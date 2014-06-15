
# Internal: Contains all the function that will instanciate a class
# with a specific number of arguments. These functions are all generated
# at runtime with the `Function` constructor.
build = (klass, args) ->
  BUILDS = (
    new Function( "return new arguments[0](#{
      ("arguments[1][#{ j-1 }]" for j in [ 0..i ] when j isnt 0).join ","
    });") for i in [ 0..24 ]
  )

  f = BUILDS[ if args? then args.length else 0 ]
  f klass, args

# Public: A `Cloneable` object can return a copy of itself through its `clone`
# method.
#
# The `Cloneable` generator function produces a different mixin when called
# with or without arguments.
#
# When called without argument, the returned mixin creates a clone using
# a copy constructor (a constructor that initialize the current object
# with an object).
#
# ```coffeescript
# class Dummy
#   @include agt.mixins.Cloneable()
#
#   constructor: (options={}) ->
#     @property = options.property or 'foo'
#     @otherProperty = options.otherProperty or 'bar'
#
# instance = new Dummy
# otherInstance = instance.clone()
# # otherInstance = {property: 'foo', otherProperty: 'bar'}
# ```
#
# When called with arguments, the `clone` method will call the class
# constructor with the values extracted from the given properties.
#
# ```coffeescript
# class Dummy
#   @include agt.mixins.Cloneable('property', 'otherProperty')
#
#   constructor: (@property='foo', @otherProperty='bar') ->
#
# instance = new Dummy
# otherInstance = instance.clone()
# # otherInstance = {property: 'foo', otherProperty: 'bar'}
# ```
#
# properties - A list of {String} of the properties to pass in the constructor.
#
# Returns a {ConcreteCloneable} mixin configured with the passed-in arguments.
agt.mixins.Cloneable = (properties...) ->

  # Public: The concrete cloneable mixin as created by the
  # [Cloneable](../files/mixins/cloneable.coffee.html) generator.
  class ConcreteCloneable

    # Public: Returns a copy of this instance.
    #
    # When the mixin is configurated without any `properties` the cloned
    # instance is passed directly as argument at the creation of the new
    # instance.
    #
    # Returns an {Object}.
    clone: -> new @constructor this

    if properties.length > 0
      ConcreteCloneable::clone = -> build @constructor, properties.map (p) => @[ p ]
