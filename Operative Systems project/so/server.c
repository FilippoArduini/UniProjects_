#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/msg.h>
#include <sys/sem.h>
#include <openssl/sha.h>
#include "common.h"


void sha256_hash(unsigned char *data, int length, char *output) {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256(data, length, hash);
    for (int i = 0; i < SHA256_DIGEST_LENGTH; i++)
        sprintf(output + (i * 2), "%02x", hash[i]);
    output[64] = 0;
}

int main() {
    int shmid = shmget(SHM_KEY, SHM_SIZE, IPC_CREAT | 0666);
    unsigned char *shm_ptr = shmat(shmid, NULL, 0);

    int msgid = msgget(MSG_KEY, IPC_CREAT | 0666);
    int semid = semget(SEM_KEY, 1, IPC_CREAT | 0666);

    union semun sem_val;
    sem_val.val = 0;
    semctl(semid, 0, SETVAL, sem_val);

    struct msg_request req;

    printf("[SERVER] Avviato.\n");

    while (1) {
        msgrcv(msgid, &req, sizeof(int), MSG_TYPE, 0);
        printf("[SERVER] Ricevuta richiesta di %d byte\n", req.length);

        // Calcola SHA-256
        char hash_output[65];
        sha256_hash(shm_ptr, req.length, hash_output);

        // Scrivi l’hash dopo il contenuto (alla fine della zona condivisa)
        memcpy(shm_ptr + req.length, hash_output, 65);

        // Sblocca il semaforo per segnalare il client
        struct sembuf sb = {0, 1, 0}; // incrementa
        semop(semid, &sb, 1);
    }

    return 0;
}
