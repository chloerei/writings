#= require editor
#= require_self
#= require_tree ./edit

class ArticleEdit
  constructor: ->
    @editor = new Editor(
      toolbar: "#toolbar"
      editable: "#editarea article"
    )
    @imageUploader = new ArticleEdit.ImageUploader(@editor)
    @version = new ArticleEdit.Version(this)
    @article = $("#editarea article")
    @space = @article.data('space')
    @saveCount = @article.data("saveCount")

    @lockScopes = []

    @bindActions()

  bindActions: ->
    $("#urlname-form").on "submit", (event) => @saveUrlname(event)
    $("#save-status .retry a").on "click", (event )=> @saveArticle(event)
    $("#publish-button").on "click", (event) => @publishArticle(event)
    $("#draft-button").on "click", (event) => @draftArticle(event)
    $("#category-form").on "submit", (event) => @saveCategory(event)
    $("#pick-up-button").on "click", (event) => @pickUpTopbar(event)

    $("#new-category-form").on "ajax:success", (event, data) ->
      $li = $("<li><a href=\"#\">")
      $li.find("a").text(data.name).data "category-id", data.urlname
      $("#category-form .dropdown-menu").prepend $li
      $("#category-form .dropdown-toggle").text data.name
      $("#article-category-id").val data.urlname
      Dialog.hide "#new-category-modal"

    $("#category-form .dropdown").on "click", ".dropdown-menu li a", (event) ->
      event.preventDefault()
      $item = $(this)
      $item.closest(".dropdown").find(".dropdown-toggle").text $item.text()
      $("#article-category-id").val $item.data("category-id")

    if @article.hasClass("init")
      @editor.formator.h1()
      @article.one "input", =>
        @article.removeClass "init"

    if @article.data('is-workspace')
      @updateStatus()

      setInterval =>
        @updateStatus()
      , 10 * 1000

    @article.on "editor:change", =>
      @saveArticle()

    $("#link-form").on "submit", (event) =>
      event.preventDefault()
      @editor.formator.link $("#link-form input[name=url]").val()

    $("#unlink-button").on "click", (event) =>
      event.preventDefault()
      @editor.formator.link ""

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
        if xhr.status is 400
          switch data.code
            when 'article_locked'
              AlertMessage.show
                type: 'info'
                text: data.message
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
        else
          AlertMessage.show
            type: 'error'
            text: data.message
            scope: 'article-save'
          @showRetryButton()
      catch err
        AlertMessage.show
          type: 'error'
          text: 'Server Error'
          scope: 'article-save'
        @showRetryButton()
      error_callback() if error_callback

  lockArticle: (scope) ->
    if !(scope in @lockScopes)
      @lockScopes.push scope

      $('#editwrap').addClass('readonly')
      @article.prop('contentEditable', false)

  unlockArticle: (scope) ->
    if scope in @lockScopes
      @lockScopes.splice(@lockScopes.indexOf(scope), 1)

      if @lockScopes.length is 0
        $('#editwrap').removeClass('readonly')
        @article.prop('contentEditable', true)

  updateStatus: ->
    $.ajax
      url: "/~#{@space}/articles/#{@article.data("id")}/edit"
      dataType: "json"
      success: (data) =>
        if data.save_count > @saveCount
          @saveCount = data.save_count
          @article.html(data.body)

        if data.locked_user and (data.locked_user.name isnt @article.data('current-user-name'))
          @lockArticle('article-locked')

          AlertMessage.remove('article-locked')
          AlertMessage.show
            type: 'info'
            text: "#{data.locked_user.name} is editing"
            keep: true
            scope: 'article-locked'
        else
          @unlockArticle('article-locked')
          AlertMessage.remove('article-locked')

  showRetryButton: ->
    $("#save-status .retry").show().siblings().hide()

  saveCategory: (event) ->
    event.preventDefault()
    categoryId = $("#article-category-id").val()
    categoryName = $("#category-form .dropdown-toggle").text()
    if @isPersisted()
      @updateArticle
        article:
          category_id: categoryId
      , (data) =>
        @article.data "category-id", categoryId
        Dialog.hide "#select-category-modal"

    else
      @article.data "category-id", categoryId
      @createArticle()
      Dialog.hide "#select-category-modal"

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
          category_id: @article.data("category-id")
          status: @article.data("status")
        saveCount: _this.saveCount
      type: "post"
      dataType: "json"
    ).done((data) =>
      if data.save_count is @saveCount
        @saveCompelete()
      @article.data "id", data.token
      @updateViewButton data
      history.replaceState null, null, "/~#{@space}/articles/" + data.token + "/edit"
      $('#urlname-modal .article-id').text(data.token)
      @saveArticle()
    ).fail((xhr) =>
      try
        AlertMessage.show
          type: 'error'
          text: $.parseJSON(xhr.responseText).message or "Save Failed"
          scope: 'article-save'
      catch err
        AlertMessage.show
          type: 'error'
          text: 'server Error'
          scope: 'article-save'
      @showRetryButton()
    ).always =>
      @creating = false

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

@ArticleEdit = ArticleEdit

page_ready ->
  new ArticleEdit() if $("body#articles-edit").length
