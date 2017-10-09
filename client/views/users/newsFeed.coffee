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
      else
        Session.set 'result', result
    if Session.get 'result'
      return Session.get 'result'

  Contracts: (id)->
    Contracts.find {$and: [{set_id: id}
                         {mirror: {$not: true}}]}

  insta: (type) ->
    if type == "instagram Post"
      return true

  twitter: (type) ->
    if type == "twitter Post"
      return true

  facebook: (type) ->
    if type == "facebook"
      return true

  youtube: (type) ->
    if type == "youtube Post"
      return true

  hint: (type) ->
    if type == "hint"
      return true

  filterUntranslatedText: GlobalHelpers.filterUntranslated

  checkCategory: (category) ->
    if category.length > 1
      return category[0]
    else
      return category
