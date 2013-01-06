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
};

ArticleIndex.prototype = {
  uninstall: function() {
    $(window).off('.ArticleIndex');
  }
};

var count = 0;

page_ready(function() {
  if ($('#articles-index, #articles-book, #articles-not_collected').length) {
    window.articleIndex = new ArticleIndex();

    $(document).one('page:change', function() {
      window.articleIndex.uninstall();
      delete window.articleIndex;
    });
  }
});
