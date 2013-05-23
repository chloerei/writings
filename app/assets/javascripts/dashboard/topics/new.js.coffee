page_ready ->
  if $('#topics-new').length
    $('.discussion-form form').on 'ajax:before', ->
      $(this).find('[name*=body]').val($(this).find('.body').html())

    $('#new-topic').data('editor', new Editor(
      toolbar: '#new-topic .mini-toolbar',
      editable: '#new-topic .body'
    ))
