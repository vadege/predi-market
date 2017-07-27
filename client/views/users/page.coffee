# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.Page.helpers
  Page: ->
    Pages.findOne {_id: Router.current().params._id}

  url:(content) ->
    re = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
    contentUrl = content.replace(re, "<a id='urlClass' href='$1'>$1</a>")
    return contentUrl
Template.Page.events

  'click #urlClass': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.href
    window.open(value + location.search)
