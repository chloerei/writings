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
    $('#notes').on 'click', '.note-add-button', ->
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
      note = $(this).closest('.note-comment')
      note.find('.dropdown').removeClass('hide')
      note.find('.note-body').removeClass('hide')
      note.find('form').remove()

    @notes.on 'click', '.expandable-form .body', ->
      $(this).closest('.expandable-form').addClass('expanded')
    @notes.on 'click', '.expandable-form .cancel-button', ->
      $(this).closest('.expandable-form').removeClass('expanded').find('.body').html('<p><br></p>')

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
    "<a class='note-add-button #{if count then 'show'}'>
      <i class='icon-pushpin'></i>
      <span class='notes-count'>#{ if count then I18n.t('notesCount', count) else I18n.t('addNote') }</span>
    </a>"

  updateStatus: (data) ->
    for note in data.notes
      @noteCounts[note.element_id] = note.count

    for id in @currentIds
      $("#note-context-#{id} .note-add-button").replaceWith(@addNoteButton(id))
