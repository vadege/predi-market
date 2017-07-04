# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@executeTrade = (user_id, amount, contract_id, timestamp) ->
  check amount, Number
  check contract_id, String
  check user_id, String

  #TODO: Check if user is member of a group that is allowd to trade in this market

  #TODO: Add a parameter that shows the contract.outstanding value as
  #the user thinks it was at the moment of trading. If it does not match
  #the current outstanding, refuse to trade. This needs to be done in
  #addition to some sort of blocking transaction around the doTrade
  #method


  if isNaN amount
    throw new Meteor.Error 403, amount + " is not a number"

  amount = parseInt amount, 10

  if amount is 0
    throw new Meteor.Error 403, "You cannot buy 0 shares"

  # Setup
  user = Meteor.users.findOne {_id: user_id}
  cont = Contracts.findOne {_id: contract_id}
  contracts = Contracts.find({set_id: cont.set_id}).fetch()
  outstanding_before = cont.outstanding
  contractset = Contractsets.findOne {_id: cont.set_id}

  alreadyOwned = user.profile.portfolio[contract_id] or 0
  cash  = user.profile.cash[cont.market_id] or 0
  freeze = 0
  thaw = 0

  if contractset.active and
     not contractset.settled and
     contractset.launchtime < Date.now() < contractset.settletime
    if amount < 0
      frozen_amount = (Math.max(0, alreadyOwned)) + amount
      if (frozen_amount < 0)
        freeze = frozen_amount * -1 * contractset.freeze_amount
    else
      if alreadyOwned < 0
        thaw = Math.min(amount, ( alreadyOwned * -1 ) ) * contractset.freeze_amount

    cost = PriceCalculator.compute_cost contractset, contracts, [{id: contract_id, move: amount }]
    total_cost = cost + freeze - thaw

    # Update user
    if cash? and cash > total_cost
      new_cash_entry = {}
      new_port_entry = {}
      new_cash_entry['profile.cash.' + cont.market_id] = cash - total_cost
      new_port_entry['profile.portfolio.' + contract_id] = alreadyOwned + amount
      Meteor.users.upsert { _id: user._id }, {$set: new_cash_entry}
      Meteor.users.upsert { _id: user._id }, {$set: new_port_entry}
    else
      throw new Meteor.Error 403, "You do not have the sufficient funds to complete this trade"

    # Update contract
    Contracts.update {_id: contract_id}, {$inc: {outstanding: amount}}
    contracts = Contracts.find({set_id: cont.set_id}).fetch()

    # Logging
    trade_log_value =
        market_id: cont.market_id
        set_id: cont.set_id
        contract_id: contract_id
        trade_amount: amount
        owned_before: alreadyOwned
        owned_after: alreadyOwned + amount
        outstanding_before: outstanding_before
        outstanding_after: outstanding_before + amount
        cash_before: cash
        cash_after: cash - total_cost - freeze + thaw
        cost: cost
        frozen: freeze
        thawed: thaw
        prices: {}

    contracts.forEach (contract) ->
      trade_log_value.prices[contract._id] =
        Number(PriceCalculator.price contractset, contracts, contract._id
          .toFixed 2
          .replace /\.?0+$/, ""
        )

    trade_log =
      timestamp: timestamp or Date.now()
      user_id: user._id
      type: "trade"
      value: trade_log_value

    Activities.insert trade_log
  else
    throw new Meteor.Error 403, "This contractset is closed"

  amount
