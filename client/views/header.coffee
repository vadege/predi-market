# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.Header.events
  'click .setLanguage': (evt, tmpl) ->
    lang_tag = evt.target.id
    TAPi18n.setLanguage lang_tag
    accountsUIBootstrap3.setLanguage lang_tag
    Meteor.call 'setUserLanguage', lang_tag

  'click #log_out': (evt, tmpl) ->
    Session.set 'loading', true
    Meteor.logout (error) ->
      if error
        Errors.throw error
      else
        Router.go '/'
        Session.set 'loading', undefined


Template.Header.helpers
  supportedLanguages: () ->
    user = Meteor.user()
    langs = TAPi18n.getLanguages()
    settings = Settings.findOne()
    if settings and not user?.profile?.admin
      supported_langs = settings.supported_languages
      if supported_langs?.length < 2
        supported_langs = []
    else
      supported_langs = _.keys(langs)

    language_list = _.chain langs
      .pick supported_langs
      .keys()
      .map (key) -> _.extend(langs[key], {'tag': key})
      .value()

    language_list.map (lang, index) ->
      return _.extend lang, {
        first: index is 0 and "first" or ""
        last: index is language_list.length - 1 and "last" or ""
      }

  isEqual: (v1, v2) ->
    v1 is v2

  current_user_avatar: ->
    user = Meteor.user()
    if user
      return Gravatar.imageUrl user?.emails[0].address, { size: 30, default: 'identicon', secure: true }
    else
      return ""

  current_language_tag: ->
    user = Meteor.user()
    settings = Settings.findOne()
    supported_langs = []
    if settings? and not user?.profile?.admin
      supported_langs = settings.supported_languages
    else
      supported_langs = _.keys(TAPi18n.getLanguages())
    if supported_langs.length > 1
      return "&nbsp;/&nbsp;" + TAPi18n.getLanguage()
    else
      return ""

  current_user_name: ->
    user = Meteor.user()
    user?.username

Template.Header.rendered = ->
  @$('[data-toggle="collapse"]').collapse()
