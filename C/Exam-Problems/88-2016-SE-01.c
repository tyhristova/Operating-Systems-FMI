#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/stat.h>
#include <err.h>

int readWr(int fd, void * buff, int size) {
    int r=read(fd, buff, size);
    if(r < 0) {
        err(2,"Problem reading!");
    }
    return r;
}

int writeWr(int fd, void * buff, int size) {
    int w=write(fd,buff,size);
    if(w<0) {
        err(3, "Problem writing!");
    }
    return w;
}

int lseekWr(int fd, int offset, int whence) {
    int l=lseek(fd, offset, whence);
    if(l<0) {
        err(4,"Problem lseek!");
    }
    return l;
}

size_t getFileSize(int fd) {
    struct stat info;
    fstat(fd, &info);
    return info.st_size;
}

int main(int argc, char** argv) {
    if(argc != 2) {
        errx(1, "Invalid number of arguments!");
    }

    int fd1=open(argv[1], O_RDONLY);
    if(fd1 < 0) {
        err(1,"Problem opening the file!");
    }

    uint8_t bytes[256]={0};

    uint8_t byte;
    int r = 0;
    while((r=readWr(fd1,&byte,sizeof(byte)) > 0)) {
        bytes[byte]++;
    }

    close(fd1);

    int fd2=open(argv[1], O_WRONLY|O_TRUNC);
    if(fd2 < 0) {
        err(6,"Problem opening the file!");
    }

    for(int i = 0; i < 256; i++) {
        uint8_t b = i;

        for(uint8_t j = 0; j < bytes[i]; j++) {
            writeWr(fd2,&b,sizeof(b));
        }
    }

    close(fd2);
    exit(0);
}
