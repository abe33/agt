# Public:
module.exports = 
class Hash
  constructor: ->
    @clear()

  clear: ->
    @keys = []
    @values = []

  set: (key, value) ->
    if @hasKey key
      index = @keys.indexOf key
      @keys[index] = key
      @values[index] = value
    else
      @keys.push key
      @values.push value

  get: (key) -> @values[ @keys.indexOf key ]

  getKey: (value) -> @keys[ @values.indexOf value ]

  hasKey: (key) -> @keys.indexOf(key) > 0

  unset: (key) ->
    index = @keys.indexOf key
    @keys.splice index, 1
    @values.splice index, 1

  each: (block) -> @values.forEach block

  eachKey: (block) -> @keys.forEach block

  eachPair: (block) -> @keys.forEach (key) => block? key, @get key
