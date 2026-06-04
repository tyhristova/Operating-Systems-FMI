#include <err.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char* argv[]) {
    if(argc < 3) {
        errx(1, "Invalid amount of arguments!");
    }
 
     int fd1 = open(argv[1], O_RDONLY);
 
     if(fd1 < 0) {
         err(2, "Failed to open %s", argv[1]);
     }
 
     char buffer[4096];
 
     ssize_t read_size = read(fd1, buffer, sizeof(buffer));
 
     if(read_size < 0) {
         err(3, "Failed to read %d", fd1);
     }
 
     close(fd1);
 
     int fd2 = open(argv[2], O_RDONLY);
 
     if(fd2 < 0) {
         err(4, "Failed to open %d", fd2);
     }
 
     char ch;
 
     int fd12 = open(argv[1], O_WRONLY | O_TRUNC);
 
     ssize_t r;
 
     while((r = read(fd2, &ch, sizeof(ch))) > 0) {
         ssize_t w = write(fd12, &ch, sizeof(ch));
 
         if(w < 0) {
             err(5, "Failed to write in %d", fd12);
         }
     }
 
     if (r < 0) {
         err(6, "Failed to read %d", fd2);
     }
 
     close(fd12);
     close(fd2);
 
     int fd22 = open(argv[2], O_WRONLY | O_TRUNC);
 
     if(fd22 < 0) {
         err(7, "Faile to open %d", fd2);
     }
 
     ssize_t w = write(fd22, buffer, read_size);
 
     if(w < 0) {
         err(8, "Failed to write in %s", argv[2]);
     }
 
     if(w != read_size) {
         errx(9, "Didn't wrte enough bytes to %s", argv[2]);
     }
 
     close(fd22);
     exit(0);
 }