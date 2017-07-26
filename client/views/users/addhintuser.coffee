Template.AddHintUser.events
  'click .hint': (evt, tmpl) ->
    evt.stopPropagation()
    $(".error").hide()
  'click .hint_val': (evt, tmpl) ->
    evt.stopPropagation()
    $(".error").hide()

  'click .add_hint': (evt, tmpl) ->
    evt.stopPropagation()
    hint = $(".hint").val()
    desc = $(".hint_val").val()
    contract_id = Session.get 'buttonId'
    Session.set 'buttonId', null
    market_id = Session.get 'market_id'
    if (hint == "" || desc == "")
      $(".error").show()
      return
    hint = {
      hint: hint
      desc: desc
      id: new Meteor.Collection.ObjectID()._str
      approved: false
      isAdmin: false
      contract_id: contract_id
    }
    Meteor.call 'addUserHint', hint, contract_id, (error, result) ->
      if error
        $(".error").show()
        Meteor.setTimeout (->
          $(".error").hide()
        ), 3000
      else
        $(".success").show()
        Meteor.setTimeout (->
          $(".success").hide()
          Router.go '/market/' +market_id
        ), 1000

  'click .back': (evt, tmpl) ->
    evt.stopPropagation()
    market_id = Session.get 'market_id'
    Router.go '/market/' +market_id
