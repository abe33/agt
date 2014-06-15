
# Public:
class agt.particles.initializers.MacroInitializer

  ### Public ###
  
  constructor: (@initializers) ->

  initialize: (particle) ->
    initializer.initialize particle for initializer in @initializers
