# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

set_contract_filter_text = (id, evt) ->
  value_element = evt.currentTarget
  value = value_element?.value
  filter = Session.get('contract-filter') or {}

  unless filter[id]
    filter[id] = {}

  unless filter[id].custom?
    filter[id].custom = []

  if evt?.target?.className is "custom-filter"
    if evt?.target?.checked
      filter[id].custom = _.union filter[id].custom, value
    else
      filter[id].custom = _.without filter[id].custom, value
  else
    if (value_element)
      filter[id].text = value

  Session.set 'contract-filter', filter

Template.Market.helpers
  Market: ->
    market_id = Router.current().params._id
    Markets.findOne {_id: market_id}

  Filters: ->
    market_id = Router.current().params._id
    Filters.find {parent_id: market_id}

  Contractsets: ->
    now = Date.now()
    market_id = Router.current().params._id
    contracts = Contracts.find({market_id: market_id}).fetch()
    contractsets = Contractsets.find(
        $and: [{market_id: market_id},
               {active: true},
               {launchtime: {$lte: now}},
               {settletime: {$gte: now}}]
      ,
        sort:
          sort_index: 1,
          settletime: -1
    ).fetch()
    filter = Session.get('contract-filter')?[market_id]

    filter_texts = _.union (filter?.text or "").split(' '), filter?.custom
    lower_case_filter_texts = _.chain filter_texts
      .filter (text) ->
        text?.length > 0
      .map (text) ->
        text.toLowerCase()
      .value()
    filter_portfolio_only = Session.get('contract-filter')?[market_id]?.portfolio_only
    filter_closing_soon = Session.get('contract-filter')?[market_id]?.closing_soon

    all_contractset_ids = _.map contractsets, (set) ->
      return set._id
    contractsets_with_portfolio = all_contractset_ids
    contractsets_closing_soon = all_contractset_ids
    contractsets_matching_text_filters = all_contractset_ids

    if filter_portfolio_only
      portfolio = Meteor.user().profile?.portfolio
      contractsets_with_portfolio = _.chain contracts
        .filter (contract) ->
          return portfolio[contract._id]? and portfolio[contract._id] isnt 0
        .map (contract) ->
          return contract.set_id
        .uniq()
        .value()

    if filter_closing_soon
      contractsets_closing_soon = _.chain contractsets
        .filter (set) ->
          return moment(set.settletime).subtract(4, 'days').valueOf() < Date.now()
        .map (set) ->
          return set._id
        .value()

    if lower_case_filter_texts.length > 0
      matching_contracts = _.reduce lower_case_filter_texts, (memo, word) ->
        matching_contract_setids = _.chain contracts
          .filter (contract) ->
            return contract.title.toLowerCase().indexOf(word) >= 0
          .map (contract) ->
            return contract.set_id
          .uniq()
          .value()

        memo[word] = matching_contract_setids
        return memo
      , {}

      matching_contractsets = _.reduce lower_case_filter_texts, (memo, word) ->
        matching_set_ids = _.chain contractsets
          .filter (set) ->
            return _.contains(matching_contracts[word], set._id) or
                   set.title.toLowerCase().indexOf(word) >= 0 or
                   set.description.toLowerCase().indexOf(word) >= 0
          .map (set) ->
             return set._id
          .uniq()
          .value()

        memo[word] = matching_set_ids
        return memo
      , {}

      contractsets_matching_text_filters = _.filter all_contractset_ids, (id) ->
        return _.every _.values(matching_contractsets), (word_matches) ->
          _.contains word_matches, id

    _.filter contractsets, (set) ->
      return set._id in contractsets_with_portfolio and
             set._id in contractsets_closing_soon and
             set._id in contractsets_matching_text_filters

  hasOpenContracts: ->
    now = Date.now()
    market_id = Router.current().params._id
    Contractsets.find(
      $and: [{market_id: market_id},
             {active: true},
             {launchtime: {$lte: now}},
             {settletime: {$gte: now}}]
    ).count() > 0

  filterActive: ->
    market_id = Router.current().params._id
    filter_text = Session.get('contract-filter')?[market_id]?

  filter_value: ->
    market_id = Router.current().params._id
    filter = Session.get 'contract-filter'
    filter? and filter[market_id]?.text? and filter[market_id].text or ""

  portfolio_only_filter_on: ->
    market_id = Router.current().params._id
    filter = Session.get 'contract-filter'
    filter? and filter[market_id]?.portfolio_only

  closing_soon_filter_on: ->
    market_id = Router.current().params._id
    filter = Session.get 'contract-filter'
    filter? and filter[market_id]?.closing_soon

  filter_on: (filter) ->
    market_id = Router.current().params._id
    filter_obj = Session.get 'contract-filter'
    _.contains (filter_obj?[market_id]?.custom or []), filter

  removeUntranslatedText: GlobalHelpers.removeUntranslated

Template.Market.events
  'keyup .filtertext': (evt, tmpl) ->
    evt.stopPropagation()
    market_id = Router.current().params._id
    set_contract_filter_text market_id, evt

  'change .filtertext': (evt, tmpl) ->
    evt.stopPropagation()
    market_id = Router.current().params._id
    set_contract_filter_text market_id, evt

  'change #filter_closing_soon': (evt, tmpl) ->
    evt.stopPropagation()
    market_id = Router.current().params._id
    value_element = evt.currentTarget
    value = value_element?.checked
    filter = Session.get('contract-filter') or {}
    unless filter[market_id]
      filter[market_id] = {}
    filter[market_id].closing_soon = value
    Session.set 'contract-filter', filter

  'change #filter_portfolio_only': (evt, tmpl) ->
    evt.stopPropagation()
    market_id = Router.current().params._id
    value_element = evt.currentTarget
    value = value_element?.checked
    filter = Session.get('contract-filter') or {}
    unless filter[market_id]
      filter[market_id] = {}
    filter[market_id].portfolio_only = value
    Session.set 'contract-filter', filter

  'change .custom-filter': (evt, tmpl) ->
    evt.stopPropagation()
    value_element = evt.currentTarget
    value = value_element?.checked
    market_id = Router.current().params._id
    set_contract_filter_text market_id, evt

Template.Market.rendered = ->
  @autorun ->
    order = Session.get 'order-details'
    market_id = Router.current().params._id
    unless order? and order.market_id is market_id
      Session.set 'order-details', undefined

