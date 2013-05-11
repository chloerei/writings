AlertMessage =
  show: (options = {}) ->
    @messageBox = $('#alert-messages')
    if !@messageBox.length
      @messageBox = $('<div id="alert-messages">').appendTo($('body'))

    icon_type = switch options.type
      when 'loading'
        'icon-spinner icon-spin'
      when 'error'
        'icon-minus-sign'
      when 'success'
        'icon-ok-sign'
      when 'notice'
        'icon-info-sign'

    message = $("<div class='alert-message alert-#{options.type}'>
                   <i class='#{icon_type}'></i>
                   #{options.text}
                 </div>")

    if options.id
      message.prop('id', options.id)

    if !options.timeout and !options.keep
      closeButton = $("<i class='icon-remove'></i>").appendTo(message).on 'click', ->
        message.remove()

    @messageBox.append(message)

    if options.timeout
      setTimeout ->
        message.remove()
      , options.timeout

  remove: (id) ->
    $("##{id}").remove()

  clearAll: ->
    $(".alert-message").remove()

@AlertMessage = AlertMessage
