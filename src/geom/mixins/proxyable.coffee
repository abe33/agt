# Public:
module.exports =
class Proxyable
  @included: (klass) ->
    klass.proxy = (targets..., options={}) ->
      type = options.as
      for k in targets
        klass::[k].proxyable = type
