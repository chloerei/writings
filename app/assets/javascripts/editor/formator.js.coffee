class @Editor.Formator
  constructor: (@editor) ->
    @editable = editor.editable
    @exec "defaultParagraphSeparator", "p"

  # inline format do nothing when is Collapsed,
  # so skip afterForamt() by checking isCollapsed,
  # and keep format state;
  isCollapsed: ->
    document.getSelection().isCollapsed

  isBold: ->
    @canBold() and (document.queryCommandValue("bold") is "true" or document.queryCommandState("bold"))

  canBold: ->
    not @isWraped("h1, h2, h3, h4, code")

  bold: ->
    if @canBold()
      @exec "bold"
      @afterFormat() unless @isCollapsed()

  isItalic: ->
    @canItalic() and (document.queryCommandValue("italic") is "true" or document.queryCommandState("italic"))

  canItalic: ->
    not @isWraped("code")

  italic: ->
    if @canItalic()
      @exec "italic"
      @afterFormat() unless @isCollapsed()

  isStrikeThrough: ->
    @canStrikeThrough() and (document.queryCommandValue("strikeThrough") is "true" or document.queryCommandState("strikeThrough"))

  canStrikeThrough: ->
    not @isWraped("code")

  strikeThrough: ->
    if @canStrikeThrough()
      @exec "strikeThrough"
      @afterFormat() unless @isCollapsed()

  isUnderline: ->
    @canUnorderedList() and (document.queryCommandValue("underline") is "true" or document.queryCommandState("underline"))

  canUnderline: ->
    not @isWraped("code, a")

  underline: ->
    if @canUnderline()
      @exec "underline"
      @afterFormat() unless @isCollapsed()

  isOrderedList: ->
    @canOrderedList() and document.queryCommandValue("insertOrderedList") is "true"

  canOrderedList: ->
    not @isWraped("h1, h2, h3, h4, code")

  orderedList: ->
    if @canOrderedList()
      if @isOrderedList()
        @exec "insertOrderedList"
        @p()
      else
        @exec "insertOrderedList"
        if $(@commonAncestorContainer()).closest("p").length
          @editor.storeRange()
          $(@commonAncestorContainer()).closest("ol").unwrap "p"
          @editor.restoreRange()
      @afterFormat()

  isUnorderedList: ->
    @canUnorderedList() and document.queryCommandValue("insertUnorderedList") is "true"

  canUnorderedList: ->
    not @isWraped("h1, h2, h3, h4, code")

  unorderedList: ->
    if @canUnorderedList()
      if @isUnorderedList()
        @exec "insertUnorderedList"
        @p()
      else
        @exec "insertUnorderedList"
        if $(@commonAncestorContainer()).closest("p").length
          @editor.storeRange()
          $(@commonAncestorContainer()).closest("ul").unwrap "p"
          @editor.restoreRange()
      @afterFormat()

  isLink: ->
    @canLink() and @isWraped("a")

  canLink: ->
    not @isWraped("code")

  link: ->
    url = prompt("Link url:", "")
    if url and url isnt ""
      @exec "createLink", url
    else
      @exec "unlink"
    @afterFormat()

  canImage: ->
    not @isWraped("h1, h2, h3, h4, code")

  image: ->
    url = prompt("Link url:", "")
    if url and url isnt ""
      @exec "insertImage", url
    @afterFormat()

  isH1: ->
    @isWraped "h1"

  canH1: ->
    not @isWraped("li, code")

  h1: ->
    @formatHeader "h1"  if @canH1()

  isH2: ->
    @isWraped "h2"

  canH2: ->
    not @isWraped("li, code")

  h2: ->
    @formatHeader "h2"  if @canH2()

  isH3: ->
    @isWraped "h3"  if @canH3()

  canH3: ->
    not @isWraped("li, code")

  h3: ->
    @formatHeader "h3"  if @canH3()

  isH4: ->
    @isWraped "h4"

  canH4: ->
    not @isWraped("li, code")

  h4: ->
    @formatHeader "h4"  if @canH4()

  isP: ->
    @isWraped "p"

  canP: ->
    not @isWraped("li, code")

  p: ->
    @exec "formatBlock", "p"
    @afterFormat()

  formatHeader: (type) ->
    if document.queryCommandValue("formatBlock") is type
      @p()
    else
      @exec "formatBlock", type
      $(@commonAncestorContainer()).closest(type).find(":not(i, strike, u, a, br)").each ->
        $(this).replaceWith $(this).contents()

      @afterFormat()

  isCode: ->
    @isWraped "code"

  canCode: ->
    true

  code: ->
    selection = window.getSelection()
    range = selection.getRangeAt(0)
    rangeAncestor = range.commonAncestorContainer
    start = undefined
    end = undefined
    $contents = undefined
    $code = $(rangeAncestor).closest("code")
    if $code.length

      # remove code
      if $code.closest("pre").length

        # pre code
        @splitCode $code
        $contents = $code.contents()
        $contents = $("<p><br></p>")  if $contents.length is 0
        $code.closest("pre").replaceWith $contents
        @editor.selectContents $contents
      else

        # inline code
        $contents = $code.contents()
        $code.replaceWith $code.contents()
        @editor.selectContents $contents
    else

      # wrap code
      isEmptyRange = (range.toString() is "")
      isWholeBlock = (range.toString() is $(range.startContainer).closest("p, h1, h2, h3, h4").text())
      hasBlock = (range.cloneContents().querySelector("p, h1, h2, h3, h4"))
      if isEmptyRange or isWholeBlock or hasBlock

        # pre code
        start = $(range.startContainer).closest("p, h1, h2, h3, h4")[0]
        end = $(range.endContainer).closest("p, h1, h2, h3, h4")[0]
        range.setStartBefore start
        range.setEndAfter end
        $code = $("<code>").html(range.extractContents())
        $pre = $("<pre>").html($code)
        range.insertNode $pre[0]
        $pre.after "<p><br></p>"  if $pre.next().length is 0
      else

        # inline code
        $code = $("<code>").html(range.extractContents())
        range.insertNode $code[0]
      @editor.sanitize.striptCode $code
      selection.selectAllChildren $code[0]
    @afterFormat()

  splitCode: (code) ->
    code.html $.map(code.text().split("\n"), (line) ->
      $("<p>").text line  if line isnt ""
    )

  isBlockquote: ->
    @isWraped "blockquote"

  canBlockquote: ->
    true

  blockquote: ->
    selection = window.getSelection()
    range = selection.getRangeAt(0)
    rangeAncestor = range.commonAncestorContainer
    start = undefined
    end = undefined
    $blockquote = $(rangeAncestor).closest("blockquote")
    if $blockquote.length

      # remmove blockquote
      $contents = $blockquote.contents()
      $blockquote.replaceWith $contents
      @editor.selectContents $contents
    else

      # wrap blockquote
      start = $(range.startContainer).closest("p, h1, h2, h3, h4, pre")[0]
      end = $(range.endContainer).closest("p, h1, h2, h3, h4, pre")[0]
      range.setStartBefore start
      range.setEndAfter end
      $blockquote = $("<blockquote>")
      $blockquote.html(range.extractContents()).find("blockquote").each ->
        $(this).replaceWith $(this).html()

      range.insertNode $blockquote[0]
      selection.selectAllChildren $blockquote[0]
      $blockquote.after "<p><br></p>"  if $blockquote.next().length is 0
    @afterFormat()

  isWraped: (selector) ->
    if @commonAncestorContainer()
      $(@commonAncestorContainer()).closest(selector).length isnt 0
    else
      false

  commonAncestorContainer: ->
    selection = document.getSelection()
    selection.getRangeAt(0).commonAncestorContainer  if selection.rangeCount isnt 0

  exec: (command, arg) ->
    document.execCommand command, false, arg

  afterFormat: ->
    @editor.undoManager.save()
    @editable.trigger "editor:change"
