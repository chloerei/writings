page_ready ->
  if $('#topics-edit').length
    $('#edit-topic').on 'ajax:before', ->
      $(this).find('[name*=body]').val($(this).find('.body').html())

    editor = new Editor(
      toolbar: '#edit-topic .mini-toolbar'
      toolbarOptions:
        activeClass: 'button-actived'
        disableClass: 'button-disabled'
      editable: '#edit-topic .body'
    )
    $('#new-topic').data('editor', editor)
    new Editor.ImageUploader(editor)
    new Editor.LinkCreator(editor)

    $('#topics-edit').data('editor', editor)

$(document).on 'page:restore', ->
  if $('#topics-edit').length
    $('#topics-edit').data('editor').bindShortcuts()
