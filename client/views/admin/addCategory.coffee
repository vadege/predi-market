Template.AddCategory.events
  'blur .category': (evt, tmpl) ->
    evt.preventDefault()
    val = $('.category').val()
    id = evt.currentTarget.id
    Meteor.call 'addCategory', id, val, (error, result) ->
      if error
        console.log error
      true
