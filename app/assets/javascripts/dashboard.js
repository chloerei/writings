//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require mousetrap
//= require jquery-fileupload/vendor/jquery.ui.widget
//= require jquery-fileupload/jquery.iframe-transport
//= require jquery-fileupload/jquery.fileupload
//= require_tree ./sitewide
//= require_tree ./dashboard

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

  $(document).on('ajax:before', function() {
    AlertMessage.loading('Posting...');
  }).on('ajax:success', function() {
    AlertMessage.success('Success', 1500);
  }).on('ajax:error', function(xhr, status, error) {
    try {
      var data = $.parseJSON(status.responseText);
      AlertMessage.error(data.message || 'Error');
    } catch(err) {
      AlertMessage.error(data.message || 'Server Error');
    }
  });

  $(document).on('click', '.alert-message', function() {
    AlertMessage.clear();
  });
});
