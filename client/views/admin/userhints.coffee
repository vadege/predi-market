
formatDate = (date) ->
  moment.locale TAPi18n.getLanguage()
  value = moment(date).format('MMMM Do YYYY, h:mm a');
  value




Template.ListHints.helpers
  hints: ->
    value = Contracts.find({mirror: {$not: true}}).fetch()
    hintUpdatedArr = [];
    i = 0
    while i < value.length
      Session.set 'date', value[i].set_id
      contract_title = value[i].title
      hintArr = value[i].hints
      j = 0
      while j < hintArr.length
        if hintArr[j].isAdmin == false && hintArr[j].approved == false
          hintArr[j]['title'] = contract_title
          hintUpdatedArr.push(hintArr[j])
        j++
      i++
    return hintUpdatedArr

  formattedDate: formatDate

  date: ->
    id = Session.get 'date'
    value = Contractsets.findOne({_id: id}, {fields: {launchtime: 1}})
    return value.launchtime

Template.ListHints.events
  'click .approve_hint': (evt, tmpl) ->
    evt.stopPropagation()
    id = evt.currentTarget.id
    value = evt.currentTarget.value
    Meteor.call 'approveHint', value, (error, result) ->
      if error
        $(".error").show()
        Meteor.setTimeout (->
          $(".error").hide()
        ), 3000
      else
        $(".success").show()
        Meteor.setTimeout (->
          $(".success").hide()
        ), 3000
      true

  'click .delete_hint': (evt,tmpl) ->
    evt.stopPropagation()
    id= evt.currentTarget.id
    value = evt.currentTarget.value
    Meteor.call 'removeUserHint', id, value, (error, result) ->
      if error
        $(".error").show()
        Meteor.setTimeout (->
          $(".error").hide()
        ), 3000
      else
        $(".delete").show()
        Meteor.setTimeout (->
          $(".delete").hide()
        ), 3000
      true
