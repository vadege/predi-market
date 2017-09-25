Template.ContractSort.events
  'click .dropdown': (evt, tmpl) ->
    evt.preventDefault()
    $('.contract_sort').toggleClass("show")

  'click .dropdown-item': (evt, tmpl) ->
    evt.preventDefault()
    value = evt.currentTarget.value
    Session.set 'category_search', value

Template.ContractSort.helpers

  select: ->
    return Session.get 'category_search'
