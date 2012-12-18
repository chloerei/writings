//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require rails.validations
//= require mousetrap
//= require modal
//= require highlight_js/highlight
//= require highlight_js/languages/ruby
//= require highlight_js/languages/javascript
//= require highlight_js/languages/bash
//= require highlight_js/languages/xml
//= require highlight_js/languages/css

$(function() {
  // Client Side Validations - Turbolinks
  $(document).bind('page:change', function() {
    $('form[data-validate]').validate();
  });
});
