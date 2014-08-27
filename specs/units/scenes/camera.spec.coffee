withWindow ->
  describe 'agt.scenes.Camera', ->
    [camera] = []

    beforeEach ->
      addRangeMatchers(this)
      addRectangleMatchers(this)
      addPointMatchers(this)

      camera = new agt.scenes.Camera

    afterEach ->
      camera.off()

    it 'sets the screen based on the window dimensions', ->
      expect(camera.screen)
      .toBeRectangle(0, 0, window.innerWidth, window.innerHeight)

    it 'initializes the camera with the default settings', ->
      expect(camera.zoom).toBeClose(1)
      expect(camera.zoomRange).toBeRange(-Infinity, Infinity)
      expect(camera.silent).toBeFalsy()

    it 'provides read accessors for the screen properties', ->
      expect(camera.x).toBeClose(window.innerWidth / 2)
      expect(camera.y).toBeClose(window.innerHeight / 2)
      expect(camera.width).toBeClose(window.innerWidth)
      expect(camera.height).toBeClose(window.innerHeight)

    it 'provides write accessors for the screen properties', ->
      camera.x = 100
      camera.y = 20
      camera.width = 200
      camera.height = 160

      expect(camera.x).toBeClose(100)
      expect(camera.y).toBeClose(20)
      expect(camera.width).toBeClose(200)
      expect(camera.height).toBeClose(160)
      expect(camera.screen).toBeRectangle(0,-60,200,160)

    it 'dispatches an event when changed', ->
      signalSpy = jasmine.createSpy('signalSpy')
      camera.once 'changed', signalSpy
      camera.x = 10
      expect(signalSpy).toHaveBeenCalled()

    it 'batches changes when using the update method', ->
      signalSpy = jasmine.createSpy('signalSpy')
      camera.on 'changed', signalSpy
      camera.update x: 100, y: 20, width: 200, height: 160

      expect(signalSpy).toHaveBeenCalled()
      expect(signalSpy.calls.count()).toBeClose(1)

      expect(camera.x).toBeClose(100)
      expect(camera.y).toBeClose(20)
      expect(camera.width).toBeClose(200)
      expect(camera.height).toBeClose(160)
      expect(camera.screen).toBeRectangle(0,-60,200,160)

    describe 'zooming within a zoom range', ->
      beforeEach ->
        camera.zoomRange = new agt.geom.Range(0, 2)

      it 'prevents the zoom value to go beyond the range limit', ->
        camera.zoom = -1
        expect(camera.zoom).toEqual(1)

        camera.zoom = 3
        expect(camera.zoom).toEqual(1)

      it 'scales the camera screen according to the zoom', ->
        {x, y, width, height} = camera
        camera.zoom = 2

        expect(camera.x).toBeClose(x)
        expect(camera.y).toBeClose(y)
        expect(camera.width).toBeClose(width)
        expect(camera.height).toBeClose(height)

        expect(camera.screen.width).toBeClose(width * 2)
        expect(camera.screen.height).toBeClose(height * 2)

      it 'updates the screen with the zoom on width change', ->
        camera.zoom = 2
        camera.width = 200

        expect(camera.screen.width).toBeClose(400)

    describe '::center', ->
      it 'changes the camera position with two numbers', ->
        camera.center(200, 200)

        expect(camera.x).toEqual(200)
        expect(camera.y).toEqual(200)
        expect(camera.screen.x).toEqual(200 - window.innerWidth / 2)
        expect(camera.screen.y).toEqual(200 - window.innerHeight / 2)
