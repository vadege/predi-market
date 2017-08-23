# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

collectionVectorToMap = (coll) ->
  _.reduce coll, (memo, item) ->
    memo[item._id] = item
    return memo
  , {}

Template.Wallet.helpers
  cash: ->
    wallet = FastReactiveDataSource.get "wallet"
    if wallet?
      trading = Session.get 'order-details'
      cash = wallet?.cash or 0
      cash = cash + (trading?.cash_delta or 0)
      cash.toFixed 0
    else
      undefined

  cash_delta: ->
    trading = Session.get 'order-details'
    if trading?
      cash_delta = trading?.cash_delta or 0
      cash_delta.toFixed 0

  frozen_assets: ->
    wallet = FastReactiveDataSource.get "wallet"
    if wallet?
      trading = Session.get 'order-details'
      frozen =  wallet?.frozen or 0
      frozen = frozen + (trading?.frozen or 0)
      frozen.toFixed 0
    else
      undefined

  frozen_delta: ->
    trading = Session.get 'order-details'
    if trading?
      frozen = trading?.frozen or 0
      frozen.toFixed 0
    else
      undefined

  ranking: ->
    trading = Session.get 'order-details'
    if trading?.ranking
      return trading.ranking + 1
    else
      wallet = FastReactiveDataSource.get "wallet"
      if wallet?
        uid = Meteor.user()?._id
        ranking = i for user, i in wallet.users_with_worth when user.me
        return ranking + 1
      else
        return undefined

  ranking_delta: ->
    trading = Session.get 'order-details'
    wallet = FastReactiveDataSource.get "wallet"
    if trading?.ranking and wallet?
      uid = Meteor.user()?._id
      ranking = i for user, i in  wallet.users_with_worth when user.me
      return (trading.ranking - ranking) or 0
    else
      return undefined

  owns_stock: ->
    wallet = FastReactiveDataSource.get "wallet"
    wallet?.owned > 0

  portfolio_worth: ->
    wallet = FastReactiveDataSource.get "wallet"
    if wallet?
      trading = Session.get "order-details"
      old_worth = wallet?.portfolio_worth or 0
      adjust = trading?.portfolio_worth_delta or 0
      worth = old_worth + adjust
      worth.toFixed 0
    else
      undefined

  portfolio_worth_delta: ->
    trading = Session.get 'order-details'
    if trading?.portfolio_worth_delta
      worth_delta = trading?.portfolio_worth_delta
      worth_delta.toFixed 0
    else
      undefined

  net_worth: ->
    wallet = FastReactiveDataSource.get "wallet"
    if wallet?
      trading = Session.get 'order-details'
      worth = wallet?.net_worth or 0
      adjust = (trading?.net_worth_delta or 0)
      worth = worth + adjust
      worth.toFixed 0
    else
      undefined

  net_worth_delta: ->
    trading = Session.get 'order-details'
    if trading?
      adjust = (trading?.net_worth_delta or 0)
      adjust.toFixed 0
    else
      undefined

Template.Wallet.rendered = ->
  ga('send', 'event', 'Wallet', 'read')
  @autorun ->
    $('a.explain').popover()
