# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.ContractSnippet.helpers
  price: ->
    contracts = Contracts.find({set_id: @set_id}).fetch()
    contractset = Contractsets.findOne({_id: @set_id})

    if contractset?
      PriceCalculator.price contractset, contracts, @_id
        .toFixed 2
        .replace /\.?0+$/, ""

  owned: ->
    user = Meteor.user()
    owned = user.profile.portfolio[@_id]
    owned? and parseInt(owned) or false

  owed: ->
    user = Meteor.user()
    owned = user.profile?.portfolio[@_id] or 0
    owned < 0

  filterUntranslatedText: GlobalHelpers.filterUntranslated
