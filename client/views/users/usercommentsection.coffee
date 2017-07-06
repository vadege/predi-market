
formatDate = (date) ->
  date.toDateString()

Template.CommentSection.helpers
  hints: ->
    hint_id = Router.current().params._id
    value = Contracts.findOne({"hints.id": hint_id})
    hintArr = value.hints
    Session.set 'contractid', value._id
    Session.set 'marketid', value.market_id
    val = hintArr.filter (d) ->
            return d.id == hint_id
    return val[0]

  comments: ->
    hint_id = Router.current().params._id
    value = Comments.find({hint_id: hint_id}).fetch()
    return value

  formattedDate: formatDate

Template.CommentSection.events
  'click .save_comment': (evt, tmpl) ->
    evt.stopPropagation()
    comment = $(".add_comment").val()
    contractid = Session.get 'contractid'
    marketid = Session.get 'marketid'
    hint_id = evt.currentTarget.id
    Session.set 'marketid', null
    Session.set 'contractid', null
    Meteor.call 'addComment', comment, contractid, hint_id, (error, result) ->
      if error
        Error.throw error
      else
        console.log("added comment successfully")
        Router.go '/market/' + marketid
