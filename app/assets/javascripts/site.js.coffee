#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require lib/highlight

highlightBlock = ->
  $("pre code").each ->
    hljs.highlightBlock this

$ ->
  highlightBlock()

$(document).on "page:load", ->
  highlightBlock()
