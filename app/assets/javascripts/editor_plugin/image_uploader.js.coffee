class @Editor.ImageUploader
  constructor: (@editor) ->
    @editor.formator.image = =>
      @open()

    @modal = $('#image-uploader-modal')
    @linkButton = $('#image-link-button')
    @urlInput = $('#attachment_remote_file_url')
    @linkForm = $('#image-link-form')
    @uploadForm = $('#image-upload-form')

    @bindActions()

  open: ->
    Dialog.show(@modal)

  close: ->
    Dialog.hide(@modal)

  insertImage: (url)->
    @editor.restoreRange()
    @editor.formator.exec 'insertImage', url
    @editor.formator.afterFormat()

  bindActions: ->
    @linkButton.on 'click', (event) =>
      event.preventDefault()
      if @urlInput.val() isnt ''
        @insertImage(@urlInput.val())
        @close()
        @resetLinkForm()

    @urlInput.on 'keyup', =>
      if @urlInput.val() isnt ''
        @linkPreview()
      else
        @resetLinkForm

    @linkForm.on 'submit', (event) =>
      event.preventDefault()
      $.ajax(
        url: @linkForm.attr('action')
        data: @linkForm.serializeArray()
        type: 'post'
        dataType: 'json'
      ).done( (data) =>
        @insertImage(data.files[0].url)
        @close()
        @updateStrageStatus(data)
      ).fail( (xhr) =>
        AlertMessage.show
          type: 'error'
          text: JSON.parse(xhr.responseText).message
      ).always( =>
        @resetLinkForm()
      )

    @uploadForm.fileupload
      dataType: 'json'
      dropZone: $('#image-upload-form .dropable, #editarea article')

      add: (event, data) =>
        @uploadPreview(data)
        $('#image-upload .filename').text(data.files[0].name)
        $('#image-upload-form').off('submit')
        if $('#image-modal').is(':hidden')
          data.submit()
        else
          $('#image-upload-form').on 'submit', (event) ->
            event.preventDefault()
            data.submit()

      start: ->
        $('#image-upload .message').hide()
        $('#image-upload .progress').show()
        $('#image-upload .dropable').addClass('start')
        AlertMessage.show
          type: 'loading'
          text: I18n.t('loading')
          scope: 'image-upload'

      progressall: (event, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        $('#image-upload .progress .bar').css('width', progress + '%')

      fail: (event, data) ->
        AlertMessage.show
          type: 'error'
          text: JSON.parse(xhr.responseText).message

      done: (event, data) =>
        @insertImage(data.result.files[0].url)
        @close()
        @updateStrageStatus(data.result)
        AlertMessage.show
          type: 'success'
          text: I18n.t('success')
          timeout: 1500

      always: (event, data) =>
        AlertMessage.remove('image-upload')
        @resetUploadForm()

  updateStrageStatus: (data) ->
    $('#image-modal .storage-status .used').text(data.storage_status.used_human_size)
    $('#image-modal .storage-status .limit').text(data.storage_status.limit_human_size)

  linkPreview: ->
    $('#image-link-form .preview').css('background-image', 'url(' + $('#attachment_remote_file_url').val() + ')')
    $('#image-link-form .message').hide()

  resetLinkForm: () ->
    $('#attachment_remote_file_url').val('')
    $('#image-link-form .preview').css('background-image', 'none')
    $('#image-link-form .message').show()

  uploadPreview: (data) ->
    if (window.FileReader)
      if /(jpg|jpeg|gif|png)/i.test(data.files[0].name)
        reader = new FileReader()
        reader.onload = (event) ->
          $('#image-upload .message').hide()
          $('#image-upload-form .dropable').css('background-image', 'url(' + event.target.result + ')')

        reader.readAsDataURL(data.files[0])
      else
        $('#image-upload-form .dropable').css('background-image', 'none')
        $('#image-upload .message').show()

  resetUploadForm: () ->
    $('#image-upload .filename').text('')
    $('#image-upload-form').off('submit')
    $('#image-upload .progress').hide()
    $('#image-upload .progress .bar').css('width', '0%')
    if window.FileReader
      $('#image-upload-form .dropable').css('background-image', 'none')
    $('#image-upload .message').show()
    $('#image-upload .dropable').removeClass('start')
