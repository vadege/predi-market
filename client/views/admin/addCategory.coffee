Template.AddCategory.events
  'click .selectpicker': (evt, tmpl) ->
    evt.preventDefault()
    val = $('.selectpicker').val()
    id = evt.currentTarget.id
    Meteor.call 'addCategory', id, val, (error, result) ->
      if error
        console.log error
      true
