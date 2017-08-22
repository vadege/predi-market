# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@GlobalHelpers =
  activate_input: (input) ->
    input.focus()
    input.select()
    null

  min_trade: (contractset_id) ->
    contract_id = Session.get 'trading'
    contract = Contracts.findOne {_id: contract_id}
    contractset = Contractsets.findOne {_id: contractset_id}
    contracts = Contracts.find({set_id: contractset_id}).fetch()
    user = Meteor.user()
    cash = user.profile.cash
    cash = user.profile.cash[contract.market_id]
    owned = user.profile.portfolio[contract_id] or undefined
    # (port for port in portfolio when port.id is contract_id)[0]?.owned or undefined
    PriceCalculator.min_trade(
      contractsets,
      contracts,
      contract_id,
      cash,
      owned
    )

  max_trade: (contractset_id) ->
    contract_id = Session.get('order-details')?.contract_id
    contractsets = Contractsets.findOne {_id: contractset_id}
    contracts = Contracts.find({set_id: contractset_id}).fetch()
    contract = Contracts.findOne {_id: contract_id}
    user = Meteor.user()
    cash = user.profile.cash[contract.market_id]
    owned = user.profile.portfolio[contract_id] or undefined
    PriceCalculator.max_trade(
      contractsets,
      contracts,
      contract_id,
      cash,
      owned
    )

  filterUntranslated: (text) ->
    if text is "Not translated"
      if Meteor.user()?.profile?.admin
        ""
      else
        TAPi18n.__ "text_not_translated"
    else
      text

  removeUntranslated: (text) ->
    if text is "Not translated"
      undefined
    else
      text

  users_with_worth: (market, contracts_with_prices) ->
    contractsets = Contractsets.find({market_id: market?._id}).fetch()
    contractsets_by_id = _.groupBy contractsets, (set) ->
      set._id
    uid = Meteor.user()?._id
    _.chain Meteor.users.find({'profile.tags': {$in: market?.tags}}).fetch()
       .map((user) ->
         portfolio = user?.profile?.portfolio
         portfolio_worth = _.chain contracts_with_prices
           .filter (contract) ->
             contract._id in _.keys(portfolio)
           .reduce((sum, contract) ->
             owned = portfolio[contract._id] or 0
             freeze_amount = contractsets_by_id[contract.set_id]?.freeze_amount or 100
             freeze_sum = (Math.min(0, owned)) * freeze_amount
             (sum + (contract.price * owned) - freeze_sum)
           , 0)
           .value()
           user.worth = portfolio_worth + (user?.profile?.cash[market._id] or 0)
           if user._id is uid
             user.me = true
           user
       ).sortBy (user) ->
         0 - parseFloat(user.worth)
       .value()

  contracts_with_prices: (market_id, live_trade) ->
    market_contractsets = Contractsets.find({market_id: market_id}).fetch()

    # Filter contracts for extra security against contracts with deleted
    # contractset Should not be possible, but it has happened
    market_contracts = _.filter Contracts.find({market_id: market_id}).fetch(), (contract) ->
      contract.set_id in _.pluck market_contractsets, "_id"

    console.log market_contracts.length
    unless market_contractsets? and market_contractsets.length > 0
      return []
    if live_trade?
      market_contracts = _.map market_contracts, (contract) ->
        if contract._id in _.keys live_trade
          contract.outstanding += live_trade[contract._id]
        return contract
    market_contracts_by_set = _.groupBy market_contracts, (contract) ->
      return contract.set_id
    market_contractsets_by_set = _.groupBy market_contractsets, (set) ->
      return set._id

    _.map market_contracts, (contract) ->
      if market_contractsets_by_set[contract.set_id]?
        contract.price = PriceCalculator.price market_contractsets_by_set[contract.set_id][0],
                                               market_contracts_by_set[contract.set_id],
                                               contract._id
      return contract

  compute_wallet: (market_id) ->
    wallet = {}
    portfolio = Meteor.user()?.profile?.portfolio
    market = Markets.findOne {_id: market_id}
    contractsets = _.indexBy Contractsets.find({market_id: market_id}).fetch(), (set) ->
      set._id

    user = Meteor.user()
    contracts_with_prices = @contracts_with_prices market_id

    values = _.chain contracts_with_prices
      .filter (contract) ->
        contract._id in _.keys(portfolio)
      .reduce((vals, contract) ->
        owned = user?.profile?.portfolio[contract._id] or 0
        vals.owned = owned + (vals.owned or 0)

        worth = (contract.price * owned)
        vals.portfolio_worth = worth + (vals.portfolio_worth or 0)

        freeze_amount = contractsets[contract.set_id]?.freeze_amount or 0
        freeze_sum = (Math.min(0, owned)) * freeze_amount
        vals.frozen_worth = freeze_sum + (vals.frozen_worth or 0)

        vals
      , {})
      .value()

    cash = (user?.profile?.cash[market_id] or 0)
    net = (values?.portfolio_worth or 0) + cash - (values?.frozen_worth or 0)

    users_with_worth = @users_with_worth market, contracts_with_prices

    wallet =
      frozen: values.frozen_worth
      owned: values.owned
      portfolio_worth: values.portfolio_worth
      net_worth: net
      cash: cash
      users_with_worth: users_with_worth

    wallet
