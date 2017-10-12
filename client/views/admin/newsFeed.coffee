Template.NewsFeed.helpers

  newsFeed: ->
    news = NewsFeed.find({}, {sort: {added: -1}}).fetch()
    if news.length > 0
      return news

  url:(comment) ->
    re = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
    commentUrl = comment.replace(re, "<a id='urlClass' href='$1'>$1</a>")
    comment = commentUrl.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1'+ "<br />" +'$2');
    return comment

  buttonCheck:(active) ->
    if active == false
      return true
    else
      return false

  format: (date) ->
    moment.locale TAPi18n.getLanguage()
    value = moment(date).format('MMMM Do YYYY, h:mm a');
    value

  contract: ->
    val = Session.get 'display'
    if val == "contract"
      return true

  hint: ->
    val = Session.get 'display'
    if val == "hint"
      return true

  facebook: ->
    val = Session.get 'display'
    if val == "facebook"
      return true

  instagram: ->
    val = Session.get 'display'
    if val == "instagram Post"
        return true

  twitter: ->
    val = Session.get 'display'
    if val == "twitter Post"
        return true

  youtube: ->
    val = Session.get 'display'
    if val == "youtube Post"
      return true

  reddit: ->
    val = Session.get 'display'
    if val == "reddit Post"
      return true

Template.NewsFeed.events

  'click .dropdown-item': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.value
    Session.set 'display', value

  'click .submit': (evt, tmpl) ->
    evt.preventDefault()
    link = $('.val').val()
    if link == ""
      $(".error").show()
      Meteor.setTimeout (->
        $(".error").hide()
      ), 2000
    type = Session.get 'display'
    if type == "hint"
      link = Session.get 'hintVal'
      typeofHint = $('.val').val()
      Meteor.call 'addHintToFeed', link, type, typeofHint, (error, result) ->
        if error
          console.log error
        else
          $('..link-add').show()
          Meteor.setTimeout (->
            $("..link-add").hide()
            Session.set 'admin_section', "markets"
          ), 2000
    else
      Meteor.call 'addLinkToFeed', type, link, (error, result) ->
        if error
          console.log error
        else
          $('.success').show()
          Meteor.setTimeout (->
            $(".success").hide()
            Session.set 'admin_section', "markets"
          ), 2000

  'blur .hint': (evt, tmpl) ->
    evt.preventDefault()
    value = $('.hint').val()
    if value == ""
      $(".error").show()
      Meteor.setTimeout (->
        $(".error").hide()
      ), 3000
    Session.set 'hintVal', value

  'click .delete_feed': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    result = confirm('Are you sure you want to deactivate news feed?')
    if result
      Meteor.call 'inactivateFeed', id, (error, result) ->
        if error
          $('.error_new').show()
          Meteor.setTimeout (->
            $(".error_new").hide()
          ), 1000
        else
          $('.delete').show()
          Meteor.setTimeout (->
            $(".delete").hide()
          ), 1000

  'click .approve_feed': (evt, tmpl) ->
    evt.preventDefault()
    id = evt.currentTarget.id
    result = confirm('Are you sure you want to activate news feed?')
    if result
      Meteor.call 'activateFeed', id, (err, res) ->
        if err
          console.log err
        else
          $('.feed-approve').show()
          Meteor.setTimeout (->
            $(".feed-approve").hide()
          ), 3000

  'click #urlClass': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.href
    window.open(value + location.search)

Template.NewsFeed.rendered = ->
  Session.set 'display', "contract"
