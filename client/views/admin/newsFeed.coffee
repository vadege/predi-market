Template.NewsFeed.helpers

  contract: ->
    val = Session.get 'display'
    if val == "contract"
      return true

  hint: ->
    val = Session.get 'display'
    if val == "hint"
      return true

  facebook: ->
    val = Session.get 'display'
    if val == "facebook"
      return true

  instagram: ->
    val = Session.get 'display'
    if val == "instagram Post"
        return true

  twitter: ->
    val = Session.get 'display'
    if val == "twitter Post"
        return true

  youtube: ->
    val = Session.get 'display'
    if val == "youtube Post"
      return true

Template.NewsFeed.events

  'click .dropdown-item': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.value
    Session.set 'display', value

  'click .submit': (evt, tmpl) ->
    evt.preventDefault()
    link = $('.val').val()
    if link == ""
      $(".error").show()
      Meteor.setTimeout (->
        $(".error").hide()
      ), 3000
    type = Session.get 'display'
    if type == "hint"
      link = Session.get 'hintVal'
      typeofHint = $('.val').val()
      Meteor.call 'addHintToFeed', link, type, typeofHint, (error, result) ->
        if error
          console.log error
        else
          $('.success').show()
          Meteor.setTimeout (->
            $(".success").hide()
            Session.set 'admin_section', "markets"
          ), 3000
    else
      Meteor.call 'addLinkToFeed', type, link, (error, result) ->
        if error
          console.log error
        else
          $('.success').show()
          Meteor.setTimeout (->
            $(".success").hide()
            Session.set 'admin_section', "markets"
          ), 3000

  'blur .hint': (evt, tmpl) ->
    evt.preventDefault()
    value = $('.hint').val()
    if value == ""
      $(".error").show()
      Meteor.setTimeout (->
        $(".error").hide()
      ), 3000
    Session.set 'hintVal', value



Template.NewsFeed.rendered = ->
  Session.set 'display', "contract"
