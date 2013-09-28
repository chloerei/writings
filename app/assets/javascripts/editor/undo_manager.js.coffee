class @Editor.UndoManager
  undoSize: 50

  constructor: (@editor) ->
    @editable = @editor.editable
    @stashContents = @currentContents()
    @undoStack = []
    @redoStack = []

  # call **after** content change
  save: ->
    @undoStack.push @stashContents
    if @undoStack.length > @undoSize
      @undoStack.shift()
    @stashContents = @currentContents()
    @redoStack = []

  undo: ->
    $contents = @undoStack.pop()
    if $contents
      @redoStack.push @stashContents
      @stashContents = $contents.clone()
      @applyContents $contents
    @editable.trigger "editor:change"

  redo: ->
    $contents = @redoStack.pop()
    if $contents
      @undoStack.push @stashContents
      @stashContents = $contents.clone()
      @applyContents $contents
    @editable.trigger "editor:change"

  hasUndo: ->
    @undoStack.length > 0

  hasRedo: ->
    @redoStack.length > 0

  # Mark selection range, clone current content.
  #
  # example:
  #
  #   <p>normal text <span data-range-start="0" data-range-end="6">select</span><p>
  #
  #   <p data-range-start="0" data-range-end="6">select</p>
  currentContents: ->
    if document.getSelection().rangeCount isnt 0
      range = document.getSelection().getRangeAt(0)
      startOffset = range.startOffset
      endOffset = range.endOffset
      $container = undefined
      $startContainer = $(range.startContainer)
      $endContainer = $(range.endContainer)

      # wrap text node in span to store data
      if range.startContainer is range.endContainer
        $container = $(range.startContainer)
        if $container[0].nodeType is 3 # TEXT NODE
          $container.wrap $("<span>").attr("data-range-start", range.startOffset).attr("data-range-end", range.endOffset)
        else
          $container.attr("data-range-start", range.startOffset).attr "data-range-end", range.endOffset
      else
        if $startContainer[0].nodeType is 3 # TEXT NODE
          $startContainer.wrap $("<span>").attr("data-range-start", range.startOffset)
        else
          $startContainer.attr "data-range-start", range.startOffset
        if $endContainer[0].nodeType is 3 # TEXT NODE
          $endContainer.wrap $("<span>").attr("data-range-end", range.endOffset)
        else
          $endContainer.attr "data-range-end", range.endOffset
      contents = @editable.contents().clone()

      # clean data in original element
      if $container
        if $container[0].nodeType is 3
          $container.closest("span").replaceWith $container
        else
          $container.removeAttr("data-range-start").removeAttr "data-range-end"
      else
        if $startContainer[0].nodeType is 3 # TEXT NODE
          $startContainer.parent("span").replaceWith $startContainer
        else
          $startContainer.removeAttr "data-range-start"
        if $endContainer[0].nodeType is 3 # TEXT NODE
          $endContainer.parent("span").replaceWith $endContainer
        else
          $endContainer.removeAttr "data-range-end"
      range.setStart $startContainer[0], startOffset
      range.setEnd $endContainer[0], endOffset
      document.getSelection().removeAllRanges()
      document.getSelection().addRange range
      contents
    else
      @editable.contents().clone()

  # Restore content, and reset selection range.
  applyContents: ($contents) ->
    @editable.html $contents
    $startContainer = @editable.find("[data-range-start]")
    $endContainer = @editable.find("[data-range-end]")
    if $startContainer.length isnt 0 and $endContainer.length isnt 0
      startOffset = $startContainer.data("range-start")
      endOffset = $endContainer.data("range-end")
      startContainer = $startContainer[0]
      endContainer = $endContainer[0]
      if startContainer is endContainer
        if $startContainer.is("span")
          startContainer = endContainer = $startContainer.contents()[0]
          $startContainer.replaceWith startContainer
        else
          $startContainer.removeAttr "data-range-start"
          $endContainer.removeAttr "data-range-end"
      else
        if $startContainer.is("span")
          startContainer = $startContainer.contents()[0]
          $startContainer.replaceWith startContainer
        else
          $startContainer.removeAttr "data-range-start"
        if $endContainer.is("span")
          endContainer = $endContainer.contents()[0]
          $endContainer.replaceWith endContainer
        else
          $endContainer.removeAttr "data-range-end"
      range = document.createRange()
      range.setStart startContainer, startOffset
      range.setEnd endContainer, endOffset
      document.getSelection().removeAllRanges()
      document.getSelection().addRange range
