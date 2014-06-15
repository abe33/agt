
# Public:
class agt.particles.timers.Unlimited extends agt.particles.timers.Limited

  ### Public ###

  constructor: (since) -> super Infinity, since

  finished: -> false
