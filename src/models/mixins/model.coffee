namespace('agt.models')

# Creates a collection class for the given model. This class
# will be decorated with the scopes defined on the model class
# so it have to be specific to the model class.
buildCollectionClass = (model) ->

  # The Collection class behaves mostly like an array except that
  # every methods that should return an array return a collection
  # instead.
  class Collection
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
              index = target.length + index if index < 0

              target.array[index]
            else
              target[name]
      }

    @delegateArrayMethods: (methods...) ->
      methods.forEach (method) =>
        @::[method] = -> @array[method](arguments...)

    @delegateArrayReturningMethods: (methods...) ->
      methods.forEach (method) =>
        @::[method] = -> @constructor.create(@array[method](arguments...))

    @delegateArrayMethods 'push', 'pop', 'shift', 'unshift', 'length', 'forEach', 'some', 'every', 'indexOf', 'reduce', 'join'

    @delegateArrayReturningMethods 'concat', 'splice', 'slice', 'filter', 'reverse', 'sort'

    constructor: (@array=[]) ->

    first: -> @array[0]

    last: -> @array[@length - 1]

    map: (block) ->
      results = if typeof block is 'string'
        @array.map (el) -> el[block]
      else
        @array.map(block)

      new @constructor(results)

    distinct: (field) ->
      values = []

      @forEach (instance) ->
        values.push(instance[field]) unless instance[field] in values

      values

    where: (conditions={}) ->
      @filter (model) => @matchConditions(model, conditions)

    matchConditions: (model, conditions) ->
      res = true
      for k,v of conditions
        if typeof v is 'function'
          res &&= v(model[k])
        else
          res &&= model[k] is v
      res

class cm.mixins.Model

  @delegateCollectionMethods: (methods...) ->
    methods.forEach (method) => @[method] = -> @instances[method](arguments...)

  @delegateCollectionMethods 'first', 'last', 'where', 'distinct'

  ### Public ###

  # Initializes the instances collection on the model's class.
  @initializeCollection: ->
    return if @initialized

    @Collection = buildCollectionClass(this)

    @instances = @Collection.create([])
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

  ### Scopes ###

  @all: ->
    @initializeCollection()

    @instances.concat()

  @scope: (name, block) ->
    @initializeCollection()

    @Collection::[name] = (args...) ->
      @filter (instance, index) -> block([instance].concat(args)...)

    @delegateCollectionMethods name

  ### Queries ###

  @find: (id) ->
    @initializeCollection()

    @where({id}).first()

  @find_or_create: (conditions={}) ->
    @initializeCollection()

    instance = @where(conditions).first()
    return instance if instance?

    new @(conditions)
