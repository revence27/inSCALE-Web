var doTheRounds;

$(function() {
  return doTheRounds(['/assets/kids1.jpg', '/assets/kids2.jpg', '/assets/kids3.jpg', '/assets/kids4.jpg', '/assets/kids5.jpg'], 10000);
});

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
