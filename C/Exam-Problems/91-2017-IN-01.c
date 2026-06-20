#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <err.h>

int lseekWR(int fd, int pos, int size)
{
    int ls = lseek(fd, pos, size);
    if (ls < 0)
    {
        err(1, "Problem with lseek!");
    }
    return ls;
}

int readWR(int fd, void *buff, int size)
{
    int r = read(fd, buff, size);
    if (r < 0)
    {
        err(2, "Problem with reading!");
    }
    return r;
}

int writeWR(int fd, void *buff, int size)
{
    int w = write(fd, buff, size);
    if (w < 0)
    {
        err(3, "Problem with writing!");
    }
    return w;
}

int getFileSize(int fd)
{
    struct stat info;
    if (fstat(fd, &info) < 0)
    {
        err(4, "Problem with fstat");
    }
    return info.st_size;
}

/////////////////////////////////////////////////////////////

typedef struct
{
    uint16_t offset;
    uint8_t length;
    uint8_t fake;
} triple;

int main(int argc, char **argv)
{
    if (argc != 5)
    {
        errx(1, "Invalid number of params!");
    }

    int f1 = open(argv[1], O_RDONLY);
    if (f1 < 0)
    {
        err(5, "Opening f1");
    }
    int f2 = open(argv[2], O_RDONLY);
    if (f2 < 0)
    {
        err(6, "Opening f2");
    }
    int f3 = open(argv[3], O_WRONLY | O_TRUNC | O_CREAT, 0644);
    if (f3 < 0)
    {
        err(7, "Opening f3");
    }
    int f4 = open(argv[4], O_WRONLY | O_TRUNC | O_CREAT, 0644);
    if (f4 < 0)
    {
        err(8, "Opening f4");
    }

    int f1size = getFileSize(f1);
    int f2size = getFileSize(f2);

    if (f2size % sizeof(triple) != 0)
    {
        err(8, "File format f2 not valid");
    }

    triple current;
    int haveRead = 0;

    while ((haveRead = readWR(f2, &current, sizeof(current))) == sizeof(triple))
    {
        if ((size_t)(current.offset + current.length) * (size_t)(sizeof(uint8_t)) >= (size_t)f1size)
        {
            err(1, "Invalid file format!");
        }

        lseekWR(f1, current.offset * sizeof(uint8_t), SEEK_SET);
        uint8_t c;
        readWR(f1, &c, sizeof(c));
        if (c < 'A' || c > 'Z')
        {
            continue;
        }

        lseekWR(f1, -1, SEEK_CUR);
        for (int i = 0; i < current.length; i++)
        {
            readWR(f1, &c, sizeof(c));
            writeWR(f3, &c, sizeof(c));
        }

        // write to idx2.idx file
        triple toWrite;

        toWrite.offset = lseekWR(f3, 0, SEEK_CUR) - current.length;
        toWrite.length = current.length;

        writeWR(f4, &toWrite, sizeof(triple));
    }

    if (haveRead < 0)
    {
        err(9, "Error occurred while reading!");
    }

    close(f1);
    close(f2);
    close(f3);
    close(f4);

    exit(0);
}