// ideq:
// chetem dva poredni puti i gi zapisvame v otdelni promenlivi x i y (otvorili sme fd za chetene ot f2 i za pisane v f3) // wrapperi za read write za greshkite
// mestim lseek v f2 na pos x i pishem s for do y v f3 prochetenoto ot f2

#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <err.h>

int lseekWR(int fd, int offset, int whence){
    int ls=lseek(fd,offset,whence);
    if(ls<0){
        err(2,"Problem with lseek!");
    }
    return ls;
}

int readWR(int fd, void * buff, int size){
    int r=read(fd,buff,size);
    if(r<0){
        err(3,"Problem reading!");
    }
    return r;
}

int writeWR(int fd, void * buff, int size){
    int w=write(fd,buff,size);
    if(w<0){
        err(4,"Problem writing!");
    }
    return w;
}

typedef struct {
    uint32_t from;
    uint32_t howMany;
} pair;

int main(int argc, char** argv) {
    if(argc != 4) {
        errx(1,"Invalid number of arguments!");
    }

    int fd1=open(argv[1],O_RDONLY);
    if(fd1 < 0){
        err(1, "Problem opening f1");
    }

    int fd2=open(argv[2],O_RDONLY);
    if(fd2 < 0){
        err(1, "Problem opening f2");
    }
    
    int fd3=open(argv[3],O_WRONLY | O_TRUNC | O_CREAT, 0644);
    if(fd3 < 0){
        err(1, "Problem opening f3");
    }
    
    pair pair1;
    uint32_t cur;

    while(readWR(fd1, &pair1, sizeof(pair1)) == sizeof(pair1)) {
        lseekWR(fd2, pair1.from * sizeof(uint32_t), SEEK_SET);

        for(uint32_t i = 0; i < pair1.howMany; i++) {
            readWR(fd2, &cur, sizeof(uint32_t));
            writeWR(fd3, &cur, sizeof(uint32_t));
        }
    }

    close(fd1);
    close(fd2);
    close(fd3);

    exit(0);
}