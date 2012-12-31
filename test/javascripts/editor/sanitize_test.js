module("Editor.Sanitize");

var sanitize = new Editor.Sanitize('#qunit-fixture .editable');

var sanitizeTest = function(html, expected) {
  sanitize.editable.html(html);
  sanitize.run();
  equal(sanitize.editable.html(), expected);
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

  // stript p to line
  sanitizeTest(
    '<code><p>line one</p><p>line two</p></code>',
    '<code>line one\nline two\n</code>'
  );

  // stript other tags
  sanitizeTest(
    '<code><span>text</span></code>',
    '<code>text</code>'
  );

  // fix pre without code
  sanitizeTest(
    '<pre>code</pre>',
    '<pre><code>code</code></pre>'
  );

});

test("sanitize attr", function() {
  sanitizeTest(
    '<p style="font-weight: bold;" class="foo">text</p>',
    '<p>text</p>'
  );

  // allow attr in white list
  sanitizeTest(
    '<a href="http://domain.name" style="font-weight: bold;" class="foo">text</a>',
    '<a href="http://domain.name">text</a>'
  );
});

test("sanitize li", function() {
  // stript p
  sanitizeTest(
    '<ul><li><p>line one</p><p>line two</p></li></ul>',
    '<ul><li>line one<br>line two<br></li></ul>'
  );

  // stript other element
  sanitizeTest(
    '<ul><li><h1>header</h1><span>span<span></li></ul>',
    '<ul><li>headerspan</li></ul>'
  );

  // stript nested li
  sanitizeTest(
    '<ul><li><ul><li>header</li></ul></li></ul>',
    '<ul><li>header</li></ul>'
  );
});
