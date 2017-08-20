# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

computePrices = (contractset) ->
  prices = []
  contracts = Contracts.find({set_id: contractset._id}).fetch()

  for contract in contracts
    contract.price = Number(PriceCalculator.price contractset, contracts, contract._id
      .toFixed 2
      .replace /\.?0+$/, ""
    )
    prices.push(contract)
  prices

@addContract = (contractset_id, contract, timestamp) ->
  check contract, Match.ObjectIncluding(
    title: String
    outstanding: Number
  )
  if isNaN contract.outstanding
    throw new Meteor.Error 403, contract.outstanding + " is not a number"

  contractset = Contractsets.findOne {_id: contractset_id}
  existing_contracts = Contracts.find({set_id: contractset_id}).fetch()
  contract_id = false

  if contractset.launchtime > Date.now()
    c = _.extend contract, {
      set_id: contractset._id,
      market_id: contractset.market_id
    }
    translations = @placeholderTranslations ["title"]

    if contractset.voteshare
      contract_id = Contracts.insertTranslations c, translations
    else
      if existing_contracts.length is 0
        contract_id = Contracts.insertTranslations c, translations
        mirror = _.extend c, {mirror: true}
        Contracts.insertTranslations mirror, translations
      else
        throw new Meteor.Error 403, "Cannot add more than one probabillity contract per set"

    if contract_id
      prices = computePrices contractset, contract
      contractset.prices = prices
      create_log =
        timestamp: timestamp or Date.now()
        user_id: "system"
        type: "createcontract"
        value: _.extend c, {_id: contract_id}
      Activities.insert create_log
  else
    throw new Meteor.Error 403, "Cannot add contracts to launched contract sets"
  contract_id

@removeContractsInMarket = (market_id) ->
  Contracts.remove {market_id: market_id}
  removeLog =
    timestamp: Date.now()
    user_id: "system"
    type: "deletecontractsinmarket"
    value: {
      market_id: market_id
    }
  Activities.insert removeLog

@removeContractsInContractset = (contractset_id) ->
  Contracts.remove {set_id: contractset_id}
  remove_log =
    timestamp: Date.now()
    user_id: "system"
    type: "deletecontractsincontractset"
    value: {
      set_id: contractset_id
    }
  Activities.insert remove_log

@removeContract = (contract_id) ->
  contract = Contracts.findOne({_id: contract_id})
  contractset = Contractsets.findOne {_id: contract.set_id}
  if contractset.launchtime > Date.now()
    if contractset.voteshare
      Contracts.remove {_id: contract_id}
      remove_log =
        timestamp: Date.now()
        user_id: "system"
        type: "deletecontract"
        value: {
          id: contract_id
        }
      Activities.insert remove_log
    else
      throw new Meteor.Error 403, "Cannot remove probabillity contract"
  else
    throw new Meteor.Error 403, "Cannot remove contract from launched contract sets"

@setContractOutstandingFromPrice = (contract_id, price) ->
  check price, Number
  check contract_id, String

  if isNaN price
    throw new Meteor.Error 403, price + " is not a number"

  contract = Contracts.findOne {_id: contract_id}
  contractset = Contractsets.findOne {_id: contract.set_id}
  contracts = Contracts.find({set_id: contractset._id}).fetch()

  outstanding = PriceCalculator.compute_outstanding contractset, contracts, contract_id, price
  Contracts.update {_id: contract_id}, {$set: {outstanding: outstanding}}
  contracts = Contracts.find({set_id: contractset._id}).fetch()

  price_set_log =
    timestamp: Date.now()
    user_id: "system"
    type: "set_prices"
    value: {}

  price_set_log.value.set_id = contract.set_id
  price_set_log.value.prices = {}
  contracts.forEach (contract) ->
    price_set_log.value.prices[contract._id] =
      Number(PriceCalculator.price contractset, contracts, contract._id
        .toFixed 2
        .replace /\.?0+$/, ""
      )
  Activities.insert price_set_log
