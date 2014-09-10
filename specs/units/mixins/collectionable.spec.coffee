
testCollectionInterface = (length, content) ->
  it "returns a collection with #{length} elements", ->
    collection = if typeof content is 'function'
      content.call(this)
    else
      @[content]

    expect(@collection.length).toEqual(collection.length)
    @collection.forEach (item,i) ->
      expect(item).toEqual(collection[i])

describe 'agt.mixins.Collectionable', ->
  [instances] = []

  beforeEach ->
    class @Collectionable
      @concern agt.mixins.Collectionable

      @scope 'minor', (item) -> item.age < 18
      @scope 'major', (item) -> item.age >= 18

      constructor: ({@name, @age}) ->
        @constructor.register(this)

    @instances = [
      new @Collectionable name: 'a', age: 4
      new @Collectionable name: 'b', age: 8
      new @Collectionable name: 'c', age: 18
    ]

  afterEach ->
    @Collectionable.initialized = false

  describe '.all', ->
    beforeEach ->
      @collection = @Collectionable.all()

    testCollectionInterface(3, 'instances')

  describe '.minor', ->
    beforeEach ->
      @collection = @Collectionable.minor()

    testCollectionInterface 2, -> @instances[0..1]

  describe '.major', ->
    beforeEach ->
      @collection = @Collectionable.major()

    testCollectionInterface 1, -> @instances[2..]

  describe '.where', ->
    beforeEach ->
      @collection = @Collectionable.where(name: 'b')

    testCollectionInterface 1, -> [@instances[1]]

  describe '.find', ->
    it 'returns the found instance', ->
      expect(@Collectionable.find(2)).toEqual(@instances[1])
