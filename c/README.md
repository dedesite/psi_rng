
# Installation

## Building libwebsockets

Some usefull information on how to compile and configure a project for libwebsockets can be found [here](http://martinsikora.com/libwebsockets-compiling-libraries-and-projects)

Here is what I did on my Ubuntu 11.10 & 12.10 machines and my raspberry pi :

    # I now use a fork of the libwebsockets library which seems to be more activelly developed
    # git clone git://git.warmcat.com/libwebsockets
    git clone git://github.com/davidgaleano/libwebsockets.git
    cd libwebsockets
    ./configure
    make clean
    make
    sudo make install
    sudo ln -s /usr/local/lib/libwebsockets.so /usr/lib/libwebsockets.so.0

## Building the websockets server

Then cd to the 'c' directory and specify libwebsocket location for compilation :

    gcc -Wall -O server.c -o server /usr/local/lib/libwebsockets.so

## Building the rng (Random Number Generator)

    gcc -Wall -O rng.c -o rng

Note : if you want to use the raspberry GPIO, you will have to uncomment RASPBERRY define before compiling

    //#define RASPBERRY 1


# Launch everything

## The rng
    ./rng

Or if you want to accesss the GPIO :

    sudo ./rng

## Then the server

    ./server

You should see messages that they are starting.

Now you can open a websocket on the 8080 port in your brower like this :

    var socket = new WebSocket('ws://192.168.0.142:8080', 'rng-protocol');
    //Don't forget to specify the binary type
    socket.binaryType = "arraybuffer";

To use the numbers just do something like this :

    socket.onmessage = function (message) {
      var numbers = new Uint8Array(message.data);

      for(var i = 0 ; i < numbers.length ; i++){
        //Do something with the numbers
      }
    }