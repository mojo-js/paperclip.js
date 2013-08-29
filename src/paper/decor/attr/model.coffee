_ = require "underscore"
ChangeDecor  = require("./change")
escapeHTML   = require("../../utils/escapeHTML")
type         = require "type-component"
dref = require "dref"

class ModelDecor extends require("./dataBind")

  ###
  ###

  bind: () ->
    super()
    (@$element = $(@element)).bind ChangeDecor.events, @_onElementChange
    @_onChange @clip.get("model")
  

  ###
  ###

  _onElementChange: (event) =>

    event.stopPropagation()
    clearTimeout @_changeTimeout
    # need to delay so that the input value can catch up
    @_changeTimeout = setTimeout (() =>

      value = @_parseValue @_elementValue()
      name  = @_elementName()
      model = @clip.get("model")

      # assumed, but can be overridden
      if @clip.get("bothWays") isnt false
        ref = name or (if @refs.length then @refs[0] else undefined)

        unless name
          model = @context

        @_currentValue = value

        if model
          if model.set
            model.set ref, value
          else
            dref.set model, ref, value


    ), 5

  ###
  ###

  dispose: () ->
    @_modelBinding?.dispose()
    @$element?.unbind ChangeDecor.events, @_onElementChange

  ###
  ###

  _onChange: (model) =>
    #@_elementValue if type(value) is "string" then escapeHTML(value) else value

    name = @_elementName()
    @_modelBinding?.dispose()

    if name
      @_modelBinding = model?.bind(name).to(@_onValueChange).now()
    else
      @_onValueChange model


  ###
  ###

  _onValueChange: (value) =>
    @_elementValue @_parseValue value

  ###
  ###

  _parseValue: (value) ->
    return undefined if not value? or value is ""
    value


  ###
  ###

  _elementValue: (value) =>


    # cannot be undefined
    unless value?
      value = ""

    # Object.prototype.hasOwnProperty is a work-around for ffox and, ie
    isInput = Object.prototype.hasOwnProperty.call(@element, "value") or /input|textarea|checkbox/.test(@element.nodeName.toLowerCase())

    unless arguments.length
      return if isInput then @_checkedOrValue() else @element.innerHTML

    return if value is @_currentValue
    
    @currentValue = value

    if isInput
      @_checkedOrValue value
    else
      @element.innerHTML = value

  ###
  ###

  _elementName: () -> $(@element).attr("name")

  ###
  ###

  _checkedOrValue: (value) ->

    isCheckbox        = /checkbox/.test @element.type
    isRadio           = /radio/.test @element.type
    isRadioOrCheckbox = isCheckbox or isRadio

    unless arguments.length
      if isRadioOrCheckbox
        return $(@element).val()
      else
        return @element.value

    if isRadioOrCheckbox
      if isRadio
        if String(value) is String($(@element).val())
          $(@element).prop("checked", true)
      else
        @element.checked = value
    else 
      @element.value = value





module.exports = ModelDecor