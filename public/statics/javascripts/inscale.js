var COLOUR_LIST, deleteableColumns, doTheRounds, downloadingByDate, drawTimeCreeper, markSkeletons;

COLOUR_LIST = ['#993333', '#b3b3b3', '#a9a9a9', '#737373', '#333333'];

$(function() {
  deleteableColumns();
  downloadingByDate();
  return doTheRounds(['/statics/images/kids1.jpg', '/statics/images/kids2.jpg', '/statics/images/kids3.jpg', '/statics/images/kids4.jpg', '/statics/images/kids5.jpg'], 10000);
});

drawTimeCreeper = function() {
  var chart, data, genTable, targ, x;
  markSkeletons();
  targ = $('#usagediv').get(0);
  if (!targ) return;
  genTable = (function() {
    var _results;
    _results = [];
    for (x = 0; x <= 23; x++) {
      _results.push([x, Math.random() * 30 * (x % 12)]);
    }
    return _results;
  })();
  data = new google.visualization.arrayToDataTable(genTable);
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
