{Random, NoRandom} = agt.random
Particle = agt.particles.Particle
Life = agt.particles.initializers.Life

describe 'Life', ->
  describe 'when instanciated with a life amount', ->
    beforeEach -> @initializer = new Life 100

    describe 'and its initialize method is called with a particle', ->
      beforeEach ->
        @particle = new Particle()
        @initializer.initialize @particle

      it 'should have set the max life of the particle', ->
        expect(@particle.maxLife).toBe(100)

  describe 'when instanciated with a life range', ->
    beforeEach -> @initializer = new Life 100, 200, new Random new NoRandom 0.5

    describe 'and its initialize method is called with a particle', ->
      beforeEach ->
        @particle = new Particle()
        @initializer.initialize @particle

      it 'should have set the max life of the particle within the range', ->
        expect(@particle.maxLife).toBe(150)

    describe 'when instanciated with nothing', ->
      it 'should have set a default random object', ->
        expect(new Life().random).toBeDefined()
