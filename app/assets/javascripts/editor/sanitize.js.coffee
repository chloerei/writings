class @Editor.Sanitize
  constructor: (@editor) ->
    @editable = @editor.editable

  run: ->
    @sanitizeDiv()
    @sanitizeTag()
    @sanitizeAttr()
    @sanitizeBlockElement()
    @sanitizeHeader()
    @sanitizeCode()
    @sanitizeList()

  tagWhiteList: ["p", "br", "img", "a", "b", "i", "strike", "u", "h1", "h2", "h3", "h4", "pre", "code", "ol", "ul", "li", "blockquote"]
  attrWhiteList:
    p: ["id"]
    h1: ["id"]
    h2: ["id"]
    h3: ["id"]
    h4: ["id"]
    pre: ["id"]
    li: ["id"]
    a: ["href", "title"]
    img: ["src", "title", "alt"]

  sanitizeDiv: ->

    # replace div to p
    @editable.find("div").each ->
      $(this).replaceWith $("<p>").append($(this).contents())


  sanitizeTag: ->

    # stript not allow tags
    @editable.find(":not(" + @tagWhiteList.join() + ")").each ->
      $element = $(this)
      if $element.contents().length
        $element.replaceWith $element.contents()
      else
        $element.remove()


  sanitizeAttr: ->
    _this = this

    # remove all attribute not in attrWhiteList
    tags = $.map(@attrWhiteList, (attrs, tag) ->
      tag
    )
    @editable.find(":not(" + tags.join() + ")").each ->
      $element = $(this)
      attributes = $.map(@attributes, (item) ->
        item.name
      )
      $.each attributes, (i, name) ->
        $element.removeAttr name



    # remove attributes not in white list for attrWhiteList
    $.each @attrWhiteList, (tag, attrList) ->
      _this.editable.find(tag).each ->
        $element = $(this)
        attributes = $.map(@attributes, (item) ->
          item.name
        )
        $.each attributes, (i, name) ->
          $element.removeAttr name  if $.inArray(name, attrList) is -1




  sanitizeBlockElement: ->
    _this = this

    # flatten nested block element
    @editable.find(@blockElementSelector).each ->
      _this.flattenBlock this


    # blockquote as a document
    @editable.find("> blockquote").find(@blockElementSelector).each ->
      _this.flattenBlock this


  blockElementSelector: "> p, > h1, > h2, > h3, > h4"
  flattenBlock: (element) ->
    _this = this
    hasTextNode = $(element).contents().filter(->
      @nodeType isnt 1
    ).length
    hasInline = $(element).find("> :not(p, h1, h2, h3, h4, ul, ol, pre, blockquote)").length
    if hasTextNode or hasInline

      # stript block
      @flattenBlockStript element
    else
      # stript children
      $(element).children().each ->
        _this.flattenBlock this

      $(element).replaceWith $(element).contents()

  flattenBlockStript: (element) ->
    if $(element).is(":not(ul, ol)")
      $(element).find(":not(code, a, img, b, strike, i, br)").each ->
        $(this).replaceWith $(this).contents()


  sanitizeHeader: ->
    @editable.find("h1, h2, h3, h4").find(":not(i, strike, u, a)").each ->
      $(this).replaceWith $(this).contents()


  sanitizeCode: ->
    _this = this
    @editable.find("pre").each ->
      $(this).append $("<code>").append($(this).contents())  if $(this).find("> code").length is 0

    @editable.find("code").each ->
      _this.striptCode this


  striptCode: (code) ->
    $(code).find("p, h1, h2, h3, h4, blockquote, pre").each ->
      $(this).replaceWith $(this).text() + "\n"

    $(code).children().each ->
      $(this).replaceWith $(this).text()


  sanitizeList: ->
    _this = this
    @editable.find("li").each ->
      $li = $(this)

      # stript p
      $li.find(":not(code, a, img, b, strike, i, br)").each ->
        $(this).append "<br>"  if $(this).next().length
        $(this).replaceWith $(this).contents()
