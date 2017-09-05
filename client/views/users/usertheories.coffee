Template.showTheory.rendered = ->
  ga('send', 'event', 'ShowTheory', 'read')

Template.showTheory.helpers
  theory: ->
    val = Theories.find({approved: true}).fetch()
    theoryArr = []
    i = 0
    while i < val.length
      theory = val[i]
      if typeof theory.likes is "undefined" && typeof theory.dislikes is "undefined"
        theoryArr.push(theory)
      else
        likesArr = theory.likes
        dislikesArr = theory.dislikes
        theory['count'] = likesArr.length - dislikesArr.length
        theoryArr.push(theory)
      i++
    newArr = _.sortBy theoryArr, 'count'
    return newArr.reverse()

  url:(comment) ->
    re = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
    commentUrl = comment.replace(re, "<a id='urlClass' href='$1'>$1</a>")
    return commentUrl


Template.showTheory.events
  'click .submit_theory': (evt, tmpl) ->
    Router.go '/add-theory'

  'click .show_theory': (evt, tmpl) ->
    id = evt.currentTarget.id
    Router.go '/theory/' + id

  'click #urlClass': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.href
    window.open(value + location.search)
