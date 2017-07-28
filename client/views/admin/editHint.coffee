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
    value = {
      hint: hint
      desc: desc
      id: val
      approved: true
      isAdmin: false
      contract_id: id
    }
    Meteor.call 'addUserHint',value, id, update, val, (error, result) ->
      if error
        console.log(error)
      else
        Session.set 'hint_value', value
        Session.set 'admin_section', 'hints'
