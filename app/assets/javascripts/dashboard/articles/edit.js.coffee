#= require_self
#= require_tree ./edit

class ArticleEdit
  constructor: ->
    @article = $("#editarea .article")
    @space = @article.data('space')
    @saveCount = @article.data("saveCount")
    @lockScopes = []

    @editor = new Editor(
      toolbar: "#toolbar"
      editable: "#editarea .article"
    )
    @imageUploader = new Editor.ImageUploader(@editor)
    @linkCreator = new Editor.LinkCreator(@editor)
    @version = new ArticleEdit.Version(this)

    @bindActions()
    @bindShortcuts()

  bindActions: ->
    $("#urlname-form").on "submit", (event) => @saveUrlname(event)
    $("#save-status .retry a").on "click", (event )=> @saveArticle(event)
    $("#publish-button").on "click", (event) => @publishArticle(event)
    $("#draft-button").on "click", (event) => @draftArticle(event)
    $("#pick-up-button").on "click", (event) => @pickUpTopbar(event)

    if @article.hasClass("init")
      @editor.formator.h1()
      @article.one "input", =>
        @article.removeClass "init"

    if @article.data('is-workspace')
      @updateStatus()

      @updateStatusInterval = setInterval =>
        @updateStatus()
      , 10 * 1000

      $(document).one 'page:change', =>
        clearInterval @updateStatusInterval

    @article.on "editor:change", =>
      @saveArticle()

  bindShortcuts: ->
    Mousetrap.bind ["ctrl+s", "command+s"], (event) =>
      @saveArticle event

    Mousetrap.bind ["ctrl+m", "command+m"], (event) ->
      event.preventDefault()
      if $("#help-modal").is(":hidden")
        Dialog.show "#help-modal"
      else
        Dialog.hide "#help-modal"

  isPersisted: ->
    !!@article.data("id")

  saveStart: ->
    @saveCount = @saveCount + 1
    $("#save-status .saving").show().siblings().hide()

  saveCompelete: ->
    AlertMessage.remove('article-save')
    $("#save-status .saved").show().siblings().hide()

  saveUrlname: (event) ->
    event.preventDefault()
    urlname = $("#article-urlname").val()
    if @isPersisted()
      @updateArticle
        article:
          urlname: urlname
      , (data) ->
        Dialog.hide "#urlname-modal"

  updateArticle: (data, success_callback, error_callback) ->
    @saveStart()
    data.article.save_count = @saveCount
    $.ajax(
      url: "/~#{@space}/articles/" + @article.data("id")
      data: data
      type: "put"
      dataType: "json"
    ).success((data) =>
      if data.save_count is @saveCount
        @saveCompelete()
      @updateViewButton data
      success_callback data if success_callback
    ).error (xhr) =>
      try
        data = $.parseJSON(xhr.responseText)
        switch data.code
          when 'article_locked'
            AlertMessage.show
              type: 'info'
              text: I18n.t('is_editing', data.locked_user.name)
              scope: 'article-locked'
              keep: true
            @lockArticle('article-locked')
            @saveCompelete()
          when 'save_count_expired'
            # do nothing
          else
            AlertMessage.show
              type: 'error'
              text: data.message
              scope: 'article-save'
            @showRetryButton()
      catch err
        AlertMessage.show
          type: 'error'
          text: I18n.t('server_error')
          scope: 'article-save'
        @showRetryButton()
      error_callback() if error_callback

  lockArticle: (scope) ->
    if !(scope in @lockScopes)
      @lockScopes.push scope

      $('#editwrap').addClass('readonly')
      @editor.setReadonly(true)

  unlockArticle: (scope) ->
    if scope in @lockScopes
      @lockScopes.splice(@lockScopes.indexOf(scope), 1)

      if @lockScopes.length is 0
        $('#editwrap').removeClass('readonly')
        @editor.setReadonly(false)

  updateStatus: ->
    $.ajax
      url: "/~#{@space}/articles/#{@article.data("id")}/status"
      dataType: "json"
      success: (data) =>
        @article.trigger('updateStatus', data)
        if data.save_count > @saveCount
          @saveCount = data.save_count
          @updateBody(data.body)

        if data.locked_user and (data.locked_user.name isnt @article.data('current-user-name'))
          @lockArticle('article-locked')
          @updateBody(data.body)

          AlertMessage.show
            type: 'info'
            text: I18n.t('is_editing', data.locked_user.name)
            keep: true
            scope: 'article-locked'
        else
          @unlockArticle('article-locked')
          AlertMessage.remove('article-locked')

  updateBody: (body) ->
    if @version.opening
      @version.storeBody = body
    else
      @article.html(body)

  showRetryButton: ->
    $("#save-status .retry").show().siblings().hide()

  saveArticle: (event) ->
    event.preventDefault() if event

    if @isPersisted()
      @updateArticle article:
        title: @extractTitle()
        body: @editor.editable.html()
    else
      @createArticle()

    document.title = @extractTitle() or "Untitle"

  extractTitle: ->
    @editor.editable.find("h1").text()

  createArticle: ->
    @saveStart()

    return if @creating is true
    @creating = true

    # save change between ajax response
    $.ajax(
      url: "/~#{@space}/articles"
      data:
        article:
          title: @editor.editable.find("h1").text()
          body: @editor.editable.html()
          urlname: @article.data("urlname")
          status: @article.data("status")
        saveCount: _this.saveCount
      type: "post"
      dataType: "json"
    ).done((data) =>
      if data.save_count is @saveCount
        @saveCompelete()
      @article.data "id", data.token
      @updateViewButton data
      @buildDownloadList()
      history.replaceState null, null, "/~#{@space}/articles/" + data.token + "/edit"
      $('#urlname-modal .article-id').text(data.token)
      @saveArticle()
    ).fail((xhr) =>
      try
        message = $.parseJSON(xhr.responseText).message
      catch err
        message = I18n.t('server_error')
      AlertMessage.show
        type: 'error'
        text: message
        scope: 'article-save'
      @showRetryButton()
    ).always =>
      @creating = false

  buildDownloadList: () ->
    $('#download').closest('li').removeClass('hide')
    $('#download .dropdown-menu').append("
    <li><a href='/~#{@space}/articles/#{@article.data('id')}.md' target='_blank'>Markdown (.md)</a></li>
    ")

  updateViewButton: (data) ->
    $("#view-button").attr "href", data.url
    if data.status is "publish"
      $("#view-button").closest("li").removeClass "hide"
    else
      $("#view-button").closest("li").addClass "hide"

  setPublishClass: (isPublish) ->
    if isPublish
      $("#draft-button").removeClass "button-actived"
      $("#publish-button").addClass "button-actived"
    else
      $("#publish-button").removeClass "button-actived"
      $("#draft-button").addClass "button-actived"

  publishArticle: (event) ->
    @setPublishClass true
    event.preventDefault()
    if @isPersisted()
      @updateArticle
        article:
          status: "publish"
      , null, (data) =>
        @setPublishClass false
        @article.data "status", "draft"

    else
      @article.data "status", "publish"
      @createArticle()

  draftArticle: (event) ->
    event.preventDefault()
    @setPublishClass false
    if @isPersisted()
      @updateArticle
        article:
          status: "draft"
      , null, (data) =>
        @setPublishClass true
        @article.data "status", "publish"

    else
      @article.data "status", "draft"
      @createArticle()

  pickUpTopbar: (event) ->
    event.preventDefault()
    $("body").toggleClass "pick-up-topbar"

    if $("body").hasClass("pick-up-topbar")
      $.cookie "pick_up_topbar", true,
        path: "/"
        expires: 14
    else
      $.removeCookie "pick_up_topbar",
        path: "/"

  restore: ->
    @bindShortcuts()
    @editor.bindShortcuts()

@ArticleEdit = ArticleEdit

$ ->
  if $("#editwrap").length
    $("editwrap").data('article-edit', new ArticleEdit())

$(document).on 'page:restore', ->
  if $("editwrap").length
    $("editwrap").data('article-edit').restore()
