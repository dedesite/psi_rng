/**
This code is heavily based on this libwebsockets tutorial :
http://martinsikora.com/libwebsockets-simple-websocket-server
gist available here :
https://gist.github.com/3654228
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>

#include <libwebsockets.h>

#include "daemonize.h"
#include "popenRWE.h"
#include "fifo.h"

//We sample the chaos 2000 times per second which mean 250bytes / sec
//and the numbers are send each 100ms so we send 25 bytes each time
#define MAX_NUMBER_PER_READ 25
#define NUM_SAMPLE_TO_TEST 101

//Used to limit the connected client to 1
struct libwebsocket *connected_client = NULL;
//Wheter or not the connected_client is on the test_protocol
bool test_protocol = false;

//Just don't respond to http request
static int callback_http(struct libwebsocket_context * this,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason, void *user,
                         void *in, size_t len)
{ return 0; }


//Return true if there is a new connection
static bool manage_connection(struct libwebsocket *wsi, enum libwebsocket_callback_reasons reason){
    switch (reason) {
        case LWS_CALLBACK_ESTABLISHED: // just log message that someone is connecting
            if(!connected_client){
                printf("connection established\n");
                connected_client = wsi;
                return true;
            }
            else{
                printf("Connection refused : only one client can connect at a time\n");
            }
            
            break;
        case LWS_CALLBACK_CLOSED:
            if(connected_client) {
                connected_client = NULL;
                test_protocol = false;
            }
            break;
        default:
            break;
    }

    return false;
}

static int callback_rng(struct libwebsocket_context * this,
                                   struct libwebsocket *wsi,
                                   enum libwebsocket_callback_reasons reason,
                                   void *user, void *in, size_t len)
{

    bool new_connection = manage_connection(wsi, reason);
    if(new_connection)
        test_protocol = false;
    return 0;
}

static int callback_rngtest(struct libwebsocket_context * this,
                                   struct libwebsocket *wsi,
                                   enum libwebsocket_callback_reasons reason,
                                   void *user, void *in, size_t len)
{
    bool new_connection = manage_connection(wsi, reason);
    if(new_connection){
        test_protocol = true;
    }
    return 0;
}

/**
 Read the fifo file where random numbers are written and then convert them to a json array
 which can be easilly read in javascript.
*/
static size_t read_random_numbers(unsigned char* numbers_array)
{
    size_t file_size = 0;
    FILE *fp = fopen(FIFO_FILE, "rb");
    if (fp) 
    {
        file_size = fread(numbers_array, 1, MAX_NUMBER_PER_READ, fp);
        if(file_size < MAX_NUMBER_PER_READ)
            printf("We've got not enough numbers : %zu instead of %d\n", file_size, MAX_NUMBER_PER_READ);
        //printf("Recieving numbers = %s\n", numbers);
        fclose(fp);
        //We sleep a bit to avoid reading while the RNG is writing
        usleep(2000);
    }
    else 
    {
        perror("error opening fifo");
        exit(1);
    }
    return file_size;
}

static size_t read_for_send(unsigned char *numbers)
{
    return read_random_numbers(&numbers[LWS_SEND_BUFFER_PRE_PADDING]);
}

static void send_random_numbers(struct libwebsocket *wsi, unsigned char *numbers, size_t len)
{
    //attention a bien avoir la taille du tableau et a ne pas faire de malloc sur le buffer a chaque fois...
    libwebsocket_write(wsi, &numbers[LWS_SEND_BUFFER_PRE_PADDING], len, LWS_WRITE_BINARY);
}

static void read_for_test(int current_sample_ind, unsigned char *numbers_to_test){
    read_random_numbers(&numbers_to_test[current_sample_ind*MAX_NUMBER_PER_READ]);
}

