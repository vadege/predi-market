# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.MarketList.helpers
  Markets: ->
    Markets.find()

  filterUntranslatedText: GlobalHelpers.filterUntranslated

Template.MarketList.events
  'click div.market': (evt, tmpl) ->
    evt.stopPropagation()
    if evt.currentTarget isnt undefined
      category = Session.get 'category'
      console.log category
      Router.go '/market/' + @_id + '?' + 'category=' + category
      Session.set 'category', null

Template.MarketList.created = ->
  markets = Markets.find().fetch()
  if markets.length is 1
    category = Session.get 'category'
    Router.go '/market/' + markets[0]._id + '?' + 'category=' + category
    Session.set 'category', null

Template.MarketList.rendered = ->
  ga('send', 'event', 'MarketList', 'read')
