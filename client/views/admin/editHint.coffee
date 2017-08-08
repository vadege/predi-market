Template.EditHint.helpers
    hint: ->
      value = Session.get 'hint_value'
      if value
        contract = Contracts.findOne({"hints.id": value}, {fields: {hints: 1}})
        if contract
          hintArr = contract.hints
          val = hintArr.filter (d) ->
            return d.id == value
          return val[0]

Template.EditHint.events
  'click .submit_hint': (evt, tmpl) ->
    id = evt.currentTarget.id
    val = evt.currentTarget.value
    hint = $(".hint").val()
    desc = $(".hint_val").val()
    update = true
    Meteor.call 'addUserHint',{},hint, desc, id, update, val, (error, result) ->
      if error
        console.log(error)
      else
        Session.set 'hint_value', null
        Session.set 'admin_section', 'hints'

  'click .back': (evt, tmpl) ->
    Session.set 'admin_section', 'hints'
