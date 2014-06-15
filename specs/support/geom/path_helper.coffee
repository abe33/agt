
global.lengthOf = (source) ->
  shouldBe: (length) ->
    it "has a length of #{length}", ->
      expect(@[source].length()).toBeClose(length)
