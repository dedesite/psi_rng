describe 'Rng', ->
  describe '#isConnected', ->
		it 'should not be connected with wrong address', ->
      rng = new Rng('fakeaddress.com', 8080)
      rng.isConnected().should.not.be.ok
    it 'should be connected with good address', (done) ->
      rng = new Rng('localhost', 8080)
      setTimeout(done, 5000)
      rng.isConnected().should.be.ok