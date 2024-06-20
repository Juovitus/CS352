
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7175                	addi	sp,sp,-144
   2:	e506                	sd	ra,136(sp)
   4:	e122                	sd	s0,128(sp)
   6:	fca6                	sd	s1,120(sp)
   8:	f8ca                	sd	s2,112(sp)
   a:	f4ce                	sd	s3,104(sp)
   c:	f0d2                	sd	s4,96(sp)
   e:	ecd6                	sd	s5,88(sp)
  10:	e8da                	sd	s6,80(sp)
  12:	e4de                	sd	s7,72(sp)
  14:	e0e2                	sd	s8,64(sp)
  16:	fc66                	sd	s9,56(sp)
  18:	f86a                	sd	s10,48(sp)
  1a:	f46e                	sd	s11,40(sp)
  1c:	0900                	addi	s0,sp,144
  1e:	f8a43023          	sd	a0,-128(s0)
  22:	f6b43c23          	sd	a1,-136(s0)
  int i, n;
  //Added another variable here number of vowels->v
  int l, w, c, inword, v;

  l = w = c = v = 0;
  26:	4981                	li	s3,0
  inword = 0;
  28:	4a01                	li	s4,0
  l = w = c = v = 0;
  2a:	f8043423          	sd	zero,-120(s0)
  2e:	4d01                	li	s10,0
  30:	4c01                	li	s8,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  32:	4b29                	li	s6,10
        l++;
      //Going to just add functionality here to find number of vowels
      if(buf[i] == 'a' || buf[i] == 'A' || buf[i] == 'e' || buf[i] == 'E' || buf[i] == 'i' || buf[i] == 'I' || buf[i] == 'o' || buf[i] == 'O' || buf[i] == 'u' || buf[i] == 'U')
  34:	03400b93          	li	s7,52
  38:	00001c97          	auipc	s9,0x1
  3c:	9b8c8c93          	addi	s9,s9,-1608 # 9f0 <__SDATA_BEGIN__>
        v++;
      if(strchr(" \r\t\n\v", buf[i]))
  40:	00001a97          	auipc	s5,0x1
  44:	948a8a93          	addi	s5,s5,-1720 # 988 <malloc+0xe6>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  48:	a891                	j	9c <wc+0x9c>
        l++;
  4a:	2c05                	addiw	s8,s8,1
      if(buf[i] == 'a' || buf[i] == 'A' || buf[i] == 'e' || buf[i] == 'E' || buf[i] == 'i' || buf[i] == 'I' || buf[i] == 'o' || buf[i] == 'O' || buf[i] == 'u' || buf[i] == 'U')
  4c:	a011                	j	50 <wc+0x50>
        v++;
  4e:	2985                	addiw	s3,s3,1
      if(strchr(" \r\t\n\v", buf[i]))
  50:	8556                	mv	a0,s5
  52:	00000097          	auipc	ra,0x0
  56:	228080e7          	jalr	552(ra) # 27a <strchr>
  5a:	c515                	beqz	a0,86 <wc+0x86>
        inword = 0;
  5c:	4a01                	li	s4,0
    for(i=0; i<n; i++){
  5e:	0485                	addi	s1,s1,1
  60:	03248863          	beq	s1,s2,90 <wc+0x90>
      if(buf[i] == '\n')
  64:	0004c583          	lbu	a1,0(s1)
  68:	ff6581e3          	beq	a1,s6,4a <wc+0x4a>
      if(buf[i] == 'a' || buf[i] == 'A' || buf[i] == 'e' || buf[i] == 'E' || buf[i] == 'i' || buf[i] == 'I' || buf[i] == 'o' || buf[i] == 'O' || buf[i] == 'u' || buf[i] == 'U')
  6c:	fbf5879b          	addiw	a5,a1,-65
  70:	0ff7f793          	andi	a5,a5,255
  74:	fcfbeee3          	bltu	s7,a5,50 <wc+0x50>
  78:	000cb703          	ld	a4,0(s9)
  7c:	00f757b3          	srl	a5,a4,a5
  80:	8b85                	andi	a5,a5,1
  82:	f7f1                	bnez	a5,4e <wc+0x4e>
  84:	b7f1                	j	50 <wc+0x50>
      else if(!inword){
  86:	fc0a1ce3          	bnez	s4,5e <wc+0x5e>
        w++;
  8a:	2d05                	addiw	s10,s10,1
        inword = 1;
  8c:	4a05                	li	s4,1
  8e:	bfc1                	j	5e <wc+0x5e>
      c++;
  90:	f8843783          	ld	a5,-120(s0)
  94:	01b787bb          	addw	a5,a5,s11
  98:	f8f43423          	sd	a5,-120(s0)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  9c:	20000613          	li	a2,512
  a0:	00001597          	auipc	a1,0x1
  a4:	96058593          	addi	a1,a1,-1696 # a00 <buf>
  a8:	f8043503          	ld	a0,-128(s0)
  ac:	00000097          	auipc	ra,0x0
  b0:	3c0080e7          	jalr	960(ra) # 46c <read>
  b4:	02a05363          	blez	a0,da <wc+0xda>
  b8:	00001497          	auipc	s1,0x1
  bc:	94848493          	addi	s1,s1,-1720 # a00 <buf>
  c0:	00050d9b          	sext.w	s11,a0
  c4:	fff5091b          	addiw	s2,a0,-1
  c8:	1902                	slli	s2,s2,0x20
  ca:	02095913          	srli	s2,s2,0x20
  ce:	00001797          	auipc	a5,0x1
  d2:	93378793          	addi	a5,a5,-1741 # a01 <buf+0x1>
  d6:	993e                	add	s2,s2,a5
  d8:	b771                	j	64 <wc+0x64>
      }
    }
  }
  if(n < 0){
  da:	04054063          	bltz	a0,11a <wc+0x11a>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %d %s\n", l, w, c, v, name);
  de:	f7843783          	ld	a5,-136(s0)
  e2:	874e                	mv	a4,s3
  e4:	f8843683          	ld	a3,-120(s0)
  e8:	866a                	mv	a2,s10
  ea:	85e2                	mv	a1,s8
  ec:	00001517          	auipc	a0,0x1
  f0:	8b450513          	addi	a0,a0,-1868 # 9a0 <malloc+0xfe>
  f4:	00000097          	auipc	ra,0x0
  f8:	6f0080e7          	jalr	1776(ra) # 7e4 <printf>
}
  fc:	60aa                	ld	ra,136(sp)
  fe:	640a                	ld	s0,128(sp)
 100:	74e6                	ld	s1,120(sp)
 102:	7946                	ld	s2,112(sp)
 104:	79a6                	ld	s3,104(sp)
 106:	7a06                	ld	s4,96(sp)
 108:	6ae6                	ld	s5,88(sp)
 10a:	6b46                	ld	s6,80(sp)
 10c:	6ba6                	ld	s7,72(sp)
 10e:	6c06                	ld	s8,64(sp)
 110:	7ce2                	ld	s9,56(sp)
 112:	7d42                	ld	s10,48(sp)
 114:	7da2                	ld	s11,40(sp)
 116:	6149                	addi	sp,sp,144
 118:	8082                	ret
    printf("wc: read error\n");
 11a:	00001517          	auipc	a0,0x1
 11e:	87650513          	addi	a0,a0,-1930 # 990 <malloc+0xee>
 122:	00000097          	auipc	ra,0x0
 126:	6c2080e7          	jalr	1730(ra) # 7e4 <printf>
    exit(1);
 12a:	4505                	li	a0,1
 12c:	00000097          	auipc	ra,0x0
 130:	328080e7          	jalr	808(ra) # 454 <exit>

