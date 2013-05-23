window.page_ready = function(callback) {
  $(callback);
  $(document).on('page:load page:restore', callback);
};

$(document).on('page:change', function() {
  Mousetrap.reset();
});
