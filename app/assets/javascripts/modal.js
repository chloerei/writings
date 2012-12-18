var Dialog = {
  show: function(id) {
    $('body').append($('<div id="modal-background"></div>'));
    $(id).show();
  },

  hide: function(el) {
    $('#modal-background').remove();
    $(el).hide();
  }
};

$(document).on('click', '[data-toggle-modal]', function(event) {
  event.preventDefault();
  Dialog.show($(this).data('toggle-modal'));
});

$(document).on('click', '.modal-close', function(event) {
  event.preventDefault();
  Dialog.hide($(this).closest('.modal-dialog'));
});
