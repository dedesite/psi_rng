Some usefull information on how to compile and configure a project for libwebsockets can be found here :
http://martinsikora.com/libwebsockets-compiling-libraries-and-projects

What I did on my Ubuntu 11.10 machine :
git clone git://git.warmcat.com/libwebsockets
cd libwebsockets
./configure
make clean
make
sudo make install
sudo ln -s /usr/local/lib/libwebsockets.so /usr/lib/libwebsockets.so.0

The cd to the websockets directory and specify libwebsocket location for compilation :
gcc -o server main.c /usr/local/lib/libwebsockets.so