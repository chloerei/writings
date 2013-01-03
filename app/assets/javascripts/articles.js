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
        updateArticle({
          article: { urlname: urlname }
        }, function(data) {
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
      var bookId = $('#book-form .dropdown-toggle').data('book-id');
      var bookName = $('#book-form .dropdown-toggle').text();
      if (isPersisted()) {
        updateArticle({
          article: { book_id: bookId }
        }, function(data) {
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

    var publishArticle = function(event) {
      event.preventDefault();
        if (isPersisted()) {
        updateArticle({
          article: {
            publish: true
          }
        }, function(data) {
          $('#draft-button').removeClass('button-actived');
          $('#publish-button').addClass('button-actived');
        });
      } else {
        article.data('publish', true);
        $('#draft-button').removeClass('button-actived');
        $('#publish-button').addClass('button-actived');
      }
    };

    var draftArticle = function(event) {
      event.preventDefault();
      if (isPersisted()) {
        updateArticle({
          article: {
            publish: false
          }
        }, function(data) {
          $('#publish-button').removeClass('button-actived');
          $('#draft-button').addClass('button-actived');
        });
      } else {
        article.data('publish', true);
        $('#publish-button').removeClass('button-actived');
        $('#draft-button').addClass('button-actived');
      }
    };

    $('#urlname-form').on('submit', saveUrlname);
    $('#save-button').on('click', saveArticle);
    $('#publish-button').on('click', publishArticle);
    $('#draft-button').on('click', draftArticle);

    $('#book-form .dropdown').on('click', '.dropdown-menu li a', function(event) {
      event.preventDefault();
      var $li = $(this);
      $li.closest('.dropdown').find('.dropdown-toggle').text($li.text()).data('book-id', $li.data('book-id'));
    });
    $('#book-form').on('submit', saveBook);

    Mousetrap.bind('ctrl+s', saveArticle);
  }
});
