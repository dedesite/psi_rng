document.onreadystatechange = function () {
  window.connected = false;
  function start_ws(){
    window.WebSocket = window.WebSocket || window.MozWebSocket;
    //official address is : ws://psi.chickenkiller.com:8080
    //for testing locally it's (no real rng) : ws://localhost:8080
    //var address = 'ws://192.168.1.13:8080';
    var address = "ws://psi.chickenkiller.com:8080";
    if(window.location.hostname == "localhost"){
      address = "ws://192.168.1.13:8080";
      //address = "ws://localhost:8080";
    }
    var socket = new WebSocket(address, 'rng-protocol');
    window.socket = socket;
    socket.binaryType = "arraybuffer";
    var first_time = true;
    window.recieved_numbers = false;
    socket.onmessage = function (message) {
      var numbers = new Uint8Array(message.data);
      if(first_time){
        console.log("number recieved : ", numbers);
        first_time = false;
        recieved_numbers = true;
      }
      var app = Processing.getInstanceById('sketch');
      if(app != null){
        for(var i = 0 ; i < numbers.length ; i++){
          //Simulate serial event for processingjs app
          app.serialEvent(numbers[i]);
        }
      }
    }

    socket.onopen = function(){
      console.log("Connection open");
      connected = true;
    }

    socket.onclose = function(){
      console.log("disconnected");
      connected = false;
    }
  }

  function check_ws_state(){
    if(!connected){
      start_ws();
    }
    //Check each 5 seconds the state of the connection
    setTimeout(function(){check_ws_state()}, 5000);
  }
  if (document.readyState == "complete") {
    start_ws();
    setTimeout(function(){check_ws_state()}, 5000);
/*
    var viewFullScreen = document.getElementById("sketch");
    if (viewFullScreen) {
        viewFullScreen.addEventListener("click", function () {
            var docElm = document.documentElement;
            if (docElm.requestFullscreen) {
                docElm.requestFullscreen();
            }
            else if (docElm.mozRequestFullScreen) {
                docElm.mozRequestFullScreen();
            }
            else if (docElm.webkitRequestFullScreen) {
                docElm.webkitRequestFullScreen();
            }
        }, false);
    }*/
  }
}
