
formatDate = (date) ->
  moment.locale TAPi18n.getLanguage()
  value = moment(date).format('MMMM Do YYYY, h:mm a');
  value

commentDate = (date) ->
  moment.locale TAPi18n.getLanguage()
  value = moment(date).format('MMMM Do YYYY, h:mm a');
  value

likedislike = (id) ->
  value = Comments.findOne({_id: id})
  if value
    likeArr = value.likes
    dislikesArr = value.dislikes
    likesLen = likeArr.length
    dislikesLen = dislikesArr.length
    return likesLen - dislikesLen
  else
    return 0

replyLikeCount = (id) ->
  value = ReplyLikeDislike.findOne({reply_id: id})
  if value
    likeArr = value.likes
    dislikesArr = value.dislikes
    likesLen = likeArr.length
    dislikesLen = dislikesArr.length
    return likesLen - dislikesLen
  else
    return 0

Template.CommentSection.rendered = ->
  ga('send', 'event', 'CommentSection', 'read')
  $(".add_comment").focus()
  Session.set 'show_less', false
  Session.set 'show', null
  hint_id = Router.current().params._id
  Meteor.call 'showCommentsByPopularity', hint_id, (error, result) ->
    if error
      console.log(error)
    else
      Session.set 'commentsByDate', null
      Session.set 'commentsByPopularity', result

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
    else
      return 0

  comments: ->
    hint_id = Router.current().params._id
    value = Comments.find({hint_id: hint_id}).fetch()
    popularity = Session.get 'commentsByPopularity'
    date = Session.get 'commentsByDate'
    replyAdded = Session.get 'replyAdded'
    if popularity
      return popularity
    else if date
      return date
    else
      return value

  replies: (comment_id)->
    value = Comments.findOne({_id: comment_id})
    replies = value.replies
    show = Session.get 'show'
    if replies.length <= 2 || show == comment_id
      return replies
    else
      return replies.splice(0,2)

  length: (replies) ->
    if replies.length > 2
      return 3

  Select: ->
    popularity = Session.get 'commentsByPopularity'
    date = Session.get 'commentsByDate'
    if popularity
      Session.set 'Select', 'popular'
      return "Popular"
    else if date
      Session.set 'Select', 'date'
      return "New"
    else
      Session.set 'Select', null
      return "New"

  url:(comment) ->
    re = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
    commentUrl = comment.replace(re, "<a id='urlClass' href='$1'>$1</a>")
    comment = commentUrl.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1'+ "<br />" +'$2');
    return comment

  username: (username) ->
    if username
      return true
    else
      return

  user: (user) ->
    username = Meteor.user().username
    name = Meteor.user().profile.name
    if user == username || user == name
      return true
    else
      return

  formattedDate: formatDate

  commenttedDate: commentDate

  format: (date) ->
    moment.locale TAPi18n.getLanguage()
    value = moment(date).format('MMMM Do YYYY, h:mm a');
    value

  nooflikes: likedislike

  nooflikesReply: replyLikeCount

