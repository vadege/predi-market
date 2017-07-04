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
      Router.go '/market/' + @_id

Template.MarketList.created = ->
  markets = Markets.find().fetch()
  if markets.length is 1
    Router.go '/market/' + markets[0]._id
