module "Editor.UndoManager",
  setup: ->
    @editor = new Editor(editable: "#qunit-fixture .editable")
    @undoManager = @editor.undoManager
    @undoManager.undoStack = [] # clear for formator effect

test "can save, undo, redo state", ->
  equal @undoManager.undoStack.length, 0
  equal @undoManager.redoStack.length, 0
  @undoManager.editable.html "<p>state one</p>"
  @undoManager.save()
  equal @undoManager.undoStack.length, 1
  equal @undoManager.redoStack.length, 0
  @undoManager.editable.html "<p>state two</p>"
  @undoManager.save()
  equal @undoManager.undoStack.length, 2
  equal @undoManager.redoStack.length, 0
  @undoManager.undo()
  equal @undoManager.undoStack.length, 1
  equal @undoManager.redoStack.length, 1
  equal @undoManager.editable.html(), "<p>state one</p>"
  @undoManager.redo()
  equal @undoManager.undoStack.length, 2
  equal @undoManager.redoStack.length, 0
  equal @undoManager.editable.html(), "<p>state two</p>"

test "shoud save two text node range.", ->
  textNode1 = document.createTextNode("text1")
  textNode2 = document.createTextNode("text2")
  @undoManager.editable.html $("<p>").append(textNode1).append(textNode2)
  range = document.createRange()
  range.setStart textNode1, 0
  range.setEnd textNode2, textNode2.length
  document.getSelection().removeAllRanges()
  document.getSelection().addRange range
  @undoManager.save()
  equal @undoManager.editable.html(), "<p>text1text2</p>"

test "flush redo state when save", ->
  @undoManager.editable.html "state one"
  @undoManager.save()
  @undoManager.undo()
  equal @undoManager.redoStack.length, 1
  @undoManager.editable.html "state two"
  @undoManager.save()
  equal @undoManager.redoStack.length, 0

test "currentContents", ->
  @undoManager.editable.html "<p>line one</p>"
  $contents = @undoManager.currentContents()
  ok $contents.length
  equal $contents.find("[data-range-start]").length, 0
  equal $contents.find("[data-range-end]").length, 0
  document.getSelection().selectAllChildren @undoManager.editable[0]
  $contents = @undoManager.currentContents()
  equal $contents.find("[data-range-start]").length, 1
  equal $contents.find("[data-range-end]").length, 1

  # clean editable
  equal @undoManager.editable.contents().find("[data-range-start]").length, 0
  equal @undoManager.editable.contents().find("[data-range-end]").length, 0

test "applyContents", ->
  @undoManager.editable.html "<p>line one</p>"
  document.getSelection().selectAllChildren @undoManager.editable[0]
  $contents = @undoManager.currentContents()
  @undoManager.editable.html ""
  @undoManager.applyContents $contents
  equal @undoManager.editable.html(), "<p>line one</p>"
