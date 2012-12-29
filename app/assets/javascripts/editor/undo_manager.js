Editor.UndoManager = function(editable) {
  this.editable = $(editable);
  this.undoStack = [];
  this.redoStack = [];
  this.save();
};

Editor.UndoManager.prototype = {
  save: function() {
    this.undoStack.push(this.editable.html());
    this.redoStack = [];
  },

  undo: function() {
    var html = this.undoStack.pop();
    if (html) {
      this.redoStack.push(this.editable.html());
      this.editable.html(html);
    }
  },

  redo: function() {
    var html = this.redoStack.pop();
    if (html) {
      this.undoStack.push(this.editable.html());
      this.editable.html(html);
    }
  }
};
