namespace('agt.inflector')
# Public: The `Inflector` transform words from singular to plural
# and verbs from present to past. The `agt.inflector` package is an instance
# of the `Inflector` class with default inflections for english words and verbs.
#
# ```coffeescript
# agt.inflector.config 'fr', ->
#   @plural /$/, 's'
#   @plural /^(bij|caill|ch|gen|hib|jouj|p)ou$/i, '$1oux'
#   @plural /^(b|cor|ém|gemm|soupir|trav|vant|vitr)ail$/i, 'aux'
#
#   @singular /s$/i, ''
#   @singular /oux$/i, 'ou'
#   @singular /aux$/i, 'ail'
#
#   @uncountable 'discours', 'secours', 'souris'
#
#   @pastTense /^a$/i, 'avait'
#   @pastTense /^est$/i, 'était'
#
# agt.inflector.pluralize('fr', 'coup') # 'coups'
# agt.inflector.pluralize('fr', 'hibou') # 'hiboux'
# agt.inflector.pluralize('fr', 'discours') # 'discours'
#
# agt.inflector.singularize('fr', 'hiboux') # 'hibou'
# agt.inflector.singularize('fr', 'coups') # 'coup'
# ```
class agt.inflector.Inflector

  # Public: Extends or defines the inflections for a given language.
  #
  # ```coffee
  # inflect.config 'en', ->
  #   # ...
  #
  # inflect.config 'fr', ->
  #   # ...
  #
  # inflect.config 'de', ->
  #   # ...
  # ```
  #
  # lang - The language {String} to configurate.
  # block - The configuration {Function} to call. The function is called
  #         with the inflector as the `this` object as well as the sole
  #         argument.
  config: (lang, block) ->
    scope =
      plural: (m,r) => @plural(lang,m,r)
      singular: (m,r) => @singular(lang,m,r)
      irregular: (p,s) => @irregular(lang,p,s)
      uncountable: (a...) => @uncountable(lang,a)
      pastTense: (m,r) => @pastTense(lang,m,r)

    block.call(scope, scope)

  plural: (lang, match, replace) ->
    @default(lang, 'plural')

    inflection = new agt.inflector.Inflection(match, replace)
    @inflections[lang].plural.push(inflection)

  singular: (lang, match, replace) ->
    @default(lang, 'singular')

    inflection = new agt.inflector.Inflection(match, replace)
    @inflections[lang].singular.push(inflection)

  irregular: (lang, plural, singular) ->
    @default(lang, 'plural')
    @default(lang, 'singular')

    pluralInflection = new agt.inflector.Inflection(singular, plural)
    singularInflection = new agt.inflector.Inflection(plural, singular)
    @inflections[lang].singular.push(singularInflection)
    @inflections[lang].plural.push(pluralInflection)

  uncountable: (lang, uncountables) ->
    @default(lang, 'uncountable')

    @inflections[lang].uncountable = @inflections[lang].uncountable.concat(uncountables)

  pastTense: (lang, match, replace) ->
    @default(lang, 'past')

    inflection = new agt.inflector.Inflection(match, replace)
    @inflections[lang].past.push(inflection)

  pluralize: (string, lang='en') -> @inflect('plural', string, lang)
  singularize: (string, lang='en') -> @inflect('singular', string, lang)
  toPast: (string, lang='en') -> @inflect('past', string, lang)

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
