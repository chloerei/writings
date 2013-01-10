//= require editor

Editor.Formator.prototype.link = function(url) {
  this.editor.restoreRange();

  if (url !== undefined) {
    if (this.isWraped('a')) {
      document.getSelection().selectAllChildren($(this.commonAncestorContainer()).closest('a')[0]);
    }
    if (url !== '') {
      if (!/^http/.test(url)) {
        url = 'http://' + url;
      }
      this.exec('createLink', url);
    } else {
      this.exec('unlink');
    }
    Dialog.hide('#link-modal');
  } else {
    var link = 'http://';
    if (this.isWraped('a')) {
      link = $(this.commonAncestorContainer()).closest('a').attr('href');
    }
    Dialog.show('#link-modal');
    $('#link-modal').find('input[name=url]').val(link).focus();
  }
};

Editor.Formator.prototype.image = function(url) {
  this.editor.restoreRange();

  if (url !== undefined) {
    if (!/^http/.test(url)) {
      url = 'http://' + url;
    }
    this.exec('insertImage', url);
    Dialog.hide('#image-modal');
  } else {
    Dialog.show('#image-modal');
    $('#image-modal').find('input[name=url]').val('http://').focus();
  }
};

var ArticleEdit = function() {
  this.editor = new Editor({
    toolbar: '#toolbar',
    editable: '#editarea article'
  });

  this.article = $('#editarea article');

  this.connect('#urlname-form', 'submit', this.saveUrlname);
  this.connect('#save-button', 'click', this.saveArticle);
  this.connect('#publish-button', 'click', this.publishArticle);
  this.connect('#draft-button', 'click', this.draftArticle);
  this.connect('#book-form', 'submit', this.saveBook);
  this.connect('#new-book-form', 'submit', this.createBook);
  this.connect('#pick-up-button', 'click', this.pickUpTopbar);

  $('#book-form .dropdown').on('click', '.dropdown-menu li a', this.selectBook);

  var _this = this;

  $('#link-form').on('submit', function(event) {
    event.preventDefault();
    _this.editor.formator.link($(this).find('input[name=url]').val());
  });

  $('#unlink-button').on('click', function(event) {
    event.preventDefault();
    _this.editor.formator.link('');
  });

  $('#image-form').on('submit', function(event) {
    event.preventDefault();
    _this.editor.formator.image($(this).find('input[name=url]').val());
  });

  Mousetrap.bind('ctrl+s', function(event) {
    _this.saveArticle(event);
  });
  Mousetrap.bind('alt+p', function(event) {
    _this.pickUpTopbar();
  });
};

