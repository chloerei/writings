$ ->
  if ('#import_tasks-show').length
    $('#select-all').on 'click', ->
      $('#articles input[name="ids[]"]').prop('checked', $(this).prop('checked'))

    $('#articles input[name="ids[]"]').on 'click', ->
      $('#select-all').prop('checked', !$('#articles input[name="ids[]"]:not(:checked)').length)
