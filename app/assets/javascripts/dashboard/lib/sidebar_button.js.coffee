$ ->
  if $('#sidebar-toggle').length
    $('#sidebar-toggle').on 'click', ->
      $('#topbar').toggleClass('show-sidebar')
      $(this).toggleClass('actived')

    $('#sidebar-background').on 'click', ->
      $('#topbar').removeClass('show-sidebar')
      $('#sidebar-toggle').removeClass('actived')

$(document).on 'page:receive', ->
  $('#topbar').removeClass('show-sidebar')
  $('#sidebar-toggle').removeClass('actived')
