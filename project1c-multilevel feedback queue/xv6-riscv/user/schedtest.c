#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/log.h"

struct logentry schedlog[LOG_SIZE];

//TEST
//call fork twice to make two child processes, 
//use one loop with sleep so it doesn't use much CPU and the other loop count to 1billion so it uses a lot of CPU...
//you should expect the one that uses a lot of CPU to drop low priority while the other one should interrupt it
//Free a process's page table, and free the
//physical memory it refers to.

struct logentry schedlog[LOG_SIZE];

void main(void){
    uint64 acc = 0;
    uint64 count = 1000000000;
    //Fork processes
    int n1 = fork();
    int n2 = fork();
    //Start logging
    startlog();
    uint64 sizeLog = 0;
    //Start intensive process
    if(n1>0 && n2 >0){
        nice(-19);
        for(uint64 i = 0; i < count; i++){
            acc+=i;
        }
    }else if(n1 == 0 && n2 > 0){
        //Start non-intensive process
        nice(-19);
        for(uint64 i = 0; i < count; i++){
            sleep(1);
        }
    }
    //Print out log
    sizeLog = getlog(schedlog);
    for(int i = 0; i < sizeLog; i++){
        printf("ID: %d, Time: %d\n", schedlog[i].pid, schedlog[i].time);
    }
}