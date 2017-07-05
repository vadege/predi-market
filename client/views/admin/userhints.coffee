Template.ListHints.helpers
  hints: ->
    value = Contracts.find({mirror: {$not: true}}).fetch()
    hintUpdatedArr = [];
    i = 0
    while i < value.length
      hintArr = value[i].hints
      j = 0
      while j < hintArr.length
        if hintArr[j].approved == false
          hintUpdatedArr.push(hintArr[j])
        j++
      i++
    return hintUpdatedArr

Template.ListHints.events
  'click .approve_hint': (evt, tmpl) ->
    evt.stopPropagation()
    id = evt.currentTarget.id
    value = evt.currentTarget.value
    Meteor.call 'approveHint', value, (error, result) ->
      if error
        Error.throw error
      true

  'click .delete_hint': (evt,tmpl) ->
    evt.stopPropagation()
    id= evt.currentTarget.id
    value = evt.currentTarget.value
    Meteor.call 'disapproveHint', id, value, (error, result) ->
      if error
        Error.throw error
      true
