# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

do_trade = ->
  trade = Session.get('order-details')
  contract_id = trade?.contract_id
  if contract_id?
    market_id = trade?.market_id
    amount = trade.amount
    unless isNaN amount or amount is 0
      user_id = Meteor.user()._id
      Meteor.call 'doTrade', amount, contract_id, (error, result) ->
        if error
          Errors.throw TAPi18n.__ "error_insufficient_funds"
        else
          Session.set 'order-details', undefined
          Session.set 'slider', undefined
        true
  true

Template.Contractset.helpers
  Contracts: ->
    Contracts.find {$and: [{set_id: @_id}
                           {mirror: {$not: true}}]}

  hint: ->
    value = Contracts.find({set_id: @_id}, {fields: {hints: 1}}).fetch()
    i = 0
    hintArrUpdated = []
    while i <value.length
      if value[i].hints
        hintArr = value[i].hints
        val = hintArr.filter (d) ->
          return d.approved == true
        j = 0
        while j <  val.length
          hintArrUpdated.push(val[j])
          j++
      i++
    return hintArrUpdated



  Image: ->
    Images.findOne({_id: @image})

  isActive: ->
    set_id = Session.get('order-details')?.set_id
    set_id? and set_id is @_id

  endingSoon: ->
    moment(@settletime).subtract(4, 'days').valueOf() < Date.now()

  isHot: ->
    false

  filterUntranslatedText: GlobalHelpers.filterUntranslated

  iframebound: ->
    self isnt top

  notSubmittable: ->
    not Session.get('order-details')? or
    Session.get('order-details').set_id isnt @_id or
    not Session.get('slider')? or
    Session.get('slider').amount is 0

  tradeDetails: ->
    details = Session.get('order-details')
    amount = details?.amount or 0

    if amount isnt 0
      price = (details.cost/amount).toFixed(2)
      if amount > 0
        return TAPi18n.__ "button_do_trade_buy", {
          postProcess: 'sprintf'
          sprintf: [amount.toFixed(0), price]
        }
      else
        return TAPi18n.__ "button_do_trade_sell", {
          postProcess: 'sprintf'
          sprintf: [(-1 * amount).toFixed(0), price]
        }
    else
      TAPi18n.__ "button_do_trade"


Template.Contractset.events
  'click .cancel-trade': (evt, tmpl) ->
    Session.set 'order-details', undefined

  'click .do-trade': (evt, tmpl) ->
    do_trade()

  'click .start-trade': (evt, tmpl) ->
    Session.set 'order-details', {'set_id': @_id, 'market_id': @market_id}

  'click .submit_hint': (evt, tmpl) ->
    id = evt.currentTarget.id
    Session.set 'market_id', @market_id
    Session.set 'buttonId', id
    Router.go('/hint')
