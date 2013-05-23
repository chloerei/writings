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
