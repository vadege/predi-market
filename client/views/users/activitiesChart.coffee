# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

createChart = (svgnode) ->
  @Timeline.initialize_graph svgnode

updateChart = (svgnode, current_user_id, log, names) ->
  @Timeline.update_and_refresh_graph svgnode, current_user_id, log, names

synthesizeInitialPrices = (set_id) ->
  set = Contractsets.findOne {_id: set_id}
  contracts = Contracts.find({set_id: set_id}).fetch()
  _.chain contracts
    .map (contract) ->
      contract.outstanding = 0
      return contract
    .reduce (memo, contract) ->
      memo[contract._id] = PriceCalculator.price set, contracts, contract._id
      return memo
    , {}
    .value()

addSyntheticData = (set_id, launchtime, log_entries, trading) ->
  log = []

  starting_prices = _.chain log_entries
    .filter (entry) ->
      return entry.type is "set_prices"
    .value()

  if starting_prices? and starting_prices.length > 0
    log = log.concat _.last(starting_prices)

  if log.length < 1
    start_datapoint = {}
    start_datapoint._id = "synthetic1"
    start_datapoint.userid = "system"
    start_datapoint.timestamp = launchtime
    start_datapoint.type = "set_prices"
    start_datapoint.value = {}
    start_datapoint.value.set_id = set_id
    start_datapoint.value.prices = synthesizeInitialPrices set_id
    log = log.concat start_datapoint

  trade_entries = _.filter log_entries, (entry) ->
    return entry.type is "trade"

  if trade_entries
    log = log.concat trade_entries

  if trading? and trading.cash? and
     trading.set_id is set_id and
     trading.amount? isnt 0
    trading_datapoint = {}
    trading_datapoint._id = "synthetic2"
    trading_datapoint.in_progress = true # For visualization rules
    trading_datapoint.timestamp = Date.now()
    trading_datapoint.type = "trade"
    trading_datapoint.userid = trading.user_id
    trading_datapoint.value = {}
    trading_datapoint.value.cash_before = trading.cash[trading.market_id] - trading.cash_delta
    trading_datapoint.value.cash_after = trading.cash[trading.market_id]
    trading_datapoint.value.contract_id = trading.contract_id
    trading_datapoint.value.cost = trading.cash_delta
    trading_datapoint.value.frozen = trading.frozen_delta > 0 and trading.frozen_delta
    trading_datapoint.value.market_id = trading.market_id
    trading_datapoint.value.outstandig_before = trading.outstanding[trading.contract_id] - trading.amount
    trading_datapoint.value.outstanding_after = trading.outstanding[trading.contract_id]
    trading_datapoint.value.owned_before = trading.portfolio[trading.contract_id]
    trading_datapoint.value.owned_after = trading.portfolio[trading.contract_id]
    trading_datapoint.value.prices = trading.prices
    trading_datapoint.value.set_id = trading.set_id
    trading_datapoint.value.thawed = trading.frozen_delta < 0 and (trading.frozen_delta * -1)
    log = log.concat trading_datapoint
  else
    now_datapoint = {}
    now_datapoint._id = "synthetic2"
    now_datapoint.userid = "system"
    now_datapoint.timestamp = Date.now()
    now_datapoint.in_progress = true # For visualization rules
    now_datapoint.type = "trade"
    now_datapoint.value = {}
    now_datapoint.value.set_id = set_id
    now_datapoint.value.prices = _.last(log).value.prices
    log = log.concat now_datapoint

  return log


Template.ActivitiesChart.helpers
  chart_id: ->
    "timeline-" + @set_id
  ready: ->
    load_status = Session.get 'log_load_status'
    load_status?[@set_id] is 2
  waiting: ->
    load_status = Session.get 'log_load_status'
    if load_status?[@set_id] is 2
      return ""
    else
      return "waiting"

Template.ActivitiesChart.rendered = ->
  # loader = new Deps.Dependency()
  load_status = Session.get 'log_load_status'
  unless load_status?
    load_status = {}
  set_id = @data.set_id
  load_status[set_id] = false
  Session.set 'log_load_status', load_status
  Meteor.subscribe 'TradeLog', set_id, ->
    load_status[set_id] = 1
    Session.set 'log_load_status', load_status
    # loader.changed()
  set = Contractsets.findOne {_id: set_id}
  launchtime = set.launchtime
  svg_selector = "div#container-timeline-" + set_id
  names = Contracts.find({set_id: set_id, mirror: undefined}).fetch()
  svgnode = @find svg_selector
  setTimeout createChart svgnode
  log_entries = []

  @autorun ->
    # loader.depend()
    load_status = Session.get 'log_load_status'
    if load_status[set_id] is 1
      log_entries = Activities.find({$or: [{type: "trade"}, {type: "set_prices"}], "value.set_id": set_id}, {sort: {timestamp: 1}}).fetch()
      load_status[set_id] = 2
      Session.set 'log_load_status', load_status
      window.setTimeout ->
        $(document).scrollTo $('#contractset-' + set_id), 500, {offset: {top: -50}}
      , 100
    else
      trading = Session.get 'order-details'
      log = addSyntheticData set_id, launchtime, log_entries, trading
      setTimeout updateChart svgnode, Meteor.user()._id, log, names