ArticleEdit.prototype = {
  connect: function(element, event, fn) {
    var _this = this;
    $(element).on(event, function(event) {
      fn.call(_this, event, this);
    });
  },

  isPersisted: function() {
    return !!this.article.data('id');
  },

  updateArticle: function(data, success_callback, error_callback) {
    AlertMessage.loading('Saving...');
    $.ajax({
      url: '/articles/' + this.article.data('id'),
      data: data,
      type: 'put',
      dataType: 'json'
    }).success(function() {
      AlertMessage.clear();
      if (success_callback) {
        success_callback();
      }
    }).error(function() {
      AlertMessage.error('Save Failed.');
      if (error_callback) {
        error_callback();
      }
    });
  },

  saveUrlname: function(event) {
    event.preventDefault();
    var urlname = $('#article-urlname').val();
    if (this.isPersisted()) {
      this.updateArticle($('#urlname-form').serializeArray(), function(data) {
        $('#topbar .urlname').text(data.urlname);
        Dialog.hide('#urlname-modal');
      });
    } else {
      this.article.data('urlname', urlname);
      $('#topbar .urlname').text(urlname);
      Dialog.hide('#urlname-modal');
    }
  },

  saveBook: function(event) {
    event.preventDefault();
    var bookId = $('#article-book-id').val();
    var bookName = $('#book-form .dropdown-toggle').text();
    var _this = this;
    if (this.isPersisted()) {
      this.updateArticle($('#book-form').serializeArray(), function(data) {
        _this.article.data('book-id', bookId);
        $('#topbar .book-name').text(bookId ? bookName : '');
        Dialog.hide('#select-book-modal');
      });
    } else {
      this.article.data('book-id', bookId);
      $('#topbar .book-name').text(bookId ? bookName : '');
      Dialog.hide('#select-book-modal');
    }
  },

  createBook: function(event) {
    event.preventDefault();
    $.ajax({
      url: '/books/',
      data: $('#new-book-form').serializeArray(),
      type: 'post',
      dataType: 'json'
    }).success(function(data) {
      var $li = $('<li><a href="#">');
      $li.find('a').text(data.name).data('book-id', data.urlname);
      $('#book-form .dropdown-menu').prepend($li);
      $('#book-form .dropdown-toggle').text(data.name);
      $('#article-book-id').val(data.urlname);
      Dialog.hide('#new-book-modal');
    });
  },

  selectBook: function(event) {
    event.preventDefault();
    var $item = $(this);
    $item.closest('.dropdown').find('.dropdown-toggle').text($item.text());
    $('#article-book-id').val($item.data('book-id'));
  },

  saveArticle: function(event) {
    event.preventDefault();
    if (this.isPersisted()) {
      this.updateArticle({
        article: {
          title: this.extractTitle(),
          body: this.editor.editable.html()
        }
      });
    } else {
      this.createArticle();
    }

    document.title = this.extractTitle() || 'Untitle';
  },

  extractTitle: function() {
    return this.editor.editable.find('h1').text();
  },

  createArticle: function() {
    var _this = this;
    AlertMessage.loading('Saving...');
    $.ajax({
      url: '/articles',
      data: {
        article: {
          title: this.editor.editable.find('h1').text(),
          body: this.editor.editable.html(),
          urlname: this.article.data('urlname'),
          book_id : this.article.data('book-id'),
          status: this.article.data('status')
        }
      },
      type: 'post',
      dataType: 'json'
    }).success(function(data) {
      AlertMessage.clear();
      _this.article.data('id', data.id);
      history.replaceState(null, null, '/articles/' + data.id + '/edit');
    }).error(function() {
      AlertMessage.error('Save Failed.');
    });
  },

  setPbulishClass: function(isPublish) {
    if (isPublish) {
      $('#draft-button').removeClass('button-actived');
      $('#publish-button').addClass('button-actived');
    } else {
      $('#publish-button').removeClass('button-actived');
      $('#draft-button').addClass('button-actived');
    }
  },

  publishArticle: function(event) {
    var _this = this;
    this.setPbulishClass(true);
    event.preventDefault();
      if (this.isPersisted()) {
      this.updateArticle({
        article: {
          status: 'publish'
        }
      }, null, function(data) {
        this.setPbulishClass(false);
        _this.article.data('status', 'draft');
      });
    } else {
      this.article.data('status', 'publish');
    }
  },

  draftArticle: function(event) {
    var _this = this;
    event.preventDefault();
    this.setPbulishClass(false);
    if (this.isPersisted()) {
      this.updateArticle({
        article: {
          status: 'draft'
        }
      }, null, function(data) {
        _this.setPbulishClass(true);
        this.article.data('status', 'publish');
      });
    } else {
      this.article.data('status', 'draft');
    }
  },

  pickUpTopbar: function() {
    $('body').toggleClass('pick-up-topbar');
    if ($('body').hasClass('pick-up-topbar')) {
      $.cookie('pick_up_topbar', true, { path: '/articles', expires: 14 });
    } else {
      $.removeCookie('pick_up_topbar',  { path: '/articles' });
    }
  }
};

page_ready(function() {
  if ($('body#articles-edit').length) {
    window.articleEdit = new ArticleEdit();
  }
});
