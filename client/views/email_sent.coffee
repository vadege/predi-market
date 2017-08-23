Template.EmailSent.events
  'click #ok': (evt, tmpl) ->
    Router.go '/'

Template.EmailSent.rendered = ->
  ga('send', 'event', 'Email', 'read')
  $("#ok").focus()
  $('.remove-class').removeClass("landing-logo")
