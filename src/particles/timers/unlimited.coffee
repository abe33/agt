Limited = require './limited'
# Public:
module.exports =
class Unlimited extends Limited

  ### Public ###

  constructor: (since) -> super Infinity, since

  finished: -> false
