module.exports =
class Disposable
  init: ->
    @initialized?()

  dispose: ->
    @disposed?()
