Template.EmailSent.events
  'click #ok': (evt, tmpl) ->
    Router.go '/'

Template.EmailSent.rendered = ->
  $("#ok").focus()
  $('.remove-class').removeClass("landing-logo")
