
Point = agt.geom.Point

construct = (klass, args) ->
  f = BUILDS[if args? then args.length else 0]
  f klass, args

testSplineMethod = (method, source, expected) ->
  describe "its #{method} method", ->
    it "returns #{expected}", ->
      expect(this[source][method]()).toBeClose(expected)

testSplineLength = (method, source, expected) ->
  describe "its #{method} method", ->
    it "returns an array of length #{expected}", ->
      expect(this[source][method]().length).toBeClose(expected)

testSplineProperty = (property, source, expected) ->
  describe "its #{property} property", ->
    it "is #{expected}", ->
      expect(this[source][property]).toBeClose(expected)

testPropertyLength = (property, source, expected) ->
  describe "its #{property} property", ->
    it "has #{expected} elements", ->
      expect(this[source][property].length).toBeClose(expected)

global.testIntersectionsMethodsOf = (klass) ->
  segmentSize = klass.segmentSize()
  mid = segmentSize / 2
  vertices = (point(i,0) for i in [0..segmentSize])
  describe "when instanciated with #{vertices}", ->
    beforeEach ->
      addPointMatchers this
      @spline = construct klass, [vertices]

    describe 'its intersects method', ->
      describe 'called with a simple line crossing it in the middle', ->
        it 'returns true', ->
          expect(@spline.intersects points: -> [point(mid,-1),point(mid,1)])
          .toBeTruthy()

      describe 'called with a simple line not crossing it', ->
        it 'returns false', ->
          expect(@spline.intersects points: -> [point(-2,-1),point(-2,1)])
          .toBeFalsy()

    describe 'its intersections method', ->
      describe 'called with a simple line crossing it in the middle', ->
        it 'returns true', ->
          intersections = @spline.intersections points: -> [ point(mid,-1),
                                                             point(mid,1) ]
          expect(intersections.length).toBe(1)
          expect(intersections[0]).toBePoint(mid,0)

      describe 'called with a simple line not crossing it', ->
        it 'returns false', ->
          intersections = @spline.intersections points: -> [ point(-2,-1),
                                                             point(-2,1) ]
          expect(intersections).toBeNull()

global.testPathMethodsOf = (klass) ->
  segmentSize = klass.segmentSize()
  hpoints = (point(i,0) for i in [0..segmentSize])
  vpoints = (point(0,i) for i in [0..segmentSize])
  [hpoints, vpoints].forEach (vertices) ->
    describe "when instanciated with #{vertices}", ->
      beforeEach ->
        addPointMatchers this
        @spline = construct klass, [vertices]

      describe 'its pathPointAt method', ->
        describe 'called with 0', ->
          it 'returns the first vertice', ->
            expect(@spline.pathPointAt 0)
            .toBeSamePoint(first(vertices))

        describe 'called with 0.5', ->
          it 'returns the first vertice', ->
            expect(@spline.pathPointAt 0.5)
            .toBeSamePoint(first(vertices).add last(vertices).scale(0.5))

        describe 'called with 1', ->
          it 'returns the last vertice', ->
            expect(@spline.pathPointAt 1)
            .toBeSamePoint(last(vertices))

global.spline = (source) ->
  shouldBe:
    cloneable: ->
      describe 'its clone method', ->
        beforeEach ->
          @target = this[source]
          @copy = @target.clone()
        it 'returns a copy of the spline', ->
          expect(@copy).toBeDefined()
          expect(@copy.vertices).toEqual(@target.vertices)

        it 'returns a simple reference to the original vertices', ->
          expect(@copy.vertices).not.toBe(@target.vertices)
          for vertex,i in @copy.vertices
            expect(vertex).not.toBe(@target.vertices[i])

    formattable: (classname) ->
      describe 'its classname method', ->
        it 'returns its class name', ->
          expect(this[source].classname()).toBe(classname)

      describe 'its toString method', ->
        it 'returns the classname in a formatted string', ->
          expect(this[source].toString().indexOf classname).not.toBe(-1)

    sourcable: (pkg) ->
      describe 'its toSource method', ->
        it 'returns the code to create the spline again', ->
          target = this[source]
          result = target.toSource()
          verticesSource = target.vertices.map (p) -> p.toSource()
          expect(result)
          .toBe("new #{pkg}([#{verticesSource.join ','}],#{target.bias})")

  shouldHave: (expected) ->
    segments: -> testSplineMethod 'segments', source, expected
    points: -> testSplineLength 'points', source, expected
    vertices: -> testPropertyLength 'vertices', source, expected

  shouldValidateWith: (expected) ->
    vertices: ->
      describe "its validateVertices method", ->
        failingAmount = expected - 1

        describe "called with #{failingAmount} vertices", ->
          it 'returns false', ->
            vertices = (point() for n in [0..failingAmount-1])
            res = this[source].validateVertices vertices
            expect(res).toBeFalsy()

        describe "called with #{expected} vertices", ->
          it 'returns true', ->
            vertices = (point() for n in [0..expected-1])
            res = this[source].validateVertices vertices
            expect(res).toBeTruthy()

  segmentSize:
    shouldBe: (expected) -> testSplineMethod 'segmentSize', source, expected
  bias:
    shouldBe: (expected) -> testSplineProperty 'bias', source, expected
