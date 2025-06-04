
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	a7010113          	addi	sp,sp,-1424 # 80007a70 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd505f>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e0078793          	addi	a5,a5,-512 # 80000e84 <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a6:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	711d                	addi	sp,sp,-96
    800000d6:	ec86                	sd	ra,88(sp)
    800000d8:	e8a2                	sd	s0,80(sp)
    800000da:	e0ca                	sd	s2,64(sp)
    800000dc:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    800000de:	04c05863          	blez	a2,8000012e <consolewrite+0x5a>
    800000e2:	e4a6                	sd	s1,72(sp)
    800000e4:	fc4e                	sd	s3,56(sp)
    800000e6:	f852                	sd	s4,48(sp)
    800000e8:	f456                	sd	s5,40(sp)
    800000ea:	f05a                	sd	s6,32(sp)
    800000ec:	ec5e                	sd	s7,24(sp)
    800000ee:	8a2a                	mv	s4,a0
    800000f0:	84ae                	mv	s1,a1
    800000f2:	89b2                	mv	s3,a2
    800000f4:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000f6:	faf40b93          	addi	s7,s0,-81
    800000fa:	4b05                	li	s6,1
    800000fc:	5afd                	li	s5,-1
    800000fe:	86da                	mv	a3,s6
    80000100:	8626                	mv	a2,s1
    80000102:	85d2                	mv	a1,s4
    80000104:	855e                	mv	a0,s7
    80000106:	198020ef          	jal	8000229e <either_copyin>
    8000010a:	03550463          	beq	a0,s5,80000132 <consolewrite+0x5e>
      break;
    uartputc(c);
    8000010e:	faf44503          	lbu	a0,-81(s0)
    80000112:	02d000ef          	jal	8000093e <uartputc>
  for(i = 0; i < n; i++){
    80000116:	2905                	addiw	s2,s2,1
    80000118:	0485                	addi	s1,s1,1
    8000011a:	ff2992e3          	bne	s3,s2,800000fe <consolewrite+0x2a>
    8000011e:	894e                	mv	s2,s3
    80000120:	64a6                	ld	s1,72(sp)
    80000122:	79e2                	ld	s3,56(sp)
    80000124:	7a42                	ld	s4,48(sp)
    80000126:	7aa2                	ld	s5,40(sp)
    80000128:	7b02                	ld	s6,32(sp)
    8000012a:	6be2                	ld	s7,24(sp)
    8000012c:	a809                	j	8000013e <consolewrite+0x6a>
    8000012e:	4901                	li	s2,0
    80000130:	a039                	j	8000013e <consolewrite+0x6a>
    80000132:	64a6                	ld	s1,72(sp)
    80000134:	79e2                	ld	s3,56(sp)
    80000136:	7a42                	ld	s4,48(sp)
    80000138:	7aa2                	ld	s5,40(sp)
    8000013a:	7b02                	ld	s6,32(sp)
    8000013c:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60e6                	ld	ra,88(sp)
    80000142:	6446                	ld	s0,80(sp)
    80000144:	6906                	ld	s2,64(sp)
    80000146:	6125                	addi	sp,sp,96
    80000148:	8082                	ret

000000008000014a <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014a:	711d                	addi	sp,sp,-96
    8000014c:	ec86                	sd	ra,88(sp)
    8000014e:	e8a2                	sd	s0,80(sp)
    80000150:	e4a6                	sd	s1,72(sp)
    80000152:	e0ca                	sd	s2,64(sp)
    80000154:	fc4e                	sd	s3,56(sp)
    80000156:	f852                	sd	s4,48(sp)
    80000158:	f456                	sd	s5,40(sp)
    8000015a:	f05a                	sd	s6,32(sp)
    8000015c:	1080                	addi	s0,sp,96
    8000015e:	8aaa                	mv	s5,a0
    80000160:	8a2e                	mv	s4,a1
    80000162:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000164:	8b32                	mv	s6,a2
  acquire(&cons.lock);
    80000166:	00010517          	auipc	a0,0x10
    8000016a:	90a50513          	addi	a0,a0,-1782 # 8000fa70 <cons>
    8000016e:	291000ef          	jal	80000bfe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000172:	00010497          	auipc	s1,0x10
    80000176:	8fe48493          	addi	s1,s1,-1794 # 8000fa70 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000017a:	00010917          	auipc	s2,0x10
    8000017e:	98e90913          	addi	s2,s2,-1650 # 8000fb08 <cons+0x98>
  while(n > 0){
    80000182:	0b305b63          	blez	s3,80000238 <consoleread+0xee>
    while(cons.r == cons.w){
    80000186:	0984a783          	lw	a5,152(s1)
    8000018a:	09c4a703          	lw	a4,156(s1)
    8000018e:	0af71063          	bne	a4,a5,8000022e <consoleread+0xe4>
      if(killed(myproc())){
    80000192:	74a010ef          	jal	800018dc <myproc>
    80000196:	7a1010ef          	jal	80002136 <killed>
    8000019a:	e12d                	bnez	a0,800001fc <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    8000019c:	85a6                	mv	a1,s1
    8000019e:	854a                	mv	a0,s2
    800001a0:	55f010ef          	jal	80001efe <sleep>
    while(cons.r == cons.w){
    800001a4:	0984a783          	lw	a5,152(s1)
    800001a8:	09c4a703          	lw	a4,156(s1)
    800001ac:	fef703e3          	beq	a4,a5,80000192 <consoleread+0x48>
    800001b0:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001b2:	00010717          	auipc	a4,0x10
    800001b6:	8be70713          	addi	a4,a4,-1858 # 8000fa70 <cons>
    800001ba:	0017869b          	addiw	a3,a5,1
    800001be:	08d72c23          	sw	a3,152(a4)
    800001c2:	07f7f693          	andi	a3,a5,127
    800001c6:	9736                	add	a4,a4,a3
    800001c8:	01874703          	lbu	a4,24(a4)
    800001cc:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001d0:	4691                	li	a3,4
    800001d2:	04db8663          	beq	s7,a3,8000021e <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001d6:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001da:	4685                	li	a3,1
    800001dc:	faf40613          	addi	a2,s0,-81
    800001e0:	85d2                	mv	a1,s4
    800001e2:	8556                	mv	a0,s5
    800001e4:	070020ef          	jal	80002254 <either_copyout>
    800001e8:	57fd                	li	a5,-1
    800001ea:	04f50663          	beq	a0,a5,80000236 <consoleread+0xec>
      break;

    dst++;
    800001ee:	0a05                	addi	s4,s4,1
    --n;
    800001f0:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001f2:	47a9                	li	a5,10
    800001f4:	04fb8b63          	beq	s7,a5,8000024a <consoleread+0x100>
    800001f8:	6be2                	ld	s7,24(sp)
    800001fa:	b761                	j	80000182 <consoleread+0x38>
        release(&cons.lock);
    800001fc:	00010517          	auipc	a0,0x10
    80000200:	87450513          	addi	a0,a0,-1932 # 8000fa70 <cons>
    80000204:	28f000ef          	jal	80000c92 <release>
        return -1;
    80000208:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000020a:	60e6                	ld	ra,88(sp)
    8000020c:	6446                	ld	s0,80(sp)
    8000020e:	64a6                	ld	s1,72(sp)
    80000210:	6906                	ld	s2,64(sp)
    80000212:	79e2                	ld	s3,56(sp)
    80000214:	7a42                	ld	s4,48(sp)
    80000216:	7aa2                	ld	s5,40(sp)
    80000218:	7b02                	ld	s6,32(sp)
    8000021a:	6125                	addi	sp,sp,96
    8000021c:	8082                	ret
      if(n < target){
    8000021e:	0169fa63          	bgeu	s3,s6,80000232 <consoleread+0xe8>
        cons.r--;
    80000222:	00010717          	auipc	a4,0x10
    80000226:	8ef72323          	sw	a5,-1818(a4) # 8000fb08 <cons+0x98>
    8000022a:	6be2                	ld	s7,24(sp)
    8000022c:	a031                	j	80000238 <consoleread+0xee>
    8000022e:	ec5e                	sd	s7,24(sp)
    80000230:	b749                	j	800001b2 <consoleread+0x68>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	a011                	j	80000238 <consoleread+0xee>
    80000236:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000238:	00010517          	auipc	a0,0x10
    8000023c:	83850513          	addi	a0,a0,-1992 # 8000fa70 <cons>
    80000240:	253000ef          	jal	80000c92 <release>
  return target - n;
    80000244:	413b053b          	subw	a0,s6,s3
    80000248:	b7c9                	j	8000020a <consoleread+0xc0>
    8000024a:	6be2                	ld	s7,24(sp)
    8000024c:	b7f5                	j	80000238 <consoleread+0xee>

000000008000024e <consputc>:
{
    8000024e:	1141                	addi	sp,sp,-16
    80000250:	e406                	sd	ra,8(sp)
    80000252:	e022                	sd	s0,0(sp)
    80000254:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000256:	10000793          	li	a5,256
    8000025a:	00f50863          	beq	a0,a5,8000026a <consputc+0x1c>
    uartputc_sync(c);
    8000025e:	5fe000ef          	jal	8000085c <uartputc_sync>
}
    80000262:	60a2                	ld	ra,8(sp)
    80000264:	6402                	ld	s0,0(sp)
    80000266:	0141                	addi	sp,sp,16
    80000268:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000026a:	4521                	li	a0,8
    8000026c:	5f0000ef          	jal	8000085c <uartputc_sync>
    80000270:	02000513          	li	a0,32
    80000274:	5e8000ef          	jal	8000085c <uartputc_sync>
    80000278:	4521                	li	a0,8
    8000027a:	5e2000ef          	jal	8000085c <uartputc_sync>
    8000027e:	b7d5                	j	80000262 <consputc+0x14>

0000000080000280 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000280:	7179                	addi	sp,sp,-48
    80000282:	f406                	sd	ra,40(sp)
    80000284:	f022                	sd	s0,32(sp)
    80000286:	ec26                	sd	s1,24(sp)
    80000288:	1800                	addi	s0,sp,48
    8000028a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000028c:	0000f517          	auipc	a0,0xf
    80000290:	7e450513          	addi	a0,a0,2020 # 8000fa70 <cons>
    80000294:	16b000ef          	jal	80000bfe <acquire>

  switch(c){
    80000298:	47d5                	li	a5,21
    8000029a:	08f48e63          	beq	s1,a5,80000336 <consoleintr+0xb6>
    8000029e:	0297c563          	blt	a5,s1,800002c8 <consoleintr+0x48>
    800002a2:	47a1                	li	a5,8
    800002a4:	0ef48863          	beq	s1,a5,80000394 <consoleintr+0x114>
    800002a8:	47c1                	li	a5,16
    800002aa:	10f49963          	bne	s1,a5,800003bc <consoleintr+0x13c>
  case C('P'):  // Print process list.
    procdump();
    800002ae:	03a020ef          	jal	800022e8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002b2:	0000f517          	auipc	a0,0xf
    800002b6:	7be50513          	addi	a0,a0,1982 # 8000fa70 <cons>
    800002ba:	1d9000ef          	jal	80000c92 <release>
}
    800002be:	70a2                	ld	ra,40(sp)
    800002c0:	7402                	ld	s0,32(sp)
    800002c2:	64e2                	ld	s1,24(sp)
    800002c4:	6145                	addi	sp,sp,48
    800002c6:	8082                	ret
  switch(c){
    800002c8:	07f00793          	li	a5,127
    800002cc:	0cf48463          	beq	s1,a5,80000394 <consoleintr+0x114>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002d0:	0000f717          	auipc	a4,0xf
    800002d4:	7a070713          	addi	a4,a4,1952 # 8000fa70 <cons>
    800002d8:	0a072783          	lw	a5,160(a4)
    800002dc:	09872703          	lw	a4,152(a4)
    800002e0:	9f99                	subw	a5,a5,a4
    800002e2:	07f00713          	li	a4,127
    800002e6:	fcf766e3          	bltu	a4,a5,800002b2 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002ea:	47b5                	li	a5,13
    800002ec:	0cf48b63          	beq	s1,a5,800003c2 <consoleintr+0x142>
      consputc(c);
    800002f0:	8526                	mv	a0,s1
    800002f2:	f5dff0ef          	jal	8000024e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002f6:	0000f797          	auipc	a5,0xf
    800002fa:	77a78793          	addi	a5,a5,1914 # 8000fa70 <cons>
    800002fe:	0a07a683          	lw	a3,160(a5)
    80000302:	0016871b          	addiw	a4,a3,1
    80000306:	863a                	mv	a2,a4
    80000308:	0ae7a023          	sw	a4,160(a5)
    8000030c:	07f6f693          	andi	a3,a3,127
    80000310:	97b6                	add	a5,a5,a3
    80000312:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000316:	47a9                	li	a5,10
    80000318:	0cf48963          	beq	s1,a5,800003ea <consoleintr+0x16a>
    8000031c:	4791                	li	a5,4
    8000031e:	0cf48663          	beq	s1,a5,800003ea <consoleintr+0x16a>
    80000322:	0000f797          	auipc	a5,0xf
    80000326:	7e67a783          	lw	a5,2022(a5) # 8000fb08 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f8f711e3          	bne	a4,a5,800002b2 <consoleintr+0x32>
    80000334:	a85d                	j	800003ea <consoleintr+0x16a>
    80000336:	e84a                	sd	s2,16(sp)
    80000338:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    8000033a:	0000f717          	auipc	a4,0xf
    8000033e:	73670713          	addi	a4,a4,1846 # 8000fa70 <cons>
    80000342:	0a072783          	lw	a5,160(a4)
    80000346:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	0000f497          	auipc	s1,0xf
    8000034e:	72648493          	addi	s1,s1,1830 # 8000fa70 <cons>
    while(cons.e != cons.w &&
    80000352:	4929                	li	s2,10
      consputc(BACKSPACE);
    80000354:	10000993          	li	s3,256
    while(cons.e != cons.w &&
    80000358:	02f70863          	beq	a4,a5,80000388 <consoleintr+0x108>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000035c:	37fd                	addiw	a5,a5,-1
    8000035e:	07f7f713          	andi	a4,a5,127
    80000362:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000364:	01874703          	lbu	a4,24(a4)
    80000368:	03270363          	beq	a4,s2,8000038e <consoleintr+0x10e>
      cons.e--;
    8000036c:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000370:	854e                	mv	a0,s3
    80000372:	eddff0ef          	jal	8000024e <consputc>
    while(cons.e != cons.w &&
    80000376:	0a04a783          	lw	a5,160(s1)
    8000037a:	09c4a703          	lw	a4,156(s1)
    8000037e:	fcf71fe3          	bne	a4,a5,8000035c <consoleintr+0xdc>
    80000382:	6942                	ld	s2,16(sp)
    80000384:	69a2                	ld	s3,8(sp)
    80000386:	b735                	j	800002b2 <consoleintr+0x32>
    80000388:	6942                	ld	s2,16(sp)
    8000038a:	69a2                	ld	s3,8(sp)
    8000038c:	b71d                	j	800002b2 <consoleintr+0x32>
    8000038e:	6942                	ld	s2,16(sp)
    80000390:	69a2                	ld	s3,8(sp)
    80000392:	b705                	j	800002b2 <consoleintr+0x32>
    if(cons.e != cons.w){
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	6dc70713          	addi	a4,a4,1756 # 8000fa70 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
    800003a4:	f0f707e3          	beq	a4,a5,800002b2 <consoleintr+0x32>
      cons.e--;
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	0000f717          	auipc	a4,0xf
    800003ae:	76f72323          	sw	a5,1894(a4) # 8000fb10 <cons+0xa0>
      consputc(BACKSPACE);
    800003b2:	10000513          	li	a0,256
    800003b6:	e99ff0ef          	jal	8000024e <consputc>
    800003ba:	bde5                	j	800002b2 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003bc:	ee048be3          	beqz	s1,800002b2 <consoleintr+0x32>
    800003c0:	bf01                	j	800002d0 <consoleintr+0x50>
      consputc(c);
    800003c2:	4529                	li	a0,10
    800003c4:	e8bff0ef          	jal	8000024e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003c8:	0000f797          	auipc	a5,0xf
    800003cc:	6a878793          	addi	a5,a5,1704 # 8000fa70 <cons>
    800003d0:	0a07a703          	lw	a4,160(a5)
    800003d4:	0017069b          	addiw	a3,a4,1
    800003d8:	8636                	mv	a2,a3
    800003da:	0ad7a023          	sw	a3,160(a5)
    800003de:	07f77713          	andi	a4,a4,127
    800003e2:	97ba                	add	a5,a5,a4
    800003e4:	4729                	li	a4,10
    800003e6:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003ea:	0000f797          	auipc	a5,0xf
    800003ee:	72c7a123          	sw	a2,1826(a5) # 8000fb0c <cons+0x9c>
        wakeup(&cons.r);
    800003f2:	0000f517          	auipc	a0,0xf
    800003f6:	71650513          	addi	a0,a0,1814 # 8000fb08 <cons+0x98>
    800003fa:	351010ef          	jal	80001f4a <wakeup>
    800003fe:	bd55                	j	800002b2 <consoleintr+0x32>

0000000080000400 <consoleinit>:

void
consoleinit(void)
{
    80000400:	1141                	addi	sp,sp,-16
    80000402:	e406                	sd	ra,8(sp)
    80000404:	e022                	sd	s0,0(sp)
    80000406:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000408:	00007597          	auipc	a1,0x7
    8000040c:	bf858593          	addi	a1,a1,-1032 # 80007000 <etext>
    80000410:	0000f517          	auipc	a0,0xf
    80000414:	66050513          	addi	a0,a0,1632 # 8000fa70 <cons>
    80000418:	762000ef          	jal	80000b7a <initlock>

  uartinit();
    8000041c:	3ea000ef          	jal	80000806 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000420:	00028797          	auipc	a5,0x28
    80000424:	1e878793          	addi	a5,a5,488 # 80028608 <devsw>
    80000428:	00000717          	auipc	a4,0x0
    8000042c:	d2270713          	addi	a4,a4,-734 # 8000014a <consoleread>
    80000430:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000432:	00000717          	auipc	a4,0x0
    80000436:	ca270713          	addi	a4,a4,-862 # 800000d4 <consolewrite>
    8000043a:	ef98                	sd	a4,24(a5)
}
    8000043c:	60a2                	ld	ra,8(sp)
    8000043e:	6402                	ld	s0,0(sp)
    80000440:	0141                	addi	sp,sp,16
    80000442:	8082                	ret

0000000080000444 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000444:	7179                	addi	sp,sp,-48
    80000446:	f406                	sd	ra,40(sp)
    80000448:	f022                	sd	s0,32(sp)
    8000044a:	ec26                	sd	s1,24(sp)
    8000044c:	e84a                	sd	s2,16(sp)
    8000044e:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000450:	c219                	beqz	a2,80000456 <printint+0x12>
    80000452:	06054a63          	bltz	a0,800004c6 <printint+0x82>
    x = -xx;
  else
    x = xx;
    80000456:	4e01                	li	t3,0

  i = 0;
    80000458:	fd040313          	addi	t1,s0,-48
    x = xx;
    8000045c:	869a                	mv	a3,t1
  i = 0;
    8000045e:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000460:	00007817          	auipc	a6,0x7
    80000464:	3b080813          	addi	a6,a6,944 # 80007810 <digits>
    80000468:	88be                	mv	a7,a5
    8000046a:	0017861b          	addiw	a2,a5,1
    8000046e:	87b2                	mv	a5,a2
    80000470:	02b57733          	remu	a4,a0,a1
    80000474:	9742                	add	a4,a4,a6
    80000476:	00074703          	lbu	a4,0(a4)
    8000047a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000047e:	872a                	mv	a4,a0
    80000480:	02b55533          	divu	a0,a0,a1
    80000484:	0685                	addi	a3,a3,1
    80000486:	feb771e3          	bgeu	a4,a1,80000468 <printint+0x24>

  if(sign)
    8000048a:	000e0c63          	beqz	t3,800004a2 <printint+0x5e>
    buf[i++] = '-';
    8000048e:	fe060793          	addi	a5,a2,-32
    80000492:	00878633          	add	a2,a5,s0
    80000496:	02d00793          	li	a5,45
    8000049a:	fef60823          	sb	a5,-16(a2)
    8000049e:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    800004a2:	fff7891b          	addiw	s2,a5,-1
    800004a6:	006784b3          	add	s1,a5,t1
    consputc(buf[i]);
    800004aa:	fff4c503          	lbu	a0,-1(s1)
    800004ae:	da1ff0ef          	jal	8000024e <consputc>
  while(--i >= 0)
    800004b2:	397d                	addiw	s2,s2,-1
    800004b4:	14fd                	addi	s1,s1,-1
    800004b6:	fe095ae3          	bgez	s2,800004aa <printint+0x66>
}
    800004ba:	70a2                	ld	ra,40(sp)
    800004bc:	7402                	ld	s0,32(sp)
    800004be:	64e2                	ld	s1,24(sp)
    800004c0:	6942                	ld	s2,16(sp)
    800004c2:	6145                	addi	sp,sp,48
    800004c4:	8082                	ret
    x = -xx;
    800004c6:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004ca:	4e05                	li	t3,1
    x = -xx;
    800004cc:	b771                	j	80000458 <printint+0x14>

00000000800004ce <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004ce:	7155                	addi	sp,sp,-208
    800004d0:	e506                	sd	ra,136(sp)
    800004d2:	e122                	sd	s0,128(sp)
    800004d4:	f0d2                	sd	s4,96(sp)
    800004d6:	0900                	addi	s0,sp,144
    800004d8:	8a2a                	mv	s4,a0
    800004da:	e40c                	sd	a1,8(s0)
    800004dc:	e810                	sd	a2,16(s0)
    800004de:	ec14                	sd	a3,24(s0)
    800004e0:	f018                	sd	a4,32(s0)
    800004e2:	f41c                	sd	a5,40(s0)
    800004e4:	03043823          	sd	a6,48(s0)
    800004e8:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004ec:	0000f797          	auipc	a5,0xf
    800004f0:	6447a783          	lw	a5,1604(a5) # 8000fb30 <pr+0x18>
    800004f4:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004f8:	e3a1                	bnez	a5,80000538 <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004fa:	00840793          	addi	a5,s0,8
    800004fe:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000502:	00054503          	lbu	a0,0(a0)
    80000506:	26050663          	beqz	a0,80000772 <printf+0x2a4>
    8000050a:	fca6                	sd	s1,120(sp)
    8000050c:	f8ca                	sd	s2,112(sp)
    8000050e:	f4ce                	sd	s3,104(sp)
    80000510:	ecd6                	sd	s5,88(sp)
    80000512:	e8da                	sd	s6,80(sp)
    80000514:	e0e2                	sd	s8,64(sp)
    80000516:	fc66                	sd	s9,56(sp)
    80000518:	f86a                	sd	s10,48(sp)
    8000051a:	f46e                	sd	s11,40(sp)
    8000051c:	4981                	li	s3,0
    if(cx != '%'){
    8000051e:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000522:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000526:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000052a:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000052e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000532:	07000d93          	li	s11,112
    80000536:	a80d                	j	80000568 <printf+0x9a>
    acquire(&pr.lock);
    80000538:	0000f517          	auipc	a0,0xf
    8000053c:	5e050513          	addi	a0,a0,1504 # 8000fb18 <pr>
    80000540:	6be000ef          	jal	80000bfe <acquire>
  va_start(ap, fmt);
    80000544:	00840793          	addi	a5,s0,8
    80000548:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054c:	000a4503          	lbu	a0,0(s4)
    80000550:	fd4d                	bnez	a0,8000050a <printf+0x3c>
    80000552:	ac3d                	j	80000790 <printf+0x2c2>
      consputc(cx);
    80000554:	cfbff0ef          	jal	8000024e <consputc>
      continue;
    80000558:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000055a:	2485                	addiw	s1,s1,1
    8000055c:	89a6                	mv	s3,s1
    8000055e:	94d2                	add	s1,s1,s4
    80000560:	0004c503          	lbu	a0,0(s1)
    80000564:	1e050b63          	beqz	a0,8000075a <printf+0x28c>
    if(cx != '%'){
    80000568:	ff5516e3          	bne	a0,s5,80000554 <printf+0x86>
    i++;
    8000056c:	0019879b          	addiw	a5,s3,1
    80000570:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    80000572:	00fa0733          	add	a4,s4,a5
    80000576:	00074903          	lbu	s2,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000057a:	1e090063          	beqz	s2,8000075a <printf+0x28c>
    8000057e:	00174703          	lbu	a4,1(a4)
    c1 = c2 = 0;
    80000582:	86ba                	mv	a3,a4
    if(c1) c2 = fmt[i+2] & 0xff;
    80000584:	c701                	beqz	a4,8000058c <printf+0xbe>
    80000586:	97d2                	add	a5,a5,s4
    80000588:	0027c683          	lbu	a3,2(a5)
    if(c0 == 'd'){
    8000058c:	03690763          	beq	s2,s6,800005ba <printf+0xec>
    } else if(c0 == 'l' && c1 == 'd'){
    80000590:	05890163          	beq	s2,s8,800005d2 <printf+0x104>
    } else if(c0 == 'u'){
    80000594:	0d990b63          	beq	s2,s9,8000066a <printf+0x19c>
    } else if(c0 == 'x'){
    80000598:	13a90163          	beq	s2,s10,800006ba <printf+0x1ec>
    } else if(c0 == 'p'){
    8000059c:	13b90b63          	beq	s2,s11,800006d2 <printf+0x204>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    800005a0:	07300793          	li	a5,115
    800005a4:	16f90a63          	beq	s2,a5,80000718 <printf+0x24a>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005a8:	1b590463          	beq	s2,s5,80000750 <printf+0x282>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005ac:	8556                	mv	a0,s5
    800005ae:	ca1ff0ef          	jal	8000024e <consputc>
      consputc(c0);
    800005b2:	854a                	mv	a0,s2
    800005b4:	c9bff0ef          	jal	8000024e <consputc>
    800005b8:	b74d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005ba:	f8843783          	ld	a5,-120(s0)
    800005be:	00878713          	addi	a4,a5,8
    800005c2:	f8e43423          	sd	a4,-120(s0)
    800005c6:	4605                	li	a2,1
    800005c8:	45a9                	li	a1,10
    800005ca:	4388                	lw	a0,0(a5)
    800005cc:	e79ff0ef          	jal	80000444 <printint>
    800005d0:	b769                	j	8000055a <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005d2:	03670663          	beq	a4,s6,800005fe <printf+0x130>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005d6:	05870263          	beq	a4,s8,8000061a <printf+0x14c>
    } else if(c0 == 'l' && c1 == 'u'){
    800005da:	0b970463          	beq	a4,s9,80000682 <printf+0x1b4>
    } else if(c0 == 'l' && c1 == 'x'){
    800005de:	fda717e3          	bne	a4,s10,800005ac <printf+0xde>
      printint(va_arg(ap, uint64), 16, 0);
    800005e2:	f8843783          	ld	a5,-120(s0)
    800005e6:	00878713          	addi	a4,a5,8
    800005ea:	f8e43423          	sd	a4,-120(s0)
    800005ee:	4601                	li	a2,0
    800005f0:	45c1                	li	a1,16
    800005f2:	6388                	ld	a0,0(a5)
    800005f4:	e51ff0ef          	jal	80000444 <printint>
      i += 1;
    800005f8:	0029849b          	addiw	s1,s3,2
    800005fc:	bfb9                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005fe:	f8843783          	ld	a5,-120(s0)
    80000602:	00878713          	addi	a4,a5,8
    80000606:	f8e43423          	sd	a4,-120(s0)
    8000060a:	4605                	li	a2,1
    8000060c:	45a9                	li	a1,10
    8000060e:	6388                	ld	a0,0(a5)
    80000610:	e35ff0ef          	jal	80000444 <printint>
      i += 1;
    80000614:	0029849b          	addiw	s1,s3,2
    80000618:	b789                	j	8000055a <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000061a:	06400793          	li	a5,100
    8000061e:	02f68863          	beq	a3,a5,8000064e <printf+0x180>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000622:	07500793          	li	a5,117
    80000626:	06f68c63          	beq	a3,a5,8000069e <printf+0x1d0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000062a:	07800793          	li	a5,120
    8000062e:	f6f69fe3          	bne	a3,a5,800005ac <printf+0xde>
      printint(va_arg(ap, uint64), 16, 0);
    80000632:	f8843783          	ld	a5,-120(s0)
    80000636:	00878713          	addi	a4,a5,8
    8000063a:	f8e43423          	sd	a4,-120(s0)
    8000063e:	4601                	li	a2,0
    80000640:	45c1                	li	a1,16
    80000642:	6388                	ld	a0,0(a5)
    80000644:	e01ff0ef          	jal	80000444 <printint>
      i += 2;
    80000648:	0039849b          	addiw	s1,s3,3
    8000064c:	b739                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    8000064e:	f8843783          	ld	a5,-120(s0)
    80000652:	00878713          	addi	a4,a5,8
    80000656:	f8e43423          	sd	a4,-120(s0)
    8000065a:	4605                	li	a2,1
    8000065c:	45a9                	li	a1,10
    8000065e:	6388                	ld	a0,0(a5)
    80000660:	de5ff0ef          	jal	80000444 <printint>
      i += 2;
    80000664:	0039849b          	addiw	s1,s3,3
    80000668:	bdcd                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000066a:	f8843783          	ld	a5,-120(s0)
    8000066e:	00878713          	addi	a4,a5,8
    80000672:	f8e43423          	sd	a4,-120(s0)
    80000676:	4601                	li	a2,0
    80000678:	45a9                	li	a1,10
    8000067a:	4388                	lw	a0,0(a5)
    8000067c:	dc9ff0ef          	jal	80000444 <printint>
    80000680:	bde9                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4601                	li	a2,0
    80000690:	45a9                	li	a1,10
    80000692:	6388                	ld	a0,0(a5)
    80000694:	db1ff0ef          	jal	80000444 <printint>
      i += 1;
    80000698:	0029849b          	addiw	s1,s3,2
    8000069c:	bd7d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	4601                	li	a2,0
    800006ac:	45a9                	li	a1,10
    800006ae:	6388                	ld	a0,0(a5)
    800006b0:	d95ff0ef          	jal	80000444 <printint>
      i += 2;
    800006b4:	0039849b          	addiw	s1,s3,3
    800006b8:	b54d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006ba:	f8843783          	ld	a5,-120(s0)
    800006be:	00878713          	addi	a4,a5,8
    800006c2:	f8e43423          	sd	a4,-120(s0)
    800006c6:	4601                	li	a2,0
    800006c8:	45c1                	li	a1,16
    800006ca:	4388                	lw	a0,0(a5)
    800006cc:	d79ff0ef          	jal	80000444 <printint>
    800006d0:	b569                	j	8000055a <printf+0x8c>
    800006d2:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006d4:	f8843783          	ld	a5,-120(s0)
    800006d8:	00878713          	addi	a4,a5,8
    800006dc:	f8e43423          	sd	a4,-120(s0)
    800006e0:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006e4:	03000513          	li	a0,48
    800006e8:	b67ff0ef          	jal	8000024e <consputc>
  consputc('x');
    800006ec:	07800513          	li	a0,120
    800006f0:	b5fff0ef          	jal	8000024e <consputc>
    800006f4:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f6:	00007b97          	auipc	s7,0x7
    800006fa:	11ab8b93          	addi	s7,s7,282 # 80007810 <digits>
    800006fe:	03c9d793          	srli	a5,s3,0x3c
    80000702:	97de                	add	a5,a5,s7
    80000704:	0007c503          	lbu	a0,0(a5)
    80000708:	b47ff0ef          	jal	8000024e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070c:	0992                	slli	s3,s3,0x4
    8000070e:	397d                	addiw	s2,s2,-1
    80000710:	fe0917e3          	bnez	s2,800006fe <printf+0x230>
    80000714:	6ba6                	ld	s7,72(sp)
    80000716:	b591                	j	8000055a <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007b903          	ld	s2,0(a5)
    80000728:	00090d63          	beqz	s2,80000742 <printf+0x274>
      for(; *s; s++)
    8000072c:	00094503          	lbu	a0,0(s2)
    80000730:	e20505e3          	beqz	a0,8000055a <printf+0x8c>
        consputc(*s);
    80000734:	b1bff0ef          	jal	8000024e <consputc>
      for(; *s; s++)
    80000738:	0905                	addi	s2,s2,1
    8000073a:	00094503          	lbu	a0,0(s2)
    8000073e:	f97d                	bnez	a0,80000734 <printf+0x266>
    80000740:	bd29                	j	8000055a <printf+0x8c>
        s = "(null)";
    80000742:	00007917          	auipc	s2,0x7
    80000746:	8c690913          	addi	s2,s2,-1850 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printf+0x266>
      consputc('%');
    80000750:	02500513          	li	a0,37
    80000754:	afbff0ef          	jal	8000024e <consputc>
    80000758:	b509                	j	8000055a <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000075a:	f7843783          	ld	a5,-136(s0)
    8000075e:	e385                	bnez	a5,8000077e <printf+0x2b0>
    80000760:	74e6                	ld	s1,120(sp)
    80000762:	7946                	ld	s2,112(sp)
    80000764:	79a6                	ld	s3,104(sp)
    80000766:	6ae6                	ld	s5,88(sp)
    80000768:	6b46                	ld	s6,80(sp)
    8000076a:	6c06                	ld	s8,64(sp)
    8000076c:	7ce2                	ld	s9,56(sp)
    8000076e:	7d42                	ld	s10,48(sp)
    80000770:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000772:	4501                	li	a0,0
    80000774:	60aa                	ld	ra,136(sp)
    80000776:	640a                	ld	s0,128(sp)
    80000778:	7a06                	ld	s4,96(sp)
    8000077a:	6169                	addi	sp,sp,208
    8000077c:	8082                	ret
    8000077e:	74e6                	ld	s1,120(sp)
    80000780:	7946                	ld	s2,112(sp)
    80000782:	79a6                	ld	s3,104(sp)
    80000784:	6ae6                	ld	s5,88(sp)
    80000786:	6b46                	ld	s6,80(sp)
    80000788:	6c06                	ld	s8,64(sp)
    8000078a:	7ce2                	ld	s9,56(sp)
    8000078c:	7d42                	ld	s10,48(sp)
    8000078e:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000790:	0000f517          	auipc	a0,0xf
    80000794:	38850513          	addi	a0,a0,904 # 8000fb18 <pr>
    80000798:	4fa000ef          	jal	80000c92 <release>
    8000079c:	bfd9                	j	80000772 <printf+0x2a4>

000000008000079e <panic>:

void
panic(char *s)
{
    8000079e:	1101                	addi	sp,sp,-32
    800007a0:	ec06                	sd	ra,24(sp)
    800007a2:	e822                	sd	s0,16(sp)
    800007a4:	e426                	sd	s1,8(sp)
    800007a6:	1000                	addi	s0,sp,32
    800007a8:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007aa:	0000f797          	auipc	a5,0xf
    800007ae:	3807a323          	sw	zero,902(a5) # 8000fb30 <pr+0x18>
  printf("panic: ");
    800007b2:	00007517          	auipc	a0,0x7
    800007b6:	86650513          	addi	a0,a0,-1946 # 80007018 <etext+0x18>
    800007ba:	d15ff0ef          	jal	800004ce <printf>
  printf("%s\n", s);
    800007be:	85a6                	mv	a1,s1
    800007c0:	00007517          	auipc	a0,0x7
    800007c4:	86050513          	addi	a0,a0,-1952 # 80007020 <etext+0x20>
    800007c8:	d07ff0ef          	jal	800004ce <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007cc:	4785                	li	a5,1
    800007ce:	00007717          	auipc	a4,0x7
    800007d2:	26f72123          	sw	a5,610(a4) # 80007a30 <panicked>
  for(;;)
    800007d6:	a001                	j	800007d6 <panic+0x38>

00000000800007d8 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007d8:	1101                	addi	sp,sp,-32
    800007da:	ec06                	sd	ra,24(sp)
    800007dc:	e822                	sd	s0,16(sp)
    800007de:	e426                	sd	s1,8(sp)
    800007e0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007e2:	0000f497          	auipc	s1,0xf
    800007e6:	33648493          	addi	s1,s1,822 # 8000fb18 <pr>
    800007ea:	00007597          	auipc	a1,0x7
    800007ee:	83e58593          	addi	a1,a1,-1986 # 80007028 <etext+0x28>
    800007f2:	8526                	mv	a0,s1
    800007f4:	386000ef          	jal	80000b7a <initlock>
  pr.locking = 1;
    800007f8:	4785                	li	a5,1
    800007fa:	cc9c                	sw	a5,24(s1)
}
    800007fc:	60e2                	ld	ra,24(sp)
    800007fe:	6442                	ld	s0,16(sp)
    80000800:	64a2                	ld	s1,8(sp)
    80000802:	6105                	addi	sp,sp,32
    80000804:	8082                	ret

0000000080000806 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000806:	1141                	addi	sp,sp,-16
    80000808:	e406                	sd	ra,8(sp)
    8000080a:	e022                	sd	s0,0(sp)
    8000080c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000080e:	100007b7          	lui	a5,0x10000
    80000812:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000816:	10000737          	lui	a4,0x10000
    8000081a:	f8000693          	li	a3,-128
    8000081e:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000822:	468d                	li	a3,3
    80000824:	10000637          	lui	a2,0x10000
    80000828:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000082c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000830:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000834:	8732                	mv	a4,a2
    80000836:	461d                	li	a2,7
    80000838:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000083c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000840:	00006597          	auipc	a1,0x6
    80000844:	7f058593          	addi	a1,a1,2032 # 80007030 <etext+0x30>
    80000848:	0000f517          	auipc	a0,0xf
    8000084c:	2f050513          	addi	a0,a0,752 # 8000fb38 <uart_tx_lock>
    80000850:	32a000ef          	jal	80000b7a <initlock>
}
    80000854:	60a2                	ld	ra,8(sp)
    80000856:	6402                	ld	s0,0(sp)
    80000858:	0141                	addi	sp,sp,16
    8000085a:	8082                	ret

000000008000085c <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000085c:	1101                	addi	sp,sp,-32
    8000085e:	ec06                	sd	ra,24(sp)
    80000860:	e822                	sd	s0,16(sp)
    80000862:	e426                	sd	s1,8(sp)
    80000864:	1000                	addi	s0,sp,32
    80000866:	84aa                	mv	s1,a0
  push_off();
    80000868:	356000ef          	jal	80000bbe <push_off>

  if(panicked){
    8000086c:	00007797          	auipc	a5,0x7
    80000870:	1c47a783          	lw	a5,452(a5) # 80007a30 <panicked>
    80000874:	e795                	bnez	a5,800008a0 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000876:	10000737          	lui	a4,0x10000
    8000087a:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000087c:	00074783          	lbu	a5,0(a4)
    80000880:	0207f793          	andi	a5,a5,32
    80000884:	dfe5                	beqz	a5,8000087c <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80000886:	0ff4f513          	zext.b	a0,s1
    8000088a:	100007b7          	lui	a5,0x10000
    8000088e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000892:	3b0000ef          	jal	80000c42 <pop_off>
}
    80000896:	60e2                	ld	ra,24(sp)
    80000898:	6442                	ld	s0,16(sp)
    8000089a:	64a2                	ld	s1,8(sp)
    8000089c:	6105                	addi	sp,sp,32
    8000089e:	8082                	ret
    for(;;)
    800008a0:	a001                	j	800008a0 <uartputc_sync+0x44>

00000000800008a2 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008a2:	00007797          	auipc	a5,0x7
    800008a6:	1967b783          	ld	a5,406(a5) # 80007a38 <uart_tx_r>
    800008aa:	00007717          	auipc	a4,0x7
    800008ae:	19673703          	ld	a4,406(a4) # 80007a40 <uart_tx_w>
    800008b2:	08f70163          	beq	a4,a5,80000934 <uartstart+0x92>
{
    800008b6:	7139                	addi	sp,sp,-64
    800008b8:	fc06                	sd	ra,56(sp)
    800008ba:	f822                	sd	s0,48(sp)
    800008bc:	f426                	sd	s1,40(sp)
    800008be:	f04a                	sd	s2,32(sp)
    800008c0:	ec4e                	sd	s3,24(sp)
    800008c2:	e852                	sd	s4,16(sp)
    800008c4:	e456                	sd	s5,8(sp)
    800008c6:	e05a                	sd	s6,0(sp)
    800008c8:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ca:	10000937          	lui	s2,0x10000
    800008ce:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008d0:	0000fa97          	auipc	s5,0xf
    800008d4:	268a8a93          	addi	s5,s5,616 # 8000fb38 <uart_tx_lock>
    uart_tx_r += 1;
    800008d8:	00007497          	auipc	s1,0x7
    800008dc:	16048493          	addi	s1,s1,352 # 80007a38 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008e0:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e4:	00007997          	auipc	s3,0x7
    800008e8:	15c98993          	addi	s3,s3,348 # 80007a40 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ec:	00094703          	lbu	a4,0(s2)
    800008f0:	02077713          	andi	a4,a4,32
    800008f4:	c715                	beqz	a4,80000920 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008f6:	01f7f713          	andi	a4,a5,31
    800008fa:	9756                	add	a4,a4,s5
    800008fc:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    80000900:	0785                	addi	a5,a5,1
    80000902:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    80000904:	8526                	mv	a0,s1
    80000906:	644010ef          	jal	80001f4a <wakeup>
    WriteReg(THR, c);
    8000090a:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    8000090e:	609c                	ld	a5,0(s1)
    80000910:	0009b703          	ld	a4,0(s3)
    80000914:	fcf71ce3          	bne	a4,a5,800008ec <uartstart+0x4a>
      ReadReg(ISR);
    80000918:	100007b7          	lui	a5,0x10000
    8000091c:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80000920:	70e2                	ld	ra,56(sp)
    80000922:	7442                	ld	s0,48(sp)
    80000924:	74a2                	ld	s1,40(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	69e2                	ld	s3,24(sp)
    8000092a:	6a42                	ld	s4,16(sp)
    8000092c:	6aa2                	ld	s5,8(sp)
    8000092e:	6b02                	ld	s6,0(sp)
    80000930:	6121                	addi	sp,sp,64
    80000932:	8082                	ret
      ReadReg(ISR);
    80000934:	100007b7          	lui	a5,0x10000
    80000938:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    8000093c:	8082                	ret

000000008000093e <uartputc>:
{
    8000093e:	7179                	addi	sp,sp,-48
    80000940:	f406                	sd	ra,40(sp)
    80000942:	f022                	sd	s0,32(sp)
    80000944:	ec26                	sd	s1,24(sp)
    80000946:	e84a                	sd	s2,16(sp)
    80000948:	e44e                	sd	s3,8(sp)
    8000094a:	e052                	sd	s4,0(sp)
    8000094c:	1800                	addi	s0,sp,48
    8000094e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000950:	0000f517          	auipc	a0,0xf
    80000954:	1e850513          	addi	a0,a0,488 # 8000fb38 <uart_tx_lock>
    80000958:	2a6000ef          	jal	80000bfe <acquire>
  if(panicked){
    8000095c:	00007797          	auipc	a5,0x7
    80000960:	0d47a783          	lw	a5,212(a5) # 80007a30 <panicked>
    80000964:	efbd                	bnez	a5,800009e2 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000966:	00007717          	auipc	a4,0x7
    8000096a:	0da73703          	ld	a4,218(a4) # 80007a40 <uart_tx_w>
    8000096e:	00007797          	auipc	a5,0x7
    80000972:	0ca7b783          	ld	a5,202(a5) # 80007a38 <uart_tx_r>
    80000976:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	0000f997          	auipc	s3,0xf
    8000097e:	1be98993          	addi	s3,s3,446 # 8000fb38 <uart_tx_lock>
    80000982:	00007497          	auipc	s1,0x7
    80000986:	0b648493          	addi	s1,s1,182 # 80007a38 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000098a:	00007917          	auipc	s2,0x7
    8000098e:	0b690913          	addi	s2,s2,182 # 80007a40 <uart_tx_w>
    80000992:	00e79d63          	bne	a5,a4,800009ac <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000996:	85ce                	mv	a1,s3
    80000998:	8526                	mv	a0,s1
    8000099a:	564010ef          	jal	80001efe <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099e:	00093703          	ld	a4,0(s2)
    800009a2:	609c                	ld	a5,0(s1)
    800009a4:	02078793          	addi	a5,a5,32
    800009a8:	fee787e3          	beq	a5,a4,80000996 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009ac:	0000f497          	auipc	s1,0xf
    800009b0:	18c48493          	addi	s1,s1,396 # 8000fb38 <uart_tx_lock>
    800009b4:	01f77793          	andi	a5,a4,31
    800009b8:	97a6                	add	a5,a5,s1
    800009ba:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009be:	0705                	addi	a4,a4,1
    800009c0:	00007797          	auipc	a5,0x7
    800009c4:	08e7b023          	sd	a4,128(a5) # 80007a40 <uart_tx_w>
  uartstart();
    800009c8:	edbff0ef          	jal	800008a2 <uartstart>
  release(&uart_tx_lock);
    800009cc:	8526                	mv	a0,s1
    800009ce:	2c4000ef          	jal	80000c92 <release>
}
    800009d2:	70a2                	ld	ra,40(sp)
    800009d4:	7402                	ld	s0,32(sp)
    800009d6:	64e2                	ld	s1,24(sp)
    800009d8:	6942                	ld	s2,16(sp)
    800009da:	69a2                	ld	s3,8(sp)
    800009dc:	6a02                	ld	s4,0(sp)
    800009de:	6145                	addi	sp,sp,48
    800009e0:	8082                	ret
    for(;;)
    800009e2:	a001                	j	800009e2 <uartputc+0xa4>

00000000800009e4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e4:	1141                	addi	sp,sp,-16
    800009e6:	e406                	sd	ra,8(sp)
    800009e8:	e022                	sd	s0,0(sp)
    800009ea:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009f4:	8b85                	andi	a5,a5,1
    800009f6:	cb89                	beqz	a5,80000a08 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009f8:	100007b7          	lui	a5,0x10000
    800009fc:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a00:	60a2                	ld	ra,8(sp)
    80000a02:	6402                	ld	s0,0(sp)
    80000a04:	0141                	addi	sp,sp,16
    80000a06:	8082                	ret
    return -1;
    80000a08:	557d                	li	a0,-1
    80000a0a:	bfdd                	j	80000a00 <uartgetc+0x1c>

0000000080000a0c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a0c:	1101                	addi	sp,sp,-32
    80000a0e:	ec06                	sd	ra,24(sp)
    80000a10:	e822                	sd	s0,16(sp)
    80000a12:	e426                	sd	s1,8(sp)
    80000a14:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a16:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a18:	fcdff0ef          	jal	800009e4 <uartgetc>
    if(c == -1)
    80000a1c:	00950563          	beq	a0,s1,80000a26 <uartintr+0x1a>
      break;
    consoleintr(c);
    80000a20:	861ff0ef          	jal	80000280 <consoleintr>
  while(1){
    80000a24:	bfd5                	j	80000a18 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a26:	0000f497          	auipc	s1,0xf
    80000a2a:	11248493          	addi	s1,s1,274 # 8000fb38 <uart_tx_lock>
    80000a2e:	8526                	mv	a0,s1
    80000a30:	1ce000ef          	jal	80000bfe <acquire>
  uartstart();
    80000a34:	e6fff0ef          	jal	800008a2 <uartstart>
  release(&uart_tx_lock);
    80000a38:	8526                	mv	a0,s1
    80000a3a:	258000ef          	jal	80000c92 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6105                	addi	sp,sp,32
    80000a46:	8082                	ret

0000000080000a48 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a48:	1101                	addi	sp,sp,-32
    80000a4a:	ec06                	sd	ra,24(sp)
    80000a4c:	e822                	sd	s0,16(sp)
    80000a4e:	e426                	sd	s1,8(sp)
    80000a50:	e04a                	sd	s2,0(sp)
    80000a52:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a54:	03451793          	slli	a5,a0,0x34
    80000a58:	e7a9                	bnez	a5,80000aa2 <kfree+0x5a>
    80000a5a:	84aa                	mv	s1,a0
    80000a5c:	00029797          	auipc	a5,0x29
    80000a60:	d4478793          	addi	a5,a5,-700 # 800297a0 <end>
    80000a64:	02f56f63          	bltu	a0,a5,80000aa2 <kfree+0x5a>
    80000a68:	47c5                	li	a5,17
    80000a6a:	07ee                	slli	a5,a5,0x1b
    80000a6c:	02f57b63          	bgeu	a0,a5,80000aa2 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a70:	6605                	lui	a2,0x1
    80000a72:	4585                	li	a1,1
    80000a74:	25a000ef          	jal	80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a78:	0000f917          	auipc	s2,0xf
    80000a7c:	0f890913          	addi	s2,s2,248 # 8000fb70 <kmem>
    80000a80:	854a                	mv	a0,s2
    80000a82:	17c000ef          	jal	80000bfe <acquire>
  r->next = kmem.freelist;
    80000a86:	01893783          	ld	a5,24(s2)
    80000a8a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a8c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a90:	854a                	mv	a0,s2
    80000a92:	200000ef          	jal	80000c92 <release>
}
    80000a96:	60e2                	ld	ra,24(sp)
    80000a98:	6442                	ld	s0,16(sp)
    80000a9a:	64a2                	ld	s1,8(sp)
    80000a9c:	6902                	ld	s2,0(sp)
    80000a9e:	6105                	addi	sp,sp,32
    80000aa0:	8082                	ret
    panic("kfree");
    80000aa2:	00006517          	auipc	a0,0x6
    80000aa6:	59650513          	addi	a0,a0,1430 # 80007038 <etext+0x38>
    80000aaa:	cf5ff0ef          	jal	8000079e <panic>

0000000080000aae <freerange>:
{
    80000aae:	7179                	addi	sp,sp,-48
    80000ab0:	f406                	sd	ra,40(sp)
    80000ab2:	f022                	sd	s0,32(sp)
    80000ab4:	ec26                	sd	s1,24(sp)
    80000ab6:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab8:	6785                	lui	a5,0x1
    80000aba:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000abe:	00e504b3          	add	s1,a0,a4
    80000ac2:	777d                	lui	a4,0xfffff
    80000ac4:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac6:	94be                	add	s1,s1,a5
    80000ac8:	0295e263          	bltu	a1,s1,80000aec <freerange+0x3e>
    80000acc:	e84a                	sd	s2,16(sp)
    80000ace:	e44e                	sd	s3,8(sp)
    80000ad0:	e052                	sd	s4,0(sp)
    80000ad2:	892e                	mv	s2,a1
    kfree(p);
    80000ad4:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad6:	89be                	mv	s3,a5
    kfree(p);
    80000ad8:	01448533          	add	a0,s1,s4
    80000adc:	f6dff0ef          	jal	80000a48 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94ce                	add	s1,s1,s3
    80000ae2:	fe997be3          	bgeu	s2,s1,80000ad8 <freerange+0x2a>
    80000ae6:	6942                	ld	s2,16(sp)
    80000ae8:	69a2                	ld	s3,8(sp)
    80000aea:	6a02                	ld	s4,0(sp)
}
    80000aec:	70a2                	ld	ra,40(sp)
    80000aee:	7402                	ld	s0,32(sp)
    80000af0:	64e2                	ld	s1,24(sp)
    80000af2:	6145                	addi	sp,sp,48
    80000af4:	8082                	ret

0000000080000af6 <kinit>:
{
    80000af6:	1141                	addi	sp,sp,-16
    80000af8:	e406                	sd	ra,8(sp)
    80000afa:	e022                	sd	s0,0(sp)
    80000afc:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000afe:	00006597          	auipc	a1,0x6
    80000b02:	54258593          	addi	a1,a1,1346 # 80007040 <etext+0x40>
    80000b06:	0000f517          	auipc	a0,0xf
    80000b0a:	06a50513          	addi	a0,a0,106 # 8000fb70 <kmem>
    80000b0e:	06c000ef          	jal	80000b7a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b12:	45c5                	li	a1,17
    80000b14:	05ee                	slli	a1,a1,0x1b
    80000b16:	00029517          	auipc	a0,0x29
    80000b1a:	c8a50513          	addi	a0,a0,-886 # 800297a0 <end>
    80000b1e:	f91ff0ef          	jal	80000aae <freerange>
}
    80000b22:	60a2                	ld	ra,8(sp)
    80000b24:	6402                	ld	s0,0(sp)
    80000b26:	0141                	addi	sp,sp,16
    80000b28:	8082                	ret

0000000080000b2a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b2a:	1101                	addi	sp,sp,-32
    80000b2c:	ec06                	sd	ra,24(sp)
    80000b2e:	e822                	sd	s0,16(sp)
    80000b30:	e426                	sd	s1,8(sp)
    80000b32:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b34:	0000f497          	auipc	s1,0xf
    80000b38:	03c48493          	addi	s1,s1,60 # 8000fb70 <kmem>
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	0c0000ef          	jal	80000bfe <acquire>
  r = kmem.freelist;
    80000b42:	6c84                	ld	s1,24(s1)
  if(r)
    80000b44:	c485                	beqz	s1,80000b6c <kalloc+0x42>
    kmem.freelist = r->next;
    80000b46:	609c                	ld	a5,0(s1)
    80000b48:	0000f517          	auipc	a0,0xf
    80000b4c:	02850513          	addi	a0,a0,40 # 8000fb70 <kmem>
    80000b50:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b52:	140000ef          	jal	80000c92 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b56:	6605                	lui	a2,0x1
    80000b58:	4595                	li	a1,5
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	172000ef          	jal	80000cce <memset>
  return (void*)r;
}
    80000b60:	8526                	mv	a0,s1
    80000b62:	60e2                	ld	ra,24(sp)
    80000b64:	6442                	ld	s0,16(sp)
    80000b66:	64a2                	ld	s1,8(sp)
    80000b68:	6105                	addi	sp,sp,32
    80000b6a:	8082                	ret
  release(&kmem.lock);
    80000b6c:	0000f517          	auipc	a0,0xf
    80000b70:	00450513          	addi	a0,a0,4 # 8000fb70 <kmem>
    80000b74:	11e000ef          	jal	80000c92 <release>
  if(r)
    80000b78:	b7e5                	j	80000b60 <kalloc+0x36>

0000000080000b7a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b7a:	1141                	addi	sp,sp,-16
    80000b7c:	e406                	sd	ra,8(sp)
    80000b7e:	e022                	sd	s0,0(sp)
    80000b80:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b82:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b84:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b88:	00053823          	sd	zero,16(a0)
}
    80000b8c:	60a2                	ld	ra,8(sp)
    80000b8e:	6402                	ld	s0,0(sp)
    80000b90:	0141                	addi	sp,sp,16
    80000b92:	8082                	ret

0000000080000b94 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b94:	411c                	lw	a5,0(a0)
    80000b96:	e399                	bnez	a5,80000b9c <holding+0x8>
    80000b98:	4501                	li	a0,0
  return r;
}
    80000b9a:	8082                	ret
{
    80000b9c:	1101                	addi	sp,sp,-32
    80000b9e:	ec06                	sd	ra,24(sp)
    80000ba0:	e822                	sd	s0,16(sp)
    80000ba2:	e426                	sd	s1,8(sp)
    80000ba4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba6:	6904                	ld	s1,16(a0)
    80000ba8:	515000ef          	jal	800018bc <mycpu>
    80000bac:	40a48533          	sub	a0,s1,a0
    80000bb0:	00153513          	seqz	a0,a0
}
    80000bb4:	60e2                	ld	ra,24(sp)
    80000bb6:	6442                	ld	s0,16(sp)
    80000bb8:	64a2                	ld	s1,8(sp)
    80000bba:	6105                	addi	sp,sp,32
    80000bbc:	8082                	ret

0000000080000bbe <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bbe:	1101                	addi	sp,sp,-32
    80000bc0:	ec06                	sd	ra,24(sp)
    80000bc2:	e822                	sd	s0,16(sp)
    80000bc4:	e426                	sd	s1,8(sp)
    80000bc6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bc8:	100024f3          	csrr	s1,sstatus
    80000bcc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bd6:	4e7000ef          	jal	800018bc <mycpu>
    80000bda:	5d3c                	lw	a5,120(a0)
    80000bdc:	cb99                	beqz	a5,80000bf2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bde:	4df000ef          	jal	800018bc <mycpu>
    80000be2:	5d3c                	lw	a5,120(a0)
    80000be4:	2785                	addiw	a5,a5,1
    80000be6:	dd3c                	sw	a5,120(a0)
}
    80000be8:	60e2                	ld	ra,24(sp)
    80000bea:	6442                	ld	s0,16(sp)
    80000bec:	64a2                	ld	s1,8(sp)
    80000bee:	6105                	addi	sp,sp,32
    80000bf0:	8082                	ret
    mycpu()->intena = old;
    80000bf2:	4cb000ef          	jal	800018bc <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bf6:	8085                	srli	s1,s1,0x1
    80000bf8:	8885                	andi	s1,s1,1
    80000bfa:	dd64                	sw	s1,124(a0)
    80000bfc:	b7cd                	j	80000bde <push_off+0x20>

0000000080000bfe <acquire>:
{
    80000bfe:	1101                	addi	sp,sp,-32
    80000c00:	ec06                	sd	ra,24(sp)
    80000c02:	e822                	sd	s0,16(sp)
    80000c04:	e426                	sd	s1,8(sp)
    80000c06:	1000                	addi	s0,sp,32
    80000c08:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c0a:	fb5ff0ef          	jal	80000bbe <push_off>
  if(holding(lk))
    80000c0e:	8526                	mv	a0,s1
    80000c10:	f85ff0ef          	jal	80000b94 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c14:	4705                	li	a4,1
  if(holding(lk))
    80000c16:	e105                	bnez	a0,80000c36 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c18:	87ba                	mv	a5,a4
    80000c1a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c1e:	2781                	sext.w	a5,a5
    80000c20:	ffe5                	bnez	a5,80000c18 <acquire+0x1a>
  __sync_synchronize();
    80000c22:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c26:	497000ef          	jal	800018bc <mycpu>
    80000c2a:	e888                	sd	a0,16(s1)
}
    80000c2c:	60e2                	ld	ra,24(sp)
    80000c2e:	6442                	ld	s0,16(sp)
    80000c30:	64a2                	ld	s1,8(sp)
    80000c32:	6105                	addi	sp,sp,32
    80000c34:	8082                	ret
    panic("acquire");
    80000c36:	00006517          	auipc	a0,0x6
    80000c3a:	41250513          	addi	a0,a0,1042 # 80007048 <etext+0x48>
    80000c3e:	b61ff0ef          	jal	8000079e <panic>

0000000080000c42 <pop_off>:

void
pop_off(void)
{
    80000c42:	1141                	addi	sp,sp,-16
    80000c44:	e406                	sd	ra,8(sp)
    80000c46:	e022                	sd	s0,0(sp)
    80000c48:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c4a:	473000ef          	jal	800018bc <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c54:	e39d                	bnez	a5,80000c7a <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c56:	5d3c                	lw	a5,120(a0)
    80000c58:	02f05763          	blez	a5,80000c86 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c5c:	37fd                	addiw	a5,a5,-1
    80000c5e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c60:	eb89                	bnez	a5,80000c72 <pop_off+0x30>
    80000c62:	5d7c                	lw	a5,124(a0)
    80000c64:	c799                	beqz	a5,80000c72 <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c66:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c72:	60a2                	ld	ra,8(sp)
    80000c74:	6402                	ld	s0,0(sp)
    80000c76:	0141                	addi	sp,sp,16
    80000c78:	8082                	ret
    panic("pop_off - interruptible");
    80000c7a:	00006517          	auipc	a0,0x6
    80000c7e:	3d650513          	addi	a0,a0,982 # 80007050 <etext+0x50>
    80000c82:	b1dff0ef          	jal	8000079e <panic>
    panic("pop_off");
    80000c86:	00006517          	auipc	a0,0x6
    80000c8a:	3e250513          	addi	a0,a0,994 # 80007068 <etext+0x68>
    80000c8e:	b11ff0ef          	jal	8000079e <panic>

0000000080000c92 <release>:
{
    80000c92:	1101                	addi	sp,sp,-32
    80000c94:	ec06                	sd	ra,24(sp)
    80000c96:	e822                	sd	s0,16(sp)
    80000c98:	e426                	sd	s1,8(sp)
    80000c9a:	1000                	addi	s0,sp,32
    80000c9c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c9e:	ef7ff0ef          	jal	80000b94 <holding>
    80000ca2:	c105                	beqz	a0,80000cc2 <release+0x30>
  lk->cpu = 0;
    80000ca4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca8:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cac:	0310000f          	fence	rw,w
    80000cb0:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cb4:	f8fff0ef          	jal	80000c42 <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00006517          	auipc	a0,0x6
    80000cc6:	3ae50513          	addi	a0,a0,942 # 80007070 <etext+0x70>
    80000cca:	ad5ff0ef          	jal	8000079e <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e406                	sd	ra,8(sp)
    80000cd2:	e022                	sd	s0,0(sp)
    80000cd4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd6:	ca19                	beqz	a2,80000cec <memset+0x1e>
    80000cd8:	87aa                	mv	a5,a0
    80000cda:	1602                	slli	a2,a2,0x20
    80000cdc:	9201                	srli	a2,a2,0x20
    80000cde:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce6:	0785                	addi	a5,a5,1
    80000ce8:	fee79de3          	bne	a5,a4,80000ce2 <memset+0x14>
  }
  return dst;
}
    80000cec:	60a2                	ld	ra,8(sp)
    80000cee:	6402                	ld	s0,0(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e406                	sd	ra,8(sp)
    80000cf8:	e022                	sd	s0,0(sp)
    80000cfa:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfc:	ca0d                	beqz	a2,80000d2e <memcmp+0x3a>
    80000cfe:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d02:	1682                	slli	a3,a3,0x20
    80000d04:	9281                	srli	a3,a3,0x20
    80000d06:	0685                	addi	a3,a3,1
    80000d08:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d0a:	00054783          	lbu	a5,0(a0)
    80000d0e:	0005c703          	lbu	a4,0(a1)
    80000d12:	00e79863          	bne	a5,a4,80000d22 <memcmp+0x2e>
      return *s1 - *s2;
    s1++, s2++;
    80000d16:	0505                	addi	a0,a0,1
    80000d18:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d1a:	fed518e3          	bne	a0,a3,80000d0a <memcmp+0x16>
  }

  return 0;
    80000d1e:	4501                	li	a0,0
    80000d20:	a019                	j	80000d26 <memcmp+0x32>
      return *s1 - *s2;
    80000d22:	40e7853b          	subw	a0,a5,a4
}
    80000d26:	60a2                	ld	ra,8(sp)
    80000d28:	6402                	ld	s0,0(sp)
    80000d2a:	0141                	addi	sp,sp,16
    80000d2c:	8082                	ret
  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	bfdd                	j	80000d26 <memcmp+0x32>

0000000080000d32 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e406                	sd	ra,8(sp)
    80000d36:	e022                	sd	s0,0(sp)
    80000d38:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d3a:	c205                	beqz	a2,80000d5a <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d3c:	02a5e363          	bltu	a1,a0,80000d62 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d40:	1602                	slli	a2,a2,0x20
    80000d42:	9201                	srli	a2,a2,0x20
    80000d44:	00c587b3          	add	a5,a1,a2
{
    80000d48:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d4a:	0585                	addi	a1,a1,1
    80000d4c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd5861>
    80000d4e:	fff5c683          	lbu	a3,-1(a1)
    80000d52:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d56:	feb79ae3          	bne	a5,a1,80000d4a <memmove+0x18>

  return dst;
}
    80000d5a:	60a2                	ld	ra,8(sp)
    80000d5c:	6402                	ld	s0,0(sp)
    80000d5e:	0141                	addi	sp,sp,16
    80000d60:	8082                	ret
  if(s < d && s + n > d){
    80000d62:	02061693          	slli	a3,a2,0x20
    80000d66:	9281                	srli	a3,a3,0x20
    80000d68:	00d58733          	add	a4,a1,a3
    80000d6c:	fce57ae3          	bgeu	a0,a4,80000d40 <memmove+0xe>
    d += n;
    80000d70:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d72:	fff6079b          	addiw	a5,a2,-1
    80000d76:	1782                	slli	a5,a5,0x20
    80000d78:	9381                	srli	a5,a5,0x20
    80000d7a:	fff7c793          	not	a5,a5
    80000d7e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d80:	177d                	addi	a4,a4,-1
    80000d82:	16fd                	addi	a3,a3,-1
    80000d84:	00074603          	lbu	a2,0(a4)
    80000d88:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d8c:	fee79ae3          	bne	a5,a4,80000d80 <memmove+0x4e>
    80000d90:	b7e9                	j	80000d5a <memmove+0x28>

0000000080000d92 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e406                	sd	ra,8(sp)
    80000d96:	e022                	sd	s0,0(sp)
    80000d98:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d9a:	f99ff0ef          	jal	80000d32 <memmove>
}
    80000d9e:	60a2                	ld	ra,8(sp)
    80000da0:	6402                	ld	s0,0(sp)
    80000da2:	0141                	addi	sp,sp,16
    80000da4:	8082                	ret

0000000080000da6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dae:	ce11                	beqz	a2,80000dca <strncmp+0x24>
    80000db0:	00054783          	lbu	a5,0(a0)
    80000db4:	cf89                	beqz	a5,80000dce <strncmp+0x28>
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	00f71a63          	bne	a4,a5,80000dce <strncmp+0x28>
    n--, p++, q++;
    80000dbe:	367d                	addiw	a2,a2,-1
    80000dc0:	0505                	addi	a0,a0,1
    80000dc2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dc4:	f675                	bnez	a2,80000db0 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dc6:	4501                	li	a0,0
    80000dc8:	a801                	j	80000dd8 <strncmp+0x32>
    80000dca:	4501                	li	a0,0
    80000dcc:	a031                	j	80000dd8 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000dce:	00054503          	lbu	a0,0(a0)
    80000dd2:	0005c783          	lbu	a5,0(a1)
    80000dd6:	9d1d                	subw	a0,a0,a5
}
    80000dd8:	60a2                	ld	ra,8(sp)
    80000dda:	6402                	ld	s0,0(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e406                	sd	ra,8(sp)
    80000de4:	e022                	sd	s0,0(sp)
    80000de6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de8:	87aa                	mv	a5,a0
    80000dea:	86b2                	mv	a3,a2
    80000dec:	367d                	addiw	a2,a2,-1
    80000dee:	02d05563          	blez	a3,80000e18 <strncpy+0x38>
    80000df2:	0785                	addi	a5,a5,1
    80000df4:	0005c703          	lbu	a4,0(a1)
    80000df8:	fee78fa3          	sb	a4,-1(a5)
    80000dfc:	0585                	addi	a1,a1,1
    80000dfe:	f775                	bnez	a4,80000dea <strncpy+0xa>
    ;
  while(n-- > 0)
    80000e00:	873e                	mv	a4,a5
    80000e02:	00c05b63          	blez	a2,80000e18 <strncpy+0x38>
    80000e06:	9fb5                	addw	a5,a5,a3
    80000e08:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e10:	40e786bb          	subw	a3,a5,a4
    80000e14:	fed04be3          	bgtz	a3,80000e0a <strncpy+0x2a>
  return os;
}
    80000e18:	60a2                	ld	ra,8(sp)
    80000e1a:	6402                	ld	s0,0(sp)
    80000e1c:	0141                	addi	sp,sp,16
    80000e1e:	8082                	ret

0000000080000e20 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e20:	1141                	addi	sp,sp,-16
    80000e22:	e406                	sd	ra,8(sp)
    80000e24:	e022                	sd	s0,0(sp)
    80000e26:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e28:	02c05363          	blez	a2,80000e4e <safestrcpy+0x2e>
    80000e2c:	fff6069b          	addiw	a3,a2,-1
    80000e30:	1682                	slli	a3,a3,0x20
    80000e32:	9281                	srli	a3,a3,0x20
    80000e34:	96ae                	add	a3,a3,a1
    80000e36:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e38:	00d58963          	beq	a1,a3,80000e4a <safestrcpy+0x2a>
    80000e3c:	0585                	addi	a1,a1,1
    80000e3e:	0785                	addi	a5,a5,1
    80000e40:	fff5c703          	lbu	a4,-1(a1)
    80000e44:	fee78fa3          	sb	a4,-1(a5)
    80000e48:	fb65                	bnez	a4,80000e38 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e4a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e4e:	60a2                	ld	ra,8(sp)
    80000e50:	6402                	ld	s0,0(sp)
    80000e52:	0141                	addi	sp,sp,16
    80000e54:	8082                	ret

0000000080000e56 <strlen>:

int
strlen(const char *s)
{
    80000e56:	1141                	addi	sp,sp,-16
    80000e58:	e406                	sd	ra,8(sp)
    80000e5a:	e022                	sd	s0,0(sp)
    80000e5c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e5e:	00054783          	lbu	a5,0(a0)
    80000e62:	cf99                	beqz	a5,80000e80 <strlen+0x2a>
    80000e64:	0505                	addi	a0,a0,1
    80000e66:	87aa                	mv	a5,a0
    80000e68:	86be                	mv	a3,a5
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff7c703          	lbu	a4,-1(a5)
    80000e70:	ff65                	bnez	a4,80000e68 <strlen+0x12>
    80000e72:	40a6853b          	subw	a0,a3,a0
    80000e76:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e78:	60a2                	ld	ra,8(sp)
    80000e7a:	6402                	ld	s0,0(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e80:	4501                	li	a0,0
    80000e82:	bfdd                	j	80000e78 <strlen+0x22>

0000000080000e84 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e84:	1141                	addi	sp,sp,-16
    80000e86:	e406                	sd	ra,8(sp)
    80000e88:	e022                	sd	s0,0(sp)
    80000e8a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e8c:	21d000ef          	jal	800018a8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e90:	00007717          	auipc	a4,0x7
    80000e94:	bb870713          	addi	a4,a4,-1096 # 80007a48 <started>
  if(cpuid() == 0){
    80000e98:	c51d                	beqz	a0,80000ec6 <main+0x42>
    while(started == 0)
    80000e9a:	431c                	lw	a5,0(a4)
    80000e9c:	2781                	sext.w	a5,a5
    80000e9e:	dff5                	beqz	a5,80000e9a <main+0x16>
      ;
    __sync_synchronize();
    80000ea0:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ea4:	205000ef          	jal	800018a8 <cpuid>
    80000ea8:	85aa                	mv	a1,a0
    80000eaa:	00006517          	auipc	a0,0x6
    80000eae:	1ee50513          	addi	a0,a0,494 # 80007098 <etext+0x98>
    80000eb2:	e1cff0ef          	jal	800004ce <printf>
    kvminithart();    // turn on paging
    80000eb6:	080000ef          	jal	80000f36 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eba:	560010ef          	jal	8000241a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	50a040ef          	jal	800053c8 <plicinithart>
  }

  scheduler();        
    80000ec2:	6a3000ef          	jal	80001d64 <scheduler>
    consoleinit();
    80000ec6:	d3aff0ef          	jal	80000400 <consoleinit>
    printfinit();
    80000eca:	90fff0ef          	jal	800007d8 <printfinit>
    printf("\n");
    80000ece:	00006517          	auipc	a0,0x6
    80000ed2:	1aa50513          	addi	a0,a0,426 # 80007078 <etext+0x78>
    80000ed6:	df8ff0ef          	jal	800004ce <printf>
    printf("xv6 kernel is booting\n");
    80000eda:	00006517          	auipc	a0,0x6
    80000ede:	1a650513          	addi	a0,a0,422 # 80007080 <etext+0x80>
    80000ee2:	decff0ef          	jal	800004ce <printf>
    printf("\n");
    80000ee6:	00006517          	auipc	a0,0x6
    80000eea:	19250513          	addi	a0,a0,402 # 80007078 <etext+0x78>
    80000eee:	de0ff0ef          	jal	800004ce <printf>
    kinit();         // physical page allocator
    80000ef2:	c05ff0ef          	jal	80000af6 <kinit>
    kvminit();       // create kernel page table
    80000ef6:	2ce000ef          	jal	800011c4 <kvminit>
    kvminithart();   // turn on paging
    80000efa:	03c000ef          	jal	80000f36 <kvminithart>
    procinit();      // process table
    80000efe:	0fb000ef          	jal	800017f8 <procinit>
    trapinit();      // trap vectors
    80000f02:	4f4010ef          	jal	800023f6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f06:	514010ef          	jal	8000241a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f0a:	4a4040ef          	jal	800053ae <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f0e:	4ba040ef          	jal	800053c8 <plicinithart>
    binit();         // buffer cache
    80000f12:	423010ef          	jal	80002b34 <binit>
    iinit();         // inode table
    80000f16:	1ee020ef          	jal	80003104 <iinit>
    fileinit();      // file table
    80000f1a:	7bd020ef          	jal	80003ed6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1e:	59a040ef          	jal	800054b8 <virtio_disk_init>
    userinit();      // first user process
    80000f22:	477000ef          	jal	80001b98 <userinit>
    __sync_synchronize();
    80000f26:	0330000f          	fence	rw,rw
    started = 1;
    80000f2a:	4785                	li	a5,1
    80000f2c:	00007717          	auipc	a4,0x7
    80000f30:	b0f72e23          	sw	a5,-1252(a4) # 80007a48 <started>
    80000f34:	b779                	j	80000ec2 <main+0x3e>

0000000080000f36 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f36:	1141                	addi	sp,sp,-16
    80000f38:	e406                	sd	ra,8(sp)
    80000f3a:	e022                	sd	s0,0(sp)
    80000f3c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f3e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f42:	00007797          	auipc	a5,0x7
    80000f46:	b0e7b783          	ld	a5,-1266(a5) # 80007a50 <kernel_pagetable>
    80000f4a:	83b1                	srli	a5,a5,0xc
    80000f4c:	577d                	li	a4,-1
    80000f4e:	177e                	slli	a4,a4,0x3f
    80000f50:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f52:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f56:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f5a:	60a2                	ld	ra,8(sp)
    80000f5c:	6402                	ld	s0,0(sp)
    80000f5e:	0141                	addi	sp,sp,16
    80000f60:	8082                	ret

0000000080000f62 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f62:	7139                	addi	sp,sp,-64
    80000f64:	fc06                	sd	ra,56(sp)
    80000f66:	f822                	sd	s0,48(sp)
    80000f68:	f426                	sd	s1,40(sp)
    80000f6a:	f04a                	sd	s2,32(sp)
    80000f6c:	ec4e                	sd	s3,24(sp)
    80000f6e:	e852                	sd	s4,16(sp)
    80000f70:	e456                	sd	s5,8(sp)
    80000f72:	e05a                	sd	s6,0(sp)
    80000f74:	0080                	addi	s0,sp,64
    80000f76:	84aa                	mv	s1,a0
    80000f78:	89ae                	mv	s3,a1
    80000f7a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f7c:	57fd                	li	a5,-1
    80000f7e:	83e9                	srli	a5,a5,0x1a
    80000f80:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f82:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f84:	04b7e263          	bltu	a5,a1,80000fc8 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f88:	0149d933          	srl	s2,s3,s4
    80000f8c:	1ff97913          	andi	s2,s2,511
    80000f90:	090e                	slli	s2,s2,0x3
    80000f92:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f94:	00093483          	ld	s1,0(s2)
    80000f98:	0014f793          	andi	a5,s1,1
    80000f9c:	cf85                	beqz	a5,80000fd4 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f9e:	80a9                	srli	s1,s1,0xa
    80000fa0:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fa2:	3a5d                	addiw	s4,s4,-9
    80000fa4:	ff6a12e3          	bne	s4,s6,80000f88 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fa8:	00c9d513          	srli	a0,s3,0xc
    80000fac:	1ff57513          	andi	a0,a0,511
    80000fb0:	050e                	slli	a0,a0,0x3
    80000fb2:	9526                	add	a0,a0,s1
}
    80000fb4:	70e2                	ld	ra,56(sp)
    80000fb6:	7442                	ld	s0,48(sp)
    80000fb8:	74a2                	ld	s1,40(sp)
    80000fba:	7902                	ld	s2,32(sp)
    80000fbc:	69e2                	ld	s3,24(sp)
    80000fbe:	6a42                	ld	s4,16(sp)
    80000fc0:	6aa2                	ld	s5,8(sp)
    80000fc2:	6b02                	ld	s6,0(sp)
    80000fc4:	6121                	addi	sp,sp,64
    80000fc6:	8082                	ret
    panic("walk");
    80000fc8:	00006517          	auipc	a0,0x6
    80000fcc:	0e850513          	addi	a0,a0,232 # 800070b0 <etext+0xb0>
    80000fd0:	fceff0ef          	jal	8000079e <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fd4:	020a8263          	beqz	s5,80000ff8 <walk+0x96>
    80000fd8:	b53ff0ef          	jal	80000b2a <kalloc>
    80000fdc:	84aa                	mv	s1,a0
    80000fde:	d979                	beqz	a0,80000fb4 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80000fe0:	6605                	lui	a2,0x1
    80000fe2:	4581                	li	a1,0
    80000fe4:	cebff0ef          	jal	80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fe8:	00c4d793          	srli	a5,s1,0xc
    80000fec:	07aa                	slli	a5,a5,0xa
    80000fee:	0017e793          	ori	a5,a5,1
    80000ff2:	00f93023          	sd	a5,0(s2)
    80000ff6:	b775                	j	80000fa2 <walk+0x40>
        return 0;
    80000ff8:	4501                	li	a0,0
    80000ffa:	bf6d                	j	80000fb4 <walk+0x52>

0000000080000ffc <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000ffc:	57fd                	li	a5,-1
    80000ffe:	83e9                	srli	a5,a5,0x1a
    80001000:	00b7f463          	bgeu	a5,a1,80001008 <walkaddr+0xc>
    return 0;
    80001004:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001006:	8082                	ret
{
    80001008:	1141                	addi	sp,sp,-16
    8000100a:	e406                	sd	ra,8(sp)
    8000100c:	e022                	sd	s0,0(sp)
    8000100e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001010:	4601                	li	a2,0
    80001012:	f51ff0ef          	jal	80000f62 <walk>
  if(pte == 0)
    80001016:	c105                	beqz	a0,80001036 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80001018:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000101a:	0117f693          	andi	a3,a5,17
    8000101e:	4745                	li	a4,17
    return 0;
    80001020:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001022:	00e68663          	beq	a3,a4,8000102e <walkaddr+0x32>
}
    80001026:	60a2                	ld	ra,8(sp)
    80001028:	6402                	ld	s0,0(sp)
    8000102a:	0141                	addi	sp,sp,16
    8000102c:	8082                	ret
  pa = PTE2PA(*pte);
    8000102e:	83a9                	srli	a5,a5,0xa
    80001030:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001034:	bfcd                	j	80001026 <walkaddr+0x2a>
    return 0;
    80001036:	4501                	li	a0,0
    80001038:	b7fd                	j	80001026 <walkaddr+0x2a>

000000008000103a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000103a:	715d                	addi	sp,sp,-80
    8000103c:	e486                	sd	ra,72(sp)
    8000103e:	e0a2                	sd	s0,64(sp)
    80001040:	fc26                	sd	s1,56(sp)
    80001042:	f84a                	sd	s2,48(sp)
    80001044:	f44e                	sd	s3,40(sp)
    80001046:	f052                	sd	s4,32(sp)
    80001048:	ec56                	sd	s5,24(sp)
    8000104a:	e85a                	sd	s6,16(sp)
    8000104c:	e45e                	sd	s7,8(sp)
    8000104e:	e062                	sd	s8,0(sp)
    80001050:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001052:	03459793          	slli	a5,a1,0x34
    80001056:	e7b1                	bnez	a5,800010a2 <mappages+0x68>
    80001058:	8aaa                	mv	s5,a0
    8000105a:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000105c:	03461793          	slli	a5,a2,0x34
    80001060:	e7b9                	bnez	a5,800010ae <mappages+0x74>
    panic("mappages: size not aligned");

  if(size == 0)
    80001062:	ce21                	beqz	a2,800010ba <mappages+0x80>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001064:	77fd                	lui	a5,0xfffff
    80001066:	963e                	add	a2,a2,a5
    80001068:	00b609b3          	add	s3,a2,a1
  a = va;
    8000106c:	892e                	mv	s2,a1
    8000106e:	40b68a33          	sub	s4,a3,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001072:	4b85                	li	s7,1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001074:	6c05                	lui	s8,0x1
    80001076:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000107a:	865e                	mv	a2,s7
    8000107c:	85ca                	mv	a1,s2
    8000107e:	8556                	mv	a0,s5
    80001080:	ee3ff0ef          	jal	80000f62 <walk>
    80001084:	c539                	beqz	a0,800010d2 <mappages+0x98>
    if(*pte & PTE_V)
    80001086:	611c                	ld	a5,0(a0)
    80001088:	8b85                	andi	a5,a5,1
    8000108a:	ef95                	bnez	a5,800010c6 <mappages+0x8c>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000108c:	80b1                	srli	s1,s1,0xc
    8000108e:	04aa                	slli	s1,s1,0xa
    80001090:	0164e4b3          	or	s1,s1,s6
    80001094:	0014e493          	ori	s1,s1,1
    80001098:	e104                	sd	s1,0(a0)
    if(a == last)
    8000109a:	05390963          	beq	s2,s3,800010ec <mappages+0xb2>
    a += PGSIZE;
    8000109e:	9962                	add	s2,s2,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    800010a0:	bfd9                	j	80001076 <mappages+0x3c>
    panic("mappages: va not aligned");
    800010a2:	00006517          	auipc	a0,0x6
    800010a6:	01650513          	addi	a0,a0,22 # 800070b8 <etext+0xb8>
    800010aa:	ef4ff0ef          	jal	8000079e <panic>
    panic("mappages: size not aligned");
    800010ae:	00006517          	auipc	a0,0x6
    800010b2:	02a50513          	addi	a0,a0,42 # 800070d8 <etext+0xd8>
    800010b6:	ee8ff0ef          	jal	8000079e <panic>
    panic("mappages: size");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	03e50513          	addi	a0,a0,62 # 800070f8 <etext+0xf8>
    800010c2:	edcff0ef          	jal	8000079e <panic>
      panic("mappages: remap");
    800010c6:	00006517          	auipc	a0,0x6
    800010ca:	04250513          	addi	a0,a0,66 # 80007108 <etext+0x108>
    800010ce:	ed0ff0ef          	jal	8000079e <panic>
      return -1;
    800010d2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010d4:	60a6                	ld	ra,72(sp)
    800010d6:	6406                	ld	s0,64(sp)
    800010d8:	74e2                	ld	s1,56(sp)
    800010da:	7942                	ld	s2,48(sp)
    800010dc:	79a2                	ld	s3,40(sp)
    800010de:	7a02                	ld	s4,32(sp)
    800010e0:	6ae2                	ld	s5,24(sp)
    800010e2:	6b42                	ld	s6,16(sp)
    800010e4:	6ba2                	ld	s7,8(sp)
    800010e6:	6c02                	ld	s8,0(sp)
    800010e8:	6161                	addi	sp,sp,80
    800010ea:	8082                	ret
  return 0;
    800010ec:	4501                	li	a0,0
    800010ee:	b7dd                	j	800010d4 <mappages+0x9a>

00000000800010f0 <kvmmap>:
{
    800010f0:	1141                	addi	sp,sp,-16
    800010f2:	e406                	sd	ra,8(sp)
    800010f4:	e022                	sd	s0,0(sp)
    800010f6:	0800                	addi	s0,sp,16
    800010f8:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010fa:	86b2                	mv	a3,a2
    800010fc:	863e                	mv	a2,a5
    800010fe:	f3dff0ef          	jal	8000103a <mappages>
    80001102:	e509                	bnez	a0,8000110c <kvmmap+0x1c>
}
    80001104:	60a2                	ld	ra,8(sp)
    80001106:	6402                	ld	s0,0(sp)
    80001108:	0141                	addi	sp,sp,16
    8000110a:	8082                	ret
    panic("kvmmap");
    8000110c:	00006517          	auipc	a0,0x6
    80001110:	00c50513          	addi	a0,a0,12 # 80007118 <etext+0x118>
    80001114:	e8aff0ef          	jal	8000079e <panic>

0000000080001118 <kvmmake>:
{
    80001118:	1101                	addi	sp,sp,-32
    8000111a:	ec06                	sd	ra,24(sp)
    8000111c:	e822                	sd	s0,16(sp)
    8000111e:	e426                	sd	s1,8(sp)
    80001120:	e04a                	sd	s2,0(sp)
    80001122:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001124:	a07ff0ef          	jal	80000b2a <kalloc>
    80001128:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000112a:	6605                	lui	a2,0x1
    8000112c:	4581                	li	a1,0
    8000112e:	ba1ff0ef          	jal	80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001132:	4719                	li	a4,6
    80001134:	6685                	lui	a3,0x1
    80001136:	10000637          	lui	a2,0x10000
    8000113a:	85b2                	mv	a1,a2
    8000113c:	8526                	mv	a0,s1
    8000113e:	fb3ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001142:	4719                	li	a4,6
    80001144:	6685                	lui	a3,0x1
    80001146:	10001637          	lui	a2,0x10001
    8000114a:	85b2                	mv	a1,a2
    8000114c:	8526                	mv	a0,s1
    8000114e:	fa3ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001152:	4719                	li	a4,6
    80001154:	040006b7          	lui	a3,0x4000
    80001158:	0c000637          	lui	a2,0xc000
    8000115c:	85b2                	mv	a1,a2
    8000115e:	8526                	mv	a0,s1
    80001160:	f91ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001164:	00006917          	auipc	s2,0x6
    80001168:	e9c90913          	addi	s2,s2,-356 # 80007000 <etext>
    8000116c:	4729                	li	a4,10
    8000116e:	80006697          	auipc	a3,0x80006
    80001172:	e9268693          	addi	a3,a3,-366 # 7000 <_entry-0x7fff9000>
    80001176:	4605                	li	a2,1
    80001178:	067e                	slli	a2,a2,0x1f
    8000117a:	85b2                	mv	a1,a2
    8000117c:	8526                	mv	a0,s1
    8000117e:	f73ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001182:	4719                	li	a4,6
    80001184:	46c5                	li	a3,17
    80001186:	06ee                	slli	a3,a3,0x1b
    80001188:	412686b3          	sub	a3,a3,s2
    8000118c:	864a                	mv	a2,s2
    8000118e:	85ca                	mv	a1,s2
    80001190:	8526                	mv	a0,s1
    80001192:	f5fff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001196:	4729                	li	a4,10
    80001198:	6685                	lui	a3,0x1
    8000119a:	00005617          	auipc	a2,0x5
    8000119e:	e6660613          	addi	a2,a2,-410 # 80006000 <_trampoline>
    800011a2:	040005b7          	lui	a1,0x4000
    800011a6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011a8:	05b2                	slli	a1,a1,0xc
    800011aa:	8526                	mv	a0,s1
    800011ac:	f45ff0ef          	jal	800010f0 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011b0:	8526                	mv	a0,s1
    800011b2:	5a8000ef          	jal	8000175a <proc_mapstacks>
}
    800011b6:	8526                	mv	a0,s1
    800011b8:	60e2                	ld	ra,24(sp)
    800011ba:	6442                	ld	s0,16(sp)
    800011bc:	64a2                	ld	s1,8(sp)
    800011be:	6902                	ld	s2,0(sp)
    800011c0:	6105                	addi	sp,sp,32
    800011c2:	8082                	ret

00000000800011c4 <kvminit>:
{
    800011c4:	1141                	addi	sp,sp,-16
    800011c6:	e406                	sd	ra,8(sp)
    800011c8:	e022                	sd	s0,0(sp)
    800011ca:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011cc:	f4dff0ef          	jal	80001118 <kvmmake>
    800011d0:	00007797          	auipc	a5,0x7
    800011d4:	88a7b023          	sd	a0,-1920(a5) # 80007a50 <kernel_pagetable>
}
    800011d8:	60a2                	ld	ra,8(sp)
    800011da:	6402                	ld	s0,0(sp)
    800011dc:	0141                	addi	sp,sp,16
    800011de:	8082                	ret

00000000800011e0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011e0:	715d                	addi	sp,sp,-80
    800011e2:	e486                	sd	ra,72(sp)
    800011e4:	e0a2                	sd	s0,64(sp)
    800011e6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011e8:	03459793          	slli	a5,a1,0x34
    800011ec:	e39d                	bnez	a5,80001212 <uvmunmap+0x32>
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    800011fa:	8a2a                	mv	s4,a0
    800011fc:	892e                	mv	s2,a1
    800011fe:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001200:	0632                	slli	a2,a2,0xc
    80001202:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001206:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001208:	6b05                	lui	s6,0x1
    8000120a:	0735ff63          	bgeu	a1,s3,80001288 <uvmunmap+0xa8>
    8000120e:	fc26                	sd	s1,56(sp)
    80001210:	a0a9                	j	8000125a <uvmunmap+0x7a>
    80001212:	fc26                	sd	s1,56(sp)
    80001214:	f84a                	sd	s2,48(sp)
    80001216:	f44e                	sd	s3,40(sp)
    80001218:	f052                	sd	s4,32(sp)
    8000121a:	ec56                	sd	s5,24(sp)
    8000121c:	e85a                	sd	s6,16(sp)
    8000121e:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001220:	00006517          	auipc	a0,0x6
    80001224:	f0050513          	addi	a0,a0,-256 # 80007120 <etext+0x120>
    80001228:	d76ff0ef          	jal	8000079e <panic>
      panic("uvmunmap: walk");
    8000122c:	00006517          	auipc	a0,0x6
    80001230:	f0c50513          	addi	a0,a0,-244 # 80007138 <etext+0x138>
    80001234:	d6aff0ef          	jal	8000079e <panic>
      panic("uvmunmap: not mapped");
    80001238:	00006517          	auipc	a0,0x6
    8000123c:	f1050513          	addi	a0,a0,-240 # 80007148 <etext+0x148>
    80001240:	d5eff0ef          	jal	8000079e <panic>
      panic("uvmunmap: not a leaf");
    80001244:	00006517          	auipc	a0,0x6
    80001248:	f1c50513          	addi	a0,a0,-228 # 80007160 <etext+0x160>
    8000124c:	d52ff0ef          	jal	8000079e <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001250:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001254:	995a                	add	s2,s2,s6
    80001256:	03397863          	bgeu	s2,s3,80001286 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000125a:	4601                	li	a2,0
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8552                	mv	a0,s4
    80001260:	d03ff0ef          	jal	80000f62 <walk>
    80001264:	84aa                	mv	s1,a0
    80001266:	d179                	beqz	a0,8000122c <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001268:	6108                	ld	a0,0(a0)
    8000126a:	00157793          	andi	a5,a0,1
    8000126e:	d7e9                	beqz	a5,80001238 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001270:	3ff57793          	andi	a5,a0,1023
    80001274:	fd7788e3          	beq	a5,s7,80001244 <uvmunmap+0x64>
    if(do_free){
    80001278:	fc0a8ce3          	beqz	s5,80001250 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    8000127c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000127e:	0532                	slli	a0,a0,0xc
    80001280:	fc8ff0ef          	jal	80000a48 <kfree>
    80001284:	b7f1                	j	80001250 <uvmunmap+0x70>
    80001286:	74e2                	ld	s1,56(sp)
    80001288:	7942                	ld	s2,48(sp)
    8000128a:	79a2                	ld	s3,40(sp)
    8000128c:	7a02                	ld	s4,32(sp)
    8000128e:	6ae2                	ld	s5,24(sp)
    80001290:	6b42                	ld	s6,16(sp)
    80001292:	6ba2                	ld	s7,8(sp)
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	6161                	addi	sp,sp,80
    8000129a:	8082                	ret

000000008000129c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000129c:	1101                	addi	sp,sp,-32
    8000129e:	ec06                	sd	ra,24(sp)
    800012a0:	e822                	sd	s0,16(sp)
    800012a2:	e426                	sd	s1,8(sp)
    800012a4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800012a6:	885ff0ef          	jal	80000b2a <kalloc>
    800012aa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012ac:	c509                	beqz	a0,800012b6 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800012ae:	6605                	lui	a2,0x1
    800012b0:	4581                	li	a1,0
    800012b2:	a1dff0ef          	jal	80000cce <memset>
  return pagetable;
}
    800012b6:	8526                	mv	a0,s1
    800012b8:	60e2                	ld	ra,24(sp)
    800012ba:	6442                	ld	s0,16(sp)
    800012bc:	64a2                	ld	s1,8(sp)
    800012be:	6105                	addi	sp,sp,32
    800012c0:	8082                	ret

00000000800012c2 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800012c2:	7179                	addi	sp,sp,-48
    800012c4:	f406                	sd	ra,40(sp)
    800012c6:	f022                	sd	s0,32(sp)
    800012c8:	ec26                	sd	s1,24(sp)
    800012ca:	e84a                	sd	s2,16(sp)
    800012cc:	e44e                	sd	s3,8(sp)
    800012ce:	e052                	sd	s4,0(sp)
    800012d0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012d2:	6785                	lui	a5,0x1
    800012d4:	04f67063          	bgeu	a2,a5,80001314 <uvmfirst+0x52>
    800012d8:	8a2a                	mv	s4,a0
    800012da:	89ae                	mv	s3,a1
    800012dc:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012de:	84dff0ef          	jal	80000b2a <kalloc>
    800012e2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012e4:	6605                	lui	a2,0x1
    800012e6:	4581                	li	a1,0
    800012e8:	9e7ff0ef          	jal	80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012ec:	4779                	li	a4,30
    800012ee:	86ca                	mv	a3,s2
    800012f0:	6605                	lui	a2,0x1
    800012f2:	4581                	li	a1,0
    800012f4:	8552                	mv	a0,s4
    800012f6:	d45ff0ef          	jal	8000103a <mappages>
  memmove(mem, src, sz);
    800012fa:	8626                	mv	a2,s1
    800012fc:	85ce                	mv	a1,s3
    800012fe:	854a                	mv	a0,s2
    80001300:	a33ff0ef          	jal	80000d32 <memmove>
}
    80001304:	70a2                	ld	ra,40(sp)
    80001306:	7402                	ld	s0,32(sp)
    80001308:	64e2                	ld	s1,24(sp)
    8000130a:	6942                	ld	s2,16(sp)
    8000130c:	69a2                	ld	s3,8(sp)
    8000130e:	6a02                	ld	s4,0(sp)
    80001310:	6145                	addi	sp,sp,48
    80001312:	8082                	ret
    panic("uvmfirst: more than a page");
    80001314:	00006517          	auipc	a0,0x6
    80001318:	e6450513          	addi	a0,a0,-412 # 80007178 <etext+0x178>
    8000131c:	c82ff0ef          	jal	8000079e <panic>

0000000080001320 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001320:	1101                	addi	sp,sp,-32
    80001322:	ec06                	sd	ra,24(sp)
    80001324:	e822                	sd	s0,16(sp)
    80001326:	e426                	sd	s1,8(sp)
    80001328:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000132a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000132c:	00b67d63          	bgeu	a2,a1,80001346 <uvmdealloc+0x26>
    80001330:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001332:	6785                	lui	a5,0x1
    80001334:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001336:	00f60733          	add	a4,a2,a5
    8000133a:	76fd                	lui	a3,0xfffff
    8000133c:	8f75                	and	a4,a4,a3
    8000133e:	97ae                	add	a5,a5,a1
    80001340:	8ff5                	and	a5,a5,a3
    80001342:	00f76863          	bltu	a4,a5,80001352 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001346:	8526                	mv	a0,s1
    80001348:	60e2                	ld	ra,24(sp)
    8000134a:	6442                	ld	s0,16(sp)
    8000134c:	64a2                	ld	s1,8(sp)
    8000134e:	6105                	addi	sp,sp,32
    80001350:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001352:	8f99                	sub	a5,a5,a4
    80001354:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001356:	4685                	li	a3,1
    80001358:	0007861b          	sext.w	a2,a5
    8000135c:	85ba                	mv	a1,a4
    8000135e:	e83ff0ef          	jal	800011e0 <uvmunmap>
    80001362:	b7d5                	j	80001346 <uvmdealloc+0x26>

0000000080001364 <uvmalloc>:
  if(newsz < oldsz)
    80001364:	0ab66363          	bltu	a2,a1,8000140a <uvmalloc+0xa6>
{
    80001368:	715d                	addi	sp,sp,-80
    8000136a:	e486                	sd	ra,72(sp)
    8000136c:	e0a2                	sd	s0,64(sp)
    8000136e:	f052                	sd	s4,32(sp)
    80001370:	ec56                	sd	s5,24(sp)
    80001372:	e85a                	sd	s6,16(sp)
    80001374:	0880                	addi	s0,sp,80
    80001376:	8b2a                	mv	s6,a0
    80001378:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    8000137a:	6785                	lui	a5,0x1
    8000137c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000137e:	95be                	add	a1,a1,a5
    80001380:	77fd                	lui	a5,0xfffff
    80001382:	00f5fa33          	and	s4,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001386:	08ca7463          	bgeu	s4,a2,8000140e <uvmalloc+0xaa>
    8000138a:	fc26                	sd	s1,56(sp)
    8000138c:	f84a                	sd	s2,48(sp)
    8000138e:	f44e                	sd	s3,40(sp)
    80001390:	e45e                	sd	s7,8(sp)
    80001392:	8952                	mv	s2,s4
    memset(mem, 0, PGSIZE);
    80001394:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001396:	0126eb93          	ori	s7,a3,18
    mem = kalloc();
    8000139a:	f90ff0ef          	jal	80000b2a <kalloc>
    8000139e:	84aa                	mv	s1,a0
    if(mem == 0){
    800013a0:	c515                	beqz	a0,800013cc <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    800013a2:	864e                	mv	a2,s3
    800013a4:	4581                	li	a1,0
    800013a6:	929ff0ef          	jal	80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013aa:	875e                	mv	a4,s7
    800013ac:	86a6                	mv	a3,s1
    800013ae:	864e                	mv	a2,s3
    800013b0:	85ca                	mv	a1,s2
    800013b2:	855a                	mv	a0,s6
    800013b4:	c87ff0ef          	jal	8000103a <mappages>
    800013b8:	e91d                	bnez	a0,800013ee <uvmalloc+0x8a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013ba:	994e                	add	s2,s2,s3
    800013bc:	fd596fe3          	bltu	s2,s5,8000139a <uvmalloc+0x36>
  return newsz;
    800013c0:	8556                	mv	a0,s5
    800013c2:	74e2                	ld	s1,56(sp)
    800013c4:	7942                	ld	s2,48(sp)
    800013c6:	79a2                	ld	s3,40(sp)
    800013c8:	6ba2                	ld	s7,8(sp)
    800013ca:	a819                	j	800013e0 <uvmalloc+0x7c>
      uvmdealloc(pagetable, a, oldsz);
    800013cc:	8652                	mv	a2,s4
    800013ce:	85ca                	mv	a1,s2
    800013d0:	855a                	mv	a0,s6
    800013d2:	f4fff0ef          	jal	80001320 <uvmdealloc>
      return 0;
    800013d6:	4501                	li	a0,0
    800013d8:	74e2                	ld	s1,56(sp)
    800013da:	7942                	ld	s2,48(sp)
    800013dc:	79a2                	ld	s3,40(sp)
    800013de:	6ba2                	ld	s7,8(sp)
}
    800013e0:	60a6                	ld	ra,72(sp)
    800013e2:	6406                	ld	s0,64(sp)
    800013e4:	7a02                	ld	s4,32(sp)
    800013e6:	6ae2                	ld	s5,24(sp)
    800013e8:	6b42                	ld	s6,16(sp)
    800013ea:	6161                	addi	sp,sp,80
    800013ec:	8082                	ret
      kfree(mem);
    800013ee:	8526                	mv	a0,s1
    800013f0:	e58ff0ef          	jal	80000a48 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013f4:	8652                	mv	a2,s4
    800013f6:	85ca                	mv	a1,s2
    800013f8:	855a                	mv	a0,s6
    800013fa:	f27ff0ef          	jal	80001320 <uvmdealloc>
      return 0;
    800013fe:	4501                	li	a0,0
    80001400:	74e2                	ld	s1,56(sp)
    80001402:	7942                	ld	s2,48(sp)
    80001404:	79a2                	ld	s3,40(sp)
    80001406:	6ba2                	ld	s7,8(sp)
    80001408:	bfe1                	j	800013e0 <uvmalloc+0x7c>
    return oldsz;
    8000140a:	852e                	mv	a0,a1
}
    8000140c:	8082                	ret
  return newsz;
    8000140e:	8532                	mv	a0,a2
    80001410:	bfc1                	j	800013e0 <uvmalloc+0x7c>

0000000080001412 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001412:	7179                	addi	sp,sp,-48
    80001414:	f406                	sd	ra,40(sp)
    80001416:	f022                	sd	s0,32(sp)
    80001418:	ec26                	sd	s1,24(sp)
    8000141a:	e84a                	sd	s2,16(sp)
    8000141c:	e44e                	sd	s3,8(sp)
    8000141e:	e052                	sd	s4,0(sp)
    80001420:	1800                	addi	s0,sp,48
    80001422:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001424:	84aa                	mv	s1,a0
    80001426:	6905                	lui	s2,0x1
    80001428:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000142a:	4985                	li	s3,1
    8000142c:	a819                	j	80001442 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000142e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001430:	00c79513          	slli	a0,a5,0xc
    80001434:	fdfff0ef          	jal	80001412 <freewalk>
      pagetable[i] = 0;
    80001438:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000143c:	04a1                	addi	s1,s1,8
    8000143e:	01248f63          	beq	s1,s2,8000145c <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001442:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001444:	00f7f713          	andi	a4,a5,15
    80001448:	ff3703e3          	beq	a4,s3,8000142e <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000144c:	8b85                	andi	a5,a5,1
    8000144e:	d7fd                	beqz	a5,8000143c <freewalk+0x2a>
      panic("freewalk: leaf");
    80001450:	00006517          	auipc	a0,0x6
    80001454:	d4850513          	addi	a0,a0,-696 # 80007198 <etext+0x198>
    80001458:	b46ff0ef          	jal	8000079e <panic>
    }
  }
  kfree((void*)pagetable);
    8000145c:	8552                	mv	a0,s4
    8000145e:	deaff0ef          	jal	80000a48 <kfree>
}
    80001462:	70a2                	ld	ra,40(sp)
    80001464:	7402                	ld	s0,32(sp)
    80001466:	64e2                	ld	s1,24(sp)
    80001468:	6942                	ld	s2,16(sp)
    8000146a:	69a2                	ld	s3,8(sp)
    8000146c:	6a02                	ld	s4,0(sp)
    8000146e:	6145                	addi	sp,sp,48
    80001470:	8082                	ret

0000000080001472 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001472:	1101                	addi	sp,sp,-32
    80001474:	ec06                	sd	ra,24(sp)
    80001476:	e822                	sd	s0,16(sp)
    80001478:	e426                	sd	s1,8(sp)
    8000147a:	1000                	addi	s0,sp,32
    8000147c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000147e:	e989                	bnez	a1,80001490 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001480:	8526                	mv	a0,s1
    80001482:	f91ff0ef          	jal	80001412 <freewalk>
}
    80001486:	60e2                	ld	ra,24(sp)
    80001488:	6442                	ld	s0,16(sp)
    8000148a:	64a2                	ld	s1,8(sp)
    8000148c:	6105                	addi	sp,sp,32
    8000148e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	4685                	li	a3,1
    80001498:	00c5d613          	srli	a2,a1,0xc
    8000149c:	4581                	li	a1,0
    8000149e:	d43ff0ef          	jal	800011e0 <uvmunmap>
    800014a2:	bff9                	j	80001480 <uvmfree+0xe>

00000000800014a4 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800014a4:	ca4d                	beqz	a2,80001556 <uvmcopy+0xb2>
{
    800014a6:	715d                	addi	sp,sp,-80
    800014a8:	e486                	sd	ra,72(sp)
    800014aa:	e0a2                	sd	s0,64(sp)
    800014ac:	fc26                	sd	s1,56(sp)
    800014ae:	f84a                	sd	s2,48(sp)
    800014b0:	f44e                	sd	s3,40(sp)
    800014b2:	f052                	sd	s4,32(sp)
    800014b4:	ec56                	sd	s5,24(sp)
    800014b6:	e85a                	sd	s6,16(sp)
    800014b8:	e45e                	sd	s7,8(sp)
    800014ba:	e062                	sd	s8,0(sp)
    800014bc:	0880                	addi	s0,sp,80
    800014be:	8baa                	mv	s7,a0
    800014c0:	8b2e                	mv	s6,a1
    800014c2:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014c4:	4981                	li	s3,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014c6:	6a05                	lui	s4,0x1
    if((pte = walk(old, i, 0)) == 0)
    800014c8:	4601                	li	a2,0
    800014ca:	85ce                	mv	a1,s3
    800014cc:	855e                	mv	a0,s7
    800014ce:	a95ff0ef          	jal	80000f62 <walk>
    800014d2:	cd1d                	beqz	a0,80001510 <uvmcopy+0x6c>
    if((*pte & PTE_V) == 0)
    800014d4:	6118                	ld	a4,0(a0)
    800014d6:	00177793          	andi	a5,a4,1
    800014da:	c3a9                	beqz	a5,8000151c <uvmcopy+0x78>
    pa = PTE2PA(*pte);
    800014dc:	00a75593          	srli	a1,a4,0xa
    800014e0:	00c59c13          	slli	s8,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014e4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014e8:	e42ff0ef          	jal	80000b2a <kalloc>
    800014ec:	892a                	mv	s2,a0
    800014ee:	c121                	beqz	a0,8000152e <uvmcopy+0x8a>
    memmove(mem, (char*)pa, PGSIZE);
    800014f0:	8652                	mv	a2,s4
    800014f2:	85e2                	mv	a1,s8
    800014f4:	83fff0ef          	jal	80000d32 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014f8:	8726                	mv	a4,s1
    800014fa:	86ca                	mv	a3,s2
    800014fc:	8652                	mv	a2,s4
    800014fe:	85ce                	mv	a1,s3
    80001500:	855a                	mv	a0,s6
    80001502:	b39ff0ef          	jal	8000103a <mappages>
    80001506:	e10d                	bnez	a0,80001528 <uvmcopy+0x84>
  for(i = 0; i < sz; i += PGSIZE){
    80001508:	99d2                	add	s3,s3,s4
    8000150a:	fb59efe3          	bltu	s3,s5,800014c8 <uvmcopy+0x24>
    8000150e:	a805                	j	8000153e <uvmcopy+0x9a>
      panic("uvmcopy: pte should exist");
    80001510:	00006517          	auipc	a0,0x6
    80001514:	c9850513          	addi	a0,a0,-872 # 800071a8 <etext+0x1a8>
    80001518:	a86ff0ef          	jal	8000079e <panic>
      panic("uvmcopy: page not present");
    8000151c:	00006517          	auipc	a0,0x6
    80001520:	cac50513          	addi	a0,a0,-852 # 800071c8 <etext+0x1c8>
    80001524:	a7aff0ef          	jal	8000079e <panic>
      kfree(mem);
    80001528:	854a                	mv	a0,s2
    8000152a:	d1eff0ef          	jal	80000a48 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000152e:	4685                	li	a3,1
    80001530:	00c9d613          	srli	a2,s3,0xc
    80001534:	4581                	li	a1,0
    80001536:	855a                	mv	a0,s6
    80001538:	ca9ff0ef          	jal	800011e0 <uvmunmap>
  return -1;
    8000153c:	557d                	li	a0,-1
}
    8000153e:	60a6                	ld	ra,72(sp)
    80001540:	6406                	ld	s0,64(sp)
    80001542:	74e2                	ld	s1,56(sp)
    80001544:	7942                	ld	s2,48(sp)
    80001546:	79a2                	ld	s3,40(sp)
    80001548:	7a02                	ld	s4,32(sp)
    8000154a:	6ae2                	ld	s5,24(sp)
    8000154c:	6b42                	ld	s6,16(sp)
    8000154e:	6ba2                	ld	s7,8(sp)
    80001550:	6c02                	ld	s8,0(sp)
    80001552:	6161                	addi	sp,sp,80
    80001554:	8082                	ret
  return 0;
    80001556:	4501                	li	a0,0
}
    80001558:	8082                	ret

000000008000155a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000155a:	1141                	addi	sp,sp,-16
    8000155c:	e406                	sd	ra,8(sp)
    8000155e:	e022                	sd	s0,0(sp)
    80001560:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001562:	4601                	li	a2,0
    80001564:	9ffff0ef          	jal	80000f62 <walk>
  if(pte == 0)
    80001568:	c901                	beqz	a0,80001578 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000156a:	611c                	ld	a5,0(a0)
    8000156c:	9bbd                	andi	a5,a5,-17
    8000156e:	e11c                	sd	a5,0(a0)
}
    80001570:	60a2                	ld	ra,8(sp)
    80001572:	6402                	ld	s0,0(sp)
    80001574:	0141                	addi	sp,sp,16
    80001576:	8082                	ret
    panic("uvmclear");
    80001578:	00006517          	auipc	a0,0x6
    8000157c:	c7050513          	addi	a0,a0,-912 # 800071e8 <etext+0x1e8>
    80001580:	a1eff0ef          	jal	8000079e <panic>

0000000080001584 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001584:	c2d9                	beqz	a3,8000160a <copyout+0x86>
{
    80001586:	711d                	addi	sp,sp,-96
    80001588:	ec86                	sd	ra,88(sp)
    8000158a:	e8a2                	sd	s0,80(sp)
    8000158c:	e4a6                	sd	s1,72(sp)
    8000158e:	e0ca                	sd	s2,64(sp)
    80001590:	fc4e                	sd	s3,56(sp)
    80001592:	f852                	sd	s4,48(sp)
    80001594:	f456                	sd	s5,40(sp)
    80001596:	f05a                	sd	s6,32(sp)
    80001598:	ec5e                	sd	s7,24(sp)
    8000159a:	e862                	sd	s8,16(sp)
    8000159c:	e466                	sd	s9,8(sp)
    8000159e:	e06a                	sd	s10,0(sp)
    800015a0:	1080                	addi	s0,sp,96
    800015a2:	8c2a                	mv	s8,a0
    800015a4:	892e                	mv	s2,a1
    800015a6:	8ab2                	mv	s5,a2
    800015a8:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015aa:	7cfd                	lui	s9,0xfffff
    if(va0 >= MAXVA)
    800015ac:	5bfd                	li	s7,-1
    800015ae:	01abdb93          	srli	s7,s7,0x1a
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015b2:	4d55                	li	s10,21
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    n = PGSIZE - (dstva - va0);
    800015b4:	6b05                	lui	s6,0x1
    800015b6:	a015                	j	800015da <copyout+0x56>
    pa0 = PTE2PA(*pte);
    800015b8:	83a9                	srli	a5,a5,0xa
    800015ba:	07b2                	slli	a5,a5,0xc
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015bc:	41390533          	sub	a0,s2,s3
    800015c0:	0004861b          	sext.w	a2,s1
    800015c4:	85d6                	mv	a1,s5
    800015c6:	953e                	add	a0,a0,a5
    800015c8:	f6aff0ef          	jal	80000d32 <memmove>

    len -= n;
    800015cc:	409a0a33          	sub	s4,s4,s1
    src += n;
    800015d0:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    800015d2:	01698933          	add	s2,s3,s6
  while(len > 0){
    800015d6:	020a0863          	beqz	s4,80001606 <copyout+0x82>
    va0 = PGROUNDDOWN(dstva);
    800015da:	019979b3          	and	s3,s2,s9
    if(va0 >= MAXVA)
    800015de:	033be863          	bltu	s7,s3,8000160e <copyout+0x8a>
    pte = walk(pagetable, va0, 0);
    800015e2:	4601                	li	a2,0
    800015e4:	85ce                	mv	a1,s3
    800015e6:	8562                	mv	a0,s8
    800015e8:	97bff0ef          	jal	80000f62 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015ec:	c121                	beqz	a0,8000162c <copyout+0xa8>
    800015ee:	611c                	ld	a5,0(a0)
    800015f0:	0157f713          	andi	a4,a5,21
    800015f4:	03a71e63          	bne	a4,s10,80001630 <copyout+0xac>
    n = PGSIZE - (dstva - va0);
    800015f8:	412984b3          	sub	s1,s3,s2
    800015fc:	94da                	add	s1,s1,s6
    if(n > len)
    800015fe:	fa9a7de3          	bgeu	s4,s1,800015b8 <copyout+0x34>
    80001602:	84d2                	mv	s1,s4
    80001604:	bf55                	j	800015b8 <copyout+0x34>
  }
  return 0;
    80001606:	4501                	li	a0,0
    80001608:	a021                	j	80001610 <copyout+0x8c>
    8000160a:	4501                	li	a0,0
}
    8000160c:	8082                	ret
      return -1;
    8000160e:	557d                	li	a0,-1
}
    80001610:	60e6                	ld	ra,88(sp)
    80001612:	6446                	ld	s0,80(sp)
    80001614:	64a6                	ld	s1,72(sp)
    80001616:	6906                	ld	s2,64(sp)
    80001618:	79e2                	ld	s3,56(sp)
    8000161a:	7a42                	ld	s4,48(sp)
    8000161c:	7aa2                	ld	s5,40(sp)
    8000161e:	7b02                	ld	s6,32(sp)
    80001620:	6be2                	ld	s7,24(sp)
    80001622:	6c42                	ld	s8,16(sp)
    80001624:	6ca2                	ld	s9,8(sp)
    80001626:	6d02                	ld	s10,0(sp)
    80001628:	6125                	addi	sp,sp,96
    8000162a:	8082                	ret
      return -1;
    8000162c:	557d                	li	a0,-1
    8000162e:	b7cd                	j	80001610 <copyout+0x8c>
    80001630:	557d                	li	a0,-1
    80001632:	bff9                	j	80001610 <copyout+0x8c>

0000000080001634 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001634:	c6a5                	beqz	a3,8000169c <copyin+0x68>
{
    80001636:	715d                	addi	sp,sp,-80
    80001638:	e486                	sd	ra,72(sp)
    8000163a:	e0a2                	sd	s0,64(sp)
    8000163c:	fc26                	sd	s1,56(sp)
    8000163e:	f84a                	sd	s2,48(sp)
    80001640:	f44e                	sd	s3,40(sp)
    80001642:	f052                	sd	s4,32(sp)
    80001644:	ec56                	sd	s5,24(sp)
    80001646:	e85a                	sd	s6,16(sp)
    80001648:	e45e                	sd	s7,8(sp)
    8000164a:	e062                	sd	s8,0(sp)
    8000164c:	0880                	addi	s0,sp,80
    8000164e:	8b2a                	mv	s6,a0
    80001650:	8a2e                	mv	s4,a1
    80001652:	8c32                	mv	s8,a2
    80001654:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001656:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001658:	6a85                	lui	s5,0x1
    8000165a:	a00d                	j	8000167c <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000165c:	018505b3          	add	a1,a0,s8
    80001660:	0004861b          	sext.w	a2,s1
    80001664:	412585b3          	sub	a1,a1,s2
    80001668:	8552                	mv	a0,s4
    8000166a:	ec8ff0ef          	jal	80000d32 <memmove>

    len -= n;
    8000166e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001672:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001674:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001678:	02098063          	beqz	s3,80001698 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    8000167c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001680:	85ca                	mv	a1,s2
    80001682:	855a                	mv	a0,s6
    80001684:	979ff0ef          	jal	80000ffc <walkaddr>
    if(pa0 == 0)
    80001688:	cd01                	beqz	a0,800016a0 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000168a:	418904b3          	sub	s1,s2,s8
    8000168e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001690:	fc99f6e3          	bgeu	s3,s1,8000165c <copyin+0x28>
    80001694:	84ce                	mv	s1,s3
    80001696:	b7d9                	j	8000165c <copyin+0x28>
  }
  return 0;
    80001698:	4501                	li	a0,0
    8000169a:	a021                	j	800016a2 <copyin+0x6e>
    8000169c:	4501                	li	a0,0
}
    8000169e:	8082                	ret
      return -1;
    800016a0:	557d                	li	a0,-1
}
    800016a2:	60a6                	ld	ra,72(sp)
    800016a4:	6406                	ld	s0,64(sp)
    800016a6:	74e2                	ld	s1,56(sp)
    800016a8:	7942                	ld	s2,48(sp)
    800016aa:	79a2                	ld	s3,40(sp)
    800016ac:	7a02                	ld	s4,32(sp)
    800016ae:	6ae2                	ld	s5,24(sp)
    800016b0:	6b42                	ld	s6,16(sp)
    800016b2:	6ba2                	ld	s7,8(sp)
    800016b4:	6c02                	ld	s8,0(sp)
    800016b6:	6161                	addi	sp,sp,80
    800016b8:	8082                	ret

00000000800016ba <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800016ba:	715d                	addi	sp,sp,-80
    800016bc:	e486                	sd	ra,72(sp)
    800016be:	e0a2                	sd	s0,64(sp)
    800016c0:	fc26                	sd	s1,56(sp)
    800016c2:	f84a                	sd	s2,48(sp)
    800016c4:	f44e                	sd	s3,40(sp)
    800016c6:	f052                	sd	s4,32(sp)
    800016c8:	ec56                	sd	s5,24(sp)
    800016ca:	e85a                	sd	s6,16(sp)
    800016cc:	e45e                	sd	s7,8(sp)
    800016ce:	0880                	addi	s0,sp,80
    800016d0:	8aaa                	mv	s5,a0
    800016d2:	89ae                	mv	s3,a1
    800016d4:	8bb2                	mv	s7,a2
    800016d6:	84b6                	mv	s1,a3
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    800016d8:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016da:	6a05                	lui	s4,0x1
    800016dc:	a02d                	j	80001706 <copyinstr+0x4c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016de:	00078023          	sb	zero,0(a5)
    800016e2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016e4:	0017c793          	xori	a5,a5,1
    800016e8:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016ec:	60a6                	ld	ra,72(sp)
    800016ee:	6406                	ld	s0,64(sp)
    800016f0:	74e2                	ld	s1,56(sp)
    800016f2:	7942                	ld	s2,48(sp)
    800016f4:	79a2                	ld	s3,40(sp)
    800016f6:	7a02                	ld	s4,32(sp)
    800016f8:	6ae2                	ld	s5,24(sp)
    800016fa:	6b42                	ld	s6,16(sp)
    800016fc:	6ba2                	ld	s7,8(sp)
    800016fe:	6161                	addi	sp,sp,80
    80001700:	8082                	ret
    srcva = va0 + PGSIZE;
    80001702:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001706:	c4b1                	beqz	s1,80001752 <copyinstr+0x98>
    va0 = PGROUNDDOWN(srcva);
    80001708:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000170c:	85ca                	mv	a1,s2
    8000170e:	8556                	mv	a0,s5
    80001710:	8edff0ef          	jal	80000ffc <walkaddr>
    if(pa0 == 0)
    80001714:	c129                	beqz	a0,80001756 <copyinstr+0x9c>
    n = PGSIZE - (srcva - va0);
    80001716:	41790633          	sub	a2,s2,s7
    8000171a:	9652                	add	a2,a2,s4
    if(n > max)
    8000171c:	00c4f363          	bgeu	s1,a2,80001722 <copyinstr+0x68>
    80001720:	8626                	mv	a2,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001722:	412b8bb3          	sub	s7,s7,s2
    80001726:	9baa                	add	s7,s7,a0
    while(n > 0){
    80001728:	de69                	beqz	a2,80001702 <copyinstr+0x48>
    8000172a:	87ce                	mv	a5,s3
      if(*p == '\0'){
    8000172c:	413b86b3          	sub	a3,s7,s3
    while(n > 0){
    80001730:	964e                	add	a2,a2,s3
    80001732:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001734:	00f68733          	add	a4,a3,a5
    80001738:	00074703          	lbu	a4,0(a4)
    8000173c:	d34d                	beqz	a4,800016de <copyinstr+0x24>
        *dst = *p;
    8000173e:	00e78023          	sb	a4,0(a5)
      dst++;
    80001742:	0785                	addi	a5,a5,1
    while(n > 0){
    80001744:	fec797e3          	bne	a5,a2,80001732 <copyinstr+0x78>
    80001748:	14fd                	addi	s1,s1,-1
    8000174a:	94ce                	add	s1,s1,s3
      --max;
    8000174c:	8c8d                	sub	s1,s1,a1
    8000174e:	89be                	mv	s3,a5
    80001750:	bf4d                	j	80001702 <copyinstr+0x48>
    80001752:	4781                	li	a5,0
    80001754:	bf41                	j	800016e4 <copyinstr+0x2a>
      return -1;
    80001756:	557d                	li	a0,-1
    80001758:	bf51                	j	800016ec <copyinstr+0x32>

000000008000175a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000175a:	715d                	addi	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	e062                	sd	s8,0(sp)
    80001770:	0880                	addi	s0,sp,80
    80001772:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001774:	0000f497          	auipc	s1,0xf
    80001778:	84c48493          	addi	s1,s1,-1972 # 8000ffc0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000177c:	8c26                	mv	s8,s1
    8000177e:	b823f7b7          	lui	a5,0xb823f
    80001782:	e0978793          	addi	a5,a5,-503 # ffffffffb823ee09 <end+0xffffffff38215669>
    80001786:	823ee937          	lui	s2,0x823ee
    8000178a:	09090913          	addi	s2,s2,144 # ffffffff823ee090 <end+0xffffffff023c48f0>
    8000178e:	1902                	slli	s2,s2,0x20
    80001790:	993e                	add	s2,s2,a5
    80001792:	040009b7          	lui	s3,0x4000
    80001796:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001798:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000179a:	4b99                	li	s7,6
    8000179c:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    8000179e:	0001da97          	auipc	s5,0x1d
    800017a2:	c22a8a93          	addi	s5,s5,-990 # 8001e3c0 <tickslock>
    char *pa = kalloc();
    800017a6:	b84ff0ef          	jal	80000b2a <kalloc>
    800017aa:	862a                	mv	a2,a0
    if(pa == 0)
    800017ac:	c121                	beqz	a0,800017ec <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    800017ae:	418485b3          	sub	a1,s1,s8
    800017b2:	8591                	srai	a1,a1,0x4
    800017b4:	032585b3          	mul	a1,a1,s2
    800017b8:	2585                	addiw	a1,a1,1
    800017ba:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017be:	875e                	mv	a4,s7
    800017c0:	86da                	mv	a3,s6
    800017c2:	40b985b3          	sub	a1,s3,a1
    800017c6:	8552                	mv	a0,s4
    800017c8:	929ff0ef          	jal	800010f0 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017cc:	39048493          	addi	s1,s1,912
    800017d0:	fd549be3          	bne	s1,s5,800017a6 <proc_mapstacks+0x4c>
  }
}
    800017d4:	60a6                	ld	ra,72(sp)
    800017d6:	6406                	ld	s0,64(sp)
    800017d8:	74e2                	ld	s1,56(sp)
    800017da:	7942                	ld	s2,48(sp)
    800017dc:	79a2                	ld	s3,40(sp)
    800017de:	7a02                	ld	s4,32(sp)
    800017e0:	6ae2                	ld	s5,24(sp)
    800017e2:	6b42                	ld	s6,16(sp)
    800017e4:	6ba2                	ld	s7,8(sp)
    800017e6:	6c02                	ld	s8,0(sp)
    800017e8:	6161                	addi	sp,sp,80
    800017ea:	8082                	ret
      panic("kalloc");
    800017ec:	00006517          	auipc	a0,0x6
    800017f0:	a0c50513          	addi	a0,a0,-1524 # 800071f8 <etext+0x1f8>
    800017f4:	fabfe0ef          	jal	8000079e <panic>

00000000800017f8 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017f8:	7139                	addi	sp,sp,-64
    800017fa:	fc06                	sd	ra,56(sp)
    800017fc:	f822                	sd	s0,48(sp)
    800017fe:	f426                	sd	s1,40(sp)
    80001800:	f04a                	sd	s2,32(sp)
    80001802:	ec4e                	sd	s3,24(sp)
    80001804:	e852                	sd	s4,16(sp)
    80001806:	e456                	sd	s5,8(sp)
    80001808:	e05a                	sd	s6,0(sp)
    8000180a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000180c:	00006597          	auipc	a1,0x6
    80001810:	9f458593          	addi	a1,a1,-1548 # 80007200 <etext+0x200>
    80001814:	0000e517          	auipc	a0,0xe
    80001818:	37c50513          	addi	a0,a0,892 # 8000fb90 <pid_lock>
    8000181c:	b5eff0ef          	jal	80000b7a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001820:	00006597          	auipc	a1,0x6
    80001824:	9e858593          	addi	a1,a1,-1560 # 80007208 <etext+0x208>
    80001828:	0000e517          	auipc	a0,0xe
    8000182c:	38050513          	addi	a0,a0,896 # 8000fba8 <wait_lock>
    80001830:	b4aff0ef          	jal	80000b7a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001834:	0000e497          	auipc	s1,0xe
    80001838:	78c48493          	addi	s1,s1,1932 # 8000ffc0 <proc>
      initlock(&p->lock, "proc");
    8000183c:	00006b17          	auipc	s6,0x6
    80001840:	9dcb0b13          	addi	s6,s6,-1572 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001844:	8aa6                	mv	s5,s1
    80001846:	b823f7b7          	lui	a5,0xb823f
    8000184a:	e0978793          	addi	a5,a5,-503 # ffffffffb823ee09 <end+0xffffffff38215669>
    8000184e:	823ee937          	lui	s2,0x823ee
    80001852:	09090913          	addi	s2,s2,144 # ffffffff823ee090 <end+0xffffffff023c48f0>
    80001856:	1902                	slli	s2,s2,0x20
    80001858:	993e                	add	s2,s2,a5
    8000185a:	040009b7          	lui	s3,0x4000
    8000185e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001860:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001862:	0001da17          	auipc	s4,0x1d
    80001866:	b5ea0a13          	addi	s4,s4,-1186 # 8001e3c0 <tickslock>
      initlock(&p->lock, "proc");
    8000186a:	85da                	mv	a1,s6
    8000186c:	8526                	mv	a0,s1
    8000186e:	b0cff0ef          	jal	80000b7a <initlock>
      p->state = UNUSED;
    80001872:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001876:	415487b3          	sub	a5,s1,s5
    8000187a:	8791                	srai	a5,a5,0x4
    8000187c:	032787b3          	mul	a5,a5,s2
    80001880:	2785                	addiw	a5,a5,1
    80001882:	00d7979b          	slliw	a5,a5,0xd
    80001886:	40f987b3          	sub	a5,s3,a5
    8000188a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188c:	39048493          	addi	s1,s1,912
    80001890:	fd449de3          	bne	s1,s4,8000186a <procinit+0x72>
  }
}
    80001894:	70e2                	ld	ra,56(sp)
    80001896:	7442                	ld	s0,48(sp)
    80001898:	74a2                	ld	s1,40(sp)
    8000189a:	7902                	ld	s2,32(sp)
    8000189c:	69e2                	ld	s3,24(sp)
    8000189e:	6a42                	ld	s4,16(sp)
    800018a0:	6aa2                	ld	s5,8(sp)
    800018a2:	6b02                	ld	s6,0(sp)
    800018a4:	6121                	addi	sp,sp,64
    800018a6:	8082                	ret

00000000800018a8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a8:	1141                	addi	sp,sp,-16
    800018aa:	e406                	sd	ra,8(sp)
    800018ac:	e022                	sd	s0,0(sp)
    800018ae:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018b0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018b2:	2501                	sext.w	a0,a0
    800018b4:	60a2                	ld	ra,8(sp)
    800018b6:	6402                	ld	s0,0(sp)
    800018b8:	0141                	addi	sp,sp,16
    800018ba:	8082                	ret

00000000800018bc <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018bc:	1141                	addi	sp,sp,-16
    800018be:	e406                	sd	ra,8(sp)
    800018c0:	e022                	sd	s0,0(sp)
    800018c2:	0800                	addi	s0,sp,16
    800018c4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018c6:	2781                	sext.w	a5,a5
    800018c8:	079e                	slli	a5,a5,0x7
  return c;
}
    800018ca:	0000e517          	auipc	a0,0xe
    800018ce:	2f650513          	addi	a0,a0,758 # 8000fbc0 <cpus>
    800018d2:	953e                	add	a0,a0,a5
    800018d4:	60a2                	ld	ra,8(sp)
    800018d6:	6402                	ld	s0,0(sp)
    800018d8:	0141                	addi	sp,sp,16
    800018da:	8082                	ret

00000000800018dc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018dc:	1101                	addi	sp,sp,-32
    800018de:	ec06                	sd	ra,24(sp)
    800018e0:	e822                	sd	s0,16(sp)
    800018e2:	e426                	sd	s1,8(sp)
    800018e4:	1000                	addi	s0,sp,32
  push_off();
    800018e6:	ad8ff0ef          	jal	80000bbe <push_off>
    800018ea:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018ec:	2781                	sext.w	a5,a5
    800018ee:	079e                	slli	a5,a5,0x7
    800018f0:	0000e717          	auipc	a4,0xe
    800018f4:	2a070713          	addi	a4,a4,672 # 8000fb90 <pid_lock>
    800018f8:	97ba                	add	a5,a5,a4
    800018fa:	7b84                	ld	s1,48(a5)
  pop_off();
    800018fc:	b46ff0ef          	jal	80000c42 <pop_off>
  return p;
}
    80001900:	8526                	mv	a0,s1
    80001902:	60e2                	ld	ra,24(sp)
    80001904:	6442                	ld	s0,16(sp)
    80001906:	64a2                	ld	s1,8(sp)
    80001908:	6105                	addi	sp,sp,32
    8000190a:	8082                	ret

000000008000190c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000190c:	1141                	addi	sp,sp,-16
    8000190e:	e406                	sd	ra,8(sp)
    80001910:	e022                	sd	s0,0(sp)
    80001912:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001914:	fc9ff0ef          	jal	800018dc <myproc>
    80001918:	b7aff0ef          	jal	80000c92 <release>

  if (first) {
    8000191c:	00006797          	auipc	a5,0x6
    80001920:	0c47a783          	lw	a5,196(a5) # 800079e0 <first.1>
    80001924:	e799                	bnez	a5,80001932 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001926:	311000ef          	jal	80002436 <usertrapret>
}
    8000192a:	60a2                	ld	ra,8(sp)
    8000192c:	6402                	ld	s0,0(sp)
    8000192e:	0141                	addi	sp,sp,16
    80001930:	8082                	ret
    fsinit(ROOTDEV);
    80001932:	4505                	li	a0,1
    80001934:	764010ef          	jal	80003098 <fsinit>
    first = 0;
    80001938:	00006797          	auipc	a5,0x6
    8000193c:	0a07a423          	sw	zero,168(a5) # 800079e0 <first.1>
    __sync_synchronize();
    80001940:	0330000f          	fence	rw,rw
    80001944:	b7cd                	j	80001926 <forkret+0x1a>

0000000080001946 <allocpid>:
{
    80001946:	1101                	addi	sp,sp,-32
    80001948:	ec06                	sd	ra,24(sp)
    8000194a:	e822                	sd	s0,16(sp)
    8000194c:	e426                	sd	s1,8(sp)
    8000194e:	e04a                	sd	s2,0(sp)
    80001950:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001952:	0000e917          	auipc	s2,0xe
    80001956:	23e90913          	addi	s2,s2,574 # 8000fb90 <pid_lock>
    8000195a:	854a                	mv	a0,s2
    8000195c:	aa2ff0ef          	jal	80000bfe <acquire>
  pid = nextpid;
    80001960:	00006797          	auipc	a5,0x6
    80001964:	08478793          	addi	a5,a5,132 # 800079e4 <nextpid>
    80001968:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196a:	0014871b          	addiw	a4,s1,1
    8000196e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001970:	854a                	mv	a0,s2
    80001972:	b20ff0ef          	jal	80000c92 <release>
}
    80001976:	8526                	mv	a0,s1
    80001978:	60e2                	ld	ra,24(sp)
    8000197a:	6442                	ld	s0,16(sp)
    8000197c:	64a2                	ld	s1,8(sp)
    8000197e:	6902                	ld	s2,0(sp)
    80001980:	6105                	addi	sp,sp,32
    80001982:	8082                	ret

0000000080001984 <proc_pagetable>:
{
    80001984:	1101                	addi	sp,sp,-32
    80001986:	ec06                	sd	ra,24(sp)
    80001988:	e822                	sd	s0,16(sp)
    8000198a:	e426                	sd	s1,8(sp)
    8000198c:	e04a                	sd	s2,0(sp)
    8000198e:	1000                	addi	s0,sp,32
    80001990:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001992:	90bff0ef          	jal	8000129c <uvmcreate>
    80001996:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001998:	cd05                	beqz	a0,800019d0 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199a:	4729                	li	a4,10
    8000199c:	00004697          	auipc	a3,0x4
    800019a0:	66468693          	addi	a3,a3,1636 # 80006000 <_trampoline>
    800019a4:	6605                	lui	a2,0x1
    800019a6:	040005b7          	lui	a1,0x4000
    800019aa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019ac:	05b2                	slli	a1,a1,0xc
    800019ae:	e8cff0ef          	jal	8000103a <mappages>
    800019b2:	02054663          	bltz	a0,800019de <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019b6:	4719                	li	a4,6
    800019b8:	05893683          	ld	a3,88(s2)
    800019bc:	6605                	lui	a2,0x1
    800019be:	020005b7          	lui	a1,0x2000
    800019c2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c4:	05b6                	slli	a1,a1,0xd
    800019c6:	8526                	mv	a0,s1
    800019c8:	e72ff0ef          	jal	8000103a <mappages>
    800019cc:	00054f63          	bltz	a0,800019ea <proc_pagetable+0x66>
}
    800019d0:	8526                	mv	a0,s1
    800019d2:	60e2                	ld	ra,24(sp)
    800019d4:	6442                	ld	s0,16(sp)
    800019d6:	64a2                	ld	s1,8(sp)
    800019d8:	6902                	ld	s2,0(sp)
    800019da:	6105                	addi	sp,sp,32
    800019dc:	8082                	ret
    uvmfree(pagetable, 0);
    800019de:	4581                	li	a1,0
    800019e0:	8526                	mv	a0,s1
    800019e2:	a91ff0ef          	jal	80001472 <uvmfree>
    return 0;
    800019e6:	4481                	li	s1,0
    800019e8:	b7e5                	j	800019d0 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ea:	4681                	li	a3,0
    800019ec:	4605                	li	a2,1
    800019ee:	040005b7          	lui	a1,0x4000
    800019f2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f4:	05b2                	slli	a1,a1,0xc
    800019f6:	8526                	mv	a0,s1
    800019f8:	fe8ff0ef          	jal	800011e0 <uvmunmap>
    uvmfree(pagetable, 0);
    800019fc:	4581                	li	a1,0
    800019fe:	8526                	mv	a0,s1
    80001a00:	a73ff0ef          	jal	80001472 <uvmfree>
    return 0;
    80001a04:	4481                	li	s1,0
    80001a06:	b7e9                	j	800019d0 <proc_pagetable+0x4c>

0000000080001a08 <proc_freepagetable>:
{
    80001a08:	1101                	addi	sp,sp,-32
    80001a0a:	ec06                	sd	ra,24(sp)
    80001a0c:	e822                	sd	s0,16(sp)
    80001a0e:	e426                	sd	s1,8(sp)
    80001a10:	e04a                	sd	s2,0(sp)
    80001a12:	1000                	addi	s0,sp,32
    80001a14:	84aa                	mv	s1,a0
    80001a16:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a18:	4681                	li	a3,0
    80001a1a:	4605                	li	a2,1
    80001a1c:	040005b7          	lui	a1,0x4000
    80001a20:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a22:	05b2                	slli	a1,a1,0xc
    80001a24:	fbcff0ef          	jal	800011e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a28:	4681                	li	a3,0
    80001a2a:	4605                	li	a2,1
    80001a2c:	020005b7          	lui	a1,0x2000
    80001a30:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a32:	05b6                	slli	a1,a1,0xd
    80001a34:	8526                	mv	a0,s1
    80001a36:	faaff0ef          	jal	800011e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3a:	85ca                	mv	a1,s2
    80001a3c:	8526                	mv	a0,s1
    80001a3e:	a35ff0ef          	jal	80001472 <uvmfree>
}
    80001a42:	60e2                	ld	ra,24(sp)
    80001a44:	6442                	ld	s0,16(sp)
    80001a46:	64a2                	ld	s1,8(sp)
    80001a48:	6902                	ld	s2,0(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret

0000000080001a4e <freeproc>:
{
    80001a4e:	1101                	addi	sp,sp,-32
    80001a50:	ec06                	sd	ra,24(sp)
    80001a52:	e822                	sd	s0,16(sp)
    80001a54:	e426                	sd	s1,8(sp)
    80001a56:	1000                	addi	s0,sp,32
    80001a58:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5a:	6d28                	ld	a0,88(a0)
    80001a5c:	c119                	beqz	a0,80001a62 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a5e:	febfe0ef          	jal	80000a48 <kfree>
  p->trapframe = 0;
    80001a62:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a66:	68a8                	ld	a0,80(s1)
    80001a68:	c501                	beqz	a0,80001a70 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6a:	64ac                	ld	a1,72(s1)
    80001a6c:	f9dff0ef          	jal	80001a08 <proc_freepagetable>
  p->pagetable = 0;
    80001a70:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a74:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a78:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a7c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a80:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a84:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a88:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a8c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a90:	0004ac23          	sw	zero,24(s1)
}
    80001a94:	60e2                	ld	ra,24(sp)
    80001a96:	6442                	ld	s0,16(sp)
    80001a98:	64a2                	ld	s1,8(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret

0000000080001a9e <allocproc>:
{
    80001a9e:	7139                	addi	sp,sp,-64
    80001aa0:	fc06                	sd	ra,56(sp)
    80001aa2:	f822                	sd	s0,48(sp)
    80001aa4:	f426                	sd	s1,40(sp)
    80001aa6:	f04a                	sd	s2,32(sp)
    80001aa8:	0080                	addi	s0,sp,64
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aaa:	0000e497          	auipc	s1,0xe
    80001aae:	51648493          	addi	s1,s1,1302 # 8000ffc0 <proc>
    80001ab2:	0001d917          	auipc	s2,0x1d
    80001ab6:	90e90913          	addi	s2,s2,-1778 # 8001e3c0 <tickslock>
    acquire(&p->lock);
    80001aba:	8526                	mv	a0,s1
    80001abc:	942ff0ef          	jal	80000bfe <acquire>
    if(p->state == UNUSED) {
    80001ac0:	4c9c                	lw	a5,24(s1)
    80001ac2:	cb91                	beqz	a5,80001ad6 <allocproc+0x38>
      release(&p->lock);
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	9ccff0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aca:	39048493          	addi	s1,s1,912
    80001ace:	ff2496e3          	bne	s1,s2,80001aba <allocproc+0x1c>
  return 0;
    80001ad2:	4481                	li	s1,0
    80001ad4:	a069                	j	80001b5e <allocproc+0xc0>
    80001ad6:	ec4e                	sd	s3,24(sp)
    80001ad8:	e852                	sd	s4,16(sp)
    80001ada:	e456                	sd	s5,8(sp)
  p->pid = allocpid();
    80001adc:	e6bff0ef          	jal	80001946 <allocpid>
    80001ae0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae2:	4785                	li	a5,1
    80001ae4:	cc9c                	sw	a5,24(s1)
  for(int i = 1; i <= NSYSCALL; i++) {
    80001ae6:	00006997          	auipc	s3,0x6
    80001aea:	d4a98993          	addi	s3,s3,-694 # 80007830 <syscall_names+0x8>
    80001aee:	18048913          	addi	s2,s1,384
    80001af2:	00006a17          	auipc	s4,0x6
    80001af6:	deea0a13          	addi	s4,s4,-530 # 800078e0 <states.0>
      safestrcpy(p->syscall_stats[i].syscall_name, syscall_names[i], sizeof(p->syscall_stats[i].syscall_name));
    80001afa:	4ac1                	li	s5,16
    80001afc:	a819                	j	80001b12 <allocproc+0x74>
      p->syscall_stats[i].syscall_name[0] = '\0';
    80001afe:	00090023          	sb	zero,0(s2)
    p->syscall_stats[i].count = 0;
    80001b02:	00092823          	sw	zero,16(s2)
    p->syscall_stats[i].accum_time = 0;
    80001b06:	00092a23          	sw	zero,20(s2)
  for(int i = 1; i <= NSYSCALL; i++) {
    80001b0a:	09a1                	addi	s3,s3,8
    80001b0c:	0961                	addi	s2,s2,24
    80001b0e:	01498a63          	beq	s3,s4,80001b22 <allocproc+0x84>
    if(syscall_names[i])
    80001b12:	0009b583          	ld	a1,0(s3)
    80001b16:	d5e5                	beqz	a1,80001afe <allocproc+0x60>
      safestrcpy(p->syscall_stats[i].syscall_name, syscall_names[i], sizeof(p->syscall_stats[i].syscall_name));
    80001b18:	8656                	mv	a2,s5
    80001b1a:	854a                	mv	a0,s2
    80001b1c:	b04ff0ef          	jal	80000e20 <safestrcpy>
    80001b20:	b7cd                	j	80001b02 <allocproc+0x64>
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b22:	808ff0ef          	jal	80000b2a <kalloc>
    80001b26:	892a                	mv	s2,a0
    80001b28:	eca8                	sd	a0,88(s1)
    80001b2a:	c129                	beqz	a0,80001b6c <allocproc+0xce>
  p->pagetable = proc_pagetable(p);
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	e57ff0ef          	jal	80001984 <proc_pagetable>
    80001b32:	892a                	mv	s2,a0
    80001b34:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b36:	c531                	beqz	a0,80001b82 <allocproc+0xe4>
  memset(&p->context, 0, sizeof(p->context));
    80001b38:	07000613          	li	a2,112
    80001b3c:	4581                	li	a1,0
    80001b3e:	06048513          	addi	a0,s1,96
    80001b42:	98cff0ef          	jal	80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001b46:	00000797          	auipc	a5,0x0
    80001b4a:	dc678793          	addi	a5,a5,-570 # 8000190c <forkret>
    80001b4e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b50:	60bc                	ld	a5,64(s1)
    80001b52:	6705                	lui	a4,0x1
    80001b54:	97ba                	add	a5,a5,a4
    80001b56:	f4bc                	sd	a5,104(s1)
    80001b58:	69e2                	ld	s3,24(sp)
    80001b5a:	6a42                	ld	s4,16(sp)
    80001b5c:	6aa2                	ld	s5,8(sp)
}
    80001b5e:	8526                	mv	a0,s1
    80001b60:	70e2                	ld	ra,56(sp)
    80001b62:	7442                	ld	s0,48(sp)
    80001b64:	74a2                	ld	s1,40(sp)
    80001b66:	7902                	ld	s2,32(sp)
    80001b68:	6121                	addi	sp,sp,64
    80001b6a:	8082                	ret
    freeproc(p);
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	ee1ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b72:	8526                	mv	a0,s1
    80001b74:	91eff0ef          	jal	80000c92 <release>
    return 0;
    80001b78:	84ca                	mv	s1,s2
    80001b7a:	69e2                	ld	s3,24(sp)
    80001b7c:	6a42                	ld	s4,16(sp)
    80001b7e:	6aa2                	ld	s5,8(sp)
    80001b80:	bff9                	j	80001b5e <allocproc+0xc0>
    freeproc(p);
    80001b82:	8526                	mv	a0,s1
    80001b84:	ecbff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b88:	8526                	mv	a0,s1
    80001b8a:	908ff0ef          	jal	80000c92 <release>
    return 0;
    80001b8e:	84ca                	mv	s1,s2
    80001b90:	69e2                	ld	s3,24(sp)
    80001b92:	6a42                	ld	s4,16(sp)
    80001b94:	6aa2                	ld	s5,8(sp)
    80001b96:	b7e1                	j	80001b5e <allocproc+0xc0>

0000000080001b98 <userinit>:
{
    80001b98:	1101                	addi	sp,sp,-32
    80001b9a:	ec06                	sd	ra,24(sp)
    80001b9c:	e822                	sd	s0,16(sp)
    80001b9e:	e426                	sd	s1,8(sp)
    80001ba0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ba2:	efdff0ef          	jal	80001a9e <allocproc>
    80001ba6:	84aa                	mv	s1,a0
  initproc = p;
    80001ba8:	00006797          	auipc	a5,0x6
    80001bac:	eaa7b823          	sd	a0,-336(a5) # 80007a58 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001bb0:	03400613          	li	a2,52
    80001bb4:	00006597          	auipc	a1,0x6
    80001bb8:	e3c58593          	addi	a1,a1,-452 # 800079f0 <initcode>
    80001bbc:	6928                	ld	a0,80(a0)
    80001bbe:	f04ff0ef          	jal	800012c2 <uvmfirst>
  p->sz = PGSIZE;
    80001bc2:	6785                	lui	a5,0x1
    80001bc4:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001bc6:	6cb8                	ld	a4,88(s1)
    80001bc8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001bcc:	6cb8                	ld	a4,88(s1)
    80001bce:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001bd0:	4641                	li	a2,16
    80001bd2:	00005597          	auipc	a1,0x5
    80001bd6:	64e58593          	addi	a1,a1,1614 # 80007220 <etext+0x220>
    80001bda:	15848513          	addi	a0,s1,344
    80001bde:	a42ff0ef          	jal	80000e20 <safestrcpy>
  p->cwd = namei("/");
    80001be2:	00005517          	auipc	a0,0x5
    80001be6:	64e50513          	addi	a0,a0,1614 # 80007230 <etext+0x230>
    80001bea:	5d3010ef          	jal	800039bc <namei>
    80001bee:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bf2:	478d                	li	a5,3
    80001bf4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bf6:	8526                	mv	a0,s1
    80001bf8:	89aff0ef          	jal	80000c92 <release>
}
    80001bfc:	60e2                	ld	ra,24(sp)
    80001bfe:	6442                	ld	s0,16(sp)
    80001c00:	64a2                	ld	s1,8(sp)
    80001c02:	6105                	addi	sp,sp,32
    80001c04:	8082                	ret

0000000080001c06 <growproc>:
{
    80001c06:	1101                	addi	sp,sp,-32
    80001c08:	ec06                	sd	ra,24(sp)
    80001c0a:	e822                	sd	s0,16(sp)
    80001c0c:	e426                	sd	s1,8(sp)
    80001c0e:	e04a                	sd	s2,0(sp)
    80001c10:	1000                	addi	s0,sp,32
    80001c12:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001c14:	cc9ff0ef          	jal	800018dc <myproc>
    80001c18:	84aa                	mv	s1,a0
  sz = p->sz;
    80001c1a:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c1c:	01204c63          	bgtz	s2,80001c34 <growproc+0x2e>
  } else if(n < 0){
    80001c20:	02094463          	bltz	s2,80001c48 <growproc+0x42>
  p->sz = sz;
    80001c24:	e4ac                	sd	a1,72(s1)
  return 0;
    80001c26:	4501                	li	a0,0
}
    80001c28:	60e2                	ld	ra,24(sp)
    80001c2a:	6442                	ld	s0,16(sp)
    80001c2c:	64a2                	ld	s1,8(sp)
    80001c2e:	6902                	ld	s2,0(sp)
    80001c30:	6105                	addi	sp,sp,32
    80001c32:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c34:	4691                	li	a3,4
    80001c36:	00b90633          	add	a2,s2,a1
    80001c3a:	6928                	ld	a0,80(a0)
    80001c3c:	f28ff0ef          	jal	80001364 <uvmalloc>
    80001c40:	85aa                	mv	a1,a0
    80001c42:	f16d                	bnez	a0,80001c24 <growproc+0x1e>
      return -1;
    80001c44:	557d                	li	a0,-1
    80001c46:	b7cd                	j	80001c28 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c48:	00b90633          	add	a2,s2,a1
    80001c4c:	6928                	ld	a0,80(a0)
    80001c4e:	ed2ff0ef          	jal	80001320 <uvmdealloc>
    80001c52:	85aa                	mv	a1,a0
    80001c54:	bfc1                	j	80001c24 <growproc+0x1e>

0000000080001c56 <fork>:
{
    80001c56:	7139                	addi	sp,sp,-64
    80001c58:	fc06                	sd	ra,56(sp)
    80001c5a:	f822                	sd	s0,48(sp)
    80001c5c:	f04a                	sd	s2,32(sp)
    80001c5e:	e456                	sd	s5,8(sp)
    80001c60:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c62:	c7bff0ef          	jal	800018dc <myproc>
    80001c66:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c68:	e37ff0ef          	jal	80001a9e <allocproc>
    80001c6c:	0e050a63          	beqz	a0,80001d60 <fork+0x10a>
    80001c70:	e852                	sd	s4,16(sp)
    80001c72:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c74:	048ab603          	ld	a2,72(s5)
    80001c78:	692c                	ld	a1,80(a0)
    80001c7a:	050ab503          	ld	a0,80(s5)
    80001c7e:	827ff0ef          	jal	800014a4 <uvmcopy>
    80001c82:	04054a63          	bltz	a0,80001cd6 <fork+0x80>
    80001c86:	f426                	sd	s1,40(sp)
    80001c88:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c8a:	048ab783          	ld	a5,72(s5)
    80001c8e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c92:	058ab683          	ld	a3,88(s5)
    80001c96:	87b6                	mv	a5,a3
    80001c98:	058a3703          	ld	a4,88(s4)
    80001c9c:	12068693          	addi	a3,a3,288
    80001ca0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ca4:	6788                	ld	a0,8(a5)
    80001ca6:	6b8c                	ld	a1,16(a5)
    80001ca8:	6f90                	ld	a2,24(a5)
    80001caa:	01073023          	sd	a6,0(a4)
    80001cae:	e708                	sd	a0,8(a4)
    80001cb0:	eb0c                	sd	a1,16(a4)
    80001cb2:	ef10                	sd	a2,24(a4)
    80001cb4:	02078793          	addi	a5,a5,32
    80001cb8:	02070713          	addi	a4,a4,32
    80001cbc:	fed792e3          	bne	a5,a3,80001ca0 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001cc0:	058a3783          	ld	a5,88(s4)
    80001cc4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001cc8:	0d0a8493          	addi	s1,s5,208
    80001ccc:	0d0a0913          	addi	s2,s4,208
    80001cd0:	150a8993          	addi	s3,s5,336
    80001cd4:	a831                	j	80001cf0 <fork+0x9a>
    freeproc(np);
    80001cd6:	8552                	mv	a0,s4
    80001cd8:	d77ff0ef          	jal	80001a4e <freeproc>
    release(&np->lock);
    80001cdc:	8552                	mv	a0,s4
    80001cde:	fb5fe0ef          	jal	80000c92 <release>
    return -1;
    80001ce2:	597d                	li	s2,-1
    80001ce4:	6a42                	ld	s4,16(sp)
    80001ce6:	a0b5                	j	80001d52 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001ce8:	04a1                	addi	s1,s1,8
    80001cea:	0921                	addi	s2,s2,8
    80001cec:	01348963          	beq	s1,s3,80001cfe <fork+0xa8>
    if(p->ofile[i])
    80001cf0:	6088                	ld	a0,0(s1)
    80001cf2:	d97d                	beqz	a0,80001ce8 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cf4:	264020ef          	jal	80003f58 <filedup>
    80001cf8:	00a93023          	sd	a0,0(s2)
    80001cfc:	b7f5                	j	80001ce8 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cfe:	150ab503          	ld	a0,336(s5)
    80001d02:	594010ef          	jal	80003296 <idup>
    80001d06:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d0a:	4641                	li	a2,16
    80001d0c:	158a8593          	addi	a1,s5,344
    80001d10:	158a0513          	addi	a0,s4,344
    80001d14:	90cff0ef          	jal	80000e20 <safestrcpy>
  pid = np->pid;
    80001d18:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d1c:	8552                	mv	a0,s4
    80001d1e:	f75fe0ef          	jal	80000c92 <release>
  acquire(&wait_lock);
    80001d22:	0000e497          	auipc	s1,0xe
    80001d26:	e8648493          	addi	s1,s1,-378 # 8000fba8 <wait_lock>
    80001d2a:	8526                	mv	a0,s1
    80001d2c:	ed3fe0ef          	jal	80000bfe <acquire>
  np->parent = p;
    80001d30:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d34:	8526                	mv	a0,s1
    80001d36:	f5dfe0ef          	jal	80000c92 <release>
  acquire(&np->lock);
    80001d3a:	8552                	mv	a0,s4
    80001d3c:	ec3fe0ef          	jal	80000bfe <acquire>
  np->state = RUNNABLE;
    80001d40:	478d                	li	a5,3
    80001d42:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d46:	8552                	mv	a0,s4
    80001d48:	f4bfe0ef          	jal	80000c92 <release>
  return pid;
    80001d4c:	74a2                	ld	s1,40(sp)
    80001d4e:	69e2                	ld	s3,24(sp)
    80001d50:	6a42                	ld	s4,16(sp)
}
    80001d52:	854a                	mv	a0,s2
    80001d54:	70e2                	ld	ra,56(sp)
    80001d56:	7442                	ld	s0,48(sp)
    80001d58:	7902                	ld	s2,32(sp)
    80001d5a:	6aa2                	ld	s5,8(sp)
    80001d5c:	6121                	addi	sp,sp,64
    80001d5e:	8082                	ret
    return -1;
    80001d60:	597d                	li	s2,-1
    80001d62:	bfc5                	j	80001d52 <fork+0xfc>

0000000080001d64 <scheduler>:
{
    80001d64:	715d                	addi	sp,sp,-80
    80001d66:	e486                	sd	ra,72(sp)
    80001d68:	e0a2                	sd	s0,64(sp)
    80001d6a:	fc26                	sd	s1,56(sp)
    80001d6c:	f84a                	sd	s2,48(sp)
    80001d6e:	f44e                	sd	s3,40(sp)
    80001d70:	f052                	sd	s4,32(sp)
    80001d72:	ec56                	sd	s5,24(sp)
    80001d74:	e85a                	sd	s6,16(sp)
    80001d76:	e45e                	sd	s7,8(sp)
    80001d78:	e062                	sd	s8,0(sp)
    80001d7a:	0880                	addi	s0,sp,80
    80001d7c:	8792                	mv	a5,tp
  int id = r_tp();
    80001d7e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d80:	00779b13          	slli	s6,a5,0x7
    80001d84:	0000e717          	auipc	a4,0xe
    80001d88:	e0c70713          	addi	a4,a4,-500 # 8000fb90 <pid_lock>
    80001d8c:	975a                	add	a4,a4,s6
    80001d8e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d92:	0000e717          	auipc	a4,0xe
    80001d96:	e3670713          	addi	a4,a4,-458 # 8000fbc8 <cpus+0x8>
    80001d9a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d9c:	4c11                	li	s8,4
        c->proc = p;
    80001d9e:	079e                	slli	a5,a5,0x7
    80001da0:	0000ea17          	auipc	s4,0xe
    80001da4:	df0a0a13          	addi	s4,s4,-528 # 8000fb90 <pid_lock>
    80001da8:	9a3e                	add	s4,s4,a5
        found = 1;
    80001daa:	4b85                	li	s7,1
    80001dac:	a0a9                	j	80001df6 <scheduler+0x92>
      release(&p->lock);
    80001dae:	8526                	mv	a0,s1
    80001db0:	ee3fe0ef          	jal	80000c92 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001db4:	39048493          	addi	s1,s1,912
    80001db8:	03248563          	beq	s1,s2,80001de2 <scheduler+0x7e>
      acquire(&p->lock);
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	e41fe0ef          	jal	80000bfe <acquire>
      if(p->state == RUNNABLE) {
    80001dc2:	4c9c                	lw	a5,24(s1)
    80001dc4:	ff3795e3          	bne	a5,s3,80001dae <scheduler+0x4a>
        p->state = RUNNING;
    80001dc8:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001dcc:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001dd0:	06048593          	addi	a1,s1,96
    80001dd4:	855a                	mv	a0,s6
    80001dd6:	5b6000ef          	jal	8000238c <swtch>
        c->proc = 0;
    80001dda:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dde:	8ade                	mv	s5,s7
    80001de0:	b7f9                	j	80001dae <scheduler+0x4a>
    if(found == 0) {
    80001de2:	000a9a63          	bnez	s5,80001df6 <scheduler+0x92>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001de6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dee:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001df2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001df6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dfa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dfe:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e02:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e04:	0000e497          	auipc	s1,0xe
    80001e08:	1bc48493          	addi	s1,s1,444 # 8000ffc0 <proc>
      if(p->state == RUNNABLE) {
    80001e0c:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e0e:	0001c917          	auipc	s2,0x1c
    80001e12:	5b290913          	addi	s2,s2,1458 # 8001e3c0 <tickslock>
    80001e16:	b75d                	j	80001dbc <scheduler+0x58>

0000000080001e18 <sched>:
{
    80001e18:	7179                	addi	sp,sp,-48
    80001e1a:	f406                	sd	ra,40(sp)
    80001e1c:	f022                	sd	s0,32(sp)
    80001e1e:	ec26                	sd	s1,24(sp)
    80001e20:	e84a                	sd	s2,16(sp)
    80001e22:	e44e                	sd	s3,8(sp)
    80001e24:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e26:	ab7ff0ef          	jal	800018dc <myproc>
    80001e2a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e2c:	d69fe0ef          	jal	80000b94 <holding>
    80001e30:	c92d                	beqz	a0,80001ea2 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e32:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e34:	2781                	sext.w	a5,a5
    80001e36:	079e                	slli	a5,a5,0x7
    80001e38:	0000e717          	auipc	a4,0xe
    80001e3c:	d5870713          	addi	a4,a4,-680 # 8000fb90 <pid_lock>
    80001e40:	97ba                	add	a5,a5,a4
    80001e42:	0a87a703          	lw	a4,168(a5)
    80001e46:	4785                	li	a5,1
    80001e48:	06f71363          	bne	a4,a5,80001eae <sched+0x96>
  if(p->state == RUNNING)
    80001e4c:	4c98                	lw	a4,24(s1)
    80001e4e:	4791                	li	a5,4
    80001e50:	06f70563          	beq	a4,a5,80001eba <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e54:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e58:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e5a:	e7b5                	bnez	a5,80001ec6 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e5c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e5e:	0000e917          	auipc	s2,0xe
    80001e62:	d3290913          	addi	s2,s2,-718 # 8000fb90 <pid_lock>
    80001e66:	2781                	sext.w	a5,a5
    80001e68:	079e                	slli	a5,a5,0x7
    80001e6a:	97ca                	add	a5,a5,s2
    80001e6c:	0ac7a983          	lw	s3,172(a5)
    80001e70:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e72:	2781                	sext.w	a5,a5
    80001e74:	079e                	slli	a5,a5,0x7
    80001e76:	0000e597          	auipc	a1,0xe
    80001e7a:	d5258593          	addi	a1,a1,-686 # 8000fbc8 <cpus+0x8>
    80001e7e:	95be                	add	a1,a1,a5
    80001e80:	06048513          	addi	a0,s1,96
    80001e84:	508000ef          	jal	8000238c <swtch>
    80001e88:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e8a:	2781                	sext.w	a5,a5
    80001e8c:	079e                	slli	a5,a5,0x7
    80001e8e:	993e                	add	s2,s2,a5
    80001e90:	0b392623          	sw	s3,172(s2)
}
    80001e94:	70a2                	ld	ra,40(sp)
    80001e96:	7402                	ld	s0,32(sp)
    80001e98:	64e2                	ld	s1,24(sp)
    80001e9a:	6942                	ld	s2,16(sp)
    80001e9c:	69a2                	ld	s3,8(sp)
    80001e9e:	6145                	addi	sp,sp,48
    80001ea0:	8082                	ret
    panic("sched p->lock");
    80001ea2:	00005517          	auipc	a0,0x5
    80001ea6:	39650513          	addi	a0,a0,918 # 80007238 <etext+0x238>
    80001eaa:	8f5fe0ef          	jal	8000079e <panic>
    panic("sched locks");
    80001eae:	00005517          	auipc	a0,0x5
    80001eb2:	39a50513          	addi	a0,a0,922 # 80007248 <etext+0x248>
    80001eb6:	8e9fe0ef          	jal	8000079e <panic>
    panic("sched running");
    80001eba:	00005517          	auipc	a0,0x5
    80001ebe:	39e50513          	addi	a0,a0,926 # 80007258 <etext+0x258>
    80001ec2:	8ddfe0ef          	jal	8000079e <panic>
    panic("sched interruptible");
    80001ec6:	00005517          	auipc	a0,0x5
    80001eca:	3a250513          	addi	a0,a0,930 # 80007268 <etext+0x268>
    80001ece:	8d1fe0ef          	jal	8000079e <panic>

0000000080001ed2 <yield>:
{
    80001ed2:	1101                	addi	sp,sp,-32
    80001ed4:	ec06                	sd	ra,24(sp)
    80001ed6:	e822                	sd	s0,16(sp)
    80001ed8:	e426                	sd	s1,8(sp)
    80001eda:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001edc:	a01ff0ef          	jal	800018dc <myproc>
    80001ee0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ee2:	d1dfe0ef          	jal	80000bfe <acquire>
  p->state = RUNNABLE;
    80001ee6:	478d                	li	a5,3
    80001ee8:	cc9c                	sw	a5,24(s1)
  sched();
    80001eea:	f2fff0ef          	jal	80001e18 <sched>
  release(&p->lock);
    80001eee:	8526                	mv	a0,s1
    80001ef0:	da3fe0ef          	jal	80000c92 <release>
}
    80001ef4:	60e2                	ld	ra,24(sp)
    80001ef6:	6442                	ld	s0,16(sp)
    80001ef8:	64a2                	ld	s1,8(sp)
    80001efa:	6105                	addi	sp,sp,32
    80001efc:	8082                	ret

0000000080001efe <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001efe:	7179                	addi	sp,sp,-48
    80001f00:	f406                	sd	ra,40(sp)
    80001f02:	f022                	sd	s0,32(sp)
    80001f04:	ec26                	sd	s1,24(sp)
    80001f06:	e84a                	sd	s2,16(sp)
    80001f08:	e44e                	sd	s3,8(sp)
    80001f0a:	1800                	addi	s0,sp,48
    80001f0c:	89aa                	mv	s3,a0
    80001f0e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f10:	9cdff0ef          	jal	800018dc <myproc>
    80001f14:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f16:	ce9fe0ef          	jal	80000bfe <acquire>
  release(lk);
    80001f1a:	854a                	mv	a0,s2
    80001f1c:	d77fe0ef          	jal	80000c92 <release>

  // Go to sleep.
  p->chan = chan;
    80001f20:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f24:	4789                	li	a5,2
    80001f26:	cc9c                	sw	a5,24(s1)

  sched();
    80001f28:	ef1ff0ef          	jal	80001e18 <sched>

  // Tidy up.
  p->chan = 0;
    80001f2c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f30:	8526                	mv	a0,s1
    80001f32:	d61fe0ef          	jal	80000c92 <release>
  acquire(lk);
    80001f36:	854a                	mv	a0,s2
    80001f38:	cc7fe0ef          	jal	80000bfe <acquire>
}
    80001f3c:	70a2                	ld	ra,40(sp)
    80001f3e:	7402                	ld	s0,32(sp)
    80001f40:	64e2                	ld	s1,24(sp)
    80001f42:	6942                	ld	s2,16(sp)
    80001f44:	69a2                	ld	s3,8(sp)
    80001f46:	6145                	addi	sp,sp,48
    80001f48:	8082                	ret

0000000080001f4a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f4a:	7139                	addi	sp,sp,-64
    80001f4c:	fc06                	sd	ra,56(sp)
    80001f4e:	f822                	sd	s0,48(sp)
    80001f50:	f426                	sd	s1,40(sp)
    80001f52:	f04a                	sd	s2,32(sp)
    80001f54:	ec4e                	sd	s3,24(sp)
    80001f56:	e852                	sd	s4,16(sp)
    80001f58:	e456                	sd	s5,8(sp)
    80001f5a:	0080                	addi	s0,sp,64
    80001f5c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f5e:	0000e497          	auipc	s1,0xe
    80001f62:	06248493          	addi	s1,s1,98 # 8000ffc0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f66:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f68:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f6a:	0001c917          	auipc	s2,0x1c
    80001f6e:	45690913          	addi	s2,s2,1110 # 8001e3c0 <tickslock>
    80001f72:	a801                	j	80001f82 <wakeup+0x38>
      }
      release(&p->lock);
    80001f74:	8526                	mv	a0,s1
    80001f76:	d1dfe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f7a:	39048493          	addi	s1,s1,912
    80001f7e:	03248263          	beq	s1,s2,80001fa2 <wakeup+0x58>
    if(p != myproc()){
    80001f82:	95bff0ef          	jal	800018dc <myproc>
    80001f86:	fea48ae3          	beq	s1,a0,80001f7a <wakeup+0x30>
      acquire(&p->lock);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	c73fe0ef          	jal	80000bfe <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f90:	4c9c                	lw	a5,24(s1)
    80001f92:	ff3791e3          	bne	a5,s3,80001f74 <wakeup+0x2a>
    80001f96:	709c                	ld	a5,32(s1)
    80001f98:	fd479ee3          	bne	a5,s4,80001f74 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f9c:	0154ac23          	sw	s5,24(s1)
    80001fa0:	bfd1                	j	80001f74 <wakeup+0x2a>
    }
  }
}
    80001fa2:	70e2                	ld	ra,56(sp)
    80001fa4:	7442                	ld	s0,48(sp)
    80001fa6:	74a2                	ld	s1,40(sp)
    80001fa8:	7902                	ld	s2,32(sp)
    80001faa:	69e2                	ld	s3,24(sp)
    80001fac:	6a42                	ld	s4,16(sp)
    80001fae:	6aa2                	ld	s5,8(sp)
    80001fb0:	6121                	addi	sp,sp,64
    80001fb2:	8082                	ret

0000000080001fb4 <reparent>:
{
    80001fb4:	7179                	addi	sp,sp,-48
    80001fb6:	f406                	sd	ra,40(sp)
    80001fb8:	f022                	sd	s0,32(sp)
    80001fba:	ec26                	sd	s1,24(sp)
    80001fbc:	e84a                	sd	s2,16(sp)
    80001fbe:	e44e                	sd	s3,8(sp)
    80001fc0:	e052                	sd	s4,0(sp)
    80001fc2:	1800                	addi	s0,sp,48
    80001fc4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fc6:	0000e497          	auipc	s1,0xe
    80001fca:	ffa48493          	addi	s1,s1,-6 # 8000ffc0 <proc>
      pp->parent = initproc;
    80001fce:	00006a17          	auipc	s4,0x6
    80001fd2:	a8aa0a13          	addi	s4,s4,-1398 # 80007a58 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fd6:	0001c997          	auipc	s3,0x1c
    80001fda:	3ea98993          	addi	s3,s3,1002 # 8001e3c0 <tickslock>
    80001fde:	a029                	j	80001fe8 <reparent+0x34>
    80001fe0:	39048493          	addi	s1,s1,912
    80001fe4:	01348b63          	beq	s1,s3,80001ffa <reparent+0x46>
    if(pp->parent == p){
    80001fe8:	7c9c                	ld	a5,56(s1)
    80001fea:	ff279be3          	bne	a5,s2,80001fe0 <reparent+0x2c>
      pp->parent = initproc;
    80001fee:	000a3503          	ld	a0,0(s4)
    80001ff2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001ff4:	f57ff0ef          	jal	80001f4a <wakeup>
    80001ff8:	b7e5                	j	80001fe0 <reparent+0x2c>
}
    80001ffa:	70a2                	ld	ra,40(sp)
    80001ffc:	7402                	ld	s0,32(sp)
    80001ffe:	64e2                	ld	s1,24(sp)
    80002000:	6942                	ld	s2,16(sp)
    80002002:	69a2                	ld	s3,8(sp)
    80002004:	6a02                	ld	s4,0(sp)
    80002006:	6145                	addi	sp,sp,48
    80002008:	8082                	ret

000000008000200a <exit>:
{
    8000200a:	7179                	addi	sp,sp,-48
    8000200c:	f406                	sd	ra,40(sp)
    8000200e:	f022                	sd	s0,32(sp)
    80002010:	ec26                	sd	s1,24(sp)
    80002012:	e84a                	sd	s2,16(sp)
    80002014:	e44e                	sd	s3,8(sp)
    80002016:	e052                	sd	s4,0(sp)
    80002018:	1800                	addi	s0,sp,48
    8000201a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000201c:	8c1ff0ef          	jal	800018dc <myproc>
    80002020:	89aa                	mv	s3,a0
  if(p == initproc)
    80002022:	00006797          	auipc	a5,0x6
    80002026:	a367b783          	ld	a5,-1482(a5) # 80007a58 <initproc>
    8000202a:	0d050493          	addi	s1,a0,208
    8000202e:	15050913          	addi	s2,a0,336
    80002032:	00a79b63          	bne	a5,a0,80002048 <exit+0x3e>
    panic("init exiting");
    80002036:	00005517          	auipc	a0,0x5
    8000203a:	24a50513          	addi	a0,a0,586 # 80007280 <etext+0x280>
    8000203e:	f60fe0ef          	jal	8000079e <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002042:	04a1                	addi	s1,s1,8
    80002044:	01248963          	beq	s1,s2,80002056 <exit+0x4c>
    if(p->ofile[fd]){
    80002048:	6088                	ld	a0,0(s1)
    8000204a:	dd65                	beqz	a0,80002042 <exit+0x38>
      fileclose(f);
    8000204c:	753010ef          	jal	80003f9e <fileclose>
      p->ofile[fd] = 0;
    80002050:	0004b023          	sd	zero,0(s1)
    80002054:	b7fd                	j	80002042 <exit+0x38>
  begin_op();
    80002056:	329010ef          	jal	80003b7e <begin_op>
  iput(p->cwd);
    8000205a:	1509b503          	ld	a0,336(s3)
    8000205e:	3f0010ef          	jal	8000344e <iput>
  end_op();
    80002062:	387010ef          	jal	80003be8 <end_op>
  p->cwd = 0;
    80002066:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000206a:	0000e497          	auipc	s1,0xe
    8000206e:	b3e48493          	addi	s1,s1,-1218 # 8000fba8 <wait_lock>
    80002072:	8526                	mv	a0,s1
    80002074:	b8bfe0ef          	jal	80000bfe <acquire>
  reparent(p);
    80002078:	854e                	mv	a0,s3
    8000207a:	f3bff0ef          	jal	80001fb4 <reparent>
  wakeup(p->parent);
    8000207e:	0389b503          	ld	a0,56(s3)
    80002082:	ec9ff0ef          	jal	80001f4a <wakeup>
  acquire(&p->lock);
    80002086:	854e                	mv	a0,s3
    80002088:	b77fe0ef          	jal	80000bfe <acquire>
  p->xstate = status;
    8000208c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002090:	4795                	li	a5,5
    80002092:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002096:	8526                	mv	a0,s1
    80002098:	bfbfe0ef          	jal	80000c92 <release>
  sched();
    8000209c:	d7dff0ef          	jal	80001e18 <sched>
  panic("zombie exit");
    800020a0:	00005517          	auipc	a0,0x5
    800020a4:	1f050513          	addi	a0,a0,496 # 80007290 <etext+0x290>
    800020a8:	ef6fe0ef          	jal	8000079e <panic>

00000000800020ac <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800020ac:	7179                	addi	sp,sp,-48
    800020ae:	f406                	sd	ra,40(sp)
    800020b0:	f022                	sd	s0,32(sp)
    800020b2:	ec26                	sd	s1,24(sp)
    800020b4:	e84a                	sd	s2,16(sp)
    800020b6:	e44e                	sd	s3,8(sp)
    800020b8:	1800                	addi	s0,sp,48
    800020ba:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020bc:	0000e497          	auipc	s1,0xe
    800020c0:	f0448493          	addi	s1,s1,-252 # 8000ffc0 <proc>
    800020c4:	0001c997          	auipc	s3,0x1c
    800020c8:	2fc98993          	addi	s3,s3,764 # 8001e3c0 <tickslock>
    acquire(&p->lock);
    800020cc:	8526                	mv	a0,s1
    800020ce:	b31fe0ef          	jal	80000bfe <acquire>
    if(p->pid == pid){
    800020d2:	589c                	lw	a5,48(s1)
    800020d4:	01278b63          	beq	a5,s2,800020ea <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020d8:	8526                	mv	a0,s1
    800020da:	bb9fe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020de:	39048493          	addi	s1,s1,912
    800020e2:	ff3495e3          	bne	s1,s3,800020cc <kill+0x20>
  }
  return -1;
    800020e6:	557d                	li	a0,-1
    800020e8:	a819                	j	800020fe <kill+0x52>
      p->killed = 1;
    800020ea:	4785                	li	a5,1
    800020ec:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020ee:	4c98                	lw	a4,24(s1)
    800020f0:	4789                	li	a5,2
    800020f2:	00f70d63          	beq	a4,a5,8000210c <kill+0x60>
      release(&p->lock);
    800020f6:	8526                	mv	a0,s1
    800020f8:	b9bfe0ef          	jal	80000c92 <release>
      return 0;
    800020fc:	4501                	li	a0,0
}
    800020fe:	70a2                	ld	ra,40(sp)
    80002100:	7402                	ld	s0,32(sp)
    80002102:	64e2                	ld	s1,24(sp)
    80002104:	6942                	ld	s2,16(sp)
    80002106:	69a2                	ld	s3,8(sp)
    80002108:	6145                	addi	sp,sp,48
    8000210a:	8082                	ret
        p->state = RUNNABLE;
    8000210c:	478d                	li	a5,3
    8000210e:	cc9c                	sw	a5,24(s1)
    80002110:	b7dd                	j	800020f6 <kill+0x4a>

0000000080002112 <setkilled>:

void
setkilled(struct proc *p)
{
    80002112:	1101                	addi	sp,sp,-32
    80002114:	ec06                	sd	ra,24(sp)
    80002116:	e822                	sd	s0,16(sp)
    80002118:	e426                	sd	s1,8(sp)
    8000211a:	1000                	addi	s0,sp,32
    8000211c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000211e:	ae1fe0ef          	jal	80000bfe <acquire>
  p->killed = 1;
    80002122:	4785                	li	a5,1
    80002124:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	b6bfe0ef          	jal	80000c92 <release>
}
    8000212c:	60e2                	ld	ra,24(sp)
    8000212e:	6442                	ld	s0,16(sp)
    80002130:	64a2                	ld	s1,8(sp)
    80002132:	6105                	addi	sp,sp,32
    80002134:	8082                	ret

0000000080002136 <killed>:

int
killed(struct proc *p)
{
    80002136:	1101                	addi	sp,sp,-32
    80002138:	ec06                	sd	ra,24(sp)
    8000213a:	e822                	sd	s0,16(sp)
    8000213c:	e426                	sd	s1,8(sp)
    8000213e:	e04a                	sd	s2,0(sp)
    80002140:	1000                	addi	s0,sp,32
    80002142:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002144:	abbfe0ef          	jal	80000bfe <acquire>
  k = p->killed;
    80002148:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000214c:	8526                	mv	a0,s1
    8000214e:	b45fe0ef          	jal	80000c92 <release>
  return k;
}
    80002152:	854a                	mv	a0,s2
    80002154:	60e2                	ld	ra,24(sp)
    80002156:	6442                	ld	s0,16(sp)
    80002158:	64a2                	ld	s1,8(sp)
    8000215a:	6902                	ld	s2,0(sp)
    8000215c:	6105                	addi	sp,sp,32
    8000215e:	8082                	ret

0000000080002160 <wait>:
{
    80002160:	715d                	addi	sp,sp,-80
    80002162:	e486                	sd	ra,72(sp)
    80002164:	e0a2                	sd	s0,64(sp)
    80002166:	fc26                	sd	s1,56(sp)
    80002168:	f84a                	sd	s2,48(sp)
    8000216a:	f44e                	sd	s3,40(sp)
    8000216c:	f052                	sd	s4,32(sp)
    8000216e:	ec56                	sd	s5,24(sp)
    80002170:	e85a                	sd	s6,16(sp)
    80002172:	e45e                	sd	s7,8(sp)
    80002174:	0880                	addi	s0,sp,80
    80002176:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002178:	f64ff0ef          	jal	800018dc <myproc>
    8000217c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000217e:	0000e517          	auipc	a0,0xe
    80002182:	a2a50513          	addi	a0,a0,-1494 # 8000fba8 <wait_lock>
    80002186:	a79fe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    8000218a:	4a15                	li	s4,5
        havekids = 1;
    8000218c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000218e:	0001c997          	auipc	s3,0x1c
    80002192:	23298993          	addi	s3,s3,562 # 8001e3c0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002196:	0000eb97          	auipc	s7,0xe
    8000219a:	a12b8b93          	addi	s7,s7,-1518 # 8000fba8 <wait_lock>
    8000219e:	a869                	j	80002238 <wait+0xd8>
          pid = pp->pid;
    800021a0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021a4:	000b0c63          	beqz	s6,800021bc <wait+0x5c>
    800021a8:	4691                	li	a3,4
    800021aa:	02c48613          	addi	a2,s1,44
    800021ae:	85da                	mv	a1,s6
    800021b0:	05093503          	ld	a0,80(s2)
    800021b4:	bd0ff0ef          	jal	80001584 <copyout>
    800021b8:	02054a63          	bltz	a0,800021ec <wait+0x8c>
          freeproc(pp);
    800021bc:	8526                	mv	a0,s1
    800021be:	891ff0ef          	jal	80001a4e <freeproc>
          release(&pp->lock);
    800021c2:	8526                	mv	a0,s1
    800021c4:	acffe0ef          	jal	80000c92 <release>
          release(&wait_lock);
    800021c8:	0000e517          	auipc	a0,0xe
    800021cc:	9e050513          	addi	a0,a0,-1568 # 8000fba8 <wait_lock>
    800021d0:	ac3fe0ef          	jal	80000c92 <release>
}
    800021d4:	854e                	mv	a0,s3
    800021d6:	60a6                	ld	ra,72(sp)
    800021d8:	6406                	ld	s0,64(sp)
    800021da:	74e2                	ld	s1,56(sp)
    800021dc:	7942                	ld	s2,48(sp)
    800021de:	79a2                	ld	s3,40(sp)
    800021e0:	7a02                	ld	s4,32(sp)
    800021e2:	6ae2                	ld	s5,24(sp)
    800021e4:	6b42                	ld	s6,16(sp)
    800021e6:	6ba2                	ld	s7,8(sp)
    800021e8:	6161                	addi	sp,sp,80
    800021ea:	8082                	ret
            release(&pp->lock);
    800021ec:	8526                	mv	a0,s1
    800021ee:	aa5fe0ef          	jal	80000c92 <release>
            release(&wait_lock);
    800021f2:	0000e517          	auipc	a0,0xe
    800021f6:	9b650513          	addi	a0,a0,-1610 # 8000fba8 <wait_lock>
    800021fa:	a99fe0ef          	jal	80000c92 <release>
            return -1;
    800021fe:	59fd                	li	s3,-1
    80002200:	bfd1                	j	800021d4 <wait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002202:	39048493          	addi	s1,s1,912
    80002206:	03348063          	beq	s1,s3,80002226 <wait+0xc6>
      if(pp->parent == p){
    8000220a:	7c9c                	ld	a5,56(s1)
    8000220c:	ff279be3          	bne	a5,s2,80002202 <wait+0xa2>
        acquire(&pp->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	9edfe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    80002216:	4c9c                	lw	a5,24(s1)
    80002218:	f94784e3          	beq	a5,s4,800021a0 <wait+0x40>
        release(&pp->lock);
    8000221c:	8526                	mv	a0,s1
    8000221e:	a75fe0ef          	jal	80000c92 <release>
        havekids = 1;
    80002222:	8756                	mv	a4,s5
    80002224:	bff9                	j	80002202 <wait+0xa2>
    if(!havekids || killed(p)){
    80002226:	cf19                	beqz	a4,80002244 <wait+0xe4>
    80002228:	854a                	mv	a0,s2
    8000222a:	f0dff0ef          	jal	80002136 <killed>
    8000222e:	e919                	bnez	a0,80002244 <wait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002230:	85de                	mv	a1,s7
    80002232:	854a                	mv	a0,s2
    80002234:	ccbff0ef          	jal	80001efe <sleep>
    havekids = 0;
    80002238:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000223a:	0000e497          	auipc	s1,0xe
    8000223e:	d8648493          	addi	s1,s1,-634 # 8000ffc0 <proc>
    80002242:	b7e1                	j	8000220a <wait+0xaa>
      release(&wait_lock);
    80002244:	0000e517          	auipc	a0,0xe
    80002248:	96450513          	addi	a0,a0,-1692 # 8000fba8 <wait_lock>
    8000224c:	a47fe0ef          	jal	80000c92 <release>
      return -1;
    80002250:	59fd                	li	s3,-1
    80002252:	b749                	j	800021d4 <wait+0x74>

0000000080002254 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	e052                	sd	s4,0(sp)
    80002262:	1800                	addi	s0,sp,48
    80002264:	84aa                	mv	s1,a0
    80002266:	892e                	mv	s2,a1
    80002268:	89b2                	mv	s3,a2
    8000226a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000226c:	e70ff0ef          	jal	800018dc <myproc>
  if(user_dst){
    80002270:	cc99                	beqz	s1,8000228e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002272:	86d2                	mv	a3,s4
    80002274:	864e                	mv	a2,s3
    80002276:	85ca                	mv	a1,s2
    80002278:	6928                	ld	a0,80(a0)
    8000227a:	b0aff0ef          	jal	80001584 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6a02                	ld	s4,0(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret
    memmove((char *)dst, src, len);
    8000228e:	000a061b          	sext.w	a2,s4
    80002292:	85ce                	mv	a1,s3
    80002294:	854a                	mv	a0,s2
    80002296:	a9dfe0ef          	jal	80000d32 <memmove>
    return 0;
    8000229a:	8526                	mv	a0,s1
    8000229c:	b7cd                	j	8000227e <either_copyout+0x2a>

000000008000229e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000229e:	7179                	addi	sp,sp,-48
    800022a0:	f406                	sd	ra,40(sp)
    800022a2:	f022                	sd	s0,32(sp)
    800022a4:	ec26                	sd	s1,24(sp)
    800022a6:	e84a                	sd	s2,16(sp)
    800022a8:	e44e                	sd	s3,8(sp)
    800022aa:	e052                	sd	s4,0(sp)
    800022ac:	1800                	addi	s0,sp,48
    800022ae:	892a                	mv	s2,a0
    800022b0:	84ae                	mv	s1,a1
    800022b2:	89b2                	mv	s3,a2
    800022b4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022b6:	e26ff0ef          	jal	800018dc <myproc>
  if(user_src){
    800022ba:	cc99                	beqz	s1,800022d8 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022bc:	86d2                	mv	a3,s4
    800022be:	864e                	mv	a2,s3
    800022c0:	85ca                	mv	a1,s2
    800022c2:	6928                	ld	a0,80(a0)
    800022c4:	b70ff0ef          	jal	80001634 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022c8:	70a2                	ld	ra,40(sp)
    800022ca:	7402                	ld	s0,32(sp)
    800022cc:	64e2                	ld	s1,24(sp)
    800022ce:	6942                	ld	s2,16(sp)
    800022d0:	69a2                	ld	s3,8(sp)
    800022d2:	6a02                	ld	s4,0(sp)
    800022d4:	6145                	addi	sp,sp,48
    800022d6:	8082                	ret
    memmove(dst, (char*)src, len);
    800022d8:	000a061b          	sext.w	a2,s4
    800022dc:	85ce                	mv	a1,s3
    800022de:	854a                	mv	a0,s2
    800022e0:	a53fe0ef          	jal	80000d32 <memmove>
    return 0;
    800022e4:	8526                	mv	a0,s1
    800022e6:	b7cd                	j	800022c8 <either_copyin+0x2a>

00000000800022e8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022e8:	715d                	addi	sp,sp,-80
    800022ea:	e486                	sd	ra,72(sp)
    800022ec:	e0a2                	sd	s0,64(sp)
    800022ee:	fc26                	sd	s1,56(sp)
    800022f0:	f84a                	sd	s2,48(sp)
    800022f2:	f44e                	sd	s3,40(sp)
    800022f4:	f052                	sd	s4,32(sp)
    800022f6:	ec56                	sd	s5,24(sp)
    800022f8:	e85a                	sd	s6,16(sp)
    800022fa:	e45e                	sd	s7,8(sp)
    800022fc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022fe:	00005517          	auipc	a0,0x5
    80002302:	d7a50513          	addi	a0,a0,-646 # 80007078 <etext+0x78>
    80002306:	9c8fe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000230a:	0000e497          	auipc	s1,0xe
    8000230e:	e0e48493          	addi	s1,s1,-498 # 80010118 <proc+0x158>
    80002312:	0001c917          	auipc	s2,0x1c
    80002316:	20690913          	addi	s2,s2,518 # 8001e518 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000231a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000231c:	00005997          	auipc	s3,0x5
    80002320:	f8498993          	addi	s3,s3,-124 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002324:	00005a97          	auipc	s5,0x5
    80002328:	f84a8a93          	addi	s5,s5,-124 # 800072a8 <etext+0x2a8>
    printf("\n");
    8000232c:	00005a17          	auipc	s4,0x5
    80002330:	d4ca0a13          	addi	s4,s4,-692 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002334:	00005b97          	auipc	s7,0x5
    80002338:	4f4b8b93          	addi	s7,s7,1268 # 80007828 <syscall_names>
    8000233c:	a829                	j	80002356 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000233e:	ed86a583          	lw	a1,-296(a3)
    80002342:	8556                	mv	a0,s5
    80002344:	98afe0ef          	jal	800004ce <printf>
    printf("\n");
    80002348:	8552                	mv	a0,s4
    8000234a:	984fe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000234e:	39048493          	addi	s1,s1,912
    80002352:	03248263          	beq	s1,s2,80002376 <procdump+0x8e>
    if(p->state == UNUSED)
    80002356:	86a6                	mv	a3,s1
    80002358:	ec04a783          	lw	a5,-320(s1)
    8000235c:	dbed                	beqz	a5,8000234e <procdump+0x66>
      state = "???";
    8000235e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002360:	fcfb6fe3          	bltu	s6,a5,8000233e <procdump+0x56>
    80002364:	02079713          	slli	a4,a5,0x20
    80002368:	01d75793          	srli	a5,a4,0x1d
    8000236c:	97de                	add	a5,a5,s7
    8000236e:	7fd0                	ld	a2,184(a5)
    80002370:	f679                	bnez	a2,8000233e <procdump+0x56>
      state = "???";
    80002372:	864e                	mv	a2,s3
    80002374:	b7e9                	j	8000233e <procdump+0x56>
  }
}
    80002376:	60a6                	ld	ra,72(sp)
    80002378:	6406                	ld	s0,64(sp)
    8000237a:	74e2                	ld	s1,56(sp)
    8000237c:	7942                	ld	s2,48(sp)
    8000237e:	79a2                	ld	s3,40(sp)
    80002380:	7a02                	ld	s4,32(sp)
    80002382:	6ae2                	ld	s5,24(sp)
    80002384:	6b42                	ld	s6,16(sp)
    80002386:	6ba2                	ld	s7,8(sp)
    80002388:	6161                	addi	sp,sp,80
    8000238a:	8082                	ret

000000008000238c <swtch>:
    8000238c:	00153023          	sd	ra,0(a0)
    80002390:	00253423          	sd	sp,8(a0)
    80002394:	e900                	sd	s0,16(a0)
    80002396:	ed04                	sd	s1,24(a0)
    80002398:	03253023          	sd	s2,32(a0)
    8000239c:	03353423          	sd	s3,40(a0)
    800023a0:	03453823          	sd	s4,48(a0)
    800023a4:	03553c23          	sd	s5,56(a0)
    800023a8:	05653023          	sd	s6,64(a0)
    800023ac:	05753423          	sd	s7,72(a0)
    800023b0:	05853823          	sd	s8,80(a0)
    800023b4:	05953c23          	sd	s9,88(a0)
    800023b8:	07a53023          	sd	s10,96(a0)
    800023bc:	07b53423          	sd	s11,104(a0)
    800023c0:	0005b083          	ld	ra,0(a1)
    800023c4:	0085b103          	ld	sp,8(a1)
    800023c8:	6980                	ld	s0,16(a1)
    800023ca:	6d84                	ld	s1,24(a1)
    800023cc:	0205b903          	ld	s2,32(a1)
    800023d0:	0285b983          	ld	s3,40(a1)
    800023d4:	0305ba03          	ld	s4,48(a1)
    800023d8:	0385ba83          	ld	s5,56(a1)
    800023dc:	0405bb03          	ld	s6,64(a1)
    800023e0:	0485bb83          	ld	s7,72(a1)
    800023e4:	0505bc03          	ld	s8,80(a1)
    800023e8:	0585bc83          	ld	s9,88(a1)
    800023ec:	0605bd03          	ld	s10,96(a1)
    800023f0:	0685bd83          	ld	s11,104(a1)
    800023f4:	8082                	ret

00000000800023f6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023f6:	1141                	addi	sp,sp,-16
    800023f8:	e406                	sd	ra,8(sp)
    800023fa:	e022                	sd	s0,0(sp)
    800023fc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023fe:	00005597          	auipc	a1,0x5
    80002402:	f9258593          	addi	a1,a1,-110 # 80007390 <etext+0x390>
    80002406:	0001c517          	auipc	a0,0x1c
    8000240a:	fba50513          	addi	a0,a0,-70 # 8001e3c0 <tickslock>
    8000240e:	f6cfe0ef          	jal	80000b7a <initlock>
}
    80002412:	60a2                	ld	ra,8(sp)
    80002414:	6402                	ld	s0,0(sp)
    80002416:	0141                	addi	sp,sp,16
    80002418:	8082                	ret

000000008000241a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000241a:	1141                	addi	sp,sp,-16
    8000241c:	e406                	sd	ra,8(sp)
    8000241e:	e022                	sd	s0,0(sp)
    80002420:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002422:	00003797          	auipc	a5,0x3
    80002426:	f2e78793          	addi	a5,a5,-210 # 80005350 <kernelvec>
    8000242a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000242e:	60a2                	ld	ra,8(sp)
    80002430:	6402                	ld	s0,0(sp)
    80002432:	0141                	addi	sp,sp,16
    80002434:	8082                	ret

0000000080002436 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002436:	1141                	addi	sp,sp,-16
    80002438:	e406                	sd	ra,8(sp)
    8000243a:	e022                	sd	s0,0(sp)
    8000243c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000243e:	c9eff0ef          	jal	800018dc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002442:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002446:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002448:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000244c:	00004697          	auipc	a3,0x4
    80002450:	bb468693          	addi	a3,a3,-1100 # 80006000 <_trampoline>
    80002454:	00004717          	auipc	a4,0x4
    80002458:	bac70713          	addi	a4,a4,-1108 # 80006000 <_trampoline>
    8000245c:	8f15                	sub	a4,a4,a3
    8000245e:	040007b7          	lui	a5,0x4000
    80002462:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002464:	07b2                	slli	a5,a5,0xc
    80002466:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002468:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000246c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000246e:	18002673          	csrr	a2,satp
    80002472:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002474:	6d30                	ld	a2,88(a0)
    80002476:	6138                	ld	a4,64(a0)
    80002478:	6585                	lui	a1,0x1
    8000247a:	972e                	add	a4,a4,a1
    8000247c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000247e:	6d38                	ld	a4,88(a0)
    80002480:	00000617          	auipc	a2,0x0
    80002484:	11060613          	addi	a2,a2,272 # 80002590 <usertrap>
    80002488:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000248a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000248c:	8612                	mv	a2,tp
    8000248e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002490:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002494:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002498:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000249c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024a0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024a2:	6f18                	ld	a4,24(a4)
    800024a4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800024a8:	6928                	ld	a0,80(a0)
    800024aa:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800024ac:	00004717          	auipc	a4,0x4
    800024b0:	bf070713          	addi	a4,a4,-1040 # 8000609c <userret>
    800024b4:	8f15                	sub	a4,a4,a3
    800024b6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800024b8:	577d                	li	a4,-1
    800024ba:	177e                	slli	a4,a4,0x3f
    800024bc:	8d59                	or	a0,a0,a4
    800024be:	9782                	jalr	a5
}
    800024c0:	60a2                	ld	ra,8(sp)
    800024c2:	6402                	ld	s0,0(sp)
    800024c4:	0141                	addi	sp,sp,16
    800024c6:	8082                	ret

00000000800024c8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024c8:	1101                	addi	sp,sp,-32
    800024ca:	ec06                	sd	ra,24(sp)
    800024cc:	e822                	sd	s0,16(sp)
    800024ce:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800024d0:	bd8ff0ef          	jal	800018a8 <cpuid>
    800024d4:	cd11                	beqz	a0,800024f0 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024d6:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024da:	000f4737          	lui	a4,0xf4
    800024de:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024e2:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024e4:	14d79073          	csrw	stimecmp,a5
}
    800024e8:	60e2                	ld	ra,24(sp)
    800024ea:	6442                	ld	s0,16(sp)
    800024ec:	6105                	addi	sp,sp,32
    800024ee:	8082                	ret
    800024f0:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024f2:	0001c497          	auipc	s1,0x1c
    800024f6:	ece48493          	addi	s1,s1,-306 # 8001e3c0 <tickslock>
    800024fa:	8526                	mv	a0,s1
    800024fc:	f02fe0ef          	jal	80000bfe <acquire>
    ticks++;
    80002500:	00005517          	auipc	a0,0x5
    80002504:	56050513          	addi	a0,a0,1376 # 80007a60 <ticks>
    80002508:	411c                	lw	a5,0(a0)
    8000250a:	2785                	addiw	a5,a5,1
    8000250c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000250e:	a3dff0ef          	jal	80001f4a <wakeup>
    release(&tickslock);
    80002512:	8526                	mv	a0,s1
    80002514:	f7efe0ef          	jal	80000c92 <release>
    80002518:	64a2                	ld	s1,8(sp)
    8000251a:	bf75                	j	800024d6 <clockintr+0xe>

000000008000251c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000251c:	1101                	addi	sp,sp,-32
    8000251e:	ec06                	sd	ra,24(sp)
    80002520:	e822                	sd	s0,16(sp)
    80002522:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002524:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002528:	57fd                	li	a5,-1
    8000252a:	17fe                	slli	a5,a5,0x3f
    8000252c:	07a5                	addi	a5,a5,9
    8000252e:	00f70c63          	beq	a4,a5,80002546 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002532:	57fd                	li	a5,-1
    80002534:	17fe                	slli	a5,a5,0x3f
    80002536:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002538:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000253a:	04f70763          	beq	a4,a5,80002588 <devintr+0x6c>
  }
}
    8000253e:	60e2                	ld	ra,24(sp)
    80002540:	6442                	ld	s0,16(sp)
    80002542:	6105                	addi	sp,sp,32
    80002544:	8082                	ret
    80002546:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002548:	6b5020ef          	jal	800053fc <plic_claim>
    8000254c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000254e:	47a9                	li	a5,10
    80002550:	00f50963          	beq	a0,a5,80002562 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002554:	4785                	li	a5,1
    80002556:	00f50963          	beq	a0,a5,80002568 <devintr+0x4c>
    return 1;
    8000255a:	4505                	li	a0,1
    } else if(irq){
    8000255c:	e889                	bnez	s1,8000256e <devintr+0x52>
    8000255e:	64a2                	ld	s1,8(sp)
    80002560:	bff9                	j	8000253e <devintr+0x22>
      uartintr();
    80002562:	caafe0ef          	jal	80000a0c <uartintr>
    if(irq)
    80002566:	a819                	j	8000257c <devintr+0x60>
      virtio_disk_intr();
    80002568:	324030ef          	jal	8000588c <virtio_disk_intr>
    if(irq)
    8000256c:	a801                	j	8000257c <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000256e:	85a6                	mv	a1,s1
    80002570:	00005517          	auipc	a0,0x5
    80002574:	e2850513          	addi	a0,a0,-472 # 80007398 <etext+0x398>
    80002578:	f57fd0ef          	jal	800004ce <printf>
      plic_complete(irq);
    8000257c:	8526                	mv	a0,s1
    8000257e:	69f020ef          	jal	8000541c <plic_complete>
    return 1;
    80002582:	4505                	li	a0,1
    80002584:	64a2                	ld	s1,8(sp)
    80002586:	bf65                	j	8000253e <devintr+0x22>
    clockintr();
    80002588:	f41ff0ef          	jal	800024c8 <clockintr>
    return 2;
    8000258c:	4509                	li	a0,2
    8000258e:	bf45                	j	8000253e <devintr+0x22>

0000000080002590 <usertrap>:
{
    80002590:	1101                	addi	sp,sp,-32
    80002592:	ec06                	sd	ra,24(sp)
    80002594:	e822                	sd	s0,16(sp)
    80002596:	e426                	sd	s1,8(sp)
    80002598:	e04a                	sd	s2,0(sp)
    8000259a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000259c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025a0:	1007f793          	andi	a5,a5,256
    800025a4:	ef85                	bnez	a5,800025dc <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025a6:	00003797          	auipc	a5,0x3
    800025aa:	daa78793          	addi	a5,a5,-598 # 80005350 <kernelvec>
    800025ae:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025b2:	b2aff0ef          	jal	800018dc <myproc>
    800025b6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025b8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025ba:	14102773          	csrr	a4,sepc
    800025be:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025c0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025c4:	47a1                	li	a5,8
    800025c6:	02f70163          	beq	a4,a5,800025e8 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800025ca:	f53ff0ef          	jal	8000251c <devintr>
    800025ce:	892a                	mv	s2,a0
    800025d0:	c135                	beqz	a0,80002634 <usertrap+0xa4>
  if(killed(p))
    800025d2:	8526                	mv	a0,s1
    800025d4:	b63ff0ef          	jal	80002136 <killed>
    800025d8:	cd1d                	beqz	a0,80002616 <usertrap+0x86>
    800025da:	a81d                	j	80002610 <usertrap+0x80>
    panic("usertrap: not from user mode");
    800025dc:	00005517          	auipc	a0,0x5
    800025e0:	ddc50513          	addi	a0,a0,-548 # 800073b8 <etext+0x3b8>
    800025e4:	9bafe0ef          	jal	8000079e <panic>
    if(killed(p))
    800025e8:	b4fff0ef          	jal	80002136 <killed>
    800025ec:	e121                	bnez	a0,8000262c <usertrap+0x9c>
    p->trapframe->epc += 4;
    800025ee:	6cb8                	ld	a4,88(s1)
    800025f0:	6f1c                	ld	a5,24(a4)
    800025f2:	0791                	addi	a5,a5,4
    800025f4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025fa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025fe:	10079073          	csrw	sstatus,a5
    syscall();
    80002602:	240000ef          	jal	80002842 <syscall>
  if(killed(p))
    80002606:	8526                	mv	a0,s1
    80002608:	b2fff0ef          	jal	80002136 <killed>
    8000260c:	c901                	beqz	a0,8000261c <usertrap+0x8c>
    8000260e:	4901                	li	s2,0
    exit(-1);
    80002610:	557d                	li	a0,-1
    80002612:	9f9ff0ef          	jal	8000200a <exit>
  if(which_dev == 2)
    80002616:	4789                	li	a5,2
    80002618:	04f90563          	beq	s2,a5,80002662 <usertrap+0xd2>
  usertrapret();
    8000261c:	e1bff0ef          	jal	80002436 <usertrapret>
}
    80002620:	60e2                	ld	ra,24(sp)
    80002622:	6442                	ld	s0,16(sp)
    80002624:	64a2                	ld	s1,8(sp)
    80002626:	6902                	ld	s2,0(sp)
    80002628:	6105                	addi	sp,sp,32
    8000262a:	8082                	ret
      exit(-1);
    8000262c:	557d                	li	a0,-1
    8000262e:	9ddff0ef          	jal	8000200a <exit>
    80002632:	bf75                	j	800025ee <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002634:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002638:	5890                	lw	a2,48(s1)
    8000263a:	00005517          	auipc	a0,0x5
    8000263e:	d9e50513          	addi	a0,a0,-610 # 800073d8 <etext+0x3d8>
    80002642:	e8dfd0ef          	jal	800004ce <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002646:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000264a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000264e:	00005517          	auipc	a0,0x5
    80002652:	dba50513          	addi	a0,a0,-582 # 80007408 <etext+0x408>
    80002656:	e79fd0ef          	jal	800004ce <printf>
    setkilled(p);
    8000265a:	8526                	mv	a0,s1
    8000265c:	ab7ff0ef          	jal	80002112 <setkilled>
    80002660:	b75d                	j	80002606 <usertrap+0x76>
    yield();
    80002662:	871ff0ef          	jal	80001ed2 <yield>
    80002666:	bf5d                	j	8000261c <usertrap+0x8c>

0000000080002668 <kerneltrap>:
{
    80002668:	7179                	addi	sp,sp,-48
    8000266a:	f406                	sd	ra,40(sp)
    8000266c:	f022                	sd	s0,32(sp)
    8000266e:	ec26                	sd	s1,24(sp)
    80002670:	e84a                	sd	s2,16(sp)
    80002672:	e44e                	sd	s3,8(sp)
    80002674:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002676:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000267a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000267e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002682:	1004f793          	andi	a5,s1,256
    80002686:	c795                	beqz	a5,800026b2 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002688:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000268c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000268e:	eb85                	bnez	a5,800026be <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002690:	e8dff0ef          	jal	8000251c <devintr>
    80002694:	c91d                	beqz	a0,800026ca <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002696:	4789                	li	a5,2
    80002698:	04f50a63          	beq	a0,a5,800026ec <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000269c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026a0:	10049073          	csrw	sstatus,s1
}
    800026a4:	70a2                	ld	ra,40(sp)
    800026a6:	7402                	ld	s0,32(sp)
    800026a8:	64e2                	ld	s1,24(sp)
    800026aa:	6942                	ld	s2,16(sp)
    800026ac:	69a2                	ld	s3,8(sp)
    800026ae:	6145                	addi	sp,sp,48
    800026b0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026b2:	00005517          	auipc	a0,0x5
    800026b6:	d7e50513          	addi	a0,a0,-642 # 80007430 <etext+0x430>
    800026ba:	8e4fe0ef          	jal	8000079e <panic>
    panic("kerneltrap: interrupts enabled");
    800026be:	00005517          	auipc	a0,0x5
    800026c2:	d9a50513          	addi	a0,a0,-614 # 80007458 <etext+0x458>
    800026c6:	8d8fe0ef          	jal	8000079e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026ca:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026ce:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026d2:	85ce                	mv	a1,s3
    800026d4:	00005517          	auipc	a0,0x5
    800026d8:	da450513          	addi	a0,a0,-604 # 80007478 <etext+0x478>
    800026dc:	df3fd0ef          	jal	800004ce <printf>
    panic("kerneltrap");
    800026e0:	00005517          	auipc	a0,0x5
    800026e4:	dc050513          	addi	a0,a0,-576 # 800074a0 <etext+0x4a0>
    800026e8:	8b6fe0ef          	jal	8000079e <panic>
  if(which_dev == 2 && myproc() != 0)
    800026ec:	9f0ff0ef          	jal	800018dc <myproc>
    800026f0:	d555                	beqz	a0,8000269c <kerneltrap+0x34>
    yield();
    800026f2:	fe0ff0ef          	jal	80001ed2 <yield>
    800026f6:	b75d                	j	8000269c <kerneltrap+0x34>

00000000800026f8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026f8:	1101                	addi	sp,sp,-32
    800026fa:	ec06                	sd	ra,24(sp)
    800026fc:	e822                	sd	s0,16(sp)
    800026fe:	e426                	sd	s1,8(sp)
    80002700:	1000                	addi	s0,sp,32
    80002702:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002704:	9d8ff0ef          	jal	800018dc <myproc>
  switch (n) {
    80002708:	4795                	li	a5,5
    8000270a:	0497e163          	bltu	a5,s1,8000274c <argraw+0x54>
    8000270e:	048a                	slli	s1,s1,0x2
    80002710:	00005717          	auipc	a4,0x5
    80002714:	20070713          	addi	a4,a4,512 # 80007910 <states.0+0x30>
    80002718:	94ba                	add	s1,s1,a4
    8000271a:	409c                	lw	a5,0(s1)
    8000271c:	97ba                	add	a5,a5,a4
    8000271e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002720:	6d3c                	ld	a5,88(a0)
    80002722:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002724:	60e2                	ld	ra,24(sp)
    80002726:	6442                	ld	s0,16(sp)
    80002728:	64a2                	ld	s1,8(sp)
    8000272a:	6105                	addi	sp,sp,32
    8000272c:	8082                	ret
    return p->trapframe->a1;
    8000272e:	6d3c                	ld	a5,88(a0)
    80002730:	7fa8                	ld	a0,120(a5)
    80002732:	bfcd                	j	80002724 <argraw+0x2c>
    return p->trapframe->a2;
    80002734:	6d3c                	ld	a5,88(a0)
    80002736:	63c8                	ld	a0,128(a5)
    80002738:	b7f5                	j	80002724 <argraw+0x2c>
    return p->trapframe->a3;
    8000273a:	6d3c                	ld	a5,88(a0)
    8000273c:	67c8                	ld	a0,136(a5)
    8000273e:	b7dd                	j	80002724 <argraw+0x2c>
    return p->trapframe->a4;
    80002740:	6d3c                	ld	a5,88(a0)
    80002742:	6bc8                	ld	a0,144(a5)
    80002744:	b7c5                	j	80002724 <argraw+0x2c>
    return p->trapframe->a5;
    80002746:	6d3c                	ld	a5,88(a0)
    80002748:	6fc8                	ld	a0,152(a5)
    8000274a:	bfe9                	j	80002724 <argraw+0x2c>
  panic("argraw");
    8000274c:	00005517          	auipc	a0,0x5
    80002750:	d6450513          	addi	a0,a0,-668 # 800074b0 <etext+0x4b0>
    80002754:	84afe0ef          	jal	8000079e <panic>

0000000080002758 <fetchaddr>:
{
    80002758:	1101                	addi	sp,sp,-32
    8000275a:	ec06                	sd	ra,24(sp)
    8000275c:	e822                	sd	s0,16(sp)
    8000275e:	e426                	sd	s1,8(sp)
    80002760:	e04a                	sd	s2,0(sp)
    80002762:	1000                	addi	s0,sp,32
    80002764:	84aa                	mv	s1,a0
    80002766:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002768:	974ff0ef          	jal	800018dc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000276c:	653c                	ld	a5,72(a0)
    8000276e:	02f4f663          	bgeu	s1,a5,8000279a <fetchaddr+0x42>
    80002772:	00848713          	addi	a4,s1,8
    80002776:	02e7e463          	bltu	a5,a4,8000279e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000277a:	46a1                	li	a3,8
    8000277c:	8626                	mv	a2,s1
    8000277e:	85ca                	mv	a1,s2
    80002780:	6928                	ld	a0,80(a0)
    80002782:	eb3fe0ef          	jal	80001634 <copyin>
    80002786:	00a03533          	snez	a0,a0
    8000278a:	40a0053b          	negw	a0,a0
}
    8000278e:	60e2                	ld	ra,24(sp)
    80002790:	6442                	ld	s0,16(sp)
    80002792:	64a2                	ld	s1,8(sp)
    80002794:	6902                	ld	s2,0(sp)
    80002796:	6105                	addi	sp,sp,32
    80002798:	8082                	ret
    return -1;
    8000279a:	557d                	li	a0,-1
    8000279c:	bfcd                	j	8000278e <fetchaddr+0x36>
    8000279e:	557d                	li	a0,-1
    800027a0:	b7fd                	j	8000278e <fetchaddr+0x36>

00000000800027a2 <fetchstr>:
{
    800027a2:	7179                	addi	sp,sp,-48
    800027a4:	f406                	sd	ra,40(sp)
    800027a6:	f022                	sd	s0,32(sp)
    800027a8:	ec26                	sd	s1,24(sp)
    800027aa:	e84a                	sd	s2,16(sp)
    800027ac:	e44e                	sd	s3,8(sp)
    800027ae:	1800                	addi	s0,sp,48
    800027b0:	892a                	mv	s2,a0
    800027b2:	84ae                	mv	s1,a1
    800027b4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027b6:	926ff0ef          	jal	800018dc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027ba:	86ce                	mv	a3,s3
    800027bc:	864a                	mv	a2,s2
    800027be:	85a6                	mv	a1,s1
    800027c0:	6928                	ld	a0,80(a0)
    800027c2:	ef9fe0ef          	jal	800016ba <copyinstr>
    800027c6:	00054c63          	bltz	a0,800027de <fetchstr+0x3c>
  return strlen(buf);
    800027ca:	8526                	mv	a0,s1
    800027cc:	e8afe0ef          	jal	80000e56 <strlen>
}
    800027d0:	70a2                	ld	ra,40(sp)
    800027d2:	7402                	ld	s0,32(sp)
    800027d4:	64e2                	ld	s1,24(sp)
    800027d6:	6942                	ld	s2,16(sp)
    800027d8:	69a2                	ld	s3,8(sp)
    800027da:	6145                	addi	sp,sp,48
    800027dc:	8082                	ret
    return -1;
    800027de:	557d                	li	a0,-1
    800027e0:	bfc5                	j	800027d0 <fetchstr+0x2e>

00000000800027e2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027e2:	1101                	addi	sp,sp,-32
    800027e4:	ec06                	sd	ra,24(sp)
    800027e6:	e822                	sd	s0,16(sp)
    800027e8:	e426                	sd	s1,8(sp)
    800027ea:	1000                	addi	s0,sp,32
    800027ec:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027ee:	f0bff0ef          	jal	800026f8 <argraw>
    800027f2:	c088                	sw	a0,0(s1)
}
    800027f4:	60e2                	ld	ra,24(sp)
    800027f6:	6442                	ld	s0,16(sp)
    800027f8:	64a2                	ld	s1,8(sp)
    800027fa:	6105                	addi	sp,sp,32
    800027fc:	8082                	ret

00000000800027fe <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027fe:	1101                	addi	sp,sp,-32
    80002800:	ec06                	sd	ra,24(sp)
    80002802:	e822                	sd	s0,16(sp)
    80002804:	e426                	sd	s1,8(sp)
    80002806:	1000                	addi	s0,sp,32
    80002808:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000280a:	eefff0ef          	jal	800026f8 <argraw>
    8000280e:	e088                	sd	a0,0(s1)
}
    80002810:	60e2                	ld	ra,24(sp)
    80002812:	6442                	ld	s0,16(sp)
    80002814:	64a2                	ld	s1,8(sp)
    80002816:	6105                	addi	sp,sp,32
    80002818:	8082                	ret

000000008000281a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000281a:	1101                	addi	sp,sp,-32
    8000281c:	ec06                	sd	ra,24(sp)
    8000281e:	e822                	sd	s0,16(sp)
    80002820:	e426                	sd	s1,8(sp)
    80002822:	e04a                	sd	s2,0(sp)
    80002824:	1000                	addi	s0,sp,32
    80002826:	84ae                	mv	s1,a1
    80002828:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000282a:	ecfff0ef          	jal	800026f8 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000282e:	864a                	mv	a2,s2
    80002830:	85a6                	mv	a1,s1
    80002832:	f71ff0ef          	jal	800027a2 <fetchstr>
}
    80002836:	60e2                	ld	ra,24(sp)
    80002838:	6442                	ld	s0,16(sp)
    8000283a:	64a2                	ld	s1,8(sp)
    8000283c:	6902                	ld	s2,0(sp)
    8000283e:	6105                	addi	sp,sp,32
    80002840:	8082                	ret

0000000080002842 <syscall>:
};


void
syscall(void)
{
    80002842:	7139                	addi	sp,sp,-64
    80002844:	fc06                	sd	ra,56(sp)
    80002846:	f822                	sd	s0,48(sp)
    80002848:	f426                	sd	s1,40(sp)
    8000284a:	f04a                	sd	s2,32(sp)
    8000284c:	0080                	addi	s0,sp,64
  int num;
  struct proc *p = myproc();
    8000284e:	88eff0ef          	jal	800018dc <myproc>
    80002852:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002854:	6d3c                	ld	a5,88(a0)
    80002856:	77dc                	ld	a5,168(a5)
    80002858:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000285c:	37fd                	addiw	a5,a5,-1
    8000285e:	4755                	li	a4,21
    80002860:	08f76f63          	bltu	a4,a5,800028fe <syscall+0xbc>
    80002864:	ec4e                	sd	s3,24(sp)
    80002866:	00391713          	slli	a4,s2,0x3
    8000286a:	00005797          	auipc	a5,0x5
    8000286e:	0be78793          	addi	a5,a5,190 # 80007928 <syscalls>
    80002872:	97ba                	add	a5,a5,a4
    80002874:	0007b983          	ld	s3,0(a5)
    80002878:	08098263          	beqz	s3,800028fc <syscall+0xba>
    8000287c:	e852                	sd	s4,16(sp)
    8000287e:	e456                	sd	s5,8(sp)
    80002880:	e05a                	sd	s6,0(sp)
    acquire(&tickslock);
    80002882:	0001c517          	auipc	a0,0x1c
    80002886:	b3e50513          	addi	a0,a0,-1218 # 8001e3c0 <tickslock>
    8000288a:	b74fe0ef          	jal	80000bfe <acquire>
    int start_ticks = ticks;
    8000288e:	00005a97          	auipc	s5,0x5
    80002892:	1d2a8a93          	addi	s5,s5,466 # 80007a60 <ticks>
    80002896:	000aaa03          	lw	s4,0(s5)
    release(&tickslock);
    8000289a:	0001c517          	auipc	a0,0x1c
    8000289e:	b2650513          	addi	a0,a0,-1242 # 8001e3c0 <tickslock>
    800028a2:	bf0fe0ef          	jal	80000c92 <release>
    p->trapframe->a0 = syscalls[num]();
    800028a6:	0584bb03          	ld	s6,88(s1)
    800028aa:	9982                	jalr	s3
    800028ac:	06ab3823          	sd	a0,112(s6)
    acquire(&tickslock);
    800028b0:	0001c517          	auipc	a0,0x1c
    800028b4:	b1050513          	addi	a0,a0,-1264 # 8001e3c0 <tickslock>
    800028b8:	b46fe0ef          	jal	80000bfe <acquire>
    int end_ticks = ticks;
    800028bc:	000aa983          	lw	s3,0(s5)
    release(&tickslock);
    800028c0:	0001c517          	auipc	a0,0x1c
    800028c4:	b0050513          	addi	a0,a0,-1280 # 8001e3c0 <tickslock>
    800028c8:	bcafe0ef          	jal	80000c92 <release>

    struct syscall_stat *stat = &p->syscall_stats[num];
    stat->count++;
    800028cc:	00191793          	slli	a5,s2,0x1
    800028d0:	01278733          	add	a4,a5,s2
    800028d4:	070e                	slli	a4,a4,0x3
    800028d6:	9726                	add	a4,a4,s1
    800028d8:	17872683          	lw	a3,376(a4)
    800028dc:	2685                	addiw	a3,a3,1
    800028de:	16d72c23          	sw	a3,376(a4)
    stat->accum_time += (end_ticks - start_ticks);
    800028e2:	414989bb          	subw	s3,s3,s4
    800028e6:	17c72783          	lw	a5,380(a4)
    800028ea:	013787bb          	addw	a5,a5,s3
    800028ee:	16f72e23          	sw	a5,380(a4)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028f2:	69e2                	ld	s3,24(sp)
    800028f4:	6a42                	ld	s4,16(sp)
    800028f6:	6aa2                	ld	s5,8(sp)
    800028f8:	6b02                	ld	s6,0(sp)
    800028fa:	a839                	j	80002918 <syscall+0xd6>
    800028fc:	69e2                	ld	s3,24(sp)
  } else {
    printf("%d %s: unknown sys call %d\n",
    800028fe:	86ca                	mv	a3,s2
    80002900:	15848613          	addi	a2,s1,344
    80002904:	588c                	lw	a1,48(s1)
    80002906:	00005517          	auipc	a0,0x5
    8000290a:	bb250513          	addi	a0,a0,-1102 # 800074b8 <etext+0x4b8>
    8000290e:	bc1fd0ef          	jal	800004ce <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002912:	6cbc                	ld	a5,88(s1)
    80002914:	577d                	li	a4,-1
    80002916:	fbb8                	sd	a4,112(a5)
  }
}
    80002918:	70e2                	ld	ra,56(sp)
    8000291a:	7442                	ld	s0,48(sp)
    8000291c:	74a2                	ld	s1,40(sp)
    8000291e:	7902                	ld	s2,32(sp)
    80002920:	6121                	addi	sp,sp,64
    80002922:	8082                	ret

0000000080002924 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002924:	1101                	addi	sp,sp,-32
    80002926:	ec06                	sd	ra,24(sp)
    80002928:	e822                	sd	s0,16(sp)
    8000292a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000292c:	fec40593          	addi	a1,s0,-20
    80002930:	4501                	li	a0,0
    80002932:	eb1ff0ef          	jal	800027e2 <argint>
  exit(n);
    80002936:	fec42503          	lw	a0,-20(s0)
    8000293a:	ed0ff0ef          	jal	8000200a <exit>
  return 0; // not reached
}
    8000293e:	4501                	li	a0,0
    80002940:	60e2                	ld	ra,24(sp)
    80002942:	6442                	ld	s0,16(sp)
    80002944:	6105                	addi	sp,sp,32
    80002946:	8082                	ret

0000000080002948 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002948:	1141                	addi	sp,sp,-16
    8000294a:	e406                	sd	ra,8(sp)
    8000294c:	e022                	sd	s0,0(sp)
    8000294e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002950:	f8dfe0ef          	jal	800018dc <myproc>
}
    80002954:	5908                	lw	a0,48(a0)
    80002956:	60a2                	ld	ra,8(sp)
    80002958:	6402                	ld	s0,0(sp)
    8000295a:	0141                	addi	sp,sp,16
    8000295c:	8082                	ret

000000008000295e <sys_fork>:

uint64
sys_fork(void)
{
    8000295e:	1141                	addi	sp,sp,-16
    80002960:	e406                	sd	ra,8(sp)
    80002962:	e022                	sd	s0,0(sp)
    80002964:	0800                	addi	s0,sp,16
  return fork();
    80002966:	af0ff0ef          	jal	80001c56 <fork>
}
    8000296a:	60a2                	ld	ra,8(sp)
    8000296c:	6402                	ld	s0,0(sp)
    8000296e:	0141                	addi	sp,sp,16
    80002970:	8082                	ret

0000000080002972 <sys_wait>:

uint64
sys_wait(void)
{
    80002972:	1101                	addi	sp,sp,-32
    80002974:	ec06                	sd	ra,24(sp)
    80002976:	e822                	sd	s0,16(sp)
    80002978:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000297a:	fe840593          	addi	a1,s0,-24
    8000297e:	4501                	li	a0,0
    80002980:	e7fff0ef          	jal	800027fe <argaddr>
  return wait(p);
    80002984:	fe843503          	ld	a0,-24(s0)
    80002988:	fd8ff0ef          	jal	80002160 <wait>
}
    8000298c:	60e2                	ld	ra,24(sp)
    8000298e:	6442                	ld	s0,16(sp)
    80002990:	6105                	addi	sp,sp,32
    80002992:	8082                	ret

0000000080002994 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002994:	7179                	addi	sp,sp,-48
    80002996:	f406                	sd	ra,40(sp)
    80002998:	f022                	sd	s0,32(sp)
    8000299a:	ec26                	sd	s1,24(sp)
    8000299c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000299e:	fdc40593          	addi	a1,s0,-36
    800029a2:	4501                	li	a0,0
    800029a4:	e3fff0ef          	jal	800027e2 <argint>
  addr = myproc()->sz;
    800029a8:	f35fe0ef          	jal	800018dc <myproc>
    800029ac:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    800029ae:	fdc42503          	lw	a0,-36(s0)
    800029b2:	a54ff0ef          	jal	80001c06 <growproc>
    800029b6:	00054863          	bltz	a0,800029c6 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    800029ba:	8526                	mv	a0,s1
    800029bc:	70a2                	ld	ra,40(sp)
    800029be:	7402                	ld	s0,32(sp)
    800029c0:	64e2                	ld	s1,24(sp)
    800029c2:	6145                	addi	sp,sp,48
    800029c4:	8082                	ret
    return -1;
    800029c6:	54fd                	li	s1,-1
    800029c8:	bfcd                	j	800029ba <sys_sbrk+0x26>

00000000800029ca <sys_sleep>:

uint64
sys_sleep(void)
{
    800029ca:	7139                	addi	sp,sp,-64
    800029cc:	fc06                	sd	ra,56(sp)
    800029ce:	f822                	sd	s0,48(sp)
    800029d0:	f04a                	sd	s2,32(sp)
    800029d2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029d4:	fcc40593          	addi	a1,s0,-52
    800029d8:	4501                	li	a0,0
    800029da:	e09ff0ef          	jal	800027e2 <argint>
  if (n < 0)
    800029de:	fcc42783          	lw	a5,-52(s0)
    800029e2:	0607c763          	bltz	a5,80002a50 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    800029e6:	0001c517          	auipc	a0,0x1c
    800029ea:	9da50513          	addi	a0,a0,-1574 # 8001e3c0 <tickslock>
    800029ee:	a10fe0ef          	jal	80000bfe <acquire>
  ticks0 = ticks;
    800029f2:	00005917          	auipc	s2,0x5
    800029f6:	06e92903          	lw	s2,110(s2) # 80007a60 <ticks>
  while (ticks - ticks0 < n)
    800029fa:	fcc42783          	lw	a5,-52(s0)
    800029fe:	cf8d                	beqz	a5,80002a38 <sys_sleep+0x6e>
    80002a00:	f426                	sd	s1,40(sp)
    80002a02:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a04:	0001c997          	auipc	s3,0x1c
    80002a08:	9bc98993          	addi	s3,s3,-1604 # 8001e3c0 <tickslock>
    80002a0c:	00005497          	auipc	s1,0x5
    80002a10:	05448493          	addi	s1,s1,84 # 80007a60 <ticks>
    if (killed(myproc()))
    80002a14:	ec9fe0ef          	jal	800018dc <myproc>
    80002a18:	f1eff0ef          	jal	80002136 <killed>
    80002a1c:	ed0d                	bnez	a0,80002a56 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002a1e:	85ce                	mv	a1,s3
    80002a20:	8526                	mv	a0,s1
    80002a22:	cdcff0ef          	jal	80001efe <sleep>
  while (ticks - ticks0 < n)
    80002a26:	409c                	lw	a5,0(s1)
    80002a28:	412787bb          	subw	a5,a5,s2
    80002a2c:	fcc42703          	lw	a4,-52(s0)
    80002a30:	fee7e2e3          	bltu	a5,a4,80002a14 <sys_sleep+0x4a>
    80002a34:	74a2                	ld	s1,40(sp)
    80002a36:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a38:	0001c517          	auipc	a0,0x1c
    80002a3c:	98850513          	addi	a0,a0,-1656 # 8001e3c0 <tickslock>
    80002a40:	a52fe0ef          	jal	80000c92 <release>
  return 0;
    80002a44:	4501                	li	a0,0
}
    80002a46:	70e2                	ld	ra,56(sp)
    80002a48:	7442                	ld	s0,48(sp)
    80002a4a:	7902                	ld	s2,32(sp)
    80002a4c:	6121                	addi	sp,sp,64
    80002a4e:	8082                	ret
    n = 0;
    80002a50:	fc042623          	sw	zero,-52(s0)
    80002a54:	bf49                	j	800029e6 <sys_sleep+0x1c>
      release(&tickslock);
    80002a56:	0001c517          	auipc	a0,0x1c
    80002a5a:	96a50513          	addi	a0,a0,-1686 # 8001e3c0 <tickslock>
    80002a5e:	a34fe0ef          	jal	80000c92 <release>
      return -1;
    80002a62:	557d                	li	a0,-1
    80002a64:	74a2                	ld	s1,40(sp)
    80002a66:	69e2                	ld	s3,24(sp)
    80002a68:	bff9                	j	80002a46 <sys_sleep+0x7c>

0000000080002a6a <sys_kill>:

uint64
sys_kill(void)
{
    80002a6a:	1101                	addi	sp,sp,-32
    80002a6c:	ec06                	sd	ra,24(sp)
    80002a6e:	e822                	sd	s0,16(sp)
    80002a70:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a72:	fec40593          	addi	a1,s0,-20
    80002a76:	4501                	li	a0,0
    80002a78:	d6bff0ef          	jal	800027e2 <argint>
  return kill(pid);
    80002a7c:	fec42503          	lw	a0,-20(s0)
    80002a80:	e2cff0ef          	jal	800020ac <kill>
}
    80002a84:	60e2                	ld	ra,24(sp)
    80002a86:	6442                	ld	s0,16(sp)
    80002a88:	6105                	addi	sp,sp,32
    80002a8a:	8082                	ret

0000000080002a8c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a8c:	1101                	addi	sp,sp,-32
    80002a8e:	ec06                	sd	ra,24(sp)
    80002a90:	e822                	sd	s0,16(sp)
    80002a92:	e426                	sd	s1,8(sp)
    80002a94:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a96:	0001c517          	auipc	a0,0x1c
    80002a9a:	92a50513          	addi	a0,a0,-1750 # 8001e3c0 <tickslock>
    80002a9e:	960fe0ef          	jal	80000bfe <acquire>
  xticks = ticks;
    80002aa2:	00005497          	auipc	s1,0x5
    80002aa6:	fbe4a483          	lw	s1,-66(s1) # 80007a60 <ticks>
  release(&tickslock);
    80002aaa:	0001c517          	auipc	a0,0x1c
    80002aae:	91650513          	addi	a0,a0,-1770 # 8001e3c0 <tickslock>
    80002ab2:	9e0fe0ef          	jal	80000c92 <release>
  return xticks;
}
    80002ab6:	02049513          	slli	a0,s1,0x20
    80002aba:	9101                	srli	a0,a0,0x20
    80002abc:	60e2                	ld	ra,24(sp)
    80002abe:	6442                	ld	s0,16(sp)
    80002ac0:	64a2                	ld	s1,8(sp)
    80002ac2:	6105                	addi	sp,sp,32
    80002ac4:	8082                	ret

0000000080002ac6 <sys_history>:

uint64 sys_history()
{
    80002ac6:	7139                	addi	sp,sp,-64
    80002ac8:	fc06                	sd	ra,56(sp)
    80002aca:	f822                	sd	s0,48(sp)
    80002acc:	0080                	addi	s0,sp,64
  int syscall_num;
  uint64 stat_addr;
  argint(0, &syscall_num);
    80002ace:	fec40593          	addi	a1,s0,-20
    80002ad2:	4501                	li	a0,0
    80002ad4:	d0fff0ef          	jal	800027e2 <argint>
  argaddr(1, &stat_addr);
    80002ad8:	fe040593          	addi	a1,s0,-32
    80002adc:	4505                	li	a0,1
    80002ade:	d21ff0ef          	jal	800027fe <argaddr>
  struct proc *p = myproc();
    80002ae2:	dfbfe0ef          	jal	800018dc <myproc>
    80002ae6:	872a                	mv	a4,a0
  if (syscall_num < 1 || syscall_num > NSYSCALL)
    80002ae8:	fec42683          	lw	a3,-20(s0)
    80002aec:	fff6861b          	addiw	a2,a3,-1
    80002af0:	47d5                	li	a5,21
    return -1;
    80002af2:	557d                	li	a0,-1
  if (syscall_num < 1 || syscall_num > NSYSCALL)
    80002af4:	02c7ec63          	bltu	a5,a2,80002b2c <sys_history+0x66>
  struct syscall_stat stat = p->syscall_stats[syscall_num];
    80002af8:	00169793          	slli	a5,a3,0x1
    80002afc:	97b6                	add	a5,a5,a3
    80002afe:	078e                	slli	a5,a5,0x3
    80002b00:	97ba                	add	a5,a5,a4
    80002b02:	1687b683          	ld	a3,360(a5)
    80002b06:	fcd43423          	sd	a3,-56(s0)
    80002b0a:	1707b683          	ld	a3,368(a5)
    80002b0e:	fcd43823          	sd	a3,-48(s0)
    80002b12:	1787b783          	ld	a5,376(a5)
    80002b16:	fcf43c23          	sd	a5,-40(s0)
  if (copyout(p->pagetable, stat_addr, (char *)&stat, sizeof(struct syscall_stat)) < 0)
    80002b1a:	46e1                	li	a3,24
    80002b1c:	fc840613          	addi	a2,s0,-56
    80002b20:	fe043583          	ld	a1,-32(s0)
    80002b24:	6b28                	ld	a0,80(a4)
    80002b26:	a5ffe0ef          	jal	80001584 <copyout>
    80002b2a:	957d                	srai	a0,a0,0x3f
    return -1;
  return 0;
}
    80002b2c:	70e2                	ld	ra,56(sp)
    80002b2e:	7442                	ld	s0,48(sp)
    80002b30:	6121                	addi	sp,sp,64
    80002b32:	8082                	ret

0000000080002b34 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b34:	7179                	addi	sp,sp,-48
    80002b36:	f406                	sd	ra,40(sp)
    80002b38:	f022                	sd	s0,32(sp)
    80002b3a:	ec26                	sd	s1,24(sp)
    80002b3c:	e84a                	sd	s2,16(sp)
    80002b3e:	e44e                	sd	s3,8(sp)
    80002b40:	e052                	sd	s4,0(sp)
    80002b42:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b44:	00005597          	auipc	a1,0x5
    80002b48:	99458593          	addi	a1,a1,-1644 # 800074d8 <etext+0x4d8>
    80002b4c:	0001c517          	auipc	a0,0x1c
    80002b50:	88c50513          	addi	a0,a0,-1908 # 8001e3d8 <bcache>
    80002b54:	826fe0ef          	jal	80000b7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b58:	00024797          	auipc	a5,0x24
    80002b5c:	88078793          	addi	a5,a5,-1920 # 800263d8 <bcache+0x8000>
    80002b60:	00024717          	auipc	a4,0x24
    80002b64:	ae070713          	addi	a4,a4,-1312 # 80026640 <bcache+0x8268>
    80002b68:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b6c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b70:	0001c497          	auipc	s1,0x1c
    80002b74:	88048493          	addi	s1,s1,-1920 # 8001e3f0 <bcache+0x18>
    b->next = bcache.head.next;
    80002b78:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b7a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b7c:	00005a17          	auipc	s4,0x5
    80002b80:	964a0a13          	addi	s4,s4,-1692 # 800074e0 <etext+0x4e0>
    b->next = bcache.head.next;
    80002b84:	2b893783          	ld	a5,696(s2)
    80002b88:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b8a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b8e:	85d2                	mv	a1,s4
    80002b90:	01048513          	addi	a0,s1,16
    80002b94:	244010ef          	jal	80003dd8 <initsleeplock>
    bcache.head.next->prev = b;
    80002b98:	2b893783          	ld	a5,696(s2)
    80002b9c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b9e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ba2:	45848493          	addi	s1,s1,1112
    80002ba6:	fd349fe3          	bne	s1,s3,80002b84 <binit+0x50>
  }
}
    80002baa:	70a2                	ld	ra,40(sp)
    80002bac:	7402                	ld	s0,32(sp)
    80002bae:	64e2                	ld	s1,24(sp)
    80002bb0:	6942                	ld	s2,16(sp)
    80002bb2:	69a2                	ld	s3,8(sp)
    80002bb4:	6a02                	ld	s4,0(sp)
    80002bb6:	6145                	addi	sp,sp,48
    80002bb8:	8082                	ret

0000000080002bba <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002bba:	7179                	addi	sp,sp,-48
    80002bbc:	f406                	sd	ra,40(sp)
    80002bbe:	f022                	sd	s0,32(sp)
    80002bc0:	ec26                	sd	s1,24(sp)
    80002bc2:	e84a                	sd	s2,16(sp)
    80002bc4:	e44e                	sd	s3,8(sp)
    80002bc6:	1800                	addi	s0,sp,48
    80002bc8:	892a                	mv	s2,a0
    80002bca:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bcc:	0001c517          	auipc	a0,0x1c
    80002bd0:	80c50513          	addi	a0,a0,-2036 # 8001e3d8 <bcache>
    80002bd4:	82afe0ef          	jal	80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bd8:	00024497          	auipc	s1,0x24
    80002bdc:	ab84b483          	ld	s1,-1352(s1) # 80026690 <bcache+0x82b8>
    80002be0:	00024797          	auipc	a5,0x24
    80002be4:	a6078793          	addi	a5,a5,-1440 # 80026640 <bcache+0x8268>
    80002be8:	02f48b63          	beq	s1,a5,80002c1e <bread+0x64>
    80002bec:	873e                	mv	a4,a5
    80002bee:	a021                	j	80002bf6 <bread+0x3c>
    80002bf0:	68a4                	ld	s1,80(s1)
    80002bf2:	02e48663          	beq	s1,a4,80002c1e <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002bf6:	449c                	lw	a5,8(s1)
    80002bf8:	ff279ce3          	bne	a5,s2,80002bf0 <bread+0x36>
    80002bfc:	44dc                	lw	a5,12(s1)
    80002bfe:	ff3799e3          	bne	a5,s3,80002bf0 <bread+0x36>
      b->refcnt++;
    80002c02:	40bc                	lw	a5,64(s1)
    80002c04:	2785                	addiw	a5,a5,1
    80002c06:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c08:	0001b517          	auipc	a0,0x1b
    80002c0c:	7d050513          	addi	a0,a0,2000 # 8001e3d8 <bcache>
    80002c10:	882fe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002c14:	01048513          	addi	a0,s1,16
    80002c18:	1f6010ef          	jal	80003e0e <acquiresleep>
      return b;
    80002c1c:	a889                	j	80002c6e <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c1e:	00024497          	auipc	s1,0x24
    80002c22:	a6a4b483          	ld	s1,-1430(s1) # 80026688 <bcache+0x82b0>
    80002c26:	00024797          	auipc	a5,0x24
    80002c2a:	a1a78793          	addi	a5,a5,-1510 # 80026640 <bcache+0x8268>
    80002c2e:	00f48863          	beq	s1,a5,80002c3e <bread+0x84>
    80002c32:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c34:	40bc                	lw	a5,64(s1)
    80002c36:	cb91                	beqz	a5,80002c4a <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c38:	64a4                	ld	s1,72(s1)
    80002c3a:	fee49de3          	bne	s1,a4,80002c34 <bread+0x7a>
  panic("bget: no buffers");
    80002c3e:	00005517          	auipc	a0,0x5
    80002c42:	8aa50513          	addi	a0,a0,-1878 # 800074e8 <etext+0x4e8>
    80002c46:	b59fd0ef          	jal	8000079e <panic>
      b->dev = dev;
    80002c4a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c4e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c52:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c56:	4785                	li	a5,1
    80002c58:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c5a:	0001b517          	auipc	a0,0x1b
    80002c5e:	77e50513          	addi	a0,a0,1918 # 8001e3d8 <bcache>
    80002c62:	830fe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002c66:	01048513          	addi	a0,s1,16
    80002c6a:	1a4010ef          	jal	80003e0e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c6e:	409c                	lw	a5,0(s1)
    80002c70:	cb89                	beqz	a5,80002c82 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c72:	8526                	mv	a0,s1
    80002c74:	70a2                	ld	ra,40(sp)
    80002c76:	7402                	ld	s0,32(sp)
    80002c78:	64e2                	ld	s1,24(sp)
    80002c7a:	6942                	ld	s2,16(sp)
    80002c7c:	69a2                	ld	s3,8(sp)
    80002c7e:	6145                	addi	sp,sp,48
    80002c80:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c82:	4581                	li	a1,0
    80002c84:	8526                	mv	a0,s1
    80002c86:	1fb020ef          	jal	80005680 <virtio_disk_rw>
    b->valid = 1;
    80002c8a:	4785                	li	a5,1
    80002c8c:	c09c                	sw	a5,0(s1)
  return b;
    80002c8e:	b7d5                	j	80002c72 <bread+0xb8>

0000000080002c90 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c90:	1101                	addi	sp,sp,-32
    80002c92:	ec06                	sd	ra,24(sp)
    80002c94:	e822                	sd	s0,16(sp)
    80002c96:	e426                	sd	s1,8(sp)
    80002c98:	1000                	addi	s0,sp,32
    80002c9a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c9c:	0541                	addi	a0,a0,16
    80002c9e:	1ee010ef          	jal	80003e8c <holdingsleep>
    80002ca2:	c911                	beqz	a0,80002cb6 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002ca4:	4585                	li	a1,1
    80002ca6:	8526                	mv	a0,s1
    80002ca8:	1d9020ef          	jal	80005680 <virtio_disk_rw>
}
    80002cac:	60e2                	ld	ra,24(sp)
    80002cae:	6442                	ld	s0,16(sp)
    80002cb0:	64a2                	ld	s1,8(sp)
    80002cb2:	6105                	addi	sp,sp,32
    80002cb4:	8082                	ret
    panic("bwrite");
    80002cb6:	00005517          	auipc	a0,0x5
    80002cba:	84a50513          	addi	a0,a0,-1974 # 80007500 <etext+0x500>
    80002cbe:	ae1fd0ef          	jal	8000079e <panic>

0000000080002cc2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	e426                	sd	s1,8(sp)
    80002cca:	e04a                	sd	s2,0(sp)
    80002ccc:	1000                	addi	s0,sp,32
    80002cce:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cd0:	01050913          	addi	s2,a0,16
    80002cd4:	854a                	mv	a0,s2
    80002cd6:	1b6010ef          	jal	80003e8c <holdingsleep>
    80002cda:	c125                	beqz	a0,80002d3a <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002cdc:	854a                	mv	a0,s2
    80002cde:	176010ef          	jal	80003e54 <releasesleep>

  acquire(&bcache.lock);
    80002ce2:	0001b517          	auipc	a0,0x1b
    80002ce6:	6f650513          	addi	a0,a0,1782 # 8001e3d8 <bcache>
    80002cea:	f15fd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002cee:	40bc                	lw	a5,64(s1)
    80002cf0:	37fd                	addiw	a5,a5,-1
    80002cf2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002cf4:	e79d                	bnez	a5,80002d22 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cf6:	68b8                	ld	a4,80(s1)
    80002cf8:	64bc                	ld	a5,72(s1)
    80002cfa:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002cfc:	68b8                	ld	a4,80(s1)
    80002cfe:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d00:	00023797          	auipc	a5,0x23
    80002d04:	6d878793          	addi	a5,a5,1752 # 800263d8 <bcache+0x8000>
    80002d08:	2b87b703          	ld	a4,696(a5)
    80002d0c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d0e:	00024717          	auipc	a4,0x24
    80002d12:	93270713          	addi	a4,a4,-1742 # 80026640 <bcache+0x8268>
    80002d16:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d18:	2b87b703          	ld	a4,696(a5)
    80002d1c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d1e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d22:	0001b517          	auipc	a0,0x1b
    80002d26:	6b650513          	addi	a0,a0,1718 # 8001e3d8 <bcache>
    80002d2a:	f69fd0ef          	jal	80000c92 <release>
}
    80002d2e:	60e2                	ld	ra,24(sp)
    80002d30:	6442                	ld	s0,16(sp)
    80002d32:	64a2                	ld	s1,8(sp)
    80002d34:	6902                	ld	s2,0(sp)
    80002d36:	6105                	addi	sp,sp,32
    80002d38:	8082                	ret
    panic("brelse");
    80002d3a:	00004517          	auipc	a0,0x4
    80002d3e:	7ce50513          	addi	a0,a0,1998 # 80007508 <etext+0x508>
    80002d42:	a5dfd0ef          	jal	8000079e <panic>

0000000080002d46 <bpin>:

void
bpin(struct buf *b) {
    80002d46:	1101                	addi	sp,sp,-32
    80002d48:	ec06                	sd	ra,24(sp)
    80002d4a:	e822                	sd	s0,16(sp)
    80002d4c:	e426                	sd	s1,8(sp)
    80002d4e:	1000                	addi	s0,sp,32
    80002d50:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d52:	0001b517          	auipc	a0,0x1b
    80002d56:	68650513          	addi	a0,a0,1670 # 8001e3d8 <bcache>
    80002d5a:	ea5fd0ef          	jal	80000bfe <acquire>
  b->refcnt++;
    80002d5e:	40bc                	lw	a5,64(s1)
    80002d60:	2785                	addiw	a5,a5,1
    80002d62:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d64:	0001b517          	auipc	a0,0x1b
    80002d68:	67450513          	addi	a0,a0,1652 # 8001e3d8 <bcache>
    80002d6c:	f27fd0ef          	jal	80000c92 <release>
}
    80002d70:	60e2                	ld	ra,24(sp)
    80002d72:	6442                	ld	s0,16(sp)
    80002d74:	64a2                	ld	s1,8(sp)
    80002d76:	6105                	addi	sp,sp,32
    80002d78:	8082                	ret

0000000080002d7a <bunpin>:

void
bunpin(struct buf *b) {
    80002d7a:	1101                	addi	sp,sp,-32
    80002d7c:	ec06                	sd	ra,24(sp)
    80002d7e:	e822                	sd	s0,16(sp)
    80002d80:	e426                	sd	s1,8(sp)
    80002d82:	1000                	addi	s0,sp,32
    80002d84:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d86:	0001b517          	auipc	a0,0x1b
    80002d8a:	65250513          	addi	a0,a0,1618 # 8001e3d8 <bcache>
    80002d8e:	e71fd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002d92:	40bc                	lw	a5,64(s1)
    80002d94:	37fd                	addiw	a5,a5,-1
    80002d96:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d98:	0001b517          	auipc	a0,0x1b
    80002d9c:	64050513          	addi	a0,a0,1600 # 8001e3d8 <bcache>
    80002da0:	ef3fd0ef          	jal	80000c92 <release>
}
    80002da4:	60e2                	ld	ra,24(sp)
    80002da6:	6442                	ld	s0,16(sp)
    80002da8:	64a2                	ld	s1,8(sp)
    80002daa:	6105                	addi	sp,sp,32
    80002dac:	8082                	ret

0000000080002dae <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002dae:	1101                	addi	sp,sp,-32
    80002db0:	ec06                	sd	ra,24(sp)
    80002db2:	e822                	sd	s0,16(sp)
    80002db4:	e426                	sd	s1,8(sp)
    80002db6:	e04a                	sd	s2,0(sp)
    80002db8:	1000                	addi	s0,sp,32
    80002dba:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002dbc:	00d5d79b          	srliw	a5,a1,0xd
    80002dc0:	00024597          	auipc	a1,0x24
    80002dc4:	cf45a583          	lw	a1,-780(a1) # 80026ab4 <sb+0x1c>
    80002dc8:	9dbd                	addw	a1,a1,a5
    80002dca:	df1ff0ef          	jal	80002bba <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002dce:	0074f713          	andi	a4,s1,7
    80002dd2:	4785                	li	a5,1
    80002dd4:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002dd8:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002dda:	90d9                	srli	s1,s1,0x36
    80002ddc:	00950733          	add	a4,a0,s1
    80002de0:	05874703          	lbu	a4,88(a4)
    80002de4:	00e7f6b3          	and	a3,a5,a4
    80002de8:	c29d                	beqz	a3,80002e0e <bfree+0x60>
    80002dea:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002dec:	94aa                	add	s1,s1,a0
    80002dee:	fff7c793          	not	a5,a5
    80002df2:	8f7d                	and	a4,a4,a5
    80002df4:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002df8:	711000ef          	jal	80003d08 <log_write>
  brelse(bp);
    80002dfc:	854a                	mv	a0,s2
    80002dfe:	ec5ff0ef          	jal	80002cc2 <brelse>
}
    80002e02:	60e2                	ld	ra,24(sp)
    80002e04:	6442                	ld	s0,16(sp)
    80002e06:	64a2                	ld	s1,8(sp)
    80002e08:	6902                	ld	s2,0(sp)
    80002e0a:	6105                	addi	sp,sp,32
    80002e0c:	8082                	ret
    panic("freeing free block");
    80002e0e:	00004517          	auipc	a0,0x4
    80002e12:	70250513          	addi	a0,a0,1794 # 80007510 <etext+0x510>
    80002e16:	989fd0ef          	jal	8000079e <panic>

0000000080002e1a <balloc>:
{
    80002e1a:	715d                	addi	sp,sp,-80
    80002e1c:	e486                	sd	ra,72(sp)
    80002e1e:	e0a2                	sd	s0,64(sp)
    80002e20:	fc26                	sd	s1,56(sp)
    80002e22:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002e24:	00024797          	auipc	a5,0x24
    80002e28:	c787a783          	lw	a5,-904(a5) # 80026a9c <sb+0x4>
    80002e2c:	0e078863          	beqz	a5,80002f1c <balloc+0x102>
    80002e30:	f84a                	sd	s2,48(sp)
    80002e32:	f44e                	sd	s3,40(sp)
    80002e34:	f052                	sd	s4,32(sp)
    80002e36:	ec56                	sd	s5,24(sp)
    80002e38:	e85a                	sd	s6,16(sp)
    80002e3a:	e45e                	sd	s7,8(sp)
    80002e3c:	e062                	sd	s8,0(sp)
    80002e3e:	8baa                	mv	s7,a0
    80002e40:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e42:	00024b17          	auipc	s6,0x24
    80002e46:	c56b0b13          	addi	s6,s6,-938 # 80026a98 <sb>
      m = 1 << (bi % 8);
    80002e4a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e4c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e4e:	6c09                	lui	s8,0x2
    80002e50:	a09d                	j	80002eb6 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e52:	97ca                	add	a5,a5,s2
    80002e54:	8e55                	or	a2,a2,a3
    80002e56:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e5a:	854a                	mv	a0,s2
    80002e5c:	6ad000ef          	jal	80003d08 <log_write>
        brelse(bp);
    80002e60:	854a                	mv	a0,s2
    80002e62:	e61ff0ef          	jal	80002cc2 <brelse>
  bp = bread(dev, bno);
    80002e66:	85a6                	mv	a1,s1
    80002e68:	855e                	mv	a0,s7
    80002e6a:	d51ff0ef          	jal	80002bba <bread>
    80002e6e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e70:	40000613          	li	a2,1024
    80002e74:	4581                	li	a1,0
    80002e76:	05850513          	addi	a0,a0,88
    80002e7a:	e55fd0ef          	jal	80000cce <memset>
  log_write(bp);
    80002e7e:	854a                	mv	a0,s2
    80002e80:	689000ef          	jal	80003d08 <log_write>
  brelse(bp);
    80002e84:	854a                	mv	a0,s2
    80002e86:	e3dff0ef          	jal	80002cc2 <brelse>
}
    80002e8a:	7942                	ld	s2,48(sp)
    80002e8c:	79a2                	ld	s3,40(sp)
    80002e8e:	7a02                	ld	s4,32(sp)
    80002e90:	6ae2                	ld	s5,24(sp)
    80002e92:	6b42                	ld	s6,16(sp)
    80002e94:	6ba2                	ld	s7,8(sp)
    80002e96:	6c02                	ld	s8,0(sp)
}
    80002e98:	8526                	mv	a0,s1
    80002e9a:	60a6                	ld	ra,72(sp)
    80002e9c:	6406                	ld	s0,64(sp)
    80002e9e:	74e2                	ld	s1,56(sp)
    80002ea0:	6161                	addi	sp,sp,80
    80002ea2:	8082                	ret
    brelse(bp);
    80002ea4:	854a                	mv	a0,s2
    80002ea6:	e1dff0ef          	jal	80002cc2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002eaa:	015c0abb          	addw	s5,s8,s5
    80002eae:	004b2783          	lw	a5,4(s6)
    80002eb2:	04fafe63          	bgeu	s5,a5,80002f0e <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    80002eb6:	41fad79b          	sraiw	a5,s5,0x1f
    80002eba:	0137d79b          	srliw	a5,a5,0x13
    80002ebe:	015787bb          	addw	a5,a5,s5
    80002ec2:	40d7d79b          	sraiw	a5,a5,0xd
    80002ec6:	01cb2583          	lw	a1,28(s6)
    80002eca:	9dbd                	addw	a1,a1,a5
    80002ecc:	855e                	mv	a0,s7
    80002ece:	cedff0ef          	jal	80002bba <bread>
    80002ed2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ed4:	004b2503          	lw	a0,4(s6)
    80002ed8:	84d6                	mv	s1,s5
    80002eda:	4701                	li	a4,0
    80002edc:	fca4f4e3          	bgeu	s1,a0,80002ea4 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002ee0:	00777693          	andi	a3,a4,7
    80002ee4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002ee8:	41f7579b          	sraiw	a5,a4,0x1f
    80002eec:	01d7d79b          	srliw	a5,a5,0x1d
    80002ef0:	9fb9                	addw	a5,a5,a4
    80002ef2:	4037d79b          	sraiw	a5,a5,0x3
    80002ef6:	00f90633          	add	a2,s2,a5
    80002efa:	05864603          	lbu	a2,88(a2)
    80002efe:	00c6f5b3          	and	a1,a3,a2
    80002f02:	d9a1                	beqz	a1,80002e52 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f04:	2705                	addiw	a4,a4,1
    80002f06:	2485                	addiw	s1,s1,1
    80002f08:	fd471ae3          	bne	a4,s4,80002edc <balloc+0xc2>
    80002f0c:	bf61                	j	80002ea4 <balloc+0x8a>
    80002f0e:	7942                	ld	s2,48(sp)
    80002f10:	79a2                	ld	s3,40(sp)
    80002f12:	7a02                	ld	s4,32(sp)
    80002f14:	6ae2                	ld	s5,24(sp)
    80002f16:	6b42                	ld	s6,16(sp)
    80002f18:	6ba2                	ld	s7,8(sp)
    80002f1a:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002f1c:	00004517          	auipc	a0,0x4
    80002f20:	60c50513          	addi	a0,a0,1548 # 80007528 <etext+0x528>
    80002f24:	daafd0ef          	jal	800004ce <printf>
  return 0;
    80002f28:	4481                	li	s1,0
    80002f2a:	b7bd                	j	80002e98 <balloc+0x7e>

0000000080002f2c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f2c:	7179                	addi	sp,sp,-48
    80002f2e:	f406                	sd	ra,40(sp)
    80002f30:	f022                	sd	s0,32(sp)
    80002f32:	ec26                	sd	s1,24(sp)
    80002f34:	e84a                	sd	s2,16(sp)
    80002f36:	e44e                	sd	s3,8(sp)
    80002f38:	1800                	addi	s0,sp,48
    80002f3a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f3c:	47ad                	li	a5,11
    80002f3e:	02b7e363          	bltu	a5,a1,80002f64 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002f42:	02059793          	slli	a5,a1,0x20
    80002f46:	01e7d593          	srli	a1,a5,0x1e
    80002f4a:	00b504b3          	add	s1,a0,a1
    80002f4e:	0504a903          	lw	s2,80(s1)
    80002f52:	06091363          	bnez	s2,80002fb8 <bmap+0x8c>
      addr = balloc(ip->dev);
    80002f56:	4108                	lw	a0,0(a0)
    80002f58:	ec3ff0ef          	jal	80002e1a <balloc>
    80002f5c:	892a                	mv	s2,a0
      if(addr == 0)
    80002f5e:	cd29                	beqz	a0,80002fb8 <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    80002f60:	c8a8                	sw	a0,80(s1)
    80002f62:	a899                	j	80002fb8 <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f64:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80002f68:	0ff00793          	li	a5,255
    80002f6c:	0697e963          	bltu	a5,s1,80002fde <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f70:	08052903          	lw	s2,128(a0)
    80002f74:	00091b63          	bnez	s2,80002f8a <bmap+0x5e>
      addr = balloc(ip->dev);
    80002f78:	4108                	lw	a0,0(a0)
    80002f7a:	ea1ff0ef          	jal	80002e1a <balloc>
    80002f7e:	892a                	mv	s2,a0
      if(addr == 0)
    80002f80:	cd05                	beqz	a0,80002fb8 <bmap+0x8c>
    80002f82:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f84:	08a9a023          	sw	a0,128(s3)
    80002f88:	a011                	j	80002f8c <bmap+0x60>
    80002f8a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f8c:	85ca                	mv	a1,s2
    80002f8e:	0009a503          	lw	a0,0(s3)
    80002f92:	c29ff0ef          	jal	80002bba <bread>
    80002f96:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f98:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f9c:	02049713          	slli	a4,s1,0x20
    80002fa0:	01e75593          	srli	a1,a4,0x1e
    80002fa4:	00b784b3          	add	s1,a5,a1
    80002fa8:	0004a903          	lw	s2,0(s1)
    80002fac:	00090e63          	beqz	s2,80002fc8 <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fb0:	8552                	mv	a0,s4
    80002fb2:	d11ff0ef          	jal	80002cc2 <brelse>
    return addr;
    80002fb6:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fb8:	854a                	mv	a0,s2
    80002fba:	70a2                	ld	ra,40(sp)
    80002fbc:	7402                	ld	s0,32(sp)
    80002fbe:	64e2                	ld	s1,24(sp)
    80002fc0:	6942                	ld	s2,16(sp)
    80002fc2:	69a2                	ld	s3,8(sp)
    80002fc4:	6145                	addi	sp,sp,48
    80002fc6:	8082                	ret
      addr = balloc(ip->dev);
    80002fc8:	0009a503          	lw	a0,0(s3)
    80002fcc:	e4fff0ef          	jal	80002e1a <balloc>
    80002fd0:	892a                	mv	s2,a0
      if(addr){
    80002fd2:	dd79                	beqz	a0,80002fb0 <bmap+0x84>
        a[bn] = addr;
    80002fd4:	c088                	sw	a0,0(s1)
        log_write(bp);
    80002fd6:	8552                	mv	a0,s4
    80002fd8:	531000ef          	jal	80003d08 <log_write>
    80002fdc:	bfd1                	j	80002fb0 <bmap+0x84>
    80002fde:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002fe0:	00004517          	auipc	a0,0x4
    80002fe4:	56050513          	addi	a0,a0,1376 # 80007540 <etext+0x540>
    80002fe8:	fb6fd0ef          	jal	8000079e <panic>

0000000080002fec <iget>:
{
    80002fec:	7179                	addi	sp,sp,-48
    80002fee:	f406                	sd	ra,40(sp)
    80002ff0:	f022                	sd	s0,32(sp)
    80002ff2:	ec26                	sd	s1,24(sp)
    80002ff4:	e84a                	sd	s2,16(sp)
    80002ff6:	e44e                	sd	s3,8(sp)
    80002ff8:	e052                	sd	s4,0(sp)
    80002ffa:	1800                	addi	s0,sp,48
    80002ffc:	89aa                	mv	s3,a0
    80002ffe:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003000:	00024517          	auipc	a0,0x24
    80003004:	ab850513          	addi	a0,a0,-1352 # 80026ab8 <itable>
    80003008:	bf7fd0ef          	jal	80000bfe <acquire>
  empty = 0;
    8000300c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000300e:	00024497          	auipc	s1,0x24
    80003012:	ac248493          	addi	s1,s1,-1342 # 80026ad0 <itable+0x18>
    80003016:	00025697          	auipc	a3,0x25
    8000301a:	54a68693          	addi	a3,a3,1354 # 80028560 <log>
    8000301e:	a039                	j	8000302c <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003020:	02090963          	beqz	s2,80003052 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003024:	08848493          	addi	s1,s1,136
    80003028:	02d48863          	beq	s1,a3,80003058 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000302c:	449c                	lw	a5,8(s1)
    8000302e:	fef059e3          	blez	a5,80003020 <iget+0x34>
    80003032:	4098                	lw	a4,0(s1)
    80003034:	ff3716e3          	bne	a4,s3,80003020 <iget+0x34>
    80003038:	40d8                	lw	a4,4(s1)
    8000303a:	ff4713e3          	bne	a4,s4,80003020 <iget+0x34>
      ip->ref++;
    8000303e:	2785                	addiw	a5,a5,1
    80003040:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003042:	00024517          	auipc	a0,0x24
    80003046:	a7650513          	addi	a0,a0,-1418 # 80026ab8 <itable>
    8000304a:	c49fd0ef          	jal	80000c92 <release>
      return ip;
    8000304e:	8926                	mv	s2,s1
    80003050:	a02d                	j	8000307a <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003052:	fbe9                	bnez	a5,80003024 <iget+0x38>
      empty = ip;
    80003054:	8926                	mv	s2,s1
    80003056:	b7f9                	j	80003024 <iget+0x38>
  if(empty == 0)
    80003058:	02090a63          	beqz	s2,8000308c <iget+0xa0>
  ip->dev = dev;
    8000305c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003060:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003064:	4785                	li	a5,1
    80003066:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000306a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000306e:	00024517          	auipc	a0,0x24
    80003072:	a4a50513          	addi	a0,a0,-1462 # 80026ab8 <itable>
    80003076:	c1dfd0ef          	jal	80000c92 <release>
}
    8000307a:	854a                	mv	a0,s2
    8000307c:	70a2                	ld	ra,40(sp)
    8000307e:	7402                	ld	s0,32(sp)
    80003080:	64e2                	ld	s1,24(sp)
    80003082:	6942                	ld	s2,16(sp)
    80003084:	69a2                	ld	s3,8(sp)
    80003086:	6a02                	ld	s4,0(sp)
    80003088:	6145                	addi	sp,sp,48
    8000308a:	8082                	ret
    panic("iget: no inodes");
    8000308c:	00004517          	auipc	a0,0x4
    80003090:	4cc50513          	addi	a0,a0,1228 # 80007558 <etext+0x558>
    80003094:	f0afd0ef          	jal	8000079e <panic>

0000000080003098 <fsinit>:
fsinit(int dev) {
    80003098:	7179                	addi	sp,sp,-48
    8000309a:	f406                	sd	ra,40(sp)
    8000309c:	f022                	sd	s0,32(sp)
    8000309e:	ec26                	sd	s1,24(sp)
    800030a0:	e84a                	sd	s2,16(sp)
    800030a2:	e44e                	sd	s3,8(sp)
    800030a4:	1800                	addi	s0,sp,48
    800030a6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800030a8:	4585                	li	a1,1
    800030aa:	b11ff0ef          	jal	80002bba <bread>
    800030ae:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800030b0:	00024997          	auipc	s3,0x24
    800030b4:	9e898993          	addi	s3,s3,-1560 # 80026a98 <sb>
    800030b8:	02000613          	li	a2,32
    800030bc:	05850593          	addi	a1,a0,88
    800030c0:	854e                	mv	a0,s3
    800030c2:	c71fd0ef          	jal	80000d32 <memmove>
  brelse(bp);
    800030c6:	8526                	mv	a0,s1
    800030c8:	bfbff0ef          	jal	80002cc2 <brelse>
  if(sb.magic != FSMAGIC)
    800030cc:	0009a703          	lw	a4,0(s3)
    800030d0:	102037b7          	lui	a5,0x10203
    800030d4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800030d8:	02f71063          	bne	a4,a5,800030f8 <fsinit+0x60>
  initlog(dev, &sb);
    800030dc:	00024597          	auipc	a1,0x24
    800030e0:	9bc58593          	addi	a1,a1,-1604 # 80026a98 <sb>
    800030e4:	854a                	mv	a0,s2
    800030e6:	215000ef          	jal	80003afa <initlog>
}
    800030ea:	70a2                	ld	ra,40(sp)
    800030ec:	7402                	ld	s0,32(sp)
    800030ee:	64e2                	ld	s1,24(sp)
    800030f0:	6942                	ld	s2,16(sp)
    800030f2:	69a2                	ld	s3,8(sp)
    800030f4:	6145                	addi	sp,sp,48
    800030f6:	8082                	ret
    panic("invalid file system");
    800030f8:	00004517          	auipc	a0,0x4
    800030fc:	47050513          	addi	a0,a0,1136 # 80007568 <etext+0x568>
    80003100:	e9efd0ef          	jal	8000079e <panic>

0000000080003104 <iinit>:
{
    80003104:	7179                	addi	sp,sp,-48
    80003106:	f406                	sd	ra,40(sp)
    80003108:	f022                	sd	s0,32(sp)
    8000310a:	ec26                	sd	s1,24(sp)
    8000310c:	e84a                	sd	s2,16(sp)
    8000310e:	e44e                	sd	s3,8(sp)
    80003110:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003112:	00004597          	auipc	a1,0x4
    80003116:	46e58593          	addi	a1,a1,1134 # 80007580 <etext+0x580>
    8000311a:	00024517          	auipc	a0,0x24
    8000311e:	99e50513          	addi	a0,a0,-1634 # 80026ab8 <itable>
    80003122:	a59fd0ef          	jal	80000b7a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003126:	00024497          	auipc	s1,0x24
    8000312a:	9ba48493          	addi	s1,s1,-1606 # 80026ae0 <itable+0x28>
    8000312e:	00025997          	auipc	s3,0x25
    80003132:	44298993          	addi	s3,s3,1090 # 80028570 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003136:	00004917          	auipc	s2,0x4
    8000313a:	45290913          	addi	s2,s2,1106 # 80007588 <etext+0x588>
    8000313e:	85ca                	mv	a1,s2
    80003140:	8526                	mv	a0,s1
    80003142:	497000ef          	jal	80003dd8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003146:	08848493          	addi	s1,s1,136
    8000314a:	ff349ae3          	bne	s1,s3,8000313e <iinit+0x3a>
}
    8000314e:	70a2                	ld	ra,40(sp)
    80003150:	7402                	ld	s0,32(sp)
    80003152:	64e2                	ld	s1,24(sp)
    80003154:	6942                	ld	s2,16(sp)
    80003156:	69a2                	ld	s3,8(sp)
    80003158:	6145                	addi	sp,sp,48
    8000315a:	8082                	ret

000000008000315c <ialloc>:
{
    8000315c:	7139                	addi	sp,sp,-64
    8000315e:	fc06                	sd	ra,56(sp)
    80003160:	f822                	sd	s0,48(sp)
    80003162:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003164:	00024717          	auipc	a4,0x24
    80003168:	94072703          	lw	a4,-1728(a4) # 80026aa4 <sb+0xc>
    8000316c:	4785                	li	a5,1
    8000316e:	06e7f063          	bgeu	a5,a4,800031ce <ialloc+0x72>
    80003172:	f426                	sd	s1,40(sp)
    80003174:	f04a                	sd	s2,32(sp)
    80003176:	ec4e                	sd	s3,24(sp)
    80003178:	e852                	sd	s4,16(sp)
    8000317a:	e456                	sd	s5,8(sp)
    8000317c:	e05a                	sd	s6,0(sp)
    8000317e:	8aaa                	mv	s5,a0
    80003180:	8b2e                	mv	s6,a1
    80003182:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003184:	00024a17          	auipc	s4,0x24
    80003188:	914a0a13          	addi	s4,s4,-1772 # 80026a98 <sb>
    8000318c:	00495593          	srli	a1,s2,0x4
    80003190:	018a2783          	lw	a5,24(s4)
    80003194:	9dbd                	addw	a1,a1,a5
    80003196:	8556                	mv	a0,s5
    80003198:	a23ff0ef          	jal	80002bba <bread>
    8000319c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000319e:	05850993          	addi	s3,a0,88
    800031a2:	00f97793          	andi	a5,s2,15
    800031a6:	079a                	slli	a5,a5,0x6
    800031a8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800031aa:	00099783          	lh	a5,0(s3)
    800031ae:	cb9d                	beqz	a5,800031e4 <ialloc+0x88>
    brelse(bp);
    800031b0:	b13ff0ef          	jal	80002cc2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800031b4:	0905                	addi	s2,s2,1
    800031b6:	00ca2703          	lw	a4,12(s4)
    800031ba:	0009079b          	sext.w	a5,s2
    800031be:	fce7e7e3          	bltu	a5,a4,8000318c <ialloc+0x30>
    800031c2:	74a2                	ld	s1,40(sp)
    800031c4:	7902                	ld	s2,32(sp)
    800031c6:	69e2                	ld	s3,24(sp)
    800031c8:	6a42                	ld	s4,16(sp)
    800031ca:	6aa2                	ld	s5,8(sp)
    800031cc:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800031ce:	00004517          	auipc	a0,0x4
    800031d2:	3c250513          	addi	a0,a0,962 # 80007590 <etext+0x590>
    800031d6:	af8fd0ef          	jal	800004ce <printf>
  return 0;
    800031da:	4501                	li	a0,0
}
    800031dc:	70e2                	ld	ra,56(sp)
    800031de:	7442                	ld	s0,48(sp)
    800031e0:	6121                	addi	sp,sp,64
    800031e2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031e4:	04000613          	li	a2,64
    800031e8:	4581                	li	a1,0
    800031ea:	854e                	mv	a0,s3
    800031ec:	ae3fd0ef          	jal	80000cce <memset>
      dip->type = type;
    800031f0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800031f4:	8526                	mv	a0,s1
    800031f6:	313000ef          	jal	80003d08 <log_write>
      brelse(bp);
    800031fa:	8526                	mv	a0,s1
    800031fc:	ac7ff0ef          	jal	80002cc2 <brelse>
      return iget(dev, inum);
    80003200:	0009059b          	sext.w	a1,s2
    80003204:	8556                	mv	a0,s5
    80003206:	de7ff0ef          	jal	80002fec <iget>
    8000320a:	74a2                	ld	s1,40(sp)
    8000320c:	7902                	ld	s2,32(sp)
    8000320e:	69e2                	ld	s3,24(sp)
    80003210:	6a42                	ld	s4,16(sp)
    80003212:	6aa2                	ld	s5,8(sp)
    80003214:	6b02                	ld	s6,0(sp)
    80003216:	b7d9                	j	800031dc <ialloc+0x80>

0000000080003218 <iupdate>:
{
    80003218:	1101                	addi	sp,sp,-32
    8000321a:	ec06                	sd	ra,24(sp)
    8000321c:	e822                	sd	s0,16(sp)
    8000321e:	e426                	sd	s1,8(sp)
    80003220:	e04a                	sd	s2,0(sp)
    80003222:	1000                	addi	s0,sp,32
    80003224:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003226:	415c                	lw	a5,4(a0)
    80003228:	0047d79b          	srliw	a5,a5,0x4
    8000322c:	00024597          	auipc	a1,0x24
    80003230:	8845a583          	lw	a1,-1916(a1) # 80026ab0 <sb+0x18>
    80003234:	9dbd                	addw	a1,a1,a5
    80003236:	4108                	lw	a0,0(a0)
    80003238:	983ff0ef          	jal	80002bba <bread>
    8000323c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000323e:	05850793          	addi	a5,a0,88
    80003242:	40d8                	lw	a4,4(s1)
    80003244:	8b3d                	andi	a4,a4,15
    80003246:	071a                	slli	a4,a4,0x6
    80003248:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000324a:	04449703          	lh	a4,68(s1)
    8000324e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003252:	04649703          	lh	a4,70(s1)
    80003256:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000325a:	04849703          	lh	a4,72(s1)
    8000325e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003262:	04a49703          	lh	a4,74(s1)
    80003266:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000326a:	44f8                	lw	a4,76(s1)
    8000326c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000326e:	03400613          	li	a2,52
    80003272:	05048593          	addi	a1,s1,80
    80003276:	00c78513          	addi	a0,a5,12
    8000327a:	ab9fd0ef          	jal	80000d32 <memmove>
  log_write(bp);
    8000327e:	854a                	mv	a0,s2
    80003280:	289000ef          	jal	80003d08 <log_write>
  brelse(bp);
    80003284:	854a                	mv	a0,s2
    80003286:	a3dff0ef          	jal	80002cc2 <brelse>
}
    8000328a:	60e2                	ld	ra,24(sp)
    8000328c:	6442                	ld	s0,16(sp)
    8000328e:	64a2                	ld	s1,8(sp)
    80003290:	6902                	ld	s2,0(sp)
    80003292:	6105                	addi	sp,sp,32
    80003294:	8082                	ret

0000000080003296 <idup>:
{
    80003296:	1101                	addi	sp,sp,-32
    80003298:	ec06                	sd	ra,24(sp)
    8000329a:	e822                	sd	s0,16(sp)
    8000329c:	e426                	sd	s1,8(sp)
    8000329e:	1000                	addi	s0,sp,32
    800032a0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032a2:	00024517          	auipc	a0,0x24
    800032a6:	81650513          	addi	a0,a0,-2026 # 80026ab8 <itable>
    800032aa:	955fd0ef          	jal	80000bfe <acquire>
  ip->ref++;
    800032ae:	449c                	lw	a5,8(s1)
    800032b0:	2785                	addiw	a5,a5,1
    800032b2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032b4:	00024517          	auipc	a0,0x24
    800032b8:	80450513          	addi	a0,a0,-2044 # 80026ab8 <itable>
    800032bc:	9d7fd0ef          	jal	80000c92 <release>
}
    800032c0:	8526                	mv	a0,s1
    800032c2:	60e2                	ld	ra,24(sp)
    800032c4:	6442                	ld	s0,16(sp)
    800032c6:	64a2                	ld	s1,8(sp)
    800032c8:	6105                	addi	sp,sp,32
    800032ca:	8082                	ret

00000000800032cc <ilock>:
{
    800032cc:	1101                	addi	sp,sp,-32
    800032ce:	ec06                	sd	ra,24(sp)
    800032d0:	e822                	sd	s0,16(sp)
    800032d2:	e426                	sd	s1,8(sp)
    800032d4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032d6:	cd19                	beqz	a0,800032f4 <ilock+0x28>
    800032d8:	84aa                	mv	s1,a0
    800032da:	451c                	lw	a5,8(a0)
    800032dc:	00f05c63          	blez	a5,800032f4 <ilock+0x28>
  acquiresleep(&ip->lock);
    800032e0:	0541                	addi	a0,a0,16
    800032e2:	32d000ef          	jal	80003e0e <acquiresleep>
  if(ip->valid == 0){
    800032e6:	40bc                	lw	a5,64(s1)
    800032e8:	cf89                	beqz	a5,80003302 <ilock+0x36>
}
    800032ea:	60e2                	ld	ra,24(sp)
    800032ec:	6442                	ld	s0,16(sp)
    800032ee:	64a2                	ld	s1,8(sp)
    800032f0:	6105                	addi	sp,sp,32
    800032f2:	8082                	ret
    800032f4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032f6:	00004517          	auipc	a0,0x4
    800032fa:	2b250513          	addi	a0,a0,690 # 800075a8 <etext+0x5a8>
    800032fe:	ca0fd0ef          	jal	8000079e <panic>
    80003302:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003304:	40dc                	lw	a5,4(s1)
    80003306:	0047d79b          	srliw	a5,a5,0x4
    8000330a:	00023597          	auipc	a1,0x23
    8000330e:	7a65a583          	lw	a1,1958(a1) # 80026ab0 <sb+0x18>
    80003312:	9dbd                	addw	a1,a1,a5
    80003314:	4088                	lw	a0,0(s1)
    80003316:	8a5ff0ef          	jal	80002bba <bread>
    8000331a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000331c:	05850593          	addi	a1,a0,88
    80003320:	40dc                	lw	a5,4(s1)
    80003322:	8bbd                	andi	a5,a5,15
    80003324:	079a                	slli	a5,a5,0x6
    80003326:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003328:	00059783          	lh	a5,0(a1)
    8000332c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003330:	00259783          	lh	a5,2(a1)
    80003334:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003338:	00459783          	lh	a5,4(a1)
    8000333c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003340:	00659783          	lh	a5,6(a1)
    80003344:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003348:	459c                	lw	a5,8(a1)
    8000334a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000334c:	03400613          	li	a2,52
    80003350:	05b1                	addi	a1,a1,12
    80003352:	05048513          	addi	a0,s1,80
    80003356:	9ddfd0ef          	jal	80000d32 <memmove>
    brelse(bp);
    8000335a:	854a                	mv	a0,s2
    8000335c:	967ff0ef          	jal	80002cc2 <brelse>
    ip->valid = 1;
    80003360:	4785                	li	a5,1
    80003362:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003364:	04449783          	lh	a5,68(s1)
    80003368:	c399                	beqz	a5,8000336e <ilock+0xa2>
    8000336a:	6902                	ld	s2,0(sp)
    8000336c:	bfbd                	j	800032ea <ilock+0x1e>
      panic("ilock: no type");
    8000336e:	00004517          	auipc	a0,0x4
    80003372:	24250513          	addi	a0,a0,578 # 800075b0 <etext+0x5b0>
    80003376:	c28fd0ef          	jal	8000079e <panic>

000000008000337a <iunlock>:
{
    8000337a:	1101                	addi	sp,sp,-32
    8000337c:	ec06                	sd	ra,24(sp)
    8000337e:	e822                	sd	s0,16(sp)
    80003380:	e426                	sd	s1,8(sp)
    80003382:	e04a                	sd	s2,0(sp)
    80003384:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003386:	c505                	beqz	a0,800033ae <iunlock+0x34>
    80003388:	84aa                	mv	s1,a0
    8000338a:	01050913          	addi	s2,a0,16
    8000338e:	854a                	mv	a0,s2
    80003390:	2fd000ef          	jal	80003e8c <holdingsleep>
    80003394:	cd09                	beqz	a0,800033ae <iunlock+0x34>
    80003396:	449c                	lw	a5,8(s1)
    80003398:	00f05b63          	blez	a5,800033ae <iunlock+0x34>
  releasesleep(&ip->lock);
    8000339c:	854a                	mv	a0,s2
    8000339e:	2b7000ef          	jal	80003e54 <releasesleep>
}
    800033a2:	60e2                	ld	ra,24(sp)
    800033a4:	6442                	ld	s0,16(sp)
    800033a6:	64a2                	ld	s1,8(sp)
    800033a8:	6902                	ld	s2,0(sp)
    800033aa:	6105                	addi	sp,sp,32
    800033ac:	8082                	ret
    panic("iunlock");
    800033ae:	00004517          	auipc	a0,0x4
    800033b2:	21250513          	addi	a0,a0,530 # 800075c0 <etext+0x5c0>
    800033b6:	be8fd0ef          	jal	8000079e <panic>

00000000800033ba <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033ba:	7179                	addi	sp,sp,-48
    800033bc:	f406                	sd	ra,40(sp)
    800033be:	f022                	sd	s0,32(sp)
    800033c0:	ec26                	sd	s1,24(sp)
    800033c2:	e84a                	sd	s2,16(sp)
    800033c4:	e44e                	sd	s3,8(sp)
    800033c6:	1800                	addi	s0,sp,48
    800033c8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033ca:	05050493          	addi	s1,a0,80
    800033ce:	08050913          	addi	s2,a0,128
    800033d2:	a021                	j	800033da <itrunc+0x20>
    800033d4:	0491                	addi	s1,s1,4
    800033d6:	01248b63          	beq	s1,s2,800033ec <itrunc+0x32>
    if(ip->addrs[i]){
    800033da:	408c                	lw	a1,0(s1)
    800033dc:	dde5                	beqz	a1,800033d4 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033de:	0009a503          	lw	a0,0(s3)
    800033e2:	9cdff0ef          	jal	80002dae <bfree>
      ip->addrs[i] = 0;
    800033e6:	0004a023          	sw	zero,0(s1)
    800033ea:	b7ed                	j	800033d4 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800033ec:	0809a583          	lw	a1,128(s3)
    800033f0:	ed89                	bnez	a1,8000340a <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033f2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033f6:	854e                	mv	a0,s3
    800033f8:	e21ff0ef          	jal	80003218 <iupdate>
}
    800033fc:	70a2                	ld	ra,40(sp)
    800033fe:	7402                	ld	s0,32(sp)
    80003400:	64e2                	ld	s1,24(sp)
    80003402:	6942                	ld	s2,16(sp)
    80003404:	69a2                	ld	s3,8(sp)
    80003406:	6145                	addi	sp,sp,48
    80003408:	8082                	ret
    8000340a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000340c:	0009a503          	lw	a0,0(s3)
    80003410:	faaff0ef          	jal	80002bba <bread>
    80003414:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003416:	05850493          	addi	s1,a0,88
    8000341a:	45850913          	addi	s2,a0,1112
    8000341e:	a021                	j	80003426 <itrunc+0x6c>
    80003420:	0491                	addi	s1,s1,4
    80003422:	01248963          	beq	s1,s2,80003434 <itrunc+0x7a>
      if(a[j])
    80003426:	408c                	lw	a1,0(s1)
    80003428:	dde5                	beqz	a1,80003420 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000342a:	0009a503          	lw	a0,0(s3)
    8000342e:	981ff0ef          	jal	80002dae <bfree>
    80003432:	b7fd                	j	80003420 <itrunc+0x66>
    brelse(bp);
    80003434:	8552                	mv	a0,s4
    80003436:	88dff0ef          	jal	80002cc2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000343a:	0809a583          	lw	a1,128(s3)
    8000343e:	0009a503          	lw	a0,0(s3)
    80003442:	96dff0ef          	jal	80002dae <bfree>
    ip->addrs[NDIRECT] = 0;
    80003446:	0809a023          	sw	zero,128(s3)
    8000344a:	6a02                	ld	s4,0(sp)
    8000344c:	b75d                	j	800033f2 <itrunc+0x38>

000000008000344e <iput>:
{
    8000344e:	1101                	addi	sp,sp,-32
    80003450:	ec06                	sd	ra,24(sp)
    80003452:	e822                	sd	s0,16(sp)
    80003454:	e426                	sd	s1,8(sp)
    80003456:	1000                	addi	s0,sp,32
    80003458:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000345a:	00023517          	auipc	a0,0x23
    8000345e:	65e50513          	addi	a0,a0,1630 # 80026ab8 <itable>
    80003462:	f9cfd0ef          	jal	80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003466:	4498                	lw	a4,8(s1)
    80003468:	4785                	li	a5,1
    8000346a:	02f70063          	beq	a4,a5,8000348a <iput+0x3c>
  ip->ref--;
    8000346e:	449c                	lw	a5,8(s1)
    80003470:	37fd                	addiw	a5,a5,-1
    80003472:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003474:	00023517          	auipc	a0,0x23
    80003478:	64450513          	addi	a0,a0,1604 # 80026ab8 <itable>
    8000347c:	817fd0ef          	jal	80000c92 <release>
}
    80003480:	60e2                	ld	ra,24(sp)
    80003482:	6442                	ld	s0,16(sp)
    80003484:	64a2                	ld	s1,8(sp)
    80003486:	6105                	addi	sp,sp,32
    80003488:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000348a:	40bc                	lw	a5,64(s1)
    8000348c:	d3ed                	beqz	a5,8000346e <iput+0x20>
    8000348e:	04a49783          	lh	a5,74(s1)
    80003492:	fff1                	bnez	a5,8000346e <iput+0x20>
    80003494:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003496:	01048913          	addi	s2,s1,16
    8000349a:	854a                	mv	a0,s2
    8000349c:	173000ef          	jal	80003e0e <acquiresleep>
    release(&itable.lock);
    800034a0:	00023517          	auipc	a0,0x23
    800034a4:	61850513          	addi	a0,a0,1560 # 80026ab8 <itable>
    800034a8:	feafd0ef          	jal	80000c92 <release>
    itrunc(ip);
    800034ac:	8526                	mv	a0,s1
    800034ae:	f0dff0ef          	jal	800033ba <itrunc>
    ip->type = 0;
    800034b2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800034b6:	8526                	mv	a0,s1
    800034b8:	d61ff0ef          	jal	80003218 <iupdate>
    ip->valid = 0;
    800034bc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034c0:	854a                	mv	a0,s2
    800034c2:	193000ef          	jal	80003e54 <releasesleep>
    acquire(&itable.lock);
    800034c6:	00023517          	auipc	a0,0x23
    800034ca:	5f250513          	addi	a0,a0,1522 # 80026ab8 <itable>
    800034ce:	f30fd0ef          	jal	80000bfe <acquire>
    800034d2:	6902                	ld	s2,0(sp)
    800034d4:	bf69                	j	8000346e <iput+0x20>

00000000800034d6 <iunlockput>:
{
    800034d6:	1101                	addi	sp,sp,-32
    800034d8:	ec06                	sd	ra,24(sp)
    800034da:	e822                	sd	s0,16(sp)
    800034dc:	e426                	sd	s1,8(sp)
    800034de:	1000                	addi	s0,sp,32
    800034e0:	84aa                	mv	s1,a0
  iunlock(ip);
    800034e2:	e99ff0ef          	jal	8000337a <iunlock>
  iput(ip);
    800034e6:	8526                	mv	a0,s1
    800034e8:	f67ff0ef          	jal	8000344e <iput>
}
    800034ec:	60e2                	ld	ra,24(sp)
    800034ee:	6442                	ld	s0,16(sp)
    800034f0:	64a2                	ld	s1,8(sp)
    800034f2:	6105                	addi	sp,sp,32
    800034f4:	8082                	ret

00000000800034f6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800034f6:	1141                	addi	sp,sp,-16
    800034f8:	e406                	sd	ra,8(sp)
    800034fa:	e022                	sd	s0,0(sp)
    800034fc:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800034fe:	411c                	lw	a5,0(a0)
    80003500:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003502:	415c                	lw	a5,4(a0)
    80003504:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003506:	04451783          	lh	a5,68(a0)
    8000350a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000350e:	04a51783          	lh	a5,74(a0)
    80003512:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003516:	04c56783          	lwu	a5,76(a0)
    8000351a:	e99c                	sd	a5,16(a1)
}
    8000351c:	60a2                	ld	ra,8(sp)
    8000351e:	6402                	ld	s0,0(sp)
    80003520:	0141                	addi	sp,sp,16
    80003522:	8082                	ret

0000000080003524 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003524:	457c                	lw	a5,76(a0)
    80003526:	0ed7e663          	bltu	a5,a3,80003612 <readi+0xee>
{
    8000352a:	7159                	addi	sp,sp,-112
    8000352c:	f486                	sd	ra,104(sp)
    8000352e:	f0a2                	sd	s0,96(sp)
    80003530:	eca6                	sd	s1,88(sp)
    80003532:	e0d2                	sd	s4,64(sp)
    80003534:	fc56                	sd	s5,56(sp)
    80003536:	f85a                	sd	s6,48(sp)
    80003538:	f45e                	sd	s7,40(sp)
    8000353a:	1880                	addi	s0,sp,112
    8000353c:	8b2a                	mv	s6,a0
    8000353e:	8bae                	mv	s7,a1
    80003540:	8a32                	mv	s4,a2
    80003542:	84b6                	mv	s1,a3
    80003544:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003546:	9f35                	addw	a4,a4,a3
    return 0;
    80003548:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000354a:	0ad76b63          	bltu	a4,a3,80003600 <readi+0xdc>
    8000354e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003550:	00e7f463          	bgeu	a5,a4,80003558 <readi+0x34>
    n = ip->size - off;
    80003554:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003558:	080a8b63          	beqz	s5,800035ee <readi+0xca>
    8000355c:	e8ca                	sd	s2,80(sp)
    8000355e:	f062                	sd	s8,32(sp)
    80003560:	ec66                	sd	s9,24(sp)
    80003562:	e86a                	sd	s10,16(sp)
    80003564:	e46e                	sd	s11,8(sp)
    80003566:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003568:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000356c:	5c7d                	li	s8,-1
    8000356e:	a80d                	j	800035a0 <readi+0x7c>
    80003570:	020d1d93          	slli	s11,s10,0x20
    80003574:	020ddd93          	srli	s11,s11,0x20
    80003578:	05890613          	addi	a2,s2,88
    8000357c:	86ee                	mv	a3,s11
    8000357e:	963e                	add	a2,a2,a5
    80003580:	85d2                	mv	a1,s4
    80003582:	855e                	mv	a0,s7
    80003584:	cd1fe0ef          	jal	80002254 <either_copyout>
    80003588:	05850363          	beq	a0,s8,800035ce <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000358c:	854a                	mv	a0,s2
    8000358e:	f34ff0ef          	jal	80002cc2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003592:	013d09bb          	addw	s3,s10,s3
    80003596:	009d04bb          	addw	s1,s10,s1
    8000359a:	9a6e                	add	s4,s4,s11
    8000359c:	0559f363          	bgeu	s3,s5,800035e2 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800035a0:	00a4d59b          	srliw	a1,s1,0xa
    800035a4:	855a                	mv	a0,s6
    800035a6:	987ff0ef          	jal	80002f2c <bmap>
    800035aa:	85aa                	mv	a1,a0
    if(addr == 0)
    800035ac:	c139                	beqz	a0,800035f2 <readi+0xce>
    bp = bread(ip->dev, addr);
    800035ae:	000b2503          	lw	a0,0(s6)
    800035b2:	e08ff0ef          	jal	80002bba <bread>
    800035b6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035b8:	3ff4f793          	andi	a5,s1,1023
    800035bc:	40fc873b          	subw	a4,s9,a5
    800035c0:	413a86bb          	subw	a3,s5,s3
    800035c4:	8d3a                	mv	s10,a4
    800035c6:	fae6f5e3          	bgeu	a3,a4,80003570 <readi+0x4c>
    800035ca:	8d36                	mv	s10,a3
    800035cc:	b755                	j	80003570 <readi+0x4c>
      brelse(bp);
    800035ce:	854a                	mv	a0,s2
    800035d0:	ef2ff0ef          	jal	80002cc2 <brelse>
      tot = -1;
    800035d4:	59fd                	li	s3,-1
      break;
    800035d6:	6946                	ld	s2,80(sp)
    800035d8:	7c02                	ld	s8,32(sp)
    800035da:	6ce2                	ld	s9,24(sp)
    800035dc:	6d42                	ld	s10,16(sp)
    800035de:	6da2                	ld	s11,8(sp)
    800035e0:	a831                	j	800035fc <readi+0xd8>
    800035e2:	6946                	ld	s2,80(sp)
    800035e4:	7c02                	ld	s8,32(sp)
    800035e6:	6ce2                	ld	s9,24(sp)
    800035e8:	6d42                	ld	s10,16(sp)
    800035ea:	6da2                	ld	s11,8(sp)
    800035ec:	a801                	j	800035fc <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035ee:	89d6                	mv	s3,s5
    800035f0:	a031                	j	800035fc <readi+0xd8>
    800035f2:	6946                	ld	s2,80(sp)
    800035f4:	7c02                	ld	s8,32(sp)
    800035f6:	6ce2                	ld	s9,24(sp)
    800035f8:	6d42                	ld	s10,16(sp)
    800035fa:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800035fc:	854e                	mv	a0,s3
    800035fe:	69a6                	ld	s3,72(sp)
}
    80003600:	70a6                	ld	ra,104(sp)
    80003602:	7406                	ld	s0,96(sp)
    80003604:	64e6                	ld	s1,88(sp)
    80003606:	6a06                	ld	s4,64(sp)
    80003608:	7ae2                	ld	s5,56(sp)
    8000360a:	7b42                	ld	s6,48(sp)
    8000360c:	7ba2                	ld	s7,40(sp)
    8000360e:	6165                	addi	sp,sp,112
    80003610:	8082                	ret
    return 0;
    80003612:	4501                	li	a0,0
}
    80003614:	8082                	ret

0000000080003616 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003616:	457c                	lw	a5,76(a0)
    80003618:	0ed7eb63          	bltu	a5,a3,8000370e <writei+0xf8>
{
    8000361c:	7159                	addi	sp,sp,-112
    8000361e:	f486                	sd	ra,104(sp)
    80003620:	f0a2                	sd	s0,96(sp)
    80003622:	e8ca                	sd	s2,80(sp)
    80003624:	e0d2                	sd	s4,64(sp)
    80003626:	fc56                	sd	s5,56(sp)
    80003628:	f85a                	sd	s6,48(sp)
    8000362a:	f45e                	sd	s7,40(sp)
    8000362c:	1880                	addi	s0,sp,112
    8000362e:	8aaa                	mv	s5,a0
    80003630:	8bae                	mv	s7,a1
    80003632:	8a32                	mv	s4,a2
    80003634:	8936                	mv	s2,a3
    80003636:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003638:	00e687bb          	addw	a5,a3,a4
    8000363c:	0cd7eb63          	bltu	a5,a3,80003712 <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003640:	00043737          	lui	a4,0x43
    80003644:	0cf76963          	bltu	a4,a5,80003716 <writei+0x100>
    80003648:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000364a:	0a0b0a63          	beqz	s6,800036fe <writei+0xe8>
    8000364e:	eca6                	sd	s1,88(sp)
    80003650:	f062                	sd	s8,32(sp)
    80003652:	ec66                	sd	s9,24(sp)
    80003654:	e86a                	sd	s10,16(sp)
    80003656:	e46e                	sd	s11,8(sp)
    80003658:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000365a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000365e:	5c7d                	li	s8,-1
    80003660:	a825                	j	80003698 <writei+0x82>
    80003662:	020d1d93          	slli	s11,s10,0x20
    80003666:	020ddd93          	srli	s11,s11,0x20
    8000366a:	05848513          	addi	a0,s1,88
    8000366e:	86ee                	mv	a3,s11
    80003670:	8652                	mv	a2,s4
    80003672:	85de                	mv	a1,s7
    80003674:	953e                	add	a0,a0,a5
    80003676:	c29fe0ef          	jal	8000229e <either_copyin>
    8000367a:	05850663          	beq	a0,s8,800036c6 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000367e:	8526                	mv	a0,s1
    80003680:	688000ef          	jal	80003d08 <log_write>
    brelse(bp);
    80003684:	8526                	mv	a0,s1
    80003686:	e3cff0ef          	jal	80002cc2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000368a:	013d09bb          	addw	s3,s10,s3
    8000368e:	012d093b          	addw	s2,s10,s2
    80003692:	9a6e                	add	s4,s4,s11
    80003694:	0369fc63          	bgeu	s3,s6,800036cc <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003698:	00a9559b          	srliw	a1,s2,0xa
    8000369c:	8556                	mv	a0,s5
    8000369e:	88fff0ef          	jal	80002f2c <bmap>
    800036a2:	85aa                	mv	a1,a0
    if(addr == 0)
    800036a4:	c505                	beqz	a0,800036cc <writei+0xb6>
    bp = bread(ip->dev, addr);
    800036a6:	000aa503          	lw	a0,0(s5)
    800036aa:	d10ff0ef          	jal	80002bba <bread>
    800036ae:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036b0:	3ff97793          	andi	a5,s2,1023
    800036b4:	40fc873b          	subw	a4,s9,a5
    800036b8:	413b06bb          	subw	a3,s6,s3
    800036bc:	8d3a                	mv	s10,a4
    800036be:	fae6f2e3          	bgeu	a3,a4,80003662 <writei+0x4c>
    800036c2:	8d36                	mv	s10,a3
    800036c4:	bf79                	j	80003662 <writei+0x4c>
      brelse(bp);
    800036c6:	8526                	mv	a0,s1
    800036c8:	dfaff0ef          	jal	80002cc2 <brelse>
  }

  if(off > ip->size)
    800036cc:	04caa783          	lw	a5,76(s5)
    800036d0:	0327f963          	bgeu	a5,s2,80003702 <writei+0xec>
    ip->size = off;
    800036d4:	052aa623          	sw	s2,76(s5)
    800036d8:	64e6                	ld	s1,88(sp)
    800036da:	7c02                	ld	s8,32(sp)
    800036dc:	6ce2                	ld	s9,24(sp)
    800036de:	6d42                	ld	s10,16(sp)
    800036e0:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800036e2:	8556                	mv	a0,s5
    800036e4:	b35ff0ef          	jal	80003218 <iupdate>

  return tot;
    800036e8:	854e                	mv	a0,s3
    800036ea:	69a6                	ld	s3,72(sp)
}
    800036ec:	70a6                	ld	ra,104(sp)
    800036ee:	7406                	ld	s0,96(sp)
    800036f0:	6946                	ld	s2,80(sp)
    800036f2:	6a06                	ld	s4,64(sp)
    800036f4:	7ae2                	ld	s5,56(sp)
    800036f6:	7b42                	ld	s6,48(sp)
    800036f8:	7ba2                	ld	s7,40(sp)
    800036fa:	6165                	addi	sp,sp,112
    800036fc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036fe:	89da                	mv	s3,s6
    80003700:	b7cd                	j	800036e2 <writei+0xcc>
    80003702:	64e6                	ld	s1,88(sp)
    80003704:	7c02                	ld	s8,32(sp)
    80003706:	6ce2                	ld	s9,24(sp)
    80003708:	6d42                	ld	s10,16(sp)
    8000370a:	6da2                	ld	s11,8(sp)
    8000370c:	bfd9                	j	800036e2 <writei+0xcc>
    return -1;
    8000370e:	557d                	li	a0,-1
}
    80003710:	8082                	ret
    return -1;
    80003712:	557d                	li	a0,-1
    80003714:	bfe1                	j	800036ec <writei+0xd6>
    return -1;
    80003716:	557d                	li	a0,-1
    80003718:	bfd1                	j	800036ec <writei+0xd6>

000000008000371a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000371a:	1141                	addi	sp,sp,-16
    8000371c:	e406                	sd	ra,8(sp)
    8000371e:	e022                	sd	s0,0(sp)
    80003720:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003722:	4639                	li	a2,14
    80003724:	e82fd0ef          	jal	80000da6 <strncmp>
}
    80003728:	60a2                	ld	ra,8(sp)
    8000372a:	6402                	ld	s0,0(sp)
    8000372c:	0141                	addi	sp,sp,16
    8000372e:	8082                	ret

0000000080003730 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003730:	711d                	addi	sp,sp,-96
    80003732:	ec86                	sd	ra,88(sp)
    80003734:	e8a2                	sd	s0,80(sp)
    80003736:	e4a6                	sd	s1,72(sp)
    80003738:	e0ca                	sd	s2,64(sp)
    8000373a:	fc4e                	sd	s3,56(sp)
    8000373c:	f852                	sd	s4,48(sp)
    8000373e:	f456                	sd	s5,40(sp)
    80003740:	f05a                	sd	s6,32(sp)
    80003742:	ec5e                	sd	s7,24(sp)
    80003744:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003746:	04451703          	lh	a4,68(a0)
    8000374a:	4785                	li	a5,1
    8000374c:	00f71f63          	bne	a4,a5,8000376a <dirlookup+0x3a>
    80003750:	892a                	mv	s2,a0
    80003752:	8aae                	mv	s5,a1
    80003754:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003756:	457c                	lw	a5,76(a0)
    80003758:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000375a:	fa040a13          	addi	s4,s0,-96
    8000375e:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003760:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003764:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003766:	e39d                	bnez	a5,8000378c <dirlookup+0x5c>
    80003768:	a8b9                	j	800037c6 <dirlookup+0x96>
    panic("dirlookup not DIR");
    8000376a:	00004517          	auipc	a0,0x4
    8000376e:	e5e50513          	addi	a0,a0,-418 # 800075c8 <etext+0x5c8>
    80003772:	82cfd0ef          	jal	8000079e <panic>
      panic("dirlookup read");
    80003776:	00004517          	auipc	a0,0x4
    8000377a:	e6a50513          	addi	a0,a0,-406 # 800075e0 <etext+0x5e0>
    8000377e:	820fd0ef          	jal	8000079e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003782:	24c1                	addiw	s1,s1,16
    80003784:	04c92783          	lw	a5,76(s2)
    80003788:	02f4fe63          	bgeu	s1,a5,800037c4 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000378c:	874e                	mv	a4,s3
    8000378e:	86a6                	mv	a3,s1
    80003790:	8652                	mv	a2,s4
    80003792:	4581                	li	a1,0
    80003794:	854a                	mv	a0,s2
    80003796:	d8fff0ef          	jal	80003524 <readi>
    8000379a:	fd351ee3          	bne	a0,s3,80003776 <dirlookup+0x46>
    if(de.inum == 0)
    8000379e:	fa045783          	lhu	a5,-96(s0)
    800037a2:	d3e5                	beqz	a5,80003782 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800037a4:	85da                	mv	a1,s6
    800037a6:	8556                	mv	a0,s5
    800037a8:	f73ff0ef          	jal	8000371a <namecmp>
    800037ac:	f979                	bnez	a0,80003782 <dirlookup+0x52>
      if(poff)
    800037ae:	000b8463          	beqz	s7,800037b6 <dirlookup+0x86>
        *poff = off;
    800037b2:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800037b6:	fa045583          	lhu	a1,-96(s0)
    800037ba:	00092503          	lw	a0,0(s2)
    800037be:	82fff0ef          	jal	80002fec <iget>
    800037c2:	a011                	j	800037c6 <dirlookup+0x96>
  return 0;
    800037c4:	4501                	li	a0,0
}
    800037c6:	60e6                	ld	ra,88(sp)
    800037c8:	6446                	ld	s0,80(sp)
    800037ca:	64a6                	ld	s1,72(sp)
    800037cc:	6906                	ld	s2,64(sp)
    800037ce:	79e2                	ld	s3,56(sp)
    800037d0:	7a42                	ld	s4,48(sp)
    800037d2:	7aa2                	ld	s5,40(sp)
    800037d4:	7b02                	ld	s6,32(sp)
    800037d6:	6be2                	ld	s7,24(sp)
    800037d8:	6125                	addi	sp,sp,96
    800037da:	8082                	ret

00000000800037dc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800037dc:	711d                	addi	sp,sp,-96
    800037de:	ec86                	sd	ra,88(sp)
    800037e0:	e8a2                	sd	s0,80(sp)
    800037e2:	e4a6                	sd	s1,72(sp)
    800037e4:	e0ca                	sd	s2,64(sp)
    800037e6:	fc4e                	sd	s3,56(sp)
    800037e8:	f852                	sd	s4,48(sp)
    800037ea:	f456                	sd	s5,40(sp)
    800037ec:	f05a                	sd	s6,32(sp)
    800037ee:	ec5e                	sd	s7,24(sp)
    800037f0:	e862                	sd	s8,16(sp)
    800037f2:	e466                	sd	s9,8(sp)
    800037f4:	e06a                	sd	s10,0(sp)
    800037f6:	1080                	addi	s0,sp,96
    800037f8:	84aa                	mv	s1,a0
    800037fa:	8b2e                	mv	s6,a1
    800037fc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800037fe:	00054703          	lbu	a4,0(a0)
    80003802:	02f00793          	li	a5,47
    80003806:	00f70f63          	beq	a4,a5,80003824 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000380a:	8d2fe0ef          	jal	800018dc <myproc>
    8000380e:	15053503          	ld	a0,336(a0)
    80003812:	a85ff0ef          	jal	80003296 <idup>
    80003816:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003818:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000381c:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    8000381e:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003820:	4b85                	li	s7,1
    80003822:	a879                	j	800038c0 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003824:	4585                	li	a1,1
    80003826:	852e                	mv	a0,a1
    80003828:	fc4ff0ef          	jal	80002fec <iget>
    8000382c:	8a2a                	mv	s4,a0
    8000382e:	b7ed                	j	80003818 <namex+0x3c>
      iunlockput(ip);
    80003830:	8552                	mv	a0,s4
    80003832:	ca5ff0ef          	jal	800034d6 <iunlockput>
      return 0;
    80003836:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003838:	8552                	mv	a0,s4
    8000383a:	60e6                	ld	ra,88(sp)
    8000383c:	6446                	ld	s0,80(sp)
    8000383e:	64a6                	ld	s1,72(sp)
    80003840:	6906                	ld	s2,64(sp)
    80003842:	79e2                	ld	s3,56(sp)
    80003844:	7a42                	ld	s4,48(sp)
    80003846:	7aa2                	ld	s5,40(sp)
    80003848:	7b02                	ld	s6,32(sp)
    8000384a:	6be2                	ld	s7,24(sp)
    8000384c:	6c42                	ld	s8,16(sp)
    8000384e:	6ca2                	ld	s9,8(sp)
    80003850:	6d02                	ld	s10,0(sp)
    80003852:	6125                	addi	sp,sp,96
    80003854:	8082                	ret
      iunlock(ip);
    80003856:	8552                	mv	a0,s4
    80003858:	b23ff0ef          	jal	8000337a <iunlock>
      return ip;
    8000385c:	bff1                	j	80003838 <namex+0x5c>
      iunlockput(ip);
    8000385e:	8552                	mv	a0,s4
    80003860:	c77ff0ef          	jal	800034d6 <iunlockput>
      return 0;
    80003864:	8a4e                	mv	s4,s3
    80003866:	bfc9                	j	80003838 <namex+0x5c>
  len = path - s;
    80003868:	40998633          	sub	a2,s3,s1
    8000386c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003870:	09ac5063          	bge	s8,s10,800038f0 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003874:	8666                	mv	a2,s9
    80003876:	85a6                	mv	a1,s1
    80003878:	8556                	mv	a0,s5
    8000387a:	cb8fd0ef          	jal	80000d32 <memmove>
    8000387e:	84ce                	mv	s1,s3
  while(*path == '/')
    80003880:	0004c783          	lbu	a5,0(s1)
    80003884:	01279763          	bne	a5,s2,80003892 <namex+0xb6>
    path++;
    80003888:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000388a:	0004c783          	lbu	a5,0(s1)
    8000388e:	ff278de3          	beq	a5,s2,80003888 <namex+0xac>
    ilock(ip);
    80003892:	8552                	mv	a0,s4
    80003894:	a39ff0ef          	jal	800032cc <ilock>
    if(ip->type != T_DIR){
    80003898:	044a1783          	lh	a5,68(s4)
    8000389c:	f9779ae3          	bne	a5,s7,80003830 <namex+0x54>
    if(nameiparent && *path == '\0'){
    800038a0:	000b0563          	beqz	s6,800038aa <namex+0xce>
    800038a4:	0004c783          	lbu	a5,0(s1)
    800038a8:	d7dd                	beqz	a5,80003856 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800038aa:	4601                	li	a2,0
    800038ac:	85d6                	mv	a1,s5
    800038ae:	8552                	mv	a0,s4
    800038b0:	e81ff0ef          	jal	80003730 <dirlookup>
    800038b4:	89aa                	mv	s3,a0
    800038b6:	d545                	beqz	a0,8000385e <namex+0x82>
    iunlockput(ip);
    800038b8:	8552                	mv	a0,s4
    800038ba:	c1dff0ef          	jal	800034d6 <iunlockput>
    ip = next;
    800038be:	8a4e                	mv	s4,s3
  while(*path == '/')
    800038c0:	0004c783          	lbu	a5,0(s1)
    800038c4:	01279763          	bne	a5,s2,800038d2 <namex+0xf6>
    path++;
    800038c8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038ca:	0004c783          	lbu	a5,0(s1)
    800038ce:	ff278de3          	beq	a5,s2,800038c8 <namex+0xec>
  if(*path == 0)
    800038d2:	cb8d                	beqz	a5,80003904 <namex+0x128>
  while(*path != '/' && *path != 0)
    800038d4:	0004c783          	lbu	a5,0(s1)
    800038d8:	89a6                	mv	s3,s1
  len = path - s;
    800038da:	4d01                	li	s10,0
    800038dc:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800038de:	01278963          	beq	a5,s2,800038f0 <namex+0x114>
    800038e2:	d3d9                	beqz	a5,80003868 <namex+0x8c>
    path++;
    800038e4:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800038e6:	0009c783          	lbu	a5,0(s3)
    800038ea:	ff279ce3          	bne	a5,s2,800038e2 <namex+0x106>
    800038ee:	bfad                	j	80003868 <namex+0x8c>
    memmove(name, s, len);
    800038f0:	2601                	sext.w	a2,a2
    800038f2:	85a6                	mv	a1,s1
    800038f4:	8556                	mv	a0,s5
    800038f6:	c3cfd0ef          	jal	80000d32 <memmove>
    name[len] = 0;
    800038fa:	9d56                	add	s10,s10,s5
    800038fc:	000d0023          	sb	zero,0(s10)
    80003900:	84ce                	mv	s1,s3
    80003902:	bfbd                	j	80003880 <namex+0xa4>
  if(nameiparent){
    80003904:	f20b0ae3          	beqz	s6,80003838 <namex+0x5c>
    iput(ip);
    80003908:	8552                	mv	a0,s4
    8000390a:	b45ff0ef          	jal	8000344e <iput>
    return 0;
    8000390e:	4a01                	li	s4,0
    80003910:	b725                	j	80003838 <namex+0x5c>

0000000080003912 <dirlink>:
{
    80003912:	715d                	addi	sp,sp,-80
    80003914:	e486                	sd	ra,72(sp)
    80003916:	e0a2                	sd	s0,64(sp)
    80003918:	f84a                	sd	s2,48(sp)
    8000391a:	ec56                	sd	s5,24(sp)
    8000391c:	e85a                	sd	s6,16(sp)
    8000391e:	0880                	addi	s0,sp,80
    80003920:	892a                	mv	s2,a0
    80003922:	8aae                	mv	s5,a1
    80003924:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003926:	4601                	li	a2,0
    80003928:	e09ff0ef          	jal	80003730 <dirlookup>
    8000392c:	ed1d                	bnez	a0,8000396a <dirlink+0x58>
    8000392e:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003930:	04c92483          	lw	s1,76(s2)
    80003934:	c4b9                	beqz	s1,80003982 <dirlink+0x70>
    80003936:	f44e                	sd	s3,40(sp)
    80003938:	f052                	sd	s4,32(sp)
    8000393a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000393c:	fb040a13          	addi	s4,s0,-80
    80003940:	49c1                	li	s3,16
    80003942:	874e                	mv	a4,s3
    80003944:	86a6                	mv	a3,s1
    80003946:	8652                	mv	a2,s4
    80003948:	4581                	li	a1,0
    8000394a:	854a                	mv	a0,s2
    8000394c:	bd9ff0ef          	jal	80003524 <readi>
    80003950:	03351163          	bne	a0,s3,80003972 <dirlink+0x60>
    if(de.inum == 0)
    80003954:	fb045783          	lhu	a5,-80(s0)
    80003958:	c39d                	beqz	a5,8000397e <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000395a:	24c1                	addiw	s1,s1,16
    8000395c:	04c92783          	lw	a5,76(s2)
    80003960:	fef4e1e3          	bltu	s1,a5,80003942 <dirlink+0x30>
    80003964:	79a2                	ld	s3,40(sp)
    80003966:	7a02                	ld	s4,32(sp)
    80003968:	a829                	j	80003982 <dirlink+0x70>
    iput(ip);
    8000396a:	ae5ff0ef          	jal	8000344e <iput>
    return -1;
    8000396e:	557d                	li	a0,-1
    80003970:	a83d                	j	800039ae <dirlink+0x9c>
      panic("dirlink read");
    80003972:	00004517          	auipc	a0,0x4
    80003976:	c7e50513          	addi	a0,a0,-898 # 800075f0 <etext+0x5f0>
    8000397a:	e25fc0ef          	jal	8000079e <panic>
    8000397e:	79a2                	ld	s3,40(sp)
    80003980:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003982:	4639                	li	a2,14
    80003984:	85d6                	mv	a1,s5
    80003986:	fb240513          	addi	a0,s0,-78
    8000398a:	c56fd0ef          	jal	80000de0 <strncpy>
  de.inum = inum;
    8000398e:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003992:	4741                	li	a4,16
    80003994:	86a6                	mv	a3,s1
    80003996:	fb040613          	addi	a2,s0,-80
    8000399a:	4581                	li	a1,0
    8000399c:	854a                	mv	a0,s2
    8000399e:	c79ff0ef          	jal	80003616 <writei>
    800039a2:	1541                	addi	a0,a0,-16
    800039a4:	00a03533          	snez	a0,a0
    800039a8:	40a0053b          	negw	a0,a0
    800039ac:	74e2                	ld	s1,56(sp)
}
    800039ae:	60a6                	ld	ra,72(sp)
    800039b0:	6406                	ld	s0,64(sp)
    800039b2:	7942                	ld	s2,48(sp)
    800039b4:	6ae2                	ld	s5,24(sp)
    800039b6:	6b42                	ld	s6,16(sp)
    800039b8:	6161                	addi	sp,sp,80
    800039ba:	8082                	ret

00000000800039bc <namei>:

struct inode*
namei(char *path)
{
    800039bc:	1101                	addi	sp,sp,-32
    800039be:	ec06                	sd	ra,24(sp)
    800039c0:	e822                	sd	s0,16(sp)
    800039c2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800039c4:	fe040613          	addi	a2,s0,-32
    800039c8:	4581                	li	a1,0
    800039ca:	e13ff0ef          	jal	800037dc <namex>
}
    800039ce:	60e2                	ld	ra,24(sp)
    800039d0:	6442                	ld	s0,16(sp)
    800039d2:	6105                	addi	sp,sp,32
    800039d4:	8082                	ret

00000000800039d6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800039d6:	1141                	addi	sp,sp,-16
    800039d8:	e406                	sd	ra,8(sp)
    800039da:	e022                	sd	s0,0(sp)
    800039dc:	0800                	addi	s0,sp,16
    800039de:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800039e0:	4585                	li	a1,1
    800039e2:	dfbff0ef          	jal	800037dc <namex>
}
    800039e6:	60a2                	ld	ra,8(sp)
    800039e8:	6402                	ld	s0,0(sp)
    800039ea:	0141                	addi	sp,sp,16
    800039ec:	8082                	ret

00000000800039ee <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800039ee:	1101                	addi	sp,sp,-32
    800039f0:	ec06                	sd	ra,24(sp)
    800039f2:	e822                	sd	s0,16(sp)
    800039f4:	e426                	sd	s1,8(sp)
    800039f6:	e04a                	sd	s2,0(sp)
    800039f8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800039fa:	00025917          	auipc	s2,0x25
    800039fe:	b6690913          	addi	s2,s2,-1178 # 80028560 <log>
    80003a02:	01892583          	lw	a1,24(s2)
    80003a06:	02892503          	lw	a0,40(s2)
    80003a0a:	9b0ff0ef          	jal	80002bba <bread>
    80003a0e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003a10:	02c92603          	lw	a2,44(s2)
    80003a14:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a16:	00c05f63          	blez	a2,80003a34 <write_head+0x46>
    80003a1a:	00025717          	auipc	a4,0x25
    80003a1e:	b7670713          	addi	a4,a4,-1162 # 80028590 <log+0x30>
    80003a22:	87aa                	mv	a5,a0
    80003a24:	060a                	slli	a2,a2,0x2
    80003a26:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a28:	4314                	lw	a3,0(a4)
    80003a2a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a2c:	0711                	addi	a4,a4,4
    80003a2e:	0791                	addi	a5,a5,4
    80003a30:	fec79ce3          	bne	a5,a2,80003a28 <write_head+0x3a>
  }
  bwrite(buf);
    80003a34:	8526                	mv	a0,s1
    80003a36:	a5aff0ef          	jal	80002c90 <bwrite>
  brelse(buf);
    80003a3a:	8526                	mv	a0,s1
    80003a3c:	a86ff0ef          	jal	80002cc2 <brelse>
}
    80003a40:	60e2                	ld	ra,24(sp)
    80003a42:	6442                	ld	s0,16(sp)
    80003a44:	64a2                	ld	s1,8(sp)
    80003a46:	6902                	ld	s2,0(sp)
    80003a48:	6105                	addi	sp,sp,32
    80003a4a:	8082                	ret

0000000080003a4c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a4c:	00025797          	auipc	a5,0x25
    80003a50:	b407a783          	lw	a5,-1216(a5) # 8002858c <log+0x2c>
    80003a54:	0af05263          	blez	a5,80003af8 <install_trans+0xac>
{
    80003a58:	715d                	addi	sp,sp,-80
    80003a5a:	e486                	sd	ra,72(sp)
    80003a5c:	e0a2                	sd	s0,64(sp)
    80003a5e:	fc26                	sd	s1,56(sp)
    80003a60:	f84a                	sd	s2,48(sp)
    80003a62:	f44e                	sd	s3,40(sp)
    80003a64:	f052                	sd	s4,32(sp)
    80003a66:	ec56                	sd	s5,24(sp)
    80003a68:	e85a                	sd	s6,16(sp)
    80003a6a:	e45e                	sd	s7,8(sp)
    80003a6c:	0880                	addi	s0,sp,80
    80003a6e:	8b2a                	mv	s6,a0
    80003a70:	00025a97          	auipc	s5,0x25
    80003a74:	b20a8a93          	addi	s5,s5,-1248 # 80028590 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a78:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a7a:	00025997          	auipc	s3,0x25
    80003a7e:	ae698993          	addi	s3,s3,-1306 # 80028560 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003a82:	40000b93          	li	s7,1024
    80003a86:	a829                	j	80003aa0 <install_trans+0x54>
    brelse(lbuf);
    80003a88:	854a                	mv	a0,s2
    80003a8a:	a38ff0ef          	jal	80002cc2 <brelse>
    brelse(dbuf);
    80003a8e:	8526                	mv	a0,s1
    80003a90:	a32ff0ef          	jal	80002cc2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a94:	2a05                	addiw	s4,s4,1
    80003a96:	0a91                	addi	s5,s5,4
    80003a98:	02c9a783          	lw	a5,44(s3)
    80003a9c:	04fa5363          	bge	s4,a5,80003ae2 <install_trans+0x96>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003aa0:	0189a583          	lw	a1,24(s3)
    80003aa4:	014585bb          	addw	a1,a1,s4
    80003aa8:	2585                	addiw	a1,a1,1
    80003aaa:	0289a503          	lw	a0,40(s3)
    80003aae:	90cff0ef          	jal	80002bba <bread>
    80003ab2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ab4:	000aa583          	lw	a1,0(s5)
    80003ab8:	0289a503          	lw	a0,40(s3)
    80003abc:	8feff0ef          	jal	80002bba <bread>
    80003ac0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ac2:	865e                	mv	a2,s7
    80003ac4:	05890593          	addi	a1,s2,88
    80003ac8:	05850513          	addi	a0,a0,88
    80003acc:	a66fd0ef          	jal	80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ad0:	8526                	mv	a0,s1
    80003ad2:	9beff0ef          	jal	80002c90 <bwrite>
    if(recovering == 0)
    80003ad6:	fa0b19e3          	bnez	s6,80003a88 <install_trans+0x3c>
      bunpin(dbuf);
    80003ada:	8526                	mv	a0,s1
    80003adc:	a9eff0ef          	jal	80002d7a <bunpin>
    80003ae0:	b765                	j	80003a88 <install_trans+0x3c>
}
    80003ae2:	60a6                	ld	ra,72(sp)
    80003ae4:	6406                	ld	s0,64(sp)
    80003ae6:	74e2                	ld	s1,56(sp)
    80003ae8:	7942                	ld	s2,48(sp)
    80003aea:	79a2                	ld	s3,40(sp)
    80003aec:	7a02                	ld	s4,32(sp)
    80003aee:	6ae2                	ld	s5,24(sp)
    80003af0:	6b42                	ld	s6,16(sp)
    80003af2:	6ba2                	ld	s7,8(sp)
    80003af4:	6161                	addi	sp,sp,80
    80003af6:	8082                	ret
    80003af8:	8082                	ret

0000000080003afa <initlog>:
{
    80003afa:	7179                	addi	sp,sp,-48
    80003afc:	f406                	sd	ra,40(sp)
    80003afe:	f022                	sd	s0,32(sp)
    80003b00:	ec26                	sd	s1,24(sp)
    80003b02:	e84a                	sd	s2,16(sp)
    80003b04:	e44e                	sd	s3,8(sp)
    80003b06:	1800                	addi	s0,sp,48
    80003b08:	892a                	mv	s2,a0
    80003b0a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b0c:	00025497          	auipc	s1,0x25
    80003b10:	a5448493          	addi	s1,s1,-1452 # 80028560 <log>
    80003b14:	00004597          	auipc	a1,0x4
    80003b18:	aec58593          	addi	a1,a1,-1300 # 80007600 <etext+0x600>
    80003b1c:	8526                	mv	a0,s1
    80003b1e:	85cfd0ef          	jal	80000b7a <initlock>
  log.start = sb->logstart;
    80003b22:	0149a583          	lw	a1,20(s3)
    80003b26:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003b28:	0109a783          	lw	a5,16(s3)
    80003b2c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003b2e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003b32:	854a                	mv	a0,s2
    80003b34:	886ff0ef          	jal	80002bba <bread>
  log.lh.n = lh->n;
    80003b38:	4d30                	lw	a2,88(a0)
    80003b3a:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003b3c:	00c05f63          	blez	a2,80003b5a <initlog+0x60>
    80003b40:	87aa                	mv	a5,a0
    80003b42:	00025717          	auipc	a4,0x25
    80003b46:	a4e70713          	addi	a4,a4,-1458 # 80028590 <log+0x30>
    80003b4a:	060a                	slli	a2,a2,0x2
    80003b4c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003b4e:	4ff4                	lw	a3,92(a5)
    80003b50:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003b52:	0791                	addi	a5,a5,4
    80003b54:	0711                	addi	a4,a4,4
    80003b56:	fec79ce3          	bne	a5,a2,80003b4e <initlog+0x54>
  brelse(buf);
    80003b5a:	968ff0ef          	jal	80002cc2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003b5e:	4505                	li	a0,1
    80003b60:	eedff0ef          	jal	80003a4c <install_trans>
  log.lh.n = 0;
    80003b64:	00025797          	auipc	a5,0x25
    80003b68:	a207a423          	sw	zero,-1496(a5) # 8002858c <log+0x2c>
  write_head(); // clear the log
    80003b6c:	e83ff0ef          	jal	800039ee <write_head>
}
    80003b70:	70a2                	ld	ra,40(sp)
    80003b72:	7402                	ld	s0,32(sp)
    80003b74:	64e2                	ld	s1,24(sp)
    80003b76:	6942                	ld	s2,16(sp)
    80003b78:	69a2                	ld	s3,8(sp)
    80003b7a:	6145                	addi	sp,sp,48
    80003b7c:	8082                	ret

0000000080003b7e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003b7e:	1101                	addi	sp,sp,-32
    80003b80:	ec06                	sd	ra,24(sp)
    80003b82:	e822                	sd	s0,16(sp)
    80003b84:	e426                	sd	s1,8(sp)
    80003b86:	e04a                	sd	s2,0(sp)
    80003b88:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003b8a:	00025517          	auipc	a0,0x25
    80003b8e:	9d650513          	addi	a0,a0,-1578 # 80028560 <log>
    80003b92:	86cfd0ef          	jal	80000bfe <acquire>
  while(1){
    if(log.committing){
    80003b96:	00025497          	auipc	s1,0x25
    80003b9a:	9ca48493          	addi	s1,s1,-1590 # 80028560 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b9e:	4979                	li	s2,30
    80003ba0:	a029                	j	80003baa <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003ba2:	85a6                	mv	a1,s1
    80003ba4:	8526                	mv	a0,s1
    80003ba6:	b58fe0ef          	jal	80001efe <sleep>
    if(log.committing){
    80003baa:	50dc                	lw	a5,36(s1)
    80003bac:	fbfd                	bnez	a5,80003ba2 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003bae:	5098                	lw	a4,32(s1)
    80003bb0:	2705                	addiw	a4,a4,1
    80003bb2:	0027179b          	slliw	a5,a4,0x2
    80003bb6:	9fb9                	addw	a5,a5,a4
    80003bb8:	0017979b          	slliw	a5,a5,0x1
    80003bbc:	54d4                	lw	a3,44(s1)
    80003bbe:	9fb5                	addw	a5,a5,a3
    80003bc0:	00f95763          	bge	s2,a5,80003bce <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003bc4:	85a6                	mv	a1,s1
    80003bc6:	8526                	mv	a0,s1
    80003bc8:	b36fe0ef          	jal	80001efe <sleep>
    80003bcc:	bff9                	j	80003baa <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003bce:	00025517          	auipc	a0,0x25
    80003bd2:	99250513          	addi	a0,a0,-1646 # 80028560 <log>
    80003bd6:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003bd8:	8bafd0ef          	jal	80000c92 <release>
      break;
    }
  }
}
    80003bdc:	60e2                	ld	ra,24(sp)
    80003bde:	6442                	ld	s0,16(sp)
    80003be0:	64a2                	ld	s1,8(sp)
    80003be2:	6902                	ld	s2,0(sp)
    80003be4:	6105                	addi	sp,sp,32
    80003be6:	8082                	ret

0000000080003be8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003be8:	7139                	addi	sp,sp,-64
    80003bea:	fc06                	sd	ra,56(sp)
    80003bec:	f822                	sd	s0,48(sp)
    80003bee:	f426                	sd	s1,40(sp)
    80003bf0:	f04a                	sd	s2,32(sp)
    80003bf2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003bf4:	00025497          	auipc	s1,0x25
    80003bf8:	96c48493          	addi	s1,s1,-1684 # 80028560 <log>
    80003bfc:	8526                	mv	a0,s1
    80003bfe:	800fd0ef          	jal	80000bfe <acquire>
  log.outstanding -= 1;
    80003c02:	509c                	lw	a5,32(s1)
    80003c04:	37fd                	addiw	a5,a5,-1
    80003c06:	893e                	mv	s2,a5
    80003c08:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003c0a:	50dc                	lw	a5,36(s1)
    80003c0c:	ef9d                	bnez	a5,80003c4a <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    80003c0e:	04091863          	bnez	s2,80003c5e <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003c12:	00025497          	auipc	s1,0x25
    80003c16:	94e48493          	addi	s1,s1,-1714 # 80028560 <log>
    80003c1a:	4785                	li	a5,1
    80003c1c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c1e:	8526                	mv	a0,s1
    80003c20:	872fd0ef          	jal	80000c92 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003c24:	54dc                	lw	a5,44(s1)
    80003c26:	04f04c63          	bgtz	a5,80003c7e <end_op+0x96>
    acquire(&log.lock);
    80003c2a:	00025497          	auipc	s1,0x25
    80003c2e:	93648493          	addi	s1,s1,-1738 # 80028560 <log>
    80003c32:	8526                	mv	a0,s1
    80003c34:	fcbfc0ef          	jal	80000bfe <acquire>
    log.committing = 0;
    80003c38:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003c3c:	8526                	mv	a0,s1
    80003c3e:	b0cfe0ef          	jal	80001f4a <wakeup>
    release(&log.lock);
    80003c42:	8526                	mv	a0,s1
    80003c44:	84efd0ef          	jal	80000c92 <release>
}
    80003c48:	a02d                	j	80003c72 <end_op+0x8a>
    80003c4a:	ec4e                	sd	s3,24(sp)
    80003c4c:	e852                	sd	s4,16(sp)
    80003c4e:	e456                	sd	s5,8(sp)
    80003c50:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80003c52:	00004517          	auipc	a0,0x4
    80003c56:	9b650513          	addi	a0,a0,-1610 # 80007608 <etext+0x608>
    80003c5a:	b45fc0ef          	jal	8000079e <panic>
    wakeup(&log);
    80003c5e:	00025497          	auipc	s1,0x25
    80003c62:	90248493          	addi	s1,s1,-1790 # 80028560 <log>
    80003c66:	8526                	mv	a0,s1
    80003c68:	ae2fe0ef          	jal	80001f4a <wakeup>
  release(&log.lock);
    80003c6c:	8526                	mv	a0,s1
    80003c6e:	824fd0ef          	jal	80000c92 <release>
}
    80003c72:	70e2                	ld	ra,56(sp)
    80003c74:	7442                	ld	s0,48(sp)
    80003c76:	74a2                	ld	s1,40(sp)
    80003c78:	7902                	ld	s2,32(sp)
    80003c7a:	6121                	addi	sp,sp,64
    80003c7c:	8082                	ret
    80003c7e:	ec4e                	sd	s3,24(sp)
    80003c80:	e852                	sd	s4,16(sp)
    80003c82:	e456                	sd	s5,8(sp)
    80003c84:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c86:	00025a97          	auipc	s5,0x25
    80003c8a:	90aa8a93          	addi	s5,s5,-1782 # 80028590 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003c8e:	00025a17          	auipc	s4,0x25
    80003c92:	8d2a0a13          	addi	s4,s4,-1838 # 80028560 <log>
    memmove(to->data, from->data, BSIZE);
    80003c96:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003c9a:	018a2583          	lw	a1,24(s4)
    80003c9e:	012585bb          	addw	a1,a1,s2
    80003ca2:	2585                	addiw	a1,a1,1
    80003ca4:	028a2503          	lw	a0,40(s4)
    80003ca8:	f13fe0ef          	jal	80002bba <bread>
    80003cac:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003cae:	000aa583          	lw	a1,0(s5)
    80003cb2:	028a2503          	lw	a0,40(s4)
    80003cb6:	f05fe0ef          	jal	80002bba <bread>
    80003cba:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003cbc:	865a                	mv	a2,s6
    80003cbe:	05850593          	addi	a1,a0,88
    80003cc2:	05848513          	addi	a0,s1,88
    80003cc6:	86cfd0ef          	jal	80000d32 <memmove>
    bwrite(to);  // write the log
    80003cca:	8526                	mv	a0,s1
    80003ccc:	fc5fe0ef          	jal	80002c90 <bwrite>
    brelse(from);
    80003cd0:	854e                	mv	a0,s3
    80003cd2:	ff1fe0ef          	jal	80002cc2 <brelse>
    brelse(to);
    80003cd6:	8526                	mv	a0,s1
    80003cd8:	febfe0ef          	jal	80002cc2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cdc:	2905                	addiw	s2,s2,1
    80003cde:	0a91                	addi	s5,s5,4
    80003ce0:	02ca2783          	lw	a5,44(s4)
    80003ce4:	faf94be3          	blt	s2,a5,80003c9a <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003ce8:	d07ff0ef          	jal	800039ee <write_head>
    install_trans(0); // Now install writes to home locations
    80003cec:	4501                	li	a0,0
    80003cee:	d5fff0ef          	jal	80003a4c <install_trans>
    log.lh.n = 0;
    80003cf2:	00025797          	auipc	a5,0x25
    80003cf6:	8807ad23          	sw	zero,-1894(a5) # 8002858c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003cfa:	cf5ff0ef          	jal	800039ee <write_head>
    80003cfe:	69e2                	ld	s3,24(sp)
    80003d00:	6a42                	ld	s4,16(sp)
    80003d02:	6aa2                	ld	s5,8(sp)
    80003d04:	6b02                	ld	s6,0(sp)
    80003d06:	b715                	j	80003c2a <end_op+0x42>

0000000080003d08 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d08:	1101                	addi	sp,sp,-32
    80003d0a:	ec06                	sd	ra,24(sp)
    80003d0c:	e822                	sd	s0,16(sp)
    80003d0e:	e426                	sd	s1,8(sp)
    80003d10:	e04a                	sd	s2,0(sp)
    80003d12:	1000                	addi	s0,sp,32
    80003d14:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d16:	00025917          	auipc	s2,0x25
    80003d1a:	84a90913          	addi	s2,s2,-1974 # 80028560 <log>
    80003d1e:	854a                	mv	a0,s2
    80003d20:	edffc0ef          	jal	80000bfe <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003d24:	02c92603          	lw	a2,44(s2)
    80003d28:	47f5                	li	a5,29
    80003d2a:	06c7c363          	blt	a5,a2,80003d90 <log_write+0x88>
    80003d2e:	00025797          	auipc	a5,0x25
    80003d32:	84e7a783          	lw	a5,-1970(a5) # 8002857c <log+0x1c>
    80003d36:	37fd                	addiw	a5,a5,-1
    80003d38:	04f65c63          	bge	a2,a5,80003d90 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003d3c:	00025797          	auipc	a5,0x25
    80003d40:	8447a783          	lw	a5,-1980(a5) # 80028580 <log+0x20>
    80003d44:	04f05c63          	blez	a5,80003d9c <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d48:	4781                	li	a5,0
    80003d4a:	04c05f63          	blez	a2,80003da8 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d4e:	44cc                	lw	a1,12(s1)
    80003d50:	00025717          	auipc	a4,0x25
    80003d54:	84070713          	addi	a4,a4,-1984 # 80028590 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003d58:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d5a:	4314                	lw	a3,0(a4)
    80003d5c:	04b68663          	beq	a3,a1,80003da8 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003d60:	2785                	addiw	a5,a5,1
    80003d62:	0711                	addi	a4,a4,4
    80003d64:	fef61be3          	bne	a2,a5,80003d5a <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003d68:	0621                	addi	a2,a2,8
    80003d6a:	060a                	slli	a2,a2,0x2
    80003d6c:	00024797          	auipc	a5,0x24
    80003d70:	7f478793          	addi	a5,a5,2036 # 80028560 <log>
    80003d74:	97b2                	add	a5,a5,a2
    80003d76:	44d8                	lw	a4,12(s1)
    80003d78:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003d7a:	8526                	mv	a0,s1
    80003d7c:	fcbfe0ef          	jal	80002d46 <bpin>
    log.lh.n++;
    80003d80:	00024717          	auipc	a4,0x24
    80003d84:	7e070713          	addi	a4,a4,2016 # 80028560 <log>
    80003d88:	575c                	lw	a5,44(a4)
    80003d8a:	2785                	addiw	a5,a5,1
    80003d8c:	d75c                	sw	a5,44(a4)
    80003d8e:	a80d                	j	80003dc0 <log_write+0xb8>
    panic("too big a transaction");
    80003d90:	00004517          	auipc	a0,0x4
    80003d94:	88850513          	addi	a0,a0,-1912 # 80007618 <etext+0x618>
    80003d98:	a07fc0ef          	jal	8000079e <panic>
    panic("log_write outside of trans");
    80003d9c:	00004517          	auipc	a0,0x4
    80003da0:	89450513          	addi	a0,a0,-1900 # 80007630 <etext+0x630>
    80003da4:	9fbfc0ef          	jal	8000079e <panic>
  log.lh.block[i] = b->blockno;
    80003da8:	00878693          	addi	a3,a5,8
    80003dac:	068a                	slli	a3,a3,0x2
    80003dae:	00024717          	auipc	a4,0x24
    80003db2:	7b270713          	addi	a4,a4,1970 # 80028560 <log>
    80003db6:	9736                	add	a4,a4,a3
    80003db8:	44d4                	lw	a3,12(s1)
    80003dba:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003dbc:	faf60fe3          	beq	a2,a5,80003d7a <log_write+0x72>
  }
  release(&log.lock);
    80003dc0:	00024517          	auipc	a0,0x24
    80003dc4:	7a050513          	addi	a0,a0,1952 # 80028560 <log>
    80003dc8:	ecbfc0ef          	jal	80000c92 <release>
}
    80003dcc:	60e2                	ld	ra,24(sp)
    80003dce:	6442                	ld	s0,16(sp)
    80003dd0:	64a2                	ld	s1,8(sp)
    80003dd2:	6902                	ld	s2,0(sp)
    80003dd4:	6105                	addi	sp,sp,32
    80003dd6:	8082                	ret

0000000080003dd8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003dd8:	1101                	addi	sp,sp,-32
    80003dda:	ec06                	sd	ra,24(sp)
    80003ddc:	e822                	sd	s0,16(sp)
    80003dde:	e426                	sd	s1,8(sp)
    80003de0:	e04a                	sd	s2,0(sp)
    80003de2:	1000                	addi	s0,sp,32
    80003de4:	84aa                	mv	s1,a0
    80003de6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003de8:	00004597          	auipc	a1,0x4
    80003dec:	86858593          	addi	a1,a1,-1944 # 80007650 <etext+0x650>
    80003df0:	0521                	addi	a0,a0,8
    80003df2:	d89fc0ef          	jal	80000b7a <initlock>
  lk->name = name;
    80003df6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003dfa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003dfe:	0204a423          	sw	zero,40(s1)
}
    80003e02:	60e2                	ld	ra,24(sp)
    80003e04:	6442                	ld	s0,16(sp)
    80003e06:	64a2                	ld	s1,8(sp)
    80003e08:	6902                	ld	s2,0(sp)
    80003e0a:	6105                	addi	sp,sp,32
    80003e0c:	8082                	ret

0000000080003e0e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e0e:	1101                	addi	sp,sp,-32
    80003e10:	ec06                	sd	ra,24(sp)
    80003e12:	e822                	sd	s0,16(sp)
    80003e14:	e426                	sd	s1,8(sp)
    80003e16:	e04a                	sd	s2,0(sp)
    80003e18:	1000                	addi	s0,sp,32
    80003e1a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e1c:	00850913          	addi	s2,a0,8
    80003e20:	854a                	mv	a0,s2
    80003e22:	dddfc0ef          	jal	80000bfe <acquire>
  while (lk->locked) {
    80003e26:	409c                	lw	a5,0(s1)
    80003e28:	c799                	beqz	a5,80003e36 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003e2a:	85ca                	mv	a1,s2
    80003e2c:	8526                	mv	a0,s1
    80003e2e:	8d0fe0ef          	jal	80001efe <sleep>
  while (lk->locked) {
    80003e32:	409c                	lw	a5,0(s1)
    80003e34:	fbfd                	bnez	a5,80003e2a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003e36:	4785                	li	a5,1
    80003e38:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003e3a:	aa3fd0ef          	jal	800018dc <myproc>
    80003e3e:	591c                	lw	a5,48(a0)
    80003e40:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003e42:	854a                	mv	a0,s2
    80003e44:	e4ffc0ef          	jal	80000c92 <release>
}
    80003e48:	60e2                	ld	ra,24(sp)
    80003e4a:	6442                	ld	s0,16(sp)
    80003e4c:	64a2                	ld	s1,8(sp)
    80003e4e:	6902                	ld	s2,0(sp)
    80003e50:	6105                	addi	sp,sp,32
    80003e52:	8082                	ret

0000000080003e54 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003e54:	1101                	addi	sp,sp,-32
    80003e56:	ec06                	sd	ra,24(sp)
    80003e58:	e822                	sd	s0,16(sp)
    80003e5a:	e426                	sd	s1,8(sp)
    80003e5c:	e04a                	sd	s2,0(sp)
    80003e5e:	1000                	addi	s0,sp,32
    80003e60:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e62:	00850913          	addi	s2,a0,8
    80003e66:	854a                	mv	a0,s2
    80003e68:	d97fc0ef          	jal	80000bfe <acquire>
  lk->locked = 0;
    80003e6c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e70:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003e74:	8526                	mv	a0,s1
    80003e76:	8d4fe0ef          	jal	80001f4a <wakeup>
  release(&lk->lk);
    80003e7a:	854a                	mv	a0,s2
    80003e7c:	e17fc0ef          	jal	80000c92 <release>
}
    80003e80:	60e2                	ld	ra,24(sp)
    80003e82:	6442                	ld	s0,16(sp)
    80003e84:	64a2                	ld	s1,8(sp)
    80003e86:	6902                	ld	s2,0(sp)
    80003e88:	6105                	addi	sp,sp,32
    80003e8a:	8082                	ret

0000000080003e8c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003e8c:	7179                	addi	sp,sp,-48
    80003e8e:	f406                	sd	ra,40(sp)
    80003e90:	f022                	sd	s0,32(sp)
    80003e92:	ec26                	sd	s1,24(sp)
    80003e94:	e84a                	sd	s2,16(sp)
    80003e96:	1800                	addi	s0,sp,48
    80003e98:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003e9a:	00850913          	addi	s2,a0,8
    80003e9e:	854a                	mv	a0,s2
    80003ea0:	d5ffc0ef          	jal	80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ea4:	409c                	lw	a5,0(s1)
    80003ea6:	ef81                	bnez	a5,80003ebe <holdingsleep+0x32>
    80003ea8:	4481                	li	s1,0
  release(&lk->lk);
    80003eaa:	854a                	mv	a0,s2
    80003eac:	de7fc0ef          	jal	80000c92 <release>
  return r;
}
    80003eb0:	8526                	mv	a0,s1
    80003eb2:	70a2                	ld	ra,40(sp)
    80003eb4:	7402                	ld	s0,32(sp)
    80003eb6:	64e2                	ld	s1,24(sp)
    80003eb8:	6942                	ld	s2,16(sp)
    80003eba:	6145                	addi	sp,sp,48
    80003ebc:	8082                	ret
    80003ebe:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ec0:	0284a983          	lw	s3,40(s1)
    80003ec4:	a19fd0ef          	jal	800018dc <myproc>
    80003ec8:	5904                	lw	s1,48(a0)
    80003eca:	413484b3          	sub	s1,s1,s3
    80003ece:	0014b493          	seqz	s1,s1
    80003ed2:	69a2                	ld	s3,8(sp)
    80003ed4:	bfd9                	j	80003eaa <holdingsleep+0x1e>

0000000080003ed6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003ed6:	1141                	addi	sp,sp,-16
    80003ed8:	e406                	sd	ra,8(sp)
    80003eda:	e022                	sd	s0,0(sp)
    80003edc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003ede:	00003597          	auipc	a1,0x3
    80003ee2:	78258593          	addi	a1,a1,1922 # 80007660 <etext+0x660>
    80003ee6:	00024517          	auipc	a0,0x24
    80003eea:	7c250513          	addi	a0,a0,1986 # 800286a8 <ftable>
    80003eee:	c8dfc0ef          	jal	80000b7a <initlock>
}
    80003ef2:	60a2                	ld	ra,8(sp)
    80003ef4:	6402                	ld	s0,0(sp)
    80003ef6:	0141                	addi	sp,sp,16
    80003ef8:	8082                	ret

0000000080003efa <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003efa:	1101                	addi	sp,sp,-32
    80003efc:	ec06                	sd	ra,24(sp)
    80003efe:	e822                	sd	s0,16(sp)
    80003f00:	e426                	sd	s1,8(sp)
    80003f02:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f04:	00024517          	auipc	a0,0x24
    80003f08:	7a450513          	addi	a0,a0,1956 # 800286a8 <ftable>
    80003f0c:	cf3fc0ef          	jal	80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f10:	00024497          	auipc	s1,0x24
    80003f14:	7b048493          	addi	s1,s1,1968 # 800286c0 <ftable+0x18>
    80003f18:	00025717          	auipc	a4,0x25
    80003f1c:	74870713          	addi	a4,a4,1864 # 80029660 <disk>
    if(f->ref == 0){
    80003f20:	40dc                	lw	a5,4(s1)
    80003f22:	cf89                	beqz	a5,80003f3c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f24:	02848493          	addi	s1,s1,40
    80003f28:	fee49ce3          	bne	s1,a4,80003f20 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003f2c:	00024517          	auipc	a0,0x24
    80003f30:	77c50513          	addi	a0,a0,1916 # 800286a8 <ftable>
    80003f34:	d5ffc0ef          	jal	80000c92 <release>
  return 0;
    80003f38:	4481                	li	s1,0
    80003f3a:	a809                	j	80003f4c <filealloc+0x52>
      f->ref = 1;
    80003f3c:	4785                	li	a5,1
    80003f3e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003f40:	00024517          	auipc	a0,0x24
    80003f44:	76850513          	addi	a0,a0,1896 # 800286a8 <ftable>
    80003f48:	d4bfc0ef          	jal	80000c92 <release>
}
    80003f4c:	8526                	mv	a0,s1
    80003f4e:	60e2                	ld	ra,24(sp)
    80003f50:	6442                	ld	s0,16(sp)
    80003f52:	64a2                	ld	s1,8(sp)
    80003f54:	6105                	addi	sp,sp,32
    80003f56:	8082                	ret

0000000080003f58 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003f58:	1101                	addi	sp,sp,-32
    80003f5a:	ec06                	sd	ra,24(sp)
    80003f5c:	e822                	sd	s0,16(sp)
    80003f5e:	e426                	sd	s1,8(sp)
    80003f60:	1000                	addi	s0,sp,32
    80003f62:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003f64:	00024517          	auipc	a0,0x24
    80003f68:	74450513          	addi	a0,a0,1860 # 800286a8 <ftable>
    80003f6c:	c93fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003f70:	40dc                	lw	a5,4(s1)
    80003f72:	02f05063          	blez	a5,80003f92 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003f76:	2785                	addiw	a5,a5,1
    80003f78:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003f7a:	00024517          	auipc	a0,0x24
    80003f7e:	72e50513          	addi	a0,a0,1838 # 800286a8 <ftable>
    80003f82:	d11fc0ef          	jal	80000c92 <release>
  return f;
}
    80003f86:	8526                	mv	a0,s1
    80003f88:	60e2                	ld	ra,24(sp)
    80003f8a:	6442                	ld	s0,16(sp)
    80003f8c:	64a2                	ld	s1,8(sp)
    80003f8e:	6105                	addi	sp,sp,32
    80003f90:	8082                	ret
    panic("filedup");
    80003f92:	00003517          	auipc	a0,0x3
    80003f96:	6d650513          	addi	a0,a0,1750 # 80007668 <etext+0x668>
    80003f9a:	805fc0ef          	jal	8000079e <panic>

0000000080003f9e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003f9e:	7139                	addi	sp,sp,-64
    80003fa0:	fc06                	sd	ra,56(sp)
    80003fa2:	f822                	sd	s0,48(sp)
    80003fa4:	f426                	sd	s1,40(sp)
    80003fa6:	0080                	addi	s0,sp,64
    80003fa8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003faa:	00024517          	auipc	a0,0x24
    80003fae:	6fe50513          	addi	a0,a0,1790 # 800286a8 <ftable>
    80003fb2:	c4dfc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003fb6:	40dc                	lw	a5,4(s1)
    80003fb8:	04f05863          	blez	a5,80004008 <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    80003fbc:	37fd                	addiw	a5,a5,-1
    80003fbe:	c0dc                	sw	a5,4(s1)
    80003fc0:	04f04e63          	bgtz	a5,8000401c <fileclose+0x7e>
    80003fc4:	f04a                	sd	s2,32(sp)
    80003fc6:	ec4e                	sd	s3,24(sp)
    80003fc8:	e852                	sd	s4,16(sp)
    80003fca:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003fcc:	0004a903          	lw	s2,0(s1)
    80003fd0:	0094ca83          	lbu	s5,9(s1)
    80003fd4:	0104ba03          	ld	s4,16(s1)
    80003fd8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003fdc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003fe0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003fe4:	00024517          	auipc	a0,0x24
    80003fe8:	6c450513          	addi	a0,a0,1732 # 800286a8 <ftable>
    80003fec:	ca7fc0ef          	jal	80000c92 <release>

  if(ff.type == FD_PIPE){
    80003ff0:	4785                	li	a5,1
    80003ff2:	04f90063          	beq	s2,a5,80004032 <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003ff6:	3979                	addiw	s2,s2,-2
    80003ff8:	4785                	li	a5,1
    80003ffa:	0527f563          	bgeu	a5,s2,80004044 <fileclose+0xa6>
    80003ffe:	7902                	ld	s2,32(sp)
    80004000:	69e2                	ld	s3,24(sp)
    80004002:	6a42                	ld	s4,16(sp)
    80004004:	6aa2                	ld	s5,8(sp)
    80004006:	a00d                	j	80004028 <fileclose+0x8a>
    80004008:	f04a                	sd	s2,32(sp)
    8000400a:	ec4e                	sd	s3,24(sp)
    8000400c:	e852                	sd	s4,16(sp)
    8000400e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004010:	00003517          	auipc	a0,0x3
    80004014:	66050513          	addi	a0,a0,1632 # 80007670 <etext+0x670>
    80004018:	f86fc0ef          	jal	8000079e <panic>
    release(&ftable.lock);
    8000401c:	00024517          	auipc	a0,0x24
    80004020:	68c50513          	addi	a0,a0,1676 # 800286a8 <ftable>
    80004024:	c6ffc0ef          	jal	80000c92 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004028:	70e2                	ld	ra,56(sp)
    8000402a:	7442                	ld	s0,48(sp)
    8000402c:	74a2                	ld	s1,40(sp)
    8000402e:	6121                	addi	sp,sp,64
    80004030:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004032:	85d6                	mv	a1,s5
    80004034:	8552                	mv	a0,s4
    80004036:	340000ef          	jal	80004376 <pipeclose>
    8000403a:	7902                	ld	s2,32(sp)
    8000403c:	69e2                	ld	s3,24(sp)
    8000403e:	6a42                	ld	s4,16(sp)
    80004040:	6aa2                	ld	s5,8(sp)
    80004042:	b7dd                	j	80004028 <fileclose+0x8a>
    begin_op();
    80004044:	b3bff0ef          	jal	80003b7e <begin_op>
    iput(ff.ip);
    80004048:	854e                	mv	a0,s3
    8000404a:	c04ff0ef          	jal	8000344e <iput>
    end_op();
    8000404e:	b9bff0ef          	jal	80003be8 <end_op>
    80004052:	7902                	ld	s2,32(sp)
    80004054:	69e2                	ld	s3,24(sp)
    80004056:	6a42                	ld	s4,16(sp)
    80004058:	6aa2                	ld	s5,8(sp)
    8000405a:	b7f9                	j	80004028 <fileclose+0x8a>

000000008000405c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000405c:	715d                	addi	sp,sp,-80
    8000405e:	e486                	sd	ra,72(sp)
    80004060:	e0a2                	sd	s0,64(sp)
    80004062:	fc26                	sd	s1,56(sp)
    80004064:	f44e                	sd	s3,40(sp)
    80004066:	0880                	addi	s0,sp,80
    80004068:	84aa                	mv	s1,a0
    8000406a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000406c:	871fd0ef          	jal	800018dc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004070:	409c                	lw	a5,0(s1)
    80004072:	37f9                	addiw	a5,a5,-2
    80004074:	4705                	li	a4,1
    80004076:	04f76263          	bltu	a4,a5,800040ba <filestat+0x5e>
    8000407a:	f84a                	sd	s2,48(sp)
    8000407c:	f052                	sd	s4,32(sp)
    8000407e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004080:	6c88                	ld	a0,24(s1)
    80004082:	a4aff0ef          	jal	800032cc <ilock>
    stati(f->ip, &st);
    80004086:	fb840a13          	addi	s4,s0,-72
    8000408a:	85d2                	mv	a1,s4
    8000408c:	6c88                	ld	a0,24(s1)
    8000408e:	c68ff0ef          	jal	800034f6 <stati>
    iunlock(f->ip);
    80004092:	6c88                	ld	a0,24(s1)
    80004094:	ae6ff0ef          	jal	8000337a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004098:	46e1                	li	a3,24
    8000409a:	8652                	mv	a2,s4
    8000409c:	85ce                	mv	a1,s3
    8000409e:	05093503          	ld	a0,80(s2)
    800040a2:	ce2fd0ef          	jal	80001584 <copyout>
    800040a6:	41f5551b          	sraiw	a0,a0,0x1f
    800040aa:	7942                	ld	s2,48(sp)
    800040ac:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800040ae:	60a6                	ld	ra,72(sp)
    800040b0:	6406                	ld	s0,64(sp)
    800040b2:	74e2                	ld	s1,56(sp)
    800040b4:	79a2                	ld	s3,40(sp)
    800040b6:	6161                	addi	sp,sp,80
    800040b8:	8082                	ret
  return -1;
    800040ba:	557d                	li	a0,-1
    800040bc:	bfcd                	j	800040ae <filestat+0x52>

00000000800040be <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800040be:	7179                	addi	sp,sp,-48
    800040c0:	f406                	sd	ra,40(sp)
    800040c2:	f022                	sd	s0,32(sp)
    800040c4:	e84a                	sd	s2,16(sp)
    800040c6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800040c8:	00854783          	lbu	a5,8(a0)
    800040cc:	cfd1                	beqz	a5,80004168 <fileread+0xaa>
    800040ce:	ec26                	sd	s1,24(sp)
    800040d0:	e44e                	sd	s3,8(sp)
    800040d2:	84aa                	mv	s1,a0
    800040d4:	89ae                	mv	s3,a1
    800040d6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800040d8:	411c                	lw	a5,0(a0)
    800040da:	4705                	li	a4,1
    800040dc:	04e78363          	beq	a5,a4,80004122 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800040e0:	470d                	li	a4,3
    800040e2:	04e78763          	beq	a5,a4,80004130 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800040e6:	4709                	li	a4,2
    800040e8:	06e79a63          	bne	a5,a4,8000415c <fileread+0x9e>
    ilock(f->ip);
    800040ec:	6d08                	ld	a0,24(a0)
    800040ee:	9deff0ef          	jal	800032cc <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800040f2:	874a                	mv	a4,s2
    800040f4:	5094                	lw	a3,32(s1)
    800040f6:	864e                	mv	a2,s3
    800040f8:	4585                	li	a1,1
    800040fa:	6c88                	ld	a0,24(s1)
    800040fc:	c28ff0ef          	jal	80003524 <readi>
    80004100:	892a                	mv	s2,a0
    80004102:	00a05563          	blez	a0,8000410c <fileread+0x4e>
      f->off += r;
    80004106:	509c                	lw	a5,32(s1)
    80004108:	9fa9                	addw	a5,a5,a0
    8000410a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000410c:	6c88                	ld	a0,24(s1)
    8000410e:	a6cff0ef          	jal	8000337a <iunlock>
    80004112:	64e2                	ld	s1,24(sp)
    80004114:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004116:	854a                	mv	a0,s2
    80004118:	70a2                	ld	ra,40(sp)
    8000411a:	7402                	ld	s0,32(sp)
    8000411c:	6942                	ld	s2,16(sp)
    8000411e:	6145                	addi	sp,sp,48
    80004120:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004122:	6908                	ld	a0,16(a0)
    80004124:	3a2000ef          	jal	800044c6 <piperead>
    80004128:	892a                	mv	s2,a0
    8000412a:	64e2                	ld	s1,24(sp)
    8000412c:	69a2                	ld	s3,8(sp)
    8000412e:	b7e5                	j	80004116 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004130:	02451783          	lh	a5,36(a0)
    80004134:	03079693          	slli	a3,a5,0x30
    80004138:	92c1                	srli	a3,a3,0x30
    8000413a:	4725                	li	a4,9
    8000413c:	02d76863          	bltu	a4,a3,8000416c <fileread+0xae>
    80004140:	0792                	slli	a5,a5,0x4
    80004142:	00024717          	auipc	a4,0x24
    80004146:	4c670713          	addi	a4,a4,1222 # 80028608 <devsw>
    8000414a:	97ba                	add	a5,a5,a4
    8000414c:	639c                	ld	a5,0(a5)
    8000414e:	c39d                	beqz	a5,80004174 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004150:	4505                	li	a0,1
    80004152:	9782                	jalr	a5
    80004154:	892a                	mv	s2,a0
    80004156:	64e2                	ld	s1,24(sp)
    80004158:	69a2                	ld	s3,8(sp)
    8000415a:	bf75                	j	80004116 <fileread+0x58>
    panic("fileread");
    8000415c:	00003517          	auipc	a0,0x3
    80004160:	52450513          	addi	a0,a0,1316 # 80007680 <etext+0x680>
    80004164:	e3afc0ef          	jal	8000079e <panic>
    return -1;
    80004168:	597d                	li	s2,-1
    8000416a:	b775                	j	80004116 <fileread+0x58>
      return -1;
    8000416c:	597d                	li	s2,-1
    8000416e:	64e2                	ld	s1,24(sp)
    80004170:	69a2                	ld	s3,8(sp)
    80004172:	b755                	j	80004116 <fileread+0x58>
    80004174:	597d                	li	s2,-1
    80004176:	64e2                	ld	s1,24(sp)
    80004178:	69a2                	ld	s3,8(sp)
    8000417a:	bf71                	j	80004116 <fileread+0x58>

000000008000417c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000417c:	00954783          	lbu	a5,9(a0)
    80004180:	10078e63          	beqz	a5,8000429c <filewrite+0x120>
{
    80004184:	711d                	addi	sp,sp,-96
    80004186:	ec86                	sd	ra,88(sp)
    80004188:	e8a2                	sd	s0,80(sp)
    8000418a:	e0ca                	sd	s2,64(sp)
    8000418c:	f456                	sd	s5,40(sp)
    8000418e:	f05a                	sd	s6,32(sp)
    80004190:	1080                	addi	s0,sp,96
    80004192:	892a                	mv	s2,a0
    80004194:	8b2e                	mv	s6,a1
    80004196:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004198:	411c                	lw	a5,0(a0)
    8000419a:	4705                	li	a4,1
    8000419c:	02e78963          	beq	a5,a4,800041ce <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800041a0:	470d                	li	a4,3
    800041a2:	02e78a63          	beq	a5,a4,800041d6 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800041a6:	4709                	li	a4,2
    800041a8:	0ce79e63          	bne	a5,a4,80004284 <filewrite+0x108>
    800041ac:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800041ae:	0ac05963          	blez	a2,80004260 <filewrite+0xe4>
    800041b2:	e4a6                	sd	s1,72(sp)
    800041b4:	fc4e                	sd	s3,56(sp)
    800041b6:	ec5e                	sd	s7,24(sp)
    800041b8:	e862                	sd	s8,16(sp)
    800041ba:	e466                	sd	s9,8(sp)
    int i = 0;
    800041bc:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800041be:	6b85                	lui	s7,0x1
    800041c0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800041c4:	6c85                	lui	s9,0x1
    800041c6:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800041ca:	4c05                	li	s8,1
    800041cc:	a8ad                	j	80004246 <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    800041ce:	6908                	ld	a0,16(a0)
    800041d0:	1fe000ef          	jal	800043ce <pipewrite>
    800041d4:	a04d                	j	80004276 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800041d6:	02451783          	lh	a5,36(a0)
    800041da:	03079693          	slli	a3,a5,0x30
    800041de:	92c1                	srli	a3,a3,0x30
    800041e0:	4725                	li	a4,9
    800041e2:	0ad76f63          	bltu	a4,a3,800042a0 <filewrite+0x124>
    800041e6:	0792                	slli	a5,a5,0x4
    800041e8:	00024717          	auipc	a4,0x24
    800041ec:	42070713          	addi	a4,a4,1056 # 80028608 <devsw>
    800041f0:	97ba                	add	a5,a5,a4
    800041f2:	679c                	ld	a5,8(a5)
    800041f4:	cbc5                	beqz	a5,800042a4 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    800041f6:	4505                	li	a0,1
    800041f8:	9782                	jalr	a5
    800041fa:	a8b5                	j	80004276 <filewrite+0xfa>
      if(n1 > max)
    800041fc:	2981                	sext.w	s3,s3
      begin_op();
    800041fe:	981ff0ef          	jal	80003b7e <begin_op>
      ilock(f->ip);
    80004202:	01893503          	ld	a0,24(s2)
    80004206:	8c6ff0ef          	jal	800032cc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000420a:	874e                	mv	a4,s3
    8000420c:	02092683          	lw	a3,32(s2)
    80004210:	016a0633          	add	a2,s4,s6
    80004214:	85e2                	mv	a1,s8
    80004216:	01893503          	ld	a0,24(s2)
    8000421a:	bfcff0ef          	jal	80003616 <writei>
    8000421e:	84aa                	mv	s1,a0
    80004220:	00a05763          	blez	a0,8000422e <filewrite+0xb2>
        f->off += r;
    80004224:	02092783          	lw	a5,32(s2)
    80004228:	9fa9                	addw	a5,a5,a0
    8000422a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000422e:	01893503          	ld	a0,24(s2)
    80004232:	948ff0ef          	jal	8000337a <iunlock>
      end_op();
    80004236:	9b3ff0ef          	jal	80003be8 <end_op>

      if(r != n1){
    8000423a:	02999563          	bne	s3,s1,80004264 <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    8000423e:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004242:	015a5963          	bge	s4,s5,80004254 <filewrite+0xd8>
      int n1 = n - i;
    80004246:	414a87bb          	subw	a5,s5,s4
    8000424a:	89be                	mv	s3,a5
      if(n1 > max)
    8000424c:	fafbd8e3          	bge	s7,a5,800041fc <filewrite+0x80>
    80004250:	89e6                	mv	s3,s9
    80004252:	b76d                	j	800041fc <filewrite+0x80>
    80004254:	64a6                	ld	s1,72(sp)
    80004256:	79e2                	ld	s3,56(sp)
    80004258:	6be2                	ld	s7,24(sp)
    8000425a:	6c42                	ld	s8,16(sp)
    8000425c:	6ca2                	ld	s9,8(sp)
    8000425e:	a801                	j	8000426e <filewrite+0xf2>
    int i = 0;
    80004260:	4a01                	li	s4,0
    80004262:	a031                	j	8000426e <filewrite+0xf2>
    80004264:	64a6                	ld	s1,72(sp)
    80004266:	79e2                	ld	s3,56(sp)
    80004268:	6be2                	ld	s7,24(sp)
    8000426a:	6c42                	ld	s8,16(sp)
    8000426c:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    8000426e:	034a9d63          	bne	s5,s4,800042a8 <filewrite+0x12c>
    80004272:	8556                	mv	a0,s5
    80004274:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004276:	60e6                	ld	ra,88(sp)
    80004278:	6446                	ld	s0,80(sp)
    8000427a:	6906                	ld	s2,64(sp)
    8000427c:	7aa2                	ld	s5,40(sp)
    8000427e:	7b02                	ld	s6,32(sp)
    80004280:	6125                	addi	sp,sp,96
    80004282:	8082                	ret
    80004284:	e4a6                	sd	s1,72(sp)
    80004286:	fc4e                	sd	s3,56(sp)
    80004288:	f852                	sd	s4,48(sp)
    8000428a:	ec5e                	sd	s7,24(sp)
    8000428c:	e862                	sd	s8,16(sp)
    8000428e:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004290:	00003517          	auipc	a0,0x3
    80004294:	40050513          	addi	a0,a0,1024 # 80007690 <etext+0x690>
    80004298:	d06fc0ef          	jal	8000079e <panic>
    return -1;
    8000429c:	557d                	li	a0,-1
}
    8000429e:	8082                	ret
      return -1;
    800042a0:	557d                	li	a0,-1
    800042a2:	bfd1                	j	80004276 <filewrite+0xfa>
    800042a4:	557d                	li	a0,-1
    800042a6:	bfc1                	j	80004276 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    800042a8:	557d                	li	a0,-1
    800042aa:	7a42                	ld	s4,48(sp)
    800042ac:	b7e9                	j	80004276 <filewrite+0xfa>

00000000800042ae <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800042ae:	7179                	addi	sp,sp,-48
    800042b0:	f406                	sd	ra,40(sp)
    800042b2:	f022                	sd	s0,32(sp)
    800042b4:	ec26                	sd	s1,24(sp)
    800042b6:	e052                	sd	s4,0(sp)
    800042b8:	1800                	addi	s0,sp,48
    800042ba:	84aa                	mv	s1,a0
    800042bc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800042be:	0005b023          	sd	zero,0(a1)
    800042c2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800042c6:	c35ff0ef          	jal	80003efa <filealloc>
    800042ca:	e088                	sd	a0,0(s1)
    800042cc:	c549                	beqz	a0,80004356 <pipealloc+0xa8>
    800042ce:	c2dff0ef          	jal	80003efa <filealloc>
    800042d2:	00aa3023          	sd	a0,0(s4)
    800042d6:	cd25                	beqz	a0,8000434e <pipealloc+0xa0>
    800042d8:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800042da:	851fc0ef          	jal	80000b2a <kalloc>
    800042de:	892a                	mv	s2,a0
    800042e0:	c12d                	beqz	a0,80004342 <pipealloc+0x94>
    800042e2:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800042e4:	4985                	li	s3,1
    800042e6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800042ea:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800042ee:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800042f2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800042f6:	00003597          	auipc	a1,0x3
    800042fa:	00a58593          	addi	a1,a1,10 # 80007300 <etext+0x300>
    800042fe:	87dfc0ef          	jal	80000b7a <initlock>
  (*f0)->type = FD_PIPE;
    80004302:	609c                	ld	a5,0(s1)
    80004304:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004308:	609c                	ld	a5,0(s1)
    8000430a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000430e:	609c                	ld	a5,0(s1)
    80004310:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004314:	609c                	ld	a5,0(s1)
    80004316:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000431a:	000a3783          	ld	a5,0(s4)
    8000431e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004322:	000a3783          	ld	a5,0(s4)
    80004326:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000432a:	000a3783          	ld	a5,0(s4)
    8000432e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004332:	000a3783          	ld	a5,0(s4)
    80004336:	0127b823          	sd	s2,16(a5)
  return 0;
    8000433a:	4501                	li	a0,0
    8000433c:	6942                	ld	s2,16(sp)
    8000433e:	69a2                	ld	s3,8(sp)
    80004340:	a01d                	j	80004366 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004342:	6088                	ld	a0,0(s1)
    80004344:	c119                	beqz	a0,8000434a <pipealloc+0x9c>
    80004346:	6942                	ld	s2,16(sp)
    80004348:	a029                	j	80004352 <pipealloc+0xa4>
    8000434a:	6942                	ld	s2,16(sp)
    8000434c:	a029                	j	80004356 <pipealloc+0xa8>
    8000434e:	6088                	ld	a0,0(s1)
    80004350:	c10d                	beqz	a0,80004372 <pipealloc+0xc4>
    fileclose(*f0);
    80004352:	c4dff0ef          	jal	80003f9e <fileclose>
  if(*f1)
    80004356:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000435a:	557d                	li	a0,-1
  if(*f1)
    8000435c:	c789                	beqz	a5,80004366 <pipealloc+0xb8>
    fileclose(*f1);
    8000435e:	853e                	mv	a0,a5
    80004360:	c3fff0ef          	jal	80003f9e <fileclose>
  return -1;
    80004364:	557d                	li	a0,-1
}
    80004366:	70a2                	ld	ra,40(sp)
    80004368:	7402                	ld	s0,32(sp)
    8000436a:	64e2                	ld	s1,24(sp)
    8000436c:	6a02                	ld	s4,0(sp)
    8000436e:	6145                	addi	sp,sp,48
    80004370:	8082                	ret
  return -1;
    80004372:	557d                	li	a0,-1
    80004374:	bfcd                	j	80004366 <pipealloc+0xb8>

0000000080004376 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004376:	1101                	addi	sp,sp,-32
    80004378:	ec06                	sd	ra,24(sp)
    8000437a:	e822                	sd	s0,16(sp)
    8000437c:	e426                	sd	s1,8(sp)
    8000437e:	e04a                	sd	s2,0(sp)
    80004380:	1000                	addi	s0,sp,32
    80004382:	84aa                	mv	s1,a0
    80004384:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004386:	879fc0ef          	jal	80000bfe <acquire>
  if(writable){
    8000438a:	02090763          	beqz	s2,800043b8 <pipeclose+0x42>
    pi->writeopen = 0;
    8000438e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004392:	21848513          	addi	a0,s1,536
    80004396:	bb5fd0ef          	jal	80001f4a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000439a:	2204b783          	ld	a5,544(s1)
    8000439e:	e785                	bnez	a5,800043c6 <pipeclose+0x50>
    release(&pi->lock);
    800043a0:	8526                	mv	a0,s1
    800043a2:	8f1fc0ef          	jal	80000c92 <release>
    kfree((char*)pi);
    800043a6:	8526                	mv	a0,s1
    800043a8:	ea0fc0ef          	jal	80000a48 <kfree>
  } else
    release(&pi->lock);
}
    800043ac:	60e2                	ld	ra,24(sp)
    800043ae:	6442                	ld	s0,16(sp)
    800043b0:	64a2                	ld	s1,8(sp)
    800043b2:	6902                	ld	s2,0(sp)
    800043b4:	6105                	addi	sp,sp,32
    800043b6:	8082                	ret
    pi->readopen = 0;
    800043b8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800043bc:	21c48513          	addi	a0,s1,540
    800043c0:	b8bfd0ef          	jal	80001f4a <wakeup>
    800043c4:	bfd9                	j	8000439a <pipeclose+0x24>
    release(&pi->lock);
    800043c6:	8526                	mv	a0,s1
    800043c8:	8cbfc0ef          	jal	80000c92 <release>
}
    800043cc:	b7c5                	j	800043ac <pipeclose+0x36>

00000000800043ce <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800043ce:	7159                	addi	sp,sp,-112
    800043d0:	f486                	sd	ra,104(sp)
    800043d2:	f0a2                	sd	s0,96(sp)
    800043d4:	eca6                	sd	s1,88(sp)
    800043d6:	e8ca                	sd	s2,80(sp)
    800043d8:	e4ce                	sd	s3,72(sp)
    800043da:	e0d2                	sd	s4,64(sp)
    800043dc:	fc56                	sd	s5,56(sp)
    800043de:	1880                	addi	s0,sp,112
    800043e0:	84aa                	mv	s1,a0
    800043e2:	8aae                	mv	s5,a1
    800043e4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800043e6:	cf6fd0ef          	jal	800018dc <myproc>
    800043ea:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800043ec:	8526                	mv	a0,s1
    800043ee:	811fc0ef          	jal	80000bfe <acquire>
  while(i < n){
    800043f2:	0d405263          	blez	s4,800044b6 <pipewrite+0xe8>
    800043f6:	f85a                	sd	s6,48(sp)
    800043f8:	f45e                	sd	s7,40(sp)
    800043fa:	f062                	sd	s8,32(sp)
    800043fc:	ec66                	sd	s9,24(sp)
    800043fe:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004400:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004402:	f9f40c13          	addi	s8,s0,-97
    80004406:	4b85                	li	s7,1
    80004408:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000440a:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000440e:	21c48c93          	addi	s9,s1,540
    80004412:	a82d                	j	8000444c <pipewrite+0x7e>
      release(&pi->lock);
    80004414:	8526                	mv	a0,s1
    80004416:	87dfc0ef          	jal	80000c92 <release>
      return -1;
    8000441a:	597d                	li	s2,-1
    8000441c:	7b42                	ld	s6,48(sp)
    8000441e:	7ba2                	ld	s7,40(sp)
    80004420:	7c02                	ld	s8,32(sp)
    80004422:	6ce2                	ld	s9,24(sp)
    80004424:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004426:	854a                	mv	a0,s2
    80004428:	70a6                	ld	ra,104(sp)
    8000442a:	7406                	ld	s0,96(sp)
    8000442c:	64e6                	ld	s1,88(sp)
    8000442e:	6946                	ld	s2,80(sp)
    80004430:	69a6                	ld	s3,72(sp)
    80004432:	6a06                	ld	s4,64(sp)
    80004434:	7ae2                	ld	s5,56(sp)
    80004436:	6165                	addi	sp,sp,112
    80004438:	8082                	ret
      wakeup(&pi->nread);
    8000443a:	856a                	mv	a0,s10
    8000443c:	b0ffd0ef          	jal	80001f4a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004440:	85a6                	mv	a1,s1
    80004442:	8566                	mv	a0,s9
    80004444:	abbfd0ef          	jal	80001efe <sleep>
  while(i < n){
    80004448:	05495a63          	bge	s2,s4,8000449c <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000444c:	2204a783          	lw	a5,544(s1)
    80004450:	d3f1                	beqz	a5,80004414 <pipewrite+0x46>
    80004452:	854e                	mv	a0,s3
    80004454:	ce3fd0ef          	jal	80002136 <killed>
    80004458:	fd55                	bnez	a0,80004414 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000445a:	2184a783          	lw	a5,536(s1)
    8000445e:	21c4a703          	lw	a4,540(s1)
    80004462:	2007879b          	addiw	a5,a5,512
    80004466:	fcf70ae3          	beq	a4,a5,8000443a <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000446a:	86de                	mv	a3,s7
    8000446c:	01590633          	add	a2,s2,s5
    80004470:	85e2                	mv	a1,s8
    80004472:	0509b503          	ld	a0,80(s3)
    80004476:	9befd0ef          	jal	80001634 <copyin>
    8000447a:	05650063          	beq	a0,s6,800044ba <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000447e:	21c4a783          	lw	a5,540(s1)
    80004482:	0017871b          	addiw	a4,a5,1
    80004486:	20e4ae23          	sw	a4,540(s1)
    8000448a:	1ff7f793          	andi	a5,a5,511
    8000448e:	97a6                	add	a5,a5,s1
    80004490:	f9f44703          	lbu	a4,-97(s0)
    80004494:	00e78c23          	sb	a4,24(a5)
      i++;
    80004498:	2905                	addiw	s2,s2,1
    8000449a:	b77d                	j	80004448 <pipewrite+0x7a>
    8000449c:	7b42                	ld	s6,48(sp)
    8000449e:	7ba2                	ld	s7,40(sp)
    800044a0:	7c02                	ld	s8,32(sp)
    800044a2:	6ce2                	ld	s9,24(sp)
    800044a4:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800044a6:	21848513          	addi	a0,s1,536
    800044aa:	aa1fd0ef          	jal	80001f4a <wakeup>
  release(&pi->lock);
    800044ae:	8526                	mv	a0,s1
    800044b0:	fe2fc0ef          	jal	80000c92 <release>
  return i;
    800044b4:	bf8d                	j	80004426 <pipewrite+0x58>
  int i = 0;
    800044b6:	4901                	li	s2,0
    800044b8:	b7fd                	j	800044a6 <pipewrite+0xd8>
    800044ba:	7b42                	ld	s6,48(sp)
    800044bc:	7ba2                	ld	s7,40(sp)
    800044be:	7c02                	ld	s8,32(sp)
    800044c0:	6ce2                	ld	s9,24(sp)
    800044c2:	6d42                	ld	s10,16(sp)
    800044c4:	b7cd                	j	800044a6 <pipewrite+0xd8>

00000000800044c6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800044c6:	711d                	addi	sp,sp,-96
    800044c8:	ec86                	sd	ra,88(sp)
    800044ca:	e8a2                	sd	s0,80(sp)
    800044cc:	e4a6                	sd	s1,72(sp)
    800044ce:	e0ca                	sd	s2,64(sp)
    800044d0:	fc4e                	sd	s3,56(sp)
    800044d2:	f852                	sd	s4,48(sp)
    800044d4:	f456                	sd	s5,40(sp)
    800044d6:	1080                	addi	s0,sp,96
    800044d8:	84aa                	mv	s1,a0
    800044da:	892e                	mv	s2,a1
    800044dc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800044de:	bfefd0ef          	jal	800018dc <myproc>
    800044e2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800044e4:	8526                	mv	a0,s1
    800044e6:	f18fc0ef          	jal	80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044ea:	2184a703          	lw	a4,536(s1)
    800044ee:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800044f2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044f6:	02f71763          	bne	a4,a5,80004524 <piperead+0x5e>
    800044fa:	2244a783          	lw	a5,548(s1)
    800044fe:	cf85                	beqz	a5,80004536 <piperead+0x70>
    if(killed(pr)){
    80004500:	8552                	mv	a0,s4
    80004502:	c35fd0ef          	jal	80002136 <killed>
    80004506:	e11d                	bnez	a0,8000452c <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004508:	85a6                	mv	a1,s1
    8000450a:	854e                	mv	a0,s3
    8000450c:	9f3fd0ef          	jal	80001efe <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004510:	2184a703          	lw	a4,536(s1)
    80004514:	21c4a783          	lw	a5,540(s1)
    80004518:	fef701e3          	beq	a4,a5,800044fa <piperead+0x34>
    8000451c:	f05a                	sd	s6,32(sp)
    8000451e:	ec5e                	sd	s7,24(sp)
    80004520:	e862                	sd	s8,16(sp)
    80004522:	a829                	j	8000453c <piperead+0x76>
    80004524:	f05a                	sd	s6,32(sp)
    80004526:	ec5e                	sd	s7,24(sp)
    80004528:	e862                	sd	s8,16(sp)
    8000452a:	a809                	j	8000453c <piperead+0x76>
      release(&pi->lock);
    8000452c:	8526                	mv	a0,s1
    8000452e:	f64fc0ef          	jal	80000c92 <release>
      return -1;
    80004532:	59fd                	li	s3,-1
    80004534:	a0a5                	j	8000459c <piperead+0xd6>
    80004536:	f05a                	sd	s6,32(sp)
    80004538:	ec5e                	sd	s7,24(sp)
    8000453a:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000453c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000453e:	faf40c13          	addi	s8,s0,-81
    80004542:	4b85                	li	s7,1
    80004544:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004546:	05505163          	blez	s5,80004588 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    8000454a:	2184a783          	lw	a5,536(s1)
    8000454e:	21c4a703          	lw	a4,540(s1)
    80004552:	02f70b63          	beq	a4,a5,80004588 <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004556:	0017871b          	addiw	a4,a5,1
    8000455a:	20e4ac23          	sw	a4,536(s1)
    8000455e:	1ff7f793          	andi	a5,a5,511
    80004562:	97a6                	add	a5,a5,s1
    80004564:	0187c783          	lbu	a5,24(a5)
    80004568:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000456c:	86de                	mv	a3,s7
    8000456e:	8662                	mv	a2,s8
    80004570:	85ca                	mv	a1,s2
    80004572:	050a3503          	ld	a0,80(s4)
    80004576:	80efd0ef          	jal	80001584 <copyout>
    8000457a:	01650763          	beq	a0,s6,80004588 <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000457e:	2985                	addiw	s3,s3,1
    80004580:	0905                	addi	s2,s2,1
    80004582:	fd3a94e3          	bne	s5,s3,8000454a <piperead+0x84>
    80004586:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004588:	21c48513          	addi	a0,s1,540
    8000458c:	9bffd0ef          	jal	80001f4a <wakeup>
  release(&pi->lock);
    80004590:	8526                	mv	a0,s1
    80004592:	f00fc0ef          	jal	80000c92 <release>
    80004596:	7b02                	ld	s6,32(sp)
    80004598:	6be2                	ld	s7,24(sp)
    8000459a:	6c42                	ld	s8,16(sp)
  return i;
}
    8000459c:	854e                	mv	a0,s3
    8000459e:	60e6                	ld	ra,88(sp)
    800045a0:	6446                	ld	s0,80(sp)
    800045a2:	64a6                	ld	s1,72(sp)
    800045a4:	6906                	ld	s2,64(sp)
    800045a6:	79e2                	ld	s3,56(sp)
    800045a8:	7a42                	ld	s4,48(sp)
    800045aa:	7aa2                	ld	s5,40(sp)
    800045ac:	6125                	addi	sp,sp,96
    800045ae:	8082                	ret

00000000800045b0 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800045b0:	1141                	addi	sp,sp,-16
    800045b2:	e406                	sd	ra,8(sp)
    800045b4:	e022                	sd	s0,0(sp)
    800045b6:	0800                	addi	s0,sp,16
    800045b8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800045ba:	0035151b          	slliw	a0,a0,0x3
    800045be:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800045c0:	8b89                	andi	a5,a5,2
    800045c2:	c399                	beqz	a5,800045c8 <flags2perm+0x18>
      perm |= PTE_W;
    800045c4:	00456513          	ori	a0,a0,4
    return perm;
}
    800045c8:	60a2                	ld	ra,8(sp)
    800045ca:	6402                	ld	s0,0(sp)
    800045cc:	0141                	addi	sp,sp,16
    800045ce:	8082                	ret

00000000800045d0 <exec>:

int
exec(char *path, char **argv)
{
    800045d0:	de010113          	addi	sp,sp,-544
    800045d4:	20113c23          	sd	ra,536(sp)
    800045d8:	20813823          	sd	s0,528(sp)
    800045dc:	20913423          	sd	s1,520(sp)
    800045e0:	21213023          	sd	s2,512(sp)
    800045e4:	1400                	addi	s0,sp,544
    800045e6:	892a                	mv	s2,a0
    800045e8:	dea43823          	sd	a0,-528(s0)
    800045ec:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800045f0:	aecfd0ef          	jal	800018dc <myproc>
    800045f4:	84aa                	mv	s1,a0

  begin_op();
    800045f6:	d88ff0ef          	jal	80003b7e <begin_op>

  if((ip = namei(path)) == 0){
    800045fa:	854a                	mv	a0,s2
    800045fc:	bc0ff0ef          	jal	800039bc <namei>
    80004600:	cd21                	beqz	a0,80004658 <exec+0x88>
    80004602:	fbd2                	sd	s4,496(sp)
    80004604:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004606:	cc7fe0ef          	jal	800032cc <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000460a:	04000713          	li	a4,64
    8000460e:	4681                	li	a3,0
    80004610:	e5040613          	addi	a2,s0,-432
    80004614:	4581                	li	a1,0
    80004616:	8552                	mv	a0,s4
    80004618:	f0dfe0ef          	jal	80003524 <readi>
    8000461c:	04000793          	li	a5,64
    80004620:	00f51a63          	bne	a0,a5,80004634 <exec+0x64>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004624:	e5042703          	lw	a4,-432(s0)
    80004628:	464c47b7          	lui	a5,0x464c4
    8000462c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004630:	02f70863          	beq	a4,a5,80004660 <exec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004634:	8552                	mv	a0,s4
    80004636:	ea1fe0ef          	jal	800034d6 <iunlockput>
    end_op();
    8000463a:	daeff0ef          	jal	80003be8 <end_op>
  }
  return -1;
    8000463e:	557d                	li	a0,-1
    80004640:	7a5e                	ld	s4,496(sp)
}
    80004642:	21813083          	ld	ra,536(sp)
    80004646:	21013403          	ld	s0,528(sp)
    8000464a:	20813483          	ld	s1,520(sp)
    8000464e:	20013903          	ld	s2,512(sp)
    80004652:	22010113          	addi	sp,sp,544
    80004656:	8082                	ret
    end_op();
    80004658:	d90ff0ef          	jal	80003be8 <end_op>
    return -1;
    8000465c:	557d                	li	a0,-1
    8000465e:	b7d5                	j	80004642 <exec+0x72>
    80004660:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004662:	8526                	mv	a0,s1
    80004664:	b20fd0ef          	jal	80001984 <proc_pagetable>
    80004668:	8b2a                	mv	s6,a0
    8000466a:	26050d63          	beqz	a0,800048e4 <exec+0x314>
    8000466e:	ffce                	sd	s3,504(sp)
    80004670:	f7d6                	sd	s5,488(sp)
    80004672:	efde                	sd	s7,472(sp)
    80004674:	ebe2                	sd	s8,464(sp)
    80004676:	e7e6                	sd	s9,456(sp)
    80004678:	e3ea                	sd	s10,448(sp)
    8000467a:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000467c:	e7042683          	lw	a3,-400(s0)
    80004680:	e8845783          	lhu	a5,-376(s0)
    80004684:	0e078763          	beqz	a5,80004772 <exec+0x1a2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004688:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000468a:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000468c:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004690:	6c85                	lui	s9,0x1
    80004692:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004696:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000469a:	6a85                	lui	s5,0x1
    8000469c:	a085                	j	800046fc <exec+0x12c>
      panic("loadseg: address should exist");
    8000469e:	00003517          	auipc	a0,0x3
    800046a2:	00250513          	addi	a0,a0,2 # 800076a0 <etext+0x6a0>
    800046a6:	8f8fc0ef          	jal	8000079e <panic>
    if(sz - i < PGSIZE)
    800046aa:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800046ac:	874a                	mv	a4,s2
    800046ae:	009c06bb          	addw	a3,s8,s1
    800046b2:	4581                	li	a1,0
    800046b4:	8552                	mv	a0,s4
    800046b6:	e6ffe0ef          	jal	80003524 <readi>
    800046ba:	22a91963          	bne	s2,a0,800048ec <exec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    800046be:	009a84bb          	addw	s1,s5,s1
    800046c2:	0334f263          	bgeu	s1,s3,800046e6 <exec+0x116>
    pa = walkaddr(pagetable, va + i);
    800046c6:	02049593          	slli	a1,s1,0x20
    800046ca:	9181                	srli	a1,a1,0x20
    800046cc:	95de                	add	a1,a1,s7
    800046ce:	855a                	mv	a0,s6
    800046d0:	92dfc0ef          	jal	80000ffc <walkaddr>
    800046d4:	862a                	mv	a2,a0
    if(pa == 0)
    800046d6:	d561                	beqz	a0,8000469e <exec+0xce>
    if(sz - i < PGSIZE)
    800046d8:	409987bb          	subw	a5,s3,s1
    800046dc:	893e                	mv	s2,a5
    800046de:	fcfcf6e3          	bgeu	s9,a5,800046aa <exec+0xda>
    800046e2:	8956                	mv	s2,s5
    800046e4:	b7d9                	j	800046aa <exec+0xda>
    sz = sz1;
    800046e6:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046ea:	2d05                	addiw	s10,s10,1
    800046ec:	e0843783          	ld	a5,-504(s0)
    800046f0:	0387869b          	addiw	a3,a5,56
    800046f4:	e8845783          	lhu	a5,-376(s0)
    800046f8:	06fd5e63          	bge	s10,a5,80004774 <exec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800046fc:	e0d43423          	sd	a3,-504(s0)
    80004700:	876e                	mv	a4,s11
    80004702:	e1840613          	addi	a2,s0,-488
    80004706:	4581                	li	a1,0
    80004708:	8552                	mv	a0,s4
    8000470a:	e1bfe0ef          	jal	80003524 <readi>
    8000470e:	1db51d63          	bne	a0,s11,800048e8 <exec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    80004712:	e1842783          	lw	a5,-488(s0)
    80004716:	4705                	li	a4,1
    80004718:	fce799e3          	bne	a5,a4,800046ea <exec+0x11a>
    if(ph.memsz < ph.filesz)
    8000471c:	e4043483          	ld	s1,-448(s0)
    80004720:	e3843783          	ld	a5,-456(s0)
    80004724:	1ef4e263          	bltu	s1,a5,80004908 <exec+0x338>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004728:	e2843783          	ld	a5,-472(s0)
    8000472c:	94be                	add	s1,s1,a5
    8000472e:	1ef4e063          	bltu	s1,a5,8000490e <exec+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    80004732:	de843703          	ld	a4,-536(s0)
    80004736:	8ff9                	and	a5,a5,a4
    80004738:	1c079e63          	bnez	a5,80004914 <exec+0x344>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000473c:	e1c42503          	lw	a0,-484(s0)
    80004740:	e71ff0ef          	jal	800045b0 <flags2perm>
    80004744:	86aa                	mv	a3,a0
    80004746:	8626                	mv	a2,s1
    80004748:	85ca                	mv	a1,s2
    8000474a:	855a                	mv	a0,s6
    8000474c:	c19fc0ef          	jal	80001364 <uvmalloc>
    80004750:	dea43c23          	sd	a0,-520(s0)
    80004754:	1c050363          	beqz	a0,8000491a <exec+0x34a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004758:	e2843b83          	ld	s7,-472(s0)
    8000475c:	e2042c03          	lw	s8,-480(s0)
    80004760:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004764:	00098463          	beqz	s3,8000476c <exec+0x19c>
    80004768:	4481                	li	s1,0
    8000476a:	bfb1                	j	800046c6 <exec+0xf6>
    sz = sz1;
    8000476c:	df843903          	ld	s2,-520(s0)
    80004770:	bfad                	j	800046ea <exec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004772:	4901                	li	s2,0
  iunlockput(ip);
    80004774:	8552                	mv	a0,s4
    80004776:	d61fe0ef          	jal	800034d6 <iunlockput>
  end_op();
    8000477a:	c6eff0ef          	jal	80003be8 <end_op>
  p = myproc();
    8000477e:	95efd0ef          	jal	800018dc <myproc>
    80004782:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004784:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004788:	6985                	lui	s3,0x1
    8000478a:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000478c:	99ca                	add	s3,s3,s2
    8000478e:	77fd                	lui	a5,0xfffff
    80004790:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004794:	4691                	li	a3,4
    80004796:	6609                	lui	a2,0x2
    80004798:	964e                	add	a2,a2,s3
    8000479a:	85ce                	mv	a1,s3
    8000479c:	855a                	mv	a0,s6
    8000479e:	bc7fc0ef          	jal	80001364 <uvmalloc>
    800047a2:	8a2a                	mv	s4,a0
    800047a4:	e105                	bnez	a0,800047c4 <exec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800047a6:	85ce                	mv	a1,s3
    800047a8:	855a                	mv	a0,s6
    800047aa:	a5efd0ef          	jal	80001a08 <proc_freepagetable>
  return -1;
    800047ae:	557d                	li	a0,-1
    800047b0:	79fe                	ld	s3,504(sp)
    800047b2:	7a5e                	ld	s4,496(sp)
    800047b4:	7abe                	ld	s5,488(sp)
    800047b6:	7b1e                	ld	s6,480(sp)
    800047b8:	6bfe                	ld	s7,472(sp)
    800047ba:	6c5e                	ld	s8,464(sp)
    800047bc:	6cbe                	ld	s9,456(sp)
    800047be:	6d1e                	ld	s10,448(sp)
    800047c0:	7dfa                	ld	s11,440(sp)
    800047c2:	b541                	j	80004642 <exec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800047c4:	75f9                	lui	a1,0xffffe
    800047c6:	95aa                	add	a1,a1,a0
    800047c8:	855a                	mv	a0,s6
    800047ca:	d91fc0ef          	jal	8000155a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800047ce:	7bfd                	lui	s7,0xfffff
    800047d0:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    800047d2:	e0043783          	ld	a5,-512(s0)
    800047d6:	6388                	ld	a0,0(a5)
  sp = sz;
    800047d8:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    800047da:	4481                	li	s1,0
    ustack[argc] = sp;
    800047dc:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    800047e0:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    800047e4:	cd21                	beqz	a0,8000483c <exec+0x26c>
    sp -= strlen(argv[argc]) + 1;
    800047e6:	e70fc0ef          	jal	80000e56 <strlen>
    800047ea:	0015079b          	addiw	a5,a0,1
    800047ee:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800047f2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800047f6:	13796563          	bltu	s2,s7,80004920 <exec+0x350>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800047fa:	e0043d83          	ld	s11,-512(s0)
    800047fe:	000db983          	ld	s3,0(s11)
    80004802:	854e                	mv	a0,s3
    80004804:	e52fc0ef          	jal	80000e56 <strlen>
    80004808:	0015069b          	addiw	a3,a0,1
    8000480c:	864e                	mv	a2,s3
    8000480e:	85ca                	mv	a1,s2
    80004810:	855a                	mv	a0,s6
    80004812:	d73fc0ef          	jal	80001584 <copyout>
    80004816:	10054763          	bltz	a0,80004924 <exec+0x354>
    ustack[argc] = sp;
    8000481a:	00349793          	slli	a5,s1,0x3
    8000481e:	97e6                	add	a5,a5,s9
    80004820:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd5860>
  for(argc = 0; argv[argc]; argc++) {
    80004824:	0485                	addi	s1,s1,1
    80004826:	008d8793          	addi	a5,s11,8
    8000482a:	e0f43023          	sd	a5,-512(s0)
    8000482e:	008db503          	ld	a0,8(s11)
    80004832:	c509                	beqz	a0,8000483c <exec+0x26c>
    if(argc >= MAXARG)
    80004834:	fb8499e3          	bne	s1,s8,800047e6 <exec+0x216>
  sz = sz1;
    80004838:	89d2                	mv	s3,s4
    8000483a:	b7b5                	j	800047a6 <exec+0x1d6>
  ustack[argc] = 0;
    8000483c:	00349793          	slli	a5,s1,0x3
    80004840:	f9078793          	addi	a5,a5,-112
    80004844:	97a2                	add	a5,a5,s0
    80004846:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000484a:	00148693          	addi	a3,s1,1
    8000484e:	068e                	slli	a3,a3,0x3
    80004850:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004854:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004858:	89d2                	mv	s3,s4
  if(sp < stackbase)
    8000485a:	f57966e3          	bltu	s2,s7,800047a6 <exec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000485e:	e9040613          	addi	a2,s0,-368
    80004862:	85ca                	mv	a1,s2
    80004864:	855a                	mv	a0,s6
    80004866:	d1ffc0ef          	jal	80001584 <copyout>
    8000486a:	f2054ee3          	bltz	a0,800047a6 <exec+0x1d6>
  p->trapframe->a1 = sp;
    8000486e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004872:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004876:	df043783          	ld	a5,-528(s0)
    8000487a:	0007c703          	lbu	a4,0(a5)
    8000487e:	cf11                	beqz	a4,8000489a <exec+0x2ca>
    80004880:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004882:	02f00693          	li	a3,47
    80004886:	a029                	j	80004890 <exec+0x2c0>
  for(last=s=path; *s; s++)
    80004888:	0785                	addi	a5,a5,1
    8000488a:	fff7c703          	lbu	a4,-1(a5)
    8000488e:	c711                	beqz	a4,8000489a <exec+0x2ca>
    if(*s == '/')
    80004890:	fed71ce3          	bne	a4,a3,80004888 <exec+0x2b8>
      last = s+1;
    80004894:	def43823          	sd	a5,-528(s0)
    80004898:	bfc5                	j	80004888 <exec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    8000489a:	4641                	li	a2,16
    8000489c:	df043583          	ld	a1,-528(s0)
    800048a0:	158a8513          	addi	a0,s5,344
    800048a4:	d7cfc0ef          	jal	80000e20 <safestrcpy>
  oldpagetable = p->pagetable;
    800048a8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800048ac:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800048b0:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800048b4:	058ab783          	ld	a5,88(s5)
    800048b8:	e6843703          	ld	a4,-408(s0)
    800048bc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800048be:	058ab783          	ld	a5,88(s5)
    800048c2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800048c6:	85ea                	mv	a1,s10
    800048c8:	940fd0ef          	jal	80001a08 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800048cc:	0004851b          	sext.w	a0,s1
    800048d0:	79fe                	ld	s3,504(sp)
    800048d2:	7a5e                	ld	s4,496(sp)
    800048d4:	7abe                	ld	s5,488(sp)
    800048d6:	7b1e                	ld	s6,480(sp)
    800048d8:	6bfe                	ld	s7,472(sp)
    800048da:	6c5e                	ld	s8,464(sp)
    800048dc:	6cbe                	ld	s9,456(sp)
    800048de:	6d1e                	ld	s10,448(sp)
    800048e0:	7dfa                	ld	s11,440(sp)
    800048e2:	b385                	j	80004642 <exec+0x72>
    800048e4:	7b1e                	ld	s6,480(sp)
    800048e6:	b3b9                	j	80004634 <exec+0x64>
    800048e8:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800048ec:	df843583          	ld	a1,-520(s0)
    800048f0:	855a                	mv	a0,s6
    800048f2:	916fd0ef          	jal	80001a08 <proc_freepagetable>
  if(ip){
    800048f6:	79fe                	ld	s3,504(sp)
    800048f8:	7abe                	ld	s5,488(sp)
    800048fa:	7b1e                	ld	s6,480(sp)
    800048fc:	6bfe                	ld	s7,472(sp)
    800048fe:	6c5e                	ld	s8,464(sp)
    80004900:	6cbe                	ld	s9,456(sp)
    80004902:	6d1e                	ld	s10,448(sp)
    80004904:	7dfa                	ld	s11,440(sp)
    80004906:	b33d                	j	80004634 <exec+0x64>
    80004908:	df243c23          	sd	s2,-520(s0)
    8000490c:	b7c5                	j	800048ec <exec+0x31c>
    8000490e:	df243c23          	sd	s2,-520(s0)
    80004912:	bfe9                	j	800048ec <exec+0x31c>
    80004914:	df243c23          	sd	s2,-520(s0)
    80004918:	bfd1                	j	800048ec <exec+0x31c>
    8000491a:	df243c23          	sd	s2,-520(s0)
    8000491e:	b7f9                	j	800048ec <exec+0x31c>
  sz = sz1;
    80004920:	89d2                	mv	s3,s4
    80004922:	b551                	j	800047a6 <exec+0x1d6>
    80004924:	89d2                	mv	s3,s4
    80004926:	b541                	j	800047a6 <exec+0x1d6>

0000000080004928 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004928:	7179                	addi	sp,sp,-48
    8000492a:	f406                	sd	ra,40(sp)
    8000492c:	f022                	sd	s0,32(sp)
    8000492e:	ec26                	sd	s1,24(sp)
    80004930:	e84a                	sd	s2,16(sp)
    80004932:	1800                	addi	s0,sp,48
    80004934:	892e                	mv	s2,a1
    80004936:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004938:	fdc40593          	addi	a1,s0,-36
    8000493c:	ea7fd0ef          	jal	800027e2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004940:	fdc42703          	lw	a4,-36(s0)
    80004944:	47bd                	li	a5,15
    80004946:	02e7e963          	bltu	a5,a4,80004978 <argfd+0x50>
    8000494a:	f93fc0ef          	jal	800018dc <myproc>
    8000494e:	fdc42703          	lw	a4,-36(s0)
    80004952:	01a70793          	addi	a5,a4,26
    80004956:	078e                	slli	a5,a5,0x3
    80004958:	953e                	add	a0,a0,a5
    8000495a:	611c                	ld	a5,0(a0)
    8000495c:	c385                	beqz	a5,8000497c <argfd+0x54>
    return -1;
  if(pfd)
    8000495e:	00090463          	beqz	s2,80004966 <argfd+0x3e>
    *pfd = fd;
    80004962:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004966:	4501                	li	a0,0
  if(pf)
    80004968:	c091                	beqz	s1,8000496c <argfd+0x44>
    *pf = f;
    8000496a:	e09c                	sd	a5,0(s1)
}
    8000496c:	70a2                	ld	ra,40(sp)
    8000496e:	7402                	ld	s0,32(sp)
    80004970:	64e2                	ld	s1,24(sp)
    80004972:	6942                	ld	s2,16(sp)
    80004974:	6145                	addi	sp,sp,48
    80004976:	8082                	ret
    return -1;
    80004978:	557d                	li	a0,-1
    8000497a:	bfcd                	j	8000496c <argfd+0x44>
    8000497c:	557d                	li	a0,-1
    8000497e:	b7fd                	j	8000496c <argfd+0x44>

0000000080004980 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004980:	1101                	addi	sp,sp,-32
    80004982:	ec06                	sd	ra,24(sp)
    80004984:	e822                	sd	s0,16(sp)
    80004986:	e426                	sd	s1,8(sp)
    80004988:	1000                	addi	s0,sp,32
    8000498a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000498c:	f51fc0ef          	jal	800018dc <myproc>
    80004990:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004992:	0d050793          	addi	a5,a0,208
    80004996:	4501                	li	a0,0
    80004998:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000499a:	6398                	ld	a4,0(a5)
    8000499c:	cb19                	beqz	a4,800049b2 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000499e:	2505                	addiw	a0,a0,1
    800049a0:	07a1                	addi	a5,a5,8
    800049a2:	fed51ce3          	bne	a0,a3,8000499a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800049a6:	557d                	li	a0,-1
}
    800049a8:	60e2                	ld	ra,24(sp)
    800049aa:	6442                	ld	s0,16(sp)
    800049ac:	64a2                	ld	s1,8(sp)
    800049ae:	6105                	addi	sp,sp,32
    800049b0:	8082                	ret
      p->ofile[fd] = f;
    800049b2:	01a50793          	addi	a5,a0,26
    800049b6:	078e                	slli	a5,a5,0x3
    800049b8:	963e                	add	a2,a2,a5
    800049ba:	e204                	sd	s1,0(a2)
      return fd;
    800049bc:	b7f5                	j	800049a8 <fdalloc+0x28>

00000000800049be <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800049be:	715d                	addi	sp,sp,-80
    800049c0:	e486                	sd	ra,72(sp)
    800049c2:	e0a2                	sd	s0,64(sp)
    800049c4:	fc26                	sd	s1,56(sp)
    800049c6:	f84a                	sd	s2,48(sp)
    800049c8:	f44e                	sd	s3,40(sp)
    800049ca:	ec56                	sd	s5,24(sp)
    800049cc:	e85a                	sd	s6,16(sp)
    800049ce:	0880                	addi	s0,sp,80
    800049d0:	8b2e                	mv	s6,a1
    800049d2:	89b2                	mv	s3,a2
    800049d4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800049d6:	fb040593          	addi	a1,s0,-80
    800049da:	ffdfe0ef          	jal	800039d6 <nameiparent>
    800049de:	84aa                	mv	s1,a0
    800049e0:	10050a63          	beqz	a0,80004af4 <create+0x136>
    return 0;

  ilock(dp);
    800049e4:	8e9fe0ef          	jal	800032cc <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800049e8:	4601                	li	a2,0
    800049ea:	fb040593          	addi	a1,s0,-80
    800049ee:	8526                	mv	a0,s1
    800049f0:	d41fe0ef          	jal	80003730 <dirlookup>
    800049f4:	8aaa                	mv	s5,a0
    800049f6:	c129                	beqz	a0,80004a38 <create+0x7a>
    iunlockput(dp);
    800049f8:	8526                	mv	a0,s1
    800049fa:	addfe0ef          	jal	800034d6 <iunlockput>
    ilock(ip);
    800049fe:	8556                	mv	a0,s5
    80004a00:	8cdfe0ef          	jal	800032cc <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a04:	4789                	li	a5,2
    80004a06:	02fb1463          	bne	s6,a5,80004a2e <create+0x70>
    80004a0a:	044ad783          	lhu	a5,68(s5)
    80004a0e:	37f9                	addiw	a5,a5,-2
    80004a10:	17c2                	slli	a5,a5,0x30
    80004a12:	93c1                	srli	a5,a5,0x30
    80004a14:	4705                	li	a4,1
    80004a16:	00f76c63          	bltu	a4,a5,80004a2e <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a1a:	8556                	mv	a0,s5
    80004a1c:	60a6                	ld	ra,72(sp)
    80004a1e:	6406                	ld	s0,64(sp)
    80004a20:	74e2                	ld	s1,56(sp)
    80004a22:	7942                	ld	s2,48(sp)
    80004a24:	79a2                	ld	s3,40(sp)
    80004a26:	6ae2                	ld	s5,24(sp)
    80004a28:	6b42                	ld	s6,16(sp)
    80004a2a:	6161                	addi	sp,sp,80
    80004a2c:	8082                	ret
    iunlockput(ip);
    80004a2e:	8556                	mv	a0,s5
    80004a30:	aa7fe0ef          	jal	800034d6 <iunlockput>
    return 0;
    80004a34:	4a81                	li	s5,0
    80004a36:	b7d5                	j	80004a1a <create+0x5c>
    80004a38:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a3a:	85da                	mv	a1,s6
    80004a3c:	4088                	lw	a0,0(s1)
    80004a3e:	f1efe0ef          	jal	8000315c <ialloc>
    80004a42:	8a2a                	mv	s4,a0
    80004a44:	cd15                	beqz	a0,80004a80 <create+0xc2>
  ilock(ip);
    80004a46:	887fe0ef          	jal	800032cc <ilock>
  ip->major = major;
    80004a4a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004a4e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004a52:	4905                	li	s2,1
    80004a54:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004a58:	8552                	mv	a0,s4
    80004a5a:	fbefe0ef          	jal	80003218 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004a5e:	032b0763          	beq	s6,s2,80004a8c <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a62:	004a2603          	lw	a2,4(s4)
    80004a66:	fb040593          	addi	a1,s0,-80
    80004a6a:	8526                	mv	a0,s1
    80004a6c:	ea7fe0ef          	jal	80003912 <dirlink>
    80004a70:	06054563          	bltz	a0,80004ada <create+0x11c>
  iunlockput(dp);
    80004a74:	8526                	mv	a0,s1
    80004a76:	a61fe0ef          	jal	800034d6 <iunlockput>
  return ip;
    80004a7a:	8ad2                	mv	s5,s4
    80004a7c:	7a02                	ld	s4,32(sp)
    80004a7e:	bf71                	j	80004a1a <create+0x5c>
    iunlockput(dp);
    80004a80:	8526                	mv	a0,s1
    80004a82:	a55fe0ef          	jal	800034d6 <iunlockput>
    return 0;
    80004a86:	8ad2                	mv	s5,s4
    80004a88:	7a02                	ld	s4,32(sp)
    80004a8a:	bf41                	j	80004a1a <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004a8c:	004a2603          	lw	a2,4(s4)
    80004a90:	00003597          	auipc	a1,0x3
    80004a94:	c3058593          	addi	a1,a1,-976 # 800076c0 <etext+0x6c0>
    80004a98:	8552                	mv	a0,s4
    80004a9a:	e79fe0ef          	jal	80003912 <dirlink>
    80004a9e:	02054e63          	bltz	a0,80004ada <create+0x11c>
    80004aa2:	40d0                	lw	a2,4(s1)
    80004aa4:	00003597          	auipc	a1,0x3
    80004aa8:	c2458593          	addi	a1,a1,-988 # 800076c8 <etext+0x6c8>
    80004aac:	8552                	mv	a0,s4
    80004aae:	e65fe0ef          	jal	80003912 <dirlink>
    80004ab2:	02054463          	bltz	a0,80004ada <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ab6:	004a2603          	lw	a2,4(s4)
    80004aba:	fb040593          	addi	a1,s0,-80
    80004abe:	8526                	mv	a0,s1
    80004ac0:	e53fe0ef          	jal	80003912 <dirlink>
    80004ac4:	00054b63          	bltz	a0,80004ada <create+0x11c>
    dp->nlink++;  // for ".."
    80004ac8:	04a4d783          	lhu	a5,74(s1)
    80004acc:	2785                	addiw	a5,a5,1
    80004ace:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ad2:	8526                	mv	a0,s1
    80004ad4:	f44fe0ef          	jal	80003218 <iupdate>
    80004ad8:	bf71                	j	80004a74 <create+0xb6>
  ip->nlink = 0;
    80004ada:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004ade:	8552                	mv	a0,s4
    80004ae0:	f38fe0ef          	jal	80003218 <iupdate>
  iunlockput(ip);
    80004ae4:	8552                	mv	a0,s4
    80004ae6:	9f1fe0ef          	jal	800034d6 <iunlockput>
  iunlockput(dp);
    80004aea:	8526                	mv	a0,s1
    80004aec:	9ebfe0ef          	jal	800034d6 <iunlockput>
  return 0;
    80004af0:	7a02                	ld	s4,32(sp)
    80004af2:	b725                	j	80004a1a <create+0x5c>
    return 0;
    80004af4:	8aaa                	mv	s5,a0
    80004af6:	b715                	j	80004a1a <create+0x5c>

0000000080004af8 <sys_dup>:
{
    80004af8:	7179                	addi	sp,sp,-48
    80004afa:	f406                	sd	ra,40(sp)
    80004afc:	f022                	sd	s0,32(sp)
    80004afe:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004b00:	fd840613          	addi	a2,s0,-40
    80004b04:	4581                	li	a1,0
    80004b06:	4501                	li	a0,0
    80004b08:	e21ff0ef          	jal	80004928 <argfd>
    return -1;
    80004b0c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004b0e:	02054363          	bltz	a0,80004b34 <sys_dup+0x3c>
    80004b12:	ec26                	sd	s1,24(sp)
    80004b14:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004b16:	fd843903          	ld	s2,-40(s0)
    80004b1a:	854a                	mv	a0,s2
    80004b1c:	e65ff0ef          	jal	80004980 <fdalloc>
    80004b20:	84aa                	mv	s1,a0
    return -1;
    80004b22:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004b24:	00054d63          	bltz	a0,80004b3e <sys_dup+0x46>
  filedup(f);
    80004b28:	854a                	mv	a0,s2
    80004b2a:	c2eff0ef          	jal	80003f58 <filedup>
  return fd;
    80004b2e:	87a6                	mv	a5,s1
    80004b30:	64e2                	ld	s1,24(sp)
    80004b32:	6942                	ld	s2,16(sp)
}
    80004b34:	853e                	mv	a0,a5
    80004b36:	70a2                	ld	ra,40(sp)
    80004b38:	7402                	ld	s0,32(sp)
    80004b3a:	6145                	addi	sp,sp,48
    80004b3c:	8082                	ret
    80004b3e:	64e2                	ld	s1,24(sp)
    80004b40:	6942                	ld	s2,16(sp)
    80004b42:	bfcd                	j	80004b34 <sys_dup+0x3c>

0000000080004b44 <sys_read>:
{
    80004b44:	7179                	addi	sp,sp,-48
    80004b46:	f406                	sd	ra,40(sp)
    80004b48:	f022                	sd	s0,32(sp)
    80004b4a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b4c:	fd840593          	addi	a1,s0,-40
    80004b50:	4505                	li	a0,1
    80004b52:	cadfd0ef          	jal	800027fe <argaddr>
  argint(2, &n);
    80004b56:	fe440593          	addi	a1,s0,-28
    80004b5a:	4509                	li	a0,2
    80004b5c:	c87fd0ef          	jal	800027e2 <argint>
  if(argfd(0, 0, &f) < 0)
    80004b60:	fe840613          	addi	a2,s0,-24
    80004b64:	4581                	li	a1,0
    80004b66:	4501                	li	a0,0
    80004b68:	dc1ff0ef          	jal	80004928 <argfd>
    80004b6c:	87aa                	mv	a5,a0
    return -1;
    80004b6e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b70:	0007ca63          	bltz	a5,80004b84 <sys_read+0x40>
  return fileread(f, p, n);
    80004b74:	fe442603          	lw	a2,-28(s0)
    80004b78:	fd843583          	ld	a1,-40(s0)
    80004b7c:	fe843503          	ld	a0,-24(s0)
    80004b80:	d3eff0ef          	jal	800040be <fileread>
}
    80004b84:	70a2                	ld	ra,40(sp)
    80004b86:	7402                	ld	s0,32(sp)
    80004b88:	6145                	addi	sp,sp,48
    80004b8a:	8082                	ret

0000000080004b8c <sys_write>:
{
    80004b8c:	7179                	addi	sp,sp,-48
    80004b8e:	f406                	sd	ra,40(sp)
    80004b90:	f022                	sd	s0,32(sp)
    80004b92:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b94:	fd840593          	addi	a1,s0,-40
    80004b98:	4505                	li	a0,1
    80004b9a:	c65fd0ef          	jal	800027fe <argaddr>
  argint(2, &n);
    80004b9e:	fe440593          	addi	a1,s0,-28
    80004ba2:	4509                	li	a0,2
    80004ba4:	c3ffd0ef          	jal	800027e2 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ba8:	fe840613          	addi	a2,s0,-24
    80004bac:	4581                	li	a1,0
    80004bae:	4501                	li	a0,0
    80004bb0:	d79ff0ef          	jal	80004928 <argfd>
    80004bb4:	87aa                	mv	a5,a0
    return -1;
    80004bb6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004bb8:	0007ca63          	bltz	a5,80004bcc <sys_write+0x40>
  return filewrite(f, p, n);
    80004bbc:	fe442603          	lw	a2,-28(s0)
    80004bc0:	fd843583          	ld	a1,-40(s0)
    80004bc4:	fe843503          	ld	a0,-24(s0)
    80004bc8:	db4ff0ef          	jal	8000417c <filewrite>
}
    80004bcc:	70a2                	ld	ra,40(sp)
    80004bce:	7402                	ld	s0,32(sp)
    80004bd0:	6145                	addi	sp,sp,48
    80004bd2:	8082                	ret

0000000080004bd4 <sys_close>:
{
    80004bd4:	1101                	addi	sp,sp,-32
    80004bd6:	ec06                	sd	ra,24(sp)
    80004bd8:	e822                	sd	s0,16(sp)
    80004bda:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004bdc:	fe040613          	addi	a2,s0,-32
    80004be0:	fec40593          	addi	a1,s0,-20
    80004be4:	4501                	li	a0,0
    80004be6:	d43ff0ef          	jal	80004928 <argfd>
    return -1;
    80004bea:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004bec:	02054063          	bltz	a0,80004c0c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004bf0:	cedfc0ef          	jal	800018dc <myproc>
    80004bf4:	fec42783          	lw	a5,-20(s0)
    80004bf8:	07e9                	addi	a5,a5,26
    80004bfa:	078e                	slli	a5,a5,0x3
    80004bfc:	953e                	add	a0,a0,a5
    80004bfe:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c02:	fe043503          	ld	a0,-32(s0)
    80004c06:	b98ff0ef          	jal	80003f9e <fileclose>
  return 0;
    80004c0a:	4781                	li	a5,0
}
    80004c0c:	853e                	mv	a0,a5
    80004c0e:	60e2                	ld	ra,24(sp)
    80004c10:	6442                	ld	s0,16(sp)
    80004c12:	6105                	addi	sp,sp,32
    80004c14:	8082                	ret

0000000080004c16 <sys_fstat>:
{
    80004c16:	1101                	addi	sp,sp,-32
    80004c18:	ec06                	sd	ra,24(sp)
    80004c1a:	e822                	sd	s0,16(sp)
    80004c1c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c1e:	fe040593          	addi	a1,s0,-32
    80004c22:	4505                	li	a0,1
    80004c24:	bdbfd0ef          	jal	800027fe <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004c28:	fe840613          	addi	a2,s0,-24
    80004c2c:	4581                	li	a1,0
    80004c2e:	4501                	li	a0,0
    80004c30:	cf9ff0ef          	jal	80004928 <argfd>
    80004c34:	87aa                	mv	a5,a0
    return -1;
    80004c36:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c38:	0007c863          	bltz	a5,80004c48 <sys_fstat+0x32>
  return filestat(f, st);
    80004c3c:	fe043583          	ld	a1,-32(s0)
    80004c40:	fe843503          	ld	a0,-24(s0)
    80004c44:	c18ff0ef          	jal	8000405c <filestat>
}
    80004c48:	60e2                	ld	ra,24(sp)
    80004c4a:	6442                	ld	s0,16(sp)
    80004c4c:	6105                	addi	sp,sp,32
    80004c4e:	8082                	ret

0000000080004c50 <sys_link>:
{
    80004c50:	7169                	addi	sp,sp,-304
    80004c52:	f606                	sd	ra,296(sp)
    80004c54:	f222                	sd	s0,288(sp)
    80004c56:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c58:	08000613          	li	a2,128
    80004c5c:	ed040593          	addi	a1,s0,-304
    80004c60:	4501                	li	a0,0
    80004c62:	bb9fd0ef          	jal	8000281a <argstr>
    return -1;
    80004c66:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c68:	0c054e63          	bltz	a0,80004d44 <sys_link+0xf4>
    80004c6c:	08000613          	li	a2,128
    80004c70:	f5040593          	addi	a1,s0,-176
    80004c74:	4505                	li	a0,1
    80004c76:	ba5fd0ef          	jal	8000281a <argstr>
    return -1;
    80004c7a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c7c:	0c054463          	bltz	a0,80004d44 <sys_link+0xf4>
    80004c80:	ee26                	sd	s1,280(sp)
  begin_op();
    80004c82:	efdfe0ef          	jal	80003b7e <begin_op>
  if((ip = namei(old)) == 0){
    80004c86:	ed040513          	addi	a0,s0,-304
    80004c8a:	d33fe0ef          	jal	800039bc <namei>
    80004c8e:	84aa                	mv	s1,a0
    80004c90:	c53d                	beqz	a0,80004cfe <sys_link+0xae>
  ilock(ip);
    80004c92:	e3afe0ef          	jal	800032cc <ilock>
  if(ip->type == T_DIR){
    80004c96:	04449703          	lh	a4,68(s1)
    80004c9a:	4785                	li	a5,1
    80004c9c:	06f70663          	beq	a4,a5,80004d08 <sys_link+0xb8>
    80004ca0:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004ca2:	04a4d783          	lhu	a5,74(s1)
    80004ca6:	2785                	addiw	a5,a5,1
    80004ca8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004cac:	8526                	mv	a0,s1
    80004cae:	d6afe0ef          	jal	80003218 <iupdate>
  iunlock(ip);
    80004cb2:	8526                	mv	a0,s1
    80004cb4:	ec6fe0ef          	jal	8000337a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004cb8:	fd040593          	addi	a1,s0,-48
    80004cbc:	f5040513          	addi	a0,s0,-176
    80004cc0:	d17fe0ef          	jal	800039d6 <nameiparent>
    80004cc4:	892a                	mv	s2,a0
    80004cc6:	cd21                	beqz	a0,80004d1e <sys_link+0xce>
  ilock(dp);
    80004cc8:	e04fe0ef          	jal	800032cc <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004ccc:	00092703          	lw	a4,0(s2)
    80004cd0:	409c                	lw	a5,0(s1)
    80004cd2:	04f71363          	bne	a4,a5,80004d18 <sys_link+0xc8>
    80004cd6:	40d0                	lw	a2,4(s1)
    80004cd8:	fd040593          	addi	a1,s0,-48
    80004cdc:	854a                	mv	a0,s2
    80004cde:	c35fe0ef          	jal	80003912 <dirlink>
    80004ce2:	02054b63          	bltz	a0,80004d18 <sys_link+0xc8>
  iunlockput(dp);
    80004ce6:	854a                	mv	a0,s2
    80004ce8:	feefe0ef          	jal	800034d6 <iunlockput>
  iput(ip);
    80004cec:	8526                	mv	a0,s1
    80004cee:	f60fe0ef          	jal	8000344e <iput>
  end_op();
    80004cf2:	ef7fe0ef          	jal	80003be8 <end_op>
  return 0;
    80004cf6:	4781                	li	a5,0
    80004cf8:	64f2                	ld	s1,280(sp)
    80004cfa:	6952                	ld	s2,272(sp)
    80004cfc:	a0a1                	j	80004d44 <sys_link+0xf4>
    end_op();
    80004cfe:	eebfe0ef          	jal	80003be8 <end_op>
    return -1;
    80004d02:	57fd                	li	a5,-1
    80004d04:	64f2                	ld	s1,280(sp)
    80004d06:	a83d                	j	80004d44 <sys_link+0xf4>
    iunlockput(ip);
    80004d08:	8526                	mv	a0,s1
    80004d0a:	fccfe0ef          	jal	800034d6 <iunlockput>
    end_op();
    80004d0e:	edbfe0ef          	jal	80003be8 <end_op>
    return -1;
    80004d12:	57fd                	li	a5,-1
    80004d14:	64f2                	ld	s1,280(sp)
    80004d16:	a03d                	j	80004d44 <sys_link+0xf4>
    iunlockput(dp);
    80004d18:	854a                	mv	a0,s2
    80004d1a:	fbcfe0ef          	jal	800034d6 <iunlockput>
  ilock(ip);
    80004d1e:	8526                	mv	a0,s1
    80004d20:	dacfe0ef          	jal	800032cc <ilock>
  ip->nlink--;
    80004d24:	04a4d783          	lhu	a5,74(s1)
    80004d28:	37fd                	addiw	a5,a5,-1
    80004d2a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d2e:	8526                	mv	a0,s1
    80004d30:	ce8fe0ef          	jal	80003218 <iupdate>
  iunlockput(ip);
    80004d34:	8526                	mv	a0,s1
    80004d36:	fa0fe0ef          	jal	800034d6 <iunlockput>
  end_op();
    80004d3a:	eaffe0ef          	jal	80003be8 <end_op>
  return -1;
    80004d3e:	57fd                	li	a5,-1
    80004d40:	64f2                	ld	s1,280(sp)
    80004d42:	6952                	ld	s2,272(sp)
}
    80004d44:	853e                	mv	a0,a5
    80004d46:	70b2                	ld	ra,296(sp)
    80004d48:	7412                	ld	s0,288(sp)
    80004d4a:	6155                	addi	sp,sp,304
    80004d4c:	8082                	ret

0000000080004d4e <sys_unlink>:
{
    80004d4e:	7111                	addi	sp,sp,-256
    80004d50:	fd86                	sd	ra,248(sp)
    80004d52:	f9a2                	sd	s0,240(sp)
    80004d54:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80004d56:	08000613          	li	a2,128
    80004d5a:	f2040593          	addi	a1,s0,-224
    80004d5e:	4501                	li	a0,0
    80004d60:	abbfd0ef          	jal	8000281a <argstr>
    80004d64:	16054663          	bltz	a0,80004ed0 <sys_unlink+0x182>
    80004d68:	f5a6                	sd	s1,232(sp)
  begin_op();
    80004d6a:	e15fe0ef          	jal	80003b7e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004d6e:	fa040593          	addi	a1,s0,-96
    80004d72:	f2040513          	addi	a0,s0,-224
    80004d76:	c61fe0ef          	jal	800039d6 <nameiparent>
    80004d7a:	84aa                	mv	s1,a0
    80004d7c:	c955                	beqz	a0,80004e30 <sys_unlink+0xe2>
  ilock(dp);
    80004d7e:	d4efe0ef          	jal	800032cc <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004d82:	00003597          	auipc	a1,0x3
    80004d86:	93e58593          	addi	a1,a1,-1730 # 800076c0 <etext+0x6c0>
    80004d8a:	fa040513          	addi	a0,s0,-96
    80004d8e:	98dfe0ef          	jal	8000371a <namecmp>
    80004d92:	12050463          	beqz	a0,80004eba <sys_unlink+0x16c>
    80004d96:	00003597          	auipc	a1,0x3
    80004d9a:	93258593          	addi	a1,a1,-1742 # 800076c8 <etext+0x6c8>
    80004d9e:	fa040513          	addi	a0,s0,-96
    80004da2:	979fe0ef          	jal	8000371a <namecmp>
    80004da6:	10050a63          	beqz	a0,80004eba <sys_unlink+0x16c>
    80004daa:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004dac:	f1c40613          	addi	a2,s0,-228
    80004db0:	fa040593          	addi	a1,s0,-96
    80004db4:	8526                	mv	a0,s1
    80004db6:	97bfe0ef          	jal	80003730 <dirlookup>
    80004dba:	892a                	mv	s2,a0
    80004dbc:	0e050e63          	beqz	a0,80004eb8 <sys_unlink+0x16a>
    80004dc0:	edce                	sd	s3,216(sp)
  ilock(ip);
    80004dc2:	d0afe0ef          	jal	800032cc <ilock>
  if(ip->nlink < 1)
    80004dc6:	04a91783          	lh	a5,74(s2)
    80004dca:	06f05863          	blez	a5,80004e3a <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004dce:	04491703          	lh	a4,68(s2)
    80004dd2:	4785                	li	a5,1
    80004dd4:	06f70b63          	beq	a4,a5,80004e4a <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    80004dd8:	fb040993          	addi	s3,s0,-80
    80004ddc:	4641                	li	a2,16
    80004dde:	4581                	li	a1,0
    80004de0:	854e                	mv	a0,s3
    80004de2:	eedfb0ef          	jal	80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004de6:	4741                	li	a4,16
    80004de8:	f1c42683          	lw	a3,-228(s0)
    80004dec:	864e                	mv	a2,s3
    80004dee:	4581                	li	a1,0
    80004df0:	8526                	mv	a0,s1
    80004df2:	825fe0ef          	jal	80003616 <writei>
    80004df6:	47c1                	li	a5,16
    80004df8:	08f51f63          	bne	a0,a5,80004e96 <sys_unlink+0x148>
  if(ip->type == T_DIR){
    80004dfc:	04491703          	lh	a4,68(s2)
    80004e00:	4785                	li	a5,1
    80004e02:	0af70263          	beq	a4,a5,80004ea6 <sys_unlink+0x158>
  iunlockput(dp);
    80004e06:	8526                	mv	a0,s1
    80004e08:	ecefe0ef          	jal	800034d6 <iunlockput>
  ip->nlink--;
    80004e0c:	04a95783          	lhu	a5,74(s2)
    80004e10:	37fd                	addiw	a5,a5,-1
    80004e12:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e16:	854a                	mv	a0,s2
    80004e18:	c00fe0ef          	jal	80003218 <iupdate>
  iunlockput(ip);
    80004e1c:	854a                	mv	a0,s2
    80004e1e:	eb8fe0ef          	jal	800034d6 <iunlockput>
  end_op();
    80004e22:	dc7fe0ef          	jal	80003be8 <end_op>
  return 0;
    80004e26:	4501                	li	a0,0
    80004e28:	74ae                	ld	s1,232(sp)
    80004e2a:	790e                	ld	s2,224(sp)
    80004e2c:	69ee                	ld	s3,216(sp)
    80004e2e:	a869                	j	80004ec8 <sys_unlink+0x17a>
    end_op();
    80004e30:	db9fe0ef          	jal	80003be8 <end_op>
    return -1;
    80004e34:	557d                	li	a0,-1
    80004e36:	74ae                	ld	s1,232(sp)
    80004e38:	a841                	j	80004ec8 <sys_unlink+0x17a>
    80004e3a:	e9d2                	sd	s4,208(sp)
    80004e3c:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80004e3e:	00003517          	auipc	a0,0x3
    80004e42:	89250513          	addi	a0,a0,-1902 # 800076d0 <etext+0x6d0>
    80004e46:	959fb0ef          	jal	8000079e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e4a:	04c92703          	lw	a4,76(s2)
    80004e4e:	02000793          	li	a5,32
    80004e52:	f8e7f3e3          	bgeu	a5,a4,80004dd8 <sys_unlink+0x8a>
    80004e56:	e9d2                	sd	s4,208(sp)
    80004e58:	e5d6                	sd	s5,200(sp)
    80004e5a:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e5c:	f0840a93          	addi	s5,s0,-248
    80004e60:	4a41                	li	s4,16
    80004e62:	8752                	mv	a4,s4
    80004e64:	86ce                	mv	a3,s3
    80004e66:	8656                	mv	a2,s5
    80004e68:	4581                	li	a1,0
    80004e6a:	854a                	mv	a0,s2
    80004e6c:	eb8fe0ef          	jal	80003524 <readi>
    80004e70:	01451d63          	bne	a0,s4,80004e8a <sys_unlink+0x13c>
    if(de.inum != 0)
    80004e74:	f0845783          	lhu	a5,-248(s0)
    80004e78:	efb1                	bnez	a5,80004ed4 <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e7a:	29c1                	addiw	s3,s3,16
    80004e7c:	04c92783          	lw	a5,76(s2)
    80004e80:	fef9e1e3          	bltu	s3,a5,80004e62 <sys_unlink+0x114>
    80004e84:	6a4e                	ld	s4,208(sp)
    80004e86:	6aae                	ld	s5,200(sp)
    80004e88:	bf81                	j	80004dd8 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004e8a:	00003517          	auipc	a0,0x3
    80004e8e:	85e50513          	addi	a0,a0,-1954 # 800076e8 <etext+0x6e8>
    80004e92:	90dfb0ef          	jal	8000079e <panic>
    80004e96:	e9d2                	sd	s4,208(sp)
    80004e98:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80004e9a:	00003517          	auipc	a0,0x3
    80004e9e:	86650513          	addi	a0,a0,-1946 # 80007700 <etext+0x700>
    80004ea2:	8fdfb0ef          	jal	8000079e <panic>
    dp->nlink--;
    80004ea6:	04a4d783          	lhu	a5,74(s1)
    80004eaa:	37fd                	addiw	a5,a5,-1
    80004eac:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004eb0:	8526                	mv	a0,s1
    80004eb2:	b66fe0ef          	jal	80003218 <iupdate>
    80004eb6:	bf81                	j	80004e06 <sys_unlink+0xb8>
    80004eb8:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80004eba:	8526                	mv	a0,s1
    80004ebc:	e1afe0ef          	jal	800034d6 <iunlockput>
  end_op();
    80004ec0:	d29fe0ef          	jal	80003be8 <end_op>
  return -1;
    80004ec4:	557d                	li	a0,-1
    80004ec6:	74ae                	ld	s1,232(sp)
}
    80004ec8:	70ee                	ld	ra,248(sp)
    80004eca:	744e                	ld	s0,240(sp)
    80004ecc:	6111                	addi	sp,sp,256
    80004ece:	8082                	ret
    return -1;
    80004ed0:	557d                	li	a0,-1
    80004ed2:	bfdd                	j	80004ec8 <sys_unlink+0x17a>
    iunlockput(ip);
    80004ed4:	854a                	mv	a0,s2
    80004ed6:	e00fe0ef          	jal	800034d6 <iunlockput>
    goto bad;
    80004eda:	790e                	ld	s2,224(sp)
    80004edc:	69ee                	ld	s3,216(sp)
    80004ede:	6a4e                	ld	s4,208(sp)
    80004ee0:	6aae                	ld	s5,200(sp)
    80004ee2:	bfe1                	j	80004eba <sys_unlink+0x16c>

0000000080004ee4 <sys_open>:

uint64
sys_open(void)
{
    80004ee4:	7131                	addi	sp,sp,-192
    80004ee6:	fd06                	sd	ra,184(sp)
    80004ee8:	f922                	sd	s0,176(sp)
    80004eea:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004eec:	f4c40593          	addi	a1,s0,-180
    80004ef0:	4505                	li	a0,1
    80004ef2:	8f1fd0ef          	jal	800027e2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004ef6:	08000613          	li	a2,128
    80004efa:	f5040593          	addi	a1,s0,-176
    80004efe:	4501                	li	a0,0
    80004f00:	91bfd0ef          	jal	8000281a <argstr>
    80004f04:	87aa                	mv	a5,a0
    return -1;
    80004f06:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f08:	0a07c363          	bltz	a5,80004fae <sys_open+0xca>
    80004f0c:	f526                	sd	s1,168(sp)

  begin_op();
    80004f0e:	c71fe0ef          	jal	80003b7e <begin_op>

  if(omode & O_CREATE){
    80004f12:	f4c42783          	lw	a5,-180(s0)
    80004f16:	2007f793          	andi	a5,a5,512
    80004f1a:	c3dd                	beqz	a5,80004fc0 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80004f1c:	4681                	li	a3,0
    80004f1e:	4601                	li	a2,0
    80004f20:	4589                	li	a1,2
    80004f22:	f5040513          	addi	a0,s0,-176
    80004f26:	a99ff0ef          	jal	800049be <create>
    80004f2a:	84aa                	mv	s1,a0
    if(ip == 0){
    80004f2c:	c549                	beqz	a0,80004fb6 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004f2e:	04449703          	lh	a4,68(s1)
    80004f32:	478d                	li	a5,3
    80004f34:	00f71763          	bne	a4,a5,80004f42 <sys_open+0x5e>
    80004f38:	0464d703          	lhu	a4,70(s1)
    80004f3c:	47a5                	li	a5,9
    80004f3e:	0ae7ee63          	bltu	a5,a4,80004ffa <sys_open+0x116>
    80004f42:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004f44:	fb7fe0ef          	jal	80003efa <filealloc>
    80004f48:	892a                	mv	s2,a0
    80004f4a:	c561                	beqz	a0,80005012 <sys_open+0x12e>
    80004f4c:	ed4e                	sd	s3,152(sp)
    80004f4e:	a33ff0ef          	jal	80004980 <fdalloc>
    80004f52:	89aa                	mv	s3,a0
    80004f54:	0a054b63          	bltz	a0,8000500a <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f58:	04449703          	lh	a4,68(s1)
    80004f5c:	478d                	li	a5,3
    80004f5e:	0cf70363          	beq	a4,a5,80005024 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004f62:	4789                	li	a5,2
    80004f64:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004f68:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004f6c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004f70:	f4c42783          	lw	a5,-180(s0)
    80004f74:	0017f713          	andi	a4,a5,1
    80004f78:	00174713          	xori	a4,a4,1
    80004f7c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004f80:	0037f713          	andi	a4,a5,3
    80004f84:	00e03733          	snez	a4,a4
    80004f88:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004f8c:	4007f793          	andi	a5,a5,1024
    80004f90:	c791                	beqz	a5,80004f9c <sys_open+0xb8>
    80004f92:	04449703          	lh	a4,68(s1)
    80004f96:	4789                	li	a5,2
    80004f98:	08f70d63          	beq	a4,a5,80005032 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80004f9c:	8526                	mv	a0,s1
    80004f9e:	bdcfe0ef          	jal	8000337a <iunlock>
  end_op();
    80004fa2:	c47fe0ef          	jal	80003be8 <end_op>

  return fd;
    80004fa6:	854e                	mv	a0,s3
    80004fa8:	74aa                	ld	s1,168(sp)
    80004faa:	790a                	ld	s2,160(sp)
    80004fac:	69ea                	ld	s3,152(sp)
}
    80004fae:	70ea                	ld	ra,184(sp)
    80004fb0:	744a                	ld	s0,176(sp)
    80004fb2:	6129                	addi	sp,sp,192
    80004fb4:	8082                	ret
      end_op();
    80004fb6:	c33fe0ef          	jal	80003be8 <end_op>
      return -1;
    80004fba:	557d                	li	a0,-1
    80004fbc:	74aa                	ld	s1,168(sp)
    80004fbe:	bfc5                	j	80004fae <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80004fc0:	f5040513          	addi	a0,s0,-176
    80004fc4:	9f9fe0ef          	jal	800039bc <namei>
    80004fc8:	84aa                	mv	s1,a0
    80004fca:	c11d                	beqz	a0,80004ff0 <sys_open+0x10c>
    ilock(ip);
    80004fcc:	b00fe0ef          	jal	800032cc <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004fd0:	04449703          	lh	a4,68(s1)
    80004fd4:	4785                	li	a5,1
    80004fd6:	f4f71ce3          	bne	a4,a5,80004f2e <sys_open+0x4a>
    80004fda:	f4c42783          	lw	a5,-180(s0)
    80004fde:	d3b5                	beqz	a5,80004f42 <sys_open+0x5e>
      iunlockput(ip);
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	cf4fe0ef          	jal	800034d6 <iunlockput>
      end_op();
    80004fe6:	c03fe0ef          	jal	80003be8 <end_op>
      return -1;
    80004fea:	557d                	li	a0,-1
    80004fec:	74aa                	ld	s1,168(sp)
    80004fee:	b7c1                	j	80004fae <sys_open+0xca>
      end_op();
    80004ff0:	bf9fe0ef          	jal	80003be8 <end_op>
      return -1;
    80004ff4:	557d                	li	a0,-1
    80004ff6:	74aa                	ld	s1,168(sp)
    80004ff8:	bf5d                	j	80004fae <sys_open+0xca>
    iunlockput(ip);
    80004ffa:	8526                	mv	a0,s1
    80004ffc:	cdafe0ef          	jal	800034d6 <iunlockput>
    end_op();
    80005000:	be9fe0ef          	jal	80003be8 <end_op>
    return -1;
    80005004:	557d                	li	a0,-1
    80005006:	74aa                	ld	s1,168(sp)
    80005008:	b75d                	j	80004fae <sys_open+0xca>
      fileclose(f);
    8000500a:	854a                	mv	a0,s2
    8000500c:	f93fe0ef          	jal	80003f9e <fileclose>
    80005010:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005012:	8526                	mv	a0,s1
    80005014:	cc2fe0ef          	jal	800034d6 <iunlockput>
    end_op();
    80005018:	bd1fe0ef          	jal	80003be8 <end_op>
    return -1;
    8000501c:	557d                	li	a0,-1
    8000501e:	74aa                	ld	s1,168(sp)
    80005020:	790a                	ld	s2,160(sp)
    80005022:	b771                	j	80004fae <sys_open+0xca>
    f->type = FD_DEVICE;
    80005024:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005028:	04649783          	lh	a5,70(s1)
    8000502c:	02f91223          	sh	a5,36(s2)
    80005030:	bf35                	j	80004f6c <sys_open+0x88>
    itrunc(ip);
    80005032:	8526                	mv	a0,s1
    80005034:	b86fe0ef          	jal	800033ba <itrunc>
    80005038:	b795                	j	80004f9c <sys_open+0xb8>

000000008000503a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000503a:	7175                	addi	sp,sp,-144
    8000503c:	e506                	sd	ra,136(sp)
    8000503e:	e122                	sd	s0,128(sp)
    80005040:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005042:	b3dfe0ef          	jal	80003b7e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005046:	08000613          	li	a2,128
    8000504a:	f7040593          	addi	a1,s0,-144
    8000504e:	4501                	li	a0,0
    80005050:	fcafd0ef          	jal	8000281a <argstr>
    80005054:	02054363          	bltz	a0,8000507a <sys_mkdir+0x40>
    80005058:	4681                	li	a3,0
    8000505a:	4601                	li	a2,0
    8000505c:	4585                	li	a1,1
    8000505e:	f7040513          	addi	a0,s0,-144
    80005062:	95dff0ef          	jal	800049be <create>
    80005066:	c911                	beqz	a0,8000507a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005068:	c6efe0ef          	jal	800034d6 <iunlockput>
  end_op();
    8000506c:	b7dfe0ef          	jal	80003be8 <end_op>
  return 0;
    80005070:	4501                	li	a0,0
}
    80005072:	60aa                	ld	ra,136(sp)
    80005074:	640a                	ld	s0,128(sp)
    80005076:	6149                	addi	sp,sp,144
    80005078:	8082                	ret
    end_op();
    8000507a:	b6ffe0ef          	jal	80003be8 <end_op>
    return -1;
    8000507e:	557d                	li	a0,-1
    80005080:	bfcd                	j	80005072 <sys_mkdir+0x38>

0000000080005082 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005082:	7135                	addi	sp,sp,-160
    80005084:	ed06                	sd	ra,152(sp)
    80005086:	e922                	sd	s0,144(sp)
    80005088:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000508a:	af5fe0ef          	jal	80003b7e <begin_op>
  argint(1, &major);
    8000508e:	f6c40593          	addi	a1,s0,-148
    80005092:	4505                	li	a0,1
    80005094:	f4efd0ef          	jal	800027e2 <argint>
  argint(2, &minor);
    80005098:	f6840593          	addi	a1,s0,-152
    8000509c:	4509                	li	a0,2
    8000509e:	f44fd0ef          	jal	800027e2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050a2:	08000613          	li	a2,128
    800050a6:	f7040593          	addi	a1,s0,-144
    800050aa:	4501                	li	a0,0
    800050ac:	f6efd0ef          	jal	8000281a <argstr>
    800050b0:	02054563          	bltz	a0,800050da <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800050b4:	f6841683          	lh	a3,-152(s0)
    800050b8:	f6c41603          	lh	a2,-148(s0)
    800050bc:	458d                	li	a1,3
    800050be:	f7040513          	addi	a0,s0,-144
    800050c2:	8fdff0ef          	jal	800049be <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050c6:	c911                	beqz	a0,800050da <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050c8:	c0efe0ef          	jal	800034d6 <iunlockput>
  end_op();
    800050cc:	b1dfe0ef          	jal	80003be8 <end_op>
  return 0;
    800050d0:	4501                	li	a0,0
}
    800050d2:	60ea                	ld	ra,152(sp)
    800050d4:	644a                	ld	s0,144(sp)
    800050d6:	610d                	addi	sp,sp,160
    800050d8:	8082                	ret
    end_op();
    800050da:	b0ffe0ef          	jal	80003be8 <end_op>
    return -1;
    800050de:	557d                	li	a0,-1
    800050e0:	bfcd                	j	800050d2 <sys_mknod+0x50>

00000000800050e2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800050e2:	7135                	addi	sp,sp,-160
    800050e4:	ed06                	sd	ra,152(sp)
    800050e6:	e922                	sd	s0,144(sp)
    800050e8:	e14a                	sd	s2,128(sp)
    800050ea:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800050ec:	ff0fc0ef          	jal	800018dc <myproc>
    800050f0:	892a                	mv	s2,a0
  
  begin_op();
    800050f2:	a8dfe0ef          	jal	80003b7e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800050f6:	08000613          	li	a2,128
    800050fa:	f6040593          	addi	a1,s0,-160
    800050fe:	4501                	li	a0,0
    80005100:	f1afd0ef          	jal	8000281a <argstr>
    80005104:	04054363          	bltz	a0,8000514a <sys_chdir+0x68>
    80005108:	e526                	sd	s1,136(sp)
    8000510a:	f6040513          	addi	a0,s0,-160
    8000510e:	8affe0ef          	jal	800039bc <namei>
    80005112:	84aa                	mv	s1,a0
    80005114:	c915                	beqz	a0,80005148 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005116:	9b6fe0ef          	jal	800032cc <ilock>
  if(ip->type != T_DIR){
    8000511a:	04449703          	lh	a4,68(s1)
    8000511e:	4785                	li	a5,1
    80005120:	02f71963          	bne	a4,a5,80005152 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005124:	8526                	mv	a0,s1
    80005126:	a54fe0ef          	jal	8000337a <iunlock>
  iput(p->cwd);
    8000512a:	15093503          	ld	a0,336(s2)
    8000512e:	b20fe0ef          	jal	8000344e <iput>
  end_op();
    80005132:	ab7fe0ef          	jal	80003be8 <end_op>
  p->cwd = ip;
    80005136:	14993823          	sd	s1,336(s2)
  return 0;
    8000513a:	4501                	li	a0,0
    8000513c:	64aa                	ld	s1,136(sp)
}
    8000513e:	60ea                	ld	ra,152(sp)
    80005140:	644a                	ld	s0,144(sp)
    80005142:	690a                	ld	s2,128(sp)
    80005144:	610d                	addi	sp,sp,160
    80005146:	8082                	ret
    80005148:	64aa                	ld	s1,136(sp)
    end_op();
    8000514a:	a9ffe0ef          	jal	80003be8 <end_op>
    return -1;
    8000514e:	557d                	li	a0,-1
    80005150:	b7fd                	j	8000513e <sys_chdir+0x5c>
    iunlockput(ip);
    80005152:	8526                	mv	a0,s1
    80005154:	b82fe0ef          	jal	800034d6 <iunlockput>
    end_op();
    80005158:	a91fe0ef          	jal	80003be8 <end_op>
    return -1;
    8000515c:	557d                	li	a0,-1
    8000515e:	64aa                	ld	s1,136(sp)
    80005160:	bff9                	j	8000513e <sys_chdir+0x5c>

0000000080005162 <sys_exec>:

uint64
sys_exec(void)
{
    80005162:	7105                	addi	sp,sp,-480
    80005164:	ef86                	sd	ra,472(sp)
    80005166:	eba2                	sd	s0,464(sp)
    80005168:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000516a:	e2840593          	addi	a1,s0,-472
    8000516e:	4505                	li	a0,1
    80005170:	e8efd0ef          	jal	800027fe <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005174:	08000613          	li	a2,128
    80005178:	f3040593          	addi	a1,s0,-208
    8000517c:	4501                	li	a0,0
    8000517e:	e9cfd0ef          	jal	8000281a <argstr>
    80005182:	87aa                	mv	a5,a0
    return -1;
    80005184:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005186:	0e07c063          	bltz	a5,80005266 <sys_exec+0x104>
    8000518a:	e7a6                	sd	s1,456(sp)
    8000518c:	e3ca                	sd	s2,448(sp)
    8000518e:	ff4e                	sd	s3,440(sp)
    80005190:	fb52                	sd	s4,432(sp)
    80005192:	f756                	sd	s5,424(sp)
    80005194:	f35a                	sd	s6,416(sp)
    80005196:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005198:	e3040a13          	addi	s4,s0,-464
    8000519c:	10000613          	li	a2,256
    800051a0:	4581                	li	a1,0
    800051a2:	8552                	mv	a0,s4
    800051a4:	b2bfb0ef          	jal	80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800051a8:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800051aa:	89d2                	mv	s3,s4
    800051ac:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051ae:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051b2:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800051b4:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051b8:	00391513          	slli	a0,s2,0x3
    800051bc:	85d6                	mv	a1,s5
    800051be:	e2843783          	ld	a5,-472(s0)
    800051c2:	953e                	add	a0,a0,a5
    800051c4:	d94fd0ef          	jal	80002758 <fetchaddr>
    800051c8:	02054663          	bltz	a0,800051f4 <sys_exec+0x92>
    if(uarg == 0){
    800051cc:	e2043783          	ld	a5,-480(s0)
    800051d0:	c7a1                	beqz	a5,80005218 <sys_exec+0xb6>
    argv[i] = kalloc();
    800051d2:	959fb0ef          	jal	80000b2a <kalloc>
    800051d6:	85aa                	mv	a1,a0
    800051d8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800051dc:	cd01                	beqz	a0,800051f4 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051de:	865a                	mv	a2,s6
    800051e0:	e2043503          	ld	a0,-480(s0)
    800051e4:	dbefd0ef          	jal	800027a2 <fetchstr>
    800051e8:	00054663          	bltz	a0,800051f4 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    800051ec:	0905                	addi	s2,s2,1
    800051ee:	09a1                	addi	s3,s3,8
    800051f0:	fd7914e3          	bne	s2,s7,800051b8 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051f4:	100a0a13          	addi	s4,s4,256
    800051f8:	6088                	ld	a0,0(s1)
    800051fa:	cd31                	beqz	a0,80005256 <sys_exec+0xf4>
    kfree(argv[i]);
    800051fc:	84dfb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005200:	04a1                	addi	s1,s1,8
    80005202:	ff449be3          	bne	s1,s4,800051f8 <sys_exec+0x96>
  return -1;
    80005206:	557d                	li	a0,-1
    80005208:	64be                	ld	s1,456(sp)
    8000520a:	691e                	ld	s2,448(sp)
    8000520c:	79fa                	ld	s3,440(sp)
    8000520e:	7a5a                	ld	s4,432(sp)
    80005210:	7aba                	ld	s5,424(sp)
    80005212:	7b1a                	ld	s6,416(sp)
    80005214:	6bfa                	ld	s7,408(sp)
    80005216:	a881                	j	80005266 <sys_exec+0x104>
      argv[i] = 0;
    80005218:	0009079b          	sext.w	a5,s2
    8000521c:	e3040593          	addi	a1,s0,-464
    80005220:	078e                	slli	a5,a5,0x3
    80005222:	97ae                	add	a5,a5,a1
    80005224:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80005228:	f3040513          	addi	a0,s0,-208
    8000522c:	ba4ff0ef          	jal	800045d0 <exec>
    80005230:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005232:	100a0a13          	addi	s4,s4,256
    80005236:	6088                	ld	a0,0(s1)
    80005238:	c511                	beqz	a0,80005244 <sys_exec+0xe2>
    kfree(argv[i]);
    8000523a:	80ffb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000523e:	04a1                	addi	s1,s1,8
    80005240:	ff449be3          	bne	s1,s4,80005236 <sys_exec+0xd4>
  return ret;
    80005244:	854a                	mv	a0,s2
    80005246:	64be                	ld	s1,456(sp)
    80005248:	691e                	ld	s2,448(sp)
    8000524a:	79fa                	ld	s3,440(sp)
    8000524c:	7a5a                	ld	s4,432(sp)
    8000524e:	7aba                	ld	s5,424(sp)
    80005250:	7b1a                	ld	s6,416(sp)
    80005252:	6bfa                	ld	s7,408(sp)
    80005254:	a809                	j	80005266 <sys_exec+0x104>
  return -1;
    80005256:	557d                	li	a0,-1
    80005258:	64be                	ld	s1,456(sp)
    8000525a:	691e                	ld	s2,448(sp)
    8000525c:	79fa                	ld	s3,440(sp)
    8000525e:	7a5a                	ld	s4,432(sp)
    80005260:	7aba                	ld	s5,424(sp)
    80005262:	7b1a                	ld	s6,416(sp)
    80005264:	6bfa                	ld	s7,408(sp)
}
    80005266:	60fe                	ld	ra,472(sp)
    80005268:	645e                	ld	s0,464(sp)
    8000526a:	613d                	addi	sp,sp,480
    8000526c:	8082                	ret

000000008000526e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000526e:	7139                	addi	sp,sp,-64
    80005270:	fc06                	sd	ra,56(sp)
    80005272:	f822                	sd	s0,48(sp)
    80005274:	f426                	sd	s1,40(sp)
    80005276:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005278:	e64fc0ef          	jal	800018dc <myproc>
    8000527c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000527e:	fd840593          	addi	a1,s0,-40
    80005282:	4501                	li	a0,0
    80005284:	d7afd0ef          	jal	800027fe <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005288:	fc840593          	addi	a1,s0,-56
    8000528c:	fd040513          	addi	a0,s0,-48
    80005290:	81eff0ef          	jal	800042ae <pipealloc>
    return -1;
    80005294:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005296:	0a054463          	bltz	a0,8000533e <sys_pipe+0xd0>
  fd0 = -1;
    8000529a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000529e:	fd043503          	ld	a0,-48(s0)
    800052a2:	edeff0ef          	jal	80004980 <fdalloc>
    800052a6:	fca42223          	sw	a0,-60(s0)
    800052aa:	08054163          	bltz	a0,8000532c <sys_pipe+0xbe>
    800052ae:	fc843503          	ld	a0,-56(s0)
    800052b2:	eceff0ef          	jal	80004980 <fdalloc>
    800052b6:	fca42023          	sw	a0,-64(s0)
    800052ba:	06054063          	bltz	a0,8000531a <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052be:	4691                	li	a3,4
    800052c0:	fc440613          	addi	a2,s0,-60
    800052c4:	fd843583          	ld	a1,-40(s0)
    800052c8:	68a8                	ld	a0,80(s1)
    800052ca:	abafc0ef          	jal	80001584 <copyout>
    800052ce:	00054e63          	bltz	a0,800052ea <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800052d2:	4691                	li	a3,4
    800052d4:	fc040613          	addi	a2,s0,-64
    800052d8:	fd843583          	ld	a1,-40(s0)
    800052dc:	95b6                	add	a1,a1,a3
    800052de:	68a8                	ld	a0,80(s1)
    800052e0:	aa4fc0ef          	jal	80001584 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800052e4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052e6:	04055c63          	bgez	a0,8000533e <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800052ea:	fc442783          	lw	a5,-60(s0)
    800052ee:	07e9                	addi	a5,a5,26
    800052f0:	078e                	slli	a5,a5,0x3
    800052f2:	97a6                	add	a5,a5,s1
    800052f4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800052f8:	fc042783          	lw	a5,-64(s0)
    800052fc:	07e9                	addi	a5,a5,26
    800052fe:	078e                	slli	a5,a5,0x3
    80005300:	94be                	add	s1,s1,a5
    80005302:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005306:	fd043503          	ld	a0,-48(s0)
    8000530a:	c95fe0ef          	jal	80003f9e <fileclose>
    fileclose(wf);
    8000530e:	fc843503          	ld	a0,-56(s0)
    80005312:	c8dfe0ef          	jal	80003f9e <fileclose>
    return -1;
    80005316:	57fd                	li	a5,-1
    80005318:	a01d                	j	8000533e <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000531a:	fc442783          	lw	a5,-60(s0)
    8000531e:	0007c763          	bltz	a5,8000532c <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005322:	07e9                	addi	a5,a5,26
    80005324:	078e                	slli	a5,a5,0x3
    80005326:	97a6                	add	a5,a5,s1
    80005328:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000532c:	fd043503          	ld	a0,-48(s0)
    80005330:	c6ffe0ef          	jal	80003f9e <fileclose>
    fileclose(wf);
    80005334:	fc843503          	ld	a0,-56(s0)
    80005338:	c67fe0ef          	jal	80003f9e <fileclose>
    return -1;
    8000533c:	57fd                	li	a5,-1
}
    8000533e:	853e                	mv	a0,a5
    80005340:	70e2                	ld	ra,56(sp)
    80005342:	7442                	ld	s0,48(sp)
    80005344:	74a2                	ld	s1,40(sp)
    80005346:	6121                	addi	sp,sp,64
    80005348:	8082                	ret
    8000534a:	0000                	unimp
    8000534c:	0000                	unimp
	...

0000000080005350 <kernelvec>:
    80005350:	7111                	addi	sp,sp,-256
    80005352:	e006                	sd	ra,0(sp)
    80005354:	e40a                	sd	sp,8(sp)
    80005356:	e80e                	sd	gp,16(sp)
    80005358:	ec12                	sd	tp,24(sp)
    8000535a:	f016                	sd	t0,32(sp)
    8000535c:	f41a                	sd	t1,40(sp)
    8000535e:	f81e                	sd	t2,48(sp)
    80005360:	e4aa                	sd	a0,72(sp)
    80005362:	e8ae                	sd	a1,80(sp)
    80005364:	ecb2                	sd	a2,88(sp)
    80005366:	f0b6                	sd	a3,96(sp)
    80005368:	f4ba                	sd	a4,104(sp)
    8000536a:	f8be                	sd	a5,112(sp)
    8000536c:	fcc2                	sd	a6,120(sp)
    8000536e:	e146                	sd	a7,128(sp)
    80005370:	edf2                	sd	t3,216(sp)
    80005372:	f1f6                	sd	t4,224(sp)
    80005374:	f5fa                	sd	t5,232(sp)
    80005376:	f9fe                	sd	t6,240(sp)
    80005378:	af0fd0ef          	jal	80002668 <kerneltrap>
    8000537c:	6082                	ld	ra,0(sp)
    8000537e:	6122                	ld	sp,8(sp)
    80005380:	61c2                	ld	gp,16(sp)
    80005382:	7282                	ld	t0,32(sp)
    80005384:	7322                	ld	t1,40(sp)
    80005386:	73c2                	ld	t2,48(sp)
    80005388:	6526                	ld	a0,72(sp)
    8000538a:	65c6                	ld	a1,80(sp)
    8000538c:	6666                	ld	a2,88(sp)
    8000538e:	7686                	ld	a3,96(sp)
    80005390:	7726                	ld	a4,104(sp)
    80005392:	77c6                	ld	a5,112(sp)
    80005394:	7866                	ld	a6,120(sp)
    80005396:	688a                	ld	a7,128(sp)
    80005398:	6e6e                	ld	t3,216(sp)
    8000539a:	7e8e                	ld	t4,224(sp)
    8000539c:	7f2e                	ld	t5,232(sp)
    8000539e:	7fce                	ld	t6,240(sp)
    800053a0:	6111                	addi	sp,sp,256
    800053a2:	10200073          	sret
	...

00000000800053ae <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800053ae:	1141                	addi	sp,sp,-16
    800053b0:	e406                	sd	ra,8(sp)
    800053b2:	e022                	sd	s0,0(sp)
    800053b4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800053b6:	0c000737          	lui	a4,0xc000
    800053ba:	4785                	li	a5,1
    800053bc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800053be:	c35c                	sw	a5,4(a4)
}
    800053c0:	60a2                	ld	ra,8(sp)
    800053c2:	6402                	ld	s0,0(sp)
    800053c4:	0141                	addi	sp,sp,16
    800053c6:	8082                	ret

00000000800053c8 <plicinithart>:

void
plicinithart(void)
{
    800053c8:	1141                	addi	sp,sp,-16
    800053ca:	e406                	sd	ra,8(sp)
    800053cc:	e022                	sd	s0,0(sp)
    800053ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800053d0:	cd8fc0ef          	jal	800018a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800053d4:	0085171b          	slliw	a4,a0,0x8
    800053d8:	0c0027b7          	lui	a5,0xc002
    800053dc:	97ba                	add	a5,a5,a4
    800053de:	40200713          	li	a4,1026
    800053e2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800053e6:	00d5151b          	slliw	a0,a0,0xd
    800053ea:	0c2017b7          	lui	a5,0xc201
    800053ee:	97aa                	add	a5,a5,a0
    800053f0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800053f4:	60a2                	ld	ra,8(sp)
    800053f6:	6402                	ld	s0,0(sp)
    800053f8:	0141                	addi	sp,sp,16
    800053fa:	8082                	ret

00000000800053fc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800053fc:	1141                	addi	sp,sp,-16
    800053fe:	e406                	sd	ra,8(sp)
    80005400:	e022                	sd	s0,0(sp)
    80005402:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005404:	ca4fc0ef          	jal	800018a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005408:	00d5151b          	slliw	a0,a0,0xd
    8000540c:	0c2017b7          	lui	a5,0xc201
    80005410:	97aa                	add	a5,a5,a0
  return irq;
}
    80005412:	43c8                	lw	a0,4(a5)
    80005414:	60a2                	ld	ra,8(sp)
    80005416:	6402                	ld	s0,0(sp)
    80005418:	0141                	addi	sp,sp,16
    8000541a:	8082                	ret

000000008000541c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000541c:	1101                	addi	sp,sp,-32
    8000541e:	ec06                	sd	ra,24(sp)
    80005420:	e822                	sd	s0,16(sp)
    80005422:	e426                	sd	s1,8(sp)
    80005424:	1000                	addi	s0,sp,32
    80005426:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005428:	c80fc0ef          	jal	800018a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000542c:	00d5179b          	slliw	a5,a0,0xd
    80005430:	0c201737          	lui	a4,0xc201
    80005434:	97ba                	add	a5,a5,a4
    80005436:	c3c4                	sw	s1,4(a5)
}
    80005438:	60e2                	ld	ra,24(sp)
    8000543a:	6442                	ld	s0,16(sp)
    8000543c:	64a2                	ld	s1,8(sp)
    8000543e:	6105                	addi	sp,sp,32
    80005440:	8082                	ret

0000000080005442 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005442:	1141                	addi	sp,sp,-16
    80005444:	e406                	sd	ra,8(sp)
    80005446:	e022                	sd	s0,0(sp)
    80005448:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000544a:	479d                	li	a5,7
    8000544c:	04a7ca63          	blt	a5,a0,800054a0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005450:	00024797          	auipc	a5,0x24
    80005454:	21078793          	addi	a5,a5,528 # 80029660 <disk>
    80005458:	97aa                	add	a5,a5,a0
    8000545a:	0187c783          	lbu	a5,24(a5)
    8000545e:	e7b9                	bnez	a5,800054ac <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005460:	00451693          	slli	a3,a0,0x4
    80005464:	00024797          	auipc	a5,0x24
    80005468:	1fc78793          	addi	a5,a5,508 # 80029660 <disk>
    8000546c:	6398                	ld	a4,0(a5)
    8000546e:	9736                	add	a4,a4,a3
    80005470:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005474:	6398                	ld	a4,0(a5)
    80005476:	9736                	add	a4,a4,a3
    80005478:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000547c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005480:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005484:	97aa                	add	a5,a5,a0
    80005486:	4705                	li	a4,1
    80005488:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000548c:	00024517          	auipc	a0,0x24
    80005490:	1ec50513          	addi	a0,a0,492 # 80029678 <disk+0x18>
    80005494:	ab7fc0ef          	jal	80001f4a <wakeup>
}
    80005498:	60a2                	ld	ra,8(sp)
    8000549a:	6402                	ld	s0,0(sp)
    8000549c:	0141                	addi	sp,sp,16
    8000549e:	8082                	ret
    panic("free_desc 1");
    800054a0:	00002517          	auipc	a0,0x2
    800054a4:	27050513          	addi	a0,a0,624 # 80007710 <etext+0x710>
    800054a8:	af6fb0ef          	jal	8000079e <panic>
    panic("free_desc 2");
    800054ac:	00002517          	auipc	a0,0x2
    800054b0:	27450513          	addi	a0,a0,628 # 80007720 <etext+0x720>
    800054b4:	aeafb0ef          	jal	8000079e <panic>

00000000800054b8 <virtio_disk_init>:
{
    800054b8:	1101                	addi	sp,sp,-32
    800054ba:	ec06                	sd	ra,24(sp)
    800054bc:	e822                	sd	s0,16(sp)
    800054be:	e426                	sd	s1,8(sp)
    800054c0:	e04a                	sd	s2,0(sp)
    800054c2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800054c4:	00002597          	auipc	a1,0x2
    800054c8:	26c58593          	addi	a1,a1,620 # 80007730 <etext+0x730>
    800054cc:	00024517          	auipc	a0,0x24
    800054d0:	2bc50513          	addi	a0,a0,700 # 80029788 <disk+0x128>
    800054d4:	ea6fb0ef          	jal	80000b7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054d8:	100017b7          	lui	a5,0x10001
    800054dc:	4398                	lw	a4,0(a5)
    800054de:	2701                	sext.w	a4,a4
    800054e0:	747277b7          	lui	a5,0x74727
    800054e4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800054e8:	14f71863          	bne	a4,a5,80005638 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054ec:	100017b7          	lui	a5,0x10001
    800054f0:	43dc                	lw	a5,4(a5)
    800054f2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054f4:	4709                	li	a4,2
    800054f6:	14e79163          	bne	a5,a4,80005638 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054fa:	100017b7          	lui	a5,0x10001
    800054fe:	479c                	lw	a5,8(a5)
    80005500:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005502:	12e79b63          	bne	a5,a4,80005638 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005506:	100017b7          	lui	a5,0x10001
    8000550a:	47d8                	lw	a4,12(a5)
    8000550c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000550e:	554d47b7          	lui	a5,0x554d4
    80005512:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005516:	12f71163          	bne	a4,a5,80005638 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000551a:	100017b7          	lui	a5,0x10001
    8000551e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005522:	4705                	li	a4,1
    80005524:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005526:	470d                	li	a4,3
    80005528:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000552a:	10001737          	lui	a4,0x10001
    8000552e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005530:	c7ffe6b7          	lui	a3,0xc7ffe
    80005534:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd4fbf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005538:	8f75                	and	a4,a4,a3
    8000553a:	100016b7          	lui	a3,0x10001
    8000553e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005540:	472d                	li	a4,11
    80005542:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005544:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005548:	439c                	lw	a5,0(a5)
    8000554a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000554e:	8ba1                	andi	a5,a5,8
    80005550:	0e078a63          	beqz	a5,80005644 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005554:	100017b7          	lui	a5,0x10001
    80005558:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000555c:	43fc                	lw	a5,68(a5)
    8000555e:	2781                	sext.w	a5,a5
    80005560:	0e079863          	bnez	a5,80005650 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005564:	100017b7          	lui	a5,0x10001
    80005568:	5bdc                	lw	a5,52(a5)
    8000556a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000556c:	0e078863          	beqz	a5,8000565c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005570:	471d                	li	a4,7
    80005572:	0ef77b63          	bgeu	a4,a5,80005668 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005576:	db4fb0ef          	jal	80000b2a <kalloc>
    8000557a:	00024497          	auipc	s1,0x24
    8000557e:	0e648493          	addi	s1,s1,230 # 80029660 <disk>
    80005582:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005584:	da6fb0ef          	jal	80000b2a <kalloc>
    80005588:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000558a:	da0fb0ef          	jal	80000b2a <kalloc>
    8000558e:	87aa                	mv	a5,a0
    80005590:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005592:	6088                	ld	a0,0(s1)
    80005594:	0e050063          	beqz	a0,80005674 <virtio_disk_init+0x1bc>
    80005598:	00024717          	auipc	a4,0x24
    8000559c:	0d073703          	ld	a4,208(a4) # 80029668 <disk+0x8>
    800055a0:	cb71                	beqz	a4,80005674 <virtio_disk_init+0x1bc>
    800055a2:	cbe9                	beqz	a5,80005674 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800055a4:	6605                	lui	a2,0x1
    800055a6:	4581                	li	a1,0
    800055a8:	f26fb0ef          	jal	80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    800055ac:	00024497          	auipc	s1,0x24
    800055b0:	0b448493          	addi	s1,s1,180 # 80029660 <disk>
    800055b4:	6605                	lui	a2,0x1
    800055b6:	4581                	li	a1,0
    800055b8:	6488                	ld	a0,8(s1)
    800055ba:	f14fb0ef          	jal	80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    800055be:	6605                	lui	a2,0x1
    800055c0:	4581                	li	a1,0
    800055c2:	6888                	ld	a0,16(s1)
    800055c4:	f0afb0ef          	jal	80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800055c8:	100017b7          	lui	a5,0x10001
    800055cc:	4721                	li	a4,8
    800055ce:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800055d0:	4098                	lw	a4,0(s1)
    800055d2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800055d6:	40d8                	lw	a4,4(s1)
    800055d8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800055dc:	649c                	ld	a5,8(s1)
    800055de:	0007869b          	sext.w	a3,a5
    800055e2:	10001737          	lui	a4,0x10001
    800055e6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800055ea:	9781                	srai	a5,a5,0x20
    800055ec:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800055f0:	689c                	ld	a5,16(s1)
    800055f2:	0007869b          	sext.w	a3,a5
    800055f6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800055fa:	9781                	srai	a5,a5,0x20
    800055fc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005600:	4785                	li	a5,1
    80005602:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005604:	00f48c23          	sb	a5,24(s1)
    80005608:	00f48ca3          	sb	a5,25(s1)
    8000560c:	00f48d23          	sb	a5,26(s1)
    80005610:	00f48da3          	sb	a5,27(s1)
    80005614:	00f48e23          	sb	a5,28(s1)
    80005618:	00f48ea3          	sb	a5,29(s1)
    8000561c:	00f48f23          	sb	a5,30(s1)
    80005620:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005624:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005628:	07272823          	sw	s2,112(a4)
}
    8000562c:	60e2                	ld	ra,24(sp)
    8000562e:	6442                	ld	s0,16(sp)
    80005630:	64a2                	ld	s1,8(sp)
    80005632:	6902                	ld	s2,0(sp)
    80005634:	6105                	addi	sp,sp,32
    80005636:	8082                	ret
    panic("could not find virtio disk");
    80005638:	00002517          	auipc	a0,0x2
    8000563c:	10850513          	addi	a0,a0,264 # 80007740 <etext+0x740>
    80005640:	95efb0ef          	jal	8000079e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005644:	00002517          	auipc	a0,0x2
    80005648:	11c50513          	addi	a0,a0,284 # 80007760 <etext+0x760>
    8000564c:	952fb0ef          	jal	8000079e <panic>
    panic("virtio disk should not be ready");
    80005650:	00002517          	auipc	a0,0x2
    80005654:	13050513          	addi	a0,a0,304 # 80007780 <etext+0x780>
    80005658:	946fb0ef          	jal	8000079e <panic>
    panic("virtio disk has no queue 0");
    8000565c:	00002517          	auipc	a0,0x2
    80005660:	14450513          	addi	a0,a0,324 # 800077a0 <etext+0x7a0>
    80005664:	93afb0ef          	jal	8000079e <panic>
    panic("virtio disk max queue too short");
    80005668:	00002517          	auipc	a0,0x2
    8000566c:	15850513          	addi	a0,a0,344 # 800077c0 <etext+0x7c0>
    80005670:	92efb0ef          	jal	8000079e <panic>
    panic("virtio disk kalloc");
    80005674:	00002517          	auipc	a0,0x2
    80005678:	16c50513          	addi	a0,a0,364 # 800077e0 <etext+0x7e0>
    8000567c:	922fb0ef          	jal	8000079e <panic>

0000000080005680 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005680:	711d                	addi	sp,sp,-96
    80005682:	ec86                	sd	ra,88(sp)
    80005684:	e8a2                	sd	s0,80(sp)
    80005686:	e4a6                	sd	s1,72(sp)
    80005688:	e0ca                	sd	s2,64(sp)
    8000568a:	fc4e                	sd	s3,56(sp)
    8000568c:	f852                	sd	s4,48(sp)
    8000568e:	f456                	sd	s5,40(sp)
    80005690:	f05a                	sd	s6,32(sp)
    80005692:	ec5e                	sd	s7,24(sp)
    80005694:	e862                	sd	s8,16(sp)
    80005696:	1080                	addi	s0,sp,96
    80005698:	89aa                	mv	s3,a0
    8000569a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000569c:	00c52b83          	lw	s7,12(a0)
    800056a0:	001b9b9b          	slliw	s7,s7,0x1
    800056a4:	1b82                	slli	s7,s7,0x20
    800056a6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800056aa:	00024517          	auipc	a0,0x24
    800056ae:	0de50513          	addi	a0,a0,222 # 80029788 <disk+0x128>
    800056b2:	d4cfb0ef          	jal	80000bfe <acquire>
  for(int i = 0; i < NUM; i++){
    800056b6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800056b8:	00024a97          	auipc	s5,0x24
    800056bc:	fa8a8a93          	addi	s5,s5,-88 # 80029660 <disk>
  for(int i = 0; i < 3; i++){
    800056c0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800056c2:	5c7d                	li	s8,-1
    800056c4:	a095                	j	80005728 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800056c6:	00fa8733          	add	a4,s5,a5
    800056ca:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800056ce:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800056d0:	0207c563          	bltz	a5,800056fa <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    800056d4:	2905                	addiw	s2,s2,1
    800056d6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800056d8:	05490c63          	beq	s2,s4,80005730 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800056dc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800056de:	00024717          	auipc	a4,0x24
    800056e2:	f8270713          	addi	a4,a4,-126 # 80029660 <disk>
    800056e6:	4781                	li	a5,0
    if(disk.free[i]){
    800056e8:	01874683          	lbu	a3,24(a4)
    800056ec:	fee9                	bnez	a3,800056c6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    800056ee:	2785                	addiw	a5,a5,1
    800056f0:	0705                	addi	a4,a4,1
    800056f2:	fe979be3          	bne	a5,s1,800056e8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    800056f6:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    800056fa:	01205d63          	blez	s2,80005714 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800056fe:	fa042503          	lw	a0,-96(s0)
    80005702:	d41ff0ef          	jal	80005442 <free_desc>
      for(int j = 0; j < i; j++)
    80005706:	4785                	li	a5,1
    80005708:	0127d663          	bge	a5,s2,80005714 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000570c:	fa442503          	lw	a0,-92(s0)
    80005710:	d33ff0ef          	jal	80005442 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005714:	00024597          	auipc	a1,0x24
    80005718:	07458593          	addi	a1,a1,116 # 80029788 <disk+0x128>
    8000571c:	00024517          	auipc	a0,0x24
    80005720:	f5c50513          	addi	a0,a0,-164 # 80029678 <disk+0x18>
    80005724:	fdafc0ef          	jal	80001efe <sleep>
  for(int i = 0; i < 3; i++){
    80005728:	fa040613          	addi	a2,s0,-96
    8000572c:	4901                	li	s2,0
    8000572e:	b77d                	j	800056dc <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005730:	fa042503          	lw	a0,-96(s0)
    80005734:	00451693          	slli	a3,a0,0x4

  if(write)
    80005738:	00024797          	auipc	a5,0x24
    8000573c:	f2878793          	addi	a5,a5,-216 # 80029660 <disk>
    80005740:	00a50713          	addi	a4,a0,10
    80005744:	0712                	slli	a4,a4,0x4
    80005746:	973e                	add	a4,a4,a5
    80005748:	01603633          	snez	a2,s6
    8000574c:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000574e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005752:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005756:	6398                	ld	a4,0(a5)
    80005758:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000575a:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    8000575e:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005760:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005762:	6390                	ld	a2,0(a5)
    80005764:	00d605b3          	add	a1,a2,a3
    80005768:	4741                	li	a4,16
    8000576a:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000576c:	4805                	li	a6,1
    8000576e:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005772:	fa442703          	lw	a4,-92(s0)
    80005776:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000577a:	0712                	slli	a4,a4,0x4
    8000577c:	963a                	add	a2,a2,a4
    8000577e:	05898593          	addi	a1,s3,88
    80005782:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005784:	0007b883          	ld	a7,0(a5)
    80005788:	9746                	add	a4,a4,a7
    8000578a:	40000613          	li	a2,1024
    8000578e:	c710                	sw	a2,8(a4)
  if(write)
    80005790:	001b3613          	seqz	a2,s6
    80005794:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005798:	01066633          	or	a2,a2,a6
    8000579c:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800057a0:	fa842583          	lw	a1,-88(s0)
    800057a4:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800057a8:	00250613          	addi	a2,a0,2
    800057ac:	0612                	slli	a2,a2,0x4
    800057ae:	963e                	add	a2,a2,a5
    800057b0:	577d                	li	a4,-1
    800057b2:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800057b6:	0592                	slli	a1,a1,0x4
    800057b8:	98ae                	add	a7,a7,a1
    800057ba:	03068713          	addi	a4,a3,48
    800057be:	973e                	add	a4,a4,a5
    800057c0:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800057c4:	6398                	ld	a4,0(a5)
    800057c6:	972e                	add	a4,a4,a1
    800057c8:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057cc:	4689                	li	a3,2
    800057ce:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800057d2:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800057d6:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    800057da:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800057de:	6794                	ld	a3,8(a5)
    800057e0:	0026d703          	lhu	a4,2(a3)
    800057e4:	8b1d                	andi	a4,a4,7
    800057e6:	0706                	slli	a4,a4,0x1
    800057e8:	96ba                	add	a3,a3,a4
    800057ea:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800057ee:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800057f2:	6798                	ld	a4,8(a5)
    800057f4:	00275783          	lhu	a5,2(a4)
    800057f8:	2785                	addiw	a5,a5,1
    800057fa:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800057fe:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005802:	100017b7          	lui	a5,0x10001
    80005806:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000580a:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    8000580e:	00024917          	auipc	s2,0x24
    80005812:	f7a90913          	addi	s2,s2,-134 # 80029788 <disk+0x128>
  while(b->disk == 1) {
    80005816:	84c2                	mv	s1,a6
    80005818:	01079a63          	bne	a5,a6,8000582c <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    8000581c:	85ca                	mv	a1,s2
    8000581e:	854e                	mv	a0,s3
    80005820:	edefc0ef          	jal	80001efe <sleep>
  while(b->disk == 1) {
    80005824:	0049a783          	lw	a5,4(s3)
    80005828:	fe978ae3          	beq	a5,s1,8000581c <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    8000582c:	fa042903          	lw	s2,-96(s0)
    80005830:	00290713          	addi	a4,s2,2
    80005834:	0712                	slli	a4,a4,0x4
    80005836:	00024797          	auipc	a5,0x24
    8000583a:	e2a78793          	addi	a5,a5,-470 # 80029660 <disk>
    8000583e:	97ba                	add	a5,a5,a4
    80005840:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005844:	00024997          	auipc	s3,0x24
    80005848:	e1c98993          	addi	s3,s3,-484 # 80029660 <disk>
    8000584c:	00491713          	slli	a4,s2,0x4
    80005850:	0009b783          	ld	a5,0(s3)
    80005854:	97ba                	add	a5,a5,a4
    80005856:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000585a:	854a                	mv	a0,s2
    8000585c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005860:	be3ff0ef          	jal	80005442 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005864:	8885                	andi	s1,s1,1
    80005866:	f0fd                	bnez	s1,8000584c <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005868:	00024517          	auipc	a0,0x24
    8000586c:	f2050513          	addi	a0,a0,-224 # 80029788 <disk+0x128>
    80005870:	c22fb0ef          	jal	80000c92 <release>
}
    80005874:	60e6                	ld	ra,88(sp)
    80005876:	6446                	ld	s0,80(sp)
    80005878:	64a6                	ld	s1,72(sp)
    8000587a:	6906                	ld	s2,64(sp)
    8000587c:	79e2                	ld	s3,56(sp)
    8000587e:	7a42                	ld	s4,48(sp)
    80005880:	7aa2                	ld	s5,40(sp)
    80005882:	7b02                	ld	s6,32(sp)
    80005884:	6be2                	ld	s7,24(sp)
    80005886:	6c42                	ld	s8,16(sp)
    80005888:	6125                	addi	sp,sp,96
    8000588a:	8082                	ret

000000008000588c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000588c:	1101                	addi	sp,sp,-32
    8000588e:	ec06                	sd	ra,24(sp)
    80005890:	e822                	sd	s0,16(sp)
    80005892:	e426                	sd	s1,8(sp)
    80005894:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005896:	00024497          	auipc	s1,0x24
    8000589a:	dca48493          	addi	s1,s1,-566 # 80029660 <disk>
    8000589e:	00024517          	auipc	a0,0x24
    800058a2:	eea50513          	addi	a0,a0,-278 # 80029788 <disk+0x128>
    800058a6:	b58fb0ef          	jal	80000bfe <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800058aa:	100017b7          	lui	a5,0x10001
    800058ae:	53bc                	lw	a5,96(a5)
    800058b0:	8b8d                	andi	a5,a5,3
    800058b2:	10001737          	lui	a4,0x10001
    800058b6:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800058b8:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058bc:	689c                	ld	a5,16(s1)
    800058be:	0204d703          	lhu	a4,32(s1)
    800058c2:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800058c6:	04f70663          	beq	a4,a5,80005912 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800058ca:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800058ce:	6898                	ld	a4,16(s1)
    800058d0:	0204d783          	lhu	a5,32(s1)
    800058d4:	8b9d                	andi	a5,a5,7
    800058d6:	078e                	slli	a5,a5,0x3
    800058d8:	97ba                	add	a5,a5,a4
    800058da:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800058dc:	00278713          	addi	a4,a5,2
    800058e0:	0712                	slli	a4,a4,0x4
    800058e2:	9726                	add	a4,a4,s1
    800058e4:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800058e8:	e321                	bnez	a4,80005928 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800058ea:	0789                	addi	a5,a5,2
    800058ec:	0792                	slli	a5,a5,0x4
    800058ee:	97a6                	add	a5,a5,s1
    800058f0:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800058f2:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800058f6:	e54fc0ef          	jal	80001f4a <wakeup>

    disk.used_idx += 1;
    800058fa:	0204d783          	lhu	a5,32(s1)
    800058fe:	2785                	addiw	a5,a5,1
    80005900:	17c2                	slli	a5,a5,0x30
    80005902:	93c1                	srli	a5,a5,0x30
    80005904:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005908:	6898                	ld	a4,16(s1)
    8000590a:	00275703          	lhu	a4,2(a4)
    8000590e:	faf71ee3          	bne	a4,a5,800058ca <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005912:	00024517          	auipc	a0,0x24
    80005916:	e7650513          	addi	a0,a0,-394 # 80029788 <disk+0x128>
    8000591a:	b78fb0ef          	jal	80000c92 <release>
}
    8000591e:	60e2                	ld	ra,24(sp)
    80005920:	6442                	ld	s0,16(sp)
    80005922:	64a2                	ld	s1,8(sp)
    80005924:	6105                	addi	sp,sp,32
    80005926:	8082                	ret
      panic("virtio_disk_intr status");
    80005928:	00002517          	auipc	a0,0x2
    8000592c:	ed050513          	addi	a0,a0,-304 # 800077f8 <etext+0x7f8>
    80005930:	e6ffa0ef          	jal	8000079e <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
