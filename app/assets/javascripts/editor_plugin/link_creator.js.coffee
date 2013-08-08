class @Editor.LinkCreator
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
      url = @input.val()
      if !url.match(/\w+:\/\//)
        url = "http://#{url}"

      if @editor.formator.isWraped('a')
        $(@editor.formator.commonAncestorContainer()).closest("a").prop('href', url)
      else
        @editor.formator.exec 'createLink', url
      @editor.formator.afterFormat()
      @input.val('')
      @close()

    $("#unlink-button").on "click", (event) =>
      event.preventDefault()
      @editor.restoreRange()
      if @editor.formator.isWraped('a')
        document.getSelection().selectAllChildren $(@editor.formator.commonAncestorContainer()).closest("a")[0]
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
