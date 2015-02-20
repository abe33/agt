Point = require './point'
Triangle = require './triangle'

module.exports =
class VerticalTriangleGrid
  constructor: (@triangleSize=10) ->
    @halfSize = @triangleSize / 2
    @columnWidth = Math.sqrt(3) / 2 * @triangleSize
    @trianglesCache = {}

  gridSizeForScreen: (width, height) ->
    width: Math.ceil(width / @columnWidth * 2)
    height: Math.ceil(height / @triangleSize)

  gridToScreen: (pos) -> @triangleAtPosition(pos).center()

  screenToGrid: ({x,y}) ->
    quandrantWidth = @columnWidth * 2
    quadrantHeight = @triangleSize

    inQuadrantX = x % quandrantWidth
    inQuadrantY = y % quadrantHeight

    quadrantX = Math.floor(x / quandrantWidth)
    quadrantY = Math.floor(y / quadrantHeight)

    if inQuadrantY <= @halfSize
      if inQuadrantX <= @columnWidth
        # upper left quadrant
        tri = new Triangle(
          {y: 0, x: 0},
          {y: @halfSize, x: 0}
          {y: 0, x: @columnWidth}
        )

        if tri.contains(inQuadrantX, inQuadrantY)
          {y: quadrantY, x: quadrantX * 4}
        else
          {y: quadrantY, x: quadrantX * 4 + 1}
      else
        # lower left quadrant
        tri = new Triangle(
          {y: 0, x: @columnWidth},
          {y: 0, x: quandrantWidth}
          {y: @halfSize, x: quandrantWidth}
        )

        if tri.contains(inQuadrantX, inQuadrantY)
          {y: quadrantY, x: quadrantX * 4 + 3}
        else
          {y: quadrantY, x: quadrantX * 4 + 2}
    else
      if inQuadrantX <= @columnWidth
        # upper right quadrant
        tri = new Triangle(
          {y: @halfSize, x: 0},
          {y: quadrantHeight, x: 0}
          {y: quadrantHeight, x: @columnWidth}
        )

        if tri.contains(inQuadrantX, inQuadrantY)
          {y: quadrantY + 1, x: quadrantX * 4}
        else
          {y: quadrantY, x: quadrantX * 4 + 1}
      else
        # lower right quadrant
        tri = new Triangle(
          {y: quadrantHeight, x: @columnWidth},
          {y: quadrantHeight, x: quandrantWidth}
          {y: @halfSize, x: quandrantWidth}
        )

        if tri.contains(inQuadrantX, inQuadrantY)
          {y: quadrantY + 1, x: quadrantX * 4 + 3}
        else
          {y: quadrantY, x: quadrantX * 4 + 2}


  neighbourCoordinates: (pos) ->
    neighbours = @distantNeighbourCoordinates(pos)
    direct = @directNeighbourCoordinates(pos)
    neighbours = neighbours.concat direct
    for d in direct
      neighbours = neighbours.concat @directNeighbourCoordinates(d).filter (p) =>
        not @compareCoordinates(pos, p)

    neighbours

  distantNeighbourCoordinates: (pos) ->
    xStep = pos.x % 4
    xStep = 3 + xStep if xStep < 0

    switch xStep
      when 0
        [
          {y: pos.y, x: pos.x + 3}
          {y: pos.y + 1, x: pos.x - 1}
          {y: pos.y - 1, x: pos.x - 1}
        ]
      when 1
        [
          {y: pos.y, x: pos.x - 3}
          {y: pos.y + 1, x: pos.x + 1}
          {y: pos.y - 1, x: pos.x + 1}
        ]
      when 2
        [
          {y: pos.y, x: pos.x + 3}
          {y: pos.y + 1, x: pos.x - 1}
          {y: pos.y - 1, x: pos.x - 1}
        ]
      when 3
        [
          {y: pos.y, x: pos.x - 3}
          {y: pos.y - 1, x: pos.x + 1}
          {y: pos.y + 1, x: pos.x + 1}
        ]

  directNeighbourCoordinates: (pos) ->
    xStep = pos.x % 4
    xStep = 3 + xStep if xStep < 0

    switch xStep
      when 0
        [
          {y: pos.y, x: pos.x - 1}
          {y: pos.y - 1, x: pos.x + 1}
          {y: pos.y, x: pos.x + 1}
        ]
      when 1
        [
          {y: pos.y, x: pos.x - 1}
          {y: pos.y + 1, x: pos.x - 1}
          {y: pos.y, x: pos.x + 1}
        ]
      when 2
        [
          {y: pos.y, x: pos.x - 1}
          {y: pos.y + 1, x: pos.x + 1}
          {y: pos.y, x: pos.x + 1}
        ]
      when 3
        [
          {y: pos.y, x: pos.x - 1}
          {y: pos.y - 1, x: pos.x - 1}
          {y: pos.y, x: pos.x + 1}
        ]

  compareCoordinates: (a,b) -> a.x is b.x and a.y is b.y

  triangleAtPosition: (pos) ->
    key = "#{pos.x};#{pos.y}"
    return @trianglesCache[key] if @trianglesCache[key]?

    [a,b,c] = []
    xStep = pos.x % 4
    xStep = 3 + xStep if xStep < 0

    switch xStep
      when 0
        xRef = (pos.x / 2) * @columnWidth
        yRef = pos.y * @triangleSize
        a = new Point(xRef + @columnWidth, yRef)
        b = new Point(xRef, yRef + @halfSize)
        c = new Point(xRef, yRef - @halfSize)
      when 1
        yRef = pos.y * @triangleSize + @halfSize
        xRef = (pos.x - 1) / 2 * @columnWidth
        a = new Point(xRef, yRef)
        b = new Point(xRef + @columnWidth, yRef + @halfSize)
        c = new Point(xRef + @columnWidth, yRef - @halfSize)
      when 2
        yRef = pos.y * @triangleSize + @halfSize
        xRef = pos.x / 2 * @columnWidth
        a = new Point(xRef + @columnWidth, yRef)
        b = new Point(xRef, yRef + @halfSize)
        c = new Point(xRef, yRef - @halfSize)
      when 3
        yRef = pos.y * @triangleSize
        xRef = (pos.x - 1) / 2 * @columnWidth
        a = new Point(xRef, yRef)
        b = new Point(xRef + @columnWidth, yRef + @halfSize)
        c = new Point(xRef + @columnWidth, yRef - @halfSize)

    @trianglesCache[key] = new Triangle(a,b,c)
