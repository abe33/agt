class agt.particles.timers.Unlimited extends agt.particles.timers.Limited
  constructor: (since) -> super Infinity, since
  finished: -> false
