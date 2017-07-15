# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

TAPi18n.publish "Markets", ->
  if @userId isnt null
    user = Meteor.users.findOne {_id: @userId}
    if user.profile.admin
      Markets.i18nFind()
    else
      Markets.i18nFind({})

TAPi18n.publish "Contractsets", ->
  if @userId isnt null
    user = Meteor.users.findOne {_id: @userId}
    if user.profile.admin
      Contractsets.i18nFind()
    else
      market_ids = _.map Markets.i18nFind({}).fetch(), (market) -> market._id

      Contractsets.i18nFind
        active: true
        settled: false
        market_id: {$in: market_ids}
        launchtime: {$lte: Date.now()}
      ,
        sort: ['settletime', 'desc']

TAPi18n.publish "Contracts", ->
  if @userId isnt null
    user = Meteor.users.findOne {_id: @userId}
    if user.profile.admin
      Contracts.i18nFind()
    else
      market_ids = _.map Markets.i18nFind({}).fetch(), (market) -> market._id
      contractset_ids = _.map Contractsets.i18nFind(
        active: true
        settled: false
        market_id: {$in: market_ids}
        launchtime: {$lte: Date.now()}
      ).fetch(), (contract) ->
        contract._id
      Contracts.i18nFind {set_id: {$in: contractset_ids}}

TAPi18n.publish "Pages", ->
  Pages.i18nFind()

TAPi18n.publish "Filters", ->
  Filters.i18nFind()

Meteor.publish "Activities", (limit) ->
  if @userId isnt null
    user = Meteor.users.findOne {_id: @userId}
    if user.profile?.admin
      Activities.find {}, {limit: limit, fields: {timestamp: 1, user_id: 1, type: 1}, sort: {timestamp: 1}}

Meteor.publish "TradeLog", (set_id) ->
  if @userId isnt null
    user = Meteor.users.findOne {_id: @userId}
    if set_id?
      Activities.find {type: {$in: ["trade", "setprice"]}, "value.set_id": set_id}, {sort: {timestamp: 1}}
    else
      Activities.find {type: {$in: ["trade", "setprice"]}}, {sort: {timestamp: 1}}

Meteor.publish "OneActivity", (id) ->
  if @userId isnt null
    user = Meteor.users.findOne {_id: @userId}
    if user.profile.admin
      id and Activities.find {_id: id}

Meteor.publish 'userData', ->
  if @userId is null
    Meteor.users.find {}, {fields: {'profile': 0}}
  else
    user = Meteor.users.findOne {_id: @userId}
    if user.profile.admin
      Meteor.users.find()
    else
      Meteor.users.find {_id: @userId}, {fields: {'profile': 1}}

Meteor.publish 'allUserData', ->
  if @userId is null
    Meteor.users.find {}, {fields: {'profile': 0}}
  else
    user = Meteor.users.findOne {_id: @userId}
    # TODO: Inject gravatar hash
    Meteor.users.find {}, {fields: {'profile.cash': true, 'profile.portfolio': true, 'profile.name': true, 'profile.tags': true, username: true, 'profile.admin': true}}

Meteor.publish 'Settings', ->
  Settings.find()

Meteor.publish 'Images', ->
  if @userId isnt null
    Images.find()

Meteor.publish 'ContractsHints', ->
  Contracts.find()

Meteor.publish 'Comments', ->
  Comments.find()

Meteor.publish 'HintsLikeDisLike', ->
  HintsLikeDisLike.find()
