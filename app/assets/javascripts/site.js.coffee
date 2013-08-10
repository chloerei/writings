#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require jquery.turbolinks
#= require lib/highlight
#= require lib/google_analytics

$ ->
  $("pre code").each ->
    hljs.highlightBlock this

  googleAnalyticsID = $('meta[name=google-analytics]').prop('content')
  spaceGoogleAnalyticsID = $('meta[name=space-google-analytics]').prop('content')

  path = window.location.protocol + '//' + window.location.hostname + window.location.pathname + window.location.search

  if googleAnalyticsID isnt ''
    ga('create', googleAnalyticsID)
    ga('send', 'pageview', { location: path })
  if spaceGoogleAnalyticsID isnt ''
    ga('create', spaceGoogleAnalyticsID, { name: 'spaceTracker' })
    ga('spaceTracker.send', 'pageview', { location: path })
