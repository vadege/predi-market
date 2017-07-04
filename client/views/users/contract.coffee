# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@slider_details = undefined

compute_trade_object = (contract_id, amount) ->
  user = Meteor.user()
  profile = user.profile
  contract = Contracts.findOne({_id: contract_id})
  contractset = Contractsets.findOne({_id: contract.set_id})
  contracts = Contracts.find({set_id: contractset._id}).fetch()
  market = Markets.findOne({_id: contract.market_id})
  cash = user.profile.cash[market._id] or 0
  owned = user.profile.portfolio[contract_id] or 0
  new_owned = owned + amount
  movement =
    id: contract_id
    move: amount
  cost = PriceCalculator.compute_cost contractset, contracts, [movement]

  owedinc = 0
  if new_owned >= 0
    if owned < 0
      owedinc = -1 * owned
  else
    if owned > 0
      owedinc = owned + amount
    else
      owedinc = amount

  freeze = owedinc * contractset.freeze_amount

  new_contracts = _.map contracts, (contract) ->
    if contract._id is contract_id
      new_contract = _.extend {}, contract
      new_contract.outstanding = new_contract.outstanding + amount
    return new_contract or contract

  new_prices = _.reduce new_contracts, (memo, contract) ->
    memo[contract._id] = PriceCalculator.price contractset, new_contracts, contract._id
    return memo
  , {}

  old_prices = _.reduce contracts, (memo, contract) ->
    memo[contract._id] = PriceCalculator.price contractset, contracts, contract._id
    return memo
  , {}

  price_deltas = _.reduce contracts, (memo, contract) ->
    memo[contract._id] = (new_prices[contract._id] - old_prices[contract._id])
    if memo[contract._id] > 0
      memo[contract._id] = "+" + memo[contract._id]
        .toFixed 2
        .replace /\.?0+$/, ""
    else
      memo[contract._id] = memo[contract._id]
        .toFixed 2
        .replace /\.?0+$/, ""

    return memo
  , {}

  outstanding = _.reduce new_contracts, (memo, contract) ->
    memo[contract._id] = contract.outstanding
    return memo
  ,{}

  portfolio_worth_delta = _.reduce contracts, (sum, contract) ->
    outstanding_delta = (outstanding[contract._id] - contract.outstanding)
    old_worth = ((profile.portfolio[contract._id] or 0) *
                 (old_prices[contract._id] or 0))
    new_worth = ((profile.portfolio[contract._id] or 0) +
                 (outstanding_delta or 0)) *
                 (new_prices[contract._id] or 0)
    return sum + (new_worth - old_worth)
  , 0

  profile.cash[market._id] = cash - cost + freeze
  cash_delta = (cost * -1) + freeze
  net_worth_delta = portfolio_worth_delta - cost

  ranking = undefined
  # contracts_with_prices = GlobalHelpers.contracts_with_prices market._id, profile.portfolio_delta
  # users_with_worth = GlobalHelpers.users_with_worth market, contracts_with_prices
  # uid = Meteor.user()?._id
  # ranking = i for user, i in users_with_worth when user._id is uid

  description =
    timestamp: Date.now()
    amount: amount
    cost: cost
    user_id: user._id
    contract_id: contract_id
    set_id: contractset._id
    market_id: market._id
    outstanding: outstanding
    contracts: new_contracts
    prices: new_prices
    price_deltas: price_deltas
    portfolio: profile.portfolio
    portfolio_worth_delta: portfolio_worth_delta
    cash: profile.cash
    cash_delta: cash_delta
    frozen: freeze
    ranking: ranking
    net_worth_delta: net_worth_delta

  description

compute_slider_details = (set_id, contract_id) ->
  contractset = Contractsets.findOne({_id: set_id})
  contracts = Contracts.find({set_id: set_id}).fetch()
  market = Markets.findOne({_id: contractset.market_id})
  user = Meteor.user()

  cash = user.profile.cash[market._id] or 0
  owned = user.profile.portfolio[contract_id] or 0

  min = PriceCalculator.min_trade contractset, contracts, contract_id, cash, owned
  max = PriceCalculator.max_trade contractset, contracts, contract_id, cash, owned

  amount = 0
  # trading = Session.get 'order-details'
  # if trading? and trading.contract_id is contract_id
  #   amount = Session.get('order-details').amount

  range = Math.abs(min) + max

  return {
    contract_id: contract_id
    set_id: set_id
    min: min
    max: max
    position: amount + Math.abs(min) - 1
    number_steps: range
  }

