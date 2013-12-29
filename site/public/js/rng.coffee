class Rng
  constructor: (@address, @port) ->
    @socket = new WebSocket("ws://#{@address}:#{@port}", 'rng-protocol')
    @socket.binaryType = 'arraybuffer'
    @socket.onmessage = @onNumbers
    @firstTime = true

  isConnected: ->
    @socket.readyState is 1

  onNumbers: ->
    console.log "numbers" if @firstTime
    @firstTime = false
window.Rng = Rng