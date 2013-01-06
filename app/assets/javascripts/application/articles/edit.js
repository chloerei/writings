//= require editor

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

  $('#book-form .dropdown').on('click', '.dropdown-menu li a', this.selectBook);

  var _this = this;
  Mousetrap.bind('ctrl+s', function(event) {
    _this.saveArticle(event);
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
    $.ajax({
      url: '/articles/' + this.article.data('id'),
      data: data,
      type: 'put',
      dataType: 'json'
    }).success(success_callback).error(error_callback);
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
    var $li = $(this);
    $li.closest('.dropdown').find('.dropdown-toggle').text($li.text());
    $('#article-book-id').val($li.data('book-id'));
  },

  saveArticle: function(event) {
    event.preventDefault();
    if (this.isPersisted()) {
      this.updateArticle({
        article: {
          title: this.editor.editable.find('h1').text(),
          body: this.editor.editable.html()
        }
      });
    } else {
      this.createArticle();
    }
  },

  createArticle: function() {
    var _this = this;
    $.ajax({
      url: '/articles',
      data: {
        article: {
          title: this.editor.editable.find('h1').text(),
          body: this.editor.editable.html(),
          urlname: this.article.data('urlname'),
          book_id : this.article.data('book-id'),
          publish: this.article.data('publish')
        }
      },
      type: 'post',
      dataType: 'json'
    }).success(function(data) {
      _this.article.data('id', data.id);
      history.replaceState(null, null, '/articles/' + data.id + '/edit');
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
      if (isPersisted()) {
      this.updateArticle({
        article: {
          publish: true
        }
      }, null, function(data) {
        this.setPbulishClass(false);
        _this.article.data('publish', false);
      });
    } else {
      this.article.data('publish', true);
    }
  },

  draftArticle: function(event) {
    var _this = this;
    event.preventDefault();
    this.setPbulishClass(false);
    if (this.isPersisted()) {
      this.updateArticle({
        article: {
          publish: false
        }
      }, null, function(data) {
        _this.setPbulishClass(true);
        this.article.data('publish', true);
      });
    } else {
      this.article.data('publish', false);
    }
  }
};

page_ready(function() {
  if ($('body#articles-edit').length) {
    window.articleEdit = new ArticleEdit();
  }
});
