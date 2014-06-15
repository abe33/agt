# Public:
class agt.geom.Surface
  ### Public: Instances Methods ###

  acreage: -> null

  randomPointInSurface: -> null

  contains: (xOrPt, y) -> null

  containsGeometry: (geometry) ->
    geometry.points().every (point) => @contains point
