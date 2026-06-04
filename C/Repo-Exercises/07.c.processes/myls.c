#include <err.h>
#include <unistd.h>

int main(int argc, char* argv) {
    if(argc != 2) {
        errx(1, "Imvalid number of arguments!");
    }
    execlp("ls", "ls", argv[1], (const char*)NULL);
    err(1, "Failed to execute ls");
}