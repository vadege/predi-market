Template.AddHint.events
  'blur .hint': (evt, tmpl) ->
    evt.stopPropagation()
    value = evt.currentTarget.value
    id = evt.currentTarget.id
    name = evt.currentTarget.name
    Meteor.call 'saveHint', value, id, name, (error, result) ->
      if error
        Error.throw error
      true

  'blur .hint_val': (evt, tmpl) ->
    evt.stopPropagation()
    value = evt.currentTarget.value
    id = evt.currentTarget.id
    name = evt.currentTarget.name
    Meteor.call 'saveHint', value, id, name, (error, result) ->
      if error
        Error.throw error
      true

  'click .remove_hint': (evt, tmpl) ->
    evt.stopPropagation()
    id = evt.currentTarget.id
    value = evt.currentTarget.value
    Meteor.call 'removeHint', id, value, (error, result) ->
      if error
        Error.throw error
      true
