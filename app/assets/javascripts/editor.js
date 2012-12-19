Mousetrap.stopCallback = function(e, element, combo) {
  // stop for input, select, and textarea
  return element.tagName == 'INPUT' || element.tagName == 'SELECT' || element.tagName == 'TEXTAREA';
};

var Editor = function() {
  this.toolbar = $('#toolbar');
  this.editarea = $('#editarea');
  this.article = $('#editarea article');
  this.connectActions();
  this.connectShortcuts();
  this.connectDetectState();

  var _this = this;
  $('#save-button').click(function(event) {
    event.preventDefault();
    _this.saveArticle.call(_this);
  });

  $('#urlname-modal form').submit(function(event) {
    event.preventDefault();
    _this.saveUrlname.call(_this);
  });

  $('#draft-button').click(function(event) {
    event.preventDefault();
    _this.draft.call(_this);
  });

  $('#publish-button').click(function(event) {
    event.preventDefault();
    _this.publish.call(_this);
  });
};

Editor.prototype = {
  actions: {
    'bold': 'bold',
    'italic': 'italic',
    'strikethrough': 'strikeThrough',
    'underline': 'underline',
    'link': 'createLink',
    'list-ol': 'insertOrderedList',
    'list-ul': 'insertUnorderedList'
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

  connectDetectState: function() {
    var _this = this;

    _this.editarea.on('keyup mouseup', function() {
      _this.detectActions();
      _this.detectBlocks();
    });
  },

  detectActions: function() {
    var _this = this;

    $.each(_this.actions, function(action, command) {
      if (document.queryCommandValue(command) !== 'true') {
        _this.toolbar.find('a[data-action=' + action + ']').removeClass('actived');
      } else {
        if (command === 'bold' && /^h/.test(document.queryCommandValue('formatBlock'))) {
          _this.toolbar.find('a[data-action=' + action + ']').removeClass('actived');
        } else {
          _this.toolbar.find('a[data-action=' + action + ']').addClass('actived');
        }
      }
    });
  },

  detectBlocks: function() {
    var _this = this;

    _this.toolbar.find('select').val(document.queryCommandValue('formatBlock'));
  },

  shortcuts: {
    'ctrl+b': 'bold',
    'ctrl+i': 'italic',
    'ctrl+d': 'strikeThrough',
    'ctrl+u': 'underline',
    'ctrl+l': 'createLink',
    'ctrl+shift+l': 'insertUnorderedList',
    'ctrl+shift+o': 'insertOrderedList',
    'ctrl+s': 'saveArticle'
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
  },

  articleId: function() {
    return this.article.data('article-id');
  },

  saveArticle: function() {
    this.update({
      article: {
        title: this.extractTitle(),
        body: this.extractBody()
      }
    });
  },

  saveUrlname: function() {
    this.update($('#urlname-modal form').serializeArray(), function(data) {
      $('#topbar .urlname').text(data.urlname);
      Dialog.hide('#urlname-modal');
    });
  },

  publish: function() {
    this.update({
      article: {
        publish: true
      }
    }, function(data) {
      $('#draft-button').removeClass('button-actived');
      $('#publish-button').addClass('button-actived');
    });
  },

  draft: function() {
    this.update({
      article: {
        publish: false
      }
    }, function(data) {
      $('#publish-button').removeClass('button-actived');
      $('#draft-button').addClass('button-actived');
    });
  },

  update: function(data, success_callback, error_callback) {
    $.ajax({
      url: '/articles/' + this.articleId(),
      data: data,
      type: 'put',
      dataType: 'json'
    }).success(success_callback).error(error_callback);
  },

  extractTitle: function() {
    return this.article.find('h1:first-child').text();
  },

  extractBody: function() {
    return this.article.html();
  }
};

var editor;
$(function() {
  editor = new Editor();
});
