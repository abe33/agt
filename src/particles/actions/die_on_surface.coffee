namespace('agt.particles.actions')
# Public:
class agt.particles.actions.DieOnSurface

  ### Public ###

  constructor: (@surfaces) ->
    if Object::toString.call(@surface).indexOf('Array') is -1
      @surfaces = [@surfaces]

  prepare: ->

  process: (p) ->
    return p.die() for surface in @surfaces when surface.contains p.position
