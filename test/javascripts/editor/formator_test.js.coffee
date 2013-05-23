module "Editor.formator",
  setup: ->
    @editor = new Editor(editable: "#qunit-fixture .editable")
    @formator = @editor.formator

  teardown: ->

test "should format bold", ->
  @formator.editable.html "<p>text</p>"
  document.getSelection().selectAllChildren @formator.editable.find("p")[0]
  equal @formator.isBold(), false
  equal @formator.canBold(), true
  @formator.bold()
  equal @formator.editable.html(), "<p><b>text</b></p>"
  equal @formator.isBold(), true
  equal @formator.canBold(), true
  @formator.bold()
  equal @formator.editable.html(), "<p>text</p>"
  equal @formator.isBold(), false
  equal @formator.canBold(), true

  # don't bold header
  @formator.editable.html "<h1>header</h1>"
  document.getSelection().selectAllChildren @formator.editable.find("h1")[0]
  equal @formator.isBold(), false
  equal @formator.canBold(), false
  @formator.bold()
  equal @formator.editable.html(), "<h1>header</h1>"

test "should format italic", ->
  @formator.editable.html "<p>text</p>"
  document.getSelection().selectAllChildren @formator.editable.find("p")[0]
  equal @formator.isItalic(), false
  equal @formator.canItalic(), true
  @formator.italic()
  equal @formator.editable.html(), "<p><i>text</i></p>"
  equal @formator.isItalic(), true
  equal @formator.canItalic(), true
  @formator.italic()
  equal @formator.editable.html(), "<p>text</p>"
  equal @formator.isItalic(), false
  equal @formator.canItalic(), true

  # don't italic code
  @formator.editable.html "<code>code</code>"
  document.getSelection().selectAllChildren @formator.editable.find("code")[0]
  equal @formator.isItalic(), false
  equal @formator.canItalic(), false
  @formator.italic()
  equal @formator.editable.html(), "<code>code</code>"

test "should format strikeThrough", ->
  @formator.editable.html "<p>text</p>"
  document.getSelection().selectAllChildren @formator.editable.find("p")[0]
  equal @formator.isStrikeThrough(), false
  equal @formator.canStrikeThrough(), true
  @formator.strikeThrough()
  equal @formator.editable.html(), "<p><strike>text</strike></p>"
  equal @formator.isStrikeThrough(), true
  equal @formator.canStrikeThrough(), true
  @formator.strikeThrough()
  equal @formator.editable.html(), "<p>text</p>"
  equal @formator.isStrikeThrough(), false
  equal @formator.canStrikeThrough(), true

  # don't strikeThrough code
  @formator.editable.html "<code>code</code>"
  document.getSelection().selectAllChildren @formator.editable.find("code")[0]
  equal @formator.isStrikeThrough(), false
  equal @formator.canStrikeThrough(), false
  @formator.strikeThrough()
  equal @formator.editable.html(), "<code>code</code>"

test "should format underline", ->
  @formator.editable.html "<p>text</p>"
  document.getSelection().selectAllChildren @formator.editable.find("p")[0]
  equal @formator.isUnderline(), false
  equal @formator.canUnderline(), true
  @formator.underline()
  equal @formator.editable.html(), "<p><u>text</u></p>"
  equal @formator.isUnderline(), true
  equal @formator.canUnderline(), true
  @formator.underline()
  equal @formator.editable.html(), "<p>text</p>"
  equal @formator.isUnderline(), false
  equal @formator.canUnderline(), true

  # don't underline code
  @formator.editable.html "<code>code</code>"
  document.getSelection().selectAllChildren @formator.editable.find("code")[0]
  equal @formator.isUnderline(), false
  equal @formator.canUnderline(), false
  @formator.underline()
  equal @formator.editable.html(), "<code>code</code>"

test "should format orderedList", ->
  @formator.editable.html "<p>text</p>"
  document.getSelection().selectAllChildren @formator.editable.find("p")[0]
  equal @formator.isOrderedList(), false
  equal @formator.canOrderedList(), true
  @formator.orderedList()
  equal @formator.editable.html(), "<ol><li>text<br></li></ol>"
  document.getSelection().selectAllChildren @formator.editable.find("li")[0]
  @formator.orderedList()
  equal @formator.editable.html(), "<p>text</p>"
  equal @formator.isOrderedList(), false
  equal @formator.canOrderedList(), true

  # don't orderedList code
  @formator.editable.html "<code>code</code>"
  document.getSelection().selectAllChildren @formator.editable.find("code")[0]
  equal @formator.isOrderedList(), false
  equal @formator.canOrderedList(), false
  @formator.orderedList()
  equal @formator.editable.html(), "<code>code</code>"

