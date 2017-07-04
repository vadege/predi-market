# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@createMarket = (market, timestamp) ->
  check market, Match.ObjectIncluding(
    title: String
    description: String
    initial_money: Number
    tags: [String]
  )

  if isNaN market.initial_money
    throw new Meteor.Error 403, market.initial_money + " is not a number"

  translations = @placeholderTranslations ["title", "description"]
  market_id = Markets.insertTranslations market, translations
  @giveMembersInitMoney market_id

  create_log =
    timestamp: timestamp or Date.now()
    user_id: "system"
    type: "createmarket"
    value: _.extend market, {market_id: market_id}

  Activities.insert create_log
  market_id

@removeMarket = (market_id) ->
  @removeContractsetsInMarket market_id
  Markets.remove({_id: market_id})

  remove_log =
    timestamp: Date.now()
    user_id: "system"
    type: "deletemarket"
    value: {market_id: market_id}

  Activities.insert remove_log
  market_id

@setMarketTags = (market_id, tagstring) ->
  market = Markets.findOne {_id: market_id}
  tags = _.map tagstring.split(','), (tag) ->
    return tag.replace /^\s+|\s+$/g, ''

  Markets.update {_id: market_id}, {$set: {tags: tags}}

  new_tags = _.difference tags, market.tags

  _.each new_tags, (tag) ->
    @giveMembersInitMoney market_id

  tags_log =
    timestamp: Date.now()
    user_id: "system"
    type: "setmarkettags"
    value: {tags: tags}

  Activities.insert tags_log

