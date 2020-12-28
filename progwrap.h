#ifndef LIBPROGWRAP_H_
#define LIBPROGWRAP_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <errno.h>
#include <libgen.h>
#include <linux/limits.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

extern char** environ;

static int appendExecChain(char* execChainEnvVar, ino_t I)
{
    char inoStr[100];
    snprintf(inoStr, 100, "%zu", I);

    char* chain = getenv(execChainEnvVar);
    if (chain && strstr(chain, inoStr)) {
        return 1;
    } else {
        char buf[BUFSIZ];
        if (chain) {
            snprintf(buf, BUFSIZ, "%s%s%s%s%s", execChainEnvVar, "=", chain, ":", inoStr);
        } else {
            snprintf(buf, BUFSIZ, "%s%s%s", execChainEnvVar, "=", inoStr);
        }
        putenv(buf);
    }
    return 0;
}

static char* getCurrentBin(char* cur)
{
    const char* proc_self = "/proc/self/exe";
    if (readlink(proc_self, cur, PATH_MAX) < 0) {
        return NULL;
    }
    return cur;
}

static char* findExecutable(char* args[], char* bin)
{
    errno = 0;
    struct stat fb;

    char cur[PATH_MAX];
    if (getCurrentBin(cur) == NULL) {
        return NULL;
    }

    stat(args[0], &fb);
    ino_t fooInode = fb.st_ino;

    stat(cur, &fb);
    ino_t curInode = fb.st_ino;

    char* bs = basename(args[0]);

    char execChainEnvVar[150];
    snprintf(execChainEnvVar, 150, "%s%s", "execution_chain_", bs);

    if (curInode != fooInode) {
        appendExecChain(execChainEnvVar, fooInode);
    }

    char buf[PATH_MAX];
    char PATH[BUFSIZ];
    strncpy(PATH, getenv("PATH"), BUFSIZ-1);
    char* dir = strtok(PATH, ":");

    do {
        snprintf(buf, PATH_MAX, "%s%s%s", dir, "/", bs);
        if (stat(buf, &fb) < 0) {
            continue;
        }
        ino_t ino = fb.st_ino;

        if (ino != curInode && fb.st_mode & S_IXUSR) {
            if (appendExecChain(execChainEnvVar, ino) == 0) {
                strncpy(bin, buf, PATH_MAX);
                return bin;
            }
        }
    } while ((dir = strtok(NULL, ":")));

    errno = ENOENT;
    return NULL;
}

int progwrap_exec(char* args[])
{
    errno = 0;
    char bin[PATH_MAX];
    if (findExecutable(args, bin) == NULL) {
        return -1;
    }

    return execve(bin, args, environ);
}

#ifdef __cplusplus
} // extern "C"
#endif

#endif // LIBPROGWRAP_H_
