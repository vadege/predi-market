
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
  if value
    likeArr = value.likes
    dislikesArr = value.dislikes
    likesLen = likeArr.length
    dislikesLen = dislikesArr.length
    count = likesLen - dislikesLen
    if count > 0
      return likesLen
    else if count < 0
      return "-" + dislikesLen
    else
      return 0
  else
    return 0

replyLikeCount = (id) ->
  value = ReplyLikeDislike.findOne({reply_id: id})
  if value
    likeArr = value.likes
    dislikesArr = value.dislikes
    likesLen = likeArr.length
    dislikesLen = dislikesArr.length
    count = likesLen - dislikesLen
    if count > 0
      return likesLen
    else if count < 0
      return "-" + dislikesLen
    else
      return 0
  else
    return 0

Template.CommentSection.onrendered = ->
  Session.set 'commentsByPopularity', null
  Session.set 'commentsByDate', null

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
      count = likeslength - dislikeslength
      if count > 0
        return likeslength
      else if count < 0
        return "-" + dislikeslength
      else
        return 0
    else
      return 0

  comments: ->
    hint_id = Router.current().params._id
    value = Comments.find({hint_id: hint_id}).fetch()
    popularity = Session.get 'commentsByPopularity'
    date = Session.get 'commentsByDate'
    if popularity
      return popularity
    else if date
      return date
    else
      return value

  Select: ->
    popularity = Session.get 'commentsByPopularity'
    date = Session.get 'commentsByDate'
    if popularity
      return "Popularity"
    else if date
      return "Date"
    else
      return "Select"

  url:(comment) ->
    re = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
    commentUrl = comment.replace(re, "<a id='urlClass' href='$1'>$1</a>")
    return commentUrl

  formattedDate: formatDate

  commenttedDate: commentDate

  nooflikes: likedislike

  nooflikesReply: replyLikeCount

Template.CommentSection.events
  'paste .add_comment': (evt, tmpl) ->
    evt.preventDefault();

  'paste .reply': (evt, tmpl) ->
    evt.preventDefault();

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
        Session.set 'commentsByPopularity', null
        Session.set 'commentsByDate', null
        $(".success").show()
        Meteor.setTimeout (->
          $(".success").hide()
        ), 3000

  'click .back': (evt, tmpl) ->
    evt.stopPropagation()
    marketid = Session.get 'marketid'
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
    $(".submit_reply#"+id).show()

  'click .reply': (evt, tmpl) ->
    id = evt.currentTarget.id
    $(".error_reply#"+id).hide()

  'click .submit_reply': (evt, tmpl) ->
    id = evt.currentTarget.id
    reply = $(".reply#"+id).val()
    if reply == ""
      $(".error_reply#"+id).show()
      return
    Meteor.call 'addReplyToComment', id, reply, (error, result) ->
      if error
        $(".error_reply#"+id).show()
        Meteor.setTimeout (->
          $(".error_reply#"+id).hide()
        ), 3000
      else
        $(".reply#"+id).hide()
        $(".reply").val("")
        $(".submit_reply#"+id).hide()
        $(".success_reply#"+id).show()
        Meteor.setTimeout (->
          $(".success_reply#"+id).hide()
        ), 3000

  'click .delete_click': (evt, tmpl) ->
    id = evt.currentTarget.id
    Meteor.call 'deleteComment', id, (error, result) ->
      if error
        $(".delete_error#"+id).show()
        Meteor.setTimeout (->
          $(".delete_error#"+id).hide()
        ), 1000
      true

  'click .delete_reply': (evt, tmpl) ->
    id = evt.currentTarget.id
    value = evt.currentTarget.value
    name = evt.currentTarget.name
    Meteor.call 'deleteReply', id, value, name, (error, result) ->
      if error
        $(".delete_error#"+id).show()
        Meteor.setTimeout (->
          $(".delete_error#"+id).hide()
        ), 1000
      true

  'click .like_reply': (evt, tmpl) ->
    id = evt.currentTarget.id
    Meteor.call 'likeReply', id, (error, result) ->
      if error
        console.log(error)
      true

  'click .dislike_reply': (evt, tmpl) ->
    id = evt.currentTarget.id
    Meteor.call 'dislikeReply', id, (error, result) ->
      if error
        console.log(error)
      true

  'click .popularity': (evt, tmpl) ->
    hint_id = Router.current().params._id
    Meteor.call 'showCommentsByPopularity', hint_id, (error, result) ->
      if error
        console.log(error)
      else
        Session.set 'commentsByDate', null
        Session.set 'commentsByPopularity', result

  'click .date': (evt, tmpl) ->
    hint_id = Router.current().params._id
    Meteor.call 'showCommentsByDate', hint_id, (error, result) ->
      if error
        console.log(error)
      else
        Session.set 'commentsByPopularity', null
        Session.set 'commentsByDate', result

  'click .select': (evt, tmpl) ->
    hint_id = Router.current().params._id
    Meteor.call 'showCommentsInitial', hint_id, (error, result) ->
      if error
        console.log(error)
      else
        Session.set 'commentsByPopularity', null
        Session.set 'commentsByDate', null

  'click #urlClass': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.href
    window.open(value + location.search)
