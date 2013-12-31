class Rng
  constructor: (@address, @port) ->
    @socket = new WebSocket("ws://#{@address}:#{@port}", 'rng-protocol')
    @socket.binaryType = 'arraybuffer'
    @socket.onmessage = @_onNumbers
    @randomNumbers = []
    console.log 'here'
    @numbersCb = false 

  isConnected: ->
    @socket.readyState is 1

  onNumbers: (callback) ->
    @numbersCb = callback

  _onNumbers: (message) =>
    console.log('yo', this) if @randomNumbers.length is 0
    numbers = new Uint8Array(message.data)
    @randomNumbers.push(numbers)
    @numbersCb(numbers) if @numbersCb
window.Rng = Rng