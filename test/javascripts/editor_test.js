window.editor = new Editor({
  toolbar: '#qunit-fixture .toolbar',
  editable: '#qunit-fixture .editable'
});

test("editor create", function() {
  ok(editor);
  ok(editor.toolbar.length);
  ok(editor.editable.length);
});
