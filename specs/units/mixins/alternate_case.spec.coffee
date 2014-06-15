describe 'agt.mixins.AlternateCase', ->
  describe 'mixed in a class using camelCase', ->
    beforeEach ->
      class TestClass
        @extend agt.mixins.AlternateCase

        someProperty: true
        someMethod: ->

        @snakify()

      @instance = new TestClass

    it 'creates properties with snake case', ->
      expect(@instance.some_property).toBeDefined()
      expect(@instance.some_method).toBeDefined()

  describe 'mixed in a class using snake_case', ->
    beforeEach ->
      class TestClass
        @extend agt.mixins.AlternateCase

        some_property: true
        some_method: ->

        @camelize()

      @instance = new TestClass

    it 'creates properties with camel case', ->
      expect(@instance.some_property).toBeDefined()
      expect(@instance.someMethod).toBeDefined()
