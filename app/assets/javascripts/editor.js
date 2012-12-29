Mousetrap.stopCallback = function(e, element, combo) {
  // stop for input, select, and textarea
  return element.tagName == 'INPUT' || element.tagName == 'SELECT' || element.tagName == 'TEXTAREA';
};

var Editor = function(options) {
  this.toolbar = $(options.toolbar);
  this.editable = $(options.editable);

  this.connectEvents();
  this.connectShortcuts();

  this.editable.focus();
  this.initParagraph();

  this.exec('defaultParagraphSeparator', 'p');
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

  p: function() {
    this.formatBlock('p');
  },

  formatHeader: function(type) {
    if (document.queryCommandValue('formatBlock') === type) {
      this.p();
    } else {
      this.formatBlock(type);
    }
  },

  h1: function() {
    this.formatHeader('h1');
  },

  h2: function() {
    this.formatHeader('h2');
  },

  h3: function() {
    this.formatHeader('h3');
  },

  h4: function() {
    this.formatHeader('h4');
  },

  code: function() {
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    var rangeAncestor = range.commonAncestorContainer;
    var start, end, $contents;

    var $code = $(rangeAncestor).closest('code');

    if ($code.length) {
      // remove code
      if ($code.closest('pre').length) {
        // pre code
        this.splitCode($code);
        $contents = $code.contents();
        if ($contents.length === 0) {
          $contents = $('<p><br></p>');
        }
        $code.closest('pre').replaceWith($contents);
        this.selectContents($contents);
      } else {
        // inline code
        $contents = $code.contents();
        $code.replaceWith($code.contents());
        this.selectContents($contents);
      }
    } else {
      // wrap code
      var isEmptyRange = (range.toString() === '');
      var isWholeBlock = (range.toString() === $(range.startContainer).closest('p, h1, h2, h3, h4').text());
      var hasBlock = (range.cloneContents().querySelector('p, h1, h2, h3, h4'));
      if (isEmptyRange || isWholeBlock || hasBlock) {
        // pre code
        start = $(range.startContainer).closest('blockquote > *, article > *')[0];
        end = $(range.endContainer).closest('blockquote > *, article > *')[0];
        range.setStartBefore(start);
        range.setEndAfter(end);
        $code = $('<code>').html(range.extractContents());
        $pre = $('<pre>').html($code);
        range.insertNode($pre[0]);
        if ($pre.next().length === 0) {
          $pre.after('<p><br></p>');
        }
      } else {
        // inline code
        $code = $('<code>').html(range.extractContents());
        range.insertNode($code[0]);
      }
      this.striptCode($code);
      selection.selectAllChildren($code[0]);
    }
  },

  striptCode: function(code) {
    while ($(code).find('p, h1, h2, h3, h4, blockquote, pre').length) {
      this.striptCodeBlock(code);
    }
    while ($(code).children().length) {
      this.striptCodeInline(code);
    }
  },

  striptCodeBlock: function(code) {
    $(code).find('p, h1, h2, h3, h4, blockquote, pre').each(function() {
      $(this).replaceWith($(this).text() + "\n");
    });
  },

  striptCodeInline: function(code) {
    $(code).children().each(function() {
      $(this).replaceWith($(this).text());
    });
  },

  splitCode: function(code) {
    code.html($.map(code.text().split("\n"), function(line) {
      if (line !== '') {
        return $('<p>').text(line);
      }
    }));
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

  blockquote: function() {
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    var rangeAncestor = range.commonAncestorContainer;
    var start, end;

    var $blockquote = $(rangeAncestor).closest('blockquote');
    if ($blockquote.length) {
      // remmove blockquote
      var $contents = $blockquote.contents();
      $blockquote.replaceWith($contents);
      this.selectContents($contents);
    } else {
      // wrap blockquote
      start = $(range.startContainer).closest('article > *')[0];
      end = $(range.endContainer).closest('article > *')[0];
      range.setStartBefore(start);
      range.setEndAfter(end);
      $blockquote = $('<blockquote>');
      $blockquote.html(range.extractContents()).find('blockquote').each(function() {
        $(this).replaceWith($(this).html());
      });
      range.insertNode($blockquote[0]);
      selection.selectAllChildren($blockquote[0]);
      if ($blockquote.next().length === 0) {
        $blockquote.after('<p><br></p>');
      }
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
    if (this.dirty) {
      this.sanitize();
      this.dirty = false;
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

  initParagraph: function() {
    // chrome is empty and firefox is <br>
    if (this.editable.html() === '' || this.editable.html() === '<br>') {
      this.p();
    }
  },

  tagWhiteList: ['p', 'br', 'img', 'a', 'b', 'i', 'strike', 'u', 'h1', 'h2', 'h3', 'h4', 'pre', 'code', 'ol', 'ul', 'li', 'blockquote'],

  attrWhiteList: {
    a: ['href', 'title'],
    img: ['src', 'title', 'alt']
  },

  sanitize: function() {
    this.sanitizeDiv();
    this.sanitizeTag();
    this.sanitizeAttr();
    this.sanitizeBlockElement();
    this.sanitizeCode();
    this.sanitizeList();
  },

  sanitizeDiv: function() {
    // replace div to p
    while(this.editable.find('div').length) {
      this.convertDivToP();
    }
  },

  sanitizeTag: function() {
    // stript not allow tags
    while(this.editable.find(':not(' + this.tagWhiteList.join() + ')').length) {
      this.striptNotAllowTags();
    }
  },

  sanitizeAttr: function() {
    var _this = this;
    // remove all attribute not in attrWhiteList
    var tags = $.map(this.attrWhiteList, function(attrs, tag) { return tag; });
    this.editable.find(':not(' + tags.join() + ')').each(function() {
      $element = $(this);
      $.each(this.attributes, function(i, attr) {
        if (attr) {
          $element.removeAttr(attr.name);
        }
      });
    });

    // remove attributes not in white list for attrWhiteList
    $.each(this.attrWhiteList, function(tag, attrList) {
      _this.editable.find(tag).each(function() {
        $element = $(this);
        $.each(this.attributes, function(i, attr) {
          if (attr && ($.inArray(attr.name, attrList) == -1)) {
            $element.removeAttr(attr.name);
          }
        });
      });
    });
  },

  convertDivToP: function() {
    this.editable.find('div').each(function() {
      $(this).replaceWith($('<p>').html($(this).html()));
    });
  },

  striptNotAllowTags: function() {
    this.editable.find(':not(' + this.tagWhiteList.join() + ')').each(function() {
      $(this).replaceWith($(this).html());
    });
  },

  sanitizeBlockElement: function () {
    var _this = this;
    // flatten nested block element
    this.editable.find(this.blockElementSelector).each(function() {
      _this.flattenBlock(this);
    });
    // blockquote as a document
    this.editable.find('> blockquote').find(this.blockElementSelector).each(function() {
      _this.flattenBlock(this);
    });
  },

  blockElementSelector: '> p, > h1, > h2, > h3, > h4',

  flattenBlock: function(element) {
    var _this = this;
    var hasTextNode = $(element).contents().filter(function() { return this.nodeType !== 1; }).length;
    var hasBr = $(element).find('> br').length;
    if (hasTextNode || hasBr) {
      // stript block
      this.flattenBlockStript(element);
    } else {
      // split block

      // stript children
      $(element).find(this.blockElementSelector).each(function() {
        _this.flattenBlockStript.call(_this, this);
      });

      // don't replaceWith() for avoid cursor lose.
      $(element).replaceWith($(element).html());
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

  sanitizeCode: function() {
    var _this = this;
    this.editable.find('code').each(function() {
      _this.striptCode(this);
    });
  },

  sanitizeList: function() {
    var _this = this;
    this.editable.find('li').each(function() {
      var $li = $(this);
      // stript p
      while ($li.find('p').length) {
        _this.sanitizeListP(this);
      }

      // stript other element
      while ($li.find(':not(a, img, br)').length) {
        _this.sanitizeListOther(this);
      }
    });
  },

  sanitizeListP: function(li) {
    $(li).find('p').each(function() {
      $(this).append('<br>').replaceWith($(this).contents());
    });
  },

  sanitizeListOther: function(li) {
    $(li).find(':not(a, img, br)').each(function() {
      $(this).replaceWith($(this).contents());
    });
  },

  articleId: function() {
    return this.editable.data('article-id');
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
    return this.editable.find('h1').text();
  },

  extractBody: function() {
    return this.editable.html();
  }
};

$(function() {
  if ($('#editor-page').length) {
    window.editor = new Editor({
      toolbar: '#editarea .toolbar',
      editable: '#editarea article'
    });
  }
});
