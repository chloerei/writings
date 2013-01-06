var Dialog = {
  level: 0,
  zIndex: 1000,
  zIndexStep: 10,
  show: function(id) {
    if ($('#modal-background').length === 0) {
      $('body').append($('<div id="modal-background"></div>'));
    }
    var $modal = $(id);

    var zIndex = Dialog.zIndex + Dialog.zIndexStep * Dialog.level;
    $('#modal-background').css('z-index', zIndex);
    $modal.css('z-index', zIndex + 1).show();
    $modal.find(ClientSideValidations.selectors.forms).resetClientSideValidations();

    Dialog.level += 1;
  },

  hide: function(el) {
    $modal = $(el);
    $modal.hide();
    Dialog.level -= 1;

    if (Dialog.level === 0) {
      $('#modal-background').remove();
    } else {
      var zIndex = Dialog.zIndex + Dialog.zIndexStep * (Dialog.level - 1);
      $('#modal-background').css('z-index', zIndex);
    }
  }
};

$(document).on('click', '[data-toggle=modal]', function(event) {
  event.preventDefault();
  Dialog.show($(this).data('target') || $(this).attr('href'));
});

$(document).on('click', '[data-close=modal]', function(event) {
  event.preventDefault();
  Dialog.hide($(this).closest('.modal-dialog'));
});
