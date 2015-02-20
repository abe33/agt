Point = require '../../geom/point'

# Public:
module.exports =
class Ponctual

  ### Public ###

  constructor: (@point=new Point) ->

  get: -> @point.clone()
