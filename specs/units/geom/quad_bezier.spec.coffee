
describe 'QuadBezier', ->
  describe 'when called with four vertices', ->
    source = 'curve'

    beforeEach ->
      addPointMatchers this
      @curve = new agt.geom.QuadBezier([
        point(0,0)
        point(2,2)
        point(4,0)
      ], 20)

    spline(source).shouldBe.cloneable()
    spline(source).shouldBe.formattable('QuadBezier')
    spline(source).shouldBe.sourcable('agt.geom.QuadBezier')

    spline(source).shouldHave(3).vertices()
    spline(source).shouldHave(1).segments()
    spline(source).shouldHave(21).points()

    spline(source).segmentSize.shouldBe(2)
    spline(source).bias.shouldBe(20)

    spline(source).shouldValidateWith(3).vertices()

    # Geometry API
    geometry(source).shouldBe.openGeometry()
    geometry(source).shouldBe.translatable()
    geometry(source).shouldBe.rotatable()
    geometry(source).shouldBe.scalable()

  testPathMethodsOf(agt.geom.QuadBezier)
  testIntersectionsMethodsOf(agt.geom.QuadBezier)
