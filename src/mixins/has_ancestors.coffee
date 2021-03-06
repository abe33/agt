# Public: The `HasAncestors` mixin adds several methods to instance to deal
# with parents and ancestors.
#
# ```coffee
# class Dummy
#   @concern agt.mixins.HasAncestors through: 'parentNode'
#
#   @ancestorScope 'activeAncestors', (ancestor) -> ancestor.active
# ```
#
# options - The option {Object}:
#           :through - The {String} name of the property giving access
#           to the instance parent.
#
# Returns a {ConcreteHasAncestors} mixin.
module.exports = (options={}) ->
  through = options.through or 'parent'

  # Public: The concrete mixin as returned by the
  # [HasAncestors](../files/mixins/has_ancestors.coffee.html) generator.
  class HasAncestors

    # Public: Returns an array of all the ancestors of the current object.
    # The ancestors are ordered such as the first element is the direct
    # parent of the current object.
    #
    # Returns an {Array}
    @getter 'ancestors', ->
      ancestors = []
      parent = @[ through ]

      while parent?
        ancestors.push parent
        parent = parent[ through ]

      ancestors

    # Public: Returns an object containing the current object followed by its
    # parent and ancestors.
    @getter 'selfAndAncestors', -> [ this ].concat @ancestors

    # Public: Defines a getter property on instances named with `name` and that
    # filter the `ancestors` array with the given `block`.
    @ancestorsScope: (name, block) ->
      @getter name, -> @ancestors.filter(block, this)
