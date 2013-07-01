page_ready ->
  if $('#topics-new').length
    $('#new-topic').on 'ajax:before', ->
      $(this).find('[name*=body]').val($(this).find('.body').html())

    editor = new Editor(
      toolbar: '#new-topic .mini-toolbar'
      toolbarOptions:
        activeClass: 'button-actived'
        disableClass: 'button-disabled'
      editable: '#new-topic .body'
    )
    $('#new-topic').data('editor', editor)
    new Editor.ImageUploader(editor)
    new Editor.LinkCreator(editor)
    $('#topic_title').focus()

    $('#topics-new').data('editor', editor)

$(document).on 'page:restore', ->
  if $('#topics-new').length
    $('#topics-new').data('editor').bindShortcuts()
