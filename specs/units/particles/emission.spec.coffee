Point = agt.geom.Point
Particle = agt.particles.Particle
Emission = agt.particles.Emission
Limited = agt.particles.timers.Limited
ByRate = agt.particles.counters.ByRate
Ponctual = agt.particles.emitters.Ponctual
Life = agt.particles.initializers.Life
Live = agt.particles.actions.Live

describe 'Emission', ->
  describe 'when instanciated with all components', ->
    beforeEach ->
      @emitter = emitter = new Ponctual(new Point)
      @timer = timer = new Limited(1000)
      @counter = counter = new ByRate(10)
      @initializer = initializer = new Life(100)
      @action = action = new Live()
      @emission = new Emission({class: Particle, emitter, timer, counter, initializer, action})

    it 'should have stored the passed-in arguments', ->
      expect(@emission.class).toBe(Particle)
      expect(@emission.emitter).toBe(@emitter)
      expect(@emission.timer).toBe(@timer)
      expect(@emission.counter).toBe(@counter)
      expect(@emission.initializer).toBe(@initializer)
      expect(@emission.action).toBe(@action)

    describe 'when its prepare method is called', ->
      beforeEach -> @emission.prepare 500, 0.5, 500

      it 'should have setup the emission based on its components', ->
        expect(@emission.currentCount).toBe(6)
        expect(@emission.currentTime).toBe(500)

      emission('emission').shouldBe.iterable(6)

      it 'should not have finished', ->
        expect(@emission.finished()).toBeFalsy()

      describe 'with a step that lead to the end of its time', ->
        beforeEach -> @emission.prepare 500, 0.5, 500

        it 'should have finished', ->
          expect(@emission.finished()).toBeTruthy()

      describe 'its next method called in a loop', ->
        it 'should return particles that have been initialized', ->
          e = @emission
          n = 0
          max = 100
          while e.hasNext()
            particle = e.next()
            expect(particle.maxLife).toBe(100)
            expect(particle.position.x).toBe(@emitter.point.x)
            expect(particle.position.y).toBe(@emitter.point.y)

            n++
            break if n > max

      describe 'its nextTime method called in a loop', ->
        it 'should provides stepped time', ->
          e = @emission
          n = 0
          max = 100
          while e.hasNext()
            time = e.nextTime()
            expect(time)
            .toBe(e.currentTime - e.iterator / e.currentCount * e.currentTime)

            e.next()
            n++
            break if n > max
