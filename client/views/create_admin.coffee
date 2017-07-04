# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.CreateAdmin.events
  'click #create_admin': (evt, tmpl) ->
    evt.stopPropagation()
    username = $("#admin_username").val()
    name = $("#admin_name").val()
    email = $("#admin_email").val()
    password = $("#admin_password").val()
    repeat_password = $("#admin_repeat_password").val()
    with_data = $("#admin_generate_data").is ":checked"
    if username and name and email and password and repeat_password
      if password is repeat_password
        Accounts.createUser {username: username, email: email, password: password, profile: {name: name, admin: true, create_data: with_data}}, ->
          if with_data
            Meteor.call "mockData", Meteor.users.findOne({"profile.admin": true})._id, ->
              Router.go '/admin'

      else
        Errors.throw TAPi18n.__ "error_passwords_dont_match"
        return false
    else
      Errors.throw TAPi18n.__ "error_all_fields_obligatory"
      return false
    false

Template.CreateAdmin.rendered = ->
  $("#admin_username").focus()
