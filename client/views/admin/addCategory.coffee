Template.AddCategory.events
  'click .dropdown-item': (evt, tmpl) ->
    evt.preventDefault()
    val = evt.currentTarget.value
    Session.set 'category_name', val
    id = $(evt.currentTarget).data("id")
    Meteor.call 'addCategory', id, val, (error, result) ->
      if error
        console.log error
      true

  'mouseenter .selected': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    $('#toggle_'+id).removeClass('fa-check-square')
    $('#toggle_'+id).addClass('fa fa-times')

  'mouseleave .selected': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    $('#toggle_'+id).removeClass('fa-times')
    $('#toggle_'+id).addClass('fa-check-square')

  'click .selected': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).data("id")
    val = $(evt.currentTarget).data("name")
    Session.set 'category_name', null
    Meteor.call 'removeCategory', id, val, (error, result) ->
      if error
        console.log error
      true

Template.AddCategory.helpers

  select: (value, category) ->
    i = 0
    if category
      while i < category.length
        if value == category[i]
          return true
        i++

  category_name: ->
    category_name = Session.get 'category_name'
    if category_name
      return category_name
    else
      return "Category"
