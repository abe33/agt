BaseAction = require './base_action'
# Public:
module.exports = 
class Friction extends BaseAction

  ### Public ###

  constructor: (@amount=1) ->

  process: (particle) ->
    fx = particle.velocity.x * @biasInSeconds * @amount
    fy = particle.velocity.y * @biasInSeconds * @amount

    particle.velocity.x -= fx
    particle.velocity.y -= fy
