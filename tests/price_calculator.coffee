#npm install -g chai
#npm install -g mocha
#npm install -g growl
#sudo gem install terminal-notifier
#TEST: (Se http://blog.oddhead.com/2006/10/30/implementing-hansons-market-maker/)
calc_module = require '../lib/price_calculator'
PriceCalculator = calc_module.PriceCalculator
chai = require 'chai'

market =
   name: "Test"
   id: "test"
   liquidity: 100

contracts = [
   {
      id: "opt1"
      market_id: "test"
      title: "Test contract 1"
      outstanding: 0
   }
   {
      id: "opt2"
      market_id: "test"
      title: "Test contract 2"
      outstanding: 0
   }
]

calc = PriceCalculator
chai.Should()

describe 'Trade', ->
   it 'should cost 512.4947951362558', ->
      contracts[0]['outstanding'] = 0
      contracts[1]['outstanding'] = 0
      calc.compute_cost(market, contracts, [{ id: "opt1", move: 10 }]).should.equal 512.4947951362558

   it 'should pay 586.6000793142562', ->
      contracts[0]['outstanding'] = 50
      contracts[1]['outstanding'] = 10
      calc.compute_cost(market, contracts, [{ id: "opt1", move: -10 }]).should.equal -586.6000793142562
   #TODO: Add tests with negative numbers
   it 'should be free', ->
      calc.compute_cost(market, contracts, [{ id: "opt1", move: 0 }]).should.equal 0

   it 'should be free', ->
      calc.compute_cost(market, contracts).should.equal 0

   #TODO: Test min_trade and max_trade functions
describe 'Price', ->
   it 'should be 99.99999999999999', ->
      contracts[0].outstanding = 0
      contracts[1].outstanding = 3741
      calc.price(market, contracts, "opt2").should.equal 99.99999999999999

   it 'should be 100', ->
      contracts[0].outstanding = 0
      contracts[1].outstanding = 3742
      calc.price(market, contracts, "opt2").should.equal 100
