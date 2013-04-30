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
    @version = new ArticleEdit.Version()
    @article = $("#editarea article")
    @saveCount = @article.data("saveCount")

    @bindActions()

  bindActions: ->
    $("#urlname-form").on "submit", (event) => @saveUrlname(event)
    $("#save-status .retry a").on "click", (event )=> @saveArticle(event)
    $("#publish-button").on "click", (event) => @publishArticle(event)
    $("#draft-button").on "click", (event) => @draftArticle(event)
    $("#category-form").on "submit", (event) => @saveCategory(event)
    $("#new-category-form").on "submit", (event) => @createCategory(event)
    $("#pick-up-button").on "click", (event) => @pickUpTopbar(event)

    $("#category-form .dropdown").on "click", ".dropdown-menu li a", (event) ->
      event.preventDefault()
      $item = $(this)
      $item.closest(".dropdown").find(".dropdown-toggle").text $item.text()
      $("#article-category-id").val $item.data("category-id")

    if @article.hasClass("init")
      @editor.formator.h1()
      @article.one "input", =>
        @article.removeClass "init"

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

  saveCompelete: (data) ->
    if data.save_count is @saveCount
      AlertMessage.clear()
      $("#save-status .saved").attr("title", data.updated_at).show().siblings().hide()

  saveError: (xhr) ->
    try
      AlertMessage.error $.parseJSON(xhr.responseText).message or "Save Failed"
    catch err
      AlertMessage.error "Server Error"
    $("#save-status .retry").show().siblings().hide()

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
      url: "/articles/" + @article.data("id")
      data: data
      type: "put"
      dataType: "json"
    ).success((data) =>
      @saveCompelete data
      @updateViewButton data
      success_callback data if success_callback
    ).error (xhr) =>
      @saveError xhr
      error_callback() if error_callback

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

  createCategory: (event) ->
    event.preventDefault()
    $.ajax(
      url: "/categories/"
      data: $("#new-category-form").serializeArray()
      type: "post"
      dataType: "json"
    ).success (data) ->
      $li = $("<li><a href=\"#\">")
      $li.find("a").text(data.name).data "category-id", data.urlname
      $("#category-form .dropdown-menu").prepend $li
      $("#category-form .dropdown-toggle").text data.name
      $("#article-category-id").val data.urlname
      Dialog.hide "#new-category-modal"

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
      url: "/articles"
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
      @saveCompelete data
      @article.data "id", data.token
      @updateViewButton data
      history.replaceState null, null, "/articles/" + data.token + "/edit"
      @saveArticle()
    ).fail((xhr) =>
      @saveError xhr
      $("#save-status .retry").show().siblings().hide()
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
        path: "/articles"
        expires: 14
    else
      $.removeCookie "pick_up_topbar",
        path: "/articles"

@ArticleEdit = ArticleEdit

page_ready ->
  new ArticleEdit() if $("body#articles-edit").length
