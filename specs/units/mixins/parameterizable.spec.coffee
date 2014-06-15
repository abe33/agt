
describe 'agt.mixins.Parameterizable', ->
  beforeEach ->
    class TestClass
      @include agt.mixins.Parameterizable('instanceFrom', {
        x: 0
        y: 0
        name: 'Untitled'
      })

      constructor: (@x,@y,@name) ->

    class PartialTestClass
      @include agt.mixins.Parameterizable('instanceFrom', {
        x: 0
        y: 0
        name: 'Untitled'
      }, true)

      constructor: (@x,@y,@name) ->

    @testClass = TestClass
    @partialTestClass = PartialTestClass

  it 'creates a class method for instance creation', ->
    expect(@testClass.instanceFrom).toBeDefined()
    expect(@partialTestClass.instanceFrom).toBeDefined()

    expect(@testClass.instanceFrom(1,1,'foo')).toEqual({
      x: 1
      y: 1
      name: 'foo'
    })
    expect(@testClass.instanceFrom({x: 1, y: 1, name: 'foo'})).toEqual({
      x: 1
      y: 1
      name: 'foo'
    })

  describe 'with a non-partial class', ->
    it 'falls back to the default values', ->
      instance = @testClass.instanceFrom(1)
      expect(instance).toEqual({
        x: 1
        y: 0
        name: 'Untitled'
      })

  describe 'with a partial class', ->
    it 'does not fall back to the default values', ->
      instance = @partialTestClass.instanceFrom(1)
      expect(instance).toEqual(x: 1)

  describe 'when the strict argument is true', ->
    it 'raises an exception if one argument type mismatch', ->
      expect(-> @testClass.instanceFrom(1, true)).toThrow()
