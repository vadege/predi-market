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

  hint: ->
      contract_id = Router.current().params._id
      likes = HintsLikeDisLike.find({},{sort: {likes: -1}}).fetch()
      value = Contracts.find({$and: [{set_id: contract_id}, {hints: {$exists: true}}]}, {fields: {hints: 1}}).fetch()
      hintArrNew = []
      k = 0
      while k < likes.length
        l = 0
        while l < value.length
          j = 0
          hintArrContract = value[l].hints
          while j < hintArrContract.length
            hint = hintArrContract[j]
            val = hintArrNew.indexOf hint
            if hint.id == likes[k].hint_id
              hint['count'] = likes[k].likes.length - likes[k].dislikes.length
              if val == -1
                hintArrNew.push(hint)
                break
            else
              if val == -1
                hintArrNew.push(hint)
                break
            j++
          l++
        k++
      i = 0
      hintArrUpdated = []
      while i < hintArrNew.length
        if hintArrNew[i]
          hintArr = hintArrNew[i]
          if hintArr.approved == true
              hintArrUpdated.push(hintArrNew[i])
        i++
      hintArrUpdated = _.sortBy hintArrUpdated, 'count'
      return hintArrUpdated.reverse()

    # Image: ->
    #   Images.findOne({_id: @image})

  filterUntranslatedText: GlobalHelpers.filterUntranslated