0000000000000134 <main>:

int
main(int argc, char *argv[])
{
 134:	7179                	addi	sp,sp,-48
 136:	f406                	sd	ra,40(sp)
 138:	f022                	sd	s0,32(sp)
 13a:	ec26                	sd	s1,24(sp)
 13c:	e84a                	sd	s2,16(sp)
 13e:	e44e                	sd	s3,8(sp)
 140:	e052                	sd	s4,0(sp)
 142:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
 144:	4785                	li	a5,1
 146:	04a7d763          	bge	a5,a0,194 <main+0x60>
 14a:	00858493          	addi	s1,a1,8
 14e:	ffe5099b          	addiw	s3,a0,-2
 152:	1982                	slli	s3,s3,0x20
 154:	0209d993          	srli	s3,s3,0x20
 158:	098e                	slli	s3,s3,0x3
 15a:	05c1                	addi	a1,a1,16
 15c:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 15e:	4581                	li	a1,0
 160:	6088                	ld	a0,0(s1)
 162:	00000097          	auipc	ra,0x0
 166:	332080e7          	jalr	818(ra) # 494 <open>
 16a:	892a                	mv	s2,a0
 16c:	04054263          	bltz	a0,1b0 <main+0x7c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 170:	608c                	ld	a1,0(s1)
 172:	00000097          	auipc	ra,0x0
 176:	e8e080e7          	jalr	-370(ra) # 0 <wc>
    close(fd);
 17a:	854a                	mv	a0,s2
 17c:	00000097          	auipc	ra,0x0
 180:	300080e7          	jalr	768(ra) # 47c <close>
  for(i = 1; i < argc; i++){
 184:	04a1                	addi	s1,s1,8
 186:	fd349ce3          	bne	s1,s3,15e <main+0x2a>
  }
  exit(0);
 18a:	4501                	li	a0,0
 18c:	00000097          	auipc	ra,0x0
 190:	2c8080e7          	jalr	712(ra) # 454 <exit>
    wc(0, "");
 194:	00001597          	auipc	a1,0x1
 198:	81c58593          	addi	a1,a1,-2020 # 9b0 <malloc+0x10e>
 19c:	4501                	li	a0,0
 19e:	00000097          	auipc	ra,0x0
 1a2:	e62080e7          	jalr	-414(ra) # 0 <wc>
    exit(0);
 1a6:	4501                	li	a0,0
 1a8:	00000097          	auipc	ra,0x0
 1ac:	2ac080e7          	jalr	684(ra) # 454 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 1b0:	608c                	ld	a1,0(s1)
 1b2:	00001517          	auipc	a0,0x1
 1b6:	80650513          	addi	a0,a0,-2042 # 9b8 <malloc+0x116>
 1ba:	00000097          	auipc	ra,0x0
 1be:	62a080e7          	jalr	1578(ra) # 7e4 <printf>
      exit(1);
 1c2:	4505                	li	a0,1
 1c4:	00000097          	auipc	ra,0x0
 1c8:	290080e7          	jalr	656(ra) # 454 <exit>

00000000000001cc <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e406                	sd	ra,8(sp)
 1d0:	e022                	sd	s0,0(sp)
 1d2:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1d4:	00000097          	auipc	ra,0x0
 1d8:	f60080e7          	jalr	-160(ra) # 134 <main>
  exit(0);
 1dc:	4501                	li	a0,0
 1de:	00000097          	auipc	ra,0x0
 1e2:	276080e7          	jalr	630(ra) # 454 <exit>

00000000000001e6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1e6:	1141                	addi	sp,sp,-16
 1e8:	e422                	sd	s0,8(sp)
 1ea:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ec:	87aa                	mv	a5,a0
 1ee:	0585                	addi	a1,a1,1
 1f0:	0785                	addi	a5,a5,1
 1f2:	fff5c703          	lbu	a4,-1(a1)
 1f6:	fee78fa3          	sb	a4,-1(a5)
 1fa:	fb75                	bnez	a4,1ee <strcpy+0x8>
    ;
  return os;
}
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret

