//= require editor

var ArticleEdit = function() {
  this.editor = new Editor({
    toolbar: '#toolbar',
    editable: '#editarea article'
  });

  this.article = $('#editarea article');

  $('#urlname-form').on('submit', this.saveUrlname);
  $('#save-button').on('click', this.saveArticle);
  $('#publish-button').on('click', this.publishArticle);
  $('#draft-button').on('click', this.draftArticle);

  $('#book-form .dropdown').on('click', '.dropdown-menu li a', function(event) {
    event.preventDefault();
    var $li = $(this);
    $li.closest('.dropdown').find('.dropdown-toggle').text($li.text());
    $('#article-book-id').val($li.data('book-id'));
  });
  $('#book-form').on('submit', this.saveBook);
  $('#new-book-form').on('submit', this.createBook);

  Mousetrap.bind('ctrl+s', this.saveArticle);
};

ArticleEdit.prototype = {
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
    if (isPersisted()) {
      updateArticle($('#urlname-form').serializeArray(), function(data) {
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
    if (isPersisted()) {
      updateArticle($('#book-form').serializeArray(), function(data) {
        this.article.data('book-id', bookId);
        $('#topbar .book-name').text(bookId ? bookName : '');
        Dialog.hide('#book-modal');
      });
    } else {
      this.article.data('book-id', bookId);
      $('#topbar .book-name').text(bookId ? bookName : '');
      Dialog.hide('#book-modal');
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

  saveArticle: function(event) {
    event.preventDefault();
    if (isPersisted()) {
      updateArticle({
        article: {
          title: this.editor.editable.find('h1').text(),
          body: this.editor.editable.html()
        }
      });
    } else {
      createArticle();
    }
  },

  createArticle: function() {
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
      this.article.data('id', data.id);
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
    setPbulishClass(true);
    event.preventDefault();
      if (isPersisted()) {
      updateArticle({
        article: {
          publish: true
        }
      }, null, function(data) {
        setPbulishClass(false);
        this.article.data('publish', false);
      });
    } else {
      this.article.data('publish', true);
    }
  },

  draftArticle: function(event) {
    event.preventDefault();
    setPbulishClass(false);
    if (isPersisted()) {
      updateArticle({
        article: {
          publish: false
        }
      }, null, function(data) {
        setPbulishClass(true);
        this.article.data('publish', true);
      });
    } else {
      this.article.data('publish', false);
    }
  }
};


page_ready(function() {
  if ($('body#articles-edit').length) {
    new ArticleEdit();
  }
});
