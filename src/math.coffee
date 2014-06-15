
Math.PI2 = Math.PI * 2
Math.PI_2 = Math.PI / 2
Math.PI_4 = Math.PI / 4
Math.PI_8 = Math.PI / 8

### Public: Instances Methods ###

Math.degToRad = (n) -> n * Math.PI / 180

Math.radToDeg = (n) -> n * 180 / Math.PI

Math.normalize = (value, minimum, maximum) ->
  (value - minimum) / (maximum - minimum)

Math.interpolate = (normValue, minimum, maximum) ->
  minimum + (maximum - minimum) * normValue

Math.deltaBelowRatio = (a, b, ratio=10000000000) -> Math.abs(a - b) < 1 / ratio

Math.map = (value, min1, max1, min2, max2) ->
  Math.interpolate Math.normalize(value, min1, max1), min2, max2

# Returns true if the passed-in argument can be casted to a number.
#
#     Math.isFloat 0.245 # true
#     Math.isFloat '12'  # true
#     Math.isFloat 'foo' # false
Math.isFloat = (floats...) ->
  return false for float in floats when isNaN parseFloat float
  true

Math.isInt = (ints...) ->
  return false for int in ints when isNaN parseInt int
  true

# Returns the passed-in arguments casted into floats.
Math.asFloat = (floats...) ->
  floats[i] = parseFloat n for n,i in floats
  floats

# Returns the passed-in arguments casted into floats.
Math.asInt = (ints...) ->
  ints[i] = parseInt n for n,i in ints
  ints
