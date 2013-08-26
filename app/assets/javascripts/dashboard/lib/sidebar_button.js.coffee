$ ->
  if $('#sidebar-toggle').length
    $('#sidebar-toggle').on 'click', ->
      $('#topbar').toggleClass('show-sidebar')
      $(this).toggleClass('actived')

    $('#sidebar-toggle').on 'mouseenter', ->
      $('#topbar').addClass('show-sidebar')
      $(this).addClass('actived')

    $('#sidebar-background').on 'click', ->
      $('#topbar').removeClass('show-sidebar')
      $('#sidebar-toggle').removeClass('actived')
