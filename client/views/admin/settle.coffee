# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

sum_prices = ->
  vals = Session.get 'settling_prices'
  _.reduce(_.values(vals), (memo, val) ->
    memo + parseFloat val
  , 0)

Template.AdminSettle.helpers
  Contracts: ->
    set_id = Session.get 'settling'
    Contracts.find {$and: [{set_id: set_id}
                           {mirror: {$not: true}}]}

  contract_id: ->
    @_id

  price: ->
    prices = Session.get 'settling_prices'
    unless prices
      prices = {}
      set = Contractsets.findOne({_id: @set_id})
      contracts = Contracts.find({set_id: set._id}).fetch()

      contracts.forEach (contract) ->
        prices[contract._id] =
          PriceCalculator.price set, contracts, contract._id
            .toFixed 2
            .replace /\.?0+$/, ""
        Session.set 'settling_prices', prices
    prices[@_id]

  correct_amount: ->
    sum_prices() is 100

Template.AdminSettle.events
  'click .do_settle': (evt, tmpl) ->
    evt.stopPropagation()
    vals = Session.get 'settling_prices'
    confirmed = true
    sum = sum_prices()
    if sum != 100
      warning_message = TAPi18n.__ "settle_incorrect_sum_warning", sum
      confirmed = confirm warning_message

    if confirmed and @_id
      Meteor.call 'settleContractset', @_id, vals, (error, result) ->
        if error
          Errors.throw error.message
        else
          Session.set 'settling', undefined
      Deps.flush()
    true

  'click .cancel_settle': (evt, tmpl) ->
    evt.stopPropagation()
    Session.set 'settling', undefined
    Session.set 'settling_prices', undefined

  'change .input-range-set-field': (evt, tmpl) ->
    prices = Session.get 'settling_prices'
    contract_id = evt.target.id.split('-')[2] or undefined
    value = evt.target.value
    contract_ids = _.keys prices
    prices = _.reduce contract_ids, (memo, id) ->
      if id is contract_id
        memo[id] = value
      else if contract_ids.length is 2
        memo[id] = 100 - value
      return memo
    , prices

    Session.set 'settling_prices', prices
