instanciate = (opts={}) ->
  opts[k] = v for k,v of @defaults when not opts[k]?

  new @class opts

instanciateSpline = -> new @class @defaults.vertices

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
    intersects: [
      new agt.geom.Circle(15,50,50)
      new agt.geom.Circle(15,75,70)
    ]
    intersectionInstance: ->
      new @class vertices: [
        new agt.geom.Point(40, 60)
        new agt.geom.Point(120, 70)
        new agt.geom.Point(130, 20)
      ]

  cubic_spline:
    class: agt.geom.CubicBezier
    defaults:
      vertices: [
        # Start
        new agt.geom.Point(10, 50)
        # First quadrant
        new agt.geom.Point(10, 30)
        new agt.geom.Point(25, 10)
        # Top
        new agt.geom.Point(50, 10)
        # Second quadrant
        new agt.geom.Point(75, 10)
        new agt.geom.Point(85, 35)
        # Right
        new agt.geom.Point(85, 50)
        # Third quadrant
        new agt.geom.Point(85, 65)
        new agt.geom.Point(65, 75)
        # Bottom
        new agt.geom.Point(50, 75)
        # Fourth quadrant
        new agt.geom.Point(35, 75)
        new agt.geom.Point(30, 60)
        # Left
        new agt.geom.Point(30, 50)
        # Last quadrant
        new agt.geom.Point(30, 40)
        new agt.geom.Point(40, 35)
        # End
        new agt.geom.Point(50, 35)
      ]
    instance: instanciateSpline

  linear_spline:
    class: agt.geom.LinearSpline
    defaults:
      vertices: [
        new agt.geom.Point(10, 85)
        new agt.geom.Point(40, 10)
        new agt.geom.Point(50, 25)
        new agt.geom.Point(55, 15)
        new agt.geom.Point(85, 75)
        new agt.geom.Point(45, 70)
      ]
    instance: instanciateSpline

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
    stroke: 'base'
    fill: 'base'
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
