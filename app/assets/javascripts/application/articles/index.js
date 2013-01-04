var ArticleIndex = function() {
  this.fetching = false;
  this.articles = $('#articles');

  var _this = this;
  $(window).on('scroll', function() {

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
};

page_ready(function() {
  if ($('body#articles-index').length) {
    new ArticleIndex();
  }
});
