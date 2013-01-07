var ArticleIndex = function() {
  this.fetching = false;
  this.articles = $('#articles');

  var _this = this;
  $(window).on('scroll.ArticleIndex', function() {

    var isButtom = $(window).scrollTop() + 200 >= $(document).height() - $(window).height();

    if (isButtom && !_this.fetching && !_this.articles.data('is-end')) {
      _this.fetching = true;

      $.ajax({
        url: _this.articles.data('url'),
        data: { skip: _this.articles.data('skip') },
        dataType: 'script',
        complete: function() {
          _this.fetching = false;
        }
      });
    }
  });

  $('#new-book-form').on('submit.ArticleIndex', function(event) {
    event.preventDefault();

    $.ajax({
      url: '/books',
      data: $(this).serializeArray(),
      type: 'post',
      dataType: 'json'
    }).success(function(data) {
      Turbolinks.visit('/books/' + data.urlname);
    });
  });

  var $bulkbar = $('#bulkbar');

  $('#articles').on('click.ArticleIndex', '.article', function(event) {
    event.preventDefault();

    $(this).toggleClass('selected');

    var count = $('#articles .article.selected').length;
    $bulkbar.find('.selected-count').text(count);
    if (count) {
      $bulkbar.show();
    } else {
      $bulkbar.hide();
    }

    if (count > 1) {
      $bulkbar.find('.edit-button').addClass('disabled');
    } else {
      $bulkbar.find('.edit-button').removeClass('disabled');
    }
  });

  $bulkbar.on('click', '.cancel-button', function(event) {
    event.preventDefault();
    $articles.find('.article.selected').removeClass('selected');
    $bulkbar.find('.selected-count').text(0).hide();
  });

};

ArticleIndex.prototype = {
  destroy: function() {
    $(window).off('.ArticleIndex');
  }
};

var count = 0;

page_ready(function() {
  if ($('#articles-index, #articles-book, #articles-not_collected').length) {
    window.articleIndex = new ArticleIndex();

    $(document).one('page:change', function() {
      window.articleIndex.destroy();
      delete window.articleIndex;
    });
  }
});
