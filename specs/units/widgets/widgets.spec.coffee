if document?
  describe 'agt.widgets', ->
    [spy, widget, element] = []

    fixture '''
      <div class='dummy'>
      </div>
    '''

    beforeEach ->
      spy = jasmine.createSpy('widget')

      agt.widgets.define 'dummy', spy

      agt.widgets 'dummy', '.dummy', on: 'custom:event'
    afterEach ->
      agt.widgets.reset()

      document.dispatchEvent(agt.domEvent 'custom:event')

      element = @fixture.querySelector('div')
      widget = agt.widgets.widgetsFor(element, 'dummy')

    it 'calls the widget method', ->
      expect(spy).toHaveBeenCalled()
      expect(spy.calls.first().args[0]).toBe(element)
      expect(spy.calls.first().object).toBe(widget)

    
