class net.Router

  constructor: (block) ->
    @routes = {}
    @beforeFilters = []
    @afterFilters = []

    block.call(this)
    @buildRoutesHandlers()

  get: (path, options={}, handle) ->
    [options, handle] = [{}, options] if typeof options is 'function'
    path = path.replace /^\/|\/$/g, ''
    @routes[path] = {handle, options}

  beforeFilter: (filter) -> @beforeFilters.push filter
  afterFilter: (filter) -> @afterFilters.push filter

  notFound: (@notFoundHandle) ->

  goto: (route) ->
    route = route.replace(/\/$/, '') unless route is '/'
    route = route.replace(/^\./, '') unless route is '.'
    route = '/' if route is '.'
    route = "/#{route}" if route.indexOf('/') isnt 0
    
    handler = @findRoute(route)

    @beforeFilters.forEach (filter) => filter(route, this)

    if handler?
      handler(route)
    else
      @notFoundHandle?(route)

    $(document).trigger('page:change')

    @afterFilters.forEach (filter) => filter(route, this)

  findRoute: (route) ->
    for k, {test, handle} of @routes
      return handle if test(route)

  buildRoutesHandlers: ->
    for route, data of @routes
      @routes[route] = @buildRouteHandler(route, data)

  buildRouteHandler: (route, {handle, options}) ->
    pathArray = route.split '/'
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
      test: (route) -> re.test(route)
      handle: (route) ->
        params = {path: route}
        res = re.exec(route)
        if res? and res.length > 1
          for pname,i in pathParams
            params[pname] = decodeURI(res[i+1])

        handle(params)
    }
