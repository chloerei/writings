$ ->
  $(document).on 'click', '.flash-message .flash-close', ->
    $(this).closest('.flash-message').remove()
