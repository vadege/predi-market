Template.NewUser.events
  'click #create_user': (evt, tmpl) ->
    evt.stopPropagation()
    username = $("#username").val()
    name = $("#name").val()
    email = $("#email").val()
    captchaData = grecaptcha.getResponse();

    if name and username and email
      Meteor.call "newUser", username, email, {name: name}, captchaData, (error) ->
        grecaptcha.reset()
        
        if error
          Errors.throw TAPi18n.__ error.error
          return false
        else
          Router.go '/email_sent'
    else
      Errors.throw TAPi18n.__ "error_all_fields_obligatory"
      return false
    false

Template.NewUser.rendered = ->
  $("#username").focus()
