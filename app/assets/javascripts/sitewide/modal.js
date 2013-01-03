var Dialog = {
  show: function(id) {
    if ($('#modal-background').length === 0) {
      $('body').append($('<div id="modal-background"></div>'));
    }
    var $modal = $(id);

    if ($modal.hasClass('level-2')) {
      $('#modal-background').addClass('level-2');
    }
    $modal.show().find('input[type=text]').first().focus();
    $modal.find(ClientSideValidations.selectors.forms).resetClientSideValidations();
  },

  hide: function(el) {
    $modal = $(el);
    $modal.hide();

    if ($modal.hasClass('level-2')) {
      $('#modal-background').removeClass('level-2');
    } else {
      $('#modal-background').remove();
    }
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
