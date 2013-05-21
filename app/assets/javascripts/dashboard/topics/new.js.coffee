page_ready ->
  if $('#topics-new').length
    $('.discussion-form form').on 'ajax:before', ->
      $(this).find('[name*=body]').val($(this).find('.body').html())
