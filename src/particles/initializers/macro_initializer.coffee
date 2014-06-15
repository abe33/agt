
class agt.particles.initializers.MacroInitializer
  constructor: (@initializers) ->

  initialize: (particle) ->
    initializer.initialize particle for initializer in @initializers
