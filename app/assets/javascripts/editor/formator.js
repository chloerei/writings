Editor.Formator = function(editable) {
  this.editable = $(editable);
};

Editor.Formator.prototype = {
  isBold: function() {
    return this.canBold() && document.queryCommandValue('bold') === 'true';
  },

  canBold: function() {
    return !this.isWraped('h1, h2, h3, h4, code');
  },

  bold: function() {
    if (this.canBold()) {
      this.exec('bold');
    }
  },

  isItalic: function() {
    return this.canItalic() && document.queryCommandValue('italic') === 'true';
  },

  canItalic: function() {
    return !this.isWraped('code');
  },

  italic: function() {
    if (this.canItalic()) {
      this.exec('italic');
    }
  },

  isStrikeThrough: function() {
    return this.canItalic() && document.queryCommandValue('strikeThrough') === 'true';
  },

  canStrikeThrough: function() {
    return !this.isWraped('code');
  },

  strikeThrough: function() {
    if (this.canStrikeThrough()) {
      this.exec('strikeThrough');
    }
  },

  isUnderline: function() {
    return this.canItalic() && document.queryCommandValue('underline') === 'true';
  },

  canUnderline: function() {
    return !this.isWraped('code');
  },

  underline: function() {
    if (this.canUnderline()) {
      this.exec('underline');
    }
  },

  isOrderedList: function() {
    return this.canOrderedList() && document.queryCommandValue('insertOrderedList') === 'true';
  },

  canOrderedList: function() {
    return !this.isWraped('h1, h2, h3, h4, code');
  },

  orderedList: function() {
    if (this.canUnderline()) {
      this.exec('insertOrderedList');
    }
  },

  isUnorderedList: function() {
    return this.canUnorderedList() && document.queryCommandValue('insertUnorderedList') === 'true';
  },

  canUnorderedList: function() {
    return !this.isWraped('h1, h2, h3, h4, code');
  },

  unorderedList: function() {
    if (this.canUnderline()) {
      this.exec('insertUnorderedList');
    }
  },

  isLink: function() {
    return this.canLink() && document.queryCommandValue('createLink') === 'true';
  },

  canLink: function() {
    return !this.isWraped('code');
  },

  link: function() {
    var url = prompt('Link url:', 'http://');
    if (url !== null && url !== '') {
      this.exec('createLink', url);
    }
  },

  isH1: function() {
    return this.isWraped('h1');
  },

  canH1: function() {
    return !this.isWraped('li, code');
  },

  h1: function() {
    if (this.canH1()) {
      this.formatHeader('h1');
    }
  },

  isH2: function() {
    return this.isWraped('h2');
  },

  canH2: function() {
    return !this.isWraped('li, code');
  },

  h2: function() {
    if (this.canH2()) {
      this.formatHeader('h2');
    }
  },

  isH3: function() {
    if (this.canH3()) {
      return this.isWraped('h3');
    }
  },

  canH3: function() {
    return !this.isWraped('li, code');
  },

  h3: function() {
    if (this.canH3()) {
      this.formatHeader('h3');
    }
  },

  isH4: function() {
    return this.isWraped('h4');
  },

  canH4: function() {
    return !this.isWraped('li, code');
  },

  h4: function() {
    if (this.canH4()) {
      this.formatHeader('h4');
    }
  },

  isP: function() {
    return this.isWraped('p');
  },

  canP: function() {
    return !this.isWraped('li, code');
  },

  p: function() {
    this.exec('formatBlock', 'p');
  },

  formatHeader: function(type) {
    if (document.queryCommandValue('formatBlock') === type) {
      this.p();
    } else {
      this.exec('formatBlock', type);
    }
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
