#ifndef COMMON_H
#define COMMON_H

#define SHM_KEY 1234
#define SEM_KEY 5678
#define MSG_KEY 9999
#define SHM_SIZE 1024 * 1024 // 1MB

struct msg_request {
    long mtype;
    int length;
};

#define MSG_TYPE 1

#endif
