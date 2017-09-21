Template.Dashboard.rendered = ->
  ga('send', 'event', 'Dashboard', 'select')

Template.Dashboard.events
  'click .dashlinks': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    Session.set 'category', id
    Router.go '/markets'
