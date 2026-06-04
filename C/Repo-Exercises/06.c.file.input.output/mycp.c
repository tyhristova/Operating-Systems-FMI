#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <err.h>

int main(int argc, char* argv[]) {
    if(argc != 3) {
        errx(1, "usage: %s <src> <dest>", argv[0]);
    }
 
     int src = open(argv[1], O_RDONLY);
     if (src < 0) {
         err(2, "could not open the source file");
     }
 
     int dest = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644 );
     if(dest < 0) {
         close(src);
         err(3, "could not open the destination file");
     }
 
     char buff[4096];
     ssize_t bytes_read;
 
     while(((bytes_read = read(src, buff, sizeof(buff))) > 0)) {
         ssize_t bytes_written = write(dest, buff, bytes_read);
         if(bytes_written < 0) {
             close(src);
             close(dest);
             err(4, "could not write");
         }}
 
     if (bytes_read < 0) {
 
         close(src);
         close(dest);
         err(5, "could not read");
     }
 
     close(src);
     close(dest);
 
     exit(0);
 }