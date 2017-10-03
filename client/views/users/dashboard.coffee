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
      if val == ""
        $('.findContract').hide()
        $('.categoryDisplay').show()
        $('.showContracts').hide()
      else
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

  'click .go': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).attr("data-id")
    value = $(evt.currentTarget).attr("data-value")
    if value.length > 0
      val = value[0]
    Router.go '/market/' + id + '?' + 'category=' + val

Template.Dashboard.helpers

  contract: ->
    return Session.get 'contracts'
