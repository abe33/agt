namespace('agt.random')
# Public:
class agt.random.MathRandom
  @include agt.mixins.Cloneable()
  @include agt.mixins.Sourcable('chancejs.MathRandom')
  @include agt.mixins.Formattable('MathRandom')

  # Public:
  get: -> Math.random()
