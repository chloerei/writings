Editor.Sanitize = function(editable) {
  this.editable = $(editable);
};

Editor.Sanitize.prototype = {
  run: function() {
    this.sanitizeDiv();
    this.sanitizeTag();
    this.sanitizeAttr();
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

  convertDivToP: function() {
    this.editable.find('div').each(function() {
      $(this).replaceWith($('<p>').append($(this).contents()));
    });
  },

  striptNotAllowTags: function() {
    this.editable.find(':not(' + this.tagWhiteList.join() + ')').each(function() {
      $(this).replaceWith($(this).contents());
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

      $(element).replaceWith($(element).contents());
    }
  },

  flattenBlockStript: function(element) {
    while($(element).find(this.blockElementSelector).length) {
      this.flattenBlockStriptExecute.call(this, element);
    }
  },

  flattenBlockStriptExecute: function(element) {
    $(element).find(this.blockElementSelector).each(function() {
      $(this).replaceWith($(this).contents());
    });
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
  }
};
