namespace('agt.particles')

DEFAULT_RANDOM = new agt.random.Random new agt.random.MathRandom

# Public:
class agt.particles.Randomizable

  ### Public ###

  initRandom: -> @random ||= DEFAULT_RANDOM
