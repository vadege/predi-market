Template.ShowHint.events
  'click .hint_div': (evt,tmpl) ->
    id = evt.currentTarget.id
    category = Router.current().params.query.category
    Session.set 'category', category
    Router.go '/hints/' +id

Template.ShowHint.rendered = ->
  ga('send', 'event', 'ShowHint', 'read')
