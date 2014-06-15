
Point = agt.geom.Point

# Public:
class agt.geom.TransformationProxy
  ### Public ###
  
  @defineProxy: (key, type) ->
    switch type
      when 'PointList'
        @::[key] = ->
          points = @geometry[key].apply(@geometry, arguments)
          if @matrix?
            points.map (pt) => @matrix.transformPoint pt
          else points

      when 'Point'
        @::[key] = ->
          point = @geometry[key].apply(@geometry, arguments)
          if @matrix? then @matrix.transformPoint point else point

      when 'Angle'
        @::[key] = ->
          angle = @geometry[key].apply(@geometry, arguments)
          if @matrix?
            vec = new Point Math.cos(angle),
                            Math.sin(angle)
            @matrix.transformPoint(vec).angle()
          else angle


  constructor: (@geometry, @matrix) ->
    @proxiedMethods = @detectProxyableMethods @geometry

  proxied: -> k for k,v of @proxiedMethods

  detectProxyableMethods: (geometry) ->
    proxiedMethods = {}
    for k,v of geometry.constructor.prototype
      if v.proxyable
        proxiedMethods[k] = v.proxyable
        TransformationProxy.defineProxy k, v.proxyable
    proxiedMethods
