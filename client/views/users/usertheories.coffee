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


Template.showTheory.events
  'click .submit_theory': (evt, tmpl) ->
    Router.go '/add-theory'

  'click .show_theory': (evt, tmpl) ->
    id = evt.currentTarget.id
    Router.go '/theory/' + id
