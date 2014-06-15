Randomizable = agt.particles.Randomizable
Point = agt.geom.Point

class agt.particles.initializers.Stream
  @include Randomizable

  constructor: (@direction=new Point(1,1),
                @velocityMin=0,
                @velocityMax=1,
                @angleRandom=0,
                @random) -> @initRandom()

  initialize: (particle) ->
    velocity = @random.in @velocityMin, @velocityMax
    angle = @direction.angle()
    angle += @random.pad @angleRandom if @angleRandom isnt 0

    particle.velocity.x = Math.cos(angle) * velocity
    particle.velocity.y = Math.sin(angle) * velocity
