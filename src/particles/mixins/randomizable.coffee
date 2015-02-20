{Random, MathRandom} = require '../../random'
DEFAULT_RANDOM = new Random new MathRandom

# Public:
module.exports = 
class Randomizable

  ### Public ###

  initRandom: -> @random ||= DEFAULT_RANDOM
