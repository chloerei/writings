Editor.Formator = function(editable) {
  this.editable = $(editable);
};

Editor.Formator.prototype = {
  isBold: function() {
    return document.queryCommandValue('bold') === 'true';
  },

  canBold: function() {
    return !this.isWraped('h1, h2, h3, h4');
  },

  bold: function() {
    this.exec('bold');
  },

  isWraped: function(selector) {
    if (this.commonAncestorContainer()) {
      return $(this.commonAncestorContainer()).closest(selector).length !== 0;
    } else {
      return false;
    }
  },

  commonAncestorContainer: function() {
    var selection = document.getSelection();
    if (selection.rangeCount !== 0) {
      return selection.getRangeAt(0).commonAncestorContainer;
    }
  },

  exec: function(command, arg) {
    document.execCommand(command, false, arg);
  }
};
