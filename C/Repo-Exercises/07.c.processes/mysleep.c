#include <err.h>
#include <unistd.h>

int main(void) {
    execlp("sleep", "sleep", "3", (const char*)NULL);
    err(1, "Failed to execute sleep");
}