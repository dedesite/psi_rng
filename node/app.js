var app = require('express')()
  , server = require('http').createServer(app)
  , io = require('socket.io').listen(server);
/*var SerialPort = require("serialport").SerialPort
var serialPort = new SerialPort("/dev/ttyUSB0", { baudrate : 19200 });*/

//A la place des hardware random on met du pseudo random pour commencer
function getRandomInt(min, max)
{
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

var numbers_to_send = [];
server.listen(8080);

io.set("log level", 1);
io.sockets.on('connection', function (socket) {
  //socket.emit('news', { hello: 'world' });
  console.log("Connection established");
  socket.emit('welcome', {message : "Hello"});

  //On simule la génération de 37 chiffres (c'est a peu près la vitesse du RNG actuelle) toutes les 100 milliseconds
  function send_numbers(){
    for(var i = 0 ; i < 37 ; i++){
      numbers_to_send.push(getRandomInt(0, 255));
    }
    socket.emit('serial', numbers_to_send);
    numbers_to_send = [];
    setTimeout(send_numbers, 100);
  }

  send_numbers();


  /*serialPort.on("data", function (data) {
  	//console.log("data");
  	numbers_to_send.push(data);
  	if(numbers_to_send.length >= 100){
  		socket.emit('serial', numbers_to_send);
      numbers_to_send = [];
  	}
  });*/
});