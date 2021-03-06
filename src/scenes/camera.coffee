
Rectangle = require '../geom/rectangle'
Range = require '../geom/range'
Emitter = require '../mixins/emitter' 
module.exports =
class Camera
  @include Emitter

  constructor: (@screen=new Rectangle(0, 0, window.innerWidth, window.innerHeight),
                @_zoom=1,
                @zoomRange=new Range(-Infinity, Infinity),
                @silent=false) ->
    @_width = @screen.width
    @_height = @screen.height


  @accessor 'x',
    get: -> @screen.center().x
    set: (value) ->
      return if value is @x
      @screen.setCenter(value, @y)
      @fireCameraChange()

  @accessor 'y',
    get: -> @screen.center().y
    set: (value) ->
      return if value is @y
      @screen.setCenter(@x, value)
      @fireCameraChange()

  @accessor 'width',
    get: -> @_width
    set: (value) ->
      return if value is @_width
      @_width = value
      @updateZoom()

  @accessor 'height',
    get: -> @_height
    set: (value) ->
      return if value is @_height
      @_height = value
      @updateZoom()

  @accessor 'rotation',
    get: -> @screen.rotation
    set: (value) ->
      @screen.rotateAroundCenter(rotation - @screen.rotation)
      @fireCameraChange()

  @accessor 'zoom',
    get: -> @_zoom
    set: (value) ->
      if @zoomRange.surround(value)
        @_zoom = value
        @updateZoom()

  center: (x,y) ->
    {x,y} = agt.geom.Point.pointFrom(x,y)

    x = @x unless x?
    y = @y unless y?

    if x isnt @x or y isnt @y
      @screen.setCenter(x, y)
      @fireCameraChange()

  update: (props={}) ->
    @inBatch = true
    changed = false
    for key, value of props
      @[key] = value
      changed ||= true

    @dispatch('changed', this) if changed
    @inBatch = false

  updateZoom: ->
    center = @screen.center()
    @screen.width = @_width * @_zoom
    @screen.height = @_height * @_zoom
    @screen.setCenter(center)
    @fireCameraChange()

  fireCameraChange: -> @dispatch('changed', this) unless @inBatch
