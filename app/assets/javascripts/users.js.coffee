jQuery ->
  $('.select_all').change ->
    checkboxes = $(this).closest('form').find(':checkbox');
    if ($(this).is(':checked'))
        checkboxes.attr checked: 'checked'
    else
        checkboxes.attr checked: null