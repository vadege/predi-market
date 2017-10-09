Template.NewsDisplay.helpers

  newsFeed: ->
    NewsFeed.find({}, {sort: {added: -1}}).fetch()

  displayType: (type) ->
    if type == "contract"
      return true

  contractset: (title) ->
    Meteor.call 'findContract', title, (error, result) ->
      if error
        console.log error
      console.log result[0]
      return result[0].title

  insta: (type) ->
    if type == "instagram Post"
      return true

  twitter: (type) ->
    if type == "twitter Post"
      return true

  facebook: (type) ->
    if type == "facebook"
      return true
