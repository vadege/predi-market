# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@addContractset = (market_id, contractset, timestamp) ->
  check contractset, Match.ObjectIncluding(
    title: String
    description: String
    liquidity: Number
    max_price: Number
    min_price: Number
    launchtime: Number
    settletime: Number
    freeze_amount: Number
    voteshare: Boolean
    active: Boolean
    settled: Boolean
  )

  _.each _.values(contractset), (val) ->
    if typeof val is "number" and isNaN val
      throw new Meteor.Error 403, val + " is not a number"

  cs = _.extend contractset, {market_id: market_id}
  translations = @placeholderTranslations ["title", "description"]
  contractset_id = Contractsets.insertTranslations cs, translations

  create_log =
    timestamp: timestamp or Date.now()
    user_id: "system"
    type: "createcontractset"
    value: _.extend cs, {contractset_id: contractset_id}
  Activities.insert create_log

  contractset_id

@removeContractsetsInMarket = (market_id) ->
  numopen = Contractsets.find(
    $and: [{market_id: market_id},
           {launchtime: {$lte: Date.now()}}]
  ).count()

  if numopen > 0
    throw new Meteor.Error 403, "Cannot delete market with opened contractsets"

  @removeContractsInMarket market_id
  Contractsets.remove {market_id: market_id}

  remove_log =
    timestamp: Date.now()
    user_id: "system"
    type: "deletecontractsetsinmarket"
    value: {
      market_id: market_id
    }
  Activities.insert remove_log

@removeContractset = (contractset_id) ->
  numopen = Contractsets.find(
    $and: [{_id: contractset_id},
           {launchtime: {$lte: Date.now()}}]
  ).count()

  if numopen > 0
    throw new Meteor.Error 403, "Cannot delete contractset that is open"

  @removeContractsInContractset contractset_id
  Contractsets.remove({_id: contractset_id})

  remove_log =
    timestamp: Date.now()
    user_id: "system"
    type: "deletecontractset"
    value: {
      contractset_id: contractset_id
    }
  Activities.insert remove_log

@settleContractset = (contractset_id, prices) ->
  set = Contractsets.findOne {_id: contractset_id}
  market = Markets.findOne {_id: set.market_id}
  contracts = Contracts.find({set_id: set._id}).fetch()
  now = Date.now()
  users = _.flatten(_.map market.tags, (tag) ->
    Meteor.users.find({'profile.tags': {$in: [tag]}}).fetch()
  )
  pricevals = _.values prices

  active = set.active
  running = set.settletime < now

  if (running or active) and (not (running and active))
    throw new Meteor.Error 403, "Cannot settle open contractsets"
  if set.settled
    throw new Meteor.Error 403, "Cannot settle already settled contractsets"
  if pricevals.length isnt contracts.length
    throw new Meteor.Error 403, "The wrong number (" + pricevals.length + ") of
  finishing prices was passed. It should be " + contracts.length

  payed = {}
  _.each _.uniq(users), (user, index, list) ->
    _.each contracts, (contract, index, list) ->
      payed[user._id] = (payed[user._id] or 0) + buyBackShares user._id, contract, prices[contract._id]

  Contractsets.update {_id: contractset_id}, {$set: {settled: true}}

  settle_log =
    timestamp: Date.now()
    user_id: "system"
    type: "settled_contractset"
    value: {set_id: contractset_id, prices: prices, payed: payed}

  Activities.insert settle_log
