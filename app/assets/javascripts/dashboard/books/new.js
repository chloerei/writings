page_ready(function() {
  if ($('#books-new')) {
    $('#new_book').on('ajax:success', function(event, data) {
      Turbolinks.visit('/books/' + data.urlname);
    });
  }
});
