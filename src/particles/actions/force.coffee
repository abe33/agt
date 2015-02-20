BaseAction = require './base_action'
Point = require '../../geom/point'
# Public:
module.exports =
class Force extends BaseAction

  ### Public ###

  constructor: (@vector=new Point) ->

  process: (particle) ->
    particle.velocity.x += @vector.x * @biasInSeconds
    particle.velocity.y += @vector.y * @biasInSeconds
