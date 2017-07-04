# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@giveUserInitMoney = (user_id, market_id) ->
  market = Markets.findOne({_id: market_id})
  unless Meteor.users.findOne({_id: user_id}).profile.cash[market._id]
    new_cash_entry = {}
    new_cash_entry['profile.cash.' + market_id] = market.initial_money
    Meteor.users.upsert { _id: user_id }, {$set: new_cash_entry}
    startfunds_log =
      timestamp: Date.now()
      user_id: "system"
      type: "paystartfunds"
      value: {user_id: user_id, market_id: market_id, funds: market.initial_money}

    Activities.insert startfunds_log

@giveMembersInitMoney = (market_id) ->
  market = Markets.findOne({_id: market_id})
  users = _.flatten(_.map market.tags, (tag) ->
    Meteor.users.find({'profile.tags': {$in: [tag]}}).fetch()
  )

  _.each _.uniq(users), (user, index, list) ->
    giveUserInitMoney user._id, market_id

  market_id

@addTag = (user_id, tag) ->
  giveUserStartMoney user_id, tag
  Meteor.users.update {_id: user_id}, {$addToSet: {'profile.tags': tag}}

  tags_log =
    timestamp: Date.now()
    user_id: "system"
    type: "addedusertag"
    value: {tag: tag}

  Activities.insert tags_log

@giveUserStartMoney = (user_id, tag) ->
  markets = Markets.find({'tags': {$in: [tag]}}).fetch()

  _.each markets, (market, index, list) ->
    giveUserInitMoney user_id, market._id

  tag

@buyBackShares = (user_id, contract, price) ->
  user = Meteor.users.findOne({'_id': user_id})
  set = Contractsets.findOne {'_id': contract.set_id}
  owned = user.profile.portfolio[contract._id]
  gains = 0
  unfreeze = 0

  if (owned? and owned isnt 0)
    gains = (owned * price)
    if (owned < 0)
      unfreeze = (owned * -1 * set.freeze_amount)

    new_cash_entry = {}
    new_port_entry = {}
    new_cash_entry['profile.cash.' + contract.market_id] = ((user?.profile?.cash[contract?.market_id] or 0) + gains + unfreeze)
    new_port_entry['profile.portfolio.' + contract._id] = 0
    Meteor.users.upsert { _id: user._id }, {$set: new_cash_entry}
    Meteor.users.upsert { _id: user._id }, {$set: new_port_entry}

    bought_back_log =
      timestamp: Date.now()
      user_id: "system"
      type: "shares_bought_back",
      value: {user_id: user_id, contract_id: contract._id, owned: owned, price: price, thawed: unfreeze, payed: gains}

    Activities.insert bought_back_log
  gains

@setUserFullName = (user_id, name) ->
  Meteor.users.update {_id: user_id}, {$set: {'profile.name': name}}
  name_log =
    timestamp: Date.now()
    user_id: "system"
    type: "setuserfullname"
    value: {name: name}

  Activities.insert name_log
  true

@setUserName = (user_id, name) ->
  Meteor.users.update {_id: user_id}, {$set: {'username': name}}
  name_log =
    timestamp: Date.now()
    user_id: "system"
    type: "setusername"
    value: {name: name}

  Activities.insert name_log
  true

@updateUserTags = (user_id, tagstring) ->
  user = Meteor.users.findOne {_id: user_id}
  tags = _.map tagstring.split(','), (tag) ->
    return tag.replace /^\s+|\s+$/g, ''

  new_tags = _.difference tags, user.profile.tags

  _.each new_tags, (tag) ->
    giveUserStartMoney user_id, tag

  Meteor.users.update {_id: user_id}, {$set: {'profile.tags': tags}}

  tags_log =
    timestamp: Date.now()
    user_id: "system"
    type: "setusertags"
    value: {tags: tags}

  Activities.insert tags_log
  tags

@setUserCash = (user_id, market_id, cash) ->
  check cash, Number
  check market_id, String
  check user_id, String

  new_cash_entry = {}
  new_cash_entry['profile.cash.' + market_id] = cash
  Meteor.users.upsert { _id: user_id }, {$set: new_cash_entry}
  startfunds_log =
    timestamp: Date.now()
    user_id: "system"
    type: "setusercash"
    value: {user_id: user_id, market_id: market_id, cash: cash}

  Activities.insert startfunds_log
  true

@setUserAdmin = (user_id, adminstatus) ->
  if adminstatus isnt true
    if Meteor.users.find({'profile.admin': true}).fetch().length < 2
      throw new Meteor.Error(403, "Removing the last admin is not allowed.")

  Meteor.users.update {_id: user_id}, {$set: {'profile.admin': adminstatus}}
  admin_log =
    timestamp: Date.now()
    user_id: "system"
    type: "setuserisadmin"
    value: {isadmin: adminstatus}

  Activities.insert admin_log

@createUser = (username, email, password, name) ->
  Accounts.createUser {username: username, email: email, password: password, profile: {name: name, admin: false}}

@setUserLanguage = (user_id, language_tag) ->
  unless language_tag in _.keys(TAPi18n.getLanguages())
    throw new Meteor.Error(403, language_tag + " is not a supported language")
  Meteor.users.update {_id: user_id}, {$set: {'profile.preferred_lang': language_tag}}
  set_language_log =
    timestamp: Date.now()
    user_id: user_id
    type: "setuserlang"
    value: {language: language_tag}

  Activities.insert set_language_log
