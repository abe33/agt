
describe 'Matrix', ->
  beforeEach ->
    addMatrixMatchers this
    addPointMatchers this

  describe 'when instanciated', ->
    describe 'without arguments', ->
      it 'initializes an identity matrix', ->
        expect(matrix.identity()).toBeIdentity()

    describe 'with another matrix', ->
      it 'initializes the matrix in the same state as the arguments', ->
        m1 = matrix.transformed()
        m2 = matrix m1

        expect(m2).toBeSameMatrix(m1)

    describe 'with an object that is not a matrix', ->
      it 'throws an error', ->
        expect(-> matrix {}).toThrow()

    describe 'with null', ->
      it 'initializes an identity matrix', ->
        expect(matrix null).toBeIdentity()

  describe '::clone called', ->
    it 'returns a copy of the matrix', ->
      expect(matrix.transformed().clone()).toBeSameMatrix(matrix.transformed())

  describe '::equals called', ->
    describe 'with a matrix', ->
      describe 'equal to the current matrix', ->
        it 'returns true', ->
          expect(matrix().equals(matrix())).toBeTruthy()

      describe 'not equal to the current matrix', ->
        it 'returns false', ->
          expect(matrix().equals(matrix.transformed())).toBeFalsy()


  describe '::inverse called', ->
    beforeEach ->
      @m1 = matrix.transformed()
      @m2 = @m1.inverse()
      @m3 = matrix.inverted()
    it 'inverses the matrix transformation', ->
      expect(@m1).toBeSameMatrix(@m3)
    it 'returns this instance', ->
      expect(@m1).toBe(@m2)

  describe '::identity called', ->
    beforeEach ->
      @m1 = matrix.transformed()
      @m2 = @m1.identity()
    it 'resets the matrix to an identity matrix', ->
      expect(@m1).toBeIdentity()
    it 'returns this instance', ->
      expect(@m1).toBe(@m2)

  describe '::translate', ->
    beforeEach ->
      @matrix = matrix.transformed()
      @translated = matrix.translated()

    calledWithPoints(-2,2)
    .where
      source: 'matrix'
      method: 'translate'
    .should 'translates the matrix', (result) ->
      expect(result).toBeSameMatrix(@translated)

    describe 'without arguments', ->
      it 'does not modify the matrix', ->
        expect(matrix.identity().translate()).toBeIdentity()

  describe '::scale called', ->
    beforeEach ->
      @matrix = matrix.transformed()
      @scaled = matrix.scaled()

    calledWithPoints(0.5,2)
    .where
      source: 'matrix'
      method: 'scale'
    .should 'scales the matrix', (result) ->
      expect(result).toBeSameMatrix(@scaled)

    describe 'without arguments', ->
      it 'does not modify the matrix', ->
        expect(matrix.identity().scale()).toBeIdentity()

  describe '::rotate called', ->
    beforeEach ->
      @m1 = matrix.transformed()
      @m2 = @m1.rotate(72)
      @m3 = matrix.rotated()

    it 'rotates the matrix', ->
      expect(@m1).toBeSameMatrix(@m3)
    it 'returns this instance', ->
      expect(@m1).toBe(@m2)

    describe 'without arguments', ->
      it 'does not modify the matrix', ->
        expect(matrix.identity().rotate()).toBeIdentity()

  describe '::append called', ->
    beforeEach ->
      @m1 = matrix.transformed()
      @m2 = @m1.append(6, 5, 4, 3, 2, 1)
      @m3 = matrix.appended()

    it 'appends the matrix', ->
      expect(@m1).toBeSameMatrix(@m3)
    it 'returns this instance', ->
      expect(@m1).toBe(@m2)

    describe 'without arguments', ->
      it 'does not modify the matrix', ->
        expect(matrix.identity().append()).toBeIdentity()

    describe 'with a matrix', ->
      it 'appends the matrix', ->
        expect(matrix.transformed().append(matrix 6, 5, 4, 3, 2, 1))
          .toBeSameMatrix(matrix.appended())

  describe '::prepend called', ->
    beforeEach ->
      @m1 = matrix.transformed()
      @m2 = @m1.prepend(6, 5, 4, 3, 2, 1)
      @m3 = matrix.prepended()

    it 'prepends the matrix', ->
      expect(@m1).toBeSameMatrix(@m3)
    it 'returns this instance', ->
      expect(@m1).toBe(@m2)

    describe 'without arguments', ->
      it 'does not modify the matrix', ->
        expect(matrix.identity().prepend()).toBeIdentity()

    describe 'with a matrix', ->
      it 'prepends the matrix', ->
        expect(matrix.transformed().prepend(matrix 6, 5, 4, 3, 2, 1))
          .toBeSameMatrix(matrix.prepended())

    describe 'with an identity matrix', ->
      it 'does not modify the matrix', ->
        expect(matrix.transformed().prepend(matrix.identity()))
          .toBeSameMatrix(matrix.transformed())

  describe '::skew called', ->
    beforeEach ->
      @matrix = matrix.transformed()
      @skewed = matrix.skewed()

    calledWithPoints(-2,2)
    .where
      source: 'matrix'
      method: 'skew'
    .should 'skews the matrix', (result) ->
      expect(result).toBeSameMatrix(@skewed)

    describe 'without arguments', ->
      it 'does not modify the matrix', ->
        expect(matrix.transformed().skew())
          .toBeSameMatrix(matrix.transformed())

  describe '::transformPoint called', ->
    beforeEach ->
      @matrix = matrix()
      @matrix.scale(2,2)
      @matrix.rotate(Math.PI / 2)

    describe 'with a point', ->
      it 'returns a new point resulting of the matrix transformations', ->
        origin = point 10, 0
        transformed = @matrix.transformPoint origin
        expect(transformed).toBePoint(0, 20)

    describe 'with two numbers', ->
      it 'returns a new point resulting of the matrix transformations', ->
        transformed = @matrix.transformPoint 10, 0
        expect(transformed).toBePoint(0, 20)

    describe 'with one number', ->
      it 'throws an error', ->
        expect(=> @matrix.transformPoint 10).toThrow()

    describe 'without arguments', ->
      it 'throws an error', ->
        expect(=> @matrix.transformPoint()).toThrow()

    describe 'with an incomplete point', ->
      it 'throws an error', ->
        expect(=> @matrix.transformPoint x: 0).toThrow()