0000000000000202 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 208:	00054783          	lbu	a5,0(a0)
 20c:	cb91                	beqz	a5,220 <strcmp+0x1e>
 20e:	0005c703          	lbu	a4,0(a1)
 212:	00f71763          	bne	a4,a5,220 <strcmp+0x1e>
    p++, q++;
 216:	0505                	addi	a0,a0,1
 218:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 21a:	00054783          	lbu	a5,0(a0)
 21e:	fbe5                	bnez	a5,20e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 220:	0005c503          	lbu	a0,0(a1)
}
 224:	40a7853b          	subw	a0,a5,a0
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret

000000000000022e <strlen>:

uint
strlen(const char *s)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 234:	00054783          	lbu	a5,0(a0)
 238:	cf91                	beqz	a5,254 <strlen+0x26>
 23a:	0505                	addi	a0,a0,1
 23c:	87aa                	mv	a5,a0
 23e:	4685                	li	a3,1
 240:	9e89                	subw	a3,a3,a0
 242:	00f6853b          	addw	a0,a3,a5
 246:	0785                	addi	a5,a5,1
 248:	fff7c703          	lbu	a4,-1(a5)
 24c:	fb7d                	bnez	a4,242 <strlen+0x14>
    ;
  return n;
}
 24e:	6422                	ld	s0,8(sp)
 250:	0141                	addi	sp,sp,16
 252:	8082                	ret
  for(n = 0; s[n]; n++)
 254:	4501                	li	a0,0
 256:	bfe5                	j	24e <strlen+0x20>

0000000000000258 <memset>:

void*
memset(void *dst, int c, uint n)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 25e:	ca19                	beqz	a2,274 <memset+0x1c>
 260:	87aa                	mv	a5,a0
 262:	1602                	slli	a2,a2,0x20
 264:	9201                	srli	a2,a2,0x20
 266:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 26a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 26e:	0785                	addi	a5,a5,1
 270:	fee79de3          	bne	a5,a4,26a <memset+0x12>
  }
  return dst;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret

000000000000027a <strchr>:

char*
strchr(const char *s, char c)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 280:	00054783          	lbu	a5,0(a0)
 284:	cb99                	beqz	a5,29a <strchr+0x20>
    if(*s == c)
 286:	00f58763          	beq	a1,a5,294 <strchr+0x1a>
  for(; *s; s++)
 28a:	0505                	addi	a0,a0,1
 28c:	00054783          	lbu	a5,0(a0)
 290:	fbfd                	bnez	a5,286 <strchr+0xc>
      return (char*)s;
  return 0;
 292:	4501                	li	a0,0
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
  return 0;
 29a:	4501                	li	a0,0
 29c:	bfe5                	j	294 <strchr+0x1a>

000000000000029e <gets>:

