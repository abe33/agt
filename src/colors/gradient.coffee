namespace('agt.colors')

class agt.colors.Gradient
  constructor: (@colors, @positions, @name="Unnamed gradient") ->
    if @colors.length isnt @positions.length
      throw new Error "Can't have two arrays with different length"

  getColor: (p) ->
    startIndex = @getStartIndex(p)
    endIndex = @getEndIndex(p)

    color1 = @colors[ startIndex ]
    color2 = @colors[ endIndex ]

    position1 = @positions[ startIndex ]
    position2 = @positions[ endIndex ]

    if color1? and not color2?
      color1
    else if not color1? and color2?
      color2
    else if position1 is position2
      color1
    else
      r = (p - position1) / (position2 - position1)
      color1.interpolate(color2, r)

  clone: ->
    new Gradient(@colors.map((i) -> return i.clone()), @positions.concat())

  getStartIndex: (position) ->
    position = @isValidPosition(position)
    l = @positions.length

    while l--
      if @positions[l] <= position
        return l

    0

  getEndIndex: (position) ->
    position = @isValidPosition(position)

    for value,i in @positions
      if value >= position
        return i

    @positions.length

  isValidPosition: (position) ->
    if position < 0
      0
    else if position > 1
      1
    else
      position
