#= require_self
#= require_tree ./locales

@I18n =
  setLocale: (@locale) ->

  defaultLocale: 'zh-CN'

  t: (key, params...) ->
    locale = I18n[@locale or @defaultLocale][key]
    if typeof locale is 'function'
      locale(params)
    else
      locale
