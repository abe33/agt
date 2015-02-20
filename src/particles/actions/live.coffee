BaseAction = require './base_action'
# Public:
module.exports =
class Live extends BaseAction
  ### Public ###
  process: (particle) ->
    particle.life += @bias
    particle.die() if particle.life >= particle.maxLife
