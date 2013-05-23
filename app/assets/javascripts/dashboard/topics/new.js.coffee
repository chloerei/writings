page_ready ->
  if $('#topics-new').length
    $('.discussion-form form').on 'ajax:before', ->
      $(this).find('[name*=body]').val($(this).find('.body').html())

    editor = new Editor(
      toolbar: '#new-topic .mini-toolbar',
      editable: '#new-topic .body'
    )
    $('#new-topic').data('editor', editor)
    new ImageUploader(editor)
    new LinkCreator(editor)
