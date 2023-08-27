
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	9b8080e7          	jalr	-1608(ra) # 59c8 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	9a6080e7          	jalr	-1626(ra) # 59c8 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	1f250513          	addi	a0,a0,498 # 6230 <malloc+0x45a>
      46:	00006097          	auipc	ra,0x6
      4a:	cd2080e7          	jalr	-814(ra) # 5d18 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	938080e7          	jalr	-1736(ra) # 5988 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	7b878793          	addi	a5,a5,1976 # 9810 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	ec068693          	addi	a3,a3,-320 # bf20 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	1d050513          	addi	a0,a0,464 # 6250 <malloc+0x47a>
      88:	00006097          	auipc	ra,0x6
      8c:	c90080e7          	jalr	-880(ra) # 5d18 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00006097          	auipc	ra,0x6
      96:	8f6080e7          	jalr	-1802(ra) # 5988 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	1c050513          	addi	a0,a0,448 # 6268 <malloc+0x492>
      b0:	00006097          	auipc	ra,0x6
      b4:	918080e7          	jalr	-1768(ra) # 59c8 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00006097          	auipc	ra,0x6
      c0:	8f4080e7          	jalr	-1804(ra) # 59b0 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	1c250513          	addi	a0,a0,450 # 6288 <malloc+0x4b2>
      ce:	00006097          	auipc	ra,0x6
      d2:	8fa080e7          	jalr	-1798(ra) # 59c8 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	18a50513          	addi	a0,a0,394 # 6270 <malloc+0x49a>
      ee:	00006097          	auipc	ra,0x6
      f2:	c2a080e7          	jalr	-982(ra) # 5d18 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00006097          	auipc	ra,0x6
      fc:	890080e7          	jalr	-1904(ra) # 5988 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	19650513          	addi	a0,a0,406 # 6298 <malloc+0x4c2>
     10a:	00006097          	auipc	ra,0x6
     10e:	c0e080e7          	jalr	-1010(ra) # 5d18 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00006097          	auipc	ra,0x6
     118:	874080e7          	jalr	-1932(ra) # 5988 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	19450513          	addi	a0,a0,404 # 62c0 <malloc+0x4ea>
     134:	00006097          	auipc	ra,0x6
     138:	8a4080e7          	jalr	-1884(ra) # 59d8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	18050513          	addi	a0,a0,384 # 62c0 <malloc+0x4ea>
     148:	00006097          	auipc	ra,0x6
     14c:	880080e7          	jalr	-1920(ra) # 59c8 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	17c58593          	addi	a1,a1,380 # 62d0 <malloc+0x4fa>
     15c:	00006097          	auipc	ra,0x6
     160:	84c080e7          	jalr	-1972(ra) # 59a8 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	15850513          	addi	a0,a0,344 # 62c0 <malloc+0x4ea>
     170:	00006097          	auipc	ra,0x6
     174:	858080e7          	jalr	-1960(ra) # 59c8 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	15c58593          	addi	a1,a1,348 # 62d8 <malloc+0x502>
     184:	8526                	mv	a0,s1
     186:	00006097          	auipc	ra,0x6
     18a:	822080e7          	jalr	-2014(ra) # 59a8 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	12c50513          	addi	a0,a0,300 # 62c0 <malloc+0x4ea>
     19c:	00006097          	auipc	ra,0x6
     1a0:	83c080e7          	jalr	-1988(ra) # 59d8 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00006097          	auipc	ra,0x6
     1aa:	80a080e7          	jalr	-2038(ra) # 59b0 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00006097          	auipc	ra,0x6
     1b4:	800080e7          	jalr	-2048(ra) # 59b0 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	11650513          	addi	a0,a0,278 # 62e0 <malloc+0x50a>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	b46080e7          	jalr	-1210(ra) # 5d18 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	7ac080e7          	jalr	1964(ra) # 5988 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00005097          	auipc	ra,0x5
     214:	7b8080e7          	jalr	1976(ra) # 59c8 <open>
    close(fd);
     218:	00005097          	auipc	ra,0x5
     21c:	798080e7          	jalr	1944(ra) # 59b0 <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	andi	s1,s1,255
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00005097          	auipc	ra,0x5
     24a:	792080e7          	jalr	1938(ra) # 59d8 <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	andi	s1,s1,255
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	e2450513          	addi	a0,a0,-476 # 60a0 <malloc+0x2ca>
     284:	00005097          	auipc	ra,0x5
     288:	754080e7          	jalr	1876(ra) # 59d8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	e10a8a93          	addi	s5,s5,-496 # 60a0 <malloc+0x2ca>
      int cc = write(fd, buf, sz);
     298:	0000ca17          	auipc	s4,0xc
     29c:	c88a0a13          	addi	s4,s4,-888 # bf20 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <exitiputtest+0x33>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00005097          	auipc	ra,0x5
     2b0:	71c080e7          	jalr	1820(ra) # 59c8 <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00005097          	auipc	ra,0x5
     2c2:	6ea080e7          	jalr	1770(ra) # 59a8 <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00005097          	auipc	ra,0x5
     2d6:	6d6080e7          	jalr	1750(ra) # 59a8 <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00005097          	auipc	ra,0x5
     2e4:	6d0080e7          	jalr	1744(ra) # 59b0 <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00005097          	auipc	ra,0x5
     2ee:	6ee080e7          	jalr	1774(ra) # 59d8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	ff650513          	addi	a0,a0,-10 # 6308 <malloc+0x532>
     31a:	00006097          	auipc	ra,0x6
     31e:	9fe080e7          	jalr	-1538(ra) # 5d18 <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00005097          	auipc	ra,0x5
     328:	664080e7          	jalr	1636(ra) # 5988 <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	ff250513          	addi	a0,a0,-14 # 6328 <malloc+0x552>
     33e:	00006097          	auipc	ra,0x6
     342:	9da080e7          	jalr	-1574(ra) # 5d18 <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00005097          	auipc	ra,0x5
     34c:	640080e7          	jalr	1600(ra) # 5988 <exit>

0000000000000350 <diskfull>:
}

// can the kernel tolerate running out of disk space?
void
diskfull(char *s)
{
     350:	b9010113          	addi	sp,sp,-1136
     354:	46113423          	sd	ra,1128(sp)
     358:	46813023          	sd	s0,1120(sp)
     35c:	44913c23          	sd	s1,1112(sp)
     360:	45213823          	sd	s2,1104(sp)
     364:	45313423          	sd	s3,1096(sp)
     368:	45413023          	sd	s4,1088(sp)
     36c:	43513c23          	sd	s5,1080(sp)
     370:	43613823          	sd	s6,1072(sp)
     374:	43713423          	sd	s7,1064(sp)
     378:	43813023          	sd	s8,1056(sp)
     37c:	47010413          	addi	s0,sp,1136
     380:	8c2a                	mv	s8,a0
  int fi;
  int done = 0;
  
  for(fi = 0; done == 0; fi++){
     382:	4981                	li	s3,0
    char name[32];
    name[0] = 'b';
     384:	06200b13          	li	s6,98
    name[1] = 'i';
     388:	06900a93          	li	s5,105
    name[2] = 'g';
     38c:	06700a13          	li	s4,103
     390:	10c00b93          	li	s7,268
     394:	a05d                	j	43a <diskfull+0xea>
    name[3] = '0' + fi;
    name[4] = '\0';
    unlink(name);
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    if(fd < 0){
      printf("%s: could not create file %s\n", s, name);
     396:	b9040613          	addi	a2,s0,-1136
     39a:	85e2                	mv	a1,s8
     39c:	00006517          	auipc	a0,0x6
     3a0:	fa450513          	addi	a0,a0,-92 # 6340 <malloc+0x56a>
     3a4:	00006097          	auipc	ra,0x6
     3a8:	974080e7          	jalr	-1676(ra) # 5d18 <printf>
      done = 1;
      break;
     3ac:	a821                	j	3c4 <diskfull+0x74>
    }
    for(int i = 0; i < MAXFILE; i++){
      char buf[BSIZE];
      if(write(fd, buf, BSIZE) != BSIZE){
        done = 1;
        close(fd);
     3ae:	854a                	mv	a0,s2
     3b0:	00005097          	auipc	ra,0x5
     3b4:	600080e7          	jalr	1536(ra) # 59b0 <close>
        break;
      }
    }
    close(fd);
     3b8:	854a                	mv	a0,s2
     3ba:	00005097          	auipc	ra,0x5
     3be:	5f6080e7          	jalr	1526(ra) # 59b0 <close>
  for(fi = 0; done == 0; fi++){
     3c2:	2985                	addiw	s3,s3,1
  }

  for(int i = 0; i < fi; i++){
     3c4:	4481                	li	s1,0
     3c6:	03305d63          	blez	s3,400 <diskfull+0xb0>
    char name[32];
    name[0] = 'b';
     3ca:	06200a93          	li	s5,98
    name[1] = 'i';
     3ce:	06900a13          	li	s4,105
    name[2] = 'g';
     3d2:	06700913          	li	s2,103
    name[0] = 'b';
     3d6:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
     3da:	bb4408a3          	sb	s4,-1103(s0)
    name[2] = 'g';
     3de:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
     3e2:	0304879b          	addiw	a5,s1,48
     3e6:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
     3ea:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
     3ee:	bb040513          	addi	a0,s0,-1104
     3f2:	00005097          	auipc	ra,0x5
     3f6:	5e6080e7          	jalr	1510(ra) # 59d8 <unlink>
  for(int i = 0; i < fi; i++){
     3fa:	2485                	addiw	s1,s1,1
     3fc:	fd349de3          	bne	s1,s3,3d6 <diskfull+0x86>
  }
}
     400:	46813083          	ld	ra,1128(sp)
     404:	46013403          	ld	s0,1120(sp)
     408:	45813483          	ld	s1,1112(sp)
     40c:	45013903          	ld	s2,1104(sp)
     410:	44813983          	ld	s3,1096(sp)
     414:	44013a03          	ld	s4,1088(sp)
     418:	43813a83          	ld	s5,1080(sp)
     41c:	43013b03          	ld	s6,1072(sp)
     420:	42813b83          	ld	s7,1064(sp)
     424:	42013c03          	ld	s8,1056(sp)
     428:	47010113          	addi	sp,sp,1136
     42c:	8082                	ret
    close(fd);
     42e:	854a                	mv	a0,s2
     430:	00005097          	auipc	ra,0x5
     434:	580080e7          	jalr	1408(ra) # 59b0 <close>
  for(fi = 0; done == 0; fi++){
     438:	2985                	addiw	s3,s3,1
    name[0] = 'b';
     43a:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
     43e:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
     442:	b9440923          	sb	s4,-1134(s0)
    name[3] = '0' + fi;
     446:	0309879b          	addiw	a5,s3,48
     44a:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
     44e:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
     452:	b9040513          	addi	a0,s0,-1136
     456:	00005097          	auipc	ra,0x5
     45a:	582080e7          	jalr	1410(ra) # 59d8 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     45e:	60200593          	li	a1,1538
     462:	b9040513          	addi	a0,s0,-1136
     466:	00005097          	auipc	ra,0x5
     46a:	562080e7          	jalr	1378(ra) # 59c8 <open>
     46e:	892a                	mv	s2,a0
    if(fd < 0){
     470:	f20543e3          	bltz	a0,396 <diskfull+0x46>
     474:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
     476:	40000613          	li	a2,1024
     47a:	bb040593          	addi	a1,s0,-1104
     47e:	854a                	mv	a0,s2
     480:	00005097          	auipc	ra,0x5
     484:	528080e7          	jalr	1320(ra) # 59a8 <write>
     488:	40000793          	li	a5,1024
     48c:	f2f511e3          	bne	a0,a5,3ae <diskfull+0x5e>
    for(int i = 0; i < MAXFILE; i++){
     490:	34fd                	addiw	s1,s1,-1
     492:	f0f5                	bnez	s1,476 <diskfull+0x126>
     494:	bf69                	j	42e <diskfull+0xde>

0000000000000496 <copyin>:
{
     496:	715d                	addi	sp,sp,-80
     498:	e486                	sd	ra,72(sp)
     49a:	e0a2                	sd	s0,64(sp)
     49c:	fc26                	sd	s1,56(sp)
     49e:	f84a                	sd	s2,48(sp)
     4a0:	f44e                	sd	s3,40(sp)
     4a2:	f052                	sd	s4,32(sp)
     4a4:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4a6:	4785                	li	a5,1
     4a8:	07fe                	slli	a5,a5,0x1f
     4aa:	fcf43023          	sd	a5,-64(s0)
     4ae:	57fd                	li	a5,-1
     4b0:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     4b4:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4b8:	00006a17          	auipc	s4,0x6
     4bc:	ea8a0a13          	addi	s4,s4,-344 # 6360 <malloc+0x58a>
    uint64 addr = addrs[ai];
     4c0:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4c4:	20100593          	li	a1,513
     4c8:	8552                	mv	a0,s4
     4ca:	00005097          	auipc	ra,0x5
     4ce:	4fe080e7          	jalr	1278(ra) # 59c8 <open>
     4d2:	84aa                	mv	s1,a0
    if(fd < 0){
     4d4:	08054863          	bltz	a0,564 <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     4d8:	6609                	lui	a2,0x2
     4da:	85ce                	mv	a1,s3
     4dc:	00005097          	auipc	ra,0x5
     4e0:	4cc080e7          	jalr	1228(ra) # 59a8 <write>
    if(n >= 0){
     4e4:	08055d63          	bgez	a0,57e <copyin+0xe8>
    close(fd);
     4e8:	8526                	mv	a0,s1
     4ea:	00005097          	auipc	ra,0x5
     4ee:	4c6080e7          	jalr	1222(ra) # 59b0 <close>
    unlink("copyin1");
     4f2:	8552                	mv	a0,s4
     4f4:	00005097          	auipc	ra,0x5
     4f8:	4e4080e7          	jalr	1252(ra) # 59d8 <unlink>
    n = write(1, (char*)addr, 8192);
     4fc:	6609                	lui	a2,0x2
     4fe:	85ce                	mv	a1,s3
     500:	4505                	li	a0,1
     502:	00005097          	auipc	ra,0x5
     506:	4a6080e7          	jalr	1190(ra) # 59a8 <write>
    if(n > 0){
     50a:	08a04963          	bgtz	a0,59c <copyin+0x106>
    if(pipe(fds) < 0){
     50e:	fb840513          	addi	a0,s0,-72
     512:	00005097          	auipc	ra,0x5
     516:	486080e7          	jalr	1158(ra) # 5998 <pipe>
     51a:	0a054063          	bltz	a0,5ba <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     51e:	6609                	lui	a2,0x2
     520:	85ce                	mv	a1,s3
     522:	fbc42503          	lw	a0,-68(s0)
     526:	00005097          	auipc	ra,0x5
     52a:	482080e7          	jalr	1154(ra) # 59a8 <write>
    if(n > 0){
     52e:	0aa04363          	bgtz	a0,5d4 <copyin+0x13e>
    close(fds[0]);
     532:	fb842503          	lw	a0,-72(s0)
     536:	00005097          	auipc	ra,0x5
     53a:	47a080e7          	jalr	1146(ra) # 59b0 <close>
    close(fds[1]);
     53e:	fbc42503          	lw	a0,-68(s0)
     542:	00005097          	auipc	ra,0x5
     546:	46e080e7          	jalr	1134(ra) # 59b0 <close>
  for(int ai = 0; ai < 2; ai++){
     54a:	0921                	addi	s2,s2,8
     54c:	fd040793          	addi	a5,s0,-48
     550:	f6f918e3          	bne	s2,a5,4c0 <copyin+0x2a>
}
     554:	60a6                	ld	ra,72(sp)
     556:	6406                	ld	s0,64(sp)
     558:	74e2                	ld	s1,56(sp)
     55a:	7942                	ld	s2,48(sp)
     55c:	79a2                	ld	s3,40(sp)
     55e:	7a02                	ld	s4,32(sp)
     560:	6161                	addi	sp,sp,80
     562:	8082                	ret
      printf("open(copyin1) failed\n");
     564:	00006517          	auipc	a0,0x6
     568:	e0450513          	addi	a0,a0,-508 # 6368 <malloc+0x592>
     56c:	00005097          	auipc	ra,0x5
     570:	7ac080e7          	jalr	1964(ra) # 5d18 <printf>
      exit(1);
     574:	4505                	li	a0,1
     576:	00005097          	auipc	ra,0x5
     57a:	412080e7          	jalr	1042(ra) # 5988 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     57e:	862a                	mv	a2,a0
     580:	85ce                	mv	a1,s3
     582:	00006517          	auipc	a0,0x6
     586:	dfe50513          	addi	a0,a0,-514 # 6380 <malloc+0x5aa>
     58a:	00005097          	auipc	ra,0x5
     58e:	78e080e7          	jalr	1934(ra) # 5d18 <printf>
      exit(1);
     592:	4505                	li	a0,1
     594:	00005097          	auipc	ra,0x5
     598:	3f4080e7          	jalr	1012(ra) # 5988 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     59c:	862a                	mv	a2,a0
     59e:	85ce                	mv	a1,s3
     5a0:	00006517          	auipc	a0,0x6
     5a4:	e1050513          	addi	a0,a0,-496 # 63b0 <malloc+0x5da>
     5a8:	00005097          	auipc	ra,0x5
     5ac:	770080e7          	jalr	1904(ra) # 5d18 <printf>
      exit(1);
     5b0:	4505                	li	a0,1
     5b2:	00005097          	auipc	ra,0x5
     5b6:	3d6080e7          	jalr	982(ra) # 5988 <exit>
      printf("pipe() failed\n");
     5ba:	00006517          	auipc	a0,0x6
     5be:	e2650513          	addi	a0,a0,-474 # 63e0 <malloc+0x60a>
     5c2:	00005097          	auipc	ra,0x5
     5c6:	756080e7          	jalr	1878(ra) # 5d18 <printf>
      exit(1);
     5ca:	4505                	li	a0,1
     5cc:	00005097          	auipc	ra,0x5
     5d0:	3bc080e7          	jalr	956(ra) # 5988 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5d4:	862a                	mv	a2,a0
     5d6:	85ce                	mv	a1,s3
     5d8:	00006517          	auipc	a0,0x6
     5dc:	e1850513          	addi	a0,a0,-488 # 63f0 <malloc+0x61a>
     5e0:	00005097          	auipc	ra,0x5
     5e4:	738080e7          	jalr	1848(ra) # 5d18 <printf>
      exit(1);
     5e8:	4505                	li	a0,1
     5ea:	00005097          	auipc	ra,0x5
     5ee:	39e080e7          	jalr	926(ra) # 5988 <exit>

00000000000005f2 <copyout>:
{
     5f2:	711d                	addi	sp,sp,-96
     5f4:	ec86                	sd	ra,88(sp)
     5f6:	e8a2                	sd	s0,80(sp)
     5f8:	e4a6                	sd	s1,72(sp)
     5fa:	e0ca                	sd	s2,64(sp)
     5fc:	fc4e                	sd	s3,56(sp)
     5fe:	f852                	sd	s4,48(sp)
     600:	f456                	sd	s5,40(sp)
     602:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     604:	4785                	li	a5,1
     606:	07fe                	slli	a5,a5,0x1f
     608:	faf43823          	sd	a5,-80(s0)
     60c:	57fd                	li	a5,-1
     60e:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     612:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     616:	00006a17          	auipc	s4,0x6
     61a:	e0aa0a13          	addi	s4,s4,-502 # 6420 <malloc+0x64a>
    n = write(fds[1], "x", 1);
     61e:	00006a97          	auipc	s5,0x6
     622:	cbaa8a93          	addi	s5,s5,-838 # 62d8 <malloc+0x502>
    uint64 addr = addrs[ai];
     626:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     62a:	4581                	li	a1,0
     62c:	8552                	mv	a0,s4
     62e:	00005097          	auipc	ra,0x5
     632:	39a080e7          	jalr	922(ra) # 59c8 <open>
     636:	84aa                	mv	s1,a0
    if(fd < 0){
     638:	08054663          	bltz	a0,6c4 <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     63c:	6609                	lui	a2,0x2
     63e:	85ce                	mv	a1,s3
     640:	00005097          	auipc	ra,0x5
     644:	360080e7          	jalr	864(ra) # 59a0 <read>
    if(n > 0){
     648:	08a04b63          	bgtz	a0,6de <copyout+0xec>
    close(fd);
     64c:	8526                	mv	a0,s1
     64e:	00005097          	auipc	ra,0x5
     652:	362080e7          	jalr	866(ra) # 59b0 <close>
    if(pipe(fds) < 0){
     656:	fa840513          	addi	a0,s0,-88
     65a:	00005097          	auipc	ra,0x5
     65e:	33e080e7          	jalr	830(ra) # 5998 <pipe>
     662:	08054d63          	bltz	a0,6fc <copyout+0x10a>
    n = write(fds[1], "x", 1);
     666:	4605                	li	a2,1
     668:	85d6                	mv	a1,s5
     66a:	fac42503          	lw	a0,-84(s0)
     66e:	00005097          	auipc	ra,0x5
     672:	33a080e7          	jalr	826(ra) # 59a8 <write>
    if(n != 1){
     676:	4785                	li	a5,1
     678:	08f51f63          	bne	a0,a5,716 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     67c:	6609                	lui	a2,0x2
     67e:	85ce                	mv	a1,s3
     680:	fa842503          	lw	a0,-88(s0)
     684:	00005097          	auipc	ra,0x5
     688:	31c080e7          	jalr	796(ra) # 59a0 <read>
    if(n > 0){
     68c:	0aa04263          	bgtz	a0,730 <copyout+0x13e>
    close(fds[0]);
     690:	fa842503          	lw	a0,-88(s0)
     694:	00005097          	auipc	ra,0x5
     698:	31c080e7          	jalr	796(ra) # 59b0 <close>
    close(fds[1]);
     69c:	fac42503          	lw	a0,-84(s0)
     6a0:	00005097          	auipc	ra,0x5
     6a4:	310080e7          	jalr	784(ra) # 59b0 <close>
  for(int ai = 0; ai < 2; ai++){
     6a8:	0921                	addi	s2,s2,8
     6aa:	fc040793          	addi	a5,s0,-64
     6ae:	f6f91ce3          	bne	s2,a5,626 <copyout+0x34>
}
     6b2:	60e6                	ld	ra,88(sp)
     6b4:	6446                	ld	s0,80(sp)
     6b6:	64a6                	ld	s1,72(sp)
     6b8:	6906                	ld	s2,64(sp)
     6ba:	79e2                	ld	s3,56(sp)
     6bc:	7a42                	ld	s4,48(sp)
     6be:	7aa2                	ld	s5,40(sp)
     6c0:	6125                	addi	sp,sp,96
     6c2:	8082                	ret
      printf("open(README) failed\n");
     6c4:	00006517          	auipc	a0,0x6
     6c8:	d6450513          	addi	a0,a0,-668 # 6428 <malloc+0x652>
     6cc:	00005097          	auipc	ra,0x5
     6d0:	64c080e7          	jalr	1612(ra) # 5d18 <printf>
      exit(1);
     6d4:	4505                	li	a0,1
     6d6:	00005097          	auipc	ra,0x5
     6da:	2b2080e7          	jalr	690(ra) # 5988 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     6de:	862a                	mv	a2,a0
     6e0:	85ce                	mv	a1,s3
     6e2:	00006517          	auipc	a0,0x6
     6e6:	d5e50513          	addi	a0,a0,-674 # 6440 <malloc+0x66a>
     6ea:	00005097          	auipc	ra,0x5
     6ee:	62e080e7          	jalr	1582(ra) # 5d18 <printf>
      exit(1);
     6f2:	4505                	li	a0,1
     6f4:	00005097          	auipc	ra,0x5
     6f8:	294080e7          	jalr	660(ra) # 5988 <exit>
      printf("pipe() failed\n");
     6fc:	00006517          	auipc	a0,0x6
     700:	ce450513          	addi	a0,a0,-796 # 63e0 <malloc+0x60a>
     704:	00005097          	auipc	ra,0x5
     708:	614080e7          	jalr	1556(ra) # 5d18 <printf>
      exit(1);
     70c:	4505                	li	a0,1
     70e:	00005097          	auipc	ra,0x5
     712:	27a080e7          	jalr	634(ra) # 5988 <exit>
      printf("pipe write failed\n");
     716:	00006517          	auipc	a0,0x6
     71a:	d5a50513          	addi	a0,a0,-678 # 6470 <malloc+0x69a>
     71e:	00005097          	auipc	ra,0x5
     722:	5fa080e7          	jalr	1530(ra) # 5d18 <printf>
      exit(1);
     726:	4505                	li	a0,1
     728:	00005097          	auipc	ra,0x5
     72c:	260080e7          	jalr	608(ra) # 5988 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     730:	862a                	mv	a2,a0
     732:	85ce                	mv	a1,s3
     734:	00006517          	auipc	a0,0x6
     738:	d5450513          	addi	a0,a0,-684 # 6488 <malloc+0x6b2>
     73c:	00005097          	auipc	ra,0x5
     740:	5dc080e7          	jalr	1500(ra) # 5d18 <printf>
      exit(1);
     744:	4505                	li	a0,1
     746:	00005097          	auipc	ra,0x5
     74a:	242080e7          	jalr	578(ra) # 5988 <exit>

000000000000074e <truncate1>:
{
     74e:	711d                	addi	sp,sp,-96
     750:	ec86                	sd	ra,88(sp)
     752:	e8a2                	sd	s0,80(sp)
     754:	e4a6                	sd	s1,72(sp)
     756:	e0ca                	sd	s2,64(sp)
     758:	fc4e                	sd	s3,56(sp)
     75a:	f852                	sd	s4,48(sp)
     75c:	f456                	sd	s5,40(sp)
     75e:	1080                	addi	s0,sp,96
     760:	8aaa                	mv	s5,a0
  unlink("truncfile");
     762:	00006517          	auipc	a0,0x6
     766:	b5e50513          	addi	a0,a0,-1186 # 62c0 <malloc+0x4ea>
     76a:	00005097          	auipc	ra,0x5
     76e:	26e080e7          	jalr	622(ra) # 59d8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     772:	60100593          	li	a1,1537
     776:	00006517          	auipc	a0,0x6
     77a:	b4a50513          	addi	a0,a0,-1206 # 62c0 <malloc+0x4ea>
     77e:	00005097          	auipc	ra,0x5
     782:	24a080e7          	jalr	586(ra) # 59c8 <open>
     786:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     788:	4611                	li	a2,4
     78a:	00006597          	auipc	a1,0x6
     78e:	b4658593          	addi	a1,a1,-1210 # 62d0 <malloc+0x4fa>
     792:	00005097          	auipc	ra,0x5
     796:	216080e7          	jalr	534(ra) # 59a8 <write>
  close(fd1);
     79a:	8526                	mv	a0,s1
     79c:	00005097          	auipc	ra,0x5
     7a0:	214080e7          	jalr	532(ra) # 59b0 <close>
  int fd2 = open("truncfile", O_RDONLY);
     7a4:	4581                	li	a1,0
     7a6:	00006517          	auipc	a0,0x6
     7aa:	b1a50513          	addi	a0,a0,-1254 # 62c0 <malloc+0x4ea>
     7ae:	00005097          	auipc	ra,0x5
     7b2:	21a080e7          	jalr	538(ra) # 59c8 <open>
     7b6:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     7b8:	02000613          	li	a2,32
     7bc:	fa040593          	addi	a1,s0,-96
     7c0:	00005097          	auipc	ra,0x5
     7c4:	1e0080e7          	jalr	480(ra) # 59a0 <read>
  if(n != 4){
     7c8:	4791                	li	a5,4
     7ca:	0cf51e63          	bne	a0,a5,8a6 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     7ce:	40100593          	li	a1,1025
     7d2:	00006517          	auipc	a0,0x6
     7d6:	aee50513          	addi	a0,a0,-1298 # 62c0 <malloc+0x4ea>
     7da:	00005097          	auipc	ra,0x5
     7de:	1ee080e7          	jalr	494(ra) # 59c8 <open>
     7e2:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     7e4:	4581                	li	a1,0
     7e6:	00006517          	auipc	a0,0x6
     7ea:	ada50513          	addi	a0,a0,-1318 # 62c0 <malloc+0x4ea>
     7ee:	00005097          	auipc	ra,0x5
     7f2:	1da080e7          	jalr	474(ra) # 59c8 <open>
     7f6:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     7f8:	02000613          	li	a2,32
     7fc:	fa040593          	addi	a1,s0,-96
     800:	00005097          	auipc	ra,0x5
     804:	1a0080e7          	jalr	416(ra) # 59a0 <read>
     808:	8a2a                	mv	s4,a0
  if(n != 0){
     80a:	ed4d                	bnez	a0,8c4 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     80c:	02000613          	li	a2,32
     810:	fa040593          	addi	a1,s0,-96
     814:	8526                	mv	a0,s1
     816:	00005097          	auipc	ra,0x5
     81a:	18a080e7          	jalr	394(ra) # 59a0 <read>
     81e:	8a2a                	mv	s4,a0
  if(n != 0){
     820:	e971                	bnez	a0,8f4 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     822:	4619                	li	a2,6
     824:	00006597          	auipc	a1,0x6
     828:	cf458593          	addi	a1,a1,-780 # 6518 <malloc+0x742>
     82c:	854e                	mv	a0,s3
     82e:	00005097          	auipc	ra,0x5
     832:	17a080e7          	jalr	378(ra) # 59a8 <write>
  n = read(fd3, buf, sizeof(buf));
     836:	02000613          	li	a2,32
     83a:	fa040593          	addi	a1,s0,-96
     83e:	854a                	mv	a0,s2
     840:	00005097          	auipc	ra,0x5
     844:	160080e7          	jalr	352(ra) # 59a0 <read>
  if(n != 6){
     848:	4799                	li	a5,6
     84a:	0cf51d63          	bne	a0,a5,924 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     84e:	02000613          	li	a2,32
     852:	fa040593          	addi	a1,s0,-96
     856:	8526                	mv	a0,s1
     858:	00005097          	auipc	ra,0x5
     85c:	148080e7          	jalr	328(ra) # 59a0 <read>
  if(n != 2){
     860:	4789                	li	a5,2
     862:	0ef51063          	bne	a0,a5,942 <truncate1+0x1f4>
  unlink("truncfile");
     866:	00006517          	auipc	a0,0x6
     86a:	a5a50513          	addi	a0,a0,-1446 # 62c0 <malloc+0x4ea>
     86e:	00005097          	auipc	ra,0x5
     872:	16a080e7          	jalr	362(ra) # 59d8 <unlink>
  close(fd1);
     876:	854e                	mv	a0,s3
     878:	00005097          	auipc	ra,0x5
     87c:	138080e7          	jalr	312(ra) # 59b0 <close>
  close(fd2);
     880:	8526                	mv	a0,s1
     882:	00005097          	auipc	ra,0x5
     886:	12e080e7          	jalr	302(ra) # 59b0 <close>
  close(fd3);
     88a:	854a                	mv	a0,s2
     88c:	00005097          	auipc	ra,0x5
     890:	124080e7          	jalr	292(ra) # 59b0 <close>
}
     894:	60e6                	ld	ra,88(sp)
     896:	6446                	ld	s0,80(sp)
     898:	64a6                	ld	s1,72(sp)
     89a:	6906                	ld	s2,64(sp)
     89c:	79e2                	ld	s3,56(sp)
     89e:	7a42                	ld	s4,48(sp)
     8a0:	7aa2                	ld	s5,40(sp)
     8a2:	6125                	addi	sp,sp,96
     8a4:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     8a6:	862a                	mv	a2,a0
     8a8:	85d6                	mv	a1,s5
     8aa:	00006517          	auipc	a0,0x6
     8ae:	c0e50513          	addi	a0,a0,-1010 # 64b8 <malloc+0x6e2>
     8b2:	00005097          	auipc	ra,0x5
     8b6:	466080e7          	jalr	1126(ra) # 5d18 <printf>
    exit(1);
     8ba:	4505                	li	a0,1
     8bc:	00005097          	auipc	ra,0x5
     8c0:	0cc080e7          	jalr	204(ra) # 5988 <exit>
    printf("aaa fd3=%d\n", fd3);
     8c4:	85ca                	mv	a1,s2
     8c6:	00006517          	auipc	a0,0x6
     8ca:	c1250513          	addi	a0,a0,-1006 # 64d8 <malloc+0x702>
     8ce:	00005097          	auipc	ra,0x5
     8d2:	44a080e7          	jalr	1098(ra) # 5d18 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     8d6:	8652                	mv	a2,s4
     8d8:	85d6                	mv	a1,s5
     8da:	00006517          	auipc	a0,0x6
     8de:	c0e50513          	addi	a0,a0,-1010 # 64e8 <malloc+0x712>
     8e2:	00005097          	auipc	ra,0x5
     8e6:	436080e7          	jalr	1078(ra) # 5d18 <printf>
    exit(1);
     8ea:	4505                	li	a0,1
     8ec:	00005097          	auipc	ra,0x5
     8f0:	09c080e7          	jalr	156(ra) # 5988 <exit>
    printf("bbb fd2=%d\n", fd2);
     8f4:	85a6                	mv	a1,s1
     8f6:	00006517          	auipc	a0,0x6
     8fa:	c1250513          	addi	a0,a0,-1006 # 6508 <malloc+0x732>
     8fe:	00005097          	auipc	ra,0x5
     902:	41a080e7          	jalr	1050(ra) # 5d18 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     906:	8652                	mv	a2,s4
     908:	85d6                	mv	a1,s5
     90a:	00006517          	auipc	a0,0x6
     90e:	bde50513          	addi	a0,a0,-1058 # 64e8 <malloc+0x712>
     912:	00005097          	auipc	ra,0x5
     916:	406080e7          	jalr	1030(ra) # 5d18 <printf>
    exit(1);
     91a:	4505                	li	a0,1
     91c:	00005097          	auipc	ra,0x5
     920:	06c080e7          	jalr	108(ra) # 5988 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     924:	862a                	mv	a2,a0
     926:	85d6                	mv	a1,s5
     928:	00006517          	auipc	a0,0x6
     92c:	bf850513          	addi	a0,a0,-1032 # 6520 <malloc+0x74a>
     930:	00005097          	auipc	ra,0x5
     934:	3e8080e7          	jalr	1000(ra) # 5d18 <printf>
    exit(1);
     938:	4505                	li	a0,1
     93a:	00005097          	auipc	ra,0x5
     93e:	04e080e7          	jalr	78(ra) # 5988 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     942:	862a                	mv	a2,a0
     944:	85d6                	mv	a1,s5
     946:	00006517          	auipc	a0,0x6
     94a:	bfa50513          	addi	a0,a0,-1030 # 6540 <malloc+0x76a>
     94e:	00005097          	auipc	ra,0x5
     952:	3ca080e7          	jalr	970(ra) # 5d18 <printf>
    exit(1);
     956:	4505                	li	a0,1
     958:	00005097          	auipc	ra,0x5
     95c:	030080e7          	jalr	48(ra) # 5988 <exit>

0000000000000960 <writetest>:
{
     960:	7139                	addi	sp,sp,-64
     962:	fc06                	sd	ra,56(sp)
     964:	f822                	sd	s0,48(sp)
     966:	f426                	sd	s1,40(sp)
     968:	f04a                	sd	s2,32(sp)
     96a:	ec4e                	sd	s3,24(sp)
     96c:	e852                	sd	s4,16(sp)
     96e:	e456                	sd	s5,8(sp)
     970:	e05a                	sd	s6,0(sp)
     972:	0080                	addi	s0,sp,64
     974:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     976:	20200593          	li	a1,514
     97a:	00006517          	auipc	a0,0x6
     97e:	be650513          	addi	a0,a0,-1050 # 6560 <malloc+0x78a>
     982:	00005097          	auipc	ra,0x5
     986:	046080e7          	jalr	70(ra) # 59c8 <open>
  if(fd < 0){
     98a:	0a054d63          	bltz	a0,a44 <writetest+0xe4>
     98e:	892a                	mv	s2,a0
     990:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     992:	00006997          	auipc	s3,0x6
     996:	bf698993          	addi	s3,s3,-1034 # 6588 <malloc+0x7b2>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     99a:	00006a97          	auipc	s5,0x6
     99e:	c26a8a93          	addi	s5,s5,-986 # 65c0 <malloc+0x7ea>
  for(i = 0; i < N; i++){
     9a2:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     9a6:	4629                	li	a2,10
     9a8:	85ce                	mv	a1,s3
     9aa:	854a                	mv	a0,s2
     9ac:	00005097          	auipc	ra,0x5
     9b0:	ffc080e7          	jalr	-4(ra) # 59a8 <write>
     9b4:	47a9                	li	a5,10
     9b6:	0af51563          	bne	a0,a5,a60 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     9ba:	4629                	li	a2,10
     9bc:	85d6                	mv	a1,s5
     9be:	854a                	mv	a0,s2
     9c0:	00005097          	auipc	ra,0x5
     9c4:	fe8080e7          	jalr	-24(ra) # 59a8 <write>
     9c8:	47a9                	li	a5,10
     9ca:	0af51a63          	bne	a0,a5,a7e <writetest+0x11e>
  for(i = 0; i < N; i++){
     9ce:	2485                	addiw	s1,s1,1
     9d0:	fd449be3          	bne	s1,s4,9a6 <writetest+0x46>
  close(fd);
     9d4:	854a                	mv	a0,s2
     9d6:	00005097          	auipc	ra,0x5
     9da:	fda080e7          	jalr	-38(ra) # 59b0 <close>
  fd = open("small", O_RDONLY);
     9de:	4581                	li	a1,0
     9e0:	00006517          	auipc	a0,0x6
     9e4:	b8050513          	addi	a0,a0,-1152 # 6560 <malloc+0x78a>
     9e8:	00005097          	auipc	ra,0x5
     9ec:	fe0080e7          	jalr	-32(ra) # 59c8 <open>
     9f0:	84aa                	mv	s1,a0
  if(fd < 0){
     9f2:	0a054563          	bltz	a0,a9c <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     9f6:	7d000613          	li	a2,2000
     9fa:	0000b597          	auipc	a1,0xb
     9fe:	52658593          	addi	a1,a1,1318 # bf20 <buf>
     a02:	00005097          	auipc	ra,0x5
     a06:	f9e080e7          	jalr	-98(ra) # 59a0 <read>
  if(i != N*SZ*2){
     a0a:	7d000793          	li	a5,2000
     a0e:	0af51563          	bne	a0,a5,ab8 <writetest+0x158>
  close(fd);
     a12:	8526                	mv	a0,s1
     a14:	00005097          	auipc	ra,0x5
     a18:	f9c080e7          	jalr	-100(ra) # 59b0 <close>
  if(unlink("small") < 0){
     a1c:	00006517          	auipc	a0,0x6
     a20:	b4450513          	addi	a0,a0,-1212 # 6560 <malloc+0x78a>
     a24:	00005097          	auipc	ra,0x5
     a28:	fb4080e7          	jalr	-76(ra) # 59d8 <unlink>
     a2c:	0a054463          	bltz	a0,ad4 <writetest+0x174>
}
     a30:	70e2                	ld	ra,56(sp)
     a32:	7442                	ld	s0,48(sp)
     a34:	74a2                	ld	s1,40(sp)
     a36:	7902                	ld	s2,32(sp)
     a38:	69e2                	ld	s3,24(sp)
     a3a:	6a42                	ld	s4,16(sp)
     a3c:	6aa2                	ld	s5,8(sp)
     a3e:	6b02                	ld	s6,0(sp)
     a40:	6121                	addi	sp,sp,64
     a42:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     a44:	85da                	mv	a1,s6
     a46:	00006517          	auipc	a0,0x6
     a4a:	b2250513          	addi	a0,a0,-1246 # 6568 <malloc+0x792>
     a4e:	00005097          	auipc	ra,0x5
     a52:	2ca080e7          	jalr	714(ra) # 5d18 <printf>
    exit(1);
     a56:	4505                	li	a0,1
     a58:	00005097          	auipc	ra,0x5
     a5c:	f30080e7          	jalr	-208(ra) # 5988 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     a60:	8626                	mv	a2,s1
     a62:	85da                	mv	a1,s6
     a64:	00006517          	auipc	a0,0x6
     a68:	b3450513          	addi	a0,a0,-1228 # 6598 <malloc+0x7c2>
     a6c:	00005097          	auipc	ra,0x5
     a70:	2ac080e7          	jalr	684(ra) # 5d18 <printf>
      exit(1);
     a74:	4505                	li	a0,1
     a76:	00005097          	auipc	ra,0x5
     a7a:	f12080e7          	jalr	-238(ra) # 5988 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     a7e:	8626                	mv	a2,s1
     a80:	85da                	mv	a1,s6
     a82:	00006517          	auipc	a0,0x6
     a86:	b4e50513          	addi	a0,a0,-1202 # 65d0 <malloc+0x7fa>
     a8a:	00005097          	auipc	ra,0x5
     a8e:	28e080e7          	jalr	654(ra) # 5d18 <printf>
      exit(1);
     a92:	4505                	li	a0,1
     a94:	00005097          	auipc	ra,0x5
     a98:	ef4080e7          	jalr	-268(ra) # 5988 <exit>
    printf("%s: error: open small failed!\n", s);
     a9c:	85da                	mv	a1,s6
     a9e:	00006517          	auipc	a0,0x6
     aa2:	b5a50513          	addi	a0,a0,-1190 # 65f8 <malloc+0x822>
     aa6:	00005097          	auipc	ra,0x5
     aaa:	272080e7          	jalr	626(ra) # 5d18 <printf>
    exit(1);
     aae:	4505                	li	a0,1
     ab0:	00005097          	auipc	ra,0x5
     ab4:	ed8080e7          	jalr	-296(ra) # 5988 <exit>
    printf("%s: read failed\n", s);
     ab8:	85da                	mv	a1,s6
     aba:	00006517          	auipc	a0,0x6
     abe:	b5e50513          	addi	a0,a0,-1186 # 6618 <malloc+0x842>
     ac2:	00005097          	auipc	ra,0x5
     ac6:	256080e7          	jalr	598(ra) # 5d18 <printf>
    exit(1);
     aca:	4505                	li	a0,1
     acc:	00005097          	auipc	ra,0x5
     ad0:	ebc080e7          	jalr	-324(ra) # 5988 <exit>
    printf("%s: unlink small failed\n", s);
     ad4:	85da                	mv	a1,s6
     ad6:	00006517          	auipc	a0,0x6
     ada:	b5a50513          	addi	a0,a0,-1190 # 6630 <malloc+0x85a>
     ade:	00005097          	auipc	ra,0x5
     ae2:	23a080e7          	jalr	570(ra) # 5d18 <printf>
    exit(1);
     ae6:	4505                	li	a0,1
     ae8:	00005097          	auipc	ra,0x5
     aec:	ea0080e7          	jalr	-352(ra) # 5988 <exit>

0000000000000af0 <writebig>:
{
     af0:	7139                	addi	sp,sp,-64
     af2:	fc06                	sd	ra,56(sp)
     af4:	f822                	sd	s0,48(sp)
     af6:	f426                	sd	s1,40(sp)
     af8:	f04a                	sd	s2,32(sp)
     afa:	ec4e                	sd	s3,24(sp)
     afc:	e852                	sd	s4,16(sp)
     afe:	e456                	sd	s5,8(sp)
     b00:	0080                	addi	s0,sp,64
     b02:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     b04:	20200593          	li	a1,514
     b08:	00006517          	auipc	a0,0x6
     b0c:	b4850513          	addi	a0,a0,-1208 # 6650 <malloc+0x87a>
     b10:	00005097          	auipc	ra,0x5
     b14:	eb8080e7          	jalr	-328(ra) # 59c8 <open>
     b18:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     b1a:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     b1c:	0000b917          	auipc	s2,0xb
     b20:	40490913          	addi	s2,s2,1028 # bf20 <buf>
  for(i = 0; i < MAXFILE; i++){
     b24:	10c00a13          	li	s4,268
  if(fd < 0){
     b28:	06054c63          	bltz	a0,ba0 <writebig+0xb0>
    ((int*)buf)[0] = i;
     b2c:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     b30:	40000613          	li	a2,1024
     b34:	85ca                	mv	a1,s2
     b36:	854e                	mv	a0,s3
     b38:	00005097          	auipc	ra,0x5
     b3c:	e70080e7          	jalr	-400(ra) # 59a8 <write>
     b40:	40000793          	li	a5,1024
     b44:	06f51c63          	bne	a0,a5,bbc <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     b48:	2485                	addiw	s1,s1,1
     b4a:	ff4491e3          	bne	s1,s4,b2c <writebig+0x3c>
  close(fd);
     b4e:	854e                	mv	a0,s3
     b50:	00005097          	auipc	ra,0x5
     b54:	e60080e7          	jalr	-416(ra) # 59b0 <close>
  fd = open("big", O_RDONLY);
     b58:	4581                	li	a1,0
     b5a:	00006517          	auipc	a0,0x6
     b5e:	af650513          	addi	a0,a0,-1290 # 6650 <malloc+0x87a>
     b62:	00005097          	auipc	ra,0x5
     b66:	e66080e7          	jalr	-410(ra) # 59c8 <open>
     b6a:	89aa                	mv	s3,a0
  n = 0;
     b6c:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     b6e:	0000b917          	auipc	s2,0xb
     b72:	3b290913          	addi	s2,s2,946 # bf20 <buf>
  if(fd < 0){
     b76:	06054263          	bltz	a0,bda <writebig+0xea>
    i = read(fd, buf, BSIZE);
     b7a:	40000613          	li	a2,1024
     b7e:	85ca                	mv	a1,s2
     b80:	854e                	mv	a0,s3
     b82:	00005097          	auipc	ra,0x5
     b86:	e1e080e7          	jalr	-482(ra) # 59a0 <read>
    if(i == 0){
     b8a:	c535                	beqz	a0,bf6 <writebig+0x106>
    } else if(i != BSIZE){
     b8c:	40000793          	li	a5,1024
     b90:	0af51f63          	bne	a0,a5,c4e <writebig+0x15e>
    if(((int*)buf)[0] != n){
     b94:	00092683          	lw	a3,0(s2)
     b98:	0c969a63          	bne	a3,s1,c6c <writebig+0x17c>
    n++;
     b9c:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     b9e:	bff1                	j	b7a <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     ba0:	85d6                	mv	a1,s5
     ba2:	00006517          	auipc	a0,0x6
     ba6:	ab650513          	addi	a0,a0,-1354 # 6658 <malloc+0x882>
     baa:	00005097          	auipc	ra,0x5
     bae:	16e080e7          	jalr	366(ra) # 5d18 <printf>
    exit(1);
     bb2:	4505                	li	a0,1
     bb4:	00005097          	auipc	ra,0x5
     bb8:	dd4080e7          	jalr	-556(ra) # 5988 <exit>
      printf("%s: error: write big file failed\n", s, i);
     bbc:	8626                	mv	a2,s1
     bbe:	85d6                	mv	a1,s5
     bc0:	00006517          	auipc	a0,0x6
     bc4:	ab850513          	addi	a0,a0,-1352 # 6678 <malloc+0x8a2>
     bc8:	00005097          	auipc	ra,0x5
     bcc:	150080e7          	jalr	336(ra) # 5d18 <printf>
      exit(1);
     bd0:	4505                	li	a0,1
     bd2:	00005097          	auipc	ra,0x5
     bd6:	db6080e7          	jalr	-586(ra) # 5988 <exit>
    printf("%s: error: open big failed!\n", s);
     bda:	85d6                	mv	a1,s5
     bdc:	00006517          	auipc	a0,0x6
     be0:	ac450513          	addi	a0,a0,-1340 # 66a0 <malloc+0x8ca>
     be4:	00005097          	auipc	ra,0x5
     be8:	134080e7          	jalr	308(ra) # 5d18 <printf>
    exit(1);
     bec:	4505                	li	a0,1
     bee:	00005097          	auipc	ra,0x5
     bf2:	d9a080e7          	jalr	-614(ra) # 5988 <exit>
      if(n == MAXFILE - 1){
     bf6:	10b00793          	li	a5,267
     bfa:	02f48a63          	beq	s1,a5,c2e <writebig+0x13e>
  close(fd);
     bfe:	854e                	mv	a0,s3
     c00:	00005097          	auipc	ra,0x5
     c04:	db0080e7          	jalr	-592(ra) # 59b0 <close>
  if(unlink("big") < 0){
     c08:	00006517          	auipc	a0,0x6
     c0c:	a4850513          	addi	a0,a0,-1464 # 6650 <malloc+0x87a>
     c10:	00005097          	auipc	ra,0x5
     c14:	dc8080e7          	jalr	-568(ra) # 59d8 <unlink>
     c18:	06054963          	bltz	a0,c8a <writebig+0x19a>
}
     c1c:	70e2                	ld	ra,56(sp)
     c1e:	7442                	ld	s0,48(sp)
     c20:	74a2                	ld	s1,40(sp)
     c22:	7902                	ld	s2,32(sp)
     c24:	69e2                	ld	s3,24(sp)
     c26:	6a42                	ld	s4,16(sp)
     c28:	6aa2                	ld	s5,8(sp)
     c2a:	6121                	addi	sp,sp,64
     c2c:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     c2e:	10b00613          	li	a2,267
     c32:	85d6                	mv	a1,s5
     c34:	00006517          	auipc	a0,0x6
     c38:	a8c50513          	addi	a0,a0,-1396 # 66c0 <malloc+0x8ea>
     c3c:	00005097          	auipc	ra,0x5
     c40:	0dc080e7          	jalr	220(ra) # 5d18 <printf>
        exit(1);
     c44:	4505                	li	a0,1
     c46:	00005097          	auipc	ra,0x5
     c4a:	d42080e7          	jalr	-702(ra) # 5988 <exit>
      printf("%s: read failed %d\n", s, i);
     c4e:	862a                	mv	a2,a0
     c50:	85d6                	mv	a1,s5
     c52:	00006517          	auipc	a0,0x6
     c56:	a9650513          	addi	a0,a0,-1386 # 66e8 <malloc+0x912>
     c5a:	00005097          	auipc	ra,0x5
     c5e:	0be080e7          	jalr	190(ra) # 5d18 <printf>
      exit(1);
     c62:	4505                	li	a0,1
     c64:	00005097          	auipc	ra,0x5
     c68:	d24080e7          	jalr	-732(ra) # 5988 <exit>
      printf("%s: read content of block %d is %d\n", s,
     c6c:	8626                	mv	a2,s1
     c6e:	85d6                	mv	a1,s5
     c70:	00006517          	auipc	a0,0x6
     c74:	a9050513          	addi	a0,a0,-1392 # 6700 <malloc+0x92a>
     c78:	00005097          	auipc	ra,0x5
     c7c:	0a0080e7          	jalr	160(ra) # 5d18 <printf>
      exit(1);
     c80:	4505                	li	a0,1
     c82:	00005097          	auipc	ra,0x5
     c86:	d06080e7          	jalr	-762(ra) # 5988 <exit>
    printf("%s: unlink big failed\n", s);
     c8a:	85d6                	mv	a1,s5
     c8c:	00006517          	auipc	a0,0x6
     c90:	a9c50513          	addi	a0,a0,-1380 # 6728 <malloc+0x952>
     c94:	00005097          	auipc	ra,0x5
     c98:	084080e7          	jalr	132(ra) # 5d18 <printf>
    exit(1);
     c9c:	4505                	li	a0,1
     c9e:	00005097          	auipc	ra,0x5
     ca2:	cea080e7          	jalr	-790(ra) # 5988 <exit>

0000000000000ca6 <unlinkread>:
{
     ca6:	7179                	addi	sp,sp,-48
     ca8:	f406                	sd	ra,40(sp)
     caa:	f022                	sd	s0,32(sp)
     cac:	ec26                	sd	s1,24(sp)
     cae:	e84a                	sd	s2,16(sp)
     cb0:	e44e                	sd	s3,8(sp)
     cb2:	1800                	addi	s0,sp,48
     cb4:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     cb6:	20200593          	li	a1,514
     cba:	00005517          	auipc	a0,0x5
     cbe:	37650513          	addi	a0,a0,886 # 6030 <malloc+0x25a>
     cc2:	00005097          	auipc	ra,0x5
     cc6:	d06080e7          	jalr	-762(ra) # 59c8 <open>
  if(fd < 0){
     cca:	0e054563          	bltz	a0,db4 <unlinkread+0x10e>
     cce:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     cd0:	4615                	li	a2,5
     cd2:	00006597          	auipc	a1,0x6
     cd6:	a8e58593          	addi	a1,a1,-1394 # 6760 <malloc+0x98a>
     cda:	00005097          	auipc	ra,0x5
     cde:	cce080e7          	jalr	-818(ra) # 59a8 <write>
  close(fd);
     ce2:	8526                	mv	a0,s1
     ce4:	00005097          	auipc	ra,0x5
     ce8:	ccc080e7          	jalr	-820(ra) # 59b0 <close>
  fd = open("unlinkread", O_RDWR);
     cec:	4589                	li	a1,2
     cee:	00005517          	auipc	a0,0x5
     cf2:	34250513          	addi	a0,a0,834 # 6030 <malloc+0x25a>
     cf6:	00005097          	auipc	ra,0x5
     cfa:	cd2080e7          	jalr	-814(ra) # 59c8 <open>
     cfe:	84aa                	mv	s1,a0
  if(fd < 0){
     d00:	0c054863          	bltz	a0,dd0 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     d04:	00005517          	auipc	a0,0x5
     d08:	32c50513          	addi	a0,a0,812 # 6030 <malloc+0x25a>
     d0c:	00005097          	auipc	ra,0x5
     d10:	ccc080e7          	jalr	-820(ra) # 59d8 <unlink>
     d14:	ed61                	bnez	a0,dec <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     d16:	20200593          	li	a1,514
     d1a:	00005517          	auipc	a0,0x5
     d1e:	31650513          	addi	a0,a0,790 # 6030 <malloc+0x25a>
     d22:	00005097          	auipc	ra,0x5
     d26:	ca6080e7          	jalr	-858(ra) # 59c8 <open>
     d2a:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     d2c:	460d                	li	a2,3
     d2e:	00006597          	auipc	a1,0x6
     d32:	a7a58593          	addi	a1,a1,-1414 # 67a8 <malloc+0x9d2>
     d36:	00005097          	auipc	ra,0x5
     d3a:	c72080e7          	jalr	-910(ra) # 59a8 <write>
  close(fd1);
     d3e:	854a                	mv	a0,s2
     d40:	00005097          	auipc	ra,0x5
     d44:	c70080e7          	jalr	-912(ra) # 59b0 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     d48:	660d                	lui	a2,0x3
     d4a:	0000b597          	auipc	a1,0xb
     d4e:	1d658593          	addi	a1,a1,470 # bf20 <buf>
     d52:	8526                	mv	a0,s1
     d54:	00005097          	auipc	ra,0x5
     d58:	c4c080e7          	jalr	-948(ra) # 59a0 <read>
     d5c:	4795                	li	a5,5
     d5e:	0af51563          	bne	a0,a5,e08 <unlinkread+0x162>
  if(buf[0] != 'h'){
     d62:	0000b717          	auipc	a4,0xb
     d66:	1be74703          	lbu	a4,446(a4) # bf20 <buf>
     d6a:	06800793          	li	a5,104
     d6e:	0af71b63          	bne	a4,a5,e24 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     d72:	4629                	li	a2,10
     d74:	0000b597          	auipc	a1,0xb
     d78:	1ac58593          	addi	a1,a1,428 # bf20 <buf>
     d7c:	8526                	mv	a0,s1
     d7e:	00005097          	auipc	ra,0x5
     d82:	c2a080e7          	jalr	-982(ra) # 59a8 <write>
     d86:	47a9                	li	a5,10
     d88:	0af51c63          	bne	a0,a5,e40 <unlinkread+0x19a>
  close(fd);
     d8c:	8526                	mv	a0,s1
     d8e:	00005097          	auipc	ra,0x5
     d92:	c22080e7          	jalr	-990(ra) # 59b0 <close>
  unlink("unlinkread");
     d96:	00005517          	auipc	a0,0x5
     d9a:	29a50513          	addi	a0,a0,666 # 6030 <malloc+0x25a>
     d9e:	00005097          	auipc	ra,0x5
     da2:	c3a080e7          	jalr	-966(ra) # 59d8 <unlink>
}
     da6:	70a2                	ld	ra,40(sp)
     da8:	7402                	ld	s0,32(sp)
     daa:	64e2                	ld	s1,24(sp)
     dac:	6942                	ld	s2,16(sp)
     dae:	69a2                	ld	s3,8(sp)
     db0:	6145                	addi	sp,sp,48
     db2:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     db4:	85ce                	mv	a1,s3
     db6:	00006517          	auipc	a0,0x6
     dba:	98a50513          	addi	a0,a0,-1654 # 6740 <malloc+0x96a>
     dbe:	00005097          	auipc	ra,0x5
     dc2:	f5a080e7          	jalr	-166(ra) # 5d18 <printf>
    exit(1);
     dc6:	4505                	li	a0,1
     dc8:	00005097          	auipc	ra,0x5
     dcc:	bc0080e7          	jalr	-1088(ra) # 5988 <exit>
    printf("%s: open unlinkread failed\n", s);
     dd0:	85ce                	mv	a1,s3
     dd2:	00006517          	auipc	a0,0x6
     dd6:	99650513          	addi	a0,a0,-1642 # 6768 <malloc+0x992>
     dda:	00005097          	auipc	ra,0x5
     dde:	f3e080e7          	jalr	-194(ra) # 5d18 <printf>
    exit(1);
     de2:	4505                	li	a0,1
     de4:	00005097          	auipc	ra,0x5
     de8:	ba4080e7          	jalr	-1116(ra) # 5988 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     dec:	85ce                	mv	a1,s3
     dee:	00006517          	auipc	a0,0x6
     df2:	99a50513          	addi	a0,a0,-1638 # 6788 <malloc+0x9b2>
     df6:	00005097          	auipc	ra,0x5
     dfa:	f22080e7          	jalr	-222(ra) # 5d18 <printf>
    exit(1);
     dfe:	4505                	li	a0,1
     e00:	00005097          	auipc	ra,0x5
     e04:	b88080e7          	jalr	-1144(ra) # 5988 <exit>
    printf("%s: unlinkread read failed", s);
     e08:	85ce                	mv	a1,s3
     e0a:	00006517          	auipc	a0,0x6
     e0e:	9a650513          	addi	a0,a0,-1626 # 67b0 <malloc+0x9da>
     e12:	00005097          	auipc	ra,0x5
     e16:	f06080e7          	jalr	-250(ra) # 5d18 <printf>
    exit(1);
     e1a:	4505                	li	a0,1
     e1c:	00005097          	auipc	ra,0x5
     e20:	b6c080e7          	jalr	-1172(ra) # 5988 <exit>
    printf("%s: unlinkread wrong data\n", s);
     e24:	85ce                	mv	a1,s3
     e26:	00006517          	auipc	a0,0x6
     e2a:	9aa50513          	addi	a0,a0,-1622 # 67d0 <malloc+0x9fa>
     e2e:	00005097          	auipc	ra,0x5
     e32:	eea080e7          	jalr	-278(ra) # 5d18 <printf>
    exit(1);
     e36:	4505                	li	a0,1
     e38:	00005097          	auipc	ra,0x5
     e3c:	b50080e7          	jalr	-1200(ra) # 5988 <exit>
    printf("%s: unlinkread write failed\n", s);
     e40:	85ce                	mv	a1,s3
     e42:	00006517          	auipc	a0,0x6
     e46:	9ae50513          	addi	a0,a0,-1618 # 67f0 <malloc+0xa1a>
     e4a:	00005097          	auipc	ra,0x5
     e4e:	ece080e7          	jalr	-306(ra) # 5d18 <printf>
    exit(1);
     e52:	4505                	li	a0,1
     e54:	00005097          	auipc	ra,0x5
     e58:	b34080e7          	jalr	-1228(ra) # 5988 <exit>

0000000000000e5c <linktest>:
{
     e5c:	1101                	addi	sp,sp,-32
     e5e:	ec06                	sd	ra,24(sp)
     e60:	e822                	sd	s0,16(sp)
     e62:	e426                	sd	s1,8(sp)
     e64:	e04a                	sd	s2,0(sp)
     e66:	1000                	addi	s0,sp,32
     e68:	892a                	mv	s2,a0
  unlink("lf1");
     e6a:	00006517          	auipc	a0,0x6
     e6e:	9a650513          	addi	a0,a0,-1626 # 6810 <malloc+0xa3a>
     e72:	00005097          	auipc	ra,0x5
     e76:	b66080e7          	jalr	-1178(ra) # 59d8 <unlink>
  unlink("lf2");
     e7a:	00006517          	auipc	a0,0x6
     e7e:	99e50513          	addi	a0,a0,-1634 # 6818 <malloc+0xa42>
     e82:	00005097          	auipc	ra,0x5
     e86:	b56080e7          	jalr	-1194(ra) # 59d8 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     e8a:	20200593          	li	a1,514
     e8e:	00006517          	auipc	a0,0x6
     e92:	98250513          	addi	a0,a0,-1662 # 6810 <malloc+0xa3a>
     e96:	00005097          	auipc	ra,0x5
     e9a:	b32080e7          	jalr	-1230(ra) # 59c8 <open>
  if(fd < 0){
     e9e:	10054763          	bltz	a0,fac <linktest+0x150>
     ea2:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     ea4:	4615                	li	a2,5
     ea6:	00006597          	auipc	a1,0x6
     eaa:	8ba58593          	addi	a1,a1,-1862 # 6760 <malloc+0x98a>
     eae:	00005097          	auipc	ra,0x5
     eb2:	afa080e7          	jalr	-1286(ra) # 59a8 <write>
     eb6:	4795                	li	a5,5
     eb8:	10f51863          	bne	a0,a5,fc8 <linktest+0x16c>
  close(fd);
     ebc:	8526                	mv	a0,s1
     ebe:	00005097          	auipc	ra,0x5
     ec2:	af2080e7          	jalr	-1294(ra) # 59b0 <close>
  if(link("lf1", "lf2") < 0){
     ec6:	00006597          	auipc	a1,0x6
     eca:	95258593          	addi	a1,a1,-1710 # 6818 <malloc+0xa42>
     ece:	00006517          	auipc	a0,0x6
     ed2:	94250513          	addi	a0,a0,-1726 # 6810 <malloc+0xa3a>
     ed6:	00005097          	auipc	ra,0x5
     eda:	b12080e7          	jalr	-1262(ra) # 59e8 <link>
     ede:	10054363          	bltz	a0,fe4 <linktest+0x188>
  unlink("lf1");
     ee2:	00006517          	auipc	a0,0x6
     ee6:	92e50513          	addi	a0,a0,-1746 # 6810 <malloc+0xa3a>
     eea:	00005097          	auipc	ra,0x5
     eee:	aee080e7          	jalr	-1298(ra) # 59d8 <unlink>
  if(open("lf1", 0) >= 0){
     ef2:	4581                	li	a1,0
     ef4:	00006517          	auipc	a0,0x6
     ef8:	91c50513          	addi	a0,a0,-1764 # 6810 <malloc+0xa3a>
     efc:	00005097          	auipc	ra,0x5
     f00:	acc080e7          	jalr	-1332(ra) # 59c8 <open>
     f04:	0e055e63          	bgez	a0,1000 <linktest+0x1a4>
  fd = open("lf2", 0);
     f08:	4581                	li	a1,0
     f0a:	00006517          	auipc	a0,0x6
     f0e:	90e50513          	addi	a0,a0,-1778 # 6818 <malloc+0xa42>
     f12:	00005097          	auipc	ra,0x5
     f16:	ab6080e7          	jalr	-1354(ra) # 59c8 <open>
     f1a:	84aa                	mv	s1,a0
  if(fd < 0){
     f1c:	10054063          	bltz	a0,101c <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     f20:	660d                	lui	a2,0x3
     f22:	0000b597          	auipc	a1,0xb
     f26:	ffe58593          	addi	a1,a1,-2 # bf20 <buf>
     f2a:	00005097          	auipc	ra,0x5
     f2e:	a76080e7          	jalr	-1418(ra) # 59a0 <read>
     f32:	4795                	li	a5,5
     f34:	10f51263          	bne	a0,a5,1038 <linktest+0x1dc>
  close(fd);
     f38:	8526                	mv	a0,s1
     f3a:	00005097          	auipc	ra,0x5
     f3e:	a76080e7          	jalr	-1418(ra) # 59b0 <close>
  if(link("lf2", "lf2") >= 0){
     f42:	00006597          	auipc	a1,0x6
     f46:	8d658593          	addi	a1,a1,-1834 # 6818 <malloc+0xa42>
     f4a:	852e                	mv	a0,a1
     f4c:	00005097          	auipc	ra,0x5
     f50:	a9c080e7          	jalr	-1380(ra) # 59e8 <link>
     f54:	10055063          	bgez	a0,1054 <linktest+0x1f8>
  unlink("lf2");
     f58:	00006517          	auipc	a0,0x6
     f5c:	8c050513          	addi	a0,a0,-1856 # 6818 <malloc+0xa42>
     f60:	00005097          	auipc	ra,0x5
     f64:	a78080e7          	jalr	-1416(ra) # 59d8 <unlink>
  if(link("lf2", "lf1") >= 0){
     f68:	00006597          	auipc	a1,0x6
     f6c:	8a858593          	addi	a1,a1,-1880 # 6810 <malloc+0xa3a>
     f70:	00006517          	auipc	a0,0x6
     f74:	8a850513          	addi	a0,a0,-1880 # 6818 <malloc+0xa42>
     f78:	00005097          	auipc	ra,0x5
     f7c:	a70080e7          	jalr	-1424(ra) # 59e8 <link>
     f80:	0e055863          	bgez	a0,1070 <linktest+0x214>
  if(link(".", "lf1") >= 0){
     f84:	00006597          	auipc	a1,0x6
     f88:	88c58593          	addi	a1,a1,-1908 # 6810 <malloc+0xa3a>
     f8c:	00006517          	auipc	a0,0x6
     f90:	99450513          	addi	a0,a0,-1644 # 6920 <malloc+0xb4a>
     f94:	00005097          	auipc	ra,0x5
     f98:	a54080e7          	jalr	-1452(ra) # 59e8 <link>
     f9c:	0e055863          	bgez	a0,108c <linktest+0x230>
}
     fa0:	60e2                	ld	ra,24(sp)
     fa2:	6442                	ld	s0,16(sp)
     fa4:	64a2                	ld	s1,8(sp)
     fa6:	6902                	ld	s2,0(sp)
     fa8:	6105                	addi	sp,sp,32
     faa:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     fac:	85ca                	mv	a1,s2
     fae:	00006517          	auipc	a0,0x6
     fb2:	87250513          	addi	a0,a0,-1934 # 6820 <malloc+0xa4a>
     fb6:	00005097          	auipc	ra,0x5
     fba:	d62080e7          	jalr	-670(ra) # 5d18 <printf>
    exit(1);
     fbe:	4505                	li	a0,1
     fc0:	00005097          	auipc	ra,0x5
     fc4:	9c8080e7          	jalr	-1592(ra) # 5988 <exit>
    printf("%s: write lf1 failed\n", s);
     fc8:	85ca                	mv	a1,s2
     fca:	00006517          	auipc	a0,0x6
     fce:	86e50513          	addi	a0,a0,-1938 # 6838 <malloc+0xa62>
     fd2:	00005097          	auipc	ra,0x5
     fd6:	d46080e7          	jalr	-698(ra) # 5d18 <printf>
    exit(1);
     fda:	4505                	li	a0,1
     fdc:	00005097          	auipc	ra,0x5
     fe0:	9ac080e7          	jalr	-1620(ra) # 5988 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     fe4:	85ca                	mv	a1,s2
     fe6:	00006517          	auipc	a0,0x6
     fea:	86a50513          	addi	a0,a0,-1942 # 6850 <malloc+0xa7a>
     fee:	00005097          	auipc	ra,0x5
     ff2:	d2a080e7          	jalr	-726(ra) # 5d18 <printf>
    exit(1);
     ff6:	4505                	li	a0,1
     ff8:	00005097          	auipc	ra,0x5
     ffc:	990080e7          	jalr	-1648(ra) # 5988 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    1000:	85ca                	mv	a1,s2
    1002:	00006517          	auipc	a0,0x6
    1006:	86e50513          	addi	a0,a0,-1938 # 6870 <malloc+0xa9a>
    100a:	00005097          	auipc	ra,0x5
    100e:	d0e080e7          	jalr	-754(ra) # 5d18 <printf>
    exit(1);
    1012:	4505                	li	a0,1
    1014:	00005097          	auipc	ra,0x5
    1018:	974080e7          	jalr	-1676(ra) # 5988 <exit>
    printf("%s: open lf2 failed\n", s);
    101c:	85ca                	mv	a1,s2
    101e:	00006517          	auipc	a0,0x6
    1022:	88250513          	addi	a0,a0,-1918 # 68a0 <malloc+0xaca>
    1026:	00005097          	auipc	ra,0x5
    102a:	cf2080e7          	jalr	-782(ra) # 5d18 <printf>
    exit(1);
    102e:	4505                	li	a0,1
    1030:	00005097          	auipc	ra,0x5
    1034:	958080e7          	jalr	-1704(ra) # 5988 <exit>
    printf("%s: read lf2 failed\n", s);
    1038:	85ca                	mv	a1,s2
    103a:	00006517          	auipc	a0,0x6
    103e:	87e50513          	addi	a0,a0,-1922 # 68b8 <malloc+0xae2>
    1042:	00005097          	auipc	ra,0x5
    1046:	cd6080e7          	jalr	-810(ra) # 5d18 <printf>
    exit(1);
    104a:	4505                	li	a0,1
    104c:	00005097          	auipc	ra,0x5
    1050:	93c080e7          	jalr	-1732(ra) # 5988 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    1054:	85ca                	mv	a1,s2
    1056:	00006517          	auipc	a0,0x6
    105a:	87a50513          	addi	a0,a0,-1926 # 68d0 <malloc+0xafa>
    105e:	00005097          	auipc	ra,0x5
    1062:	cba080e7          	jalr	-838(ra) # 5d18 <printf>
    exit(1);
    1066:	4505                	li	a0,1
    1068:	00005097          	auipc	ra,0x5
    106c:	920080e7          	jalr	-1760(ra) # 5988 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    1070:	85ca                	mv	a1,s2
    1072:	00006517          	auipc	a0,0x6
    1076:	88650513          	addi	a0,a0,-1914 # 68f8 <malloc+0xb22>
    107a:	00005097          	auipc	ra,0x5
    107e:	c9e080e7          	jalr	-866(ra) # 5d18 <printf>
    exit(1);
    1082:	4505                	li	a0,1
    1084:	00005097          	auipc	ra,0x5
    1088:	904080e7          	jalr	-1788(ra) # 5988 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    108c:	85ca                	mv	a1,s2
    108e:	00006517          	auipc	a0,0x6
    1092:	89a50513          	addi	a0,a0,-1894 # 6928 <malloc+0xb52>
    1096:	00005097          	auipc	ra,0x5
    109a:	c82080e7          	jalr	-894(ra) # 5d18 <printf>
    exit(1);
    109e:	4505                	li	a0,1
    10a0:	00005097          	auipc	ra,0x5
    10a4:	8e8080e7          	jalr	-1816(ra) # 5988 <exit>

00000000000010a8 <bigdir>:
{
    10a8:	715d                	addi	sp,sp,-80
    10aa:	e486                	sd	ra,72(sp)
    10ac:	e0a2                	sd	s0,64(sp)
    10ae:	fc26                	sd	s1,56(sp)
    10b0:	f84a                	sd	s2,48(sp)
    10b2:	f44e                	sd	s3,40(sp)
    10b4:	f052                	sd	s4,32(sp)
    10b6:	ec56                	sd	s5,24(sp)
    10b8:	e85a                	sd	s6,16(sp)
    10ba:	0880                	addi	s0,sp,80
    10bc:	89aa                	mv	s3,a0
  unlink("bd");
    10be:	00006517          	auipc	a0,0x6
    10c2:	88a50513          	addi	a0,a0,-1910 # 6948 <malloc+0xb72>
    10c6:	00005097          	auipc	ra,0x5
    10ca:	912080e7          	jalr	-1774(ra) # 59d8 <unlink>
  fd = open("bd", O_CREATE);
    10ce:	20000593          	li	a1,512
    10d2:	00006517          	auipc	a0,0x6
    10d6:	87650513          	addi	a0,a0,-1930 # 6948 <malloc+0xb72>
    10da:	00005097          	auipc	ra,0x5
    10de:	8ee080e7          	jalr	-1810(ra) # 59c8 <open>
  if(fd < 0){
    10e2:	0c054963          	bltz	a0,11b4 <bigdir+0x10c>
  close(fd);
    10e6:	00005097          	auipc	ra,0x5
    10ea:	8ca080e7          	jalr	-1846(ra) # 59b0 <close>
  for(i = 0; i < N; i++){
    10ee:	4901                	li	s2,0
    name[0] = 'x';
    10f0:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    10f4:	00006a17          	auipc	s4,0x6
    10f8:	854a0a13          	addi	s4,s4,-1964 # 6948 <malloc+0xb72>
  for(i = 0; i < N; i++){
    10fc:	1f400b13          	li	s6,500
    name[0] = 'x';
    1100:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    1104:	41f9579b          	sraiw	a5,s2,0x1f
    1108:	01a7d71b          	srliw	a4,a5,0x1a
    110c:	012707bb          	addw	a5,a4,s2
    1110:	4067d69b          	sraiw	a3,a5,0x6
    1114:	0306869b          	addiw	a3,a3,48
    1118:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    111c:	03f7f793          	andi	a5,a5,63
    1120:	9f99                	subw	a5,a5,a4
    1122:	0307879b          	addiw	a5,a5,48
    1126:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    112a:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    112e:	fb040593          	addi	a1,s0,-80
    1132:	8552                	mv	a0,s4
    1134:	00005097          	auipc	ra,0x5
    1138:	8b4080e7          	jalr	-1868(ra) # 59e8 <link>
    113c:	84aa                	mv	s1,a0
    113e:	e949                	bnez	a0,11d0 <bigdir+0x128>
  for(i = 0; i < N; i++){
    1140:	2905                	addiw	s2,s2,1
    1142:	fb691fe3          	bne	s2,s6,1100 <bigdir+0x58>
  unlink("bd");
    1146:	00006517          	auipc	a0,0x6
    114a:	80250513          	addi	a0,a0,-2046 # 6948 <malloc+0xb72>
    114e:	00005097          	auipc	ra,0x5
    1152:	88a080e7          	jalr	-1910(ra) # 59d8 <unlink>
    name[0] = 'x';
    1156:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    115a:	1f400a13          	li	s4,500
    name[0] = 'x';
    115e:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1162:	41f4d79b          	sraiw	a5,s1,0x1f
    1166:	01a7d71b          	srliw	a4,a5,0x1a
    116a:	009707bb          	addw	a5,a4,s1
    116e:	4067d69b          	sraiw	a3,a5,0x6
    1172:	0306869b          	addiw	a3,a3,48
    1176:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    117a:	03f7f793          	andi	a5,a5,63
    117e:	9f99                	subw	a5,a5,a4
    1180:	0307879b          	addiw	a5,a5,48
    1184:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1188:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    118c:	fb040513          	addi	a0,s0,-80
    1190:	00005097          	auipc	ra,0x5
    1194:	848080e7          	jalr	-1976(ra) # 59d8 <unlink>
    1198:	ed21                	bnez	a0,11f0 <bigdir+0x148>
  for(i = 0; i < N; i++){
    119a:	2485                	addiw	s1,s1,1
    119c:	fd4491e3          	bne	s1,s4,115e <bigdir+0xb6>
}
    11a0:	60a6                	ld	ra,72(sp)
    11a2:	6406                	ld	s0,64(sp)
    11a4:	74e2                	ld	s1,56(sp)
    11a6:	7942                	ld	s2,48(sp)
    11a8:	79a2                	ld	s3,40(sp)
    11aa:	7a02                	ld	s4,32(sp)
    11ac:	6ae2                	ld	s5,24(sp)
    11ae:	6b42                	ld	s6,16(sp)
    11b0:	6161                	addi	sp,sp,80
    11b2:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    11b4:	85ce                	mv	a1,s3
    11b6:	00005517          	auipc	a0,0x5
    11ba:	79a50513          	addi	a0,a0,1946 # 6950 <malloc+0xb7a>
    11be:	00005097          	auipc	ra,0x5
    11c2:	b5a080e7          	jalr	-1190(ra) # 5d18 <printf>
    exit(1);
    11c6:	4505                	li	a0,1
    11c8:	00004097          	auipc	ra,0x4
    11cc:	7c0080e7          	jalr	1984(ra) # 5988 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    11d0:	fb040613          	addi	a2,s0,-80
    11d4:	85ce                	mv	a1,s3
    11d6:	00005517          	auipc	a0,0x5
    11da:	79a50513          	addi	a0,a0,1946 # 6970 <malloc+0xb9a>
    11de:	00005097          	auipc	ra,0x5
    11e2:	b3a080e7          	jalr	-1222(ra) # 5d18 <printf>
      exit(1);
    11e6:	4505                	li	a0,1
    11e8:	00004097          	auipc	ra,0x4
    11ec:	7a0080e7          	jalr	1952(ra) # 5988 <exit>
      printf("%s: bigdir unlink failed", s);
    11f0:	85ce                	mv	a1,s3
    11f2:	00005517          	auipc	a0,0x5
    11f6:	79e50513          	addi	a0,a0,1950 # 6990 <malloc+0xbba>
    11fa:	00005097          	auipc	ra,0x5
    11fe:	b1e080e7          	jalr	-1250(ra) # 5d18 <printf>
      exit(1);
    1202:	4505                	li	a0,1
    1204:	00004097          	auipc	ra,0x4
    1208:	784080e7          	jalr	1924(ra) # 5988 <exit>

000000000000120c <validatetest>:
{
    120c:	7139                	addi	sp,sp,-64
    120e:	fc06                	sd	ra,56(sp)
    1210:	f822                	sd	s0,48(sp)
    1212:	f426                	sd	s1,40(sp)
    1214:	f04a                	sd	s2,32(sp)
    1216:	ec4e                	sd	s3,24(sp)
    1218:	e852                	sd	s4,16(sp)
    121a:	e456                	sd	s5,8(sp)
    121c:	e05a                	sd	s6,0(sp)
    121e:	0080                	addi	s0,sp,64
    1220:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1222:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    1224:	00005997          	auipc	s3,0x5
    1228:	78c98993          	addi	s3,s3,1932 # 69b0 <malloc+0xbda>
    122c:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    122e:	6a85                	lui	s5,0x1
    1230:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1234:	85a6                	mv	a1,s1
    1236:	854e                	mv	a0,s3
    1238:	00004097          	auipc	ra,0x4
    123c:	7b0080e7          	jalr	1968(ra) # 59e8 <link>
    1240:	01251f63          	bne	a0,s2,125e <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1244:	94d6                	add	s1,s1,s5
    1246:	ff4497e3          	bne	s1,s4,1234 <validatetest+0x28>
}
    124a:	70e2                	ld	ra,56(sp)
    124c:	7442                	ld	s0,48(sp)
    124e:	74a2                	ld	s1,40(sp)
    1250:	7902                	ld	s2,32(sp)
    1252:	69e2                	ld	s3,24(sp)
    1254:	6a42                	ld	s4,16(sp)
    1256:	6aa2                	ld	s5,8(sp)
    1258:	6b02                	ld	s6,0(sp)
    125a:	6121                	addi	sp,sp,64
    125c:	8082                	ret
      printf("%s: link should not succeed\n", s);
    125e:	85da                	mv	a1,s6
    1260:	00005517          	auipc	a0,0x5
    1264:	76050513          	addi	a0,a0,1888 # 69c0 <malloc+0xbea>
    1268:	00005097          	auipc	ra,0x5
    126c:	ab0080e7          	jalr	-1360(ra) # 5d18 <printf>
      exit(1);
    1270:	4505                	li	a0,1
    1272:	00004097          	auipc	ra,0x4
    1276:	716080e7          	jalr	1814(ra) # 5988 <exit>

000000000000127a <pgbug>:
{
    127a:	7179                	addi	sp,sp,-48
    127c:	f406                	sd	ra,40(sp)
    127e:	f022                	sd	s0,32(sp)
    1280:	ec26                	sd	s1,24(sp)
    1282:	1800                	addi	s0,sp,48
  argv[0] = 0;
    1284:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1288:	00007497          	auipc	s1,0x7
    128c:	4704b483          	ld	s1,1136(s1) # 86f8 <__SDATA_BEGIN__>
    1290:	fd840593          	addi	a1,s0,-40
    1294:	8526                	mv	a0,s1
    1296:	00004097          	auipc	ra,0x4
    129a:	72a080e7          	jalr	1834(ra) # 59c0 <exec>
  pipe((int*)0xeaeb0b5b00002f5e);
    129e:	8526                	mv	a0,s1
    12a0:	00004097          	auipc	ra,0x4
    12a4:	6f8080e7          	jalr	1784(ra) # 5998 <pipe>
  exit(0);
    12a8:	4501                	li	a0,0
    12aa:	00004097          	auipc	ra,0x4
    12ae:	6de080e7          	jalr	1758(ra) # 5988 <exit>

00000000000012b2 <badarg>:
{
    12b2:	7139                	addi	sp,sp,-64
    12b4:	fc06                	sd	ra,56(sp)
    12b6:	f822                	sd	s0,48(sp)
    12b8:	f426                	sd	s1,40(sp)
    12ba:	f04a                	sd	s2,32(sp)
    12bc:	ec4e                	sd	s3,24(sp)
    12be:	0080                	addi	s0,sp,64
    12c0:	64b1                	lui	s1,0xc
    12c2:	35048493          	addi	s1,s1,848 # c350 <buf+0x430>
    argv[0] = (char*)0xffffffff;
    12c6:	597d                	li	s2,-1
    12c8:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    12cc:	00005997          	auipc	s3,0x5
    12d0:	f9c98993          	addi	s3,s3,-100 # 6268 <malloc+0x492>
    argv[0] = (char*)0xffffffff;
    12d4:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    12d8:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    12dc:	fc040593          	addi	a1,s0,-64
    12e0:	854e                	mv	a0,s3
    12e2:	00004097          	auipc	ra,0x4
    12e6:	6de080e7          	jalr	1758(ra) # 59c0 <exec>
  for(int i = 0; i < 50000; i++){
    12ea:	34fd                	addiw	s1,s1,-1
    12ec:	f4e5                	bnez	s1,12d4 <badarg+0x22>
  exit(0);
    12ee:	4501                	li	a0,0
    12f0:	00004097          	auipc	ra,0x4
    12f4:	698080e7          	jalr	1688(ra) # 5988 <exit>

00000000000012f8 <copyinstr2>:
{
    12f8:	7155                	addi	sp,sp,-208
    12fa:	e586                	sd	ra,200(sp)
    12fc:	e1a2                	sd	s0,192(sp)
    12fe:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    1300:	f6840793          	addi	a5,s0,-152
    1304:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    1308:	07800713          	li	a4,120
    130c:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    1310:	0785                	addi	a5,a5,1
    1312:	fed79de3          	bne	a5,a3,130c <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    1316:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    131a:	f6840513          	addi	a0,s0,-152
    131e:	00004097          	auipc	ra,0x4
    1322:	6ba080e7          	jalr	1722(ra) # 59d8 <unlink>
  if(ret != -1){
    1326:	57fd                	li	a5,-1
    1328:	0ef51063          	bne	a0,a5,1408 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    132c:	20100593          	li	a1,513
    1330:	f6840513          	addi	a0,s0,-152
    1334:	00004097          	auipc	ra,0x4
    1338:	694080e7          	jalr	1684(ra) # 59c8 <open>
  if(fd != -1){
    133c:	57fd                	li	a5,-1
    133e:	0ef51563          	bne	a0,a5,1428 <copyinstr2+0x130>
  ret = link(b, b);
    1342:	f6840593          	addi	a1,s0,-152
    1346:	852e                	mv	a0,a1
    1348:	00004097          	auipc	ra,0x4
    134c:	6a0080e7          	jalr	1696(ra) # 59e8 <link>
  if(ret != -1){
    1350:	57fd                	li	a5,-1
    1352:	0ef51b63          	bne	a0,a5,1448 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1356:	00007797          	auipc	a5,0x7
    135a:	85278793          	addi	a5,a5,-1966 # 7ba8 <malloc+0x1dd2>
    135e:	f4f43c23          	sd	a5,-168(s0)
    1362:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1366:	f5840593          	addi	a1,s0,-168
    136a:	f6840513          	addi	a0,s0,-152
    136e:	00004097          	auipc	ra,0x4
    1372:	652080e7          	jalr	1618(ra) # 59c0 <exec>
  if(ret != -1){
    1376:	57fd                	li	a5,-1
    1378:	0ef51963          	bne	a0,a5,146a <copyinstr2+0x172>
  int pid = fork();
    137c:	00004097          	auipc	ra,0x4
    1380:	604080e7          	jalr	1540(ra) # 5980 <fork>
  if(pid < 0){
    1384:	10054363          	bltz	a0,148a <copyinstr2+0x192>
  if(pid == 0){
    1388:	12051463          	bnez	a0,14b0 <copyinstr2+0x1b8>
    138c:	00007797          	auipc	a5,0x7
    1390:	47c78793          	addi	a5,a5,1148 # 8808 <big.0>
    1394:	00008697          	auipc	a3,0x8
    1398:	47468693          	addi	a3,a3,1140 # 9808 <__global_pointer$+0x910>
      big[i] = 'x';
    139c:	07800713          	li	a4,120
    13a0:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    13a4:	0785                	addi	a5,a5,1
    13a6:	fed79de3          	bne	a5,a3,13a0 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    13aa:	00008797          	auipc	a5,0x8
    13ae:	44078f23          	sb	zero,1118(a5) # 9808 <__global_pointer$+0x910>
    char *args2[] = { big, big, big, 0 };
    13b2:	00007797          	auipc	a5,0x7
    13b6:	f0678793          	addi	a5,a5,-250 # 82b8 <malloc+0x24e2>
    13ba:	6390                	ld	a2,0(a5)
    13bc:	6794                	ld	a3,8(a5)
    13be:	6b98                	ld	a4,16(a5)
    13c0:	6f9c                	ld	a5,24(a5)
    13c2:	f2c43823          	sd	a2,-208(s0)
    13c6:	f2d43c23          	sd	a3,-200(s0)
    13ca:	f4e43023          	sd	a4,-192(s0)
    13ce:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    13d2:	f3040593          	addi	a1,s0,-208
    13d6:	00005517          	auipc	a0,0x5
    13da:	e9250513          	addi	a0,a0,-366 # 6268 <malloc+0x492>
    13de:	00004097          	auipc	ra,0x4
    13e2:	5e2080e7          	jalr	1506(ra) # 59c0 <exec>
    if(ret != -1){
    13e6:	57fd                	li	a5,-1
    13e8:	0af50e63          	beq	a0,a5,14a4 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    13ec:	55fd                	li	a1,-1
    13ee:	00005517          	auipc	a0,0x5
    13f2:	67a50513          	addi	a0,a0,1658 # 6a68 <malloc+0xc92>
    13f6:	00005097          	auipc	ra,0x5
    13fa:	922080e7          	jalr	-1758(ra) # 5d18 <printf>
      exit(1);
    13fe:	4505                	li	a0,1
    1400:	00004097          	auipc	ra,0x4
    1404:	588080e7          	jalr	1416(ra) # 5988 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1408:	862a                	mv	a2,a0
    140a:	f6840593          	addi	a1,s0,-152
    140e:	00005517          	auipc	a0,0x5
    1412:	5d250513          	addi	a0,a0,1490 # 69e0 <malloc+0xc0a>
    1416:	00005097          	auipc	ra,0x5
    141a:	902080e7          	jalr	-1790(ra) # 5d18 <printf>
    exit(1);
    141e:	4505                	li	a0,1
    1420:	00004097          	auipc	ra,0x4
    1424:	568080e7          	jalr	1384(ra) # 5988 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1428:	862a                	mv	a2,a0
    142a:	f6840593          	addi	a1,s0,-152
    142e:	00005517          	auipc	a0,0x5
    1432:	5d250513          	addi	a0,a0,1490 # 6a00 <malloc+0xc2a>
    1436:	00005097          	auipc	ra,0x5
    143a:	8e2080e7          	jalr	-1822(ra) # 5d18 <printf>
    exit(1);
    143e:	4505                	li	a0,1
    1440:	00004097          	auipc	ra,0x4
    1444:	548080e7          	jalr	1352(ra) # 5988 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1448:	86aa                	mv	a3,a0
    144a:	f6840613          	addi	a2,s0,-152
    144e:	85b2                	mv	a1,a2
    1450:	00005517          	auipc	a0,0x5
    1454:	5d050513          	addi	a0,a0,1488 # 6a20 <malloc+0xc4a>
    1458:	00005097          	auipc	ra,0x5
    145c:	8c0080e7          	jalr	-1856(ra) # 5d18 <printf>
    exit(1);
    1460:	4505                	li	a0,1
    1462:	00004097          	auipc	ra,0x4
    1466:	526080e7          	jalr	1318(ra) # 5988 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    146a:	567d                	li	a2,-1
    146c:	f6840593          	addi	a1,s0,-152
    1470:	00005517          	auipc	a0,0x5
    1474:	5d850513          	addi	a0,a0,1496 # 6a48 <malloc+0xc72>
    1478:	00005097          	auipc	ra,0x5
    147c:	8a0080e7          	jalr	-1888(ra) # 5d18 <printf>
    exit(1);
    1480:	4505                	li	a0,1
    1482:	00004097          	auipc	ra,0x4
    1486:	506080e7          	jalr	1286(ra) # 5988 <exit>
    printf("fork failed\n");
    148a:	00006517          	auipc	a0,0x6
    148e:	a5650513          	addi	a0,a0,-1450 # 6ee0 <malloc+0x110a>
    1492:	00005097          	auipc	ra,0x5
    1496:	886080e7          	jalr	-1914(ra) # 5d18 <printf>
    exit(1);
    149a:	4505                	li	a0,1
    149c:	00004097          	auipc	ra,0x4
    14a0:	4ec080e7          	jalr	1260(ra) # 5988 <exit>
    exit(747); // OK
    14a4:	2eb00513          	li	a0,747
    14a8:	00004097          	auipc	ra,0x4
    14ac:	4e0080e7          	jalr	1248(ra) # 5988 <exit>
  int st = 0;
    14b0:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    14b4:	f5440513          	addi	a0,s0,-172
    14b8:	00004097          	auipc	ra,0x4
    14bc:	4d8080e7          	jalr	1240(ra) # 5990 <wait>
  if(st != 747){
    14c0:	f5442703          	lw	a4,-172(s0)
    14c4:	2eb00793          	li	a5,747
    14c8:	00f71663          	bne	a4,a5,14d4 <copyinstr2+0x1dc>
}
    14cc:	60ae                	ld	ra,200(sp)
    14ce:	640e                	ld	s0,192(sp)
    14d0:	6169                	addi	sp,sp,208
    14d2:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    14d4:	00005517          	auipc	a0,0x5
    14d8:	5bc50513          	addi	a0,a0,1468 # 6a90 <malloc+0xcba>
    14dc:	00005097          	auipc	ra,0x5
    14e0:	83c080e7          	jalr	-1988(ra) # 5d18 <printf>
    exit(1);
    14e4:	4505                	li	a0,1
    14e6:	00004097          	auipc	ra,0x4
    14ea:	4a2080e7          	jalr	1186(ra) # 5988 <exit>

00000000000014ee <truncate3>:
{
    14ee:	7159                	addi	sp,sp,-112
    14f0:	f486                	sd	ra,104(sp)
    14f2:	f0a2                	sd	s0,96(sp)
    14f4:	eca6                	sd	s1,88(sp)
    14f6:	e8ca                	sd	s2,80(sp)
    14f8:	e4ce                	sd	s3,72(sp)
    14fa:	e0d2                	sd	s4,64(sp)
    14fc:	fc56                	sd	s5,56(sp)
    14fe:	1880                	addi	s0,sp,112
    1500:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    1502:	60100593          	li	a1,1537
    1506:	00005517          	auipc	a0,0x5
    150a:	dba50513          	addi	a0,a0,-582 # 62c0 <malloc+0x4ea>
    150e:	00004097          	auipc	ra,0x4
    1512:	4ba080e7          	jalr	1210(ra) # 59c8 <open>
    1516:	00004097          	auipc	ra,0x4
    151a:	49a080e7          	jalr	1178(ra) # 59b0 <close>
  pid = fork();
    151e:	00004097          	auipc	ra,0x4
    1522:	462080e7          	jalr	1122(ra) # 5980 <fork>
  if(pid < 0){
    1526:	08054063          	bltz	a0,15a6 <truncate3+0xb8>
  if(pid == 0){
    152a:	e969                	bnez	a0,15fc <truncate3+0x10e>
    152c:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    1530:	00005a17          	auipc	s4,0x5
    1534:	d90a0a13          	addi	s4,s4,-624 # 62c0 <malloc+0x4ea>
      int n = write(fd, "1234567890", 10);
    1538:	00005a97          	auipc	s5,0x5
    153c:	5b8a8a93          	addi	s5,s5,1464 # 6af0 <malloc+0xd1a>
      int fd = open("truncfile", O_WRONLY);
    1540:	4585                	li	a1,1
    1542:	8552                	mv	a0,s4
    1544:	00004097          	auipc	ra,0x4
    1548:	484080e7          	jalr	1156(ra) # 59c8 <open>
    154c:	84aa                	mv	s1,a0
      if(fd < 0){
    154e:	06054a63          	bltz	a0,15c2 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1552:	4629                	li	a2,10
    1554:	85d6                	mv	a1,s5
    1556:	00004097          	auipc	ra,0x4
    155a:	452080e7          	jalr	1106(ra) # 59a8 <write>
      if(n != 10){
    155e:	47a9                	li	a5,10
    1560:	06f51f63          	bne	a0,a5,15de <truncate3+0xf0>
      close(fd);
    1564:	8526                	mv	a0,s1
    1566:	00004097          	auipc	ra,0x4
    156a:	44a080e7          	jalr	1098(ra) # 59b0 <close>
      fd = open("truncfile", O_RDONLY);
    156e:	4581                	li	a1,0
    1570:	8552                	mv	a0,s4
    1572:	00004097          	auipc	ra,0x4
    1576:	456080e7          	jalr	1110(ra) # 59c8 <open>
    157a:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    157c:	02000613          	li	a2,32
    1580:	f9840593          	addi	a1,s0,-104
    1584:	00004097          	auipc	ra,0x4
    1588:	41c080e7          	jalr	1052(ra) # 59a0 <read>
      close(fd);
    158c:	8526                	mv	a0,s1
    158e:	00004097          	auipc	ra,0x4
    1592:	422080e7          	jalr	1058(ra) # 59b0 <close>
    for(int i = 0; i < 100; i++){
    1596:	39fd                	addiw	s3,s3,-1
    1598:	fa0994e3          	bnez	s3,1540 <truncate3+0x52>
    exit(0);
    159c:	4501                	li	a0,0
    159e:	00004097          	auipc	ra,0x4
    15a2:	3ea080e7          	jalr	1002(ra) # 5988 <exit>
    printf("%s: fork failed\n", s);
    15a6:	85ca                	mv	a1,s2
    15a8:	00005517          	auipc	a0,0x5
    15ac:	51850513          	addi	a0,a0,1304 # 6ac0 <malloc+0xcea>
    15b0:	00004097          	auipc	ra,0x4
    15b4:	768080e7          	jalr	1896(ra) # 5d18 <printf>
    exit(1);
    15b8:	4505                	li	a0,1
    15ba:	00004097          	auipc	ra,0x4
    15be:	3ce080e7          	jalr	974(ra) # 5988 <exit>
        printf("%s: open failed\n", s);
    15c2:	85ca                	mv	a1,s2
    15c4:	00005517          	auipc	a0,0x5
    15c8:	51450513          	addi	a0,a0,1300 # 6ad8 <malloc+0xd02>
    15cc:	00004097          	auipc	ra,0x4
    15d0:	74c080e7          	jalr	1868(ra) # 5d18 <printf>
        exit(1);
    15d4:	4505                	li	a0,1
    15d6:	00004097          	auipc	ra,0x4
    15da:	3b2080e7          	jalr	946(ra) # 5988 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    15de:	862a                	mv	a2,a0
    15e0:	85ca                	mv	a1,s2
    15e2:	00005517          	auipc	a0,0x5
    15e6:	51e50513          	addi	a0,a0,1310 # 6b00 <malloc+0xd2a>
    15ea:	00004097          	auipc	ra,0x4
    15ee:	72e080e7          	jalr	1838(ra) # 5d18 <printf>
        exit(1);
    15f2:	4505                	li	a0,1
    15f4:	00004097          	auipc	ra,0x4
    15f8:	394080e7          	jalr	916(ra) # 5988 <exit>
    15fc:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    1600:	00005a17          	auipc	s4,0x5
    1604:	cc0a0a13          	addi	s4,s4,-832 # 62c0 <malloc+0x4ea>
    int n = write(fd, "xxx", 3);
    1608:	00005a97          	auipc	s5,0x5
    160c:	518a8a93          	addi	s5,s5,1304 # 6b20 <malloc+0xd4a>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    1610:	60100593          	li	a1,1537
    1614:	8552                	mv	a0,s4
    1616:	00004097          	auipc	ra,0x4
    161a:	3b2080e7          	jalr	946(ra) # 59c8 <open>
    161e:	84aa                	mv	s1,a0
    if(fd < 0){
    1620:	04054763          	bltz	a0,166e <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    1624:	460d                	li	a2,3
    1626:	85d6                	mv	a1,s5
    1628:	00004097          	auipc	ra,0x4
    162c:	380080e7          	jalr	896(ra) # 59a8 <write>
    if(n != 3){
    1630:	478d                	li	a5,3
    1632:	04f51c63          	bne	a0,a5,168a <truncate3+0x19c>
    close(fd);
    1636:	8526                	mv	a0,s1
    1638:	00004097          	auipc	ra,0x4
    163c:	378080e7          	jalr	888(ra) # 59b0 <close>
  for(int i = 0; i < 150; i++){
    1640:	39fd                	addiw	s3,s3,-1
    1642:	fc0997e3          	bnez	s3,1610 <truncate3+0x122>
  wait(&xstatus);
    1646:	fbc40513          	addi	a0,s0,-68
    164a:	00004097          	auipc	ra,0x4
    164e:	346080e7          	jalr	838(ra) # 5990 <wait>
  unlink("truncfile");
    1652:	00005517          	auipc	a0,0x5
    1656:	c6e50513          	addi	a0,a0,-914 # 62c0 <malloc+0x4ea>
    165a:	00004097          	auipc	ra,0x4
    165e:	37e080e7          	jalr	894(ra) # 59d8 <unlink>
  exit(xstatus);
    1662:	fbc42503          	lw	a0,-68(s0)
    1666:	00004097          	auipc	ra,0x4
    166a:	322080e7          	jalr	802(ra) # 5988 <exit>
      printf("%s: open failed\n", s);
    166e:	85ca                	mv	a1,s2
    1670:	00005517          	auipc	a0,0x5
    1674:	46850513          	addi	a0,a0,1128 # 6ad8 <malloc+0xd02>
    1678:	00004097          	auipc	ra,0x4
    167c:	6a0080e7          	jalr	1696(ra) # 5d18 <printf>
      exit(1);
    1680:	4505                	li	a0,1
    1682:	00004097          	auipc	ra,0x4
    1686:	306080e7          	jalr	774(ra) # 5988 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    168a:	862a                	mv	a2,a0
    168c:	85ca                	mv	a1,s2
    168e:	00005517          	auipc	a0,0x5
    1692:	49a50513          	addi	a0,a0,1178 # 6b28 <malloc+0xd52>
    1696:	00004097          	auipc	ra,0x4
    169a:	682080e7          	jalr	1666(ra) # 5d18 <printf>
      exit(1);
    169e:	4505                	li	a0,1
    16a0:	00004097          	auipc	ra,0x4
    16a4:	2e8080e7          	jalr	744(ra) # 5988 <exit>

00000000000016a8 <exectest>:
{
    16a8:	715d                	addi	sp,sp,-80
    16aa:	e486                	sd	ra,72(sp)
    16ac:	e0a2                	sd	s0,64(sp)
    16ae:	fc26                	sd	s1,56(sp)
    16b0:	f84a                	sd	s2,48(sp)
    16b2:	0880                	addi	s0,sp,80
    16b4:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    16b6:	00005797          	auipc	a5,0x5
    16ba:	bb278793          	addi	a5,a5,-1102 # 6268 <malloc+0x492>
    16be:	fcf43023          	sd	a5,-64(s0)
    16c2:	00005797          	auipc	a5,0x5
    16c6:	48678793          	addi	a5,a5,1158 # 6b48 <malloc+0xd72>
    16ca:	fcf43423          	sd	a5,-56(s0)
    16ce:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    16d2:	00005517          	auipc	a0,0x5
    16d6:	47e50513          	addi	a0,a0,1150 # 6b50 <malloc+0xd7a>
    16da:	00004097          	auipc	ra,0x4
    16de:	2fe080e7          	jalr	766(ra) # 59d8 <unlink>
  pid = fork();
    16e2:	00004097          	auipc	ra,0x4
    16e6:	29e080e7          	jalr	670(ra) # 5980 <fork>
  if(pid < 0) {
    16ea:	04054663          	bltz	a0,1736 <exectest+0x8e>
    16ee:	84aa                	mv	s1,a0
  if(pid == 0) {
    16f0:	e959                	bnez	a0,1786 <exectest+0xde>
    close(1);
    16f2:	4505                	li	a0,1
    16f4:	00004097          	auipc	ra,0x4
    16f8:	2bc080e7          	jalr	700(ra) # 59b0 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    16fc:	20100593          	li	a1,513
    1700:	00005517          	auipc	a0,0x5
    1704:	45050513          	addi	a0,a0,1104 # 6b50 <malloc+0xd7a>
    1708:	00004097          	auipc	ra,0x4
    170c:	2c0080e7          	jalr	704(ra) # 59c8 <open>
    if(fd < 0) {
    1710:	04054163          	bltz	a0,1752 <exectest+0xaa>
    if(fd != 1) {
    1714:	4785                	li	a5,1
    1716:	04f50c63          	beq	a0,a5,176e <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    171a:	85ca                	mv	a1,s2
    171c:	00005517          	auipc	a0,0x5
    1720:	45450513          	addi	a0,a0,1108 # 6b70 <malloc+0xd9a>
    1724:	00004097          	auipc	ra,0x4
    1728:	5f4080e7          	jalr	1524(ra) # 5d18 <printf>
      exit(1);
    172c:	4505                	li	a0,1
    172e:	00004097          	auipc	ra,0x4
    1732:	25a080e7          	jalr	602(ra) # 5988 <exit>
     printf("%s: fork failed\n", s);
    1736:	85ca                	mv	a1,s2
    1738:	00005517          	auipc	a0,0x5
    173c:	38850513          	addi	a0,a0,904 # 6ac0 <malloc+0xcea>
    1740:	00004097          	auipc	ra,0x4
    1744:	5d8080e7          	jalr	1496(ra) # 5d18 <printf>
     exit(1);
    1748:	4505                	li	a0,1
    174a:	00004097          	auipc	ra,0x4
    174e:	23e080e7          	jalr	574(ra) # 5988 <exit>
      printf("%s: create failed\n", s);
    1752:	85ca                	mv	a1,s2
    1754:	00005517          	auipc	a0,0x5
    1758:	40450513          	addi	a0,a0,1028 # 6b58 <malloc+0xd82>
    175c:	00004097          	auipc	ra,0x4
    1760:	5bc080e7          	jalr	1468(ra) # 5d18 <printf>
      exit(1);
    1764:	4505                	li	a0,1
    1766:	00004097          	auipc	ra,0x4
    176a:	222080e7          	jalr	546(ra) # 5988 <exit>
    if(exec("echo", echoargv) < 0){
    176e:	fc040593          	addi	a1,s0,-64
    1772:	00005517          	auipc	a0,0x5
    1776:	af650513          	addi	a0,a0,-1290 # 6268 <malloc+0x492>
    177a:	00004097          	auipc	ra,0x4
    177e:	246080e7          	jalr	582(ra) # 59c0 <exec>
    1782:	02054163          	bltz	a0,17a4 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1786:	fdc40513          	addi	a0,s0,-36
    178a:	00004097          	auipc	ra,0x4
    178e:	206080e7          	jalr	518(ra) # 5990 <wait>
    1792:	02951763          	bne	a0,s1,17c0 <exectest+0x118>
  if(xstatus != 0)
    1796:	fdc42503          	lw	a0,-36(s0)
    179a:	cd0d                	beqz	a0,17d4 <exectest+0x12c>
    exit(xstatus);
    179c:	00004097          	auipc	ra,0x4
    17a0:	1ec080e7          	jalr	492(ra) # 5988 <exit>
      printf("%s: exec echo failed\n", s);
    17a4:	85ca                	mv	a1,s2
    17a6:	00005517          	auipc	a0,0x5
    17aa:	3da50513          	addi	a0,a0,986 # 6b80 <malloc+0xdaa>
    17ae:	00004097          	auipc	ra,0x4
    17b2:	56a080e7          	jalr	1386(ra) # 5d18 <printf>
      exit(1);
    17b6:	4505                	li	a0,1
    17b8:	00004097          	auipc	ra,0x4
    17bc:	1d0080e7          	jalr	464(ra) # 5988 <exit>
    printf("%s: wait failed!\n", s);
    17c0:	85ca                	mv	a1,s2
    17c2:	00005517          	auipc	a0,0x5
    17c6:	3d650513          	addi	a0,a0,982 # 6b98 <malloc+0xdc2>
    17ca:	00004097          	auipc	ra,0x4
    17ce:	54e080e7          	jalr	1358(ra) # 5d18 <printf>
    17d2:	b7d1                	j	1796 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    17d4:	4581                	li	a1,0
    17d6:	00005517          	auipc	a0,0x5
    17da:	37a50513          	addi	a0,a0,890 # 6b50 <malloc+0xd7a>
    17de:	00004097          	auipc	ra,0x4
    17e2:	1ea080e7          	jalr	490(ra) # 59c8 <open>
  if(fd < 0) {
    17e6:	02054a63          	bltz	a0,181a <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    17ea:	4609                	li	a2,2
    17ec:	fb840593          	addi	a1,s0,-72
    17f0:	00004097          	auipc	ra,0x4
    17f4:	1b0080e7          	jalr	432(ra) # 59a0 <read>
    17f8:	4789                	li	a5,2
    17fa:	02f50e63          	beq	a0,a5,1836 <exectest+0x18e>
    printf("%s: read failed\n", s);
    17fe:	85ca                	mv	a1,s2
    1800:	00005517          	auipc	a0,0x5
    1804:	e1850513          	addi	a0,a0,-488 # 6618 <malloc+0x842>
    1808:	00004097          	auipc	ra,0x4
    180c:	510080e7          	jalr	1296(ra) # 5d18 <printf>
    exit(1);
    1810:	4505                	li	a0,1
    1812:	00004097          	auipc	ra,0x4
    1816:	176080e7          	jalr	374(ra) # 5988 <exit>
    printf("%s: open failed\n", s);
    181a:	85ca                	mv	a1,s2
    181c:	00005517          	auipc	a0,0x5
    1820:	2bc50513          	addi	a0,a0,700 # 6ad8 <malloc+0xd02>
    1824:	00004097          	auipc	ra,0x4
    1828:	4f4080e7          	jalr	1268(ra) # 5d18 <printf>
    exit(1);
    182c:	4505                	li	a0,1
    182e:	00004097          	auipc	ra,0x4
    1832:	15a080e7          	jalr	346(ra) # 5988 <exit>
  unlink("echo-ok");
    1836:	00005517          	auipc	a0,0x5
    183a:	31a50513          	addi	a0,a0,794 # 6b50 <malloc+0xd7a>
    183e:	00004097          	auipc	ra,0x4
    1842:	19a080e7          	jalr	410(ra) # 59d8 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1846:	fb844703          	lbu	a4,-72(s0)
    184a:	04f00793          	li	a5,79
    184e:	00f71863          	bne	a4,a5,185e <exectest+0x1b6>
    1852:	fb944703          	lbu	a4,-71(s0)
    1856:	04b00793          	li	a5,75
    185a:	02f70063          	beq	a4,a5,187a <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    185e:	85ca                	mv	a1,s2
    1860:	00005517          	auipc	a0,0x5
    1864:	35050513          	addi	a0,a0,848 # 6bb0 <malloc+0xdda>
    1868:	00004097          	auipc	ra,0x4
    186c:	4b0080e7          	jalr	1200(ra) # 5d18 <printf>
    exit(1);
    1870:	4505                	li	a0,1
    1872:	00004097          	auipc	ra,0x4
    1876:	116080e7          	jalr	278(ra) # 5988 <exit>
    exit(0);
    187a:	4501                	li	a0,0
    187c:	00004097          	auipc	ra,0x4
    1880:	10c080e7          	jalr	268(ra) # 5988 <exit>

0000000000001884 <pipe1>:
{
    1884:	711d                	addi	sp,sp,-96
    1886:	ec86                	sd	ra,88(sp)
    1888:	e8a2                	sd	s0,80(sp)
    188a:	e4a6                	sd	s1,72(sp)
    188c:	e0ca                	sd	s2,64(sp)
    188e:	fc4e                	sd	s3,56(sp)
    1890:	f852                	sd	s4,48(sp)
    1892:	f456                	sd	s5,40(sp)
    1894:	f05a                	sd	s6,32(sp)
    1896:	ec5e                	sd	s7,24(sp)
    1898:	1080                	addi	s0,sp,96
    189a:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    189c:	fa840513          	addi	a0,s0,-88
    18a0:	00004097          	auipc	ra,0x4
    18a4:	0f8080e7          	jalr	248(ra) # 5998 <pipe>
    18a8:	ed25                	bnez	a0,1920 <pipe1+0x9c>
    18aa:	84aa                	mv	s1,a0
  pid = fork();
    18ac:	00004097          	auipc	ra,0x4
    18b0:	0d4080e7          	jalr	212(ra) # 5980 <fork>
    18b4:	8a2a                	mv	s4,a0
  if(pid == 0){
    18b6:	c159                	beqz	a0,193c <pipe1+0xb8>
  } else if(pid > 0){
    18b8:	16a05e63          	blez	a0,1a34 <pipe1+0x1b0>
    close(fds[1]);
    18bc:	fac42503          	lw	a0,-84(s0)
    18c0:	00004097          	auipc	ra,0x4
    18c4:	0f0080e7          	jalr	240(ra) # 59b0 <close>
    total = 0;
    18c8:	8a26                	mv	s4,s1
    cc = 1;
    18ca:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    18cc:	0000aa97          	auipc	s5,0xa
    18d0:	654a8a93          	addi	s5,s5,1620 # bf20 <buf>
      if(cc > sizeof(buf))
    18d4:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    18d6:	864e                	mv	a2,s3
    18d8:	85d6                	mv	a1,s5
    18da:	fa842503          	lw	a0,-88(s0)
    18de:	00004097          	auipc	ra,0x4
    18e2:	0c2080e7          	jalr	194(ra) # 59a0 <read>
    18e6:	10a05263          	blez	a0,19ea <pipe1+0x166>
      for(i = 0; i < n; i++){
    18ea:	0000a717          	auipc	a4,0xa
    18ee:	63670713          	addi	a4,a4,1590 # bf20 <buf>
    18f2:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    18f6:	00074683          	lbu	a3,0(a4)
    18fa:	0ff4f793          	andi	a5,s1,255
    18fe:	2485                	addiw	s1,s1,1
    1900:	0cf69163          	bne	a3,a5,19c2 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    1904:	0705                	addi	a4,a4,1
    1906:	fec498e3          	bne	s1,a2,18f6 <pipe1+0x72>
      total += n;
    190a:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    190e:	0019979b          	slliw	a5,s3,0x1
    1912:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    1916:	013b7363          	bgeu	s6,s3,191c <pipe1+0x98>
        cc = sizeof(buf);
    191a:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    191c:	84b2                	mv	s1,a2
    191e:	bf65                	j	18d6 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    1920:	85ca                	mv	a1,s2
    1922:	00005517          	auipc	a0,0x5
    1926:	2a650513          	addi	a0,a0,678 # 6bc8 <malloc+0xdf2>
    192a:	00004097          	auipc	ra,0x4
    192e:	3ee080e7          	jalr	1006(ra) # 5d18 <printf>
    exit(1);
    1932:	4505                	li	a0,1
    1934:	00004097          	auipc	ra,0x4
    1938:	054080e7          	jalr	84(ra) # 5988 <exit>
    close(fds[0]);
    193c:	fa842503          	lw	a0,-88(s0)
    1940:	00004097          	auipc	ra,0x4
    1944:	070080e7          	jalr	112(ra) # 59b0 <close>
    for(n = 0; n < N; n++){
    1948:	0000ab17          	auipc	s6,0xa
    194c:	5d8b0b13          	addi	s6,s6,1496 # bf20 <buf>
    1950:	416004bb          	negw	s1,s6
    1954:	0ff4f493          	andi	s1,s1,255
    1958:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    195c:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    195e:	6a85                	lui	s5,0x1
    1960:	42da8a93          	addi	s5,s5,1069 # 142d <copyinstr2+0x135>
{
    1964:	87da                	mv	a5,s6
        buf[i] = seq++;
    1966:	0097873b          	addw	a4,a5,s1
    196a:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    196e:	0785                	addi	a5,a5,1
    1970:	fef99be3          	bne	s3,a5,1966 <pipe1+0xe2>
        buf[i] = seq++;
    1974:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1978:	40900613          	li	a2,1033
    197c:	85de                	mv	a1,s7
    197e:	fac42503          	lw	a0,-84(s0)
    1982:	00004097          	auipc	ra,0x4
    1986:	026080e7          	jalr	38(ra) # 59a8 <write>
    198a:	40900793          	li	a5,1033
    198e:	00f51c63          	bne	a0,a5,19a6 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1992:	24a5                	addiw	s1,s1,9
    1994:	0ff4f493          	andi	s1,s1,255
    1998:	fd5a16e3          	bne	s4,s5,1964 <pipe1+0xe0>
    exit(0);
    199c:	4501                	li	a0,0
    199e:	00004097          	auipc	ra,0x4
    19a2:	fea080e7          	jalr	-22(ra) # 5988 <exit>
        printf("%s: pipe1 oops 1\n", s);
    19a6:	85ca                	mv	a1,s2
    19a8:	00005517          	auipc	a0,0x5
    19ac:	23850513          	addi	a0,a0,568 # 6be0 <malloc+0xe0a>
    19b0:	00004097          	auipc	ra,0x4
    19b4:	368080e7          	jalr	872(ra) # 5d18 <printf>
        exit(1);
    19b8:	4505                	li	a0,1
    19ba:	00004097          	auipc	ra,0x4
    19be:	fce080e7          	jalr	-50(ra) # 5988 <exit>
          printf("%s: pipe1 oops 2\n", s);
    19c2:	85ca                	mv	a1,s2
    19c4:	00005517          	auipc	a0,0x5
    19c8:	23450513          	addi	a0,a0,564 # 6bf8 <malloc+0xe22>
    19cc:	00004097          	auipc	ra,0x4
    19d0:	34c080e7          	jalr	844(ra) # 5d18 <printf>
}
    19d4:	60e6                	ld	ra,88(sp)
    19d6:	6446                	ld	s0,80(sp)
    19d8:	64a6                	ld	s1,72(sp)
    19da:	6906                	ld	s2,64(sp)
    19dc:	79e2                	ld	s3,56(sp)
    19de:	7a42                	ld	s4,48(sp)
    19e0:	7aa2                	ld	s5,40(sp)
    19e2:	7b02                	ld	s6,32(sp)
    19e4:	6be2                	ld	s7,24(sp)
    19e6:	6125                	addi	sp,sp,96
    19e8:	8082                	ret
    if(total != N * SZ){
    19ea:	6785                	lui	a5,0x1
    19ec:	42d78793          	addi	a5,a5,1069 # 142d <copyinstr2+0x135>
    19f0:	02fa0063          	beq	s4,a5,1a10 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    19f4:	85d2                	mv	a1,s4
    19f6:	00005517          	auipc	a0,0x5
    19fa:	21a50513          	addi	a0,a0,538 # 6c10 <malloc+0xe3a>
    19fe:	00004097          	auipc	ra,0x4
    1a02:	31a080e7          	jalr	794(ra) # 5d18 <printf>
      exit(1);
    1a06:	4505                	li	a0,1
    1a08:	00004097          	auipc	ra,0x4
    1a0c:	f80080e7          	jalr	-128(ra) # 5988 <exit>
    close(fds[0]);
    1a10:	fa842503          	lw	a0,-88(s0)
    1a14:	00004097          	auipc	ra,0x4
    1a18:	f9c080e7          	jalr	-100(ra) # 59b0 <close>
    wait(&xstatus);
    1a1c:	fa440513          	addi	a0,s0,-92
    1a20:	00004097          	auipc	ra,0x4
    1a24:	f70080e7          	jalr	-144(ra) # 5990 <wait>
    exit(xstatus);
    1a28:	fa442503          	lw	a0,-92(s0)
    1a2c:	00004097          	auipc	ra,0x4
    1a30:	f5c080e7          	jalr	-164(ra) # 5988 <exit>
    printf("%s: fork() failed\n", s);
    1a34:	85ca                	mv	a1,s2
    1a36:	00005517          	auipc	a0,0x5
    1a3a:	1fa50513          	addi	a0,a0,506 # 6c30 <malloc+0xe5a>
    1a3e:	00004097          	auipc	ra,0x4
    1a42:	2da080e7          	jalr	730(ra) # 5d18 <printf>
    exit(1);
    1a46:	4505                	li	a0,1
    1a48:	00004097          	auipc	ra,0x4
    1a4c:	f40080e7          	jalr	-192(ra) # 5988 <exit>

0000000000001a50 <exitwait>:
{
    1a50:	7139                	addi	sp,sp,-64
    1a52:	fc06                	sd	ra,56(sp)
    1a54:	f822                	sd	s0,48(sp)
    1a56:	f426                	sd	s1,40(sp)
    1a58:	f04a                	sd	s2,32(sp)
    1a5a:	ec4e                	sd	s3,24(sp)
    1a5c:	e852                	sd	s4,16(sp)
    1a5e:	0080                	addi	s0,sp,64
    1a60:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1a62:	4901                	li	s2,0
    1a64:	06400993          	li	s3,100
    pid = fork();
    1a68:	00004097          	auipc	ra,0x4
    1a6c:	f18080e7          	jalr	-232(ra) # 5980 <fork>
    1a70:	84aa                	mv	s1,a0
    if(pid < 0){
    1a72:	02054a63          	bltz	a0,1aa6 <exitwait+0x56>
    if(pid){
    1a76:	c151                	beqz	a0,1afa <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1a78:	fcc40513          	addi	a0,s0,-52
    1a7c:	00004097          	auipc	ra,0x4
    1a80:	f14080e7          	jalr	-236(ra) # 5990 <wait>
    1a84:	02951f63          	bne	a0,s1,1ac2 <exitwait+0x72>
      if(i != xstate) {
    1a88:	fcc42783          	lw	a5,-52(s0)
    1a8c:	05279963          	bne	a5,s2,1ade <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1a90:	2905                	addiw	s2,s2,1
    1a92:	fd391be3          	bne	s2,s3,1a68 <exitwait+0x18>
}
    1a96:	70e2                	ld	ra,56(sp)
    1a98:	7442                	ld	s0,48(sp)
    1a9a:	74a2                	ld	s1,40(sp)
    1a9c:	7902                	ld	s2,32(sp)
    1a9e:	69e2                	ld	s3,24(sp)
    1aa0:	6a42                	ld	s4,16(sp)
    1aa2:	6121                	addi	sp,sp,64
    1aa4:	8082                	ret
      printf("%s: fork failed\n", s);
    1aa6:	85d2                	mv	a1,s4
    1aa8:	00005517          	auipc	a0,0x5
    1aac:	01850513          	addi	a0,a0,24 # 6ac0 <malloc+0xcea>
    1ab0:	00004097          	auipc	ra,0x4
    1ab4:	268080e7          	jalr	616(ra) # 5d18 <printf>
      exit(1);
    1ab8:	4505                	li	a0,1
    1aba:	00004097          	auipc	ra,0x4
    1abe:	ece080e7          	jalr	-306(ra) # 5988 <exit>
        printf("%s: wait wrong pid\n", s);
    1ac2:	85d2                	mv	a1,s4
    1ac4:	00005517          	auipc	a0,0x5
    1ac8:	18450513          	addi	a0,a0,388 # 6c48 <malloc+0xe72>
    1acc:	00004097          	auipc	ra,0x4
    1ad0:	24c080e7          	jalr	588(ra) # 5d18 <printf>
        exit(1);
    1ad4:	4505                	li	a0,1
    1ad6:	00004097          	auipc	ra,0x4
    1ada:	eb2080e7          	jalr	-334(ra) # 5988 <exit>
        printf("%s: wait wrong exit status\n", s);
    1ade:	85d2                	mv	a1,s4
    1ae0:	00005517          	auipc	a0,0x5
    1ae4:	18050513          	addi	a0,a0,384 # 6c60 <malloc+0xe8a>
    1ae8:	00004097          	auipc	ra,0x4
    1aec:	230080e7          	jalr	560(ra) # 5d18 <printf>
        exit(1);
    1af0:	4505                	li	a0,1
    1af2:	00004097          	auipc	ra,0x4
    1af6:	e96080e7          	jalr	-362(ra) # 5988 <exit>
      exit(i);
    1afa:	854a                	mv	a0,s2
    1afc:	00004097          	auipc	ra,0x4
    1b00:	e8c080e7          	jalr	-372(ra) # 5988 <exit>

0000000000001b04 <twochildren>:
{
    1b04:	1101                	addi	sp,sp,-32
    1b06:	ec06                	sd	ra,24(sp)
    1b08:	e822                	sd	s0,16(sp)
    1b0a:	e426                	sd	s1,8(sp)
    1b0c:	e04a                	sd	s2,0(sp)
    1b0e:	1000                	addi	s0,sp,32
    1b10:	892a                	mv	s2,a0
    1b12:	3e800493          	li	s1,1000
    int pid1 = fork();
    1b16:	00004097          	auipc	ra,0x4
    1b1a:	e6a080e7          	jalr	-406(ra) # 5980 <fork>
    if(pid1 < 0){
    1b1e:	02054c63          	bltz	a0,1b56 <twochildren+0x52>
    if(pid1 == 0){
    1b22:	c921                	beqz	a0,1b72 <twochildren+0x6e>
      int pid2 = fork();
    1b24:	00004097          	auipc	ra,0x4
    1b28:	e5c080e7          	jalr	-420(ra) # 5980 <fork>
      if(pid2 < 0){
    1b2c:	04054763          	bltz	a0,1b7a <twochildren+0x76>
      if(pid2 == 0){
    1b30:	c13d                	beqz	a0,1b96 <twochildren+0x92>
        wait(0);
    1b32:	4501                	li	a0,0
    1b34:	00004097          	auipc	ra,0x4
    1b38:	e5c080e7          	jalr	-420(ra) # 5990 <wait>
        wait(0);
    1b3c:	4501                	li	a0,0
    1b3e:	00004097          	auipc	ra,0x4
    1b42:	e52080e7          	jalr	-430(ra) # 5990 <wait>
  for(int i = 0; i < 1000; i++){
    1b46:	34fd                	addiw	s1,s1,-1
    1b48:	f4f9                	bnez	s1,1b16 <twochildren+0x12>
}
    1b4a:	60e2                	ld	ra,24(sp)
    1b4c:	6442                	ld	s0,16(sp)
    1b4e:	64a2                	ld	s1,8(sp)
    1b50:	6902                	ld	s2,0(sp)
    1b52:	6105                	addi	sp,sp,32
    1b54:	8082                	ret
      printf("%s: fork failed\n", s);
    1b56:	85ca                	mv	a1,s2
    1b58:	00005517          	auipc	a0,0x5
    1b5c:	f6850513          	addi	a0,a0,-152 # 6ac0 <malloc+0xcea>
    1b60:	00004097          	auipc	ra,0x4
    1b64:	1b8080e7          	jalr	440(ra) # 5d18 <printf>
      exit(1);
    1b68:	4505                	li	a0,1
    1b6a:	00004097          	auipc	ra,0x4
    1b6e:	e1e080e7          	jalr	-482(ra) # 5988 <exit>
      exit(0);
    1b72:	00004097          	auipc	ra,0x4
    1b76:	e16080e7          	jalr	-490(ra) # 5988 <exit>
        printf("%s: fork failed\n", s);
    1b7a:	85ca                	mv	a1,s2
    1b7c:	00005517          	auipc	a0,0x5
    1b80:	f4450513          	addi	a0,a0,-188 # 6ac0 <malloc+0xcea>
    1b84:	00004097          	auipc	ra,0x4
    1b88:	194080e7          	jalr	404(ra) # 5d18 <printf>
        exit(1);
    1b8c:	4505                	li	a0,1
    1b8e:	00004097          	auipc	ra,0x4
    1b92:	dfa080e7          	jalr	-518(ra) # 5988 <exit>
        exit(0);
    1b96:	00004097          	auipc	ra,0x4
    1b9a:	df2080e7          	jalr	-526(ra) # 5988 <exit>

0000000000001b9e <forkfork>:
{
    1b9e:	7179                	addi	sp,sp,-48
    1ba0:	f406                	sd	ra,40(sp)
    1ba2:	f022                	sd	s0,32(sp)
    1ba4:	ec26                	sd	s1,24(sp)
    1ba6:	1800                	addi	s0,sp,48
    1ba8:	84aa                	mv	s1,a0
    int pid = fork();
    1baa:	00004097          	auipc	ra,0x4
    1bae:	dd6080e7          	jalr	-554(ra) # 5980 <fork>
    if(pid < 0){
    1bb2:	04054163          	bltz	a0,1bf4 <forkfork+0x56>
    if(pid == 0){
    1bb6:	cd29                	beqz	a0,1c10 <forkfork+0x72>
    int pid = fork();
    1bb8:	00004097          	auipc	ra,0x4
    1bbc:	dc8080e7          	jalr	-568(ra) # 5980 <fork>
    if(pid < 0){
    1bc0:	02054a63          	bltz	a0,1bf4 <forkfork+0x56>
    if(pid == 0){
    1bc4:	c531                	beqz	a0,1c10 <forkfork+0x72>
    wait(&xstatus);
    1bc6:	fdc40513          	addi	a0,s0,-36
    1bca:	00004097          	auipc	ra,0x4
    1bce:	dc6080e7          	jalr	-570(ra) # 5990 <wait>
    if(xstatus != 0) {
    1bd2:	fdc42783          	lw	a5,-36(s0)
    1bd6:	ebbd                	bnez	a5,1c4c <forkfork+0xae>
    wait(&xstatus);
    1bd8:	fdc40513          	addi	a0,s0,-36
    1bdc:	00004097          	auipc	ra,0x4
    1be0:	db4080e7          	jalr	-588(ra) # 5990 <wait>
    if(xstatus != 0) {
    1be4:	fdc42783          	lw	a5,-36(s0)
    1be8:	e3b5                	bnez	a5,1c4c <forkfork+0xae>
}
    1bea:	70a2                	ld	ra,40(sp)
    1bec:	7402                	ld	s0,32(sp)
    1bee:	64e2                	ld	s1,24(sp)
    1bf0:	6145                	addi	sp,sp,48
    1bf2:	8082                	ret
      printf("%s: fork failed", s);
    1bf4:	85a6                	mv	a1,s1
    1bf6:	00005517          	auipc	a0,0x5
    1bfa:	08a50513          	addi	a0,a0,138 # 6c80 <malloc+0xeaa>
    1bfe:	00004097          	auipc	ra,0x4
    1c02:	11a080e7          	jalr	282(ra) # 5d18 <printf>
      exit(1);
    1c06:	4505                	li	a0,1
    1c08:	00004097          	auipc	ra,0x4
    1c0c:	d80080e7          	jalr	-640(ra) # 5988 <exit>
{
    1c10:	0c800493          	li	s1,200
        int pid1 = fork();
    1c14:	00004097          	auipc	ra,0x4
    1c18:	d6c080e7          	jalr	-660(ra) # 5980 <fork>
        if(pid1 < 0){
    1c1c:	00054f63          	bltz	a0,1c3a <forkfork+0x9c>
        if(pid1 == 0){
    1c20:	c115                	beqz	a0,1c44 <forkfork+0xa6>
        wait(0);
    1c22:	4501                	li	a0,0
    1c24:	00004097          	auipc	ra,0x4
    1c28:	d6c080e7          	jalr	-660(ra) # 5990 <wait>
      for(int j = 0; j < 200; j++){
    1c2c:	34fd                	addiw	s1,s1,-1
    1c2e:	f0fd                	bnez	s1,1c14 <forkfork+0x76>
      exit(0);
    1c30:	4501                	li	a0,0
    1c32:	00004097          	auipc	ra,0x4
    1c36:	d56080e7          	jalr	-682(ra) # 5988 <exit>
          exit(1);
    1c3a:	4505                	li	a0,1
    1c3c:	00004097          	auipc	ra,0x4
    1c40:	d4c080e7          	jalr	-692(ra) # 5988 <exit>
          exit(0);
    1c44:	00004097          	auipc	ra,0x4
    1c48:	d44080e7          	jalr	-700(ra) # 5988 <exit>
      printf("%s: fork in child failed", s);
    1c4c:	85a6                	mv	a1,s1
    1c4e:	00005517          	auipc	a0,0x5
    1c52:	04250513          	addi	a0,a0,66 # 6c90 <malloc+0xeba>
    1c56:	00004097          	auipc	ra,0x4
    1c5a:	0c2080e7          	jalr	194(ra) # 5d18 <printf>
      exit(1);
    1c5e:	4505                	li	a0,1
    1c60:	00004097          	auipc	ra,0x4
    1c64:	d28080e7          	jalr	-728(ra) # 5988 <exit>

0000000000001c68 <reparent2>:
{
    1c68:	1101                	addi	sp,sp,-32
    1c6a:	ec06                	sd	ra,24(sp)
    1c6c:	e822                	sd	s0,16(sp)
    1c6e:	e426                	sd	s1,8(sp)
    1c70:	1000                	addi	s0,sp,32
    1c72:	32000493          	li	s1,800
    int pid1 = fork();
    1c76:	00004097          	auipc	ra,0x4
    1c7a:	d0a080e7          	jalr	-758(ra) # 5980 <fork>
    if(pid1 < 0){
    1c7e:	00054f63          	bltz	a0,1c9c <reparent2+0x34>
    if(pid1 == 0){
    1c82:	c915                	beqz	a0,1cb6 <reparent2+0x4e>
    wait(0);
    1c84:	4501                	li	a0,0
    1c86:	00004097          	auipc	ra,0x4
    1c8a:	d0a080e7          	jalr	-758(ra) # 5990 <wait>
  for(int i = 0; i < 800; i++){
    1c8e:	34fd                	addiw	s1,s1,-1
    1c90:	f0fd                	bnez	s1,1c76 <reparent2+0xe>
  exit(0);
    1c92:	4501                	li	a0,0
    1c94:	00004097          	auipc	ra,0x4
    1c98:	cf4080e7          	jalr	-780(ra) # 5988 <exit>
      printf("fork failed\n");
    1c9c:	00005517          	auipc	a0,0x5
    1ca0:	24450513          	addi	a0,a0,580 # 6ee0 <malloc+0x110a>
    1ca4:	00004097          	auipc	ra,0x4
    1ca8:	074080e7          	jalr	116(ra) # 5d18 <printf>
      exit(1);
    1cac:	4505                	li	a0,1
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	cda080e7          	jalr	-806(ra) # 5988 <exit>
      fork();
    1cb6:	00004097          	auipc	ra,0x4
    1cba:	cca080e7          	jalr	-822(ra) # 5980 <fork>
      fork();
    1cbe:	00004097          	auipc	ra,0x4
    1cc2:	cc2080e7          	jalr	-830(ra) # 5980 <fork>
      exit(0);
    1cc6:	4501                	li	a0,0
    1cc8:	00004097          	auipc	ra,0x4
    1ccc:	cc0080e7          	jalr	-832(ra) # 5988 <exit>

0000000000001cd0 <createdelete>:
{
    1cd0:	7175                	addi	sp,sp,-144
    1cd2:	e506                	sd	ra,136(sp)
    1cd4:	e122                	sd	s0,128(sp)
    1cd6:	fca6                	sd	s1,120(sp)
    1cd8:	f8ca                	sd	s2,112(sp)
    1cda:	f4ce                	sd	s3,104(sp)
    1cdc:	f0d2                	sd	s4,96(sp)
    1cde:	ecd6                	sd	s5,88(sp)
    1ce0:	e8da                	sd	s6,80(sp)
    1ce2:	e4de                	sd	s7,72(sp)
    1ce4:	e0e2                	sd	s8,64(sp)
    1ce6:	fc66                	sd	s9,56(sp)
    1ce8:	0900                	addi	s0,sp,144
    1cea:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1cec:	4901                	li	s2,0
    1cee:	4991                	li	s3,4
    pid = fork();
    1cf0:	00004097          	auipc	ra,0x4
    1cf4:	c90080e7          	jalr	-880(ra) # 5980 <fork>
    1cf8:	84aa                	mv	s1,a0
    if(pid < 0){
    1cfa:	02054f63          	bltz	a0,1d38 <createdelete+0x68>
    if(pid == 0){
    1cfe:	c939                	beqz	a0,1d54 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1d00:	2905                	addiw	s2,s2,1
    1d02:	ff3917e3          	bne	s2,s3,1cf0 <createdelete+0x20>
    1d06:	4491                	li	s1,4
    wait(&xstatus);
    1d08:	f7c40513          	addi	a0,s0,-132
    1d0c:	00004097          	auipc	ra,0x4
    1d10:	c84080e7          	jalr	-892(ra) # 5990 <wait>
    if(xstatus != 0)
    1d14:	f7c42903          	lw	s2,-132(s0)
    1d18:	0e091263          	bnez	s2,1dfc <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1d1c:	34fd                	addiw	s1,s1,-1
    1d1e:	f4ed                	bnez	s1,1d08 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1d20:	f8040123          	sb	zero,-126(s0)
    1d24:	03000993          	li	s3,48
    1d28:	5a7d                	li	s4,-1
    1d2a:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d2e:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1d30:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1d32:	07400a93          	li	s5,116
    1d36:	a29d                	j	1e9c <createdelete+0x1cc>
      printf("fork failed\n", s);
    1d38:	85e6                	mv	a1,s9
    1d3a:	00005517          	auipc	a0,0x5
    1d3e:	1a650513          	addi	a0,a0,422 # 6ee0 <malloc+0x110a>
    1d42:	00004097          	auipc	ra,0x4
    1d46:	fd6080e7          	jalr	-42(ra) # 5d18 <printf>
      exit(1);
    1d4a:	4505                	li	a0,1
    1d4c:	00004097          	auipc	ra,0x4
    1d50:	c3c080e7          	jalr	-964(ra) # 5988 <exit>
      name[0] = 'p' + pi;
    1d54:	0709091b          	addiw	s2,s2,112
    1d58:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1d5c:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1d60:	4951                	li	s2,20
    1d62:	a015                	j	1d86 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1d64:	85e6                	mv	a1,s9
    1d66:	00005517          	auipc	a0,0x5
    1d6a:	df250513          	addi	a0,a0,-526 # 6b58 <malloc+0xd82>
    1d6e:	00004097          	auipc	ra,0x4
    1d72:	faa080e7          	jalr	-86(ra) # 5d18 <printf>
          exit(1);
    1d76:	4505                	li	a0,1
    1d78:	00004097          	auipc	ra,0x4
    1d7c:	c10080e7          	jalr	-1008(ra) # 5988 <exit>
      for(i = 0; i < N; i++){
    1d80:	2485                	addiw	s1,s1,1
    1d82:	07248863          	beq	s1,s2,1df2 <createdelete+0x122>
        name[1] = '0' + i;
    1d86:	0304879b          	addiw	a5,s1,48
    1d8a:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1d8e:	20200593          	li	a1,514
    1d92:	f8040513          	addi	a0,s0,-128
    1d96:	00004097          	auipc	ra,0x4
    1d9a:	c32080e7          	jalr	-974(ra) # 59c8 <open>
        if(fd < 0){
    1d9e:	fc0543e3          	bltz	a0,1d64 <createdelete+0x94>
        close(fd);
    1da2:	00004097          	auipc	ra,0x4
    1da6:	c0e080e7          	jalr	-1010(ra) # 59b0 <close>
        if(i > 0 && (i % 2 ) == 0){
    1daa:	fc905be3          	blez	s1,1d80 <createdelete+0xb0>
    1dae:	0014f793          	andi	a5,s1,1
    1db2:	f7f9                	bnez	a5,1d80 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1db4:	01f4d79b          	srliw	a5,s1,0x1f
    1db8:	9fa5                	addw	a5,a5,s1
    1dba:	4017d79b          	sraiw	a5,a5,0x1
    1dbe:	0307879b          	addiw	a5,a5,48
    1dc2:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1dc6:	f8040513          	addi	a0,s0,-128
    1dca:	00004097          	auipc	ra,0x4
    1dce:	c0e080e7          	jalr	-1010(ra) # 59d8 <unlink>
    1dd2:	fa0557e3          	bgez	a0,1d80 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1dd6:	85e6                	mv	a1,s9
    1dd8:	00005517          	auipc	a0,0x5
    1ddc:	ed850513          	addi	a0,a0,-296 # 6cb0 <malloc+0xeda>
    1de0:	00004097          	auipc	ra,0x4
    1de4:	f38080e7          	jalr	-200(ra) # 5d18 <printf>
            exit(1);
    1de8:	4505                	li	a0,1
    1dea:	00004097          	auipc	ra,0x4
    1dee:	b9e080e7          	jalr	-1122(ra) # 5988 <exit>
      exit(0);
    1df2:	4501                	li	a0,0
    1df4:	00004097          	auipc	ra,0x4
    1df8:	b94080e7          	jalr	-1132(ra) # 5988 <exit>
      exit(1);
    1dfc:	4505                	li	a0,1
    1dfe:	00004097          	auipc	ra,0x4
    1e02:	b8a080e7          	jalr	-1142(ra) # 5988 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1e06:	f8040613          	addi	a2,s0,-128
    1e0a:	85e6                	mv	a1,s9
    1e0c:	00005517          	auipc	a0,0x5
    1e10:	ebc50513          	addi	a0,a0,-324 # 6cc8 <malloc+0xef2>
    1e14:	00004097          	auipc	ra,0x4
    1e18:	f04080e7          	jalr	-252(ra) # 5d18 <printf>
        exit(1);
    1e1c:	4505                	li	a0,1
    1e1e:	00004097          	auipc	ra,0x4
    1e22:	b6a080e7          	jalr	-1174(ra) # 5988 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1e26:	054b7163          	bgeu	s6,s4,1e68 <createdelete+0x198>
      if(fd >= 0)
    1e2a:	02055a63          	bgez	a0,1e5e <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1e2e:	2485                	addiw	s1,s1,1
    1e30:	0ff4f493          	andi	s1,s1,255
    1e34:	05548c63          	beq	s1,s5,1e8c <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1e38:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1e3c:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1e40:	4581                	li	a1,0
    1e42:	f8040513          	addi	a0,s0,-128
    1e46:	00004097          	auipc	ra,0x4
    1e4a:	b82080e7          	jalr	-1150(ra) # 59c8 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1e4e:	00090463          	beqz	s2,1e56 <createdelete+0x186>
    1e52:	fd2bdae3          	bge	s7,s2,1e26 <createdelete+0x156>
    1e56:	fa0548e3          	bltz	a0,1e06 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1e5a:	014b7963          	bgeu	s6,s4,1e6c <createdelete+0x19c>
        close(fd);
    1e5e:	00004097          	auipc	ra,0x4
    1e62:	b52080e7          	jalr	-1198(ra) # 59b0 <close>
    1e66:	b7e1                	j	1e2e <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1e68:	fc0543e3          	bltz	a0,1e2e <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1e6c:	f8040613          	addi	a2,s0,-128
    1e70:	85e6                	mv	a1,s9
    1e72:	00005517          	auipc	a0,0x5
    1e76:	e7e50513          	addi	a0,a0,-386 # 6cf0 <malloc+0xf1a>
    1e7a:	00004097          	auipc	ra,0x4
    1e7e:	e9e080e7          	jalr	-354(ra) # 5d18 <printf>
        exit(1);
    1e82:	4505                	li	a0,1
    1e84:	00004097          	auipc	ra,0x4
    1e88:	b04080e7          	jalr	-1276(ra) # 5988 <exit>
  for(i = 0; i < N; i++){
    1e8c:	2905                	addiw	s2,s2,1
    1e8e:	2a05                	addiw	s4,s4,1
    1e90:	2985                	addiw	s3,s3,1
    1e92:	0ff9f993          	andi	s3,s3,255
    1e96:	47d1                	li	a5,20
    1e98:	02f90a63          	beq	s2,a5,1ecc <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1e9c:	84e2                	mv	s1,s8
    1e9e:	bf69                	j	1e38 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1ea0:	2905                	addiw	s2,s2,1
    1ea2:	0ff97913          	andi	s2,s2,255
    1ea6:	2985                	addiw	s3,s3,1
    1ea8:	0ff9f993          	andi	s3,s3,255
    1eac:	03490863          	beq	s2,s4,1edc <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1eb0:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1eb2:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1eb6:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1eba:	f8040513          	addi	a0,s0,-128
    1ebe:	00004097          	auipc	ra,0x4
    1ec2:	b1a080e7          	jalr	-1254(ra) # 59d8 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1ec6:	34fd                	addiw	s1,s1,-1
    1ec8:	f4ed                	bnez	s1,1eb2 <createdelete+0x1e2>
    1eca:	bfd9                	j	1ea0 <createdelete+0x1d0>
    1ecc:	03000993          	li	s3,48
    1ed0:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1ed4:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1ed6:	08400a13          	li	s4,132
    1eda:	bfd9                	j	1eb0 <createdelete+0x1e0>
}
    1edc:	60aa                	ld	ra,136(sp)
    1ede:	640a                	ld	s0,128(sp)
    1ee0:	74e6                	ld	s1,120(sp)
    1ee2:	7946                	ld	s2,112(sp)
    1ee4:	79a6                	ld	s3,104(sp)
    1ee6:	7a06                	ld	s4,96(sp)
    1ee8:	6ae6                	ld	s5,88(sp)
    1eea:	6b46                	ld	s6,80(sp)
    1eec:	6ba6                	ld	s7,72(sp)
    1eee:	6c06                	ld	s8,64(sp)
    1ef0:	7ce2                	ld	s9,56(sp)
    1ef2:	6149                	addi	sp,sp,144
    1ef4:	8082                	ret

0000000000001ef6 <linkunlink>:
{
    1ef6:	711d                	addi	sp,sp,-96
    1ef8:	ec86                	sd	ra,88(sp)
    1efa:	e8a2                	sd	s0,80(sp)
    1efc:	e4a6                	sd	s1,72(sp)
    1efe:	e0ca                	sd	s2,64(sp)
    1f00:	fc4e                	sd	s3,56(sp)
    1f02:	f852                	sd	s4,48(sp)
    1f04:	f456                	sd	s5,40(sp)
    1f06:	f05a                	sd	s6,32(sp)
    1f08:	ec5e                	sd	s7,24(sp)
    1f0a:	e862                	sd	s8,16(sp)
    1f0c:	e466                	sd	s9,8(sp)
    1f0e:	1080                	addi	s0,sp,96
    1f10:	84aa                	mv	s1,a0
  unlink("x");
    1f12:	00004517          	auipc	a0,0x4
    1f16:	3c650513          	addi	a0,a0,966 # 62d8 <malloc+0x502>
    1f1a:	00004097          	auipc	ra,0x4
    1f1e:	abe080e7          	jalr	-1346(ra) # 59d8 <unlink>
  pid = fork();
    1f22:	00004097          	auipc	ra,0x4
    1f26:	a5e080e7          	jalr	-1442(ra) # 5980 <fork>
  if(pid < 0){
    1f2a:	02054b63          	bltz	a0,1f60 <linkunlink+0x6a>
    1f2e:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1f30:	4c85                	li	s9,1
    1f32:	e119                	bnez	a0,1f38 <linkunlink+0x42>
    1f34:	06100c93          	li	s9,97
    1f38:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1f3c:	41c659b7          	lui	s3,0x41c65
    1f40:	e6d9899b          	addiw	s3,s3,-403
    1f44:	690d                	lui	s2,0x3
    1f46:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1f4a:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1f4c:	4b05                	li	s6,1
      unlink("x");
    1f4e:	00004a97          	auipc	s5,0x4
    1f52:	38aa8a93          	addi	s5,s5,906 # 62d8 <malloc+0x502>
      link("cat", "x");
    1f56:	00005b97          	auipc	s7,0x5
    1f5a:	dc2b8b93          	addi	s7,s7,-574 # 6d18 <malloc+0xf42>
    1f5e:	a825                	j	1f96 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1f60:	85a6                	mv	a1,s1
    1f62:	00005517          	auipc	a0,0x5
    1f66:	b5e50513          	addi	a0,a0,-1186 # 6ac0 <malloc+0xcea>
    1f6a:	00004097          	auipc	ra,0x4
    1f6e:	dae080e7          	jalr	-594(ra) # 5d18 <printf>
    exit(1);
    1f72:	4505                	li	a0,1
    1f74:	00004097          	auipc	ra,0x4
    1f78:	a14080e7          	jalr	-1516(ra) # 5988 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1f7c:	20200593          	li	a1,514
    1f80:	8556                	mv	a0,s5
    1f82:	00004097          	auipc	ra,0x4
    1f86:	a46080e7          	jalr	-1466(ra) # 59c8 <open>
    1f8a:	00004097          	auipc	ra,0x4
    1f8e:	a26080e7          	jalr	-1498(ra) # 59b0 <close>
  for(i = 0; i < 100; i++){
    1f92:	34fd                	addiw	s1,s1,-1
    1f94:	c88d                	beqz	s1,1fc6 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1f96:	033c87bb          	mulw	a5,s9,s3
    1f9a:	012787bb          	addw	a5,a5,s2
    1f9e:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1fa2:	0347f7bb          	remuw	a5,a5,s4
    1fa6:	dbf9                	beqz	a5,1f7c <linkunlink+0x86>
    } else if((x % 3) == 1){
    1fa8:	01678863          	beq	a5,s6,1fb8 <linkunlink+0xc2>
      unlink("x");
    1fac:	8556                	mv	a0,s5
    1fae:	00004097          	auipc	ra,0x4
    1fb2:	a2a080e7          	jalr	-1494(ra) # 59d8 <unlink>
    1fb6:	bff1                	j	1f92 <linkunlink+0x9c>
      link("cat", "x");
    1fb8:	85d6                	mv	a1,s5
    1fba:	855e                	mv	a0,s7
    1fbc:	00004097          	auipc	ra,0x4
    1fc0:	a2c080e7          	jalr	-1492(ra) # 59e8 <link>
    1fc4:	b7f9                	j	1f92 <linkunlink+0x9c>
  if(pid)
    1fc6:	020c0463          	beqz	s8,1fee <linkunlink+0xf8>
    wait(0);
    1fca:	4501                	li	a0,0
    1fcc:	00004097          	auipc	ra,0x4
    1fd0:	9c4080e7          	jalr	-1596(ra) # 5990 <wait>
}
    1fd4:	60e6                	ld	ra,88(sp)
    1fd6:	6446                	ld	s0,80(sp)
    1fd8:	64a6                	ld	s1,72(sp)
    1fda:	6906                	ld	s2,64(sp)
    1fdc:	79e2                	ld	s3,56(sp)
    1fde:	7a42                	ld	s4,48(sp)
    1fe0:	7aa2                	ld	s5,40(sp)
    1fe2:	7b02                	ld	s6,32(sp)
    1fe4:	6be2                	ld	s7,24(sp)
    1fe6:	6c42                	ld	s8,16(sp)
    1fe8:	6ca2                	ld	s9,8(sp)
    1fea:	6125                	addi	sp,sp,96
    1fec:	8082                	ret
    exit(0);
    1fee:	4501                	li	a0,0
    1ff0:	00004097          	auipc	ra,0x4
    1ff4:	998080e7          	jalr	-1640(ra) # 5988 <exit>

0000000000001ff8 <manywrites>:
{
    1ff8:	711d                	addi	sp,sp,-96
    1ffa:	ec86                	sd	ra,88(sp)
    1ffc:	e8a2                	sd	s0,80(sp)
    1ffe:	e4a6                	sd	s1,72(sp)
    2000:	e0ca                	sd	s2,64(sp)
    2002:	fc4e                	sd	s3,56(sp)
    2004:	f852                	sd	s4,48(sp)
    2006:	f456                	sd	s5,40(sp)
    2008:	f05a                	sd	s6,32(sp)
    200a:	ec5e                	sd	s7,24(sp)
    200c:	1080                	addi	s0,sp,96
    200e:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    2010:	4981                	li	s3,0
    2012:	4911                	li	s2,4
    int pid = fork();
    2014:	00004097          	auipc	ra,0x4
    2018:	96c080e7          	jalr	-1684(ra) # 5980 <fork>
    201c:	84aa                	mv	s1,a0
    if(pid < 0){
    201e:	02054963          	bltz	a0,2050 <manywrites+0x58>
    if(pid == 0){
    2022:	c521                	beqz	a0,206a <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    2024:	2985                	addiw	s3,s3,1
    2026:	ff2997e3          	bne	s3,s2,2014 <manywrites+0x1c>
    202a:	4491                	li	s1,4
    int st = 0;
    202c:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    2030:	fa840513          	addi	a0,s0,-88
    2034:	00004097          	auipc	ra,0x4
    2038:	95c080e7          	jalr	-1700(ra) # 5990 <wait>
    if(st != 0)
    203c:	fa842503          	lw	a0,-88(s0)
    2040:	ed6d                	bnez	a0,213a <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    2042:	34fd                	addiw	s1,s1,-1
    2044:	f4e5                	bnez	s1,202c <manywrites+0x34>
  exit(0);
    2046:	4501                	li	a0,0
    2048:	00004097          	auipc	ra,0x4
    204c:	940080e7          	jalr	-1728(ra) # 5988 <exit>
      printf("fork failed\n");
    2050:	00005517          	auipc	a0,0x5
    2054:	e9050513          	addi	a0,a0,-368 # 6ee0 <malloc+0x110a>
    2058:	00004097          	auipc	ra,0x4
    205c:	cc0080e7          	jalr	-832(ra) # 5d18 <printf>
      exit(1);
    2060:	4505                	li	a0,1
    2062:	00004097          	auipc	ra,0x4
    2066:	926080e7          	jalr	-1754(ra) # 5988 <exit>
      name[0] = 'b';
    206a:	06200793          	li	a5,98
    206e:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    2072:	0619879b          	addiw	a5,s3,97
    2076:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    207a:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    207e:	fa840513          	addi	a0,s0,-88
    2082:	00004097          	auipc	ra,0x4
    2086:	956080e7          	jalr	-1706(ra) # 59d8 <unlink>
    208a:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    208c:	0000ab17          	auipc	s6,0xa
    2090:	e94b0b13          	addi	s6,s6,-364 # bf20 <buf>
        for(int i = 0; i < ci+1; i++){
    2094:	8a26                	mv	s4,s1
    2096:	0209ce63          	bltz	s3,20d2 <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    209a:	20200593          	li	a1,514
    209e:	fa840513          	addi	a0,s0,-88
    20a2:	00004097          	auipc	ra,0x4
    20a6:	926080e7          	jalr	-1754(ra) # 59c8 <open>
    20aa:	892a                	mv	s2,a0
          if(fd < 0){
    20ac:	04054763          	bltz	a0,20fa <manywrites+0x102>
          int cc = write(fd, buf, sz);
    20b0:	660d                	lui	a2,0x3
    20b2:	85da                	mv	a1,s6
    20b4:	00004097          	auipc	ra,0x4
    20b8:	8f4080e7          	jalr	-1804(ra) # 59a8 <write>
          if(cc != sz){
    20bc:	678d                	lui	a5,0x3
    20be:	04f51e63          	bne	a0,a5,211a <manywrites+0x122>
          close(fd);
    20c2:	854a                	mv	a0,s2
    20c4:	00004097          	auipc	ra,0x4
    20c8:	8ec080e7          	jalr	-1812(ra) # 59b0 <close>
        for(int i = 0; i < ci+1; i++){
    20cc:	2a05                	addiw	s4,s4,1
    20ce:	fd49d6e3          	bge	s3,s4,209a <manywrites+0xa2>
        unlink(name);
    20d2:	fa840513          	addi	a0,s0,-88
    20d6:	00004097          	auipc	ra,0x4
    20da:	902080e7          	jalr	-1790(ra) # 59d8 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    20de:	3bfd                	addiw	s7,s7,-1
    20e0:	fa0b9ae3          	bnez	s7,2094 <manywrites+0x9c>
      unlink(name);
    20e4:	fa840513          	addi	a0,s0,-88
    20e8:	00004097          	auipc	ra,0x4
    20ec:	8f0080e7          	jalr	-1808(ra) # 59d8 <unlink>
      exit(0);
    20f0:	4501                	li	a0,0
    20f2:	00004097          	auipc	ra,0x4
    20f6:	896080e7          	jalr	-1898(ra) # 5988 <exit>
            printf("%s: cannot create %s\n", s, name);
    20fa:	fa840613          	addi	a2,s0,-88
    20fe:	85d6                	mv	a1,s5
    2100:	00005517          	auipc	a0,0x5
    2104:	c2050513          	addi	a0,a0,-992 # 6d20 <malloc+0xf4a>
    2108:	00004097          	auipc	ra,0x4
    210c:	c10080e7          	jalr	-1008(ra) # 5d18 <printf>
            exit(1);
    2110:	4505                	li	a0,1
    2112:	00004097          	auipc	ra,0x4
    2116:	876080e7          	jalr	-1930(ra) # 5988 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    211a:	86aa                	mv	a3,a0
    211c:	660d                	lui	a2,0x3
    211e:	85d6                	mv	a1,s5
    2120:	00004517          	auipc	a0,0x4
    2124:	20850513          	addi	a0,a0,520 # 6328 <malloc+0x552>
    2128:	00004097          	auipc	ra,0x4
    212c:	bf0080e7          	jalr	-1040(ra) # 5d18 <printf>
            exit(1);
    2130:	4505                	li	a0,1
    2132:	00004097          	auipc	ra,0x4
    2136:	856080e7          	jalr	-1962(ra) # 5988 <exit>
      exit(st);
    213a:	00004097          	auipc	ra,0x4
    213e:	84e080e7          	jalr	-1970(ra) # 5988 <exit>

0000000000002142 <forktest>:
{
    2142:	7179                	addi	sp,sp,-48
    2144:	f406                	sd	ra,40(sp)
    2146:	f022                	sd	s0,32(sp)
    2148:	ec26                	sd	s1,24(sp)
    214a:	e84a                	sd	s2,16(sp)
    214c:	e44e                	sd	s3,8(sp)
    214e:	1800                	addi	s0,sp,48
    2150:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    2152:	4481                	li	s1,0
    2154:	3e800913          	li	s2,1000
    pid = fork();
    2158:	00004097          	auipc	ra,0x4
    215c:	828080e7          	jalr	-2008(ra) # 5980 <fork>
    if(pid < 0)
    2160:	02054863          	bltz	a0,2190 <forktest+0x4e>
    if(pid == 0)
    2164:	c115                	beqz	a0,2188 <forktest+0x46>
  for(n=0; n<N; n++){
    2166:	2485                	addiw	s1,s1,1
    2168:	ff2498e3          	bne	s1,s2,2158 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    216c:	85ce                	mv	a1,s3
    216e:	00005517          	auipc	a0,0x5
    2172:	be250513          	addi	a0,a0,-1054 # 6d50 <malloc+0xf7a>
    2176:	00004097          	auipc	ra,0x4
    217a:	ba2080e7          	jalr	-1118(ra) # 5d18 <printf>
    exit(1);
    217e:	4505                	li	a0,1
    2180:	00004097          	auipc	ra,0x4
    2184:	808080e7          	jalr	-2040(ra) # 5988 <exit>
      exit(0);
    2188:	00004097          	auipc	ra,0x4
    218c:	800080e7          	jalr	-2048(ra) # 5988 <exit>
  if (n == 0) {
    2190:	cc9d                	beqz	s1,21ce <forktest+0x8c>
  if(n == N){
    2192:	3e800793          	li	a5,1000
    2196:	fcf48be3          	beq	s1,a5,216c <forktest+0x2a>
  for(; n > 0; n--){
    219a:	00905b63          	blez	s1,21b0 <forktest+0x6e>
    if(wait(0) < 0){
    219e:	4501                	li	a0,0
    21a0:	00003097          	auipc	ra,0x3
    21a4:	7f0080e7          	jalr	2032(ra) # 5990 <wait>
    21a8:	04054163          	bltz	a0,21ea <forktest+0xa8>
  for(; n > 0; n--){
    21ac:	34fd                	addiw	s1,s1,-1
    21ae:	f8e5                	bnez	s1,219e <forktest+0x5c>
  if(wait(0) != -1){
    21b0:	4501                	li	a0,0
    21b2:	00003097          	auipc	ra,0x3
    21b6:	7de080e7          	jalr	2014(ra) # 5990 <wait>
    21ba:	57fd                	li	a5,-1
    21bc:	04f51563          	bne	a0,a5,2206 <forktest+0xc4>
}
    21c0:	70a2                	ld	ra,40(sp)
    21c2:	7402                	ld	s0,32(sp)
    21c4:	64e2                	ld	s1,24(sp)
    21c6:	6942                	ld	s2,16(sp)
    21c8:	69a2                	ld	s3,8(sp)
    21ca:	6145                	addi	sp,sp,48
    21cc:	8082                	ret
    printf("%s: no fork at all!\n", s);
    21ce:	85ce                	mv	a1,s3
    21d0:	00005517          	auipc	a0,0x5
    21d4:	b6850513          	addi	a0,a0,-1176 # 6d38 <malloc+0xf62>
    21d8:	00004097          	auipc	ra,0x4
    21dc:	b40080e7          	jalr	-1216(ra) # 5d18 <printf>
    exit(1);
    21e0:	4505                	li	a0,1
    21e2:	00003097          	auipc	ra,0x3
    21e6:	7a6080e7          	jalr	1958(ra) # 5988 <exit>
      printf("%s: wait stopped early\n", s);
    21ea:	85ce                	mv	a1,s3
    21ec:	00005517          	auipc	a0,0x5
    21f0:	b8c50513          	addi	a0,a0,-1140 # 6d78 <malloc+0xfa2>
    21f4:	00004097          	auipc	ra,0x4
    21f8:	b24080e7          	jalr	-1244(ra) # 5d18 <printf>
      exit(1);
    21fc:	4505                	li	a0,1
    21fe:	00003097          	auipc	ra,0x3
    2202:	78a080e7          	jalr	1930(ra) # 5988 <exit>
    printf("%s: wait got too many\n", s);
    2206:	85ce                	mv	a1,s3
    2208:	00005517          	auipc	a0,0x5
    220c:	b8850513          	addi	a0,a0,-1144 # 6d90 <malloc+0xfba>
    2210:	00004097          	auipc	ra,0x4
    2214:	b08080e7          	jalr	-1272(ra) # 5d18 <printf>
    exit(1);
    2218:	4505                	li	a0,1
    221a:	00003097          	auipc	ra,0x3
    221e:	76e080e7          	jalr	1902(ra) # 5988 <exit>

0000000000002222 <kernmem>:
{
    2222:	715d                	addi	sp,sp,-80
    2224:	e486                	sd	ra,72(sp)
    2226:	e0a2                	sd	s0,64(sp)
    2228:	fc26                	sd	s1,56(sp)
    222a:	f84a                	sd	s2,48(sp)
    222c:	f44e                	sd	s3,40(sp)
    222e:	f052                	sd	s4,32(sp)
    2230:	ec56                	sd	s5,24(sp)
    2232:	0880                	addi	s0,sp,80
    2234:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2236:	4485                	li	s1,1
    2238:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    223a:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    223c:	69b1                	lui	s3,0xc
    223e:	35098993          	addi	s3,s3,848 # c350 <buf+0x430>
    2242:	1003d937          	lui	s2,0x1003d
    2246:	090e                	slli	s2,s2,0x3
    2248:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e550>
    pid = fork();
    224c:	00003097          	auipc	ra,0x3
    2250:	734080e7          	jalr	1844(ra) # 5980 <fork>
    if(pid < 0){
    2254:	02054963          	bltz	a0,2286 <kernmem+0x64>
    if(pid == 0){
    2258:	c529                	beqz	a0,22a2 <kernmem+0x80>
    wait(&xstatus);
    225a:	fbc40513          	addi	a0,s0,-68
    225e:	00003097          	auipc	ra,0x3
    2262:	732080e7          	jalr	1842(ra) # 5990 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2266:	fbc42783          	lw	a5,-68(s0)
    226a:	05579d63          	bne	a5,s5,22c4 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    226e:	94ce                	add	s1,s1,s3
    2270:	fd249ee3          	bne	s1,s2,224c <kernmem+0x2a>
}
    2274:	60a6                	ld	ra,72(sp)
    2276:	6406                	ld	s0,64(sp)
    2278:	74e2                	ld	s1,56(sp)
    227a:	7942                	ld	s2,48(sp)
    227c:	79a2                	ld	s3,40(sp)
    227e:	7a02                	ld	s4,32(sp)
    2280:	6ae2                	ld	s5,24(sp)
    2282:	6161                	addi	sp,sp,80
    2284:	8082                	ret
      printf("%s: fork failed\n", s);
    2286:	85d2                	mv	a1,s4
    2288:	00005517          	auipc	a0,0x5
    228c:	83850513          	addi	a0,a0,-1992 # 6ac0 <malloc+0xcea>
    2290:	00004097          	auipc	ra,0x4
    2294:	a88080e7          	jalr	-1400(ra) # 5d18 <printf>
      exit(1);
    2298:	4505                	li	a0,1
    229a:	00003097          	auipc	ra,0x3
    229e:	6ee080e7          	jalr	1774(ra) # 5988 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    22a2:	0004c683          	lbu	a3,0(s1)
    22a6:	8626                	mv	a2,s1
    22a8:	85d2                	mv	a1,s4
    22aa:	00005517          	auipc	a0,0x5
    22ae:	afe50513          	addi	a0,a0,-1282 # 6da8 <malloc+0xfd2>
    22b2:	00004097          	auipc	ra,0x4
    22b6:	a66080e7          	jalr	-1434(ra) # 5d18 <printf>
      exit(1);
    22ba:	4505                	li	a0,1
    22bc:	00003097          	auipc	ra,0x3
    22c0:	6cc080e7          	jalr	1740(ra) # 5988 <exit>
      exit(1);
    22c4:	4505                	li	a0,1
    22c6:	00003097          	auipc	ra,0x3
    22ca:	6c2080e7          	jalr	1730(ra) # 5988 <exit>

00000000000022ce <MAXVAplus>:
{
    22ce:	7179                	addi	sp,sp,-48
    22d0:	f406                	sd	ra,40(sp)
    22d2:	f022                	sd	s0,32(sp)
    22d4:	ec26                	sd	s1,24(sp)
    22d6:	e84a                	sd	s2,16(sp)
    22d8:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    22da:	4785                	li	a5,1
    22dc:	179a                	slli	a5,a5,0x26
    22de:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    22e2:	fd843783          	ld	a5,-40(s0)
    22e6:	cf85                	beqz	a5,231e <MAXVAplus+0x50>
    22e8:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    22ea:	54fd                	li	s1,-1
    pid = fork();
    22ec:	00003097          	auipc	ra,0x3
    22f0:	694080e7          	jalr	1684(ra) # 5980 <fork>
    if(pid < 0){
    22f4:	02054b63          	bltz	a0,232a <MAXVAplus+0x5c>
    if(pid == 0){
    22f8:	c539                	beqz	a0,2346 <MAXVAplus+0x78>
    wait(&xstatus);
    22fa:	fd440513          	addi	a0,s0,-44
    22fe:	00003097          	auipc	ra,0x3
    2302:	692080e7          	jalr	1682(ra) # 5990 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2306:	fd442783          	lw	a5,-44(s0)
    230a:	06979463          	bne	a5,s1,2372 <MAXVAplus+0xa4>
  for( ; a != 0; a <<= 1){
    230e:	fd843783          	ld	a5,-40(s0)
    2312:	0786                	slli	a5,a5,0x1
    2314:	fcf43c23          	sd	a5,-40(s0)
    2318:	fd843783          	ld	a5,-40(s0)
    231c:	fbe1                	bnez	a5,22ec <MAXVAplus+0x1e>
}
    231e:	70a2                	ld	ra,40(sp)
    2320:	7402                	ld	s0,32(sp)
    2322:	64e2                	ld	s1,24(sp)
    2324:	6942                	ld	s2,16(sp)
    2326:	6145                	addi	sp,sp,48
    2328:	8082                	ret
      printf("%s: fork failed\n", s);
    232a:	85ca                	mv	a1,s2
    232c:	00004517          	auipc	a0,0x4
    2330:	79450513          	addi	a0,a0,1940 # 6ac0 <malloc+0xcea>
    2334:	00004097          	auipc	ra,0x4
    2338:	9e4080e7          	jalr	-1564(ra) # 5d18 <printf>
      exit(1);
    233c:	4505                	li	a0,1
    233e:	00003097          	auipc	ra,0x3
    2342:	64a080e7          	jalr	1610(ra) # 5988 <exit>
      *(char*)a = 99;
    2346:	fd843783          	ld	a5,-40(s0)
    234a:	06300713          	li	a4,99
    234e:	00e78023          	sb	a4,0(a5) # 3000 <fourteen+0xe4>
      printf("%s: oops wrote %x\n", s, a);
    2352:	fd843603          	ld	a2,-40(s0)
    2356:	85ca                	mv	a1,s2
    2358:	00005517          	auipc	a0,0x5
    235c:	a7050513          	addi	a0,a0,-1424 # 6dc8 <malloc+0xff2>
    2360:	00004097          	auipc	ra,0x4
    2364:	9b8080e7          	jalr	-1608(ra) # 5d18 <printf>
      exit(1);
    2368:	4505                	li	a0,1
    236a:	00003097          	auipc	ra,0x3
    236e:	61e080e7          	jalr	1566(ra) # 5988 <exit>
      exit(1);
    2372:	4505                	li	a0,1
    2374:	00003097          	auipc	ra,0x3
    2378:	614080e7          	jalr	1556(ra) # 5988 <exit>

000000000000237c <bigargtest>:
{
    237c:	7179                	addi	sp,sp,-48
    237e:	f406                	sd	ra,40(sp)
    2380:	f022                	sd	s0,32(sp)
    2382:	ec26                	sd	s1,24(sp)
    2384:	1800                	addi	s0,sp,48
    2386:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2388:	00005517          	auipc	a0,0x5
    238c:	a5850513          	addi	a0,a0,-1448 # 6de0 <malloc+0x100a>
    2390:	00003097          	auipc	ra,0x3
    2394:	648080e7          	jalr	1608(ra) # 59d8 <unlink>
  pid = fork();
    2398:	00003097          	auipc	ra,0x3
    239c:	5e8080e7          	jalr	1512(ra) # 5980 <fork>
  if(pid == 0){
    23a0:	c121                	beqz	a0,23e0 <bigargtest+0x64>
  } else if(pid < 0){
    23a2:	0a054063          	bltz	a0,2442 <bigargtest+0xc6>
  wait(&xstatus);
    23a6:	fdc40513          	addi	a0,s0,-36
    23aa:	00003097          	auipc	ra,0x3
    23ae:	5e6080e7          	jalr	1510(ra) # 5990 <wait>
  if(xstatus != 0)
    23b2:	fdc42503          	lw	a0,-36(s0)
    23b6:	e545                	bnez	a0,245e <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    23b8:	4581                	li	a1,0
    23ba:	00005517          	auipc	a0,0x5
    23be:	a2650513          	addi	a0,a0,-1498 # 6de0 <malloc+0x100a>
    23c2:	00003097          	auipc	ra,0x3
    23c6:	606080e7          	jalr	1542(ra) # 59c8 <open>
  if(fd < 0){
    23ca:	08054e63          	bltz	a0,2466 <bigargtest+0xea>
  close(fd);
    23ce:	00003097          	auipc	ra,0x3
    23d2:	5e2080e7          	jalr	1506(ra) # 59b0 <close>
}
    23d6:	70a2                	ld	ra,40(sp)
    23d8:	7402                	ld	s0,32(sp)
    23da:	64e2                	ld	s1,24(sp)
    23dc:	6145                	addi	sp,sp,48
    23de:	8082                	ret
    23e0:	00006797          	auipc	a5,0x6
    23e4:	32878793          	addi	a5,a5,808 # 8708 <args.1>
    23e8:	00006697          	auipc	a3,0x6
    23ec:	41868693          	addi	a3,a3,1048 # 8800 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    23f0:	00005717          	auipc	a4,0x5
    23f4:	a0070713          	addi	a4,a4,-1536 # 6df0 <malloc+0x101a>
    23f8:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    23fa:	07a1                	addi	a5,a5,8
    23fc:	fed79ee3          	bne	a5,a3,23f8 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    2400:	00006597          	auipc	a1,0x6
    2404:	30858593          	addi	a1,a1,776 # 8708 <args.1>
    2408:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    240c:	00004517          	auipc	a0,0x4
    2410:	e5c50513          	addi	a0,a0,-420 # 6268 <malloc+0x492>
    2414:	00003097          	auipc	ra,0x3
    2418:	5ac080e7          	jalr	1452(ra) # 59c0 <exec>
    fd = open("bigarg-ok", O_CREATE);
    241c:	20000593          	li	a1,512
    2420:	00005517          	auipc	a0,0x5
    2424:	9c050513          	addi	a0,a0,-1600 # 6de0 <malloc+0x100a>
    2428:	00003097          	auipc	ra,0x3
    242c:	5a0080e7          	jalr	1440(ra) # 59c8 <open>
    close(fd);
    2430:	00003097          	auipc	ra,0x3
    2434:	580080e7          	jalr	1408(ra) # 59b0 <close>
    exit(0);
    2438:	4501                	li	a0,0
    243a:	00003097          	auipc	ra,0x3
    243e:	54e080e7          	jalr	1358(ra) # 5988 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2442:	85a6                	mv	a1,s1
    2444:	00005517          	auipc	a0,0x5
    2448:	a8c50513          	addi	a0,a0,-1396 # 6ed0 <malloc+0x10fa>
    244c:	00004097          	auipc	ra,0x4
    2450:	8cc080e7          	jalr	-1844(ra) # 5d18 <printf>
    exit(1);
    2454:	4505                	li	a0,1
    2456:	00003097          	auipc	ra,0x3
    245a:	532080e7          	jalr	1330(ra) # 5988 <exit>
    exit(xstatus);
    245e:	00003097          	auipc	ra,0x3
    2462:	52a080e7          	jalr	1322(ra) # 5988 <exit>
    printf("%s: bigarg test failed!\n", s);
    2466:	85a6                	mv	a1,s1
    2468:	00005517          	auipc	a0,0x5
    246c:	a8850513          	addi	a0,a0,-1400 # 6ef0 <malloc+0x111a>
    2470:	00004097          	auipc	ra,0x4
    2474:	8a8080e7          	jalr	-1880(ra) # 5d18 <printf>
    exit(1);
    2478:	4505                	li	a0,1
    247a:	00003097          	auipc	ra,0x3
    247e:	50e080e7          	jalr	1294(ra) # 5988 <exit>

0000000000002482 <stacktest>:
{
    2482:	7179                	addi	sp,sp,-48
    2484:	f406                	sd	ra,40(sp)
    2486:	f022                	sd	s0,32(sp)
    2488:	ec26                	sd	s1,24(sp)
    248a:	1800                	addi	s0,sp,48
    248c:	84aa                	mv	s1,a0
  pid = fork();
    248e:	00003097          	auipc	ra,0x3
    2492:	4f2080e7          	jalr	1266(ra) # 5980 <fork>
  if(pid == 0) {
    2496:	c115                	beqz	a0,24ba <stacktest+0x38>
  } else if(pid < 0){
    2498:	04054463          	bltz	a0,24e0 <stacktest+0x5e>
  wait(&xstatus);
    249c:	fdc40513          	addi	a0,s0,-36
    24a0:	00003097          	auipc	ra,0x3
    24a4:	4f0080e7          	jalr	1264(ra) # 5990 <wait>
  if(xstatus == -1)  // kernel killed child?
    24a8:	fdc42503          	lw	a0,-36(s0)
    24ac:	57fd                	li	a5,-1
    24ae:	04f50763          	beq	a0,a5,24fc <stacktest+0x7a>
    exit(xstatus);
    24b2:	00003097          	auipc	ra,0x3
    24b6:	4d6080e7          	jalr	1238(ra) # 5988 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    24ba:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    24bc:	77fd                	lui	a5,0xfffff
    24be:	97ba                	add	a5,a5,a4
    24c0:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff00d0>
    24c4:	85a6                	mv	a1,s1
    24c6:	00005517          	auipc	a0,0x5
    24ca:	a4a50513          	addi	a0,a0,-1462 # 6f10 <malloc+0x113a>
    24ce:	00004097          	auipc	ra,0x4
    24d2:	84a080e7          	jalr	-1974(ra) # 5d18 <printf>
    exit(1);
    24d6:	4505                	li	a0,1
    24d8:	00003097          	auipc	ra,0x3
    24dc:	4b0080e7          	jalr	1200(ra) # 5988 <exit>
    printf("%s: fork failed\n", s);
    24e0:	85a6                	mv	a1,s1
    24e2:	00004517          	auipc	a0,0x4
    24e6:	5de50513          	addi	a0,a0,1502 # 6ac0 <malloc+0xcea>
    24ea:	00004097          	auipc	ra,0x4
    24ee:	82e080e7          	jalr	-2002(ra) # 5d18 <printf>
    exit(1);
    24f2:	4505                	li	a0,1
    24f4:	00003097          	auipc	ra,0x3
    24f8:	494080e7          	jalr	1172(ra) # 5988 <exit>
    exit(0);
    24fc:	4501                	li	a0,0
    24fe:	00003097          	auipc	ra,0x3
    2502:	48a080e7          	jalr	1162(ra) # 5988 <exit>

0000000000002506 <copyinstr3>:
{
    2506:	7179                	addi	sp,sp,-48
    2508:	f406                	sd	ra,40(sp)
    250a:	f022                	sd	s0,32(sp)
    250c:	ec26                	sd	s1,24(sp)
    250e:	1800                	addi	s0,sp,48
  sbrk(8192);
    2510:	6509                	lui	a0,0x2
    2512:	00003097          	auipc	ra,0x3
    2516:	4fe080e7          	jalr	1278(ra) # 5a10 <sbrk>
  uint64 top = (uint64) sbrk(0);
    251a:	4501                	li	a0,0
    251c:	00003097          	auipc	ra,0x3
    2520:	4f4080e7          	jalr	1268(ra) # 5a10 <sbrk>
  if((top % PGSIZE) != 0){
    2524:	03451793          	slli	a5,a0,0x34
    2528:	e3c9                	bnez	a5,25aa <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    252a:	4501                	li	a0,0
    252c:	00003097          	auipc	ra,0x3
    2530:	4e4080e7          	jalr	1252(ra) # 5a10 <sbrk>
  if(top % PGSIZE){
    2534:	03451793          	slli	a5,a0,0x34
    2538:	e3d9                	bnez	a5,25be <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    253a:	fff50493          	addi	s1,a0,-1 # 1fff <manywrites+0x7>
  *b = 'x';
    253e:	07800793          	li	a5,120
    2542:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2546:	8526                	mv	a0,s1
    2548:	00003097          	auipc	ra,0x3
    254c:	490080e7          	jalr	1168(ra) # 59d8 <unlink>
  if(ret != -1){
    2550:	57fd                	li	a5,-1
    2552:	08f51363          	bne	a0,a5,25d8 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2556:	20100593          	li	a1,513
    255a:	8526                	mv	a0,s1
    255c:	00003097          	auipc	ra,0x3
    2560:	46c080e7          	jalr	1132(ra) # 59c8 <open>
  if(fd != -1){
    2564:	57fd                	li	a5,-1
    2566:	08f51863          	bne	a0,a5,25f6 <copyinstr3+0xf0>
  ret = link(b, b);
    256a:	85a6                	mv	a1,s1
    256c:	8526                	mv	a0,s1
    256e:	00003097          	auipc	ra,0x3
    2572:	47a080e7          	jalr	1146(ra) # 59e8 <link>
  if(ret != -1){
    2576:	57fd                	li	a5,-1
    2578:	08f51e63          	bne	a0,a5,2614 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    257c:	00005797          	auipc	a5,0x5
    2580:	62c78793          	addi	a5,a5,1580 # 7ba8 <malloc+0x1dd2>
    2584:	fcf43823          	sd	a5,-48(s0)
    2588:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    258c:	fd040593          	addi	a1,s0,-48
    2590:	8526                	mv	a0,s1
    2592:	00003097          	auipc	ra,0x3
    2596:	42e080e7          	jalr	1070(ra) # 59c0 <exec>
  if(ret != -1){
    259a:	57fd                	li	a5,-1
    259c:	08f51c63          	bne	a0,a5,2634 <copyinstr3+0x12e>
}
    25a0:	70a2                	ld	ra,40(sp)
    25a2:	7402                	ld	s0,32(sp)
    25a4:	64e2                	ld	s1,24(sp)
    25a6:	6145                	addi	sp,sp,48
    25a8:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    25aa:	0347d513          	srli	a0,a5,0x34
    25ae:	6785                	lui	a5,0x1
    25b0:	40a7853b          	subw	a0,a5,a0
    25b4:	00003097          	auipc	ra,0x3
    25b8:	45c080e7          	jalr	1116(ra) # 5a10 <sbrk>
    25bc:	b7bd                	j	252a <copyinstr3+0x24>
    printf("oops\n");
    25be:	00005517          	auipc	a0,0x5
    25c2:	97a50513          	addi	a0,a0,-1670 # 6f38 <malloc+0x1162>
    25c6:	00003097          	auipc	ra,0x3
    25ca:	752080e7          	jalr	1874(ra) # 5d18 <printf>
    exit(1);
    25ce:	4505                	li	a0,1
    25d0:	00003097          	auipc	ra,0x3
    25d4:	3b8080e7          	jalr	952(ra) # 5988 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    25d8:	862a                	mv	a2,a0
    25da:	85a6                	mv	a1,s1
    25dc:	00004517          	auipc	a0,0x4
    25e0:	40450513          	addi	a0,a0,1028 # 69e0 <malloc+0xc0a>
    25e4:	00003097          	auipc	ra,0x3
    25e8:	734080e7          	jalr	1844(ra) # 5d18 <printf>
    exit(1);
    25ec:	4505                	li	a0,1
    25ee:	00003097          	auipc	ra,0x3
    25f2:	39a080e7          	jalr	922(ra) # 5988 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    25f6:	862a                	mv	a2,a0
    25f8:	85a6                	mv	a1,s1
    25fa:	00004517          	auipc	a0,0x4
    25fe:	40650513          	addi	a0,a0,1030 # 6a00 <malloc+0xc2a>
    2602:	00003097          	auipc	ra,0x3
    2606:	716080e7          	jalr	1814(ra) # 5d18 <printf>
    exit(1);
    260a:	4505                	li	a0,1
    260c:	00003097          	auipc	ra,0x3
    2610:	37c080e7          	jalr	892(ra) # 5988 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2614:	86aa                	mv	a3,a0
    2616:	8626                	mv	a2,s1
    2618:	85a6                	mv	a1,s1
    261a:	00004517          	auipc	a0,0x4
    261e:	40650513          	addi	a0,a0,1030 # 6a20 <malloc+0xc4a>
    2622:	00003097          	auipc	ra,0x3
    2626:	6f6080e7          	jalr	1782(ra) # 5d18 <printf>
    exit(1);
    262a:	4505                	li	a0,1
    262c:	00003097          	auipc	ra,0x3
    2630:	35c080e7          	jalr	860(ra) # 5988 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2634:	567d                	li	a2,-1
    2636:	85a6                	mv	a1,s1
    2638:	00004517          	auipc	a0,0x4
    263c:	41050513          	addi	a0,a0,1040 # 6a48 <malloc+0xc72>
    2640:	00003097          	auipc	ra,0x3
    2644:	6d8080e7          	jalr	1752(ra) # 5d18 <printf>
    exit(1);
    2648:	4505                	li	a0,1
    264a:	00003097          	auipc	ra,0x3
    264e:	33e080e7          	jalr	830(ra) # 5988 <exit>

0000000000002652 <rwsbrk>:
{
    2652:	1101                	addi	sp,sp,-32
    2654:	ec06                	sd	ra,24(sp)
    2656:	e822                	sd	s0,16(sp)
    2658:	e426                	sd	s1,8(sp)
    265a:	e04a                	sd	s2,0(sp)
    265c:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    265e:	6509                	lui	a0,0x2
    2660:	00003097          	auipc	ra,0x3
    2664:	3b0080e7          	jalr	944(ra) # 5a10 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2668:	57fd                	li	a5,-1
    266a:	06f50363          	beq	a0,a5,26d0 <rwsbrk+0x7e>
    266e:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2670:	7579                	lui	a0,0xffffe
    2672:	00003097          	auipc	ra,0x3
    2676:	39e080e7          	jalr	926(ra) # 5a10 <sbrk>
    267a:	57fd                	li	a5,-1
    267c:	06f50763          	beq	a0,a5,26ea <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2680:	20100593          	li	a1,513
    2684:	00004517          	auipc	a0,0x4
    2688:	8c450513          	addi	a0,a0,-1852 # 5f48 <malloc+0x172>
    268c:	00003097          	auipc	ra,0x3
    2690:	33c080e7          	jalr	828(ra) # 59c8 <open>
    2694:	892a                	mv	s2,a0
  if(fd < 0){
    2696:	06054763          	bltz	a0,2704 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    269a:	6505                	lui	a0,0x1
    269c:	94aa                	add	s1,s1,a0
    269e:	40000613          	li	a2,1024
    26a2:	85a6                	mv	a1,s1
    26a4:	854a                	mv	a0,s2
    26a6:	00003097          	auipc	ra,0x3
    26aa:	302080e7          	jalr	770(ra) # 59a8 <write>
    26ae:	862a                	mv	a2,a0
  if(n >= 0){
    26b0:	06054763          	bltz	a0,271e <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    26b4:	85a6                	mv	a1,s1
    26b6:	00005517          	auipc	a0,0x5
    26ba:	8da50513          	addi	a0,a0,-1830 # 6f90 <malloc+0x11ba>
    26be:	00003097          	auipc	ra,0x3
    26c2:	65a080e7          	jalr	1626(ra) # 5d18 <printf>
    exit(1);
    26c6:	4505                	li	a0,1
    26c8:	00003097          	auipc	ra,0x3
    26cc:	2c0080e7          	jalr	704(ra) # 5988 <exit>
    printf("sbrk(rwsbrk) failed\n");
    26d0:	00005517          	auipc	a0,0x5
    26d4:	87050513          	addi	a0,a0,-1936 # 6f40 <malloc+0x116a>
    26d8:	00003097          	auipc	ra,0x3
    26dc:	640080e7          	jalr	1600(ra) # 5d18 <printf>
    exit(1);
    26e0:	4505                	li	a0,1
    26e2:	00003097          	auipc	ra,0x3
    26e6:	2a6080e7          	jalr	678(ra) # 5988 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    26ea:	00005517          	auipc	a0,0x5
    26ee:	86e50513          	addi	a0,a0,-1938 # 6f58 <malloc+0x1182>
    26f2:	00003097          	auipc	ra,0x3
    26f6:	626080e7          	jalr	1574(ra) # 5d18 <printf>
    exit(1);
    26fa:	4505                	li	a0,1
    26fc:	00003097          	auipc	ra,0x3
    2700:	28c080e7          	jalr	652(ra) # 5988 <exit>
    printf("open(rwsbrk) failed\n");
    2704:	00005517          	auipc	a0,0x5
    2708:	87450513          	addi	a0,a0,-1932 # 6f78 <malloc+0x11a2>
    270c:	00003097          	auipc	ra,0x3
    2710:	60c080e7          	jalr	1548(ra) # 5d18 <printf>
    exit(1);
    2714:	4505                	li	a0,1
    2716:	00003097          	auipc	ra,0x3
    271a:	272080e7          	jalr	626(ra) # 5988 <exit>
  close(fd);
    271e:	854a                	mv	a0,s2
    2720:	00003097          	auipc	ra,0x3
    2724:	290080e7          	jalr	656(ra) # 59b0 <close>
  unlink("rwsbrk");
    2728:	00004517          	auipc	a0,0x4
    272c:	82050513          	addi	a0,a0,-2016 # 5f48 <malloc+0x172>
    2730:	00003097          	auipc	ra,0x3
    2734:	2a8080e7          	jalr	680(ra) # 59d8 <unlink>
  fd = open("README", O_RDONLY);
    2738:	4581                	li	a1,0
    273a:	00004517          	auipc	a0,0x4
    273e:	ce650513          	addi	a0,a0,-794 # 6420 <malloc+0x64a>
    2742:	00003097          	auipc	ra,0x3
    2746:	286080e7          	jalr	646(ra) # 59c8 <open>
    274a:	892a                	mv	s2,a0
  if(fd < 0){
    274c:	02054963          	bltz	a0,277e <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    2750:	4629                	li	a2,10
    2752:	85a6                	mv	a1,s1
    2754:	00003097          	auipc	ra,0x3
    2758:	24c080e7          	jalr	588(ra) # 59a0 <read>
    275c:	862a                	mv	a2,a0
  if(n >= 0){
    275e:	02054d63          	bltz	a0,2798 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2762:	85a6                	mv	a1,s1
    2764:	00005517          	auipc	a0,0x5
    2768:	85c50513          	addi	a0,a0,-1956 # 6fc0 <malloc+0x11ea>
    276c:	00003097          	auipc	ra,0x3
    2770:	5ac080e7          	jalr	1452(ra) # 5d18 <printf>
    exit(1);
    2774:	4505                	li	a0,1
    2776:	00003097          	auipc	ra,0x3
    277a:	212080e7          	jalr	530(ra) # 5988 <exit>
    printf("open(rwsbrk) failed\n");
    277e:	00004517          	auipc	a0,0x4
    2782:	7fa50513          	addi	a0,a0,2042 # 6f78 <malloc+0x11a2>
    2786:	00003097          	auipc	ra,0x3
    278a:	592080e7          	jalr	1426(ra) # 5d18 <printf>
    exit(1);
    278e:	4505                	li	a0,1
    2790:	00003097          	auipc	ra,0x3
    2794:	1f8080e7          	jalr	504(ra) # 5988 <exit>
  close(fd);
    2798:	854a                	mv	a0,s2
    279a:	00003097          	auipc	ra,0x3
    279e:	216080e7          	jalr	534(ra) # 59b0 <close>
  exit(0);
    27a2:	4501                	li	a0,0
    27a4:	00003097          	auipc	ra,0x3
    27a8:	1e4080e7          	jalr	484(ra) # 5988 <exit>

00000000000027ac <sbrkbasic>:
{
    27ac:	7139                	addi	sp,sp,-64
    27ae:	fc06                	sd	ra,56(sp)
    27b0:	f822                	sd	s0,48(sp)
    27b2:	f426                	sd	s1,40(sp)
    27b4:	f04a                	sd	s2,32(sp)
    27b6:	ec4e                	sd	s3,24(sp)
    27b8:	e852                	sd	s4,16(sp)
    27ba:	0080                	addi	s0,sp,64
    27bc:	8a2a                	mv	s4,a0
  pid = fork();
    27be:	00003097          	auipc	ra,0x3
    27c2:	1c2080e7          	jalr	450(ra) # 5980 <fork>
  if(pid < 0){
    27c6:	02054c63          	bltz	a0,27fe <sbrkbasic+0x52>
  if(pid == 0){
    27ca:	ed21                	bnez	a0,2822 <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    27cc:	40000537          	lui	a0,0x40000
    27d0:	00003097          	auipc	ra,0x3
    27d4:	240080e7          	jalr	576(ra) # 5a10 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    27d8:	57fd                	li	a5,-1
    27da:	02f50f63          	beq	a0,a5,2818 <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    27de:	400007b7          	lui	a5,0x40000
    27e2:	97aa                	add	a5,a5,a0
      *b = 99;
    27e4:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    27e8:	6705                	lui	a4,0x1
      *b = 99;
    27ea:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff10d0>
    for(b = a; b < a+TOOMUCH; b += 4096){
    27ee:	953a                	add	a0,a0,a4
    27f0:	fef51de3          	bne	a0,a5,27ea <sbrkbasic+0x3e>
    exit(1);
    27f4:	4505                	li	a0,1
    27f6:	00003097          	auipc	ra,0x3
    27fa:	192080e7          	jalr	402(ra) # 5988 <exit>
    printf("fork failed in sbrkbasic\n");
    27fe:	00004517          	auipc	a0,0x4
    2802:	7ea50513          	addi	a0,a0,2026 # 6fe8 <malloc+0x1212>
    2806:	00003097          	auipc	ra,0x3
    280a:	512080e7          	jalr	1298(ra) # 5d18 <printf>
    exit(1);
    280e:	4505                	li	a0,1
    2810:	00003097          	auipc	ra,0x3
    2814:	178080e7          	jalr	376(ra) # 5988 <exit>
      exit(0);
    2818:	4501                	li	a0,0
    281a:	00003097          	auipc	ra,0x3
    281e:	16e080e7          	jalr	366(ra) # 5988 <exit>
  wait(&xstatus);
    2822:	fcc40513          	addi	a0,s0,-52
    2826:	00003097          	auipc	ra,0x3
    282a:	16a080e7          	jalr	362(ra) # 5990 <wait>
  if(xstatus == 1){
    282e:	fcc42703          	lw	a4,-52(s0)
    2832:	4785                	li	a5,1
    2834:	00f70d63          	beq	a4,a5,284e <sbrkbasic+0xa2>
  a = sbrk(0);
    2838:	4501                	li	a0,0
    283a:	00003097          	auipc	ra,0x3
    283e:	1d6080e7          	jalr	470(ra) # 5a10 <sbrk>
    2842:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2844:	4901                	li	s2,0
    2846:	6985                	lui	s3,0x1
    2848:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x90>
    284c:	a005                	j	286c <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    284e:	85d2                	mv	a1,s4
    2850:	00004517          	auipc	a0,0x4
    2854:	7b850513          	addi	a0,a0,1976 # 7008 <malloc+0x1232>
    2858:	00003097          	auipc	ra,0x3
    285c:	4c0080e7          	jalr	1216(ra) # 5d18 <printf>
    exit(1);
    2860:	4505                	li	a0,1
    2862:	00003097          	auipc	ra,0x3
    2866:	126080e7          	jalr	294(ra) # 5988 <exit>
    a = b + 1;
    286a:	84be                	mv	s1,a5
    b = sbrk(1);
    286c:	4505                	li	a0,1
    286e:	00003097          	auipc	ra,0x3
    2872:	1a2080e7          	jalr	418(ra) # 5a10 <sbrk>
    if(b != a){
    2876:	04951c63          	bne	a0,s1,28ce <sbrkbasic+0x122>
    *b = 1;
    287a:	4785                	li	a5,1
    287c:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2880:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2884:	2905                	addiw	s2,s2,1
    2886:	ff3912e3          	bne	s2,s3,286a <sbrkbasic+0xbe>
  pid = fork();
    288a:	00003097          	auipc	ra,0x3
    288e:	0f6080e7          	jalr	246(ra) # 5980 <fork>
    2892:	892a                	mv	s2,a0
  if(pid < 0){
    2894:	04054e63          	bltz	a0,28f0 <sbrkbasic+0x144>
  c = sbrk(1);
    2898:	4505                	li	a0,1
    289a:	00003097          	auipc	ra,0x3
    289e:	176080e7          	jalr	374(ra) # 5a10 <sbrk>
  c = sbrk(1);
    28a2:	4505                	li	a0,1
    28a4:	00003097          	auipc	ra,0x3
    28a8:	16c080e7          	jalr	364(ra) # 5a10 <sbrk>
  if(c != a + 1){
    28ac:	0489                	addi	s1,s1,2
    28ae:	04a48f63          	beq	s1,a0,290c <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    28b2:	85d2                	mv	a1,s4
    28b4:	00004517          	auipc	a0,0x4
    28b8:	7b450513          	addi	a0,a0,1972 # 7068 <malloc+0x1292>
    28bc:	00003097          	auipc	ra,0x3
    28c0:	45c080e7          	jalr	1116(ra) # 5d18 <printf>
    exit(1);
    28c4:	4505                	li	a0,1
    28c6:	00003097          	auipc	ra,0x3
    28ca:	0c2080e7          	jalr	194(ra) # 5988 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    28ce:	872a                	mv	a4,a0
    28d0:	86a6                	mv	a3,s1
    28d2:	864a                	mv	a2,s2
    28d4:	85d2                	mv	a1,s4
    28d6:	00004517          	auipc	a0,0x4
    28da:	75250513          	addi	a0,a0,1874 # 7028 <malloc+0x1252>
    28de:	00003097          	auipc	ra,0x3
    28e2:	43a080e7          	jalr	1082(ra) # 5d18 <printf>
      exit(1);
    28e6:	4505                	li	a0,1
    28e8:	00003097          	auipc	ra,0x3
    28ec:	0a0080e7          	jalr	160(ra) # 5988 <exit>
    printf("%s: sbrk test fork failed\n", s);
    28f0:	85d2                	mv	a1,s4
    28f2:	00004517          	auipc	a0,0x4
    28f6:	75650513          	addi	a0,a0,1878 # 7048 <malloc+0x1272>
    28fa:	00003097          	auipc	ra,0x3
    28fe:	41e080e7          	jalr	1054(ra) # 5d18 <printf>
    exit(1);
    2902:	4505                	li	a0,1
    2904:	00003097          	auipc	ra,0x3
    2908:	084080e7          	jalr	132(ra) # 5988 <exit>
  if(pid == 0)
    290c:	00091763          	bnez	s2,291a <sbrkbasic+0x16e>
    exit(0);
    2910:	4501                	li	a0,0
    2912:	00003097          	auipc	ra,0x3
    2916:	076080e7          	jalr	118(ra) # 5988 <exit>
  wait(&xstatus);
    291a:	fcc40513          	addi	a0,s0,-52
    291e:	00003097          	auipc	ra,0x3
    2922:	072080e7          	jalr	114(ra) # 5990 <wait>
  exit(xstatus);
    2926:	fcc42503          	lw	a0,-52(s0)
    292a:	00003097          	auipc	ra,0x3
    292e:	05e080e7          	jalr	94(ra) # 5988 <exit>

0000000000002932 <sbrkmuch>:
{
    2932:	7179                	addi	sp,sp,-48
    2934:	f406                	sd	ra,40(sp)
    2936:	f022                	sd	s0,32(sp)
    2938:	ec26                	sd	s1,24(sp)
    293a:	e84a                	sd	s2,16(sp)
    293c:	e44e                	sd	s3,8(sp)
    293e:	e052                	sd	s4,0(sp)
    2940:	1800                	addi	s0,sp,48
    2942:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2944:	4501                	li	a0,0
    2946:	00003097          	auipc	ra,0x3
    294a:	0ca080e7          	jalr	202(ra) # 5a10 <sbrk>
    294e:	892a                	mv	s2,a0
  a = sbrk(0);
    2950:	4501                	li	a0,0
    2952:	00003097          	auipc	ra,0x3
    2956:	0be080e7          	jalr	190(ra) # 5a10 <sbrk>
    295a:	84aa                	mv	s1,a0
  p = sbrk(amt);
    295c:	06400537          	lui	a0,0x6400
    2960:	9d05                	subw	a0,a0,s1
    2962:	00003097          	auipc	ra,0x3
    2966:	0ae080e7          	jalr	174(ra) # 5a10 <sbrk>
  if (p != a) {
    296a:	0ca49863          	bne	s1,a0,2a3a <sbrkmuch+0x108>
  char *eee = sbrk(0);
    296e:	4501                	li	a0,0
    2970:	00003097          	auipc	ra,0x3
    2974:	0a0080e7          	jalr	160(ra) # 5a10 <sbrk>
    2978:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    297a:	00a4f963          	bgeu	s1,a0,298c <sbrkmuch+0x5a>
    *pp = 1;
    297e:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2980:	6705                	lui	a4,0x1
    *pp = 1;
    2982:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2986:	94ba                	add	s1,s1,a4
    2988:	fef4ede3          	bltu	s1,a5,2982 <sbrkmuch+0x50>
  *lastaddr = 99;
    298c:	064007b7          	lui	a5,0x6400
    2990:	06300713          	li	a4,99
    2994:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f10cf>
  a = sbrk(0);
    2998:	4501                	li	a0,0
    299a:	00003097          	auipc	ra,0x3
    299e:	076080e7          	jalr	118(ra) # 5a10 <sbrk>
    29a2:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    29a4:	757d                	lui	a0,0xfffff
    29a6:	00003097          	auipc	ra,0x3
    29aa:	06a080e7          	jalr	106(ra) # 5a10 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    29ae:	57fd                	li	a5,-1
    29b0:	0af50363          	beq	a0,a5,2a56 <sbrkmuch+0x124>
  c = sbrk(0);
    29b4:	4501                	li	a0,0
    29b6:	00003097          	auipc	ra,0x3
    29ba:	05a080e7          	jalr	90(ra) # 5a10 <sbrk>
  if(c != a - PGSIZE){
    29be:	77fd                	lui	a5,0xfffff
    29c0:	97a6                	add	a5,a5,s1
    29c2:	0af51863          	bne	a0,a5,2a72 <sbrkmuch+0x140>
  a = sbrk(0);
    29c6:	4501                	li	a0,0
    29c8:	00003097          	auipc	ra,0x3
    29cc:	048080e7          	jalr	72(ra) # 5a10 <sbrk>
    29d0:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    29d2:	6505                	lui	a0,0x1
    29d4:	00003097          	auipc	ra,0x3
    29d8:	03c080e7          	jalr	60(ra) # 5a10 <sbrk>
    29dc:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    29de:	0aa49a63          	bne	s1,a0,2a92 <sbrkmuch+0x160>
    29e2:	4501                	li	a0,0
    29e4:	00003097          	auipc	ra,0x3
    29e8:	02c080e7          	jalr	44(ra) # 5a10 <sbrk>
    29ec:	6785                	lui	a5,0x1
    29ee:	97a6                	add	a5,a5,s1
    29f0:	0af51163          	bne	a0,a5,2a92 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    29f4:	064007b7          	lui	a5,0x6400
    29f8:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f10cf>
    29fc:	06300793          	li	a5,99
    2a00:	0af70963          	beq	a4,a5,2ab2 <sbrkmuch+0x180>
  a = sbrk(0);
    2a04:	4501                	li	a0,0
    2a06:	00003097          	auipc	ra,0x3
    2a0a:	00a080e7          	jalr	10(ra) # 5a10 <sbrk>
    2a0e:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2a10:	4501                	li	a0,0
    2a12:	00003097          	auipc	ra,0x3
    2a16:	ffe080e7          	jalr	-2(ra) # 5a10 <sbrk>
    2a1a:	40a9053b          	subw	a0,s2,a0
    2a1e:	00003097          	auipc	ra,0x3
    2a22:	ff2080e7          	jalr	-14(ra) # 5a10 <sbrk>
  if(c != a){
    2a26:	0aa49463          	bne	s1,a0,2ace <sbrkmuch+0x19c>
}
    2a2a:	70a2                	ld	ra,40(sp)
    2a2c:	7402                	ld	s0,32(sp)
    2a2e:	64e2                	ld	s1,24(sp)
    2a30:	6942                	ld	s2,16(sp)
    2a32:	69a2                	ld	s3,8(sp)
    2a34:	6a02                	ld	s4,0(sp)
    2a36:	6145                	addi	sp,sp,48
    2a38:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2a3a:	85ce                	mv	a1,s3
    2a3c:	00004517          	auipc	a0,0x4
    2a40:	64c50513          	addi	a0,a0,1612 # 7088 <malloc+0x12b2>
    2a44:	00003097          	auipc	ra,0x3
    2a48:	2d4080e7          	jalr	724(ra) # 5d18 <printf>
    exit(1);
    2a4c:	4505                	li	a0,1
    2a4e:	00003097          	auipc	ra,0x3
    2a52:	f3a080e7          	jalr	-198(ra) # 5988 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2a56:	85ce                	mv	a1,s3
    2a58:	00004517          	auipc	a0,0x4
    2a5c:	67850513          	addi	a0,a0,1656 # 70d0 <malloc+0x12fa>
    2a60:	00003097          	auipc	ra,0x3
    2a64:	2b8080e7          	jalr	696(ra) # 5d18 <printf>
    exit(1);
    2a68:	4505                	li	a0,1
    2a6a:	00003097          	auipc	ra,0x3
    2a6e:	f1e080e7          	jalr	-226(ra) # 5988 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2a72:	86aa                	mv	a3,a0
    2a74:	8626                	mv	a2,s1
    2a76:	85ce                	mv	a1,s3
    2a78:	00004517          	auipc	a0,0x4
    2a7c:	67850513          	addi	a0,a0,1656 # 70f0 <malloc+0x131a>
    2a80:	00003097          	auipc	ra,0x3
    2a84:	298080e7          	jalr	664(ra) # 5d18 <printf>
    exit(1);
    2a88:	4505                	li	a0,1
    2a8a:	00003097          	auipc	ra,0x3
    2a8e:	efe080e7          	jalr	-258(ra) # 5988 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2a92:	86d2                	mv	a3,s4
    2a94:	8626                	mv	a2,s1
    2a96:	85ce                	mv	a1,s3
    2a98:	00004517          	auipc	a0,0x4
    2a9c:	69850513          	addi	a0,a0,1688 # 7130 <malloc+0x135a>
    2aa0:	00003097          	auipc	ra,0x3
    2aa4:	278080e7          	jalr	632(ra) # 5d18 <printf>
    exit(1);
    2aa8:	4505                	li	a0,1
    2aaa:	00003097          	auipc	ra,0x3
    2aae:	ede080e7          	jalr	-290(ra) # 5988 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2ab2:	85ce                	mv	a1,s3
    2ab4:	00004517          	auipc	a0,0x4
    2ab8:	6ac50513          	addi	a0,a0,1708 # 7160 <malloc+0x138a>
    2abc:	00003097          	auipc	ra,0x3
    2ac0:	25c080e7          	jalr	604(ra) # 5d18 <printf>
    exit(1);
    2ac4:	4505                	li	a0,1
    2ac6:	00003097          	auipc	ra,0x3
    2aca:	ec2080e7          	jalr	-318(ra) # 5988 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2ace:	86aa                	mv	a3,a0
    2ad0:	8626                	mv	a2,s1
    2ad2:	85ce                	mv	a1,s3
    2ad4:	00004517          	auipc	a0,0x4
    2ad8:	6c450513          	addi	a0,a0,1732 # 7198 <malloc+0x13c2>
    2adc:	00003097          	auipc	ra,0x3
    2ae0:	23c080e7          	jalr	572(ra) # 5d18 <printf>
    exit(1);
    2ae4:	4505                	li	a0,1
    2ae6:	00003097          	auipc	ra,0x3
    2aea:	ea2080e7          	jalr	-350(ra) # 5988 <exit>

0000000000002aee <sbrkarg>:
{
    2aee:	7179                	addi	sp,sp,-48
    2af0:	f406                	sd	ra,40(sp)
    2af2:	f022                	sd	s0,32(sp)
    2af4:	ec26                	sd	s1,24(sp)
    2af6:	e84a                	sd	s2,16(sp)
    2af8:	e44e                	sd	s3,8(sp)
    2afa:	1800                	addi	s0,sp,48
    2afc:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2afe:	6505                	lui	a0,0x1
    2b00:	00003097          	auipc	ra,0x3
    2b04:	f10080e7          	jalr	-240(ra) # 5a10 <sbrk>
    2b08:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2b0a:	20100593          	li	a1,513
    2b0e:	00004517          	auipc	a0,0x4
    2b12:	6b250513          	addi	a0,a0,1714 # 71c0 <malloc+0x13ea>
    2b16:	00003097          	auipc	ra,0x3
    2b1a:	eb2080e7          	jalr	-334(ra) # 59c8 <open>
    2b1e:	84aa                	mv	s1,a0
  unlink("sbrk");
    2b20:	00004517          	auipc	a0,0x4
    2b24:	6a050513          	addi	a0,a0,1696 # 71c0 <malloc+0x13ea>
    2b28:	00003097          	auipc	ra,0x3
    2b2c:	eb0080e7          	jalr	-336(ra) # 59d8 <unlink>
  if(fd < 0)  {
    2b30:	0404c163          	bltz	s1,2b72 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2b34:	6605                	lui	a2,0x1
    2b36:	85ca                	mv	a1,s2
    2b38:	8526                	mv	a0,s1
    2b3a:	00003097          	auipc	ra,0x3
    2b3e:	e6e080e7          	jalr	-402(ra) # 59a8 <write>
    2b42:	04054663          	bltz	a0,2b8e <sbrkarg+0xa0>
  close(fd);
    2b46:	8526                	mv	a0,s1
    2b48:	00003097          	auipc	ra,0x3
    2b4c:	e68080e7          	jalr	-408(ra) # 59b0 <close>
  a = sbrk(PGSIZE);
    2b50:	6505                	lui	a0,0x1
    2b52:	00003097          	auipc	ra,0x3
    2b56:	ebe080e7          	jalr	-322(ra) # 5a10 <sbrk>
  if(pipe((int *) a) != 0){
    2b5a:	00003097          	auipc	ra,0x3
    2b5e:	e3e080e7          	jalr	-450(ra) # 5998 <pipe>
    2b62:	e521                	bnez	a0,2baa <sbrkarg+0xbc>
}
    2b64:	70a2                	ld	ra,40(sp)
    2b66:	7402                	ld	s0,32(sp)
    2b68:	64e2                	ld	s1,24(sp)
    2b6a:	6942                	ld	s2,16(sp)
    2b6c:	69a2                	ld	s3,8(sp)
    2b6e:	6145                	addi	sp,sp,48
    2b70:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2b72:	85ce                	mv	a1,s3
    2b74:	00004517          	auipc	a0,0x4
    2b78:	65450513          	addi	a0,a0,1620 # 71c8 <malloc+0x13f2>
    2b7c:	00003097          	auipc	ra,0x3
    2b80:	19c080e7          	jalr	412(ra) # 5d18 <printf>
    exit(1);
    2b84:	4505                	li	a0,1
    2b86:	00003097          	auipc	ra,0x3
    2b8a:	e02080e7          	jalr	-510(ra) # 5988 <exit>
    printf("%s: write sbrk failed\n", s);
    2b8e:	85ce                	mv	a1,s3
    2b90:	00004517          	auipc	a0,0x4
    2b94:	65050513          	addi	a0,a0,1616 # 71e0 <malloc+0x140a>
    2b98:	00003097          	auipc	ra,0x3
    2b9c:	180080e7          	jalr	384(ra) # 5d18 <printf>
    exit(1);
    2ba0:	4505                	li	a0,1
    2ba2:	00003097          	auipc	ra,0x3
    2ba6:	de6080e7          	jalr	-538(ra) # 5988 <exit>
    printf("%s: pipe() failed\n", s);
    2baa:	85ce                	mv	a1,s3
    2bac:	00004517          	auipc	a0,0x4
    2bb0:	01c50513          	addi	a0,a0,28 # 6bc8 <malloc+0xdf2>
    2bb4:	00003097          	auipc	ra,0x3
    2bb8:	164080e7          	jalr	356(ra) # 5d18 <printf>
    exit(1);
    2bbc:	4505                	li	a0,1
    2bbe:	00003097          	auipc	ra,0x3
    2bc2:	dca080e7          	jalr	-566(ra) # 5988 <exit>

0000000000002bc6 <argptest>:
{
    2bc6:	1101                	addi	sp,sp,-32
    2bc8:	ec06                	sd	ra,24(sp)
    2bca:	e822                	sd	s0,16(sp)
    2bcc:	e426                	sd	s1,8(sp)
    2bce:	e04a                	sd	s2,0(sp)
    2bd0:	1000                	addi	s0,sp,32
    2bd2:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2bd4:	4581                	li	a1,0
    2bd6:	00004517          	auipc	a0,0x4
    2bda:	62250513          	addi	a0,a0,1570 # 71f8 <malloc+0x1422>
    2bde:	00003097          	auipc	ra,0x3
    2be2:	dea080e7          	jalr	-534(ra) # 59c8 <open>
  if (fd < 0) {
    2be6:	02054b63          	bltz	a0,2c1c <argptest+0x56>
    2bea:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2bec:	4501                	li	a0,0
    2bee:	00003097          	auipc	ra,0x3
    2bf2:	e22080e7          	jalr	-478(ra) # 5a10 <sbrk>
    2bf6:	567d                	li	a2,-1
    2bf8:	fff50593          	addi	a1,a0,-1
    2bfc:	8526                	mv	a0,s1
    2bfe:	00003097          	auipc	ra,0x3
    2c02:	da2080e7          	jalr	-606(ra) # 59a0 <read>
  close(fd);
    2c06:	8526                	mv	a0,s1
    2c08:	00003097          	auipc	ra,0x3
    2c0c:	da8080e7          	jalr	-600(ra) # 59b0 <close>
}
    2c10:	60e2                	ld	ra,24(sp)
    2c12:	6442                	ld	s0,16(sp)
    2c14:	64a2                	ld	s1,8(sp)
    2c16:	6902                	ld	s2,0(sp)
    2c18:	6105                	addi	sp,sp,32
    2c1a:	8082                	ret
    printf("%s: open failed\n", s);
    2c1c:	85ca                	mv	a1,s2
    2c1e:	00004517          	auipc	a0,0x4
    2c22:	eba50513          	addi	a0,a0,-326 # 6ad8 <malloc+0xd02>
    2c26:	00003097          	auipc	ra,0x3
    2c2a:	0f2080e7          	jalr	242(ra) # 5d18 <printf>
    exit(1);
    2c2e:	4505                	li	a0,1
    2c30:	00003097          	auipc	ra,0x3
    2c34:	d58080e7          	jalr	-680(ra) # 5988 <exit>

0000000000002c38 <sbrkbugs>:
{
    2c38:	1141                	addi	sp,sp,-16
    2c3a:	e406                	sd	ra,8(sp)
    2c3c:	e022                	sd	s0,0(sp)
    2c3e:	0800                	addi	s0,sp,16
  int pid = fork();
    2c40:	00003097          	auipc	ra,0x3
    2c44:	d40080e7          	jalr	-704(ra) # 5980 <fork>
  if(pid < 0){
    2c48:	02054263          	bltz	a0,2c6c <sbrkbugs+0x34>
  if(pid == 0){
    2c4c:	ed0d                	bnez	a0,2c86 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2c4e:	00003097          	auipc	ra,0x3
    2c52:	dc2080e7          	jalr	-574(ra) # 5a10 <sbrk>
    sbrk(-sz);
    2c56:	40a0053b          	negw	a0,a0
    2c5a:	00003097          	auipc	ra,0x3
    2c5e:	db6080e7          	jalr	-586(ra) # 5a10 <sbrk>
    exit(0);
    2c62:	4501                	li	a0,0
    2c64:	00003097          	auipc	ra,0x3
    2c68:	d24080e7          	jalr	-732(ra) # 5988 <exit>
    printf("fork failed\n");
    2c6c:	00004517          	auipc	a0,0x4
    2c70:	27450513          	addi	a0,a0,628 # 6ee0 <malloc+0x110a>
    2c74:	00003097          	auipc	ra,0x3
    2c78:	0a4080e7          	jalr	164(ra) # 5d18 <printf>
    exit(1);
    2c7c:	4505                	li	a0,1
    2c7e:	00003097          	auipc	ra,0x3
    2c82:	d0a080e7          	jalr	-758(ra) # 5988 <exit>
  wait(0);
    2c86:	4501                	li	a0,0
    2c88:	00003097          	auipc	ra,0x3
    2c8c:	d08080e7          	jalr	-760(ra) # 5990 <wait>
  pid = fork();
    2c90:	00003097          	auipc	ra,0x3
    2c94:	cf0080e7          	jalr	-784(ra) # 5980 <fork>
  if(pid < 0){
    2c98:	02054563          	bltz	a0,2cc2 <sbrkbugs+0x8a>
  if(pid == 0){
    2c9c:	e121                	bnez	a0,2cdc <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2c9e:	00003097          	auipc	ra,0x3
    2ca2:	d72080e7          	jalr	-654(ra) # 5a10 <sbrk>
    sbrk(-(sz - 3500));
    2ca6:	6785                	lui	a5,0x1
    2ca8:	dac7879b          	addiw	a5,a5,-596
    2cac:	40a7853b          	subw	a0,a5,a0
    2cb0:	00003097          	auipc	ra,0x3
    2cb4:	d60080e7          	jalr	-672(ra) # 5a10 <sbrk>
    exit(0);
    2cb8:	4501                	li	a0,0
    2cba:	00003097          	auipc	ra,0x3
    2cbe:	cce080e7          	jalr	-818(ra) # 5988 <exit>
    printf("fork failed\n");
    2cc2:	00004517          	auipc	a0,0x4
    2cc6:	21e50513          	addi	a0,a0,542 # 6ee0 <malloc+0x110a>
    2cca:	00003097          	auipc	ra,0x3
    2cce:	04e080e7          	jalr	78(ra) # 5d18 <printf>
    exit(1);
    2cd2:	4505                	li	a0,1
    2cd4:	00003097          	auipc	ra,0x3
    2cd8:	cb4080e7          	jalr	-844(ra) # 5988 <exit>
  wait(0);
    2cdc:	4501                	li	a0,0
    2cde:	00003097          	auipc	ra,0x3
    2ce2:	cb2080e7          	jalr	-846(ra) # 5990 <wait>
  pid = fork();
    2ce6:	00003097          	auipc	ra,0x3
    2cea:	c9a080e7          	jalr	-870(ra) # 5980 <fork>
  if(pid < 0){
    2cee:	02054a63          	bltz	a0,2d22 <sbrkbugs+0xea>
  if(pid == 0){
    2cf2:	e529                	bnez	a0,2d3c <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2cf4:	00003097          	auipc	ra,0x3
    2cf8:	d1c080e7          	jalr	-740(ra) # 5a10 <sbrk>
    2cfc:	67ad                	lui	a5,0xb
    2cfe:	8007879b          	addiw	a5,a5,-2048
    2d02:	40a7853b          	subw	a0,a5,a0
    2d06:	00003097          	auipc	ra,0x3
    2d0a:	d0a080e7          	jalr	-758(ra) # 5a10 <sbrk>
    sbrk(-10);
    2d0e:	5559                	li	a0,-10
    2d10:	00003097          	auipc	ra,0x3
    2d14:	d00080e7          	jalr	-768(ra) # 5a10 <sbrk>
    exit(0);
    2d18:	4501                	li	a0,0
    2d1a:	00003097          	auipc	ra,0x3
    2d1e:	c6e080e7          	jalr	-914(ra) # 5988 <exit>
    printf("fork failed\n");
    2d22:	00004517          	auipc	a0,0x4
    2d26:	1be50513          	addi	a0,a0,446 # 6ee0 <malloc+0x110a>
    2d2a:	00003097          	auipc	ra,0x3
    2d2e:	fee080e7          	jalr	-18(ra) # 5d18 <printf>
    exit(1);
    2d32:	4505                	li	a0,1
    2d34:	00003097          	auipc	ra,0x3
    2d38:	c54080e7          	jalr	-940(ra) # 5988 <exit>
  wait(0);
    2d3c:	4501                	li	a0,0
    2d3e:	00003097          	auipc	ra,0x3
    2d42:	c52080e7          	jalr	-942(ra) # 5990 <wait>
  exit(0);
    2d46:	4501                	li	a0,0
    2d48:	00003097          	auipc	ra,0x3
    2d4c:	c40080e7          	jalr	-960(ra) # 5988 <exit>

0000000000002d50 <sbrklast>:
{
    2d50:	7179                	addi	sp,sp,-48
    2d52:	f406                	sd	ra,40(sp)
    2d54:	f022                	sd	s0,32(sp)
    2d56:	ec26                	sd	s1,24(sp)
    2d58:	e84a                	sd	s2,16(sp)
    2d5a:	e44e                	sd	s3,8(sp)
    2d5c:	e052                	sd	s4,0(sp)
    2d5e:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    2d60:	4501                	li	a0,0
    2d62:	00003097          	auipc	ra,0x3
    2d66:	cae080e7          	jalr	-850(ra) # 5a10 <sbrk>
  if((top % 4096) != 0)
    2d6a:	03451793          	slli	a5,a0,0x34
    2d6e:	ebd9                	bnez	a5,2e04 <sbrklast+0xb4>
  sbrk(4096);
    2d70:	6505                	lui	a0,0x1
    2d72:	00003097          	auipc	ra,0x3
    2d76:	c9e080e7          	jalr	-866(ra) # 5a10 <sbrk>
  sbrk(10);
    2d7a:	4529                	li	a0,10
    2d7c:	00003097          	auipc	ra,0x3
    2d80:	c94080e7          	jalr	-876(ra) # 5a10 <sbrk>
  sbrk(-20);
    2d84:	5531                	li	a0,-20
    2d86:	00003097          	auipc	ra,0x3
    2d8a:	c8a080e7          	jalr	-886(ra) # 5a10 <sbrk>
  top = (uint64) sbrk(0);
    2d8e:	4501                	li	a0,0
    2d90:	00003097          	auipc	ra,0x3
    2d94:	c80080e7          	jalr	-896(ra) # 5a10 <sbrk>
    2d98:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2d9a:	fc050913          	addi	s2,a0,-64 # fc0 <linktest+0x164>
  p[0] = 'x';
    2d9e:	07800a13          	li	s4,120
    2da2:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2da6:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2daa:	20200593          	li	a1,514
    2dae:	854a                	mv	a0,s2
    2db0:	00003097          	auipc	ra,0x3
    2db4:	c18080e7          	jalr	-1000(ra) # 59c8 <open>
    2db8:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2dba:	4605                	li	a2,1
    2dbc:	85ca                	mv	a1,s2
    2dbe:	00003097          	auipc	ra,0x3
    2dc2:	bea080e7          	jalr	-1046(ra) # 59a8 <write>
  close(fd);
    2dc6:	854e                	mv	a0,s3
    2dc8:	00003097          	auipc	ra,0x3
    2dcc:	be8080e7          	jalr	-1048(ra) # 59b0 <close>
  fd = open(p, O_RDWR);
    2dd0:	4589                	li	a1,2
    2dd2:	854a                	mv	a0,s2
    2dd4:	00003097          	auipc	ra,0x3
    2dd8:	bf4080e7          	jalr	-1036(ra) # 59c8 <open>
  p[0] = '\0';
    2ddc:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2de0:	4605                	li	a2,1
    2de2:	85ca                	mv	a1,s2
    2de4:	00003097          	auipc	ra,0x3
    2de8:	bbc080e7          	jalr	-1092(ra) # 59a0 <read>
  if(p[0] != 'x')
    2dec:	fc04c783          	lbu	a5,-64(s1)
    2df0:	03479463          	bne	a5,s4,2e18 <sbrklast+0xc8>
}
    2df4:	70a2                	ld	ra,40(sp)
    2df6:	7402                	ld	s0,32(sp)
    2df8:	64e2                	ld	s1,24(sp)
    2dfa:	6942                	ld	s2,16(sp)
    2dfc:	69a2                	ld	s3,8(sp)
    2dfe:	6a02                	ld	s4,0(sp)
    2e00:	6145                	addi	sp,sp,48
    2e02:	8082                	ret
    sbrk(4096 - (top % 4096));
    2e04:	0347d513          	srli	a0,a5,0x34
    2e08:	6785                	lui	a5,0x1
    2e0a:	40a7853b          	subw	a0,a5,a0
    2e0e:	00003097          	auipc	ra,0x3
    2e12:	c02080e7          	jalr	-1022(ra) # 5a10 <sbrk>
    2e16:	bfa9                	j	2d70 <sbrklast+0x20>
    exit(1);
    2e18:	4505                	li	a0,1
    2e1a:	00003097          	auipc	ra,0x3
    2e1e:	b6e080e7          	jalr	-1170(ra) # 5988 <exit>

0000000000002e22 <sbrk8000>:
{
    2e22:	1141                	addi	sp,sp,-16
    2e24:	e406                	sd	ra,8(sp)
    2e26:	e022                	sd	s0,0(sp)
    2e28:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2e2a:	80000537          	lui	a0,0x80000
    2e2e:	0511                	addi	a0,a0,4
    2e30:	00003097          	auipc	ra,0x3
    2e34:	be0080e7          	jalr	-1056(ra) # 5a10 <sbrk>
  volatile char *top = sbrk(0);
    2e38:	4501                	li	a0,0
    2e3a:	00003097          	auipc	ra,0x3
    2e3e:	bd6080e7          	jalr	-1066(ra) # 5a10 <sbrk>
  *(top-1) = *(top-1) + 1;
    2e42:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <__BSS_END__+0xffffffff7fff10cf>
    2e46:	0785                	addi	a5,a5,1
    2e48:	0ff7f793          	andi	a5,a5,255
    2e4c:	fef50fa3          	sb	a5,-1(a0)
}
    2e50:	60a2                	ld	ra,8(sp)
    2e52:	6402                	ld	s0,0(sp)
    2e54:	0141                	addi	sp,sp,16
    2e56:	8082                	ret

0000000000002e58 <execout>:
{
    2e58:	715d                	addi	sp,sp,-80
    2e5a:	e486                	sd	ra,72(sp)
    2e5c:	e0a2                	sd	s0,64(sp)
    2e5e:	fc26                	sd	s1,56(sp)
    2e60:	f84a                	sd	s2,48(sp)
    2e62:	f44e                	sd	s3,40(sp)
    2e64:	f052                	sd	s4,32(sp)
    2e66:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2e68:	4901                	li	s2,0
    2e6a:	49bd                	li	s3,15
    int pid = fork();
    2e6c:	00003097          	auipc	ra,0x3
    2e70:	b14080e7          	jalr	-1260(ra) # 5980 <fork>
    2e74:	84aa                	mv	s1,a0
    if(pid < 0){
    2e76:	02054063          	bltz	a0,2e96 <execout+0x3e>
    } else if(pid == 0){
    2e7a:	c91d                	beqz	a0,2eb0 <execout+0x58>
      wait((int*)0);
    2e7c:	4501                	li	a0,0
    2e7e:	00003097          	auipc	ra,0x3
    2e82:	b12080e7          	jalr	-1262(ra) # 5990 <wait>
  for(int avail = 0; avail < 15; avail++){
    2e86:	2905                	addiw	s2,s2,1
    2e88:	ff3912e3          	bne	s2,s3,2e6c <execout+0x14>
  exit(0);
    2e8c:	4501                	li	a0,0
    2e8e:	00003097          	auipc	ra,0x3
    2e92:	afa080e7          	jalr	-1286(ra) # 5988 <exit>
      printf("fork failed\n");
    2e96:	00004517          	auipc	a0,0x4
    2e9a:	04a50513          	addi	a0,a0,74 # 6ee0 <malloc+0x110a>
    2e9e:	00003097          	auipc	ra,0x3
    2ea2:	e7a080e7          	jalr	-390(ra) # 5d18 <printf>
      exit(1);
    2ea6:	4505                	li	a0,1
    2ea8:	00003097          	auipc	ra,0x3
    2eac:	ae0080e7          	jalr	-1312(ra) # 5988 <exit>
        if(a == 0xffffffffffffffffLL)
    2eb0:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2eb2:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2eb4:	6505                	lui	a0,0x1
    2eb6:	00003097          	auipc	ra,0x3
    2eba:	b5a080e7          	jalr	-1190(ra) # 5a10 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2ebe:	01350763          	beq	a0,s3,2ecc <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2ec2:	6785                	lui	a5,0x1
    2ec4:	953e                	add	a0,a0,a5
    2ec6:	ff450fa3          	sb	s4,-1(a0) # fff <linktest+0x1a3>
      while(1){
    2eca:	b7ed                	j	2eb4 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2ecc:	01205a63          	blez	s2,2ee0 <execout+0x88>
        sbrk(-4096);
    2ed0:	757d                	lui	a0,0xfffff
    2ed2:	00003097          	auipc	ra,0x3
    2ed6:	b3e080e7          	jalr	-1218(ra) # 5a10 <sbrk>
      for(int i = 0; i < avail; i++)
    2eda:	2485                	addiw	s1,s1,1
    2edc:	ff249ae3          	bne	s1,s2,2ed0 <execout+0x78>
      close(1);
    2ee0:	4505                	li	a0,1
    2ee2:	00003097          	auipc	ra,0x3
    2ee6:	ace080e7          	jalr	-1330(ra) # 59b0 <close>
      char *args[] = { "echo", "x", 0 };
    2eea:	00003517          	auipc	a0,0x3
    2eee:	37e50513          	addi	a0,a0,894 # 6268 <malloc+0x492>
    2ef2:	faa43c23          	sd	a0,-72(s0)
    2ef6:	00003797          	auipc	a5,0x3
    2efa:	3e278793          	addi	a5,a5,994 # 62d8 <malloc+0x502>
    2efe:	fcf43023          	sd	a5,-64(s0)
    2f02:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2f06:	fb840593          	addi	a1,s0,-72
    2f0a:	00003097          	auipc	ra,0x3
    2f0e:	ab6080e7          	jalr	-1354(ra) # 59c0 <exec>
      exit(0);
    2f12:	4501                	li	a0,0
    2f14:	00003097          	auipc	ra,0x3
    2f18:	a74080e7          	jalr	-1420(ra) # 5988 <exit>

0000000000002f1c <fourteen>:
{
    2f1c:	1101                	addi	sp,sp,-32
    2f1e:	ec06                	sd	ra,24(sp)
    2f20:	e822                	sd	s0,16(sp)
    2f22:	e426                	sd	s1,8(sp)
    2f24:	1000                	addi	s0,sp,32
    2f26:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2f28:	00004517          	auipc	a0,0x4
    2f2c:	4a850513          	addi	a0,a0,1192 # 73d0 <malloc+0x15fa>
    2f30:	00003097          	auipc	ra,0x3
    2f34:	ac0080e7          	jalr	-1344(ra) # 59f0 <mkdir>
    2f38:	e165                	bnez	a0,3018 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2f3a:	00004517          	auipc	a0,0x4
    2f3e:	2ee50513          	addi	a0,a0,750 # 7228 <malloc+0x1452>
    2f42:	00003097          	auipc	ra,0x3
    2f46:	aae080e7          	jalr	-1362(ra) # 59f0 <mkdir>
    2f4a:	e56d                	bnez	a0,3034 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2f4c:	20000593          	li	a1,512
    2f50:	00004517          	auipc	a0,0x4
    2f54:	33050513          	addi	a0,a0,816 # 7280 <malloc+0x14aa>
    2f58:	00003097          	auipc	ra,0x3
    2f5c:	a70080e7          	jalr	-1424(ra) # 59c8 <open>
  if(fd < 0){
    2f60:	0e054863          	bltz	a0,3050 <fourteen+0x134>
  close(fd);
    2f64:	00003097          	auipc	ra,0x3
    2f68:	a4c080e7          	jalr	-1460(ra) # 59b0 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2f6c:	4581                	li	a1,0
    2f6e:	00004517          	auipc	a0,0x4
    2f72:	38a50513          	addi	a0,a0,906 # 72f8 <malloc+0x1522>
    2f76:	00003097          	auipc	ra,0x3
    2f7a:	a52080e7          	jalr	-1454(ra) # 59c8 <open>
  if(fd < 0){
    2f7e:	0e054763          	bltz	a0,306c <fourteen+0x150>
  close(fd);
    2f82:	00003097          	auipc	ra,0x3
    2f86:	a2e080e7          	jalr	-1490(ra) # 59b0 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2f8a:	00004517          	auipc	a0,0x4
    2f8e:	3de50513          	addi	a0,a0,990 # 7368 <malloc+0x1592>
    2f92:	00003097          	auipc	ra,0x3
    2f96:	a5e080e7          	jalr	-1442(ra) # 59f0 <mkdir>
    2f9a:	c57d                	beqz	a0,3088 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2f9c:	00004517          	auipc	a0,0x4
    2fa0:	42450513          	addi	a0,a0,1060 # 73c0 <malloc+0x15ea>
    2fa4:	00003097          	auipc	ra,0x3
    2fa8:	a4c080e7          	jalr	-1460(ra) # 59f0 <mkdir>
    2fac:	cd65                	beqz	a0,30a4 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2fae:	00004517          	auipc	a0,0x4
    2fb2:	41250513          	addi	a0,a0,1042 # 73c0 <malloc+0x15ea>
    2fb6:	00003097          	auipc	ra,0x3
    2fba:	a22080e7          	jalr	-1502(ra) # 59d8 <unlink>
  unlink("12345678901234/12345678901234");
    2fbe:	00004517          	auipc	a0,0x4
    2fc2:	3aa50513          	addi	a0,a0,938 # 7368 <malloc+0x1592>
    2fc6:	00003097          	auipc	ra,0x3
    2fca:	a12080e7          	jalr	-1518(ra) # 59d8 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2fce:	00004517          	auipc	a0,0x4
    2fd2:	32a50513          	addi	a0,a0,810 # 72f8 <malloc+0x1522>
    2fd6:	00003097          	auipc	ra,0x3
    2fda:	a02080e7          	jalr	-1534(ra) # 59d8 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2fde:	00004517          	auipc	a0,0x4
    2fe2:	2a250513          	addi	a0,a0,674 # 7280 <malloc+0x14aa>
    2fe6:	00003097          	auipc	ra,0x3
    2fea:	9f2080e7          	jalr	-1550(ra) # 59d8 <unlink>
  unlink("12345678901234/123456789012345");
    2fee:	00004517          	auipc	a0,0x4
    2ff2:	23a50513          	addi	a0,a0,570 # 7228 <malloc+0x1452>
    2ff6:	00003097          	auipc	ra,0x3
    2ffa:	9e2080e7          	jalr	-1566(ra) # 59d8 <unlink>
  unlink("12345678901234");
    2ffe:	00004517          	auipc	a0,0x4
    3002:	3d250513          	addi	a0,a0,978 # 73d0 <malloc+0x15fa>
    3006:	00003097          	auipc	ra,0x3
    300a:	9d2080e7          	jalr	-1582(ra) # 59d8 <unlink>
}
    300e:	60e2                	ld	ra,24(sp)
    3010:	6442                	ld	s0,16(sp)
    3012:	64a2                	ld	s1,8(sp)
    3014:	6105                	addi	sp,sp,32
    3016:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    3018:	85a6                	mv	a1,s1
    301a:	00004517          	auipc	a0,0x4
    301e:	1e650513          	addi	a0,a0,486 # 7200 <malloc+0x142a>
    3022:	00003097          	auipc	ra,0x3
    3026:	cf6080e7          	jalr	-778(ra) # 5d18 <printf>
    exit(1);
    302a:	4505                	li	a0,1
    302c:	00003097          	auipc	ra,0x3
    3030:	95c080e7          	jalr	-1700(ra) # 5988 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    3034:	85a6                	mv	a1,s1
    3036:	00004517          	auipc	a0,0x4
    303a:	21250513          	addi	a0,a0,530 # 7248 <malloc+0x1472>
    303e:	00003097          	auipc	ra,0x3
    3042:	cda080e7          	jalr	-806(ra) # 5d18 <printf>
    exit(1);
    3046:	4505                	li	a0,1
    3048:	00003097          	auipc	ra,0x3
    304c:	940080e7          	jalr	-1728(ra) # 5988 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    3050:	85a6                	mv	a1,s1
    3052:	00004517          	auipc	a0,0x4
    3056:	25e50513          	addi	a0,a0,606 # 72b0 <malloc+0x14da>
    305a:	00003097          	auipc	ra,0x3
    305e:	cbe080e7          	jalr	-834(ra) # 5d18 <printf>
    exit(1);
    3062:	4505                	li	a0,1
    3064:	00003097          	auipc	ra,0x3
    3068:	924080e7          	jalr	-1756(ra) # 5988 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    306c:	85a6                	mv	a1,s1
    306e:	00004517          	auipc	a0,0x4
    3072:	2ba50513          	addi	a0,a0,698 # 7328 <malloc+0x1552>
    3076:	00003097          	auipc	ra,0x3
    307a:	ca2080e7          	jalr	-862(ra) # 5d18 <printf>
    exit(1);
    307e:	4505                	li	a0,1
    3080:	00003097          	auipc	ra,0x3
    3084:	908080e7          	jalr	-1784(ra) # 5988 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    3088:	85a6                	mv	a1,s1
    308a:	00004517          	auipc	a0,0x4
    308e:	2fe50513          	addi	a0,a0,766 # 7388 <malloc+0x15b2>
    3092:	00003097          	auipc	ra,0x3
    3096:	c86080e7          	jalr	-890(ra) # 5d18 <printf>
    exit(1);
    309a:	4505                	li	a0,1
    309c:	00003097          	auipc	ra,0x3
    30a0:	8ec080e7          	jalr	-1812(ra) # 5988 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    30a4:	85a6                	mv	a1,s1
    30a6:	00004517          	auipc	a0,0x4
    30aa:	33a50513          	addi	a0,a0,826 # 73e0 <malloc+0x160a>
    30ae:	00003097          	auipc	ra,0x3
    30b2:	c6a080e7          	jalr	-918(ra) # 5d18 <printf>
    exit(1);
    30b6:	4505                	li	a0,1
    30b8:	00003097          	auipc	ra,0x3
    30bc:	8d0080e7          	jalr	-1840(ra) # 5988 <exit>

00000000000030c0 <iputtest>:
{
    30c0:	1101                	addi	sp,sp,-32
    30c2:	ec06                	sd	ra,24(sp)
    30c4:	e822                	sd	s0,16(sp)
    30c6:	e426                	sd	s1,8(sp)
    30c8:	1000                	addi	s0,sp,32
    30ca:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    30cc:	00004517          	auipc	a0,0x4
    30d0:	34c50513          	addi	a0,a0,844 # 7418 <malloc+0x1642>
    30d4:	00003097          	auipc	ra,0x3
    30d8:	91c080e7          	jalr	-1764(ra) # 59f0 <mkdir>
    30dc:	04054563          	bltz	a0,3126 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    30e0:	00004517          	auipc	a0,0x4
    30e4:	33850513          	addi	a0,a0,824 # 7418 <malloc+0x1642>
    30e8:	00003097          	auipc	ra,0x3
    30ec:	910080e7          	jalr	-1776(ra) # 59f8 <chdir>
    30f0:	04054963          	bltz	a0,3142 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    30f4:	00004517          	auipc	a0,0x4
    30f8:	36450513          	addi	a0,a0,868 # 7458 <malloc+0x1682>
    30fc:	00003097          	auipc	ra,0x3
    3100:	8dc080e7          	jalr	-1828(ra) # 59d8 <unlink>
    3104:	04054d63          	bltz	a0,315e <iputtest+0x9e>
  if(chdir("/") < 0){
    3108:	00004517          	auipc	a0,0x4
    310c:	38050513          	addi	a0,a0,896 # 7488 <malloc+0x16b2>
    3110:	00003097          	auipc	ra,0x3
    3114:	8e8080e7          	jalr	-1816(ra) # 59f8 <chdir>
    3118:	06054163          	bltz	a0,317a <iputtest+0xba>
}
    311c:	60e2                	ld	ra,24(sp)
    311e:	6442                	ld	s0,16(sp)
    3120:	64a2                	ld	s1,8(sp)
    3122:	6105                	addi	sp,sp,32
    3124:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3126:	85a6                	mv	a1,s1
    3128:	00004517          	auipc	a0,0x4
    312c:	2f850513          	addi	a0,a0,760 # 7420 <malloc+0x164a>
    3130:	00003097          	auipc	ra,0x3
    3134:	be8080e7          	jalr	-1048(ra) # 5d18 <printf>
    exit(1);
    3138:	4505                	li	a0,1
    313a:	00003097          	auipc	ra,0x3
    313e:	84e080e7          	jalr	-1970(ra) # 5988 <exit>
    printf("%s: chdir iputdir failed\n", s);
    3142:	85a6                	mv	a1,s1
    3144:	00004517          	auipc	a0,0x4
    3148:	2f450513          	addi	a0,a0,756 # 7438 <malloc+0x1662>
    314c:	00003097          	auipc	ra,0x3
    3150:	bcc080e7          	jalr	-1076(ra) # 5d18 <printf>
    exit(1);
    3154:	4505                	li	a0,1
    3156:	00003097          	auipc	ra,0x3
    315a:	832080e7          	jalr	-1998(ra) # 5988 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    315e:	85a6                	mv	a1,s1
    3160:	00004517          	auipc	a0,0x4
    3164:	30850513          	addi	a0,a0,776 # 7468 <malloc+0x1692>
    3168:	00003097          	auipc	ra,0x3
    316c:	bb0080e7          	jalr	-1104(ra) # 5d18 <printf>
    exit(1);
    3170:	4505                	li	a0,1
    3172:	00003097          	auipc	ra,0x3
    3176:	816080e7          	jalr	-2026(ra) # 5988 <exit>
    printf("%s: chdir / failed\n", s);
    317a:	85a6                	mv	a1,s1
    317c:	00004517          	auipc	a0,0x4
    3180:	31450513          	addi	a0,a0,788 # 7490 <malloc+0x16ba>
    3184:	00003097          	auipc	ra,0x3
    3188:	b94080e7          	jalr	-1132(ra) # 5d18 <printf>
    exit(1);
    318c:	4505                	li	a0,1
    318e:	00002097          	auipc	ra,0x2
    3192:	7fa080e7          	jalr	2042(ra) # 5988 <exit>

0000000000003196 <exitiputtest>:
{
    3196:	7179                	addi	sp,sp,-48
    3198:	f406                	sd	ra,40(sp)
    319a:	f022                	sd	s0,32(sp)
    319c:	ec26                	sd	s1,24(sp)
    319e:	1800                	addi	s0,sp,48
    31a0:	84aa                	mv	s1,a0
  pid = fork();
    31a2:	00002097          	auipc	ra,0x2
    31a6:	7de080e7          	jalr	2014(ra) # 5980 <fork>
  if(pid < 0){
    31aa:	04054663          	bltz	a0,31f6 <exitiputtest+0x60>
  if(pid == 0){
    31ae:	ed45                	bnez	a0,3266 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    31b0:	00004517          	auipc	a0,0x4
    31b4:	26850513          	addi	a0,a0,616 # 7418 <malloc+0x1642>
    31b8:	00003097          	auipc	ra,0x3
    31bc:	838080e7          	jalr	-1992(ra) # 59f0 <mkdir>
    31c0:	04054963          	bltz	a0,3212 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    31c4:	00004517          	auipc	a0,0x4
    31c8:	25450513          	addi	a0,a0,596 # 7418 <malloc+0x1642>
    31cc:	00003097          	auipc	ra,0x3
    31d0:	82c080e7          	jalr	-2004(ra) # 59f8 <chdir>
    31d4:	04054d63          	bltz	a0,322e <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    31d8:	00004517          	auipc	a0,0x4
    31dc:	28050513          	addi	a0,a0,640 # 7458 <malloc+0x1682>
    31e0:	00002097          	auipc	ra,0x2
    31e4:	7f8080e7          	jalr	2040(ra) # 59d8 <unlink>
    31e8:	06054163          	bltz	a0,324a <exitiputtest+0xb4>
    exit(0);
    31ec:	4501                	li	a0,0
    31ee:	00002097          	auipc	ra,0x2
    31f2:	79a080e7          	jalr	1946(ra) # 5988 <exit>
    printf("%s: fork failed\n", s);
    31f6:	85a6                	mv	a1,s1
    31f8:	00004517          	auipc	a0,0x4
    31fc:	8c850513          	addi	a0,a0,-1848 # 6ac0 <malloc+0xcea>
    3200:	00003097          	auipc	ra,0x3
    3204:	b18080e7          	jalr	-1256(ra) # 5d18 <printf>
    exit(1);
    3208:	4505                	li	a0,1
    320a:	00002097          	auipc	ra,0x2
    320e:	77e080e7          	jalr	1918(ra) # 5988 <exit>
      printf("%s: mkdir failed\n", s);
    3212:	85a6                	mv	a1,s1
    3214:	00004517          	auipc	a0,0x4
    3218:	20c50513          	addi	a0,a0,524 # 7420 <malloc+0x164a>
    321c:	00003097          	auipc	ra,0x3
    3220:	afc080e7          	jalr	-1284(ra) # 5d18 <printf>
      exit(1);
    3224:	4505                	li	a0,1
    3226:	00002097          	auipc	ra,0x2
    322a:	762080e7          	jalr	1890(ra) # 5988 <exit>
      printf("%s: child chdir failed\n", s);
    322e:	85a6                	mv	a1,s1
    3230:	00004517          	auipc	a0,0x4
    3234:	27850513          	addi	a0,a0,632 # 74a8 <malloc+0x16d2>
    3238:	00003097          	auipc	ra,0x3
    323c:	ae0080e7          	jalr	-1312(ra) # 5d18 <printf>
      exit(1);
    3240:	4505                	li	a0,1
    3242:	00002097          	auipc	ra,0x2
    3246:	746080e7          	jalr	1862(ra) # 5988 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    324a:	85a6                	mv	a1,s1
    324c:	00004517          	auipc	a0,0x4
    3250:	21c50513          	addi	a0,a0,540 # 7468 <malloc+0x1692>
    3254:	00003097          	auipc	ra,0x3
    3258:	ac4080e7          	jalr	-1340(ra) # 5d18 <printf>
      exit(1);
    325c:	4505                	li	a0,1
    325e:	00002097          	auipc	ra,0x2
    3262:	72a080e7          	jalr	1834(ra) # 5988 <exit>
  wait(&xstatus);
    3266:	fdc40513          	addi	a0,s0,-36
    326a:	00002097          	auipc	ra,0x2
    326e:	726080e7          	jalr	1830(ra) # 5990 <wait>
  exit(xstatus);
    3272:	fdc42503          	lw	a0,-36(s0)
    3276:	00002097          	auipc	ra,0x2
    327a:	712080e7          	jalr	1810(ra) # 5988 <exit>

000000000000327e <dirtest>:
{
    327e:	1101                	addi	sp,sp,-32
    3280:	ec06                	sd	ra,24(sp)
    3282:	e822                	sd	s0,16(sp)
    3284:	e426                	sd	s1,8(sp)
    3286:	1000                	addi	s0,sp,32
    3288:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    328a:	00004517          	auipc	a0,0x4
    328e:	23650513          	addi	a0,a0,566 # 74c0 <malloc+0x16ea>
    3292:	00002097          	auipc	ra,0x2
    3296:	75e080e7          	jalr	1886(ra) # 59f0 <mkdir>
    329a:	04054563          	bltz	a0,32e4 <dirtest+0x66>
  if(chdir("dir0") < 0){
    329e:	00004517          	auipc	a0,0x4
    32a2:	22250513          	addi	a0,a0,546 # 74c0 <malloc+0x16ea>
    32a6:	00002097          	auipc	ra,0x2
    32aa:	752080e7          	jalr	1874(ra) # 59f8 <chdir>
    32ae:	04054963          	bltz	a0,3300 <dirtest+0x82>
  if(chdir("..") < 0){
    32b2:	00004517          	auipc	a0,0x4
    32b6:	22e50513          	addi	a0,a0,558 # 74e0 <malloc+0x170a>
    32ba:	00002097          	auipc	ra,0x2
    32be:	73e080e7          	jalr	1854(ra) # 59f8 <chdir>
    32c2:	04054d63          	bltz	a0,331c <dirtest+0x9e>
  if(unlink("dir0") < 0){
    32c6:	00004517          	auipc	a0,0x4
    32ca:	1fa50513          	addi	a0,a0,506 # 74c0 <malloc+0x16ea>
    32ce:	00002097          	auipc	ra,0x2
    32d2:	70a080e7          	jalr	1802(ra) # 59d8 <unlink>
    32d6:	06054163          	bltz	a0,3338 <dirtest+0xba>
}
    32da:	60e2                	ld	ra,24(sp)
    32dc:	6442                	ld	s0,16(sp)
    32de:	64a2                	ld	s1,8(sp)
    32e0:	6105                	addi	sp,sp,32
    32e2:	8082                	ret
    printf("%s: mkdir failed\n", s);
    32e4:	85a6                	mv	a1,s1
    32e6:	00004517          	auipc	a0,0x4
    32ea:	13a50513          	addi	a0,a0,314 # 7420 <malloc+0x164a>
    32ee:	00003097          	auipc	ra,0x3
    32f2:	a2a080e7          	jalr	-1494(ra) # 5d18 <printf>
    exit(1);
    32f6:	4505                	li	a0,1
    32f8:	00002097          	auipc	ra,0x2
    32fc:	690080e7          	jalr	1680(ra) # 5988 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3300:	85a6                	mv	a1,s1
    3302:	00004517          	auipc	a0,0x4
    3306:	1c650513          	addi	a0,a0,454 # 74c8 <malloc+0x16f2>
    330a:	00003097          	auipc	ra,0x3
    330e:	a0e080e7          	jalr	-1522(ra) # 5d18 <printf>
    exit(1);
    3312:	4505                	li	a0,1
    3314:	00002097          	auipc	ra,0x2
    3318:	674080e7          	jalr	1652(ra) # 5988 <exit>
    printf("%s: chdir .. failed\n", s);
    331c:	85a6                	mv	a1,s1
    331e:	00004517          	auipc	a0,0x4
    3322:	1ca50513          	addi	a0,a0,458 # 74e8 <malloc+0x1712>
    3326:	00003097          	auipc	ra,0x3
    332a:	9f2080e7          	jalr	-1550(ra) # 5d18 <printf>
    exit(1);
    332e:	4505                	li	a0,1
    3330:	00002097          	auipc	ra,0x2
    3334:	658080e7          	jalr	1624(ra) # 5988 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3338:	85a6                	mv	a1,s1
    333a:	00004517          	auipc	a0,0x4
    333e:	1c650513          	addi	a0,a0,454 # 7500 <malloc+0x172a>
    3342:	00003097          	auipc	ra,0x3
    3346:	9d6080e7          	jalr	-1578(ra) # 5d18 <printf>
    exit(1);
    334a:	4505                	li	a0,1
    334c:	00002097          	auipc	ra,0x2
    3350:	63c080e7          	jalr	1596(ra) # 5988 <exit>

0000000000003354 <subdir>:
{
    3354:	1101                	addi	sp,sp,-32
    3356:	ec06                	sd	ra,24(sp)
    3358:	e822                	sd	s0,16(sp)
    335a:	e426                	sd	s1,8(sp)
    335c:	e04a                	sd	s2,0(sp)
    335e:	1000                	addi	s0,sp,32
    3360:	892a                	mv	s2,a0
  unlink("ff");
    3362:	00004517          	auipc	a0,0x4
    3366:	2e650513          	addi	a0,a0,742 # 7648 <malloc+0x1872>
    336a:	00002097          	auipc	ra,0x2
    336e:	66e080e7          	jalr	1646(ra) # 59d8 <unlink>
  if(mkdir("dd") != 0){
    3372:	00004517          	auipc	a0,0x4
    3376:	1a650513          	addi	a0,a0,422 # 7518 <malloc+0x1742>
    337a:	00002097          	auipc	ra,0x2
    337e:	676080e7          	jalr	1654(ra) # 59f0 <mkdir>
    3382:	38051663          	bnez	a0,370e <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    3386:	20200593          	li	a1,514
    338a:	00004517          	auipc	a0,0x4
    338e:	1ae50513          	addi	a0,a0,430 # 7538 <malloc+0x1762>
    3392:	00002097          	auipc	ra,0x2
    3396:	636080e7          	jalr	1590(ra) # 59c8 <open>
    339a:	84aa                	mv	s1,a0
  if(fd < 0){
    339c:	38054763          	bltz	a0,372a <subdir+0x3d6>
  write(fd, "ff", 2);
    33a0:	4609                	li	a2,2
    33a2:	00004597          	auipc	a1,0x4
    33a6:	2a658593          	addi	a1,a1,678 # 7648 <malloc+0x1872>
    33aa:	00002097          	auipc	ra,0x2
    33ae:	5fe080e7          	jalr	1534(ra) # 59a8 <write>
  close(fd);
    33b2:	8526                	mv	a0,s1
    33b4:	00002097          	auipc	ra,0x2
    33b8:	5fc080e7          	jalr	1532(ra) # 59b0 <close>
  if(unlink("dd") >= 0){
    33bc:	00004517          	auipc	a0,0x4
    33c0:	15c50513          	addi	a0,a0,348 # 7518 <malloc+0x1742>
    33c4:	00002097          	auipc	ra,0x2
    33c8:	614080e7          	jalr	1556(ra) # 59d8 <unlink>
    33cc:	36055d63          	bgez	a0,3746 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    33d0:	00004517          	auipc	a0,0x4
    33d4:	1c050513          	addi	a0,a0,448 # 7590 <malloc+0x17ba>
    33d8:	00002097          	auipc	ra,0x2
    33dc:	618080e7          	jalr	1560(ra) # 59f0 <mkdir>
    33e0:	38051163          	bnez	a0,3762 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    33e4:	20200593          	li	a1,514
    33e8:	00004517          	auipc	a0,0x4
    33ec:	1d050513          	addi	a0,a0,464 # 75b8 <malloc+0x17e2>
    33f0:	00002097          	auipc	ra,0x2
    33f4:	5d8080e7          	jalr	1496(ra) # 59c8 <open>
    33f8:	84aa                	mv	s1,a0
  if(fd < 0){
    33fa:	38054263          	bltz	a0,377e <subdir+0x42a>
  write(fd, "FF", 2);
    33fe:	4609                	li	a2,2
    3400:	00004597          	auipc	a1,0x4
    3404:	1e858593          	addi	a1,a1,488 # 75e8 <malloc+0x1812>
    3408:	00002097          	auipc	ra,0x2
    340c:	5a0080e7          	jalr	1440(ra) # 59a8 <write>
  close(fd);
    3410:	8526                	mv	a0,s1
    3412:	00002097          	auipc	ra,0x2
    3416:	59e080e7          	jalr	1438(ra) # 59b0 <close>
  fd = open("dd/dd/../ff", 0);
    341a:	4581                	li	a1,0
    341c:	00004517          	auipc	a0,0x4
    3420:	1d450513          	addi	a0,a0,468 # 75f0 <malloc+0x181a>
    3424:	00002097          	auipc	ra,0x2
    3428:	5a4080e7          	jalr	1444(ra) # 59c8 <open>
    342c:	84aa                	mv	s1,a0
  if(fd < 0){
    342e:	36054663          	bltz	a0,379a <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3432:	660d                	lui	a2,0x3
    3434:	00009597          	auipc	a1,0x9
    3438:	aec58593          	addi	a1,a1,-1300 # bf20 <buf>
    343c:	00002097          	auipc	ra,0x2
    3440:	564080e7          	jalr	1380(ra) # 59a0 <read>
  if(cc != 2 || buf[0] != 'f'){
    3444:	4789                	li	a5,2
    3446:	36f51863          	bne	a0,a5,37b6 <subdir+0x462>
    344a:	00009717          	auipc	a4,0x9
    344e:	ad674703          	lbu	a4,-1322(a4) # bf20 <buf>
    3452:	06600793          	li	a5,102
    3456:	36f71063          	bne	a4,a5,37b6 <subdir+0x462>
  close(fd);
    345a:	8526                	mv	a0,s1
    345c:	00002097          	auipc	ra,0x2
    3460:	554080e7          	jalr	1364(ra) # 59b0 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3464:	00004597          	auipc	a1,0x4
    3468:	1dc58593          	addi	a1,a1,476 # 7640 <malloc+0x186a>
    346c:	00004517          	auipc	a0,0x4
    3470:	14c50513          	addi	a0,a0,332 # 75b8 <malloc+0x17e2>
    3474:	00002097          	auipc	ra,0x2
    3478:	574080e7          	jalr	1396(ra) # 59e8 <link>
    347c:	34051b63          	bnez	a0,37d2 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    3480:	00004517          	auipc	a0,0x4
    3484:	13850513          	addi	a0,a0,312 # 75b8 <malloc+0x17e2>
    3488:	00002097          	auipc	ra,0x2
    348c:	550080e7          	jalr	1360(ra) # 59d8 <unlink>
    3490:	34051f63          	bnez	a0,37ee <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3494:	4581                	li	a1,0
    3496:	00004517          	auipc	a0,0x4
    349a:	12250513          	addi	a0,a0,290 # 75b8 <malloc+0x17e2>
    349e:	00002097          	auipc	ra,0x2
    34a2:	52a080e7          	jalr	1322(ra) # 59c8 <open>
    34a6:	36055263          	bgez	a0,380a <subdir+0x4b6>
  if(chdir("dd") != 0){
    34aa:	00004517          	auipc	a0,0x4
    34ae:	06e50513          	addi	a0,a0,110 # 7518 <malloc+0x1742>
    34b2:	00002097          	auipc	ra,0x2
    34b6:	546080e7          	jalr	1350(ra) # 59f8 <chdir>
    34ba:	36051663          	bnez	a0,3826 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    34be:	00004517          	auipc	a0,0x4
    34c2:	21a50513          	addi	a0,a0,538 # 76d8 <malloc+0x1902>
    34c6:	00002097          	auipc	ra,0x2
    34ca:	532080e7          	jalr	1330(ra) # 59f8 <chdir>
    34ce:	36051a63          	bnez	a0,3842 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    34d2:	00004517          	auipc	a0,0x4
    34d6:	23650513          	addi	a0,a0,566 # 7708 <malloc+0x1932>
    34da:	00002097          	auipc	ra,0x2
    34de:	51e080e7          	jalr	1310(ra) # 59f8 <chdir>
    34e2:	36051e63          	bnez	a0,385e <subdir+0x50a>
  if(chdir("./..") != 0){
    34e6:	00004517          	auipc	a0,0x4
    34ea:	25250513          	addi	a0,a0,594 # 7738 <malloc+0x1962>
    34ee:	00002097          	auipc	ra,0x2
    34f2:	50a080e7          	jalr	1290(ra) # 59f8 <chdir>
    34f6:	38051263          	bnez	a0,387a <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    34fa:	4581                	li	a1,0
    34fc:	00004517          	auipc	a0,0x4
    3500:	14450513          	addi	a0,a0,324 # 7640 <malloc+0x186a>
    3504:	00002097          	auipc	ra,0x2
    3508:	4c4080e7          	jalr	1220(ra) # 59c8 <open>
    350c:	84aa                	mv	s1,a0
  if(fd < 0){
    350e:	38054463          	bltz	a0,3896 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3512:	660d                	lui	a2,0x3
    3514:	00009597          	auipc	a1,0x9
    3518:	a0c58593          	addi	a1,a1,-1524 # bf20 <buf>
    351c:	00002097          	auipc	ra,0x2
    3520:	484080e7          	jalr	1156(ra) # 59a0 <read>
    3524:	4789                	li	a5,2
    3526:	38f51663          	bne	a0,a5,38b2 <subdir+0x55e>
  close(fd);
    352a:	8526                	mv	a0,s1
    352c:	00002097          	auipc	ra,0x2
    3530:	484080e7          	jalr	1156(ra) # 59b0 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3534:	4581                	li	a1,0
    3536:	00004517          	auipc	a0,0x4
    353a:	08250513          	addi	a0,a0,130 # 75b8 <malloc+0x17e2>
    353e:	00002097          	auipc	ra,0x2
    3542:	48a080e7          	jalr	1162(ra) # 59c8 <open>
    3546:	38055463          	bgez	a0,38ce <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    354a:	20200593          	li	a1,514
    354e:	00004517          	auipc	a0,0x4
    3552:	27a50513          	addi	a0,a0,634 # 77c8 <malloc+0x19f2>
    3556:	00002097          	auipc	ra,0x2
    355a:	472080e7          	jalr	1138(ra) # 59c8 <open>
    355e:	38055663          	bgez	a0,38ea <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3562:	20200593          	li	a1,514
    3566:	00004517          	auipc	a0,0x4
    356a:	29250513          	addi	a0,a0,658 # 77f8 <malloc+0x1a22>
    356e:	00002097          	auipc	ra,0x2
    3572:	45a080e7          	jalr	1114(ra) # 59c8 <open>
    3576:	38055863          	bgez	a0,3906 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    357a:	20000593          	li	a1,512
    357e:	00004517          	auipc	a0,0x4
    3582:	f9a50513          	addi	a0,a0,-102 # 7518 <malloc+0x1742>
    3586:	00002097          	auipc	ra,0x2
    358a:	442080e7          	jalr	1090(ra) # 59c8 <open>
    358e:	38055a63          	bgez	a0,3922 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3592:	4589                	li	a1,2
    3594:	00004517          	auipc	a0,0x4
    3598:	f8450513          	addi	a0,a0,-124 # 7518 <malloc+0x1742>
    359c:	00002097          	auipc	ra,0x2
    35a0:	42c080e7          	jalr	1068(ra) # 59c8 <open>
    35a4:	38055d63          	bgez	a0,393e <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    35a8:	4585                	li	a1,1
    35aa:	00004517          	auipc	a0,0x4
    35ae:	f6e50513          	addi	a0,a0,-146 # 7518 <malloc+0x1742>
    35b2:	00002097          	auipc	ra,0x2
    35b6:	416080e7          	jalr	1046(ra) # 59c8 <open>
    35ba:	3a055063          	bgez	a0,395a <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    35be:	00004597          	auipc	a1,0x4
    35c2:	2ca58593          	addi	a1,a1,714 # 7888 <malloc+0x1ab2>
    35c6:	00004517          	auipc	a0,0x4
    35ca:	20250513          	addi	a0,a0,514 # 77c8 <malloc+0x19f2>
    35ce:	00002097          	auipc	ra,0x2
    35d2:	41a080e7          	jalr	1050(ra) # 59e8 <link>
    35d6:	3a050063          	beqz	a0,3976 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    35da:	00004597          	auipc	a1,0x4
    35de:	2ae58593          	addi	a1,a1,686 # 7888 <malloc+0x1ab2>
    35e2:	00004517          	auipc	a0,0x4
    35e6:	21650513          	addi	a0,a0,534 # 77f8 <malloc+0x1a22>
    35ea:	00002097          	auipc	ra,0x2
    35ee:	3fe080e7          	jalr	1022(ra) # 59e8 <link>
    35f2:	3a050063          	beqz	a0,3992 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    35f6:	00004597          	auipc	a1,0x4
    35fa:	04a58593          	addi	a1,a1,74 # 7640 <malloc+0x186a>
    35fe:	00004517          	auipc	a0,0x4
    3602:	f3a50513          	addi	a0,a0,-198 # 7538 <malloc+0x1762>
    3606:	00002097          	auipc	ra,0x2
    360a:	3e2080e7          	jalr	994(ra) # 59e8 <link>
    360e:	3a050063          	beqz	a0,39ae <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3612:	00004517          	auipc	a0,0x4
    3616:	1b650513          	addi	a0,a0,438 # 77c8 <malloc+0x19f2>
    361a:	00002097          	auipc	ra,0x2
    361e:	3d6080e7          	jalr	982(ra) # 59f0 <mkdir>
    3622:	3a050463          	beqz	a0,39ca <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3626:	00004517          	auipc	a0,0x4
    362a:	1d250513          	addi	a0,a0,466 # 77f8 <malloc+0x1a22>
    362e:	00002097          	auipc	ra,0x2
    3632:	3c2080e7          	jalr	962(ra) # 59f0 <mkdir>
    3636:	3a050863          	beqz	a0,39e6 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    363a:	00004517          	auipc	a0,0x4
    363e:	00650513          	addi	a0,a0,6 # 7640 <malloc+0x186a>
    3642:	00002097          	auipc	ra,0x2
    3646:	3ae080e7          	jalr	942(ra) # 59f0 <mkdir>
    364a:	3a050c63          	beqz	a0,3a02 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    364e:	00004517          	auipc	a0,0x4
    3652:	1aa50513          	addi	a0,a0,426 # 77f8 <malloc+0x1a22>
    3656:	00002097          	auipc	ra,0x2
    365a:	382080e7          	jalr	898(ra) # 59d8 <unlink>
    365e:	3c050063          	beqz	a0,3a1e <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3662:	00004517          	auipc	a0,0x4
    3666:	16650513          	addi	a0,a0,358 # 77c8 <malloc+0x19f2>
    366a:	00002097          	auipc	ra,0x2
    366e:	36e080e7          	jalr	878(ra) # 59d8 <unlink>
    3672:	3c050463          	beqz	a0,3a3a <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3676:	00004517          	auipc	a0,0x4
    367a:	ec250513          	addi	a0,a0,-318 # 7538 <malloc+0x1762>
    367e:	00002097          	auipc	ra,0x2
    3682:	37a080e7          	jalr	890(ra) # 59f8 <chdir>
    3686:	3c050863          	beqz	a0,3a56 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    368a:	00004517          	auipc	a0,0x4
    368e:	34e50513          	addi	a0,a0,846 # 79d8 <malloc+0x1c02>
    3692:	00002097          	auipc	ra,0x2
    3696:	366080e7          	jalr	870(ra) # 59f8 <chdir>
    369a:	3c050c63          	beqz	a0,3a72 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    369e:	00004517          	auipc	a0,0x4
    36a2:	fa250513          	addi	a0,a0,-94 # 7640 <malloc+0x186a>
    36a6:	00002097          	auipc	ra,0x2
    36aa:	332080e7          	jalr	818(ra) # 59d8 <unlink>
    36ae:	3e051063          	bnez	a0,3a8e <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    36b2:	00004517          	auipc	a0,0x4
    36b6:	e8650513          	addi	a0,a0,-378 # 7538 <malloc+0x1762>
    36ba:	00002097          	auipc	ra,0x2
    36be:	31e080e7          	jalr	798(ra) # 59d8 <unlink>
    36c2:	3e051463          	bnez	a0,3aaa <subdir+0x756>
  if(unlink("dd") == 0){
    36c6:	00004517          	auipc	a0,0x4
    36ca:	e5250513          	addi	a0,a0,-430 # 7518 <malloc+0x1742>
    36ce:	00002097          	auipc	ra,0x2
    36d2:	30a080e7          	jalr	778(ra) # 59d8 <unlink>
    36d6:	3e050863          	beqz	a0,3ac6 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    36da:	00004517          	auipc	a0,0x4
    36de:	36e50513          	addi	a0,a0,878 # 7a48 <malloc+0x1c72>
    36e2:	00002097          	auipc	ra,0x2
    36e6:	2f6080e7          	jalr	758(ra) # 59d8 <unlink>
    36ea:	3e054c63          	bltz	a0,3ae2 <subdir+0x78e>
  if(unlink("dd") < 0){
    36ee:	00004517          	auipc	a0,0x4
    36f2:	e2a50513          	addi	a0,a0,-470 # 7518 <malloc+0x1742>
    36f6:	00002097          	auipc	ra,0x2
    36fa:	2e2080e7          	jalr	738(ra) # 59d8 <unlink>
    36fe:	40054063          	bltz	a0,3afe <subdir+0x7aa>
}
    3702:	60e2                	ld	ra,24(sp)
    3704:	6442                	ld	s0,16(sp)
    3706:	64a2                	ld	s1,8(sp)
    3708:	6902                	ld	s2,0(sp)
    370a:	6105                	addi	sp,sp,32
    370c:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    370e:	85ca                	mv	a1,s2
    3710:	00004517          	auipc	a0,0x4
    3714:	e1050513          	addi	a0,a0,-496 # 7520 <malloc+0x174a>
    3718:	00002097          	auipc	ra,0x2
    371c:	600080e7          	jalr	1536(ra) # 5d18 <printf>
    exit(1);
    3720:	4505                	li	a0,1
    3722:	00002097          	auipc	ra,0x2
    3726:	266080e7          	jalr	614(ra) # 5988 <exit>
    printf("%s: create dd/ff failed\n", s);
    372a:	85ca                	mv	a1,s2
    372c:	00004517          	auipc	a0,0x4
    3730:	e1450513          	addi	a0,a0,-492 # 7540 <malloc+0x176a>
    3734:	00002097          	auipc	ra,0x2
    3738:	5e4080e7          	jalr	1508(ra) # 5d18 <printf>
    exit(1);
    373c:	4505                	li	a0,1
    373e:	00002097          	auipc	ra,0x2
    3742:	24a080e7          	jalr	586(ra) # 5988 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3746:	85ca                	mv	a1,s2
    3748:	00004517          	auipc	a0,0x4
    374c:	e1850513          	addi	a0,a0,-488 # 7560 <malloc+0x178a>
    3750:	00002097          	auipc	ra,0x2
    3754:	5c8080e7          	jalr	1480(ra) # 5d18 <printf>
    exit(1);
    3758:	4505                	li	a0,1
    375a:	00002097          	auipc	ra,0x2
    375e:	22e080e7          	jalr	558(ra) # 5988 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3762:	85ca                	mv	a1,s2
    3764:	00004517          	auipc	a0,0x4
    3768:	e3450513          	addi	a0,a0,-460 # 7598 <malloc+0x17c2>
    376c:	00002097          	auipc	ra,0x2
    3770:	5ac080e7          	jalr	1452(ra) # 5d18 <printf>
    exit(1);
    3774:	4505                	li	a0,1
    3776:	00002097          	auipc	ra,0x2
    377a:	212080e7          	jalr	530(ra) # 5988 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    377e:	85ca                	mv	a1,s2
    3780:	00004517          	auipc	a0,0x4
    3784:	e4850513          	addi	a0,a0,-440 # 75c8 <malloc+0x17f2>
    3788:	00002097          	auipc	ra,0x2
    378c:	590080e7          	jalr	1424(ra) # 5d18 <printf>
    exit(1);
    3790:	4505                	li	a0,1
    3792:	00002097          	auipc	ra,0x2
    3796:	1f6080e7          	jalr	502(ra) # 5988 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    379a:	85ca                	mv	a1,s2
    379c:	00004517          	auipc	a0,0x4
    37a0:	e6450513          	addi	a0,a0,-412 # 7600 <malloc+0x182a>
    37a4:	00002097          	auipc	ra,0x2
    37a8:	574080e7          	jalr	1396(ra) # 5d18 <printf>
    exit(1);
    37ac:	4505                	li	a0,1
    37ae:	00002097          	auipc	ra,0x2
    37b2:	1da080e7          	jalr	474(ra) # 5988 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    37b6:	85ca                	mv	a1,s2
    37b8:	00004517          	auipc	a0,0x4
    37bc:	e6850513          	addi	a0,a0,-408 # 7620 <malloc+0x184a>
    37c0:	00002097          	auipc	ra,0x2
    37c4:	558080e7          	jalr	1368(ra) # 5d18 <printf>
    exit(1);
    37c8:	4505                	li	a0,1
    37ca:	00002097          	auipc	ra,0x2
    37ce:	1be080e7          	jalr	446(ra) # 5988 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    37d2:	85ca                	mv	a1,s2
    37d4:	00004517          	auipc	a0,0x4
    37d8:	e7c50513          	addi	a0,a0,-388 # 7650 <malloc+0x187a>
    37dc:	00002097          	auipc	ra,0x2
    37e0:	53c080e7          	jalr	1340(ra) # 5d18 <printf>
    exit(1);
    37e4:	4505                	li	a0,1
    37e6:	00002097          	auipc	ra,0x2
    37ea:	1a2080e7          	jalr	418(ra) # 5988 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    37ee:	85ca                	mv	a1,s2
    37f0:	00004517          	auipc	a0,0x4
    37f4:	e8850513          	addi	a0,a0,-376 # 7678 <malloc+0x18a2>
    37f8:	00002097          	auipc	ra,0x2
    37fc:	520080e7          	jalr	1312(ra) # 5d18 <printf>
    exit(1);
    3800:	4505                	li	a0,1
    3802:	00002097          	auipc	ra,0x2
    3806:	186080e7          	jalr	390(ra) # 5988 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    380a:	85ca                	mv	a1,s2
    380c:	00004517          	auipc	a0,0x4
    3810:	e8c50513          	addi	a0,a0,-372 # 7698 <malloc+0x18c2>
    3814:	00002097          	auipc	ra,0x2
    3818:	504080e7          	jalr	1284(ra) # 5d18 <printf>
    exit(1);
    381c:	4505                	li	a0,1
    381e:	00002097          	auipc	ra,0x2
    3822:	16a080e7          	jalr	362(ra) # 5988 <exit>
    printf("%s: chdir dd failed\n", s);
    3826:	85ca                	mv	a1,s2
    3828:	00004517          	auipc	a0,0x4
    382c:	e9850513          	addi	a0,a0,-360 # 76c0 <malloc+0x18ea>
    3830:	00002097          	auipc	ra,0x2
    3834:	4e8080e7          	jalr	1256(ra) # 5d18 <printf>
    exit(1);
    3838:	4505                	li	a0,1
    383a:	00002097          	auipc	ra,0x2
    383e:	14e080e7          	jalr	334(ra) # 5988 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3842:	85ca                	mv	a1,s2
    3844:	00004517          	auipc	a0,0x4
    3848:	ea450513          	addi	a0,a0,-348 # 76e8 <malloc+0x1912>
    384c:	00002097          	auipc	ra,0x2
    3850:	4cc080e7          	jalr	1228(ra) # 5d18 <printf>
    exit(1);
    3854:	4505                	li	a0,1
    3856:	00002097          	auipc	ra,0x2
    385a:	132080e7          	jalr	306(ra) # 5988 <exit>
    printf("chdir dd/../../dd failed\n", s);
    385e:	85ca                	mv	a1,s2
    3860:	00004517          	auipc	a0,0x4
    3864:	eb850513          	addi	a0,a0,-328 # 7718 <malloc+0x1942>
    3868:	00002097          	auipc	ra,0x2
    386c:	4b0080e7          	jalr	1200(ra) # 5d18 <printf>
    exit(1);
    3870:	4505                	li	a0,1
    3872:	00002097          	auipc	ra,0x2
    3876:	116080e7          	jalr	278(ra) # 5988 <exit>
    printf("%s: chdir ./.. failed\n", s);
    387a:	85ca                	mv	a1,s2
    387c:	00004517          	auipc	a0,0x4
    3880:	ec450513          	addi	a0,a0,-316 # 7740 <malloc+0x196a>
    3884:	00002097          	auipc	ra,0x2
    3888:	494080e7          	jalr	1172(ra) # 5d18 <printf>
    exit(1);
    388c:	4505                	li	a0,1
    388e:	00002097          	auipc	ra,0x2
    3892:	0fa080e7          	jalr	250(ra) # 5988 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3896:	85ca                	mv	a1,s2
    3898:	00004517          	auipc	a0,0x4
    389c:	ec050513          	addi	a0,a0,-320 # 7758 <malloc+0x1982>
    38a0:	00002097          	auipc	ra,0x2
    38a4:	478080e7          	jalr	1144(ra) # 5d18 <printf>
    exit(1);
    38a8:	4505                	li	a0,1
    38aa:	00002097          	auipc	ra,0x2
    38ae:	0de080e7          	jalr	222(ra) # 5988 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    38b2:	85ca                	mv	a1,s2
    38b4:	00004517          	auipc	a0,0x4
    38b8:	ec450513          	addi	a0,a0,-316 # 7778 <malloc+0x19a2>
    38bc:	00002097          	auipc	ra,0x2
    38c0:	45c080e7          	jalr	1116(ra) # 5d18 <printf>
    exit(1);
    38c4:	4505                	li	a0,1
    38c6:	00002097          	auipc	ra,0x2
    38ca:	0c2080e7          	jalr	194(ra) # 5988 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    38ce:	85ca                	mv	a1,s2
    38d0:	00004517          	auipc	a0,0x4
    38d4:	ec850513          	addi	a0,a0,-312 # 7798 <malloc+0x19c2>
    38d8:	00002097          	auipc	ra,0x2
    38dc:	440080e7          	jalr	1088(ra) # 5d18 <printf>
    exit(1);
    38e0:	4505                	li	a0,1
    38e2:	00002097          	auipc	ra,0x2
    38e6:	0a6080e7          	jalr	166(ra) # 5988 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    38ea:	85ca                	mv	a1,s2
    38ec:	00004517          	auipc	a0,0x4
    38f0:	eec50513          	addi	a0,a0,-276 # 77d8 <malloc+0x1a02>
    38f4:	00002097          	auipc	ra,0x2
    38f8:	424080e7          	jalr	1060(ra) # 5d18 <printf>
    exit(1);
    38fc:	4505                	li	a0,1
    38fe:	00002097          	auipc	ra,0x2
    3902:	08a080e7          	jalr	138(ra) # 5988 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3906:	85ca                	mv	a1,s2
    3908:	00004517          	auipc	a0,0x4
    390c:	f0050513          	addi	a0,a0,-256 # 7808 <malloc+0x1a32>
    3910:	00002097          	auipc	ra,0x2
    3914:	408080e7          	jalr	1032(ra) # 5d18 <printf>
    exit(1);
    3918:	4505                	li	a0,1
    391a:	00002097          	auipc	ra,0x2
    391e:	06e080e7          	jalr	110(ra) # 5988 <exit>
    printf("%s: create dd succeeded!\n", s);
    3922:	85ca                	mv	a1,s2
    3924:	00004517          	auipc	a0,0x4
    3928:	f0450513          	addi	a0,a0,-252 # 7828 <malloc+0x1a52>
    392c:	00002097          	auipc	ra,0x2
    3930:	3ec080e7          	jalr	1004(ra) # 5d18 <printf>
    exit(1);
    3934:	4505                	li	a0,1
    3936:	00002097          	auipc	ra,0x2
    393a:	052080e7          	jalr	82(ra) # 5988 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    393e:	85ca                	mv	a1,s2
    3940:	00004517          	auipc	a0,0x4
    3944:	f0850513          	addi	a0,a0,-248 # 7848 <malloc+0x1a72>
    3948:	00002097          	auipc	ra,0x2
    394c:	3d0080e7          	jalr	976(ra) # 5d18 <printf>
    exit(1);
    3950:	4505                	li	a0,1
    3952:	00002097          	auipc	ra,0x2
    3956:	036080e7          	jalr	54(ra) # 5988 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    395a:	85ca                	mv	a1,s2
    395c:	00004517          	auipc	a0,0x4
    3960:	f0c50513          	addi	a0,a0,-244 # 7868 <malloc+0x1a92>
    3964:	00002097          	auipc	ra,0x2
    3968:	3b4080e7          	jalr	948(ra) # 5d18 <printf>
    exit(1);
    396c:	4505                	li	a0,1
    396e:	00002097          	auipc	ra,0x2
    3972:	01a080e7          	jalr	26(ra) # 5988 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3976:	85ca                	mv	a1,s2
    3978:	00004517          	auipc	a0,0x4
    397c:	f2050513          	addi	a0,a0,-224 # 7898 <malloc+0x1ac2>
    3980:	00002097          	auipc	ra,0x2
    3984:	398080e7          	jalr	920(ra) # 5d18 <printf>
    exit(1);
    3988:	4505                	li	a0,1
    398a:	00002097          	auipc	ra,0x2
    398e:	ffe080e7          	jalr	-2(ra) # 5988 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3992:	85ca                	mv	a1,s2
    3994:	00004517          	auipc	a0,0x4
    3998:	f2c50513          	addi	a0,a0,-212 # 78c0 <malloc+0x1aea>
    399c:	00002097          	auipc	ra,0x2
    39a0:	37c080e7          	jalr	892(ra) # 5d18 <printf>
    exit(1);
    39a4:	4505                	li	a0,1
    39a6:	00002097          	auipc	ra,0x2
    39aa:	fe2080e7          	jalr	-30(ra) # 5988 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    39ae:	85ca                	mv	a1,s2
    39b0:	00004517          	auipc	a0,0x4
    39b4:	f3850513          	addi	a0,a0,-200 # 78e8 <malloc+0x1b12>
    39b8:	00002097          	auipc	ra,0x2
    39bc:	360080e7          	jalr	864(ra) # 5d18 <printf>
    exit(1);
    39c0:	4505                	li	a0,1
    39c2:	00002097          	auipc	ra,0x2
    39c6:	fc6080e7          	jalr	-58(ra) # 5988 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    39ca:	85ca                	mv	a1,s2
    39cc:	00004517          	auipc	a0,0x4
    39d0:	f4450513          	addi	a0,a0,-188 # 7910 <malloc+0x1b3a>
    39d4:	00002097          	auipc	ra,0x2
    39d8:	344080e7          	jalr	836(ra) # 5d18 <printf>
    exit(1);
    39dc:	4505                	li	a0,1
    39de:	00002097          	auipc	ra,0x2
    39e2:	faa080e7          	jalr	-86(ra) # 5988 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    39e6:	85ca                	mv	a1,s2
    39e8:	00004517          	auipc	a0,0x4
    39ec:	f4850513          	addi	a0,a0,-184 # 7930 <malloc+0x1b5a>
    39f0:	00002097          	auipc	ra,0x2
    39f4:	328080e7          	jalr	808(ra) # 5d18 <printf>
    exit(1);
    39f8:	4505                	li	a0,1
    39fa:	00002097          	auipc	ra,0x2
    39fe:	f8e080e7          	jalr	-114(ra) # 5988 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3a02:	85ca                	mv	a1,s2
    3a04:	00004517          	auipc	a0,0x4
    3a08:	f4c50513          	addi	a0,a0,-180 # 7950 <malloc+0x1b7a>
    3a0c:	00002097          	auipc	ra,0x2
    3a10:	30c080e7          	jalr	780(ra) # 5d18 <printf>
    exit(1);
    3a14:	4505                	li	a0,1
    3a16:	00002097          	auipc	ra,0x2
    3a1a:	f72080e7          	jalr	-142(ra) # 5988 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3a1e:	85ca                	mv	a1,s2
    3a20:	00004517          	auipc	a0,0x4
    3a24:	f5850513          	addi	a0,a0,-168 # 7978 <malloc+0x1ba2>
    3a28:	00002097          	auipc	ra,0x2
    3a2c:	2f0080e7          	jalr	752(ra) # 5d18 <printf>
    exit(1);
    3a30:	4505                	li	a0,1
    3a32:	00002097          	auipc	ra,0x2
    3a36:	f56080e7          	jalr	-170(ra) # 5988 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3a3a:	85ca                	mv	a1,s2
    3a3c:	00004517          	auipc	a0,0x4
    3a40:	f5c50513          	addi	a0,a0,-164 # 7998 <malloc+0x1bc2>
    3a44:	00002097          	auipc	ra,0x2
    3a48:	2d4080e7          	jalr	724(ra) # 5d18 <printf>
    exit(1);
    3a4c:	4505                	li	a0,1
    3a4e:	00002097          	auipc	ra,0x2
    3a52:	f3a080e7          	jalr	-198(ra) # 5988 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3a56:	85ca                	mv	a1,s2
    3a58:	00004517          	auipc	a0,0x4
    3a5c:	f6050513          	addi	a0,a0,-160 # 79b8 <malloc+0x1be2>
    3a60:	00002097          	auipc	ra,0x2
    3a64:	2b8080e7          	jalr	696(ra) # 5d18 <printf>
    exit(1);
    3a68:	4505                	li	a0,1
    3a6a:	00002097          	auipc	ra,0x2
    3a6e:	f1e080e7          	jalr	-226(ra) # 5988 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3a72:	85ca                	mv	a1,s2
    3a74:	00004517          	auipc	a0,0x4
    3a78:	f6c50513          	addi	a0,a0,-148 # 79e0 <malloc+0x1c0a>
    3a7c:	00002097          	auipc	ra,0x2
    3a80:	29c080e7          	jalr	668(ra) # 5d18 <printf>
    exit(1);
    3a84:	4505                	li	a0,1
    3a86:	00002097          	auipc	ra,0x2
    3a8a:	f02080e7          	jalr	-254(ra) # 5988 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3a8e:	85ca                	mv	a1,s2
    3a90:	00004517          	auipc	a0,0x4
    3a94:	be850513          	addi	a0,a0,-1048 # 7678 <malloc+0x18a2>
    3a98:	00002097          	auipc	ra,0x2
    3a9c:	280080e7          	jalr	640(ra) # 5d18 <printf>
    exit(1);
    3aa0:	4505                	li	a0,1
    3aa2:	00002097          	auipc	ra,0x2
    3aa6:	ee6080e7          	jalr	-282(ra) # 5988 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3aaa:	85ca                	mv	a1,s2
    3aac:	00004517          	auipc	a0,0x4
    3ab0:	f5450513          	addi	a0,a0,-172 # 7a00 <malloc+0x1c2a>
    3ab4:	00002097          	auipc	ra,0x2
    3ab8:	264080e7          	jalr	612(ra) # 5d18 <printf>
    exit(1);
    3abc:	4505                	li	a0,1
    3abe:	00002097          	auipc	ra,0x2
    3ac2:	eca080e7          	jalr	-310(ra) # 5988 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3ac6:	85ca                	mv	a1,s2
    3ac8:	00004517          	auipc	a0,0x4
    3acc:	f5850513          	addi	a0,a0,-168 # 7a20 <malloc+0x1c4a>
    3ad0:	00002097          	auipc	ra,0x2
    3ad4:	248080e7          	jalr	584(ra) # 5d18 <printf>
    exit(1);
    3ad8:	4505                	li	a0,1
    3ada:	00002097          	auipc	ra,0x2
    3ade:	eae080e7          	jalr	-338(ra) # 5988 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3ae2:	85ca                	mv	a1,s2
    3ae4:	00004517          	auipc	a0,0x4
    3ae8:	f6c50513          	addi	a0,a0,-148 # 7a50 <malloc+0x1c7a>
    3aec:	00002097          	auipc	ra,0x2
    3af0:	22c080e7          	jalr	556(ra) # 5d18 <printf>
    exit(1);
    3af4:	4505                	li	a0,1
    3af6:	00002097          	auipc	ra,0x2
    3afa:	e92080e7          	jalr	-366(ra) # 5988 <exit>
    printf("%s: unlink dd failed\n", s);
    3afe:	85ca                	mv	a1,s2
    3b00:	00004517          	auipc	a0,0x4
    3b04:	f7050513          	addi	a0,a0,-144 # 7a70 <malloc+0x1c9a>
    3b08:	00002097          	auipc	ra,0x2
    3b0c:	210080e7          	jalr	528(ra) # 5d18 <printf>
    exit(1);
    3b10:	4505                	li	a0,1
    3b12:	00002097          	auipc	ra,0x2
    3b16:	e76080e7          	jalr	-394(ra) # 5988 <exit>

0000000000003b1a <rmdot>:
{
    3b1a:	1101                	addi	sp,sp,-32
    3b1c:	ec06                	sd	ra,24(sp)
    3b1e:	e822                	sd	s0,16(sp)
    3b20:	e426                	sd	s1,8(sp)
    3b22:	1000                	addi	s0,sp,32
    3b24:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3b26:	00004517          	auipc	a0,0x4
    3b2a:	f6250513          	addi	a0,a0,-158 # 7a88 <malloc+0x1cb2>
    3b2e:	00002097          	auipc	ra,0x2
    3b32:	ec2080e7          	jalr	-318(ra) # 59f0 <mkdir>
    3b36:	e549                	bnez	a0,3bc0 <rmdot+0xa6>
  if(chdir("dots") != 0){
    3b38:	00004517          	auipc	a0,0x4
    3b3c:	f5050513          	addi	a0,a0,-176 # 7a88 <malloc+0x1cb2>
    3b40:	00002097          	auipc	ra,0x2
    3b44:	eb8080e7          	jalr	-328(ra) # 59f8 <chdir>
    3b48:	e951                	bnez	a0,3bdc <rmdot+0xc2>
  if(unlink(".") == 0){
    3b4a:	00003517          	auipc	a0,0x3
    3b4e:	dd650513          	addi	a0,a0,-554 # 6920 <malloc+0xb4a>
    3b52:	00002097          	auipc	ra,0x2
    3b56:	e86080e7          	jalr	-378(ra) # 59d8 <unlink>
    3b5a:	cd59                	beqz	a0,3bf8 <rmdot+0xde>
  if(unlink("..") == 0){
    3b5c:	00004517          	auipc	a0,0x4
    3b60:	98450513          	addi	a0,a0,-1660 # 74e0 <malloc+0x170a>
    3b64:	00002097          	auipc	ra,0x2
    3b68:	e74080e7          	jalr	-396(ra) # 59d8 <unlink>
    3b6c:	c545                	beqz	a0,3c14 <rmdot+0xfa>
  if(chdir("/") != 0){
    3b6e:	00004517          	auipc	a0,0x4
    3b72:	91a50513          	addi	a0,a0,-1766 # 7488 <malloc+0x16b2>
    3b76:	00002097          	auipc	ra,0x2
    3b7a:	e82080e7          	jalr	-382(ra) # 59f8 <chdir>
    3b7e:	e94d                	bnez	a0,3c30 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3b80:	00004517          	auipc	a0,0x4
    3b84:	f7050513          	addi	a0,a0,-144 # 7af0 <malloc+0x1d1a>
    3b88:	00002097          	auipc	ra,0x2
    3b8c:	e50080e7          	jalr	-432(ra) # 59d8 <unlink>
    3b90:	cd55                	beqz	a0,3c4c <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3b92:	00004517          	auipc	a0,0x4
    3b96:	f8650513          	addi	a0,a0,-122 # 7b18 <malloc+0x1d42>
    3b9a:	00002097          	auipc	ra,0x2
    3b9e:	e3e080e7          	jalr	-450(ra) # 59d8 <unlink>
    3ba2:	c179                	beqz	a0,3c68 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3ba4:	00004517          	auipc	a0,0x4
    3ba8:	ee450513          	addi	a0,a0,-284 # 7a88 <malloc+0x1cb2>
    3bac:	00002097          	auipc	ra,0x2
    3bb0:	e2c080e7          	jalr	-468(ra) # 59d8 <unlink>
    3bb4:	e961                	bnez	a0,3c84 <rmdot+0x16a>
}
    3bb6:	60e2                	ld	ra,24(sp)
    3bb8:	6442                	ld	s0,16(sp)
    3bba:	64a2                	ld	s1,8(sp)
    3bbc:	6105                	addi	sp,sp,32
    3bbe:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3bc0:	85a6                	mv	a1,s1
    3bc2:	00004517          	auipc	a0,0x4
    3bc6:	ece50513          	addi	a0,a0,-306 # 7a90 <malloc+0x1cba>
    3bca:	00002097          	auipc	ra,0x2
    3bce:	14e080e7          	jalr	334(ra) # 5d18 <printf>
    exit(1);
    3bd2:	4505                	li	a0,1
    3bd4:	00002097          	auipc	ra,0x2
    3bd8:	db4080e7          	jalr	-588(ra) # 5988 <exit>
    printf("%s: chdir dots failed\n", s);
    3bdc:	85a6                	mv	a1,s1
    3bde:	00004517          	auipc	a0,0x4
    3be2:	eca50513          	addi	a0,a0,-310 # 7aa8 <malloc+0x1cd2>
    3be6:	00002097          	auipc	ra,0x2
    3bea:	132080e7          	jalr	306(ra) # 5d18 <printf>
    exit(1);
    3bee:	4505                	li	a0,1
    3bf0:	00002097          	auipc	ra,0x2
    3bf4:	d98080e7          	jalr	-616(ra) # 5988 <exit>
    printf("%s: rm . worked!\n", s);
    3bf8:	85a6                	mv	a1,s1
    3bfa:	00004517          	auipc	a0,0x4
    3bfe:	ec650513          	addi	a0,a0,-314 # 7ac0 <malloc+0x1cea>
    3c02:	00002097          	auipc	ra,0x2
    3c06:	116080e7          	jalr	278(ra) # 5d18 <printf>
    exit(1);
    3c0a:	4505                	li	a0,1
    3c0c:	00002097          	auipc	ra,0x2
    3c10:	d7c080e7          	jalr	-644(ra) # 5988 <exit>
    printf("%s: rm .. worked!\n", s);
    3c14:	85a6                	mv	a1,s1
    3c16:	00004517          	auipc	a0,0x4
    3c1a:	ec250513          	addi	a0,a0,-318 # 7ad8 <malloc+0x1d02>
    3c1e:	00002097          	auipc	ra,0x2
    3c22:	0fa080e7          	jalr	250(ra) # 5d18 <printf>
    exit(1);
    3c26:	4505                	li	a0,1
    3c28:	00002097          	auipc	ra,0x2
    3c2c:	d60080e7          	jalr	-672(ra) # 5988 <exit>
    printf("%s: chdir / failed\n", s);
    3c30:	85a6                	mv	a1,s1
    3c32:	00004517          	auipc	a0,0x4
    3c36:	85e50513          	addi	a0,a0,-1954 # 7490 <malloc+0x16ba>
    3c3a:	00002097          	auipc	ra,0x2
    3c3e:	0de080e7          	jalr	222(ra) # 5d18 <printf>
    exit(1);
    3c42:	4505                	li	a0,1
    3c44:	00002097          	auipc	ra,0x2
    3c48:	d44080e7          	jalr	-700(ra) # 5988 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3c4c:	85a6                	mv	a1,s1
    3c4e:	00004517          	auipc	a0,0x4
    3c52:	eaa50513          	addi	a0,a0,-342 # 7af8 <malloc+0x1d22>
    3c56:	00002097          	auipc	ra,0x2
    3c5a:	0c2080e7          	jalr	194(ra) # 5d18 <printf>
    exit(1);
    3c5e:	4505                	li	a0,1
    3c60:	00002097          	auipc	ra,0x2
    3c64:	d28080e7          	jalr	-728(ra) # 5988 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3c68:	85a6                	mv	a1,s1
    3c6a:	00004517          	auipc	a0,0x4
    3c6e:	eb650513          	addi	a0,a0,-330 # 7b20 <malloc+0x1d4a>
    3c72:	00002097          	auipc	ra,0x2
    3c76:	0a6080e7          	jalr	166(ra) # 5d18 <printf>
    exit(1);
    3c7a:	4505                	li	a0,1
    3c7c:	00002097          	auipc	ra,0x2
    3c80:	d0c080e7          	jalr	-756(ra) # 5988 <exit>
    printf("%s: unlink dots failed!\n", s);
    3c84:	85a6                	mv	a1,s1
    3c86:	00004517          	auipc	a0,0x4
    3c8a:	eba50513          	addi	a0,a0,-326 # 7b40 <malloc+0x1d6a>
    3c8e:	00002097          	auipc	ra,0x2
    3c92:	08a080e7          	jalr	138(ra) # 5d18 <printf>
    exit(1);
    3c96:	4505                	li	a0,1
    3c98:	00002097          	auipc	ra,0x2
    3c9c:	cf0080e7          	jalr	-784(ra) # 5988 <exit>

0000000000003ca0 <dirfile>:
{
    3ca0:	1101                	addi	sp,sp,-32
    3ca2:	ec06                	sd	ra,24(sp)
    3ca4:	e822                	sd	s0,16(sp)
    3ca6:	e426                	sd	s1,8(sp)
    3ca8:	e04a                	sd	s2,0(sp)
    3caa:	1000                	addi	s0,sp,32
    3cac:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    3cae:	20000593          	li	a1,512
    3cb2:	00002517          	auipc	a0,0x2
    3cb6:	54650513          	addi	a0,a0,1350 # 61f8 <malloc+0x422>
    3cba:	00002097          	auipc	ra,0x2
    3cbe:	d0e080e7          	jalr	-754(ra) # 59c8 <open>
  if(fd < 0){
    3cc2:	0e054d63          	bltz	a0,3dbc <dirfile+0x11c>
  close(fd);
    3cc6:	00002097          	auipc	ra,0x2
    3cca:	cea080e7          	jalr	-790(ra) # 59b0 <close>
  if(chdir("dirfile") == 0){
    3cce:	00002517          	auipc	a0,0x2
    3cd2:	52a50513          	addi	a0,a0,1322 # 61f8 <malloc+0x422>
    3cd6:	00002097          	auipc	ra,0x2
    3cda:	d22080e7          	jalr	-734(ra) # 59f8 <chdir>
    3cde:	cd6d                	beqz	a0,3dd8 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    3ce0:	4581                	li	a1,0
    3ce2:	00004517          	auipc	a0,0x4
    3ce6:	ebe50513          	addi	a0,a0,-322 # 7ba0 <malloc+0x1dca>
    3cea:	00002097          	auipc	ra,0x2
    3cee:	cde080e7          	jalr	-802(ra) # 59c8 <open>
  if(fd >= 0){
    3cf2:	10055163          	bgez	a0,3df4 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3cf6:	20000593          	li	a1,512
    3cfa:	00004517          	auipc	a0,0x4
    3cfe:	ea650513          	addi	a0,a0,-346 # 7ba0 <malloc+0x1dca>
    3d02:	00002097          	auipc	ra,0x2
    3d06:	cc6080e7          	jalr	-826(ra) # 59c8 <open>
  if(fd >= 0){
    3d0a:	10055363          	bgez	a0,3e10 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3d0e:	00004517          	auipc	a0,0x4
    3d12:	e9250513          	addi	a0,a0,-366 # 7ba0 <malloc+0x1dca>
    3d16:	00002097          	auipc	ra,0x2
    3d1a:	cda080e7          	jalr	-806(ra) # 59f0 <mkdir>
    3d1e:	10050763          	beqz	a0,3e2c <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3d22:	00004517          	auipc	a0,0x4
    3d26:	e7e50513          	addi	a0,a0,-386 # 7ba0 <malloc+0x1dca>
    3d2a:	00002097          	auipc	ra,0x2
    3d2e:	cae080e7          	jalr	-850(ra) # 59d8 <unlink>
    3d32:	10050b63          	beqz	a0,3e48 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3d36:	00004597          	auipc	a1,0x4
    3d3a:	e6a58593          	addi	a1,a1,-406 # 7ba0 <malloc+0x1dca>
    3d3e:	00002517          	auipc	a0,0x2
    3d42:	6e250513          	addi	a0,a0,1762 # 6420 <malloc+0x64a>
    3d46:	00002097          	auipc	ra,0x2
    3d4a:	ca2080e7          	jalr	-862(ra) # 59e8 <link>
    3d4e:	10050b63          	beqz	a0,3e64 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3d52:	00002517          	auipc	a0,0x2
    3d56:	4a650513          	addi	a0,a0,1190 # 61f8 <malloc+0x422>
    3d5a:	00002097          	auipc	ra,0x2
    3d5e:	c7e080e7          	jalr	-898(ra) # 59d8 <unlink>
    3d62:	10051f63          	bnez	a0,3e80 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3d66:	4589                	li	a1,2
    3d68:	00003517          	auipc	a0,0x3
    3d6c:	bb850513          	addi	a0,a0,-1096 # 6920 <malloc+0xb4a>
    3d70:	00002097          	auipc	ra,0x2
    3d74:	c58080e7          	jalr	-936(ra) # 59c8 <open>
  if(fd >= 0){
    3d78:	12055263          	bgez	a0,3e9c <dirfile+0x1fc>
  fd = open(".", 0);
    3d7c:	4581                	li	a1,0
    3d7e:	00003517          	auipc	a0,0x3
    3d82:	ba250513          	addi	a0,a0,-1118 # 6920 <malloc+0xb4a>
    3d86:	00002097          	auipc	ra,0x2
    3d8a:	c42080e7          	jalr	-958(ra) # 59c8 <open>
    3d8e:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3d90:	4605                	li	a2,1
    3d92:	00002597          	auipc	a1,0x2
    3d96:	54658593          	addi	a1,a1,1350 # 62d8 <malloc+0x502>
    3d9a:	00002097          	auipc	ra,0x2
    3d9e:	c0e080e7          	jalr	-1010(ra) # 59a8 <write>
    3da2:	10a04b63          	bgtz	a0,3eb8 <dirfile+0x218>
  close(fd);
    3da6:	8526                	mv	a0,s1
    3da8:	00002097          	auipc	ra,0x2
    3dac:	c08080e7          	jalr	-1016(ra) # 59b0 <close>
}
    3db0:	60e2                	ld	ra,24(sp)
    3db2:	6442                	ld	s0,16(sp)
    3db4:	64a2                	ld	s1,8(sp)
    3db6:	6902                	ld	s2,0(sp)
    3db8:	6105                	addi	sp,sp,32
    3dba:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3dbc:	85ca                	mv	a1,s2
    3dbe:	00004517          	auipc	a0,0x4
    3dc2:	da250513          	addi	a0,a0,-606 # 7b60 <malloc+0x1d8a>
    3dc6:	00002097          	auipc	ra,0x2
    3dca:	f52080e7          	jalr	-174(ra) # 5d18 <printf>
    exit(1);
    3dce:	4505                	li	a0,1
    3dd0:	00002097          	auipc	ra,0x2
    3dd4:	bb8080e7          	jalr	-1096(ra) # 5988 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3dd8:	85ca                	mv	a1,s2
    3dda:	00004517          	auipc	a0,0x4
    3dde:	da650513          	addi	a0,a0,-602 # 7b80 <malloc+0x1daa>
    3de2:	00002097          	auipc	ra,0x2
    3de6:	f36080e7          	jalr	-202(ra) # 5d18 <printf>
    exit(1);
    3dea:	4505                	li	a0,1
    3dec:	00002097          	auipc	ra,0x2
    3df0:	b9c080e7          	jalr	-1124(ra) # 5988 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3df4:	85ca                	mv	a1,s2
    3df6:	00004517          	auipc	a0,0x4
    3dfa:	dba50513          	addi	a0,a0,-582 # 7bb0 <malloc+0x1dda>
    3dfe:	00002097          	auipc	ra,0x2
    3e02:	f1a080e7          	jalr	-230(ra) # 5d18 <printf>
    exit(1);
    3e06:	4505                	li	a0,1
    3e08:	00002097          	auipc	ra,0x2
    3e0c:	b80080e7          	jalr	-1152(ra) # 5988 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3e10:	85ca                	mv	a1,s2
    3e12:	00004517          	auipc	a0,0x4
    3e16:	d9e50513          	addi	a0,a0,-610 # 7bb0 <malloc+0x1dda>
    3e1a:	00002097          	auipc	ra,0x2
    3e1e:	efe080e7          	jalr	-258(ra) # 5d18 <printf>
    exit(1);
    3e22:	4505                	li	a0,1
    3e24:	00002097          	auipc	ra,0x2
    3e28:	b64080e7          	jalr	-1180(ra) # 5988 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3e2c:	85ca                	mv	a1,s2
    3e2e:	00004517          	auipc	a0,0x4
    3e32:	daa50513          	addi	a0,a0,-598 # 7bd8 <malloc+0x1e02>
    3e36:	00002097          	auipc	ra,0x2
    3e3a:	ee2080e7          	jalr	-286(ra) # 5d18 <printf>
    exit(1);
    3e3e:	4505                	li	a0,1
    3e40:	00002097          	auipc	ra,0x2
    3e44:	b48080e7          	jalr	-1208(ra) # 5988 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3e48:	85ca                	mv	a1,s2
    3e4a:	00004517          	auipc	a0,0x4
    3e4e:	db650513          	addi	a0,a0,-586 # 7c00 <malloc+0x1e2a>
    3e52:	00002097          	auipc	ra,0x2
    3e56:	ec6080e7          	jalr	-314(ra) # 5d18 <printf>
    exit(1);
    3e5a:	4505                	li	a0,1
    3e5c:	00002097          	auipc	ra,0x2
    3e60:	b2c080e7          	jalr	-1236(ra) # 5988 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3e64:	85ca                	mv	a1,s2
    3e66:	00004517          	auipc	a0,0x4
    3e6a:	dc250513          	addi	a0,a0,-574 # 7c28 <malloc+0x1e52>
    3e6e:	00002097          	auipc	ra,0x2
    3e72:	eaa080e7          	jalr	-342(ra) # 5d18 <printf>
    exit(1);
    3e76:	4505                	li	a0,1
    3e78:	00002097          	auipc	ra,0x2
    3e7c:	b10080e7          	jalr	-1264(ra) # 5988 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3e80:	85ca                	mv	a1,s2
    3e82:	00004517          	auipc	a0,0x4
    3e86:	dce50513          	addi	a0,a0,-562 # 7c50 <malloc+0x1e7a>
    3e8a:	00002097          	auipc	ra,0x2
    3e8e:	e8e080e7          	jalr	-370(ra) # 5d18 <printf>
    exit(1);
    3e92:	4505                	li	a0,1
    3e94:	00002097          	auipc	ra,0x2
    3e98:	af4080e7          	jalr	-1292(ra) # 5988 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3e9c:	85ca                	mv	a1,s2
    3e9e:	00004517          	auipc	a0,0x4
    3ea2:	dd250513          	addi	a0,a0,-558 # 7c70 <malloc+0x1e9a>
    3ea6:	00002097          	auipc	ra,0x2
    3eaa:	e72080e7          	jalr	-398(ra) # 5d18 <printf>
    exit(1);
    3eae:	4505                	li	a0,1
    3eb0:	00002097          	auipc	ra,0x2
    3eb4:	ad8080e7          	jalr	-1320(ra) # 5988 <exit>
    printf("%s: write . succeeded!\n", s);
    3eb8:	85ca                	mv	a1,s2
    3eba:	00004517          	auipc	a0,0x4
    3ebe:	dde50513          	addi	a0,a0,-546 # 7c98 <malloc+0x1ec2>
    3ec2:	00002097          	auipc	ra,0x2
    3ec6:	e56080e7          	jalr	-426(ra) # 5d18 <printf>
    exit(1);
    3eca:	4505                	li	a0,1
    3ecc:	00002097          	auipc	ra,0x2
    3ed0:	abc080e7          	jalr	-1348(ra) # 5988 <exit>

0000000000003ed4 <iref>:
{
    3ed4:	7139                	addi	sp,sp,-64
    3ed6:	fc06                	sd	ra,56(sp)
    3ed8:	f822                	sd	s0,48(sp)
    3eda:	f426                	sd	s1,40(sp)
    3edc:	f04a                	sd	s2,32(sp)
    3ede:	ec4e                	sd	s3,24(sp)
    3ee0:	e852                	sd	s4,16(sp)
    3ee2:	e456                	sd	s5,8(sp)
    3ee4:	e05a                	sd	s6,0(sp)
    3ee6:	0080                	addi	s0,sp,64
    3ee8:	8b2a                	mv	s6,a0
    3eea:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3eee:	00004a17          	auipc	s4,0x4
    3ef2:	dc2a0a13          	addi	s4,s4,-574 # 7cb0 <malloc+0x1eda>
    mkdir("");
    3ef6:	00004497          	auipc	s1,0x4
    3efa:	8ca48493          	addi	s1,s1,-1846 # 77c0 <malloc+0x19ea>
    link("README", "");
    3efe:	00002a97          	auipc	s5,0x2
    3f02:	522a8a93          	addi	s5,s5,1314 # 6420 <malloc+0x64a>
    fd = open("xx", O_CREATE);
    3f06:	00004997          	auipc	s3,0x4
    3f0a:	ca298993          	addi	s3,s3,-862 # 7ba8 <malloc+0x1dd2>
    3f0e:	a891                	j	3f62 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3f10:	85da                	mv	a1,s6
    3f12:	00004517          	auipc	a0,0x4
    3f16:	da650513          	addi	a0,a0,-602 # 7cb8 <malloc+0x1ee2>
    3f1a:	00002097          	auipc	ra,0x2
    3f1e:	dfe080e7          	jalr	-514(ra) # 5d18 <printf>
      exit(1);
    3f22:	4505                	li	a0,1
    3f24:	00002097          	auipc	ra,0x2
    3f28:	a64080e7          	jalr	-1436(ra) # 5988 <exit>
      printf("%s: chdir irefd failed\n", s);
    3f2c:	85da                	mv	a1,s6
    3f2e:	00004517          	auipc	a0,0x4
    3f32:	da250513          	addi	a0,a0,-606 # 7cd0 <malloc+0x1efa>
    3f36:	00002097          	auipc	ra,0x2
    3f3a:	de2080e7          	jalr	-542(ra) # 5d18 <printf>
      exit(1);
    3f3e:	4505                	li	a0,1
    3f40:	00002097          	auipc	ra,0x2
    3f44:	a48080e7          	jalr	-1464(ra) # 5988 <exit>
      close(fd);
    3f48:	00002097          	auipc	ra,0x2
    3f4c:	a68080e7          	jalr	-1432(ra) # 59b0 <close>
    3f50:	a889                	j	3fa2 <iref+0xce>
    unlink("xx");
    3f52:	854e                	mv	a0,s3
    3f54:	00002097          	auipc	ra,0x2
    3f58:	a84080e7          	jalr	-1404(ra) # 59d8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3f5c:	397d                	addiw	s2,s2,-1
    3f5e:	06090063          	beqz	s2,3fbe <iref+0xea>
    if(mkdir("irefd") != 0){
    3f62:	8552                	mv	a0,s4
    3f64:	00002097          	auipc	ra,0x2
    3f68:	a8c080e7          	jalr	-1396(ra) # 59f0 <mkdir>
    3f6c:	f155                	bnez	a0,3f10 <iref+0x3c>
    if(chdir("irefd") != 0){
    3f6e:	8552                	mv	a0,s4
    3f70:	00002097          	auipc	ra,0x2
    3f74:	a88080e7          	jalr	-1400(ra) # 59f8 <chdir>
    3f78:	f955                	bnez	a0,3f2c <iref+0x58>
    mkdir("");
    3f7a:	8526                	mv	a0,s1
    3f7c:	00002097          	auipc	ra,0x2
    3f80:	a74080e7          	jalr	-1420(ra) # 59f0 <mkdir>
    link("README", "");
    3f84:	85a6                	mv	a1,s1
    3f86:	8556                	mv	a0,s5
    3f88:	00002097          	auipc	ra,0x2
    3f8c:	a60080e7          	jalr	-1440(ra) # 59e8 <link>
    fd = open("", O_CREATE);
    3f90:	20000593          	li	a1,512
    3f94:	8526                	mv	a0,s1
    3f96:	00002097          	auipc	ra,0x2
    3f9a:	a32080e7          	jalr	-1486(ra) # 59c8 <open>
    if(fd >= 0)
    3f9e:	fa0555e3          	bgez	a0,3f48 <iref+0x74>
    fd = open("xx", O_CREATE);
    3fa2:	20000593          	li	a1,512
    3fa6:	854e                	mv	a0,s3
    3fa8:	00002097          	auipc	ra,0x2
    3fac:	a20080e7          	jalr	-1504(ra) # 59c8 <open>
    if(fd >= 0)
    3fb0:	fa0541e3          	bltz	a0,3f52 <iref+0x7e>
      close(fd);
    3fb4:	00002097          	auipc	ra,0x2
    3fb8:	9fc080e7          	jalr	-1540(ra) # 59b0 <close>
    3fbc:	bf59                	j	3f52 <iref+0x7e>
    3fbe:	03300493          	li	s1,51
    chdir("..");
    3fc2:	00003997          	auipc	s3,0x3
    3fc6:	51e98993          	addi	s3,s3,1310 # 74e0 <malloc+0x170a>
    unlink("irefd");
    3fca:	00004917          	auipc	s2,0x4
    3fce:	ce690913          	addi	s2,s2,-794 # 7cb0 <malloc+0x1eda>
    chdir("..");
    3fd2:	854e                	mv	a0,s3
    3fd4:	00002097          	auipc	ra,0x2
    3fd8:	a24080e7          	jalr	-1500(ra) # 59f8 <chdir>
    unlink("irefd");
    3fdc:	854a                	mv	a0,s2
    3fde:	00002097          	auipc	ra,0x2
    3fe2:	9fa080e7          	jalr	-1542(ra) # 59d8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3fe6:	34fd                	addiw	s1,s1,-1
    3fe8:	f4ed                	bnez	s1,3fd2 <iref+0xfe>
  chdir("/");
    3fea:	00003517          	auipc	a0,0x3
    3fee:	49e50513          	addi	a0,a0,1182 # 7488 <malloc+0x16b2>
    3ff2:	00002097          	auipc	ra,0x2
    3ff6:	a06080e7          	jalr	-1530(ra) # 59f8 <chdir>
}
    3ffa:	70e2                	ld	ra,56(sp)
    3ffc:	7442                	ld	s0,48(sp)
    3ffe:	74a2                	ld	s1,40(sp)
    4000:	7902                	ld	s2,32(sp)
    4002:	69e2                	ld	s3,24(sp)
    4004:	6a42                	ld	s4,16(sp)
    4006:	6aa2                	ld	s5,8(sp)
    4008:	6b02                	ld	s6,0(sp)
    400a:	6121                	addi	sp,sp,64
    400c:	8082                	ret

000000000000400e <openiputtest>:
{
    400e:	7179                	addi	sp,sp,-48
    4010:	f406                	sd	ra,40(sp)
    4012:	f022                	sd	s0,32(sp)
    4014:	ec26                	sd	s1,24(sp)
    4016:	1800                	addi	s0,sp,48
    4018:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    401a:	00004517          	auipc	a0,0x4
    401e:	cce50513          	addi	a0,a0,-818 # 7ce8 <malloc+0x1f12>
    4022:	00002097          	auipc	ra,0x2
    4026:	9ce080e7          	jalr	-1586(ra) # 59f0 <mkdir>
    402a:	04054263          	bltz	a0,406e <openiputtest+0x60>
  pid = fork();
    402e:	00002097          	auipc	ra,0x2
    4032:	952080e7          	jalr	-1710(ra) # 5980 <fork>
  if(pid < 0){
    4036:	04054a63          	bltz	a0,408a <openiputtest+0x7c>
  if(pid == 0){
    403a:	e93d                	bnez	a0,40b0 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    403c:	4589                	li	a1,2
    403e:	00004517          	auipc	a0,0x4
    4042:	caa50513          	addi	a0,a0,-854 # 7ce8 <malloc+0x1f12>
    4046:	00002097          	auipc	ra,0x2
    404a:	982080e7          	jalr	-1662(ra) # 59c8 <open>
    if(fd >= 0){
    404e:	04054c63          	bltz	a0,40a6 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    4052:	85a6                	mv	a1,s1
    4054:	00004517          	auipc	a0,0x4
    4058:	cb450513          	addi	a0,a0,-844 # 7d08 <malloc+0x1f32>
    405c:	00002097          	auipc	ra,0x2
    4060:	cbc080e7          	jalr	-836(ra) # 5d18 <printf>
      exit(1);
    4064:	4505                	li	a0,1
    4066:	00002097          	auipc	ra,0x2
    406a:	922080e7          	jalr	-1758(ra) # 5988 <exit>
    printf("%s: mkdir oidir failed\n", s);
    406e:	85a6                	mv	a1,s1
    4070:	00004517          	auipc	a0,0x4
    4074:	c8050513          	addi	a0,a0,-896 # 7cf0 <malloc+0x1f1a>
    4078:	00002097          	auipc	ra,0x2
    407c:	ca0080e7          	jalr	-864(ra) # 5d18 <printf>
    exit(1);
    4080:	4505                	li	a0,1
    4082:	00002097          	auipc	ra,0x2
    4086:	906080e7          	jalr	-1786(ra) # 5988 <exit>
    printf("%s: fork failed\n", s);
    408a:	85a6                	mv	a1,s1
    408c:	00003517          	auipc	a0,0x3
    4090:	a3450513          	addi	a0,a0,-1484 # 6ac0 <malloc+0xcea>
    4094:	00002097          	auipc	ra,0x2
    4098:	c84080e7          	jalr	-892(ra) # 5d18 <printf>
    exit(1);
    409c:	4505                	li	a0,1
    409e:	00002097          	auipc	ra,0x2
    40a2:	8ea080e7          	jalr	-1814(ra) # 5988 <exit>
    exit(0);
    40a6:	4501                	li	a0,0
    40a8:	00002097          	auipc	ra,0x2
    40ac:	8e0080e7          	jalr	-1824(ra) # 5988 <exit>
  sleep(1);
    40b0:	4505                	li	a0,1
    40b2:	00002097          	auipc	ra,0x2
    40b6:	966080e7          	jalr	-1690(ra) # 5a18 <sleep>
  if(unlink("oidir") != 0){
    40ba:	00004517          	auipc	a0,0x4
    40be:	c2e50513          	addi	a0,a0,-978 # 7ce8 <malloc+0x1f12>
    40c2:	00002097          	auipc	ra,0x2
    40c6:	916080e7          	jalr	-1770(ra) # 59d8 <unlink>
    40ca:	cd19                	beqz	a0,40e8 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    40cc:	85a6                	mv	a1,s1
    40ce:	00003517          	auipc	a0,0x3
    40d2:	be250513          	addi	a0,a0,-1054 # 6cb0 <malloc+0xeda>
    40d6:	00002097          	auipc	ra,0x2
    40da:	c42080e7          	jalr	-958(ra) # 5d18 <printf>
    exit(1);
    40de:	4505                	li	a0,1
    40e0:	00002097          	auipc	ra,0x2
    40e4:	8a8080e7          	jalr	-1880(ra) # 5988 <exit>
  wait(&xstatus);
    40e8:	fdc40513          	addi	a0,s0,-36
    40ec:	00002097          	auipc	ra,0x2
    40f0:	8a4080e7          	jalr	-1884(ra) # 5990 <wait>
  exit(xstatus);
    40f4:	fdc42503          	lw	a0,-36(s0)
    40f8:	00002097          	auipc	ra,0x2
    40fc:	890080e7          	jalr	-1904(ra) # 5988 <exit>

0000000000004100 <forkforkfork>:
{
    4100:	1101                	addi	sp,sp,-32
    4102:	ec06                	sd	ra,24(sp)
    4104:	e822                	sd	s0,16(sp)
    4106:	e426                	sd	s1,8(sp)
    4108:	1000                	addi	s0,sp,32
    410a:	84aa                	mv	s1,a0
  unlink("stopforking");
    410c:	00004517          	auipc	a0,0x4
    4110:	c2450513          	addi	a0,a0,-988 # 7d30 <malloc+0x1f5a>
    4114:	00002097          	auipc	ra,0x2
    4118:	8c4080e7          	jalr	-1852(ra) # 59d8 <unlink>
  int pid = fork();
    411c:	00002097          	auipc	ra,0x2
    4120:	864080e7          	jalr	-1948(ra) # 5980 <fork>
  if(pid < 0){
    4124:	04054563          	bltz	a0,416e <forkforkfork+0x6e>
  if(pid == 0){
    4128:	c12d                	beqz	a0,418a <forkforkfork+0x8a>
  sleep(20); // two seconds
    412a:	4551                	li	a0,20
    412c:	00002097          	auipc	ra,0x2
    4130:	8ec080e7          	jalr	-1812(ra) # 5a18 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    4134:	20200593          	li	a1,514
    4138:	00004517          	auipc	a0,0x4
    413c:	bf850513          	addi	a0,a0,-1032 # 7d30 <malloc+0x1f5a>
    4140:	00002097          	auipc	ra,0x2
    4144:	888080e7          	jalr	-1912(ra) # 59c8 <open>
    4148:	00002097          	auipc	ra,0x2
    414c:	868080e7          	jalr	-1944(ra) # 59b0 <close>
  wait(0);
    4150:	4501                	li	a0,0
    4152:	00002097          	auipc	ra,0x2
    4156:	83e080e7          	jalr	-1986(ra) # 5990 <wait>
  sleep(10); // one second
    415a:	4529                	li	a0,10
    415c:	00002097          	auipc	ra,0x2
    4160:	8bc080e7          	jalr	-1860(ra) # 5a18 <sleep>
}
    4164:	60e2                	ld	ra,24(sp)
    4166:	6442                	ld	s0,16(sp)
    4168:	64a2                	ld	s1,8(sp)
    416a:	6105                	addi	sp,sp,32
    416c:	8082                	ret
    printf("%s: fork failed", s);
    416e:	85a6                	mv	a1,s1
    4170:	00003517          	auipc	a0,0x3
    4174:	b1050513          	addi	a0,a0,-1264 # 6c80 <malloc+0xeaa>
    4178:	00002097          	auipc	ra,0x2
    417c:	ba0080e7          	jalr	-1120(ra) # 5d18 <printf>
    exit(1);
    4180:	4505                	li	a0,1
    4182:	00002097          	auipc	ra,0x2
    4186:	806080e7          	jalr	-2042(ra) # 5988 <exit>
      int fd = open("stopforking", 0);
    418a:	00004497          	auipc	s1,0x4
    418e:	ba648493          	addi	s1,s1,-1114 # 7d30 <malloc+0x1f5a>
    4192:	4581                	li	a1,0
    4194:	8526                	mv	a0,s1
    4196:	00002097          	auipc	ra,0x2
    419a:	832080e7          	jalr	-1998(ra) # 59c8 <open>
      if(fd >= 0){
    419e:	02055463          	bgez	a0,41c6 <forkforkfork+0xc6>
      if(fork() < 0){
    41a2:	00001097          	auipc	ra,0x1
    41a6:	7de080e7          	jalr	2014(ra) # 5980 <fork>
    41aa:	fe0554e3          	bgez	a0,4192 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    41ae:	20200593          	li	a1,514
    41b2:	8526                	mv	a0,s1
    41b4:	00002097          	auipc	ra,0x2
    41b8:	814080e7          	jalr	-2028(ra) # 59c8 <open>
    41bc:	00001097          	auipc	ra,0x1
    41c0:	7f4080e7          	jalr	2036(ra) # 59b0 <close>
    41c4:	b7f9                	j	4192 <forkforkfork+0x92>
        exit(0);
    41c6:	4501                	li	a0,0
    41c8:	00001097          	auipc	ra,0x1
    41cc:	7c0080e7          	jalr	1984(ra) # 5988 <exit>

00000000000041d0 <killstatus>:
{
    41d0:	7139                	addi	sp,sp,-64
    41d2:	fc06                	sd	ra,56(sp)
    41d4:	f822                	sd	s0,48(sp)
    41d6:	f426                	sd	s1,40(sp)
    41d8:	f04a                	sd	s2,32(sp)
    41da:	ec4e                	sd	s3,24(sp)
    41dc:	e852                	sd	s4,16(sp)
    41de:	0080                	addi	s0,sp,64
    41e0:	8a2a                	mv	s4,a0
    41e2:	06400913          	li	s2,100
    if(xst != -1) {
    41e6:	59fd                	li	s3,-1
    int pid1 = fork();
    41e8:	00001097          	auipc	ra,0x1
    41ec:	798080e7          	jalr	1944(ra) # 5980 <fork>
    41f0:	84aa                	mv	s1,a0
    if(pid1 < 0){
    41f2:	02054f63          	bltz	a0,4230 <killstatus+0x60>
    if(pid1 == 0){
    41f6:	c939                	beqz	a0,424c <killstatus+0x7c>
    sleep(1);
    41f8:	4505                	li	a0,1
    41fa:	00002097          	auipc	ra,0x2
    41fe:	81e080e7          	jalr	-2018(ra) # 5a18 <sleep>
    kill(pid1);
    4202:	8526                	mv	a0,s1
    4204:	00001097          	auipc	ra,0x1
    4208:	7b4080e7          	jalr	1972(ra) # 59b8 <kill>
    wait(&xst);
    420c:	fcc40513          	addi	a0,s0,-52
    4210:	00001097          	auipc	ra,0x1
    4214:	780080e7          	jalr	1920(ra) # 5990 <wait>
    if(xst != -1) {
    4218:	fcc42783          	lw	a5,-52(s0)
    421c:	03379d63          	bne	a5,s3,4256 <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    4220:	397d                	addiw	s2,s2,-1
    4222:	fc0913e3          	bnez	s2,41e8 <killstatus+0x18>
  exit(0);
    4226:	4501                	li	a0,0
    4228:	00001097          	auipc	ra,0x1
    422c:	760080e7          	jalr	1888(ra) # 5988 <exit>
      printf("%s: fork failed\n", s);
    4230:	85d2                	mv	a1,s4
    4232:	00003517          	auipc	a0,0x3
    4236:	88e50513          	addi	a0,a0,-1906 # 6ac0 <malloc+0xcea>
    423a:	00002097          	auipc	ra,0x2
    423e:	ade080e7          	jalr	-1314(ra) # 5d18 <printf>
      exit(1);
    4242:	4505                	li	a0,1
    4244:	00001097          	auipc	ra,0x1
    4248:	744080e7          	jalr	1860(ra) # 5988 <exit>
        getpid();
    424c:	00001097          	auipc	ra,0x1
    4250:	7bc080e7          	jalr	1980(ra) # 5a08 <getpid>
      while(1) {
    4254:	bfe5                	j	424c <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    4256:	85d2                	mv	a1,s4
    4258:	00004517          	auipc	a0,0x4
    425c:	ae850513          	addi	a0,a0,-1304 # 7d40 <malloc+0x1f6a>
    4260:	00002097          	auipc	ra,0x2
    4264:	ab8080e7          	jalr	-1352(ra) # 5d18 <printf>
       exit(1);
    4268:	4505                	li	a0,1
    426a:	00001097          	auipc	ra,0x1
    426e:	71e080e7          	jalr	1822(ra) # 5988 <exit>

0000000000004272 <preempt>:
{
    4272:	7139                	addi	sp,sp,-64
    4274:	fc06                	sd	ra,56(sp)
    4276:	f822                	sd	s0,48(sp)
    4278:	f426                	sd	s1,40(sp)
    427a:	f04a                	sd	s2,32(sp)
    427c:	ec4e                	sd	s3,24(sp)
    427e:	e852                	sd	s4,16(sp)
    4280:	0080                	addi	s0,sp,64
    4282:	892a                	mv	s2,a0
  pid1 = fork();
    4284:	00001097          	auipc	ra,0x1
    4288:	6fc080e7          	jalr	1788(ra) # 5980 <fork>
  if(pid1 < 0) {
    428c:	00054563          	bltz	a0,4296 <preempt+0x24>
    4290:	84aa                	mv	s1,a0
  if(pid1 == 0)
    4292:	e105                	bnez	a0,42b2 <preempt+0x40>
    for(;;)
    4294:	a001                	j	4294 <preempt+0x22>
    printf("%s: fork failed", s);
    4296:	85ca                	mv	a1,s2
    4298:	00003517          	auipc	a0,0x3
    429c:	9e850513          	addi	a0,a0,-1560 # 6c80 <malloc+0xeaa>
    42a0:	00002097          	auipc	ra,0x2
    42a4:	a78080e7          	jalr	-1416(ra) # 5d18 <printf>
    exit(1);
    42a8:	4505                	li	a0,1
    42aa:	00001097          	auipc	ra,0x1
    42ae:	6de080e7          	jalr	1758(ra) # 5988 <exit>
  pid2 = fork();
    42b2:	00001097          	auipc	ra,0x1
    42b6:	6ce080e7          	jalr	1742(ra) # 5980 <fork>
    42ba:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    42bc:	00054463          	bltz	a0,42c4 <preempt+0x52>
  if(pid2 == 0)
    42c0:	e105                	bnez	a0,42e0 <preempt+0x6e>
    for(;;)
    42c2:	a001                	j	42c2 <preempt+0x50>
    printf("%s: fork failed\n", s);
    42c4:	85ca                	mv	a1,s2
    42c6:	00002517          	auipc	a0,0x2
    42ca:	7fa50513          	addi	a0,a0,2042 # 6ac0 <malloc+0xcea>
    42ce:	00002097          	auipc	ra,0x2
    42d2:	a4a080e7          	jalr	-1462(ra) # 5d18 <printf>
    exit(1);
    42d6:	4505                	li	a0,1
    42d8:	00001097          	auipc	ra,0x1
    42dc:	6b0080e7          	jalr	1712(ra) # 5988 <exit>
  pipe(pfds);
    42e0:	fc840513          	addi	a0,s0,-56
    42e4:	00001097          	auipc	ra,0x1
    42e8:	6b4080e7          	jalr	1716(ra) # 5998 <pipe>
  pid3 = fork();
    42ec:	00001097          	auipc	ra,0x1
    42f0:	694080e7          	jalr	1684(ra) # 5980 <fork>
    42f4:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    42f6:	02054e63          	bltz	a0,4332 <preempt+0xc0>
  if(pid3 == 0){
    42fa:	e525                	bnez	a0,4362 <preempt+0xf0>
    close(pfds[0]);
    42fc:	fc842503          	lw	a0,-56(s0)
    4300:	00001097          	auipc	ra,0x1
    4304:	6b0080e7          	jalr	1712(ra) # 59b0 <close>
    if(write(pfds[1], "x", 1) != 1)
    4308:	4605                	li	a2,1
    430a:	00002597          	auipc	a1,0x2
    430e:	fce58593          	addi	a1,a1,-50 # 62d8 <malloc+0x502>
    4312:	fcc42503          	lw	a0,-52(s0)
    4316:	00001097          	auipc	ra,0x1
    431a:	692080e7          	jalr	1682(ra) # 59a8 <write>
    431e:	4785                	li	a5,1
    4320:	02f51763          	bne	a0,a5,434e <preempt+0xdc>
    close(pfds[1]);
    4324:	fcc42503          	lw	a0,-52(s0)
    4328:	00001097          	auipc	ra,0x1
    432c:	688080e7          	jalr	1672(ra) # 59b0 <close>
    for(;;)
    4330:	a001                	j	4330 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    4332:	85ca                	mv	a1,s2
    4334:	00002517          	auipc	a0,0x2
    4338:	78c50513          	addi	a0,a0,1932 # 6ac0 <malloc+0xcea>
    433c:	00002097          	auipc	ra,0x2
    4340:	9dc080e7          	jalr	-1572(ra) # 5d18 <printf>
     exit(1);
    4344:	4505                	li	a0,1
    4346:	00001097          	auipc	ra,0x1
    434a:	642080e7          	jalr	1602(ra) # 5988 <exit>
      printf("%s: preempt write error", s);
    434e:	85ca                	mv	a1,s2
    4350:	00004517          	auipc	a0,0x4
    4354:	a1050513          	addi	a0,a0,-1520 # 7d60 <malloc+0x1f8a>
    4358:	00002097          	auipc	ra,0x2
    435c:	9c0080e7          	jalr	-1600(ra) # 5d18 <printf>
    4360:	b7d1                	j	4324 <preempt+0xb2>
  close(pfds[1]);
    4362:	fcc42503          	lw	a0,-52(s0)
    4366:	00001097          	auipc	ra,0x1
    436a:	64a080e7          	jalr	1610(ra) # 59b0 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    436e:	660d                	lui	a2,0x3
    4370:	00008597          	auipc	a1,0x8
    4374:	bb058593          	addi	a1,a1,-1104 # bf20 <buf>
    4378:	fc842503          	lw	a0,-56(s0)
    437c:	00001097          	auipc	ra,0x1
    4380:	624080e7          	jalr	1572(ra) # 59a0 <read>
    4384:	4785                	li	a5,1
    4386:	02f50363          	beq	a0,a5,43ac <preempt+0x13a>
    printf("%s: preempt read error", s);
    438a:	85ca                	mv	a1,s2
    438c:	00004517          	auipc	a0,0x4
    4390:	9ec50513          	addi	a0,a0,-1556 # 7d78 <malloc+0x1fa2>
    4394:	00002097          	auipc	ra,0x2
    4398:	984080e7          	jalr	-1660(ra) # 5d18 <printf>
}
    439c:	70e2                	ld	ra,56(sp)
    439e:	7442                	ld	s0,48(sp)
    43a0:	74a2                	ld	s1,40(sp)
    43a2:	7902                	ld	s2,32(sp)
    43a4:	69e2                	ld	s3,24(sp)
    43a6:	6a42                	ld	s4,16(sp)
    43a8:	6121                	addi	sp,sp,64
    43aa:	8082                	ret
  close(pfds[0]);
    43ac:	fc842503          	lw	a0,-56(s0)
    43b0:	00001097          	auipc	ra,0x1
    43b4:	600080e7          	jalr	1536(ra) # 59b0 <close>
  printf("kill... ");
    43b8:	00004517          	auipc	a0,0x4
    43bc:	9d850513          	addi	a0,a0,-1576 # 7d90 <malloc+0x1fba>
    43c0:	00002097          	auipc	ra,0x2
    43c4:	958080e7          	jalr	-1704(ra) # 5d18 <printf>
  kill(pid1);
    43c8:	8526                	mv	a0,s1
    43ca:	00001097          	auipc	ra,0x1
    43ce:	5ee080e7          	jalr	1518(ra) # 59b8 <kill>
  kill(pid2);
    43d2:	854e                	mv	a0,s3
    43d4:	00001097          	auipc	ra,0x1
    43d8:	5e4080e7          	jalr	1508(ra) # 59b8 <kill>
  kill(pid3);
    43dc:	8552                	mv	a0,s4
    43de:	00001097          	auipc	ra,0x1
    43e2:	5da080e7          	jalr	1498(ra) # 59b8 <kill>
  printf("wait... ");
    43e6:	00004517          	auipc	a0,0x4
    43ea:	9ba50513          	addi	a0,a0,-1606 # 7da0 <malloc+0x1fca>
    43ee:	00002097          	auipc	ra,0x2
    43f2:	92a080e7          	jalr	-1750(ra) # 5d18 <printf>
  wait(0);
    43f6:	4501                	li	a0,0
    43f8:	00001097          	auipc	ra,0x1
    43fc:	598080e7          	jalr	1432(ra) # 5990 <wait>
  wait(0);
    4400:	4501                	li	a0,0
    4402:	00001097          	auipc	ra,0x1
    4406:	58e080e7          	jalr	1422(ra) # 5990 <wait>
  wait(0);
    440a:	4501                	li	a0,0
    440c:	00001097          	auipc	ra,0x1
    4410:	584080e7          	jalr	1412(ra) # 5990 <wait>
    4414:	b761                	j	439c <preempt+0x12a>

0000000000004416 <reparent>:
{
    4416:	7179                	addi	sp,sp,-48
    4418:	f406                	sd	ra,40(sp)
    441a:	f022                	sd	s0,32(sp)
    441c:	ec26                	sd	s1,24(sp)
    441e:	e84a                	sd	s2,16(sp)
    4420:	e44e                	sd	s3,8(sp)
    4422:	e052                	sd	s4,0(sp)
    4424:	1800                	addi	s0,sp,48
    4426:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4428:	00001097          	auipc	ra,0x1
    442c:	5e0080e7          	jalr	1504(ra) # 5a08 <getpid>
    4430:	8a2a                	mv	s4,a0
    4432:	0c800913          	li	s2,200
    int pid = fork();
    4436:	00001097          	auipc	ra,0x1
    443a:	54a080e7          	jalr	1354(ra) # 5980 <fork>
    443e:	84aa                	mv	s1,a0
    if(pid < 0){
    4440:	02054263          	bltz	a0,4464 <reparent+0x4e>
    if(pid){
    4444:	cd21                	beqz	a0,449c <reparent+0x86>
      if(wait(0) != pid){
    4446:	4501                	li	a0,0
    4448:	00001097          	auipc	ra,0x1
    444c:	548080e7          	jalr	1352(ra) # 5990 <wait>
    4450:	02951863          	bne	a0,s1,4480 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4454:	397d                	addiw	s2,s2,-1
    4456:	fe0910e3          	bnez	s2,4436 <reparent+0x20>
  exit(0);
    445a:	4501                	li	a0,0
    445c:	00001097          	auipc	ra,0x1
    4460:	52c080e7          	jalr	1324(ra) # 5988 <exit>
      printf("%s: fork failed\n", s);
    4464:	85ce                	mv	a1,s3
    4466:	00002517          	auipc	a0,0x2
    446a:	65a50513          	addi	a0,a0,1626 # 6ac0 <malloc+0xcea>
    446e:	00002097          	auipc	ra,0x2
    4472:	8aa080e7          	jalr	-1878(ra) # 5d18 <printf>
      exit(1);
    4476:	4505                	li	a0,1
    4478:	00001097          	auipc	ra,0x1
    447c:	510080e7          	jalr	1296(ra) # 5988 <exit>
        printf("%s: wait wrong pid\n", s);
    4480:	85ce                	mv	a1,s3
    4482:	00002517          	auipc	a0,0x2
    4486:	7c650513          	addi	a0,a0,1990 # 6c48 <malloc+0xe72>
    448a:	00002097          	auipc	ra,0x2
    448e:	88e080e7          	jalr	-1906(ra) # 5d18 <printf>
        exit(1);
    4492:	4505                	li	a0,1
    4494:	00001097          	auipc	ra,0x1
    4498:	4f4080e7          	jalr	1268(ra) # 5988 <exit>
      int pid2 = fork();
    449c:	00001097          	auipc	ra,0x1
    44a0:	4e4080e7          	jalr	1252(ra) # 5980 <fork>
      if(pid2 < 0){
    44a4:	00054763          	bltz	a0,44b2 <reparent+0x9c>
      exit(0);
    44a8:	4501                	li	a0,0
    44aa:	00001097          	auipc	ra,0x1
    44ae:	4de080e7          	jalr	1246(ra) # 5988 <exit>
        kill(master_pid);
    44b2:	8552                	mv	a0,s4
    44b4:	00001097          	auipc	ra,0x1
    44b8:	504080e7          	jalr	1284(ra) # 59b8 <kill>
        exit(1);
    44bc:	4505                	li	a0,1
    44be:	00001097          	auipc	ra,0x1
    44c2:	4ca080e7          	jalr	1226(ra) # 5988 <exit>

00000000000044c6 <sbrkfail>:
{
    44c6:	7119                	addi	sp,sp,-128
    44c8:	fc86                	sd	ra,120(sp)
    44ca:	f8a2                	sd	s0,112(sp)
    44cc:	f4a6                	sd	s1,104(sp)
    44ce:	f0ca                	sd	s2,96(sp)
    44d0:	ecce                	sd	s3,88(sp)
    44d2:	e8d2                	sd	s4,80(sp)
    44d4:	e4d6                	sd	s5,72(sp)
    44d6:	0100                	addi	s0,sp,128
    44d8:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    44da:	fb040513          	addi	a0,s0,-80
    44de:	00001097          	auipc	ra,0x1
    44e2:	4ba080e7          	jalr	1210(ra) # 5998 <pipe>
    44e6:	e901                	bnez	a0,44f6 <sbrkfail+0x30>
    44e8:	f8040493          	addi	s1,s0,-128
    44ec:	fa840993          	addi	s3,s0,-88
    44f0:	8926                	mv	s2,s1
    if(pids[i] != -1)
    44f2:	5a7d                	li	s4,-1
    44f4:	a085                	j	4554 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    44f6:	85d6                	mv	a1,s5
    44f8:	00002517          	auipc	a0,0x2
    44fc:	6d050513          	addi	a0,a0,1744 # 6bc8 <malloc+0xdf2>
    4500:	00002097          	auipc	ra,0x2
    4504:	818080e7          	jalr	-2024(ra) # 5d18 <printf>
    exit(1);
    4508:	4505                	li	a0,1
    450a:	00001097          	auipc	ra,0x1
    450e:	47e080e7          	jalr	1150(ra) # 5988 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    4512:	00001097          	auipc	ra,0x1
    4516:	4fe080e7          	jalr	1278(ra) # 5a10 <sbrk>
    451a:	064007b7          	lui	a5,0x6400
    451e:	40a7853b          	subw	a0,a5,a0
    4522:	00001097          	auipc	ra,0x1
    4526:	4ee080e7          	jalr	1262(ra) # 5a10 <sbrk>
      write(fds[1], "x", 1);
    452a:	4605                	li	a2,1
    452c:	00002597          	auipc	a1,0x2
    4530:	dac58593          	addi	a1,a1,-596 # 62d8 <malloc+0x502>
    4534:	fb442503          	lw	a0,-76(s0)
    4538:	00001097          	auipc	ra,0x1
    453c:	470080e7          	jalr	1136(ra) # 59a8 <write>
      for(;;) sleep(1000);
    4540:	3e800513          	li	a0,1000
    4544:	00001097          	auipc	ra,0x1
    4548:	4d4080e7          	jalr	1236(ra) # 5a18 <sleep>
    454c:	bfd5                	j	4540 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    454e:	0911                	addi	s2,s2,4
    4550:	03390563          	beq	s2,s3,457a <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    4554:	00001097          	auipc	ra,0x1
    4558:	42c080e7          	jalr	1068(ra) # 5980 <fork>
    455c:	00a92023          	sw	a0,0(s2)
    4560:	d94d                	beqz	a0,4512 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4562:	ff4506e3          	beq	a0,s4,454e <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4566:	4605                	li	a2,1
    4568:	faf40593          	addi	a1,s0,-81
    456c:	fb042503          	lw	a0,-80(s0)
    4570:	00001097          	auipc	ra,0x1
    4574:	430080e7          	jalr	1072(ra) # 59a0 <read>
    4578:	bfd9                	j	454e <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    457a:	6505                	lui	a0,0x1
    457c:	00001097          	auipc	ra,0x1
    4580:	494080e7          	jalr	1172(ra) # 5a10 <sbrk>
    4584:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    4586:	597d                	li	s2,-1
    4588:	a021                	j	4590 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    458a:	0491                	addi	s1,s1,4
    458c:	01348f63          	beq	s1,s3,45aa <sbrkfail+0xe4>
    if(pids[i] == -1)
    4590:	4088                	lw	a0,0(s1)
    4592:	ff250ce3          	beq	a0,s2,458a <sbrkfail+0xc4>
    kill(pids[i]);
    4596:	00001097          	auipc	ra,0x1
    459a:	422080e7          	jalr	1058(ra) # 59b8 <kill>
    wait(0);
    459e:	4501                	li	a0,0
    45a0:	00001097          	auipc	ra,0x1
    45a4:	3f0080e7          	jalr	1008(ra) # 5990 <wait>
    45a8:	b7cd                	j	458a <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    45aa:	57fd                	li	a5,-1
    45ac:	04fa0163          	beq	s4,a5,45ee <sbrkfail+0x128>
  pid = fork();
    45b0:	00001097          	auipc	ra,0x1
    45b4:	3d0080e7          	jalr	976(ra) # 5980 <fork>
    45b8:	84aa                	mv	s1,a0
  if(pid < 0){
    45ba:	04054863          	bltz	a0,460a <sbrkfail+0x144>
  if(pid == 0){
    45be:	c525                	beqz	a0,4626 <sbrkfail+0x160>
  wait(&xstatus);
    45c0:	fbc40513          	addi	a0,s0,-68
    45c4:	00001097          	auipc	ra,0x1
    45c8:	3cc080e7          	jalr	972(ra) # 5990 <wait>
  if(xstatus != -1 && xstatus != 2)
    45cc:	fbc42783          	lw	a5,-68(s0)
    45d0:	577d                	li	a4,-1
    45d2:	00e78563          	beq	a5,a4,45dc <sbrkfail+0x116>
    45d6:	4709                	li	a4,2
    45d8:	08e79d63          	bne	a5,a4,4672 <sbrkfail+0x1ac>
}
    45dc:	70e6                	ld	ra,120(sp)
    45de:	7446                	ld	s0,112(sp)
    45e0:	74a6                	ld	s1,104(sp)
    45e2:	7906                	ld	s2,96(sp)
    45e4:	69e6                	ld	s3,88(sp)
    45e6:	6a46                	ld	s4,80(sp)
    45e8:	6aa6                	ld	s5,72(sp)
    45ea:	6109                	addi	sp,sp,128
    45ec:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    45ee:	85d6                	mv	a1,s5
    45f0:	00003517          	auipc	a0,0x3
    45f4:	7c050513          	addi	a0,a0,1984 # 7db0 <malloc+0x1fda>
    45f8:	00001097          	auipc	ra,0x1
    45fc:	720080e7          	jalr	1824(ra) # 5d18 <printf>
    exit(1);
    4600:	4505                	li	a0,1
    4602:	00001097          	auipc	ra,0x1
    4606:	386080e7          	jalr	902(ra) # 5988 <exit>
    printf("%s: fork failed\n", s);
    460a:	85d6                	mv	a1,s5
    460c:	00002517          	auipc	a0,0x2
    4610:	4b450513          	addi	a0,a0,1204 # 6ac0 <malloc+0xcea>
    4614:	00001097          	auipc	ra,0x1
    4618:	704080e7          	jalr	1796(ra) # 5d18 <printf>
    exit(1);
    461c:	4505                	li	a0,1
    461e:	00001097          	auipc	ra,0x1
    4622:	36a080e7          	jalr	874(ra) # 5988 <exit>
    a = sbrk(0);
    4626:	4501                	li	a0,0
    4628:	00001097          	auipc	ra,0x1
    462c:	3e8080e7          	jalr	1000(ra) # 5a10 <sbrk>
    4630:	892a                	mv	s2,a0
    sbrk(10*BIG);
    4632:	3e800537          	lui	a0,0x3e800
    4636:	00001097          	auipc	ra,0x1
    463a:	3da080e7          	jalr	986(ra) # 5a10 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    463e:	87ca                	mv	a5,s2
    4640:	3e800737          	lui	a4,0x3e800
    4644:	993a                	add	s2,s2,a4
    4646:	6705                	lui	a4,0x1
      n += *(a+i);
    4648:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f10d0>
    464c:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    464e:	97ba                	add	a5,a5,a4
    4650:	ff279ce3          	bne	a5,s2,4648 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4654:	8626                	mv	a2,s1
    4656:	85d6                	mv	a1,s5
    4658:	00003517          	auipc	a0,0x3
    465c:	77850513          	addi	a0,a0,1912 # 7dd0 <malloc+0x1ffa>
    4660:	00001097          	auipc	ra,0x1
    4664:	6b8080e7          	jalr	1720(ra) # 5d18 <printf>
    exit(1);
    4668:	4505                	li	a0,1
    466a:	00001097          	auipc	ra,0x1
    466e:	31e080e7          	jalr	798(ra) # 5988 <exit>
    exit(1);
    4672:	4505                	li	a0,1
    4674:	00001097          	auipc	ra,0x1
    4678:	314080e7          	jalr	788(ra) # 5988 <exit>

000000000000467c <mem>:
{
    467c:	7139                	addi	sp,sp,-64
    467e:	fc06                	sd	ra,56(sp)
    4680:	f822                	sd	s0,48(sp)
    4682:	f426                	sd	s1,40(sp)
    4684:	f04a                	sd	s2,32(sp)
    4686:	ec4e                	sd	s3,24(sp)
    4688:	0080                	addi	s0,sp,64
    468a:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    468c:	00001097          	auipc	ra,0x1
    4690:	2f4080e7          	jalr	756(ra) # 5980 <fork>
    m1 = 0;
    4694:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4696:	6909                	lui	s2,0x2
    4698:	71190913          	addi	s2,s2,1809 # 2711 <rwsbrk+0xbf>
  if((pid = fork()) == 0){
    469c:	c115                	beqz	a0,46c0 <mem+0x44>
    wait(&xstatus);
    469e:	fcc40513          	addi	a0,s0,-52
    46a2:	00001097          	auipc	ra,0x1
    46a6:	2ee080e7          	jalr	750(ra) # 5990 <wait>
    if(xstatus == -1){
    46aa:	fcc42503          	lw	a0,-52(s0)
    46ae:	57fd                	li	a5,-1
    46b0:	06f50363          	beq	a0,a5,4716 <mem+0x9a>
    exit(xstatus);
    46b4:	00001097          	auipc	ra,0x1
    46b8:	2d4080e7          	jalr	724(ra) # 5988 <exit>
      *(char**)m2 = m1;
    46bc:	e104                	sd	s1,0(a0)
      m1 = m2;
    46be:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    46c0:	854a                	mv	a0,s2
    46c2:	00001097          	auipc	ra,0x1
    46c6:	714080e7          	jalr	1812(ra) # 5dd6 <malloc>
    46ca:	f96d                	bnez	a0,46bc <mem+0x40>
    while(m1){
    46cc:	c881                	beqz	s1,46dc <mem+0x60>
      m2 = *(char**)m1;
    46ce:	8526                	mv	a0,s1
    46d0:	6084                	ld	s1,0(s1)
      free(m1);
    46d2:	00001097          	auipc	ra,0x1
    46d6:	67c080e7          	jalr	1660(ra) # 5d4e <free>
    while(m1){
    46da:	f8f5                	bnez	s1,46ce <mem+0x52>
    m1 = malloc(1024*20);
    46dc:	6515                	lui	a0,0x5
    46de:	00001097          	auipc	ra,0x1
    46e2:	6f8080e7          	jalr	1784(ra) # 5dd6 <malloc>
    if(m1 == 0){
    46e6:	c911                	beqz	a0,46fa <mem+0x7e>
    free(m1);
    46e8:	00001097          	auipc	ra,0x1
    46ec:	666080e7          	jalr	1638(ra) # 5d4e <free>
    exit(0);
    46f0:	4501                	li	a0,0
    46f2:	00001097          	auipc	ra,0x1
    46f6:	296080e7          	jalr	662(ra) # 5988 <exit>
      printf("couldn't allocate mem?!!\n", s);
    46fa:	85ce                	mv	a1,s3
    46fc:	00003517          	auipc	a0,0x3
    4700:	70450513          	addi	a0,a0,1796 # 7e00 <malloc+0x202a>
    4704:	00001097          	auipc	ra,0x1
    4708:	614080e7          	jalr	1556(ra) # 5d18 <printf>
      exit(1);
    470c:	4505                	li	a0,1
    470e:	00001097          	auipc	ra,0x1
    4712:	27a080e7          	jalr	634(ra) # 5988 <exit>
      exit(0);
    4716:	4501                	li	a0,0
    4718:	00001097          	auipc	ra,0x1
    471c:	270080e7          	jalr	624(ra) # 5988 <exit>

0000000000004720 <sharedfd>:
{
    4720:	7159                	addi	sp,sp,-112
    4722:	f486                	sd	ra,104(sp)
    4724:	f0a2                	sd	s0,96(sp)
    4726:	eca6                	sd	s1,88(sp)
    4728:	e8ca                	sd	s2,80(sp)
    472a:	e4ce                	sd	s3,72(sp)
    472c:	e0d2                	sd	s4,64(sp)
    472e:	fc56                	sd	s5,56(sp)
    4730:	f85a                	sd	s6,48(sp)
    4732:	f45e                	sd	s7,40(sp)
    4734:	1880                	addi	s0,sp,112
    4736:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4738:	00002517          	auipc	a0,0x2
    473c:	93050513          	addi	a0,a0,-1744 # 6068 <malloc+0x292>
    4740:	00001097          	auipc	ra,0x1
    4744:	298080e7          	jalr	664(ra) # 59d8 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4748:	20200593          	li	a1,514
    474c:	00002517          	auipc	a0,0x2
    4750:	91c50513          	addi	a0,a0,-1764 # 6068 <malloc+0x292>
    4754:	00001097          	auipc	ra,0x1
    4758:	274080e7          	jalr	628(ra) # 59c8 <open>
  if(fd < 0){
    475c:	04054a63          	bltz	a0,47b0 <sharedfd+0x90>
    4760:	892a                	mv	s2,a0
  pid = fork();
    4762:	00001097          	auipc	ra,0x1
    4766:	21e080e7          	jalr	542(ra) # 5980 <fork>
    476a:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    476c:	06300593          	li	a1,99
    4770:	c119                	beqz	a0,4776 <sharedfd+0x56>
    4772:	07000593          	li	a1,112
    4776:	4629                	li	a2,10
    4778:	fa040513          	addi	a0,s0,-96
    477c:	00001097          	auipc	ra,0x1
    4780:	010080e7          	jalr	16(ra) # 578c <memset>
    4784:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    4788:	4629                	li	a2,10
    478a:	fa040593          	addi	a1,s0,-96
    478e:	854a                	mv	a0,s2
    4790:	00001097          	auipc	ra,0x1
    4794:	218080e7          	jalr	536(ra) # 59a8 <write>
    4798:	47a9                	li	a5,10
    479a:	02f51963          	bne	a0,a5,47cc <sharedfd+0xac>
  for(i = 0; i < N; i++){
    479e:	34fd                	addiw	s1,s1,-1
    47a0:	f4e5                	bnez	s1,4788 <sharedfd+0x68>
  if(pid == 0) {
    47a2:	04099363          	bnez	s3,47e8 <sharedfd+0xc8>
    exit(0);
    47a6:	4501                	li	a0,0
    47a8:	00001097          	auipc	ra,0x1
    47ac:	1e0080e7          	jalr	480(ra) # 5988 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    47b0:	85d2                	mv	a1,s4
    47b2:	00003517          	auipc	a0,0x3
    47b6:	66e50513          	addi	a0,a0,1646 # 7e20 <malloc+0x204a>
    47ba:	00001097          	auipc	ra,0x1
    47be:	55e080e7          	jalr	1374(ra) # 5d18 <printf>
    exit(1);
    47c2:	4505                	li	a0,1
    47c4:	00001097          	auipc	ra,0x1
    47c8:	1c4080e7          	jalr	452(ra) # 5988 <exit>
      printf("%s: write sharedfd failed\n", s);
    47cc:	85d2                	mv	a1,s4
    47ce:	00003517          	auipc	a0,0x3
    47d2:	67a50513          	addi	a0,a0,1658 # 7e48 <malloc+0x2072>
    47d6:	00001097          	auipc	ra,0x1
    47da:	542080e7          	jalr	1346(ra) # 5d18 <printf>
      exit(1);
    47de:	4505                	li	a0,1
    47e0:	00001097          	auipc	ra,0x1
    47e4:	1a8080e7          	jalr	424(ra) # 5988 <exit>
    wait(&xstatus);
    47e8:	f9c40513          	addi	a0,s0,-100
    47ec:	00001097          	auipc	ra,0x1
    47f0:	1a4080e7          	jalr	420(ra) # 5990 <wait>
    if(xstatus != 0)
    47f4:	f9c42983          	lw	s3,-100(s0)
    47f8:	00098763          	beqz	s3,4806 <sharedfd+0xe6>
      exit(xstatus);
    47fc:	854e                	mv	a0,s3
    47fe:	00001097          	auipc	ra,0x1
    4802:	18a080e7          	jalr	394(ra) # 5988 <exit>
  close(fd);
    4806:	854a                	mv	a0,s2
    4808:	00001097          	auipc	ra,0x1
    480c:	1a8080e7          	jalr	424(ra) # 59b0 <close>
  fd = open("sharedfd", 0);
    4810:	4581                	li	a1,0
    4812:	00002517          	auipc	a0,0x2
    4816:	85650513          	addi	a0,a0,-1962 # 6068 <malloc+0x292>
    481a:	00001097          	auipc	ra,0x1
    481e:	1ae080e7          	jalr	430(ra) # 59c8 <open>
    4822:	8baa                	mv	s7,a0
  nc = np = 0;
    4824:	8ace                	mv	s5,s3
  if(fd < 0){
    4826:	02054563          	bltz	a0,4850 <sharedfd+0x130>
    482a:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    482e:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4832:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4836:	4629                	li	a2,10
    4838:	fa040593          	addi	a1,s0,-96
    483c:	855e                	mv	a0,s7
    483e:	00001097          	auipc	ra,0x1
    4842:	162080e7          	jalr	354(ra) # 59a0 <read>
    4846:	02a05f63          	blez	a0,4884 <sharedfd+0x164>
    484a:	fa040793          	addi	a5,s0,-96
    484e:	a01d                	j	4874 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4850:	85d2                	mv	a1,s4
    4852:	00003517          	auipc	a0,0x3
    4856:	61650513          	addi	a0,a0,1558 # 7e68 <malloc+0x2092>
    485a:	00001097          	auipc	ra,0x1
    485e:	4be080e7          	jalr	1214(ra) # 5d18 <printf>
    exit(1);
    4862:	4505                	li	a0,1
    4864:	00001097          	auipc	ra,0x1
    4868:	124080e7          	jalr	292(ra) # 5988 <exit>
        nc++;
    486c:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    486e:	0785                	addi	a5,a5,1
    4870:	fd2783e3          	beq	a5,s2,4836 <sharedfd+0x116>
      if(buf[i] == 'c')
    4874:	0007c703          	lbu	a4,0(a5)
    4878:	fe970ae3          	beq	a4,s1,486c <sharedfd+0x14c>
      if(buf[i] == 'p')
    487c:	ff6719e3          	bne	a4,s6,486e <sharedfd+0x14e>
        np++;
    4880:	2a85                	addiw	s5,s5,1
    4882:	b7f5                	j	486e <sharedfd+0x14e>
  close(fd);
    4884:	855e                	mv	a0,s7
    4886:	00001097          	auipc	ra,0x1
    488a:	12a080e7          	jalr	298(ra) # 59b0 <close>
  unlink("sharedfd");
    488e:	00001517          	auipc	a0,0x1
    4892:	7da50513          	addi	a0,a0,2010 # 6068 <malloc+0x292>
    4896:	00001097          	auipc	ra,0x1
    489a:	142080e7          	jalr	322(ra) # 59d8 <unlink>
  if(nc == N*SZ && np == N*SZ){
    489e:	6789                	lui	a5,0x2
    48a0:	71078793          	addi	a5,a5,1808 # 2710 <rwsbrk+0xbe>
    48a4:	00f99763          	bne	s3,a5,48b2 <sharedfd+0x192>
    48a8:	6789                	lui	a5,0x2
    48aa:	71078793          	addi	a5,a5,1808 # 2710 <rwsbrk+0xbe>
    48ae:	02fa8063          	beq	s5,a5,48ce <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    48b2:	85d2                	mv	a1,s4
    48b4:	00003517          	auipc	a0,0x3
    48b8:	5dc50513          	addi	a0,a0,1500 # 7e90 <malloc+0x20ba>
    48bc:	00001097          	auipc	ra,0x1
    48c0:	45c080e7          	jalr	1116(ra) # 5d18 <printf>
    exit(1);
    48c4:	4505                	li	a0,1
    48c6:	00001097          	auipc	ra,0x1
    48ca:	0c2080e7          	jalr	194(ra) # 5988 <exit>
    exit(0);
    48ce:	4501                	li	a0,0
    48d0:	00001097          	auipc	ra,0x1
    48d4:	0b8080e7          	jalr	184(ra) # 5988 <exit>

00000000000048d8 <fourfiles>:
{
    48d8:	7171                	addi	sp,sp,-176
    48da:	f506                	sd	ra,168(sp)
    48dc:	f122                	sd	s0,160(sp)
    48de:	ed26                	sd	s1,152(sp)
    48e0:	e94a                	sd	s2,144(sp)
    48e2:	e54e                	sd	s3,136(sp)
    48e4:	e152                	sd	s4,128(sp)
    48e6:	fcd6                	sd	s5,120(sp)
    48e8:	f8da                	sd	s6,112(sp)
    48ea:	f4de                	sd	s7,104(sp)
    48ec:	f0e2                	sd	s8,96(sp)
    48ee:	ece6                	sd	s9,88(sp)
    48f0:	e8ea                	sd	s10,80(sp)
    48f2:	e4ee                	sd	s11,72(sp)
    48f4:	1900                	addi	s0,sp,176
    48f6:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    48fa:	00001797          	auipc	a5,0x1
    48fe:	5c678793          	addi	a5,a5,1478 # 5ec0 <malloc+0xea>
    4902:	f6f43823          	sd	a5,-144(s0)
    4906:	00001797          	auipc	a5,0x1
    490a:	5c278793          	addi	a5,a5,1474 # 5ec8 <malloc+0xf2>
    490e:	f6f43c23          	sd	a5,-136(s0)
    4912:	00001797          	auipc	a5,0x1
    4916:	5be78793          	addi	a5,a5,1470 # 5ed0 <malloc+0xfa>
    491a:	f8f43023          	sd	a5,-128(s0)
    491e:	00001797          	auipc	a5,0x1
    4922:	5ba78793          	addi	a5,a5,1466 # 5ed8 <malloc+0x102>
    4926:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    492a:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    492e:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    4930:	4481                	li	s1,0
    4932:	4a11                	li	s4,4
    fname = names[pi];
    4934:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4938:	854e                	mv	a0,s3
    493a:	00001097          	auipc	ra,0x1
    493e:	09e080e7          	jalr	158(ra) # 59d8 <unlink>
    pid = fork();
    4942:	00001097          	auipc	ra,0x1
    4946:	03e080e7          	jalr	62(ra) # 5980 <fork>
    if(pid < 0){
    494a:	04054463          	bltz	a0,4992 <fourfiles+0xba>
    if(pid == 0){
    494e:	c12d                	beqz	a0,49b0 <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    4950:	2485                	addiw	s1,s1,1
    4952:	0921                	addi	s2,s2,8
    4954:	ff4490e3          	bne	s1,s4,4934 <fourfiles+0x5c>
    4958:	4491                	li	s1,4
    wait(&xstatus);
    495a:	f6c40513          	addi	a0,s0,-148
    495e:	00001097          	auipc	ra,0x1
    4962:	032080e7          	jalr	50(ra) # 5990 <wait>
    if(xstatus != 0)
    4966:	f6c42b03          	lw	s6,-148(s0)
    496a:	0c0b1e63          	bnez	s6,4a46 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    496e:	34fd                	addiw	s1,s1,-1
    4970:	f4ed                	bnez	s1,495a <fourfiles+0x82>
    4972:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4976:	00007a17          	auipc	s4,0x7
    497a:	5aaa0a13          	addi	s4,s4,1450 # bf20 <buf>
    497e:	00007a97          	auipc	s5,0x7
    4982:	5a3a8a93          	addi	s5,s5,1443 # bf21 <buf+0x1>
    if(total != N*SZ){
    4986:	6d85                	lui	s11,0x1
    4988:	770d8d93          	addi	s11,s11,1904 # 1770 <exectest+0xc8>
  for(i = 0; i < NCHILD; i++){
    498c:	03400d13          	li	s10,52
    4990:	aa1d                	j	4ac6 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    4992:	f5843583          	ld	a1,-168(s0)
    4996:	00002517          	auipc	a0,0x2
    499a:	54a50513          	addi	a0,a0,1354 # 6ee0 <malloc+0x110a>
    499e:	00001097          	auipc	ra,0x1
    49a2:	37a080e7          	jalr	890(ra) # 5d18 <printf>
      exit(1);
    49a6:	4505                	li	a0,1
    49a8:	00001097          	auipc	ra,0x1
    49ac:	fe0080e7          	jalr	-32(ra) # 5988 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    49b0:	20200593          	li	a1,514
    49b4:	854e                	mv	a0,s3
    49b6:	00001097          	auipc	ra,0x1
    49ba:	012080e7          	jalr	18(ra) # 59c8 <open>
    49be:	892a                	mv	s2,a0
      if(fd < 0){
    49c0:	04054763          	bltz	a0,4a0e <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    49c4:	1f400613          	li	a2,500
    49c8:	0304859b          	addiw	a1,s1,48
    49cc:	00007517          	auipc	a0,0x7
    49d0:	55450513          	addi	a0,a0,1364 # bf20 <buf>
    49d4:	00001097          	auipc	ra,0x1
    49d8:	db8080e7          	jalr	-584(ra) # 578c <memset>
    49dc:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    49de:	00007997          	auipc	s3,0x7
    49e2:	54298993          	addi	s3,s3,1346 # bf20 <buf>
    49e6:	1f400613          	li	a2,500
    49ea:	85ce                	mv	a1,s3
    49ec:	854a                	mv	a0,s2
    49ee:	00001097          	auipc	ra,0x1
    49f2:	fba080e7          	jalr	-70(ra) # 59a8 <write>
    49f6:	85aa                	mv	a1,a0
    49f8:	1f400793          	li	a5,500
    49fc:	02f51863          	bne	a0,a5,4a2c <fourfiles+0x154>
      for(i = 0; i < N; i++){
    4a00:	34fd                	addiw	s1,s1,-1
    4a02:	f0f5                	bnez	s1,49e6 <fourfiles+0x10e>
      exit(0);
    4a04:	4501                	li	a0,0
    4a06:	00001097          	auipc	ra,0x1
    4a0a:	f82080e7          	jalr	-126(ra) # 5988 <exit>
        printf("create failed\n", s);
    4a0e:	f5843583          	ld	a1,-168(s0)
    4a12:	00003517          	auipc	a0,0x3
    4a16:	49650513          	addi	a0,a0,1174 # 7ea8 <malloc+0x20d2>
    4a1a:	00001097          	auipc	ra,0x1
    4a1e:	2fe080e7          	jalr	766(ra) # 5d18 <printf>
        exit(1);
    4a22:	4505                	li	a0,1
    4a24:	00001097          	auipc	ra,0x1
    4a28:	f64080e7          	jalr	-156(ra) # 5988 <exit>
          printf("write failed %d\n", n);
    4a2c:	00003517          	auipc	a0,0x3
    4a30:	48c50513          	addi	a0,a0,1164 # 7eb8 <malloc+0x20e2>
    4a34:	00001097          	auipc	ra,0x1
    4a38:	2e4080e7          	jalr	740(ra) # 5d18 <printf>
          exit(1);
    4a3c:	4505                	li	a0,1
    4a3e:	00001097          	auipc	ra,0x1
    4a42:	f4a080e7          	jalr	-182(ra) # 5988 <exit>
      exit(xstatus);
    4a46:	855a                	mv	a0,s6
    4a48:	00001097          	auipc	ra,0x1
    4a4c:	f40080e7          	jalr	-192(ra) # 5988 <exit>
          printf("wrong char\n", s);
    4a50:	f5843583          	ld	a1,-168(s0)
    4a54:	00003517          	auipc	a0,0x3
    4a58:	47c50513          	addi	a0,a0,1148 # 7ed0 <malloc+0x20fa>
    4a5c:	00001097          	auipc	ra,0x1
    4a60:	2bc080e7          	jalr	700(ra) # 5d18 <printf>
          exit(1);
    4a64:	4505                	li	a0,1
    4a66:	00001097          	auipc	ra,0x1
    4a6a:	f22080e7          	jalr	-222(ra) # 5988 <exit>
      total += n;
    4a6e:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4a72:	660d                	lui	a2,0x3
    4a74:	85d2                	mv	a1,s4
    4a76:	854e                	mv	a0,s3
    4a78:	00001097          	auipc	ra,0x1
    4a7c:	f28080e7          	jalr	-216(ra) # 59a0 <read>
    4a80:	02a05363          	blez	a0,4aa6 <fourfiles+0x1ce>
    4a84:	00007797          	auipc	a5,0x7
    4a88:	49c78793          	addi	a5,a5,1180 # bf20 <buf>
    4a8c:	fff5069b          	addiw	a3,a0,-1
    4a90:	1682                	slli	a3,a3,0x20
    4a92:	9281                	srli	a3,a3,0x20
    4a94:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    4a96:	0007c703          	lbu	a4,0(a5)
    4a9a:	fa971be3          	bne	a4,s1,4a50 <fourfiles+0x178>
      for(j = 0; j < n; j++){
    4a9e:	0785                	addi	a5,a5,1
    4aa0:	fed79be3          	bne	a5,a3,4a96 <fourfiles+0x1be>
    4aa4:	b7e9                	j	4a6e <fourfiles+0x196>
    close(fd);
    4aa6:	854e                	mv	a0,s3
    4aa8:	00001097          	auipc	ra,0x1
    4aac:	f08080e7          	jalr	-248(ra) # 59b0 <close>
    if(total != N*SZ){
    4ab0:	03b91863          	bne	s2,s11,4ae0 <fourfiles+0x208>
    unlink(fname);
    4ab4:	8566                	mv	a0,s9
    4ab6:	00001097          	auipc	ra,0x1
    4aba:	f22080e7          	jalr	-222(ra) # 59d8 <unlink>
  for(i = 0; i < NCHILD; i++){
    4abe:	0c21                	addi	s8,s8,8
    4ac0:	2b85                	addiw	s7,s7,1
    4ac2:	03ab8d63          	beq	s7,s10,4afc <fourfiles+0x224>
    fname = names[i];
    4ac6:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    4aca:	4581                	li	a1,0
    4acc:	8566                	mv	a0,s9
    4ace:	00001097          	auipc	ra,0x1
    4ad2:	efa080e7          	jalr	-262(ra) # 59c8 <open>
    4ad6:	89aa                	mv	s3,a0
    total = 0;
    4ad8:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    4ada:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4ade:	bf51                	j	4a72 <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    4ae0:	85ca                	mv	a1,s2
    4ae2:	00003517          	auipc	a0,0x3
    4ae6:	3fe50513          	addi	a0,a0,1022 # 7ee0 <malloc+0x210a>
    4aea:	00001097          	auipc	ra,0x1
    4aee:	22e080e7          	jalr	558(ra) # 5d18 <printf>
      exit(1);
    4af2:	4505                	li	a0,1
    4af4:	00001097          	auipc	ra,0x1
    4af8:	e94080e7          	jalr	-364(ra) # 5988 <exit>
}
    4afc:	70aa                	ld	ra,168(sp)
    4afe:	740a                	ld	s0,160(sp)
    4b00:	64ea                	ld	s1,152(sp)
    4b02:	694a                	ld	s2,144(sp)
    4b04:	69aa                	ld	s3,136(sp)
    4b06:	6a0a                	ld	s4,128(sp)
    4b08:	7ae6                	ld	s5,120(sp)
    4b0a:	7b46                	ld	s6,112(sp)
    4b0c:	7ba6                	ld	s7,104(sp)
    4b0e:	7c06                	ld	s8,96(sp)
    4b10:	6ce6                	ld	s9,88(sp)
    4b12:	6d46                	ld	s10,80(sp)
    4b14:	6da6                	ld	s11,72(sp)
    4b16:	614d                	addi	sp,sp,176
    4b18:	8082                	ret

0000000000004b1a <concreate>:
{
    4b1a:	7135                	addi	sp,sp,-160
    4b1c:	ed06                	sd	ra,152(sp)
    4b1e:	e922                	sd	s0,144(sp)
    4b20:	e526                	sd	s1,136(sp)
    4b22:	e14a                	sd	s2,128(sp)
    4b24:	fcce                	sd	s3,120(sp)
    4b26:	f8d2                	sd	s4,112(sp)
    4b28:	f4d6                	sd	s5,104(sp)
    4b2a:	f0da                	sd	s6,96(sp)
    4b2c:	ecde                	sd	s7,88(sp)
    4b2e:	1100                	addi	s0,sp,160
    4b30:	89aa                	mv	s3,a0
  file[0] = 'C';
    4b32:	04300793          	li	a5,67
    4b36:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4b3a:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4b3e:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4b40:	4b0d                	li	s6,3
    4b42:	4a85                	li	s5,1
      link("C0", file);
    4b44:	00003b97          	auipc	s7,0x3
    4b48:	3b4b8b93          	addi	s7,s7,948 # 7ef8 <malloc+0x2122>
  for(i = 0; i < N; i++){
    4b4c:	02800a13          	li	s4,40
    4b50:	acc1                	j	4e20 <concreate+0x306>
      link("C0", file);
    4b52:	fa840593          	addi	a1,s0,-88
    4b56:	855e                	mv	a0,s7
    4b58:	00001097          	auipc	ra,0x1
    4b5c:	e90080e7          	jalr	-368(ra) # 59e8 <link>
    if(pid == 0) {
    4b60:	a45d                	j	4e06 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    4b62:	4795                	li	a5,5
    4b64:	02f9693b          	remw	s2,s2,a5
    4b68:	4785                	li	a5,1
    4b6a:	02f90b63          	beq	s2,a5,4ba0 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4b6e:	20200593          	li	a1,514
    4b72:	fa840513          	addi	a0,s0,-88
    4b76:	00001097          	auipc	ra,0x1
    4b7a:	e52080e7          	jalr	-430(ra) # 59c8 <open>
      if(fd < 0){
    4b7e:	26055b63          	bgez	a0,4df4 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    4b82:	fa840593          	addi	a1,s0,-88
    4b86:	00003517          	auipc	a0,0x3
    4b8a:	37a50513          	addi	a0,a0,890 # 7f00 <malloc+0x212a>
    4b8e:	00001097          	auipc	ra,0x1
    4b92:	18a080e7          	jalr	394(ra) # 5d18 <printf>
        exit(1);
    4b96:	4505                	li	a0,1
    4b98:	00001097          	auipc	ra,0x1
    4b9c:	df0080e7          	jalr	-528(ra) # 5988 <exit>
      link("C0", file);
    4ba0:	fa840593          	addi	a1,s0,-88
    4ba4:	00003517          	auipc	a0,0x3
    4ba8:	35450513          	addi	a0,a0,852 # 7ef8 <malloc+0x2122>
    4bac:	00001097          	auipc	ra,0x1
    4bb0:	e3c080e7          	jalr	-452(ra) # 59e8 <link>
      exit(0);
    4bb4:	4501                	li	a0,0
    4bb6:	00001097          	auipc	ra,0x1
    4bba:	dd2080e7          	jalr	-558(ra) # 5988 <exit>
        exit(1);
    4bbe:	4505                	li	a0,1
    4bc0:	00001097          	auipc	ra,0x1
    4bc4:	dc8080e7          	jalr	-568(ra) # 5988 <exit>
  memset(fa, 0, sizeof(fa));
    4bc8:	02800613          	li	a2,40
    4bcc:	4581                	li	a1,0
    4bce:	f8040513          	addi	a0,s0,-128
    4bd2:	00001097          	auipc	ra,0x1
    4bd6:	bba080e7          	jalr	-1094(ra) # 578c <memset>
  fd = open(".", 0);
    4bda:	4581                	li	a1,0
    4bdc:	00002517          	auipc	a0,0x2
    4be0:	d4450513          	addi	a0,a0,-700 # 6920 <malloc+0xb4a>
    4be4:	00001097          	auipc	ra,0x1
    4be8:	de4080e7          	jalr	-540(ra) # 59c8 <open>
    4bec:	892a                	mv	s2,a0
  n = 0;
    4bee:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4bf0:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4bf4:	02700b13          	li	s6,39
      fa[i] = 1;
    4bf8:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4bfa:	4641                	li	a2,16
    4bfc:	f7040593          	addi	a1,s0,-144
    4c00:	854a                	mv	a0,s2
    4c02:	00001097          	auipc	ra,0x1
    4c06:	d9e080e7          	jalr	-610(ra) # 59a0 <read>
    4c0a:	08a05163          	blez	a0,4c8c <concreate+0x172>
    if(de.inum == 0)
    4c0e:	f7045783          	lhu	a5,-144(s0)
    4c12:	d7e5                	beqz	a5,4bfa <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4c14:	f7244783          	lbu	a5,-142(s0)
    4c18:	ff4791e3          	bne	a5,s4,4bfa <concreate+0xe0>
    4c1c:	f7444783          	lbu	a5,-140(s0)
    4c20:	ffe9                	bnez	a5,4bfa <concreate+0xe0>
      i = de.name[1] - '0';
    4c22:	f7344783          	lbu	a5,-141(s0)
    4c26:	fd07879b          	addiw	a5,a5,-48
    4c2a:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4c2e:	00eb6f63          	bltu	s6,a4,4c4c <concreate+0x132>
      if(fa[i]){
    4c32:	fb040793          	addi	a5,s0,-80
    4c36:	97ba                	add	a5,a5,a4
    4c38:	fd07c783          	lbu	a5,-48(a5)
    4c3c:	eb85                	bnez	a5,4c6c <concreate+0x152>
      fa[i] = 1;
    4c3e:	fb040793          	addi	a5,s0,-80
    4c42:	973e                	add	a4,a4,a5
    4c44:	fd770823          	sb	s7,-48(a4) # fd0 <linktest+0x174>
      n++;
    4c48:	2a85                	addiw	s5,s5,1
    4c4a:	bf45                	j	4bfa <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4c4c:	f7240613          	addi	a2,s0,-142
    4c50:	85ce                	mv	a1,s3
    4c52:	00003517          	auipc	a0,0x3
    4c56:	2ce50513          	addi	a0,a0,718 # 7f20 <malloc+0x214a>
    4c5a:	00001097          	auipc	ra,0x1
    4c5e:	0be080e7          	jalr	190(ra) # 5d18 <printf>
        exit(1);
    4c62:	4505                	li	a0,1
    4c64:	00001097          	auipc	ra,0x1
    4c68:	d24080e7          	jalr	-732(ra) # 5988 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4c6c:	f7240613          	addi	a2,s0,-142
    4c70:	85ce                	mv	a1,s3
    4c72:	00003517          	auipc	a0,0x3
    4c76:	2ce50513          	addi	a0,a0,718 # 7f40 <malloc+0x216a>
    4c7a:	00001097          	auipc	ra,0x1
    4c7e:	09e080e7          	jalr	158(ra) # 5d18 <printf>
        exit(1);
    4c82:	4505                	li	a0,1
    4c84:	00001097          	auipc	ra,0x1
    4c88:	d04080e7          	jalr	-764(ra) # 5988 <exit>
  close(fd);
    4c8c:	854a                	mv	a0,s2
    4c8e:	00001097          	auipc	ra,0x1
    4c92:	d22080e7          	jalr	-734(ra) # 59b0 <close>
  if(n != N){
    4c96:	02800793          	li	a5,40
    4c9a:	00fa9763          	bne	s5,a5,4ca8 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    4c9e:	4a8d                	li	s5,3
    4ca0:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    4ca2:	02800a13          	li	s4,40
    4ca6:	a8c9                	j	4d78 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4ca8:	85ce                	mv	a1,s3
    4caa:	00003517          	auipc	a0,0x3
    4cae:	2be50513          	addi	a0,a0,702 # 7f68 <malloc+0x2192>
    4cb2:	00001097          	auipc	ra,0x1
    4cb6:	066080e7          	jalr	102(ra) # 5d18 <printf>
    exit(1);
    4cba:	4505                	li	a0,1
    4cbc:	00001097          	auipc	ra,0x1
    4cc0:	ccc080e7          	jalr	-820(ra) # 5988 <exit>
      printf("%s: fork failed\n", s);
    4cc4:	85ce                	mv	a1,s3
    4cc6:	00002517          	auipc	a0,0x2
    4cca:	dfa50513          	addi	a0,a0,-518 # 6ac0 <malloc+0xcea>
    4cce:	00001097          	auipc	ra,0x1
    4cd2:	04a080e7          	jalr	74(ra) # 5d18 <printf>
      exit(1);
    4cd6:	4505                	li	a0,1
    4cd8:	00001097          	auipc	ra,0x1
    4cdc:	cb0080e7          	jalr	-848(ra) # 5988 <exit>
      close(open(file, 0));
    4ce0:	4581                	li	a1,0
    4ce2:	fa840513          	addi	a0,s0,-88
    4ce6:	00001097          	auipc	ra,0x1
    4cea:	ce2080e7          	jalr	-798(ra) # 59c8 <open>
    4cee:	00001097          	auipc	ra,0x1
    4cf2:	cc2080e7          	jalr	-830(ra) # 59b0 <close>
      close(open(file, 0));
    4cf6:	4581                	li	a1,0
    4cf8:	fa840513          	addi	a0,s0,-88
    4cfc:	00001097          	auipc	ra,0x1
    4d00:	ccc080e7          	jalr	-820(ra) # 59c8 <open>
    4d04:	00001097          	auipc	ra,0x1
    4d08:	cac080e7          	jalr	-852(ra) # 59b0 <close>
      close(open(file, 0));
    4d0c:	4581                	li	a1,0
    4d0e:	fa840513          	addi	a0,s0,-88
    4d12:	00001097          	auipc	ra,0x1
    4d16:	cb6080e7          	jalr	-842(ra) # 59c8 <open>
    4d1a:	00001097          	auipc	ra,0x1
    4d1e:	c96080e7          	jalr	-874(ra) # 59b0 <close>
      close(open(file, 0));
    4d22:	4581                	li	a1,0
    4d24:	fa840513          	addi	a0,s0,-88
    4d28:	00001097          	auipc	ra,0x1
    4d2c:	ca0080e7          	jalr	-864(ra) # 59c8 <open>
    4d30:	00001097          	auipc	ra,0x1
    4d34:	c80080e7          	jalr	-896(ra) # 59b0 <close>
      close(open(file, 0));
    4d38:	4581                	li	a1,0
    4d3a:	fa840513          	addi	a0,s0,-88
    4d3e:	00001097          	auipc	ra,0x1
    4d42:	c8a080e7          	jalr	-886(ra) # 59c8 <open>
    4d46:	00001097          	auipc	ra,0x1
    4d4a:	c6a080e7          	jalr	-918(ra) # 59b0 <close>
      close(open(file, 0));
    4d4e:	4581                	li	a1,0
    4d50:	fa840513          	addi	a0,s0,-88
    4d54:	00001097          	auipc	ra,0x1
    4d58:	c74080e7          	jalr	-908(ra) # 59c8 <open>
    4d5c:	00001097          	auipc	ra,0x1
    4d60:	c54080e7          	jalr	-940(ra) # 59b0 <close>
    if(pid == 0)
    4d64:	08090363          	beqz	s2,4dea <concreate+0x2d0>
      wait(0);
    4d68:	4501                	li	a0,0
    4d6a:	00001097          	auipc	ra,0x1
    4d6e:	c26080e7          	jalr	-986(ra) # 5990 <wait>
  for(i = 0; i < N; i++){
    4d72:	2485                	addiw	s1,s1,1
    4d74:	0f448563          	beq	s1,s4,4e5e <concreate+0x344>
    file[1] = '0' + i;
    4d78:	0304879b          	addiw	a5,s1,48
    4d7c:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    4d80:	00001097          	auipc	ra,0x1
    4d84:	c00080e7          	jalr	-1024(ra) # 5980 <fork>
    4d88:	892a                	mv	s2,a0
    if(pid < 0){
    4d8a:	f2054de3          	bltz	a0,4cc4 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    4d8e:	0354e73b          	remw	a4,s1,s5
    4d92:	00a767b3          	or	a5,a4,a0
    4d96:	2781                	sext.w	a5,a5
    4d98:	d7a1                	beqz	a5,4ce0 <concreate+0x1c6>
    4d9a:	01671363          	bne	a4,s6,4da0 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    4d9e:	f129                	bnez	a0,4ce0 <concreate+0x1c6>
      unlink(file);
    4da0:	fa840513          	addi	a0,s0,-88
    4da4:	00001097          	auipc	ra,0x1
    4da8:	c34080e7          	jalr	-972(ra) # 59d8 <unlink>
      unlink(file);
    4dac:	fa840513          	addi	a0,s0,-88
    4db0:	00001097          	auipc	ra,0x1
    4db4:	c28080e7          	jalr	-984(ra) # 59d8 <unlink>
      unlink(file);
    4db8:	fa840513          	addi	a0,s0,-88
    4dbc:	00001097          	auipc	ra,0x1
    4dc0:	c1c080e7          	jalr	-996(ra) # 59d8 <unlink>
      unlink(file);
    4dc4:	fa840513          	addi	a0,s0,-88
    4dc8:	00001097          	auipc	ra,0x1
    4dcc:	c10080e7          	jalr	-1008(ra) # 59d8 <unlink>
      unlink(file);
    4dd0:	fa840513          	addi	a0,s0,-88
    4dd4:	00001097          	auipc	ra,0x1
    4dd8:	c04080e7          	jalr	-1020(ra) # 59d8 <unlink>
      unlink(file);
    4ddc:	fa840513          	addi	a0,s0,-88
    4de0:	00001097          	auipc	ra,0x1
    4de4:	bf8080e7          	jalr	-1032(ra) # 59d8 <unlink>
    4de8:	bfb5                	j	4d64 <concreate+0x24a>
      exit(0);
    4dea:	4501                	li	a0,0
    4dec:	00001097          	auipc	ra,0x1
    4df0:	b9c080e7          	jalr	-1124(ra) # 5988 <exit>
      close(fd);
    4df4:	00001097          	auipc	ra,0x1
    4df8:	bbc080e7          	jalr	-1092(ra) # 59b0 <close>
    if(pid == 0) {
    4dfc:	bb65                	j	4bb4 <concreate+0x9a>
      close(fd);
    4dfe:	00001097          	auipc	ra,0x1
    4e02:	bb2080e7          	jalr	-1102(ra) # 59b0 <close>
      wait(&xstatus);
    4e06:	f6c40513          	addi	a0,s0,-148
    4e0a:	00001097          	auipc	ra,0x1
    4e0e:	b86080e7          	jalr	-1146(ra) # 5990 <wait>
      if(xstatus != 0)
    4e12:	f6c42483          	lw	s1,-148(s0)
    4e16:	da0494e3          	bnez	s1,4bbe <concreate+0xa4>
  for(i = 0; i < N; i++){
    4e1a:	2905                	addiw	s2,s2,1
    4e1c:	db4906e3          	beq	s2,s4,4bc8 <concreate+0xae>
    file[1] = '0' + i;
    4e20:	0309079b          	addiw	a5,s2,48
    4e24:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4e28:	fa840513          	addi	a0,s0,-88
    4e2c:	00001097          	auipc	ra,0x1
    4e30:	bac080e7          	jalr	-1108(ra) # 59d8 <unlink>
    pid = fork();
    4e34:	00001097          	auipc	ra,0x1
    4e38:	b4c080e7          	jalr	-1204(ra) # 5980 <fork>
    if(pid && (i % 3) == 1){
    4e3c:	d20503e3          	beqz	a0,4b62 <concreate+0x48>
    4e40:	036967bb          	remw	a5,s2,s6
    4e44:	d15787e3          	beq	a5,s5,4b52 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4e48:	20200593          	li	a1,514
    4e4c:	fa840513          	addi	a0,s0,-88
    4e50:	00001097          	auipc	ra,0x1
    4e54:	b78080e7          	jalr	-1160(ra) # 59c8 <open>
      if(fd < 0){
    4e58:	fa0553e3          	bgez	a0,4dfe <concreate+0x2e4>
    4e5c:	b31d                	j	4b82 <concreate+0x68>
}
    4e5e:	60ea                	ld	ra,152(sp)
    4e60:	644a                	ld	s0,144(sp)
    4e62:	64aa                	ld	s1,136(sp)
    4e64:	690a                	ld	s2,128(sp)
    4e66:	79e6                	ld	s3,120(sp)
    4e68:	7a46                	ld	s4,112(sp)
    4e6a:	7aa6                	ld	s5,104(sp)
    4e6c:	7b06                	ld	s6,96(sp)
    4e6e:	6be6                	ld	s7,88(sp)
    4e70:	610d                	addi	sp,sp,160
    4e72:	8082                	ret

0000000000004e74 <bigfile>:
{
    4e74:	7139                	addi	sp,sp,-64
    4e76:	fc06                	sd	ra,56(sp)
    4e78:	f822                	sd	s0,48(sp)
    4e7a:	f426                	sd	s1,40(sp)
    4e7c:	f04a                	sd	s2,32(sp)
    4e7e:	ec4e                	sd	s3,24(sp)
    4e80:	e852                	sd	s4,16(sp)
    4e82:	e456                	sd	s5,8(sp)
    4e84:	0080                	addi	s0,sp,64
    4e86:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4e88:	00003517          	auipc	a0,0x3
    4e8c:	11850513          	addi	a0,a0,280 # 7fa0 <malloc+0x21ca>
    4e90:	00001097          	auipc	ra,0x1
    4e94:	b48080e7          	jalr	-1208(ra) # 59d8 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4e98:	20200593          	li	a1,514
    4e9c:	00003517          	auipc	a0,0x3
    4ea0:	10450513          	addi	a0,a0,260 # 7fa0 <malloc+0x21ca>
    4ea4:	00001097          	auipc	ra,0x1
    4ea8:	b24080e7          	jalr	-1244(ra) # 59c8 <open>
    4eac:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4eae:	4481                	li	s1,0
    memset(buf, i, SZ);
    4eb0:	00007917          	auipc	s2,0x7
    4eb4:	07090913          	addi	s2,s2,112 # bf20 <buf>
  for(i = 0; i < N; i++){
    4eb8:	4a51                	li	s4,20
  if(fd < 0){
    4eba:	0a054063          	bltz	a0,4f5a <bigfile+0xe6>
    memset(buf, i, SZ);
    4ebe:	25800613          	li	a2,600
    4ec2:	85a6                	mv	a1,s1
    4ec4:	854a                	mv	a0,s2
    4ec6:	00001097          	auipc	ra,0x1
    4eca:	8c6080e7          	jalr	-1850(ra) # 578c <memset>
    if(write(fd, buf, SZ) != SZ){
    4ece:	25800613          	li	a2,600
    4ed2:	85ca                	mv	a1,s2
    4ed4:	854e                	mv	a0,s3
    4ed6:	00001097          	auipc	ra,0x1
    4eda:	ad2080e7          	jalr	-1326(ra) # 59a8 <write>
    4ede:	25800793          	li	a5,600
    4ee2:	08f51a63          	bne	a0,a5,4f76 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4ee6:	2485                	addiw	s1,s1,1
    4ee8:	fd449be3          	bne	s1,s4,4ebe <bigfile+0x4a>
  close(fd);
    4eec:	854e                	mv	a0,s3
    4eee:	00001097          	auipc	ra,0x1
    4ef2:	ac2080e7          	jalr	-1342(ra) # 59b0 <close>
  fd = open("bigfile.dat", 0);
    4ef6:	4581                	li	a1,0
    4ef8:	00003517          	auipc	a0,0x3
    4efc:	0a850513          	addi	a0,a0,168 # 7fa0 <malloc+0x21ca>
    4f00:	00001097          	auipc	ra,0x1
    4f04:	ac8080e7          	jalr	-1336(ra) # 59c8 <open>
    4f08:	8a2a                	mv	s4,a0
  total = 0;
    4f0a:	4981                	li	s3,0
  for(i = 0; ; i++){
    4f0c:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4f0e:	00007917          	auipc	s2,0x7
    4f12:	01290913          	addi	s2,s2,18 # bf20 <buf>
  if(fd < 0){
    4f16:	06054e63          	bltz	a0,4f92 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4f1a:	12c00613          	li	a2,300
    4f1e:	85ca                	mv	a1,s2
    4f20:	8552                	mv	a0,s4
    4f22:	00001097          	auipc	ra,0x1
    4f26:	a7e080e7          	jalr	-1410(ra) # 59a0 <read>
    if(cc < 0){
    4f2a:	08054263          	bltz	a0,4fae <bigfile+0x13a>
    if(cc == 0)
    4f2e:	c971                	beqz	a0,5002 <bigfile+0x18e>
    if(cc != SZ/2){
    4f30:	12c00793          	li	a5,300
    4f34:	08f51b63          	bne	a0,a5,4fca <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4f38:	01f4d79b          	srliw	a5,s1,0x1f
    4f3c:	9fa5                	addw	a5,a5,s1
    4f3e:	4017d79b          	sraiw	a5,a5,0x1
    4f42:	00094703          	lbu	a4,0(s2)
    4f46:	0af71063          	bne	a4,a5,4fe6 <bigfile+0x172>
    4f4a:	12b94703          	lbu	a4,299(s2)
    4f4e:	08f71c63          	bne	a4,a5,4fe6 <bigfile+0x172>
    total += cc;
    4f52:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4f56:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4f58:	b7c9                	j	4f1a <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4f5a:	85d6                	mv	a1,s5
    4f5c:	00003517          	auipc	a0,0x3
    4f60:	05450513          	addi	a0,a0,84 # 7fb0 <malloc+0x21da>
    4f64:	00001097          	auipc	ra,0x1
    4f68:	db4080e7          	jalr	-588(ra) # 5d18 <printf>
    exit(1);
    4f6c:	4505                	li	a0,1
    4f6e:	00001097          	auipc	ra,0x1
    4f72:	a1a080e7          	jalr	-1510(ra) # 5988 <exit>
      printf("%s: write bigfile failed\n", s);
    4f76:	85d6                	mv	a1,s5
    4f78:	00003517          	auipc	a0,0x3
    4f7c:	05850513          	addi	a0,a0,88 # 7fd0 <malloc+0x21fa>
    4f80:	00001097          	auipc	ra,0x1
    4f84:	d98080e7          	jalr	-616(ra) # 5d18 <printf>
      exit(1);
    4f88:	4505                	li	a0,1
    4f8a:	00001097          	auipc	ra,0x1
    4f8e:	9fe080e7          	jalr	-1538(ra) # 5988 <exit>
    printf("%s: cannot open bigfile\n", s);
    4f92:	85d6                	mv	a1,s5
    4f94:	00003517          	auipc	a0,0x3
    4f98:	05c50513          	addi	a0,a0,92 # 7ff0 <malloc+0x221a>
    4f9c:	00001097          	auipc	ra,0x1
    4fa0:	d7c080e7          	jalr	-644(ra) # 5d18 <printf>
    exit(1);
    4fa4:	4505                	li	a0,1
    4fa6:	00001097          	auipc	ra,0x1
    4faa:	9e2080e7          	jalr	-1566(ra) # 5988 <exit>
      printf("%s: read bigfile failed\n", s);
    4fae:	85d6                	mv	a1,s5
    4fb0:	00003517          	auipc	a0,0x3
    4fb4:	06050513          	addi	a0,a0,96 # 8010 <malloc+0x223a>
    4fb8:	00001097          	auipc	ra,0x1
    4fbc:	d60080e7          	jalr	-672(ra) # 5d18 <printf>
      exit(1);
    4fc0:	4505                	li	a0,1
    4fc2:	00001097          	auipc	ra,0x1
    4fc6:	9c6080e7          	jalr	-1594(ra) # 5988 <exit>
      printf("%s: short read bigfile\n", s);
    4fca:	85d6                	mv	a1,s5
    4fcc:	00003517          	auipc	a0,0x3
    4fd0:	06450513          	addi	a0,a0,100 # 8030 <malloc+0x225a>
    4fd4:	00001097          	auipc	ra,0x1
    4fd8:	d44080e7          	jalr	-700(ra) # 5d18 <printf>
      exit(1);
    4fdc:	4505                	li	a0,1
    4fde:	00001097          	auipc	ra,0x1
    4fe2:	9aa080e7          	jalr	-1622(ra) # 5988 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4fe6:	85d6                	mv	a1,s5
    4fe8:	00003517          	auipc	a0,0x3
    4fec:	06050513          	addi	a0,a0,96 # 8048 <malloc+0x2272>
    4ff0:	00001097          	auipc	ra,0x1
    4ff4:	d28080e7          	jalr	-728(ra) # 5d18 <printf>
      exit(1);
    4ff8:	4505                	li	a0,1
    4ffa:	00001097          	auipc	ra,0x1
    4ffe:	98e080e7          	jalr	-1650(ra) # 5988 <exit>
  close(fd);
    5002:	8552                	mv	a0,s4
    5004:	00001097          	auipc	ra,0x1
    5008:	9ac080e7          	jalr	-1620(ra) # 59b0 <close>
  if(total != N*SZ){
    500c:	678d                	lui	a5,0x3
    500e:	ee078793          	addi	a5,a5,-288 # 2ee0 <execout+0x88>
    5012:	02f99363          	bne	s3,a5,5038 <bigfile+0x1c4>
  unlink("bigfile.dat");
    5016:	00003517          	auipc	a0,0x3
    501a:	f8a50513          	addi	a0,a0,-118 # 7fa0 <malloc+0x21ca>
    501e:	00001097          	auipc	ra,0x1
    5022:	9ba080e7          	jalr	-1606(ra) # 59d8 <unlink>
}
    5026:	70e2                	ld	ra,56(sp)
    5028:	7442                	ld	s0,48(sp)
    502a:	74a2                	ld	s1,40(sp)
    502c:	7902                	ld	s2,32(sp)
    502e:	69e2                	ld	s3,24(sp)
    5030:	6a42                	ld	s4,16(sp)
    5032:	6aa2                	ld	s5,8(sp)
    5034:	6121                	addi	sp,sp,64
    5036:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    5038:	85d6                	mv	a1,s5
    503a:	00003517          	auipc	a0,0x3
    503e:	02e50513          	addi	a0,a0,46 # 8068 <malloc+0x2292>
    5042:	00001097          	auipc	ra,0x1
    5046:	cd6080e7          	jalr	-810(ra) # 5d18 <printf>
    exit(1);
    504a:	4505                	li	a0,1
    504c:	00001097          	auipc	ra,0x1
    5050:	93c080e7          	jalr	-1732(ra) # 5988 <exit>

0000000000005054 <fsfull>:
{
    5054:	7171                	addi	sp,sp,-176
    5056:	f506                	sd	ra,168(sp)
    5058:	f122                	sd	s0,160(sp)
    505a:	ed26                	sd	s1,152(sp)
    505c:	e94a                	sd	s2,144(sp)
    505e:	e54e                	sd	s3,136(sp)
    5060:	e152                	sd	s4,128(sp)
    5062:	fcd6                	sd	s5,120(sp)
    5064:	f8da                	sd	s6,112(sp)
    5066:	f4de                	sd	s7,104(sp)
    5068:	f0e2                	sd	s8,96(sp)
    506a:	ece6                	sd	s9,88(sp)
    506c:	e8ea                	sd	s10,80(sp)
    506e:	e4ee                	sd	s11,72(sp)
    5070:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    5072:	00003517          	auipc	a0,0x3
    5076:	01650513          	addi	a0,a0,22 # 8088 <malloc+0x22b2>
    507a:	00001097          	auipc	ra,0x1
    507e:	c9e080e7          	jalr	-866(ra) # 5d18 <printf>
  for(nfiles = 0; ; nfiles++){
    5082:	4481                	li	s1,0
    name[0] = 'f';
    5084:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    5088:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    508c:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    5090:	4b29                	li	s6,10
    printf("writing %s\n", name);
    5092:	00003c97          	auipc	s9,0x3
    5096:	006c8c93          	addi	s9,s9,6 # 8098 <malloc+0x22c2>
    int total = 0;
    509a:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    509c:	00007a17          	auipc	s4,0x7
    50a0:	e84a0a13          	addi	s4,s4,-380 # bf20 <buf>
    name[0] = 'f';
    50a4:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    50a8:	0384c7bb          	divw	a5,s1,s8
    50ac:	0307879b          	addiw	a5,a5,48
    50b0:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    50b4:	0384e7bb          	remw	a5,s1,s8
    50b8:	0377c7bb          	divw	a5,a5,s7
    50bc:	0307879b          	addiw	a5,a5,48
    50c0:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    50c4:	0374e7bb          	remw	a5,s1,s7
    50c8:	0367c7bb          	divw	a5,a5,s6
    50cc:	0307879b          	addiw	a5,a5,48
    50d0:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    50d4:	0364e7bb          	remw	a5,s1,s6
    50d8:	0307879b          	addiw	a5,a5,48
    50dc:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    50e0:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    50e4:	f5040593          	addi	a1,s0,-176
    50e8:	8566                	mv	a0,s9
    50ea:	00001097          	auipc	ra,0x1
    50ee:	c2e080e7          	jalr	-978(ra) # 5d18 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    50f2:	20200593          	li	a1,514
    50f6:	f5040513          	addi	a0,s0,-176
    50fa:	00001097          	auipc	ra,0x1
    50fe:	8ce080e7          	jalr	-1842(ra) # 59c8 <open>
    5102:	892a                	mv	s2,a0
    if(fd < 0){
    5104:	0a055663          	bgez	a0,51b0 <fsfull+0x15c>
      printf("open %s failed\n", name);
    5108:	f5040593          	addi	a1,s0,-176
    510c:	00003517          	auipc	a0,0x3
    5110:	f9c50513          	addi	a0,a0,-100 # 80a8 <malloc+0x22d2>
    5114:	00001097          	auipc	ra,0x1
    5118:	c04080e7          	jalr	-1020(ra) # 5d18 <printf>
  while(nfiles >= 0){
    511c:	0604c363          	bltz	s1,5182 <fsfull+0x12e>
    name[0] = 'f';
    5120:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    5124:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    5128:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    512c:	4929                	li	s2,10
  while(nfiles >= 0){
    512e:	5afd                	li	s5,-1
    name[0] = 'f';
    5130:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    5134:	0344c7bb          	divw	a5,s1,s4
    5138:	0307879b          	addiw	a5,a5,48
    513c:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5140:	0344e7bb          	remw	a5,s1,s4
    5144:	0337c7bb          	divw	a5,a5,s3
    5148:	0307879b          	addiw	a5,a5,48
    514c:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5150:	0334e7bb          	remw	a5,s1,s3
    5154:	0327c7bb          	divw	a5,a5,s2
    5158:	0307879b          	addiw	a5,a5,48
    515c:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    5160:	0324e7bb          	remw	a5,s1,s2
    5164:	0307879b          	addiw	a5,a5,48
    5168:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    516c:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    5170:	f5040513          	addi	a0,s0,-176
    5174:	00001097          	auipc	ra,0x1
    5178:	864080e7          	jalr	-1948(ra) # 59d8 <unlink>
    nfiles--;
    517c:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    517e:	fb5499e3          	bne	s1,s5,5130 <fsfull+0xdc>
  printf("fsfull test finished\n");
    5182:	00003517          	auipc	a0,0x3
    5186:	f4650513          	addi	a0,a0,-186 # 80c8 <malloc+0x22f2>
    518a:	00001097          	auipc	ra,0x1
    518e:	b8e080e7          	jalr	-1138(ra) # 5d18 <printf>
}
    5192:	70aa                	ld	ra,168(sp)
    5194:	740a                	ld	s0,160(sp)
    5196:	64ea                	ld	s1,152(sp)
    5198:	694a                	ld	s2,144(sp)
    519a:	69aa                	ld	s3,136(sp)
    519c:	6a0a                	ld	s4,128(sp)
    519e:	7ae6                	ld	s5,120(sp)
    51a0:	7b46                	ld	s6,112(sp)
    51a2:	7ba6                	ld	s7,104(sp)
    51a4:	7c06                	ld	s8,96(sp)
    51a6:	6ce6                	ld	s9,88(sp)
    51a8:	6d46                	ld	s10,80(sp)
    51aa:	6da6                	ld	s11,72(sp)
    51ac:	614d                	addi	sp,sp,176
    51ae:	8082                	ret
    int total = 0;
    51b0:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    51b2:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    51b6:	40000613          	li	a2,1024
    51ba:	85d2                	mv	a1,s4
    51bc:	854a                	mv	a0,s2
    51be:	00000097          	auipc	ra,0x0
    51c2:	7ea080e7          	jalr	2026(ra) # 59a8 <write>
      if(cc < BSIZE)
    51c6:	00aad563          	bge	s5,a0,51d0 <fsfull+0x17c>
      total += cc;
    51ca:	00a989bb          	addw	s3,s3,a0
    while(1){
    51ce:	b7e5                	j	51b6 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    51d0:	85ce                	mv	a1,s3
    51d2:	00003517          	auipc	a0,0x3
    51d6:	ee650513          	addi	a0,a0,-282 # 80b8 <malloc+0x22e2>
    51da:	00001097          	auipc	ra,0x1
    51de:	b3e080e7          	jalr	-1218(ra) # 5d18 <printf>
    close(fd);
    51e2:	854a                	mv	a0,s2
    51e4:	00000097          	auipc	ra,0x0
    51e8:	7cc080e7          	jalr	1996(ra) # 59b0 <close>
    if(total == 0)
    51ec:	f20988e3          	beqz	s3,511c <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    51f0:	2485                	addiw	s1,s1,1
    51f2:	bd4d                	j	50a4 <fsfull+0x50>

00000000000051f4 <badwrite>:
{
    51f4:	7179                	addi	sp,sp,-48
    51f6:	f406                	sd	ra,40(sp)
    51f8:	f022                	sd	s0,32(sp)
    51fa:	ec26                	sd	s1,24(sp)
    51fc:	e84a                	sd	s2,16(sp)
    51fe:	e44e                	sd	s3,8(sp)
    5200:	e052                	sd	s4,0(sp)
    5202:	1800                	addi	s0,sp,48
  unlink("junk");
    5204:	00003517          	auipc	a0,0x3
    5208:	edc50513          	addi	a0,a0,-292 # 80e0 <malloc+0x230a>
    520c:	00000097          	auipc	ra,0x0
    5210:	7cc080e7          	jalr	1996(ra) # 59d8 <unlink>
    5214:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    5218:	00003997          	auipc	s3,0x3
    521c:	ec898993          	addi	s3,s3,-312 # 80e0 <malloc+0x230a>
    write(fd, (char*)0xffffffffffL, 1);
    5220:	5a7d                	li	s4,-1
    5222:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    5226:	20100593          	li	a1,513
    522a:	854e                	mv	a0,s3
    522c:	00000097          	auipc	ra,0x0
    5230:	79c080e7          	jalr	1948(ra) # 59c8 <open>
    5234:	84aa                	mv	s1,a0
    if(fd < 0){
    5236:	06054b63          	bltz	a0,52ac <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    523a:	4605                	li	a2,1
    523c:	85d2                	mv	a1,s4
    523e:	00000097          	auipc	ra,0x0
    5242:	76a080e7          	jalr	1898(ra) # 59a8 <write>
    close(fd);
    5246:	8526                	mv	a0,s1
    5248:	00000097          	auipc	ra,0x0
    524c:	768080e7          	jalr	1896(ra) # 59b0 <close>
    unlink("junk");
    5250:	854e                	mv	a0,s3
    5252:	00000097          	auipc	ra,0x0
    5256:	786080e7          	jalr	1926(ra) # 59d8 <unlink>
  for(int i = 0; i < assumed_free; i++){
    525a:	397d                	addiw	s2,s2,-1
    525c:	fc0915e3          	bnez	s2,5226 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    5260:	20100593          	li	a1,513
    5264:	00003517          	auipc	a0,0x3
    5268:	e7c50513          	addi	a0,a0,-388 # 80e0 <malloc+0x230a>
    526c:	00000097          	auipc	ra,0x0
    5270:	75c080e7          	jalr	1884(ra) # 59c8 <open>
    5274:	84aa                	mv	s1,a0
  if(fd < 0){
    5276:	04054863          	bltz	a0,52c6 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    527a:	4605                	li	a2,1
    527c:	00001597          	auipc	a1,0x1
    5280:	05c58593          	addi	a1,a1,92 # 62d8 <malloc+0x502>
    5284:	00000097          	auipc	ra,0x0
    5288:	724080e7          	jalr	1828(ra) # 59a8 <write>
    528c:	4785                	li	a5,1
    528e:	04f50963          	beq	a0,a5,52e0 <badwrite+0xec>
    printf("write failed\n");
    5292:	00003517          	auipc	a0,0x3
    5296:	e6e50513          	addi	a0,a0,-402 # 8100 <malloc+0x232a>
    529a:	00001097          	auipc	ra,0x1
    529e:	a7e080e7          	jalr	-1410(ra) # 5d18 <printf>
    exit(1);
    52a2:	4505                	li	a0,1
    52a4:	00000097          	auipc	ra,0x0
    52a8:	6e4080e7          	jalr	1764(ra) # 5988 <exit>
      printf("open junk failed\n");
    52ac:	00003517          	auipc	a0,0x3
    52b0:	e3c50513          	addi	a0,a0,-452 # 80e8 <malloc+0x2312>
    52b4:	00001097          	auipc	ra,0x1
    52b8:	a64080e7          	jalr	-1436(ra) # 5d18 <printf>
      exit(1);
    52bc:	4505                	li	a0,1
    52be:	00000097          	auipc	ra,0x0
    52c2:	6ca080e7          	jalr	1738(ra) # 5988 <exit>
    printf("open junk failed\n");
    52c6:	00003517          	auipc	a0,0x3
    52ca:	e2250513          	addi	a0,a0,-478 # 80e8 <malloc+0x2312>
    52ce:	00001097          	auipc	ra,0x1
    52d2:	a4a080e7          	jalr	-1462(ra) # 5d18 <printf>
    exit(1);
    52d6:	4505                	li	a0,1
    52d8:	00000097          	auipc	ra,0x0
    52dc:	6b0080e7          	jalr	1712(ra) # 5988 <exit>
  close(fd);
    52e0:	8526                	mv	a0,s1
    52e2:	00000097          	auipc	ra,0x0
    52e6:	6ce080e7          	jalr	1742(ra) # 59b0 <close>
  unlink("junk");
    52ea:	00003517          	auipc	a0,0x3
    52ee:	df650513          	addi	a0,a0,-522 # 80e0 <malloc+0x230a>
    52f2:	00000097          	auipc	ra,0x0
    52f6:	6e6080e7          	jalr	1766(ra) # 59d8 <unlink>
  exit(0);
    52fa:	4501                	li	a0,0
    52fc:	00000097          	auipc	ra,0x0
    5300:	68c080e7          	jalr	1676(ra) # 5988 <exit>

0000000000005304 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    5304:	7139                	addi	sp,sp,-64
    5306:	fc06                	sd	ra,56(sp)
    5308:	f822                	sd	s0,48(sp)
    530a:	f426                	sd	s1,40(sp)
    530c:	f04a                	sd	s2,32(sp)
    530e:	ec4e                	sd	s3,24(sp)
    5310:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    5312:	fc840513          	addi	a0,s0,-56
    5316:	00000097          	auipc	ra,0x0
    531a:	682080e7          	jalr	1666(ra) # 5998 <pipe>
    531e:	06054763          	bltz	a0,538c <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    5322:	00000097          	auipc	ra,0x0
    5326:	65e080e7          	jalr	1630(ra) # 5980 <fork>

  if(pid < 0){
    532a:	06054e63          	bltz	a0,53a6 <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    532e:	ed51                	bnez	a0,53ca <countfree+0xc6>
    close(fds[0]);
    5330:	fc842503          	lw	a0,-56(s0)
    5334:	00000097          	auipc	ra,0x0
    5338:	67c080e7          	jalr	1660(ra) # 59b0 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    533c:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    533e:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    5340:	00001997          	auipc	s3,0x1
    5344:	f9898993          	addi	s3,s3,-104 # 62d8 <malloc+0x502>
      uint64 a = (uint64) sbrk(4096);
    5348:	6505                	lui	a0,0x1
    534a:	00000097          	auipc	ra,0x0
    534e:	6c6080e7          	jalr	1734(ra) # 5a10 <sbrk>
      if(a == 0xffffffffffffffff){
    5352:	07250763          	beq	a0,s2,53c0 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    5356:	6785                	lui	a5,0x1
    5358:	953e                	add	a0,a0,a5
    535a:	fe950fa3          	sb	s1,-1(a0) # fff <linktest+0x1a3>
      if(write(fds[1], "x", 1) != 1){
    535e:	8626                	mv	a2,s1
    5360:	85ce                	mv	a1,s3
    5362:	fcc42503          	lw	a0,-52(s0)
    5366:	00000097          	auipc	ra,0x0
    536a:	642080e7          	jalr	1602(ra) # 59a8 <write>
    536e:	fc950de3          	beq	a0,s1,5348 <countfree+0x44>
        printf("write() failed in countfree()\n");
    5372:	00003517          	auipc	a0,0x3
    5376:	dde50513          	addi	a0,a0,-546 # 8150 <malloc+0x237a>
    537a:	00001097          	auipc	ra,0x1
    537e:	99e080e7          	jalr	-1634(ra) # 5d18 <printf>
        exit(1);
    5382:	4505                	li	a0,1
    5384:	00000097          	auipc	ra,0x0
    5388:	604080e7          	jalr	1540(ra) # 5988 <exit>
    printf("pipe() failed in countfree()\n");
    538c:	00003517          	auipc	a0,0x3
    5390:	d8450513          	addi	a0,a0,-636 # 8110 <malloc+0x233a>
    5394:	00001097          	auipc	ra,0x1
    5398:	984080e7          	jalr	-1660(ra) # 5d18 <printf>
    exit(1);
    539c:	4505                	li	a0,1
    539e:	00000097          	auipc	ra,0x0
    53a2:	5ea080e7          	jalr	1514(ra) # 5988 <exit>
    printf("fork failed in countfree()\n");
    53a6:	00003517          	auipc	a0,0x3
    53aa:	d8a50513          	addi	a0,a0,-630 # 8130 <malloc+0x235a>
    53ae:	00001097          	auipc	ra,0x1
    53b2:	96a080e7          	jalr	-1686(ra) # 5d18 <printf>
    exit(1);
    53b6:	4505                	li	a0,1
    53b8:	00000097          	auipc	ra,0x0
    53bc:	5d0080e7          	jalr	1488(ra) # 5988 <exit>
      }
    }

    exit(0);
    53c0:	4501                	li	a0,0
    53c2:	00000097          	auipc	ra,0x0
    53c6:	5c6080e7          	jalr	1478(ra) # 5988 <exit>
  }

  close(fds[1]);
    53ca:	fcc42503          	lw	a0,-52(s0)
    53ce:	00000097          	auipc	ra,0x0
    53d2:	5e2080e7          	jalr	1506(ra) # 59b0 <close>

  int n = 0;
    53d6:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    53d8:	4605                	li	a2,1
    53da:	fc740593          	addi	a1,s0,-57
    53de:	fc842503          	lw	a0,-56(s0)
    53e2:	00000097          	auipc	ra,0x0
    53e6:	5be080e7          	jalr	1470(ra) # 59a0 <read>
    if(cc < 0){
    53ea:	00054563          	bltz	a0,53f4 <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    53ee:	c105                	beqz	a0,540e <countfree+0x10a>
      break;
    n += 1;
    53f0:	2485                	addiw	s1,s1,1
  while(1){
    53f2:	b7dd                	j	53d8 <countfree+0xd4>
      printf("read() failed in countfree()\n");
    53f4:	00003517          	auipc	a0,0x3
    53f8:	d7c50513          	addi	a0,a0,-644 # 8170 <malloc+0x239a>
    53fc:	00001097          	auipc	ra,0x1
    5400:	91c080e7          	jalr	-1764(ra) # 5d18 <printf>
      exit(1);
    5404:	4505                	li	a0,1
    5406:	00000097          	auipc	ra,0x0
    540a:	582080e7          	jalr	1410(ra) # 5988 <exit>
  }

  close(fds[0]);
    540e:	fc842503          	lw	a0,-56(s0)
    5412:	00000097          	auipc	ra,0x0
    5416:	59e080e7          	jalr	1438(ra) # 59b0 <close>
  wait((int*)0);
    541a:	4501                	li	a0,0
    541c:	00000097          	auipc	ra,0x0
    5420:	574080e7          	jalr	1396(ra) # 5990 <wait>
  
  return n;
}
    5424:	8526                	mv	a0,s1
    5426:	70e2                	ld	ra,56(sp)
    5428:	7442                	ld	s0,48(sp)
    542a:	74a2                	ld	s1,40(sp)
    542c:	7902                	ld	s2,32(sp)
    542e:	69e2                	ld	s3,24(sp)
    5430:	6121                	addi	sp,sp,64
    5432:	8082                	ret

0000000000005434 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    5434:	7179                	addi	sp,sp,-48
    5436:	f406                	sd	ra,40(sp)
    5438:	f022                	sd	s0,32(sp)
    543a:	ec26                	sd	s1,24(sp)
    543c:	e84a                	sd	s2,16(sp)
    543e:	1800                	addi	s0,sp,48
    5440:	84aa                	mv	s1,a0
    5442:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    5444:	00003517          	auipc	a0,0x3
    5448:	d4c50513          	addi	a0,a0,-692 # 8190 <malloc+0x23ba>
    544c:	00001097          	auipc	ra,0x1
    5450:	8cc080e7          	jalr	-1844(ra) # 5d18 <printf>
  if((pid = fork()) < 0) {
    5454:	00000097          	auipc	ra,0x0
    5458:	52c080e7          	jalr	1324(ra) # 5980 <fork>
    545c:	02054e63          	bltz	a0,5498 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    5460:	c929                	beqz	a0,54b2 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    5462:	fdc40513          	addi	a0,s0,-36
    5466:	00000097          	auipc	ra,0x0
    546a:	52a080e7          	jalr	1322(ra) # 5990 <wait>
    if(xstatus != 0) 
    546e:	fdc42783          	lw	a5,-36(s0)
    5472:	c7b9                	beqz	a5,54c0 <run+0x8c>
      printf("FAILED\n");
    5474:	00003517          	auipc	a0,0x3
    5478:	d4450513          	addi	a0,a0,-700 # 81b8 <malloc+0x23e2>
    547c:	00001097          	auipc	ra,0x1
    5480:	89c080e7          	jalr	-1892(ra) # 5d18 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5484:	fdc42503          	lw	a0,-36(s0)
  }
}
    5488:	00153513          	seqz	a0,a0
    548c:	70a2                	ld	ra,40(sp)
    548e:	7402                	ld	s0,32(sp)
    5490:	64e2                	ld	s1,24(sp)
    5492:	6942                	ld	s2,16(sp)
    5494:	6145                	addi	sp,sp,48
    5496:	8082                	ret
    printf("runtest: fork error\n");
    5498:	00003517          	auipc	a0,0x3
    549c:	d0850513          	addi	a0,a0,-760 # 81a0 <malloc+0x23ca>
    54a0:	00001097          	auipc	ra,0x1
    54a4:	878080e7          	jalr	-1928(ra) # 5d18 <printf>
    exit(1);
    54a8:	4505                	li	a0,1
    54aa:	00000097          	auipc	ra,0x0
    54ae:	4de080e7          	jalr	1246(ra) # 5988 <exit>
    f(s);
    54b2:	854a                	mv	a0,s2
    54b4:	9482                	jalr	s1
    exit(0);
    54b6:	4501                	li	a0,0
    54b8:	00000097          	auipc	ra,0x0
    54bc:	4d0080e7          	jalr	1232(ra) # 5988 <exit>
      printf("OK\n");
    54c0:	00003517          	auipc	a0,0x3
    54c4:	d0050513          	addi	a0,a0,-768 # 81c0 <malloc+0x23ea>
    54c8:	00001097          	auipc	ra,0x1
    54cc:	850080e7          	jalr	-1968(ra) # 5d18 <printf>
    54d0:	bf55                	j	5484 <run+0x50>

00000000000054d2 <main>:

int
main(int argc, char *argv[])
{
    54d2:	bc010113          	addi	sp,sp,-1088
    54d6:	42113c23          	sd	ra,1080(sp)
    54da:	42813823          	sd	s0,1072(sp)
    54de:	42913423          	sd	s1,1064(sp)
    54e2:	43213023          	sd	s2,1056(sp)
    54e6:	41313c23          	sd	s3,1048(sp)
    54ea:	41413823          	sd	s4,1040(sp)
    54ee:	41513423          	sd	s5,1032(sp)
    54f2:	41613023          	sd	s6,1024(sp)
    54f6:	44010413          	addi	s0,sp,1088
    54fa:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    54fc:	4789                	li	a5,2
    54fe:	08f50763          	beq	a0,a5,558c <main+0xba>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5502:	4785                	li	a5,1
  char *justone = 0;
    5504:	4901                	li	s2,0
  } else if(argc > 1){
    5506:	0ca7c163          	blt	a5,a0,55c8 <main+0xf6>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    550a:	00003797          	auipc	a5,0x3
    550e:	dce78793          	addi	a5,a5,-562 # 82d8 <malloc+0x2502>
    5512:	bc040713          	addi	a4,s0,-1088
    5516:	00003817          	auipc	a6,0x3
    551a:	1c280813          	addi	a6,a6,450 # 86d8 <malloc+0x2902>
    551e:	6388                	ld	a0,0(a5)
    5520:	678c                	ld	a1,8(a5)
    5522:	6b90                	ld	a2,16(a5)
    5524:	6f94                	ld	a3,24(a5)
    5526:	e308                	sd	a0,0(a4)
    5528:	e70c                	sd	a1,8(a4)
    552a:	eb10                	sd	a2,16(a4)
    552c:	ef14                	sd	a3,24(a4)
    552e:	02078793          	addi	a5,a5,32
    5532:	02070713          	addi	a4,a4,32
    5536:	ff0794e3          	bne	a5,a6,551e <main+0x4c>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    553a:	00003517          	auipc	a0,0x3
    553e:	d3e50513          	addi	a0,a0,-706 # 8278 <malloc+0x24a2>
    5542:	00000097          	auipc	ra,0x0
    5546:	7d6080e7          	jalr	2006(ra) # 5d18 <printf>
  int free0 = countfree();
    554a:	00000097          	auipc	ra,0x0
    554e:	dba080e7          	jalr	-582(ra) # 5304 <countfree>
    5552:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    5554:	bc843503          	ld	a0,-1080(s0)
    5558:	bc040493          	addi	s1,s0,-1088
  int fail = 0;
    555c:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    555e:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    5560:	e55d                	bnez	a0,560e <main+0x13c>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    5562:	00000097          	auipc	ra,0x0
    5566:	da2080e7          	jalr	-606(ra) # 5304 <countfree>
    556a:	85aa                	mv	a1,a0
    556c:	0f455163          	bge	a0,s4,564e <main+0x17c>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5570:	8652                	mv	a2,s4
    5572:	00003517          	auipc	a0,0x3
    5576:	cbe50513          	addi	a0,a0,-834 # 8230 <malloc+0x245a>
    557a:	00000097          	auipc	ra,0x0
    557e:	79e080e7          	jalr	1950(ra) # 5d18 <printf>
    exit(1);
    5582:	4505                	li	a0,1
    5584:	00000097          	auipc	ra,0x0
    5588:	404080e7          	jalr	1028(ra) # 5988 <exit>
    558c:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    558e:	00003597          	auipc	a1,0x3
    5592:	c3a58593          	addi	a1,a1,-966 # 81c8 <malloc+0x23f2>
    5596:	6488                	ld	a0,8(s1)
    5598:	00000097          	auipc	ra,0x0
    559c:	19e080e7          	jalr	414(ra) # 5736 <strcmp>
    55a0:	10050563          	beqz	a0,56aa <main+0x1d8>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    55a4:	00003597          	auipc	a1,0x3
    55a8:	d0c58593          	addi	a1,a1,-756 # 82b0 <malloc+0x24da>
    55ac:	6488                	ld	a0,8(s1)
    55ae:	00000097          	auipc	ra,0x0
    55b2:	188080e7          	jalr	392(ra) # 5736 <strcmp>
    55b6:	c97d                	beqz	a0,56ac <main+0x1da>
  } else if(argc == 2 && argv[1][0] != '-'){
    55b8:	0084b903          	ld	s2,8(s1)
    55bc:	00094703          	lbu	a4,0(s2)
    55c0:	02d00793          	li	a5,45
    55c4:	f4f713e3          	bne	a4,a5,550a <main+0x38>
    printf("Usage: usertests [-c] [testname]\n");
    55c8:	00003517          	auipc	a0,0x3
    55cc:	c0850513          	addi	a0,a0,-1016 # 81d0 <malloc+0x23fa>
    55d0:	00000097          	auipc	ra,0x0
    55d4:	748080e7          	jalr	1864(ra) # 5d18 <printf>
    exit(1);
    55d8:	4505                	li	a0,1
    55da:	00000097          	auipc	ra,0x0
    55de:	3ae080e7          	jalr	942(ra) # 5988 <exit>
          exit(1);
    55e2:	4505                	li	a0,1
    55e4:	00000097          	auipc	ra,0x0
    55e8:	3a4080e7          	jalr	932(ra) # 5988 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    55ec:	40a905bb          	subw	a1,s2,a0
    55f0:	855a                	mv	a0,s6
    55f2:	00000097          	auipc	ra,0x0
    55f6:	726080e7          	jalr	1830(ra) # 5d18 <printf>
        if(continuous != 2)
    55fa:	09498463          	beq	s3,s4,5682 <main+0x1b0>
          exit(1);
    55fe:	4505                	li	a0,1
    5600:	00000097          	auipc	ra,0x0
    5604:	388080e7          	jalr	904(ra) # 5988 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    5608:	04c1                	addi	s1,s1,16
    560a:	6488                	ld	a0,8(s1)
    560c:	c115                	beqz	a0,5630 <main+0x15e>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    560e:	00090863          	beqz	s2,561e <main+0x14c>
    5612:	85ca                	mv	a1,s2
    5614:	00000097          	auipc	ra,0x0
    5618:	122080e7          	jalr	290(ra) # 5736 <strcmp>
    561c:	f575                	bnez	a0,5608 <main+0x136>
      if(!run(t->f, t->s))
    561e:	648c                	ld	a1,8(s1)
    5620:	6088                	ld	a0,0(s1)
    5622:	00000097          	auipc	ra,0x0
    5626:	e12080e7          	jalr	-494(ra) # 5434 <run>
    562a:	fd79                	bnez	a0,5608 <main+0x136>
        fail = 1;
    562c:	89d6                	mv	s3,s5
    562e:	bfe9                	j	5608 <main+0x136>
  if(fail){
    5630:	f20989e3          	beqz	s3,5562 <main+0x90>
    printf("SOME TESTS FAILED\n");
    5634:	00003517          	auipc	a0,0x3
    5638:	be450513          	addi	a0,a0,-1052 # 8218 <malloc+0x2442>
    563c:	00000097          	auipc	ra,0x0
    5640:	6dc080e7          	jalr	1756(ra) # 5d18 <printf>
    exit(1);
    5644:	4505                	li	a0,1
    5646:	00000097          	auipc	ra,0x0
    564a:	342080e7          	jalr	834(ra) # 5988 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    564e:	00003517          	auipc	a0,0x3
    5652:	c1250513          	addi	a0,a0,-1006 # 8260 <malloc+0x248a>
    5656:	00000097          	auipc	ra,0x0
    565a:	6c2080e7          	jalr	1730(ra) # 5d18 <printf>
    exit(0);
    565e:	4501                	li	a0,0
    5660:	00000097          	auipc	ra,0x0
    5664:	328080e7          	jalr	808(ra) # 5988 <exit>
        printf("SOME TESTS FAILED\n");
    5668:	8556                	mv	a0,s5
    566a:	00000097          	auipc	ra,0x0
    566e:	6ae080e7          	jalr	1710(ra) # 5d18 <printf>
        if(continuous != 2)
    5672:	f74998e3          	bne	s3,s4,55e2 <main+0x110>
      int free1 = countfree();
    5676:	00000097          	auipc	ra,0x0
    567a:	c8e080e7          	jalr	-882(ra) # 5304 <countfree>
      if(free1 < free0){
    567e:	f72547e3          	blt	a0,s2,55ec <main+0x11a>
      int free0 = countfree();
    5682:	00000097          	auipc	ra,0x0
    5686:	c82080e7          	jalr	-894(ra) # 5304 <countfree>
    568a:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    568c:	bc843583          	ld	a1,-1080(s0)
    5690:	d1fd                	beqz	a1,5676 <main+0x1a4>
    5692:	bc040493          	addi	s1,s0,-1088
        if(!run(t->f, t->s)){
    5696:	6088                	ld	a0,0(s1)
    5698:	00000097          	auipc	ra,0x0
    569c:	d9c080e7          	jalr	-612(ra) # 5434 <run>
    56a0:	d561                	beqz	a0,5668 <main+0x196>
      for (struct test *t = tests; t->s != 0; t++) {
    56a2:	04c1                	addi	s1,s1,16
    56a4:	648c                	ld	a1,8(s1)
    56a6:	f9e5                	bnez	a1,5696 <main+0x1c4>
    56a8:	b7f9                	j	5676 <main+0x1a4>
    continuous = 1;
    56aa:	4985                	li	s3,1
  } tests[] = {
    56ac:	00003797          	auipc	a5,0x3
    56b0:	c2c78793          	addi	a5,a5,-980 # 82d8 <malloc+0x2502>
    56b4:	bc040713          	addi	a4,s0,-1088
    56b8:	00003817          	auipc	a6,0x3
    56bc:	02080813          	addi	a6,a6,32 # 86d8 <malloc+0x2902>
    56c0:	6388                	ld	a0,0(a5)
    56c2:	678c                	ld	a1,8(a5)
    56c4:	6b90                	ld	a2,16(a5)
    56c6:	6f94                	ld	a3,24(a5)
    56c8:	e308                	sd	a0,0(a4)
    56ca:	e70c                	sd	a1,8(a4)
    56cc:	eb10                	sd	a2,16(a4)
    56ce:	ef14                	sd	a3,24(a4)
    56d0:	02078793          	addi	a5,a5,32
    56d4:	02070713          	addi	a4,a4,32
    56d8:	ff0794e3          	bne	a5,a6,56c0 <main+0x1ee>
    printf("continuous usertests starting\n");
    56dc:	00003517          	auipc	a0,0x3
    56e0:	bb450513          	addi	a0,a0,-1100 # 8290 <malloc+0x24ba>
    56e4:	00000097          	auipc	ra,0x0
    56e8:	634080e7          	jalr	1588(ra) # 5d18 <printf>
        printf("SOME TESTS FAILED\n");
    56ec:	00003a97          	auipc	s5,0x3
    56f0:	b2ca8a93          	addi	s5,s5,-1236 # 8218 <malloc+0x2442>
        if(continuous != 2)
    56f4:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    56f6:	00003b17          	auipc	s6,0x3
    56fa:	b02b0b13          	addi	s6,s6,-1278 # 81f8 <malloc+0x2422>
    56fe:	b751                	j	5682 <main+0x1b0>

0000000000005700 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
    5700:	1141                	addi	sp,sp,-16
    5702:	e406                	sd	ra,8(sp)
    5704:	e022                	sd	s0,0(sp)
    5706:	0800                	addi	s0,sp,16
  extern int main();
  main();
    5708:	00000097          	auipc	ra,0x0
    570c:	dca080e7          	jalr	-566(ra) # 54d2 <main>
  exit(0);
    5710:	4501                	li	a0,0
    5712:	00000097          	auipc	ra,0x0
    5716:	276080e7          	jalr	630(ra) # 5988 <exit>

000000000000571a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    571a:	1141                	addi	sp,sp,-16
    571c:	e422                	sd	s0,8(sp)
    571e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5720:	87aa                	mv	a5,a0
    5722:	0585                	addi	a1,a1,1
    5724:	0785                	addi	a5,a5,1
    5726:	fff5c703          	lbu	a4,-1(a1)
    572a:	fee78fa3          	sb	a4,-1(a5)
    572e:	fb75                	bnez	a4,5722 <strcpy+0x8>
    ;
  return os;
}
    5730:	6422                	ld	s0,8(sp)
    5732:	0141                	addi	sp,sp,16
    5734:	8082                	ret

0000000000005736 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5736:	1141                	addi	sp,sp,-16
    5738:	e422                	sd	s0,8(sp)
    573a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    573c:	00054783          	lbu	a5,0(a0)
    5740:	cb91                	beqz	a5,5754 <strcmp+0x1e>
    5742:	0005c703          	lbu	a4,0(a1)
    5746:	00f71763          	bne	a4,a5,5754 <strcmp+0x1e>
    p++, q++;
    574a:	0505                	addi	a0,a0,1
    574c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    574e:	00054783          	lbu	a5,0(a0)
    5752:	fbe5                	bnez	a5,5742 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5754:	0005c503          	lbu	a0,0(a1)
}
    5758:	40a7853b          	subw	a0,a5,a0
    575c:	6422                	ld	s0,8(sp)
    575e:	0141                	addi	sp,sp,16
    5760:	8082                	ret

0000000000005762 <strlen>:

uint
strlen(const char *s)
{
    5762:	1141                	addi	sp,sp,-16
    5764:	e422                	sd	s0,8(sp)
    5766:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5768:	00054783          	lbu	a5,0(a0)
    576c:	cf91                	beqz	a5,5788 <strlen+0x26>
    576e:	0505                	addi	a0,a0,1
    5770:	87aa                	mv	a5,a0
    5772:	4685                	li	a3,1
    5774:	9e89                	subw	a3,a3,a0
    5776:	00f6853b          	addw	a0,a3,a5
    577a:	0785                	addi	a5,a5,1
    577c:	fff7c703          	lbu	a4,-1(a5)
    5780:	fb7d                	bnez	a4,5776 <strlen+0x14>
    ;
  return n;
}
    5782:	6422                	ld	s0,8(sp)
    5784:	0141                	addi	sp,sp,16
    5786:	8082                	ret
  for(n = 0; s[n]; n++)
    5788:	4501                	li	a0,0
    578a:	bfe5                	j	5782 <strlen+0x20>

000000000000578c <memset>:

void*
memset(void *dst, int c, uint n)
{
    578c:	1141                	addi	sp,sp,-16
    578e:	e422                	sd	s0,8(sp)
    5790:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    5792:	ca19                	beqz	a2,57a8 <memset+0x1c>
    5794:	87aa                	mv	a5,a0
    5796:	1602                	slli	a2,a2,0x20
    5798:	9201                	srli	a2,a2,0x20
    579a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    579e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    57a2:	0785                	addi	a5,a5,1
    57a4:	fee79de3          	bne	a5,a4,579e <memset+0x12>
  }
  return dst;
}
    57a8:	6422                	ld	s0,8(sp)
    57aa:	0141                	addi	sp,sp,16
    57ac:	8082                	ret

00000000000057ae <strchr>:

char*
strchr(const char *s, char c)
{
    57ae:	1141                	addi	sp,sp,-16
    57b0:	e422                	sd	s0,8(sp)
    57b2:	0800                	addi	s0,sp,16
  for(; *s; s++)
    57b4:	00054783          	lbu	a5,0(a0)
    57b8:	cb99                	beqz	a5,57ce <strchr+0x20>
    if(*s == c)
    57ba:	00f58763          	beq	a1,a5,57c8 <strchr+0x1a>
  for(; *s; s++)
    57be:	0505                	addi	a0,a0,1
    57c0:	00054783          	lbu	a5,0(a0)
    57c4:	fbfd                	bnez	a5,57ba <strchr+0xc>
      return (char*)s;
  return 0;
    57c6:	4501                	li	a0,0
}
    57c8:	6422                	ld	s0,8(sp)
    57ca:	0141                	addi	sp,sp,16
    57cc:	8082                	ret
  return 0;
    57ce:	4501                	li	a0,0
    57d0:	bfe5                	j	57c8 <strchr+0x1a>

00000000000057d2 <gets>:

char*
gets(char *buf, int max)
{
    57d2:	711d                	addi	sp,sp,-96
    57d4:	ec86                	sd	ra,88(sp)
    57d6:	e8a2                	sd	s0,80(sp)
    57d8:	e4a6                	sd	s1,72(sp)
    57da:	e0ca                	sd	s2,64(sp)
    57dc:	fc4e                	sd	s3,56(sp)
    57de:	f852                	sd	s4,48(sp)
    57e0:	f456                	sd	s5,40(sp)
    57e2:	f05a                	sd	s6,32(sp)
    57e4:	ec5e                	sd	s7,24(sp)
    57e6:	1080                	addi	s0,sp,96
    57e8:	8baa                	mv	s7,a0
    57ea:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    57ec:	892a                	mv	s2,a0
    57ee:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    57f0:	4aa9                	li	s5,10
    57f2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    57f4:	89a6                	mv	s3,s1
    57f6:	2485                	addiw	s1,s1,1
    57f8:	0344d863          	bge	s1,s4,5828 <gets+0x56>
    cc = read(0, &c, 1);
    57fc:	4605                	li	a2,1
    57fe:	faf40593          	addi	a1,s0,-81
    5802:	4501                	li	a0,0
    5804:	00000097          	auipc	ra,0x0
    5808:	19c080e7          	jalr	412(ra) # 59a0 <read>
    if(cc < 1)
    580c:	00a05e63          	blez	a0,5828 <gets+0x56>
    buf[i++] = c;
    5810:	faf44783          	lbu	a5,-81(s0)
    5814:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5818:	01578763          	beq	a5,s5,5826 <gets+0x54>
    581c:	0905                	addi	s2,s2,1
    581e:	fd679be3          	bne	a5,s6,57f4 <gets+0x22>
  for(i=0; i+1 < max; ){
    5822:	89a6                	mv	s3,s1
    5824:	a011                	j	5828 <gets+0x56>
    5826:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5828:	99de                	add	s3,s3,s7
    582a:	00098023          	sb	zero,0(s3)
  return buf;
}
    582e:	855e                	mv	a0,s7
    5830:	60e6                	ld	ra,88(sp)
    5832:	6446                	ld	s0,80(sp)
    5834:	64a6                	ld	s1,72(sp)
    5836:	6906                	ld	s2,64(sp)
    5838:	79e2                	ld	s3,56(sp)
    583a:	7a42                	ld	s4,48(sp)
    583c:	7aa2                	ld	s5,40(sp)
    583e:	7b02                	ld	s6,32(sp)
    5840:	6be2                	ld	s7,24(sp)
    5842:	6125                	addi	sp,sp,96
    5844:	8082                	ret

0000000000005846 <stat>:

int
stat(const char *n, struct stat *st)
{
    5846:	1101                	addi	sp,sp,-32
    5848:	ec06                	sd	ra,24(sp)
    584a:	e822                	sd	s0,16(sp)
    584c:	e426                	sd	s1,8(sp)
    584e:	e04a                	sd	s2,0(sp)
    5850:	1000                	addi	s0,sp,32
    5852:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5854:	4581                	li	a1,0
    5856:	00000097          	auipc	ra,0x0
    585a:	172080e7          	jalr	370(ra) # 59c8 <open>
  if(fd < 0)
    585e:	02054563          	bltz	a0,5888 <stat+0x42>
    5862:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5864:	85ca                	mv	a1,s2
    5866:	00000097          	auipc	ra,0x0
    586a:	17a080e7          	jalr	378(ra) # 59e0 <fstat>
    586e:	892a                	mv	s2,a0
  close(fd);
    5870:	8526                	mv	a0,s1
    5872:	00000097          	auipc	ra,0x0
    5876:	13e080e7          	jalr	318(ra) # 59b0 <close>
  return r;
}
    587a:	854a                	mv	a0,s2
    587c:	60e2                	ld	ra,24(sp)
    587e:	6442                	ld	s0,16(sp)
    5880:	64a2                	ld	s1,8(sp)
    5882:	6902                	ld	s2,0(sp)
    5884:	6105                	addi	sp,sp,32
    5886:	8082                	ret
    return -1;
    5888:	597d                	li	s2,-1
    588a:	bfc5                	j	587a <stat+0x34>

000000000000588c <atoi>:

int
atoi(const char *s)
{
    588c:	1141                	addi	sp,sp,-16
    588e:	e422                	sd	s0,8(sp)
    5890:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5892:	00054603          	lbu	a2,0(a0)
    5896:	fd06079b          	addiw	a5,a2,-48
    589a:	0ff7f793          	andi	a5,a5,255
    589e:	4725                	li	a4,9
    58a0:	02f76963          	bltu	a4,a5,58d2 <atoi+0x46>
    58a4:	86aa                	mv	a3,a0
  n = 0;
    58a6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    58a8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    58aa:	0685                	addi	a3,a3,1
    58ac:	0025179b          	slliw	a5,a0,0x2
    58b0:	9fa9                	addw	a5,a5,a0
    58b2:	0017979b          	slliw	a5,a5,0x1
    58b6:	9fb1                	addw	a5,a5,a2
    58b8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    58bc:	0006c603          	lbu	a2,0(a3)
    58c0:	fd06071b          	addiw	a4,a2,-48
    58c4:	0ff77713          	andi	a4,a4,255
    58c8:	fee5f1e3          	bgeu	a1,a4,58aa <atoi+0x1e>
  return n;
}
    58cc:	6422                	ld	s0,8(sp)
    58ce:	0141                	addi	sp,sp,16
    58d0:	8082                	ret
  n = 0;
    58d2:	4501                	li	a0,0
    58d4:	bfe5                	j	58cc <atoi+0x40>

00000000000058d6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    58d6:	1141                	addi	sp,sp,-16
    58d8:	e422                	sd	s0,8(sp)
    58da:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    58dc:	02b57463          	bgeu	a0,a1,5904 <memmove+0x2e>
    while(n-- > 0)
    58e0:	00c05f63          	blez	a2,58fe <memmove+0x28>
    58e4:	1602                	slli	a2,a2,0x20
    58e6:	9201                	srli	a2,a2,0x20
    58e8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    58ec:	872a                	mv	a4,a0
      *dst++ = *src++;
    58ee:	0585                	addi	a1,a1,1
    58f0:	0705                	addi	a4,a4,1
    58f2:	fff5c683          	lbu	a3,-1(a1)
    58f6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    58fa:	fee79ae3          	bne	a5,a4,58ee <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    58fe:	6422                	ld	s0,8(sp)
    5900:	0141                	addi	sp,sp,16
    5902:	8082                	ret
    dst += n;
    5904:	00c50733          	add	a4,a0,a2
    src += n;
    5908:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    590a:	fec05ae3          	blez	a2,58fe <memmove+0x28>
    590e:	fff6079b          	addiw	a5,a2,-1
    5912:	1782                	slli	a5,a5,0x20
    5914:	9381                	srli	a5,a5,0x20
    5916:	fff7c793          	not	a5,a5
    591a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    591c:	15fd                	addi	a1,a1,-1
    591e:	177d                	addi	a4,a4,-1
    5920:	0005c683          	lbu	a3,0(a1)
    5924:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5928:	fee79ae3          	bne	a5,a4,591c <memmove+0x46>
    592c:	bfc9                	j	58fe <memmove+0x28>

000000000000592e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    592e:	1141                	addi	sp,sp,-16
    5930:	e422                	sd	s0,8(sp)
    5932:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5934:	ca05                	beqz	a2,5964 <memcmp+0x36>
    5936:	fff6069b          	addiw	a3,a2,-1
    593a:	1682                	slli	a3,a3,0x20
    593c:	9281                	srli	a3,a3,0x20
    593e:	0685                	addi	a3,a3,1
    5940:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5942:	00054783          	lbu	a5,0(a0)
    5946:	0005c703          	lbu	a4,0(a1)
    594a:	00e79863          	bne	a5,a4,595a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    594e:	0505                	addi	a0,a0,1
    p2++;
    5950:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5952:	fed518e3          	bne	a0,a3,5942 <memcmp+0x14>
  }
  return 0;
    5956:	4501                	li	a0,0
    5958:	a019                	j	595e <memcmp+0x30>
      return *p1 - *p2;
    595a:	40e7853b          	subw	a0,a5,a4
}
    595e:	6422                	ld	s0,8(sp)
    5960:	0141                	addi	sp,sp,16
    5962:	8082                	ret
  return 0;
    5964:	4501                	li	a0,0
    5966:	bfe5                	j	595e <memcmp+0x30>

0000000000005968 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5968:	1141                	addi	sp,sp,-16
    596a:	e406                	sd	ra,8(sp)
    596c:	e022                	sd	s0,0(sp)
    596e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5970:	00000097          	auipc	ra,0x0
    5974:	f66080e7          	jalr	-154(ra) # 58d6 <memmove>
}
    5978:	60a2                	ld	ra,8(sp)
    597a:	6402                	ld	s0,0(sp)
    597c:	0141                	addi	sp,sp,16
    597e:	8082                	ret

0000000000005980 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5980:	4885                	li	a7,1
 ecall
    5982:	00000073          	ecall
 ret
    5986:	8082                	ret

0000000000005988 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5988:	4889                	li	a7,2
 ecall
    598a:	00000073          	ecall
 ret
    598e:	8082                	ret

0000000000005990 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5990:	488d                	li	a7,3
 ecall
    5992:	00000073          	ecall
 ret
    5996:	8082                	ret

0000000000005998 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5998:	4891                	li	a7,4
 ecall
    599a:	00000073          	ecall
 ret
    599e:	8082                	ret

00000000000059a0 <read>:
.global read
read:
 li a7, SYS_read
    59a0:	4895                	li	a7,5
 ecall
    59a2:	00000073          	ecall
 ret
    59a6:	8082                	ret

00000000000059a8 <write>:
.global write
write:
 li a7, SYS_write
    59a8:	48c1                	li	a7,16
 ecall
    59aa:	00000073          	ecall
 ret
    59ae:	8082                	ret

00000000000059b0 <close>:
.global close
close:
 li a7, SYS_close
    59b0:	48d5                	li	a7,21
 ecall
    59b2:	00000073          	ecall
 ret
    59b6:	8082                	ret

00000000000059b8 <kill>:
.global kill
kill:
 li a7, SYS_kill
    59b8:	4899                	li	a7,6
 ecall
    59ba:	00000073          	ecall
 ret
    59be:	8082                	ret

00000000000059c0 <exec>:
.global exec
exec:
 li a7, SYS_exec
    59c0:	489d                	li	a7,7
 ecall
    59c2:	00000073          	ecall
 ret
    59c6:	8082                	ret

00000000000059c8 <open>:
.global open
open:
 li a7, SYS_open
    59c8:	48bd                	li	a7,15
 ecall
    59ca:	00000073          	ecall
 ret
    59ce:	8082                	ret

00000000000059d0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    59d0:	48c5                	li	a7,17
 ecall
    59d2:	00000073          	ecall
 ret
    59d6:	8082                	ret

00000000000059d8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    59d8:	48c9                	li	a7,18
 ecall
    59da:	00000073          	ecall
 ret
    59de:	8082                	ret

00000000000059e0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    59e0:	48a1                	li	a7,8
 ecall
    59e2:	00000073          	ecall
 ret
    59e6:	8082                	ret

00000000000059e8 <link>:
.global link
link:
 li a7, SYS_link
    59e8:	48cd                	li	a7,19
 ecall
    59ea:	00000073          	ecall
 ret
    59ee:	8082                	ret

00000000000059f0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    59f0:	48d1                	li	a7,20
 ecall
    59f2:	00000073          	ecall
 ret
    59f6:	8082                	ret

00000000000059f8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    59f8:	48a5                	li	a7,9
 ecall
    59fa:	00000073          	ecall
 ret
    59fe:	8082                	ret

0000000000005a00 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5a00:	48a9                	li	a7,10
 ecall
    5a02:	00000073          	ecall
 ret
    5a06:	8082                	ret

0000000000005a08 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5a08:	48ad                	li	a7,11
 ecall
    5a0a:	00000073          	ecall
 ret
    5a0e:	8082                	ret

0000000000005a10 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5a10:	48b1                	li	a7,12
 ecall
    5a12:	00000073          	ecall
 ret
    5a16:	8082                	ret

0000000000005a18 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5a18:	48b5                	li	a7,13
 ecall
    5a1a:	00000073          	ecall
 ret
    5a1e:	8082                	ret

0000000000005a20 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5a20:	48b9                	li	a7,14
 ecall
    5a22:	00000073          	ecall
 ret
    5a26:	8082                	ret

0000000000005a28 <startlog>:
.global startlog
startlog:
 li a7, SYS_startlog
    5a28:	48d9                	li	a7,22
 ecall
    5a2a:	00000073          	ecall
 ret
    5a2e:	8082                	ret

0000000000005a30 <getlog>:
.global getlog
getlog:
 li a7, SYS_getlog
    5a30:	48dd                	li	a7,23
 ecall
    5a32:	00000073          	ecall
 ret
    5a36:	8082                	ret

0000000000005a38 <nice>:
.global nice
nice:
 li a7, SYS_nice
    5a38:	48e1                	li	a7,24
 ecall
    5a3a:	00000073          	ecall
 ret
    5a3e:	8082                	ret

0000000000005a40 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5a40:	1101                	addi	sp,sp,-32
    5a42:	ec06                	sd	ra,24(sp)
    5a44:	e822                	sd	s0,16(sp)
    5a46:	1000                	addi	s0,sp,32
    5a48:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5a4c:	4605                	li	a2,1
    5a4e:	fef40593          	addi	a1,s0,-17
    5a52:	00000097          	auipc	ra,0x0
    5a56:	f56080e7          	jalr	-170(ra) # 59a8 <write>
}
    5a5a:	60e2                	ld	ra,24(sp)
    5a5c:	6442                	ld	s0,16(sp)
    5a5e:	6105                	addi	sp,sp,32
    5a60:	8082                	ret

0000000000005a62 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5a62:	7139                	addi	sp,sp,-64
    5a64:	fc06                	sd	ra,56(sp)
    5a66:	f822                	sd	s0,48(sp)
    5a68:	f426                	sd	s1,40(sp)
    5a6a:	f04a                	sd	s2,32(sp)
    5a6c:	ec4e                	sd	s3,24(sp)
    5a6e:	0080                	addi	s0,sp,64
    5a70:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5a72:	c299                	beqz	a3,5a78 <printint+0x16>
    5a74:	0805c863          	bltz	a1,5b04 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5a78:	2581                	sext.w	a1,a1
  neg = 0;
    5a7a:	4881                	li	a7,0
    5a7c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5a80:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5a82:	2601                	sext.w	a2,a2
    5a84:	00003517          	auipc	a0,0x3
    5a88:	c5c50513          	addi	a0,a0,-932 # 86e0 <digits>
    5a8c:	883a                	mv	a6,a4
    5a8e:	2705                	addiw	a4,a4,1
    5a90:	02c5f7bb          	remuw	a5,a1,a2
    5a94:	1782                	slli	a5,a5,0x20
    5a96:	9381                	srli	a5,a5,0x20
    5a98:	97aa                	add	a5,a5,a0
    5a9a:	0007c783          	lbu	a5,0(a5)
    5a9e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5aa2:	0005879b          	sext.w	a5,a1
    5aa6:	02c5d5bb          	divuw	a1,a1,a2
    5aaa:	0685                	addi	a3,a3,1
    5aac:	fec7f0e3          	bgeu	a5,a2,5a8c <printint+0x2a>
  if(neg)
    5ab0:	00088b63          	beqz	a7,5ac6 <printint+0x64>
    buf[i++] = '-';
    5ab4:	fd040793          	addi	a5,s0,-48
    5ab8:	973e                	add	a4,a4,a5
    5aba:	02d00793          	li	a5,45
    5abe:	fef70823          	sb	a5,-16(a4)
    5ac2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5ac6:	02e05863          	blez	a4,5af6 <printint+0x94>
    5aca:	fc040793          	addi	a5,s0,-64
    5ace:	00e78933          	add	s2,a5,a4
    5ad2:	fff78993          	addi	s3,a5,-1
    5ad6:	99ba                	add	s3,s3,a4
    5ad8:	377d                	addiw	a4,a4,-1
    5ada:	1702                	slli	a4,a4,0x20
    5adc:	9301                	srli	a4,a4,0x20
    5ade:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5ae2:	fff94583          	lbu	a1,-1(s2)
    5ae6:	8526                	mv	a0,s1
    5ae8:	00000097          	auipc	ra,0x0
    5aec:	f58080e7          	jalr	-168(ra) # 5a40 <putc>
  while(--i >= 0)
    5af0:	197d                	addi	s2,s2,-1
    5af2:	ff3918e3          	bne	s2,s3,5ae2 <printint+0x80>
}
    5af6:	70e2                	ld	ra,56(sp)
    5af8:	7442                	ld	s0,48(sp)
    5afa:	74a2                	ld	s1,40(sp)
    5afc:	7902                	ld	s2,32(sp)
    5afe:	69e2                	ld	s3,24(sp)
    5b00:	6121                	addi	sp,sp,64
    5b02:	8082                	ret
    x = -xx;
    5b04:	40b005bb          	negw	a1,a1
    neg = 1;
    5b08:	4885                	li	a7,1
    x = -xx;
    5b0a:	bf8d                	j	5a7c <printint+0x1a>

0000000000005b0c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5b0c:	7119                	addi	sp,sp,-128
    5b0e:	fc86                	sd	ra,120(sp)
    5b10:	f8a2                	sd	s0,112(sp)
    5b12:	f4a6                	sd	s1,104(sp)
    5b14:	f0ca                	sd	s2,96(sp)
    5b16:	ecce                	sd	s3,88(sp)
    5b18:	e8d2                	sd	s4,80(sp)
    5b1a:	e4d6                	sd	s5,72(sp)
    5b1c:	e0da                	sd	s6,64(sp)
    5b1e:	fc5e                	sd	s7,56(sp)
    5b20:	f862                	sd	s8,48(sp)
    5b22:	f466                	sd	s9,40(sp)
    5b24:	f06a                	sd	s10,32(sp)
    5b26:	ec6e                	sd	s11,24(sp)
    5b28:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5b2a:	0005c903          	lbu	s2,0(a1)
    5b2e:	18090f63          	beqz	s2,5ccc <vprintf+0x1c0>
    5b32:	8aaa                	mv	s5,a0
    5b34:	8b32                	mv	s6,a2
    5b36:	00158493          	addi	s1,a1,1
  state = 0;
    5b3a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5b3c:	02500a13          	li	s4,37
      if(c == 'd'){
    5b40:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5b44:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5b48:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5b4c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5b50:	00003b97          	auipc	s7,0x3
    5b54:	b90b8b93          	addi	s7,s7,-1136 # 86e0 <digits>
    5b58:	a839                	j	5b76 <vprintf+0x6a>
        putc(fd, c);
    5b5a:	85ca                	mv	a1,s2
    5b5c:	8556                	mv	a0,s5
    5b5e:	00000097          	auipc	ra,0x0
    5b62:	ee2080e7          	jalr	-286(ra) # 5a40 <putc>
    5b66:	a019                	j	5b6c <vprintf+0x60>
    } else if(state == '%'){
    5b68:	01498f63          	beq	s3,s4,5b86 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5b6c:	0485                	addi	s1,s1,1
    5b6e:	fff4c903          	lbu	s2,-1(s1)
    5b72:	14090d63          	beqz	s2,5ccc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5b76:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5b7a:	fe0997e3          	bnez	s3,5b68 <vprintf+0x5c>
      if(c == '%'){
    5b7e:	fd479ee3          	bne	a5,s4,5b5a <vprintf+0x4e>
        state = '%';
    5b82:	89be                	mv	s3,a5
    5b84:	b7e5                	j	5b6c <vprintf+0x60>
      if(c == 'd'){
    5b86:	05878063          	beq	a5,s8,5bc6 <vprintf+0xba>
      } else if(c == 'l') {
    5b8a:	05978c63          	beq	a5,s9,5be2 <vprintf+0xd6>
      } else if(c == 'x') {
    5b8e:	07a78863          	beq	a5,s10,5bfe <vprintf+0xf2>
      } else if(c == 'p') {
    5b92:	09b78463          	beq	a5,s11,5c1a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5b96:	07300713          	li	a4,115
    5b9a:	0ce78663          	beq	a5,a4,5c66 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5b9e:	06300713          	li	a4,99
    5ba2:	0ee78e63          	beq	a5,a4,5c9e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5ba6:	11478863          	beq	a5,s4,5cb6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5baa:	85d2                	mv	a1,s4
    5bac:	8556                	mv	a0,s5
    5bae:	00000097          	auipc	ra,0x0
    5bb2:	e92080e7          	jalr	-366(ra) # 5a40 <putc>
        putc(fd, c);
    5bb6:	85ca                	mv	a1,s2
    5bb8:	8556                	mv	a0,s5
    5bba:	00000097          	auipc	ra,0x0
    5bbe:	e86080e7          	jalr	-378(ra) # 5a40 <putc>
      }
      state = 0;
    5bc2:	4981                	li	s3,0
    5bc4:	b765                	j	5b6c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5bc6:	008b0913          	addi	s2,s6,8
    5bca:	4685                	li	a3,1
    5bcc:	4629                	li	a2,10
    5bce:	000b2583          	lw	a1,0(s6)
    5bd2:	8556                	mv	a0,s5
    5bd4:	00000097          	auipc	ra,0x0
    5bd8:	e8e080e7          	jalr	-370(ra) # 5a62 <printint>
    5bdc:	8b4a                	mv	s6,s2
      state = 0;
    5bde:	4981                	li	s3,0
    5be0:	b771                	j	5b6c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5be2:	008b0913          	addi	s2,s6,8
    5be6:	4681                	li	a3,0
    5be8:	4629                	li	a2,10
    5bea:	000b2583          	lw	a1,0(s6)
    5bee:	8556                	mv	a0,s5
    5bf0:	00000097          	auipc	ra,0x0
    5bf4:	e72080e7          	jalr	-398(ra) # 5a62 <printint>
    5bf8:	8b4a                	mv	s6,s2
      state = 0;
    5bfa:	4981                	li	s3,0
    5bfc:	bf85                	j	5b6c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5bfe:	008b0913          	addi	s2,s6,8
    5c02:	4681                	li	a3,0
    5c04:	4641                	li	a2,16
    5c06:	000b2583          	lw	a1,0(s6)
    5c0a:	8556                	mv	a0,s5
    5c0c:	00000097          	auipc	ra,0x0
    5c10:	e56080e7          	jalr	-426(ra) # 5a62 <printint>
    5c14:	8b4a                	mv	s6,s2
      state = 0;
    5c16:	4981                	li	s3,0
    5c18:	bf91                	j	5b6c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5c1a:	008b0793          	addi	a5,s6,8
    5c1e:	f8f43423          	sd	a5,-120(s0)
    5c22:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5c26:	03000593          	li	a1,48
    5c2a:	8556                	mv	a0,s5
    5c2c:	00000097          	auipc	ra,0x0
    5c30:	e14080e7          	jalr	-492(ra) # 5a40 <putc>
  putc(fd, 'x');
    5c34:	85ea                	mv	a1,s10
    5c36:	8556                	mv	a0,s5
    5c38:	00000097          	auipc	ra,0x0
    5c3c:	e08080e7          	jalr	-504(ra) # 5a40 <putc>
    5c40:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5c42:	03c9d793          	srli	a5,s3,0x3c
    5c46:	97de                	add	a5,a5,s7
    5c48:	0007c583          	lbu	a1,0(a5)
    5c4c:	8556                	mv	a0,s5
    5c4e:	00000097          	auipc	ra,0x0
    5c52:	df2080e7          	jalr	-526(ra) # 5a40 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5c56:	0992                	slli	s3,s3,0x4
    5c58:	397d                	addiw	s2,s2,-1
    5c5a:	fe0914e3          	bnez	s2,5c42 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5c5e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5c62:	4981                	li	s3,0
    5c64:	b721                	j	5b6c <vprintf+0x60>
        s = va_arg(ap, char*);
    5c66:	008b0993          	addi	s3,s6,8
    5c6a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5c6e:	02090163          	beqz	s2,5c90 <vprintf+0x184>
        while(*s != 0){
    5c72:	00094583          	lbu	a1,0(s2)
    5c76:	c9a1                	beqz	a1,5cc6 <vprintf+0x1ba>
          putc(fd, *s);
    5c78:	8556                	mv	a0,s5
    5c7a:	00000097          	auipc	ra,0x0
    5c7e:	dc6080e7          	jalr	-570(ra) # 5a40 <putc>
          s++;
    5c82:	0905                	addi	s2,s2,1
        while(*s != 0){
    5c84:	00094583          	lbu	a1,0(s2)
    5c88:	f9e5                	bnez	a1,5c78 <vprintf+0x16c>
        s = va_arg(ap, char*);
    5c8a:	8b4e                	mv	s6,s3
      state = 0;
    5c8c:	4981                	li	s3,0
    5c8e:	bdf9                	j	5b6c <vprintf+0x60>
          s = "(null)";
    5c90:	00003917          	auipc	s2,0x3
    5c94:	a4890913          	addi	s2,s2,-1464 # 86d8 <malloc+0x2902>
        while(*s != 0){
    5c98:	02800593          	li	a1,40
    5c9c:	bff1                	j	5c78 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5c9e:	008b0913          	addi	s2,s6,8
    5ca2:	000b4583          	lbu	a1,0(s6)
    5ca6:	8556                	mv	a0,s5
    5ca8:	00000097          	auipc	ra,0x0
    5cac:	d98080e7          	jalr	-616(ra) # 5a40 <putc>
    5cb0:	8b4a                	mv	s6,s2
      state = 0;
    5cb2:	4981                	li	s3,0
    5cb4:	bd65                	j	5b6c <vprintf+0x60>
        putc(fd, c);
    5cb6:	85d2                	mv	a1,s4
    5cb8:	8556                	mv	a0,s5
    5cba:	00000097          	auipc	ra,0x0
    5cbe:	d86080e7          	jalr	-634(ra) # 5a40 <putc>
      state = 0;
    5cc2:	4981                	li	s3,0
    5cc4:	b565                	j	5b6c <vprintf+0x60>
        s = va_arg(ap, char*);
    5cc6:	8b4e                	mv	s6,s3
      state = 0;
    5cc8:	4981                	li	s3,0
    5cca:	b54d                	j	5b6c <vprintf+0x60>
    }
  }
}
    5ccc:	70e6                	ld	ra,120(sp)
    5cce:	7446                	ld	s0,112(sp)
    5cd0:	74a6                	ld	s1,104(sp)
    5cd2:	7906                	ld	s2,96(sp)
    5cd4:	69e6                	ld	s3,88(sp)
    5cd6:	6a46                	ld	s4,80(sp)
    5cd8:	6aa6                	ld	s5,72(sp)
    5cda:	6b06                	ld	s6,64(sp)
    5cdc:	7be2                	ld	s7,56(sp)
    5cde:	7c42                	ld	s8,48(sp)
    5ce0:	7ca2                	ld	s9,40(sp)
    5ce2:	7d02                	ld	s10,32(sp)
    5ce4:	6de2                	ld	s11,24(sp)
    5ce6:	6109                	addi	sp,sp,128
    5ce8:	8082                	ret

0000000000005cea <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5cea:	715d                	addi	sp,sp,-80
    5cec:	ec06                	sd	ra,24(sp)
    5cee:	e822                	sd	s0,16(sp)
    5cf0:	1000                	addi	s0,sp,32
    5cf2:	e010                	sd	a2,0(s0)
    5cf4:	e414                	sd	a3,8(s0)
    5cf6:	e818                	sd	a4,16(s0)
    5cf8:	ec1c                	sd	a5,24(s0)
    5cfa:	03043023          	sd	a6,32(s0)
    5cfe:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5d02:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5d06:	8622                	mv	a2,s0
    5d08:	00000097          	auipc	ra,0x0
    5d0c:	e04080e7          	jalr	-508(ra) # 5b0c <vprintf>
}
    5d10:	60e2                	ld	ra,24(sp)
    5d12:	6442                	ld	s0,16(sp)
    5d14:	6161                	addi	sp,sp,80
    5d16:	8082                	ret

0000000000005d18 <printf>:

void
printf(const char *fmt, ...)
{
    5d18:	711d                	addi	sp,sp,-96
    5d1a:	ec06                	sd	ra,24(sp)
    5d1c:	e822                	sd	s0,16(sp)
    5d1e:	1000                	addi	s0,sp,32
    5d20:	e40c                	sd	a1,8(s0)
    5d22:	e810                	sd	a2,16(s0)
    5d24:	ec14                	sd	a3,24(s0)
    5d26:	f018                	sd	a4,32(s0)
    5d28:	f41c                	sd	a5,40(s0)
    5d2a:	03043823          	sd	a6,48(s0)
    5d2e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5d32:	00840613          	addi	a2,s0,8
    5d36:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5d3a:	85aa                	mv	a1,a0
    5d3c:	4505                	li	a0,1
    5d3e:	00000097          	auipc	ra,0x0
    5d42:	dce080e7          	jalr	-562(ra) # 5b0c <vprintf>
}
    5d46:	60e2                	ld	ra,24(sp)
    5d48:	6442                	ld	s0,16(sp)
    5d4a:	6125                	addi	sp,sp,96
    5d4c:	8082                	ret

0000000000005d4e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5d4e:	1141                	addi	sp,sp,-16
    5d50:	e422                	sd	s0,8(sp)
    5d52:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5d54:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5d58:	00003797          	auipc	a5,0x3
    5d5c:	9a87b783          	ld	a5,-1624(a5) # 8700 <freep>
    5d60:	a805                	j	5d90 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5d62:	4618                	lw	a4,8(a2)
    5d64:	9db9                	addw	a1,a1,a4
    5d66:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5d6a:	6398                	ld	a4,0(a5)
    5d6c:	6318                	ld	a4,0(a4)
    5d6e:	fee53823          	sd	a4,-16(a0)
    5d72:	a091                	j	5db6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5d74:	ff852703          	lw	a4,-8(a0)
    5d78:	9e39                	addw	a2,a2,a4
    5d7a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5d7c:	ff053703          	ld	a4,-16(a0)
    5d80:	e398                	sd	a4,0(a5)
    5d82:	a099                	j	5dc8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5d84:	6398                	ld	a4,0(a5)
    5d86:	00e7e463          	bltu	a5,a4,5d8e <free+0x40>
    5d8a:	00e6ea63          	bltu	a3,a4,5d9e <free+0x50>
{
    5d8e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5d90:	fed7fae3          	bgeu	a5,a3,5d84 <free+0x36>
    5d94:	6398                	ld	a4,0(a5)
    5d96:	00e6e463          	bltu	a3,a4,5d9e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5d9a:	fee7eae3          	bltu	a5,a4,5d8e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5d9e:	ff852583          	lw	a1,-8(a0)
    5da2:	6390                	ld	a2,0(a5)
    5da4:	02059713          	slli	a4,a1,0x20
    5da8:	9301                	srli	a4,a4,0x20
    5daa:	0712                	slli	a4,a4,0x4
    5dac:	9736                	add	a4,a4,a3
    5dae:	fae60ae3          	beq	a2,a4,5d62 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5db2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5db6:	4790                	lw	a2,8(a5)
    5db8:	02061713          	slli	a4,a2,0x20
    5dbc:	9301                	srli	a4,a4,0x20
    5dbe:	0712                	slli	a4,a4,0x4
    5dc0:	973e                	add	a4,a4,a5
    5dc2:	fae689e3          	beq	a3,a4,5d74 <free+0x26>
  } else
    p->s.ptr = bp;
    5dc6:	e394                	sd	a3,0(a5)
  freep = p;
    5dc8:	00003717          	auipc	a4,0x3
    5dcc:	92f73c23          	sd	a5,-1736(a4) # 8700 <freep>
}
    5dd0:	6422                	ld	s0,8(sp)
    5dd2:	0141                	addi	sp,sp,16
    5dd4:	8082                	ret

0000000000005dd6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5dd6:	7139                	addi	sp,sp,-64
    5dd8:	fc06                	sd	ra,56(sp)
    5dda:	f822                	sd	s0,48(sp)
    5ddc:	f426                	sd	s1,40(sp)
    5dde:	f04a                	sd	s2,32(sp)
    5de0:	ec4e                	sd	s3,24(sp)
    5de2:	e852                	sd	s4,16(sp)
    5de4:	e456                	sd	s5,8(sp)
    5de6:	e05a                	sd	s6,0(sp)
    5de8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5dea:	02051493          	slli	s1,a0,0x20
    5dee:	9081                	srli	s1,s1,0x20
    5df0:	04bd                	addi	s1,s1,15
    5df2:	8091                	srli	s1,s1,0x4
    5df4:	0014899b          	addiw	s3,s1,1
    5df8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5dfa:	00003517          	auipc	a0,0x3
    5dfe:	90653503          	ld	a0,-1786(a0) # 8700 <freep>
    5e02:	c515                	beqz	a0,5e2e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5e04:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5e06:	4798                	lw	a4,8(a5)
    5e08:	02977f63          	bgeu	a4,s1,5e46 <malloc+0x70>
    5e0c:	8a4e                	mv	s4,s3
    5e0e:	0009871b          	sext.w	a4,s3
    5e12:	6685                	lui	a3,0x1
    5e14:	00d77363          	bgeu	a4,a3,5e1a <malloc+0x44>
    5e18:	6a05                	lui	s4,0x1
    5e1a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5e1e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5e22:	00003917          	auipc	s2,0x3
    5e26:	8de90913          	addi	s2,s2,-1826 # 8700 <freep>
  if(p == (char*)-1)
    5e2a:	5afd                	li	s5,-1
    5e2c:	a88d                	j	5e9e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5e2e:	00009797          	auipc	a5,0x9
    5e32:	0f278793          	addi	a5,a5,242 # ef20 <base>
    5e36:	00003717          	auipc	a4,0x3
    5e3a:	8cf73523          	sd	a5,-1846(a4) # 8700 <freep>
    5e3e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5e40:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5e44:	b7e1                	j	5e0c <malloc+0x36>
      if(p->s.size == nunits)
    5e46:	02e48b63          	beq	s1,a4,5e7c <malloc+0xa6>
        p->s.size -= nunits;
    5e4a:	4137073b          	subw	a4,a4,s3
    5e4e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5e50:	1702                	slli	a4,a4,0x20
    5e52:	9301                	srli	a4,a4,0x20
    5e54:	0712                	slli	a4,a4,0x4
    5e56:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5e58:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5e5c:	00003717          	auipc	a4,0x3
    5e60:	8aa73223          	sd	a0,-1884(a4) # 8700 <freep>
      return (void*)(p + 1);
    5e64:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5e68:	70e2                	ld	ra,56(sp)
    5e6a:	7442                	ld	s0,48(sp)
    5e6c:	74a2                	ld	s1,40(sp)
    5e6e:	7902                	ld	s2,32(sp)
    5e70:	69e2                	ld	s3,24(sp)
    5e72:	6a42                	ld	s4,16(sp)
    5e74:	6aa2                	ld	s5,8(sp)
    5e76:	6b02                	ld	s6,0(sp)
    5e78:	6121                	addi	sp,sp,64
    5e7a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5e7c:	6398                	ld	a4,0(a5)
    5e7e:	e118                	sd	a4,0(a0)
    5e80:	bff1                	j	5e5c <malloc+0x86>
  hp->s.size = nu;
    5e82:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5e86:	0541                	addi	a0,a0,16
    5e88:	00000097          	auipc	ra,0x0
    5e8c:	ec6080e7          	jalr	-314(ra) # 5d4e <free>
  return freep;
    5e90:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5e94:	d971                	beqz	a0,5e68 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5e96:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5e98:	4798                	lw	a4,8(a5)
    5e9a:	fa9776e3          	bgeu	a4,s1,5e46 <malloc+0x70>
    if(p == freep)
    5e9e:	00093703          	ld	a4,0(s2)
    5ea2:	853e                	mv	a0,a5
    5ea4:	fef719e3          	bne	a4,a5,5e96 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    5ea8:	8552                	mv	a0,s4
    5eaa:	00000097          	auipc	ra,0x0
    5eae:	b66080e7          	jalr	-1178(ra) # 5a10 <sbrk>
  if(p == (char*)-1)
    5eb2:	fd5518e3          	bne	a0,s5,5e82 <malloc+0xac>
        return 0;
    5eb6:	4501                	li	a0,0
    5eb8:	bf45                	j	5e68 <malloc+0x92>
