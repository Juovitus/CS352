#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/log.h"

struct logentry schedlog[LOG_SIZE];

//Will start logging and print out the ID and time of the logged processes.
int main(void){
    nice(10);
    startlog();
    uint64 sizeLog = 0;
    if(fork() > 0){
        for(int i = 0; i < 6; i++){
         sleep(1);
        }
        sizeLog = getlog(schedlog);
    }
    for(int i = 0; i < sizeLog; i++){
        printf("ID: %d,  Time:  %d\n", schedlog[i].pid, schedlog[i].time);

    }
    // printf("--------------------------------------------\n");
    // for(int i = 0; i < LOG_SIZE; i++){
    //     printf("ID: %d,  Time:  %d\n", schedlog[i].pid, schedlog[i].time);
    // }
    return 0;
}