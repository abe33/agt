Delegation = require './delegation'

# Public:
module.exports =
class Collectionable
  @extend Delegation

  @delegatesCollectionMethods: (methods...) ->
    methods.forEach (method) => @[method] = -> @instances[method](arguments...)

  @delegatesCollectionMethods 'first', 'last', 'where', 'distinct', 'sum', 'group'

  ### Public ###

  # Initializes the instances collection on the model's class.
  @initializeCollection: ->
    return if @initialized

    @Collection = buildCollectionClass(this)

    @instances = @Collection.create()
    @nextId = 1

    @initialized = true

  @create_collection: (content=[]) ->
    @initializeCollection()

    @Collection.create(content)

  @register: (instance) ->
    @initializeCollection()

    instance.id = @nextId++
    @instances.push(instance)

  @unregister: (instance) ->
    @instances.splice(@instances.indexOf(instance), 1) if instance in @instances

  @unregisterAll: ->
    @instances = @Collection.create()

  ### Scopes ###

  @all: ->
    @initializeCollection()

    @instances.concat()

  @scope: (name, block) ->
    @initializeCollection()

    @Collection::[name] = (args...) ->
      @filter (instance, index) -> block([instance].concat(args)...)

    @delegatesCollectionMethods name

  ### Queries ###

  @find: (id) ->
    @initializeCollection()

    @where({id}).first()

  @find_or_create: (conditions={}) ->
    @initializeCollection()

    instance = @where(conditions).first()
    return instance if instance?

    new @(conditions)

# Internal: Creates a collection class for the given model. This class
# will be decorated with the scopes defined on the model class
# so it have to be specific to the model class.
buildCollectionClass = (model) ->

  # Public: The Collection class behaves mostly like an array except that
  # every methods that should return an array return a collection
  # instead.
  class Collection
    @extend Delegation

    @model: model

    # We can't use `new Collection` because Collection's instances
    # are not proxy. Use `Collection.create` instead.
    @create: (content) ->
      collection = new @(content)
      return collection unless typeof Proxy is 'function'
      new Proxy collection, {
        get: (target, name) ->
          # Methods are simply bound to the target and returned.
          if typeof target[name] is 'function'
            target[name].bind(target)
          else
            if /-?\d+/.test(name)
              # With this we can call `collection[index]` and access the content
              # of the collection array.
              index = parseInt(name)
              target.get(index)
            else
              target[name]
      }

    @delegatesArrayMethods: (methods...) ->
      methods.forEach (method) =>
        @::[method] = -> @array[method](arguments...)

    @delegatesArrayReturningMethods: (methods...) ->
      methods.forEach (method) =>
        @::[method] = -> @constructor.create(@array[method](arguments...))

    @delegates 'length', toProperty: 'array'

    @delegatesArrayMethods 'push', 'pop', 'shift', 'unshift', 'forEach', 'some', 'every', 'indexOf', 'reduce', 'join'

    @delegatesArrayReturningMethods 'concat', 'splice', 'slice', 'filter', 'reverse', 'sort'

    model: model

    constructor: (@array=[]) ->

    get: (index) ->
      index = @length + index if index < 0
      @array[index]

    first: -> @get(0)

    last: -> @get(-1)

    where: (conditions={}) ->
      @filter (model) => @matchConditions(model, conditions)

    map: (block) ->
      if typeof block is 'string'
        @distinct(block)
      else
        @array.map(block)

    sum: (field) -> @reduce ((a,b) -> a + b[field]), 0

    group: (key) ->
      results = {}

      for record in @array
        slot = record[key]
        slot = slot.id if typeof slot is 'object' and slot.id?
        results[slot] ?= @constructor.create()
        results[slot].push record

      results


    distinct: (field) ->
      values = []

      @forEach (instance) ->
        values.push(instance[field]) unless instance[field] in values

      values

    matchConditions: (model, conditions) ->
      res = true
      for k,v of conditions
        if typeof v is 'function'
          res &&= v(model[k])
        else
          res &&= model[k] is v
      res
