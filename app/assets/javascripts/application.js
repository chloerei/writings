//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require mousetrap
//= require_tree ./sitewide
//= require_tree ./application

$(function() {
  // Client Side Validations - Turbolinks
  $(document).on('page:change', function() {
    $('form[data-validate]').validate();
  });

  $(document).on('page:fetch', function() {
    $('#spinner').show();
  }).on('page:restore', function() {
    $('#spinner').hide();
  });
});
