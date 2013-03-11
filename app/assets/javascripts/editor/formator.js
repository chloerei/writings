Editor.Formator = function(editor) {
  this.editor = editor;
  this.editable = editor.editable;
};

Editor.Formator.prototype = {
  isBold: function() {
    return this.canBold() &&
      (document.queryCommandValue('bold') === 'true' ||
       document.queryCommandState('bold'));
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
    return this.canItalic() &&
      (document.queryCommandValue('italic') === 'true' ||
       document.queryCommandState('italic'));
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
    return this.canStrikeThrough() &&
      (document.queryCommandValue('strikeThrough') === 'true' ||
       document.queryCommandState('strikeThrough'));
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
    return this.canUnorderedList() &&
      (document.queryCommandValue('underline') === 'true' ||
       document.queryCommandState('underline'));
  },

  canUnderline: function() {
    return !this.isWraped('code, a');
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
    if (this.canOrderedList()) {
      if (this.isOrderedList()) {
        this.exec('insertOrderedList');
        this.p();
      } else {
        this.exec('insertOrderedList');
        if ($(this.commonAncestorContainer()).closest('p').length) {
          this.editor.storeRange();
          $(this.commonAncestorContainer()).closest('ol').unwrap('p');
          this.editor.restoreRange();
        }
      }
    }
  },

  isUnorderedList: function() {
    return this.canUnorderedList() && document.queryCommandValue('insertUnorderedList') === 'true';
  },

  canUnorderedList: function() {
    return !this.isWraped('h1, h2, h3, h4, code');
  },

  unorderedList: function() {
    if (this.canUnorderedList()) {
      if (this.isUnorderedList()) {
        this.exec('insertUnorderedList');
        this.p();
      } else {
        this.exec('insertUnorderedList');
        if ($(this.commonAncestorContainer()).closest('p').length) {
          this.editor.storeRange();
          $(this.commonAncestorContainer()).closest('ul').unwrap('p');
          this.editor.restoreRange();
        }
      }
    }
  },

  isLink: function() {
    return this.canLink() && this.isWraped('a');
  },

  canLink: function() {
    return !this.isWraped('code');
  },

  link: function() {
    var url = prompt('Link url:', 'http://');

    if (url && url !== '') {
      this.exec('createLink', url);
    } else {
      this.exec('unlink');
    }
  },

  image: function() {
    var url = prompt('Link url:', 'http://');

    this.exec('insertImage', url);
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
      $(this.commonAncestorContainer()).closest(type).find(':not(i, strike, u, a, br)').each(function() {
        $(this).replaceWith($(this).contents());
      });
    }
  },

  isCode: function() {
    return this.isWraped('code');
  },

  canCode: function() {
    return true;
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
        this.editor.selectContents($contents);
      } else {
        // inline code
        $contents = $code.contents();
        $code.replaceWith($code.contents());
        this.editor.selectContents($contents);
      }
    } else {
      // wrap code
      var isEmptyRange = (range.toString() === '');
      var isWholeBlock = (range.toString() === $(range.startContainer).closest('p, h1, h2, h3, h4').text());
      var hasBlock = (range.cloneContents().querySelector('p, h1, h2, h3, h4'));
      if (isEmptyRange || isWholeBlock || hasBlock) {
        // pre code
        start = $(range.startContainer).closest('p, h1, h2, h3, h4')[0];
        end = $(range.endContainer).closest('p, h1, h2, h3, h4')[0];
        range.setStartBefore(start);
        range.setEndAfter(end);
        $code = $('<code>').html(range.extractContents());
        var $pre = $('<pre>').html($code);
        range.insertNode($pre[0]);
        if ($pre.next().length === 0) {
          $pre.after('<p><br></p>');
        }
      } else {
        // inline code
        $code = $('<code>').html(range.extractContents());
        range.insertNode($code[0]);
      }
      this.editor.sanitize.striptCode($code);
      selection.selectAllChildren($code[0]);
    }
  },

  splitCode: function(code) {
    code.html($.map(code.text().split("\n"), function(line) {
      if (line !== '') {
        return $('<p>').text(line);
      }
    }));
  },

  isBlockquote: function() {
    return this.isWraped('blockquote');
  },

  canBlockquote: function() {
    return true;
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
      this.editor.selectContents($contents);
    } else {
      // wrap blockquote
      start = $(range.startContainer).closest('p, h1, h2, h3, h4, pre')[0];
      end = $(range.endContainer).closest('p, h1, h2, h3, h4, pre')[0];
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
    this.editable.trigger('editor:change');
  }
};
