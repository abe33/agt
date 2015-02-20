{Cloneable, Sourcable, Formattable} = require '../../mixins'
# Public:
module.exports =
class Linear
  @include Cloneable('step')
  @include Sourcable('chancejs.Linear','step')
  @include Formattable('Linear','step')

  ### Public ###

  constructor: (@step=1000000000) ->
    @iterator = 0

  get: ->
    res = @iterator++ / @step
    @iterator = 0 if @iterator > @step
    res
