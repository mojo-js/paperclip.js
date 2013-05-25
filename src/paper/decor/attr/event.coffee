class SubmitDecor extends require("./dataBind")

  ###
  ###
  
  watch: false

  ###
  ###

  bind: () ->
    super()
    $(@element).bind @name, @_onSubmitted

  ###
  ###

  _onSubmitted: (event) =>
    @clip.data.set "event", event
    @script.update()

module.exports = SubmitDecor