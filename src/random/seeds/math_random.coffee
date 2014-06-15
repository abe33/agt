# Public:
class agt.random.MathRandom
  @include mixins.Cloneable()
  @include mixins.Sourcable('chancejs.MathRandom')
  @include mixins.Formattable('MathRandom')

  # Public:
  get: -> Math.random()
