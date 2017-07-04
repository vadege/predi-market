# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@placeholderTranslations = (translated_fields) ->
  # FIXME: This is not ideal, but as far as I can see, it is nescecary to
  # explicitly insert translated values for the fields one wants translated.
  # There is no way to check if a translation exists, and one cannot update the
  # translation for a field that is not translated already, and one cannot insert
  # a new translation except when creating the initial document. Workaround very
  # much wanted. Having empty strings without fallback to base language in
  # database is ugly!
  translations = {}
  langs = _.filter Object.keys(TAPi18n.getLanguages()), (lang) -> lang != "en"

  for lang in langs
    translations[lang] = {}
    for field in translated_fields
      translations[lang][field] = "Not translated"
  translations

@checkAdmin = (admin_id) ->
  check admin_id, String
  user = Meteor.users.findOne {_id: admin_id}
  unless user?.profile?.admin
    throw new Meteor.Error 403, "You are not an administrator"

@updateTranslation = (collection, selector, setter) ->
  check selector, String
  check setter, Object
  # check collection, Object #FIXME A TAPi18n collection object
                             #seems to not be an object WTF?
  collection.updateTranslations selector, setter

  action =
    collection: collection._name
    field: selector
    value: setter

  createLog =
    timestamp: Date.now()
    user_id: "system"
    type: "translation"
    value: action

  Activities.insert createLog
