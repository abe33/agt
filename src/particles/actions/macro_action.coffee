
class agt.particles.actions.MacroAction extends agt.particles.actions.BaseAction
  constructor: (@actions=[]) ->
  prepare: (bias, biasInSeconds, time) ->
    action.prepare bias, biasInSeconds, time for action in @actions
  process: (particle) ->
    action.process particle for action in @actions
