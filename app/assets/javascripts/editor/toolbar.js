Editor.Toolbar = function(editor, toolbar) {
  this.editor = editor;
  this.toolbar = $(toolbar);

  var _this = this;
  this.editor.editable.on('keyup mouseup', function() {
    _this.detectState();
  });
  this.toolbar.on('click', '[data-command]', function(event) {
    event.preventDefault();
    if (!$(this).closest('.readonly').length) {
      _this.command(this);
    }
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
      if (command) {
        var isCommand = 'is' + command[0].toUpperCase() + command.substring(1);

        if (_this.editor.formator[isCommand]) {
          if (_this.editor.formator[isCommand]()) {
            $(element).addClass('actived');
          } else {
            $(element).removeClass('actived');
          }
        }

        var canCommand = 'can' + command[0].toUpperCase() + command.substring(1);

        if (_this.editor.formator[canCommand]) {
          if (_this.editor.formator[canCommand]()) {
            $(element).removeClass('disabled');
          } else {
            $(element).addClass('disabled');
          }
        }
      }
    });
  },

  detectBlocks: function() {
    var type = document.queryCommandValue('formatBlock');
    if (type === 'pre') {
      type = 'code'; // rename
    }
    var text = this.toolbar.find('#format-block [data-command=' + type + ']').text();
    if (text === '') {
      text = this.toolbar.find('#format-block [data-command]:first').text();
    }
    this.toolbar.find('#format-block .toolbar-button').text(text);
  },

  command: function(element) {
    if (!this.editor.hasRange()) {
      this.editor.restoreRange();
    }
    this.editor.formator[$(element).data('command')]();
    this.detectState();
  }
};
