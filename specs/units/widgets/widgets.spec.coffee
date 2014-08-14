if document?
  describe 'agt.widgets', ->
    [spy, widget, element] = []

    fixture '''
      <div class='dummy'>
      </div>
    '''

    beforeEach ->
      spy = jasmine.createSpy('widget')
      element = @fixture.querySelector('div')
      agt.widgets.define 'dummy', spy

    afterEach ->
      agt.widgets.reset()

    describe 'without any conditions', ->
      beforeEach ->
        agt.widgets 'dummy', '.dummy', on: 'custom:event'

        document.dispatchEvent(agt.domEvent 'custom:event')

        widget = agt.widgets.widgetsFor(element, 'dummy')

      it 'calls the widget method', ->
        expect(spy).toHaveBeenCalled()
        expect(spy.calls.first().args[0]).toBe(element)
        expect(spy.calls.first().object).toBe(widget)

      it 'activates the widget object', ->
        expect(widget.active).toBeTruthy()

    describe 'with a if condition', ->
      describe 'that return true', ->
        beforeEach ->
          agt.widgets 'dummy', '.dummy', on: 'custom:event', if: -> true

          document.dispatchEvent(agt.domEvent 'custom:event')

        it 'calls the widget handler', ->
          expect(spy).toHaveBeenCalled()

      describe 'that return false', ->
        beforeEach ->
          agt.widgets 'dummy', '.dummy', on: 'custom:event', if: -> false
          document.dispatchEvent(agt.domEvent 'custom:event')

        it 'does not call the widget handler', ->
          expect(spy).not.toHaveBeenCalled()

    describe 'with a unless condition', ->
      describe 'that return true', ->
        beforeEach ->
          agt.widgets 'dummy', '.dummy', on: 'custom:event', unless: -> true

          document.dispatchEvent(agt.domEvent 'custom:event')

        it 'does not call the widget handler', ->
          expect(spy).not.toHaveBeenCalled()

      describe 'that return false', ->
        beforeEach ->
          agt.widgets 'dummy', '.dummy', on: 'custom:event', unless: -> false
          document.dispatchEvent(agt.domEvent 'custom:event')

        it 'calls the widget handler', ->
          expect(spy).toHaveBeenCalled()
