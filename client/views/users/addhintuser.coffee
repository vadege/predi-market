Template.AddHintUser.events
  'click .add_hint': (evt, tmpl) ->
    evt.stopPropagation()
    hint = $(".hint").val()
    desc = $(".hint_val").val()
    contract_id = Session.get 'buttonId'
    market_id = Session.get 'market_id'
    Session.set 'buttonId', null
    Session.set 'market_id', null
    console.log(market_id)
    hint = {
      hint: hint
      desc: desc
      id: new Meteor.Collection.ObjectID()._str
      approved: false
      contract_id: contract_id
    }
    Meteor.call 'addUserHint', hint, contract_id, (error, result) ->
      if error
        console.log ('Cannot save your hint. Please try again.');
      else
        console.log ('Hint saved successfully');
      Router.go('/market/'+market_id)
