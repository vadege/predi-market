Template.EmailSent.events
  'click #ok': (evt, tmpl) ->
    Router.go '/'

Template.NewUser.rendered = ->
  $("#ok").focus()
