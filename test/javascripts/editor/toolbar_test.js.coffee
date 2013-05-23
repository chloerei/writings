module "Editor.toolbar",
  setup: ->
    @editor = new Editor(editable: "#qunit-fixture .editable")
    @toolbar = new Editor.Toolbar(@editor, "#qunit-fixture .toolbar")

  teardown: ->
    @editor = null
    @toolbar = null

test "can access editor and toolbar", ->
  ok @toolbar
  ok @toolbar.editor
  ok @toolbar.toolbar
