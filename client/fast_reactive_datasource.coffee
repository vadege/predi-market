# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@FastReactiveDataSource =
  keys: {}
  deps: {}

  get: (key) ->
    @ensureDeps key
    @deps[key].depend()
    @keys[key]

  set: (key, value) ->
    @ensureDeps key
    @keys[key] = value
    @deps[key].changed()
    return

  ensureDeps: (key) ->
    if !@deps[key]
      @deps[key] = new (Deps.Dependency)
    return
