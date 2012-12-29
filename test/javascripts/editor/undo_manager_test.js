var undoManager;

module("Editor.UndoManager", {
  setup: function() {
    undoManager = new Editor.UndoManager('#qunit-fixture .editable');
  },
  teardown: function() {
    undoManager = null;
  }
});

test("can save, undo, redo state", function() {
  equal(undoManager.undoStack.length, 1);
  equal(undoManager.redoStack.length, 0);
  undoManager.editable.html('<p>state one</p>');
  undoManager.save();
  equal(undoManager.undoStack.length, 2);
  equal(undoManager.redoStack.length, 0);

  undoManager.editable.html('<p>state two</p>');
  undoManager.undo();
  equal(undoManager.undoStack.length, 1);
  equal(undoManager.redoStack.length, 1);
  equal('<p>state one</p>', undoManager.editable.html());

  undoManager.redo();
  equal(undoManager.undoStack.length, 2);
  equal(undoManager.redoStack.length, 0);
  equal('<p>state two</p>', undoManager.editable.html());
});

test("flush redo state when save", function() {
  undoManager.editable.html('state one');
  undoManager.save();
  undoManager.undo();
  equal(undoManager.redoStack.length, 1);
  undoManager.editable.html('state two');
  undoManager.save();
  equal(undoManager.redoStack.length, 0);
});
