Template.theoryCommentSection.rendered = ->
  ga('send', 'event', 'Leaderboard', 'read')
  $('.comment').focus()
  id = Router.current().params._id
  Meteor.call 'showNewestComments', id, (error, result) ->
    if error
      Error.throw error
    else
      Session.set 'newestTheoryComments', result
      Session.set 'popularTheoryComments', null

Template.theoryCommentSection.helpers
  theory: ->
    id = Router.current().params._id
    Theories.findOne({_id: id})

  likes: ->
    id = Router.current().params._id
    theory = Theories.findOne({_id: id }, {fields: {likes: 1, dislikes: 1}})
    likesArr = theory.likes
    dislikesArr  = theory.dislikes
    return likesArr.length - dislikesArr.length

  format: (date) ->
    moment.locale TAPi18n.getLanguage()
    value = moment(date).format('MMMM Do YYYY, h:mm a');
    value

  comments: ->
    id = Router.current().params._id
    comments = TheoriesComment.find({theoryId: id}).fetch()
    popular = Session.get 'popularTheoryComments'
    newest = Session.get 'newestTheoryComments'
    if popular
      return popular
    else if newest
      return newest
    else
      return comments

  replyArr: (comment_id)->
    value = TheoriesComment.findOne({_id: comment_id})
    replies = value.replies
    show = Session.get 'show'
    if replies.length <= 2 || show == comment_id
      return replies
    else
      return replies.splice(0,2)

  replylength: (replies) ->
    if replies.length > 2
      return 3

  length: ->
    id = Router.current().params._id
    comments = TheoriesComment.find({theoryId: id}).fetch()
    if comments.length > 0
      return true

  url:(comment) ->
    re = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
    commentUrl = comment.replace(re, "<a id='urlClass' href='$1'>$1</a>")
    comment = commentUrl.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1'+ "<br />" +'$2');
    return comment

  user: (user) ->
    username = Meteor.user().username
    if user == username
      return true
    else
      return

  nooflikesComments: (id) ->
    theory = TheoriesComment.findOne({_id: id }, {fields: {likes: 1, dislikes: 1}})
    likesArr = theory.likes
    dislikesArr  = theory.dislikes
    return likesArr.length - dislikesArr.length

  nooflikesReply: (id) ->
    reply = TheoriesReplyLikes.findOne({reply_id: id})
    if reply
      likesArr = reply.likes
      dislikesArr  = reply.dislikes
      return likesArr.length - dislikesArr.length
    else
      return 0

  Select: ->
    popularity = Session.get 'popularTheoryComments'
    date = Session.get 'newestTheoryComments'
    if popularity
      Session.set 'Select', 'popular'
      return "Popular"
    else if date
      Session.set 'Select', 'date'
      return "New"
    else
      Session.set 'Select', null
      return "New"

