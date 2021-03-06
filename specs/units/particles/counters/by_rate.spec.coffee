ByRate = agt.particles.counters.ByRate

describe 'ByRate', ->
  source = 'counter'
  describe 'when instanciated with a rate', ->
    beforeEach -> @counter = new ByRate 10

    counter(source).count.shouldBe(0)

    byRateCounter(source).rate.shouldBe(10)
    byRateCounter(source).rest.shouldBe(0)

    describe 'when its prepare method is called', ->
      beforeEach -> @counter.prepare 510, 0.51, 510

      counter(source).count.shouldBe(6)
      byRateCounter(source).rest.shouldBe(0.1)
