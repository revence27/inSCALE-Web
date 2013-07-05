var deleteableColumns, downloadingByDate;

$(function() {
  deleteableColumns();
  return downloadingByDate();
});

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
