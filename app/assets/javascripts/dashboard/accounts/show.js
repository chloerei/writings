page_ready(function() {
  if ($('#accounts-show').length) {
    $('#show-nav-button').on('click', function(event) {
      event.preventDefault();
      event.stopPropagation();
      $('#main-nav').addClass('appear');
    });

    $('#main-nav-background').on('click', function(event) {
      $('#main-nav').removeClass('appear');
    });

    $('#account_form').on('ajax:success', function(event, data) {
      $('#user-link').attr('href', 'http://' + data.host);
    });
  }
});
