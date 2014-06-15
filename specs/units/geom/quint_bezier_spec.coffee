
describe 'QuintBezier', ->
  describe 'when called with four vertices', ->
    source = 'curve'

    beforeEach ->
      addPointMatchers this
      @curve = new agt.geom.QuintBezier([
        point(0,0)
        point(2,2)
        point(4,0)
        point(6,2)
        point(8,0)
      ], 20)

    spline(source).shouldBe.cloneable()
    spline(source).shouldBe.formattable('QuintBezier')
    spline(source).shouldBe.sourcable('agt.geom.QuintBezier')

    spline(source).shouldHave(5).vertices()
    spline(source).shouldHave(1).segments()
    spline(source).shouldHave(21).points()

    spline(source).segmentSize.shouldBe(4)
    spline(source).bias.shouldBe(20)

    spline(source).shouldValidateWith(5).vertices()

    # Geometry API
    geometry(source).shouldBe.openGeometry()
    geometry(source).shouldBe.translatable()
    geometry(source).shouldBe.rotatable()
    geometry(source).shouldBe.scalable()

  testPathMethodsOf(agt.geom.QuintBezier)
  testIntersectionsMethodsOf(agt.geom.QuintBezier)
