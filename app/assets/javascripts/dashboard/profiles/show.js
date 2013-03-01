page_ready(function() {
  if ($('#profiles-show').length) {
    $('#show-nav-button').on('click', function(event) {
      event.preventDefault();
      event.stopPropagation();
      $('#main-nav').addClass('appear');
    });

    $('#main-nav-background').on('click', function(event) {
      $('#main-nav').removeClass('appear');
    });
  }
});
