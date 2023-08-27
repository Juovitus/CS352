
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <__global_pointer$+0x1d46c>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <__global_pointer$+0x22f6>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <__global_pointer$+0xffffffffffffd63b>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00001517          	auipc	a0,0x1
      64:	65850513          	addi	a0,a0,1624 # 16b8 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	e70080e7          	jalr	-400(ra) # f00 <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	31650513          	addi	a0,a0,790 # 13b0 <malloc+0xea>
      a2:	00001097          	auipc	ra,0x1
      a6:	e3e080e7          	jalr	-450(ra) # ee0 <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	30650513          	addi	a0,a0,774 # 13b0 <malloc+0xea>
      b2:	00001097          	auipc	ra,0x1
      b6:	e36080e7          	jalr	-458(ra) # ee8 <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	2fc50513          	addi	a0,a0,764 # 13b8 <malloc+0xf2>
      c4:	00001097          	auipc	ra,0x1
      c8:	144080e7          	jalr	324(ra) # 1208 <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	daa080e7          	jalr	-598(ra) # e78 <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	30250513          	addi	a0,a0,770 # 13d8 <malloc+0x112>
      de:	00001097          	auipc	ra,0x1
      e2:	e0a080e7          	jalr	-502(ra) # ee8 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      e6:	00001997          	auipc	s3,0x1
      ea:	30298993          	addi	s3,s3,770 # 13e8 <malloc+0x122>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	2f098993          	addi	s3,s3,752 # 13e0 <malloc+0x11a>
    iters++;
      f8:	4485                	li	s1,1
  int fd = -1;
      fa:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
      fc:	00001a17          	auipc	s4,0x1
     100:	5cca0a13          	addi	s4,s4,1484 # 16c8 <buf.0>
     104:	a825                	j	13c <go+0xc4>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	2e650513          	addi	a0,a0,742 # 13f0 <malloc+0x12a>
     112:	00001097          	auipc	ra,0x1
     116:	da6080e7          	jalr	-602(ra) # eb8 <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	d86080e7          	jalr	-634(ra) # ea0 <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	d64080e7          	jalr	-668(ra) # e98 <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	4789                	li	a5,2
     152:	18f50563          	beq	a0,a5,2dc <go+0x264>
    } else if(what == 3){
     156:	478d                	li	a5,3
     158:	1af50163          	beq	a0,a5,2fa <go+0x282>
    } else if(what == 4){
     15c:	4791                	li	a5,4
     15e:	1af50763          	beq	a0,a5,30c <go+0x294>
    } else if(what == 5){
     162:	4795                	li	a5,5
     164:	1ef50b63          	beq	a0,a5,35a <go+0x2e2>
    } else if(what == 6){
     168:	4799                	li	a5,6
     16a:	20f50963          	beq	a0,a5,37c <go+0x304>
    } else if(what == 7){
     16e:	479d                	li	a5,7
     170:	22f50763          	beq	a0,a5,39e <go+0x326>
    } else if(what == 8){
     174:	47a1                	li	a5,8
     176:	22f50d63          	beq	a0,a5,3b0 <go+0x338>
    } else if(what == 9){
     17a:	47a5                	li	a5,9
     17c:	24f50363          	beq	a0,a5,3c2 <go+0x34a>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     180:	47a9                	li	a5,10
     182:	26f50f63          	beq	a0,a5,400 <go+0x388>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     186:	47ad                	li	a5,11
     188:	2af50b63          	beq	a0,a5,43e <go+0x3c6>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     18c:	47b1                	li	a5,12
     18e:	2cf50d63          	beq	a0,a5,468 <go+0x3f0>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     192:	47b5                	li	a5,13
     194:	2ef50f63          	beq	a0,a5,492 <go+0x41a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 14){
     198:	47b9                	li	a5,14
     19a:	32f50a63          	beq	a0,a5,4ce <go+0x456>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
     19e:	47bd                	li	a5,15
     1a0:	36f50e63          	beq	a0,a5,51c <go+0x4a4>
      sbrk(6011);
    } else if(what == 16){
     1a4:	47c1                	li	a5,16
     1a6:	38f50363          	beq	a0,a5,52c <go+0x4b4>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     1aa:	47c5                	li	a5,17
     1ac:	3af50363          	beq	a0,a5,552 <go+0x4da>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0);
    } else if(what == 18){
     1b0:	47c9                	li	a5,18
     1b2:	42f50963          	beq	a0,a5,5e4 <go+0x56c>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
     1b6:	47cd                	li	a5,19
     1b8:	46f50d63          	beq	a0,a5,632 <go+0x5ba>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
     1bc:	47d1                	li	a5,20
     1be:	54f50e63          	beq	a0,a5,71a <go+0x6a2>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
     1c2:	47d5                	li	a5,21
     1c4:	5ef50c63          	beq	a0,a5,7bc <go+0x744>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     1c8:	47d9                	li	a5,22
     1ca:	f4f51ce3          	bne	a0,a5,122 <go+0xaa>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1ce:	f9840513          	addi	a0,s0,-104
     1d2:	00001097          	auipc	ra,0x1
     1d6:	cb6080e7          	jalr	-842(ra) # e88 <pipe>
     1da:	6e054563          	bltz	a0,8c4 <go+0x84c>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1de:	fa040513          	addi	a0,s0,-96
     1e2:	00001097          	auipc	ra,0x1
     1e6:	ca6080e7          	jalr	-858(ra) # e88 <pipe>
     1ea:	6e054b63          	bltz	a0,8e0 <go+0x868>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1ee:	00001097          	auipc	ra,0x1
     1f2:	c82080e7          	jalr	-894(ra) # e70 <fork>
      if(pid1 == 0){
     1f6:	70050363          	beqz	a0,8fc <go+0x884>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1fa:	7a054b63          	bltz	a0,9b0 <go+0x938>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1fe:	00001097          	auipc	ra,0x1
     202:	c72080e7          	jalr	-910(ra) # e70 <fork>
      if(pid2 == 0){
     206:	7c050363          	beqz	a0,9cc <go+0x954>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     20a:	08054fe3          	bltz	a0,aa8 <go+0xa30>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     20e:	f9842503          	lw	a0,-104(s0)
     212:	00001097          	auipc	ra,0x1
     216:	c8e080e7          	jalr	-882(ra) # ea0 <close>
      close(aa[1]);
     21a:	f9c42503          	lw	a0,-100(s0)
     21e:	00001097          	auipc	ra,0x1
     222:	c82080e7          	jalr	-894(ra) # ea0 <close>
      close(bb[1]);
     226:	fa442503          	lw	a0,-92(s0)
     22a:	00001097          	auipc	ra,0x1
     22e:	c76080e7          	jalr	-906(ra) # ea0 <close>
      char buf[4] = { 0, 0, 0, 0 };
     232:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     236:	4605                	li	a2,1
     238:	f9040593          	addi	a1,s0,-112
     23c:	fa042503          	lw	a0,-96(s0)
     240:	00001097          	auipc	ra,0x1
     244:	c50080e7          	jalr	-944(ra) # e90 <read>
      read(bb[0], buf+1, 1);
     248:	4605                	li	a2,1
     24a:	f9140593          	addi	a1,s0,-111
     24e:	fa042503          	lw	a0,-96(s0)
     252:	00001097          	auipc	ra,0x1
     256:	c3e080e7          	jalr	-962(ra) # e90 <read>
      read(bb[0], buf+2, 1);
     25a:	4605                	li	a2,1
     25c:	f9240593          	addi	a1,s0,-110
     260:	fa042503          	lw	a0,-96(s0)
     264:	00001097          	auipc	ra,0x1
     268:	c2c080e7          	jalr	-980(ra) # e90 <read>
      close(bb[0]);
     26c:	fa042503          	lw	a0,-96(s0)
     270:	00001097          	auipc	ra,0x1
     274:	c30080e7          	jalr	-976(ra) # ea0 <close>
      int st1, st2;
      wait(&st1);
     278:	f9440513          	addi	a0,s0,-108
     27c:	00001097          	auipc	ra,0x1
     280:	c04080e7          	jalr	-1020(ra) # e80 <wait>
      wait(&st2);
     284:	fa840513          	addi	a0,s0,-88
     288:	00001097          	auipc	ra,0x1
     28c:	bf8080e7          	jalr	-1032(ra) # e80 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     290:	f9442783          	lw	a5,-108(s0)
     294:	fa842703          	lw	a4,-88(s0)
     298:	8fd9                	or	a5,a5,a4
     29a:	2781                	sext.w	a5,a5
     29c:	ef89                	bnez	a5,2b6 <go+0x23e>
     29e:	00001597          	auipc	a1,0x1
     2a2:	3ca58593          	addi	a1,a1,970 # 1668 <malloc+0x3a2>
     2a6:	f9040513          	addi	a0,s0,-112
     2aa:	00001097          	auipc	ra,0x1
     2ae:	97c080e7          	jalr	-1668(ra) # c26 <strcmp>
     2b2:	e60508e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2b6:	f9040693          	addi	a3,s0,-112
     2ba:	fa842603          	lw	a2,-88(s0)
     2be:	f9442583          	lw	a1,-108(s0)
     2c2:	00001517          	auipc	a0,0x1
     2c6:	3ae50513          	addi	a0,a0,942 # 1670 <malloc+0x3aa>
     2ca:	00001097          	auipc	ra,0x1
     2ce:	f3e080e7          	jalr	-194(ra) # 1208 <printf>
        exit(1);
     2d2:	4505                	li	a0,1
     2d4:	00001097          	auipc	ra,0x1
     2d8:	ba4080e7          	jalr	-1116(ra) # e78 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2dc:	20200593          	li	a1,514
     2e0:	00001517          	auipc	a0,0x1
     2e4:	12050513          	addi	a0,a0,288 # 1400 <malloc+0x13a>
     2e8:	00001097          	auipc	ra,0x1
     2ec:	bd0080e7          	jalr	-1072(ra) # eb8 <open>
     2f0:	00001097          	auipc	ra,0x1
     2f4:	bb0080e7          	jalr	-1104(ra) # ea0 <close>
     2f8:	b52d                	j	122 <go+0xaa>
      unlink("grindir/../a");
     2fa:	00001517          	auipc	a0,0x1
     2fe:	0f650513          	addi	a0,a0,246 # 13f0 <malloc+0x12a>
     302:	00001097          	auipc	ra,0x1
     306:	bc6080e7          	jalr	-1082(ra) # ec8 <unlink>
     30a:	bd21                	j	122 <go+0xaa>
      if(chdir("grindir") != 0){
     30c:	00001517          	auipc	a0,0x1
     310:	0a450513          	addi	a0,a0,164 # 13b0 <malloc+0xea>
     314:	00001097          	auipc	ra,0x1
     318:	bd4080e7          	jalr	-1068(ra) # ee8 <chdir>
     31c:	e115                	bnez	a0,340 <go+0x2c8>
      unlink("../b");
     31e:	00001517          	auipc	a0,0x1
     322:	0fa50513          	addi	a0,a0,250 # 1418 <malloc+0x152>
     326:	00001097          	auipc	ra,0x1
     32a:	ba2080e7          	jalr	-1118(ra) # ec8 <unlink>
      chdir("/");
     32e:	00001517          	auipc	a0,0x1
     332:	0aa50513          	addi	a0,a0,170 # 13d8 <malloc+0x112>
     336:	00001097          	auipc	ra,0x1
     33a:	bb2080e7          	jalr	-1102(ra) # ee8 <chdir>
     33e:	b3d5                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     340:	00001517          	auipc	a0,0x1
     344:	07850513          	addi	a0,a0,120 # 13b8 <malloc+0xf2>
     348:	00001097          	auipc	ra,0x1
     34c:	ec0080e7          	jalr	-320(ra) # 1208 <printf>
        exit(1);
     350:	4505                	li	a0,1
     352:	00001097          	auipc	ra,0x1
     356:	b26080e7          	jalr	-1242(ra) # e78 <exit>
      close(fd);
     35a:	854a                	mv	a0,s2
     35c:	00001097          	auipc	ra,0x1
     360:	b44080e7          	jalr	-1212(ra) # ea0 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     364:	20200593          	li	a1,514
     368:	00001517          	auipc	a0,0x1
     36c:	0b850513          	addi	a0,a0,184 # 1420 <malloc+0x15a>
     370:	00001097          	auipc	ra,0x1
     374:	b48080e7          	jalr	-1208(ra) # eb8 <open>
     378:	892a                	mv	s2,a0
     37a:	b365                	j	122 <go+0xaa>
      close(fd);
     37c:	854a                	mv	a0,s2
     37e:	00001097          	auipc	ra,0x1
     382:	b22080e7          	jalr	-1246(ra) # ea0 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     386:	20200593          	li	a1,514
     38a:	00001517          	auipc	a0,0x1
     38e:	0a650513          	addi	a0,a0,166 # 1430 <malloc+0x16a>
     392:	00001097          	auipc	ra,0x1
     396:	b26080e7          	jalr	-1242(ra) # eb8 <open>
     39a:	892a                	mv	s2,a0
     39c:	b359                	j	122 <go+0xaa>
      write(fd, buf, sizeof(buf));
     39e:	3e700613          	li	a2,999
     3a2:	85d2                	mv	a1,s4
     3a4:	854a                	mv	a0,s2
     3a6:	00001097          	auipc	ra,0x1
     3aa:	af2080e7          	jalr	-1294(ra) # e98 <write>
     3ae:	bb95                	j	122 <go+0xaa>
      read(fd, buf, sizeof(buf));
     3b0:	3e700613          	li	a2,999
     3b4:	85d2                	mv	a1,s4
     3b6:	854a                	mv	a0,s2
     3b8:	00001097          	auipc	ra,0x1
     3bc:	ad8080e7          	jalr	-1320(ra) # e90 <read>
     3c0:	b38d                	j	122 <go+0xaa>
      mkdir("grindir/../a");
     3c2:	00001517          	auipc	a0,0x1
     3c6:	02e50513          	addi	a0,a0,46 # 13f0 <malloc+0x12a>
     3ca:	00001097          	auipc	ra,0x1
     3ce:	b16080e7          	jalr	-1258(ra) # ee0 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3d2:	20200593          	li	a1,514
     3d6:	00001517          	auipc	a0,0x1
     3da:	07250513          	addi	a0,a0,114 # 1448 <malloc+0x182>
     3de:	00001097          	auipc	ra,0x1
     3e2:	ada080e7          	jalr	-1318(ra) # eb8 <open>
     3e6:	00001097          	auipc	ra,0x1
     3ea:	aba080e7          	jalr	-1350(ra) # ea0 <close>
      unlink("a/a");
     3ee:	00001517          	auipc	a0,0x1
     3f2:	06a50513          	addi	a0,a0,106 # 1458 <malloc+0x192>
     3f6:	00001097          	auipc	ra,0x1
     3fa:	ad2080e7          	jalr	-1326(ra) # ec8 <unlink>
     3fe:	b315                	j	122 <go+0xaa>
      mkdir("/../b");
     400:	00001517          	auipc	a0,0x1
     404:	06050513          	addi	a0,a0,96 # 1460 <malloc+0x19a>
     408:	00001097          	auipc	ra,0x1
     40c:	ad8080e7          	jalr	-1320(ra) # ee0 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     410:	20200593          	li	a1,514
     414:	00001517          	auipc	a0,0x1
     418:	05450513          	addi	a0,a0,84 # 1468 <malloc+0x1a2>
     41c:	00001097          	auipc	ra,0x1
     420:	a9c080e7          	jalr	-1380(ra) # eb8 <open>
     424:	00001097          	auipc	ra,0x1
     428:	a7c080e7          	jalr	-1412(ra) # ea0 <close>
      unlink("b/b");
     42c:	00001517          	auipc	a0,0x1
     430:	04c50513          	addi	a0,a0,76 # 1478 <malloc+0x1b2>
     434:	00001097          	auipc	ra,0x1
     438:	a94080e7          	jalr	-1388(ra) # ec8 <unlink>
     43c:	b1dd                	j	122 <go+0xaa>
      unlink("b");
     43e:	00001517          	auipc	a0,0x1
     442:	00250513          	addi	a0,a0,2 # 1440 <malloc+0x17a>
     446:	00001097          	auipc	ra,0x1
     44a:	a82080e7          	jalr	-1406(ra) # ec8 <unlink>
      link("../grindir/./../a", "../b");
     44e:	00001597          	auipc	a1,0x1
     452:	fca58593          	addi	a1,a1,-54 # 1418 <malloc+0x152>
     456:	00001517          	auipc	a0,0x1
     45a:	02a50513          	addi	a0,a0,42 # 1480 <malloc+0x1ba>
     45e:	00001097          	auipc	ra,0x1
     462:	a7a080e7          	jalr	-1414(ra) # ed8 <link>
     466:	b975                	j	122 <go+0xaa>
      unlink("../grindir/../a");
     468:	00001517          	auipc	a0,0x1
     46c:	03050513          	addi	a0,a0,48 # 1498 <malloc+0x1d2>
     470:	00001097          	auipc	ra,0x1
     474:	a58080e7          	jalr	-1448(ra) # ec8 <unlink>
      link(".././b", "/grindir/../a");
     478:	00001597          	auipc	a1,0x1
     47c:	fa858593          	addi	a1,a1,-88 # 1420 <malloc+0x15a>
     480:	00001517          	auipc	a0,0x1
     484:	02850513          	addi	a0,a0,40 # 14a8 <malloc+0x1e2>
     488:	00001097          	auipc	ra,0x1
     48c:	a50080e7          	jalr	-1456(ra) # ed8 <link>
     490:	b949                	j	122 <go+0xaa>
      int pid = fork();
     492:	00001097          	auipc	ra,0x1
     496:	9de080e7          	jalr	-1570(ra) # e70 <fork>
      if(pid == 0){
     49a:	c909                	beqz	a0,4ac <go+0x434>
      } else if(pid < 0){
     49c:	00054c63          	bltz	a0,4b4 <go+0x43c>
      wait(0);
     4a0:	4501                	li	a0,0
     4a2:	00001097          	auipc	ra,0x1
     4a6:	9de080e7          	jalr	-1570(ra) # e80 <wait>
     4aa:	b9a5                	j	122 <go+0xaa>
        exit(0);
     4ac:	00001097          	auipc	ra,0x1
     4b0:	9cc080e7          	jalr	-1588(ra) # e78 <exit>
        printf("grind: fork failed\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	ffc50513          	addi	a0,a0,-4 # 14b0 <malloc+0x1ea>
     4bc:	00001097          	auipc	ra,0x1
     4c0:	d4c080e7          	jalr	-692(ra) # 1208 <printf>
        exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00001097          	auipc	ra,0x1
     4ca:	9b2080e7          	jalr	-1614(ra) # e78 <exit>
      int pid = fork();
     4ce:	00001097          	auipc	ra,0x1
     4d2:	9a2080e7          	jalr	-1630(ra) # e70 <fork>
      if(pid == 0){
     4d6:	c909                	beqz	a0,4e8 <go+0x470>
      } else if(pid < 0){
     4d8:	02054563          	bltz	a0,502 <go+0x48a>
      wait(0);
     4dc:	4501                	li	a0,0
     4de:	00001097          	auipc	ra,0x1
     4e2:	9a2080e7          	jalr	-1630(ra) # e80 <wait>
     4e6:	b935                	j	122 <go+0xaa>
        fork();
     4e8:	00001097          	auipc	ra,0x1
     4ec:	988080e7          	jalr	-1656(ra) # e70 <fork>
        fork();
     4f0:	00001097          	auipc	ra,0x1
     4f4:	980080e7          	jalr	-1664(ra) # e70 <fork>
        exit(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	97e080e7          	jalr	-1666(ra) # e78 <exit>
        printf("grind: fork failed\n");
     502:	00001517          	auipc	a0,0x1
     506:	fae50513          	addi	a0,a0,-82 # 14b0 <malloc+0x1ea>
     50a:	00001097          	auipc	ra,0x1
     50e:	cfe080e7          	jalr	-770(ra) # 1208 <printf>
        exit(1);
     512:	4505                	li	a0,1
     514:	00001097          	auipc	ra,0x1
     518:	964080e7          	jalr	-1692(ra) # e78 <exit>
      sbrk(6011);
     51c:	6505                	lui	a0,0x1
     51e:	77b50513          	addi	a0,a0,1915 # 177b <buf.0+0xb3>
     522:	00001097          	auipc	ra,0x1
     526:	9de080e7          	jalr	-1570(ra) # f00 <sbrk>
     52a:	bee5                	j	122 <go+0xaa>
      if(sbrk(0) > break0)
     52c:	4501                	li	a0,0
     52e:	00001097          	auipc	ra,0x1
     532:	9d2080e7          	jalr	-1582(ra) # f00 <sbrk>
     536:	beaaf6e3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     53a:	4501                	li	a0,0
     53c:	00001097          	auipc	ra,0x1
     540:	9c4080e7          	jalr	-1596(ra) # f00 <sbrk>
     544:	40aa853b          	subw	a0,s5,a0
     548:	00001097          	auipc	ra,0x1
     54c:	9b8080e7          	jalr	-1608(ra) # f00 <sbrk>
     550:	bec9                	j	122 <go+0xaa>
      int pid = fork();
     552:	00001097          	auipc	ra,0x1
     556:	91e080e7          	jalr	-1762(ra) # e70 <fork>
     55a:	8b2a                	mv	s6,a0
      if(pid == 0){
     55c:	c51d                	beqz	a0,58a <go+0x512>
      } else if(pid < 0){
     55e:	04054963          	bltz	a0,5b0 <go+0x538>
      if(chdir("../grindir/..") != 0){
     562:	00001517          	auipc	a0,0x1
     566:	f6650513          	addi	a0,a0,-154 # 14c8 <malloc+0x202>
     56a:	00001097          	auipc	ra,0x1
     56e:	97e080e7          	jalr	-1666(ra) # ee8 <chdir>
     572:	ed21                	bnez	a0,5ca <go+0x552>
      kill(pid);
     574:	855a                	mv	a0,s6
     576:	00001097          	auipc	ra,0x1
     57a:	932080e7          	jalr	-1742(ra) # ea8 <kill>
      wait(0);
     57e:	4501                	li	a0,0
     580:	00001097          	auipc	ra,0x1
     584:	900080e7          	jalr	-1792(ra) # e80 <wait>
     588:	be69                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     58a:	20200593          	li	a1,514
     58e:	00001517          	auipc	a0,0x1
     592:	f0250513          	addi	a0,a0,-254 # 1490 <malloc+0x1ca>
     596:	00001097          	auipc	ra,0x1
     59a:	922080e7          	jalr	-1758(ra) # eb8 <open>
     59e:	00001097          	auipc	ra,0x1
     5a2:	902080e7          	jalr	-1790(ra) # ea0 <close>
        exit(0);
     5a6:	4501                	li	a0,0
     5a8:	00001097          	auipc	ra,0x1
     5ac:	8d0080e7          	jalr	-1840(ra) # e78 <exit>
        printf("grind: fork failed\n");
     5b0:	00001517          	auipc	a0,0x1
     5b4:	f0050513          	addi	a0,a0,-256 # 14b0 <malloc+0x1ea>
     5b8:	00001097          	auipc	ra,0x1
     5bc:	c50080e7          	jalr	-944(ra) # 1208 <printf>
        exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00001097          	auipc	ra,0x1
     5c6:	8b6080e7          	jalr	-1866(ra) # e78 <exit>
        printf("grind: chdir failed\n");
     5ca:	00001517          	auipc	a0,0x1
     5ce:	f0e50513          	addi	a0,a0,-242 # 14d8 <malloc+0x212>
     5d2:	00001097          	auipc	ra,0x1
     5d6:	c36080e7          	jalr	-970(ra) # 1208 <printf>
        exit(1);
     5da:	4505                	li	a0,1
     5dc:	00001097          	auipc	ra,0x1
     5e0:	89c080e7          	jalr	-1892(ra) # e78 <exit>
      int pid = fork();
     5e4:	00001097          	auipc	ra,0x1
     5e8:	88c080e7          	jalr	-1908(ra) # e70 <fork>
      if(pid == 0){
     5ec:	c909                	beqz	a0,5fe <go+0x586>
      } else if(pid < 0){
     5ee:	02054563          	bltz	a0,618 <go+0x5a0>
      wait(0);
     5f2:	4501                	li	a0,0
     5f4:	00001097          	auipc	ra,0x1
     5f8:	88c080e7          	jalr	-1908(ra) # e80 <wait>
     5fc:	b61d                	j	122 <go+0xaa>
        kill(getpid());
     5fe:	00001097          	auipc	ra,0x1
     602:	8fa080e7          	jalr	-1798(ra) # ef8 <getpid>
     606:	00001097          	auipc	ra,0x1
     60a:	8a2080e7          	jalr	-1886(ra) # ea8 <kill>
        exit(0);
     60e:	4501                	li	a0,0
     610:	00001097          	auipc	ra,0x1
     614:	868080e7          	jalr	-1944(ra) # e78 <exit>
        printf("grind: fork failed\n");
     618:	00001517          	auipc	a0,0x1
     61c:	e9850513          	addi	a0,a0,-360 # 14b0 <malloc+0x1ea>
     620:	00001097          	auipc	ra,0x1
     624:	be8080e7          	jalr	-1048(ra) # 1208 <printf>
        exit(1);
     628:	4505                	li	a0,1
     62a:	00001097          	auipc	ra,0x1
     62e:	84e080e7          	jalr	-1970(ra) # e78 <exit>
      if(pipe(fds) < 0){
     632:	fa840513          	addi	a0,s0,-88
     636:	00001097          	auipc	ra,0x1
     63a:	852080e7          	jalr	-1966(ra) # e88 <pipe>
     63e:	02054b63          	bltz	a0,674 <go+0x5fc>
      int pid = fork();
     642:	00001097          	auipc	ra,0x1
     646:	82e080e7          	jalr	-2002(ra) # e70 <fork>
      if(pid == 0){
     64a:	c131                	beqz	a0,68e <go+0x616>
      } else if(pid < 0){
     64c:	0a054a63          	bltz	a0,700 <go+0x688>
      close(fds[0]);
     650:	fa842503          	lw	a0,-88(s0)
     654:	00001097          	auipc	ra,0x1
     658:	84c080e7          	jalr	-1972(ra) # ea0 <close>
      close(fds[1]);
     65c:	fac42503          	lw	a0,-84(s0)
     660:	00001097          	auipc	ra,0x1
     664:	840080e7          	jalr	-1984(ra) # ea0 <close>
      wait(0);
     668:	4501                	li	a0,0
     66a:	00001097          	auipc	ra,0x1
     66e:	816080e7          	jalr	-2026(ra) # e80 <wait>
     672:	bc45                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     674:	00001517          	auipc	a0,0x1
     678:	e7c50513          	addi	a0,a0,-388 # 14f0 <malloc+0x22a>
     67c:	00001097          	auipc	ra,0x1
     680:	b8c080e7          	jalr	-1140(ra) # 1208 <printf>
        exit(1);
     684:	4505                	li	a0,1
     686:	00000097          	auipc	ra,0x0
     68a:	7f2080e7          	jalr	2034(ra) # e78 <exit>
        fork();
     68e:	00000097          	auipc	ra,0x0
     692:	7e2080e7          	jalr	2018(ra) # e70 <fork>
        fork();
     696:	00000097          	auipc	ra,0x0
     69a:	7da080e7          	jalr	2010(ra) # e70 <fork>
        if(write(fds[1], "x", 1) != 1)
     69e:	4605                	li	a2,1
     6a0:	00001597          	auipc	a1,0x1
     6a4:	e6858593          	addi	a1,a1,-408 # 1508 <malloc+0x242>
     6a8:	fac42503          	lw	a0,-84(s0)
     6ac:	00000097          	auipc	ra,0x0
     6b0:	7ec080e7          	jalr	2028(ra) # e98 <write>
     6b4:	4785                	li	a5,1
     6b6:	02f51363          	bne	a0,a5,6dc <go+0x664>
        if(read(fds[0], &c, 1) != 1)
     6ba:	4605                	li	a2,1
     6bc:	fa040593          	addi	a1,s0,-96
     6c0:	fa842503          	lw	a0,-88(s0)
     6c4:	00000097          	auipc	ra,0x0
     6c8:	7cc080e7          	jalr	1996(ra) # e90 <read>
     6cc:	4785                	li	a5,1
     6ce:	02f51063          	bne	a0,a5,6ee <go+0x676>
        exit(0);
     6d2:	4501                	li	a0,0
     6d4:	00000097          	auipc	ra,0x0
     6d8:	7a4080e7          	jalr	1956(ra) # e78 <exit>
          printf("grind: pipe write failed\n");
     6dc:	00001517          	auipc	a0,0x1
     6e0:	e3450513          	addi	a0,a0,-460 # 1510 <malloc+0x24a>
     6e4:	00001097          	auipc	ra,0x1
     6e8:	b24080e7          	jalr	-1244(ra) # 1208 <printf>
     6ec:	b7f9                	j	6ba <go+0x642>
          printf("grind: pipe read failed\n");
     6ee:	00001517          	auipc	a0,0x1
     6f2:	e4250513          	addi	a0,a0,-446 # 1530 <malloc+0x26a>
     6f6:	00001097          	auipc	ra,0x1
     6fa:	b12080e7          	jalr	-1262(ra) # 1208 <printf>
     6fe:	bfd1                	j	6d2 <go+0x65a>
        printf("grind: fork failed\n");
     700:	00001517          	auipc	a0,0x1
     704:	db050513          	addi	a0,a0,-592 # 14b0 <malloc+0x1ea>
     708:	00001097          	auipc	ra,0x1
     70c:	b00080e7          	jalr	-1280(ra) # 1208 <printf>
        exit(1);
     710:	4505                	li	a0,1
     712:	00000097          	auipc	ra,0x0
     716:	766080e7          	jalr	1894(ra) # e78 <exit>
      int pid = fork();
     71a:	00000097          	auipc	ra,0x0
     71e:	756080e7          	jalr	1878(ra) # e70 <fork>
      if(pid == 0){
     722:	c909                	beqz	a0,734 <go+0x6bc>
      } else if(pid < 0){
     724:	06054f63          	bltz	a0,7a2 <go+0x72a>
      wait(0);
     728:	4501                	li	a0,0
     72a:	00000097          	auipc	ra,0x0
     72e:	756080e7          	jalr	1878(ra) # e80 <wait>
     732:	bac5                	j	122 <go+0xaa>
        unlink("a");
     734:	00001517          	auipc	a0,0x1
     738:	d5c50513          	addi	a0,a0,-676 # 1490 <malloc+0x1ca>
     73c:	00000097          	auipc	ra,0x0
     740:	78c080e7          	jalr	1932(ra) # ec8 <unlink>
        mkdir("a");
     744:	00001517          	auipc	a0,0x1
     748:	d4c50513          	addi	a0,a0,-692 # 1490 <malloc+0x1ca>
     74c:	00000097          	auipc	ra,0x0
     750:	794080e7          	jalr	1940(ra) # ee0 <mkdir>
        chdir("a");
     754:	00001517          	auipc	a0,0x1
     758:	d3c50513          	addi	a0,a0,-708 # 1490 <malloc+0x1ca>
     75c:	00000097          	auipc	ra,0x0
     760:	78c080e7          	jalr	1932(ra) # ee8 <chdir>
        unlink("../a");
     764:	00001517          	auipc	a0,0x1
     768:	c9450513          	addi	a0,a0,-876 # 13f8 <malloc+0x132>
     76c:	00000097          	auipc	ra,0x0
     770:	75c080e7          	jalr	1884(ra) # ec8 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     774:	20200593          	li	a1,514
     778:	00001517          	auipc	a0,0x1
     77c:	d9050513          	addi	a0,a0,-624 # 1508 <malloc+0x242>
     780:	00000097          	auipc	ra,0x0
     784:	738080e7          	jalr	1848(ra) # eb8 <open>
        unlink("x");
     788:	00001517          	auipc	a0,0x1
     78c:	d8050513          	addi	a0,a0,-640 # 1508 <malloc+0x242>
     790:	00000097          	auipc	ra,0x0
     794:	738080e7          	jalr	1848(ra) # ec8 <unlink>
        exit(0);
     798:	4501                	li	a0,0
     79a:	00000097          	auipc	ra,0x0
     79e:	6de080e7          	jalr	1758(ra) # e78 <exit>
        printf("grind: fork failed\n");
     7a2:	00001517          	auipc	a0,0x1
     7a6:	d0e50513          	addi	a0,a0,-754 # 14b0 <malloc+0x1ea>
     7aa:	00001097          	auipc	ra,0x1
     7ae:	a5e080e7          	jalr	-1442(ra) # 1208 <printf>
        exit(1);
     7b2:	4505                	li	a0,1
     7b4:	00000097          	auipc	ra,0x0
     7b8:	6c4080e7          	jalr	1732(ra) # e78 <exit>
      unlink("c");
     7bc:	00001517          	auipc	a0,0x1
     7c0:	d9450513          	addi	a0,a0,-620 # 1550 <malloc+0x28a>
     7c4:	00000097          	auipc	ra,0x0
     7c8:	704080e7          	jalr	1796(ra) # ec8 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     7cc:	20200593          	li	a1,514
     7d0:	00001517          	auipc	a0,0x1
     7d4:	d8050513          	addi	a0,a0,-640 # 1550 <malloc+0x28a>
     7d8:	00000097          	auipc	ra,0x0
     7dc:	6e0080e7          	jalr	1760(ra) # eb8 <open>
     7e0:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     7e2:	04054f63          	bltz	a0,840 <go+0x7c8>
      if(write(fd1, "x", 1) != 1){
     7e6:	4605                	li	a2,1
     7e8:	00001597          	auipc	a1,0x1
     7ec:	d2058593          	addi	a1,a1,-736 # 1508 <malloc+0x242>
     7f0:	00000097          	auipc	ra,0x0
     7f4:	6a8080e7          	jalr	1704(ra) # e98 <write>
     7f8:	4785                	li	a5,1
     7fa:	06f51063          	bne	a0,a5,85a <go+0x7e2>
      if(fstat(fd1, &st) != 0){
     7fe:	fa840593          	addi	a1,s0,-88
     802:	855a                	mv	a0,s6
     804:	00000097          	auipc	ra,0x0
     808:	6cc080e7          	jalr	1740(ra) # ed0 <fstat>
     80c:	e525                	bnez	a0,874 <go+0x7fc>
      if(st.size != 1){
     80e:	fb843583          	ld	a1,-72(s0)
     812:	4785                	li	a5,1
     814:	06f59d63          	bne	a1,a5,88e <go+0x816>
      if(st.ino > 200){
     818:	fac42583          	lw	a1,-84(s0)
     81c:	0c800793          	li	a5,200
     820:	08b7e563          	bltu	a5,a1,8aa <go+0x832>
      close(fd1);
     824:	855a                	mv	a0,s6
     826:	00000097          	auipc	ra,0x0
     82a:	67a080e7          	jalr	1658(ra) # ea0 <close>
      unlink("c");
     82e:	00001517          	auipc	a0,0x1
     832:	d2250513          	addi	a0,a0,-734 # 1550 <malloc+0x28a>
     836:	00000097          	auipc	ra,0x0
     83a:	692080e7          	jalr	1682(ra) # ec8 <unlink>
     83e:	b0d5                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     840:	00001517          	auipc	a0,0x1
     844:	d1850513          	addi	a0,a0,-744 # 1558 <malloc+0x292>
     848:	00001097          	auipc	ra,0x1
     84c:	9c0080e7          	jalr	-1600(ra) # 1208 <printf>
        exit(1);
     850:	4505                	li	a0,1
     852:	00000097          	auipc	ra,0x0
     856:	626080e7          	jalr	1574(ra) # e78 <exit>
        printf("grind: write c failed\n");
     85a:	00001517          	auipc	a0,0x1
     85e:	d1650513          	addi	a0,a0,-746 # 1570 <malloc+0x2aa>
     862:	00001097          	auipc	ra,0x1
     866:	9a6080e7          	jalr	-1626(ra) # 1208 <printf>
        exit(1);
     86a:	4505                	li	a0,1
     86c:	00000097          	auipc	ra,0x0
     870:	60c080e7          	jalr	1548(ra) # e78 <exit>
        printf("grind: fstat failed\n");
     874:	00001517          	auipc	a0,0x1
     878:	d1450513          	addi	a0,a0,-748 # 1588 <malloc+0x2c2>
     87c:	00001097          	auipc	ra,0x1
     880:	98c080e7          	jalr	-1652(ra) # 1208 <printf>
        exit(1);
     884:	4505                	li	a0,1
     886:	00000097          	auipc	ra,0x0
     88a:	5f2080e7          	jalr	1522(ra) # e78 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     88e:	2581                	sext.w	a1,a1
     890:	00001517          	auipc	a0,0x1
     894:	d1050513          	addi	a0,a0,-752 # 15a0 <malloc+0x2da>
     898:	00001097          	auipc	ra,0x1
     89c:	970080e7          	jalr	-1680(ra) # 1208 <printf>
        exit(1);
     8a0:	4505                	li	a0,1
     8a2:	00000097          	auipc	ra,0x0
     8a6:	5d6080e7          	jalr	1494(ra) # e78 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     8aa:	00001517          	auipc	a0,0x1
     8ae:	d1e50513          	addi	a0,a0,-738 # 15c8 <malloc+0x302>
     8b2:	00001097          	auipc	ra,0x1
     8b6:	956080e7          	jalr	-1706(ra) # 1208 <printf>
        exit(1);
     8ba:	4505                	li	a0,1
     8bc:	00000097          	auipc	ra,0x0
     8c0:	5bc080e7          	jalr	1468(ra) # e78 <exit>
        fprintf(2, "grind: pipe failed\n");
     8c4:	00001597          	auipc	a1,0x1
     8c8:	c2c58593          	addi	a1,a1,-980 # 14f0 <malloc+0x22a>
     8cc:	4509                	li	a0,2
     8ce:	00001097          	auipc	ra,0x1
     8d2:	90c080e7          	jalr	-1780(ra) # 11da <fprintf>
        exit(1);
     8d6:	4505                	li	a0,1
     8d8:	00000097          	auipc	ra,0x0
     8dc:	5a0080e7          	jalr	1440(ra) # e78 <exit>
        fprintf(2, "grind: pipe failed\n");
     8e0:	00001597          	auipc	a1,0x1
     8e4:	c1058593          	addi	a1,a1,-1008 # 14f0 <malloc+0x22a>
     8e8:	4509                	li	a0,2
     8ea:	00001097          	auipc	ra,0x1
     8ee:	8f0080e7          	jalr	-1808(ra) # 11da <fprintf>
        exit(1);
     8f2:	4505                	li	a0,1
     8f4:	00000097          	auipc	ra,0x0
     8f8:	584080e7          	jalr	1412(ra) # e78 <exit>
        close(bb[0]);
     8fc:	fa042503          	lw	a0,-96(s0)
     900:	00000097          	auipc	ra,0x0
     904:	5a0080e7          	jalr	1440(ra) # ea0 <close>
        close(bb[1]);
     908:	fa442503          	lw	a0,-92(s0)
     90c:	00000097          	auipc	ra,0x0
     910:	594080e7          	jalr	1428(ra) # ea0 <close>
        close(aa[0]);
     914:	f9842503          	lw	a0,-104(s0)
     918:	00000097          	auipc	ra,0x0
     91c:	588080e7          	jalr	1416(ra) # ea0 <close>
        close(1);
     920:	4505                	li	a0,1
     922:	00000097          	auipc	ra,0x0
     926:	57e080e7          	jalr	1406(ra) # ea0 <close>
        if(dup(aa[1]) != 1){
     92a:	f9c42503          	lw	a0,-100(s0)
     92e:	00000097          	auipc	ra,0x0
     932:	5c2080e7          	jalr	1474(ra) # ef0 <dup>
     936:	4785                	li	a5,1
     938:	02f50063          	beq	a0,a5,958 <go+0x8e0>
          fprintf(2, "grind: dup failed\n");
     93c:	00001597          	auipc	a1,0x1
     940:	cb458593          	addi	a1,a1,-844 # 15f0 <malloc+0x32a>
     944:	4509                	li	a0,2
     946:	00001097          	auipc	ra,0x1
     94a:	894080e7          	jalr	-1900(ra) # 11da <fprintf>
          exit(1);
     94e:	4505                	li	a0,1
     950:	00000097          	auipc	ra,0x0
     954:	528080e7          	jalr	1320(ra) # e78 <exit>
        close(aa[1]);
     958:	f9c42503          	lw	a0,-100(s0)
     95c:	00000097          	auipc	ra,0x0
     960:	544080e7          	jalr	1348(ra) # ea0 <close>
        char *args[3] = { "echo", "hi", 0 };
     964:	00001797          	auipc	a5,0x1
     968:	ca478793          	addi	a5,a5,-860 # 1608 <malloc+0x342>
     96c:	faf43423          	sd	a5,-88(s0)
     970:	00001797          	auipc	a5,0x1
     974:	ca078793          	addi	a5,a5,-864 # 1610 <malloc+0x34a>
     978:	faf43823          	sd	a5,-80(s0)
     97c:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     980:	fa840593          	addi	a1,s0,-88
     984:	00001517          	auipc	a0,0x1
     988:	c9450513          	addi	a0,a0,-876 # 1618 <malloc+0x352>
     98c:	00000097          	auipc	ra,0x0
     990:	524080e7          	jalr	1316(ra) # eb0 <exec>
        fprintf(2, "grind: echo: not found\n");
     994:	00001597          	auipc	a1,0x1
     998:	c9458593          	addi	a1,a1,-876 # 1628 <malloc+0x362>
     99c:	4509                	li	a0,2
     99e:	00001097          	auipc	ra,0x1
     9a2:	83c080e7          	jalr	-1988(ra) # 11da <fprintf>
        exit(2);
     9a6:	4509                	li	a0,2
     9a8:	00000097          	auipc	ra,0x0
     9ac:	4d0080e7          	jalr	1232(ra) # e78 <exit>
        fprintf(2, "grind: fork failed\n");
     9b0:	00001597          	auipc	a1,0x1
     9b4:	b0058593          	addi	a1,a1,-1280 # 14b0 <malloc+0x1ea>
     9b8:	4509                	li	a0,2
     9ba:	00001097          	auipc	ra,0x1
     9be:	820080e7          	jalr	-2016(ra) # 11da <fprintf>
        exit(3);
     9c2:	450d                	li	a0,3
     9c4:	00000097          	auipc	ra,0x0
     9c8:	4b4080e7          	jalr	1204(ra) # e78 <exit>
        close(aa[1]);
     9cc:	f9c42503          	lw	a0,-100(s0)
     9d0:	00000097          	auipc	ra,0x0
     9d4:	4d0080e7          	jalr	1232(ra) # ea0 <close>
        close(bb[0]);
     9d8:	fa042503          	lw	a0,-96(s0)
     9dc:	00000097          	auipc	ra,0x0
     9e0:	4c4080e7          	jalr	1220(ra) # ea0 <close>
        close(0);
     9e4:	4501                	li	a0,0
     9e6:	00000097          	auipc	ra,0x0
     9ea:	4ba080e7          	jalr	1210(ra) # ea0 <close>
        if(dup(aa[0]) != 0){
     9ee:	f9842503          	lw	a0,-104(s0)
     9f2:	00000097          	auipc	ra,0x0
     9f6:	4fe080e7          	jalr	1278(ra) # ef0 <dup>
     9fa:	cd19                	beqz	a0,a18 <go+0x9a0>
          fprintf(2, "grind: dup failed\n");
     9fc:	00001597          	auipc	a1,0x1
     a00:	bf458593          	addi	a1,a1,-1036 # 15f0 <malloc+0x32a>
     a04:	4509                	li	a0,2
     a06:	00000097          	auipc	ra,0x0
     a0a:	7d4080e7          	jalr	2004(ra) # 11da <fprintf>
          exit(4);
     a0e:	4511                	li	a0,4
     a10:	00000097          	auipc	ra,0x0
     a14:	468080e7          	jalr	1128(ra) # e78 <exit>
        close(aa[0]);
     a18:	f9842503          	lw	a0,-104(s0)
     a1c:	00000097          	auipc	ra,0x0
     a20:	484080e7          	jalr	1156(ra) # ea0 <close>
        close(1);
     a24:	4505                	li	a0,1
     a26:	00000097          	auipc	ra,0x0
     a2a:	47a080e7          	jalr	1146(ra) # ea0 <close>
        if(dup(bb[1]) != 1){
     a2e:	fa442503          	lw	a0,-92(s0)
     a32:	00000097          	auipc	ra,0x0
     a36:	4be080e7          	jalr	1214(ra) # ef0 <dup>
     a3a:	4785                	li	a5,1
     a3c:	02f50063          	beq	a0,a5,a5c <go+0x9e4>
          fprintf(2, "grind: dup failed\n");
     a40:	00001597          	auipc	a1,0x1
     a44:	bb058593          	addi	a1,a1,-1104 # 15f0 <malloc+0x32a>
     a48:	4509                	li	a0,2
     a4a:	00000097          	auipc	ra,0x0
     a4e:	790080e7          	jalr	1936(ra) # 11da <fprintf>
          exit(5);
     a52:	4515                	li	a0,5
     a54:	00000097          	auipc	ra,0x0
     a58:	424080e7          	jalr	1060(ra) # e78 <exit>
        close(bb[1]);
     a5c:	fa442503          	lw	a0,-92(s0)
     a60:	00000097          	auipc	ra,0x0
     a64:	440080e7          	jalr	1088(ra) # ea0 <close>
        char *args[2] = { "cat", 0 };
     a68:	00001797          	auipc	a5,0x1
     a6c:	bd878793          	addi	a5,a5,-1064 # 1640 <malloc+0x37a>
     a70:	faf43423          	sd	a5,-88(s0)
     a74:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a78:	fa840593          	addi	a1,s0,-88
     a7c:	00001517          	auipc	a0,0x1
     a80:	bcc50513          	addi	a0,a0,-1076 # 1648 <malloc+0x382>
     a84:	00000097          	auipc	ra,0x0
     a88:	42c080e7          	jalr	1068(ra) # eb0 <exec>
        fprintf(2, "grind: cat: not found\n");
     a8c:	00001597          	auipc	a1,0x1
     a90:	bc458593          	addi	a1,a1,-1084 # 1650 <malloc+0x38a>
     a94:	4509                	li	a0,2
     a96:	00000097          	auipc	ra,0x0
     a9a:	744080e7          	jalr	1860(ra) # 11da <fprintf>
        exit(6);
     a9e:	4519                	li	a0,6
     aa0:	00000097          	auipc	ra,0x0
     aa4:	3d8080e7          	jalr	984(ra) # e78 <exit>
        fprintf(2, "grind: fork failed\n");
     aa8:	00001597          	auipc	a1,0x1
     aac:	a0858593          	addi	a1,a1,-1528 # 14b0 <malloc+0x1ea>
     ab0:	4509                	li	a0,2
     ab2:	00000097          	auipc	ra,0x0
     ab6:	728080e7          	jalr	1832(ra) # 11da <fprintf>
        exit(7);
     aba:	451d                	li	a0,7
     abc:	00000097          	auipc	ra,0x0
     ac0:	3bc080e7          	jalr	956(ra) # e78 <exit>

0000000000000ac4 <iter>:
  }
}

void
iter()
{
     ac4:	7179                	addi	sp,sp,-48
     ac6:	f406                	sd	ra,40(sp)
     ac8:	f022                	sd	s0,32(sp)
     aca:	ec26                	sd	s1,24(sp)
     acc:	e84a                	sd	s2,16(sp)
     ace:	1800                	addi	s0,sp,48
  unlink("a");
     ad0:	00001517          	auipc	a0,0x1
     ad4:	9c050513          	addi	a0,a0,-1600 # 1490 <malloc+0x1ca>
     ad8:	00000097          	auipc	ra,0x0
     adc:	3f0080e7          	jalr	1008(ra) # ec8 <unlink>
  unlink("b");
     ae0:	00001517          	auipc	a0,0x1
     ae4:	96050513          	addi	a0,a0,-1696 # 1440 <malloc+0x17a>
     ae8:	00000097          	auipc	ra,0x0
     aec:	3e0080e7          	jalr	992(ra) # ec8 <unlink>
  
  int pid1 = fork();
     af0:	00000097          	auipc	ra,0x0
     af4:	380080e7          	jalr	896(ra) # e70 <fork>
  if(pid1 < 0){
     af8:	00054e63          	bltz	a0,b14 <iter+0x50>
     afc:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     afe:	e905                	bnez	a0,b2e <iter+0x6a>
    rand_next = 31;
     b00:	47fd                	li	a5,31
     b02:	00001717          	auipc	a4,0x1
     b06:	baf73b23          	sd	a5,-1098(a4) # 16b8 <rand_next>
    go(0);
     b0a:	4501                	li	a0,0
     b0c:	fffff097          	auipc	ra,0xfffff
     b10:	56c080e7          	jalr	1388(ra) # 78 <go>
    printf("grind: fork failed\n");
     b14:	00001517          	auipc	a0,0x1
     b18:	99c50513          	addi	a0,a0,-1636 # 14b0 <malloc+0x1ea>
     b1c:	00000097          	auipc	ra,0x0
     b20:	6ec080e7          	jalr	1772(ra) # 1208 <printf>
    exit(1);
     b24:	4505                	li	a0,1
     b26:	00000097          	auipc	ra,0x0
     b2a:	352080e7          	jalr	850(ra) # e78 <exit>
    exit(0);
  }

  int pid2 = fork();
     b2e:	00000097          	auipc	ra,0x0
     b32:	342080e7          	jalr	834(ra) # e70 <fork>
     b36:	892a                	mv	s2,a0
  if(pid2 < 0){
     b38:	00054f63          	bltz	a0,b56 <iter+0x92>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     b3c:	e915                	bnez	a0,b70 <iter+0xac>
    rand_next = 7177;
     b3e:	6789                	lui	a5,0x2
     b40:	c0978793          	addi	a5,a5,-1015 # 1c09 <__BSS_END__+0x149>
     b44:	00001717          	auipc	a4,0x1
     b48:	b6f73a23          	sd	a5,-1164(a4) # 16b8 <rand_next>
    go(1);
     b4c:	4505                	li	a0,1
     b4e:	fffff097          	auipc	ra,0xfffff
     b52:	52a080e7          	jalr	1322(ra) # 78 <go>
    printf("grind: fork failed\n");
     b56:	00001517          	auipc	a0,0x1
     b5a:	95a50513          	addi	a0,a0,-1702 # 14b0 <malloc+0x1ea>
     b5e:	00000097          	auipc	ra,0x0
     b62:	6aa080e7          	jalr	1706(ra) # 1208 <printf>
    exit(1);
     b66:	4505                	li	a0,1
     b68:	00000097          	auipc	ra,0x0
     b6c:	310080e7          	jalr	784(ra) # e78 <exit>
    exit(0);
  }

  int st1 = -1;
     b70:	57fd                	li	a5,-1
     b72:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b76:	fdc40513          	addi	a0,s0,-36
     b7a:	00000097          	auipc	ra,0x0
     b7e:	306080e7          	jalr	774(ra) # e80 <wait>
  if(st1 != 0){
     b82:	fdc42783          	lw	a5,-36(s0)
     b86:	ef99                	bnez	a5,ba4 <iter+0xe0>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b88:	57fd                	li	a5,-1
     b8a:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b8e:	fd840513          	addi	a0,s0,-40
     b92:	00000097          	auipc	ra,0x0
     b96:	2ee080e7          	jalr	750(ra) # e80 <wait>

  exit(0);
     b9a:	4501                	li	a0,0
     b9c:	00000097          	auipc	ra,0x0
     ba0:	2dc080e7          	jalr	732(ra) # e78 <exit>
    kill(pid1);
     ba4:	8526                	mv	a0,s1
     ba6:	00000097          	auipc	ra,0x0
     baa:	302080e7          	jalr	770(ra) # ea8 <kill>
    kill(pid2);
     bae:	854a                	mv	a0,s2
     bb0:	00000097          	auipc	ra,0x0
     bb4:	2f8080e7          	jalr	760(ra) # ea8 <kill>
     bb8:	bfc1                	j	b88 <iter+0xc4>

0000000000000bba <main>:
}

int
main()
{
     bba:	1141                	addi	sp,sp,-16
     bbc:	e406                	sd	ra,8(sp)
     bbe:	e022                	sd	s0,0(sp)
     bc0:	0800                	addi	s0,sp,16
     bc2:	a811                	j	bd6 <main+0x1c>
  while(1){
    int pid = fork();
    if(pid == 0){
      iter();
     bc4:	00000097          	auipc	ra,0x0
     bc8:	f00080e7          	jalr	-256(ra) # ac4 <iter>
      exit(0);
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
     bcc:	4551                	li	a0,20
     bce:	00000097          	auipc	ra,0x0
     bd2:	33a080e7          	jalr	826(ra) # f08 <sleep>
    int pid = fork();
     bd6:	00000097          	auipc	ra,0x0
     bda:	29a080e7          	jalr	666(ra) # e70 <fork>
    if(pid == 0){
     bde:	d17d                	beqz	a0,bc4 <main+0xa>
    if(pid > 0){
     be0:	fea056e3          	blez	a0,bcc <main+0x12>
      wait(0);
     be4:	4501                	li	a0,0
     be6:	00000097          	auipc	ra,0x0
     bea:	29a080e7          	jalr	666(ra) # e80 <wait>
     bee:	bff9                	j	bcc <main+0x12>

0000000000000bf0 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     bf0:	1141                	addi	sp,sp,-16
     bf2:	e406                	sd	ra,8(sp)
     bf4:	e022                	sd	s0,0(sp)
     bf6:	0800                	addi	s0,sp,16
  extern int main();
  main();
     bf8:	00000097          	auipc	ra,0x0
     bfc:	fc2080e7          	jalr	-62(ra) # bba <main>
  exit(0);
     c00:	4501                	li	a0,0
     c02:	00000097          	auipc	ra,0x0
     c06:	276080e7          	jalr	630(ra) # e78 <exit>

0000000000000c0a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     c0a:	1141                	addi	sp,sp,-16
     c0c:	e422                	sd	s0,8(sp)
     c0e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c10:	87aa                	mv	a5,a0
     c12:	0585                	addi	a1,a1,1
     c14:	0785                	addi	a5,a5,1
     c16:	fff5c703          	lbu	a4,-1(a1)
     c1a:	fee78fa3          	sb	a4,-1(a5)
     c1e:	fb75                	bnez	a4,c12 <strcpy+0x8>
    ;
  return os;
}
     c20:	6422                	ld	s0,8(sp)
     c22:	0141                	addi	sp,sp,16
     c24:	8082                	ret

0000000000000c26 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c26:	1141                	addi	sp,sp,-16
     c28:	e422                	sd	s0,8(sp)
     c2a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c2c:	00054783          	lbu	a5,0(a0)
     c30:	cb91                	beqz	a5,c44 <strcmp+0x1e>
     c32:	0005c703          	lbu	a4,0(a1)
     c36:	00f71763          	bne	a4,a5,c44 <strcmp+0x1e>
    p++, q++;
     c3a:	0505                	addi	a0,a0,1
     c3c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c3e:	00054783          	lbu	a5,0(a0)
     c42:	fbe5                	bnez	a5,c32 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c44:	0005c503          	lbu	a0,0(a1)
}
     c48:	40a7853b          	subw	a0,a5,a0
     c4c:	6422                	ld	s0,8(sp)
     c4e:	0141                	addi	sp,sp,16
     c50:	8082                	ret

0000000000000c52 <strlen>:

uint
strlen(const char *s)
{
     c52:	1141                	addi	sp,sp,-16
     c54:	e422                	sd	s0,8(sp)
     c56:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c58:	00054783          	lbu	a5,0(a0)
     c5c:	cf91                	beqz	a5,c78 <strlen+0x26>
     c5e:	0505                	addi	a0,a0,1
     c60:	87aa                	mv	a5,a0
     c62:	4685                	li	a3,1
     c64:	9e89                	subw	a3,a3,a0
     c66:	00f6853b          	addw	a0,a3,a5
     c6a:	0785                	addi	a5,a5,1
     c6c:	fff7c703          	lbu	a4,-1(a5)
     c70:	fb7d                	bnez	a4,c66 <strlen+0x14>
    ;
  return n;
}
     c72:	6422                	ld	s0,8(sp)
     c74:	0141                	addi	sp,sp,16
     c76:	8082                	ret
  for(n = 0; s[n]; n++)
     c78:	4501                	li	a0,0
     c7a:	bfe5                	j	c72 <strlen+0x20>

0000000000000c7c <memset>:

void*
memset(void *dst, int c, uint n)
{
     c7c:	1141                	addi	sp,sp,-16
     c7e:	e422                	sd	s0,8(sp)
     c80:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c82:	ca19                	beqz	a2,c98 <memset+0x1c>
     c84:	87aa                	mv	a5,a0
     c86:	1602                	slli	a2,a2,0x20
     c88:	9201                	srli	a2,a2,0x20
     c8a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c8e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c92:	0785                	addi	a5,a5,1
     c94:	fee79de3          	bne	a5,a4,c8e <memset+0x12>
  }
  return dst;
}
     c98:	6422                	ld	s0,8(sp)
     c9a:	0141                	addi	sp,sp,16
     c9c:	8082                	ret

0000000000000c9e <strchr>:

char*
strchr(const char *s, char c)
{
     c9e:	1141                	addi	sp,sp,-16
     ca0:	e422                	sd	s0,8(sp)
     ca2:	0800                	addi	s0,sp,16
  for(; *s; s++)
     ca4:	00054783          	lbu	a5,0(a0)
     ca8:	cb99                	beqz	a5,cbe <strchr+0x20>
    if(*s == c)
     caa:	00f58763          	beq	a1,a5,cb8 <strchr+0x1a>
  for(; *s; s++)
     cae:	0505                	addi	a0,a0,1
     cb0:	00054783          	lbu	a5,0(a0)
     cb4:	fbfd                	bnez	a5,caa <strchr+0xc>
      return (char*)s;
  return 0;
     cb6:	4501                	li	a0,0
}
     cb8:	6422                	ld	s0,8(sp)
     cba:	0141                	addi	sp,sp,16
     cbc:	8082                	ret
  return 0;
     cbe:	4501                	li	a0,0
     cc0:	bfe5                	j	cb8 <strchr+0x1a>

0000000000000cc2 <gets>:

char*
gets(char *buf, int max)
{
     cc2:	711d                	addi	sp,sp,-96
     cc4:	ec86                	sd	ra,88(sp)
     cc6:	e8a2                	sd	s0,80(sp)
     cc8:	e4a6                	sd	s1,72(sp)
     cca:	e0ca                	sd	s2,64(sp)
     ccc:	fc4e                	sd	s3,56(sp)
     cce:	f852                	sd	s4,48(sp)
     cd0:	f456                	sd	s5,40(sp)
     cd2:	f05a                	sd	s6,32(sp)
     cd4:	ec5e                	sd	s7,24(sp)
     cd6:	1080                	addi	s0,sp,96
     cd8:	8baa                	mv	s7,a0
     cda:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cdc:	892a                	mv	s2,a0
     cde:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     ce0:	4aa9                	li	s5,10
     ce2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     ce4:	89a6                	mv	s3,s1
     ce6:	2485                	addiw	s1,s1,1
     ce8:	0344d863          	bge	s1,s4,d18 <gets+0x56>
    cc = read(0, &c, 1);
     cec:	4605                	li	a2,1
     cee:	faf40593          	addi	a1,s0,-81
     cf2:	4501                	li	a0,0
     cf4:	00000097          	auipc	ra,0x0
     cf8:	19c080e7          	jalr	412(ra) # e90 <read>
    if(cc < 1)
     cfc:	00a05e63          	blez	a0,d18 <gets+0x56>
    buf[i++] = c;
     d00:	faf44783          	lbu	a5,-81(s0)
     d04:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d08:	01578763          	beq	a5,s5,d16 <gets+0x54>
     d0c:	0905                	addi	s2,s2,1
     d0e:	fd679be3          	bne	a5,s6,ce4 <gets+0x22>
  for(i=0; i+1 < max; ){
     d12:	89a6                	mv	s3,s1
     d14:	a011                	j	d18 <gets+0x56>
     d16:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d18:	99de                	add	s3,s3,s7
     d1a:	00098023          	sb	zero,0(s3)
  return buf;
}
     d1e:	855e                	mv	a0,s7
     d20:	60e6                	ld	ra,88(sp)
     d22:	6446                	ld	s0,80(sp)
     d24:	64a6                	ld	s1,72(sp)
     d26:	6906                	ld	s2,64(sp)
     d28:	79e2                	ld	s3,56(sp)
     d2a:	7a42                	ld	s4,48(sp)
     d2c:	7aa2                	ld	s5,40(sp)
     d2e:	7b02                	ld	s6,32(sp)
     d30:	6be2                	ld	s7,24(sp)
     d32:	6125                	addi	sp,sp,96
     d34:	8082                	ret

0000000000000d36 <stat>:

int
stat(const char *n, struct stat *st)
{
     d36:	1101                	addi	sp,sp,-32
     d38:	ec06                	sd	ra,24(sp)
     d3a:	e822                	sd	s0,16(sp)
     d3c:	e426                	sd	s1,8(sp)
     d3e:	e04a                	sd	s2,0(sp)
     d40:	1000                	addi	s0,sp,32
     d42:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d44:	4581                	li	a1,0
     d46:	00000097          	auipc	ra,0x0
     d4a:	172080e7          	jalr	370(ra) # eb8 <open>
  if(fd < 0)
     d4e:	02054563          	bltz	a0,d78 <stat+0x42>
     d52:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d54:	85ca                	mv	a1,s2
     d56:	00000097          	auipc	ra,0x0
     d5a:	17a080e7          	jalr	378(ra) # ed0 <fstat>
     d5e:	892a                	mv	s2,a0
  close(fd);
     d60:	8526                	mv	a0,s1
     d62:	00000097          	auipc	ra,0x0
     d66:	13e080e7          	jalr	318(ra) # ea0 <close>
  return r;
}
     d6a:	854a                	mv	a0,s2
     d6c:	60e2                	ld	ra,24(sp)
     d6e:	6442                	ld	s0,16(sp)
     d70:	64a2                	ld	s1,8(sp)
     d72:	6902                	ld	s2,0(sp)
     d74:	6105                	addi	sp,sp,32
     d76:	8082                	ret
    return -1;
     d78:	597d                	li	s2,-1
     d7a:	bfc5                	j	d6a <stat+0x34>

0000000000000d7c <atoi>:

int
atoi(const char *s)
{
     d7c:	1141                	addi	sp,sp,-16
     d7e:	e422                	sd	s0,8(sp)
     d80:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d82:	00054603          	lbu	a2,0(a0)
     d86:	fd06079b          	addiw	a5,a2,-48
     d8a:	0ff7f793          	andi	a5,a5,255
     d8e:	4725                	li	a4,9
     d90:	02f76963          	bltu	a4,a5,dc2 <atoi+0x46>
     d94:	86aa                	mv	a3,a0
  n = 0;
     d96:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d98:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d9a:	0685                	addi	a3,a3,1
     d9c:	0025179b          	slliw	a5,a0,0x2
     da0:	9fa9                	addw	a5,a5,a0
     da2:	0017979b          	slliw	a5,a5,0x1
     da6:	9fb1                	addw	a5,a5,a2
     da8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     dac:	0006c603          	lbu	a2,0(a3)
     db0:	fd06071b          	addiw	a4,a2,-48
     db4:	0ff77713          	andi	a4,a4,255
     db8:	fee5f1e3          	bgeu	a1,a4,d9a <atoi+0x1e>
  return n;
}
     dbc:	6422                	ld	s0,8(sp)
     dbe:	0141                	addi	sp,sp,16
     dc0:	8082                	ret
  n = 0;
     dc2:	4501                	li	a0,0
     dc4:	bfe5                	j	dbc <atoi+0x40>

0000000000000dc6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     dc6:	1141                	addi	sp,sp,-16
     dc8:	e422                	sd	s0,8(sp)
     dca:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     dcc:	02b57463          	bgeu	a0,a1,df4 <memmove+0x2e>
    while(n-- > 0)
     dd0:	00c05f63          	blez	a2,dee <memmove+0x28>
     dd4:	1602                	slli	a2,a2,0x20
     dd6:	9201                	srli	a2,a2,0x20
     dd8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     ddc:	872a                	mv	a4,a0
      *dst++ = *src++;
     dde:	0585                	addi	a1,a1,1
     de0:	0705                	addi	a4,a4,1
     de2:	fff5c683          	lbu	a3,-1(a1)
     de6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     dea:	fee79ae3          	bne	a5,a4,dde <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     dee:	6422                	ld	s0,8(sp)
     df0:	0141                	addi	sp,sp,16
     df2:	8082                	ret
    dst += n;
     df4:	00c50733          	add	a4,a0,a2
    src += n;
     df8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     dfa:	fec05ae3          	blez	a2,dee <memmove+0x28>
     dfe:	fff6079b          	addiw	a5,a2,-1
     e02:	1782                	slli	a5,a5,0x20
     e04:	9381                	srli	a5,a5,0x20
     e06:	fff7c793          	not	a5,a5
     e0a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e0c:	15fd                	addi	a1,a1,-1
     e0e:	177d                	addi	a4,a4,-1
     e10:	0005c683          	lbu	a3,0(a1)
     e14:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e18:	fee79ae3          	bne	a5,a4,e0c <memmove+0x46>
     e1c:	bfc9                	j	dee <memmove+0x28>

0000000000000e1e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e1e:	1141                	addi	sp,sp,-16
     e20:	e422                	sd	s0,8(sp)
     e22:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e24:	ca05                	beqz	a2,e54 <memcmp+0x36>
     e26:	fff6069b          	addiw	a3,a2,-1
     e2a:	1682                	slli	a3,a3,0x20
     e2c:	9281                	srli	a3,a3,0x20
     e2e:	0685                	addi	a3,a3,1
     e30:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e32:	00054783          	lbu	a5,0(a0)
     e36:	0005c703          	lbu	a4,0(a1)
     e3a:	00e79863          	bne	a5,a4,e4a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e3e:	0505                	addi	a0,a0,1
    p2++;
     e40:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e42:	fed518e3          	bne	a0,a3,e32 <memcmp+0x14>
  }
  return 0;
     e46:	4501                	li	a0,0
     e48:	a019                	j	e4e <memcmp+0x30>
      return *p1 - *p2;
     e4a:	40e7853b          	subw	a0,a5,a4
}
     e4e:	6422                	ld	s0,8(sp)
     e50:	0141                	addi	sp,sp,16
     e52:	8082                	ret
  return 0;
     e54:	4501                	li	a0,0
     e56:	bfe5                	j	e4e <memcmp+0x30>

0000000000000e58 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e58:	1141                	addi	sp,sp,-16
     e5a:	e406                	sd	ra,8(sp)
     e5c:	e022                	sd	s0,0(sp)
     e5e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e60:	00000097          	auipc	ra,0x0
     e64:	f66080e7          	jalr	-154(ra) # dc6 <memmove>
}
     e68:	60a2                	ld	ra,8(sp)
     e6a:	6402                	ld	s0,0(sp)
     e6c:	0141                	addi	sp,sp,16
     e6e:	8082                	ret

0000000000000e70 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e70:	4885                	li	a7,1
 ecall
     e72:	00000073          	ecall
 ret
     e76:	8082                	ret

0000000000000e78 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e78:	4889                	li	a7,2
 ecall
     e7a:	00000073          	ecall
 ret
     e7e:	8082                	ret

0000000000000e80 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e80:	488d                	li	a7,3
 ecall
     e82:	00000073          	ecall
 ret
     e86:	8082                	ret

0000000000000e88 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e88:	4891                	li	a7,4
 ecall
     e8a:	00000073          	ecall
 ret
     e8e:	8082                	ret

0000000000000e90 <read>:
.global read
read:
 li a7, SYS_read
     e90:	4895                	li	a7,5
 ecall
     e92:	00000073          	ecall
 ret
     e96:	8082                	ret

0000000000000e98 <write>:
.global write
write:
 li a7, SYS_write
     e98:	48c1                	li	a7,16
 ecall
     e9a:	00000073          	ecall
 ret
     e9e:	8082                	ret

0000000000000ea0 <close>:
.global close
close:
 li a7, SYS_close
     ea0:	48d5                	li	a7,21
 ecall
     ea2:	00000073          	ecall
 ret
     ea6:	8082                	ret

0000000000000ea8 <kill>:
.global kill
kill:
 li a7, SYS_kill
     ea8:	4899                	li	a7,6
 ecall
     eaa:	00000073          	ecall
 ret
     eae:	8082                	ret

0000000000000eb0 <exec>:
.global exec
exec:
 li a7, SYS_exec
     eb0:	489d                	li	a7,7
 ecall
     eb2:	00000073          	ecall
 ret
     eb6:	8082                	ret

0000000000000eb8 <open>:
.global open
open:
 li a7, SYS_open
     eb8:	48bd                	li	a7,15
 ecall
     eba:	00000073          	ecall
 ret
     ebe:	8082                	ret

0000000000000ec0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ec0:	48c5                	li	a7,17
 ecall
     ec2:	00000073          	ecall
 ret
     ec6:	8082                	ret

0000000000000ec8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ec8:	48c9                	li	a7,18
 ecall
     eca:	00000073          	ecall
 ret
     ece:	8082                	ret

0000000000000ed0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ed0:	48a1                	li	a7,8
 ecall
     ed2:	00000073          	ecall
 ret
     ed6:	8082                	ret

0000000000000ed8 <link>:
.global link
link:
 li a7, SYS_link
     ed8:	48cd                	li	a7,19
 ecall
     eda:	00000073          	ecall
 ret
     ede:	8082                	ret

0000000000000ee0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     ee0:	48d1                	li	a7,20
 ecall
     ee2:	00000073          	ecall
 ret
     ee6:	8082                	ret

0000000000000ee8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ee8:	48a5                	li	a7,9
 ecall
     eea:	00000073          	ecall
 ret
     eee:	8082                	ret

0000000000000ef0 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ef0:	48a9                	li	a7,10
 ecall
     ef2:	00000073          	ecall
 ret
     ef6:	8082                	ret

0000000000000ef8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ef8:	48ad                	li	a7,11
 ecall
     efa:	00000073          	ecall
 ret
     efe:	8082                	ret

0000000000000f00 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f00:	48b1                	li	a7,12
 ecall
     f02:	00000073          	ecall
 ret
     f06:	8082                	ret

0000000000000f08 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f08:	48b5                	li	a7,13
 ecall
     f0a:	00000073          	ecall
 ret
     f0e:	8082                	ret

0000000000000f10 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f10:	48b9                	li	a7,14
 ecall
     f12:	00000073          	ecall
 ret
     f16:	8082                	ret

0000000000000f18 <startlog>:
.global startlog
startlog:
 li a7, SYS_startlog
     f18:	48d9                	li	a7,22
 ecall
     f1a:	00000073          	ecall
 ret
     f1e:	8082                	ret

0000000000000f20 <getlog>:
.global getlog
getlog:
 li a7, SYS_getlog
     f20:	48dd                	li	a7,23
 ecall
     f22:	00000073          	ecall
 ret
     f26:	8082                	ret

0000000000000f28 <nice>:
.global nice
nice:
 li a7, SYS_nice
     f28:	48e1                	li	a7,24
 ecall
     f2a:	00000073          	ecall
 ret
     f2e:	8082                	ret

0000000000000f30 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f30:	1101                	addi	sp,sp,-32
     f32:	ec06                	sd	ra,24(sp)
     f34:	e822                	sd	s0,16(sp)
     f36:	1000                	addi	s0,sp,32
     f38:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f3c:	4605                	li	a2,1
     f3e:	fef40593          	addi	a1,s0,-17
     f42:	00000097          	auipc	ra,0x0
     f46:	f56080e7          	jalr	-170(ra) # e98 <write>
}
     f4a:	60e2                	ld	ra,24(sp)
     f4c:	6442                	ld	s0,16(sp)
     f4e:	6105                	addi	sp,sp,32
     f50:	8082                	ret

0000000000000f52 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f52:	7139                	addi	sp,sp,-64
     f54:	fc06                	sd	ra,56(sp)
     f56:	f822                	sd	s0,48(sp)
     f58:	f426                	sd	s1,40(sp)
     f5a:	f04a                	sd	s2,32(sp)
     f5c:	ec4e                	sd	s3,24(sp)
     f5e:	0080                	addi	s0,sp,64
     f60:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f62:	c299                	beqz	a3,f68 <printint+0x16>
     f64:	0805c863          	bltz	a1,ff4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f68:	2581                	sext.w	a1,a1
  neg = 0;
     f6a:	4881                	li	a7,0
     f6c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f70:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f72:	2601                	sext.w	a2,a2
     f74:	00000517          	auipc	a0,0x0
     f78:	72c50513          	addi	a0,a0,1836 # 16a0 <digits>
     f7c:	883a                	mv	a6,a4
     f7e:	2705                	addiw	a4,a4,1
     f80:	02c5f7bb          	remuw	a5,a1,a2
     f84:	1782                	slli	a5,a5,0x20
     f86:	9381                	srli	a5,a5,0x20
     f88:	97aa                	add	a5,a5,a0
     f8a:	0007c783          	lbu	a5,0(a5)
     f8e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f92:	0005879b          	sext.w	a5,a1
     f96:	02c5d5bb          	divuw	a1,a1,a2
     f9a:	0685                	addi	a3,a3,1
     f9c:	fec7f0e3          	bgeu	a5,a2,f7c <printint+0x2a>
  if(neg)
     fa0:	00088b63          	beqz	a7,fb6 <printint+0x64>
    buf[i++] = '-';
     fa4:	fd040793          	addi	a5,s0,-48
     fa8:	973e                	add	a4,a4,a5
     faa:	02d00793          	li	a5,45
     fae:	fef70823          	sb	a5,-16(a4)
     fb2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     fb6:	02e05863          	blez	a4,fe6 <printint+0x94>
     fba:	fc040793          	addi	a5,s0,-64
     fbe:	00e78933          	add	s2,a5,a4
     fc2:	fff78993          	addi	s3,a5,-1
     fc6:	99ba                	add	s3,s3,a4
     fc8:	377d                	addiw	a4,a4,-1
     fca:	1702                	slli	a4,a4,0x20
     fcc:	9301                	srli	a4,a4,0x20
     fce:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fd2:	fff94583          	lbu	a1,-1(s2)
     fd6:	8526                	mv	a0,s1
     fd8:	00000097          	auipc	ra,0x0
     fdc:	f58080e7          	jalr	-168(ra) # f30 <putc>
  while(--i >= 0)
     fe0:	197d                	addi	s2,s2,-1
     fe2:	ff3918e3          	bne	s2,s3,fd2 <printint+0x80>
}
     fe6:	70e2                	ld	ra,56(sp)
     fe8:	7442                	ld	s0,48(sp)
     fea:	74a2                	ld	s1,40(sp)
     fec:	7902                	ld	s2,32(sp)
     fee:	69e2                	ld	s3,24(sp)
     ff0:	6121                	addi	sp,sp,64
     ff2:	8082                	ret
    x = -xx;
     ff4:	40b005bb          	negw	a1,a1
    neg = 1;
     ff8:	4885                	li	a7,1
    x = -xx;
     ffa:	bf8d                	j	f6c <printint+0x1a>

0000000000000ffc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     ffc:	7119                	addi	sp,sp,-128
     ffe:	fc86                	sd	ra,120(sp)
    1000:	f8a2                	sd	s0,112(sp)
    1002:	f4a6                	sd	s1,104(sp)
    1004:	f0ca                	sd	s2,96(sp)
    1006:	ecce                	sd	s3,88(sp)
    1008:	e8d2                	sd	s4,80(sp)
    100a:	e4d6                	sd	s5,72(sp)
    100c:	e0da                	sd	s6,64(sp)
    100e:	fc5e                	sd	s7,56(sp)
    1010:	f862                	sd	s8,48(sp)
    1012:	f466                	sd	s9,40(sp)
    1014:	f06a                	sd	s10,32(sp)
    1016:	ec6e                	sd	s11,24(sp)
    1018:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    101a:	0005c903          	lbu	s2,0(a1)
    101e:	18090f63          	beqz	s2,11bc <vprintf+0x1c0>
    1022:	8aaa                	mv	s5,a0
    1024:	8b32                	mv	s6,a2
    1026:	00158493          	addi	s1,a1,1
  state = 0;
    102a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    102c:	02500a13          	li	s4,37
      if(c == 'd'){
    1030:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1034:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1038:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    103c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1040:	00000b97          	auipc	s7,0x0
    1044:	660b8b93          	addi	s7,s7,1632 # 16a0 <digits>
    1048:	a839                	j	1066 <vprintf+0x6a>
        putc(fd, c);
    104a:	85ca                	mv	a1,s2
    104c:	8556                	mv	a0,s5
    104e:	00000097          	auipc	ra,0x0
    1052:	ee2080e7          	jalr	-286(ra) # f30 <putc>
    1056:	a019                	j	105c <vprintf+0x60>
    } else if(state == '%'){
    1058:	01498f63          	beq	s3,s4,1076 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    105c:	0485                	addi	s1,s1,1
    105e:	fff4c903          	lbu	s2,-1(s1)
    1062:	14090d63          	beqz	s2,11bc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1066:	0009079b          	sext.w	a5,s2
    if(state == 0){
    106a:	fe0997e3          	bnez	s3,1058 <vprintf+0x5c>
      if(c == '%'){
    106e:	fd479ee3          	bne	a5,s4,104a <vprintf+0x4e>
        state = '%';
    1072:	89be                	mv	s3,a5
    1074:	b7e5                	j	105c <vprintf+0x60>
      if(c == 'd'){
    1076:	05878063          	beq	a5,s8,10b6 <vprintf+0xba>
      } else if(c == 'l') {
    107a:	05978c63          	beq	a5,s9,10d2 <vprintf+0xd6>
      } else if(c == 'x') {
    107e:	07a78863          	beq	a5,s10,10ee <vprintf+0xf2>
      } else if(c == 'p') {
    1082:	09b78463          	beq	a5,s11,110a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1086:	07300713          	li	a4,115
    108a:	0ce78663          	beq	a5,a4,1156 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    108e:	06300713          	li	a4,99
    1092:	0ee78e63          	beq	a5,a4,118e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    1096:	11478863          	beq	a5,s4,11a6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    109a:	85d2                	mv	a1,s4
    109c:	8556                	mv	a0,s5
    109e:	00000097          	auipc	ra,0x0
    10a2:	e92080e7          	jalr	-366(ra) # f30 <putc>
        putc(fd, c);
    10a6:	85ca                	mv	a1,s2
    10a8:	8556                	mv	a0,s5
    10aa:	00000097          	auipc	ra,0x0
    10ae:	e86080e7          	jalr	-378(ra) # f30 <putc>
      }
      state = 0;
    10b2:	4981                	li	s3,0
    10b4:	b765                	j	105c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10b6:	008b0913          	addi	s2,s6,8
    10ba:	4685                	li	a3,1
    10bc:	4629                	li	a2,10
    10be:	000b2583          	lw	a1,0(s6)
    10c2:	8556                	mv	a0,s5
    10c4:	00000097          	auipc	ra,0x0
    10c8:	e8e080e7          	jalr	-370(ra) # f52 <printint>
    10cc:	8b4a                	mv	s6,s2
      state = 0;
    10ce:	4981                	li	s3,0
    10d0:	b771                	j	105c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10d2:	008b0913          	addi	s2,s6,8
    10d6:	4681                	li	a3,0
    10d8:	4629                	li	a2,10
    10da:	000b2583          	lw	a1,0(s6)
    10de:	8556                	mv	a0,s5
    10e0:	00000097          	auipc	ra,0x0
    10e4:	e72080e7          	jalr	-398(ra) # f52 <printint>
    10e8:	8b4a                	mv	s6,s2
      state = 0;
    10ea:	4981                	li	s3,0
    10ec:	bf85                	j	105c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    10ee:	008b0913          	addi	s2,s6,8
    10f2:	4681                	li	a3,0
    10f4:	4641                	li	a2,16
    10f6:	000b2583          	lw	a1,0(s6)
    10fa:	8556                	mv	a0,s5
    10fc:	00000097          	auipc	ra,0x0
    1100:	e56080e7          	jalr	-426(ra) # f52 <printint>
    1104:	8b4a                	mv	s6,s2
      state = 0;
    1106:	4981                	li	s3,0
    1108:	bf91                	j	105c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    110a:	008b0793          	addi	a5,s6,8
    110e:	f8f43423          	sd	a5,-120(s0)
    1112:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1116:	03000593          	li	a1,48
    111a:	8556                	mv	a0,s5
    111c:	00000097          	auipc	ra,0x0
    1120:	e14080e7          	jalr	-492(ra) # f30 <putc>
  putc(fd, 'x');
    1124:	85ea                	mv	a1,s10
    1126:	8556                	mv	a0,s5
    1128:	00000097          	auipc	ra,0x0
    112c:	e08080e7          	jalr	-504(ra) # f30 <putc>
    1130:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1132:	03c9d793          	srli	a5,s3,0x3c
    1136:	97de                	add	a5,a5,s7
    1138:	0007c583          	lbu	a1,0(a5)
    113c:	8556                	mv	a0,s5
    113e:	00000097          	auipc	ra,0x0
    1142:	df2080e7          	jalr	-526(ra) # f30 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1146:	0992                	slli	s3,s3,0x4
    1148:	397d                	addiw	s2,s2,-1
    114a:	fe0914e3          	bnez	s2,1132 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    114e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1152:	4981                	li	s3,0
    1154:	b721                	j	105c <vprintf+0x60>
        s = va_arg(ap, char*);
    1156:	008b0993          	addi	s3,s6,8
    115a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    115e:	02090163          	beqz	s2,1180 <vprintf+0x184>
        while(*s != 0){
    1162:	00094583          	lbu	a1,0(s2)
    1166:	c9a1                	beqz	a1,11b6 <vprintf+0x1ba>
          putc(fd, *s);
    1168:	8556                	mv	a0,s5
    116a:	00000097          	auipc	ra,0x0
    116e:	dc6080e7          	jalr	-570(ra) # f30 <putc>
          s++;
    1172:	0905                	addi	s2,s2,1
        while(*s != 0){
    1174:	00094583          	lbu	a1,0(s2)
    1178:	f9e5                	bnez	a1,1168 <vprintf+0x16c>
        s = va_arg(ap, char*);
    117a:	8b4e                	mv	s6,s3
      state = 0;
    117c:	4981                	li	s3,0
    117e:	bdf9                	j	105c <vprintf+0x60>
          s = "(null)";
    1180:	00000917          	auipc	s2,0x0
    1184:	51890913          	addi	s2,s2,1304 # 1698 <malloc+0x3d2>
        while(*s != 0){
    1188:	02800593          	li	a1,40
    118c:	bff1                	j	1168 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    118e:	008b0913          	addi	s2,s6,8
    1192:	000b4583          	lbu	a1,0(s6)
    1196:	8556                	mv	a0,s5
    1198:	00000097          	auipc	ra,0x0
    119c:	d98080e7          	jalr	-616(ra) # f30 <putc>
    11a0:	8b4a                	mv	s6,s2
      state = 0;
    11a2:	4981                	li	s3,0
    11a4:	bd65                	j	105c <vprintf+0x60>
        putc(fd, c);
    11a6:	85d2                	mv	a1,s4
    11a8:	8556                	mv	a0,s5
    11aa:	00000097          	auipc	ra,0x0
    11ae:	d86080e7          	jalr	-634(ra) # f30 <putc>
      state = 0;
    11b2:	4981                	li	s3,0
    11b4:	b565                	j	105c <vprintf+0x60>
        s = va_arg(ap, char*);
    11b6:	8b4e                	mv	s6,s3
      state = 0;
    11b8:	4981                	li	s3,0
    11ba:	b54d                	j	105c <vprintf+0x60>
    }
  }
}
    11bc:	70e6                	ld	ra,120(sp)
    11be:	7446                	ld	s0,112(sp)
    11c0:	74a6                	ld	s1,104(sp)
    11c2:	7906                	ld	s2,96(sp)
    11c4:	69e6                	ld	s3,88(sp)
    11c6:	6a46                	ld	s4,80(sp)
    11c8:	6aa6                	ld	s5,72(sp)
    11ca:	6b06                	ld	s6,64(sp)
    11cc:	7be2                	ld	s7,56(sp)
    11ce:	7c42                	ld	s8,48(sp)
    11d0:	7ca2                	ld	s9,40(sp)
    11d2:	7d02                	ld	s10,32(sp)
    11d4:	6de2                	ld	s11,24(sp)
    11d6:	6109                	addi	sp,sp,128
    11d8:	8082                	ret

00000000000011da <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    11da:	715d                	addi	sp,sp,-80
    11dc:	ec06                	sd	ra,24(sp)
    11de:	e822                	sd	s0,16(sp)
    11e0:	1000                	addi	s0,sp,32
    11e2:	e010                	sd	a2,0(s0)
    11e4:	e414                	sd	a3,8(s0)
    11e6:	e818                	sd	a4,16(s0)
    11e8:	ec1c                	sd	a5,24(s0)
    11ea:	03043023          	sd	a6,32(s0)
    11ee:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11f2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    11f6:	8622                	mv	a2,s0
    11f8:	00000097          	auipc	ra,0x0
    11fc:	e04080e7          	jalr	-508(ra) # ffc <vprintf>
}
    1200:	60e2                	ld	ra,24(sp)
    1202:	6442                	ld	s0,16(sp)
    1204:	6161                	addi	sp,sp,80
    1206:	8082                	ret

0000000000001208 <printf>:

void
printf(const char *fmt, ...)
{
    1208:	711d                	addi	sp,sp,-96
    120a:	ec06                	sd	ra,24(sp)
    120c:	e822                	sd	s0,16(sp)
    120e:	1000                	addi	s0,sp,32
    1210:	e40c                	sd	a1,8(s0)
    1212:	e810                	sd	a2,16(s0)
    1214:	ec14                	sd	a3,24(s0)
    1216:	f018                	sd	a4,32(s0)
    1218:	f41c                	sd	a5,40(s0)
    121a:	03043823          	sd	a6,48(s0)
    121e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1222:	00840613          	addi	a2,s0,8
    1226:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    122a:	85aa                	mv	a1,a0
    122c:	4505                	li	a0,1
    122e:	00000097          	auipc	ra,0x0
    1232:	dce080e7          	jalr	-562(ra) # ffc <vprintf>
}
    1236:	60e2                	ld	ra,24(sp)
    1238:	6442                	ld	s0,16(sp)
    123a:	6125                	addi	sp,sp,96
    123c:	8082                	ret

000000000000123e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    123e:	1141                	addi	sp,sp,-16
    1240:	e422                	sd	s0,8(sp)
    1242:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1244:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1248:	00000797          	auipc	a5,0x0
    124c:	4787b783          	ld	a5,1144(a5) # 16c0 <freep>
    1250:	a805                	j	1280 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1252:	4618                	lw	a4,8(a2)
    1254:	9db9                	addw	a1,a1,a4
    1256:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    125a:	6398                	ld	a4,0(a5)
    125c:	6318                	ld	a4,0(a4)
    125e:	fee53823          	sd	a4,-16(a0)
    1262:	a091                	j	12a6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1264:	ff852703          	lw	a4,-8(a0)
    1268:	9e39                	addw	a2,a2,a4
    126a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    126c:	ff053703          	ld	a4,-16(a0)
    1270:	e398                	sd	a4,0(a5)
    1272:	a099                	j	12b8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1274:	6398                	ld	a4,0(a5)
    1276:	00e7e463          	bltu	a5,a4,127e <free+0x40>
    127a:	00e6ea63          	bltu	a3,a4,128e <free+0x50>
{
    127e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1280:	fed7fae3          	bgeu	a5,a3,1274 <free+0x36>
    1284:	6398                	ld	a4,0(a5)
    1286:	00e6e463          	bltu	a3,a4,128e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    128a:	fee7eae3          	bltu	a5,a4,127e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    128e:	ff852583          	lw	a1,-8(a0)
    1292:	6390                	ld	a2,0(a5)
    1294:	02059713          	slli	a4,a1,0x20
    1298:	9301                	srli	a4,a4,0x20
    129a:	0712                	slli	a4,a4,0x4
    129c:	9736                	add	a4,a4,a3
    129e:	fae60ae3          	beq	a2,a4,1252 <free+0x14>
    bp->s.ptr = p->s.ptr;
    12a2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12a6:	4790                	lw	a2,8(a5)
    12a8:	02061713          	slli	a4,a2,0x20
    12ac:	9301                	srli	a4,a4,0x20
    12ae:	0712                	slli	a4,a4,0x4
    12b0:	973e                	add	a4,a4,a5
    12b2:	fae689e3          	beq	a3,a4,1264 <free+0x26>
  } else
    p->s.ptr = bp;
    12b6:	e394                	sd	a3,0(a5)
  freep = p;
    12b8:	00000717          	auipc	a4,0x0
    12bc:	40f73423          	sd	a5,1032(a4) # 16c0 <freep>
}
    12c0:	6422                	ld	s0,8(sp)
    12c2:	0141                	addi	sp,sp,16
    12c4:	8082                	ret

00000000000012c6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12c6:	7139                	addi	sp,sp,-64
    12c8:	fc06                	sd	ra,56(sp)
    12ca:	f822                	sd	s0,48(sp)
    12cc:	f426                	sd	s1,40(sp)
    12ce:	f04a                	sd	s2,32(sp)
    12d0:	ec4e                	sd	s3,24(sp)
    12d2:	e852                	sd	s4,16(sp)
    12d4:	e456                	sd	s5,8(sp)
    12d6:	e05a                	sd	s6,0(sp)
    12d8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    12da:	02051493          	slli	s1,a0,0x20
    12de:	9081                	srli	s1,s1,0x20
    12e0:	04bd                	addi	s1,s1,15
    12e2:	8091                	srli	s1,s1,0x4
    12e4:	0014899b          	addiw	s3,s1,1
    12e8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12ea:	00000517          	auipc	a0,0x0
    12ee:	3d653503          	ld	a0,982(a0) # 16c0 <freep>
    12f2:	c515                	beqz	a0,131e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12f6:	4798                	lw	a4,8(a5)
    12f8:	02977f63          	bgeu	a4,s1,1336 <malloc+0x70>
    12fc:	8a4e                	mv	s4,s3
    12fe:	0009871b          	sext.w	a4,s3
    1302:	6685                	lui	a3,0x1
    1304:	00d77363          	bgeu	a4,a3,130a <malloc+0x44>
    1308:	6a05                	lui	s4,0x1
    130a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    130e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1312:	00000917          	auipc	s2,0x0
    1316:	3ae90913          	addi	s2,s2,942 # 16c0 <freep>
  if(p == (char*)-1)
    131a:	5afd                	li	s5,-1
    131c:	a88d                	j	138e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    131e:	00000797          	auipc	a5,0x0
    1322:	79278793          	addi	a5,a5,1938 # 1ab0 <base>
    1326:	00000717          	auipc	a4,0x0
    132a:	38f73d23          	sd	a5,922(a4) # 16c0 <freep>
    132e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1330:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1334:	b7e1                	j	12fc <malloc+0x36>
      if(p->s.size == nunits)
    1336:	02e48b63          	beq	s1,a4,136c <malloc+0xa6>
        p->s.size -= nunits;
    133a:	4137073b          	subw	a4,a4,s3
    133e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1340:	1702                	slli	a4,a4,0x20
    1342:	9301                	srli	a4,a4,0x20
    1344:	0712                	slli	a4,a4,0x4
    1346:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1348:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    134c:	00000717          	auipc	a4,0x0
    1350:	36a73a23          	sd	a0,884(a4) # 16c0 <freep>
      return (void*)(p + 1);
    1354:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1358:	70e2                	ld	ra,56(sp)
    135a:	7442                	ld	s0,48(sp)
    135c:	74a2                	ld	s1,40(sp)
    135e:	7902                	ld	s2,32(sp)
    1360:	69e2                	ld	s3,24(sp)
    1362:	6a42                	ld	s4,16(sp)
    1364:	6aa2                	ld	s5,8(sp)
    1366:	6b02                	ld	s6,0(sp)
    1368:	6121                	addi	sp,sp,64
    136a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    136c:	6398                	ld	a4,0(a5)
    136e:	e118                	sd	a4,0(a0)
    1370:	bff1                	j	134c <malloc+0x86>
  hp->s.size = nu;
    1372:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1376:	0541                	addi	a0,a0,16
    1378:	00000097          	auipc	ra,0x0
    137c:	ec6080e7          	jalr	-314(ra) # 123e <free>
  return freep;
    1380:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1384:	d971                	beqz	a0,1358 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1386:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1388:	4798                	lw	a4,8(a5)
    138a:	fa9776e3          	bgeu	a4,s1,1336 <malloc+0x70>
    if(p == freep)
    138e:	00093703          	ld	a4,0(s2)
    1392:	853e                	mv	a0,a5
    1394:	fef719e3          	bne	a4,a5,1386 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    1398:	8552                	mv	a0,s4
    139a:	00000097          	auipc	ra,0x0
    139e:	b66080e7          	jalr	-1178(ra) # f00 <sbrk>
  if(p == (char*)-1)
    13a2:	fd5518e3          	bne	a0,s5,1372 <malloc+0xac>
        return 0;
    13a6:	4501                	li	a0,0
    13a8:	bf45                	j	1358 <malloc+0x92>
