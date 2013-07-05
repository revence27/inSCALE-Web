var COLOUR_LIST, deleteableColumns, doTheRounds, downloadingByDate, drawMonthCreeper, drawTimeCreeper, markSkeletons;

COLOUR_LIST = ['#993333', '#b3b3b3', '#a9a9a9', '#737373', '#333333'];

$(function() {
  deleteableColumns();
  downloadingByDate();
  return doTheRounds(['/statics/images/kids1.jpg', '/statics/images/kids2.jpg', '/statics/images/kids3.jpg', '/statics/images/kids4.jpg', '/statics/images/kids5.jpg'], 10000);
});

drawTimeCreeper = function() {
  var chart, data, targ, x, y, _ref;
  drawMonthCreeper();
  markSkeletons();
  targ = $('#usagediv').get(0);
  if (!targ) return;
  data = new google.visualization.DataTable({
    cols: [
      {
        label: 'Hour',
        type: 'timeofday'
      }, {
        label: 'Submissions',
        type: 'number'
      }
    ]
  });
  for (x = 0; x <= 23; x++) {
    for (y = 0, _ref = Math.floor(10 * Math.random()); 0 <= _ref ? y <= _ref : y >= _ref; 0 <= _ref ? y++ : y--) {
      data.addRow([[x, y, 0, 0], Math.random() * 30 * (x % (Math.random() * 12))]);
    }
  }
  chart = new google.visualization.ScatterChart(targ);
  return chart.draw(data, {
    title: 'Chart of Submission Times',
    hAxis: {
      title: 'Time of the Day',
      maxValue: 23
    },
    vAxis: {
      title: 'Number of Submissions',
      maxValue: 230
    },
    fontName: 'Quattrocento Sans',
    colors: COLOUR_LIST
  });
};

drawMonthCreeper = function() {
  var chart, curt, genTable, secs, targ, val, x;
  targ = $('#monthsdiv').get(0);
  if (!targ) return;
  genTable = new google.visualization.DataTable();
  genTable.addColumn('date', 'Period');
  genTable.addColumn('number', 'Submissions');
  genTable.addColumn('number', 'Punctual Submissions');
  for (x = 0; x <= 52; x++) {
    val = Math.random() * 300 * (x % 12);
    secs = (52 - x) * (60 * 60 * 24 * 7 * 1000);
    curt = new Date().getTime();
    genTable.addRow([new Date(curt - secs), val, val * Math.random()]);
  }
  chart = new google.visualization.LineChart(targ);
  return chart.draw(genTable, {
    title: 'Weekly Activity for the Year',
    vAxis: {
      title: 'Total Submissions (Week)'
    },
    hAxis: {
      title: 'Period'
    },
    fontName: 'Quattrocento Sans',
    colors: COLOUR_LIST
  });
};

markSkeletons = function() {
  var canv, chart, chosen, it, pie, sk, skel, tds, _i, _len, _ref, _results;
  _ref = $('.skel');
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    sk = _ref[_i];
    skel = $(sk);
    tds = $('td', sk);
    it = $(tds[2]);
    chosen = ['&#9925;', '&#9785;', '&#9733;'][Math.floor(Math.random() * 3)];
    it.append($('<br /><span class="tabalert">☠</span> <span class="tabalert">&#128137;</span> <span class="tabalert">' + chosen + '</span>'));
    pie = google.visualization.arrayToDataTable([['Baby Gender', 'Number'], ['Male', parseInt($(tds[7]).text())], ['Female', parseInt($(tds[8]).text())]]);
    canv = $('<div></div>');
    $(tds[2]).append(canv);
    chart = new google.visualization.PieChart(canv.get(0));
    _results.push(chart.draw(pie, {
      title: 'Genders',
      colors: COLOUR_LIST
    }));
  }
  return _results;
};

doTheRounds = function(lst, pause) {
  var notForNaught, r, rnd, _i, _len, _ref;
  notForNaught = false;
  _ref = $('.dotherounds');
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    rnd = _ref[_i];
    notForNaught = true;
    r = $(rnd);
    r.css('background', "url('" + lst[Math.floor(Math.random() * lst.length)] + "')");
  }
  if (notForNaught) return setTimeout(doTheRounds, pause, lst, pause);
};

downloadingByDate = function() {
  var link;
  $('.dater').datepicker({
    dateFormat: 'dd/mm/yy'
  });
  link = $('#exceldownload');
  return link.hide();
};

deleteableColumns = function() {
  var hd, i, t, td, _len, _ref, _results;
  _ref = $('.largetable thead th');
  _results = [];
  for (i = 0, _len = _ref.length; i < _len; i++) {
    t = _ref[i];
    td = $(t);
    hd = $('<a href="javascript://dio.1st.ug/">x</a>');
    hd.attr('title', "Hide the '" + (td.text()) + "' column");
    hd.attr('colpos', i);
    hd.click(function(evt) {
      var c, pos, r, sth, tbl, thd, x, _i, _len2, _len3, _ref2, _ref3;
      sth = $(evt.target);
      pos = parseInt(sth.attr('colpos'));
      thd = sth.parent();
      tbl = thd.parent().parent().parent();
      _ref2 = $('tr', tbl);
      for (_i = 0, _len2 = _ref2.length; _i < _len2; _i++) {
        r = _ref2[_i];
        _ref3 = $('td', r);
        for (x = 0, _len3 = _ref3.length; x < _len3; x++) {
          c = _ref3[x];
          if (pos === x) $(c).hide('fast');
        }
      }
      return thd.hide();
    });
    td.append(' ');
    _results.push(td.append(hd));
  }
  return _results;
};
