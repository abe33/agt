namespace('agt.models')

class agt.models.ModelsCollection

  @initializeCollection: ->
    return if @initialized

    @decorate_array = @decorate_array.bind(this)

    @instances = []
    @array_extensions =
      decorate_array: @decorate_array
      distinct: (field) ->
        values = []

        @forEach (instance) ->
          values.push(instance[field]) unless instance[field] in values

        values

    @initialized = true

  @register: (instance) ->
    @instances.push(instance)

  @unregister: (instance) ->
    @instances.splice(@instances.indexOf(instance), 1) if instance in @instances

  @all: -> @decorate_array @instances.concat()

  @scope: (name, block) ->
    @scopes ?= {}

    @[name] = (args...) ->
      @decorate_array @instances.filter (instance, index) ->
        block([instance].concat(args)...)

    @scopes[name] = (args...) ->
      @decorate_array @filter (instance, index) ->
        block([instance].concat(args)...)

  @distinct: (field) ->
    @array_extensions.distinct.call(@instances, field)

  @decorate_array: (array) ->
    array = array.concat()
    if @array_extensions?
      for k,v of @array_extensions
        array[k] = v
    if @scopes?
      for k,v of @scopes
        array[k] = v

    array
