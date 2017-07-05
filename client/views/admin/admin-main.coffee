# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.AdminMain.helpers
  Markets: ->
    Markets.find()

  Pages: ->
    Pages.find()

  Users: ->
    Meteor.users()

  Settings: ->
    Settings.find()

  markets: ->
    Session.get('admin_section') is 'markets' or
    not Session.get('admin_section')

  users: ->
    Session.get('admin_section') is 'users'

  log: ->
    Session.get('admin_section') is 'log'

  pages: ->
    Session.get('admin_section') is 'pages'

  settings: ->
    Session.get('admin_section') is 'settings'

  hints: ->
    Session.get('admin_section') is "hints"

  logOptions: ->
    # handle: activitiesHandle

Template.AdminMain.events
  'click .add_market': (evt, tmpl) ->
    evt.stopPropagation()
    market = {
      title: ""
      initial_money: 10000
      description: ""
      tags: []
    }

    Meteor.call 'addMarket', market, (error, result) ->
      if error
        Errors.throw error
    Deps.flush()

  'click .add_page': (evt, tmpl) ->
    evt.stopPropagation()
    page = {
      title: ""
      content: ""
    }

    Meteor.call 'addPage', page, (error, result) ->
      if error
        Errors.throw error
    Deps.flush()
