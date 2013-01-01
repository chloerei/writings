module("Editor.formator", {
  setup: function() {
    this.formator = new Editor.Formator('#qunit-fixture .editable');
  },
  teardown: function() {
  }
});

test("should check bold status", function() {
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
});
