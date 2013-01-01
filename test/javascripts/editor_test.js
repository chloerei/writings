module("Editor", {
  setup: function() {
    this.editor = new Editor({
      toolbar: '#qunit-fixture .toolbar',
        editable: '#qunit-fixture .editable'
    });
  }, teardowm: function() {
    this.editor = null;
  }
});

test("create", function() {
  ok(this.editor);
  ok(this.editor.editable.length);
  ok(this.editor.toolbar);
});
