#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require jquery.turbolinks
#= require mousetrap
#= require jquery-fileupload/vendor/jquery.ui.widget
#= require jquery-fileupload/jquery.iframe-transport
#= require jquery-fileupload/jquery.fileupload
#= require locales
#= require editor
#= require_tree ./editor_plugin
#= require_tree ./lib
#= require_tree ./dashboard

analyticsReferrer = document.referrer

$ ->
  I18n.setLocale($('html').attr('lang'))

  googleAnalyticsID = $('meta[name=google-analytics]').prop('content')

  path = window.location.protocol + '//' + window.location.hostname + window.location.pathname + window.location.search

  if googleAnalyticsID? && googleAnalyticsID isnt ''
    ga('create', googleAnalyticsID)
    ga('set', 'referrer', analyticsReferrer)
    ga('send', 'pageview', { location: path })

  # Referrer no change in Turbolink
  analyticsReferrer = null


$(document).on
  "page:change": ->
    Mousetrap.reset()

$(document).on 'click', '#blog-button.highlight', ->
  $(this).removeClass('highlight')
  $.post('/read_blog')
