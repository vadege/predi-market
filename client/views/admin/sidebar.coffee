# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.AdminSidebar.events
  'click #go_markets': ->
    Session.set 'admin_section', "markets"
  'click #go_users': ->
    Session.set 'admin_section', "users"
  'click #go_log': ->
    Session.set 'admin_section', "log"
  'click #go_pages': ->
    Session.set 'admin_section', "pages"
  'click #go_settings': ->
    Session.set 'admin_section', "settings"
  'click #go_hints': ->
    Session.set 'admin_section', "hints"
  'click #go_comments': ->
    Session.set 'admin_section', "comments"

  'click [data-toggle=offcanvas]': (evt, tmpl) ->
    element = $ evt.currentTarget
    element.toggleClass 'visible-xs text-center'
    element.find('i').toggleClass 'fa-chevron-right fa-chevron-left'
    $('.row-offcanvas').toggleClass 'active'
    $('#lg-menu, #xs-menu').toggleClass('hidden-xs').toggleClass 'visible-xs'
