//= require editor

$(function() {
  if ($('body#article-edit').length) {
    window.editor = new Editor({
      toolbar: '#toolbar',
      editable: '#editarea article'
    });

    var updateArticle = function(data, success_callback, error_callback) {
      $.ajax({
        url: '/articles/' + editor.editable.data('article-id'),
        data: data,
        type: 'put',
        dataType: 'json'
      }).success(success_callback).error(error_callback);
    };

    var saveUrlname = function(event) {
      event.preventDefault();
      updateArticle($('#urlname-modal form').serializeArray(), function(data) {
        $('#topbar .urlname').text(data.urlname);
        Dialog.hide('#urlname-modal');
      });
    };

    var saveArticle = function(event) {
      event.preventDefault();
      updateArticle({
        article: {
          title: editor.editable.find('h1').text(),
          body: editor.editable.html()
        }
      });
    };

    var publishArticle = function(event) {
      event.preventDefault();
      updateArticle({
        article: {
          publish: true
        }
      }, function(data) {
        $('#draft-button').removeClass('button-actived');
        $('#publish-button').addClass('button-actived');
      });
    };

    var draftArticle = function(event) {
      event.preventDefault();
      updateArticle({
        article: {
          publish: false
        }
      }, function(data) {
        $('#publish-button').removeClass('button-actived');
        $('#draft-button').addClass('button-actived');
      });
    };

    $('#urlname-modal form').on('submit', saveUrlname);
    $('#save-button').on('click', saveArticle);
    $('#publish-button').on('click', publishArticle);
    $('#draft-button').on('click', draftArticle);

    Mousetrap.bind('ctrl+s', saveArticle);
  }
});
