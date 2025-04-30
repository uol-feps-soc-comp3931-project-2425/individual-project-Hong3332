
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a6010113          	addi	sp,sp,-1440 # 80008a60 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff133c7>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	197020ef          	jal	80002a90 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00011517          	auipc	a0,0x11
    80000158:	90c50513          	addi	a0,a0,-1780 # 80010a60 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00011497          	auipc	s1,0x11
    80000164:	90048493          	addi	s1,s1,-1792 # 80010a60 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00011917          	auipc	s2,0x11
    8000016c:	99090913          	addi	s2,s2,-1648 # 80010af8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	7c6010ef          	jal	80001946 <myproc>
    80000184:	7a4020ef          	jal	80002928 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	516020ef          	jal	800026a4 <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00011717          	auipc	a4,0x11
    800001a4:	8c070713          	addi	a4,a4,-1856 # 80010a60 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	075020ef          	jal	80002a46 <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	00011517          	auipc	a0,0x11
    800001ee:	87650513          	addi	a0,a0,-1930 # 80010a60 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00011717          	auipc	a4,0x11
    80000218:	8ef72223          	sw	a5,-1820(a4) # 80010af8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	83650513          	addi	a0,a0,-1994 # 80010a60 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	00010517          	auipc	a0,0x10
    80000282:	7e250513          	addi	a0,a0,2018 # 80010a60 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	03b020ef          	jal	80002ada <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	00010517          	auipc	a0,0x10
    800002a8:	7bc50513          	addi	a0,a0,1980 # 80010a60 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	00010717          	auipc	a4,0x10
    800002c6:	79e70713          	addi	a4,a4,1950 # 80010a60 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	00010797          	auipc	a5,0x10
    800002ec:	77878793          	addi	a5,a5,1912 # 80010a60 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	00010797          	auipc	a5,0x10
    8000031a:	7e27a783          	lw	a5,2018(a5) # 80010af8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	00010717          	auipc	a4,0x10
    80000330:	73470713          	addi	a4,a4,1844 # 80010a60 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	00010497          	auipc	s1,0x10
    80000340:	72448493          	addi	s1,s1,1828 # 80010a60 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	00010717          	auipc	a4,0x10
    80000382:	6e270713          	addi	a4,a4,1762 # 80010a60 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	76f72623          	sw	a5,1900(a4) # 80010b00 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	00010797          	auipc	a5,0x10
    800003b6:	6ae78793          	addi	a5,a5,1710 # 80010a60 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00010797          	auipc	a5,0x10
    800003da:	72c7a323          	sw	a2,1830(a5) # 80010afc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00010517          	auipc	a0,0x10
    800003e2:	71a50513          	addi	a0,a0,1818 # 80010af8 <cons+0x98>
    800003e6:	30a020ef          	jal	800026f0 <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00008597          	auipc	a1,0x8
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80008000 <etext>
    800003fc:	00010517          	auipc	a0,0x10
    80000400:	66450513          	addi	a0,a0,1636 # 80010a60 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	000ea797          	auipc	a5,0xea
    80000410:	e9478793          	addi	a5,a5,-364 # 800ea2a0 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00008617          	auipc	a2,0x8
    8000044a:	43260613          	addi	a2,a2,1074 # 80008878 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	00010797          	auipc	a5,0x10
    800004e4:	6407a783          	lw	a5,1600(a5) # 80010b20 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	00010517          	auipc	a0,0x10
    80000530:	5dc50513          	addi	a0,a0,1500 # 80010b08 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00008b97          	auipc	s7,0x8
    800006f0:	18cb8b93          	addi	s7,s7,396 # 80008878 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00008917          	auipc	s2,0x8
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80008008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	00010517          	auipc	a0,0x10
    8000078a:	38250513          	addi	a0,a0,898 # 80010b08 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	00010797          	auipc	a5,0x10
    800007a4:	3807a023          	sw	zero,896(a5) # 80010b20 <pr+0x18>
  printf("panic: ");
    800007a8:	00008517          	auipc	a0,0x8
    800007ac:	87050513          	addi	a0,a0,-1936 # 80008018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00008517          	auipc	a0,0x8
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80008020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	00008717          	auipc	a4,0x8
    800007c8:	24f72e23          	sw	a5,604(a4) # 80008a20 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	00010497          	auipc	s1,0x10
    800007dc:	33048493          	addi	s1,s1,816 # 80010b08 <pr>
    800007e0:	00008597          	auipc	a1,0x8
    800007e4:	84858593          	addi	a1,a1,-1976 # 80008028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00007597          	auipc	a1,0x7
    8000083c:	7f858593          	addi	a1,a1,2040 # 80008030 <etext+0x30>
    80000840:	00010517          	auipc	a0,0x10
    80000844:	2e850513          	addi	a0,a0,744 # 80010b28 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	00008797          	auipc	a5,0x8
    80000868:	1bc7a783          	lw	a5,444(a5) # 80008a20 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	00008797          	auipc	a5,0x8
    8000089e:	18e7b783          	ld	a5,398(a5) # 80008a28 <uart_tx_r>
    800008a2:	00008717          	auipc	a4,0x8
    800008a6:	18e73703          	ld	a4,398(a4) # 80008a30 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	00010a97          	auipc	s5,0x10
    800008cc:	260a8a93          	addi	s5,s5,608 # 80010b28 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00008497          	auipc	s1,0x8
    800008d4:	15848493          	addi	s1,s1,344 # 80008a28 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00008997          	auipc	s3,0x8
    800008e0:	15498993          	addi	s3,s3,340 # 80008a30 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	5f3010ef          	jal	800026f0 <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	00010517          	auipc	a0,0x10
    80000950:	1dc50513          	addi	a0,a0,476 # 80010b28 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00008797          	auipc	a5,0x8
    8000095c:	0c87a783          	lw	a5,200(a5) # 80008a20 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00008717          	auipc	a4,0x8
    80000966:	0ce73703          	ld	a4,206(a4) # 80008a30 <uart_tx_w>
    8000096a:	00008797          	auipc	a5,0x8
    8000096e:	0be7b783          	ld	a5,190(a5) # 80008a28 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	00010997          	auipc	s3,0x10
    8000097a:	1b298993          	addi	s3,s3,434 # 80010b28 <uart_tx_lock>
    8000097e:	00008497          	auipc	s1,0x8
    80000982:	0aa48493          	addi	s1,s1,170 # 80008a28 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00008917          	auipc	s2,0x8
    8000098a:	0aa90913          	addi	s2,s2,170 # 80008a30 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	50f010ef          	jal	800026a4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	00010497          	auipc	s1,0x10
    800009ac:	18048493          	addi	s1,s1,384 # 80010b28 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00008797          	auipc	a5,0x8
    800009c0:	06e7ba23          	sd	a4,116(a5) # 80008a30 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	00010497          	auipc	s1,0x10
    80000a24:	10848493          	addi	s1,s1,264 # 80010b28 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	000eb797          	auipc	a5,0xeb
    80000a5a:	9e278793          	addi	a5,a5,-1566 # 800eb438 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	00010917          	auipc	s2,0x10
    80000a76:	0ee90913          	addi	s2,s2,238 # 80010b60 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00007517          	auipc	a0,0x7
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80008038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00007597          	auipc	a1,0x7
    80000afc:	54858593          	addi	a1,a1,1352 # 80008040 <etext+0x40>
    80000b00:	00010517          	auipc	a0,0x10
    80000b04:	06050513          	addi	a0,a0,96 # 80010b60 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	000eb517          	auipc	a0,0xeb
    80000b14:	92850513          	addi	a0,a0,-1752 # 800eb438 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	00010497          	auipc	s1,0x10
    80000b32:	03248493          	addi	s1,s1,50 # 80010b60 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00010517          	auipc	a0,0x10
    80000b46:	01e50513          	addi	a0,a0,30 # 80010b60 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	00010517          	auipc	a0,0x10
    80000b6a:	ffa50513          	addi	a0,a0,-6 # 80010b60 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	58d000ef          	jal	8000192a <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	55f000ef          	jal	8000192a <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	557000ef          	jal	8000192a <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	543000ef          	jal	8000192a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1c:	50f000ef          	jal	8000192a <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00007517          	auipc	a0,0x7
    80000c30:	41c50513          	addi	a0,a0,1052 # 80008048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	4eb000ef          	jal	8000192a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00007517          	auipc	a0,0x7
    80000c78:	3dc50513          	addi	a0,a0,988 # 80008050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00007517          	auipc	a0,0x7
    80000c84:	3e850513          	addi	a0,a0,1000 # 80008068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca6:	0f50000f          	fence	iorw,ow
    80000caa:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00007517          	auipc	a0,0x7
    80000cc0:	3b450513          	addi	a0,a0,948 # 80008070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ff13bc9>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	2b1000ef          	jal	8000191a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00008717          	auipc	a4,0x8
    80000e72:	bca70713          	addi	a4,a4,-1078 # 80008a38 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e82:	299000ef          	jal	8000191a <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00007517          	auipc	a0,0x7
    80000e8c:	21050513          	addi	a0,a0,528 # 80008098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	5cd010ef          	jal	80002c64 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	74d040ef          	jal	80005de8 <plicinithart>
  }

  scheduler();        
    80000ea0:	296010ef          	jal	80002136 <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00007517          	auipc	a0,0x7
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80008078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00007517          	auipc	a0,0x7
    80000ebc:	1c850513          	addi	a0,a0,456 # 80008080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00007517          	auipc	a0,0x7
    80000ec8:	1b450513          	addi	a0,a0,436 # 80008078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	185000ef          	jal	80001860 <procinit>
    trapinit();      // trap vectors
    80000ee0:	561010ef          	jal	80002c40 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	581010ef          	jal	80002c64 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	6e7040ef          	jal	80005dce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	6fd040ef          	jal	80005de8 <plicinithart>
    binit();         // buffer cache
    80000ef0:	6a2020ef          	jal	80003592 <binit>
    iinit();         // inode table
    80000ef4:	495020ef          	jal	80003b88 <iinit>
    fileinit();      // file table
    80000ef8:	241030ef          	jal	80004938 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	7dd040ef          	jal	80005ed8 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	5e3000ef          	jal	80001ce2 <userinit>
    __sync_synchronize();
    80000f04:	0ff0000f          	fence
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00008717          	auipc	a4,0x8
    80000f0e:	b2f72723          	sw	a5,-1234(a4) # 80008a38 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00008797          	auipc	a5,0x8
    80000f22:	b227b783          	ld	a5,-1246(a5) # 80008a40 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00007517          	auipc	a0,0x7
    80000f66:	14e50513          	addi	a0,a0,334 # 800080b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ff13bbf>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00007517          	auipc	a0,0x7
    8000107c:	04050513          	addi	a0,a0,64 # 800080b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00007517          	auipc	a0,0x7
    80001088:	05450513          	addi	a0,a0,84 # 800080d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00007517          	auipc	a0,0x7
    80001094:	06850513          	addi	a0,a0,104 # 800080f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00007517          	auipc	a0,0x7
    800010a0:	06c50513          	addi	a0,a0,108 # 80008108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00007517          	auipc	a0,0x7
    800010e4:	03850513          	addi	a0,a0,56 # 80008118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00007917          	auipc	s2,0x7
    80001142:	ec290913          	addi	s2,s2,-318 # 80008000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80007697          	auipc	a3,0x80007
    8000114c:	eb868693          	addi	a3,a3,-328 # 8000 <_entry-0x7fff8000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00006617          	auipc	a2,0x6
    80001178:	e8c60613          	addi	a2,a2,-372 # 80007000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00008797          	auipc	a5,0x8
    800011ae:	88a7bb23          	sd	a0,-1898(a5) # 80008a40 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00007517          	auipc	a0,0x7
    800011fe:	f2650513          	addi	a0,a0,-218 # 80008120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00007517          	auipc	a0,0x7
    8000120a:	f3250513          	addi	a0,a0,-206 # 80008138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00007517          	auipc	a0,0x7
    80001216:	f3650513          	addi	a0,a0,-202 # 80008148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00007517          	auipc	a0,0x7
    80001222:	f4250513          	addi	a0,a0,-190 # 80008160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00007517          	auipc	a0,0x7
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80008178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00007517          	auipc	a0,0x7
    80001426:	d7650513          	addi	a0,a0,-650 # 80008198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00007517          	auipc	a0,0x7
    800014e4:	cc850513          	addi	a0,a0,-824 # 800081a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00007517          	auipc	a0,0x7
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800081c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00007517          	auipc	a0,0x7
    8000154a:	ca250513          	addi	a0,a0,-862 # 800081e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	00010497          	auipc	s1,0x10
    80001780:	83448493          	addi	s1,s1,-1996 # 80010fb0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	ff8f6937          	lui	s2,0xff8f6
    8000178a:	c2990913          	addi	s2,s2,-983 # ffffffffff8f5c29 <end+0xffffffff7f80a7f1>
    8000178e:	093e                	slli	s2,s2,0xf
    80001790:	ae190913          	addi	s2,s2,-1311
    80001794:	0932                	slli	s2,s2,0xc
    80001796:	47b90913          	addi	s2,s2,1147
    8000179a:	0936                	slli	s2,s2,0xd
    8000179c:	c2990913          	addi	s2,s2,-983
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	000d3a97          	auipc	s5,0xd3
    800017ac:	d08a8a93          	addi	s5,s5,-760 # 800d44b0 <mlfq>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	8591                	srai	a1,a1,0x4
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	19048493          	addi	s1,s1,400
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00007517          	auipc	a0,0x7
    800017f6:	a0650513          	addi	a0,a0,-1530 # 800081f8 <etext+0x1f8>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <mlfq_init>:

void
mlfq_init() {
    800017fe:	1141                	addi	sp,sp,-16
    80001800:	e406                	sd	ra,8(sp)
    80001802:	e022                	sd	s0,0(sp)
    80001804:	0800                	addi	s0,sp,16
  initlock(&mlfq.lock, "mlfq");
    80001806:	00007597          	auipc	a1,0x7
    8000180a:	9fa58593          	addi	a1,a1,-1542 # 80008200 <etext+0x200>
    8000180e:	000d3517          	auipc	a0,0xd3
    80001812:	ca250513          	addi	a0,a0,-862 # 800d44b0 <mlfq>
    80001816:	b5eff0ef          	jal	80000b74 <initlock>
  for (int i = 0; i < QUEUE_LEVELS; i++) {
    8000181a:	000df697          	auipc	a3,0xdf
    8000181e:	82e68693          	addi	a3,a3,-2002 # 800e0048 <mlfq+0xbb98>
    80001822:	000d7717          	auipc	a4,0xd7
    80001826:	b2670713          	addi	a4,a4,-1242 # 800d8348 <mlfq+0x3e98>
    8000182a:	000e2517          	auipc	a0,0xe2
    8000182e:	69e50513          	addi	a0,a0,1694 # 800e3ec8 <bcache+0x3e58>
    80001832:	75f1                	lui	a1,0xffffc
    80001834:	18058593          	addi	a1,a1,384 # ffffffffffffc180 <end+0xffffffff7ff10d48>
    80001838:	6611                	lui	a2,0x4
    8000183a:	e8060613          	addi	a2,a2,-384 # 3e80 <_entry-0x7fffc180>
    mlfq.qsize[i] = 0;
    8000183e:	0006a023          	sw	zero,0(a3)
    for (int j = 0; j < NPROC; j++) {
    80001842:	00b707b3          	add	a5,a4,a1
      mlfq.queue[i][j] = 0;
    80001846:	0007b023          	sd	zero,0(a5)
    for (int j = 0; j < NPROC; j++) {
    8000184a:	07a1                	addi	a5,a5,8
    8000184c:	fee79de3          	bne	a5,a4,80001846 <mlfq_init+0x48>
  for (int i = 0; i < QUEUE_LEVELS; i++) {
    80001850:	0691                	addi	a3,a3,4
    80001852:	9732                	add	a4,a4,a2
    80001854:	fea715e3          	bne	a4,a0,8000183e <mlfq_init+0x40>
    }
  }
}
    80001858:	60a2                	ld	ra,8(sp)
    8000185a:	6402                	ld	s0,0(sp)
    8000185c:	0141                	addi	sp,sp,16
    8000185e:	8082                	ret

0000000080001860 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001860:	7139                	addi	sp,sp,-64
    80001862:	fc06                	sd	ra,56(sp)
    80001864:	f822                	sd	s0,48(sp)
    80001866:	f426                	sd	s1,40(sp)
    80001868:	f04a                	sd	s2,32(sp)
    8000186a:	ec4e                	sd	s3,24(sp)
    8000186c:	e852                	sd	s4,16(sp)
    8000186e:	e456                	sd	s5,8(sp)
    80001870:	e05a                	sd	s6,0(sp)
    80001872:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001874:	00007597          	auipc	a1,0x7
    80001878:	99458593          	addi	a1,a1,-1644 # 80008208 <etext+0x208>
    8000187c:	0000f517          	auipc	a0,0xf
    80001880:	30450513          	addi	a0,a0,772 # 80010b80 <pid_lock>
    80001884:	af0ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001888:	00007597          	auipc	a1,0x7
    8000188c:	98858593          	addi	a1,a1,-1656 # 80008210 <etext+0x210>
    80001890:	0000f517          	auipc	a0,0xf
    80001894:	30850513          	addi	a0,a0,776 # 80010b98 <wait_lock>
    80001898:	adcff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189c:	0000f497          	auipc	s1,0xf
    800018a0:	71448493          	addi	s1,s1,1812 # 80010fb0 <proc>
      initlock(&p->lock, "proc");
    800018a4:	00007b17          	auipc	s6,0x7
    800018a8:	97cb0b13          	addi	s6,s6,-1668 # 80008220 <etext+0x220>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800018ac:	8aa6                	mv	s5,s1
    800018ae:	ff8f6937          	lui	s2,0xff8f6
    800018b2:	c2990913          	addi	s2,s2,-983 # ffffffffff8f5c29 <end+0xffffffff7f80a7f1>
    800018b6:	093e                	slli	s2,s2,0xf
    800018b8:	ae190913          	addi	s2,s2,-1311
    800018bc:	0932                	slli	s2,s2,0xc
    800018be:	47b90913          	addi	s2,s2,1147
    800018c2:	0936                	slli	s2,s2,0xd
    800018c4:	c2990913          	addi	s2,s2,-983
    800018c8:	040009b7          	lui	s3,0x4000
    800018cc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018ce:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018d0:	000d3a17          	auipc	s4,0xd3
    800018d4:	be0a0a13          	addi	s4,s4,-1056 # 800d44b0 <mlfq>
      initlock(&p->lock, "proc");
    800018d8:	85da                	mv	a1,s6
    800018da:	8526                	mv	a0,s1
    800018dc:	a98ff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    800018e0:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018e4:	415487b3          	sub	a5,s1,s5
    800018e8:	8791                	srai	a5,a5,0x4
    800018ea:	032787b3          	mul	a5,a5,s2
    800018ee:	2785                	addiw	a5,a5,1
    800018f0:	00d7979b          	slliw	a5,a5,0xd
    800018f4:	40f987b3          	sub	a5,s3,a5
    800018f8:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fa:	19048493          	addi	s1,s1,400
    800018fe:	fd449de3          	bne	s1,s4,800018d8 <procinit+0x78>
  }
  mlfq_init();
    80001902:	efdff0ef          	jal	800017fe <mlfq_init>
}
    80001906:	70e2                	ld	ra,56(sp)
    80001908:	7442                	ld	s0,48(sp)
    8000190a:	74a2                	ld	s1,40(sp)
    8000190c:	7902                	ld	s2,32(sp)
    8000190e:	69e2                	ld	s3,24(sp)
    80001910:	6a42                	ld	s4,16(sp)
    80001912:	6aa2                	ld	s5,8(sp)
    80001914:	6b02                	ld	s6,0(sp)
    80001916:	6121                	addi	sp,sp,64
    80001918:	8082                	ret

000000008000191a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000191a:	1141                	addi	sp,sp,-16
    8000191c:	e422                	sd	s0,8(sp)
    8000191e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001920:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001922:	2501                	sext.w	a0,a0
    80001924:	6422                	ld	s0,8(sp)
    80001926:	0141                	addi	sp,sp,16
    80001928:	8082                	ret

000000008000192a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000192a:	1141                	addi	sp,sp,-16
    8000192c:	e422                	sd	s0,8(sp)
    8000192e:	0800                	addi	s0,sp,16
    80001930:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001932:	2781                	sext.w	a5,a5
    80001934:	079e                	slli	a5,a5,0x7
  return c;
}
    80001936:	0000f517          	auipc	a0,0xf
    8000193a:	27a50513          	addi	a0,a0,634 # 80010bb0 <cpus>
    8000193e:	953e                	add	a0,a0,a5
    80001940:	6422                	ld	s0,8(sp)
    80001942:	0141                	addi	sp,sp,16
    80001944:	8082                	ret

0000000080001946 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001946:	1101                	addi	sp,sp,-32
    80001948:	ec06                	sd	ra,24(sp)
    8000194a:	e822                	sd	s0,16(sp)
    8000194c:	e426                	sd	s1,8(sp)
    8000194e:	1000                	addi	s0,sp,32
  push_off();
    80001950:	a64ff0ef          	jal	80000bb4 <push_off>
    80001954:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001956:	2781                	sext.w	a5,a5
    80001958:	079e                	slli	a5,a5,0x7
    8000195a:	0000f717          	auipc	a4,0xf
    8000195e:	22670713          	addi	a4,a4,550 # 80010b80 <pid_lock>
    80001962:	97ba                	add	a5,a5,a4
    80001964:	7b84                	ld	s1,48(a5)
  pop_off();
    80001966:	ad2ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    8000196a:	8526                	mv	a0,s1
    8000196c:	60e2                	ld	ra,24(sp)
    8000196e:	6442                	ld	s0,16(sp)
    80001970:	64a2                	ld	s1,8(sp)
    80001972:	6105                	addi	sp,sp,32
    80001974:	8082                	ret

0000000080001976 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001976:	1101                	addi	sp,sp,-32
    80001978:	ec06                	sd	ra,24(sp)
    8000197a:	e822                	sd	s0,16(sp)
    8000197c:	e426                	sd	s1,8(sp)
    8000197e:	1000                	addi	s0,sp,32
  static int first = 1;

  // Still holding p->lock from scheduler.
  struct proc *p = myproc();
    80001980:	fc7ff0ef          	jal	80001946 <myproc>
    80001984:	84aa                	mv	s1,a0
  release(&p->lock);
    80001986:	b06ff0ef          	jal	80000c8c <release>

  if (first) {
    8000198a:	00007797          	auipc	a5,0x7
    8000198e:	0467a783          	lw	a5,70(a5) # 800089d0 <first.1>
    80001992:	ef91                	bnez	a5,800019ae <forkret+0x38>
    first = 0;
    __sync_synchronize(); // Ensure all cores see fsinit complete
  }


  p->runtime_start_ticks = ticks;
    80001994:	00007797          	auipc	a5,0x7
    80001998:	0c47a783          	lw	a5,196(a5) # 80008a58 <ticks>
    8000199c:	16f4aa23          	sw	a5,372(s1)

  usertrapret();
    800019a0:	2dc010ef          	jal	80002c7c <usertrapret>
}
    800019a4:	60e2                	ld	ra,24(sp)
    800019a6:	6442                	ld	s0,16(sp)
    800019a8:	64a2                	ld	s1,8(sp)
    800019aa:	6105                	addi	sp,sp,32
    800019ac:	8082                	ret
    fsinit(ROOTDEV);
    800019ae:	4505                	li	a0,1
    800019b0:	16c020ef          	jal	80003b1c <fsinit>
    first = 0;
    800019b4:	00007797          	auipc	a5,0x7
    800019b8:	0007ae23          	sw	zero,28(a5) # 800089d0 <first.1>
    __sync_synchronize(); // Ensure all cores see fsinit complete
    800019bc:	0ff0000f          	fence
    800019c0:	bfd1                	j	80001994 <forkret+0x1e>

00000000800019c2 <allocpid>:
{
    800019c2:	1101                	addi	sp,sp,-32
    800019c4:	ec06                	sd	ra,24(sp)
    800019c6:	e822                	sd	s0,16(sp)
    800019c8:	e426                	sd	s1,8(sp)
    800019ca:	e04a                	sd	s2,0(sp)
    800019cc:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019ce:	0000f917          	auipc	s2,0xf
    800019d2:	1b290913          	addi	s2,s2,434 # 80010b80 <pid_lock>
    800019d6:	854a                	mv	a0,s2
    800019d8:	a1cff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    800019dc:	00007797          	auipc	a5,0x7
    800019e0:	ff878793          	addi	a5,a5,-8 # 800089d4 <nextpid>
    800019e4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019e6:	0014871b          	addiw	a4,s1,1
    800019ea:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019ec:	854a                	mv	a0,s2
    800019ee:	a9eff0ef          	jal	80000c8c <release>
}
    800019f2:	8526                	mv	a0,s1
    800019f4:	60e2                	ld	ra,24(sp)
    800019f6:	6442                	ld	s0,16(sp)
    800019f8:	64a2                	ld	s1,8(sp)
    800019fa:	6902                	ld	s2,0(sp)
    800019fc:	6105                	addi	sp,sp,32
    800019fe:	8082                	ret

0000000080001a00 <proc_pagetable>:
{
    80001a00:	1101                	addi	sp,sp,-32
    80001a02:	ec06                	sd	ra,24(sp)
    80001a04:	e822                	sd	s0,16(sp)
    80001a06:	e426                	sd	s1,8(sp)
    80001a08:	e04a                	sd	s2,0(sp)
    80001a0a:	1000                	addi	s0,sp,32
    80001a0c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a0e:	869ff0ef          	jal	80001276 <uvmcreate>
    80001a12:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a14:	cd05                	beqz	a0,80001a4c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a16:	4729                	li	a4,10
    80001a18:	00005697          	auipc	a3,0x5
    80001a1c:	5e868693          	addi	a3,a3,1512 # 80007000 <_trampoline>
    80001a20:	6605                	lui	a2,0x1
    80001a22:	040005b7          	lui	a1,0x4000
    80001a26:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a28:	05b2                	slli	a1,a1,0xc
    80001a2a:	deaff0ef          	jal	80001014 <mappages>
    80001a2e:	02054663          	bltz	a0,80001a5a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a32:	4719                	li	a4,6
    80001a34:	05893683          	ld	a3,88(s2)
    80001a38:	6605                	lui	a2,0x1
    80001a3a:	020005b7          	lui	a1,0x2000
    80001a3e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a40:	05b6                	slli	a1,a1,0xd
    80001a42:	8526                	mv	a0,s1
    80001a44:	dd0ff0ef          	jal	80001014 <mappages>
    80001a48:	00054f63          	bltz	a0,80001a66 <proc_pagetable+0x66>
}
    80001a4c:	8526                	mv	a0,s1
    80001a4e:	60e2                	ld	ra,24(sp)
    80001a50:	6442                	ld	s0,16(sp)
    80001a52:	64a2                	ld	s1,8(sp)
    80001a54:	6902                	ld	s2,0(sp)
    80001a56:	6105                	addi	sp,sp,32
    80001a58:	8082                	ret
    uvmfree(pagetable, 0);
    80001a5a:	4581                	li	a1,0
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	9e7ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a62:	4481                	li	s1,0
    80001a64:	b7e5                	j	80001a4c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a66:	4681                	li	a3,0
    80001a68:	4605                	li	a2,1
    80001a6a:	040005b7          	lui	a1,0x4000
    80001a6e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a70:	05b2                	slli	a1,a1,0xc
    80001a72:	8526                	mv	a0,s1
    80001a74:	f46ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a78:	4581                	li	a1,0
    80001a7a:	8526                	mv	a0,s1
    80001a7c:	9c9ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a80:	4481                	li	s1,0
    80001a82:	b7e9                	j	80001a4c <proc_pagetable+0x4c>

0000000080001a84 <proc_freepagetable>:
{
    80001a84:	1101                	addi	sp,sp,-32
    80001a86:	ec06                	sd	ra,24(sp)
    80001a88:	e822                	sd	s0,16(sp)
    80001a8a:	e426                	sd	s1,8(sp)
    80001a8c:	e04a                	sd	s2,0(sp)
    80001a8e:	1000                	addi	s0,sp,32
    80001a90:	84aa                	mv	s1,a0
    80001a92:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a94:	4681                	li	a3,0
    80001a96:	4605                	li	a2,1
    80001a98:	040005b7          	lui	a1,0x4000
    80001a9c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a9e:	05b2                	slli	a1,a1,0xc
    80001aa0:	f1aff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001aa4:	4681                	li	a3,0
    80001aa6:	4605                	li	a2,1
    80001aa8:	020005b7          	lui	a1,0x2000
    80001aac:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aae:	05b6                	slli	a1,a1,0xd
    80001ab0:	8526                	mv	a0,s1
    80001ab2:	f08ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001ab6:	85ca                	mv	a1,s2
    80001ab8:	8526                	mv	a0,s1
    80001aba:	98bff0ef          	jal	80001444 <uvmfree>
}
    80001abe:	60e2                	ld	ra,24(sp)
    80001ac0:	6442                	ld	s0,16(sp)
    80001ac2:	64a2                	ld	s1,8(sp)
    80001ac4:	6902                	ld	s2,0(sp)
    80001ac6:	6105                	addi	sp,sp,32
    80001ac8:	8082                	ret

0000000080001aca <freeproc>:
{
    80001aca:	1101                	addi	sp,sp,-32
    80001acc:	ec06                	sd	ra,24(sp)
    80001ace:	e822                	sd	s0,16(sp)
    80001ad0:	e426                	sd	s1,8(sp)
    80001ad2:	1000                	addi	s0,sp,32
    80001ad4:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001ad6:	6d28                	ld	a0,88(a0)
    80001ad8:	c119                	beqz	a0,80001ade <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001ada:	f69fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001ade:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ae2:	68a8                	ld	a0,80(s1)
    80001ae4:	c501                	beqz	a0,80001aec <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ae6:	64ac                	ld	a1,72(s1)
    80001ae8:	f9dff0ef          	jal	80001a84 <proc_freepagetable>
  p->pagetable = 0;
    80001aec:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001af0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001af4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001af8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001afc:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b00:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b04:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b08:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b0c:	0004ac23          	sw	zero,24(s1)
}
    80001b10:	60e2                	ld	ra,24(sp)
    80001b12:	6442                	ld	s0,16(sp)
    80001b14:	64a2                	ld	s1,8(sp)
    80001b16:	6105                	addi	sp,sp,32
    80001b18:	8082                	ret

0000000080001b1a <allocproc>:
{
    80001b1a:	1101                	addi	sp,sp,-32
    80001b1c:	ec06                	sd	ra,24(sp)
    80001b1e:	e822                	sd	s0,16(sp)
    80001b20:	e426                	sd	s1,8(sp)
    80001b22:	e04a                	sd	s2,0(sp)
    80001b24:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b26:	0000f497          	auipc	s1,0xf
    80001b2a:	48a48493          	addi	s1,s1,1162 # 80010fb0 <proc>
    80001b2e:	000d3917          	auipc	s2,0xd3
    80001b32:	98290913          	addi	s2,s2,-1662 # 800d44b0 <mlfq>
    acquire(&p->lock);
    80001b36:	8526                	mv	a0,s1
    80001b38:	8bcff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001b3c:	4c9c                	lw	a5,24(s1)
    80001b3e:	cb91                	beqz	a5,80001b52 <allocproc+0x38>
      release(&p->lock);
    80001b40:	8526                	mv	a0,s1
    80001b42:	94aff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b46:	19048493          	addi	s1,s1,400
    80001b4a:	ff2496e3          	bne	s1,s2,80001b36 <allocproc+0x1c>
  return 0;
    80001b4e:	4481                	li	s1,0
    80001b50:	a8a5                	j	80001bc8 <allocproc+0xae>
  p->pid = allocpid();
    80001b52:	e71ff0ef          	jal	800019c2 <allocpid>
    80001b56:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b58:	4785                	li	a5,1
    80001b5a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b5c:	fc9fe0ef          	jal	80000b24 <kalloc>
    80001b60:	892a                	mv	s2,a0
    80001b62:	eca8                	sd	a0,88(s1)
    80001b64:	c92d                	beqz	a0,80001bd6 <allocproc+0xbc>
  p->pagetable = proc_pagetable(p);
    80001b66:	8526                	mv	a0,s1
    80001b68:	e99ff0ef          	jal	80001a00 <proc_pagetable>
    80001b6c:	892a                	mv	s2,a0
    80001b6e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b70:	c93d                	beqz	a0,80001be6 <allocproc+0xcc>
  memset(&p->context, 0, sizeof(p->context));
    80001b72:	07000613          	li	a2,112
    80001b76:	4581                	li	a1,0
    80001b78:	06048513          	addi	a0,s1,96
    80001b7c:	94cff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b80:	00000797          	auipc	a5,0x0
    80001b84:	df678793          	addi	a5,a5,-522 # 80001976 <forkret>
    80001b88:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b8a:	60bc                	ld	a5,64(s1)
    80001b8c:	6705                	lui	a4,0x1
    80001b8e:	97ba                	add	a5,a5,a4
    80001b90:	f4bc                	sd	a5,104(s1)
  p->arrival_time = ticks;
    80001b92:	00007797          	auipc	a5,0x7
    80001b96:	ec67a783          	lw	a5,-314(a5) # 80008a58 <ticks>
    80001b9a:	16f4a423          	sw	a5,360(s1)
  p->priority = 10;
    80001b9e:	47a9                	li	a5,10
    80001ba0:	16f4a623          	sw	a5,364(s1)
  p->last_runtime = 1;
    80001ba4:	4785                	li	a5,1
    80001ba6:	16f4a823          	sw	a5,368(s1)
  p->queue_level = 0;
    80001baa:	1604ac23          	sw	zero,376(s1)
  p->time_slice = 0;
    80001bae:	1604ae23          	sw	zero,380(s1)
  p->total_ticks = 0;
    80001bb2:	1804a023          	sw	zero,384(s1)
  safestrcpy(p->name, "unknown", sizeof(p->name));
    80001bb6:	4641                	li	a2,16
    80001bb8:	00006597          	auipc	a1,0x6
    80001bbc:	67058593          	addi	a1,a1,1648 # 80008228 <etext+0x228>
    80001bc0:	15848513          	addi	a0,s1,344
    80001bc4:	a42ff0ef          	jal	80000e06 <safestrcpy>
}
    80001bc8:	8526                	mv	a0,s1
    80001bca:	60e2                	ld	ra,24(sp)
    80001bcc:	6442                	ld	s0,16(sp)
    80001bce:	64a2                	ld	s1,8(sp)
    80001bd0:	6902                	ld	s2,0(sp)
    80001bd2:	6105                	addi	sp,sp,32
    80001bd4:	8082                	ret
    freeproc(p);
    80001bd6:	8526                	mv	a0,s1
    80001bd8:	ef3ff0ef          	jal	80001aca <freeproc>
    release(&p->lock);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	8aeff0ef          	jal	80000c8c <release>
    return 0;
    80001be2:	84ca                	mv	s1,s2
    80001be4:	b7d5                	j	80001bc8 <allocproc+0xae>
    freeproc(p);
    80001be6:	8526                	mv	a0,s1
    80001be8:	ee3ff0ef          	jal	80001aca <freeproc>
    release(&p->lock);
    80001bec:	8526                	mv	a0,s1
    80001bee:	89eff0ef          	jal	80000c8c <release>
    return 0;
    80001bf2:	84ca                	mv	s1,s2
    80001bf4:	bfd1                	j	80001bc8 <allocproc+0xae>

0000000080001bf6 <enqueue_to_mlfq>:
  int level = p->queue_level;
    80001bf6:	17852583          	lw	a1,376(a0)
  for (int i = 0; i < mlfq.qsize[level]; i++) {
    80001bfa:	678d                	lui	a5,0x3
    80001bfc:	ee478793          	addi	a5,a5,-284 # 2ee4 <_entry-0x7fffd11c>
    80001c00:	97ae                	add	a5,a5,a1
    80001c02:	078a                	slli	a5,a5,0x2
    80001c04:	000d3717          	auipc	a4,0xd3
    80001c08:	8ac70713          	addi	a4,a4,-1876 # 800d44b0 <mlfq>
    80001c0c:	97ba                	add	a5,a5,a4
    80001c0e:	4794                	lw	a3,8(a5)
    80001c10:	08d05863          	blez	a3,80001ca0 <enqueue_to_mlfq+0xaa>
    80001c14:	6711                	lui	a4,0x4
    80001c16:	e8070713          	addi	a4,a4,-384 # 3e80 <_entry-0x7fffc180>
    80001c1a:	02e58733          	mul	a4,a1,a4
    80001c1e:	000d3797          	auipc	a5,0xd3
    80001c22:	8aa78793          	addi	a5,a5,-1878 # 800d44c8 <mlfq+0x18>
    80001c26:	973e                	add	a4,a4,a5
    80001c28:	4781                	li	a5,0
    if (mlfq.queue[level][i] == p) {
    80001c2a:	6310                	ld	a2,0(a4)
    80001c2c:	00a60763          	beq	a2,a0,80001c3a <enqueue_to_mlfq+0x44>
  for (int i = 0; i < mlfq.qsize[level]; i++) {
    80001c30:	2785                	addiw	a5,a5,1
    80001c32:	0721                	addi	a4,a4,8
    80001c34:	fed79be3          	bne	a5,a3,80001c2a <enqueue_to_mlfq+0x34>
    80001c38:	a0a9                	j	80001c82 <enqueue_to_mlfq+0x8c>
      for (int j = i; j < mlfq.qsize[level] - 1; j++) {
    80001c3a:	fff6881b          	addiw	a6,a3,-1
    80001c3e:	0008071b          	sext.w	a4,a6
    80001c42:	02e7d463          	bge	a5,a4,80001c6a <enqueue_to_mlfq+0x74>
    80001c46:	7d000713          	li	a4,2000
    80001c4a:	02e58733          	mul	a4,a1,a4
    80001c4e:	973e                	add	a4,a4,a5
    80001c50:	070e                	slli	a4,a4,0x3
    80001c52:	000d3617          	auipc	a2,0xd3
    80001c56:	85e60613          	addi	a2,a2,-1954 # 800d44b0 <mlfq>
    80001c5a:	9732                	add	a4,a4,a2
    80001c5c:	36fd                	addiw	a3,a3,-1
        mlfq.queue[level][j] = mlfq.queue[level][j+1];
    80001c5e:	2785                	addiw	a5,a5,1
    80001c60:	7310                	ld	a2,32(a4)
    80001c62:	ef10                	sd	a2,24(a4)
      for (int j = i; j < mlfq.qsize[level] - 1; j++) {
    80001c64:	0721                	addi	a4,a4,8
    80001c66:	fed79ce3          	bne	a5,a3,80001c5e <enqueue_to_mlfq+0x68>
      mlfq.qsize[level]--;
    80001c6a:	678d                	lui	a5,0x3
    80001c6c:	ee478793          	addi	a5,a5,-284 # 2ee4 <_entry-0x7fffd11c>
    80001c70:	97ae                	add	a5,a5,a1
    80001c72:	078a                	slli	a5,a5,0x2
    80001c74:	000d3717          	auipc	a4,0xd3
    80001c78:	83c70713          	addi	a4,a4,-1988 # 800d44b0 <mlfq>
    80001c7c:	97ba                	add	a5,a5,a4
    80001c7e:	0107a423          	sw	a6,8(a5)
  if (mlfq.qsize[level] < NPROC) {
    80001c82:	678d                	lui	a5,0x3
    80001c84:	ee478793          	addi	a5,a5,-284 # 2ee4 <_entry-0x7fffd11c>
    80001c88:	97ae                	add	a5,a5,a1
    80001c8a:	078a                	slli	a5,a5,0x2
    80001c8c:	000d3717          	auipc	a4,0xd3
    80001c90:	82470713          	addi	a4,a4,-2012 # 800d44b0 <mlfq>
    80001c94:	97ba                	add	a5,a5,a4
    80001c96:	4794                	lw	a3,8(a5)
    80001c98:	7cf00793          	li	a5,1999
    80001c9c:	02d7c963          	blt	a5,a3,80001cce <enqueue_to_mlfq+0xd8>
    mlfq.queue[level][mlfq.qsize[level]++] = p;
    80001ca0:	000d3717          	auipc	a4,0xd3
    80001ca4:	81070713          	addi	a4,a4,-2032 # 800d44b0 <mlfq>
    80001ca8:	678d                	lui	a5,0x3
    80001caa:	ee478793          	addi	a5,a5,-284 # 2ee4 <_entry-0x7fffd11c>
    80001cae:	97ae                	add	a5,a5,a1
    80001cb0:	078a                	slli	a5,a5,0x2
    80001cb2:	97ba                	add	a5,a5,a4
    80001cb4:	0016861b          	addiw	a2,a3,1
    80001cb8:	c790                	sw	a2,8(a5)
    80001cba:	7d000793          	li	a5,2000
    80001cbe:	02f587b3          	mul	a5,a1,a5
    80001cc2:	97b6                	add	a5,a5,a3
    80001cc4:	0789                	addi	a5,a5,2
    80001cc6:	078e                	slli	a5,a5,0x3
    80001cc8:	973e                	add	a4,a4,a5
    80001cca:	e708                	sd	a0,8(a4)
    80001ccc:	8082                	ret
enqueue_to_mlfq(struct proc *p) {
    80001cce:	1141                	addi	sp,sp,-16
    80001cd0:	e406                	sd	ra,8(sp)
    80001cd2:	e022                	sd	s0,0(sp)
    80001cd4:	0800                	addi	s0,sp,16
    panic("MLFQ: queue full");
    80001cd6:	00006517          	auipc	a0,0x6
    80001cda:	55a50513          	addi	a0,a0,1370 # 80008230 <etext+0x230>
    80001cde:	ab7fe0ef          	jal	80000794 <panic>

0000000080001ce2 <userinit>:
{
    80001ce2:	1101                	addi	sp,sp,-32
    80001ce4:	ec06                	sd	ra,24(sp)
    80001ce6:	e822                	sd	s0,16(sp)
    80001ce8:	e426                	sd	s1,8(sp)
    80001cea:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cec:	e2fff0ef          	jal	80001b1a <allocproc>
    80001cf0:	84aa                	mv	s1,a0
  initproc = p;
    80001cf2:	00007797          	auipc	a5,0x7
    80001cf6:	d4a7bf23          	sd	a0,-674(a5) # 80008a50 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cfa:	03400613          	li	a2,52
    80001cfe:	00007597          	auipc	a1,0x7
    80001d02:	ce258593          	addi	a1,a1,-798 # 800089e0 <initcode>
    80001d06:	6928                	ld	a0,80(a0)
    80001d08:	d94ff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001d0c:	6785                	lui	a5,0x1
    80001d0e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d10:	6cb8                	ld	a4,88(s1)
    80001d12:	00073c23          	sd	zero,24(a4)
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d16:	6cb8                	ld	a4,88(s1)
    80001d18:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d1a:	4641                	li	a2,16
    80001d1c:	00006597          	auipc	a1,0x6
    80001d20:	52c58593          	addi	a1,a1,1324 # 80008248 <etext+0x248>
    80001d24:	15848513          	addi	a0,s1,344
    80001d28:	8deff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001d2c:	00006517          	auipc	a0,0x6
    80001d30:	52c50513          	addi	a0,a0,1324 # 80008258 <etext+0x258>
    80001d34:	6f6020ef          	jal	8000442a <namei>
    80001d38:	14a4b823          	sd	a0,336(s1)
  p->arrival_time = ticks;
    80001d3c:	00007797          	auipc	a5,0x7
    80001d40:	d1c7a783          	lw	a5,-740(a5) # 80008a58 <ticks>
    80001d44:	16f4a423          	sw	a5,360(s1)
  p->priority = 10;
    80001d48:	4729                	li	a4,10
    80001d4a:	16e4a623          	sw	a4,364(s1)
  p->last_runtime = 1;
    80001d4e:	4705                	li	a4,1
    80001d50:	16e4a823          	sw	a4,368(s1)
  p->queue_level = 0;
    80001d54:	1604ac23          	sw	zero,376(s1)
  p->time_slice = 0;
    80001d58:	1604ae23          	sw	zero,380(s1)
  p->total_ticks = 0;
    80001d5c:	1804a023          	sw	zero,384(s1)
  p->state = RUNNABLE;
    80001d60:	470d                	li	a4,3
    80001d62:	cc98                	sw	a4,24(s1)
  p->ready_time = ticks;
    80001d64:	18f4a223          	sw	a5,388(s1)
  if (current_policy == 4) {
    80001d68:	00007717          	auipc	a4,0x7
    80001d6c:	ce072703          	lw	a4,-800(a4) # 80008a48 <current_policy>
    80001d70:	4791                	li	a5,4
    80001d72:	00f70a63          	beq	a4,a5,80001d86 <userinit+0xa4>
  release(&p->lock);
    80001d76:	8526                	mv	a0,s1
    80001d78:	f15fe0ef          	jal	80000c8c <release>
}
    80001d7c:	60e2                	ld	ra,24(sp)
    80001d7e:	6442                	ld	s0,16(sp)
    80001d80:	64a2                	ld	s1,8(sp)
    80001d82:	6105                	addi	sp,sp,32
    80001d84:	8082                	ret
    acquire(&mlfq.lock);
    80001d86:	000d2517          	auipc	a0,0xd2
    80001d8a:	72a50513          	addi	a0,a0,1834 # 800d44b0 <mlfq>
    80001d8e:	e67fe0ef          	jal	80000bf4 <acquire>
    enqueue_to_mlfq(p);
    80001d92:	8526                	mv	a0,s1
    80001d94:	e63ff0ef          	jal	80001bf6 <enqueue_to_mlfq>
    release(&mlfq.lock);
    80001d98:	000d2517          	auipc	a0,0xd2
    80001d9c:	71850513          	addi	a0,a0,1816 # 800d44b0 <mlfq>
    80001da0:	eedfe0ef          	jal	80000c8c <release>
    80001da4:	bfc9                	j	80001d76 <userinit+0x94>

0000000080001da6 <growproc>:
{
    80001da6:	1101                	addi	sp,sp,-32
    80001da8:	ec06                	sd	ra,24(sp)
    80001daa:	e822                	sd	s0,16(sp)
    80001dac:	e426                	sd	s1,8(sp)
    80001dae:	e04a                	sd	s2,0(sp)
    80001db0:	1000                	addi	s0,sp,32
    80001db2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001db4:	b93ff0ef          	jal	80001946 <myproc>
    80001db8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dba:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dbc:	01204c63          	bgtz	s2,80001dd4 <growproc+0x2e>
  } else if(n < 0){
    80001dc0:	02094463          	bltz	s2,80001de8 <growproc+0x42>
  p->sz = sz;
    80001dc4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dc6:	4501                	li	a0,0
}
    80001dc8:	60e2                	ld	ra,24(sp)
    80001dca:	6442                	ld	s0,16(sp)
    80001dcc:	64a2                	ld	s1,8(sp)
    80001dce:	6902                	ld	s2,0(sp)
    80001dd0:	6105                	addi	sp,sp,32
    80001dd2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dd4:	4691                	li	a3,4
    80001dd6:	00b90633          	add	a2,s2,a1
    80001dda:	6928                	ld	a0,80(a0)
    80001ddc:	d62ff0ef          	jal	8000133e <uvmalloc>
    80001de0:	85aa                	mv	a1,a0
    80001de2:	f16d                	bnez	a0,80001dc4 <growproc+0x1e>
      return -1;
    80001de4:	557d                	li	a0,-1
    80001de6:	b7cd                	j	80001dc8 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001de8:	00b90633          	add	a2,s2,a1
    80001dec:	6928                	ld	a0,80(a0)
    80001dee:	d0cff0ef          	jal	800012fa <uvmdealloc>
    80001df2:	85aa                	mv	a1,a0
    80001df4:	bfc1                	j	80001dc4 <growproc+0x1e>

0000000080001df6 <fork>:
{
    80001df6:	7139                	addi	sp,sp,-64
    80001df8:	fc06                	sd	ra,56(sp)
    80001dfa:	f822                	sd	s0,48(sp)
    80001dfc:	f04a                	sd	s2,32(sp)
    80001dfe:	e456                	sd	s5,8(sp)
    80001e00:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e02:	b45ff0ef          	jal	80001946 <myproc>
    80001e06:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e08:	d13ff0ef          	jal	80001b1a <allocproc>
    80001e0c:	14050363          	beqz	a0,80001f52 <fork+0x15c>
    80001e10:	ec4e                	sd	s3,24(sp)
    80001e12:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e14:	048ab603          	ld	a2,72(s5)
    80001e18:	692c                	ld	a1,80(a0)
    80001e1a:	050ab503          	ld	a0,80(s5)
    80001e1e:	e58ff0ef          	jal	80001476 <uvmcopy>
    80001e22:	04054a63          	bltz	a0,80001e76 <fork+0x80>
    80001e26:	f426                	sd	s1,40(sp)
    80001e28:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001e2a:	048ab783          	ld	a5,72(s5)
    80001e2e:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e32:	058ab683          	ld	a3,88(s5)
    80001e36:	87b6                	mv	a5,a3
    80001e38:	0589b703          	ld	a4,88(s3)
    80001e3c:	12068693          	addi	a3,a3,288
    80001e40:	0007b803          	ld	a6,0(a5)
    80001e44:	6788                	ld	a0,8(a5)
    80001e46:	6b8c                	ld	a1,16(a5)
    80001e48:	6f90                	ld	a2,24(a5)
    80001e4a:	01073023          	sd	a6,0(a4)
    80001e4e:	e708                	sd	a0,8(a4)
    80001e50:	eb0c                	sd	a1,16(a4)
    80001e52:	ef10                	sd	a2,24(a4)
    80001e54:	02078793          	addi	a5,a5,32
    80001e58:	02070713          	addi	a4,a4,32
    80001e5c:	fed792e3          	bne	a5,a3,80001e40 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001e60:	0589b783          	ld	a5,88(s3)
    80001e64:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e68:	0d0a8493          	addi	s1,s5,208
    80001e6c:	0d098913          	addi	s2,s3,208
    80001e70:	150a8a13          	addi	s4,s5,336
    80001e74:	a831                	j	80001e90 <fork+0x9a>
    freeproc(np);
    80001e76:	854e                	mv	a0,s3
    80001e78:	c53ff0ef          	jal	80001aca <freeproc>
    release(&np->lock);
    80001e7c:	854e                	mv	a0,s3
    80001e7e:	e0ffe0ef          	jal	80000c8c <release>
    return -1;
    80001e82:	597d                	li	s2,-1
    80001e84:	69e2                	ld	s3,24(sp)
    80001e86:	a879                	j	80001f24 <fork+0x12e>
  for(i = 0; i < NOFILE; i++)
    80001e88:	04a1                	addi	s1,s1,8
    80001e8a:	0921                	addi	s2,s2,8
    80001e8c:	01448963          	beq	s1,s4,80001e9e <fork+0xa8>
    if(p->ofile[i])
    80001e90:	6088                	ld	a0,0(s1)
    80001e92:	d97d                	beqz	a0,80001e88 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e94:	327020ef          	jal	800049ba <filedup>
    80001e98:	00a93023          	sd	a0,0(s2)
    80001e9c:	b7f5                	j	80001e88 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001e9e:	150ab503          	ld	a0,336(s5)
    80001ea2:	679010ef          	jal	80003d1a <idup>
    80001ea6:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(np->name));
    80001eaa:	4641                	li	a2,16
    80001eac:	158a8593          	addi	a1,s5,344
    80001eb0:	15898513          	addi	a0,s3,344
    80001eb4:	f53fe0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001eb8:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ebc:	854e                	mv	a0,s3
    80001ebe:	dcffe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001ec2:	0000f497          	auipc	s1,0xf
    80001ec6:	cd648493          	addi	s1,s1,-810 # 80010b98 <wait_lock>
    80001eca:	8526                	mv	a0,s1
    80001ecc:	d29fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001ed0:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	db7fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001eda:	854e                	mv	a0,s3
    80001edc:	d19fe0ef          	jal	80000bf4 <acquire>
  np->priority = 10;
    80001ee0:	47a9                	li	a5,10
    80001ee2:	16f9a623          	sw	a5,364(s3)
  np->last_runtime = 1;
    80001ee6:	4785                	li	a5,1
    80001ee8:	16f9a823          	sw	a5,368(s3)
  np->queue_level = 0;
    80001eec:	1609ac23          	sw	zero,376(s3)
  np->time_slice = 0;
    80001ef0:	1609ae23          	sw	zero,380(s3)
  np->total_ticks = 0;
    80001ef4:	1809a023          	sw	zero,384(s3)
  np->state = RUNNABLE;
    80001ef8:	478d                	li	a5,3
    80001efa:	00f9ac23          	sw	a5,24(s3)
  np->ready_time = ticks;
    80001efe:	00007797          	auipc	a5,0x7
    80001f02:	b5a7a783          	lw	a5,-1190(a5) # 80008a58 <ticks>
    80001f06:	18f9a223          	sw	a5,388(s3)
  if (current_policy == 4) {
    80001f0a:	00007717          	auipc	a4,0x7
    80001f0e:	b3e72703          	lw	a4,-1218(a4) # 80008a48 <current_policy>
    80001f12:	4791                	li	a5,4
    80001f14:	00f70f63          	beq	a4,a5,80001f32 <fork+0x13c>
  release(&np->lock);
    80001f18:	854e                	mv	a0,s3
    80001f1a:	d73fe0ef          	jal	80000c8c <release>
  return pid;
    80001f1e:	74a2                	ld	s1,40(sp)
    80001f20:	69e2                	ld	s3,24(sp)
    80001f22:	6a42                	ld	s4,16(sp)
}
    80001f24:	854a                	mv	a0,s2
    80001f26:	70e2                	ld	ra,56(sp)
    80001f28:	7442                	ld	s0,48(sp)
    80001f2a:	7902                	ld	s2,32(sp)
    80001f2c:	6aa2                	ld	s5,8(sp)
    80001f2e:	6121                	addi	sp,sp,64
    80001f30:	8082                	ret
    acquire(&mlfq.lock);
    80001f32:	000d2517          	auipc	a0,0xd2
    80001f36:	57e50513          	addi	a0,a0,1406 # 800d44b0 <mlfq>
    80001f3a:	cbbfe0ef          	jal	80000bf4 <acquire>
    enqueue_to_mlfq(np);
    80001f3e:	854e                	mv	a0,s3
    80001f40:	cb7ff0ef          	jal	80001bf6 <enqueue_to_mlfq>
    release(&mlfq.lock);
    80001f44:	000d2517          	auipc	a0,0xd2
    80001f48:	56c50513          	addi	a0,a0,1388 # 800d44b0 <mlfq>
    80001f4c:	d41fe0ef          	jal	80000c8c <release>
    80001f50:	b7e1                	j	80001f18 <fork+0x122>
    return -1;
    80001f52:	597d                	li	s2,-1
    80001f54:	bfc1                	j	80001f24 <fork+0x12e>

0000000080001f56 <fork_with_priority>:
{
    80001f56:	7139                	addi	sp,sp,-64
    80001f58:	fc06                	sd	ra,56(sp)
    80001f5a:	f822                	sd	s0,48(sp)
    80001f5c:	f04a                	sd	s2,32(sp)
    80001f5e:	e456                	sd	s5,8(sp)
    80001f60:	e05a                	sd	s6,0(sp)
    80001f62:	0080                	addi	s0,sp,64
    80001f64:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001f66:	9e1ff0ef          	jal	80001946 <myproc>
    80001f6a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f6c:	bafff0ef          	jal	80001b1a <allocproc>
    80001f70:	12050d63          	beqz	a0,800020aa <fork_with_priority+0x154>
    80001f74:	ec4e                	sd	s3,24(sp)
    80001f76:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f78:	048ab603          	ld	a2,72(s5)
    80001f7c:	692c                	ld	a1,80(a0)
    80001f7e:	050ab503          	ld	a0,80(s5)
    80001f82:	cf4ff0ef          	jal	80001476 <uvmcopy>
    80001f86:	04054a63          	bltz	a0,80001fda <fork_with_priority+0x84>
    80001f8a:	f426                	sd	s1,40(sp)
    80001f8c:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001f8e:	048ab783          	ld	a5,72(s5)
    80001f92:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f96:	058ab683          	ld	a3,88(s5)
    80001f9a:	87b6                	mv	a5,a3
    80001f9c:	0589b703          	ld	a4,88(s3)
    80001fa0:	12068693          	addi	a3,a3,288
    80001fa4:	0007b803          	ld	a6,0(a5)
    80001fa8:	6788                	ld	a0,8(a5)
    80001faa:	6b8c                	ld	a1,16(a5)
    80001fac:	6f90                	ld	a2,24(a5)
    80001fae:	01073023          	sd	a6,0(a4)
    80001fb2:	e708                	sd	a0,8(a4)
    80001fb4:	eb0c                	sd	a1,16(a4)
    80001fb6:	ef10                	sd	a2,24(a4)
    80001fb8:	02078793          	addi	a5,a5,32
    80001fbc:	02070713          	addi	a4,a4,32
    80001fc0:	fed792e3          	bne	a5,a3,80001fa4 <fork_with_priority+0x4e>
  np->trapframe->a0 = 0;  // Child returns 0 from fork.
    80001fc4:	0589b783          	ld	a5,88(s3)
    80001fc8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001fcc:	0d0a8493          	addi	s1,s5,208
    80001fd0:	0d098913          	addi	s2,s3,208
    80001fd4:	150a8a13          	addi	s4,s5,336
    80001fd8:	a831                	j	80001ff4 <fork_with_priority+0x9e>
    freeproc(np);
    80001fda:	854e                	mv	a0,s3
    80001fdc:	aefff0ef          	jal	80001aca <freeproc>
    release(&np->lock);
    80001fe0:	854e                	mv	a0,s3
    80001fe2:	cabfe0ef          	jal	80000c8c <release>
    return -1;
    80001fe6:	597d                	li	s2,-1
    80001fe8:	69e2                	ld	s3,24(sp)
    80001fea:	a841                	j	8000207a <fork_with_priority+0x124>
  for(i = 0; i < NOFILE; i++)
    80001fec:	04a1                	addi	s1,s1,8
    80001fee:	0921                	addi	s2,s2,8
    80001ff0:	01448963          	beq	s1,s4,80002002 <fork_with_priority+0xac>
    if(p->ofile[i])
    80001ff4:	6088                	ld	a0,0(s1)
    80001ff6:	d97d                	beqz	a0,80001fec <fork_with_priority+0x96>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ff8:	1c3020ef          	jal	800049ba <filedup>
    80001ffc:	00a93023          	sd	a0,0(s2)
    80002000:	b7f5                	j	80001fec <fork_with_priority+0x96>
  np->cwd = idup(p->cwd);
    80002002:	150ab503          	ld	a0,336(s5)
    80002006:	515010ef          	jal	80003d1a <idup>
    8000200a:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000200e:	4641                	li	a2,16
    80002010:	158a8593          	addi	a1,s5,344
    80002014:	15898513          	addi	a0,s3,344
    80002018:	deffe0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    8000201c:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002020:	854e                	mv	a0,s3
    80002022:	c6bfe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80002026:	0000f497          	auipc	s1,0xf
    8000202a:	b7248493          	addi	s1,s1,-1166 # 80010b98 <wait_lock>
    8000202e:	8526                	mv	a0,s1
    80002030:	bc5fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80002034:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002038:	8526                	mv	a0,s1
    8000203a:	c53fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    8000203e:	854e                	mv	a0,s3
    80002040:	bb5fe0ef          	jal	80000bf4 <acquire>
  np->priority = priority; 
    80002044:	1769a623          	sw	s6,364(s3)
  np->last_runtime = 1;
    80002048:	4785                	li	a5,1
    8000204a:	16f9a823          	sw	a5,368(s3)
  np->queue_level = 0;
    8000204e:	1609ac23          	sw	zero,376(s3)
  np->time_slice = 0;
    80002052:	1609ae23          	sw	zero,380(s3)
  np->total_ticks = 0;
    80002056:	1809a023          	sw	zero,384(s3)
  np->state = RUNNABLE;
    8000205a:	478d                	li	a5,3
    8000205c:	00f9ac23          	sw	a5,24(s3)
  if (current_policy == SCHED_MLFQ) {
    80002060:	00007717          	auipc	a4,0x7
    80002064:	9e872703          	lw	a4,-1560(a4) # 80008a48 <current_policy>
    80002068:	4791                	li	a5,4
    8000206a:	02f70063          	beq	a4,a5,8000208a <fork_with_priority+0x134>
  release(&np->lock);
    8000206e:	854e                	mv	a0,s3
    80002070:	c1dfe0ef          	jal	80000c8c <release>
  return pid;
    80002074:	74a2                	ld	s1,40(sp)
    80002076:	69e2                	ld	s3,24(sp)
    80002078:	6a42                	ld	s4,16(sp)
}
    8000207a:	854a                	mv	a0,s2
    8000207c:	70e2                	ld	ra,56(sp)
    8000207e:	7442                	ld	s0,48(sp)
    80002080:	7902                	ld	s2,32(sp)
    80002082:	6aa2                	ld	s5,8(sp)
    80002084:	6b02                	ld	s6,0(sp)
    80002086:	6121                	addi	sp,sp,64
    80002088:	8082                	ret
    acquire(&mlfq.lock);
    8000208a:	000d2517          	auipc	a0,0xd2
    8000208e:	42650513          	addi	a0,a0,1062 # 800d44b0 <mlfq>
    80002092:	b63fe0ef          	jal	80000bf4 <acquire>
    enqueue_to_mlfq(np);
    80002096:	854e                	mv	a0,s3
    80002098:	b5fff0ef          	jal	80001bf6 <enqueue_to_mlfq>
    release(&mlfq.lock);
    8000209c:	000d2517          	auipc	a0,0xd2
    800020a0:	41450513          	addi	a0,a0,1044 # 800d44b0 <mlfq>
    800020a4:	be9fe0ef          	jal	80000c8c <release>
    800020a8:	b7d9                	j	8000206e <fork_with_priority+0x118>
    return -1;
    800020aa:	597d                	li	s2,-1
    800020ac:	b7f9                	j	8000207a <fork_with_priority+0x124>

00000000800020ae <compact_queue>:
compact_queue(int level) {
    800020ae:	1141                	addi	sp,sp,-16
    800020b0:	e422                	sd	s0,8(sp)
    800020b2:	0800                	addi	s0,sp,16
  for (int i = 0; i < mlfq.qsize[level]; i++) {
    800020b4:	678d                	lui	a5,0x3
    800020b6:	ee478793          	addi	a5,a5,-284 # 2ee4 <_entry-0x7fffd11c>
    800020ba:	97aa                	add	a5,a5,a0
    800020bc:	078a                	slli	a5,a5,0x2
    800020be:	000d2717          	auipc	a4,0xd2
    800020c2:	3f270713          	addi	a4,a4,1010 # 800d44b0 <mlfq>
    800020c6:	97ba                	add	a5,a5,a4
    800020c8:	479c                	lw	a5,8(a5)
    800020ca:	04f05763          	blez	a5,80002118 <compact_queue+0x6a>
    800020ce:	6711                	lui	a4,0x4
    800020d0:	e8070713          	addi	a4,a4,-384 # 3e80 <_entry-0x7fffc180>
    800020d4:	02e50733          	mul	a4,a0,a4
    800020d8:	000d2697          	auipc	a3,0xd2
    800020dc:	3d868693          	addi	a3,a3,984 # 800d44b0 <mlfq>
    800020e0:	9736                	add	a4,a4,a3
    800020e2:	7d000593          	li	a1,2000
    800020e6:	02b505b3          	mul	a1,a0,a1
    800020ea:	95be                	add	a1,a1,a5
    800020ec:	058e                	slli	a1,a1,0x3
    800020ee:	95b6                	add	a1,a1,a3
  int j = 0;
    800020f0:	4601                	li	a2,0
      mlfq.queue[level][j++] = mlfq.queue[level][i];
    800020f2:	88b6                	mv	a7,a3
    800020f4:	7d000813          	li	a6,2000
    800020f8:	03050833          	mul	a6,a0,a6
    800020fc:	a819                	j	80002112 <compact_queue+0x64>
    800020fe:	00c807b3          	add	a5,a6,a2
    80002102:	0789                	addi	a5,a5,2
    80002104:	078e                	slli	a5,a5,0x3
    80002106:	97c6                	add	a5,a5,a7
    80002108:	e794                	sd	a3,8(a5)
    8000210a:	2605                	addiw	a2,a2,1
  for (int i = 0; i < mlfq.qsize[level]; i++) {
    8000210c:	0721                	addi	a4,a4,8
    8000210e:	00b70663          	beq	a4,a1,8000211a <compact_queue+0x6c>
    if (mlfq.queue[level][i] != 0)
    80002112:	6f14                	ld	a3,24(a4)
    80002114:	f6ed                	bnez	a3,800020fe <compact_queue+0x50>
    80002116:	bfdd                	j	8000210c <compact_queue+0x5e>
  int j = 0;
    80002118:	4601                	li	a2,0
  mlfq.qsize[level] = j;
    8000211a:	678d                	lui	a5,0x3
    8000211c:	ee478793          	addi	a5,a5,-284 # 2ee4 <_entry-0x7fffd11c>
    80002120:	953e                	add	a0,a0,a5
    80002122:	050a                	slli	a0,a0,0x2
    80002124:	000d2797          	auipc	a5,0xd2
    80002128:	38c78793          	addi	a5,a5,908 # 800d44b0 <mlfq>
    8000212c:	97aa                	add	a5,a5,a0
    8000212e:	c790                	sw	a2,8(a5)
}
    80002130:	6422                	ld	s0,8(sp)
    80002132:	0141                	addi	sp,sp,16
    80002134:	8082                	ret

0000000080002136 <scheduler>:
{
    80002136:	7119                	addi	sp,sp,-128
    80002138:	fc86                	sd	ra,120(sp)
    8000213a:	f8a2                	sd	s0,112(sp)
    8000213c:	f4a6                	sd	s1,104(sp)
    8000213e:	f0ca                	sd	s2,96(sp)
    80002140:	ecce                	sd	s3,88(sp)
    80002142:	e8d2                	sd	s4,80(sp)
    80002144:	e4d6                	sd	s5,72(sp)
    80002146:	e0da                	sd	s6,64(sp)
    80002148:	fc5e                	sd	s7,56(sp)
    8000214a:	f862                	sd	s8,48(sp)
    8000214c:	f466                	sd	s9,40(sp)
    8000214e:	f06a                	sd	s10,32(sp)
    80002150:	ec6e                	sd	s11,24(sp)
    80002152:	0100                	addi	s0,sp,128
    80002154:	8792                	mv	a5,tp
  int id = r_tp();
    80002156:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002158:	00779c93          	slli	s9,a5,0x7
    8000215c:	0000f717          	auipc	a4,0xf
    80002160:	a2470713          	addi	a4,a4,-1500 # 80010b80 <pid_lock>
    80002164:	9766                	add	a4,a4,s9
    80002166:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    8000216a:	0000f717          	auipc	a4,0xf
    8000216e:	a4e70713          	addi	a4,a4,-1458 # 80010bb8 <cpus+0x8>
    80002172:	9cba                	add	s9,s9,a4
          p->run_start_time = ticks;
    80002174:	00007a17          	auipc	s4,0x7
    80002178:	8e4a0a13          	addi	s4,s4,-1820 # 80008a58 <ticks>
          c->proc = p;
    8000217c:	079e                	slli	a5,a5,0x7
    8000217e:	0000f997          	auipc	s3,0xf
    80002182:	a0298993          	addi	s3,s3,-1534 # 80010b80 <pid_lock>
    80002186:	99be                	add	s3,s3,a5
      for(p = proc; p < &proc[NPROC]; p++) {
    80002188:	000d2497          	auipc	s1,0xd2
    8000218c:	32848493          	addi	s1,s1,808 # 800d44b0 <mlfq>
    80002190:	a051                	j	80002214 <scheduler+0xde>
      uint min_arrival = -1;
    80002192:	5bfd                	li	s7,-1
      struct proc *chosen = 0;
    80002194:	4b01                	li	s6,0
      for (p = proc; p < &proc[NPROC]; p++) {
    80002196:	0000f917          	auipc	s2,0xf
    8000219a:	e1a90913          	addi	s2,s2,-486 # 80010fb0 <proc>
        if (p->state == RUNNABLE) {
    8000219e:	4a8d                	li	s5,3
    800021a0:	a821                	j	800021b8 <scheduler+0x82>
            release(&p->lock);
    800021a2:	854a                	mv	a0,s2
    800021a4:	ae9fe0ef          	jal	80000c8c <release>
    800021a8:	a021                	j	800021b0 <scheduler+0x7a>
          release(&p->lock);
    800021aa:	854a                	mv	a0,s2
    800021ac:	ae1fe0ef          	jal	80000c8c <release>
      for (p = proc; p < &proc[NPROC]; p++) {
    800021b0:	19090913          	addi	s2,s2,400
    800021b4:	02990663          	beq	s2,s1,800021e0 <scheduler+0xaa>
        acquire(&p->lock);
    800021b8:	854a                	mv	a0,s2
    800021ba:	a3bfe0ef          	jal	80000bf4 <acquire>
        if (p->state == RUNNABLE) {
    800021be:	01892783          	lw	a5,24(s2)
    800021c2:	ff5794e3          	bne	a5,s5,800021aa <scheduler+0x74>
          if (p->arrival_time < min_arrival) {
    800021c6:	16892783          	lw	a5,360(s2)
    800021ca:	fd77fce3          	bgeu	a5,s7,800021a2 <scheduler+0x6c>
            if (chosen) {
    800021ce:	000b0563          	beqz	s6,800021d8 <scheduler+0xa2>
              release(&chosen->lock);
    800021d2:	855a                	mv	a0,s6
    800021d4:	ab9fe0ef          	jal	80000c8c <release>
            min_arrival = p->arrival_time;
    800021d8:	16892b83          	lw	s7,360(s2)
            chosen = p;
    800021dc:	8b4a                	mv	s6,s2
    800021de:	bfc9                	j	800021b0 <scheduler+0x7a>
      if (chosen) {
    800021e0:	060b0a63          	beqz	s6,80002254 <scheduler+0x11e>
        chosen->run_start_time = ticks;
    800021e4:	000a2783          	lw	a5,0(s4)
    800021e8:	18fb2423          	sw	a5,392(s6)
        chosen->waiting_time = chosen->run_start_time - chosen->ready_time;
    800021ec:	184b2703          	lw	a4,388(s6)
    800021f0:	9f99                	subw	a5,a5,a4
    800021f2:	18fb2623          	sw	a5,396(s6)
        chosen->state = RUNNING;
    800021f6:	4791                	li	a5,4
    800021f8:	00fb2c23          	sw	a5,24(s6)
        c->proc = chosen;
    800021fc:	0369b823          	sd	s6,48(s3)
        swtch(&c->context, &chosen->context);
    80002200:	060b0593          	addi	a1,s6,96
    80002204:	8566                	mv	a0,s9
    80002206:	1d1000ef          	jal	80002bd6 <swtch>
        c->proc = 0;
    8000220a:	0209b823          	sd	zero,48(s3)
        release(&chosen->lock);
    8000220e:	855a                	mv	a0,s6
    80002210:	a7dfe0ef          	jal	80000c8c <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002214:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002218:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000221c:	10079073          	csrw	sstatus,a5
    if (current_policy == 1) {
    80002220:	00007797          	auipc	a5,0x7
    80002224:	82878793          	addi	a5,a5,-2008 # 80008a48 <current_policy>
    80002228:	439c                	lw	a5,0(a5)
    8000222a:	4705                	li	a4,1
    8000222c:	f6e783e3          	beq	a5,a4,80002192 <scheduler+0x5c>
    } else if (current_policy == 2) {
    80002230:	4709                	li	a4,2
    80002232:	02e78a63          	beq	a5,a4,80002266 <scheduler+0x130>
    } else if (current_policy == 3) {
    80002236:	470d                	li	a4,3
    80002238:	0ce78363          	beq	a5,a4,800022fe <scheduler+0x1c8>
    } else if (current_policy == 4) {
    8000223c:	4711                	li	a4,4
      int found = 0;
    8000223e:	4c01                	li	s8,0
      for(p = proc; p < &proc[NPROC]; p++) {
    80002240:	0000f917          	auipc	s2,0xf
    80002244:	d7090913          	addi	s2,s2,-656 # 80010fb0 <proc>
    } else if (current_policy == 4) {
    80002248:	18e78f63          	beq	a5,a4,800023e6 <scheduler+0x2b0>
        if(p->state == RUNNABLE) {
    8000224c:	4a8d                	li	s5,3
          p->state = RUNNING;
    8000224e:	4b91                	li	s7,4
          found = 1;
    80002250:	4b05                	li	s6,1
    80002252:	acc1                	j	80002522 <scheduler+0x3ec>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002254:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002258:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000225c:	10079073          	csrw	sstatus,a5
        asm volatile("wfi");
    80002260:	10500073          	wfi
    80002264:	bf45                	j	80002214 <scheduler+0xde>
      struct proc *chosen = 0;
    80002266:	4a81                	li	s5,0
      for(p = proc; p < &proc[NPROC]; p++) {
    80002268:	0000f917          	auipc	s2,0xf
    8000226c:	d4890913          	addi	s2,s2,-696 # 80010fb0 <proc>
        if(p->state == RUNNABLE) {
    80002270:	4b0d                	li	s6,3
    80002272:	a821                	j	8000228a <scheduler+0x154>
            release(&p->lock);
    80002274:	854a                	mv	a0,s2
    80002276:	a17fe0ef          	jal	80000c8c <release>
    8000227a:	a021                	j	80002282 <scheduler+0x14c>
          release(&p->lock);
    8000227c:	854a                	mv	a0,s2
    8000227e:	a0ffe0ef          	jal	80000c8c <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80002282:	19090913          	addi	s2,s2,400
    80002286:	02990863          	beq	s2,s1,800022b6 <scheduler+0x180>
        acquire(&p->lock);
    8000228a:	854a                	mv	a0,s2
    8000228c:	969fe0ef          	jal	80000bf4 <acquire>
        if(p->state == RUNNABLE) {
    80002290:	01892783          	lw	a5,24(s2)
    80002294:	ff6794e3          	bne	a5,s6,8000227c <scheduler+0x146>
          if (chosen == 0 || p->priority < chosen->priority) {
    80002298:	000a8d63          	beqz	s5,800022b2 <scheduler+0x17c>
    8000229c:	16c92703          	lw	a4,364(s2)
    800022a0:	16caa783          	lw	a5,364(s5)
    800022a4:	fcf758e3          	bge	a4,a5,80002274 <scheduler+0x13e>
            if (chosen) release(&chosen->lock);
    800022a8:	8556                	mv	a0,s5
    800022aa:	9e3fe0ef          	jal	80000c8c <release>
            chosen = p;
    800022ae:	8aca                	mv	s5,s2
    800022b0:	bfc9                	j	80002282 <scheduler+0x14c>
    800022b2:	8aca                	mv	s5,s2
    800022b4:	b7f9                	j	80002282 <scheduler+0x14c>
      if (chosen) {
    800022b6:	020a8b63          	beqz	s5,800022ec <scheduler+0x1b6>
        chosen->run_start_time = ticks;
    800022ba:	000a2783          	lw	a5,0(s4)
    800022be:	18faa423          	sw	a5,392(s5)
        chosen->waiting_time = chosen->run_start_time - chosen->ready_time;
    800022c2:	184aa703          	lw	a4,388(s5)
    800022c6:	9f99                	subw	a5,a5,a4
    800022c8:	18faa623          	sw	a5,396(s5)
        chosen->state = RUNNING;
    800022cc:	4791                	li	a5,4
    800022ce:	00faac23          	sw	a5,24(s5)
        c->proc = chosen;
    800022d2:	0359b823          	sd	s5,48(s3)
        swtch(&c->context, &chosen->context);
    800022d6:	060a8593          	addi	a1,s5,96
    800022da:	8566                	mv	a0,s9
    800022dc:	0fb000ef          	jal	80002bd6 <swtch>
        c->proc = 0;
    800022e0:	0209b823          	sd	zero,48(s3)
        release(&chosen->lock);
    800022e4:	8556                	mv	a0,s5
    800022e6:	9a7fe0ef          	jal	80000c8c <release>
    800022ea:	b72d                	j	80002214 <scheduler+0xde>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022ec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022f0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022f4:	10079073          	csrw	sstatus,a5
        asm volatile("wfi");
    800022f8:	10500073          	wfi
    800022fc:	bf21                	j	80002214 <scheduler+0xde>
            int chosen_rr_den = 1;  // denominator of response ratio
    800022fe:	4d85                	li	s11,1
            int chosen_rr_num = -1; // numerator of response ratio
    80002300:	5d7d                	li	s10,-1
            struct proc *chosen = 0;
    80002302:	4a81                	li	s5,0
            for(p = proc; p < &proc[NPROC]; p++) {
    80002304:	0000f917          	auipc	s2,0xf
    80002308:	cac90913          	addi	s2,s2,-852 # 80010fb0 <proc>
              if(p->state == RUNNABLE) {
    8000230c:	4b0d                	li	s6,3
    8000230e:	a831                	j	8000232a <scheduler+0x1f4>
                int service_time = p->last_runtime > 0 ? p->last_runtime : 1;
    80002310:	4705                	li	a4,1
    80002312:	a80d                	j	80002344 <scheduler+0x20e>
                  release(&p->lock);
    80002314:	854a                	mv	a0,s2
    80002316:	977fe0ef          	jal	80000c8c <release>
    8000231a:	a021                	j	80002322 <scheduler+0x1ec>
                release(&p->lock);
    8000231c:	854a                	mv	a0,s2
    8000231e:	96ffe0ef          	jal	80000c8c <release>
            for(p = proc; p < &proc[NPROC]; p++) {
    80002322:	19090913          	addi	s2,s2,400
    80002326:	04990c63          	beq	s2,s1,8000237e <scheduler+0x248>
              acquire(&p->lock);
    8000232a:	854a                	mv	a0,s2
    8000232c:	8c9fe0ef          	jal	80000bf4 <acquire>
              if(p->state == RUNNABLE) {
    80002330:	01892783          	lw	a5,24(s2)
    80002334:	ff6794e3          	bne	a5,s6,8000231c <scheduler+0x1e6>
                int service_time = p->last_runtime > 0 ? p->last_runtime : 1;
    80002338:	17092783          	lw	a5,368(s2)
    8000233c:	873e                	mv	a4,a5
    8000233e:	2781                	sext.w	a5,a5
    80002340:	fcf058e3          	blez	a5,80002310 <scheduler+0x1da>
    80002344:	00070c1b          	sext.w	s8,a4
                int wait_time = ticks - p->arrival_time;
    80002348:	000a2783          	lw	a5,0(s4)
    8000234c:	16892683          	lw	a3,360(s2)
    80002350:	9f95                	subw	a5,a5,a3
                int rr_num = wait_time + service_time;
    80002352:	9fb9                	addw	a5,a5,a4
    80002354:	00078b9b          	sext.w	s7,a5
                if (chosen == 0 || rr_num * chosen_rr_den > chosen_rr_num * rr_den) {
    80002358:	000a8f63          	beqz	s5,80002376 <scheduler+0x240>
    8000235c:	03b787bb          	mulw	a5,a5,s11
    80002360:	03a7073b          	mulw	a4,a4,s10
    80002364:	faf758e3          	bge	a4,a5,80002314 <scheduler+0x1de>
                  if (chosen) release(&chosen->lock);
    80002368:	8556                	mv	a0,s5
    8000236a:	923fe0ef          	jal	80000c8c <release>
                  chosen_rr_den = rr_den;
    8000236e:	8de2                	mv	s11,s8
                  chosen_rr_num = rr_num;
    80002370:	8d5e                	mv	s10,s7
                  chosen = p;
    80002372:	8aca                	mv	s5,s2
    80002374:	b77d                	j	80002322 <scheduler+0x1ec>
                  chosen_rr_den = rr_den;
    80002376:	8de2                	mv	s11,s8
                  chosen_rr_num = rr_num;
    80002378:	8d5e                	mv	s10,s7
                  chosen = p;
    8000237a:	8aca                	mv	s5,s2
    8000237c:	b75d                	j	80002322 <scheduler+0x1ec>
            if (chosen) {
    8000237e:	040a8b63          	beqz	s5,800023d4 <scheduler+0x29e>
              chosen->run_start_time = ticks;
    80002382:	000a2783          	lw	a5,0(s4)
    80002386:	18faa423          	sw	a5,392(s5)
              chosen->waiting_time = chosen->run_start_time - chosen->ready_time;
    8000238a:	184aa703          	lw	a4,388(s5)
    8000238e:	40e7873b          	subw	a4,a5,a4
    80002392:	18eaa623          	sw	a4,396(s5)
              chosen->runtime_start_ticks = ticks;
    80002396:	16faaa23          	sw	a5,372(s5)
              chosen->state = RUNNING;
    8000239a:	4791                	li	a5,4
    8000239c:	00faac23          	sw	a5,24(s5)
              c->proc = chosen;
    800023a0:	0359b823          	sd	s5,48(s3)
              swtch(&c->context, &chosen->context);
    800023a4:	060a8593          	addi	a1,s5,96
    800023a8:	8566                	mv	a0,s9
    800023aa:	02d000ef          	jal	80002bd6 <swtch>
              c->proc = 0;
    800023ae:	0209b823          	sd	zero,48(s3)
              int delta = ticks - chosen->runtime_start_ticks;
    800023b2:	000a2783          	lw	a5,0(s4)
    800023b6:	174aa703          	lw	a4,372(s5)
    800023ba:	9f99                	subw	a5,a5,a4
              chosen->last_runtime = delta > 0 ? delta : 1;
    800023bc:	0007871b          	sext.w	a4,a5
    800023c0:	00e05863          	blez	a4,800023d0 <scheduler+0x29a>
    800023c4:	16faa823          	sw	a5,368(s5)
              release(&chosen->lock);
    800023c8:	8556                	mv	a0,s5
    800023ca:	8c3fe0ef          	jal	80000c8c <release>
    800023ce:	b599                	j	80002214 <scheduler+0xde>
              chosen->last_runtime = delta > 0 ? delta : 1;
    800023d0:	4785                	li	a5,1
    800023d2:	bfcd                	j	800023c4 <scheduler+0x28e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023d4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800023d8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023dc:	10079073          	csrw	sstatus,a5
              asm volatile("wfi");
    800023e0:	10500073          	wfi
    800023e4:	bd05                	j	80002214 <scheduler+0xde>
        total_qsize += mlfq.qsize[i];
    800023e6:	000de717          	auipc	a4,0xde
    800023ea:	0ca70713          	addi	a4,a4,202 # 800e04b0 <bcache+0x440>
    800023ee:	b9c72683          	lw	a3,-1124(a4)
    800023f2:	b9872783          	lw	a5,-1128(a4)
    800023f6:	9fb5                	addw	a5,a5,a3
    800023f8:	ba072703          	lw	a4,-1120(a4)
      if (total_qsize == 0) {
    800023fc:	9fb9                	addw	a5,a5,a4
    800023fe:	cbb9                	beqz	a5,80002454 <scheduler+0x31e>
      for (int level = 0; level < QUEUE_LEVELS; level++) {
    80002400:	000ded17          	auipc	s10,0xde
    80002404:	c48d0d13          	addi	s10,s10,-952 # 800e0048 <mlfq+0xbb98>
    80002408:	000d2797          	auipc	a5,0xd2
    8000240c:	0c078793          	addi	a5,a5,192 # 800d44c8 <mlfq+0x18>
    80002410:	f8f43423          	sd	a5,-120(s0)
        for (int i = 0; i < mlfq.qsize[level]; i++) {
    80002414:	4d81                	li	s11,0
          if (p->state == RUNNABLE) {
    80002416:	4c0d                	li	s8,3
        for (int i = 0; i < mlfq.qsize[level]; i++) {
    80002418:	8bea                	mv	s7,s10
    8000241a:	000d2783          	lw	a5,0(s10)
    8000241e:	f8843b03          	ld	s6,-120(s0)
    80002422:	4a81                	li	s5,0
    80002424:	0cf04963          	bgtz	a5,800024f6 <scheduler+0x3c0>
      for (int level = 0; level < QUEUE_LEVELS; level++) {
    80002428:	2d85                	addiw	s11,s11,1
    8000242a:	0d11                	addi	s10,s10,4
    8000242c:	6791                	lui	a5,0x4
    8000242e:	e8078793          	addi	a5,a5,-384 # 3e80 <_entry-0x7fffc180>
    80002432:	f8843703          	ld	a4,-120(s0)
    80002436:	97ba                	add	a5,a5,a4
    80002438:	f8f43423          	sd	a5,-120(s0)
    8000243c:	478d                	li	a5,3
    8000243e:	fcfd9de3          	bne	s11,a5,80002418 <scheduler+0x2e2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002442:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002446:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000244a:	10079073          	csrw	sstatus,a5
        asm volatile("wfi");
    8000244e:	10500073          	wfi
    80002452:	b3c9                	j	80002214 <scheduler+0xde>
        acquire(&mlfq.lock);
    80002454:	000d2517          	auipc	a0,0xd2
    80002458:	05c50513          	addi	a0,a0,92 # 800d44b0 <mlfq>
    8000245c:	f98fe0ef          	jal	80000bf4 <acquire>
        for (struct proc *q = proc; q < &proc[NPROC]; q++) {
    80002460:	0000f917          	auipc	s2,0xf
    80002464:	b5090913          	addi	s2,s2,-1200 # 80010fb0 <proc>
          if (q->state == RUNNABLE) {
    80002468:	4a8d                	li	s5,3
    8000246a:	a029                	j	80002474 <scheduler+0x33e>
        for (struct proc *q = proc; q < &proc[NPROC]; q++) {
    8000246c:	19090913          	addi	s2,s2,400
    80002470:	00990c63          	beq	s2,s1,80002488 <scheduler+0x352>
          if (q->state == RUNNABLE) {
    80002474:	01892783          	lw	a5,24(s2)
    80002478:	ff579ae3          	bne	a5,s5,8000246c <scheduler+0x336>
            enqueue_to_mlfq(q);  // 保留原 queue_level
    8000247c:	854a                	mv	a0,s2
    8000247e:	f78ff0ef          	jal	80001bf6 <enqueue_to_mlfq>
            q->time_slice = 0;
    80002482:	16092e23          	sw	zero,380(s2)
    80002486:	b7dd                	j	8000246c <scheduler+0x336>
        release(&mlfq.lock);
    80002488:	000d2517          	auipc	a0,0xd2
    8000248c:	02850513          	addi	a0,a0,40 # 800d44b0 <mlfq>
    80002490:	ffcfe0ef          	jal	80000c8c <release>
    80002494:	b7b5                	j	80002400 <scheduler+0x2ca>
            p->run_start_time = ticks;
    80002496:	000a2783          	lw	a5,0(s4)
    8000249a:	18f92423          	sw	a5,392(s2)
            p->waiting_time = p->run_start_time - p->ready_time;
    8000249e:	18492703          	lw	a4,388(s2)
    800024a2:	9f99                	subw	a5,a5,a4
    800024a4:	18f92623          	sw	a5,396(s2)
            p->state = RUNNING;
    800024a8:	4791                	li	a5,4
    800024aa:	00f92c23          	sw	a5,24(s2)
            c->proc = p;
    800024ae:	0329b823          	sd	s2,48(s3)
            mlfq.queue[level][i] = 0;
    800024b2:	7d000793          	li	a5,2000
    800024b6:	02fd87b3          	mul	a5,s11,a5
    800024ba:	97d6                	add	a5,a5,s5
    800024bc:	0789                	addi	a5,a5,2
    800024be:	078e                	slli	a5,a5,0x3
    800024c0:	000d2717          	auipc	a4,0xd2
    800024c4:	ff070713          	addi	a4,a4,-16 # 800d44b0 <mlfq>
    800024c8:	97ba                	add	a5,a5,a4
    800024ca:	0007b423          	sd	zero,8(a5)
            compact_queue(level);
    800024ce:	856e                	mv	a0,s11
    800024d0:	bdfff0ef          	jal	800020ae <compact_queue>
            swtch(&c->context, &p->context);
    800024d4:	06090593          	addi	a1,s2,96
    800024d8:	8566                	mv	a0,s9
    800024da:	6fc000ef          	jal	80002bd6 <swtch>
            c->proc = 0;
    800024de:	0209b823          	sd	zero,48(s3)
            release(&p->lock); 
    800024e2:	854a                	mv	a0,s2
    800024e4:	fa8fe0ef          	jal	80000c8c <release>
      if (!found) {
    800024e8:	b335                	j	80002214 <scheduler+0xde>
        for (int i = 0; i < mlfq.qsize[level]; i++) {
    800024ea:	2a85                	addiw	s5,s5,1
    800024ec:	0b21                	addi	s6,s6,8
    800024ee:	000ba783          	lw	a5,0(s7) # 1000 <_entry-0x7ffff000>
    800024f2:	f2fadbe3          	bge	s5,a5,80002428 <scheduler+0x2f2>
          p = mlfq.queue[level][i];
    800024f6:	000b3903          	ld	s2,0(s6)
          if (p == 0) continue;
    800024fa:	fe0908e3          	beqz	s2,800024ea <scheduler+0x3b4>
          acquire(&p->lock);
    800024fe:	854a                	mv	a0,s2
    80002500:	ef4fe0ef          	jal	80000bf4 <acquire>
          if (p->state == RUNNABLE) {
    80002504:	01892783          	lw	a5,24(s2)
    80002508:	f98787e3          	beq	a5,s8,80002496 <scheduler+0x360>
          release(&p->lock);
    8000250c:	854a                	mv	a0,s2
    8000250e:	f7efe0ef          	jal	80000c8c <release>
    80002512:	bfe1                	j	800024ea <scheduler+0x3b4>
        release(&p->lock);
    80002514:	854a                	mv	a0,s2
    80002516:	f76fe0ef          	jal	80000c8c <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    8000251a:	19090913          	addi	s2,s2,400
    8000251e:	02990f63          	beq	s2,s1,8000255c <scheduler+0x426>
        acquire(&p->lock);
    80002522:	854a                	mv	a0,s2
    80002524:	ed0fe0ef          	jal	80000bf4 <acquire>
        if(p->state == RUNNABLE) {
    80002528:	01892783          	lw	a5,24(s2)
    8000252c:	ff5794e3          	bne	a5,s5,80002514 <scheduler+0x3de>
          p->run_start_time = ticks;
    80002530:	000a2783          	lw	a5,0(s4)
    80002534:	18f92423          	sw	a5,392(s2)
          p->waiting_time = p->run_start_time - p->ready_time;
    80002538:	18492703          	lw	a4,388(s2)
    8000253c:	9f99                	subw	a5,a5,a4
    8000253e:	18f92623          	sw	a5,396(s2)
          p->state = RUNNING;
    80002542:	01792c23          	sw	s7,24(s2)
          c->proc = p;
    80002546:	0329b823          	sd	s2,48(s3)
          swtch(&c->context, &p->context);
    8000254a:	06090593          	addi	a1,s2,96
    8000254e:	8566                	mv	a0,s9
    80002550:	686000ef          	jal	80002bd6 <swtch>
          c->proc = 0;
    80002554:	0209b823          	sd	zero,48(s3)
          found = 1;
    80002558:	8c5a                	mv	s8,s6
    8000255a:	bf6d                	j	80002514 <scheduler+0x3de>
      if(found == 0) {
    8000255c:	ca0c1ce3          	bnez	s8,80002214 <scheduler+0xde>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002560:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002564:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002568:	10079073          	csrw	sstatus,a5
        asm volatile("wfi");
    8000256c:	10500073          	wfi
    80002570:	b155                	j	80002214 <scheduler+0xde>

0000000080002572 <sched>:
{
    80002572:	7179                	addi	sp,sp,-48
    80002574:	f406                	sd	ra,40(sp)
    80002576:	f022                	sd	s0,32(sp)
    80002578:	ec26                	sd	s1,24(sp)
    8000257a:	e84a                	sd	s2,16(sp)
    8000257c:	e44e                	sd	s3,8(sp)
    8000257e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002580:	bc6ff0ef          	jal	80001946 <myproc>
    80002584:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002586:	e04fe0ef          	jal	80000b8a <holding>
    8000258a:	c92d                	beqz	a0,800025fc <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000258c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000258e:	2781                	sext.w	a5,a5
    80002590:	079e                	slli	a5,a5,0x7
    80002592:	0000e717          	auipc	a4,0xe
    80002596:	5ee70713          	addi	a4,a4,1518 # 80010b80 <pid_lock>
    8000259a:	97ba                	add	a5,a5,a4
    8000259c:	0a87a703          	lw	a4,168(a5)
    800025a0:	4785                	li	a5,1
    800025a2:	06f71363          	bne	a4,a5,80002608 <sched+0x96>
  if(p->state == RUNNING)
    800025a6:	4c98                	lw	a4,24(s1)
    800025a8:	4791                	li	a5,4
    800025aa:	06f70563          	beq	a4,a5,80002614 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025ae:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800025b2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800025b4:	e7b5                	bnez	a5,80002620 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025b6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800025b8:	0000e917          	auipc	s2,0xe
    800025bc:	5c890913          	addi	s2,s2,1480 # 80010b80 <pid_lock>
    800025c0:	2781                	sext.w	a5,a5
    800025c2:	079e                	slli	a5,a5,0x7
    800025c4:	97ca                	add	a5,a5,s2
    800025c6:	0ac7a983          	lw	s3,172(a5)
    800025ca:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800025cc:	2781                	sext.w	a5,a5
    800025ce:	079e                	slli	a5,a5,0x7
    800025d0:	0000e597          	auipc	a1,0xe
    800025d4:	5e858593          	addi	a1,a1,1512 # 80010bb8 <cpus+0x8>
    800025d8:	95be                	add	a1,a1,a5
    800025da:	06048513          	addi	a0,s1,96
    800025de:	5f8000ef          	jal	80002bd6 <swtch>
    800025e2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800025e4:	2781                	sext.w	a5,a5
    800025e6:	079e                	slli	a5,a5,0x7
    800025e8:	993e                	add	s2,s2,a5
    800025ea:	0b392623          	sw	s3,172(s2)
}
    800025ee:	70a2                	ld	ra,40(sp)
    800025f0:	7402                	ld	s0,32(sp)
    800025f2:	64e2                	ld	s1,24(sp)
    800025f4:	6942                	ld	s2,16(sp)
    800025f6:	69a2                	ld	s3,8(sp)
    800025f8:	6145                	addi	sp,sp,48
    800025fa:	8082                	ret
    panic("sched p->lock");
    800025fc:	00006517          	auipc	a0,0x6
    80002600:	c6450513          	addi	a0,a0,-924 # 80008260 <etext+0x260>
    80002604:	990fe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80002608:	00006517          	auipc	a0,0x6
    8000260c:	c6850513          	addi	a0,a0,-920 # 80008270 <etext+0x270>
    80002610:	984fe0ef          	jal	80000794 <panic>
    panic("sched running");
    80002614:	00006517          	auipc	a0,0x6
    80002618:	c6c50513          	addi	a0,a0,-916 # 80008280 <etext+0x280>
    8000261c:	978fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80002620:	00006517          	auipc	a0,0x6
    80002624:	c7050513          	addi	a0,a0,-912 # 80008290 <etext+0x290>
    80002628:	96cfe0ef          	jal	80000794 <panic>

000000008000262c <yield>:
{
    8000262c:	1101                	addi	sp,sp,-32
    8000262e:	ec06                	sd	ra,24(sp)
    80002630:	e822                	sd	s0,16(sp)
    80002632:	e426                	sd	s1,8(sp)
    80002634:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002636:	b10ff0ef          	jal	80001946 <myproc>
    8000263a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000263c:	db8fe0ef          	jal	80000bf4 <acquire>
  int delta = ticks - p->runtime_start_ticks;
    80002640:	00006797          	auipc	a5,0x6
    80002644:	4187a783          	lw	a5,1048(a5) # 80008a58 <ticks>
    80002648:	1744a703          	lw	a4,372(s1)
    8000264c:	9f99                	subw	a5,a5,a4
  p->last_runtime = delta > 0 ? delta : 1;
    8000264e:	0007871b          	sext.w	a4,a5
    80002652:	02e05763          	blez	a4,80002680 <yield+0x54>
    80002656:	16f4a823          	sw	a5,368(s1)
  p->state = RUNNABLE;
    8000265a:	478d                	li	a5,3
    8000265c:	cc9c                	sw	a5,24(s1)
  if (current_policy == SCHED_MLFQ) {
    8000265e:	00006717          	auipc	a4,0x6
    80002662:	3ea72703          	lw	a4,1002(a4) # 80008a48 <current_policy>
    80002666:	4791                	li	a5,4
    80002668:	00f70e63          	beq	a4,a5,80002684 <yield+0x58>
  sched();
    8000266c:	f07ff0ef          	jal	80002572 <sched>
  release(&p->lock);
    80002670:	8526                	mv	a0,s1
    80002672:	e1afe0ef          	jal	80000c8c <release>
}
    80002676:	60e2                	ld	ra,24(sp)
    80002678:	6442                	ld	s0,16(sp)
    8000267a:	64a2                	ld	s1,8(sp)
    8000267c:	6105                	addi	sp,sp,32
    8000267e:	8082                	ret
  p->last_runtime = delta > 0 ? delta : 1;
    80002680:	4785                	li	a5,1
    80002682:	bfd1                	j	80002656 <yield+0x2a>
    acquire(&mlfq.lock);
    80002684:	000d2517          	auipc	a0,0xd2
    80002688:	e2c50513          	addi	a0,a0,-468 # 800d44b0 <mlfq>
    8000268c:	d68fe0ef          	jal	80000bf4 <acquire>
    enqueue_to_mlfq(p);
    80002690:	8526                	mv	a0,s1
    80002692:	d64ff0ef          	jal	80001bf6 <enqueue_to_mlfq>
    release(&mlfq.lock);
    80002696:	000d2517          	auipc	a0,0xd2
    8000269a:	e1a50513          	addi	a0,a0,-486 # 800d44b0 <mlfq>
    8000269e:	deefe0ef          	jal	80000c8c <release>
    800026a2:	b7e9                	j	8000266c <yield+0x40>

00000000800026a4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800026a4:	7179                	addi	sp,sp,-48
    800026a6:	f406                	sd	ra,40(sp)
    800026a8:	f022                	sd	s0,32(sp)
    800026aa:	ec26                	sd	s1,24(sp)
    800026ac:	e84a                	sd	s2,16(sp)
    800026ae:	e44e                	sd	s3,8(sp)
    800026b0:	1800                	addi	s0,sp,48
    800026b2:	89aa                	mv	s3,a0
    800026b4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800026b6:	a90ff0ef          	jal	80001946 <myproc>
    800026ba:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800026bc:	d38fe0ef          	jal	80000bf4 <acquire>
  release(lk);
    800026c0:	854a                	mv	a0,s2
    800026c2:	dcafe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    800026c6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800026ca:	4789                	li	a5,2
    800026cc:	cc9c                	sw	a5,24(s1)

  sched();
    800026ce:	ea5ff0ef          	jal	80002572 <sched>

  // Tidy up.
  p->chan = 0;
    800026d2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800026d6:	8526                	mv	a0,s1
    800026d8:	db4fe0ef          	jal	80000c8c <release>
  acquire(lk);
    800026dc:	854a                	mv	a0,s2
    800026de:	d16fe0ef          	jal	80000bf4 <acquire>
}
    800026e2:	70a2                	ld	ra,40(sp)
    800026e4:	7402                	ld	s0,32(sp)
    800026e6:	64e2                	ld	s1,24(sp)
    800026e8:	6942                	ld	s2,16(sp)
    800026ea:	69a2                	ld	s3,8(sp)
    800026ec:	6145                	addi	sp,sp,48
    800026ee:	8082                	ret

00000000800026f0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800026f0:	711d                	addi	sp,sp,-96
    800026f2:	ec86                	sd	ra,88(sp)
    800026f4:	e8a2                	sd	s0,80(sp)
    800026f6:	e4a6                	sd	s1,72(sp)
    800026f8:	e0ca                	sd	s2,64(sp)
    800026fa:	fc4e                	sd	s3,56(sp)
    800026fc:	f852                	sd	s4,48(sp)
    800026fe:	f456                	sd	s5,40(sp)
    80002700:	f05a                	sd	s6,32(sp)
    80002702:	ec5e                	sd	s7,24(sp)
    80002704:	e862                	sd	s8,16(sp)
    80002706:	e466                	sd	s9,8(sp)
    80002708:	1080                	addi	s0,sp,96
    8000270a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000270c:	0000f497          	auipc	s1,0xf
    80002710:	8a448493          	addi	s1,s1,-1884 # 80010fb0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002714:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002716:	4c0d                	li	s8,3
        p->ready_time = ticks;
    80002718:	00006b97          	auipc	s7,0x6
    8000271c:	340b8b93          	addi	s7,s7,832 # 80008a58 <ticks>
        if (current_policy == SCHED_MLFQ) {
    80002720:	00006b17          	auipc	s6,0x6
    80002724:	328b0b13          	addi	s6,s6,808 # 80008a48 <current_policy>
    80002728:	4a91                	li	s5,4
          acquire(&mlfq.lock);
    8000272a:	000d2c97          	auipc	s9,0xd2
    8000272e:	d86c8c93          	addi	s9,s9,-634 # 800d44b0 <mlfq>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002732:	000d2917          	auipc	s2,0xd2
    80002736:	d7e90913          	addi	s2,s2,-642 # 800d44b0 <mlfq>
    8000273a:	a801                	j	8000274a <wakeup+0x5a>
          enqueue_to_mlfq(p);
          release(&mlfq.lock);
        }
      }
      release(&p->lock);
    8000273c:	8526                	mv	a0,s1
    8000273e:	d4efe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002742:	19048493          	addi	s1,s1,400
    80002746:	05248363          	beq	s1,s2,8000278c <wakeup+0x9c>
    if(p != myproc()){
    8000274a:	9fcff0ef          	jal	80001946 <myproc>
    8000274e:	fea48ae3          	beq	s1,a0,80002742 <wakeup+0x52>
      acquire(&p->lock);
    80002752:	8526                	mv	a0,s1
    80002754:	ca0fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002758:	4c9c                	lw	a5,24(s1)
    8000275a:	ff3791e3          	bne	a5,s3,8000273c <wakeup+0x4c>
    8000275e:	709c                	ld	a5,32(s1)
    80002760:	fd479ee3          	bne	a5,s4,8000273c <wakeup+0x4c>
        p->state = RUNNABLE;
    80002764:	0184ac23          	sw	s8,24(s1)
        p->ready_time = ticks;
    80002768:	000ba783          	lw	a5,0(s7)
    8000276c:	18f4a223          	sw	a5,388(s1)
        if (current_policy == SCHED_MLFQ) {
    80002770:	000b2783          	lw	a5,0(s6)
    80002774:	fd5794e3          	bne	a5,s5,8000273c <wakeup+0x4c>
          acquire(&mlfq.lock);
    80002778:	8566                	mv	a0,s9
    8000277a:	c7afe0ef          	jal	80000bf4 <acquire>
          enqueue_to_mlfq(p);
    8000277e:	8526                	mv	a0,s1
    80002780:	c76ff0ef          	jal	80001bf6 <enqueue_to_mlfq>
          release(&mlfq.lock);
    80002784:	8566                	mv	a0,s9
    80002786:	d06fe0ef          	jal	80000c8c <release>
    8000278a:	bf4d                	j	8000273c <wakeup+0x4c>
    }
  }
}
    8000278c:	60e6                	ld	ra,88(sp)
    8000278e:	6446                	ld	s0,80(sp)
    80002790:	64a6                	ld	s1,72(sp)
    80002792:	6906                	ld	s2,64(sp)
    80002794:	79e2                	ld	s3,56(sp)
    80002796:	7a42                	ld	s4,48(sp)
    80002798:	7aa2                	ld	s5,40(sp)
    8000279a:	7b02                	ld	s6,32(sp)
    8000279c:	6be2                	ld	s7,24(sp)
    8000279e:	6c42                	ld	s8,16(sp)
    800027a0:	6ca2                	ld	s9,8(sp)
    800027a2:	6125                	addi	sp,sp,96
    800027a4:	8082                	ret

00000000800027a6 <reparent>:
{
    800027a6:	7179                	addi	sp,sp,-48
    800027a8:	f406                	sd	ra,40(sp)
    800027aa:	f022                	sd	s0,32(sp)
    800027ac:	ec26                	sd	s1,24(sp)
    800027ae:	e84a                	sd	s2,16(sp)
    800027b0:	e44e                	sd	s3,8(sp)
    800027b2:	e052                	sd	s4,0(sp)
    800027b4:	1800                	addi	s0,sp,48
    800027b6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800027b8:	0000e497          	auipc	s1,0xe
    800027bc:	7f848493          	addi	s1,s1,2040 # 80010fb0 <proc>
      pp->parent = initproc;
    800027c0:	00006a17          	auipc	s4,0x6
    800027c4:	290a0a13          	addi	s4,s4,656 # 80008a50 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800027c8:	000d2997          	auipc	s3,0xd2
    800027cc:	ce898993          	addi	s3,s3,-792 # 800d44b0 <mlfq>
    800027d0:	a029                	j	800027da <reparent+0x34>
    800027d2:	19048493          	addi	s1,s1,400
    800027d6:	01348b63          	beq	s1,s3,800027ec <reparent+0x46>
    if(pp->parent == p){
    800027da:	7c9c                	ld	a5,56(s1)
    800027dc:	ff279be3          	bne	a5,s2,800027d2 <reparent+0x2c>
      pp->parent = initproc;
    800027e0:	000a3503          	ld	a0,0(s4)
    800027e4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800027e6:	f0bff0ef          	jal	800026f0 <wakeup>
    800027ea:	b7e5                	j	800027d2 <reparent+0x2c>
}
    800027ec:	70a2                	ld	ra,40(sp)
    800027ee:	7402                	ld	s0,32(sp)
    800027f0:	64e2                	ld	s1,24(sp)
    800027f2:	6942                	ld	s2,16(sp)
    800027f4:	69a2                	ld	s3,8(sp)
    800027f6:	6a02                	ld	s4,0(sp)
    800027f8:	6145                	addi	sp,sp,48
    800027fa:	8082                	ret

00000000800027fc <exit>:
{
    800027fc:	7179                	addi	sp,sp,-48
    800027fe:	f406                	sd	ra,40(sp)
    80002800:	f022                	sd	s0,32(sp)
    80002802:	ec26                	sd	s1,24(sp)
    80002804:	e84a                	sd	s2,16(sp)
    80002806:	e44e                	sd	s3,8(sp)
    80002808:	e052                	sd	s4,0(sp)
    8000280a:	1800                	addi	s0,sp,48
    8000280c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000280e:	938ff0ef          	jal	80001946 <myproc>
    80002812:	89aa                	mv	s3,a0
  if(p == initproc)
    80002814:	00006797          	auipc	a5,0x6
    80002818:	23c7b783          	ld	a5,572(a5) # 80008a50 <initproc>
    8000281c:	0d050493          	addi	s1,a0,208
    80002820:	15050913          	addi	s2,a0,336
    80002824:	00a79f63          	bne	a5,a0,80002842 <exit+0x46>
    panic("init exiting");
    80002828:	00006517          	auipc	a0,0x6
    8000282c:	a8050513          	addi	a0,a0,-1408 # 800082a8 <etext+0x2a8>
    80002830:	f65fd0ef          	jal	80000794 <panic>
      fileclose(f);
    80002834:	1cc020ef          	jal	80004a00 <fileclose>
      p->ofile[fd] = 0;
    80002838:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000283c:	04a1                	addi	s1,s1,8
    8000283e:	01248563          	beq	s1,s2,80002848 <exit+0x4c>
    if(p->ofile[fd]){
    80002842:	6088                	ld	a0,0(s1)
    80002844:	f965                	bnez	a0,80002834 <exit+0x38>
    80002846:	bfdd                	j	8000283c <exit+0x40>
  begin_op();
    80002848:	59f010ef          	jal	800045e6 <begin_op>
  iput(p->cwd);
    8000284c:	1509b503          	ld	a0,336(s3)
    80002850:	682010ef          	jal	80003ed2 <iput>
  end_op();
    80002854:	5fd010ef          	jal	80004650 <end_op>
  p->cwd = 0;
    80002858:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000285c:	0000e497          	auipc	s1,0xe
    80002860:	33c48493          	addi	s1,s1,828 # 80010b98 <wait_lock>
    80002864:	8526                	mv	a0,s1
    80002866:	b8efe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    8000286a:	854e                	mv	a0,s3
    8000286c:	f3bff0ef          	jal	800027a6 <reparent>
  wakeup(p->parent);
    80002870:	0389b503          	ld	a0,56(s3)
    80002874:	e7dff0ef          	jal	800026f0 <wakeup>
  acquire(&p->lock);
    80002878:	854e                	mv	a0,s3
    8000287a:	b7afe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    8000287e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002882:	4795                	li	a5,5
    80002884:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002888:	8526                	mv	a0,s1
    8000288a:	c02fe0ef          	jal	80000c8c <release>
  sched();
    8000288e:	ce5ff0ef          	jal	80002572 <sched>
  panic("zombie exit");
    80002892:	00006517          	auipc	a0,0x6
    80002896:	a2650513          	addi	a0,a0,-1498 # 800082b8 <etext+0x2b8>
    8000289a:	efbfd0ef          	jal	80000794 <panic>

000000008000289e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000289e:	7179                	addi	sp,sp,-48
    800028a0:	f406                	sd	ra,40(sp)
    800028a2:	f022                	sd	s0,32(sp)
    800028a4:	ec26                	sd	s1,24(sp)
    800028a6:	e84a                	sd	s2,16(sp)
    800028a8:	e44e                	sd	s3,8(sp)
    800028aa:	1800                	addi	s0,sp,48
    800028ac:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800028ae:	0000e497          	auipc	s1,0xe
    800028b2:	70248493          	addi	s1,s1,1794 # 80010fb0 <proc>
    800028b6:	000d2997          	auipc	s3,0xd2
    800028ba:	bfa98993          	addi	s3,s3,-1030 # 800d44b0 <mlfq>
    acquire(&p->lock);
    800028be:	8526                	mv	a0,s1
    800028c0:	b34fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    800028c4:	589c                	lw	a5,48(s1)
    800028c6:	01278b63          	beq	a5,s2,800028dc <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800028ca:	8526                	mv	a0,s1
    800028cc:	bc0fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800028d0:	19048493          	addi	s1,s1,400
    800028d4:	ff3495e3          	bne	s1,s3,800028be <kill+0x20>
  }
  return -1;
    800028d8:	557d                	li	a0,-1
    800028da:	a819                	j	800028f0 <kill+0x52>
      p->killed = 1;
    800028dc:	4785                	li	a5,1
    800028de:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800028e0:	4c98                	lw	a4,24(s1)
    800028e2:	4789                	li	a5,2
    800028e4:	00f70d63          	beq	a4,a5,800028fe <kill+0x60>
      release(&p->lock);
    800028e8:	8526                	mv	a0,s1
    800028ea:	ba2fe0ef          	jal	80000c8c <release>
      return 0;
    800028ee:	4501                	li	a0,0
}
    800028f0:	70a2                	ld	ra,40(sp)
    800028f2:	7402                	ld	s0,32(sp)
    800028f4:	64e2                	ld	s1,24(sp)
    800028f6:	6942                	ld	s2,16(sp)
    800028f8:	69a2                	ld	s3,8(sp)
    800028fa:	6145                	addi	sp,sp,48
    800028fc:	8082                	ret
        p->state = RUNNABLE;
    800028fe:	478d                	li	a5,3
    80002900:	cc9c                	sw	a5,24(s1)
    80002902:	b7dd                	j	800028e8 <kill+0x4a>

0000000080002904 <setkilled>:

void
setkilled(struct proc *p)
{
    80002904:	1101                	addi	sp,sp,-32
    80002906:	ec06                	sd	ra,24(sp)
    80002908:	e822                	sd	s0,16(sp)
    8000290a:	e426                	sd	s1,8(sp)
    8000290c:	1000                	addi	s0,sp,32
    8000290e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002910:	ae4fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    80002914:	4785                	li	a5,1
    80002916:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002918:	8526                	mv	a0,s1
    8000291a:	b72fe0ef          	jal	80000c8c <release>
}
    8000291e:	60e2                	ld	ra,24(sp)
    80002920:	6442                	ld	s0,16(sp)
    80002922:	64a2                	ld	s1,8(sp)
    80002924:	6105                	addi	sp,sp,32
    80002926:	8082                	ret

0000000080002928 <killed>:

int
killed(struct proc *p)
{
    80002928:	1101                	addi	sp,sp,-32
    8000292a:	ec06                	sd	ra,24(sp)
    8000292c:	e822                	sd	s0,16(sp)
    8000292e:	e426                	sd	s1,8(sp)
    80002930:	e04a                	sd	s2,0(sp)
    80002932:	1000                	addi	s0,sp,32
    80002934:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002936:	abefe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    8000293a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000293e:	8526                	mv	a0,s1
    80002940:	b4cfe0ef          	jal	80000c8c <release>
  return k;
}
    80002944:	854a                	mv	a0,s2
    80002946:	60e2                	ld	ra,24(sp)
    80002948:	6442                	ld	s0,16(sp)
    8000294a:	64a2                	ld	s1,8(sp)
    8000294c:	6902                	ld	s2,0(sp)
    8000294e:	6105                	addi	sp,sp,32
    80002950:	8082                	ret

0000000080002952 <wait>:
{
    80002952:	715d                	addi	sp,sp,-80
    80002954:	e486                	sd	ra,72(sp)
    80002956:	e0a2                	sd	s0,64(sp)
    80002958:	fc26                	sd	s1,56(sp)
    8000295a:	f84a                	sd	s2,48(sp)
    8000295c:	f44e                	sd	s3,40(sp)
    8000295e:	f052                	sd	s4,32(sp)
    80002960:	ec56                	sd	s5,24(sp)
    80002962:	e85a                	sd	s6,16(sp)
    80002964:	e45e                	sd	s7,8(sp)
    80002966:	0880                	addi	s0,sp,80
    80002968:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000296a:	fddfe0ef          	jal	80001946 <myproc>
    8000296e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002970:	0000e517          	auipc	a0,0xe
    80002974:	22850513          	addi	a0,a0,552 # 80010b98 <wait_lock>
    80002978:	a7cfe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    8000297c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000297e:	4a15                	li	s4,5
        havekids = 1;
    80002980:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002982:	000d2997          	auipc	s3,0xd2
    80002986:	b2e98993          	addi	s3,s3,-1234 # 800d44b0 <mlfq>
    havekids = 0;
    8000298a:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000298c:	0000e497          	auipc	s1,0xe
    80002990:	62448493          	addi	s1,s1,1572 # 80010fb0 <proc>
    80002994:	a0b5                	j	80002a00 <wait+0xae>
          pid = pp->pid;
    80002996:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000299a:	000b0c63          	beqz	s6,800029b2 <wait+0x60>
    8000299e:	4691                	li	a3,4
    800029a0:	02c48613          	addi	a2,s1,44
    800029a4:	85da                	mv	a1,s6
    800029a6:	05093503          	ld	a0,80(s2)
    800029aa:	ba9fe0ef          	jal	80001552 <copyout>
    800029ae:	02054a63          	bltz	a0,800029e2 <wait+0x90>
          freeproc(pp);
    800029b2:	8526                	mv	a0,s1
    800029b4:	916ff0ef          	jal	80001aca <freeproc>
          release(&pp->lock);
    800029b8:	8526                	mv	a0,s1
    800029ba:	ad2fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    800029be:	0000e517          	auipc	a0,0xe
    800029c2:	1da50513          	addi	a0,a0,474 # 80010b98 <wait_lock>
    800029c6:	ac6fe0ef          	jal	80000c8c <release>
}
    800029ca:	854e                	mv	a0,s3
    800029cc:	60a6                	ld	ra,72(sp)
    800029ce:	6406                	ld	s0,64(sp)
    800029d0:	74e2                	ld	s1,56(sp)
    800029d2:	7942                	ld	s2,48(sp)
    800029d4:	79a2                	ld	s3,40(sp)
    800029d6:	7a02                	ld	s4,32(sp)
    800029d8:	6ae2                	ld	s5,24(sp)
    800029da:	6b42                	ld	s6,16(sp)
    800029dc:	6ba2                	ld	s7,8(sp)
    800029de:	6161                	addi	sp,sp,80
    800029e0:	8082                	ret
            release(&pp->lock);
    800029e2:	8526                	mv	a0,s1
    800029e4:	aa8fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800029e8:	0000e517          	auipc	a0,0xe
    800029ec:	1b050513          	addi	a0,a0,432 # 80010b98 <wait_lock>
    800029f0:	a9cfe0ef          	jal	80000c8c <release>
            return -1;
    800029f4:	59fd                	li	s3,-1
    800029f6:	bfd1                	j	800029ca <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800029f8:	19048493          	addi	s1,s1,400
    800029fc:	03348063          	beq	s1,s3,80002a1c <wait+0xca>
      if(pp->parent == p){
    80002a00:	7c9c                	ld	a5,56(s1)
    80002a02:	ff279be3          	bne	a5,s2,800029f8 <wait+0xa6>
        acquire(&pp->lock);
    80002a06:	8526                	mv	a0,s1
    80002a08:	9ecfe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    80002a0c:	4c9c                	lw	a5,24(s1)
    80002a0e:	f94784e3          	beq	a5,s4,80002996 <wait+0x44>
        release(&pp->lock);
    80002a12:	8526                	mv	a0,s1
    80002a14:	a78fe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002a18:	8756                	mv	a4,s5
    80002a1a:	bff9                	j	800029f8 <wait+0xa6>
    if(!havekids || killed(p)){
    80002a1c:	cf09                	beqz	a4,80002a36 <wait+0xe4>
    80002a1e:	854a                	mv	a0,s2
    80002a20:	f09ff0ef          	jal	80002928 <killed>
    80002a24:	e909                	bnez	a0,80002a36 <wait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a26:	0000e597          	auipc	a1,0xe
    80002a2a:	17258593          	addi	a1,a1,370 # 80010b98 <wait_lock>
    80002a2e:	854a                	mv	a0,s2
    80002a30:	c75ff0ef          	jal	800026a4 <sleep>
    havekids = 0;
    80002a34:	bf99                	j	8000298a <wait+0x38>
      release(&wait_lock);
    80002a36:	0000e517          	auipc	a0,0xe
    80002a3a:	16250513          	addi	a0,a0,354 # 80010b98 <wait_lock>
    80002a3e:	a4efe0ef          	jal	80000c8c <release>
      return -1;
    80002a42:	59fd                	li	s3,-1
    80002a44:	b759                	j	800029ca <wait+0x78>

0000000080002a46 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a46:	7179                	addi	sp,sp,-48
    80002a48:	f406                	sd	ra,40(sp)
    80002a4a:	f022                	sd	s0,32(sp)
    80002a4c:	ec26                	sd	s1,24(sp)
    80002a4e:	e84a                	sd	s2,16(sp)
    80002a50:	e44e                	sd	s3,8(sp)
    80002a52:	e052                	sd	s4,0(sp)
    80002a54:	1800                	addi	s0,sp,48
    80002a56:	84aa                	mv	s1,a0
    80002a58:	892e                	mv	s2,a1
    80002a5a:	89b2                	mv	s3,a2
    80002a5c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a5e:	ee9fe0ef          	jal	80001946 <myproc>
  if(user_dst){
    80002a62:	cc99                	beqz	s1,80002a80 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002a64:	86d2                	mv	a3,s4
    80002a66:	864e                	mv	a2,s3
    80002a68:	85ca                	mv	a1,s2
    80002a6a:	6928                	ld	a0,80(a0)
    80002a6c:	ae7fe0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002a70:	70a2                	ld	ra,40(sp)
    80002a72:	7402                	ld	s0,32(sp)
    80002a74:	64e2                	ld	s1,24(sp)
    80002a76:	6942                	ld	s2,16(sp)
    80002a78:	69a2                	ld	s3,8(sp)
    80002a7a:	6a02                	ld	s4,0(sp)
    80002a7c:	6145                	addi	sp,sp,48
    80002a7e:	8082                	ret
    memmove((char *)dst, src, len);
    80002a80:	000a061b          	sext.w	a2,s4
    80002a84:	85ce                	mv	a1,s3
    80002a86:	854a                	mv	a0,s2
    80002a88:	a9cfe0ef          	jal	80000d24 <memmove>
    return 0;
    80002a8c:	8526                	mv	a0,s1
    80002a8e:	b7cd                	j	80002a70 <either_copyout+0x2a>

0000000080002a90 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a90:	7179                	addi	sp,sp,-48
    80002a92:	f406                	sd	ra,40(sp)
    80002a94:	f022                	sd	s0,32(sp)
    80002a96:	ec26                	sd	s1,24(sp)
    80002a98:	e84a                	sd	s2,16(sp)
    80002a9a:	e44e                	sd	s3,8(sp)
    80002a9c:	e052                	sd	s4,0(sp)
    80002a9e:	1800                	addi	s0,sp,48
    80002aa0:	892a                	mv	s2,a0
    80002aa2:	84ae                	mv	s1,a1
    80002aa4:	89b2                	mv	s3,a2
    80002aa6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002aa8:	e9ffe0ef          	jal	80001946 <myproc>
  if(user_src){
    80002aac:	cc99                	beqz	s1,80002aca <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002aae:	86d2                	mv	a3,s4
    80002ab0:	864e                	mv	a2,s3
    80002ab2:	85ca                	mv	a1,s2
    80002ab4:	6928                	ld	a0,80(a0)
    80002ab6:	b73fe0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002aba:	70a2                	ld	ra,40(sp)
    80002abc:	7402                	ld	s0,32(sp)
    80002abe:	64e2                	ld	s1,24(sp)
    80002ac0:	6942                	ld	s2,16(sp)
    80002ac2:	69a2                	ld	s3,8(sp)
    80002ac4:	6a02                	ld	s4,0(sp)
    80002ac6:	6145                	addi	sp,sp,48
    80002ac8:	8082                	ret
    memmove(dst, (char*)src, len);
    80002aca:	000a061b          	sext.w	a2,s4
    80002ace:	85ce                	mv	a1,s3
    80002ad0:	854a                	mv	a0,s2
    80002ad2:	a52fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002ad6:	8526                	mv	a0,s1
    80002ad8:	b7cd                	j	80002aba <either_copyin+0x2a>

0000000080002ada <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002ada:	715d                	addi	sp,sp,-80
    80002adc:	e486                	sd	ra,72(sp)
    80002ade:	e0a2                	sd	s0,64(sp)
    80002ae0:	fc26                	sd	s1,56(sp)
    80002ae2:	f84a                	sd	s2,48(sp)
    80002ae4:	f44e                	sd	s3,40(sp)
    80002ae6:	f052                	sd	s4,32(sp)
    80002ae8:	ec56                	sd	s5,24(sp)
    80002aea:	e85a                	sd	s6,16(sp)
    80002aec:	e45e                	sd	s7,8(sp)
    80002aee:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002af0:	00005517          	auipc	a0,0x5
    80002af4:	58850513          	addi	a0,a0,1416 # 80008078 <etext+0x78>
    80002af8:	9cbfd0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002afc:	0000e497          	auipc	s1,0xe
    80002b00:	60c48493          	addi	s1,s1,1548 # 80011108 <proc+0x158>
    80002b04:	000d2917          	auipc	s2,0xd2
    80002b08:	b0490913          	addi	s2,s2,-1276 # 800d4608 <mlfq+0x158>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b0c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002b0e:	00005997          	auipc	s3,0x5
    80002b12:	7ba98993          	addi	s3,s3,1978 # 800082c8 <etext+0x2c8>
    printf("%d %s %s", p->pid, state, p->name);
    80002b16:	00005a97          	auipc	s5,0x5
    80002b1a:	7baa8a93          	addi	s5,s5,1978 # 800082d0 <etext+0x2d0>
    printf("\n");
    80002b1e:	00005a17          	auipc	s4,0x5
    80002b22:	55aa0a13          	addi	s4,s4,1370 # 80008078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b26:	00006b97          	auipc	s7,0x6
    80002b2a:	d6ab8b93          	addi	s7,s7,-662 # 80008890 <states.0>
    80002b2e:	a829                	j	80002b48 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002b30:	ed86a583          	lw	a1,-296(a3)
    80002b34:	8556                	mv	a0,s5
    80002b36:	98dfd0ef          	jal	800004c2 <printf>
    printf("\n");
    80002b3a:	8552                	mv	a0,s4
    80002b3c:	987fd0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b40:	19048493          	addi	s1,s1,400
    80002b44:	03248263          	beq	s1,s2,80002b68 <procdump+0x8e>
    if(p->state == UNUSED)
    80002b48:	86a6                	mv	a3,s1
    80002b4a:	ec04a783          	lw	a5,-320(s1)
    80002b4e:	dbed                	beqz	a5,80002b40 <procdump+0x66>
      state = "???";
    80002b50:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b52:	fcfb6fe3          	bltu	s6,a5,80002b30 <procdump+0x56>
    80002b56:	02079713          	slli	a4,a5,0x20
    80002b5a:	01d75793          	srli	a5,a4,0x1d
    80002b5e:	97de                	add	a5,a5,s7
    80002b60:	6390                	ld	a2,0(a5)
    80002b62:	f679                	bnez	a2,80002b30 <procdump+0x56>
      state = "???";
    80002b64:	864e                	mv	a2,s3
    80002b66:	b7e9                	j	80002b30 <procdump+0x56>
  }
}
    80002b68:	60a6                	ld	ra,72(sp)
    80002b6a:	6406                	ld	s0,64(sp)
    80002b6c:	74e2                	ld	s1,56(sp)
    80002b6e:	7942                	ld	s2,48(sp)
    80002b70:	79a2                	ld	s3,40(sp)
    80002b72:	7a02                	ld	s4,32(sp)
    80002b74:	6ae2                	ld	s5,24(sp)
    80002b76:	6b42                	ld	s6,16(sp)
    80002b78:	6ba2                	ld	s7,8(sp)
    80002b7a:	6161                	addi	sp,sp,80
    80002b7c:	8082                	ret

0000000080002b7e <get_waiting_time>:


int
get_waiting_time(int pid)
{
    80002b7e:	7179                	addi	sp,sp,-48
    80002b80:	f406                	sd	ra,40(sp)
    80002b82:	f022                	sd	s0,32(sp)
    80002b84:	ec26                	sd	s1,24(sp)
    80002b86:	e84a                	sd	s2,16(sp)
    80002b88:	e44e                	sd	s3,8(sp)
    80002b8a:	1800                	addi	s0,sp,48
    80002b8c:	892a                	mv	s2,a0
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    80002b8e:	0000e497          	auipc	s1,0xe
    80002b92:	42248493          	addi	s1,s1,1058 # 80010fb0 <proc>
    80002b96:	000d2997          	auipc	s3,0xd2
    80002b9a:	91a98993          	addi	s3,s3,-1766 # 800d44b0 <mlfq>
    acquire(&p->lock);
    80002b9e:	8526                	mv	a0,s1
    80002ba0:	854fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid) {
    80002ba4:	589c                	lw	a5,48(s1)
    80002ba6:	01278b63          	beq	a5,s2,80002bbc <get_waiting_time+0x3e>
      int w = p->waiting_time;
      release(&p->lock);
      return w;
    }
    release(&p->lock);
    80002baa:	8526                	mv	a0,s1
    80002bac:	8e0fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002bb0:	19048493          	addi	s1,s1,400
    80002bb4:	ff3495e3          	bne	s1,s3,80002b9e <get_waiting_time+0x20>
  }
  return -1;
    80002bb8:	597d                	li	s2,-1
    80002bba:	a031                	j	80002bc6 <get_waiting_time+0x48>
      int w = p->waiting_time;
    80002bbc:	18c4a903          	lw	s2,396(s1)
      release(&p->lock);
    80002bc0:	8526                	mv	a0,s1
    80002bc2:	8cafe0ef          	jal	80000c8c <release>
}
    80002bc6:	854a                	mv	a0,s2
    80002bc8:	70a2                	ld	ra,40(sp)
    80002bca:	7402                	ld	s0,32(sp)
    80002bcc:	64e2                	ld	s1,24(sp)
    80002bce:	6942                	ld	s2,16(sp)
    80002bd0:	69a2                	ld	s3,8(sp)
    80002bd2:	6145                	addi	sp,sp,48
    80002bd4:	8082                	ret

0000000080002bd6 <swtch>:
    80002bd6:	00153023          	sd	ra,0(a0)
    80002bda:	00253423          	sd	sp,8(a0)
    80002bde:	e900                	sd	s0,16(a0)
    80002be0:	ed04                	sd	s1,24(a0)
    80002be2:	03253023          	sd	s2,32(a0)
    80002be6:	03353423          	sd	s3,40(a0)
    80002bea:	03453823          	sd	s4,48(a0)
    80002bee:	03553c23          	sd	s5,56(a0)
    80002bf2:	05653023          	sd	s6,64(a0)
    80002bf6:	05753423          	sd	s7,72(a0)
    80002bfa:	05853823          	sd	s8,80(a0)
    80002bfe:	05953c23          	sd	s9,88(a0)
    80002c02:	07a53023          	sd	s10,96(a0)
    80002c06:	07b53423          	sd	s11,104(a0)
    80002c0a:	0005b083          	ld	ra,0(a1)
    80002c0e:	0085b103          	ld	sp,8(a1)
    80002c12:	6980                	ld	s0,16(a1)
    80002c14:	6d84                	ld	s1,24(a1)
    80002c16:	0205b903          	ld	s2,32(a1)
    80002c1a:	0285b983          	ld	s3,40(a1)
    80002c1e:	0305ba03          	ld	s4,48(a1)
    80002c22:	0385ba83          	ld	s5,56(a1)
    80002c26:	0405bb03          	ld	s6,64(a1)
    80002c2a:	0485bb83          	ld	s7,72(a1)
    80002c2e:	0505bc03          	ld	s8,80(a1)
    80002c32:	0585bc83          	ld	s9,88(a1)
    80002c36:	0605bd03          	ld	s10,96(a1)
    80002c3a:	0685bd83          	ld	s11,104(a1)
    80002c3e:	8082                	ret

0000000080002c40 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002c40:	1141                	addi	sp,sp,-16
    80002c42:	e406                	sd	ra,8(sp)
    80002c44:	e022                	sd	s0,0(sp)
    80002c46:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c48:	00005597          	auipc	a1,0x5
    80002c4c:	6c858593          	addi	a1,a1,1736 # 80008310 <etext+0x310>
    80002c50:	000dd517          	auipc	a0,0xdd
    80002c54:	40850513          	addi	a0,a0,1032 # 800e0058 <tickslock>
    80002c58:	f1dfd0ef          	jal	80000b74 <initlock>
}
    80002c5c:	60a2                	ld	ra,8(sp)
    80002c5e:	6402                	ld	s0,0(sp)
    80002c60:	0141                	addi	sp,sp,16
    80002c62:	8082                	ret

0000000080002c64 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002c64:	1141                	addi	sp,sp,-16
    80002c66:	e422                	sd	s0,8(sp)
    80002c68:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c6a:	00003797          	auipc	a5,0x3
    80002c6e:	10678793          	addi	a5,a5,262 # 80005d70 <kernelvec>
    80002c72:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002c76:	6422                	ld	s0,8(sp)
    80002c78:	0141                	addi	sp,sp,16
    80002c7a:	8082                	ret

0000000080002c7c <usertrapret>:
}

// return to user space
void
usertrapret(void)
{
    80002c7c:	1141                	addi	sp,sp,-16
    80002c7e:	e406                	sd	ra,8(sp)
    80002c80:	e022                	sd	s0,0(sp)
    80002c82:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002c84:	cc3fe0ef          	jal	80001946 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c88:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002c8c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c8e:	10079073          	csrw	sstatus,a5

  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002c92:	00004697          	auipc	a3,0x4
    80002c96:	36e68693          	addi	a3,a3,878 # 80007000 <_trampoline>
    80002c9a:	00004717          	auipc	a4,0x4
    80002c9e:	36670713          	addi	a4,a4,870 # 80007000 <_trampoline>
    80002ca2:	8f15                	sub	a4,a4,a3
    80002ca4:	040007b7          	lui	a5,0x4000
    80002ca8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002caa:	07b2                	slli	a5,a5,0xc
    80002cac:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cae:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  p->trapframe->kernel_satp = r_satp();
    80002cb2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002cb4:	18002673          	csrr	a2,satp
    80002cb8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE;
    80002cba:	6d30                	ld	a2,88(a0)
    80002cbc:	6138                	ld	a4,64(a0)
    80002cbe:	6585                	lui	a1,0x1
    80002cc0:	972e                	add	a4,a4,a1
    80002cc2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002cc4:	6d38                	ld	a4,88(a0)
    80002cc6:	00000617          	auipc	a2,0x0
    80002cca:	11060613          	addi	a2,a2,272 # 80002dd6 <usertrap>
    80002cce:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();
    80002cd0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002cd2:	8612                	mv	a2,tp
    80002cd4:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cd6:	10002773          	csrr	a4,sstatus

  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002cda:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002cde:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ce2:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  w_sepc(p->trapframe->epc);
    80002ce6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ce8:	6f18                	ld	a4,24(a4)
    80002cea:	14171073          	csrw	sepc,a4

  uint64 satp = MAKE_SATP(p->pagetable);
    80002cee:	6928                	ld	a0,80(a0)
    80002cf0:	8131                	srli	a0,a0,0xc

  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002cf2:	00004717          	auipc	a4,0x4
    80002cf6:	3aa70713          	addi	a4,a4,938 # 8000709c <userret>
    80002cfa:	8f15                	sub	a4,a4,a3
    80002cfc:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002cfe:	577d                	li	a4,-1
    80002d00:	177e                	slli	a4,a4,0x3f
    80002d02:	8d59                	or	a0,a0,a4
    80002d04:	9782                	jalr	a5
}
    80002d06:	60a2                	ld	ra,8(sp)
    80002d08:	6402                	ld	s0,0(sp)
    80002d0a:	0141                	addi	sp,sp,16
    80002d0c:	8082                	ret

0000000080002d0e <clockintr>:
}

// clock interrupt handler
void
clockintr(void)
{
    80002d0e:	1101                	addi	sp,sp,-32
    80002d10:	ec06                	sd	ra,24(sp)
    80002d12:	e822                	sd	s0,16(sp)
    80002d14:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002d16:	c05fe0ef          	jal	8000191a <cpuid>
    80002d1a:	cd11                	beqz	a0,80002d36 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002d1c:	c01027f3          	rdtime	a5
    wakeup(&ticks);
    release(&tickslock);
  }

  // ask for the next timer interrupt (tick interval)
  w_stimecmp(r_time() + 1000000);
    80002d20:	000f4737          	lui	a4,0xf4
    80002d24:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002d28:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002d2a:	14d79073          	csrw	stimecmp,a5
}
    80002d2e:	60e2                	ld	ra,24(sp)
    80002d30:	6442                	ld	s0,16(sp)
    80002d32:	6105                	addi	sp,sp,32
    80002d34:	8082                	ret
    80002d36:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002d38:	000dd497          	auipc	s1,0xdd
    80002d3c:	32048493          	addi	s1,s1,800 # 800e0058 <tickslock>
    80002d40:	8526                	mv	a0,s1
    80002d42:	eb3fd0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002d46:	00006517          	auipc	a0,0x6
    80002d4a:	d1250513          	addi	a0,a0,-750 # 80008a58 <ticks>
    80002d4e:	411c                	lw	a5,0(a0)
    80002d50:	2785                	addiw	a5,a5,1
    80002d52:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002d54:	99dff0ef          	jal	800026f0 <wakeup>
    release(&tickslock);
    80002d58:	8526                	mv	a0,s1
    80002d5a:	f33fd0ef          	jal	80000c8c <release>
    80002d5e:	64a2                	ld	s1,8(sp)
    80002d60:	bf75                	j	80002d1c <clockintr+0xe>

0000000080002d62 <devintr>:

// device interrupt
int
devintr(void)
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d6a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002d6e:	57fd                	li	a5,-1
    80002d70:	17fe                	slli	a5,a5,0x3f
    80002d72:	07a5                	addi	a5,a5,9
    80002d74:	00f70c63          	beq	a4,a5,80002d8c <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    }
    if(irq)
      plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000005L){
    80002d78:	57fd                	li	a5,-1
    80002d7a:	17fe                	slli	a5,a5,0x3f
    80002d7c:	0795                	addi	a5,a5,5
    clockintr();
    return 2;
  } else {
    return 0;
    80002d7e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002d80:	04f70763          	beq	a4,a5,80002dce <devintr+0x6c>
  }
}
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	6105                	addi	sp,sp,32
    80002d8a:	8082                	ret
    80002d8c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002d8e:	08e030ef          	jal	80005e1c <plic_claim>
    80002d92:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002d94:	47a9                	li	a5,10
    80002d96:	00f50963          	beq	a0,a5,80002da8 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002d9a:	4785                	li	a5,1
    80002d9c:	00f50963          	beq	a0,a5,80002dae <devintr+0x4c>
    return 1;
    80002da0:	4505                	li	a0,1
    } else if(irq){
    80002da2:	e889                	bnez	s1,80002db4 <devintr+0x52>
    80002da4:	64a2                	ld	s1,8(sp)
    80002da6:	bff9                	j	80002d84 <devintr+0x22>
      uartintr();
    80002da8:	c5ffd0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002dac:	a819                	j	80002dc2 <devintr+0x60>
      virtio_disk_intr();
    80002dae:	534030ef          	jal	800062e2 <virtio_disk_intr>
    if(irq)
    80002db2:	a801                	j	80002dc2 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002db4:	85a6                	mv	a1,s1
    80002db6:	00005517          	auipc	a0,0x5
    80002dba:	56250513          	addi	a0,a0,1378 # 80008318 <etext+0x318>
    80002dbe:	f04fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    80002dc2:	8526                	mv	a0,s1
    80002dc4:	078030ef          	jal	80005e3c <plic_complete>
    return 1;
    80002dc8:	4505                	li	a0,1
    80002dca:	64a2                	ld	s1,8(sp)
    80002dcc:	bf65                	j	80002d84 <devintr+0x22>
    clockintr();
    80002dce:	f41ff0ef          	jal	80002d0e <clockintr>
    return 2;
    80002dd2:	4509                	li	a0,2
    80002dd4:	bf45                	j	80002d84 <devintr+0x22>

0000000080002dd6 <usertrap>:
{
    80002dd6:	7179                	addi	sp,sp,-48
    80002dd8:	f406                	sd	ra,40(sp)
    80002dda:	f022                	sd	s0,32(sp)
    80002ddc:	ec26                	sd	s1,24(sp)
    80002dde:	e84a                	sd	s2,16(sp)
    80002de0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002de2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002de6:	1007f793          	andi	a5,a5,256
    80002dea:	ef85                	bnez	a5,80002e22 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002dec:	00003797          	auipc	a5,0x3
    80002df0:	f8478793          	addi	a5,a5,-124 # 80005d70 <kernelvec>
    80002df4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002df8:	b4ffe0ef          	jal	80001946 <myproc>
    80002dfc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002dfe:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e00:	14102773          	csrr	a4,sepc
    80002e04:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e06:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002e0a:	47a1                	li	a5,8
    80002e0c:	02f70163          	beq	a4,a5,80002e2e <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002e10:	f53ff0ef          	jal	80002d62 <devintr>
    80002e14:	892a                	mv	s2,a0
    80002e16:	c939                	beqz	a0,80002e6c <usertrap+0x96>
  if(killed(p))
    80002e18:	8526                	mv	a0,s1
    80002e1a:	b0fff0ef          	jal	80002928 <killed>
    80002e1e:	cd39                	beqz	a0,80002e7c <usertrap+0xa6>
    80002e20:	a899                	j	80002e76 <usertrap+0xa0>
    panic("usertrap: not from user mode");
    80002e22:	00005517          	auipc	a0,0x5
    80002e26:	51650513          	addi	a0,a0,1302 # 80008338 <etext+0x338>
    80002e2a:	96bfd0ef          	jal	80000794 <panic>
    if(killed(p))
    80002e2e:	afbff0ef          	jal	80002928 <killed>
    80002e32:	e90d                	bnez	a0,80002e64 <usertrap+0x8e>
    p->trapframe->epc += 4;
    80002e34:	6cb8                	ld	a4,88(s1)
    80002e36:	6f1c                	ld	a5,24(a4)
    80002e38:	0791                	addi	a5,a5,4
    80002e3a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e3c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002e40:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e44:	10079073          	csrw	sstatus,a5
    syscall();
    80002e48:	2de000ef          	jal	80003126 <syscall>
  if(killed(p))
    80002e4c:	8526                	mv	a0,s1
    80002e4e:	adbff0ef          	jal	80002928 <killed>
    80002e52:	e10d                	bnez	a0,80002e74 <usertrap+0x9e>
  usertrapret();
    80002e54:	e29ff0ef          	jal	80002c7c <usertrapret>
}
    80002e58:	70a2                	ld	ra,40(sp)
    80002e5a:	7402                	ld	s0,32(sp)
    80002e5c:	64e2                	ld	s1,24(sp)
    80002e5e:	6942                	ld	s2,16(sp)
    80002e60:	6145                	addi	sp,sp,48
    80002e62:	8082                	ret
      exit(-1);
    80002e64:	557d                	li	a0,-1
    80002e66:	997ff0ef          	jal	800027fc <exit>
    80002e6a:	b7e9                	j	80002e34 <usertrap+0x5e>
    setkilled(p);
    80002e6c:	8526                	mv	a0,s1
    80002e6e:	a97ff0ef          	jal	80002904 <setkilled>
    80002e72:	bfe9                	j	80002e4c <usertrap+0x76>
  if(killed(p))
    80002e74:	4901                	li	s2,0
    exit(-1);
    80002e76:	557d                	li	a0,-1
    80002e78:	985ff0ef          	jal	800027fc <exit>
  if (which_dev == 2) {
    80002e7c:	4789                	li	a5,2
    80002e7e:	fcf91be3          	bne	s2,a5,80002e54 <usertrap+0x7e>
    if (p && p->state == RUNNING) {
    80002e82:	4c98                	lw	a4,24(s1)
    80002e84:	4791                	li	a5,4
    80002e86:	06f70a63          	beq	a4,a5,80002efa <usertrap+0x124>
    if (current_policy == 0 && p && p->state == RUNNING) {
    80002e8a:	00006797          	auipc	a5,0x6
    80002e8e:	bbe7a783          	lw	a5,-1090(a5) # 80008a48 <current_policy>
    80002e92:	d3e9                	beqz	a5,80002e54 <usertrap+0x7e>
    } else if (current_policy == 4 && p && p->state == RUNNING) {
    80002e94:	4691                	li	a3,4
    80002e96:	fad79fe3          	bne	a5,a3,80002e54 <usertrap+0x7e>
    80002e9a:	4791                	li	a5,4
    80002e9c:	faf71ce3          	bne	a4,a5,80002e54 <usertrap+0x7e>
      p->time_slice++;
    80002ea0:	17c4a783          	lw	a5,380(s1)
    80002ea4:	2785                	addiw	a5,a5,1
    80002ea6:	0007871b          	sext.w	a4,a5
    80002eaa:	16f4ae23          	sw	a5,380(s1)
      int max_ticks[] = {5, 10, 20}; // MLFQ各层最大时间片
    80002eae:	4795                	li	a5,5
    80002eb0:	fcf42823          	sw	a5,-48(s0)
    80002eb4:	47a9                	li	a5,10
    80002eb6:	fcf42a23          	sw	a5,-44(s0)
    80002eba:	47d1                	li	a5,20
    80002ebc:	fcf42c23          	sw	a5,-40(s0)
      if (p->time_slice >= max_ticks[p->queue_level]) {
    80002ec0:	1784a683          	lw	a3,376(s1)
    80002ec4:	00269793          	slli	a5,a3,0x2
    80002ec8:	1781                	addi	a5,a5,-32
    80002eca:	97a2                	add	a5,a5,s0
    80002ecc:	ff07a783          	lw	a5,-16(a5)
    80002ed0:	f8f742e3          	blt	a4,a5,80002e54 <usertrap+0x7e>
        if (p->queue_level < QUEUE_LEVELS - 1) {
    80002ed4:	4785                	li	a5,1
    80002ed6:	02d7df63          	bge	a5,a3,80002f14 <usertrap+0x13e>
          printf("PID=%d reached time slice limit at tick=%d (already at lowest level %d)\n",
    80002eda:	00006617          	auipc	a2,0x6
    80002ede:	b7e62603          	lw	a2,-1154(a2) # 80008a58 <ticks>
    80002ee2:	588c                	lw	a1,48(s1)
    80002ee4:	00005517          	auipc	a0,0x5
    80002ee8:	4bc50513          	addi	a0,a0,1212 # 800083a0 <etext+0x3a0>
    80002eec:	dd6fd0ef          	jal	800004c2 <printf>
        p->time_slice = 0;
    80002ef0:	1604ae23          	sw	zero,380(s1)
        yield();
    80002ef4:	f38ff0ef          	jal	8000262c <yield>
    80002ef8:	bfb1                	j	80002e54 <usertrap+0x7e>
      p->total_ticks++;
    80002efa:	1804a783          	lw	a5,384(s1)
    80002efe:	2785                	addiw	a5,a5,1
    80002f00:	18f4a023          	sw	a5,384(s1)
    if (current_policy == 0 && p && p->state == RUNNING) {
    80002f04:	00006797          	auipc	a5,0x6
    80002f08:	b447a783          	lw	a5,-1212(a5) # 80008a48 <current_policy>
    80002f0c:	f7c1                	bnez	a5,80002e94 <usertrap+0xbe>
      yield();
    80002f0e:	f1eff0ef          	jal	8000262c <yield>
    80002f12:	b789                	j	80002e54 <usertrap+0x7e>
          printf("PID=%d exceeded time slice at tick=%d, demoting from level %d to %d\n",
    80002f14:	0016871b          	addiw	a4,a3,1
    80002f18:	00006617          	auipc	a2,0x6
    80002f1c:	b4062603          	lw	a2,-1216(a2) # 80008a58 <ticks>
    80002f20:	588c                	lw	a1,48(s1)
    80002f22:	00005517          	auipc	a0,0x5
    80002f26:	43650513          	addi	a0,a0,1078 # 80008358 <etext+0x358>
    80002f2a:	d98fd0ef          	jal	800004c2 <printf>
          p->queue_level++; // 降级
    80002f2e:	1784a783          	lw	a5,376(s1)
    80002f32:	2785                	addiw	a5,a5,1
    80002f34:	16f4ac23          	sw	a5,376(s1)
    80002f38:	bf65                	j	80002ef0 <usertrap+0x11a>

0000000080002f3a <kerneltrap>:
{
    80002f3a:	7179                	addi	sp,sp,-48
    80002f3c:	f406                	sd	ra,40(sp)
    80002f3e:	f022                	sd	s0,32(sp)
    80002f40:	ec26                	sd	s1,24(sp)
    80002f42:	e84a                	sd	s2,16(sp)
    80002f44:	e44e                	sd	s3,8(sp)
    80002f46:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f48:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f4c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f50:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002f54:	1004f793          	andi	a5,s1,256
    80002f58:	c795                	beqz	a5,80002f84 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f5a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002f5e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002f60:	eb85                	bnez	a5,80002f90 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002f62:	e01ff0ef          	jal	80002d62 <devintr>
    80002f66:	c91d                	beqz	a0,80002f9c <kerneltrap+0x62>
  if (which_dev == 2 && myproc() != 0) {
    80002f68:	4789                	li	a5,2
    80002f6a:	04f50963          	beq	a0,a5,80002fbc <kerneltrap+0x82>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f6e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f72:	10049073          	csrw	sstatus,s1
}
    80002f76:	70a2                	ld	ra,40(sp)
    80002f78:	7402                	ld	s0,32(sp)
    80002f7a:	64e2                	ld	s1,24(sp)
    80002f7c:	6942                	ld	s2,16(sp)
    80002f7e:	69a2                	ld	s3,8(sp)
    80002f80:	6145                	addi	sp,sp,48
    80002f82:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002f84:	00005517          	auipc	a0,0x5
    80002f88:	46c50513          	addi	a0,a0,1132 # 800083f0 <etext+0x3f0>
    80002f8c:	809fd0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002f90:	00005517          	auipc	a0,0x5
    80002f94:	48850513          	addi	a0,a0,1160 # 80008418 <etext+0x418>
    80002f98:	ffcfd0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f9c:	143026f3          	csrr	a3,stval
    printf("kerneltrap: unexpected scause 0x%lx sepc=0x%lx stval=0x%lx\n", scause, sepc, r_stval());
    80002fa0:	864a                	mv	a2,s2
    80002fa2:	85ce                	mv	a1,s3
    80002fa4:	00005517          	auipc	a0,0x5
    80002fa8:	49450513          	addi	a0,a0,1172 # 80008438 <etext+0x438>
    80002fac:	d16fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002fb0:	00005517          	auipc	a0,0x5
    80002fb4:	4c850513          	addi	a0,a0,1224 # 80008478 <etext+0x478>
    80002fb8:	fdcfd0ef          	jal	80000794 <panic>
  if (which_dev == 2 && myproc() != 0) {
    80002fbc:	98bfe0ef          	jal	80001946 <myproc>
    80002fc0:	d55d                	beqz	a0,80002f6e <kerneltrap+0x34>
    if (current_policy == 0 || current_policy == 4) {
    80002fc2:	00006797          	auipc	a5,0x6
    80002fc6:	a867a783          	lw	a5,-1402(a5) # 80008a48 <current_policy>
    80002fca:	9bed                	andi	a5,a5,-5
    80002fcc:	f3cd                	bnez	a5,80002f6e <kerneltrap+0x34>
      yield();
    80002fce:	e5eff0ef          	jal	8000262c <yield>
    80002fd2:	bf71                	j	80002f6e <kerneltrap+0x34>

0000000080002fd4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002fd4:	1101                	addi	sp,sp,-32
    80002fd6:	ec06                	sd	ra,24(sp)
    80002fd8:	e822                	sd	s0,16(sp)
    80002fda:	e426                	sd	s1,8(sp)
    80002fdc:	1000                	addi	s0,sp,32
    80002fde:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002fe0:	967fe0ef          	jal	80001946 <myproc>
  switch (n) {
    80002fe4:	4795                	li	a5,5
    80002fe6:	0497e163          	bltu	a5,s1,80003028 <argraw+0x54>
    80002fea:	048a                	slli	s1,s1,0x2
    80002fec:	00006717          	auipc	a4,0x6
    80002ff0:	8d470713          	addi	a4,a4,-1836 # 800088c0 <states.0+0x30>
    80002ff4:	94ba                	add	s1,s1,a4
    80002ff6:	409c                	lw	a5,0(s1)
    80002ff8:	97ba                	add	a5,a5,a4
    80002ffa:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ffc:	6d3c                	ld	a5,88(a0)
    80002ffe:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003000:	60e2                	ld	ra,24(sp)
    80003002:	6442                	ld	s0,16(sp)
    80003004:	64a2                	ld	s1,8(sp)
    80003006:	6105                	addi	sp,sp,32
    80003008:	8082                	ret
    return p->trapframe->a1;
    8000300a:	6d3c                	ld	a5,88(a0)
    8000300c:	7fa8                	ld	a0,120(a5)
    8000300e:	bfcd                	j	80003000 <argraw+0x2c>
    return p->trapframe->a2;
    80003010:	6d3c                	ld	a5,88(a0)
    80003012:	63c8                	ld	a0,128(a5)
    80003014:	b7f5                	j	80003000 <argraw+0x2c>
    return p->trapframe->a3;
    80003016:	6d3c                	ld	a5,88(a0)
    80003018:	67c8                	ld	a0,136(a5)
    8000301a:	b7dd                	j	80003000 <argraw+0x2c>
    return p->trapframe->a4;
    8000301c:	6d3c                	ld	a5,88(a0)
    8000301e:	6bc8                	ld	a0,144(a5)
    80003020:	b7c5                	j	80003000 <argraw+0x2c>
    return p->trapframe->a5;
    80003022:	6d3c                	ld	a5,88(a0)
    80003024:	6fc8                	ld	a0,152(a5)
    80003026:	bfe9                	j	80003000 <argraw+0x2c>
  panic("argraw");
    80003028:	00005517          	auipc	a0,0x5
    8000302c:	46050513          	addi	a0,a0,1120 # 80008488 <etext+0x488>
    80003030:	f64fd0ef          	jal	80000794 <panic>

0000000080003034 <fetchaddr>:
{
    80003034:	1101                	addi	sp,sp,-32
    80003036:	ec06                	sd	ra,24(sp)
    80003038:	e822                	sd	s0,16(sp)
    8000303a:	e426                	sd	s1,8(sp)
    8000303c:	e04a                	sd	s2,0(sp)
    8000303e:	1000                	addi	s0,sp,32
    80003040:	84aa                	mv	s1,a0
    80003042:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003044:	903fe0ef          	jal	80001946 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003048:	653c                	ld	a5,72(a0)
    8000304a:	02f4f663          	bgeu	s1,a5,80003076 <fetchaddr+0x42>
    8000304e:	00848713          	addi	a4,s1,8
    80003052:	02e7e463          	bltu	a5,a4,8000307a <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003056:	46a1                	li	a3,8
    80003058:	8626                	mv	a2,s1
    8000305a:	85ca                	mv	a1,s2
    8000305c:	6928                	ld	a0,80(a0)
    8000305e:	dcafe0ef          	jal	80001628 <copyin>
    80003062:	00a03533          	snez	a0,a0
    80003066:	40a00533          	neg	a0,a0
}
    8000306a:	60e2                	ld	ra,24(sp)
    8000306c:	6442                	ld	s0,16(sp)
    8000306e:	64a2                	ld	s1,8(sp)
    80003070:	6902                	ld	s2,0(sp)
    80003072:	6105                	addi	sp,sp,32
    80003074:	8082                	ret
    return -1;
    80003076:	557d                	li	a0,-1
    80003078:	bfcd                	j	8000306a <fetchaddr+0x36>
    8000307a:	557d                	li	a0,-1
    8000307c:	b7fd                	j	8000306a <fetchaddr+0x36>

000000008000307e <fetchstr>:
{
    8000307e:	7179                	addi	sp,sp,-48
    80003080:	f406                	sd	ra,40(sp)
    80003082:	f022                	sd	s0,32(sp)
    80003084:	ec26                	sd	s1,24(sp)
    80003086:	e84a                	sd	s2,16(sp)
    80003088:	e44e                	sd	s3,8(sp)
    8000308a:	1800                	addi	s0,sp,48
    8000308c:	892a                	mv	s2,a0
    8000308e:	84ae                	mv	s1,a1
    80003090:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003092:	8b5fe0ef          	jal	80001946 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003096:	86ce                	mv	a3,s3
    80003098:	864a                	mv	a2,s2
    8000309a:	85a6                	mv	a1,s1
    8000309c:	6928                	ld	a0,80(a0)
    8000309e:	e10fe0ef          	jal	800016ae <copyinstr>
    800030a2:	00054c63          	bltz	a0,800030ba <fetchstr+0x3c>
  return strlen(buf);
    800030a6:	8526                	mv	a0,s1
    800030a8:	d91fd0ef          	jal	80000e38 <strlen>
}
    800030ac:	70a2                	ld	ra,40(sp)
    800030ae:	7402                	ld	s0,32(sp)
    800030b0:	64e2                	ld	s1,24(sp)
    800030b2:	6942                	ld	s2,16(sp)
    800030b4:	69a2                	ld	s3,8(sp)
    800030b6:	6145                	addi	sp,sp,48
    800030b8:	8082                	ret
    return -1;
    800030ba:	557d                	li	a0,-1
    800030bc:	bfc5                	j	800030ac <fetchstr+0x2e>

00000000800030be <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800030be:	1101                	addi	sp,sp,-32
    800030c0:	ec06                	sd	ra,24(sp)
    800030c2:	e822                	sd	s0,16(sp)
    800030c4:	e426                	sd	s1,8(sp)
    800030c6:	1000                	addi	s0,sp,32
    800030c8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030ca:	f0bff0ef          	jal	80002fd4 <argraw>
    800030ce:	c088                	sw	a0,0(s1)
}
    800030d0:	60e2                	ld	ra,24(sp)
    800030d2:	6442                	ld	s0,16(sp)
    800030d4:	64a2                	ld	s1,8(sp)
    800030d6:	6105                	addi	sp,sp,32
    800030d8:	8082                	ret

00000000800030da <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800030da:	1101                	addi	sp,sp,-32
    800030dc:	ec06                	sd	ra,24(sp)
    800030de:	e822                	sd	s0,16(sp)
    800030e0:	e426                	sd	s1,8(sp)
    800030e2:	1000                	addi	s0,sp,32
    800030e4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030e6:	eefff0ef          	jal	80002fd4 <argraw>
    800030ea:	e088                	sd	a0,0(s1)
}
    800030ec:	60e2                	ld	ra,24(sp)
    800030ee:	6442                	ld	s0,16(sp)
    800030f0:	64a2                	ld	s1,8(sp)
    800030f2:	6105                	addi	sp,sp,32
    800030f4:	8082                	ret

00000000800030f6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800030f6:	7179                	addi	sp,sp,-48
    800030f8:	f406                	sd	ra,40(sp)
    800030fa:	f022                	sd	s0,32(sp)
    800030fc:	ec26                	sd	s1,24(sp)
    800030fe:	e84a                	sd	s2,16(sp)
    80003100:	1800                	addi	s0,sp,48
    80003102:	84ae                	mv	s1,a1
    80003104:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80003106:	fd840593          	addi	a1,s0,-40
    8000310a:	fd1ff0ef          	jal	800030da <argaddr>
  return fetchstr(addr, buf, max);
    8000310e:	864a                	mv	a2,s2
    80003110:	85a6                	mv	a1,s1
    80003112:	fd843503          	ld	a0,-40(s0)
    80003116:	f69ff0ef          	jal	8000307e <fetchstr>
}
    8000311a:	70a2                	ld	ra,40(sp)
    8000311c:	7402                	ld	s0,32(sp)
    8000311e:	64e2                	ld	s1,24(sp)
    80003120:	6942                	ld	s2,16(sp)
    80003122:	6145                	addi	sp,sp,48
    80003124:	8082                	ret

0000000080003126 <syscall>:

};

void
syscall(void)
{
    80003126:	1101                	addi	sp,sp,-32
    80003128:	ec06                	sd	ra,24(sp)
    8000312a:	e822                	sd	s0,16(sp)
    8000312c:	e426                	sd	s1,8(sp)
    8000312e:	e04a                	sd	s2,0(sp)
    80003130:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003132:	815fe0ef          	jal	80001946 <myproc>
    80003136:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003138:	05853903          	ld	s2,88(a0)
    8000313c:	0a893783          	ld	a5,168(s2)
    80003140:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003144:	37fd                	addiw	a5,a5,-1
    80003146:	4769                	li	a4,26
    80003148:	00f76f63          	bltu	a4,a5,80003166 <syscall+0x40>
    8000314c:	00369713          	slli	a4,a3,0x3
    80003150:	00005797          	auipc	a5,0x5
    80003154:	78878793          	addi	a5,a5,1928 # 800088d8 <syscalls>
    80003158:	97ba                	add	a5,a5,a4
    8000315a:	639c                	ld	a5,0(a5)
    8000315c:	c789                	beqz	a5,80003166 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000315e:	9782                	jalr	a5
    80003160:	06a93823          	sd	a0,112(s2)
    80003164:	a829                	j	8000317e <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003166:	15848613          	addi	a2,s1,344
    8000316a:	588c                	lw	a1,48(s1)
    8000316c:	00005517          	auipc	a0,0x5
    80003170:	32450513          	addi	a0,a0,804 # 80008490 <etext+0x490>
    80003174:	b4efd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003178:	6cbc                	ld	a5,88(s1)
    8000317a:	577d                	li	a4,-1
    8000317c:	fbb8                	sd	a4,112(a5)
  }
}
    8000317e:	60e2                	ld	ra,24(sp)
    80003180:	6442                	ld	s0,16(sp)
    80003182:	64a2                	ld	s1,8(sp)
    80003184:	6902                	ld	s2,0(sp)
    80003186:	6105                	addi	sp,sp,32
    80003188:	8082                	ret

000000008000318a <print_padded>:
extern struct proc proc[NPROC];
extern int fork_with_priority(int priority);
extern int get_waiting_time(int);

void
print_padded(const char *s, int width) {
    8000318a:	7179                	addi	sp,sp,-48
    8000318c:	f406                	sd	ra,40(sp)
    8000318e:	f022                	sd	s0,32(sp)
    80003190:	ec26                	sd	s1,24(sp)
    80003192:	e84a                	sd	s2,16(sp)
    80003194:	1800                	addi	s0,sp,48
    80003196:	84aa                	mv	s1,a0
    80003198:	892e                	mv	s2,a1
  printf("%s", s);
    8000319a:	85aa                	mv	a1,a0
    8000319c:	00005517          	auipc	a0,0x5
    800031a0:	31450513          	addi	a0,a0,788 # 800084b0 <etext+0x4b0>
    800031a4:	b1efd0ef          	jal	800004c2 <printf>
  int len = strlen(s);
    800031a8:	8526                	mv	a0,s1
    800031aa:	c8ffd0ef          	jal	80000e38 <strlen>
  for (int i = len; i < width; i++) {
    800031ae:	01255f63          	bge	a0,s2,800031cc <print_padded+0x42>
    800031b2:	e44e                	sd	s3,8(sp)
    800031b4:	84aa                	mv	s1,a0
    printf(" ");
    800031b6:	00005997          	auipc	s3,0x5
    800031ba:	30298993          	addi	s3,s3,770 # 800084b8 <etext+0x4b8>
    800031be:	854e                	mv	a0,s3
    800031c0:	b02fd0ef          	jal	800004c2 <printf>
  for (int i = len; i < width; i++) {
    800031c4:	2485                	addiw	s1,s1,1
    800031c6:	fe991ce3          	bne	s2,s1,800031be <print_padded+0x34>
    800031ca:	69a2                	ld	s3,8(sp)
  }
}
    800031cc:	70a2                	ld	ra,40(sp)
    800031ce:	7402                	ld	s0,32(sp)
    800031d0:	64e2                	ld	s1,24(sp)
    800031d2:	6942                	ld	s2,16(sp)
    800031d4:	6145                	addi	sp,sp,48
    800031d6:	8082                	ret

00000000800031d8 <sys_get_waiting_time>:

uint64
sys_get_waiting_time(void)
{
    800031d8:	1101                	addi	sp,sp,-32
    800031da:	ec06                	sd	ra,24(sp)
    800031dc:	e822                	sd	s0,16(sp)
    800031de:	1000                	addi	s0,sp,32
  int pid;

  
  argint(0, &pid);
    800031e0:	fec40593          	addi	a1,s0,-20
    800031e4:	4501                	li	a0,0
    800031e6:	ed9ff0ef          	jal	800030be <argint>

  
  return get_waiting_time(pid);
    800031ea:	fec42503          	lw	a0,-20(s0)
    800031ee:	991ff0ef          	jal	80002b7e <get_waiting_time>
}
    800031f2:	60e2                	ld	ra,24(sp)
    800031f4:	6442                	ld	s0,16(sp)
    800031f6:	6105                	addi	sp,sp,32
    800031f8:	8082                	ret

00000000800031fa <sys_yield>:


uint64
sys_yield(void)
{
    800031fa:	1141                	addi	sp,sp,-16
    800031fc:	e406                	sd	ra,8(sp)
    800031fe:	e022                	sd	s0,0(sp)
    80003200:	0800                	addi	s0,sp,16
  yield();
    80003202:	c2aff0ef          	jal	8000262c <yield>
  return 0;
}
    80003206:	4501                	li	a0,0
    80003208:	60a2                	ld	ra,8(sp)
    8000320a:	6402                	ld	s0,0(sp)
    8000320c:	0141                	addi	sp,sp,16
    8000320e:	8082                	ret

0000000080003210 <sys_fork_with_priority>:


uint64
sys_fork_with_priority(void)
{
    80003210:	1101                	addi	sp,sp,-32
    80003212:	ec06                	sd	ra,24(sp)
    80003214:	e822                	sd	s0,16(sp)
    80003216:	1000                	addi	s0,sp,32
  int priority;
  argint(0, &priority);  
    80003218:	fec40593          	addi	a1,s0,-20
    8000321c:	4501                	li	a0,0
    8000321e:	ea1ff0ef          	jal	800030be <argint>
  return fork_with_priority(priority);
    80003222:	fec42503          	lw	a0,-20(s0)
    80003226:	d31fe0ef          	jal	80001f56 <fork_with_priority>
}
    8000322a:	60e2                	ld	ra,24(sp)
    8000322c:	6442                	ld	s0,16(sp)
    8000322e:	6105                	addi	sp,sp,32
    80003230:	8082                	ret

0000000080003232 <sys_top>:


uint64
sys_top(void)
{
    80003232:	711d                	addi	sp,sp,-96
    80003234:	ec86                	sd	ra,88(sp)
    80003236:	e8a2                	sd	s0,80(sp)
    80003238:	e4a6                	sd	s1,72(sp)
    8000323a:	e0ca                	sd	s2,64(sp)
    8000323c:	fc4e                	sd	s3,56(sp)
    8000323e:	f852                	sd	s4,48(sp)
    80003240:	f456                	sd	s5,40(sp)
    80003242:	f05a                	sd	s6,32(sp)
    80003244:	ec5e                	sd	s7,24(sp)
    80003246:	e862                	sd	s8,16(sp)
    80003248:	e466                	sd	s9,8(sp)
    8000324a:	e06a                	sd	s10,0(sp)
    8000324c:	1080                	addi	s0,sp,96
  struct proc *p;
  printf("PID\tSTATE       \tPRIO\ttime\tNAME\n");
    8000324e:	00005517          	auipc	a0,0x5
    80003252:	2aa50513          	addi	a0,a0,682 # 800084f8 <etext+0x4f8>
    80003256:	a6cfd0ef          	jal	800004c2 <printf>

  for(p = proc; p < &proc[NPROC]; p++) {
    8000325a:	0000e497          	auipc	s1,0xe
    8000325e:	d5648493          	addi	s1,s1,-682 # 80010fb0 <proc>
        case ZOMBIE:    state_str = "zombie"; break;
      }

      printf("%d\t", p->pid);
      print_padded(state_str, 12);
      printf("\t%d\t%d\t%s\n",
    80003262:	00005997          	auipc	s3,0x5
    80003266:	28698993          	addi	s3,s3,646 # 800084e8 <etext+0x4e8>
      switch (p->state) {
    8000326a:	00005917          	auipc	s2,0x5
    8000326e:	74e90913          	addi	s2,s2,1870 # 800089b8 <syscalls+0xe0>
    80003272:	00005a17          	auipc	s4,0x5
    80003276:	06ea0a13          	addi	s4,s4,110 # 800082e0 <etext+0x2e0>
        case ZOMBIE:    state_str = "zombie"; break;
    8000327a:	00005c97          	auipc	s9,0x5
    8000327e:	08ec8c93          	addi	s9,s9,142 # 80008308 <etext+0x308>
        case RUNNING:   state_str = "running"; break;
    80003282:	00005c17          	auipc	s8,0x5
    80003286:	25ec0c13          	addi	s8,s8,606 # 800084e0 <etext+0x4e0>
        case RUNNABLE:  state_str = "runnable"; break;
    8000328a:	00005b97          	auipc	s7,0x5
    8000328e:	246b8b93          	addi	s7,s7,582 # 800084d0 <etext+0x4d0>
        case SLEEPING:  state_str = "sleeping"; break;
    80003292:	00005b17          	auipc	s6,0x5
    80003296:	22eb0b13          	addi	s6,s6,558 # 800084c0 <etext+0x4c0>
        case USED:      state_str = "used"; break;
    8000329a:	00005a97          	auipc	s5,0x5
    8000329e:	04ea8a93          	addi	s5,s5,78 # 800082e8 <etext+0x2e8>
    800032a2:	a0bd                	j	80003310 <sys_top+0xde>
      const char *state_str = "???";
    800032a4:	00005d17          	auipc	s10,0x5
    800032a8:	024d0d13          	addi	s10,s10,36 # 800082c8 <etext+0x2c8>
    800032ac:	a821                	j	800032c4 <sys_top+0x92>
        case USED:      state_str = "used"; break;
    800032ae:	8d56                	mv	s10,s5
    800032b0:	a811                	j	800032c4 <sys_top+0x92>
        case SLEEPING:  state_str = "sleeping"; break;
    800032b2:	8d5a                	mv	s10,s6
    800032b4:	a801                	j	800032c4 <sys_top+0x92>
        case RUNNABLE:  state_str = "runnable"; break;
    800032b6:	8d5e                	mv	s10,s7
    800032b8:	a031                	j	800032c4 <sys_top+0x92>
        case RUNNING:   state_str = "running"; break;
    800032ba:	8d62                	mv	s10,s8
    800032bc:	a021                	j	800032c4 <sys_top+0x92>
        case ZOMBIE:    state_str = "zombie"; break;
    800032be:	8d66                	mv	s10,s9
    800032c0:	a011                	j	800032c4 <sys_top+0x92>
      switch (p->state) {
    800032c2:	8d52                	mv	s10,s4
      printf("%d\t", p->pid);
    800032c4:	588c                	lw	a1,48(s1)
    800032c6:	00005517          	auipc	a0,0x5
    800032ca:	25a50513          	addi	a0,a0,602 # 80008520 <etext+0x520>
    800032ce:	9f4fd0ef          	jal	800004c2 <printf>
      print_padded(state_str, 12);
    800032d2:	45b1                	li	a1,12
    800032d4:	856a                	mv	a0,s10
    800032d6:	eb5ff0ef          	jal	8000318a <print_padded>
      printf("\t%d\t%d\t%s\n",
    800032da:	16c4a583          	lw	a1,364(s1)
    800032de:	1684a603          	lw	a2,360(s1)
    800032e2:	1584c783          	lbu	a5,344(s1)
    800032e6:	86ce                	mv	a3,s3
    800032e8:	c399                	beqz	a5,800032ee <sys_top+0xbc>
    800032ea:	15848693          	addi	a3,s1,344
    800032ee:	00005517          	auipc	a0,0x5
    800032f2:	23a50513          	addi	a0,a0,570 # 80008528 <etext+0x528>
    800032f6:	9ccfd0ef          	jal	800004c2 <printf>
             p->priority,
             p->arrival_time,
             p->name[0] ? p->name : "(unnamed)");
    }

    release(&p->lock);
    800032fa:	8526                	mv	a0,s1
    800032fc:	991fd0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80003300:	19048493          	addi	s1,s1,400
    80003304:	000d1797          	auipc	a5,0xd1
    80003308:	1ac78793          	addi	a5,a5,428 # 800d44b0 <mlfq>
    8000330c:	00f48f63          	beq	s1,a5,8000332a <sys_top+0xf8>
    acquire(&p->lock);
    80003310:	8526                	mv	a0,s1
    80003312:	8e3fd0ef          	jal	80000bf4 <acquire>
    if(p->state != UNUSED){
    80003316:	4c9c                	lw	a5,24(s1)
    80003318:	d3ed                	beqz	a5,800032fa <sys_top+0xc8>
      switch (p->state) {
    8000331a:	4715                	li	a4,5
    8000331c:	f8f764e3          	bltu	a4,a5,800032a4 <sys_top+0x72>
    80003320:	078a                	slli	a5,a5,0x2
    80003322:	97ca                	add	a5,a5,s2
    80003324:	439c                	lw	a5,0(a5)
    80003326:	97ca                	add	a5,a5,s2
    80003328:	8782                	jr	a5
  }

  return 0;
}
    8000332a:	4501                	li	a0,0
    8000332c:	60e6                	ld	ra,88(sp)
    8000332e:	6446                	ld	s0,80(sp)
    80003330:	64a6                	ld	s1,72(sp)
    80003332:	6906                	ld	s2,64(sp)
    80003334:	79e2                	ld	s3,56(sp)
    80003336:	7a42                	ld	s4,48(sp)
    80003338:	7aa2                	ld	s5,40(sp)
    8000333a:	7b02                	ld	s6,32(sp)
    8000333c:	6be2                	ld	s7,24(sp)
    8000333e:	6c42                	ld	s8,16(sp)
    80003340:	6ca2                	ld	s9,8(sp)
    80003342:	6d02                	ld	s10,0(sp)
    80003344:	6125                	addi	sp,sp,96
    80003346:	8082                	ret

0000000080003348 <sys_set_priority>:



uint64
sys_set_priority(void)
{
    80003348:	7179                	addi	sp,sp,-48
    8000334a:	f406                	sd	ra,40(sp)
    8000334c:	f022                	sd	s0,32(sp)
    8000334e:	ec26                	sd	s1,24(sp)
    80003350:	e84a                	sd	s2,16(sp)
    80003352:	1800                	addi	s0,sp,48
  int pid, prio;
  argint(0, &pid);
    80003354:	fdc40593          	addi	a1,s0,-36
    80003358:	4501                	li	a0,0
    8000335a:	d65ff0ef          	jal	800030be <argint>
  argint(1, &prio);
    8000335e:	fd840593          	addi	a1,s0,-40
    80003362:	4505                	li	a0,1
    80003364:	d5bff0ef          	jal	800030be <argint>

  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++) {
    80003368:	0000e497          	auipc	s1,0xe
    8000336c:	c4848493          	addi	s1,s1,-952 # 80010fb0 <proc>
    80003370:	000d1917          	auipc	s2,0xd1
    80003374:	14090913          	addi	s2,s2,320 # 800d44b0 <mlfq>
    acquire(&p->lock);
    80003378:	8526                	mv	a0,s1
    8000337a:	87bfd0ef          	jal	80000bf4 <acquire>
    if (p->pid == pid) {
    8000337e:	5898                	lw	a4,48(s1)
    80003380:	fdc42783          	lw	a5,-36(s0)
    80003384:	00f70b63          	beq	a4,a5,8000339a <sys_set_priority+0x52>
      p->priority = prio;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80003388:	8526                	mv	a0,s1
    8000338a:	903fd0ef          	jal	80000c8c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000338e:	19048493          	addi	s1,s1,400
    80003392:	ff2493e3          	bne	s1,s2,80003378 <sys_set_priority+0x30>
  }

  return -1;
    80003396:	557d                	li	a0,-1
    80003398:	a809                	j	800033aa <sys_set_priority+0x62>
      p->priority = prio;
    8000339a:	fd842783          	lw	a5,-40(s0)
    8000339e:	16f4a623          	sw	a5,364(s1)
      release(&p->lock);
    800033a2:	8526                	mv	a0,s1
    800033a4:	8e9fd0ef          	jal	80000c8c <release>
      return 0;
    800033a8:	4501                	li	a0,0
}
    800033aa:	70a2                	ld	ra,40(sp)
    800033ac:	7402                	ld	s0,32(sp)
    800033ae:	64e2                	ld	s1,24(sp)
    800033b0:	6942                	ld	s2,16(sp)
    800033b2:	6145                	addi	sp,sp,48
    800033b4:	8082                	ret

00000000800033b6 <sys_set_sched>:

uint64
sys_set_sched(void)
{
    800033b6:	1101                	addi	sp,sp,-32
    800033b8:	ec06                	sd	ra,24(sp)
    800033ba:	e822                	sd	s0,16(sp)
    800033bc:	1000                	addi	s0,sp,32
  int mode = 0;
    800033be:	fe042623          	sw	zero,-20(s0)
  argint(0, &mode);
    800033c2:	fec40593          	addi	a1,s0,-20
    800033c6:	4501                	li	a0,0
    800033c8:	cf7ff0ef          	jal	800030be <argint>

  if (mode == 0 || mode == 1 || mode == 2 || mode == 3 || mode == 4) {
    800033cc:	fec42783          	lw	a5,-20(s0)
    800033d0:	0007869b          	sext.w	a3,a5
    800033d4:	4711                	li	a4,4
    current_policy = mode;
    return 0;
  }

  return -1;
    800033d6:	557d                	li	a0,-1
  if (mode == 0 || mode == 1 || mode == 2 || mode == 3 || mode == 4) {
    800033d8:	00d77663          	bgeu	a4,a3,800033e4 <sys_set_sched+0x2e>
}
    800033dc:	60e2                	ld	ra,24(sp)
    800033de:	6442                	ld	s0,16(sp)
    800033e0:	6105                	addi	sp,sp,32
    800033e2:	8082                	ret
    current_policy = mode;
    800033e4:	00005717          	auipc	a4,0x5
    800033e8:	66f72223          	sw	a5,1636(a4) # 80008a48 <current_policy>
    return 0;
    800033ec:	4501                	li	a0,0
    800033ee:	b7fd                	j	800033dc <sys_set_sched+0x26>

00000000800033f0 <sys_exit>:

uint64
sys_exit(void)
{
    800033f0:	1101                	addi	sp,sp,-32
    800033f2:	ec06                	sd	ra,24(sp)
    800033f4:	e822                	sd	s0,16(sp)
    800033f6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800033f8:	fec40593          	addi	a1,s0,-20
    800033fc:	4501                	li	a0,0
    800033fe:	cc1ff0ef          	jal	800030be <argint>
  exit(n);
    80003402:	fec42503          	lw	a0,-20(s0)
    80003406:	bf6ff0ef          	jal	800027fc <exit>
  return 0;  // not reached
}
    8000340a:	4501                	li	a0,0
    8000340c:	60e2                	ld	ra,24(sp)
    8000340e:	6442                	ld	s0,16(sp)
    80003410:	6105                	addi	sp,sp,32
    80003412:	8082                	ret

0000000080003414 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003414:	1141                	addi	sp,sp,-16
    80003416:	e406                	sd	ra,8(sp)
    80003418:	e022                	sd	s0,0(sp)
    8000341a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000341c:	d2afe0ef          	jal	80001946 <myproc>
}
    80003420:	5908                	lw	a0,48(a0)
    80003422:	60a2                	ld	ra,8(sp)
    80003424:	6402                	ld	s0,0(sp)
    80003426:	0141                	addi	sp,sp,16
    80003428:	8082                	ret

000000008000342a <sys_fork>:

uint64
sys_fork(void)
{
    8000342a:	1141                	addi	sp,sp,-16
    8000342c:	e406                	sd	ra,8(sp)
    8000342e:	e022                	sd	s0,0(sp)
    80003430:	0800                	addi	s0,sp,16
  return fork();
    80003432:	9c5fe0ef          	jal	80001df6 <fork>
}
    80003436:	60a2                	ld	ra,8(sp)
    80003438:	6402                	ld	s0,0(sp)
    8000343a:	0141                	addi	sp,sp,16
    8000343c:	8082                	ret

000000008000343e <sys_wait>:

uint64
sys_wait(void)
{
    8000343e:	1101                	addi	sp,sp,-32
    80003440:	ec06                	sd	ra,24(sp)
    80003442:	e822                	sd	s0,16(sp)
    80003444:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003446:	fe840593          	addi	a1,s0,-24
    8000344a:	4501                	li	a0,0
    8000344c:	c8fff0ef          	jal	800030da <argaddr>
  return wait(p);
    80003450:	fe843503          	ld	a0,-24(s0)
    80003454:	cfeff0ef          	jal	80002952 <wait>
}
    80003458:	60e2                	ld	ra,24(sp)
    8000345a:	6442                	ld	s0,16(sp)
    8000345c:	6105                	addi	sp,sp,32
    8000345e:	8082                	ret

0000000080003460 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003460:	7179                	addi	sp,sp,-48
    80003462:	f406                	sd	ra,40(sp)
    80003464:	f022                	sd	s0,32(sp)
    80003466:	ec26                	sd	s1,24(sp)
    80003468:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000346a:	fdc40593          	addi	a1,s0,-36
    8000346e:	4501                	li	a0,0
    80003470:	c4fff0ef          	jal	800030be <argint>
  addr = myproc()->sz;
    80003474:	cd2fe0ef          	jal	80001946 <myproc>
    80003478:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000347a:	fdc42503          	lw	a0,-36(s0)
    8000347e:	929fe0ef          	jal	80001da6 <growproc>
    80003482:	00054863          	bltz	a0,80003492 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80003486:	8526                	mv	a0,s1
    80003488:	70a2                	ld	ra,40(sp)
    8000348a:	7402                	ld	s0,32(sp)
    8000348c:	64e2                	ld	s1,24(sp)
    8000348e:	6145                	addi	sp,sp,48
    80003490:	8082                	ret
    return -1;
    80003492:	54fd                	li	s1,-1
    80003494:	bfcd                	j	80003486 <sys_sbrk+0x26>

0000000080003496 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003496:	7139                	addi	sp,sp,-64
    80003498:	fc06                	sd	ra,56(sp)
    8000349a:	f822                	sd	s0,48(sp)
    8000349c:	f04a                	sd	s2,32(sp)
    8000349e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800034a0:	fcc40593          	addi	a1,s0,-52
    800034a4:	4501                	li	a0,0
    800034a6:	c19ff0ef          	jal	800030be <argint>
  if(n < 0)
    800034aa:	fcc42783          	lw	a5,-52(s0)
    800034ae:	0607c763          	bltz	a5,8000351c <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    800034b2:	000dd517          	auipc	a0,0xdd
    800034b6:	ba650513          	addi	a0,a0,-1114 # 800e0058 <tickslock>
    800034ba:	f3afd0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    800034be:	00005917          	auipc	s2,0x5
    800034c2:	59a92903          	lw	s2,1434(s2) # 80008a58 <ticks>
  while(ticks - ticks0 < n){
    800034c6:	fcc42783          	lw	a5,-52(s0)
    800034ca:	cf8d                	beqz	a5,80003504 <sys_sleep+0x6e>
    800034cc:	f426                	sd	s1,40(sp)
    800034ce:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800034d0:	000dd997          	auipc	s3,0xdd
    800034d4:	b8898993          	addi	s3,s3,-1144 # 800e0058 <tickslock>
    800034d8:	00005497          	auipc	s1,0x5
    800034dc:	58048493          	addi	s1,s1,1408 # 80008a58 <ticks>
    if(killed(myproc())){
    800034e0:	c66fe0ef          	jal	80001946 <myproc>
    800034e4:	c44ff0ef          	jal	80002928 <killed>
    800034e8:	ed0d                	bnez	a0,80003522 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    800034ea:	85ce                	mv	a1,s3
    800034ec:	8526                	mv	a0,s1
    800034ee:	9b6ff0ef          	jal	800026a4 <sleep>
  while(ticks - ticks0 < n){
    800034f2:	409c                	lw	a5,0(s1)
    800034f4:	412787bb          	subw	a5,a5,s2
    800034f8:	fcc42703          	lw	a4,-52(s0)
    800034fc:	fee7e2e3          	bltu	a5,a4,800034e0 <sys_sleep+0x4a>
    80003500:	74a2                	ld	s1,40(sp)
    80003502:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003504:	000dd517          	auipc	a0,0xdd
    80003508:	b5450513          	addi	a0,a0,-1196 # 800e0058 <tickslock>
    8000350c:	f80fd0ef          	jal	80000c8c <release>
  return 0;
    80003510:	4501                	li	a0,0
}
    80003512:	70e2                	ld	ra,56(sp)
    80003514:	7442                	ld	s0,48(sp)
    80003516:	7902                	ld	s2,32(sp)
    80003518:	6121                	addi	sp,sp,64
    8000351a:	8082                	ret
    n = 0;
    8000351c:	fc042623          	sw	zero,-52(s0)
    80003520:	bf49                	j	800034b2 <sys_sleep+0x1c>
      release(&tickslock);
    80003522:	000dd517          	auipc	a0,0xdd
    80003526:	b3650513          	addi	a0,a0,-1226 # 800e0058 <tickslock>
    8000352a:	f62fd0ef          	jal	80000c8c <release>
      return -1;
    8000352e:	557d                	li	a0,-1
    80003530:	74a2                	ld	s1,40(sp)
    80003532:	69e2                	ld	s3,24(sp)
    80003534:	bff9                	j	80003512 <sys_sleep+0x7c>

0000000080003536 <sys_kill>:

uint64
sys_kill(void)
{
    80003536:	1101                	addi	sp,sp,-32
    80003538:	ec06                	sd	ra,24(sp)
    8000353a:	e822                	sd	s0,16(sp)
    8000353c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000353e:	fec40593          	addi	a1,s0,-20
    80003542:	4501                	li	a0,0
    80003544:	b7bff0ef          	jal	800030be <argint>
  return kill(pid);
    80003548:	fec42503          	lw	a0,-20(s0)
    8000354c:	b52ff0ef          	jal	8000289e <kill>
}
    80003550:	60e2                	ld	ra,24(sp)
    80003552:	6442                	ld	s0,16(sp)
    80003554:	6105                	addi	sp,sp,32
    80003556:	8082                	ret

0000000080003558 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003558:	1101                	addi	sp,sp,-32
    8000355a:	ec06                	sd	ra,24(sp)
    8000355c:	e822                	sd	s0,16(sp)
    8000355e:	e426                	sd	s1,8(sp)
    80003560:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003562:	000dd517          	auipc	a0,0xdd
    80003566:	af650513          	addi	a0,a0,-1290 # 800e0058 <tickslock>
    8000356a:	e8afd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    8000356e:	00005497          	auipc	s1,0x5
    80003572:	4ea4a483          	lw	s1,1258(s1) # 80008a58 <ticks>
  release(&tickslock);
    80003576:	000dd517          	auipc	a0,0xdd
    8000357a:	ae250513          	addi	a0,a0,-1310 # 800e0058 <tickslock>
    8000357e:	f0efd0ef          	jal	80000c8c <release>
  return xticks;
}
    80003582:	02049513          	slli	a0,s1,0x20
    80003586:	9101                	srli	a0,a0,0x20
    80003588:	60e2                	ld	ra,24(sp)
    8000358a:	6442                	ld	s0,16(sp)
    8000358c:	64a2                	ld	s1,8(sp)
    8000358e:	6105                	addi	sp,sp,32
    80003590:	8082                	ret

0000000080003592 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003592:	7179                	addi	sp,sp,-48
    80003594:	f406                	sd	ra,40(sp)
    80003596:	f022                	sd	s0,32(sp)
    80003598:	ec26                	sd	s1,24(sp)
    8000359a:	e84a                	sd	s2,16(sp)
    8000359c:	e44e                	sd	s3,8(sp)
    8000359e:	e052                	sd	s4,0(sp)
    800035a0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800035a2:	00005597          	auipc	a1,0x5
    800035a6:	f9658593          	addi	a1,a1,-106 # 80008538 <etext+0x538>
    800035aa:	000dd517          	auipc	a0,0xdd
    800035ae:	ac650513          	addi	a0,a0,-1338 # 800e0070 <bcache>
    800035b2:	dc2fd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800035b6:	000e5797          	auipc	a5,0xe5
    800035ba:	aba78793          	addi	a5,a5,-1350 # 800e8070 <bcache+0x8000>
    800035be:	000e5717          	auipc	a4,0xe5
    800035c2:	d1a70713          	addi	a4,a4,-742 # 800e82d8 <bcache+0x8268>
    800035c6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800035ca:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035ce:	000dd497          	auipc	s1,0xdd
    800035d2:	aba48493          	addi	s1,s1,-1350 # 800e0088 <bcache+0x18>
    b->next = bcache.head.next;
    800035d6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800035d8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800035da:	00005a17          	auipc	s4,0x5
    800035de:	f66a0a13          	addi	s4,s4,-154 # 80008540 <etext+0x540>
    b->next = bcache.head.next;
    800035e2:	2b893783          	ld	a5,696(s2)
    800035e6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800035e8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800035ec:	85d2                	mv	a1,s4
    800035ee:	01048513          	addi	a0,s1,16
    800035f2:	248010ef          	jal	8000483a <initsleeplock>
    bcache.head.next->prev = b;
    800035f6:	2b893783          	ld	a5,696(s2)
    800035fa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800035fc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003600:	45848493          	addi	s1,s1,1112
    80003604:	fd349fe3          	bne	s1,s3,800035e2 <binit+0x50>
  }
}
    80003608:	70a2                	ld	ra,40(sp)
    8000360a:	7402                	ld	s0,32(sp)
    8000360c:	64e2                	ld	s1,24(sp)
    8000360e:	6942                	ld	s2,16(sp)
    80003610:	69a2                	ld	s3,8(sp)
    80003612:	6a02                	ld	s4,0(sp)
    80003614:	6145                	addi	sp,sp,48
    80003616:	8082                	ret

0000000080003618 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003618:	7179                	addi	sp,sp,-48
    8000361a:	f406                	sd	ra,40(sp)
    8000361c:	f022                	sd	s0,32(sp)
    8000361e:	ec26                	sd	s1,24(sp)
    80003620:	e84a                	sd	s2,16(sp)
    80003622:	e44e                	sd	s3,8(sp)
    80003624:	1800                	addi	s0,sp,48
    80003626:	892a                	mv	s2,a0
    80003628:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000362a:	000dd517          	auipc	a0,0xdd
    8000362e:	a4650513          	addi	a0,a0,-1466 # 800e0070 <bcache>
    80003632:	dc2fd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003636:	000e5497          	auipc	s1,0xe5
    8000363a:	cf24b483          	ld	s1,-782(s1) # 800e8328 <bcache+0x82b8>
    8000363e:	000e5797          	auipc	a5,0xe5
    80003642:	c9a78793          	addi	a5,a5,-870 # 800e82d8 <bcache+0x8268>
    80003646:	02f48b63          	beq	s1,a5,8000367c <bread+0x64>
    8000364a:	873e                	mv	a4,a5
    8000364c:	a021                	j	80003654 <bread+0x3c>
    8000364e:	68a4                	ld	s1,80(s1)
    80003650:	02e48663          	beq	s1,a4,8000367c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003654:	449c                	lw	a5,8(s1)
    80003656:	ff279ce3          	bne	a5,s2,8000364e <bread+0x36>
    8000365a:	44dc                	lw	a5,12(s1)
    8000365c:	ff3799e3          	bne	a5,s3,8000364e <bread+0x36>
      b->refcnt++;
    80003660:	40bc                	lw	a5,64(s1)
    80003662:	2785                	addiw	a5,a5,1
    80003664:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003666:	000dd517          	auipc	a0,0xdd
    8000366a:	a0a50513          	addi	a0,a0,-1526 # 800e0070 <bcache>
    8000366e:	e1efd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80003672:	01048513          	addi	a0,s1,16
    80003676:	1fa010ef          	jal	80004870 <acquiresleep>
      return b;
    8000367a:	a889                	j	800036cc <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000367c:	000e5497          	auipc	s1,0xe5
    80003680:	ca44b483          	ld	s1,-860(s1) # 800e8320 <bcache+0x82b0>
    80003684:	000e5797          	auipc	a5,0xe5
    80003688:	c5478793          	addi	a5,a5,-940 # 800e82d8 <bcache+0x8268>
    8000368c:	00f48863          	beq	s1,a5,8000369c <bread+0x84>
    80003690:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003692:	40bc                	lw	a5,64(s1)
    80003694:	cb91                	beqz	a5,800036a8 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003696:	64a4                	ld	s1,72(s1)
    80003698:	fee49de3          	bne	s1,a4,80003692 <bread+0x7a>
  panic("bget: no buffers");
    8000369c:	00005517          	auipc	a0,0x5
    800036a0:	eac50513          	addi	a0,a0,-340 # 80008548 <etext+0x548>
    800036a4:	8f0fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    800036a8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800036ac:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800036b0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800036b4:	4785                	li	a5,1
    800036b6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036b8:	000dd517          	auipc	a0,0xdd
    800036bc:	9b850513          	addi	a0,a0,-1608 # 800e0070 <bcache>
    800036c0:	dccfd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    800036c4:	01048513          	addi	a0,s1,16
    800036c8:	1a8010ef          	jal	80004870 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800036cc:	409c                	lw	a5,0(s1)
    800036ce:	cb89                	beqz	a5,800036e0 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800036d0:	8526                	mv	a0,s1
    800036d2:	70a2                	ld	ra,40(sp)
    800036d4:	7402                	ld	s0,32(sp)
    800036d6:	64e2                	ld	s1,24(sp)
    800036d8:	6942                	ld	s2,16(sp)
    800036da:	69a2                	ld	s3,8(sp)
    800036dc:	6145                	addi	sp,sp,48
    800036de:	8082                	ret
    virtio_disk_rw(b, 0);
    800036e0:	4581                	li	a1,0
    800036e2:	8526                	mv	a0,s1
    800036e4:	1ed020ef          	jal	800060d0 <virtio_disk_rw>
    b->valid = 1;
    800036e8:	4785                	li	a5,1
    800036ea:	c09c                	sw	a5,0(s1)
  return b;
    800036ec:	b7d5                	j	800036d0 <bread+0xb8>

00000000800036ee <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800036ee:	1101                	addi	sp,sp,-32
    800036f0:	ec06                	sd	ra,24(sp)
    800036f2:	e822                	sd	s0,16(sp)
    800036f4:	e426                	sd	s1,8(sp)
    800036f6:	1000                	addi	s0,sp,32
    800036f8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036fa:	0541                	addi	a0,a0,16
    800036fc:	1f2010ef          	jal	800048ee <holdingsleep>
    80003700:	c911                	beqz	a0,80003714 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003702:	4585                	li	a1,1
    80003704:	8526                	mv	a0,s1
    80003706:	1cb020ef          	jal	800060d0 <virtio_disk_rw>
}
    8000370a:	60e2                	ld	ra,24(sp)
    8000370c:	6442                	ld	s0,16(sp)
    8000370e:	64a2                	ld	s1,8(sp)
    80003710:	6105                	addi	sp,sp,32
    80003712:	8082                	ret
    panic("bwrite");
    80003714:	00005517          	auipc	a0,0x5
    80003718:	e4c50513          	addi	a0,a0,-436 # 80008560 <etext+0x560>
    8000371c:	878fd0ef          	jal	80000794 <panic>

0000000080003720 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003720:	1101                	addi	sp,sp,-32
    80003722:	ec06                	sd	ra,24(sp)
    80003724:	e822                	sd	s0,16(sp)
    80003726:	e426                	sd	s1,8(sp)
    80003728:	e04a                	sd	s2,0(sp)
    8000372a:	1000                	addi	s0,sp,32
    8000372c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000372e:	01050913          	addi	s2,a0,16
    80003732:	854a                	mv	a0,s2
    80003734:	1ba010ef          	jal	800048ee <holdingsleep>
    80003738:	c135                	beqz	a0,8000379c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    8000373a:	854a                	mv	a0,s2
    8000373c:	17a010ef          	jal	800048b6 <releasesleep>

  acquire(&bcache.lock);
    80003740:	000dd517          	auipc	a0,0xdd
    80003744:	93050513          	addi	a0,a0,-1744 # 800e0070 <bcache>
    80003748:	cacfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    8000374c:	40bc                	lw	a5,64(s1)
    8000374e:	37fd                	addiw	a5,a5,-1
    80003750:	0007871b          	sext.w	a4,a5
    80003754:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003756:	e71d                	bnez	a4,80003784 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003758:	68b8                	ld	a4,80(s1)
    8000375a:	64bc                	ld	a5,72(s1)
    8000375c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000375e:	68b8                	ld	a4,80(s1)
    80003760:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003762:	000e5797          	auipc	a5,0xe5
    80003766:	90e78793          	addi	a5,a5,-1778 # 800e8070 <bcache+0x8000>
    8000376a:	2b87b703          	ld	a4,696(a5)
    8000376e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003770:	000e5717          	auipc	a4,0xe5
    80003774:	b6870713          	addi	a4,a4,-1176 # 800e82d8 <bcache+0x8268>
    80003778:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000377a:	2b87b703          	ld	a4,696(a5)
    8000377e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003780:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003784:	000dd517          	auipc	a0,0xdd
    80003788:	8ec50513          	addi	a0,a0,-1812 # 800e0070 <bcache>
    8000378c:	d00fd0ef          	jal	80000c8c <release>
}
    80003790:	60e2                	ld	ra,24(sp)
    80003792:	6442                	ld	s0,16(sp)
    80003794:	64a2                	ld	s1,8(sp)
    80003796:	6902                	ld	s2,0(sp)
    80003798:	6105                	addi	sp,sp,32
    8000379a:	8082                	ret
    panic("brelse");
    8000379c:	00005517          	auipc	a0,0x5
    800037a0:	dcc50513          	addi	a0,a0,-564 # 80008568 <etext+0x568>
    800037a4:	ff1fc0ef          	jal	80000794 <panic>

00000000800037a8 <bpin>:

void
bpin(struct buf *b) {
    800037a8:	1101                	addi	sp,sp,-32
    800037aa:	ec06                	sd	ra,24(sp)
    800037ac:	e822                	sd	s0,16(sp)
    800037ae:	e426                	sd	s1,8(sp)
    800037b0:	1000                	addi	s0,sp,32
    800037b2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037b4:	000dd517          	auipc	a0,0xdd
    800037b8:	8bc50513          	addi	a0,a0,-1860 # 800e0070 <bcache>
    800037bc:	c38fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    800037c0:	40bc                	lw	a5,64(s1)
    800037c2:	2785                	addiw	a5,a5,1
    800037c4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037c6:	000dd517          	auipc	a0,0xdd
    800037ca:	8aa50513          	addi	a0,a0,-1878 # 800e0070 <bcache>
    800037ce:	cbefd0ef          	jal	80000c8c <release>
}
    800037d2:	60e2                	ld	ra,24(sp)
    800037d4:	6442                	ld	s0,16(sp)
    800037d6:	64a2                	ld	s1,8(sp)
    800037d8:	6105                	addi	sp,sp,32
    800037da:	8082                	ret

00000000800037dc <bunpin>:

void
bunpin(struct buf *b) {
    800037dc:	1101                	addi	sp,sp,-32
    800037de:	ec06                	sd	ra,24(sp)
    800037e0:	e822                	sd	s0,16(sp)
    800037e2:	e426                	sd	s1,8(sp)
    800037e4:	1000                	addi	s0,sp,32
    800037e6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037e8:	000dd517          	auipc	a0,0xdd
    800037ec:	88850513          	addi	a0,a0,-1912 # 800e0070 <bcache>
    800037f0:	c04fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    800037f4:	40bc                	lw	a5,64(s1)
    800037f6:	37fd                	addiw	a5,a5,-1
    800037f8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037fa:	000dd517          	auipc	a0,0xdd
    800037fe:	87650513          	addi	a0,a0,-1930 # 800e0070 <bcache>
    80003802:	c8afd0ef          	jal	80000c8c <release>
}
    80003806:	60e2                	ld	ra,24(sp)
    80003808:	6442                	ld	s0,16(sp)
    8000380a:	64a2                	ld	s1,8(sp)
    8000380c:	6105                	addi	sp,sp,32
    8000380e:	8082                	ret

0000000080003810 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003810:	1101                	addi	sp,sp,-32
    80003812:	ec06                	sd	ra,24(sp)
    80003814:	e822                	sd	s0,16(sp)
    80003816:	e426                	sd	s1,8(sp)
    80003818:	e04a                	sd	s2,0(sp)
    8000381a:	1000                	addi	s0,sp,32
    8000381c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000381e:	00d5d59b          	srliw	a1,a1,0xd
    80003822:	000e5797          	auipc	a5,0xe5
    80003826:	f2a7a783          	lw	a5,-214(a5) # 800e874c <sb+0x1c>
    8000382a:	9dbd                	addw	a1,a1,a5
    8000382c:	dedff0ef          	jal	80003618 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003830:	0074f713          	andi	a4,s1,7
    80003834:	4785                	li	a5,1
    80003836:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000383a:	14ce                	slli	s1,s1,0x33
    8000383c:	90d9                	srli	s1,s1,0x36
    8000383e:	00950733          	add	a4,a0,s1
    80003842:	05874703          	lbu	a4,88(a4)
    80003846:	00e7f6b3          	and	a3,a5,a4
    8000384a:	c29d                	beqz	a3,80003870 <bfree+0x60>
    8000384c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000384e:	94aa                	add	s1,s1,a0
    80003850:	fff7c793          	not	a5,a5
    80003854:	8f7d                	and	a4,a4,a5
    80003856:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000385a:	711000ef          	jal	8000476a <log_write>
  brelse(bp);
    8000385e:	854a                	mv	a0,s2
    80003860:	ec1ff0ef          	jal	80003720 <brelse>
}
    80003864:	60e2                	ld	ra,24(sp)
    80003866:	6442                	ld	s0,16(sp)
    80003868:	64a2                	ld	s1,8(sp)
    8000386a:	6902                	ld	s2,0(sp)
    8000386c:	6105                	addi	sp,sp,32
    8000386e:	8082                	ret
    panic("freeing free block");
    80003870:	00005517          	auipc	a0,0x5
    80003874:	d0050513          	addi	a0,a0,-768 # 80008570 <etext+0x570>
    80003878:	f1dfc0ef          	jal	80000794 <panic>

000000008000387c <balloc>:
{
    8000387c:	711d                	addi	sp,sp,-96
    8000387e:	ec86                	sd	ra,88(sp)
    80003880:	e8a2                	sd	s0,80(sp)
    80003882:	e4a6                	sd	s1,72(sp)
    80003884:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003886:	000e5797          	auipc	a5,0xe5
    8000388a:	eae7a783          	lw	a5,-338(a5) # 800e8734 <sb+0x4>
    8000388e:	0e078f63          	beqz	a5,8000398c <balloc+0x110>
    80003892:	e0ca                	sd	s2,64(sp)
    80003894:	fc4e                	sd	s3,56(sp)
    80003896:	f852                	sd	s4,48(sp)
    80003898:	f456                	sd	s5,40(sp)
    8000389a:	f05a                	sd	s6,32(sp)
    8000389c:	ec5e                	sd	s7,24(sp)
    8000389e:	e862                	sd	s8,16(sp)
    800038a0:	e466                	sd	s9,8(sp)
    800038a2:	8baa                	mv	s7,a0
    800038a4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800038a6:	000e5b17          	auipc	s6,0xe5
    800038aa:	e8ab0b13          	addi	s6,s6,-374 # 800e8730 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038ae:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800038b0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038b2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800038b4:	6c89                	lui	s9,0x2
    800038b6:	a0b5                	j	80003922 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800038b8:	97ca                	add	a5,a5,s2
    800038ba:	8e55                	or	a2,a2,a3
    800038bc:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800038c0:	854a                	mv	a0,s2
    800038c2:	6a9000ef          	jal	8000476a <log_write>
        brelse(bp);
    800038c6:	854a                	mv	a0,s2
    800038c8:	e59ff0ef          	jal	80003720 <brelse>
  bp = bread(dev, bno);
    800038cc:	85a6                	mv	a1,s1
    800038ce:	855e                	mv	a0,s7
    800038d0:	d49ff0ef          	jal	80003618 <bread>
    800038d4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038d6:	40000613          	li	a2,1024
    800038da:	4581                	li	a1,0
    800038dc:	05850513          	addi	a0,a0,88
    800038e0:	be8fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    800038e4:	854a                	mv	a0,s2
    800038e6:	685000ef          	jal	8000476a <log_write>
  brelse(bp);
    800038ea:	854a                	mv	a0,s2
    800038ec:	e35ff0ef          	jal	80003720 <brelse>
}
    800038f0:	6906                	ld	s2,64(sp)
    800038f2:	79e2                	ld	s3,56(sp)
    800038f4:	7a42                	ld	s4,48(sp)
    800038f6:	7aa2                	ld	s5,40(sp)
    800038f8:	7b02                	ld	s6,32(sp)
    800038fa:	6be2                	ld	s7,24(sp)
    800038fc:	6c42                	ld	s8,16(sp)
    800038fe:	6ca2                	ld	s9,8(sp)
}
    80003900:	8526                	mv	a0,s1
    80003902:	60e6                	ld	ra,88(sp)
    80003904:	6446                	ld	s0,80(sp)
    80003906:	64a6                	ld	s1,72(sp)
    80003908:	6125                	addi	sp,sp,96
    8000390a:	8082                	ret
    brelse(bp);
    8000390c:	854a                	mv	a0,s2
    8000390e:	e13ff0ef          	jal	80003720 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003912:	015c87bb          	addw	a5,s9,s5
    80003916:	00078a9b          	sext.w	s5,a5
    8000391a:	004b2703          	lw	a4,4(s6)
    8000391e:	04eaff63          	bgeu	s5,a4,8000397c <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003922:	41fad79b          	sraiw	a5,s5,0x1f
    80003926:	0137d79b          	srliw	a5,a5,0x13
    8000392a:	015787bb          	addw	a5,a5,s5
    8000392e:	40d7d79b          	sraiw	a5,a5,0xd
    80003932:	01cb2583          	lw	a1,28(s6)
    80003936:	9dbd                	addw	a1,a1,a5
    80003938:	855e                	mv	a0,s7
    8000393a:	cdfff0ef          	jal	80003618 <bread>
    8000393e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003940:	004b2503          	lw	a0,4(s6)
    80003944:	000a849b          	sext.w	s1,s5
    80003948:	8762                	mv	a4,s8
    8000394a:	fca4f1e3          	bgeu	s1,a0,8000390c <balloc+0x90>
      m = 1 << (bi % 8);
    8000394e:	00777693          	andi	a3,a4,7
    80003952:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003956:	41f7579b          	sraiw	a5,a4,0x1f
    8000395a:	01d7d79b          	srliw	a5,a5,0x1d
    8000395e:	9fb9                	addw	a5,a5,a4
    80003960:	4037d79b          	sraiw	a5,a5,0x3
    80003964:	00f90633          	add	a2,s2,a5
    80003968:	05864603          	lbu	a2,88(a2)
    8000396c:	00c6f5b3          	and	a1,a3,a2
    80003970:	d5a1                	beqz	a1,800038b8 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003972:	2705                	addiw	a4,a4,1
    80003974:	2485                	addiw	s1,s1,1
    80003976:	fd471ae3          	bne	a4,s4,8000394a <balloc+0xce>
    8000397a:	bf49                	j	8000390c <balloc+0x90>
    8000397c:	6906                	ld	s2,64(sp)
    8000397e:	79e2                	ld	s3,56(sp)
    80003980:	7a42                	ld	s4,48(sp)
    80003982:	7aa2                	ld	s5,40(sp)
    80003984:	7b02                	ld	s6,32(sp)
    80003986:	6be2                	ld	s7,24(sp)
    80003988:	6c42                	ld	s8,16(sp)
    8000398a:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000398c:	00005517          	auipc	a0,0x5
    80003990:	bfc50513          	addi	a0,a0,-1028 # 80008588 <etext+0x588>
    80003994:	b2ffc0ef          	jal	800004c2 <printf>
  return 0;
    80003998:	4481                	li	s1,0
    8000399a:	b79d                	j	80003900 <balloc+0x84>

000000008000399c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000399c:	7179                	addi	sp,sp,-48
    8000399e:	f406                	sd	ra,40(sp)
    800039a0:	f022                	sd	s0,32(sp)
    800039a2:	ec26                	sd	s1,24(sp)
    800039a4:	e84a                	sd	s2,16(sp)
    800039a6:	e44e                	sd	s3,8(sp)
    800039a8:	1800                	addi	s0,sp,48
    800039aa:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800039ac:	47ad                	li	a5,11
    800039ae:	02b7e663          	bltu	a5,a1,800039da <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800039b2:	02059793          	slli	a5,a1,0x20
    800039b6:	01e7d593          	srli	a1,a5,0x1e
    800039ba:	00b504b3          	add	s1,a0,a1
    800039be:	0504a903          	lw	s2,80(s1)
    800039c2:	06091a63          	bnez	s2,80003a36 <bmap+0x9a>
      addr = balloc(ip->dev);
    800039c6:	4108                	lw	a0,0(a0)
    800039c8:	eb5ff0ef          	jal	8000387c <balloc>
    800039cc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800039d0:	06090363          	beqz	s2,80003a36 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800039d4:	0524a823          	sw	s2,80(s1)
    800039d8:	a8b9                	j	80003a36 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800039da:	ff45849b          	addiw	s1,a1,-12
    800039de:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800039e2:	0ff00793          	li	a5,255
    800039e6:	06e7ee63          	bltu	a5,a4,80003a62 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800039ea:	08052903          	lw	s2,128(a0)
    800039ee:	00091d63          	bnez	s2,80003a08 <bmap+0x6c>
      addr = balloc(ip->dev);
    800039f2:	4108                	lw	a0,0(a0)
    800039f4:	e89ff0ef          	jal	8000387c <balloc>
    800039f8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800039fc:	02090d63          	beqz	s2,80003a36 <bmap+0x9a>
    80003a00:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003a02:	0929a023          	sw	s2,128(s3)
    80003a06:	a011                	j	80003a0a <bmap+0x6e>
    80003a08:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003a0a:	85ca                	mv	a1,s2
    80003a0c:	0009a503          	lw	a0,0(s3)
    80003a10:	c09ff0ef          	jal	80003618 <bread>
    80003a14:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a16:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003a1a:	02049713          	slli	a4,s1,0x20
    80003a1e:	01e75593          	srli	a1,a4,0x1e
    80003a22:	00b784b3          	add	s1,a5,a1
    80003a26:	0004a903          	lw	s2,0(s1)
    80003a2a:	00090e63          	beqz	s2,80003a46 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003a2e:	8552                	mv	a0,s4
    80003a30:	cf1ff0ef          	jal	80003720 <brelse>
    return addr;
    80003a34:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003a36:	854a                	mv	a0,s2
    80003a38:	70a2                	ld	ra,40(sp)
    80003a3a:	7402                	ld	s0,32(sp)
    80003a3c:	64e2                	ld	s1,24(sp)
    80003a3e:	6942                	ld	s2,16(sp)
    80003a40:	69a2                	ld	s3,8(sp)
    80003a42:	6145                	addi	sp,sp,48
    80003a44:	8082                	ret
      addr = balloc(ip->dev);
    80003a46:	0009a503          	lw	a0,0(s3)
    80003a4a:	e33ff0ef          	jal	8000387c <balloc>
    80003a4e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003a52:	fc090ee3          	beqz	s2,80003a2e <bmap+0x92>
        a[bn] = addr;
    80003a56:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003a5a:	8552                	mv	a0,s4
    80003a5c:	50f000ef          	jal	8000476a <log_write>
    80003a60:	b7f9                	j	80003a2e <bmap+0x92>
    80003a62:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003a64:	00005517          	auipc	a0,0x5
    80003a68:	b3c50513          	addi	a0,a0,-1220 # 800085a0 <etext+0x5a0>
    80003a6c:	d29fc0ef          	jal	80000794 <panic>

0000000080003a70 <iget>:
{
    80003a70:	7179                	addi	sp,sp,-48
    80003a72:	f406                	sd	ra,40(sp)
    80003a74:	f022                	sd	s0,32(sp)
    80003a76:	ec26                	sd	s1,24(sp)
    80003a78:	e84a                	sd	s2,16(sp)
    80003a7a:	e44e                	sd	s3,8(sp)
    80003a7c:	e052                	sd	s4,0(sp)
    80003a7e:	1800                	addi	s0,sp,48
    80003a80:	89aa                	mv	s3,a0
    80003a82:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a84:	000e5517          	auipc	a0,0xe5
    80003a88:	ccc50513          	addi	a0,a0,-820 # 800e8750 <itable>
    80003a8c:	968fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80003a90:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a92:	000e5497          	auipc	s1,0xe5
    80003a96:	cd648493          	addi	s1,s1,-810 # 800e8768 <itable+0x18>
    80003a9a:	000e6697          	auipc	a3,0xe6
    80003a9e:	75e68693          	addi	a3,a3,1886 # 800ea1f8 <log>
    80003aa2:	a039                	j	80003ab0 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003aa4:	02090963          	beqz	s2,80003ad6 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003aa8:	08848493          	addi	s1,s1,136
    80003aac:	02d48863          	beq	s1,a3,80003adc <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003ab0:	449c                	lw	a5,8(s1)
    80003ab2:	fef059e3          	blez	a5,80003aa4 <iget+0x34>
    80003ab6:	4098                	lw	a4,0(s1)
    80003ab8:	ff3716e3          	bne	a4,s3,80003aa4 <iget+0x34>
    80003abc:	40d8                	lw	a4,4(s1)
    80003abe:	ff4713e3          	bne	a4,s4,80003aa4 <iget+0x34>
      ip->ref++;
    80003ac2:	2785                	addiw	a5,a5,1
    80003ac4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003ac6:	000e5517          	auipc	a0,0xe5
    80003aca:	c8a50513          	addi	a0,a0,-886 # 800e8750 <itable>
    80003ace:	9befd0ef          	jal	80000c8c <release>
      return ip;
    80003ad2:	8926                	mv	s2,s1
    80003ad4:	a02d                	j	80003afe <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ad6:	fbe9                	bnez	a5,80003aa8 <iget+0x38>
      empty = ip;
    80003ad8:	8926                	mv	s2,s1
    80003ada:	b7f9                	j	80003aa8 <iget+0x38>
  if(empty == 0)
    80003adc:	02090a63          	beqz	s2,80003b10 <iget+0xa0>
  ip->dev = dev;
    80003ae0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003ae4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003ae8:	4785                	li	a5,1
    80003aea:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003aee:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003af2:	000e5517          	auipc	a0,0xe5
    80003af6:	c5e50513          	addi	a0,a0,-930 # 800e8750 <itable>
    80003afa:	992fd0ef          	jal	80000c8c <release>
}
    80003afe:	854a                	mv	a0,s2
    80003b00:	70a2                	ld	ra,40(sp)
    80003b02:	7402                	ld	s0,32(sp)
    80003b04:	64e2                	ld	s1,24(sp)
    80003b06:	6942                	ld	s2,16(sp)
    80003b08:	69a2                	ld	s3,8(sp)
    80003b0a:	6a02                	ld	s4,0(sp)
    80003b0c:	6145                	addi	sp,sp,48
    80003b0e:	8082                	ret
    panic("iget: no inodes");
    80003b10:	00005517          	auipc	a0,0x5
    80003b14:	aa850513          	addi	a0,a0,-1368 # 800085b8 <etext+0x5b8>
    80003b18:	c7dfc0ef          	jal	80000794 <panic>

0000000080003b1c <fsinit>:
fsinit(int dev) {
    80003b1c:	7179                	addi	sp,sp,-48
    80003b1e:	f406                	sd	ra,40(sp)
    80003b20:	f022                	sd	s0,32(sp)
    80003b22:	ec26                	sd	s1,24(sp)
    80003b24:	e84a                	sd	s2,16(sp)
    80003b26:	e44e                	sd	s3,8(sp)
    80003b28:	1800                	addi	s0,sp,48
    80003b2a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b2c:	4585                	li	a1,1
    80003b2e:	aebff0ef          	jal	80003618 <bread>
    80003b32:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b34:	000e5997          	auipc	s3,0xe5
    80003b38:	bfc98993          	addi	s3,s3,-1028 # 800e8730 <sb>
    80003b3c:	02000613          	li	a2,32
    80003b40:	05850593          	addi	a1,a0,88
    80003b44:	854e                	mv	a0,s3
    80003b46:	9defd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80003b4a:	8526                	mv	a0,s1
    80003b4c:	bd5ff0ef          	jal	80003720 <brelse>
  if(sb.magic != FSMAGIC)
    80003b50:	0009a703          	lw	a4,0(s3)
    80003b54:	102037b7          	lui	a5,0x10203
    80003b58:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b5c:	02f71063          	bne	a4,a5,80003b7c <fsinit+0x60>
  initlog(dev, &sb);
    80003b60:	000e5597          	auipc	a1,0xe5
    80003b64:	bd058593          	addi	a1,a1,-1072 # 800e8730 <sb>
    80003b68:	854a                	mv	a0,s2
    80003b6a:	1f9000ef          	jal	80004562 <initlog>
}
    80003b6e:	70a2                	ld	ra,40(sp)
    80003b70:	7402                	ld	s0,32(sp)
    80003b72:	64e2                	ld	s1,24(sp)
    80003b74:	6942                	ld	s2,16(sp)
    80003b76:	69a2                	ld	s3,8(sp)
    80003b78:	6145                	addi	sp,sp,48
    80003b7a:	8082                	ret
    panic("invalid file system");
    80003b7c:	00005517          	auipc	a0,0x5
    80003b80:	a4c50513          	addi	a0,a0,-1460 # 800085c8 <etext+0x5c8>
    80003b84:	c11fc0ef          	jal	80000794 <panic>

0000000080003b88 <iinit>:
{
    80003b88:	7179                	addi	sp,sp,-48
    80003b8a:	f406                	sd	ra,40(sp)
    80003b8c:	f022                	sd	s0,32(sp)
    80003b8e:	ec26                	sd	s1,24(sp)
    80003b90:	e84a                	sd	s2,16(sp)
    80003b92:	e44e                	sd	s3,8(sp)
    80003b94:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b96:	00005597          	auipc	a1,0x5
    80003b9a:	a4a58593          	addi	a1,a1,-1462 # 800085e0 <etext+0x5e0>
    80003b9e:	000e5517          	auipc	a0,0xe5
    80003ba2:	bb250513          	addi	a0,a0,-1102 # 800e8750 <itable>
    80003ba6:	fcffc0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003baa:	000e5497          	auipc	s1,0xe5
    80003bae:	bce48493          	addi	s1,s1,-1074 # 800e8778 <itable+0x28>
    80003bb2:	000e6997          	auipc	s3,0xe6
    80003bb6:	65698993          	addi	s3,s3,1622 # 800ea208 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003bba:	00005917          	auipc	s2,0x5
    80003bbe:	a2e90913          	addi	s2,s2,-1490 # 800085e8 <etext+0x5e8>
    80003bc2:	85ca                	mv	a1,s2
    80003bc4:	8526                	mv	a0,s1
    80003bc6:	475000ef          	jal	8000483a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003bca:	08848493          	addi	s1,s1,136
    80003bce:	ff349ae3          	bne	s1,s3,80003bc2 <iinit+0x3a>
}
    80003bd2:	70a2                	ld	ra,40(sp)
    80003bd4:	7402                	ld	s0,32(sp)
    80003bd6:	64e2                	ld	s1,24(sp)
    80003bd8:	6942                	ld	s2,16(sp)
    80003bda:	69a2                	ld	s3,8(sp)
    80003bdc:	6145                	addi	sp,sp,48
    80003bde:	8082                	ret

0000000080003be0 <ialloc>:
{
    80003be0:	7139                	addi	sp,sp,-64
    80003be2:	fc06                	sd	ra,56(sp)
    80003be4:	f822                	sd	s0,48(sp)
    80003be6:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003be8:	000e5717          	auipc	a4,0xe5
    80003bec:	b5472703          	lw	a4,-1196(a4) # 800e873c <sb+0xc>
    80003bf0:	4785                	li	a5,1
    80003bf2:	06e7f063          	bgeu	a5,a4,80003c52 <ialloc+0x72>
    80003bf6:	f426                	sd	s1,40(sp)
    80003bf8:	f04a                	sd	s2,32(sp)
    80003bfa:	ec4e                	sd	s3,24(sp)
    80003bfc:	e852                	sd	s4,16(sp)
    80003bfe:	e456                	sd	s5,8(sp)
    80003c00:	e05a                	sd	s6,0(sp)
    80003c02:	8aaa                	mv	s5,a0
    80003c04:	8b2e                	mv	s6,a1
    80003c06:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c08:	000e5a17          	auipc	s4,0xe5
    80003c0c:	b28a0a13          	addi	s4,s4,-1240 # 800e8730 <sb>
    80003c10:	00495593          	srli	a1,s2,0x4
    80003c14:	018a2783          	lw	a5,24(s4)
    80003c18:	9dbd                	addw	a1,a1,a5
    80003c1a:	8556                	mv	a0,s5
    80003c1c:	9fdff0ef          	jal	80003618 <bread>
    80003c20:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c22:	05850993          	addi	s3,a0,88
    80003c26:	00f97793          	andi	a5,s2,15
    80003c2a:	079a                	slli	a5,a5,0x6
    80003c2c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c2e:	00099783          	lh	a5,0(s3)
    80003c32:	cb9d                	beqz	a5,80003c68 <ialloc+0x88>
    brelse(bp);
    80003c34:	aedff0ef          	jal	80003720 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c38:	0905                	addi	s2,s2,1
    80003c3a:	00ca2703          	lw	a4,12(s4)
    80003c3e:	0009079b          	sext.w	a5,s2
    80003c42:	fce7e7e3          	bltu	a5,a4,80003c10 <ialloc+0x30>
    80003c46:	74a2                	ld	s1,40(sp)
    80003c48:	7902                	ld	s2,32(sp)
    80003c4a:	69e2                	ld	s3,24(sp)
    80003c4c:	6a42                	ld	s4,16(sp)
    80003c4e:	6aa2                	ld	s5,8(sp)
    80003c50:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003c52:	00005517          	auipc	a0,0x5
    80003c56:	99e50513          	addi	a0,a0,-1634 # 800085f0 <etext+0x5f0>
    80003c5a:	869fc0ef          	jal	800004c2 <printf>
  return 0;
    80003c5e:	4501                	li	a0,0
}
    80003c60:	70e2                	ld	ra,56(sp)
    80003c62:	7442                	ld	s0,48(sp)
    80003c64:	6121                	addi	sp,sp,64
    80003c66:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003c68:	04000613          	li	a2,64
    80003c6c:	4581                	li	a1,0
    80003c6e:	854e                	mv	a0,s3
    80003c70:	858fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    80003c74:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c78:	8526                	mv	a0,s1
    80003c7a:	2f1000ef          	jal	8000476a <log_write>
      brelse(bp);
    80003c7e:	8526                	mv	a0,s1
    80003c80:	aa1ff0ef          	jal	80003720 <brelse>
      return iget(dev, inum);
    80003c84:	0009059b          	sext.w	a1,s2
    80003c88:	8556                	mv	a0,s5
    80003c8a:	de7ff0ef          	jal	80003a70 <iget>
    80003c8e:	74a2                	ld	s1,40(sp)
    80003c90:	7902                	ld	s2,32(sp)
    80003c92:	69e2                	ld	s3,24(sp)
    80003c94:	6a42                	ld	s4,16(sp)
    80003c96:	6aa2                	ld	s5,8(sp)
    80003c98:	6b02                	ld	s6,0(sp)
    80003c9a:	b7d9                	j	80003c60 <ialloc+0x80>

0000000080003c9c <iupdate>:
{
    80003c9c:	1101                	addi	sp,sp,-32
    80003c9e:	ec06                	sd	ra,24(sp)
    80003ca0:	e822                	sd	s0,16(sp)
    80003ca2:	e426                	sd	s1,8(sp)
    80003ca4:	e04a                	sd	s2,0(sp)
    80003ca6:	1000                	addi	s0,sp,32
    80003ca8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003caa:	415c                	lw	a5,4(a0)
    80003cac:	0047d79b          	srliw	a5,a5,0x4
    80003cb0:	000e5597          	auipc	a1,0xe5
    80003cb4:	a985a583          	lw	a1,-1384(a1) # 800e8748 <sb+0x18>
    80003cb8:	9dbd                	addw	a1,a1,a5
    80003cba:	4108                	lw	a0,0(a0)
    80003cbc:	95dff0ef          	jal	80003618 <bread>
    80003cc0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cc2:	05850793          	addi	a5,a0,88
    80003cc6:	40d8                	lw	a4,4(s1)
    80003cc8:	8b3d                	andi	a4,a4,15
    80003cca:	071a                	slli	a4,a4,0x6
    80003ccc:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003cce:	04449703          	lh	a4,68(s1)
    80003cd2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003cd6:	04649703          	lh	a4,70(s1)
    80003cda:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003cde:	04849703          	lh	a4,72(s1)
    80003ce2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003ce6:	04a49703          	lh	a4,74(s1)
    80003cea:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003cee:	44f8                	lw	a4,76(s1)
    80003cf0:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003cf2:	03400613          	li	a2,52
    80003cf6:	05048593          	addi	a1,s1,80
    80003cfa:	00c78513          	addi	a0,a5,12
    80003cfe:	826fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003d02:	854a                	mv	a0,s2
    80003d04:	267000ef          	jal	8000476a <log_write>
  brelse(bp);
    80003d08:	854a                	mv	a0,s2
    80003d0a:	a17ff0ef          	jal	80003720 <brelse>
}
    80003d0e:	60e2                	ld	ra,24(sp)
    80003d10:	6442                	ld	s0,16(sp)
    80003d12:	64a2                	ld	s1,8(sp)
    80003d14:	6902                	ld	s2,0(sp)
    80003d16:	6105                	addi	sp,sp,32
    80003d18:	8082                	ret

0000000080003d1a <idup>:
{
    80003d1a:	1101                	addi	sp,sp,-32
    80003d1c:	ec06                	sd	ra,24(sp)
    80003d1e:	e822                	sd	s0,16(sp)
    80003d20:	e426                	sd	s1,8(sp)
    80003d22:	1000                	addi	s0,sp,32
    80003d24:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d26:	000e5517          	auipc	a0,0xe5
    80003d2a:	a2a50513          	addi	a0,a0,-1494 # 800e8750 <itable>
    80003d2e:	ec7fc0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    80003d32:	449c                	lw	a5,8(s1)
    80003d34:	2785                	addiw	a5,a5,1
    80003d36:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d38:	000e5517          	auipc	a0,0xe5
    80003d3c:	a1850513          	addi	a0,a0,-1512 # 800e8750 <itable>
    80003d40:	f4dfc0ef          	jal	80000c8c <release>
}
    80003d44:	8526                	mv	a0,s1
    80003d46:	60e2                	ld	ra,24(sp)
    80003d48:	6442                	ld	s0,16(sp)
    80003d4a:	64a2                	ld	s1,8(sp)
    80003d4c:	6105                	addi	sp,sp,32
    80003d4e:	8082                	ret

0000000080003d50 <ilock>:
{
    80003d50:	1101                	addi	sp,sp,-32
    80003d52:	ec06                	sd	ra,24(sp)
    80003d54:	e822                	sd	s0,16(sp)
    80003d56:	e426                	sd	s1,8(sp)
    80003d58:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d5a:	cd19                	beqz	a0,80003d78 <ilock+0x28>
    80003d5c:	84aa                	mv	s1,a0
    80003d5e:	451c                	lw	a5,8(a0)
    80003d60:	00f05c63          	blez	a5,80003d78 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003d64:	0541                	addi	a0,a0,16
    80003d66:	30b000ef          	jal	80004870 <acquiresleep>
  if(ip->valid == 0){
    80003d6a:	40bc                	lw	a5,64(s1)
    80003d6c:	cf89                	beqz	a5,80003d86 <ilock+0x36>
}
    80003d6e:	60e2                	ld	ra,24(sp)
    80003d70:	6442                	ld	s0,16(sp)
    80003d72:	64a2                	ld	s1,8(sp)
    80003d74:	6105                	addi	sp,sp,32
    80003d76:	8082                	ret
    80003d78:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003d7a:	00005517          	auipc	a0,0x5
    80003d7e:	88e50513          	addi	a0,a0,-1906 # 80008608 <etext+0x608>
    80003d82:	a13fc0ef          	jal	80000794 <panic>
    80003d86:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d88:	40dc                	lw	a5,4(s1)
    80003d8a:	0047d79b          	srliw	a5,a5,0x4
    80003d8e:	000e5597          	auipc	a1,0xe5
    80003d92:	9ba5a583          	lw	a1,-1606(a1) # 800e8748 <sb+0x18>
    80003d96:	9dbd                	addw	a1,a1,a5
    80003d98:	4088                	lw	a0,0(s1)
    80003d9a:	87fff0ef          	jal	80003618 <bread>
    80003d9e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003da0:	05850593          	addi	a1,a0,88
    80003da4:	40dc                	lw	a5,4(s1)
    80003da6:	8bbd                	andi	a5,a5,15
    80003da8:	079a                	slli	a5,a5,0x6
    80003daa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003dac:	00059783          	lh	a5,0(a1)
    80003db0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003db4:	00259783          	lh	a5,2(a1)
    80003db8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003dbc:	00459783          	lh	a5,4(a1)
    80003dc0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003dc4:	00659783          	lh	a5,6(a1)
    80003dc8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003dcc:	459c                	lw	a5,8(a1)
    80003dce:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003dd0:	03400613          	li	a2,52
    80003dd4:	05b1                	addi	a1,a1,12
    80003dd6:	05048513          	addi	a0,s1,80
    80003dda:	f4bfc0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003dde:	854a                	mv	a0,s2
    80003de0:	941ff0ef          	jal	80003720 <brelse>
    ip->valid = 1;
    80003de4:	4785                	li	a5,1
    80003de6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003de8:	04449783          	lh	a5,68(s1)
    80003dec:	c399                	beqz	a5,80003df2 <ilock+0xa2>
    80003dee:	6902                	ld	s2,0(sp)
    80003df0:	bfbd                	j	80003d6e <ilock+0x1e>
      panic("ilock: no type");
    80003df2:	00005517          	auipc	a0,0x5
    80003df6:	81e50513          	addi	a0,a0,-2018 # 80008610 <etext+0x610>
    80003dfa:	99bfc0ef          	jal	80000794 <panic>

0000000080003dfe <iunlock>:
{
    80003dfe:	1101                	addi	sp,sp,-32
    80003e00:	ec06                	sd	ra,24(sp)
    80003e02:	e822                	sd	s0,16(sp)
    80003e04:	e426                	sd	s1,8(sp)
    80003e06:	e04a                	sd	s2,0(sp)
    80003e08:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e0a:	c505                	beqz	a0,80003e32 <iunlock+0x34>
    80003e0c:	84aa                	mv	s1,a0
    80003e0e:	01050913          	addi	s2,a0,16
    80003e12:	854a                	mv	a0,s2
    80003e14:	2db000ef          	jal	800048ee <holdingsleep>
    80003e18:	cd09                	beqz	a0,80003e32 <iunlock+0x34>
    80003e1a:	449c                	lw	a5,8(s1)
    80003e1c:	00f05b63          	blez	a5,80003e32 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003e20:	854a                	mv	a0,s2
    80003e22:	295000ef          	jal	800048b6 <releasesleep>
}
    80003e26:	60e2                	ld	ra,24(sp)
    80003e28:	6442                	ld	s0,16(sp)
    80003e2a:	64a2                	ld	s1,8(sp)
    80003e2c:	6902                	ld	s2,0(sp)
    80003e2e:	6105                	addi	sp,sp,32
    80003e30:	8082                	ret
    panic("iunlock");
    80003e32:	00004517          	auipc	a0,0x4
    80003e36:	7ee50513          	addi	a0,a0,2030 # 80008620 <etext+0x620>
    80003e3a:	95bfc0ef          	jal	80000794 <panic>

0000000080003e3e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e3e:	7179                	addi	sp,sp,-48
    80003e40:	f406                	sd	ra,40(sp)
    80003e42:	f022                	sd	s0,32(sp)
    80003e44:	ec26                	sd	s1,24(sp)
    80003e46:	e84a                	sd	s2,16(sp)
    80003e48:	e44e                	sd	s3,8(sp)
    80003e4a:	1800                	addi	s0,sp,48
    80003e4c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e4e:	05050493          	addi	s1,a0,80
    80003e52:	08050913          	addi	s2,a0,128
    80003e56:	a021                	j	80003e5e <itrunc+0x20>
    80003e58:	0491                	addi	s1,s1,4
    80003e5a:	01248b63          	beq	s1,s2,80003e70 <itrunc+0x32>
    if(ip->addrs[i]){
    80003e5e:	408c                	lw	a1,0(s1)
    80003e60:	dde5                	beqz	a1,80003e58 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003e62:	0009a503          	lw	a0,0(s3)
    80003e66:	9abff0ef          	jal	80003810 <bfree>
      ip->addrs[i] = 0;
    80003e6a:	0004a023          	sw	zero,0(s1)
    80003e6e:	b7ed                	j	80003e58 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e70:	0809a583          	lw	a1,128(s3)
    80003e74:	ed89                	bnez	a1,80003e8e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e76:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e7a:	854e                	mv	a0,s3
    80003e7c:	e21ff0ef          	jal	80003c9c <iupdate>
}
    80003e80:	70a2                	ld	ra,40(sp)
    80003e82:	7402                	ld	s0,32(sp)
    80003e84:	64e2                	ld	s1,24(sp)
    80003e86:	6942                	ld	s2,16(sp)
    80003e88:	69a2                	ld	s3,8(sp)
    80003e8a:	6145                	addi	sp,sp,48
    80003e8c:	8082                	ret
    80003e8e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e90:	0009a503          	lw	a0,0(s3)
    80003e94:	f84ff0ef          	jal	80003618 <bread>
    80003e98:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e9a:	05850493          	addi	s1,a0,88
    80003e9e:	45850913          	addi	s2,a0,1112
    80003ea2:	a021                	j	80003eaa <itrunc+0x6c>
    80003ea4:	0491                	addi	s1,s1,4
    80003ea6:	01248963          	beq	s1,s2,80003eb8 <itrunc+0x7a>
      if(a[j])
    80003eaa:	408c                	lw	a1,0(s1)
    80003eac:	dde5                	beqz	a1,80003ea4 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003eae:	0009a503          	lw	a0,0(s3)
    80003eb2:	95fff0ef          	jal	80003810 <bfree>
    80003eb6:	b7fd                	j	80003ea4 <itrunc+0x66>
    brelse(bp);
    80003eb8:	8552                	mv	a0,s4
    80003eba:	867ff0ef          	jal	80003720 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ebe:	0809a583          	lw	a1,128(s3)
    80003ec2:	0009a503          	lw	a0,0(s3)
    80003ec6:	94bff0ef          	jal	80003810 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003eca:	0809a023          	sw	zero,128(s3)
    80003ece:	6a02                	ld	s4,0(sp)
    80003ed0:	b75d                	j	80003e76 <itrunc+0x38>

0000000080003ed2 <iput>:
{
    80003ed2:	1101                	addi	sp,sp,-32
    80003ed4:	ec06                	sd	ra,24(sp)
    80003ed6:	e822                	sd	s0,16(sp)
    80003ed8:	e426                	sd	s1,8(sp)
    80003eda:	1000                	addi	s0,sp,32
    80003edc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ede:	000e5517          	auipc	a0,0xe5
    80003ee2:	87250513          	addi	a0,a0,-1934 # 800e8750 <itable>
    80003ee6:	d0ffc0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003eea:	4498                	lw	a4,8(s1)
    80003eec:	4785                	li	a5,1
    80003eee:	02f70063          	beq	a4,a5,80003f0e <iput+0x3c>
  ip->ref--;
    80003ef2:	449c                	lw	a5,8(s1)
    80003ef4:	37fd                	addiw	a5,a5,-1
    80003ef6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ef8:	000e5517          	auipc	a0,0xe5
    80003efc:	85850513          	addi	a0,a0,-1960 # 800e8750 <itable>
    80003f00:	d8dfc0ef          	jal	80000c8c <release>
}
    80003f04:	60e2                	ld	ra,24(sp)
    80003f06:	6442                	ld	s0,16(sp)
    80003f08:	64a2                	ld	s1,8(sp)
    80003f0a:	6105                	addi	sp,sp,32
    80003f0c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f0e:	40bc                	lw	a5,64(s1)
    80003f10:	d3ed                	beqz	a5,80003ef2 <iput+0x20>
    80003f12:	04a49783          	lh	a5,74(s1)
    80003f16:	fff1                	bnez	a5,80003ef2 <iput+0x20>
    80003f18:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003f1a:	01048913          	addi	s2,s1,16
    80003f1e:	854a                	mv	a0,s2
    80003f20:	151000ef          	jal	80004870 <acquiresleep>
    release(&itable.lock);
    80003f24:	000e5517          	auipc	a0,0xe5
    80003f28:	82c50513          	addi	a0,a0,-2004 # 800e8750 <itable>
    80003f2c:	d61fc0ef          	jal	80000c8c <release>
    itrunc(ip);
    80003f30:	8526                	mv	a0,s1
    80003f32:	f0dff0ef          	jal	80003e3e <itrunc>
    ip->type = 0;
    80003f36:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	d61ff0ef          	jal	80003c9c <iupdate>
    ip->valid = 0;
    80003f40:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f44:	854a                	mv	a0,s2
    80003f46:	171000ef          	jal	800048b6 <releasesleep>
    acquire(&itable.lock);
    80003f4a:	000e5517          	auipc	a0,0xe5
    80003f4e:	80650513          	addi	a0,a0,-2042 # 800e8750 <itable>
    80003f52:	ca3fc0ef          	jal	80000bf4 <acquire>
    80003f56:	6902                	ld	s2,0(sp)
    80003f58:	bf69                	j	80003ef2 <iput+0x20>

0000000080003f5a <iunlockput>:
{
    80003f5a:	1101                	addi	sp,sp,-32
    80003f5c:	ec06                	sd	ra,24(sp)
    80003f5e:	e822                	sd	s0,16(sp)
    80003f60:	e426                	sd	s1,8(sp)
    80003f62:	1000                	addi	s0,sp,32
    80003f64:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f66:	e99ff0ef          	jal	80003dfe <iunlock>
  iput(ip);
    80003f6a:	8526                	mv	a0,s1
    80003f6c:	f67ff0ef          	jal	80003ed2 <iput>
}
    80003f70:	60e2                	ld	ra,24(sp)
    80003f72:	6442                	ld	s0,16(sp)
    80003f74:	64a2                	ld	s1,8(sp)
    80003f76:	6105                	addi	sp,sp,32
    80003f78:	8082                	ret

0000000080003f7a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f7a:	1141                	addi	sp,sp,-16
    80003f7c:	e422                	sd	s0,8(sp)
    80003f7e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f80:	411c                	lw	a5,0(a0)
    80003f82:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f84:	415c                	lw	a5,4(a0)
    80003f86:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f88:	04451783          	lh	a5,68(a0)
    80003f8c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f90:	04a51783          	lh	a5,74(a0)
    80003f94:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f98:	04c56783          	lwu	a5,76(a0)
    80003f9c:	e99c                	sd	a5,16(a1)
}
    80003f9e:	6422                	ld	s0,8(sp)
    80003fa0:	0141                	addi	sp,sp,16
    80003fa2:	8082                	ret

0000000080003fa4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fa4:	457c                	lw	a5,76(a0)
    80003fa6:	0ed7eb63          	bltu	a5,a3,8000409c <readi+0xf8>
{
    80003faa:	7159                	addi	sp,sp,-112
    80003fac:	f486                	sd	ra,104(sp)
    80003fae:	f0a2                	sd	s0,96(sp)
    80003fb0:	eca6                	sd	s1,88(sp)
    80003fb2:	e0d2                	sd	s4,64(sp)
    80003fb4:	fc56                	sd	s5,56(sp)
    80003fb6:	f85a                	sd	s6,48(sp)
    80003fb8:	f45e                	sd	s7,40(sp)
    80003fba:	1880                	addi	s0,sp,112
    80003fbc:	8b2a                	mv	s6,a0
    80003fbe:	8bae                	mv	s7,a1
    80003fc0:	8a32                	mv	s4,a2
    80003fc2:	84b6                	mv	s1,a3
    80003fc4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003fc6:	9f35                	addw	a4,a4,a3
    return 0;
    80003fc8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003fca:	0cd76063          	bltu	a4,a3,8000408a <readi+0xe6>
    80003fce:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003fd0:	00e7f463          	bgeu	a5,a4,80003fd8 <readi+0x34>
    n = ip->size - off;
    80003fd4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fd8:	080a8f63          	beqz	s5,80004076 <readi+0xd2>
    80003fdc:	e8ca                	sd	s2,80(sp)
    80003fde:	f062                	sd	s8,32(sp)
    80003fe0:	ec66                	sd	s9,24(sp)
    80003fe2:	e86a                	sd	s10,16(sp)
    80003fe4:	e46e                	sd	s11,8(sp)
    80003fe6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fe8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003fec:	5c7d                	li	s8,-1
    80003fee:	a80d                	j	80004020 <readi+0x7c>
    80003ff0:	020d1d93          	slli	s11,s10,0x20
    80003ff4:	020ddd93          	srli	s11,s11,0x20
    80003ff8:	05890613          	addi	a2,s2,88
    80003ffc:	86ee                	mv	a3,s11
    80003ffe:	963a                	add	a2,a2,a4
    80004000:	85d2                	mv	a1,s4
    80004002:	855e                	mv	a0,s7
    80004004:	a43fe0ef          	jal	80002a46 <either_copyout>
    80004008:	05850763          	beq	a0,s8,80004056 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000400c:	854a                	mv	a0,s2
    8000400e:	f12ff0ef          	jal	80003720 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004012:	013d09bb          	addw	s3,s10,s3
    80004016:	009d04bb          	addw	s1,s10,s1
    8000401a:	9a6e                	add	s4,s4,s11
    8000401c:	0559f763          	bgeu	s3,s5,8000406a <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80004020:	00a4d59b          	srliw	a1,s1,0xa
    80004024:	855a                	mv	a0,s6
    80004026:	977ff0ef          	jal	8000399c <bmap>
    8000402a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000402e:	c5b1                	beqz	a1,8000407a <readi+0xd6>
    bp = bread(ip->dev, addr);
    80004030:	000b2503          	lw	a0,0(s6)
    80004034:	de4ff0ef          	jal	80003618 <bread>
    80004038:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000403a:	3ff4f713          	andi	a4,s1,1023
    8000403e:	40ec87bb          	subw	a5,s9,a4
    80004042:	413a86bb          	subw	a3,s5,s3
    80004046:	8d3e                	mv	s10,a5
    80004048:	2781                	sext.w	a5,a5
    8000404a:	0006861b          	sext.w	a2,a3
    8000404e:	faf671e3          	bgeu	a2,a5,80003ff0 <readi+0x4c>
    80004052:	8d36                	mv	s10,a3
    80004054:	bf71                	j	80003ff0 <readi+0x4c>
      brelse(bp);
    80004056:	854a                	mv	a0,s2
    80004058:	ec8ff0ef          	jal	80003720 <brelse>
      tot = -1;
    8000405c:	59fd                	li	s3,-1
      break;
    8000405e:	6946                	ld	s2,80(sp)
    80004060:	7c02                	ld	s8,32(sp)
    80004062:	6ce2                	ld	s9,24(sp)
    80004064:	6d42                	ld	s10,16(sp)
    80004066:	6da2                	ld	s11,8(sp)
    80004068:	a831                	j	80004084 <readi+0xe0>
    8000406a:	6946                	ld	s2,80(sp)
    8000406c:	7c02                	ld	s8,32(sp)
    8000406e:	6ce2                	ld	s9,24(sp)
    80004070:	6d42                	ld	s10,16(sp)
    80004072:	6da2                	ld	s11,8(sp)
    80004074:	a801                	j	80004084 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004076:	89d6                	mv	s3,s5
    80004078:	a031                	j	80004084 <readi+0xe0>
    8000407a:	6946                	ld	s2,80(sp)
    8000407c:	7c02                	ld	s8,32(sp)
    8000407e:	6ce2                	ld	s9,24(sp)
    80004080:	6d42                	ld	s10,16(sp)
    80004082:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80004084:	0009851b          	sext.w	a0,s3
    80004088:	69a6                	ld	s3,72(sp)
}
    8000408a:	70a6                	ld	ra,104(sp)
    8000408c:	7406                	ld	s0,96(sp)
    8000408e:	64e6                	ld	s1,88(sp)
    80004090:	6a06                	ld	s4,64(sp)
    80004092:	7ae2                	ld	s5,56(sp)
    80004094:	7b42                	ld	s6,48(sp)
    80004096:	7ba2                	ld	s7,40(sp)
    80004098:	6165                	addi	sp,sp,112
    8000409a:	8082                	ret
    return 0;
    8000409c:	4501                	li	a0,0
}
    8000409e:	8082                	ret

00000000800040a0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040a0:	457c                	lw	a5,76(a0)
    800040a2:	10d7e063          	bltu	a5,a3,800041a2 <writei+0x102>
{
    800040a6:	7159                	addi	sp,sp,-112
    800040a8:	f486                	sd	ra,104(sp)
    800040aa:	f0a2                	sd	s0,96(sp)
    800040ac:	e8ca                	sd	s2,80(sp)
    800040ae:	e0d2                	sd	s4,64(sp)
    800040b0:	fc56                	sd	s5,56(sp)
    800040b2:	f85a                	sd	s6,48(sp)
    800040b4:	f45e                	sd	s7,40(sp)
    800040b6:	1880                	addi	s0,sp,112
    800040b8:	8aaa                	mv	s5,a0
    800040ba:	8bae                	mv	s7,a1
    800040bc:	8a32                	mv	s4,a2
    800040be:	8936                	mv	s2,a3
    800040c0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800040c2:	00e687bb          	addw	a5,a3,a4
    800040c6:	0ed7e063          	bltu	a5,a3,800041a6 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040ca:	00043737          	lui	a4,0x43
    800040ce:	0cf76e63          	bltu	a4,a5,800041aa <writei+0x10a>
    800040d2:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040d4:	0a0b0f63          	beqz	s6,80004192 <writei+0xf2>
    800040d8:	eca6                	sd	s1,88(sp)
    800040da:	f062                	sd	s8,32(sp)
    800040dc:	ec66                	sd	s9,24(sp)
    800040de:	e86a                	sd	s10,16(sp)
    800040e0:	e46e                	sd	s11,8(sp)
    800040e2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040e4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040e8:	5c7d                	li	s8,-1
    800040ea:	a825                	j	80004122 <writei+0x82>
    800040ec:	020d1d93          	slli	s11,s10,0x20
    800040f0:	020ddd93          	srli	s11,s11,0x20
    800040f4:	05848513          	addi	a0,s1,88
    800040f8:	86ee                	mv	a3,s11
    800040fa:	8652                	mv	a2,s4
    800040fc:	85de                	mv	a1,s7
    800040fe:	953a                	add	a0,a0,a4
    80004100:	991fe0ef          	jal	80002a90 <either_copyin>
    80004104:	05850a63          	beq	a0,s8,80004158 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004108:	8526                	mv	a0,s1
    8000410a:	660000ef          	jal	8000476a <log_write>
    brelse(bp);
    8000410e:	8526                	mv	a0,s1
    80004110:	e10ff0ef          	jal	80003720 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004114:	013d09bb          	addw	s3,s10,s3
    80004118:	012d093b          	addw	s2,s10,s2
    8000411c:	9a6e                	add	s4,s4,s11
    8000411e:	0569f063          	bgeu	s3,s6,8000415e <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80004122:	00a9559b          	srliw	a1,s2,0xa
    80004126:	8556                	mv	a0,s5
    80004128:	875ff0ef          	jal	8000399c <bmap>
    8000412c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004130:	c59d                	beqz	a1,8000415e <writei+0xbe>
    bp = bread(ip->dev, addr);
    80004132:	000aa503          	lw	a0,0(s5)
    80004136:	ce2ff0ef          	jal	80003618 <bread>
    8000413a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000413c:	3ff97713          	andi	a4,s2,1023
    80004140:	40ec87bb          	subw	a5,s9,a4
    80004144:	413b06bb          	subw	a3,s6,s3
    80004148:	8d3e                	mv	s10,a5
    8000414a:	2781                	sext.w	a5,a5
    8000414c:	0006861b          	sext.w	a2,a3
    80004150:	f8f67ee3          	bgeu	a2,a5,800040ec <writei+0x4c>
    80004154:	8d36                	mv	s10,a3
    80004156:	bf59                	j	800040ec <writei+0x4c>
      brelse(bp);
    80004158:	8526                	mv	a0,s1
    8000415a:	dc6ff0ef          	jal	80003720 <brelse>
  }

  if(off > ip->size)
    8000415e:	04caa783          	lw	a5,76(s5)
    80004162:	0327fa63          	bgeu	a5,s2,80004196 <writei+0xf6>
    ip->size = off;
    80004166:	052aa623          	sw	s2,76(s5)
    8000416a:	64e6                	ld	s1,88(sp)
    8000416c:	7c02                	ld	s8,32(sp)
    8000416e:	6ce2                	ld	s9,24(sp)
    80004170:	6d42                	ld	s10,16(sp)
    80004172:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004174:	8556                	mv	a0,s5
    80004176:	b27ff0ef          	jal	80003c9c <iupdate>

  return tot;
    8000417a:	0009851b          	sext.w	a0,s3
    8000417e:	69a6                	ld	s3,72(sp)
}
    80004180:	70a6                	ld	ra,104(sp)
    80004182:	7406                	ld	s0,96(sp)
    80004184:	6946                	ld	s2,80(sp)
    80004186:	6a06                	ld	s4,64(sp)
    80004188:	7ae2                	ld	s5,56(sp)
    8000418a:	7b42                	ld	s6,48(sp)
    8000418c:	7ba2                	ld	s7,40(sp)
    8000418e:	6165                	addi	sp,sp,112
    80004190:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004192:	89da                	mv	s3,s6
    80004194:	b7c5                	j	80004174 <writei+0xd4>
    80004196:	64e6                	ld	s1,88(sp)
    80004198:	7c02                	ld	s8,32(sp)
    8000419a:	6ce2                	ld	s9,24(sp)
    8000419c:	6d42                	ld	s10,16(sp)
    8000419e:	6da2                	ld	s11,8(sp)
    800041a0:	bfd1                	j	80004174 <writei+0xd4>
    return -1;
    800041a2:	557d                	li	a0,-1
}
    800041a4:	8082                	ret
    return -1;
    800041a6:	557d                	li	a0,-1
    800041a8:	bfe1                	j	80004180 <writei+0xe0>
    return -1;
    800041aa:	557d                	li	a0,-1
    800041ac:	bfd1                	j	80004180 <writei+0xe0>

00000000800041ae <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800041ae:	1141                	addi	sp,sp,-16
    800041b0:	e406                	sd	ra,8(sp)
    800041b2:	e022                	sd	s0,0(sp)
    800041b4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041b6:	4639                	li	a2,14
    800041b8:	bddfc0ef          	jal	80000d94 <strncmp>
}
    800041bc:	60a2                	ld	ra,8(sp)
    800041be:	6402                	ld	s0,0(sp)
    800041c0:	0141                	addi	sp,sp,16
    800041c2:	8082                	ret

00000000800041c4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041c4:	7139                	addi	sp,sp,-64
    800041c6:	fc06                	sd	ra,56(sp)
    800041c8:	f822                	sd	s0,48(sp)
    800041ca:	f426                	sd	s1,40(sp)
    800041cc:	f04a                	sd	s2,32(sp)
    800041ce:	ec4e                	sd	s3,24(sp)
    800041d0:	e852                	sd	s4,16(sp)
    800041d2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041d4:	04451703          	lh	a4,68(a0)
    800041d8:	4785                	li	a5,1
    800041da:	00f71a63          	bne	a4,a5,800041ee <dirlookup+0x2a>
    800041de:	892a                	mv	s2,a0
    800041e0:	89ae                	mv	s3,a1
    800041e2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041e4:	457c                	lw	a5,76(a0)
    800041e6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041e8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ea:	e39d                	bnez	a5,80004210 <dirlookup+0x4c>
    800041ec:	a095                	j	80004250 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800041ee:	00004517          	auipc	a0,0x4
    800041f2:	43a50513          	addi	a0,a0,1082 # 80008628 <etext+0x628>
    800041f6:	d9efc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    800041fa:	00004517          	auipc	a0,0x4
    800041fe:	44650513          	addi	a0,a0,1094 # 80008640 <etext+0x640>
    80004202:	d92fc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004206:	24c1                	addiw	s1,s1,16
    80004208:	04c92783          	lw	a5,76(s2)
    8000420c:	04f4f163          	bgeu	s1,a5,8000424e <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004210:	4741                	li	a4,16
    80004212:	86a6                	mv	a3,s1
    80004214:	fc040613          	addi	a2,s0,-64
    80004218:	4581                	li	a1,0
    8000421a:	854a                	mv	a0,s2
    8000421c:	d89ff0ef          	jal	80003fa4 <readi>
    80004220:	47c1                	li	a5,16
    80004222:	fcf51ce3          	bne	a0,a5,800041fa <dirlookup+0x36>
    if(de.inum == 0)
    80004226:	fc045783          	lhu	a5,-64(s0)
    8000422a:	dff1                	beqz	a5,80004206 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    8000422c:	fc240593          	addi	a1,s0,-62
    80004230:	854e                	mv	a0,s3
    80004232:	f7dff0ef          	jal	800041ae <namecmp>
    80004236:	f961                	bnez	a0,80004206 <dirlookup+0x42>
      if(poff)
    80004238:	000a0463          	beqz	s4,80004240 <dirlookup+0x7c>
        *poff = off;
    8000423c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004240:	fc045583          	lhu	a1,-64(s0)
    80004244:	00092503          	lw	a0,0(s2)
    80004248:	829ff0ef          	jal	80003a70 <iget>
    8000424c:	a011                	j	80004250 <dirlookup+0x8c>
  return 0;
    8000424e:	4501                	li	a0,0
}
    80004250:	70e2                	ld	ra,56(sp)
    80004252:	7442                	ld	s0,48(sp)
    80004254:	74a2                	ld	s1,40(sp)
    80004256:	7902                	ld	s2,32(sp)
    80004258:	69e2                	ld	s3,24(sp)
    8000425a:	6a42                	ld	s4,16(sp)
    8000425c:	6121                	addi	sp,sp,64
    8000425e:	8082                	ret

0000000080004260 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004260:	711d                	addi	sp,sp,-96
    80004262:	ec86                	sd	ra,88(sp)
    80004264:	e8a2                	sd	s0,80(sp)
    80004266:	e4a6                	sd	s1,72(sp)
    80004268:	e0ca                	sd	s2,64(sp)
    8000426a:	fc4e                	sd	s3,56(sp)
    8000426c:	f852                	sd	s4,48(sp)
    8000426e:	f456                	sd	s5,40(sp)
    80004270:	f05a                	sd	s6,32(sp)
    80004272:	ec5e                	sd	s7,24(sp)
    80004274:	e862                	sd	s8,16(sp)
    80004276:	e466                	sd	s9,8(sp)
    80004278:	1080                	addi	s0,sp,96
    8000427a:	84aa                	mv	s1,a0
    8000427c:	8b2e                	mv	s6,a1
    8000427e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004280:	00054703          	lbu	a4,0(a0)
    80004284:	02f00793          	li	a5,47
    80004288:	00f70e63          	beq	a4,a5,800042a4 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000428c:	ebafd0ef          	jal	80001946 <myproc>
    80004290:	15053503          	ld	a0,336(a0)
    80004294:	a87ff0ef          	jal	80003d1a <idup>
    80004298:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000429a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000429e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800042a0:	4b85                	li	s7,1
    800042a2:	a871                	j	8000433e <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800042a4:	4585                	li	a1,1
    800042a6:	4505                	li	a0,1
    800042a8:	fc8ff0ef          	jal	80003a70 <iget>
    800042ac:	8a2a                	mv	s4,a0
    800042ae:	b7f5                	j	8000429a <namex+0x3a>
      iunlockput(ip);
    800042b0:	8552                	mv	a0,s4
    800042b2:	ca9ff0ef          	jal	80003f5a <iunlockput>
      return 0;
    800042b6:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042b8:	8552                	mv	a0,s4
    800042ba:	60e6                	ld	ra,88(sp)
    800042bc:	6446                	ld	s0,80(sp)
    800042be:	64a6                	ld	s1,72(sp)
    800042c0:	6906                	ld	s2,64(sp)
    800042c2:	79e2                	ld	s3,56(sp)
    800042c4:	7a42                	ld	s4,48(sp)
    800042c6:	7aa2                	ld	s5,40(sp)
    800042c8:	7b02                	ld	s6,32(sp)
    800042ca:	6be2                	ld	s7,24(sp)
    800042cc:	6c42                	ld	s8,16(sp)
    800042ce:	6ca2                	ld	s9,8(sp)
    800042d0:	6125                	addi	sp,sp,96
    800042d2:	8082                	ret
      iunlock(ip);
    800042d4:	8552                	mv	a0,s4
    800042d6:	b29ff0ef          	jal	80003dfe <iunlock>
      return ip;
    800042da:	bff9                	j	800042b8 <namex+0x58>
      iunlockput(ip);
    800042dc:	8552                	mv	a0,s4
    800042de:	c7dff0ef          	jal	80003f5a <iunlockput>
      return 0;
    800042e2:	8a4e                	mv	s4,s3
    800042e4:	bfd1                	j	800042b8 <namex+0x58>
  len = path - s;
    800042e6:	40998633          	sub	a2,s3,s1
    800042ea:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800042ee:	099c5063          	bge	s8,s9,8000436e <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800042f2:	4639                	li	a2,14
    800042f4:	85a6                	mv	a1,s1
    800042f6:	8556                	mv	a0,s5
    800042f8:	a2dfc0ef          	jal	80000d24 <memmove>
    800042fc:	84ce                	mv	s1,s3
  while(*path == '/')
    800042fe:	0004c783          	lbu	a5,0(s1)
    80004302:	01279763          	bne	a5,s2,80004310 <namex+0xb0>
    path++;
    80004306:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004308:	0004c783          	lbu	a5,0(s1)
    8000430c:	ff278de3          	beq	a5,s2,80004306 <namex+0xa6>
    ilock(ip);
    80004310:	8552                	mv	a0,s4
    80004312:	a3fff0ef          	jal	80003d50 <ilock>
    if(ip->type != T_DIR){
    80004316:	044a1783          	lh	a5,68(s4)
    8000431a:	f9779be3          	bne	a5,s7,800042b0 <namex+0x50>
    if(nameiparent && *path == '\0'){
    8000431e:	000b0563          	beqz	s6,80004328 <namex+0xc8>
    80004322:	0004c783          	lbu	a5,0(s1)
    80004326:	d7dd                	beqz	a5,800042d4 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004328:	4601                	li	a2,0
    8000432a:	85d6                	mv	a1,s5
    8000432c:	8552                	mv	a0,s4
    8000432e:	e97ff0ef          	jal	800041c4 <dirlookup>
    80004332:	89aa                	mv	s3,a0
    80004334:	d545                	beqz	a0,800042dc <namex+0x7c>
    iunlockput(ip);
    80004336:	8552                	mv	a0,s4
    80004338:	c23ff0ef          	jal	80003f5a <iunlockput>
    ip = next;
    8000433c:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000433e:	0004c783          	lbu	a5,0(s1)
    80004342:	01279763          	bne	a5,s2,80004350 <namex+0xf0>
    path++;
    80004346:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004348:	0004c783          	lbu	a5,0(s1)
    8000434c:	ff278de3          	beq	a5,s2,80004346 <namex+0xe6>
  if(*path == 0)
    80004350:	cb8d                	beqz	a5,80004382 <namex+0x122>
  while(*path != '/' && *path != 0)
    80004352:	0004c783          	lbu	a5,0(s1)
    80004356:	89a6                	mv	s3,s1
  len = path - s;
    80004358:	4c81                	li	s9,0
    8000435a:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000435c:	01278963          	beq	a5,s2,8000436e <namex+0x10e>
    80004360:	d3d9                	beqz	a5,800042e6 <namex+0x86>
    path++;
    80004362:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004364:	0009c783          	lbu	a5,0(s3)
    80004368:	ff279ce3          	bne	a5,s2,80004360 <namex+0x100>
    8000436c:	bfad                	j	800042e6 <namex+0x86>
    memmove(name, s, len);
    8000436e:	2601                	sext.w	a2,a2
    80004370:	85a6                	mv	a1,s1
    80004372:	8556                	mv	a0,s5
    80004374:	9b1fc0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80004378:	9cd6                	add	s9,s9,s5
    8000437a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000437e:	84ce                	mv	s1,s3
    80004380:	bfbd                	j	800042fe <namex+0x9e>
  if(nameiparent){
    80004382:	f20b0be3          	beqz	s6,800042b8 <namex+0x58>
    iput(ip);
    80004386:	8552                	mv	a0,s4
    80004388:	b4bff0ef          	jal	80003ed2 <iput>
    return 0;
    8000438c:	4a01                	li	s4,0
    8000438e:	b72d                	j	800042b8 <namex+0x58>

0000000080004390 <dirlink>:
{
    80004390:	7139                	addi	sp,sp,-64
    80004392:	fc06                	sd	ra,56(sp)
    80004394:	f822                	sd	s0,48(sp)
    80004396:	f04a                	sd	s2,32(sp)
    80004398:	ec4e                	sd	s3,24(sp)
    8000439a:	e852                	sd	s4,16(sp)
    8000439c:	0080                	addi	s0,sp,64
    8000439e:	892a                	mv	s2,a0
    800043a0:	8a2e                	mv	s4,a1
    800043a2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043a4:	4601                	li	a2,0
    800043a6:	e1fff0ef          	jal	800041c4 <dirlookup>
    800043aa:	e535                	bnez	a0,80004416 <dirlink+0x86>
    800043ac:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043ae:	04c92483          	lw	s1,76(s2)
    800043b2:	c48d                	beqz	s1,800043dc <dirlink+0x4c>
    800043b4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043b6:	4741                	li	a4,16
    800043b8:	86a6                	mv	a3,s1
    800043ba:	fc040613          	addi	a2,s0,-64
    800043be:	4581                	li	a1,0
    800043c0:	854a                	mv	a0,s2
    800043c2:	be3ff0ef          	jal	80003fa4 <readi>
    800043c6:	47c1                	li	a5,16
    800043c8:	04f51b63          	bne	a0,a5,8000441e <dirlink+0x8e>
    if(de.inum == 0)
    800043cc:	fc045783          	lhu	a5,-64(s0)
    800043d0:	c791                	beqz	a5,800043dc <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043d2:	24c1                	addiw	s1,s1,16
    800043d4:	04c92783          	lw	a5,76(s2)
    800043d8:	fcf4efe3          	bltu	s1,a5,800043b6 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800043dc:	4639                	li	a2,14
    800043de:	85d2                	mv	a1,s4
    800043e0:	fc240513          	addi	a0,s0,-62
    800043e4:	9e7fc0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    800043e8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043ec:	4741                	li	a4,16
    800043ee:	86a6                	mv	a3,s1
    800043f0:	fc040613          	addi	a2,s0,-64
    800043f4:	4581                	li	a1,0
    800043f6:	854a                	mv	a0,s2
    800043f8:	ca9ff0ef          	jal	800040a0 <writei>
    800043fc:	1541                	addi	a0,a0,-16
    800043fe:	00a03533          	snez	a0,a0
    80004402:	40a00533          	neg	a0,a0
    80004406:	74a2                	ld	s1,40(sp)
}
    80004408:	70e2                	ld	ra,56(sp)
    8000440a:	7442                	ld	s0,48(sp)
    8000440c:	7902                	ld	s2,32(sp)
    8000440e:	69e2                	ld	s3,24(sp)
    80004410:	6a42                	ld	s4,16(sp)
    80004412:	6121                	addi	sp,sp,64
    80004414:	8082                	ret
    iput(ip);
    80004416:	abdff0ef          	jal	80003ed2 <iput>
    return -1;
    8000441a:	557d                	li	a0,-1
    8000441c:	b7f5                	j	80004408 <dirlink+0x78>
      panic("dirlink read");
    8000441e:	00004517          	auipc	a0,0x4
    80004422:	23250513          	addi	a0,a0,562 # 80008650 <etext+0x650>
    80004426:	b6efc0ef          	jal	80000794 <panic>

000000008000442a <namei>:

struct inode*
namei(char *path)
{
    8000442a:	1101                	addi	sp,sp,-32
    8000442c:	ec06                	sd	ra,24(sp)
    8000442e:	e822                	sd	s0,16(sp)
    80004430:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004432:	fe040613          	addi	a2,s0,-32
    80004436:	4581                	li	a1,0
    80004438:	e29ff0ef          	jal	80004260 <namex>
}
    8000443c:	60e2                	ld	ra,24(sp)
    8000443e:	6442                	ld	s0,16(sp)
    80004440:	6105                	addi	sp,sp,32
    80004442:	8082                	ret

0000000080004444 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004444:	1141                	addi	sp,sp,-16
    80004446:	e406                	sd	ra,8(sp)
    80004448:	e022                	sd	s0,0(sp)
    8000444a:	0800                	addi	s0,sp,16
    8000444c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000444e:	4585                	li	a1,1
    80004450:	e11ff0ef          	jal	80004260 <namex>
}
    80004454:	60a2                	ld	ra,8(sp)
    80004456:	6402                	ld	s0,0(sp)
    80004458:	0141                	addi	sp,sp,16
    8000445a:	8082                	ret

000000008000445c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000445c:	1101                	addi	sp,sp,-32
    8000445e:	ec06                	sd	ra,24(sp)
    80004460:	e822                	sd	s0,16(sp)
    80004462:	e426                	sd	s1,8(sp)
    80004464:	e04a                	sd	s2,0(sp)
    80004466:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004468:	000e6917          	auipc	s2,0xe6
    8000446c:	d9090913          	addi	s2,s2,-624 # 800ea1f8 <log>
    80004470:	01892583          	lw	a1,24(s2)
    80004474:	02892503          	lw	a0,40(s2)
    80004478:	9a0ff0ef          	jal	80003618 <bread>
    8000447c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000447e:	02c92603          	lw	a2,44(s2)
    80004482:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004484:	00c05f63          	blez	a2,800044a2 <write_head+0x46>
    80004488:	000e6717          	auipc	a4,0xe6
    8000448c:	da070713          	addi	a4,a4,-608 # 800ea228 <log+0x30>
    80004490:	87aa                	mv	a5,a0
    80004492:	060a                	slli	a2,a2,0x2
    80004494:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004496:	4314                	lw	a3,0(a4)
    80004498:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000449a:	0711                	addi	a4,a4,4
    8000449c:	0791                	addi	a5,a5,4
    8000449e:	fec79ce3          	bne	a5,a2,80004496 <write_head+0x3a>
  }
  bwrite(buf);
    800044a2:	8526                	mv	a0,s1
    800044a4:	a4aff0ef          	jal	800036ee <bwrite>
  brelse(buf);
    800044a8:	8526                	mv	a0,s1
    800044aa:	a76ff0ef          	jal	80003720 <brelse>
}
    800044ae:	60e2                	ld	ra,24(sp)
    800044b0:	6442                	ld	s0,16(sp)
    800044b2:	64a2                	ld	s1,8(sp)
    800044b4:	6902                	ld	s2,0(sp)
    800044b6:	6105                	addi	sp,sp,32
    800044b8:	8082                	ret

00000000800044ba <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ba:	000e6797          	auipc	a5,0xe6
    800044be:	d6a7a783          	lw	a5,-662(a5) # 800ea224 <log+0x2c>
    800044c2:	08f05f63          	blez	a5,80004560 <install_trans+0xa6>
{
    800044c6:	7139                	addi	sp,sp,-64
    800044c8:	fc06                	sd	ra,56(sp)
    800044ca:	f822                	sd	s0,48(sp)
    800044cc:	f426                	sd	s1,40(sp)
    800044ce:	f04a                	sd	s2,32(sp)
    800044d0:	ec4e                	sd	s3,24(sp)
    800044d2:	e852                	sd	s4,16(sp)
    800044d4:	e456                	sd	s5,8(sp)
    800044d6:	e05a                	sd	s6,0(sp)
    800044d8:	0080                	addi	s0,sp,64
    800044da:	8b2a                	mv	s6,a0
    800044dc:	000e6a97          	auipc	s5,0xe6
    800044e0:	d4ca8a93          	addi	s5,s5,-692 # 800ea228 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044e4:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044e6:	000e6997          	auipc	s3,0xe6
    800044ea:	d1298993          	addi	s3,s3,-750 # 800ea1f8 <log>
    800044ee:	a829                	j	80004508 <install_trans+0x4e>
    brelse(lbuf);
    800044f0:	854a                	mv	a0,s2
    800044f2:	a2eff0ef          	jal	80003720 <brelse>
    brelse(dbuf);
    800044f6:	8526                	mv	a0,s1
    800044f8:	a28ff0ef          	jal	80003720 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044fc:	2a05                	addiw	s4,s4,1
    800044fe:	0a91                	addi	s5,s5,4
    80004500:	02c9a783          	lw	a5,44(s3)
    80004504:	04fa5463          	bge	s4,a5,8000454c <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004508:	0189a583          	lw	a1,24(s3)
    8000450c:	014585bb          	addw	a1,a1,s4
    80004510:	2585                	addiw	a1,a1,1
    80004512:	0289a503          	lw	a0,40(s3)
    80004516:	902ff0ef          	jal	80003618 <bread>
    8000451a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000451c:	000aa583          	lw	a1,0(s5)
    80004520:	0289a503          	lw	a0,40(s3)
    80004524:	8f4ff0ef          	jal	80003618 <bread>
    80004528:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000452a:	40000613          	li	a2,1024
    8000452e:	05890593          	addi	a1,s2,88
    80004532:	05850513          	addi	a0,a0,88
    80004536:	feefc0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000453a:	8526                	mv	a0,s1
    8000453c:	9b2ff0ef          	jal	800036ee <bwrite>
    if(recovering == 0)
    80004540:	fa0b18e3          	bnez	s6,800044f0 <install_trans+0x36>
      bunpin(dbuf);
    80004544:	8526                	mv	a0,s1
    80004546:	a96ff0ef          	jal	800037dc <bunpin>
    8000454a:	b75d                	j	800044f0 <install_trans+0x36>
}
    8000454c:	70e2                	ld	ra,56(sp)
    8000454e:	7442                	ld	s0,48(sp)
    80004550:	74a2                	ld	s1,40(sp)
    80004552:	7902                	ld	s2,32(sp)
    80004554:	69e2                	ld	s3,24(sp)
    80004556:	6a42                	ld	s4,16(sp)
    80004558:	6aa2                	ld	s5,8(sp)
    8000455a:	6b02                	ld	s6,0(sp)
    8000455c:	6121                	addi	sp,sp,64
    8000455e:	8082                	ret
    80004560:	8082                	ret

0000000080004562 <initlog>:
{
    80004562:	7179                	addi	sp,sp,-48
    80004564:	f406                	sd	ra,40(sp)
    80004566:	f022                	sd	s0,32(sp)
    80004568:	ec26                	sd	s1,24(sp)
    8000456a:	e84a                	sd	s2,16(sp)
    8000456c:	e44e                	sd	s3,8(sp)
    8000456e:	1800                	addi	s0,sp,48
    80004570:	892a                	mv	s2,a0
    80004572:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004574:	000e6497          	auipc	s1,0xe6
    80004578:	c8448493          	addi	s1,s1,-892 # 800ea1f8 <log>
    8000457c:	00004597          	auipc	a1,0x4
    80004580:	0e458593          	addi	a1,a1,228 # 80008660 <etext+0x660>
    80004584:	8526                	mv	a0,s1
    80004586:	deefc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    8000458a:	0149a583          	lw	a1,20(s3)
    8000458e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004590:	0109a783          	lw	a5,16(s3)
    80004594:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004596:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000459a:	854a                	mv	a0,s2
    8000459c:	87cff0ef          	jal	80003618 <bread>
  log.lh.n = lh->n;
    800045a0:	4d30                	lw	a2,88(a0)
    800045a2:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045a4:	00c05f63          	blez	a2,800045c2 <initlog+0x60>
    800045a8:	87aa                	mv	a5,a0
    800045aa:	000e6717          	auipc	a4,0xe6
    800045ae:	c7e70713          	addi	a4,a4,-898 # 800ea228 <log+0x30>
    800045b2:	060a                	slli	a2,a2,0x2
    800045b4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800045b6:	4ff4                	lw	a3,92(a5)
    800045b8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045ba:	0791                	addi	a5,a5,4
    800045bc:	0711                	addi	a4,a4,4
    800045be:	fec79ce3          	bne	a5,a2,800045b6 <initlog+0x54>
  brelse(buf);
    800045c2:	95eff0ef          	jal	80003720 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045c6:	4505                	li	a0,1
    800045c8:	ef3ff0ef          	jal	800044ba <install_trans>
  log.lh.n = 0;
    800045cc:	000e6797          	auipc	a5,0xe6
    800045d0:	c407ac23          	sw	zero,-936(a5) # 800ea224 <log+0x2c>
  write_head(); // clear the log
    800045d4:	e89ff0ef          	jal	8000445c <write_head>
}
    800045d8:	70a2                	ld	ra,40(sp)
    800045da:	7402                	ld	s0,32(sp)
    800045dc:	64e2                	ld	s1,24(sp)
    800045de:	6942                	ld	s2,16(sp)
    800045e0:	69a2                	ld	s3,8(sp)
    800045e2:	6145                	addi	sp,sp,48
    800045e4:	8082                	ret

00000000800045e6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045e6:	1101                	addi	sp,sp,-32
    800045e8:	ec06                	sd	ra,24(sp)
    800045ea:	e822                	sd	s0,16(sp)
    800045ec:	e426                	sd	s1,8(sp)
    800045ee:	e04a                	sd	s2,0(sp)
    800045f0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045f2:	000e6517          	auipc	a0,0xe6
    800045f6:	c0650513          	addi	a0,a0,-1018 # 800ea1f8 <log>
    800045fa:	dfafc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    800045fe:	000e6497          	auipc	s1,0xe6
    80004602:	bfa48493          	addi	s1,s1,-1030 # 800ea1f8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004606:	4979                	li	s2,30
    80004608:	a029                	j	80004612 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000460a:	85a6                	mv	a1,s1
    8000460c:	8526                	mv	a0,s1
    8000460e:	896fe0ef          	jal	800026a4 <sleep>
    if(log.committing){
    80004612:	50dc                	lw	a5,36(s1)
    80004614:	fbfd                	bnez	a5,8000460a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004616:	5098                	lw	a4,32(s1)
    80004618:	2705                	addiw	a4,a4,1
    8000461a:	0027179b          	slliw	a5,a4,0x2
    8000461e:	9fb9                	addw	a5,a5,a4
    80004620:	0017979b          	slliw	a5,a5,0x1
    80004624:	54d4                	lw	a3,44(s1)
    80004626:	9fb5                	addw	a5,a5,a3
    80004628:	00f95763          	bge	s2,a5,80004636 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000462c:	85a6                	mv	a1,s1
    8000462e:	8526                	mv	a0,s1
    80004630:	874fe0ef          	jal	800026a4 <sleep>
    80004634:	bff9                	j	80004612 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004636:	000e6517          	auipc	a0,0xe6
    8000463a:	bc250513          	addi	a0,a0,-1086 # 800ea1f8 <log>
    8000463e:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004640:	e4cfc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80004644:	60e2                	ld	ra,24(sp)
    80004646:	6442                	ld	s0,16(sp)
    80004648:	64a2                	ld	s1,8(sp)
    8000464a:	6902                	ld	s2,0(sp)
    8000464c:	6105                	addi	sp,sp,32
    8000464e:	8082                	ret

0000000080004650 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004650:	7139                	addi	sp,sp,-64
    80004652:	fc06                	sd	ra,56(sp)
    80004654:	f822                	sd	s0,48(sp)
    80004656:	f426                	sd	s1,40(sp)
    80004658:	f04a                	sd	s2,32(sp)
    8000465a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000465c:	000e6497          	auipc	s1,0xe6
    80004660:	b9c48493          	addi	s1,s1,-1124 # 800ea1f8 <log>
    80004664:	8526                	mv	a0,s1
    80004666:	d8efc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    8000466a:	509c                	lw	a5,32(s1)
    8000466c:	37fd                	addiw	a5,a5,-1
    8000466e:	0007891b          	sext.w	s2,a5
    80004672:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004674:	50dc                	lw	a5,36(s1)
    80004676:	ef9d                	bnez	a5,800046b4 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80004678:	04091763          	bnez	s2,800046c6 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000467c:	000e6497          	auipc	s1,0xe6
    80004680:	b7c48493          	addi	s1,s1,-1156 # 800ea1f8 <log>
    80004684:	4785                	li	a5,1
    80004686:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004688:	8526                	mv	a0,s1
    8000468a:	e02fc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000468e:	54dc                	lw	a5,44(s1)
    80004690:	04f04b63          	bgtz	a5,800046e6 <end_op+0x96>
    acquire(&log.lock);
    80004694:	000e6497          	auipc	s1,0xe6
    80004698:	b6448493          	addi	s1,s1,-1180 # 800ea1f8 <log>
    8000469c:	8526                	mv	a0,s1
    8000469e:	d56fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    800046a2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800046a6:	8526                	mv	a0,s1
    800046a8:	848fe0ef          	jal	800026f0 <wakeup>
    release(&log.lock);
    800046ac:	8526                	mv	a0,s1
    800046ae:	ddefc0ef          	jal	80000c8c <release>
}
    800046b2:	a025                	j	800046da <end_op+0x8a>
    800046b4:	ec4e                	sd	s3,24(sp)
    800046b6:	e852                	sd	s4,16(sp)
    800046b8:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800046ba:	00004517          	auipc	a0,0x4
    800046be:	fae50513          	addi	a0,a0,-82 # 80008668 <etext+0x668>
    800046c2:	8d2fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    800046c6:	000e6497          	auipc	s1,0xe6
    800046ca:	b3248493          	addi	s1,s1,-1230 # 800ea1f8 <log>
    800046ce:	8526                	mv	a0,s1
    800046d0:	820fe0ef          	jal	800026f0 <wakeup>
  release(&log.lock);
    800046d4:	8526                	mv	a0,s1
    800046d6:	db6fc0ef          	jal	80000c8c <release>
}
    800046da:	70e2                	ld	ra,56(sp)
    800046dc:	7442                	ld	s0,48(sp)
    800046de:	74a2                	ld	s1,40(sp)
    800046e0:	7902                	ld	s2,32(sp)
    800046e2:	6121                	addi	sp,sp,64
    800046e4:	8082                	ret
    800046e6:	ec4e                	sd	s3,24(sp)
    800046e8:	e852                	sd	s4,16(sp)
    800046ea:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800046ec:	000e6a97          	auipc	s5,0xe6
    800046f0:	b3ca8a93          	addi	s5,s5,-1220 # 800ea228 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046f4:	000e6a17          	auipc	s4,0xe6
    800046f8:	b04a0a13          	addi	s4,s4,-1276 # 800ea1f8 <log>
    800046fc:	018a2583          	lw	a1,24(s4)
    80004700:	012585bb          	addw	a1,a1,s2
    80004704:	2585                	addiw	a1,a1,1
    80004706:	028a2503          	lw	a0,40(s4)
    8000470a:	f0ffe0ef          	jal	80003618 <bread>
    8000470e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004710:	000aa583          	lw	a1,0(s5)
    80004714:	028a2503          	lw	a0,40(s4)
    80004718:	f01fe0ef          	jal	80003618 <bread>
    8000471c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000471e:	40000613          	li	a2,1024
    80004722:	05850593          	addi	a1,a0,88
    80004726:	05848513          	addi	a0,s1,88
    8000472a:	dfafc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    8000472e:	8526                	mv	a0,s1
    80004730:	fbffe0ef          	jal	800036ee <bwrite>
    brelse(from);
    80004734:	854e                	mv	a0,s3
    80004736:	febfe0ef          	jal	80003720 <brelse>
    brelse(to);
    8000473a:	8526                	mv	a0,s1
    8000473c:	fe5fe0ef          	jal	80003720 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004740:	2905                	addiw	s2,s2,1
    80004742:	0a91                	addi	s5,s5,4
    80004744:	02ca2783          	lw	a5,44(s4)
    80004748:	faf94ae3          	blt	s2,a5,800046fc <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000474c:	d11ff0ef          	jal	8000445c <write_head>
    install_trans(0); // Now install writes to home locations
    80004750:	4501                	li	a0,0
    80004752:	d69ff0ef          	jal	800044ba <install_trans>
    log.lh.n = 0;
    80004756:	000e6797          	auipc	a5,0xe6
    8000475a:	ac07a723          	sw	zero,-1330(a5) # 800ea224 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000475e:	cffff0ef          	jal	8000445c <write_head>
    80004762:	69e2                	ld	s3,24(sp)
    80004764:	6a42                	ld	s4,16(sp)
    80004766:	6aa2                	ld	s5,8(sp)
    80004768:	b735                	j	80004694 <end_op+0x44>

000000008000476a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000476a:	1101                	addi	sp,sp,-32
    8000476c:	ec06                	sd	ra,24(sp)
    8000476e:	e822                	sd	s0,16(sp)
    80004770:	e426                	sd	s1,8(sp)
    80004772:	e04a                	sd	s2,0(sp)
    80004774:	1000                	addi	s0,sp,32
    80004776:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004778:	000e6917          	auipc	s2,0xe6
    8000477c:	a8090913          	addi	s2,s2,-1408 # 800ea1f8 <log>
    80004780:	854a                	mv	a0,s2
    80004782:	c72fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004786:	02c92603          	lw	a2,44(s2)
    8000478a:	47f5                	li	a5,29
    8000478c:	06c7c363          	blt	a5,a2,800047f2 <log_write+0x88>
    80004790:	000e6797          	auipc	a5,0xe6
    80004794:	a847a783          	lw	a5,-1404(a5) # 800ea214 <log+0x1c>
    80004798:	37fd                	addiw	a5,a5,-1
    8000479a:	04f65c63          	bge	a2,a5,800047f2 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000479e:	000e6797          	auipc	a5,0xe6
    800047a2:	a7a7a783          	lw	a5,-1414(a5) # 800ea218 <log+0x20>
    800047a6:	04f05c63          	blez	a5,800047fe <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047aa:	4781                	li	a5,0
    800047ac:	04c05f63          	blez	a2,8000480a <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047b0:	44cc                	lw	a1,12(s1)
    800047b2:	000e6717          	auipc	a4,0xe6
    800047b6:	a7670713          	addi	a4,a4,-1418 # 800ea228 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800047ba:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047bc:	4314                	lw	a3,0(a4)
    800047be:	04b68663          	beq	a3,a1,8000480a <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    800047c2:	2785                	addiw	a5,a5,1
    800047c4:	0711                	addi	a4,a4,4
    800047c6:	fef61be3          	bne	a2,a5,800047bc <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    800047ca:	0621                	addi	a2,a2,8
    800047cc:	060a                	slli	a2,a2,0x2
    800047ce:	000e6797          	auipc	a5,0xe6
    800047d2:	a2a78793          	addi	a5,a5,-1494 # 800ea1f8 <log>
    800047d6:	97b2                	add	a5,a5,a2
    800047d8:	44d8                	lw	a4,12(s1)
    800047da:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800047dc:	8526                	mv	a0,s1
    800047de:	fcbfe0ef          	jal	800037a8 <bpin>
    log.lh.n++;
    800047e2:	000e6717          	auipc	a4,0xe6
    800047e6:	a1670713          	addi	a4,a4,-1514 # 800ea1f8 <log>
    800047ea:	575c                	lw	a5,44(a4)
    800047ec:	2785                	addiw	a5,a5,1
    800047ee:	d75c                	sw	a5,44(a4)
    800047f0:	a80d                	j	80004822 <log_write+0xb8>
    panic("too big a transaction");
    800047f2:	00004517          	auipc	a0,0x4
    800047f6:	e8650513          	addi	a0,a0,-378 # 80008678 <etext+0x678>
    800047fa:	f9bfb0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    800047fe:	00004517          	auipc	a0,0x4
    80004802:	e9250513          	addi	a0,a0,-366 # 80008690 <etext+0x690>
    80004806:	f8ffb0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    8000480a:	00878693          	addi	a3,a5,8
    8000480e:	068a                	slli	a3,a3,0x2
    80004810:	000e6717          	auipc	a4,0xe6
    80004814:	9e870713          	addi	a4,a4,-1560 # 800ea1f8 <log>
    80004818:	9736                	add	a4,a4,a3
    8000481a:	44d4                	lw	a3,12(s1)
    8000481c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000481e:	faf60fe3          	beq	a2,a5,800047dc <log_write+0x72>
  }
  release(&log.lock);
    80004822:	000e6517          	auipc	a0,0xe6
    80004826:	9d650513          	addi	a0,a0,-1578 # 800ea1f8 <log>
    8000482a:	c62fc0ef          	jal	80000c8c <release>
}
    8000482e:	60e2                	ld	ra,24(sp)
    80004830:	6442                	ld	s0,16(sp)
    80004832:	64a2                	ld	s1,8(sp)
    80004834:	6902                	ld	s2,0(sp)
    80004836:	6105                	addi	sp,sp,32
    80004838:	8082                	ret

000000008000483a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000483a:	1101                	addi	sp,sp,-32
    8000483c:	ec06                	sd	ra,24(sp)
    8000483e:	e822                	sd	s0,16(sp)
    80004840:	e426                	sd	s1,8(sp)
    80004842:	e04a                	sd	s2,0(sp)
    80004844:	1000                	addi	s0,sp,32
    80004846:	84aa                	mv	s1,a0
    80004848:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000484a:	00004597          	auipc	a1,0x4
    8000484e:	e6658593          	addi	a1,a1,-410 # 800086b0 <etext+0x6b0>
    80004852:	0521                	addi	a0,a0,8
    80004854:	b20fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80004858:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000485c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004860:	0204a423          	sw	zero,40(s1)
}
    80004864:	60e2                	ld	ra,24(sp)
    80004866:	6442                	ld	s0,16(sp)
    80004868:	64a2                	ld	s1,8(sp)
    8000486a:	6902                	ld	s2,0(sp)
    8000486c:	6105                	addi	sp,sp,32
    8000486e:	8082                	ret

0000000080004870 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004870:	1101                	addi	sp,sp,-32
    80004872:	ec06                	sd	ra,24(sp)
    80004874:	e822                	sd	s0,16(sp)
    80004876:	e426                	sd	s1,8(sp)
    80004878:	e04a                	sd	s2,0(sp)
    8000487a:	1000                	addi	s0,sp,32
    8000487c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000487e:	00850913          	addi	s2,a0,8
    80004882:	854a                	mv	a0,s2
    80004884:	b70fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80004888:	409c                	lw	a5,0(s1)
    8000488a:	c799                	beqz	a5,80004898 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000488c:	85ca                	mv	a1,s2
    8000488e:	8526                	mv	a0,s1
    80004890:	e15fd0ef          	jal	800026a4 <sleep>
  while (lk->locked) {
    80004894:	409c                	lw	a5,0(s1)
    80004896:	fbfd                	bnez	a5,8000488c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004898:	4785                	li	a5,1
    8000489a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000489c:	8aafd0ef          	jal	80001946 <myproc>
    800048a0:	591c                	lw	a5,48(a0)
    800048a2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800048a4:	854a                	mv	a0,s2
    800048a6:	be6fc0ef          	jal	80000c8c <release>
}
    800048aa:	60e2                	ld	ra,24(sp)
    800048ac:	6442                	ld	s0,16(sp)
    800048ae:	64a2                	ld	s1,8(sp)
    800048b0:	6902                	ld	s2,0(sp)
    800048b2:	6105                	addi	sp,sp,32
    800048b4:	8082                	ret

00000000800048b6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048b6:	1101                	addi	sp,sp,-32
    800048b8:	ec06                	sd	ra,24(sp)
    800048ba:	e822                	sd	s0,16(sp)
    800048bc:	e426                	sd	s1,8(sp)
    800048be:	e04a                	sd	s2,0(sp)
    800048c0:	1000                	addi	s0,sp,32
    800048c2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048c4:	00850913          	addi	s2,a0,8
    800048c8:	854a                	mv	a0,s2
    800048ca:	b2afc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    800048ce:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048d2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800048d6:	8526                	mv	a0,s1
    800048d8:	e19fd0ef          	jal	800026f0 <wakeup>
  release(&lk->lk);
    800048dc:	854a                	mv	a0,s2
    800048de:	baefc0ef          	jal	80000c8c <release>
}
    800048e2:	60e2                	ld	ra,24(sp)
    800048e4:	6442                	ld	s0,16(sp)
    800048e6:	64a2                	ld	s1,8(sp)
    800048e8:	6902                	ld	s2,0(sp)
    800048ea:	6105                	addi	sp,sp,32
    800048ec:	8082                	ret

00000000800048ee <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048ee:	7179                	addi	sp,sp,-48
    800048f0:	f406                	sd	ra,40(sp)
    800048f2:	f022                	sd	s0,32(sp)
    800048f4:	ec26                	sd	s1,24(sp)
    800048f6:	e84a                	sd	s2,16(sp)
    800048f8:	1800                	addi	s0,sp,48
    800048fa:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048fc:	00850913          	addi	s2,a0,8
    80004900:	854a                	mv	a0,s2
    80004902:	af2fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004906:	409c                	lw	a5,0(s1)
    80004908:	ef81                	bnez	a5,80004920 <holdingsleep+0x32>
    8000490a:	4481                	li	s1,0
  release(&lk->lk);
    8000490c:	854a                	mv	a0,s2
    8000490e:	b7efc0ef          	jal	80000c8c <release>
  return r;
}
    80004912:	8526                	mv	a0,s1
    80004914:	70a2                	ld	ra,40(sp)
    80004916:	7402                	ld	s0,32(sp)
    80004918:	64e2                	ld	s1,24(sp)
    8000491a:	6942                	ld	s2,16(sp)
    8000491c:	6145                	addi	sp,sp,48
    8000491e:	8082                	ret
    80004920:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004922:	0284a983          	lw	s3,40(s1)
    80004926:	820fd0ef          	jal	80001946 <myproc>
    8000492a:	5904                	lw	s1,48(a0)
    8000492c:	413484b3          	sub	s1,s1,s3
    80004930:	0014b493          	seqz	s1,s1
    80004934:	69a2                	ld	s3,8(sp)
    80004936:	bfd9                	j	8000490c <holdingsleep+0x1e>

0000000080004938 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004938:	1141                	addi	sp,sp,-16
    8000493a:	e406                	sd	ra,8(sp)
    8000493c:	e022                	sd	s0,0(sp)
    8000493e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004940:	00004597          	auipc	a1,0x4
    80004944:	d8058593          	addi	a1,a1,-640 # 800086c0 <etext+0x6c0>
    80004948:	000e6517          	auipc	a0,0xe6
    8000494c:	9f850513          	addi	a0,a0,-1544 # 800ea340 <ftable>
    80004950:	a24fc0ef          	jal	80000b74 <initlock>
}
    80004954:	60a2                	ld	ra,8(sp)
    80004956:	6402                	ld	s0,0(sp)
    80004958:	0141                	addi	sp,sp,16
    8000495a:	8082                	ret

000000008000495c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000495c:	1101                	addi	sp,sp,-32
    8000495e:	ec06                	sd	ra,24(sp)
    80004960:	e822                	sd	s0,16(sp)
    80004962:	e426                	sd	s1,8(sp)
    80004964:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004966:	000e6517          	auipc	a0,0xe6
    8000496a:	9da50513          	addi	a0,a0,-1574 # 800ea340 <ftable>
    8000496e:	a86fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004972:	000e6497          	auipc	s1,0xe6
    80004976:	9e648493          	addi	s1,s1,-1562 # 800ea358 <ftable+0x18>
    8000497a:	000e7717          	auipc	a4,0xe7
    8000497e:	97e70713          	addi	a4,a4,-1666 # 800eb2f8 <disk>
    if(f->ref == 0){
    80004982:	40dc                	lw	a5,4(s1)
    80004984:	cf89                	beqz	a5,8000499e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004986:	02848493          	addi	s1,s1,40
    8000498a:	fee49ce3          	bne	s1,a4,80004982 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000498e:	000e6517          	auipc	a0,0xe6
    80004992:	9b250513          	addi	a0,a0,-1614 # 800ea340 <ftable>
    80004996:	af6fc0ef          	jal	80000c8c <release>
  return 0;
    8000499a:	4481                	li	s1,0
    8000499c:	a809                	j	800049ae <filealloc+0x52>
      f->ref = 1;
    8000499e:	4785                	li	a5,1
    800049a0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800049a2:	000e6517          	auipc	a0,0xe6
    800049a6:	99e50513          	addi	a0,a0,-1634 # 800ea340 <ftable>
    800049aa:	ae2fc0ef          	jal	80000c8c <release>
}
    800049ae:	8526                	mv	a0,s1
    800049b0:	60e2                	ld	ra,24(sp)
    800049b2:	6442                	ld	s0,16(sp)
    800049b4:	64a2                	ld	s1,8(sp)
    800049b6:	6105                	addi	sp,sp,32
    800049b8:	8082                	ret

00000000800049ba <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049ba:	1101                	addi	sp,sp,-32
    800049bc:	ec06                	sd	ra,24(sp)
    800049be:	e822                	sd	s0,16(sp)
    800049c0:	e426                	sd	s1,8(sp)
    800049c2:	1000                	addi	s0,sp,32
    800049c4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049c6:	000e6517          	auipc	a0,0xe6
    800049ca:	97a50513          	addi	a0,a0,-1670 # 800ea340 <ftable>
    800049ce:	a26fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    800049d2:	40dc                	lw	a5,4(s1)
    800049d4:	02f05063          	blez	a5,800049f4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800049d8:	2785                	addiw	a5,a5,1
    800049da:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049dc:	000e6517          	auipc	a0,0xe6
    800049e0:	96450513          	addi	a0,a0,-1692 # 800ea340 <ftable>
    800049e4:	aa8fc0ef          	jal	80000c8c <release>
  return f;
}
    800049e8:	8526                	mv	a0,s1
    800049ea:	60e2                	ld	ra,24(sp)
    800049ec:	6442                	ld	s0,16(sp)
    800049ee:	64a2                	ld	s1,8(sp)
    800049f0:	6105                	addi	sp,sp,32
    800049f2:	8082                	ret
    panic("filedup");
    800049f4:	00004517          	auipc	a0,0x4
    800049f8:	cd450513          	addi	a0,a0,-812 # 800086c8 <etext+0x6c8>
    800049fc:	d99fb0ef          	jal	80000794 <panic>

0000000080004a00 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a00:	7139                	addi	sp,sp,-64
    80004a02:	fc06                	sd	ra,56(sp)
    80004a04:	f822                	sd	s0,48(sp)
    80004a06:	f426                	sd	s1,40(sp)
    80004a08:	0080                	addi	s0,sp,64
    80004a0a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a0c:	000e6517          	auipc	a0,0xe6
    80004a10:	93450513          	addi	a0,a0,-1740 # 800ea340 <ftable>
    80004a14:	9e0fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004a18:	40dc                	lw	a5,4(s1)
    80004a1a:	04f05a63          	blez	a5,80004a6e <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004a1e:	37fd                	addiw	a5,a5,-1
    80004a20:	0007871b          	sext.w	a4,a5
    80004a24:	c0dc                	sw	a5,4(s1)
    80004a26:	04e04e63          	bgtz	a4,80004a82 <fileclose+0x82>
    80004a2a:	f04a                	sd	s2,32(sp)
    80004a2c:	ec4e                	sd	s3,24(sp)
    80004a2e:	e852                	sd	s4,16(sp)
    80004a30:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a32:	0004a903          	lw	s2,0(s1)
    80004a36:	0094ca83          	lbu	s5,9(s1)
    80004a3a:	0104ba03          	ld	s4,16(s1)
    80004a3e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a42:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a46:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a4a:	000e6517          	auipc	a0,0xe6
    80004a4e:	8f650513          	addi	a0,a0,-1802 # 800ea340 <ftable>
    80004a52:	a3afc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80004a56:	4785                	li	a5,1
    80004a58:	04f90063          	beq	s2,a5,80004a98 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a5c:	3979                	addiw	s2,s2,-2
    80004a5e:	4785                	li	a5,1
    80004a60:	0527f563          	bgeu	a5,s2,80004aaa <fileclose+0xaa>
    80004a64:	7902                	ld	s2,32(sp)
    80004a66:	69e2                	ld	s3,24(sp)
    80004a68:	6a42                	ld	s4,16(sp)
    80004a6a:	6aa2                	ld	s5,8(sp)
    80004a6c:	a00d                	j	80004a8e <fileclose+0x8e>
    80004a6e:	f04a                	sd	s2,32(sp)
    80004a70:	ec4e                	sd	s3,24(sp)
    80004a72:	e852                	sd	s4,16(sp)
    80004a74:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004a76:	00004517          	auipc	a0,0x4
    80004a7a:	c5a50513          	addi	a0,a0,-934 # 800086d0 <etext+0x6d0>
    80004a7e:	d17fb0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80004a82:	000e6517          	auipc	a0,0xe6
    80004a86:	8be50513          	addi	a0,a0,-1858 # 800ea340 <ftable>
    80004a8a:	a02fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004a8e:	70e2                	ld	ra,56(sp)
    80004a90:	7442                	ld	s0,48(sp)
    80004a92:	74a2                	ld	s1,40(sp)
    80004a94:	6121                	addi	sp,sp,64
    80004a96:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a98:	85d6                	mv	a1,s5
    80004a9a:	8552                	mv	a0,s4
    80004a9c:	336000ef          	jal	80004dd2 <pipeclose>
    80004aa0:	7902                	ld	s2,32(sp)
    80004aa2:	69e2                	ld	s3,24(sp)
    80004aa4:	6a42                	ld	s4,16(sp)
    80004aa6:	6aa2                	ld	s5,8(sp)
    80004aa8:	b7dd                	j	80004a8e <fileclose+0x8e>
    begin_op();
    80004aaa:	b3dff0ef          	jal	800045e6 <begin_op>
    iput(ff.ip);
    80004aae:	854e                	mv	a0,s3
    80004ab0:	c22ff0ef          	jal	80003ed2 <iput>
    end_op();
    80004ab4:	b9dff0ef          	jal	80004650 <end_op>
    80004ab8:	7902                	ld	s2,32(sp)
    80004aba:	69e2                	ld	s3,24(sp)
    80004abc:	6a42                	ld	s4,16(sp)
    80004abe:	6aa2                	ld	s5,8(sp)
    80004ac0:	b7f9                	j	80004a8e <fileclose+0x8e>

0000000080004ac2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ac2:	715d                	addi	sp,sp,-80
    80004ac4:	e486                	sd	ra,72(sp)
    80004ac6:	e0a2                	sd	s0,64(sp)
    80004ac8:	fc26                	sd	s1,56(sp)
    80004aca:	f44e                	sd	s3,40(sp)
    80004acc:	0880                	addi	s0,sp,80
    80004ace:	84aa                	mv	s1,a0
    80004ad0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ad2:	e75fc0ef          	jal	80001946 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ad6:	409c                	lw	a5,0(s1)
    80004ad8:	37f9                	addiw	a5,a5,-2
    80004ada:	4705                	li	a4,1
    80004adc:	04f76063          	bltu	a4,a5,80004b1c <filestat+0x5a>
    80004ae0:	f84a                	sd	s2,48(sp)
    80004ae2:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ae4:	6c88                	ld	a0,24(s1)
    80004ae6:	a6aff0ef          	jal	80003d50 <ilock>
    stati(f->ip, &st);
    80004aea:	fb840593          	addi	a1,s0,-72
    80004aee:	6c88                	ld	a0,24(s1)
    80004af0:	c8aff0ef          	jal	80003f7a <stati>
    iunlock(f->ip);
    80004af4:	6c88                	ld	a0,24(s1)
    80004af6:	b08ff0ef          	jal	80003dfe <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004afa:	46e1                	li	a3,24
    80004afc:	fb840613          	addi	a2,s0,-72
    80004b00:	85ce                	mv	a1,s3
    80004b02:	05093503          	ld	a0,80(s2)
    80004b06:	a4dfc0ef          	jal	80001552 <copyout>
    80004b0a:	41f5551b          	sraiw	a0,a0,0x1f
    80004b0e:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004b10:	60a6                	ld	ra,72(sp)
    80004b12:	6406                	ld	s0,64(sp)
    80004b14:	74e2                	ld	s1,56(sp)
    80004b16:	79a2                	ld	s3,40(sp)
    80004b18:	6161                	addi	sp,sp,80
    80004b1a:	8082                	ret
  return -1;
    80004b1c:	557d                	li	a0,-1
    80004b1e:	bfcd                	j	80004b10 <filestat+0x4e>

0000000080004b20 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b20:	7179                	addi	sp,sp,-48
    80004b22:	f406                	sd	ra,40(sp)
    80004b24:	f022                	sd	s0,32(sp)
    80004b26:	e84a                	sd	s2,16(sp)
    80004b28:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b2a:	00854783          	lbu	a5,8(a0)
    80004b2e:	cfd1                	beqz	a5,80004bca <fileread+0xaa>
    80004b30:	ec26                	sd	s1,24(sp)
    80004b32:	e44e                	sd	s3,8(sp)
    80004b34:	84aa                	mv	s1,a0
    80004b36:	89ae                	mv	s3,a1
    80004b38:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b3a:	411c                	lw	a5,0(a0)
    80004b3c:	4705                	li	a4,1
    80004b3e:	04e78363          	beq	a5,a4,80004b84 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b42:	470d                	li	a4,3
    80004b44:	04e78763          	beq	a5,a4,80004b92 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b48:	4709                	li	a4,2
    80004b4a:	06e79a63          	bne	a5,a4,80004bbe <fileread+0x9e>
    ilock(f->ip);
    80004b4e:	6d08                	ld	a0,24(a0)
    80004b50:	a00ff0ef          	jal	80003d50 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b54:	874a                	mv	a4,s2
    80004b56:	5094                	lw	a3,32(s1)
    80004b58:	864e                	mv	a2,s3
    80004b5a:	4585                	li	a1,1
    80004b5c:	6c88                	ld	a0,24(s1)
    80004b5e:	c46ff0ef          	jal	80003fa4 <readi>
    80004b62:	892a                	mv	s2,a0
    80004b64:	00a05563          	blez	a0,80004b6e <fileread+0x4e>
      f->off += r;
    80004b68:	509c                	lw	a5,32(s1)
    80004b6a:	9fa9                	addw	a5,a5,a0
    80004b6c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b6e:	6c88                	ld	a0,24(s1)
    80004b70:	a8eff0ef          	jal	80003dfe <iunlock>
    80004b74:	64e2                	ld	s1,24(sp)
    80004b76:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004b78:	854a                	mv	a0,s2
    80004b7a:	70a2                	ld	ra,40(sp)
    80004b7c:	7402                	ld	s0,32(sp)
    80004b7e:	6942                	ld	s2,16(sp)
    80004b80:	6145                	addi	sp,sp,48
    80004b82:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b84:	6908                	ld	a0,16(a0)
    80004b86:	388000ef          	jal	80004f0e <piperead>
    80004b8a:	892a                	mv	s2,a0
    80004b8c:	64e2                	ld	s1,24(sp)
    80004b8e:	69a2                	ld	s3,8(sp)
    80004b90:	b7e5                	j	80004b78 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b92:	02451783          	lh	a5,36(a0)
    80004b96:	03079693          	slli	a3,a5,0x30
    80004b9a:	92c1                	srli	a3,a3,0x30
    80004b9c:	4725                	li	a4,9
    80004b9e:	02d76863          	bltu	a4,a3,80004bce <fileread+0xae>
    80004ba2:	0792                	slli	a5,a5,0x4
    80004ba4:	000e5717          	auipc	a4,0xe5
    80004ba8:	6fc70713          	addi	a4,a4,1788 # 800ea2a0 <devsw>
    80004bac:	97ba                	add	a5,a5,a4
    80004bae:	639c                	ld	a5,0(a5)
    80004bb0:	c39d                	beqz	a5,80004bd6 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004bb2:	4505                	li	a0,1
    80004bb4:	9782                	jalr	a5
    80004bb6:	892a                	mv	s2,a0
    80004bb8:	64e2                	ld	s1,24(sp)
    80004bba:	69a2                	ld	s3,8(sp)
    80004bbc:	bf75                	j	80004b78 <fileread+0x58>
    panic("fileread");
    80004bbe:	00004517          	auipc	a0,0x4
    80004bc2:	b2250513          	addi	a0,a0,-1246 # 800086e0 <etext+0x6e0>
    80004bc6:	bcffb0ef          	jal	80000794 <panic>
    return -1;
    80004bca:	597d                	li	s2,-1
    80004bcc:	b775                	j	80004b78 <fileread+0x58>
      return -1;
    80004bce:	597d                	li	s2,-1
    80004bd0:	64e2                	ld	s1,24(sp)
    80004bd2:	69a2                	ld	s3,8(sp)
    80004bd4:	b755                	j	80004b78 <fileread+0x58>
    80004bd6:	597d                	li	s2,-1
    80004bd8:	64e2                	ld	s1,24(sp)
    80004bda:	69a2                	ld	s3,8(sp)
    80004bdc:	bf71                	j	80004b78 <fileread+0x58>

0000000080004bde <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004bde:	00954783          	lbu	a5,9(a0)
    80004be2:	10078b63          	beqz	a5,80004cf8 <filewrite+0x11a>
{
    80004be6:	715d                	addi	sp,sp,-80
    80004be8:	e486                	sd	ra,72(sp)
    80004bea:	e0a2                	sd	s0,64(sp)
    80004bec:	f84a                	sd	s2,48(sp)
    80004bee:	f052                	sd	s4,32(sp)
    80004bf0:	e85a                	sd	s6,16(sp)
    80004bf2:	0880                	addi	s0,sp,80
    80004bf4:	892a                	mv	s2,a0
    80004bf6:	8b2e                	mv	s6,a1
    80004bf8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bfa:	411c                	lw	a5,0(a0)
    80004bfc:	4705                	li	a4,1
    80004bfe:	02e78763          	beq	a5,a4,80004c2c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c02:	470d                	li	a4,3
    80004c04:	02e78863          	beq	a5,a4,80004c34 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c08:	4709                	li	a4,2
    80004c0a:	0ce79c63          	bne	a5,a4,80004ce2 <filewrite+0x104>
    80004c0e:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c10:	0ac05863          	blez	a2,80004cc0 <filewrite+0xe2>
    80004c14:	fc26                	sd	s1,56(sp)
    80004c16:	ec56                	sd	s5,24(sp)
    80004c18:	e45e                	sd	s7,8(sp)
    80004c1a:	e062                	sd	s8,0(sp)
    int i = 0;
    80004c1c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004c1e:	6b85                	lui	s7,0x1
    80004c20:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004c24:	6c05                	lui	s8,0x1
    80004c26:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004c2a:	a8b5                	j	80004ca6 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004c2c:	6908                	ld	a0,16(a0)
    80004c2e:	1fc000ef          	jal	80004e2a <pipewrite>
    80004c32:	a04d                	j	80004cd4 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c34:	02451783          	lh	a5,36(a0)
    80004c38:	03079693          	slli	a3,a5,0x30
    80004c3c:	92c1                	srli	a3,a3,0x30
    80004c3e:	4725                	li	a4,9
    80004c40:	0ad76e63          	bltu	a4,a3,80004cfc <filewrite+0x11e>
    80004c44:	0792                	slli	a5,a5,0x4
    80004c46:	000e5717          	auipc	a4,0xe5
    80004c4a:	65a70713          	addi	a4,a4,1626 # 800ea2a0 <devsw>
    80004c4e:	97ba                	add	a5,a5,a4
    80004c50:	679c                	ld	a5,8(a5)
    80004c52:	c7dd                	beqz	a5,80004d00 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004c54:	4505                	li	a0,1
    80004c56:	9782                	jalr	a5
    80004c58:	a8b5                	j	80004cd4 <filewrite+0xf6>
      if(n1 > max)
    80004c5a:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004c5e:	989ff0ef          	jal	800045e6 <begin_op>
      ilock(f->ip);
    80004c62:	01893503          	ld	a0,24(s2)
    80004c66:	8eaff0ef          	jal	80003d50 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c6a:	8756                	mv	a4,s5
    80004c6c:	02092683          	lw	a3,32(s2)
    80004c70:	01698633          	add	a2,s3,s6
    80004c74:	4585                	li	a1,1
    80004c76:	01893503          	ld	a0,24(s2)
    80004c7a:	c26ff0ef          	jal	800040a0 <writei>
    80004c7e:	84aa                	mv	s1,a0
    80004c80:	00a05763          	blez	a0,80004c8e <filewrite+0xb0>
        f->off += r;
    80004c84:	02092783          	lw	a5,32(s2)
    80004c88:	9fa9                	addw	a5,a5,a0
    80004c8a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c8e:	01893503          	ld	a0,24(s2)
    80004c92:	96cff0ef          	jal	80003dfe <iunlock>
      end_op();
    80004c96:	9bbff0ef          	jal	80004650 <end_op>

      if(r != n1){
    80004c9a:	029a9563          	bne	s5,s1,80004cc4 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004c9e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ca2:	0149da63          	bge	s3,s4,80004cb6 <filewrite+0xd8>
      int n1 = n - i;
    80004ca6:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004caa:	0004879b          	sext.w	a5,s1
    80004cae:	fafbd6e3          	bge	s7,a5,80004c5a <filewrite+0x7c>
    80004cb2:	84e2                	mv	s1,s8
    80004cb4:	b75d                	j	80004c5a <filewrite+0x7c>
    80004cb6:	74e2                	ld	s1,56(sp)
    80004cb8:	6ae2                	ld	s5,24(sp)
    80004cba:	6ba2                	ld	s7,8(sp)
    80004cbc:	6c02                	ld	s8,0(sp)
    80004cbe:	a039                	j	80004ccc <filewrite+0xee>
    int i = 0;
    80004cc0:	4981                	li	s3,0
    80004cc2:	a029                	j	80004ccc <filewrite+0xee>
    80004cc4:	74e2                	ld	s1,56(sp)
    80004cc6:	6ae2                	ld	s5,24(sp)
    80004cc8:	6ba2                	ld	s7,8(sp)
    80004cca:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004ccc:	033a1c63          	bne	s4,s3,80004d04 <filewrite+0x126>
    80004cd0:	8552                	mv	a0,s4
    80004cd2:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004cd4:	60a6                	ld	ra,72(sp)
    80004cd6:	6406                	ld	s0,64(sp)
    80004cd8:	7942                	ld	s2,48(sp)
    80004cda:	7a02                	ld	s4,32(sp)
    80004cdc:	6b42                	ld	s6,16(sp)
    80004cde:	6161                	addi	sp,sp,80
    80004ce0:	8082                	ret
    80004ce2:	fc26                	sd	s1,56(sp)
    80004ce4:	f44e                	sd	s3,40(sp)
    80004ce6:	ec56                	sd	s5,24(sp)
    80004ce8:	e45e                	sd	s7,8(sp)
    80004cea:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004cec:	00004517          	auipc	a0,0x4
    80004cf0:	a0450513          	addi	a0,a0,-1532 # 800086f0 <etext+0x6f0>
    80004cf4:	aa1fb0ef          	jal	80000794 <panic>
    return -1;
    80004cf8:	557d                	li	a0,-1
}
    80004cfa:	8082                	ret
      return -1;
    80004cfc:	557d                	li	a0,-1
    80004cfe:	bfd9                	j	80004cd4 <filewrite+0xf6>
    80004d00:	557d                	li	a0,-1
    80004d02:	bfc9                	j	80004cd4 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004d04:	557d                	li	a0,-1
    80004d06:	79a2                	ld	s3,40(sp)
    80004d08:	b7f1                	j	80004cd4 <filewrite+0xf6>

0000000080004d0a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d0a:	7179                	addi	sp,sp,-48
    80004d0c:	f406                	sd	ra,40(sp)
    80004d0e:	f022                	sd	s0,32(sp)
    80004d10:	ec26                	sd	s1,24(sp)
    80004d12:	e052                	sd	s4,0(sp)
    80004d14:	1800                	addi	s0,sp,48
    80004d16:	84aa                	mv	s1,a0
    80004d18:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d1a:	0005b023          	sd	zero,0(a1)
    80004d1e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d22:	c3bff0ef          	jal	8000495c <filealloc>
    80004d26:	e088                	sd	a0,0(s1)
    80004d28:	c549                	beqz	a0,80004db2 <pipealloc+0xa8>
    80004d2a:	c33ff0ef          	jal	8000495c <filealloc>
    80004d2e:	00aa3023          	sd	a0,0(s4)
    80004d32:	cd25                	beqz	a0,80004daa <pipealloc+0xa0>
    80004d34:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d36:	deffb0ef          	jal	80000b24 <kalloc>
    80004d3a:	892a                	mv	s2,a0
    80004d3c:	c12d                	beqz	a0,80004d9e <pipealloc+0x94>
    80004d3e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004d40:	4985                	li	s3,1
    80004d42:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d46:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d4a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d4e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d52:	00004597          	auipc	a1,0x4
    80004d56:	9ae58593          	addi	a1,a1,-1618 # 80008700 <etext+0x700>
    80004d5a:	e1bfb0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    80004d5e:	609c                	ld	a5,0(s1)
    80004d60:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d64:	609c                	ld	a5,0(s1)
    80004d66:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d6a:	609c                	ld	a5,0(s1)
    80004d6c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d70:	609c                	ld	a5,0(s1)
    80004d72:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d76:	000a3783          	ld	a5,0(s4)
    80004d7a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d7e:	000a3783          	ld	a5,0(s4)
    80004d82:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d86:	000a3783          	ld	a5,0(s4)
    80004d8a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d8e:	000a3783          	ld	a5,0(s4)
    80004d92:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d96:	4501                	li	a0,0
    80004d98:	6942                	ld	s2,16(sp)
    80004d9a:	69a2                	ld	s3,8(sp)
    80004d9c:	a01d                	j	80004dc2 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d9e:	6088                	ld	a0,0(s1)
    80004da0:	c119                	beqz	a0,80004da6 <pipealloc+0x9c>
    80004da2:	6942                	ld	s2,16(sp)
    80004da4:	a029                	j	80004dae <pipealloc+0xa4>
    80004da6:	6942                	ld	s2,16(sp)
    80004da8:	a029                	j	80004db2 <pipealloc+0xa8>
    80004daa:	6088                	ld	a0,0(s1)
    80004dac:	c10d                	beqz	a0,80004dce <pipealloc+0xc4>
    fileclose(*f0);
    80004dae:	c53ff0ef          	jal	80004a00 <fileclose>
  if(*f1)
    80004db2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004db6:	557d                	li	a0,-1
  if(*f1)
    80004db8:	c789                	beqz	a5,80004dc2 <pipealloc+0xb8>
    fileclose(*f1);
    80004dba:	853e                	mv	a0,a5
    80004dbc:	c45ff0ef          	jal	80004a00 <fileclose>
  return -1;
    80004dc0:	557d                	li	a0,-1
}
    80004dc2:	70a2                	ld	ra,40(sp)
    80004dc4:	7402                	ld	s0,32(sp)
    80004dc6:	64e2                	ld	s1,24(sp)
    80004dc8:	6a02                	ld	s4,0(sp)
    80004dca:	6145                	addi	sp,sp,48
    80004dcc:	8082                	ret
  return -1;
    80004dce:	557d                	li	a0,-1
    80004dd0:	bfcd                	j	80004dc2 <pipealloc+0xb8>

0000000080004dd2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004dd2:	1101                	addi	sp,sp,-32
    80004dd4:	ec06                	sd	ra,24(sp)
    80004dd6:	e822                	sd	s0,16(sp)
    80004dd8:	e426                	sd	s1,8(sp)
    80004dda:	e04a                	sd	s2,0(sp)
    80004ddc:	1000                	addi	s0,sp,32
    80004dde:	84aa                	mv	s1,a0
    80004de0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004de2:	e13fb0ef          	jal	80000bf4 <acquire>
  if(writable){
    80004de6:	02090763          	beqz	s2,80004e14 <pipeclose+0x42>
    pi->writeopen = 0;
    80004dea:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004dee:	21848513          	addi	a0,s1,536
    80004df2:	8fffd0ef          	jal	800026f0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004df6:	2204b783          	ld	a5,544(s1)
    80004dfa:	e785                	bnez	a5,80004e22 <pipeclose+0x50>
    release(&pi->lock);
    80004dfc:	8526                	mv	a0,s1
    80004dfe:	e8ffb0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    80004e02:	8526                	mv	a0,s1
    80004e04:	c3ffb0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004e08:	60e2                	ld	ra,24(sp)
    80004e0a:	6442                	ld	s0,16(sp)
    80004e0c:	64a2                	ld	s1,8(sp)
    80004e0e:	6902                	ld	s2,0(sp)
    80004e10:	6105                	addi	sp,sp,32
    80004e12:	8082                	ret
    pi->readopen = 0;
    80004e14:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e18:	21c48513          	addi	a0,s1,540
    80004e1c:	8d5fd0ef          	jal	800026f0 <wakeup>
    80004e20:	bfd9                	j	80004df6 <pipeclose+0x24>
    release(&pi->lock);
    80004e22:	8526                	mv	a0,s1
    80004e24:	e69fb0ef          	jal	80000c8c <release>
}
    80004e28:	b7c5                	j	80004e08 <pipeclose+0x36>

0000000080004e2a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e2a:	711d                	addi	sp,sp,-96
    80004e2c:	ec86                	sd	ra,88(sp)
    80004e2e:	e8a2                	sd	s0,80(sp)
    80004e30:	e4a6                	sd	s1,72(sp)
    80004e32:	e0ca                	sd	s2,64(sp)
    80004e34:	fc4e                	sd	s3,56(sp)
    80004e36:	f852                	sd	s4,48(sp)
    80004e38:	f456                	sd	s5,40(sp)
    80004e3a:	1080                	addi	s0,sp,96
    80004e3c:	84aa                	mv	s1,a0
    80004e3e:	8aae                	mv	s5,a1
    80004e40:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e42:	b05fc0ef          	jal	80001946 <myproc>
    80004e46:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e48:	8526                	mv	a0,s1
    80004e4a:	dabfb0ef          	jal	80000bf4 <acquire>
  while(i < n){
    80004e4e:	0b405a63          	blez	s4,80004f02 <pipewrite+0xd8>
    80004e52:	f05a                	sd	s6,32(sp)
    80004e54:	ec5e                	sd	s7,24(sp)
    80004e56:	e862                	sd	s8,16(sp)
  int i = 0;
    80004e58:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e5a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e5c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e60:	21c48b93          	addi	s7,s1,540
    80004e64:	a81d                	j	80004e9a <pipewrite+0x70>
      release(&pi->lock);
    80004e66:	8526                	mv	a0,s1
    80004e68:	e25fb0ef          	jal	80000c8c <release>
      return -1;
    80004e6c:	597d                	li	s2,-1
    80004e6e:	7b02                	ld	s6,32(sp)
    80004e70:	6be2                	ld	s7,24(sp)
    80004e72:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e74:	854a                	mv	a0,s2
    80004e76:	60e6                	ld	ra,88(sp)
    80004e78:	6446                	ld	s0,80(sp)
    80004e7a:	64a6                	ld	s1,72(sp)
    80004e7c:	6906                	ld	s2,64(sp)
    80004e7e:	79e2                	ld	s3,56(sp)
    80004e80:	7a42                	ld	s4,48(sp)
    80004e82:	7aa2                	ld	s5,40(sp)
    80004e84:	6125                	addi	sp,sp,96
    80004e86:	8082                	ret
      wakeup(&pi->nread);
    80004e88:	8562                	mv	a0,s8
    80004e8a:	867fd0ef          	jal	800026f0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e8e:	85a6                	mv	a1,s1
    80004e90:	855e                	mv	a0,s7
    80004e92:	813fd0ef          	jal	800026a4 <sleep>
  while(i < n){
    80004e96:	05495b63          	bge	s2,s4,80004eec <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004e9a:	2204a783          	lw	a5,544(s1)
    80004e9e:	d7e1                	beqz	a5,80004e66 <pipewrite+0x3c>
    80004ea0:	854e                	mv	a0,s3
    80004ea2:	a87fd0ef          	jal	80002928 <killed>
    80004ea6:	f161                	bnez	a0,80004e66 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ea8:	2184a783          	lw	a5,536(s1)
    80004eac:	21c4a703          	lw	a4,540(s1)
    80004eb0:	2007879b          	addiw	a5,a5,512
    80004eb4:	fcf70ae3          	beq	a4,a5,80004e88 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004eb8:	4685                	li	a3,1
    80004eba:	01590633          	add	a2,s2,s5
    80004ebe:	faf40593          	addi	a1,s0,-81
    80004ec2:	0509b503          	ld	a0,80(s3)
    80004ec6:	f62fc0ef          	jal	80001628 <copyin>
    80004eca:	03650e63          	beq	a0,s6,80004f06 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ece:	21c4a783          	lw	a5,540(s1)
    80004ed2:	0017871b          	addiw	a4,a5,1
    80004ed6:	20e4ae23          	sw	a4,540(s1)
    80004eda:	1ff7f793          	andi	a5,a5,511
    80004ede:	97a6                	add	a5,a5,s1
    80004ee0:	faf44703          	lbu	a4,-81(s0)
    80004ee4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ee8:	2905                	addiw	s2,s2,1
    80004eea:	b775                	j	80004e96 <pipewrite+0x6c>
    80004eec:	7b02                	ld	s6,32(sp)
    80004eee:	6be2                	ld	s7,24(sp)
    80004ef0:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004ef2:	21848513          	addi	a0,s1,536
    80004ef6:	ffafd0ef          	jal	800026f0 <wakeup>
  release(&pi->lock);
    80004efa:	8526                	mv	a0,s1
    80004efc:	d91fb0ef          	jal	80000c8c <release>
  return i;
    80004f00:	bf95                	j	80004e74 <pipewrite+0x4a>
  int i = 0;
    80004f02:	4901                	li	s2,0
    80004f04:	b7fd                	j	80004ef2 <pipewrite+0xc8>
    80004f06:	7b02                	ld	s6,32(sp)
    80004f08:	6be2                	ld	s7,24(sp)
    80004f0a:	6c42                	ld	s8,16(sp)
    80004f0c:	b7dd                	j	80004ef2 <pipewrite+0xc8>

0000000080004f0e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f0e:	715d                	addi	sp,sp,-80
    80004f10:	e486                	sd	ra,72(sp)
    80004f12:	e0a2                	sd	s0,64(sp)
    80004f14:	fc26                	sd	s1,56(sp)
    80004f16:	f84a                	sd	s2,48(sp)
    80004f18:	f44e                	sd	s3,40(sp)
    80004f1a:	f052                	sd	s4,32(sp)
    80004f1c:	ec56                	sd	s5,24(sp)
    80004f1e:	0880                	addi	s0,sp,80
    80004f20:	84aa                	mv	s1,a0
    80004f22:	892e                	mv	s2,a1
    80004f24:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f26:	a21fc0ef          	jal	80001946 <myproc>
    80004f2a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f2c:	8526                	mv	a0,s1
    80004f2e:	cc7fb0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f32:	2184a703          	lw	a4,536(s1)
    80004f36:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f3a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f3e:	02f71563          	bne	a4,a5,80004f68 <piperead+0x5a>
    80004f42:	2244a783          	lw	a5,548(s1)
    80004f46:	cb85                	beqz	a5,80004f76 <piperead+0x68>
    if(killed(pr)){
    80004f48:	8552                	mv	a0,s4
    80004f4a:	9dffd0ef          	jal	80002928 <killed>
    80004f4e:	ed19                	bnez	a0,80004f6c <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f50:	85a6                	mv	a1,s1
    80004f52:	854e                	mv	a0,s3
    80004f54:	f50fd0ef          	jal	800026a4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f58:	2184a703          	lw	a4,536(s1)
    80004f5c:	21c4a783          	lw	a5,540(s1)
    80004f60:	fef701e3          	beq	a4,a5,80004f42 <piperead+0x34>
    80004f64:	e85a                	sd	s6,16(sp)
    80004f66:	a809                	j	80004f78 <piperead+0x6a>
    80004f68:	e85a                	sd	s6,16(sp)
    80004f6a:	a039                	j	80004f78 <piperead+0x6a>
      release(&pi->lock);
    80004f6c:	8526                	mv	a0,s1
    80004f6e:	d1ffb0ef          	jal	80000c8c <release>
      return -1;
    80004f72:	59fd                	li	s3,-1
    80004f74:	a8b1                	j	80004fd0 <piperead+0xc2>
    80004f76:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f78:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f7a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f7c:	05505263          	blez	s5,80004fc0 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004f80:	2184a783          	lw	a5,536(s1)
    80004f84:	21c4a703          	lw	a4,540(s1)
    80004f88:	02f70c63          	beq	a4,a5,80004fc0 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f8c:	0017871b          	addiw	a4,a5,1
    80004f90:	20e4ac23          	sw	a4,536(s1)
    80004f94:	1ff7f793          	andi	a5,a5,511
    80004f98:	97a6                	add	a5,a5,s1
    80004f9a:	0187c783          	lbu	a5,24(a5)
    80004f9e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fa2:	4685                	li	a3,1
    80004fa4:	fbf40613          	addi	a2,s0,-65
    80004fa8:	85ca                	mv	a1,s2
    80004faa:	050a3503          	ld	a0,80(s4)
    80004fae:	da4fc0ef          	jal	80001552 <copyout>
    80004fb2:	01650763          	beq	a0,s6,80004fc0 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fb6:	2985                	addiw	s3,s3,1
    80004fb8:	0905                	addi	s2,s2,1
    80004fba:	fd3a93e3          	bne	s5,s3,80004f80 <piperead+0x72>
    80004fbe:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004fc0:	21c48513          	addi	a0,s1,540
    80004fc4:	f2cfd0ef          	jal	800026f0 <wakeup>
  release(&pi->lock);
    80004fc8:	8526                	mv	a0,s1
    80004fca:	cc3fb0ef          	jal	80000c8c <release>
    80004fce:	6b42                	ld	s6,16(sp)
  return i;
}
    80004fd0:	854e                	mv	a0,s3
    80004fd2:	60a6                	ld	ra,72(sp)
    80004fd4:	6406                	ld	s0,64(sp)
    80004fd6:	74e2                	ld	s1,56(sp)
    80004fd8:	7942                	ld	s2,48(sp)
    80004fda:	79a2                	ld	s3,40(sp)
    80004fdc:	7a02                	ld	s4,32(sp)
    80004fde:	6ae2                	ld	s5,24(sp)
    80004fe0:	6161                	addi	sp,sp,80
    80004fe2:	8082                	ret

0000000080004fe4 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004fe4:	1141                	addi	sp,sp,-16
    80004fe6:	e422                	sd	s0,8(sp)
    80004fe8:	0800                	addi	s0,sp,16
    80004fea:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004fec:	8905                	andi	a0,a0,1
    80004fee:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004ff0:	8b89                	andi	a5,a5,2
    80004ff2:	c399                	beqz	a5,80004ff8 <flags2perm+0x14>
      perm |= PTE_W;
    80004ff4:	00456513          	ori	a0,a0,4
    return perm;
}
    80004ff8:	6422                	ld	s0,8(sp)
    80004ffa:	0141                	addi	sp,sp,16
    80004ffc:	8082                	ret

0000000080004ffe <exec>:

int
exec(char *path, char **argv)
{
    80004ffe:	df010113          	addi	sp,sp,-528
    80005002:	20113423          	sd	ra,520(sp)
    80005006:	20813023          	sd	s0,512(sp)
    8000500a:	ffa6                	sd	s1,504(sp)
    8000500c:	fbca                	sd	s2,496(sp)
    8000500e:	0c00                	addi	s0,sp,528
    80005010:	892a                	mv	s2,a0
    80005012:	dea43c23          	sd	a0,-520(s0)
    80005016:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000501a:	92dfc0ef          	jal	80001946 <myproc>
    8000501e:	84aa                	mv	s1,a0

  begin_op();
    80005020:	dc6ff0ef          	jal	800045e6 <begin_op>

  if((ip = namei(path)) == 0){
    80005024:	854a                	mv	a0,s2
    80005026:	c04ff0ef          	jal	8000442a <namei>
    8000502a:	c931                	beqz	a0,8000507e <exec+0x80>
    8000502c:	f3d2                	sd	s4,480(sp)
    8000502e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005030:	d21fe0ef          	jal	80003d50 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005034:	04000713          	li	a4,64
    80005038:	4681                	li	a3,0
    8000503a:	e5040613          	addi	a2,s0,-432
    8000503e:	4581                	li	a1,0
    80005040:	8552                	mv	a0,s4
    80005042:	f63fe0ef          	jal	80003fa4 <readi>
    80005046:	04000793          	li	a5,64
    8000504a:	00f51a63          	bne	a0,a5,8000505e <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000504e:	e5042703          	lw	a4,-432(s0)
    80005052:	464c47b7          	lui	a5,0x464c4
    80005056:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000505a:	02f70663          	beq	a4,a5,80005086 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000505e:	8552                	mv	a0,s4
    80005060:	efbfe0ef          	jal	80003f5a <iunlockput>
    end_op();
    80005064:	decff0ef          	jal	80004650 <end_op>
  }
  return -1;
    80005068:	557d                	li	a0,-1
    8000506a:	7a1e                	ld	s4,480(sp)
}
    8000506c:	20813083          	ld	ra,520(sp)
    80005070:	20013403          	ld	s0,512(sp)
    80005074:	74fe                	ld	s1,504(sp)
    80005076:	795e                	ld	s2,496(sp)
    80005078:	21010113          	addi	sp,sp,528
    8000507c:	8082                	ret
    end_op();
    8000507e:	dd2ff0ef          	jal	80004650 <end_op>
    return -1;
    80005082:	557d                	li	a0,-1
    80005084:	b7e5                	j	8000506c <exec+0x6e>
    80005086:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005088:	8526                	mv	a0,s1
    8000508a:	977fc0ef          	jal	80001a00 <proc_pagetable>
    8000508e:	8b2a                	mv	s6,a0
    80005090:	2c050b63          	beqz	a0,80005366 <exec+0x368>
    80005094:	f7ce                	sd	s3,488(sp)
    80005096:	efd6                	sd	s5,472(sp)
    80005098:	e7de                	sd	s7,456(sp)
    8000509a:	e3e2                	sd	s8,448(sp)
    8000509c:	ff66                	sd	s9,440(sp)
    8000509e:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050a0:	e7042d03          	lw	s10,-400(s0)
    800050a4:	e8845783          	lhu	a5,-376(s0)
    800050a8:	12078963          	beqz	a5,800051da <exec+0x1dc>
    800050ac:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800050ae:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050b0:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800050b2:	6c85                	lui	s9,0x1
    800050b4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800050b8:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800050bc:	6a85                	lui	s5,0x1
    800050be:	a085                	j	8000511e <exec+0x120>
      panic("loadseg: address should exist");
    800050c0:	00003517          	auipc	a0,0x3
    800050c4:	64850513          	addi	a0,a0,1608 # 80008708 <etext+0x708>
    800050c8:	eccfb0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    800050cc:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050ce:	8726                	mv	a4,s1
    800050d0:	012c06bb          	addw	a3,s8,s2
    800050d4:	4581                	li	a1,0
    800050d6:	8552                	mv	a0,s4
    800050d8:	ecdfe0ef          	jal	80003fa4 <readi>
    800050dc:	2501                	sext.w	a0,a0
    800050de:	24a49a63          	bne	s1,a0,80005332 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800050e2:	012a893b          	addw	s2,s5,s2
    800050e6:	03397363          	bgeu	s2,s3,8000510c <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800050ea:	02091593          	slli	a1,s2,0x20
    800050ee:	9181                	srli	a1,a1,0x20
    800050f0:	95de                	add	a1,a1,s7
    800050f2:	855a                	mv	a0,s6
    800050f4:	ee3fb0ef          	jal	80000fd6 <walkaddr>
    800050f8:	862a                	mv	a2,a0
    if(pa == 0)
    800050fa:	d179                	beqz	a0,800050c0 <exec+0xc2>
    if(sz - i < PGSIZE)
    800050fc:	412984bb          	subw	s1,s3,s2
    80005100:	0004879b          	sext.w	a5,s1
    80005104:	fcfcf4e3          	bgeu	s9,a5,800050cc <exec+0xce>
    80005108:	84d6                	mv	s1,s5
    8000510a:	b7c9                	j	800050cc <exec+0xce>
    sz = sz1;
    8000510c:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005110:	2d85                	addiw	s11,s11,1
    80005112:	038d0d1b          	addiw	s10,s10,56
    80005116:	e8845783          	lhu	a5,-376(s0)
    8000511a:	08fdd063          	bge	s11,a5,8000519a <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000511e:	2d01                	sext.w	s10,s10
    80005120:	03800713          	li	a4,56
    80005124:	86ea                	mv	a3,s10
    80005126:	e1840613          	addi	a2,s0,-488
    8000512a:	4581                	li	a1,0
    8000512c:	8552                	mv	a0,s4
    8000512e:	e77fe0ef          	jal	80003fa4 <readi>
    80005132:	03800793          	li	a5,56
    80005136:	1cf51663          	bne	a0,a5,80005302 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    8000513a:	e1842783          	lw	a5,-488(s0)
    8000513e:	4705                	li	a4,1
    80005140:	fce798e3          	bne	a5,a4,80005110 <exec+0x112>
    if(ph.memsz < ph.filesz)
    80005144:	e4043483          	ld	s1,-448(s0)
    80005148:	e3843783          	ld	a5,-456(s0)
    8000514c:	1af4ef63          	bltu	s1,a5,8000530a <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005150:	e2843783          	ld	a5,-472(s0)
    80005154:	94be                	add	s1,s1,a5
    80005156:	1af4ee63          	bltu	s1,a5,80005312 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    8000515a:	df043703          	ld	a4,-528(s0)
    8000515e:	8ff9                	and	a5,a5,a4
    80005160:	1a079d63          	bnez	a5,8000531a <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005164:	e1c42503          	lw	a0,-484(s0)
    80005168:	e7dff0ef          	jal	80004fe4 <flags2perm>
    8000516c:	86aa                	mv	a3,a0
    8000516e:	8626                	mv	a2,s1
    80005170:	85ca                	mv	a1,s2
    80005172:	855a                	mv	a0,s6
    80005174:	9cafc0ef          	jal	8000133e <uvmalloc>
    80005178:	e0a43423          	sd	a0,-504(s0)
    8000517c:	1a050363          	beqz	a0,80005322 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005180:	e2843b83          	ld	s7,-472(s0)
    80005184:	e2042c03          	lw	s8,-480(s0)
    80005188:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000518c:	00098463          	beqz	s3,80005194 <exec+0x196>
    80005190:	4901                	li	s2,0
    80005192:	bfa1                	j	800050ea <exec+0xec>
    sz = sz1;
    80005194:	e0843903          	ld	s2,-504(s0)
    80005198:	bfa5                	j	80005110 <exec+0x112>
    8000519a:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000519c:	8552                	mv	a0,s4
    8000519e:	dbdfe0ef          	jal	80003f5a <iunlockput>
  end_op();
    800051a2:	caeff0ef          	jal	80004650 <end_op>
  p = myproc();
    800051a6:	fa0fc0ef          	jal	80001946 <myproc>
    800051aa:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800051ac:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800051b0:	6985                	lui	s3,0x1
    800051b2:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800051b4:	99ca                	add	s3,s3,s2
    800051b6:	77fd                	lui	a5,0xfffff
    800051b8:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800051bc:	4691                	li	a3,4
    800051be:	6609                	lui	a2,0x2
    800051c0:	964e                	add	a2,a2,s3
    800051c2:	85ce                	mv	a1,s3
    800051c4:	855a                	mv	a0,s6
    800051c6:	978fc0ef          	jal	8000133e <uvmalloc>
    800051ca:	892a                	mv	s2,a0
    800051cc:	e0a43423          	sd	a0,-504(s0)
    800051d0:	e519                	bnez	a0,800051de <exec+0x1e0>
  if(pagetable)
    800051d2:	e1343423          	sd	s3,-504(s0)
    800051d6:	4a01                	li	s4,0
    800051d8:	aab1                	j	80005334 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051da:	4901                	li	s2,0
    800051dc:	b7c1                	j	8000519c <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800051de:	75f9                	lui	a1,0xffffe
    800051e0:	95aa                	add	a1,a1,a0
    800051e2:	855a                	mv	a0,s6
    800051e4:	b44fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800051e8:	7bfd                	lui	s7,0xfffff
    800051ea:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800051ec:	e0043783          	ld	a5,-512(s0)
    800051f0:	6388                	ld	a0,0(a5)
    800051f2:	cd39                	beqz	a0,80005250 <exec+0x252>
    800051f4:	e9040993          	addi	s3,s0,-368
    800051f8:	f9040c13          	addi	s8,s0,-112
    800051fc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800051fe:	c3bfb0ef          	jal	80000e38 <strlen>
    80005202:	0015079b          	addiw	a5,a0,1
    80005206:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000520a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000520e:	11796e63          	bltu	s2,s7,8000532a <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005212:	e0043d03          	ld	s10,-512(s0)
    80005216:	000d3a03          	ld	s4,0(s10)
    8000521a:	8552                	mv	a0,s4
    8000521c:	c1dfb0ef          	jal	80000e38 <strlen>
    80005220:	0015069b          	addiw	a3,a0,1
    80005224:	8652                	mv	a2,s4
    80005226:	85ca                	mv	a1,s2
    80005228:	855a                	mv	a0,s6
    8000522a:	b28fc0ef          	jal	80001552 <copyout>
    8000522e:	10054063          	bltz	a0,8000532e <exec+0x330>
    ustack[argc] = sp;
    80005232:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005236:	0485                	addi	s1,s1,1
    80005238:	008d0793          	addi	a5,s10,8
    8000523c:	e0f43023          	sd	a5,-512(s0)
    80005240:	008d3503          	ld	a0,8(s10)
    80005244:	c909                	beqz	a0,80005256 <exec+0x258>
    if(argc >= MAXARG)
    80005246:	09a1                	addi	s3,s3,8
    80005248:	fb899be3          	bne	s3,s8,800051fe <exec+0x200>
  ip = 0;
    8000524c:	4a01                	li	s4,0
    8000524e:	a0dd                	j	80005334 <exec+0x336>
  sp = sz;
    80005250:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005254:	4481                	li	s1,0
  ustack[argc] = 0;
    80005256:	00349793          	slli	a5,s1,0x3
    8000525a:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ff13b58>
    8000525e:	97a2                	add	a5,a5,s0
    80005260:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005264:	00148693          	addi	a3,s1,1
    80005268:	068e                	slli	a3,a3,0x3
    8000526a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000526e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005272:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005276:	f5796ee3          	bltu	s2,s7,800051d2 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000527a:	e9040613          	addi	a2,s0,-368
    8000527e:	85ca                	mv	a1,s2
    80005280:	855a                	mv	a0,s6
    80005282:	ad0fc0ef          	jal	80001552 <copyout>
    80005286:	0e054263          	bltz	a0,8000536a <exec+0x36c>
  p->trapframe->a1 = sp;
    8000528a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000528e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005292:	df843783          	ld	a5,-520(s0)
    80005296:	0007c703          	lbu	a4,0(a5)
    8000529a:	cf11                	beqz	a4,800052b6 <exec+0x2b8>
    8000529c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000529e:	02f00693          	li	a3,47
    800052a2:	a039                	j	800052b0 <exec+0x2b2>
      last = s+1;
    800052a4:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800052a8:	0785                	addi	a5,a5,1
    800052aa:	fff7c703          	lbu	a4,-1(a5)
    800052ae:	c701                	beqz	a4,800052b6 <exec+0x2b8>
    if(*s == '/')
    800052b0:	fed71ce3          	bne	a4,a3,800052a8 <exec+0x2aa>
    800052b4:	bfc5                	j	800052a4 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800052b6:	4641                	li	a2,16
    800052b8:	df843583          	ld	a1,-520(s0)
    800052bc:	158a8513          	addi	a0,s5,344
    800052c0:	b47fb0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    800052c4:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800052c8:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800052cc:	e0843783          	ld	a5,-504(s0)
    800052d0:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800052d4:	058ab783          	ld	a5,88(s5)
    800052d8:	e6843703          	ld	a4,-408(s0)
    800052dc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800052de:	058ab783          	ld	a5,88(s5)
    800052e2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052e6:	85e6                	mv	a1,s9
    800052e8:	f9cfc0ef          	jal	80001a84 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052ec:	0004851b          	sext.w	a0,s1
    800052f0:	79be                	ld	s3,488(sp)
    800052f2:	7a1e                	ld	s4,480(sp)
    800052f4:	6afe                	ld	s5,472(sp)
    800052f6:	6b5e                	ld	s6,464(sp)
    800052f8:	6bbe                	ld	s7,456(sp)
    800052fa:	6c1e                	ld	s8,448(sp)
    800052fc:	7cfa                	ld	s9,440(sp)
    800052fe:	7d5a                	ld	s10,432(sp)
    80005300:	b3b5                	j	8000506c <exec+0x6e>
    80005302:	e1243423          	sd	s2,-504(s0)
    80005306:	7dba                	ld	s11,424(sp)
    80005308:	a035                	j	80005334 <exec+0x336>
    8000530a:	e1243423          	sd	s2,-504(s0)
    8000530e:	7dba                	ld	s11,424(sp)
    80005310:	a015                	j	80005334 <exec+0x336>
    80005312:	e1243423          	sd	s2,-504(s0)
    80005316:	7dba                	ld	s11,424(sp)
    80005318:	a831                	j	80005334 <exec+0x336>
    8000531a:	e1243423          	sd	s2,-504(s0)
    8000531e:	7dba                	ld	s11,424(sp)
    80005320:	a811                	j	80005334 <exec+0x336>
    80005322:	e1243423          	sd	s2,-504(s0)
    80005326:	7dba                	ld	s11,424(sp)
    80005328:	a031                	j	80005334 <exec+0x336>
  ip = 0;
    8000532a:	4a01                	li	s4,0
    8000532c:	a021                	j	80005334 <exec+0x336>
    8000532e:	4a01                	li	s4,0
  if(pagetable)
    80005330:	a011                	j	80005334 <exec+0x336>
    80005332:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005334:	e0843583          	ld	a1,-504(s0)
    80005338:	855a                	mv	a0,s6
    8000533a:	f4afc0ef          	jal	80001a84 <proc_freepagetable>
  return -1;
    8000533e:	557d                	li	a0,-1
  if(ip){
    80005340:	000a1b63          	bnez	s4,80005356 <exec+0x358>
    80005344:	79be                	ld	s3,488(sp)
    80005346:	7a1e                	ld	s4,480(sp)
    80005348:	6afe                	ld	s5,472(sp)
    8000534a:	6b5e                	ld	s6,464(sp)
    8000534c:	6bbe                	ld	s7,456(sp)
    8000534e:	6c1e                	ld	s8,448(sp)
    80005350:	7cfa                	ld	s9,440(sp)
    80005352:	7d5a                	ld	s10,432(sp)
    80005354:	bb21                	j	8000506c <exec+0x6e>
    80005356:	79be                	ld	s3,488(sp)
    80005358:	6afe                	ld	s5,472(sp)
    8000535a:	6b5e                	ld	s6,464(sp)
    8000535c:	6bbe                	ld	s7,456(sp)
    8000535e:	6c1e                	ld	s8,448(sp)
    80005360:	7cfa                	ld	s9,440(sp)
    80005362:	7d5a                	ld	s10,432(sp)
    80005364:	b9ed                	j	8000505e <exec+0x60>
    80005366:	6b5e                	ld	s6,464(sp)
    80005368:	b9dd                	j	8000505e <exec+0x60>
  sz = sz1;
    8000536a:	e0843983          	ld	s3,-504(s0)
    8000536e:	b595                	j	800051d2 <exec+0x1d4>

0000000080005370 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005370:	7179                	addi	sp,sp,-48
    80005372:	f406                	sd	ra,40(sp)
    80005374:	f022                	sd	s0,32(sp)
    80005376:	ec26                	sd	s1,24(sp)
    80005378:	e84a                	sd	s2,16(sp)
    8000537a:	1800                	addi	s0,sp,48
    8000537c:	892e                	mv	s2,a1
    8000537e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005380:	fdc40593          	addi	a1,s0,-36
    80005384:	d3bfd0ef          	jal	800030be <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005388:	fdc42703          	lw	a4,-36(s0)
    8000538c:	47bd                	li	a5,15
    8000538e:	02e7e963          	bltu	a5,a4,800053c0 <argfd+0x50>
    80005392:	db4fc0ef          	jal	80001946 <myproc>
    80005396:	fdc42703          	lw	a4,-36(s0)
    8000539a:	01a70793          	addi	a5,a4,26
    8000539e:	078e                	slli	a5,a5,0x3
    800053a0:	953e                	add	a0,a0,a5
    800053a2:	611c                	ld	a5,0(a0)
    800053a4:	c385                	beqz	a5,800053c4 <argfd+0x54>
    return -1;
  if(pfd)
    800053a6:	00090463          	beqz	s2,800053ae <argfd+0x3e>
    *pfd = fd;
    800053aa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800053ae:	4501                	li	a0,0
  if(pf)
    800053b0:	c091                	beqz	s1,800053b4 <argfd+0x44>
    *pf = f;
    800053b2:	e09c                	sd	a5,0(s1)
}
    800053b4:	70a2                	ld	ra,40(sp)
    800053b6:	7402                	ld	s0,32(sp)
    800053b8:	64e2                	ld	s1,24(sp)
    800053ba:	6942                	ld	s2,16(sp)
    800053bc:	6145                	addi	sp,sp,48
    800053be:	8082                	ret
    return -1;
    800053c0:	557d                	li	a0,-1
    800053c2:	bfcd                	j	800053b4 <argfd+0x44>
    800053c4:	557d                	li	a0,-1
    800053c6:	b7fd                	j	800053b4 <argfd+0x44>

00000000800053c8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053c8:	1101                	addi	sp,sp,-32
    800053ca:	ec06                	sd	ra,24(sp)
    800053cc:	e822                	sd	s0,16(sp)
    800053ce:	e426                	sd	s1,8(sp)
    800053d0:	1000                	addi	s0,sp,32
    800053d2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053d4:	d72fc0ef          	jal	80001946 <myproc>
    800053d8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053da:	0d050793          	addi	a5,a0,208
    800053de:	4501                	li	a0,0
    800053e0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053e2:	6398                	ld	a4,0(a5)
    800053e4:	cb19                	beqz	a4,800053fa <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800053e6:	2505                	addiw	a0,a0,1
    800053e8:	07a1                	addi	a5,a5,8
    800053ea:	fed51ce3          	bne	a0,a3,800053e2 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053ee:	557d                	li	a0,-1
}
    800053f0:	60e2                	ld	ra,24(sp)
    800053f2:	6442                	ld	s0,16(sp)
    800053f4:	64a2                	ld	s1,8(sp)
    800053f6:	6105                	addi	sp,sp,32
    800053f8:	8082                	ret
      p->ofile[fd] = f;
    800053fa:	01a50793          	addi	a5,a0,26
    800053fe:	078e                	slli	a5,a5,0x3
    80005400:	963e                	add	a2,a2,a5
    80005402:	e204                	sd	s1,0(a2)
      return fd;
    80005404:	b7f5                	j	800053f0 <fdalloc+0x28>

0000000080005406 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005406:	715d                	addi	sp,sp,-80
    80005408:	e486                	sd	ra,72(sp)
    8000540a:	e0a2                	sd	s0,64(sp)
    8000540c:	fc26                	sd	s1,56(sp)
    8000540e:	f84a                	sd	s2,48(sp)
    80005410:	f44e                	sd	s3,40(sp)
    80005412:	ec56                	sd	s5,24(sp)
    80005414:	e85a                	sd	s6,16(sp)
    80005416:	0880                	addi	s0,sp,80
    80005418:	8b2e                	mv	s6,a1
    8000541a:	89b2                	mv	s3,a2
    8000541c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000541e:	fb040593          	addi	a1,s0,-80
    80005422:	822ff0ef          	jal	80004444 <nameiparent>
    80005426:	84aa                	mv	s1,a0
    80005428:	10050a63          	beqz	a0,8000553c <create+0x136>
    return 0;

  ilock(dp);
    8000542c:	925fe0ef          	jal	80003d50 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005430:	4601                	li	a2,0
    80005432:	fb040593          	addi	a1,s0,-80
    80005436:	8526                	mv	a0,s1
    80005438:	d8dfe0ef          	jal	800041c4 <dirlookup>
    8000543c:	8aaa                	mv	s5,a0
    8000543e:	c129                	beqz	a0,80005480 <create+0x7a>
    iunlockput(dp);
    80005440:	8526                	mv	a0,s1
    80005442:	b19fe0ef          	jal	80003f5a <iunlockput>
    ilock(ip);
    80005446:	8556                	mv	a0,s5
    80005448:	909fe0ef          	jal	80003d50 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000544c:	4789                	li	a5,2
    8000544e:	02fb1463          	bne	s6,a5,80005476 <create+0x70>
    80005452:	044ad783          	lhu	a5,68(s5)
    80005456:	37f9                	addiw	a5,a5,-2
    80005458:	17c2                	slli	a5,a5,0x30
    8000545a:	93c1                	srli	a5,a5,0x30
    8000545c:	4705                	li	a4,1
    8000545e:	00f76c63          	bltu	a4,a5,80005476 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005462:	8556                	mv	a0,s5
    80005464:	60a6                	ld	ra,72(sp)
    80005466:	6406                	ld	s0,64(sp)
    80005468:	74e2                	ld	s1,56(sp)
    8000546a:	7942                	ld	s2,48(sp)
    8000546c:	79a2                	ld	s3,40(sp)
    8000546e:	6ae2                	ld	s5,24(sp)
    80005470:	6b42                	ld	s6,16(sp)
    80005472:	6161                	addi	sp,sp,80
    80005474:	8082                	ret
    iunlockput(ip);
    80005476:	8556                	mv	a0,s5
    80005478:	ae3fe0ef          	jal	80003f5a <iunlockput>
    return 0;
    8000547c:	4a81                	li	s5,0
    8000547e:	b7d5                	j	80005462 <create+0x5c>
    80005480:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005482:	85da                	mv	a1,s6
    80005484:	4088                	lw	a0,0(s1)
    80005486:	f5afe0ef          	jal	80003be0 <ialloc>
    8000548a:	8a2a                	mv	s4,a0
    8000548c:	cd15                	beqz	a0,800054c8 <create+0xc2>
  ilock(ip);
    8000548e:	8c3fe0ef          	jal	80003d50 <ilock>
  ip->major = major;
    80005492:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005496:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000549a:	4905                	li	s2,1
    8000549c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800054a0:	8552                	mv	a0,s4
    800054a2:	ffafe0ef          	jal	80003c9c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054a6:	032b0763          	beq	s6,s2,800054d4 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800054aa:	004a2603          	lw	a2,4(s4)
    800054ae:	fb040593          	addi	a1,s0,-80
    800054b2:	8526                	mv	a0,s1
    800054b4:	eddfe0ef          	jal	80004390 <dirlink>
    800054b8:	06054563          	bltz	a0,80005522 <create+0x11c>
  iunlockput(dp);
    800054bc:	8526                	mv	a0,s1
    800054be:	a9dfe0ef          	jal	80003f5a <iunlockput>
  return ip;
    800054c2:	8ad2                	mv	s5,s4
    800054c4:	7a02                	ld	s4,32(sp)
    800054c6:	bf71                	j	80005462 <create+0x5c>
    iunlockput(dp);
    800054c8:	8526                	mv	a0,s1
    800054ca:	a91fe0ef          	jal	80003f5a <iunlockput>
    return 0;
    800054ce:	8ad2                	mv	s5,s4
    800054d0:	7a02                	ld	s4,32(sp)
    800054d2:	bf41                	j	80005462 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800054d4:	004a2603          	lw	a2,4(s4)
    800054d8:	00003597          	auipc	a1,0x3
    800054dc:	25058593          	addi	a1,a1,592 # 80008728 <etext+0x728>
    800054e0:	8552                	mv	a0,s4
    800054e2:	eaffe0ef          	jal	80004390 <dirlink>
    800054e6:	02054e63          	bltz	a0,80005522 <create+0x11c>
    800054ea:	40d0                	lw	a2,4(s1)
    800054ec:	00003597          	auipc	a1,0x3
    800054f0:	24458593          	addi	a1,a1,580 # 80008730 <etext+0x730>
    800054f4:	8552                	mv	a0,s4
    800054f6:	e9bfe0ef          	jal	80004390 <dirlink>
    800054fa:	02054463          	bltz	a0,80005522 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800054fe:	004a2603          	lw	a2,4(s4)
    80005502:	fb040593          	addi	a1,s0,-80
    80005506:	8526                	mv	a0,s1
    80005508:	e89fe0ef          	jal	80004390 <dirlink>
    8000550c:	00054b63          	bltz	a0,80005522 <create+0x11c>
    dp->nlink++;  // for ".."
    80005510:	04a4d783          	lhu	a5,74(s1)
    80005514:	2785                	addiw	a5,a5,1
    80005516:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000551a:	8526                	mv	a0,s1
    8000551c:	f80fe0ef          	jal	80003c9c <iupdate>
    80005520:	bf71                	j	800054bc <create+0xb6>
  ip->nlink = 0;
    80005522:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005526:	8552                	mv	a0,s4
    80005528:	f74fe0ef          	jal	80003c9c <iupdate>
  iunlockput(ip);
    8000552c:	8552                	mv	a0,s4
    8000552e:	a2dfe0ef          	jal	80003f5a <iunlockput>
  iunlockput(dp);
    80005532:	8526                	mv	a0,s1
    80005534:	a27fe0ef          	jal	80003f5a <iunlockput>
  return 0;
    80005538:	7a02                	ld	s4,32(sp)
    8000553a:	b725                	j	80005462 <create+0x5c>
    return 0;
    8000553c:	8aaa                	mv	s5,a0
    8000553e:	b715                	j	80005462 <create+0x5c>

0000000080005540 <sys_dup>:
{
    80005540:	7179                	addi	sp,sp,-48
    80005542:	f406                	sd	ra,40(sp)
    80005544:	f022                	sd	s0,32(sp)
    80005546:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005548:	fd840613          	addi	a2,s0,-40
    8000554c:	4581                	li	a1,0
    8000554e:	4501                	li	a0,0
    80005550:	e21ff0ef          	jal	80005370 <argfd>
    return -1;
    80005554:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005556:	02054363          	bltz	a0,8000557c <sys_dup+0x3c>
    8000555a:	ec26                	sd	s1,24(sp)
    8000555c:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000555e:	fd843903          	ld	s2,-40(s0)
    80005562:	854a                	mv	a0,s2
    80005564:	e65ff0ef          	jal	800053c8 <fdalloc>
    80005568:	84aa                	mv	s1,a0
    return -1;
    8000556a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000556c:	00054d63          	bltz	a0,80005586 <sys_dup+0x46>
  filedup(f);
    80005570:	854a                	mv	a0,s2
    80005572:	c48ff0ef          	jal	800049ba <filedup>
  return fd;
    80005576:	87a6                	mv	a5,s1
    80005578:	64e2                	ld	s1,24(sp)
    8000557a:	6942                	ld	s2,16(sp)
}
    8000557c:	853e                	mv	a0,a5
    8000557e:	70a2                	ld	ra,40(sp)
    80005580:	7402                	ld	s0,32(sp)
    80005582:	6145                	addi	sp,sp,48
    80005584:	8082                	ret
    80005586:	64e2                	ld	s1,24(sp)
    80005588:	6942                	ld	s2,16(sp)
    8000558a:	bfcd                	j	8000557c <sys_dup+0x3c>

000000008000558c <sys_read>:
{
    8000558c:	7179                	addi	sp,sp,-48
    8000558e:	f406                	sd	ra,40(sp)
    80005590:	f022                	sd	s0,32(sp)
    80005592:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005594:	fd840593          	addi	a1,s0,-40
    80005598:	4505                	li	a0,1
    8000559a:	b41fd0ef          	jal	800030da <argaddr>
  argint(2, &n);
    8000559e:	fe440593          	addi	a1,s0,-28
    800055a2:	4509                	li	a0,2
    800055a4:	b1bfd0ef          	jal	800030be <argint>
  if(argfd(0, 0, &f) < 0)
    800055a8:	fe840613          	addi	a2,s0,-24
    800055ac:	4581                	li	a1,0
    800055ae:	4501                	li	a0,0
    800055b0:	dc1ff0ef          	jal	80005370 <argfd>
    800055b4:	87aa                	mv	a5,a0
    return -1;
    800055b6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055b8:	0007ca63          	bltz	a5,800055cc <sys_read+0x40>
  return fileread(f, p, n);
    800055bc:	fe442603          	lw	a2,-28(s0)
    800055c0:	fd843583          	ld	a1,-40(s0)
    800055c4:	fe843503          	ld	a0,-24(s0)
    800055c8:	d58ff0ef          	jal	80004b20 <fileread>
}
    800055cc:	70a2                	ld	ra,40(sp)
    800055ce:	7402                	ld	s0,32(sp)
    800055d0:	6145                	addi	sp,sp,48
    800055d2:	8082                	ret

00000000800055d4 <sys_write>:
{
    800055d4:	7179                	addi	sp,sp,-48
    800055d6:	f406                	sd	ra,40(sp)
    800055d8:	f022                	sd	s0,32(sp)
    800055da:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800055dc:	fd840593          	addi	a1,s0,-40
    800055e0:	4505                	li	a0,1
    800055e2:	af9fd0ef          	jal	800030da <argaddr>
  argint(2, &n);
    800055e6:	fe440593          	addi	a1,s0,-28
    800055ea:	4509                	li	a0,2
    800055ec:	ad3fd0ef          	jal	800030be <argint>
  if(argfd(0, 0, &f) < 0)
    800055f0:	fe840613          	addi	a2,s0,-24
    800055f4:	4581                	li	a1,0
    800055f6:	4501                	li	a0,0
    800055f8:	d79ff0ef          	jal	80005370 <argfd>
    800055fc:	87aa                	mv	a5,a0
    return -1;
    800055fe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005600:	0007ca63          	bltz	a5,80005614 <sys_write+0x40>
  return filewrite(f, p, n);
    80005604:	fe442603          	lw	a2,-28(s0)
    80005608:	fd843583          	ld	a1,-40(s0)
    8000560c:	fe843503          	ld	a0,-24(s0)
    80005610:	dceff0ef          	jal	80004bde <filewrite>
}
    80005614:	70a2                	ld	ra,40(sp)
    80005616:	7402                	ld	s0,32(sp)
    80005618:	6145                	addi	sp,sp,48
    8000561a:	8082                	ret

000000008000561c <sys_close>:
{
    8000561c:	1101                	addi	sp,sp,-32
    8000561e:	ec06                	sd	ra,24(sp)
    80005620:	e822                	sd	s0,16(sp)
    80005622:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005624:	fe040613          	addi	a2,s0,-32
    80005628:	fec40593          	addi	a1,s0,-20
    8000562c:	4501                	li	a0,0
    8000562e:	d43ff0ef          	jal	80005370 <argfd>
    return -1;
    80005632:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005634:	02054063          	bltz	a0,80005654 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005638:	b0efc0ef          	jal	80001946 <myproc>
    8000563c:	fec42783          	lw	a5,-20(s0)
    80005640:	07e9                	addi	a5,a5,26
    80005642:	078e                	slli	a5,a5,0x3
    80005644:	953e                	add	a0,a0,a5
    80005646:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000564a:	fe043503          	ld	a0,-32(s0)
    8000564e:	bb2ff0ef          	jal	80004a00 <fileclose>
  return 0;
    80005652:	4781                	li	a5,0
}
    80005654:	853e                	mv	a0,a5
    80005656:	60e2                	ld	ra,24(sp)
    80005658:	6442                	ld	s0,16(sp)
    8000565a:	6105                	addi	sp,sp,32
    8000565c:	8082                	ret

000000008000565e <sys_fstat>:
{
    8000565e:	1101                	addi	sp,sp,-32
    80005660:	ec06                	sd	ra,24(sp)
    80005662:	e822                	sd	s0,16(sp)
    80005664:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005666:	fe040593          	addi	a1,s0,-32
    8000566a:	4505                	li	a0,1
    8000566c:	a6ffd0ef          	jal	800030da <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005670:	fe840613          	addi	a2,s0,-24
    80005674:	4581                	li	a1,0
    80005676:	4501                	li	a0,0
    80005678:	cf9ff0ef          	jal	80005370 <argfd>
    8000567c:	87aa                	mv	a5,a0
    return -1;
    8000567e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005680:	0007c863          	bltz	a5,80005690 <sys_fstat+0x32>
  return filestat(f, st);
    80005684:	fe043583          	ld	a1,-32(s0)
    80005688:	fe843503          	ld	a0,-24(s0)
    8000568c:	c36ff0ef          	jal	80004ac2 <filestat>
}
    80005690:	60e2                	ld	ra,24(sp)
    80005692:	6442                	ld	s0,16(sp)
    80005694:	6105                	addi	sp,sp,32
    80005696:	8082                	ret

0000000080005698 <sys_link>:
{
    80005698:	7169                	addi	sp,sp,-304
    8000569a:	f606                	sd	ra,296(sp)
    8000569c:	f222                	sd	s0,288(sp)
    8000569e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056a0:	08000613          	li	a2,128
    800056a4:	ed040593          	addi	a1,s0,-304
    800056a8:	4501                	li	a0,0
    800056aa:	a4dfd0ef          	jal	800030f6 <argstr>
    return -1;
    800056ae:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056b0:	0c054e63          	bltz	a0,8000578c <sys_link+0xf4>
    800056b4:	08000613          	li	a2,128
    800056b8:	f5040593          	addi	a1,s0,-176
    800056bc:	4505                	li	a0,1
    800056be:	a39fd0ef          	jal	800030f6 <argstr>
    return -1;
    800056c2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056c4:	0c054463          	bltz	a0,8000578c <sys_link+0xf4>
    800056c8:	ee26                	sd	s1,280(sp)
  begin_op();
    800056ca:	f1dfe0ef          	jal	800045e6 <begin_op>
  if((ip = namei(old)) == 0){
    800056ce:	ed040513          	addi	a0,s0,-304
    800056d2:	d59fe0ef          	jal	8000442a <namei>
    800056d6:	84aa                	mv	s1,a0
    800056d8:	c53d                	beqz	a0,80005746 <sys_link+0xae>
  ilock(ip);
    800056da:	e76fe0ef          	jal	80003d50 <ilock>
  if(ip->type == T_DIR){
    800056de:	04449703          	lh	a4,68(s1)
    800056e2:	4785                	li	a5,1
    800056e4:	06f70663          	beq	a4,a5,80005750 <sys_link+0xb8>
    800056e8:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800056ea:	04a4d783          	lhu	a5,74(s1)
    800056ee:	2785                	addiw	a5,a5,1
    800056f0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056f4:	8526                	mv	a0,s1
    800056f6:	da6fe0ef          	jal	80003c9c <iupdate>
  iunlock(ip);
    800056fa:	8526                	mv	a0,s1
    800056fc:	f02fe0ef          	jal	80003dfe <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005700:	fd040593          	addi	a1,s0,-48
    80005704:	f5040513          	addi	a0,s0,-176
    80005708:	d3dfe0ef          	jal	80004444 <nameiparent>
    8000570c:	892a                	mv	s2,a0
    8000570e:	cd21                	beqz	a0,80005766 <sys_link+0xce>
  ilock(dp);
    80005710:	e40fe0ef          	jal	80003d50 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005714:	00092703          	lw	a4,0(s2)
    80005718:	409c                	lw	a5,0(s1)
    8000571a:	04f71363          	bne	a4,a5,80005760 <sys_link+0xc8>
    8000571e:	40d0                	lw	a2,4(s1)
    80005720:	fd040593          	addi	a1,s0,-48
    80005724:	854a                	mv	a0,s2
    80005726:	c6bfe0ef          	jal	80004390 <dirlink>
    8000572a:	02054b63          	bltz	a0,80005760 <sys_link+0xc8>
  iunlockput(dp);
    8000572e:	854a                	mv	a0,s2
    80005730:	82bfe0ef          	jal	80003f5a <iunlockput>
  iput(ip);
    80005734:	8526                	mv	a0,s1
    80005736:	f9cfe0ef          	jal	80003ed2 <iput>
  end_op();
    8000573a:	f17fe0ef          	jal	80004650 <end_op>
  return 0;
    8000573e:	4781                	li	a5,0
    80005740:	64f2                	ld	s1,280(sp)
    80005742:	6952                	ld	s2,272(sp)
    80005744:	a0a1                	j	8000578c <sys_link+0xf4>
    end_op();
    80005746:	f0bfe0ef          	jal	80004650 <end_op>
    return -1;
    8000574a:	57fd                	li	a5,-1
    8000574c:	64f2                	ld	s1,280(sp)
    8000574e:	a83d                	j	8000578c <sys_link+0xf4>
    iunlockput(ip);
    80005750:	8526                	mv	a0,s1
    80005752:	809fe0ef          	jal	80003f5a <iunlockput>
    end_op();
    80005756:	efbfe0ef          	jal	80004650 <end_op>
    return -1;
    8000575a:	57fd                	li	a5,-1
    8000575c:	64f2                	ld	s1,280(sp)
    8000575e:	a03d                	j	8000578c <sys_link+0xf4>
    iunlockput(dp);
    80005760:	854a                	mv	a0,s2
    80005762:	ff8fe0ef          	jal	80003f5a <iunlockput>
  ilock(ip);
    80005766:	8526                	mv	a0,s1
    80005768:	de8fe0ef          	jal	80003d50 <ilock>
  ip->nlink--;
    8000576c:	04a4d783          	lhu	a5,74(s1)
    80005770:	37fd                	addiw	a5,a5,-1
    80005772:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005776:	8526                	mv	a0,s1
    80005778:	d24fe0ef          	jal	80003c9c <iupdate>
  iunlockput(ip);
    8000577c:	8526                	mv	a0,s1
    8000577e:	fdcfe0ef          	jal	80003f5a <iunlockput>
  end_op();
    80005782:	ecffe0ef          	jal	80004650 <end_op>
  return -1;
    80005786:	57fd                	li	a5,-1
    80005788:	64f2                	ld	s1,280(sp)
    8000578a:	6952                	ld	s2,272(sp)
}
    8000578c:	853e                	mv	a0,a5
    8000578e:	70b2                	ld	ra,296(sp)
    80005790:	7412                	ld	s0,288(sp)
    80005792:	6155                	addi	sp,sp,304
    80005794:	8082                	ret

0000000080005796 <sys_unlink>:
{
    80005796:	7151                	addi	sp,sp,-240
    80005798:	f586                	sd	ra,232(sp)
    8000579a:	f1a2                	sd	s0,224(sp)
    8000579c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000579e:	08000613          	li	a2,128
    800057a2:	f3040593          	addi	a1,s0,-208
    800057a6:	4501                	li	a0,0
    800057a8:	94ffd0ef          	jal	800030f6 <argstr>
    800057ac:	16054063          	bltz	a0,8000590c <sys_unlink+0x176>
    800057b0:	eda6                	sd	s1,216(sp)
  begin_op();
    800057b2:	e35fe0ef          	jal	800045e6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057b6:	fb040593          	addi	a1,s0,-80
    800057ba:	f3040513          	addi	a0,s0,-208
    800057be:	c87fe0ef          	jal	80004444 <nameiparent>
    800057c2:	84aa                	mv	s1,a0
    800057c4:	c945                	beqz	a0,80005874 <sys_unlink+0xde>
  ilock(dp);
    800057c6:	d8afe0ef          	jal	80003d50 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057ca:	00003597          	auipc	a1,0x3
    800057ce:	f5e58593          	addi	a1,a1,-162 # 80008728 <etext+0x728>
    800057d2:	fb040513          	addi	a0,s0,-80
    800057d6:	9d9fe0ef          	jal	800041ae <namecmp>
    800057da:	10050e63          	beqz	a0,800058f6 <sys_unlink+0x160>
    800057de:	00003597          	auipc	a1,0x3
    800057e2:	f5258593          	addi	a1,a1,-174 # 80008730 <etext+0x730>
    800057e6:	fb040513          	addi	a0,s0,-80
    800057ea:	9c5fe0ef          	jal	800041ae <namecmp>
    800057ee:	10050463          	beqz	a0,800058f6 <sys_unlink+0x160>
    800057f2:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057f4:	f2c40613          	addi	a2,s0,-212
    800057f8:	fb040593          	addi	a1,s0,-80
    800057fc:	8526                	mv	a0,s1
    800057fe:	9c7fe0ef          	jal	800041c4 <dirlookup>
    80005802:	892a                	mv	s2,a0
    80005804:	0e050863          	beqz	a0,800058f4 <sys_unlink+0x15e>
  ilock(ip);
    80005808:	d48fe0ef          	jal	80003d50 <ilock>
  if(ip->nlink < 1)
    8000580c:	04a91783          	lh	a5,74(s2)
    80005810:	06f05763          	blez	a5,8000587e <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005814:	04491703          	lh	a4,68(s2)
    80005818:	4785                	li	a5,1
    8000581a:	06f70963          	beq	a4,a5,8000588c <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    8000581e:	4641                	li	a2,16
    80005820:	4581                	li	a1,0
    80005822:	fc040513          	addi	a0,s0,-64
    80005826:	ca2fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000582a:	4741                	li	a4,16
    8000582c:	f2c42683          	lw	a3,-212(s0)
    80005830:	fc040613          	addi	a2,s0,-64
    80005834:	4581                	li	a1,0
    80005836:	8526                	mv	a0,s1
    80005838:	869fe0ef          	jal	800040a0 <writei>
    8000583c:	47c1                	li	a5,16
    8000583e:	08f51b63          	bne	a0,a5,800058d4 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005842:	04491703          	lh	a4,68(s2)
    80005846:	4785                	li	a5,1
    80005848:	08f70d63          	beq	a4,a5,800058e2 <sys_unlink+0x14c>
  iunlockput(dp);
    8000584c:	8526                	mv	a0,s1
    8000584e:	f0cfe0ef          	jal	80003f5a <iunlockput>
  ip->nlink--;
    80005852:	04a95783          	lhu	a5,74(s2)
    80005856:	37fd                	addiw	a5,a5,-1
    80005858:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000585c:	854a                	mv	a0,s2
    8000585e:	c3efe0ef          	jal	80003c9c <iupdate>
  iunlockput(ip);
    80005862:	854a                	mv	a0,s2
    80005864:	ef6fe0ef          	jal	80003f5a <iunlockput>
  end_op();
    80005868:	de9fe0ef          	jal	80004650 <end_op>
  return 0;
    8000586c:	4501                	li	a0,0
    8000586e:	64ee                	ld	s1,216(sp)
    80005870:	694e                	ld	s2,208(sp)
    80005872:	a849                	j	80005904 <sys_unlink+0x16e>
    end_op();
    80005874:	dddfe0ef          	jal	80004650 <end_op>
    return -1;
    80005878:	557d                	li	a0,-1
    8000587a:	64ee                	ld	s1,216(sp)
    8000587c:	a061                	j	80005904 <sys_unlink+0x16e>
    8000587e:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005880:	00003517          	auipc	a0,0x3
    80005884:	eb850513          	addi	a0,a0,-328 # 80008738 <etext+0x738>
    80005888:	f0dfa0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000588c:	04c92703          	lw	a4,76(s2)
    80005890:	02000793          	li	a5,32
    80005894:	f8e7f5e3          	bgeu	a5,a4,8000581e <sys_unlink+0x88>
    80005898:	e5ce                	sd	s3,200(sp)
    8000589a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000589e:	4741                	li	a4,16
    800058a0:	86ce                	mv	a3,s3
    800058a2:	f1840613          	addi	a2,s0,-232
    800058a6:	4581                	li	a1,0
    800058a8:	854a                	mv	a0,s2
    800058aa:	efafe0ef          	jal	80003fa4 <readi>
    800058ae:	47c1                	li	a5,16
    800058b0:	00f51c63          	bne	a0,a5,800058c8 <sys_unlink+0x132>
    if(de.inum != 0)
    800058b4:	f1845783          	lhu	a5,-232(s0)
    800058b8:	efa1                	bnez	a5,80005910 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058ba:	29c1                	addiw	s3,s3,16
    800058bc:	04c92783          	lw	a5,76(s2)
    800058c0:	fcf9efe3          	bltu	s3,a5,8000589e <sys_unlink+0x108>
    800058c4:	69ae                	ld	s3,200(sp)
    800058c6:	bfa1                	j	8000581e <sys_unlink+0x88>
      panic("isdirempty: readi");
    800058c8:	00003517          	auipc	a0,0x3
    800058cc:	e8850513          	addi	a0,a0,-376 # 80008750 <etext+0x750>
    800058d0:	ec5fa0ef          	jal	80000794 <panic>
    800058d4:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800058d6:	00003517          	auipc	a0,0x3
    800058da:	e9250513          	addi	a0,a0,-366 # 80008768 <etext+0x768>
    800058de:	eb7fa0ef          	jal	80000794 <panic>
    dp->nlink--;
    800058e2:	04a4d783          	lhu	a5,74(s1)
    800058e6:	37fd                	addiw	a5,a5,-1
    800058e8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058ec:	8526                	mv	a0,s1
    800058ee:	baefe0ef          	jal	80003c9c <iupdate>
    800058f2:	bfa9                	j	8000584c <sys_unlink+0xb6>
    800058f4:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800058f6:	8526                	mv	a0,s1
    800058f8:	e62fe0ef          	jal	80003f5a <iunlockput>
  end_op();
    800058fc:	d55fe0ef          	jal	80004650 <end_op>
  return -1;
    80005900:	557d                	li	a0,-1
    80005902:	64ee                	ld	s1,216(sp)
}
    80005904:	70ae                	ld	ra,232(sp)
    80005906:	740e                	ld	s0,224(sp)
    80005908:	616d                	addi	sp,sp,240
    8000590a:	8082                	ret
    return -1;
    8000590c:	557d                	li	a0,-1
    8000590e:	bfdd                	j	80005904 <sys_unlink+0x16e>
    iunlockput(ip);
    80005910:	854a                	mv	a0,s2
    80005912:	e48fe0ef          	jal	80003f5a <iunlockput>
    goto bad;
    80005916:	694e                	ld	s2,208(sp)
    80005918:	69ae                	ld	s3,200(sp)
    8000591a:	bff1                	j	800058f6 <sys_unlink+0x160>

000000008000591c <sys_open>:

uint64
sys_open(void)
{
    8000591c:	7131                	addi	sp,sp,-192
    8000591e:	fd06                	sd	ra,184(sp)
    80005920:	f922                	sd	s0,176(sp)
    80005922:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005924:	f4c40593          	addi	a1,s0,-180
    80005928:	4505                	li	a0,1
    8000592a:	f94fd0ef          	jal	800030be <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000592e:	08000613          	li	a2,128
    80005932:	f5040593          	addi	a1,s0,-176
    80005936:	4501                	li	a0,0
    80005938:	fbefd0ef          	jal	800030f6 <argstr>
    8000593c:	87aa                	mv	a5,a0
    return -1;
    8000593e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005940:	0a07c263          	bltz	a5,800059e4 <sys_open+0xc8>
    80005944:	f526                	sd	s1,168(sp)

  begin_op();
    80005946:	ca1fe0ef          	jal	800045e6 <begin_op>

  if(omode & O_CREATE){
    8000594a:	f4c42783          	lw	a5,-180(s0)
    8000594e:	2007f793          	andi	a5,a5,512
    80005952:	c3d5                	beqz	a5,800059f6 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005954:	4681                	li	a3,0
    80005956:	4601                	li	a2,0
    80005958:	4589                	li	a1,2
    8000595a:	f5040513          	addi	a0,s0,-176
    8000595e:	aa9ff0ef          	jal	80005406 <create>
    80005962:	84aa                	mv	s1,a0
    if(ip == 0){
    80005964:	c541                	beqz	a0,800059ec <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005966:	04449703          	lh	a4,68(s1)
    8000596a:	478d                	li	a5,3
    8000596c:	00f71763          	bne	a4,a5,8000597a <sys_open+0x5e>
    80005970:	0464d703          	lhu	a4,70(s1)
    80005974:	47a5                	li	a5,9
    80005976:	0ae7ed63          	bltu	a5,a4,80005a30 <sys_open+0x114>
    8000597a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000597c:	fe1fe0ef          	jal	8000495c <filealloc>
    80005980:	892a                	mv	s2,a0
    80005982:	c179                	beqz	a0,80005a48 <sys_open+0x12c>
    80005984:	ed4e                	sd	s3,152(sp)
    80005986:	a43ff0ef          	jal	800053c8 <fdalloc>
    8000598a:	89aa                	mv	s3,a0
    8000598c:	0a054a63          	bltz	a0,80005a40 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005990:	04449703          	lh	a4,68(s1)
    80005994:	478d                	li	a5,3
    80005996:	0cf70263          	beq	a4,a5,80005a5a <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000599a:	4789                	li	a5,2
    8000599c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800059a0:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800059a4:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800059a8:	f4c42783          	lw	a5,-180(s0)
    800059ac:	0017c713          	xori	a4,a5,1
    800059b0:	8b05                	andi	a4,a4,1
    800059b2:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059b6:	0037f713          	andi	a4,a5,3
    800059ba:	00e03733          	snez	a4,a4
    800059be:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059c2:	4007f793          	andi	a5,a5,1024
    800059c6:	c791                	beqz	a5,800059d2 <sys_open+0xb6>
    800059c8:	04449703          	lh	a4,68(s1)
    800059cc:	4789                	li	a5,2
    800059ce:	08f70d63          	beq	a4,a5,80005a68 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800059d2:	8526                	mv	a0,s1
    800059d4:	c2afe0ef          	jal	80003dfe <iunlock>
  end_op();
    800059d8:	c79fe0ef          	jal	80004650 <end_op>

  return fd;
    800059dc:	854e                	mv	a0,s3
    800059de:	74aa                	ld	s1,168(sp)
    800059e0:	790a                	ld	s2,160(sp)
    800059e2:	69ea                	ld	s3,152(sp)
}
    800059e4:	70ea                	ld	ra,184(sp)
    800059e6:	744a                	ld	s0,176(sp)
    800059e8:	6129                	addi	sp,sp,192
    800059ea:	8082                	ret
      end_op();
    800059ec:	c65fe0ef          	jal	80004650 <end_op>
      return -1;
    800059f0:	557d                	li	a0,-1
    800059f2:	74aa                	ld	s1,168(sp)
    800059f4:	bfc5                	j	800059e4 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800059f6:	f5040513          	addi	a0,s0,-176
    800059fa:	a31fe0ef          	jal	8000442a <namei>
    800059fe:	84aa                	mv	s1,a0
    80005a00:	c11d                	beqz	a0,80005a26 <sys_open+0x10a>
    ilock(ip);
    80005a02:	b4efe0ef          	jal	80003d50 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a06:	04449703          	lh	a4,68(s1)
    80005a0a:	4785                	li	a5,1
    80005a0c:	f4f71de3          	bne	a4,a5,80005966 <sys_open+0x4a>
    80005a10:	f4c42783          	lw	a5,-180(s0)
    80005a14:	d3bd                	beqz	a5,8000597a <sys_open+0x5e>
      iunlockput(ip);
    80005a16:	8526                	mv	a0,s1
    80005a18:	d42fe0ef          	jal	80003f5a <iunlockput>
      end_op();
    80005a1c:	c35fe0ef          	jal	80004650 <end_op>
      return -1;
    80005a20:	557d                	li	a0,-1
    80005a22:	74aa                	ld	s1,168(sp)
    80005a24:	b7c1                	j	800059e4 <sys_open+0xc8>
      end_op();
    80005a26:	c2bfe0ef          	jal	80004650 <end_op>
      return -1;
    80005a2a:	557d                	li	a0,-1
    80005a2c:	74aa                	ld	s1,168(sp)
    80005a2e:	bf5d                	j	800059e4 <sys_open+0xc8>
    iunlockput(ip);
    80005a30:	8526                	mv	a0,s1
    80005a32:	d28fe0ef          	jal	80003f5a <iunlockput>
    end_op();
    80005a36:	c1bfe0ef          	jal	80004650 <end_op>
    return -1;
    80005a3a:	557d                	li	a0,-1
    80005a3c:	74aa                	ld	s1,168(sp)
    80005a3e:	b75d                	j	800059e4 <sys_open+0xc8>
      fileclose(f);
    80005a40:	854a                	mv	a0,s2
    80005a42:	fbffe0ef          	jal	80004a00 <fileclose>
    80005a46:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005a48:	8526                	mv	a0,s1
    80005a4a:	d10fe0ef          	jal	80003f5a <iunlockput>
    end_op();
    80005a4e:	c03fe0ef          	jal	80004650 <end_op>
    return -1;
    80005a52:	557d                	li	a0,-1
    80005a54:	74aa                	ld	s1,168(sp)
    80005a56:	790a                	ld	s2,160(sp)
    80005a58:	b771                	j	800059e4 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005a5a:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005a5e:	04649783          	lh	a5,70(s1)
    80005a62:	02f91223          	sh	a5,36(s2)
    80005a66:	bf3d                	j	800059a4 <sys_open+0x88>
    itrunc(ip);
    80005a68:	8526                	mv	a0,s1
    80005a6a:	bd4fe0ef          	jal	80003e3e <itrunc>
    80005a6e:	b795                	j	800059d2 <sys_open+0xb6>

0000000080005a70 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a70:	7175                	addi	sp,sp,-144
    80005a72:	e506                	sd	ra,136(sp)
    80005a74:	e122                	sd	s0,128(sp)
    80005a76:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a78:	b6ffe0ef          	jal	800045e6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a7c:	08000613          	li	a2,128
    80005a80:	f7040593          	addi	a1,s0,-144
    80005a84:	4501                	li	a0,0
    80005a86:	e70fd0ef          	jal	800030f6 <argstr>
    80005a8a:	02054363          	bltz	a0,80005ab0 <sys_mkdir+0x40>
    80005a8e:	4681                	li	a3,0
    80005a90:	4601                	li	a2,0
    80005a92:	4585                	li	a1,1
    80005a94:	f7040513          	addi	a0,s0,-144
    80005a98:	96fff0ef          	jal	80005406 <create>
    80005a9c:	c911                	beqz	a0,80005ab0 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a9e:	cbcfe0ef          	jal	80003f5a <iunlockput>
  end_op();
    80005aa2:	baffe0ef          	jal	80004650 <end_op>
  return 0;
    80005aa6:	4501                	li	a0,0
}
    80005aa8:	60aa                	ld	ra,136(sp)
    80005aaa:	640a                	ld	s0,128(sp)
    80005aac:	6149                	addi	sp,sp,144
    80005aae:	8082                	ret
    end_op();
    80005ab0:	ba1fe0ef          	jal	80004650 <end_op>
    return -1;
    80005ab4:	557d                	li	a0,-1
    80005ab6:	bfcd                	j	80005aa8 <sys_mkdir+0x38>

0000000080005ab8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ab8:	7135                	addi	sp,sp,-160
    80005aba:	ed06                	sd	ra,152(sp)
    80005abc:	e922                	sd	s0,144(sp)
    80005abe:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ac0:	b27fe0ef          	jal	800045e6 <begin_op>
  argint(1, &major);
    80005ac4:	f6c40593          	addi	a1,s0,-148
    80005ac8:	4505                	li	a0,1
    80005aca:	df4fd0ef          	jal	800030be <argint>
  argint(2, &minor);
    80005ace:	f6840593          	addi	a1,s0,-152
    80005ad2:	4509                	li	a0,2
    80005ad4:	deafd0ef          	jal	800030be <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ad8:	08000613          	li	a2,128
    80005adc:	f7040593          	addi	a1,s0,-144
    80005ae0:	4501                	li	a0,0
    80005ae2:	e14fd0ef          	jal	800030f6 <argstr>
    80005ae6:	02054563          	bltz	a0,80005b10 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005aea:	f6841683          	lh	a3,-152(s0)
    80005aee:	f6c41603          	lh	a2,-148(s0)
    80005af2:	458d                	li	a1,3
    80005af4:	f7040513          	addi	a0,s0,-144
    80005af8:	90fff0ef          	jal	80005406 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005afc:	c911                	beqz	a0,80005b10 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005afe:	c5cfe0ef          	jal	80003f5a <iunlockput>
  end_op();
    80005b02:	b4ffe0ef          	jal	80004650 <end_op>
  return 0;
    80005b06:	4501                	li	a0,0
}
    80005b08:	60ea                	ld	ra,152(sp)
    80005b0a:	644a                	ld	s0,144(sp)
    80005b0c:	610d                	addi	sp,sp,160
    80005b0e:	8082                	ret
    end_op();
    80005b10:	b41fe0ef          	jal	80004650 <end_op>
    return -1;
    80005b14:	557d                	li	a0,-1
    80005b16:	bfcd                	j	80005b08 <sys_mknod+0x50>

0000000080005b18 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b18:	7135                	addi	sp,sp,-160
    80005b1a:	ed06                	sd	ra,152(sp)
    80005b1c:	e922                	sd	s0,144(sp)
    80005b1e:	e14a                	sd	s2,128(sp)
    80005b20:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b22:	e25fb0ef          	jal	80001946 <myproc>
    80005b26:	892a                	mv	s2,a0
  
  begin_op();
    80005b28:	abffe0ef          	jal	800045e6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b2c:	08000613          	li	a2,128
    80005b30:	f6040593          	addi	a1,s0,-160
    80005b34:	4501                	li	a0,0
    80005b36:	dc0fd0ef          	jal	800030f6 <argstr>
    80005b3a:	04054363          	bltz	a0,80005b80 <sys_chdir+0x68>
    80005b3e:	e526                	sd	s1,136(sp)
    80005b40:	f6040513          	addi	a0,s0,-160
    80005b44:	8e7fe0ef          	jal	8000442a <namei>
    80005b48:	84aa                	mv	s1,a0
    80005b4a:	c915                	beqz	a0,80005b7e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b4c:	a04fe0ef          	jal	80003d50 <ilock>
  if(ip->type != T_DIR){
    80005b50:	04449703          	lh	a4,68(s1)
    80005b54:	4785                	li	a5,1
    80005b56:	02f71963          	bne	a4,a5,80005b88 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b5a:	8526                	mv	a0,s1
    80005b5c:	aa2fe0ef          	jal	80003dfe <iunlock>
  iput(p->cwd);
    80005b60:	15093503          	ld	a0,336(s2)
    80005b64:	b6efe0ef          	jal	80003ed2 <iput>
  end_op();
    80005b68:	ae9fe0ef          	jal	80004650 <end_op>
  p->cwd = ip;
    80005b6c:	14993823          	sd	s1,336(s2)
  return 0;
    80005b70:	4501                	li	a0,0
    80005b72:	64aa                	ld	s1,136(sp)
}
    80005b74:	60ea                	ld	ra,152(sp)
    80005b76:	644a                	ld	s0,144(sp)
    80005b78:	690a                	ld	s2,128(sp)
    80005b7a:	610d                	addi	sp,sp,160
    80005b7c:	8082                	ret
    80005b7e:	64aa                	ld	s1,136(sp)
    end_op();
    80005b80:	ad1fe0ef          	jal	80004650 <end_op>
    return -1;
    80005b84:	557d                	li	a0,-1
    80005b86:	b7fd                	j	80005b74 <sys_chdir+0x5c>
    iunlockput(ip);
    80005b88:	8526                	mv	a0,s1
    80005b8a:	bd0fe0ef          	jal	80003f5a <iunlockput>
    end_op();
    80005b8e:	ac3fe0ef          	jal	80004650 <end_op>
    return -1;
    80005b92:	557d                	li	a0,-1
    80005b94:	64aa                	ld	s1,136(sp)
    80005b96:	bff9                	j	80005b74 <sys_chdir+0x5c>

0000000080005b98 <sys_exec>:

uint64
sys_exec(void)
{
    80005b98:	7121                	addi	sp,sp,-448
    80005b9a:	ff06                	sd	ra,440(sp)
    80005b9c:	fb22                	sd	s0,432(sp)
    80005b9e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ba0:	e4840593          	addi	a1,s0,-440
    80005ba4:	4505                	li	a0,1
    80005ba6:	d34fd0ef          	jal	800030da <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005baa:	08000613          	li	a2,128
    80005bae:	f5040593          	addi	a1,s0,-176
    80005bb2:	4501                	li	a0,0
    80005bb4:	d42fd0ef          	jal	800030f6 <argstr>
    80005bb8:	87aa                	mv	a5,a0
    return -1;
    80005bba:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005bbc:	0c07c463          	bltz	a5,80005c84 <sys_exec+0xec>
    80005bc0:	f726                	sd	s1,424(sp)
    80005bc2:	f34a                	sd	s2,416(sp)
    80005bc4:	ef4e                	sd	s3,408(sp)
    80005bc6:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005bc8:	10000613          	li	a2,256
    80005bcc:	4581                	li	a1,0
    80005bce:	e5040513          	addi	a0,s0,-432
    80005bd2:	8f6fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bd6:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005bda:	89a6                	mv	s3,s1
    80005bdc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005bde:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005be2:	00391513          	slli	a0,s2,0x3
    80005be6:	e4040593          	addi	a1,s0,-448
    80005bea:	e4843783          	ld	a5,-440(s0)
    80005bee:	953e                	add	a0,a0,a5
    80005bf0:	c44fd0ef          	jal	80003034 <fetchaddr>
    80005bf4:	02054663          	bltz	a0,80005c20 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005bf8:	e4043783          	ld	a5,-448(s0)
    80005bfc:	c3a9                	beqz	a5,80005c3e <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005bfe:	f27fa0ef          	jal	80000b24 <kalloc>
    80005c02:	85aa                	mv	a1,a0
    80005c04:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c08:	cd01                	beqz	a0,80005c20 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c0a:	6605                	lui	a2,0x1
    80005c0c:	e4043503          	ld	a0,-448(s0)
    80005c10:	c6efd0ef          	jal	8000307e <fetchstr>
    80005c14:	00054663          	bltz	a0,80005c20 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005c18:	0905                	addi	s2,s2,1
    80005c1a:	09a1                	addi	s3,s3,8
    80005c1c:	fd4913e3          	bne	s2,s4,80005be2 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c20:	f5040913          	addi	s2,s0,-176
    80005c24:	6088                	ld	a0,0(s1)
    80005c26:	c931                	beqz	a0,80005c7a <sys_exec+0xe2>
    kfree(argv[i]);
    80005c28:	e1bfa0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c2c:	04a1                	addi	s1,s1,8
    80005c2e:	ff249be3          	bne	s1,s2,80005c24 <sys_exec+0x8c>
  return -1;
    80005c32:	557d                	li	a0,-1
    80005c34:	74ba                	ld	s1,424(sp)
    80005c36:	791a                	ld	s2,416(sp)
    80005c38:	69fa                	ld	s3,408(sp)
    80005c3a:	6a5a                	ld	s4,400(sp)
    80005c3c:	a0a1                	j	80005c84 <sys_exec+0xec>
      argv[i] = 0;
    80005c3e:	0009079b          	sext.w	a5,s2
    80005c42:	078e                	slli	a5,a5,0x3
    80005c44:	fd078793          	addi	a5,a5,-48
    80005c48:	97a2                	add	a5,a5,s0
    80005c4a:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005c4e:	e5040593          	addi	a1,s0,-432
    80005c52:	f5040513          	addi	a0,s0,-176
    80005c56:	ba8ff0ef          	jal	80004ffe <exec>
    80005c5a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c5c:	f5040993          	addi	s3,s0,-176
    80005c60:	6088                	ld	a0,0(s1)
    80005c62:	c511                	beqz	a0,80005c6e <sys_exec+0xd6>
    kfree(argv[i]);
    80005c64:	ddffa0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c68:	04a1                	addi	s1,s1,8
    80005c6a:	ff349be3          	bne	s1,s3,80005c60 <sys_exec+0xc8>
  return ret;
    80005c6e:	854a                	mv	a0,s2
    80005c70:	74ba                	ld	s1,424(sp)
    80005c72:	791a                	ld	s2,416(sp)
    80005c74:	69fa                	ld	s3,408(sp)
    80005c76:	6a5a                	ld	s4,400(sp)
    80005c78:	a031                	j	80005c84 <sys_exec+0xec>
  return -1;
    80005c7a:	557d                	li	a0,-1
    80005c7c:	74ba                	ld	s1,424(sp)
    80005c7e:	791a                	ld	s2,416(sp)
    80005c80:	69fa                	ld	s3,408(sp)
    80005c82:	6a5a                	ld	s4,400(sp)
}
    80005c84:	70fa                	ld	ra,440(sp)
    80005c86:	745a                	ld	s0,432(sp)
    80005c88:	6139                	addi	sp,sp,448
    80005c8a:	8082                	ret

0000000080005c8c <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c8c:	7139                	addi	sp,sp,-64
    80005c8e:	fc06                	sd	ra,56(sp)
    80005c90:	f822                	sd	s0,48(sp)
    80005c92:	f426                	sd	s1,40(sp)
    80005c94:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c96:	cb1fb0ef          	jal	80001946 <myproc>
    80005c9a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005c9c:	fd840593          	addi	a1,s0,-40
    80005ca0:	4501                	li	a0,0
    80005ca2:	c38fd0ef          	jal	800030da <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ca6:	fc840593          	addi	a1,s0,-56
    80005caa:	fd040513          	addi	a0,s0,-48
    80005cae:	85cff0ef          	jal	80004d0a <pipealloc>
    return -1;
    80005cb2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cb4:	0a054463          	bltz	a0,80005d5c <sys_pipe+0xd0>
  fd0 = -1;
    80005cb8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005cbc:	fd043503          	ld	a0,-48(s0)
    80005cc0:	f08ff0ef          	jal	800053c8 <fdalloc>
    80005cc4:	fca42223          	sw	a0,-60(s0)
    80005cc8:	08054163          	bltz	a0,80005d4a <sys_pipe+0xbe>
    80005ccc:	fc843503          	ld	a0,-56(s0)
    80005cd0:	ef8ff0ef          	jal	800053c8 <fdalloc>
    80005cd4:	fca42023          	sw	a0,-64(s0)
    80005cd8:	06054063          	bltz	a0,80005d38 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cdc:	4691                	li	a3,4
    80005cde:	fc440613          	addi	a2,s0,-60
    80005ce2:	fd843583          	ld	a1,-40(s0)
    80005ce6:	68a8                	ld	a0,80(s1)
    80005ce8:	86bfb0ef          	jal	80001552 <copyout>
    80005cec:	00054e63          	bltz	a0,80005d08 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005cf0:	4691                	li	a3,4
    80005cf2:	fc040613          	addi	a2,s0,-64
    80005cf6:	fd843583          	ld	a1,-40(s0)
    80005cfa:	0591                	addi	a1,a1,4
    80005cfc:	68a8                	ld	a0,80(s1)
    80005cfe:	855fb0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d02:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d04:	04055c63          	bgez	a0,80005d5c <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005d08:	fc442783          	lw	a5,-60(s0)
    80005d0c:	07e9                	addi	a5,a5,26
    80005d0e:	078e                	slli	a5,a5,0x3
    80005d10:	97a6                	add	a5,a5,s1
    80005d12:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d16:	fc042783          	lw	a5,-64(s0)
    80005d1a:	07e9                	addi	a5,a5,26
    80005d1c:	078e                	slli	a5,a5,0x3
    80005d1e:	94be                	add	s1,s1,a5
    80005d20:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d24:	fd043503          	ld	a0,-48(s0)
    80005d28:	cd9fe0ef          	jal	80004a00 <fileclose>
    fileclose(wf);
    80005d2c:	fc843503          	ld	a0,-56(s0)
    80005d30:	cd1fe0ef          	jal	80004a00 <fileclose>
    return -1;
    80005d34:	57fd                	li	a5,-1
    80005d36:	a01d                	j	80005d5c <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005d38:	fc442783          	lw	a5,-60(s0)
    80005d3c:	0007c763          	bltz	a5,80005d4a <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005d40:	07e9                	addi	a5,a5,26
    80005d42:	078e                	slli	a5,a5,0x3
    80005d44:	97a6                	add	a5,a5,s1
    80005d46:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005d4a:	fd043503          	ld	a0,-48(s0)
    80005d4e:	cb3fe0ef          	jal	80004a00 <fileclose>
    fileclose(wf);
    80005d52:	fc843503          	ld	a0,-56(s0)
    80005d56:	cabfe0ef          	jal	80004a00 <fileclose>
    return -1;
    80005d5a:	57fd                	li	a5,-1
}
    80005d5c:	853e                	mv	a0,a5
    80005d5e:	70e2                	ld	ra,56(sp)
    80005d60:	7442                	ld	s0,48(sp)
    80005d62:	74a2                	ld	s1,40(sp)
    80005d64:	6121                	addi	sp,sp,64
    80005d66:	8082                	ret
	...

0000000080005d70 <kernelvec>:
    80005d70:	7111                	addi	sp,sp,-256
    80005d72:	e006                	sd	ra,0(sp)
    80005d74:	e40a                	sd	sp,8(sp)
    80005d76:	e80e                	sd	gp,16(sp)
    80005d78:	ec12                	sd	tp,24(sp)
    80005d7a:	f016                	sd	t0,32(sp)
    80005d7c:	f41a                	sd	t1,40(sp)
    80005d7e:	f81e                	sd	t2,48(sp)
    80005d80:	e4aa                	sd	a0,72(sp)
    80005d82:	e8ae                	sd	a1,80(sp)
    80005d84:	ecb2                	sd	a2,88(sp)
    80005d86:	f0b6                	sd	a3,96(sp)
    80005d88:	f4ba                	sd	a4,104(sp)
    80005d8a:	f8be                	sd	a5,112(sp)
    80005d8c:	fcc2                	sd	a6,120(sp)
    80005d8e:	e146                	sd	a7,128(sp)
    80005d90:	edf2                	sd	t3,216(sp)
    80005d92:	f1f6                	sd	t4,224(sp)
    80005d94:	f5fa                	sd	t5,232(sp)
    80005d96:	f9fe                	sd	t6,240(sp)
    80005d98:	9a2fd0ef          	jal	80002f3a <kerneltrap>
    80005d9c:	6082                	ld	ra,0(sp)
    80005d9e:	6122                	ld	sp,8(sp)
    80005da0:	61c2                	ld	gp,16(sp)
    80005da2:	7282                	ld	t0,32(sp)
    80005da4:	7322                	ld	t1,40(sp)
    80005da6:	73c2                	ld	t2,48(sp)
    80005da8:	6526                	ld	a0,72(sp)
    80005daa:	65c6                	ld	a1,80(sp)
    80005dac:	6666                	ld	a2,88(sp)
    80005dae:	7686                	ld	a3,96(sp)
    80005db0:	7726                	ld	a4,104(sp)
    80005db2:	77c6                	ld	a5,112(sp)
    80005db4:	7866                	ld	a6,120(sp)
    80005db6:	688a                	ld	a7,128(sp)
    80005db8:	6e6e                	ld	t3,216(sp)
    80005dba:	7e8e                	ld	t4,224(sp)
    80005dbc:	7f2e                	ld	t5,232(sp)
    80005dbe:	7fce                	ld	t6,240(sp)
    80005dc0:	6111                	addi	sp,sp,256
    80005dc2:	10200073          	sret
	...

0000000080005dce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005dce:	1141                	addi	sp,sp,-16
    80005dd0:	e422                	sd	s0,8(sp)
    80005dd2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005dd4:	0c0007b7          	lui	a5,0xc000
    80005dd8:	4705                	li	a4,1
    80005dda:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ddc:	0c0007b7          	lui	a5,0xc000
    80005de0:	c3d8                	sw	a4,4(a5)
}
    80005de2:	6422                	ld	s0,8(sp)
    80005de4:	0141                	addi	sp,sp,16
    80005de6:	8082                	ret

0000000080005de8 <plicinithart>:

void
plicinithart(void)
{
    80005de8:	1141                	addi	sp,sp,-16
    80005dea:	e406                	sd	ra,8(sp)
    80005dec:	e022                	sd	s0,0(sp)
    80005dee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005df0:	b2bfb0ef          	jal	8000191a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005df4:	0085171b          	slliw	a4,a0,0x8
    80005df8:	0c0027b7          	lui	a5,0xc002
    80005dfc:	97ba                	add	a5,a5,a4
    80005dfe:	40200713          	li	a4,1026
    80005e02:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e06:	00d5151b          	slliw	a0,a0,0xd
    80005e0a:	0c2017b7          	lui	a5,0xc201
    80005e0e:	97aa                	add	a5,a5,a0
    80005e10:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005e14:	60a2                	ld	ra,8(sp)
    80005e16:	6402                	ld	s0,0(sp)
    80005e18:	0141                	addi	sp,sp,16
    80005e1a:	8082                	ret

0000000080005e1c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e1c:	1141                	addi	sp,sp,-16
    80005e1e:	e406                	sd	ra,8(sp)
    80005e20:	e022                	sd	s0,0(sp)
    80005e22:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e24:	af7fb0ef          	jal	8000191a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e28:	00d5151b          	slliw	a0,a0,0xd
    80005e2c:	0c2017b7          	lui	a5,0xc201
    80005e30:	97aa                	add	a5,a5,a0
  return irq;
}
    80005e32:	43c8                	lw	a0,4(a5)
    80005e34:	60a2                	ld	ra,8(sp)
    80005e36:	6402                	ld	s0,0(sp)
    80005e38:	0141                	addi	sp,sp,16
    80005e3a:	8082                	ret

0000000080005e3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e3c:	1101                	addi	sp,sp,-32
    80005e3e:	ec06                	sd	ra,24(sp)
    80005e40:	e822                	sd	s0,16(sp)
    80005e42:	e426                	sd	s1,8(sp)
    80005e44:	1000                	addi	s0,sp,32
    80005e46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e48:	ad3fb0ef          	jal	8000191a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e4c:	00d5151b          	slliw	a0,a0,0xd
    80005e50:	0c2017b7          	lui	a5,0xc201
    80005e54:	97aa                	add	a5,a5,a0
    80005e56:	c3c4                	sw	s1,4(a5)
}
    80005e58:	60e2                	ld	ra,24(sp)
    80005e5a:	6442                	ld	s0,16(sp)
    80005e5c:	64a2                	ld	s1,8(sp)
    80005e5e:	6105                	addi	sp,sp,32
    80005e60:	8082                	ret

0000000080005e62 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e62:	1141                	addi	sp,sp,-16
    80005e64:	e406                	sd	ra,8(sp)
    80005e66:	e022                	sd	s0,0(sp)
    80005e68:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e6a:	479d                	li	a5,7
    80005e6c:	04a7ca63          	blt	a5,a0,80005ec0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005e70:	000e5797          	auipc	a5,0xe5
    80005e74:	48878793          	addi	a5,a5,1160 # 800eb2f8 <disk>
    80005e78:	97aa                	add	a5,a5,a0
    80005e7a:	0187c783          	lbu	a5,24(a5)
    80005e7e:	e7b9                	bnez	a5,80005ecc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e80:	00451693          	slli	a3,a0,0x4
    80005e84:	000e5797          	auipc	a5,0xe5
    80005e88:	47478793          	addi	a5,a5,1140 # 800eb2f8 <disk>
    80005e8c:	6398                	ld	a4,0(a5)
    80005e8e:	9736                	add	a4,a4,a3
    80005e90:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005e94:	6398                	ld	a4,0(a5)
    80005e96:	9736                	add	a4,a4,a3
    80005e98:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005e9c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ea0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ea4:	97aa                	add	a5,a5,a0
    80005ea6:	4705                	li	a4,1
    80005ea8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005eac:	000e5517          	auipc	a0,0xe5
    80005eb0:	46450513          	addi	a0,a0,1124 # 800eb310 <disk+0x18>
    80005eb4:	83dfc0ef          	jal	800026f0 <wakeup>
}
    80005eb8:	60a2                	ld	ra,8(sp)
    80005eba:	6402                	ld	s0,0(sp)
    80005ebc:	0141                	addi	sp,sp,16
    80005ebe:	8082                	ret
    panic("free_desc 1");
    80005ec0:	00003517          	auipc	a0,0x3
    80005ec4:	8b850513          	addi	a0,a0,-1864 # 80008778 <etext+0x778>
    80005ec8:	8cdfa0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    80005ecc:	00003517          	auipc	a0,0x3
    80005ed0:	8bc50513          	addi	a0,a0,-1860 # 80008788 <etext+0x788>
    80005ed4:	8c1fa0ef          	jal	80000794 <panic>

0000000080005ed8 <virtio_disk_init>:
{
    80005ed8:	1101                	addi	sp,sp,-32
    80005eda:	ec06                	sd	ra,24(sp)
    80005edc:	e822                	sd	s0,16(sp)
    80005ede:	e426                	sd	s1,8(sp)
    80005ee0:	e04a                	sd	s2,0(sp)
    80005ee2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ee4:	00003597          	auipc	a1,0x3
    80005ee8:	8b458593          	addi	a1,a1,-1868 # 80008798 <etext+0x798>
    80005eec:	000e5517          	auipc	a0,0xe5
    80005ef0:	53450513          	addi	a0,a0,1332 # 800eb420 <disk+0x128>
    80005ef4:	c81fa0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ef8:	100017b7          	lui	a5,0x10001
    80005efc:	4398                	lw	a4,0(a5)
    80005efe:	2701                	sext.w	a4,a4
    80005f00:	747277b7          	lui	a5,0x74727
    80005f04:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f08:	18f71063          	bne	a4,a5,80006088 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f0c:	100017b7          	lui	a5,0x10001
    80005f10:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005f12:	439c                	lw	a5,0(a5)
    80005f14:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f16:	4709                	li	a4,2
    80005f18:	16e79863          	bne	a5,a4,80006088 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f1c:	100017b7          	lui	a5,0x10001
    80005f20:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005f22:	439c                	lw	a5,0(a5)
    80005f24:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f26:	16e79163          	bne	a5,a4,80006088 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f2a:	100017b7          	lui	a5,0x10001
    80005f2e:	47d8                	lw	a4,12(a5)
    80005f30:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f32:	554d47b7          	lui	a5,0x554d4
    80005f36:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f3a:	14f71763          	bne	a4,a5,80006088 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f3e:	100017b7          	lui	a5,0x10001
    80005f42:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f46:	4705                	li	a4,1
    80005f48:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f4a:	470d                	li	a4,3
    80005f4c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f4e:	10001737          	lui	a4,0x10001
    80005f52:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005f54:	c7ffe737          	lui	a4,0xc7ffe
    80005f58:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47f13327>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f5c:	8ef9                	and	a3,a3,a4
    80005f5e:	10001737          	lui	a4,0x10001
    80005f62:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f64:	472d                	li	a4,11
    80005f66:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f68:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005f6c:	439c                	lw	a5,0(a5)
    80005f6e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f72:	8ba1                	andi	a5,a5,8
    80005f74:	12078063          	beqz	a5,80006094 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f78:	100017b7          	lui	a5,0x10001
    80005f7c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005f80:	100017b7          	lui	a5,0x10001
    80005f84:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005f88:	439c                	lw	a5,0(a5)
    80005f8a:	2781                	sext.w	a5,a5
    80005f8c:	10079a63          	bnez	a5,800060a0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f90:	100017b7          	lui	a5,0x10001
    80005f94:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005f98:	439c                	lw	a5,0(a5)
    80005f9a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f9c:	10078863          	beqz	a5,800060ac <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005fa0:	471d                	li	a4,7
    80005fa2:	10f77b63          	bgeu	a4,a5,800060b8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005fa6:	b7ffa0ef          	jal	80000b24 <kalloc>
    80005faa:	000e5497          	auipc	s1,0xe5
    80005fae:	34e48493          	addi	s1,s1,846 # 800eb2f8 <disk>
    80005fb2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005fb4:	b71fa0ef          	jal	80000b24 <kalloc>
    80005fb8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005fba:	b6bfa0ef          	jal	80000b24 <kalloc>
    80005fbe:	87aa                	mv	a5,a0
    80005fc0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005fc2:	6088                	ld	a0,0(s1)
    80005fc4:	10050063          	beqz	a0,800060c4 <virtio_disk_init+0x1ec>
    80005fc8:	000e5717          	auipc	a4,0xe5
    80005fcc:	33873703          	ld	a4,824(a4) # 800eb300 <disk+0x8>
    80005fd0:	0e070a63          	beqz	a4,800060c4 <virtio_disk_init+0x1ec>
    80005fd4:	0e078863          	beqz	a5,800060c4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005fd8:	6605                	lui	a2,0x1
    80005fda:	4581                	li	a1,0
    80005fdc:	cedfa0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005fe0:	000e5497          	auipc	s1,0xe5
    80005fe4:	31848493          	addi	s1,s1,792 # 800eb2f8 <disk>
    80005fe8:	6605                	lui	a2,0x1
    80005fea:	4581                	li	a1,0
    80005fec:	6488                	ld	a0,8(s1)
    80005fee:	cdbfa0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005ff2:	6605                	lui	a2,0x1
    80005ff4:	4581                	li	a1,0
    80005ff6:	6888                	ld	a0,16(s1)
    80005ff8:	cd1fa0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ffc:	100017b7          	lui	a5,0x10001
    80006000:	4721                	li	a4,8
    80006002:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006004:	4098                	lw	a4,0(s1)
    80006006:	100017b7          	lui	a5,0x10001
    8000600a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000600e:	40d8                	lw	a4,4(s1)
    80006010:	100017b7          	lui	a5,0x10001
    80006014:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006018:	649c                	ld	a5,8(s1)
    8000601a:	0007869b          	sext.w	a3,a5
    8000601e:	10001737          	lui	a4,0x10001
    80006022:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006026:	9781                	srai	a5,a5,0x20
    80006028:	10001737          	lui	a4,0x10001
    8000602c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006030:	689c                	ld	a5,16(s1)
    80006032:	0007869b          	sext.w	a3,a5
    80006036:	10001737          	lui	a4,0x10001
    8000603a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000603e:	9781                	srai	a5,a5,0x20
    80006040:	10001737          	lui	a4,0x10001
    80006044:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006048:	10001737          	lui	a4,0x10001
    8000604c:	4785                	li	a5,1
    8000604e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006050:	00f48c23          	sb	a5,24(s1)
    80006054:	00f48ca3          	sb	a5,25(s1)
    80006058:	00f48d23          	sb	a5,26(s1)
    8000605c:	00f48da3          	sb	a5,27(s1)
    80006060:	00f48e23          	sb	a5,28(s1)
    80006064:	00f48ea3          	sb	a5,29(s1)
    80006068:	00f48f23          	sb	a5,30(s1)
    8000606c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006070:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006074:	100017b7          	lui	a5,0x10001
    80006078:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000607c:	60e2                	ld	ra,24(sp)
    8000607e:	6442                	ld	s0,16(sp)
    80006080:	64a2                	ld	s1,8(sp)
    80006082:	6902                	ld	s2,0(sp)
    80006084:	6105                	addi	sp,sp,32
    80006086:	8082                	ret
    panic("could not find virtio disk");
    80006088:	00002517          	auipc	a0,0x2
    8000608c:	72050513          	addi	a0,a0,1824 # 800087a8 <etext+0x7a8>
    80006090:	f04fa0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006094:	00002517          	auipc	a0,0x2
    80006098:	73450513          	addi	a0,a0,1844 # 800087c8 <etext+0x7c8>
    8000609c:	ef8fa0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    800060a0:	00002517          	auipc	a0,0x2
    800060a4:	74850513          	addi	a0,a0,1864 # 800087e8 <etext+0x7e8>
    800060a8:	eecfa0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    800060ac:	00002517          	auipc	a0,0x2
    800060b0:	75c50513          	addi	a0,a0,1884 # 80008808 <etext+0x808>
    800060b4:	ee0fa0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    800060b8:	00002517          	auipc	a0,0x2
    800060bc:	77050513          	addi	a0,a0,1904 # 80008828 <etext+0x828>
    800060c0:	ed4fa0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    800060c4:	00002517          	auipc	a0,0x2
    800060c8:	78450513          	addi	a0,a0,1924 # 80008848 <etext+0x848>
    800060cc:	ec8fa0ef          	jal	80000794 <panic>

00000000800060d0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060d0:	7159                	addi	sp,sp,-112
    800060d2:	f486                	sd	ra,104(sp)
    800060d4:	f0a2                	sd	s0,96(sp)
    800060d6:	eca6                	sd	s1,88(sp)
    800060d8:	e8ca                	sd	s2,80(sp)
    800060da:	e4ce                	sd	s3,72(sp)
    800060dc:	e0d2                	sd	s4,64(sp)
    800060de:	fc56                	sd	s5,56(sp)
    800060e0:	f85a                	sd	s6,48(sp)
    800060e2:	f45e                	sd	s7,40(sp)
    800060e4:	f062                	sd	s8,32(sp)
    800060e6:	ec66                	sd	s9,24(sp)
    800060e8:	1880                	addi	s0,sp,112
    800060ea:	8a2a                	mv	s4,a0
    800060ec:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060ee:	00c52c83          	lw	s9,12(a0)
    800060f2:	001c9c9b          	slliw	s9,s9,0x1
    800060f6:	1c82                	slli	s9,s9,0x20
    800060f8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800060fc:	000e5517          	auipc	a0,0xe5
    80006100:	32450513          	addi	a0,a0,804 # 800eb420 <disk+0x128>
    80006104:	af1fa0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80006108:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000610a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000610c:	000e5b17          	auipc	s6,0xe5
    80006110:	1ecb0b13          	addi	s6,s6,492 # 800eb2f8 <disk>
  for(int i = 0; i < 3; i++){
    80006114:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006116:	000e5c17          	auipc	s8,0xe5
    8000611a:	30ac0c13          	addi	s8,s8,778 # 800eb420 <disk+0x128>
    8000611e:	a8b9                	j	8000617c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80006120:	00fb0733          	add	a4,s6,a5
    80006124:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006128:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000612a:	0207c563          	bltz	a5,80006154 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000612e:	2905                	addiw	s2,s2,1
    80006130:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006132:	05590963          	beq	s2,s5,80006184 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80006136:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006138:	000e5717          	auipc	a4,0xe5
    8000613c:	1c070713          	addi	a4,a4,448 # 800eb2f8 <disk>
    80006140:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006142:	01874683          	lbu	a3,24(a4)
    80006146:	fee9                	bnez	a3,80006120 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80006148:	2785                	addiw	a5,a5,1
    8000614a:	0705                	addi	a4,a4,1
    8000614c:	fe979be3          	bne	a5,s1,80006142 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80006150:	57fd                	li	a5,-1
    80006152:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006154:	01205d63          	blez	s2,8000616e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006158:	f9042503          	lw	a0,-112(s0)
    8000615c:	d07ff0ef          	jal	80005e62 <free_desc>
      for(int j = 0; j < i; j++)
    80006160:	4785                	li	a5,1
    80006162:	0127d663          	bge	a5,s2,8000616e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006166:	f9442503          	lw	a0,-108(s0)
    8000616a:	cf9ff0ef          	jal	80005e62 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000616e:	85e2                	mv	a1,s8
    80006170:	000e5517          	auipc	a0,0xe5
    80006174:	1a050513          	addi	a0,a0,416 # 800eb310 <disk+0x18>
    80006178:	d2cfc0ef          	jal	800026a4 <sleep>
  for(int i = 0; i < 3; i++){
    8000617c:	f9040613          	addi	a2,s0,-112
    80006180:	894e                	mv	s2,s3
    80006182:	bf55                	j	80006136 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006184:	f9042503          	lw	a0,-112(s0)
    80006188:	00451693          	slli	a3,a0,0x4

  if(write)
    8000618c:	000e5797          	auipc	a5,0xe5
    80006190:	16c78793          	addi	a5,a5,364 # 800eb2f8 <disk>
    80006194:	00a50713          	addi	a4,a0,10
    80006198:	0712                	slli	a4,a4,0x4
    8000619a:	973e                	add	a4,a4,a5
    8000619c:	01703633          	snez	a2,s7
    800061a0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800061a2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800061a6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800061aa:	6398                	ld	a4,0(a5)
    800061ac:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061ae:	0a868613          	addi	a2,a3,168
    800061b2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800061b4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800061b6:	6390                	ld	a2,0(a5)
    800061b8:	00d605b3          	add	a1,a2,a3
    800061bc:	4741                	li	a4,16
    800061be:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061c0:	4805                	li	a6,1
    800061c2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800061c6:	f9442703          	lw	a4,-108(s0)
    800061ca:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800061ce:	0712                	slli	a4,a4,0x4
    800061d0:	963a                	add	a2,a2,a4
    800061d2:	058a0593          	addi	a1,s4,88
    800061d6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800061d8:	0007b883          	ld	a7,0(a5)
    800061dc:	9746                	add	a4,a4,a7
    800061de:	40000613          	li	a2,1024
    800061e2:	c710                	sw	a2,8(a4)
  if(write)
    800061e4:	001bb613          	seqz	a2,s7
    800061e8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061ec:	00166613          	ori	a2,a2,1
    800061f0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800061f4:	f9842583          	lw	a1,-104(s0)
    800061f8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800061fc:	00250613          	addi	a2,a0,2
    80006200:	0612                	slli	a2,a2,0x4
    80006202:	963e                	add	a2,a2,a5
    80006204:	577d                	li	a4,-1
    80006206:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000620a:	0592                	slli	a1,a1,0x4
    8000620c:	98ae                	add	a7,a7,a1
    8000620e:	03068713          	addi	a4,a3,48
    80006212:	973e                	add	a4,a4,a5
    80006214:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006218:	6398                	ld	a4,0(a5)
    8000621a:	972e                	add	a4,a4,a1
    8000621c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006220:	4689                	li	a3,2
    80006222:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006226:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000622a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000622e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006232:	6794                	ld	a3,8(a5)
    80006234:	0026d703          	lhu	a4,2(a3)
    80006238:	8b1d                	andi	a4,a4,7
    8000623a:	0706                	slli	a4,a4,0x1
    8000623c:	96ba                	add	a3,a3,a4
    8000623e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006242:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006246:	6798                	ld	a4,8(a5)
    80006248:	00275783          	lhu	a5,2(a4)
    8000624c:	2785                	addiw	a5,a5,1
    8000624e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006252:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006256:	100017b7          	lui	a5,0x10001
    8000625a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000625e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006262:	000e5917          	auipc	s2,0xe5
    80006266:	1be90913          	addi	s2,s2,446 # 800eb420 <disk+0x128>
  while(b->disk == 1) {
    8000626a:	4485                	li	s1,1
    8000626c:	01079a63          	bne	a5,a6,80006280 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006270:	85ca                	mv	a1,s2
    80006272:	8552                	mv	a0,s4
    80006274:	c30fc0ef          	jal	800026a4 <sleep>
  while(b->disk == 1) {
    80006278:	004a2783          	lw	a5,4(s4)
    8000627c:	fe978ae3          	beq	a5,s1,80006270 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006280:	f9042903          	lw	s2,-112(s0)
    80006284:	00290713          	addi	a4,s2,2
    80006288:	0712                	slli	a4,a4,0x4
    8000628a:	000e5797          	auipc	a5,0xe5
    8000628e:	06e78793          	addi	a5,a5,110 # 800eb2f8 <disk>
    80006292:	97ba                	add	a5,a5,a4
    80006294:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006298:	000e5997          	auipc	s3,0xe5
    8000629c:	06098993          	addi	s3,s3,96 # 800eb2f8 <disk>
    800062a0:	00491713          	slli	a4,s2,0x4
    800062a4:	0009b783          	ld	a5,0(s3)
    800062a8:	97ba                	add	a5,a5,a4
    800062aa:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800062ae:	854a                	mv	a0,s2
    800062b0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800062b4:	bafff0ef          	jal	80005e62 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800062b8:	8885                	andi	s1,s1,1
    800062ba:	f0fd                	bnez	s1,800062a0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062bc:	000e5517          	auipc	a0,0xe5
    800062c0:	16450513          	addi	a0,a0,356 # 800eb420 <disk+0x128>
    800062c4:	9c9fa0ef          	jal	80000c8c <release>
}
    800062c8:	70a6                	ld	ra,104(sp)
    800062ca:	7406                	ld	s0,96(sp)
    800062cc:	64e6                	ld	s1,88(sp)
    800062ce:	6946                	ld	s2,80(sp)
    800062d0:	69a6                	ld	s3,72(sp)
    800062d2:	6a06                	ld	s4,64(sp)
    800062d4:	7ae2                	ld	s5,56(sp)
    800062d6:	7b42                	ld	s6,48(sp)
    800062d8:	7ba2                	ld	s7,40(sp)
    800062da:	7c02                	ld	s8,32(sp)
    800062dc:	6ce2                	ld	s9,24(sp)
    800062de:	6165                	addi	sp,sp,112
    800062e0:	8082                	ret

00000000800062e2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800062e2:	1101                	addi	sp,sp,-32
    800062e4:	ec06                	sd	ra,24(sp)
    800062e6:	e822                	sd	s0,16(sp)
    800062e8:	e426                	sd	s1,8(sp)
    800062ea:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800062ec:	000e5497          	auipc	s1,0xe5
    800062f0:	00c48493          	addi	s1,s1,12 # 800eb2f8 <disk>
    800062f4:	000e5517          	auipc	a0,0xe5
    800062f8:	12c50513          	addi	a0,a0,300 # 800eb420 <disk+0x128>
    800062fc:	8f9fa0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006300:	100017b7          	lui	a5,0x10001
    80006304:	53b8                	lw	a4,96(a5)
    80006306:	8b0d                	andi	a4,a4,3
    80006308:	100017b7          	lui	a5,0x10001
    8000630c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000630e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006312:	689c                	ld	a5,16(s1)
    80006314:	0204d703          	lhu	a4,32(s1)
    80006318:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000631c:	04f70663          	beq	a4,a5,80006368 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80006320:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006324:	6898                	ld	a4,16(s1)
    80006326:	0204d783          	lhu	a5,32(s1)
    8000632a:	8b9d                	andi	a5,a5,7
    8000632c:	078e                	slli	a5,a5,0x3
    8000632e:	97ba                	add	a5,a5,a4
    80006330:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006332:	00278713          	addi	a4,a5,2
    80006336:	0712                	slli	a4,a4,0x4
    80006338:	9726                	add	a4,a4,s1
    8000633a:	01074703          	lbu	a4,16(a4)
    8000633e:	e321                	bnez	a4,8000637e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006340:	0789                	addi	a5,a5,2
    80006342:	0792                	slli	a5,a5,0x4
    80006344:	97a6                	add	a5,a5,s1
    80006346:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006348:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000634c:	ba4fc0ef          	jal	800026f0 <wakeup>

    disk.used_idx += 1;
    80006350:	0204d783          	lhu	a5,32(s1)
    80006354:	2785                	addiw	a5,a5,1
    80006356:	17c2                	slli	a5,a5,0x30
    80006358:	93c1                	srli	a5,a5,0x30
    8000635a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000635e:	6898                	ld	a4,16(s1)
    80006360:	00275703          	lhu	a4,2(a4)
    80006364:	faf71ee3          	bne	a4,a5,80006320 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006368:	000e5517          	auipc	a0,0xe5
    8000636c:	0b850513          	addi	a0,a0,184 # 800eb420 <disk+0x128>
    80006370:	91dfa0ef          	jal	80000c8c <release>
}
    80006374:	60e2                	ld	ra,24(sp)
    80006376:	6442                	ld	s0,16(sp)
    80006378:	64a2                	ld	s1,8(sp)
    8000637a:	6105                	addi	sp,sp,32
    8000637c:	8082                	ret
      panic("virtio_disk_intr status");
    8000637e:	00002517          	auipc	a0,0x2
    80006382:	4e250513          	addi	a0,a0,1250 # 80008860 <etext+0x860>
    80006386:	c0efa0ef          	jal	80000794 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
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
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
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
