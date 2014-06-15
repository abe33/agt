
describe 'LinearSpline', ->
  describe 'when instanciated with one point', ->
    it 'throws an error', ->
      expect(-> new agt.geom.LinearSpline [point()] ).toThrow()

  describe 'when instanciated with four points', ->
    source = 'spline'

    beforeEach ->
      addPointMatchers this
      @spline = new agt.geom.LinearSpline [ point(0,3), point(3,3),
                                   point(3,0), point(6,0) ]

    it 'has registered the points as its vertices', ->
      expect(@spline.vertices[0]).toBePoint(0,3)
      expect(@spline.vertices[1]).toBePoint(3,3)
      expect(@spline.vertices[2]).toBePoint(3,0)
      expect(@spline.vertices[3]).toBePoint(6,0)


    spline(source).shouldBe.cloneable()
    spline(source).shouldBe.formattable('LinearSpline')
    spline(source).shouldBe.sourcable('agt.geom.LinearSpline')

    spline(source).shouldHave(4).vertices()
    spline(source).shouldHave(3).segments()
    spline(source).shouldHave(4).points()

    spline(source).segmentSize.shouldBe(1)
    spline(source).bias.shouldBe(20)

    spline(source).shouldValidateWith(2).vertices()

    lengthOf(source).shouldBe(9)

    # Geometry API
    geometry(source).shouldBe.openGeometry()
    geometry(source).shouldBe.translatable()
    geometry(source).shouldBe.rotatable()
    geometry(source).shouldBe.scalable()

  testPathMethodsOf(agt.geom.LinearSpline)
  testIntersectionsMethodsOf(agt.geom.LinearSpline)
