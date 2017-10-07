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

Template.NewsFeed.events

  'click .dropdown-item': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.value
    Session.set 'display', value


Template.NewsFeed.rendered = ->
  Session.set 'display', "contract"
