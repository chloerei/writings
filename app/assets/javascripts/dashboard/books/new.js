page_ready(function() {
  if ($('#categories-new')) {
    $('#new_category').on('ajax:success', function(event, data) {
      Turbolinks.visit('/categories/' + data.urlname);
    });
  }
});
