BaseAction = require './base_action'

# Public:
module.exports =
class MacroAction extends BaseAction

  ### Public ###

  constructor: (@actions=[]) ->

  prepare: (bias, biasInSeconds, time) ->
    action.prepare bias, biasInSeconds, time for action in @actions

  process: (particle) ->
    action.process particle for action in @actions