char*
gets(char *buf, int max)
{
 29e:	711d                	addi	sp,sp,-96
 2a0:	ec86                	sd	ra,88(sp)
 2a2:	e8a2                	sd	s0,80(sp)
 2a4:	e4a6                	sd	s1,72(sp)
 2a6:	e0ca                	sd	s2,64(sp)
 2a8:	fc4e                	sd	s3,56(sp)
 2aa:	f852                	sd	s4,48(sp)
 2ac:	f456                	sd	s5,40(sp)
 2ae:	f05a                	sd	s6,32(sp)
 2b0:	ec5e                	sd	s7,24(sp)
 2b2:	1080                	addi	s0,sp,96
 2b4:	8baa                	mv	s7,a0
 2b6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b8:	892a                	mv	s2,a0
 2ba:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2bc:	4aa9                	li	s5,10
 2be:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2c0:	89a6                	mv	s3,s1
 2c2:	2485                	addiw	s1,s1,1
 2c4:	0344d863          	bge	s1,s4,2f4 <gets+0x56>
    cc = read(0, &c, 1);
 2c8:	4605                	li	a2,1
 2ca:	faf40593          	addi	a1,s0,-81
 2ce:	4501                	li	a0,0
 2d0:	00000097          	auipc	ra,0x0
 2d4:	19c080e7          	jalr	412(ra) # 46c <read>
    if(cc < 1)
 2d8:	00a05e63          	blez	a0,2f4 <gets+0x56>
    buf[i++] = c;
 2dc:	faf44783          	lbu	a5,-81(s0)
 2e0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2e4:	01578763          	beq	a5,s5,2f2 <gets+0x54>
 2e8:	0905                	addi	s2,s2,1
 2ea:	fd679be3          	bne	a5,s6,2c0 <gets+0x22>
  for(i=0; i+1 < max; ){
 2ee:	89a6                	mv	s3,s1
 2f0:	a011                	j	2f4 <gets+0x56>
 2f2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2f4:	99de                	add	s3,s3,s7
 2f6:	00098023          	sb	zero,0(s3)
  return buf;
}
 2fa:	855e                	mv	a0,s7
 2fc:	60e6                	ld	ra,88(sp)
 2fe:	6446                	ld	s0,80(sp)
 300:	64a6                	ld	s1,72(sp)
 302:	6906                	ld	s2,64(sp)
 304:	79e2                	ld	s3,56(sp)
 306:	7a42                	ld	s4,48(sp)
 308:	7aa2                	ld	s5,40(sp)
 30a:	7b02                	ld	s6,32(sp)
 30c:	6be2                	ld	s7,24(sp)
 30e:	6125                	addi	sp,sp,96
 310:	8082                	ret

0000000000000312 <stat>:

int
stat(const char *n, struct stat *st)
{
 312:	1101                	addi	sp,sp,-32
 314:	ec06                	sd	ra,24(sp)
 316:	e822                	sd	s0,16(sp)
 318:	e426                	sd	s1,8(sp)
 31a:	e04a                	sd	s2,0(sp)
 31c:	1000                	addi	s0,sp,32
 31e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 320:	4581                	li	a1,0
 322:	00000097          	auipc	ra,0x0
 326:	172080e7          	jalr	370(ra) # 494 <open>
  if(fd < 0)
 32a:	02054563          	bltz	a0,354 <stat+0x42>
 32e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 330:	85ca                	mv	a1,s2
 332:	00000097          	auipc	ra,0x0
 336:	17a080e7          	jalr	378(ra) # 4ac <fstat>
 33a:	892a                	mv	s2,a0
  close(fd);
 33c:	8526                	mv	a0,s1
 33e:	00000097          	auipc	ra,0x0
 342:	13e080e7          	jalr	318(ra) # 47c <close>
  return r;
}
 346:	854a                	mv	a0,s2
 348:	60e2                	ld	ra,24(sp)
 34a:	6442                	ld	s0,16(sp)
 34c:	64a2                	ld	s1,8(sp)
 34e:	6902                	ld	s2,0(sp)
 350:	6105                	addi	sp,sp,32
 352:	8082                	ret
    return -1;
 354:	597d                	li	s2,-1
 356:	bfc5                	j	346 <stat+0x34>

0000000000000358 <atoi>:

int
atoi(const char *s)
{
 358:	1141                	addi	sp,sp,-16
 35a:	e422                	sd	s0,8(sp)
 35c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 35e:	00054603          	lbu	a2,0(a0)
 362:	fd06079b          	addiw	a5,a2,-48
 366:	0ff7f793          	andi	a5,a5,255
 36a:	4725                	li	a4,9
 36c:	02f76963          	bltu	a4,a5,39e <atoi+0x46>
 370:	86aa                	mv	a3,a0
  n = 0;
 372:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 374:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 376:	0685                	addi	a3,a3,1
 378:	0025179b          	slliw	a5,a0,0x2
 37c:	9fa9                	addw	a5,a5,a0
 37e:	0017979b          	slliw	a5,a5,0x1
 382:	9fb1                	addw	a5,a5,a2
 384:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 388:	0006c603          	lbu	a2,0(a3)
 38c:	fd06071b          	addiw	a4,a2,-48
 390:	0ff77713          	andi	a4,a4,255
 394:	fee5f1e3          	bgeu	a1,a4,376 <atoi+0x1e>
  return n;
}
 398:	6422                	ld	s0,8(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret
  n = 0;
 39e:	4501                	li	a0,0
 3a0:	bfe5                	j	398 <atoi+0x40>

00000000000003a2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3a2:	1141                	addi	sp,sp,-16
 3a4:	e422                	sd	s0,8(sp)
 3a6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3a8:	02b57463          	bgeu	a0,a1,3d0 <memmove+0x2e>
    while(n-- > 0)
 3ac:	00c05f63          	blez	a2,3ca <memmove+0x28>
 3b0:	1602                	slli	a2,a2,0x20
 3b2:	9201                	srli	a2,a2,0x20
 3b4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3b8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ba:	0585                	addi	a1,a1,1
 3bc:	0705                	addi	a4,a4,1
 3be:	fff5c683          	lbu	a3,-1(a1)
 3c2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3c6:	fee79ae3          	bne	a5,a4,3ba <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ca:	6422                	ld	s0,8(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret
    dst += n;
 3d0:	00c50733          	add	a4,a0,a2
    src += n;
 3d4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3d6:	fec05ae3          	blez	a2,3ca <memmove+0x28>
 3da:	fff6079b          	addiw	a5,a2,-1
 3de:	1782                	slli	a5,a5,0x20
 3e0:	9381                	srli	a5,a5,0x20
 3e2:	fff7c793          	not	a5,a5
 3e6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3e8:	15fd                	addi	a1,a1,-1
 3ea:	177d                	addi	a4,a4,-1
 3ec:	0005c683          	lbu	a3,0(a1)
 3f0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3f4:	fee79ae3          	bne	a5,a4,3e8 <memmove+0x46>
 3f8:	bfc9                	j	3ca <memmove+0x28>

00000000000003fa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3fa:	1141                	addi	sp,sp,-16
 3fc:	e422                	sd	s0,8(sp)
 3fe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 400:	ca05                	beqz	a2,430 <memcmp+0x36>
 402:	fff6069b          	addiw	a3,a2,-1
 406:	1682                	slli	a3,a3,0x20
 408:	9281                	srli	a3,a3,0x20
 40a:	0685                	addi	a3,a3,1
 40c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 40e:	00054783          	lbu	a5,0(a0)
 412:	0005c703          	lbu	a4,0(a1)
 416:	00e79863          	bne	a5,a4,426 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 41a:	0505                	addi	a0,a0,1
    p2++;
 41c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 41e:	fed518e3          	bne	a0,a3,40e <memcmp+0x14>
  }
  return 0;
 422:	4501                	li	a0,0
 424:	a019                	j	42a <memcmp+0x30>
      return *p1 - *p2;
 426:	40e7853b          	subw	a0,a5,a4
}
 42a:	6422                	ld	s0,8(sp)
 42c:	0141                	addi	sp,sp,16
 42e:	8082                	ret
  return 0;
 430:	4501                	li	a0,0
 432:	bfe5                	j	42a <memcmp+0x30>

0000000000000434 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 434:	1141                	addi	sp,sp,-16
 436:	e406                	sd	ra,8(sp)
 438:	e022                	sd	s0,0(sp)
 43a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 43c:	00000097          	auipc	ra,0x0
 440:	f66080e7          	jalr	-154(ra) # 3a2 <memmove>
}
 444:	60a2                	ld	ra,8(sp)
 446:	6402                	ld	s0,0(sp)
 448:	0141                	addi	sp,sp,16
 44a:	8082                	ret

