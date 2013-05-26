class ArticleEdit.NoteManager
  constructor: (@manager) ->
    @article = @manager.article
    @space = @manager.space

    @notes = $('#notes')
    @ids = []

    @updateNoteContext()

    @article.find('img').one 'load', =>
      @updateNoteContext()

    @manager.editor.editable.on 'editor:change', =>
      @updateNoteContext()
      @article.find('img').one 'load', =>
        @updateNoteContext()

  updateNoteContext: ->
    _this = this
    @currentIds = []
    @article.find('p, h1, h2, h3, h4, pre, li').each ->
      if this.id is '' or $("##{this.id}")[0] isnt this
        this.id = Math.random().toString(36).substring(2, 10)
      _this.currentIds.push this.id

    # remove
    for id in @ids when @currentIds.indexOf(id) < 0
      $("#note-context-#{id}").remove()

    # new
    for id in @currentIds
      element = $("##{id}")
      context = $("#note-context-#{id}")
      if !context.length
        context = $("<div id='note-context-#{id}' class='note-context'>")
        context.append('<a class="add-note-button"><i class="icon-pushpin"></i></a>')
        @notes.append(context)

      top = element.position().top + parseInt(element.css('margin-top'))
      context.css( top: "#{top}px" )

    @ids = @currentIds
