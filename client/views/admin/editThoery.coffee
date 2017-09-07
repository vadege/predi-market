Template.EditTheory.rendered = ->
  ga('send', 'event', 'EditHint', 'submit')

Template.EditTheory.helpers
    theory: ->
      value = Session.get 'theory_value'
      if value
        theory = Theories.findOne({_id: value})
        if theory
          return theory

Template.EditTheory.events
  'click .submit_theory': (evt, tmpl) ->
    id = evt.currentTarget.id
    theory = $(".theory").val()
    desc = $(".theory_val").val()
    update = true
    Meteor.call 'addUserTheory',theory, desc, id, update, (error, result) ->
      if error
        console.log(error)
      else
        Session.set 'theory_value', null
        Session.set 'admin_section', 'theories'

  'click .back': (evt, tmpl) ->
    Session.set 'admin_section', 'theories'
