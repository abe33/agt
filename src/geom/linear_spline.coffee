
{Point,Intersections,Geometry,Spline,Path} = agt.geom

# Public: 
class agt.geom.LinearSpline
  @include mixins.Formattable('LinearSpline')
  @include mixins.Sourcable('agt.geom.LinearSpline', 'vertices', 'bias')
  @include Geometry
  @include Path
  @include Intersections
  @include Spline(1)

  ### Public: Instances Methods ###

  constructor: (vertices, bias) ->
    @initSpline vertices, bias

  points: -> vertex.clone() for vertex in @vertices

  segments: -> @vertices.length - 1

  validateVertices: (vertices) -> vertices.length >= 2

  drawVerticesConnections: ->
