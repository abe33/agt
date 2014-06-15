
global.polygon = (vertices) -> new agt.geom.Polygon vertices

global.polygonData = (vertices) ->
  data = {vertices}

  merge data, {
    source: "new agt.geom.Polygon([#{vertices.map (pt) -> pt.toSource()}])"
  }

  data

global.polygonFactories =
  'with four points in an array':
    args: -> [[point(0,0), point(4,0), point(4,4), point(0,4)]]
    test: -> [point(0,0), point(4,0), point(4,4), point(0,4)]
  'with an object containing vertices':
    args: -> [vertices: [point(0,0), point(4,0), point(4,4), point(0,4)]]
    test: -> [point(0,0), point(4,0), point(4,4), point(0,4)]
