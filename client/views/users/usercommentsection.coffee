
formatDate = (date) ->
  moment.locale TAPi18n.getLanguage()
  value = moment(date).format('MMMM Do YYYY, h:mm a');
  value

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

  totalLikes: ->
    hint_id = Router.current().params._id
    value = Contracts.findOne({"hints.id": hint_id}, {fields: {hints: 1}})
    hintArr = value.hints
    likes = hintArr.filter (d) ->
            return d.id == hint_id
    if likes[0].likes?
      len = likes.length
    else
      len = 0
    return len

  comments: ->
    hint_id = Router.current().params._id
    value = Comments.find({hint_id: hint_id}, {sort: {"user.commentedOn": 1}})
    return value.fetch()

  formattedDate: formatDate

Template.CommentSection.events
  'click .add_comment': (evt, tmpl) ->
      evt.stopPropagation()
      $(".error").hide()

  'click .save_comment': (evt, tmpl) ->
    evt.stopPropagation()
    comment = $(".add_comment").val()
    if (comment == "")
      $(".error").show()
      return;
    $(".add_comment").val("")
    contractid = Session.get 'contractid'
    marketid = Session.get 'marketid'
    hint_id = evt.currentTarget.id
    Session.set 'contractid', null
    Meteor.call 'addComment', comment, contractid, hint_id, (error, result) ->
      if error
        Error.throw error
      else
        console.log("added comment successfully")

  'click .back': (evt, tmpl) ->
    evt.stopPropagation()
    marketid = Session.get 'marketid'
    Session.set 'marketid', null
    Router.go '/market/' + marketid

  'click .like': (evt, tmpl) ->
    evt.stopPropagation()
    id = evt.currentTarget.id
    Meteor.call 'addLike', id, (error, result) ->
      if error
        Error.throw error
      true

  'click .dislike': (evt,tmpl) ->
    evt.stopPropagation()
    id = evt.currentTarget.id
    Meteor.call 'removeLike', id, (error, result) ->
      if error
        Error.throw error
      true
