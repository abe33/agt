instanciate = (opts={}) ->
  opts[k] = v for k,v of @defaults when not opts[k]?

  new @class opts

defaults =
  width: 100
  height: 100

  geometry:
    class: agt.geom.Polygon
    defaults:
      vertices: [
        new agt.geom.Point(40, 10)
        new agt.geom.Point(50, 25)
        new agt.geom.Point(55, 15)
        new agt.geom.Point(85, 75)
        new agt.geom.Point(45, 70)
        new agt.geom.Point(10, 85)
      ]
    instance: instanciate
    contains: [
      new agt.geom.Circle(15,50,50)
      new agt.geom.Circle(15,75,70)
    ]

  circle:
    class: agt.geom.Circle
    defaults:
      radius: 40
      x: 50
      y: 50

    instance: instanciate
    intersectionInstance: -> new @class 40, 100, 50

  rectangle:
    class: agt.geom.Rectangle
    defaults:
      x: 20
      y: 20
      width: 75
      height: 40
      rotation: Math.PI * 0.1

    instance: instanciate
    intersectionInstance: ->
      new @class 60, 35, 80, 30

  triangle:
    class: agt.geom.Triangle
    defaults:
      a: new agt.geom.Point 40, 10
      b: new agt.geom.Point 10, 70
      c: new agt.geom.Point 90, 85

    instance: instanciate
    intersectionInstance: ->
      new @class
        a: new agt.geom.Point 40, 60
        b: new agt.geom.Point 130, 20
        c: new agt.geom.Point 120, 70

  render:
    angle: false
    paths: false
    contains: false
    center: false
    bounds: false
    center: false
    surface: false
    triangles: false
    vertices: false
    highlight: false