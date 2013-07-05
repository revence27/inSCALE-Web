$ ->
  deleteableColumns()
  downloadingByDate()
  doTheRounds(['/assets/kids1.jpg'
    '/assets/kids2.jpg'
    '/assets/kids3.jpg'
    '/assets/kids4.jpg'
    '/assets/kids5.jpg'
    # '/assets/kids6.jpg'
    ], 10000)

doTheRounds = (lst, pause) ->
  notForNaught    = false
  for rnd in $('.dotherounds')
    notForNaught  = true
    r             = $(rnd)
    r.css 'background', "url('#{lst[Math.floor(Math.random() * lst.length)]}')"
  setTimeout(doTheRounds, pause, lst, pause) if notForNaught

downloadingByDate = () ->
  $('.dater').datepicker({dateFormat: 'dd/mm/yy'})
  link    = $('#exceldownload')
  link.hide()

deleteableColumns = () ->
  for t, i in $('.largetable thead th')
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
