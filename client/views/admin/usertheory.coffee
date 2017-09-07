Template.ListTheory.rendered = ->
  ga('send', 'event', 'ListTheory', 'read')

Template.ListTheory.helpers
  theory: ->
    theories = Theories.find({}).fetch()
    theoriesUpdated = _.sortBy theories, 'addedOn'
    return theoriesUpdated.reverse()

  format: (date) ->
    moment.locale TAPi18n.getLanguage()
    value = moment(date).format('MMMM Do YYYY, h:mm a');
    value

  buttonCheck:(approved) ->
    if approved == false
      return true

  url:(comment) ->
    re = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
    commentUrl = comment.replace(re, "<a id='urlClass' href='$1'>$1</a>")
    return commentUrl

Template.ListTheory.events
  'click .approve_theory': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    Meteor.call 'approveTheory', id, (error, result) ->
      if error
        $('.error_new').show()
        Meteor.setTimeout (->
          $(".error_new").hide()
        ), 3000
      else
        $('.success').show()
        Meteor.setTimeout (->
          $(".success").hide()
        ), 3000

  'click .delete_theory': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    Meteor.call 'deleteTheory', id, (error, result) ->
      if error
        $('.error_new').show()
        Meteor.setTimeout (->
          $(".error_new").hide()
        ), 1000
      else
        $('.delete').show()
        Meteor.setTimeout (->
          $(".delete").hide()
        ), 1000

  'click .edit_theory': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    Session.set 'theory_value', id
    Session.set 'admin_section', 'editTheory'

  'click #urlClass': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.href
    window.open(value + location.search)
