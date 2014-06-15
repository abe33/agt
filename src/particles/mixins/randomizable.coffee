{Random, MathRandom} = agt.random

DEFAULT_RANDOM = new Random new MathRandom

class agt.particles.Randomizable
  initRandom: -> @random ||= DEFAULT_RANDOM
