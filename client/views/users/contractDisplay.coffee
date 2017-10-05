Template.ContractDisplay.helpers

  Contractset: ->
    now = Date.now()
    contract_id = Router.current().params._id
    contractsets = Contractsets.find(
        $and: [{_id: contract_id},
               {active: true},
               {launchtime: {$lte: now}},
               {settletime: {$gte: now}}]
      ,
        sort:
          sort_index: 1,
          settletime: -1
    ).fetch()
    return contractsets

  Contracts: ->
    contract_id = Router.current().params._id
    Contracts.find {$and: [{set_id: contract_id}
                         {mirror: {$not: true}}]}

  filterUntranslatedText: GlobalHelpers.filterUntranslated

  checkCategory: (category) ->
    if category.length > 1
      return category[0]
    else
      return category

Template.ContractDisplay.events

  'click .redirect': (evt, tmpl) ->
    evt.preventDefault()
    market_id = evt.currentTarget.id
    category = evt.currentTarget.value
    contract_id = Router.current().params._id
    Session.set 'order-details', {'set_id': contract_id, 'market_id': market_id}
    Router.go '/market/' + market_id + '?' + 'category=' + category
