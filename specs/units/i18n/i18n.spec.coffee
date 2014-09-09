
describe 'I18n', ->
  [locale] = []

  beforeEach ->
    locale = new agt.i18n.I18n {
      en:
        pluralize:
          0: '0 strings'
          1: '1 string'
          other: '#{count} strings'

        string_without_token: 'A String'
        string_with_token: 'A String with #{token}'
    }

  describe '::get', ->

    it 'returns the string corresponding to the passed-in scope', ->
      expect(locale.get('en', 'string_without_token')).toEqual('A String')

    it 'replaces the tokens in the string by the passed-in value', ->
      expect(locale.get('en', 'string_with_token', token: 'a token')).toEqual('A String with a token')

    it 'leaves the token when there is no value for it', ->
      expect(locale.get('en', 'string_with_token')).toEqual('A String with #{token}')

    it 'returns a humanized version of the path when not found in locales', ->
      expect(locale.get('en', 'path.to.inexistent_locale')).toEqual('Inexistent Locale')

    it 'fall backs to the default language when not specified', ->
      expect(locale.get('string_without_token')).toEqual('A String')

    it 'uses pluralization when count is passed and the target is an object', ->
      expect(locale.get('pluralize', count: 0)).toEqual('0 strings')
      expect(locale.get('pluralize', count: 1)).toEqual('1 string')
      expect(locale.get('pluralize', count: 12)).toEqual('12 strings')
