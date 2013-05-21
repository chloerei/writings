page_ready ->
  if $('#topics-show').length
    $('.discussion-form form').on 'ajax:before', ->
      $(this).find('[name*=body]').val($(this).find('.body').html())
