{round, floor} = Math

describe 'with a Random instance', ->
  beforeEach ->
    @random = new agt.random.Random new agt.random.Linear 10

    @callMethod = (method, args..., block) ->
      random = new agt.random.Random new agt.random.Linear 10
      withLoop.call this, (n) ->
        expect(random[method].apply random, args).toBe block.call this, n

  describe 'calling Random#get', ->
    it 'returns the generator value unchanged', ->
      @callMethod 'get', (n) -> (n % 11) / 10

  describe 'calling Random#random', ->

    it 'returns a value from 0 to the passed-in value', ->
      @callMethod 'random', 10, (n) -> n % 11

    it 'returns the generator value when called without value', ->
      @callMethod 'random', (n) -> (n % 11) / 10

  describe 'calling Random#intRandom', ->
    it 'returns an int from 0 to the passed-in value', ->
      @callMethod 'intRandom', 5, (n) -> round (n % 11) / 2

    it 'returns the floored generator value when called without arg', ->
      @callMethod 'intRandom', (n) -> round (n % 11) / 10

  describe 'calling Random#pad', ->
    it 'returns a value around 0', ->
      @callMethod 'pad', 10, (n) -> 5 - (n % 11)

  describe 'calling Random#intPad', ->
    it 'returns a value around 0', ->
      @callMethod 'intPad', 5, (n) -> round 2.5 - (n % 11) / 2

  describe 'calling Random#boolean', ->
    describe 'with a float between 0 or 1', ->
      it 'returns a boolean value according to the rate', ->
        @callMethod 'boolean', 0.2, (n) -> (n%11) / 10 < 0.2

    describe 'with no arguments', ->
      it 'returns a boolean with a default rate of 0.5', ->
        @callMethod 'boolean', (n) -> (n%11) / 10 < 0.5

    describe 'with values outside of the 0-1 range', ->
      it 'returns a boolean with a default rate of 0.5', ->
        @callMethod 'boolean', -1, (n) -> (n%11) / 10 < 0.5
        @callMethod 'boolean', 2, (n) -> (n%11) / 10 < 0.5

  describe 'calling Random#char', ->
    describe 'with a string as argument', ->
      it 'returns a char in the range', ->
        @callMethod 'char', 'abcdefghijk', (n) ->
          'abcdefghijk'.substr (n%11), 1

    describe 'with two strings as arguments', ->
      it 'returns a char in the range defined by the first char of each strings', ->
        @callMethod 'char', 'a', 'k', (n) ->
          'abcdefghijk'.substr (n%11), 1

    describe 'with a number as argument', ->
      it 'returns a char in the unicode range from 0 to the argument', ->
        @callMethod 'char', 10, (n) -> String.fromCharCode round (n%11)

    describe 'with two numbers as arguments', ->
      it 'returns a char in the unicode range from start to the end', ->
        @callMethod 'char', 10, 20, (n) -> String.fromCharCode round 10 +(n%11)

    describe 'with no arguments', ->
      it 'returns a char from the latin alphabet', ->
        @callMethod 'char', (n) ->
          'abcdefghijklmnopqrstuvwxyz'.substr round((n%11) / 10 * 25), 1

   describe 'calling Random#inArray', ->
    it 'returns of the value within the passed-in array', ->
      @callMethod 'inArray', [0,1,2,3,4,5], (n) -> round (n%11) / 2

    it 'returns null whe no argument is passed', ->
      @callMethod 'inArray', (n) -> null

    describe 'with an array and ratios', ->
      it 'returns a value according to the ratios', ->
        @callMethod 'inArray', [0,1], [1,3], (n) ->
          a = [0,0,0,1,1,1,1,1,1,1,1]
          a[n%11]

      it 'raises an error if the array and ratios length does not match', ->
        expect(=> @random.inArray [0,1], [0]).toThrow()

    describe 'with an array and summed ratios', ->
      it 'returns a value according to the ratios', ->
        @callMethod 'inArray', [0,1], [1,4], true, (n) ->
          a = [0,0,0,1,1,1,1,1,1,1,1]
          a[n%11]

      it 'raises an error if ratios are not ordered', ->
        expect(=> @random.inArray [0,1], [4,1], true).toThrow()

  describe 'calling Random#in', ->
    describe 'with an array as first argument', ->
      it 'returns of the value within the passed-in array', ->
        @callMethod 'in', [0,1,2,3,4,5], (n) -> round (n%11) / 2

      it 'returns null whe no argument is passed', ->
        @callMethod 'in', (n) -> null

      describe 'with a ratios array as second argument', ->
        it 'returns a value according to the ratios', ->
          @callMethod 'in', [0,1], [1,3], (n) ->
            a = [0,0,0,1,1,1,1,1,1,1,1]
            a[n%11]

        it 'raises an error if the array and ratios length does not match', ->
          expect(=> @random.in [0,1], [0]).toThrow()

      describe 'with a summed ratios array as second argument', ->
        it 'returns a value according to the ratios', ->
          @callMethod 'in', [0,1], [1,4], true, (n) ->
            a = [0,0,0,1,1,1,1,1,1,1,1]
            a[n%11]

        it 'raises an error if ratios are not ordered', ->
          expect(=> @random.in [0,1], [4,1], true).toThrow()

    describe 'with a string as first argument', ->
      it 'returns a char within the string', ->
        @callMethod 'in', 'abcdefghijk', (n) ->
          'abcdefghijk'.substr (n%11), 1

    describe 'with numbers as arguments', ->
      it 'returns a number within the range defined by the numbers', ->
        @callMethod 'in', 10, 20, (n) -> 10 + (n%11)

    describe 'with a list of arguments', ->
      it 'returns one of the arguments', ->
        @callMethod 'in', 0, 1, 2, 3, 4, 5, (n) -> round (n%11) / 2

    describe 'with a range object', ->
      it 'returns a number within the range', ->
        @callMethod 'in', min: 10, max: 20, (n) -> 10 + (n%11)

    describe 'with a range object and a step', ->
      it 'returns a number within the range rounded to the step', ->
        @callMethod 'in', min: 1, max: 2, step: 0.2, (n) ->
          a = [1, 1, 1.2, 1.2, 1.4, 1.4, 1.6, 1.6, 1.8, 1.8, 2]
          a[n%11]

  describe 'calling Random#bit', ->
    describe 'with a float between 0 or 1', ->
      it 'returns a 0 or a 1 value according to the rate', ->
        @callMethod 'bit', 0.2, (n) -> if (n%11) / 10 < 0.2 then 1 else 0

    describe 'with no arguments', ->
      it 'returns a 0 or a 1 with a default rate of 0.5', ->
        @callMethod 'bit', (n) -> if (n%11) / 10 < 0.5 then 1 else 0

    describe 'with values outside of the 0-1 range', ->
      it 'returns a 0 or a 1 with a default rate of 0.5', ->
        @callMethod 'bit', -1, (n) -> if (n%11) / 10 < 0.5 then 1 else 0
        @callMethod 'bit', 2, (n) -> if (n%11) / 10 < 0.5 then 1 else 0

  describe 'calling Random#sign', ->
    describe 'with a float between 0 or 1', ->
      it 'returns -1 or 1 value according to the rate', ->
        @callMethod 'sign', 0.2, (n) -> if (n%11) / 10 < 0.2 then 1 else -1

    describe 'with no arguments', ->
      it 'returns -1 or 1 with a default rate of 0.5', ->
        @callMethod 'sign', (n) -> if (n%11) / 10 < 0.5 then 1 else -1

    describe 'with values outside of the 0-1 range', ->
      it 'returns -1 or 1 with a default rate of 0.5', ->
        @callMethod 'sign', -1, (n) -> if (n%11) / 10 < 0.5 then 1 else -1
        @callMethod 'sign', 2, (n) -> if (n%11) / 10 < 0.5 then 1 else -1

  describe 'calling Random::sort', ->
    it 'returns a function that return either -1, 0 or 1', ->
      f = @random.sort()
      a = [ 1, 1, 1, 0, 0, 0, 0, 0, -1, -1, -1 ]
      for n in [0..20]
        expect(f n).toBe(a[n%11])
