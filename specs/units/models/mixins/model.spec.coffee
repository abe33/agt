
testCollectionInterface = (length, content) ->
  it "returns a collection with #{length} elements", ->
    collection = if typeof content is 'function'
      content.call(this)
    else
      @[content]

    expect(@collection.length).toEqual(collection.length)
    @collection.forEach (item,i) ->
      expect(item).toEqual(collection[i])

describe 'agt.models.Model', ->
  [instances] = []

  beforeEach ->
    class @Model
      @concern agt.models.Model

      @scope 'minor', (item) -> item.age < 18
      @scope 'major', (item) -> item.age >= 18

      constructor: ({@name, @age}) ->
        @constructor.register(this)

    @instances = [
      new @Model name: 'a', age: 4
      new @Model name: 'b', age: 8
      new @Model name: 'c', age: 18
    ]

  afterEach ->
    @Model.initialized = false

  describe '.all', ->
    beforeEach ->
      @collection = @Model.all()

    testCollectionInterface(3, 'instances')

  describe '.minor', ->
    beforeEach ->
      @collection = @Model.minor()

    testCollectionInterface 2, -> @instances[0..1]

  describe '.major', ->
    beforeEach ->
      @collection = @Model.major()

    testCollectionInterface 1, -> @instances[2..]

  describe '.where', ->
    beforeEach ->
      @collection = @Model.where(name: 'b')

    testCollectionInterface 1, -> [@instances[1]]

  describe '.find', ->
    it 'returns the found instance', ->
      expect(@Model.find(2)).toEqual(@instances[1])

  
