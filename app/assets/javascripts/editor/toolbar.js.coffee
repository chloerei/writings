class @Editor.Toolbar
  constructor: (@editor, toolbar, @options = {}) ->
    @toolbar = $(toolbar)
    @options.activeClass ||= 'actived'
    @options.disableClass ||= 'disabled'
    _this = this
    @editor.editable.on "keyup mouseup", ->
      _this.detectState()

    @toolbar.on "click", "[data-command]", (event) ->
      event.preventDefault()
      _this.command this unless _this.editor.readonly

  detectState: ->
    @detectButton()
    @detectBlocks()

  detectButton: ->
    _this = this
    _this.toolbar.find("[data-command]").each (index, element) ->
      command = $(element).data("command")
      if command
        isCommand = "is" + command[0].toUpperCase() + command.substring(1)
        if _this.editor.formator[isCommand]
          if _this.editor.formator[isCommand]()
            $(element).addClass _this.options.activeClass
          else
            $(element).removeClass _this.options.activeClass
        canCommand = "can" + command[0].toUpperCase() + command.substring(1)
        if _this.editor.formator[canCommand]
          if _this.editor.formator[canCommand]()
            $(element).removeClass _this.options.disableClass
          else
            $(element).addClass _this.options.disableClass


  detectBlocks: ->
    type = document.queryCommandValue("formatBlock")
    type = "code" if type is "pre" # rename
    text = @toolbar.find("#format-block [data-command=" + type + "]").text()
    text = @toolbar.find("#format-block [data-command]:first").text()  if text is ""
    @toolbar.find("#format-block .toolbar-button").text text

  command: (element) ->
    @editor.restoreRange() unless @editor.hasRange()
    @editor.formator[$(element).data("command")]()
    @editor.storeRange() if @editor.hasRange()
    @detectState()
