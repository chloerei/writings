module "Editor",
  setup: ->
    @editor = new Editor(
      toolbar: "#qunit-fixture .toolbar"
      editable: "#qunit-fixture .editable"
    )

  teardowm: ->
    @editor = null

test "create", ->
  ok @editor
  ok @editor.editable.length
  ok @editor.toolbar

test "readonly", ->
  ok !@editor.readonly
  equal @editor.editable.prop('contentEditable'), 'true'
  @editor.setReadonly(true)
  ok @editor.readonly
  equal @editor.editable.prop('contentEditable'), 'false'

test "reset", ->
  @editor.editable.html('<p>text</p>')
  @editor.reset()
  equal @editor.editable.text(), ''
