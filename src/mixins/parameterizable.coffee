
# Public: A `Parameterizable` object provides a class and an instance
# method to convert an arbitrary {Object} or a series of values into
# an instance of the class receiving the mixin.
#
# ```coffeescript
# class Dummy
#   @include agt.mixins.Parameterizable('dummyFrom', {
#     x: 0
#     y: 0
#     name: 'Untitled'
#   })
#
#   constructor: (@x, @y, @name) ->
#
# instance = new Dummy
#
# Dummy.instanceFrom(1,2,'foo')
# instance.instanceFrom(1,2,'foo')
# ```
#
# The methods can be used either with an object or with a list
# of values whose order is the order of the `parameters` object keys:
#
# ``` coffeescript
# Dummy.instanceFrom(1,2,'Foo') # [Dummy(x=1,y=2,name='Foo')]
# Dummy.instanceFrom(x: 1, y: 2, name: 'Foo') # [Dummy(x=1,y=2,name='Foo')]
# ```
#
# The last `instanceFrom` argument controls can be a {Boolean} of whether
# the method raises an exception when the creation arguments types mismatch:
#
# ``` coffeescript
# Dummy.instanceFrom(1,'foo','bar' true) # value for y doesn't match type number
# Dummy.instanceFrom(x: 1, y: 'foo', name: 'bar', true) # value for y doesn't match type number
# ```
#
# The only edge case is that if you have yourself defined a {Boolean} as last
# argument you'll always have to pass the `strict` argument when calling the
# methods.
#
# The `allowPartial` argument, when set to `true`, will prevent the method
# to fallback on the default values provided in the `parameters` object
# leaving the class constructor to deal with it.
#
# method - The {String} name of the method to create.
# parameters - An {Object} describing the arguments name, type and order.
# allowPartial - A {Boolean} of
agt.mixins.Parameterizable = (method, parameters, allowPartial=false) ->

  # Public: The concrete mixin as returned by the
  # [Parameterizable](../files/mixins/parameterizable.coffee.html) generator.
  class ConcreteParameterizable

    # Internal:
    @included: (klass) ->
      f = (args..., strict)->
        (args.push(strict); strict = false) if typeof strict isnt 'boolean'
        output = {}

        o = arguments[ 0 ]
        n = 0
        firstArgumentIsObject = o? and typeof o is 'object'

        for k,v of parameters
          value = if firstArgumentIsObject then o[ k ] else arguments[ n++ ]
          parameterType = typeof v

          if strict
            if typeof value is parameterType
              output[ k ] = value
            else
              if parameterType is 'number'
                value = parseFloat value

                if isNaN value
                  throw new Error "value for #{ k } doesn't match type #{ parameterType}"
                else
                  output[k] = value
              else
                throw new Error "value for #{ k } doesn't match type #{ parameterType}"

          else
            if value?
              if parameterType is 'number'
                value = parseFloat value

                if isNaN value
                  output[ k ] = v unless allowPartial
                else
                  output[ k ] = value
              else
                output[ k ] = value
            else
              output[ k ] = v unless allowPartial


        output

      klass[method] = f
      klass::[method] = f
