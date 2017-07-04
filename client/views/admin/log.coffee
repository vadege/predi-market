# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.AdminLog.helpers
  # LogEntries: ->
  #   # options =  {sort: @sort, limit: @handle.limit()}
  #   Activities.find {}#, options

  time: ->
    moment.locale TAPi18n.getLanguage()
    moment(@timestamp).format("LLLL")

  name: ->
    name = @user_id
    user = Meteor.users.findOne {_id: name}
    if user
      name = user.profile.name + " (" + user.username + ")"
    name

  value: ->
    entries = _.chain(@value)
      .pairs()
      .map (pair) -> "<dt>"+pair[0]+"</dt><dd>"+pair[1]+"</dd>"
      .value()
    "<dl>" + entries.join() + "</dl>"

  # postsReady: ->
  #   @handle.ready();

  # allPostsLoaded: ->
  #   @handle.ready() and Activities.find().count() < @handle.loaded()

Template.AdminLog.events
  'click .loginfo': (evt, tmpl) ->
    Session.set "selected-log", evt.target.value
  'click .save': (evt, tmpl) ->
    $('#download-button').toggleClass('fa-download').toggleClass('fa-cog').toggleClass 'fa-spin'
    setTimeout ->
        moment.locale TAPi18n.getLanguage()
        trades = Activities.find({type: "trade"}, {reactive: false, sort: {'value.set_id': 1, timestamp: 1}}).fetch()
        rawData = _.map trades, (trade) ->
          user = Meteor.users.findOne {_id: trade.user_id}
          obj = _.omit trade.value, 'prices'
          obj.time = moment(trade.timestamp).format("LLLL")
          obj.userlogin = user?.username or "Non-existing user"
          obj.username = user?.profile.name or "Non-existing user"
          obj.prices = _.reduce _.keys(trade.value.prices), (string, contract_id)  ->
            string = string + contract_id + ": " + trade.value.prices[contract_id] + ", "
          , ""
          return obj
        csv = json2csv rawData, true, true
        savefunc = ->
          blob = new Blob [csv], {type: "text/csv;charset=utf-8;"}
          date = moment(Date.now()).format('YYYY.MM.DD-HH.mm')
          saveAs blob, "pricehistory-" + date + ".csv"
        setTimeout savefunc, 100
        $('#download-button').toggleClass('fa-download').toggleClass('fa-cog').toggleClass 'fa-spin'
      , 100
    false
  # 'click .loadMore': (evt, tmpl) ->
  #   @handle.loadNextPage()

Template.AdminLog.rendered = ->
  Meteor.subscribe 'TradeLog', undefined
