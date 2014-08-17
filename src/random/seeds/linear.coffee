namespace('agt.random')
# Public:
class agt.random.Linear
  @include agt.mixins.Cloneable('step')
  @include agt.mixins.Sourcable('chancejs.Linear','step')
  @include agt.mixins.Formattable('Linear','step')

  ### Public ###

  constructor: (@step=1000000000) ->
    @iterator = 0

  get: ->
    res = @iterator++ / @step
    @iterator = 0 if @iterator > @step
    res
