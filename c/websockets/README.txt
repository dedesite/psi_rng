Some usefull information on how to compile and configure a project for libwebsockets can be found here :
http://martinsikora.com/libwebsockets-compiling-libraries-and-projects

What I did on my Ubuntu 11.10 machine :
#I now use a fork of the libwebsockets library which seems to be more activelly developed
#git clone git://git.warmcat.com/libwebsockets
git clone git://github.com/davidgaleano/libwebsockets.git
cd libwebsockets
./configure
make clean
make
sudo make install
sudo ln -s /usr/local/lib/libwebsockets.so /usr/lib/libwebsockets.so.0

The cd to the websockets directory and specify libwebsocket location for compilation :
gcc -Wall -O main.c -o server /usr/local/lib/libwebsockets.so