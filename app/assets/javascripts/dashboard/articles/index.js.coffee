page_ready ->
  if $('#articles-index, #articles-trash').length
    $('#new-category-form').on 'ajax:success', (xhr, data) ->
      Turbolinks.visit("/articles/category/#{data.urlname}")
