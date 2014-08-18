namespace('agt.inflector')

# Public: The `Inflection` class represent a single inflection for the general
# case of pluralization, singularization and conversion to the past tense.
class agt.inflector.Inflection
  ### Public ###

  # Creates a new instance.
  #
  # match - The {RegExp} or {String} to match.
  # replace - The replacement {String}.
  constructor: (@match, @replace) ->
    @match = ///^#{@match}$///i if typeof @match is 'string'

  # Converts the passed-in {String} if it matches the inflection's {RegExp}.
  #
  # string - The {String} to convert.
  #
  # Returns a {String}.
  inflect: (string) ->
    string.replace(@match, @replace) if @match.test(string)
