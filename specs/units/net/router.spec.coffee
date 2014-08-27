describe 'Router', ->
  [router, spyPosts, spyPost, spyComments, spyComment, spy404, beforeSpy, afterSpy] = []
  beforeEach ->
    router = new agt.net.Router ->
      @beforeFilter beforeSpy = jasmine.createSpy('beforeSpy')
      @afterFilter afterSpy = jasmine.createSpy('afterSpy')
      @match '/posts', spyPosts = jasmine.createSpy('spyPosts')
      @match '/posts/:id', spyPost = jasmine.createSpy('spyPost')
      @match '/posts/:post_id/comments', spyComments = jasmine.createSpy('spyComments')
      @match '/posts/:post_id/comments/:id', spyComment = jasmine.createSpy('spyComment')
      @notFound spy404 = jasmine.createSpy('404')

  it 'calls posts with /posts', ->
    router.goto '/posts'
    expect(spyPosts).toHaveBeenCalled()

  it 'calls post with /posts/4', ->
    router.goto '/posts/4'
    expect(beforeSpy).toHaveBeenCalled()
    expect(afterSpy).toHaveBeenCalled()
    expect(spyPost).toHaveBeenCalled()
    expect(spyPost.calls.argsFor(0)[0]).toEqual({id: '4', path: '/posts/4'})

  it 'calls comments with /posts/4/comments', ->
    router.goto '/posts/4/comments'
    expect(beforeSpy).toHaveBeenCalled()
    expect(afterSpy).toHaveBeenCalled()
    expect(spyComments).toHaveBeenCalled()
    expect(spyComments.calls.argsFor(0)[0]).toEqual({post_id: '4', path: '/posts/4/comments'})

  it 'calls comment with /posts/4/comments/12', ->
    router.goto '/posts/4/comments/12'
    expect(beforeSpy).toHaveBeenCalled()
    expect(afterSpy).toHaveBeenCalled()
    expect(spyComment).toHaveBeenCalled()
    expect(spyComment.calls.argsFor(0)[0]).toEqual({post_id: '4', path: '/posts/4/comments/12', id: '12'})

  it 'calls the not found handler with /foo', ->
    router.goto '/foo'
    expect(beforeSpy).toHaveBeenCalled()
    expect(afterSpy).toHaveBeenCalled()
    expect(spy404).toHaveBeenCalled()
    expect(spy404.calls.argsFor(0)[0]).toEqual({path: '/foo'})

  it 'calls the not found handler with /posts/4/foo', ->
    router.goto '/posts/4/foo'
    expect(beforeSpy).toHaveBeenCalled()
    expect(afterSpy).toHaveBeenCalled()
    expect(spy404).toHaveBeenCalled()
    expect(spy404.calls.argsFor(0)[0]).toEqual({path: '/posts/4/foo'})

  # Browser-only tests
  if document?
    it 'dispatch a route:changed event', ->
      spy = jasmine.createSpy('routeChanged')
      document.addEventListener('route:changed', spy)

      router.goto '/posts'
      expect(spy).toHaveBeenCalled()
      expect(spy.calls.argsFor(0)[0].data).toEqual(path: '/posts')
