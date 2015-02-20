
testCollectionInterface = (length, content) ->
  it "returns a collection with #{length} elements", ->
    collection = if typeof content is 'function'
      content.call(this)
    else
      @[content]

    expect(@collection.constructor).toEqual(@collection.model.Collection)

    expect(@collection.length).toEqual(collection.length)
    @collection.forEach (item,i) ->
      expect(item).toEqual(collection[i])

describe 'agt.mixins.Collectionable', ->
  [instances, Dummy] = []

  beforeEach ->
    class Dummy
      @concern agt.mixins.Collectionable

      @scope 'minor', (item) -> item.age < 18
      @scope 'major', (item) -> item.age >= 18

      constructor: ({@name, @age}) -> @constructor.register(this)

    @instances = [
      new Dummy name: 'a', age: 4
      new Dummy name: 'b', age: 8
      new Dummy name: 'c', age: 18
    ]

  afterEach ->
    Dummy.initialized = false

  describe '.all', ->
    beforeEach ->
      @collection = Dummy.all()

    testCollectionInterface(3, 'instances')

  describe '.minor', ->
    beforeEach ->
      @collection = Dummy.minor()

    testCollectionInterface 2, -> @instances[0..1]

  describe '.major', ->
    beforeEach ->
      @collection = Dummy.major()

    testCollectionInterface 1, -> @instances[2..]

  describe '.where', ->
    beforeEach ->
      @collection = Dummy.where(name: 'b')

    testCollectionInterface 1, -> [@instances[1]]

  describe '.find', ->
    it 'returns the found instance', ->
      expect(Dummy.find(2)).toEqual(@instances[1])

  describe '.sum', ->
    it 'returns the sum of all the values of the specified field from all models', ->
      expect(Dummy.sum('age')).toEqual(30)

  describe '.distinct', ->
    it 'returns an array with the field values', ->
      expect(Dummy.distinct('age')).toEqual([4,8,18])

  describe '.group', ->
    it 'returns all instances grouped by the value of the specified field', ->
      grouped = Dummy.group('age')

      expect(Object.keys(grouped)).toEqual(['4','8','18'])

      expect(grouped[4].length).toEqual(1)
      expect(grouped[4].get(0)).toBe(@instances[0])

      expect(grouped[8].length).toEqual(1)
      expect(grouped[8].get(0)).toBe(@instances[1])

      expect(grouped[18].length).toEqual(1)
      expect(grouped[18].get(0)).toBe(@instances[2])

  describe '.unregisterAll', ->
    it 'removes all instances from the collectionable class', ->
      Dummy.unregisterAll()
      expect(Dummy.all().length).toEqual(0)

  describe "'s collection", ->
    beforeEach ->
      @collection = Dummy.minor()

    describe '::sum', ->
      it 'returns the sum of all the values of the specified field', ->
        expect(@collection.sum('age')).toEqual(12)

    describe '::distinct', ->
      it 'returns an array with the field values', ->
        expect(@collection.distinct('age')).toEqual([4,8])

    describe '::group', ->
      it 'returns an object where records are grouped by the value of the specified field', ->
        grouped = @collection.group('age')

        expect(Object.keys(grouped)).toEqual(['4','8'])

        expect(grouped[4].length).toEqual(1)
        expect(grouped[4].get(0)).toBe(@instances[0])

        expect(grouped[8].length).toEqual(1)
        expect(grouped[8].get(0)).toBe(@instances[1])

    it 'has the scopes defined on the model class', ->
      collection = Dummy.all()
      sub_collection = collection.minor()

      expect(sub_collection.length).toEqual(2)

      sub_collection = collection.major()

      expect(sub_collection.length).toEqual(1)
