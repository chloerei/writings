Editor.Toolbar = function(editor, toolbar) {
  this.editor = editor;
  this.toolbar = $(toolbar);

  var _this = this;
  this.editor.editable.on('keyup mouseup', function() {
    _this.detectState();
  });
  this.toolbar.on('click', '[data-command]', function(event) {
    event.preventDefault();
    _this.command(this);
  });
};

Editor.Toolbar.prototype = {
  detectState: function() {
    this.detectButton();
    this.detectBlocks();
  },

  detectButton: function() {
    var _this = this;

    _this.toolbar.find('[data-command]').each(function(index, element) {
      var command = $(element).data('command');
      if (document.queryCommandValue(command) !== 'true') {
        $(element).removeClass('actived');
      } else {
        if (command === 'bold' && /^h/.test(document.queryCommandValue('formatBlock'))) {
          $(element).removeClass('actived');
        } else {
          $(element).addClass('actived');
        }
      }
    });
  },

  detectBlocks: function() {
    var type = document.queryCommandValue('formatBlock');
    var text = this.toolbar.find('#format-block [data-command=' + type + ']').text();
    if (text === '') {
      text = this.toolbar.find('#format-block [data-command]:first').text();
    }
    this.toolbar.find('#format-block .toolbar-botton').text(text);
  },

  command: function(element) {
    this.editor.formator[$(element).data('command')]();
    this.detectState();
  }
};
