# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

pick_language = (lang) ->
  picked_lang = "en"

  if lang and lang in Settings.findOne()?.supported_languages
    picked_lang = lang
  else
    picked_lang = Settings.findOne()?.default_language or "en"

  picked_lang

Router.route '/api/pricehistory/:contractset_id/:frequency?/:lang?', ->
  @response.setHeader "Content-Type", "application/json"
  @response.setHeader "Access-Control-Allow-Origin", "*"
  @response.setHeader "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"

  frequency = @params.frequency or 24
  lang = pick_language @params.lang

  if @request.method is 'GET'
    if (parseInt(@params.frequency, 10) < 1)
      @response.statusCode = 400
      @response.end "Minimum sample frequency is 1 hour"
    else
      history = PrediRest.compute_pricehistory @params.contractset_id, (frequency * 3600000), lang

      if not history?
        @response.statusCode = 404
        @response.end "A contract set with id '" + @params.contractset_id + "' could not be found"
      else
        @response.statusCode = 200
        @response.end JSON.stringify(history)
  else
    @response.statusCode = 405
    @response.end "Only GET requests are supported"
, {where: 'server'}

Router.route '/api/protovohistory/:contractset_id/:frequency?/:lang?', ->
  @response.setHeader "Content-Type", "application/json"
  @response.setHeader "Access-Control-Allow-Origin", "*"
  @response.setHeader "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"

  frequency = @params.frequency or 24
  lang = pick_language @params.lang

  if @request.method is 'GET'
    if (parseInt(frequency, 10) < 1)
      @response.statusCode = 400
      @response.end "Minimum sample frequency is 1 hour"
    else
      history = PrediRest.compute_protovo_pricehistory @params.contractset_id, (frequency * 3599999), lang

      if not history?
        @response.statusCode = 404
        @response.end "A contract set with id '" + @params.contractset_id + "' could not be found"
      else
        if not history.voteshare
          @response.statusCode = 404
          @response.end "The contractset '" + @params.contractset_id + "' is not eligible for protovo history"
        else
          @response.statusCode = 200
          @response.end JSON.stringify(history)
  else
    @response.statusCode = 405
    @response.end "Only GET requests are supported"
, {where: 'server'}

Router.route '/api/protovosethistory/:market_id/:frequency?/:lang?', ->
  @response.setHeader "Content-Type", "application/json"
  @response.setHeader "Access-Control-Allow-Origin", "*"
  @response.setHeader "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"

  frequency = @params.frequency or 24
  lang = pick_language @params.lang

  if @request.method is 'GET'
    if (parseInt(frequency, 10) < 1)
      @response.statusCode = 400
      @response.end "Minimum sample frequency is 1 hour"
    else
      history = PrediRest.compute_protovo_set_pricehistory @params.market_id, (frequency * 3599999), lang

    if not history? # or not history.voteshare
      @response.statusCode = 404
      @response.end "A market with id '" + @params.market_id + "' could not be found or is not eligible for protovo history"
    else
      @response.statusCode = 200
      @response.end JSON.stringify(history)
  else
    @response.statusCode = 405
    @response.end "Only GET requests are supported"
, {where: 'server'}
