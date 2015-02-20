{Randomizable} = require '../mixins'
# Public:
module.exports = 
class Life
  @include Randomizable

  ### Public ###

  constructor: (@lifeMin, @lifeMax, @random) ->
    @lifeMax = @lifeMin unless @lifeMax?
    @initRandom()

  initialize: (particle) ->
    if @lifeMin is @lifeMax
      particle.maxLife = @lifeMin
    else
      particle.maxLife = @random.in @lifeMin, @lifeMax
