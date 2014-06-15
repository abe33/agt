# Public: A `Point` represent a location in a two-dimensional space.
#
# A point with coordinates (0,0) can be constructed with:
#
# ```coffeescript
# new Point
# new Point 0, 0
# new Point x: 0, y: 0
# ```
#
# **Note:** Any functions in agt that accept a `Point` object also allow
# to use numbers instead, this is obviously also the case in the `Point`
# class. For more details about how to achieve the same behavior in your own
# functions please refer to the {.pointFrom} method.
#
# ### Includes
#
# - [agt.mixins.Equatable](../../../files/mixins/equatable.coffee.html)
# - [agt.mixins.Formattable](../../../files/mixins/formattable.coffee.html)
# - [agt.mixins.Sourcable](../../../files/mixins/sourcable.coffee.html)
# - [agt.mixins.Cloneable](../../../files/mixins/cloneable.coffee.html)
class agt.geom.Point
  @include mixins.Equatable('x', 'y')
  @include mixins.Formattable('Point','x', 'y')
  @include mixins.Sourcable('agt.geom.Point', 'x', 'y')
  @include mixins.Cloneable()

  ### Public: Static methods ###

  # Returns `true` if the passed-in object pass the requirments
  # to be a point. Valid points are objects that possess a x and
  # a y property.
  #
  # ```coffeescript
  # Point.isPoint new Point  # true
  # Point.isPoint x: 0, y: 0 # true
  # Point.isPoint x: 0       # false
  # ```
  #
  # pt - The point {Object} that will be tested.
  #
  # Returns a {Boolean}
  @isPoint: (pt) -> pt? and pt.x? and pt.y?

  # Returns a point according to the provided arguments:
  #
  # ```coffeescript
  # translate = (xOrPt, y) ->
  #   point = Point.pointFrom xOrPt, y
  #   # ...
  # ```
  #
  # The first argument can be either an {Object} or a {Number}.
  # In the case the argument is an object, the function will
  # extract the x and y values from it. However, if the `strict`
  # argument is `true`, the function will throw an error if
  # the object does not have either x or y property:
  #
  # ```coffeescript
  # Point.pointFrom x: 10            # will not throw
  # Point.pointFrom x: 10, 0, true   # will throw
  # ```
  #
  # In the case the object is incomplete or empty, and with
  # the strict mode disabled, the missing property will end
  # being set to `0`.
  #
  # ```coffeescript
  # point = Point.pointFrom x: 10 # {x: 10, y: NaN}
  # ```
  #
  # For further examples, feel free to take a look at the
  # methods of the `Point` class.
  #
  # xOrPt - The x {Number} value or a point-like {Object}.
  # y - The y {Number} value
  # strict - A {Boolean} of whether the method raises an exception
  #          on type mismatch.
  #
  # Returns a {agt.geom.Point} instance
  @pointFrom: (xOrPt, y, strict=false) ->
    x = xOrPt
    {x,y} = xOrPt if xOrPt? and typeof xOrPt is 'object'
    @notAPoint [x,y] if strict and (isNaN(x) or isNaN(y))
    new Point x, y

  # Converts polar coordinates in cartesian coordinates.
  #
  #     Point.polar 90, 10 # [Point(x=0,y=10)]
  @polar: (angle, length=1) -> new Point Math.sin(angle) * length,
                                         Math.cos(angle) * length

  # Returns a point between `pt1` and `pt2` at a ratio corresponding to `pos`.
  #
  # The `Point.interpolate` method supports all the following forms:
  #
  #     Point.interpolate pt1, pt2, pos
  #     Point.interpolate x1, y1, pt2, pos
  #     Point.interpolate pt1, x2, y2, pos
  #     Point.interpolate x1, x2, x2, y2, pos
  @interpolate: (pt1, pt2, pos) ->
    args = []; args[i] = v for v,i in arguments

    # Utility function that extract a point from `args`
    # and removes the values it used from it.
    extract = (args, name) =>
      pt = null
      if @isPoint args[0] then pt = args.shift()
      else if Math.isFloat(args[0]) and Math.isFloat(args[1])
        pt = new Point args[0], args[1]
        args.splice 0, 2
      else @missingPoint args, name
      pt

    pt1 = extract args, 'first'
    pt2 = extract args, 'second'
    pos = parseFloat args.shift()
    @missingPosition pos if isNaN pos

    dif = pt2.subtract(pt1)
    new Point pt1.x + dif.x * pos,
              pt1.y + dif.y * pos

  ### Internal: Class error methods ###

  # Throws an error for a missing position in `Point.interpolate`.
  @missingPosition: (pos) ->
    throw new Error "Point.interpolate require a position but #{pos} was given"

  # Throws an error for a missing point in `Point.interpolate`.
  @missingPoint: (args, pos) ->
    msg = "Can't find the #{pos} point in Point.interpolate arguments #{args}"
    throw new Error msg

  # Throws an error for an invalid point in `Point.pointFrom`.
  @notAPoint: (args) ->
    throw new Error "#{args} is not a point"

  ### Public: Instances methods ###

  # Whatever is passed to the `Point` constructor, a valid point
  # is always returned. All invalid properties will be default to `0`.
  #
  # A point be constructed with the following forms:
  #
  #     new Point
  #     new Point 0, 0
  #     new Point x: 0, y: 0
  constructor: (x, y) ->
    y = x.y or y if x?; y = 0 if isNaN y
    x = x.x or x if x?; x = 0 if isNaN x
    @x = x
    @y = y

  # Returns the length of the current vector represented by this point.
  #
  #     length = point.length()
  length: -> Math.sqrt (@x * @x) + (@y * @y)

  # Returns the angle in degrees formed by the vector.
  #
  #     angle = point.angle()
  angle: -> Math.atan2 @y, @x

  # Given a triangle formed by this point, the passed-in point
  # and the origin (0,0), the `Point::angleWith` method will
  # return the angle in degrees formed by the two vectors at
  # the origin.
  #
  #     point1 = new Point 10, 0
  #     point2 = new Point 10, 10
  #     angle = point1.angleWith point2
  #     # angle = 45
  angleWith: (x, y) ->
    @noPoint 'dot' if not x? and not y?
    isPoint = @isPoint x
    y = if isPoint then x.y else y
    x = if isPoint then x.x else x
    Point.notAPoint [x,y] if (isNaN(x) or isNaN(y))

    d = @normalize().dot new Point(x,y).normalize()

    Math.acos(Math.abs(d)) * (if d < 0 then -1 else 1)

  # Returns a new point of length `length`.
  #
  #     normalized = point.normalize()
  #     normalized.length() # 1
  #
  #     normalized = point.normalize(6)
  #     normalized.length() # 6
  normalize: (length=1) ->
    @invalidLength length unless Math.isFloat length
    l = @length()
    new Point @x / l * length, @y / l * length

  # Returns a new point resulting of the addition of the
  # passed-in point to this point.
  #
  #     point = new Point 4, 4
  #     inc = point.add 1, 5
  #     inc = point.add x: 0.2
  #     inc = point.add new Point 1.8, 8
  #     # inc = [Point(x=7,y=17)]
  add: (x, y) ->
    y = x.y or y if x?; y = 0 if isNaN y
    x = x.x or x if x?; x = 0 if isNaN x
    new Point @x + x, @y + y

  # Returns a new point resulting of the subtraction of the
  # passed-in point to this point.
  #
  #     point = new Point 4, 4
  #     inc = point.subtract 1, 5
  #     inc = point.subtract x: 0.2
  #     inc = point.subtract new Point 1.8, 8
  #     # inc = [Point(x=2,y=-9)]
  subtract: (x, y) ->
    y = x.y or y if x?; y = 0 if isNaN y
    x = x.x or x if x?; x = 0 if isNaN x
    new Point @x - x, @y - y

  # Returns the dot product of this point and the passed-in point.
  #
  #     dot = new Point(5,6).dot(7,8)
  #     # dot = 83
  dot: (x, y) ->
    @noPoint 'dot' if not x? and not y?
    isPoint = @isPoint x
    y = if isPoint then x.y else y
    x = if isPoint then x.x else x
    Point.notAPoint [x,y] if (isNaN(x) or isNaN(y))
    @x * x + @y * y

  # Returns the distance between this point and the passed-in point.
  #
  #     distance = new Point(0,2).distance(2,2)
  #     # distance = 2
  distance: (x, y) ->
    @noPoint 'distance' if not x? and not y?
    isPoint = @isPoint x
    y = if isPoint then x.y else y
    x = if isPoint then x.x else x
    Point.notAPoint [x,y] if (isNaN(x) or isNaN(y))
    @subtract(x,y).length()

  # Returns a new point which is a scaled copy of the current point.
  #
  #     point = new Point 1, 1
  #     scaled = point.scale 2
  #     # scaled = [Point(x=2,y=2)]
  scale: (n) ->
    @invalidScale n unless Math.isFloat n
    new Point @x * n, @y * n

  # Returns a new point which is the result of rotating the
  # current point around the origin (0,0).
  #
  #     point = new Point 10, 0
  #     rotated = point.rotate 90
  #     # rotated = [Point(x=0,y=10)]
  rotate: (n) ->
    @invalidRotation n unless Math.isFloat n
    l = @length()
    a = Math.atan2(@y, @x) + n
    x = Math.cos(a) * l
    y = Math.sin(a) * l
    new Point x, y

  # Returns a new point which is the result of rotating the
  # current point around the passed-in point.
  #
  #     point = new Point 10, 0
  #     origin = new Point 20, 0
  #     rotated = point.rotateAround origin, 90
  #     # rotated = [Point(x=20,y=-10)]
  rotateAround: (x, y, a) ->
    isPoint = @isPoint x
    a = y if isPoint
    y = if isPoint then x.y else y
    x = if isPoint then x.x else x

    @subtract(x,y).rotate(a).add(x,y)

  # Alias the `Point.isPoint` method in instances.
  isPoint: Point.isPoint

  # Alias the `Point.pointFrom` method in instances.
  pointFrom: Point.pointFrom

  # Returns the two arguments x and y in an array where arguments
  # that were `NaN` are replaced by `0`.
  defaultToZero: (x, y) ->
    x = if isNaN x then 0 else x
    y = if isNaN y then 0 else y
    [x,y]

  # Copy the values of the passed-in point into this point.
  #
  #     point = new Point
  #     point.paste 1, 7
  #     # point = [Point(x=5,y=7)]
  #
  #     point.paste new Point 4, 4
  #     # point = [Point(x=4,y=4)]
  paste: (x, y) ->
    return this if not x? and not y?
    isObject = x? and typeof x is 'object'
    y = if isObject then x.y else y
    x = if isObject then x.x else x
    @x = x unless isNaN x
    @y = y unless isNaN y
    this

  ### Internal: Instances error methods ###

  # A generic error helper used by methods that require a point argument
  # and was called without it.
  noPoint: (method) ->
    throw new Error "#{method} was called without arguments"

  # Throws an error for an invalid length in `Point::normalize` method.
  invalidLength: (l) ->
    throw new Error "Invalid length #{l} provided"

  # Throws an error for an invalid scale in `Point::scale` method.
  invalidScale: (s) ->
    throw new Error "Invalid scale #{s} provided"

  ##### Point::invalidRotation
  #
  # Throws an error for an invalid rotation in `Point::rotate`
  # and `Point::rotateAround` method.
  invalidRotation: (a) ->
    throw new Error "Invalid rotation #{a} provided"
