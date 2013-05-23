page_ready ->
  if $('#topics-show').length
    $('.discussion-form form').on 'ajax:before', ->
      $(this).find('[name*=body]').val($(this).find('.body').html())

    $('#new-comment').data('editor', new Editor(
      toolbar: '#new-comment .mini-toolbar',
      editable: '#new-comment article'
    ))
