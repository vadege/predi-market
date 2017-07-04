# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

# Accounts.config sendVerificationEmail: true
Activities.allow
  update: ->

Meteor.users.deny {update: -> true}

Images.allow
  download: -> true
  insert: (userId, doc) ->
    Meteor.users.findOne({_id: userId})?.profile?.admin
  update: (userId, doc) ->
    Meteor.users.findOne({_id: userId})?.profile?.admin
  remove: (userId, doc) ->
    Meteor.users.findOne({_id: userId})?.profile?.admin

Accounts.onCreateUser (options, user) ->
  if options.profile
    user.profile = options.profile
  else
    user.profile = {}

  unless user.profile.tags?
    user.profile.tags = []
  user.profile.cash = {}
  user.profile.portfolio = {}
  user.profile.preferred_lang = Settings.findOne().default_language

  adduser_log =
    timestamp: Date.now()
    type: "adduser"
    user_id: "system"
    value: {emails: user.emails, username: user.username, profile: user.profile}

  Activities.insert adduser_log
  user

Accounts.onLogin (details) ->
  login_log =
    timestamp: Date.now()
    type: "login"
    user_id: details.user._id
    value: {username: details.user.username, ip: details.connection.clientAddress}

  Activities.insert login_log
