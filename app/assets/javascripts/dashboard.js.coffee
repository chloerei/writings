#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require mousetrap
#= require jquery-fileupload/vendor/jquery.ui.widget
#= require jquery-fileupload/jquery.iframe-transport
#= require jquery-fileupload/jquery.fileupload
#= require locales
#= require editor
#= require_tree ./editor_plugin
#= require_tree ./lib
#= require_tree ./dashboard

$ ->
  I18n.setLocale($('html').attr('lang'))
  # Client Side Validations - Turbolinks
  $(document).on "page:change", ->
    $("form[data-validate]").validate()

  $(document).on("page:fetch", ->
    AlertMessage.show
      type: 'loading',
      text: I18n.t('loading')
      keep: true
      scope: 'page-loading'
  ).on "page:change", ->
    AlertMessage.remove('page-loading')

  $(document).on("ajax:before", ->
    AlertMessage.show
      type: 'loading'
      text: I18n.t('sending')
      keep: true
      scope: 'ajax-sending'
  ).on("ajax:error", (xhr, status, error) ->
    AlertMessage.show
      type: 'error'
      text: I18n.t('server_error')
  ).on("ajax:complete", ->
    AlertMessage.remove('ajax-sending')
  )
