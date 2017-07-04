# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

#Robert Hansons Logarithmic Market Scoring Rule
#liquidity == b
defaultFor = (arg, val) ->
  (if typeof arg isnt "undefined" then arg else val)

# Movements is an array of objects containing contract id and move fields
sumexp = (contracts, liquidity, movements) ->
  movements = defaultFor movements, {}
  sum = 0
  for contract in contracts
    mv = (mv for mv in movements when mv.id is contract._id)[0]
    movement = mv?.move or 0
    exp = (Math.exp((contract.outstanding + movement) / liquidity))
    sum = sum + exp
  sum

@PriceCalculator =
  compute_cost: (contracts_metadata, contracts, movements) ->
    price_after_move = (contracts_metadata.liquidity * Math.log(sumexp(contracts, contracts_metadata.liquidity, movements)))
    price_now = contracts_metadata.liquidity * Math.log(sumexp(contracts, contracts_metadata.liquidity))
    (price_after_move - price_now) * ((contracts_metadata.max_price or 100) - (contracts_metadata.min_price or 0))
  ,
  price: (contracts_metadata, contracts, contract_id) ->
    contract = _.find(contracts, (contract) =>
      contract._id is contract_id)
    result = 0
    sum = sumexp(contracts, contracts_metadata.liquidity)
    if sum isnt 0
      result = ((Math.exp(contract.outstanding / contracts_metadata.liquidity)) / sum)
    result * ((contracts_metadata.max_price or 100) - (contracts_metadata.min_price or 0))
  ,
  #TODO min_trade and max_trade should be the same function
  #TODO Be smarter than to simuluate trade for each added stock
  #TODO write tests for these functions
  max_trade: (contracts_metadata, contracts, contract_id, cash, owned) ->
    count = 1
    assets = cash
    if owned < 0
      assets = assets + (owned * -1 * contracts_metadata.freeze_amount)
    while assets > 0
      assets = cash
      if owned < 0
        thaw = Math.min count, Math.abs owned
        assets = assets + (thaw * contracts_metadata.freeze_amount)
      movements = [{id: contract_id, move: count}]
      result = @compute_cost(contracts_metadata, contracts, movements)
      assets = assets - result
      count++
    count - 2
  ,
  min_trade: (contracts_metadata, contracts, contract_id, cash, owned) ->
    count = -1
    assets = cash
    if owned < 0
      assets = assets + (owned * -1 * contracts_metadata.freeze_amount)
    while assets > 0
      assets = cash
      if (owned + count) < 0
        freeze = 0
        if owned < 0
          freeze = count
        else
          freeze = Math.min 0, (owned + count)

        assets = assets + (freeze * contracts_metadata.freeze_amount)
      movements = [{id: contract_id, move: count}]
      result = @compute_cost(contracts_metadata, contracts, movements)
      assets = assets - result
      count--
    count + 2
  ,
  compute_outstanding: (contracts_metadata, contracts, contract_id, target_price) ->
    incoutstanding = (contract) ->
      if (contract._id is contract_id)
        contract.outstading = contract.outstanding++
        contract
      else
        contract

    decoutstanding = (contract) ->
      if (contract._id is contract_id)
        contract.outstading = contract.outstanding--
        contract
      else
        contract

    price = @price(contracts_metadata, contracts, contract_id)
    if price < target_price
      while price < target_price
        contracts = _.map(contracts, incoutstanding)
        price = @price(contracts_metadata, contracts, contract_id)
    else
      while price > target_price
        contracts = _.map(contracts, decoutstanding)
        price = @price(contracts_metadata, contracts, contract_id)

    _.find(contracts, (contract) =>
      contract._id is contract_id
    ).outstanding
