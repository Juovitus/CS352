
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8e013103          	ld	sp,-1824(sp) # 800088e0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8fe70713          	addi	a4,a4,-1794 # 80008950 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	0cc78793          	addi	a5,a5,204 # 80006130 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdbc8f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00003097          	auipc	ra,0x3
    80000130:	906080e7          	jalr	-1786(ra) # 80002a32 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	90650513          	addi	a0,a0,-1786 # 80010a90 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8f648493          	addi	s1,s1,-1802 # 80010a90 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	98690913          	addi	s2,s2,-1658 # 80010b28 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	bb4080e7          	jalr	-1100(ra) # 80001d74 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	6b4080e7          	jalr	1716(ra) # 8000287c <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	3a8080e7          	jalr	936(ra) # 8000257e <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	7ca080e7          	jalr	1994(ra) # 800029dc <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	86a50513          	addi	a0,a0,-1942 # 80010a90 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	85450513          	addi	a0,a0,-1964 # 80010a90 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	8af72b23          	sw	a5,-1866(a4) # 80010b28 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	7c450513          	addi	a0,a0,1988 # 80010a90 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	796080e7          	jalr	1942(ra) # 80002a88 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	79650513          	addi	a0,a0,1942 # 80010a90 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	77270713          	addi	a4,a4,1906 # 80010a90 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	74878793          	addi	a5,a5,1864 # 80010a90 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7b27a783          	lw	a5,1970(a5) # 80010b28 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	70670713          	addi	a4,a4,1798 # 80010a90 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6f648493          	addi	s1,s1,1782 # 80010a90 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	6ba70713          	addi	a4,a4,1722 # 80010a90 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	74f72223          	sw	a5,1860(a4) # 80010b30 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	67e78793          	addi	a5,a5,1662 # 80010a90 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ec7ab23          	sw	a2,1782(a5) # 80010b2c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6ea50513          	addi	a0,a0,1770 # 80010b28 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	19c080e7          	jalr	412(ra) # 800025e2 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	63050513          	addi	a0,a0,1584 # 80010a90 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	56078793          	addi	a5,a5,1376 # 800219d8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	6007a323          	sw	zero,1542(a5) # 80010b50 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	38f72123          	sw	a5,898(a4) # 80008900 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	596dad83          	lw	s11,1430(s11) # 80010b50 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	54050513          	addi	a0,a0,1344 # 80010b38 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	3e250513          	addi	a0,a0,994 # 80010b38 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	3c648493          	addi	s1,s1,966 # 80010b38 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	38650513          	addi	a0,a0,902 # 80010b58 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	1027a783          	lw	a5,258(a5) # 80008900 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0d27b783          	ld	a5,210(a5) # 80008908 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0d273703          	ld	a4,210(a4) # 80008910 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2f8a0a13          	addi	s4,s4,760 # 80010b58 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	0a048493          	addi	s1,s1,160 # 80008908 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	0a098993          	addi	s3,s3,160 # 80008910 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	d50080e7          	jalr	-688(ra) # 800025e2 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	28a50513          	addi	a0,a0,650 # 80010b58 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	0227a783          	lw	a5,34(a5) # 80008900 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	02873703          	ld	a4,40(a4) # 80008910 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	0187b783          	ld	a5,24(a5) # 80008908 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	25c98993          	addi	s3,s3,604 # 80010b58 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	00448493          	addi	s1,s1,4 # 80008908 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	00490913          	addi	s2,s2,4 # 80008910 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	c62080e7          	jalr	-926(ra) # 8000257e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	22648493          	addi	s1,s1,550 # 80010b58 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	fce7b523          	sd	a4,-54(a5) # 80008910 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	19c48493          	addi	s1,s1,412 # 80010b58 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00022797          	auipc	a5,0x22
    80000a02:	17278793          	addi	a5,a5,370 # 80022b70 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	17290913          	addi	s2,s2,370 # 80010b90 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	0d650513          	addi	a0,a0,214 # 80010b90 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00022517          	auipc	a0,0x22
    80000ad2:	0a250513          	addi	a0,a0,162 # 80022b70 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	0a048493          	addi	s1,s1,160 # 80010b90 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	08850513          	addi	a0,a0,136 # 80010b90 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	05c50513          	addi	a0,a0,92 # 80010b90 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	1e8080e7          	jalr	488(ra) # 80001d58 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	1b6080e7          	jalr	438(ra) # 80001d58 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	1aa080e7          	jalr	426(ra) # 80001d58 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	192080e7          	jalr	402(ra) # 80001d58 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	152080e7          	jalr	338(ra) # 80001d58 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	126080e7          	jalr	294(ra) # 80001d58 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	ec8080e7          	jalr	-312(ra) # 80001d48 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a9070713          	addi	a4,a4,-1392 # 80008918 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	eac080e7          	jalr	-340(ra) # 80001d48 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	d0a080e7          	jalr	-758(ra) # 80002bc8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	2aa080e7          	jalr	682(ra) # 80006170 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	4e0080e7          	jalr	1248(ra) # 800023ae <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	d66080e7          	jalr	-666(ra) # 80001c94 <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	c6a080e7          	jalr	-918(ra) # 80002ba0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	c8a080e7          	jalr	-886(ra) # 80002bc8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	214080e7          	jalr	532(ra) # 8000615a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	222080e7          	jalr	546(ra) # 80006170 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	3ca080e7          	jalr	970(ra) # 80003320 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	a6e080e7          	jalr	-1426(ra) # 800039cc <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	a0c080e7          	jalr	-1524(ra) # 80004972 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	30a080e7          	jalr	778(ra) # 80006278 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	1ca080e7          	jalr	458(ra) # 80002140 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	98f72a23          	sw	a5,-1644(a4) # 80008918 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9887b783          	ld	a5,-1656(a5) # 80008920 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00001097          	auipc	ra,0x1
    80001232:	9d0080e7          	jalr	-1584(ra) # 80001bfe <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	6ca7b623          	sd	a0,1740(a5) # 80008920 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <setupQueue>:
};

//A fixed size table where the index of a process in proc[] is the same in qtable[]
struct qentry qtable[NPROC + 2*NUM_QUEUES];

void setupQueue(){
    80001836:	1141                	addi	sp,sp,-16
    80001838:	e406                	sd	ra,8(sp)
    8000183a:	e022                	sd	s0,0(sp)
    8000183c:	0800                	addi	s0,sp,16
  printf("SETTING UP THE QUEUE!\n");
    8000183e:	00007517          	auipc	a0,0x7
    80001842:	99a50513          	addi	a0,a0,-1638 # 800081d8 <digits+0x198>
    80001846:	fffff097          	auipc	ra,0xfffff
    8000184a:	d42080e7          	jalr	-702(ra) # 80000588 <printf>
  for(int i = 0; i < NPROC; i++){
    8000184e:	0000f797          	auipc	a5,0xf
    80001852:	36278793          	addi	a5,a5,866 # 80010bb0 <qtable>
    80001856:	00010697          	auipc	a3,0x10
    8000185a:	95a68693          	addi	a3,a3,-1702 # 800111b0 <qtable+0x600>
    qtable[i].queue = EMPTY;
    8000185e:	577d                	li	a4,-1
    80001860:	e398                	sd	a4,0(a5)
  for(int i = 0; i < NPROC; i++){
    80001862:	07e1                	addi	a5,a5,24
    80001864:	fed79ee3          	bne	a5,a3,80001860 <setupQueue+0x2a>
  }
  //Head-Tail
  //INDEX 64+65=0, 66+67=1, 68+69=2
  //Setup heads and tails of all 3 queues(I know this is bad ok)
  //Head's next should point to tail and tail's previous should point to head by default
  qtable[HEAD_Q0].queue = 0;
    80001868:	0000f797          	auipc	a5,0xf
    8000186c:	34878793          	addi	a5,a5,840 # 80010bb0 <qtable>
    80001870:	6007b023          	sd	zero,1536(a5)
  qtable[HEAD_Q0].next = 65;
    80001874:	04100713          	li	a4,65
    80001878:	60e7b823          	sd	a4,1552(a5)
  qtable[TAIL_Q0].queue = 0;
    8000187c:	6007bc23          	sd	zero,1560(a5)
  qtable[TAIL_Q0].prev = 64;
    80001880:	04000713          	li	a4,64
    80001884:	62e7b023          	sd	a4,1568(a5)
  
  qtable[HEAD_Q1].queue = 1;
    80001888:	4705                	li	a4,1
    8000188a:	62e7b823          	sd	a4,1584(a5)
  qtable[HEAD_Q1].next = 67;
    8000188e:	04300693          	li	a3,67
    80001892:	64d7b023          	sd	a3,1600(a5)
  qtable[TAIL_Q1].queue = 1;
    80001896:	64e7b423          	sd	a4,1608(a5)
  qtable[TAIL_Q1].prev = 66;
    8000189a:	04200713          	li	a4,66
    8000189e:	64e7b823          	sd	a4,1616(a5)

  qtable[HEAD_Q2].queue = 2;
    800018a2:	4709                	li	a4,2
    800018a4:	66e7b023          	sd	a4,1632(a5)
  qtable[HEAD_Q2].next = 69;
    800018a8:	04500693          	li	a3,69
    800018ac:	66d7b823          	sd	a3,1648(a5)
  qtable[TAIL_Q2].queue = 2;
    800018b0:	66e7bc23          	sd	a4,1656(a5)
  qtable[TAIL_Q2].prev = 68;
    800018b4:	04400713          	li	a4,68
    800018b8:	68e7b023          	sd	a4,1664(a5)
}
    800018bc:	60a2                	ld	ra,8(sp)
    800018be:	6402                	ld	s0,0(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <enqueue>:

void enqueue(struct proc *p){
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
  uint64 pindex = p-proc;
    800018ca:	00010797          	auipc	a5,0x10
    800018ce:	0c678793          	addi	a5,a5,198 # 80011990 <proc>
    800018d2:	40f507b3          	sub	a5,a0,a5
    800018d6:	878d                	srai	a5,a5,0x3
    800018d8:	00006717          	auipc	a4,0x6
    800018dc:	72873703          	ld	a4,1832(a4) # 80008000 <etext>
    800018e0:	02e787b3          	mul	a5,a5,a4
  int queueToInsertTo;
  //Check which queue we want to insert to based on the nice value.
  if(p->nice>10){
    800018e4:	16852703          	lw	a4,360(a0)
    800018e8:	46a9                	li	a3,10
    800018ea:	00e6d963          	bge	a3,a4,800018fc <enqueue+0x38>
    queueToInsertTo = 0;
    //If the process is moving up a queue then we reset time quanta
    if(p->queue > 0)p->quanta = 0;
    800018ee:	17052703          	lw	a4,368(a0)
    800018f2:	0ce05a63          	blez	a4,800019c6 <enqueue+0x102>
    800018f6:	16052623          	sw	zero,364(a0)
    p->quanta = 0;
  }
  //Failsafe ig
  if(queueToInsertTo > 2)queueToInsertTo = 2;

  if(queueToInsertTo == 0){
    800018fa:	a815                	j	8000192e <enqueue+0x6a>
  }else if(p->nice <= 10 && p->nice > -10){
    800018fc:	2725                	addiw	a4,a4,9
    800018fe:	46cd                	li	a3,19
    80001900:	00e6ea63          	bltu	a3,a4,80001914 <enqueue+0x50>
    if(p->queue > 1)p->quanta = 0;
    80001904:	17052683          	lw	a3,368(a0)
    80001908:	4705                	li	a4,1
    8000190a:	04d75e63          	bge	a4,a3,80001966 <enqueue+0xa2>
    8000190e:	16052623          	sw	zero,364(a0)
    qtable[pindex].next = TAIL_Q0;
    qtable[oldTail].next = pindex;
    qtable[TAIL_Q0].prev = pindex;
    
  }
  else if(queueToInsertTo == 1){
    80001912:	a0c9                	j	800019d4 <enqueue+0x110>
    queueToInsertTo = 2;
    80001914:	4689                	li	a3,2
  if(p->quanta > 15 && queueToInsertTo == 0){
    80001916:	16c52703          	lw	a4,364(a0)
    8000191a:	463d                	li	a2,15
    8000191c:	04e65763          	bge	a2,a4,8000196a <enqueue+0xa6>
  }else if(p->quanta > 10 && queueToInsertTo == 1){
    80001920:	4705                	li	a4,1
    80001922:	04e68b63          	beq	a3,a4,80001978 <enqueue+0xb4>
  }else if(p->quanta > 1 && queueToInsertTo == 2){
    80001926:	4709                	li	a4,2
    80001928:	04e68b63          	beq	a3,a4,8000197e <enqueue+0xba>
  if(queueToInsertTo == 0){
    8000192c:	eea1                	bnez	a3,80001984 <enqueue+0xc0>
    p->queue = 0;
    8000192e:	16052823          	sw	zero,368(a0)
    qtable[pindex].queue = 0;
    80001932:	0000f697          	auipc	a3,0xf
    80001936:	27e68693          	addi	a3,a3,638 # 80010bb0 <qtable>
    8000193a:	00179713          	slli	a4,a5,0x1
    8000193e:	973e                	add	a4,a4,a5
    80001940:	070e                	slli	a4,a4,0x3
    80001942:	9736                	add	a4,a4,a3
    80001944:	00073023          	sd	zero,0(a4)
    int oldTail = qtable[TAIL_Q0].prev;
    80001948:	6206a603          	lw	a2,1568(a3)
    qtable[pindex].prev = oldTail;
    8000194c:	e710                	sd	a2,8(a4)
    qtable[pindex].next = TAIL_Q0;
    8000194e:	04100593          	li	a1,65
    80001952:	eb0c                	sd	a1,16(a4)
    qtable[oldTail].next = pindex;
    80001954:	00161713          	slli	a4,a2,0x1
    80001958:	9732                	add	a4,a4,a2
    8000195a:	070e                	slli	a4,a4,0x3
    8000195c:	9736                	add	a4,a4,a3
    8000195e:	eb1c                	sd	a5,16(a4)
    qtable[TAIL_Q0].prev = pindex;
    80001960:	62f6b023          	sd	a5,1568(a3)
    80001964:	a8b1                	j	800019c0 <enqueue+0xfc>
    queueToInsertTo = 1;
    80001966:	4685                	li	a3,1
    80001968:	b77d                	j	80001916 <enqueue+0x52>
  }else if(p->quanta > 10 && queueToInsertTo == 1){
    8000196a:	4629                	li	a2,10
    8000196c:	fae64ae3          	blt	a2,a4,80001920 <enqueue+0x5c>
  }else if(p->quanta > 1 && queueToInsertTo == 2){
    80001970:	4605                	li	a2,1
    80001972:	fae64ae3          	blt	a2,a4,80001926 <enqueue+0x62>
    80001976:	bf5d                	j	8000192c <enqueue+0x68>
    p->quanta = 0;
    80001978:	16052623          	sw	zero,364(a0)
    8000197c:	a039                	j	8000198a <enqueue+0xc6>
    p->quanta = 0;
    8000197e:	16052623          	sw	zero,364(a0)
    80001982:	a021                	j	8000198a <enqueue+0xc6>
  else if(queueToInsertTo == 1){
    80001984:	4705                	li	a4,1
    80001986:	04e68763          	beq	a3,a4,800019d4 <enqueue+0x110>
    qtable[pindex].next = TAIL_Q1;
    qtable[oldTail].next = pindex;
    qtable[TAIL_Q1].prev = pindex;
  }else{
    //else it goes to the last queue, 2.
    p->queue = 2;
    8000198a:	4609                	li	a2,2
    8000198c:	16c52823          	sw	a2,368(a0)
    //give process to queue 2
    qtable[pindex].queue = 2;
    80001990:	0000f697          	auipc	a3,0xf
    80001994:	22068693          	addi	a3,a3,544 # 80010bb0 <qtable>
    80001998:	00179713          	slli	a4,a5,0x1
    8000199c:	973e                	add	a4,a4,a5
    8000199e:	070e                	slli	a4,a4,0x3
    800019a0:	9736                	add	a4,a4,a3
    800019a2:	e310                	sd	a2,0(a4)
    int oldTail = qtable[TAIL_Q2].prev;
    800019a4:	6806a603          	lw	a2,1664(a3)
    qtable[pindex].prev = oldTail;
    800019a8:	e710                	sd	a2,8(a4)
    qtable[pindex].next = TAIL_Q2;
    800019aa:	04500593          	li	a1,69
    800019ae:	eb0c                	sd	a1,16(a4)
    qtable[oldTail].next = pindex;
    800019b0:	00161713          	slli	a4,a2,0x1
    800019b4:	9732                	add	a4,a4,a2
    800019b6:	070e                	slli	a4,a4,0x3
    800019b8:	9736                	add	a4,a4,a3
    800019ba:	eb1c                	sd	a5,16(a4)
    qtable[TAIL_Q2].prev = pindex;
    800019bc:	68f6b023          	sd	a5,1664(a3)
  }
}
    800019c0:	6422                	ld	s0,8(sp)
    800019c2:	0141                	addi	sp,sp,16
    800019c4:	8082                	ret
  if(p->quanta > 15 && queueToInsertTo == 0){
    800019c6:	16c52703          	lw	a4,364(a0)
    800019ca:	46bd                	li	a3,15
    800019cc:	04e6d063          	bge	a3,a4,80001a0c <enqueue+0x148>
    p->quanta = 0;
    800019d0:	16052623          	sw	zero,364(a0)
    p->queue = 1;
    800019d4:	4605                	li	a2,1
    800019d6:	16c52823          	sw	a2,368(a0)
    qtable[pindex].queue = 1;
    800019da:	0000f697          	auipc	a3,0xf
    800019de:	1d668693          	addi	a3,a3,470 # 80010bb0 <qtable>
    800019e2:	00179713          	slli	a4,a5,0x1
    800019e6:	973e                	add	a4,a4,a5
    800019e8:	070e                	slli	a4,a4,0x3
    800019ea:	9736                	add	a4,a4,a3
    800019ec:	e310                	sd	a2,0(a4)
    int oldTail = qtable[TAIL_Q1].prev;
    800019ee:	6506a603          	lw	a2,1616(a3)
    qtable[pindex].prev = oldTail;
    800019f2:	e710                	sd	a2,8(a4)
    qtable[pindex].next = TAIL_Q1;
    800019f4:	04300593          	li	a1,67
    800019f8:	eb0c                	sd	a1,16(a4)
    qtable[oldTail].next = pindex;
    800019fa:	00161713          	slli	a4,a2,0x1
    800019fe:	9732                	add	a4,a4,a2
    80001a00:	070e                	slli	a4,a4,0x3
    80001a02:	9736                	add	a4,a4,a3
    80001a04:	eb1c                	sd	a5,16(a4)
    qtable[TAIL_Q1].prev = pindex;
    80001a06:	64f6b823          	sd	a5,1616(a3)
    80001a0a:	bf5d                	j	800019c0 <enqueue+0xfc>
  }else if(p->quanta > 10 && queueToInsertTo == 1){
    80001a0c:	4629                	li	a2,10
    queueToInsertTo = 0;
    80001a0e:	4681                	li	a3,0
  }else if(p->quanta > 10 && queueToInsertTo == 1){
    80001a10:	f0e64be3          	blt	a2,a4,80001926 <enqueue+0x62>
    80001a14:	bfb1                	j	80001970 <enqueue+0xac>

0000000080001a16 <removeFromQueue>:

void removeFromQueue(struct proc *p){
    80001a16:	1141                	addi	sp,sp,-16
    80001a18:	e422                	sd	s0,8(sp)
    80001a1a:	0800                	addi	s0,sp,16
  //Assume p is a pointer to a process in proc[]
  uint64 pindex = p-proc;
    80001a1c:	00010797          	auipc	a5,0x10
    80001a20:	f7478793          	addi	a5,a5,-140 # 80011990 <proc>
    80001a24:	8d1d                	sub	a0,a0,a5
    80001a26:	850d                	srai	a0,a0,0x3
    80001a28:	00006797          	auipc	a5,0x6
    80001a2c:	5d87b783          	ld	a5,1496(a5) # 80008000 <etext>
    80001a30:	02f50533          	mul	a0,a0,a5
  //Set queue of process we're de-queueing to empty
  qtable[pindex].queue = EMPTY;
    80001a34:	0000f717          	auipc	a4,0xf
    80001a38:	17c70713          	addi	a4,a4,380 # 80010bb0 <qtable>
    80001a3c:	00151793          	slli	a5,a0,0x1
    80001a40:	00a786b3          	add	a3,a5,a0
    80001a44:	068e                	slli	a3,a3,0x3
    80001a46:	96ba                	add	a3,a3,a4
    80001a48:	567d                	li	a2,-1
    80001a4a:	e290                	sd	a2,0(a3)
  //Placehold the old prev and next even though they'll still be there for ease of use
  int oldPrev = qtable[pindex].prev;
    80001a4c:	4694                	lw	a3,8(a3)
  int oldNext = qtable[pindex].next;
    80001a4e:	97aa                	add	a5,a5,a0
    80001a50:	078e                	slli	a5,a5,0x3
    80001a52:	97ba                	add	a5,a5,a4
    80001a54:	4b90                	lw	a2,16(a5)
  qtable[oldPrev].next = oldNext;
    80001a56:	00169793          	slli	a5,a3,0x1
    80001a5a:	97b6                	add	a5,a5,a3
    80001a5c:	078e                	slli	a5,a5,0x3
    80001a5e:	97ba                	add	a5,a5,a4
    80001a60:	eb90                	sd	a2,16(a5)
  qtable[oldNext].prev = oldPrev;
    80001a62:	00161793          	slli	a5,a2,0x1
    80001a66:	97b2                	add	a5,a5,a2
    80001a68:	078e                	slli	a5,a5,0x3
    80001a6a:	973e                	add	a4,a4,a5
    80001a6c:	e714                	sd	a3,8(a4)
}
    80001a6e:	6422                	ld	s0,8(sp)
    80001a70:	0141                	addi	sp,sp,16
    80001a72:	8082                	ret

0000000080001a74 <dequeue>:

void dequeue(){
    80001a74:	7139                	addi	sp,sp,-64
    80001a76:	fc06                	sd	ra,56(sp)
    80001a78:	f822                	sd	s0,48(sp)
    80001a7a:	f426                	sd	s1,40(sp)
    80001a7c:	f04a                	sd	s2,32(sp)
    80001a7e:	ec4e                	sd	s3,24(sp)
    80001a80:	e852                	sd	s4,16(sp)
    80001a82:	e456                	sd	s5,8(sp)
    80001a84:	0080                	addi	s0,sp,64
  //Find first process
  struct proc *p;
  //If the head pointer is tail then we go to the next queue down the list because priority
  if(qtable[HEAD_Q0].next != TAIL_Q0){
    80001a86:	0000f497          	auipc	s1,0xf
    80001a8a:	73a4b483          	ld	s1,1850(s1) # 800111c0 <qtable+0x610>
    80001a8e:	04100793          	li	a5,65
    80001a92:	0cf48a63          	beq	s1,a5,80001b66 <dequeue+0xf2>
    //Find first process, set it to local variable and then dequeue it, at the end return it to scheduler.
    //Set p to head of queue 0
    p = &proc[qtable[HEAD_Q0].next];
    80001a96:	17800793          	li	a5,376
    80001a9a:	02f484b3          	mul	s1,s1,a5
    80001a9e:	00010797          	auipc	a5,0x10
    80001aa2:	ef278793          	addi	a5,a5,-270 # 80011990 <proc>
    80001aa6:	94be                	add	s1,s1,a5
  }else{
    return;
  }
  
  //Remove p from the queue since we're gonna run it?
  removeFromQueue(p);
    80001aa8:	8526                	mv	a0,s1
    80001aaa:	00000097          	auipc	ra,0x0
    80001aae:	f6c080e7          	jalr	-148(ra) # 80001a16 <removeFromQueue>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ab2:	8792                	mv	a5,tp
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
    80001ab4:	0007899b          	sext.w	s3,a5
  c->proc = 0;
    80001ab8:	00799a13          	slli	s4,s3,0x7
    80001abc:	0000f917          	auipc	s2,0xf
    80001ac0:	0f490913          	addi	s2,s2,244 # 80010bb0 <qtable>
    80001ac4:	9952                	add	s2,s2,s4
    80001ac6:	68093823          	sd	zero,1680(s2)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001aca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ace:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ad2:	10079073          	csrw	sstatus,a5
  acquire(&p->lock);
    80001ad6:	8aa6                	mv	s5,s1
    80001ad8:	8526                	mv	a0,s1
    80001ada:	fffff097          	auipc	ra,0xfffff
    80001ade:	0fc080e7          	jalr	252(ra) # 80000bd6 <acquire>
  p->state = RUNNING;
    80001ae2:	4791                	li	a5,4
    80001ae4:	cc9c                	sw	a5,24(s1)
  c->proc = p;
    80001ae6:	68993823          	sd	s1,1680(s2)
  swtch(&c->context, &p->context);
    80001aea:	06048593          	addi	a1,s1,96
    80001aee:	0000f517          	auipc	a0,0xf
    80001af2:	75a50513          	addi	a0,a0,1882 # 80011248 <cpus+0x8>
    80001af6:	9552                	add	a0,a0,s4
    80001af8:	00001097          	auipc	ra,0x1
    80001afc:	03e080e7          	jalr	62(ra) # 80002b36 <swtch>
  if (is_logging && (num_logged == 0 || schedlog[num_logged-1].pid != p->pid) && num_logged < LOG_SIZE) {
    80001b00:	00007797          	auipc	a5,0x7
    80001b04:	e347a783          	lw	a5,-460(a5) # 80008934 <is_logging>
    80001b08:	cb85                	beqz	a5,80001b38 <dequeue+0xc4>
    80001b0a:	00007797          	auipc	a5,0x7
    80001b0e:	e267a783          	lw	a5,-474(a5) # 80008930 <num_logged>
    80001b12:	cfd1                	beqz	a5,80001bae <dequeue+0x13a>
    80001b14:	fff7871b          	addiw	a4,a5,-1
    80001b18:	00371693          	slli	a3,a4,0x3
    80001b1c:	00010717          	auipc	a4,0x10
    80001b20:	09470713          	addi	a4,a4,148 # 80011bb0 <proc+0x220>
    80001b24:	9736                	add	a4,a4,a3
    80001b26:	a9072683          	lw	a3,-1392(a4)
    80001b2a:	5898                	lw	a4,48(s1)
    80001b2c:	00e68663          	beq	a3,a4,80001b38 <dequeue+0xc4>
    80001b30:	06300713          	li	a4,99
    80001b34:	06f75d63          	bge	a4,a5,80001bae <dequeue+0x13a>
  c->proc = 0;
    80001b38:	00799793          	slli	a5,s3,0x7
    80001b3c:	0000f717          	auipc	a4,0xf
    80001b40:	07470713          	addi	a4,a4,116 # 80010bb0 <qtable>
    80001b44:	97ba                	add	a5,a5,a4
    80001b46:	6807b823          	sd	zero,1680(a5)
  release(&p->lock);
    80001b4a:	8556                	mv	a0,s5
    80001b4c:	fffff097          	auipc	ra,0xfffff
    80001b50:	13e080e7          	jalr	318(ra) # 80000c8a <release>
}
    80001b54:	70e2                	ld	ra,56(sp)
    80001b56:	7442                	ld	s0,48(sp)
    80001b58:	74a2                	ld	s1,40(sp)
    80001b5a:	7902                	ld	s2,32(sp)
    80001b5c:	69e2                	ld	s3,24(sp)
    80001b5e:	6a42                	ld	s4,16(sp)
    80001b60:	6aa2                	ld	s5,8(sp)
    80001b62:	6121                	addi	sp,sp,64
    80001b64:	8082                	ret
  }else if(qtable[HEAD_Q1].next != TAIL_Q1){
    80001b66:	0000f497          	auipc	s1,0xf
    80001b6a:	68a4b483          	ld	s1,1674(s1) # 800111f0 <qtable+0x640>
    80001b6e:	04300793          	li	a5,67
    80001b72:	00f48c63          	beq	s1,a5,80001b8a <dequeue+0x116>
    p = &proc[qtable[HEAD_Q1].next];
    80001b76:	17800793          	li	a5,376
    80001b7a:	02f484b3          	mul	s1,s1,a5
    80001b7e:	00010797          	auipc	a5,0x10
    80001b82:	e1278793          	addi	a5,a5,-494 # 80011990 <proc>
    80001b86:	94be                	add	s1,s1,a5
    80001b88:	b705                	j	80001aa8 <dequeue+0x34>
  }else if(qtable[HEAD_Q2].next != TAIL_Q2){
    80001b8a:	0000f497          	auipc	s1,0xf
    80001b8e:	6964b483          	ld	s1,1686(s1) # 80011220 <qtable+0x670>
    80001b92:	04500793          	li	a5,69
    80001b96:	faf48fe3          	beq	s1,a5,80001b54 <dequeue+0xe0>
    p = &proc[qtable[HEAD_Q2].next];
    80001b9a:	17800793          	li	a5,376
    80001b9e:	02f484b3          	mul	s1,s1,a5
    80001ba2:	00010797          	auipc	a5,0x10
    80001ba6:	dee78793          	addi	a5,a5,-530 # 80011990 <proc>
    80001baa:	94be                	add	s1,s1,a5
    80001bac:	bdf5                	j	80001aa8 <dequeue+0x34>
    schedlog[num_logged].pid = p->pid;
    80001bae:	00379693          	slli	a3,a5,0x3
    80001bb2:	00010717          	auipc	a4,0x10
    80001bb6:	ffe70713          	addi	a4,a4,-2 # 80011bb0 <proc+0x220>
    80001bba:	9736                	add	a4,a4,a3
    80001bbc:	5894                	lw	a3,48(s1)
    80001bbe:	a8d72823          	sw	a3,-1392(a4)
    schedlog[num_logged].time = time;
    80001bc2:	00007697          	auipc	a3,0x7
    80001bc6:	d766a683          	lw	a3,-650(a3) # 80008938 <time>
    80001bca:	a8d72a23          	sw	a3,-1388(a4)
    num_logged++;
    80001bce:	2785                	addiw	a5,a5,1
    80001bd0:	00007717          	auipc	a4,0x7
    80001bd4:	d6f72023          	sw	a5,-672(a4) # 80008930 <num_logged>
    80001bd8:	b785                	j	80001b38 <dequeue+0xc4>

0000000080001bda <sys_startlog>:
{
    80001bda:	1141                	addi	sp,sp,-16
    80001bdc:	e422                	sd	s0,8(sp)
    80001bde:	0800                	addi	s0,sp,16
  if (is_logging) {
    80001be0:	00007797          	auipc	a5,0x7
    80001be4:	d547a783          	lw	a5,-684(a5) # 80008934 <is_logging>
    return -1; 
    80001be8:	557d                	li	a0,-1
  if (is_logging) {
    80001bea:	e799                	bnez	a5,80001bf8 <sys_startlog+0x1e>
  is_logging = 1; 
    80001bec:	4785                	li	a5,1
    80001bee:	00007717          	auipc	a4,0x7
    80001bf2:	d4f72323          	sw	a5,-698(a4) # 80008934 <is_logging>
  return 0;
    80001bf6:	4501                	li	a0,0
}
    80001bf8:	6422                	ld	s0,8(sp)
    80001bfa:	0141                	addi	sp,sp,16
    80001bfc:	8082                	ret

0000000080001bfe <proc_mapstacks>:
{
    80001bfe:	7139                	addi	sp,sp,-64
    80001c00:	fc06                	sd	ra,56(sp)
    80001c02:	f822                	sd	s0,48(sp)
    80001c04:	f426                	sd	s1,40(sp)
    80001c06:	f04a                	sd	s2,32(sp)
    80001c08:	ec4e                	sd	s3,24(sp)
    80001c0a:	e852                	sd	s4,16(sp)
    80001c0c:	e456                	sd	s5,8(sp)
    80001c0e:	e05a                	sd	s6,0(sp)
    80001c10:	0080                	addi	s0,sp,64
    80001c12:	89aa                	mv	s3,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c14:	00010497          	auipc	s1,0x10
    80001c18:	d7c48493          	addi	s1,s1,-644 # 80011990 <proc>
    uint64 va = KSTACK((int) (p - proc));
    80001c1c:	8b26                	mv	s6,s1
    80001c1e:	00006a97          	auipc	s5,0x6
    80001c22:	3e2a8a93          	addi	s5,s5,994 # 80008000 <etext>
    80001c26:	04000937          	lui	s2,0x4000
    80001c2a:	197d                	addi	s2,s2,-1
    80001c2c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c2e:	00016a17          	auipc	s4,0x16
    80001c32:	b62a0a13          	addi	s4,s4,-1182 # 80017790 <tickslock>
    char *pa = kalloc();
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	eb0080e7          	jalr	-336(ra) # 80000ae6 <kalloc>
    80001c3e:	862a                	mv	a2,a0
    if(pa == 0)
    80001c40:	c131                	beqz	a0,80001c84 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001c42:	416485b3          	sub	a1,s1,s6
    80001c46:	858d                	srai	a1,a1,0x3
    80001c48:	000ab783          	ld	a5,0(s5)
    80001c4c:	02f585b3          	mul	a1,a1,a5
    80001c50:	2585                	addiw	a1,a1,1
    80001c52:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c56:	4719                	li	a4,6
    80001c58:	6685                	lui	a3,0x1
    80001c5a:	40b905b3          	sub	a1,s2,a1
    80001c5e:	854e                	mv	a0,s3
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	4de080e7          	jalr	1246(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c68:	17848493          	addi	s1,s1,376
    80001c6c:	fd4495e3          	bne	s1,s4,80001c36 <proc_mapstacks+0x38>
}
    80001c70:	70e2                	ld	ra,56(sp)
    80001c72:	7442                	ld	s0,48(sp)
    80001c74:	74a2                	ld	s1,40(sp)
    80001c76:	7902                	ld	s2,32(sp)
    80001c78:	69e2                	ld	s3,24(sp)
    80001c7a:	6a42                	ld	s4,16(sp)
    80001c7c:	6aa2                	ld	s5,8(sp)
    80001c7e:	6b02                	ld	s6,0(sp)
    80001c80:	6121                	addi	sp,sp,64
    80001c82:	8082                	ret
      panic("kalloc");
    80001c84:	00006517          	auipc	a0,0x6
    80001c88:	56c50513          	addi	a0,a0,1388 # 800081f0 <digits+0x1b0>
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	8b2080e7          	jalr	-1870(ra) # 8000053e <panic>

0000000080001c94 <procinit>:
{
    80001c94:	7139                	addi	sp,sp,-64
    80001c96:	fc06                	sd	ra,56(sp)
    80001c98:	f822                	sd	s0,48(sp)
    80001c9a:	f426                	sd	s1,40(sp)
    80001c9c:	f04a                	sd	s2,32(sp)
    80001c9e:	ec4e                	sd	s3,24(sp)
    80001ca0:	e852                	sd	s4,16(sp)
    80001ca2:	e456                	sd	s5,8(sp)
    80001ca4:	e05a                	sd	s6,0(sp)
    80001ca6:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80001ca8:	00006597          	auipc	a1,0x6
    80001cac:	55058593          	addi	a1,a1,1360 # 800081f8 <digits+0x1b8>
    80001cb0:	00010517          	auipc	a0,0x10
    80001cb4:	cb050513          	addi	a0,a0,-848 # 80011960 <pid_lock>
    80001cb8:	fffff097          	auipc	ra,0xfffff
    80001cbc:	e8e080e7          	jalr	-370(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001cc0:	00006597          	auipc	a1,0x6
    80001cc4:	54058593          	addi	a1,a1,1344 # 80008200 <digits+0x1c0>
    80001cc8:	00010517          	auipc	a0,0x10
    80001ccc:	cb050513          	addi	a0,a0,-848 # 80011978 <wait_lock>
    80001cd0:	fffff097          	auipc	ra,0xfffff
    80001cd4:	e76080e7          	jalr	-394(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cd8:	00010497          	auipc	s1,0x10
    80001cdc:	cb848493          	addi	s1,s1,-840 # 80011990 <proc>
      initlock(&p->lock, "proc");
    80001ce0:	00006b17          	auipc	s6,0x6
    80001ce4:	530b0b13          	addi	s6,s6,1328 # 80008210 <digits+0x1d0>
      p->kstack = KSTACK((int) (p - proc));
    80001ce8:	8aa6                	mv	s5,s1
    80001cea:	00006a17          	auipc	s4,0x6
    80001cee:	316a0a13          	addi	s4,s4,790 # 80008000 <etext>
    80001cf2:	04000937          	lui	s2,0x4000
    80001cf6:	197d                	addi	s2,s2,-1
    80001cf8:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cfa:	00016997          	auipc	s3,0x16
    80001cfe:	a9698993          	addi	s3,s3,-1386 # 80017790 <tickslock>
      initlock(&p->lock, "proc");
    80001d02:	85da                	mv	a1,s6
    80001d04:	8526                	mv	a0,s1
    80001d06:	fffff097          	auipc	ra,0xfffff
    80001d0a:	e40080e7          	jalr	-448(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001d0e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001d12:	415487b3          	sub	a5,s1,s5
    80001d16:	878d                	srai	a5,a5,0x3
    80001d18:	000a3703          	ld	a4,0(s4)
    80001d1c:	02e787b3          	mul	a5,a5,a4
    80001d20:	2785                	addiw	a5,a5,1
    80001d22:	00d7979b          	slliw	a5,a5,0xd
    80001d26:	40f907b3          	sub	a5,s2,a5
    80001d2a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d2c:	17848493          	addi	s1,s1,376
    80001d30:	fd3499e3          	bne	s1,s3,80001d02 <procinit+0x6e>
}
    80001d34:	70e2                	ld	ra,56(sp)
    80001d36:	7442                	ld	s0,48(sp)
    80001d38:	74a2                	ld	s1,40(sp)
    80001d3a:	7902                	ld	s2,32(sp)
    80001d3c:	69e2                	ld	s3,24(sp)
    80001d3e:	6a42                	ld	s4,16(sp)
    80001d40:	6aa2                	ld	s5,8(sp)
    80001d42:	6b02                	ld	s6,0(sp)
    80001d44:	6121                	addi	sp,sp,64
    80001d46:	8082                	ret

0000000080001d48 <cpuid>:
{
    80001d48:	1141                	addi	sp,sp,-16
    80001d4a:	e422                	sd	s0,8(sp)
    80001d4c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d4e:	8512                	mv	a0,tp
  return id;
}
    80001d50:	2501                	sext.w	a0,a0
    80001d52:	6422                	ld	s0,8(sp)
    80001d54:	0141                	addi	sp,sp,16
    80001d56:	8082                	ret

0000000080001d58 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001d58:	1141                	addi	sp,sp,-16
    80001d5a:	e422                	sd	s0,8(sp)
    80001d5c:	0800                	addi	s0,sp,16
    80001d5e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001d60:	2781                	sext.w	a5,a5
    80001d62:	079e                	slli	a5,a5,0x7
  return c;
}
    80001d64:	0000f517          	auipc	a0,0xf
    80001d68:	4dc50513          	addi	a0,a0,1244 # 80011240 <cpus>
    80001d6c:	953e                	add	a0,a0,a5
    80001d6e:	6422                	ld	s0,8(sp)
    80001d70:	0141                	addi	sp,sp,16
    80001d72:	8082                	ret

0000000080001d74 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001d74:	1101                	addi	sp,sp,-32
    80001d76:	ec06                	sd	ra,24(sp)
    80001d78:	e822                	sd	s0,16(sp)
    80001d7a:	e426                	sd	s1,8(sp)
    80001d7c:	1000                	addi	s0,sp,32
  push_off();
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	e0c080e7          	jalr	-500(ra) # 80000b8a <push_off>
    80001d86:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001d88:	2781                	sext.w	a5,a5
    80001d8a:	079e                	slli	a5,a5,0x7
    80001d8c:	0000f717          	auipc	a4,0xf
    80001d90:	e2470713          	addi	a4,a4,-476 # 80010bb0 <qtable>
    80001d94:	97ba                	add	a5,a5,a4
    80001d96:	6907b483          	ld	s1,1680(a5)
  pop_off();
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	e90080e7          	jalr	-368(ra) # 80000c2a <pop_off>
  return p;
}
    80001da2:	8526                	mv	a0,s1
    80001da4:	60e2                	ld	ra,24(sp)
    80001da6:	6442                	ld	s0,16(sp)
    80001da8:	64a2                	ld	s1,8(sp)
    80001daa:	6105                	addi	sp,sp,32
    80001dac:	8082                	ret

0000000080001dae <sys_getlog>:
sys_getlog(void) {
    80001dae:	1101                	addi	sp,sp,-32
    80001db0:	ec06                	sd	ra,24(sp)
    80001db2:	e822                	sd	s0,16(sp)
    80001db4:	1000                	addi	s0,sp,32
    argaddr(0, &userlog);
    80001db6:	fe840593          	addi	a1,s0,-24
    80001dba:	4501                	li	a0,0
    80001dbc:	00001097          	auipc	ra,0x1
    80001dc0:	2c0080e7          	jalr	704(ra) # 8000307c <argaddr>
    struct proc *p = myproc();
    80001dc4:	00000097          	auipc	ra,0x0
    80001dc8:	fb0080e7          	jalr	-80(ra) # 80001d74 <myproc>
    if (copyout(p->pagetable, userlog, (char *)schedlog,
    80001dcc:	32000693          	li	a3,800
    80001dd0:	00010617          	auipc	a2,0x10
    80001dd4:	87060613          	addi	a2,a2,-1936 # 80011640 <schedlog>
    80001dd8:	fe843583          	ld	a1,-24(s0)
    80001ddc:	6928                	ld	a0,80(a0)
    80001dde:	00000097          	auipc	ra,0x0
    80001de2:	88a080e7          	jalr	-1910(ra) # 80001668 <copyout>
    80001de6:	00054a63          	bltz	a0,80001dfa <sys_getlog+0x4c>
    return num_logged;
    80001dea:	00007517          	auipc	a0,0x7
    80001dee:	b4652503          	lw	a0,-1210(a0) # 80008930 <num_logged>
}
    80001df2:	60e2                	ld	ra,24(sp)
    80001df4:	6442                	ld	s0,16(sp)
    80001df6:	6105                	addi	sp,sp,32
    80001df8:	8082                	ret
        return -1;
    80001dfa:	557d                	li	a0,-1
    80001dfc:	bfdd                	j	80001df2 <sys_getlog+0x44>

0000000080001dfe <sys_nice>:
sys_nice(void) {
    80001dfe:	7179                	addi	sp,sp,-48
    80001e00:	f406                	sd	ra,40(sp)
    80001e02:	f022                	sd	s0,32(sp)
    80001e04:	ec26                	sd	s1,24(sp)
    80001e06:	1800                	addi	s0,sp,48
  argint(0, &inc);
    80001e08:	fdc40593          	addi	a1,s0,-36
    80001e0c:	4501                	li	a0,0
    80001e0e:	00001097          	auipc	ra,0x1
    80001e12:	24e080e7          	jalr	590(ra) # 8000305c <argint>
  struct proc *p = myproc();
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	f5e080e7          	jalr	-162(ra) # 80001d74 <myproc>
    80001e1e:	84aa                	mv	s1,a0
  p->nice += inc;
    80001e20:	16852783          	lw	a5,360(a0)
    80001e24:	fdc42703          	lw	a4,-36(s0)
    80001e28:	9fb9                	addw	a5,a5,a4
    80001e2a:	0007871b          	sext.w	a4,a5
    80001e2e:	16f52423          	sw	a5,360(a0)
  if (p->nice > 19) {
    80001e32:	47cd                	li	a5,19
    80001e34:	02e7d063          	bge	a5,a4,80001e54 <sys_nice+0x56>
	  p->nice = 19;
    80001e38:	16f52423          	sw	a5,360(a0)
    tempQueue = 0;
    80001e3c:	4781                	li	a5,0
  if(tempQueue != p->queue){
    80001e3e:	1704a703          	lw	a4,368(s1)
    80001e42:	04f71263          	bne	a4,a5,80001e86 <sys_nice+0x88>
}
    80001e46:	1684a503          	lw	a0,360(s1)
    80001e4a:	70a2                	ld	ra,40(sp)
    80001e4c:	7402                	ld	s0,32(sp)
    80001e4e:	64e2                	ld	s1,24(sp)
    80001e50:	6145                	addi	sp,sp,48
    80001e52:	8082                	ret
  if (p->nice < -20) {
    80001e54:	57b1                	li	a5,-20
    80001e56:	00f75663          	bge	a4,a5,80001e62 <sys_nice+0x64>
	  p->nice = -20;
    80001e5a:	16f52423          	sw	a5,360(a0)
    tempQueue = 1;
    80001e5e:	4785                	li	a5,1
    80001e60:	bff9                	j	80001e3e <sys_nice+0x40>
  if(p->nice > 10){
    80001e62:	16852703          	lw	a4,360(a0)
    80001e66:	47a9                	li	a5,10
    80001e68:	00e7cb63          	blt	a5,a4,80001e7e <sys_nice+0x80>
  }else if(p->nice < -10 && p->nice <= 10){
    80001e6c:	57d9                	li	a5,-10
    80001e6e:	00f74a63          	blt	a4,a5,80001e82 <sys_nice+0x84>
  }else if(p->nice <= -10){
    80001e72:	56d9                	li	a3,-10
  int tempQueue = -1;
    80001e74:	57fd                	li	a5,-1
  }else if(p->nice <= -10){
    80001e76:	fcd714e3          	bne	a4,a3,80001e3e <sys_nice+0x40>
    tempQueue = 2;
    80001e7a:	4789                	li	a5,2
    80001e7c:	b7c9                	j	80001e3e <sys_nice+0x40>
    tempQueue = 0;
    80001e7e:	4781                	li	a5,0
    80001e80:	bf7d                	j	80001e3e <sys_nice+0x40>
    tempQueue = 1;
    80001e82:	4785                	li	a5,1
    80001e84:	bf6d                	j	80001e3e <sys_nice+0x40>
    removeFromQueue(p);
    80001e86:	8526                	mv	a0,s1
    80001e88:	00000097          	auipc	ra,0x0
    80001e8c:	b8e080e7          	jalr	-1138(ra) # 80001a16 <removeFromQueue>
    enqueue(p);
    80001e90:	8526                	mv	a0,s1
    80001e92:	00000097          	auipc	ra,0x0
    80001e96:	a32080e7          	jalr	-1486(ra) # 800018c4 <enqueue>
    80001e9a:	b775                	j	80001e46 <sys_nice+0x48>

0000000080001e9c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001e9c:	1141                	addi	sp,sp,-16
    80001e9e:	e406                	sd	ra,8(sp)
    80001ea0:	e022                	sd	s0,0(sp)
    80001ea2:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001ea4:	00000097          	auipc	ra,0x0
    80001ea8:	ed0080e7          	jalr	-304(ra) # 80001d74 <myproc>
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	dde080e7          	jalr	-546(ra) # 80000c8a <release>

  if (first) {
    80001eb4:	00007797          	auipc	a5,0x7
    80001eb8:	9dc7a783          	lw	a5,-1572(a5) # 80008890 <first.1>
    80001ebc:	eb89                	bnez	a5,80001ece <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ebe:	00001097          	auipc	ra,0x1
    80001ec2:	d22080e7          	jalr	-734(ra) # 80002be0 <usertrapret>
}
    80001ec6:	60a2                	ld	ra,8(sp)
    80001ec8:	6402                	ld	s0,0(sp)
    80001eca:	0141                	addi	sp,sp,16
    80001ecc:	8082                	ret
    first = 0;
    80001ece:	00007797          	auipc	a5,0x7
    80001ed2:	9c07a123          	sw	zero,-1598(a5) # 80008890 <first.1>
    fsinit(ROOTDEV);
    80001ed6:	4505                	li	a0,1
    80001ed8:	00002097          	auipc	ra,0x2
    80001edc:	a74080e7          	jalr	-1420(ra) # 8000394c <fsinit>
    80001ee0:	bff9                	j	80001ebe <forkret+0x22>

0000000080001ee2 <allocpid>:
{
    80001ee2:	1101                	addi	sp,sp,-32
    80001ee4:	ec06                	sd	ra,24(sp)
    80001ee6:	e822                	sd	s0,16(sp)
    80001ee8:	e426                	sd	s1,8(sp)
    80001eea:	e04a                	sd	s2,0(sp)
    80001eec:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001eee:	00010917          	auipc	s2,0x10
    80001ef2:	a7290913          	addi	s2,s2,-1422 # 80011960 <pid_lock>
    80001ef6:	854a                	mv	a0,s2
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	cde080e7          	jalr	-802(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001f00:	00007797          	auipc	a5,0x7
    80001f04:	99478793          	addi	a5,a5,-1644 # 80008894 <nextpid>
    80001f08:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001f0a:	0014871b          	addiw	a4,s1,1
    80001f0e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001f10:	854a                	mv	a0,s2
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	d78080e7          	jalr	-648(ra) # 80000c8a <release>
}
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	60e2                	ld	ra,24(sp)
    80001f1e:	6442                	ld	s0,16(sp)
    80001f20:	64a2                	ld	s1,8(sp)
    80001f22:	6902                	ld	s2,0(sp)
    80001f24:	6105                	addi	sp,sp,32
    80001f26:	8082                	ret

0000000080001f28 <proc_pagetable>:
{
    80001f28:	1101                	addi	sp,sp,-32
    80001f2a:	ec06                	sd	ra,24(sp)
    80001f2c:	e822                	sd	s0,16(sp)
    80001f2e:	e426                	sd	s1,8(sp)
    80001f30:	e04a                	sd	s2,0(sp)
    80001f32:	1000                	addi	s0,sp,32
    80001f34:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	3f2080e7          	jalr	1010(ra) # 80001328 <uvmcreate>
    80001f3e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001f40:	c121                	beqz	a0,80001f80 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001f42:	4729                	li	a4,10
    80001f44:	00005697          	auipc	a3,0x5
    80001f48:	0bc68693          	addi	a3,a3,188 # 80007000 <_trampoline>
    80001f4c:	6605                	lui	a2,0x1
    80001f4e:	040005b7          	lui	a1,0x4000
    80001f52:	15fd                	addi	a1,a1,-1
    80001f54:	05b2                	slli	a1,a1,0xc
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	148080e7          	jalr	328(ra) # 8000109e <mappages>
    80001f5e:	02054863          	bltz	a0,80001f8e <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001f62:	4719                	li	a4,6
    80001f64:	05893683          	ld	a3,88(s2)
    80001f68:	6605                	lui	a2,0x1
    80001f6a:	020005b7          	lui	a1,0x2000
    80001f6e:	15fd                	addi	a1,a1,-1
    80001f70:	05b6                	slli	a1,a1,0xd
    80001f72:	8526                	mv	a0,s1
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	12a080e7          	jalr	298(ra) # 8000109e <mappages>
    80001f7c:	02054163          	bltz	a0,80001f9e <proc_pagetable+0x76>
}
    80001f80:	8526                	mv	a0,s1
    80001f82:	60e2                	ld	ra,24(sp)
    80001f84:	6442                	ld	s0,16(sp)
    80001f86:	64a2                	ld	s1,8(sp)
    80001f88:	6902                	ld	s2,0(sp)
    80001f8a:	6105                	addi	sp,sp,32
    80001f8c:	8082                	ret
    uvmfree(pagetable, 0);
    80001f8e:	4581                	li	a1,0
    80001f90:	8526                	mv	a0,s1
    80001f92:	fffff097          	auipc	ra,0xfffff
    80001f96:	59a080e7          	jalr	1434(ra) # 8000152c <uvmfree>
    return 0;
    80001f9a:	4481                	li	s1,0
    80001f9c:	b7d5                	j	80001f80 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f9e:	4681                	li	a3,0
    80001fa0:	4605                	li	a2,1
    80001fa2:	040005b7          	lui	a1,0x4000
    80001fa6:	15fd                	addi	a1,a1,-1
    80001fa8:	05b2                	slli	a1,a1,0xc
    80001faa:	8526                	mv	a0,s1
    80001fac:	fffff097          	auipc	ra,0xfffff
    80001fb0:	2b8080e7          	jalr	696(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001fb4:	4581                	li	a1,0
    80001fb6:	8526                	mv	a0,s1
    80001fb8:	fffff097          	auipc	ra,0xfffff
    80001fbc:	574080e7          	jalr	1396(ra) # 8000152c <uvmfree>
    return 0;
    80001fc0:	4481                	li	s1,0
    80001fc2:	bf7d                	j	80001f80 <proc_pagetable+0x58>

0000000080001fc4 <proc_freepagetable>:
{
    80001fc4:	1101                	addi	sp,sp,-32
    80001fc6:	ec06                	sd	ra,24(sp)
    80001fc8:	e822                	sd	s0,16(sp)
    80001fca:	e426                	sd	s1,8(sp)
    80001fcc:	e04a                	sd	s2,0(sp)
    80001fce:	1000                	addi	s0,sp,32
    80001fd0:	84aa                	mv	s1,a0
    80001fd2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001fd4:	4681                	li	a3,0
    80001fd6:	4605                	li	a2,1
    80001fd8:	040005b7          	lui	a1,0x4000
    80001fdc:	15fd                	addi	a1,a1,-1
    80001fde:	05b2                	slli	a1,a1,0xc
    80001fe0:	fffff097          	auipc	ra,0xfffff
    80001fe4:	284080e7          	jalr	644(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001fe8:	4681                	li	a3,0
    80001fea:	4605                	li	a2,1
    80001fec:	020005b7          	lui	a1,0x2000
    80001ff0:	15fd                	addi	a1,a1,-1
    80001ff2:	05b6                	slli	a1,a1,0xd
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	fffff097          	auipc	ra,0xfffff
    80001ffa:	26e080e7          	jalr	622(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ffe:	85ca                	mv	a1,s2
    80002000:	8526                	mv	a0,s1
    80002002:	fffff097          	auipc	ra,0xfffff
    80002006:	52a080e7          	jalr	1322(ra) # 8000152c <uvmfree>
}
    8000200a:	60e2                	ld	ra,24(sp)
    8000200c:	6442                	ld	s0,16(sp)
    8000200e:	64a2                	ld	s1,8(sp)
    80002010:	6902                	ld	s2,0(sp)
    80002012:	6105                	addi	sp,sp,32
    80002014:	8082                	ret

0000000080002016 <freeproc>:
{
    80002016:	1101                	addi	sp,sp,-32
    80002018:	ec06                	sd	ra,24(sp)
    8000201a:	e822                	sd	s0,16(sp)
    8000201c:	e426                	sd	s1,8(sp)
    8000201e:	1000                	addi	s0,sp,32
    80002020:	84aa                	mv	s1,a0
  if(p->trapframe)
    80002022:	6d28                	ld	a0,88(a0)
    80002024:	c509                	beqz	a0,8000202e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80002026:	fffff097          	auipc	ra,0xfffff
    8000202a:	9c4080e7          	jalr	-1596(ra) # 800009ea <kfree>
  p->trapframe = 0;
    8000202e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80002032:	68a8                	ld	a0,80(s1)
    80002034:	c511                	beqz	a0,80002040 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80002036:	64ac                	ld	a1,72(s1)
    80002038:	00000097          	auipc	ra,0x0
    8000203c:	f8c080e7          	jalr	-116(ra) # 80001fc4 <proc_freepagetable>
  p->pagetable = 0;
    80002040:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80002044:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80002048:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000204c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80002050:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80002054:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80002058:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000205c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80002060:	0004ac23          	sw	zero,24(s1)
  p->nice = 0;
    80002064:	1604a423          	sw	zero,360(s1)
}
    80002068:	60e2                	ld	ra,24(sp)
    8000206a:	6442                	ld	s0,16(sp)
    8000206c:	64a2                	ld	s1,8(sp)
    8000206e:	6105                	addi	sp,sp,32
    80002070:	8082                	ret

0000000080002072 <allocproc>:
{
    80002072:	1101                	addi	sp,sp,-32
    80002074:	ec06                	sd	ra,24(sp)
    80002076:	e822                	sd	s0,16(sp)
    80002078:	e426                	sd	s1,8(sp)
    8000207a:	e04a                	sd	s2,0(sp)
    8000207c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000207e:	00010497          	auipc	s1,0x10
    80002082:	91248493          	addi	s1,s1,-1774 # 80011990 <proc>
    80002086:	00015917          	auipc	s2,0x15
    8000208a:	70a90913          	addi	s2,s2,1802 # 80017790 <tickslock>
    acquire(&p->lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	b46080e7          	jalr	-1210(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80002098:	4c9c                	lw	a5,24(s1)
    8000209a:	cf81                	beqz	a5,800020b2 <allocproc+0x40>
      release(&p->lock);
    8000209c:	8526                	mv	a0,s1
    8000209e:	fffff097          	auipc	ra,0xfffff
    800020a2:	bec080e7          	jalr	-1044(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020a6:	17848493          	addi	s1,s1,376
    800020aa:	ff2492e3          	bne	s1,s2,8000208e <allocproc+0x1c>
  return 0;
    800020ae:	4481                	li	s1,0
    800020b0:	a889                	j	80002102 <allocproc+0x90>
  p->pid = allocpid();
    800020b2:	00000097          	auipc	ra,0x0
    800020b6:	e30080e7          	jalr	-464(ra) # 80001ee2 <allocpid>
    800020ba:	d888                	sw	a0,48(s1)
  p->state = USED;
    800020bc:	4785                	li	a5,1
    800020be:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800020c0:	fffff097          	auipc	ra,0xfffff
    800020c4:	a26080e7          	jalr	-1498(ra) # 80000ae6 <kalloc>
    800020c8:	892a                	mv	s2,a0
    800020ca:	eca8                	sd	a0,88(s1)
    800020cc:	c131                	beqz	a0,80002110 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    800020ce:	8526                	mv	a0,s1
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	e58080e7          	jalr	-424(ra) # 80001f28 <proc_pagetable>
    800020d8:	892a                	mv	s2,a0
    800020da:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800020dc:	c531                	beqz	a0,80002128 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    800020de:	07000613          	li	a2,112
    800020e2:	4581                	li	a1,0
    800020e4:	06048513          	addi	a0,s1,96
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	bea080e7          	jalr	-1046(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    800020f0:	00000797          	auipc	a5,0x0
    800020f4:	dac78793          	addi	a5,a5,-596 # 80001e9c <forkret>
    800020f8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800020fa:	60bc                	ld	a5,64(s1)
    800020fc:	6705                	lui	a4,0x1
    800020fe:	97ba                	add	a5,a5,a4
    80002100:	f4bc                	sd	a5,104(s1)
}
    80002102:	8526                	mv	a0,s1
    80002104:	60e2                	ld	ra,24(sp)
    80002106:	6442                	ld	s0,16(sp)
    80002108:	64a2                	ld	s1,8(sp)
    8000210a:	6902                	ld	s2,0(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret
    freeproc(p);
    80002110:	8526                	mv	a0,s1
    80002112:	00000097          	auipc	ra,0x0
    80002116:	f04080e7          	jalr	-252(ra) # 80002016 <freeproc>
    release(&p->lock);
    8000211a:	8526                	mv	a0,s1
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	b6e080e7          	jalr	-1170(ra) # 80000c8a <release>
    return 0;
    80002124:	84ca                	mv	s1,s2
    80002126:	bff1                	j	80002102 <allocproc+0x90>
    freeproc(p);
    80002128:	8526                	mv	a0,s1
    8000212a:	00000097          	auipc	ra,0x0
    8000212e:	eec080e7          	jalr	-276(ra) # 80002016 <freeproc>
    release(&p->lock);
    80002132:	8526                	mv	a0,s1
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	b56080e7          	jalr	-1194(ra) # 80000c8a <release>
    return 0;
    8000213c:	84ca                	mv	s1,s2
    8000213e:	b7d1                	j	80002102 <allocproc+0x90>

0000000080002140 <userinit>:
{
    80002140:	1101                	addi	sp,sp,-32
    80002142:	ec06                	sd	ra,24(sp)
    80002144:	e822                	sd	s0,16(sp)
    80002146:	e426                	sd	s1,8(sp)
    80002148:	1000                	addi	s0,sp,32
  p = allocproc();
    8000214a:	00000097          	auipc	ra,0x0
    8000214e:	f28080e7          	jalr	-216(ra) # 80002072 <allocproc>
    80002152:	84aa                	mv	s1,a0
  initproc = p;
    80002154:	00006797          	auipc	a5,0x6
    80002158:	7ea7b623          	sd	a0,2028(a5) # 80008940 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    8000215c:	03400613          	li	a2,52
    80002160:	00006597          	auipc	a1,0x6
    80002164:	74058593          	addi	a1,a1,1856 # 800088a0 <initcode>
    80002168:	6928                	ld	a0,80(a0)
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	1ec080e7          	jalr	492(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80002172:	6785                	lui	a5,0x1
    80002174:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80002176:	6cb8                	ld	a4,88(s1)
    80002178:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    8000217c:	6cb8                	ld	a4,88(s1)
    8000217e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002180:	4641                	li	a2,16
    80002182:	00006597          	auipc	a1,0x6
    80002186:	09658593          	addi	a1,a1,150 # 80008218 <digits+0x1d8>
    8000218a:	15848513          	addi	a0,s1,344
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	c8e080e7          	jalr	-882(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80002196:	00006517          	auipc	a0,0x6
    8000219a:	09250513          	addi	a0,a0,146 # 80008228 <digits+0x1e8>
    8000219e:	00002097          	auipc	ra,0x2
    800021a2:	1d0080e7          	jalr	464(ra) # 8000436e <namei>
    800021a6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800021aa:	478d                	li	a5,3
    800021ac:	cc9c                	sw	a5,24(s1)
  if(isQueueSetup == 0){
    800021ae:	00006797          	auipc	a5,0x6
    800021b2:	77e7a783          	lw	a5,1918(a5) # 8000892c <isQueueSetup>
    800021b6:	c385                	beqz	a5,800021d6 <userinit+0x96>
  enqueue(p);
    800021b8:	8526                	mv	a0,s1
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	70a080e7          	jalr	1802(ra) # 800018c4 <enqueue>
  release(&p->lock);
    800021c2:	8526                	mv	a0,s1
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	ac6080e7          	jalr	-1338(ra) # 80000c8a <release>
}
    800021cc:	60e2                	ld	ra,24(sp)
    800021ce:	6442                	ld	s0,16(sp)
    800021d0:	64a2                	ld	s1,8(sp)
    800021d2:	6105                	addi	sp,sp,32
    800021d4:	8082                	ret
    setupQueue();
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	660080e7          	jalr	1632(ra) # 80001836 <setupQueue>
    isQueueSetup = 1;
    800021de:	4785                	li	a5,1
    800021e0:	00006717          	auipc	a4,0x6
    800021e4:	74f72623          	sw	a5,1868(a4) # 8000892c <isQueueSetup>
    800021e8:	bfc1                	j	800021b8 <userinit+0x78>

00000000800021ea <growproc>:
{
    800021ea:	1101                	addi	sp,sp,-32
    800021ec:	ec06                	sd	ra,24(sp)
    800021ee:	e822                	sd	s0,16(sp)
    800021f0:	e426                	sd	s1,8(sp)
    800021f2:	e04a                	sd	s2,0(sp)
    800021f4:	1000                	addi	s0,sp,32
    800021f6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800021f8:	00000097          	auipc	ra,0x0
    800021fc:	b7c080e7          	jalr	-1156(ra) # 80001d74 <myproc>
    80002200:	84aa                	mv	s1,a0
  sz = p->sz;
    80002202:	652c                	ld	a1,72(a0)
  if(n > 0){
    80002204:	01204c63          	bgtz	s2,8000221c <growproc+0x32>
  } else if(n < 0){
    80002208:	02094663          	bltz	s2,80002234 <growproc+0x4a>
  p->sz = sz;
    8000220c:	e4ac                	sd	a1,72(s1)
  return 0;
    8000220e:	4501                	li	a0,0
}
    80002210:	60e2                	ld	ra,24(sp)
    80002212:	6442                	ld	s0,16(sp)
    80002214:	64a2                	ld	s1,8(sp)
    80002216:	6902                	ld	s2,0(sp)
    80002218:	6105                	addi	sp,sp,32
    8000221a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000221c:	4691                	li	a3,4
    8000221e:	00b90633          	add	a2,s2,a1
    80002222:	6928                	ld	a0,80(a0)
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	1ec080e7          	jalr	492(ra) # 80001410 <uvmalloc>
    8000222c:	85aa                	mv	a1,a0
    8000222e:	fd79                	bnez	a0,8000220c <growproc+0x22>
      return -1;
    80002230:	557d                	li	a0,-1
    80002232:	bff9                	j	80002210 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002234:	00b90633          	add	a2,s2,a1
    80002238:	6928                	ld	a0,80(a0)
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	18e080e7          	jalr	398(ra) # 800013c8 <uvmdealloc>
    80002242:	85aa                	mv	a1,a0
    80002244:	b7e1                	j	8000220c <growproc+0x22>

0000000080002246 <fork>:
{
    80002246:	7139                	addi	sp,sp,-64
    80002248:	fc06                	sd	ra,56(sp)
    8000224a:	f822                	sd	s0,48(sp)
    8000224c:	f426                	sd	s1,40(sp)
    8000224e:	f04a                	sd	s2,32(sp)
    80002250:	ec4e                	sd	s3,24(sp)
    80002252:	e852                	sd	s4,16(sp)
    80002254:	e456                	sd	s5,8(sp)
    80002256:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002258:	00000097          	auipc	ra,0x0
    8000225c:	b1c080e7          	jalr	-1252(ra) # 80001d74 <myproc>
    80002260:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002262:	00000097          	auipc	ra,0x0
    80002266:	e10080e7          	jalr	-496(ra) # 80002072 <allocproc>
    8000226a:	14050063          	beqz	a0,800023aa <fork+0x164>
    8000226e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002270:	048ab603          	ld	a2,72(s5)
    80002274:	692c                	ld	a1,80(a0)
    80002276:	050ab503          	ld	a0,80(s5)
    8000227a:	fffff097          	auipc	ra,0xfffff
    8000227e:	2ea080e7          	jalr	746(ra) # 80001564 <uvmcopy>
    80002282:	04054863          	bltz	a0,800022d2 <fork+0x8c>
  np->sz = p->sz;
    80002286:	048ab783          	ld	a5,72(s5)
    8000228a:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    8000228e:	058ab683          	ld	a3,88(s5)
    80002292:	87b6                	mv	a5,a3
    80002294:	0589b703          	ld	a4,88(s3)
    80002298:	12068693          	addi	a3,a3,288
    8000229c:	0007b803          	ld	a6,0(a5)
    800022a0:	6788                	ld	a0,8(a5)
    800022a2:	6b8c                	ld	a1,16(a5)
    800022a4:	6f90                	ld	a2,24(a5)
    800022a6:	01073023          	sd	a6,0(a4)
    800022aa:	e708                	sd	a0,8(a4)
    800022ac:	eb0c                	sd	a1,16(a4)
    800022ae:	ef10                	sd	a2,24(a4)
    800022b0:	02078793          	addi	a5,a5,32
    800022b4:	02070713          	addi	a4,a4,32
    800022b8:	fed792e3          	bne	a5,a3,8000229c <fork+0x56>
  np->trapframe->a0 = 0;
    800022bc:	0589b783          	ld	a5,88(s3)
    800022c0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800022c4:	0d0a8493          	addi	s1,s5,208
    800022c8:	0d098913          	addi	s2,s3,208
    800022cc:	150a8a13          	addi	s4,s5,336
    800022d0:	a00d                	j	800022f2 <fork+0xac>
    freeproc(np);
    800022d2:	854e                	mv	a0,s3
    800022d4:	00000097          	auipc	ra,0x0
    800022d8:	d42080e7          	jalr	-702(ra) # 80002016 <freeproc>
    release(&np->lock);
    800022dc:	854e                	mv	a0,s3
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	9ac080e7          	jalr	-1620(ra) # 80000c8a <release>
    return -1;
    800022e6:	597d                	li	s2,-1
    800022e8:	a869                	j	80002382 <fork+0x13c>
  for(i = 0; i < NOFILE; i++)
    800022ea:	04a1                	addi	s1,s1,8
    800022ec:	0921                	addi	s2,s2,8
    800022ee:	01448b63          	beq	s1,s4,80002304 <fork+0xbe>
    if(p->ofile[i])
    800022f2:	6088                	ld	a0,0(s1)
    800022f4:	d97d                	beqz	a0,800022ea <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    800022f6:	00002097          	auipc	ra,0x2
    800022fa:	70e080e7          	jalr	1806(ra) # 80004a04 <filedup>
    800022fe:	00a93023          	sd	a0,0(s2)
    80002302:	b7e5                	j	800022ea <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002304:	150ab503          	ld	a0,336(s5)
    80002308:	00002097          	auipc	ra,0x2
    8000230c:	882080e7          	jalr	-1918(ra) # 80003b8a <idup>
    80002310:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002314:	4641                	li	a2,16
    80002316:	158a8593          	addi	a1,s5,344
    8000231a:	15898513          	addi	a0,s3,344
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	afe080e7          	jalr	-1282(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80002326:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    8000232a:	854e                	mv	a0,s3
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	95e080e7          	jalr	-1698(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80002334:	0000f497          	auipc	s1,0xf
    80002338:	64448493          	addi	s1,s1,1604 # 80011978 <wait_lock>
    8000233c:	8526                	mv	a0,s1
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	898080e7          	jalr	-1896(ra) # 80000bd6 <acquire>
  np->parent = p;
    80002346:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	93e080e7          	jalr	-1730(ra) # 80000c8a <release>
  acquire(&np->lock);
    80002354:	854e                	mv	a0,s3
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	880080e7          	jalr	-1920(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    8000235e:	478d                	li	a5,3
    80002360:	00f9ac23          	sw	a5,24(s3)
    if(isQueueSetup == 0){
    80002364:	00006797          	auipc	a5,0x6
    80002368:	5c87a783          	lw	a5,1480(a5) # 8000892c <isQueueSetup>
    8000236c:	c78d                	beqz	a5,80002396 <fork+0x150>
  enqueue(np);
    8000236e:	854e                	mv	a0,s3
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	554080e7          	jalr	1364(ra) # 800018c4 <enqueue>
  release(&np->lock);
    80002378:	854e                	mv	a0,s3
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	910080e7          	jalr	-1776(ra) # 80000c8a <release>
}
    80002382:	854a                	mv	a0,s2
    80002384:	70e2                	ld	ra,56(sp)
    80002386:	7442                	ld	s0,48(sp)
    80002388:	74a2                	ld	s1,40(sp)
    8000238a:	7902                	ld	s2,32(sp)
    8000238c:	69e2                	ld	s3,24(sp)
    8000238e:	6a42                	ld	s4,16(sp)
    80002390:	6aa2                	ld	s5,8(sp)
    80002392:	6121                	addi	sp,sp,64
    80002394:	8082                	ret
    setupQueue();
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	4a0080e7          	jalr	1184(ra) # 80001836 <setupQueue>
    isQueueSetup = 1;
    8000239e:	4785                	li	a5,1
    800023a0:	00006717          	auipc	a4,0x6
    800023a4:	58f72623          	sw	a5,1420(a4) # 8000892c <isQueueSetup>
    800023a8:	b7d9                	j	8000236e <fork+0x128>
    return -1;
    800023aa:	597d                	li	s2,-1
    800023ac:	bfd9                	j	80002382 <fork+0x13c>

00000000800023ae <scheduler>:
{
    800023ae:	7139                	addi	sp,sp,-64
    800023b0:	fc06                	sd	ra,56(sp)
    800023b2:	f822                	sd	s0,48(sp)
    800023b4:	f426                	sd	s1,40(sp)
    800023b6:	f04a                	sd	s2,32(sp)
    800023b8:	ec4e                	sd	s3,24(sp)
    800023ba:	e852                	sd	s4,16(sp)
    800023bc:	e456                	sd	s5,8(sp)
    800023be:	e05a                	sd	s6,0(sp)
    800023c0:	0080                	addi	s0,sp,64
    if(timeSincePriorityBoost > 60){
    800023c2:	00006a17          	auipc	s4,0x6
    800023c6:	566a0a13          	addi	s4,s4,1382 # 80008928 <timeSincePriorityBoost>
    800023ca:	03c00a93          	li	s5,60
      printf("Priority Boost!\n");
    800023ce:	00006b17          	auipc	s6,0x6
    800023d2:	e62b0b13          	addi	s6,s6,-414 # 80008230 <digits+0x1f0>
        if(p->state == RUNNABLE){
    800023d6:	498d                	li	s3,3
      for(p = proc; p < &proc[NPROC]; p++){
    800023d8:	00015917          	auipc	s2,0x15
    800023dc:	3b890913          	addi	s2,s2,952 # 80017790 <tickslock>
    800023e0:	a025                	j	80002408 <scheduler+0x5a>
    800023e2:	17848493          	addi	s1,s1,376
    800023e6:	01248b63          	beq	s1,s2,800023fc <scheduler+0x4e>
        if(p->state == RUNNABLE){
    800023ea:	4c9c                	lw	a5,24(s1)
    800023ec:	ff379be3          	bne	a5,s3,800023e2 <scheduler+0x34>
          enqueue(p);
    800023f0:	8526                	mv	a0,s1
    800023f2:	fffff097          	auipc	ra,0xfffff
    800023f6:	4d2080e7          	jalr	1234(ra) # 800018c4 <enqueue>
    800023fa:	b7e5                	j	800023e2 <scheduler+0x34>
      timeSincePriorityBoost = 0;
    800023fc:	000a2023          	sw	zero,0(s4)
    dequeue();
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	674080e7          	jalr	1652(ra) # 80001a74 <dequeue>
    if(timeSincePriorityBoost > 60){
    80002408:	000a2783          	lw	a5,0(s4)
    8000240c:	fefadae3          	bge	s5,a5,80002400 <scheduler+0x52>
      printf("Priority Boost!\n");
    80002410:	855a                	mv	a0,s6
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	176080e7          	jalr	374(ra) # 80000588 <printf>
      setupQueue();
    8000241a:	fffff097          	auipc	ra,0xfffff
    8000241e:	41c080e7          	jalr	1052(ra) # 80001836 <setupQueue>
      for(p = proc; p < &proc[NPROC]; p++){
    80002422:	0000f497          	auipc	s1,0xf
    80002426:	56e48493          	addi	s1,s1,1390 # 80011990 <proc>
    8000242a:	b7c1                	j	800023ea <scheduler+0x3c>

000000008000242c <sched>:
{
    8000242c:	7179                	addi	sp,sp,-48
    8000242e:	f406                	sd	ra,40(sp)
    80002430:	f022                	sd	s0,32(sp)
    80002432:	ec26                	sd	s1,24(sp)
    80002434:	e84a                	sd	s2,16(sp)
    80002436:	e44e                	sd	s3,8(sp)
    80002438:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000243a:	00000097          	auipc	ra,0x0
    8000243e:	93a080e7          	jalr	-1734(ra) # 80001d74 <myproc>
    80002442:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002444:	ffffe097          	auipc	ra,0xffffe
    80002448:	718080e7          	jalr	1816(ra) # 80000b5c <holding>
    8000244c:	c93d                	beqz	a0,800024c2 <sched+0x96>
    8000244e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002450:	2781                	sext.w	a5,a5
    80002452:	079e                	slli	a5,a5,0x7
    80002454:	0000e717          	auipc	a4,0xe
    80002458:	75c70713          	addi	a4,a4,1884 # 80010bb0 <qtable>
    8000245c:	97ba                	add	a5,a5,a4
    8000245e:	7087a703          	lw	a4,1800(a5)
    80002462:	4785                	li	a5,1
    80002464:	06f71763          	bne	a4,a5,800024d2 <sched+0xa6>
  if(p->state == RUNNING)
    80002468:	4c98                	lw	a4,24(s1)
    8000246a:	4791                	li	a5,4
    8000246c:	06f70b63          	beq	a4,a5,800024e2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002470:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002474:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002476:	efb5                	bnez	a5,800024f2 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002478:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000247a:	0000e917          	auipc	s2,0xe
    8000247e:	73690913          	addi	s2,s2,1846 # 80010bb0 <qtable>
    80002482:	2781                	sext.w	a5,a5
    80002484:	079e                	slli	a5,a5,0x7
    80002486:	97ca                	add	a5,a5,s2
    80002488:	70c7a983          	lw	s3,1804(a5)
    8000248c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000248e:	2781                	sext.w	a5,a5
    80002490:	079e                	slli	a5,a5,0x7
    80002492:	0000f597          	auipc	a1,0xf
    80002496:	db658593          	addi	a1,a1,-586 # 80011248 <cpus+0x8>
    8000249a:	95be                	add	a1,a1,a5
    8000249c:	06048513          	addi	a0,s1,96
    800024a0:	00000097          	auipc	ra,0x0
    800024a4:	696080e7          	jalr	1686(ra) # 80002b36 <swtch>
    800024a8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800024aa:	2781                	sext.w	a5,a5
    800024ac:	079e                	slli	a5,a5,0x7
    800024ae:	97ca                	add	a5,a5,s2
    800024b0:	7137a623          	sw	s3,1804(a5)
}
    800024b4:	70a2                	ld	ra,40(sp)
    800024b6:	7402                	ld	s0,32(sp)
    800024b8:	64e2                	ld	s1,24(sp)
    800024ba:	6942                	ld	s2,16(sp)
    800024bc:	69a2                	ld	s3,8(sp)
    800024be:	6145                	addi	sp,sp,48
    800024c0:	8082                	ret
    panic("sched p->lock");
    800024c2:	00006517          	auipc	a0,0x6
    800024c6:	d8650513          	addi	a0,a0,-634 # 80008248 <digits+0x208>
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	074080e7          	jalr	116(ra) # 8000053e <panic>
    panic("sched locks");
    800024d2:	00006517          	auipc	a0,0x6
    800024d6:	d8650513          	addi	a0,a0,-634 # 80008258 <digits+0x218>
    800024da:	ffffe097          	auipc	ra,0xffffe
    800024de:	064080e7          	jalr	100(ra) # 8000053e <panic>
    panic("sched running");
    800024e2:	00006517          	auipc	a0,0x6
    800024e6:	d8650513          	addi	a0,a0,-634 # 80008268 <digits+0x228>
    800024ea:	ffffe097          	auipc	ra,0xffffe
    800024ee:	054080e7          	jalr	84(ra) # 8000053e <panic>
    panic("sched interruptible");
    800024f2:	00006517          	auipc	a0,0x6
    800024f6:	d8650513          	addi	a0,a0,-634 # 80008278 <digits+0x238>
    800024fa:	ffffe097          	auipc	ra,0xffffe
    800024fe:	044080e7          	jalr	68(ra) # 8000053e <panic>

0000000080002502 <yield>:
{
    80002502:	1101                	addi	sp,sp,-32
    80002504:	ec06                	sd	ra,24(sp)
    80002506:	e822                	sd	s0,16(sp)
    80002508:	e426                	sd	s1,8(sp)
    8000250a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000250c:	00000097          	auipc	ra,0x0
    80002510:	868080e7          	jalr	-1944(ra) # 80001d74 <myproc>
    80002514:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	6c0080e7          	jalr	1728(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000251e:	478d                	li	a5,3
    80002520:	cc9c                	sw	a5,24(s1)
    if(isQueueSetup == 0){
    80002522:	00006797          	auipc	a5,0x6
    80002526:	40a7a783          	lw	a5,1034(a5) # 8000892c <isQueueSetup>
    8000252a:	c3a1                	beqz	a5,8000256a <yield+0x68>
  p->quanta++;
    8000252c:	16c4a783          	lw	a5,364(s1)
    80002530:	2785                	addiw	a5,a5,1
    80002532:	16f4a623          	sw	a5,364(s1)
  timeSincePriorityBoost++;
    80002536:	00006717          	auipc	a4,0x6
    8000253a:	3f270713          	addi	a4,a4,1010 # 80008928 <timeSincePriorityBoost>
    8000253e:	431c                	lw	a5,0(a4)
    80002540:	2785                	addiw	a5,a5,1
    80002542:	c31c                	sw	a5,0(a4)
  enqueue(p);
    80002544:	8526                	mv	a0,s1
    80002546:	fffff097          	auipc	ra,0xfffff
    8000254a:	37e080e7          	jalr	894(ra) # 800018c4 <enqueue>
  sched();
    8000254e:	00000097          	auipc	ra,0x0
    80002552:	ede080e7          	jalr	-290(ra) # 8000242c <sched>
  release(&p->lock);
    80002556:	8526                	mv	a0,s1
    80002558:	ffffe097          	auipc	ra,0xffffe
    8000255c:	732080e7          	jalr	1842(ra) # 80000c8a <release>
}
    80002560:	60e2                	ld	ra,24(sp)
    80002562:	6442                	ld	s0,16(sp)
    80002564:	64a2                	ld	s1,8(sp)
    80002566:	6105                	addi	sp,sp,32
    80002568:	8082                	ret
    setupQueue();
    8000256a:	fffff097          	auipc	ra,0xfffff
    8000256e:	2cc080e7          	jalr	716(ra) # 80001836 <setupQueue>
    isQueueSetup = 1;
    80002572:	4785                	li	a5,1
    80002574:	00006717          	auipc	a4,0x6
    80002578:	3af72c23          	sw	a5,952(a4) # 8000892c <isQueueSetup>
    8000257c:	bf45                	j	8000252c <yield+0x2a>

000000008000257e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000257e:	7179                	addi	sp,sp,-48
    80002580:	f406                	sd	ra,40(sp)
    80002582:	f022                	sd	s0,32(sp)
    80002584:	ec26                	sd	s1,24(sp)
    80002586:	e84a                	sd	s2,16(sp)
    80002588:	e44e                	sd	s3,8(sp)
    8000258a:	1800                	addi	s0,sp,48
    8000258c:	89aa                	mv	s3,a0
    8000258e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002590:	fffff097          	auipc	ra,0xfffff
    80002594:	7e4080e7          	jalr	2020(ra) # 80001d74 <myproc>
    80002598:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000259a:	ffffe097          	auipc	ra,0xffffe
    8000259e:	63c080e7          	jalr	1596(ra) # 80000bd6 <acquire>
  release(lk);
    800025a2:	854a                	mv	a0,s2
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	6e6080e7          	jalr	1766(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800025ac:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800025b0:	4789                	li	a5,2
    800025b2:	cc9c                	sw	a5,24(s1)

  sched();
    800025b4:	00000097          	auipc	ra,0x0
    800025b8:	e78080e7          	jalr	-392(ra) # 8000242c <sched>

  // Tidy up.
  p->chan = 0;
    800025bc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800025c0:	8526                	mv	a0,s1
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	6c8080e7          	jalr	1736(ra) # 80000c8a <release>
  acquire(lk);
    800025ca:	854a                	mv	a0,s2
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	60a080e7          	jalr	1546(ra) # 80000bd6 <acquire>
}
    800025d4:	70a2                	ld	ra,40(sp)
    800025d6:	7402                	ld	s0,32(sp)
    800025d8:	64e2                	ld	s1,24(sp)
    800025da:	6942                	ld	s2,16(sp)
    800025dc:	69a2                	ld	s3,8(sp)
    800025de:	6145                	addi	sp,sp,48
    800025e0:	8082                	ret

00000000800025e2 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800025e2:	715d                	addi	sp,sp,-80
    800025e4:	e486                	sd	ra,72(sp)
    800025e6:	e0a2                	sd	s0,64(sp)
    800025e8:	fc26                	sd	s1,56(sp)
    800025ea:	f84a                	sd	s2,48(sp)
    800025ec:	f44e                	sd	s3,40(sp)
    800025ee:	f052                	sd	s4,32(sp)
    800025f0:	ec56                	sd	s5,24(sp)
    800025f2:	e85a                	sd	s6,16(sp)
    800025f4:	e45e                	sd	s7,8(sp)
    800025f6:	0880                	addi	s0,sp,80
    800025f8:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800025fa:	0000f497          	auipc	s1,0xf
    800025fe:	39648493          	addi	s1,s1,918 # 80011990 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002602:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002604:	4b0d                	li	s6,3
        //uint64 pindex = p-proc;
          if(isQueueSetup == 0){
    80002606:	00006a97          	auipc	s5,0x6
    8000260a:	326a8a93          	addi	s5,s5,806 # 8000892c <isQueueSetup>
            setupQueue();
            isQueueSetup = 1;
    8000260e:	4b85                	li	s7,1
  for(p = proc; p < &proc[NPROC]; p++) {
    80002610:	00015917          	auipc	s2,0x15
    80002614:	18090913          	addi	s2,s2,384 # 80017790 <tickslock>
    80002618:	a839                	j	80002636 <wakeup+0x54>
          }
        //printf("4Enqueueing process name: %s, pindex: %d\n", p->name, pindex);
        enqueue(p);
    8000261a:	8526                	mv	a0,s1
    8000261c:	fffff097          	auipc	ra,0xfffff
    80002620:	2a8080e7          	jalr	680(ra) # 800018c4 <enqueue>
      }
      release(&p->lock);
    80002624:	8526                	mv	a0,s1
    80002626:	ffffe097          	auipc	ra,0xffffe
    8000262a:	664080e7          	jalr	1636(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000262e:	17848493          	addi	s1,s1,376
    80002632:	03248f63          	beq	s1,s2,80002670 <wakeup+0x8e>
    if(p != myproc()){
    80002636:	fffff097          	auipc	ra,0xfffff
    8000263a:	73e080e7          	jalr	1854(ra) # 80001d74 <myproc>
    8000263e:	fea488e3          	beq	s1,a0,8000262e <wakeup+0x4c>
      acquire(&p->lock);
    80002642:	8526                	mv	a0,s1
    80002644:	ffffe097          	auipc	ra,0xffffe
    80002648:	592080e7          	jalr	1426(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000264c:	4c9c                	lw	a5,24(s1)
    8000264e:	fd379be3          	bne	a5,s3,80002624 <wakeup+0x42>
    80002652:	709c                	ld	a5,32(s1)
    80002654:	fd4798e3          	bne	a5,s4,80002624 <wakeup+0x42>
        p->state = RUNNABLE;
    80002658:	0164ac23          	sw	s6,24(s1)
          if(isQueueSetup == 0){
    8000265c:	000aa783          	lw	a5,0(s5)
    80002660:	ffcd                	bnez	a5,8000261a <wakeup+0x38>
            setupQueue();
    80002662:	fffff097          	auipc	ra,0xfffff
    80002666:	1d4080e7          	jalr	468(ra) # 80001836 <setupQueue>
            isQueueSetup = 1;
    8000266a:	017aa023          	sw	s7,0(s5)
    8000266e:	b775                	j	8000261a <wakeup+0x38>
    }
  }
}
    80002670:	60a6                	ld	ra,72(sp)
    80002672:	6406                	ld	s0,64(sp)
    80002674:	74e2                	ld	s1,56(sp)
    80002676:	7942                	ld	s2,48(sp)
    80002678:	79a2                	ld	s3,40(sp)
    8000267a:	7a02                	ld	s4,32(sp)
    8000267c:	6ae2                	ld	s5,24(sp)
    8000267e:	6b42                	ld	s6,16(sp)
    80002680:	6ba2                	ld	s7,8(sp)
    80002682:	6161                	addi	sp,sp,80
    80002684:	8082                	ret

0000000080002686 <reparent>:
{
    80002686:	7179                	addi	sp,sp,-48
    80002688:	f406                	sd	ra,40(sp)
    8000268a:	f022                	sd	s0,32(sp)
    8000268c:	ec26                	sd	s1,24(sp)
    8000268e:	e84a                	sd	s2,16(sp)
    80002690:	e44e                	sd	s3,8(sp)
    80002692:	e052                	sd	s4,0(sp)
    80002694:	1800                	addi	s0,sp,48
    80002696:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002698:	0000f497          	auipc	s1,0xf
    8000269c:	2f848493          	addi	s1,s1,760 # 80011990 <proc>
      pp->parent = initproc;
    800026a0:	00006a17          	auipc	s4,0x6
    800026a4:	2a0a0a13          	addi	s4,s4,672 # 80008940 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800026a8:	00015997          	auipc	s3,0x15
    800026ac:	0e898993          	addi	s3,s3,232 # 80017790 <tickslock>
    800026b0:	a029                	j	800026ba <reparent+0x34>
    800026b2:	17848493          	addi	s1,s1,376
    800026b6:	01348d63          	beq	s1,s3,800026d0 <reparent+0x4a>
    if(pp->parent == p){
    800026ba:	7c9c                	ld	a5,56(s1)
    800026bc:	ff279be3          	bne	a5,s2,800026b2 <reparent+0x2c>
      pp->parent = initproc;
    800026c0:	000a3503          	ld	a0,0(s4)
    800026c4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800026c6:	00000097          	auipc	ra,0x0
    800026ca:	f1c080e7          	jalr	-228(ra) # 800025e2 <wakeup>
    800026ce:	b7d5                	j	800026b2 <reparent+0x2c>
}
    800026d0:	70a2                	ld	ra,40(sp)
    800026d2:	7402                	ld	s0,32(sp)
    800026d4:	64e2                	ld	s1,24(sp)
    800026d6:	6942                	ld	s2,16(sp)
    800026d8:	69a2                	ld	s3,8(sp)
    800026da:	6a02                	ld	s4,0(sp)
    800026dc:	6145                	addi	sp,sp,48
    800026de:	8082                	ret

00000000800026e0 <exit>:
{
    800026e0:	7179                	addi	sp,sp,-48
    800026e2:	f406                	sd	ra,40(sp)
    800026e4:	f022                	sd	s0,32(sp)
    800026e6:	ec26                	sd	s1,24(sp)
    800026e8:	e84a                	sd	s2,16(sp)
    800026ea:	e44e                	sd	s3,8(sp)
    800026ec:	e052                	sd	s4,0(sp)
    800026ee:	1800                	addi	s0,sp,48
    800026f0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800026f2:	fffff097          	auipc	ra,0xfffff
    800026f6:	682080e7          	jalr	1666(ra) # 80001d74 <myproc>
    800026fa:	89aa                	mv	s3,a0
  if(p == initproc)
    800026fc:	00006797          	auipc	a5,0x6
    80002700:	2447b783          	ld	a5,580(a5) # 80008940 <initproc>
    80002704:	0d050493          	addi	s1,a0,208
    80002708:	15050913          	addi	s2,a0,336
    8000270c:	02a79363          	bne	a5,a0,80002732 <exit+0x52>
    panic("init exiting");
    80002710:	00006517          	auipc	a0,0x6
    80002714:	b8050513          	addi	a0,a0,-1152 # 80008290 <digits+0x250>
    80002718:	ffffe097          	auipc	ra,0xffffe
    8000271c:	e26080e7          	jalr	-474(ra) # 8000053e <panic>
      fileclose(f);
    80002720:	00002097          	auipc	ra,0x2
    80002724:	336080e7          	jalr	822(ra) # 80004a56 <fileclose>
      p->ofile[fd] = 0;
    80002728:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000272c:	04a1                	addi	s1,s1,8
    8000272e:	01248563          	beq	s1,s2,80002738 <exit+0x58>
    if(p->ofile[fd]){
    80002732:	6088                	ld	a0,0(s1)
    80002734:	f575                	bnez	a0,80002720 <exit+0x40>
    80002736:	bfdd                	j	8000272c <exit+0x4c>
  begin_op();
    80002738:	00002097          	auipc	ra,0x2
    8000273c:	e52080e7          	jalr	-430(ra) # 8000458a <begin_op>
  iput(p->cwd);
    80002740:	1509b503          	ld	a0,336(s3)
    80002744:	00001097          	auipc	ra,0x1
    80002748:	63e080e7          	jalr	1598(ra) # 80003d82 <iput>
  end_op();
    8000274c:	00002097          	auipc	ra,0x2
    80002750:	ebe080e7          	jalr	-322(ra) # 8000460a <end_op>
  p->cwd = 0;
    80002754:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002758:	0000f497          	auipc	s1,0xf
    8000275c:	22048493          	addi	s1,s1,544 # 80011978 <wait_lock>
    80002760:	8526                	mv	a0,s1
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	474080e7          	jalr	1140(ra) # 80000bd6 <acquire>
  reparent(p);
    8000276a:	854e                	mv	a0,s3
    8000276c:	00000097          	auipc	ra,0x0
    80002770:	f1a080e7          	jalr	-230(ra) # 80002686 <reparent>
  wakeup(p->parent);
    80002774:	0389b503          	ld	a0,56(s3)
    80002778:	00000097          	auipc	ra,0x0
    8000277c:	e6a080e7          	jalr	-406(ra) # 800025e2 <wakeup>
  acquire(&p->lock);
    80002780:	854e                	mv	a0,s3
    80002782:	ffffe097          	auipc	ra,0xffffe
    80002786:	454080e7          	jalr	1108(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000278a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000278e:	4795                	li	a5,5
    80002790:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002794:	8526                	mv	a0,s1
    80002796:	ffffe097          	auipc	ra,0xffffe
    8000279a:	4f4080e7          	jalr	1268(ra) # 80000c8a <release>
  sched();
    8000279e:	00000097          	auipc	ra,0x0
    800027a2:	c8e080e7          	jalr	-882(ra) # 8000242c <sched>
  panic("zombie exit");
    800027a6:	00006517          	auipc	a0,0x6
    800027aa:	afa50513          	addi	a0,a0,-1286 # 800082a0 <digits+0x260>
    800027ae:	ffffe097          	auipc	ra,0xffffe
    800027b2:	d90080e7          	jalr	-624(ra) # 8000053e <panic>

00000000800027b6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800027b6:	7179                	addi	sp,sp,-48
    800027b8:	f406                	sd	ra,40(sp)
    800027ba:	f022                	sd	s0,32(sp)
    800027bc:	ec26                	sd	s1,24(sp)
    800027be:	e84a                	sd	s2,16(sp)
    800027c0:	e44e                	sd	s3,8(sp)
    800027c2:	1800                	addi	s0,sp,48
    800027c4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800027c6:	0000f497          	auipc	s1,0xf
    800027ca:	1ca48493          	addi	s1,s1,458 # 80011990 <proc>
    800027ce:	00015997          	auipc	s3,0x15
    800027d2:	fc298993          	addi	s3,s3,-62 # 80017790 <tickslock>
    acquire(&p->lock);
    800027d6:	8526                	mv	a0,s1
    800027d8:	ffffe097          	auipc	ra,0xffffe
    800027dc:	3fe080e7          	jalr	1022(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800027e0:	589c                	lw	a5,48(s1)
    800027e2:	01278d63          	beq	a5,s2,800027fc <kill+0x46>
        enqueue(p);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800027e6:	8526                	mv	a0,s1
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	4a2080e7          	jalr	1186(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800027f0:	17848493          	addi	s1,s1,376
    800027f4:	ff3491e3          	bne	s1,s3,800027d6 <kill+0x20>
  }
  return -1;
    800027f8:	557d                	li	a0,-1
    800027fa:	a829                	j	80002814 <kill+0x5e>
      p->killed = 1;
    800027fc:	4785                	li	a5,1
    800027fe:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002800:	4c98                	lw	a4,24(s1)
    80002802:	4789                	li	a5,2
    80002804:	00f70f63          	beq	a4,a5,80002822 <kill+0x6c>
      release(&p->lock);
    80002808:	8526                	mv	a0,s1
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	480080e7          	jalr	1152(ra) # 80000c8a <release>
      return 0;
    80002812:	4501                	li	a0,0
}
    80002814:	70a2                	ld	ra,40(sp)
    80002816:	7402                	ld	s0,32(sp)
    80002818:	64e2                	ld	s1,24(sp)
    8000281a:	6942                	ld	s2,16(sp)
    8000281c:	69a2                	ld	s3,8(sp)
    8000281e:	6145                	addi	sp,sp,48
    80002820:	8082                	ret
        p->state = RUNNABLE;
    80002822:	478d                	li	a5,3
    80002824:	cc9c                	sw	a5,24(s1)
          if(isQueueSetup == 0){
    80002826:	00006797          	auipc	a5,0x6
    8000282a:	1067a783          	lw	a5,262(a5) # 8000892c <isQueueSetup>
    8000282e:	c799                	beqz	a5,8000283c <kill+0x86>
        enqueue(p);
    80002830:	8526                	mv	a0,s1
    80002832:	fffff097          	auipc	ra,0xfffff
    80002836:	092080e7          	jalr	146(ra) # 800018c4 <enqueue>
    8000283a:	b7f9                	j	80002808 <kill+0x52>
            setupQueue();
    8000283c:	fffff097          	auipc	ra,0xfffff
    80002840:	ffa080e7          	jalr	-6(ra) # 80001836 <setupQueue>
            isQueueSetup = 1;
    80002844:	4785                	li	a5,1
    80002846:	00006717          	auipc	a4,0x6
    8000284a:	0ef72323          	sw	a5,230(a4) # 8000892c <isQueueSetup>
    8000284e:	b7cd                	j	80002830 <kill+0x7a>

0000000080002850 <setkilled>:

void
setkilled(struct proc *p)
{
    80002850:	1101                	addi	sp,sp,-32
    80002852:	ec06                	sd	ra,24(sp)
    80002854:	e822                	sd	s0,16(sp)
    80002856:	e426                	sd	s1,8(sp)
    80002858:	1000                	addi	s0,sp,32
    8000285a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	37a080e7          	jalr	890(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002864:	4785                	li	a5,1
    80002866:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002868:	8526                	mv	a0,s1
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	420080e7          	jalr	1056(ra) # 80000c8a <release>
}
    80002872:	60e2                	ld	ra,24(sp)
    80002874:	6442                	ld	s0,16(sp)
    80002876:	64a2                	ld	s1,8(sp)
    80002878:	6105                	addi	sp,sp,32
    8000287a:	8082                	ret

000000008000287c <killed>:

int
killed(struct proc *p)
{
    8000287c:	1101                	addi	sp,sp,-32
    8000287e:	ec06                	sd	ra,24(sp)
    80002880:	e822                	sd	s0,16(sp)
    80002882:	e426                	sd	s1,8(sp)
    80002884:	e04a                	sd	s2,0(sp)
    80002886:	1000                	addi	s0,sp,32
    80002888:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	34c080e7          	jalr	844(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002892:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002896:	8526                	mv	a0,s1
    80002898:	ffffe097          	auipc	ra,0xffffe
    8000289c:	3f2080e7          	jalr	1010(ra) # 80000c8a <release>
  return k;
}
    800028a0:	854a                	mv	a0,s2
    800028a2:	60e2                	ld	ra,24(sp)
    800028a4:	6442                	ld	s0,16(sp)
    800028a6:	64a2                	ld	s1,8(sp)
    800028a8:	6902                	ld	s2,0(sp)
    800028aa:	6105                	addi	sp,sp,32
    800028ac:	8082                	ret

00000000800028ae <wait>:
{
    800028ae:	715d                	addi	sp,sp,-80
    800028b0:	e486                	sd	ra,72(sp)
    800028b2:	e0a2                	sd	s0,64(sp)
    800028b4:	fc26                	sd	s1,56(sp)
    800028b6:	f84a                	sd	s2,48(sp)
    800028b8:	f44e                	sd	s3,40(sp)
    800028ba:	f052                	sd	s4,32(sp)
    800028bc:	ec56                	sd	s5,24(sp)
    800028be:	e85a                	sd	s6,16(sp)
    800028c0:	e45e                	sd	s7,8(sp)
    800028c2:	e062                	sd	s8,0(sp)
    800028c4:	0880                	addi	s0,sp,80
    800028c6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800028c8:	fffff097          	auipc	ra,0xfffff
    800028cc:	4ac080e7          	jalr	1196(ra) # 80001d74 <myproc>
    800028d0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800028d2:	0000f517          	auipc	a0,0xf
    800028d6:	0a650513          	addi	a0,a0,166 # 80011978 <wait_lock>
    800028da:	ffffe097          	auipc	ra,0xffffe
    800028de:	2fc080e7          	jalr	764(ra) # 80000bd6 <acquire>
    havekids = 0;
    800028e2:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800028e4:	4a15                	li	s4,5
        havekids = 1;
    800028e6:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800028e8:	00015997          	auipc	s3,0x15
    800028ec:	ea898993          	addi	s3,s3,-344 # 80017790 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800028f0:	0000fc17          	auipc	s8,0xf
    800028f4:	088c0c13          	addi	s8,s8,136 # 80011978 <wait_lock>
    havekids = 0;
    800028f8:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800028fa:	0000f497          	auipc	s1,0xf
    800028fe:	09648493          	addi	s1,s1,150 # 80011990 <proc>
    80002902:	a0bd                	j	80002970 <wait+0xc2>
          pid = pp->pid;
    80002904:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002908:	000b0e63          	beqz	s6,80002924 <wait+0x76>
    8000290c:	4691                	li	a3,4
    8000290e:	02c48613          	addi	a2,s1,44
    80002912:	85da                	mv	a1,s6
    80002914:	05093503          	ld	a0,80(s2)
    80002918:	fffff097          	auipc	ra,0xfffff
    8000291c:	d50080e7          	jalr	-688(ra) # 80001668 <copyout>
    80002920:	02054563          	bltz	a0,8000294a <wait+0x9c>
          freeproc(pp);
    80002924:	8526                	mv	a0,s1
    80002926:	fffff097          	auipc	ra,0xfffff
    8000292a:	6f0080e7          	jalr	1776(ra) # 80002016 <freeproc>
          release(&pp->lock);
    8000292e:	8526                	mv	a0,s1
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	35a080e7          	jalr	858(ra) # 80000c8a <release>
          release(&wait_lock);
    80002938:	0000f517          	auipc	a0,0xf
    8000293c:	04050513          	addi	a0,a0,64 # 80011978 <wait_lock>
    80002940:	ffffe097          	auipc	ra,0xffffe
    80002944:	34a080e7          	jalr	842(ra) # 80000c8a <release>
          return pid;
    80002948:	a0b5                	j	800029b4 <wait+0x106>
            release(&pp->lock);
    8000294a:	8526                	mv	a0,s1
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	33e080e7          	jalr	830(ra) # 80000c8a <release>
            release(&wait_lock);
    80002954:	0000f517          	auipc	a0,0xf
    80002958:	02450513          	addi	a0,a0,36 # 80011978 <wait_lock>
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	32e080e7          	jalr	814(ra) # 80000c8a <release>
            return -1;
    80002964:	59fd                	li	s3,-1
    80002966:	a0b9                	j	800029b4 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002968:	17848493          	addi	s1,s1,376
    8000296c:	03348463          	beq	s1,s3,80002994 <wait+0xe6>
      if(pp->parent == p){
    80002970:	7c9c                	ld	a5,56(s1)
    80002972:	ff279be3          	bne	a5,s2,80002968 <wait+0xba>
        acquire(&pp->lock);
    80002976:	8526                	mv	a0,s1
    80002978:	ffffe097          	auipc	ra,0xffffe
    8000297c:	25e080e7          	jalr	606(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002980:	4c9c                	lw	a5,24(s1)
    80002982:	f94781e3          	beq	a5,s4,80002904 <wait+0x56>
        release(&pp->lock);
    80002986:	8526                	mv	a0,s1
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	302080e7          	jalr	770(ra) # 80000c8a <release>
        havekids = 1;
    80002990:	8756                	mv	a4,s5
    80002992:	bfd9                	j	80002968 <wait+0xba>
    if(!havekids || killed(p)){
    80002994:	c719                	beqz	a4,800029a2 <wait+0xf4>
    80002996:	854a                	mv	a0,s2
    80002998:	00000097          	auipc	ra,0x0
    8000299c:	ee4080e7          	jalr	-284(ra) # 8000287c <killed>
    800029a0:	c51d                	beqz	a0,800029ce <wait+0x120>
      release(&wait_lock);
    800029a2:	0000f517          	auipc	a0,0xf
    800029a6:	fd650513          	addi	a0,a0,-42 # 80011978 <wait_lock>
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	2e0080e7          	jalr	736(ra) # 80000c8a <release>
      return -1;
    800029b2:	59fd                	li	s3,-1
}
    800029b4:	854e                	mv	a0,s3
    800029b6:	60a6                	ld	ra,72(sp)
    800029b8:	6406                	ld	s0,64(sp)
    800029ba:	74e2                	ld	s1,56(sp)
    800029bc:	7942                	ld	s2,48(sp)
    800029be:	79a2                	ld	s3,40(sp)
    800029c0:	7a02                	ld	s4,32(sp)
    800029c2:	6ae2                	ld	s5,24(sp)
    800029c4:	6b42                	ld	s6,16(sp)
    800029c6:	6ba2                	ld	s7,8(sp)
    800029c8:	6c02                	ld	s8,0(sp)
    800029ca:	6161                	addi	sp,sp,80
    800029cc:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800029ce:	85e2                	mv	a1,s8
    800029d0:	854a                	mv	a0,s2
    800029d2:	00000097          	auipc	ra,0x0
    800029d6:	bac080e7          	jalr	-1108(ra) # 8000257e <sleep>
    havekids = 0;
    800029da:	bf39                	j	800028f8 <wait+0x4a>

00000000800029dc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800029dc:	7179                	addi	sp,sp,-48
    800029de:	f406                	sd	ra,40(sp)
    800029e0:	f022                	sd	s0,32(sp)
    800029e2:	ec26                	sd	s1,24(sp)
    800029e4:	e84a                	sd	s2,16(sp)
    800029e6:	e44e                	sd	s3,8(sp)
    800029e8:	e052                	sd	s4,0(sp)
    800029ea:	1800                	addi	s0,sp,48
    800029ec:	84aa                	mv	s1,a0
    800029ee:	892e                	mv	s2,a1
    800029f0:	89b2                	mv	s3,a2
    800029f2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029f4:	fffff097          	auipc	ra,0xfffff
    800029f8:	380080e7          	jalr	896(ra) # 80001d74 <myproc>
  if(user_dst){
    800029fc:	c08d                	beqz	s1,80002a1e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800029fe:	86d2                	mv	a3,s4
    80002a00:	864e                	mv	a2,s3
    80002a02:	85ca                	mv	a1,s2
    80002a04:	6928                	ld	a0,80(a0)
    80002a06:	fffff097          	auipc	ra,0xfffff
    80002a0a:	c62080e7          	jalr	-926(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002a0e:	70a2                	ld	ra,40(sp)
    80002a10:	7402                	ld	s0,32(sp)
    80002a12:	64e2                	ld	s1,24(sp)
    80002a14:	6942                	ld	s2,16(sp)
    80002a16:	69a2                	ld	s3,8(sp)
    80002a18:	6a02                	ld	s4,0(sp)
    80002a1a:	6145                	addi	sp,sp,48
    80002a1c:	8082                	ret
    memmove((char *)dst, src, len);
    80002a1e:	000a061b          	sext.w	a2,s4
    80002a22:	85ce                	mv	a1,s3
    80002a24:	854a                	mv	a0,s2
    80002a26:	ffffe097          	auipc	ra,0xffffe
    80002a2a:	308080e7          	jalr	776(ra) # 80000d2e <memmove>
    return 0;
    80002a2e:	8526                	mv	a0,s1
    80002a30:	bff9                	j	80002a0e <either_copyout+0x32>

0000000080002a32 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a32:	7179                	addi	sp,sp,-48
    80002a34:	f406                	sd	ra,40(sp)
    80002a36:	f022                	sd	s0,32(sp)
    80002a38:	ec26                	sd	s1,24(sp)
    80002a3a:	e84a                	sd	s2,16(sp)
    80002a3c:	e44e                	sd	s3,8(sp)
    80002a3e:	e052                	sd	s4,0(sp)
    80002a40:	1800                	addi	s0,sp,48
    80002a42:	892a                	mv	s2,a0
    80002a44:	84ae                	mv	s1,a1
    80002a46:	89b2                	mv	s3,a2
    80002a48:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a4a:	fffff097          	auipc	ra,0xfffff
    80002a4e:	32a080e7          	jalr	810(ra) # 80001d74 <myproc>
  if(user_src){
    80002a52:	c08d                	beqz	s1,80002a74 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002a54:	86d2                	mv	a3,s4
    80002a56:	864e                	mv	a2,s3
    80002a58:	85ca                	mv	a1,s2
    80002a5a:	6928                	ld	a0,80(a0)
    80002a5c:	fffff097          	auipc	ra,0xfffff
    80002a60:	c98080e7          	jalr	-872(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002a64:	70a2                	ld	ra,40(sp)
    80002a66:	7402                	ld	s0,32(sp)
    80002a68:	64e2                	ld	s1,24(sp)
    80002a6a:	6942                	ld	s2,16(sp)
    80002a6c:	69a2                	ld	s3,8(sp)
    80002a6e:	6a02                	ld	s4,0(sp)
    80002a70:	6145                	addi	sp,sp,48
    80002a72:	8082                	ret
    memmove(dst, (char*)src, len);
    80002a74:	000a061b          	sext.w	a2,s4
    80002a78:	85ce                	mv	a1,s3
    80002a7a:	854a                	mv	a0,s2
    80002a7c:	ffffe097          	auipc	ra,0xffffe
    80002a80:	2b2080e7          	jalr	690(ra) # 80000d2e <memmove>
    return 0;
    80002a84:	8526                	mv	a0,s1
    80002a86:	bff9                	j	80002a64 <either_copyin+0x32>

0000000080002a88 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002a88:	715d                	addi	sp,sp,-80
    80002a8a:	e486                	sd	ra,72(sp)
    80002a8c:	e0a2                	sd	s0,64(sp)
    80002a8e:	fc26                	sd	s1,56(sp)
    80002a90:	f84a                	sd	s2,48(sp)
    80002a92:	f44e                	sd	s3,40(sp)
    80002a94:	f052                	sd	s4,32(sp)
    80002a96:	ec56                	sd	s5,24(sp)
    80002a98:	e85a                	sd	s6,16(sp)
    80002a9a:	e45e                	sd	s7,8(sp)
    80002a9c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002a9e:	00005517          	auipc	a0,0x5
    80002aa2:	62a50513          	addi	a0,a0,1578 # 800080c8 <digits+0x88>
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	ae2080e7          	jalr	-1310(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002aae:	0000f497          	auipc	s1,0xf
    80002ab2:	03a48493          	addi	s1,s1,58 # 80011ae8 <proc+0x158>
    80002ab6:	00015917          	auipc	s2,0x15
    80002aba:	e3290913          	addi	s2,s2,-462 # 800178e8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002abe:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002ac0:	00005997          	auipc	s3,0x5
    80002ac4:	7f098993          	addi	s3,s3,2032 # 800082b0 <digits+0x270>
    printf("%d %s %s", p->pid, state, p->name);
    80002ac8:	00005a97          	auipc	s5,0x5
    80002acc:	7f0a8a93          	addi	s5,s5,2032 # 800082b8 <digits+0x278>
    printf("\n");
    80002ad0:	00005a17          	auipc	s4,0x5
    80002ad4:	5f8a0a13          	addi	s4,s4,1528 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ad8:	00006b97          	auipc	s7,0x6
    80002adc:	820b8b93          	addi	s7,s7,-2016 # 800082f8 <states.0>
    80002ae0:	a00d                	j	80002b02 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002ae2:	ed86a583          	lw	a1,-296(a3)
    80002ae6:	8556                	mv	a0,s5
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	aa0080e7          	jalr	-1376(ra) # 80000588 <printf>
    printf("\n");
    80002af0:	8552                	mv	a0,s4
    80002af2:	ffffe097          	auipc	ra,0xffffe
    80002af6:	a96080e7          	jalr	-1386(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002afa:	17848493          	addi	s1,s1,376
    80002afe:	03248163          	beq	s1,s2,80002b20 <procdump+0x98>
    if(p->state == UNUSED)
    80002b02:	86a6                	mv	a3,s1
    80002b04:	ec04a783          	lw	a5,-320(s1)
    80002b08:	dbed                	beqz	a5,80002afa <procdump+0x72>
      state = "???";
    80002b0a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b0c:	fcfb6be3          	bltu	s6,a5,80002ae2 <procdump+0x5a>
    80002b10:	1782                	slli	a5,a5,0x20
    80002b12:	9381                	srli	a5,a5,0x20
    80002b14:	078e                	slli	a5,a5,0x3
    80002b16:	97de                	add	a5,a5,s7
    80002b18:	6390                	ld	a2,0(a5)
    80002b1a:	f661                	bnez	a2,80002ae2 <procdump+0x5a>
      state = "???";
    80002b1c:	864e                	mv	a2,s3
    80002b1e:	b7d1                	j	80002ae2 <procdump+0x5a>
  }
}
    80002b20:	60a6                	ld	ra,72(sp)
    80002b22:	6406                	ld	s0,64(sp)
    80002b24:	74e2                	ld	s1,56(sp)
    80002b26:	7942                	ld	s2,48(sp)
    80002b28:	79a2                	ld	s3,40(sp)
    80002b2a:	7a02                	ld	s4,32(sp)
    80002b2c:	6ae2                	ld	s5,24(sp)
    80002b2e:	6b42                	ld	s6,16(sp)
    80002b30:	6ba2                	ld	s7,8(sp)
    80002b32:	6161                	addi	sp,sp,80
    80002b34:	8082                	ret

0000000080002b36 <swtch>:
    80002b36:	00153023          	sd	ra,0(a0)
    80002b3a:	00253423          	sd	sp,8(a0)
    80002b3e:	e900                	sd	s0,16(a0)
    80002b40:	ed04                	sd	s1,24(a0)
    80002b42:	03253023          	sd	s2,32(a0)
    80002b46:	03353423          	sd	s3,40(a0)
    80002b4a:	03453823          	sd	s4,48(a0)
    80002b4e:	03553c23          	sd	s5,56(a0)
    80002b52:	05653023          	sd	s6,64(a0)
    80002b56:	05753423          	sd	s7,72(a0)
    80002b5a:	05853823          	sd	s8,80(a0)
    80002b5e:	05953c23          	sd	s9,88(a0)
    80002b62:	07a53023          	sd	s10,96(a0)
    80002b66:	07b53423          	sd	s11,104(a0)
    80002b6a:	0005b083          	ld	ra,0(a1)
    80002b6e:	0085b103          	ld	sp,8(a1)
    80002b72:	6980                	ld	s0,16(a1)
    80002b74:	6d84                	ld	s1,24(a1)
    80002b76:	0205b903          	ld	s2,32(a1)
    80002b7a:	0285b983          	ld	s3,40(a1)
    80002b7e:	0305ba03          	ld	s4,48(a1)
    80002b82:	0385ba83          	ld	s5,56(a1)
    80002b86:	0405bb03          	ld	s6,64(a1)
    80002b8a:	0485bb83          	ld	s7,72(a1)
    80002b8e:	0505bc03          	ld	s8,80(a1)
    80002b92:	0585bc83          	ld	s9,88(a1)
    80002b96:	0605bd03          	ld	s10,96(a1)
    80002b9a:	0685bd83          	ld	s11,104(a1)
    80002b9e:	8082                	ret

0000000080002ba0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002ba0:	1141                	addi	sp,sp,-16
    80002ba2:	e406                	sd	ra,8(sp)
    80002ba4:	e022                	sd	s0,0(sp)
    80002ba6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ba8:	00005597          	auipc	a1,0x5
    80002bac:	78058593          	addi	a1,a1,1920 # 80008328 <states.0+0x30>
    80002bb0:	00015517          	auipc	a0,0x15
    80002bb4:	be050513          	addi	a0,a0,-1056 # 80017790 <tickslock>
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	f8e080e7          	jalr	-114(ra) # 80000b46 <initlock>
}
    80002bc0:	60a2                	ld	ra,8(sp)
    80002bc2:	6402                	ld	s0,0(sp)
    80002bc4:	0141                	addi	sp,sp,16
    80002bc6:	8082                	ret

0000000080002bc8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002bc8:	1141                	addi	sp,sp,-16
    80002bca:	e422                	sd	s0,8(sp)
    80002bcc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bce:	00003797          	auipc	a5,0x3
    80002bd2:	4d278793          	addi	a5,a5,1234 # 800060a0 <kernelvec>
    80002bd6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002bda:	6422                	ld	s0,8(sp)
    80002bdc:	0141                	addi	sp,sp,16
    80002bde:	8082                	ret

0000000080002be0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002be0:	1141                	addi	sp,sp,-16
    80002be2:	e406                	sd	ra,8(sp)
    80002be4:	e022                	sd	s0,0(sp)
    80002be6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002be8:	fffff097          	auipc	ra,0xfffff
    80002bec:	18c080e7          	jalr	396(ra) # 80001d74 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002bf4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bf6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002bfa:	00004617          	auipc	a2,0x4
    80002bfe:	40660613          	addi	a2,a2,1030 # 80007000 <_trampoline>
    80002c02:	00004697          	auipc	a3,0x4
    80002c06:	3fe68693          	addi	a3,a3,1022 # 80007000 <_trampoline>
    80002c0a:	8e91                	sub	a3,a3,a2
    80002c0c:	040007b7          	lui	a5,0x4000
    80002c10:	17fd                	addi	a5,a5,-1
    80002c12:	07b2                	slli	a5,a5,0xc
    80002c14:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c16:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c1a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002c1c:	180026f3          	csrr	a3,satp
    80002c20:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002c22:	6d38                	ld	a4,88(a0)
    80002c24:	6134                	ld	a3,64(a0)
    80002c26:	6585                	lui	a1,0x1
    80002c28:	96ae                	add	a3,a3,a1
    80002c2a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002c2c:	6d38                	ld	a4,88(a0)
    80002c2e:	00000697          	auipc	a3,0x0
    80002c32:	13068693          	addi	a3,a3,304 # 80002d5e <usertrap>
    80002c36:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c38:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002c3a:	8692                	mv	a3,tp
    80002c3c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c3e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c42:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c46:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c4a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c4e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c50:	6f18                	ld	a4,24(a4)
    80002c52:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c56:	6928                	ld	a0,80(a0)
    80002c58:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002c5a:	00004717          	auipc	a4,0x4
    80002c5e:	44270713          	addi	a4,a4,1090 # 8000709c <userret>
    80002c62:	8f11                	sub	a4,a4,a2
    80002c64:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002c66:	577d                	li	a4,-1
    80002c68:	177e                	slli	a4,a4,0x3f
    80002c6a:	8d59                	or	a0,a0,a4
    80002c6c:	9782                	jalr	a5
}
    80002c6e:	60a2                	ld	ra,8(sp)
    80002c70:	6402                	ld	s0,0(sp)
    80002c72:	0141                	addi	sp,sp,16
    80002c74:	8082                	ret

0000000080002c76 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c76:	1101                	addi	sp,sp,-32
    80002c78:	ec06                	sd	ra,24(sp)
    80002c7a:	e822                	sd	s0,16(sp)
    80002c7c:	e426                	sd	s1,8(sp)
    80002c7e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c80:	00015497          	auipc	s1,0x15
    80002c84:	b1048493          	addi	s1,s1,-1264 # 80017790 <tickslock>
    80002c88:	8526                	mv	a0,s1
    80002c8a:	ffffe097          	auipc	ra,0xffffe
    80002c8e:	f4c080e7          	jalr	-180(ra) # 80000bd6 <acquire>
  ticks++;
    80002c92:	00006517          	auipc	a0,0x6
    80002c96:	cb650513          	addi	a0,a0,-842 # 80008948 <ticks>
    80002c9a:	411c                	lw	a5,0(a0)
    80002c9c:	2785                	addiw	a5,a5,1
    80002c9e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002ca0:	00000097          	auipc	ra,0x0
    80002ca4:	942080e7          	jalr	-1726(ra) # 800025e2 <wakeup>
  release(&tickslock);
    80002ca8:	8526                	mv	a0,s1
    80002caa:	ffffe097          	auipc	ra,0xffffe
    80002cae:	fe0080e7          	jalr	-32(ra) # 80000c8a <release>
}
    80002cb2:	60e2                	ld	ra,24(sp)
    80002cb4:	6442                	ld	s0,16(sp)
    80002cb6:	64a2                	ld	s1,8(sp)
    80002cb8:	6105                	addi	sp,sp,32
    80002cba:	8082                	ret

0000000080002cbc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002cbc:	1101                	addi	sp,sp,-32
    80002cbe:	ec06                	sd	ra,24(sp)
    80002cc0:	e822                	sd	s0,16(sp)
    80002cc2:	e426                	sd	s1,8(sp)
    80002cc4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cc6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002cca:	00074d63          	bltz	a4,80002ce4 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002cce:	57fd                	li	a5,-1
    80002cd0:	17fe                	slli	a5,a5,0x3f
    80002cd2:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002cd4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002cd6:	06f70363          	beq	a4,a5,80002d3c <devintr+0x80>
  }
}
    80002cda:	60e2                	ld	ra,24(sp)
    80002cdc:	6442                	ld	s0,16(sp)
    80002cde:	64a2                	ld	s1,8(sp)
    80002ce0:	6105                	addi	sp,sp,32
    80002ce2:	8082                	ret
     (scause & 0xff) == 9){
    80002ce4:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002ce8:	46a5                	li	a3,9
    80002cea:	fed792e3          	bne	a5,a3,80002cce <devintr+0x12>
    int irq = plic_claim();
    80002cee:	00003097          	auipc	ra,0x3
    80002cf2:	4ba080e7          	jalr	1210(ra) # 800061a8 <plic_claim>
    80002cf6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002cf8:	47a9                	li	a5,10
    80002cfa:	02f50763          	beq	a0,a5,80002d28 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002cfe:	4785                	li	a5,1
    80002d00:	02f50963          	beq	a0,a5,80002d32 <devintr+0x76>
    return 1;
    80002d04:	4505                	li	a0,1
    } else if(irq){
    80002d06:	d8f1                	beqz	s1,80002cda <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002d08:	85a6                	mv	a1,s1
    80002d0a:	00005517          	auipc	a0,0x5
    80002d0e:	62650513          	addi	a0,a0,1574 # 80008330 <states.0+0x38>
    80002d12:	ffffe097          	auipc	ra,0xffffe
    80002d16:	876080e7          	jalr	-1930(ra) # 80000588 <printf>
      plic_complete(irq);
    80002d1a:	8526                	mv	a0,s1
    80002d1c:	00003097          	auipc	ra,0x3
    80002d20:	4b0080e7          	jalr	1200(ra) # 800061cc <plic_complete>
    return 1;
    80002d24:	4505                	li	a0,1
    80002d26:	bf55                	j	80002cda <devintr+0x1e>
      uartintr();
    80002d28:	ffffe097          	auipc	ra,0xffffe
    80002d2c:	c72080e7          	jalr	-910(ra) # 8000099a <uartintr>
    80002d30:	b7ed                	j	80002d1a <devintr+0x5e>
      virtio_disk_intr();
    80002d32:	00004097          	auipc	ra,0x4
    80002d36:	966080e7          	jalr	-1690(ra) # 80006698 <virtio_disk_intr>
    80002d3a:	b7c5                	j	80002d1a <devintr+0x5e>
    if(cpuid() == 0){
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	00c080e7          	jalr	12(ra) # 80001d48 <cpuid>
    80002d44:	c901                	beqz	a0,80002d54 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002d46:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d4a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002d4c:	14479073          	csrw	sip,a5
    return 2;
    80002d50:	4509                	li	a0,2
    80002d52:	b761                	j	80002cda <devintr+0x1e>
      clockintr();
    80002d54:	00000097          	auipc	ra,0x0
    80002d58:	f22080e7          	jalr	-222(ra) # 80002c76 <clockintr>
    80002d5c:	b7ed                	j	80002d46 <devintr+0x8a>

0000000080002d5e <usertrap>:
{
    80002d5e:	1101                	addi	sp,sp,-32
    80002d60:	ec06                	sd	ra,24(sp)
    80002d62:	e822                	sd	s0,16(sp)
    80002d64:	e426                	sd	s1,8(sp)
    80002d66:	e04a                	sd	s2,0(sp)
    80002d68:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d6a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d6e:	1007f793          	andi	a5,a5,256
    80002d72:	e3b1                	bnez	a5,80002db6 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d74:	00003797          	auipc	a5,0x3
    80002d78:	32c78793          	addi	a5,a5,812 # 800060a0 <kernelvec>
    80002d7c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d80:	fffff097          	auipc	ra,0xfffff
    80002d84:	ff4080e7          	jalr	-12(ra) # 80001d74 <myproc>
    80002d88:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d8a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d8c:	14102773          	csrr	a4,sepc
    80002d90:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d92:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d96:	47a1                	li	a5,8
    80002d98:	02f70763          	beq	a4,a5,80002dc6 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002d9c:	00000097          	auipc	ra,0x0
    80002da0:	f20080e7          	jalr	-224(ra) # 80002cbc <devintr>
    80002da4:	892a                	mv	s2,a0
    80002da6:	c151                	beqz	a0,80002e2a <usertrap+0xcc>
  if(killed(p))
    80002da8:	8526                	mv	a0,s1
    80002daa:	00000097          	auipc	ra,0x0
    80002dae:	ad2080e7          	jalr	-1326(ra) # 8000287c <killed>
    80002db2:	c929                	beqz	a0,80002e04 <usertrap+0xa6>
    80002db4:	a099                	j	80002dfa <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002db6:	00005517          	auipc	a0,0x5
    80002dba:	59a50513          	addi	a0,a0,1434 # 80008350 <states.0+0x58>
    80002dbe:	ffffd097          	auipc	ra,0xffffd
    80002dc2:	780080e7          	jalr	1920(ra) # 8000053e <panic>
    if(killed(p))
    80002dc6:	00000097          	auipc	ra,0x0
    80002dca:	ab6080e7          	jalr	-1354(ra) # 8000287c <killed>
    80002dce:	e921                	bnez	a0,80002e1e <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002dd0:	6cb8                	ld	a4,88(s1)
    80002dd2:	6f1c                	ld	a5,24(a4)
    80002dd4:	0791                	addi	a5,a5,4
    80002dd6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ddc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002de0:	10079073          	csrw	sstatus,a5
    syscall();
    80002de4:	00000097          	auipc	ra,0x0
    80002de8:	2f0080e7          	jalr	752(ra) # 800030d4 <syscall>
  if(killed(p))
    80002dec:	8526                	mv	a0,s1
    80002dee:	00000097          	auipc	ra,0x0
    80002df2:	a8e080e7          	jalr	-1394(ra) # 8000287c <killed>
    80002df6:	c911                	beqz	a0,80002e0a <usertrap+0xac>
    80002df8:	4901                	li	s2,0
    exit(-1);
    80002dfa:	557d                	li	a0,-1
    80002dfc:	00000097          	auipc	ra,0x0
    80002e00:	8e4080e7          	jalr	-1820(ra) # 800026e0 <exit>
  if(which_dev == 2) {
    80002e04:	4789                	li	a5,2
    80002e06:	04f90f63          	beq	s2,a5,80002e64 <usertrap+0x106>
  usertrapret();
    80002e0a:	00000097          	auipc	ra,0x0
    80002e0e:	dd6080e7          	jalr	-554(ra) # 80002be0 <usertrapret>
}
    80002e12:	60e2                	ld	ra,24(sp)
    80002e14:	6442                	ld	s0,16(sp)
    80002e16:	64a2                	ld	s1,8(sp)
    80002e18:	6902                	ld	s2,0(sp)
    80002e1a:	6105                	addi	sp,sp,32
    80002e1c:	8082                	ret
      exit(-1);
    80002e1e:	557d                	li	a0,-1
    80002e20:	00000097          	auipc	ra,0x0
    80002e24:	8c0080e7          	jalr	-1856(ra) # 800026e0 <exit>
    80002e28:	b765                	j	80002dd0 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e2a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002e2e:	5890                	lw	a2,48(s1)
    80002e30:	00005517          	auipc	a0,0x5
    80002e34:	54050513          	addi	a0,a0,1344 # 80008370 <states.0+0x78>
    80002e38:	ffffd097          	auipc	ra,0xffffd
    80002e3c:	750080e7          	jalr	1872(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e40:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e44:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e48:	00005517          	auipc	a0,0x5
    80002e4c:	55850513          	addi	a0,a0,1368 # 800083a0 <states.0+0xa8>
    80002e50:	ffffd097          	auipc	ra,0xffffd
    80002e54:	738080e7          	jalr	1848(ra) # 80000588 <printf>
    setkilled(p);
    80002e58:	8526                	mv	a0,s1
    80002e5a:	00000097          	auipc	ra,0x0
    80002e5e:	9f6080e7          	jalr	-1546(ra) # 80002850 <setkilled>
    80002e62:	b769                	j	80002dec <usertrap+0x8e>
    time++;
    80002e64:	00006717          	auipc	a4,0x6
    80002e68:	ad470713          	addi	a4,a4,-1324 # 80008938 <time>
    80002e6c:	431c                	lw	a5,0(a4)
    80002e6e:	2785                	addiw	a5,a5,1
    80002e70:	c31c                	sw	a5,0(a4)
    yield();
    80002e72:	fffff097          	auipc	ra,0xfffff
    80002e76:	690080e7          	jalr	1680(ra) # 80002502 <yield>
    80002e7a:	bf41                	j	80002e0a <usertrap+0xac>

0000000080002e7c <kerneltrap>:
{
    80002e7c:	7179                	addi	sp,sp,-48
    80002e7e:	f406                	sd	ra,40(sp)
    80002e80:	f022                	sd	s0,32(sp)
    80002e82:	ec26                	sd	s1,24(sp)
    80002e84:	e84a                	sd	s2,16(sp)
    80002e86:	e44e                	sd	s3,8(sp)
    80002e88:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e8a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e8e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e92:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002e96:	1004f793          	andi	a5,s1,256
    80002e9a:	cb85                	beqz	a5,80002eca <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002ea0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002ea2:	ef85                	bnez	a5,80002eda <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002ea4:	00000097          	auipc	ra,0x0
    80002ea8:	e18080e7          	jalr	-488(ra) # 80002cbc <devintr>
    80002eac:	cd1d                	beqz	a0,80002eea <kerneltrap+0x6e>
  if(which_dev == 2){
    80002eae:	4789                	li	a5,2
    80002eb0:	06f50a63          	beq	a0,a5,80002f24 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002eb4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002eb8:	10049073          	csrw	sstatus,s1
}
    80002ebc:	70a2                	ld	ra,40(sp)
    80002ebe:	7402                	ld	s0,32(sp)
    80002ec0:	64e2                	ld	s1,24(sp)
    80002ec2:	6942                	ld	s2,16(sp)
    80002ec4:	69a2                	ld	s3,8(sp)
    80002ec6:	6145                	addi	sp,sp,48
    80002ec8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002eca:	00005517          	auipc	a0,0x5
    80002ece:	4f650513          	addi	a0,a0,1270 # 800083c0 <states.0+0xc8>
    80002ed2:	ffffd097          	auipc	ra,0xffffd
    80002ed6:	66c080e7          	jalr	1644(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002eda:	00005517          	auipc	a0,0x5
    80002ede:	50e50513          	addi	a0,a0,1294 # 800083e8 <states.0+0xf0>
    80002ee2:	ffffd097          	auipc	ra,0xffffd
    80002ee6:	65c080e7          	jalr	1628(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002eea:	85ce                	mv	a1,s3
    80002eec:	00005517          	auipc	a0,0x5
    80002ef0:	51c50513          	addi	a0,a0,1308 # 80008408 <states.0+0x110>
    80002ef4:	ffffd097          	auipc	ra,0xffffd
    80002ef8:	694080e7          	jalr	1684(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002efc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f00:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f04:	00005517          	auipc	a0,0x5
    80002f08:	51450513          	addi	a0,a0,1300 # 80008418 <states.0+0x120>
    80002f0c:	ffffd097          	auipc	ra,0xffffd
    80002f10:	67c080e7          	jalr	1660(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002f14:	00005517          	auipc	a0,0x5
    80002f18:	51c50513          	addi	a0,a0,1308 # 80008430 <states.0+0x138>
    80002f1c:	ffffd097          	auipc	ra,0xffffd
    80002f20:	622080e7          	jalr	1570(ra) # 8000053e <panic>
    time++;
    80002f24:	00006717          	auipc	a4,0x6
    80002f28:	a1470713          	addi	a4,a4,-1516 # 80008938 <time>
    80002f2c:	431c                	lw	a5,0(a4)
    80002f2e:	2785                	addiw	a5,a5,1
    80002f30:	c31c                	sw	a5,0(a4)
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f32:	fffff097          	auipc	ra,0xfffff
    80002f36:	e42080e7          	jalr	-446(ra) # 80001d74 <myproc>
    80002f3a:	dd2d                	beqz	a0,80002eb4 <kerneltrap+0x38>
    80002f3c:	fffff097          	auipc	ra,0xfffff
    80002f40:	e38080e7          	jalr	-456(ra) # 80001d74 <myproc>
    80002f44:	4d18                	lw	a4,24(a0)
    80002f46:	4791                	li	a5,4
    80002f48:	f6f716e3          	bne	a4,a5,80002eb4 <kerneltrap+0x38>
    yield();
    80002f4c:	fffff097          	auipc	ra,0xfffff
    80002f50:	5b6080e7          	jalr	1462(ra) # 80002502 <yield>
    80002f54:	b785                	j	80002eb4 <kerneltrap+0x38>

0000000080002f56 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f56:	1101                	addi	sp,sp,-32
    80002f58:	ec06                	sd	ra,24(sp)
    80002f5a:	e822                	sd	s0,16(sp)
    80002f5c:	e426                	sd	s1,8(sp)
    80002f5e:	1000                	addi	s0,sp,32
    80002f60:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f62:	fffff097          	auipc	ra,0xfffff
    80002f66:	e12080e7          	jalr	-494(ra) # 80001d74 <myproc>
  switch (n) {
    80002f6a:	4795                	li	a5,5
    80002f6c:	0497e163          	bltu	a5,s1,80002fae <argraw+0x58>
    80002f70:	048a                	slli	s1,s1,0x2
    80002f72:	00005717          	auipc	a4,0x5
    80002f76:	4f670713          	addi	a4,a4,1270 # 80008468 <states.0+0x170>
    80002f7a:	94ba                	add	s1,s1,a4
    80002f7c:	409c                	lw	a5,0(s1)
    80002f7e:	97ba                	add	a5,a5,a4
    80002f80:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002f82:	6d3c                	ld	a5,88(a0)
    80002f84:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002f86:	60e2                	ld	ra,24(sp)
    80002f88:	6442                	ld	s0,16(sp)
    80002f8a:	64a2                	ld	s1,8(sp)
    80002f8c:	6105                	addi	sp,sp,32
    80002f8e:	8082                	ret
    return p->trapframe->a1;
    80002f90:	6d3c                	ld	a5,88(a0)
    80002f92:	7fa8                	ld	a0,120(a5)
    80002f94:	bfcd                	j	80002f86 <argraw+0x30>
    return p->trapframe->a2;
    80002f96:	6d3c                	ld	a5,88(a0)
    80002f98:	63c8                	ld	a0,128(a5)
    80002f9a:	b7f5                	j	80002f86 <argraw+0x30>
    return p->trapframe->a3;
    80002f9c:	6d3c                	ld	a5,88(a0)
    80002f9e:	67c8                	ld	a0,136(a5)
    80002fa0:	b7dd                	j	80002f86 <argraw+0x30>
    return p->trapframe->a4;
    80002fa2:	6d3c                	ld	a5,88(a0)
    80002fa4:	6bc8                	ld	a0,144(a5)
    80002fa6:	b7c5                	j	80002f86 <argraw+0x30>
    return p->trapframe->a5;
    80002fa8:	6d3c                	ld	a5,88(a0)
    80002faa:	6fc8                	ld	a0,152(a5)
    80002fac:	bfe9                	j	80002f86 <argraw+0x30>
  panic("argraw");
    80002fae:	00005517          	auipc	a0,0x5
    80002fb2:	49250513          	addi	a0,a0,1170 # 80008440 <states.0+0x148>
    80002fb6:	ffffd097          	auipc	ra,0xffffd
    80002fba:	588080e7          	jalr	1416(ra) # 8000053e <panic>

0000000080002fbe <fetchaddr>:
{
    80002fbe:	1101                	addi	sp,sp,-32
    80002fc0:	ec06                	sd	ra,24(sp)
    80002fc2:	e822                	sd	s0,16(sp)
    80002fc4:	e426                	sd	s1,8(sp)
    80002fc6:	e04a                	sd	s2,0(sp)
    80002fc8:	1000                	addi	s0,sp,32
    80002fca:	84aa                	mv	s1,a0
    80002fcc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002fce:	fffff097          	auipc	ra,0xfffff
    80002fd2:	da6080e7          	jalr	-602(ra) # 80001d74 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002fd6:	653c                	ld	a5,72(a0)
    80002fd8:	02f4f863          	bgeu	s1,a5,80003008 <fetchaddr+0x4a>
    80002fdc:	00848713          	addi	a4,s1,8
    80002fe0:	02e7e663          	bltu	a5,a4,8000300c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002fe4:	46a1                	li	a3,8
    80002fe6:	8626                	mv	a2,s1
    80002fe8:	85ca                	mv	a1,s2
    80002fea:	6928                	ld	a0,80(a0)
    80002fec:	ffffe097          	auipc	ra,0xffffe
    80002ff0:	708080e7          	jalr	1800(ra) # 800016f4 <copyin>
    80002ff4:	00a03533          	snez	a0,a0
    80002ff8:	40a00533          	neg	a0,a0
}
    80002ffc:	60e2                	ld	ra,24(sp)
    80002ffe:	6442                	ld	s0,16(sp)
    80003000:	64a2                	ld	s1,8(sp)
    80003002:	6902                	ld	s2,0(sp)
    80003004:	6105                	addi	sp,sp,32
    80003006:	8082                	ret
    return -1;
    80003008:	557d                	li	a0,-1
    8000300a:	bfcd                	j	80002ffc <fetchaddr+0x3e>
    8000300c:	557d                	li	a0,-1
    8000300e:	b7fd                	j	80002ffc <fetchaddr+0x3e>

0000000080003010 <fetchstr>:
{
    80003010:	7179                	addi	sp,sp,-48
    80003012:	f406                	sd	ra,40(sp)
    80003014:	f022                	sd	s0,32(sp)
    80003016:	ec26                	sd	s1,24(sp)
    80003018:	e84a                	sd	s2,16(sp)
    8000301a:	e44e                	sd	s3,8(sp)
    8000301c:	1800                	addi	s0,sp,48
    8000301e:	892a                	mv	s2,a0
    80003020:	84ae                	mv	s1,a1
    80003022:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003024:	fffff097          	auipc	ra,0xfffff
    80003028:	d50080e7          	jalr	-688(ra) # 80001d74 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000302c:	86ce                	mv	a3,s3
    8000302e:	864a                	mv	a2,s2
    80003030:	85a6                	mv	a1,s1
    80003032:	6928                	ld	a0,80(a0)
    80003034:	ffffe097          	auipc	ra,0xffffe
    80003038:	74e080e7          	jalr	1870(ra) # 80001782 <copyinstr>
    8000303c:	00054e63          	bltz	a0,80003058 <fetchstr+0x48>
  return strlen(buf);
    80003040:	8526                	mv	a0,s1
    80003042:	ffffe097          	auipc	ra,0xffffe
    80003046:	e0c080e7          	jalr	-500(ra) # 80000e4e <strlen>
}
    8000304a:	70a2                	ld	ra,40(sp)
    8000304c:	7402                	ld	s0,32(sp)
    8000304e:	64e2                	ld	s1,24(sp)
    80003050:	6942                	ld	s2,16(sp)
    80003052:	69a2                	ld	s3,8(sp)
    80003054:	6145                	addi	sp,sp,48
    80003056:	8082                	ret
    return -1;
    80003058:	557d                	li	a0,-1
    8000305a:	bfc5                	j	8000304a <fetchstr+0x3a>

000000008000305c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000305c:	1101                	addi	sp,sp,-32
    8000305e:	ec06                	sd	ra,24(sp)
    80003060:	e822                	sd	s0,16(sp)
    80003062:	e426                	sd	s1,8(sp)
    80003064:	1000                	addi	s0,sp,32
    80003066:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003068:	00000097          	auipc	ra,0x0
    8000306c:	eee080e7          	jalr	-274(ra) # 80002f56 <argraw>
    80003070:	c088                	sw	a0,0(s1)
}
    80003072:	60e2                	ld	ra,24(sp)
    80003074:	6442                	ld	s0,16(sp)
    80003076:	64a2                	ld	s1,8(sp)
    80003078:	6105                	addi	sp,sp,32
    8000307a:	8082                	ret

000000008000307c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000307c:	1101                	addi	sp,sp,-32
    8000307e:	ec06                	sd	ra,24(sp)
    80003080:	e822                	sd	s0,16(sp)
    80003082:	e426                	sd	s1,8(sp)
    80003084:	1000                	addi	s0,sp,32
    80003086:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003088:	00000097          	auipc	ra,0x0
    8000308c:	ece080e7          	jalr	-306(ra) # 80002f56 <argraw>
    80003090:	e088                	sd	a0,0(s1)
}
    80003092:	60e2                	ld	ra,24(sp)
    80003094:	6442                	ld	s0,16(sp)
    80003096:	64a2                	ld	s1,8(sp)
    80003098:	6105                	addi	sp,sp,32
    8000309a:	8082                	ret

000000008000309c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000309c:	7179                	addi	sp,sp,-48
    8000309e:	f406                	sd	ra,40(sp)
    800030a0:	f022                	sd	s0,32(sp)
    800030a2:	ec26                	sd	s1,24(sp)
    800030a4:	e84a                	sd	s2,16(sp)
    800030a6:	1800                	addi	s0,sp,48
    800030a8:	84ae                	mv	s1,a1
    800030aa:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800030ac:	fd840593          	addi	a1,s0,-40
    800030b0:	00000097          	auipc	ra,0x0
    800030b4:	fcc080e7          	jalr	-52(ra) # 8000307c <argaddr>
  return fetchstr(addr, buf, max);
    800030b8:	864a                	mv	a2,s2
    800030ba:	85a6                	mv	a1,s1
    800030bc:	fd843503          	ld	a0,-40(s0)
    800030c0:	00000097          	auipc	ra,0x0
    800030c4:	f50080e7          	jalr	-176(ra) # 80003010 <fetchstr>
}
    800030c8:	70a2                	ld	ra,40(sp)
    800030ca:	7402                	ld	s0,32(sp)
    800030cc:	64e2                	ld	s1,24(sp)
    800030ce:	6942                	ld	s2,16(sp)
    800030d0:	6145                	addi	sp,sp,48
    800030d2:	8082                	ret

00000000800030d4 <syscall>:
[SYS_nice]    sys_nice,
};

void
syscall(void)
{
    800030d4:	1101                	addi	sp,sp,-32
    800030d6:	ec06                	sd	ra,24(sp)
    800030d8:	e822                	sd	s0,16(sp)
    800030da:	e426                	sd	s1,8(sp)
    800030dc:	e04a                	sd	s2,0(sp)
    800030de:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800030e0:	fffff097          	auipc	ra,0xfffff
    800030e4:	c94080e7          	jalr	-876(ra) # 80001d74 <myproc>
    800030e8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800030ea:	05853903          	ld	s2,88(a0)
    800030ee:	0a893783          	ld	a5,168(s2)
    800030f2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800030f6:	37fd                	addiw	a5,a5,-1
    800030f8:	475d                	li	a4,23
    800030fa:	00f76f63          	bltu	a4,a5,80003118 <syscall+0x44>
    800030fe:	00369713          	slli	a4,a3,0x3
    80003102:	00005797          	auipc	a5,0x5
    80003106:	37e78793          	addi	a5,a5,894 # 80008480 <syscalls>
    8000310a:	97ba                	add	a5,a5,a4
    8000310c:	639c                	ld	a5,0(a5)
    8000310e:	c789                	beqz	a5,80003118 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80003110:	9782                	jalr	a5
    80003112:	06a93823          	sd	a0,112(s2)
    80003116:	a839                	j	80003134 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003118:	15848613          	addi	a2,s1,344
    8000311c:	588c                	lw	a1,48(s1)
    8000311e:	00005517          	auipc	a0,0x5
    80003122:	32a50513          	addi	a0,a0,810 # 80008448 <states.0+0x150>
    80003126:	ffffd097          	auipc	ra,0xffffd
    8000312a:	462080e7          	jalr	1122(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000312e:	6cbc                	ld	a5,88(s1)
    80003130:	577d                	li	a4,-1
    80003132:	fbb8                	sd	a4,112(a5)
  }
}
    80003134:	60e2                	ld	ra,24(sp)
    80003136:	6442                	ld	s0,16(sp)
    80003138:	64a2                	ld	s1,8(sp)
    8000313a:	6902                	ld	s2,0(sp)
    8000313c:	6105                	addi	sp,sp,32
    8000313e:	8082                	ret

0000000080003140 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003140:	1101                	addi	sp,sp,-32
    80003142:	ec06                	sd	ra,24(sp)
    80003144:	e822                	sd	s0,16(sp)
    80003146:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003148:	fec40593          	addi	a1,s0,-20
    8000314c:	4501                	li	a0,0
    8000314e:	00000097          	auipc	ra,0x0
    80003152:	f0e080e7          	jalr	-242(ra) # 8000305c <argint>
  exit(n);
    80003156:	fec42503          	lw	a0,-20(s0)
    8000315a:	fffff097          	auipc	ra,0xfffff
    8000315e:	586080e7          	jalr	1414(ra) # 800026e0 <exit>
  return 0;  // not reached
}
    80003162:	4501                	li	a0,0
    80003164:	60e2                	ld	ra,24(sp)
    80003166:	6442                	ld	s0,16(sp)
    80003168:	6105                	addi	sp,sp,32
    8000316a:	8082                	ret

000000008000316c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000316c:	1141                	addi	sp,sp,-16
    8000316e:	e406                	sd	ra,8(sp)
    80003170:	e022                	sd	s0,0(sp)
    80003172:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003174:	fffff097          	auipc	ra,0xfffff
    80003178:	c00080e7          	jalr	-1024(ra) # 80001d74 <myproc>
}
    8000317c:	5908                	lw	a0,48(a0)
    8000317e:	60a2                	ld	ra,8(sp)
    80003180:	6402                	ld	s0,0(sp)
    80003182:	0141                	addi	sp,sp,16
    80003184:	8082                	ret

0000000080003186 <sys_fork>:

uint64
sys_fork(void)
{
    80003186:	1141                	addi	sp,sp,-16
    80003188:	e406                	sd	ra,8(sp)
    8000318a:	e022                	sd	s0,0(sp)
    8000318c:	0800                	addi	s0,sp,16
  return fork();
    8000318e:	fffff097          	auipc	ra,0xfffff
    80003192:	0b8080e7          	jalr	184(ra) # 80002246 <fork>
}
    80003196:	60a2                	ld	ra,8(sp)
    80003198:	6402                	ld	s0,0(sp)
    8000319a:	0141                	addi	sp,sp,16
    8000319c:	8082                	ret

000000008000319e <sys_wait>:

uint64
sys_wait(void)
{
    8000319e:	1101                	addi	sp,sp,-32
    800031a0:	ec06                	sd	ra,24(sp)
    800031a2:	e822                	sd	s0,16(sp)
    800031a4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800031a6:	fe840593          	addi	a1,s0,-24
    800031aa:	4501                	li	a0,0
    800031ac:	00000097          	auipc	ra,0x0
    800031b0:	ed0080e7          	jalr	-304(ra) # 8000307c <argaddr>
  return wait(p);
    800031b4:	fe843503          	ld	a0,-24(s0)
    800031b8:	fffff097          	auipc	ra,0xfffff
    800031bc:	6f6080e7          	jalr	1782(ra) # 800028ae <wait>
}
    800031c0:	60e2                	ld	ra,24(sp)
    800031c2:	6442                	ld	s0,16(sp)
    800031c4:	6105                	addi	sp,sp,32
    800031c6:	8082                	ret

00000000800031c8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800031c8:	7179                	addi	sp,sp,-48
    800031ca:	f406                	sd	ra,40(sp)
    800031cc:	f022                	sd	s0,32(sp)
    800031ce:	ec26                	sd	s1,24(sp)
    800031d0:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800031d2:	fdc40593          	addi	a1,s0,-36
    800031d6:	4501                	li	a0,0
    800031d8:	00000097          	auipc	ra,0x0
    800031dc:	e84080e7          	jalr	-380(ra) # 8000305c <argint>
  addr = myproc()->sz;
    800031e0:	fffff097          	auipc	ra,0xfffff
    800031e4:	b94080e7          	jalr	-1132(ra) # 80001d74 <myproc>
    800031e8:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800031ea:	fdc42503          	lw	a0,-36(s0)
    800031ee:	fffff097          	auipc	ra,0xfffff
    800031f2:	ffc080e7          	jalr	-4(ra) # 800021ea <growproc>
    800031f6:	00054863          	bltz	a0,80003206 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800031fa:	8526                	mv	a0,s1
    800031fc:	70a2                	ld	ra,40(sp)
    800031fe:	7402                	ld	s0,32(sp)
    80003200:	64e2                	ld	s1,24(sp)
    80003202:	6145                	addi	sp,sp,48
    80003204:	8082                	ret
    return -1;
    80003206:	54fd                	li	s1,-1
    80003208:	bfcd                	j	800031fa <sys_sbrk+0x32>

000000008000320a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000320a:	7139                	addi	sp,sp,-64
    8000320c:	fc06                	sd	ra,56(sp)
    8000320e:	f822                	sd	s0,48(sp)
    80003210:	f426                	sd	s1,40(sp)
    80003212:	f04a                	sd	s2,32(sp)
    80003214:	ec4e                	sd	s3,24(sp)
    80003216:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003218:	fcc40593          	addi	a1,s0,-52
    8000321c:	4501                	li	a0,0
    8000321e:	00000097          	auipc	ra,0x0
    80003222:	e3e080e7          	jalr	-450(ra) # 8000305c <argint>
  acquire(&tickslock);
    80003226:	00014517          	auipc	a0,0x14
    8000322a:	56a50513          	addi	a0,a0,1386 # 80017790 <tickslock>
    8000322e:	ffffe097          	auipc	ra,0xffffe
    80003232:	9a8080e7          	jalr	-1624(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80003236:	00005917          	auipc	s2,0x5
    8000323a:	71292903          	lw	s2,1810(s2) # 80008948 <ticks>
  while(ticks - ticks0 < n){
    8000323e:	fcc42783          	lw	a5,-52(s0)
    80003242:	cf9d                	beqz	a5,80003280 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003244:	00014997          	auipc	s3,0x14
    80003248:	54c98993          	addi	s3,s3,1356 # 80017790 <tickslock>
    8000324c:	00005497          	auipc	s1,0x5
    80003250:	6fc48493          	addi	s1,s1,1788 # 80008948 <ticks>
    if(killed(myproc())){
    80003254:	fffff097          	auipc	ra,0xfffff
    80003258:	b20080e7          	jalr	-1248(ra) # 80001d74 <myproc>
    8000325c:	fffff097          	auipc	ra,0xfffff
    80003260:	620080e7          	jalr	1568(ra) # 8000287c <killed>
    80003264:	ed15                	bnez	a0,800032a0 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003266:	85ce                	mv	a1,s3
    80003268:	8526                	mv	a0,s1
    8000326a:	fffff097          	auipc	ra,0xfffff
    8000326e:	314080e7          	jalr	788(ra) # 8000257e <sleep>
  while(ticks - ticks0 < n){
    80003272:	409c                	lw	a5,0(s1)
    80003274:	412787bb          	subw	a5,a5,s2
    80003278:	fcc42703          	lw	a4,-52(s0)
    8000327c:	fce7ece3          	bltu	a5,a4,80003254 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003280:	00014517          	auipc	a0,0x14
    80003284:	51050513          	addi	a0,a0,1296 # 80017790 <tickslock>
    80003288:	ffffe097          	auipc	ra,0xffffe
    8000328c:	a02080e7          	jalr	-1534(ra) # 80000c8a <release>
  return 0;
    80003290:	4501                	li	a0,0
}
    80003292:	70e2                	ld	ra,56(sp)
    80003294:	7442                	ld	s0,48(sp)
    80003296:	74a2                	ld	s1,40(sp)
    80003298:	7902                	ld	s2,32(sp)
    8000329a:	69e2                	ld	s3,24(sp)
    8000329c:	6121                	addi	sp,sp,64
    8000329e:	8082                	ret
      release(&tickslock);
    800032a0:	00014517          	auipc	a0,0x14
    800032a4:	4f050513          	addi	a0,a0,1264 # 80017790 <tickslock>
    800032a8:	ffffe097          	auipc	ra,0xffffe
    800032ac:	9e2080e7          	jalr	-1566(ra) # 80000c8a <release>
      return -1;
    800032b0:	557d                	li	a0,-1
    800032b2:	b7c5                	j	80003292 <sys_sleep+0x88>

00000000800032b4 <sys_kill>:

uint64
sys_kill(void)
{
    800032b4:	1101                	addi	sp,sp,-32
    800032b6:	ec06                	sd	ra,24(sp)
    800032b8:	e822                	sd	s0,16(sp)
    800032ba:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800032bc:	fec40593          	addi	a1,s0,-20
    800032c0:	4501                	li	a0,0
    800032c2:	00000097          	auipc	ra,0x0
    800032c6:	d9a080e7          	jalr	-614(ra) # 8000305c <argint>
  return kill(pid);
    800032ca:	fec42503          	lw	a0,-20(s0)
    800032ce:	fffff097          	auipc	ra,0xfffff
    800032d2:	4e8080e7          	jalr	1256(ra) # 800027b6 <kill>
}
    800032d6:	60e2                	ld	ra,24(sp)
    800032d8:	6442                	ld	s0,16(sp)
    800032da:	6105                	addi	sp,sp,32
    800032dc:	8082                	ret

00000000800032de <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800032de:	1101                	addi	sp,sp,-32
    800032e0:	ec06                	sd	ra,24(sp)
    800032e2:	e822                	sd	s0,16(sp)
    800032e4:	e426                	sd	s1,8(sp)
    800032e6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800032e8:	00014517          	auipc	a0,0x14
    800032ec:	4a850513          	addi	a0,a0,1192 # 80017790 <tickslock>
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	8e6080e7          	jalr	-1818(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800032f8:	00005497          	auipc	s1,0x5
    800032fc:	6504a483          	lw	s1,1616(s1) # 80008948 <ticks>
  release(&tickslock);
    80003300:	00014517          	auipc	a0,0x14
    80003304:	49050513          	addi	a0,a0,1168 # 80017790 <tickslock>
    80003308:	ffffe097          	auipc	ra,0xffffe
    8000330c:	982080e7          	jalr	-1662(ra) # 80000c8a <release>
  return xticks;
}
    80003310:	02049513          	slli	a0,s1,0x20
    80003314:	9101                	srli	a0,a0,0x20
    80003316:	60e2                	ld	ra,24(sp)
    80003318:	6442                	ld	s0,16(sp)
    8000331a:	64a2                	ld	s1,8(sp)
    8000331c:	6105                	addi	sp,sp,32
    8000331e:	8082                	ret

0000000080003320 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003320:	7179                	addi	sp,sp,-48
    80003322:	f406                	sd	ra,40(sp)
    80003324:	f022                	sd	s0,32(sp)
    80003326:	ec26                	sd	s1,24(sp)
    80003328:	e84a                	sd	s2,16(sp)
    8000332a:	e44e                	sd	s3,8(sp)
    8000332c:	e052                	sd	s4,0(sp)
    8000332e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003330:	00005597          	auipc	a1,0x5
    80003334:	21858593          	addi	a1,a1,536 # 80008548 <syscalls+0xc8>
    80003338:	00014517          	auipc	a0,0x14
    8000333c:	47050513          	addi	a0,a0,1136 # 800177a8 <bcache>
    80003340:	ffffe097          	auipc	ra,0xffffe
    80003344:	806080e7          	jalr	-2042(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003348:	0001c797          	auipc	a5,0x1c
    8000334c:	46078793          	addi	a5,a5,1120 # 8001f7a8 <bcache+0x8000>
    80003350:	0001c717          	auipc	a4,0x1c
    80003354:	6c070713          	addi	a4,a4,1728 # 8001fa10 <bcache+0x8268>
    80003358:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000335c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003360:	00014497          	auipc	s1,0x14
    80003364:	46048493          	addi	s1,s1,1120 # 800177c0 <bcache+0x18>
    b->next = bcache.head.next;
    80003368:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000336a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000336c:	00005a17          	auipc	s4,0x5
    80003370:	1e4a0a13          	addi	s4,s4,484 # 80008550 <syscalls+0xd0>
    b->next = bcache.head.next;
    80003374:	2b893783          	ld	a5,696(s2)
    80003378:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000337a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000337e:	85d2                	mv	a1,s4
    80003380:	01048513          	addi	a0,s1,16
    80003384:	00001097          	auipc	ra,0x1
    80003388:	4c4080e7          	jalr	1220(ra) # 80004848 <initsleeplock>
    bcache.head.next->prev = b;
    8000338c:	2b893783          	ld	a5,696(s2)
    80003390:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003392:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003396:	45848493          	addi	s1,s1,1112
    8000339a:	fd349de3          	bne	s1,s3,80003374 <binit+0x54>
  }
}
    8000339e:	70a2                	ld	ra,40(sp)
    800033a0:	7402                	ld	s0,32(sp)
    800033a2:	64e2                	ld	s1,24(sp)
    800033a4:	6942                	ld	s2,16(sp)
    800033a6:	69a2                	ld	s3,8(sp)
    800033a8:	6a02                	ld	s4,0(sp)
    800033aa:	6145                	addi	sp,sp,48
    800033ac:	8082                	ret

00000000800033ae <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033ae:	7179                	addi	sp,sp,-48
    800033b0:	f406                	sd	ra,40(sp)
    800033b2:	f022                	sd	s0,32(sp)
    800033b4:	ec26                	sd	s1,24(sp)
    800033b6:	e84a                	sd	s2,16(sp)
    800033b8:	e44e                	sd	s3,8(sp)
    800033ba:	1800                	addi	s0,sp,48
    800033bc:	892a                	mv	s2,a0
    800033be:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800033c0:	00014517          	auipc	a0,0x14
    800033c4:	3e850513          	addi	a0,a0,1000 # 800177a8 <bcache>
    800033c8:	ffffe097          	auipc	ra,0xffffe
    800033cc:	80e080e7          	jalr	-2034(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033d0:	0001c497          	auipc	s1,0x1c
    800033d4:	6904b483          	ld	s1,1680(s1) # 8001fa60 <bcache+0x82b8>
    800033d8:	0001c797          	auipc	a5,0x1c
    800033dc:	63878793          	addi	a5,a5,1592 # 8001fa10 <bcache+0x8268>
    800033e0:	02f48f63          	beq	s1,a5,8000341e <bread+0x70>
    800033e4:	873e                	mv	a4,a5
    800033e6:	a021                	j	800033ee <bread+0x40>
    800033e8:	68a4                	ld	s1,80(s1)
    800033ea:	02e48a63          	beq	s1,a4,8000341e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800033ee:	449c                	lw	a5,8(s1)
    800033f0:	ff279ce3          	bne	a5,s2,800033e8 <bread+0x3a>
    800033f4:	44dc                	lw	a5,12(s1)
    800033f6:	ff3799e3          	bne	a5,s3,800033e8 <bread+0x3a>
      b->refcnt++;
    800033fa:	40bc                	lw	a5,64(s1)
    800033fc:	2785                	addiw	a5,a5,1
    800033fe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003400:	00014517          	auipc	a0,0x14
    80003404:	3a850513          	addi	a0,a0,936 # 800177a8 <bcache>
    80003408:	ffffe097          	auipc	ra,0xffffe
    8000340c:	882080e7          	jalr	-1918(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003410:	01048513          	addi	a0,s1,16
    80003414:	00001097          	auipc	ra,0x1
    80003418:	46e080e7          	jalr	1134(ra) # 80004882 <acquiresleep>
      return b;
    8000341c:	a8b9                	j	8000347a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000341e:	0001c497          	auipc	s1,0x1c
    80003422:	63a4b483          	ld	s1,1594(s1) # 8001fa58 <bcache+0x82b0>
    80003426:	0001c797          	auipc	a5,0x1c
    8000342a:	5ea78793          	addi	a5,a5,1514 # 8001fa10 <bcache+0x8268>
    8000342e:	00f48863          	beq	s1,a5,8000343e <bread+0x90>
    80003432:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003434:	40bc                	lw	a5,64(s1)
    80003436:	cf81                	beqz	a5,8000344e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003438:	64a4                	ld	s1,72(s1)
    8000343a:	fee49de3          	bne	s1,a4,80003434 <bread+0x86>
  panic("bget: no buffers");
    8000343e:	00005517          	auipc	a0,0x5
    80003442:	11a50513          	addi	a0,a0,282 # 80008558 <syscalls+0xd8>
    80003446:	ffffd097          	auipc	ra,0xffffd
    8000344a:	0f8080e7          	jalr	248(ra) # 8000053e <panic>
      b->dev = dev;
    8000344e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003452:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003456:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000345a:	4785                	li	a5,1
    8000345c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000345e:	00014517          	auipc	a0,0x14
    80003462:	34a50513          	addi	a0,a0,842 # 800177a8 <bcache>
    80003466:	ffffe097          	auipc	ra,0xffffe
    8000346a:	824080e7          	jalr	-2012(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000346e:	01048513          	addi	a0,s1,16
    80003472:	00001097          	auipc	ra,0x1
    80003476:	410080e7          	jalr	1040(ra) # 80004882 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000347a:	409c                	lw	a5,0(s1)
    8000347c:	cb89                	beqz	a5,8000348e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000347e:	8526                	mv	a0,s1
    80003480:	70a2                	ld	ra,40(sp)
    80003482:	7402                	ld	s0,32(sp)
    80003484:	64e2                	ld	s1,24(sp)
    80003486:	6942                	ld	s2,16(sp)
    80003488:	69a2                	ld	s3,8(sp)
    8000348a:	6145                	addi	sp,sp,48
    8000348c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000348e:	4581                	li	a1,0
    80003490:	8526                	mv	a0,s1
    80003492:	00003097          	auipc	ra,0x3
    80003496:	fd2080e7          	jalr	-46(ra) # 80006464 <virtio_disk_rw>
    b->valid = 1;
    8000349a:	4785                	li	a5,1
    8000349c:	c09c                	sw	a5,0(s1)
  return b;
    8000349e:	b7c5                	j	8000347e <bread+0xd0>

00000000800034a0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034a0:	1101                	addi	sp,sp,-32
    800034a2:	ec06                	sd	ra,24(sp)
    800034a4:	e822                	sd	s0,16(sp)
    800034a6:	e426                	sd	s1,8(sp)
    800034a8:	1000                	addi	s0,sp,32
    800034aa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034ac:	0541                	addi	a0,a0,16
    800034ae:	00001097          	auipc	ra,0x1
    800034b2:	46e080e7          	jalr	1134(ra) # 8000491c <holdingsleep>
    800034b6:	cd01                	beqz	a0,800034ce <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800034b8:	4585                	li	a1,1
    800034ba:	8526                	mv	a0,s1
    800034bc:	00003097          	auipc	ra,0x3
    800034c0:	fa8080e7          	jalr	-88(ra) # 80006464 <virtio_disk_rw>
}
    800034c4:	60e2                	ld	ra,24(sp)
    800034c6:	6442                	ld	s0,16(sp)
    800034c8:	64a2                	ld	s1,8(sp)
    800034ca:	6105                	addi	sp,sp,32
    800034cc:	8082                	ret
    panic("bwrite");
    800034ce:	00005517          	auipc	a0,0x5
    800034d2:	0a250513          	addi	a0,a0,162 # 80008570 <syscalls+0xf0>
    800034d6:	ffffd097          	auipc	ra,0xffffd
    800034da:	068080e7          	jalr	104(ra) # 8000053e <panic>

00000000800034de <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800034de:	1101                	addi	sp,sp,-32
    800034e0:	ec06                	sd	ra,24(sp)
    800034e2:	e822                	sd	s0,16(sp)
    800034e4:	e426                	sd	s1,8(sp)
    800034e6:	e04a                	sd	s2,0(sp)
    800034e8:	1000                	addi	s0,sp,32
    800034ea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034ec:	01050913          	addi	s2,a0,16
    800034f0:	854a                	mv	a0,s2
    800034f2:	00001097          	auipc	ra,0x1
    800034f6:	42a080e7          	jalr	1066(ra) # 8000491c <holdingsleep>
    800034fa:	c92d                	beqz	a0,8000356c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800034fc:	854a                	mv	a0,s2
    800034fe:	00001097          	auipc	ra,0x1
    80003502:	3da080e7          	jalr	986(ra) # 800048d8 <releasesleep>

  acquire(&bcache.lock);
    80003506:	00014517          	auipc	a0,0x14
    8000350a:	2a250513          	addi	a0,a0,674 # 800177a8 <bcache>
    8000350e:	ffffd097          	auipc	ra,0xffffd
    80003512:	6c8080e7          	jalr	1736(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003516:	40bc                	lw	a5,64(s1)
    80003518:	37fd                	addiw	a5,a5,-1
    8000351a:	0007871b          	sext.w	a4,a5
    8000351e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003520:	eb05                	bnez	a4,80003550 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003522:	68bc                	ld	a5,80(s1)
    80003524:	64b8                	ld	a4,72(s1)
    80003526:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003528:	64bc                	ld	a5,72(s1)
    8000352a:	68b8                	ld	a4,80(s1)
    8000352c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000352e:	0001c797          	auipc	a5,0x1c
    80003532:	27a78793          	addi	a5,a5,634 # 8001f7a8 <bcache+0x8000>
    80003536:	2b87b703          	ld	a4,696(a5)
    8000353a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000353c:	0001c717          	auipc	a4,0x1c
    80003540:	4d470713          	addi	a4,a4,1236 # 8001fa10 <bcache+0x8268>
    80003544:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003546:	2b87b703          	ld	a4,696(a5)
    8000354a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000354c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003550:	00014517          	auipc	a0,0x14
    80003554:	25850513          	addi	a0,a0,600 # 800177a8 <bcache>
    80003558:	ffffd097          	auipc	ra,0xffffd
    8000355c:	732080e7          	jalr	1842(ra) # 80000c8a <release>
}
    80003560:	60e2                	ld	ra,24(sp)
    80003562:	6442                	ld	s0,16(sp)
    80003564:	64a2                	ld	s1,8(sp)
    80003566:	6902                	ld	s2,0(sp)
    80003568:	6105                	addi	sp,sp,32
    8000356a:	8082                	ret
    panic("brelse");
    8000356c:	00005517          	auipc	a0,0x5
    80003570:	00c50513          	addi	a0,a0,12 # 80008578 <syscalls+0xf8>
    80003574:	ffffd097          	auipc	ra,0xffffd
    80003578:	fca080e7          	jalr	-54(ra) # 8000053e <panic>

000000008000357c <bpin>:

void
bpin(struct buf *b) {
    8000357c:	1101                	addi	sp,sp,-32
    8000357e:	ec06                	sd	ra,24(sp)
    80003580:	e822                	sd	s0,16(sp)
    80003582:	e426                	sd	s1,8(sp)
    80003584:	1000                	addi	s0,sp,32
    80003586:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003588:	00014517          	auipc	a0,0x14
    8000358c:	22050513          	addi	a0,a0,544 # 800177a8 <bcache>
    80003590:	ffffd097          	auipc	ra,0xffffd
    80003594:	646080e7          	jalr	1606(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003598:	40bc                	lw	a5,64(s1)
    8000359a:	2785                	addiw	a5,a5,1
    8000359c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000359e:	00014517          	auipc	a0,0x14
    800035a2:	20a50513          	addi	a0,a0,522 # 800177a8 <bcache>
    800035a6:	ffffd097          	auipc	ra,0xffffd
    800035aa:	6e4080e7          	jalr	1764(ra) # 80000c8a <release>
}
    800035ae:	60e2                	ld	ra,24(sp)
    800035b0:	6442                	ld	s0,16(sp)
    800035b2:	64a2                	ld	s1,8(sp)
    800035b4:	6105                	addi	sp,sp,32
    800035b6:	8082                	ret

00000000800035b8 <bunpin>:

void
bunpin(struct buf *b) {
    800035b8:	1101                	addi	sp,sp,-32
    800035ba:	ec06                	sd	ra,24(sp)
    800035bc:	e822                	sd	s0,16(sp)
    800035be:	e426                	sd	s1,8(sp)
    800035c0:	1000                	addi	s0,sp,32
    800035c2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035c4:	00014517          	auipc	a0,0x14
    800035c8:	1e450513          	addi	a0,a0,484 # 800177a8 <bcache>
    800035cc:	ffffd097          	auipc	ra,0xffffd
    800035d0:	60a080e7          	jalr	1546(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800035d4:	40bc                	lw	a5,64(s1)
    800035d6:	37fd                	addiw	a5,a5,-1
    800035d8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035da:	00014517          	auipc	a0,0x14
    800035de:	1ce50513          	addi	a0,a0,462 # 800177a8 <bcache>
    800035e2:	ffffd097          	auipc	ra,0xffffd
    800035e6:	6a8080e7          	jalr	1704(ra) # 80000c8a <release>
}
    800035ea:	60e2                	ld	ra,24(sp)
    800035ec:	6442                	ld	s0,16(sp)
    800035ee:	64a2                	ld	s1,8(sp)
    800035f0:	6105                	addi	sp,sp,32
    800035f2:	8082                	ret

00000000800035f4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800035f4:	1101                	addi	sp,sp,-32
    800035f6:	ec06                	sd	ra,24(sp)
    800035f8:	e822                	sd	s0,16(sp)
    800035fa:	e426                	sd	s1,8(sp)
    800035fc:	e04a                	sd	s2,0(sp)
    800035fe:	1000                	addi	s0,sp,32
    80003600:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003602:	00d5d59b          	srliw	a1,a1,0xd
    80003606:	0001d797          	auipc	a5,0x1d
    8000360a:	87e7a783          	lw	a5,-1922(a5) # 8001fe84 <sb+0x1c>
    8000360e:	9dbd                	addw	a1,a1,a5
    80003610:	00000097          	auipc	ra,0x0
    80003614:	d9e080e7          	jalr	-610(ra) # 800033ae <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003618:	0074f713          	andi	a4,s1,7
    8000361c:	4785                	li	a5,1
    8000361e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003622:	14ce                	slli	s1,s1,0x33
    80003624:	90d9                	srli	s1,s1,0x36
    80003626:	00950733          	add	a4,a0,s1
    8000362a:	05874703          	lbu	a4,88(a4)
    8000362e:	00e7f6b3          	and	a3,a5,a4
    80003632:	c69d                	beqz	a3,80003660 <bfree+0x6c>
    80003634:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003636:	94aa                	add	s1,s1,a0
    80003638:	fff7c793          	not	a5,a5
    8000363c:	8ff9                	and	a5,a5,a4
    8000363e:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003642:	00001097          	auipc	ra,0x1
    80003646:	120080e7          	jalr	288(ra) # 80004762 <log_write>
  brelse(bp);
    8000364a:	854a                	mv	a0,s2
    8000364c:	00000097          	auipc	ra,0x0
    80003650:	e92080e7          	jalr	-366(ra) # 800034de <brelse>
}
    80003654:	60e2                	ld	ra,24(sp)
    80003656:	6442                	ld	s0,16(sp)
    80003658:	64a2                	ld	s1,8(sp)
    8000365a:	6902                	ld	s2,0(sp)
    8000365c:	6105                	addi	sp,sp,32
    8000365e:	8082                	ret
    panic("freeing free block");
    80003660:	00005517          	auipc	a0,0x5
    80003664:	f2050513          	addi	a0,a0,-224 # 80008580 <syscalls+0x100>
    80003668:	ffffd097          	auipc	ra,0xffffd
    8000366c:	ed6080e7          	jalr	-298(ra) # 8000053e <panic>

0000000080003670 <balloc>:
{
    80003670:	711d                	addi	sp,sp,-96
    80003672:	ec86                	sd	ra,88(sp)
    80003674:	e8a2                	sd	s0,80(sp)
    80003676:	e4a6                	sd	s1,72(sp)
    80003678:	e0ca                	sd	s2,64(sp)
    8000367a:	fc4e                	sd	s3,56(sp)
    8000367c:	f852                	sd	s4,48(sp)
    8000367e:	f456                	sd	s5,40(sp)
    80003680:	f05a                	sd	s6,32(sp)
    80003682:	ec5e                	sd	s7,24(sp)
    80003684:	e862                	sd	s8,16(sp)
    80003686:	e466                	sd	s9,8(sp)
    80003688:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000368a:	0001c797          	auipc	a5,0x1c
    8000368e:	7e27a783          	lw	a5,2018(a5) # 8001fe6c <sb+0x4>
    80003692:	10078163          	beqz	a5,80003794 <balloc+0x124>
    80003696:	8baa                	mv	s7,a0
    80003698:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000369a:	0001cb17          	auipc	s6,0x1c
    8000369e:	7ceb0b13          	addi	s6,s6,1998 # 8001fe68 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036a2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036a4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036a6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036a8:	6c89                	lui	s9,0x2
    800036aa:	a061                	j	80003732 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036ac:	974a                	add	a4,a4,s2
    800036ae:	8fd5                	or	a5,a5,a3
    800036b0:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800036b4:	854a                	mv	a0,s2
    800036b6:	00001097          	auipc	ra,0x1
    800036ba:	0ac080e7          	jalr	172(ra) # 80004762 <log_write>
        brelse(bp);
    800036be:	854a                	mv	a0,s2
    800036c0:	00000097          	auipc	ra,0x0
    800036c4:	e1e080e7          	jalr	-482(ra) # 800034de <brelse>
  bp = bread(dev, bno);
    800036c8:	85a6                	mv	a1,s1
    800036ca:	855e                	mv	a0,s7
    800036cc:	00000097          	auipc	ra,0x0
    800036d0:	ce2080e7          	jalr	-798(ra) # 800033ae <bread>
    800036d4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036d6:	40000613          	li	a2,1024
    800036da:	4581                	li	a1,0
    800036dc:	05850513          	addi	a0,a0,88
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	5f2080e7          	jalr	1522(ra) # 80000cd2 <memset>
  log_write(bp);
    800036e8:	854a                	mv	a0,s2
    800036ea:	00001097          	auipc	ra,0x1
    800036ee:	078080e7          	jalr	120(ra) # 80004762 <log_write>
  brelse(bp);
    800036f2:	854a                	mv	a0,s2
    800036f4:	00000097          	auipc	ra,0x0
    800036f8:	dea080e7          	jalr	-534(ra) # 800034de <brelse>
}
    800036fc:	8526                	mv	a0,s1
    800036fe:	60e6                	ld	ra,88(sp)
    80003700:	6446                	ld	s0,80(sp)
    80003702:	64a6                	ld	s1,72(sp)
    80003704:	6906                	ld	s2,64(sp)
    80003706:	79e2                	ld	s3,56(sp)
    80003708:	7a42                	ld	s4,48(sp)
    8000370a:	7aa2                	ld	s5,40(sp)
    8000370c:	7b02                	ld	s6,32(sp)
    8000370e:	6be2                	ld	s7,24(sp)
    80003710:	6c42                	ld	s8,16(sp)
    80003712:	6ca2                	ld	s9,8(sp)
    80003714:	6125                	addi	sp,sp,96
    80003716:	8082                	ret
    brelse(bp);
    80003718:	854a                	mv	a0,s2
    8000371a:	00000097          	auipc	ra,0x0
    8000371e:	dc4080e7          	jalr	-572(ra) # 800034de <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003722:	015c87bb          	addw	a5,s9,s5
    80003726:	00078a9b          	sext.w	s5,a5
    8000372a:	004b2703          	lw	a4,4(s6)
    8000372e:	06eaf363          	bgeu	s5,a4,80003794 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003732:	41fad79b          	sraiw	a5,s5,0x1f
    80003736:	0137d79b          	srliw	a5,a5,0x13
    8000373a:	015787bb          	addw	a5,a5,s5
    8000373e:	40d7d79b          	sraiw	a5,a5,0xd
    80003742:	01cb2583          	lw	a1,28(s6)
    80003746:	9dbd                	addw	a1,a1,a5
    80003748:	855e                	mv	a0,s7
    8000374a:	00000097          	auipc	ra,0x0
    8000374e:	c64080e7          	jalr	-924(ra) # 800033ae <bread>
    80003752:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003754:	004b2503          	lw	a0,4(s6)
    80003758:	000a849b          	sext.w	s1,s5
    8000375c:	8662                	mv	a2,s8
    8000375e:	faa4fde3          	bgeu	s1,a0,80003718 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003762:	41f6579b          	sraiw	a5,a2,0x1f
    80003766:	01d7d69b          	srliw	a3,a5,0x1d
    8000376a:	00c6873b          	addw	a4,a3,a2
    8000376e:	00777793          	andi	a5,a4,7
    80003772:	9f95                	subw	a5,a5,a3
    80003774:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003778:	4037571b          	sraiw	a4,a4,0x3
    8000377c:	00e906b3          	add	a3,s2,a4
    80003780:	0586c683          	lbu	a3,88(a3)
    80003784:	00d7f5b3          	and	a1,a5,a3
    80003788:	d195                	beqz	a1,800036ac <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000378a:	2605                	addiw	a2,a2,1
    8000378c:	2485                	addiw	s1,s1,1
    8000378e:	fd4618e3          	bne	a2,s4,8000375e <balloc+0xee>
    80003792:	b759                	j	80003718 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003794:	00005517          	auipc	a0,0x5
    80003798:	e0450513          	addi	a0,a0,-508 # 80008598 <syscalls+0x118>
    8000379c:	ffffd097          	auipc	ra,0xffffd
    800037a0:	dec080e7          	jalr	-532(ra) # 80000588 <printf>
  return 0;
    800037a4:	4481                	li	s1,0
    800037a6:	bf99                	j	800036fc <balloc+0x8c>

00000000800037a8 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037a8:	7179                	addi	sp,sp,-48
    800037aa:	f406                	sd	ra,40(sp)
    800037ac:	f022                	sd	s0,32(sp)
    800037ae:	ec26                	sd	s1,24(sp)
    800037b0:	e84a                	sd	s2,16(sp)
    800037b2:	e44e                	sd	s3,8(sp)
    800037b4:	e052                	sd	s4,0(sp)
    800037b6:	1800                	addi	s0,sp,48
    800037b8:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037ba:	47ad                	li	a5,11
    800037bc:	02b7e763          	bltu	a5,a1,800037ea <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800037c0:	02059493          	slli	s1,a1,0x20
    800037c4:	9081                	srli	s1,s1,0x20
    800037c6:	048a                	slli	s1,s1,0x2
    800037c8:	94aa                	add	s1,s1,a0
    800037ca:	0504a903          	lw	s2,80(s1)
    800037ce:	06091e63          	bnez	s2,8000384a <bmap+0xa2>
      addr = balloc(ip->dev);
    800037d2:	4108                	lw	a0,0(a0)
    800037d4:	00000097          	auipc	ra,0x0
    800037d8:	e9c080e7          	jalr	-356(ra) # 80003670 <balloc>
    800037dc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037e0:	06090563          	beqz	s2,8000384a <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800037e4:	0524a823          	sw	s2,80(s1)
    800037e8:	a08d                	j	8000384a <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800037ea:	ff45849b          	addiw	s1,a1,-12
    800037ee:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800037f2:	0ff00793          	li	a5,255
    800037f6:	08e7e563          	bltu	a5,a4,80003880 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800037fa:	08052903          	lw	s2,128(a0)
    800037fe:	00091d63          	bnez	s2,80003818 <bmap+0x70>
      addr = balloc(ip->dev);
    80003802:	4108                	lw	a0,0(a0)
    80003804:	00000097          	auipc	ra,0x0
    80003808:	e6c080e7          	jalr	-404(ra) # 80003670 <balloc>
    8000380c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003810:	02090d63          	beqz	s2,8000384a <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003814:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003818:	85ca                	mv	a1,s2
    8000381a:	0009a503          	lw	a0,0(s3)
    8000381e:	00000097          	auipc	ra,0x0
    80003822:	b90080e7          	jalr	-1136(ra) # 800033ae <bread>
    80003826:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003828:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000382c:	02049593          	slli	a1,s1,0x20
    80003830:	9181                	srli	a1,a1,0x20
    80003832:	058a                	slli	a1,a1,0x2
    80003834:	00b784b3          	add	s1,a5,a1
    80003838:	0004a903          	lw	s2,0(s1)
    8000383c:	02090063          	beqz	s2,8000385c <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003840:	8552                	mv	a0,s4
    80003842:	00000097          	auipc	ra,0x0
    80003846:	c9c080e7          	jalr	-868(ra) # 800034de <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000384a:	854a                	mv	a0,s2
    8000384c:	70a2                	ld	ra,40(sp)
    8000384e:	7402                	ld	s0,32(sp)
    80003850:	64e2                	ld	s1,24(sp)
    80003852:	6942                	ld	s2,16(sp)
    80003854:	69a2                	ld	s3,8(sp)
    80003856:	6a02                	ld	s4,0(sp)
    80003858:	6145                	addi	sp,sp,48
    8000385a:	8082                	ret
      addr = balloc(ip->dev);
    8000385c:	0009a503          	lw	a0,0(s3)
    80003860:	00000097          	auipc	ra,0x0
    80003864:	e10080e7          	jalr	-496(ra) # 80003670 <balloc>
    80003868:	0005091b          	sext.w	s2,a0
      if(addr){
    8000386c:	fc090ae3          	beqz	s2,80003840 <bmap+0x98>
        a[bn] = addr;
    80003870:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003874:	8552                	mv	a0,s4
    80003876:	00001097          	auipc	ra,0x1
    8000387a:	eec080e7          	jalr	-276(ra) # 80004762 <log_write>
    8000387e:	b7c9                	j	80003840 <bmap+0x98>
  panic("bmap: out of range");
    80003880:	00005517          	auipc	a0,0x5
    80003884:	d3050513          	addi	a0,a0,-720 # 800085b0 <syscalls+0x130>
    80003888:	ffffd097          	auipc	ra,0xffffd
    8000388c:	cb6080e7          	jalr	-842(ra) # 8000053e <panic>

0000000080003890 <iget>:
{
    80003890:	7179                	addi	sp,sp,-48
    80003892:	f406                	sd	ra,40(sp)
    80003894:	f022                	sd	s0,32(sp)
    80003896:	ec26                	sd	s1,24(sp)
    80003898:	e84a                	sd	s2,16(sp)
    8000389a:	e44e                	sd	s3,8(sp)
    8000389c:	e052                	sd	s4,0(sp)
    8000389e:	1800                	addi	s0,sp,48
    800038a0:	89aa                	mv	s3,a0
    800038a2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038a4:	0001c517          	auipc	a0,0x1c
    800038a8:	5e450513          	addi	a0,a0,1508 # 8001fe88 <itable>
    800038ac:	ffffd097          	auipc	ra,0xffffd
    800038b0:	32a080e7          	jalr	810(ra) # 80000bd6 <acquire>
  empty = 0;
    800038b4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038b6:	0001c497          	auipc	s1,0x1c
    800038ba:	5ea48493          	addi	s1,s1,1514 # 8001fea0 <itable+0x18>
    800038be:	0001e697          	auipc	a3,0x1e
    800038c2:	07268693          	addi	a3,a3,114 # 80021930 <log>
    800038c6:	a039                	j	800038d4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038c8:	02090b63          	beqz	s2,800038fe <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038cc:	08848493          	addi	s1,s1,136
    800038d0:	02d48a63          	beq	s1,a3,80003904 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038d4:	449c                	lw	a5,8(s1)
    800038d6:	fef059e3          	blez	a5,800038c8 <iget+0x38>
    800038da:	4098                	lw	a4,0(s1)
    800038dc:	ff3716e3          	bne	a4,s3,800038c8 <iget+0x38>
    800038e0:	40d8                	lw	a4,4(s1)
    800038e2:	ff4713e3          	bne	a4,s4,800038c8 <iget+0x38>
      ip->ref++;
    800038e6:	2785                	addiw	a5,a5,1
    800038e8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800038ea:	0001c517          	auipc	a0,0x1c
    800038ee:	59e50513          	addi	a0,a0,1438 # 8001fe88 <itable>
    800038f2:	ffffd097          	auipc	ra,0xffffd
    800038f6:	398080e7          	jalr	920(ra) # 80000c8a <release>
      return ip;
    800038fa:	8926                	mv	s2,s1
    800038fc:	a03d                	j	8000392a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038fe:	f7f9                	bnez	a5,800038cc <iget+0x3c>
    80003900:	8926                	mv	s2,s1
    80003902:	b7e9                	j	800038cc <iget+0x3c>
  if(empty == 0)
    80003904:	02090c63          	beqz	s2,8000393c <iget+0xac>
  ip->dev = dev;
    80003908:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000390c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003910:	4785                	li	a5,1
    80003912:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003916:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000391a:	0001c517          	auipc	a0,0x1c
    8000391e:	56e50513          	addi	a0,a0,1390 # 8001fe88 <itable>
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	368080e7          	jalr	872(ra) # 80000c8a <release>
}
    8000392a:	854a                	mv	a0,s2
    8000392c:	70a2                	ld	ra,40(sp)
    8000392e:	7402                	ld	s0,32(sp)
    80003930:	64e2                	ld	s1,24(sp)
    80003932:	6942                	ld	s2,16(sp)
    80003934:	69a2                	ld	s3,8(sp)
    80003936:	6a02                	ld	s4,0(sp)
    80003938:	6145                	addi	sp,sp,48
    8000393a:	8082                	ret
    panic("iget: no inodes");
    8000393c:	00005517          	auipc	a0,0x5
    80003940:	c8c50513          	addi	a0,a0,-884 # 800085c8 <syscalls+0x148>
    80003944:	ffffd097          	auipc	ra,0xffffd
    80003948:	bfa080e7          	jalr	-1030(ra) # 8000053e <panic>

000000008000394c <fsinit>:
fsinit(int dev) {
    8000394c:	7179                	addi	sp,sp,-48
    8000394e:	f406                	sd	ra,40(sp)
    80003950:	f022                	sd	s0,32(sp)
    80003952:	ec26                	sd	s1,24(sp)
    80003954:	e84a                	sd	s2,16(sp)
    80003956:	e44e                	sd	s3,8(sp)
    80003958:	1800                	addi	s0,sp,48
    8000395a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000395c:	4585                	li	a1,1
    8000395e:	00000097          	auipc	ra,0x0
    80003962:	a50080e7          	jalr	-1456(ra) # 800033ae <bread>
    80003966:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003968:	0001c997          	auipc	s3,0x1c
    8000396c:	50098993          	addi	s3,s3,1280 # 8001fe68 <sb>
    80003970:	02000613          	li	a2,32
    80003974:	05850593          	addi	a1,a0,88
    80003978:	854e                	mv	a0,s3
    8000397a:	ffffd097          	auipc	ra,0xffffd
    8000397e:	3b4080e7          	jalr	948(ra) # 80000d2e <memmove>
  brelse(bp);
    80003982:	8526                	mv	a0,s1
    80003984:	00000097          	auipc	ra,0x0
    80003988:	b5a080e7          	jalr	-1190(ra) # 800034de <brelse>
  if(sb.magic != FSMAGIC)
    8000398c:	0009a703          	lw	a4,0(s3)
    80003990:	102037b7          	lui	a5,0x10203
    80003994:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003998:	02f71263          	bne	a4,a5,800039bc <fsinit+0x70>
  initlog(dev, &sb);
    8000399c:	0001c597          	auipc	a1,0x1c
    800039a0:	4cc58593          	addi	a1,a1,1228 # 8001fe68 <sb>
    800039a4:	854a                	mv	a0,s2
    800039a6:	00001097          	auipc	ra,0x1
    800039aa:	b40080e7          	jalr	-1216(ra) # 800044e6 <initlog>
}
    800039ae:	70a2                	ld	ra,40(sp)
    800039b0:	7402                	ld	s0,32(sp)
    800039b2:	64e2                	ld	s1,24(sp)
    800039b4:	6942                	ld	s2,16(sp)
    800039b6:	69a2                	ld	s3,8(sp)
    800039b8:	6145                	addi	sp,sp,48
    800039ba:	8082                	ret
    panic("invalid file system");
    800039bc:	00005517          	auipc	a0,0x5
    800039c0:	c1c50513          	addi	a0,a0,-996 # 800085d8 <syscalls+0x158>
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	b7a080e7          	jalr	-1158(ra) # 8000053e <panic>

00000000800039cc <iinit>:
{
    800039cc:	7179                	addi	sp,sp,-48
    800039ce:	f406                	sd	ra,40(sp)
    800039d0:	f022                	sd	s0,32(sp)
    800039d2:	ec26                	sd	s1,24(sp)
    800039d4:	e84a                	sd	s2,16(sp)
    800039d6:	e44e                	sd	s3,8(sp)
    800039d8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800039da:	00005597          	auipc	a1,0x5
    800039de:	c1658593          	addi	a1,a1,-1002 # 800085f0 <syscalls+0x170>
    800039e2:	0001c517          	auipc	a0,0x1c
    800039e6:	4a650513          	addi	a0,a0,1190 # 8001fe88 <itable>
    800039ea:	ffffd097          	auipc	ra,0xffffd
    800039ee:	15c080e7          	jalr	348(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800039f2:	0001c497          	auipc	s1,0x1c
    800039f6:	4be48493          	addi	s1,s1,1214 # 8001feb0 <itable+0x28>
    800039fa:	0001e997          	auipc	s3,0x1e
    800039fe:	f4698993          	addi	s3,s3,-186 # 80021940 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a02:	00005917          	auipc	s2,0x5
    80003a06:	bf690913          	addi	s2,s2,-1034 # 800085f8 <syscalls+0x178>
    80003a0a:	85ca                	mv	a1,s2
    80003a0c:	8526                	mv	a0,s1
    80003a0e:	00001097          	auipc	ra,0x1
    80003a12:	e3a080e7          	jalr	-454(ra) # 80004848 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a16:	08848493          	addi	s1,s1,136
    80003a1a:	ff3498e3          	bne	s1,s3,80003a0a <iinit+0x3e>
}
    80003a1e:	70a2                	ld	ra,40(sp)
    80003a20:	7402                	ld	s0,32(sp)
    80003a22:	64e2                	ld	s1,24(sp)
    80003a24:	6942                	ld	s2,16(sp)
    80003a26:	69a2                	ld	s3,8(sp)
    80003a28:	6145                	addi	sp,sp,48
    80003a2a:	8082                	ret

0000000080003a2c <ialloc>:
{
    80003a2c:	715d                	addi	sp,sp,-80
    80003a2e:	e486                	sd	ra,72(sp)
    80003a30:	e0a2                	sd	s0,64(sp)
    80003a32:	fc26                	sd	s1,56(sp)
    80003a34:	f84a                	sd	s2,48(sp)
    80003a36:	f44e                	sd	s3,40(sp)
    80003a38:	f052                	sd	s4,32(sp)
    80003a3a:	ec56                	sd	s5,24(sp)
    80003a3c:	e85a                	sd	s6,16(sp)
    80003a3e:	e45e                	sd	s7,8(sp)
    80003a40:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a42:	0001c717          	auipc	a4,0x1c
    80003a46:	43272703          	lw	a4,1074(a4) # 8001fe74 <sb+0xc>
    80003a4a:	4785                	li	a5,1
    80003a4c:	04e7fa63          	bgeu	a5,a4,80003aa0 <ialloc+0x74>
    80003a50:	8aaa                	mv	s5,a0
    80003a52:	8bae                	mv	s7,a1
    80003a54:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a56:	0001ca17          	auipc	s4,0x1c
    80003a5a:	412a0a13          	addi	s4,s4,1042 # 8001fe68 <sb>
    80003a5e:	00048b1b          	sext.w	s6,s1
    80003a62:	0044d793          	srli	a5,s1,0x4
    80003a66:	018a2583          	lw	a1,24(s4)
    80003a6a:	9dbd                	addw	a1,a1,a5
    80003a6c:	8556                	mv	a0,s5
    80003a6e:	00000097          	auipc	ra,0x0
    80003a72:	940080e7          	jalr	-1728(ra) # 800033ae <bread>
    80003a76:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a78:	05850993          	addi	s3,a0,88
    80003a7c:	00f4f793          	andi	a5,s1,15
    80003a80:	079a                	slli	a5,a5,0x6
    80003a82:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a84:	00099783          	lh	a5,0(s3)
    80003a88:	c3a1                	beqz	a5,80003ac8 <ialloc+0x9c>
    brelse(bp);
    80003a8a:	00000097          	auipc	ra,0x0
    80003a8e:	a54080e7          	jalr	-1452(ra) # 800034de <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a92:	0485                	addi	s1,s1,1
    80003a94:	00ca2703          	lw	a4,12(s4)
    80003a98:	0004879b          	sext.w	a5,s1
    80003a9c:	fce7e1e3          	bltu	a5,a4,80003a5e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003aa0:	00005517          	auipc	a0,0x5
    80003aa4:	b6050513          	addi	a0,a0,-1184 # 80008600 <syscalls+0x180>
    80003aa8:	ffffd097          	auipc	ra,0xffffd
    80003aac:	ae0080e7          	jalr	-1312(ra) # 80000588 <printf>
  return 0;
    80003ab0:	4501                	li	a0,0
}
    80003ab2:	60a6                	ld	ra,72(sp)
    80003ab4:	6406                	ld	s0,64(sp)
    80003ab6:	74e2                	ld	s1,56(sp)
    80003ab8:	7942                	ld	s2,48(sp)
    80003aba:	79a2                	ld	s3,40(sp)
    80003abc:	7a02                	ld	s4,32(sp)
    80003abe:	6ae2                	ld	s5,24(sp)
    80003ac0:	6b42                	ld	s6,16(sp)
    80003ac2:	6ba2                	ld	s7,8(sp)
    80003ac4:	6161                	addi	sp,sp,80
    80003ac6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003ac8:	04000613          	li	a2,64
    80003acc:	4581                	li	a1,0
    80003ace:	854e                	mv	a0,s3
    80003ad0:	ffffd097          	auipc	ra,0xffffd
    80003ad4:	202080e7          	jalr	514(ra) # 80000cd2 <memset>
      dip->type = type;
    80003ad8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003adc:	854a                	mv	a0,s2
    80003ade:	00001097          	auipc	ra,0x1
    80003ae2:	c84080e7          	jalr	-892(ra) # 80004762 <log_write>
      brelse(bp);
    80003ae6:	854a                	mv	a0,s2
    80003ae8:	00000097          	auipc	ra,0x0
    80003aec:	9f6080e7          	jalr	-1546(ra) # 800034de <brelse>
      return iget(dev, inum);
    80003af0:	85da                	mv	a1,s6
    80003af2:	8556                	mv	a0,s5
    80003af4:	00000097          	auipc	ra,0x0
    80003af8:	d9c080e7          	jalr	-612(ra) # 80003890 <iget>
    80003afc:	bf5d                	j	80003ab2 <ialloc+0x86>

0000000080003afe <iupdate>:
{
    80003afe:	1101                	addi	sp,sp,-32
    80003b00:	ec06                	sd	ra,24(sp)
    80003b02:	e822                	sd	s0,16(sp)
    80003b04:	e426                	sd	s1,8(sp)
    80003b06:	e04a                	sd	s2,0(sp)
    80003b08:	1000                	addi	s0,sp,32
    80003b0a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b0c:	415c                	lw	a5,4(a0)
    80003b0e:	0047d79b          	srliw	a5,a5,0x4
    80003b12:	0001c597          	auipc	a1,0x1c
    80003b16:	36e5a583          	lw	a1,878(a1) # 8001fe80 <sb+0x18>
    80003b1a:	9dbd                	addw	a1,a1,a5
    80003b1c:	4108                	lw	a0,0(a0)
    80003b1e:	00000097          	auipc	ra,0x0
    80003b22:	890080e7          	jalr	-1904(ra) # 800033ae <bread>
    80003b26:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b28:	05850793          	addi	a5,a0,88
    80003b2c:	40c8                	lw	a0,4(s1)
    80003b2e:	893d                	andi	a0,a0,15
    80003b30:	051a                	slli	a0,a0,0x6
    80003b32:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003b34:	04449703          	lh	a4,68(s1)
    80003b38:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003b3c:	04649703          	lh	a4,70(s1)
    80003b40:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003b44:	04849703          	lh	a4,72(s1)
    80003b48:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003b4c:	04a49703          	lh	a4,74(s1)
    80003b50:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003b54:	44f8                	lw	a4,76(s1)
    80003b56:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b58:	03400613          	li	a2,52
    80003b5c:	05048593          	addi	a1,s1,80
    80003b60:	0531                	addi	a0,a0,12
    80003b62:	ffffd097          	auipc	ra,0xffffd
    80003b66:	1cc080e7          	jalr	460(ra) # 80000d2e <memmove>
  log_write(bp);
    80003b6a:	854a                	mv	a0,s2
    80003b6c:	00001097          	auipc	ra,0x1
    80003b70:	bf6080e7          	jalr	-1034(ra) # 80004762 <log_write>
  brelse(bp);
    80003b74:	854a                	mv	a0,s2
    80003b76:	00000097          	auipc	ra,0x0
    80003b7a:	968080e7          	jalr	-1688(ra) # 800034de <brelse>
}
    80003b7e:	60e2                	ld	ra,24(sp)
    80003b80:	6442                	ld	s0,16(sp)
    80003b82:	64a2                	ld	s1,8(sp)
    80003b84:	6902                	ld	s2,0(sp)
    80003b86:	6105                	addi	sp,sp,32
    80003b88:	8082                	ret

0000000080003b8a <idup>:
{
    80003b8a:	1101                	addi	sp,sp,-32
    80003b8c:	ec06                	sd	ra,24(sp)
    80003b8e:	e822                	sd	s0,16(sp)
    80003b90:	e426                	sd	s1,8(sp)
    80003b92:	1000                	addi	s0,sp,32
    80003b94:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b96:	0001c517          	auipc	a0,0x1c
    80003b9a:	2f250513          	addi	a0,a0,754 # 8001fe88 <itable>
    80003b9e:	ffffd097          	auipc	ra,0xffffd
    80003ba2:	038080e7          	jalr	56(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003ba6:	449c                	lw	a5,8(s1)
    80003ba8:	2785                	addiw	a5,a5,1
    80003baa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bac:	0001c517          	auipc	a0,0x1c
    80003bb0:	2dc50513          	addi	a0,a0,732 # 8001fe88 <itable>
    80003bb4:	ffffd097          	auipc	ra,0xffffd
    80003bb8:	0d6080e7          	jalr	214(ra) # 80000c8a <release>
}
    80003bbc:	8526                	mv	a0,s1
    80003bbe:	60e2                	ld	ra,24(sp)
    80003bc0:	6442                	ld	s0,16(sp)
    80003bc2:	64a2                	ld	s1,8(sp)
    80003bc4:	6105                	addi	sp,sp,32
    80003bc6:	8082                	ret

0000000080003bc8 <ilock>:
{
    80003bc8:	1101                	addi	sp,sp,-32
    80003bca:	ec06                	sd	ra,24(sp)
    80003bcc:	e822                	sd	s0,16(sp)
    80003bce:	e426                	sd	s1,8(sp)
    80003bd0:	e04a                	sd	s2,0(sp)
    80003bd2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003bd4:	c115                	beqz	a0,80003bf8 <ilock+0x30>
    80003bd6:	84aa                	mv	s1,a0
    80003bd8:	451c                	lw	a5,8(a0)
    80003bda:	00f05f63          	blez	a5,80003bf8 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003bde:	0541                	addi	a0,a0,16
    80003be0:	00001097          	auipc	ra,0x1
    80003be4:	ca2080e7          	jalr	-862(ra) # 80004882 <acquiresleep>
  if(ip->valid == 0){
    80003be8:	40bc                	lw	a5,64(s1)
    80003bea:	cf99                	beqz	a5,80003c08 <ilock+0x40>
}
    80003bec:	60e2                	ld	ra,24(sp)
    80003bee:	6442                	ld	s0,16(sp)
    80003bf0:	64a2                	ld	s1,8(sp)
    80003bf2:	6902                	ld	s2,0(sp)
    80003bf4:	6105                	addi	sp,sp,32
    80003bf6:	8082                	ret
    panic("ilock");
    80003bf8:	00005517          	auipc	a0,0x5
    80003bfc:	a2050513          	addi	a0,a0,-1504 # 80008618 <syscalls+0x198>
    80003c00:	ffffd097          	auipc	ra,0xffffd
    80003c04:	93e080e7          	jalr	-1730(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c08:	40dc                	lw	a5,4(s1)
    80003c0a:	0047d79b          	srliw	a5,a5,0x4
    80003c0e:	0001c597          	auipc	a1,0x1c
    80003c12:	2725a583          	lw	a1,626(a1) # 8001fe80 <sb+0x18>
    80003c16:	9dbd                	addw	a1,a1,a5
    80003c18:	4088                	lw	a0,0(s1)
    80003c1a:	fffff097          	auipc	ra,0xfffff
    80003c1e:	794080e7          	jalr	1940(ra) # 800033ae <bread>
    80003c22:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c24:	05850593          	addi	a1,a0,88
    80003c28:	40dc                	lw	a5,4(s1)
    80003c2a:	8bbd                	andi	a5,a5,15
    80003c2c:	079a                	slli	a5,a5,0x6
    80003c2e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c30:	00059783          	lh	a5,0(a1)
    80003c34:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c38:	00259783          	lh	a5,2(a1)
    80003c3c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c40:	00459783          	lh	a5,4(a1)
    80003c44:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c48:	00659783          	lh	a5,6(a1)
    80003c4c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c50:	459c                	lw	a5,8(a1)
    80003c52:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c54:	03400613          	li	a2,52
    80003c58:	05b1                	addi	a1,a1,12
    80003c5a:	05048513          	addi	a0,s1,80
    80003c5e:	ffffd097          	auipc	ra,0xffffd
    80003c62:	0d0080e7          	jalr	208(ra) # 80000d2e <memmove>
    brelse(bp);
    80003c66:	854a                	mv	a0,s2
    80003c68:	00000097          	auipc	ra,0x0
    80003c6c:	876080e7          	jalr	-1930(ra) # 800034de <brelse>
    ip->valid = 1;
    80003c70:	4785                	li	a5,1
    80003c72:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c74:	04449783          	lh	a5,68(s1)
    80003c78:	fbb5                	bnez	a5,80003bec <ilock+0x24>
      panic("ilock: no type");
    80003c7a:	00005517          	auipc	a0,0x5
    80003c7e:	9a650513          	addi	a0,a0,-1626 # 80008620 <syscalls+0x1a0>
    80003c82:	ffffd097          	auipc	ra,0xffffd
    80003c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080003c8a <iunlock>:
{
    80003c8a:	1101                	addi	sp,sp,-32
    80003c8c:	ec06                	sd	ra,24(sp)
    80003c8e:	e822                	sd	s0,16(sp)
    80003c90:	e426                	sd	s1,8(sp)
    80003c92:	e04a                	sd	s2,0(sp)
    80003c94:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c96:	c905                	beqz	a0,80003cc6 <iunlock+0x3c>
    80003c98:	84aa                	mv	s1,a0
    80003c9a:	01050913          	addi	s2,a0,16
    80003c9e:	854a                	mv	a0,s2
    80003ca0:	00001097          	auipc	ra,0x1
    80003ca4:	c7c080e7          	jalr	-900(ra) # 8000491c <holdingsleep>
    80003ca8:	cd19                	beqz	a0,80003cc6 <iunlock+0x3c>
    80003caa:	449c                	lw	a5,8(s1)
    80003cac:	00f05d63          	blez	a5,80003cc6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003cb0:	854a                	mv	a0,s2
    80003cb2:	00001097          	auipc	ra,0x1
    80003cb6:	c26080e7          	jalr	-986(ra) # 800048d8 <releasesleep>
}
    80003cba:	60e2                	ld	ra,24(sp)
    80003cbc:	6442                	ld	s0,16(sp)
    80003cbe:	64a2                	ld	s1,8(sp)
    80003cc0:	6902                	ld	s2,0(sp)
    80003cc2:	6105                	addi	sp,sp,32
    80003cc4:	8082                	ret
    panic("iunlock");
    80003cc6:	00005517          	auipc	a0,0x5
    80003cca:	96a50513          	addi	a0,a0,-1686 # 80008630 <syscalls+0x1b0>
    80003cce:	ffffd097          	auipc	ra,0xffffd
    80003cd2:	870080e7          	jalr	-1936(ra) # 8000053e <panic>

0000000080003cd6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003cd6:	7179                	addi	sp,sp,-48
    80003cd8:	f406                	sd	ra,40(sp)
    80003cda:	f022                	sd	s0,32(sp)
    80003cdc:	ec26                	sd	s1,24(sp)
    80003cde:	e84a                	sd	s2,16(sp)
    80003ce0:	e44e                	sd	s3,8(sp)
    80003ce2:	e052                	sd	s4,0(sp)
    80003ce4:	1800                	addi	s0,sp,48
    80003ce6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ce8:	05050493          	addi	s1,a0,80
    80003cec:	08050913          	addi	s2,a0,128
    80003cf0:	a021                	j	80003cf8 <itrunc+0x22>
    80003cf2:	0491                	addi	s1,s1,4
    80003cf4:	01248d63          	beq	s1,s2,80003d0e <itrunc+0x38>
    if(ip->addrs[i]){
    80003cf8:	408c                	lw	a1,0(s1)
    80003cfa:	dde5                	beqz	a1,80003cf2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003cfc:	0009a503          	lw	a0,0(s3)
    80003d00:	00000097          	auipc	ra,0x0
    80003d04:	8f4080e7          	jalr	-1804(ra) # 800035f4 <bfree>
      ip->addrs[i] = 0;
    80003d08:	0004a023          	sw	zero,0(s1)
    80003d0c:	b7dd                	j	80003cf2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d0e:	0809a583          	lw	a1,128(s3)
    80003d12:	e185                	bnez	a1,80003d32 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d14:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d18:	854e                	mv	a0,s3
    80003d1a:	00000097          	auipc	ra,0x0
    80003d1e:	de4080e7          	jalr	-540(ra) # 80003afe <iupdate>
}
    80003d22:	70a2                	ld	ra,40(sp)
    80003d24:	7402                	ld	s0,32(sp)
    80003d26:	64e2                	ld	s1,24(sp)
    80003d28:	6942                	ld	s2,16(sp)
    80003d2a:	69a2                	ld	s3,8(sp)
    80003d2c:	6a02                	ld	s4,0(sp)
    80003d2e:	6145                	addi	sp,sp,48
    80003d30:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d32:	0009a503          	lw	a0,0(s3)
    80003d36:	fffff097          	auipc	ra,0xfffff
    80003d3a:	678080e7          	jalr	1656(ra) # 800033ae <bread>
    80003d3e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d40:	05850493          	addi	s1,a0,88
    80003d44:	45850913          	addi	s2,a0,1112
    80003d48:	a021                	j	80003d50 <itrunc+0x7a>
    80003d4a:	0491                	addi	s1,s1,4
    80003d4c:	01248b63          	beq	s1,s2,80003d62 <itrunc+0x8c>
      if(a[j])
    80003d50:	408c                	lw	a1,0(s1)
    80003d52:	dde5                	beqz	a1,80003d4a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d54:	0009a503          	lw	a0,0(s3)
    80003d58:	00000097          	auipc	ra,0x0
    80003d5c:	89c080e7          	jalr	-1892(ra) # 800035f4 <bfree>
    80003d60:	b7ed                	j	80003d4a <itrunc+0x74>
    brelse(bp);
    80003d62:	8552                	mv	a0,s4
    80003d64:	fffff097          	auipc	ra,0xfffff
    80003d68:	77a080e7          	jalr	1914(ra) # 800034de <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d6c:	0809a583          	lw	a1,128(s3)
    80003d70:	0009a503          	lw	a0,0(s3)
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	880080e7          	jalr	-1920(ra) # 800035f4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d7c:	0809a023          	sw	zero,128(s3)
    80003d80:	bf51                	j	80003d14 <itrunc+0x3e>

0000000080003d82 <iput>:
{
    80003d82:	1101                	addi	sp,sp,-32
    80003d84:	ec06                	sd	ra,24(sp)
    80003d86:	e822                	sd	s0,16(sp)
    80003d88:	e426                	sd	s1,8(sp)
    80003d8a:	e04a                	sd	s2,0(sp)
    80003d8c:	1000                	addi	s0,sp,32
    80003d8e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d90:	0001c517          	auipc	a0,0x1c
    80003d94:	0f850513          	addi	a0,a0,248 # 8001fe88 <itable>
    80003d98:	ffffd097          	auipc	ra,0xffffd
    80003d9c:	e3e080e7          	jalr	-450(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003da0:	4498                	lw	a4,8(s1)
    80003da2:	4785                	li	a5,1
    80003da4:	02f70363          	beq	a4,a5,80003dca <iput+0x48>
  ip->ref--;
    80003da8:	449c                	lw	a5,8(s1)
    80003daa:	37fd                	addiw	a5,a5,-1
    80003dac:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dae:	0001c517          	auipc	a0,0x1c
    80003db2:	0da50513          	addi	a0,a0,218 # 8001fe88 <itable>
    80003db6:	ffffd097          	auipc	ra,0xffffd
    80003dba:	ed4080e7          	jalr	-300(ra) # 80000c8a <release>
}
    80003dbe:	60e2                	ld	ra,24(sp)
    80003dc0:	6442                	ld	s0,16(sp)
    80003dc2:	64a2                	ld	s1,8(sp)
    80003dc4:	6902                	ld	s2,0(sp)
    80003dc6:	6105                	addi	sp,sp,32
    80003dc8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dca:	40bc                	lw	a5,64(s1)
    80003dcc:	dff1                	beqz	a5,80003da8 <iput+0x26>
    80003dce:	04a49783          	lh	a5,74(s1)
    80003dd2:	fbf9                	bnez	a5,80003da8 <iput+0x26>
    acquiresleep(&ip->lock);
    80003dd4:	01048913          	addi	s2,s1,16
    80003dd8:	854a                	mv	a0,s2
    80003dda:	00001097          	auipc	ra,0x1
    80003dde:	aa8080e7          	jalr	-1368(ra) # 80004882 <acquiresleep>
    release(&itable.lock);
    80003de2:	0001c517          	auipc	a0,0x1c
    80003de6:	0a650513          	addi	a0,a0,166 # 8001fe88 <itable>
    80003dea:	ffffd097          	auipc	ra,0xffffd
    80003dee:	ea0080e7          	jalr	-352(ra) # 80000c8a <release>
    itrunc(ip);
    80003df2:	8526                	mv	a0,s1
    80003df4:	00000097          	auipc	ra,0x0
    80003df8:	ee2080e7          	jalr	-286(ra) # 80003cd6 <itrunc>
    ip->type = 0;
    80003dfc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e00:	8526                	mv	a0,s1
    80003e02:	00000097          	auipc	ra,0x0
    80003e06:	cfc080e7          	jalr	-772(ra) # 80003afe <iupdate>
    ip->valid = 0;
    80003e0a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e0e:	854a                	mv	a0,s2
    80003e10:	00001097          	auipc	ra,0x1
    80003e14:	ac8080e7          	jalr	-1336(ra) # 800048d8 <releasesleep>
    acquire(&itable.lock);
    80003e18:	0001c517          	auipc	a0,0x1c
    80003e1c:	07050513          	addi	a0,a0,112 # 8001fe88 <itable>
    80003e20:	ffffd097          	auipc	ra,0xffffd
    80003e24:	db6080e7          	jalr	-586(ra) # 80000bd6 <acquire>
    80003e28:	b741                	j	80003da8 <iput+0x26>

0000000080003e2a <iunlockput>:
{
    80003e2a:	1101                	addi	sp,sp,-32
    80003e2c:	ec06                	sd	ra,24(sp)
    80003e2e:	e822                	sd	s0,16(sp)
    80003e30:	e426                	sd	s1,8(sp)
    80003e32:	1000                	addi	s0,sp,32
    80003e34:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e36:	00000097          	auipc	ra,0x0
    80003e3a:	e54080e7          	jalr	-428(ra) # 80003c8a <iunlock>
  iput(ip);
    80003e3e:	8526                	mv	a0,s1
    80003e40:	00000097          	auipc	ra,0x0
    80003e44:	f42080e7          	jalr	-190(ra) # 80003d82 <iput>
}
    80003e48:	60e2                	ld	ra,24(sp)
    80003e4a:	6442                	ld	s0,16(sp)
    80003e4c:	64a2                	ld	s1,8(sp)
    80003e4e:	6105                	addi	sp,sp,32
    80003e50:	8082                	ret

0000000080003e52 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e52:	1141                	addi	sp,sp,-16
    80003e54:	e422                	sd	s0,8(sp)
    80003e56:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e58:	411c                	lw	a5,0(a0)
    80003e5a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e5c:	415c                	lw	a5,4(a0)
    80003e5e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e60:	04451783          	lh	a5,68(a0)
    80003e64:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e68:	04a51783          	lh	a5,74(a0)
    80003e6c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e70:	04c56783          	lwu	a5,76(a0)
    80003e74:	e99c                	sd	a5,16(a1)
}
    80003e76:	6422                	ld	s0,8(sp)
    80003e78:	0141                	addi	sp,sp,16
    80003e7a:	8082                	ret

0000000080003e7c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e7c:	457c                	lw	a5,76(a0)
    80003e7e:	0ed7e963          	bltu	a5,a3,80003f70 <readi+0xf4>
{
    80003e82:	7159                	addi	sp,sp,-112
    80003e84:	f486                	sd	ra,104(sp)
    80003e86:	f0a2                	sd	s0,96(sp)
    80003e88:	eca6                	sd	s1,88(sp)
    80003e8a:	e8ca                	sd	s2,80(sp)
    80003e8c:	e4ce                	sd	s3,72(sp)
    80003e8e:	e0d2                	sd	s4,64(sp)
    80003e90:	fc56                	sd	s5,56(sp)
    80003e92:	f85a                	sd	s6,48(sp)
    80003e94:	f45e                	sd	s7,40(sp)
    80003e96:	f062                	sd	s8,32(sp)
    80003e98:	ec66                	sd	s9,24(sp)
    80003e9a:	e86a                	sd	s10,16(sp)
    80003e9c:	e46e                	sd	s11,8(sp)
    80003e9e:	1880                	addi	s0,sp,112
    80003ea0:	8b2a                	mv	s6,a0
    80003ea2:	8bae                	mv	s7,a1
    80003ea4:	8a32                	mv	s4,a2
    80003ea6:	84b6                	mv	s1,a3
    80003ea8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003eaa:	9f35                	addw	a4,a4,a3
    return 0;
    80003eac:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003eae:	0ad76063          	bltu	a4,a3,80003f4e <readi+0xd2>
  if(off + n > ip->size)
    80003eb2:	00e7f463          	bgeu	a5,a4,80003eba <readi+0x3e>
    n = ip->size - off;
    80003eb6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003eba:	0a0a8963          	beqz	s5,80003f6c <readi+0xf0>
    80003ebe:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ec0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ec4:	5c7d                	li	s8,-1
    80003ec6:	a82d                	j	80003f00 <readi+0x84>
    80003ec8:	020d1d93          	slli	s11,s10,0x20
    80003ecc:	020ddd93          	srli	s11,s11,0x20
    80003ed0:	05890793          	addi	a5,s2,88
    80003ed4:	86ee                	mv	a3,s11
    80003ed6:	963e                	add	a2,a2,a5
    80003ed8:	85d2                	mv	a1,s4
    80003eda:	855e                	mv	a0,s7
    80003edc:	fffff097          	auipc	ra,0xfffff
    80003ee0:	b00080e7          	jalr	-1280(ra) # 800029dc <either_copyout>
    80003ee4:	05850d63          	beq	a0,s8,80003f3e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ee8:	854a                	mv	a0,s2
    80003eea:	fffff097          	auipc	ra,0xfffff
    80003eee:	5f4080e7          	jalr	1524(ra) # 800034de <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ef2:	013d09bb          	addw	s3,s10,s3
    80003ef6:	009d04bb          	addw	s1,s10,s1
    80003efa:	9a6e                	add	s4,s4,s11
    80003efc:	0559f763          	bgeu	s3,s5,80003f4a <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f00:	00a4d59b          	srliw	a1,s1,0xa
    80003f04:	855a                	mv	a0,s6
    80003f06:	00000097          	auipc	ra,0x0
    80003f0a:	8a2080e7          	jalr	-1886(ra) # 800037a8 <bmap>
    80003f0e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f12:	cd85                	beqz	a1,80003f4a <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f14:	000b2503          	lw	a0,0(s6)
    80003f18:	fffff097          	auipc	ra,0xfffff
    80003f1c:	496080e7          	jalr	1174(ra) # 800033ae <bread>
    80003f20:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f22:	3ff4f613          	andi	a2,s1,1023
    80003f26:	40cc87bb          	subw	a5,s9,a2
    80003f2a:	413a873b          	subw	a4,s5,s3
    80003f2e:	8d3e                	mv	s10,a5
    80003f30:	2781                	sext.w	a5,a5
    80003f32:	0007069b          	sext.w	a3,a4
    80003f36:	f8f6f9e3          	bgeu	a3,a5,80003ec8 <readi+0x4c>
    80003f3a:	8d3a                	mv	s10,a4
    80003f3c:	b771                	j	80003ec8 <readi+0x4c>
      brelse(bp);
    80003f3e:	854a                	mv	a0,s2
    80003f40:	fffff097          	auipc	ra,0xfffff
    80003f44:	59e080e7          	jalr	1438(ra) # 800034de <brelse>
      tot = -1;
    80003f48:	59fd                	li	s3,-1
  }
  return tot;
    80003f4a:	0009851b          	sext.w	a0,s3
}
    80003f4e:	70a6                	ld	ra,104(sp)
    80003f50:	7406                	ld	s0,96(sp)
    80003f52:	64e6                	ld	s1,88(sp)
    80003f54:	6946                	ld	s2,80(sp)
    80003f56:	69a6                	ld	s3,72(sp)
    80003f58:	6a06                	ld	s4,64(sp)
    80003f5a:	7ae2                	ld	s5,56(sp)
    80003f5c:	7b42                	ld	s6,48(sp)
    80003f5e:	7ba2                	ld	s7,40(sp)
    80003f60:	7c02                	ld	s8,32(sp)
    80003f62:	6ce2                	ld	s9,24(sp)
    80003f64:	6d42                	ld	s10,16(sp)
    80003f66:	6da2                	ld	s11,8(sp)
    80003f68:	6165                	addi	sp,sp,112
    80003f6a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f6c:	89d6                	mv	s3,s5
    80003f6e:	bff1                	j	80003f4a <readi+0xce>
    return 0;
    80003f70:	4501                	li	a0,0
}
    80003f72:	8082                	ret

0000000080003f74 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f74:	457c                	lw	a5,76(a0)
    80003f76:	10d7e863          	bltu	a5,a3,80004086 <writei+0x112>
{
    80003f7a:	7159                	addi	sp,sp,-112
    80003f7c:	f486                	sd	ra,104(sp)
    80003f7e:	f0a2                	sd	s0,96(sp)
    80003f80:	eca6                	sd	s1,88(sp)
    80003f82:	e8ca                	sd	s2,80(sp)
    80003f84:	e4ce                	sd	s3,72(sp)
    80003f86:	e0d2                	sd	s4,64(sp)
    80003f88:	fc56                	sd	s5,56(sp)
    80003f8a:	f85a                	sd	s6,48(sp)
    80003f8c:	f45e                	sd	s7,40(sp)
    80003f8e:	f062                	sd	s8,32(sp)
    80003f90:	ec66                	sd	s9,24(sp)
    80003f92:	e86a                	sd	s10,16(sp)
    80003f94:	e46e                	sd	s11,8(sp)
    80003f96:	1880                	addi	s0,sp,112
    80003f98:	8aaa                	mv	s5,a0
    80003f9a:	8bae                	mv	s7,a1
    80003f9c:	8a32                	mv	s4,a2
    80003f9e:	8936                	mv	s2,a3
    80003fa0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fa2:	00e687bb          	addw	a5,a3,a4
    80003fa6:	0ed7e263          	bltu	a5,a3,8000408a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003faa:	00043737          	lui	a4,0x43
    80003fae:	0ef76063          	bltu	a4,a5,8000408e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fb2:	0c0b0863          	beqz	s6,80004082 <writei+0x10e>
    80003fb6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fb8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003fbc:	5c7d                	li	s8,-1
    80003fbe:	a091                	j	80004002 <writei+0x8e>
    80003fc0:	020d1d93          	slli	s11,s10,0x20
    80003fc4:	020ddd93          	srli	s11,s11,0x20
    80003fc8:	05848793          	addi	a5,s1,88
    80003fcc:	86ee                	mv	a3,s11
    80003fce:	8652                	mv	a2,s4
    80003fd0:	85de                	mv	a1,s7
    80003fd2:	953e                	add	a0,a0,a5
    80003fd4:	fffff097          	auipc	ra,0xfffff
    80003fd8:	a5e080e7          	jalr	-1442(ra) # 80002a32 <either_copyin>
    80003fdc:	07850263          	beq	a0,s8,80004040 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003fe0:	8526                	mv	a0,s1
    80003fe2:	00000097          	auipc	ra,0x0
    80003fe6:	780080e7          	jalr	1920(ra) # 80004762 <log_write>
    brelse(bp);
    80003fea:	8526                	mv	a0,s1
    80003fec:	fffff097          	auipc	ra,0xfffff
    80003ff0:	4f2080e7          	jalr	1266(ra) # 800034de <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ff4:	013d09bb          	addw	s3,s10,s3
    80003ff8:	012d093b          	addw	s2,s10,s2
    80003ffc:	9a6e                	add	s4,s4,s11
    80003ffe:	0569f663          	bgeu	s3,s6,8000404a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004002:	00a9559b          	srliw	a1,s2,0xa
    80004006:	8556                	mv	a0,s5
    80004008:	fffff097          	auipc	ra,0xfffff
    8000400c:	7a0080e7          	jalr	1952(ra) # 800037a8 <bmap>
    80004010:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004014:	c99d                	beqz	a1,8000404a <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004016:	000aa503          	lw	a0,0(s5)
    8000401a:	fffff097          	auipc	ra,0xfffff
    8000401e:	394080e7          	jalr	916(ra) # 800033ae <bread>
    80004022:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004024:	3ff97513          	andi	a0,s2,1023
    80004028:	40ac87bb          	subw	a5,s9,a0
    8000402c:	413b073b          	subw	a4,s6,s3
    80004030:	8d3e                	mv	s10,a5
    80004032:	2781                	sext.w	a5,a5
    80004034:	0007069b          	sext.w	a3,a4
    80004038:	f8f6f4e3          	bgeu	a3,a5,80003fc0 <writei+0x4c>
    8000403c:	8d3a                	mv	s10,a4
    8000403e:	b749                	j	80003fc0 <writei+0x4c>
      brelse(bp);
    80004040:	8526                	mv	a0,s1
    80004042:	fffff097          	auipc	ra,0xfffff
    80004046:	49c080e7          	jalr	1180(ra) # 800034de <brelse>
  }

  if(off > ip->size)
    8000404a:	04caa783          	lw	a5,76(s5)
    8000404e:	0127f463          	bgeu	a5,s2,80004056 <writei+0xe2>
    ip->size = off;
    80004052:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004056:	8556                	mv	a0,s5
    80004058:	00000097          	auipc	ra,0x0
    8000405c:	aa6080e7          	jalr	-1370(ra) # 80003afe <iupdate>

  return tot;
    80004060:	0009851b          	sext.w	a0,s3
}
    80004064:	70a6                	ld	ra,104(sp)
    80004066:	7406                	ld	s0,96(sp)
    80004068:	64e6                	ld	s1,88(sp)
    8000406a:	6946                	ld	s2,80(sp)
    8000406c:	69a6                	ld	s3,72(sp)
    8000406e:	6a06                	ld	s4,64(sp)
    80004070:	7ae2                	ld	s5,56(sp)
    80004072:	7b42                	ld	s6,48(sp)
    80004074:	7ba2                	ld	s7,40(sp)
    80004076:	7c02                	ld	s8,32(sp)
    80004078:	6ce2                	ld	s9,24(sp)
    8000407a:	6d42                	ld	s10,16(sp)
    8000407c:	6da2                	ld	s11,8(sp)
    8000407e:	6165                	addi	sp,sp,112
    80004080:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004082:	89da                	mv	s3,s6
    80004084:	bfc9                	j	80004056 <writei+0xe2>
    return -1;
    80004086:	557d                	li	a0,-1
}
    80004088:	8082                	ret
    return -1;
    8000408a:	557d                	li	a0,-1
    8000408c:	bfe1                	j	80004064 <writei+0xf0>
    return -1;
    8000408e:	557d                	li	a0,-1
    80004090:	bfd1                	j	80004064 <writei+0xf0>

0000000080004092 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004092:	1141                	addi	sp,sp,-16
    80004094:	e406                	sd	ra,8(sp)
    80004096:	e022                	sd	s0,0(sp)
    80004098:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000409a:	4639                	li	a2,14
    8000409c:	ffffd097          	auipc	ra,0xffffd
    800040a0:	d06080e7          	jalr	-762(ra) # 80000da2 <strncmp>
}
    800040a4:	60a2                	ld	ra,8(sp)
    800040a6:	6402                	ld	s0,0(sp)
    800040a8:	0141                	addi	sp,sp,16
    800040aa:	8082                	ret

00000000800040ac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040ac:	7139                	addi	sp,sp,-64
    800040ae:	fc06                	sd	ra,56(sp)
    800040b0:	f822                	sd	s0,48(sp)
    800040b2:	f426                	sd	s1,40(sp)
    800040b4:	f04a                	sd	s2,32(sp)
    800040b6:	ec4e                	sd	s3,24(sp)
    800040b8:	e852                	sd	s4,16(sp)
    800040ba:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040bc:	04451703          	lh	a4,68(a0)
    800040c0:	4785                	li	a5,1
    800040c2:	00f71a63          	bne	a4,a5,800040d6 <dirlookup+0x2a>
    800040c6:	892a                	mv	s2,a0
    800040c8:	89ae                	mv	s3,a1
    800040ca:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040cc:	457c                	lw	a5,76(a0)
    800040ce:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040d0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040d2:	e79d                	bnez	a5,80004100 <dirlookup+0x54>
    800040d4:	a8a5                	j	8000414c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800040d6:	00004517          	auipc	a0,0x4
    800040da:	56250513          	addi	a0,a0,1378 # 80008638 <syscalls+0x1b8>
    800040de:	ffffc097          	auipc	ra,0xffffc
    800040e2:	460080e7          	jalr	1120(ra) # 8000053e <panic>
      panic("dirlookup read");
    800040e6:	00004517          	auipc	a0,0x4
    800040ea:	56a50513          	addi	a0,a0,1386 # 80008650 <syscalls+0x1d0>
    800040ee:	ffffc097          	auipc	ra,0xffffc
    800040f2:	450080e7          	jalr	1104(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040f6:	24c1                	addiw	s1,s1,16
    800040f8:	04c92783          	lw	a5,76(s2)
    800040fc:	04f4f763          	bgeu	s1,a5,8000414a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004100:	4741                	li	a4,16
    80004102:	86a6                	mv	a3,s1
    80004104:	fc040613          	addi	a2,s0,-64
    80004108:	4581                	li	a1,0
    8000410a:	854a                	mv	a0,s2
    8000410c:	00000097          	auipc	ra,0x0
    80004110:	d70080e7          	jalr	-656(ra) # 80003e7c <readi>
    80004114:	47c1                	li	a5,16
    80004116:	fcf518e3          	bne	a0,a5,800040e6 <dirlookup+0x3a>
    if(de.inum == 0)
    8000411a:	fc045783          	lhu	a5,-64(s0)
    8000411e:	dfe1                	beqz	a5,800040f6 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004120:	fc240593          	addi	a1,s0,-62
    80004124:	854e                	mv	a0,s3
    80004126:	00000097          	auipc	ra,0x0
    8000412a:	f6c080e7          	jalr	-148(ra) # 80004092 <namecmp>
    8000412e:	f561                	bnez	a0,800040f6 <dirlookup+0x4a>
      if(poff)
    80004130:	000a0463          	beqz	s4,80004138 <dirlookup+0x8c>
        *poff = off;
    80004134:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004138:	fc045583          	lhu	a1,-64(s0)
    8000413c:	00092503          	lw	a0,0(s2)
    80004140:	fffff097          	auipc	ra,0xfffff
    80004144:	750080e7          	jalr	1872(ra) # 80003890 <iget>
    80004148:	a011                	j	8000414c <dirlookup+0xa0>
  return 0;
    8000414a:	4501                	li	a0,0
}
    8000414c:	70e2                	ld	ra,56(sp)
    8000414e:	7442                	ld	s0,48(sp)
    80004150:	74a2                	ld	s1,40(sp)
    80004152:	7902                	ld	s2,32(sp)
    80004154:	69e2                	ld	s3,24(sp)
    80004156:	6a42                	ld	s4,16(sp)
    80004158:	6121                	addi	sp,sp,64
    8000415a:	8082                	ret

000000008000415c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000415c:	711d                	addi	sp,sp,-96
    8000415e:	ec86                	sd	ra,88(sp)
    80004160:	e8a2                	sd	s0,80(sp)
    80004162:	e4a6                	sd	s1,72(sp)
    80004164:	e0ca                	sd	s2,64(sp)
    80004166:	fc4e                	sd	s3,56(sp)
    80004168:	f852                	sd	s4,48(sp)
    8000416a:	f456                	sd	s5,40(sp)
    8000416c:	f05a                	sd	s6,32(sp)
    8000416e:	ec5e                	sd	s7,24(sp)
    80004170:	e862                	sd	s8,16(sp)
    80004172:	e466                	sd	s9,8(sp)
    80004174:	1080                	addi	s0,sp,96
    80004176:	84aa                	mv	s1,a0
    80004178:	8aae                	mv	s5,a1
    8000417a:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000417c:	00054703          	lbu	a4,0(a0)
    80004180:	02f00793          	li	a5,47
    80004184:	02f70363          	beq	a4,a5,800041aa <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004188:	ffffe097          	auipc	ra,0xffffe
    8000418c:	bec080e7          	jalr	-1044(ra) # 80001d74 <myproc>
    80004190:	15053503          	ld	a0,336(a0)
    80004194:	00000097          	auipc	ra,0x0
    80004198:	9f6080e7          	jalr	-1546(ra) # 80003b8a <idup>
    8000419c:	89aa                	mv	s3,a0
  while(*path == '/')
    8000419e:	02f00913          	li	s2,47
  len = path - s;
    800041a2:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800041a4:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041a6:	4b85                	li	s7,1
    800041a8:	a865                	j	80004260 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800041aa:	4585                	li	a1,1
    800041ac:	4505                	li	a0,1
    800041ae:	fffff097          	auipc	ra,0xfffff
    800041b2:	6e2080e7          	jalr	1762(ra) # 80003890 <iget>
    800041b6:	89aa                	mv	s3,a0
    800041b8:	b7dd                	j	8000419e <namex+0x42>
      iunlockput(ip);
    800041ba:	854e                	mv	a0,s3
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	c6e080e7          	jalr	-914(ra) # 80003e2a <iunlockput>
      return 0;
    800041c4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800041c6:	854e                	mv	a0,s3
    800041c8:	60e6                	ld	ra,88(sp)
    800041ca:	6446                	ld	s0,80(sp)
    800041cc:	64a6                	ld	s1,72(sp)
    800041ce:	6906                	ld	s2,64(sp)
    800041d0:	79e2                	ld	s3,56(sp)
    800041d2:	7a42                	ld	s4,48(sp)
    800041d4:	7aa2                	ld	s5,40(sp)
    800041d6:	7b02                	ld	s6,32(sp)
    800041d8:	6be2                	ld	s7,24(sp)
    800041da:	6c42                	ld	s8,16(sp)
    800041dc:	6ca2                	ld	s9,8(sp)
    800041de:	6125                	addi	sp,sp,96
    800041e0:	8082                	ret
      iunlock(ip);
    800041e2:	854e                	mv	a0,s3
    800041e4:	00000097          	auipc	ra,0x0
    800041e8:	aa6080e7          	jalr	-1370(ra) # 80003c8a <iunlock>
      return ip;
    800041ec:	bfe9                	j	800041c6 <namex+0x6a>
      iunlockput(ip);
    800041ee:	854e                	mv	a0,s3
    800041f0:	00000097          	auipc	ra,0x0
    800041f4:	c3a080e7          	jalr	-966(ra) # 80003e2a <iunlockput>
      return 0;
    800041f8:	89e6                	mv	s3,s9
    800041fa:	b7f1                	j	800041c6 <namex+0x6a>
  len = path - s;
    800041fc:	40b48633          	sub	a2,s1,a1
    80004200:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004204:	099c5463          	bge	s8,s9,8000428c <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004208:	4639                	li	a2,14
    8000420a:	8552                	mv	a0,s4
    8000420c:	ffffd097          	auipc	ra,0xffffd
    80004210:	b22080e7          	jalr	-1246(ra) # 80000d2e <memmove>
  while(*path == '/')
    80004214:	0004c783          	lbu	a5,0(s1)
    80004218:	01279763          	bne	a5,s2,80004226 <namex+0xca>
    path++;
    8000421c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000421e:	0004c783          	lbu	a5,0(s1)
    80004222:	ff278de3          	beq	a5,s2,8000421c <namex+0xc0>
    ilock(ip);
    80004226:	854e                	mv	a0,s3
    80004228:	00000097          	auipc	ra,0x0
    8000422c:	9a0080e7          	jalr	-1632(ra) # 80003bc8 <ilock>
    if(ip->type != T_DIR){
    80004230:	04499783          	lh	a5,68(s3)
    80004234:	f97793e3          	bne	a5,s7,800041ba <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004238:	000a8563          	beqz	s5,80004242 <namex+0xe6>
    8000423c:	0004c783          	lbu	a5,0(s1)
    80004240:	d3cd                	beqz	a5,800041e2 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004242:	865a                	mv	a2,s6
    80004244:	85d2                	mv	a1,s4
    80004246:	854e                	mv	a0,s3
    80004248:	00000097          	auipc	ra,0x0
    8000424c:	e64080e7          	jalr	-412(ra) # 800040ac <dirlookup>
    80004250:	8caa                	mv	s9,a0
    80004252:	dd51                	beqz	a0,800041ee <namex+0x92>
    iunlockput(ip);
    80004254:	854e                	mv	a0,s3
    80004256:	00000097          	auipc	ra,0x0
    8000425a:	bd4080e7          	jalr	-1068(ra) # 80003e2a <iunlockput>
    ip = next;
    8000425e:	89e6                	mv	s3,s9
  while(*path == '/')
    80004260:	0004c783          	lbu	a5,0(s1)
    80004264:	05279763          	bne	a5,s2,800042b2 <namex+0x156>
    path++;
    80004268:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000426a:	0004c783          	lbu	a5,0(s1)
    8000426e:	ff278de3          	beq	a5,s2,80004268 <namex+0x10c>
  if(*path == 0)
    80004272:	c79d                	beqz	a5,800042a0 <namex+0x144>
    path++;
    80004274:	85a6                	mv	a1,s1
  len = path - s;
    80004276:	8cda                	mv	s9,s6
    80004278:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000427a:	01278963          	beq	a5,s2,8000428c <namex+0x130>
    8000427e:	dfbd                	beqz	a5,800041fc <namex+0xa0>
    path++;
    80004280:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004282:	0004c783          	lbu	a5,0(s1)
    80004286:	ff279ce3          	bne	a5,s2,8000427e <namex+0x122>
    8000428a:	bf8d                	j	800041fc <namex+0xa0>
    memmove(name, s, len);
    8000428c:	2601                	sext.w	a2,a2
    8000428e:	8552                	mv	a0,s4
    80004290:	ffffd097          	auipc	ra,0xffffd
    80004294:	a9e080e7          	jalr	-1378(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004298:	9cd2                	add	s9,s9,s4
    8000429a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000429e:	bf9d                	j	80004214 <namex+0xb8>
  if(nameiparent){
    800042a0:	f20a83e3          	beqz	s5,800041c6 <namex+0x6a>
    iput(ip);
    800042a4:	854e                	mv	a0,s3
    800042a6:	00000097          	auipc	ra,0x0
    800042aa:	adc080e7          	jalr	-1316(ra) # 80003d82 <iput>
    return 0;
    800042ae:	4981                	li	s3,0
    800042b0:	bf19                	j	800041c6 <namex+0x6a>
  if(*path == 0)
    800042b2:	d7fd                	beqz	a5,800042a0 <namex+0x144>
  while(*path != '/' && *path != 0)
    800042b4:	0004c783          	lbu	a5,0(s1)
    800042b8:	85a6                	mv	a1,s1
    800042ba:	b7d1                	j	8000427e <namex+0x122>

00000000800042bc <dirlink>:
{
    800042bc:	7139                	addi	sp,sp,-64
    800042be:	fc06                	sd	ra,56(sp)
    800042c0:	f822                	sd	s0,48(sp)
    800042c2:	f426                	sd	s1,40(sp)
    800042c4:	f04a                	sd	s2,32(sp)
    800042c6:	ec4e                	sd	s3,24(sp)
    800042c8:	e852                	sd	s4,16(sp)
    800042ca:	0080                	addi	s0,sp,64
    800042cc:	892a                	mv	s2,a0
    800042ce:	8a2e                	mv	s4,a1
    800042d0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042d2:	4601                	li	a2,0
    800042d4:	00000097          	auipc	ra,0x0
    800042d8:	dd8080e7          	jalr	-552(ra) # 800040ac <dirlookup>
    800042dc:	e93d                	bnez	a0,80004352 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042de:	04c92483          	lw	s1,76(s2)
    800042e2:	c49d                	beqz	s1,80004310 <dirlink+0x54>
    800042e4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042e6:	4741                	li	a4,16
    800042e8:	86a6                	mv	a3,s1
    800042ea:	fc040613          	addi	a2,s0,-64
    800042ee:	4581                	li	a1,0
    800042f0:	854a                	mv	a0,s2
    800042f2:	00000097          	auipc	ra,0x0
    800042f6:	b8a080e7          	jalr	-1142(ra) # 80003e7c <readi>
    800042fa:	47c1                	li	a5,16
    800042fc:	06f51163          	bne	a0,a5,8000435e <dirlink+0xa2>
    if(de.inum == 0)
    80004300:	fc045783          	lhu	a5,-64(s0)
    80004304:	c791                	beqz	a5,80004310 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004306:	24c1                	addiw	s1,s1,16
    80004308:	04c92783          	lw	a5,76(s2)
    8000430c:	fcf4ede3          	bltu	s1,a5,800042e6 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004310:	4639                	li	a2,14
    80004312:	85d2                	mv	a1,s4
    80004314:	fc240513          	addi	a0,s0,-62
    80004318:	ffffd097          	auipc	ra,0xffffd
    8000431c:	ac6080e7          	jalr	-1338(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004320:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004324:	4741                	li	a4,16
    80004326:	86a6                	mv	a3,s1
    80004328:	fc040613          	addi	a2,s0,-64
    8000432c:	4581                	li	a1,0
    8000432e:	854a                	mv	a0,s2
    80004330:	00000097          	auipc	ra,0x0
    80004334:	c44080e7          	jalr	-956(ra) # 80003f74 <writei>
    80004338:	1541                	addi	a0,a0,-16
    8000433a:	00a03533          	snez	a0,a0
    8000433e:	40a00533          	neg	a0,a0
}
    80004342:	70e2                	ld	ra,56(sp)
    80004344:	7442                	ld	s0,48(sp)
    80004346:	74a2                	ld	s1,40(sp)
    80004348:	7902                	ld	s2,32(sp)
    8000434a:	69e2                	ld	s3,24(sp)
    8000434c:	6a42                	ld	s4,16(sp)
    8000434e:	6121                	addi	sp,sp,64
    80004350:	8082                	ret
    iput(ip);
    80004352:	00000097          	auipc	ra,0x0
    80004356:	a30080e7          	jalr	-1488(ra) # 80003d82 <iput>
    return -1;
    8000435a:	557d                	li	a0,-1
    8000435c:	b7dd                	j	80004342 <dirlink+0x86>
      panic("dirlink read");
    8000435e:	00004517          	auipc	a0,0x4
    80004362:	30250513          	addi	a0,a0,770 # 80008660 <syscalls+0x1e0>
    80004366:	ffffc097          	auipc	ra,0xffffc
    8000436a:	1d8080e7          	jalr	472(ra) # 8000053e <panic>

000000008000436e <namei>:

struct inode*
namei(char *path)
{
    8000436e:	1101                	addi	sp,sp,-32
    80004370:	ec06                	sd	ra,24(sp)
    80004372:	e822                	sd	s0,16(sp)
    80004374:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004376:	fe040613          	addi	a2,s0,-32
    8000437a:	4581                	li	a1,0
    8000437c:	00000097          	auipc	ra,0x0
    80004380:	de0080e7          	jalr	-544(ra) # 8000415c <namex>
}
    80004384:	60e2                	ld	ra,24(sp)
    80004386:	6442                	ld	s0,16(sp)
    80004388:	6105                	addi	sp,sp,32
    8000438a:	8082                	ret

000000008000438c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000438c:	1141                	addi	sp,sp,-16
    8000438e:	e406                	sd	ra,8(sp)
    80004390:	e022                	sd	s0,0(sp)
    80004392:	0800                	addi	s0,sp,16
    80004394:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004396:	4585                	li	a1,1
    80004398:	00000097          	auipc	ra,0x0
    8000439c:	dc4080e7          	jalr	-572(ra) # 8000415c <namex>
}
    800043a0:	60a2                	ld	ra,8(sp)
    800043a2:	6402                	ld	s0,0(sp)
    800043a4:	0141                	addi	sp,sp,16
    800043a6:	8082                	ret

00000000800043a8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043a8:	1101                	addi	sp,sp,-32
    800043aa:	ec06                	sd	ra,24(sp)
    800043ac:	e822                	sd	s0,16(sp)
    800043ae:	e426                	sd	s1,8(sp)
    800043b0:	e04a                	sd	s2,0(sp)
    800043b2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043b4:	0001d917          	auipc	s2,0x1d
    800043b8:	57c90913          	addi	s2,s2,1404 # 80021930 <log>
    800043bc:	01892583          	lw	a1,24(s2)
    800043c0:	02892503          	lw	a0,40(s2)
    800043c4:	fffff097          	auipc	ra,0xfffff
    800043c8:	fea080e7          	jalr	-22(ra) # 800033ae <bread>
    800043cc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043ce:	02c92683          	lw	a3,44(s2)
    800043d2:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800043d4:	02d05763          	blez	a3,80004402 <write_head+0x5a>
    800043d8:	0001d797          	auipc	a5,0x1d
    800043dc:	58878793          	addi	a5,a5,1416 # 80021960 <log+0x30>
    800043e0:	05c50713          	addi	a4,a0,92
    800043e4:	36fd                	addiw	a3,a3,-1
    800043e6:	1682                	slli	a3,a3,0x20
    800043e8:	9281                	srli	a3,a3,0x20
    800043ea:	068a                	slli	a3,a3,0x2
    800043ec:	0001d617          	auipc	a2,0x1d
    800043f0:	57860613          	addi	a2,a2,1400 # 80021964 <log+0x34>
    800043f4:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800043f6:	4390                	lw	a2,0(a5)
    800043f8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043fa:	0791                	addi	a5,a5,4
    800043fc:	0711                	addi	a4,a4,4
    800043fe:	fed79ce3          	bne	a5,a3,800043f6 <write_head+0x4e>
  }
  bwrite(buf);
    80004402:	8526                	mv	a0,s1
    80004404:	fffff097          	auipc	ra,0xfffff
    80004408:	09c080e7          	jalr	156(ra) # 800034a0 <bwrite>
  brelse(buf);
    8000440c:	8526                	mv	a0,s1
    8000440e:	fffff097          	auipc	ra,0xfffff
    80004412:	0d0080e7          	jalr	208(ra) # 800034de <brelse>
}
    80004416:	60e2                	ld	ra,24(sp)
    80004418:	6442                	ld	s0,16(sp)
    8000441a:	64a2                	ld	s1,8(sp)
    8000441c:	6902                	ld	s2,0(sp)
    8000441e:	6105                	addi	sp,sp,32
    80004420:	8082                	ret

0000000080004422 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004422:	0001d797          	auipc	a5,0x1d
    80004426:	53a7a783          	lw	a5,1338(a5) # 8002195c <log+0x2c>
    8000442a:	0af05d63          	blez	a5,800044e4 <install_trans+0xc2>
{
    8000442e:	7139                	addi	sp,sp,-64
    80004430:	fc06                	sd	ra,56(sp)
    80004432:	f822                	sd	s0,48(sp)
    80004434:	f426                	sd	s1,40(sp)
    80004436:	f04a                	sd	s2,32(sp)
    80004438:	ec4e                	sd	s3,24(sp)
    8000443a:	e852                	sd	s4,16(sp)
    8000443c:	e456                	sd	s5,8(sp)
    8000443e:	e05a                	sd	s6,0(sp)
    80004440:	0080                	addi	s0,sp,64
    80004442:	8b2a                	mv	s6,a0
    80004444:	0001da97          	auipc	s5,0x1d
    80004448:	51ca8a93          	addi	s5,s5,1308 # 80021960 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000444c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000444e:	0001d997          	auipc	s3,0x1d
    80004452:	4e298993          	addi	s3,s3,1250 # 80021930 <log>
    80004456:	a00d                	j	80004478 <install_trans+0x56>
    brelse(lbuf);
    80004458:	854a                	mv	a0,s2
    8000445a:	fffff097          	auipc	ra,0xfffff
    8000445e:	084080e7          	jalr	132(ra) # 800034de <brelse>
    brelse(dbuf);
    80004462:	8526                	mv	a0,s1
    80004464:	fffff097          	auipc	ra,0xfffff
    80004468:	07a080e7          	jalr	122(ra) # 800034de <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000446c:	2a05                	addiw	s4,s4,1
    8000446e:	0a91                	addi	s5,s5,4
    80004470:	02c9a783          	lw	a5,44(s3)
    80004474:	04fa5e63          	bge	s4,a5,800044d0 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004478:	0189a583          	lw	a1,24(s3)
    8000447c:	014585bb          	addw	a1,a1,s4
    80004480:	2585                	addiw	a1,a1,1
    80004482:	0289a503          	lw	a0,40(s3)
    80004486:	fffff097          	auipc	ra,0xfffff
    8000448a:	f28080e7          	jalr	-216(ra) # 800033ae <bread>
    8000448e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004490:	000aa583          	lw	a1,0(s5)
    80004494:	0289a503          	lw	a0,40(s3)
    80004498:	fffff097          	auipc	ra,0xfffff
    8000449c:	f16080e7          	jalr	-234(ra) # 800033ae <bread>
    800044a0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044a2:	40000613          	li	a2,1024
    800044a6:	05890593          	addi	a1,s2,88
    800044aa:	05850513          	addi	a0,a0,88
    800044ae:	ffffd097          	auipc	ra,0xffffd
    800044b2:	880080e7          	jalr	-1920(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800044b6:	8526                	mv	a0,s1
    800044b8:	fffff097          	auipc	ra,0xfffff
    800044bc:	fe8080e7          	jalr	-24(ra) # 800034a0 <bwrite>
    if(recovering == 0)
    800044c0:	f80b1ce3          	bnez	s6,80004458 <install_trans+0x36>
      bunpin(dbuf);
    800044c4:	8526                	mv	a0,s1
    800044c6:	fffff097          	auipc	ra,0xfffff
    800044ca:	0f2080e7          	jalr	242(ra) # 800035b8 <bunpin>
    800044ce:	b769                	j	80004458 <install_trans+0x36>
}
    800044d0:	70e2                	ld	ra,56(sp)
    800044d2:	7442                	ld	s0,48(sp)
    800044d4:	74a2                	ld	s1,40(sp)
    800044d6:	7902                	ld	s2,32(sp)
    800044d8:	69e2                	ld	s3,24(sp)
    800044da:	6a42                	ld	s4,16(sp)
    800044dc:	6aa2                	ld	s5,8(sp)
    800044de:	6b02                	ld	s6,0(sp)
    800044e0:	6121                	addi	sp,sp,64
    800044e2:	8082                	ret
    800044e4:	8082                	ret

00000000800044e6 <initlog>:
{
    800044e6:	7179                	addi	sp,sp,-48
    800044e8:	f406                	sd	ra,40(sp)
    800044ea:	f022                	sd	s0,32(sp)
    800044ec:	ec26                	sd	s1,24(sp)
    800044ee:	e84a                	sd	s2,16(sp)
    800044f0:	e44e                	sd	s3,8(sp)
    800044f2:	1800                	addi	s0,sp,48
    800044f4:	892a                	mv	s2,a0
    800044f6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044f8:	0001d497          	auipc	s1,0x1d
    800044fc:	43848493          	addi	s1,s1,1080 # 80021930 <log>
    80004500:	00004597          	auipc	a1,0x4
    80004504:	17058593          	addi	a1,a1,368 # 80008670 <syscalls+0x1f0>
    80004508:	8526                	mv	a0,s1
    8000450a:	ffffc097          	auipc	ra,0xffffc
    8000450e:	63c080e7          	jalr	1596(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004512:	0149a583          	lw	a1,20(s3)
    80004516:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004518:	0109a783          	lw	a5,16(s3)
    8000451c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000451e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004522:	854a                	mv	a0,s2
    80004524:	fffff097          	auipc	ra,0xfffff
    80004528:	e8a080e7          	jalr	-374(ra) # 800033ae <bread>
  log.lh.n = lh->n;
    8000452c:	4d34                	lw	a3,88(a0)
    8000452e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004530:	02d05563          	blez	a3,8000455a <initlog+0x74>
    80004534:	05c50793          	addi	a5,a0,92
    80004538:	0001d717          	auipc	a4,0x1d
    8000453c:	42870713          	addi	a4,a4,1064 # 80021960 <log+0x30>
    80004540:	36fd                	addiw	a3,a3,-1
    80004542:	1682                	slli	a3,a3,0x20
    80004544:	9281                	srli	a3,a3,0x20
    80004546:	068a                	slli	a3,a3,0x2
    80004548:	06050613          	addi	a2,a0,96
    8000454c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000454e:	4390                	lw	a2,0(a5)
    80004550:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004552:	0791                	addi	a5,a5,4
    80004554:	0711                	addi	a4,a4,4
    80004556:	fed79ce3          	bne	a5,a3,8000454e <initlog+0x68>
  brelse(buf);
    8000455a:	fffff097          	auipc	ra,0xfffff
    8000455e:	f84080e7          	jalr	-124(ra) # 800034de <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004562:	4505                	li	a0,1
    80004564:	00000097          	auipc	ra,0x0
    80004568:	ebe080e7          	jalr	-322(ra) # 80004422 <install_trans>
  log.lh.n = 0;
    8000456c:	0001d797          	auipc	a5,0x1d
    80004570:	3e07a823          	sw	zero,1008(a5) # 8002195c <log+0x2c>
  write_head(); // clear the log
    80004574:	00000097          	auipc	ra,0x0
    80004578:	e34080e7          	jalr	-460(ra) # 800043a8 <write_head>
}
    8000457c:	70a2                	ld	ra,40(sp)
    8000457e:	7402                	ld	s0,32(sp)
    80004580:	64e2                	ld	s1,24(sp)
    80004582:	6942                	ld	s2,16(sp)
    80004584:	69a2                	ld	s3,8(sp)
    80004586:	6145                	addi	sp,sp,48
    80004588:	8082                	ret

000000008000458a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000458a:	1101                	addi	sp,sp,-32
    8000458c:	ec06                	sd	ra,24(sp)
    8000458e:	e822                	sd	s0,16(sp)
    80004590:	e426                	sd	s1,8(sp)
    80004592:	e04a                	sd	s2,0(sp)
    80004594:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004596:	0001d517          	auipc	a0,0x1d
    8000459a:	39a50513          	addi	a0,a0,922 # 80021930 <log>
    8000459e:	ffffc097          	auipc	ra,0xffffc
    800045a2:	638080e7          	jalr	1592(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800045a6:	0001d497          	auipc	s1,0x1d
    800045aa:	38a48493          	addi	s1,s1,906 # 80021930 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045ae:	4979                	li	s2,30
    800045b0:	a039                	j	800045be <begin_op+0x34>
      sleep(&log, &log.lock);
    800045b2:	85a6                	mv	a1,s1
    800045b4:	8526                	mv	a0,s1
    800045b6:	ffffe097          	auipc	ra,0xffffe
    800045ba:	fc8080e7          	jalr	-56(ra) # 8000257e <sleep>
    if(log.committing){
    800045be:	50dc                	lw	a5,36(s1)
    800045c0:	fbed                	bnez	a5,800045b2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045c2:	509c                	lw	a5,32(s1)
    800045c4:	0017871b          	addiw	a4,a5,1
    800045c8:	0007069b          	sext.w	a3,a4
    800045cc:	0027179b          	slliw	a5,a4,0x2
    800045d0:	9fb9                	addw	a5,a5,a4
    800045d2:	0017979b          	slliw	a5,a5,0x1
    800045d6:	54d8                	lw	a4,44(s1)
    800045d8:	9fb9                	addw	a5,a5,a4
    800045da:	00f95963          	bge	s2,a5,800045ec <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800045de:	85a6                	mv	a1,s1
    800045e0:	8526                	mv	a0,s1
    800045e2:	ffffe097          	auipc	ra,0xffffe
    800045e6:	f9c080e7          	jalr	-100(ra) # 8000257e <sleep>
    800045ea:	bfd1                	j	800045be <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800045ec:	0001d517          	auipc	a0,0x1d
    800045f0:	34450513          	addi	a0,a0,836 # 80021930 <log>
    800045f4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800045f6:	ffffc097          	auipc	ra,0xffffc
    800045fa:	694080e7          	jalr	1684(ra) # 80000c8a <release>
      break;
    }
  }
}
    800045fe:	60e2                	ld	ra,24(sp)
    80004600:	6442                	ld	s0,16(sp)
    80004602:	64a2                	ld	s1,8(sp)
    80004604:	6902                	ld	s2,0(sp)
    80004606:	6105                	addi	sp,sp,32
    80004608:	8082                	ret

000000008000460a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000460a:	7139                	addi	sp,sp,-64
    8000460c:	fc06                	sd	ra,56(sp)
    8000460e:	f822                	sd	s0,48(sp)
    80004610:	f426                	sd	s1,40(sp)
    80004612:	f04a                	sd	s2,32(sp)
    80004614:	ec4e                	sd	s3,24(sp)
    80004616:	e852                	sd	s4,16(sp)
    80004618:	e456                	sd	s5,8(sp)
    8000461a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000461c:	0001d497          	auipc	s1,0x1d
    80004620:	31448493          	addi	s1,s1,788 # 80021930 <log>
    80004624:	8526                	mv	a0,s1
    80004626:	ffffc097          	auipc	ra,0xffffc
    8000462a:	5b0080e7          	jalr	1456(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000462e:	509c                	lw	a5,32(s1)
    80004630:	37fd                	addiw	a5,a5,-1
    80004632:	0007891b          	sext.w	s2,a5
    80004636:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004638:	50dc                	lw	a5,36(s1)
    8000463a:	e7b9                	bnez	a5,80004688 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000463c:	04091e63          	bnez	s2,80004698 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004640:	0001d497          	auipc	s1,0x1d
    80004644:	2f048493          	addi	s1,s1,752 # 80021930 <log>
    80004648:	4785                	li	a5,1
    8000464a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000464c:	8526                	mv	a0,s1
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	63c080e7          	jalr	1596(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004656:	54dc                	lw	a5,44(s1)
    80004658:	06f04763          	bgtz	a5,800046c6 <end_op+0xbc>
    acquire(&log.lock);
    8000465c:	0001d497          	auipc	s1,0x1d
    80004660:	2d448493          	addi	s1,s1,724 # 80021930 <log>
    80004664:	8526                	mv	a0,s1
    80004666:	ffffc097          	auipc	ra,0xffffc
    8000466a:	570080e7          	jalr	1392(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000466e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004672:	8526                	mv	a0,s1
    80004674:	ffffe097          	auipc	ra,0xffffe
    80004678:	f6e080e7          	jalr	-146(ra) # 800025e2 <wakeup>
    release(&log.lock);
    8000467c:	8526                	mv	a0,s1
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	60c080e7          	jalr	1548(ra) # 80000c8a <release>
}
    80004686:	a03d                	j	800046b4 <end_op+0xaa>
    panic("log.committing");
    80004688:	00004517          	auipc	a0,0x4
    8000468c:	ff050513          	addi	a0,a0,-16 # 80008678 <syscalls+0x1f8>
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	eae080e7          	jalr	-338(ra) # 8000053e <panic>
    wakeup(&log);
    80004698:	0001d497          	auipc	s1,0x1d
    8000469c:	29848493          	addi	s1,s1,664 # 80021930 <log>
    800046a0:	8526                	mv	a0,s1
    800046a2:	ffffe097          	auipc	ra,0xffffe
    800046a6:	f40080e7          	jalr	-192(ra) # 800025e2 <wakeup>
  release(&log.lock);
    800046aa:	8526                	mv	a0,s1
    800046ac:	ffffc097          	auipc	ra,0xffffc
    800046b0:	5de080e7          	jalr	1502(ra) # 80000c8a <release>
}
    800046b4:	70e2                	ld	ra,56(sp)
    800046b6:	7442                	ld	s0,48(sp)
    800046b8:	74a2                	ld	s1,40(sp)
    800046ba:	7902                	ld	s2,32(sp)
    800046bc:	69e2                	ld	s3,24(sp)
    800046be:	6a42                	ld	s4,16(sp)
    800046c0:	6aa2                	ld	s5,8(sp)
    800046c2:	6121                	addi	sp,sp,64
    800046c4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800046c6:	0001da97          	auipc	s5,0x1d
    800046ca:	29aa8a93          	addi	s5,s5,666 # 80021960 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046ce:	0001da17          	auipc	s4,0x1d
    800046d2:	262a0a13          	addi	s4,s4,610 # 80021930 <log>
    800046d6:	018a2583          	lw	a1,24(s4)
    800046da:	012585bb          	addw	a1,a1,s2
    800046de:	2585                	addiw	a1,a1,1
    800046e0:	028a2503          	lw	a0,40(s4)
    800046e4:	fffff097          	auipc	ra,0xfffff
    800046e8:	cca080e7          	jalr	-822(ra) # 800033ae <bread>
    800046ec:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800046ee:	000aa583          	lw	a1,0(s5)
    800046f2:	028a2503          	lw	a0,40(s4)
    800046f6:	fffff097          	auipc	ra,0xfffff
    800046fa:	cb8080e7          	jalr	-840(ra) # 800033ae <bread>
    800046fe:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004700:	40000613          	li	a2,1024
    80004704:	05850593          	addi	a1,a0,88
    80004708:	05848513          	addi	a0,s1,88
    8000470c:	ffffc097          	auipc	ra,0xffffc
    80004710:	622080e7          	jalr	1570(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004714:	8526                	mv	a0,s1
    80004716:	fffff097          	auipc	ra,0xfffff
    8000471a:	d8a080e7          	jalr	-630(ra) # 800034a0 <bwrite>
    brelse(from);
    8000471e:	854e                	mv	a0,s3
    80004720:	fffff097          	auipc	ra,0xfffff
    80004724:	dbe080e7          	jalr	-578(ra) # 800034de <brelse>
    brelse(to);
    80004728:	8526                	mv	a0,s1
    8000472a:	fffff097          	auipc	ra,0xfffff
    8000472e:	db4080e7          	jalr	-588(ra) # 800034de <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004732:	2905                	addiw	s2,s2,1
    80004734:	0a91                	addi	s5,s5,4
    80004736:	02ca2783          	lw	a5,44(s4)
    8000473a:	f8f94ee3          	blt	s2,a5,800046d6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000473e:	00000097          	auipc	ra,0x0
    80004742:	c6a080e7          	jalr	-918(ra) # 800043a8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004746:	4501                	li	a0,0
    80004748:	00000097          	auipc	ra,0x0
    8000474c:	cda080e7          	jalr	-806(ra) # 80004422 <install_trans>
    log.lh.n = 0;
    80004750:	0001d797          	auipc	a5,0x1d
    80004754:	2007a623          	sw	zero,524(a5) # 8002195c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004758:	00000097          	auipc	ra,0x0
    8000475c:	c50080e7          	jalr	-944(ra) # 800043a8 <write_head>
    80004760:	bdf5                	j	8000465c <end_op+0x52>

0000000080004762 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004762:	1101                	addi	sp,sp,-32
    80004764:	ec06                	sd	ra,24(sp)
    80004766:	e822                	sd	s0,16(sp)
    80004768:	e426                	sd	s1,8(sp)
    8000476a:	e04a                	sd	s2,0(sp)
    8000476c:	1000                	addi	s0,sp,32
    8000476e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004770:	0001d917          	auipc	s2,0x1d
    80004774:	1c090913          	addi	s2,s2,448 # 80021930 <log>
    80004778:	854a                	mv	a0,s2
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	45c080e7          	jalr	1116(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004782:	02c92603          	lw	a2,44(s2)
    80004786:	47f5                	li	a5,29
    80004788:	06c7c563          	blt	a5,a2,800047f2 <log_write+0x90>
    8000478c:	0001d797          	auipc	a5,0x1d
    80004790:	1c07a783          	lw	a5,448(a5) # 8002194c <log+0x1c>
    80004794:	37fd                	addiw	a5,a5,-1
    80004796:	04f65e63          	bge	a2,a5,800047f2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000479a:	0001d797          	auipc	a5,0x1d
    8000479e:	1b67a783          	lw	a5,438(a5) # 80021950 <log+0x20>
    800047a2:	06f05063          	blez	a5,80004802 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047a6:	4781                	li	a5,0
    800047a8:	06c05563          	blez	a2,80004812 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047ac:	44cc                	lw	a1,12(s1)
    800047ae:	0001d717          	auipc	a4,0x1d
    800047b2:	1b270713          	addi	a4,a4,434 # 80021960 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800047b6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047b8:	4314                	lw	a3,0(a4)
    800047ba:	04b68c63          	beq	a3,a1,80004812 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800047be:	2785                	addiw	a5,a5,1
    800047c0:	0711                	addi	a4,a4,4
    800047c2:	fef61be3          	bne	a2,a5,800047b8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800047c6:	0621                	addi	a2,a2,8
    800047c8:	060a                	slli	a2,a2,0x2
    800047ca:	0001d797          	auipc	a5,0x1d
    800047ce:	16678793          	addi	a5,a5,358 # 80021930 <log>
    800047d2:	963e                	add	a2,a2,a5
    800047d4:	44dc                	lw	a5,12(s1)
    800047d6:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800047d8:	8526                	mv	a0,s1
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	da2080e7          	jalr	-606(ra) # 8000357c <bpin>
    log.lh.n++;
    800047e2:	0001d717          	auipc	a4,0x1d
    800047e6:	14e70713          	addi	a4,a4,334 # 80021930 <log>
    800047ea:	575c                	lw	a5,44(a4)
    800047ec:	2785                	addiw	a5,a5,1
    800047ee:	d75c                	sw	a5,44(a4)
    800047f0:	a835                	j	8000482c <log_write+0xca>
    panic("too big a transaction");
    800047f2:	00004517          	auipc	a0,0x4
    800047f6:	e9650513          	addi	a0,a0,-362 # 80008688 <syscalls+0x208>
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	d44080e7          	jalr	-700(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004802:	00004517          	auipc	a0,0x4
    80004806:	e9e50513          	addi	a0,a0,-354 # 800086a0 <syscalls+0x220>
    8000480a:	ffffc097          	auipc	ra,0xffffc
    8000480e:	d34080e7          	jalr	-716(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004812:	00878713          	addi	a4,a5,8
    80004816:	00271693          	slli	a3,a4,0x2
    8000481a:	0001d717          	auipc	a4,0x1d
    8000481e:	11670713          	addi	a4,a4,278 # 80021930 <log>
    80004822:	9736                	add	a4,a4,a3
    80004824:	44d4                	lw	a3,12(s1)
    80004826:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004828:	faf608e3          	beq	a2,a5,800047d8 <log_write+0x76>
  }
  release(&log.lock);
    8000482c:	0001d517          	auipc	a0,0x1d
    80004830:	10450513          	addi	a0,a0,260 # 80021930 <log>
    80004834:	ffffc097          	auipc	ra,0xffffc
    80004838:	456080e7          	jalr	1110(ra) # 80000c8a <release>
}
    8000483c:	60e2                	ld	ra,24(sp)
    8000483e:	6442                	ld	s0,16(sp)
    80004840:	64a2                	ld	s1,8(sp)
    80004842:	6902                	ld	s2,0(sp)
    80004844:	6105                	addi	sp,sp,32
    80004846:	8082                	ret

0000000080004848 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004848:	1101                	addi	sp,sp,-32
    8000484a:	ec06                	sd	ra,24(sp)
    8000484c:	e822                	sd	s0,16(sp)
    8000484e:	e426                	sd	s1,8(sp)
    80004850:	e04a                	sd	s2,0(sp)
    80004852:	1000                	addi	s0,sp,32
    80004854:	84aa                	mv	s1,a0
    80004856:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004858:	00004597          	auipc	a1,0x4
    8000485c:	e6858593          	addi	a1,a1,-408 # 800086c0 <syscalls+0x240>
    80004860:	0521                	addi	a0,a0,8
    80004862:	ffffc097          	auipc	ra,0xffffc
    80004866:	2e4080e7          	jalr	740(ra) # 80000b46 <initlock>
  lk->name = name;
    8000486a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000486e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004872:	0204a423          	sw	zero,40(s1)
}
    80004876:	60e2                	ld	ra,24(sp)
    80004878:	6442                	ld	s0,16(sp)
    8000487a:	64a2                	ld	s1,8(sp)
    8000487c:	6902                	ld	s2,0(sp)
    8000487e:	6105                	addi	sp,sp,32
    80004880:	8082                	ret

0000000080004882 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004882:	1101                	addi	sp,sp,-32
    80004884:	ec06                	sd	ra,24(sp)
    80004886:	e822                	sd	s0,16(sp)
    80004888:	e426                	sd	s1,8(sp)
    8000488a:	e04a                	sd	s2,0(sp)
    8000488c:	1000                	addi	s0,sp,32
    8000488e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004890:	00850913          	addi	s2,a0,8
    80004894:	854a                	mv	a0,s2
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	340080e7          	jalr	832(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000489e:	409c                	lw	a5,0(s1)
    800048a0:	cb89                	beqz	a5,800048b2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048a2:	85ca                	mv	a1,s2
    800048a4:	8526                	mv	a0,s1
    800048a6:	ffffe097          	auipc	ra,0xffffe
    800048aa:	cd8080e7          	jalr	-808(ra) # 8000257e <sleep>
  while (lk->locked) {
    800048ae:	409c                	lw	a5,0(s1)
    800048b0:	fbed                	bnez	a5,800048a2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048b2:	4785                	li	a5,1
    800048b4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800048b6:	ffffd097          	auipc	ra,0xffffd
    800048ba:	4be080e7          	jalr	1214(ra) # 80001d74 <myproc>
    800048be:	591c                	lw	a5,48(a0)
    800048c0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800048c2:	854a                	mv	a0,s2
    800048c4:	ffffc097          	auipc	ra,0xffffc
    800048c8:	3c6080e7          	jalr	966(ra) # 80000c8a <release>
}
    800048cc:	60e2                	ld	ra,24(sp)
    800048ce:	6442                	ld	s0,16(sp)
    800048d0:	64a2                	ld	s1,8(sp)
    800048d2:	6902                	ld	s2,0(sp)
    800048d4:	6105                	addi	sp,sp,32
    800048d6:	8082                	ret

00000000800048d8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048d8:	1101                	addi	sp,sp,-32
    800048da:	ec06                	sd	ra,24(sp)
    800048dc:	e822                	sd	s0,16(sp)
    800048de:	e426                	sd	s1,8(sp)
    800048e0:	e04a                	sd	s2,0(sp)
    800048e2:	1000                	addi	s0,sp,32
    800048e4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048e6:	00850913          	addi	s2,a0,8
    800048ea:	854a                	mv	a0,s2
    800048ec:	ffffc097          	auipc	ra,0xffffc
    800048f0:	2ea080e7          	jalr	746(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800048f4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048f8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800048fc:	8526                	mv	a0,s1
    800048fe:	ffffe097          	auipc	ra,0xffffe
    80004902:	ce4080e7          	jalr	-796(ra) # 800025e2 <wakeup>
  release(&lk->lk);
    80004906:	854a                	mv	a0,s2
    80004908:	ffffc097          	auipc	ra,0xffffc
    8000490c:	382080e7          	jalr	898(ra) # 80000c8a <release>
}
    80004910:	60e2                	ld	ra,24(sp)
    80004912:	6442                	ld	s0,16(sp)
    80004914:	64a2                	ld	s1,8(sp)
    80004916:	6902                	ld	s2,0(sp)
    80004918:	6105                	addi	sp,sp,32
    8000491a:	8082                	ret

000000008000491c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000491c:	7179                	addi	sp,sp,-48
    8000491e:	f406                	sd	ra,40(sp)
    80004920:	f022                	sd	s0,32(sp)
    80004922:	ec26                	sd	s1,24(sp)
    80004924:	e84a                	sd	s2,16(sp)
    80004926:	e44e                	sd	s3,8(sp)
    80004928:	1800                	addi	s0,sp,48
    8000492a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000492c:	00850913          	addi	s2,a0,8
    80004930:	854a                	mv	a0,s2
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	2a4080e7          	jalr	676(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000493a:	409c                	lw	a5,0(s1)
    8000493c:	ef99                	bnez	a5,8000495a <holdingsleep+0x3e>
    8000493e:	4481                	li	s1,0
  release(&lk->lk);
    80004940:	854a                	mv	a0,s2
    80004942:	ffffc097          	auipc	ra,0xffffc
    80004946:	348080e7          	jalr	840(ra) # 80000c8a <release>
  return r;
}
    8000494a:	8526                	mv	a0,s1
    8000494c:	70a2                	ld	ra,40(sp)
    8000494e:	7402                	ld	s0,32(sp)
    80004950:	64e2                	ld	s1,24(sp)
    80004952:	6942                	ld	s2,16(sp)
    80004954:	69a2                	ld	s3,8(sp)
    80004956:	6145                	addi	sp,sp,48
    80004958:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000495a:	0284a983          	lw	s3,40(s1)
    8000495e:	ffffd097          	auipc	ra,0xffffd
    80004962:	416080e7          	jalr	1046(ra) # 80001d74 <myproc>
    80004966:	5904                	lw	s1,48(a0)
    80004968:	413484b3          	sub	s1,s1,s3
    8000496c:	0014b493          	seqz	s1,s1
    80004970:	bfc1                	j	80004940 <holdingsleep+0x24>

0000000080004972 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004972:	1141                	addi	sp,sp,-16
    80004974:	e406                	sd	ra,8(sp)
    80004976:	e022                	sd	s0,0(sp)
    80004978:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000497a:	00004597          	auipc	a1,0x4
    8000497e:	d5658593          	addi	a1,a1,-682 # 800086d0 <syscalls+0x250>
    80004982:	0001d517          	auipc	a0,0x1d
    80004986:	0f650513          	addi	a0,a0,246 # 80021a78 <ftable>
    8000498a:	ffffc097          	auipc	ra,0xffffc
    8000498e:	1bc080e7          	jalr	444(ra) # 80000b46 <initlock>
}
    80004992:	60a2                	ld	ra,8(sp)
    80004994:	6402                	ld	s0,0(sp)
    80004996:	0141                	addi	sp,sp,16
    80004998:	8082                	ret

000000008000499a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000499a:	1101                	addi	sp,sp,-32
    8000499c:	ec06                	sd	ra,24(sp)
    8000499e:	e822                	sd	s0,16(sp)
    800049a0:	e426                	sd	s1,8(sp)
    800049a2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049a4:	0001d517          	auipc	a0,0x1d
    800049a8:	0d450513          	addi	a0,a0,212 # 80021a78 <ftable>
    800049ac:	ffffc097          	auipc	ra,0xffffc
    800049b0:	22a080e7          	jalr	554(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049b4:	0001d497          	auipc	s1,0x1d
    800049b8:	0dc48493          	addi	s1,s1,220 # 80021a90 <ftable+0x18>
    800049bc:	0001e717          	auipc	a4,0x1e
    800049c0:	07470713          	addi	a4,a4,116 # 80022a30 <disk>
    if(f->ref == 0){
    800049c4:	40dc                	lw	a5,4(s1)
    800049c6:	cf99                	beqz	a5,800049e4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049c8:	02848493          	addi	s1,s1,40
    800049cc:	fee49ce3          	bne	s1,a4,800049c4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049d0:	0001d517          	auipc	a0,0x1d
    800049d4:	0a850513          	addi	a0,a0,168 # 80021a78 <ftable>
    800049d8:	ffffc097          	auipc	ra,0xffffc
    800049dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
  return 0;
    800049e0:	4481                	li	s1,0
    800049e2:	a819                	j	800049f8 <filealloc+0x5e>
      f->ref = 1;
    800049e4:	4785                	li	a5,1
    800049e6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800049e8:	0001d517          	auipc	a0,0x1d
    800049ec:	09050513          	addi	a0,a0,144 # 80021a78 <ftable>
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	29a080e7          	jalr	666(ra) # 80000c8a <release>
}
    800049f8:	8526                	mv	a0,s1
    800049fa:	60e2                	ld	ra,24(sp)
    800049fc:	6442                	ld	s0,16(sp)
    800049fe:	64a2                	ld	s1,8(sp)
    80004a00:	6105                	addi	sp,sp,32
    80004a02:	8082                	ret

0000000080004a04 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a04:	1101                	addi	sp,sp,-32
    80004a06:	ec06                	sd	ra,24(sp)
    80004a08:	e822                	sd	s0,16(sp)
    80004a0a:	e426                	sd	s1,8(sp)
    80004a0c:	1000                	addi	s0,sp,32
    80004a0e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a10:	0001d517          	auipc	a0,0x1d
    80004a14:	06850513          	addi	a0,a0,104 # 80021a78 <ftable>
    80004a18:	ffffc097          	auipc	ra,0xffffc
    80004a1c:	1be080e7          	jalr	446(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a20:	40dc                	lw	a5,4(s1)
    80004a22:	02f05263          	blez	a5,80004a46 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a26:	2785                	addiw	a5,a5,1
    80004a28:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a2a:	0001d517          	auipc	a0,0x1d
    80004a2e:	04e50513          	addi	a0,a0,78 # 80021a78 <ftable>
    80004a32:	ffffc097          	auipc	ra,0xffffc
    80004a36:	258080e7          	jalr	600(ra) # 80000c8a <release>
  return f;
}
    80004a3a:	8526                	mv	a0,s1
    80004a3c:	60e2                	ld	ra,24(sp)
    80004a3e:	6442                	ld	s0,16(sp)
    80004a40:	64a2                	ld	s1,8(sp)
    80004a42:	6105                	addi	sp,sp,32
    80004a44:	8082                	ret
    panic("filedup");
    80004a46:	00004517          	auipc	a0,0x4
    80004a4a:	c9250513          	addi	a0,a0,-878 # 800086d8 <syscalls+0x258>
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	af0080e7          	jalr	-1296(ra) # 8000053e <panic>

0000000080004a56 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a56:	7139                	addi	sp,sp,-64
    80004a58:	fc06                	sd	ra,56(sp)
    80004a5a:	f822                	sd	s0,48(sp)
    80004a5c:	f426                	sd	s1,40(sp)
    80004a5e:	f04a                	sd	s2,32(sp)
    80004a60:	ec4e                	sd	s3,24(sp)
    80004a62:	e852                	sd	s4,16(sp)
    80004a64:	e456                	sd	s5,8(sp)
    80004a66:	0080                	addi	s0,sp,64
    80004a68:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a6a:	0001d517          	auipc	a0,0x1d
    80004a6e:	00e50513          	addi	a0,a0,14 # 80021a78 <ftable>
    80004a72:	ffffc097          	auipc	ra,0xffffc
    80004a76:	164080e7          	jalr	356(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a7a:	40dc                	lw	a5,4(s1)
    80004a7c:	06f05163          	blez	a5,80004ade <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a80:	37fd                	addiw	a5,a5,-1
    80004a82:	0007871b          	sext.w	a4,a5
    80004a86:	c0dc                	sw	a5,4(s1)
    80004a88:	06e04363          	bgtz	a4,80004aee <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a8c:	0004a903          	lw	s2,0(s1)
    80004a90:	0094ca83          	lbu	s5,9(s1)
    80004a94:	0104ba03          	ld	s4,16(s1)
    80004a98:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a9c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004aa0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004aa4:	0001d517          	auipc	a0,0x1d
    80004aa8:	fd450513          	addi	a0,a0,-44 # 80021a78 <ftable>
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	1de080e7          	jalr	478(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004ab4:	4785                	li	a5,1
    80004ab6:	04f90d63          	beq	s2,a5,80004b10 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004aba:	3979                	addiw	s2,s2,-2
    80004abc:	4785                	li	a5,1
    80004abe:	0527e063          	bltu	a5,s2,80004afe <fileclose+0xa8>
    begin_op();
    80004ac2:	00000097          	auipc	ra,0x0
    80004ac6:	ac8080e7          	jalr	-1336(ra) # 8000458a <begin_op>
    iput(ff.ip);
    80004aca:	854e                	mv	a0,s3
    80004acc:	fffff097          	auipc	ra,0xfffff
    80004ad0:	2b6080e7          	jalr	694(ra) # 80003d82 <iput>
    end_op();
    80004ad4:	00000097          	auipc	ra,0x0
    80004ad8:	b36080e7          	jalr	-1226(ra) # 8000460a <end_op>
    80004adc:	a00d                	j	80004afe <fileclose+0xa8>
    panic("fileclose");
    80004ade:	00004517          	auipc	a0,0x4
    80004ae2:	c0250513          	addi	a0,a0,-1022 # 800086e0 <syscalls+0x260>
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	a58080e7          	jalr	-1448(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004aee:	0001d517          	auipc	a0,0x1d
    80004af2:	f8a50513          	addi	a0,a0,-118 # 80021a78 <ftable>
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	194080e7          	jalr	404(ra) # 80000c8a <release>
  }
}
    80004afe:	70e2                	ld	ra,56(sp)
    80004b00:	7442                	ld	s0,48(sp)
    80004b02:	74a2                	ld	s1,40(sp)
    80004b04:	7902                	ld	s2,32(sp)
    80004b06:	69e2                	ld	s3,24(sp)
    80004b08:	6a42                	ld	s4,16(sp)
    80004b0a:	6aa2                	ld	s5,8(sp)
    80004b0c:	6121                	addi	sp,sp,64
    80004b0e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b10:	85d6                	mv	a1,s5
    80004b12:	8552                	mv	a0,s4
    80004b14:	00000097          	auipc	ra,0x0
    80004b18:	34c080e7          	jalr	844(ra) # 80004e60 <pipeclose>
    80004b1c:	b7cd                	j	80004afe <fileclose+0xa8>

0000000080004b1e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b1e:	715d                	addi	sp,sp,-80
    80004b20:	e486                	sd	ra,72(sp)
    80004b22:	e0a2                	sd	s0,64(sp)
    80004b24:	fc26                	sd	s1,56(sp)
    80004b26:	f84a                	sd	s2,48(sp)
    80004b28:	f44e                	sd	s3,40(sp)
    80004b2a:	0880                	addi	s0,sp,80
    80004b2c:	84aa                	mv	s1,a0
    80004b2e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b30:	ffffd097          	auipc	ra,0xffffd
    80004b34:	244080e7          	jalr	580(ra) # 80001d74 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b38:	409c                	lw	a5,0(s1)
    80004b3a:	37f9                	addiw	a5,a5,-2
    80004b3c:	4705                	li	a4,1
    80004b3e:	04f76763          	bltu	a4,a5,80004b8c <filestat+0x6e>
    80004b42:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b44:	6c88                	ld	a0,24(s1)
    80004b46:	fffff097          	auipc	ra,0xfffff
    80004b4a:	082080e7          	jalr	130(ra) # 80003bc8 <ilock>
    stati(f->ip, &st);
    80004b4e:	fb840593          	addi	a1,s0,-72
    80004b52:	6c88                	ld	a0,24(s1)
    80004b54:	fffff097          	auipc	ra,0xfffff
    80004b58:	2fe080e7          	jalr	766(ra) # 80003e52 <stati>
    iunlock(f->ip);
    80004b5c:	6c88                	ld	a0,24(s1)
    80004b5e:	fffff097          	auipc	ra,0xfffff
    80004b62:	12c080e7          	jalr	300(ra) # 80003c8a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b66:	46e1                	li	a3,24
    80004b68:	fb840613          	addi	a2,s0,-72
    80004b6c:	85ce                	mv	a1,s3
    80004b6e:	05093503          	ld	a0,80(s2)
    80004b72:	ffffd097          	auipc	ra,0xffffd
    80004b76:	af6080e7          	jalr	-1290(ra) # 80001668 <copyout>
    80004b7a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b7e:	60a6                	ld	ra,72(sp)
    80004b80:	6406                	ld	s0,64(sp)
    80004b82:	74e2                	ld	s1,56(sp)
    80004b84:	7942                	ld	s2,48(sp)
    80004b86:	79a2                	ld	s3,40(sp)
    80004b88:	6161                	addi	sp,sp,80
    80004b8a:	8082                	ret
  return -1;
    80004b8c:	557d                	li	a0,-1
    80004b8e:	bfc5                	j	80004b7e <filestat+0x60>

0000000080004b90 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b90:	7179                	addi	sp,sp,-48
    80004b92:	f406                	sd	ra,40(sp)
    80004b94:	f022                	sd	s0,32(sp)
    80004b96:	ec26                	sd	s1,24(sp)
    80004b98:	e84a                	sd	s2,16(sp)
    80004b9a:	e44e                	sd	s3,8(sp)
    80004b9c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b9e:	00854783          	lbu	a5,8(a0)
    80004ba2:	c3d5                	beqz	a5,80004c46 <fileread+0xb6>
    80004ba4:	84aa                	mv	s1,a0
    80004ba6:	89ae                	mv	s3,a1
    80004ba8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004baa:	411c                	lw	a5,0(a0)
    80004bac:	4705                	li	a4,1
    80004bae:	04e78963          	beq	a5,a4,80004c00 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bb2:	470d                	li	a4,3
    80004bb4:	04e78d63          	beq	a5,a4,80004c0e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bb8:	4709                	li	a4,2
    80004bba:	06e79e63          	bne	a5,a4,80004c36 <fileread+0xa6>
    ilock(f->ip);
    80004bbe:	6d08                	ld	a0,24(a0)
    80004bc0:	fffff097          	auipc	ra,0xfffff
    80004bc4:	008080e7          	jalr	8(ra) # 80003bc8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004bc8:	874a                	mv	a4,s2
    80004bca:	5094                	lw	a3,32(s1)
    80004bcc:	864e                	mv	a2,s3
    80004bce:	4585                	li	a1,1
    80004bd0:	6c88                	ld	a0,24(s1)
    80004bd2:	fffff097          	auipc	ra,0xfffff
    80004bd6:	2aa080e7          	jalr	682(ra) # 80003e7c <readi>
    80004bda:	892a                	mv	s2,a0
    80004bdc:	00a05563          	blez	a0,80004be6 <fileread+0x56>
      f->off += r;
    80004be0:	509c                	lw	a5,32(s1)
    80004be2:	9fa9                	addw	a5,a5,a0
    80004be4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004be6:	6c88                	ld	a0,24(s1)
    80004be8:	fffff097          	auipc	ra,0xfffff
    80004bec:	0a2080e7          	jalr	162(ra) # 80003c8a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004bf0:	854a                	mv	a0,s2
    80004bf2:	70a2                	ld	ra,40(sp)
    80004bf4:	7402                	ld	s0,32(sp)
    80004bf6:	64e2                	ld	s1,24(sp)
    80004bf8:	6942                	ld	s2,16(sp)
    80004bfa:	69a2                	ld	s3,8(sp)
    80004bfc:	6145                	addi	sp,sp,48
    80004bfe:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c00:	6908                	ld	a0,16(a0)
    80004c02:	00000097          	auipc	ra,0x0
    80004c06:	3c6080e7          	jalr	966(ra) # 80004fc8 <piperead>
    80004c0a:	892a                	mv	s2,a0
    80004c0c:	b7d5                	j	80004bf0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c0e:	02451783          	lh	a5,36(a0)
    80004c12:	03079693          	slli	a3,a5,0x30
    80004c16:	92c1                	srli	a3,a3,0x30
    80004c18:	4725                	li	a4,9
    80004c1a:	02d76863          	bltu	a4,a3,80004c4a <fileread+0xba>
    80004c1e:	0792                	slli	a5,a5,0x4
    80004c20:	0001d717          	auipc	a4,0x1d
    80004c24:	db870713          	addi	a4,a4,-584 # 800219d8 <devsw>
    80004c28:	97ba                	add	a5,a5,a4
    80004c2a:	639c                	ld	a5,0(a5)
    80004c2c:	c38d                	beqz	a5,80004c4e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c2e:	4505                	li	a0,1
    80004c30:	9782                	jalr	a5
    80004c32:	892a                	mv	s2,a0
    80004c34:	bf75                	j	80004bf0 <fileread+0x60>
    panic("fileread");
    80004c36:	00004517          	auipc	a0,0x4
    80004c3a:	aba50513          	addi	a0,a0,-1350 # 800086f0 <syscalls+0x270>
    80004c3e:	ffffc097          	auipc	ra,0xffffc
    80004c42:	900080e7          	jalr	-1792(ra) # 8000053e <panic>
    return -1;
    80004c46:	597d                	li	s2,-1
    80004c48:	b765                	j	80004bf0 <fileread+0x60>
      return -1;
    80004c4a:	597d                	li	s2,-1
    80004c4c:	b755                	j	80004bf0 <fileread+0x60>
    80004c4e:	597d                	li	s2,-1
    80004c50:	b745                	j	80004bf0 <fileread+0x60>

0000000080004c52 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c52:	715d                	addi	sp,sp,-80
    80004c54:	e486                	sd	ra,72(sp)
    80004c56:	e0a2                	sd	s0,64(sp)
    80004c58:	fc26                	sd	s1,56(sp)
    80004c5a:	f84a                	sd	s2,48(sp)
    80004c5c:	f44e                	sd	s3,40(sp)
    80004c5e:	f052                	sd	s4,32(sp)
    80004c60:	ec56                	sd	s5,24(sp)
    80004c62:	e85a                	sd	s6,16(sp)
    80004c64:	e45e                	sd	s7,8(sp)
    80004c66:	e062                	sd	s8,0(sp)
    80004c68:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c6a:	00954783          	lbu	a5,9(a0)
    80004c6e:	10078663          	beqz	a5,80004d7a <filewrite+0x128>
    80004c72:	892a                	mv	s2,a0
    80004c74:	8aae                	mv	s5,a1
    80004c76:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c78:	411c                	lw	a5,0(a0)
    80004c7a:	4705                	li	a4,1
    80004c7c:	02e78263          	beq	a5,a4,80004ca0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c80:	470d                	li	a4,3
    80004c82:	02e78663          	beq	a5,a4,80004cae <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c86:	4709                	li	a4,2
    80004c88:	0ee79163          	bne	a5,a4,80004d6a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c8c:	0ac05d63          	blez	a2,80004d46 <filewrite+0xf4>
    int i = 0;
    80004c90:	4981                	li	s3,0
    80004c92:	6b05                	lui	s6,0x1
    80004c94:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004c98:	6b85                	lui	s7,0x1
    80004c9a:	c00b8b9b          	addiw	s7,s7,-1024
    80004c9e:	a861                	j	80004d36 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004ca0:	6908                	ld	a0,16(a0)
    80004ca2:	00000097          	auipc	ra,0x0
    80004ca6:	22e080e7          	jalr	558(ra) # 80004ed0 <pipewrite>
    80004caa:	8a2a                	mv	s4,a0
    80004cac:	a045                	j	80004d4c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cae:	02451783          	lh	a5,36(a0)
    80004cb2:	03079693          	slli	a3,a5,0x30
    80004cb6:	92c1                	srli	a3,a3,0x30
    80004cb8:	4725                	li	a4,9
    80004cba:	0cd76263          	bltu	a4,a3,80004d7e <filewrite+0x12c>
    80004cbe:	0792                	slli	a5,a5,0x4
    80004cc0:	0001d717          	auipc	a4,0x1d
    80004cc4:	d1870713          	addi	a4,a4,-744 # 800219d8 <devsw>
    80004cc8:	97ba                	add	a5,a5,a4
    80004cca:	679c                	ld	a5,8(a5)
    80004ccc:	cbdd                	beqz	a5,80004d82 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004cce:	4505                	li	a0,1
    80004cd0:	9782                	jalr	a5
    80004cd2:	8a2a                	mv	s4,a0
    80004cd4:	a8a5                	j	80004d4c <filewrite+0xfa>
    80004cd6:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004cda:	00000097          	auipc	ra,0x0
    80004cde:	8b0080e7          	jalr	-1872(ra) # 8000458a <begin_op>
      ilock(f->ip);
    80004ce2:	01893503          	ld	a0,24(s2)
    80004ce6:	fffff097          	auipc	ra,0xfffff
    80004cea:	ee2080e7          	jalr	-286(ra) # 80003bc8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004cee:	8762                	mv	a4,s8
    80004cf0:	02092683          	lw	a3,32(s2)
    80004cf4:	01598633          	add	a2,s3,s5
    80004cf8:	4585                	li	a1,1
    80004cfa:	01893503          	ld	a0,24(s2)
    80004cfe:	fffff097          	auipc	ra,0xfffff
    80004d02:	276080e7          	jalr	630(ra) # 80003f74 <writei>
    80004d06:	84aa                	mv	s1,a0
    80004d08:	00a05763          	blez	a0,80004d16 <filewrite+0xc4>
        f->off += r;
    80004d0c:	02092783          	lw	a5,32(s2)
    80004d10:	9fa9                	addw	a5,a5,a0
    80004d12:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d16:	01893503          	ld	a0,24(s2)
    80004d1a:	fffff097          	auipc	ra,0xfffff
    80004d1e:	f70080e7          	jalr	-144(ra) # 80003c8a <iunlock>
      end_op();
    80004d22:	00000097          	auipc	ra,0x0
    80004d26:	8e8080e7          	jalr	-1816(ra) # 8000460a <end_op>

      if(r != n1){
    80004d2a:	009c1f63          	bne	s8,s1,80004d48 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d2e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d32:	0149db63          	bge	s3,s4,80004d48 <filewrite+0xf6>
      int n1 = n - i;
    80004d36:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004d3a:	84be                	mv	s1,a5
    80004d3c:	2781                	sext.w	a5,a5
    80004d3e:	f8fb5ce3          	bge	s6,a5,80004cd6 <filewrite+0x84>
    80004d42:	84de                	mv	s1,s7
    80004d44:	bf49                	j	80004cd6 <filewrite+0x84>
    int i = 0;
    80004d46:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d48:	013a1f63          	bne	s4,s3,80004d66 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d4c:	8552                	mv	a0,s4
    80004d4e:	60a6                	ld	ra,72(sp)
    80004d50:	6406                	ld	s0,64(sp)
    80004d52:	74e2                	ld	s1,56(sp)
    80004d54:	7942                	ld	s2,48(sp)
    80004d56:	79a2                	ld	s3,40(sp)
    80004d58:	7a02                	ld	s4,32(sp)
    80004d5a:	6ae2                	ld	s5,24(sp)
    80004d5c:	6b42                	ld	s6,16(sp)
    80004d5e:	6ba2                	ld	s7,8(sp)
    80004d60:	6c02                	ld	s8,0(sp)
    80004d62:	6161                	addi	sp,sp,80
    80004d64:	8082                	ret
    ret = (i == n ? n : -1);
    80004d66:	5a7d                	li	s4,-1
    80004d68:	b7d5                	j	80004d4c <filewrite+0xfa>
    panic("filewrite");
    80004d6a:	00004517          	auipc	a0,0x4
    80004d6e:	99650513          	addi	a0,a0,-1642 # 80008700 <syscalls+0x280>
    80004d72:	ffffb097          	auipc	ra,0xffffb
    80004d76:	7cc080e7          	jalr	1996(ra) # 8000053e <panic>
    return -1;
    80004d7a:	5a7d                	li	s4,-1
    80004d7c:	bfc1                	j	80004d4c <filewrite+0xfa>
      return -1;
    80004d7e:	5a7d                	li	s4,-1
    80004d80:	b7f1                	j	80004d4c <filewrite+0xfa>
    80004d82:	5a7d                	li	s4,-1
    80004d84:	b7e1                	j	80004d4c <filewrite+0xfa>

0000000080004d86 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d86:	7179                	addi	sp,sp,-48
    80004d88:	f406                	sd	ra,40(sp)
    80004d8a:	f022                	sd	s0,32(sp)
    80004d8c:	ec26                	sd	s1,24(sp)
    80004d8e:	e84a                	sd	s2,16(sp)
    80004d90:	e44e                	sd	s3,8(sp)
    80004d92:	e052                	sd	s4,0(sp)
    80004d94:	1800                	addi	s0,sp,48
    80004d96:	84aa                	mv	s1,a0
    80004d98:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d9a:	0005b023          	sd	zero,0(a1)
    80004d9e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004da2:	00000097          	auipc	ra,0x0
    80004da6:	bf8080e7          	jalr	-1032(ra) # 8000499a <filealloc>
    80004daa:	e088                	sd	a0,0(s1)
    80004dac:	c551                	beqz	a0,80004e38 <pipealloc+0xb2>
    80004dae:	00000097          	auipc	ra,0x0
    80004db2:	bec080e7          	jalr	-1044(ra) # 8000499a <filealloc>
    80004db6:	00aa3023          	sd	a0,0(s4)
    80004dba:	c92d                	beqz	a0,80004e2c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004dbc:	ffffc097          	auipc	ra,0xffffc
    80004dc0:	d2a080e7          	jalr	-726(ra) # 80000ae6 <kalloc>
    80004dc4:	892a                	mv	s2,a0
    80004dc6:	c125                	beqz	a0,80004e26 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004dc8:	4985                	li	s3,1
    80004dca:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004dce:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004dd2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004dd6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004dda:	00004597          	auipc	a1,0x4
    80004dde:	93658593          	addi	a1,a1,-1738 # 80008710 <syscalls+0x290>
    80004de2:	ffffc097          	auipc	ra,0xffffc
    80004de6:	d64080e7          	jalr	-668(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004dea:	609c                	ld	a5,0(s1)
    80004dec:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004df0:	609c                	ld	a5,0(s1)
    80004df2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004df6:	609c                	ld	a5,0(s1)
    80004df8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004dfc:	609c                	ld	a5,0(s1)
    80004dfe:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e02:	000a3783          	ld	a5,0(s4)
    80004e06:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e0a:	000a3783          	ld	a5,0(s4)
    80004e0e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e12:	000a3783          	ld	a5,0(s4)
    80004e16:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e1a:	000a3783          	ld	a5,0(s4)
    80004e1e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e22:	4501                	li	a0,0
    80004e24:	a025                	j	80004e4c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e26:	6088                	ld	a0,0(s1)
    80004e28:	e501                	bnez	a0,80004e30 <pipealloc+0xaa>
    80004e2a:	a039                	j	80004e38 <pipealloc+0xb2>
    80004e2c:	6088                	ld	a0,0(s1)
    80004e2e:	c51d                	beqz	a0,80004e5c <pipealloc+0xd6>
    fileclose(*f0);
    80004e30:	00000097          	auipc	ra,0x0
    80004e34:	c26080e7          	jalr	-986(ra) # 80004a56 <fileclose>
  if(*f1)
    80004e38:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e3c:	557d                	li	a0,-1
  if(*f1)
    80004e3e:	c799                	beqz	a5,80004e4c <pipealloc+0xc6>
    fileclose(*f1);
    80004e40:	853e                	mv	a0,a5
    80004e42:	00000097          	auipc	ra,0x0
    80004e46:	c14080e7          	jalr	-1004(ra) # 80004a56 <fileclose>
  return -1;
    80004e4a:	557d                	li	a0,-1
}
    80004e4c:	70a2                	ld	ra,40(sp)
    80004e4e:	7402                	ld	s0,32(sp)
    80004e50:	64e2                	ld	s1,24(sp)
    80004e52:	6942                	ld	s2,16(sp)
    80004e54:	69a2                	ld	s3,8(sp)
    80004e56:	6a02                	ld	s4,0(sp)
    80004e58:	6145                	addi	sp,sp,48
    80004e5a:	8082                	ret
  return -1;
    80004e5c:	557d                	li	a0,-1
    80004e5e:	b7fd                	j	80004e4c <pipealloc+0xc6>

0000000080004e60 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e60:	1101                	addi	sp,sp,-32
    80004e62:	ec06                	sd	ra,24(sp)
    80004e64:	e822                	sd	s0,16(sp)
    80004e66:	e426                	sd	s1,8(sp)
    80004e68:	e04a                	sd	s2,0(sp)
    80004e6a:	1000                	addi	s0,sp,32
    80004e6c:	84aa                	mv	s1,a0
    80004e6e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e70:	ffffc097          	auipc	ra,0xffffc
    80004e74:	d66080e7          	jalr	-666(ra) # 80000bd6 <acquire>
  if(writable){
    80004e78:	02090d63          	beqz	s2,80004eb2 <pipeclose+0x52>
    pi->writeopen = 0;
    80004e7c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e80:	21848513          	addi	a0,s1,536
    80004e84:	ffffd097          	auipc	ra,0xffffd
    80004e88:	75e080e7          	jalr	1886(ra) # 800025e2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e8c:	2204b783          	ld	a5,544(s1)
    80004e90:	eb95                	bnez	a5,80004ec4 <pipeclose+0x64>
    release(&pi->lock);
    80004e92:	8526                	mv	a0,s1
    80004e94:	ffffc097          	auipc	ra,0xffffc
    80004e98:	df6080e7          	jalr	-522(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004e9c:	8526                	mv	a0,s1
    80004e9e:	ffffc097          	auipc	ra,0xffffc
    80004ea2:	b4c080e7          	jalr	-1204(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004ea6:	60e2                	ld	ra,24(sp)
    80004ea8:	6442                	ld	s0,16(sp)
    80004eaa:	64a2                	ld	s1,8(sp)
    80004eac:	6902                	ld	s2,0(sp)
    80004eae:	6105                	addi	sp,sp,32
    80004eb0:	8082                	ret
    pi->readopen = 0;
    80004eb2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004eb6:	21c48513          	addi	a0,s1,540
    80004eba:	ffffd097          	auipc	ra,0xffffd
    80004ebe:	728080e7          	jalr	1832(ra) # 800025e2 <wakeup>
    80004ec2:	b7e9                	j	80004e8c <pipeclose+0x2c>
    release(&pi->lock);
    80004ec4:	8526                	mv	a0,s1
    80004ec6:	ffffc097          	auipc	ra,0xffffc
    80004eca:	dc4080e7          	jalr	-572(ra) # 80000c8a <release>
}
    80004ece:	bfe1                	j	80004ea6 <pipeclose+0x46>

0000000080004ed0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ed0:	711d                	addi	sp,sp,-96
    80004ed2:	ec86                	sd	ra,88(sp)
    80004ed4:	e8a2                	sd	s0,80(sp)
    80004ed6:	e4a6                	sd	s1,72(sp)
    80004ed8:	e0ca                	sd	s2,64(sp)
    80004eda:	fc4e                	sd	s3,56(sp)
    80004edc:	f852                	sd	s4,48(sp)
    80004ede:	f456                	sd	s5,40(sp)
    80004ee0:	f05a                	sd	s6,32(sp)
    80004ee2:	ec5e                	sd	s7,24(sp)
    80004ee4:	e862                	sd	s8,16(sp)
    80004ee6:	1080                	addi	s0,sp,96
    80004ee8:	84aa                	mv	s1,a0
    80004eea:	8aae                	mv	s5,a1
    80004eec:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004eee:	ffffd097          	auipc	ra,0xffffd
    80004ef2:	e86080e7          	jalr	-378(ra) # 80001d74 <myproc>
    80004ef6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ef8:	8526                	mv	a0,s1
    80004efa:	ffffc097          	auipc	ra,0xffffc
    80004efe:	cdc080e7          	jalr	-804(ra) # 80000bd6 <acquire>
  while(i < n){
    80004f02:	0b405663          	blez	s4,80004fae <pipewrite+0xde>
  int i = 0;
    80004f06:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f08:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f0a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f0e:	21c48b93          	addi	s7,s1,540
    80004f12:	a089                	j	80004f54 <pipewrite+0x84>
      release(&pi->lock);
    80004f14:	8526                	mv	a0,s1
    80004f16:	ffffc097          	auipc	ra,0xffffc
    80004f1a:	d74080e7          	jalr	-652(ra) # 80000c8a <release>
      return -1;
    80004f1e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f20:	854a                	mv	a0,s2
    80004f22:	60e6                	ld	ra,88(sp)
    80004f24:	6446                	ld	s0,80(sp)
    80004f26:	64a6                	ld	s1,72(sp)
    80004f28:	6906                	ld	s2,64(sp)
    80004f2a:	79e2                	ld	s3,56(sp)
    80004f2c:	7a42                	ld	s4,48(sp)
    80004f2e:	7aa2                	ld	s5,40(sp)
    80004f30:	7b02                	ld	s6,32(sp)
    80004f32:	6be2                	ld	s7,24(sp)
    80004f34:	6c42                	ld	s8,16(sp)
    80004f36:	6125                	addi	sp,sp,96
    80004f38:	8082                	ret
      wakeup(&pi->nread);
    80004f3a:	8562                	mv	a0,s8
    80004f3c:	ffffd097          	auipc	ra,0xffffd
    80004f40:	6a6080e7          	jalr	1702(ra) # 800025e2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f44:	85a6                	mv	a1,s1
    80004f46:	855e                	mv	a0,s7
    80004f48:	ffffd097          	auipc	ra,0xffffd
    80004f4c:	636080e7          	jalr	1590(ra) # 8000257e <sleep>
  while(i < n){
    80004f50:	07495063          	bge	s2,s4,80004fb0 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004f54:	2204a783          	lw	a5,544(s1)
    80004f58:	dfd5                	beqz	a5,80004f14 <pipewrite+0x44>
    80004f5a:	854e                	mv	a0,s3
    80004f5c:	ffffe097          	auipc	ra,0xffffe
    80004f60:	920080e7          	jalr	-1760(ra) # 8000287c <killed>
    80004f64:	f945                	bnez	a0,80004f14 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f66:	2184a783          	lw	a5,536(s1)
    80004f6a:	21c4a703          	lw	a4,540(s1)
    80004f6e:	2007879b          	addiw	a5,a5,512
    80004f72:	fcf704e3          	beq	a4,a5,80004f3a <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f76:	4685                	li	a3,1
    80004f78:	01590633          	add	a2,s2,s5
    80004f7c:	faf40593          	addi	a1,s0,-81
    80004f80:	0509b503          	ld	a0,80(s3)
    80004f84:	ffffc097          	auipc	ra,0xffffc
    80004f88:	770080e7          	jalr	1904(ra) # 800016f4 <copyin>
    80004f8c:	03650263          	beq	a0,s6,80004fb0 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f90:	21c4a783          	lw	a5,540(s1)
    80004f94:	0017871b          	addiw	a4,a5,1
    80004f98:	20e4ae23          	sw	a4,540(s1)
    80004f9c:	1ff7f793          	andi	a5,a5,511
    80004fa0:	97a6                	add	a5,a5,s1
    80004fa2:	faf44703          	lbu	a4,-81(s0)
    80004fa6:	00e78c23          	sb	a4,24(a5)
      i++;
    80004faa:	2905                	addiw	s2,s2,1
    80004fac:	b755                	j	80004f50 <pipewrite+0x80>
  int i = 0;
    80004fae:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004fb0:	21848513          	addi	a0,s1,536
    80004fb4:	ffffd097          	auipc	ra,0xffffd
    80004fb8:	62e080e7          	jalr	1582(ra) # 800025e2 <wakeup>
  release(&pi->lock);
    80004fbc:	8526                	mv	a0,s1
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	ccc080e7          	jalr	-820(ra) # 80000c8a <release>
  return i;
    80004fc6:	bfa9                	j	80004f20 <pipewrite+0x50>

0000000080004fc8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004fc8:	715d                	addi	sp,sp,-80
    80004fca:	e486                	sd	ra,72(sp)
    80004fcc:	e0a2                	sd	s0,64(sp)
    80004fce:	fc26                	sd	s1,56(sp)
    80004fd0:	f84a                	sd	s2,48(sp)
    80004fd2:	f44e                	sd	s3,40(sp)
    80004fd4:	f052                	sd	s4,32(sp)
    80004fd6:	ec56                	sd	s5,24(sp)
    80004fd8:	e85a                	sd	s6,16(sp)
    80004fda:	0880                	addi	s0,sp,80
    80004fdc:	84aa                	mv	s1,a0
    80004fde:	892e                	mv	s2,a1
    80004fe0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004fe2:	ffffd097          	auipc	ra,0xffffd
    80004fe6:	d92080e7          	jalr	-622(ra) # 80001d74 <myproc>
    80004fea:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004fec:	8526                	mv	a0,s1
    80004fee:	ffffc097          	auipc	ra,0xffffc
    80004ff2:	be8080e7          	jalr	-1048(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ff6:	2184a703          	lw	a4,536(s1)
    80004ffa:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ffe:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005002:	02f71763          	bne	a4,a5,80005030 <piperead+0x68>
    80005006:	2244a783          	lw	a5,548(s1)
    8000500a:	c39d                	beqz	a5,80005030 <piperead+0x68>
    if(killed(pr)){
    8000500c:	8552                	mv	a0,s4
    8000500e:	ffffe097          	auipc	ra,0xffffe
    80005012:	86e080e7          	jalr	-1938(ra) # 8000287c <killed>
    80005016:	e941                	bnez	a0,800050a6 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005018:	85a6                	mv	a1,s1
    8000501a:	854e                	mv	a0,s3
    8000501c:	ffffd097          	auipc	ra,0xffffd
    80005020:	562080e7          	jalr	1378(ra) # 8000257e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005024:	2184a703          	lw	a4,536(s1)
    80005028:	21c4a783          	lw	a5,540(s1)
    8000502c:	fcf70de3          	beq	a4,a5,80005006 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005030:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005032:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005034:	05505363          	blez	s5,8000507a <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80005038:	2184a783          	lw	a5,536(s1)
    8000503c:	21c4a703          	lw	a4,540(s1)
    80005040:	02f70d63          	beq	a4,a5,8000507a <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005044:	0017871b          	addiw	a4,a5,1
    80005048:	20e4ac23          	sw	a4,536(s1)
    8000504c:	1ff7f793          	andi	a5,a5,511
    80005050:	97a6                	add	a5,a5,s1
    80005052:	0187c783          	lbu	a5,24(a5)
    80005056:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000505a:	4685                	li	a3,1
    8000505c:	fbf40613          	addi	a2,s0,-65
    80005060:	85ca                	mv	a1,s2
    80005062:	050a3503          	ld	a0,80(s4)
    80005066:	ffffc097          	auipc	ra,0xffffc
    8000506a:	602080e7          	jalr	1538(ra) # 80001668 <copyout>
    8000506e:	01650663          	beq	a0,s6,8000507a <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005072:	2985                	addiw	s3,s3,1
    80005074:	0905                	addi	s2,s2,1
    80005076:	fd3a91e3          	bne	s5,s3,80005038 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000507a:	21c48513          	addi	a0,s1,540
    8000507e:	ffffd097          	auipc	ra,0xffffd
    80005082:	564080e7          	jalr	1380(ra) # 800025e2 <wakeup>
  release(&pi->lock);
    80005086:	8526                	mv	a0,s1
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	c02080e7          	jalr	-1022(ra) # 80000c8a <release>
  return i;
}
    80005090:	854e                	mv	a0,s3
    80005092:	60a6                	ld	ra,72(sp)
    80005094:	6406                	ld	s0,64(sp)
    80005096:	74e2                	ld	s1,56(sp)
    80005098:	7942                	ld	s2,48(sp)
    8000509a:	79a2                	ld	s3,40(sp)
    8000509c:	7a02                	ld	s4,32(sp)
    8000509e:	6ae2                	ld	s5,24(sp)
    800050a0:	6b42                	ld	s6,16(sp)
    800050a2:	6161                	addi	sp,sp,80
    800050a4:	8082                	ret
      release(&pi->lock);
    800050a6:	8526                	mv	a0,s1
    800050a8:	ffffc097          	auipc	ra,0xffffc
    800050ac:	be2080e7          	jalr	-1054(ra) # 80000c8a <release>
      return -1;
    800050b0:	59fd                	li	s3,-1
    800050b2:	bff9                	j	80005090 <piperead+0xc8>

00000000800050b4 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800050b4:	1141                	addi	sp,sp,-16
    800050b6:	e422                	sd	s0,8(sp)
    800050b8:	0800                	addi	s0,sp,16
    800050ba:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800050bc:	8905                	andi	a0,a0,1
    800050be:	c111                	beqz	a0,800050c2 <flags2perm+0xe>
      perm = PTE_X;
    800050c0:	4521                	li	a0,8
    if(flags & 0x2)
    800050c2:	8b89                	andi	a5,a5,2
    800050c4:	c399                	beqz	a5,800050ca <flags2perm+0x16>
      perm |= PTE_W;
    800050c6:	00456513          	ori	a0,a0,4
    return perm;
}
    800050ca:	6422                	ld	s0,8(sp)
    800050cc:	0141                	addi	sp,sp,16
    800050ce:	8082                	ret

00000000800050d0 <exec>:

int
exec(char *path, char **argv)
{
    800050d0:	de010113          	addi	sp,sp,-544
    800050d4:	20113c23          	sd	ra,536(sp)
    800050d8:	20813823          	sd	s0,528(sp)
    800050dc:	20913423          	sd	s1,520(sp)
    800050e0:	21213023          	sd	s2,512(sp)
    800050e4:	ffce                	sd	s3,504(sp)
    800050e6:	fbd2                	sd	s4,496(sp)
    800050e8:	f7d6                	sd	s5,488(sp)
    800050ea:	f3da                	sd	s6,480(sp)
    800050ec:	efde                	sd	s7,472(sp)
    800050ee:	ebe2                	sd	s8,464(sp)
    800050f0:	e7e6                	sd	s9,456(sp)
    800050f2:	e3ea                	sd	s10,448(sp)
    800050f4:	ff6e                	sd	s11,440(sp)
    800050f6:	1400                	addi	s0,sp,544
    800050f8:	892a                	mv	s2,a0
    800050fa:	dea43423          	sd	a0,-536(s0)
    800050fe:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005102:	ffffd097          	auipc	ra,0xffffd
    80005106:	c72080e7          	jalr	-910(ra) # 80001d74 <myproc>
    8000510a:	84aa                	mv	s1,a0

  begin_op();
    8000510c:	fffff097          	auipc	ra,0xfffff
    80005110:	47e080e7          	jalr	1150(ra) # 8000458a <begin_op>

  if((ip = namei(path)) == 0){
    80005114:	854a                	mv	a0,s2
    80005116:	fffff097          	auipc	ra,0xfffff
    8000511a:	258080e7          	jalr	600(ra) # 8000436e <namei>
    8000511e:	c93d                	beqz	a0,80005194 <exec+0xc4>
    80005120:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005122:	fffff097          	auipc	ra,0xfffff
    80005126:	aa6080e7          	jalr	-1370(ra) # 80003bc8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000512a:	04000713          	li	a4,64
    8000512e:	4681                	li	a3,0
    80005130:	e5040613          	addi	a2,s0,-432
    80005134:	4581                	li	a1,0
    80005136:	8556                	mv	a0,s5
    80005138:	fffff097          	auipc	ra,0xfffff
    8000513c:	d44080e7          	jalr	-700(ra) # 80003e7c <readi>
    80005140:	04000793          	li	a5,64
    80005144:	00f51a63          	bne	a0,a5,80005158 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005148:	e5042703          	lw	a4,-432(s0)
    8000514c:	464c47b7          	lui	a5,0x464c4
    80005150:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005154:	04f70663          	beq	a4,a5,800051a0 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005158:	8556                	mv	a0,s5
    8000515a:	fffff097          	auipc	ra,0xfffff
    8000515e:	cd0080e7          	jalr	-816(ra) # 80003e2a <iunlockput>
    end_op();
    80005162:	fffff097          	auipc	ra,0xfffff
    80005166:	4a8080e7          	jalr	1192(ra) # 8000460a <end_op>
  }
  return -1;
    8000516a:	557d                	li	a0,-1
}
    8000516c:	21813083          	ld	ra,536(sp)
    80005170:	21013403          	ld	s0,528(sp)
    80005174:	20813483          	ld	s1,520(sp)
    80005178:	20013903          	ld	s2,512(sp)
    8000517c:	79fe                	ld	s3,504(sp)
    8000517e:	7a5e                	ld	s4,496(sp)
    80005180:	7abe                	ld	s5,488(sp)
    80005182:	7b1e                	ld	s6,480(sp)
    80005184:	6bfe                	ld	s7,472(sp)
    80005186:	6c5e                	ld	s8,464(sp)
    80005188:	6cbe                	ld	s9,456(sp)
    8000518a:	6d1e                	ld	s10,448(sp)
    8000518c:	7dfa                	ld	s11,440(sp)
    8000518e:	22010113          	addi	sp,sp,544
    80005192:	8082                	ret
    end_op();
    80005194:	fffff097          	auipc	ra,0xfffff
    80005198:	476080e7          	jalr	1142(ra) # 8000460a <end_op>
    return -1;
    8000519c:	557d                	li	a0,-1
    8000519e:	b7f9                	j	8000516c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800051a0:	8526                	mv	a0,s1
    800051a2:	ffffd097          	auipc	ra,0xffffd
    800051a6:	d86080e7          	jalr	-634(ra) # 80001f28 <proc_pagetable>
    800051aa:	8b2a                	mv	s6,a0
    800051ac:	d555                	beqz	a0,80005158 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051ae:	e7042783          	lw	a5,-400(s0)
    800051b2:	e8845703          	lhu	a4,-376(s0)
    800051b6:	c735                	beqz	a4,80005222 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051b8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051ba:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800051be:	6a05                	lui	s4,0x1
    800051c0:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800051c4:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800051c8:	6d85                	lui	s11,0x1
    800051ca:	7d7d                	lui	s10,0xfffff
    800051cc:	a481                	j	8000540c <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800051ce:	00003517          	auipc	a0,0x3
    800051d2:	54a50513          	addi	a0,a0,1354 # 80008718 <syscalls+0x298>
    800051d6:	ffffb097          	auipc	ra,0xffffb
    800051da:	368080e7          	jalr	872(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800051de:	874a                	mv	a4,s2
    800051e0:	009c86bb          	addw	a3,s9,s1
    800051e4:	4581                	li	a1,0
    800051e6:	8556                	mv	a0,s5
    800051e8:	fffff097          	auipc	ra,0xfffff
    800051ec:	c94080e7          	jalr	-876(ra) # 80003e7c <readi>
    800051f0:	2501                	sext.w	a0,a0
    800051f2:	1aa91a63          	bne	s2,a0,800053a6 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    800051f6:	009d84bb          	addw	s1,s11,s1
    800051fa:	013d09bb          	addw	s3,s10,s3
    800051fe:	1f74f763          	bgeu	s1,s7,800053ec <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80005202:	02049593          	slli	a1,s1,0x20
    80005206:	9181                	srli	a1,a1,0x20
    80005208:	95e2                	add	a1,a1,s8
    8000520a:	855a                	mv	a0,s6
    8000520c:	ffffc097          	auipc	ra,0xffffc
    80005210:	e50080e7          	jalr	-432(ra) # 8000105c <walkaddr>
    80005214:	862a                	mv	a2,a0
    if(pa == 0)
    80005216:	dd45                	beqz	a0,800051ce <exec+0xfe>
      n = PGSIZE;
    80005218:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000521a:	fd49f2e3          	bgeu	s3,s4,800051de <exec+0x10e>
      n = sz - i;
    8000521e:	894e                	mv	s2,s3
    80005220:	bf7d                	j	800051de <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005222:	4901                	li	s2,0
  iunlockput(ip);
    80005224:	8556                	mv	a0,s5
    80005226:	fffff097          	auipc	ra,0xfffff
    8000522a:	c04080e7          	jalr	-1020(ra) # 80003e2a <iunlockput>
  end_op();
    8000522e:	fffff097          	auipc	ra,0xfffff
    80005232:	3dc080e7          	jalr	988(ra) # 8000460a <end_op>
  p = myproc();
    80005236:	ffffd097          	auipc	ra,0xffffd
    8000523a:	b3e080e7          	jalr	-1218(ra) # 80001d74 <myproc>
    8000523e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005240:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005244:	6785                	lui	a5,0x1
    80005246:	17fd                	addi	a5,a5,-1
    80005248:	993e                	add	s2,s2,a5
    8000524a:	77fd                	lui	a5,0xfffff
    8000524c:	00f977b3          	and	a5,s2,a5
    80005250:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005254:	4691                	li	a3,4
    80005256:	6609                	lui	a2,0x2
    80005258:	963e                	add	a2,a2,a5
    8000525a:	85be                	mv	a1,a5
    8000525c:	855a                	mv	a0,s6
    8000525e:	ffffc097          	auipc	ra,0xffffc
    80005262:	1b2080e7          	jalr	434(ra) # 80001410 <uvmalloc>
    80005266:	8c2a                	mv	s8,a0
  ip = 0;
    80005268:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000526a:	12050e63          	beqz	a0,800053a6 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000526e:	75f9                	lui	a1,0xffffe
    80005270:	95aa                	add	a1,a1,a0
    80005272:	855a                	mv	a0,s6
    80005274:	ffffc097          	auipc	ra,0xffffc
    80005278:	3c2080e7          	jalr	962(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    8000527c:	7afd                	lui	s5,0xfffff
    8000527e:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005280:	df043783          	ld	a5,-528(s0)
    80005284:	6388                	ld	a0,0(a5)
    80005286:	c925                	beqz	a0,800052f6 <exec+0x226>
    80005288:	e9040993          	addi	s3,s0,-368
    8000528c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005290:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005292:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005294:	ffffc097          	auipc	ra,0xffffc
    80005298:	bba080e7          	jalr	-1094(ra) # 80000e4e <strlen>
    8000529c:	0015079b          	addiw	a5,a0,1
    800052a0:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052a4:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800052a8:	13596663          	bltu	s2,s5,800053d4 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052ac:	df043d83          	ld	s11,-528(s0)
    800052b0:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800052b4:	8552                	mv	a0,s4
    800052b6:	ffffc097          	auipc	ra,0xffffc
    800052ba:	b98080e7          	jalr	-1128(ra) # 80000e4e <strlen>
    800052be:	0015069b          	addiw	a3,a0,1
    800052c2:	8652                	mv	a2,s4
    800052c4:	85ca                	mv	a1,s2
    800052c6:	855a                	mv	a0,s6
    800052c8:	ffffc097          	auipc	ra,0xffffc
    800052cc:	3a0080e7          	jalr	928(ra) # 80001668 <copyout>
    800052d0:	10054663          	bltz	a0,800053dc <exec+0x30c>
    ustack[argc] = sp;
    800052d4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800052d8:	0485                	addi	s1,s1,1
    800052da:	008d8793          	addi	a5,s11,8
    800052de:	def43823          	sd	a5,-528(s0)
    800052e2:	008db503          	ld	a0,8(s11)
    800052e6:	c911                	beqz	a0,800052fa <exec+0x22a>
    if(argc >= MAXARG)
    800052e8:	09a1                	addi	s3,s3,8
    800052ea:	fb3c95e3          	bne	s9,s3,80005294 <exec+0x1c4>
  sz = sz1;
    800052ee:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052f2:	4a81                	li	s5,0
    800052f4:	a84d                	j	800053a6 <exec+0x2d6>
  sp = sz;
    800052f6:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800052f8:	4481                	li	s1,0
  ustack[argc] = 0;
    800052fa:	00349793          	slli	a5,s1,0x3
    800052fe:	f9040713          	addi	a4,s0,-112
    80005302:	97ba                	add	a5,a5,a4
    80005304:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdc390>
  sp -= (argc+1) * sizeof(uint64);
    80005308:	00148693          	addi	a3,s1,1
    8000530c:	068e                	slli	a3,a3,0x3
    8000530e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005312:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005316:	01597663          	bgeu	s2,s5,80005322 <exec+0x252>
  sz = sz1;
    8000531a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000531e:	4a81                	li	s5,0
    80005320:	a059                	j	800053a6 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005322:	e9040613          	addi	a2,s0,-368
    80005326:	85ca                	mv	a1,s2
    80005328:	855a                	mv	a0,s6
    8000532a:	ffffc097          	auipc	ra,0xffffc
    8000532e:	33e080e7          	jalr	830(ra) # 80001668 <copyout>
    80005332:	0a054963          	bltz	a0,800053e4 <exec+0x314>
  p->trapframe->a1 = sp;
    80005336:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    8000533a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000533e:	de843783          	ld	a5,-536(s0)
    80005342:	0007c703          	lbu	a4,0(a5)
    80005346:	cf11                	beqz	a4,80005362 <exec+0x292>
    80005348:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000534a:	02f00693          	li	a3,47
    8000534e:	a039                	j	8000535c <exec+0x28c>
      last = s+1;
    80005350:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005354:	0785                	addi	a5,a5,1
    80005356:	fff7c703          	lbu	a4,-1(a5)
    8000535a:	c701                	beqz	a4,80005362 <exec+0x292>
    if(*s == '/')
    8000535c:	fed71ce3          	bne	a4,a3,80005354 <exec+0x284>
    80005360:	bfc5                	j	80005350 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80005362:	4641                	li	a2,16
    80005364:	de843583          	ld	a1,-536(s0)
    80005368:	158b8513          	addi	a0,s7,344
    8000536c:	ffffc097          	auipc	ra,0xffffc
    80005370:	ab0080e7          	jalr	-1360(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005374:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005378:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000537c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005380:	058bb783          	ld	a5,88(s7)
    80005384:	e6843703          	ld	a4,-408(s0)
    80005388:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000538a:	058bb783          	ld	a5,88(s7)
    8000538e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005392:	85ea                	mv	a1,s10
    80005394:	ffffd097          	auipc	ra,0xffffd
    80005398:	c30080e7          	jalr	-976(ra) # 80001fc4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000539c:	0004851b          	sext.w	a0,s1
    800053a0:	b3f1                	j	8000516c <exec+0x9c>
    800053a2:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800053a6:	df843583          	ld	a1,-520(s0)
    800053aa:	855a                	mv	a0,s6
    800053ac:	ffffd097          	auipc	ra,0xffffd
    800053b0:	c18080e7          	jalr	-1000(ra) # 80001fc4 <proc_freepagetable>
  if(ip){
    800053b4:	da0a92e3          	bnez	s5,80005158 <exec+0x88>
  return -1;
    800053b8:	557d                	li	a0,-1
    800053ba:	bb4d                	j	8000516c <exec+0x9c>
    800053bc:	df243c23          	sd	s2,-520(s0)
    800053c0:	b7dd                	j	800053a6 <exec+0x2d6>
    800053c2:	df243c23          	sd	s2,-520(s0)
    800053c6:	b7c5                	j	800053a6 <exec+0x2d6>
    800053c8:	df243c23          	sd	s2,-520(s0)
    800053cc:	bfe9                	j	800053a6 <exec+0x2d6>
    800053ce:	df243c23          	sd	s2,-520(s0)
    800053d2:	bfd1                	j	800053a6 <exec+0x2d6>
  sz = sz1;
    800053d4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053d8:	4a81                	li	s5,0
    800053da:	b7f1                	j	800053a6 <exec+0x2d6>
  sz = sz1;
    800053dc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053e0:	4a81                	li	s5,0
    800053e2:	b7d1                	j	800053a6 <exec+0x2d6>
  sz = sz1;
    800053e4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053e8:	4a81                	li	s5,0
    800053ea:	bf75                	j	800053a6 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053ec:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053f0:	e0843783          	ld	a5,-504(s0)
    800053f4:	0017869b          	addiw	a3,a5,1
    800053f8:	e0d43423          	sd	a3,-504(s0)
    800053fc:	e0043783          	ld	a5,-512(s0)
    80005400:	0387879b          	addiw	a5,a5,56
    80005404:	e8845703          	lhu	a4,-376(s0)
    80005408:	e0e6dee3          	bge	a3,a4,80005224 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000540c:	2781                	sext.w	a5,a5
    8000540e:	e0f43023          	sd	a5,-512(s0)
    80005412:	03800713          	li	a4,56
    80005416:	86be                	mv	a3,a5
    80005418:	e1840613          	addi	a2,s0,-488
    8000541c:	4581                	li	a1,0
    8000541e:	8556                	mv	a0,s5
    80005420:	fffff097          	auipc	ra,0xfffff
    80005424:	a5c080e7          	jalr	-1444(ra) # 80003e7c <readi>
    80005428:	03800793          	li	a5,56
    8000542c:	f6f51be3          	bne	a0,a5,800053a2 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80005430:	e1842783          	lw	a5,-488(s0)
    80005434:	4705                	li	a4,1
    80005436:	fae79de3          	bne	a5,a4,800053f0 <exec+0x320>
    if(ph.memsz < ph.filesz)
    8000543a:	e4043483          	ld	s1,-448(s0)
    8000543e:	e3843783          	ld	a5,-456(s0)
    80005442:	f6f4ede3          	bltu	s1,a5,800053bc <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005446:	e2843783          	ld	a5,-472(s0)
    8000544a:	94be                	add	s1,s1,a5
    8000544c:	f6f4ebe3          	bltu	s1,a5,800053c2 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80005450:	de043703          	ld	a4,-544(s0)
    80005454:	8ff9                	and	a5,a5,a4
    80005456:	fbad                	bnez	a5,800053c8 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005458:	e1c42503          	lw	a0,-484(s0)
    8000545c:	00000097          	auipc	ra,0x0
    80005460:	c58080e7          	jalr	-936(ra) # 800050b4 <flags2perm>
    80005464:	86aa                	mv	a3,a0
    80005466:	8626                	mv	a2,s1
    80005468:	85ca                	mv	a1,s2
    8000546a:	855a                	mv	a0,s6
    8000546c:	ffffc097          	auipc	ra,0xffffc
    80005470:	fa4080e7          	jalr	-92(ra) # 80001410 <uvmalloc>
    80005474:	dea43c23          	sd	a0,-520(s0)
    80005478:	d939                	beqz	a0,800053ce <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000547a:	e2843c03          	ld	s8,-472(s0)
    8000547e:	e2042c83          	lw	s9,-480(s0)
    80005482:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005486:	f60b83e3          	beqz	s7,800053ec <exec+0x31c>
    8000548a:	89de                	mv	s3,s7
    8000548c:	4481                	li	s1,0
    8000548e:	bb95                	j	80005202 <exec+0x132>

0000000080005490 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005490:	7179                	addi	sp,sp,-48
    80005492:	f406                	sd	ra,40(sp)
    80005494:	f022                	sd	s0,32(sp)
    80005496:	ec26                	sd	s1,24(sp)
    80005498:	e84a                	sd	s2,16(sp)
    8000549a:	1800                	addi	s0,sp,48
    8000549c:	892e                	mv	s2,a1
    8000549e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054a0:	fdc40593          	addi	a1,s0,-36
    800054a4:	ffffe097          	auipc	ra,0xffffe
    800054a8:	bb8080e7          	jalr	-1096(ra) # 8000305c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054ac:	fdc42703          	lw	a4,-36(s0)
    800054b0:	47bd                	li	a5,15
    800054b2:	02e7eb63          	bltu	a5,a4,800054e8 <argfd+0x58>
    800054b6:	ffffd097          	auipc	ra,0xffffd
    800054ba:	8be080e7          	jalr	-1858(ra) # 80001d74 <myproc>
    800054be:	fdc42703          	lw	a4,-36(s0)
    800054c2:	01a70793          	addi	a5,a4,26
    800054c6:	078e                	slli	a5,a5,0x3
    800054c8:	953e                	add	a0,a0,a5
    800054ca:	611c                	ld	a5,0(a0)
    800054cc:	c385                	beqz	a5,800054ec <argfd+0x5c>
    return -1;
  if(pfd)
    800054ce:	00090463          	beqz	s2,800054d6 <argfd+0x46>
    *pfd = fd;
    800054d2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800054d6:	4501                	li	a0,0
  if(pf)
    800054d8:	c091                	beqz	s1,800054dc <argfd+0x4c>
    *pf = f;
    800054da:	e09c                	sd	a5,0(s1)
}
    800054dc:	70a2                	ld	ra,40(sp)
    800054de:	7402                	ld	s0,32(sp)
    800054e0:	64e2                	ld	s1,24(sp)
    800054e2:	6942                	ld	s2,16(sp)
    800054e4:	6145                	addi	sp,sp,48
    800054e6:	8082                	ret
    return -1;
    800054e8:	557d                	li	a0,-1
    800054ea:	bfcd                	j	800054dc <argfd+0x4c>
    800054ec:	557d                	li	a0,-1
    800054ee:	b7fd                	j	800054dc <argfd+0x4c>

00000000800054f0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800054f0:	1101                	addi	sp,sp,-32
    800054f2:	ec06                	sd	ra,24(sp)
    800054f4:	e822                	sd	s0,16(sp)
    800054f6:	e426                	sd	s1,8(sp)
    800054f8:	1000                	addi	s0,sp,32
    800054fa:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800054fc:	ffffd097          	auipc	ra,0xffffd
    80005500:	878080e7          	jalr	-1928(ra) # 80001d74 <myproc>
    80005504:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005506:	0d050793          	addi	a5,a0,208
    8000550a:	4501                	li	a0,0
    8000550c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000550e:	6398                	ld	a4,0(a5)
    80005510:	cb19                	beqz	a4,80005526 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005512:	2505                	addiw	a0,a0,1
    80005514:	07a1                	addi	a5,a5,8
    80005516:	fed51ce3          	bne	a0,a3,8000550e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000551a:	557d                	li	a0,-1
}
    8000551c:	60e2                	ld	ra,24(sp)
    8000551e:	6442                	ld	s0,16(sp)
    80005520:	64a2                	ld	s1,8(sp)
    80005522:	6105                	addi	sp,sp,32
    80005524:	8082                	ret
      p->ofile[fd] = f;
    80005526:	01a50793          	addi	a5,a0,26
    8000552a:	078e                	slli	a5,a5,0x3
    8000552c:	963e                	add	a2,a2,a5
    8000552e:	e204                	sd	s1,0(a2)
      return fd;
    80005530:	b7f5                	j	8000551c <fdalloc+0x2c>

0000000080005532 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005532:	715d                	addi	sp,sp,-80
    80005534:	e486                	sd	ra,72(sp)
    80005536:	e0a2                	sd	s0,64(sp)
    80005538:	fc26                	sd	s1,56(sp)
    8000553a:	f84a                	sd	s2,48(sp)
    8000553c:	f44e                	sd	s3,40(sp)
    8000553e:	f052                	sd	s4,32(sp)
    80005540:	ec56                	sd	s5,24(sp)
    80005542:	e85a                	sd	s6,16(sp)
    80005544:	0880                	addi	s0,sp,80
    80005546:	8b2e                	mv	s6,a1
    80005548:	89b2                	mv	s3,a2
    8000554a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000554c:	fb040593          	addi	a1,s0,-80
    80005550:	fffff097          	auipc	ra,0xfffff
    80005554:	e3c080e7          	jalr	-452(ra) # 8000438c <nameiparent>
    80005558:	84aa                	mv	s1,a0
    8000555a:	14050f63          	beqz	a0,800056b8 <create+0x186>
    return 0;

  ilock(dp);
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	66a080e7          	jalr	1642(ra) # 80003bc8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005566:	4601                	li	a2,0
    80005568:	fb040593          	addi	a1,s0,-80
    8000556c:	8526                	mv	a0,s1
    8000556e:	fffff097          	auipc	ra,0xfffff
    80005572:	b3e080e7          	jalr	-1218(ra) # 800040ac <dirlookup>
    80005576:	8aaa                	mv	s5,a0
    80005578:	c931                	beqz	a0,800055cc <create+0x9a>
    iunlockput(dp);
    8000557a:	8526                	mv	a0,s1
    8000557c:	fffff097          	auipc	ra,0xfffff
    80005580:	8ae080e7          	jalr	-1874(ra) # 80003e2a <iunlockput>
    ilock(ip);
    80005584:	8556                	mv	a0,s5
    80005586:	ffffe097          	auipc	ra,0xffffe
    8000558a:	642080e7          	jalr	1602(ra) # 80003bc8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000558e:	000b059b          	sext.w	a1,s6
    80005592:	4789                	li	a5,2
    80005594:	02f59563          	bne	a1,a5,800055be <create+0x8c>
    80005598:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdc4d4>
    8000559c:	37f9                	addiw	a5,a5,-2
    8000559e:	17c2                	slli	a5,a5,0x30
    800055a0:	93c1                	srli	a5,a5,0x30
    800055a2:	4705                	li	a4,1
    800055a4:	00f76d63          	bltu	a4,a5,800055be <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055a8:	8556                	mv	a0,s5
    800055aa:	60a6                	ld	ra,72(sp)
    800055ac:	6406                	ld	s0,64(sp)
    800055ae:	74e2                	ld	s1,56(sp)
    800055b0:	7942                	ld	s2,48(sp)
    800055b2:	79a2                	ld	s3,40(sp)
    800055b4:	7a02                	ld	s4,32(sp)
    800055b6:	6ae2                	ld	s5,24(sp)
    800055b8:	6b42                	ld	s6,16(sp)
    800055ba:	6161                	addi	sp,sp,80
    800055bc:	8082                	ret
    iunlockput(ip);
    800055be:	8556                	mv	a0,s5
    800055c0:	fffff097          	auipc	ra,0xfffff
    800055c4:	86a080e7          	jalr	-1942(ra) # 80003e2a <iunlockput>
    return 0;
    800055c8:	4a81                	li	s5,0
    800055ca:	bff9                	j	800055a8 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800055cc:	85da                	mv	a1,s6
    800055ce:	4088                	lw	a0,0(s1)
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	45c080e7          	jalr	1116(ra) # 80003a2c <ialloc>
    800055d8:	8a2a                	mv	s4,a0
    800055da:	c539                	beqz	a0,80005628 <create+0xf6>
  ilock(ip);
    800055dc:	ffffe097          	auipc	ra,0xffffe
    800055e0:	5ec080e7          	jalr	1516(ra) # 80003bc8 <ilock>
  ip->major = major;
    800055e4:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800055e8:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800055ec:	4905                	li	s2,1
    800055ee:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800055f2:	8552                	mv	a0,s4
    800055f4:	ffffe097          	auipc	ra,0xffffe
    800055f8:	50a080e7          	jalr	1290(ra) # 80003afe <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800055fc:	000b059b          	sext.w	a1,s6
    80005600:	03258b63          	beq	a1,s2,80005636 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005604:	004a2603          	lw	a2,4(s4)
    80005608:	fb040593          	addi	a1,s0,-80
    8000560c:	8526                	mv	a0,s1
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	cae080e7          	jalr	-850(ra) # 800042bc <dirlink>
    80005616:	06054f63          	bltz	a0,80005694 <create+0x162>
  iunlockput(dp);
    8000561a:	8526                	mv	a0,s1
    8000561c:	fffff097          	auipc	ra,0xfffff
    80005620:	80e080e7          	jalr	-2034(ra) # 80003e2a <iunlockput>
  return ip;
    80005624:	8ad2                	mv	s5,s4
    80005626:	b749                	j	800055a8 <create+0x76>
    iunlockput(dp);
    80005628:	8526                	mv	a0,s1
    8000562a:	fffff097          	auipc	ra,0xfffff
    8000562e:	800080e7          	jalr	-2048(ra) # 80003e2a <iunlockput>
    return 0;
    80005632:	8ad2                	mv	s5,s4
    80005634:	bf95                	j	800055a8 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005636:	004a2603          	lw	a2,4(s4)
    8000563a:	00003597          	auipc	a1,0x3
    8000563e:	0fe58593          	addi	a1,a1,254 # 80008738 <syscalls+0x2b8>
    80005642:	8552                	mv	a0,s4
    80005644:	fffff097          	auipc	ra,0xfffff
    80005648:	c78080e7          	jalr	-904(ra) # 800042bc <dirlink>
    8000564c:	04054463          	bltz	a0,80005694 <create+0x162>
    80005650:	40d0                	lw	a2,4(s1)
    80005652:	00003597          	auipc	a1,0x3
    80005656:	0ee58593          	addi	a1,a1,238 # 80008740 <syscalls+0x2c0>
    8000565a:	8552                	mv	a0,s4
    8000565c:	fffff097          	auipc	ra,0xfffff
    80005660:	c60080e7          	jalr	-928(ra) # 800042bc <dirlink>
    80005664:	02054863          	bltz	a0,80005694 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005668:	004a2603          	lw	a2,4(s4)
    8000566c:	fb040593          	addi	a1,s0,-80
    80005670:	8526                	mv	a0,s1
    80005672:	fffff097          	auipc	ra,0xfffff
    80005676:	c4a080e7          	jalr	-950(ra) # 800042bc <dirlink>
    8000567a:	00054d63          	bltz	a0,80005694 <create+0x162>
    dp->nlink++;  // for ".."
    8000567e:	04a4d783          	lhu	a5,74(s1)
    80005682:	2785                	addiw	a5,a5,1
    80005684:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005688:	8526                	mv	a0,s1
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	474080e7          	jalr	1140(ra) # 80003afe <iupdate>
    80005692:	b761                	j	8000561a <create+0xe8>
  ip->nlink = 0;
    80005694:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005698:	8552                	mv	a0,s4
    8000569a:	ffffe097          	auipc	ra,0xffffe
    8000569e:	464080e7          	jalr	1124(ra) # 80003afe <iupdate>
  iunlockput(ip);
    800056a2:	8552                	mv	a0,s4
    800056a4:	ffffe097          	auipc	ra,0xffffe
    800056a8:	786080e7          	jalr	1926(ra) # 80003e2a <iunlockput>
  iunlockput(dp);
    800056ac:	8526                	mv	a0,s1
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	77c080e7          	jalr	1916(ra) # 80003e2a <iunlockput>
  return 0;
    800056b6:	bdcd                	j	800055a8 <create+0x76>
    return 0;
    800056b8:	8aaa                	mv	s5,a0
    800056ba:	b5fd                	j	800055a8 <create+0x76>

00000000800056bc <sys_dup>:
{
    800056bc:	7179                	addi	sp,sp,-48
    800056be:	f406                	sd	ra,40(sp)
    800056c0:	f022                	sd	s0,32(sp)
    800056c2:	ec26                	sd	s1,24(sp)
    800056c4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800056c6:	fd840613          	addi	a2,s0,-40
    800056ca:	4581                	li	a1,0
    800056cc:	4501                	li	a0,0
    800056ce:	00000097          	auipc	ra,0x0
    800056d2:	dc2080e7          	jalr	-574(ra) # 80005490 <argfd>
    return -1;
    800056d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800056d8:	02054363          	bltz	a0,800056fe <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800056dc:	fd843503          	ld	a0,-40(s0)
    800056e0:	00000097          	auipc	ra,0x0
    800056e4:	e10080e7          	jalr	-496(ra) # 800054f0 <fdalloc>
    800056e8:	84aa                	mv	s1,a0
    return -1;
    800056ea:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800056ec:	00054963          	bltz	a0,800056fe <sys_dup+0x42>
  filedup(f);
    800056f0:	fd843503          	ld	a0,-40(s0)
    800056f4:	fffff097          	auipc	ra,0xfffff
    800056f8:	310080e7          	jalr	784(ra) # 80004a04 <filedup>
  return fd;
    800056fc:	87a6                	mv	a5,s1
}
    800056fe:	853e                	mv	a0,a5
    80005700:	70a2                	ld	ra,40(sp)
    80005702:	7402                	ld	s0,32(sp)
    80005704:	64e2                	ld	s1,24(sp)
    80005706:	6145                	addi	sp,sp,48
    80005708:	8082                	ret

000000008000570a <sys_read>:
{
    8000570a:	7179                	addi	sp,sp,-48
    8000570c:	f406                	sd	ra,40(sp)
    8000570e:	f022                	sd	s0,32(sp)
    80005710:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005712:	fd840593          	addi	a1,s0,-40
    80005716:	4505                	li	a0,1
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	964080e7          	jalr	-1692(ra) # 8000307c <argaddr>
  argint(2, &n);
    80005720:	fe440593          	addi	a1,s0,-28
    80005724:	4509                	li	a0,2
    80005726:	ffffe097          	auipc	ra,0xffffe
    8000572a:	936080e7          	jalr	-1738(ra) # 8000305c <argint>
  if(argfd(0, 0, &f) < 0)
    8000572e:	fe840613          	addi	a2,s0,-24
    80005732:	4581                	li	a1,0
    80005734:	4501                	li	a0,0
    80005736:	00000097          	auipc	ra,0x0
    8000573a:	d5a080e7          	jalr	-678(ra) # 80005490 <argfd>
    8000573e:	87aa                	mv	a5,a0
    return -1;
    80005740:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005742:	0007cc63          	bltz	a5,8000575a <sys_read+0x50>
  return fileread(f, p, n);
    80005746:	fe442603          	lw	a2,-28(s0)
    8000574a:	fd843583          	ld	a1,-40(s0)
    8000574e:	fe843503          	ld	a0,-24(s0)
    80005752:	fffff097          	auipc	ra,0xfffff
    80005756:	43e080e7          	jalr	1086(ra) # 80004b90 <fileread>
}
    8000575a:	70a2                	ld	ra,40(sp)
    8000575c:	7402                	ld	s0,32(sp)
    8000575e:	6145                	addi	sp,sp,48
    80005760:	8082                	ret

0000000080005762 <sys_write>:
{
    80005762:	7179                	addi	sp,sp,-48
    80005764:	f406                	sd	ra,40(sp)
    80005766:	f022                	sd	s0,32(sp)
    80005768:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000576a:	fd840593          	addi	a1,s0,-40
    8000576e:	4505                	li	a0,1
    80005770:	ffffe097          	auipc	ra,0xffffe
    80005774:	90c080e7          	jalr	-1780(ra) # 8000307c <argaddr>
  argint(2, &n);
    80005778:	fe440593          	addi	a1,s0,-28
    8000577c:	4509                	li	a0,2
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	8de080e7          	jalr	-1826(ra) # 8000305c <argint>
  if(argfd(0, 0, &f) < 0)
    80005786:	fe840613          	addi	a2,s0,-24
    8000578a:	4581                	li	a1,0
    8000578c:	4501                	li	a0,0
    8000578e:	00000097          	auipc	ra,0x0
    80005792:	d02080e7          	jalr	-766(ra) # 80005490 <argfd>
    80005796:	87aa                	mv	a5,a0
    return -1;
    80005798:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000579a:	0007cc63          	bltz	a5,800057b2 <sys_write+0x50>
  return filewrite(f, p, n);
    8000579e:	fe442603          	lw	a2,-28(s0)
    800057a2:	fd843583          	ld	a1,-40(s0)
    800057a6:	fe843503          	ld	a0,-24(s0)
    800057aa:	fffff097          	auipc	ra,0xfffff
    800057ae:	4a8080e7          	jalr	1192(ra) # 80004c52 <filewrite>
}
    800057b2:	70a2                	ld	ra,40(sp)
    800057b4:	7402                	ld	s0,32(sp)
    800057b6:	6145                	addi	sp,sp,48
    800057b8:	8082                	ret

00000000800057ba <sys_close>:
{
    800057ba:	1101                	addi	sp,sp,-32
    800057bc:	ec06                	sd	ra,24(sp)
    800057be:	e822                	sd	s0,16(sp)
    800057c0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057c2:	fe040613          	addi	a2,s0,-32
    800057c6:	fec40593          	addi	a1,s0,-20
    800057ca:	4501                	li	a0,0
    800057cc:	00000097          	auipc	ra,0x0
    800057d0:	cc4080e7          	jalr	-828(ra) # 80005490 <argfd>
    return -1;
    800057d4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800057d6:	02054463          	bltz	a0,800057fe <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800057da:	ffffc097          	auipc	ra,0xffffc
    800057de:	59a080e7          	jalr	1434(ra) # 80001d74 <myproc>
    800057e2:	fec42783          	lw	a5,-20(s0)
    800057e6:	07e9                	addi	a5,a5,26
    800057e8:	078e                	slli	a5,a5,0x3
    800057ea:	97aa                	add	a5,a5,a0
    800057ec:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800057f0:	fe043503          	ld	a0,-32(s0)
    800057f4:	fffff097          	auipc	ra,0xfffff
    800057f8:	262080e7          	jalr	610(ra) # 80004a56 <fileclose>
  return 0;
    800057fc:	4781                	li	a5,0
}
    800057fe:	853e                	mv	a0,a5
    80005800:	60e2                	ld	ra,24(sp)
    80005802:	6442                	ld	s0,16(sp)
    80005804:	6105                	addi	sp,sp,32
    80005806:	8082                	ret

0000000080005808 <sys_fstat>:
{
    80005808:	1101                	addi	sp,sp,-32
    8000580a:	ec06                	sd	ra,24(sp)
    8000580c:	e822                	sd	s0,16(sp)
    8000580e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005810:	fe040593          	addi	a1,s0,-32
    80005814:	4505                	li	a0,1
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	866080e7          	jalr	-1946(ra) # 8000307c <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000581e:	fe840613          	addi	a2,s0,-24
    80005822:	4581                	li	a1,0
    80005824:	4501                	li	a0,0
    80005826:	00000097          	auipc	ra,0x0
    8000582a:	c6a080e7          	jalr	-918(ra) # 80005490 <argfd>
    8000582e:	87aa                	mv	a5,a0
    return -1;
    80005830:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005832:	0007ca63          	bltz	a5,80005846 <sys_fstat+0x3e>
  return filestat(f, st);
    80005836:	fe043583          	ld	a1,-32(s0)
    8000583a:	fe843503          	ld	a0,-24(s0)
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	2e0080e7          	jalr	736(ra) # 80004b1e <filestat>
}
    80005846:	60e2                	ld	ra,24(sp)
    80005848:	6442                	ld	s0,16(sp)
    8000584a:	6105                	addi	sp,sp,32
    8000584c:	8082                	ret

000000008000584e <sys_link>:
{
    8000584e:	7169                	addi	sp,sp,-304
    80005850:	f606                	sd	ra,296(sp)
    80005852:	f222                	sd	s0,288(sp)
    80005854:	ee26                	sd	s1,280(sp)
    80005856:	ea4a                	sd	s2,272(sp)
    80005858:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000585a:	08000613          	li	a2,128
    8000585e:	ed040593          	addi	a1,s0,-304
    80005862:	4501                	li	a0,0
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	838080e7          	jalr	-1992(ra) # 8000309c <argstr>
    return -1;
    8000586c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000586e:	10054e63          	bltz	a0,8000598a <sys_link+0x13c>
    80005872:	08000613          	li	a2,128
    80005876:	f5040593          	addi	a1,s0,-176
    8000587a:	4505                	li	a0,1
    8000587c:	ffffe097          	auipc	ra,0xffffe
    80005880:	820080e7          	jalr	-2016(ra) # 8000309c <argstr>
    return -1;
    80005884:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005886:	10054263          	bltz	a0,8000598a <sys_link+0x13c>
  begin_op();
    8000588a:	fffff097          	auipc	ra,0xfffff
    8000588e:	d00080e7          	jalr	-768(ra) # 8000458a <begin_op>
  if((ip = namei(old)) == 0){
    80005892:	ed040513          	addi	a0,s0,-304
    80005896:	fffff097          	auipc	ra,0xfffff
    8000589a:	ad8080e7          	jalr	-1320(ra) # 8000436e <namei>
    8000589e:	84aa                	mv	s1,a0
    800058a0:	c551                	beqz	a0,8000592c <sys_link+0xde>
  ilock(ip);
    800058a2:	ffffe097          	auipc	ra,0xffffe
    800058a6:	326080e7          	jalr	806(ra) # 80003bc8 <ilock>
  if(ip->type == T_DIR){
    800058aa:	04449703          	lh	a4,68(s1)
    800058ae:	4785                	li	a5,1
    800058b0:	08f70463          	beq	a4,a5,80005938 <sys_link+0xea>
  ip->nlink++;
    800058b4:	04a4d783          	lhu	a5,74(s1)
    800058b8:	2785                	addiw	a5,a5,1
    800058ba:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058be:	8526                	mv	a0,s1
    800058c0:	ffffe097          	auipc	ra,0xffffe
    800058c4:	23e080e7          	jalr	574(ra) # 80003afe <iupdate>
  iunlock(ip);
    800058c8:	8526                	mv	a0,s1
    800058ca:	ffffe097          	auipc	ra,0xffffe
    800058ce:	3c0080e7          	jalr	960(ra) # 80003c8a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800058d2:	fd040593          	addi	a1,s0,-48
    800058d6:	f5040513          	addi	a0,s0,-176
    800058da:	fffff097          	auipc	ra,0xfffff
    800058de:	ab2080e7          	jalr	-1358(ra) # 8000438c <nameiparent>
    800058e2:	892a                	mv	s2,a0
    800058e4:	c935                	beqz	a0,80005958 <sys_link+0x10a>
  ilock(dp);
    800058e6:	ffffe097          	auipc	ra,0xffffe
    800058ea:	2e2080e7          	jalr	738(ra) # 80003bc8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800058ee:	00092703          	lw	a4,0(s2)
    800058f2:	409c                	lw	a5,0(s1)
    800058f4:	04f71d63          	bne	a4,a5,8000594e <sys_link+0x100>
    800058f8:	40d0                	lw	a2,4(s1)
    800058fa:	fd040593          	addi	a1,s0,-48
    800058fe:	854a                	mv	a0,s2
    80005900:	fffff097          	auipc	ra,0xfffff
    80005904:	9bc080e7          	jalr	-1604(ra) # 800042bc <dirlink>
    80005908:	04054363          	bltz	a0,8000594e <sys_link+0x100>
  iunlockput(dp);
    8000590c:	854a                	mv	a0,s2
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	51c080e7          	jalr	1308(ra) # 80003e2a <iunlockput>
  iput(ip);
    80005916:	8526                	mv	a0,s1
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	46a080e7          	jalr	1130(ra) # 80003d82 <iput>
  end_op();
    80005920:	fffff097          	auipc	ra,0xfffff
    80005924:	cea080e7          	jalr	-790(ra) # 8000460a <end_op>
  return 0;
    80005928:	4781                	li	a5,0
    8000592a:	a085                	j	8000598a <sys_link+0x13c>
    end_op();
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	cde080e7          	jalr	-802(ra) # 8000460a <end_op>
    return -1;
    80005934:	57fd                	li	a5,-1
    80005936:	a891                	j	8000598a <sys_link+0x13c>
    iunlockput(ip);
    80005938:	8526                	mv	a0,s1
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	4f0080e7          	jalr	1264(ra) # 80003e2a <iunlockput>
    end_op();
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	cc8080e7          	jalr	-824(ra) # 8000460a <end_op>
    return -1;
    8000594a:	57fd                	li	a5,-1
    8000594c:	a83d                	j	8000598a <sys_link+0x13c>
    iunlockput(dp);
    8000594e:	854a                	mv	a0,s2
    80005950:	ffffe097          	auipc	ra,0xffffe
    80005954:	4da080e7          	jalr	1242(ra) # 80003e2a <iunlockput>
  ilock(ip);
    80005958:	8526                	mv	a0,s1
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	26e080e7          	jalr	622(ra) # 80003bc8 <ilock>
  ip->nlink--;
    80005962:	04a4d783          	lhu	a5,74(s1)
    80005966:	37fd                	addiw	a5,a5,-1
    80005968:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000596c:	8526                	mv	a0,s1
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	190080e7          	jalr	400(ra) # 80003afe <iupdate>
  iunlockput(ip);
    80005976:	8526                	mv	a0,s1
    80005978:	ffffe097          	auipc	ra,0xffffe
    8000597c:	4b2080e7          	jalr	1202(ra) # 80003e2a <iunlockput>
  end_op();
    80005980:	fffff097          	auipc	ra,0xfffff
    80005984:	c8a080e7          	jalr	-886(ra) # 8000460a <end_op>
  return -1;
    80005988:	57fd                	li	a5,-1
}
    8000598a:	853e                	mv	a0,a5
    8000598c:	70b2                	ld	ra,296(sp)
    8000598e:	7412                	ld	s0,288(sp)
    80005990:	64f2                	ld	s1,280(sp)
    80005992:	6952                	ld	s2,272(sp)
    80005994:	6155                	addi	sp,sp,304
    80005996:	8082                	ret

0000000080005998 <sys_unlink>:
{
    80005998:	7151                	addi	sp,sp,-240
    8000599a:	f586                	sd	ra,232(sp)
    8000599c:	f1a2                	sd	s0,224(sp)
    8000599e:	eda6                	sd	s1,216(sp)
    800059a0:	e9ca                	sd	s2,208(sp)
    800059a2:	e5ce                	sd	s3,200(sp)
    800059a4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059a6:	08000613          	li	a2,128
    800059aa:	f3040593          	addi	a1,s0,-208
    800059ae:	4501                	li	a0,0
    800059b0:	ffffd097          	auipc	ra,0xffffd
    800059b4:	6ec080e7          	jalr	1772(ra) # 8000309c <argstr>
    800059b8:	18054163          	bltz	a0,80005b3a <sys_unlink+0x1a2>
  begin_op();
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	bce080e7          	jalr	-1074(ra) # 8000458a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800059c4:	fb040593          	addi	a1,s0,-80
    800059c8:	f3040513          	addi	a0,s0,-208
    800059cc:	fffff097          	auipc	ra,0xfffff
    800059d0:	9c0080e7          	jalr	-1600(ra) # 8000438c <nameiparent>
    800059d4:	84aa                	mv	s1,a0
    800059d6:	c979                	beqz	a0,80005aac <sys_unlink+0x114>
  ilock(dp);
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	1f0080e7          	jalr	496(ra) # 80003bc8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800059e0:	00003597          	auipc	a1,0x3
    800059e4:	d5858593          	addi	a1,a1,-680 # 80008738 <syscalls+0x2b8>
    800059e8:	fb040513          	addi	a0,s0,-80
    800059ec:	ffffe097          	auipc	ra,0xffffe
    800059f0:	6a6080e7          	jalr	1702(ra) # 80004092 <namecmp>
    800059f4:	14050a63          	beqz	a0,80005b48 <sys_unlink+0x1b0>
    800059f8:	00003597          	auipc	a1,0x3
    800059fc:	d4858593          	addi	a1,a1,-696 # 80008740 <syscalls+0x2c0>
    80005a00:	fb040513          	addi	a0,s0,-80
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	68e080e7          	jalr	1678(ra) # 80004092 <namecmp>
    80005a0c:	12050e63          	beqz	a0,80005b48 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a10:	f2c40613          	addi	a2,s0,-212
    80005a14:	fb040593          	addi	a1,s0,-80
    80005a18:	8526                	mv	a0,s1
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	692080e7          	jalr	1682(ra) # 800040ac <dirlookup>
    80005a22:	892a                	mv	s2,a0
    80005a24:	12050263          	beqz	a0,80005b48 <sys_unlink+0x1b0>
  ilock(ip);
    80005a28:	ffffe097          	auipc	ra,0xffffe
    80005a2c:	1a0080e7          	jalr	416(ra) # 80003bc8 <ilock>
  if(ip->nlink < 1)
    80005a30:	04a91783          	lh	a5,74(s2)
    80005a34:	08f05263          	blez	a5,80005ab8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a38:	04491703          	lh	a4,68(s2)
    80005a3c:	4785                	li	a5,1
    80005a3e:	08f70563          	beq	a4,a5,80005ac8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a42:	4641                	li	a2,16
    80005a44:	4581                	li	a1,0
    80005a46:	fc040513          	addi	a0,s0,-64
    80005a4a:	ffffb097          	auipc	ra,0xffffb
    80005a4e:	288080e7          	jalr	648(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a52:	4741                	li	a4,16
    80005a54:	f2c42683          	lw	a3,-212(s0)
    80005a58:	fc040613          	addi	a2,s0,-64
    80005a5c:	4581                	li	a1,0
    80005a5e:	8526                	mv	a0,s1
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	514080e7          	jalr	1300(ra) # 80003f74 <writei>
    80005a68:	47c1                	li	a5,16
    80005a6a:	0af51563          	bne	a0,a5,80005b14 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a6e:	04491703          	lh	a4,68(s2)
    80005a72:	4785                	li	a5,1
    80005a74:	0af70863          	beq	a4,a5,80005b24 <sys_unlink+0x18c>
  iunlockput(dp);
    80005a78:	8526                	mv	a0,s1
    80005a7a:	ffffe097          	auipc	ra,0xffffe
    80005a7e:	3b0080e7          	jalr	944(ra) # 80003e2a <iunlockput>
  ip->nlink--;
    80005a82:	04a95783          	lhu	a5,74(s2)
    80005a86:	37fd                	addiw	a5,a5,-1
    80005a88:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a8c:	854a                	mv	a0,s2
    80005a8e:	ffffe097          	auipc	ra,0xffffe
    80005a92:	070080e7          	jalr	112(ra) # 80003afe <iupdate>
  iunlockput(ip);
    80005a96:	854a                	mv	a0,s2
    80005a98:	ffffe097          	auipc	ra,0xffffe
    80005a9c:	392080e7          	jalr	914(ra) # 80003e2a <iunlockput>
  end_op();
    80005aa0:	fffff097          	auipc	ra,0xfffff
    80005aa4:	b6a080e7          	jalr	-1174(ra) # 8000460a <end_op>
  return 0;
    80005aa8:	4501                	li	a0,0
    80005aaa:	a84d                	j	80005b5c <sys_unlink+0x1c4>
    end_op();
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	b5e080e7          	jalr	-1186(ra) # 8000460a <end_op>
    return -1;
    80005ab4:	557d                	li	a0,-1
    80005ab6:	a05d                	j	80005b5c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005ab8:	00003517          	auipc	a0,0x3
    80005abc:	c9050513          	addi	a0,a0,-880 # 80008748 <syscalls+0x2c8>
    80005ac0:	ffffb097          	auipc	ra,0xffffb
    80005ac4:	a7e080e7          	jalr	-1410(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ac8:	04c92703          	lw	a4,76(s2)
    80005acc:	02000793          	li	a5,32
    80005ad0:	f6e7f9e3          	bgeu	a5,a4,80005a42 <sys_unlink+0xaa>
    80005ad4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ad8:	4741                	li	a4,16
    80005ada:	86ce                	mv	a3,s3
    80005adc:	f1840613          	addi	a2,s0,-232
    80005ae0:	4581                	li	a1,0
    80005ae2:	854a                	mv	a0,s2
    80005ae4:	ffffe097          	auipc	ra,0xffffe
    80005ae8:	398080e7          	jalr	920(ra) # 80003e7c <readi>
    80005aec:	47c1                	li	a5,16
    80005aee:	00f51b63          	bne	a0,a5,80005b04 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005af2:	f1845783          	lhu	a5,-232(s0)
    80005af6:	e7a1                	bnez	a5,80005b3e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005af8:	29c1                	addiw	s3,s3,16
    80005afa:	04c92783          	lw	a5,76(s2)
    80005afe:	fcf9ede3          	bltu	s3,a5,80005ad8 <sys_unlink+0x140>
    80005b02:	b781                	j	80005a42 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b04:	00003517          	auipc	a0,0x3
    80005b08:	c5c50513          	addi	a0,a0,-932 # 80008760 <syscalls+0x2e0>
    80005b0c:	ffffb097          	auipc	ra,0xffffb
    80005b10:	a32080e7          	jalr	-1486(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005b14:	00003517          	auipc	a0,0x3
    80005b18:	c6450513          	addi	a0,a0,-924 # 80008778 <syscalls+0x2f8>
    80005b1c:	ffffb097          	auipc	ra,0xffffb
    80005b20:	a22080e7          	jalr	-1502(ra) # 8000053e <panic>
    dp->nlink--;
    80005b24:	04a4d783          	lhu	a5,74(s1)
    80005b28:	37fd                	addiw	a5,a5,-1
    80005b2a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b2e:	8526                	mv	a0,s1
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	fce080e7          	jalr	-50(ra) # 80003afe <iupdate>
    80005b38:	b781                	j	80005a78 <sys_unlink+0xe0>
    return -1;
    80005b3a:	557d                	li	a0,-1
    80005b3c:	a005                	j	80005b5c <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b3e:	854a                	mv	a0,s2
    80005b40:	ffffe097          	auipc	ra,0xffffe
    80005b44:	2ea080e7          	jalr	746(ra) # 80003e2a <iunlockput>
  iunlockput(dp);
    80005b48:	8526                	mv	a0,s1
    80005b4a:	ffffe097          	auipc	ra,0xffffe
    80005b4e:	2e0080e7          	jalr	736(ra) # 80003e2a <iunlockput>
  end_op();
    80005b52:	fffff097          	auipc	ra,0xfffff
    80005b56:	ab8080e7          	jalr	-1352(ra) # 8000460a <end_op>
  return -1;
    80005b5a:	557d                	li	a0,-1
}
    80005b5c:	70ae                	ld	ra,232(sp)
    80005b5e:	740e                	ld	s0,224(sp)
    80005b60:	64ee                	ld	s1,216(sp)
    80005b62:	694e                	ld	s2,208(sp)
    80005b64:	69ae                	ld	s3,200(sp)
    80005b66:	616d                	addi	sp,sp,240
    80005b68:	8082                	ret

0000000080005b6a <sys_open>:

uint64
sys_open(void)
{
    80005b6a:	7131                	addi	sp,sp,-192
    80005b6c:	fd06                	sd	ra,184(sp)
    80005b6e:	f922                	sd	s0,176(sp)
    80005b70:	f526                	sd	s1,168(sp)
    80005b72:	f14a                	sd	s2,160(sp)
    80005b74:	ed4e                	sd	s3,152(sp)
    80005b76:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b78:	f4c40593          	addi	a1,s0,-180
    80005b7c:	4505                	li	a0,1
    80005b7e:	ffffd097          	auipc	ra,0xffffd
    80005b82:	4de080e7          	jalr	1246(ra) # 8000305c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b86:	08000613          	li	a2,128
    80005b8a:	f5040593          	addi	a1,s0,-176
    80005b8e:	4501                	li	a0,0
    80005b90:	ffffd097          	auipc	ra,0xffffd
    80005b94:	50c080e7          	jalr	1292(ra) # 8000309c <argstr>
    80005b98:	87aa                	mv	a5,a0
    return -1;
    80005b9a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b9c:	0a07c963          	bltz	a5,80005c4e <sys_open+0xe4>

  begin_op();
    80005ba0:	fffff097          	auipc	ra,0xfffff
    80005ba4:	9ea080e7          	jalr	-1558(ra) # 8000458a <begin_op>

  if(omode & O_CREATE){
    80005ba8:	f4c42783          	lw	a5,-180(s0)
    80005bac:	2007f793          	andi	a5,a5,512
    80005bb0:	cfc5                	beqz	a5,80005c68 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005bb2:	4681                	li	a3,0
    80005bb4:	4601                	li	a2,0
    80005bb6:	4589                	li	a1,2
    80005bb8:	f5040513          	addi	a0,s0,-176
    80005bbc:	00000097          	auipc	ra,0x0
    80005bc0:	976080e7          	jalr	-1674(ra) # 80005532 <create>
    80005bc4:	84aa                	mv	s1,a0
    if(ip == 0){
    80005bc6:	c959                	beqz	a0,80005c5c <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005bc8:	04449703          	lh	a4,68(s1)
    80005bcc:	478d                	li	a5,3
    80005bce:	00f71763          	bne	a4,a5,80005bdc <sys_open+0x72>
    80005bd2:	0464d703          	lhu	a4,70(s1)
    80005bd6:	47a5                	li	a5,9
    80005bd8:	0ce7ed63          	bltu	a5,a4,80005cb2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005bdc:	fffff097          	auipc	ra,0xfffff
    80005be0:	dbe080e7          	jalr	-578(ra) # 8000499a <filealloc>
    80005be4:	89aa                	mv	s3,a0
    80005be6:	10050363          	beqz	a0,80005cec <sys_open+0x182>
    80005bea:	00000097          	auipc	ra,0x0
    80005bee:	906080e7          	jalr	-1786(ra) # 800054f0 <fdalloc>
    80005bf2:	892a                	mv	s2,a0
    80005bf4:	0e054763          	bltz	a0,80005ce2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005bf8:	04449703          	lh	a4,68(s1)
    80005bfc:	478d                	li	a5,3
    80005bfe:	0cf70563          	beq	a4,a5,80005cc8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c02:	4789                	li	a5,2
    80005c04:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c08:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c0c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c10:	f4c42783          	lw	a5,-180(s0)
    80005c14:	0017c713          	xori	a4,a5,1
    80005c18:	8b05                	andi	a4,a4,1
    80005c1a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c1e:	0037f713          	andi	a4,a5,3
    80005c22:	00e03733          	snez	a4,a4
    80005c26:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c2a:	4007f793          	andi	a5,a5,1024
    80005c2e:	c791                	beqz	a5,80005c3a <sys_open+0xd0>
    80005c30:	04449703          	lh	a4,68(s1)
    80005c34:	4789                	li	a5,2
    80005c36:	0af70063          	beq	a4,a5,80005cd6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c3a:	8526                	mv	a0,s1
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	04e080e7          	jalr	78(ra) # 80003c8a <iunlock>
  end_op();
    80005c44:	fffff097          	auipc	ra,0xfffff
    80005c48:	9c6080e7          	jalr	-1594(ra) # 8000460a <end_op>

  return fd;
    80005c4c:	854a                	mv	a0,s2
}
    80005c4e:	70ea                	ld	ra,184(sp)
    80005c50:	744a                	ld	s0,176(sp)
    80005c52:	74aa                	ld	s1,168(sp)
    80005c54:	790a                	ld	s2,160(sp)
    80005c56:	69ea                	ld	s3,152(sp)
    80005c58:	6129                	addi	sp,sp,192
    80005c5a:	8082                	ret
      end_op();
    80005c5c:	fffff097          	auipc	ra,0xfffff
    80005c60:	9ae080e7          	jalr	-1618(ra) # 8000460a <end_op>
      return -1;
    80005c64:	557d                	li	a0,-1
    80005c66:	b7e5                	j	80005c4e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c68:	f5040513          	addi	a0,s0,-176
    80005c6c:	ffffe097          	auipc	ra,0xffffe
    80005c70:	702080e7          	jalr	1794(ra) # 8000436e <namei>
    80005c74:	84aa                	mv	s1,a0
    80005c76:	c905                	beqz	a0,80005ca6 <sys_open+0x13c>
    ilock(ip);
    80005c78:	ffffe097          	auipc	ra,0xffffe
    80005c7c:	f50080e7          	jalr	-176(ra) # 80003bc8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c80:	04449703          	lh	a4,68(s1)
    80005c84:	4785                	li	a5,1
    80005c86:	f4f711e3          	bne	a4,a5,80005bc8 <sys_open+0x5e>
    80005c8a:	f4c42783          	lw	a5,-180(s0)
    80005c8e:	d7b9                	beqz	a5,80005bdc <sys_open+0x72>
      iunlockput(ip);
    80005c90:	8526                	mv	a0,s1
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	198080e7          	jalr	408(ra) # 80003e2a <iunlockput>
      end_op();
    80005c9a:	fffff097          	auipc	ra,0xfffff
    80005c9e:	970080e7          	jalr	-1680(ra) # 8000460a <end_op>
      return -1;
    80005ca2:	557d                	li	a0,-1
    80005ca4:	b76d                	j	80005c4e <sys_open+0xe4>
      end_op();
    80005ca6:	fffff097          	auipc	ra,0xfffff
    80005caa:	964080e7          	jalr	-1692(ra) # 8000460a <end_op>
      return -1;
    80005cae:	557d                	li	a0,-1
    80005cb0:	bf79                	j	80005c4e <sys_open+0xe4>
    iunlockput(ip);
    80005cb2:	8526                	mv	a0,s1
    80005cb4:	ffffe097          	auipc	ra,0xffffe
    80005cb8:	176080e7          	jalr	374(ra) # 80003e2a <iunlockput>
    end_op();
    80005cbc:	fffff097          	auipc	ra,0xfffff
    80005cc0:	94e080e7          	jalr	-1714(ra) # 8000460a <end_op>
    return -1;
    80005cc4:	557d                	li	a0,-1
    80005cc6:	b761                	j	80005c4e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005cc8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ccc:	04649783          	lh	a5,70(s1)
    80005cd0:	02f99223          	sh	a5,36(s3)
    80005cd4:	bf25                	j	80005c0c <sys_open+0xa2>
    itrunc(ip);
    80005cd6:	8526                	mv	a0,s1
    80005cd8:	ffffe097          	auipc	ra,0xffffe
    80005cdc:	ffe080e7          	jalr	-2(ra) # 80003cd6 <itrunc>
    80005ce0:	bfa9                	j	80005c3a <sys_open+0xd0>
      fileclose(f);
    80005ce2:	854e                	mv	a0,s3
    80005ce4:	fffff097          	auipc	ra,0xfffff
    80005ce8:	d72080e7          	jalr	-654(ra) # 80004a56 <fileclose>
    iunlockput(ip);
    80005cec:	8526                	mv	a0,s1
    80005cee:	ffffe097          	auipc	ra,0xffffe
    80005cf2:	13c080e7          	jalr	316(ra) # 80003e2a <iunlockput>
    end_op();
    80005cf6:	fffff097          	auipc	ra,0xfffff
    80005cfa:	914080e7          	jalr	-1772(ra) # 8000460a <end_op>
    return -1;
    80005cfe:	557d                	li	a0,-1
    80005d00:	b7b9                	j	80005c4e <sys_open+0xe4>

0000000080005d02 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d02:	7175                	addi	sp,sp,-144
    80005d04:	e506                	sd	ra,136(sp)
    80005d06:	e122                	sd	s0,128(sp)
    80005d08:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d0a:	fffff097          	auipc	ra,0xfffff
    80005d0e:	880080e7          	jalr	-1920(ra) # 8000458a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d12:	08000613          	li	a2,128
    80005d16:	f7040593          	addi	a1,s0,-144
    80005d1a:	4501                	li	a0,0
    80005d1c:	ffffd097          	auipc	ra,0xffffd
    80005d20:	380080e7          	jalr	896(ra) # 8000309c <argstr>
    80005d24:	02054963          	bltz	a0,80005d56 <sys_mkdir+0x54>
    80005d28:	4681                	li	a3,0
    80005d2a:	4601                	li	a2,0
    80005d2c:	4585                	li	a1,1
    80005d2e:	f7040513          	addi	a0,s0,-144
    80005d32:	00000097          	auipc	ra,0x0
    80005d36:	800080e7          	jalr	-2048(ra) # 80005532 <create>
    80005d3a:	cd11                	beqz	a0,80005d56 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d3c:	ffffe097          	auipc	ra,0xffffe
    80005d40:	0ee080e7          	jalr	238(ra) # 80003e2a <iunlockput>
  end_op();
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	8c6080e7          	jalr	-1850(ra) # 8000460a <end_op>
  return 0;
    80005d4c:	4501                	li	a0,0
}
    80005d4e:	60aa                	ld	ra,136(sp)
    80005d50:	640a                	ld	s0,128(sp)
    80005d52:	6149                	addi	sp,sp,144
    80005d54:	8082                	ret
    end_op();
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	8b4080e7          	jalr	-1868(ra) # 8000460a <end_op>
    return -1;
    80005d5e:	557d                	li	a0,-1
    80005d60:	b7fd                	j	80005d4e <sys_mkdir+0x4c>

0000000080005d62 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d62:	7135                	addi	sp,sp,-160
    80005d64:	ed06                	sd	ra,152(sp)
    80005d66:	e922                	sd	s0,144(sp)
    80005d68:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d6a:	fffff097          	auipc	ra,0xfffff
    80005d6e:	820080e7          	jalr	-2016(ra) # 8000458a <begin_op>
  argint(1, &major);
    80005d72:	f6c40593          	addi	a1,s0,-148
    80005d76:	4505                	li	a0,1
    80005d78:	ffffd097          	auipc	ra,0xffffd
    80005d7c:	2e4080e7          	jalr	740(ra) # 8000305c <argint>
  argint(2, &minor);
    80005d80:	f6840593          	addi	a1,s0,-152
    80005d84:	4509                	li	a0,2
    80005d86:	ffffd097          	auipc	ra,0xffffd
    80005d8a:	2d6080e7          	jalr	726(ra) # 8000305c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d8e:	08000613          	li	a2,128
    80005d92:	f7040593          	addi	a1,s0,-144
    80005d96:	4501                	li	a0,0
    80005d98:	ffffd097          	auipc	ra,0xffffd
    80005d9c:	304080e7          	jalr	772(ra) # 8000309c <argstr>
    80005da0:	02054b63          	bltz	a0,80005dd6 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005da4:	f6841683          	lh	a3,-152(s0)
    80005da8:	f6c41603          	lh	a2,-148(s0)
    80005dac:	458d                	li	a1,3
    80005dae:	f7040513          	addi	a0,s0,-144
    80005db2:	fffff097          	auipc	ra,0xfffff
    80005db6:	780080e7          	jalr	1920(ra) # 80005532 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dba:	cd11                	beqz	a0,80005dd6 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dbc:	ffffe097          	auipc	ra,0xffffe
    80005dc0:	06e080e7          	jalr	110(ra) # 80003e2a <iunlockput>
  end_op();
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	846080e7          	jalr	-1978(ra) # 8000460a <end_op>
  return 0;
    80005dcc:	4501                	li	a0,0
}
    80005dce:	60ea                	ld	ra,152(sp)
    80005dd0:	644a                	ld	s0,144(sp)
    80005dd2:	610d                	addi	sp,sp,160
    80005dd4:	8082                	ret
    end_op();
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	834080e7          	jalr	-1996(ra) # 8000460a <end_op>
    return -1;
    80005dde:	557d                	li	a0,-1
    80005de0:	b7fd                	j	80005dce <sys_mknod+0x6c>

0000000080005de2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005de2:	7135                	addi	sp,sp,-160
    80005de4:	ed06                	sd	ra,152(sp)
    80005de6:	e922                	sd	s0,144(sp)
    80005de8:	e526                	sd	s1,136(sp)
    80005dea:	e14a                	sd	s2,128(sp)
    80005dec:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005dee:	ffffc097          	auipc	ra,0xffffc
    80005df2:	f86080e7          	jalr	-122(ra) # 80001d74 <myproc>
    80005df6:	892a                	mv	s2,a0
  
  begin_op();
    80005df8:	ffffe097          	auipc	ra,0xffffe
    80005dfc:	792080e7          	jalr	1938(ra) # 8000458a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e00:	08000613          	li	a2,128
    80005e04:	f6040593          	addi	a1,s0,-160
    80005e08:	4501                	li	a0,0
    80005e0a:	ffffd097          	auipc	ra,0xffffd
    80005e0e:	292080e7          	jalr	658(ra) # 8000309c <argstr>
    80005e12:	04054b63          	bltz	a0,80005e68 <sys_chdir+0x86>
    80005e16:	f6040513          	addi	a0,s0,-160
    80005e1a:	ffffe097          	auipc	ra,0xffffe
    80005e1e:	554080e7          	jalr	1364(ra) # 8000436e <namei>
    80005e22:	84aa                	mv	s1,a0
    80005e24:	c131                	beqz	a0,80005e68 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e26:	ffffe097          	auipc	ra,0xffffe
    80005e2a:	da2080e7          	jalr	-606(ra) # 80003bc8 <ilock>
  if(ip->type != T_DIR){
    80005e2e:	04449703          	lh	a4,68(s1)
    80005e32:	4785                	li	a5,1
    80005e34:	04f71063          	bne	a4,a5,80005e74 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e38:	8526                	mv	a0,s1
    80005e3a:	ffffe097          	auipc	ra,0xffffe
    80005e3e:	e50080e7          	jalr	-432(ra) # 80003c8a <iunlock>
  iput(p->cwd);
    80005e42:	15093503          	ld	a0,336(s2)
    80005e46:	ffffe097          	auipc	ra,0xffffe
    80005e4a:	f3c080e7          	jalr	-196(ra) # 80003d82 <iput>
  end_op();
    80005e4e:	ffffe097          	auipc	ra,0xffffe
    80005e52:	7bc080e7          	jalr	1980(ra) # 8000460a <end_op>
  p->cwd = ip;
    80005e56:	14993823          	sd	s1,336(s2)
  return 0;
    80005e5a:	4501                	li	a0,0
}
    80005e5c:	60ea                	ld	ra,152(sp)
    80005e5e:	644a                	ld	s0,144(sp)
    80005e60:	64aa                	ld	s1,136(sp)
    80005e62:	690a                	ld	s2,128(sp)
    80005e64:	610d                	addi	sp,sp,160
    80005e66:	8082                	ret
    end_op();
    80005e68:	ffffe097          	auipc	ra,0xffffe
    80005e6c:	7a2080e7          	jalr	1954(ra) # 8000460a <end_op>
    return -1;
    80005e70:	557d                	li	a0,-1
    80005e72:	b7ed                	j	80005e5c <sys_chdir+0x7a>
    iunlockput(ip);
    80005e74:	8526                	mv	a0,s1
    80005e76:	ffffe097          	auipc	ra,0xffffe
    80005e7a:	fb4080e7          	jalr	-76(ra) # 80003e2a <iunlockput>
    end_op();
    80005e7e:	ffffe097          	auipc	ra,0xffffe
    80005e82:	78c080e7          	jalr	1932(ra) # 8000460a <end_op>
    return -1;
    80005e86:	557d                	li	a0,-1
    80005e88:	bfd1                	j	80005e5c <sys_chdir+0x7a>

0000000080005e8a <sys_exec>:

uint64
sys_exec(void)
{
    80005e8a:	7145                	addi	sp,sp,-464
    80005e8c:	e786                	sd	ra,456(sp)
    80005e8e:	e3a2                	sd	s0,448(sp)
    80005e90:	ff26                	sd	s1,440(sp)
    80005e92:	fb4a                	sd	s2,432(sp)
    80005e94:	f74e                	sd	s3,424(sp)
    80005e96:	f352                	sd	s4,416(sp)
    80005e98:	ef56                	sd	s5,408(sp)
    80005e9a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e9c:	e3840593          	addi	a1,s0,-456
    80005ea0:	4505                	li	a0,1
    80005ea2:	ffffd097          	auipc	ra,0xffffd
    80005ea6:	1da080e7          	jalr	474(ra) # 8000307c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005eaa:	08000613          	li	a2,128
    80005eae:	f4040593          	addi	a1,s0,-192
    80005eb2:	4501                	li	a0,0
    80005eb4:	ffffd097          	auipc	ra,0xffffd
    80005eb8:	1e8080e7          	jalr	488(ra) # 8000309c <argstr>
    80005ebc:	87aa                	mv	a5,a0
    return -1;
    80005ebe:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005ec0:	0c07c263          	bltz	a5,80005f84 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005ec4:	10000613          	li	a2,256
    80005ec8:	4581                	li	a1,0
    80005eca:	e4040513          	addi	a0,s0,-448
    80005ece:	ffffb097          	auipc	ra,0xffffb
    80005ed2:	e04080e7          	jalr	-508(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ed6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005eda:	89a6                	mv	s3,s1
    80005edc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ede:	02000a13          	li	s4,32
    80005ee2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ee6:	00391793          	slli	a5,s2,0x3
    80005eea:	e3040593          	addi	a1,s0,-464
    80005eee:	e3843503          	ld	a0,-456(s0)
    80005ef2:	953e                	add	a0,a0,a5
    80005ef4:	ffffd097          	auipc	ra,0xffffd
    80005ef8:	0ca080e7          	jalr	202(ra) # 80002fbe <fetchaddr>
    80005efc:	02054a63          	bltz	a0,80005f30 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f00:	e3043783          	ld	a5,-464(s0)
    80005f04:	c3b9                	beqz	a5,80005f4a <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f06:	ffffb097          	auipc	ra,0xffffb
    80005f0a:	be0080e7          	jalr	-1056(ra) # 80000ae6 <kalloc>
    80005f0e:	85aa                	mv	a1,a0
    80005f10:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f14:	cd11                	beqz	a0,80005f30 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f16:	6605                	lui	a2,0x1
    80005f18:	e3043503          	ld	a0,-464(s0)
    80005f1c:	ffffd097          	auipc	ra,0xffffd
    80005f20:	0f4080e7          	jalr	244(ra) # 80003010 <fetchstr>
    80005f24:	00054663          	bltz	a0,80005f30 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f28:	0905                	addi	s2,s2,1
    80005f2a:	09a1                	addi	s3,s3,8
    80005f2c:	fb491be3          	bne	s2,s4,80005ee2 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f30:	10048913          	addi	s2,s1,256
    80005f34:	6088                	ld	a0,0(s1)
    80005f36:	c531                	beqz	a0,80005f82 <sys_exec+0xf8>
    kfree(argv[i]);
    80005f38:	ffffb097          	auipc	ra,0xffffb
    80005f3c:	ab2080e7          	jalr	-1358(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f40:	04a1                	addi	s1,s1,8
    80005f42:	ff2499e3          	bne	s1,s2,80005f34 <sys_exec+0xaa>
  return -1;
    80005f46:	557d                	li	a0,-1
    80005f48:	a835                	j	80005f84 <sys_exec+0xfa>
      argv[i] = 0;
    80005f4a:	0a8e                	slli	s5,s5,0x3
    80005f4c:	fc040793          	addi	a5,s0,-64
    80005f50:	9abe                	add	s5,s5,a5
    80005f52:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f56:	e4040593          	addi	a1,s0,-448
    80005f5a:	f4040513          	addi	a0,s0,-192
    80005f5e:	fffff097          	auipc	ra,0xfffff
    80005f62:	172080e7          	jalr	370(ra) # 800050d0 <exec>
    80005f66:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f68:	10048993          	addi	s3,s1,256
    80005f6c:	6088                	ld	a0,0(s1)
    80005f6e:	c901                	beqz	a0,80005f7e <sys_exec+0xf4>
    kfree(argv[i]);
    80005f70:	ffffb097          	auipc	ra,0xffffb
    80005f74:	a7a080e7          	jalr	-1414(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f78:	04a1                	addi	s1,s1,8
    80005f7a:	ff3499e3          	bne	s1,s3,80005f6c <sys_exec+0xe2>
  return ret;
    80005f7e:	854a                	mv	a0,s2
    80005f80:	a011                	j	80005f84 <sys_exec+0xfa>
  return -1;
    80005f82:	557d                	li	a0,-1
}
    80005f84:	60be                	ld	ra,456(sp)
    80005f86:	641e                	ld	s0,448(sp)
    80005f88:	74fa                	ld	s1,440(sp)
    80005f8a:	795a                	ld	s2,432(sp)
    80005f8c:	79ba                	ld	s3,424(sp)
    80005f8e:	7a1a                	ld	s4,416(sp)
    80005f90:	6afa                	ld	s5,408(sp)
    80005f92:	6179                	addi	sp,sp,464
    80005f94:	8082                	ret

0000000080005f96 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f96:	7139                	addi	sp,sp,-64
    80005f98:	fc06                	sd	ra,56(sp)
    80005f9a:	f822                	sd	s0,48(sp)
    80005f9c:	f426                	sd	s1,40(sp)
    80005f9e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005fa0:	ffffc097          	auipc	ra,0xffffc
    80005fa4:	dd4080e7          	jalr	-556(ra) # 80001d74 <myproc>
    80005fa8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005faa:	fd840593          	addi	a1,s0,-40
    80005fae:	4501                	li	a0,0
    80005fb0:	ffffd097          	auipc	ra,0xffffd
    80005fb4:	0cc080e7          	jalr	204(ra) # 8000307c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005fb8:	fc840593          	addi	a1,s0,-56
    80005fbc:	fd040513          	addi	a0,s0,-48
    80005fc0:	fffff097          	auipc	ra,0xfffff
    80005fc4:	dc6080e7          	jalr	-570(ra) # 80004d86 <pipealloc>
    return -1;
    80005fc8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005fca:	0c054463          	bltz	a0,80006092 <sys_pipe+0xfc>
  fd0 = -1;
    80005fce:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005fd2:	fd043503          	ld	a0,-48(s0)
    80005fd6:	fffff097          	auipc	ra,0xfffff
    80005fda:	51a080e7          	jalr	1306(ra) # 800054f0 <fdalloc>
    80005fde:	fca42223          	sw	a0,-60(s0)
    80005fe2:	08054b63          	bltz	a0,80006078 <sys_pipe+0xe2>
    80005fe6:	fc843503          	ld	a0,-56(s0)
    80005fea:	fffff097          	auipc	ra,0xfffff
    80005fee:	506080e7          	jalr	1286(ra) # 800054f0 <fdalloc>
    80005ff2:	fca42023          	sw	a0,-64(s0)
    80005ff6:	06054863          	bltz	a0,80006066 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ffa:	4691                	li	a3,4
    80005ffc:	fc440613          	addi	a2,s0,-60
    80006000:	fd843583          	ld	a1,-40(s0)
    80006004:	68a8                	ld	a0,80(s1)
    80006006:	ffffb097          	auipc	ra,0xffffb
    8000600a:	662080e7          	jalr	1634(ra) # 80001668 <copyout>
    8000600e:	02054063          	bltz	a0,8000602e <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006012:	4691                	li	a3,4
    80006014:	fc040613          	addi	a2,s0,-64
    80006018:	fd843583          	ld	a1,-40(s0)
    8000601c:	0591                	addi	a1,a1,4
    8000601e:	68a8                	ld	a0,80(s1)
    80006020:	ffffb097          	auipc	ra,0xffffb
    80006024:	648080e7          	jalr	1608(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006028:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000602a:	06055463          	bgez	a0,80006092 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000602e:	fc442783          	lw	a5,-60(s0)
    80006032:	07e9                	addi	a5,a5,26
    80006034:	078e                	slli	a5,a5,0x3
    80006036:	97a6                	add	a5,a5,s1
    80006038:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000603c:	fc042503          	lw	a0,-64(s0)
    80006040:	0569                	addi	a0,a0,26
    80006042:	050e                	slli	a0,a0,0x3
    80006044:	94aa                	add	s1,s1,a0
    80006046:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000604a:	fd043503          	ld	a0,-48(s0)
    8000604e:	fffff097          	auipc	ra,0xfffff
    80006052:	a08080e7          	jalr	-1528(ra) # 80004a56 <fileclose>
    fileclose(wf);
    80006056:	fc843503          	ld	a0,-56(s0)
    8000605a:	fffff097          	auipc	ra,0xfffff
    8000605e:	9fc080e7          	jalr	-1540(ra) # 80004a56 <fileclose>
    return -1;
    80006062:	57fd                	li	a5,-1
    80006064:	a03d                	j	80006092 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006066:	fc442783          	lw	a5,-60(s0)
    8000606a:	0007c763          	bltz	a5,80006078 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000606e:	07e9                	addi	a5,a5,26
    80006070:	078e                	slli	a5,a5,0x3
    80006072:	94be                	add	s1,s1,a5
    80006074:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006078:	fd043503          	ld	a0,-48(s0)
    8000607c:	fffff097          	auipc	ra,0xfffff
    80006080:	9da080e7          	jalr	-1574(ra) # 80004a56 <fileclose>
    fileclose(wf);
    80006084:	fc843503          	ld	a0,-56(s0)
    80006088:	fffff097          	auipc	ra,0xfffff
    8000608c:	9ce080e7          	jalr	-1586(ra) # 80004a56 <fileclose>
    return -1;
    80006090:	57fd                	li	a5,-1
}
    80006092:	853e                	mv	a0,a5
    80006094:	70e2                	ld	ra,56(sp)
    80006096:	7442                	ld	s0,48(sp)
    80006098:	74a2                	ld	s1,40(sp)
    8000609a:	6121                	addi	sp,sp,64
    8000609c:	8082                	ret
	...

00000000800060a0 <kernelvec>:
    800060a0:	7111                	addi	sp,sp,-256
    800060a2:	e006                	sd	ra,0(sp)
    800060a4:	e40a                	sd	sp,8(sp)
    800060a6:	e80e                	sd	gp,16(sp)
    800060a8:	ec12                	sd	tp,24(sp)
    800060aa:	f016                	sd	t0,32(sp)
    800060ac:	f41a                	sd	t1,40(sp)
    800060ae:	f81e                	sd	t2,48(sp)
    800060b0:	fc22                	sd	s0,56(sp)
    800060b2:	e0a6                	sd	s1,64(sp)
    800060b4:	e4aa                	sd	a0,72(sp)
    800060b6:	e8ae                	sd	a1,80(sp)
    800060b8:	ecb2                	sd	a2,88(sp)
    800060ba:	f0b6                	sd	a3,96(sp)
    800060bc:	f4ba                	sd	a4,104(sp)
    800060be:	f8be                	sd	a5,112(sp)
    800060c0:	fcc2                	sd	a6,120(sp)
    800060c2:	e146                	sd	a7,128(sp)
    800060c4:	e54a                	sd	s2,136(sp)
    800060c6:	e94e                	sd	s3,144(sp)
    800060c8:	ed52                	sd	s4,152(sp)
    800060ca:	f156                	sd	s5,160(sp)
    800060cc:	f55a                	sd	s6,168(sp)
    800060ce:	f95e                	sd	s7,176(sp)
    800060d0:	fd62                	sd	s8,184(sp)
    800060d2:	e1e6                	sd	s9,192(sp)
    800060d4:	e5ea                	sd	s10,200(sp)
    800060d6:	e9ee                	sd	s11,208(sp)
    800060d8:	edf2                	sd	t3,216(sp)
    800060da:	f1f6                	sd	t4,224(sp)
    800060dc:	f5fa                	sd	t5,232(sp)
    800060de:	f9fe                	sd	t6,240(sp)
    800060e0:	d9dfc0ef          	jal	ra,80002e7c <kerneltrap>
    800060e4:	6082                	ld	ra,0(sp)
    800060e6:	6122                	ld	sp,8(sp)
    800060e8:	61c2                	ld	gp,16(sp)
    800060ea:	7282                	ld	t0,32(sp)
    800060ec:	7322                	ld	t1,40(sp)
    800060ee:	73c2                	ld	t2,48(sp)
    800060f0:	7462                	ld	s0,56(sp)
    800060f2:	6486                	ld	s1,64(sp)
    800060f4:	6526                	ld	a0,72(sp)
    800060f6:	65c6                	ld	a1,80(sp)
    800060f8:	6666                	ld	a2,88(sp)
    800060fa:	7686                	ld	a3,96(sp)
    800060fc:	7726                	ld	a4,104(sp)
    800060fe:	77c6                	ld	a5,112(sp)
    80006100:	7866                	ld	a6,120(sp)
    80006102:	688a                	ld	a7,128(sp)
    80006104:	692a                	ld	s2,136(sp)
    80006106:	69ca                	ld	s3,144(sp)
    80006108:	6a6a                	ld	s4,152(sp)
    8000610a:	7a8a                	ld	s5,160(sp)
    8000610c:	7b2a                	ld	s6,168(sp)
    8000610e:	7bca                	ld	s7,176(sp)
    80006110:	7c6a                	ld	s8,184(sp)
    80006112:	6c8e                	ld	s9,192(sp)
    80006114:	6d2e                	ld	s10,200(sp)
    80006116:	6dce                	ld	s11,208(sp)
    80006118:	6e6e                	ld	t3,216(sp)
    8000611a:	7e8e                	ld	t4,224(sp)
    8000611c:	7f2e                	ld	t5,232(sp)
    8000611e:	7fce                	ld	t6,240(sp)
    80006120:	6111                	addi	sp,sp,256
    80006122:	10200073          	sret
    80006126:	00000013          	nop
    8000612a:	00000013          	nop
    8000612e:	0001                	nop

0000000080006130 <timervec>:
    80006130:	34051573          	csrrw	a0,mscratch,a0
    80006134:	e10c                	sd	a1,0(a0)
    80006136:	e510                	sd	a2,8(a0)
    80006138:	e914                	sd	a3,16(a0)
    8000613a:	6d0c                	ld	a1,24(a0)
    8000613c:	7110                	ld	a2,32(a0)
    8000613e:	6194                	ld	a3,0(a1)
    80006140:	96b2                	add	a3,a3,a2
    80006142:	e194                	sd	a3,0(a1)
    80006144:	4589                	li	a1,2
    80006146:	14459073          	csrw	sip,a1
    8000614a:	6914                	ld	a3,16(a0)
    8000614c:	6510                	ld	a2,8(a0)
    8000614e:	610c                	ld	a1,0(a0)
    80006150:	34051573          	csrrw	a0,mscratch,a0
    80006154:	30200073          	mret
	...

000000008000615a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000615a:	1141                	addi	sp,sp,-16
    8000615c:	e422                	sd	s0,8(sp)
    8000615e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006160:	0c0007b7          	lui	a5,0xc000
    80006164:	4705                	li	a4,1
    80006166:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006168:	c3d8                	sw	a4,4(a5)
}
    8000616a:	6422                	ld	s0,8(sp)
    8000616c:	0141                	addi	sp,sp,16
    8000616e:	8082                	ret

0000000080006170 <plicinithart>:

void
plicinithart(void)
{
    80006170:	1141                	addi	sp,sp,-16
    80006172:	e406                	sd	ra,8(sp)
    80006174:	e022                	sd	s0,0(sp)
    80006176:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006178:	ffffc097          	auipc	ra,0xffffc
    8000617c:	bd0080e7          	jalr	-1072(ra) # 80001d48 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006180:	0085171b          	slliw	a4,a0,0x8
    80006184:	0c0027b7          	lui	a5,0xc002
    80006188:	97ba                	add	a5,a5,a4
    8000618a:	40200713          	li	a4,1026
    8000618e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006192:	00d5151b          	slliw	a0,a0,0xd
    80006196:	0c2017b7          	lui	a5,0xc201
    8000619a:	953e                	add	a0,a0,a5
    8000619c:	00052023          	sw	zero,0(a0)
}
    800061a0:	60a2                	ld	ra,8(sp)
    800061a2:	6402                	ld	s0,0(sp)
    800061a4:	0141                	addi	sp,sp,16
    800061a6:	8082                	ret

00000000800061a8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800061a8:	1141                	addi	sp,sp,-16
    800061aa:	e406                	sd	ra,8(sp)
    800061ac:	e022                	sd	s0,0(sp)
    800061ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061b0:	ffffc097          	auipc	ra,0xffffc
    800061b4:	b98080e7          	jalr	-1128(ra) # 80001d48 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800061b8:	00d5179b          	slliw	a5,a0,0xd
    800061bc:	0c201537          	lui	a0,0xc201
    800061c0:	953e                	add	a0,a0,a5
  return irq;
}
    800061c2:	4148                	lw	a0,4(a0)
    800061c4:	60a2                	ld	ra,8(sp)
    800061c6:	6402                	ld	s0,0(sp)
    800061c8:	0141                	addi	sp,sp,16
    800061ca:	8082                	ret

00000000800061cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800061cc:	1101                	addi	sp,sp,-32
    800061ce:	ec06                	sd	ra,24(sp)
    800061d0:	e822                	sd	s0,16(sp)
    800061d2:	e426                	sd	s1,8(sp)
    800061d4:	1000                	addi	s0,sp,32
    800061d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800061d8:	ffffc097          	auipc	ra,0xffffc
    800061dc:	b70080e7          	jalr	-1168(ra) # 80001d48 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800061e0:	00d5151b          	slliw	a0,a0,0xd
    800061e4:	0c2017b7          	lui	a5,0xc201
    800061e8:	97aa                	add	a5,a5,a0
    800061ea:	c3c4                	sw	s1,4(a5)
}
    800061ec:	60e2                	ld	ra,24(sp)
    800061ee:	6442                	ld	s0,16(sp)
    800061f0:	64a2                	ld	s1,8(sp)
    800061f2:	6105                	addi	sp,sp,32
    800061f4:	8082                	ret

00000000800061f6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800061f6:	1141                	addi	sp,sp,-16
    800061f8:	e406                	sd	ra,8(sp)
    800061fa:	e022                	sd	s0,0(sp)
    800061fc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800061fe:	479d                	li	a5,7
    80006200:	04a7cc63          	blt	a5,a0,80006258 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006204:	0001d797          	auipc	a5,0x1d
    80006208:	82c78793          	addi	a5,a5,-2004 # 80022a30 <disk>
    8000620c:	97aa                	add	a5,a5,a0
    8000620e:	0187c783          	lbu	a5,24(a5)
    80006212:	ebb9                	bnez	a5,80006268 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006214:	00451613          	slli	a2,a0,0x4
    80006218:	0001d797          	auipc	a5,0x1d
    8000621c:	81878793          	addi	a5,a5,-2024 # 80022a30 <disk>
    80006220:	6394                	ld	a3,0(a5)
    80006222:	96b2                	add	a3,a3,a2
    80006224:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006228:	6398                	ld	a4,0(a5)
    8000622a:	9732                	add	a4,a4,a2
    8000622c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006230:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006234:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006238:	953e                	add	a0,a0,a5
    8000623a:	4785                	li	a5,1
    8000623c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006240:	0001d517          	auipc	a0,0x1d
    80006244:	80850513          	addi	a0,a0,-2040 # 80022a48 <disk+0x18>
    80006248:	ffffc097          	auipc	ra,0xffffc
    8000624c:	39a080e7          	jalr	922(ra) # 800025e2 <wakeup>
}
    80006250:	60a2                	ld	ra,8(sp)
    80006252:	6402                	ld	s0,0(sp)
    80006254:	0141                	addi	sp,sp,16
    80006256:	8082                	ret
    panic("free_desc 1");
    80006258:	00002517          	auipc	a0,0x2
    8000625c:	53050513          	addi	a0,a0,1328 # 80008788 <syscalls+0x308>
    80006260:	ffffa097          	auipc	ra,0xffffa
    80006264:	2de080e7          	jalr	734(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006268:	00002517          	auipc	a0,0x2
    8000626c:	53050513          	addi	a0,a0,1328 # 80008798 <syscalls+0x318>
    80006270:	ffffa097          	auipc	ra,0xffffa
    80006274:	2ce080e7          	jalr	718(ra) # 8000053e <panic>

0000000080006278 <virtio_disk_init>:
{
    80006278:	1101                	addi	sp,sp,-32
    8000627a:	ec06                	sd	ra,24(sp)
    8000627c:	e822                	sd	s0,16(sp)
    8000627e:	e426                	sd	s1,8(sp)
    80006280:	e04a                	sd	s2,0(sp)
    80006282:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006284:	00002597          	auipc	a1,0x2
    80006288:	52458593          	addi	a1,a1,1316 # 800087a8 <syscalls+0x328>
    8000628c:	0001d517          	auipc	a0,0x1d
    80006290:	8cc50513          	addi	a0,a0,-1844 # 80022b58 <disk+0x128>
    80006294:	ffffb097          	auipc	ra,0xffffb
    80006298:	8b2080e7          	jalr	-1870(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000629c:	100017b7          	lui	a5,0x10001
    800062a0:	4398                	lw	a4,0(a5)
    800062a2:	2701                	sext.w	a4,a4
    800062a4:	747277b7          	lui	a5,0x74727
    800062a8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800062ac:	14f71c63          	bne	a4,a5,80006404 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062b0:	100017b7          	lui	a5,0x10001
    800062b4:	43dc                	lw	a5,4(a5)
    800062b6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062b8:	4709                	li	a4,2
    800062ba:	14e79563          	bne	a5,a4,80006404 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062be:	100017b7          	lui	a5,0x10001
    800062c2:	479c                	lw	a5,8(a5)
    800062c4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062c6:	12e79f63          	bne	a5,a4,80006404 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800062ca:	100017b7          	lui	a5,0x10001
    800062ce:	47d8                	lw	a4,12(a5)
    800062d0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062d2:	554d47b7          	lui	a5,0x554d4
    800062d6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800062da:	12f71563          	bne	a4,a5,80006404 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062de:	100017b7          	lui	a5,0x10001
    800062e2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062e6:	4705                	li	a4,1
    800062e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062ea:	470d                	li	a4,3
    800062ec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800062ee:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800062f0:	c7ffe737          	lui	a4,0xc7ffe
    800062f4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdbbef>
    800062f8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062fa:	2701                	sext.w	a4,a4
    800062fc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062fe:	472d                	li	a4,11
    80006300:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006302:	5bbc                	lw	a5,112(a5)
    80006304:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006308:	8ba1                	andi	a5,a5,8
    8000630a:	10078563          	beqz	a5,80006414 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000630e:	100017b7          	lui	a5,0x10001
    80006312:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006316:	43fc                	lw	a5,68(a5)
    80006318:	2781                	sext.w	a5,a5
    8000631a:	10079563          	bnez	a5,80006424 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000631e:	100017b7          	lui	a5,0x10001
    80006322:	5bdc                	lw	a5,52(a5)
    80006324:	2781                	sext.w	a5,a5
  if(max == 0)
    80006326:	10078763          	beqz	a5,80006434 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000632a:	471d                	li	a4,7
    8000632c:	10f77c63          	bgeu	a4,a5,80006444 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006330:	ffffa097          	auipc	ra,0xffffa
    80006334:	7b6080e7          	jalr	1974(ra) # 80000ae6 <kalloc>
    80006338:	0001c497          	auipc	s1,0x1c
    8000633c:	6f848493          	addi	s1,s1,1784 # 80022a30 <disk>
    80006340:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006342:	ffffa097          	auipc	ra,0xffffa
    80006346:	7a4080e7          	jalr	1956(ra) # 80000ae6 <kalloc>
    8000634a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000634c:	ffffa097          	auipc	ra,0xffffa
    80006350:	79a080e7          	jalr	1946(ra) # 80000ae6 <kalloc>
    80006354:	87aa                	mv	a5,a0
    80006356:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006358:	6088                	ld	a0,0(s1)
    8000635a:	cd6d                	beqz	a0,80006454 <virtio_disk_init+0x1dc>
    8000635c:	0001c717          	auipc	a4,0x1c
    80006360:	6dc73703          	ld	a4,1756(a4) # 80022a38 <disk+0x8>
    80006364:	cb65                	beqz	a4,80006454 <virtio_disk_init+0x1dc>
    80006366:	c7fd                	beqz	a5,80006454 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006368:	6605                	lui	a2,0x1
    8000636a:	4581                	li	a1,0
    8000636c:	ffffb097          	auipc	ra,0xffffb
    80006370:	966080e7          	jalr	-1690(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006374:	0001c497          	auipc	s1,0x1c
    80006378:	6bc48493          	addi	s1,s1,1724 # 80022a30 <disk>
    8000637c:	6605                	lui	a2,0x1
    8000637e:	4581                	li	a1,0
    80006380:	6488                	ld	a0,8(s1)
    80006382:	ffffb097          	auipc	ra,0xffffb
    80006386:	950080e7          	jalr	-1712(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000638a:	6605                	lui	a2,0x1
    8000638c:	4581                	li	a1,0
    8000638e:	6888                	ld	a0,16(s1)
    80006390:	ffffb097          	auipc	ra,0xffffb
    80006394:	942080e7          	jalr	-1726(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006398:	100017b7          	lui	a5,0x10001
    8000639c:	4721                	li	a4,8
    8000639e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800063a0:	4098                	lw	a4,0(s1)
    800063a2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800063a6:	40d8                	lw	a4,4(s1)
    800063a8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800063ac:	6498                	ld	a4,8(s1)
    800063ae:	0007069b          	sext.w	a3,a4
    800063b2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800063b6:	9701                	srai	a4,a4,0x20
    800063b8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800063bc:	6898                	ld	a4,16(s1)
    800063be:	0007069b          	sext.w	a3,a4
    800063c2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800063c6:	9701                	srai	a4,a4,0x20
    800063c8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800063cc:	4705                	li	a4,1
    800063ce:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800063d0:	00e48c23          	sb	a4,24(s1)
    800063d4:	00e48ca3          	sb	a4,25(s1)
    800063d8:	00e48d23          	sb	a4,26(s1)
    800063dc:	00e48da3          	sb	a4,27(s1)
    800063e0:	00e48e23          	sb	a4,28(s1)
    800063e4:	00e48ea3          	sb	a4,29(s1)
    800063e8:	00e48f23          	sb	a4,30(s1)
    800063ec:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800063f0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800063f4:	0727a823          	sw	s2,112(a5)
}
    800063f8:	60e2                	ld	ra,24(sp)
    800063fa:	6442                	ld	s0,16(sp)
    800063fc:	64a2                	ld	s1,8(sp)
    800063fe:	6902                	ld	s2,0(sp)
    80006400:	6105                	addi	sp,sp,32
    80006402:	8082                	ret
    panic("could not find virtio disk");
    80006404:	00002517          	auipc	a0,0x2
    80006408:	3b450513          	addi	a0,a0,948 # 800087b8 <syscalls+0x338>
    8000640c:	ffffa097          	auipc	ra,0xffffa
    80006410:	132080e7          	jalr	306(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006414:	00002517          	auipc	a0,0x2
    80006418:	3c450513          	addi	a0,a0,964 # 800087d8 <syscalls+0x358>
    8000641c:	ffffa097          	auipc	ra,0xffffa
    80006420:	122080e7          	jalr	290(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006424:	00002517          	auipc	a0,0x2
    80006428:	3d450513          	addi	a0,a0,980 # 800087f8 <syscalls+0x378>
    8000642c:	ffffa097          	auipc	ra,0xffffa
    80006430:	112080e7          	jalr	274(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006434:	00002517          	auipc	a0,0x2
    80006438:	3e450513          	addi	a0,a0,996 # 80008818 <syscalls+0x398>
    8000643c:	ffffa097          	auipc	ra,0xffffa
    80006440:	102080e7          	jalr	258(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006444:	00002517          	auipc	a0,0x2
    80006448:	3f450513          	addi	a0,a0,1012 # 80008838 <syscalls+0x3b8>
    8000644c:	ffffa097          	auipc	ra,0xffffa
    80006450:	0f2080e7          	jalr	242(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006454:	00002517          	auipc	a0,0x2
    80006458:	40450513          	addi	a0,a0,1028 # 80008858 <syscalls+0x3d8>
    8000645c:	ffffa097          	auipc	ra,0xffffa
    80006460:	0e2080e7          	jalr	226(ra) # 8000053e <panic>

0000000080006464 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006464:	7119                	addi	sp,sp,-128
    80006466:	fc86                	sd	ra,120(sp)
    80006468:	f8a2                	sd	s0,112(sp)
    8000646a:	f4a6                	sd	s1,104(sp)
    8000646c:	f0ca                	sd	s2,96(sp)
    8000646e:	ecce                	sd	s3,88(sp)
    80006470:	e8d2                	sd	s4,80(sp)
    80006472:	e4d6                	sd	s5,72(sp)
    80006474:	e0da                	sd	s6,64(sp)
    80006476:	fc5e                	sd	s7,56(sp)
    80006478:	f862                	sd	s8,48(sp)
    8000647a:	f466                	sd	s9,40(sp)
    8000647c:	f06a                	sd	s10,32(sp)
    8000647e:	ec6e                	sd	s11,24(sp)
    80006480:	0100                	addi	s0,sp,128
    80006482:	8aaa                	mv	s5,a0
    80006484:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006486:	00c52d03          	lw	s10,12(a0)
    8000648a:	001d1d1b          	slliw	s10,s10,0x1
    8000648e:	1d02                	slli	s10,s10,0x20
    80006490:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006494:	0001c517          	auipc	a0,0x1c
    80006498:	6c450513          	addi	a0,a0,1732 # 80022b58 <disk+0x128>
    8000649c:	ffffa097          	auipc	ra,0xffffa
    800064a0:	73a080e7          	jalr	1850(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800064a4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064a6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064a8:	0001cb97          	auipc	s7,0x1c
    800064ac:	588b8b93          	addi	s7,s7,1416 # 80022a30 <disk>
  for(int i = 0; i < 3; i++){
    800064b0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064b2:	0001cc97          	auipc	s9,0x1c
    800064b6:	6a6c8c93          	addi	s9,s9,1702 # 80022b58 <disk+0x128>
    800064ba:	a08d                	j	8000651c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800064bc:	00fb8733          	add	a4,s7,a5
    800064c0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064c4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064c6:	0207c563          	bltz	a5,800064f0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800064ca:	2905                	addiw	s2,s2,1
    800064cc:	0611                	addi	a2,a2,4
    800064ce:	05690c63          	beq	s2,s6,80006526 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800064d2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800064d4:	0001c717          	auipc	a4,0x1c
    800064d8:	55c70713          	addi	a4,a4,1372 # 80022a30 <disk>
    800064dc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800064de:	01874683          	lbu	a3,24(a4)
    800064e2:	fee9                	bnez	a3,800064bc <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800064e4:	2785                	addiw	a5,a5,1
    800064e6:	0705                	addi	a4,a4,1
    800064e8:	fe979be3          	bne	a5,s1,800064de <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800064ec:	57fd                	li	a5,-1
    800064ee:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800064f0:	01205d63          	blez	s2,8000650a <virtio_disk_rw+0xa6>
    800064f4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800064f6:	000a2503          	lw	a0,0(s4)
    800064fa:	00000097          	auipc	ra,0x0
    800064fe:	cfc080e7          	jalr	-772(ra) # 800061f6 <free_desc>
      for(int j = 0; j < i; j++)
    80006502:	2d85                	addiw	s11,s11,1
    80006504:	0a11                	addi	s4,s4,4
    80006506:	ffb918e3          	bne	s2,s11,800064f6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000650a:	85e6                	mv	a1,s9
    8000650c:	0001c517          	auipc	a0,0x1c
    80006510:	53c50513          	addi	a0,a0,1340 # 80022a48 <disk+0x18>
    80006514:	ffffc097          	auipc	ra,0xffffc
    80006518:	06a080e7          	jalr	106(ra) # 8000257e <sleep>
  for(int i = 0; i < 3; i++){
    8000651c:	f8040a13          	addi	s4,s0,-128
{
    80006520:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006522:	894e                	mv	s2,s3
    80006524:	b77d                	j	800064d2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006526:	f8042583          	lw	a1,-128(s0)
    8000652a:	00a58793          	addi	a5,a1,10
    8000652e:	0792                	slli	a5,a5,0x4

  if(write)
    80006530:	0001c617          	auipc	a2,0x1c
    80006534:	50060613          	addi	a2,a2,1280 # 80022a30 <disk>
    80006538:	00f60733          	add	a4,a2,a5
    8000653c:	018036b3          	snez	a3,s8
    80006540:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006542:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006546:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000654a:	f6078693          	addi	a3,a5,-160
    8000654e:	6218                	ld	a4,0(a2)
    80006550:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006552:	00878513          	addi	a0,a5,8
    80006556:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006558:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000655a:	6208                	ld	a0,0(a2)
    8000655c:	96aa                	add	a3,a3,a0
    8000655e:	4741                	li	a4,16
    80006560:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006562:	4705                	li	a4,1
    80006564:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006568:	f8442703          	lw	a4,-124(s0)
    8000656c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006570:	0712                	slli	a4,a4,0x4
    80006572:	953a                	add	a0,a0,a4
    80006574:	058a8693          	addi	a3,s5,88
    80006578:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000657a:	6208                	ld	a0,0(a2)
    8000657c:	972a                	add	a4,a4,a0
    8000657e:	40000693          	li	a3,1024
    80006582:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006584:	001c3c13          	seqz	s8,s8
    80006588:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000658a:	001c6c13          	ori	s8,s8,1
    8000658e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006592:	f8842603          	lw	a2,-120(s0)
    80006596:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000659a:	0001c697          	auipc	a3,0x1c
    8000659e:	49668693          	addi	a3,a3,1174 # 80022a30 <disk>
    800065a2:	00258713          	addi	a4,a1,2
    800065a6:	0712                	slli	a4,a4,0x4
    800065a8:	9736                	add	a4,a4,a3
    800065aa:	587d                	li	a6,-1
    800065ac:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065b0:	0612                	slli	a2,a2,0x4
    800065b2:	9532                	add	a0,a0,a2
    800065b4:	f9078793          	addi	a5,a5,-112
    800065b8:	97b6                	add	a5,a5,a3
    800065ba:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800065bc:	629c                	ld	a5,0(a3)
    800065be:	97b2                	add	a5,a5,a2
    800065c0:	4605                	li	a2,1
    800065c2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065c4:	4509                	li	a0,2
    800065c6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800065ca:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065ce:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800065d2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065d6:	6698                	ld	a4,8(a3)
    800065d8:	00275783          	lhu	a5,2(a4)
    800065dc:	8b9d                	andi	a5,a5,7
    800065de:	0786                	slli	a5,a5,0x1
    800065e0:	97ba                	add	a5,a5,a4
    800065e2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800065e6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065ea:	6698                	ld	a4,8(a3)
    800065ec:	00275783          	lhu	a5,2(a4)
    800065f0:	2785                	addiw	a5,a5,1
    800065f2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065f6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065fa:	100017b7          	lui	a5,0x10001
    800065fe:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006602:	004aa783          	lw	a5,4(s5)
    80006606:	02c79163          	bne	a5,a2,80006628 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000660a:	0001c917          	auipc	s2,0x1c
    8000660e:	54e90913          	addi	s2,s2,1358 # 80022b58 <disk+0x128>
  while(b->disk == 1) {
    80006612:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006614:	85ca                	mv	a1,s2
    80006616:	8556                	mv	a0,s5
    80006618:	ffffc097          	auipc	ra,0xffffc
    8000661c:	f66080e7          	jalr	-154(ra) # 8000257e <sleep>
  while(b->disk == 1) {
    80006620:	004aa783          	lw	a5,4(s5)
    80006624:	fe9788e3          	beq	a5,s1,80006614 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006628:	f8042903          	lw	s2,-128(s0)
    8000662c:	00290793          	addi	a5,s2,2
    80006630:	00479713          	slli	a4,a5,0x4
    80006634:	0001c797          	auipc	a5,0x1c
    80006638:	3fc78793          	addi	a5,a5,1020 # 80022a30 <disk>
    8000663c:	97ba                	add	a5,a5,a4
    8000663e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006642:	0001c997          	auipc	s3,0x1c
    80006646:	3ee98993          	addi	s3,s3,1006 # 80022a30 <disk>
    8000664a:	00491713          	slli	a4,s2,0x4
    8000664e:	0009b783          	ld	a5,0(s3)
    80006652:	97ba                	add	a5,a5,a4
    80006654:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006658:	854a                	mv	a0,s2
    8000665a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000665e:	00000097          	auipc	ra,0x0
    80006662:	b98080e7          	jalr	-1128(ra) # 800061f6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006666:	8885                	andi	s1,s1,1
    80006668:	f0ed                	bnez	s1,8000664a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000666a:	0001c517          	auipc	a0,0x1c
    8000666e:	4ee50513          	addi	a0,a0,1262 # 80022b58 <disk+0x128>
    80006672:	ffffa097          	auipc	ra,0xffffa
    80006676:	618080e7          	jalr	1560(ra) # 80000c8a <release>
}
    8000667a:	70e6                	ld	ra,120(sp)
    8000667c:	7446                	ld	s0,112(sp)
    8000667e:	74a6                	ld	s1,104(sp)
    80006680:	7906                	ld	s2,96(sp)
    80006682:	69e6                	ld	s3,88(sp)
    80006684:	6a46                	ld	s4,80(sp)
    80006686:	6aa6                	ld	s5,72(sp)
    80006688:	6b06                	ld	s6,64(sp)
    8000668a:	7be2                	ld	s7,56(sp)
    8000668c:	7c42                	ld	s8,48(sp)
    8000668e:	7ca2                	ld	s9,40(sp)
    80006690:	7d02                	ld	s10,32(sp)
    80006692:	6de2                	ld	s11,24(sp)
    80006694:	6109                	addi	sp,sp,128
    80006696:	8082                	ret

0000000080006698 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006698:	1101                	addi	sp,sp,-32
    8000669a:	ec06                	sd	ra,24(sp)
    8000669c:	e822                	sd	s0,16(sp)
    8000669e:	e426                	sd	s1,8(sp)
    800066a0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066a2:	0001c497          	auipc	s1,0x1c
    800066a6:	38e48493          	addi	s1,s1,910 # 80022a30 <disk>
    800066aa:	0001c517          	auipc	a0,0x1c
    800066ae:	4ae50513          	addi	a0,a0,1198 # 80022b58 <disk+0x128>
    800066b2:	ffffa097          	auipc	ra,0xffffa
    800066b6:	524080e7          	jalr	1316(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066ba:	10001737          	lui	a4,0x10001
    800066be:	533c                	lw	a5,96(a4)
    800066c0:	8b8d                	andi	a5,a5,3
    800066c2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066c4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066c8:	689c                	ld	a5,16(s1)
    800066ca:	0204d703          	lhu	a4,32(s1)
    800066ce:	0027d783          	lhu	a5,2(a5)
    800066d2:	04f70863          	beq	a4,a5,80006722 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800066d6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066da:	6898                	ld	a4,16(s1)
    800066dc:	0204d783          	lhu	a5,32(s1)
    800066e0:	8b9d                	andi	a5,a5,7
    800066e2:	078e                	slli	a5,a5,0x3
    800066e4:	97ba                	add	a5,a5,a4
    800066e6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800066e8:	00278713          	addi	a4,a5,2
    800066ec:	0712                	slli	a4,a4,0x4
    800066ee:	9726                	add	a4,a4,s1
    800066f0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800066f4:	e721                	bnez	a4,8000673c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800066f6:	0789                	addi	a5,a5,2
    800066f8:	0792                	slli	a5,a5,0x4
    800066fa:	97a6                	add	a5,a5,s1
    800066fc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800066fe:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006702:	ffffc097          	auipc	ra,0xffffc
    80006706:	ee0080e7          	jalr	-288(ra) # 800025e2 <wakeup>

    disk.used_idx += 1;
    8000670a:	0204d783          	lhu	a5,32(s1)
    8000670e:	2785                	addiw	a5,a5,1
    80006710:	17c2                	slli	a5,a5,0x30
    80006712:	93c1                	srli	a5,a5,0x30
    80006714:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006718:	6898                	ld	a4,16(s1)
    8000671a:	00275703          	lhu	a4,2(a4)
    8000671e:	faf71ce3          	bne	a4,a5,800066d6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006722:	0001c517          	auipc	a0,0x1c
    80006726:	43650513          	addi	a0,a0,1078 # 80022b58 <disk+0x128>
    8000672a:	ffffa097          	auipc	ra,0xffffa
    8000672e:	560080e7          	jalr	1376(ra) # 80000c8a <release>
}
    80006732:	60e2                	ld	ra,24(sp)
    80006734:	6442                	ld	s0,16(sp)
    80006736:	64a2                	ld	s1,8(sp)
    80006738:	6105                	addi	sp,sp,32
    8000673a:	8082                	ret
      panic("virtio_disk_intr status");
    8000673c:	00002517          	auipc	a0,0x2
    80006740:	13450513          	addi	a0,a0,308 # 80008870 <syscalls+0x3f0>
    80006744:	ffffa097          	auipc	ra,0xffffa
    80006748:	dfa080e7          	jalr	-518(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
