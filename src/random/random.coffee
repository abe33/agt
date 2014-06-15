
{floor, round} = Math

# Public: Create a `Random` object whenever you need randomized values
# of various kind. The `Random` class doesn't provides the random generation
# itself, it relies on `Seeder` objects, but will use the generated values
# to produce a wide range of values.
#
# ```coffeescript
# random = new agt.random.Random(new agt.random.MathRandom)
# ```
class agt.random.Random
  @include mixins.Cloneable('generator')
  @include mixins.Sourcable('agt.random.Random','generator')
  @include mixins.Formattable('Random','generator')

  ### Public: Instances methods ###

  constructor: (@generator) ->

  get: -> @generator.get()

  boolean: (rate=0.5) -> rate = 0.5 unless 0 <= rate <= 1; @get() < rate
  bit: (rate=0.5) -> if @boolean rate then 1 else 0
  sign: (rate=0.5) -> if @boolean rate then 1 else -1

  char: (arg, rangeEnd) ->
    [arg, rangeEnd] = ['abcdefghijklmnopqrstuvwxyz', null] unless arg?
    switch typeof arg
      when 'string'
        if typeof rangeEnd is 'string'
          str = ''
          for n in [arg.charCodeAt(0)..rangeEnd.charCodeAt(0)]
            str += String.fromCharCode(n)
          arg = str

        arg.substr @intRandom(arg.length - 1), 1

      when 'number'
        if typeof rangeEnd is 'number'
          n = String.fromCharCode floor @inRange arg, rangeEnd
        else
          String.fromCharCode @intRandom arg

  inRange: (a, b, c) ->
    res = a + @random b - a
    if typeof c is 'number'
      r = 1 / c
      res -= res % c unless floor(res * r) is res * r

    res = floor(res * 1000000000) / 1000000000
    res

  inArray: (array, ratios, summed) ->
    if array?
      if ratios?
        if ratios.length isnt array.length
          throw new Error 'array and ratios arrays must have the same length'
        if summed
          for b,i in ratios
            if i > 0
              a = ratios[i-1]
              if a > b
                throw new Error 'ratios must be ordered when summed is true'

        if summed
          last = ratios[ratios.length-1]
          ratios = ratios.map (n) -> n / last
        else
          sum = ratios.reduce (a, b) -> a + b
          ratios = ratios.map (n) -> n / sum
          ratios[i] += ratios[i-1] for n,i in ratios when i > 0

        rand = @get()
        return array[i] for v,i in ratios when rand <= v
      else
        array[@intRandom array.length - 1]
    else
      null

  in: (a, b, c) ->
    if arguments.length > 3 then @inArray arguments
    else
      switch typeof a
        when 'number' then @inRange a, b
        when 'string' then @inArray a, b, c
        when 'object'
          if Object::toString.call(a) == '[object Array]'
            @inArray a, b, c
          else
            if a.min? and a.max? then @inRange a.min, a.max, a.step
        else null

  sort: -> => @intPad 2

  random: (amount) -> @get() * (amount or 1)
  intRandom: (amount) -> round @random amount

  pad: (amount) -> amount / 2 - @random amount
  intPad: (amount) -> round @pad amount
