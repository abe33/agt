# Public:
class agt.geom.Intersections
  @iterators: {}
  
  ### Public: Instances Methods ###
  intersects: (geometry) ->
    return false if geometry.bounds? and not @boundsCollide geometry
    output = false
    iterator = @intersectionsIterator this, geometry
    iterator.call this, this, geometry, -> output = true

    output

  intersections: (geometry) ->
    return null if geometry.bounds? and not @boundsCollide geometry
    output = []
    iterator = @intersectionsIterator this, geometry
    iterator.call this, this, geometry, (intersection) ->
      output.push intersection
      false

    if output.length > 0 then output else null

  boundsCollide: (geometry) ->
    bounds1 = @bounds()
    bounds2 = geometry.bounds()

    not (
      bounds1.top > bounds2.bottom or
      bounds1.left > bounds2.right or
      bounds1.bottom < bounds2.top or
      bounds1.right < bounds2.left
    )

  intersectionsIterator: (geom1, geom2) ->
    c1 = if geom1.classname then geom1.classname() else ''
    c2 = if geom2.classname then geom2.classname() else ''
    iterator = null
    iterator = Intersections.iterators[c1 + c2]
    iterator ||= Intersections.iterators[c1]
    iterator ||= Intersections.iterators[c2]
    iterator || @eachIntersections

  eachIntersections: (geom1, geom2, block, providesDataInCallback=false) ->
    points1 = geom1.points()
    points2 = geom2.points()
    length1 = points1.length
    length2 = points2.length
    lastIntersection = null

    for i in [0..length1-2]
      sv1 = points1[i]
      ev1 = points1[i+1]
      dif1x = ev1.x - sv1.x
      dif1y = ev1.y - sv1.y
      dif1l = dif1x * dif1x + dif1y * dif1y

      for j in [0..length2-2]
        sv2 = points2[j]
        ev2 = points2[j+1]
        dif2x = ev2.x - sv2.x
        dif2y = ev2.y - sv2.y
        dif2l = dif2x * dif2x + dif2y * dif2y

        cross = @perCrossing sv1, {x:dif1x,y:dif1y}, sv2, {x:dif2x,y:dif2y}
        d1x = cross.x - ev1.x
        d1y = cross.y - ev1.y
        d2x = cross.x - sv1.x
        d2y = cross.y - sv1.y
        d3x = cross.x - ev2.x
        d3y = cross.y - ev2.y
        d4x = cross.x - sv2.x
        d4y = cross.y - sv2.y

        d1l = d1x * d1x + d1y * d1y
        d2l = d2x * d2x + d2y * d2y
        d3l = d3x * d3x + d3y * d3y
        d4l = d4x * d4x + d4y * d4y

        if d1l <= dif1l and
           d2l <= dif1l and
           d3l <= dif2l and
           d4l <= dif2l

          if cross.equals lastIntersection
            lastIntersection = cross
            continue

          if providesDataInCallback
            context =
              segment1: new agt.geom.Point dif1x, dif1y
              segmentIndex1: i
              segmentStart1: sv1
              segmentEnd1: ev1
              segment2: new agt.geom.Point dif2x, dif2y
              segmentIndex2: j
              segmentStart2: sv2
              segmentEnd2: ev2

          return if block.call this, cross, context
          lastIntersection = cross

  perCrossing: (start1, dir1, start2, dir2) ->
    v3bx = start2.x - start1.x
    v3by = start2.y - start1.y
    perP1 = v3bx*dir2.y - v3by*dir2.x
    perP2 = dir1.x*dir2.y - dir1.y*dir2.x

    t = perP1 / perP2

    cx = start1.x + dir1.x*t
    cy = start1.y + dir1.y*t

    new agt.geom.Point cx, cy
