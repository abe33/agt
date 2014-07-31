{Point,Intersections,Geometry,Spline,Path} = agt.geom

# Public: The `LinearSpline` is the simplest spline you can find.
#
# <script>window.exampleKey = 'linear_spline'</script>
# <script>drawGeometry(exampleKey, {highlight: true})</script>
#
# ### Included Mixins
#
# - {agt.geom.Geometry}
# - {agt.geom.Intersections}
# - {agt.geom.Path}
# - [agt.mixins.Spline](../../../files/geom/mixins/spline.coffee.html)
# - [agt.mixins.Formattable](../../../files/mixins/formattable.coffee.html)
# - [agt.mixins.Memoizable](../../../files/mixins/memoizable.coffee.html)
# - [agt.mixins.Sourcable](../../../files/mixins/sourcable.coffee.html)
class agt.geom.LinearSpline
  @include mixins.Formattable('LinearSpline')
  @include mixins.Sourcable('agt.geom.LinearSpline', 'vertices', 'bias')
  @include Geometry
  @include Path
  @include Intersections
  @include Spline(1)

  ### Public ###

  # Creates a new [LinearSpline]{agt.geom.LinearSpline}
  #
  # vertices - An {Array} of [Points]{agt.geom.Point} that forms the spline.
  constructor: (vertices) ->
    @initSpline vertices

  # The points of a linear spline are the same as its array of vertices.
  #
  # <script>drawGeometryPoints(exampleKey, 'points')</script>
  #
  # Returns an {Array} of [Points]{agt.geom.Point}.
  points: -> vertex.clone() for vertex in @vertices

  # Returns the number of segments in the spline.
  #
  # Returns a {Number}
  segments: -> @vertices.length - 1

  # **Unsupported** - As the final points of a linear spine are its vertices
  # there's no need to render the connections between them.
  drawVerticesConnections: ->

  ### Internal ###
  validateVertices: (vertices) -> vertices.length >= 2
