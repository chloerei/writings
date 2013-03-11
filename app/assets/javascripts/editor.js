//= require_self
//= require_tree ./editor
Mousetrap.stopCallback = function(e, element, combo) {
  // stop for input, select, and textarea
  return element.tagName == 'INPUT' || element.tagName == 'SELECT' || element.tagName == 'TEXTAREA';
};

var Editor = function(options) {
  this.editable_selector = options.editable;
  this.editable = $(options.editable);

  this.sanitize = new Editor.Sanitize(this.editable);
  this.formator = new Editor.Formator(this);
  this.formator.exec('defaultParagraphSeparator', 'p');

  this.editable.focus();
  this.undoManager = new Editor.UndoManager(this.editable);

  if (options.toolbar) {
    this.toolbar = new Editor.Toolbar(this, options.toolbar);
  }

  this.connectShortcuts();

  this.initParagraph();

  var _this = this;
  this.editable.on('keyup mouseup', function() {
    _this.storeRange();
  });

  this.editable.on({
    keyup: function(event) {
      _this.keyup(event);
    },
    keydown: function(event) {
      _this.keydown(event);
    },
    input: function(event) {
      _this.input(event);
    },
    paste: function(event) {
      _this.paste(event);
    }
  });

  var is_chrome = navigator.userAgent.indexOf('Chrome') > -1;
  var is_safari = navigator.userAgent.indexOf("Safari") > -1;

  // In mac, chrome in safari trigger input event when typing pinyin,
  // so use textInput event.
  if (is_chrome || is_safari) {
    this.editable.on('textInput', function() {
      _this.undoManagerSave();
    });
  } else {
    this.editable.on('input', function() {
      _this.undoManagerSave();
    });
  }
};

Editor.prototype = {
  shortcuts: {
    'bold' : ['ctrl+b'],
    'italic' : ['ctrl+i'],
    'image' : ['ctrl+g'],
    'strikeThrough' : ['ctrl+d'],
    'underline' : ['ctrl+shift+l'],
    'link' : ['ctrl+l'],
    'unorderedList' : ['ctrl+u'],
    'orderedList' : ['ctrl+o'],
    'p' : ['ctrl+p'],
    'h1' : ['ctrl+1'],
    'h2' : ['ctrl+2'],
    'h3' : ['ctrl+3'],
    'h4' : ['ctrl+4'],
    'code' : ['ctrl+k'],
    'blockquote' : ['ctrl+q'],
    'undo' : ['ctrl+z'],
    'redo' : ['ctrl+y', 'ctrl+shift+z']
  },

  connectShortcuts: function() {
    var _this = this;
    $.each(this.shortcuts, function(method, key) {
      if (_this.formator[method]) {
        Mousetrap.bind(key, function(event) {
          event.preventDefault();
          if (!_this.hasRange()) {
            _this.restoreRange();
          }
          _this.formator[method]();
        });
      } else if (_this[method]) {
        Mousetrap.bind(key, function(event) {
          event.preventDefault();
          _this[method]();
        });
      }
    });
  },

  paste: function(event) {
    this.dirty = true;
  },

  input: function(event) {
    var _this = this;
    if (_this.dirty) {
      _this.sanitize.run();
      _this.dirty = false;
    }
  },

  selectContents: function(contents) {
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    var start = contents.first()[0];
    var end = contents.last()[0];
    range.setStart(start, 0);
    range.setEnd(end, end.childNodes.length || end.length); // text node don't have childNodes
    selection.removeAllRanges();
    selection.addRange(range);
  },

  keyup: function() {
    this.initParagraph();
    switch (event.keyCode) {
      case 8: // Backspace
      case 46: // Delete
        this.undoManager.save();
        break;
    }
  },

  keydown: function(event) {
    switch (event.keyCode) {
      case 8: // Backspace
        this.backspcae(event);
        break;
      case 13: // Enter
        this.enter(event);
        break;
    }
  },

  undoManagerSave: function() {
    var _this = this;
    setTimeout(function() {
      _this.undoManager.save();
    }, 0); // webkit don't get right range offset, so setTimout to fix
  },

  backspcae: function(event) {
    // Stop Backspace when empty, avoid cursor flash
    if (this.editable.html() === '<p><br></p>') {
      event.preventDefault();
    }
  },

  enter: function(event) {
    // If in pre code, insert \n

    if (document.queryCommandValue('formatBlock') === 'pre') {
      event.preventDefault();
      var selection = window.getSelection();
      var range = selection.getRangeAt(0);
      var rangeAncestor = range.commonAncestorContainer;
      var $pre = $(rangeAncestor).closest('pre');

      range.deleteContents();
      var isLastLine = ($pre.find('code').contents().last()[0] === range.endContainer);
      var isEnd = (range.endContainer.length === range.endOffset);
      var node = document.createTextNode("\n");
      range.insertNode(node);
      // keep two \n at the end, fix webkit eat \n issues.
      if (isLastLine && isEnd) {
        $pre.find('code').append(document.createTextNode("\n"));
      }
      range.setStartAfter(node);
      range.setEndAfter(node);
      selection.removeAllRanges();
      selection.addRange(range);
    }
  },

  undo: function() {
    this.undoManager.undo();
  },

  redo: function() {
    this.undoManager.redo();
  },

  initParagraph: function() {
    // chrome is empty and firefox is <br>
    if (this.editable.html() === '' || this.editable.html() === '<br>') {
      this.formator.p();
    }
  },

  storeRange: function() {
    var selection = document.getSelection();
    var range = selection.getRangeAt(0);
    this.storedRange = {
      startContainer: range.startContainer,
      startOffset: range.startOffset,
      endContainer: range.endContainer,
      endOffset: range.endOffset
    };
  },

  restoreRange: function() {
    var selection = document.getSelection();
    var range = selection.getRangeAt(0);
    range.setStart(this.storedRange.startContainer, this.storedRange.startOffset);
    range.setEnd(this.storedRange.endContainer, this.storedRange.endOffset);
    selection.removeAllRanges();
    selection.addRange(range);
  },

  hasRange: function() {
    var selection = document.getSelection();

    return selection.rangeCount && $(selection.getRangeAt(0).commonAncestorContainer).closest(this.editable_selector).length;
  }
};
