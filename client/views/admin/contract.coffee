# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3


Template.AdminContract.helpers
  hint: ->
    value = Contracts.findOne({_id: @_id}, {fields: { hints: 1 }})
    return value.hints

  opened: ->
    Contractsets.find(
      $and: [{_id: @set_id},
             {launchtime: {$lte: Date.now()}}]).count() > 0

  voteshare: ->
    Contractsets.findOne({_id: @set_id}).voteshare

  price: ->
    set = Contractsets.findOne({_id: @set_id})
    contracts = Contracts.find({set_id: set._id}).fetch()

    contracts.forEach (contract) ->
      if contract._id is @_id
        contract.outstanding = contract.outstanding +
                               $("set-start-price-@_id").val()
    PriceCalculator.price set, contracts, @_id
      .toFixed 2
      .replace /\.?0+$/, ""


Template.AdminContract.events
  'change .set-color': (evt, tmpl) ->
    evt.stopPropagation()
    value = evt.target.value
    if (value)
      Meteor.call 'setContractColor', value, @_id, (error, result) ->
        if error
          Errors.throw error
      Deps.flush()
    true
  ,
  'click .remove_contract': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'removeContract', @_id, (error, result) ->
      if error
        Errors.throw error
    Deps.flush()
    true

  'click .add_hint': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'addHint', @_id, (error,result) ->
      if error
        Errors.throw error
    Deps.flush()
    true

  'click .save_hint': (evt, tmpl) ->
    evt.stopPropagation()
    console.log(Session.get 'hintArr')
