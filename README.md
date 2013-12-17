psi_rng
=======

Arduino, Raspberry Pi, processing (legacy) and processingJs code for a DIY Hardware Random Number Generator.

# Hardware

I worked on a reproduction of an Hardware Random Number Generator made by [Rob Seward](http://robseward.com/misc/RNG2/) which was inspired by the work of [Aaron Logue](http://www.cryogenius.com/hardware/rng/). I want to thank both of them for sharing their work.

I now work on a reproduction of an Hardware Random Number Generator made by [Giorgio Vazzana](http://holdenc.altervista.org/avalanche/) which seems to have a more structured design, output directly digital values and seems to be less biais. Special thanks to him, firstly cause his article is very complete and "scientific" and secondly cause he helps me building and tuning the circuit, so hat off !

# Project

My goal is to study effect of the intention (human or animal) on the matter through the influence of hardware based randomness generation.

I will try to reproduice the principles of [Rene Poec'h](http://psiland.free.fr/savoirplus/theses/theses.html#RenePeoch) experiment with [baby chicken and a robot](http://www.dailymotion.com/video/xb6zgf_l-esprit-et-la-matiere_tech) but with a "software robot" guide with the RNG.

I will also create new kinds of experiments, more on this later...

# Code

## Raspberry (C) code

I now use a raspberry pi as a Random Number Generator **and** a websockets server (using [libwebsockets](https://github.com/warmcat/libwebsockets)).
Code that read the random frequency stream and transform it to a random bit stream.

Code espacially made to be run on slow configuration with few RAM and little CPU like raspberry.
On the raspberry it took only 0.7% of the RAM and 15% of the CPU !
The first program reads GPIO, generates a stream of byte with the random bits and write them to a FIFO.
The second program reads the randoms numbers through the FIFO and send them via websockets if a client is connected.
Note: Look at the `README.md` in the "c" directory

## Processingjs code

A bunch of experiments using the rng. Some of them may use violents or pornographics images to create an emotional reaction on the subject. I decided not to put thoses photos on the repository but to share links where you can find them.

The most advanced experiment is the "robot hasard" which is a software replication of the "tychoscope", the little robot used in Rene Peoc'h experiments.

## Licence

All code is under GPL V3 licence.

# Articles

All articles are Copyrighted so you are not allow to modify them except you have the author permission.

I'm not even sure if it's legal to store those articles on github.
If it's not, please let me know, I'll remove them.

Here is the place where I downloaded them :
*  http://www.princeton.edu/~pear/pdfs/
*  http://psiland.free.fr/savoirplus/theses/theses.html#RenePeoch
*  http://www.scientificexploration.org/journal/jse_22_2_ivtzan.pdf