$ ->
  $("body").keyup (event) ->
    if event.which is 37 and $(".paging .left > a").length
      location.replace $(".paging .left >a").attr("href")
    else if event.which is 39 and $(".paging .right > a").length
      location.replace $(".paging .right >a").attr("href")
