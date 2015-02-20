Inflection = require './inflection'

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
#   @pastTense /^a$/i, 'eu'
#   @pastTense /^est$/i, 'fut'
#
# agt.inflector.pluralize('fr', 'coup') # 'coups'
# agt.inflector.pluralize('fr', 'hibou') # 'hiboux'
# agt.inflector.pluralize('fr', 'discours') # 'discours'
#
# agt.inflector.singularize('fr', 'hiboux') # 'hibou'
# agt.inflector.singularize('fr', 'coups') # 'coup'
# ```
module.exports =
class Inflector

  ### Public ###
  constructor: (lang, block) ->
    @config(lang, block) if lang? and block?

  # Extends or defines the inflections for a given language.
  #
  # ```coffee
  # inflector.config 'en', ->
  #   # ...
  #
  # inflector.config 'fr', ->
  #   # ...
  #
  # inflector.config 'de', ->
  #   # ...
  # ```
  #
  # As the language is passed to the `config` function, the methods available
  # inside the block doesn't require the `lang` argument as the `Inflector`
  # methods does.
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

  # Defines a pluralization inflection for the specified language.
  #
  # ```coffee
  # inflector.plural 'fr', /$/, 's'
  #
  # inflector.plural 'fr', /(eu|eau|au)$/i, '$1x'
  #
  # inflector.plural 'fr', /^(bij|caill|ch|gen|hib|jouj|p)ou$/i, '$1oux'
  # ```
  #
  # lang - The language {String} to configurate. Note that when inside
  #        a configuration block this parameter is automatically set.
  # match - The {RegExp} or the {String} that match words. When a string
  #         is passed, the created regex is equivalent to `///^#{word}$///`.
  # replace - The replacement {String}. Groups defined in the regex can be
  #           freely used.
  plural: (lang, match, replace) ->
    @default(lang, 'plural')

    inflection = new Inflection(match, replace)
    @inflections[lang].plural.push(inflection)


  # Defines a singularization inflection for the specified language.
  #
  # ```coffee
  # inflector.singlular 'fr', /s$/, ''
  #
  # inflector.singlular 'fr', /^(eu|eau|au)x$/i, '$1'
  #
  # inflector.singlular 'fr', /oux$/i, 'ou'
  # ```
  #
  # lang - The language {String} to configurate. Note that when inside
  #        a configuration block this parameter is automatically set.
  # match - The {RegExp} or the {String} that match words. When a string
  #         is passed, the created regex is equivalent to `///^#{word}$///`.
  # replace - The replacement {String}. Groups defined in the regex can be
  #           freely used.
  singular: (lang, match, replace) ->
    @default(lang, 'singular')

    inflection = new Inflection(match, replace)
    @inflections[lang].singular.push(inflection)

  # Defines an inflection for an irregular word which pluralization doesn't
  # follow the general rules such as person and people in english.
  #
  # ```coffee
  # inflector.irregular 'fr', 'ail', 'aulx'
  # inflector.irregular 'fr', 'œuil', 'yeux'
  # ```
  #
  # lang - The language {String} to configurate. Note that when inside
  #        a configuration block this parameter is automatically set.
  # singular - The singular {String} for the irregular word.
  # plural - The plural {String} for the irregular word.
  irregular: (lang, singular, plural) ->
    @default(lang, 'plural')
    @default(lang, 'singular')

    pluralInflection = new Inflection(singular, plural)
    singularInflection = new Inflection(plural, singular)
    @inflections[lang].singular.push(singularInflection)
    @inflections[lang].plural.push(pluralInflection)

  # Defines one or many uncountable words. Uncountable words have a single
  # form and are always returned as is in both {::pluralize} and {::singularize}
  # methods.
  #
  # ```coffee
  # inflector.uncountable 'fr', ['discours', 'secours']
  #
  # inflector.config 'fr', ->
  #   @uncountable 'discours', 'secours'
  # ```
  #
  # lang - The language {String} to configurate. Note that when inside
  #        a configuration block this parameter is automatically set.
  # uncountables - The {Array} of uncountable {String}. When inside
  #                a configuration block, the uncountable words must be passed
  #                as a list of {String}.
  uncountable: (lang, uncountables) ->
    @default(lang, 'uncountable')

    @inflections[lang].uncountable = @inflections[lang].uncountable.concat(uncountables)

  # Defines an inflection to convert a verb from its present form to its past
  # form.
  #
  # ```coffee
  # inflector.pastTense 'fr', /e/i, 'é'
  # inflector.pastTense 'fr', /est/i, 'était'
  # ```
  #
  # lang - The language {String} to configurate. Note that when inside
  #        a configuration block this parameter is automatically set.
  # match - The {RegExp} or the {String} that match words. When a string
  #         is passed, the created regex is equivalent to `///^#{word}$///`.
  # replace - The replacement {String}. Groups defined in the regex can be
  #           freely used.
  pastTense: (lang, match, replace) ->
    @default(lang, 'past')

    inflection = new Inflection(match, replace)
    @inflections[lang].past.push(inflection)

  # Conversion Methods

  # Returns the passed-in {String} in its pluralized form.
  #
  # string - The {String} to pluralize.
  # lang - The language {String} to use.
  #
  # Returns a {String}.
  pluralize: (string, lang='en') -> @inflect('plural', string, lang)

  # Returns the passed-in {String} in its singularized form.
  #
  # string - The {String} to singularize.
  # lang - The language {String} to use.
  #
  # Returns a {String}.
  singularize: (string, lang='en') -> @inflect('singular', string, lang)

  # Returns the passed-in {String} in its past form.
  #
  # string - The {String} to conjugate to the past.
  # lang - The language {String} to use.
  #
  # Returns a {String}.
  toPast: (string, lang='en') -> @inflect('past', string, lang)

  ### Internal ###

  # Realizes the inflection for the passed-in string based on the specified
  # conversion mode.
  #
  # conversion - The {String} kind of conversion to apply.
  # string - The {String} to convert.
  # lang - The language {String} to use.
  #
  # Returns a {String}.
  inflect: (conversion, string, lang='en') ->
    result = string
    return result if string is '' or string in @inflections[lang].uncountable

    inflections = @inflections[lang][conversion]

    return result if not inflections? or inflections.length is 0

    reversed = []
    reversed.unshift(o) for o in inflections

    reversed.some (inflection) ->
      res = inflection.inflect(string)
      result = res if res?
      res

    result

  # Defines a new collection on the `inflections` object for the specified
  # `lang`.
  #
  # lang - The target language {String}.
  # collection - The {String} name of the collection to create.
  default: (lang, collection)->
    @inflections ||= {}
    @inflections[lang] ||= {}
    @inflections[lang][collection] ||= []
