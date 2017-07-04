# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@createPage = (page) ->
  translations = @placeholderTranslations ["title", "content"]
  page_id = Pages.insertTranslations page, translations
  create_log =
    timestamp: Date.now()
    user_id: "system"
    type: "createpage"
    value: _.extend page, {page_id: page_id}
  Activities.insert create_log

@deletePage = (page_id) ->
  Pages.remove {_id: page_id}
  delete_log =
    timestamp: Date.now()
    user_id: "system"
    type: "deletepage"
    value: {page_id: page_id}
  Activities.insert delete_log
