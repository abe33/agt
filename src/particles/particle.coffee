{Poolable} = require '../mixins'
Point = require '../geom/point'

# Public:
module.exports =
class Particle
  @concern Poolable

  ### Public ###

  init: (options={}) ->
    @dead = false
    @life = 0
    @maxLife = 0
    @position = new Point
    @lastPosition = new Point
    @velocity = new Point
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
