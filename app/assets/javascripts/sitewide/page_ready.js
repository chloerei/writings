window.page_ready = function(callback) {
  $(callback);
  $(document).bind('page:load page:restore', callback);
};

$(document).one('page:change', function() {
  Mousetrap.reset();
});
