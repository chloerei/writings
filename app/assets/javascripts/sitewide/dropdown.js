$(document).on('click', '.dropdown-toggle', function(event) {
  event.preventDefault();
  event.stopPropagation();

  var $dropdown = $(this).closest('.dropdown');
  var isOpened = $dropdown.hasClass('actived');
  $('.dropdown').removeClass('actived');
  if (!isOpened) {
    $dropdown.addClass('actived');
  }
}).on('click', function(event) {
  $('.dropdown').removeClass('actived');
});
