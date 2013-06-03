class ArticleEdit.Version
  constructor: (@manager) ->
    @article = @manager.article
    @space = @manager.space
    @versions = $('#versions')

    $('#save-status .saved').on 'click', =>
      if @opening
        @close()
      else
        @open()

    $('#history .close-button').on 'click', =>
      @close()

    @versions.on 'click', '.version:not(".actived")', ->
      _this.preview($(this).data('id'))

    @versions.on 'click', '.version .restore-button', (event) ->
      event.preventDefault()
      _this.restore($(this).closest('.version').data('id'))

    @scrollable = $('#history .scrollable')
    @scrollable.on 'scroll', (event) =>
      if @scrollable.prop('scrollHeight') - @scrollable.scrollTop() - @scrollable.height() < 200 and !@fetching
        @nextPage()

  open: ->
    @manager.lockArticle('article-versions')
    $('#editwrap').addClass('show-sidebar')
    @storeBody = @article.html()

    @opening = true
    @page = 1
    @fetch()

  close: ->
    @manager.unlockArticle('article-versions')
    $('#editwrap').removeClass('show-sidebar')
    if @storeBody
      @article.html(@storeBody)
    @storeBody = null

    AlertMessage.remove 'article-version-preview'
    @versions.html('').data('isEnd', false)
    @fetching = false
    @opening = false

  nextPage: ->
    @page += 1
    @fetch()

  isEnd: ->
    @versions.data('isEnd')

  fetch: ->
    if !@fetching and !@isEnd()
      @fetching = true
      AlertMessage.show
        type: 'loading'
        text: I18n.t('loading')
        scope: 'article-version-fetch'
        keep: true
      $.ajax
        url: "/~#{@space}/articles/#{@article.data('id')}/versions"
        data:
          page: @page
        dataType: 'script'
        complete: =>
          AlertMessage.remove('article-version-fetch')
          @fetching = false
        error: (xhr) =>
          @onError(xhr, 'article-version-fetch')

  preview: (id) ->
    AlertMessage.show
      type: 'loading'
      text: I18n.t('loading')
      scope: 'article-version-preview'
      keep: true
    $.ajax
      url: "/~#{@space}/articles/#{@article.data('id')}/versions/#{id}"
      dataType: 'json'
      success: (data) =>
        @article.html(data.body)
        @versions.find("[data-id='#{id}']").addClass('actived').siblings().removeClass('actived')
        AlertMessage.show
          type: 'info'
          text: data.created_at
          scope: 'article-version-preview'
          keep: true
      error: (xhr) =>
        @onError(xhr, 'article-version-preview')

  restore: (id) ->
    AlertMessage.show
      type: 'loading'
      text: I18n.t('loading')
      scope: 'article-version-restore'
      keep: true
    $.ajax
      url: "/~#{@space}/articles/#{@article.data('id')}/versions/#{id}/restore"
      dataType: 'json'
      type: 'PUT'
      success: =>
        AlertMessage.remove 'article-version-restore'
        @storeBody = null
        @close()
      error: (xhr) =>
        @onError(xhr, 'article-version-restore')

  onError: (xhr, scope) ->
    try
      message = $.parseJSON(xhr.responseText).message
    catch err
      message = I18n.t('server_error')
    AlertMessage.show
      type: 'error'
      text: message
      scope: scope
