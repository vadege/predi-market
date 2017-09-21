Template.Dashboard.events

  'click .dashlinks': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    console.log id

Template.Dashboard.rendered = ->
  console.log 'inside Dashboard'
