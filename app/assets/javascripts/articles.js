//= require editor

$(function() {
  if ($('body#article-edit').length) {
    window.editor = new Editor({
      toolbar: '#toolbar',
      editable: '#editarea article'
    });

    var article = $('#editarea article');

    var isPersisted = function() {
      return !!article.data('id');
    };

    var updateArticle = function(data, success_callback, error_callback) {
      $.ajax({
        url: '/articles/' + article.data('id'),
        data: data,
        type: 'put',
        dataType: 'json'
      }).success(success_callback).error(error_callback);
    };

    var saveUrlname = function(event) {
      event.preventDefault();
      var urlname = $('#article-urlname').val();
      if (isPersisted()) {
        updateArticle($('#urlname-form').serializeArray(), function(data) {
          $('#topbar .urlname').text(data.urlname);
          Dialog.hide('#urlname-modal');
        });
      } else {
        article.data('urlname', urlname);
        $('#topbar .urlname').text(urlname);
        Dialog.hide('#urlname-modal');
      }
    };

    var saveBook = function(event) {
      event.preventDefault();
      var bookId = $('#article-book-id').val();
      var bookName = $('#book-form .dropdown-toggle').text();
      if (isPersisted()) {
        updateArticle($('#book-form').serializeArray(), function(data) {
          article.data('book-id', bookId);
          $('#topbar .book-name').text(bookId ? bookName : '');
          Dialog.hide('#book-modal');
        });
      } else {
        article.data('book-id', bookId);
        $('#topbar .book-name').text(bookId ? bookName : '');
        Dialog.hide('#book-modal');
      }
    };

    var createBook = function(event) {
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
    };

    var saveArticle = function(event) {
      event.preventDefault();
      if (isPersisted()) {
        updateArticle({
          article: {
            title: editor.editable.find('h1').text(),
            body: editor.editable.html()
          }
        });
      } else {
        createArticle();
      }
    };

    var createArticle = function() {
      $.ajax({
        url: '/articles',
        data: {
          article: {
            title: editor.editable.find('h1').text(),
            body: editor.editable.html(),
            urlname: article.data('urlname'),
            book_id : article.data('book-id'),
            publish: article.data('publish')
          }
        },
        type: 'post',
        dataType: 'json'
      }).success(function(data) {
        article.data('id', data.id);
        history.replaceState(null, null, '/articles/' + data.id + '/edit');
      });
    };

    var setPbulishClass = function(isPublish) {
      if (isPublish) {
        $('#draft-button').removeClass('button-actived');
        $('#publish-button').addClass('button-actived');
      } else {
        $('#publish-button').removeClass('button-actived');
        $('#draft-button').addClass('button-actived');
      }
    };

    var publishArticle = function(event) {
      setPbulishClass(true);
      event.preventDefault();
        if (isPersisted()) {
        updateArticle({
          article: {
            publish: true
          }
        }, null, function(data) {
          setPbulishClass(false);
          article.data('publish', false);
        });
      } else {
        article.data('publish', true);
      }
    };

    var draftArticle = function(event) {
      event.preventDefault();
      setPbulishClass(false);
      if (isPersisted()) {
        updateArticle({
          article: {
            publish: false
          }
        }, null, function(data) {
          setPbulishClass(true);
          article.data('publish', true);
        });
      } else {
        article.data('publish', false);
      }
    };

    $('#urlname-form').on('submit', saveUrlname);
    $('#save-button').on('click', saveArticle);
    $('#publish-button').on('click', publishArticle);
    $('#draft-button').on('click', draftArticle);

    $('#book-form .dropdown').on('click', '.dropdown-menu li a', function(event) {
      event.preventDefault();
      var $li = $(this);
      $li.closest('.dropdown').find('.dropdown-toggle').text($li.text());
      $('#article-book-id').val($li.data('book-id'));
    });
    $('#book-form').on('submit', saveBook);
    $('#new-book-form').on('submit', createBook);

    Mousetrap.bind('ctrl+s', saveArticle);
  }
});
