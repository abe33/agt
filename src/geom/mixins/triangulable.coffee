# Public: 
class agt.geom.Triangulable
  @include mixins.Memoizable

  ### Public ###

  triangles: ->
    return @memoFor 'triangles' if @memoized 'triangles'

    vertices = @points()
    vertices.pop()
    indices = triangulate vertices
    triangles = []
    for i in [0..indices.length / 3 -1]
      index = i * 3
      a = vertices[indices[index]]
      b = vertices[indices[index+1]]
      c = vertices[indices[index+2]]
      triangles.push new agt.geom.Triangle a, b, c

    @memoize 'triangles', triangles

  arrayCopy = (arrayTo, arrayFrom) -> arrayTo[i] = n for n,i in arrayFrom

  pointInTriangle = (pt, v1, v2, v3) ->
    denom = (v1.y - v3.y) * (v2.x - v3.x) +
            (v2.y - v3.y) * (v3.x - v1.x)
    b1 = ((pt.y - v3.y) * (v2.x - v3.x) +
          (v2.y - v3.y) * (v3.x - pt.x)) / denom
    b2 = ((pt.y - v1.y) * (v3.x - v1.x) +
          (v3.y - v1.y) * (v1.x - pt.x)) / denom
    b3 = ((pt.y - v2.y) * (v1.x - v2.x) +
          (v1.y - v2.y) * (v2.x - pt.x)) / denom
    return false if b1 < 0 or b2 < 0 or b3 < 0
    true

  polyArea = (pts) ->
    sum = 0
    i = 0
    l = pts.length

    for i in [0..l-1]
      sum += pts[i].x * pts[(i + 1) % l].y - pts[(i + 1) % l].x * pts[i].y

    sum / 2

  triangulate = (vertices) ->
    return if vertices.length < 4

    safeGuard = 0
    maxSafeGuard = 100

    pts = vertices
    refs = (i for n,i in pts)
    ptsArea = []
    i = 0
    l = refs.length

    while i < l
      ptsArea[i] = pts[refs[i]].clone()
      ++i
    pArea = polyArea(ptsArea)
    cr = []
    nr = []
    arrayCopy cr, refs
    while cr.length > 3
      i = 0
      l = cr.length

      while i < l
        r1 = cr[i % l]
        r2 = cr[(i + 1) % l]
        r3 = cr[(i + 2) % l]
        v1 = pts[r1]
        v2 = pts[r2]
        v3 = pts[r3]
        ok = true
        j = (i + 3) % l

        while j isnt i
          ptsArea = [v1, v2, v3]
          tArea = polyArea(ptsArea)
          if (pArea < 0 and tArea > 0) or
             (pArea > 0 and tArea < 0) or
             pointInTriangle(pts[cr[j]], v1, v2, v3)
            ok = false
            break
          j = (j + 1) % l

          safeGuard += 1
          if safeGuard > maxSafeGuard
            break

        if ok
          nr.push r1, r2, r3
          cr.splice (i + 1) % l, 1
          break
        ++i
    nr.push.apply nr, cr[0..2]
    triangulated = true

    return nr
