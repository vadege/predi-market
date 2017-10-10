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
        Session.set 'result', result[0]
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

Template.NewsDisplay.events

  'click .redirect': (evt, tmpl) ->
    evt.preventDefault()
    market_id = evt.currentTarget.id
    category = evt.currentTarget.value
    contract_id = $(evt.currentTarget).data("id")
    Session.set 'order-details', {'set_id': contract_id, 'market_id': market_id}
    Router.go '/market/' + market_id + '?' + 'category=' + category


  'click #go': (evt, tmpl) ->
    evt.preventDefault()
    type = $(evt.currentTarget).data("name")
    value = $(evt.currentTarget).data("value")
    Meteor.call 'findHint', type, value, (error, result) ->
      if error
        console.log error
      else
        if type == "user theory"
          id = result._id
          Router.go '/theory/' + id
        else
          hints = result.hints
          hint = hints.filter (d) ->
            return d.hint == value
          id = hint[0].id
          Router.go '/hints/' +id
