module("Editor");

editor = new Editor({
  toolbar: '#qunit-fixture .toolbar',
  editable: '#qunit-fixture .editable'
});

test("create", function() {
  ok(editor);
  ok(editor.toolbar.length);
  ok(editor.editable.length);
});
