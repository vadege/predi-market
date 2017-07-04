# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.AdminFilter.events
  'click button.delete_filter': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'removeFilter', @_id, (error, result) ->
      if error
        Errors.throw error.message
    Deps.flush()
    true
