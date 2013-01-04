var ArticleIndex = function() {
};

ArticleIndex.prototype = {
};

page_ready(function() {
  if ($('body#articles-index').length) {
    new ArticleIndex();
  }
});
