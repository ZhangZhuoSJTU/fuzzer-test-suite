#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

extern "C" {
    int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size);
    __attribute__((weak)) int LLVMFuzzerInitialize(int *argc, char ***argv);
}

int main(int argc, char** argv)
{
        if(argc <= 1)
        {
                exit(1);
                printf("argc error!\n");
        }
        size_t length, result;
        unsigned char* buf;
        FILE *fp = fopen(argv[1], "rb");
        if(fp == NULL)
        {
                exit(1);
                printf("Open error!\n");
        }
        fseek(fp, 0, SEEK_END);
        length = (size_t)ftell(fp);
        rewind(fp);
        buf = (unsigned char*)malloc(length);
        if(buf == NULL)
        {
                printf("malloc error!\n");
                exit(2);
        }
        result = fread(buf, 1, length, fp);
        if(result != length)
        {
                printf("read error!\n");
                exit(3);
        }
        LLVMFuzzerTestOneInput(buf, result);
        free(buf);
        fclose(fp);
        return 0;
}
