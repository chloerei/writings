$(document).on('click', '.dropdown-toggle', function(event) {
  event.preventDefault();
  event.stopPropagation();
  $(this).closest('.dropdown').toggleClass('actived');
}).on('click', function(event) {
  console.log('1');
  $('.dropdown').removeClass('actived');
});
