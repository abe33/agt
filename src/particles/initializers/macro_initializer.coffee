
# Public:
module.exports =
class MacroInitializer

  ### Public ###

  constructor: (@initializers) ->

  initialize: (particle) ->
    initializer.initialize particle for initializer in @initializers
