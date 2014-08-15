describe 'agt.inflector.Inflector', ->
  [inflector] = []

  beforeEach ->
    inflector = new agt.inflector.Inflector
    inflector.config 'en', ->
      @plural /$/, 's'
      @plural /s$/i, 's'
      @plural /^(ax|test)is$/i, '$1es'

      @singular(/s$/i, '')
      @singular(/([^aeiouy]|qu)ies$/i, '$1y')

      @irregular 'person', 'people'

      @uncountable 'equipment'

  describe 'when configurated', ->
    it 'contains the inflections defined in the configuration block', ->
      expect(inflector.inflections.en.plural.length).toEqual(4)
      expect(inflector.inflections.en.singular.length).toEqual(3)
      expect(inflector.inflections.en.uncountable.length).toEqual(1)

    it 'creates an inflector that can pluralize', ->
      expect(inflector.pluralize('foo')).toEqual('foos')
      expect(inflector.pluralize('foos')).toEqual('foos')
      expect(inflector.pluralize('axis')).toEqual('axes')
      expect(inflector.pluralize('')).toEqual('')
      expect(inflector.pluralize('equipment')).toEqual('equipment')

    it 'creates an inflector that can singularize', ->
      expect(inflector.singularize('queries')).toEqual('query')
      expect(inflector.singularize('foos')).toEqual('foo')
      expect(inflector.singularize('')).toEqual('')
      expect(inflector.singularize('equipment')).toEqual('equipment')
