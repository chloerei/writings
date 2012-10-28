Mousetrap.stopCallback = function(e, element, combo) {
  // stop for input, select, and textarea
  return element.tagName == 'INPUT' || element.tagName == 'SELECT' || element.tagName == 'TEXTAREA';
};

var Editor = function() {
  this.toolbar = $('#toolbar');
  this.connectActions();
  this.connectShortcuts();
};

Editor.prototype = {
  actions: {
    'bold': 'bold',
    'italic': 'italic',
    'strikethrough': 'strikeThrough',
    'underline': 'underline',
    'link': 'createLink',
    'list-ol': 'insertOrderedList',
    'list-ul': 'insertUnorderedList',
    'align-left': 'justifyLeft',
    'align-center': 'justifyCenter',
    'align-right': 'justifyRight',
    'align-justify': 'justifyFull'
  },

  connectActions: function(events) {
    var _this = this;

    _this.toolbar.on('click', 'a[data-action]', function(event) {
      event.preventDefault();
      var action = _this.actions[$(this).data('action')];
      if (_this[action]) {
        _this[action].call(_this);
      }
    });

    _this.toolbar.on('change', '[data-action=formatBlock]', function(event) {
      _this.formatBlock.call(_this, $(this).val());
    });
  },

  shortcuts: {
    'ctrl+b': 'bold',
    'ctrl+i': 'italic',
    'ctrl+d': 'strikeThrough',
    'ctrl+u': 'underline',
    'ctrl+l': 'createLink',
    'ctrl+shift+l': 'insertUnorderedList',
    'ctrl+shift+o': 'insertOrderedList',
    'ctrl+left': 'justifyLeft',
    'ctrl+right': 'justifyRight'
  },

  connectShortcuts: function() {
    var _this = this;
    $.each(this.shortcuts, function(key, action) {
      Mousetrap.bind(key, function(event) {
        event.preventDefault();
        _this[action].call(_this);
      });
    });
  },

  bold: function() {
    this.exec('bold');
  },

  italic: function() {
    this.exec('italic');
  },

  strikeThrough: function() {
    this.exec('strikeThrough');
  },

  underline: function() {
    this.exec('underline');
  },

  insertOrderedList: function() {
    this.exec('insertOrderedList');
  },

  insertUnorderedList: function() {
    this.exec('insertUnorderedList');
  },

  createLink: function() {
    var url = prompt('Link url:', 'http://');
    if (url !== null && url !== '') {
      this.exec('createLink', url);
    }
  },

  justifyLeft: function() {
    this.exec('justifyLeft');
  },

  justifyRight: function() {
    this.exec('justifyRight');
  },

  justifyCenter: function() {
    this.exec('justifyCenter');
  },

  justifyFull: function() {
    this.exec('justifyFull');
  },

  formatBlock: function(type) {
    this.exec('formatBlock', type);
  },

  exec: function(command, arg) {
    document.execCommand(command, false, arg);
  }
};

var editor;
$(function() {
  editor = new Editor();
});
