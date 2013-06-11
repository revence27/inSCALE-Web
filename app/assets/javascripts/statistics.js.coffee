# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  deleteableColumns()
  downloadingByDate()

downloadingByDate = () ->
  $('.dater').datepicker({dateFormat: 'dd/mm/yy'})
  link    = $('#exceldownload')
  link.hide()

deleteableColumns = () ->
  for t, i in $('table thead th')
    td  = $(t)
    hd  = $('<a href="javascript://dio.1st.ug/">x</a>')
    hd.attr 'title', "Hide the '#{td.text()}' column"
    hd.attr 'colpos', i
    hd.click((evt) ->
      sth = $(evt.target)
      pos = parseInt(sth.attr('colpos'))
      thd = sth.parent()
      tbl = thd.parent().parent().parent()
      for r in $('tr', tbl)
        for c, x in $('td', r)
          if pos == x
            $(c).hide('fast')
      thd.hide()
    )
    td.append ' '
    td.append hd