000000000000044c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 44c:	4885                	li	a7,1
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <exit>:
.global exit
exit:
 li a7, SYS_exit
 454:	4889                	li	a7,2
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <wait>:
.global wait
wait:
 li a7, SYS_wait
 45c:	488d                	li	a7,3
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 464:	4891                	li	a7,4
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <read>:
.global read
read:
 li a7, SYS_read
 46c:	4895                	li	a7,5
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <write>:
.global write
write:
 li a7, SYS_write
 474:	48c1                	li	a7,16
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <close>:
.global close
close:
 li a7, SYS_close
 47c:	48d5                	li	a7,21
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <kill>:
.global kill
kill:
 li a7, SYS_kill
 484:	4899                	li	a7,6
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <exec>:
.global exec
exec:
 li a7, SYS_exec
 48c:	489d                	li	a7,7
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <open>:
.global open
open:
 li a7, SYS_open
 494:	48bd                	li	a7,15
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 49c:	48c5                	li	a7,17
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4a4:	48c9                	li	a7,18
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4ac:	48a1                	li	a7,8
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <link>:
.global link
link:
 li a7, SYS_link
 4b4:	48cd                	li	a7,19
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4bc:	48d1                	li	a7,20
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4c4:	48a5                	li	a7,9
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <dup>:
.global dup
dup:
 li a7, SYS_dup
 4cc:	48a9                	li	a7,10
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4d4:	48ad                	li	a7,11
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4dc:	48b1                	li	a7,12
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4e4:	48b5                	li	a7,13
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4ec:	48b9                	li	a7,14
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <startlog>:
.global startlog
startlog:
 li a7, SYS_startlog
 4f4:	48d9                	li	a7,22
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <getlog>:
.global getlog
getlog:
 li a7, SYS_getlog
 4fc:	48dd                	li	a7,23
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <nice>:
.global nice
nice:
 li a7, SYS_nice
 504:	48e1                	li	a7,24
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 50c:	1101                	addi	sp,sp,-32
 50e:	ec06                	sd	ra,24(sp)
 510:	e822                	sd	s0,16(sp)
 512:	1000                	addi	s0,sp,32
 514:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 518:	4605                	li	a2,1
 51a:	fef40593          	addi	a1,s0,-17
 51e:	00000097          	auipc	ra,0x0
 522:	f56080e7          	jalr	-170(ra) # 474 <write>
}
 526:	60e2                	ld	ra,24(sp)
 528:	6442                	ld	s0,16(sp)
 52a:	6105                	addi	sp,sp,32
 52c:	8082                	ret

000000000000052e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 52e:	7139                	addi	sp,sp,-64
 530:	fc06                	sd	ra,56(sp)
 532:	f822                	sd	s0,48(sp)
 534:	f426                	sd	s1,40(sp)
 536:	f04a                	sd	s2,32(sp)
 538:	ec4e                	sd	s3,24(sp)
 53a:	0080                	addi	s0,sp,64
 53c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 53e:	c299                	beqz	a3,544 <printint+0x16>
 540:	0805c863          	bltz	a1,5d0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 544:	2581                	sext.w	a1,a1
  neg = 0;
 546:	4881                	li	a7,0
 548:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 54c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 54e:	2601                	sext.w	a2,a2
 550:	00000517          	auipc	a0,0x0
 554:	48850513          	addi	a0,a0,1160 # 9d8 <digits>
 558:	883a                	mv	a6,a4
 55a:	2705                	addiw	a4,a4,1
 55c:	02c5f7bb          	remuw	a5,a1,a2
 560:	1782                	slli	a5,a5,0x20
 562:	9381                	srli	a5,a5,0x20
 564:	97aa                	add	a5,a5,a0
 566:	0007c783          	lbu	a5,0(a5)
 56a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 56e:	0005879b          	sext.w	a5,a1
 572:	02c5d5bb          	divuw	a1,a1,a2
 576:	0685                	addi	a3,a3,1
 578:	fec7f0e3          	bgeu	a5,a2,558 <printint+0x2a>
  if(neg)
 57c:	00088b63          	beqz	a7,592 <printint+0x64>
    buf[i++] = '-';
 580:	fd040793          	addi	a5,s0,-48
 584:	973e                	add	a4,a4,a5
 586:	02d00793          	li	a5,45
 58a:	fef70823          	sb	a5,-16(a4)
 58e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 592:	02e05863          	blez	a4,5c2 <printint+0x94>
 596:	fc040793          	addi	a5,s0,-64
 59a:	00e78933          	add	s2,a5,a4
 59e:	fff78993          	addi	s3,a5,-1
 5a2:	99ba                	add	s3,s3,a4
 5a4:	377d                	addiw	a4,a4,-1
 5a6:	1702                	slli	a4,a4,0x20
 5a8:	9301                	srli	a4,a4,0x20
 5aa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5ae:	fff94583          	lbu	a1,-1(s2)
 5b2:	8526                	mv	a0,s1
 5b4:	00000097          	auipc	ra,0x0
 5b8:	f58080e7          	jalr	-168(ra) # 50c <putc>
  while(--i >= 0)
 5bc:	197d                	addi	s2,s2,-1
 5be:	ff3918e3          	bne	s2,s3,5ae <printint+0x80>
}
 5c2:	70e2                	ld	ra,56(sp)
 5c4:	7442                	ld	s0,48(sp)
 5c6:	74a2                	ld	s1,40(sp)
 5c8:	7902                	ld	s2,32(sp)
 5ca:	69e2                	ld	s3,24(sp)
 5cc:	6121                	addi	sp,sp,64
 5ce:	8082                	ret
    x = -xx;
 5d0:	40b005bb          	negw	a1,a1
    neg = 1;
 5d4:	4885                	li	a7,1
    x = -xx;
 5d6:	bf8d                	j	548 <printint+0x1a>

