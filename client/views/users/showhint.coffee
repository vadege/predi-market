Template.ShowHint.events
  'click .hint_div': (evt,tmpl) ->
    id = evt.currentTarget.id
    Router.go '/hints/' +id

Template.ShowHint.rendered = ->
  ga('send', 'event', 'ShowHint', 'read')
