COLOUR_LIST = ['#993333', '#b3b3b3', '#a9a9a9', '#737373', '#333333']

$ ->
  deleteableColumns()
  downloadingByDate()
  doTheRounds(['/statics/images/kids1.jpg'
    '/statics/images/kids2.jpg'
    '/statics/images/kids3.jpg'
    '/statics/images/kids4.jpg'
    '/statics/images/kids5.jpg'
    # '/statics/images/kids6.jpg'
    ], 10000)

drawTimeCreeper = () ->
  markSkeletons()
  targ      = $('#usagediv').get(0)
  return unless targ
  genTable  = ([x, Math.random() * 30 * (x % 12)] for x in [0 .. 23])
  data      = new google.visualization.arrayToDataTable(genTable)
  chart     = new google.visualization.ScatterChart targ
  chart.draw(data,
    {
      title: 'Chart of Submission Times',
      hAxis: {title: 'Time of the Day', maxValue: 23},
      vAxis: {title: 'Number of Submissions', maxValue: 230},
      fontName: 'Quattrocento Sans', colors: COLOUR_LIST
    })

markSkeletons = () ->
  for sk in $('.skel')
    skel    = $(sk)
    tds     = $('td', sk)
    it      = $(tds[2])
    chosen  = ['&#9925;', '&#9785;', '&#9733;'][Math.floor((Math.random() * 3))]
    it.append $('<br /><span class="tabalert">☠</span> <span class="tabalert">&#128137;</span> <span class="tabalert">' + chosen + '</span>')
    pie     = google.visualization.arrayToDataTable([
      ['Baby Gender', 'Number'],
      ['Male',    parseInt($(tds[7]).text())],
      ['Female',  parseInt($(tds[8]).text())],
    ])
    canv  = $('<div></div>')
    $(tds[2]).append(canv)
    chart = new google.visualization.PieChart(canv.get(0))
    chart.draw(pie, {title: 'Genders'})

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
