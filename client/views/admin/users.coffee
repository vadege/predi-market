# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.AdminUsers.helpers
  Users: ->
    Meteor.users.find()

  User: ->
    if Session.get 'selected_user'
      Meteor.users.find {_id: Session.get('selected_user')}

  Markets: ->
    if Session.get 'selected_user'
      user = Meteor.users.findOne {_id: Session.get('selected_user')}
      if user
        tags = user.profile.tags
        markets = Markets.find {tags: {$in: tags}}
        _.map markets.fetch(), (market) ->
          cash = user.profile.cash[market._id] or 0
          contracts = _.chain Contracts.find({market_id: market._id}).fetch()
            .map (contract) ->
              portfolio = user.profile.portfolio[contract._id] or 0
              _.extend contract, {portfolio: portfolio}
            .filter (contract) ->
              return user.profile.portfolio[contract._id] > 0
            .value()
          _.extend market, {cash: {value: cash, data: user._id}, contracts: contracts}


  admin: ->
    if Session.get 'selected_user'
      user = Meteor.users.findOne {_id: Session.get('selected_user')}
      user.profile.admin is true

  adminstring: ->
    TAPi18n.__ 'button_administrator'

  tags: ->
    _.map @profile.tags, (tag) ->
      {tag: tag}

  selected: ->
    Session.get 'selected_user' is @_id


Template.AdminUsers.events
  'click tbody>tr': (evt, tmpl) ->
    Session.set 'selected_user', @_id

  'click #dismiss_user_controls': (evt, tmpl) ->
    Session.set 'selected_user', undefined

  'click #reset_password': (evt, tmpl) ->
    true

  'change #set_admin': (evt, tmpl) ->
    evt.stopPropagation()
    value = evt.target.checked

    Meteor.call 'setAdmin', value, @_id, (error, result) ->
      if error
        Errors.throw error.message
    Deps.flush()
    true

