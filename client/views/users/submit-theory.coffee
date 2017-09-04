Template.SubmitTheory.rendered = ->
  ga('send', 'event', 'SubmtiTheory', 'submit')

Template.SubmitTheory.events
  'click input': (evt, tmpl) ->
    evt.preventDefault()
    $('.error_class').hide()

  'click textarea': (evt, tmpl) ->
    evt.preventDefault()
    $('.error_class').hide()

  'click .add_theory': (evt, tmpl) ->
    evt.preventDefault()
    title = $('.title').val()
    desc = $('.desc').val()
    if title == "" || desc == ""
      $('.error_class').show()
      return
    Meteor.call 'addUserTheory', title, desc, (error, result) ->
      if error
        $(".error").show()
        Meteor.setTimeout (->
          $(".error").hide()
        ), 3000
      else
        $(".success").show()
        Meteor.setTimeout (->
          $(".success").hide()
          Router.go '/submit-theory/'
        ), 3000

  'click .back': (evt, tmpl) ->
    evt.preventDefault()
    Router.go '/submit-theory'
