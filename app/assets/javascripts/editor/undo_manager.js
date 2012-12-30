Editor.UndoManager = function(editable) {
  this.editable = $(editable);
  this.undoStack = [];
  this.redoStack = [];
};

Editor.UndoManager.prototype = {
  save: function() {
    this.undoStack.push(this.currentContents());
    this.redoStack = [];
  },

  undo: function() {
    var $contents = this.undoStack.pop();
    if ($contents) {
      this.redoStack.push(this.currentContents());
      this.applyContents($contents);
    }
  },

  redo: function() {
    var $contents = this.redoStack.pop();
    if ($contents) {
      this.undoStack.push(this.currentContents());
      this.applyContents($contents);
    }
  },

  hasUndo: function() {
    return this.undoStack.length > 0;
  },

  hasRedo: function() {
    return this.redoStack.length > 0;
  },

  currentContents: function() {
    if (document.getSelection().rangeCount !== 0) {
      var range = document.getSelection().getRangeAt(0);
      var startOffset = range.startOffset,
          endOffset = range.endOffset;
      var $container,
          $startContainer = $(range.startContainer),
          $endContainer = $(range.endContainer);

      // wrap text node in span to store data
      if (range.startContainer === range.endContainer) {
        $container = $(range.startContainer);
        if ($container[0].nodeType === 3 /* TEXT NODE */) {
          $container.wrap(
            $('<span>')
              .attr('data-range-start', range.startOffset)
              .attr('data-range-end', range.endOffset)
          );
        } else {
          $container
            .attr('data-range-start', range.startOffset)
            .attr('data-range-end', range.endOffset);
        }
      } else {
        if ($startContainer[0].nodeType === 3 /* TEXT NODE */) {
          $startContainer.wrap($('<span>').attr('data-range-start', range.startOffset));
        } else {
          $startContainer.attr('data-range-start', range.startOffset);
        }
        if ($endContainer[0].nodeType === 3 /* TEXT NODE */) {
          $endContainer.wrap($('<span>').attr('data-range-end', range.endOffset));
        } else {
          $endContainer.attr('data-range-end', range.endOffset);
        }
      }

      var contents = this.editable.contents().clone();

      // clean data in original element
      if ($container) {
        if ($container[0].nodeType === 3) {
          $container.closest('span').replaceWith($container);
        } else {
          $container.removeAttr('data-range-start').removeAttr('data-range-end');
        }
      } else {
        if ($startContainer[0].nodeType === 3 /* TEXT NODE */) {
          $startContainer.parent('span').replaceWith($startContainer.contents());
        } else {
          $startContainer.removeAttr('data-range-start');
        }
        if ($endContainer[0].nodeType === 3 /* TEXT NODE */) {
          $endContainer.parent('span').replaceWith($endContainer.contents());
        } else {
          $endContainer.removeAttr('data-range-end');
        }
      }

      range.setStart($startContainer[0], startOffset);
      range.setEnd($endContainer[0], endOffset);
      document.getSelection().removeAllRanges();
      document.getSelection().addRange(range);
      return contents;
    } else {
      return this.editable.contents().clone();
    }
  },

  applyContents: function($contents) {
    this.editable.html($contents);
    var $startContainer = this.editable.find('[data-range-start]'),
        $endContainer = this.editable.find('[data-range-end]');

    if ($startContainer.length !== 0 && $endContainer.length !== 0) {
      var startOffset = $startContainer.data('range-start'),
          endOffset = $endContainer.data('range-end');
      var startContainer = $startContainer[0],
          endContainer = $endContainer[0];
      if (startContainer === endContainer) {
        if ($startContainer.is('span')) {
          startContainer = endContainer = $startContainer.contents()[0];
          $startContainer.replaceWith(startContainer);
        } else {
          $startContainer.removeAttr('data-range-start');
          $endContainer.removeAttr('data-range-end');
        }
      } else {
        if ($startContainer.is('span')) {
          startContainer = $startContainer.contents()[0];
          $startContainer.replaceWith(startContainer);
        } else {
          $startContainer.removeAttr('data-range-start');
        }
        if ($endContainer.is('span')) {
          endContainer = $endContainer.contents()[0];
          $endContainer.replaceWith(endContainer);
        } else {
          $endContainer.removeAttr('data-range-end');
        }
      }

      var range = document.createRange();
      range.setStart(startContainer, startOffset);
      range.setEnd(endContainer, endOffset);
      document.getSelection().removeAllRanges();
      document.getSelection().addRange(range);
    }
  }
};
