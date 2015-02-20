# Public: Provides class methods to deal with aliased methods and properties.
#
# ```coffeescript
# class Dummy
#   @extend agt.mixins.Aliasable
#
#   someMethod: ->
#   @alias 'someMethod', 'someMethodAlias'
# ```
module.exports =
class Aliasable

  # Public: Creates aliases for the given `source` property of tthe current
  # class prototype. Any number of alias can be passed at once.
  #
  # source - The {String} name of the aliased property
  # aliases - A list of {String}s to use as aliases.
  @alias: (source, aliases...) ->
    desc = Object.getPropertyDescriptor @prototype, source

    if desc?
      Object.defineProperty @prototype, alias, desc for alias in aliases
    else
      if @prototype[ source ]?
        @prototype[ alias ] = @prototype[ source ] for alias in aliases
