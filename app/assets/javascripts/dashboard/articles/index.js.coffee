page_ready ->
  if $('#articles-index').length
    $('.articles').on 'click', 'a.select-category', ->
      article = $(this).closest('.article')
      form = $('#select-category-form')
      form.prop('action', "/~#{form.data('space')}/articles/#{article.data('id')}/category")
      form.find('.dropdown-toggle').text(article.data('category-name'))
      form.find('#select-category-id-input').val(article.data('category-id'))

    $('#add-category-form').on 'ajax:success', (event, data) ->
      li = $("<li><a href=\"#\">")
      li.find("a").text(data.name).data("category-id", data.urlname)
      $("#select-category-form .dropdown-menu").prepend li
      $("#select-category-form .dropdown-toggle").text data.name
      $("#select-category-id-input").val data.urlname
      Dialog.hide "#add-category-modal"

    $('#select-category-form').on 'ajax:success', ->
      Dialog.hide '#select-category-modal'

    $("#select-category-form .dropdown").on "click", ".dropdown-menu li a", (event) ->
      event.preventDefault()
      item = $(this)
      item.closest(".dropdown").find(".dropdown-toggle").text item.text()
      $("#select-category-id-input").val(item.data("category-id"))