Template.CommentSection.events
  # 'paste .add_comment': (evt, tmpl) ->
  #   evt.preventDefault();
  #
  # 'paste .reply': (evt, tmpl) ->
  #   evt.preventDefault();

  'click .add_comment': (evt, tmpl) ->
      evt.stopPropagation()
      $(".error_class").hide()

  'click .cancel_hint': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).data("id")
    $(".reply").hide()
    $(".submit_reply").hide()
    $('.cancel_hint').hide()

  'click .save_comment': (evt, tmpl) ->
    evt.stopPropagation()
    comment = $(".add_comment").val()
    if (comment == "")
      $(".error_class").show()
      Meteor.setTimeout (->
        $(".error_class").hide()
      ), 3000
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
    category = Session.get 'category'
    Router.go '/market/' + marketid + '?' + 'category=' + category

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
    id = $(evt.currentTarget).attr("data-id")
    Meteor.call 'likeComment', id, (error, result) ->
      if error
        Error.throw error
      true

  'click .dislike_comment': (evt, tmpl) ->
    evt.stopPropagation()
    id = $(evt.currentTarget).attr("data-id")
    Meteor.call 'dislikeComment', id, (error, result) ->
      if error
        Error.throw error
      true

  'click .reply_click': (evt, tmpl) ->
    id = $(evt.currentTarget).data("id")
    Session.set 'id' , id
    if Session.get 'id'
      $(".reply").hide()
      $(".submit_reply").hide()
      $('.cancel_hint').hide()
    $("#input_"+id).show()
    $("#input_"+id).focus()
    $("#button_"+id).show()
    $('#cancel_'+id).show()

  'click .reply': (evt, tmpl) ->
    id = $(evt.currentTarget).data("id")
    $(".error_reply#"+id).hide()

  'click .submit_reply': (evt, tmpl) ->
    hint_id = Router.current().params._id
    id = $(evt.currentTarget).data("id")
    reply = $("#input_"+id).val()
    if reply == ""
      $(".error_reply#"+id).show()
      Meteor.setTimeout (->
        $(".error_reply#"+id).hide()
      ), 3000
      return
    Meteor.call 'addReplyToComment', id, reply, (error, result) ->
      if error
        $(".error_reply#"+id).show()
        Meteor.setTimeout (->
          $(".error_reply#"+id).hide()
        ), 3000
      else
        $(".reply").hide()
        $(".submit_reply").hide()
        $('.cancel_hint').hide()
        val = Session.get 'Select'
        if val == "popular"
          Meteor.call 'showCommentsByPopularity', hint_id, (error, result) ->
            if error
              console.log(error)
            else
              Session.set 'commentsByDate', null
              Session.set 'commentsByPopularity', result
        else if val == "date"
          Meteor.call 'showCommentsByDate', hint_id, (error, result) ->
            if error
              console.log(error)
            else
              Session.set 'commentsByPopularity', null
              Session.set 'commentsByDate', result
        else
          Session.set 'commentsByPopularity', null
          Session.set 'commentsByDate', null
        $(".reply#"+id).hide()
        $(".reply").val("")
        $(".submit_reply#"+id).hide()
        $(".success_reply#"+id).show()
        Meteor.setTimeout (->
          $(".success_reply#"+id).hide()
        ), 3000

  'click .delete_click': (evt, tmpl) ->
    hint_id = Router.current().params._id
    id = $(evt.currentTarget).data("id")
    result = confirm('Are you sure you want to delete comment?')
    if result
      Meteor.call 'deleteComment', id, (error, result) ->
        if error
          $(".delete_error#"+id).show()
          Meteor.setTimeout (->
            $(".delete_error#"+id).hide()
          ), 1000
        else
          val = Session.get 'Select'
          if val == "popular"
            Meteor.call 'showCommentsByPopularity', hint_id, (error, result) ->
              if error
                console.log(error)
              else
                Session.set 'commentsByDate', null
                Session.set 'commentsByPopularity', result
          else if val == "date"
            Meteor.call 'showCommentsByDate', hint_id, (error, result) ->
              if error
                console.log(error)
              else
                Session.set 'commentsByPopularity', null
                Session.set 'commentsByDate', result
          else
            Session.set 'commentsByPopularity', null
            Session.set 'commentsByDate', null
    else
      return

  'click .delete_reply': (evt, tmpl) ->
    hint_id = Router.current().params._id
    id = $(evt.currentTarget).data("id")
    value = evt.currentTarget.value
    name = evt.currentTarget.name
    result = confirm('Are you sure you want to delete reply?')
    if result
      Meteor.call 'deleteReply', id, value, name, (error, result) ->
        if error
          $(".delete_error#"+id).show()
          Meteor.setTimeout (->
            $(".delete_error#"+id).hide()
          ), 1000
        else
          val = Session.get 'Select'
          if val == "popular"
            Meteor.call 'showCommentsByPopularity', hint_id, (error, result) ->
              if error
                console.log(error)
              else
                Session.set 'commentsByDate', null
                Session.set 'commentsByPopularity', result
          else if val == "date"
            Meteor.call 'showCommentsByDate', hint_id, (error, result) ->
              if error
                console.log(error)
              else
                Session.set 'commentsByPopularity', null
                Session.set 'commentsByDate', result
          else
            Session.set 'commentsByPopularity', null
            Session.set 'commentsByDate', null
    else
      return

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

  'click #urlClass': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.href
    window.open(value + location.search)

  'click .show_more': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).data("id")
    Session.set 'show' , id
    Session.set 'show_less', true
    $(".show_more#"+id).hide()
    $(".show_less#"+id).show()

  'click .show_less': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).data("id")
    Session.set 'show' , null
    Session.set 'show_less', false
    $(".show_less#"+id).hide()
    $(".show_more#"+id).show()
