#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require mousetrap
#= require jquery-fileupload/vendor/jquery.ui.widget
#= require jquery-fileupload/jquery.iframe-transport
#= require jquery-fileupload/jquery.fileupload
#= require_tree ./sitewide
#= require_tree ./dashboard

$ ->
  # Client Side Validations - Turbolinks
  $(document).on "page:change", ->
    $("form[data-validate]").validate()

  $(document).on("page:fetch", ->
    $("#spinner").show()
  ).on "page:restore", ->
    $("#spinner").hide()

  $(document).on("ajax:before", ->
    AlertMessage.show
      type: 'loading'
      text: 'Loading...'
      keep: true
      id: 'ajax_loading'
  ).on("ajax:success", ->
    AlertMessage.show
      type: 'success'
      text: "Success"
      timeout: 1500
  ).on("ajax:error", (xhr, status, error) ->
    try
      data = $.parseJSON(status.responseText)
      AlertMessage.show
        type: 'error'
        text: data.message or "Error"
    catch err
      AlertMessage.show
        type: 'error'
        text: "Server Error"
  ).on("ajax:complete", ->
    AlertMessage.remove('ajax_loading')
  )
