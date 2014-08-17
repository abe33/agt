namespace('agt.mixins')
# Public: A `Formattable` object provides a `toString` that return
# a string representation of the current instance.
#
# ```coffeescript
# class Dummy
#   @include agt.mixins.Formattable('Dummy', 'p1', 'p2')
#
#   constructor: (@p1, @p2) ->
#     # ...
#
# dummy = new Dummy(10, 'foo')
# dummy.toString()
# # [Dummy(p1=10, p2=foo)]
# ```
#
# You may wonder why the class name is passed in the `Formattable`
# call, the reason is that javascript minification can alter the
# naming of the functions and in that case, the constructor function
# name can't be relied on anymore.
# Passing the class name will ensure that the initial class name
# is always accessible through an instance.
#
# classname - The {String} name of the class for which generate a mixin.
# properties - A list of {String} of the properties to include
#              in the formatted output.
#
# Returns a {ConcreteFormattable} mixin.
agt.mixins.Formattable = (classname, properties...) ->
  # Public: The concrete class as returned by the
  # [Formattable](../files/mixins/formattable.coffee.html) generator.
  class ConcreteFormattable
    ### Public ###

    # Returns the object representation as a {String}.
    # By default the object representation looks like `[ClassName]`.
    # If the mixin was configurated using at least on property the
    # object representation will now looks like
    # `[ClassName(property=value)]`
    #
    # Returns a {String}.
    toString: -> "[#{ classname }]"

    if properties.length > 0
      @::toString = ->
        formattedProperties = ("#{ p }=#{ @[ p ] }" for p in properties)
        "[#{ classname }(#{ formattedProperties.join ', ' })]"

    # Returns the class name {String} of this instance.
    #
    # Returns a {String}
    classname: -> classname
