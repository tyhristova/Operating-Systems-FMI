#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <err.h>

off_t asserted_lseek(int fd, off_t offset, int whence) {
    off_t ls = lseek(fd, offset, whence);

    if(ls < 0) {
         err(4, "Failed to lseek %d", fd);
     }
 
     return ls;
 }
 
 int main(int argc, char* argv[]) {
     if(argc != 3) {
         errx(1, "Invalid amount of arguments!");
     }
 
     int fd1 = open(argv[1], O_RDWR);
 
     if(fd1 < 0) {
         err(2, "Failed to open %s", argv[1]);
     }
 
     int fd2 = open(argv[2], O_RDWR);
 
     if(fd2 < 0) {
         close(fd1);
         err(3, "Failed to open %s", argv[2]);
     }
 
     char ch1;
     char ch2;
 
     int r1;
     int r2;
 
     while ((r1 = read(fd1, &ch1, sizeof(ch1)) > 0) && (r2 = read(fd2, &ch2, sizeof(ch2)) > 0)) {
         lseek(fd1, -1, SEEK_CUR);
         lseek(fd2, -1, SEEK_CUR);
 
         if(write(fd1, &ch2, sizeof(ch2)) < 0) {
            err(5, "Failed to write to %s", argv[1]);
         }
 
         if(write(fd2, &ch1, sizeof(ch1)) < 0) {
             err(6, "Failed to write to %s", argv[2]);
         }
     }
 
     if (r1 < 0) {
         err(7, "Failed to read to %s", argv[1]);
     }
 
     if (r2 < 0) {
         err(8, "Failed to read to %s", argv[2]);
     }
 
     close(fd1);
     close(fd2);
 
     exit(0);
 }