test "should format orderedList", ->
  @formator.editable.html "<p>text</p>"
  document.getSelection().selectAllChildren @formator.editable.find("p")[0]
  equal @formator.isUnorderedList(), false
  equal @formator.canUnorderedList(), true
  @formator.unorderedList()
  equal @formator.editable.html(), "<ul><li>text<br></li></ul>"
  document.getSelection().selectAllChildren @formator.editable.find("li")[0]
  @formator.unorderedList()
  equal @formator.editable.html(), "<p>text</p>"
  equal @formator.isUnorderedList(), false
  equal @formator.canUnorderedList(), true

  # don't unorderedList code
  @formator.editable.html "<code>code</code>"
  document.getSelection().selectAllChildren @formator.editable.find("code")[0]
  equal @formator.isUnorderedList(), false
  equal @formator.canUnorderedList(), false
  @formator.unorderedList()
  equal @formator.editable.html(), "<code>code</code>"


#
# * TODO link test
#
test "format header", ->
  @formator.editable.html "<p>text</p>"
  document.getSelection().selectAllChildren @formator.editable.find("p")[0]
  equal @formator.isH1(), false
  equal @formator.canH1(), true
  @formator.h1()
  equal @formator.editable.html(), "<h1>text</h1>"
  equal @formator.isH1(), true
  equal @formator.canH1(), true
  @formator.h1()
  equal @formator.editable.html(), "<p>text</p>"
  equal @formator.isH1(), false
  equal @formator.canH1(), true

  # don't unorderedList code
  @formator.editable.html "<code>code</code>"
  document.getSelection().selectAllChildren @formator.editable.find("code")[0]
  equal @formator.isUnorderedList(), false
  equal @formator.canUnorderedList(), false
  @formator.unorderedList()
  equal @formator.editable.html(), "<code>code</code>"

  # stirpt header
  @formator.editable.html "<p><b>text</b></p>"
  document.getSelection().selectAllChildren @formator.editable.find("p")[0]
  @formator.h1()
  equal @formator.editable.html(), "<h1>text</h1>"

test "format code", ->
  @formator.editable.html "<p>text</p>"
  document.getSelection().selectAllChildren @formator.editable.find("p")[0]
  equal @formator.isCode(), false
  equal @formator.canCode(), true
  @formator.code()
  equal @formator.editable.html(), "<pre><code>text\n</code></pre><p><br></p>" # add a new line after
  @formator.code()
  equal @formator.editable.html(), "<p>text</p><p><br></p>"
  @formator.editable.html "<p>text</p>"
  range = document.createRange()
  textNode = @formator.editable.find("p").contents().first()[0]
  range.setStart textNode, 0
  range.setEnd textNode, 1
  document.getSelection().removeAllRanges()
  document.getSelection().addRange range
  @formator.code()
  equal @formator.editable.html(), "<p><code>t</code>ext</p>"
  @formator.code()
  equal @formator.editable.html(), "<p>text</p>"

test "format blockquote", ->
  @formator.editable.html "<p>text</p>"
  document.getSelection().selectAllChildren @formator.editable.find("p")[0]
  equal @formator.isBlockquote(), false
  equal @formator.canBlockquote(), true
  @formator.blockquote()
  equal @formator.editable.html(), "<blockquote><p>text</p></blockquote><p><br></p>" # add a new line after
  @formator.blockquote()
  equal @formator.editable.html(), "<p>text</p><p><br></p>"

  # multi line
  @formator.editable.html "<p>text</p><p>text</p>"
  document.getSelection().selectAllChildren @formator.editable[0]
  @formator.blockquote()
  equal @formator.editable.html(), "<blockquote><p>text</p><p>text</p></blockquote><p><br></p>" # add a new line after
  @formator.blockquote()
  equal @formator.editable.html(), "<p>text</p><p>text</p><p><br></p>"
