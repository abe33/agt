namespace('agt.mixins')
class agt.mixins.Disposable
  init: ->
    @initialized?()

  dispose: ->
    @disposed?()
