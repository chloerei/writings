#= require_self
#= require_tree ./locales

@I18n =
  setLocale: (@locale) ->

  defaultLocale: 'zh-CN'

  t: (key, params...) ->
    translator = I18n[@locale] || I18n[@defaultLocale]
    translate = translator[key]
    if translate
      if typeof translate is 'function'
        translate(params)
      else
        translate
    else
      key
