# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Router.configure {
  layoutTemplate: 'ApplicationLayout'
  loadingTemplate: 'Loading'
  trackPageView: true
}

Router.onBeforeAction ->
  if Session?.get "loading"
    @layout 'DialogLayout'
    @render 'Loading'
  else
    @next()

Router.onBeforeAction ->
  if Meteor?.users?.find()?.count() is 0
    @layout 'DialogLayout'
    @render 'CreateAdmin'
  else
    @next()

Router.onBeforeAction ->
  if IdleWatcher?.isInactive()
    Meteor.logout()
  @next()

Router.onBeforeAction ->
  if Meteor?.userId() and Meteor?.status()?.connected
    @next()
  else
    @layout 'DialogLayout'
    @render 'Login'
, {except: ['login', 'new_user', 'email_sent']}

Router.route '/new_user', ->
  @layout 'DialogLayout'
  @render 'NewUser'
, {name: 'new_user'}

Router.route '/email_sent', ->
  @layout 'DialogLayout'
  @render 'EmailSent'
, {name: 'email_sent'}

Router.route '/login', ->
  @layout 'DialogLayout'
  @render 'Login'
, {name: 'login'}

Router.route '/', ->
  if Meteor?.user()?.profile?.admin
    @redirect '/admin'
  else
    @redirect '/markets'

Router.route '/page/:_id', ->
  @render 'Sidebar', {to: 'Sidebar'}
  @render 'Page'
, {name: 'page', waitOn: -> TAPi18n.subscribe 'Pages'}

Router.route '/market/:_id', ->
  Session.set 'market_id', null
  Session.set 'commentsByPopularity', null
  Session.set 'commentsByDate', null
  @render 'Sidebar', {to: 'Sidebar'}
  @render 'Market'
, {name: 'market', waitOn: ->
     if Meteor?.userId()
       cols = ['Pages', 'Markets', 'Contractsets', 'Contracts', 'Images', 'Filters', 'ContractsHints', 'HintsLikeDisLike', 'ReplyLikeDislike', 'Comments']
       _.map cols, (col) ->
         TAPi18n.subscribe col
  }

Router.route '/leaderboard/:_id', ->
  @render 'Sidebar', {to: 'Sidebar'}
  @render 'Leaderboard'
, {name: 'leaderboard', waitOn: ->
     if Meteor?.userId()
       cols = ['Pages', 'Markets', 'Contractsets', 'Contracts']
       _.map cols, (col) ->
         TAPi18n.subscribe col
  }

Router.route '/hints/:_id', ->
  Session.set 'commentsByPopularity', null
  Session.set 'commentsByDate', null
  @render 'Sidebar', {to: 'Sidebar'}
  @render 'CommentSection'
, {waitOn: ->
     if Meteor?.userId()
       cols = ['Pages', 'Markets', 'ContractsHints', 'HintsLikeDisLike', 'ReplyLikeDislike', 'Comments']
       _.map cols, (col) ->
         TAPi18n.subscribe col
  }

Router.route '/contract/:_id', ->
  @render 'Sidebar', {to: 'Sidebar'}
  @render 'Contractset'
, {waitOn: ->
     if Meteor?.userId()
       cols = ['Pages', 'Markets']
       _.map cols, (col) ->
         TAPi18n.subscribe col
  }

Router.route '/markets/', ->
  @render 'Sidebar', {to: 'Sidebar'}
  @render 'MarketList'
, {waitOn: ->
     if Meteor?.userId()
       cols = ['Pages', 'Markets', "Contracts", "Contractsets"]
       _.map cols, (col) ->
         TAPi18n.subscribe col
  }

Router.route '/hint/', ->
  @render 'Sidebar', {to: 'Sidebar'}
  @render 'AddHintUser'
, {waitOn: ->
     if Meteor?.userId()
       cols = ['Pages', 'Markets', "Contracts", "Contractsets"]
       _.map cols, (col) ->
         TAPi18n.subscribe col
  }

Router.route '/admin', ->
  if not Meteor?.user()?.profile?.admin
    @redirect '/markets'
  else
    @render 'AdminSidebar', {to: 'Sidebar'}
    @render 'AdminMain'
, {name: 'admin', waitOn: ->
     if Meteor?.user()?.profile?.admin
       subs = _.map ['userData', 'Pages', 'Markets', 'Contractsets', 'Contracts', 'Images', 'Filters', 'Comments'], (col) ->
         TAPi18n.subscribe col
       subs.push Meteor.subscribe 'Activities', 100
       subs
  }
