var Dialog = {
  level: 0,
  zIndex: 1000,
  zIndexStep: 10,
  show: function(el) {
    var $modal = $(el);

    if ($modal.is(':visible')) {
      return;
    }

    if ($('#modal-background').length === 0) {
      $('body').append($('<div id="modal-background"></div>'));
    }

    var zIndex = Dialog.zIndex + Dialog.zIndexStep * Dialog.level;
    $('#modal-background').css('z-index', zIndex);
    $modal.css('z-index', zIndex + 1).show();

    $modal.css('margin-left', '-' + ($modal.outerWidth() / 2) + 'px')
      .css('margin-top', '-' + $modal.outerHeight() / 2 + 'px');

    $modal.find(ClientSideValidations.selectors.forms).resetClientSideValidations();

    Dialog.level += 1;
    $modal.addClass('modal-level-' + Dialog.level);
  },

  hide: function(el) {
    $modal = $(el);

    if ($modal.is(':hidden')) {
      return;
    }

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

$(document).on('click', '[data-remove=modal]', function(event) {
  event.preventDefault();
  var dialog = $(this).closest('.modal-dialog');
  Dialog.hide(dialog);
  dialog.remove();
});

$(document).on('keyup', function(event) {
  if (event.keyCode === 27 && Dialog.level > 0) { // Esc
    Dialog.hide('.modal-level-' + Dialog.level);
  }
});
