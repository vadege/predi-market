# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.Login.events
  'click #new_user': (evt, tmpl) ->
    evt.stopPropagation()
    Router.go '/new_user'
    false

  'click #forgot_pass': (evt, tmpl) ->
    evt.stopPropagation()
    username = $("#username").val()
    if username
      unless Meteor.status().connected
        Meteor.reconnect()
      # TODO: Check if valid email, throw error otherwise

      user = Meteor.users.findOne({username: username})
      if user?.emails[0]?.address
        Accounts.forgotPassword { "email": user.emails[0].address}
        Router.go '/email_sent'
      else
        Errors.throw TAPi18n.__ "error_user_not_found", username
    else
       Errors .throw TAPi18n.__ "error_username_missing"
    false

  'click #log_in': (evt, tmpl) ->
    evt.stopPropagation()
    username = $("#username").val()
    password = $("#password").val()
    if username and password
      unless Meteor.status().connected
        Meteor.reconnect()
      Meteor.loginWithPassword username, password, (error, result) ->
        if error
          Errors.throw TAPi18n.__ "error_login_failed"
        else
          user = Meteor.users.findOne({username: username})
          console.log user
          Router.go '/'
    else
      Errors.throw TAPi18n.__ "error_login_failed"
    false

Template.Login.rendered = ->
  $("#username").focus()
