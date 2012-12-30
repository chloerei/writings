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
  equal(undoManager.undoStack.length, 0);
  equal(undoManager.redoStack.length, 0);
  undoManager.editable.html('<p>state one</p>');
  undoManager.save();
  equal(undoManager.undoStack.length, 1);
  equal(undoManager.redoStack.length, 0);

  undoManager.editable.html('<p>state two</p>');
  undoManager.save();
  equal(undoManager.undoStack.length, 2);
  equal(undoManager.redoStack.length, 0);

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

test("currentContents", function() {
  undoManager.editable.html('<p>line one</p>');
  var $contents = undoManager.currentContents();
  ok($contents.length);
  equal($contents.find('[data-range-start]').length, 0);
  equal($contents.find('[data-range-end]').length, 0);

  document.getSelection().selectAllChildren(undoManager.editable[0]);
  $contents = undoManager.currentContents();
  equal($contents.find('[data-range-start]').length, 1);
  equal($contents.find('[data-range-end]').length, 1);
  // clean editable
  equal(undoManager.editable.contents().find('[data-range-start]').length, 0);
  equal(undoManager.editable.contents().find('[data-range-end]').length, 0);
});

test("applyContents", function() {
  undoManager.editable.html('<p>line one</p>');
  document.getSelection().selectAllChildren(undoManager.editable[0]);
  var $contents = undoManager.currentContents();
  undoManager.editable.html('');
  undoManager.applyContents($contents);
  equal(undoManager.editable.html(), '<p>line one</p>');
});
