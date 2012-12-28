module("editor");

window.editor = new Editor({
  toolbar: '#qunit-fixture .toolbar',
  editable: '#qunit-fixture .editable'
});

test("create", function() {
  ok(editor);
  ok(editor.toolbar.length);
  ok(editor.editable.length);
});

test("sanitize p", function() {
  // flatten nested p
  editor.editable.html(
    $('<p>').append($('<p>').text('line one')).append($('<p>').text('line two'))
  );
  editor.sanitize();
  equal(editor.editable.html(),
    '<p>line one</p>' +
    '<p>line two</p>'
  );

  // stript nested p if has text node
  editor.editable.html(
    $('<p>').text('text').append($('<p>').text('nested'))
  );
  editor.sanitize();
  equal(editor.editable.html(), '<p>textnested</p>');

  // stript more nested block
  editor.editable.html(
    $('<p>').text('text').append($('<h1>').append($('<p>').text('nested')))
  );
  editor.sanitize();
  equal(editor.editable.html(), '<p>textnested</p>');
});
