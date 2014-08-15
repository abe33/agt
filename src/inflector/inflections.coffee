
agt.inflector.config 'en', ->
  @plural(/$/, 's')
  @plural(/s$/i, 's')
  @plural(/^(ax|test)is$/i, '$1es')
  @plural(/(octop|vir)us$/i, '$1i')
  @plural(/(octop|vir)i$/i, '$1i')
  @plural(/(alias|status)$/i, '$1es')
  @plural(/(bu)s$/i, '$1ses')
  @plural(/(buffal|tomat)o$/i, '$1oes')
  @plural(/([ti])um$/i, '$1a')
  @plural(/([ti])a$/i, '$1a')
  @plural(/sis$/i, 'ses')
  @plural(/(?:([^f])fe|([lr])f)$/i, '$1$2ves')
  @plural(/(hive)$/i, '$1s')
  @plural(/([^aeiouy]|qu)y$/i, '$1ies')
  @plural(/(x|ch|ss|sh)$/i, '$1es')
  @plural(/(matr|vert|ind)(?:ix|ex)$/i, '$1ices')
  @plural(/^(m|l)ouse$/i, '$1ice')
  @plural(/^(m|l)ice$/i, '$1ice')
  @plural(/^(ox)$/i, '$1en')
  @plural(/^(oxen)$/i, '$1')
  @plural(/(quiz)$/i, '$1zes')

  @singular(/s$/i, '')
  @singular(/(ss)$/i, '$1')
  @singular(/(n)ews$/i, '$1ews')
  @singular(/([ti])a$/i, '$1um')
  @singular(/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)(sis|ses)$/i, '$1sis')
  @singular(/(^analy)(sis|ses)$/i, '$1sis')
  @singular(/([^f])ves$/i, '$1fe')
  @singular(/(hive)s$/i, '$1')
  @singular(/(tive)s$/i, '$1')
  @singular(/([lr])ves$/i, '$1f')
  @singular(/([^aeiouy]|qu)ies$/i, '$1y')
  @singular(/(s)eries$/i, '$1eries')
  @singular(/(m)ovies$/i, '$1ovie')
  @singular(/(x|ch|ss|sh)es$/i, '$1')
  @singular(/^(m|l)ice$/i, '$1ouse')
  @singular(/(bus)(es)?$/i, '$1')
  @singular(/(o)es$/i, '$1')
  @singular(/(shoe)s$/i, '$1')
  @singular(/(cris|test)(is|es)$/i, '$1is')
  @singular(/^(a)x[ie]s$/i, '$1xis')
  @singular(/(octop|vir)(us|i)$/i, '$1us')
  @singular(/(alias|status)(es)?$/i, '$1')
  @singular(/^(ox)en/i, '$1')
  @singular(/(vert|ind)ices$/i, '$1ex')
  @singular(/(matr)ices$/i, '$1ix')
  @singular(/(quiz)zes$/i, '$1')
  @singular(/(database)s$/i, '$1')

  @irregular('person', 'people')
  @irregular('man', 'men')
  @irregular('child', 'children')
  @irregular('sex', 'sexes')
  @irregular('move', 'moves')
  @irregular('zombie', 'zombies')

  @uncountable('equipment', 'information', 'rice', 'money', 'species', 'series', 'fish', 'sheep', 'jeans ', 'police')

  @pastTense /^(.*)$/,'$1ed'
  @pastTense /e$/,'ed'
  @pastTense /t$/,'ted'
  @pastTense /g$/,'gged'
  @pastTense /ight$/,'ought'
  @pastTense "buy",'bought'
  @pastTense "have",'had'
  @pastTense "sell",'sold'
  @pastTense "is",'was'
  @pastTense "are",'were'
  @pastTense "teach",'taught'
  @pastTense "feel",'felt'
  @pastTense "light",'lit'
  @pastTense "find",'found'
