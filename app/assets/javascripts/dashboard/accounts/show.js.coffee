page_ready ->
  if $("#accounts-show").length
    $("#account_form").on "ajax:success", (event, data) ->
      $("#user-link").attr "href", "http://" + data.host
