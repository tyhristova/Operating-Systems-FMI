#include <fcntl.h>
#include <err.h>
#include <unistd.h>

void print_file(const char* filename) {
    int fd = open(filename, O_RDONLY);
    if(fd < 0) {
        err(1, "could not open the file for reading");
    }
 
     char buff[4096];
     ssize_t bytes_read;
 
     while((bytes_read = read(fd, buff, sizeof(buff))) > 0) {
         ssize_t bytes_write = write(1, buff, bytes_read);
         if(bytes_write < 0) {
             err(1, "could not write to stdout");
         }
     }
 
     if(bytes_read < 0) {
         err(1, "could not read");
     }
     close(fd);
 }
 
 int main(int argc, char* argv[]) {
     if (argc < 2) {
         errx(1, "not enough parameters");
     }
 
     for(int i = 1; i < argc; i++) {
         print_file(argv[i]);
     }
 
     return 0;
 }