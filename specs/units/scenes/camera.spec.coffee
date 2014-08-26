describe 'agt.scenes.Camera', ->
  [camera] = []

  beforeEach ->
    addRangeMatchers(this)
    addRectangleMatchers(this)

  withWindow ->
    describe 'created without a screen', ->
      beforeEach ->
        camera = new agt.scenes.Camera

      it 'sets the screen based on the window dimensions', ->
        expect(camera.screen)
        .toBeRectangle(0, 0, window.innerWidth, window.innerHeight)

      it 'initializes the camera with the default settings', ->
        expect(camera.initialZoom).toEqual(1)
        expect(camera.zoomRange).toBeRange(-Infinity, Infinity)
        expect(camera.silent).toBeFalsy()

      it 'provides read accessors for the screen properties', ->
        expect(camera.x).toEqual(0)
        expect(camera.y).toEqual(0)
        expect(camera.width).toEqual(window.innerWidth)
        expect(camera.height).toEqual(window.innerHeight)

      it 'provides write accessors for the screen properties', ->
        camera.x = 100
        camera.y = 20
        camera.width = 200
        camera.height = 150

        expect(camera.x).toEqual(100)
        expect(camera.y).toEqual(20)
        expect(camera.width).toEqual(200)
        expect(camera.height).toEqual(150)
        expect(camera.screen).toBeRectangle(100,20,200,150)

      it 'dispatches an event when changed', ->
        signalSpy = jasmine.createSpy('signalSpy')
        camera.once 'changed', signalSpy
        camera.x = 10
        expect(signalSpy).toHaveBeenCalled()
