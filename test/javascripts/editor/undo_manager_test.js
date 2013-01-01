module("Editor.UndoManager", {
  setup: function() {
    this.undoManager = new Editor.UndoManager('#qunit-fixture .editable');
  },
  teardown: function() {
    this.undoManager = null;
  }
});

test("can save, undo, redo state", function() {
  equal(this.undoManager.undoStack.length, 0);
  equal(this.undoManager.redoStack.length, 0);
  this.undoManager.editable.html('<p>state one</p>');
  this.undoManager.save();
  equal(this.undoManager.undoStack.length, 1);
  equal(this.undoManager.redoStack.length, 0);

  this.undoManager.editable.html('<p>state two</p>');
  this.undoManager.save();
  equal(this.undoManager.undoStack.length, 2);
  equal(this.undoManager.redoStack.length, 0);

  this.undoManager.undo();
  equal(this.undoManager.undoStack.length, 1);
  equal(this.undoManager.redoStack.length, 1);
  equal('<p>state one</p>', this.undoManager.editable.html());

  this.undoManager.redo();
  equal(this.undoManager.undoStack.length, 2);
  equal(this.undoManager.redoStack.length, 0);
  equal('<p>state two</p>', this.undoManager.editable.html());
});

test("flush redo state when save", function() {
  this.undoManager.editable.html('state one');
  this.undoManager.save();
  this.undoManager.undo();
  equal(this.undoManager.redoStack.length, 1);
  this.undoManager.editable.html('state two');
  this.undoManager.save();
  equal(this.undoManager.redoStack.length, 0);
});

test("currentContents", function() {
  this.undoManager.editable.html('<p>line one</p>');
  var $contents = this.undoManager.currentContents();
  ok($contents.length);
  equal($contents.find('[data-range-start]').length, 0);
  equal($contents.find('[data-range-end]').length, 0);

  document.getSelection().selectAllChildren(this.undoManager.editable[0]);
  $contents = this.undoManager.currentContents();
  equal($contents.find('[data-range-start]').length, 1);
  equal($contents.find('[data-range-end]').length, 1);
  // clean editable
  equal(this.undoManager.editable.contents().find('[data-range-start]').length, 0);
  equal(this.undoManager.editable.contents().find('[data-range-end]').length, 0);
});

test("applyContents", function() {
  this.undoManager.editable.html('<p>line one</p>');
  document.getSelection().selectAllChildren(this.undoManager.editable[0]);
  var $contents = this.undoManager.currentContents();
  this.undoManager.editable.html('');
  this.undoManager.applyContents($contents);
  equal(this.undoManager.editable.html(), '<p>line one</p>');
});
