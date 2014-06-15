# Public:
class agt.random.Linear
  @include mixins.Cloneable('step')
  @include mixins.Sourcable('chancejs.Linear','step')
  @include mixins.Formattable('Linear','step')

  ### Public: Instances Methods ###

  constructor: (@step=1000000000) ->
    @iterator = 0

  get: ->
    res = @iterator++ / @step
    @iterator = 0 if @iterator > @step
    res
