Template.showTheory.rendered = ->
  ga('send', 'event', 'ShowTheory', 'read')

Template.showTheory.helpers
  theory: ->
    return Theories.find({approved: true})

Template.showTheory.events
  'click .submit_theory': (evt, tmpl) ->
    Router.go '/add-theory'

  'click .show_theory': (evt, tmpl) ->
    id = evt.currentTarget.id
    Router.go '/theory/' + id
