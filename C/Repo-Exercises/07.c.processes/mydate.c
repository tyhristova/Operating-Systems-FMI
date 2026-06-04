#include <err.h>
#include <unistd.h>

int main(void) {
    execlp("date", "date", (const char*)NULL);
    err(1, "Failed to execute date");
}