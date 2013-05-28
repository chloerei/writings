class ArticleEdit.NoteManager
  constructor: (@manager) ->
    @article = @manager.article
    @space = @manager.space

    @notes = $('#notes')
    @ids = []
    @noteCounts = {}

    @updateNoteContext()
    @article.find('img').one 'load', =>
      @updateNoteContext()

    @bindActions()

  bindActions: ->
    @manager.editor.editable.on 'editor:change', =>
      @updateNoteContext()
      @article.find('img').one 'load', =>
        @updateNoteContext()

    @manager.article.on 'click', 'p, h1, h2, h3, h4, pre, li', ->
      if this.id
        $("#note-context-#{this.id}").addClass('show-on-click').siblings().removeClass('show-on-click')

    _this = this
    $('#notes').on 'click', '.add-note-button', ->
      _this.openContext($(this).closest('.note-context').data('element-id'))
      $('#editwrap').addClass('show-notes')

    $('#notes').on 'click', '.close-button', ->
      $(this).closest('.note-context').removeClass('actived').find('.note-context-content').remove()
      $('#editwrap').removeClass('show-notes')

    @article.on 'updateStatus', (event, data) =>
      @updateStatus(data)

    @notes.on 'ajax:before', 'form', ->
      $(this).find('[name*=body]').val($(this).find('.body').html())

    @notes.on 'click', '.note-cancel-button', ->
      note = $(this).closest('.note-card-comment')
      note.find('.dropdown').removeClass('hide')
      note.find('.note-card-body').removeClass('hide')
      note.find('form').remove()

    @notes.on 'click', '.new-note-comment .body', ->
      $(this).closest('.new-note-comment').addClass('actived')
    @notes.on 'click', '.comment-cancel-button', ->
      $(this).closest('.new-note-comment').removeClass('actived').find('.body').html('')

  openContext: (id) ->
    $("#note-context-#{id}").siblings().removeClass('actived').find('.note-context-content').remove()

    $.ajax(
      url: "/~#{@space}/notes/new?article_id=#{@article.data('id')}&element_id=#{id}"
      dataType: 'script'
    )

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
        context = $("<div id='note-context-#{id}' class='note-context'>").data('element-id', id)
        context.html(@addNoteButton(id))
        @notes.append(context)

      top = element.position().top + parseInt(element.css('margin-top'))
      context.css(
        top: "#{element.position().top}px"
        height: "#{element.innerHeight()}px"
        'padding-top': "#{parseInt(element.css('margin-top'))}px"
        'padding-bottom': "#{parseInt(element.css('margin-bottom'))}px"
      )

    @ids = @currentIds

  addNoteButton: (id) ->
    count = @noteCounts[id]
    "<a class='add-note-button #{if count then 'show'}'>
      <i class='icon-pushpin'></i>
      #{ if count then (count + ' notes...') else 'add note...'}
    </a>"

  updateStatus: (data) ->
    for note in data.notes
      @noteCounts[note.element_id] = note.count

    for id in @currentIds
      $("#note-context-#{id} .add-note-button").replaceWith(@addNoteButton(id))
