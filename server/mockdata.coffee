# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@mockMarket = ->
  now = Date.now()
  month = (24*60*60*1000*31)
  twoMonthsAgo = now - (month * 2)
  oneMonthFromNow = now + month
  threeMonthsFromNow = now + (month *3)

  market =
      image: null
      initial_money: 10000
      title: Fake.sentence 5
      description: Fake.paragraph 5
      tags: ["test"]

  set =
      title: Fake.sentence 5
      description: Fake.paragraph 9
      liquidity: 666
      launchtime: oneMonthFromNow
      settletime: threeMonthsFromNow
      max_price: 100
      min_price: 0
      freeze_amount: 100
      voteshare: true
      active: true
      settled: false
      image: null

  contracts = [
      image: null
      title: Fake.sentence 5
      color: "#aabbcc"
      outstanding: 150
    ,
      image: null
      title: Fake.sentence 5
      color: "#bbaacc"
      outstanding: 100
    ,
      image: null
      title: Fake.sentence 5
      color: "#bbccaa"
      outstanding: 50
    ,
      image: null
      title: Fake.sentence 5
      color: "#ccaabb"
      outstanding: 0
  ]

  admin = Meteor.users.findOne({"profile.admin": true})
  market_id = @createMarket market, twoMonthsAgo
  set_id = @addContractset market_id, set, twoMonthsAgo
  contract_id = undefined
  for contract in contracts
    contract_id = @addContract(set_id, contract, twoMonthsAgo)

  market_id

@mockTrades = (user_id, market_id) ->
  now = Date.now()
  month = (24*60*60*1000*31)
  aMonthAgo = now - month

  Contractsets.update {market_id: market_id}, {$set: {launchtime: aMonthAgo}}
  sets = Contractsets.find({market_id: market_id}).fetch()

  for set in sets
    timestamp = set.launchtime
    yesterday = now - 86400000
    num_contracts = Contracts.find({set_id: set._id}).count()
    contracts = Contracts.find({set_id: set._id}).fetch()

    while num_contracts > 0 and timestamp < yesterday
      contract = contracts[Math.floor(Math.random() * contracts.length)]
      amount = Math.floor(Math.random() * 40) - 20 + 1
      try
        @executeTrade user_id, amount, contract._id, timestamp
      catch e
        return false
      timestamp = timestamp + parseInt((Math.random() * 86400000), 10)

@mockUsers = ->
  user_id = createUser "test", "Test.Tets@test.com", "test", "TestUser #1"
  addTag user_id, "test"
  user_id

@mockPage = ->
  title = Fake.word()
  content = Fake.paragraph(5) + Fake.paragraph(5) + Fake.paragraph(5)
  @createPage {title: title, content: content}