//Call rngtest with the 20000 bits and send the result
static void test_random_numbers(struct libwebsocket *wsi, unsigned char *numbers_to_test){
    //open the rngtest process
    //FILE *fp = popen("rngtest", "w");
    int pipe[3];
    //Very important rngtest is run in pipe mode
    pid_t pid = popenRWE(pipe, "rngtest --pipe");
    if(pid > 0){
        int nb_bytes = write(pipe[0], numbers_to_test, NUM_SAMPLE_TO_TEST*MAX_NUMBER_PER_READ);
        //We need to close the pipe, otherwise we could wait undefinitly
        close(pipe[0]);
        char buf[LWS_SEND_BUFFER_PRE_PADDING+1024+LWS_SEND_BUFFER_POST_PADDING];
        //Read stdout
        nb_bytes = read(pipe[1], &buf[LWS_SEND_BUFFER_PRE_PADDING], 1024);
        if(nb_bytes == 0){
            //rngtest write error results to stderr
            nb_bytes = read(pipe[2], &buf[LWS_SEND_BUFFER_PRE_PADDING], 1024);
        }

        pcloseRWE(pid, pipe);

        libwebsocket_write(wsi, (unsigned char*)&buf[LWS_SEND_BUFFER_PRE_PADDING], nb_bytes, LWS_WRITE_TEXT);
    }
    else {
        perror("error opening rngtest process");
        exit(1);
    }
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
        "rngtest-protocol", //Launch rngtest each 2000 bits and send the result
        callback_rngtest,
        0
    },
    {
        NULL, NULL, 0 /* End of list */
    }
};

int main(int argc, char *argv[]) {
    int current_sample_ind = 0;
    unsigned char numbers[LWS_SEND_BUFFER_PRE_PADDING + MAX_NUMBER_PER_READ + LWS_SEND_BUFFER_POST_PADDING];
    //Cumulate 20000 bits for test
    unsigned char numbers_to_test[MAX_NUMBER_PER_READ*NUM_SAMPLE_TO_TEST];
    size_t len = 0;
    if(argc > 2 && strcmp(argv[1], "-d") == 0)
        daemonize();

    // server url will be http://localhost:8080
    struct lws_context_creation_info info;
    memset(&info, 0, sizeof info);
    info.port = 8080;
    info.iface = NULL;
    info.protocols = protocols;
    info.extensions = libwebsocket_get_internal_extensions();
    info.ssl_cert_filepath = NULL;
    info.ssl_private_key_filepath = NULL;
    info.gid = -1;
    info.uid = -1;
    info.options = 0;
    
    struct libwebsocket_context *context;
    // create libwebsocket context representing this server
    context = libwebsocket_create_context(&info);
    
    if (context == NULL) {
        fprintf(stderr, "libwebsocket init failed\n");
        exit(1);
    }

    create_fifo_and_wait("r", "Waiting for Random Numbers Generator to start sending numbers...", 
        "Random Numbers Generator started : starting websocket server.");

    // infinite loop, to end this server send SIGTERM. (CTRL+C)
    while (1) {
        //There is 0ms sleep in the service
        //cause the sleep time is determine by the Random Number Generator
        //through the FIFO
        libwebsocket_service(context, 0);

        if(test_protocol){
            read_for_test(current_sample_ind, (unsigned char*)&numbers_to_test);
            current_sample_ind++;
        }
        else{
            len = read_for_send((unsigned char*)&numbers);
        }

        //If we got a connected client
        //Send we send him the random numbers each 100ms
        if(connected_client)
        {
            if(test_protocol)
            {
                if(current_sample_ind >= NUM_SAMPLE_TO_TEST-1)
                    test_random_numbers(connected_client, (unsigned char*)&numbers_to_test);
            }
            else
                send_random_numbers(connected_client, (unsigned char*)&numbers, len);
        }

        if(current_sample_ind >= NUM_SAMPLE_TO_TEST-1)
            current_sample_ind = 0;
    }
    
    libwebsocket_context_destroy(context);
    
    return 0;
}