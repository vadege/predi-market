# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.AdminMarket.helpers
  Contractsets: ->
    now = Date.now()
    category = Session.get 'category_search'
    Contractsets.find
      $and: [{market_id: @_id},
             {category: category},
             {settled: false}]

  Filters: ->
    Filters.find {parent_id: @_id}

  hasOpenContracts: ->
    now = Date.now()
    Contractsets.find(
      $and: [{market_id: @_id},
             {active: true},
             {settled: false},
             {settletime: {$gte: now}},
             {launchtime: {$lte: now}}]
    ).count() > 0

  deleteable: ->
    now = Date.now()
    Contractsets.find(
      $and: [{market_id: @_id},
             {launchtime: {$lte: now}}]
    ).count() < 1

Template.AdminMarket.events
  'click button.close_market': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'closeMarket', @_id, (error, result) ->
      if error
        Errors.throw error.message
    Deps.flush()
    true

  'click button.delete_market': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'deleteMarket', @_id, (error, result) ->
      if error
        Errors.throw error.message
    Deps.flush()
    true

  'click button.add_voteshare_set': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'addContractset', @_id, true, (error, result) ->
      if error
        Errors.throw error.message
    Deps.flush()
    true

  'click button.add_prob': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'addContractset', @_id, false, (error, result) ->
      if error
        Errors.throw error.message
    Deps.flush()
    true

  'click button.add_filter': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'addFilter', @_id, false, (error, result) ->
      if error
        Errors.throw error.message
    Deps.flush()
    true
