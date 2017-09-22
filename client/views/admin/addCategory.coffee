Template.AddCategory.events
  'change .selectpicker': (evt, tmpl) ->
    evt.preventDefault()
    val = evt.currentTarget.value
    id = evt.currentTarget.id
    Meteor.call 'addCategory', id, val, (error, result) ->
      if error
        console.log error
      true

Template.AddCategory.helpers

  select: (value, category) ->
    if value == category
      return "true"
