//= require_self
//= require_tree ./editor
Mousetrap.stopCallback = function(e, element, combo) {
  // stop for input, select, and textarea
  return element.tagName == 'INPUT' || element.tagName == 'SELECT' || element.tagName == 'TEXTAREA';
};

var Editor = function(options) {
  this.editable = $(options.editable);

  this.sanitize = new Editor.Sanitize(this.editable);
  this.formator = new Editor.Formator(this);
  this.formator.exec('defaultParagraphSeparator', 'p');

  this.editable.focus();
  this.undoManager = new Editor.UndoManager(this.editable);

  if (options.toolbar) {
    this.toolbar = new Editor.Toolbar(this, options.toolbar);
  }

  this.connectEvents();
  this.connectShortcuts();

  this.initParagraph();
};

Editor.prototype = {
  events: {
    'keyup #editarea article': 'keyup',
    'keydown #editarea article': 'keydown',
    'input #editarea article': 'input',
    'paste #editarea article': 'paste'
  },

  connectEvents: function() {
    var _this = this;
    $.each(this.events, function(key, method) {
      var actions = key.split(' ');
      var event = actions.shift();
      var selector = actions.join(' ');
      $(selector).on(event, function(event) {
        _this[method].call(_this, event, this);
      });
    });
  },

  shortcuts: {
    'ctrl+b': 'bold',
    'ctrl+i': 'italic',
    'ctrl+d': 'strikeThrough',
    'ctrl+u': 'underline',
    'ctrl+l': 'link',
    'ctrl+shift+l': 'unorderedList',
    'ctrl+shift+o': 'orderedList',
    'ctrl+p': 'p',
    'ctrl+1': 'h1',
    'ctrl+2': 'h2',
    'ctrl+3': 'h3',
    'ctrl+4': 'h4',
    'ctrl+k': 'code',
    'ctrl+q': 'blockquote',
    'ctrl+z': 'undo',
    'ctrl+y': 'redo'
  },

  connectShortcuts: function() {
    var _this = this;
    $.each(this.shortcuts, function(key, method) {
      if (_this.formator[method]) {
        Mousetrap.bind(key, function(event) {
          event.preventDefault();
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

  input: function(event) {
    var _this = this;
    if (this.dirty) {
      this.sanitize.run();
      this.dirty = false;
    }
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
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    var rangeAncestor = range.commonAncestorContainer;

    var $pre = $(rangeAncestor).closest('pre');
    if ($pre.length) {
      event.preventDefault();
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

  extractTitle: function() {
    return this.editable.find('h1').text();
  },

  extractBody: function() {
    return this.editable.html();
  }
};