Template.theoryCommentSection.events
  'click .back': (evt, tmpl) ->
    evt.preventDefault()
    Router.go '/submit-theory'

  'click .comment': (evt, tmpl) ->
    evt.preventDefault()
    $('.error_class').hide()

  'click .theory_comment': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).attr("data-id")
    comment = $('.comment').val()
    theoryId = Router.current().params._id
    if comment == ""
      $('.error_class').show()
      Meteor.setTimeout (->
        $(".error_class").hide()
      ), 3000
      return
    Meteor.call 'addCommentOnTheory', id, comment, (error, result) ->
      if error
        $('.error').show()
        Meteor.setTimeout (->
          $(".error").hide()
        ), 3000
      else
        $('.comment').val("")
        val = Session.get 'Select'
        if val == 'date'
          Meteor.call 'showNewestComments', theoryId, (error, result) ->
            if error
              Error.throw error
            else
              Session.set 'newestTheoryComments', result
              Session.set 'popularTheoryComments', null
        else if val == "popular"
          Meteor.call 'showPopularComments', theoryId, (error, result) ->
            if error
              Error.throw error
            else
              Session.set 'newestTheoryComments', null
              Session.set 'popularTheoryComments', result
        else
          Session.set 'newestTheoryComments', null
          Session.set 'popularTheoryComments', null

  'click .reply_click': (evt, tmpl) ->
    id = $(evt.currentTarget).attr("data-id")
    Session.set 'id' , id
    if Session.get 'id'
      $(".reply").hide()
      $(".submit_reply").hide()
      $('.cancel').hide()
    $("#input_"+id).show()
    $("#input_"+id).focus()
    $("#button_"+id).show()
    $("#cancel_"+id).show()

  'click .cancel': (evt, tmpl) ->
    id = $(evt.currentTarget).attr("data-id")
    $(".reply").hide()
    $(".submit_reply").hide()
    $('.error_new#'+id).hide()
    $('.cancel').hide()

  'click .reply': (evt, tmpl) ->
    evt.preventDefault()
    $('.error_new').hide()

  'click .submit_reply': (evt, tmpl) ->
    id = $(evt.currentTarget).attr("data-id")
    reply = $('#input_'+id).val()
    theoryId = evt.currentTarget.value
    if reply == ""
      $('.error_new#'+id).show()
      Meteor.setTimeout (->
        $('.error_new#'+id).hide()
      ), 2000
      return
    Meteor.call 'addReplyToCommentTheory', id, reply, (error, result) ->
      if error
        $(".error_reply#"+id).show()
        Meteor.setTimeout (->
          $(".error_reply#"+id).hide()
        ), 3000
      else
        $(".reply").hide()
        $(".submit_reply").hide()
        $(".reply").val("")
        $(".submit_reply#"+id).hide()
        $('.cancel').hide()
        val = Session.get 'Select'
        if val == 'date'
          Meteor.call 'showNewestComments', theoryId, (error, result) ->
            if error
              Error.throw error
            else
              Session.set 'newestTheoryComments', result
              Session.set 'popularTheoryComments', null
        else if val == "popular"
          Meteor.call 'showPopularComments', theoryId, (error, result) ->
            if error
              Error.throw error
            else
              Session.set 'newestTheoryComments', null
              Session.set 'popularTheoryComments', result
        else
          Session.set 'newestTheoryComments', null
          Session.set 'popularTheoryComments', null

  'click .like': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).attr("data-id")
    Meteor.call 'likeTheory', id, (error, result) ->
      if error
        Error.throw error
      true

  'click .dislike': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).attr("data-id")
    Meteor.call 'dislikeTheory', id, (error, result) ->
      if error
        Error.throw error
      true

  'click #urlClass': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.href
    window.open(value + location.search)

  'click .delete_click': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).attr("data-id")
    theoryId = evt.currentTarget.value
    Meteor.call 'deleteTheoryComment', id, (error, result) ->
      if error
        Error.throw error
      else
        val = Session.get 'Select'
        if val == 'date'
          Meteor.call 'showNewestComments', theoryId, (error, result) ->
            if error
              Error.throw error
            else
              Session.set 'newestTheoryComments', result
              Session.set 'popularTheoryComments', null
        else if val == "popular"
          Meteor.call 'showPopularComments', theoryId, (error, result) ->
            if error
              Error.throw error
            else
              Session.set 'newestTheoryComments', null
              Session.set 'popularTheoryComments', result
        else
          Session.set 'newestTheoryComments', null
          Session.set 'popularTheoryComments', null

  'click .like_comment': (evt, tmpl) ->
    evt.preventDefault()
    id = $(evt.currentTarget).attr("data-id")
    Meteor.call 'likeTheoryComment', id, (error, result) ->
      if error
        Error.throw error
      true

   'click .dislike_comment': (evt, tmpl) ->
     evt.preventDefault()
     id = $(evt.currentTarget).attr("data-id")
     Meteor.call 'dislikeTheoryComment', id, (error, result) ->
       if error
         Error.throw error
       true

    'click .popularity': (evt, tmpl) ->
      evt.preventDefault()
      id = Router.current().params._id
      Meteor.call 'showPopularComments', id, (error, result) ->
        if error
          Error.throw error
        else
          Session.set 'popularTheoryComments', result
          Session.set 'newestTheoryComments', null

    'click .date': (evt, tmpl) ->
      evt.preventDefault()
      id = Router.current().params._id
      Meteor.call 'showNewestComments', id, (error, result) ->
        if error
          Error.throw error
        else
          Session.set 'newestTheoryComments', result
          Session.set 'popularTheoryComments', null

    'click .like_reply': (evt, tmpl) ->
      evt.preventDefault()
      id = $(evt.currentTarget).attr("data-id")
      Meteor.call 'addLikeToReply', id, (error, result) ->
        if error
          Error.throw error
        true

    'click .dislike_reply': (evt, tmpl) ->
      evt.preventDefault()
      id = $(evt.currentTarget).attr("data-id")
      Meteor.call 'addDislikeToReply', id, (error, result) ->
        if error
          Error.throw error
        true

    'click .delete_reply': (evt, tmpl) ->
      evt.preventDefault()
      id = $(evt.currentTarget).attr("data-id")
      theoryId = Router.current().params._id
      Meteor.call 'removeReplyTheory', id, (error, result) ->
        if error
          Error.throw error
        else
          val = Session.get 'Select'
          if val == 'date'
            Meteor.call 'showNewestComments', theoryId, (error, result) ->
              if error
                Error.throw error
              else
                Session.set 'newestTheoryComments', result
                Session.set 'popularTheoryComments', null
          else if val == "popular"
            Meteor.call 'showPopularComments', theoryId, (error, result) ->
              if error
                Error.throw error
              else
                Session.set 'newestTheoryComments', null
                Session.set 'popularTheoryComments', result
          else
            Session.set 'newestTheoryComments', null
            Session.set 'popularTheoryComments', null

    'click .show_more': (evt, tmpl) ->
      evt.preventDefault()
      id = $(evt.currentTarget).attr("data-id")
      Session.set 'show' , id
      Session.set 'show_less', true
      $("#more_"+id).hide()
      $("#less_"+id).show()

    'click .show_less': (evt, tmpl) ->
      evt.preventDefault()
      id = $(evt.currentTarget).attr("data-id")
      Session.set 'show' , null
      Session.set 'show_less', false
      $("#less_"+id).hide()
      $("#more_"+id).show()
