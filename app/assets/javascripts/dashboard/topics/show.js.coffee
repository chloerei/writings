page_ready ->
  if $('#topics-show').length
    $('#new-comment').on 'ajax:before', ->
      $(this).find('[name*=body]').val($(this).find('.body').html())

    editor = new Editor(
      toolbar: '#new-comment .mini-toolbar'
      toolbarOptions:
        activeClass: 'button-actived'
        disableClass: 'button-disabled'
      editable: '#new-comment article'
    )
    $('#new-comment').data('editor', editor)
    new Editor.ImageUploader(editor)
    new Editor.LinkCreator(editor)

    $('#topics-show').data('editor', editor)

$(document).on 'page:restore', ->
  if $('#topics-show').length
    $('#topics-show').data('editor').bindShortcuts()
