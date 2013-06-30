page_ready ->
  if $('#articles-index').length
    $('#articles').on 'click', '.article:not(.selected)', (event) ->
      if event.originalEvent.srcElement.tagName isnt 'A'
        $(this).addClass('selected').find('.checkbox').removeClass('icon-check-empty').addClass('icon-check')
        if $('#articles .article:not(.selected)').length
          $('#select-all').removeClass('icon-check icon-check-empty').addClass('icon-check-minus')
        else
          $('#select-all').removeClass('icon-check-minus icon-check-empty').addClass('icon-check')

    $('#articles').on 'click', '.article.selected', (event) ->
      if event.originalEvent.srcElement.tagName isnt 'A'
        $(this).removeClass('selected').find('.checkbox').removeClass('icon-check').addClass('icon-check-empty')
        if $('#articles .article.selected').length
          $('#select-all').removeClass('icon-check').addClass('icon-check-minus')
        else
          $('#select-all').removeClass('icon-check-minus icon-check').addClass('icon-check-empty')

    $('#select-all').on 'click', ->
      if $(this).hasClass('icon-check-empty')
        $('#articles').find('.article:not(.selected)').addClass('selected').find('.checkbox').removeClass('icon-check-empty').addClass('icon-check')
        $(this).removeClass('icon-check-empty').addClass('icon-check')
      else
        $('#articles').find('.article.selected').removeClass('selected').find('.checkbox').removeClass('icon-check').addClass('icon-check-empty')
        $(this).removeClass('icon-check icon-check-minus').addClass('icon-check-empty')
