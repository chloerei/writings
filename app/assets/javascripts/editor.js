Mousetrap.stopCallback = function(e, element, combo) {
  // stop for input, select, and textarea
  return element.tagName == 'INPUT' || element.tagName == 'SELECT' || element.tagName == 'TEXTAREA';
};

var Editor = function() {
  this.toolbar = $('#toolbar');
  this.article = $('#editarea article');

  this.connectEvents();
  this.connectShortcuts();

  this.article.focus();
  this.initParagraph();
};

Editor.prototype = {
  events: {
    'click #save-button': 'saveArticle',
    'submit #urlname-modal form':  'saveUrlname',
    'click #draft-button': 'draft',
    'click #publish-button': 'publish',
    'keyup #editarea article': 'keyup',
    'keydown #editarea article': 'keydown',
    'mouseup #editarea article': 'detectState',
    'paste #editarea article': 'paste',
    'click #toolbar [data-command]': 'toolbarCommand'
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
    $.each(this.shortcuts, function(key, method) {
      Mousetrap.bind(key, function(event) {
        event.preventDefault();
        _this[method].call(_this);
      });
    });
  },

  toolbarCommand: function(event, element) {
    event.preventDefault();
    this[$(element).data('command')].call(this);
    this.detectButton();
    this.detectBlocks();
  },

  detectState: function() {
    this.detectButton();
    this.detectBlocks();
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

  paste: function(event) {
    this.dirty = true;
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
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    var start = $(range.startContainer).closest('article > *')[0];
    var end = $(range.endContainer).closest('article > *')[0];
    range.setStartBefore(start);
    range.setEndAfter(end);

    if (range.cloneContents().querySelector('blockquote')) {
      // remmove blockquote
      $(start).nextUntil(end.nextSibling).andSelf().each(function() {
        var node = $(this);
        if (node.prop('tagName') === 'BLOCKQUOTE') {
          if (this === start) {
            start = node.children()[0];
          }
          if (this === end) {
            end = node.children().last()[0];
          }
          node.replaceWith(node.children());
        }
      });
      range.setStart(start, 0);
      range.setEnd(end, end.childNodes.length);
      selection.removeAllRanges();
      selection.addRange(range);
    } else {
      // wrap blockquote
      var blockquote = document.createElement('blockquote');
      blockquote.appendChild(range.extractContents());
      range.insertNode(blockquote);
      selection.selectAllChildren(blockquote);
      $('<p><br></p>').insertAfter(blockquote);
    }
  },

  formatBlock: function(type) {
    this.exec('formatBlock', type);
  },

  exec: function(command, arg) {
    document.execCommand(command, false, arg);
  },

  keyup: function() {
    this.initParagraph();
    this.detectState();
    this.sanitize();
  },

  keydown: function(event) {
    this.stopEmptyBackspace(event);
  },

  initParagraph: function() {
    // chrome is empty and firefox is <br>
    if (this.article.html() === '' || this.article.html() === '<br>') {
      this.p();
    }

    // replace div to p
    if (document.queryCommandValue('formatBlock') === 'div') {
      this.p();
    }
  },

  tagWhiteList: ['p', 'br', 'img', 'a', 'b', 'i', 'strike', 'u', 'h1', 'h2', 'h3', 'h4', 'pre', 'code', 'ol', 'ul', 'li', 'blockquote'],

  attrWhiteList: {
    a: ['href', 'title'],
    img: ['src', 'title', 'alt']
  },

  sanitize: function() {
    var _this = this;
    if (this.dirty) {
      // replace div to p
      while(this.article.find('div').length) {
        this.convertDivToP();
      }

      // stript not allow tags
      while(this.article.find(':not(' + this.tagWhiteList.join() + ')').length) {
        this.striptNotAllowTags();
      }

      // flatten block element
      this.article.find('> :not(blockquote)').each(function() {
        _this.flattenBlock(this);
      });
      // blockquote as a document
      this.article.find('> blockquote').find('> :not(blockquote)').each(function() {
        _this.flattenBlock(this);
      });

      // remove all attribute not in attrWhiteList
      var tags = $.map(this.attrWhiteList, function(tag) { return tag; });
      this.article.find(':not(' + tags.join() + ')').each(function() {
        $element = $(this);
        $.each(this.attributes, function(i, attr) {
          if (attr) {
            $element.removeAttr(attr.name);
          }
        });
      });

      // remove attributes not in white list for attrWhiteList
      $.each(this.attrWhiteList, function(tag, attrList) {
        _this.article.find(tag).each(function() {
          $element = $(this);
          $.each(this.attributes, function(i, attr) {
            if (attr && ($.inArray(attr.name, attrList) == -1)) {
              $element.removeAttr(attr.name);
            }
          });
        });
      });
      this.dirty = false;
    }
  },

  convertDivToP: function() {
    this.article.find('div').each(function() {
      $(this).replaceWith($('<p></p>').html($(this).html()));
    });
  },

  striptNotAllowTags: function() {
    this.article.find(':not(' + this.tagWhiteList.join() + ')').each(function() {
      $(this).replaceWith($(this).html());
    });
  },

  blockElementSelector: '> p, > h1, > h2, > h3, > h4',

  flattenBlock: function(element) {
    var _this = this;
    var hasNoBlockContent = $(element).contents().filter(function() { return this.nodeType !== 1; }).length;
    if (hasNoBlockContent) {
      // stript block
      this.flattenBlockStript(element);
    } else {
      // split block

      // stript children
      $(element).find(this.blockElementSelector).each(function() {
        _this.flattenBlockStript.call(_this, this);
      });

      // replace with last child, and set other before
      // not use replaceWith() for avoid cursor lose.
      var last = $(element).find('> :last');
      var other = $(element).find('> :not(:last)');
      $(element).html(last.html()).before(other);
    }
  },

  flattenBlockStript: function(element) {
    while($(element).find(this.blockElementSelector).length) {
      this.flattenBlockStriptExecute.call(this, element);
    }
  },

  flattenBlockStriptExecute: function(element) {
    $(element).find(this.blockElementSelector).each(function() {
      $(this).replaceWith($(this).html());
    });
  },

  stopEmptyBackspace: function(event) {
    // Stop Backspace when empty, avoid cursor flash
    if (event.keyCode === 8) {
      if (this.article.html() === '<p><br></p>') {
        event.preventDefault();
      }
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
    return this.article.find('h1').text();
  },

  extractBody: function() {
    return this.article.html();
  }
};

var editor;
$(function() {
  editor = new Editor();
});
