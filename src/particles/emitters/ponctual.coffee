namespace('agt.particles.emitters')
# Public:
class agt.particles.emitters.Ponctual

  ### Public ###

  constructor: (@point=new agt.geom.Point) ->

  get: -> @point.clone()
