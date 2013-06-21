page_ready ->
  if $('#articles-index').length
    $('.articles').on 'click', 'a.select-category', ->
      article = $(this).closest('.article')
      form = $('#select-category-form')
      form.prop('action', "/~#{form.data('space')}/articles/#{article.data('id')}/category")
      form.find('[name*=category_id]').val(article.data('category-id'))

    $('#add-category-form').on 'ajax:success', (event, data) ->
      form = $('#select-category-form')
      form.find('[name*=category_id]').append("<option value=#{data.token}>#{data.name}</option>").val(data.token)
      Dialog.hide "#add-category-modal"

    $('#select-category-form').on 'ajax:success', ->
      Dialog.hide '#select-category-modal'
