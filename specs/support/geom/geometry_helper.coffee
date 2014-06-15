
global.geometry = (source) ->
  shouldBe:
    translatable: ->
      xAmount = 5
      yAmount = 3

      describe 'its translate method', ->
        describe 'called with an object', ->
          it 'translates the geometry', ->
            target = this[source]
            original = target.points()
            target.translate {x:xAmount, y:yAmount}

            for pt,i in target.points()
              pt2 = original[i]
              expect(pt).toBeSamePoint(pt2.add xAmount, yAmount)

        describe 'call with two number', ->
          it 'translates the geometry', ->
            target = this[source]
            original = target.points()
            target.translate xAmount, yAmount

            for pt,i in target.points()
              pt2 = original[i]
              expect(pt).toBeSamePoint(pt2.add xAmount, yAmount)

        it 'returns the instance', ->
          expect(this[source].translate()).toBe(this[source])

    rotatable: ->
      rotation = 10
      describe 'its rotate method', ->
        it 'rotates the geometry around its center', ->
          target = this[source]
          center = target.center()
          original = target.points()
          target.rotate rotation

          for pt,i in target.points()
            pt2 = original[i]
            expect(pt).toBeSamePoint(pt2.rotateAround center, rotation)

        it 'returns the instance', ->
          expect(this[source].rotate(0)).toBe(this[source])

    scalable: ->
      scale = 2
      describe 'its scale method', ->
        it 'scales the geometry around its center', ->
          target = this[source]
          center = target.center()
          original = target.points()
          target.scale scale

          for pt,i in target.points()
            pt2 = original[i]
            expect(pt)
            .toBeSamePoint(center.add pt2.subtract(center).scale(scale))

        it 'returns the instance', ->
          expect(this[source].scale(1)).toBe(this[source])

    closedGeometry: ->
      it 'is a closed geometry', ->
        expect(@[source].closedGeometry()).toBeTruthy()

    openGeometry: ->
      it 'is an open geometry', ->
        expect(@[source].closedGeometry()).toBeFalsy()


global.testDrawingOf = (source) ->
  describe "with drawing api", ->
    beforeEach ->
      @context =
        fill: => @fillCalled = true
        stroke: => @strokeCalled = true
        beginPath: => @beginPathCalled = true
        closePath: => @closePathCalled = true
        moveTo: => @moveToCalled = true
        lineTo: => @lineToCalled = true
        arc: => @arcCalled = true
        save: => @saveCalled = true
        restore: => @restoreCalled = true
        translate: => @translateCalled = true
        rotate: => @rotateCalled = true
        scale: => @scaleCalled = true

    describe "the #{source} stroke method", ->
      beforeEach ->
        @color = "#ffffff"
        @[source].stroke @context, @color

      it 'sets the stroke style on the context object', ->
        expect(@context.strokeStyle).toBe(@color)
      it 'calls the stroke method of the context object', ->
        expect(@strokeCalled).toBeTruthy()

    describe "the #{source} fill method", ->
      beforeEach ->
        @color = "#ffffff"
        @[source].fill @context, @color

      it 'sets the fill style on the context object', ->
        expect(@context.fillStyle).toBe(@color)
      it 'calls the fill method of the context object', ->
        expect(@fillCalled).toBeTruthy()
