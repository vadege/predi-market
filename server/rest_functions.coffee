# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@PrediRest =
  compute_pricehistory: (set_id, freq, lang) ->
    contractset = Contractsets.findOne {_id: set_id}
    contractdetails = Contracts.find({set_id: set_id, mirror: undefined}).fetch()
    logentries = Activities.find({$or: [{type: "trade"}, {type: "set_prices"}], 'value.set_id': set_id},{sort: {timestamp: 1}}).fetch()

    initial_prices = _.chain logentries
       .filter (entry) -> entry.type is "set_prices"
       .last()
       .value()

    only_trades = _.filter logentries, (entry) ->
      entry.type is "trade"

    price_entries = []
    if initial_prices?
      price_entries = price_entries.concat(initial_prices)
    if only_trades?
      price_entries = price_entries.concat(only_trades)

    if price_entries.length > 0
      start = _.first(price_entries).timestamp
      end = _.last(price_entries).timestamp
      time_points = _.range(end, (start - freq), (freq * -1)).reverse()
      contract_ids = _.map contractdetails, (contract) ->
        return contract._id

      prev_price = (100 / Math.max(contract_ids.length, 2))
      history = _.map contract_ids, (contract) ->
        res = {}
        res.contract_id = contract
        res.values = _.map time_points, (point) ->
          price_entry = {}
          price_entry.timestamp = point
          price_info = _.first(_.filter(price_entries, (trade) ->
            return trade.timestamp >= point
          ))
          price = prev_price
          if price_info? and price_info.value.prices[contract]
            price = price_info.value.prices[contract]
          prev_price = price
          price_entry.price = price

          return price_entry
        return res

      response_object = _.pick contractset, 'market_id', 'title', 'description', 'voteshare', 'image'
      response_object.contractset_id = set_id
      response_object.title = contractset.i18n?[lang]?.title or response_object.title
      response_object.description = contractset.i18n?[lang]?.description or response_object.description
      response_object.open_at = contractset.launchtime
      response_object.close_at = contractset.settletime
      if response_object.image
        response_object.image = Images.findOne({_id: response_object.image}).url()
      response_object.contracts = _.map contractdetails, (contract) ->
        c = _.pick contract, 'title', 'color', 'image'
        c.contract_id = contract._id
        if c.image
          c.image = Images.findOne({_id: c.image}).url()
        c.title = contract.i18n?[lang]?.title or c.title
        return c
      response_object.price_history = history

    response_object

  compute_protovo_pricehistory: (set_id, freq, lang) ->
    history = _.omit @compute_pricehistory(set_id, freq, lang), "contracts"
    num_contracts = history?.price_history?.length

    if num_contracts isnt 3
      return {voteshare: false}

    num_entries = history.price_history[0].values.length
    contractset = Contractsets.findOne {_id: set_id}

    if not contractset?.protovo_high? or not contractset?.protovo_low?
      return {voteshare: false}

    prices = _.map _.range(0, num_entries), (index) ->
      wta2high = contractset.protovo_high
      wta2low = contractset.protovo_low

      pwta1 = history.price_history[0].values[index].price / 100
      pwta2 = history.price_history[1].values[index].price / 100
      pwta3 = history.price_history[2].values[index].price / 100

      pte = (wta2low + wta2high) / 2
      balance = pwta3 - pwta1
      weight = pwta2 + Math.sqrt(Math.pow pwta3 - pwta1, 2)
      intervalsize = wta2high - wta2low
      vs = pte + intervalsize * (balance / weight)

      return {
        timestamp: history.price_history[0].values[index].timestamp
        price: vs
      }

    history.price_history = prices
    return history

  compute_protovo_set_pricehistory: (market_id, freq, lang) ->
    self = @
    _.mixin {
      zip_me_up: (arrays) ->
        return _.zip.apply _, arrays
    }

    market = Markets.findOne {_id: market_id}
    sets = Contractsets.find({market_id: market_id}).fetch()
    protovo_sets = _.chain sets
      .filter (set) ->
        Contracts.find({set_id: set._id}).count() is 3
      .map (set) ->
        middle_contract = Contracts.find({set_id: set._id}).fetch()[1]
        res = _.pick set, 'title', 'description'
        res.set_id = set._id
        if set.image
         res.image = Images.findOne({_id: set.image}).url()
        res.color = middle_contract.color
        res.title = set.i18n?[lang]?.title or res.title
        res.description = set.i18n?[lang]?.description or res.description
        return res
      .value()

    history_by_set = _.map protovo_sets, (set) ->
      return self.compute_protovo_pricehistory set.set_id, freq, lang

    prices = _.map history_by_set, (set) ->
      return set.price_history

    averaged_prices = _.chain prices
      .zip_me_up()
      .map (prices) ->
        sum = _.reduce prices, (sum, price) ->
         return sum + (price?.price or 0)
        , 0

        factor = 100 / sum

        timestampobj = _.find prices, (price) ->
          return price?.timestamp
        timestamp = timestampobj.timestamp

        return _.map prices, (price) ->
          return _.extend (price or {timestamp: timestamp}), {price: (price?.price or 0) * factor}
      .zip_me_up()
      .value()

    price_history = _.map _.zip(history_by_set, averaged_prices), (colls) ->
      # console.log "colls:"
      # console.log colls
      return {set_id: colls[0].contractset_id, values: colls[1]}

    res = {}
    res.market_id = market._id
    res.title = market.title
    res.description = market.description
    res.title = market.i18n?[lang]?.title or res.title
    res.description = market.i18n?[lang]?.description or res.description
    res.sets = protovo_sets
    res.price_history = price_history

    res
