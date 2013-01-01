module("Editor.formator", {
  setup: function() {
    this.formator = new Editor.Formator('#qunit-fixture .editable');
  },
  teardown: function() {
  }
});

test("should format bold", function() {
  this.formator.editable.html('<p>text</p>');
  document.getSelection().selectAllChildren(this.formator.editable.find('p')[0]);
  equal(this.formator.isBold(), false);
  equal(this.formator.canBold(), true);

  this.formator.bold();
  equal(this.formator.editable.html(), '<p><b>text</b></p>');
  equal(this.formator.isBold(), true);
  equal(this.formator.canBold(), true);

  this.formator.bold();
  equal(this.formator.editable.html(), '<p>text</p>');
  equal(this.formator.isBold(), false);
  equal(this.formator.canBold(), true);

  // don't bold header
  this.formator.editable.html('<h1>header</h1>');
  document.getSelection().selectAllChildren(this.formator.editable.find('h1')[0]);
  equal(this.formator.isBold(), false);
  equal(this.formator.canBold(), false);
  this.formator.bold();
  equal(this.formator.editable.html(), '<h1>header</h1>');
});

test("should format italic", function() {
  this.formator.editable.html('<p>text</p>');
  document.getSelection().selectAllChildren(this.formator.editable.find('p')[0]);
  equal(this.formator.isItalic(), false);
  equal(this.formator.canItalic(), true);

  this.formator.italic();
  equal(this.formator.editable.html(), '<p><i>text</i></p>');
  equal(this.formator.isItalic(), true);
  equal(this.formator.canItalic(), true);

  this.formator.italic();
  equal(this.formator.editable.html(), '<p>text</p>');
  equal(this.formator.isItalic(), false);
  equal(this.formator.canItalic(), true);

  // don't italic code
  this.formator.editable.html('<code>code</code>');
  document.getSelection().selectAllChildren(this.formator.editable.find('code')[0]);
  equal(this.formator.isItalic(), false);
  equal(this.formator.canItalic(), false);
  this.formator.italic();
  equal(this.formator.editable.html(), '<code>code</code>');
});

test("should format strikeThrough", function() {
  this.formator.editable.html('<p>text</p>');
  document.getSelection().selectAllChildren(this.formator.editable.find('p')[0]);
  equal(this.formator.isStrikeThrough(), false);
  equal(this.formator.canStrikeThrough(), true);

  this.formator.strikeThrough();
  equal(this.formator.editable.html(), '<p><strike>text</strike></p>');
  equal(this.formator.isStrikeThrough(), true);
  equal(this.formator.canStrikeThrough(), true);

  this.formator.strikeThrough();
  equal(this.formator.editable.html(), '<p>text</p>');
  equal(this.formator.isStrikeThrough(), false);
  equal(this.formator.canStrikeThrough(), true);

  // don't strikeThrough code
  this.formator.editable.html('<code>code</code>');
  document.getSelection().selectAllChildren(this.formator.editable.find('code')[0]);
  equal(this.formator.isStrikeThrough(), false);
  equal(this.formator.canStrikeThrough(), false);
  this.formator.strikeThrough();
  equal(this.formator.editable.html(), '<code>code</code>');
});

test("should format underline", function() {
  this.formator.editable.html('<p>text</p>');
  document.getSelection().selectAllChildren(this.formator.editable.find('p')[0]);
  equal(this.formator.isUnderline(), false);
  equal(this.formator.canUnderline(), true);

  this.formator.underline();
  equal(this.formator.editable.html(), '<p><u>text</u></p>');
  equal(this.formator.isUnderline(), true);
  equal(this.formator.canUnderline(), true);

  this.formator.underline();
  equal(this.formator.editable.html(), '<p>text</p>');
  equal(this.formator.isUnderline(), false);
  equal(this.formator.canUnderline(), true);

  // don't underline code
  this.formator.editable.html('<code>code</code>');
  document.getSelection().selectAllChildren(this.formator.editable.find('code')[0]);
  equal(this.formator.isUnderline(), false);
  equal(this.formator.canUnderline(), false);
  this.formator.underline();
  equal(this.formator.editable.html(), '<code>code</code>');
});

test("should format orderedList", function() {
  this.formator.editable.html('<p>text<br></p>');
  document.getSelection().selectAllChildren(this.formator.editable.find('p')[0]);
  equal(this.formator.isOrderedList(), false);
  equal(this.formator.canOrderedList(), true);

  this.formator.orderedList();
  equal(this.formator.editable.html(), '<p><ol><li>text<br></li></ol></p>');
  equal(this.formator.isOrderedList(), true);
  equal(this.formator.canOrderedList(), true);

  this.formator.orderedList();
  equal(this.formator.editable.html(), '<p>text<br></p>');
  equal(this.formator.isOrderedList(), false);
  equal(this.formator.canOrderedList(), true);

  // don't orderedList code
  this.formator.editable.html('<code>code</code>');
  document.getSelection().selectAllChildren(this.formator.editable.find('code')[0]);
  equal(this.formator.isOrderedList(), false);
  equal(this.formator.canOrderedList(), false);
  this.formator.orderedList();
  equal(this.formator.editable.html(), '<code>code</code>');
});


test("should format orderedList", function() {
  this.formator.editable.html('<p>text<br></p>');
  document.getSelection().selectAllChildren(this.formator.editable.find('p')[0]);
  equal(this.formator.isUnorderedList(), false);
  equal(this.formator.canUnorderedList(), true);

  this.formator.unorderedList();
  equal(this.formator.editable.html(), '<p><ul><li>text<br></li></ul></p>');
  equal(this.formator.isUnorderedList(), true);
  equal(this.formator.canUnorderedList(), true);

  this.formator.unorderedList();
  equal(this.formator.editable.html(), '<p>text<br></p>');
  equal(this.formator.isUnorderedList(), false);
  equal(this.formator.canUnorderedList(), true);

  // don't unorderedList code
  this.formator.editable.html('<code>code</code>');
  document.getSelection().selectAllChildren(this.formator.editable.find('code')[0]);
  equal(this.formator.isUnorderedList(), false);
  equal(this.formator.canUnorderedList(), false);
  this.formator.unorderedList();
  equal(this.formator.editable.html(), '<code>code</code>');
});

/*
 * TODO link test
 */

test("format header", function() {
  this.formator.editable.html('<p>text</p>');
  document.getSelection().selectAllChildren(this.formator.editable.find('p')[0]);
  equal(this.formator.isH1(), false);
  equal(this.formator.canH1(), true);

  this.formator.h1();
  equal(this.formator.editable.html(), '<h1>text</h1>');
  equal(this.formator.isH1(), true);
  equal(this.formator.canH1(), true);

  this.formator.h1();
  equal(this.formator.editable.html(), '<p>text</p>');
  equal(this.formator.isH1(), false);
  equal(this.formator.canH1(), true);

  // don't unorderedList code
  this.formator.editable.html('<code>code</code>');
  document.getSelection().selectAllChildren(this.formator.editable.find('code')[0]);
  equal(this.formator.isUnorderedList(), false);
  equal(this.formator.canUnorderedList(), false);
  this.formator.unorderedList();
  equal(this.formator.editable.html(), '<code>code</code>');
});
