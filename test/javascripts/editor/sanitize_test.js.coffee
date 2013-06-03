module "Editor.Sanitize",
  setup: ->
    @editor = new Editor(editable: "#qunit-fixture .editable")
    @sanitize = @editor.sanitize

  teardown: ->
    @sanitize = null

sanitizeTest = (_this, html, expected) ->
  _this.sanitize.editable.html html
  _this.sanitize.run()
  equal _this.sanitize.editable.html(), expected

test "sanitize p", ->

  # flatten nested p
  sanitizeTest this, $("<p>").append($("<p>").text("line one")).append($("<p>").text("line two")), "<p>line one</p><p>line two</p>"

  # stript nested p if has text node
  sanitizeTest this, $("<p>").text("text").append($("<p>").text("nested")), "<p>textnested</p>"

  # stript more nested block

  # '<p><h1>header</h1><p><p>line one</p><p>line two</p></p></p>
  sanitizeTest this, $("<p>").append($("<h1>").text("header")).append($("<p>").append($("<p>").text("line one")).append($("<p>").text("line two"))), "<h1>header</h1><p>line one</p><p>line two</p>"

  # keep list
  sanitizeTest this, $("<p>").append($("<ul>").append($("<li>").text("text"))), "<ul><li>text</li></ul>"

test "sanitize header", ->
  sanitizeTest this, "<h1><b>header</b></h1>", "<h1>header</h1>"

test "sanitize div to p", ->
  sanitizeTest this, "<div>text</div>", "<p>text</p>"
  sanitizeTest this, "<div><div>text</div></div>", "<p>text</p>"

test "sanitize stript not allow tags", ->
  sanitizeTest this, "<p>text</p><table></table>", "<p>text</p>"
  sanitizeTest this, "<p>text</p><table><tbody></tbody></table>", "<p>text</p>"

test "sanitize code", ->

  # stript code
  sanitizeTest this, "<code>code1<code>code2</code></code>", "<code>code1code2</code>"

  # stript p to line
  sanitizeTest this, "<code><p>line one</p><p>line two</p></code>", "<code>line one\nline two\n</code>"

  # stript other tags
  sanitizeTest this, "<code><span>text</span></code>", "<code>text</code>"

  # fix pre without code
  sanitizeTest this, "<pre>code</pre>", "<pre><code>code</code></pre>"

test "sanitize attr", ->
  sanitizeTest this, "<p style=\"font-weight: bold;\" class=\"foo\">text</p>", "<p>text</p>"

  # allow attr in white list
  sanitizeTest this, "<a href=\"http://domain.name\" style=\"font-weight: bold;\" class=\"foo\">text</a>", "<a href=\"http://domain.name\">text</a>"

test "sanitize li", ->

  # stript p
  sanitizeTest this, "<ul><li><p>line one</p><p>line two</p></li></ul>", "<ul><li>line one<br>line two</li></ul>"

  # stript other element
  sanitizeTest this, "<ul><li><h1>header</h1><span>span</span></li></ul>", "<ul><li>headerspan</li></ul>"

  # stript nested li
  sanitizeTest this, "<ul><li><ul><li>header</li></ul></li></ul>", "<ul><li>header</li></ul>"
