Template.ListTheory.rendered = ->
  ga('send', 'event', 'ListTheory', 'read')

Template.ListTheory.helpers
  theory: ->
    theories = Theories.find({}).fetch()
    return theories

  format: (date) ->
    moment.locale TAPi18n.getLanguage()
    value = moment(date).format('MMMM Do YYYY, h:mm a');
    value

  buttonCheck:(approved) ->
    if approved == false
      return true

Template.ListTheory.events
  'click .approve_theory': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    Meteor.call 'approveTheory', id, (error, result) ->
      if error
        Error.throw error
      true

  'click .delete_theory': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    Meteor.call 'deleteTheory', id, (error, result) ->
      if error
        Error.throw error
      true
