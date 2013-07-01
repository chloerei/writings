window.page_ready = function(callback) {
  $(callback);
  $(document).on('page:load', callback);
};

$(document).on('page:change', function() {
  Mousetrap.reset();
});
