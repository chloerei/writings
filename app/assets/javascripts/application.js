//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require mousetrap
//= require_tree ./sitewide
//= require_tree ./application

$(function() {
  // Client Side Validations - Turbolinks
  $(document).bind('page:change', function() {
    $('form[data-validate]').validate();
  });
});
