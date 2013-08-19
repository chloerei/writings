#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require jquery.turbolinks
#= require lib/dropdown
#= require lib/highlight
#= require lib/google_analytics

analyticsReferrer = document.referrer

$ ->
  $("pre code").each ->
    hljs.highlightBlock this

  googleAnalyticsID = $('meta[name=google-analytics]').prop('content')
  spaceGoogleAnalyticsID = $('meta[name=space-google-analytics]').prop('content')

  path = window.location.protocol + '//' + window.location.hostname + window.location.pathname + window.location.search

  if googleAnalyticsID? && googleAnalyticsID isnt ''
    ga('create', googleAnalyticsID)
    ga('set', 'referrer', analyticsReferrer)
    ga('send', 'pageview', { location: path })

  if spaceGoogleAnalyticsID? && spaceGoogleAnalyticsID isnt ''
    ga('create', spaceGoogleAnalyticsID, { name: 'spaceTracker' })
    ga('spaceTracker.set', 'referrer', analyticsReferrer)
    ga('spaceTracker.send', 'pageview', { location: path })

  # Referrer no change in Turbolink
  analyticsReferrer = null
