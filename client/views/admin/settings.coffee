# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.AdminSettings.rendered = ->
  ga('send', 'event', 'AdminSettings', 'read')

Template.AdminSettings.helpers
  Languages: ->
    settings =  Settings.findOne()
    languages = TAPi18n.getLanguages()
    _.map _.keys(languages), (lang) =>
      code: lang
      enabled: _.contains(settings.supported_languages, lang)
      label: languages[lang]["en"]
      default: lang is settings.default_language

  language_enabled: (language) ->
    language.enabled is true

  language_default: (language) ->
    language.default is true

  language_disabled: (language) ->
    language.enabled isnt true

Template.AdminSettings.events
  'change .default-language': (evt, tmpl) ->
    radios = tmpl.findAll ".default-language"
    default_language = _.chain radios
      .filter (radio) -> radio.disabled isnt true and radio.checked is true
      .map (radio) -> radio.value
      .first()
      .value()
    Meteor.call "setDefaultLanguage", null, default_language, (error, result) ->
      if error
        Errors.throw error

  'change .enabled-language': (evt, tmpl) ->
    languages = tmpl.findAll ".enabled-language"
    enabled_languages = _.chain languages
      .filter (check) -> check.checked is true
      .map (check) -> check.value
      .value()
    langs = enabled_languages.join(",")
    Meteor.call "setSupportedLanguages", null, langs, (error, result) ->
      if error
        Errors.throw error
