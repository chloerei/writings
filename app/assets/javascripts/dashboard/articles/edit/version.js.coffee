class ArticleEdit.Version
  constructor: ->
    @article = $('article')
    @fetchUrl = "/articles/#{@article.data('id')}/versions"
    @versions = $('#versions')

    $('#save-status').on 'click', =>
      $('#editwrap').toggleClass('show-sidebar')
      if $('#editwrap').hasClass('show-sidebar')
        @init()
      else
        @clear()

    $('#history .close-button').on 'click', =>
      $('#editwrap').removeClass('show-sidebar')
      @clear()

    @versions.on 'click', 'li', ->
      $(this).addClass('actived').siblings().removeClass('actived')

    @scrollable = $('#history .scrollable')
    @scrollable.on 'scroll', (event) =>
      if @scrollable.prop('scrollHeight') - @scrollable.scrollTop() - @scrollable.height() < 200 and !@fetching
        @nextPage()

  init: ->
    @storeBody = @article.html()
    @article.prop('contentEditable', false)

    @page = 1
    @fetch()

  clear: ->
    if @storeBody
      @article.html(@storeBody)
    @article.prop('contentEditable', true)

    @versions.html('').data('isEnd', false)
    @fetching = false

  nextPage: ->
    @page += 1
    @fetch()

  isEnd: ->
    @versions.data('isEnd')

  fetch: ->
    if !@fetching and !@isEnd()
      @fetching = true
      $.ajax
        url: @fetchUrl
        data:
          page: @page
        dataType: 'script'
        complete: =>
          @fetching = false
