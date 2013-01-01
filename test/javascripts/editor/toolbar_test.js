module("Editor.toolbar", {
  setup: function() {
    this.editor = new Editor({
      editable: '#qunit-fixture .editable'
    });
    this.toolbar = new Editor.Toolbar(this.editor, '#qunit-fixture .toolbar');
  },
  teardown: function() {
    editor = null;
    toolbar = null;
  }
});

test("can access editor and toolbar", function() {
  ok(this.toolbar);
  ok(this.toolbar.editor);
  ok(this.toolbar.toolbar);
});
