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
class agt.net.Router
  @extend agt.mixins.Aliasable

  ### Public ###

  # Creates a new router instance. The constructor takes a {Function}
  # and call it in the constructor this the router as the context object
  # of the call. This is generally inside the block {Function} that you'll
  # define the route to support.
  #
  # block - The initialization {Function}.
  constructor: (block) ->
    @routes = {}
    @beforeFilters = []
    @afterFilters = []

    block.call(this)
    @buildRoutesHandlers()

  # Registers a route on this router.
  #
  # A route is defined with a `path` {String}, starting with a `/` and that
  # can contains variables patterns for dynamic routes.
  #
  # For instance, the following path `'/posts/:post_id/comments/:id'` sets
  # that the route defines two variables `post_id` and `id` that can contains
  # any value. It means that this route will match both `'/posts/1/comments/2'`
  # or `'/posts/foo/comments/bar'`.
  #
  # To limit the legal values for a variable, you can pass a string
  # in the option object with the name of the variable as key, such as in:
  #
  # ```coffee
  # @match '/posts/:id', id: '(\d+)', ({id}) ->
  # ```
  #
  # In the example above the route can only be matched if the content for the
  # `id` variable in the path contains only numbers. It means that
  # `'/posts/1/comments/2'` will be matched by the route but
  # `'/posts/foo/comments/bar'` won't.
  #
  # path - The path {String} to support.
  # options - An option {Object} that can contain properties matching the
  #           path variables and containing strings that will be used to
  #           construct the regexp String to test paths.
  match: (path, options={}, handle) ->
    [options, handle] = [{}, options] if typeof options is 'function'
    path = path.replace /^\/|\/$/g, ''
    @routes[path] = {handle, options}

  @alias 'match', 'get'

  # Registers a filter to be called before the route handler.
  #
  # ```coffee
  # @beforeFilter (path, router) ->
  #   # ...
  # ```
  #
  # filter - The {Function} to invoke before the route handler.
  beforeFilter: (filter) -> @beforeFilters.push filter

  # Registers a filter to be called after the route handler.
  #
  # ```coffee
  # @afterFilter (path, router) ->
  #   # ...
  # ```
  #
  # filter - The {Function} to invoke after the route handler.
  afterFilter: (filter) -> @afterFilters.push filter

  # Defines a handler for paths that doesn't match any routes.
  #
  # notFoundHandle - The {Function} to call for route not found.
  notFound: (@notFoundHandle) ->

  # Triggers a change of route with the passed-in path.
  #
  # A `route:changed` event is dispatched after all the filters and the
  # handler was called.
  #
  # path - The path {String} to match.
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

    @afterFilters.forEach (filter) => filter(path, this)

    document.dispatchEvent agt.domEvent('route:changed', {path}) if document?

  # Internal: Returns the {Function} to handle the passed-in `path`.
  #
  # path - The path {String} to match.
  #
  # Returns a {Function}.
  findRoute: (path) ->
    for k, {test, handle} of @routes
      return handle if test(path)

  # Internal: Builds the route handlers.
  buildRoutesHandlers: ->
    for path, data of @routes
      @routes[path] = @buildRouteHandler(path, data)

  # Internal: Build a single route handler using the information provided.
  #
  # path - A {String} of the route path pattern.
  # options - An object with the following properties:
  #           :handle - The {Function} that will handle the route.
  #           :options - An {Object} that contains the path variables patterns.
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
