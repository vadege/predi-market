Template.theoryCommentSection.rendered = ->
  ga('send', 'event', 'Leaderboard', 'read')
  $('.comment').focus()
  id = Router.current().params._id
  Meteor.call 'showPopularComments', id, (error, result) ->
    if error
      Error.throw error
    else
      Session.set 'newestTheoryComments', null
      Session.set 'popularTheoryComments', result

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

  length: ->
    id = Router.current().params._id
    comments = TheoriesComment.find({theoryId: id}).fetch()
    if comments.length > 0
      return true

  url:(comment) ->
    re = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
    commentUrl = comment.replace(re, "<a id='urlClass' href='$1'>$1</a>")
    comment = commentUrl.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1'+ "<br />" +'$2');
    console.log comment
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
      return "Popular"

Template.theoryCommentSection.events
  'click .back': (evt, tmpl) ->
    evt.preventDefault()
    Router.go '/submit-theory'

  'click .comment': (evt, tmpl) ->
    evt.preventDefault()
    $('.error_class').hide()

  'click .theory_comment': (evt, tmpl) ->
    evt.preventDefault()
    Session.set 'popularTheoryComments', null
    Session.set 'newestTheoryComments', null
    id = $(evt.currentTarget).attr("data-id")
    comment = $('.comment').val()
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
        $(".success").show()
        $('.comment').val("")
        Meteor.setTimeout (->
          $(".success").hide()
        ), 3000

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
    $('.cancel').hide()

  'click .reply': (evt, tmpl) ->
    evt.preventDefault()
    $('.error_new').hide()

  'click .submit_reply': (evt, tmpl) ->
    id = $(evt.currentTarget).attr("data-id")
    Session.set 'popularTheoryComments', null
    Session.set 'newestTheoryComments', null
    reply = $('#input_'+id).val()
    if reply == ""
      $('.error_new#'+id).show()
      Meteor.setTimeout (->
        $('.error_new#'+id).hide()
      ), 3000
      return
    Meteor.call 'addReplyToCommentTheory', id, reply, (error, result) ->
      if error
        $(".error_reply#"+id).show()
        Meteor.setTimeout (->
          $(".error_reply#"+id).hide()
        ), 3000
      else
        $(".submit_reply").val("")
        $(".reply").hide()
        $(".submit_reply").hide()
        $(".reply").val("")
        $(".submit_reply#"+id).hide()
        $(".success_reply#"+id).show()
        $('.cancel').hide()
        Meteor.setTimeout (->
          $(".success_reply#"+id).hide()
        ), 3000

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
    Session.set 'popularTheoryComments', null
    Session.set 'newestTheoryComments', null
    id = $(evt.currentTarget).attr("data-id")
    Meteor.call 'deleteTheoryComment', id, (error, result) ->
      if error
        Error.throw error
      true

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
      Session.set 'newestTheoryComments', null
      Session.set 'popularTheoryComments', null
      Meteor.call 'removeReplyTheory', id, (error, result) ->
        if error
          Error.throw error
        true
