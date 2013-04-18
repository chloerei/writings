class ArticleEdit.Version
  constructor: ->
    @article = $('article')
    @fetchUrl = "/articles/#{@article.data('id')}/versions"
    @versions = $('#versions')

    $('#save-status .saved').on 'click', =>
      if $('#editwrap').hasClass('show-sidebar')
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
    $('#editwrap').addClass('show-sidebar readonly')
    @storeBody = @article.html()
    @article.prop('contentEditable', false)

    @page = 1
    @fetch()

  close: ->
    $('#editwrap').removeClass('show-sidebar readonly')
    $('#editarea').removeClass('readonly')
    if @storeBody
      @article.html(@storeBody)
    @storeBody = null
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

  preview: (id) ->
    $.ajax
      url: "/articles/#{@article.data('id')}/versions/#{id}"
      dataType: 'json'
      success: (data) =>
        @article.html(data.body)
        @versions.find("[data-id='#{id}']").addClass('actived').siblings().removeClass('actived')

  restore: (id) ->
    $.ajax
      url: "/articles/#{@article.data('id')}/versions/#{id}/restore"
      dataType: 'script'
      type: 'PUT'
      success: =>
        @storeBody = null
        @close()
