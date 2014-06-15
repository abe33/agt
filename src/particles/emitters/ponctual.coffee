Point = agt.geom.Point

class agt.particles.emitters.Ponctual
  constructor: (@point=new Point) ->
  get: -> @point.clone()
