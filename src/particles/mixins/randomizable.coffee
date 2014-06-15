{Random, MathRandom} = agt.random

DEFAULT_RANDOM = new Random new MathRandom

# Public:
class agt.particles.Randomizable

  ### Public ###
  
  initRandom: -> @random ||= DEFAULT_RANDOM
