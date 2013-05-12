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

    @versions.on 'click', '.version .restore-button', ->
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
        text: 'Loading...'
        scope: 'article-version-loading'
      $.ajax
        url: "/~#{@space}/articles/#{@article.data('id')}/versions"
        data:
          page: @page
        dataType: 'script'
        complete: =>
          AlertMessage.remove('article-version-loading')
          @fetching = false

  preview: (id) ->
    AlertMessage.show
      type: 'loading'
      text: 'Loading...'
      scope: 'article-version-preview'
    $.ajax
      url: "/~#{@space}/articles/#{@article.data('id')}/versions/#{id}"
      dataType: 'json'
      success: (data) =>
        @article.html(data.body)
        @versions.find("[data-id='#{id}']").addClass('actived').siblings().removeClass('actived')
      complete: =>
        AlertMessage.remove('article-version-preview')

  restore: (id) ->
    AlertMessage.show
      type: 'loading'
      text: 'Loading...'
      scope: 'article-version-restore'
    $.ajax
      url: "/~#{@space}/articles/#{@article.data('id')}/versions/#{id}/restore"
      dataType: 'script'
      type: 'PUT'
      success: =>
        @storeBody = null
        @close()
      complete: =>
        AlertMessage.remove('article-version-restore')
