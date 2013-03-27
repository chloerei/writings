$(document).on('click', '[data-toggle=tab]', function(event) {
  event.preventDefault();
  $(this).closest('.tabs').find('.actived').removeClass('actived');
  $(this).addClass('actived');
  $($(this).attr('href')).siblings('.tab-pane').removeClass('actived').end().addClass('actived');
});
