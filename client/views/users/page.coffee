# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.Page.helpers
  Page: ->
    Pages.findOne {_id: Router.current().params._id}
