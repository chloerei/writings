Editor.Sanitize = function(editable) {
  this.editable = $(editable);
};

Editor.Sanitize.prototype = {
  run: function() {
    this.sanitizeDiv();
    this.sanitizeTag();
    this.sanitizeAttr();
    this.sanitizeBr();
    this.sanitizeBlockElement();
    this.sanitizeCode();
    this.sanitizeList();
  },

  tagWhiteList: ['p', 'br', 'img', 'a', 'b', 'i', 'strike', 'u', 'h1', 'h2', 'h3', 'h4', 'pre', 'code', 'ol', 'ul', 'li', 'blockquote'],

  attrWhiteList: {
    a: ['href', 'title'],
    img: ['src', 'title', 'alt']
  },

  sanitizeDiv: function() {
    // replace div to p
    this.editable.find('div').each(function() {
      $(this).replaceWith($('<p>').append($(this).contents()));
    });
  },

  sanitizeTag: function() {
    // stript not allow tags
    this.editable.find(':not(' + this.tagWhiteList.join() + ')').each(function() {
      $(this).replaceWith($(this).contents());
    });
  },

  sanitizeAttr: function() {
    var _this = this;
    // remove all attribute not in attrWhiteList
    var tags = $.map(this.attrWhiteList, function(attrs, tag) { return tag; });
    this.editable.find(':not(' + tags.join() + ')').each(function() {
      var $element = $(this);
      var attributes = $.map(this.attributes, function(item) {
        return item.name;
      });
      $.each(attributes, function(i, name) {
        $element.removeAttr(name);
      });
    });

    // remove attributes not in white list for attrWhiteList
    $.each(this.attrWhiteList, function(tag, attrList) {
      _this.editable.find(tag).each(function() {
        var $element = $(this);
        var attributes = $.map(this.attributes, function(item) {
          return item.name;
        });
        $.each(attributes, function(i, name) {
          if ($.inArray(name, attrList) == -1) {
            $element.removeAttr(name);
          }
        });
      });
    });
  },

  sanitizeBr: function() {
    this.editable.find('> br').each(function() {
      $(this).wrap('<p>');
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
    var hasInline = $(element).find('> :not(p, h1, h2, h3, h4, ul, ol, li)').length;
    if (hasTextNode || hasInline) {
      // stript block
      this.flattenBlockStript(element);
    } else {
      // split block

      // stript children
      $(element).children().each(function() {
        _this.flattenBlockStript(this);
      });

      $(element).replaceWith($(element).contents());
    }
  },

  flattenBlockStript: function(element) {
    if ($(element).is(':not(ul)')) {
      $(element).find(':not(code, a, img, b, strike, i, br)').each(function() {
        $(this).replaceWith($(this).contents());
      });
    }
  },

  sanitizeCode: function() {
    var _this = this;
    this.editable.find('pre').each(function() {
      if ($(this).find('> code').length === 0) {
        $(this).append($('<code>').append($(this).contents()));
      }
    });
    this.editable.find('code').each(function() {
      _this.striptCode(this);
    });
  },

  striptCode: function(code) {
    $(code).find('p, h1, h2, h3, h4, blockquote, pre').each(function() {
      $(this).replaceWith($(this).text() + "\n");
    });
    $(code).children().each(function() {
      $(this).replaceWith($(this).text());
    });
  },

  sanitizeList: function() {
    var _this = this;
    this.editable.find('li').each(function() {
      var $li = $(this);
      // stript p
      $li.find(':not(code, a, img, b, strike, i, br)').each(function() {
        if ($(this).next().length) {
          $(this).append('<br>');
        }
        $(this).replaceWith($(this).contents());
      });
    });
  }
};
