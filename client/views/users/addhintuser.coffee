Template.AddHintUser.rendered = ->
  ga('send', 'event', 'hintSubmit', 'submit')
  $(".hint").focus()

Template.AddHintUser.events
  'click .hint': (evt, tmpl) ->
    evt.stopPropagation()
    $(".error").hide()
  'click .hint_val': (evt, tmpl) ->
    evt.stopPropagation()
    $(".error").hide()

  'click .add_hint': (evt, tmpl) ->
    evt.stopPropagation()
    username = Meteor.user().username
    hint = $(".hint").val()
    desc = $(".hint_val").val()
    contract_id = Session.get 'buttonId'
    category = Session.get 'category'
    Session.set 'buttonId', null
    id = Contracts.findOne({$and:[{set_id: contract_id}, {mirror: {$not: true}}]})
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
      contract_id: id._id
      username: username
      createdAt: new Date()
    }
    Meteor.call 'addUserHint', hint, "", "", contract_id, false, "", (error, result) ->
      if error
        $(".error").show()
        Meteor.setTimeout (->
          $(".error").hide()
        ), 3000
      else
        $(".success").show()
        Meteor.setTimeout (->
          $(".success").hide()
          Router.go '/market/' +market_id + '?' + 'category=' + category
          Session.set 'category', null
        ), 1000

  'click .back': (evt, tmpl) ->
    evt.stopPropagation()
    market_id = Session.get 'market_id'
    category = Session.get 'category'
    Router.go '/market/' +market_id + '?' + 'category=' + category
