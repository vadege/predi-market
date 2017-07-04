# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.AdminPage.events
  'click button.delete_page': (evt, tmpl) ->
    evt.stopPropagation()
    Meteor.call 'deletePage', @_id, (error, result) ->
      if error
        Errors.throw error.message
    Deps.flush()
    true
