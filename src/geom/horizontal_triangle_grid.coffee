namespace('agt.geom')

class agt.geom.HorizontalTriangleGrid
  constructor: (@triangleSize=10) ->
    @halfSize = @triangleSize / 2
    @rowHeight = Math.sqrt(3) / 2 * @triangleSize
    @trianglesCache = {}

  gridSizeForScreen: (width, height) ->
    width: Math.ceil(width / @triangleSize)
    height: Math.ceil(height / @rowHeight * 2)

  gridToScreen: (pos) -> @triangleAtPosition(pos).center()

  screenToGrid: ({x,y}) ->
    quadrantHeight = @rowHeight * 2
    quadrantWidth = @triangleSize

    inQuadrantX = x % quadrantWidth
    inQuadrantY = y % quadrantHeight

    quadrantX = Math.floor(x / quadrantWidth)
    quadrantY = Math.floor(y / quadrantHeight)

    if inQuadrantX <= @halfSize
      if inQuadrantY <= @rowHeight
        # upper left quadrant
        tri = new agt.geom.Triangle(
          {x: 0, y: 0},
          {x: @halfSize, y: 0}
          {x: 0, y: @rowHeight}
        )

        if tri.contains(inQuadrantX, inQuadrantY)
          {x: quadrantX, y: quadrantY * 4}
        else
          {x: quadrantX, y: quadrantY * 4 + 1}
      else
        # lower left quadrant
        tri = new agt.geom.Triangle(
          {x: 0, y: @rowHeight},
          {x: 0, y: quadrantHeight}
          {x: @halfSize, y: quadrantHeight}
        )

        if tri.contains(inQuadrantX, inQuadrantY)
          {x: quadrantX, y: quadrantY * 4 + 3}
        else
          {x: quadrantX, y: quadrantY * 4 + 2}
    else
      if inQuadrantY <= @rowHeight
        # upper right quadrant
        tri = new agt.geom.Triangle(
          {x: @halfSize, y: 0},
          {x: quadrantWidth, y: 0}
          {x: quadrantWidth, y: @rowHeight}
        )

        if tri.contains(inQuadrantX, inQuadrantY)
          {x: quadrantX + 1, y: quadrantY * 4}
        else
          {x: quadrantX, y: quadrantY * 4 + 1}
      else
        # lower right quadrant
        tri = new agt.geom.Triangle(
          {x: quadrantWidth, y: @rowHeight},
          {x: quadrantWidth, y: quadrantHeight}
          {x: @halfSize, y: quadrantHeight}
        )

        if tri.contains(inQuadrantX, inQuadrantY)
          {x: quadrantX + 1, y: quadrantY * 4 + 3}
        else
          {x: quadrantX, y: quadrantY * 4 + 2}


  neighbourCoordinates: (pos) ->
    neighbours = @distantNeighbourCoordinates(pos)
    direct = @directNeighbourCoordinates(pos)
    neighbours = neighbours.concat direct
    for d in direct
      neighbours = neighbours.concat @directNeighbourCoordinates(d).filter (p) =>
        not @compareCoordinates(pos, p)

    neighbours

  distantNeighbourCoordinates: (pos) ->
    yStep = pos.y % 4
    yStep = 3 + yStep if yStep < 0

    switch yStep
      when 0
        [
          {x: pos.x, y: pos.y + 3}
          {x: pos.x + 1, y: pos.y - 1}
          {x: pos.x - 1, y: pos.y - 1}
        ]
      when 1
        [
          {x: pos.x, y: pos.y - 3}
          {x: pos.x + 1, y: pos.y + 1}
          {x: pos.x - 1, y: pos.y + 1}
        ]
      when 2
        [
          {x: pos.x, y: pos.y + 3}
          {x: pos.x + 1, y: pos.y - 1}
          {x: pos.x - 1, y: pos.y - 1}
        ]
      when 3
        [
          {x: pos.x, y: pos.y - 3}
          {x: pos.x - 1, y: pos.y + 1}
          {x: pos.x + 1, y: pos.y + 1}
        ]

  directNeighbourCoordinates: (pos) ->
    yStep = pos.y % 4
    yStep = 3 + yStep if yStep < 0

    switch yStep
      when 0
        [
          {x: pos.x, y: pos.y - 1}
          {x: pos.x - 1, y: pos.y + 1}
          {x: pos.x, y: pos.y + 1}
        ]
      when 1
        [
          {x: pos.x, y: pos.y - 1}
          {x: pos.x + 1, y: pos.y - 1}
          {x: pos.x, y: pos.y + 1}
        ]
      when 2
        [
          {x: pos.x, y: pos.y - 1}
          {x: pos.x + 1, y: pos.y + 1}
          {x: pos.x, y: pos.y + 1}
        ]
      when 3
        [
          {x: pos.x, y: pos.y - 1}
          {x: pos.x - 1, y: pos.y - 1}
          {x: pos.x, y: pos.y + 1}
        ]

  compareCoordinates: (a,b) -> a.x is b.x and a.y is b.y

  triangleAtPosition: (pos) ->
    key = "#{pos.x};#{pos.y}"
    return @trianglesCache[key] if @trianglesCache[key]?

    [a,b,c] = []
    yStep = pos.y % 4
    yStep = 3 + yStep if yStep < 0

    switch yStep
      when 0
        xRef = pos.x * @triangleSize
        yRef = (pos.y / 2) * @rowHeight
        a = new agt.geom.Point(xRef, yRef + @rowHeight)
        b = new agt.geom.Point(xRef + @halfSize, yRef)
        c = new agt.geom.Point(xRef - @halfSize, yRef)
      when 1
        xRef = pos.x * @triangleSize + @halfSize
        yRef = (pos.y - 1) / 2 * @rowHeight
        a = new agt.geom.Point(xRef, yRef)
        b = new agt.geom.Point(xRef + @halfSize, yRef + @rowHeight)
        c = new agt.geom.Point(xRef - @halfSize, yRef + @rowHeight)
      when 2
        xRef = pos.x * @triangleSize + @halfSize
        yRef = pos.y / 2 * @rowHeight
        a = new agt.geom.Point(xRef, yRef + @rowHeight)
        b = new agt.geom.Point(xRef + @halfSize, yRef)
        c = new agt.geom.Point(xRef - @halfSize, yRef)
      when 3
        xRef = pos.x * @triangleSize
        yRef = (pos.y - 1) / 2 * @rowHeight
        a = new agt.geom.Point(xRef, yRef)
        b = new agt.geom.Point(xRef + @halfSize, yRef + @rowHeight)
        c = new agt.geom.Point(xRef - @halfSize, yRef + @rowHeight)

    @trianglesCache[key] = new agt.geom.Triangle(a,b,c)
