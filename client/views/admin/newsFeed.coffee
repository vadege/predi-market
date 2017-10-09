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
    type = Session.get 'display'
    console.log type, link
    Meteor.call 'addLinkToFeed', type, link, (error, result) ->
      if error
        console.log error
      else
        $('.success').show()
        Meteor.setTimeout (->
          $(".success").hide()
          Session.set 'admin_section', "markets"
        ), 3000

Template.NewsFeed.rendered = ->
  Session.set 'display', "contract"
