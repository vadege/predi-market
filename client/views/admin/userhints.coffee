Template.ListHints.helpers
  hints: ->
    value = Contracts.find({mirror: {$not: true}}).fetch()
    hintUpdatedArr = [];
    i = 0
    while i < value.length
      hintArr = value[i].hints
      j = 0
      while j < hintArr.length
        if hintArr[j].approved == false
          hintUpdatedArr.push(hintArr[j])
        j++
      i++
    return hintUpdatedArr