Template.Contract.helpers
  Image: ->
    Images.findOne({_id: @image})

  price: ->
    contracts = undefined
    trading = Session.get 'order-details'
    if trading? and trading.set_id is @set_id
      contracts = trading.contracts
    if not contracts?
      contracts = Contracts.find({set_id: @set_id}).fetch()

    PriceCalculator.price Contractsets.findOne({_id: @set_id}), contracts, @_id
      .toFixed 2
      .replace /\.?0+$/, ""

  display_contract_portfolio: ->
    user = Meteor.user()
    owned = user.profile.portfolio[@_id] or 0
    trading = Session.get 'order-details'
    (trading? and trading.set_id is @set_id) or owned isnt 0

  owned: ->
    user = Meteor.user()
    owned = user.profile.portfolio[@_id] or 0
    slider = Session.get 'slider'
    if slider? and slider.contract_id is @_id
      owned = parseInt(owned + slider.amount)
    owned

  owned_delta: ->
    amount = undefined
    slider = Session.get 'slider'
    if slider? and slider.contract_id is @_id
      amount = parseInt slider.amount
      if amount is 0
        amount = undefined
      else if amount > 0
        amount = "+" + amount
      else
        amount = "" + amount
    amount

  price_delta: ->
    price_delta = undefined
    trading = Session.get 'order-details'
    if trading? and trading.set_id is @set_id
      price_delta = trading.price_deltas?[@_id]
    (price_delta? and price_delta isnt "0" and price_delta) or undefined

  owed: ->
    user = Meteor.user()
    owned = user.profile.portfolio[@_id] or 0
    trading = Session.get 'order-details'
    slider = Session.get 'slider'
    if slider? and slider.contract_id is @_id
      owned = owned + slider.amount
    owned < 0

  amount: ->
    amount = 0
    trading = Session.get 'order-details'
    if trading? and trading.contract_id is @_id
      amount = Session.get('order-details').amount
    parseInt(amount)

  trading: ->
    trading = Session.get 'order-details'
    trading? and trading.contract_id is @_id

  trading_class: ->
    trading = Session.get 'order-details'
    trading? and trading.contract_id is @_id and "trading"

  extra_class: ->
    trading = Session.get 'order-details'
    extra_class = "panel-default"
    if trading? and trading.contract_id is @_id
      extra_class = "panel-info"
    extra_class

  filterUntranslatedText: GlobalHelpers.filterUntranslated

  notSubmittable: ->
    not Session.get('order-details')? or
    Session.get('order-details').contract_id isnt @_id or
    Session.get('slider')?.amount is 0

  cannotSellOne: ->
    not Session.get('order-details')? or
    Session.get('order-details').contract_id isnt @_id or
    not @slider_details or
    parseInt(Session.get("slider")?.amount, 10) - 1 < @slider_details.min

  cannotSellTen: ->
    not Session.get('order-details')? or
    Session.get('order-details').contract_id isnt @_id or
    not @slider_details or
    parseInt(Session.get("slider")?.amount, 10) - 10 < @slider_details.min

  cannotBuyOne: ->
    not Session.get('order-details')? or
    Session.get('order-details').contract_id isnt @_id or
    not @slider_details or
    @slider_details.position + parseInt(Session.get("slider")?.amount, 10) + 1 >= @slider_details.number_steps

  cannotBuyTen: ->
    not Session.get('order-details')? or
    Session.get('order-details').contract_id isnt @_id or
    not @slider_details or
    @slider_details.position + parseInt(Session.get("slider")?.amount, 10) + 10 >= @slider_details.number_steps


Template.Contract.events
  'click div.contract': (evt, tmpl) ->
    current_slider = Session.get 'slider'
    unless current_slider? and current_slider.contract_id is @_id
      evt.stopPropagation()
      Session.set 'slider', {contract_id: @_id, amount: 0}
      if evt.currentTarget isnt undefined
        trading = Session.get 'order-details'
        if not trading? or trading.contract_id isnt @_id
          user = Meteor.user()
          cash = user.profile.cash[@market_id] or 0
          owned = user.profile.portfolio[@_id] or 0
          if cash isnt 0 or owned isnt 0
            Session.set 'order-details', compute_trade_object(@_id, 0)
          else
            Errors.throw TAPi18n.__ "error_insufficient_funds"

      true

  'click button.reset_slider': (e) ->
    slider = Session.get 'slider'
    if slider?.contract_id is @_id
      slider.amount = 0
      slider.reset = true
      Session.set 'slider', slider

  'click button.buyten': (e) ->
    slider = Session.get 'slider'
    if slider?.contract_id is @_id
      slider.amount = slider.amount + 10
      slider.reset = true
      Session.set 'slider', slider

  'click button.buyone': (e) ->
    slider = Session.get 'slider'
    if slider?.contract_id is @_id
      slider.amount = slider.amount + 1
      slider.reset = true
      Session.set 'slider', slider

  'click button.sellone': (e) ->
    slider = Session.get 'slider'
    if slider?.contract_id is @_id
      slider.amount = slider.amount - 1
      slider.reset = true
      Session.set 'slider', slider

  'click button.sellten': (e) ->
    slider = Session.get 'slider'
    if slider?.contract_id is @_id
      slider.amount = slider.amount - 10
      slider.reset = true
      Session.set 'slider', slider

Template.Contract.rendered = ->
  contract_id = @data._id
  set_id = @data.set_id
  slider_details = compute_slider_details set_id, contract_id
  @data.slider_details = slider_details
  init_pos = (@data.slider_details.position / @data.slider_details.number_steps)

  computefun = _.debounce (amount) ->
    Session.set 'order-details', compute_trade_object contract_id, amount
    slider = Session.get 'slider' 
    if slider?.amount is amount and slider?.reset
      slider.reset = false
      Session.set 'slider', slider
  , 300

  slider = new Dragdealer 'trade-drag-dealer-' + contract_id, {
    animationCallback: (x, y) ->
      session_slider = Session.get 'slider'
      if session_slider?.contract_id is contract_id
        step = @getStep()[0] or 1
        amount = slider_details.min + step - 1
        unless session_slider.reset
          session_slider.amount = amount
          Session.set 'slider', session_slider
          computefun amount

    steps: slider_details.number_steps + 1
    disabled: true
    loose: true
    speed: 0.5
    x: init_pos
  }

  Session.set 'slider', undefined

  @autorun ->
    session_slider = Session.get 'slider'
    if session_slider?.contract_id is contract_id and
       slider_details?.number_steps > 0
      slider.enable()
      if session_slider.reset
        slider.setStep session_slider.amount - slider_details.min, 0, {snap: true}
        Meteor.setTimeout ->
          computefun session_slider.amount
        , 500
    else
      slider.disable()
      slider.setValue init_pos, 0, {snap: true}
