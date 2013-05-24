page_ready ->
  if $('#comments-edit').length
    $('#edit-comment').on 'ajax:before', ->
      $(this).find('[name*=body]').val($(this).find('.body').html())

    editor = new Editor(
      toolbar: '#edit-comment .mini-toolbar'
      toolbarOptions:
        activeClass: 'button-actived'
        disableClass: 'button-disabled'
      editable: '#edit-comment article'
    )
    $('#edit-comment').data('editor', editor)
    new Editor.ImageUploader(editor)
    new Editor.LinkCreator(editor)
