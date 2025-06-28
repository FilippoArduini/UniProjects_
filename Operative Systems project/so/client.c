#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/msg.h>
#include <sys/sem.h>
#include <fcntl.h>
#include "common.h"

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Uso: %s <file>\n", argv[0]);
        return 1;
    }

    int shmid = shmget(SHM_KEY, SHM_SIZE, 0666);
    unsigned char *shm_ptr = shmat(shmid, NULL, 0);

    int msgid = msgget(MSG_KEY, 0666);
    int semid = semget(SEM_KEY, 1, 0666);

    FILE *fp = fopen(argv[1], "rb");
    if (!fp) {
        perror("Errore apertura file");
        return 1;
    }

    fseek(fp, 0, SEEK_END);
    int length = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    fread(shm_ptr, 1, length, fp);
    fclose(fp);

    struct msg_request req;
    req.mtype = MSG_TYPE;
    req.length = length;

    msgsnd(msgid, &req, sizeof(int), 0);
    printf("[CLIENT] Richiesta inviata, in attesa del risultato...\n");

    // Attendi il semaforo
    struct sembuf sb = {0, -1, 0}; // decrementa
    semop(semid, &sb, 1);

    // Leggi hash
    char hash_output[65];
    memcpy(hash_output, shm_ptr + length, 65);
    printf("[CLIENT] SHA-256: %s\n", hash_output);

    return 0;
}
