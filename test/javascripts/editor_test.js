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

var sanitizeTest = function(html, expected) {
  editor.editable.html(html);
  editor.sanitize();
  equal(editor.editable.html(), expected);
};

test("sanitize p", function() {
  // flatten nested p
  sanitizeTest(
    $('<p>').append($('<p>').text('line one')).append($('<p>').text('line two')),
    '<p>line one</p><p>line two</p>'
  );

  // stript nested p if has text node
  sanitizeTest(
    $('<p>').text('text').append($('<p>').text('nested')),
    '<p>textnested</p>'
  );

  // stript more nested block
  sanitizeTest(
    $('<p>').text('text').append($('<h1>').append($('<p>').text('nested'))),
    '<p>textnested</p>'
  );
});

test("sanitize div to p", function() {
  sanitizeTest(
    '<div>text</div>',
    '<p>text</p>'
  );
});

test("sanitize stript not allow tags", function() {
  sanitizeTest(
    '<p>text<table></table></p>',
    '<p>text</p>'
  );
});

test("sanitize code", function() {
  // stript code
  sanitizeTest(
    '<code>code1<code>code2</code></code>',
    '<code>code1code2</code>'
  );
});

test("sanitize attr", function() {
  sanitizeTest(
    '<p style="font-weight: bold">text</p>',
    '<p>text</p>'
  );
});
