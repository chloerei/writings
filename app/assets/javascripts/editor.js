var Editor = function() {
  this.toolbar = $('#toolbar');
  this.delegateEvents(this.events);
}

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

  delegateEvents: function(events) {
    var _this = this;

    _this.toolbar.on('click', '[data-action]', function(event) {
      event.preventDefault();
      var action = _this.actions[$(this).data('action')];
      if (_this[action]) {
        _this[action].call(_this);
      }
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
    var url = prompt("Link url:", "http://");
    if (url != null && url != "") {
      this.exec('createLink', url);
    };
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

  exec: function(command, arg) {
    document.execCommand(command, false, arg);
  }
}

var editor;
$(function() {
  editor = new Editor();
});
