Mousetrap.stopCallback = function(e, element, combo) {
  // stop for input, select, and textarea
  return element.tagName == 'INPUT' || element.tagName == 'SELECT' || element.tagName == 'TEXTAREA';
};

var Editor = function() {
  this.toolbar = $('#toolbar');
  this.editarea = $('#editarea');
  this.article = $('#editarea article');

  this.connectToolbar();
  this.connectShortcuts();
  this.connectDetectState();

  this.connect('#save-button', 'click', 'saveArticle');
  this.connect('#urlname-modal form', 'submit', 'saveUrlname');
  this.connect('#draft-button', 'click', 'draft');
  this.connect('#publish-button', 'click', 'publish');

  this.clearFormat();
  var _this = this;
  this.article.on('keyup', function() {
    _this.clearFormat();
  });
};

Editor.prototype = {
  connect: function(id, type, method) {
    var _this = this;
    $(id).on(type, function(event) {
      event.preventDefault();
      _this[method].call(_this);
    });
  },

  connectToolbar: function(events) {
    var _this = this;

    _this.toolbar.on('click', '[data-command]', function(event) {
      event.preventDefault();
      _this[$(this).data('command')].call(_this);
      _this.detectButton();
      _this.detectBlocks();
    });
  },

  connectDetectState: function() {
    var _this = this;

    _this.article.on('keyup mouseup', function() {
      _this.detectButton();
      _this.detectBlocks();
    });
  },

  detectButton: function() {
    var _this = this;

    _this.toolbar.find('[data-command]').each(function(index, element) {
      var command = $(element).data('command');
      if (document.queryCommandValue(command) !== 'true') {
        $(element).removeClass('actived');
      } else {
        if (command === 'bold' && /^h/.test(document.queryCommandValue('formatBlock'))) {
          $(element).removeClass('actived');
        } else {
          $(element).addClass('actived');
        }
      }
    });
  },

  detectBlocks: function() {
    var type = document.queryCommandValue('formatBlock');
    var text = this.toolbar.find('#format-block [data-command=' + type + ']').text();
    if (text === '') {
      text = this.toolbar.find('#format-block [data-command]:first').text();
    }
    this.toolbar.find('#format-block .toolbar-botton').text(text);
  },

  shortcuts: {
    'ctrl+b': 'bold',
    'ctrl+i': 'italic',
    'ctrl+d': 'strikeThrough',
    'ctrl+u': 'underline',
    'ctrl+l': 'createLink',
    'ctrl+shift+l': 'insertUnorderedList',
    'ctrl+shift+o': 'insertOrderedList',
    'ctrl+p': 'p',
    'ctrl+1': 'h1',
    'ctrl+2': 'h2',
    'ctrl+3': 'h3',
    'ctrl+4': 'h4',
    'ctrl+k': 'code',
    'ctrl+q': 'blockquote',
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

  p: function() {
    this.formatBlock('p');
  },

  h1: function() {
    this.formatBlock('h1');
  },

  h2: function() {
    this.formatBlock('h2');
  },

  h3: function() {
    this.formatBlock('h3');
  },

  h4: function() {
    this.formatBlock('h4');
  },

  code: function() {
    this.formatBlock('code');
  },

  blockquote: function() {
    this.formatBlock('blockquote');
  },

  formatBlock: function(type) {
    this.exec('formatBlock', type);
  },

  exec: function(command, arg) {
    document.execCommand(command, false, arg);
  },

  clearFormat: function() {
    var block = document.queryCommandValue('formatBlock');
    if (block === '' || block === 'div') {
      this.p();
    }
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
