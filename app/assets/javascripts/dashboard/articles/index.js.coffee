ArticlesCtrl =
  init: ->
    $('#toolbar').on('click', '.close-button', ->
      $('#articles .article.selected').removeClass('selected')
      $('#normal-nav').removeClass('hide')
      $('#toolbar').addClass('hide')
    ).on('click', '.select-all-button', ->
      button = $(this)
      if button.hasClass('actived')
        $('#articles .article').removeClass('selected')
      else
        $('#articles .article').addClass('selected')

      button.toggleClass('actived')
      ArticlesCtrl.updateItemCount()
    ).on('ajax:before', '[data-batch=true]', (event) ->
      ids = $('#articles .article.selected').map( ->
        $(this).data('id')
      ).get()

      $(this).data('params', {ids: ids})
    )

    $('#articles').on 'click', '.article', (event) ->
      if event.target.tagName isnt 'A'
        article = $(this)
        article.toggleClass('selected')

        ArticlesCtrl.updateItemCount()
        ArticlesCtrl.updateToolbar()

    $('#topbar').on 'click', '.search-toggle', ->
      $('#normal-nav').addClass('searching')
      $('#search-input').focus()

    lastSearchXHR = null
    $('#search-input').on('focus', ->
      $('#normal-nav').addClass('searching')
      $('body').data('need-reload', true)
    ).on('input', ->
      form = $('#search-form')
      $.getScript(form.prop('action') + '?' + form.serialize())
    )

    $('#search-form').on('reset', ->
      Turbolinks.visit($(this).data('reset-url'))
    ).on('submit', (event) ->
      event.preventDefault()
      form = $(this)
      Turbolinks.visit(form.prop('action') + '?' + form.serialize())
    )

  updateItemCount: ->
    count = $('#articles .article.selected').length
    $('#selected-count').text(count)

    if $('#articles .article').length == count
      $('#toolbar .select-all-button').addClass('actived')
    else
      $('#toolbar .select-all-button').removeClass('actived')

  updateToolbar: ->
    if $('#articles .article.selected').length > 0
      $('#normal-nav').addClass('hide')
      $('#toolbar').removeClass('hide')
    else
      $('#normal-nav').removeClass('hide')
      $('#toolbar').addClass('hide')

$(document).on 'page:restore', ->
  if $('body').data('need-reload')
    Turbolinks.visit(location.href)

$ ->
  if $('#articles').length
    ArticlesCtrl.init()
