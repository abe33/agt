BaseAction = require './base_action'
Point = require '../../geom/point'

module.exports =
class ConditionalForce extends BaseAction
  constructor: (@vector=new Point, @condition) ->
    @condition ?= -> true

  process: (particle) ->
    if @condition(particle)
      particle.velocity.x += @vector.x * @biasInSeconds
      particle.velocity.y += @vector.y * @biasInSeconds
