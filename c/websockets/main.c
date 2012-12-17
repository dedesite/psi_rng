/**
This code is heavily based on this libwebsockets tutorial :
http://martinsikora.com/libwebsockets-simple-websocket-server
gist available here :
https://gist.github.com/3654228
*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>

#include <libwebsockets.h>

#define FIFO_FILE "../rng_fifo"
//We sample the chaos 2000 times per second which mean 250bytes / sec
//and the numbers are send each 100ms so we send 25 bytes each time
#define MAX_NUMBER_PER_READ 25

//Used to limit the connected client to 1
struct libwebsocket *connected_client = NULL;

//Just don't respond to http request
static int callback_http(struct libwebsocket_context * this,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason, void *user,
                         void *in, size_t len)
{ return 0; }



static int callback_rng(struct libwebsocket_context * this,
                                   struct libwebsocket *wsi,
                                   enum libwebsocket_callback_reasons reason,
                                   void *user, void *in, size_t len)
{
    switch (reason) {
        case LWS_CALLBACK_ESTABLISHED: // just log message that someone is connecting
            if(!connected_client){
                printf("connection established\n");
                connected_client = wsi;
                //As the program is single threaded we can't just start a loop
                //and sending indefinitly random numbers. Cause we won't never be called
                //on disconnect...
                //Here is a try with the linux epoll function (a js setTimeout will be so good...)
            }
            else{
                printf("Connection refused : only one client can connect at a time\n");
            }
            
            break;
        case LWS_CALLBACK_CLOSED:
            if(connected_client) connected_client = NULL;
            break;
        case LWS_CALLBACK_RECEIVE: { 
            // the funny part
            // create a buffer to hold our response
            // it has to have some pre and post padding. You don't need to care
            // what comes there, libwebsockets will do everything for you. For more info see
            // http://git.warmcat.com/cgi-bin/cgit/libwebsockets/tree/lib/libwebsockets.h#n597
            unsigned char *buf = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + len +
                                                         LWS_SEND_BUFFER_POST_PADDING);       
            
            int i;
            
            // pointer to `void *in` holds the incomming request
            // we're just going to put it in reverse order and put it in `buf` with
            // correct offset. `len` holds length of the request.
            for (i=0; i < len; i++) {
                buf[LWS_SEND_BUFFER_PRE_PADDING + (len - 1) - i ] = ((char *) in)[i];
            }
            // log what we recieved and what we're going to send as a response.
            // that disco syntax `%.*s` is used to print just a part of our buffer
            // http://stackoverflow.com/questions/5189071/print-part-of-char-array
            printf("received data: %s, replying: %.*s\n", (char *) in, (int) len,
                   buf + LWS_SEND_BUFFER_PRE_PADDING);
            
            // send response
            // just notice that we have to tell where exactly our response starts. That's
            // why there's `buf[LWS_SEND_BUFFER_PRE_PADDING]` and how long it is.
            // we know that our response has the same length as request because
            // it's the same message in reverse order.
            libwebsocket_write(wsi, &buf[LWS_SEND_BUFFER_PRE_PADDING], len, LWS_WRITE_TEXT);
            
            // release memory back into the wild
            free(buf);
            break;
        }
        default:
            break;
    }
    
    return 0;
}

/**
 Read the fifo file where random numbers are written and then convert them to a json array
 which can be easilly read in javascript.
*/
size_t file_size = 0;
static unsigned char* read_random_numbers(){
    FILE *fp = fopen(FIFO_FILE, "rb");
    if (fp) {
        unsigned char *numbers = 
            (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + MAX_NUMBER_PER_READ + LWS_SEND_BUFFER_POST_PADDING);

        file_size = fread(&numbers[LWS_SEND_BUFFER_PRE_PADDING], 1, MAX_NUMBER_PER_READ, fp);
        if(file_size < MAX_NUMBER_PER_READ){
            printf("We've got not enough numbers : %d instead of %d", file_size, MAX_NUMBER_PER_READ);
        }
        //printf("Recieving numbers = %s\n", numbers);
        fclose(fp);
        //We sleep a bit to avoid reading while the RNG is writing
        usleep(2000);

        return numbers;
    }
    else {
        perror("error opening fifo");
        exit(1);
    }
}

static void send_random_numbers(struct libwebsocket *wsi, unsigned char *numbers){
    //attention a bien avoir la taille du tableau et a ne pas faire de malloc sur le buffer a chaque fois...
    libwebsocket_write(wsi, &numbers[LWS_SEND_BUFFER_PRE_PADDING], MAX_NUMBER_PER_READ, LWS_WRITE_BINARY);
}



static struct libwebsocket_protocols protocols[] = {
    /* first protocol must always be HTTP handler */
    {
        "http-only", // name
        callback_http, // callback
        0 // per_session_data_size
    },
    {
        "rng-protocol", // protocol name - very important!
        callback_rng, // callback
        0 // we don't use any per session data
    },
    {
        NULL, NULL, 0 /* End of list */
    }
};

int main(void) {
    // server url will be http://localhost:8080
    int port = 8080;
    const char *interface = NULL;
    struct libwebsocket_context *context;
    // we're not using ssl
    const char *cert_path = NULL;
    const char *key_path = NULL;
    const char *ca_path = NULL;
    // no special options
    int opts = 0;
    
    // create libwebsocket context representing this server
    context = libwebsocket_create_context(port, interface, protocols,
                                          libwebsocket_internal_extensions,
                                          cert_path, key_path, ca_path, -1, -1, opts);
    
    if (context == NULL) {
        fprintf(stderr, "libwebsocket init failed\n");
        return -1;
    }

    /* Create the FIFO if it does not exist */
    umask(0);
    mkfifo(FIFO_FILE, 0666);
    
    printf("Waiting for Random Numbers Generator to start sending numbers...\n");
    FILE *fp = fopen(FIFO_FILE, "r");
    if (fp) {
        printf("Random Numbers Generator started : starting websocket server.\n");
        fclose(fp);
    }
    else {
        perror("error opening fifo");
        exit(1);
    }
    
    // infinite loop, to end this server send SIGTERM. (CTRL+C)
    while (1) {
        //There is 0ms sleep in the service
        //cause the sleep time is determine by the Random Number Generator
        //through the FIFO
        libwebsocket_service(context, 0);


        unsigned char* numbers = read_random_numbers();
        //If we got a connected client
        //Send we send him the random numbers each 100ms
        if(connected_client){
            send_random_numbers(connected_client, numbers);
        }
        //Don't forget to free the numbers
        free(numbers);
    }
    
    libwebsocket_context_destroy(context);
    
    return 0;
}