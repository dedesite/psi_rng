
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

    gcc -Wall -O rng_server.c -o rng_server /usr/local/lib/libwebsockets.so

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

    ./rng_server

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

# Configuring a ddclient (for dynamic DNS)

As I don't have a internet provider kind enough to give me freely a static IP, I need to use some dynamic DNS service. So, we need to install a dynamic DNS client.
ddclient seams to be a good candidate except that the version in raspbian is a bit old, so it doesn't work for example with freedns, which I use cause it has the "chickenkiller.com" domain name !

So, we need to install a more recent version of ddclient.
Start by installing ddclient vie apt-get

    sudo apt-get install ddclient

To the dynDNS provider question, respond : 
    
    other

For server adress put (it's not really important):
    
    freedns.afraid.org

Then for the protocol, respond (we will change it later) : 

    dyndns

Type your login, password

For the interface enter :

    eth0

Add your subdomain name :

    psi.chickenkiller.org

The problem is that freedns use a SHA1 in it's protocol, so we also need to install the perl binding for sha1 which is not included in Raspbian. This is where CPAN comes :

    # Yes we also need to install gcc-4.7 cause apparently perl was build with it for Raspbian
    sudo apt-get install cpanminus gcc-4.7
    cpanm --sudo Digest::SHA1

Then download a more recent version of ddclient :

    # This is the last one from the official repository
    wget http://sourceforge.net/apps/trac/ddclient/export/139/trunk/ddclient
    sudo mv ddclient /usr/sbin/
    sudo chmod +x /usr/sbin/ddclient

Then edit the config file to change the protocol and use an externe site to retrieve public IP Adress:

    sudo mkdir /etc/ddclient
    # The ddclient conf place has changed
    sudo mv /etc/ddclient.conf /etc/ddclient/ddclient.conf
    sudo vim /etc/ddclient/ddclient.conf

Change "protocol=dyndns" to :

    protocol=freedns

If your behing a router, change "use=if..." line to :

    use=web, web=checkip.dyndns.com/, web-skip='IP Address'

You can also remove the server line cause it takes the default server for freedns.

And we're done! Just restart the service (don't pay attention to the $VERSION warning) :

    sudo service ddclient restart

If you want to insure it is running :

    ps auwx | grep [d]dclient


Those articles help me to find the solution :

http://people.virginia.edu/~ll2bf/docs/nix/rpi_server.html
http://gianpaj.com/post/34222308317/raspberry-pi-with-cloudflares-dynamic-dns-ddclient
http://raspberrypi.stackexchange.com/questions/1901/compiling-for-cpan-not-possible-on-raspbian