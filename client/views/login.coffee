# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.Login.events

  'click #urlClass': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.href
    window.open(value + location.search)

  'click #new_user': (evt, tmpl) ->
    evt.stopPropagation()
    Router.go '/new_user'
    false

  'click .arrow-down': (evt, tmpl) ->
    evt.stopPropagation()
    $('html,body').animate({
      scrollTop: $(".white-container").offset().top + 1400},
     'slow');

  'click #forgot_pass': (evt, tmpl) ->
    evt.stopPropagation()
    value = $(".login-username").val()
    username = value.toLowerCase()
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
    value = $(".login-username").val()
    password = $(".login-password").val()
    username = value.toLowerCase()
    if username and password
      unless Meteor.status().connected
        Meteor.reconnect()
      Meteor.loginWithPassword username, password, (error, result) ->
        if error
          Errors.throw TAPi18n.__ "error_login_failed"
        else
          Router.go '/'
    else
      Errors.throw TAPi18n.__ "error_login_failed"
    false

  'click #create_user': (evt, tmpl) ->
    evt.stopPropagation()
    username = $(".register-username").val()
    email = $(".register-email").val()
    captchaData = grecaptcha.getResponse();

    if username and email
      Meteor.call "newUser", username, email, {}, captchaData, (error) ->
        grecaptcha.reset()
        if error
          Errors.throw TAPi18n.__ error.error
          return false
        else
          Meteor.call 'notifyAdminOnRegister', username, email
          Router.go '/email_sent'
    else
      Errors.throw TAPi18n.__ "error_all_fields_obligatory"
      return false
    false

Template.Login.rendered = ->
  ga('send', 'event', 'Login', 'submit')
  $('.remove-class').addClass("landing-logo")
