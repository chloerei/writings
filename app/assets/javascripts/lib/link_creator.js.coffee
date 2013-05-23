class @LinkCreator
  constructor: (@editor) ->
    @editor.formator.link = =>
      @open()

    @modal = $('#link-creator-modal')
    @input = @modal.find('input[name=url]')

    @bindActions()

  bindActions: ->
    $("#link-form").on "submit", (event) =>
      event.preventDefault()
      @editor.restoreRange()
      @editor.formator.exec 'createLink', @input.val()
      @editor.formator.afterFormat()
      @input.val('')
      @close()

    $("#unlink-button").on "click", (event) =>
      event.preventDefault()
      @editor.restoreRange()
      @editor.formator.exec 'unlink'
      @editor.formator.afterFormat()
      @close()

  open: ->
    if @editor.formator.isWraped('a')
      @input.val($(@editor.formator.commonAncestorContainer()).closest("a").attr("href"))
    else
      @input.val('')
    Dialog.show(@modal)
    @input.focus()

  close: ->
    Dialog.hide(@modal)
