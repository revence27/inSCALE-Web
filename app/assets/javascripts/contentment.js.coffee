# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  doTheRounds(['/assets/kids1.jpg'
    '/assets/kids2.jpg'
    '/assets/kids3.jpg'
    '/assets/kids4.jpg'
    '/assets/kids5.jpg'
    # '/assets/kids6.jpg'
    ], 10000)
  makeRowsResponsive()

doTheRounds = (lst, pause) ->
  notForNaught    = false
  for rnd in $('.dotherounds')
    notForNaught  = true
    r             = $(rnd)
    r.css 'background', "url('#{lst[Math.floor(Math.random() * lst.length)]}')"
  setTimeout(doTheRounds, pause, lst, pause) if notForNaught
