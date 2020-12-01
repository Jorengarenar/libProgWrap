#ifndef WRAPPER_EXEC_H_
#define WRAPPER_EXEC_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <sys/types.h>

int   appendExecChain(ino_t I);
char* getCurrentBin(char* cur);
char* findRealBin(char* bin);

#ifdef __cplusplus
} // extern "C"
#endif

#endif