00000000000005d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d8:	7119                	addi	sp,sp,-128
 5da:	fc86                	sd	ra,120(sp)
 5dc:	f8a2                	sd	s0,112(sp)
 5de:	f4a6                	sd	s1,104(sp)
 5e0:	f0ca                	sd	s2,96(sp)
 5e2:	ecce                	sd	s3,88(sp)
 5e4:	e8d2                	sd	s4,80(sp)
 5e6:	e4d6                	sd	s5,72(sp)
 5e8:	e0da                	sd	s6,64(sp)
 5ea:	fc5e                	sd	s7,56(sp)
 5ec:	f862                	sd	s8,48(sp)
 5ee:	f466                	sd	s9,40(sp)
 5f0:	f06a                	sd	s10,32(sp)
 5f2:	ec6e                	sd	s11,24(sp)
 5f4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f6:	0005c903          	lbu	s2,0(a1)
 5fa:	18090f63          	beqz	s2,798 <vprintf+0x1c0>
 5fe:	8aaa                	mv	s5,a0
 600:	8b32                	mv	s6,a2
 602:	00158493          	addi	s1,a1,1
  state = 0;
 606:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 608:	02500a13          	li	s4,37
      if(c == 'd'){
 60c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 610:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 614:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 618:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61c:	00000b97          	auipc	s7,0x0
 620:	3bcb8b93          	addi	s7,s7,956 # 9d8 <digits>
 624:	a839                	j	642 <vprintf+0x6a>
        putc(fd, c);
 626:	85ca                	mv	a1,s2
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	ee2080e7          	jalr	-286(ra) # 50c <putc>
 632:	a019                	j	638 <vprintf+0x60>
    } else if(state == '%'){
 634:	01498f63          	beq	s3,s4,652 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 638:	0485                	addi	s1,s1,1
 63a:	fff4c903          	lbu	s2,-1(s1)
 63e:	14090d63          	beqz	s2,798 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 642:	0009079b          	sext.w	a5,s2
    if(state == 0){
 646:	fe0997e3          	bnez	s3,634 <vprintf+0x5c>
      if(c == '%'){
 64a:	fd479ee3          	bne	a5,s4,626 <vprintf+0x4e>
        state = '%';
 64e:	89be                	mv	s3,a5
 650:	b7e5                	j	638 <vprintf+0x60>
      if(c == 'd'){
 652:	05878063          	beq	a5,s8,692 <vprintf+0xba>
      } else if(c == 'l') {
 656:	05978c63          	beq	a5,s9,6ae <vprintf+0xd6>
      } else if(c == 'x') {
 65a:	07a78863          	beq	a5,s10,6ca <vprintf+0xf2>
      } else if(c == 'p') {
 65e:	09b78463          	beq	a5,s11,6e6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 662:	07300713          	li	a4,115
 666:	0ce78663          	beq	a5,a4,732 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 66a:	06300713          	li	a4,99
 66e:	0ee78e63          	beq	a5,a4,76a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 672:	11478863          	beq	a5,s4,782 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 676:	85d2                	mv	a1,s4
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	e92080e7          	jalr	-366(ra) # 50c <putc>
        putc(fd, c);
 682:	85ca                	mv	a1,s2
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	e86080e7          	jalr	-378(ra) # 50c <putc>
      }
      state = 0;
 68e:	4981                	li	s3,0
 690:	b765                	j	638 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 692:	008b0913          	addi	s2,s6,8
 696:	4685                	li	a3,1
 698:	4629                	li	a2,10
 69a:	000b2583          	lw	a1,0(s6)
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	e8e080e7          	jalr	-370(ra) # 52e <printint>
 6a8:	8b4a                	mv	s6,s2
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b771                	j	638 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ae:	008b0913          	addi	s2,s6,8
 6b2:	4681                	li	a3,0
 6b4:	4629                	li	a2,10
 6b6:	000b2583          	lw	a1,0(s6)
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e72080e7          	jalr	-398(ra) # 52e <printint>
 6c4:	8b4a                	mv	s6,s2
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	bf85                	j	638 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6ca:	008b0913          	addi	s2,s6,8
 6ce:	4681                	li	a3,0
 6d0:	4641                	li	a2,16
 6d2:	000b2583          	lw	a1,0(s6)
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e56080e7          	jalr	-426(ra) # 52e <printint>
 6e0:	8b4a                	mv	s6,s2
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bf91                	j	638 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6e6:	008b0793          	addi	a5,s6,8
 6ea:	f8f43423          	sd	a5,-120(s0)
 6ee:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6f2:	03000593          	li	a1,48
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	e14080e7          	jalr	-492(ra) # 50c <putc>
  putc(fd, 'x');
 700:	85ea                	mv	a1,s10
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	e08080e7          	jalr	-504(ra) # 50c <putc>
 70c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70e:	03c9d793          	srli	a5,s3,0x3c
 712:	97de                	add	a5,a5,s7
 714:	0007c583          	lbu	a1,0(a5)
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	df2080e7          	jalr	-526(ra) # 50c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 722:	0992                	slli	s3,s3,0x4
 724:	397d                	addiw	s2,s2,-1
 726:	fe0914e3          	bnez	s2,70e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 72a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 72e:	4981                	li	s3,0
 730:	b721                	j	638 <vprintf+0x60>
        s = va_arg(ap, char*);
 732:	008b0993          	addi	s3,s6,8
 736:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 73a:	02090163          	beqz	s2,75c <vprintf+0x184>
        while(*s != 0){
 73e:	00094583          	lbu	a1,0(s2)
 742:	c9a1                	beqz	a1,792 <vprintf+0x1ba>
          putc(fd, *s);
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	dc6080e7          	jalr	-570(ra) # 50c <putc>
          s++;
 74e:	0905                	addi	s2,s2,1
        while(*s != 0){
 750:	00094583          	lbu	a1,0(s2)
 754:	f9e5                	bnez	a1,744 <vprintf+0x16c>
        s = va_arg(ap, char*);
 756:	8b4e                	mv	s6,s3
      state = 0;
 758:	4981                	li	s3,0
 75a:	bdf9                	j	638 <vprintf+0x60>
          s = "(null)";
 75c:	00000917          	auipc	s2,0x0
 760:	27490913          	addi	s2,s2,628 # 9d0 <malloc+0x12e>
        while(*s != 0){
 764:	02800593          	li	a1,40
 768:	bff1                	j	744 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 76a:	008b0913          	addi	s2,s6,8
 76e:	000b4583          	lbu	a1,0(s6)
 772:	8556                	mv	a0,s5
 774:	00000097          	auipc	ra,0x0
 778:	d98080e7          	jalr	-616(ra) # 50c <putc>
 77c:	8b4a                	mv	s6,s2
      state = 0;
 77e:	4981                	li	s3,0
 780:	bd65                	j	638 <vprintf+0x60>
        putc(fd, c);
 782:	85d2                	mv	a1,s4
 784:	8556                	mv	a0,s5
 786:	00000097          	auipc	ra,0x0
 78a:	d86080e7          	jalr	-634(ra) # 50c <putc>
      state = 0;
 78e:	4981                	li	s3,0
 790:	b565                	j	638 <vprintf+0x60>
        s = va_arg(ap, char*);
 792:	8b4e                	mv	s6,s3
      state = 0;
 794:	4981                	li	s3,0
 796:	b54d                	j	638 <vprintf+0x60>
    }
  }
}
 798:	70e6                	ld	ra,120(sp)
 79a:	7446                	ld	s0,112(sp)
 79c:	74a6                	ld	s1,104(sp)
 79e:	7906                	ld	s2,96(sp)
 7a0:	69e6                	ld	s3,88(sp)
 7a2:	6a46                	ld	s4,80(sp)
 7a4:	6aa6                	ld	s5,72(sp)
 7a6:	6b06                	ld	s6,64(sp)
 7a8:	7be2                	ld	s7,56(sp)
 7aa:	7c42                	ld	s8,48(sp)
 7ac:	7ca2                	ld	s9,40(sp)
 7ae:	7d02                	ld	s10,32(sp)
 7b0:	6de2                	ld	s11,24(sp)
 7b2:	6109                	addi	sp,sp,128
 7b4:	8082                	ret

00000000000007b6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b6:	715d                	addi	sp,sp,-80
 7b8:	ec06                	sd	ra,24(sp)
 7ba:	e822                	sd	s0,16(sp)
 7bc:	1000                	addi	s0,sp,32
 7be:	e010                	sd	a2,0(s0)
 7c0:	e414                	sd	a3,8(s0)
 7c2:	e818                	sd	a4,16(s0)
 7c4:	ec1c                	sd	a5,24(s0)
 7c6:	03043023          	sd	a6,32(s0)
 7ca:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ce:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d2:	8622                	mv	a2,s0
 7d4:	00000097          	auipc	ra,0x0
 7d8:	e04080e7          	jalr	-508(ra) # 5d8 <vprintf>
}
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	6161                	addi	sp,sp,80
 7e2:	8082                	ret

00000000000007e4 <printf>:

void
printf(const char *fmt, ...)
{
 7e4:	711d                	addi	sp,sp,-96
 7e6:	ec06                	sd	ra,24(sp)
 7e8:	e822                	sd	s0,16(sp)
 7ea:	1000                	addi	s0,sp,32
 7ec:	e40c                	sd	a1,8(s0)
 7ee:	e810                	sd	a2,16(s0)
 7f0:	ec14                	sd	a3,24(s0)
 7f2:	f018                	sd	a4,32(s0)
 7f4:	f41c                	sd	a5,40(s0)
 7f6:	03043823          	sd	a6,48(s0)
 7fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fe:	00840613          	addi	a2,s0,8
 802:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 806:	85aa                	mv	a1,a0
 808:	4505                	li	a0,1
 80a:	00000097          	auipc	ra,0x0
 80e:	dce080e7          	jalr	-562(ra) # 5d8 <vprintf>
}
 812:	60e2                	ld	ra,24(sp)
 814:	6442                	ld	s0,16(sp)
 816:	6125                	addi	sp,sp,96
 818:	8082                	ret

000000000000081a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81a:	1141                	addi	sp,sp,-16
 81c:	e422                	sd	s0,8(sp)
 81e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 820:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 824:	00000797          	auipc	a5,0x0
 828:	1d47b783          	ld	a5,468(a5) # 9f8 <freep>
 82c:	a805                	j	85c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 82e:	4618                	lw	a4,8(a2)
 830:	9db9                	addw	a1,a1,a4
 832:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 836:	6398                	ld	a4,0(a5)
 838:	6318                	ld	a4,0(a4)
 83a:	fee53823          	sd	a4,-16(a0)
 83e:	a091                	j	882 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 840:	ff852703          	lw	a4,-8(a0)
 844:	9e39                	addw	a2,a2,a4
 846:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 848:	ff053703          	ld	a4,-16(a0)
 84c:	e398                	sd	a4,0(a5)
 84e:	a099                	j	894 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 850:	6398                	ld	a4,0(a5)
 852:	00e7e463          	bltu	a5,a4,85a <free+0x40>
 856:	00e6ea63          	bltu	a3,a4,86a <free+0x50>
{
 85a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85c:	fed7fae3          	bgeu	a5,a3,850 <free+0x36>
 860:	6398                	ld	a4,0(a5)
 862:	00e6e463          	bltu	a3,a4,86a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 866:	fee7eae3          	bltu	a5,a4,85a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 86a:	ff852583          	lw	a1,-8(a0)
 86e:	6390                	ld	a2,0(a5)
 870:	02059713          	slli	a4,a1,0x20
 874:	9301                	srli	a4,a4,0x20
 876:	0712                	slli	a4,a4,0x4
 878:	9736                	add	a4,a4,a3
 87a:	fae60ae3          	beq	a2,a4,82e <free+0x14>
    bp->s.ptr = p->s.ptr;
 87e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 882:	4790                	lw	a2,8(a5)
 884:	02061713          	slli	a4,a2,0x20
 888:	9301                	srli	a4,a4,0x20
 88a:	0712                	slli	a4,a4,0x4
 88c:	973e                	add	a4,a4,a5
 88e:	fae689e3          	beq	a3,a4,840 <free+0x26>
  } else
    p->s.ptr = bp;
 892:	e394                	sd	a3,0(a5)
  freep = p;
 894:	00000717          	auipc	a4,0x0
 898:	16f73223          	sd	a5,356(a4) # 9f8 <freep>
}
 89c:	6422                	ld	s0,8(sp)
 89e:	0141                	addi	sp,sp,16
 8a0:	8082                	ret

00000000000008a2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a2:	7139                	addi	sp,sp,-64
 8a4:	fc06                	sd	ra,56(sp)
 8a6:	f822                	sd	s0,48(sp)
 8a8:	f426                	sd	s1,40(sp)
 8aa:	f04a                	sd	s2,32(sp)
 8ac:	ec4e                	sd	s3,24(sp)
 8ae:	e852                	sd	s4,16(sp)
 8b0:	e456                	sd	s5,8(sp)
 8b2:	e05a                	sd	s6,0(sp)
 8b4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b6:	02051493          	slli	s1,a0,0x20
 8ba:	9081                	srli	s1,s1,0x20
 8bc:	04bd                	addi	s1,s1,15
 8be:	8091                	srli	s1,s1,0x4
 8c0:	0014899b          	addiw	s3,s1,1
 8c4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8c6:	00000517          	auipc	a0,0x0
 8ca:	13253503          	ld	a0,306(a0) # 9f8 <freep>
 8ce:	c515                	beqz	a0,8fa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	02977f63          	bgeu	a4,s1,912 <malloc+0x70>
 8d8:	8a4e                	mv	s4,s3
 8da:	0009871b          	sext.w	a4,s3
 8de:	6685                	lui	a3,0x1
 8e0:	00d77363          	bgeu	a4,a3,8e6 <malloc+0x44>
 8e4:	6a05                	lui	s4,0x1
 8e6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ea:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ee:	00000917          	auipc	s2,0x0
 8f2:	10a90913          	addi	s2,s2,266 # 9f8 <freep>
  if(p == (char*)-1)
 8f6:	5afd                	li	s5,-1
 8f8:	a88d                	j	96a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8fa:	00000797          	auipc	a5,0x0
 8fe:	30678793          	addi	a5,a5,774 # c00 <base>
 902:	00000717          	auipc	a4,0x0
 906:	0ef73b23          	sd	a5,246(a4) # 9f8 <freep>
 90a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 90c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 910:	b7e1                	j	8d8 <malloc+0x36>
      if(p->s.size == nunits)
 912:	02e48b63          	beq	s1,a4,948 <malloc+0xa6>
        p->s.size -= nunits;
 916:	4137073b          	subw	a4,a4,s3
 91a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 91c:	1702                	slli	a4,a4,0x20
 91e:	9301                	srli	a4,a4,0x20
 920:	0712                	slli	a4,a4,0x4
 922:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 924:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 928:	00000717          	auipc	a4,0x0
 92c:	0ca73823          	sd	a0,208(a4) # 9f8 <freep>
      return (void*)(p + 1);
 930:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 934:	70e2                	ld	ra,56(sp)
 936:	7442                	ld	s0,48(sp)
 938:	74a2                	ld	s1,40(sp)
 93a:	7902                	ld	s2,32(sp)
 93c:	69e2                	ld	s3,24(sp)
 93e:	6a42                	ld	s4,16(sp)
 940:	6aa2                	ld	s5,8(sp)
 942:	6b02                	ld	s6,0(sp)
 944:	6121                	addi	sp,sp,64
 946:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 948:	6398                	ld	a4,0(a5)
 94a:	e118                	sd	a4,0(a0)
 94c:	bff1                	j	928 <malloc+0x86>
  hp->s.size = nu;
 94e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 952:	0541                	addi	a0,a0,16
 954:	00000097          	auipc	ra,0x0
 958:	ec6080e7          	jalr	-314(ra) # 81a <free>
  return freep;
 95c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 960:	d971                	beqz	a0,934 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 962:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 964:	4798                	lw	a4,8(a5)
 966:	fa9776e3          	bgeu	a4,s1,912 <malloc+0x70>
    if(p == freep)
 96a:	00093703          	ld	a4,0(s2)
 96e:	853e                	mv	a0,a5
 970:	fef719e3          	bne	a4,a5,962 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 974:	8552                	mv	a0,s4
 976:	00000097          	auipc	ra,0x0
 97a:	b66080e7          	jalr	-1178(ra) # 4dc <sbrk>
  if(p == (char*)-1)
 97e:	fd5518e3          	bne	a0,s5,94e <malloc+0xac>
        return 0;
 982:	4501                	li	a0,0
 984:	bf45                	j	934 <malloc+0x92>
