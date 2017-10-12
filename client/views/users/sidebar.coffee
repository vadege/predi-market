# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.Sidebar.helpers
  Pages: ->
    Pages.find()

  Markets: ->
    user = Meteor.user()
    contracts = Contracts.find().fetch()
    _.map Markets.find().fetch(), (market) ->
      sum = _.chain contracts
        .filter (contract) ->
          return contract.market_id is market._id
        .reduce (sum, contract) ->
          return sum + (user?.profile?.portfolio[contract._id] or 0)
        , 0
        .value()
      return _.extend market, {owned: sum}

  has_multiple_markets: ->
    Markets.find().count() > 1

  market_selected: ->
    Router.current()?.options?.route?.getName() is "market" ||
    Router.current()?.options?.route?.getName() is "dashboard"

  select: ->
    if Router.current()?.options?.route?.getName() is "submit-theory"
      return 'selected'
    else
      return ''

  select_dashboard: ->
     if Router.current()?.options?.route?.getName() is "dashboard"
       return 'selected'
     else
       return ''

  marketplace_selected: ->
    current_route = Router.current()
    if current_route.options.route.getName() is "markets"
      return 'selected'
    else
      markets = Markets.find().fetch()
      if markets?.length is 1 and
         current_route? and
         markets[0]._id is current_route.params._id
        return 'selected'
    return ''

  leaderboard_select: ->
    linkName = Router.current()?.options?.route?.getName()
    if linkName is "leaderboard"
      return 'selected'
    else
      return ''

  maybe_selected: ->
    current_route = Router.current()
    if current_route and @_id is current_route.params._id
      return 'selected'
    else
      return ''

  leaderboard_link: ->
    market_id = undefined
    if Router.current().route.getName() is "market"
      market_id = Router.current().params._id
    if market_id?
      return "/leaderboard/" + market_id
    else
      return "/leaderboard/*"

  iframewallet: ->
    if self != top
      return "in-iframe"
    else
      return ""

Template.Sidebar.rendered = ->
  @autorun ->
    current_route = Router.current()
    if current_route?.options?.route?.getName() is "market" || current_route?.options?.route?.getName() is "dashboard"
      FastReactiveDataSource.set "wallet", GlobalHelpers.compute_wallet current_route.params._id
    else
      FastReactiveDataSource.set "wallet", undefined

Template.Sidebar.events
  'click [data-toggle=offcanvas]': (evt, tmpl) ->
    element = $ evt.currentTarget
    element.toggleClass 'visible-xs text-center'
    element.find('i').toggleClass 'fa-chevron-right fa-chevron-left'
    $('.row-offcanvas').toggleClass 'active'
    $('#sidebar .market-stats').toggleClass 'visible-account-xs'
    $('#sidebar .menu').toggleClass('expanded')
    $('#main').toggleClass('col-xs-push-1')

  'click [data-toggle=popover]': (evt, tmpl) ->
    $('[data-toggle=popover]').each ->
      unless this is evt.target or
             this.children[0] is evt.target
        $(this).popover 'hide'
