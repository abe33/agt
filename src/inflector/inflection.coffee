class agt.inflector.Inflection
  constructor: (@match, @replace) ->
    @match = ///^#{@match}$///i if typeof @match is 'string'

  inflect: (string) ->
    string.replace(@match, @replace) if @match.test(string)
