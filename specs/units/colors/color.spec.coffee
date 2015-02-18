
describe 'agt.colors.Color', ->
  [color] = []
  describe 'created with separated components', ->
    beforeEach ->
      color = new agt.colors.Color(255, 127, 64, 0.5)

    it 'creates the color with the provided components', ->
      expect(color.red).toEqual(255)
      expect(color.green).toEqual(127)
      expect(color.blue).toEqual(64)
      expect(color.alpha).toEqual(0.5)

  describe 'created with a hexa rgb string', ->
    beforeEach ->
      color = new agt.colors.Color('#ff6933')

    it 'creates the color with the provided components', ->
      expect(color.red).toEqual(0xff)
      expect(color.green).toEqual(0x69)
      expect(color.blue).toEqual(0x33)
      expect(color.alpha).toEqual(1)

  describe 'created with a hexa argb string', ->
    beforeEach ->
      color = new agt.colors.Color('#66ff6933')

    it 'creates the color with the provided components', ->
      expect(color.red).toEqual(0xff)
      expect(color.green).toEqual(0x69)
      expect(color.blue).toEqual(0x33)
      expect(color.alpha).toEqual(0x66 / 255)
