namespace('agt.particles')

# Public:
class agt.particles.Particle
  @concern agt.mixins.Poolable

  ### Public ###

  init: (options={}) ->
    @dead = false
    @life = 0
    @maxLife = 0
    @position = new agt.geom.Point
    @lastPosition = new agt.geom.Point
    @velocity = new agt.geom.Point
    @parasite = {}

    @[ k ] = v for k,v of options

  dispose: ->
    @position = null
    @lastPosition = null
    @velocity = null
    @parasite = null

  die: ->
    @dead = true
    @life = @maxLife

  revive: ->
    @dead = false
    @life = 0
