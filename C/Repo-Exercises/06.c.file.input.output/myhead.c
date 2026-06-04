#include <fcntl.h>
#include <err.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
    if(argc != 2) {
        errx(1, "Invalid amount of arguments!");
    }
 
     int fd = open(argv[1], O_RDONLY);
 
     if (fd < 0) {
         err(2, "Failed to open %s", argv[1]);
     }
 
     char ch;
 
     int r;
 
     int line;
 
     while((r = read(fd, &ch, sizeof(ch))) > 0) {
         if (ch == '\n') {
             line++;
         }
 
         if(write(1,&ch,sizeof(ch)) < 0) {
             close(fd);
             err(3, "Failed to write!");
         }
 
         if(line == 10) {
             break;
         }
     }
 
     close(fd);
     exit(0);
 }