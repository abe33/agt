# Public: The router class allow to trigger view changes on url changes.
# Typically the url changes may be handled by the history API or a url hash
# handler.
# The routes the router will support are defined in the callback passed to
# the router constructor as in the example below:
#
# ```coffee
# router = new Router ->
#   @match '/posts', ->
#     # render the post index
#
#   @match '/posts/:id', ({id}) ->
#     # render a single post identified with an :id
# ```
#
# 
class agt.net.Router
  @extend agt.mixins.Aliasable

  constructor: (block) ->
    @routes = {}
    @beforeFilters = []
    @afterFilters = []

    block.call(this)
    @buildRoutesHandlers()

  match: (path, options={}, handle) ->
    [options, handle] = [{}, options] if typeof options is 'function'
    path = path.replace /^\/|\/$/g, ''
    @routes[path] = {handle, options}

  @alias 'match', 'get'

  beforeFilter: (filter) -> @beforeFilters.push filter

  afterFilter: (filter) -> @afterFilters.push filter

  notFound: (@notFoundHandle) ->

  goto: (path) ->
    path = '/' if path is '.'
    path = path.replace(/^\./, '')
    path = path.replace(/\/$/, '') unless path is '/'
    path = "/#{path}" if path.indexOf('/') isnt 0

    handler = @findRoute(path)

    @beforeFilters.forEach (filter) => filter(path, this)

    if handler?
      handler(path)
    else
      @notFoundHandle?({path})

    $(document).trigger('page:change') if document?

    @afterFilters.forEach (filter) => filter(path, this)

  findRoute: (path) ->
    for k, {test, handle} of @routes
      return handle if test(path)

  buildRoutesHandlers: ->
    for path, data of @routes
      @routes[path] = @buildRouteHandler(path, data)

  buildRouteHandler: (path, {handle, options}) ->
    pathArray = path.split '/'
    pathRe = []
    pathParams = []

    for part in pathArray
      params_re = /^:(.+)$/
      if res = params_re.exec(part)
        param_name = res[1]
        pathRe.push options[param_name] ? '([^/]+)'
        pathParams.push param_name
      else
        pathRe.push part

    re = new RegExp('^/' + pathRe.join('/') + '$')

    {
      options
      test: (path) -> re.test(path)
      handle: (path) ->
        params = {path: path}
        res = re.exec(path)
        if res? and res.length > 1
          for pname,i in pathParams
            params[pname] = decodeURI(res[i+1])

        handle(params)
    }
