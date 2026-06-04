#include <err.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

ssize_t wrapper_write(int fd, const char* buff, ssize_t size_buff) {
    ssize_t w = write(fd, buff, size_buff);
 
     if(w < 0) {
         close(fd);
         err(1, "Failed to write to %d", fd);
     }
 
     return w;
 }
 
 int main(void) {
     pid_t child = fork();
 
     if(child < 0) {
         err(2, "Failed to fork");
     }
 
     if(child == 0) {
         for(int i = 0; i < 3; i++) {
             wrapper_write(1, "Child\n", strlen("Child\n"));
         }
         exit(0);
     }
 
     for(int i = 0; i <3; i++) {
         wrapper_write(1, "Parent\n", strlen("Parent\n"));
     }
 
     int w_status;
 
     if(wait(&w_status) < 0) {
         err(3, "wait");
     }
 
     if(WIFEXITED(w_status) == 0) {
         err(4, "The child process ended abnormally!");
     }
 
     exit(0);
 }
