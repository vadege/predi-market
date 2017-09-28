Template.Dashboard.rendered = ->
  ga('send', 'event', 'Dashboard', 'select')
  Session.set 'contracts', null

Template.Dashboard.events
  'click .dashlinks': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    Session.set 'category', id
    Router.go '/markets'

  'keypress .search': (evt, tmpl) ->
    if evt.which == 13
      val = $('.search').val()
      Meteor.call 'findContract', val, (error, result) ->
        if error
          console.log error
        else
          if result.length > 0
            $('.categoryDisplay').hide()
            $('.showContracts').show()
            Session.set 'contracts', result
          else
            $('.categoryDisplay').hide()
            $('.findContract').show()
            Meteor.setTimeout ( ->
              $('.categoryDisplay').show()
              $('.findContract').hide()
              $('.search').val("")
            ), 2000

  'click .go': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).attr("data-id")
    value = $(evt.currentTarget).attr("data-value")
    Router.go '/market/' + id + '?' + 'category=' + value

Template.Dashboard.helpers

  contract: ->
    return Session.get 'contracts'
