Randomizable = agt.particles.Randomizable

class agt.particles.initializers.Life
  @include Randomizable

  constructor: (@lifeMin, @lifeMax, @random) ->
    @lifeMax = @lifeMin unless @lifeMax?
    @initRandom()

  initialize: (particle) ->
    if @lifeMin is @lifeMax
      particle.maxLife = @lifeMin
    else
      particle.maxLife = @random.in @lifeMin, @lifeMax
