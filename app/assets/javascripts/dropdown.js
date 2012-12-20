$(document).on('click', '.dropdown-toggle', function(event) {
  event.preventDefault();
  event.stopPropagation();
  $(this).closest('.dropdown').toggleClass('actived');
}).on('click', function(event) {
  $('.dropdown').removeClass('actived');
});
