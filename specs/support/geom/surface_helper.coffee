
global.acreageOf = (source) ->
  shouldBe: (acreage) ->
    it "has an acreage of #{acreage}", ->
      expect(@[source].acreage()).toBe(acreage)
