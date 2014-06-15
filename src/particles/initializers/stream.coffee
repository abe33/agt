
# Public:
class agt.particles.initializers.Stream
  @include agt.particles.Randomizable

  ### Public ###

  constructor: (@direction=new agt.geom.Point(1,1),
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
