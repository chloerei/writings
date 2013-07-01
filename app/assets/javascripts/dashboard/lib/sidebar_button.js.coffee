page_ready ->
  if $('#sidebar-button').length
    $('#sidebar-button').on 'click', ->
      $('#main').toggleClass('show-sidebar')
      $(this).toggleClass('actived')

    $('#main-sidebar-background').on 'click', ->
      $('#main').removeClass('show-sidebar')
      $('#sidebar-button').removeClass('actived')
