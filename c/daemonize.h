#ifndef _DAEMONIZE
#define _DAEMONIZE

#include <sys/stat.h>

static void 
daemonize(void)
{
  pid_t pid, sid;

  /* already a daemon */
  if ( getppid() == 1 ) return;
  
  /* Fork off the parent process */
  pid = fork();
  if (pid < 0) {
    exit(EXIT_FAILURE);
  }
  /* If we got a good PID, then we can exit the parent process. */
  if (pid > 0) {
    exit(EXIT_SUCCESS);
  }
  
  /* At this point we are executing as the child process */
  fprintf(stdout,"Daemonization done. Messages are now logged to syslog.\n");
  
  /* Change the file mode mask */
  umask(0);
  
  /* Create a new SID for the child process */
  sid = setsid();
  if (sid < 0) {
    exit(EXIT_FAILURE);
  }
  
  /* Change the current working directory.  This prevents the current
     directory from being locked; hence not being able to remove it. */
  if ((chdir("/")) < 0) {
    exit(EXIT_FAILURE);
  }

  /* Redirect standard files to /dev/null */
  FILE *f;
  f = freopen( "/dev/null", "r", stdin);
  if(f == NULL) exit(EXIT_FAILURE);
  f = freopen( "/dev/null", "w", stdout);
  if(f == NULL) exit(EXIT_FAILURE);
  f = freopen( "/dev/null", "w", stderr);
  if(f == NULL) exit(EXIT_FAILURE);
}
#endif /*_DAEMONIZE*/
