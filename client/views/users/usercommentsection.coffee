
formatDate = (date) ->
  moment.locale TAPi18n.getLanguage()
  value = moment(date).format('MMMM Do YYYY, h:mm a');
  value

commentDate = (date) ->
  moment.locale TAPi18n.getLanguage()
  value = moment(date).format('MMMM Do YYYY');
  value

likedislike = (id) ->
  value = Comments.findOne({_id: id})
  likeArr = value.likes
  dislikesArr = value.dislikes
  likesLen = likeArr.length
  dislikesLen = dislikesArr.length
  return likesLen - dislikesLen

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
    value =  HintsLikeDisLike.findOne({"hint_id": hint_id})
    if value
      likesArr = value.likes
      likeslength = likesArr.length
      dislikesArr = value.dislikes
      dislikeslength = dislikesArr.length
      return likeslength - dislikeslength

  comments: ->
    hint_id = Router.current().params._id
    value = Comments.find({hint_id: hint_id})
    return value.fetch()

  formattedDate: formatDate

  commenttedDate: commentDate

  nooflikes: likedislike

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
        $(".error").show()
        Meteor.setTimeout (->
          $(".error").hide()
        ), 3000
      else
        $(".success").show()
        Meteor.setTimeout (->
          $(".success").hide()
        ), 3000

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

  'click .like_comment': (evt, tmpl) ->
    evt.stopPropagation()
    id = evt.currentTarget.id
    Meteor.call 'likeComment', id, (error, result) ->
      if error
        Error.throw error
      true

  'click .dislike_comment': (evt, tmpl) ->
    evt.stopPropagation()
    id = evt.currentTarget.id
    Meteor.call 'dislikeComment', id, (error, result) ->
      if error
        Error.throw error
      true

  'click .reply_click': (evt, tmpl) ->
    id = evt.currentTarget.id
    $(".reply#"+id).show()

  'blur .reply': (evt, tmpl) ->
    reply = evt.currentTarget.value
    id = evt.currentTarget.id
    console.log(reply,id)
    Meteor.call 'addReplyToComment', id, reply, (error, result) ->
      if error
        Error.throw error
      else
        $(".reply#"+id).hide()
