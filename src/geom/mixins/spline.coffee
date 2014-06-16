# Public: A spline is a curve made of [vertices]{agt.geom.Point} that
# controls the resulting geometry.
#
# The `Spline` mixin set the ground for all other curves classes such as
# the [CubicBezier]{agt.geom.CubicBezier} or the
# [LinearSpline]{agt.geom.LinearSpline} classes.
#
# ```coffeescript
# class DummySpline
#   @include agt.geom.Spine(1)
#
#   # Your spline implementation
# ```
#
# segmentSize - The {Number} of points constituting a segment minus one.
#               For example, the [LinearSpline]{agt.geom.LinearSpline}
#               class sets a segment size of `1`, meaning that for points
#               `[a, b, c, d]` it will have 3 segments `ab`, `bc` and `cd`.
#
# Returns a {ConcreteSpline} mixin.
agt.geom.Spline = (segmentSize) ->

  # Public: The concrete mixin as returned by the
  # [Spline](../files/geom/mixins/spline.coffee.html) method.
  class ConcreteSpline
    @include mixins.Memoizable

    ### Public ###

    # The `Spline` mixin is intended to be included, but it decorates
    # the target class with a class method to return the segment size defined
    # for the class.
    #
    # klass - The [Class]{Function} that receive the mixin.
    @included: (klass) ->
      klass.segmentSize = -> segmentSize

    # Initializes the oject's spline properties. It will also proceed
    # to the validation of the spline's `vertices` based on the segment
    # size specified at the mixin creation.
    #
    # A vertices {Array} is valid when its length is equal
    # to `x * segmentSize + 1` where `x` is any integer greater
    # or equal to `1`.
    #
    # vertices - The {Array} of [Points]{agt.geom.Point} that forms the
    #            spline shape.
    # bias - The {Number} of steps per segments when generating the points
    #        of the final geometry.
    initSpline: (@vertices, @bias=20) ->
      unless @validateVertices @vertices
        throw new Error "The number of vertices for #{this} doesn't match"

    # Returns the center of the spline by averaging its vertices.
    #
    # Returns a [Point]{agt.geom.Point}.
    center: ->
      x = y = 0

      for vertex in @vertices
        x += vertex.x
        y += vertex.y

      x = x / @vertices.length
      y = y / @vertices.length

      new Point x, y

    # Applies a translation represented by the passed-in [point]{agt.geom.Point}
    # to every vertices of the spline.
    #
    # x - A {Number} for the x coordinate or a point-like {Object}.
    # y - A {Number} for the y coordinate if the first argument is also a number.
    #
    # Returns this {ConcreteSpline}.
    translate: (x,y) ->
      {x,y} = Point.pointFrom x,y
      for vertex,i in @vertices
        @vertices[i] = vertex.add x, y
      this

    # Rotates every vertices around the spline center by an amount of `rotation`
    # radians.
    #
    # rotation - The {Number} of radians to rotate the spline.
    #
    # Returns this {ConcreteSpline}.
    rotate: (rotation) ->
      center = @center()
      for vertex,i in @vertices
        @vertices[i] = vertex.rotateAround center, rotation
      this

    # Scales the spline by moving every vertices on the vector they forms with
    # the spline center.
    #
    # scale - The scaling factor {Number}, a value of `0.5` will scale down
    #         the spline at half its original size when a value of `2` will
    #         double the size of the spline.
    #
    # Returns this {ConcreteSpline}.
    scale: (scale) ->
      center = @center()
      for vertex,i in @vertices
        @vertices[i] = center.add vertex.subtract(center).scale(scale)
      this

    # Returns the *final* points of the curve as determined by the `bias`
    # property of the current spline. The total number of points for a geometry
    # is always the result of the following equation: `segment size * number
    # of segments`.
    #
    # Returns an {Array} of [Points]{agt.geom.Point}.
    points: ->
      return @memoFor('points').concat() if @memoized 'points'
      segments = @segments() * @bias
      points = (@pathPointAt i / segments for i in [0..segments])
      @memoize('points', points).concat()

    # Internal: Validates the length of the vertices {Array}.
    validateVertices: (vertices) ->
      vertices.length % segmentSize is 1 and
      vertices.length >= segmentSize + 1

    # Returns the {Number} of segments of the current spline based on the
    # spline configuration.
    #
    # Returns a {Number}.
    segments: ->
      return 0 if not @vertices? or @vertices.length is 0
      return @memoFor 'segments' if @memoized 'segments'
      @memoize 'segments', (@vertices.length - 1) / segmentSize

    # Returns the size {Number} of the spline segments.
    #
    # Returns a {Number}.
    segmentSize: -> segmentSize

    # Returns the segment at `index`. A segment is a pair of
    # [Points]{agt.geom.Point} of each extremity of the segment.
    #
    # index - The index {Number} of the segment.
    #
    # Returns an {Array} of [Points]{agt.geom.Point}.
    segment: (index) ->
      if index < @segments()
        k = "segment#{index}"
        return @memoFor k if @memoized k
        @memoize k, @vertices
          .concat()
          .slice(index * segmentSize, (index + 1) * segmentSize + 1)
      else
        null

    # Returns the length of the spline in pixels.
    #
    # This an approximative value based on the current spline `bias`, so the
    # bigger the `bias` the more accurate the length is, with the downside
    # of poorer performances.
    #
    # Returns a {Number}.
    length: -> @measure @bias

    # Internal: Measures the spline using the passed-in bias.
    #
    # bias - The {Number} of steps used to walk the spline segments.
    #
    # Returns a {Number}.
    measure: (bias) ->
      return @memoFor 'measure' if @memoized 'measure'
      length = 0
      length += @measureSegment @segment(i), bias for i in [0..@segments()-1]
      @memoize 'measure', length

    # Internal: Measures the given segment using the passed-in bias.
    #
    # segment - The index {Number} of the segment to measure.
    # bias - The {Number} of steps used to walk the segment.
    #
    # Returns a {Number}.
    measureSegment: (segment, bias) ->
      k = "segment#{segment}_#{bias}Length"
      return @memoFor k if @memoized k

      step = 1 / bias
      length = 0

      for i in [1..bias]
        length += @pointInSegment((i-1) * step, segment)
                    .distance(@pointInSegment(i * step, segment))

      @memoize k, length

    # {Delegates to: agt.geom.Path.pathPointAt}
    pathPointAt: (pos, pathBasedOnLength=true) ->
      pos = 0 if pos < 0
      pos = 1 if pos > 1

      return @vertices[0] if pos is 0
      return @vertices[@vertices.length - 1] if pos is 1

      if pathBasedOnLength
        @walkPathBasedOnLength pos
      else
        @walkPathBasedOnSegments pos

    # Internal: Iterates over the spline steps until the given `pos` and
    # returns the corresponding coordinates.
    #
    # In this implementation the path is walked with each segment taking
    # a space in the total spline length based on its own length.
    #
    # pos - The position {Number} between `0` and `1`.
    #
    # Returns a [Point]{agt.geom.Point}.
    walkPathBasedOnLength: (pos) ->
      walked = 0
      length = @length()
      segments = @segments()

      for i in [0..segments-1]
        segment = @segment i
        stepLength = @measureSegment(segment, @bias) / length

        if walked + stepLength > pos
          innerStepPos = Math.map pos, walked, walked + stepLength, 0, 1
          return @pointInSegment innerStepPos, segment

        walked += stepLength

    # Internal: Iterates over the spline steps until the given `pos` and
    # returns the corresponding coordinates.
    #
    # In this implementation the path is walked with each segment taking
    # based on the number of segments in the spline.
    #
    # pos - The position {Number} between `0` and `1`.
    #
    # Returns a [Point]{agt.geom.Point}.
    walkPathBasedOnSegments: (pos) ->
      segments = @segments()
      pos = pos * segments
      segment = Math.floor pos
      segment -= 1 if segment is segments
      @pointInSegment pos - segment, @segment segment

    # **Unsupported** - The {agt.geom.Geometry::fill} method is not supported
    # by splines as they are not closed geometry.
    fill: ->

    # {Delegates to: agt.geom.Geometry.drawPath}
    drawPath: (context) ->
      points = @points()
      start = points.shift()
      context.beginPath()
      context.moveTo(start.x,start.y)
      context.lineTo(p.x,p.y) for p in points

    drawVertices: (context, color) ->
    # Draws the spline vertices onto the passed-in canvas context.
    #
    # context - The canvas context to draw in.
    # color - The color {String} to use for the vertices.
      context.fillStyle = color
      for vertex in @vertices
        context.beginPath()
        context.arc vertex.x, vertex.y, 2, 0, Math.PI*2
        context.fill()
        context.closePath()

    drawVerticesConnections: (context, color) ->
    # Draws the segments between each vertex onto the passed-in canvas context.
    #
    # context - The canvas context to draw in.
    # color - The color {String} to use for the vertices connections.
      context.strokeStyle = color
      for i in [1..@vertices.length-1]
        vertexStart = @vertices[i-1]
        vertexEnd = @vertices[i]
        context.beginPath()
        context.moveTo vertexStart.x, vertexStart.y
        context.lineTo vertexEnd.x, vertexEnd.y
        context.stroke()
        context.closePath()

    # The memoization key of a spline is the concatenation of its vertices.
    #
    # Returns a {String}.
    memoizationKey: ->
      @vertices.map((pt) -> "#{pt.x};#{pt.y}").join(';')

    # {Delegates to: ConcreteCloneable.clone}
    clone: -> new @constructor @vertices.map((pt) -> pt.clone()), @bias
