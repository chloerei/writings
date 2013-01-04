window.page_ready = function(callback) {
  $(callback);
  $(document).bind('page:change', callback);
};

page_ready(function() {
  Mousetrap.reset();
});
