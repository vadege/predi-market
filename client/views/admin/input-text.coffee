# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Template.InputText.helpers
  label: ->
    TAPi18n.__ "form_"+@field

  is_readonly: ->
    @ro and true

  is_numbertype: ->
    @type is "number"

  is_textarea: ->
    @type is "textarea"

  is_tags: ->
    @type is "tags"

  is_range: ->
    @type is "range"

  is_file: ->
    @type is "file"

  val: ->
    if @type is "number" or @type is "file"
      @value?.value or @value
    else if @type is "tags"
      @value.join()
    else
      GlobalHelpers.filterUntranslated @value

  data: ->
    if @type is "number" and @value
      @value.data
    else
      undefined

  field_width_class: ->
    if @ro
      "col-md-8"
    else
      "col-md-6"

  image: ->
    if @type is "file" and @value?
      file = Images?.findOne {_id: @value}
      if file?.isImage()
        return file
    return undefined

  Image: ->
    file = Images?.findOne {_id: @value}

Template.InputText.events
  'click .input-text-save-button, blur .input-text-set-field, change .input-range-set-field': (evt, tmpl) ->
    evt.stopPropagation()
    value_element = tmpl.find "#set-" + @field + "-" + @id
    value = value_element.value || ""
    data = @value?.data
    if (value? and @method)
      if @type is "number" or @type is "range"
        value = Number value
        if isNaN value
          Errors.throw error
          return false
      if data?
        Meteor.call @method, TAPi18n.getLanguage(), value, data, @id, (error, result) ->
          if error
            Errors.throw error
      else
        Meteor.call @method, TAPi18n.getLanguage(), value, @id, (error, result) ->
          if error
            Errors.throw error
      Deps.flush()
      true

  'click .dropzone .remove': (e, t) ->
    e.stopPropagation()
    e.preventDefault()
    method = @method
    value = @value || ""
    element_id = @id
    Meteor.call method, undefined, element_id, (error, result) ->
      if error
        Errors.throw error
      else
        if value?
          Images.remove {_id: value}

  'dragenter .dropzone': (e, t) ->
    e.stopPropagation()
    e.preventDefault()
    $(t.find('.dropzone')).addClass 'dropzone-hover'

  'dragexit .dropzone': (e, t) ->
    e.stopPropagation()
    e.preventDefault()
    $(t.find('.dropzone')).removeClass 'dropzone-hover'

  'dragover .dropzone': (e, t) ->
    e.stopPropagation()
    e.preventDefault()

  'dropped .upload-file': (e, t) ->
    value = @value || ""
    processed_one = false
    method = @method
    element_id = @id

    FS.Utility.eachFile e, (file) ->
      unless processed_one
        processed_one = true
        fileObj = new FS.File file
        image = Images.insert fileObj, (error, fileObj) ->
          if error
            Errors.throw error

        if image
          Meteor.call method, image._id, element_id, (error, result) ->
            if error
              Errors.throw error
            else
              if value?
                # Delete old file if it exists
                Images.remove {_id: value}

Template.InputText.rendered = ->
  @$('[data-toggle="tagsinput"]').tagsinput()
