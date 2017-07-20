
formatDate = (date) ->
  moment.locale TAPi18n.getLanguage()
  value = moment(date).format('MMMM Do YYYY, h:mm a');
  value

Template.ListComment.helpers
  comments: ->
    comments = Comments.find({}).fetch()
    return comments

  url:(comment) ->
    re = /(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/
    if re.test comment
      return true
    else
      return false

  formattedDate: formatDate

Template.ListComment.events
  "click .url": (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.href
    window.open(value + location.search)

  'click .delete_comment': (evt, tmpl) ->
    id = evt.currentTarget.id
    Meteor.call 'deleteUserComment', id, (error, result) ->
      if error
        console.log(error)
      true
