
describe 'agt.geom.Range', ->
  [range] = []

  beforeEach ->
    range = new agt.geom.Range 12, 67

  describe '::surround', ->
    it 'returns true when the passed-in value', ->
      expect(range.surround(45)).toBeTruthy()

    it 'returns false when the passed-in value', ->
      expect(range.surround(5)).toBeFalsy()

  describe '::middle', ->
    it 'returns the middle of the range', ->
      expect(range.middle()).toEqual(39.5)

  describe '::overlap', ->
    it 'returns true when the two ranges overlap', ->
      expect(range.overlap(new agt.geom.Range(0, 20))).toBeTruthy()

    it 'returns false when the two ranges does not overlap', ->
      expect(range.overlap(new agt.geom.Range(80, 90))).toBeFalsy()

  describe '::inside', ->
    it 'returns true when the passed-in range is inside', ->
      expect(range.inside(new agt.geom.Range(22, 57))).toBeTruthy()

    it 'returns false when the passed-in range is inside', ->
      expect(range.inside(new agt.geom.Range(0, 20))).toBeFalsy()
