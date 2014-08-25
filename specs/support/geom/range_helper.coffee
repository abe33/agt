global.addRangeMatchers = (scope) ->
  jasmine.addMatchers
    toBeRange: ->
      compare: (actual, min=0, max=1) ->
        result = {}
        result.message = "Expect #{actual} to be a range with min=#{min} and max=#{max}"
        result.pass = actual.min is min and actual.max is max
        result
