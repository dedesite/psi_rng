var app = require('express')()
  , server = require('http').createServer(app)
  , io = require('socket.io').listen(server);
var SerialPort = require("serialport").SerialPort
var serialPort = new SerialPort("/dev/ttyUSB0", { baudrate : 19200 });

//A la place des hardware random on met du pseudo random pour commencer
/*function getRandomInt(min, max)
{
  return Math.floor(Math.random() * (max - min + 1)) + min;
}*/

var buffer_to_send = [];
var numbers_to_send = [];
server.listen(8080);

serialPort.on("data", function (data) {
  //Don't fill the buffer if there is no connections
  if(io.sockets.clients().length > 0){
    buffer_to_send.push(data);
  }
});

io.set("log level", 1);
io.sockets.on('connection', function (socket) {
  //socket.emit('news', { hello: 'world' });
  //Limit simultaneus connected clients to 1
  if(io.sockets.clients().length == 1){
    console.log("Connection established");
    socket.emit('welcome', {message : "Hello"});

    function send_numbers(){
      for(var i = 0 ; i < buffer_to_send.length ; i++){
        for(var j = 0 ; j < buffer_to_send[i].length ; j++){
          numbers_to_send.push(buffer_to_send[i].readUInt8(j));  
        }
      }
      socket.emit('serial', numbers_to_send);
      numbers_to_send = [];
      buffer_to_send = [];
      //Don't send numbers if there is no more connections
      if(io.sockets.clients().length > 0){
        setTimeout(send_numbers, 100);  
      }
    }

    send_numbers();
  }
  else{
    console.log("Connection refused : only one client can connect at a time");
    socket.emit('refused', {message : "Too much connections"});
  }
});