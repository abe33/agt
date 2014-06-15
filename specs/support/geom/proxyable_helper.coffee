
global.proxyable = (source) ->
  shouldDefine: (methods) ->
    asProxyable: ->
      eachPair methods, (method, type) ->
        describe "its #{method} method", ->
          it "is proxyable as #{type}", ->
            meth = this[source][method].proxyable
            expect(meth).toBe(type)
