# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@addFilter = (parent_id, filter) ->
  translations = @placeholderTranslations ["filter", "label"]
  f = _.extend filter, {parent_id: parent_id}
  filter_id = Filters.insertTranslations f, translations

  filters_log =
    timestamp: Date.now()
    user_id: "system"
    type: "addFilter"
    value: {
      parent: parent_id
      filter: filter}

  Activities.insert filters_log
  filter_id

@removeFilter = (filter_id) ->
  Filters.remove filter_id

  remove_log =
    timestamp: Date.now()
    user_id: "system"
    type: "deletefilter"
    value: {filter_id: filter_id}

  Activities.insert remove_log
  filter_id
