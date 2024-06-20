
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8d013103          	ld	sp,-1840(sp) # 800088d0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	8de70713          	addi	a4,a4,-1826 # 80008930 <timer_scratch>
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
    80000068:	bdc78793          	addi	a5,a5,-1060 # 80005c40 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc73f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dc478793          	addi	a5,a5,-572 # 80000e72 <main>
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
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	444080e7          	jalr	1092(ra) # 80002570 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	77a080e7          	jalr	1914(ra) # 800008b6 <uartputc>
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
    8000018e:	8e650513          	addi	a0,a0,-1818 # 80010a70 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a3e080e7          	jalr	-1474(ra) # 80000bd0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8d648493          	addi	s1,s1,-1834 # 80010a70 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	96690913          	addi	s2,s2,-1690 # 80010b08 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

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
    800001b0:	07305863          	blez	s3,80000220 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71463          	bne	a4,a5,800001e4 <consoleread+0x80>
      if(myproc()->killed){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7f2080e7          	jalr	2034(ra) # 800019b2 <myproc>
    800001c8:	551c                	lw	a5,40(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	fa6080e7          	jalr	-90(ra) # 80002176 <sleep>
    while(cons.r == cons.w){
    800001d8:	0984a783          	lw	a5,152(s1)
    800001dc:	09c4a703          	lw	a4,156(s1)
    800001e0:	fef700e3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e4:	0017871b          	addiw	a4,a5,1
    800001e8:	08e4ac23          	sw	a4,152(s1)
    800001ec:	07f7f713          	andi	a4,a5,127
    800001f0:	9726                	add	a4,a4,s1
    800001f2:	01874703          	lbu	a4,24(a4)
    800001f6:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001fa:	077d0563          	beq	s10,s7,80000264 <consoleread+0x100>
    cbuf = c;
    800001fe:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000202:	4685                	li	a3,1
    80000204:	f9f40613          	addi	a2,s0,-97
    80000208:	85d2                	mv	a1,s4
    8000020a:	8556                	mv	a0,s5
    8000020c:	00002097          	auipc	ra,0x2
    80000210:	30e080e7          	jalr	782(ra) # 8000251a <either_copyout>
    80000214:	01850663          	beq	a0,s8,80000220 <consoleread+0xbc>
    dst++;
    80000218:	0a05                	addi	s4,s4,1
    --n;
    8000021a:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000021c:	f99d1ae3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000220:	00011517          	auipc	a0,0x11
    80000224:	85050513          	addi	a0,a0,-1968 # 80010a70 <cons>
    80000228:	00001097          	auipc	ra,0x1
    8000022c:	a5c080e7          	jalr	-1444(ra) # 80000c84 <release>

  return target - n;
    80000230:	413b053b          	subw	a0,s6,s3
    80000234:	a811                	j	80000248 <consoleread+0xe4>
        release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	83a50513          	addi	a0,a0,-1990 # 80010a70 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	a46080e7          	jalr	-1466(ra) # 80000c84 <release>
        return -1;
    80000246:	557d                	li	a0,-1
}
    80000248:	70a6                	ld	ra,104(sp)
    8000024a:	7406                	ld	s0,96(sp)
    8000024c:	64e6                	ld	s1,88(sp)
    8000024e:	6946                	ld	s2,80(sp)
    80000250:	69a6                	ld	s3,72(sp)
    80000252:	6a06                	ld	s4,64(sp)
    80000254:	7ae2                	ld	s5,56(sp)
    80000256:	7b42                	ld	s6,48(sp)
    80000258:	7ba2                	ld	s7,40(sp)
    8000025a:	7c02                	ld	s8,32(sp)
    8000025c:	6ce2                	ld	s9,24(sp)
    8000025e:	6d42                	ld	s10,16(sp)
    80000260:	6165                	addi	sp,sp,112
    80000262:	8082                	ret
      if(n < target){
    80000264:	0009871b          	sext.w	a4,s3
    80000268:	fb677ce3          	bgeu	a4,s6,80000220 <consoleread+0xbc>
        cons.r--;
    8000026c:	00011717          	auipc	a4,0x11
    80000270:	88f72e23          	sw	a5,-1892(a4) # 80010b08 <cons+0x98>
    80000274:	b775                	j	80000220 <consoleread+0xbc>

0000000080000276 <consputc>:
{
    80000276:	1141                	addi	sp,sp,-16
    80000278:	e406                	sd	ra,8(sp)
    8000027a:	e022                	sd	s0,0(sp)
    8000027c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027e:	10000793          	li	a5,256
    80000282:	00f50a63          	beq	a0,a5,80000296 <consputc+0x20>
    uartputc_sync(c);
    80000286:	00000097          	auipc	ra,0x0
    8000028a:	55e080e7          	jalr	1374(ra) # 800007e4 <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	00000097          	auipc	ra,0x0
    8000029c:	54c080e7          	jalr	1356(ra) # 800007e4 <uartputc_sync>
    800002a0:	02000513          	li	a0,32
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	540080e7          	jalr	1344(ra) # 800007e4 <uartputc_sync>
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	536080e7          	jalr	1334(ra) # 800007e4 <uartputc_sync>
    800002b6:	bfe1                	j	8000028e <consputc+0x18>

00000000800002b8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b8:	1101                	addi	sp,sp,-32
    800002ba:	ec06                	sd	ra,24(sp)
    800002bc:	e822                	sd	s0,16(sp)
    800002be:	e426                	sd	s1,8(sp)
    800002c0:	e04a                	sd	s2,0(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00010517          	auipc	a0,0x10
    800002ca:	7aa50513          	addi	a0,a0,1962 # 80010a70 <cons>
    800002ce:	00001097          	auipc	ra,0x1
    800002d2:	902080e7          	jalr	-1790(ra) # 80000bd0 <acquire>

  switch(c){
    800002d6:	47d5                	li	a5,21
    800002d8:	0af48663          	beq	s1,a5,80000384 <consoleintr+0xcc>
    800002dc:	0297ca63          	blt	a5,s1,80000310 <consoleintr+0x58>
    800002e0:	47a1                	li	a5,8
    800002e2:	0ef48763          	beq	s1,a5,800003d0 <consoleintr+0x118>
    800002e6:	47c1                	li	a5,16
    800002e8:	10f49a63          	bne	s1,a5,800003fc <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ec:	00002097          	auipc	ra,0x2
    800002f0:	2da080e7          	jalr	730(ra) # 800025c6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f4:	00010517          	auipc	a0,0x10
    800002f8:	77c50513          	addi	a0,a0,1916 # 80010a70 <cons>
    800002fc:	00001097          	auipc	ra,0x1
    80000300:	988080e7          	jalr	-1656(ra) # 80000c84 <release>
}
    80000304:	60e2                	ld	ra,24(sp)
    80000306:	6442                	ld	s0,16(sp)
    80000308:	64a2                	ld	s1,8(sp)
    8000030a:	6902                	ld	s2,0(sp)
    8000030c:	6105                	addi	sp,sp,32
    8000030e:	8082                	ret
  switch(c){
    80000310:	07f00793          	li	a5,127
    80000314:	0af48e63          	beq	s1,a5,800003d0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000318:	00010717          	auipc	a4,0x10
    8000031c:	75870713          	addi	a4,a4,1880 # 80010a70 <cons>
    80000320:	0a072783          	lw	a5,160(a4)
    80000324:	09872703          	lw	a4,152(a4)
    80000328:	9f99                	subw	a5,a5,a4
    8000032a:	07f00713          	li	a4,127
    8000032e:	fcf763e3          	bltu	a4,a5,800002f4 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000332:	47b5                	li	a5,13
    80000334:	0cf48763          	beq	s1,a5,80000402 <consoleintr+0x14a>
      consputc(c);
    80000338:	8526                	mv	a0,s1
    8000033a:	00000097          	auipc	ra,0x0
    8000033e:	f3c080e7          	jalr	-196(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000342:	00010797          	auipc	a5,0x10
    80000346:	72e78793          	addi	a5,a5,1838 # 80010a70 <cons>
    8000034a:	0a07a703          	lw	a4,160(a5)
    8000034e:	0017069b          	addiw	a3,a4,1
    80000352:	0006861b          	sext.w	a2,a3
    80000356:	0ad7a023          	sw	a3,160(a5)
    8000035a:	07f77713          	andi	a4,a4,127
    8000035e:	97ba                	add	a5,a5,a4
    80000360:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000364:	47a9                	li	a5,10
    80000366:	0cf48563          	beq	s1,a5,80000430 <consoleintr+0x178>
    8000036a:	4791                	li	a5,4
    8000036c:	0cf48263          	beq	s1,a5,80000430 <consoleintr+0x178>
    80000370:	00010797          	auipc	a5,0x10
    80000374:	7987a783          	lw	a5,1944(a5) # 80010b08 <cons+0x98>
    80000378:	0807879b          	addiw	a5,a5,128
    8000037c:	f6f61ce3          	bne	a2,a5,800002f4 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000380:	863e                	mv	a2,a5
    80000382:	a07d                	j	80000430 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000384:	00010717          	auipc	a4,0x10
    80000388:	6ec70713          	addi	a4,a4,1772 # 80010a70 <cons>
    8000038c:	0a072783          	lw	a5,160(a4)
    80000390:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	00010497          	auipc	s1,0x10
    80000398:	6dc48493          	addi	s1,s1,1756 # 80010a70 <cons>
    while(cons.e != cons.w &&
    8000039c:	4929                	li	s2,10
    8000039e:	f4f70be3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a2:	37fd                	addiw	a5,a5,-1
    800003a4:	07f7f713          	andi	a4,a5,127
    800003a8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003aa:	01874703          	lbu	a4,24(a4)
    800003ae:	f52703e3          	beq	a4,s2,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003b2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b6:	10000513          	li	a0,256
    800003ba:	00000097          	auipc	ra,0x0
    800003be:	ebc080e7          	jalr	-324(ra) # 80000276 <consputc>
    while(cons.e != cons.w &&
    800003c2:	0a04a783          	lw	a5,160(s1)
    800003c6:	09c4a703          	lw	a4,156(s1)
    800003ca:	fcf71ce3          	bne	a4,a5,800003a2 <consoleintr+0xea>
    800003ce:	b71d                	j	800002f4 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d0:	00010717          	auipc	a4,0x10
    800003d4:	6a070713          	addi	a4,a4,1696 # 80010a70 <cons>
    800003d8:	0a072783          	lw	a5,160(a4)
    800003dc:	09c72703          	lw	a4,156(a4)
    800003e0:	f0f70ae3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003e4:	37fd                	addiw	a5,a5,-1
    800003e6:	00010717          	auipc	a4,0x10
    800003ea:	72f72523          	sw	a5,1834(a4) # 80010b10 <cons+0xa0>
      consputc(BACKSPACE);
    800003ee:	10000513          	li	a0,256
    800003f2:	00000097          	auipc	ra,0x0
    800003f6:	e84080e7          	jalr	-380(ra) # 80000276 <consputc>
    800003fa:	bded                	j	800002f4 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003fc:	ee048ce3          	beqz	s1,800002f4 <consoleintr+0x3c>
    80000400:	bf21                	j	80000318 <consoleintr+0x60>
      consputc(c);
    80000402:	4529                	li	a0,10
    80000404:	00000097          	auipc	ra,0x0
    80000408:	e72080e7          	jalr	-398(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000040c:	00010797          	auipc	a5,0x10
    80000410:	66478793          	addi	a5,a5,1636 # 80010a70 <cons>
    80000414:	0a07a703          	lw	a4,160(a5)
    80000418:	0017069b          	addiw	a3,a4,1
    8000041c:	0006861b          	sext.w	a2,a3
    80000420:	0ad7a023          	sw	a3,160(a5)
    80000424:	07f77713          	andi	a4,a4,127
    80000428:	97ba                	add	a5,a5,a4
    8000042a:	4729                	li	a4,10
    8000042c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000430:	00010797          	auipc	a5,0x10
    80000434:	6cc7ae23          	sw	a2,1756(a5) # 80010b0c <cons+0x9c>
        wakeup(&cons.r);
    80000438:	00010517          	auipc	a0,0x10
    8000043c:	6d050513          	addi	a0,a0,1744 # 80010b08 <cons+0x98>
    80000440:	00002097          	auipc	ra,0x2
    80000444:	ec2080e7          	jalr	-318(ra) # 80002302 <wakeup>
    80000448:	b575                	j	800002f4 <consoleintr+0x3c>

000000008000044a <consoleinit>:

void
consoleinit(void)
{
    8000044a:	1141                	addi	sp,sp,-16
    8000044c:	e406                	sd	ra,8(sp)
    8000044e:	e022                	sd	s0,0(sp)
    80000450:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000452:	00008597          	auipc	a1,0x8
    80000456:	bbe58593          	addi	a1,a1,-1090 # 80008010 <etext+0x10>
    8000045a:	00010517          	auipc	a0,0x10
    8000045e:	61650513          	addi	a0,a0,1558 # 80010a70 <cons>
    80000462:	00000097          	auipc	ra,0x0
    80000466:	6de080e7          	jalr	1758(ra) # 80000b40 <initlock>

  uartinit();
    8000046a:	00000097          	auipc	ra,0x0
    8000046e:	32a080e7          	jalr	810(ra) # 80000794 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000472:	00021797          	auipc	a5,0x21
    80000476:	ab678793          	addi	a5,a5,-1354 # 80020f28 <devsw>
    8000047a:	00000717          	auipc	a4,0x0
    8000047e:	cea70713          	addi	a4,a4,-790 # 80000164 <consoleread>
    80000482:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000484:	00000717          	auipc	a4,0x0
    80000488:	c7e70713          	addi	a4,a4,-898 # 80000102 <consolewrite>
    8000048c:	ef98                	sd	a4,24(a5)
}
    8000048e:	60a2                	ld	ra,8(sp)
    80000490:	6402                	ld	s0,0(sp)
    80000492:	0141                	addi	sp,sp,16
    80000494:	8082                	ret

0000000080000496 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000496:	7179                	addi	sp,sp,-48
    80000498:	f406                	sd	ra,40(sp)
    8000049a:	f022                	sd	s0,32(sp)
    8000049c:	ec26                	sd	s1,24(sp)
    8000049e:	e84a                	sd	s2,16(sp)
    800004a0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a2:	c219                	beqz	a2,800004a8 <printint+0x12>
    800004a4:	08054663          	bltz	a0,80000530 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004a8:	2501                	sext.w	a0,a0
    800004aa:	4881                	li	a7,0
    800004ac:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b2:	2581                	sext.w	a1,a1
    800004b4:	00008617          	auipc	a2,0x8
    800004b8:	b8c60613          	addi	a2,a2,-1140 # 80008040 <digits>
    800004bc:	883a                	mv	a6,a4
    800004be:	2705                	addiw	a4,a4,1
    800004c0:	02b577bb          	remuw	a5,a0,a1
    800004c4:	1782                	slli	a5,a5,0x20
    800004c6:	9381                	srli	a5,a5,0x20
    800004c8:	97b2                	add	a5,a5,a2
    800004ca:	0007c783          	lbu	a5,0(a5)
    800004ce:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d2:	0005079b          	sext.w	a5,a0
    800004d6:	02b5553b          	divuw	a0,a0,a1
    800004da:	0685                	addi	a3,a3,1
    800004dc:	feb7f0e3          	bgeu	a5,a1,800004bc <printint+0x26>

  if(sign)
    800004e0:	00088b63          	beqz	a7,800004f6 <printint+0x60>
    buf[i++] = '-';
    800004e4:	fe040793          	addi	a5,s0,-32
    800004e8:	973e                	add	a4,a4,a5
    800004ea:	02d00793          	li	a5,45
    800004ee:	fef70823          	sb	a5,-16(a4)
    800004f2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004f6:	02e05763          	blez	a4,80000524 <printint+0x8e>
    800004fa:	fd040793          	addi	a5,s0,-48
    800004fe:	00e784b3          	add	s1,a5,a4
    80000502:	fff78913          	addi	s2,a5,-1
    80000506:	993a                	add	s2,s2,a4
    80000508:	377d                	addiw	a4,a4,-1
    8000050a:	1702                	slli	a4,a4,0x20
    8000050c:	9301                	srli	a4,a4,0x20
    8000050e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000512:	fff4c503          	lbu	a0,-1(s1)
    80000516:	00000097          	auipc	ra,0x0
    8000051a:	d60080e7          	jalr	-672(ra) # 80000276 <consputc>
  while(--i >= 0)
    8000051e:	14fd                	addi	s1,s1,-1
    80000520:	ff2499e3          	bne	s1,s2,80000512 <printint+0x7c>
}
    80000524:	70a2                	ld	ra,40(sp)
    80000526:	7402                	ld	s0,32(sp)
    80000528:	64e2                	ld	s1,24(sp)
    8000052a:	6942                	ld	s2,16(sp)
    8000052c:	6145                	addi	sp,sp,48
    8000052e:	8082                	ret
    x = -xx;
    80000530:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000534:	4885                	li	a7,1
    x = -xx;
    80000536:	bf9d                	j	800004ac <printint+0x16>

0000000080000538 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000538:	1101                	addi	sp,sp,-32
    8000053a:	ec06                	sd	ra,24(sp)
    8000053c:	e822                	sd	s0,16(sp)
    8000053e:	e426                	sd	s1,8(sp)
    80000540:	1000                	addi	s0,sp,32
    80000542:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000544:	00010797          	auipc	a5,0x10
    80000548:	5e07a623          	sw	zero,1516(a5) # 80010b30 <pr+0x18>
  printf("panic: ");
    8000054c:	00008517          	auipc	a0,0x8
    80000550:	acc50513          	addi	a0,a0,-1332 # 80008018 <etext+0x18>
    80000554:	00000097          	auipc	ra,0x0
    80000558:	02e080e7          	jalr	46(ra) # 80000582 <printf>
  printf(s);
    8000055c:	8526                	mv	a0,s1
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	024080e7          	jalr	36(ra) # 80000582 <printf>
  printf("\n");
    80000566:	00008517          	auipc	a0,0x8
    8000056a:	b6250513          	addi	a0,a0,-1182 # 800080c8 <digits+0x88>
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	014080e7          	jalr	20(ra) # 80000582 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000576:	4785                	li	a5,1
    80000578:	00008717          	auipc	a4,0x8
    8000057c:	36f72c23          	sw	a5,888(a4) # 800088f0 <panicked>
  for(;;)
    80000580:	a001                	j	80000580 <panic+0x48>

0000000080000582 <printf>:
{
    80000582:	7131                	addi	sp,sp,-192
    80000584:	fc86                	sd	ra,120(sp)
    80000586:	f8a2                	sd	s0,112(sp)
    80000588:	f4a6                	sd	s1,104(sp)
    8000058a:	f0ca                	sd	s2,96(sp)
    8000058c:	ecce                	sd	s3,88(sp)
    8000058e:	e8d2                	sd	s4,80(sp)
    80000590:	e4d6                	sd	s5,72(sp)
    80000592:	e0da                	sd	s6,64(sp)
    80000594:	fc5e                	sd	s7,56(sp)
    80000596:	f862                	sd	s8,48(sp)
    80000598:	f466                	sd	s9,40(sp)
    8000059a:	f06a                	sd	s10,32(sp)
    8000059c:	ec6e                	sd	s11,24(sp)
    8000059e:	0100                	addi	s0,sp,128
    800005a0:	8a2a                	mv	s4,a0
    800005a2:	e40c                	sd	a1,8(s0)
    800005a4:	e810                	sd	a2,16(s0)
    800005a6:	ec14                	sd	a3,24(s0)
    800005a8:	f018                	sd	a4,32(s0)
    800005aa:	f41c                	sd	a5,40(s0)
    800005ac:	03043823          	sd	a6,48(s0)
    800005b0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b4:	00010d97          	auipc	s11,0x10
    800005b8:	57cdad83          	lw	s11,1404(s11) # 80010b30 <pr+0x18>
  if(locking)
    800005bc:	020d9b63          	bnez	s11,800005f2 <printf+0x70>
  if (fmt == 0)
    800005c0:	040a0263          	beqz	s4,80000604 <printf+0x82>
  va_start(ap, fmt);
    800005c4:	00840793          	addi	a5,s0,8
    800005c8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005cc:	000a4503          	lbu	a0,0(s4)
    800005d0:	14050f63          	beqz	a0,8000072e <printf+0x1ac>
    800005d4:	4981                	li	s3,0
    if(c != '%'){
    800005d6:	02500a93          	li	s5,37
    switch(c){
    800005da:	07000b93          	li	s7,112
  consputc('x');
    800005de:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e0:	00008b17          	auipc	s6,0x8
    800005e4:	a60b0b13          	addi	s6,s6,-1440 # 80008040 <digits>
    switch(c){
    800005e8:	07300c93          	li	s9,115
    800005ec:	06400c13          	li	s8,100
    800005f0:	a82d                	j	8000062a <printf+0xa8>
    acquire(&pr.lock);
    800005f2:	00010517          	auipc	a0,0x10
    800005f6:	52650513          	addi	a0,a0,1318 # 80010b18 <pr>
    800005fa:	00000097          	auipc	ra,0x0
    800005fe:	5d6080e7          	jalr	1494(ra) # 80000bd0 <acquire>
    80000602:	bf7d                	j	800005c0 <printf+0x3e>
    panic("null fmt");
    80000604:	00008517          	auipc	a0,0x8
    80000608:	a2450513          	addi	a0,a0,-1500 # 80008028 <etext+0x28>
    8000060c:	00000097          	auipc	ra,0x0
    80000610:	f2c080e7          	jalr	-212(ra) # 80000538 <panic>
      consputc(c);
    80000614:	00000097          	auipc	ra,0x0
    80000618:	c62080e7          	jalr	-926(ra) # 80000276 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000061c:	2985                	addiw	s3,s3,1
    8000061e:	013a07b3          	add	a5,s4,s3
    80000622:	0007c503          	lbu	a0,0(a5)
    80000626:	10050463          	beqz	a0,8000072e <printf+0x1ac>
    if(c != '%'){
    8000062a:	ff5515e3          	bne	a0,s5,80000614 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000062e:	2985                	addiw	s3,s3,1
    80000630:	013a07b3          	add	a5,s4,s3
    80000634:	0007c783          	lbu	a5,0(a5)
    80000638:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000063c:	cbed                	beqz	a5,8000072e <printf+0x1ac>
    switch(c){
    8000063e:	05778a63          	beq	a5,s7,80000692 <printf+0x110>
    80000642:	02fbf663          	bgeu	s7,a5,8000066e <printf+0xec>
    80000646:	09978863          	beq	a5,s9,800006d6 <printf+0x154>
    8000064a:	07800713          	li	a4,120
    8000064e:	0ce79563          	bne	a5,a4,80000718 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4605                	li	a2,1
    80000660:	85ea                	mv	a1,s10
    80000662:	4388                	lw	a0,0(a5)
    80000664:	00000097          	auipc	ra,0x0
    80000668:	e32080e7          	jalr	-462(ra) # 80000496 <printint>
      break;
    8000066c:	bf45                	j	8000061c <printf+0x9a>
    switch(c){
    8000066e:	09578f63          	beq	a5,s5,8000070c <printf+0x18a>
    80000672:	0b879363          	bne	a5,s8,80000718 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000676:	f8843783          	ld	a5,-120(s0)
    8000067a:	00878713          	addi	a4,a5,8
    8000067e:	f8e43423          	sd	a4,-120(s0)
    80000682:	4605                	li	a2,1
    80000684:	45a9                	li	a1,10
    80000686:	4388                	lw	a0,0(a5)
    80000688:	00000097          	auipc	ra,0x0
    8000068c:	e0e080e7          	jalr	-498(ra) # 80000496 <printint>
      break;
    80000690:	b771                	j	8000061c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a2:	03000513          	li	a0,48
    800006a6:	00000097          	auipc	ra,0x0
    800006aa:	bd0080e7          	jalr	-1072(ra) # 80000276 <consputc>
  consputc('x');
    800006ae:	07800513          	li	a0,120
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bc4080e7          	jalr	-1084(ra) # 80000276 <consputc>
    800006ba:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006bc:	03c95793          	srli	a5,s2,0x3c
    800006c0:	97da                	add	a5,a5,s6
    800006c2:	0007c503          	lbu	a0,0(a5)
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	bb0080e7          	jalr	-1104(ra) # 80000276 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ce:	0912                	slli	s2,s2,0x4
    800006d0:	34fd                	addiw	s1,s1,-1
    800006d2:	f4ed                	bnez	s1,800006bc <printf+0x13a>
    800006d4:	b7a1                	j	8000061c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d6:	f8843783          	ld	a5,-120(s0)
    800006da:	00878713          	addi	a4,a5,8
    800006de:	f8e43423          	sd	a4,-120(s0)
    800006e2:	6384                	ld	s1,0(a5)
    800006e4:	cc89                	beqz	s1,800006fe <printf+0x17c>
      for(; *s; s++)
    800006e6:	0004c503          	lbu	a0,0(s1)
    800006ea:	d90d                	beqz	a0,8000061c <printf+0x9a>
        consputc(*s);
    800006ec:	00000097          	auipc	ra,0x0
    800006f0:	b8a080e7          	jalr	-1142(ra) # 80000276 <consputc>
      for(; *s; s++)
    800006f4:	0485                	addi	s1,s1,1
    800006f6:	0004c503          	lbu	a0,0(s1)
    800006fa:	f96d                	bnez	a0,800006ec <printf+0x16a>
    800006fc:	b705                	j	8000061c <printf+0x9a>
        s = "(null)";
    800006fe:	00008497          	auipc	s1,0x8
    80000702:	92248493          	addi	s1,s1,-1758 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000706:	02800513          	li	a0,40
    8000070a:	b7cd                	j	800006ec <printf+0x16a>
      consputc('%');
    8000070c:	8556                	mv	a0,s5
    8000070e:	00000097          	auipc	ra,0x0
    80000712:	b68080e7          	jalr	-1176(ra) # 80000276 <consputc>
      break;
    80000716:	b719                	j	8000061c <printf+0x9a>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b5c080e7          	jalr	-1188(ra) # 80000276 <consputc>
      consputc(c);
    80000722:	8526                	mv	a0,s1
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b52080e7          	jalr	-1198(ra) # 80000276 <consputc>
      break;
    8000072c:	bdc5                	j	8000061c <printf+0x9a>
  if(locking)
    8000072e:	020d9163          	bnez	s11,80000750 <printf+0x1ce>
}
    80000732:	70e6                	ld	ra,120(sp)
    80000734:	7446                	ld	s0,112(sp)
    80000736:	74a6                	ld	s1,104(sp)
    80000738:	7906                	ld	s2,96(sp)
    8000073a:	69e6                	ld	s3,88(sp)
    8000073c:	6a46                	ld	s4,80(sp)
    8000073e:	6aa6                	ld	s5,72(sp)
    80000740:	6b06                	ld	s6,64(sp)
    80000742:	7be2                	ld	s7,56(sp)
    80000744:	7c42                	ld	s8,48(sp)
    80000746:	7ca2                	ld	s9,40(sp)
    80000748:	7d02                	ld	s10,32(sp)
    8000074a:	6de2                	ld	s11,24(sp)
    8000074c:	6129                	addi	sp,sp,192
    8000074e:	8082                	ret
    release(&pr.lock);
    80000750:	00010517          	auipc	a0,0x10
    80000754:	3c850513          	addi	a0,a0,968 # 80010b18 <pr>
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	52c080e7          	jalr	1324(ra) # 80000c84 <release>
}
    80000760:	bfc9                	j	80000732 <printf+0x1b0>

0000000080000762 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000762:	1101                	addi	sp,sp,-32
    80000764:	ec06                	sd	ra,24(sp)
    80000766:	e822                	sd	s0,16(sp)
    80000768:	e426                	sd	s1,8(sp)
    8000076a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076c:	00010497          	auipc	s1,0x10
    80000770:	3ac48493          	addi	s1,s1,940 # 80010b18 <pr>
    80000774:	00008597          	auipc	a1,0x8
    80000778:	8c458593          	addi	a1,a1,-1852 # 80008038 <etext+0x38>
    8000077c:	8526                	mv	a0,s1
    8000077e:	00000097          	auipc	ra,0x0
    80000782:	3c2080e7          	jalr	962(ra) # 80000b40 <initlock>
  pr.locking = 1;
    80000786:	4785                	li	a5,1
    80000788:	cc9c                	sw	a5,24(s1)
}
    8000078a:	60e2                	ld	ra,24(sp)
    8000078c:	6442                	ld	s0,16(sp)
    8000078e:	64a2                	ld	s1,8(sp)
    80000790:	6105                	addi	sp,sp,32
    80000792:	8082                	ret

0000000080000794 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000794:	1141                	addi	sp,sp,-16
    80000796:	e406                	sd	ra,8(sp)
    80000798:	e022                	sd	s0,0(sp)
    8000079a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079c:	100007b7          	lui	a5,0x10000
    800007a0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a4:	f8000713          	li	a4,-128
    800007a8:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ac:	470d                	li	a4,3
    800007ae:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b2:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b6:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ba:	469d                	li	a3,7
    800007bc:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c0:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	89458593          	addi	a1,a1,-1900 # 80008058 <digits+0x18>
    800007cc:	00010517          	auipc	a0,0x10
    800007d0:	36c50513          	addi	a0,a0,876 # 80010b38 <uart_tx_lock>
    800007d4:	00000097          	auipc	ra,0x0
    800007d8:	36c080e7          	jalr	876(ra) # 80000b40 <initlock>
}
    800007dc:	60a2                	ld	ra,8(sp)
    800007de:	6402                	ld	s0,0(sp)
    800007e0:	0141                	addi	sp,sp,16
    800007e2:	8082                	ret

00000000800007e4 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e4:	1101                	addi	sp,sp,-32
    800007e6:	ec06                	sd	ra,24(sp)
    800007e8:	e822                	sd	s0,16(sp)
    800007ea:	e426                	sd	s1,8(sp)
    800007ec:	1000                	addi	s0,sp,32
    800007ee:	84aa                	mv	s1,a0
  push_off();
    800007f0:	00000097          	auipc	ra,0x0
    800007f4:	394080e7          	jalr	916(ra) # 80000b84 <push_off>

  if(panicked){
    800007f8:	00008797          	auipc	a5,0x8
    800007fc:	0f87a783          	lw	a5,248(a5) # 800088f0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000800:	10000737          	lui	a4,0x10000
  if(panicked){
    80000804:	c391                	beqz	a5,80000808 <uartputc_sync+0x24>
    for(;;)
    80000806:	a001                	j	80000806 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080c:	0207f793          	andi	a5,a5,32
    80000810:	dfe5                	beqz	a5,80000808 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000812:	0ff4f513          	andi	a0,s1,255
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000081e:	00000097          	auipc	ra,0x0
    80000822:	406080e7          	jalr	1030(ra) # 80000c24 <pop_off>
}
    80000826:	60e2                	ld	ra,24(sp)
    80000828:	6442                	ld	s0,16(sp)
    8000082a:	64a2                	ld	s1,8(sp)
    8000082c:	6105                	addi	sp,sp,32
    8000082e:	8082                	ret

0000000080000830 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000830:	00008797          	auipc	a5,0x8
    80000834:	0c87b783          	ld	a5,200(a5) # 800088f8 <uart_tx_r>
    80000838:	00008717          	auipc	a4,0x8
    8000083c:	0c873703          	ld	a4,200(a4) # 80008900 <uart_tx_w>
    80000840:	06f70a63          	beq	a4,a5,800008b4 <uartstart+0x84>
{
    80000844:	7139                	addi	sp,sp,-64
    80000846:	fc06                	sd	ra,56(sp)
    80000848:	f822                	sd	s0,48(sp)
    8000084a:	f426                	sd	s1,40(sp)
    8000084c:	f04a                	sd	s2,32(sp)
    8000084e:	ec4e                	sd	s3,24(sp)
    80000850:	e852                	sd	s4,16(sp)
    80000852:	e456                	sd	s5,8(sp)
    80000854:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000856:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085a:	00010a17          	auipc	s4,0x10
    8000085e:	2dea0a13          	addi	s4,s4,734 # 80010b38 <uart_tx_lock>
    uart_tx_r += 1;
    80000862:	00008497          	auipc	s1,0x8
    80000866:	09648493          	addi	s1,s1,150 # 800088f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086a:	00008997          	auipc	s3,0x8
    8000086e:	09698993          	addi	s3,s3,150 # 80008900 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000872:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000876:	02077713          	andi	a4,a4,32
    8000087a:	c705                	beqz	a4,800008a2 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000087c:	01f7f713          	andi	a4,a5,31
    80000880:	9752                	add	a4,a4,s4
    80000882:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000886:	0785                	addi	a5,a5,1
    80000888:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088a:	8526                	mv	a0,s1
    8000088c:	00002097          	auipc	ra,0x2
    80000890:	a76080e7          	jalr	-1418(ra) # 80002302 <wakeup>
    
    WriteReg(THR, c);
    80000894:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80000898:	609c                	ld	a5,0(s1)
    8000089a:	0009b703          	ld	a4,0(s3)
    8000089e:	fcf71ae3          	bne	a4,a5,80000872 <uartstart+0x42>
  }
}
    800008a2:	70e2                	ld	ra,56(sp)
    800008a4:	7442                	ld	s0,48(sp)
    800008a6:	74a2                	ld	s1,40(sp)
    800008a8:	7902                	ld	s2,32(sp)
    800008aa:	69e2                	ld	s3,24(sp)
    800008ac:	6a42                	ld	s4,16(sp)
    800008ae:	6aa2                	ld	s5,8(sp)
    800008b0:	6121                	addi	sp,sp,64
    800008b2:	8082                	ret
    800008b4:	8082                	ret

00000000800008b6 <uartputc>:
{
    800008b6:	7179                	addi	sp,sp,-48
    800008b8:	f406                	sd	ra,40(sp)
    800008ba:	f022                	sd	s0,32(sp)
    800008bc:	ec26                	sd	s1,24(sp)
    800008be:	e84a                	sd	s2,16(sp)
    800008c0:	e44e                	sd	s3,8(sp)
    800008c2:	e052                	sd	s4,0(sp)
    800008c4:	1800                	addi	s0,sp,48
    800008c6:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008c8:	00010517          	auipc	a0,0x10
    800008cc:	27050513          	addi	a0,a0,624 # 80010b38 <uart_tx_lock>
    800008d0:	00000097          	auipc	ra,0x0
    800008d4:	300080e7          	jalr	768(ra) # 80000bd0 <acquire>
  if(panicked){
    800008d8:	00008797          	auipc	a5,0x8
    800008dc:	0187a783          	lw	a5,24(a5) # 800088f0 <panicked>
    800008e0:	c391                	beqz	a5,800008e4 <uartputc+0x2e>
    for(;;)
    800008e2:	a001                	j	800008e2 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e4:	00008717          	auipc	a4,0x8
    800008e8:	01c73703          	ld	a4,28(a4) # 80008900 <uart_tx_w>
    800008ec:	00008797          	auipc	a5,0x8
    800008f0:	00c7b783          	ld	a5,12(a5) # 800088f8 <uart_tx_r>
    800008f4:	02078793          	addi	a5,a5,32
    800008f8:	02e79b63          	bne	a5,a4,8000092e <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	23c98993          	addi	s3,s3,572 # 80010b38 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	ff448493          	addi	s1,s1,-12 # 800088f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	ff490913          	addi	s2,s2,-12 # 80008900 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000914:	85ce                	mv	a1,s3
    80000916:	8526                	mv	a0,s1
    80000918:	00002097          	auipc	ra,0x2
    8000091c:	85e080e7          	jalr	-1954(ra) # 80002176 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00093703          	ld	a4,0(s2)
    80000924:	609c                	ld	a5,0(s1)
    80000926:	02078793          	addi	a5,a5,32
    8000092a:	fee785e3          	beq	a5,a4,80000914 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000092e:	00010497          	auipc	s1,0x10
    80000932:	20a48493          	addi	s1,s1,522 # 80010b38 <uart_tx_lock>
    80000936:	01f77793          	andi	a5,a4,31
    8000093a:	97a6                	add	a5,a5,s1
    8000093c:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000940:	0705                	addi	a4,a4,1
    80000942:	00008797          	auipc	a5,0x8
    80000946:	fae7bf23          	sd	a4,-66(a5) # 80008900 <uart_tx_w>
      uartstart();
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	ee6080e7          	jalr	-282(ra) # 80000830 <uartstart>
      release(&uart_tx_lock);
    80000952:	8526                	mv	a0,s1
    80000954:	00000097          	auipc	ra,0x0
    80000958:	330080e7          	jalr	816(ra) # 80000c84 <release>
}
    8000095c:	70a2                	ld	ra,40(sp)
    8000095e:	7402                	ld	s0,32(sp)
    80000960:	64e2                	ld	s1,24(sp)
    80000962:	6942                	ld	s2,16(sp)
    80000964:	69a2                	ld	s3,8(sp)
    80000966:	6a02                	ld	s4,0(sp)
    80000968:	6145                	addi	sp,sp,48
    8000096a:	8082                	ret

000000008000096c <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000096c:	1141                	addi	sp,sp,-16
    8000096e:	e422                	sd	s0,8(sp)
    80000970:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000972:	100007b7          	lui	a5,0x10000
    80000976:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097a:	8b85                	andi	a5,a5,1
    8000097c:	cb91                	beqz	a5,80000990 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    8000097e:	100007b7          	lui	a5,0x10000
    80000982:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000986:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1e>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	916080e7          	jalr	-1770(ra) # 800002b8 <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc2080e7          	jalr	-62(ra) # 8000096c <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	18248493          	addi	s1,s1,386 # 80010b38 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	210080e7          	jalr	528(ra) # 80000bd0 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e68080e7          	jalr	-408(ra) # 80000830 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b2080e7          	jalr	690(ra) # 80000c84 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00021797          	auipc	a5,0x21
    800009fc:	6c878793          	addi	a5,a5,1736 # 800220c0 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2bc080e7          	jalr	700(ra) # 80000ccc <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	15890913          	addi	s2,s2,344 # 80010b70 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1ae080e7          	jalr	430(ra) # 80000bd0 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	24e080e7          	jalr	590(ra) # 80000c84 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	ae6080e7          	jalr	-1306(ra) # 80000538 <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	94aa                	add	s1,s1,a0
    80000a72:	757d                	lui	a0,0xfffff
    80000a74:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a76:	94be                	add	s1,s1,a5
    80000a78:	0095ee63          	bltu	a1,s1,80000a94 <freerange+0x3a>
    80000a7c:	892e                	mv	s2,a1
    kfree(p);
    80000a7e:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	6985                	lui	s3,0x1
    kfree(p);
    80000a82:	01448533          	add	a0,s1,s4
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	f5e080e7          	jalr	-162(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8e:	94ce                	add	s1,s1,s3
    80000a90:	fe9979e3          	bgeu	s2,s1,80000a82 <freerange+0x28>
}
    80000a94:	70a2                	ld	ra,40(sp)
    80000a96:	7402                	ld	s0,32(sp)
    80000a98:	64e2                	ld	s1,24(sp)
    80000a9a:	6942                	ld	s2,16(sp)
    80000a9c:	69a2                	ld	s3,8(sp)
    80000a9e:	6a02                	ld	s4,0(sp)
    80000aa0:	6145                	addi	sp,sp,48
    80000aa2:	8082                	ret

0000000080000aa4 <kinit>:
{
    80000aa4:	1141                	addi	sp,sp,-16
    80000aa6:	e406                	sd	ra,8(sp)
    80000aa8:	e022                	sd	s0,0(sp)
    80000aaa:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aac:	00007597          	auipc	a1,0x7
    80000ab0:	5bc58593          	addi	a1,a1,1468 # 80008068 <digits+0x28>
    80000ab4:	00010517          	auipc	a0,0x10
    80000ab8:	0bc50513          	addi	a0,a0,188 # 80010b70 <kmem>
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	084080e7          	jalr	132(ra) # 80000b40 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac4:	45c5                	li	a1,17
    80000ac6:	05ee                	slli	a1,a1,0x1b
    80000ac8:	00021517          	auipc	a0,0x21
    80000acc:	5f850513          	addi	a0,a0,1528 # 800220c0 <end>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	f8a080e7          	jalr	-118(ra) # 80000a5a <freerange>
}
    80000ad8:	60a2                	ld	ra,8(sp)
    80000ada:	6402                	ld	s0,0(sp)
    80000adc:	0141                	addi	sp,sp,16
    80000ade:	8082                	ret

0000000080000ae0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae0:	1101                	addi	sp,sp,-32
    80000ae2:	ec06                	sd	ra,24(sp)
    80000ae4:	e822                	sd	s0,16(sp)
    80000ae6:	e426                	sd	s1,8(sp)
    80000ae8:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aea:	00010497          	auipc	s1,0x10
    80000aee:	08648493          	addi	s1,s1,134 # 80010b70 <kmem>
    80000af2:	8526                	mv	a0,s1
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	0dc080e7          	jalr	220(ra) # 80000bd0 <acquire>
  r = kmem.freelist;
    80000afc:	6c84                	ld	s1,24(s1)
  if(r)
    80000afe:	c885                	beqz	s1,80000b2e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b00:	609c                	ld	a5,0(s1)
    80000b02:	00010517          	auipc	a0,0x10
    80000b06:	06e50513          	addi	a0,a0,110 # 80010b70 <kmem>
    80000b0a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	178080e7          	jalr	376(ra) # 80000c84 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b14:	6605                	lui	a2,0x1
    80000b16:	4595                	li	a1,5
    80000b18:	8526                	mv	a0,s1
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	1b2080e7          	jalr	434(ra) # 80000ccc <memset>
  return (void*)r;
}
    80000b22:	8526                	mv	a0,s1
    80000b24:	60e2                	ld	ra,24(sp)
    80000b26:	6442                	ld	s0,16(sp)
    80000b28:	64a2                	ld	s1,8(sp)
    80000b2a:	6105                	addi	sp,sp,32
    80000b2c:	8082                	ret
  release(&kmem.lock);
    80000b2e:	00010517          	auipc	a0,0x10
    80000b32:	04250513          	addi	a0,a0,66 # 80010b70 <kmem>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	14e080e7          	jalr	334(ra) # 80000c84 <release>
  if(r)
    80000b3e:	b7d5                	j	80000b22 <kalloc+0x42>

0000000080000b40 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b40:	1141                	addi	sp,sp,-16
    80000b42:	e422                	sd	s0,8(sp)
    80000b44:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b46:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b48:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4c:	00053823          	sd	zero,16(a0)
}
    80000b50:	6422                	ld	s0,8(sp)
    80000b52:	0141                	addi	sp,sp,16
    80000b54:	8082                	ret

0000000080000b56 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b56:	411c                	lw	a5,0(a0)
    80000b58:	e399                	bnez	a5,80000b5e <holding+0x8>
    80000b5a:	4501                	li	a0,0
  return r;
}
    80000b5c:	8082                	ret
{
    80000b5e:	1101                	addi	sp,sp,-32
    80000b60:	ec06                	sd	ra,24(sp)
    80000b62:	e822                	sd	s0,16(sp)
    80000b64:	e426                	sd	s1,8(sp)
    80000b66:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b68:	6904                	ld	s1,16(a0)
    80000b6a:	00001097          	auipc	ra,0x1
    80000b6e:	e2c080e7          	jalr	-468(ra) # 80001996 <mycpu>
    80000b72:	40a48533          	sub	a0,s1,a0
    80000b76:	00153513          	seqz	a0,a0
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret

0000000080000b84 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b84:	1101                	addi	sp,sp,-32
    80000b86:	ec06                	sd	ra,24(sp)
    80000b88:	e822                	sd	s0,16(sp)
    80000b8a:	e426                	sd	s1,8(sp)
    80000b8c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b8e:	100024f3          	csrr	s1,sstatus
    80000b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b96:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b98:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9c:	00001097          	auipc	ra,0x1
    80000ba0:	dfa080e7          	jalr	-518(ra) # 80001996 <mycpu>
    80000ba4:	5d3c                	lw	a5,120(a0)
    80000ba6:	cf89                	beqz	a5,80000bc0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba8:	00001097          	auipc	ra,0x1
    80000bac:	dee080e7          	jalr	-530(ra) # 80001996 <mycpu>
    80000bb0:	5d3c                	lw	a5,120(a0)
    80000bb2:	2785                	addiw	a5,a5,1
    80000bb4:	dd3c                	sw	a5,120(a0)
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
    mycpu()->intena = old;
    80000bc0:	00001097          	auipc	ra,0x1
    80000bc4:	dd6080e7          	jalr	-554(ra) # 80001996 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc8:	8085                	srli	s1,s1,0x1
    80000bca:	8885                	andi	s1,s1,1
    80000bcc:	dd64                	sw	s1,124(a0)
    80000bce:	bfe9                	j	80000ba8 <push_off+0x24>

0000000080000bd0 <acquire>:
{
    80000bd0:	1101                	addi	sp,sp,-32
    80000bd2:	ec06                	sd	ra,24(sp)
    80000bd4:	e822                	sd	s0,16(sp)
    80000bd6:	e426                	sd	s1,8(sp)
    80000bd8:	1000                	addi	s0,sp,32
    80000bda:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	fa8080e7          	jalr	-88(ra) # 80000b84 <push_off>
  if(holding(lk))
    80000be4:	8526                	mv	a0,s1
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	f70080e7          	jalr	-144(ra) # 80000b56 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bee:	4705                	li	a4,1
  if(holding(lk))
    80000bf0:	e115                	bnez	a0,80000c14 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf2:	87ba                	mv	a5,a4
    80000bf4:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf8:	2781                	sext.w	a5,a5
    80000bfa:	ffe5                	bnez	a5,80000bf2 <acquire+0x22>
  __sync_synchronize();
    80000bfc:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c00:	00001097          	auipc	ra,0x1
    80000c04:	d96080e7          	jalr	-618(ra) # 80001996 <mycpu>
    80000c08:	e888                	sd	a0,16(s1)
}
    80000c0a:	60e2                	ld	ra,24(sp)
    80000c0c:	6442                	ld	s0,16(sp)
    80000c0e:	64a2                	ld	s1,8(sp)
    80000c10:	6105                	addi	sp,sp,32
    80000c12:	8082                	ret
    panic("acquire");
    80000c14:	00007517          	auipc	a0,0x7
    80000c18:	45c50513          	addi	a0,a0,1116 # 80008070 <digits+0x30>
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	91c080e7          	jalr	-1764(ra) # 80000538 <panic>

0000000080000c24 <pop_off>:

void
pop_off(void)
{
    80000c24:	1141                	addi	sp,sp,-16
    80000c26:	e406                	sd	ra,8(sp)
    80000c28:	e022                	sd	s0,0(sp)
    80000c2a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2c:	00001097          	auipc	ra,0x1
    80000c30:	d6a080e7          	jalr	-662(ra) # 80001996 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c34:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c38:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3a:	e78d                	bnez	a5,80000c64 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3c:	5d3c                	lw	a5,120(a0)
    80000c3e:	02f05b63          	blez	a5,80000c74 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c42:	37fd                	addiw	a5,a5,-1
    80000c44:	0007871b          	sext.w	a4,a5
    80000c48:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4a:	eb09                	bnez	a4,80000c5c <pop_off+0x38>
    80000c4c:	5d7c                	lw	a5,124(a0)
    80000c4e:	c799                	beqz	a5,80000c5c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c54:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c58:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5c:	60a2                	ld	ra,8(sp)
    80000c5e:	6402                	ld	s0,0(sp)
    80000c60:	0141                	addi	sp,sp,16
    80000c62:	8082                	ret
    panic("pop_off - interruptible");
    80000c64:	00007517          	auipc	a0,0x7
    80000c68:	41450513          	addi	a0,a0,1044 # 80008078 <digits+0x38>
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	8cc080e7          	jalr	-1844(ra) # 80000538 <panic>
    panic("pop_off");
    80000c74:	00007517          	auipc	a0,0x7
    80000c78:	41c50513          	addi	a0,a0,1052 # 80008090 <digits+0x50>
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	8bc080e7          	jalr	-1860(ra) # 80000538 <panic>

0000000080000c84 <release>:
{
    80000c84:	1101                	addi	sp,sp,-32
    80000c86:	ec06                	sd	ra,24(sp)
    80000c88:	e822                	sd	s0,16(sp)
    80000c8a:	e426                	sd	s1,8(sp)
    80000c8c:	1000                	addi	s0,sp,32
    80000c8e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	ec6080e7          	jalr	-314(ra) # 80000b56 <holding>
    80000c98:	c115                	beqz	a0,80000cbc <release+0x38>
  lk->cpu = 0;
    80000c9a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c9e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca2:	0f50000f          	fence	iorw,ow
    80000ca6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	f7a080e7          	jalr	-134(ra) # 80000c24 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00007517          	auipc	a0,0x7
    80000cc0:	3dc50513          	addi	a0,a0,988 # 80008098 <digits+0x58>
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	874080e7          	jalr	-1932(ra) # 80000538 <panic>

0000000080000ccc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ccc:	1141                	addi	sp,sp,-16
    80000cce:	e422                	sd	s0,8(sp)
    80000cd0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd2:	ca19                	beqz	a2,80000ce8 <memset+0x1c>
    80000cd4:	87aa                	mv	a5,a0
    80000cd6:	1602                	slli	a2,a2,0x20
    80000cd8:	9201                	srli	a2,a2,0x20
    80000cda:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cde:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce2:	0785                	addi	a5,a5,1
    80000ce4:	fee79de3          	bne	a5,a4,80000cde <memset+0x12>
  }
  return dst;
}
    80000ce8:	6422                	ld	s0,8(sp)
    80000cea:	0141                	addi	sp,sp,16
    80000cec:	8082                	ret

0000000080000cee <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cee:	1141                	addi	sp,sp,-16
    80000cf0:	e422                	sd	s0,8(sp)
    80000cf2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf4:	ca05                	beqz	a2,80000d24 <memcmp+0x36>
    80000cf6:	fff6069b          	addiw	a3,a2,-1
    80000cfa:	1682                	slli	a3,a3,0x20
    80000cfc:	9281                	srli	a3,a3,0x20
    80000cfe:	0685                	addi	a3,a3,1
    80000d00:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d02:	00054783          	lbu	a5,0(a0)
    80000d06:	0005c703          	lbu	a4,0(a1)
    80000d0a:	00e79863          	bne	a5,a4,80000d1a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0e:	0505                	addi	a0,a0,1
    80000d10:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d12:	fed518e3          	bne	a0,a3,80000d02 <memcmp+0x14>
  }

  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	a019                	j	80000d1e <memcmp+0x30>
      return *s1 - *s2;
    80000d1a:	40e7853b          	subw	a0,a5,a4
}
    80000d1e:	6422                	ld	s0,8(sp)
    80000d20:	0141                	addi	sp,sp,16
    80000d22:	8082                	ret
  return 0;
    80000d24:	4501                	li	a0,0
    80000d26:	bfe5                	j	80000d1e <memcmp+0x30>

0000000080000d28 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d28:	1141                	addi	sp,sp,-16
    80000d2a:	e422                	sd	s0,8(sp)
    80000d2c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2e:	c205                	beqz	a2,80000d4e <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d30:	02a5e263          	bltu	a1,a0,80000d54 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d34:	1602                	slli	a2,a2,0x20
    80000d36:	9201                	srli	a2,a2,0x20
    80000d38:	00c587b3          	add	a5,a1,a2
{
    80000d3c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3e:	0585                	addi	a1,a1,1
    80000d40:	0705                	addi	a4,a4,1
    80000d42:	fff5c683          	lbu	a3,-1(a1)
    80000d46:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4a:	fef59ae3          	bne	a1,a5,80000d3e <memmove+0x16>

  return dst;
}
    80000d4e:	6422                	ld	s0,8(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  if(s < d && s + n > d){
    80000d54:	02061693          	slli	a3,a2,0x20
    80000d58:	9281                	srli	a3,a3,0x20
    80000d5a:	00d58733          	add	a4,a1,a3
    80000d5e:	fce57be3          	bgeu	a0,a4,80000d34 <memmove+0xc>
    d += n;
    80000d62:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d64:	fff6079b          	addiw	a5,a2,-1
    80000d68:	1782                	slli	a5,a5,0x20
    80000d6a:	9381                	srli	a5,a5,0x20
    80000d6c:	fff7c793          	not	a5,a5
    80000d70:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d72:	177d                	addi	a4,a4,-1
    80000d74:	16fd                	addi	a3,a3,-1
    80000d76:	00074603          	lbu	a2,0(a4)
    80000d7a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7e:	fee79ae3          	bne	a5,a4,80000d72 <memmove+0x4a>
    80000d82:	b7f1                	j	80000d4e <memmove+0x26>

0000000080000d84 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e406                	sd	ra,8(sp)
    80000d88:	e022                	sd	s0,0(sp)
    80000d8a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8c:	00000097          	auipc	ra,0x0
    80000d90:	f9c080e7          	jalr	-100(ra) # 80000d28 <memmove>
}
    80000d94:	60a2                	ld	ra,8(sp)
    80000d96:	6402                	ld	s0,0(sp)
    80000d98:	0141                	addi	sp,sp,16
    80000d9a:	8082                	ret

0000000080000d9c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9c:	1141                	addi	sp,sp,-16
    80000d9e:	e422                	sd	s0,8(sp)
    80000da0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da2:	ce11                	beqz	a2,80000dbe <strncmp+0x22>
    80000da4:	00054783          	lbu	a5,0(a0)
    80000da8:	cf89                	beqz	a5,80000dc2 <strncmp+0x26>
    80000daa:	0005c703          	lbu	a4,0(a1)
    80000dae:	00f71a63          	bne	a4,a5,80000dc2 <strncmp+0x26>
    n--, p++, q++;
    80000db2:	367d                	addiw	a2,a2,-1
    80000db4:	0505                	addi	a0,a0,1
    80000db6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db8:	f675                	bnez	a2,80000da4 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dba:	4501                	li	a0,0
    80000dbc:	a809                	j	80000dce <strncmp+0x32>
    80000dbe:	4501                	li	a0,0
    80000dc0:	a039                	j	80000dce <strncmp+0x32>
  if(n == 0)
    80000dc2:	ca09                	beqz	a2,80000dd4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc4:	00054503          	lbu	a0,0(a0)
    80000dc8:	0005c783          	lbu	a5,0(a1)
    80000dcc:	9d1d                	subw	a0,a0,a5
}
    80000dce:	6422                	ld	s0,8(sp)
    80000dd0:	0141                	addi	sp,sp,16
    80000dd2:	8082                	ret
    return 0;
    80000dd4:	4501                	li	a0,0
    80000dd6:	bfe5                	j	80000dce <strncmp+0x32>

0000000080000dd8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd8:	1141                	addi	sp,sp,-16
    80000dda:	e422                	sd	s0,8(sp)
    80000ddc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dde:	872a                	mv	a4,a0
    80000de0:	8832                	mv	a6,a2
    80000de2:	367d                	addiw	a2,a2,-1
    80000de4:	01005963          	blez	a6,80000df6 <strncpy+0x1e>
    80000de8:	0705                	addi	a4,a4,1
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	fef70fa3          	sb	a5,-1(a4)
    80000df2:	0585                	addi	a1,a1,1
    80000df4:	f7f5                	bnez	a5,80000de0 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df6:	86ba                	mv	a3,a4
    80000df8:	00c05c63          	blez	a2,80000e10 <strncpy+0x38>
    *s++ = 0;
    80000dfc:	0685                	addi	a3,a3,1
    80000dfe:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e02:	fff6c793          	not	a5,a3
    80000e06:	9fb9                	addw	a5,a5,a4
    80000e08:	010787bb          	addw	a5,a5,a6
    80000e0c:	fef048e3          	bgtz	a5,80000dfc <strncpy+0x24>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	4685                	li	a3,1
    80000e5a:	9e89                	subw	a3,a3,a0
    80000e5c:	00f6853b          	addw	a0,a3,a5
    80000e60:	0785                	addi	a5,a5,1
    80000e62:	fff7c703          	lbu	a4,-1(a5)
    80000e66:	fb7d                	bnez	a4,80000e5c <strlen+0x14>
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b0c080e7          	jalr	-1268(ra) # 80001986 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	a8670713          	addi	a4,a4,-1402 # 80008908 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	af0080e7          	jalr	-1296(ra) # 80001986 <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6da080e7          	jalr	1754(ra) # 80000582 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	84e080e7          	jalr	-1970(ra) # 80002706 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	dc0080e7          	jalr	-576(ra) # 80005c80 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	09a080e7          	jalr	154(ra) # 80001f62 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57a080e7          	jalr	1402(ra) # 8000044a <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88a080e7          	jalr	-1910(ra) # 80000762 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69a080e7          	jalr	1690(ra) # 80000582 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68a080e7          	jalr	1674(ra) # 80000582 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67a080e7          	jalr	1658(ra) # 80000582 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b94080e7          	jalr	-1132(ra) # 80000aa4 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	322080e7          	jalr	802(ra) # 8000123a <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	9ae080e7          	jalr	-1618(ra) # 800018d6 <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	7ae080e7          	jalr	1966(ra) # 800026de <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	7ce080e7          	jalr	1998(ra) # 80002706 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	d2a080e7          	jalr	-726(ra) # 80005c6a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	d38080e7          	jalr	-712(ra) # 80005c80 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	eee080e7          	jalr	-274(ra) # 80002e3e <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	592080e7          	jalr	1426(ra) # 800034ea <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	53c080e7          	jalr	1340(ra) # 8000449c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	e20080e7          	jalr	-480(ra) # 80005d88 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	dbc080e7          	jalr	-580(ra) # 80001d2c <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	98f72523          	sw	a5,-1654(a4) # 80008908 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f8e:	00008797          	auipc	a5,0x8
    80000f92:	9827b783          	ld	a5,-1662(a5) # 80008910 <kernel_pagetable>
    80000f96:	83b1                	srli	a5,a5,0xc
    80000f98:	577d                	li	a4,-1
    80000f9a:	177e                	slli	a4,a4,0x3f
    80000f9c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f9e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fa2:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa6:	6422                	ld	s0,8(sp)
    80000fa8:	0141                	addi	sp,sp,16
    80000faa:	8082                	ret

0000000080000fac <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fac:	7139                	addi	sp,sp,-64
    80000fae:	fc06                	sd	ra,56(sp)
    80000fb0:	f822                	sd	s0,48(sp)
    80000fb2:	f426                	sd	s1,40(sp)
    80000fb4:	f04a                	sd	s2,32(sp)
    80000fb6:	ec4e                	sd	s3,24(sp)
    80000fb8:	e852                	sd	s4,16(sp)
    80000fba:	e456                	sd	s5,8(sp)
    80000fbc:	e05a                	sd	s6,0(sp)
    80000fbe:	0080                	addi	s0,sp,64
    80000fc0:	84aa                	mv	s1,a0
    80000fc2:	89ae                	mv	s3,a1
    80000fc4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc6:	57fd                	li	a5,-1
    80000fc8:	83e9                	srli	a5,a5,0x1a
    80000fca:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fcc:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fce:	04b7f263          	bgeu	a5,a1,80001012 <walk+0x66>
    panic("walk");
    80000fd2:	00007517          	auipc	a0,0x7
    80000fd6:	0fe50513          	addi	a0,a0,254 # 800080d0 <digits+0x90>
    80000fda:	fffff097          	auipc	ra,0xfffff
    80000fde:	55e080e7          	jalr	1374(ra) # 80000538 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe2:	060a8663          	beqz	s5,8000104e <walk+0xa2>
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	afa080e7          	jalr	-1286(ra) # 80000ae0 <kalloc>
    80000fee:	84aa                	mv	s1,a0
    80000ff0:	c529                	beqz	a0,8000103a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff2:	6605                	lui	a2,0x1
    80000ff4:	4581                	li	a1,0
    80000ff6:	00000097          	auipc	ra,0x0
    80000ffa:	cd6080e7          	jalr	-810(ra) # 80000ccc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ffe:	00c4d793          	srli	a5,s1,0xc
    80001002:	07aa                	slli	a5,a5,0xa
    80001004:	0017e793          	ori	a5,a5,1
    80001008:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000100c:	3a5d                	addiw	s4,s4,-9
    8000100e:	036a0063          	beq	s4,s6,8000102e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001012:	0149d933          	srl	s2,s3,s4
    80001016:	1ff97913          	andi	s2,s2,511
    8000101a:	090e                	slli	s2,s2,0x3
    8000101c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000101e:	00093483          	ld	s1,0(s2)
    80001022:	0014f793          	andi	a5,s1,1
    80001026:	dfd5                	beqz	a5,80000fe2 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001028:	80a9                	srli	s1,s1,0xa
    8000102a:	04b2                	slli	s1,s1,0xc
    8000102c:	b7c5                	j	8000100c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000102e:	00c9d513          	srli	a0,s3,0xc
    80001032:	1ff57513          	andi	a0,a0,511
    80001036:	050e                	slli	a0,a0,0x3
    80001038:	9526                	add	a0,a0,s1
}
    8000103a:	70e2                	ld	ra,56(sp)
    8000103c:	7442                	ld	s0,48(sp)
    8000103e:	74a2                	ld	s1,40(sp)
    80001040:	7902                	ld	s2,32(sp)
    80001042:	69e2                	ld	s3,24(sp)
    80001044:	6a42                	ld	s4,16(sp)
    80001046:	6aa2                	ld	s5,8(sp)
    80001048:	6b02                	ld	s6,0(sp)
    8000104a:	6121                	addi	sp,sp,64
    8000104c:	8082                	ret
        return 0;
    8000104e:	4501                	li	a0,0
    80001050:	b7ed                	j	8000103a <walk+0x8e>

0000000080001052 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001052:	57fd                	li	a5,-1
    80001054:	83e9                	srli	a5,a5,0x1a
    80001056:	00b7f463          	bgeu	a5,a1,8000105e <walkaddr+0xc>
    return 0;
    8000105a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000105c:	8082                	ret
{
    8000105e:	1141                	addi	sp,sp,-16
    80001060:	e406                	sd	ra,8(sp)
    80001062:	e022                	sd	s0,0(sp)
    80001064:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001066:	4601                	li	a2,0
    80001068:	00000097          	auipc	ra,0x0
    8000106c:	f44080e7          	jalr	-188(ra) # 80000fac <walk>
  if(pte == 0)
    80001070:	c105                	beqz	a0,80001090 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001072:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001074:	0117f693          	andi	a3,a5,17
    80001078:	4745                	li	a4,17
    return 0;
    8000107a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000107c:	00e68663          	beq	a3,a4,80001088 <walkaddr+0x36>
}
    80001080:	60a2                	ld	ra,8(sp)
    80001082:	6402                	ld	s0,0(sp)
    80001084:	0141                	addi	sp,sp,16
    80001086:	8082                	ret
  pa = PTE2PA(*pte);
    80001088:	00a7d513          	srli	a0,a5,0xa
    8000108c:	0532                	slli	a0,a0,0xc
  return pa;
    8000108e:	bfcd                	j	80001080 <walkaddr+0x2e>
    return 0;
    80001090:	4501                	li	a0,0
    80001092:	b7fd                	j	80001080 <walkaddr+0x2e>

0000000080001094 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001094:	715d                	addi	sp,sp,-80
    80001096:	e486                	sd	ra,72(sp)
    80001098:	e0a2                	sd	s0,64(sp)
    8000109a:	fc26                	sd	s1,56(sp)
    8000109c:	f84a                	sd	s2,48(sp)
    8000109e:	f44e                	sd	s3,40(sp)
    800010a0:	f052                	sd	s4,32(sp)
    800010a2:	ec56                	sd	s5,24(sp)
    800010a4:	e85a                	sd	s6,16(sp)
    800010a6:	e45e                	sd	s7,8(sp)
    800010a8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010aa:	c639                	beqz	a2,800010f8 <mappages+0x64>
    800010ac:	8aaa                	mv	s5,a0
    800010ae:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b0:	77fd                	lui	a5,0xfffff
    800010b2:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010b6:	15fd                	addi	a1,a1,-1
    800010b8:	00c589b3          	add	s3,a1,a2
    800010bc:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010c0:	8952                	mv	s2,s4
    800010c2:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010c6:	6b85                	lui	s7,0x1
    800010c8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010cc:	4605                	li	a2,1
    800010ce:	85ca                	mv	a1,s2
    800010d0:	8556                	mv	a0,s5
    800010d2:	00000097          	auipc	ra,0x0
    800010d6:	eda080e7          	jalr	-294(ra) # 80000fac <walk>
    800010da:	cd1d                	beqz	a0,80001118 <mappages+0x84>
    if(*pte & PTE_V)
    800010dc:	611c                	ld	a5,0(a0)
    800010de:	8b85                	andi	a5,a5,1
    800010e0:	e785                	bnez	a5,80001108 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e2:	80b1                	srli	s1,s1,0xc
    800010e4:	04aa                	slli	s1,s1,0xa
    800010e6:	0164e4b3          	or	s1,s1,s6
    800010ea:	0014e493          	ori	s1,s1,1
    800010ee:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f0:	05390063          	beq	s2,s3,80001130 <mappages+0x9c>
    a += PGSIZE;
    800010f4:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010f6:	bfc9                	j	800010c8 <mappages+0x34>
    panic("mappages: size");
    800010f8:	00007517          	auipc	a0,0x7
    800010fc:	fe050513          	addi	a0,a0,-32 # 800080d8 <digits+0x98>
    80001100:	fffff097          	auipc	ra,0xfffff
    80001104:	438080e7          	jalr	1080(ra) # 80000538 <panic>
      panic("mappages: remap");
    80001108:	00007517          	auipc	a0,0x7
    8000110c:	fe050513          	addi	a0,a0,-32 # 800080e8 <digits+0xa8>
    80001110:	fffff097          	auipc	ra,0xfffff
    80001114:	428080e7          	jalr	1064(ra) # 80000538 <panic>
      return -1;
    80001118:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111a:	60a6                	ld	ra,72(sp)
    8000111c:	6406                	ld	s0,64(sp)
    8000111e:	74e2                	ld	s1,56(sp)
    80001120:	7942                	ld	s2,48(sp)
    80001122:	79a2                	ld	s3,40(sp)
    80001124:	7a02                	ld	s4,32(sp)
    80001126:	6ae2                	ld	s5,24(sp)
    80001128:	6b42                	ld	s6,16(sp)
    8000112a:	6ba2                	ld	s7,8(sp)
    8000112c:	6161                	addi	sp,sp,80
    8000112e:	8082                	ret
  return 0;
    80001130:	4501                	li	a0,0
    80001132:	b7e5                	j	8000111a <mappages+0x86>

0000000080001134 <kvmmap>:
{
    80001134:	1141                	addi	sp,sp,-16
    80001136:	e406                	sd	ra,8(sp)
    80001138:	e022                	sd	s0,0(sp)
    8000113a:	0800                	addi	s0,sp,16
    8000113c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000113e:	86b2                	mv	a3,a2
    80001140:	863e                	mv	a2,a5
    80001142:	00000097          	auipc	ra,0x0
    80001146:	f52080e7          	jalr	-174(ra) # 80001094 <mappages>
    8000114a:	e509                	bnez	a0,80001154 <kvmmap+0x20>
}
    8000114c:	60a2                	ld	ra,8(sp)
    8000114e:	6402                	ld	s0,0(sp)
    80001150:	0141                	addi	sp,sp,16
    80001152:	8082                	ret
    panic("kvmmap");
    80001154:	00007517          	auipc	a0,0x7
    80001158:	fa450513          	addi	a0,a0,-92 # 800080f8 <digits+0xb8>
    8000115c:	fffff097          	auipc	ra,0xfffff
    80001160:	3dc080e7          	jalr	988(ra) # 80000538 <panic>

0000000080001164 <kvmmake>:
{
    80001164:	1101                	addi	sp,sp,-32
    80001166:	ec06                	sd	ra,24(sp)
    80001168:	e822                	sd	s0,16(sp)
    8000116a:	e426                	sd	s1,8(sp)
    8000116c:	e04a                	sd	s2,0(sp)
    8000116e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001170:	00000097          	auipc	ra,0x0
    80001174:	970080e7          	jalr	-1680(ra) # 80000ae0 <kalloc>
    80001178:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117a:	6605                	lui	a2,0x1
    8000117c:	4581                	li	a1,0
    8000117e:	00000097          	auipc	ra,0x0
    80001182:	b4e080e7          	jalr	-1202(ra) # 80000ccc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001186:	4719                	li	a4,6
    80001188:	6685                	lui	a3,0x1
    8000118a:	10000637          	lui	a2,0x10000
    8000118e:	100005b7          	lui	a1,0x10000
    80001192:	8526                	mv	a0,s1
    80001194:	00000097          	auipc	ra,0x0
    80001198:	fa0080e7          	jalr	-96(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119c:	4719                	li	a4,6
    8000119e:	6685                	lui	a3,0x1
    800011a0:	10001637          	lui	a2,0x10001
    800011a4:	100015b7          	lui	a1,0x10001
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f8a080e7          	jalr	-118(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b2:	4719                	li	a4,6
    800011b4:	004006b7          	lui	a3,0x400
    800011b8:	0c000637          	lui	a2,0xc000
    800011bc:	0c0005b7          	lui	a1,0xc000
    800011c0:	8526                	mv	a0,s1
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	f72080e7          	jalr	-142(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ca:	00007917          	auipc	s2,0x7
    800011ce:	e3690913          	addi	s2,s2,-458 # 80008000 <etext>
    800011d2:	4729                	li	a4,10
    800011d4:	80007697          	auipc	a3,0x80007
    800011d8:	e2c68693          	addi	a3,a3,-468 # 8000 <_entry-0x7fff8000>
    800011dc:	4605                	li	a2,1
    800011de:	067e                	slli	a2,a2,0x1f
    800011e0:	85b2                	mv	a1,a2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f50080e7          	jalr	-176(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011ec:	4719                	li	a4,6
    800011ee:	46c5                	li	a3,17
    800011f0:	06ee                	slli	a3,a3,0x1b
    800011f2:	412686b3          	sub	a3,a3,s2
    800011f6:	864a                	mv	a2,s2
    800011f8:	85ca                	mv	a1,s2
    800011fa:	8526                	mv	a0,s1
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	f38080e7          	jalr	-200(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001204:	4729                	li	a4,10
    80001206:	6685                	lui	a3,0x1
    80001208:	00006617          	auipc	a2,0x6
    8000120c:	df860613          	addi	a2,a2,-520 # 80007000 <_trampoline>
    80001210:	040005b7          	lui	a1,0x4000
    80001214:	15fd                	addi	a1,a1,-1
    80001216:	05b2                	slli	a1,a1,0xc
    80001218:	8526                	mv	a0,s1
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	f1a080e7          	jalr	-230(ra) # 80001134 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	61c080e7          	jalr	1564(ra) # 80001840 <proc_mapstacks>
}
    8000122c:	8526                	mv	a0,s1
    8000122e:	60e2                	ld	ra,24(sp)
    80001230:	6442                	ld	s0,16(sp)
    80001232:	64a2                	ld	s1,8(sp)
    80001234:	6902                	ld	s2,0(sp)
    80001236:	6105                	addi	sp,sp,32
    80001238:	8082                	ret

000000008000123a <kvminit>:
{
    8000123a:	1141                	addi	sp,sp,-16
    8000123c:	e406                	sd	ra,8(sp)
    8000123e:	e022                	sd	s0,0(sp)
    80001240:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001242:	00000097          	auipc	ra,0x0
    80001246:	f22080e7          	jalr	-222(ra) # 80001164 <kvmmake>
    8000124a:	00007797          	auipc	a5,0x7
    8000124e:	6ca7b323          	sd	a0,1734(a5) # 80008910 <kernel_pagetable>
}
    80001252:	60a2                	ld	ra,8(sp)
    80001254:	6402                	ld	s0,0(sp)
    80001256:	0141                	addi	sp,sp,16
    80001258:	8082                	ret

000000008000125a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125a:	715d                	addi	sp,sp,-80
    8000125c:	e486                	sd	ra,72(sp)
    8000125e:	e0a2                	sd	s0,64(sp)
    80001260:	fc26                	sd	s1,56(sp)
    80001262:	f84a                	sd	s2,48(sp)
    80001264:	f44e                	sd	s3,40(sp)
    80001266:	f052                	sd	s4,32(sp)
    80001268:	ec56                	sd	s5,24(sp)
    8000126a:	e85a                	sd	s6,16(sp)
    8000126c:	e45e                	sd	s7,8(sp)
    8000126e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001270:	03459793          	slli	a5,a1,0x34
    80001274:	e795                	bnez	a5,800012a0 <uvmunmap+0x46>
    80001276:	8a2a                	mv	s4,a0
    80001278:	892e                	mv	s2,a1
    8000127a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000127c:	0632                	slli	a2,a2,0xc
    8000127e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001282:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001284:	6b05                	lui	s6,0x1
    80001286:	0735e263          	bltu	a1,s3,800012ea <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128a:	60a6                	ld	ra,72(sp)
    8000128c:	6406                	ld	s0,64(sp)
    8000128e:	74e2                	ld	s1,56(sp)
    80001290:	7942                	ld	s2,48(sp)
    80001292:	79a2                	ld	s3,40(sp)
    80001294:	7a02                	ld	s4,32(sp)
    80001296:	6ae2                	ld	s5,24(sp)
    80001298:	6b42                	ld	s6,16(sp)
    8000129a:	6ba2                	ld	s7,8(sp)
    8000129c:	6161                	addi	sp,sp,80
    8000129e:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a0:	00007517          	auipc	a0,0x7
    800012a4:	e6050513          	addi	a0,a0,-416 # 80008100 <digits+0xc0>
    800012a8:	fffff097          	auipc	ra,0xfffff
    800012ac:	290080e7          	jalr	656(ra) # 80000538 <panic>
      panic("uvmunmap: walk");
    800012b0:	00007517          	auipc	a0,0x7
    800012b4:	e6850513          	addi	a0,a0,-408 # 80008118 <digits+0xd8>
    800012b8:	fffff097          	auipc	ra,0xfffff
    800012bc:	280080e7          	jalr	640(ra) # 80000538 <panic>
      panic("uvmunmap: not mapped");
    800012c0:	00007517          	auipc	a0,0x7
    800012c4:	e6850513          	addi	a0,a0,-408 # 80008128 <digits+0xe8>
    800012c8:	fffff097          	auipc	ra,0xfffff
    800012cc:	270080e7          	jalr	624(ra) # 80000538 <panic>
      panic("uvmunmap: not a leaf");
    800012d0:	00007517          	auipc	a0,0x7
    800012d4:	e7050513          	addi	a0,a0,-400 # 80008140 <digits+0x100>
    800012d8:	fffff097          	auipc	ra,0xfffff
    800012dc:	260080e7          	jalr	608(ra) # 80000538 <panic>
    *pte = 0;
    800012e0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e4:	995a                	add	s2,s2,s6
    800012e6:	fb3972e3          	bgeu	s2,s3,8000128a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ea:	4601                	li	a2,0
    800012ec:	85ca                	mv	a1,s2
    800012ee:	8552                	mv	a0,s4
    800012f0:	00000097          	auipc	ra,0x0
    800012f4:	cbc080e7          	jalr	-836(ra) # 80000fac <walk>
    800012f8:	84aa                	mv	s1,a0
    800012fa:	d95d                	beqz	a0,800012b0 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012fc:	6108                	ld	a0,0(a0)
    800012fe:	00157793          	andi	a5,a0,1
    80001302:	dfdd                	beqz	a5,800012c0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001304:	3ff57793          	andi	a5,a0,1023
    80001308:	fd7784e3          	beq	a5,s7,800012d0 <uvmunmap+0x76>
    if(do_free){
    8000130c:	fc0a8ae3          	beqz	s5,800012e0 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001310:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001312:	0532                	slli	a0,a0,0xc
    80001314:	fffff097          	auipc	ra,0xfffff
    80001318:	6d0080e7          	jalr	1744(ra) # 800009e4 <kfree>
    8000131c:	b7d1                	j	800012e0 <uvmunmap+0x86>

000000008000131e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000131e:	1101                	addi	sp,sp,-32
    80001320:	ec06                	sd	ra,24(sp)
    80001322:	e822                	sd	s0,16(sp)
    80001324:	e426                	sd	s1,8(sp)
    80001326:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	7b8080e7          	jalr	1976(ra) # 80000ae0 <kalloc>
    80001330:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001332:	c519                	beqz	a0,80001340 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001334:	6605                	lui	a2,0x1
    80001336:	4581                	li	a1,0
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	994080e7          	jalr	-1644(ra) # 80000ccc <memset>
  return pagetable;
}
    80001340:	8526                	mv	a0,s1
    80001342:	60e2                	ld	ra,24(sp)
    80001344:	6442                	ld	s0,16(sp)
    80001346:	64a2                	ld	s1,8(sp)
    80001348:	6105                	addi	sp,sp,32
    8000134a:	8082                	ret

000000008000134c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000134c:	7179                	addi	sp,sp,-48
    8000134e:	f406                	sd	ra,40(sp)
    80001350:	f022                	sd	s0,32(sp)
    80001352:	ec26                	sd	s1,24(sp)
    80001354:	e84a                	sd	s2,16(sp)
    80001356:	e44e                	sd	s3,8(sp)
    80001358:	e052                	sd	s4,0(sp)
    8000135a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000135c:	6785                	lui	a5,0x1
    8000135e:	04f67863          	bgeu	a2,a5,800013ae <uvmfirst+0x62>
    80001362:	8a2a                	mv	s4,a0
    80001364:	89ae                	mv	s3,a1
    80001366:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001368:	fffff097          	auipc	ra,0xfffff
    8000136c:	778080e7          	jalr	1912(ra) # 80000ae0 <kalloc>
    80001370:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001372:	6605                	lui	a2,0x1
    80001374:	4581                	li	a1,0
    80001376:	00000097          	auipc	ra,0x0
    8000137a:	956080e7          	jalr	-1706(ra) # 80000ccc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000137e:	4779                	li	a4,30
    80001380:	86ca                	mv	a3,s2
    80001382:	6605                	lui	a2,0x1
    80001384:	4581                	li	a1,0
    80001386:	8552                	mv	a0,s4
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	d0c080e7          	jalr	-756(ra) # 80001094 <mappages>
  memmove(mem, src, sz);
    80001390:	8626                	mv	a2,s1
    80001392:	85ce                	mv	a1,s3
    80001394:	854a                	mv	a0,s2
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	992080e7          	jalr	-1646(ra) # 80000d28 <memmove>
}
    8000139e:	70a2                	ld	ra,40(sp)
    800013a0:	7402                	ld	s0,32(sp)
    800013a2:	64e2                	ld	s1,24(sp)
    800013a4:	6942                	ld	s2,16(sp)
    800013a6:	69a2                	ld	s3,8(sp)
    800013a8:	6a02                	ld	s4,0(sp)
    800013aa:	6145                	addi	sp,sp,48
    800013ac:	8082                	ret
    panic("uvmfirst: more than a page");
    800013ae:	00007517          	auipc	a0,0x7
    800013b2:	daa50513          	addi	a0,a0,-598 # 80008158 <digits+0x118>
    800013b6:	fffff097          	auipc	ra,0xfffff
    800013ba:	182080e7          	jalr	386(ra) # 80000538 <panic>

00000000800013be <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013be:	1101                	addi	sp,sp,-32
    800013c0:	ec06                	sd	ra,24(sp)
    800013c2:	e822                	sd	s0,16(sp)
    800013c4:	e426                	sd	s1,8(sp)
    800013c6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013c8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ca:	00b67d63          	bgeu	a2,a1,800013e4 <uvmdealloc+0x26>
    800013ce:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d0:	6785                	lui	a5,0x1
    800013d2:	17fd                	addi	a5,a5,-1
    800013d4:	00f60733          	add	a4,a2,a5
    800013d8:	767d                	lui	a2,0xfffff
    800013da:	8f71                	and	a4,a4,a2
    800013dc:	97ae                	add	a5,a5,a1
    800013de:	8ff1                	and	a5,a5,a2
    800013e0:	00f76863          	bltu	a4,a5,800013f0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e4:	8526                	mv	a0,s1
    800013e6:	60e2                	ld	ra,24(sp)
    800013e8:	6442                	ld	s0,16(sp)
    800013ea:	64a2                	ld	s1,8(sp)
    800013ec:	6105                	addi	sp,sp,32
    800013ee:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f0:	8f99                	sub	a5,a5,a4
    800013f2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f4:	4685                	li	a3,1
    800013f6:	0007861b          	sext.w	a2,a5
    800013fa:	85ba                	mv	a1,a4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	e5e080e7          	jalr	-418(ra) # 8000125a <uvmunmap>
    80001404:	b7c5                	j	800013e4 <uvmdealloc+0x26>

0000000080001406 <uvmalloc>:
  if(newsz < oldsz)
    80001406:	0ab66163          	bltu	a2,a1,800014a8 <uvmalloc+0xa2>
{
    8000140a:	7139                	addi	sp,sp,-64
    8000140c:	fc06                	sd	ra,56(sp)
    8000140e:	f822                	sd	s0,48(sp)
    80001410:	f426                	sd	s1,40(sp)
    80001412:	f04a                	sd	s2,32(sp)
    80001414:	ec4e                	sd	s3,24(sp)
    80001416:	e852                	sd	s4,16(sp)
    80001418:	e456                	sd	s5,8(sp)
    8000141a:	0080                	addi	s0,sp,64
    8000141c:	8aaa                	mv	s5,a0
    8000141e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001420:	6985                	lui	s3,0x1
    80001422:	19fd                	addi	s3,s3,-1
    80001424:	95ce                	add	a1,a1,s3
    80001426:	79fd                	lui	s3,0xfffff
    80001428:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000142c:	08c9f063          	bgeu	s3,a2,800014ac <uvmalloc+0xa6>
    80001430:	894e                	mv	s2,s3
    mem = kalloc();
    80001432:	fffff097          	auipc	ra,0xfffff
    80001436:	6ae080e7          	jalr	1710(ra) # 80000ae0 <kalloc>
    8000143a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000143c:	c51d                	beqz	a0,8000146a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000143e:	6605                	lui	a2,0x1
    80001440:	4581                	li	a1,0
    80001442:	00000097          	auipc	ra,0x0
    80001446:	88a080e7          	jalr	-1910(ra) # 80000ccc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000144a:	4779                	li	a4,30
    8000144c:	86a6                	mv	a3,s1
    8000144e:	6605                	lui	a2,0x1
    80001450:	85ca                	mv	a1,s2
    80001452:	8556                	mv	a0,s5
    80001454:	00000097          	auipc	ra,0x0
    80001458:	c40080e7          	jalr	-960(ra) # 80001094 <mappages>
    8000145c:	e905                	bnez	a0,8000148c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000145e:	6785                	lui	a5,0x1
    80001460:	993e                	add	s2,s2,a5
    80001462:	fd4968e3          	bltu	s2,s4,80001432 <uvmalloc+0x2c>
  return newsz;
    80001466:	8552                	mv	a0,s4
    80001468:	a809                	j	8000147a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000146a:	864e                	mv	a2,s3
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	f4e080e7          	jalr	-178(ra) # 800013be <uvmdealloc>
      return 0;
    80001478:	4501                	li	a0,0
}
    8000147a:	70e2                	ld	ra,56(sp)
    8000147c:	7442                	ld	s0,48(sp)
    8000147e:	74a2                	ld	s1,40(sp)
    80001480:	7902                	ld	s2,32(sp)
    80001482:	69e2                	ld	s3,24(sp)
    80001484:	6a42                	ld	s4,16(sp)
    80001486:	6aa2                	ld	s5,8(sp)
    80001488:	6121                	addi	sp,sp,64
    8000148a:	8082                	ret
      kfree(mem);
    8000148c:	8526                	mv	a0,s1
    8000148e:	fffff097          	auipc	ra,0xfffff
    80001492:	556080e7          	jalr	1366(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001496:	864e                	mv	a2,s3
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f22080e7          	jalr	-222(ra) # 800013be <uvmdealloc>
      return 0;
    800014a4:	4501                	li	a0,0
    800014a6:	bfd1                	j	8000147a <uvmalloc+0x74>
    return oldsz;
    800014a8:	852e                	mv	a0,a1
}
    800014aa:	8082                	ret
  return newsz;
    800014ac:	8532                	mv	a0,a2
    800014ae:	b7f1                	j	8000147a <uvmalloc+0x74>

00000000800014b0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b0:	7179                	addi	sp,sp,-48
    800014b2:	f406                	sd	ra,40(sp)
    800014b4:	f022                	sd	s0,32(sp)
    800014b6:	ec26                	sd	s1,24(sp)
    800014b8:	e84a                	sd	s2,16(sp)
    800014ba:	e44e                	sd	s3,8(sp)
    800014bc:	e052                	sd	s4,0(sp)
    800014be:	1800                	addi	s0,sp,48
    800014c0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c2:	84aa                	mv	s1,a0
    800014c4:	6905                	lui	s2,0x1
    800014c6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014c8:	4985                	li	s3,1
    800014ca:	a821                	j	800014e2 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014cc:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ce:	0532                	slli	a0,a0,0xc
    800014d0:	00000097          	auipc	ra,0x0
    800014d4:	fe0080e7          	jalr	-32(ra) # 800014b0 <freewalk>
      pagetable[i] = 0;
    800014d8:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014dc:	04a1                	addi	s1,s1,8
    800014de:	03248163          	beq	s1,s2,80001500 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014e2:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	00f57793          	andi	a5,a0,15
    800014e8:	ff3782e3          	beq	a5,s3,800014cc <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014ec:	8905                	andi	a0,a0,1
    800014ee:	d57d                	beqz	a0,800014dc <freewalk+0x2c>
      panic("freewalk: leaf");
    800014f0:	00007517          	auipc	a0,0x7
    800014f4:	c8850513          	addi	a0,a0,-888 # 80008178 <digits+0x138>
    800014f8:	fffff097          	auipc	ra,0xfffff
    800014fc:	040080e7          	jalr	64(ra) # 80000538 <panic>
    }
  }
  kfree((void*)pagetable);
    80001500:	8552                	mv	a0,s4
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	4e2080e7          	jalr	1250(ra) # 800009e4 <kfree>
}
    8000150a:	70a2                	ld	ra,40(sp)
    8000150c:	7402                	ld	s0,32(sp)
    8000150e:	64e2                	ld	s1,24(sp)
    80001510:	6942                	ld	s2,16(sp)
    80001512:	69a2                	ld	s3,8(sp)
    80001514:	6a02                	ld	s4,0(sp)
    80001516:	6145                	addi	sp,sp,48
    80001518:	8082                	ret

000000008000151a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000151a:	1101                	addi	sp,sp,-32
    8000151c:	ec06                	sd	ra,24(sp)
    8000151e:	e822                	sd	s0,16(sp)
    80001520:	e426                	sd	s1,8(sp)
    80001522:	1000                	addi	s0,sp,32
    80001524:	84aa                	mv	s1,a0
  if(sz > 0)
    80001526:	e999                	bnez	a1,8000153c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001528:	8526                	mv	a0,s1
    8000152a:	00000097          	auipc	ra,0x0
    8000152e:	f86080e7          	jalr	-122(ra) # 800014b0 <freewalk>
}
    80001532:	60e2                	ld	ra,24(sp)
    80001534:	6442                	ld	s0,16(sp)
    80001536:	64a2                	ld	s1,8(sp)
    80001538:	6105                	addi	sp,sp,32
    8000153a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000153c:	6605                	lui	a2,0x1
    8000153e:	167d                	addi	a2,a2,-1
    80001540:	962e                	add	a2,a2,a1
    80001542:	4685                	li	a3,1
    80001544:	8231                	srli	a2,a2,0xc
    80001546:	4581                	li	a1,0
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	d12080e7          	jalr	-750(ra) # 8000125a <uvmunmap>
    80001550:	bfe1                	j	80001528 <uvmfree+0xe>

0000000080001552 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001552:	c679                	beqz	a2,80001620 <uvmcopy+0xce>
{
    80001554:	715d                	addi	sp,sp,-80
    80001556:	e486                	sd	ra,72(sp)
    80001558:	e0a2                	sd	s0,64(sp)
    8000155a:	fc26                	sd	s1,56(sp)
    8000155c:	f84a                	sd	s2,48(sp)
    8000155e:	f44e                	sd	s3,40(sp)
    80001560:	f052                	sd	s4,32(sp)
    80001562:	ec56                	sd	s5,24(sp)
    80001564:	e85a                	sd	s6,16(sp)
    80001566:	e45e                	sd	s7,8(sp)
    80001568:	0880                	addi	s0,sp,80
    8000156a:	8b2a                	mv	s6,a0
    8000156c:	8aae                	mv	s5,a1
    8000156e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001570:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001572:	4601                	li	a2,0
    80001574:	85ce                	mv	a1,s3
    80001576:	855a                	mv	a0,s6
    80001578:	00000097          	auipc	ra,0x0
    8000157c:	a34080e7          	jalr	-1484(ra) # 80000fac <walk>
    80001580:	c531                	beqz	a0,800015cc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001582:	6118                	ld	a4,0(a0)
    80001584:	00177793          	andi	a5,a4,1
    80001588:	cbb1                	beqz	a5,800015dc <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000158a:	00a75593          	srli	a1,a4,0xa
    8000158e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001592:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001596:	fffff097          	auipc	ra,0xfffff
    8000159a:	54a080e7          	jalr	1354(ra) # 80000ae0 <kalloc>
    8000159e:	892a                	mv	s2,a0
    800015a0:	c939                	beqz	a0,800015f6 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015a2:	6605                	lui	a2,0x1
    800015a4:	85de                	mv	a1,s7
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	782080e7          	jalr	1922(ra) # 80000d28 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ae:	8726                	mv	a4,s1
    800015b0:	86ca                	mv	a3,s2
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85ce                	mv	a1,s3
    800015b6:	8556                	mv	a0,s5
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	adc080e7          	jalr	-1316(ra) # 80001094 <mappages>
    800015c0:	e515                	bnez	a0,800015ec <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015c2:	6785                	lui	a5,0x1
    800015c4:	99be                	add	s3,s3,a5
    800015c6:	fb49e6e3          	bltu	s3,s4,80001572 <uvmcopy+0x20>
    800015ca:	a081                	j	8000160a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015cc:	00007517          	auipc	a0,0x7
    800015d0:	bbc50513          	addi	a0,a0,-1092 # 80008188 <digits+0x148>
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	f64080e7          	jalr	-156(ra) # 80000538 <panic>
      panic("uvmcopy: page not present");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bcc50513          	addi	a0,a0,-1076 # 800081a8 <digits+0x168>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f54080e7          	jalr	-172(ra) # 80000538 <panic>
      kfree(mem);
    800015ec:	854a                	mv	a0,s2
    800015ee:	fffff097          	auipc	ra,0xfffff
    800015f2:	3f6080e7          	jalr	1014(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015f6:	4685                	li	a3,1
    800015f8:	00c9d613          	srli	a2,s3,0xc
    800015fc:	4581                	li	a1,0
    800015fe:	8556                	mv	a0,s5
    80001600:	00000097          	auipc	ra,0x0
    80001604:	c5a080e7          	jalr	-934(ra) # 8000125a <uvmunmap>
  return -1;
    80001608:	557d                	li	a0,-1
}
    8000160a:	60a6                	ld	ra,72(sp)
    8000160c:	6406                	ld	s0,64(sp)
    8000160e:	74e2                	ld	s1,56(sp)
    80001610:	7942                	ld	s2,48(sp)
    80001612:	79a2                	ld	s3,40(sp)
    80001614:	7a02                	ld	s4,32(sp)
    80001616:	6ae2                	ld	s5,24(sp)
    80001618:	6b42                	ld	s6,16(sp)
    8000161a:	6ba2                	ld	s7,8(sp)
    8000161c:	6161                	addi	sp,sp,80
    8000161e:	8082                	ret
  return 0;
    80001620:	4501                	li	a0,0
}
    80001622:	8082                	ret

0000000080001624 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001624:	1141                	addi	sp,sp,-16
    80001626:	e406                	sd	ra,8(sp)
    80001628:	e022                	sd	s0,0(sp)
    8000162a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000162c:	4601                	li	a2,0
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	97e080e7          	jalr	-1666(ra) # 80000fac <walk>
  if(pte == 0)
    80001636:	c901                	beqz	a0,80001646 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001638:	611c                	ld	a5,0(a0)
    8000163a:	9bbd                	andi	a5,a5,-17
    8000163c:	e11c                	sd	a5,0(a0)
}
    8000163e:	60a2                	ld	ra,8(sp)
    80001640:	6402                	ld	s0,0(sp)
    80001642:	0141                	addi	sp,sp,16
    80001644:	8082                	ret
    panic("uvmclear");
    80001646:	00007517          	auipc	a0,0x7
    8000164a:	b8250513          	addi	a0,a0,-1150 # 800081c8 <digits+0x188>
    8000164e:	fffff097          	auipc	ra,0xfffff
    80001652:	eea080e7          	jalr	-278(ra) # 80000538 <panic>

0000000080001656 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001656:	c6bd                	beqz	a3,800016c4 <copyout+0x6e>
{
    80001658:	715d                	addi	sp,sp,-80
    8000165a:	e486                	sd	ra,72(sp)
    8000165c:	e0a2                	sd	s0,64(sp)
    8000165e:	fc26                	sd	s1,56(sp)
    80001660:	f84a                	sd	s2,48(sp)
    80001662:	f44e                	sd	s3,40(sp)
    80001664:	f052                	sd	s4,32(sp)
    80001666:	ec56                	sd	s5,24(sp)
    80001668:	e85a                	sd	s6,16(sp)
    8000166a:	e45e                	sd	s7,8(sp)
    8000166c:	e062                	sd	s8,0(sp)
    8000166e:	0880                	addi	s0,sp,80
    80001670:	8b2a                	mv	s6,a0
    80001672:	8c2e                	mv	s8,a1
    80001674:	8a32                	mv	s4,a2
    80001676:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001678:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000167a:	6a85                	lui	s5,0x1
    8000167c:	a015                	j	800016a0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000167e:	9562                	add	a0,a0,s8
    80001680:	0004861b          	sext.w	a2,s1
    80001684:	85d2                	mv	a1,s4
    80001686:	41250533          	sub	a0,a0,s2
    8000168a:	fffff097          	auipc	ra,0xfffff
    8000168e:	69e080e7          	jalr	1694(ra) # 80000d28 <memmove>

    len -= n;
    80001692:	409989b3          	sub	s3,s3,s1
    src += n;
    80001696:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001698:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000169c:	02098263          	beqz	s3,800016c0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016a0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016a4:	85ca                	mv	a1,s2
    800016a6:	855a                	mv	a0,s6
    800016a8:	00000097          	auipc	ra,0x0
    800016ac:	9aa080e7          	jalr	-1622(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    800016b0:	cd01                	beqz	a0,800016c8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016b2:	418904b3          	sub	s1,s2,s8
    800016b6:	94d6                	add	s1,s1,s5
    if(n > len)
    800016b8:	fc99f3e3          	bgeu	s3,s1,8000167e <copyout+0x28>
    800016bc:	84ce                	mv	s1,s3
    800016be:	b7c1                	j	8000167e <copyout+0x28>
  }
  return 0;
    800016c0:	4501                	li	a0,0
    800016c2:	a021                	j	800016ca <copyout+0x74>
    800016c4:	4501                	li	a0,0
}
    800016c6:	8082                	ret
      return -1;
    800016c8:	557d                	li	a0,-1
}
    800016ca:	60a6                	ld	ra,72(sp)
    800016cc:	6406                	ld	s0,64(sp)
    800016ce:	74e2                	ld	s1,56(sp)
    800016d0:	7942                	ld	s2,48(sp)
    800016d2:	79a2                	ld	s3,40(sp)
    800016d4:	7a02                	ld	s4,32(sp)
    800016d6:	6ae2                	ld	s5,24(sp)
    800016d8:	6b42                	ld	s6,16(sp)
    800016da:	6ba2                	ld	s7,8(sp)
    800016dc:	6c02                	ld	s8,0(sp)
    800016de:	6161                	addi	sp,sp,80
    800016e0:	8082                	ret

00000000800016e2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	caa5                	beqz	a3,80001752 <copyin+0x70>
{
    800016e4:	715d                	addi	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	addi	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8a2e                	mv	s4,a1
    80001700:	8c32                	mv	s8,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a01d                	j	8000172e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000170a:	018505b3          	add	a1,a0,s8
    8000170e:	0004861b          	sext.w	a2,s1
    80001712:	412585b3          	sub	a1,a1,s2
    80001716:	8552                	mv	a0,s4
    80001718:	fffff097          	auipc	ra,0xfffff
    8000171c:	610080e7          	jalr	1552(ra) # 80000d28 <memmove>

    len -= n;
    80001720:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001724:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001726:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000172a:	02098263          	beqz	s3,8000174e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000172e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001732:	85ca                	mv	a1,s2
    80001734:	855a                	mv	a0,s6
    80001736:	00000097          	auipc	ra,0x0
    8000173a:	91c080e7          	jalr	-1764(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    8000173e:	cd01                	beqz	a0,80001756 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001740:	418904b3          	sub	s1,s2,s8
    80001744:	94d6                	add	s1,s1,s5
    if(n > len)
    80001746:	fc99f2e3          	bgeu	s3,s1,8000170a <copyin+0x28>
    8000174a:	84ce                	mv	s1,s3
    8000174c:	bf7d                	j	8000170a <copyin+0x28>
  }
  return 0;
    8000174e:	4501                	li	a0,0
    80001750:	a021                	j	80001758 <copyin+0x76>
    80001752:	4501                	li	a0,0
}
    80001754:	8082                	ret
      return -1;
    80001756:	557d                	li	a0,-1
}
    80001758:	60a6                	ld	ra,72(sp)
    8000175a:	6406                	ld	s0,64(sp)
    8000175c:	74e2                	ld	s1,56(sp)
    8000175e:	7942                	ld	s2,48(sp)
    80001760:	79a2                	ld	s3,40(sp)
    80001762:	7a02                	ld	s4,32(sp)
    80001764:	6ae2                	ld	s5,24(sp)
    80001766:	6b42                	ld	s6,16(sp)
    80001768:	6ba2                	ld	s7,8(sp)
    8000176a:	6c02                	ld	s8,0(sp)
    8000176c:	6161                	addi	sp,sp,80
    8000176e:	8082                	ret

0000000080001770 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001770:	c6c5                	beqz	a3,80001818 <copyinstr+0xa8>
{
    80001772:	715d                	addi	sp,sp,-80
    80001774:	e486                	sd	ra,72(sp)
    80001776:	e0a2                	sd	s0,64(sp)
    80001778:	fc26                	sd	s1,56(sp)
    8000177a:	f84a                	sd	s2,48(sp)
    8000177c:	f44e                	sd	s3,40(sp)
    8000177e:	f052                	sd	s4,32(sp)
    80001780:	ec56                	sd	s5,24(sp)
    80001782:	e85a                	sd	s6,16(sp)
    80001784:	e45e                	sd	s7,8(sp)
    80001786:	0880                	addi	s0,sp,80
    80001788:	8a2a                	mv	s4,a0
    8000178a:	8b2e                	mv	s6,a1
    8000178c:	8bb2                	mv	s7,a2
    8000178e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001790:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001792:	6985                	lui	s3,0x1
    80001794:	a035                	j	800017c0 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001796:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000179a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000179c:	0017b793          	seqz	a5,a5
    800017a0:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017a4:	60a6                	ld	ra,72(sp)
    800017a6:	6406                	ld	s0,64(sp)
    800017a8:	74e2                	ld	s1,56(sp)
    800017aa:	7942                	ld	s2,48(sp)
    800017ac:	79a2                	ld	s3,40(sp)
    800017ae:	7a02                	ld	s4,32(sp)
    800017b0:	6ae2                	ld	s5,24(sp)
    800017b2:	6b42                	ld	s6,16(sp)
    800017b4:	6ba2                	ld	s7,8(sp)
    800017b6:	6161                	addi	sp,sp,80
    800017b8:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ba:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017be:	c8a9                	beqz	s1,80001810 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017c0:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017c4:	85ca                	mv	a1,s2
    800017c6:	8552                	mv	a0,s4
    800017c8:	00000097          	auipc	ra,0x0
    800017cc:	88a080e7          	jalr	-1910(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    800017d0:	c131                	beqz	a0,80001814 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017d2:	41790833          	sub	a6,s2,s7
    800017d6:	984e                	add	a6,a6,s3
    if(n > max)
    800017d8:	0104f363          	bgeu	s1,a6,800017de <copyinstr+0x6e>
    800017dc:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017de:	955e                	add	a0,a0,s7
    800017e0:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017e4:	fc080be3          	beqz	a6,800017ba <copyinstr+0x4a>
    800017e8:	985a                	add	a6,a6,s6
    800017ea:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017ec:	41650633          	sub	a2,a0,s6
    800017f0:	14fd                	addi	s1,s1,-1
    800017f2:	9b26                	add	s6,s6,s1
    800017f4:	00f60733          	add	a4,a2,a5
    800017f8:	00074703          	lbu	a4,0(a4)
    800017fc:	df49                	beqz	a4,80001796 <copyinstr+0x26>
        *dst = *p;
    800017fe:	00e78023          	sb	a4,0(a5)
      --max;
    80001802:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001806:	0785                	addi	a5,a5,1
    while(n > 0){
    80001808:	ff0796e3          	bne	a5,a6,800017f4 <copyinstr+0x84>
      dst++;
    8000180c:	8b42                	mv	s6,a6
    8000180e:	b775                	j	800017ba <copyinstr+0x4a>
    80001810:	4781                	li	a5,0
    80001812:	b769                	j	8000179c <copyinstr+0x2c>
      return -1;
    80001814:	557d                	li	a0,-1
    80001816:	b779                	j	800017a4 <copyinstr+0x34>
  int got_null = 0;
    80001818:	4781                	li	a5,0
  if(got_null){
    8000181a:	0017b793          	seqz	a5,a5
    8000181e:	40f00533          	neg	a0,a5
}
    80001822:	8082                	ret

0000000080001824 <sys_startlog>:
int timer = 0;
//Number of items in the log
int numLog = 0;
int lastProcessId = 0;

uint64 sys_startlog(void){
    80001824:	1141                	addi	sp,sp,-16
    80001826:	e422                	sd	s0,8(sp)
    80001828:	0800                	addi	s0,sp,16
  //Starts logging every context switch between user processes by the scheduler. The log consists of a fixed size array
  //of struct logentry. Logging continues until the log buffer is full(LOG_SIZE entires). Return 0 on success, -1 on error(logging is started already).
  if(numLog != 0){
    8000182a:	00007517          	auipc	a0,0x7
    8000182e:	0fa52503          	lw	a0,250(a0) # 80008924 <numLog>
    80001832:	00a03533          	snez	a0,a0
    return -1;
  }else{
    numLog = 0;
    return 0;
  }
}
    80001836:	40a00533          	neg	a0,a0
    8000183a:	6422                	ld	s0,8(sp)
    8000183c:	0141                	addi	sp,sp,16
    8000183e:	8082                	ret

0000000080001840 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001840:	7139                	addi	sp,sp,-64
    80001842:	fc06                	sd	ra,56(sp)
    80001844:	f822                	sd	s0,48(sp)
    80001846:	f426                	sd	s1,40(sp)
    80001848:	f04a                	sd	s2,32(sp)
    8000184a:	ec4e                	sd	s3,24(sp)
    8000184c:	e852                	sd	s4,16(sp)
    8000184e:	e456                	sd	s5,8(sp)
    80001850:	e05a                	sd	s6,0(sp)
    80001852:	0080                	addi	s0,sp,64
    80001854:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001856:	00010497          	auipc	s1,0x10
    8000185a:	a8a48493          	addi	s1,s1,-1398 # 800112e0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000185e:	8b26                	mv	s6,s1
    80001860:	00006a97          	auipc	s5,0x6
    80001864:	7a0a8a93          	addi	s5,s5,1952 # 80008000 <etext>
    80001868:	04000937          	lui	s2,0x4000
    8000186c:	197d                	addi	s2,s2,-1
    8000186e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001870:	00015a17          	auipc	s4,0x15
    80001874:	470a0a13          	addi	s4,s4,1136 # 80016ce0 <tickslock>
    char *pa = kalloc();
    80001878:	fffff097          	auipc	ra,0xfffff
    8000187c:	268080e7          	jalr	616(ra) # 80000ae0 <kalloc>
    80001880:	862a                	mv	a2,a0
    if(pa == 0)
    80001882:	c131                	beqz	a0,800018c6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001884:	416485b3          	sub	a1,s1,s6
    80001888:	858d                	srai	a1,a1,0x3
    8000188a:	000ab783          	ld	a5,0(s5)
    8000188e:	02f585b3          	mul	a1,a1,a5
    80001892:	2585                	addiw	a1,a1,1
    80001894:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001898:	4719                	li	a4,6
    8000189a:	6685                	lui	a3,0x1
    8000189c:	40b905b3          	sub	a1,s2,a1
    800018a0:	854e                	mv	a0,s3
    800018a2:	00000097          	auipc	ra,0x0
    800018a6:	892080e7          	jalr	-1902(ra) # 80001134 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018aa:	16848493          	addi	s1,s1,360
    800018ae:	fd4495e3          	bne	s1,s4,80001878 <proc_mapstacks+0x38>
  }
}
    800018b2:	70e2                	ld	ra,56(sp)
    800018b4:	7442                	ld	s0,48(sp)
    800018b6:	74a2                	ld	s1,40(sp)
    800018b8:	7902                	ld	s2,32(sp)
    800018ba:	69e2                	ld	s3,24(sp)
    800018bc:	6a42                	ld	s4,16(sp)
    800018be:	6aa2                	ld	s5,8(sp)
    800018c0:	6b02                	ld	s6,0(sp)
    800018c2:	6121                	addi	sp,sp,64
    800018c4:	8082                	ret
      panic("kalloc");
    800018c6:	00007517          	auipc	a0,0x7
    800018ca:	91250513          	addi	a0,a0,-1774 # 800081d8 <digits+0x198>
    800018ce:	fffff097          	auipc	ra,0xfffff
    800018d2:	c6a080e7          	jalr	-918(ra) # 80000538 <panic>

00000000800018d6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018d6:	7139                	addi	sp,sp,-64
    800018d8:	fc06                	sd	ra,56(sp)
    800018da:	f822                	sd	s0,48(sp)
    800018dc:	f426                	sd	s1,40(sp)
    800018de:	f04a                	sd	s2,32(sp)
    800018e0:	ec4e                	sd	s3,24(sp)
    800018e2:	e852                	sd	s4,16(sp)
    800018e4:	e456                	sd	s5,8(sp)
    800018e6:	e05a                	sd	s6,0(sp)
    800018e8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018ea:	00007597          	auipc	a1,0x7
    800018ee:	8f658593          	addi	a1,a1,-1802 # 800081e0 <digits+0x1a0>
    800018f2:	0000f517          	auipc	a0,0xf
    800018f6:	29e50513          	addi	a0,a0,670 # 80010b90 <pid_lock>
    800018fa:	fffff097          	auipc	ra,0xfffff
    800018fe:	246080e7          	jalr	582(ra) # 80000b40 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001902:	00007597          	auipc	a1,0x7
    80001906:	8e658593          	addi	a1,a1,-1818 # 800081e8 <digits+0x1a8>
    8000190a:	0000f517          	auipc	a0,0xf
    8000190e:	29e50513          	addi	a0,a0,670 # 80010ba8 <wait_lock>
    80001912:	fffff097          	auipc	ra,0xfffff
    80001916:	22e080e7          	jalr	558(ra) # 80000b40 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191a:	00010497          	auipc	s1,0x10
    8000191e:	9c648493          	addi	s1,s1,-1594 # 800112e0 <proc>
      initlock(&p->lock, "proc");
    80001922:	00007b17          	auipc	s6,0x7
    80001926:	8d6b0b13          	addi	s6,s6,-1834 # 800081f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    8000192a:	8aa6                	mv	s5,s1
    8000192c:	00006a17          	auipc	s4,0x6
    80001930:	6d4a0a13          	addi	s4,s4,1748 # 80008000 <etext>
    80001934:	04000937          	lui	s2,0x4000
    80001938:	197d                	addi	s2,s2,-1
    8000193a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193c:	00015997          	auipc	s3,0x15
    80001940:	3a498993          	addi	s3,s3,932 # 80016ce0 <tickslock>
      initlock(&p->lock, "proc");
    80001944:	85da                	mv	a1,s6
    80001946:	8526                	mv	a0,s1
    80001948:	fffff097          	auipc	ra,0xfffff
    8000194c:	1f8080e7          	jalr	504(ra) # 80000b40 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001950:	415487b3          	sub	a5,s1,s5
    80001954:	878d                	srai	a5,a5,0x3
    80001956:	000a3703          	ld	a4,0(s4)
    8000195a:	02e787b3          	mul	a5,a5,a4
    8000195e:	2785                	addiw	a5,a5,1
    80001960:	00d7979b          	slliw	a5,a5,0xd
    80001964:	40f907b3          	sub	a5,s2,a5
    80001968:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000196a:	16848493          	addi	s1,s1,360
    8000196e:	fd349be3          	bne	s1,s3,80001944 <procinit+0x6e>
  }
}
    80001972:	70e2                	ld	ra,56(sp)
    80001974:	7442                	ld	s0,48(sp)
    80001976:	74a2                	ld	s1,40(sp)
    80001978:	7902                	ld	s2,32(sp)
    8000197a:	69e2                	ld	s3,24(sp)
    8000197c:	6a42                	ld	s4,16(sp)
    8000197e:	6aa2                	ld	s5,8(sp)
    80001980:	6b02                	ld	s6,0(sp)
    80001982:	6121                	addi	sp,sp,64
    80001984:	8082                	ret

0000000080001986 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001986:	1141                	addi	sp,sp,-16
    80001988:	e422                	sd	s0,8(sp)
    8000198a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000198c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000198e:	2501                	sext.w	a0,a0
    80001990:	6422                	ld	s0,8(sp)
    80001992:	0141                	addi	sp,sp,16
    80001994:	8082                	ret

0000000080001996 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001996:	1141                	addi	sp,sp,-16
    80001998:	e422                	sd	s0,8(sp)
    8000199a:	0800                	addi	s0,sp,16
    8000199c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000199e:	2781                	sext.w	a5,a5
    800019a0:	079e                	slli	a5,a5,0x7
  return c;
}
    800019a2:	0000f517          	auipc	a0,0xf
    800019a6:	21e50513          	addi	a0,a0,542 # 80010bc0 <cpus>
    800019aa:	953e                	add	a0,a0,a5
    800019ac:	6422                	ld	s0,8(sp)
    800019ae:	0141                	addi	sp,sp,16
    800019b0:	8082                	ret

00000000800019b2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019b2:	1101                	addi	sp,sp,-32
    800019b4:	ec06                	sd	ra,24(sp)
    800019b6:	e822                	sd	s0,16(sp)
    800019b8:	e426                	sd	s1,8(sp)
    800019ba:	1000                	addi	s0,sp,32
  push_off();
    800019bc:	fffff097          	auipc	ra,0xfffff
    800019c0:	1c8080e7          	jalr	456(ra) # 80000b84 <push_off>
    800019c4:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c6:	2781                	sext.w	a5,a5
    800019c8:	079e                	slli	a5,a5,0x7
    800019ca:	0000f717          	auipc	a4,0xf
    800019ce:	1c670713          	addi	a4,a4,454 # 80010b90 <pid_lock>
    800019d2:	97ba                	add	a5,a5,a4
    800019d4:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d6:	fffff097          	auipc	ra,0xfffff
    800019da:	24e080e7          	jalr	590(ra) # 80000c24 <pop_off>
  return p;
}
    800019de:	8526                	mv	a0,s1
    800019e0:	60e2                	ld	ra,24(sp)
    800019e2:	6442                	ld	s0,16(sp)
    800019e4:	64a2                	ld	s1,8(sp)
    800019e6:	6105                	addi	sp,sp,32
    800019e8:	8082                	ret

00000000800019ea <sys_getlog>:
uint64 sys_getlog(void){
    800019ea:	1101                	addi	sp,sp,-32
    800019ec:	ec06                	sd	ra,24(sp)
    800019ee:	e822                	sd	s0,16(sp)
    800019f0:	1000                	addi	s0,sp,32
  argaddr(0, &userlog);
    800019f2:	fe840593          	addi	a1,s0,-24
    800019f6:	4501                	li	a0,0
    800019f8:	00001097          	auipc	ra,0x1
    800019fc:	188080e7          	jalr	392(ra) # 80002b80 <argaddr>
  struct proc *p = myproc();
    80001a00:	00000097          	auipc	ra,0x0
    80001a04:	fb2080e7          	jalr	-78(ra) # 800019b2 <myproc>
  if(copyout (p->pagetable, userlog, (char *) schedlog, sizeof(struct logentry) * LOG_SIZE) < 0){
    80001a08:	32000693          	li	a3,800
    80001a0c:	0000f617          	auipc	a2,0xf
    80001a10:	5b460613          	addi	a2,a2,1460 # 80010fc0 <schedlog>
    80001a14:	fe843583          	ld	a1,-24(s0)
    80001a18:	6928                	ld	a0,80(a0)
    80001a1a:	00000097          	auipc	ra,0x0
    80001a1e:	c3c080e7          	jalr	-964(ra) # 80001656 <copyout>
    80001a22:	00054a63          	bltz	a0,80001a36 <sys_getlog+0x4c>
  return numLog;
    80001a26:	00007517          	auipc	a0,0x7
    80001a2a:	efe52503          	lw	a0,-258(a0) # 80008924 <numLog>
}
    80001a2e:	60e2                	ld	ra,24(sp)
    80001a30:	6442                	ld	s0,16(sp)
    80001a32:	6105                	addi	sp,sp,32
    80001a34:	8082                	ret
    return -1;
    80001a36:	557d                	li	a0,-1
    80001a38:	bfdd                	j	80001a2e <sys_getlog+0x44>

0000000080001a3a <sys_nice>:
int sys_nice(void){
    80001a3a:	1101                	addi	sp,sp,-32
    80001a3c:	ec06                	sd	ra,24(sp)
    80001a3e:	e822                	sd	s0,16(sp)
    80001a40:	1000                	addi	s0,sp,32
  argint(0, &inc);
    80001a42:	fec40593          	addi	a1,s0,-20
    80001a46:	4501                	li	a0,0
    80001a48:	00001097          	auipc	ra,0x1
    80001a4c:	116080e7          	jalr	278(ra) # 80002b5e <argint>
  struct proc *p = myproc();
    80001a50:	00000097          	auipc	ra,0x0
    80001a54:	f62080e7          	jalr	-158(ra) # 800019b2 <myproc>
  if(inc > 19){
    80001a58:	fec42783          	lw	a5,-20(s0)
    80001a5c:	474d                	li	a4,19
    80001a5e:	00f75a63          	bge	a4,a5,80001a72 <sys_nice+0x38>
    p->nice += 19;
    80001a62:	595c                	lw	a5,52(a0)
    80001a64:	27cd                	addiw	a5,a5,19
    80001a66:	d95c                	sw	a5,52(a0)
}
    80001a68:	5948                	lw	a0,52(a0)
    80001a6a:	60e2                	ld	ra,24(sp)
    80001a6c:	6442                	ld	s0,16(sp)
    80001a6e:	6105                	addi	sp,sp,32
    80001a70:	8082                	ret
  }else if(inc < -20){
    80001a72:	5731                	li	a4,-20
    80001a74:	00e7d663          	bge	a5,a4,80001a80 <sys_nice+0x46>
    p->nice += -20;
    80001a78:	595c                	lw	a5,52(a0)
    80001a7a:	37b1                	addiw	a5,a5,-20
    80001a7c:	d95c                	sw	a5,52(a0)
    80001a7e:	b7ed                	j	80001a68 <sys_nice+0x2e>
    p->nice += inc;
    80001a80:	5958                	lw	a4,52(a0)
    80001a82:	9fb9                	addw	a5,a5,a4
    80001a84:	d95c                	sw	a5,52(a0)
    80001a86:	b7cd                	j	80001a68 <sys_nice+0x2e>

0000000080001a88 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a88:	1141                	addi	sp,sp,-16
    80001a8a:	e406                	sd	ra,8(sp)
    80001a8c:	e022                	sd	s0,0(sp)
    80001a8e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a90:	00000097          	auipc	ra,0x0
    80001a94:	f22080e7          	jalr	-222(ra) # 800019b2 <myproc>
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	1ec080e7          	jalr	492(ra) # 80000c84 <release>

  if (first) {
    80001aa0:	00007797          	auipc	a5,0x7
    80001aa4:	de07a783          	lw	a5,-544(a5) # 80008880 <first.1>
    80001aa8:	eb89                	bnez	a5,80001aba <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001aaa:	00001097          	auipc	ra,0x1
    80001aae:	c74080e7          	jalr	-908(ra) # 8000271e <usertrapret>
}
    80001ab2:	60a2                	ld	ra,8(sp)
    80001ab4:	6402                	ld	s0,0(sp)
    80001ab6:	0141                	addi	sp,sp,16
    80001ab8:	8082                	ret
    first = 0;
    80001aba:	00007797          	auipc	a5,0x7
    80001abe:	dc07a323          	sw	zero,-570(a5) # 80008880 <first.1>
    fsinit(ROOTDEV);
    80001ac2:	4505                	li	a0,1
    80001ac4:	00002097          	auipc	ra,0x2
    80001ac8:	9a6080e7          	jalr	-1626(ra) # 8000346a <fsinit>
    80001acc:	bff9                	j	80001aaa <forkret+0x22>

0000000080001ace <allocpid>:
{
    80001ace:	1101                	addi	sp,sp,-32
    80001ad0:	ec06                	sd	ra,24(sp)
    80001ad2:	e822                	sd	s0,16(sp)
    80001ad4:	e426                	sd	s1,8(sp)
    80001ad6:	e04a                	sd	s2,0(sp)
    80001ad8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ada:	0000f917          	auipc	s2,0xf
    80001ade:	0b690913          	addi	s2,s2,182 # 80010b90 <pid_lock>
    80001ae2:	854a                	mv	a0,s2
    80001ae4:	fffff097          	auipc	ra,0xfffff
    80001ae8:	0ec080e7          	jalr	236(ra) # 80000bd0 <acquire>
  pid = nextpid;
    80001aec:	00007797          	auipc	a5,0x7
    80001af0:	d9878793          	addi	a5,a5,-616 # 80008884 <nextpid>
    80001af4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001af6:	0014871b          	addiw	a4,s1,1
    80001afa:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001afc:	854a                	mv	a0,s2
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	186080e7          	jalr	390(ra) # 80000c84 <release>
}
    80001b06:	8526                	mv	a0,s1
    80001b08:	60e2                	ld	ra,24(sp)
    80001b0a:	6442                	ld	s0,16(sp)
    80001b0c:	64a2                	ld	s1,8(sp)
    80001b0e:	6902                	ld	s2,0(sp)
    80001b10:	6105                	addi	sp,sp,32
    80001b12:	8082                	ret

0000000080001b14 <proc_pagetable>:
{
    80001b14:	1101                	addi	sp,sp,-32
    80001b16:	ec06                	sd	ra,24(sp)
    80001b18:	e822                	sd	s0,16(sp)
    80001b1a:	e426                	sd	s1,8(sp)
    80001b1c:	e04a                	sd	s2,0(sp)
    80001b1e:	1000                	addi	s0,sp,32
    80001b20:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	7fc080e7          	jalr	2044(ra) # 8000131e <uvmcreate>
    80001b2a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b2c:	c121                	beqz	a0,80001b6c <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b2e:	4729                	li	a4,10
    80001b30:	00005697          	auipc	a3,0x5
    80001b34:	4d068693          	addi	a3,a3,1232 # 80007000 <_trampoline>
    80001b38:	6605                	lui	a2,0x1
    80001b3a:	040005b7          	lui	a1,0x4000
    80001b3e:	15fd                	addi	a1,a1,-1
    80001b40:	05b2                	slli	a1,a1,0xc
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	552080e7          	jalr	1362(ra) # 80001094 <mappages>
    80001b4a:	02054863          	bltz	a0,80001b7a <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b4e:	4719                	li	a4,6
    80001b50:	05893683          	ld	a3,88(s2)
    80001b54:	6605                	lui	a2,0x1
    80001b56:	020005b7          	lui	a1,0x2000
    80001b5a:	15fd                	addi	a1,a1,-1
    80001b5c:	05b6                	slli	a1,a1,0xd
    80001b5e:	8526                	mv	a0,s1
    80001b60:	fffff097          	auipc	ra,0xfffff
    80001b64:	534080e7          	jalr	1332(ra) # 80001094 <mappages>
    80001b68:	02054163          	bltz	a0,80001b8a <proc_pagetable+0x76>
}
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	60e2                	ld	ra,24(sp)
    80001b70:	6442                	ld	s0,16(sp)
    80001b72:	64a2                	ld	s1,8(sp)
    80001b74:	6902                	ld	s2,0(sp)
    80001b76:	6105                	addi	sp,sp,32
    80001b78:	8082                	ret
    uvmfree(pagetable, 0);
    80001b7a:	4581                	li	a1,0
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	00000097          	auipc	ra,0x0
    80001b82:	99c080e7          	jalr	-1636(ra) # 8000151a <uvmfree>
    return 0;
    80001b86:	4481                	li	s1,0
    80001b88:	b7d5                	j	80001b6c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b8a:	4681                	li	a3,0
    80001b8c:	4605                	li	a2,1
    80001b8e:	040005b7          	lui	a1,0x4000
    80001b92:	15fd                	addi	a1,a1,-1
    80001b94:	05b2                	slli	a1,a1,0xc
    80001b96:	8526                	mv	a0,s1
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	6c2080e7          	jalr	1730(ra) # 8000125a <uvmunmap>
    uvmfree(pagetable, 0);
    80001ba0:	4581                	li	a1,0
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	00000097          	auipc	ra,0x0
    80001ba8:	976080e7          	jalr	-1674(ra) # 8000151a <uvmfree>
    return 0;
    80001bac:	4481                	li	s1,0
    80001bae:	bf7d                	j	80001b6c <proc_pagetable+0x58>

0000000080001bb0 <proc_freepagetable>:
{
    80001bb0:	1101                	addi	sp,sp,-32
    80001bb2:	ec06                	sd	ra,24(sp)
    80001bb4:	e822                	sd	s0,16(sp)
    80001bb6:	e426                	sd	s1,8(sp)
    80001bb8:	e04a                	sd	s2,0(sp)
    80001bba:	1000                	addi	s0,sp,32
    80001bbc:	84aa                	mv	s1,a0
    80001bbe:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bc0:	4681                	li	a3,0
    80001bc2:	4605                	li	a2,1
    80001bc4:	040005b7          	lui	a1,0x4000
    80001bc8:	15fd                	addi	a1,a1,-1
    80001bca:	05b2                	slli	a1,a1,0xc
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	68e080e7          	jalr	1678(ra) # 8000125a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bd4:	4681                	li	a3,0
    80001bd6:	4605                	li	a2,1
    80001bd8:	020005b7          	lui	a1,0x2000
    80001bdc:	15fd                	addi	a1,a1,-1
    80001bde:	05b6                	slli	a1,a1,0xd
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	678080e7          	jalr	1656(ra) # 8000125a <uvmunmap>
  uvmfree(pagetable, sz);
    80001bea:	85ca                	mv	a1,s2
    80001bec:	8526                	mv	a0,s1
    80001bee:	00000097          	auipc	ra,0x0
    80001bf2:	92c080e7          	jalr	-1748(ra) # 8000151a <uvmfree>
}
    80001bf6:	60e2                	ld	ra,24(sp)
    80001bf8:	6442                	ld	s0,16(sp)
    80001bfa:	64a2                	ld	s1,8(sp)
    80001bfc:	6902                	ld	s2,0(sp)
    80001bfe:	6105                	addi	sp,sp,32
    80001c00:	8082                	ret

0000000080001c02 <freeproc>:
{
    80001c02:	1101                	addi	sp,sp,-32
    80001c04:	ec06                	sd	ra,24(sp)
    80001c06:	e822                	sd	s0,16(sp)
    80001c08:	e426                	sd	s1,8(sp)
    80001c0a:	1000                	addi	s0,sp,32
    80001c0c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c0e:	6d28                	ld	a0,88(a0)
    80001c10:	c509                	beqz	a0,80001c1a <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	dd2080e7          	jalr	-558(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001c1a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c1e:	68a8                	ld	a0,80(s1)
    80001c20:	c511                	beqz	a0,80001c2c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c22:	64ac                	ld	a1,72(s1)
    80001c24:	00000097          	auipc	ra,0x0
    80001c28:	f8c080e7          	jalr	-116(ra) # 80001bb0 <proc_freepagetable>
  p->pagetable = 0;
    80001c2c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c30:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c34:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c38:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c3c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c40:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c44:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c48:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c4c:	0004ac23          	sw	zero,24(s1)
  p->nice = 0;
    80001c50:	0204aa23          	sw	zero,52(s1)
}
    80001c54:	60e2                	ld	ra,24(sp)
    80001c56:	6442                	ld	s0,16(sp)
    80001c58:	64a2                	ld	s1,8(sp)
    80001c5a:	6105                	addi	sp,sp,32
    80001c5c:	8082                	ret

0000000080001c5e <allocproc>:
{
    80001c5e:	1101                	addi	sp,sp,-32
    80001c60:	ec06                	sd	ra,24(sp)
    80001c62:	e822                	sd	s0,16(sp)
    80001c64:	e426                	sd	s1,8(sp)
    80001c66:	e04a                	sd	s2,0(sp)
    80001c68:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c6a:	0000f497          	auipc	s1,0xf
    80001c6e:	67648493          	addi	s1,s1,1654 # 800112e0 <proc>
    80001c72:	00015917          	auipc	s2,0x15
    80001c76:	06e90913          	addi	s2,s2,110 # 80016ce0 <tickslock>
    acquire(&p->lock);
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	fffff097          	auipc	ra,0xfffff
    80001c80:	f54080e7          	jalr	-172(ra) # 80000bd0 <acquire>
    if(p->state == UNUSED) {
    80001c84:	4c9c                	lw	a5,24(s1)
    80001c86:	cf81                	beqz	a5,80001c9e <allocproc+0x40>
      release(&p->lock);
    80001c88:	8526                	mv	a0,s1
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	ffa080e7          	jalr	-6(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c92:	16848493          	addi	s1,s1,360
    80001c96:	ff2492e3          	bne	s1,s2,80001c7a <allocproc+0x1c>
  return 0;
    80001c9a:	4481                	li	s1,0
    80001c9c:	a889                	j	80001cee <allocproc+0x90>
  p->pid = allocpid();
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	e30080e7          	jalr	-464(ra) # 80001ace <allocpid>
    80001ca6:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ca8:	4785                	li	a5,1
    80001caa:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	e34080e7          	jalr	-460(ra) # 80000ae0 <kalloc>
    80001cb4:	892a                	mv	s2,a0
    80001cb6:	eca8                	sd	a0,88(s1)
    80001cb8:	c131                	beqz	a0,80001cfc <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001cba:	8526                	mv	a0,s1
    80001cbc:	00000097          	auipc	ra,0x0
    80001cc0:	e58080e7          	jalr	-424(ra) # 80001b14 <proc_pagetable>
    80001cc4:	892a                	mv	s2,a0
    80001cc6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cc8:	c531                	beqz	a0,80001d14 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001cca:	07000613          	li	a2,112
    80001cce:	4581                	li	a1,0
    80001cd0:	06048513          	addi	a0,s1,96
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	ff8080e7          	jalr	-8(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001cdc:	00000797          	auipc	a5,0x0
    80001ce0:	dac78793          	addi	a5,a5,-596 # 80001a88 <forkret>
    80001ce4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ce6:	60bc                	ld	a5,64(s1)
    80001ce8:	6705                	lui	a4,0x1
    80001cea:	97ba                	add	a5,a5,a4
    80001cec:	f4bc                	sd	a5,104(s1)
}
    80001cee:	8526                	mv	a0,s1
    80001cf0:	60e2                	ld	ra,24(sp)
    80001cf2:	6442                	ld	s0,16(sp)
    80001cf4:	64a2                	ld	s1,8(sp)
    80001cf6:	6902                	ld	s2,0(sp)
    80001cf8:	6105                	addi	sp,sp,32
    80001cfa:	8082                	ret
    freeproc(p);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	00000097          	auipc	ra,0x0
    80001d02:	f04080e7          	jalr	-252(ra) # 80001c02 <freeproc>
    release(&p->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	f7c080e7          	jalr	-132(ra) # 80000c84 <release>
    return 0;
    80001d10:	84ca                	mv	s1,s2
    80001d12:	bff1                	j	80001cee <allocproc+0x90>
    freeproc(p);
    80001d14:	8526                	mv	a0,s1
    80001d16:	00000097          	auipc	ra,0x0
    80001d1a:	eec080e7          	jalr	-276(ra) # 80001c02 <freeproc>
    release(&p->lock);
    80001d1e:	8526                	mv	a0,s1
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	f64080e7          	jalr	-156(ra) # 80000c84 <release>
    return 0;
    80001d28:	84ca                	mv	s1,s2
    80001d2a:	b7d1                	j	80001cee <allocproc+0x90>

0000000080001d2c <userinit>:
{
    80001d2c:	1101                	addi	sp,sp,-32
    80001d2e:	ec06                	sd	ra,24(sp)
    80001d30:	e822                	sd	s0,16(sp)
    80001d32:	e426                	sd	s1,8(sp)
    80001d34:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d36:	00000097          	auipc	ra,0x0
    80001d3a:	f28080e7          	jalr	-216(ra) # 80001c5e <allocproc>
    80001d3e:	84aa                	mv	s1,a0
  initproc = p;
    80001d40:	00007797          	auipc	a5,0x7
    80001d44:	bca7bc23          	sd	a0,-1064(a5) # 80008918 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d48:	03400613          	li	a2,52
    80001d4c:	00007597          	auipc	a1,0x7
    80001d50:	b4458593          	addi	a1,a1,-1212 # 80008890 <initcode>
    80001d54:	6928                	ld	a0,80(a0)
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	5f6080e7          	jalr	1526(ra) # 8000134c <uvmfirst>
  p->sz = PGSIZE;
    80001d5e:	6785                	lui	a5,0x1
    80001d60:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d62:	6cb8                	ld	a4,88(s1)
    80001d64:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d68:	6cb8                	ld	a4,88(s1)
    80001d6a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d6c:	4641                	li	a2,16
    80001d6e:	00006597          	auipc	a1,0x6
    80001d72:	49258593          	addi	a1,a1,1170 # 80008200 <digits+0x1c0>
    80001d76:	15848513          	addi	a0,s1,344
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	09c080e7          	jalr	156(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001d82:	00006517          	auipc	a0,0x6
    80001d86:	48e50513          	addi	a0,a0,1166 # 80008210 <digits+0x1d0>
    80001d8a:	00002097          	auipc	ra,0x2
    80001d8e:	10e080e7          	jalr	270(ra) # 80003e98 <namei>
    80001d92:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d96:	478d                	li	a5,3
    80001d98:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d9a:	8526                	mv	a0,s1
    80001d9c:	fffff097          	auipc	ra,0xfffff
    80001da0:	ee8080e7          	jalr	-280(ra) # 80000c84 <release>
}
    80001da4:	60e2                	ld	ra,24(sp)
    80001da6:	6442                	ld	s0,16(sp)
    80001da8:	64a2                	ld	s1,8(sp)
    80001daa:	6105                	addi	sp,sp,32
    80001dac:	8082                	ret

0000000080001dae <growproc>:
{
    80001dae:	1101                	addi	sp,sp,-32
    80001db0:	ec06                	sd	ra,24(sp)
    80001db2:	e822                	sd	s0,16(sp)
    80001db4:	e426                	sd	s1,8(sp)
    80001db6:	e04a                	sd	s2,0(sp)
    80001db8:	1000                	addi	s0,sp,32
    80001dba:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	bf6080e7          	jalr	-1034(ra) # 800019b2 <myproc>
    80001dc4:	892a                	mv	s2,a0
  sz = p->sz;
    80001dc6:	652c                	ld	a1,72(a0)
    80001dc8:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001dcc:	00904f63          	bgtz	s1,80001dea <growproc+0x3c>
  } else if(n < 0){
    80001dd0:	0204cc63          	bltz	s1,80001e08 <growproc+0x5a>
  p->sz = sz;
    80001dd4:	1602                	slli	a2,a2,0x20
    80001dd6:	9201                	srli	a2,a2,0x20
    80001dd8:	04c93423          	sd	a2,72(s2)
  return 0;
    80001ddc:	4501                	li	a0,0
}
    80001dde:	60e2                	ld	ra,24(sp)
    80001de0:	6442                	ld	s0,16(sp)
    80001de2:	64a2                	ld	s1,8(sp)
    80001de4:	6902                	ld	s2,0(sp)
    80001de6:	6105                	addi	sp,sp,32
    80001de8:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dea:	9e25                	addw	a2,a2,s1
    80001dec:	1602                	slli	a2,a2,0x20
    80001dee:	9201                	srli	a2,a2,0x20
    80001df0:	1582                	slli	a1,a1,0x20
    80001df2:	9181                	srli	a1,a1,0x20
    80001df4:	6928                	ld	a0,80(a0)
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	610080e7          	jalr	1552(ra) # 80001406 <uvmalloc>
    80001dfe:	0005061b          	sext.w	a2,a0
    80001e02:	fa69                	bnez	a2,80001dd4 <growproc+0x26>
      return -1;
    80001e04:	557d                	li	a0,-1
    80001e06:	bfe1                	j	80001dde <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e08:	9e25                	addw	a2,a2,s1
    80001e0a:	1602                	slli	a2,a2,0x20
    80001e0c:	9201                	srli	a2,a2,0x20
    80001e0e:	1582                	slli	a1,a1,0x20
    80001e10:	9181                	srli	a1,a1,0x20
    80001e12:	6928                	ld	a0,80(a0)
    80001e14:	fffff097          	auipc	ra,0xfffff
    80001e18:	5aa080e7          	jalr	1450(ra) # 800013be <uvmdealloc>
    80001e1c:	0005061b          	sext.w	a2,a0
    80001e20:	bf55                	j	80001dd4 <growproc+0x26>

0000000080001e22 <fork>:
{
    80001e22:	7139                	addi	sp,sp,-64
    80001e24:	fc06                	sd	ra,56(sp)
    80001e26:	f822                	sd	s0,48(sp)
    80001e28:	f426                	sd	s1,40(sp)
    80001e2a:	f04a                	sd	s2,32(sp)
    80001e2c:	ec4e                	sd	s3,24(sp)
    80001e2e:	e852                	sd	s4,16(sp)
    80001e30:	e456                	sd	s5,8(sp)
    80001e32:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e34:	00000097          	auipc	ra,0x0
    80001e38:	b7e080e7          	jalr	-1154(ra) # 800019b2 <myproc>
    80001e3c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e3e:	00000097          	auipc	ra,0x0
    80001e42:	e20080e7          	jalr	-480(ra) # 80001c5e <allocproc>
    80001e46:	10050c63          	beqz	a0,80001f5e <fork+0x13c>
    80001e4a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e4c:	048ab603          	ld	a2,72(s5)
    80001e50:	692c                	ld	a1,80(a0)
    80001e52:	050ab503          	ld	a0,80(s5)
    80001e56:	fffff097          	auipc	ra,0xfffff
    80001e5a:	6fc080e7          	jalr	1788(ra) # 80001552 <uvmcopy>
    80001e5e:	04054863          	bltz	a0,80001eae <fork+0x8c>
  np->sz = p->sz;
    80001e62:	048ab783          	ld	a5,72(s5)
    80001e66:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e6a:	058ab683          	ld	a3,88(s5)
    80001e6e:	87b6                	mv	a5,a3
    80001e70:	058a3703          	ld	a4,88(s4)
    80001e74:	12068693          	addi	a3,a3,288
    80001e78:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e7c:	6788                	ld	a0,8(a5)
    80001e7e:	6b8c                	ld	a1,16(a5)
    80001e80:	6f90                	ld	a2,24(a5)
    80001e82:	01073023          	sd	a6,0(a4)
    80001e86:	e708                	sd	a0,8(a4)
    80001e88:	eb0c                	sd	a1,16(a4)
    80001e8a:	ef10                	sd	a2,24(a4)
    80001e8c:	02078793          	addi	a5,a5,32
    80001e90:	02070713          	addi	a4,a4,32
    80001e94:	fed792e3          	bne	a5,a3,80001e78 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e98:	058a3783          	ld	a5,88(s4)
    80001e9c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ea0:	0d0a8493          	addi	s1,s5,208
    80001ea4:	0d0a0913          	addi	s2,s4,208
    80001ea8:	150a8993          	addi	s3,s5,336
    80001eac:	a00d                	j	80001ece <fork+0xac>
    freeproc(np);
    80001eae:	8552                	mv	a0,s4
    80001eb0:	00000097          	auipc	ra,0x0
    80001eb4:	d52080e7          	jalr	-686(ra) # 80001c02 <freeproc>
    release(&np->lock);
    80001eb8:	8552                	mv	a0,s4
    80001eba:	fffff097          	auipc	ra,0xfffff
    80001ebe:	dca080e7          	jalr	-566(ra) # 80000c84 <release>
    return -1;
    80001ec2:	597d                	li	s2,-1
    80001ec4:	a059                	j	80001f4a <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001ec6:	04a1                	addi	s1,s1,8
    80001ec8:	0921                	addi	s2,s2,8
    80001eca:	01348b63          	beq	s1,s3,80001ee0 <fork+0xbe>
    if(p->ofile[i])
    80001ece:	6088                	ld	a0,0(s1)
    80001ed0:	d97d                	beqz	a0,80001ec6 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ed2:	00002097          	auipc	ra,0x2
    80001ed6:	65c080e7          	jalr	1628(ra) # 8000452e <filedup>
    80001eda:	00a93023          	sd	a0,0(s2)
    80001ede:	b7e5                	j	80001ec6 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ee0:	150ab503          	ld	a0,336(s5)
    80001ee4:	00001097          	auipc	ra,0x1
    80001ee8:	7c0080e7          	jalr	1984(ra) # 800036a4 <idup>
    80001eec:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ef0:	4641                	li	a2,16
    80001ef2:	158a8593          	addi	a1,s5,344
    80001ef6:	158a0513          	addi	a0,s4,344
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	f1c080e7          	jalr	-228(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001f02:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f06:	8552                	mv	a0,s4
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	d7c080e7          	jalr	-644(ra) # 80000c84 <release>
  acquire(&wait_lock);
    80001f10:	0000f497          	auipc	s1,0xf
    80001f14:	c9848493          	addi	s1,s1,-872 # 80010ba8 <wait_lock>
    80001f18:	8526                	mv	a0,s1
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	cb6080e7          	jalr	-842(ra) # 80000bd0 <acquire>
  np->parent = p;
    80001f22:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f26:	8526                	mv	a0,s1
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	d5c080e7          	jalr	-676(ra) # 80000c84 <release>
  acquire(&np->lock);
    80001f30:	8552                	mv	a0,s4
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	c9e080e7          	jalr	-866(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    80001f3a:	478d                	li	a5,3
    80001f3c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f40:	8552                	mv	a0,s4
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	d42080e7          	jalr	-702(ra) # 80000c84 <release>
}
    80001f4a:	854a                	mv	a0,s2
    80001f4c:	70e2                	ld	ra,56(sp)
    80001f4e:	7442                	ld	s0,48(sp)
    80001f50:	74a2                	ld	s1,40(sp)
    80001f52:	7902                	ld	s2,32(sp)
    80001f54:	69e2                	ld	s3,24(sp)
    80001f56:	6a42                	ld	s4,16(sp)
    80001f58:	6aa2                	ld	s5,8(sp)
    80001f5a:	6121                	addi	sp,sp,64
    80001f5c:	8082                	ret
    return -1;
    80001f5e:	597d                	li	s2,-1
    80001f60:	b7ed                	j	80001f4a <fork+0x128>

0000000080001f62 <scheduler>:
{
    80001f62:	711d                	addi	sp,sp,-96
    80001f64:	ec86                	sd	ra,88(sp)
    80001f66:	e8a2                	sd	s0,80(sp)
    80001f68:	e4a6                	sd	s1,72(sp)
    80001f6a:	e0ca                	sd	s2,64(sp)
    80001f6c:	fc4e                	sd	s3,56(sp)
    80001f6e:	f852                	sd	s4,48(sp)
    80001f70:	f456                	sd	s5,40(sp)
    80001f72:	f05a                	sd	s6,32(sp)
    80001f74:	ec5e                	sd	s7,24(sp)
    80001f76:	e862                	sd	s8,16(sp)
    80001f78:	e466                	sd	s9,8(sp)
    80001f7a:	e06a                	sd	s10,0(sp)
    80001f7c:	1080                	addi	s0,sp,96
    80001f7e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f80:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f82:	00779b93          	slli	s7,a5,0x7
    80001f86:	0000f717          	auipc	a4,0xf
    80001f8a:	c0a70713          	addi	a4,a4,-1014 # 80010b90 <pid_lock>
    80001f8e:	975e                	add	a4,a4,s7
    80001f90:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f94:	0000f717          	auipc	a4,0xf
    80001f98:	c3470713          	addi	a4,a4,-972 # 80010bc8 <cpus+0x8>
    80001f9c:	9bba                	add	s7,s7,a4
        c->proc = p;
    80001f9e:	0000fd17          	auipc	s10,0xf
    80001fa2:	bf2d0d13          	addi	s10,s10,-1038 # 80010b90 <pid_lock>
    80001fa6:	079e                	slli	a5,a5,0x7
    80001fa8:	00fd0ab3          	add	s5,s10,a5
        if(numLog < LOG_SIZE && lastProcessId != p->pid){
    80001fac:	00007b17          	auipc	s6,0x7
    80001fb0:	978b0b13          	addi	s6,s6,-1672 # 80008924 <numLog>
    80001fb4:	00007c17          	auipc	s8,0x7
    80001fb8:	96cc0c13          	addi	s8,s8,-1684 # 80008920 <lastProcessId>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fbc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fc0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fc4:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fc8:	0000f497          	auipc	s1,0xf
    80001fcc:	31848493          	addi	s1,s1,792 # 800112e0 <proc>
      if(p->state == RUNNABLE) {
    80001fd0:	4a0d                	li	s4,3
          schedlog[numLog].time = timer;
    80001fd2:	00007c97          	auipc	s9,0x7
    80001fd6:	956c8c93          	addi	s9,s9,-1706 # 80008928 <timer>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fda:	00015997          	auipc	s3,0x15
    80001fde:	d0698993          	addi	s3,s3,-762 # 80016ce0 <tickslock>
    80001fe2:	a01d                	j	80002008 <scheduler+0xa6>
        swtch(&c->context, &p->context);
    80001fe4:	06090593          	addi	a1,s2,96
    80001fe8:	855e                	mv	a0,s7
    80001fea:	00000097          	auipc	ra,0x0
    80001fee:	68a080e7          	jalr	1674(ra) # 80002674 <swtch>
        c->proc = 0;
    80001ff2:	020ab823          	sd	zero,48(s5)
      release(&p->lock);
    80001ff6:	8526                	mv	a0,s1
    80001ff8:	fffff097          	auipc	ra,0xfffff
    80001ffc:	c8c080e7          	jalr	-884(ra) # 80000c84 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002000:	16848493          	addi	s1,s1,360
    80002004:	fb348ce3          	beq	s1,s3,80001fbc <scheduler+0x5a>
      acquire(&p->lock);
    80002008:	8926                	mv	s2,s1
    8000200a:	8526                	mv	a0,s1
    8000200c:	fffff097          	auipc	ra,0xfffff
    80002010:	bc4080e7          	jalr	-1084(ra) # 80000bd0 <acquire>
      if(p->state == RUNNABLE) {
    80002014:	4c9c                	lw	a5,24(s1)
    80002016:	ff4790e3          	bne	a5,s4,80001ff6 <scheduler+0x94>
        p->state = RUNNING;
    8000201a:	4791                	li	a5,4
    8000201c:	cc9c                	sw	a5,24(s1)
        c->proc = p;
    8000201e:	029ab823          	sd	s1,48(s5)
        if(numLog < LOG_SIZE && lastProcessId != p->pid){
    80002022:	000b2783          	lw	a5,0(s6)
    80002026:	06300713          	li	a4,99
    8000202a:	faf74de3          	blt	a4,a5,80001fe4 <scheduler+0x82>
    8000202e:	5898                	lw	a4,48(s1)
    80002030:	000c2683          	lw	a3,0(s8)
    80002034:	fae688e3          	beq	a3,a4,80001fe4 <scheduler+0x82>
          schedlog[numLog].pid = p->pid;
    80002038:	00379693          	slli	a3,a5,0x3
    8000203c:	96ea                	add	a3,a3,s10
    8000203e:	42e6a823          	sw	a4,1072(a3)
          lastProcessId = p->pid;
    80002042:	00ec2023          	sw	a4,0(s8)
          schedlog[numLog].time = timer;
    80002046:	000ca703          	lw	a4,0(s9)
    8000204a:	42e6aa23          	sw	a4,1076(a3)
          numLog++;
    8000204e:	2785                	addiw	a5,a5,1
    80002050:	00fb2023          	sw	a5,0(s6)
    80002054:	bf41                	j	80001fe4 <scheduler+0x82>

0000000080002056 <sched>:
{
    80002056:	7179                	addi	sp,sp,-48
    80002058:	f406                	sd	ra,40(sp)
    8000205a:	f022                	sd	s0,32(sp)
    8000205c:	ec26                	sd	s1,24(sp)
    8000205e:	e84a                	sd	s2,16(sp)
    80002060:	e44e                	sd	s3,8(sp)
    80002062:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002064:	00000097          	auipc	ra,0x0
    80002068:	94e080e7          	jalr	-1714(ra) # 800019b2 <myproc>
    8000206c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000206e:	fffff097          	auipc	ra,0xfffff
    80002072:	ae8080e7          	jalr	-1304(ra) # 80000b56 <holding>
    80002076:	c93d                	beqz	a0,800020ec <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002078:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000207a:	2781                	sext.w	a5,a5
    8000207c:	079e                	slli	a5,a5,0x7
    8000207e:	0000f717          	auipc	a4,0xf
    80002082:	b1270713          	addi	a4,a4,-1262 # 80010b90 <pid_lock>
    80002086:	97ba                	add	a5,a5,a4
    80002088:	0a87a703          	lw	a4,168(a5)
    8000208c:	4785                	li	a5,1
    8000208e:	06f71763          	bne	a4,a5,800020fc <sched+0xa6>
  if(p->state == RUNNING)
    80002092:	4c98                	lw	a4,24(s1)
    80002094:	4791                	li	a5,4
    80002096:	06f70b63          	beq	a4,a5,8000210c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000209a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000209e:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020a0:	efb5                	bnez	a5,8000211c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020a2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020a4:	0000f917          	auipc	s2,0xf
    800020a8:	aec90913          	addi	s2,s2,-1300 # 80010b90 <pid_lock>
    800020ac:	2781                	sext.w	a5,a5
    800020ae:	079e                	slli	a5,a5,0x7
    800020b0:	97ca                	add	a5,a5,s2
    800020b2:	0ac7a983          	lw	s3,172(a5)
    800020b6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020b8:	2781                	sext.w	a5,a5
    800020ba:	079e                	slli	a5,a5,0x7
    800020bc:	0000f597          	auipc	a1,0xf
    800020c0:	b0c58593          	addi	a1,a1,-1268 # 80010bc8 <cpus+0x8>
    800020c4:	95be                	add	a1,a1,a5
    800020c6:	06048513          	addi	a0,s1,96
    800020ca:	00000097          	auipc	ra,0x0
    800020ce:	5aa080e7          	jalr	1450(ra) # 80002674 <swtch>
    800020d2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020d4:	2781                	sext.w	a5,a5
    800020d6:	079e                	slli	a5,a5,0x7
    800020d8:	97ca                	add	a5,a5,s2
    800020da:	0b37a623          	sw	s3,172(a5)
}
    800020de:	70a2                	ld	ra,40(sp)
    800020e0:	7402                	ld	s0,32(sp)
    800020e2:	64e2                	ld	s1,24(sp)
    800020e4:	6942                	ld	s2,16(sp)
    800020e6:	69a2                	ld	s3,8(sp)
    800020e8:	6145                	addi	sp,sp,48
    800020ea:	8082                	ret
    panic("sched p->lock");
    800020ec:	00006517          	auipc	a0,0x6
    800020f0:	12c50513          	addi	a0,a0,300 # 80008218 <digits+0x1d8>
    800020f4:	ffffe097          	auipc	ra,0xffffe
    800020f8:	444080e7          	jalr	1092(ra) # 80000538 <panic>
    panic("sched locks");
    800020fc:	00006517          	auipc	a0,0x6
    80002100:	12c50513          	addi	a0,a0,300 # 80008228 <digits+0x1e8>
    80002104:	ffffe097          	auipc	ra,0xffffe
    80002108:	434080e7          	jalr	1076(ra) # 80000538 <panic>
    panic("sched running");
    8000210c:	00006517          	auipc	a0,0x6
    80002110:	12c50513          	addi	a0,a0,300 # 80008238 <digits+0x1f8>
    80002114:	ffffe097          	auipc	ra,0xffffe
    80002118:	424080e7          	jalr	1060(ra) # 80000538 <panic>
    panic("sched interruptible");
    8000211c:	00006517          	auipc	a0,0x6
    80002120:	12c50513          	addi	a0,a0,300 # 80008248 <digits+0x208>
    80002124:	ffffe097          	auipc	ra,0xffffe
    80002128:	414080e7          	jalr	1044(ra) # 80000538 <panic>

000000008000212c <yield>:
{
    8000212c:	1101                	addi	sp,sp,-32
    8000212e:	ec06                	sd	ra,24(sp)
    80002130:	e822                	sd	s0,16(sp)
    80002132:	e426                	sd	s1,8(sp)
    80002134:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002136:	00000097          	auipc	ra,0x0
    8000213a:	87c080e7          	jalr	-1924(ra) # 800019b2 <myproc>
    8000213e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	a90080e7          	jalr	-1392(ra) # 80000bd0 <acquire>
  p->state = RUNNABLE;
    80002148:	478d                	li	a5,3
    8000214a:	cc9c                	sw	a5,24(s1)
  sched();
    8000214c:	00000097          	auipc	ra,0x0
    80002150:	f0a080e7          	jalr	-246(ra) # 80002056 <sched>
  release(&p->lock);
    80002154:	8526                	mv	a0,s1
    80002156:	fffff097          	auipc	ra,0xfffff
    8000215a:	b2e080e7          	jalr	-1234(ra) # 80000c84 <release>
  timer++;
    8000215e:	00006717          	auipc	a4,0x6
    80002162:	7ca70713          	addi	a4,a4,1994 # 80008928 <timer>
    80002166:	431c                	lw	a5,0(a4)
    80002168:	2785                	addiw	a5,a5,1
    8000216a:	c31c                	sw	a5,0(a4)
}
    8000216c:	60e2                	ld	ra,24(sp)
    8000216e:	6442                	ld	s0,16(sp)
    80002170:	64a2                	ld	s1,8(sp)
    80002172:	6105                	addi	sp,sp,32
    80002174:	8082                	ret

0000000080002176 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002176:	7179                	addi	sp,sp,-48
    80002178:	f406                	sd	ra,40(sp)
    8000217a:	f022                	sd	s0,32(sp)
    8000217c:	ec26                	sd	s1,24(sp)
    8000217e:	e84a                	sd	s2,16(sp)
    80002180:	e44e                	sd	s3,8(sp)
    80002182:	1800                	addi	s0,sp,48
    80002184:	89aa                	mv	s3,a0
    80002186:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002188:	00000097          	auipc	ra,0x0
    8000218c:	82a080e7          	jalr	-2006(ra) # 800019b2 <myproc>
    80002190:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	a3e080e7          	jalr	-1474(ra) # 80000bd0 <acquire>
  release(lk);
    8000219a:	854a                	mv	a0,s2
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	ae8080e7          	jalr	-1304(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    800021a4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021a8:	4789                	li	a5,2
    800021aa:	cc9c                	sw	a5,24(s1)

  sched();
    800021ac:	00000097          	auipc	ra,0x0
    800021b0:	eaa080e7          	jalr	-342(ra) # 80002056 <sched>

  // Tidy up.
  p->chan = 0;
    800021b4:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021b8:	8526                	mv	a0,s1
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	aca080e7          	jalr	-1334(ra) # 80000c84 <release>
  acquire(lk);
    800021c2:	854a                	mv	a0,s2
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	a0c080e7          	jalr	-1524(ra) # 80000bd0 <acquire>
}
    800021cc:	70a2                	ld	ra,40(sp)
    800021ce:	7402                	ld	s0,32(sp)
    800021d0:	64e2                	ld	s1,24(sp)
    800021d2:	6942                	ld	s2,16(sp)
    800021d4:	69a2                	ld	s3,8(sp)
    800021d6:	6145                	addi	sp,sp,48
    800021d8:	8082                	ret

00000000800021da <wait>:
{
    800021da:	715d                	addi	sp,sp,-80
    800021dc:	e486                	sd	ra,72(sp)
    800021de:	e0a2                	sd	s0,64(sp)
    800021e0:	fc26                	sd	s1,56(sp)
    800021e2:	f84a                	sd	s2,48(sp)
    800021e4:	f44e                	sd	s3,40(sp)
    800021e6:	f052                	sd	s4,32(sp)
    800021e8:	ec56                	sd	s5,24(sp)
    800021ea:	e85a                	sd	s6,16(sp)
    800021ec:	e45e                	sd	s7,8(sp)
    800021ee:	e062                	sd	s8,0(sp)
    800021f0:	0880                	addi	s0,sp,80
    800021f2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	7be080e7          	jalr	1982(ra) # 800019b2 <myproc>
    800021fc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021fe:	0000f517          	auipc	a0,0xf
    80002202:	9aa50513          	addi	a0,a0,-1622 # 80010ba8 <wait_lock>
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	9ca080e7          	jalr	-1590(ra) # 80000bd0 <acquire>
    havekids = 0;
    8000220e:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002210:	4a15                	li	s4,5
        havekids = 1;
    80002212:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002214:	00015997          	auipc	s3,0x15
    80002218:	acc98993          	addi	s3,s3,-1332 # 80016ce0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000221c:	0000fc17          	auipc	s8,0xf
    80002220:	98cc0c13          	addi	s8,s8,-1652 # 80010ba8 <wait_lock>
    havekids = 0;
    80002224:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002226:	0000f497          	auipc	s1,0xf
    8000222a:	0ba48493          	addi	s1,s1,186 # 800112e0 <proc>
    8000222e:	a0bd                	j	8000229c <wait+0xc2>
          pid = np->pid;
    80002230:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002234:	000b0e63          	beqz	s6,80002250 <wait+0x76>
    80002238:	4691                	li	a3,4
    8000223a:	02c48613          	addi	a2,s1,44
    8000223e:	85da                	mv	a1,s6
    80002240:	05093503          	ld	a0,80(s2)
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	412080e7          	jalr	1042(ra) # 80001656 <copyout>
    8000224c:	02054563          	bltz	a0,80002276 <wait+0x9c>
          freeproc(np);
    80002250:	8526                	mv	a0,s1
    80002252:	00000097          	auipc	ra,0x0
    80002256:	9b0080e7          	jalr	-1616(ra) # 80001c02 <freeproc>
          release(&np->lock);
    8000225a:	8526                	mv	a0,s1
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	a28080e7          	jalr	-1496(ra) # 80000c84 <release>
          release(&wait_lock);
    80002264:	0000f517          	auipc	a0,0xf
    80002268:	94450513          	addi	a0,a0,-1724 # 80010ba8 <wait_lock>
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	a18080e7          	jalr	-1512(ra) # 80000c84 <release>
          return pid;
    80002274:	a09d                	j	800022da <wait+0x100>
            release(&np->lock);
    80002276:	8526                	mv	a0,s1
    80002278:	fffff097          	auipc	ra,0xfffff
    8000227c:	a0c080e7          	jalr	-1524(ra) # 80000c84 <release>
            release(&wait_lock);
    80002280:	0000f517          	auipc	a0,0xf
    80002284:	92850513          	addi	a0,a0,-1752 # 80010ba8 <wait_lock>
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	9fc080e7          	jalr	-1540(ra) # 80000c84 <release>
            return -1;
    80002290:	59fd                	li	s3,-1
    80002292:	a0a1                	j	800022da <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002294:	16848493          	addi	s1,s1,360
    80002298:	03348463          	beq	s1,s3,800022c0 <wait+0xe6>
      if(np->parent == p){
    8000229c:	7c9c                	ld	a5,56(s1)
    8000229e:	ff279be3          	bne	a5,s2,80002294 <wait+0xba>
        acquire(&np->lock);
    800022a2:	8526                	mv	a0,s1
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	92c080e7          	jalr	-1748(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    800022ac:	4c9c                	lw	a5,24(s1)
    800022ae:	f94781e3          	beq	a5,s4,80002230 <wait+0x56>
        release(&np->lock);
    800022b2:	8526                	mv	a0,s1
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	9d0080e7          	jalr	-1584(ra) # 80000c84 <release>
        havekids = 1;
    800022bc:	8756                	mv	a4,s5
    800022be:	bfd9                	j	80002294 <wait+0xba>
    if(!havekids || p->killed){
    800022c0:	c701                	beqz	a4,800022c8 <wait+0xee>
    800022c2:	02892783          	lw	a5,40(s2)
    800022c6:	c79d                	beqz	a5,800022f4 <wait+0x11a>
      release(&wait_lock);
    800022c8:	0000f517          	auipc	a0,0xf
    800022cc:	8e050513          	addi	a0,a0,-1824 # 80010ba8 <wait_lock>
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	9b4080e7          	jalr	-1612(ra) # 80000c84 <release>
      return -1;
    800022d8:	59fd                	li	s3,-1
}
    800022da:	854e                	mv	a0,s3
    800022dc:	60a6                	ld	ra,72(sp)
    800022de:	6406                	ld	s0,64(sp)
    800022e0:	74e2                	ld	s1,56(sp)
    800022e2:	7942                	ld	s2,48(sp)
    800022e4:	79a2                	ld	s3,40(sp)
    800022e6:	7a02                	ld	s4,32(sp)
    800022e8:	6ae2                	ld	s5,24(sp)
    800022ea:	6b42                	ld	s6,16(sp)
    800022ec:	6ba2                	ld	s7,8(sp)
    800022ee:	6c02                	ld	s8,0(sp)
    800022f0:	6161                	addi	sp,sp,80
    800022f2:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022f4:	85e2                	mv	a1,s8
    800022f6:	854a                	mv	a0,s2
    800022f8:	00000097          	auipc	ra,0x0
    800022fc:	e7e080e7          	jalr	-386(ra) # 80002176 <sleep>
    havekids = 0;
    80002300:	b715                	j	80002224 <wait+0x4a>

0000000080002302 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002302:	7139                	addi	sp,sp,-64
    80002304:	fc06                	sd	ra,56(sp)
    80002306:	f822                	sd	s0,48(sp)
    80002308:	f426                	sd	s1,40(sp)
    8000230a:	f04a                	sd	s2,32(sp)
    8000230c:	ec4e                	sd	s3,24(sp)
    8000230e:	e852                	sd	s4,16(sp)
    80002310:	e456                	sd	s5,8(sp)
    80002312:	0080                	addi	s0,sp,64
    80002314:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002316:	0000f497          	auipc	s1,0xf
    8000231a:	fca48493          	addi	s1,s1,-54 # 800112e0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000231e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002320:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002322:	00015917          	auipc	s2,0x15
    80002326:	9be90913          	addi	s2,s2,-1602 # 80016ce0 <tickslock>
    8000232a:	a811                	j	8000233e <wakeup+0x3c>
      }
      release(&p->lock);
    8000232c:	8526                	mv	a0,s1
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	956080e7          	jalr	-1706(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002336:	16848493          	addi	s1,s1,360
    8000233a:	03248663          	beq	s1,s2,80002366 <wakeup+0x64>
    if(p != myproc()){
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	674080e7          	jalr	1652(ra) # 800019b2 <myproc>
    80002346:	fea488e3          	beq	s1,a0,80002336 <wakeup+0x34>
      acquire(&p->lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	884080e7          	jalr	-1916(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002354:	4c9c                	lw	a5,24(s1)
    80002356:	fd379be3          	bne	a5,s3,8000232c <wakeup+0x2a>
    8000235a:	709c                	ld	a5,32(s1)
    8000235c:	fd4798e3          	bne	a5,s4,8000232c <wakeup+0x2a>
        p->state = RUNNABLE;
    80002360:	0154ac23          	sw	s5,24(s1)
    80002364:	b7e1                	j	8000232c <wakeup+0x2a>
    }
  }
}
    80002366:	70e2                	ld	ra,56(sp)
    80002368:	7442                	ld	s0,48(sp)
    8000236a:	74a2                	ld	s1,40(sp)
    8000236c:	7902                	ld	s2,32(sp)
    8000236e:	69e2                	ld	s3,24(sp)
    80002370:	6a42                	ld	s4,16(sp)
    80002372:	6aa2                	ld	s5,8(sp)
    80002374:	6121                	addi	sp,sp,64
    80002376:	8082                	ret

0000000080002378 <reparent>:
{
    80002378:	7179                	addi	sp,sp,-48
    8000237a:	f406                	sd	ra,40(sp)
    8000237c:	f022                	sd	s0,32(sp)
    8000237e:	ec26                	sd	s1,24(sp)
    80002380:	e84a                	sd	s2,16(sp)
    80002382:	e44e                	sd	s3,8(sp)
    80002384:	e052                	sd	s4,0(sp)
    80002386:	1800                	addi	s0,sp,48
    80002388:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000238a:	0000f497          	auipc	s1,0xf
    8000238e:	f5648493          	addi	s1,s1,-170 # 800112e0 <proc>
      pp->parent = initproc;
    80002392:	00006a17          	auipc	s4,0x6
    80002396:	586a0a13          	addi	s4,s4,1414 # 80008918 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000239a:	00015997          	auipc	s3,0x15
    8000239e:	94698993          	addi	s3,s3,-1722 # 80016ce0 <tickslock>
    800023a2:	a029                	j	800023ac <reparent+0x34>
    800023a4:	16848493          	addi	s1,s1,360
    800023a8:	01348d63          	beq	s1,s3,800023c2 <reparent+0x4a>
    if(pp->parent == p){
    800023ac:	7c9c                	ld	a5,56(s1)
    800023ae:	ff279be3          	bne	a5,s2,800023a4 <reparent+0x2c>
      pp->parent = initproc;
    800023b2:	000a3503          	ld	a0,0(s4)
    800023b6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800023b8:	00000097          	auipc	ra,0x0
    800023bc:	f4a080e7          	jalr	-182(ra) # 80002302 <wakeup>
    800023c0:	b7d5                	j	800023a4 <reparent+0x2c>
}
    800023c2:	70a2                	ld	ra,40(sp)
    800023c4:	7402                	ld	s0,32(sp)
    800023c6:	64e2                	ld	s1,24(sp)
    800023c8:	6942                	ld	s2,16(sp)
    800023ca:	69a2                	ld	s3,8(sp)
    800023cc:	6a02                	ld	s4,0(sp)
    800023ce:	6145                	addi	sp,sp,48
    800023d0:	8082                	ret

00000000800023d2 <exit>:
{
    800023d2:	7179                	addi	sp,sp,-48
    800023d4:	f406                	sd	ra,40(sp)
    800023d6:	f022                	sd	s0,32(sp)
    800023d8:	ec26                	sd	s1,24(sp)
    800023da:	e84a                	sd	s2,16(sp)
    800023dc:	e44e                	sd	s3,8(sp)
    800023de:	e052                	sd	s4,0(sp)
    800023e0:	1800                	addi	s0,sp,48
    800023e2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	5ce080e7          	jalr	1486(ra) # 800019b2 <myproc>
    800023ec:	89aa                	mv	s3,a0
  if(p == initproc)
    800023ee:	00006797          	auipc	a5,0x6
    800023f2:	52a7b783          	ld	a5,1322(a5) # 80008918 <initproc>
    800023f6:	0d050493          	addi	s1,a0,208
    800023fa:	15050913          	addi	s2,a0,336
    800023fe:	02a79363          	bne	a5,a0,80002424 <exit+0x52>
    panic("init exiting");
    80002402:	00006517          	auipc	a0,0x6
    80002406:	e5e50513          	addi	a0,a0,-418 # 80008260 <digits+0x220>
    8000240a:	ffffe097          	auipc	ra,0xffffe
    8000240e:	12e080e7          	jalr	302(ra) # 80000538 <panic>
      fileclose(f);
    80002412:	00002097          	auipc	ra,0x2
    80002416:	16e080e7          	jalr	366(ra) # 80004580 <fileclose>
      p->ofile[fd] = 0;
    8000241a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000241e:	04a1                	addi	s1,s1,8
    80002420:	01248563          	beq	s1,s2,8000242a <exit+0x58>
    if(p->ofile[fd]){
    80002424:	6088                	ld	a0,0(s1)
    80002426:	f575                	bnez	a0,80002412 <exit+0x40>
    80002428:	bfdd                	j	8000241e <exit+0x4c>
  begin_op();
    8000242a:	00002097          	auipc	ra,0x2
    8000242e:	c8a080e7          	jalr	-886(ra) # 800040b4 <begin_op>
  iput(p->cwd);
    80002432:	1509b503          	ld	a0,336(s3)
    80002436:	00001097          	auipc	ra,0x1
    8000243a:	466080e7          	jalr	1126(ra) # 8000389c <iput>
  end_op();
    8000243e:	00002097          	auipc	ra,0x2
    80002442:	cf6080e7          	jalr	-778(ra) # 80004134 <end_op>
  p->cwd = 0;
    80002446:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000244a:	0000e497          	auipc	s1,0xe
    8000244e:	75e48493          	addi	s1,s1,1886 # 80010ba8 <wait_lock>
    80002452:	8526                	mv	a0,s1
    80002454:	ffffe097          	auipc	ra,0xffffe
    80002458:	77c080e7          	jalr	1916(ra) # 80000bd0 <acquire>
  reparent(p);
    8000245c:	854e                	mv	a0,s3
    8000245e:	00000097          	auipc	ra,0x0
    80002462:	f1a080e7          	jalr	-230(ra) # 80002378 <reparent>
  wakeup(p->parent);
    80002466:	0389b503          	ld	a0,56(s3)
    8000246a:	00000097          	auipc	ra,0x0
    8000246e:	e98080e7          	jalr	-360(ra) # 80002302 <wakeup>
  acquire(&p->lock);
    80002472:	854e                	mv	a0,s3
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	75c080e7          	jalr	1884(ra) # 80000bd0 <acquire>
  p->xstate = status;
    8000247c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002480:	4795                	li	a5,5
    80002482:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002486:	8526                	mv	a0,s1
    80002488:	ffffe097          	auipc	ra,0xffffe
    8000248c:	7fc080e7          	jalr	2044(ra) # 80000c84 <release>
  sched();
    80002490:	00000097          	auipc	ra,0x0
    80002494:	bc6080e7          	jalr	-1082(ra) # 80002056 <sched>
  panic("zombie exit");
    80002498:	00006517          	auipc	a0,0x6
    8000249c:	dd850513          	addi	a0,a0,-552 # 80008270 <digits+0x230>
    800024a0:	ffffe097          	auipc	ra,0xffffe
    800024a4:	098080e7          	jalr	152(ra) # 80000538 <panic>

00000000800024a8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800024a8:	7179                	addi	sp,sp,-48
    800024aa:	f406                	sd	ra,40(sp)
    800024ac:	f022                	sd	s0,32(sp)
    800024ae:	ec26                	sd	s1,24(sp)
    800024b0:	e84a                	sd	s2,16(sp)
    800024b2:	e44e                	sd	s3,8(sp)
    800024b4:	1800                	addi	s0,sp,48
    800024b6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024b8:	0000f497          	auipc	s1,0xf
    800024bc:	e2848493          	addi	s1,s1,-472 # 800112e0 <proc>
    800024c0:	00015997          	auipc	s3,0x15
    800024c4:	82098993          	addi	s3,s3,-2016 # 80016ce0 <tickslock>
    acquire(&p->lock);
    800024c8:	8526                	mv	a0,s1
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	706080e7          	jalr	1798(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    800024d2:	589c                	lw	a5,48(s1)
    800024d4:	01278d63          	beq	a5,s2,800024ee <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024d8:	8526                	mv	a0,s1
    800024da:	ffffe097          	auipc	ra,0xffffe
    800024de:	7aa080e7          	jalr	1962(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024e2:	16848493          	addi	s1,s1,360
    800024e6:	ff3491e3          	bne	s1,s3,800024c8 <kill+0x20>
  }
  return -1;
    800024ea:	557d                	li	a0,-1
    800024ec:	a829                	j	80002506 <kill+0x5e>
      p->killed = 1;
    800024ee:	4785                	li	a5,1
    800024f0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800024f2:	4c98                	lw	a4,24(s1)
    800024f4:	4789                	li	a5,2
    800024f6:	00f70f63          	beq	a4,a5,80002514 <kill+0x6c>
      release(&p->lock);
    800024fa:	8526                	mv	a0,s1
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	788080e7          	jalr	1928(ra) # 80000c84 <release>
      return 0;
    80002504:	4501                	li	a0,0
}
    80002506:	70a2                	ld	ra,40(sp)
    80002508:	7402                	ld	s0,32(sp)
    8000250a:	64e2                	ld	s1,24(sp)
    8000250c:	6942                	ld	s2,16(sp)
    8000250e:	69a2                	ld	s3,8(sp)
    80002510:	6145                	addi	sp,sp,48
    80002512:	8082                	ret
        p->state = RUNNABLE;
    80002514:	478d                	li	a5,3
    80002516:	cc9c                	sw	a5,24(s1)
    80002518:	b7cd                	j	800024fa <kill+0x52>

000000008000251a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000251a:	7179                	addi	sp,sp,-48
    8000251c:	f406                	sd	ra,40(sp)
    8000251e:	f022                	sd	s0,32(sp)
    80002520:	ec26                	sd	s1,24(sp)
    80002522:	e84a                	sd	s2,16(sp)
    80002524:	e44e                	sd	s3,8(sp)
    80002526:	e052                	sd	s4,0(sp)
    80002528:	1800                	addi	s0,sp,48
    8000252a:	84aa                	mv	s1,a0
    8000252c:	892e                	mv	s2,a1
    8000252e:	89b2                	mv	s3,a2
    80002530:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002532:	fffff097          	auipc	ra,0xfffff
    80002536:	480080e7          	jalr	1152(ra) # 800019b2 <myproc>
  if(user_dst){
    8000253a:	c08d                	beqz	s1,8000255c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000253c:	86d2                	mv	a3,s4
    8000253e:	864e                	mv	a2,s3
    80002540:	85ca                	mv	a1,s2
    80002542:	6928                	ld	a0,80(a0)
    80002544:	fffff097          	auipc	ra,0xfffff
    80002548:	112080e7          	jalr	274(ra) # 80001656 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000254c:	70a2                	ld	ra,40(sp)
    8000254e:	7402                	ld	s0,32(sp)
    80002550:	64e2                	ld	s1,24(sp)
    80002552:	6942                	ld	s2,16(sp)
    80002554:	69a2                	ld	s3,8(sp)
    80002556:	6a02                	ld	s4,0(sp)
    80002558:	6145                	addi	sp,sp,48
    8000255a:	8082                	ret
    memmove((char *)dst, src, len);
    8000255c:	000a061b          	sext.w	a2,s4
    80002560:	85ce                	mv	a1,s3
    80002562:	854a                	mv	a0,s2
    80002564:	ffffe097          	auipc	ra,0xffffe
    80002568:	7c4080e7          	jalr	1988(ra) # 80000d28 <memmove>
    return 0;
    8000256c:	8526                	mv	a0,s1
    8000256e:	bff9                	j	8000254c <either_copyout+0x32>

0000000080002570 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002570:	7179                	addi	sp,sp,-48
    80002572:	f406                	sd	ra,40(sp)
    80002574:	f022                	sd	s0,32(sp)
    80002576:	ec26                	sd	s1,24(sp)
    80002578:	e84a                	sd	s2,16(sp)
    8000257a:	e44e                	sd	s3,8(sp)
    8000257c:	e052                	sd	s4,0(sp)
    8000257e:	1800                	addi	s0,sp,48
    80002580:	892a                	mv	s2,a0
    80002582:	84ae                	mv	s1,a1
    80002584:	89b2                	mv	s3,a2
    80002586:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002588:	fffff097          	auipc	ra,0xfffff
    8000258c:	42a080e7          	jalr	1066(ra) # 800019b2 <myproc>
  if(user_src){
    80002590:	c08d                	beqz	s1,800025b2 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002592:	86d2                	mv	a3,s4
    80002594:	864e                	mv	a2,s3
    80002596:	85ca                	mv	a1,s2
    80002598:	6928                	ld	a0,80(a0)
    8000259a:	fffff097          	auipc	ra,0xfffff
    8000259e:	148080e7          	jalr	328(ra) # 800016e2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025a2:	70a2                	ld	ra,40(sp)
    800025a4:	7402                	ld	s0,32(sp)
    800025a6:	64e2                	ld	s1,24(sp)
    800025a8:	6942                	ld	s2,16(sp)
    800025aa:	69a2                	ld	s3,8(sp)
    800025ac:	6a02                	ld	s4,0(sp)
    800025ae:	6145                	addi	sp,sp,48
    800025b0:	8082                	ret
    memmove(dst, (char*)src, len);
    800025b2:	000a061b          	sext.w	a2,s4
    800025b6:	85ce                	mv	a1,s3
    800025b8:	854a                	mv	a0,s2
    800025ba:	ffffe097          	auipc	ra,0xffffe
    800025be:	76e080e7          	jalr	1902(ra) # 80000d28 <memmove>
    return 0;
    800025c2:	8526                	mv	a0,s1
    800025c4:	bff9                	j	800025a2 <either_copyin+0x32>

00000000800025c6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025c6:	715d                	addi	sp,sp,-80
    800025c8:	e486                	sd	ra,72(sp)
    800025ca:	e0a2                	sd	s0,64(sp)
    800025cc:	fc26                	sd	s1,56(sp)
    800025ce:	f84a                	sd	s2,48(sp)
    800025d0:	f44e                	sd	s3,40(sp)
    800025d2:	f052                	sd	s4,32(sp)
    800025d4:	ec56                	sd	s5,24(sp)
    800025d6:	e85a                	sd	s6,16(sp)
    800025d8:	e45e                	sd	s7,8(sp)
    800025da:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025dc:	00006517          	auipc	a0,0x6
    800025e0:	aec50513          	addi	a0,a0,-1300 # 800080c8 <digits+0x88>
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	f9e080e7          	jalr	-98(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ec:	0000f497          	auipc	s1,0xf
    800025f0:	e4c48493          	addi	s1,s1,-436 # 80011438 <proc+0x158>
    800025f4:	00015917          	auipc	s2,0x15
    800025f8:	84490913          	addi	s2,s2,-1980 # 80016e38 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025fc:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025fe:	00006997          	auipc	s3,0x6
    80002602:	c8298993          	addi	s3,s3,-894 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002606:	00006a97          	auipc	s5,0x6
    8000260a:	c82a8a93          	addi	s5,s5,-894 # 80008288 <digits+0x248>
    printf("\n");
    8000260e:	00006a17          	auipc	s4,0x6
    80002612:	abaa0a13          	addi	s4,s4,-1350 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002616:	00006b97          	auipc	s7,0x6
    8000261a:	caab8b93          	addi	s7,s7,-854 # 800082c0 <states.0>
    8000261e:	a00d                	j	80002640 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002620:	ed86a583          	lw	a1,-296(a3)
    80002624:	8556                	mv	a0,s5
    80002626:	ffffe097          	auipc	ra,0xffffe
    8000262a:	f5c080e7          	jalr	-164(ra) # 80000582 <printf>
    printf("\n");
    8000262e:	8552                	mv	a0,s4
    80002630:	ffffe097          	auipc	ra,0xffffe
    80002634:	f52080e7          	jalr	-174(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002638:	16848493          	addi	s1,s1,360
    8000263c:	03248163          	beq	s1,s2,8000265e <procdump+0x98>
    if(p->state == UNUSED)
    80002640:	86a6                	mv	a3,s1
    80002642:	ec04a783          	lw	a5,-320(s1)
    80002646:	dbed                	beqz	a5,80002638 <procdump+0x72>
      state = "???";
    80002648:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000264a:	fcfb6be3          	bltu	s6,a5,80002620 <procdump+0x5a>
    8000264e:	1782                	slli	a5,a5,0x20
    80002650:	9381                	srli	a5,a5,0x20
    80002652:	078e                	slli	a5,a5,0x3
    80002654:	97de                	add	a5,a5,s7
    80002656:	6390                	ld	a2,0(a5)
    80002658:	f661                	bnez	a2,80002620 <procdump+0x5a>
      state = "???";
    8000265a:	864e                	mv	a2,s3
    8000265c:	b7d1                	j	80002620 <procdump+0x5a>
  }
}
    8000265e:	60a6                	ld	ra,72(sp)
    80002660:	6406                	ld	s0,64(sp)
    80002662:	74e2                	ld	s1,56(sp)
    80002664:	7942                	ld	s2,48(sp)
    80002666:	79a2                	ld	s3,40(sp)
    80002668:	7a02                	ld	s4,32(sp)
    8000266a:	6ae2                	ld	s5,24(sp)
    8000266c:	6b42                	ld	s6,16(sp)
    8000266e:	6ba2                	ld	s7,8(sp)
    80002670:	6161                	addi	sp,sp,80
    80002672:	8082                	ret

0000000080002674 <swtch>:
    80002674:	00153023          	sd	ra,0(a0)
    80002678:	00253423          	sd	sp,8(a0)
    8000267c:	e900                	sd	s0,16(a0)
    8000267e:	ed04                	sd	s1,24(a0)
    80002680:	03253023          	sd	s2,32(a0)
    80002684:	03353423          	sd	s3,40(a0)
    80002688:	03453823          	sd	s4,48(a0)
    8000268c:	03553c23          	sd	s5,56(a0)
    80002690:	05653023          	sd	s6,64(a0)
    80002694:	05753423          	sd	s7,72(a0)
    80002698:	05853823          	sd	s8,80(a0)
    8000269c:	05953c23          	sd	s9,88(a0)
    800026a0:	07a53023          	sd	s10,96(a0)
    800026a4:	07b53423          	sd	s11,104(a0)
    800026a8:	0005b083          	ld	ra,0(a1)
    800026ac:	0085b103          	ld	sp,8(a1)
    800026b0:	6980                	ld	s0,16(a1)
    800026b2:	6d84                	ld	s1,24(a1)
    800026b4:	0205b903          	ld	s2,32(a1)
    800026b8:	0285b983          	ld	s3,40(a1)
    800026bc:	0305ba03          	ld	s4,48(a1)
    800026c0:	0385ba83          	ld	s5,56(a1)
    800026c4:	0405bb03          	ld	s6,64(a1)
    800026c8:	0485bb83          	ld	s7,72(a1)
    800026cc:	0505bc03          	ld	s8,80(a1)
    800026d0:	0585bc83          	ld	s9,88(a1)
    800026d4:	0605bd03          	ld	s10,96(a1)
    800026d8:	0685bd83          	ld	s11,104(a1)
    800026dc:	8082                	ret

00000000800026de <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026de:	1141                	addi	sp,sp,-16
    800026e0:	e406                	sd	ra,8(sp)
    800026e2:	e022                	sd	s0,0(sp)
    800026e4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026e6:	00006597          	auipc	a1,0x6
    800026ea:	c0a58593          	addi	a1,a1,-1014 # 800082f0 <states.0+0x30>
    800026ee:	00014517          	auipc	a0,0x14
    800026f2:	5f250513          	addi	a0,a0,1522 # 80016ce0 <tickslock>
    800026f6:	ffffe097          	auipc	ra,0xffffe
    800026fa:	44a080e7          	jalr	1098(ra) # 80000b40 <initlock>
}
    800026fe:	60a2                	ld	ra,8(sp)
    80002700:	6402                	ld	s0,0(sp)
    80002702:	0141                	addi	sp,sp,16
    80002704:	8082                	ret

0000000080002706 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002706:	1141                	addi	sp,sp,-16
    80002708:	e422                	sd	s0,8(sp)
    8000270a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000270c:	00003797          	auipc	a5,0x3
    80002710:	4a478793          	addi	a5,a5,1188 # 80005bb0 <kernelvec>
    80002714:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002718:	6422                	ld	s0,8(sp)
    8000271a:	0141                	addi	sp,sp,16
    8000271c:	8082                	ret

000000008000271e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000271e:	1141                	addi	sp,sp,-16
    80002720:	e406                	sd	ra,8(sp)
    80002722:	e022                	sd	s0,0(sp)
    80002724:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002726:	fffff097          	auipc	ra,0xfffff
    8000272a:	28c080e7          	jalr	652(ra) # 800019b2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000272e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002732:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002734:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002738:	00005617          	auipc	a2,0x5
    8000273c:	8c860613          	addi	a2,a2,-1848 # 80007000 <_trampoline>
    80002740:	00005697          	auipc	a3,0x5
    80002744:	8c068693          	addi	a3,a3,-1856 # 80007000 <_trampoline>
    80002748:	8e91                	sub	a3,a3,a2
    8000274a:	040007b7          	lui	a5,0x4000
    8000274e:	17fd                	addi	a5,a5,-1
    80002750:	07b2                	slli	a5,a5,0xc
    80002752:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002754:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002758:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000275a:	180026f3          	csrr	a3,satp
    8000275e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002760:	6d38                	ld	a4,88(a0)
    80002762:	6134                	ld	a3,64(a0)
    80002764:	6585                	lui	a1,0x1
    80002766:	96ae                	add	a3,a3,a1
    80002768:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000276a:	6d38                	ld	a4,88(a0)
    8000276c:	00000697          	auipc	a3,0x0
    80002770:	13068693          	addi	a3,a3,304 # 8000289c <usertrap>
    80002774:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002776:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002778:	8692                	mv	a3,tp
    8000277a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000277c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002780:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002784:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002788:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000278c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000278e:	6f18                	ld	a4,24(a4)
    80002790:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002794:	6928                	ld	a0,80(a0)
    80002796:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002798:	00005717          	auipc	a4,0x5
    8000279c:	90070713          	addi	a4,a4,-1792 # 80007098 <userret>
    800027a0:	8f11                	sub	a4,a4,a2
    800027a2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800027a4:	577d                	li	a4,-1
    800027a6:	177e                	slli	a4,a4,0x3f
    800027a8:	8d59                	or	a0,a0,a4
    800027aa:	9782                	jalr	a5
}
    800027ac:	60a2                	ld	ra,8(sp)
    800027ae:	6402                	ld	s0,0(sp)
    800027b0:	0141                	addi	sp,sp,16
    800027b2:	8082                	ret

00000000800027b4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027b4:	1101                	addi	sp,sp,-32
    800027b6:	ec06                	sd	ra,24(sp)
    800027b8:	e822                	sd	s0,16(sp)
    800027ba:	e426                	sd	s1,8(sp)
    800027bc:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027be:	00014497          	auipc	s1,0x14
    800027c2:	52248493          	addi	s1,s1,1314 # 80016ce0 <tickslock>
    800027c6:	8526                	mv	a0,s1
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	408080e7          	jalr	1032(ra) # 80000bd0 <acquire>
  ticks++;
    800027d0:	00006517          	auipc	a0,0x6
    800027d4:	15c50513          	addi	a0,a0,348 # 8000892c <ticks>
    800027d8:	411c                	lw	a5,0(a0)
    800027da:	2785                	addiw	a5,a5,1
    800027dc:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027de:	00000097          	auipc	ra,0x0
    800027e2:	b24080e7          	jalr	-1244(ra) # 80002302 <wakeup>
  release(&tickslock);
    800027e6:	8526                	mv	a0,s1
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	49c080e7          	jalr	1180(ra) # 80000c84 <release>
}
    800027f0:	60e2                	ld	ra,24(sp)
    800027f2:	6442                	ld	s0,16(sp)
    800027f4:	64a2                	ld	s1,8(sp)
    800027f6:	6105                	addi	sp,sp,32
    800027f8:	8082                	ret

00000000800027fa <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027fa:	1101                	addi	sp,sp,-32
    800027fc:	ec06                	sd	ra,24(sp)
    800027fe:	e822                	sd	s0,16(sp)
    80002800:	e426                	sd	s1,8(sp)
    80002802:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002804:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002808:	00074d63          	bltz	a4,80002822 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000280c:	57fd                	li	a5,-1
    8000280e:	17fe                	slli	a5,a5,0x3f
    80002810:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002812:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002814:	06f70363          	beq	a4,a5,8000287a <devintr+0x80>
  }
}
    80002818:	60e2                	ld	ra,24(sp)
    8000281a:	6442                	ld	s0,16(sp)
    8000281c:	64a2                	ld	s1,8(sp)
    8000281e:	6105                	addi	sp,sp,32
    80002820:	8082                	ret
     (scause & 0xff) == 9){
    80002822:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002826:	46a5                	li	a3,9
    80002828:	fed792e3          	bne	a5,a3,8000280c <devintr+0x12>
    int irq = plic_claim();
    8000282c:	00003097          	auipc	ra,0x3
    80002830:	48c080e7          	jalr	1164(ra) # 80005cb8 <plic_claim>
    80002834:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002836:	47a9                	li	a5,10
    80002838:	02f50763          	beq	a0,a5,80002866 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000283c:	4785                	li	a5,1
    8000283e:	02f50963          	beq	a0,a5,80002870 <devintr+0x76>
    return 1;
    80002842:	4505                	li	a0,1
    } else if(irq){
    80002844:	d8f1                	beqz	s1,80002818 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002846:	85a6                	mv	a1,s1
    80002848:	00006517          	auipc	a0,0x6
    8000284c:	ab050513          	addi	a0,a0,-1360 # 800082f8 <states.0+0x38>
    80002850:	ffffe097          	auipc	ra,0xffffe
    80002854:	d32080e7          	jalr	-718(ra) # 80000582 <printf>
      plic_complete(irq);
    80002858:	8526                	mv	a0,s1
    8000285a:	00003097          	auipc	ra,0x3
    8000285e:	482080e7          	jalr	1154(ra) # 80005cdc <plic_complete>
    return 1;
    80002862:	4505                	li	a0,1
    80002864:	bf55                	j	80002818 <devintr+0x1e>
      uartintr();
    80002866:	ffffe097          	auipc	ra,0xffffe
    8000286a:	12e080e7          	jalr	302(ra) # 80000994 <uartintr>
    8000286e:	b7ed                	j	80002858 <devintr+0x5e>
      virtio_disk_intr();
    80002870:	00004097          	auipc	ra,0x4
    80002874:	938080e7          	jalr	-1736(ra) # 800061a8 <virtio_disk_intr>
    80002878:	b7c5                	j	80002858 <devintr+0x5e>
    if(cpuid() == 0){
    8000287a:	fffff097          	auipc	ra,0xfffff
    8000287e:	10c080e7          	jalr	268(ra) # 80001986 <cpuid>
    80002882:	c901                	beqz	a0,80002892 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002884:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002888:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000288a:	14479073          	csrw	sip,a5
    return 2;
    8000288e:	4509                	li	a0,2
    80002890:	b761                	j	80002818 <devintr+0x1e>
      clockintr();
    80002892:	00000097          	auipc	ra,0x0
    80002896:	f22080e7          	jalr	-222(ra) # 800027b4 <clockintr>
    8000289a:	b7ed                	j	80002884 <devintr+0x8a>

000000008000289c <usertrap>:
{
    8000289c:	1101                	addi	sp,sp,-32
    8000289e:	ec06                	sd	ra,24(sp)
    800028a0:	e822                	sd	s0,16(sp)
    800028a2:	e426                	sd	s1,8(sp)
    800028a4:	e04a                	sd	s2,0(sp)
    800028a6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028a8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028ac:	1007f793          	andi	a5,a5,256
    800028b0:	e3ad                	bnez	a5,80002912 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028b2:	00003797          	auipc	a5,0x3
    800028b6:	2fe78793          	addi	a5,a5,766 # 80005bb0 <kernelvec>
    800028ba:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028be:	fffff097          	auipc	ra,0xfffff
    800028c2:	0f4080e7          	jalr	244(ra) # 800019b2 <myproc>
    800028c6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028c8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ca:	14102773          	csrr	a4,sepc
    800028ce:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028d4:	47a1                	li	a5,8
    800028d6:	04f71c63          	bne	a4,a5,8000292e <usertrap+0x92>
    if(p->killed)
    800028da:	551c                	lw	a5,40(a0)
    800028dc:	e3b9                	bnez	a5,80002922 <usertrap+0x86>
    p->trapframe->epc += 4;
    800028de:	6cb8                	ld	a4,88(s1)
    800028e0:	6f1c                	ld	a5,24(a4)
    800028e2:	0791                	addi	a5,a5,4
    800028e4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028e6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028ea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028ee:	10079073          	csrw	sstatus,a5
    syscall();
    800028f2:	00000097          	auipc	ra,0x0
    800028f6:	2e0080e7          	jalr	736(ra) # 80002bd2 <syscall>
  if(p->killed)
    800028fa:	549c                	lw	a5,40(s1)
    800028fc:	ebc1                	bnez	a5,8000298c <usertrap+0xf0>
  usertrapret();
    800028fe:	00000097          	auipc	ra,0x0
    80002902:	e20080e7          	jalr	-480(ra) # 8000271e <usertrapret>
}
    80002906:	60e2                	ld	ra,24(sp)
    80002908:	6442                	ld	s0,16(sp)
    8000290a:	64a2                	ld	s1,8(sp)
    8000290c:	6902                	ld	s2,0(sp)
    8000290e:	6105                	addi	sp,sp,32
    80002910:	8082                	ret
    panic("usertrap: not from user mode");
    80002912:	00006517          	auipc	a0,0x6
    80002916:	a0650513          	addi	a0,a0,-1530 # 80008318 <states.0+0x58>
    8000291a:	ffffe097          	auipc	ra,0xffffe
    8000291e:	c1e080e7          	jalr	-994(ra) # 80000538 <panic>
      exit(-1);
    80002922:	557d                	li	a0,-1
    80002924:	00000097          	auipc	ra,0x0
    80002928:	aae080e7          	jalr	-1362(ra) # 800023d2 <exit>
    8000292c:	bf4d                	j	800028de <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    8000292e:	00000097          	auipc	ra,0x0
    80002932:	ecc080e7          	jalr	-308(ra) # 800027fa <devintr>
    80002936:	892a                	mv	s2,a0
    80002938:	c501                	beqz	a0,80002940 <usertrap+0xa4>
  if(p->killed)
    8000293a:	549c                	lw	a5,40(s1)
    8000293c:	c3a1                	beqz	a5,8000297c <usertrap+0xe0>
    8000293e:	a815                	j	80002972 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002940:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002944:	5890                	lw	a2,48(s1)
    80002946:	00006517          	auipc	a0,0x6
    8000294a:	9f250513          	addi	a0,a0,-1550 # 80008338 <states.0+0x78>
    8000294e:	ffffe097          	auipc	ra,0xffffe
    80002952:	c34080e7          	jalr	-972(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002956:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000295a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000295e:	00006517          	auipc	a0,0x6
    80002962:	a0a50513          	addi	a0,a0,-1526 # 80008368 <states.0+0xa8>
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	c1c080e7          	jalr	-996(ra) # 80000582 <printf>
    p->killed = 1;
    8000296e:	4785                	li	a5,1
    80002970:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002972:	557d                	li	a0,-1
    80002974:	00000097          	auipc	ra,0x0
    80002978:	a5e080e7          	jalr	-1442(ra) # 800023d2 <exit>
  if(which_dev == 2)
    8000297c:	4789                	li	a5,2
    8000297e:	f8f910e3          	bne	s2,a5,800028fe <usertrap+0x62>
    yield();
    80002982:	fffff097          	auipc	ra,0xfffff
    80002986:	7aa080e7          	jalr	1962(ra) # 8000212c <yield>
    8000298a:	bf95                	j	800028fe <usertrap+0x62>
  int which_dev = 0;
    8000298c:	4901                	li	s2,0
    8000298e:	b7d5                	j	80002972 <usertrap+0xd6>

0000000080002990 <kerneltrap>:
{
    80002990:	7179                	addi	sp,sp,-48
    80002992:	f406                	sd	ra,40(sp)
    80002994:	f022                	sd	s0,32(sp)
    80002996:	ec26                	sd	s1,24(sp)
    80002998:	e84a                	sd	s2,16(sp)
    8000299a:	e44e                	sd	s3,8(sp)
    8000299c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000299e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029a6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029aa:	1004f793          	andi	a5,s1,256
    800029ae:	cb85                	beqz	a5,800029de <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029b4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029b6:	ef85                	bnez	a5,800029ee <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029b8:	00000097          	auipc	ra,0x0
    800029bc:	e42080e7          	jalr	-446(ra) # 800027fa <devintr>
    800029c0:	cd1d                	beqz	a0,800029fe <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029c2:	4789                	li	a5,2
    800029c4:	06f50a63          	beq	a0,a5,80002a38 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029c8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029cc:	10049073          	csrw	sstatus,s1
}
    800029d0:	70a2                	ld	ra,40(sp)
    800029d2:	7402                	ld	s0,32(sp)
    800029d4:	64e2                	ld	s1,24(sp)
    800029d6:	6942                	ld	s2,16(sp)
    800029d8:	69a2                	ld	s3,8(sp)
    800029da:	6145                	addi	sp,sp,48
    800029dc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029de:	00006517          	auipc	a0,0x6
    800029e2:	9aa50513          	addi	a0,a0,-1622 # 80008388 <states.0+0xc8>
    800029e6:	ffffe097          	auipc	ra,0xffffe
    800029ea:	b52080e7          	jalr	-1198(ra) # 80000538 <panic>
    panic("kerneltrap: interrupts enabled");
    800029ee:	00006517          	auipc	a0,0x6
    800029f2:	9c250513          	addi	a0,a0,-1598 # 800083b0 <states.0+0xf0>
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	b42080e7          	jalr	-1214(ra) # 80000538 <panic>
    printf("scause %p\n", scause);
    800029fe:	85ce                	mv	a1,s3
    80002a00:	00006517          	auipc	a0,0x6
    80002a04:	9d050513          	addi	a0,a0,-1584 # 800083d0 <states.0+0x110>
    80002a08:	ffffe097          	auipc	ra,0xffffe
    80002a0c:	b7a080e7          	jalr	-1158(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a10:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a14:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a18:	00006517          	auipc	a0,0x6
    80002a1c:	9c850513          	addi	a0,a0,-1592 # 800083e0 <states.0+0x120>
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	b62080e7          	jalr	-1182(ra) # 80000582 <printf>
    panic("kerneltrap");
    80002a28:	00006517          	auipc	a0,0x6
    80002a2c:	9d050513          	addi	a0,a0,-1584 # 800083f8 <states.0+0x138>
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	b08080e7          	jalr	-1272(ra) # 80000538 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a38:	fffff097          	auipc	ra,0xfffff
    80002a3c:	f7a080e7          	jalr	-134(ra) # 800019b2 <myproc>
    80002a40:	d541                	beqz	a0,800029c8 <kerneltrap+0x38>
    80002a42:	fffff097          	auipc	ra,0xfffff
    80002a46:	f70080e7          	jalr	-144(ra) # 800019b2 <myproc>
    80002a4a:	4d18                	lw	a4,24(a0)
    80002a4c:	4791                	li	a5,4
    80002a4e:	f6f71de3          	bne	a4,a5,800029c8 <kerneltrap+0x38>
    yield();
    80002a52:	fffff097          	auipc	ra,0xfffff
    80002a56:	6da080e7          	jalr	1754(ra) # 8000212c <yield>
    80002a5a:	b7bd                	j	800029c8 <kerneltrap+0x38>

0000000080002a5c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a5c:	1101                	addi	sp,sp,-32
    80002a5e:	ec06                	sd	ra,24(sp)
    80002a60:	e822                	sd	s0,16(sp)
    80002a62:	e426                	sd	s1,8(sp)
    80002a64:	1000                	addi	s0,sp,32
    80002a66:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a68:	fffff097          	auipc	ra,0xfffff
    80002a6c:	f4a080e7          	jalr	-182(ra) # 800019b2 <myproc>
  switch (n) {
    80002a70:	4795                	li	a5,5
    80002a72:	0497e163          	bltu	a5,s1,80002ab4 <argraw+0x58>
    80002a76:	048a                	slli	s1,s1,0x2
    80002a78:	00006717          	auipc	a4,0x6
    80002a7c:	9b870713          	addi	a4,a4,-1608 # 80008430 <states.0+0x170>
    80002a80:	94ba                	add	s1,s1,a4
    80002a82:	409c                	lw	a5,0(s1)
    80002a84:	97ba                	add	a5,a5,a4
    80002a86:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a88:	6d3c                	ld	a5,88(a0)
    80002a8a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a8c:	60e2                	ld	ra,24(sp)
    80002a8e:	6442                	ld	s0,16(sp)
    80002a90:	64a2                	ld	s1,8(sp)
    80002a92:	6105                	addi	sp,sp,32
    80002a94:	8082                	ret
    return p->trapframe->a1;
    80002a96:	6d3c                	ld	a5,88(a0)
    80002a98:	7fa8                	ld	a0,120(a5)
    80002a9a:	bfcd                	j	80002a8c <argraw+0x30>
    return p->trapframe->a2;
    80002a9c:	6d3c                	ld	a5,88(a0)
    80002a9e:	63c8                	ld	a0,128(a5)
    80002aa0:	b7f5                	j	80002a8c <argraw+0x30>
    return p->trapframe->a3;
    80002aa2:	6d3c                	ld	a5,88(a0)
    80002aa4:	67c8                	ld	a0,136(a5)
    80002aa6:	b7dd                	j	80002a8c <argraw+0x30>
    return p->trapframe->a4;
    80002aa8:	6d3c                	ld	a5,88(a0)
    80002aaa:	6bc8                	ld	a0,144(a5)
    80002aac:	b7c5                	j	80002a8c <argraw+0x30>
    return p->trapframe->a5;
    80002aae:	6d3c                	ld	a5,88(a0)
    80002ab0:	6fc8                	ld	a0,152(a5)
    80002ab2:	bfe9                	j	80002a8c <argraw+0x30>
  panic("argraw");
    80002ab4:	00006517          	auipc	a0,0x6
    80002ab8:	95450513          	addi	a0,a0,-1708 # 80008408 <states.0+0x148>
    80002abc:	ffffe097          	auipc	ra,0xffffe
    80002ac0:	a7c080e7          	jalr	-1412(ra) # 80000538 <panic>

0000000080002ac4 <fetchaddr>:
{
    80002ac4:	1101                	addi	sp,sp,-32
    80002ac6:	ec06                	sd	ra,24(sp)
    80002ac8:	e822                	sd	s0,16(sp)
    80002aca:	e426                	sd	s1,8(sp)
    80002acc:	e04a                	sd	s2,0(sp)
    80002ace:	1000                	addi	s0,sp,32
    80002ad0:	84aa                	mv	s1,a0
    80002ad2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	ede080e7          	jalr	-290(ra) # 800019b2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002adc:	653c                	ld	a5,72(a0)
    80002ade:	02f4f863          	bgeu	s1,a5,80002b0e <fetchaddr+0x4a>
    80002ae2:	00848713          	addi	a4,s1,8
    80002ae6:	02e7e663          	bltu	a5,a4,80002b12 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002aea:	46a1                	li	a3,8
    80002aec:	8626                	mv	a2,s1
    80002aee:	85ca                	mv	a1,s2
    80002af0:	6928                	ld	a0,80(a0)
    80002af2:	fffff097          	auipc	ra,0xfffff
    80002af6:	bf0080e7          	jalr	-1040(ra) # 800016e2 <copyin>
    80002afa:	00a03533          	snez	a0,a0
    80002afe:	40a00533          	neg	a0,a0
}
    80002b02:	60e2                	ld	ra,24(sp)
    80002b04:	6442                	ld	s0,16(sp)
    80002b06:	64a2                	ld	s1,8(sp)
    80002b08:	6902                	ld	s2,0(sp)
    80002b0a:	6105                	addi	sp,sp,32
    80002b0c:	8082                	ret
    return -1;
    80002b0e:	557d                	li	a0,-1
    80002b10:	bfcd                	j	80002b02 <fetchaddr+0x3e>
    80002b12:	557d                	li	a0,-1
    80002b14:	b7fd                	j	80002b02 <fetchaddr+0x3e>

0000000080002b16 <fetchstr>:
{
    80002b16:	7179                	addi	sp,sp,-48
    80002b18:	f406                	sd	ra,40(sp)
    80002b1a:	f022                	sd	s0,32(sp)
    80002b1c:	ec26                	sd	s1,24(sp)
    80002b1e:	e84a                	sd	s2,16(sp)
    80002b20:	e44e                	sd	s3,8(sp)
    80002b22:	1800                	addi	s0,sp,48
    80002b24:	892a                	mv	s2,a0
    80002b26:	84ae                	mv	s1,a1
    80002b28:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b2a:	fffff097          	auipc	ra,0xfffff
    80002b2e:	e88080e7          	jalr	-376(ra) # 800019b2 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b32:	86ce                	mv	a3,s3
    80002b34:	864a                	mv	a2,s2
    80002b36:	85a6                	mv	a1,s1
    80002b38:	6928                	ld	a0,80(a0)
    80002b3a:	fffff097          	auipc	ra,0xfffff
    80002b3e:	c36080e7          	jalr	-970(ra) # 80001770 <copyinstr>
  if(err < 0)
    80002b42:	00054763          	bltz	a0,80002b50 <fetchstr+0x3a>
  return strlen(buf);
    80002b46:	8526                	mv	a0,s1
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	300080e7          	jalr	768(ra) # 80000e48 <strlen>
}
    80002b50:	70a2                	ld	ra,40(sp)
    80002b52:	7402                	ld	s0,32(sp)
    80002b54:	64e2                	ld	s1,24(sp)
    80002b56:	6942                	ld	s2,16(sp)
    80002b58:	69a2                	ld	s3,8(sp)
    80002b5a:	6145                	addi	sp,sp,48
    80002b5c:	8082                	ret

0000000080002b5e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b5e:	1101                	addi	sp,sp,-32
    80002b60:	ec06                	sd	ra,24(sp)
    80002b62:	e822                	sd	s0,16(sp)
    80002b64:	e426                	sd	s1,8(sp)
    80002b66:	1000                	addi	s0,sp,32
    80002b68:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b6a:	00000097          	auipc	ra,0x0
    80002b6e:	ef2080e7          	jalr	-270(ra) # 80002a5c <argraw>
    80002b72:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b74:	4501                	li	a0,0
    80002b76:	60e2                	ld	ra,24(sp)
    80002b78:	6442                	ld	s0,16(sp)
    80002b7a:	64a2                	ld	s1,8(sp)
    80002b7c:	6105                	addi	sp,sp,32
    80002b7e:	8082                	ret

0000000080002b80 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b80:	1101                	addi	sp,sp,-32
    80002b82:	ec06                	sd	ra,24(sp)
    80002b84:	e822                	sd	s0,16(sp)
    80002b86:	e426                	sd	s1,8(sp)
    80002b88:	1000                	addi	s0,sp,32
    80002b8a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	ed0080e7          	jalr	-304(ra) # 80002a5c <argraw>
    80002b94:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b96:	4501                	li	a0,0
    80002b98:	60e2                	ld	ra,24(sp)
    80002b9a:	6442                	ld	s0,16(sp)
    80002b9c:	64a2                	ld	s1,8(sp)
    80002b9e:	6105                	addi	sp,sp,32
    80002ba0:	8082                	ret

0000000080002ba2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ba2:	1101                	addi	sp,sp,-32
    80002ba4:	ec06                	sd	ra,24(sp)
    80002ba6:	e822                	sd	s0,16(sp)
    80002ba8:	e426                	sd	s1,8(sp)
    80002baa:	e04a                	sd	s2,0(sp)
    80002bac:	1000                	addi	s0,sp,32
    80002bae:	84ae                	mv	s1,a1
    80002bb0:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002bb2:	00000097          	auipc	ra,0x0
    80002bb6:	eaa080e7          	jalr	-342(ra) # 80002a5c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002bba:	864a                	mv	a2,s2
    80002bbc:	85a6                	mv	a1,s1
    80002bbe:	00000097          	auipc	ra,0x0
    80002bc2:	f58080e7          	jalr	-168(ra) # 80002b16 <fetchstr>
}
    80002bc6:	60e2                	ld	ra,24(sp)
    80002bc8:	6442                	ld	s0,16(sp)
    80002bca:	64a2                	ld	s1,8(sp)
    80002bcc:	6902                	ld	s2,0(sp)
    80002bce:	6105                	addi	sp,sp,32
    80002bd0:	8082                	ret

0000000080002bd2 <syscall>:
[SYS_nice]    sys_nice,
};

void
syscall(void)
{
    80002bd2:	1101                	addi	sp,sp,-32
    80002bd4:	ec06                	sd	ra,24(sp)
    80002bd6:	e822                	sd	s0,16(sp)
    80002bd8:	e426                	sd	s1,8(sp)
    80002bda:	e04a                	sd	s2,0(sp)
    80002bdc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bde:	fffff097          	auipc	ra,0xfffff
    80002be2:	dd4080e7          	jalr	-556(ra) # 800019b2 <myproc>
    80002be6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002be8:	05853903          	ld	s2,88(a0)
    80002bec:	0a893783          	ld	a5,168(s2)
    80002bf0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bf4:	37fd                	addiw	a5,a5,-1
    80002bf6:	475d                	li	a4,23
    80002bf8:	00f76f63          	bltu	a4,a5,80002c16 <syscall+0x44>
    80002bfc:	00369713          	slli	a4,a3,0x3
    80002c00:	00006797          	auipc	a5,0x6
    80002c04:	84878793          	addi	a5,a5,-1976 # 80008448 <syscalls>
    80002c08:	97ba                	add	a5,a5,a4
    80002c0a:	639c                	ld	a5,0(a5)
    80002c0c:	c789                	beqz	a5,80002c16 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002c0e:	9782                	jalr	a5
    80002c10:	06a93823          	sd	a0,112(s2)
    80002c14:	a839                	j	80002c32 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c16:	15848613          	addi	a2,s1,344
    80002c1a:	588c                	lw	a1,48(s1)
    80002c1c:	00005517          	auipc	a0,0x5
    80002c20:	7f450513          	addi	a0,a0,2036 # 80008410 <states.0+0x150>
    80002c24:	ffffe097          	auipc	ra,0xffffe
    80002c28:	95e080e7          	jalr	-1698(ra) # 80000582 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c2c:	6cbc                	ld	a5,88(s1)
    80002c2e:	577d                	li	a4,-1
    80002c30:	fbb8                	sd	a4,112(a5)
  }
}
    80002c32:	60e2                	ld	ra,24(sp)
    80002c34:	6442                	ld	s0,16(sp)
    80002c36:	64a2                	ld	s1,8(sp)
    80002c38:	6902                	ld	s2,0(sp)
    80002c3a:	6105                	addi	sp,sp,32
    80002c3c:	8082                	ret

0000000080002c3e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c3e:	1101                	addi	sp,sp,-32
    80002c40:	ec06                	sd	ra,24(sp)
    80002c42:	e822                	sd	s0,16(sp)
    80002c44:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c46:	fec40593          	addi	a1,s0,-20
    80002c4a:	4501                	li	a0,0
    80002c4c:	00000097          	auipc	ra,0x0
    80002c50:	f12080e7          	jalr	-238(ra) # 80002b5e <argint>
    return -1;
    80002c54:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c56:	00054963          	bltz	a0,80002c68 <sys_exit+0x2a>
  exit(n);
    80002c5a:	fec42503          	lw	a0,-20(s0)
    80002c5e:	fffff097          	auipc	ra,0xfffff
    80002c62:	774080e7          	jalr	1908(ra) # 800023d2 <exit>
  return 0;  // not reached
    80002c66:	4781                	li	a5,0
}
    80002c68:	853e                	mv	a0,a5
    80002c6a:	60e2                	ld	ra,24(sp)
    80002c6c:	6442                	ld	s0,16(sp)
    80002c6e:	6105                	addi	sp,sp,32
    80002c70:	8082                	ret

0000000080002c72 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c72:	1141                	addi	sp,sp,-16
    80002c74:	e406                	sd	ra,8(sp)
    80002c76:	e022                	sd	s0,0(sp)
    80002c78:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c7a:	fffff097          	auipc	ra,0xfffff
    80002c7e:	d38080e7          	jalr	-712(ra) # 800019b2 <myproc>
}
    80002c82:	5908                	lw	a0,48(a0)
    80002c84:	60a2                	ld	ra,8(sp)
    80002c86:	6402                	ld	s0,0(sp)
    80002c88:	0141                	addi	sp,sp,16
    80002c8a:	8082                	ret

0000000080002c8c <sys_fork>:

uint64
sys_fork(void)
{
    80002c8c:	1141                	addi	sp,sp,-16
    80002c8e:	e406                	sd	ra,8(sp)
    80002c90:	e022                	sd	s0,0(sp)
    80002c92:	0800                	addi	s0,sp,16
  return fork();
    80002c94:	fffff097          	auipc	ra,0xfffff
    80002c98:	18e080e7          	jalr	398(ra) # 80001e22 <fork>
}
    80002c9c:	60a2                	ld	ra,8(sp)
    80002c9e:	6402                	ld	s0,0(sp)
    80002ca0:	0141                	addi	sp,sp,16
    80002ca2:	8082                	ret

0000000080002ca4 <sys_wait>:

uint64
sys_wait(void)
{
    80002ca4:	1101                	addi	sp,sp,-32
    80002ca6:	ec06                	sd	ra,24(sp)
    80002ca8:	e822                	sd	s0,16(sp)
    80002caa:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002cac:	fe840593          	addi	a1,s0,-24
    80002cb0:	4501                	li	a0,0
    80002cb2:	00000097          	auipc	ra,0x0
    80002cb6:	ece080e7          	jalr	-306(ra) # 80002b80 <argaddr>
    80002cba:	87aa                	mv	a5,a0
    return -1;
    80002cbc:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002cbe:	0007c863          	bltz	a5,80002cce <sys_wait+0x2a>
  return wait(p);
    80002cc2:	fe843503          	ld	a0,-24(s0)
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	514080e7          	jalr	1300(ra) # 800021da <wait>
}
    80002cce:	60e2                	ld	ra,24(sp)
    80002cd0:	6442                	ld	s0,16(sp)
    80002cd2:	6105                	addi	sp,sp,32
    80002cd4:	8082                	ret

0000000080002cd6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cd6:	7179                	addi	sp,sp,-48
    80002cd8:	f406                	sd	ra,40(sp)
    80002cda:	f022                	sd	s0,32(sp)
    80002cdc:	ec26                	sd	s1,24(sp)
    80002cde:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002ce0:	fdc40593          	addi	a1,s0,-36
    80002ce4:	4501                	li	a0,0
    80002ce6:	00000097          	auipc	ra,0x0
    80002cea:	e78080e7          	jalr	-392(ra) # 80002b5e <argint>
    return -1;
    80002cee:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002cf0:	00054f63          	bltz	a0,80002d0e <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002cf4:	fffff097          	auipc	ra,0xfffff
    80002cf8:	cbe080e7          	jalr	-834(ra) # 800019b2 <myproc>
    80002cfc:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002cfe:	fdc42503          	lw	a0,-36(s0)
    80002d02:	fffff097          	auipc	ra,0xfffff
    80002d06:	0ac080e7          	jalr	172(ra) # 80001dae <growproc>
    80002d0a:	00054863          	bltz	a0,80002d1a <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002d0e:	8526                	mv	a0,s1
    80002d10:	70a2                	ld	ra,40(sp)
    80002d12:	7402                	ld	s0,32(sp)
    80002d14:	64e2                	ld	s1,24(sp)
    80002d16:	6145                	addi	sp,sp,48
    80002d18:	8082                	ret
    return -1;
    80002d1a:	54fd                	li	s1,-1
    80002d1c:	bfcd                	j	80002d0e <sys_sbrk+0x38>

0000000080002d1e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d1e:	7139                	addi	sp,sp,-64
    80002d20:	fc06                	sd	ra,56(sp)
    80002d22:	f822                	sd	s0,48(sp)
    80002d24:	f426                	sd	s1,40(sp)
    80002d26:	f04a                	sd	s2,32(sp)
    80002d28:	ec4e                	sd	s3,24(sp)
    80002d2a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d2c:	fcc40593          	addi	a1,s0,-52
    80002d30:	4501                	li	a0,0
    80002d32:	00000097          	auipc	ra,0x0
    80002d36:	e2c080e7          	jalr	-468(ra) # 80002b5e <argint>
    return -1;
    80002d3a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d3c:	06054563          	bltz	a0,80002da6 <sys_sleep+0x88>
  acquire(&tickslock);
    80002d40:	00014517          	auipc	a0,0x14
    80002d44:	fa050513          	addi	a0,a0,-96 # 80016ce0 <tickslock>
    80002d48:	ffffe097          	auipc	ra,0xffffe
    80002d4c:	e88080e7          	jalr	-376(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    80002d50:	00006917          	auipc	s2,0x6
    80002d54:	bdc92903          	lw	s2,-1060(s2) # 8000892c <ticks>
  while(ticks - ticks0 < n){
    80002d58:	fcc42783          	lw	a5,-52(s0)
    80002d5c:	cf85                	beqz	a5,80002d94 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d5e:	00014997          	auipc	s3,0x14
    80002d62:	f8298993          	addi	s3,s3,-126 # 80016ce0 <tickslock>
    80002d66:	00006497          	auipc	s1,0x6
    80002d6a:	bc648493          	addi	s1,s1,-1082 # 8000892c <ticks>
    if(myproc()->killed){
    80002d6e:	fffff097          	auipc	ra,0xfffff
    80002d72:	c44080e7          	jalr	-956(ra) # 800019b2 <myproc>
    80002d76:	551c                	lw	a5,40(a0)
    80002d78:	ef9d                	bnez	a5,80002db6 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d7a:	85ce                	mv	a1,s3
    80002d7c:	8526                	mv	a0,s1
    80002d7e:	fffff097          	auipc	ra,0xfffff
    80002d82:	3f8080e7          	jalr	1016(ra) # 80002176 <sleep>
  while(ticks - ticks0 < n){
    80002d86:	409c                	lw	a5,0(s1)
    80002d88:	412787bb          	subw	a5,a5,s2
    80002d8c:	fcc42703          	lw	a4,-52(s0)
    80002d90:	fce7efe3          	bltu	a5,a4,80002d6e <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d94:	00014517          	auipc	a0,0x14
    80002d98:	f4c50513          	addi	a0,a0,-180 # 80016ce0 <tickslock>
    80002d9c:	ffffe097          	auipc	ra,0xffffe
    80002da0:	ee8080e7          	jalr	-280(ra) # 80000c84 <release>
  return 0;
    80002da4:	4781                	li	a5,0
}
    80002da6:	853e                	mv	a0,a5
    80002da8:	70e2                	ld	ra,56(sp)
    80002daa:	7442                	ld	s0,48(sp)
    80002dac:	74a2                	ld	s1,40(sp)
    80002dae:	7902                	ld	s2,32(sp)
    80002db0:	69e2                	ld	s3,24(sp)
    80002db2:	6121                	addi	sp,sp,64
    80002db4:	8082                	ret
      release(&tickslock);
    80002db6:	00014517          	auipc	a0,0x14
    80002dba:	f2a50513          	addi	a0,a0,-214 # 80016ce0 <tickslock>
    80002dbe:	ffffe097          	auipc	ra,0xffffe
    80002dc2:	ec6080e7          	jalr	-314(ra) # 80000c84 <release>
      return -1;
    80002dc6:	57fd                	li	a5,-1
    80002dc8:	bff9                	j	80002da6 <sys_sleep+0x88>

0000000080002dca <sys_kill>:

uint64
sys_kill(void)
{
    80002dca:	1101                	addi	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002dd2:	fec40593          	addi	a1,s0,-20
    80002dd6:	4501                	li	a0,0
    80002dd8:	00000097          	auipc	ra,0x0
    80002ddc:	d86080e7          	jalr	-634(ra) # 80002b5e <argint>
    80002de0:	87aa                	mv	a5,a0
    return -1;
    80002de2:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002de4:	0007c863          	bltz	a5,80002df4 <sys_kill+0x2a>
  return kill(pid);
    80002de8:	fec42503          	lw	a0,-20(s0)
    80002dec:	fffff097          	auipc	ra,0xfffff
    80002df0:	6bc080e7          	jalr	1724(ra) # 800024a8 <kill>
}
    80002df4:	60e2                	ld	ra,24(sp)
    80002df6:	6442                	ld	s0,16(sp)
    80002df8:	6105                	addi	sp,sp,32
    80002dfa:	8082                	ret

0000000080002dfc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dfc:	1101                	addi	sp,sp,-32
    80002dfe:	ec06                	sd	ra,24(sp)
    80002e00:	e822                	sd	s0,16(sp)
    80002e02:	e426                	sd	s1,8(sp)
    80002e04:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e06:	00014517          	auipc	a0,0x14
    80002e0a:	eda50513          	addi	a0,a0,-294 # 80016ce0 <tickslock>
    80002e0e:	ffffe097          	auipc	ra,0xffffe
    80002e12:	dc2080e7          	jalr	-574(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80002e16:	00006497          	auipc	s1,0x6
    80002e1a:	b164a483          	lw	s1,-1258(s1) # 8000892c <ticks>
  release(&tickslock);
    80002e1e:	00014517          	auipc	a0,0x14
    80002e22:	ec250513          	addi	a0,a0,-318 # 80016ce0 <tickslock>
    80002e26:	ffffe097          	auipc	ra,0xffffe
    80002e2a:	e5e080e7          	jalr	-418(ra) # 80000c84 <release>
  return xticks;
}
    80002e2e:	02049513          	slli	a0,s1,0x20
    80002e32:	9101                	srli	a0,a0,0x20
    80002e34:	60e2                	ld	ra,24(sp)
    80002e36:	6442                	ld	s0,16(sp)
    80002e38:	64a2                	ld	s1,8(sp)
    80002e3a:	6105                	addi	sp,sp,32
    80002e3c:	8082                	ret

0000000080002e3e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e3e:	7179                	addi	sp,sp,-48
    80002e40:	f406                	sd	ra,40(sp)
    80002e42:	f022                	sd	s0,32(sp)
    80002e44:	ec26                	sd	s1,24(sp)
    80002e46:	e84a                	sd	s2,16(sp)
    80002e48:	e44e                	sd	s3,8(sp)
    80002e4a:	e052                	sd	s4,0(sp)
    80002e4c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e4e:	00005597          	auipc	a1,0x5
    80002e52:	6c258593          	addi	a1,a1,1730 # 80008510 <syscalls+0xc8>
    80002e56:	00014517          	auipc	a0,0x14
    80002e5a:	ea250513          	addi	a0,a0,-350 # 80016cf8 <bcache>
    80002e5e:	ffffe097          	auipc	ra,0xffffe
    80002e62:	ce2080e7          	jalr	-798(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e66:	0001c797          	auipc	a5,0x1c
    80002e6a:	e9278793          	addi	a5,a5,-366 # 8001ecf8 <bcache+0x8000>
    80002e6e:	0001c717          	auipc	a4,0x1c
    80002e72:	0f270713          	addi	a4,a4,242 # 8001ef60 <bcache+0x8268>
    80002e76:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e7a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e7e:	00014497          	auipc	s1,0x14
    80002e82:	e9248493          	addi	s1,s1,-366 # 80016d10 <bcache+0x18>
    b->next = bcache.head.next;
    80002e86:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e88:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e8a:	00005a17          	auipc	s4,0x5
    80002e8e:	68ea0a13          	addi	s4,s4,1678 # 80008518 <syscalls+0xd0>
    b->next = bcache.head.next;
    80002e92:	2b893783          	ld	a5,696(s2)
    80002e96:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e98:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e9c:	85d2                	mv	a1,s4
    80002e9e:	01048513          	addi	a0,s1,16
    80002ea2:	00001097          	auipc	ra,0x1
    80002ea6:	4d0080e7          	jalr	1232(ra) # 80004372 <initsleeplock>
    bcache.head.next->prev = b;
    80002eaa:	2b893783          	ld	a5,696(s2)
    80002eae:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002eb0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002eb4:	45848493          	addi	s1,s1,1112
    80002eb8:	fd349de3          	bne	s1,s3,80002e92 <binit+0x54>
  }
}
    80002ebc:	70a2                	ld	ra,40(sp)
    80002ebe:	7402                	ld	s0,32(sp)
    80002ec0:	64e2                	ld	s1,24(sp)
    80002ec2:	6942                	ld	s2,16(sp)
    80002ec4:	69a2                	ld	s3,8(sp)
    80002ec6:	6a02                	ld	s4,0(sp)
    80002ec8:	6145                	addi	sp,sp,48
    80002eca:	8082                	ret

0000000080002ecc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ecc:	7179                	addi	sp,sp,-48
    80002ece:	f406                	sd	ra,40(sp)
    80002ed0:	f022                	sd	s0,32(sp)
    80002ed2:	ec26                	sd	s1,24(sp)
    80002ed4:	e84a                	sd	s2,16(sp)
    80002ed6:	e44e                	sd	s3,8(sp)
    80002ed8:	1800                	addi	s0,sp,48
    80002eda:	892a                	mv	s2,a0
    80002edc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ede:	00014517          	auipc	a0,0x14
    80002ee2:	e1a50513          	addi	a0,a0,-486 # 80016cf8 <bcache>
    80002ee6:	ffffe097          	auipc	ra,0xffffe
    80002eea:	cea080e7          	jalr	-790(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002eee:	0001c497          	auipc	s1,0x1c
    80002ef2:	0c24b483          	ld	s1,194(s1) # 8001efb0 <bcache+0x82b8>
    80002ef6:	0001c797          	auipc	a5,0x1c
    80002efa:	06a78793          	addi	a5,a5,106 # 8001ef60 <bcache+0x8268>
    80002efe:	02f48f63          	beq	s1,a5,80002f3c <bread+0x70>
    80002f02:	873e                	mv	a4,a5
    80002f04:	a021                	j	80002f0c <bread+0x40>
    80002f06:	68a4                	ld	s1,80(s1)
    80002f08:	02e48a63          	beq	s1,a4,80002f3c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f0c:	449c                	lw	a5,8(s1)
    80002f0e:	ff279ce3          	bne	a5,s2,80002f06 <bread+0x3a>
    80002f12:	44dc                	lw	a5,12(s1)
    80002f14:	ff3799e3          	bne	a5,s3,80002f06 <bread+0x3a>
      b->refcnt++;
    80002f18:	40bc                	lw	a5,64(s1)
    80002f1a:	2785                	addiw	a5,a5,1
    80002f1c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f1e:	00014517          	auipc	a0,0x14
    80002f22:	dda50513          	addi	a0,a0,-550 # 80016cf8 <bcache>
    80002f26:	ffffe097          	auipc	ra,0xffffe
    80002f2a:	d5e080e7          	jalr	-674(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80002f2e:	01048513          	addi	a0,s1,16
    80002f32:	00001097          	auipc	ra,0x1
    80002f36:	47a080e7          	jalr	1146(ra) # 800043ac <acquiresleep>
      return b;
    80002f3a:	a8b9                	j	80002f98 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f3c:	0001c497          	auipc	s1,0x1c
    80002f40:	06c4b483          	ld	s1,108(s1) # 8001efa8 <bcache+0x82b0>
    80002f44:	0001c797          	auipc	a5,0x1c
    80002f48:	01c78793          	addi	a5,a5,28 # 8001ef60 <bcache+0x8268>
    80002f4c:	00f48863          	beq	s1,a5,80002f5c <bread+0x90>
    80002f50:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f52:	40bc                	lw	a5,64(s1)
    80002f54:	cf81                	beqz	a5,80002f6c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f56:	64a4                	ld	s1,72(s1)
    80002f58:	fee49de3          	bne	s1,a4,80002f52 <bread+0x86>
  panic("bget: no buffers");
    80002f5c:	00005517          	auipc	a0,0x5
    80002f60:	5c450513          	addi	a0,a0,1476 # 80008520 <syscalls+0xd8>
    80002f64:	ffffd097          	auipc	ra,0xffffd
    80002f68:	5d4080e7          	jalr	1492(ra) # 80000538 <panic>
      b->dev = dev;
    80002f6c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f70:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f74:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f78:	4785                	li	a5,1
    80002f7a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f7c:	00014517          	auipc	a0,0x14
    80002f80:	d7c50513          	addi	a0,a0,-644 # 80016cf8 <bcache>
    80002f84:	ffffe097          	auipc	ra,0xffffe
    80002f88:	d00080e7          	jalr	-768(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80002f8c:	01048513          	addi	a0,s1,16
    80002f90:	00001097          	auipc	ra,0x1
    80002f94:	41c080e7          	jalr	1052(ra) # 800043ac <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f98:	409c                	lw	a5,0(s1)
    80002f9a:	cb89                	beqz	a5,80002fac <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f9c:	8526                	mv	a0,s1
    80002f9e:	70a2                	ld	ra,40(sp)
    80002fa0:	7402                	ld	s0,32(sp)
    80002fa2:	64e2                	ld	s1,24(sp)
    80002fa4:	6942                	ld	s2,16(sp)
    80002fa6:	69a2                	ld	s3,8(sp)
    80002fa8:	6145                	addi	sp,sp,48
    80002faa:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fac:	4581                	li	a1,0
    80002fae:	8526                	mv	a0,s1
    80002fb0:	00003097          	auipc	ra,0x3
    80002fb4:	fc4080e7          	jalr	-60(ra) # 80005f74 <virtio_disk_rw>
    b->valid = 1;
    80002fb8:	4785                	li	a5,1
    80002fba:	c09c                	sw	a5,0(s1)
  return b;
    80002fbc:	b7c5                	j	80002f9c <bread+0xd0>

0000000080002fbe <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fbe:	1101                	addi	sp,sp,-32
    80002fc0:	ec06                	sd	ra,24(sp)
    80002fc2:	e822                	sd	s0,16(sp)
    80002fc4:	e426                	sd	s1,8(sp)
    80002fc6:	1000                	addi	s0,sp,32
    80002fc8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fca:	0541                	addi	a0,a0,16
    80002fcc:	00001097          	auipc	ra,0x1
    80002fd0:	47a080e7          	jalr	1146(ra) # 80004446 <holdingsleep>
    80002fd4:	cd01                	beqz	a0,80002fec <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fd6:	4585                	li	a1,1
    80002fd8:	8526                	mv	a0,s1
    80002fda:	00003097          	auipc	ra,0x3
    80002fde:	f9a080e7          	jalr	-102(ra) # 80005f74 <virtio_disk_rw>
}
    80002fe2:	60e2                	ld	ra,24(sp)
    80002fe4:	6442                	ld	s0,16(sp)
    80002fe6:	64a2                	ld	s1,8(sp)
    80002fe8:	6105                	addi	sp,sp,32
    80002fea:	8082                	ret
    panic("bwrite");
    80002fec:	00005517          	auipc	a0,0x5
    80002ff0:	54c50513          	addi	a0,a0,1356 # 80008538 <syscalls+0xf0>
    80002ff4:	ffffd097          	auipc	ra,0xffffd
    80002ff8:	544080e7          	jalr	1348(ra) # 80000538 <panic>

0000000080002ffc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ffc:	1101                	addi	sp,sp,-32
    80002ffe:	ec06                	sd	ra,24(sp)
    80003000:	e822                	sd	s0,16(sp)
    80003002:	e426                	sd	s1,8(sp)
    80003004:	e04a                	sd	s2,0(sp)
    80003006:	1000                	addi	s0,sp,32
    80003008:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000300a:	01050913          	addi	s2,a0,16
    8000300e:	854a                	mv	a0,s2
    80003010:	00001097          	auipc	ra,0x1
    80003014:	436080e7          	jalr	1078(ra) # 80004446 <holdingsleep>
    80003018:	c92d                	beqz	a0,8000308a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000301a:	854a                	mv	a0,s2
    8000301c:	00001097          	auipc	ra,0x1
    80003020:	3e6080e7          	jalr	998(ra) # 80004402 <releasesleep>

  acquire(&bcache.lock);
    80003024:	00014517          	auipc	a0,0x14
    80003028:	cd450513          	addi	a0,a0,-812 # 80016cf8 <bcache>
    8000302c:	ffffe097          	auipc	ra,0xffffe
    80003030:	ba4080e7          	jalr	-1116(ra) # 80000bd0 <acquire>
  b->refcnt--;
    80003034:	40bc                	lw	a5,64(s1)
    80003036:	37fd                	addiw	a5,a5,-1
    80003038:	0007871b          	sext.w	a4,a5
    8000303c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000303e:	eb05                	bnez	a4,8000306e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003040:	68bc                	ld	a5,80(s1)
    80003042:	64b8                	ld	a4,72(s1)
    80003044:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003046:	64bc                	ld	a5,72(s1)
    80003048:	68b8                	ld	a4,80(s1)
    8000304a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000304c:	0001c797          	auipc	a5,0x1c
    80003050:	cac78793          	addi	a5,a5,-852 # 8001ecf8 <bcache+0x8000>
    80003054:	2b87b703          	ld	a4,696(a5)
    80003058:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000305a:	0001c717          	auipc	a4,0x1c
    8000305e:	f0670713          	addi	a4,a4,-250 # 8001ef60 <bcache+0x8268>
    80003062:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003064:	2b87b703          	ld	a4,696(a5)
    80003068:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000306a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000306e:	00014517          	auipc	a0,0x14
    80003072:	c8a50513          	addi	a0,a0,-886 # 80016cf8 <bcache>
    80003076:	ffffe097          	auipc	ra,0xffffe
    8000307a:	c0e080e7          	jalr	-1010(ra) # 80000c84 <release>
}
    8000307e:	60e2                	ld	ra,24(sp)
    80003080:	6442                	ld	s0,16(sp)
    80003082:	64a2                	ld	s1,8(sp)
    80003084:	6902                	ld	s2,0(sp)
    80003086:	6105                	addi	sp,sp,32
    80003088:	8082                	ret
    panic("brelse");
    8000308a:	00005517          	auipc	a0,0x5
    8000308e:	4b650513          	addi	a0,a0,1206 # 80008540 <syscalls+0xf8>
    80003092:	ffffd097          	auipc	ra,0xffffd
    80003096:	4a6080e7          	jalr	1190(ra) # 80000538 <panic>

000000008000309a <bpin>:

void
bpin(struct buf *b) {
    8000309a:	1101                	addi	sp,sp,-32
    8000309c:	ec06                	sd	ra,24(sp)
    8000309e:	e822                	sd	s0,16(sp)
    800030a0:	e426                	sd	s1,8(sp)
    800030a2:	1000                	addi	s0,sp,32
    800030a4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030a6:	00014517          	auipc	a0,0x14
    800030aa:	c5250513          	addi	a0,a0,-942 # 80016cf8 <bcache>
    800030ae:	ffffe097          	auipc	ra,0xffffe
    800030b2:	b22080e7          	jalr	-1246(ra) # 80000bd0 <acquire>
  b->refcnt++;
    800030b6:	40bc                	lw	a5,64(s1)
    800030b8:	2785                	addiw	a5,a5,1
    800030ba:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030bc:	00014517          	auipc	a0,0x14
    800030c0:	c3c50513          	addi	a0,a0,-964 # 80016cf8 <bcache>
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	bc0080e7          	jalr	-1088(ra) # 80000c84 <release>
}
    800030cc:	60e2                	ld	ra,24(sp)
    800030ce:	6442                	ld	s0,16(sp)
    800030d0:	64a2                	ld	s1,8(sp)
    800030d2:	6105                	addi	sp,sp,32
    800030d4:	8082                	ret

00000000800030d6 <bunpin>:

void
bunpin(struct buf *b) {
    800030d6:	1101                	addi	sp,sp,-32
    800030d8:	ec06                	sd	ra,24(sp)
    800030da:	e822                	sd	s0,16(sp)
    800030dc:	e426                	sd	s1,8(sp)
    800030de:	1000                	addi	s0,sp,32
    800030e0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030e2:	00014517          	auipc	a0,0x14
    800030e6:	c1650513          	addi	a0,a0,-1002 # 80016cf8 <bcache>
    800030ea:	ffffe097          	auipc	ra,0xffffe
    800030ee:	ae6080e7          	jalr	-1306(ra) # 80000bd0 <acquire>
  b->refcnt--;
    800030f2:	40bc                	lw	a5,64(s1)
    800030f4:	37fd                	addiw	a5,a5,-1
    800030f6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030f8:	00014517          	auipc	a0,0x14
    800030fc:	c0050513          	addi	a0,a0,-1024 # 80016cf8 <bcache>
    80003100:	ffffe097          	auipc	ra,0xffffe
    80003104:	b84080e7          	jalr	-1148(ra) # 80000c84 <release>
}
    80003108:	60e2                	ld	ra,24(sp)
    8000310a:	6442                	ld	s0,16(sp)
    8000310c:	64a2                	ld	s1,8(sp)
    8000310e:	6105                	addi	sp,sp,32
    80003110:	8082                	ret

0000000080003112 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003112:	1101                	addi	sp,sp,-32
    80003114:	ec06                	sd	ra,24(sp)
    80003116:	e822                	sd	s0,16(sp)
    80003118:	e426                	sd	s1,8(sp)
    8000311a:	e04a                	sd	s2,0(sp)
    8000311c:	1000                	addi	s0,sp,32
    8000311e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003120:	00d5d59b          	srliw	a1,a1,0xd
    80003124:	0001c797          	auipc	a5,0x1c
    80003128:	2b07a783          	lw	a5,688(a5) # 8001f3d4 <sb+0x1c>
    8000312c:	9dbd                	addw	a1,a1,a5
    8000312e:	00000097          	auipc	ra,0x0
    80003132:	d9e080e7          	jalr	-610(ra) # 80002ecc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003136:	0074f713          	andi	a4,s1,7
    8000313a:	4785                	li	a5,1
    8000313c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003140:	14ce                	slli	s1,s1,0x33
    80003142:	90d9                	srli	s1,s1,0x36
    80003144:	00950733          	add	a4,a0,s1
    80003148:	05874703          	lbu	a4,88(a4)
    8000314c:	00e7f6b3          	and	a3,a5,a4
    80003150:	c69d                	beqz	a3,8000317e <bfree+0x6c>
    80003152:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003154:	94aa                	add	s1,s1,a0
    80003156:	fff7c793          	not	a5,a5
    8000315a:	8ff9                	and	a5,a5,a4
    8000315c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003160:	00001097          	auipc	ra,0x1
    80003164:	12c080e7          	jalr	300(ra) # 8000428c <log_write>
  brelse(bp);
    80003168:	854a                	mv	a0,s2
    8000316a:	00000097          	auipc	ra,0x0
    8000316e:	e92080e7          	jalr	-366(ra) # 80002ffc <brelse>
}
    80003172:	60e2                	ld	ra,24(sp)
    80003174:	6442                	ld	s0,16(sp)
    80003176:	64a2                	ld	s1,8(sp)
    80003178:	6902                	ld	s2,0(sp)
    8000317a:	6105                	addi	sp,sp,32
    8000317c:	8082                	ret
    panic("freeing free block");
    8000317e:	00005517          	auipc	a0,0x5
    80003182:	3ca50513          	addi	a0,a0,970 # 80008548 <syscalls+0x100>
    80003186:	ffffd097          	auipc	ra,0xffffd
    8000318a:	3b2080e7          	jalr	946(ra) # 80000538 <panic>

000000008000318e <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
    8000318e:	7179                	addi	sp,sp,-48
    80003190:	f406                	sd	ra,40(sp)
    80003192:	f022                	sd	s0,32(sp)
    80003194:	ec26                	sd	s1,24(sp)
    80003196:	e84a                	sd	s2,16(sp)
    80003198:	e44e                	sd	s3,8(sp)
    8000319a:	e052                	sd	s4,0(sp)
    8000319c:	1800                	addi	s0,sp,48
    8000319e:	89aa                	mv	s3,a0
    800031a0:	8a2e                	mv	s4,a1
  struct inode *ip, *empty;

  acquire(&itable.lock);
    800031a2:	0001c517          	auipc	a0,0x1c
    800031a6:	23650513          	addi	a0,a0,566 # 8001f3d8 <itable>
    800031aa:	ffffe097          	auipc	ra,0xffffe
    800031ae:	a26080e7          	jalr	-1498(ra) # 80000bd0 <acquire>

  // Is the inode already in the table?
  empty = 0;
    800031b2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031b4:	0001c497          	auipc	s1,0x1c
    800031b8:	23c48493          	addi	s1,s1,572 # 8001f3f0 <itable+0x18>
    800031bc:	0001e697          	auipc	a3,0x1e
    800031c0:	cc468693          	addi	a3,a3,-828 # 80020e80 <log>
    800031c4:	a039                	j	800031d2 <iget+0x44>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&itable.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031c6:	02090b63          	beqz	s2,800031fc <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031ca:	08848493          	addi	s1,s1,136
    800031ce:	02d48a63          	beq	s1,a3,80003202 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800031d2:	449c                	lw	a5,8(s1)
    800031d4:	fef059e3          	blez	a5,800031c6 <iget+0x38>
    800031d8:	4098                	lw	a4,0(s1)
    800031da:	ff3716e3          	bne	a4,s3,800031c6 <iget+0x38>
    800031de:	40d8                	lw	a4,4(s1)
    800031e0:	ff4713e3          	bne	a4,s4,800031c6 <iget+0x38>
      ip->ref++;
    800031e4:	2785                	addiw	a5,a5,1
    800031e6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031e8:	0001c517          	auipc	a0,0x1c
    800031ec:	1f050513          	addi	a0,a0,496 # 8001f3d8 <itable>
    800031f0:	ffffe097          	auipc	ra,0xffffe
    800031f4:	a94080e7          	jalr	-1388(ra) # 80000c84 <release>
      return ip;
    800031f8:	8926                	mv	s2,s1
    800031fa:	a03d                	j	80003228 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031fc:	f7f9                	bnez	a5,800031ca <iget+0x3c>
    800031fe:	8926                	mv	s2,s1
    80003200:	b7e9                	j	800031ca <iget+0x3c>
      empty = ip;
  }

  // Recycle an inode entry.
  if(empty == 0)
    80003202:	02090c63          	beqz	s2,8000323a <iget+0xac>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
    80003206:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000320a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000320e:	4785                	li	a5,1
    80003210:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003214:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003218:	0001c517          	auipc	a0,0x1c
    8000321c:	1c050513          	addi	a0,a0,448 # 8001f3d8 <itable>
    80003220:	ffffe097          	auipc	ra,0xffffe
    80003224:	a64080e7          	jalr	-1436(ra) # 80000c84 <release>

  return ip;
}
    80003228:	854a                	mv	a0,s2
    8000322a:	70a2                	ld	ra,40(sp)
    8000322c:	7402                	ld	s0,32(sp)
    8000322e:	64e2                	ld	s1,24(sp)
    80003230:	6942                	ld	s2,16(sp)
    80003232:	69a2                	ld	s3,8(sp)
    80003234:	6a02                	ld	s4,0(sp)
    80003236:	6145                	addi	sp,sp,48
    80003238:	8082                	ret
    panic("iget: no inodes");
    8000323a:	00005517          	auipc	a0,0x5
    8000323e:	32650513          	addi	a0,a0,806 # 80008560 <syscalls+0x118>
    80003242:	ffffd097          	auipc	ra,0xffffd
    80003246:	2f6080e7          	jalr	758(ra) # 80000538 <panic>

000000008000324a <balloc>:
{
    8000324a:	711d                	addi	sp,sp,-96
    8000324c:	ec86                	sd	ra,88(sp)
    8000324e:	e8a2                	sd	s0,80(sp)
    80003250:	e4a6                	sd	s1,72(sp)
    80003252:	e0ca                	sd	s2,64(sp)
    80003254:	fc4e                	sd	s3,56(sp)
    80003256:	f852                	sd	s4,48(sp)
    80003258:	f456                	sd	s5,40(sp)
    8000325a:	f05a                	sd	s6,32(sp)
    8000325c:	ec5e                	sd	s7,24(sp)
    8000325e:	e862                	sd	s8,16(sp)
    80003260:	e466                	sd	s9,8(sp)
    80003262:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003264:	0001c797          	auipc	a5,0x1c
    80003268:	1587a783          	lw	a5,344(a5) # 8001f3bc <sb+0x4>
    8000326c:	10078163          	beqz	a5,8000336e <balloc+0x124>
    80003270:	8baa                	mv	s7,a0
    80003272:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003274:	0001cb17          	auipc	s6,0x1c
    80003278:	144b0b13          	addi	s6,s6,324 # 8001f3b8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000327c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000327e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003280:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003282:	6c89                	lui	s9,0x2
    80003284:	a061                	j	8000330c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003286:	974a                	add	a4,a4,s2
    80003288:	8fd5                	or	a5,a5,a3
    8000328a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000328e:	854a                	mv	a0,s2
    80003290:	00001097          	auipc	ra,0x1
    80003294:	ffc080e7          	jalr	-4(ra) # 8000428c <log_write>
        brelse(bp);
    80003298:	854a                	mv	a0,s2
    8000329a:	00000097          	auipc	ra,0x0
    8000329e:	d62080e7          	jalr	-670(ra) # 80002ffc <brelse>
  bp = bread(dev, bno);
    800032a2:	85a6                	mv	a1,s1
    800032a4:	855e                	mv	a0,s7
    800032a6:	00000097          	auipc	ra,0x0
    800032aa:	c26080e7          	jalr	-986(ra) # 80002ecc <bread>
    800032ae:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032b0:	40000613          	li	a2,1024
    800032b4:	4581                	li	a1,0
    800032b6:	05850513          	addi	a0,a0,88
    800032ba:	ffffe097          	auipc	ra,0xffffe
    800032be:	a12080e7          	jalr	-1518(ra) # 80000ccc <memset>
  log_write(bp);
    800032c2:	854a                	mv	a0,s2
    800032c4:	00001097          	auipc	ra,0x1
    800032c8:	fc8080e7          	jalr	-56(ra) # 8000428c <log_write>
  brelse(bp);
    800032cc:	854a                	mv	a0,s2
    800032ce:	00000097          	auipc	ra,0x0
    800032d2:	d2e080e7          	jalr	-722(ra) # 80002ffc <brelse>
}
    800032d6:	8526                	mv	a0,s1
    800032d8:	60e6                	ld	ra,88(sp)
    800032da:	6446                	ld	s0,80(sp)
    800032dc:	64a6                	ld	s1,72(sp)
    800032de:	6906                	ld	s2,64(sp)
    800032e0:	79e2                	ld	s3,56(sp)
    800032e2:	7a42                	ld	s4,48(sp)
    800032e4:	7aa2                	ld	s5,40(sp)
    800032e6:	7b02                	ld	s6,32(sp)
    800032e8:	6be2                	ld	s7,24(sp)
    800032ea:	6c42                	ld	s8,16(sp)
    800032ec:	6ca2                	ld	s9,8(sp)
    800032ee:	6125                	addi	sp,sp,96
    800032f0:	8082                	ret
    brelse(bp);
    800032f2:	854a                	mv	a0,s2
    800032f4:	00000097          	auipc	ra,0x0
    800032f8:	d08080e7          	jalr	-760(ra) # 80002ffc <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032fc:	015c87bb          	addw	a5,s9,s5
    80003300:	00078a9b          	sext.w	s5,a5
    80003304:	004b2703          	lw	a4,4(s6)
    80003308:	06eaf363          	bgeu	s5,a4,8000336e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000330c:	41fad79b          	sraiw	a5,s5,0x1f
    80003310:	0137d79b          	srliw	a5,a5,0x13
    80003314:	015787bb          	addw	a5,a5,s5
    80003318:	40d7d79b          	sraiw	a5,a5,0xd
    8000331c:	01cb2583          	lw	a1,28(s6)
    80003320:	9dbd                	addw	a1,a1,a5
    80003322:	855e                	mv	a0,s7
    80003324:	00000097          	auipc	ra,0x0
    80003328:	ba8080e7          	jalr	-1112(ra) # 80002ecc <bread>
    8000332c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000332e:	004b2503          	lw	a0,4(s6)
    80003332:	000a849b          	sext.w	s1,s5
    80003336:	8662                	mv	a2,s8
    80003338:	faa4fde3          	bgeu	s1,a0,800032f2 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000333c:	41f6579b          	sraiw	a5,a2,0x1f
    80003340:	01d7d69b          	srliw	a3,a5,0x1d
    80003344:	00c6873b          	addw	a4,a3,a2
    80003348:	00777793          	andi	a5,a4,7
    8000334c:	9f95                	subw	a5,a5,a3
    8000334e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003352:	4037571b          	sraiw	a4,a4,0x3
    80003356:	00e906b3          	add	a3,s2,a4
    8000335a:	0586c683          	lbu	a3,88(a3)
    8000335e:	00d7f5b3          	and	a1,a5,a3
    80003362:	d195                	beqz	a1,80003286 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003364:	2605                	addiw	a2,a2,1
    80003366:	2485                	addiw	s1,s1,1
    80003368:	fd4618e3          	bne	a2,s4,80003338 <balloc+0xee>
    8000336c:	b759                	j	800032f2 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000336e:	00005517          	auipc	a0,0x5
    80003372:	20250513          	addi	a0,a0,514 # 80008570 <syscalls+0x128>
    80003376:	ffffd097          	auipc	ra,0xffffd
    8000337a:	20c080e7          	jalr	524(ra) # 80000582 <printf>
  return 0;
    8000337e:	4481                	li	s1,0
    80003380:	bf99                	j	800032d6 <balloc+0x8c>

0000000080003382 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003382:	7179                	addi	sp,sp,-48
    80003384:	f406                	sd	ra,40(sp)
    80003386:	f022                	sd	s0,32(sp)
    80003388:	ec26                	sd	s1,24(sp)
    8000338a:	e84a                	sd	s2,16(sp)
    8000338c:	e44e                	sd	s3,8(sp)
    8000338e:	e052                	sd	s4,0(sp)
    80003390:	1800                	addi	s0,sp,48
    80003392:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003394:	47ad                	li	a5,11
    80003396:	02b7e763          	bltu	a5,a1,800033c4 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000339a:	02059493          	slli	s1,a1,0x20
    8000339e:	9081                	srli	s1,s1,0x20
    800033a0:	048a                	slli	s1,s1,0x2
    800033a2:	94aa                	add	s1,s1,a0
    800033a4:	0504a903          	lw	s2,80(s1)
    800033a8:	06091e63          	bnez	s2,80003424 <bmap+0xa2>
      addr = balloc(ip->dev);
    800033ac:	4108                	lw	a0,0(a0)
    800033ae:	00000097          	auipc	ra,0x0
    800033b2:	e9c080e7          	jalr	-356(ra) # 8000324a <balloc>
    800033b6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033ba:	06090563          	beqz	s2,80003424 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800033be:	0524a823          	sw	s2,80(s1)
    800033c2:	a08d                	j	80003424 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033c4:	ff45849b          	addiw	s1,a1,-12
    800033c8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033cc:	0ff00793          	li	a5,255
    800033d0:	08e7e563          	bltu	a5,a4,8000345a <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033d4:	08052903          	lw	s2,128(a0)
    800033d8:	00091d63          	bnez	s2,800033f2 <bmap+0x70>
      addr = balloc(ip->dev);
    800033dc:	4108                	lw	a0,0(a0)
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	e6c080e7          	jalr	-404(ra) # 8000324a <balloc>
    800033e6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033ea:	02090d63          	beqz	s2,80003424 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800033ee:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800033f2:	85ca                	mv	a1,s2
    800033f4:	0009a503          	lw	a0,0(s3)
    800033f8:	00000097          	auipc	ra,0x0
    800033fc:	ad4080e7          	jalr	-1324(ra) # 80002ecc <bread>
    80003400:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003402:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003406:	02049593          	slli	a1,s1,0x20
    8000340a:	9181                	srli	a1,a1,0x20
    8000340c:	058a                	slli	a1,a1,0x2
    8000340e:	00b784b3          	add	s1,a5,a1
    80003412:	0004a903          	lw	s2,0(s1)
    80003416:	02090063          	beqz	s2,80003436 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000341a:	8552                	mv	a0,s4
    8000341c:	00000097          	auipc	ra,0x0
    80003420:	be0080e7          	jalr	-1056(ra) # 80002ffc <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003424:	854a                	mv	a0,s2
    80003426:	70a2                	ld	ra,40(sp)
    80003428:	7402                	ld	s0,32(sp)
    8000342a:	64e2                	ld	s1,24(sp)
    8000342c:	6942                	ld	s2,16(sp)
    8000342e:	69a2                	ld	s3,8(sp)
    80003430:	6a02                	ld	s4,0(sp)
    80003432:	6145                	addi	sp,sp,48
    80003434:	8082                	ret
      addr = balloc(ip->dev);
    80003436:	0009a503          	lw	a0,0(s3)
    8000343a:	00000097          	auipc	ra,0x0
    8000343e:	e10080e7          	jalr	-496(ra) # 8000324a <balloc>
    80003442:	0005091b          	sext.w	s2,a0
      if(addr){
    80003446:	fc090ae3          	beqz	s2,8000341a <bmap+0x98>
        a[bn] = addr;
    8000344a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000344e:	8552                	mv	a0,s4
    80003450:	00001097          	auipc	ra,0x1
    80003454:	e3c080e7          	jalr	-452(ra) # 8000428c <log_write>
    80003458:	b7c9                	j	8000341a <bmap+0x98>
  panic("bmap: out of range");
    8000345a:	00005517          	auipc	a0,0x5
    8000345e:	12e50513          	addi	a0,a0,302 # 80008588 <syscalls+0x140>
    80003462:	ffffd097          	auipc	ra,0xffffd
    80003466:	0d6080e7          	jalr	214(ra) # 80000538 <panic>

000000008000346a <fsinit>:
fsinit(int dev) {
    8000346a:	7179                	addi	sp,sp,-48
    8000346c:	f406                	sd	ra,40(sp)
    8000346e:	f022                	sd	s0,32(sp)
    80003470:	ec26                	sd	s1,24(sp)
    80003472:	e84a                	sd	s2,16(sp)
    80003474:	e44e                	sd	s3,8(sp)
    80003476:	1800                	addi	s0,sp,48
    80003478:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000347a:	4585                	li	a1,1
    8000347c:	00000097          	auipc	ra,0x0
    80003480:	a50080e7          	jalr	-1456(ra) # 80002ecc <bread>
    80003484:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003486:	0001c997          	auipc	s3,0x1c
    8000348a:	f3298993          	addi	s3,s3,-206 # 8001f3b8 <sb>
    8000348e:	02000613          	li	a2,32
    80003492:	05850593          	addi	a1,a0,88
    80003496:	854e                	mv	a0,s3
    80003498:	ffffe097          	auipc	ra,0xffffe
    8000349c:	890080e7          	jalr	-1904(ra) # 80000d28 <memmove>
  brelse(bp);
    800034a0:	8526                	mv	a0,s1
    800034a2:	00000097          	auipc	ra,0x0
    800034a6:	b5a080e7          	jalr	-1190(ra) # 80002ffc <brelse>
  if(sb.magic != FSMAGIC)
    800034aa:	0009a703          	lw	a4,0(s3)
    800034ae:	102037b7          	lui	a5,0x10203
    800034b2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034b6:	02f71263          	bne	a4,a5,800034da <fsinit+0x70>
  initlog(dev, &sb);
    800034ba:	0001c597          	auipc	a1,0x1c
    800034be:	efe58593          	addi	a1,a1,-258 # 8001f3b8 <sb>
    800034c2:	854a                	mv	a0,s2
    800034c4:	00001097          	auipc	ra,0x1
    800034c8:	b4c080e7          	jalr	-1204(ra) # 80004010 <initlog>
}
    800034cc:	70a2                	ld	ra,40(sp)
    800034ce:	7402                	ld	s0,32(sp)
    800034d0:	64e2                	ld	s1,24(sp)
    800034d2:	6942                	ld	s2,16(sp)
    800034d4:	69a2                	ld	s3,8(sp)
    800034d6:	6145                	addi	sp,sp,48
    800034d8:	8082                	ret
    panic("invalid file system");
    800034da:	00005517          	auipc	a0,0x5
    800034de:	0c650513          	addi	a0,a0,198 # 800085a0 <syscalls+0x158>
    800034e2:	ffffd097          	auipc	ra,0xffffd
    800034e6:	056080e7          	jalr	86(ra) # 80000538 <panic>

00000000800034ea <iinit>:
{
    800034ea:	7179                	addi	sp,sp,-48
    800034ec:	f406                	sd	ra,40(sp)
    800034ee:	f022                	sd	s0,32(sp)
    800034f0:	ec26                	sd	s1,24(sp)
    800034f2:	e84a                	sd	s2,16(sp)
    800034f4:	e44e                	sd	s3,8(sp)
    800034f6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034f8:	00005597          	auipc	a1,0x5
    800034fc:	0c058593          	addi	a1,a1,192 # 800085b8 <syscalls+0x170>
    80003500:	0001c517          	auipc	a0,0x1c
    80003504:	ed850513          	addi	a0,a0,-296 # 8001f3d8 <itable>
    80003508:	ffffd097          	auipc	ra,0xffffd
    8000350c:	638080e7          	jalr	1592(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003510:	0001c497          	auipc	s1,0x1c
    80003514:	ef048493          	addi	s1,s1,-272 # 8001f400 <itable+0x28>
    80003518:	0001e997          	auipc	s3,0x1e
    8000351c:	97898993          	addi	s3,s3,-1672 # 80020e90 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003520:	00005917          	auipc	s2,0x5
    80003524:	0a090913          	addi	s2,s2,160 # 800085c0 <syscalls+0x178>
    80003528:	85ca                	mv	a1,s2
    8000352a:	8526                	mv	a0,s1
    8000352c:	00001097          	auipc	ra,0x1
    80003530:	e46080e7          	jalr	-442(ra) # 80004372 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003534:	08848493          	addi	s1,s1,136
    80003538:	ff3498e3          	bne	s1,s3,80003528 <iinit+0x3e>
}
    8000353c:	70a2                	ld	ra,40(sp)
    8000353e:	7402                	ld	s0,32(sp)
    80003540:	64e2                	ld	s1,24(sp)
    80003542:	6942                	ld	s2,16(sp)
    80003544:	69a2                	ld	s3,8(sp)
    80003546:	6145                	addi	sp,sp,48
    80003548:	8082                	ret

000000008000354a <ialloc>:
{
    8000354a:	715d                	addi	sp,sp,-80
    8000354c:	e486                	sd	ra,72(sp)
    8000354e:	e0a2                	sd	s0,64(sp)
    80003550:	fc26                	sd	s1,56(sp)
    80003552:	f84a                	sd	s2,48(sp)
    80003554:	f44e                	sd	s3,40(sp)
    80003556:	f052                	sd	s4,32(sp)
    80003558:	ec56                	sd	s5,24(sp)
    8000355a:	e85a                	sd	s6,16(sp)
    8000355c:	e45e                	sd	s7,8(sp)
    8000355e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003560:	0001c717          	auipc	a4,0x1c
    80003564:	e6472703          	lw	a4,-412(a4) # 8001f3c4 <sb+0xc>
    80003568:	4785                	li	a5,1
    8000356a:	04e7fa63          	bgeu	a5,a4,800035be <ialloc+0x74>
    8000356e:	8aaa                	mv	s5,a0
    80003570:	8bae                	mv	s7,a1
    80003572:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003574:	0001ca17          	auipc	s4,0x1c
    80003578:	e44a0a13          	addi	s4,s4,-444 # 8001f3b8 <sb>
    8000357c:	00048b1b          	sext.w	s6,s1
    80003580:	0044d793          	srli	a5,s1,0x4
    80003584:	018a2583          	lw	a1,24(s4)
    80003588:	9dbd                	addw	a1,a1,a5
    8000358a:	8556                	mv	a0,s5
    8000358c:	00000097          	auipc	ra,0x0
    80003590:	940080e7          	jalr	-1728(ra) # 80002ecc <bread>
    80003594:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003596:	05850993          	addi	s3,a0,88
    8000359a:	00f4f793          	andi	a5,s1,15
    8000359e:	079a                	slli	a5,a5,0x6
    800035a0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035a2:	00099783          	lh	a5,0(s3)
    800035a6:	c785                	beqz	a5,800035ce <ialloc+0x84>
    brelse(bp);
    800035a8:	00000097          	auipc	ra,0x0
    800035ac:	a54080e7          	jalr	-1452(ra) # 80002ffc <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035b0:	0485                	addi	s1,s1,1
    800035b2:	00ca2703          	lw	a4,12(s4)
    800035b6:	0004879b          	sext.w	a5,s1
    800035ba:	fce7e1e3          	bltu	a5,a4,8000357c <ialloc+0x32>
  panic("ialloc: no inodes");
    800035be:	00005517          	auipc	a0,0x5
    800035c2:	00a50513          	addi	a0,a0,10 # 800085c8 <syscalls+0x180>
    800035c6:	ffffd097          	auipc	ra,0xffffd
    800035ca:	f72080e7          	jalr	-142(ra) # 80000538 <panic>
      memset(dip, 0, sizeof(*dip));
    800035ce:	04000613          	li	a2,64
    800035d2:	4581                	li	a1,0
    800035d4:	854e                	mv	a0,s3
    800035d6:	ffffd097          	auipc	ra,0xffffd
    800035da:	6f6080e7          	jalr	1782(ra) # 80000ccc <memset>
      dip->type = type;
    800035de:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035e2:	854a                	mv	a0,s2
    800035e4:	00001097          	auipc	ra,0x1
    800035e8:	ca8080e7          	jalr	-856(ra) # 8000428c <log_write>
      brelse(bp);
    800035ec:	854a                	mv	a0,s2
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	a0e080e7          	jalr	-1522(ra) # 80002ffc <brelse>
      return iget(dev, inum);
    800035f6:	85da                	mv	a1,s6
    800035f8:	8556                	mv	a0,s5
    800035fa:	00000097          	auipc	ra,0x0
    800035fe:	b94080e7          	jalr	-1132(ra) # 8000318e <iget>
}
    80003602:	60a6                	ld	ra,72(sp)
    80003604:	6406                	ld	s0,64(sp)
    80003606:	74e2                	ld	s1,56(sp)
    80003608:	7942                	ld	s2,48(sp)
    8000360a:	79a2                	ld	s3,40(sp)
    8000360c:	7a02                	ld	s4,32(sp)
    8000360e:	6ae2                	ld	s5,24(sp)
    80003610:	6b42                	ld	s6,16(sp)
    80003612:	6ba2                	ld	s7,8(sp)
    80003614:	6161                	addi	sp,sp,80
    80003616:	8082                	ret

0000000080003618 <iupdate>:
{
    80003618:	1101                	addi	sp,sp,-32
    8000361a:	ec06                	sd	ra,24(sp)
    8000361c:	e822                	sd	s0,16(sp)
    8000361e:	e426                	sd	s1,8(sp)
    80003620:	e04a                	sd	s2,0(sp)
    80003622:	1000                	addi	s0,sp,32
    80003624:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003626:	415c                	lw	a5,4(a0)
    80003628:	0047d79b          	srliw	a5,a5,0x4
    8000362c:	0001c597          	auipc	a1,0x1c
    80003630:	da45a583          	lw	a1,-604(a1) # 8001f3d0 <sb+0x18>
    80003634:	9dbd                	addw	a1,a1,a5
    80003636:	4108                	lw	a0,0(a0)
    80003638:	00000097          	auipc	ra,0x0
    8000363c:	894080e7          	jalr	-1900(ra) # 80002ecc <bread>
    80003640:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003642:	05850793          	addi	a5,a0,88
    80003646:	40c8                	lw	a0,4(s1)
    80003648:	893d                	andi	a0,a0,15
    8000364a:	051a                	slli	a0,a0,0x6
    8000364c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000364e:	04449703          	lh	a4,68(s1)
    80003652:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003656:	04649703          	lh	a4,70(s1)
    8000365a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000365e:	04849703          	lh	a4,72(s1)
    80003662:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003666:	04a49703          	lh	a4,74(s1)
    8000366a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000366e:	44f8                	lw	a4,76(s1)
    80003670:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003672:	03400613          	li	a2,52
    80003676:	05048593          	addi	a1,s1,80
    8000367a:	0531                	addi	a0,a0,12
    8000367c:	ffffd097          	auipc	ra,0xffffd
    80003680:	6ac080e7          	jalr	1708(ra) # 80000d28 <memmove>
  log_write(bp);
    80003684:	854a                	mv	a0,s2
    80003686:	00001097          	auipc	ra,0x1
    8000368a:	c06080e7          	jalr	-1018(ra) # 8000428c <log_write>
  brelse(bp);
    8000368e:	854a                	mv	a0,s2
    80003690:	00000097          	auipc	ra,0x0
    80003694:	96c080e7          	jalr	-1684(ra) # 80002ffc <brelse>
}
    80003698:	60e2                	ld	ra,24(sp)
    8000369a:	6442                	ld	s0,16(sp)
    8000369c:	64a2                	ld	s1,8(sp)
    8000369e:	6902                	ld	s2,0(sp)
    800036a0:	6105                	addi	sp,sp,32
    800036a2:	8082                	ret

00000000800036a4 <idup>:
{
    800036a4:	1101                	addi	sp,sp,-32
    800036a6:	ec06                	sd	ra,24(sp)
    800036a8:	e822                	sd	s0,16(sp)
    800036aa:	e426                	sd	s1,8(sp)
    800036ac:	1000                	addi	s0,sp,32
    800036ae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036b0:	0001c517          	auipc	a0,0x1c
    800036b4:	d2850513          	addi	a0,a0,-728 # 8001f3d8 <itable>
    800036b8:	ffffd097          	auipc	ra,0xffffd
    800036bc:	518080e7          	jalr	1304(ra) # 80000bd0 <acquire>
  ip->ref++;
    800036c0:	449c                	lw	a5,8(s1)
    800036c2:	2785                	addiw	a5,a5,1
    800036c4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036c6:	0001c517          	auipc	a0,0x1c
    800036ca:	d1250513          	addi	a0,a0,-750 # 8001f3d8 <itable>
    800036ce:	ffffd097          	auipc	ra,0xffffd
    800036d2:	5b6080e7          	jalr	1462(ra) # 80000c84 <release>
}
    800036d6:	8526                	mv	a0,s1
    800036d8:	60e2                	ld	ra,24(sp)
    800036da:	6442                	ld	s0,16(sp)
    800036dc:	64a2                	ld	s1,8(sp)
    800036de:	6105                	addi	sp,sp,32
    800036e0:	8082                	ret

00000000800036e2 <ilock>:
{
    800036e2:	1101                	addi	sp,sp,-32
    800036e4:	ec06                	sd	ra,24(sp)
    800036e6:	e822                	sd	s0,16(sp)
    800036e8:	e426                	sd	s1,8(sp)
    800036ea:	e04a                	sd	s2,0(sp)
    800036ec:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036ee:	c115                	beqz	a0,80003712 <ilock+0x30>
    800036f0:	84aa                	mv	s1,a0
    800036f2:	451c                	lw	a5,8(a0)
    800036f4:	00f05f63          	blez	a5,80003712 <ilock+0x30>
  acquiresleep(&ip->lock);
    800036f8:	0541                	addi	a0,a0,16
    800036fa:	00001097          	auipc	ra,0x1
    800036fe:	cb2080e7          	jalr	-846(ra) # 800043ac <acquiresleep>
  if(ip->valid == 0){
    80003702:	40bc                	lw	a5,64(s1)
    80003704:	cf99                	beqz	a5,80003722 <ilock+0x40>
}
    80003706:	60e2                	ld	ra,24(sp)
    80003708:	6442                	ld	s0,16(sp)
    8000370a:	64a2                	ld	s1,8(sp)
    8000370c:	6902                	ld	s2,0(sp)
    8000370e:	6105                	addi	sp,sp,32
    80003710:	8082                	ret
    panic("ilock");
    80003712:	00005517          	auipc	a0,0x5
    80003716:	ece50513          	addi	a0,a0,-306 # 800085e0 <syscalls+0x198>
    8000371a:	ffffd097          	auipc	ra,0xffffd
    8000371e:	e1e080e7          	jalr	-482(ra) # 80000538 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003722:	40dc                	lw	a5,4(s1)
    80003724:	0047d79b          	srliw	a5,a5,0x4
    80003728:	0001c597          	auipc	a1,0x1c
    8000372c:	ca85a583          	lw	a1,-856(a1) # 8001f3d0 <sb+0x18>
    80003730:	9dbd                	addw	a1,a1,a5
    80003732:	4088                	lw	a0,0(s1)
    80003734:	fffff097          	auipc	ra,0xfffff
    80003738:	798080e7          	jalr	1944(ra) # 80002ecc <bread>
    8000373c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000373e:	05850593          	addi	a1,a0,88
    80003742:	40dc                	lw	a5,4(s1)
    80003744:	8bbd                	andi	a5,a5,15
    80003746:	079a                	slli	a5,a5,0x6
    80003748:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000374a:	00059783          	lh	a5,0(a1)
    8000374e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003752:	00259783          	lh	a5,2(a1)
    80003756:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000375a:	00459783          	lh	a5,4(a1)
    8000375e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003762:	00659783          	lh	a5,6(a1)
    80003766:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000376a:	459c                	lw	a5,8(a1)
    8000376c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000376e:	03400613          	li	a2,52
    80003772:	05b1                	addi	a1,a1,12
    80003774:	05048513          	addi	a0,s1,80
    80003778:	ffffd097          	auipc	ra,0xffffd
    8000377c:	5b0080e7          	jalr	1456(ra) # 80000d28 <memmove>
    brelse(bp);
    80003780:	854a                	mv	a0,s2
    80003782:	00000097          	auipc	ra,0x0
    80003786:	87a080e7          	jalr	-1926(ra) # 80002ffc <brelse>
    ip->valid = 1;
    8000378a:	4785                	li	a5,1
    8000378c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000378e:	04449783          	lh	a5,68(s1)
    80003792:	fbb5                	bnez	a5,80003706 <ilock+0x24>
      panic("ilock: no type");
    80003794:	00005517          	auipc	a0,0x5
    80003798:	e5450513          	addi	a0,a0,-428 # 800085e8 <syscalls+0x1a0>
    8000379c:	ffffd097          	auipc	ra,0xffffd
    800037a0:	d9c080e7          	jalr	-612(ra) # 80000538 <panic>

00000000800037a4 <iunlock>:
{
    800037a4:	1101                	addi	sp,sp,-32
    800037a6:	ec06                	sd	ra,24(sp)
    800037a8:	e822                	sd	s0,16(sp)
    800037aa:	e426                	sd	s1,8(sp)
    800037ac:	e04a                	sd	s2,0(sp)
    800037ae:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037b0:	c905                	beqz	a0,800037e0 <iunlock+0x3c>
    800037b2:	84aa                	mv	s1,a0
    800037b4:	01050913          	addi	s2,a0,16
    800037b8:	854a                	mv	a0,s2
    800037ba:	00001097          	auipc	ra,0x1
    800037be:	c8c080e7          	jalr	-884(ra) # 80004446 <holdingsleep>
    800037c2:	cd19                	beqz	a0,800037e0 <iunlock+0x3c>
    800037c4:	449c                	lw	a5,8(s1)
    800037c6:	00f05d63          	blez	a5,800037e0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037ca:	854a                	mv	a0,s2
    800037cc:	00001097          	auipc	ra,0x1
    800037d0:	c36080e7          	jalr	-970(ra) # 80004402 <releasesleep>
}
    800037d4:	60e2                	ld	ra,24(sp)
    800037d6:	6442                	ld	s0,16(sp)
    800037d8:	64a2                	ld	s1,8(sp)
    800037da:	6902                	ld	s2,0(sp)
    800037dc:	6105                	addi	sp,sp,32
    800037de:	8082                	ret
    panic("iunlock");
    800037e0:	00005517          	auipc	a0,0x5
    800037e4:	e1850513          	addi	a0,a0,-488 # 800085f8 <syscalls+0x1b0>
    800037e8:	ffffd097          	auipc	ra,0xffffd
    800037ec:	d50080e7          	jalr	-688(ra) # 80000538 <panic>

00000000800037f0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037f0:	7179                	addi	sp,sp,-48
    800037f2:	f406                	sd	ra,40(sp)
    800037f4:	f022                	sd	s0,32(sp)
    800037f6:	ec26                	sd	s1,24(sp)
    800037f8:	e84a                	sd	s2,16(sp)
    800037fa:	e44e                	sd	s3,8(sp)
    800037fc:	e052                	sd	s4,0(sp)
    800037fe:	1800                	addi	s0,sp,48
    80003800:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003802:	05050493          	addi	s1,a0,80
    80003806:	08050913          	addi	s2,a0,128
    8000380a:	a021                	j	80003812 <itrunc+0x22>
    8000380c:	0491                	addi	s1,s1,4
    8000380e:	01248d63          	beq	s1,s2,80003828 <itrunc+0x38>
    if(ip->addrs[i]){
    80003812:	408c                	lw	a1,0(s1)
    80003814:	dde5                	beqz	a1,8000380c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003816:	0009a503          	lw	a0,0(s3)
    8000381a:	00000097          	auipc	ra,0x0
    8000381e:	8f8080e7          	jalr	-1800(ra) # 80003112 <bfree>
      ip->addrs[i] = 0;
    80003822:	0004a023          	sw	zero,0(s1)
    80003826:	b7dd                	j	8000380c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003828:	0809a583          	lw	a1,128(s3)
    8000382c:	e185                	bnez	a1,8000384c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000382e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003832:	854e                	mv	a0,s3
    80003834:	00000097          	auipc	ra,0x0
    80003838:	de4080e7          	jalr	-540(ra) # 80003618 <iupdate>
}
    8000383c:	70a2                	ld	ra,40(sp)
    8000383e:	7402                	ld	s0,32(sp)
    80003840:	64e2                	ld	s1,24(sp)
    80003842:	6942                	ld	s2,16(sp)
    80003844:	69a2                	ld	s3,8(sp)
    80003846:	6a02                	ld	s4,0(sp)
    80003848:	6145                	addi	sp,sp,48
    8000384a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000384c:	0009a503          	lw	a0,0(s3)
    80003850:	fffff097          	auipc	ra,0xfffff
    80003854:	67c080e7          	jalr	1660(ra) # 80002ecc <bread>
    80003858:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000385a:	05850493          	addi	s1,a0,88
    8000385e:	45850913          	addi	s2,a0,1112
    80003862:	a021                	j	8000386a <itrunc+0x7a>
    80003864:	0491                	addi	s1,s1,4
    80003866:	01248b63          	beq	s1,s2,8000387c <itrunc+0x8c>
      if(a[j])
    8000386a:	408c                	lw	a1,0(s1)
    8000386c:	dde5                	beqz	a1,80003864 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000386e:	0009a503          	lw	a0,0(s3)
    80003872:	00000097          	auipc	ra,0x0
    80003876:	8a0080e7          	jalr	-1888(ra) # 80003112 <bfree>
    8000387a:	b7ed                	j	80003864 <itrunc+0x74>
    brelse(bp);
    8000387c:	8552                	mv	a0,s4
    8000387e:	fffff097          	auipc	ra,0xfffff
    80003882:	77e080e7          	jalr	1918(ra) # 80002ffc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003886:	0809a583          	lw	a1,128(s3)
    8000388a:	0009a503          	lw	a0,0(s3)
    8000388e:	00000097          	auipc	ra,0x0
    80003892:	884080e7          	jalr	-1916(ra) # 80003112 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003896:	0809a023          	sw	zero,128(s3)
    8000389a:	bf51                	j	8000382e <itrunc+0x3e>

000000008000389c <iput>:
{
    8000389c:	1101                	addi	sp,sp,-32
    8000389e:	ec06                	sd	ra,24(sp)
    800038a0:	e822                	sd	s0,16(sp)
    800038a2:	e426                	sd	s1,8(sp)
    800038a4:	e04a                	sd	s2,0(sp)
    800038a6:	1000                	addi	s0,sp,32
    800038a8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038aa:	0001c517          	auipc	a0,0x1c
    800038ae:	b2e50513          	addi	a0,a0,-1234 # 8001f3d8 <itable>
    800038b2:	ffffd097          	auipc	ra,0xffffd
    800038b6:	31e080e7          	jalr	798(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038ba:	4498                	lw	a4,8(s1)
    800038bc:	4785                	li	a5,1
    800038be:	02f70363          	beq	a4,a5,800038e4 <iput+0x48>
  ip->ref--;
    800038c2:	449c                	lw	a5,8(s1)
    800038c4:	37fd                	addiw	a5,a5,-1
    800038c6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038c8:	0001c517          	auipc	a0,0x1c
    800038cc:	b1050513          	addi	a0,a0,-1264 # 8001f3d8 <itable>
    800038d0:	ffffd097          	auipc	ra,0xffffd
    800038d4:	3b4080e7          	jalr	948(ra) # 80000c84 <release>
}
    800038d8:	60e2                	ld	ra,24(sp)
    800038da:	6442                	ld	s0,16(sp)
    800038dc:	64a2                	ld	s1,8(sp)
    800038de:	6902                	ld	s2,0(sp)
    800038e0:	6105                	addi	sp,sp,32
    800038e2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038e4:	40bc                	lw	a5,64(s1)
    800038e6:	dff1                	beqz	a5,800038c2 <iput+0x26>
    800038e8:	04a49783          	lh	a5,74(s1)
    800038ec:	fbf9                	bnez	a5,800038c2 <iput+0x26>
    acquiresleep(&ip->lock);
    800038ee:	01048913          	addi	s2,s1,16
    800038f2:	854a                	mv	a0,s2
    800038f4:	00001097          	auipc	ra,0x1
    800038f8:	ab8080e7          	jalr	-1352(ra) # 800043ac <acquiresleep>
    release(&itable.lock);
    800038fc:	0001c517          	auipc	a0,0x1c
    80003900:	adc50513          	addi	a0,a0,-1316 # 8001f3d8 <itable>
    80003904:	ffffd097          	auipc	ra,0xffffd
    80003908:	380080e7          	jalr	896(ra) # 80000c84 <release>
    itrunc(ip);
    8000390c:	8526                	mv	a0,s1
    8000390e:	00000097          	auipc	ra,0x0
    80003912:	ee2080e7          	jalr	-286(ra) # 800037f0 <itrunc>
    ip->type = 0;
    80003916:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000391a:	8526                	mv	a0,s1
    8000391c:	00000097          	auipc	ra,0x0
    80003920:	cfc080e7          	jalr	-772(ra) # 80003618 <iupdate>
    ip->valid = 0;
    80003924:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003928:	854a                	mv	a0,s2
    8000392a:	00001097          	auipc	ra,0x1
    8000392e:	ad8080e7          	jalr	-1320(ra) # 80004402 <releasesleep>
    acquire(&itable.lock);
    80003932:	0001c517          	auipc	a0,0x1c
    80003936:	aa650513          	addi	a0,a0,-1370 # 8001f3d8 <itable>
    8000393a:	ffffd097          	auipc	ra,0xffffd
    8000393e:	296080e7          	jalr	662(ra) # 80000bd0 <acquire>
    80003942:	b741                	j	800038c2 <iput+0x26>

0000000080003944 <iunlockput>:
{
    80003944:	1101                	addi	sp,sp,-32
    80003946:	ec06                	sd	ra,24(sp)
    80003948:	e822                	sd	s0,16(sp)
    8000394a:	e426                	sd	s1,8(sp)
    8000394c:	1000                	addi	s0,sp,32
    8000394e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003950:	00000097          	auipc	ra,0x0
    80003954:	e54080e7          	jalr	-428(ra) # 800037a4 <iunlock>
  iput(ip);
    80003958:	8526                	mv	a0,s1
    8000395a:	00000097          	auipc	ra,0x0
    8000395e:	f42080e7          	jalr	-190(ra) # 8000389c <iput>
}
    80003962:	60e2                	ld	ra,24(sp)
    80003964:	6442                	ld	s0,16(sp)
    80003966:	64a2                	ld	s1,8(sp)
    80003968:	6105                	addi	sp,sp,32
    8000396a:	8082                	ret

000000008000396c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000396c:	1141                	addi	sp,sp,-16
    8000396e:	e422                	sd	s0,8(sp)
    80003970:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003972:	411c                	lw	a5,0(a0)
    80003974:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003976:	415c                	lw	a5,4(a0)
    80003978:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000397a:	04451783          	lh	a5,68(a0)
    8000397e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003982:	04a51783          	lh	a5,74(a0)
    80003986:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000398a:	04c56783          	lwu	a5,76(a0)
    8000398e:	e99c                	sd	a5,16(a1)
}
    80003990:	6422                	ld	s0,8(sp)
    80003992:	0141                	addi	sp,sp,16
    80003994:	8082                	ret

0000000080003996 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003996:	457c                	lw	a5,76(a0)
    80003998:	0ed7e963          	bltu	a5,a3,80003a8a <readi+0xf4>
{
    8000399c:	7159                	addi	sp,sp,-112
    8000399e:	f486                	sd	ra,104(sp)
    800039a0:	f0a2                	sd	s0,96(sp)
    800039a2:	eca6                	sd	s1,88(sp)
    800039a4:	e8ca                	sd	s2,80(sp)
    800039a6:	e4ce                	sd	s3,72(sp)
    800039a8:	e0d2                	sd	s4,64(sp)
    800039aa:	fc56                	sd	s5,56(sp)
    800039ac:	f85a                	sd	s6,48(sp)
    800039ae:	f45e                	sd	s7,40(sp)
    800039b0:	f062                	sd	s8,32(sp)
    800039b2:	ec66                	sd	s9,24(sp)
    800039b4:	e86a                	sd	s10,16(sp)
    800039b6:	e46e                	sd	s11,8(sp)
    800039b8:	1880                	addi	s0,sp,112
    800039ba:	8b2a                	mv	s6,a0
    800039bc:	8bae                	mv	s7,a1
    800039be:	8a32                	mv	s4,a2
    800039c0:	84b6                	mv	s1,a3
    800039c2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800039c4:	9f35                	addw	a4,a4,a3
    return 0;
    800039c6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039c8:	0ad76063          	bltu	a4,a3,80003a68 <readi+0xd2>
  if(off + n > ip->size)
    800039cc:	00e7f463          	bgeu	a5,a4,800039d4 <readi+0x3e>
    n = ip->size - off;
    800039d0:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039d4:	0a0a8963          	beqz	s5,80003a86 <readi+0xf0>
    800039d8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039da:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039de:	5c7d                	li	s8,-1
    800039e0:	a82d                	j	80003a1a <readi+0x84>
    800039e2:	020d1d93          	slli	s11,s10,0x20
    800039e6:	020ddd93          	srli	s11,s11,0x20
    800039ea:	05890793          	addi	a5,s2,88
    800039ee:	86ee                	mv	a3,s11
    800039f0:	963e                	add	a2,a2,a5
    800039f2:	85d2                	mv	a1,s4
    800039f4:	855e                	mv	a0,s7
    800039f6:	fffff097          	auipc	ra,0xfffff
    800039fa:	b24080e7          	jalr	-1244(ra) # 8000251a <either_copyout>
    800039fe:	05850d63          	beq	a0,s8,80003a58 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a02:	854a                	mv	a0,s2
    80003a04:	fffff097          	auipc	ra,0xfffff
    80003a08:	5f8080e7          	jalr	1528(ra) # 80002ffc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a0c:	013d09bb          	addw	s3,s10,s3
    80003a10:	009d04bb          	addw	s1,s10,s1
    80003a14:	9a6e                	add	s4,s4,s11
    80003a16:	0559f763          	bgeu	s3,s5,80003a64 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003a1a:	00a4d59b          	srliw	a1,s1,0xa
    80003a1e:	855a                	mv	a0,s6
    80003a20:	00000097          	auipc	ra,0x0
    80003a24:	962080e7          	jalr	-1694(ra) # 80003382 <bmap>
    80003a28:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a2c:	cd85                	beqz	a1,80003a64 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a2e:	000b2503          	lw	a0,0(s6)
    80003a32:	fffff097          	auipc	ra,0xfffff
    80003a36:	49a080e7          	jalr	1178(ra) # 80002ecc <bread>
    80003a3a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a3c:	3ff4f613          	andi	a2,s1,1023
    80003a40:	40cc87bb          	subw	a5,s9,a2
    80003a44:	413a873b          	subw	a4,s5,s3
    80003a48:	8d3e                	mv	s10,a5
    80003a4a:	2781                	sext.w	a5,a5
    80003a4c:	0007069b          	sext.w	a3,a4
    80003a50:	f8f6f9e3          	bgeu	a3,a5,800039e2 <readi+0x4c>
    80003a54:	8d3a                	mv	s10,a4
    80003a56:	b771                	j	800039e2 <readi+0x4c>
      brelse(bp);
    80003a58:	854a                	mv	a0,s2
    80003a5a:	fffff097          	auipc	ra,0xfffff
    80003a5e:	5a2080e7          	jalr	1442(ra) # 80002ffc <brelse>
      tot = -1;
    80003a62:	59fd                	li	s3,-1
  }
  return tot;
    80003a64:	0009851b          	sext.w	a0,s3
}
    80003a68:	70a6                	ld	ra,104(sp)
    80003a6a:	7406                	ld	s0,96(sp)
    80003a6c:	64e6                	ld	s1,88(sp)
    80003a6e:	6946                	ld	s2,80(sp)
    80003a70:	69a6                	ld	s3,72(sp)
    80003a72:	6a06                	ld	s4,64(sp)
    80003a74:	7ae2                	ld	s5,56(sp)
    80003a76:	7b42                	ld	s6,48(sp)
    80003a78:	7ba2                	ld	s7,40(sp)
    80003a7a:	7c02                	ld	s8,32(sp)
    80003a7c:	6ce2                	ld	s9,24(sp)
    80003a7e:	6d42                	ld	s10,16(sp)
    80003a80:	6da2                	ld	s11,8(sp)
    80003a82:	6165                	addi	sp,sp,112
    80003a84:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a86:	89d6                	mv	s3,s5
    80003a88:	bff1                	j	80003a64 <readi+0xce>
    return 0;
    80003a8a:	4501                	li	a0,0
}
    80003a8c:	8082                	ret

0000000080003a8e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a8e:	457c                	lw	a5,76(a0)
    80003a90:	10d7e863          	bltu	a5,a3,80003ba0 <writei+0x112>
{
    80003a94:	7159                	addi	sp,sp,-112
    80003a96:	f486                	sd	ra,104(sp)
    80003a98:	f0a2                	sd	s0,96(sp)
    80003a9a:	eca6                	sd	s1,88(sp)
    80003a9c:	e8ca                	sd	s2,80(sp)
    80003a9e:	e4ce                	sd	s3,72(sp)
    80003aa0:	e0d2                	sd	s4,64(sp)
    80003aa2:	fc56                	sd	s5,56(sp)
    80003aa4:	f85a                	sd	s6,48(sp)
    80003aa6:	f45e                	sd	s7,40(sp)
    80003aa8:	f062                	sd	s8,32(sp)
    80003aaa:	ec66                	sd	s9,24(sp)
    80003aac:	e86a                	sd	s10,16(sp)
    80003aae:	e46e                	sd	s11,8(sp)
    80003ab0:	1880                	addi	s0,sp,112
    80003ab2:	8aaa                	mv	s5,a0
    80003ab4:	8bae                	mv	s7,a1
    80003ab6:	8a32                	mv	s4,a2
    80003ab8:	8936                	mv	s2,a3
    80003aba:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003abc:	00e687bb          	addw	a5,a3,a4
    80003ac0:	0ed7e263          	bltu	a5,a3,80003ba4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ac4:	00043737          	lui	a4,0x43
    80003ac8:	0ef76063          	bltu	a4,a5,80003ba8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003acc:	0c0b0863          	beqz	s6,80003b9c <writei+0x10e>
    80003ad0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ad2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ad6:	5c7d                	li	s8,-1
    80003ad8:	a091                	j	80003b1c <writei+0x8e>
    80003ada:	020d1d93          	slli	s11,s10,0x20
    80003ade:	020ddd93          	srli	s11,s11,0x20
    80003ae2:	05848793          	addi	a5,s1,88
    80003ae6:	86ee                	mv	a3,s11
    80003ae8:	8652                	mv	a2,s4
    80003aea:	85de                	mv	a1,s7
    80003aec:	953e                	add	a0,a0,a5
    80003aee:	fffff097          	auipc	ra,0xfffff
    80003af2:	a82080e7          	jalr	-1406(ra) # 80002570 <either_copyin>
    80003af6:	07850263          	beq	a0,s8,80003b5a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003afa:	8526                	mv	a0,s1
    80003afc:	00000097          	auipc	ra,0x0
    80003b00:	790080e7          	jalr	1936(ra) # 8000428c <log_write>
    brelse(bp);
    80003b04:	8526                	mv	a0,s1
    80003b06:	fffff097          	auipc	ra,0xfffff
    80003b0a:	4f6080e7          	jalr	1270(ra) # 80002ffc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b0e:	013d09bb          	addw	s3,s10,s3
    80003b12:	012d093b          	addw	s2,s10,s2
    80003b16:	9a6e                	add	s4,s4,s11
    80003b18:	0569f663          	bgeu	s3,s6,80003b64 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003b1c:	00a9559b          	srliw	a1,s2,0xa
    80003b20:	8556                	mv	a0,s5
    80003b22:	00000097          	auipc	ra,0x0
    80003b26:	860080e7          	jalr	-1952(ra) # 80003382 <bmap>
    80003b2a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b2e:	c99d                	beqz	a1,80003b64 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b30:	000aa503          	lw	a0,0(s5)
    80003b34:	fffff097          	auipc	ra,0xfffff
    80003b38:	398080e7          	jalr	920(ra) # 80002ecc <bread>
    80003b3c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b3e:	3ff97513          	andi	a0,s2,1023
    80003b42:	40ac87bb          	subw	a5,s9,a0
    80003b46:	413b073b          	subw	a4,s6,s3
    80003b4a:	8d3e                	mv	s10,a5
    80003b4c:	2781                	sext.w	a5,a5
    80003b4e:	0007069b          	sext.w	a3,a4
    80003b52:	f8f6f4e3          	bgeu	a3,a5,80003ada <writei+0x4c>
    80003b56:	8d3a                	mv	s10,a4
    80003b58:	b749                	j	80003ada <writei+0x4c>
      brelse(bp);
    80003b5a:	8526                	mv	a0,s1
    80003b5c:	fffff097          	auipc	ra,0xfffff
    80003b60:	4a0080e7          	jalr	1184(ra) # 80002ffc <brelse>
  }

  if(off > ip->size)
    80003b64:	04caa783          	lw	a5,76(s5)
    80003b68:	0127f463          	bgeu	a5,s2,80003b70 <writei+0xe2>
    ip->size = off;
    80003b6c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b70:	8556                	mv	a0,s5
    80003b72:	00000097          	auipc	ra,0x0
    80003b76:	aa6080e7          	jalr	-1370(ra) # 80003618 <iupdate>

  return tot;
    80003b7a:	0009851b          	sext.w	a0,s3
}
    80003b7e:	70a6                	ld	ra,104(sp)
    80003b80:	7406                	ld	s0,96(sp)
    80003b82:	64e6                	ld	s1,88(sp)
    80003b84:	6946                	ld	s2,80(sp)
    80003b86:	69a6                	ld	s3,72(sp)
    80003b88:	6a06                	ld	s4,64(sp)
    80003b8a:	7ae2                	ld	s5,56(sp)
    80003b8c:	7b42                	ld	s6,48(sp)
    80003b8e:	7ba2                	ld	s7,40(sp)
    80003b90:	7c02                	ld	s8,32(sp)
    80003b92:	6ce2                	ld	s9,24(sp)
    80003b94:	6d42                	ld	s10,16(sp)
    80003b96:	6da2                	ld	s11,8(sp)
    80003b98:	6165                	addi	sp,sp,112
    80003b9a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b9c:	89da                	mv	s3,s6
    80003b9e:	bfc9                	j	80003b70 <writei+0xe2>
    return -1;
    80003ba0:	557d                	li	a0,-1
}
    80003ba2:	8082                	ret
    return -1;
    80003ba4:	557d                	li	a0,-1
    80003ba6:	bfe1                	j	80003b7e <writei+0xf0>
    return -1;
    80003ba8:	557d                	li	a0,-1
    80003baa:	bfd1                	j	80003b7e <writei+0xf0>

0000000080003bac <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bac:	1141                	addi	sp,sp,-16
    80003bae:	e406                	sd	ra,8(sp)
    80003bb0:	e022                	sd	s0,0(sp)
    80003bb2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bb4:	4639                	li	a2,14
    80003bb6:	ffffd097          	auipc	ra,0xffffd
    80003bba:	1e6080e7          	jalr	486(ra) # 80000d9c <strncmp>
}
    80003bbe:	60a2                	ld	ra,8(sp)
    80003bc0:	6402                	ld	s0,0(sp)
    80003bc2:	0141                	addi	sp,sp,16
    80003bc4:	8082                	ret

0000000080003bc6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bc6:	7139                	addi	sp,sp,-64
    80003bc8:	fc06                	sd	ra,56(sp)
    80003bca:	f822                	sd	s0,48(sp)
    80003bcc:	f426                	sd	s1,40(sp)
    80003bce:	f04a                	sd	s2,32(sp)
    80003bd0:	ec4e                	sd	s3,24(sp)
    80003bd2:	e852                	sd	s4,16(sp)
    80003bd4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003bd6:	04451703          	lh	a4,68(a0)
    80003bda:	4785                	li	a5,1
    80003bdc:	00f71a63          	bne	a4,a5,80003bf0 <dirlookup+0x2a>
    80003be0:	892a                	mv	s2,a0
    80003be2:	89ae                	mv	s3,a1
    80003be4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003be6:	457c                	lw	a5,76(a0)
    80003be8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bea:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bec:	e79d                	bnez	a5,80003c1a <dirlookup+0x54>
    80003bee:	a8a5                	j	80003c66 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003bf0:	00005517          	auipc	a0,0x5
    80003bf4:	a1050513          	addi	a0,a0,-1520 # 80008600 <syscalls+0x1b8>
    80003bf8:	ffffd097          	auipc	ra,0xffffd
    80003bfc:	940080e7          	jalr	-1728(ra) # 80000538 <panic>
      panic("dirlookup read");
    80003c00:	00005517          	auipc	a0,0x5
    80003c04:	a1850513          	addi	a0,a0,-1512 # 80008618 <syscalls+0x1d0>
    80003c08:	ffffd097          	auipc	ra,0xffffd
    80003c0c:	930080e7          	jalr	-1744(ra) # 80000538 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c10:	24c1                	addiw	s1,s1,16
    80003c12:	04c92783          	lw	a5,76(s2)
    80003c16:	04f4f763          	bgeu	s1,a5,80003c64 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c1a:	4741                	li	a4,16
    80003c1c:	86a6                	mv	a3,s1
    80003c1e:	fc040613          	addi	a2,s0,-64
    80003c22:	4581                	li	a1,0
    80003c24:	854a                	mv	a0,s2
    80003c26:	00000097          	auipc	ra,0x0
    80003c2a:	d70080e7          	jalr	-656(ra) # 80003996 <readi>
    80003c2e:	47c1                	li	a5,16
    80003c30:	fcf518e3          	bne	a0,a5,80003c00 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c34:	fc045783          	lhu	a5,-64(s0)
    80003c38:	dfe1                	beqz	a5,80003c10 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c3a:	fc240593          	addi	a1,s0,-62
    80003c3e:	854e                	mv	a0,s3
    80003c40:	00000097          	auipc	ra,0x0
    80003c44:	f6c080e7          	jalr	-148(ra) # 80003bac <namecmp>
    80003c48:	f561                	bnez	a0,80003c10 <dirlookup+0x4a>
      if(poff)
    80003c4a:	000a0463          	beqz	s4,80003c52 <dirlookup+0x8c>
        *poff = off;
    80003c4e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c52:	fc045583          	lhu	a1,-64(s0)
    80003c56:	00092503          	lw	a0,0(s2)
    80003c5a:	fffff097          	auipc	ra,0xfffff
    80003c5e:	534080e7          	jalr	1332(ra) # 8000318e <iget>
    80003c62:	a011                	j	80003c66 <dirlookup+0xa0>
  return 0;
    80003c64:	4501                	li	a0,0
}
    80003c66:	70e2                	ld	ra,56(sp)
    80003c68:	7442                	ld	s0,48(sp)
    80003c6a:	74a2                	ld	s1,40(sp)
    80003c6c:	7902                	ld	s2,32(sp)
    80003c6e:	69e2                	ld	s3,24(sp)
    80003c70:	6a42                	ld	s4,16(sp)
    80003c72:	6121                	addi	sp,sp,64
    80003c74:	8082                	ret

0000000080003c76 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c76:	711d                	addi	sp,sp,-96
    80003c78:	ec86                	sd	ra,88(sp)
    80003c7a:	e8a2                	sd	s0,80(sp)
    80003c7c:	e4a6                	sd	s1,72(sp)
    80003c7e:	e0ca                	sd	s2,64(sp)
    80003c80:	fc4e                	sd	s3,56(sp)
    80003c82:	f852                	sd	s4,48(sp)
    80003c84:	f456                	sd	s5,40(sp)
    80003c86:	f05a                	sd	s6,32(sp)
    80003c88:	ec5e                	sd	s7,24(sp)
    80003c8a:	e862                	sd	s8,16(sp)
    80003c8c:	e466                	sd	s9,8(sp)
    80003c8e:	1080                	addi	s0,sp,96
    80003c90:	84aa                	mv	s1,a0
    80003c92:	8aae                	mv	s5,a1
    80003c94:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c96:	00054703          	lbu	a4,0(a0)
    80003c9a:	02f00793          	li	a5,47
    80003c9e:	02f70363          	beq	a4,a5,80003cc4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ca2:	ffffe097          	auipc	ra,0xffffe
    80003ca6:	d10080e7          	jalr	-752(ra) # 800019b2 <myproc>
    80003caa:	15053503          	ld	a0,336(a0)
    80003cae:	00000097          	auipc	ra,0x0
    80003cb2:	9f6080e7          	jalr	-1546(ra) # 800036a4 <idup>
    80003cb6:	89aa                	mv	s3,a0
  while(*path == '/')
    80003cb8:	02f00913          	li	s2,47
  len = path - s;
    80003cbc:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003cbe:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cc0:	4b85                	li	s7,1
    80003cc2:	a865                	j	80003d7a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003cc4:	4585                	li	a1,1
    80003cc6:	4505                	li	a0,1
    80003cc8:	fffff097          	auipc	ra,0xfffff
    80003ccc:	4c6080e7          	jalr	1222(ra) # 8000318e <iget>
    80003cd0:	89aa                	mv	s3,a0
    80003cd2:	b7dd                	j	80003cb8 <namex+0x42>
      iunlockput(ip);
    80003cd4:	854e                	mv	a0,s3
    80003cd6:	00000097          	auipc	ra,0x0
    80003cda:	c6e080e7          	jalr	-914(ra) # 80003944 <iunlockput>
      return 0;
    80003cde:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ce0:	854e                	mv	a0,s3
    80003ce2:	60e6                	ld	ra,88(sp)
    80003ce4:	6446                	ld	s0,80(sp)
    80003ce6:	64a6                	ld	s1,72(sp)
    80003ce8:	6906                	ld	s2,64(sp)
    80003cea:	79e2                	ld	s3,56(sp)
    80003cec:	7a42                	ld	s4,48(sp)
    80003cee:	7aa2                	ld	s5,40(sp)
    80003cf0:	7b02                	ld	s6,32(sp)
    80003cf2:	6be2                	ld	s7,24(sp)
    80003cf4:	6c42                	ld	s8,16(sp)
    80003cf6:	6ca2                	ld	s9,8(sp)
    80003cf8:	6125                	addi	sp,sp,96
    80003cfa:	8082                	ret
      iunlock(ip);
    80003cfc:	854e                	mv	a0,s3
    80003cfe:	00000097          	auipc	ra,0x0
    80003d02:	aa6080e7          	jalr	-1370(ra) # 800037a4 <iunlock>
      return ip;
    80003d06:	bfe9                	j	80003ce0 <namex+0x6a>
      iunlockput(ip);
    80003d08:	854e                	mv	a0,s3
    80003d0a:	00000097          	auipc	ra,0x0
    80003d0e:	c3a080e7          	jalr	-966(ra) # 80003944 <iunlockput>
      return 0;
    80003d12:	89e6                	mv	s3,s9
    80003d14:	b7f1                	j	80003ce0 <namex+0x6a>
  len = path - s;
    80003d16:	40b48633          	sub	a2,s1,a1
    80003d1a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d1e:	099c5463          	bge	s8,s9,80003da6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d22:	4639                	li	a2,14
    80003d24:	8552                	mv	a0,s4
    80003d26:	ffffd097          	auipc	ra,0xffffd
    80003d2a:	002080e7          	jalr	2(ra) # 80000d28 <memmove>
  while(*path == '/')
    80003d2e:	0004c783          	lbu	a5,0(s1)
    80003d32:	01279763          	bne	a5,s2,80003d40 <namex+0xca>
    path++;
    80003d36:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d38:	0004c783          	lbu	a5,0(s1)
    80003d3c:	ff278de3          	beq	a5,s2,80003d36 <namex+0xc0>
    ilock(ip);
    80003d40:	854e                	mv	a0,s3
    80003d42:	00000097          	auipc	ra,0x0
    80003d46:	9a0080e7          	jalr	-1632(ra) # 800036e2 <ilock>
    if(ip->type != T_DIR){
    80003d4a:	04499783          	lh	a5,68(s3)
    80003d4e:	f97793e3          	bne	a5,s7,80003cd4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d52:	000a8563          	beqz	s5,80003d5c <namex+0xe6>
    80003d56:	0004c783          	lbu	a5,0(s1)
    80003d5a:	d3cd                	beqz	a5,80003cfc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d5c:	865a                	mv	a2,s6
    80003d5e:	85d2                	mv	a1,s4
    80003d60:	854e                	mv	a0,s3
    80003d62:	00000097          	auipc	ra,0x0
    80003d66:	e64080e7          	jalr	-412(ra) # 80003bc6 <dirlookup>
    80003d6a:	8caa                	mv	s9,a0
    80003d6c:	dd51                	beqz	a0,80003d08 <namex+0x92>
    iunlockput(ip);
    80003d6e:	854e                	mv	a0,s3
    80003d70:	00000097          	auipc	ra,0x0
    80003d74:	bd4080e7          	jalr	-1068(ra) # 80003944 <iunlockput>
    ip = next;
    80003d78:	89e6                	mv	s3,s9
  while(*path == '/')
    80003d7a:	0004c783          	lbu	a5,0(s1)
    80003d7e:	05279763          	bne	a5,s2,80003dcc <namex+0x156>
    path++;
    80003d82:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d84:	0004c783          	lbu	a5,0(s1)
    80003d88:	ff278de3          	beq	a5,s2,80003d82 <namex+0x10c>
  if(*path == 0)
    80003d8c:	c79d                	beqz	a5,80003dba <namex+0x144>
    path++;
    80003d8e:	85a6                	mv	a1,s1
  len = path - s;
    80003d90:	8cda                	mv	s9,s6
    80003d92:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003d94:	01278963          	beq	a5,s2,80003da6 <namex+0x130>
    80003d98:	dfbd                	beqz	a5,80003d16 <namex+0xa0>
    path++;
    80003d9a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003d9c:	0004c783          	lbu	a5,0(s1)
    80003da0:	ff279ce3          	bne	a5,s2,80003d98 <namex+0x122>
    80003da4:	bf8d                	j	80003d16 <namex+0xa0>
    memmove(name, s, len);
    80003da6:	2601                	sext.w	a2,a2
    80003da8:	8552                	mv	a0,s4
    80003daa:	ffffd097          	auipc	ra,0xffffd
    80003dae:	f7e080e7          	jalr	-130(ra) # 80000d28 <memmove>
    name[len] = 0;
    80003db2:	9cd2                	add	s9,s9,s4
    80003db4:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003db8:	bf9d                	j	80003d2e <namex+0xb8>
  if(nameiparent){
    80003dba:	f20a83e3          	beqz	s5,80003ce0 <namex+0x6a>
    iput(ip);
    80003dbe:	854e                	mv	a0,s3
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	adc080e7          	jalr	-1316(ra) # 8000389c <iput>
    return 0;
    80003dc8:	4981                	li	s3,0
    80003dca:	bf19                	j	80003ce0 <namex+0x6a>
  if(*path == 0)
    80003dcc:	d7fd                	beqz	a5,80003dba <namex+0x144>
  while(*path != '/' && *path != 0)
    80003dce:	0004c783          	lbu	a5,0(s1)
    80003dd2:	85a6                	mv	a1,s1
    80003dd4:	b7d1                	j	80003d98 <namex+0x122>

0000000080003dd6 <dirlink>:
{
    80003dd6:	7139                	addi	sp,sp,-64
    80003dd8:	fc06                	sd	ra,56(sp)
    80003dda:	f822                	sd	s0,48(sp)
    80003ddc:	f426                	sd	s1,40(sp)
    80003dde:	f04a                	sd	s2,32(sp)
    80003de0:	ec4e                	sd	s3,24(sp)
    80003de2:	e852                	sd	s4,16(sp)
    80003de4:	0080                	addi	s0,sp,64
    80003de6:	892a                	mv	s2,a0
    80003de8:	8a2e                	mv	s4,a1
    80003dea:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dec:	4601                	li	a2,0
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	dd8080e7          	jalr	-552(ra) # 80003bc6 <dirlookup>
    80003df6:	e93d                	bnez	a0,80003e6c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003df8:	04c92483          	lw	s1,76(s2)
    80003dfc:	c49d                	beqz	s1,80003e2a <dirlink+0x54>
    80003dfe:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e00:	4741                	li	a4,16
    80003e02:	86a6                	mv	a3,s1
    80003e04:	fc040613          	addi	a2,s0,-64
    80003e08:	4581                	li	a1,0
    80003e0a:	854a                	mv	a0,s2
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	b8a080e7          	jalr	-1142(ra) # 80003996 <readi>
    80003e14:	47c1                	li	a5,16
    80003e16:	06f51163          	bne	a0,a5,80003e78 <dirlink+0xa2>
    if(de.inum == 0)
    80003e1a:	fc045783          	lhu	a5,-64(s0)
    80003e1e:	c791                	beqz	a5,80003e2a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e20:	24c1                	addiw	s1,s1,16
    80003e22:	04c92783          	lw	a5,76(s2)
    80003e26:	fcf4ede3          	bltu	s1,a5,80003e00 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e2a:	4639                	li	a2,14
    80003e2c:	85d2                	mv	a1,s4
    80003e2e:	fc240513          	addi	a0,s0,-62
    80003e32:	ffffd097          	auipc	ra,0xffffd
    80003e36:	fa6080e7          	jalr	-90(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    80003e3a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e3e:	4741                	li	a4,16
    80003e40:	86a6                	mv	a3,s1
    80003e42:	fc040613          	addi	a2,s0,-64
    80003e46:	4581                	li	a1,0
    80003e48:	854a                	mv	a0,s2
    80003e4a:	00000097          	auipc	ra,0x0
    80003e4e:	c44080e7          	jalr	-956(ra) # 80003a8e <writei>
    80003e52:	872a                	mv	a4,a0
    80003e54:	47c1                	li	a5,16
  return 0;
    80003e56:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e58:	02f71863          	bne	a4,a5,80003e88 <dirlink+0xb2>
}
    80003e5c:	70e2                	ld	ra,56(sp)
    80003e5e:	7442                	ld	s0,48(sp)
    80003e60:	74a2                	ld	s1,40(sp)
    80003e62:	7902                	ld	s2,32(sp)
    80003e64:	69e2                	ld	s3,24(sp)
    80003e66:	6a42                	ld	s4,16(sp)
    80003e68:	6121                	addi	sp,sp,64
    80003e6a:	8082                	ret
    iput(ip);
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	a30080e7          	jalr	-1488(ra) # 8000389c <iput>
    return -1;
    80003e74:	557d                	li	a0,-1
    80003e76:	b7dd                	j	80003e5c <dirlink+0x86>
      panic("dirlink read");
    80003e78:	00004517          	auipc	a0,0x4
    80003e7c:	7b050513          	addi	a0,a0,1968 # 80008628 <syscalls+0x1e0>
    80003e80:	ffffc097          	auipc	ra,0xffffc
    80003e84:	6b8080e7          	jalr	1720(ra) # 80000538 <panic>
    panic("dirlink");
    80003e88:	00005517          	auipc	a0,0x5
    80003e8c:	8b050513          	addi	a0,a0,-1872 # 80008738 <syscalls+0x2f0>
    80003e90:	ffffc097          	auipc	ra,0xffffc
    80003e94:	6a8080e7          	jalr	1704(ra) # 80000538 <panic>

0000000080003e98 <namei>:

struct inode*
namei(char *path)
{
    80003e98:	1101                	addi	sp,sp,-32
    80003e9a:	ec06                	sd	ra,24(sp)
    80003e9c:	e822                	sd	s0,16(sp)
    80003e9e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ea0:	fe040613          	addi	a2,s0,-32
    80003ea4:	4581                	li	a1,0
    80003ea6:	00000097          	auipc	ra,0x0
    80003eaa:	dd0080e7          	jalr	-560(ra) # 80003c76 <namex>
}
    80003eae:	60e2                	ld	ra,24(sp)
    80003eb0:	6442                	ld	s0,16(sp)
    80003eb2:	6105                	addi	sp,sp,32
    80003eb4:	8082                	ret

0000000080003eb6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003eb6:	1141                	addi	sp,sp,-16
    80003eb8:	e406                	sd	ra,8(sp)
    80003eba:	e022                	sd	s0,0(sp)
    80003ebc:	0800                	addi	s0,sp,16
    80003ebe:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ec0:	4585                	li	a1,1
    80003ec2:	00000097          	auipc	ra,0x0
    80003ec6:	db4080e7          	jalr	-588(ra) # 80003c76 <namex>
}
    80003eca:	60a2                	ld	ra,8(sp)
    80003ecc:	6402                	ld	s0,0(sp)
    80003ece:	0141                	addi	sp,sp,16
    80003ed0:	8082                	ret

0000000080003ed2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ed2:	1101                	addi	sp,sp,-32
    80003ed4:	ec06                	sd	ra,24(sp)
    80003ed6:	e822                	sd	s0,16(sp)
    80003ed8:	e426                	sd	s1,8(sp)
    80003eda:	e04a                	sd	s2,0(sp)
    80003edc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ede:	0001d917          	auipc	s2,0x1d
    80003ee2:	fa290913          	addi	s2,s2,-94 # 80020e80 <log>
    80003ee6:	01892583          	lw	a1,24(s2)
    80003eea:	02892503          	lw	a0,40(s2)
    80003eee:	fffff097          	auipc	ra,0xfffff
    80003ef2:	fde080e7          	jalr	-34(ra) # 80002ecc <bread>
    80003ef6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ef8:	02c92683          	lw	a3,44(s2)
    80003efc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003efe:	02d05763          	blez	a3,80003f2c <write_head+0x5a>
    80003f02:	0001d797          	auipc	a5,0x1d
    80003f06:	fae78793          	addi	a5,a5,-82 # 80020eb0 <log+0x30>
    80003f0a:	05c50713          	addi	a4,a0,92
    80003f0e:	36fd                	addiw	a3,a3,-1
    80003f10:	1682                	slli	a3,a3,0x20
    80003f12:	9281                	srli	a3,a3,0x20
    80003f14:	068a                	slli	a3,a3,0x2
    80003f16:	0001d617          	auipc	a2,0x1d
    80003f1a:	f9e60613          	addi	a2,a2,-98 # 80020eb4 <log+0x34>
    80003f1e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f20:	4390                	lw	a2,0(a5)
    80003f22:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f24:	0791                	addi	a5,a5,4
    80003f26:	0711                	addi	a4,a4,4
    80003f28:	fed79ce3          	bne	a5,a3,80003f20 <write_head+0x4e>
  }
  bwrite(buf);
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	fffff097          	auipc	ra,0xfffff
    80003f32:	090080e7          	jalr	144(ra) # 80002fbe <bwrite>
  brelse(buf);
    80003f36:	8526                	mv	a0,s1
    80003f38:	fffff097          	auipc	ra,0xfffff
    80003f3c:	0c4080e7          	jalr	196(ra) # 80002ffc <brelse>
}
    80003f40:	60e2                	ld	ra,24(sp)
    80003f42:	6442                	ld	s0,16(sp)
    80003f44:	64a2                	ld	s1,8(sp)
    80003f46:	6902                	ld	s2,0(sp)
    80003f48:	6105                	addi	sp,sp,32
    80003f4a:	8082                	ret

0000000080003f4c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f4c:	0001d797          	auipc	a5,0x1d
    80003f50:	f607a783          	lw	a5,-160(a5) # 80020eac <log+0x2c>
    80003f54:	0af05d63          	blez	a5,8000400e <install_trans+0xc2>
{
    80003f58:	7139                	addi	sp,sp,-64
    80003f5a:	fc06                	sd	ra,56(sp)
    80003f5c:	f822                	sd	s0,48(sp)
    80003f5e:	f426                	sd	s1,40(sp)
    80003f60:	f04a                	sd	s2,32(sp)
    80003f62:	ec4e                	sd	s3,24(sp)
    80003f64:	e852                	sd	s4,16(sp)
    80003f66:	e456                	sd	s5,8(sp)
    80003f68:	e05a                	sd	s6,0(sp)
    80003f6a:	0080                	addi	s0,sp,64
    80003f6c:	8b2a                	mv	s6,a0
    80003f6e:	0001da97          	auipc	s5,0x1d
    80003f72:	f42a8a93          	addi	s5,s5,-190 # 80020eb0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f76:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f78:	0001d997          	auipc	s3,0x1d
    80003f7c:	f0898993          	addi	s3,s3,-248 # 80020e80 <log>
    80003f80:	a00d                	j	80003fa2 <install_trans+0x56>
    brelse(lbuf);
    80003f82:	854a                	mv	a0,s2
    80003f84:	fffff097          	auipc	ra,0xfffff
    80003f88:	078080e7          	jalr	120(ra) # 80002ffc <brelse>
    brelse(dbuf);
    80003f8c:	8526                	mv	a0,s1
    80003f8e:	fffff097          	auipc	ra,0xfffff
    80003f92:	06e080e7          	jalr	110(ra) # 80002ffc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f96:	2a05                	addiw	s4,s4,1
    80003f98:	0a91                	addi	s5,s5,4
    80003f9a:	02c9a783          	lw	a5,44(s3)
    80003f9e:	04fa5e63          	bge	s4,a5,80003ffa <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fa2:	0189a583          	lw	a1,24(s3)
    80003fa6:	014585bb          	addw	a1,a1,s4
    80003faa:	2585                	addiw	a1,a1,1
    80003fac:	0289a503          	lw	a0,40(s3)
    80003fb0:	fffff097          	auipc	ra,0xfffff
    80003fb4:	f1c080e7          	jalr	-228(ra) # 80002ecc <bread>
    80003fb8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fba:	000aa583          	lw	a1,0(s5)
    80003fbe:	0289a503          	lw	a0,40(s3)
    80003fc2:	fffff097          	auipc	ra,0xfffff
    80003fc6:	f0a080e7          	jalr	-246(ra) # 80002ecc <bread>
    80003fca:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fcc:	40000613          	li	a2,1024
    80003fd0:	05890593          	addi	a1,s2,88
    80003fd4:	05850513          	addi	a0,a0,88
    80003fd8:	ffffd097          	auipc	ra,0xffffd
    80003fdc:	d50080e7          	jalr	-688(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fe0:	8526                	mv	a0,s1
    80003fe2:	fffff097          	auipc	ra,0xfffff
    80003fe6:	fdc080e7          	jalr	-36(ra) # 80002fbe <bwrite>
    if(recovering == 0)
    80003fea:	f80b1ce3          	bnez	s6,80003f82 <install_trans+0x36>
      bunpin(dbuf);
    80003fee:	8526                	mv	a0,s1
    80003ff0:	fffff097          	auipc	ra,0xfffff
    80003ff4:	0e6080e7          	jalr	230(ra) # 800030d6 <bunpin>
    80003ff8:	b769                	j	80003f82 <install_trans+0x36>
}
    80003ffa:	70e2                	ld	ra,56(sp)
    80003ffc:	7442                	ld	s0,48(sp)
    80003ffe:	74a2                	ld	s1,40(sp)
    80004000:	7902                	ld	s2,32(sp)
    80004002:	69e2                	ld	s3,24(sp)
    80004004:	6a42                	ld	s4,16(sp)
    80004006:	6aa2                	ld	s5,8(sp)
    80004008:	6b02                	ld	s6,0(sp)
    8000400a:	6121                	addi	sp,sp,64
    8000400c:	8082                	ret
    8000400e:	8082                	ret

0000000080004010 <initlog>:
{
    80004010:	7179                	addi	sp,sp,-48
    80004012:	f406                	sd	ra,40(sp)
    80004014:	f022                	sd	s0,32(sp)
    80004016:	ec26                	sd	s1,24(sp)
    80004018:	e84a                	sd	s2,16(sp)
    8000401a:	e44e                	sd	s3,8(sp)
    8000401c:	1800                	addi	s0,sp,48
    8000401e:	892a                	mv	s2,a0
    80004020:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004022:	0001d497          	auipc	s1,0x1d
    80004026:	e5e48493          	addi	s1,s1,-418 # 80020e80 <log>
    8000402a:	00004597          	auipc	a1,0x4
    8000402e:	60e58593          	addi	a1,a1,1550 # 80008638 <syscalls+0x1f0>
    80004032:	8526                	mv	a0,s1
    80004034:	ffffd097          	auipc	ra,0xffffd
    80004038:	b0c080e7          	jalr	-1268(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    8000403c:	0149a583          	lw	a1,20(s3)
    80004040:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004042:	0109a783          	lw	a5,16(s3)
    80004046:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004048:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000404c:	854a                	mv	a0,s2
    8000404e:	fffff097          	auipc	ra,0xfffff
    80004052:	e7e080e7          	jalr	-386(ra) # 80002ecc <bread>
  log.lh.n = lh->n;
    80004056:	4d34                	lw	a3,88(a0)
    80004058:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000405a:	02d05563          	blez	a3,80004084 <initlog+0x74>
    8000405e:	05c50793          	addi	a5,a0,92
    80004062:	0001d717          	auipc	a4,0x1d
    80004066:	e4e70713          	addi	a4,a4,-434 # 80020eb0 <log+0x30>
    8000406a:	36fd                	addiw	a3,a3,-1
    8000406c:	1682                	slli	a3,a3,0x20
    8000406e:	9281                	srli	a3,a3,0x20
    80004070:	068a                	slli	a3,a3,0x2
    80004072:	06050613          	addi	a2,a0,96
    80004076:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004078:	4390                	lw	a2,0(a5)
    8000407a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000407c:	0791                	addi	a5,a5,4
    8000407e:	0711                	addi	a4,a4,4
    80004080:	fed79ce3          	bne	a5,a3,80004078 <initlog+0x68>
  brelse(buf);
    80004084:	fffff097          	auipc	ra,0xfffff
    80004088:	f78080e7          	jalr	-136(ra) # 80002ffc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000408c:	4505                	li	a0,1
    8000408e:	00000097          	auipc	ra,0x0
    80004092:	ebe080e7          	jalr	-322(ra) # 80003f4c <install_trans>
  log.lh.n = 0;
    80004096:	0001d797          	auipc	a5,0x1d
    8000409a:	e007ab23          	sw	zero,-490(a5) # 80020eac <log+0x2c>
  write_head(); // clear the log
    8000409e:	00000097          	auipc	ra,0x0
    800040a2:	e34080e7          	jalr	-460(ra) # 80003ed2 <write_head>
}
    800040a6:	70a2                	ld	ra,40(sp)
    800040a8:	7402                	ld	s0,32(sp)
    800040aa:	64e2                	ld	s1,24(sp)
    800040ac:	6942                	ld	s2,16(sp)
    800040ae:	69a2                	ld	s3,8(sp)
    800040b0:	6145                	addi	sp,sp,48
    800040b2:	8082                	ret

00000000800040b4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040b4:	1101                	addi	sp,sp,-32
    800040b6:	ec06                	sd	ra,24(sp)
    800040b8:	e822                	sd	s0,16(sp)
    800040ba:	e426                	sd	s1,8(sp)
    800040bc:	e04a                	sd	s2,0(sp)
    800040be:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040c0:	0001d517          	auipc	a0,0x1d
    800040c4:	dc050513          	addi	a0,a0,-576 # 80020e80 <log>
    800040c8:	ffffd097          	auipc	ra,0xffffd
    800040cc:	b08080e7          	jalr	-1272(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    800040d0:	0001d497          	auipc	s1,0x1d
    800040d4:	db048493          	addi	s1,s1,-592 # 80020e80 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040d8:	4979                	li	s2,30
    800040da:	a039                	j	800040e8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800040dc:	85a6                	mv	a1,s1
    800040de:	8526                	mv	a0,s1
    800040e0:	ffffe097          	auipc	ra,0xffffe
    800040e4:	096080e7          	jalr	150(ra) # 80002176 <sleep>
    if(log.committing){
    800040e8:	50dc                	lw	a5,36(s1)
    800040ea:	fbed                	bnez	a5,800040dc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040ec:	509c                	lw	a5,32(s1)
    800040ee:	0017871b          	addiw	a4,a5,1
    800040f2:	0007069b          	sext.w	a3,a4
    800040f6:	0027179b          	slliw	a5,a4,0x2
    800040fa:	9fb9                	addw	a5,a5,a4
    800040fc:	0017979b          	slliw	a5,a5,0x1
    80004100:	54d8                	lw	a4,44(s1)
    80004102:	9fb9                	addw	a5,a5,a4
    80004104:	00f95963          	bge	s2,a5,80004116 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004108:	85a6                	mv	a1,s1
    8000410a:	8526                	mv	a0,s1
    8000410c:	ffffe097          	auipc	ra,0xffffe
    80004110:	06a080e7          	jalr	106(ra) # 80002176 <sleep>
    80004114:	bfd1                	j	800040e8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004116:	0001d517          	auipc	a0,0x1d
    8000411a:	d6a50513          	addi	a0,a0,-662 # 80020e80 <log>
    8000411e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	b64080e7          	jalr	-1180(ra) # 80000c84 <release>
      break;
    }
  }
}
    80004128:	60e2                	ld	ra,24(sp)
    8000412a:	6442                	ld	s0,16(sp)
    8000412c:	64a2                	ld	s1,8(sp)
    8000412e:	6902                	ld	s2,0(sp)
    80004130:	6105                	addi	sp,sp,32
    80004132:	8082                	ret

0000000080004134 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004134:	7139                	addi	sp,sp,-64
    80004136:	fc06                	sd	ra,56(sp)
    80004138:	f822                	sd	s0,48(sp)
    8000413a:	f426                	sd	s1,40(sp)
    8000413c:	f04a                	sd	s2,32(sp)
    8000413e:	ec4e                	sd	s3,24(sp)
    80004140:	e852                	sd	s4,16(sp)
    80004142:	e456                	sd	s5,8(sp)
    80004144:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004146:	0001d497          	auipc	s1,0x1d
    8000414a:	d3a48493          	addi	s1,s1,-710 # 80020e80 <log>
    8000414e:	8526                	mv	a0,s1
    80004150:	ffffd097          	auipc	ra,0xffffd
    80004154:	a80080e7          	jalr	-1408(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    80004158:	509c                	lw	a5,32(s1)
    8000415a:	37fd                	addiw	a5,a5,-1
    8000415c:	0007891b          	sext.w	s2,a5
    80004160:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004162:	50dc                	lw	a5,36(s1)
    80004164:	e7b9                	bnez	a5,800041b2 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004166:	04091e63          	bnez	s2,800041c2 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000416a:	0001d497          	auipc	s1,0x1d
    8000416e:	d1648493          	addi	s1,s1,-746 # 80020e80 <log>
    80004172:	4785                	li	a5,1
    80004174:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004176:	8526                	mv	a0,s1
    80004178:	ffffd097          	auipc	ra,0xffffd
    8000417c:	b0c080e7          	jalr	-1268(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004180:	54dc                	lw	a5,44(s1)
    80004182:	06f04763          	bgtz	a5,800041f0 <end_op+0xbc>
    acquire(&log.lock);
    80004186:	0001d497          	auipc	s1,0x1d
    8000418a:	cfa48493          	addi	s1,s1,-774 # 80020e80 <log>
    8000418e:	8526                	mv	a0,s1
    80004190:	ffffd097          	auipc	ra,0xffffd
    80004194:	a40080e7          	jalr	-1472(ra) # 80000bd0 <acquire>
    log.committing = 0;
    80004198:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000419c:	8526                	mv	a0,s1
    8000419e:	ffffe097          	auipc	ra,0xffffe
    800041a2:	164080e7          	jalr	356(ra) # 80002302 <wakeup>
    release(&log.lock);
    800041a6:	8526                	mv	a0,s1
    800041a8:	ffffd097          	auipc	ra,0xffffd
    800041ac:	adc080e7          	jalr	-1316(ra) # 80000c84 <release>
}
    800041b0:	a03d                	j	800041de <end_op+0xaa>
    panic("log.committing");
    800041b2:	00004517          	auipc	a0,0x4
    800041b6:	48e50513          	addi	a0,a0,1166 # 80008640 <syscalls+0x1f8>
    800041ba:	ffffc097          	auipc	ra,0xffffc
    800041be:	37e080e7          	jalr	894(ra) # 80000538 <panic>
    wakeup(&log);
    800041c2:	0001d497          	auipc	s1,0x1d
    800041c6:	cbe48493          	addi	s1,s1,-834 # 80020e80 <log>
    800041ca:	8526                	mv	a0,s1
    800041cc:	ffffe097          	auipc	ra,0xffffe
    800041d0:	136080e7          	jalr	310(ra) # 80002302 <wakeup>
  release(&log.lock);
    800041d4:	8526                	mv	a0,s1
    800041d6:	ffffd097          	auipc	ra,0xffffd
    800041da:	aae080e7          	jalr	-1362(ra) # 80000c84 <release>
}
    800041de:	70e2                	ld	ra,56(sp)
    800041e0:	7442                	ld	s0,48(sp)
    800041e2:	74a2                	ld	s1,40(sp)
    800041e4:	7902                	ld	s2,32(sp)
    800041e6:	69e2                	ld	s3,24(sp)
    800041e8:	6a42                	ld	s4,16(sp)
    800041ea:	6aa2                	ld	s5,8(sp)
    800041ec:	6121                	addi	sp,sp,64
    800041ee:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f0:	0001da97          	auipc	s5,0x1d
    800041f4:	cc0a8a93          	addi	s5,s5,-832 # 80020eb0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041f8:	0001da17          	auipc	s4,0x1d
    800041fc:	c88a0a13          	addi	s4,s4,-888 # 80020e80 <log>
    80004200:	018a2583          	lw	a1,24(s4)
    80004204:	012585bb          	addw	a1,a1,s2
    80004208:	2585                	addiw	a1,a1,1
    8000420a:	028a2503          	lw	a0,40(s4)
    8000420e:	fffff097          	auipc	ra,0xfffff
    80004212:	cbe080e7          	jalr	-834(ra) # 80002ecc <bread>
    80004216:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004218:	000aa583          	lw	a1,0(s5)
    8000421c:	028a2503          	lw	a0,40(s4)
    80004220:	fffff097          	auipc	ra,0xfffff
    80004224:	cac080e7          	jalr	-852(ra) # 80002ecc <bread>
    80004228:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000422a:	40000613          	li	a2,1024
    8000422e:	05850593          	addi	a1,a0,88
    80004232:	05848513          	addi	a0,s1,88
    80004236:	ffffd097          	auipc	ra,0xffffd
    8000423a:	af2080e7          	jalr	-1294(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    8000423e:	8526                	mv	a0,s1
    80004240:	fffff097          	auipc	ra,0xfffff
    80004244:	d7e080e7          	jalr	-642(ra) # 80002fbe <bwrite>
    brelse(from);
    80004248:	854e                	mv	a0,s3
    8000424a:	fffff097          	auipc	ra,0xfffff
    8000424e:	db2080e7          	jalr	-590(ra) # 80002ffc <brelse>
    brelse(to);
    80004252:	8526                	mv	a0,s1
    80004254:	fffff097          	auipc	ra,0xfffff
    80004258:	da8080e7          	jalr	-600(ra) # 80002ffc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000425c:	2905                	addiw	s2,s2,1
    8000425e:	0a91                	addi	s5,s5,4
    80004260:	02ca2783          	lw	a5,44(s4)
    80004264:	f8f94ee3          	blt	s2,a5,80004200 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004268:	00000097          	auipc	ra,0x0
    8000426c:	c6a080e7          	jalr	-918(ra) # 80003ed2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004270:	4501                	li	a0,0
    80004272:	00000097          	auipc	ra,0x0
    80004276:	cda080e7          	jalr	-806(ra) # 80003f4c <install_trans>
    log.lh.n = 0;
    8000427a:	0001d797          	auipc	a5,0x1d
    8000427e:	c207a923          	sw	zero,-974(a5) # 80020eac <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004282:	00000097          	auipc	ra,0x0
    80004286:	c50080e7          	jalr	-944(ra) # 80003ed2 <write_head>
    8000428a:	bdf5                	j	80004186 <end_op+0x52>

000000008000428c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000428c:	1101                	addi	sp,sp,-32
    8000428e:	ec06                	sd	ra,24(sp)
    80004290:	e822                	sd	s0,16(sp)
    80004292:	e426                	sd	s1,8(sp)
    80004294:	e04a                	sd	s2,0(sp)
    80004296:	1000                	addi	s0,sp,32
    80004298:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000429a:	0001d917          	auipc	s2,0x1d
    8000429e:	be690913          	addi	s2,s2,-1050 # 80020e80 <log>
    800042a2:	854a                	mv	a0,s2
    800042a4:	ffffd097          	auipc	ra,0xffffd
    800042a8:	92c080e7          	jalr	-1748(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042ac:	02c92603          	lw	a2,44(s2)
    800042b0:	47f5                	li	a5,29
    800042b2:	06c7c563          	blt	a5,a2,8000431c <log_write+0x90>
    800042b6:	0001d797          	auipc	a5,0x1d
    800042ba:	be67a783          	lw	a5,-1050(a5) # 80020e9c <log+0x1c>
    800042be:	37fd                	addiw	a5,a5,-1
    800042c0:	04f65e63          	bge	a2,a5,8000431c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042c4:	0001d797          	auipc	a5,0x1d
    800042c8:	bdc7a783          	lw	a5,-1060(a5) # 80020ea0 <log+0x20>
    800042cc:	06f05063          	blez	a5,8000432c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042d0:	4781                	li	a5,0
    800042d2:	06c05563          	blez	a2,8000433c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042d6:	44cc                	lw	a1,12(s1)
    800042d8:	0001d717          	auipc	a4,0x1d
    800042dc:	bd870713          	addi	a4,a4,-1064 # 80020eb0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042e0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042e2:	4314                	lw	a3,0(a4)
    800042e4:	04b68c63          	beq	a3,a1,8000433c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042e8:	2785                	addiw	a5,a5,1
    800042ea:	0711                	addi	a4,a4,4
    800042ec:	fef61be3          	bne	a2,a5,800042e2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042f0:	0621                	addi	a2,a2,8
    800042f2:	060a                	slli	a2,a2,0x2
    800042f4:	0001d797          	auipc	a5,0x1d
    800042f8:	b8c78793          	addi	a5,a5,-1140 # 80020e80 <log>
    800042fc:	963e                	add	a2,a2,a5
    800042fe:	44dc                	lw	a5,12(s1)
    80004300:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004302:	8526                	mv	a0,s1
    80004304:	fffff097          	auipc	ra,0xfffff
    80004308:	d96080e7          	jalr	-618(ra) # 8000309a <bpin>
    log.lh.n++;
    8000430c:	0001d717          	auipc	a4,0x1d
    80004310:	b7470713          	addi	a4,a4,-1164 # 80020e80 <log>
    80004314:	575c                	lw	a5,44(a4)
    80004316:	2785                	addiw	a5,a5,1
    80004318:	d75c                	sw	a5,44(a4)
    8000431a:	a835                	j	80004356 <log_write+0xca>
    panic("too big a transaction");
    8000431c:	00004517          	auipc	a0,0x4
    80004320:	33450513          	addi	a0,a0,820 # 80008650 <syscalls+0x208>
    80004324:	ffffc097          	auipc	ra,0xffffc
    80004328:	214080e7          	jalr	532(ra) # 80000538 <panic>
    panic("log_write outside of trans");
    8000432c:	00004517          	auipc	a0,0x4
    80004330:	33c50513          	addi	a0,a0,828 # 80008668 <syscalls+0x220>
    80004334:	ffffc097          	auipc	ra,0xffffc
    80004338:	204080e7          	jalr	516(ra) # 80000538 <panic>
  log.lh.block[i] = b->blockno;
    8000433c:	00878713          	addi	a4,a5,8
    80004340:	00271693          	slli	a3,a4,0x2
    80004344:	0001d717          	auipc	a4,0x1d
    80004348:	b3c70713          	addi	a4,a4,-1220 # 80020e80 <log>
    8000434c:	9736                	add	a4,a4,a3
    8000434e:	44d4                	lw	a3,12(s1)
    80004350:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004352:	faf608e3          	beq	a2,a5,80004302 <log_write+0x76>
  }
  release(&log.lock);
    80004356:	0001d517          	auipc	a0,0x1d
    8000435a:	b2a50513          	addi	a0,a0,-1238 # 80020e80 <log>
    8000435e:	ffffd097          	auipc	ra,0xffffd
    80004362:	926080e7          	jalr	-1754(ra) # 80000c84 <release>
}
    80004366:	60e2                	ld	ra,24(sp)
    80004368:	6442                	ld	s0,16(sp)
    8000436a:	64a2                	ld	s1,8(sp)
    8000436c:	6902                	ld	s2,0(sp)
    8000436e:	6105                	addi	sp,sp,32
    80004370:	8082                	ret

0000000080004372 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004372:	1101                	addi	sp,sp,-32
    80004374:	ec06                	sd	ra,24(sp)
    80004376:	e822                	sd	s0,16(sp)
    80004378:	e426                	sd	s1,8(sp)
    8000437a:	e04a                	sd	s2,0(sp)
    8000437c:	1000                	addi	s0,sp,32
    8000437e:	84aa                	mv	s1,a0
    80004380:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004382:	00004597          	auipc	a1,0x4
    80004386:	30658593          	addi	a1,a1,774 # 80008688 <syscalls+0x240>
    8000438a:	0521                	addi	a0,a0,8
    8000438c:	ffffc097          	auipc	ra,0xffffc
    80004390:	7b4080e7          	jalr	1972(ra) # 80000b40 <initlock>
  lk->name = name;
    80004394:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004398:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000439c:	0204a423          	sw	zero,40(s1)
}
    800043a0:	60e2                	ld	ra,24(sp)
    800043a2:	6442                	ld	s0,16(sp)
    800043a4:	64a2                	ld	s1,8(sp)
    800043a6:	6902                	ld	s2,0(sp)
    800043a8:	6105                	addi	sp,sp,32
    800043aa:	8082                	ret

00000000800043ac <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043ac:	1101                	addi	sp,sp,-32
    800043ae:	ec06                	sd	ra,24(sp)
    800043b0:	e822                	sd	s0,16(sp)
    800043b2:	e426                	sd	s1,8(sp)
    800043b4:	e04a                	sd	s2,0(sp)
    800043b6:	1000                	addi	s0,sp,32
    800043b8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043ba:	00850913          	addi	s2,a0,8
    800043be:	854a                	mv	a0,s2
    800043c0:	ffffd097          	auipc	ra,0xffffd
    800043c4:	810080e7          	jalr	-2032(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    800043c8:	409c                	lw	a5,0(s1)
    800043ca:	cb89                	beqz	a5,800043dc <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043cc:	85ca                	mv	a1,s2
    800043ce:	8526                	mv	a0,s1
    800043d0:	ffffe097          	auipc	ra,0xffffe
    800043d4:	da6080e7          	jalr	-602(ra) # 80002176 <sleep>
  while (lk->locked) {
    800043d8:	409c                	lw	a5,0(s1)
    800043da:	fbed                	bnez	a5,800043cc <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043dc:	4785                	li	a5,1
    800043de:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043e0:	ffffd097          	auipc	ra,0xffffd
    800043e4:	5d2080e7          	jalr	1490(ra) # 800019b2 <myproc>
    800043e8:	591c                	lw	a5,48(a0)
    800043ea:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043ec:	854a                	mv	a0,s2
    800043ee:	ffffd097          	auipc	ra,0xffffd
    800043f2:	896080e7          	jalr	-1898(ra) # 80000c84 <release>
}
    800043f6:	60e2                	ld	ra,24(sp)
    800043f8:	6442                	ld	s0,16(sp)
    800043fa:	64a2                	ld	s1,8(sp)
    800043fc:	6902                	ld	s2,0(sp)
    800043fe:	6105                	addi	sp,sp,32
    80004400:	8082                	ret

0000000080004402 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004402:	1101                	addi	sp,sp,-32
    80004404:	ec06                	sd	ra,24(sp)
    80004406:	e822                	sd	s0,16(sp)
    80004408:	e426                	sd	s1,8(sp)
    8000440a:	e04a                	sd	s2,0(sp)
    8000440c:	1000                	addi	s0,sp,32
    8000440e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004410:	00850913          	addi	s2,a0,8
    80004414:	854a                	mv	a0,s2
    80004416:	ffffc097          	auipc	ra,0xffffc
    8000441a:	7ba080e7          	jalr	1978(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    8000441e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004422:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004426:	8526                	mv	a0,s1
    80004428:	ffffe097          	auipc	ra,0xffffe
    8000442c:	eda080e7          	jalr	-294(ra) # 80002302 <wakeup>
  release(&lk->lk);
    80004430:	854a                	mv	a0,s2
    80004432:	ffffd097          	auipc	ra,0xffffd
    80004436:	852080e7          	jalr	-1966(ra) # 80000c84 <release>
}
    8000443a:	60e2                	ld	ra,24(sp)
    8000443c:	6442                	ld	s0,16(sp)
    8000443e:	64a2                	ld	s1,8(sp)
    80004440:	6902                	ld	s2,0(sp)
    80004442:	6105                	addi	sp,sp,32
    80004444:	8082                	ret

0000000080004446 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004446:	7179                	addi	sp,sp,-48
    80004448:	f406                	sd	ra,40(sp)
    8000444a:	f022                	sd	s0,32(sp)
    8000444c:	ec26                	sd	s1,24(sp)
    8000444e:	e84a                	sd	s2,16(sp)
    80004450:	e44e                	sd	s3,8(sp)
    80004452:	1800                	addi	s0,sp,48
    80004454:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004456:	00850913          	addi	s2,a0,8
    8000445a:	854a                	mv	a0,s2
    8000445c:	ffffc097          	auipc	ra,0xffffc
    80004460:	774080e7          	jalr	1908(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004464:	409c                	lw	a5,0(s1)
    80004466:	ef99                	bnez	a5,80004484 <holdingsleep+0x3e>
    80004468:	4481                	li	s1,0
  release(&lk->lk);
    8000446a:	854a                	mv	a0,s2
    8000446c:	ffffd097          	auipc	ra,0xffffd
    80004470:	818080e7          	jalr	-2024(ra) # 80000c84 <release>
  return r;
}
    80004474:	8526                	mv	a0,s1
    80004476:	70a2                	ld	ra,40(sp)
    80004478:	7402                	ld	s0,32(sp)
    8000447a:	64e2                	ld	s1,24(sp)
    8000447c:	6942                	ld	s2,16(sp)
    8000447e:	69a2                	ld	s3,8(sp)
    80004480:	6145                	addi	sp,sp,48
    80004482:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004484:	0284a983          	lw	s3,40(s1)
    80004488:	ffffd097          	auipc	ra,0xffffd
    8000448c:	52a080e7          	jalr	1322(ra) # 800019b2 <myproc>
    80004490:	5904                	lw	s1,48(a0)
    80004492:	413484b3          	sub	s1,s1,s3
    80004496:	0014b493          	seqz	s1,s1
    8000449a:	bfc1                	j	8000446a <holdingsleep+0x24>

000000008000449c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000449c:	1141                	addi	sp,sp,-16
    8000449e:	e406                	sd	ra,8(sp)
    800044a0:	e022                	sd	s0,0(sp)
    800044a2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044a4:	00004597          	auipc	a1,0x4
    800044a8:	1f458593          	addi	a1,a1,500 # 80008698 <syscalls+0x250>
    800044ac:	0001d517          	auipc	a0,0x1d
    800044b0:	b1c50513          	addi	a0,a0,-1252 # 80020fc8 <ftable>
    800044b4:	ffffc097          	auipc	ra,0xffffc
    800044b8:	68c080e7          	jalr	1676(ra) # 80000b40 <initlock>
}
    800044bc:	60a2                	ld	ra,8(sp)
    800044be:	6402                	ld	s0,0(sp)
    800044c0:	0141                	addi	sp,sp,16
    800044c2:	8082                	ret

00000000800044c4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044c4:	1101                	addi	sp,sp,-32
    800044c6:	ec06                	sd	ra,24(sp)
    800044c8:	e822                	sd	s0,16(sp)
    800044ca:	e426                	sd	s1,8(sp)
    800044cc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044ce:	0001d517          	auipc	a0,0x1d
    800044d2:	afa50513          	addi	a0,a0,-1286 # 80020fc8 <ftable>
    800044d6:	ffffc097          	auipc	ra,0xffffc
    800044da:	6fa080e7          	jalr	1786(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044de:	0001d497          	auipc	s1,0x1d
    800044e2:	b0248493          	addi	s1,s1,-1278 # 80020fe0 <ftable+0x18>
    800044e6:	0001e717          	auipc	a4,0x1e
    800044ea:	a9a70713          	addi	a4,a4,-1382 # 80021f80 <disk>
    if(f->ref == 0){
    800044ee:	40dc                	lw	a5,4(s1)
    800044f0:	cf99                	beqz	a5,8000450e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044f2:	02848493          	addi	s1,s1,40
    800044f6:	fee49ce3          	bne	s1,a4,800044ee <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044fa:	0001d517          	auipc	a0,0x1d
    800044fe:	ace50513          	addi	a0,a0,-1330 # 80020fc8 <ftable>
    80004502:	ffffc097          	auipc	ra,0xffffc
    80004506:	782080e7          	jalr	1922(ra) # 80000c84 <release>
  return 0;
    8000450a:	4481                	li	s1,0
    8000450c:	a819                	j	80004522 <filealloc+0x5e>
      f->ref = 1;
    8000450e:	4785                	li	a5,1
    80004510:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004512:	0001d517          	auipc	a0,0x1d
    80004516:	ab650513          	addi	a0,a0,-1354 # 80020fc8 <ftable>
    8000451a:	ffffc097          	auipc	ra,0xffffc
    8000451e:	76a080e7          	jalr	1898(ra) # 80000c84 <release>
}
    80004522:	8526                	mv	a0,s1
    80004524:	60e2                	ld	ra,24(sp)
    80004526:	6442                	ld	s0,16(sp)
    80004528:	64a2                	ld	s1,8(sp)
    8000452a:	6105                	addi	sp,sp,32
    8000452c:	8082                	ret

000000008000452e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000452e:	1101                	addi	sp,sp,-32
    80004530:	ec06                	sd	ra,24(sp)
    80004532:	e822                	sd	s0,16(sp)
    80004534:	e426                	sd	s1,8(sp)
    80004536:	1000                	addi	s0,sp,32
    80004538:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000453a:	0001d517          	auipc	a0,0x1d
    8000453e:	a8e50513          	addi	a0,a0,-1394 # 80020fc8 <ftable>
    80004542:	ffffc097          	auipc	ra,0xffffc
    80004546:	68e080e7          	jalr	1678(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    8000454a:	40dc                	lw	a5,4(s1)
    8000454c:	02f05263          	blez	a5,80004570 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004550:	2785                	addiw	a5,a5,1
    80004552:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004554:	0001d517          	auipc	a0,0x1d
    80004558:	a7450513          	addi	a0,a0,-1420 # 80020fc8 <ftable>
    8000455c:	ffffc097          	auipc	ra,0xffffc
    80004560:	728080e7          	jalr	1832(ra) # 80000c84 <release>
  return f;
}
    80004564:	8526                	mv	a0,s1
    80004566:	60e2                	ld	ra,24(sp)
    80004568:	6442                	ld	s0,16(sp)
    8000456a:	64a2                	ld	s1,8(sp)
    8000456c:	6105                	addi	sp,sp,32
    8000456e:	8082                	ret
    panic("filedup");
    80004570:	00004517          	auipc	a0,0x4
    80004574:	13050513          	addi	a0,a0,304 # 800086a0 <syscalls+0x258>
    80004578:	ffffc097          	auipc	ra,0xffffc
    8000457c:	fc0080e7          	jalr	-64(ra) # 80000538 <panic>

0000000080004580 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004580:	7139                	addi	sp,sp,-64
    80004582:	fc06                	sd	ra,56(sp)
    80004584:	f822                	sd	s0,48(sp)
    80004586:	f426                	sd	s1,40(sp)
    80004588:	f04a                	sd	s2,32(sp)
    8000458a:	ec4e                	sd	s3,24(sp)
    8000458c:	e852                	sd	s4,16(sp)
    8000458e:	e456                	sd	s5,8(sp)
    80004590:	0080                	addi	s0,sp,64
    80004592:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004594:	0001d517          	auipc	a0,0x1d
    80004598:	a3450513          	addi	a0,a0,-1484 # 80020fc8 <ftable>
    8000459c:	ffffc097          	auipc	ra,0xffffc
    800045a0:	634080e7          	jalr	1588(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    800045a4:	40dc                	lw	a5,4(s1)
    800045a6:	06f05163          	blez	a5,80004608 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045aa:	37fd                	addiw	a5,a5,-1
    800045ac:	0007871b          	sext.w	a4,a5
    800045b0:	c0dc                	sw	a5,4(s1)
    800045b2:	06e04363          	bgtz	a4,80004618 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045b6:	0004a903          	lw	s2,0(s1)
    800045ba:	0094ca83          	lbu	s5,9(s1)
    800045be:	0104ba03          	ld	s4,16(s1)
    800045c2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045c6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045ca:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045ce:	0001d517          	auipc	a0,0x1d
    800045d2:	9fa50513          	addi	a0,a0,-1542 # 80020fc8 <ftable>
    800045d6:	ffffc097          	auipc	ra,0xffffc
    800045da:	6ae080e7          	jalr	1710(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    800045de:	4785                	li	a5,1
    800045e0:	04f90d63          	beq	s2,a5,8000463a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045e4:	3979                	addiw	s2,s2,-2
    800045e6:	4785                	li	a5,1
    800045e8:	0527e063          	bltu	a5,s2,80004628 <fileclose+0xa8>
    begin_op();
    800045ec:	00000097          	auipc	ra,0x0
    800045f0:	ac8080e7          	jalr	-1336(ra) # 800040b4 <begin_op>
    iput(ff.ip);
    800045f4:	854e                	mv	a0,s3
    800045f6:	fffff097          	auipc	ra,0xfffff
    800045fa:	2a6080e7          	jalr	678(ra) # 8000389c <iput>
    end_op();
    800045fe:	00000097          	auipc	ra,0x0
    80004602:	b36080e7          	jalr	-1226(ra) # 80004134 <end_op>
    80004606:	a00d                	j	80004628 <fileclose+0xa8>
    panic("fileclose");
    80004608:	00004517          	auipc	a0,0x4
    8000460c:	0a050513          	addi	a0,a0,160 # 800086a8 <syscalls+0x260>
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	f28080e7          	jalr	-216(ra) # 80000538 <panic>
    release(&ftable.lock);
    80004618:	0001d517          	auipc	a0,0x1d
    8000461c:	9b050513          	addi	a0,a0,-1616 # 80020fc8 <ftable>
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	664080e7          	jalr	1636(ra) # 80000c84 <release>
  }
}
    80004628:	70e2                	ld	ra,56(sp)
    8000462a:	7442                	ld	s0,48(sp)
    8000462c:	74a2                	ld	s1,40(sp)
    8000462e:	7902                	ld	s2,32(sp)
    80004630:	69e2                	ld	s3,24(sp)
    80004632:	6a42                	ld	s4,16(sp)
    80004634:	6aa2                	ld	s5,8(sp)
    80004636:	6121                	addi	sp,sp,64
    80004638:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000463a:	85d6                	mv	a1,s5
    8000463c:	8552                	mv	a0,s4
    8000463e:	00000097          	auipc	ra,0x0
    80004642:	34c080e7          	jalr	844(ra) # 8000498a <pipeclose>
    80004646:	b7cd                	j	80004628 <fileclose+0xa8>

0000000080004648 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004648:	715d                	addi	sp,sp,-80
    8000464a:	e486                	sd	ra,72(sp)
    8000464c:	e0a2                	sd	s0,64(sp)
    8000464e:	fc26                	sd	s1,56(sp)
    80004650:	f84a                	sd	s2,48(sp)
    80004652:	f44e                	sd	s3,40(sp)
    80004654:	0880                	addi	s0,sp,80
    80004656:	84aa                	mv	s1,a0
    80004658:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000465a:	ffffd097          	auipc	ra,0xffffd
    8000465e:	358080e7          	jalr	856(ra) # 800019b2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004662:	409c                	lw	a5,0(s1)
    80004664:	37f9                	addiw	a5,a5,-2
    80004666:	4705                	li	a4,1
    80004668:	04f76763          	bltu	a4,a5,800046b6 <filestat+0x6e>
    8000466c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000466e:	6c88                	ld	a0,24(s1)
    80004670:	fffff097          	auipc	ra,0xfffff
    80004674:	072080e7          	jalr	114(ra) # 800036e2 <ilock>
    stati(f->ip, &st);
    80004678:	fb840593          	addi	a1,s0,-72
    8000467c:	6c88                	ld	a0,24(s1)
    8000467e:	fffff097          	auipc	ra,0xfffff
    80004682:	2ee080e7          	jalr	750(ra) # 8000396c <stati>
    iunlock(f->ip);
    80004686:	6c88                	ld	a0,24(s1)
    80004688:	fffff097          	auipc	ra,0xfffff
    8000468c:	11c080e7          	jalr	284(ra) # 800037a4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004690:	46e1                	li	a3,24
    80004692:	fb840613          	addi	a2,s0,-72
    80004696:	85ce                	mv	a1,s3
    80004698:	05093503          	ld	a0,80(s2)
    8000469c:	ffffd097          	auipc	ra,0xffffd
    800046a0:	fba080e7          	jalr	-70(ra) # 80001656 <copyout>
    800046a4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046a8:	60a6                	ld	ra,72(sp)
    800046aa:	6406                	ld	s0,64(sp)
    800046ac:	74e2                	ld	s1,56(sp)
    800046ae:	7942                	ld	s2,48(sp)
    800046b0:	79a2                	ld	s3,40(sp)
    800046b2:	6161                	addi	sp,sp,80
    800046b4:	8082                	ret
  return -1;
    800046b6:	557d                	li	a0,-1
    800046b8:	bfc5                	j	800046a8 <filestat+0x60>

00000000800046ba <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046ba:	7179                	addi	sp,sp,-48
    800046bc:	f406                	sd	ra,40(sp)
    800046be:	f022                	sd	s0,32(sp)
    800046c0:	ec26                	sd	s1,24(sp)
    800046c2:	e84a                	sd	s2,16(sp)
    800046c4:	e44e                	sd	s3,8(sp)
    800046c6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046c8:	00854783          	lbu	a5,8(a0)
    800046cc:	c3d5                	beqz	a5,80004770 <fileread+0xb6>
    800046ce:	84aa                	mv	s1,a0
    800046d0:	89ae                	mv	s3,a1
    800046d2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046d4:	411c                	lw	a5,0(a0)
    800046d6:	4705                	li	a4,1
    800046d8:	04e78963          	beq	a5,a4,8000472a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046dc:	470d                	li	a4,3
    800046de:	04e78d63          	beq	a5,a4,80004738 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046e2:	4709                	li	a4,2
    800046e4:	06e79e63          	bne	a5,a4,80004760 <fileread+0xa6>
    ilock(f->ip);
    800046e8:	6d08                	ld	a0,24(a0)
    800046ea:	fffff097          	auipc	ra,0xfffff
    800046ee:	ff8080e7          	jalr	-8(ra) # 800036e2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046f2:	874a                	mv	a4,s2
    800046f4:	5094                	lw	a3,32(s1)
    800046f6:	864e                	mv	a2,s3
    800046f8:	4585                	li	a1,1
    800046fa:	6c88                	ld	a0,24(s1)
    800046fc:	fffff097          	auipc	ra,0xfffff
    80004700:	29a080e7          	jalr	666(ra) # 80003996 <readi>
    80004704:	892a                	mv	s2,a0
    80004706:	00a05563          	blez	a0,80004710 <fileread+0x56>
      f->off += r;
    8000470a:	509c                	lw	a5,32(s1)
    8000470c:	9fa9                	addw	a5,a5,a0
    8000470e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004710:	6c88                	ld	a0,24(s1)
    80004712:	fffff097          	auipc	ra,0xfffff
    80004716:	092080e7          	jalr	146(ra) # 800037a4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000471a:	854a                	mv	a0,s2
    8000471c:	70a2                	ld	ra,40(sp)
    8000471e:	7402                	ld	s0,32(sp)
    80004720:	64e2                	ld	s1,24(sp)
    80004722:	6942                	ld	s2,16(sp)
    80004724:	69a2                	ld	s3,8(sp)
    80004726:	6145                	addi	sp,sp,48
    80004728:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000472a:	6908                	ld	a0,16(a0)
    8000472c:	00000097          	auipc	ra,0x0
    80004730:	3c0080e7          	jalr	960(ra) # 80004aec <piperead>
    80004734:	892a                	mv	s2,a0
    80004736:	b7d5                	j	8000471a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004738:	02451783          	lh	a5,36(a0)
    8000473c:	03079693          	slli	a3,a5,0x30
    80004740:	92c1                	srli	a3,a3,0x30
    80004742:	4725                	li	a4,9
    80004744:	02d76863          	bltu	a4,a3,80004774 <fileread+0xba>
    80004748:	0792                	slli	a5,a5,0x4
    8000474a:	0001c717          	auipc	a4,0x1c
    8000474e:	7de70713          	addi	a4,a4,2014 # 80020f28 <devsw>
    80004752:	97ba                	add	a5,a5,a4
    80004754:	639c                	ld	a5,0(a5)
    80004756:	c38d                	beqz	a5,80004778 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004758:	4505                	li	a0,1
    8000475a:	9782                	jalr	a5
    8000475c:	892a                	mv	s2,a0
    8000475e:	bf75                	j	8000471a <fileread+0x60>
    panic("fileread");
    80004760:	00004517          	auipc	a0,0x4
    80004764:	f5850513          	addi	a0,a0,-168 # 800086b8 <syscalls+0x270>
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	dd0080e7          	jalr	-560(ra) # 80000538 <panic>
    return -1;
    80004770:	597d                	li	s2,-1
    80004772:	b765                	j	8000471a <fileread+0x60>
      return -1;
    80004774:	597d                	li	s2,-1
    80004776:	b755                	j	8000471a <fileread+0x60>
    80004778:	597d                	li	s2,-1
    8000477a:	b745                	j	8000471a <fileread+0x60>

000000008000477c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000477c:	715d                	addi	sp,sp,-80
    8000477e:	e486                	sd	ra,72(sp)
    80004780:	e0a2                	sd	s0,64(sp)
    80004782:	fc26                	sd	s1,56(sp)
    80004784:	f84a                	sd	s2,48(sp)
    80004786:	f44e                	sd	s3,40(sp)
    80004788:	f052                	sd	s4,32(sp)
    8000478a:	ec56                	sd	s5,24(sp)
    8000478c:	e85a                	sd	s6,16(sp)
    8000478e:	e45e                	sd	s7,8(sp)
    80004790:	e062                	sd	s8,0(sp)
    80004792:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004794:	00954783          	lbu	a5,9(a0)
    80004798:	10078663          	beqz	a5,800048a4 <filewrite+0x128>
    8000479c:	892a                	mv	s2,a0
    8000479e:	8aae                	mv	s5,a1
    800047a0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047a2:	411c                	lw	a5,0(a0)
    800047a4:	4705                	li	a4,1
    800047a6:	02e78263          	beq	a5,a4,800047ca <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047aa:	470d                	li	a4,3
    800047ac:	02e78663          	beq	a5,a4,800047d8 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047b0:	4709                	li	a4,2
    800047b2:	0ee79163          	bne	a5,a4,80004894 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047b6:	0ac05d63          	blez	a2,80004870 <filewrite+0xf4>
    int i = 0;
    800047ba:	4981                	li	s3,0
    800047bc:	6b05                	lui	s6,0x1
    800047be:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800047c2:	6b85                	lui	s7,0x1
    800047c4:	c00b8b9b          	addiw	s7,s7,-1024
    800047c8:	a861                	j	80004860 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800047ca:	6908                	ld	a0,16(a0)
    800047cc:	00000097          	auipc	ra,0x0
    800047d0:	22e080e7          	jalr	558(ra) # 800049fa <pipewrite>
    800047d4:	8a2a                	mv	s4,a0
    800047d6:	a045                	j	80004876 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047d8:	02451783          	lh	a5,36(a0)
    800047dc:	03079693          	slli	a3,a5,0x30
    800047e0:	92c1                	srli	a3,a3,0x30
    800047e2:	4725                	li	a4,9
    800047e4:	0cd76263          	bltu	a4,a3,800048a8 <filewrite+0x12c>
    800047e8:	0792                	slli	a5,a5,0x4
    800047ea:	0001c717          	auipc	a4,0x1c
    800047ee:	73e70713          	addi	a4,a4,1854 # 80020f28 <devsw>
    800047f2:	97ba                	add	a5,a5,a4
    800047f4:	679c                	ld	a5,8(a5)
    800047f6:	cbdd                	beqz	a5,800048ac <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800047f8:	4505                	li	a0,1
    800047fa:	9782                	jalr	a5
    800047fc:	8a2a                	mv	s4,a0
    800047fe:	a8a5                	j	80004876 <filewrite+0xfa>
    80004800:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004804:	00000097          	auipc	ra,0x0
    80004808:	8b0080e7          	jalr	-1872(ra) # 800040b4 <begin_op>
      ilock(f->ip);
    8000480c:	01893503          	ld	a0,24(s2)
    80004810:	fffff097          	auipc	ra,0xfffff
    80004814:	ed2080e7          	jalr	-302(ra) # 800036e2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004818:	8762                	mv	a4,s8
    8000481a:	02092683          	lw	a3,32(s2)
    8000481e:	01598633          	add	a2,s3,s5
    80004822:	4585                	li	a1,1
    80004824:	01893503          	ld	a0,24(s2)
    80004828:	fffff097          	auipc	ra,0xfffff
    8000482c:	266080e7          	jalr	614(ra) # 80003a8e <writei>
    80004830:	84aa                	mv	s1,a0
    80004832:	00a05763          	blez	a0,80004840 <filewrite+0xc4>
        f->off += r;
    80004836:	02092783          	lw	a5,32(s2)
    8000483a:	9fa9                	addw	a5,a5,a0
    8000483c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004840:	01893503          	ld	a0,24(s2)
    80004844:	fffff097          	auipc	ra,0xfffff
    80004848:	f60080e7          	jalr	-160(ra) # 800037a4 <iunlock>
      end_op();
    8000484c:	00000097          	auipc	ra,0x0
    80004850:	8e8080e7          	jalr	-1816(ra) # 80004134 <end_op>

      if(r != n1){
    80004854:	009c1f63          	bne	s8,s1,80004872 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004858:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000485c:	0149db63          	bge	s3,s4,80004872 <filewrite+0xf6>
      int n1 = n - i;
    80004860:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004864:	84be                	mv	s1,a5
    80004866:	2781                	sext.w	a5,a5
    80004868:	f8fb5ce3          	bge	s6,a5,80004800 <filewrite+0x84>
    8000486c:	84de                	mv	s1,s7
    8000486e:	bf49                	j	80004800 <filewrite+0x84>
    int i = 0;
    80004870:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004872:	013a1f63          	bne	s4,s3,80004890 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004876:	8552                	mv	a0,s4
    80004878:	60a6                	ld	ra,72(sp)
    8000487a:	6406                	ld	s0,64(sp)
    8000487c:	74e2                	ld	s1,56(sp)
    8000487e:	7942                	ld	s2,48(sp)
    80004880:	79a2                	ld	s3,40(sp)
    80004882:	7a02                	ld	s4,32(sp)
    80004884:	6ae2                	ld	s5,24(sp)
    80004886:	6b42                	ld	s6,16(sp)
    80004888:	6ba2                	ld	s7,8(sp)
    8000488a:	6c02                	ld	s8,0(sp)
    8000488c:	6161                	addi	sp,sp,80
    8000488e:	8082                	ret
    ret = (i == n ? n : -1);
    80004890:	5a7d                	li	s4,-1
    80004892:	b7d5                	j	80004876 <filewrite+0xfa>
    panic("filewrite");
    80004894:	00004517          	auipc	a0,0x4
    80004898:	e3450513          	addi	a0,a0,-460 # 800086c8 <syscalls+0x280>
    8000489c:	ffffc097          	auipc	ra,0xffffc
    800048a0:	c9c080e7          	jalr	-868(ra) # 80000538 <panic>
    return -1;
    800048a4:	5a7d                	li	s4,-1
    800048a6:	bfc1                	j	80004876 <filewrite+0xfa>
      return -1;
    800048a8:	5a7d                	li	s4,-1
    800048aa:	b7f1                	j	80004876 <filewrite+0xfa>
    800048ac:	5a7d                	li	s4,-1
    800048ae:	b7e1                	j	80004876 <filewrite+0xfa>

00000000800048b0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048b0:	7179                	addi	sp,sp,-48
    800048b2:	f406                	sd	ra,40(sp)
    800048b4:	f022                	sd	s0,32(sp)
    800048b6:	ec26                	sd	s1,24(sp)
    800048b8:	e84a                	sd	s2,16(sp)
    800048ba:	e44e                	sd	s3,8(sp)
    800048bc:	e052                	sd	s4,0(sp)
    800048be:	1800                	addi	s0,sp,48
    800048c0:	84aa                	mv	s1,a0
    800048c2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048c4:	0005b023          	sd	zero,0(a1)
    800048c8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048cc:	00000097          	auipc	ra,0x0
    800048d0:	bf8080e7          	jalr	-1032(ra) # 800044c4 <filealloc>
    800048d4:	e088                	sd	a0,0(s1)
    800048d6:	c551                	beqz	a0,80004962 <pipealloc+0xb2>
    800048d8:	00000097          	auipc	ra,0x0
    800048dc:	bec080e7          	jalr	-1044(ra) # 800044c4 <filealloc>
    800048e0:	00aa3023          	sd	a0,0(s4)
    800048e4:	c92d                	beqz	a0,80004956 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048e6:	ffffc097          	auipc	ra,0xffffc
    800048ea:	1fa080e7          	jalr	506(ra) # 80000ae0 <kalloc>
    800048ee:	892a                	mv	s2,a0
    800048f0:	c125                	beqz	a0,80004950 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048f2:	4985                	li	s3,1
    800048f4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048f8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048fc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004900:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004904:	00004597          	auipc	a1,0x4
    80004908:	dd458593          	addi	a1,a1,-556 # 800086d8 <syscalls+0x290>
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	234080e7          	jalr	564(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    80004914:	609c                	ld	a5,0(s1)
    80004916:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000491a:	609c                	ld	a5,0(s1)
    8000491c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004920:	609c                	ld	a5,0(s1)
    80004922:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004926:	609c                	ld	a5,0(s1)
    80004928:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000492c:	000a3783          	ld	a5,0(s4)
    80004930:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004934:	000a3783          	ld	a5,0(s4)
    80004938:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000493c:	000a3783          	ld	a5,0(s4)
    80004940:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004944:	000a3783          	ld	a5,0(s4)
    80004948:	0127b823          	sd	s2,16(a5)
  return 0;
    8000494c:	4501                	li	a0,0
    8000494e:	a025                	j	80004976 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004950:	6088                	ld	a0,0(s1)
    80004952:	e501                	bnez	a0,8000495a <pipealloc+0xaa>
    80004954:	a039                	j	80004962 <pipealloc+0xb2>
    80004956:	6088                	ld	a0,0(s1)
    80004958:	c51d                	beqz	a0,80004986 <pipealloc+0xd6>
    fileclose(*f0);
    8000495a:	00000097          	auipc	ra,0x0
    8000495e:	c26080e7          	jalr	-986(ra) # 80004580 <fileclose>
  if(*f1)
    80004962:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004966:	557d                	li	a0,-1
  if(*f1)
    80004968:	c799                	beqz	a5,80004976 <pipealloc+0xc6>
    fileclose(*f1);
    8000496a:	853e                	mv	a0,a5
    8000496c:	00000097          	auipc	ra,0x0
    80004970:	c14080e7          	jalr	-1004(ra) # 80004580 <fileclose>
  return -1;
    80004974:	557d                	li	a0,-1
}
    80004976:	70a2                	ld	ra,40(sp)
    80004978:	7402                	ld	s0,32(sp)
    8000497a:	64e2                	ld	s1,24(sp)
    8000497c:	6942                	ld	s2,16(sp)
    8000497e:	69a2                	ld	s3,8(sp)
    80004980:	6a02                	ld	s4,0(sp)
    80004982:	6145                	addi	sp,sp,48
    80004984:	8082                	ret
  return -1;
    80004986:	557d                	li	a0,-1
    80004988:	b7fd                	j	80004976 <pipealloc+0xc6>

000000008000498a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000498a:	1101                	addi	sp,sp,-32
    8000498c:	ec06                	sd	ra,24(sp)
    8000498e:	e822                	sd	s0,16(sp)
    80004990:	e426                	sd	s1,8(sp)
    80004992:	e04a                	sd	s2,0(sp)
    80004994:	1000                	addi	s0,sp,32
    80004996:	84aa                	mv	s1,a0
    80004998:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000499a:	ffffc097          	auipc	ra,0xffffc
    8000499e:	236080e7          	jalr	566(ra) # 80000bd0 <acquire>
  if(writable){
    800049a2:	02090d63          	beqz	s2,800049dc <pipeclose+0x52>
    pi->writeopen = 0;
    800049a6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049aa:	21848513          	addi	a0,s1,536
    800049ae:	ffffe097          	auipc	ra,0xffffe
    800049b2:	954080e7          	jalr	-1708(ra) # 80002302 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049b6:	2204b783          	ld	a5,544(s1)
    800049ba:	eb95                	bnez	a5,800049ee <pipeclose+0x64>
    release(&pi->lock);
    800049bc:	8526                	mv	a0,s1
    800049be:	ffffc097          	auipc	ra,0xffffc
    800049c2:	2c6080e7          	jalr	710(ra) # 80000c84 <release>
    kfree((char*)pi);
    800049c6:	8526                	mv	a0,s1
    800049c8:	ffffc097          	auipc	ra,0xffffc
    800049cc:	01c080e7          	jalr	28(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    800049d0:	60e2                	ld	ra,24(sp)
    800049d2:	6442                	ld	s0,16(sp)
    800049d4:	64a2                	ld	s1,8(sp)
    800049d6:	6902                	ld	s2,0(sp)
    800049d8:	6105                	addi	sp,sp,32
    800049da:	8082                	ret
    pi->readopen = 0;
    800049dc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049e0:	21c48513          	addi	a0,s1,540
    800049e4:	ffffe097          	auipc	ra,0xffffe
    800049e8:	91e080e7          	jalr	-1762(ra) # 80002302 <wakeup>
    800049ec:	b7e9                	j	800049b6 <pipeclose+0x2c>
    release(&pi->lock);
    800049ee:	8526                	mv	a0,s1
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	294080e7          	jalr	660(ra) # 80000c84 <release>
}
    800049f8:	bfe1                	j	800049d0 <pipeclose+0x46>

00000000800049fa <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049fa:	711d                	addi	sp,sp,-96
    800049fc:	ec86                	sd	ra,88(sp)
    800049fe:	e8a2                	sd	s0,80(sp)
    80004a00:	e4a6                	sd	s1,72(sp)
    80004a02:	e0ca                	sd	s2,64(sp)
    80004a04:	fc4e                	sd	s3,56(sp)
    80004a06:	f852                	sd	s4,48(sp)
    80004a08:	f456                	sd	s5,40(sp)
    80004a0a:	f05a                	sd	s6,32(sp)
    80004a0c:	ec5e                	sd	s7,24(sp)
    80004a0e:	e862                	sd	s8,16(sp)
    80004a10:	1080                	addi	s0,sp,96
    80004a12:	84aa                	mv	s1,a0
    80004a14:	8aae                	mv	s5,a1
    80004a16:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a18:	ffffd097          	auipc	ra,0xffffd
    80004a1c:	f9a080e7          	jalr	-102(ra) # 800019b2 <myproc>
    80004a20:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a22:	8526                	mv	a0,s1
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	1ac080e7          	jalr	428(ra) # 80000bd0 <acquire>
  while(i < n){
    80004a2c:	0b405363          	blez	s4,80004ad2 <pipewrite+0xd8>
  int i = 0;
    80004a30:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a32:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a34:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a38:	21c48b93          	addi	s7,s1,540
    80004a3c:	a089                	j	80004a7e <pipewrite+0x84>
      release(&pi->lock);
    80004a3e:	8526                	mv	a0,s1
    80004a40:	ffffc097          	auipc	ra,0xffffc
    80004a44:	244080e7          	jalr	580(ra) # 80000c84 <release>
      return -1;
    80004a48:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a4a:	854a                	mv	a0,s2
    80004a4c:	60e6                	ld	ra,88(sp)
    80004a4e:	6446                	ld	s0,80(sp)
    80004a50:	64a6                	ld	s1,72(sp)
    80004a52:	6906                	ld	s2,64(sp)
    80004a54:	79e2                	ld	s3,56(sp)
    80004a56:	7a42                	ld	s4,48(sp)
    80004a58:	7aa2                	ld	s5,40(sp)
    80004a5a:	7b02                	ld	s6,32(sp)
    80004a5c:	6be2                	ld	s7,24(sp)
    80004a5e:	6c42                	ld	s8,16(sp)
    80004a60:	6125                	addi	sp,sp,96
    80004a62:	8082                	ret
      wakeup(&pi->nread);
    80004a64:	8562                	mv	a0,s8
    80004a66:	ffffe097          	auipc	ra,0xffffe
    80004a6a:	89c080e7          	jalr	-1892(ra) # 80002302 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a6e:	85a6                	mv	a1,s1
    80004a70:	855e                	mv	a0,s7
    80004a72:	ffffd097          	auipc	ra,0xffffd
    80004a76:	704080e7          	jalr	1796(ra) # 80002176 <sleep>
  while(i < n){
    80004a7a:	05495d63          	bge	s2,s4,80004ad4 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004a7e:	2204a783          	lw	a5,544(s1)
    80004a82:	dfd5                	beqz	a5,80004a3e <pipewrite+0x44>
    80004a84:	0289a783          	lw	a5,40(s3)
    80004a88:	fbdd                	bnez	a5,80004a3e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a8a:	2184a783          	lw	a5,536(s1)
    80004a8e:	21c4a703          	lw	a4,540(s1)
    80004a92:	2007879b          	addiw	a5,a5,512
    80004a96:	fcf707e3          	beq	a4,a5,80004a64 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a9a:	4685                	li	a3,1
    80004a9c:	01590633          	add	a2,s2,s5
    80004aa0:	faf40593          	addi	a1,s0,-81
    80004aa4:	0509b503          	ld	a0,80(s3)
    80004aa8:	ffffd097          	auipc	ra,0xffffd
    80004aac:	c3a080e7          	jalr	-966(ra) # 800016e2 <copyin>
    80004ab0:	03650263          	beq	a0,s6,80004ad4 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ab4:	21c4a783          	lw	a5,540(s1)
    80004ab8:	0017871b          	addiw	a4,a5,1
    80004abc:	20e4ae23          	sw	a4,540(s1)
    80004ac0:	1ff7f793          	andi	a5,a5,511
    80004ac4:	97a6                	add	a5,a5,s1
    80004ac6:	faf44703          	lbu	a4,-81(s0)
    80004aca:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ace:	2905                	addiw	s2,s2,1
    80004ad0:	b76d                	j	80004a7a <pipewrite+0x80>
  int i = 0;
    80004ad2:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ad4:	21848513          	addi	a0,s1,536
    80004ad8:	ffffe097          	auipc	ra,0xffffe
    80004adc:	82a080e7          	jalr	-2006(ra) # 80002302 <wakeup>
  release(&pi->lock);
    80004ae0:	8526                	mv	a0,s1
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	1a2080e7          	jalr	418(ra) # 80000c84 <release>
  return i;
    80004aea:	b785                	j	80004a4a <pipewrite+0x50>

0000000080004aec <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004aec:	715d                	addi	sp,sp,-80
    80004aee:	e486                	sd	ra,72(sp)
    80004af0:	e0a2                	sd	s0,64(sp)
    80004af2:	fc26                	sd	s1,56(sp)
    80004af4:	f84a                	sd	s2,48(sp)
    80004af6:	f44e                	sd	s3,40(sp)
    80004af8:	f052                	sd	s4,32(sp)
    80004afa:	ec56                	sd	s5,24(sp)
    80004afc:	e85a                	sd	s6,16(sp)
    80004afe:	0880                	addi	s0,sp,80
    80004b00:	84aa                	mv	s1,a0
    80004b02:	892e                	mv	s2,a1
    80004b04:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b06:	ffffd097          	auipc	ra,0xffffd
    80004b0a:	eac080e7          	jalr	-340(ra) # 800019b2 <myproc>
    80004b0e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b10:	8526                	mv	a0,s1
    80004b12:	ffffc097          	auipc	ra,0xffffc
    80004b16:	0be080e7          	jalr	190(ra) # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b1a:	2184a703          	lw	a4,536(s1)
    80004b1e:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b22:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b26:	02f71463          	bne	a4,a5,80004b4e <piperead+0x62>
    80004b2a:	2244a783          	lw	a5,548(s1)
    80004b2e:	c385                	beqz	a5,80004b4e <piperead+0x62>
    if(pr->killed){
    80004b30:	028a2783          	lw	a5,40(s4)
    80004b34:	ebc1                	bnez	a5,80004bc4 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b36:	85a6                	mv	a1,s1
    80004b38:	854e                	mv	a0,s3
    80004b3a:	ffffd097          	auipc	ra,0xffffd
    80004b3e:	63c080e7          	jalr	1596(ra) # 80002176 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b42:	2184a703          	lw	a4,536(s1)
    80004b46:	21c4a783          	lw	a5,540(s1)
    80004b4a:	fef700e3          	beq	a4,a5,80004b2a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b4e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b50:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b52:	05505363          	blez	s5,80004b98 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004b56:	2184a783          	lw	a5,536(s1)
    80004b5a:	21c4a703          	lw	a4,540(s1)
    80004b5e:	02f70d63          	beq	a4,a5,80004b98 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b62:	0017871b          	addiw	a4,a5,1
    80004b66:	20e4ac23          	sw	a4,536(s1)
    80004b6a:	1ff7f793          	andi	a5,a5,511
    80004b6e:	97a6                	add	a5,a5,s1
    80004b70:	0187c783          	lbu	a5,24(a5)
    80004b74:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b78:	4685                	li	a3,1
    80004b7a:	fbf40613          	addi	a2,s0,-65
    80004b7e:	85ca                	mv	a1,s2
    80004b80:	050a3503          	ld	a0,80(s4)
    80004b84:	ffffd097          	auipc	ra,0xffffd
    80004b88:	ad2080e7          	jalr	-1326(ra) # 80001656 <copyout>
    80004b8c:	01650663          	beq	a0,s6,80004b98 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b90:	2985                	addiw	s3,s3,1
    80004b92:	0905                	addi	s2,s2,1
    80004b94:	fd3a91e3          	bne	s5,s3,80004b56 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b98:	21c48513          	addi	a0,s1,540
    80004b9c:	ffffd097          	auipc	ra,0xffffd
    80004ba0:	766080e7          	jalr	1894(ra) # 80002302 <wakeup>
  release(&pi->lock);
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	ffffc097          	auipc	ra,0xffffc
    80004baa:	0de080e7          	jalr	222(ra) # 80000c84 <release>
  return i;
}
    80004bae:	854e                	mv	a0,s3
    80004bb0:	60a6                	ld	ra,72(sp)
    80004bb2:	6406                	ld	s0,64(sp)
    80004bb4:	74e2                	ld	s1,56(sp)
    80004bb6:	7942                	ld	s2,48(sp)
    80004bb8:	79a2                	ld	s3,40(sp)
    80004bba:	7a02                	ld	s4,32(sp)
    80004bbc:	6ae2                	ld	s5,24(sp)
    80004bbe:	6b42                	ld	s6,16(sp)
    80004bc0:	6161                	addi	sp,sp,80
    80004bc2:	8082                	ret
      release(&pi->lock);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	ffffc097          	auipc	ra,0xffffc
    80004bca:	0be080e7          	jalr	190(ra) # 80000c84 <release>
      return -1;
    80004bce:	59fd                	li	s3,-1
    80004bd0:	bff9                	j	80004bae <piperead+0xc2>

0000000080004bd2 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004bd2:	de010113          	addi	sp,sp,-544
    80004bd6:	20113c23          	sd	ra,536(sp)
    80004bda:	20813823          	sd	s0,528(sp)
    80004bde:	20913423          	sd	s1,520(sp)
    80004be2:	21213023          	sd	s2,512(sp)
    80004be6:	ffce                	sd	s3,504(sp)
    80004be8:	fbd2                	sd	s4,496(sp)
    80004bea:	f7d6                	sd	s5,488(sp)
    80004bec:	f3da                	sd	s6,480(sp)
    80004bee:	efde                	sd	s7,472(sp)
    80004bf0:	ebe2                	sd	s8,464(sp)
    80004bf2:	e7e6                	sd	s9,456(sp)
    80004bf4:	e3ea                	sd	s10,448(sp)
    80004bf6:	ff6e                	sd	s11,440(sp)
    80004bf8:	1400                	addi	s0,sp,544
    80004bfa:	892a                	mv	s2,a0
    80004bfc:	dea43423          	sd	a0,-536(s0)
    80004c00:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c04:	ffffd097          	auipc	ra,0xffffd
    80004c08:	dae080e7          	jalr	-594(ra) # 800019b2 <myproc>
    80004c0c:	84aa                	mv	s1,a0

  begin_op();
    80004c0e:	fffff097          	auipc	ra,0xfffff
    80004c12:	4a6080e7          	jalr	1190(ra) # 800040b4 <begin_op>

  if((ip = namei(path)) == 0){
    80004c16:	854a                	mv	a0,s2
    80004c18:	fffff097          	auipc	ra,0xfffff
    80004c1c:	280080e7          	jalr	640(ra) # 80003e98 <namei>
    80004c20:	c93d                	beqz	a0,80004c96 <exec+0xc4>
    80004c22:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c24:	fffff097          	auipc	ra,0xfffff
    80004c28:	abe080e7          	jalr	-1346(ra) # 800036e2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c2c:	04000713          	li	a4,64
    80004c30:	4681                	li	a3,0
    80004c32:	e5040613          	addi	a2,s0,-432
    80004c36:	4581                	li	a1,0
    80004c38:	8556                	mv	a0,s5
    80004c3a:	fffff097          	auipc	ra,0xfffff
    80004c3e:	d5c080e7          	jalr	-676(ra) # 80003996 <readi>
    80004c42:	04000793          	li	a5,64
    80004c46:	00f51a63          	bne	a0,a5,80004c5a <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004c4a:	e5042703          	lw	a4,-432(s0)
    80004c4e:	464c47b7          	lui	a5,0x464c4
    80004c52:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c56:	04f70663          	beq	a4,a5,80004ca2 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c5a:	8556                	mv	a0,s5
    80004c5c:	fffff097          	auipc	ra,0xfffff
    80004c60:	ce8080e7          	jalr	-792(ra) # 80003944 <iunlockput>
    end_op();
    80004c64:	fffff097          	auipc	ra,0xfffff
    80004c68:	4d0080e7          	jalr	1232(ra) # 80004134 <end_op>
  }
  return -1;
    80004c6c:	557d                	li	a0,-1
}
    80004c6e:	21813083          	ld	ra,536(sp)
    80004c72:	21013403          	ld	s0,528(sp)
    80004c76:	20813483          	ld	s1,520(sp)
    80004c7a:	20013903          	ld	s2,512(sp)
    80004c7e:	79fe                	ld	s3,504(sp)
    80004c80:	7a5e                	ld	s4,496(sp)
    80004c82:	7abe                	ld	s5,488(sp)
    80004c84:	7b1e                	ld	s6,480(sp)
    80004c86:	6bfe                	ld	s7,472(sp)
    80004c88:	6c5e                	ld	s8,464(sp)
    80004c8a:	6cbe                	ld	s9,456(sp)
    80004c8c:	6d1e                	ld	s10,448(sp)
    80004c8e:	7dfa                	ld	s11,440(sp)
    80004c90:	22010113          	addi	sp,sp,544
    80004c94:	8082                	ret
    end_op();
    80004c96:	fffff097          	auipc	ra,0xfffff
    80004c9a:	49e080e7          	jalr	1182(ra) # 80004134 <end_op>
    return -1;
    80004c9e:	557d                	li	a0,-1
    80004ca0:	b7f9                	j	80004c6e <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	ffffd097          	auipc	ra,0xffffd
    80004ca8:	e70080e7          	jalr	-400(ra) # 80001b14 <proc_pagetable>
    80004cac:	8b2a                	mv	s6,a0
    80004cae:	d555                	beqz	a0,80004c5a <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cb0:	e7042783          	lw	a5,-400(s0)
    80004cb4:	e8845703          	lhu	a4,-376(s0)
    80004cb8:	c735                	beqz	a4,80004d24 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cba:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cbc:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004cc0:	6a05                	lui	s4,0x1
    80004cc2:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004cc6:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004cca:	6d85                	lui	s11,0x1
    80004ccc:	7d7d                	lui	s10,0xfffff
    80004cce:	ac1d                	j	80004f04 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004cd0:	00004517          	auipc	a0,0x4
    80004cd4:	a1050513          	addi	a0,a0,-1520 # 800086e0 <syscalls+0x298>
    80004cd8:	ffffc097          	auipc	ra,0xffffc
    80004cdc:	860080e7          	jalr	-1952(ra) # 80000538 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ce0:	874a                	mv	a4,s2
    80004ce2:	009c86bb          	addw	a3,s9,s1
    80004ce6:	4581                	li	a1,0
    80004ce8:	8556                	mv	a0,s5
    80004cea:	fffff097          	auipc	ra,0xfffff
    80004cee:	cac080e7          	jalr	-852(ra) # 80003996 <readi>
    80004cf2:	2501                	sext.w	a0,a0
    80004cf4:	1aa91863          	bne	s2,a0,80004ea4 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004cf8:	009d84bb          	addw	s1,s11,s1
    80004cfc:	013d09bb          	addw	s3,s10,s3
    80004d00:	1f74f263          	bgeu	s1,s7,80004ee4 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004d04:	02049593          	slli	a1,s1,0x20
    80004d08:	9181                	srli	a1,a1,0x20
    80004d0a:	95e2                	add	a1,a1,s8
    80004d0c:	855a                	mv	a0,s6
    80004d0e:	ffffc097          	auipc	ra,0xffffc
    80004d12:	344080e7          	jalr	836(ra) # 80001052 <walkaddr>
    80004d16:	862a                	mv	a2,a0
    if(pa == 0)
    80004d18:	dd45                	beqz	a0,80004cd0 <exec+0xfe>
      n = PGSIZE;
    80004d1a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004d1c:	fd49f2e3          	bgeu	s3,s4,80004ce0 <exec+0x10e>
      n = sz - i;
    80004d20:	894e                	mv	s2,s3
    80004d22:	bf7d                	j	80004ce0 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d24:	4481                	li	s1,0
  iunlockput(ip);
    80004d26:	8556                	mv	a0,s5
    80004d28:	fffff097          	auipc	ra,0xfffff
    80004d2c:	c1c080e7          	jalr	-996(ra) # 80003944 <iunlockput>
  end_op();
    80004d30:	fffff097          	auipc	ra,0xfffff
    80004d34:	404080e7          	jalr	1028(ra) # 80004134 <end_op>
  p = myproc();
    80004d38:	ffffd097          	auipc	ra,0xffffd
    80004d3c:	c7a080e7          	jalr	-902(ra) # 800019b2 <myproc>
    80004d40:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d42:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d46:	6785                	lui	a5,0x1
    80004d48:	17fd                	addi	a5,a5,-1
    80004d4a:	94be                	add	s1,s1,a5
    80004d4c:	77fd                	lui	a5,0xfffff
    80004d4e:	8fe5                	and	a5,a5,s1
    80004d50:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d54:	6609                	lui	a2,0x2
    80004d56:	963e                	add	a2,a2,a5
    80004d58:	85be                	mv	a1,a5
    80004d5a:	855a                	mv	a0,s6
    80004d5c:	ffffc097          	auipc	ra,0xffffc
    80004d60:	6aa080e7          	jalr	1706(ra) # 80001406 <uvmalloc>
    80004d64:	8c2a                	mv	s8,a0
  ip = 0;
    80004d66:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d68:	12050e63          	beqz	a0,80004ea4 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d6c:	75f9                	lui	a1,0xffffe
    80004d6e:	95aa                	add	a1,a1,a0
    80004d70:	855a                	mv	a0,s6
    80004d72:	ffffd097          	auipc	ra,0xffffd
    80004d76:	8b2080e7          	jalr	-1870(ra) # 80001624 <uvmclear>
  stackbase = sp - PGSIZE;
    80004d7a:	7afd                	lui	s5,0xfffff
    80004d7c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d7e:	df043783          	ld	a5,-528(s0)
    80004d82:	6388                	ld	a0,0(a5)
    80004d84:	c925                	beqz	a0,80004df4 <exec+0x222>
    80004d86:	e9040993          	addi	s3,s0,-368
    80004d8a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004d8e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d90:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	0b6080e7          	jalr	182(ra) # 80000e48 <strlen>
    80004d9a:	0015079b          	addiw	a5,a0,1
    80004d9e:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004da2:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004da6:	13596363          	bltu	s2,s5,80004ecc <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004daa:	df043d83          	ld	s11,-528(s0)
    80004dae:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004db2:	8552                	mv	a0,s4
    80004db4:	ffffc097          	auipc	ra,0xffffc
    80004db8:	094080e7          	jalr	148(ra) # 80000e48 <strlen>
    80004dbc:	0015069b          	addiw	a3,a0,1
    80004dc0:	8652                	mv	a2,s4
    80004dc2:	85ca                	mv	a1,s2
    80004dc4:	855a                	mv	a0,s6
    80004dc6:	ffffd097          	auipc	ra,0xffffd
    80004dca:	890080e7          	jalr	-1904(ra) # 80001656 <copyout>
    80004dce:	10054363          	bltz	a0,80004ed4 <exec+0x302>
    ustack[argc] = sp;
    80004dd2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004dd6:	0485                	addi	s1,s1,1
    80004dd8:	008d8793          	addi	a5,s11,8
    80004ddc:	def43823          	sd	a5,-528(s0)
    80004de0:	008db503          	ld	a0,8(s11)
    80004de4:	c911                	beqz	a0,80004df8 <exec+0x226>
    if(argc >= MAXARG)
    80004de6:	09a1                	addi	s3,s3,8
    80004de8:	fb3c95e3          	bne	s9,s3,80004d92 <exec+0x1c0>
  sz = sz1;
    80004dec:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004df0:	4a81                	li	s5,0
    80004df2:	a84d                	j	80004ea4 <exec+0x2d2>
  sp = sz;
    80004df4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004df6:	4481                	li	s1,0
  ustack[argc] = 0;
    80004df8:	00349793          	slli	a5,s1,0x3
    80004dfc:	f9040713          	addi	a4,s0,-112
    80004e00:	97ba                	add	a5,a5,a4
    80004e02:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdce40>
  sp -= (argc+1) * sizeof(uint64);
    80004e06:	00148693          	addi	a3,s1,1
    80004e0a:	068e                	slli	a3,a3,0x3
    80004e0c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e10:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e14:	01597663          	bgeu	s2,s5,80004e20 <exec+0x24e>
  sz = sz1;
    80004e18:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e1c:	4a81                	li	s5,0
    80004e1e:	a059                	j	80004ea4 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e20:	e9040613          	addi	a2,s0,-368
    80004e24:	85ca                	mv	a1,s2
    80004e26:	855a                	mv	a0,s6
    80004e28:	ffffd097          	auipc	ra,0xffffd
    80004e2c:	82e080e7          	jalr	-2002(ra) # 80001656 <copyout>
    80004e30:	0a054663          	bltz	a0,80004edc <exec+0x30a>
  p->trapframe->a1 = sp;
    80004e34:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004e38:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e3c:	de843783          	ld	a5,-536(s0)
    80004e40:	0007c703          	lbu	a4,0(a5)
    80004e44:	cf11                	beqz	a4,80004e60 <exec+0x28e>
    80004e46:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e48:	02f00693          	li	a3,47
    80004e4c:	a039                	j	80004e5a <exec+0x288>
      last = s+1;
    80004e4e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e52:	0785                	addi	a5,a5,1
    80004e54:	fff7c703          	lbu	a4,-1(a5)
    80004e58:	c701                	beqz	a4,80004e60 <exec+0x28e>
    if(*s == '/')
    80004e5a:	fed71ce3          	bne	a4,a3,80004e52 <exec+0x280>
    80004e5e:	bfc5                	j	80004e4e <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e60:	4641                	li	a2,16
    80004e62:	de843583          	ld	a1,-536(s0)
    80004e66:	158b8513          	addi	a0,s7,344
    80004e6a:	ffffc097          	auipc	ra,0xffffc
    80004e6e:	fac080e7          	jalr	-84(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e72:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e76:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004e7a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e7e:	058bb783          	ld	a5,88(s7)
    80004e82:	e6843703          	ld	a4,-408(s0)
    80004e86:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e88:	058bb783          	ld	a5,88(s7)
    80004e8c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e90:	85ea                	mv	a1,s10
    80004e92:	ffffd097          	auipc	ra,0xffffd
    80004e96:	d1e080e7          	jalr	-738(ra) # 80001bb0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e9a:	0004851b          	sext.w	a0,s1
    80004e9e:	bbc1                	j	80004c6e <exec+0x9c>
    80004ea0:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ea4:	df843583          	ld	a1,-520(s0)
    80004ea8:	855a                	mv	a0,s6
    80004eaa:	ffffd097          	auipc	ra,0xffffd
    80004eae:	d06080e7          	jalr	-762(ra) # 80001bb0 <proc_freepagetable>
  if(ip){
    80004eb2:	da0a94e3          	bnez	s5,80004c5a <exec+0x88>
  return -1;
    80004eb6:	557d                	li	a0,-1
    80004eb8:	bb5d                	j	80004c6e <exec+0x9c>
    80004eba:	de943c23          	sd	s1,-520(s0)
    80004ebe:	b7dd                	j	80004ea4 <exec+0x2d2>
    80004ec0:	de943c23          	sd	s1,-520(s0)
    80004ec4:	b7c5                	j	80004ea4 <exec+0x2d2>
    80004ec6:	de943c23          	sd	s1,-520(s0)
    80004eca:	bfe9                	j	80004ea4 <exec+0x2d2>
  sz = sz1;
    80004ecc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ed0:	4a81                	li	s5,0
    80004ed2:	bfc9                	j	80004ea4 <exec+0x2d2>
  sz = sz1;
    80004ed4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ed8:	4a81                	li	s5,0
    80004eda:	b7e9                	j	80004ea4 <exec+0x2d2>
  sz = sz1;
    80004edc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ee0:	4a81                	li	s5,0
    80004ee2:	b7c9                	j	80004ea4 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ee4:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ee8:	e0843783          	ld	a5,-504(s0)
    80004eec:	0017869b          	addiw	a3,a5,1
    80004ef0:	e0d43423          	sd	a3,-504(s0)
    80004ef4:	e0043783          	ld	a5,-512(s0)
    80004ef8:	0387879b          	addiw	a5,a5,56
    80004efc:	e8845703          	lhu	a4,-376(s0)
    80004f00:	e2e6d3e3          	bge	a3,a4,80004d26 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f04:	2781                	sext.w	a5,a5
    80004f06:	e0f43023          	sd	a5,-512(s0)
    80004f0a:	03800713          	li	a4,56
    80004f0e:	86be                	mv	a3,a5
    80004f10:	e1840613          	addi	a2,s0,-488
    80004f14:	4581                	li	a1,0
    80004f16:	8556                	mv	a0,s5
    80004f18:	fffff097          	auipc	ra,0xfffff
    80004f1c:	a7e080e7          	jalr	-1410(ra) # 80003996 <readi>
    80004f20:	03800793          	li	a5,56
    80004f24:	f6f51ee3          	bne	a0,a5,80004ea0 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004f28:	e1842783          	lw	a5,-488(s0)
    80004f2c:	4705                	li	a4,1
    80004f2e:	fae79de3          	bne	a5,a4,80004ee8 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004f32:	e4043603          	ld	a2,-448(s0)
    80004f36:	e3843783          	ld	a5,-456(s0)
    80004f3a:	f8f660e3          	bltu	a2,a5,80004eba <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f3e:	e2843783          	ld	a5,-472(s0)
    80004f42:	963e                	add	a2,a2,a5
    80004f44:	f6f66ee3          	bltu	a2,a5,80004ec0 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f48:	85a6                	mv	a1,s1
    80004f4a:	855a                	mv	a0,s6
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	4ba080e7          	jalr	1210(ra) # 80001406 <uvmalloc>
    80004f54:	dea43c23          	sd	a0,-520(s0)
    80004f58:	d53d                	beqz	a0,80004ec6 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80004f5a:	e2843c03          	ld	s8,-472(s0)
    80004f5e:	de043783          	ld	a5,-544(s0)
    80004f62:	00fc77b3          	and	a5,s8,a5
    80004f66:	ff9d                	bnez	a5,80004ea4 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f68:	e2042c83          	lw	s9,-480(s0)
    80004f6c:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f70:	f60b8ae3          	beqz	s7,80004ee4 <exec+0x312>
    80004f74:	89de                	mv	s3,s7
    80004f76:	4481                	li	s1,0
    80004f78:	b371                	j	80004d04 <exec+0x132>

0000000080004f7a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f7a:	7179                	addi	sp,sp,-48
    80004f7c:	f406                	sd	ra,40(sp)
    80004f7e:	f022                	sd	s0,32(sp)
    80004f80:	ec26                	sd	s1,24(sp)
    80004f82:	e84a                	sd	s2,16(sp)
    80004f84:	1800                	addi	s0,sp,48
    80004f86:	892e                	mv	s2,a1
    80004f88:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004f8a:	fdc40593          	addi	a1,s0,-36
    80004f8e:	ffffe097          	auipc	ra,0xffffe
    80004f92:	bd0080e7          	jalr	-1072(ra) # 80002b5e <argint>
    80004f96:	04054063          	bltz	a0,80004fd6 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f9a:	fdc42703          	lw	a4,-36(s0)
    80004f9e:	47bd                	li	a5,15
    80004fa0:	02e7ed63          	bltu	a5,a4,80004fda <argfd+0x60>
    80004fa4:	ffffd097          	auipc	ra,0xffffd
    80004fa8:	a0e080e7          	jalr	-1522(ra) # 800019b2 <myproc>
    80004fac:	fdc42703          	lw	a4,-36(s0)
    80004fb0:	01a70793          	addi	a5,a4,26
    80004fb4:	078e                	slli	a5,a5,0x3
    80004fb6:	953e                	add	a0,a0,a5
    80004fb8:	611c                	ld	a5,0(a0)
    80004fba:	c395                	beqz	a5,80004fde <argfd+0x64>
    return -1;
  if(pfd)
    80004fbc:	00090463          	beqz	s2,80004fc4 <argfd+0x4a>
    *pfd = fd;
    80004fc0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fc4:	4501                	li	a0,0
  if(pf)
    80004fc6:	c091                	beqz	s1,80004fca <argfd+0x50>
    *pf = f;
    80004fc8:	e09c                	sd	a5,0(s1)
}
    80004fca:	70a2                	ld	ra,40(sp)
    80004fcc:	7402                	ld	s0,32(sp)
    80004fce:	64e2                	ld	s1,24(sp)
    80004fd0:	6942                	ld	s2,16(sp)
    80004fd2:	6145                	addi	sp,sp,48
    80004fd4:	8082                	ret
    return -1;
    80004fd6:	557d                	li	a0,-1
    80004fd8:	bfcd                	j	80004fca <argfd+0x50>
    return -1;
    80004fda:	557d                	li	a0,-1
    80004fdc:	b7fd                	j	80004fca <argfd+0x50>
    80004fde:	557d                	li	a0,-1
    80004fe0:	b7ed                	j	80004fca <argfd+0x50>

0000000080004fe2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fe2:	1101                	addi	sp,sp,-32
    80004fe4:	ec06                	sd	ra,24(sp)
    80004fe6:	e822                	sd	s0,16(sp)
    80004fe8:	e426                	sd	s1,8(sp)
    80004fea:	1000                	addi	s0,sp,32
    80004fec:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fee:	ffffd097          	auipc	ra,0xffffd
    80004ff2:	9c4080e7          	jalr	-1596(ra) # 800019b2 <myproc>
    80004ff6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004ff8:	0d050793          	addi	a5,a0,208
    80004ffc:	4501                	li	a0,0
    80004ffe:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005000:	6398                	ld	a4,0(a5)
    80005002:	cb19                	beqz	a4,80005018 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005004:	2505                	addiw	a0,a0,1
    80005006:	07a1                	addi	a5,a5,8
    80005008:	fed51ce3          	bne	a0,a3,80005000 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000500c:	557d                	li	a0,-1
}
    8000500e:	60e2                	ld	ra,24(sp)
    80005010:	6442                	ld	s0,16(sp)
    80005012:	64a2                	ld	s1,8(sp)
    80005014:	6105                	addi	sp,sp,32
    80005016:	8082                	ret
      p->ofile[fd] = f;
    80005018:	01a50793          	addi	a5,a0,26
    8000501c:	078e                	slli	a5,a5,0x3
    8000501e:	963e                	add	a2,a2,a5
    80005020:	e204                	sd	s1,0(a2)
      return fd;
    80005022:	b7f5                	j	8000500e <fdalloc+0x2c>

0000000080005024 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005024:	715d                	addi	sp,sp,-80
    80005026:	e486                	sd	ra,72(sp)
    80005028:	e0a2                	sd	s0,64(sp)
    8000502a:	fc26                	sd	s1,56(sp)
    8000502c:	f84a                	sd	s2,48(sp)
    8000502e:	f44e                	sd	s3,40(sp)
    80005030:	f052                	sd	s4,32(sp)
    80005032:	ec56                	sd	s5,24(sp)
    80005034:	0880                	addi	s0,sp,80
    80005036:	89ae                	mv	s3,a1
    80005038:	8ab2                	mv	s5,a2
    8000503a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000503c:	fb040593          	addi	a1,s0,-80
    80005040:	fffff097          	auipc	ra,0xfffff
    80005044:	e76080e7          	jalr	-394(ra) # 80003eb6 <nameiparent>
    80005048:	892a                	mv	s2,a0
    8000504a:	12050e63          	beqz	a0,80005186 <create+0x162>
    return 0;

  ilock(dp);
    8000504e:	ffffe097          	auipc	ra,0xffffe
    80005052:	694080e7          	jalr	1684(ra) # 800036e2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005056:	4601                	li	a2,0
    80005058:	fb040593          	addi	a1,s0,-80
    8000505c:	854a                	mv	a0,s2
    8000505e:	fffff097          	auipc	ra,0xfffff
    80005062:	b68080e7          	jalr	-1176(ra) # 80003bc6 <dirlookup>
    80005066:	84aa                	mv	s1,a0
    80005068:	c921                	beqz	a0,800050b8 <create+0x94>
    iunlockput(dp);
    8000506a:	854a                	mv	a0,s2
    8000506c:	fffff097          	auipc	ra,0xfffff
    80005070:	8d8080e7          	jalr	-1832(ra) # 80003944 <iunlockput>
    ilock(ip);
    80005074:	8526                	mv	a0,s1
    80005076:	ffffe097          	auipc	ra,0xffffe
    8000507a:	66c080e7          	jalr	1644(ra) # 800036e2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000507e:	2981                	sext.w	s3,s3
    80005080:	4789                	li	a5,2
    80005082:	02f99463          	bne	s3,a5,800050aa <create+0x86>
    80005086:	0444d783          	lhu	a5,68(s1)
    8000508a:	37f9                	addiw	a5,a5,-2
    8000508c:	17c2                	slli	a5,a5,0x30
    8000508e:	93c1                	srli	a5,a5,0x30
    80005090:	4705                	li	a4,1
    80005092:	00f76c63          	bltu	a4,a5,800050aa <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005096:	8526                	mv	a0,s1
    80005098:	60a6                	ld	ra,72(sp)
    8000509a:	6406                	ld	s0,64(sp)
    8000509c:	74e2                	ld	s1,56(sp)
    8000509e:	7942                	ld	s2,48(sp)
    800050a0:	79a2                	ld	s3,40(sp)
    800050a2:	7a02                	ld	s4,32(sp)
    800050a4:	6ae2                	ld	s5,24(sp)
    800050a6:	6161                	addi	sp,sp,80
    800050a8:	8082                	ret
    iunlockput(ip);
    800050aa:	8526                	mv	a0,s1
    800050ac:	fffff097          	auipc	ra,0xfffff
    800050b0:	898080e7          	jalr	-1896(ra) # 80003944 <iunlockput>
    return 0;
    800050b4:	4481                	li	s1,0
    800050b6:	b7c5                	j	80005096 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800050b8:	85ce                	mv	a1,s3
    800050ba:	00092503          	lw	a0,0(s2)
    800050be:	ffffe097          	auipc	ra,0xffffe
    800050c2:	48c080e7          	jalr	1164(ra) # 8000354a <ialloc>
    800050c6:	84aa                	mv	s1,a0
    800050c8:	c521                	beqz	a0,80005110 <create+0xec>
  ilock(ip);
    800050ca:	ffffe097          	auipc	ra,0xffffe
    800050ce:	618080e7          	jalr	1560(ra) # 800036e2 <ilock>
  ip->major = major;
    800050d2:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800050d6:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800050da:	4a05                	li	s4,1
    800050dc:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800050e0:	8526                	mv	a0,s1
    800050e2:	ffffe097          	auipc	ra,0xffffe
    800050e6:	536080e7          	jalr	1334(ra) # 80003618 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050ea:	2981                	sext.w	s3,s3
    800050ec:	03498a63          	beq	s3,s4,80005120 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800050f0:	40d0                	lw	a2,4(s1)
    800050f2:	fb040593          	addi	a1,s0,-80
    800050f6:	854a                	mv	a0,s2
    800050f8:	fffff097          	auipc	ra,0xfffff
    800050fc:	cde080e7          	jalr	-802(ra) # 80003dd6 <dirlink>
    80005100:	06054b63          	bltz	a0,80005176 <create+0x152>
  iunlockput(dp);
    80005104:	854a                	mv	a0,s2
    80005106:	fffff097          	auipc	ra,0xfffff
    8000510a:	83e080e7          	jalr	-1986(ra) # 80003944 <iunlockput>
  return ip;
    8000510e:	b761                	j	80005096 <create+0x72>
    panic("create: ialloc");
    80005110:	00003517          	auipc	a0,0x3
    80005114:	5f050513          	addi	a0,a0,1520 # 80008700 <syscalls+0x2b8>
    80005118:	ffffb097          	auipc	ra,0xffffb
    8000511c:	420080e7          	jalr	1056(ra) # 80000538 <panic>
    dp->nlink++;  // for ".."
    80005120:	04a95783          	lhu	a5,74(s2)
    80005124:	2785                	addiw	a5,a5,1
    80005126:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000512a:	854a                	mv	a0,s2
    8000512c:	ffffe097          	auipc	ra,0xffffe
    80005130:	4ec080e7          	jalr	1260(ra) # 80003618 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005134:	40d0                	lw	a2,4(s1)
    80005136:	00003597          	auipc	a1,0x3
    8000513a:	5da58593          	addi	a1,a1,1498 # 80008710 <syscalls+0x2c8>
    8000513e:	8526                	mv	a0,s1
    80005140:	fffff097          	auipc	ra,0xfffff
    80005144:	c96080e7          	jalr	-874(ra) # 80003dd6 <dirlink>
    80005148:	00054f63          	bltz	a0,80005166 <create+0x142>
    8000514c:	00492603          	lw	a2,4(s2)
    80005150:	00003597          	auipc	a1,0x3
    80005154:	5c858593          	addi	a1,a1,1480 # 80008718 <syscalls+0x2d0>
    80005158:	8526                	mv	a0,s1
    8000515a:	fffff097          	auipc	ra,0xfffff
    8000515e:	c7c080e7          	jalr	-900(ra) # 80003dd6 <dirlink>
    80005162:	f80557e3          	bgez	a0,800050f0 <create+0xcc>
      panic("create dots");
    80005166:	00003517          	auipc	a0,0x3
    8000516a:	5ba50513          	addi	a0,a0,1466 # 80008720 <syscalls+0x2d8>
    8000516e:	ffffb097          	auipc	ra,0xffffb
    80005172:	3ca080e7          	jalr	970(ra) # 80000538 <panic>
    panic("create: dirlink");
    80005176:	00003517          	auipc	a0,0x3
    8000517a:	5ba50513          	addi	a0,a0,1466 # 80008730 <syscalls+0x2e8>
    8000517e:	ffffb097          	auipc	ra,0xffffb
    80005182:	3ba080e7          	jalr	954(ra) # 80000538 <panic>
    return 0;
    80005186:	84aa                	mv	s1,a0
    80005188:	b739                	j	80005096 <create+0x72>

000000008000518a <sys_dup>:
{
    8000518a:	7179                	addi	sp,sp,-48
    8000518c:	f406                	sd	ra,40(sp)
    8000518e:	f022                	sd	s0,32(sp)
    80005190:	ec26                	sd	s1,24(sp)
    80005192:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005194:	fd840613          	addi	a2,s0,-40
    80005198:	4581                	li	a1,0
    8000519a:	4501                	li	a0,0
    8000519c:	00000097          	auipc	ra,0x0
    800051a0:	dde080e7          	jalr	-546(ra) # 80004f7a <argfd>
    return -1;
    800051a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051a6:	02054363          	bltz	a0,800051cc <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800051aa:	fd843503          	ld	a0,-40(s0)
    800051ae:	00000097          	auipc	ra,0x0
    800051b2:	e34080e7          	jalr	-460(ra) # 80004fe2 <fdalloc>
    800051b6:	84aa                	mv	s1,a0
    return -1;
    800051b8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051ba:	00054963          	bltz	a0,800051cc <sys_dup+0x42>
  filedup(f);
    800051be:	fd843503          	ld	a0,-40(s0)
    800051c2:	fffff097          	auipc	ra,0xfffff
    800051c6:	36c080e7          	jalr	876(ra) # 8000452e <filedup>
  return fd;
    800051ca:	87a6                	mv	a5,s1
}
    800051cc:	853e                	mv	a0,a5
    800051ce:	70a2                	ld	ra,40(sp)
    800051d0:	7402                	ld	s0,32(sp)
    800051d2:	64e2                	ld	s1,24(sp)
    800051d4:	6145                	addi	sp,sp,48
    800051d6:	8082                	ret

00000000800051d8 <sys_read>:
{
    800051d8:	7179                	addi	sp,sp,-48
    800051da:	f406                	sd	ra,40(sp)
    800051dc:	f022                	sd	s0,32(sp)
    800051de:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051e0:	fe840613          	addi	a2,s0,-24
    800051e4:	4581                	li	a1,0
    800051e6:	4501                	li	a0,0
    800051e8:	00000097          	auipc	ra,0x0
    800051ec:	d92080e7          	jalr	-622(ra) # 80004f7a <argfd>
    return -1;
    800051f0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051f2:	04054163          	bltz	a0,80005234 <sys_read+0x5c>
    800051f6:	fe440593          	addi	a1,s0,-28
    800051fa:	4509                	li	a0,2
    800051fc:	ffffe097          	auipc	ra,0xffffe
    80005200:	962080e7          	jalr	-1694(ra) # 80002b5e <argint>
    return -1;
    80005204:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005206:	02054763          	bltz	a0,80005234 <sys_read+0x5c>
    8000520a:	fd840593          	addi	a1,s0,-40
    8000520e:	4505                	li	a0,1
    80005210:	ffffe097          	auipc	ra,0xffffe
    80005214:	970080e7          	jalr	-1680(ra) # 80002b80 <argaddr>
    return -1;
    80005218:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000521a:	00054d63          	bltz	a0,80005234 <sys_read+0x5c>
  return fileread(f, p, n);
    8000521e:	fe442603          	lw	a2,-28(s0)
    80005222:	fd843583          	ld	a1,-40(s0)
    80005226:	fe843503          	ld	a0,-24(s0)
    8000522a:	fffff097          	auipc	ra,0xfffff
    8000522e:	490080e7          	jalr	1168(ra) # 800046ba <fileread>
    80005232:	87aa                	mv	a5,a0
}
    80005234:	853e                	mv	a0,a5
    80005236:	70a2                	ld	ra,40(sp)
    80005238:	7402                	ld	s0,32(sp)
    8000523a:	6145                	addi	sp,sp,48
    8000523c:	8082                	ret

000000008000523e <sys_write>:
{
    8000523e:	7179                	addi	sp,sp,-48
    80005240:	f406                	sd	ra,40(sp)
    80005242:	f022                	sd	s0,32(sp)
    80005244:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005246:	fe840613          	addi	a2,s0,-24
    8000524a:	4581                	li	a1,0
    8000524c:	4501                	li	a0,0
    8000524e:	00000097          	auipc	ra,0x0
    80005252:	d2c080e7          	jalr	-724(ra) # 80004f7a <argfd>
    return -1;
    80005256:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005258:	04054163          	bltz	a0,8000529a <sys_write+0x5c>
    8000525c:	fe440593          	addi	a1,s0,-28
    80005260:	4509                	li	a0,2
    80005262:	ffffe097          	auipc	ra,0xffffe
    80005266:	8fc080e7          	jalr	-1796(ra) # 80002b5e <argint>
    return -1;
    8000526a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000526c:	02054763          	bltz	a0,8000529a <sys_write+0x5c>
    80005270:	fd840593          	addi	a1,s0,-40
    80005274:	4505                	li	a0,1
    80005276:	ffffe097          	auipc	ra,0xffffe
    8000527a:	90a080e7          	jalr	-1782(ra) # 80002b80 <argaddr>
    return -1;
    8000527e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005280:	00054d63          	bltz	a0,8000529a <sys_write+0x5c>
  return filewrite(f, p, n);
    80005284:	fe442603          	lw	a2,-28(s0)
    80005288:	fd843583          	ld	a1,-40(s0)
    8000528c:	fe843503          	ld	a0,-24(s0)
    80005290:	fffff097          	auipc	ra,0xfffff
    80005294:	4ec080e7          	jalr	1260(ra) # 8000477c <filewrite>
    80005298:	87aa                	mv	a5,a0
}
    8000529a:	853e                	mv	a0,a5
    8000529c:	70a2                	ld	ra,40(sp)
    8000529e:	7402                	ld	s0,32(sp)
    800052a0:	6145                	addi	sp,sp,48
    800052a2:	8082                	ret

00000000800052a4 <sys_close>:
{
    800052a4:	1101                	addi	sp,sp,-32
    800052a6:	ec06                	sd	ra,24(sp)
    800052a8:	e822                	sd	s0,16(sp)
    800052aa:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052ac:	fe040613          	addi	a2,s0,-32
    800052b0:	fec40593          	addi	a1,s0,-20
    800052b4:	4501                	li	a0,0
    800052b6:	00000097          	auipc	ra,0x0
    800052ba:	cc4080e7          	jalr	-828(ra) # 80004f7a <argfd>
    return -1;
    800052be:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052c0:	02054463          	bltz	a0,800052e8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800052c4:	ffffc097          	auipc	ra,0xffffc
    800052c8:	6ee080e7          	jalr	1774(ra) # 800019b2 <myproc>
    800052cc:	fec42783          	lw	a5,-20(s0)
    800052d0:	07e9                	addi	a5,a5,26
    800052d2:	078e                	slli	a5,a5,0x3
    800052d4:	97aa                	add	a5,a5,a0
    800052d6:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800052da:	fe043503          	ld	a0,-32(s0)
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	2a2080e7          	jalr	674(ra) # 80004580 <fileclose>
  return 0;
    800052e6:	4781                	li	a5,0
}
    800052e8:	853e                	mv	a0,a5
    800052ea:	60e2                	ld	ra,24(sp)
    800052ec:	6442                	ld	s0,16(sp)
    800052ee:	6105                	addi	sp,sp,32
    800052f0:	8082                	ret

00000000800052f2 <sys_fstat>:
{
    800052f2:	1101                	addi	sp,sp,-32
    800052f4:	ec06                	sd	ra,24(sp)
    800052f6:	e822                	sd	s0,16(sp)
    800052f8:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052fa:	fe840613          	addi	a2,s0,-24
    800052fe:	4581                	li	a1,0
    80005300:	4501                	li	a0,0
    80005302:	00000097          	auipc	ra,0x0
    80005306:	c78080e7          	jalr	-904(ra) # 80004f7a <argfd>
    return -1;
    8000530a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000530c:	02054563          	bltz	a0,80005336 <sys_fstat+0x44>
    80005310:	fe040593          	addi	a1,s0,-32
    80005314:	4505                	li	a0,1
    80005316:	ffffe097          	auipc	ra,0xffffe
    8000531a:	86a080e7          	jalr	-1942(ra) # 80002b80 <argaddr>
    return -1;
    8000531e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005320:	00054b63          	bltz	a0,80005336 <sys_fstat+0x44>
  return filestat(f, st);
    80005324:	fe043583          	ld	a1,-32(s0)
    80005328:	fe843503          	ld	a0,-24(s0)
    8000532c:	fffff097          	auipc	ra,0xfffff
    80005330:	31c080e7          	jalr	796(ra) # 80004648 <filestat>
    80005334:	87aa                	mv	a5,a0
}
    80005336:	853e                	mv	a0,a5
    80005338:	60e2                	ld	ra,24(sp)
    8000533a:	6442                	ld	s0,16(sp)
    8000533c:	6105                	addi	sp,sp,32
    8000533e:	8082                	ret

0000000080005340 <sys_link>:
{
    80005340:	7169                	addi	sp,sp,-304
    80005342:	f606                	sd	ra,296(sp)
    80005344:	f222                	sd	s0,288(sp)
    80005346:	ee26                	sd	s1,280(sp)
    80005348:	ea4a                	sd	s2,272(sp)
    8000534a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000534c:	08000613          	li	a2,128
    80005350:	ed040593          	addi	a1,s0,-304
    80005354:	4501                	li	a0,0
    80005356:	ffffe097          	auipc	ra,0xffffe
    8000535a:	84c080e7          	jalr	-1972(ra) # 80002ba2 <argstr>
    return -1;
    8000535e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005360:	10054e63          	bltz	a0,8000547c <sys_link+0x13c>
    80005364:	08000613          	li	a2,128
    80005368:	f5040593          	addi	a1,s0,-176
    8000536c:	4505                	li	a0,1
    8000536e:	ffffe097          	auipc	ra,0xffffe
    80005372:	834080e7          	jalr	-1996(ra) # 80002ba2 <argstr>
    return -1;
    80005376:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005378:	10054263          	bltz	a0,8000547c <sys_link+0x13c>
  begin_op();
    8000537c:	fffff097          	auipc	ra,0xfffff
    80005380:	d38080e7          	jalr	-712(ra) # 800040b4 <begin_op>
  if((ip = namei(old)) == 0){
    80005384:	ed040513          	addi	a0,s0,-304
    80005388:	fffff097          	auipc	ra,0xfffff
    8000538c:	b10080e7          	jalr	-1264(ra) # 80003e98 <namei>
    80005390:	84aa                	mv	s1,a0
    80005392:	c551                	beqz	a0,8000541e <sys_link+0xde>
  ilock(ip);
    80005394:	ffffe097          	auipc	ra,0xffffe
    80005398:	34e080e7          	jalr	846(ra) # 800036e2 <ilock>
  if(ip->type == T_DIR){
    8000539c:	04449703          	lh	a4,68(s1)
    800053a0:	4785                	li	a5,1
    800053a2:	08f70463          	beq	a4,a5,8000542a <sys_link+0xea>
  ip->nlink++;
    800053a6:	04a4d783          	lhu	a5,74(s1)
    800053aa:	2785                	addiw	a5,a5,1
    800053ac:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053b0:	8526                	mv	a0,s1
    800053b2:	ffffe097          	auipc	ra,0xffffe
    800053b6:	266080e7          	jalr	614(ra) # 80003618 <iupdate>
  iunlock(ip);
    800053ba:	8526                	mv	a0,s1
    800053bc:	ffffe097          	auipc	ra,0xffffe
    800053c0:	3e8080e7          	jalr	1000(ra) # 800037a4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053c4:	fd040593          	addi	a1,s0,-48
    800053c8:	f5040513          	addi	a0,s0,-176
    800053cc:	fffff097          	auipc	ra,0xfffff
    800053d0:	aea080e7          	jalr	-1302(ra) # 80003eb6 <nameiparent>
    800053d4:	892a                	mv	s2,a0
    800053d6:	c935                	beqz	a0,8000544a <sys_link+0x10a>
  ilock(dp);
    800053d8:	ffffe097          	auipc	ra,0xffffe
    800053dc:	30a080e7          	jalr	778(ra) # 800036e2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053e0:	00092703          	lw	a4,0(s2)
    800053e4:	409c                	lw	a5,0(s1)
    800053e6:	04f71d63          	bne	a4,a5,80005440 <sys_link+0x100>
    800053ea:	40d0                	lw	a2,4(s1)
    800053ec:	fd040593          	addi	a1,s0,-48
    800053f0:	854a                	mv	a0,s2
    800053f2:	fffff097          	auipc	ra,0xfffff
    800053f6:	9e4080e7          	jalr	-1564(ra) # 80003dd6 <dirlink>
    800053fa:	04054363          	bltz	a0,80005440 <sys_link+0x100>
  iunlockput(dp);
    800053fe:	854a                	mv	a0,s2
    80005400:	ffffe097          	auipc	ra,0xffffe
    80005404:	544080e7          	jalr	1348(ra) # 80003944 <iunlockput>
  iput(ip);
    80005408:	8526                	mv	a0,s1
    8000540a:	ffffe097          	auipc	ra,0xffffe
    8000540e:	492080e7          	jalr	1170(ra) # 8000389c <iput>
  end_op();
    80005412:	fffff097          	auipc	ra,0xfffff
    80005416:	d22080e7          	jalr	-734(ra) # 80004134 <end_op>
  return 0;
    8000541a:	4781                	li	a5,0
    8000541c:	a085                	j	8000547c <sys_link+0x13c>
    end_op();
    8000541e:	fffff097          	auipc	ra,0xfffff
    80005422:	d16080e7          	jalr	-746(ra) # 80004134 <end_op>
    return -1;
    80005426:	57fd                	li	a5,-1
    80005428:	a891                	j	8000547c <sys_link+0x13c>
    iunlockput(ip);
    8000542a:	8526                	mv	a0,s1
    8000542c:	ffffe097          	auipc	ra,0xffffe
    80005430:	518080e7          	jalr	1304(ra) # 80003944 <iunlockput>
    end_op();
    80005434:	fffff097          	auipc	ra,0xfffff
    80005438:	d00080e7          	jalr	-768(ra) # 80004134 <end_op>
    return -1;
    8000543c:	57fd                	li	a5,-1
    8000543e:	a83d                	j	8000547c <sys_link+0x13c>
    iunlockput(dp);
    80005440:	854a                	mv	a0,s2
    80005442:	ffffe097          	auipc	ra,0xffffe
    80005446:	502080e7          	jalr	1282(ra) # 80003944 <iunlockput>
  ilock(ip);
    8000544a:	8526                	mv	a0,s1
    8000544c:	ffffe097          	auipc	ra,0xffffe
    80005450:	296080e7          	jalr	662(ra) # 800036e2 <ilock>
  ip->nlink--;
    80005454:	04a4d783          	lhu	a5,74(s1)
    80005458:	37fd                	addiw	a5,a5,-1
    8000545a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000545e:	8526                	mv	a0,s1
    80005460:	ffffe097          	auipc	ra,0xffffe
    80005464:	1b8080e7          	jalr	440(ra) # 80003618 <iupdate>
  iunlockput(ip);
    80005468:	8526                	mv	a0,s1
    8000546a:	ffffe097          	auipc	ra,0xffffe
    8000546e:	4da080e7          	jalr	1242(ra) # 80003944 <iunlockput>
  end_op();
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	cc2080e7          	jalr	-830(ra) # 80004134 <end_op>
  return -1;
    8000547a:	57fd                	li	a5,-1
}
    8000547c:	853e                	mv	a0,a5
    8000547e:	70b2                	ld	ra,296(sp)
    80005480:	7412                	ld	s0,288(sp)
    80005482:	64f2                	ld	s1,280(sp)
    80005484:	6952                	ld	s2,272(sp)
    80005486:	6155                	addi	sp,sp,304
    80005488:	8082                	ret

000000008000548a <sys_unlink>:
{
    8000548a:	7151                	addi	sp,sp,-240
    8000548c:	f586                	sd	ra,232(sp)
    8000548e:	f1a2                	sd	s0,224(sp)
    80005490:	eda6                	sd	s1,216(sp)
    80005492:	e9ca                	sd	s2,208(sp)
    80005494:	e5ce                	sd	s3,200(sp)
    80005496:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005498:	08000613          	li	a2,128
    8000549c:	f3040593          	addi	a1,s0,-208
    800054a0:	4501                	li	a0,0
    800054a2:	ffffd097          	auipc	ra,0xffffd
    800054a6:	700080e7          	jalr	1792(ra) # 80002ba2 <argstr>
    800054aa:	18054163          	bltz	a0,8000562c <sys_unlink+0x1a2>
  begin_op();
    800054ae:	fffff097          	auipc	ra,0xfffff
    800054b2:	c06080e7          	jalr	-1018(ra) # 800040b4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800054b6:	fb040593          	addi	a1,s0,-80
    800054ba:	f3040513          	addi	a0,s0,-208
    800054be:	fffff097          	auipc	ra,0xfffff
    800054c2:	9f8080e7          	jalr	-1544(ra) # 80003eb6 <nameiparent>
    800054c6:	84aa                	mv	s1,a0
    800054c8:	c979                	beqz	a0,8000559e <sys_unlink+0x114>
  ilock(dp);
    800054ca:	ffffe097          	auipc	ra,0xffffe
    800054ce:	218080e7          	jalr	536(ra) # 800036e2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800054d2:	00003597          	auipc	a1,0x3
    800054d6:	23e58593          	addi	a1,a1,574 # 80008710 <syscalls+0x2c8>
    800054da:	fb040513          	addi	a0,s0,-80
    800054de:	ffffe097          	auipc	ra,0xffffe
    800054e2:	6ce080e7          	jalr	1742(ra) # 80003bac <namecmp>
    800054e6:	14050a63          	beqz	a0,8000563a <sys_unlink+0x1b0>
    800054ea:	00003597          	auipc	a1,0x3
    800054ee:	22e58593          	addi	a1,a1,558 # 80008718 <syscalls+0x2d0>
    800054f2:	fb040513          	addi	a0,s0,-80
    800054f6:	ffffe097          	auipc	ra,0xffffe
    800054fa:	6b6080e7          	jalr	1718(ra) # 80003bac <namecmp>
    800054fe:	12050e63          	beqz	a0,8000563a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005502:	f2c40613          	addi	a2,s0,-212
    80005506:	fb040593          	addi	a1,s0,-80
    8000550a:	8526                	mv	a0,s1
    8000550c:	ffffe097          	auipc	ra,0xffffe
    80005510:	6ba080e7          	jalr	1722(ra) # 80003bc6 <dirlookup>
    80005514:	892a                	mv	s2,a0
    80005516:	12050263          	beqz	a0,8000563a <sys_unlink+0x1b0>
  ilock(ip);
    8000551a:	ffffe097          	auipc	ra,0xffffe
    8000551e:	1c8080e7          	jalr	456(ra) # 800036e2 <ilock>
  if(ip->nlink < 1)
    80005522:	04a91783          	lh	a5,74(s2)
    80005526:	08f05263          	blez	a5,800055aa <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000552a:	04491703          	lh	a4,68(s2)
    8000552e:	4785                	li	a5,1
    80005530:	08f70563          	beq	a4,a5,800055ba <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005534:	4641                	li	a2,16
    80005536:	4581                	li	a1,0
    80005538:	fc040513          	addi	a0,s0,-64
    8000553c:	ffffb097          	auipc	ra,0xffffb
    80005540:	790080e7          	jalr	1936(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005544:	4741                	li	a4,16
    80005546:	f2c42683          	lw	a3,-212(s0)
    8000554a:	fc040613          	addi	a2,s0,-64
    8000554e:	4581                	li	a1,0
    80005550:	8526                	mv	a0,s1
    80005552:	ffffe097          	auipc	ra,0xffffe
    80005556:	53c080e7          	jalr	1340(ra) # 80003a8e <writei>
    8000555a:	47c1                	li	a5,16
    8000555c:	0af51563          	bne	a0,a5,80005606 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005560:	04491703          	lh	a4,68(s2)
    80005564:	4785                	li	a5,1
    80005566:	0af70863          	beq	a4,a5,80005616 <sys_unlink+0x18c>
  iunlockput(dp);
    8000556a:	8526                	mv	a0,s1
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	3d8080e7          	jalr	984(ra) # 80003944 <iunlockput>
  ip->nlink--;
    80005574:	04a95783          	lhu	a5,74(s2)
    80005578:	37fd                	addiw	a5,a5,-1
    8000557a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000557e:	854a                	mv	a0,s2
    80005580:	ffffe097          	auipc	ra,0xffffe
    80005584:	098080e7          	jalr	152(ra) # 80003618 <iupdate>
  iunlockput(ip);
    80005588:	854a                	mv	a0,s2
    8000558a:	ffffe097          	auipc	ra,0xffffe
    8000558e:	3ba080e7          	jalr	954(ra) # 80003944 <iunlockput>
  end_op();
    80005592:	fffff097          	auipc	ra,0xfffff
    80005596:	ba2080e7          	jalr	-1118(ra) # 80004134 <end_op>
  return 0;
    8000559a:	4501                	li	a0,0
    8000559c:	a84d                	j	8000564e <sys_unlink+0x1c4>
    end_op();
    8000559e:	fffff097          	auipc	ra,0xfffff
    800055a2:	b96080e7          	jalr	-1130(ra) # 80004134 <end_op>
    return -1;
    800055a6:	557d                	li	a0,-1
    800055a8:	a05d                	j	8000564e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800055aa:	00003517          	auipc	a0,0x3
    800055ae:	19650513          	addi	a0,a0,406 # 80008740 <syscalls+0x2f8>
    800055b2:	ffffb097          	auipc	ra,0xffffb
    800055b6:	f86080e7          	jalr	-122(ra) # 80000538 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055ba:	04c92703          	lw	a4,76(s2)
    800055be:	02000793          	li	a5,32
    800055c2:	f6e7f9e3          	bgeu	a5,a4,80005534 <sys_unlink+0xaa>
    800055c6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055ca:	4741                	li	a4,16
    800055cc:	86ce                	mv	a3,s3
    800055ce:	f1840613          	addi	a2,s0,-232
    800055d2:	4581                	li	a1,0
    800055d4:	854a                	mv	a0,s2
    800055d6:	ffffe097          	auipc	ra,0xffffe
    800055da:	3c0080e7          	jalr	960(ra) # 80003996 <readi>
    800055de:	47c1                	li	a5,16
    800055e0:	00f51b63          	bne	a0,a5,800055f6 <sys_unlink+0x16c>
    if(de.inum != 0)
    800055e4:	f1845783          	lhu	a5,-232(s0)
    800055e8:	e7a1                	bnez	a5,80005630 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055ea:	29c1                	addiw	s3,s3,16
    800055ec:	04c92783          	lw	a5,76(s2)
    800055f0:	fcf9ede3          	bltu	s3,a5,800055ca <sys_unlink+0x140>
    800055f4:	b781                	j	80005534 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800055f6:	00003517          	auipc	a0,0x3
    800055fa:	16250513          	addi	a0,a0,354 # 80008758 <syscalls+0x310>
    800055fe:	ffffb097          	auipc	ra,0xffffb
    80005602:	f3a080e7          	jalr	-198(ra) # 80000538 <panic>
    panic("unlink: writei");
    80005606:	00003517          	auipc	a0,0x3
    8000560a:	16a50513          	addi	a0,a0,362 # 80008770 <syscalls+0x328>
    8000560e:	ffffb097          	auipc	ra,0xffffb
    80005612:	f2a080e7          	jalr	-214(ra) # 80000538 <panic>
    dp->nlink--;
    80005616:	04a4d783          	lhu	a5,74(s1)
    8000561a:	37fd                	addiw	a5,a5,-1
    8000561c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005620:	8526                	mv	a0,s1
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	ff6080e7          	jalr	-10(ra) # 80003618 <iupdate>
    8000562a:	b781                	j	8000556a <sys_unlink+0xe0>
    return -1;
    8000562c:	557d                	li	a0,-1
    8000562e:	a005                	j	8000564e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005630:	854a                	mv	a0,s2
    80005632:	ffffe097          	auipc	ra,0xffffe
    80005636:	312080e7          	jalr	786(ra) # 80003944 <iunlockput>
  iunlockput(dp);
    8000563a:	8526                	mv	a0,s1
    8000563c:	ffffe097          	auipc	ra,0xffffe
    80005640:	308080e7          	jalr	776(ra) # 80003944 <iunlockput>
  end_op();
    80005644:	fffff097          	auipc	ra,0xfffff
    80005648:	af0080e7          	jalr	-1296(ra) # 80004134 <end_op>
  return -1;
    8000564c:	557d                	li	a0,-1
}
    8000564e:	70ae                	ld	ra,232(sp)
    80005650:	740e                	ld	s0,224(sp)
    80005652:	64ee                	ld	s1,216(sp)
    80005654:	694e                	ld	s2,208(sp)
    80005656:	69ae                	ld	s3,200(sp)
    80005658:	616d                	addi	sp,sp,240
    8000565a:	8082                	ret

000000008000565c <sys_open>:

uint64
sys_open(void)
{
    8000565c:	7131                	addi	sp,sp,-192
    8000565e:	fd06                	sd	ra,184(sp)
    80005660:	f922                	sd	s0,176(sp)
    80005662:	f526                	sd	s1,168(sp)
    80005664:	f14a                	sd	s2,160(sp)
    80005666:	ed4e                	sd	s3,152(sp)
    80005668:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000566a:	08000613          	li	a2,128
    8000566e:	f5040593          	addi	a1,s0,-176
    80005672:	4501                	li	a0,0
    80005674:	ffffd097          	auipc	ra,0xffffd
    80005678:	52e080e7          	jalr	1326(ra) # 80002ba2 <argstr>
    return -1;
    8000567c:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000567e:	0c054163          	bltz	a0,80005740 <sys_open+0xe4>
    80005682:	f4c40593          	addi	a1,s0,-180
    80005686:	4505                	li	a0,1
    80005688:	ffffd097          	auipc	ra,0xffffd
    8000568c:	4d6080e7          	jalr	1238(ra) # 80002b5e <argint>
    80005690:	0a054863          	bltz	a0,80005740 <sys_open+0xe4>

  begin_op();
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	a20080e7          	jalr	-1504(ra) # 800040b4 <begin_op>

  if(omode & O_CREATE){
    8000569c:	f4c42783          	lw	a5,-180(s0)
    800056a0:	2007f793          	andi	a5,a5,512
    800056a4:	cbdd                	beqz	a5,8000575a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056a6:	4681                	li	a3,0
    800056a8:	4601                	li	a2,0
    800056aa:	4589                	li	a1,2
    800056ac:	f5040513          	addi	a0,s0,-176
    800056b0:	00000097          	auipc	ra,0x0
    800056b4:	974080e7          	jalr	-1676(ra) # 80005024 <create>
    800056b8:	892a                	mv	s2,a0
    if(ip == 0){
    800056ba:	c959                	beqz	a0,80005750 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056bc:	04491703          	lh	a4,68(s2)
    800056c0:	478d                	li	a5,3
    800056c2:	00f71763          	bne	a4,a5,800056d0 <sys_open+0x74>
    800056c6:	04695703          	lhu	a4,70(s2)
    800056ca:	47a5                	li	a5,9
    800056cc:	0ce7ec63          	bltu	a5,a4,800057a4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	df4080e7          	jalr	-524(ra) # 800044c4 <filealloc>
    800056d8:	89aa                	mv	s3,a0
    800056da:	10050263          	beqz	a0,800057de <sys_open+0x182>
    800056de:	00000097          	auipc	ra,0x0
    800056e2:	904080e7          	jalr	-1788(ra) # 80004fe2 <fdalloc>
    800056e6:	84aa                	mv	s1,a0
    800056e8:	0e054663          	bltz	a0,800057d4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056ec:	04491703          	lh	a4,68(s2)
    800056f0:	478d                	li	a5,3
    800056f2:	0cf70463          	beq	a4,a5,800057ba <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800056f6:	4789                	li	a5,2
    800056f8:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800056fc:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005700:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005704:	f4c42783          	lw	a5,-180(s0)
    80005708:	0017c713          	xori	a4,a5,1
    8000570c:	8b05                	andi	a4,a4,1
    8000570e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005712:	0037f713          	andi	a4,a5,3
    80005716:	00e03733          	snez	a4,a4
    8000571a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000571e:	4007f793          	andi	a5,a5,1024
    80005722:	c791                	beqz	a5,8000572e <sys_open+0xd2>
    80005724:	04491703          	lh	a4,68(s2)
    80005728:	4789                	li	a5,2
    8000572a:	08f70f63          	beq	a4,a5,800057c8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000572e:	854a                	mv	a0,s2
    80005730:	ffffe097          	auipc	ra,0xffffe
    80005734:	074080e7          	jalr	116(ra) # 800037a4 <iunlock>
  end_op();
    80005738:	fffff097          	auipc	ra,0xfffff
    8000573c:	9fc080e7          	jalr	-1540(ra) # 80004134 <end_op>

  return fd;
}
    80005740:	8526                	mv	a0,s1
    80005742:	70ea                	ld	ra,184(sp)
    80005744:	744a                	ld	s0,176(sp)
    80005746:	74aa                	ld	s1,168(sp)
    80005748:	790a                	ld	s2,160(sp)
    8000574a:	69ea                	ld	s3,152(sp)
    8000574c:	6129                	addi	sp,sp,192
    8000574e:	8082                	ret
      end_op();
    80005750:	fffff097          	auipc	ra,0xfffff
    80005754:	9e4080e7          	jalr	-1564(ra) # 80004134 <end_op>
      return -1;
    80005758:	b7e5                	j	80005740 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000575a:	f5040513          	addi	a0,s0,-176
    8000575e:	ffffe097          	auipc	ra,0xffffe
    80005762:	73a080e7          	jalr	1850(ra) # 80003e98 <namei>
    80005766:	892a                	mv	s2,a0
    80005768:	c905                	beqz	a0,80005798 <sys_open+0x13c>
    ilock(ip);
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	f78080e7          	jalr	-136(ra) # 800036e2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005772:	04491703          	lh	a4,68(s2)
    80005776:	4785                	li	a5,1
    80005778:	f4f712e3          	bne	a4,a5,800056bc <sys_open+0x60>
    8000577c:	f4c42783          	lw	a5,-180(s0)
    80005780:	dba1                	beqz	a5,800056d0 <sys_open+0x74>
      iunlockput(ip);
    80005782:	854a                	mv	a0,s2
    80005784:	ffffe097          	auipc	ra,0xffffe
    80005788:	1c0080e7          	jalr	448(ra) # 80003944 <iunlockput>
      end_op();
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	9a8080e7          	jalr	-1624(ra) # 80004134 <end_op>
      return -1;
    80005794:	54fd                	li	s1,-1
    80005796:	b76d                	j	80005740 <sys_open+0xe4>
      end_op();
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	99c080e7          	jalr	-1636(ra) # 80004134 <end_op>
      return -1;
    800057a0:	54fd                	li	s1,-1
    800057a2:	bf79                	j	80005740 <sys_open+0xe4>
    iunlockput(ip);
    800057a4:	854a                	mv	a0,s2
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	19e080e7          	jalr	414(ra) # 80003944 <iunlockput>
    end_op();
    800057ae:	fffff097          	auipc	ra,0xfffff
    800057b2:	986080e7          	jalr	-1658(ra) # 80004134 <end_op>
    return -1;
    800057b6:	54fd                	li	s1,-1
    800057b8:	b761                	j	80005740 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800057ba:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800057be:	04691783          	lh	a5,70(s2)
    800057c2:	02f99223          	sh	a5,36(s3)
    800057c6:	bf2d                	j	80005700 <sys_open+0xa4>
    itrunc(ip);
    800057c8:	854a                	mv	a0,s2
    800057ca:	ffffe097          	auipc	ra,0xffffe
    800057ce:	026080e7          	jalr	38(ra) # 800037f0 <itrunc>
    800057d2:	bfb1                	j	8000572e <sys_open+0xd2>
      fileclose(f);
    800057d4:	854e                	mv	a0,s3
    800057d6:	fffff097          	auipc	ra,0xfffff
    800057da:	daa080e7          	jalr	-598(ra) # 80004580 <fileclose>
    iunlockput(ip);
    800057de:	854a                	mv	a0,s2
    800057e0:	ffffe097          	auipc	ra,0xffffe
    800057e4:	164080e7          	jalr	356(ra) # 80003944 <iunlockput>
    end_op();
    800057e8:	fffff097          	auipc	ra,0xfffff
    800057ec:	94c080e7          	jalr	-1716(ra) # 80004134 <end_op>
    return -1;
    800057f0:	54fd                	li	s1,-1
    800057f2:	b7b9                	j	80005740 <sys_open+0xe4>

00000000800057f4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057f4:	7175                	addi	sp,sp,-144
    800057f6:	e506                	sd	ra,136(sp)
    800057f8:	e122                	sd	s0,128(sp)
    800057fa:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	8b8080e7          	jalr	-1864(ra) # 800040b4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005804:	08000613          	li	a2,128
    80005808:	f7040593          	addi	a1,s0,-144
    8000580c:	4501                	li	a0,0
    8000580e:	ffffd097          	auipc	ra,0xffffd
    80005812:	394080e7          	jalr	916(ra) # 80002ba2 <argstr>
    80005816:	02054963          	bltz	a0,80005848 <sys_mkdir+0x54>
    8000581a:	4681                	li	a3,0
    8000581c:	4601                	li	a2,0
    8000581e:	4585                	li	a1,1
    80005820:	f7040513          	addi	a0,s0,-144
    80005824:	00000097          	auipc	ra,0x0
    80005828:	800080e7          	jalr	-2048(ra) # 80005024 <create>
    8000582c:	cd11                	beqz	a0,80005848 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000582e:	ffffe097          	auipc	ra,0xffffe
    80005832:	116080e7          	jalr	278(ra) # 80003944 <iunlockput>
  end_op();
    80005836:	fffff097          	auipc	ra,0xfffff
    8000583a:	8fe080e7          	jalr	-1794(ra) # 80004134 <end_op>
  return 0;
    8000583e:	4501                	li	a0,0
}
    80005840:	60aa                	ld	ra,136(sp)
    80005842:	640a                	ld	s0,128(sp)
    80005844:	6149                	addi	sp,sp,144
    80005846:	8082                	ret
    end_op();
    80005848:	fffff097          	auipc	ra,0xfffff
    8000584c:	8ec080e7          	jalr	-1812(ra) # 80004134 <end_op>
    return -1;
    80005850:	557d                	li	a0,-1
    80005852:	b7fd                	j	80005840 <sys_mkdir+0x4c>

0000000080005854 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005854:	7135                	addi	sp,sp,-160
    80005856:	ed06                	sd	ra,152(sp)
    80005858:	e922                	sd	s0,144(sp)
    8000585a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	858080e7          	jalr	-1960(ra) # 800040b4 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005864:	08000613          	li	a2,128
    80005868:	f7040593          	addi	a1,s0,-144
    8000586c:	4501                	li	a0,0
    8000586e:	ffffd097          	auipc	ra,0xffffd
    80005872:	334080e7          	jalr	820(ra) # 80002ba2 <argstr>
    80005876:	04054a63          	bltz	a0,800058ca <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000587a:	f6c40593          	addi	a1,s0,-148
    8000587e:	4505                	li	a0,1
    80005880:	ffffd097          	auipc	ra,0xffffd
    80005884:	2de080e7          	jalr	734(ra) # 80002b5e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005888:	04054163          	bltz	a0,800058ca <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000588c:	f6840593          	addi	a1,s0,-152
    80005890:	4509                	li	a0,2
    80005892:	ffffd097          	auipc	ra,0xffffd
    80005896:	2cc080e7          	jalr	716(ra) # 80002b5e <argint>
     argint(1, &major) < 0 ||
    8000589a:	02054863          	bltz	a0,800058ca <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000589e:	f6841683          	lh	a3,-152(s0)
    800058a2:	f6c41603          	lh	a2,-148(s0)
    800058a6:	458d                	li	a1,3
    800058a8:	f7040513          	addi	a0,s0,-144
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	778080e7          	jalr	1912(ra) # 80005024 <create>
     argint(2, &minor) < 0 ||
    800058b4:	c919                	beqz	a0,800058ca <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058b6:	ffffe097          	auipc	ra,0xffffe
    800058ba:	08e080e7          	jalr	142(ra) # 80003944 <iunlockput>
  end_op();
    800058be:	fffff097          	auipc	ra,0xfffff
    800058c2:	876080e7          	jalr	-1930(ra) # 80004134 <end_op>
  return 0;
    800058c6:	4501                	li	a0,0
    800058c8:	a031                	j	800058d4 <sys_mknod+0x80>
    end_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	86a080e7          	jalr	-1942(ra) # 80004134 <end_op>
    return -1;
    800058d2:	557d                	li	a0,-1
}
    800058d4:	60ea                	ld	ra,152(sp)
    800058d6:	644a                	ld	s0,144(sp)
    800058d8:	610d                	addi	sp,sp,160
    800058da:	8082                	ret

00000000800058dc <sys_chdir>:

uint64
sys_chdir(void)
{
    800058dc:	7135                	addi	sp,sp,-160
    800058de:	ed06                	sd	ra,152(sp)
    800058e0:	e922                	sd	s0,144(sp)
    800058e2:	e526                	sd	s1,136(sp)
    800058e4:	e14a                	sd	s2,128(sp)
    800058e6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058e8:	ffffc097          	auipc	ra,0xffffc
    800058ec:	0ca080e7          	jalr	202(ra) # 800019b2 <myproc>
    800058f0:	892a                	mv	s2,a0
  
  begin_op();
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	7c2080e7          	jalr	1986(ra) # 800040b4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800058fa:	08000613          	li	a2,128
    800058fe:	f6040593          	addi	a1,s0,-160
    80005902:	4501                	li	a0,0
    80005904:	ffffd097          	auipc	ra,0xffffd
    80005908:	29e080e7          	jalr	670(ra) # 80002ba2 <argstr>
    8000590c:	04054b63          	bltz	a0,80005962 <sys_chdir+0x86>
    80005910:	f6040513          	addi	a0,s0,-160
    80005914:	ffffe097          	auipc	ra,0xffffe
    80005918:	584080e7          	jalr	1412(ra) # 80003e98 <namei>
    8000591c:	84aa                	mv	s1,a0
    8000591e:	c131                	beqz	a0,80005962 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	dc2080e7          	jalr	-574(ra) # 800036e2 <ilock>
  if(ip->type != T_DIR){
    80005928:	04449703          	lh	a4,68(s1)
    8000592c:	4785                	li	a5,1
    8000592e:	04f71063          	bne	a4,a5,8000596e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005932:	8526                	mv	a0,s1
    80005934:	ffffe097          	auipc	ra,0xffffe
    80005938:	e70080e7          	jalr	-400(ra) # 800037a4 <iunlock>
  iput(p->cwd);
    8000593c:	15093503          	ld	a0,336(s2)
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	f5c080e7          	jalr	-164(ra) # 8000389c <iput>
  end_op();
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	7ec080e7          	jalr	2028(ra) # 80004134 <end_op>
  p->cwd = ip;
    80005950:	14993823          	sd	s1,336(s2)
  return 0;
    80005954:	4501                	li	a0,0
}
    80005956:	60ea                	ld	ra,152(sp)
    80005958:	644a                	ld	s0,144(sp)
    8000595a:	64aa                	ld	s1,136(sp)
    8000595c:	690a                	ld	s2,128(sp)
    8000595e:	610d                	addi	sp,sp,160
    80005960:	8082                	ret
    end_op();
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	7d2080e7          	jalr	2002(ra) # 80004134 <end_op>
    return -1;
    8000596a:	557d                	li	a0,-1
    8000596c:	b7ed                	j	80005956 <sys_chdir+0x7a>
    iunlockput(ip);
    8000596e:	8526                	mv	a0,s1
    80005970:	ffffe097          	auipc	ra,0xffffe
    80005974:	fd4080e7          	jalr	-44(ra) # 80003944 <iunlockput>
    end_op();
    80005978:	ffffe097          	auipc	ra,0xffffe
    8000597c:	7bc080e7          	jalr	1980(ra) # 80004134 <end_op>
    return -1;
    80005980:	557d                	li	a0,-1
    80005982:	bfd1                	j	80005956 <sys_chdir+0x7a>

0000000080005984 <sys_exec>:

uint64
sys_exec(void)
{
    80005984:	7145                	addi	sp,sp,-464
    80005986:	e786                	sd	ra,456(sp)
    80005988:	e3a2                	sd	s0,448(sp)
    8000598a:	ff26                	sd	s1,440(sp)
    8000598c:	fb4a                	sd	s2,432(sp)
    8000598e:	f74e                	sd	s3,424(sp)
    80005990:	f352                	sd	s4,416(sp)
    80005992:	ef56                	sd	s5,408(sp)
    80005994:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005996:	08000613          	li	a2,128
    8000599a:	f4040593          	addi	a1,s0,-192
    8000599e:	4501                	li	a0,0
    800059a0:	ffffd097          	auipc	ra,0xffffd
    800059a4:	202080e7          	jalr	514(ra) # 80002ba2 <argstr>
    return -1;
    800059a8:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059aa:	0c054a63          	bltz	a0,80005a7e <sys_exec+0xfa>
    800059ae:	e3840593          	addi	a1,s0,-456
    800059b2:	4505                	li	a0,1
    800059b4:	ffffd097          	auipc	ra,0xffffd
    800059b8:	1cc080e7          	jalr	460(ra) # 80002b80 <argaddr>
    800059bc:	0c054163          	bltz	a0,80005a7e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800059c0:	10000613          	li	a2,256
    800059c4:	4581                	li	a1,0
    800059c6:	e4040513          	addi	a0,s0,-448
    800059ca:	ffffb097          	auipc	ra,0xffffb
    800059ce:	302080e7          	jalr	770(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059d2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800059d6:	89a6                	mv	s3,s1
    800059d8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800059da:	02000a13          	li	s4,32
    800059de:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800059e2:	00391793          	slli	a5,s2,0x3
    800059e6:	e3040593          	addi	a1,s0,-464
    800059ea:	e3843503          	ld	a0,-456(s0)
    800059ee:	953e                	add	a0,a0,a5
    800059f0:	ffffd097          	auipc	ra,0xffffd
    800059f4:	0d4080e7          	jalr	212(ra) # 80002ac4 <fetchaddr>
    800059f8:	02054a63          	bltz	a0,80005a2c <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800059fc:	e3043783          	ld	a5,-464(s0)
    80005a00:	c3b9                	beqz	a5,80005a46 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a02:	ffffb097          	auipc	ra,0xffffb
    80005a06:	0de080e7          	jalr	222(ra) # 80000ae0 <kalloc>
    80005a0a:	85aa                	mv	a1,a0
    80005a0c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a10:	cd11                	beqz	a0,80005a2c <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a12:	6605                	lui	a2,0x1
    80005a14:	e3043503          	ld	a0,-464(s0)
    80005a18:	ffffd097          	auipc	ra,0xffffd
    80005a1c:	0fe080e7          	jalr	254(ra) # 80002b16 <fetchstr>
    80005a20:	00054663          	bltz	a0,80005a2c <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005a24:	0905                	addi	s2,s2,1
    80005a26:	09a1                	addi	s3,s3,8
    80005a28:	fb491be3          	bne	s2,s4,800059de <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a2c:	10048913          	addi	s2,s1,256
    80005a30:	6088                	ld	a0,0(s1)
    80005a32:	c529                	beqz	a0,80005a7c <sys_exec+0xf8>
    kfree(argv[i]);
    80005a34:	ffffb097          	auipc	ra,0xffffb
    80005a38:	fb0080e7          	jalr	-80(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a3c:	04a1                	addi	s1,s1,8
    80005a3e:	ff2499e3          	bne	s1,s2,80005a30 <sys_exec+0xac>
  return -1;
    80005a42:	597d                	li	s2,-1
    80005a44:	a82d                	j	80005a7e <sys_exec+0xfa>
      argv[i] = 0;
    80005a46:	0a8e                	slli	s5,s5,0x3
    80005a48:	fc040793          	addi	a5,s0,-64
    80005a4c:	9abe                	add	s5,s5,a5
    80005a4e:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffdcdc0>
  int ret = exec(path, argv);
    80005a52:	e4040593          	addi	a1,s0,-448
    80005a56:	f4040513          	addi	a0,s0,-192
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	178080e7          	jalr	376(ra) # 80004bd2 <exec>
    80005a62:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a64:	10048993          	addi	s3,s1,256
    80005a68:	6088                	ld	a0,0(s1)
    80005a6a:	c911                	beqz	a0,80005a7e <sys_exec+0xfa>
    kfree(argv[i]);
    80005a6c:	ffffb097          	auipc	ra,0xffffb
    80005a70:	f78080e7          	jalr	-136(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a74:	04a1                	addi	s1,s1,8
    80005a76:	ff3499e3          	bne	s1,s3,80005a68 <sys_exec+0xe4>
    80005a7a:	a011                	j	80005a7e <sys_exec+0xfa>
  return -1;
    80005a7c:	597d                	li	s2,-1
}
    80005a7e:	854a                	mv	a0,s2
    80005a80:	60be                	ld	ra,456(sp)
    80005a82:	641e                	ld	s0,448(sp)
    80005a84:	74fa                	ld	s1,440(sp)
    80005a86:	795a                	ld	s2,432(sp)
    80005a88:	79ba                	ld	s3,424(sp)
    80005a8a:	7a1a                	ld	s4,416(sp)
    80005a8c:	6afa                	ld	s5,408(sp)
    80005a8e:	6179                	addi	sp,sp,464
    80005a90:	8082                	ret

0000000080005a92 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a92:	7139                	addi	sp,sp,-64
    80005a94:	fc06                	sd	ra,56(sp)
    80005a96:	f822                	sd	s0,48(sp)
    80005a98:	f426                	sd	s1,40(sp)
    80005a9a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a9c:	ffffc097          	auipc	ra,0xffffc
    80005aa0:	f16080e7          	jalr	-234(ra) # 800019b2 <myproc>
    80005aa4:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005aa6:	fd840593          	addi	a1,s0,-40
    80005aaa:	4501                	li	a0,0
    80005aac:	ffffd097          	auipc	ra,0xffffd
    80005ab0:	0d4080e7          	jalr	212(ra) # 80002b80 <argaddr>
    return -1;
    80005ab4:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005ab6:	0e054063          	bltz	a0,80005b96 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005aba:	fc840593          	addi	a1,s0,-56
    80005abe:	fd040513          	addi	a0,s0,-48
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	dee080e7          	jalr	-530(ra) # 800048b0 <pipealloc>
    return -1;
    80005aca:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005acc:	0c054563          	bltz	a0,80005b96 <sys_pipe+0x104>
  fd0 = -1;
    80005ad0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ad4:	fd043503          	ld	a0,-48(s0)
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	50a080e7          	jalr	1290(ra) # 80004fe2 <fdalloc>
    80005ae0:	fca42223          	sw	a0,-60(s0)
    80005ae4:	08054c63          	bltz	a0,80005b7c <sys_pipe+0xea>
    80005ae8:	fc843503          	ld	a0,-56(s0)
    80005aec:	fffff097          	auipc	ra,0xfffff
    80005af0:	4f6080e7          	jalr	1270(ra) # 80004fe2 <fdalloc>
    80005af4:	fca42023          	sw	a0,-64(s0)
    80005af8:	06054863          	bltz	a0,80005b68 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005afc:	4691                	li	a3,4
    80005afe:	fc440613          	addi	a2,s0,-60
    80005b02:	fd843583          	ld	a1,-40(s0)
    80005b06:	68a8                	ld	a0,80(s1)
    80005b08:	ffffc097          	auipc	ra,0xffffc
    80005b0c:	b4e080e7          	jalr	-1202(ra) # 80001656 <copyout>
    80005b10:	02054063          	bltz	a0,80005b30 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b14:	4691                	li	a3,4
    80005b16:	fc040613          	addi	a2,s0,-64
    80005b1a:	fd843583          	ld	a1,-40(s0)
    80005b1e:	0591                	addi	a1,a1,4
    80005b20:	68a8                	ld	a0,80(s1)
    80005b22:	ffffc097          	auipc	ra,0xffffc
    80005b26:	b34080e7          	jalr	-1228(ra) # 80001656 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b2a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b2c:	06055563          	bgez	a0,80005b96 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005b30:	fc442783          	lw	a5,-60(s0)
    80005b34:	07e9                	addi	a5,a5,26
    80005b36:	078e                	slli	a5,a5,0x3
    80005b38:	97a6                	add	a5,a5,s1
    80005b3a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b3e:	fc042503          	lw	a0,-64(s0)
    80005b42:	0569                	addi	a0,a0,26
    80005b44:	050e                	slli	a0,a0,0x3
    80005b46:	9526                	add	a0,a0,s1
    80005b48:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b4c:	fd043503          	ld	a0,-48(s0)
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	a30080e7          	jalr	-1488(ra) # 80004580 <fileclose>
    fileclose(wf);
    80005b58:	fc843503          	ld	a0,-56(s0)
    80005b5c:	fffff097          	auipc	ra,0xfffff
    80005b60:	a24080e7          	jalr	-1500(ra) # 80004580 <fileclose>
    return -1;
    80005b64:	57fd                	li	a5,-1
    80005b66:	a805                	j	80005b96 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005b68:	fc442783          	lw	a5,-60(s0)
    80005b6c:	0007c863          	bltz	a5,80005b7c <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005b70:	01a78513          	addi	a0,a5,26
    80005b74:	050e                	slli	a0,a0,0x3
    80005b76:	9526                	add	a0,a0,s1
    80005b78:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b7c:	fd043503          	ld	a0,-48(s0)
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	a00080e7          	jalr	-1536(ra) # 80004580 <fileclose>
    fileclose(wf);
    80005b88:	fc843503          	ld	a0,-56(s0)
    80005b8c:	fffff097          	auipc	ra,0xfffff
    80005b90:	9f4080e7          	jalr	-1548(ra) # 80004580 <fileclose>
    return -1;
    80005b94:	57fd                	li	a5,-1
}
    80005b96:	853e                	mv	a0,a5
    80005b98:	70e2                	ld	ra,56(sp)
    80005b9a:	7442                	ld	s0,48(sp)
    80005b9c:	74a2                	ld	s1,40(sp)
    80005b9e:	6121                	addi	sp,sp,64
    80005ba0:	8082                	ret
	...

0000000080005bb0 <kernelvec>:
    80005bb0:	7111                	addi	sp,sp,-256
    80005bb2:	e006                	sd	ra,0(sp)
    80005bb4:	e40a                	sd	sp,8(sp)
    80005bb6:	e80e                	sd	gp,16(sp)
    80005bb8:	ec12                	sd	tp,24(sp)
    80005bba:	f016                	sd	t0,32(sp)
    80005bbc:	f41a                	sd	t1,40(sp)
    80005bbe:	f81e                	sd	t2,48(sp)
    80005bc0:	fc22                	sd	s0,56(sp)
    80005bc2:	e0a6                	sd	s1,64(sp)
    80005bc4:	e4aa                	sd	a0,72(sp)
    80005bc6:	e8ae                	sd	a1,80(sp)
    80005bc8:	ecb2                	sd	a2,88(sp)
    80005bca:	f0b6                	sd	a3,96(sp)
    80005bcc:	f4ba                	sd	a4,104(sp)
    80005bce:	f8be                	sd	a5,112(sp)
    80005bd0:	fcc2                	sd	a6,120(sp)
    80005bd2:	e146                	sd	a7,128(sp)
    80005bd4:	e54a                	sd	s2,136(sp)
    80005bd6:	e94e                	sd	s3,144(sp)
    80005bd8:	ed52                	sd	s4,152(sp)
    80005bda:	f156                	sd	s5,160(sp)
    80005bdc:	f55a                	sd	s6,168(sp)
    80005bde:	f95e                	sd	s7,176(sp)
    80005be0:	fd62                	sd	s8,184(sp)
    80005be2:	e1e6                	sd	s9,192(sp)
    80005be4:	e5ea                	sd	s10,200(sp)
    80005be6:	e9ee                	sd	s11,208(sp)
    80005be8:	edf2                	sd	t3,216(sp)
    80005bea:	f1f6                	sd	t4,224(sp)
    80005bec:	f5fa                	sd	t5,232(sp)
    80005bee:	f9fe                	sd	t6,240(sp)
    80005bf0:	da1fc0ef          	jal	ra,80002990 <kerneltrap>
    80005bf4:	6082                	ld	ra,0(sp)
    80005bf6:	6122                	ld	sp,8(sp)
    80005bf8:	61c2                	ld	gp,16(sp)
    80005bfa:	7282                	ld	t0,32(sp)
    80005bfc:	7322                	ld	t1,40(sp)
    80005bfe:	73c2                	ld	t2,48(sp)
    80005c00:	7462                	ld	s0,56(sp)
    80005c02:	6486                	ld	s1,64(sp)
    80005c04:	6526                	ld	a0,72(sp)
    80005c06:	65c6                	ld	a1,80(sp)
    80005c08:	6666                	ld	a2,88(sp)
    80005c0a:	7686                	ld	a3,96(sp)
    80005c0c:	7726                	ld	a4,104(sp)
    80005c0e:	77c6                	ld	a5,112(sp)
    80005c10:	7866                	ld	a6,120(sp)
    80005c12:	688a                	ld	a7,128(sp)
    80005c14:	692a                	ld	s2,136(sp)
    80005c16:	69ca                	ld	s3,144(sp)
    80005c18:	6a6a                	ld	s4,152(sp)
    80005c1a:	7a8a                	ld	s5,160(sp)
    80005c1c:	7b2a                	ld	s6,168(sp)
    80005c1e:	7bca                	ld	s7,176(sp)
    80005c20:	7c6a                	ld	s8,184(sp)
    80005c22:	6c8e                	ld	s9,192(sp)
    80005c24:	6d2e                	ld	s10,200(sp)
    80005c26:	6dce                	ld	s11,208(sp)
    80005c28:	6e6e                	ld	t3,216(sp)
    80005c2a:	7e8e                	ld	t4,224(sp)
    80005c2c:	7f2e                	ld	t5,232(sp)
    80005c2e:	7fce                	ld	t6,240(sp)
    80005c30:	6111                	addi	sp,sp,256
    80005c32:	10200073          	sret
    80005c36:	00000013          	nop
    80005c3a:	00000013          	nop
    80005c3e:	0001                	nop

0000000080005c40 <timervec>:
    80005c40:	34051573          	csrrw	a0,mscratch,a0
    80005c44:	e10c                	sd	a1,0(a0)
    80005c46:	e510                	sd	a2,8(a0)
    80005c48:	e914                	sd	a3,16(a0)
    80005c4a:	6d0c                	ld	a1,24(a0)
    80005c4c:	7110                	ld	a2,32(a0)
    80005c4e:	6194                	ld	a3,0(a1)
    80005c50:	96b2                	add	a3,a3,a2
    80005c52:	e194                	sd	a3,0(a1)
    80005c54:	4589                	li	a1,2
    80005c56:	14459073          	csrw	sip,a1
    80005c5a:	6914                	ld	a3,16(a0)
    80005c5c:	6510                	ld	a2,8(a0)
    80005c5e:	610c                	ld	a1,0(a0)
    80005c60:	34051573          	csrrw	a0,mscratch,a0
    80005c64:	30200073          	mret
	...

0000000080005c6a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c6a:	1141                	addi	sp,sp,-16
    80005c6c:	e422                	sd	s0,8(sp)
    80005c6e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c70:	0c0007b7          	lui	a5,0xc000
    80005c74:	4705                	li	a4,1
    80005c76:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c78:	c3d8                	sw	a4,4(a5)
}
    80005c7a:	6422                	ld	s0,8(sp)
    80005c7c:	0141                	addi	sp,sp,16
    80005c7e:	8082                	ret

0000000080005c80 <plicinithart>:

void
plicinithart(void)
{
    80005c80:	1141                	addi	sp,sp,-16
    80005c82:	e406                	sd	ra,8(sp)
    80005c84:	e022                	sd	s0,0(sp)
    80005c86:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c88:	ffffc097          	auipc	ra,0xffffc
    80005c8c:	cfe080e7          	jalr	-770(ra) # 80001986 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c90:	0085171b          	slliw	a4,a0,0x8
    80005c94:	0c0027b7          	lui	a5,0xc002
    80005c98:	97ba                	add	a5,a5,a4
    80005c9a:	40200713          	li	a4,1026
    80005c9e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ca2:	00d5151b          	slliw	a0,a0,0xd
    80005ca6:	0c2017b7          	lui	a5,0xc201
    80005caa:	953e                	add	a0,a0,a5
    80005cac:	00052023          	sw	zero,0(a0)
}
    80005cb0:	60a2                	ld	ra,8(sp)
    80005cb2:	6402                	ld	s0,0(sp)
    80005cb4:	0141                	addi	sp,sp,16
    80005cb6:	8082                	ret

0000000080005cb8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005cb8:	1141                	addi	sp,sp,-16
    80005cba:	e406                	sd	ra,8(sp)
    80005cbc:	e022                	sd	s0,0(sp)
    80005cbe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cc0:	ffffc097          	auipc	ra,0xffffc
    80005cc4:	cc6080e7          	jalr	-826(ra) # 80001986 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005cc8:	00d5179b          	slliw	a5,a0,0xd
    80005ccc:	0c201537          	lui	a0,0xc201
    80005cd0:	953e                	add	a0,a0,a5
  return irq;
}
    80005cd2:	4148                	lw	a0,4(a0)
    80005cd4:	60a2                	ld	ra,8(sp)
    80005cd6:	6402                	ld	s0,0(sp)
    80005cd8:	0141                	addi	sp,sp,16
    80005cda:	8082                	ret

0000000080005cdc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005cdc:	1101                	addi	sp,sp,-32
    80005cde:	ec06                	sd	ra,24(sp)
    80005ce0:	e822                	sd	s0,16(sp)
    80005ce2:	e426                	sd	s1,8(sp)
    80005ce4:	1000                	addi	s0,sp,32
    80005ce6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ce8:	ffffc097          	auipc	ra,0xffffc
    80005cec:	c9e080e7          	jalr	-866(ra) # 80001986 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005cf0:	00d5151b          	slliw	a0,a0,0xd
    80005cf4:	0c2017b7          	lui	a5,0xc201
    80005cf8:	97aa                	add	a5,a5,a0
    80005cfa:	c3c4                	sw	s1,4(a5)
}
    80005cfc:	60e2                	ld	ra,24(sp)
    80005cfe:	6442                	ld	s0,16(sp)
    80005d00:	64a2                	ld	s1,8(sp)
    80005d02:	6105                	addi	sp,sp,32
    80005d04:	8082                	ret

0000000080005d06 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d06:	1141                	addi	sp,sp,-16
    80005d08:	e406                	sd	ra,8(sp)
    80005d0a:	e022                	sd	s0,0(sp)
    80005d0c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d0e:	479d                	li	a5,7
    80005d10:	04a7cc63          	blt	a5,a0,80005d68 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d14:	0001c797          	auipc	a5,0x1c
    80005d18:	26c78793          	addi	a5,a5,620 # 80021f80 <disk>
    80005d1c:	97aa                	add	a5,a5,a0
    80005d1e:	0187c783          	lbu	a5,24(a5)
    80005d22:	ebb9                	bnez	a5,80005d78 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d24:	00451613          	slli	a2,a0,0x4
    80005d28:	0001c797          	auipc	a5,0x1c
    80005d2c:	25878793          	addi	a5,a5,600 # 80021f80 <disk>
    80005d30:	6394                	ld	a3,0(a5)
    80005d32:	96b2                	add	a3,a3,a2
    80005d34:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005d38:	6398                	ld	a4,0(a5)
    80005d3a:	9732                	add	a4,a4,a2
    80005d3c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d40:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d44:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d48:	953e                	add	a0,a0,a5
    80005d4a:	4785                	li	a5,1
    80005d4c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005d50:	0001c517          	auipc	a0,0x1c
    80005d54:	24850513          	addi	a0,a0,584 # 80021f98 <disk+0x18>
    80005d58:	ffffc097          	auipc	ra,0xffffc
    80005d5c:	5aa080e7          	jalr	1450(ra) # 80002302 <wakeup>
}
    80005d60:	60a2                	ld	ra,8(sp)
    80005d62:	6402                	ld	s0,0(sp)
    80005d64:	0141                	addi	sp,sp,16
    80005d66:	8082                	ret
    panic("free_desc 1");
    80005d68:	00003517          	auipc	a0,0x3
    80005d6c:	a1850513          	addi	a0,a0,-1512 # 80008780 <syscalls+0x338>
    80005d70:	ffffa097          	auipc	ra,0xffffa
    80005d74:	7c8080e7          	jalr	1992(ra) # 80000538 <panic>
    panic("free_desc 2");
    80005d78:	00003517          	auipc	a0,0x3
    80005d7c:	a1850513          	addi	a0,a0,-1512 # 80008790 <syscalls+0x348>
    80005d80:	ffffa097          	auipc	ra,0xffffa
    80005d84:	7b8080e7          	jalr	1976(ra) # 80000538 <panic>

0000000080005d88 <virtio_disk_init>:
{
    80005d88:	1101                	addi	sp,sp,-32
    80005d8a:	ec06                	sd	ra,24(sp)
    80005d8c:	e822                	sd	s0,16(sp)
    80005d8e:	e426                	sd	s1,8(sp)
    80005d90:	e04a                	sd	s2,0(sp)
    80005d92:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d94:	00003597          	auipc	a1,0x3
    80005d98:	a0c58593          	addi	a1,a1,-1524 # 800087a0 <syscalls+0x358>
    80005d9c:	0001c517          	auipc	a0,0x1c
    80005da0:	30c50513          	addi	a0,a0,780 # 800220a8 <disk+0x128>
    80005da4:	ffffb097          	auipc	ra,0xffffb
    80005da8:	d9c080e7          	jalr	-612(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dac:	100017b7          	lui	a5,0x10001
    80005db0:	4398                	lw	a4,0(a5)
    80005db2:	2701                	sext.w	a4,a4
    80005db4:	747277b7          	lui	a5,0x74727
    80005db8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005dbc:	14f71c63          	bne	a4,a5,80005f14 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005dc0:	100017b7          	lui	a5,0x10001
    80005dc4:	43dc                	lw	a5,4(a5)
    80005dc6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dc8:	4709                	li	a4,2
    80005dca:	14e79563          	bne	a5,a4,80005f14 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005dce:	100017b7          	lui	a5,0x10001
    80005dd2:	479c                	lw	a5,8(a5)
    80005dd4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005dd6:	12e79f63          	bne	a5,a4,80005f14 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005dda:	100017b7          	lui	a5,0x10001
    80005dde:	47d8                	lw	a4,12(a5)
    80005de0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005de2:	554d47b7          	lui	a5,0x554d4
    80005de6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005dea:	12f71563          	bne	a4,a5,80005f14 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dee:	100017b7          	lui	a5,0x10001
    80005df2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005df6:	4705                	li	a4,1
    80005df8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dfa:	470d                	li	a4,3
    80005dfc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005dfe:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e00:	c7ffe737          	lui	a4,0xc7ffe
    80005e04:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc69f>
    80005e08:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e0a:	2701                	sext.w	a4,a4
    80005e0c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e0e:	472d                	li	a4,11
    80005e10:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e12:	5bbc                	lw	a5,112(a5)
    80005e14:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e18:	8ba1                	andi	a5,a5,8
    80005e1a:	10078563          	beqz	a5,80005f24 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e1e:	100017b7          	lui	a5,0x10001
    80005e22:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e26:	43fc                	lw	a5,68(a5)
    80005e28:	2781                	sext.w	a5,a5
    80005e2a:	10079563          	bnez	a5,80005f34 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e2e:	100017b7          	lui	a5,0x10001
    80005e32:	5bdc                	lw	a5,52(a5)
    80005e34:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e36:	10078763          	beqz	a5,80005f44 <virtio_disk_init+0x1bc>
  if(max < NUM)
    80005e3a:	471d                	li	a4,7
    80005e3c:	10f77c63          	bgeu	a4,a5,80005f54 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80005e40:	ffffb097          	auipc	ra,0xffffb
    80005e44:	ca0080e7          	jalr	-864(ra) # 80000ae0 <kalloc>
    80005e48:	0001c497          	auipc	s1,0x1c
    80005e4c:	13848493          	addi	s1,s1,312 # 80021f80 <disk>
    80005e50:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e52:	ffffb097          	auipc	ra,0xffffb
    80005e56:	c8e080e7          	jalr	-882(ra) # 80000ae0 <kalloc>
    80005e5a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e5c:	ffffb097          	auipc	ra,0xffffb
    80005e60:	c84080e7          	jalr	-892(ra) # 80000ae0 <kalloc>
    80005e64:	87aa                	mv	a5,a0
    80005e66:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005e68:	6088                	ld	a0,0(s1)
    80005e6a:	cd6d                	beqz	a0,80005f64 <virtio_disk_init+0x1dc>
    80005e6c:	0001c717          	auipc	a4,0x1c
    80005e70:	11c73703          	ld	a4,284(a4) # 80021f88 <disk+0x8>
    80005e74:	cb65                	beqz	a4,80005f64 <virtio_disk_init+0x1dc>
    80005e76:	c7fd                	beqz	a5,80005f64 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80005e78:	6605                	lui	a2,0x1
    80005e7a:	4581                	li	a1,0
    80005e7c:	ffffb097          	auipc	ra,0xffffb
    80005e80:	e50080e7          	jalr	-432(ra) # 80000ccc <memset>
  memset(disk.avail, 0, PGSIZE);
    80005e84:	0001c497          	auipc	s1,0x1c
    80005e88:	0fc48493          	addi	s1,s1,252 # 80021f80 <disk>
    80005e8c:	6605                	lui	a2,0x1
    80005e8e:	4581                	li	a1,0
    80005e90:	6488                	ld	a0,8(s1)
    80005e92:	ffffb097          	auipc	ra,0xffffb
    80005e96:	e3a080e7          	jalr	-454(ra) # 80000ccc <memset>
  memset(disk.used, 0, PGSIZE);
    80005e9a:	6605                	lui	a2,0x1
    80005e9c:	4581                	li	a1,0
    80005e9e:	6888                	ld	a0,16(s1)
    80005ea0:	ffffb097          	auipc	ra,0xffffb
    80005ea4:	e2c080e7          	jalr	-468(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ea8:	100017b7          	lui	a5,0x10001
    80005eac:	4721                	li	a4,8
    80005eae:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005eb0:	4098                	lw	a4,0(s1)
    80005eb2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005eb6:	40d8                	lw	a4,4(s1)
    80005eb8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005ebc:	6498                	ld	a4,8(s1)
    80005ebe:	0007069b          	sext.w	a3,a4
    80005ec2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005ec6:	9701                	srai	a4,a4,0x20
    80005ec8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005ecc:	6898                	ld	a4,16(s1)
    80005ece:	0007069b          	sext.w	a3,a4
    80005ed2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005ed6:	9701                	srai	a4,a4,0x20
    80005ed8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005edc:	4705                	li	a4,1
    80005ede:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005ee0:	00e48c23          	sb	a4,24(s1)
    80005ee4:	00e48ca3          	sb	a4,25(s1)
    80005ee8:	00e48d23          	sb	a4,26(s1)
    80005eec:	00e48da3          	sb	a4,27(s1)
    80005ef0:	00e48e23          	sb	a4,28(s1)
    80005ef4:	00e48ea3          	sb	a4,29(s1)
    80005ef8:	00e48f23          	sb	a4,30(s1)
    80005efc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f00:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f04:	0727a823          	sw	s2,112(a5)
}
    80005f08:	60e2                	ld	ra,24(sp)
    80005f0a:	6442                	ld	s0,16(sp)
    80005f0c:	64a2                	ld	s1,8(sp)
    80005f0e:	6902                	ld	s2,0(sp)
    80005f10:	6105                	addi	sp,sp,32
    80005f12:	8082                	ret
    panic("could not find virtio disk");
    80005f14:	00003517          	auipc	a0,0x3
    80005f18:	89c50513          	addi	a0,a0,-1892 # 800087b0 <syscalls+0x368>
    80005f1c:	ffffa097          	auipc	ra,0xffffa
    80005f20:	61c080e7          	jalr	1564(ra) # 80000538 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f24:	00003517          	auipc	a0,0x3
    80005f28:	8ac50513          	addi	a0,a0,-1876 # 800087d0 <syscalls+0x388>
    80005f2c:	ffffa097          	auipc	ra,0xffffa
    80005f30:	60c080e7          	jalr	1548(ra) # 80000538 <panic>
    panic("virtio disk should not be ready");
    80005f34:	00003517          	auipc	a0,0x3
    80005f38:	8bc50513          	addi	a0,a0,-1860 # 800087f0 <syscalls+0x3a8>
    80005f3c:	ffffa097          	auipc	ra,0xffffa
    80005f40:	5fc080e7          	jalr	1532(ra) # 80000538 <panic>
    panic("virtio disk has no queue 0");
    80005f44:	00003517          	auipc	a0,0x3
    80005f48:	8cc50513          	addi	a0,a0,-1844 # 80008810 <syscalls+0x3c8>
    80005f4c:	ffffa097          	auipc	ra,0xffffa
    80005f50:	5ec080e7          	jalr	1516(ra) # 80000538 <panic>
    panic("virtio disk max queue too short");
    80005f54:	00003517          	auipc	a0,0x3
    80005f58:	8dc50513          	addi	a0,a0,-1828 # 80008830 <syscalls+0x3e8>
    80005f5c:	ffffa097          	auipc	ra,0xffffa
    80005f60:	5dc080e7          	jalr	1500(ra) # 80000538 <panic>
    panic("virtio disk kalloc");
    80005f64:	00003517          	auipc	a0,0x3
    80005f68:	8ec50513          	addi	a0,a0,-1812 # 80008850 <syscalls+0x408>
    80005f6c:	ffffa097          	auipc	ra,0xffffa
    80005f70:	5cc080e7          	jalr	1484(ra) # 80000538 <panic>

0000000080005f74 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f74:	7119                	addi	sp,sp,-128
    80005f76:	fc86                	sd	ra,120(sp)
    80005f78:	f8a2                	sd	s0,112(sp)
    80005f7a:	f4a6                	sd	s1,104(sp)
    80005f7c:	f0ca                	sd	s2,96(sp)
    80005f7e:	ecce                	sd	s3,88(sp)
    80005f80:	e8d2                	sd	s4,80(sp)
    80005f82:	e4d6                	sd	s5,72(sp)
    80005f84:	e0da                	sd	s6,64(sp)
    80005f86:	fc5e                	sd	s7,56(sp)
    80005f88:	f862                	sd	s8,48(sp)
    80005f8a:	f466                	sd	s9,40(sp)
    80005f8c:	f06a                	sd	s10,32(sp)
    80005f8e:	ec6e                	sd	s11,24(sp)
    80005f90:	0100                	addi	s0,sp,128
    80005f92:	8aaa                	mv	s5,a0
    80005f94:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f96:	00c52d03          	lw	s10,12(a0)
    80005f9a:	001d1d1b          	slliw	s10,s10,0x1
    80005f9e:	1d02                	slli	s10,s10,0x20
    80005fa0:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005fa4:	0001c517          	auipc	a0,0x1c
    80005fa8:	10450513          	addi	a0,a0,260 # 800220a8 <disk+0x128>
    80005fac:	ffffb097          	auipc	ra,0xffffb
    80005fb0:	c24080e7          	jalr	-988(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80005fb4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fb6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005fb8:	0001cb97          	auipc	s7,0x1c
    80005fbc:	fc8b8b93          	addi	s7,s7,-56 # 80021f80 <disk>
  for(int i = 0; i < 3; i++){
    80005fc0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fc2:	0001cc97          	auipc	s9,0x1c
    80005fc6:	0e6c8c93          	addi	s9,s9,230 # 800220a8 <disk+0x128>
    80005fca:	a08d                	j	8000602c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005fcc:	00fb8733          	add	a4,s7,a5
    80005fd0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005fd4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005fd6:	0207c563          	bltz	a5,80006000 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005fda:	2905                	addiw	s2,s2,1
    80005fdc:	0611                	addi	a2,a2,4
    80005fde:	05690c63          	beq	s2,s6,80006036 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005fe2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005fe4:	0001c717          	auipc	a4,0x1c
    80005fe8:	f9c70713          	addi	a4,a4,-100 # 80021f80 <disk>
    80005fec:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005fee:	01874683          	lbu	a3,24(a4)
    80005ff2:	fee9                	bnez	a3,80005fcc <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005ff4:	2785                	addiw	a5,a5,1
    80005ff6:	0705                	addi	a4,a4,1
    80005ff8:	fe979be3          	bne	a5,s1,80005fee <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80005ffc:	57fd                	li	a5,-1
    80005ffe:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006000:	01205d63          	blez	s2,8000601a <virtio_disk_rw+0xa6>
    80006004:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006006:	000a2503          	lw	a0,0(s4)
    8000600a:	00000097          	auipc	ra,0x0
    8000600e:	cfc080e7          	jalr	-772(ra) # 80005d06 <free_desc>
      for(int j = 0; j < i; j++)
    80006012:	2d85                	addiw	s11,s11,1
    80006014:	0a11                	addi	s4,s4,4
    80006016:	ffb918e3          	bne	s2,s11,80006006 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000601a:	85e6                	mv	a1,s9
    8000601c:	0001c517          	auipc	a0,0x1c
    80006020:	f7c50513          	addi	a0,a0,-132 # 80021f98 <disk+0x18>
    80006024:	ffffc097          	auipc	ra,0xffffc
    80006028:	152080e7          	jalr	338(ra) # 80002176 <sleep>
  for(int i = 0; i < 3; i++){
    8000602c:	f8040a13          	addi	s4,s0,-128
{
    80006030:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006032:	894e                	mv	s2,s3
    80006034:	b77d                	j	80005fe2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006036:	f8042583          	lw	a1,-128(s0)
    8000603a:	00a58793          	addi	a5,a1,10
    8000603e:	0792                	slli	a5,a5,0x4

  if(write)
    80006040:	0001c617          	auipc	a2,0x1c
    80006044:	f4060613          	addi	a2,a2,-192 # 80021f80 <disk>
    80006048:	00f60733          	add	a4,a2,a5
    8000604c:	018036b3          	snez	a3,s8
    80006050:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006052:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006056:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000605a:	f6078693          	addi	a3,a5,-160
    8000605e:	6218                	ld	a4,0(a2)
    80006060:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006062:	00878513          	addi	a0,a5,8
    80006066:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006068:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000606a:	6208                	ld	a0,0(a2)
    8000606c:	96aa                	add	a3,a3,a0
    8000606e:	4741                	li	a4,16
    80006070:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006072:	4705                	li	a4,1
    80006074:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006078:	f8442703          	lw	a4,-124(s0)
    8000607c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006080:	0712                	slli	a4,a4,0x4
    80006082:	953a                	add	a0,a0,a4
    80006084:	058a8693          	addi	a3,s5,88
    80006088:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000608a:	6208                	ld	a0,0(a2)
    8000608c:	972a                	add	a4,a4,a0
    8000608e:	40000693          	li	a3,1024
    80006092:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006094:	001c3c13          	seqz	s8,s8
    80006098:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000609a:	001c6c13          	ori	s8,s8,1
    8000609e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800060a2:	f8842603          	lw	a2,-120(s0)
    800060a6:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800060aa:	0001c697          	auipc	a3,0x1c
    800060ae:	ed668693          	addi	a3,a3,-298 # 80021f80 <disk>
    800060b2:	00258713          	addi	a4,a1,2
    800060b6:	0712                	slli	a4,a4,0x4
    800060b8:	9736                	add	a4,a4,a3
    800060ba:	587d                	li	a6,-1
    800060bc:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800060c0:	0612                	slli	a2,a2,0x4
    800060c2:	9532                	add	a0,a0,a2
    800060c4:	f9078793          	addi	a5,a5,-112
    800060c8:	97b6                	add	a5,a5,a3
    800060ca:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800060cc:	629c                	ld	a5,0(a3)
    800060ce:	97b2                	add	a5,a5,a2
    800060d0:	4605                	li	a2,1
    800060d2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060d4:	4509                	li	a0,2
    800060d6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800060da:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060de:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800060e2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800060e6:	6698                	ld	a4,8(a3)
    800060e8:	00275783          	lhu	a5,2(a4)
    800060ec:	8b9d                	andi	a5,a5,7
    800060ee:	0786                	slli	a5,a5,0x1
    800060f0:	97ba                	add	a5,a5,a4
    800060f2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800060f6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800060fa:	6698                	ld	a4,8(a3)
    800060fc:	00275783          	lhu	a5,2(a4)
    80006100:	2785                	addiw	a5,a5,1
    80006102:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006106:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000610a:	100017b7          	lui	a5,0x10001
    8000610e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006112:	004aa783          	lw	a5,4(s5)
    80006116:	02c79163          	bne	a5,a2,80006138 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000611a:	0001c917          	auipc	s2,0x1c
    8000611e:	f8e90913          	addi	s2,s2,-114 # 800220a8 <disk+0x128>
  while(b->disk == 1) {
    80006122:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006124:	85ca                	mv	a1,s2
    80006126:	8556                	mv	a0,s5
    80006128:	ffffc097          	auipc	ra,0xffffc
    8000612c:	04e080e7          	jalr	78(ra) # 80002176 <sleep>
  while(b->disk == 1) {
    80006130:	004aa783          	lw	a5,4(s5)
    80006134:	fe9788e3          	beq	a5,s1,80006124 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006138:	f8042903          	lw	s2,-128(s0)
    8000613c:	00290793          	addi	a5,s2,2
    80006140:	00479713          	slli	a4,a5,0x4
    80006144:	0001c797          	auipc	a5,0x1c
    80006148:	e3c78793          	addi	a5,a5,-452 # 80021f80 <disk>
    8000614c:	97ba                	add	a5,a5,a4
    8000614e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006152:	0001c997          	auipc	s3,0x1c
    80006156:	e2e98993          	addi	s3,s3,-466 # 80021f80 <disk>
    8000615a:	00491713          	slli	a4,s2,0x4
    8000615e:	0009b783          	ld	a5,0(s3)
    80006162:	97ba                	add	a5,a5,a4
    80006164:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006168:	854a                	mv	a0,s2
    8000616a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000616e:	00000097          	auipc	ra,0x0
    80006172:	b98080e7          	jalr	-1128(ra) # 80005d06 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006176:	8885                	andi	s1,s1,1
    80006178:	f0ed                	bnez	s1,8000615a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000617a:	0001c517          	auipc	a0,0x1c
    8000617e:	f2e50513          	addi	a0,a0,-210 # 800220a8 <disk+0x128>
    80006182:	ffffb097          	auipc	ra,0xffffb
    80006186:	b02080e7          	jalr	-1278(ra) # 80000c84 <release>
}
    8000618a:	70e6                	ld	ra,120(sp)
    8000618c:	7446                	ld	s0,112(sp)
    8000618e:	74a6                	ld	s1,104(sp)
    80006190:	7906                	ld	s2,96(sp)
    80006192:	69e6                	ld	s3,88(sp)
    80006194:	6a46                	ld	s4,80(sp)
    80006196:	6aa6                	ld	s5,72(sp)
    80006198:	6b06                	ld	s6,64(sp)
    8000619a:	7be2                	ld	s7,56(sp)
    8000619c:	7c42                	ld	s8,48(sp)
    8000619e:	7ca2                	ld	s9,40(sp)
    800061a0:	7d02                	ld	s10,32(sp)
    800061a2:	6de2                	ld	s11,24(sp)
    800061a4:	6109                	addi	sp,sp,128
    800061a6:	8082                	ret

00000000800061a8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061a8:	1101                	addi	sp,sp,-32
    800061aa:	ec06                	sd	ra,24(sp)
    800061ac:	e822                	sd	s0,16(sp)
    800061ae:	e426                	sd	s1,8(sp)
    800061b0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061b2:	0001c497          	auipc	s1,0x1c
    800061b6:	dce48493          	addi	s1,s1,-562 # 80021f80 <disk>
    800061ba:	0001c517          	auipc	a0,0x1c
    800061be:	eee50513          	addi	a0,a0,-274 # 800220a8 <disk+0x128>
    800061c2:	ffffb097          	auipc	ra,0xffffb
    800061c6:	a0e080e7          	jalr	-1522(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800061ca:	10001737          	lui	a4,0x10001
    800061ce:	533c                	lw	a5,96(a4)
    800061d0:	8b8d                	andi	a5,a5,3
    800061d2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800061d4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061d8:	689c                	ld	a5,16(s1)
    800061da:	0204d703          	lhu	a4,32(s1)
    800061de:	0027d783          	lhu	a5,2(a5)
    800061e2:	04f70863          	beq	a4,a5,80006232 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800061e6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061ea:	6898                	ld	a4,16(s1)
    800061ec:	0204d783          	lhu	a5,32(s1)
    800061f0:	8b9d                	andi	a5,a5,7
    800061f2:	078e                	slli	a5,a5,0x3
    800061f4:	97ba                	add	a5,a5,a4
    800061f6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800061f8:	00278713          	addi	a4,a5,2
    800061fc:	0712                	slli	a4,a4,0x4
    800061fe:	9726                	add	a4,a4,s1
    80006200:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006204:	e721                	bnez	a4,8000624c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006206:	0789                	addi	a5,a5,2
    80006208:	0792                	slli	a5,a5,0x4
    8000620a:	97a6                	add	a5,a5,s1
    8000620c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000620e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006212:	ffffc097          	auipc	ra,0xffffc
    80006216:	0f0080e7          	jalr	240(ra) # 80002302 <wakeup>

    disk.used_idx += 1;
    8000621a:	0204d783          	lhu	a5,32(s1)
    8000621e:	2785                	addiw	a5,a5,1
    80006220:	17c2                	slli	a5,a5,0x30
    80006222:	93c1                	srli	a5,a5,0x30
    80006224:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006228:	6898                	ld	a4,16(s1)
    8000622a:	00275703          	lhu	a4,2(a4)
    8000622e:	faf71ce3          	bne	a4,a5,800061e6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006232:	0001c517          	auipc	a0,0x1c
    80006236:	e7650513          	addi	a0,a0,-394 # 800220a8 <disk+0x128>
    8000623a:	ffffb097          	auipc	ra,0xffffb
    8000623e:	a4a080e7          	jalr	-1462(ra) # 80000c84 <release>
}
    80006242:	60e2                	ld	ra,24(sp)
    80006244:	6442                	ld	s0,16(sp)
    80006246:	64a2                	ld	s1,8(sp)
    80006248:	6105                	addi	sp,sp,32
    8000624a:	8082                	ret
      panic("virtio_disk_intr status");
    8000624c:	00002517          	auipc	a0,0x2
    80006250:	61c50513          	addi	a0,a0,1564 # 80008868 <syscalls+0x420>
    80006254:	ffffa097          	auipc	ra,0xffffa
    80006258:	2e4080e7          	jalr	740(ra) # 80000538 <panic>
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
    8000708e:	18031073          	csrw	satp,t1
    80007092:	12000073          	sfence.vma
    80007096:	8282                	jr	t0

0000000080007098 <userret>:
    80007098:	18051073          	csrw	satp,a0
    8000709c:	12000073          	sfence.vma
    800070a0:	02000537          	lui	a0,0x2000
    800070a4:	357d                	addiw	a0,a0,-1
    800070a6:	0536                	slli	a0,a0,0xd
    800070a8:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070ac:	03053103          	ld	sp,48(a0)
    800070b0:	03853183          	ld	gp,56(a0)
    800070b4:	04053203          	ld	tp,64(a0)
    800070b8:	04853283          	ld	t0,72(a0)
    800070bc:	05053303          	ld	t1,80(a0)
    800070c0:	05853383          	ld	t2,88(a0)
    800070c4:	7120                	ld	s0,96(a0)
    800070c6:	7524                	ld	s1,104(a0)
    800070c8:	7d2c                	ld	a1,120(a0)
    800070ca:	6150                	ld	a2,128(a0)
    800070cc:	6554                	ld	a3,136(a0)
    800070ce:	6958                	ld	a4,144(a0)
    800070d0:	6d5c                	ld	a5,152(a0)
    800070d2:	0a053803          	ld	a6,160(a0)
    800070d6:	0a853883          	ld	a7,168(a0)
    800070da:	0b053903          	ld	s2,176(a0)
    800070de:	0b853983          	ld	s3,184(a0)
    800070e2:	0c053a03          	ld	s4,192(a0)
    800070e6:	0c853a83          	ld	s5,200(a0)
    800070ea:	0d053b03          	ld	s6,208(a0)
    800070ee:	0d853b83          	ld	s7,216(a0)
    800070f2:	0e053c03          	ld	s8,224(a0)
    800070f6:	0e853c83          	ld	s9,232(a0)
    800070fa:	0f053d03          	ld	s10,240(a0)
    800070fe:	0f853d83          	ld	s11,248(a0)
    80007102:	10053e03          	ld	t3,256(a0)
    80007106:	10853e83          	ld	t4,264(a0)
    8000710a:	11053f03          	ld	t5,272(a0)
    8000710e:	11853f83          	ld	t6,280(a0)
    80007112:	7928                	ld	a0,112(a0)
    80007114:	10200073          	sret
	...
