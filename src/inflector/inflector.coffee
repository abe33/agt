class agt.inflector.Inflector

  config: (lang, block) ->
    scope =
      plural: (m,r) => @plural(lang,m,r)
      singular: (m,r) => @singular(lang,m,r)
      irregular: (p,s) => @irregular(lang,p,s)
      uncountable: (a...) => @uncountable(lang,a)

    block.call(scope, scope)

  plural: (lang, match, replace) ->
    @default(lang, 'plural')

    inflection = new agt.inflector.Inflection(match, replace)
    @inflections[lang].plural.push(inflection)

  singular: (lang, match, replace) ->
    @default(lang, 'singular')

    inflection = new agt.inflector.Inflection(match, replace)
    @inflections[lang].singular.push(inflection)

  uncountable: (lang, uncountables) ->
    @default(lang, 'uncountable')

    @inflections[lang].uncountable = @inflections[lang].uncountable.concat(uncountables)

  irregular: (lang, plural, singular) ->
    @default(lang, 'plural')
    @default(lang, 'singular')

    pluralInflection = new agt.inflector.Inflection(singular, plural)
    singularInflection = new agt.inflector.Inflection(plural, singular)
    @inflections[lang].singular.push(singularInflection)
    @inflections[lang].plural.push(pluralInflection)

  pluralize: (string, lang='en') -> @inflect('plural', string, lang)
  singularize: (string, lang='en') -> @inflect('singular', string, lang)

  inflect: (action, string, lang='en') ->
    result = string
    return result if string is '' or string in @inflections[lang].uncountable

    inflections = @inflections[lang][action]

    return result if not inflections? or inflections.length is 0

    reversed = []
    reversed.unshift(o) for o in inflections

    reversed.some (inflection) ->
      res = inflection.inflect(string)
      result = res if res?
      res

    result

  default: (lang, collection)->
    @inflections ||= {}
    @inflections[lang] ||= {}
    @inflections[lang][collection] ||= []

agt.inflector = new agt.inflector.Inflector
agt.inflector.Inflector = agt.inflector.constructor
