Editor.Formator::link = (url) ->
  @editor.restoreRange()
  if url
    document.getSelection().selectAllChildren $(@commonAncestorContainer()).closest("a")[0]  if @isWraped("a")
    if url isnt ""
      @exec "createLink", url
    else
      @exec "unlink"
    @afterFormat()
    Dialog.hide "#link-modal"
  else
    link = ""
    link = $(@commonAncestorContainer()).closest("a").attr("href")  if @isWraped("a")
    Dialog.show "#link-modal"
    $("#link-modal").find("input[name=url]").val(link).focus()
