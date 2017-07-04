# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.Leaderboard.helpers
  to_fixed: (num) ->
    num.toFixed(2)

  markets: ->
    market = undefined
    current_route = Router.current()
    market_id = current_route?.params?._id
    if market_id is "*"
      market = Markets.findOne()
    else
      market = Markets.findOne {_id: market_id}
    current_id = market._id

    markets = _.map Markets.find().fetch(), (m) ->
      if m._id is current_id
        m.link = false
      else
        m.link = m._id
      return m

    if markets.length > 1
      markets
    else
      undefined



  leaders: ->
    market = undefined
    current_route = Router.current()
    market_id = current_route?.params?._id
    if market_id is "*"
      market = Markets.findOne()
    else
      market = Markets.findOne {_id: market_id}

    contracts_with_prices = GlobalHelpers.contracts_with_prices market._id
    GlobalHelpers.users_with_worth market, contracts_with_prices
