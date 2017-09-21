# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

formatDate = (date) ->
  moment.locale TAPi18n.getLanguage()
  val = moment(date).format("LLLL")
  val

Template.AdminContractset.helpers
  Contracts: ->
    Contracts.find {$and: [{set_id: @_id}
                           {mirror: {$not: true}}]}

  formattedDate: formatDate

  category: ->
    value = Contractsets.findOne({_id: @_id})
    if value
      return true

  settleable: ->
    (Date.now() > @launchtime and not @active) or
    Date.now() > @settletime

  settling: ->
    Session.get('settling') is @_id

  closeable: ->
    @active and
    Date.now() > @launchtime and
    Date.now() < @settletime

  reopenable: ->
    not @active and
    Date.now() > @launchtime and
    Date.now() < @settletime

  deleteable: ->
    Date.now() < @launchtime

  started: ->
    Date.now() > @launchtime

  protovo_eligible: ->
    num_contracts = Contracts.find({$and: [{set_id: @_id}
                                           {mirror: {$not: true}}]}).count()
    @voteshare and num_contracts is 3


Template.AdminContractset.events
  'click .add_contract': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'addContract', @_id, (error, result) ->
      if error
        Errors.throw error.message
    true

  'click .settle_contractset': (evt, tmpl) ->
    evt.stopPropagation()
    if @_id
      Session.set 'settling', @_id

  'click .close_contractset': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'closeContractset', @_id, (error, result) ->
      if error
        Errors.throw error.message
    true

  'click .reopen_contractset': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'reopenContractset', @_id, (error, result) ->
      if error
        Errors.throw error.message
    true

  'click .delete_contractset': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'deleteContractset', @_id, (error, result) ->
      if error
        Errors.throw error.message
    true

Template.AdminContractset.rendered = ->
  # TODO: Prevent setting timestamp < now
  data = @data
  if @data.launchtime > Date.now()
    $('#set-launchtime-' + @data._id).datetimepicker(
      format: "LLLL"
      locale: TAPi18n.getLanguage()
      sideBySide: true
      minDate: new Date()
      maxDate: new Date @data.settletime
      useCurrent: false
      defaultDate: new Date @data.launchtime
      useStrict: true
    ).on 'dp.change', (ev) =>
      settlepicker = $('#set-settletime-'+data._id).data "DateTimePicker"
      launchpicker = $('#set-launchtime-'+data._id).data "DateTimePicker"
      oldval = data.launchtime
      reportedval = ev.date.valueOf()
      offset = new Date().getTimezoneOffset()
      newval = reportedval + (offset * 60000)
      olddate = new moment(oldval)
      newdate = new moment(newval)
      if Date.now() < newval < data.settletime
        Meteor.call 'setContractsetLaunchTime', newval, data._id, (error, result) ->
          if error
            Errors.throw error.message
          else
            if settlepicker
              settlepicker.minDate newdate
          true
      else
        launchpicker.defaultDate olddate
        false

  $('#set-settletime-'+ @data._id).datetimepicker(
    format: "LLLL"
    sideBySide: true
    locale: TAPi18n.getLanguage()
    minDate: new Date data.launchtime
    defaultDate: new Date data.settletime
    useCurrent: false
    useStrict: true
  ).on 'dp.change', (ev) =>
    settlepicker = $('#set-settletime-'+data._id).data("DateTimePicker")
    launchpicker = $('#set-launchtime-'+data._id).data("DateTimePicker")
    oldval = data.settletime
    reportedval = ev.date.valueOf()
    offset = new Date().getTimezoneOffset()
    newval = reportedval + (offset * 60000)
    olddate = new moment(oldval)
    newdate = new moment(newval)

    if newval > data.launchtime
      Meteor.call 'setContractsetSettleTime', newval, data._id, (error, result) ->
        if error
          Errors.throw error.message
        else
          if launchpicker
            launchpicker.maxDate(newdate)
        true
    else
      settlepicker.defaultDate olddate
      false
