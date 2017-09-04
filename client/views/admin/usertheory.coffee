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
