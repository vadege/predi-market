Template.Dashboard.rendered = ->
  ga('send', 'event', 'Dashboard', 'select')
  Session.set 'contracts', null

Template.Dashboard.events
  'click .dashlinks': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    Session.set 'category', id
    Router.go '/markets'

  'keyup .search': (evt, tmpl) ->
    val = $('.search').val()
    if val == ""
      Session.set 'contracts', []
    else
      Meteor.call 'findContract', val, (error, result) ->
          if error
            console.log error
          else
            if result.length > 0
              Session.set 'contracts', result

  'click .go': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).attr("data-id")
    value = $(evt.currentTarget).attr("data-value")
    if value.length > 0
      val = value[0]
    Router.go '/market/' + id + '?' + 'category=' + val

Template.Dashboard.helpers

  contract: ->
    value = Session.get 'contracts'
    if value.length > 0
      return value
    else
      return
