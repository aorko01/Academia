
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	b0010113          	addi	sp,sp,-1280 # 80007b00 <stack0>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd3dcf>
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
    80000106:	4b4020ef          	jal	800025ba <either_copyin>
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
    8000016a:	99a50513          	addi	a0,a0,-1638 # 8000fb00 <cons>
    8000016e:	291000ef          	jal	80000bfe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000172:	00010497          	auipc	s1,0x10
    80000176:	98e48493          	addi	s1,s1,-1650 # 8000fb00 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000017a:	00010917          	auipc	s2,0x10
    8000017e:	a1e90913          	addi	s2,s2,-1506 # 8000fb98 <cons+0x98>
  while(n > 0){
    80000182:	0b305b63          	blez	s3,80000238 <consoleread+0xee>
    while(cons.r == cons.w){
    80000186:	0984a783          	lw	a5,152(s1)
    8000018a:	09c4a703          	lw	a4,156(s1)
    8000018e:	0af71063          	bne	a4,a5,8000022e <consoleread+0xe4>
      if(killed(myproc())){
    80000192:	74a010ef          	jal	800018dc <myproc>
    80000196:	2bc020ef          	jal	80002452 <killed>
    8000019a:	e12d                	bnez	a0,800001fc <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    8000019c:	85a6                	mv	a1,s1
    8000019e:	854a                	mv	a0,s2
    800001a0:	07a020ef          	jal	8000221a <sleep>
    while(cons.r == cons.w){
    800001a4:	0984a783          	lw	a5,152(s1)
    800001a8:	09c4a703          	lw	a4,156(s1)
    800001ac:	fef703e3          	beq	a4,a5,80000192 <consoleread+0x48>
    800001b0:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001b2:	00010717          	auipc	a4,0x10
    800001b6:	94e70713          	addi	a4,a4,-1714 # 8000fb00 <cons>
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
    800001e4:	38c020ef          	jal	80002570 <either_copyout>
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
    80000200:	90450513          	addi	a0,a0,-1788 # 8000fb00 <cons>
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
    80000226:	96f72b23          	sw	a5,-1674(a4) # 8000fb98 <cons+0x98>
    8000022a:	6be2                	ld	s7,24(sp)
    8000022c:	a031                	j	80000238 <consoleread+0xee>
    8000022e:	ec5e                	sd	s7,24(sp)
    80000230:	b749                	j	800001b2 <consoleread+0x68>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	a011                	j	80000238 <consoleread+0xee>
    80000236:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000238:	00010517          	auipc	a0,0x10
    8000023c:	8c850513          	addi	a0,a0,-1848 # 8000fb00 <cons>
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
    8000028c:	00010517          	auipc	a0,0x10
    80000290:	87450513          	addi	a0,a0,-1932 # 8000fb00 <cons>
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
    800002ae:	356020ef          	jal	80002604 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002b2:	00010517          	auipc	a0,0x10
    800002b6:	84e50513          	addi	a0,a0,-1970 # 8000fb00 <cons>
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
    800002d0:	00010717          	auipc	a4,0x10
    800002d4:	83070713          	addi	a4,a4,-2000 # 8000fb00 <cons>
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
    800002f6:	00010797          	auipc	a5,0x10
    800002fa:	80a78793          	addi	a5,a5,-2038 # 8000fb00 <cons>
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
    80000322:	00010797          	auipc	a5,0x10
    80000326:	8767a783          	lw	a5,-1930(a5) # 8000fb98 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f8f711e3          	bne	a4,a5,800002b2 <consoleintr+0x32>
    80000334:	a85d                	j	800003ea <consoleintr+0x16a>
    80000336:	e84a                	sd	s2,16(sp)
    80000338:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    8000033a:	0000f717          	auipc	a4,0xf
    8000033e:	7c670713          	addi	a4,a4,1990 # 8000fb00 <cons>
    80000342:	0a072783          	lw	a5,160(a4)
    80000346:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	0000f497          	auipc	s1,0xf
    8000034e:	7b648493          	addi	s1,s1,1974 # 8000fb00 <cons>
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
    80000398:	76c70713          	addi	a4,a4,1900 # 8000fb00 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
    800003a4:	f0f707e3          	beq	a4,a5,800002b2 <consoleintr+0x32>
      cons.e--;
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	0000f717          	auipc	a4,0xf
    800003ae:	7ef72b23          	sw	a5,2038(a4) # 8000fba0 <cons+0xa0>
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
    800003cc:	73878793          	addi	a5,a5,1848 # 8000fb00 <cons>
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
    800003ee:	7ac7a923          	sw	a2,1970(a5) # 8000fb9c <cons+0x9c>
        wakeup(&cons.r);
    800003f2:	0000f517          	auipc	a0,0xf
    800003f6:	7a650513          	addi	a0,a0,1958 # 8000fb98 <cons+0x98>
    800003fa:	66d010ef          	jal	80002266 <wakeup>
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
    80000414:	6f050513          	addi	a0,a0,1776 # 8000fb00 <cons>
    80000418:	762000ef          	jal	80000b7a <initlock>

  uartinit();
    8000041c:	3ea000ef          	jal	80000806 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000420:	00029797          	auipc	a5,0x29
    80000424:	47878793          	addi	a5,a5,1144 # 80029898 <devsw>
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
    80000464:	42080813          	addi	a6,a6,1056 # 80007880 <digits>
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
    800004f0:	6d47a783          	lw	a5,1748(a5) # 8000fbc0 <pr+0x18>
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
    8000053c:	67050513          	addi	a0,a0,1648 # 8000fba8 <pr>
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
    800006fa:	18ab8b93          	addi	s7,s7,394 # 80007880 <digits>
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
    80000794:	41850513          	addi	a0,a0,1048 # 8000fba8 <pr>
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
    800007ae:	4007ab23          	sw	zero,1046(a5) # 8000fbc0 <pr+0x18>
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
    800007d2:	2ef72923          	sw	a5,754(a4) # 80007ac0 <panicked>
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
    800007e6:	3c648493          	addi	s1,s1,966 # 8000fba8 <pr>
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
    8000084c:	38050513          	addi	a0,a0,896 # 8000fbc8 <uart_tx_lock>
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
    80000870:	2547a783          	lw	a5,596(a5) # 80007ac0 <panicked>
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
    800008a6:	2267b783          	ld	a5,550(a5) # 80007ac8 <uart_tx_r>
    800008aa:	00007717          	auipc	a4,0x7
    800008ae:	22673703          	ld	a4,550(a4) # 80007ad0 <uart_tx_w>
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
    800008d4:	2f8a8a93          	addi	s5,s5,760 # 8000fbc8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d8:	00007497          	auipc	s1,0x7
    800008dc:	1f048493          	addi	s1,s1,496 # 80007ac8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008e0:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e4:	00007997          	auipc	s3,0x7
    800008e8:	1ec98993          	addi	s3,s3,492 # 80007ad0 <uart_tx_w>
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
    80000906:	161010ef          	jal	80002266 <wakeup>
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
    80000954:	27850513          	addi	a0,a0,632 # 8000fbc8 <uart_tx_lock>
    80000958:	2a6000ef          	jal	80000bfe <acquire>
  if(panicked){
    8000095c:	00007797          	auipc	a5,0x7
    80000960:	1647a783          	lw	a5,356(a5) # 80007ac0 <panicked>
    80000964:	efbd                	bnez	a5,800009e2 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000966:	00007717          	auipc	a4,0x7
    8000096a:	16a73703          	ld	a4,362(a4) # 80007ad0 <uart_tx_w>
    8000096e:	00007797          	auipc	a5,0x7
    80000972:	15a7b783          	ld	a5,346(a5) # 80007ac8 <uart_tx_r>
    80000976:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	0000f997          	auipc	s3,0xf
    8000097e:	24e98993          	addi	s3,s3,590 # 8000fbc8 <uart_tx_lock>
    80000982:	00007497          	auipc	s1,0x7
    80000986:	14648493          	addi	s1,s1,326 # 80007ac8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000098a:	00007917          	auipc	s2,0x7
    8000098e:	14690913          	addi	s2,s2,326 # 80007ad0 <uart_tx_w>
    80000992:	00e79d63          	bne	a5,a4,800009ac <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000996:	85ce                	mv	a1,s3
    80000998:	8526                	mv	a0,s1
    8000099a:	081010ef          	jal	8000221a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099e:	00093703          	ld	a4,0(s2)
    800009a2:	609c                	ld	a5,0(s1)
    800009a4:	02078793          	addi	a5,a5,32
    800009a8:	fee787e3          	beq	a5,a4,80000996 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009ac:	0000f497          	auipc	s1,0xf
    800009b0:	21c48493          	addi	s1,s1,540 # 8000fbc8 <uart_tx_lock>
    800009b4:	01f77793          	andi	a5,a4,31
    800009b8:	97a6                	add	a5,a5,s1
    800009ba:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009be:	0705                	addi	a4,a4,1
    800009c0:	00007797          	auipc	a5,0x7
    800009c4:	10e7b823          	sd	a4,272(a5) # 80007ad0 <uart_tx_w>
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
    80000a2a:	1a248493          	addi	s1,s1,418 # 8000fbc8 <uart_tx_lock>
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
    80000a5c:	0002a797          	auipc	a5,0x2a
    80000a60:	fd478793          	addi	a5,a5,-44 # 8002aa30 <end>
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
    80000a7c:	18890913          	addi	s2,s2,392 # 8000fc00 <kmem>
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
    80000b0a:	0fa50513          	addi	a0,a0,250 # 8000fc00 <kmem>
    80000b0e:	06c000ef          	jal	80000b7a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b12:	45c5                	li	a1,17
    80000b14:	05ee                	slli	a1,a1,0x1b
    80000b16:	0002a517          	auipc	a0,0x2a
    80000b1a:	f1a50513          	addi	a0,a0,-230 # 8002aa30 <end>
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
    80000b38:	0cc48493          	addi	s1,s1,204 # 8000fc00 <kmem>
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	0c0000ef          	jal	80000bfe <acquire>
  r = kmem.freelist;
    80000b42:	6c84                	ld	s1,24(s1)
  if(r)
    80000b44:	c485                	beqz	s1,80000b6c <kalloc+0x42>
    kmem.freelist = r->next;
    80000b46:	609c                	ld	a5,0(s1)
    80000b48:	0000f517          	auipc	a0,0xf
    80000b4c:	0b850513          	addi	a0,a0,184 # 8000fc00 <kmem>
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
    80000b70:	09450513          	addi	a0,a0,148 # 8000fc00 <kmem>
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
    80000d4c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd45d1>
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
    80000e94:	c4870713          	addi	a4,a4,-952 # 80007ad8 <started>
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
    80000eba:	07d010ef          	jal	80002736 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	16b040ef          	jal	80005828 <plicinithart>
  }

  scheduler();        
    80000ec2:	6c5000ef          	jal	80001d86 <scheduler>
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
    80000f02:	011010ef          	jal	80002712 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f06:	031010ef          	jal	80002736 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f0a:	105040ef          	jal	8000580e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f0e:	11b040ef          	jal	80005828 <plicinithart>
    binit();         // buffer cache
    80000f12:	07e020ef          	jal	80002f90 <binit>
    iinit();         // inode table
    80000f16:	64a020ef          	jal	80003560 <iinit>
    fileinit();      // file table
    80000f1a:	418030ef          	jal	80004332 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1e:	1fb040ef          	jal	80005918 <virtio_disk_init>
    userinit();      // first user process
    80000f22:	48d000ef          	jal	80001bae <userinit>
    __sync_synchronize();
    80000f26:	0330000f          	fence	rw,rw
    started = 1;
    80000f2a:	4785                	li	a5,1
    80000f2c:	00007717          	auipc	a4,0x7
    80000f30:	baf72623          	sw	a5,-1108(a4) # 80007ad8 <started>
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
    80000f46:	b9e7b783          	ld	a5,-1122(a5) # 80007ae0 <kernel_pagetable>
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
    800011d4:	90a7b823          	sd	a0,-1776(a5) # 80007ae0 <kernel_pagetable>
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
void proc_mapstacks(pagetable_t kpgtbl)
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

  for (p = proc; p < &proc[NPROC]; p++)
    80001774:	0000f497          	auipc	s1,0xf
    80001778:	8dc48493          	addi	s1,s1,-1828 # 80010050 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000177c:	8c26                	mv	s8,s1
    8000177e:	eb2fe7b7          	lui	a5,0xeb2fe
    80001782:	eb378793          	addi	a5,a5,-333 # ffffffffeb2fdeb3 <end+0xffffffff6b2d3483>
    80001786:	2fdeb937          	lui	s2,0x2fdeb
    8000178a:	2fe90913          	addi	s2,s2,766 # 2fdeb2fe <_entry-0x50214d02>
    8000178e:	1902                	slli	s2,s2,0x20
    80001790:	993e                	add	s2,s2,a5
    80001792:	040009b7          	lui	s3,0x4000
    80001796:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001798:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000179a:	4b99                	li	s7,6
    8000179c:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++)
    8000179e:	0001ea97          	auipc	s5,0x1e
    800017a2:	eb2a8a93          	addi	s5,s5,-334 # 8001f650 <tickslock>
    char *pa = kalloc();
    800017a6:	b84ff0ef          	jal	80000b2a <kalloc>
    800017aa:	862a                	mv	a2,a0
    if (pa == 0)
    800017ac:	c121                	beqz	a0,800017ec <proc_mapstacks+0x92>
    uint64 va = KSTACK((int)(p - proc));
    800017ae:	418485b3          	sub	a1,s1,s8
    800017b2:	858d                	srai	a1,a1,0x3
    800017b4:	032585b3          	mul	a1,a1,s2
    800017b8:	2585                	addiw	a1,a1,1
    800017ba:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017be:	875e                	mv	a4,s7
    800017c0:	86da                	mv	a3,s6
    800017c2:	40b985b3          	sub	a1,s3,a1
    800017c6:	8552                	mv	a0,s4
    800017c8:	929ff0ef          	jal	800010f0 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800017cc:	3d848493          	addi	s1,s1,984
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
void procinit(void)
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
    80001818:	40c50513          	addi	a0,a0,1036 # 8000fc20 <pid_lock>
    8000181c:	b5eff0ef          	jal	80000b7a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001820:	00006597          	auipc	a1,0x6
    80001824:	9e858593          	addi	a1,a1,-1560 # 80007208 <etext+0x208>
    80001828:	0000e517          	auipc	a0,0xe
    8000182c:	41050513          	addi	a0,a0,1040 # 8000fc38 <wait_lock>
    80001830:	b4aff0ef          	jal	80000b7a <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001834:	0000f497          	auipc	s1,0xf
    80001838:	81c48493          	addi	s1,s1,-2020 # 80010050 <proc>
  {
    initlock(&p->lock, "proc");
    8000183c:	00006b17          	auipc	s6,0x6
    80001840:	9dcb0b13          	addi	s6,s6,-1572 # 80007218 <etext+0x218>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001844:	8aa6                	mv	s5,s1
    80001846:	eb2fe7b7          	lui	a5,0xeb2fe
    8000184a:	eb378793          	addi	a5,a5,-333 # ffffffffeb2fdeb3 <end+0xffffffff6b2d3483>
    8000184e:	2fdeb937          	lui	s2,0x2fdeb
    80001852:	2fe90913          	addi	s2,s2,766 # 2fdeb2fe <_entry-0x50214d02>
    80001856:	1902                	slli	s2,s2,0x20
    80001858:	993e                	add	s2,s2,a5
    8000185a:	040009b7          	lui	s3,0x4000
    8000185e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001860:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001862:	0001ea17          	auipc	s4,0x1e
    80001866:	deea0a13          	addi	s4,s4,-530 # 8001f650 <tickslock>
    initlock(&p->lock, "proc");
    8000186a:	85da                	mv	a1,s6
    8000186c:	8526                	mv	a0,s1
    8000186e:	b0cff0ef          	jal	80000b7a <initlock>
    p->state = UNUSED;
    80001872:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001876:	415487b3          	sub	a5,s1,s5
    8000187a:	878d                	srai	a5,a5,0x3
    8000187c:	032787b3          	mul	a5,a5,s2
    80001880:	2785                	addiw	a5,a5,1
    80001882:	00d7979b          	slliw	a5,a5,0xd
    80001886:	40f987b3          	sub	a5,s3,a5
    8000188a:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    8000188c:	3d848493          	addi	s1,s1,984
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
int cpuid()
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
struct cpu *
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
    800018ce:	38650513          	addi	a0,a0,902 # 8000fc50 <cpus>
    800018d2:	953e                	add	a0,a0,a5
    800018d4:	60a2                	ld	ra,8(sp)
    800018d6:	6402                	ld	s0,0(sp)
    800018d8:	0141                	addi	sp,sp,16
    800018da:	8082                	ret

00000000800018dc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
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
    800018f4:	33070713          	addi	a4,a4,816 # 8000fc20 <pid_lock>
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
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
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

  if (first)
    8000191c:	00006797          	auipc	a5,0x6
    80001920:	1547a783          	lw	a5,340(a5) # 80007a70 <first.1>
    80001924:	e799                	bnez	a5,80001932 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001926:	62d000ef          	jal	80002752 <usertrapret>
}
    8000192a:	60a2                	ld	ra,8(sp)
    8000192c:	6402                	ld	s0,0(sp)
    8000192e:	0141                	addi	sp,sp,16
    80001930:	8082                	ret
    fsinit(ROOTDEV);
    80001932:	4505                	li	a0,1
    80001934:	3c1010ef          	jal	800034f4 <fsinit>
    first = 0;
    80001938:	00006797          	auipc	a5,0x6
    8000193c:	1207ac23          	sw	zero,312(a5) # 80007a70 <first.1>
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
    80001956:	2ce90913          	addi	s2,s2,718 # 8000fc20 <pid_lock>
    8000195a:	854a                	mv	a0,s2
    8000195c:	aa2ff0ef          	jal	80000bfe <acquire>
  pid = nextpid;
    80001960:	00006797          	auipc	a5,0x6
    80001964:	11878793          	addi	a5,a5,280 # 80007a78 <nextpid>
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
  if (pagetable == 0)
    80001998:	cd05                	beqz	a0,800019d0 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199a:	4729                	li	a4,10
    8000199c:	00004697          	auipc	a3,0x4
    800019a0:	66468693          	addi	a3,a3,1636 # 80006000 <_trampoline>
    800019a4:	6605                	lui	a2,0x1
    800019a6:	040005b7          	lui	a1,0x4000
    800019aa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019ac:	05b2                	slli	a1,a1,0xc
    800019ae:	e8cff0ef          	jal	8000103a <mappages>
    800019b2:	02054663          	bltz	a0,800019de <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
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
  if (p->trapframe)
    80001a5a:	6d28                	ld	a0,88(a0)
    80001a5c:	c119                	beqz	a0,80001a62 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001a5e:	febfe0ef          	jal	80000a48 <kfree>
  p->trapframe = 0;
    80001a62:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
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
  for (p = proc; p < &proc[NPROC]; p++)
    80001aaa:	0000e497          	auipc	s1,0xe
    80001aae:	5a648493          	addi	s1,s1,1446 # 80010050 <proc>
    80001ab2:	0001e917          	auipc	s2,0x1e
    80001ab6:	b9e90913          	addi	s2,s2,-1122 # 8001f650 <tickslock>
    acquire(&p->lock);
    80001aba:	8526                	mv	a0,s1
    80001abc:	942ff0ef          	jal	80000bfe <acquire>
    if (p->state == UNUSED)
    80001ac0:	4c9c                	lw	a5,24(s1)
    80001ac2:	cb91                	beqz	a5,80001ad6 <allocproc+0x38>
      release(&p->lock);
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	9ccff0ef          	jal	80000c92 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001aca:	3d848493          	addi	s1,s1,984
    80001ace:	ff2496e3          	bne	s1,s2,80001aba <allocproc+0x1c>
  return 0;
    80001ad2:	4481                	li	s1,0
    80001ad4:	a045                	j	80001b74 <allocproc+0xd6>
    80001ad6:	ec4e                	sd	s3,24(sp)
    80001ad8:	e852                	sd	s4,16(sp)
    80001ada:	e456                	sd	s5,8(sp)
  p->pid = allocpid();
    80001adc:	e6bff0ef          	jal	80001946 <allocpid>
    80001ae0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae2:	4785                	li	a5,1
    80001ae4:	cc9c                	sw	a5,24(s1)
  for (int i = 1; i <= NSYSCALL; i++)
    80001ae6:	00006997          	auipc	s3,0x6
    80001aea:	dba98993          	addi	s3,s3,-582 # 800078a0 <syscall_names+0x8>
    80001aee:	18048913          	addi	s2,s1,384
    80001af2:	00006a17          	auipc	s4,0x6
    80001af6:	e6ea0a13          	addi	s4,s4,-402 # 80007960 <states.0>
      safestrcpy(p->syscall_stats[i].syscall_name, syscall_names[i], sizeof(p->syscall_stats[i].syscall_name));
    80001afa:	4ac1                	li	s5,16
    80001afc:	a829                	j	80001b16 <allocproc+0x78>
    80001afe:	8656                	mv	a2,s5
    80001b00:	854a                	mv	a0,s2
    80001b02:	b1eff0ef          	jal	80000e20 <safestrcpy>
    p->syscall_stats[i].count = 0;
    80001b06:	00092823          	sw	zero,16(s2)
    p->syscall_stats[i].accum_time = 0;
    80001b0a:	00092a23          	sw	zero,20(s2)
  for (int i = 1; i <= NSYSCALL; i++)
    80001b0e:	09a1                	addi	s3,s3,8
    80001b10:	0961                	addi	s2,s2,24
    80001b12:	01498863          	beq	s3,s4,80001b22 <allocproc+0x84>
    if (syscall_names[i])
    80001b16:	0009b583          	ld	a1,0(s3)
    80001b1a:	f1f5                	bnez	a1,80001afe <allocproc+0x60>
      p->syscall_stats[i].syscall_name[0] = '\0';
    80001b1c:	00090023          	sb	zero,0(s2)
    80001b20:	b7dd                	j	80001b06 <allocproc+0x68>
  p->inq = 1;                    // Start in queue 1
    80001b22:	4785                	li	a5,1
    80001b24:	3cf4a423          	sw	a5,968(s1)
  p->curr_runtime = 0;           // Initialize runtime
    80001b28:	3c04a823          	sw	zero,976(s1)
  p->time_slices = 0;            // Initialize time slices
    80001b2c:	3c04a623          	sw	zero,972(s1)
  p->Original_tickets = 1;       // Default ticket count
    80001b30:	3cf4a023          	sw	a5,960(s1)
  p->Current_tickets = 1;        // Current ticket count
    80001b34:	3cf4a223          	sw	a5,964(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001b38:	ff3fe0ef          	jal	80000b2a <kalloc>
    80001b3c:	892a                	mv	s2,a0
    80001b3e:	eca8                	sd	a0,88(s1)
    80001b40:	c129                	beqz	a0,80001b82 <allocproc+0xe4>
  p->pagetable = proc_pagetable(p);
    80001b42:	8526                	mv	a0,s1
    80001b44:	e41ff0ef          	jal	80001984 <proc_pagetable>
    80001b48:	892a                	mv	s2,a0
    80001b4a:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001b4c:	c531                	beqz	a0,80001b98 <allocproc+0xfa>
  memset(&p->context, 0, sizeof(p->context));
    80001b4e:	07000613          	li	a2,112
    80001b52:	4581                	li	a1,0
    80001b54:	06048513          	addi	a0,s1,96
    80001b58:	976ff0ef          	jal	80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001b5c:	00000797          	auipc	a5,0x0
    80001b60:	db078793          	addi	a5,a5,-592 # 8000190c <forkret>
    80001b64:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b66:	60bc                	ld	a5,64(s1)
    80001b68:	6705                	lui	a4,0x1
    80001b6a:	97ba                	add	a5,a5,a4
    80001b6c:	f4bc                	sd	a5,104(s1)
    80001b6e:	69e2                	ld	s3,24(sp)
    80001b70:	6a42                	ld	s4,16(sp)
    80001b72:	6aa2                	ld	s5,8(sp)
}
    80001b74:	8526                	mv	a0,s1
    80001b76:	70e2                	ld	ra,56(sp)
    80001b78:	7442                	ld	s0,48(sp)
    80001b7a:	74a2                	ld	s1,40(sp)
    80001b7c:	7902                	ld	s2,32(sp)
    80001b7e:	6121                	addi	sp,sp,64
    80001b80:	8082                	ret
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
    80001b96:	bff9                	j	80001b74 <allocproc+0xd6>
    freeproc(p);
    80001b98:	8526                	mv	a0,s1
    80001b9a:	eb5ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	8f2ff0ef          	jal	80000c92 <release>
    return 0;
    80001ba4:	84ca                	mv	s1,s2
    80001ba6:	69e2                	ld	s3,24(sp)
    80001ba8:	6a42                	ld	s4,16(sp)
    80001baa:	6aa2                	ld	s5,8(sp)
    80001bac:	b7e1                	j	80001b74 <allocproc+0xd6>

0000000080001bae <userinit>:
{
    80001bae:	1101                	addi	sp,sp,-32
    80001bb0:	ec06                	sd	ra,24(sp)
    80001bb2:	e822                	sd	s0,16(sp)
    80001bb4:	e426                	sd	s1,8(sp)
    80001bb6:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bb8:	ee7ff0ef          	jal	80001a9e <allocproc>
    80001bbc:	84aa                	mv	s1,a0
  initproc = p;
    80001bbe:	00006797          	auipc	a5,0x6
    80001bc2:	f2a7b923          	sd	a0,-206(a5) # 80007af0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001bc6:	03400613          	li	a2,52
    80001bca:	00006597          	auipc	a1,0x6
    80001bce:	eb658593          	addi	a1,a1,-330 # 80007a80 <initcode>
    80001bd2:	6928                	ld	a0,80(a0)
    80001bd4:	eeeff0ef          	jal	800012c2 <uvmfirst>
  p->sz = PGSIZE;
    80001bd8:	6785                	lui	a5,0x1
    80001bda:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001bdc:	6cb8                	ld	a4,88(s1)
    80001bde:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001be2:	6cb8                	ld	a4,88(s1)
    80001be4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001be6:	4641                	li	a2,16
    80001be8:	00005597          	auipc	a1,0x5
    80001bec:	63858593          	addi	a1,a1,1592 # 80007220 <etext+0x220>
    80001bf0:	15848513          	addi	a0,s1,344
    80001bf4:	a2cff0ef          	jal	80000e20 <safestrcpy>
  p->cwd = namei("/");
    80001bf8:	00005517          	auipc	a0,0x5
    80001bfc:	63850513          	addi	a0,a0,1592 # 80007230 <etext+0x230>
    80001c00:	218020ef          	jal	80003e18 <namei>
    80001c04:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c08:	478d                	li	a5,3
    80001c0a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	884ff0ef          	jal	80000c92 <release>
}
    80001c12:	60e2                	ld	ra,24(sp)
    80001c14:	6442                	ld	s0,16(sp)
    80001c16:	64a2                	ld	s1,8(sp)
    80001c18:	6105                	addi	sp,sp,32
    80001c1a:	8082                	ret

0000000080001c1c <growproc>:
{
    80001c1c:	1101                	addi	sp,sp,-32
    80001c1e:	ec06                	sd	ra,24(sp)
    80001c20:	e822                	sd	s0,16(sp)
    80001c22:	e426                	sd	s1,8(sp)
    80001c24:	e04a                	sd	s2,0(sp)
    80001c26:	1000                	addi	s0,sp,32
    80001c28:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001c2a:	cb3ff0ef          	jal	800018dc <myproc>
    80001c2e:	84aa                	mv	s1,a0
  sz = p->sz;
    80001c30:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001c32:	01204c63          	bgtz	s2,80001c4a <growproc+0x2e>
  else if (n < 0)
    80001c36:	02094463          	bltz	s2,80001c5e <growproc+0x42>
  p->sz = sz;
    80001c3a:	e4ac                	sd	a1,72(s1)
  return 0;
    80001c3c:	4501                	li	a0,0
}
    80001c3e:	60e2                	ld	ra,24(sp)
    80001c40:	6442                	ld	s0,16(sp)
    80001c42:	64a2                	ld	s1,8(sp)
    80001c44:	6902                	ld	s2,0(sp)
    80001c46:	6105                	addi	sp,sp,32
    80001c48:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001c4a:	4691                	li	a3,4
    80001c4c:	00b90633          	add	a2,s2,a1
    80001c50:	6928                	ld	a0,80(a0)
    80001c52:	f12ff0ef          	jal	80001364 <uvmalloc>
    80001c56:	85aa                	mv	a1,a0
    80001c58:	f16d                	bnez	a0,80001c3a <growproc+0x1e>
      return -1;
    80001c5a:	557d                	li	a0,-1
    80001c5c:	b7cd                	j	80001c3e <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c5e:	00b90633          	add	a2,s2,a1
    80001c62:	6928                	ld	a0,80(a0)
    80001c64:	ebcff0ef          	jal	80001320 <uvmdealloc>
    80001c68:	85aa                	mv	a1,a0
    80001c6a:	bfc1                	j	80001c3a <growproc+0x1e>

0000000080001c6c <fork>:
{
    80001c6c:	7139                	addi	sp,sp,-64
    80001c6e:	fc06                	sd	ra,56(sp)
    80001c70:	f822                	sd	s0,48(sp)
    80001c72:	f04a                	sd	s2,32(sp)
    80001c74:	e456                	sd	s5,8(sp)
    80001c76:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c78:	c65ff0ef          	jal	800018dc <myproc>
    80001c7c:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001c7e:	e21ff0ef          	jal	80001a9e <allocproc>
    80001c82:	10050063          	beqz	a0,80001d82 <fork+0x116>
    80001c86:	ec4e                	sd	s3,24(sp)
    80001c88:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001c8a:	048ab603          	ld	a2,72(s5)
    80001c8e:	692c                	ld	a1,80(a0)
    80001c90:	050ab503          	ld	a0,80(s5)
    80001c94:	811ff0ef          	jal	800014a4 <uvmcopy>
    80001c98:	04054a63          	bltz	a0,80001cec <fork+0x80>
    80001c9c:	f426                	sd	s1,40(sp)
    80001c9e:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001ca0:	048ab783          	ld	a5,72(s5)
    80001ca4:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ca8:	058ab683          	ld	a3,88(s5)
    80001cac:	87b6                	mv	a5,a3
    80001cae:	0589b703          	ld	a4,88(s3)
    80001cb2:	12068693          	addi	a3,a3,288
    80001cb6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001cba:	6788                	ld	a0,8(a5)
    80001cbc:	6b8c                	ld	a1,16(a5)
    80001cbe:	6f90                	ld	a2,24(a5)
    80001cc0:	01073023          	sd	a6,0(a4)
    80001cc4:	e708                	sd	a0,8(a4)
    80001cc6:	eb0c                	sd	a1,16(a4)
    80001cc8:	ef10                	sd	a2,24(a4)
    80001cca:	02078793          	addi	a5,a5,32
    80001cce:	02070713          	addi	a4,a4,32
    80001cd2:	fed792e3          	bne	a5,a3,80001cb6 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001cd6:	0589b783          	ld	a5,88(s3)
    80001cda:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001cde:	0d0a8493          	addi	s1,s5,208
    80001ce2:	0d098913          	addi	s2,s3,208
    80001ce6:	150a8a13          	addi	s4,s5,336
    80001cea:	a831                	j	80001d06 <fork+0x9a>
    freeproc(np);
    80001cec:	854e                	mv	a0,s3
    80001cee:	d61ff0ef          	jal	80001a4e <freeproc>
    release(&np->lock);
    80001cf2:	854e                	mv	a0,s3
    80001cf4:	f9ffe0ef          	jal	80000c92 <release>
    return -1;
    80001cf8:	597d                	li	s2,-1
    80001cfa:	69e2                	ld	s3,24(sp)
    80001cfc:	a8a5                	j	80001d74 <fork+0x108>
  for (i = 0; i < NOFILE; i++)
    80001cfe:	04a1                	addi	s1,s1,8
    80001d00:	0921                	addi	s2,s2,8
    80001d02:	01448963          	beq	s1,s4,80001d14 <fork+0xa8>
    if (p->ofile[i])
    80001d06:	6088                	ld	a0,0(s1)
    80001d08:	d97d                	beqz	a0,80001cfe <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d0a:	6aa020ef          	jal	800043b4 <filedup>
    80001d0e:	00a93023          	sd	a0,0(s2)
    80001d12:	b7f5                	j	80001cfe <fork+0x92>
  np->cwd = idup(p->cwd);
    80001d14:	150ab503          	ld	a0,336(s5)
    80001d18:	1db010ef          	jal	800036f2 <idup>
    80001d1c:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d20:	4641                	li	a2,16
    80001d22:	158a8593          	addi	a1,s5,344
    80001d26:	15898513          	addi	a0,s3,344
    80001d2a:	8f6ff0ef          	jal	80000e20 <safestrcpy>
  pid = np->pid;
    80001d2e:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001d32:	854e                	mv	a0,s3
    80001d34:	f5ffe0ef          	jal	80000c92 <release>
  acquire(&wait_lock);
    80001d38:	0000e497          	auipc	s1,0xe
    80001d3c:	f0048493          	addi	s1,s1,-256 # 8000fc38 <wait_lock>
    80001d40:	8526                	mv	a0,s1
    80001d42:	ebdfe0ef          	jal	80000bfe <acquire>
  np->parent = p;
    80001d46:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d4a:	8526                	mv	a0,s1
    80001d4c:	f47fe0ef          	jal	80000c92 <release>
  acquire(&np->lock);
    80001d50:	854e                	mv	a0,s3
    80001d52:	eadfe0ef          	jal	80000bfe <acquire>
  np->state = RUNNABLE;
    80001d56:	478d                	li	a5,3
    80001d58:	00f9ac23          	sw	a5,24(s3)
  np->Current_tickets = p->Original_tickets;
    80001d5c:	3c0aa783          	lw	a5,960(s5)
    80001d60:	3cf9a223          	sw	a5,964(s3)
  np->Original_tickets = p->Original_tickets;
    80001d64:	3cf9a023          	sw	a5,960(s3)
  release(&np->lock);
    80001d68:	854e                	mv	a0,s3
    80001d6a:	f29fe0ef          	jal	80000c92 <release>
  return pid;
    80001d6e:	74a2                	ld	s1,40(sp)
    80001d70:	69e2                	ld	s3,24(sp)
    80001d72:	6a42                	ld	s4,16(sp)
}
    80001d74:	854a                	mv	a0,s2
    80001d76:	70e2                	ld	ra,56(sp)
    80001d78:	7442                	ld	s0,48(sp)
    80001d7a:	7902                	ld	s2,32(sp)
    80001d7c:	6aa2                	ld	s5,8(sp)
    80001d7e:	6121                	addi	sp,sp,64
    80001d80:	8082                	ret
    return -1;
    80001d82:	597d                	li	s2,-1
    80001d84:	bfc5                	j	80001d74 <fork+0x108>

0000000080001d86 <scheduler>:
void scheduler(void) {
    80001d86:	7109                	addi	sp,sp,-384
    80001d88:	fe86                	sd	ra,376(sp)
    80001d8a:	faa2                	sd	s0,368(sp)
    80001d8c:	f6a6                	sd	s1,360(sp)
    80001d8e:	f2ca                	sd	s2,352(sp)
    80001d90:	eece                	sd	s3,344(sp)
    80001d92:	ead2                	sd	s4,336(sp)
    80001d94:	e6d6                	sd	s5,328(sp)
    80001d96:	e2da                	sd	s6,320(sp)
    80001d98:	fe5e                	sd	s7,312(sp)
    80001d9a:	fa62                	sd	s8,304(sp)
    80001d9c:	f666                	sd	s9,296(sp)
    80001d9e:	f26a                	sd	s10,288(sp)
    80001da0:	ee6e                	sd	s11,280(sp)
    80001da2:	0300                	addi	s0,sp,384
    80001da4:	8792                	mv	a5,tp
  int id = r_tp();
    80001da6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001da8:	00779693          	slli	a3,a5,0x7
    80001dac:	0000e717          	auipc	a4,0xe
    80001db0:	e7470713          	addi	a4,a4,-396 # 8000fc20 <pid_lock>
    80001db4:	9736                	add	a4,a4,a3
    80001db6:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001dba:	0000e717          	auipc	a4,0xe
    80001dbe:	e9e70713          	addi	a4,a4,-354 # 8000fc58 <cpus+0x8>
    80001dc2:	9736                	add	a4,a4,a3
    80001dc4:	e8e43423          	sd	a4,-376(s0)
      if (lp->state == RUNNABLE && lp->Current_tickets > 0 && lp->inq == 1) {
    80001dc8:	490d                	li	s2,3
    80001dca:	4a85                	li	s5,1
          c->proc = p;
    80001dcc:	0000e717          	auipc	a4,0xe
    80001dd0:	e5470713          	addi	a4,a4,-428 # 8000fc20 <pid_lock>
    80001dd4:	00d707b3          	add	a5,a4,a3
    80001dd8:	e8f43023          	sd	a5,-384(s0)
    80001ddc:	a229                	j	80001ee6 <scheduler+0x160>
      release(&lp->lock);
    80001dde:	8552                	mv	a0,s4
    80001de0:	eb3fe0ef          	jal	80000c92 <release>
    for (int i = 0; i < NPROC; i++) {
    80001de4:	2985                	addiw	s3,s3,1
    80001de6:	3d848493          	addi	s1,s1,984
    80001dea:	03698a63          	beq	s3,s6,80001e1e <scheduler+0x98>
      acquire(&lp->lock);
    80001dee:	8a26                	mv	s4,s1
    80001df0:	8526                	mv	a0,s1
    80001df2:	e0dfe0ef          	jal	80000bfe <acquire>
      if (lp->state == RUNNABLE && lp->Current_tickets > 0 && lp->inq == 1) {
    80001df6:	4c9c                	lw	a5,24(s1)
    80001df8:	ff2793e3          	bne	a5,s2,80001dde <scheduler+0x58>
    80001dfc:	3c44a783          	lw	a5,964(s1)
    80001e00:	fcf05fe3          	blez	a5,80001dde <scheduler+0x58>
    80001e04:	3c84a703          	lw	a4,968(s1)
    80001e08:	fd571be3          	bne	a4,s5,80001dde <scheduler+0x58>
        total_tickets += lp->Current_tickets;
    80001e0c:	01878c3b          	addw	s8,a5,s8
        ticket_holders[holder_count++] = i;
    80001e10:	002b9793          	slli	a5,s7,0x2
    80001e14:	97e6                	add	a5,a5,s9
    80001e16:	0137a023          	sw	s3,0(a5)
    80001e1a:	2b85                	addiw	s7,s7,1 # fffffffffffff001 <end+0xffffffff7ffd45d1>
    80001e1c:	b7c9                	j	80001dde <scheduler+0x58>
    if (total_tickets > 0 && holder_count > 0) {
    80001e1e:	1d805a63          	blez	s8,80001ff2 <scheduler+0x26c>
    80001e22:	1f705763          	blez	s7,80002010 <scheduler+0x28a>
      seed = (1103515245 * seed + 12345) & 0x7fffffff;
    80001e26:	00006697          	auipc	a3,0x6
    80001e2a:	c4e68693          	addi	a3,a3,-946 # 80007a74 <seed.3>
    80001e2e:	429c                	lw	a5,0(a3)
    80001e30:	41c65737          	lui	a4,0x41c65
    80001e34:	e6d7071b          	addiw	a4,a4,-403 # 41c64e6d <_entry-0x3e39b193>
    80001e38:	02f7073b          	mulw	a4,a4,a5
    80001e3c:	678d                	lui	a5,0x3
    80001e3e:	0397879b          	addiw	a5,a5,57 # 3039 <_entry-0x7fffcfc7>
    80001e42:	9fb9                	addw	a5,a5,a4
    80001e44:	1786                	slli	a5,a5,0x21
    80001e46:	9385                	srli	a5,a5,0x21
    80001e48:	c29c                	sw	a5,0(a3)
      int winning_ticket = (seed % total_tickets) + 1;
    80001e4a:	0387f7bb          	remuw	a5,a5,s8
    80001e4e:	00178c9b          	addiw	s9,a5,1
      for (int j = 0; j < holder_count; j++) {
    80001e52:	e9040993          	addi	s3,s0,-368
    80001e56:	002b9b13          	slli	s6,s7,0x2
    80001e5a:	9b4e                	add	s6,s6,s3
      int ticket_sum = 0;
    80001e5c:	4d01                	li	s10,0
        acquire(&lp->lock);
    80001e5e:	3d800c13          	li	s8,984
    80001e62:	0000eb97          	auipc	s7,0xe
    80001e66:	1eeb8b93          	addi	s7,s7,494 # 80010050 <proc>
    80001e6a:	a039                	j	80001e78 <scheduler+0xf2>
        release(&lp->lock);
    80001e6c:	8526                	mv	a0,s1
    80001e6e:	e25fe0ef          	jal	80000c92 <release>
      for (int j = 0; j < holder_count; j++) {
    80001e72:	0991                	addi	s3,s3,4
    80001e74:	07698963          	beq	s3,s6,80001ee6 <scheduler+0x160>
        int proc_idx = ticket_holders[j];
    80001e78:	0009aa03          	lw	s4,0(s3)
        acquire(&lp->lock);
    80001e7c:	038a04b3          	mul	s1,s4,s8
    80001e80:	94de                	add	s1,s1,s7
    80001e82:	8526                	mv	a0,s1
    80001e84:	d7bfe0ef          	jal	80000bfe <acquire>
        if (lp->state == RUNNABLE && lp->Current_tickets > 0 && lp->inq == 1) {
    80001e88:	4c9c                	lw	a5,24(s1)
    80001e8a:	ff2791e3          	bne	a5,s2,80001e6c <scheduler+0xe6>
    80001e8e:	3c44a703          	lw	a4,964(s1)
    80001e92:	fce05de3          	blez	a4,80001e6c <scheduler+0xe6>
    80001e96:	3c84a783          	lw	a5,968(s1)
    80001e9a:	fd5799e3          	bne	a5,s5,80001e6c <scheduler+0xe6>
          ticket_sum += lp->Current_tickets;
    80001e9e:	01a70d3b          	addw	s10,a4,s10
          if (ticket_sum >= winning_ticket && winner_idx == -1) {
    80001ea2:	fd9d45e3          	blt	s10,s9,80001e6c <scheduler+0xe6>
      if (winner_idx != -1) {
    80001ea6:	57fd                	li	a5,-1
    80001ea8:	02fa0f63          	beq	s4,a5,80001ee6 <scheduler+0x160>
        struct proc *lp = &proc[winner_idx];
    80001eac:	3d800793          	li	a5,984
    80001eb0:	02fa07b3          	mul	a5,s4,a5
    80001eb4:	0000e497          	auipc	s1,0xe
    80001eb8:	19c48493          	addi	s1,s1,412 # 80010050 <proc>
    80001ebc:	94be                	add	s1,s1,a5
        if (lp->state == RUNNABLE && lp->Current_tickets > 0 && lp->inq == 1) {
    80001ebe:	3c44a703          	lw	a4,964(s1)
    80001ec2:	00e05f63          	blez	a4,80001ee0 <scheduler+0x15a>
    80001ec6:	3d800693          	li	a3,984
    80001eca:	02da06b3          	mul	a3,s4,a3
    80001ece:	0000e717          	auipc	a4,0xe
    80001ed2:	18270713          	addi	a4,a4,386 # 80010050 <proc>
    80001ed6:	9736                	add	a4,a4,a3
    80001ed8:	3c872703          	lw	a4,968(a4)
    80001edc:	03570763          	beq	a4,s5,80001f0a <scheduler+0x184>
        release(&lp->lock);
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	db1fe0ef          	jal	80000c92 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ee6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001eea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001eee:	10079073          	csrw	sstatus,a5
    for (int i = 0; i < NPROC; i++) {
    80001ef2:	0000e497          	auipc	s1,0xe
    80001ef6:	15e48493          	addi	s1,s1,350 # 80010050 <proc>
    80001efa:	4981                	li	s3,0
    int holder_count = 0;
    80001efc:	4b81                	li	s7,0
    int total_tickets = 0;
    80001efe:	4c01                	li	s8,0
        ticket_holders[holder_count++] = i;
    80001f00:	e9040c93          	addi	s9,s0,-368
    for (int i = 0; i < NPROC; i++) {
    80001f04:	04000b13          	li	s6,64
    80001f08:	b5dd                	j	80001dee <scheduler+0x68>
            swtch(&c->context, &lp->context);
    80001f0a:	0000e717          	auipc	a4,0xe
    80001f0e:	1a670713          	addi	a4,a4,422 # 800100b0 <proc+0x60>
    80001f12:	00e789b3          	add	s3,a5,a4
          while (lp->state == RUNNABLE && lp->curr_runtime < TIME_LIMIT_1) {
    80001f16:	0000eb17          	auipc	s6,0xe
    80001f1a:	13ab0b13          	addi	s6,s6,314 # 80010050 <proc>
    80001f1e:	9b36                	add	s6,s6,a3
            lp->state = RUNNING;
    80001f20:	4b91                	li	s7,4
          while (lp->state == RUNNABLE && lp->curr_runtime < TIME_LIMIT_1) {
    80001f22:	3d0b2783          	lw	a5,976(s6)
    80001f26:	04f04a63          	bgtz	a5,80001f7a <scheduler+0x1f4>
            lp->state = RUNNING;
    80001f2a:	017b2c23          	sw	s7,24(s6)
            c->proc = lp;
    80001f2e:	e8043c03          	ld	s8,-384(s0)
    80001f32:	029c3823          	sd	s1,48(s8) # 1030 <_entry-0x7fffefd0>
            swtch(&c->context, &lp->context);
    80001f36:	85ce                	mv	a1,s3
    80001f38:	e8843503          	ld	a0,-376(s0)
    80001f3c:	76c000ef          	jal	800026a8 <swtch>
            c->proc = 0;
    80001f40:	020c3823          	sd	zero,48(s8)
            lp->time_slices++;
    80001f44:	3ccb2783          	lw	a5,972(s6)
    80001f48:	2785                	addiw	a5,a5,1
    80001f4a:	3cfb2623          	sw	a5,972(s6)
            lp->curr_runtime++;
    80001f4e:	3d0b2783          	lw	a5,976(s6)
    80001f52:	2785                	addiw	a5,a5,1
    80001f54:	3cfb2823          	sw	a5,976(s6)
          while (lp->state == RUNNABLE && lp->curr_runtime < TIME_LIMIT_1) {
    80001f58:	018b2783          	lw	a5,24(s6)
    80001f5c:	fd2783e3          	beq	a5,s2,80001f22 <scheduler+0x19c>
          if (lp->curr_runtime >= TIME_LIMIT_1) {
    80001f60:	3d800713          	li	a4,984
    80001f64:	02ea0733          	mul	a4,s4,a4
    80001f68:	0000e797          	auipc	a5,0xe
    80001f6c:	0e878793          	addi	a5,a5,232 # 80010050 <proc>
    80001f70:	97ba                	add	a5,a5,a4
    80001f72:	3d07a783          	lw	a5,976(a5)
    80001f76:	00f05e63          	blez	a5,80001f92 <scheduler+0x20c>
            lp->inq = 2;
    80001f7a:	3d800713          	li	a4,984
    80001f7e:	02ea0733          	mul	a4,s4,a4
    80001f82:	0000e797          	auipc	a5,0xe
    80001f86:	0ce78793          	addi	a5,a5,206 # 80010050 <proc>
    80001f8a:	97ba                	add	a5,a5,a4
    80001f8c:	4709                	li	a4,2
    80001f8e:	3ce7a423          	sw	a4,968(a5)
          if (lp->Current_tickets > 0) {
    80001f92:	3d800713          	li	a4,984
    80001f96:	02ea0733          	mul	a4,s4,a4
    80001f9a:	0000e797          	auipc	a5,0xe
    80001f9e:	0b678793          	addi	a5,a5,182 # 80010050 <proc>
    80001fa2:	97ba                	add	a5,a5,a4
    80001fa4:	3c47a783          	lw	a5,964(a5)
    80001fa8:	00f05b63          	blez	a5,80001fbe <scheduler+0x238>
            lp->Current_tickets--;
    80001fac:	86ba                	mv	a3,a4
    80001fae:	0000e717          	auipc	a4,0xe
    80001fb2:	0a270713          	addi	a4,a4,162 # 80010050 <proc>
    80001fb6:	9736                	add	a4,a4,a3
    80001fb8:	37fd                	addiw	a5,a5,-1
    80001fba:	3cf72223          	sw	a5,964(a4)
          lp->curr_runtime = 0;
    80001fbe:	3d800713          	li	a4,984
    80001fc2:	02ea0733          	mul	a4,s4,a4
    80001fc6:	0000e797          	auipc	a5,0xe
    80001fca:	08a78793          	addi	a5,a5,138 # 80010050 <proc>
    80001fce:	97ba                	add	a5,a5,a4
    80001fd0:	3c07a823          	sw	zero,976(a5)
          last_idx = (winner_idx + 1) % NPROC;
    80001fd4:	2a05                	addiw	s4,s4,1
    80001fd6:	41fa571b          	sraiw	a4,s4,0x1f
    80001fda:	01a7571b          	srliw	a4,a4,0x1a
    80001fde:	014707bb          	addw	a5,a4,s4
    80001fe2:	03f7f793          	andi	a5,a5,63
    80001fe6:	9f99                	subw	a5,a5,a4
    80001fe8:	00006717          	auipc	a4,0x6
    80001fec:	b0f72023          	sw	a5,-1280(a4) # 80007ae8 <last_idx.2>
    80001ff0:	bdc5                	j	80001ee0 <scheduler+0x15a>
    80001ff2:	4a01                	li	s4,0
      int idx = (last_idx + i) % NPROC;
    80001ff4:	00006c97          	auipc	s9,0x6
    80001ff8:	af4c8c93          	addi	s9,s9,-1292 # 80007ae8 <last_idx.2>
    80001ffc:	3d800c13          	li	s8,984
      p = &proc[idx];
    80002000:	0000eb97          	auipc	s7,0xe
    80002004:	050b8b93          	addi	s7,s7,80 # 80010050 <proc>
      if (p->state == RUNNABLE && p->inq == 2) {
    80002008:	4d89                	li	s11,2
    for (int i = 0; i < NPROC; i++) {
    8000200a:	04000d13          	li	s10,64
    8000200e:	a809                	j	80002020 <scheduler+0x29a>
    80002010:	4a01                	li	s4,0
    80002012:	b7cd                	j	80001ff4 <scheduler+0x26e>
      release(&p->lock);
    80002014:	854e                	mv	a0,s3
    80002016:	c7dfe0ef          	jal	80000c92 <release>
    for (int i = 0; i < NPROC; i++) {
    8000201a:	2a05                	addiw	s4,s4,1
    8000201c:	11aa0363          	beq	s4,s10,80002122 <scheduler+0x39c>
      int idx = (last_idx + i) % NPROC;
    80002020:	000ca483          	lw	s1,0(s9)
    80002024:	014484bb          	addw	s1,s1,s4
    80002028:	41f4d79b          	sraiw	a5,s1,0x1f
    8000202c:	01a7d79b          	srliw	a5,a5,0x1a
    80002030:	9cbd                	addw	s1,s1,a5
    80002032:	03f4f493          	andi	s1,s1,63
    80002036:	9c9d                	subw	s1,s1,a5
      p = &proc[idx];
    80002038:	03848b33          	mul	s6,s1,s8
    8000203c:	017b09b3          	add	s3,s6,s7
      acquire(&p->lock);
    80002040:	854e                	mv	a0,s3
    80002042:	bbdfe0ef          	jal	80000bfe <acquire>
      if (p->state == RUNNABLE && p->inq == 2) {
    80002046:	0189a783          	lw	a5,24(s3)
    8000204a:	fd2795e3          	bne	a5,s2,80002014 <scheduler+0x28e>
    8000204e:	3c89a783          	lw	a5,968(s3)
    80002052:	fdb791e3          	bne	a5,s11,80002014 <scheduler+0x28e>
          swtch(&c->context, &p->context);
    80002056:	0000eb97          	auipc	s7,0xe
    8000205a:	05ab8b93          	addi	s7,s7,90 # 800100b0 <proc+0x60>
    8000205e:	9bda                	add	s7,s7,s6
    int found = 0;
    80002060:	4a01                	li	s4,0
        while (p->state == RUNNABLE && p->curr_runtime < TIME_LIMIT_2) {
    80002062:	3d800793          	li	a5,984
    80002066:	02f487b3          	mul	a5,s1,a5
    8000206a:	0000eb17          	auipc	s6,0xe
    8000206e:	fe6b0b13          	addi	s6,s6,-26 # 80010050 <proc>
    80002072:	9b3e                	add	s6,s6,a5
          p->state = RUNNING;
    80002074:	4c11                	li	s8,4
        while (p->state == RUNNABLE && p->curr_runtime < TIME_LIMIT_2) {
    80002076:	3d0b2783          	lw	a5,976(s6)
    8000207a:	04facb63          	blt	s5,a5,800020d0 <scheduler+0x34a>
          p->state = RUNNING;
    8000207e:	018b2c23          	sw	s8,24(s6)
          c->proc = p;
    80002082:	e8043a03          	ld	s4,-384(s0)
    80002086:	033a3823          	sd	s3,48(s4)
          swtch(&c->context, &p->context);
    8000208a:	85de                	mv	a1,s7
    8000208c:	e8843503          	ld	a0,-376(s0)
    80002090:	618000ef          	jal	800026a8 <swtch>
          c->proc = 0;
    80002094:	020a3823          	sd	zero,48(s4)
          p->time_slices++;
    80002098:	3ccb2783          	lw	a5,972(s6)
    8000209c:	2785                	addiw	a5,a5,1
    8000209e:	3cfb2623          	sw	a5,972(s6)
          p->curr_runtime++;
    800020a2:	3d0b2783          	lw	a5,976(s6)
    800020a6:	2785                	addiw	a5,a5,1
    800020a8:	3cfb2823          	sw	a5,976(s6)
        while (p->state == RUNNABLE && p->curr_runtime < TIME_LIMIT_2) {
    800020ac:	8a56                	mv	s4,s5
    800020ae:	018b2783          	lw	a5,24(s6)
    800020b2:	fd2782e3          	beq	a5,s2,80002076 <scheduler+0x2f0>
        if (p->curr_runtime >= TIME_LIMIT_2) {
    800020b6:	3d800713          	li	a4,984
    800020ba:	02e48733          	mul	a4,s1,a4
    800020be:	0000e797          	auipc	a5,0xe
    800020c2:	f9278793          	addi	a5,a5,-110 # 80010050 <proc>
    800020c6:	97ba                	add	a5,a5,a4
    800020c8:	3d07a783          	lw	a5,976(a5)
    800020cc:	00fadd63          	bge	s5,a5,800020e6 <scheduler+0x360>
          p->inq = 1;
    800020d0:	3d800713          	li	a4,984
    800020d4:	02e48733          	mul	a4,s1,a4
    800020d8:	0000e797          	auipc	a5,0xe
    800020dc:	f7878793          	addi	a5,a5,-136 # 80010050 <proc>
    800020e0:	97ba                	add	a5,a5,a4
    800020e2:	3d57a423          	sw	s5,968(a5)
        p->curr_runtime = 0;
    800020e6:	3d800713          	li	a4,984
    800020ea:	02e48733          	mul	a4,s1,a4
    800020ee:	0000e797          	auipc	a5,0xe
    800020f2:	f6278793          	addi	a5,a5,-158 # 80010050 <proc>
    800020f6:	97ba                	add	a5,a5,a4
    800020f8:	3c07a823          	sw	zero,976(a5)
        last_idx = (idx + 1) % NPROC;
    800020fc:	2485                	addiw	s1,s1,1
    800020fe:	41f4d71b          	sraiw	a4,s1,0x1f
    80002102:	01a7571b          	srliw	a4,a4,0x1a
    80002106:	009707bb          	addw	a5,a4,s1
    8000210a:	03f7f793          	andi	a5,a5,63
    8000210e:	9f99                	subw	a5,a5,a4
    80002110:	00006717          	auipc	a4,0x6
    80002114:	9cf72c23          	sw	a5,-1576(a4) # 80007ae8 <last_idx.2>
        release(&p->lock);
    80002118:	854e                	mv	a0,s3
    8000211a:	b79fe0ef          	jal	80000c92 <release>
    if (found == 0) {
    8000211e:	dc0a14e3          	bnez	s4,80001ee6 <scheduler+0x160>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002122:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002126:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000212a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000212e:	10500073          	wfi
    80002132:	bb55                	j	80001ee6 <scheduler+0x160>

0000000080002134 <sched>:
{
    80002134:	7179                	addi	sp,sp,-48
    80002136:	f406                	sd	ra,40(sp)
    80002138:	f022                	sd	s0,32(sp)
    8000213a:	ec26                	sd	s1,24(sp)
    8000213c:	e84a                	sd	s2,16(sp)
    8000213e:	e44e                	sd	s3,8(sp)
    80002140:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002142:	f9aff0ef          	jal	800018dc <myproc>
    80002146:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002148:	a4dfe0ef          	jal	80000b94 <holding>
    8000214c:	c92d                	beqz	a0,800021be <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000214e:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002150:	2781                	sext.w	a5,a5
    80002152:	079e                	slli	a5,a5,0x7
    80002154:	0000e717          	auipc	a4,0xe
    80002158:	acc70713          	addi	a4,a4,-1332 # 8000fc20 <pid_lock>
    8000215c:	97ba                	add	a5,a5,a4
    8000215e:	0a87a703          	lw	a4,168(a5)
    80002162:	4785                	li	a5,1
    80002164:	06f71363          	bne	a4,a5,800021ca <sched+0x96>
  if (p->state == RUNNING)
    80002168:	4c98                	lw	a4,24(s1)
    8000216a:	4791                	li	a5,4
    8000216c:	06f70563          	beq	a4,a5,800021d6 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002170:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002174:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002176:	e7b5                	bnez	a5,800021e2 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002178:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000217a:	0000e917          	auipc	s2,0xe
    8000217e:	aa690913          	addi	s2,s2,-1370 # 8000fc20 <pid_lock>
    80002182:	2781                	sext.w	a5,a5
    80002184:	079e                	slli	a5,a5,0x7
    80002186:	97ca                	add	a5,a5,s2
    80002188:	0ac7a983          	lw	s3,172(a5)
    8000218c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000218e:	2781                	sext.w	a5,a5
    80002190:	079e                	slli	a5,a5,0x7
    80002192:	0000e597          	auipc	a1,0xe
    80002196:	ac658593          	addi	a1,a1,-1338 # 8000fc58 <cpus+0x8>
    8000219a:	95be                	add	a1,a1,a5
    8000219c:	06048513          	addi	a0,s1,96
    800021a0:	508000ef          	jal	800026a8 <swtch>
    800021a4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021a6:	2781                	sext.w	a5,a5
    800021a8:	079e                	slli	a5,a5,0x7
    800021aa:	993e                	add	s2,s2,a5
    800021ac:	0b392623          	sw	s3,172(s2)
}
    800021b0:	70a2                	ld	ra,40(sp)
    800021b2:	7402                	ld	s0,32(sp)
    800021b4:	64e2                	ld	s1,24(sp)
    800021b6:	6942                	ld	s2,16(sp)
    800021b8:	69a2                	ld	s3,8(sp)
    800021ba:	6145                	addi	sp,sp,48
    800021bc:	8082                	ret
    panic("sched p->lock");
    800021be:	00005517          	auipc	a0,0x5
    800021c2:	07a50513          	addi	a0,a0,122 # 80007238 <etext+0x238>
    800021c6:	dd8fe0ef          	jal	8000079e <panic>
    panic("sched locks");
    800021ca:	00005517          	auipc	a0,0x5
    800021ce:	07e50513          	addi	a0,a0,126 # 80007248 <etext+0x248>
    800021d2:	dccfe0ef          	jal	8000079e <panic>
    panic("sched running");
    800021d6:	00005517          	auipc	a0,0x5
    800021da:	08250513          	addi	a0,a0,130 # 80007258 <etext+0x258>
    800021de:	dc0fe0ef          	jal	8000079e <panic>
    panic("sched interruptible");
    800021e2:	00005517          	auipc	a0,0x5
    800021e6:	08650513          	addi	a0,a0,134 # 80007268 <etext+0x268>
    800021ea:	db4fe0ef          	jal	8000079e <panic>

00000000800021ee <yield>:
{
    800021ee:	1101                	addi	sp,sp,-32
    800021f0:	ec06                	sd	ra,24(sp)
    800021f2:	e822                	sd	s0,16(sp)
    800021f4:	e426                	sd	s1,8(sp)
    800021f6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021f8:	ee4ff0ef          	jal	800018dc <myproc>
    800021fc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021fe:	a01fe0ef          	jal	80000bfe <acquire>
  p->state = RUNNABLE;
    80002202:	478d                	li	a5,3
    80002204:	cc9c                	sw	a5,24(s1)
  sched();
    80002206:	f2fff0ef          	jal	80002134 <sched>
  release(&p->lock);
    8000220a:	8526                	mv	a0,s1
    8000220c:	a87fe0ef          	jal	80000c92 <release>
}
    80002210:	60e2                	ld	ra,24(sp)
    80002212:	6442                	ld	s0,16(sp)
    80002214:	64a2                	ld	s1,8(sp)
    80002216:	6105                	addi	sp,sp,32
    80002218:	8082                	ret

000000008000221a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000221a:	7179                	addi	sp,sp,-48
    8000221c:	f406                	sd	ra,40(sp)
    8000221e:	f022                	sd	s0,32(sp)
    80002220:	ec26                	sd	s1,24(sp)
    80002222:	e84a                	sd	s2,16(sp)
    80002224:	e44e                	sd	s3,8(sp)
    80002226:	1800                	addi	s0,sp,48
    80002228:	89aa                	mv	s3,a0
    8000222a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000222c:	eb0ff0ef          	jal	800018dc <myproc>
    80002230:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002232:	9cdfe0ef          	jal	80000bfe <acquire>
  release(lk);
    80002236:	854a                	mv	a0,s2
    80002238:	a5bfe0ef          	jal	80000c92 <release>

  // Go to sleep.
  p->chan = chan;
    8000223c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002240:	4789                	li	a5,2
    80002242:	cc9c                	sw	a5,24(s1)

  sched();
    80002244:	ef1ff0ef          	jal	80002134 <sched>

  // Tidy up.
  p->chan = 0;
    80002248:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000224c:	8526                	mv	a0,s1
    8000224e:	a45fe0ef          	jal	80000c92 <release>
  acquire(lk);
    80002252:	854a                	mv	a0,s2
    80002254:	9abfe0ef          	jal	80000bfe <acquire>
}
    80002258:	70a2                	ld	ra,40(sp)
    8000225a:	7402                	ld	s0,32(sp)
    8000225c:	64e2                	ld	s1,24(sp)
    8000225e:	6942                	ld	s2,16(sp)
    80002260:	69a2                	ld	s3,8(sp)
    80002262:	6145                	addi	sp,sp,48
    80002264:	8082                	ret

0000000080002266 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002266:	7139                	addi	sp,sp,-64
    80002268:	fc06                	sd	ra,56(sp)
    8000226a:	f822                	sd	s0,48(sp)
    8000226c:	f426                	sd	s1,40(sp)
    8000226e:	f04a                	sd	s2,32(sp)
    80002270:	ec4e                	sd	s3,24(sp)
    80002272:	e852                	sd	s4,16(sp)
    80002274:	e456                	sd	s5,8(sp)
    80002276:	0080                	addi	s0,sp,64
    80002278:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000227a:	0000e497          	auipc	s1,0xe
    8000227e:	dd648493          	addi	s1,s1,-554 # 80010050 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002282:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002284:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002286:	0001d917          	auipc	s2,0x1d
    8000228a:	3ca90913          	addi	s2,s2,970 # 8001f650 <tickslock>
    8000228e:	a801                	j	8000229e <wakeup+0x38>
      }
      release(&p->lock);
    80002290:	8526                	mv	a0,s1
    80002292:	a01fe0ef          	jal	80000c92 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002296:	3d848493          	addi	s1,s1,984
    8000229a:	03248263          	beq	s1,s2,800022be <wakeup+0x58>
    if (p != myproc())
    8000229e:	e3eff0ef          	jal	800018dc <myproc>
    800022a2:	fea48ae3          	beq	s1,a0,80002296 <wakeup+0x30>
      acquire(&p->lock);
    800022a6:	8526                	mv	a0,s1
    800022a8:	957fe0ef          	jal	80000bfe <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800022ac:	4c9c                	lw	a5,24(s1)
    800022ae:	ff3791e3          	bne	a5,s3,80002290 <wakeup+0x2a>
    800022b2:	709c                	ld	a5,32(s1)
    800022b4:	fd479ee3          	bne	a5,s4,80002290 <wakeup+0x2a>
        p->state = RUNNABLE;
    800022b8:	0154ac23          	sw	s5,24(s1)
    800022bc:	bfd1                	j	80002290 <wakeup+0x2a>
    }
  }
}
    800022be:	70e2                	ld	ra,56(sp)
    800022c0:	7442                	ld	s0,48(sp)
    800022c2:	74a2                	ld	s1,40(sp)
    800022c4:	7902                	ld	s2,32(sp)
    800022c6:	69e2                	ld	s3,24(sp)
    800022c8:	6a42                	ld	s4,16(sp)
    800022ca:	6aa2                	ld	s5,8(sp)
    800022cc:	6121                	addi	sp,sp,64
    800022ce:	8082                	ret

00000000800022d0 <reparent>:
{
    800022d0:	7179                	addi	sp,sp,-48
    800022d2:	f406                	sd	ra,40(sp)
    800022d4:	f022                	sd	s0,32(sp)
    800022d6:	ec26                	sd	s1,24(sp)
    800022d8:	e84a                	sd	s2,16(sp)
    800022da:	e44e                	sd	s3,8(sp)
    800022dc:	e052                	sd	s4,0(sp)
    800022de:	1800                	addi	s0,sp,48
    800022e0:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800022e2:	0000e497          	auipc	s1,0xe
    800022e6:	d6e48493          	addi	s1,s1,-658 # 80010050 <proc>
      pp->parent = initproc;
    800022ea:	00006a17          	auipc	s4,0x6
    800022ee:	806a0a13          	addi	s4,s4,-2042 # 80007af0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800022f2:	0001d997          	auipc	s3,0x1d
    800022f6:	35e98993          	addi	s3,s3,862 # 8001f650 <tickslock>
    800022fa:	a029                	j	80002304 <reparent+0x34>
    800022fc:	3d848493          	addi	s1,s1,984
    80002300:	01348b63          	beq	s1,s3,80002316 <reparent+0x46>
    if (pp->parent == p)
    80002304:	7c9c                	ld	a5,56(s1)
    80002306:	ff279be3          	bne	a5,s2,800022fc <reparent+0x2c>
      pp->parent = initproc;
    8000230a:	000a3503          	ld	a0,0(s4)
    8000230e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002310:	f57ff0ef          	jal	80002266 <wakeup>
    80002314:	b7e5                	j	800022fc <reparent+0x2c>
}
    80002316:	70a2                	ld	ra,40(sp)
    80002318:	7402                	ld	s0,32(sp)
    8000231a:	64e2                	ld	s1,24(sp)
    8000231c:	6942                	ld	s2,16(sp)
    8000231e:	69a2                	ld	s3,8(sp)
    80002320:	6a02                	ld	s4,0(sp)
    80002322:	6145                	addi	sp,sp,48
    80002324:	8082                	ret

0000000080002326 <exit>:
{
    80002326:	7179                	addi	sp,sp,-48
    80002328:	f406                	sd	ra,40(sp)
    8000232a:	f022                	sd	s0,32(sp)
    8000232c:	ec26                	sd	s1,24(sp)
    8000232e:	e84a                	sd	s2,16(sp)
    80002330:	e44e                	sd	s3,8(sp)
    80002332:	e052                	sd	s4,0(sp)
    80002334:	1800                	addi	s0,sp,48
    80002336:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002338:	da4ff0ef          	jal	800018dc <myproc>
    8000233c:	89aa                	mv	s3,a0
  if (p == initproc)
    8000233e:	00005797          	auipc	a5,0x5
    80002342:	7b27b783          	ld	a5,1970(a5) # 80007af0 <initproc>
    80002346:	0d050493          	addi	s1,a0,208
    8000234a:	15050913          	addi	s2,a0,336
    8000234e:	00a79b63          	bne	a5,a0,80002364 <exit+0x3e>
    panic("init exiting");
    80002352:	00005517          	auipc	a0,0x5
    80002356:	f2e50513          	addi	a0,a0,-210 # 80007280 <etext+0x280>
    8000235a:	c44fe0ef          	jal	8000079e <panic>
  for (int fd = 0; fd < NOFILE; fd++)
    8000235e:	04a1                	addi	s1,s1,8
    80002360:	01248963          	beq	s1,s2,80002372 <exit+0x4c>
    if (p->ofile[fd])
    80002364:	6088                	ld	a0,0(s1)
    80002366:	dd65                	beqz	a0,8000235e <exit+0x38>
      fileclose(f);
    80002368:	092020ef          	jal	800043fa <fileclose>
      p->ofile[fd] = 0;
    8000236c:	0004b023          	sd	zero,0(s1)
    80002370:	b7fd                	j	8000235e <exit+0x38>
  begin_op();
    80002372:	469010ef          	jal	80003fda <begin_op>
  iput(p->cwd);
    80002376:	1509b503          	ld	a0,336(s3)
    8000237a:	530010ef          	jal	800038aa <iput>
  end_op();
    8000237e:	4c7010ef          	jal	80004044 <end_op>
  p->cwd = 0;
    80002382:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002386:	0000e497          	auipc	s1,0xe
    8000238a:	8b248493          	addi	s1,s1,-1870 # 8000fc38 <wait_lock>
    8000238e:	8526                	mv	a0,s1
    80002390:	86ffe0ef          	jal	80000bfe <acquire>
  reparent(p);
    80002394:	854e                	mv	a0,s3
    80002396:	f3bff0ef          	jal	800022d0 <reparent>
  wakeup(p->parent);
    8000239a:	0389b503          	ld	a0,56(s3)
    8000239e:	ec9ff0ef          	jal	80002266 <wakeup>
  acquire(&p->lock);
    800023a2:	854e                	mv	a0,s3
    800023a4:	85bfe0ef          	jal	80000bfe <acquire>
  p->xstate = status;
    800023a8:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023ac:	4795                	li	a5,5
    800023ae:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023b2:	8526                	mv	a0,s1
    800023b4:	8dffe0ef          	jal	80000c92 <release>
  sched();
    800023b8:	d7dff0ef          	jal	80002134 <sched>
  panic("zombie exit");
    800023bc:	00005517          	auipc	a0,0x5
    800023c0:	ed450513          	addi	a0,a0,-300 # 80007290 <etext+0x290>
    800023c4:	bdafe0ef          	jal	8000079e <panic>

00000000800023c8 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800023c8:	7179                	addi	sp,sp,-48
    800023ca:	f406                	sd	ra,40(sp)
    800023cc:	f022                	sd	s0,32(sp)
    800023ce:	ec26                	sd	s1,24(sp)
    800023d0:	e84a                	sd	s2,16(sp)
    800023d2:	e44e                	sd	s3,8(sp)
    800023d4:	1800                	addi	s0,sp,48
    800023d6:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023d8:	0000e497          	auipc	s1,0xe
    800023dc:	c7848493          	addi	s1,s1,-904 # 80010050 <proc>
    800023e0:	0001d997          	auipc	s3,0x1d
    800023e4:	27098993          	addi	s3,s3,624 # 8001f650 <tickslock>
  {
    acquire(&p->lock);
    800023e8:	8526                	mv	a0,s1
    800023ea:	815fe0ef          	jal	80000bfe <acquire>
    if (p->pid == pid)
    800023ee:	589c                	lw	a5,48(s1)
    800023f0:	01278b63          	beq	a5,s2,80002406 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023f4:	8526                	mv	a0,s1
    800023f6:	89dfe0ef          	jal	80000c92 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023fa:	3d848493          	addi	s1,s1,984
    800023fe:	ff3495e3          	bne	s1,s3,800023e8 <kill+0x20>
  }
  return -1;
    80002402:	557d                	li	a0,-1
    80002404:	a819                	j	8000241a <kill+0x52>
      p->killed = 1;
    80002406:	4785                	li	a5,1
    80002408:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000240a:	4c98                	lw	a4,24(s1)
    8000240c:	4789                	li	a5,2
    8000240e:	00f70d63          	beq	a4,a5,80002428 <kill+0x60>
      release(&p->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	87ffe0ef          	jal	80000c92 <release>
      return 0;
    80002418:	4501                	li	a0,0
}
    8000241a:	70a2                	ld	ra,40(sp)
    8000241c:	7402                	ld	s0,32(sp)
    8000241e:	64e2                	ld	s1,24(sp)
    80002420:	6942                	ld	s2,16(sp)
    80002422:	69a2                	ld	s3,8(sp)
    80002424:	6145                	addi	sp,sp,48
    80002426:	8082                	ret
        p->state = RUNNABLE;
    80002428:	478d                	li	a5,3
    8000242a:	cc9c                	sw	a5,24(s1)
    8000242c:	b7dd                	j	80002412 <kill+0x4a>

000000008000242e <setkilled>:

void setkilled(struct proc *p)
{
    8000242e:	1101                	addi	sp,sp,-32
    80002430:	ec06                	sd	ra,24(sp)
    80002432:	e822                	sd	s0,16(sp)
    80002434:	e426                	sd	s1,8(sp)
    80002436:	1000                	addi	s0,sp,32
    80002438:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000243a:	fc4fe0ef          	jal	80000bfe <acquire>
  p->killed = 1;
    8000243e:	4785                	li	a5,1
    80002440:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002442:	8526                	mv	a0,s1
    80002444:	84ffe0ef          	jal	80000c92 <release>
}
    80002448:	60e2                	ld	ra,24(sp)
    8000244a:	6442                	ld	s0,16(sp)
    8000244c:	64a2                	ld	s1,8(sp)
    8000244e:	6105                	addi	sp,sp,32
    80002450:	8082                	ret

0000000080002452 <killed>:

int killed(struct proc *p)
{
    80002452:	1101                	addi	sp,sp,-32
    80002454:	ec06                	sd	ra,24(sp)
    80002456:	e822                	sd	s0,16(sp)
    80002458:	e426                	sd	s1,8(sp)
    8000245a:	e04a                	sd	s2,0(sp)
    8000245c:	1000                	addi	s0,sp,32
    8000245e:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002460:	f9efe0ef          	jal	80000bfe <acquire>
  k = p->killed;
    80002464:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	829fe0ef          	jal	80000c92 <release>
  return k;
}
    8000246e:	854a                	mv	a0,s2
    80002470:	60e2                	ld	ra,24(sp)
    80002472:	6442                	ld	s0,16(sp)
    80002474:	64a2                	ld	s1,8(sp)
    80002476:	6902                	ld	s2,0(sp)
    80002478:	6105                	addi	sp,sp,32
    8000247a:	8082                	ret

000000008000247c <wait>:
{
    8000247c:	715d                	addi	sp,sp,-80
    8000247e:	e486                	sd	ra,72(sp)
    80002480:	e0a2                	sd	s0,64(sp)
    80002482:	fc26                	sd	s1,56(sp)
    80002484:	f84a                	sd	s2,48(sp)
    80002486:	f44e                	sd	s3,40(sp)
    80002488:	f052                	sd	s4,32(sp)
    8000248a:	ec56                	sd	s5,24(sp)
    8000248c:	e85a                	sd	s6,16(sp)
    8000248e:	e45e                	sd	s7,8(sp)
    80002490:	0880                	addi	s0,sp,80
    80002492:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002494:	c48ff0ef          	jal	800018dc <myproc>
    80002498:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000249a:	0000d517          	auipc	a0,0xd
    8000249e:	79e50513          	addi	a0,a0,1950 # 8000fc38 <wait_lock>
    800024a2:	f5cfe0ef          	jal	80000bfe <acquire>
        if (pp->state == ZOMBIE)
    800024a6:	4a15                	li	s4,5
        havekids = 1;
    800024a8:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024aa:	0001d997          	auipc	s3,0x1d
    800024ae:	1a698993          	addi	s3,s3,422 # 8001f650 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024b2:	0000db97          	auipc	s7,0xd
    800024b6:	786b8b93          	addi	s7,s7,1926 # 8000fc38 <wait_lock>
    800024ba:	a869                	j	80002554 <wait+0xd8>
          pid = pp->pid;
    800024bc:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024c0:	000b0c63          	beqz	s6,800024d8 <wait+0x5c>
    800024c4:	4691                	li	a3,4
    800024c6:	02c48613          	addi	a2,s1,44
    800024ca:	85da                	mv	a1,s6
    800024cc:	05093503          	ld	a0,80(s2)
    800024d0:	8b4ff0ef          	jal	80001584 <copyout>
    800024d4:	02054a63          	bltz	a0,80002508 <wait+0x8c>
          freeproc(pp);
    800024d8:	8526                	mv	a0,s1
    800024da:	d74ff0ef          	jal	80001a4e <freeproc>
          release(&pp->lock);
    800024de:	8526                	mv	a0,s1
    800024e0:	fb2fe0ef          	jal	80000c92 <release>
          release(&wait_lock);
    800024e4:	0000d517          	auipc	a0,0xd
    800024e8:	75450513          	addi	a0,a0,1876 # 8000fc38 <wait_lock>
    800024ec:	fa6fe0ef          	jal	80000c92 <release>
}
    800024f0:	854e                	mv	a0,s3
    800024f2:	60a6                	ld	ra,72(sp)
    800024f4:	6406                	ld	s0,64(sp)
    800024f6:	74e2                	ld	s1,56(sp)
    800024f8:	7942                	ld	s2,48(sp)
    800024fa:	79a2                	ld	s3,40(sp)
    800024fc:	7a02                	ld	s4,32(sp)
    800024fe:	6ae2                	ld	s5,24(sp)
    80002500:	6b42                	ld	s6,16(sp)
    80002502:	6ba2                	ld	s7,8(sp)
    80002504:	6161                	addi	sp,sp,80
    80002506:	8082                	ret
            release(&pp->lock);
    80002508:	8526                	mv	a0,s1
    8000250a:	f88fe0ef          	jal	80000c92 <release>
            release(&wait_lock);
    8000250e:	0000d517          	auipc	a0,0xd
    80002512:	72a50513          	addi	a0,a0,1834 # 8000fc38 <wait_lock>
    80002516:	f7cfe0ef          	jal	80000c92 <release>
            return -1;
    8000251a:	59fd                	li	s3,-1
    8000251c:	bfd1                	j	800024f0 <wait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000251e:	3d848493          	addi	s1,s1,984
    80002522:	03348063          	beq	s1,s3,80002542 <wait+0xc6>
      if (pp->parent == p)
    80002526:	7c9c                	ld	a5,56(s1)
    80002528:	ff279be3          	bne	a5,s2,8000251e <wait+0xa2>
        acquire(&pp->lock);
    8000252c:	8526                	mv	a0,s1
    8000252e:	ed0fe0ef          	jal	80000bfe <acquire>
        if (pp->state == ZOMBIE)
    80002532:	4c9c                	lw	a5,24(s1)
    80002534:	f94784e3          	beq	a5,s4,800024bc <wait+0x40>
        release(&pp->lock);
    80002538:	8526                	mv	a0,s1
    8000253a:	f58fe0ef          	jal	80000c92 <release>
        havekids = 1;
    8000253e:	8756                	mv	a4,s5
    80002540:	bff9                	j	8000251e <wait+0xa2>
    if (!havekids || killed(p))
    80002542:	cf19                	beqz	a4,80002560 <wait+0xe4>
    80002544:	854a                	mv	a0,s2
    80002546:	f0dff0ef          	jal	80002452 <killed>
    8000254a:	e919                	bnez	a0,80002560 <wait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000254c:	85de                	mv	a1,s7
    8000254e:	854a                	mv	a0,s2
    80002550:	ccbff0ef          	jal	8000221a <sleep>
    havekids = 0;
    80002554:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002556:	0000e497          	auipc	s1,0xe
    8000255a:	afa48493          	addi	s1,s1,-1286 # 80010050 <proc>
    8000255e:	b7e1                	j	80002526 <wait+0xaa>
      release(&wait_lock);
    80002560:	0000d517          	auipc	a0,0xd
    80002564:	6d850513          	addi	a0,a0,1752 # 8000fc38 <wait_lock>
    80002568:	f2afe0ef          	jal	80000c92 <release>
      return -1;
    8000256c:	59fd                	li	s3,-1
    8000256e:	b749                	j	800024f0 <wait+0x74>

0000000080002570 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002570:	7179                	addi	sp,sp,-48
    80002572:	f406                	sd	ra,40(sp)
    80002574:	f022                	sd	s0,32(sp)
    80002576:	ec26                	sd	s1,24(sp)
    80002578:	e84a                	sd	s2,16(sp)
    8000257a:	e44e                	sd	s3,8(sp)
    8000257c:	e052                	sd	s4,0(sp)
    8000257e:	1800                	addi	s0,sp,48
    80002580:	84aa                	mv	s1,a0
    80002582:	892e                	mv	s2,a1
    80002584:	89b2                	mv	s3,a2
    80002586:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002588:	b54ff0ef          	jal	800018dc <myproc>
  if (user_dst)
    8000258c:	cc99                	beqz	s1,800025aa <either_copyout+0x3a>
  {
    return copyout(p->pagetable, dst, src, len);
    8000258e:	86d2                	mv	a3,s4
    80002590:	864e                	mv	a2,s3
    80002592:	85ca                	mv	a1,s2
    80002594:	6928                	ld	a0,80(a0)
    80002596:	feffe0ef          	jal	80001584 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000259a:	70a2                	ld	ra,40(sp)
    8000259c:	7402                	ld	s0,32(sp)
    8000259e:	64e2                	ld	s1,24(sp)
    800025a0:	6942                	ld	s2,16(sp)
    800025a2:	69a2                	ld	s3,8(sp)
    800025a4:	6a02                	ld	s4,0(sp)
    800025a6:	6145                	addi	sp,sp,48
    800025a8:	8082                	ret
    memmove((char *)dst, src, len);
    800025aa:	000a061b          	sext.w	a2,s4
    800025ae:	85ce                	mv	a1,s3
    800025b0:	854a                	mv	a0,s2
    800025b2:	f80fe0ef          	jal	80000d32 <memmove>
    return 0;
    800025b6:	8526                	mv	a0,s1
    800025b8:	b7cd                	j	8000259a <either_copyout+0x2a>

00000000800025ba <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025ba:	7179                	addi	sp,sp,-48
    800025bc:	f406                	sd	ra,40(sp)
    800025be:	f022                	sd	s0,32(sp)
    800025c0:	ec26                	sd	s1,24(sp)
    800025c2:	e84a                	sd	s2,16(sp)
    800025c4:	e44e                	sd	s3,8(sp)
    800025c6:	e052                	sd	s4,0(sp)
    800025c8:	1800                	addi	s0,sp,48
    800025ca:	892a                	mv	s2,a0
    800025cc:	84ae                	mv	s1,a1
    800025ce:	89b2                	mv	s3,a2
    800025d0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025d2:	b0aff0ef          	jal	800018dc <myproc>
  if (user_src)
    800025d6:	cc99                	beqz	s1,800025f4 <either_copyin+0x3a>
  {
    return copyin(p->pagetable, dst, src, len);
    800025d8:	86d2                	mv	a3,s4
    800025da:	864e                	mv	a2,s3
    800025dc:	85ca                	mv	a1,s2
    800025de:	6928                	ld	a0,80(a0)
    800025e0:	854ff0ef          	jal	80001634 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800025e4:	70a2                	ld	ra,40(sp)
    800025e6:	7402                	ld	s0,32(sp)
    800025e8:	64e2                	ld	s1,24(sp)
    800025ea:	6942                	ld	s2,16(sp)
    800025ec:	69a2                	ld	s3,8(sp)
    800025ee:	6a02                	ld	s4,0(sp)
    800025f0:	6145                	addi	sp,sp,48
    800025f2:	8082                	ret
    memmove(dst, (char *)src, len);
    800025f4:	000a061b          	sext.w	a2,s4
    800025f8:	85ce                	mv	a1,s3
    800025fa:	854a                	mv	a0,s2
    800025fc:	f36fe0ef          	jal	80000d32 <memmove>
    return 0;
    80002600:	8526                	mv	a0,s1
    80002602:	b7cd                	j	800025e4 <either_copyin+0x2a>

0000000080002604 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002604:	715d                	addi	sp,sp,-80
    80002606:	e486                	sd	ra,72(sp)
    80002608:	e0a2                	sd	s0,64(sp)
    8000260a:	fc26                	sd	s1,56(sp)
    8000260c:	f84a                	sd	s2,48(sp)
    8000260e:	f44e                	sd	s3,40(sp)
    80002610:	f052                	sd	s4,32(sp)
    80002612:	ec56                	sd	s5,24(sp)
    80002614:	e85a                	sd	s6,16(sp)
    80002616:	e45e                	sd	s7,8(sp)
    80002618:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000261a:	00005517          	auipc	a0,0x5
    8000261e:	a5e50513          	addi	a0,a0,-1442 # 80007078 <etext+0x78>
    80002622:	eadfd0ef          	jal	800004ce <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002626:	0000e497          	auipc	s1,0xe
    8000262a:	b8248493          	addi	s1,s1,-1150 # 800101a8 <proc+0x158>
    8000262e:	0001d917          	auipc	s2,0x1d
    80002632:	17a90913          	addi	s2,s2,378 # 8001f7a8 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002636:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002638:	00005997          	auipc	s3,0x5
    8000263c:	c6898993          	addi	s3,s3,-920 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002640:	00005a97          	auipc	s5,0x5
    80002644:	c68a8a93          	addi	s5,s5,-920 # 800072a8 <etext+0x2a8>
    printf("\n");
    80002648:	00005a17          	auipc	s4,0x5
    8000264c:	a30a0a13          	addi	s4,s4,-1488 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002650:	00005b97          	auipc	s7,0x5
    80002654:	248b8b93          	addi	s7,s7,584 # 80007898 <syscall_names>
    80002658:	a829                	j	80002672 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000265a:	ed86a583          	lw	a1,-296(a3)
    8000265e:	8556                	mv	a0,s5
    80002660:	e6ffd0ef          	jal	800004ce <printf>
    printf("\n");
    80002664:	8552                	mv	a0,s4
    80002666:	e69fd0ef          	jal	800004ce <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000266a:	3d848493          	addi	s1,s1,984
    8000266e:	03248263          	beq	s1,s2,80002692 <procdump+0x8e>
    if (p->state == UNUSED)
    80002672:	86a6                	mv	a3,s1
    80002674:	ec04a783          	lw	a5,-320(s1)
    80002678:	dbed                	beqz	a5,8000266a <procdump+0x66>
      state = "???";
    8000267a:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000267c:	fcfb6fe3          	bltu	s6,a5,8000265a <procdump+0x56>
    80002680:	02079713          	slli	a4,a5,0x20
    80002684:	01d75793          	srli	a5,a4,0x1d
    80002688:	97de                	add	a5,a5,s7
    8000268a:	67f0                	ld	a2,200(a5)
    8000268c:	f679                	bnez	a2,8000265a <procdump+0x56>
      state = "???";
    8000268e:	864e                	mv	a2,s3
    80002690:	b7e9                	j	8000265a <procdump+0x56>
  }
}
    80002692:	60a6                	ld	ra,72(sp)
    80002694:	6406                	ld	s0,64(sp)
    80002696:	74e2                	ld	s1,56(sp)
    80002698:	7942                	ld	s2,48(sp)
    8000269a:	79a2                	ld	s3,40(sp)
    8000269c:	7a02                	ld	s4,32(sp)
    8000269e:	6ae2                	ld	s5,24(sp)
    800026a0:	6b42                	ld	s6,16(sp)
    800026a2:	6ba2                	ld	s7,8(sp)
    800026a4:	6161                	addi	sp,sp,80
    800026a6:	8082                	ret

00000000800026a8 <swtch>:
    800026a8:	00153023          	sd	ra,0(a0)
    800026ac:	00253423          	sd	sp,8(a0)
    800026b0:	e900                	sd	s0,16(a0)
    800026b2:	ed04                	sd	s1,24(a0)
    800026b4:	03253023          	sd	s2,32(a0)
    800026b8:	03353423          	sd	s3,40(a0)
    800026bc:	03453823          	sd	s4,48(a0)
    800026c0:	03553c23          	sd	s5,56(a0)
    800026c4:	05653023          	sd	s6,64(a0)
    800026c8:	05753423          	sd	s7,72(a0)
    800026cc:	05853823          	sd	s8,80(a0)
    800026d0:	05953c23          	sd	s9,88(a0)
    800026d4:	07a53023          	sd	s10,96(a0)
    800026d8:	07b53423          	sd	s11,104(a0)
    800026dc:	0005b083          	ld	ra,0(a1)
    800026e0:	0085b103          	ld	sp,8(a1)
    800026e4:	6980                	ld	s0,16(a1)
    800026e6:	6d84                	ld	s1,24(a1)
    800026e8:	0205b903          	ld	s2,32(a1)
    800026ec:	0285b983          	ld	s3,40(a1)
    800026f0:	0305ba03          	ld	s4,48(a1)
    800026f4:	0385ba83          	ld	s5,56(a1)
    800026f8:	0405bb03          	ld	s6,64(a1)
    800026fc:	0485bb83          	ld	s7,72(a1)
    80002700:	0505bc03          	ld	s8,80(a1)
    80002704:	0585bc83          	ld	s9,88(a1)
    80002708:	0605bd03          	ld	s10,96(a1)
    8000270c:	0685bd83          	ld	s11,104(a1)
    80002710:	8082                	ret

0000000080002712 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002712:	1141                	addi	sp,sp,-16
    80002714:	e406                	sd	ra,8(sp)
    80002716:	e022                	sd	s0,0(sp)
    80002718:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000271a:	00005597          	auipc	a1,0x5
    8000271e:	c9658593          	addi	a1,a1,-874 # 800073b0 <etext+0x3b0>
    80002722:	0001d517          	auipc	a0,0x1d
    80002726:	f2e50513          	addi	a0,a0,-210 # 8001f650 <tickslock>
    8000272a:	c50fe0ef          	jal	80000b7a <initlock>
}
    8000272e:	60a2                	ld	ra,8(sp)
    80002730:	6402                	ld	s0,0(sp)
    80002732:	0141                	addi	sp,sp,16
    80002734:	8082                	ret

0000000080002736 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002736:	1141                	addi	sp,sp,-16
    80002738:	e406                	sd	ra,8(sp)
    8000273a:	e022                	sd	s0,0(sp)
    8000273c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000273e:	00003797          	auipc	a5,0x3
    80002742:	07278793          	addi	a5,a5,114 # 800057b0 <kernelvec>
    80002746:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000274a:	60a2                	ld	ra,8(sp)
    8000274c:	6402                	ld	s0,0(sp)
    8000274e:	0141                	addi	sp,sp,16
    80002750:	8082                	ret

0000000080002752 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002752:	1141                	addi	sp,sp,-16
    80002754:	e406                	sd	ra,8(sp)
    80002756:	e022                	sd	s0,0(sp)
    80002758:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000275a:	982ff0ef          	jal	800018dc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000275e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002762:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002764:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002768:	00004697          	auipc	a3,0x4
    8000276c:	89868693          	addi	a3,a3,-1896 # 80006000 <_trampoline>
    80002770:	00004717          	auipc	a4,0x4
    80002774:	89070713          	addi	a4,a4,-1904 # 80006000 <_trampoline>
    80002778:	8f15                	sub	a4,a4,a3
    8000277a:	040007b7          	lui	a5,0x4000
    8000277e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002780:	07b2                	slli	a5,a5,0xc
    80002782:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002784:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002788:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000278a:	18002673          	csrr	a2,satp
    8000278e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002790:	6d30                	ld	a2,88(a0)
    80002792:	6138                	ld	a4,64(a0)
    80002794:	6585                	lui	a1,0x1
    80002796:	972e                	add	a4,a4,a1
    80002798:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000279a:	6d38                	ld	a4,88(a0)
    8000279c:	00000617          	auipc	a2,0x0
    800027a0:	11060613          	addi	a2,a2,272 # 800028ac <usertrap>
    800027a4:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027a6:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027a8:	8612                	mv	a2,tp
    800027aa:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ac:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027b0:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027b4:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027b8:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027bc:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027be:	6f18                	ld	a4,24(a4)
    800027c0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027c4:	6928                	ld	a0,80(a0)
    800027c6:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800027c8:	00004717          	auipc	a4,0x4
    800027cc:	8d470713          	addi	a4,a4,-1836 # 8000609c <userret>
    800027d0:	8f15                	sub	a4,a4,a3
    800027d2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800027d4:	577d                	li	a4,-1
    800027d6:	177e                	slli	a4,a4,0x3f
    800027d8:	8d59                	or	a0,a0,a4
    800027da:	9782                	jalr	a5
}
    800027dc:	60a2                	ld	ra,8(sp)
    800027de:	6402                	ld	s0,0(sp)
    800027e0:	0141                	addi	sp,sp,16
    800027e2:	8082                	ret

00000000800027e4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027e4:	1101                	addi	sp,sp,-32
    800027e6:	ec06                	sd	ra,24(sp)
    800027e8:	e822                	sd	s0,16(sp)
    800027ea:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800027ec:	8bcff0ef          	jal	800018a8 <cpuid>
    800027f0:	cd11                	beqz	a0,8000280c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800027f2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800027f6:	000f4737          	lui	a4,0xf4
    800027fa:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800027fe:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002800:	14d79073          	csrw	stimecmp,a5
}
    80002804:	60e2                	ld	ra,24(sp)
    80002806:	6442                	ld	s0,16(sp)
    80002808:	6105                	addi	sp,sp,32
    8000280a:	8082                	ret
    8000280c:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000280e:	0001d497          	auipc	s1,0x1d
    80002812:	e4248493          	addi	s1,s1,-446 # 8001f650 <tickslock>
    80002816:	8526                	mv	a0,s1
    80002818:	be6fe0ef          	jal	80000bfe <acquire>
    ticks++;
    8000281c:	00005517          	auipc	a0,0x5
    80002820:	2dc50513          	addi	a0,a0,732 # 80007af8 <ticks>
    80002824:	411c                	lw	a5,0(a0)
    80002826:	2785                	addiw	a5,a5,1
    80002828:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000282a:	a3dff0ef          	jal	80002266 <wakeup>
    release(&tickslock);
    8000282e:	8526                	mv	a0,s1
    80002830:	c62fe0ef          	jal	80000c92 <release>
    80002834:	64a2                	ld	s1,8(sp)
    80002836:	bf75                	j	800027f2 <clockintr+0xe>

0000000080002838 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002838:	1101                	addi	sp,sp,-32
    8000283a:	ec06                	sd	ra,24(sp)
    8000283c:	e822                	sd	s0,16(sp)
    8000283e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002840:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002844:	57fd                	li	a5,-1
    80002846:	17fe                	slli	a5,a5,0x3f
    80002848:	07a5                	addi	a5,a5,9
    8000284a:	00f70c63          	beq	a4,a5,80002862 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000284e:	57fd                	li	a5,-1
    80002850:	17fe                	slli	a5,a5,0x3f
    80002852:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002854:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002856:	04f70763          	beq	a4,a5,800028a4 <devintr+0x6c>
  }
}
    8000285a:	60e2                	ld	ra,24(sp)
    8000285c:	6442                	ld	s0,16(sp)
    8000285e:	6105                	addi	sp,sp,32
    80002860:	8082                	ret
    80002862:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002864:	7f9020ef          	jal	8000585c <plic_claim>
    80002868:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000286a:	47a9                	li	a5,10
    8000286c:	00f50963          	beq	a0,a5,8000287e <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002870:	4785                	li	a5,1
    80002872:	00f50963          	beq	a0,a5,80002884 <devintr+0x4c>
    return 1;
    80002876:	4505                	li	a0,1
    } else if(irq){
    80002878:	e889                	bnez	s1,8000288a <devintr+0x52>
    8000287a:	64a2                	ld	s1,8(sp)
    8000287c:	bff9                	j	8000285a <devintr+0x22>
      uartintr();
    8000287e:	98efe0ef          	jal	80000a0c <uartintr>
    if(irq)
    80002882:	a819                	j	80002898 <devintr+0x60>
      virtio_disk_intr();
    80002884:	468030ef          	jal	80005cec <virtio_disk_intr>
    if(irq)
    80002888:	a801                	j	80002898 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000288a:	85a6                	mv	a1,s1
    8000288c:	00005517          	auipc	a0,0x5
    80002890:	b2c50513          	addi	a0,a0,-1236 # 800073b8 <etext+0x3b8>
    80002894:	c3bfd0ef          	jal	800004ce <printf>
      plic_complete(irq);
    80002898:	8526                	mv	a0,s1
    8000289a:	7e3020ef          	jal	8000587c <plic_complete>
    return 1;
    8000289e:	4505                	li	a0,1
    800028a0:	64a2                	ld	s1,8(sp)
    800028a2:	bf65                	j	8000285a <devintr+0x22>
    clockintr();
    800028a4:	f41ff0ef          	jal	800027e4 <clockintr>
    return 2;
    800028a8:	4509                	li	a0,2
    800028aa:	bf45                	j	8000285a <devintr+0x22>

00000000800028ac <usertrap>:
{
    800028ac:	1101                	addi	sp,sp,-32
    800028ae:	ec06                	sd	ra,24(sp)
    800028b0:	e822                	sd	s0,16(sp)
    800028b2:	e426                	sd	s1,8(sp)
    800028b4:	e04a                	sd	s2,0(sp)
    800028b6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028bc:	1007f793          	andi	a5,a5,256
    800028c0:	ef85                	bnez	a5,800028f8 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028c2:	00003797          	auipc	a5,0x3
    800028c6:	eee78793          	addi	a5,a5,-274 # 800057b0 <kernelvec>
    800028ca:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028ce:	80eff0ef          	jal	800018dc <myproc>
    800028d2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028d4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028d6:	14102773          	csrr	a4,sepc
    800028da:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028dc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028e0:	47a1                	li	a5,8
    800028e2:	02f70163          	beq	a4,a5,80002904 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800028e6:	f53ff0ef          	jal	80002838 <devintr>
    800028ea:	892a                	mv	s2,a0
    800028ec:	c135                	beqz	a0,80002950 <usertrap+0xa4>
  if(killed(p))
    800028ee:	8526                	mv	a0,s1
    800028f0:	b63ff0ef          	jal	80002452 <killed>
    800028f4:	cd1d                	beqz	a0,80002932 <usertrap+0x86>
    800028f6:	a81d                	j	8000292c <usertrap+0x80>
    panic("usertrap: not from user mode");
    800028f8:	00005517          	auipc	a0,0x5
    800028fc:	ae050513          	addi	a0,a0,-1312 # 800073d8 <etext+0x3d8>
    80002900:	e9ffd0ef          	jal	8000079e <panic>
    if(killed(p))
    80002904:	b4fff0ef          	jal	80002452 <killed>
    80002908:	e121                	bnez	a0,80002948 <usertrap+0x9c>
    p->trapframe->epc += 4;
    8000290a:	6cb8                	ld	a4,88(s1)
    8000290c:	6f1c                	ld	a5,24(a4)
    8000290e:	0791                	addi	a5,a5,4
    80002910:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002912:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002916:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000291a:	10079073          	csrw	sstatus,a5
    syscall();
    8000291e:	240000ef          	jal	80002b5e <syscall>
  if(killed(p))
    80002922:	8526                	mv	a0,s1
    80002924:	b2fff0ef          	jal	80002452 <killed>
    80002928:	c901                	beqz	a0,80002938 <usertrap+0x8c>
    8000292a:	4901                	li	s2,0
    exit(-1);
    8000292c:	557d                	li	a0,-1
    8000292e:	9f9ff0ef          	jal	80002326 <exit>
  if(which_dev == 2)
    80002932:	4789                	li	a5,2
    80002934:	04f90563          	beq	s2,a5,8000297e <usertrap+0xd2>
  usertrapret();
    80002938:	e1bff0ef          	jal	80002752 <usertrapret>
}
    8000293c:	60e2                	ld	ra,24(sp)
    8000293e:	6442                	ld	s0,16(sp)
    80002940:	64a2                	ld	s1,8(sp)
    80002942:	6902                	ld	s2,0(sp)
    80002944:	6105                	addi	sp,sp,32
    80002946:	8082                	ret
      exit(-1);
    80002948:	557d                	li	a0,-1
    8000294a:	9ddff0ef          	jal	80002326 <exit>
    8000294e:	bf75                	j	8000290a <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002950:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002954:	5890                	lw	a2,48(s1)
    80002956:	00005517          	auipc	a0,0x5
    8000295a:	aa250513          	addi	a0,a0,-1374 # 800073f8 <etext+0x3f8>
    8000295e:	b71fd0ef          	jal	800004ce <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002962:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002966:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000296a:	00005517          	auipc	a0,0x5
    8000296e:	abe50513          	addi	a0,a0,-1346 # 80007428 <etext+0x428>
    80002972:	b5dfd0ef          	jal	800004ce <printf>
    setkilled(p);
    80002976:	8526                	mv	a0,s1
    80002978:	ab7ff0ef          	jal	8000242e <setkilled>
    8000297c:	b75d                	j	80002922 <usertrap+0x76>
    yield();
    8000297e:	871ff0ef          	jal	800021ee <yield>
    80002982:	bf5d                	j	80002938 <usertrap+0x8c>

0000000080002984 <kerneltrap>:
{
    80002984:	7179                	addi	sp,sp,-48
    80002986:	f406                	sd	ra,40(sp)
    80002988:	f022                	sd	s0,32(sp)
    8000298a:	ec26                	sd	s1,24(sp)
    8000298c:	e84a                	sd	s2,16(sp)
    8000298e:	e44e                	sd	s3,8(sp)
    80002990:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002992:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002996:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000299a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000299e:	1004f793          	andi	a5,s1,256
    800029a2:	c795                	beqz	a5,800029ce <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029a8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029aa:	eb85                	bnez	a5,800029da <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800029ac:	e8dff0ef          	jal	80002838 <devintr>
    800029b0:	c91d                	beqz	a0,800029e6 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800029b2:	4789                	li	a5,2
    800029b4:	04f50a63          	beq	a0,a5,80002a08 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029b8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029bc:	10049073          	csrw	sstatus,s1
}
    800029c0:	70a2                	ld	ra,40(sp)
    800029c2:	7402                	ld	s0,32(sp)
    800029c4:	64e2                	ld	s1,24(sp)
    800029c6:	6942                	ld	s2,16(sp)
    800029c8:	69a2                	ld	s3,8(sp)
    800029ca:	6145                	addi	sp,sp,48
    800029cc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029ce:	00005517          	auipc	a0,0x5
    800029d2:	a8250513          	addi	a0,a0,-1406 # 80007450 <etext+0x450>
    800029d6:	dc9fd0ef          	jal	8000079e <panic>
    panic("kerneltrap: interrupts enabled");
    800029da:	00005517          	auipc	a0,0x5
    800029de:	a9e50513          	addi	a0,a0,-1378 # 80007478 <etext+0x478>
    800029e2:	dbdfd0ef          	jal	8000079e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029e6:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029ea:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800029ee:	85ce                	mv	a1,s3
    800029f0:	00005517          	auipc	a0,0x5
    800029f4:	aa850513          	addi	a0,a0,-1368 # 80007498 <etext+0x498>
    800029f8:	ad7fd0ef          	jal	800004ce <printf>
    panic("kerneltrap");
    800029fc:	00005517          	auipc	a0,0x5
    80002a00:	ac450513          	addi	a0,a0,-1340 # 800074c0 <etext+0x4c0>
    80002a04:	d9bfd0ef          	jal	8000079e <panic>
  if(which_dev == 2 && myproc() != 0)
    80002a08:	ed5fe0ef          	jal	800018dc <myproc>
    80002a0c:	d555                	beqz	a0,800029b8 <kerneltrap+0x34>
    yield();
    80002a0e:	fe0ff0ef          	jal	800021ee <yield>
    80002a12:	b75d                	j	800029b8 <kerneltrap+0x34>

0000000080002a14 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a14:	1101                	addi	sp,sp,-32
    80002a16:	ec06                	sd	ra,24(sp)
    80002a18:	e822                	sd	s0,16(sp)
    80002a1a:	e426                	sd	s1,8(sp)
    80002a1c:	1000                	addi	s0,sp,32
    80002a1e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a20:	ebdfe0ef          	jal	800018dc <myproc>
  switch (n) {
    80002a24:	4795                	li	a5,5
    80002a26:	0497e163          	bltu	a5,s1,80002a68 <argraw+0x54>
    80002a2a:	048a                	slli	s1,s1,0x2
    80002a2c:	00005717          	auipc	a4,0x5
    80002a30:	f6470713          	addi	a4,a4,-156 # 80007990 <states.0+0x30>
    80002a34:	94ba                	add	s1,s1,a4
    80002a36:	409c                	lw	a5,0(s1)
    80002a38:	97ba                	add	a5,a5,a4
    80002a3a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a3c:	6d3c                	ld	a5,88(a0)
    80002a3e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a40:	60e2                	ld	ra,24(sp)
    80002a42:	6442                	ld	s0,16(sp)
    80002a44:	64a2                	ld	s1,8(sp)
    80002a46:	6105                	addi	sp,sp,32
    80002a48:	8082                	ret
    return p->trapframe->a1;
    80002a4a:	6d3c                	ld	a5,88(a0)
    80002a4c:	7fa8                	ld	a0,120(a5)
    80002a4e:	bfcd                	j	80002a40 <argraw+0x2c>
    return p->trapframe->a2;
    80002a50:	6d3c                	ld	a5,88(a0)
    80002a52:	63c8                	ld	a0,128(a5)
    80002a54:	b7f5                	j	80002a40 <argraw+0x2c>
    return p->trapframe->a3;
    80002a56:	6d3c                	ld	a5,88(a0)
    80002a58:	67c8                	ld	a0,136(a5)
    80002a5a:	b7dd                	j	80002a40 <argraw+0x2c>
    return p->trapframe->a4;
    80002a5c:	6d3c                	ld	a5,88(a0)
    80002a5e:	6bc8                	ld	a0,144(a5)
    80002a60:	b7c5                	j	80002a40 <argraw+0x2c>
    return p->trapframe->a5;
    80002a62:	6d3c                	ld	a5,88(a0)
    80002a64:	6fc8                	ld	a0,152(a5)
    80002a66:	bfe9                	j	80002a40 <argraw+0x2c>
  panic("argraw");
    80002a68:	00005517          	auipc	a0,0x5
    80002a6c:	a6850513          	addi	a0,a0,-1432 # 800074d0 <etext+0x4d0>
    80002a70:	d2ffd0ef          	jal	8000079e <panic>

0000000080002a74 <fetchaddr>:
{
    80002a74:	1101                	addi	sp,sp,-32
    80002a76:	ec06                	sd	ra,24(sp)
    80002a78:	e822                	sd	s0,16(sp)
    80002a7a:	e426                	sd	s1,8(sp)
    80002a7c:	e04a                	sd	s2,0(sp)
    80002a7e:	1000                	addi	s0,sp,32
    80002a80:	84aa                	mv	s1,a0
    80002a82:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a84:	e59fe0ef          	jal	800018dc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a88:	653c                	ld	a5,72(a0)
    80002a8a:	02f4f663          	bgeu	s1,a5,80002ab6 <fetchaddr+0x42>
    80002a8e:	00848713          	addi	a4,s1,8
    80002a92:	02e7e463          	bltu	a5,a4,80002aba <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a96:	46a1                	li	a3,8
    80002a98:	8626                	mv	a2,s1
    80002a9a:	85ca                	mv	a1,s2
    80002a9c:	6928                	ld	a0,80(a0)
    80002a9e:	b97fe0ef          	jal	80001634 <copyin>
    80002aa2:	00a03533          	snez	a0,a0
    80002aa6:	40a0053b          	negw	a0,a0
}
    80002aaa:	60e2                	ld	ra,24(sp)
    80002aac:	6442                	ld	s0,16(sp)
    80002aae:	64a2                	ld	s1,8(sp)
    80002ab0:	6902                	ld	s2,0(sp)
    80002ab2:	6105                	addi	sp,sp,32
    80002ab4:	8082                	ret
    return -1;
    80002ab6:	557d                	li	a0,-1
    80002ab8:	bfcd                	j	80002aaa <fetchaddr+0x36>
    80002aba:	557d                	li	a0,-1
    80002abc:	b7fd                	j	80002aaa <fetchaddr+0x36>

0000000080002abe <fetchstr>:
{
    80002abe:	7179                	addi	sp,sp,-48
    80002ac0:	f406                	sd	ra,40(sp)
    80002ac2:	f022                	sd	s0,32(sp)
    80002ac4:	ec26                	sd	s1,24(sp)
    80002ac6:	e84a                	sd	s2,16(sp)
    80002ac8:	e44e                	sd	s3,8(sp)
    80002aca:	1800                	addi	s0,sp,48
    80002acc:	892a                	mv	s2,a0
    80002ace:	84ae                	mv	s1,a1
    80002ad0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ad2:	e0bfe0ef          	jal	800018dc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ad6:	86ce                	mv	a3,s3
    80002ad8:	864a                	mv	a2,s2
    80002ada:	85a6                	mv	a1,s1
    80002adc:	6928                	ld	a0,80(a0)
    80002ade:	bddfe0ef          	jal	800016ba <copyinstr>
    80002ae2:	00054c63          	bltz	a0,80002afa <fetchstr+0x3c>
  return strlen(buf);
    80002ae6:	8526                	mv	a0,s1
    80002ae8:	b6efe0ef          	jal	80000e56 <strlen>
}
    80002aec:	70a2                	ld	ra,40(sp)
    80002aee:	7402                	ld	s0,32(sp)
    80002af0:	64e2                	ld	s1,24(sp)
    80002af2:	6942                	ld	s2,16(sp)
    80002af4:	69a2                	ld	s3,8(sp)
    80002af6:	6145                	addi	sp,sp,48
    80002af8:	8082                	ret
    return -1;
    80002afa:	557d                	li	a0,-1
    80002afc:	bfc5                	j	80002aec <fetchstr+0x2e>

0000000080002afe <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002afe:	1101                	addi	sp,sp,-32
    80002b00:	ec06                	sd	ra,24(sp)
    80002b02:	e822                	sd	s0,16(sp)
    80002b04:	e426                	sd	s1,8(sp)
    80002b06:	1000                	addi	s0,sp,32
    80002b08:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b0a:	f0bff0ef          	jal	80002a14 <argraw>
    80002b0e:	c088                	sw	a0,0(s1)
}
    80002b10:	60e2                	ld	ra,24(sp)
    80002b12:	6442                	ld	s0,16(sp)
    80002b14:	64a2                	ld	s1,8(sp)
    80002b16:	6105                	addi	sp,sp,32
    80002b18:	8082                	ret

0000000080002b1a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b1a:	1101                	addi	sp,sp,-32
    80002b1c:	ec06                	sd	ra,24(sp)
    80002b1e:	e822                	sd	s0,16(sp)
    80002b20:	e426                	sd	s1,8(sp)
    80002b22:	1000                	addi	s0,sp,32
    80002b24:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b26:	eefff0ef          	jal	80002a14 <argraw>
    80002b2a:	e088                	sd	a0,0(s1)
}
    80002b2c:	60e2                	ld	ra,24(sp)
    80002b2e:	6442                	ld	s0,16(sp)
    80002b30:	64a2                	ld	s1,8(sp)
    80002b32:	6105                	addi	sp,sp,32
    80002b34:	8082                	ret

0000000080002b36 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b36:	1101                	addi	sp,sp,-32
    80002b38:	ec06                	sd	ra,24(sp)
    80002b3a:	e822                	sd	s0,16(sp)
    80002b3c:	e426                	sd	s1,8(sp)
    80002b3e:	e04a                	sd	s2,0(sp)
    80002b40:	1000                	addi	s0,sp,32
    80002b42:	84ae                	mv	s1,a1
    80002b44:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b46:	ecfff0ef          	jal	80002a14 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002b4a:	864a                	mv	a2,s2
    80002b4c:	85a6                	mv	a1,s1
    80002b4e:	f71ff0ef          	jal	80002abe <fetchstr>
}
    80002b52:	60e2                	ld	ra,24(sp)
    80002b54:	6442                	ld	s0,16(sp)
    80002b56:	64a2                	ld	s1,8(sp)
    80002b58:	6902                	ld	s2,0(sp)
    80002b5a:	6105                	addi	sp,sp,32
    80002b5c:	8082                	ret

0000000080002b5e <syscall>:
};


void
syscall(void)
{
    80002b5e:	7139                	addi	sp,sp,-64
    80002b60:	fc06                	sd	ra,56(sp)
    80002b62:	f822                	sd	s0,48(sp)
    80002b64:	f426                	sd	s1,40(sp)
    80002b66:	f04a                	sd	s2,32(sp)
    80002b68:	0080                	addi	s0,sp,64
  int num;
  struct proc *p = myproc();
    80002b6a:	d73fe0ef          	jal	800018dc <myproc>
    80002b6e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b70:	6d3c                	ld	a5,88(a0)
    80002b72:	77dc                	ld	a5,168(a5)
    80002b74:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b78:	37fd                	addiw	a5,a5,-1
    80002b7a:	4759                	li	a4,22
    80002b7c:	08f76f63          	bltu	a4,a5,80002c1a <syscall+0xbc>
    80002b80:	ec4e                	sd	s3,24(sp)
    80002b82:	00391713          	slli	a4,s2,0x3
    80002b86:	00005797          	auipc	a5,0x5
    80002b8a:	e2278793          	addi	a5,a5,-478 # 800079a8 <syscalls>
    80002b8e:	97ba                	add	a5,a5,a4
    80002b90:	0007b983          	ld	s3,0(a5)
    80002b94:	08098263          	beqz	s3,80002c18 <syscall+0xba>
    80002b98:	e852                	sd	s4,16(sp)
    80002b9a:	e456                	sd	s5,8(sp)
    80002b9c:	e05a                	sd	s6,0(sp)
    acquire(&tickslock);
    80002b9e:	0001d517          	auipc	a0,0x1d
    80002ba2:	ab250513          	addi	a0,a0,-1358 # 8001f650 <tickslock>
    80002ba6:	858fe0ef          	jal	80000bfe <acquire>
    int start_ticks = ticks;
    80002baa:	00005a97          	auipc	s5,0x5
    80002bae:	f4ea8a93          	addi	s5,s5,-178 # 80007af8 <ticks>
    80002bb2:	000aaa03          	lw	s4,0(s5)
    release(&tickslock);
    80002bb6:	0001d517          	auipc	a0,0x1d
    80002bba:	a9a50513          	addi	a0,a0,-1382 # 8001f650 <tickslock>
    80002bbe:	8d4fe0ef          	jal	80000c92 <release>
    p->trapframe->a0 = syscalls[num]();
    80002bc2:	0584bb03          	ld	s6,88(s1)
    80002bc6:	9982                	jalr	s3
    80002bc8:	06ab3823          	sd	a0,112(s6)
    acquire(&tickslock);
    80002bcc:	0001d517          	auipc	a0,0x1d
    80002bd0:	a8450513          	addi	a0,a0,-1404 # 8001f650 <tickslock>
    80002bd4:	82afe0ef          	jal	80000bfe <acquire>
    int end_ticks = ticks;
    80002bd8:	000aa983          	lw	s3,0(s5)
    release(&tickslock);
    80002bdc:	0001d517          	auipc	a0,0x1d
    80002be0:	a7450513          	addi	a0,a0,-1420 # 8001f650 <tickslock>
    80002be4:	8aefe0ef          	jal	80000c92 <release>

    struct syscall_stat *stat = &p->syscall_stats[num];
    stat->count++;
    80002be8:	00191793          	slli	a5,s2,0x1
    80002bec:	01278733          	add	a4,a5,s2
    80002bf0:	070e                	slli	a4,a4,0x3
    80002bf2:	9726                	add	a4,a4,s1
    80002bf4:	17872683          	lw	a3,376(a4)
    80002bf8:	2685                	addiw	a3,a3,1
    80002bfa:	16d72c23          	sw	a3,376(a4)
    stat->accum_time += (end_ticks - start_ticks);
    80002bfe:	414989bb          	subw	s3,s3,s4
    80002c02:	17c72783          	lw	a5,380(a4)
    80002c06:	013787bb          	addw	a5,a5,s3
    80002c0a:	16f72e23          	sw	a5,380(a4)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c0e:	69e2                	ld	s3,24(sp)
    80002c10:	6a42                	ld	s4,16(sp)
    80002c12:	6aa2                	ld	s5,8(sp)
    80002c14:	6b02                	ld	s6,0(sp)
    80002c16:	a839                	j	80002c34 <syscall+0xd6>
    80002c18:	69e2                	ld	s3,24(sp)
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c1a:	86ca                	mv	a3,s2
    80002c1c:	15848613          	addi	a2,s1,344
    80002c20:	588c                	lw	a1,48(s1)
    80002c22:	00005517          	auipc	a0,0x5
    80002c26:	8b650513          	addi	a0,a0,-1866 # 800074d8 <etext+0x4d8>
    80002c2a:	8a5fd0ef          	jal	800004ce <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c2e:	6cbc                	ld	a5,88(s1)
    80002c30:	577d                	li	a4,-1
    80002c32:	fbb8                	sd	a4,112(a5)
  }
}
    80002c34:	70e2                	ld	ra,56(sp)
    80002c36:	7442                	ld	s0,48(sp)
    80002c38:	74a2                	ld	s1,40(sp)
    80002c3a:	7902                	ld	s2,32(sp)
    80002c3c:	6121                	addi	sp,sp,64
    80002c3e:	8082                	ret

0000000080002c40 <sys_exit>:
#include "pstat.h"
extern struct proc proc[];

uint64
sys_exit(void)
{
    80002c40:	1101                	addi	sp,sp,-32
    80002c42:	ec06                	sd	ra,24(sp)
    80002c44:	e822                	sd	s0,16(sp)
    80002c46:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c48:	fec40593          	addi	a1,s0,-20
    80002c4c:	4501                	li	a0,0
    80002c4e:	eb1ff0ef          	jal	80002afe <argint>
  exit(n);
    80002c52:	fec42503          	lw	a0,-20(s0)
    80002c56:	ed0ff0ef          	jal	80002326 <exit>
  return 0; // not reached
}
    80002c5a:	4501                	li	a0,0
    80002c5c:	60e2                	ld	ra,24(sp)
    80002c5e:	6442                	ld	s0,16(sp)
    80002c60:	6105                	addi	sp,sp,32
    80002c62:	8082                	ret

0000000080002c64 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c64:	1141                	addi	sp,sp,-16
    80002c66:	e406                	sd	ra,8(sp)
    80002c68:	e022                	sd	s0,0(sp)
    80002c6a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c6c:	c71fe0ef          	jal	800018dc <myproc>
}
    80002c70:	5908                	lw	a0,48(a0)
    80002c72:	60a2                	ld	ra,8(sp)
    80002c74:	6402                	ld	s0,0(sp)
    80002c76:	0141                	addi	sp,sp,16
    80002c78:	8082                	ret

0000000080002c7a <sys_fork>:

uint64
sys_fork(void)
{
    80002c7a:	1141                	addi	sp,sp,-16
    80002c7c:	e406                	sd	ra,8(sp)
    80002c7e:	e022                	sd	s0,0(sp)
    80002c80:	0800                	addi	s0,sp,16
  return fork();
    80002c82:	febfe0ef          	jal	80001c6c <fork>
}
    80002c86:	60a2                	ld	ra,8(sp)
    80002c88:	6402                	ld	s0,0(sp)
    80002c8a:	0141                	addi	sp,sp,16
    80002c8c:	8082                	ret

0000000080002c8e <sys_wait>:

uint64
sys_wait(void)
{
    80002c8e:	1101                	addi	sp,sp,-32
    80002c90:	ec06                	sd	ra,24(sp)
    80002c92:	e822                	sd	s0,16(sp)
    80002c94:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c96:	fe840593          	addi	a1,s0,-24
    80002c9a:	4501                	li	a0,0
    80002c9c:	e7fff0ef          	jal	80002b1a <argaddr>
  return wait(p);
    80002ca0:	fe843503          	ld	a0,-24(s0)
    80002ca4:	fd8ff0ef          	jal	8000247c <wait>
}
    80002ca8:	60e2                	ld	ra,24(sp)
    80002caa:	6442                	ld	s0,16(sp)
    80002cac:	6105                	addi	sp,sp,32
    80002cae:	8082                	ret

0000000080002cb0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cb0:	7179                	addi	sp,sp,-48
    80002cb2:	f406                	sd	ra,40(sp)
    80002cb4:	f022                	sd	s0,32(sp)
    80002cb6:	ec26                	sd	s1,24(sp)
    80002cb8:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002cba:	fdc40593          	addi	a1,s0,-36
    80002cbe:	4501                	li	a0,0
    80002cc0:	e3fff0ef          	jal	80002afe <argint>
  addr = myproc()->sz;
    80002cc4:	c19fe0ef          	jal	800018dc <myproc>
    80002cc8:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002cca:	fdc42503          	lw	a0,-36(s0)
    80002cce:	f4ffe0ef          	jal	80001c1c <growproc>
    80002cd2:	00054863          	bltz	a0,80002ce2 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002cd6:	8526                	mv	a0,s1
    80002cd8:	70a2                	ld	ra,40(sp)
    80002cda:	7402                	ld	s0,32(sp)
    80002cdc:	64e2                	ld	s1,24(sp)
    80002cde:	6145                	addi	sp,sp,48
    80002ce0:	8082                	ret
    return -1;
    80002ce2:	54fd                	li	s1,-1
    80002ce4:	bfcd                	j	80002cd6 <sys_sbrk+0x26>

0000000080002ce6 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ce6:	7139                	addi	sp,sp,-64
    80002ce8:	fc06                	sd	ra,56(sp)
    80002cea:	f822                	sd	s0,48(sp)
    80002cec:	f04a                	sd	s2,32(sp)
    80002cee:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cf0:	fcc40593          	addi	a1,s0,-52
    80002cf4:	4501                	li	a0,0
    80002cf6:	e09ff0ef          	jal	80002afe <argint>
  if (n < 0)
    80002cfa:	fcc42783          	lw	a5,-52(s0)
    80002cfe:	0607c763          	bltz	a5,80002d6c <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002d02:	0001d517          	auipc	a0,0x1d
    80002d06:	94e50513          	addi	a0,a0,-1714 # 8001f650 <tickslock>
    80002d0a:	ef5fd0ef          	jal	80000bfe <acquire>
  ticks0 = ticks;
    80002d0e:	00005917          	auipc	s2,0x5
    80002d12:	dea92903          	lw	s2,-534(s2) # 80007af8 <ticks>
  while (ticks - ticks0 < n)
    80002d16:	fcc42783          	lw	a5,-52(s0)
    80002d1a:	cf8d                	beqz	a5,80002d54 <sys_sleep+0x6e>
    80002d1c:	f426                	sd	s1,40(sp)
    80002d1e:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d20:	0001d997          	auipc	s3,0x1d
    80002d24:	93098993          	addi	s3,s3,-1744 # 8001f650 <tickslock>
    80002d28:	00005497          	auipc	s1,0x5
    80002d2c:	dd048493          	addi	s1,s1,-560 # 80007af8 <ticks>
    if (killed(myproc()))
    80002d30:	badfe0ef          	jal	800018dc <myproc>
    80002d34:	f1eff0ef          	jal	80002452 <killed>
    80002d38:	ed0d                	bnez	a0,80002d72 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002d3a:	85ce                	mv	a1,s3
    80002d3c:	8526                	mv	a0,s1
    80002d3e:	cdcff0ef          	jal	8000221a <sleep>
  while (ticks - ticks0 < n)
    80002d42:	409c                	lw	a5,0(s1)
    80002d44:	412787bb          	subw	a5,a5,s2
    80002d48:	fcc42703          	lw	a4,-52(s0)
    80002d4c:	fee7e2e3          	bltu	a5,a4,80002d30 <sys_sleep+0x4a>
    80002d50:	74a2                	ld	s1,40(sp)
    80002d52:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d54:	0001d517          	auipc	a0,0x1d
    80002d58:	8fc50513          	addi	a0,a0,-1796 # 8001f650 <tickslock>
    80002d5c:	f37fd0ef          	jal	80000c92 <release>
  return 0;
    80002d60:	4501                	li	a0,0
}
    80002d62:	70e2                	ld	ra,56(sp)
    80002d64:	7442                	ld	s0,48(sp)
    80002d66:	7902                	ld	s2,32(sp)
    80002d68:	6121                	addi	sp,sp,64
    80002d6a:	8082                	ret
    n = 0;
    80002d6c:	fc042623          	sw	zero,-52(s0)
    80002d70:	bf49                	j	80002d02 <sys_sleep+0x1c>
      release(&tickslock);
    80002d72:	0001d517          	auipc	a0,0x1d
    80002d76:	8de50513          	addi	a0,a0,-1826 # 8001f650 <tickslock>
    80002d7a:	f19fd0ef          	jal	80000c92 <release>
      return -1;
    80002d7e:	557d                	li	a0,-1
    80002d80:	74a2                	ld	s1,40(sp)
    80002d82:	69e2                	ld	s3,24(sp)
    80002d84:	bff9                	j	80002d62 <sys_sleep+0x7c>

0000000080002d86 <sys_kill>:

uint64
sys_kill(void)
{
    80002d86:	1101                	addi	sp,sp,-32
    80002d88:	ec06                	sd	ra,24(sp)
    80002d8a:	e822                	sd	s0,16(sp)
    80002d8c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d8e:	fec40593          	addi	a1,s0,-20
    80002d92:	4501                	li	a0,0
    80002d94:	d6bff0ef          	jal	80002afe <argint>
  return kill(pid);
    80002d98:	fec42503          	lw	a0,-20(s0)
    80002d9c:	e2cff0ef          	jal	800023c8 <kill>
}
    80002da0:	60e2                	ld	ra,24(sp)
    80002da2:	6442                	ld	s0,16(sp)
    80002da4:	6105                	addi	sp,sp,32
    80002da6:	8082                	ret

0000000080002da8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002da8:	1101                	addi	sp,sp,-32
    80002daa:	ec06                	sd	ra,24(sp)
    80002dac:	e822                	sd	s0,16(sp)
    80002dae:	e426                	sd	s1,8(sp)
    80002db0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002db2:	0001d517          	auipc	a0,0x1d
    80002db6:	89e50513          	addi	a0,a0,-1890 # 8001f650 <tickslock>
    80002dba:	e45fd0ef          	jal	80000bfe <acquire>
  xticks = ticks;
    80002dbe:	00005497          	auipc	s1,0x5
    80002dc2:	d3a4a483          	lw	s1,-710(s1) # 80007af8 <ticks>
  release(&tickslock);
    80002dc6:	0001d517          	auipc	a0,0x1d
    80002dca:	88a50513          	addi	a0,a0,-1910 # 8001f650 <tickslock>
    80002dce:	ec5fd0ef          	jal	80000c92 <release>
  return xticks;
}
    80002dd2:	02049513          	slli	a0,s1,0x20
    80002dd6:	9101                	srli	a0,a0,0x20
    80002dd8:	60e2                	ld	ra,24(sp)
    80002dda:	6442                	ld	s0,16(sp)
    80002ddc:	64a2                	ld	s1,8(sp)
    80002dde:	6105                	addi	sp,sp,32
    80002de0:	8082                	ret

0000000080002de2 <sys_history>:

uint64 sys_history()
{
    80002de2:	7139                	addi	sp,sp,-64
    80002de4:	fc06                	sd	ra,56(sp)
    80002de6:	f822                	sd	s0,48(sp)
    80002de8:	0080                	addi	s0,sp,64
  int syscall_num;
  uint64 stat_addr;
  argint(0, &syscall_num);
    80002dea:	fec40593          	addi	a1,s0,-20
    80002dee:	4501                	li	a0,0
    80002df0:	d0fff0ef          	jal	80002afe <argint>
  argaddr(1, &stat_addr);
    80002df4:	fe040593          	addi	a1,s0,-32
    80002df8:	4505                	li	a0,1
    80002dfa:	d21ff0ef          	jal	80002b1a <argaddr>
  struct proc *p = myproc();
    80002dfe:	adffe0ef          	jal	800018dc <myproc>
    80002e02:	872a                	mv	a4,a0
  if (syscall_num < 1 || syscall_num > NSYSCALL)
    80002e04:	fec42683          	lw	a3,-20(s0)
    80002e08:	fff6861b          	addiw	a2,a3,-1
    80002e0c:	47dd                	li	a5,23
    return -1;
    80002e0e:	557d                	li	a0,-1
  if (syscall_num < 1 || syscall_num > NSYSCALL)
    80002e10:	02c7ec63          	bltu	a5,a2,80002e48 <sys_history+0x66>
  struct syscall_stat stat = p->syscall_stats[syscall_num];
    80002e14:	00169793          	slli	a5,a3,0x1
    80002e18:	97b6                	add	a5,a5,a3
    80002e1a:	078e                	slli	a5,a5,0x3
    80002e1c:	97ba                	add	a5,a5,a4
    80002e1e:	1687b683          	ld	a3,360(a5)
    80002e22:	fcd43423          	sd	a3,-56(s0)
    80002e26:	1707b683          	ld	a3,368(a5)
    80002e2a:	fcd43823          	sd	a3,-48(s0)
    80002e2e:	1787b783          	ld	a5,376(a5)
    80002e32:	fcf43c23          	sd	a5,-40(s0)
  if (copyout(p->pagetable, stat_addr, (char *)&stat, sizeof(struct syscall_stat)) < 0)
    80002e36:	46e1                	li	a3,24
    80002e38:	fc840613          	addi	a2,s0,-56
    80002e3c:	fe043583          	ld	a1,-32(s0)
    80002e40:	6b28                	ld	a0,80(a4)
    80002e42:	f42fe0ef          	jal	80001584 <copyout>
    80002e46:	957d                	srai	a0,a0,0x3f
    return -1;
  return 0;
}
    80002e48:	70e2                	ld	ra,56(sp)
    80002e4a:	7442                	ld	s0,48(sp)
    80002e4c:	6121                	addi	sp,sp,64
    80002e4e:	8082                	ret

0000000080002e50 <sys_settickets>:

uint64 sys_settickets()
{
    80002e50:	7179                	addi	sp,sp,-48
    80002e52:	f406                	sd	ra,40(sp)
    80002e54:	f022                	sd	s0,32(sp)
    80002e56:	ec26                	sd	s1,24(sp)
    80002e58:	1800                	addi	s0,sp,48
  int n;
  argint(0, &n);
    80002e5a:	fdc40593          	addi	a1,s0,-36
    80002e5e:	4501                	li	a0,0
    80002e60:	c9fff0ef          	jal	80002afe <argint>
  struct proc *p = myproc();
    80002e64:	a79fe0ef          	jal	800018dc <myproc>
    80002e68:	84aa                	mv	s1,a0

  if (n < 1)
    80002e6a:	fdc42783          	lw	a5,-36(s0)
    80002e6e:	02f05363          	blez	a5,80002e94 <sys_settickets+0x44>
    p->Current_tickets = DEFAULT_TICKET_COUNT;
    release(&p->lock);
    return -1;
  }

  acquire(&p->lock);
    80002e72:	d8dfd0ef          	jal	80000bfe <acquire>
  p->Original_tickets = n;
    80002e76:	fdc42783          	lw	a5,-36(s0)
    80002e7a:	3cf4a023          	sw	a5,960(s1)
  p->Current_tickets = n;
    80002e7e:	3cf4a223          	sw	a5,964(s1)
  release(&p->lock);
    80002e82:	8526                	mv	a0,s1
    80002e84:	e0ffd0ef          	jal	80000c92 <release>
  return 0;
    80002e88:	4501                	li	a0,0
}
    80002e8a:	70a2                	ld	ra,40(sp)
    80002e8c:	7402                	ld	s0,32(sp)
    80002e8e:	64e2                	ld	s1,24(sp)
    80002e90:	6145                	addi	sp,sp,48
    80002e92:	8082                	ret
    acquire(&p->lock);
    80002e94:	d6bfd0ef          	jal	80000bfe <acquire>
    p->Original_tickets = DEFAULT_TICKET_COUNT;
    80002e98:	47a9                	li	a5,10
    80002e9a:	3cf4a023          	sw	a5,960(s1)
    p->Current_tickets = DEFAULT_TICKET_COUNT;
    80002e9e:	3cf4a223          	sw	a5,964(s1)
    release(&p->lock);
    80002ea2:	8526                	mv	a0,s1
    80002ea4:	deffd0ef          	jal	80000c92 <release>
    return -1;
    80002ea8:	557d                	li	a0,-1
    80002eaa:	b7c5                	j	80002e8a <sys_settickets+0x3a>

0000000080002eac <sys_getpinfo>:
uint64 sys_getpinfo()
{
    80002eac:	9b010113          	addi	sp,sp,-1616
    80002eb0:	64113423          	sd	ra,1608(sp)
    80002eb4:	64813023          	sd	s0,1600(sp)
    80002eb8:	62913c23          	sd	s1,1592(sp)
    80002ebc:	63213823          	sd	s2,1584(sp)
    80002ec0:	63313423          	sd	s3,1576(sp)
    80002ec4:	63413023          	sd	s4,1568(sp)
    80002ec8:	61513c23          	sd	s5,1560(sp)
    80002ecc:	61613823          	sd	s6,1552(sp)
    80002ed0:	65010413          	addi	s0,sp,1616
  uint64 addr;
  argaddr(0, &addr);
    80002ed4:	fb840593          	addi	a1,s0,-72
    80002ed8:	4501                	li	a0,0
    80002eda:	c41ff0ef          	jal	80002b1a <argaddr>
  struct proc *p;
  struct pstat st;

  for (int i = 0; i < NPROC; i++)
    80002ede:	0000d497          	auipc	s1,0xd
    80002ee2:	17248493          	addi	s1,s1,370 # 80010050 <proc>
    80002ee6:	9b840913          	addi	s2,s0,-1608
    80002eea:	0001ca17          	auipc	s4,0x1c
    80002eee:	766a0a13          	addi	s4,s4,1894 # 8001f650 <tickslock>
    st.tickets_current[i] = p->Current_tickets;
    st.time_slices[i] = p->time_slices;
    // Debug print for each process
    if (st.inuse[i])
    {
      printf("[sys_getpinfo] pid=%d inuse=%d tickets_o=%d tickets_c=%d slices=%d queue=%d\n",
    80002ef2:	4b05                	li	s6,1
    80002ef4:	00004a97          	auipc	s5,0x4
    80002ef8:	604a8a93          	addi	s5,s5,1540 # 800074f8 <etext+0x4f8>
    80002efc:	a809                	j	80002f0e <sys_getpinfo+0x62>
             st.tickets_original[i],
             st.tickets_current[i],
             st.time_slices[i],
             st.inQ[i]);
    }
    release(&p->lock);
    80002efe:	854e                	mv	a0,s3
    80002f00:	d93fd0ef          	jal	80000c92 <release>
  for (int i = 0; i < NPROC; i++)
    80002f04:	3d848493          	addi	s1,s1,984
    80002f08:	0911                	addi	s2,s2,4
    80002f0a:	05448463          	beq	s1,s4,80002f52 <sys_getpinfo+0xa6>
    acquire(&p->lock);
    80002f0e:	89a6                	mv	s3,s1
    80002f10:	8526                	mv	a0,s1
    80002f12:	cedfd0ef          	jal	80000bfe <acquire>
    st.pid[i] = p->pid;
    80002f16:	588c                	lw	a1,48(s1)
    80002f18:	00b92023          	sw	a1,0(s2)
    st.inuse[i] = (p->state != UNUSED);
    80002f1c:	4c90                	lw	a2,24(s1)
    80002f1e:	00c037b3          	snez	a5,a2
    80002f22:	10f92023          	sw	a5,256(s2)
    st.inQ[i] = p->inq;
    80002f26:	3c84a803          	lw	a6,968(s1)
    80002f2a:	21092023          	sw	a6,512(s2)
    st.tickets_original[i] = p->Original_tickets;
    80002f2e:	3c04a683          	lw	a3,960(s1)
    80002f32:	30d92023          	sw	a3,768(s2)
    st.tickets_current[i] = p->Current_tickets;
    80002f36:	3c44a703          	lw	a4,964(s1)
    80002f3a:	40e92023          	sw	a4,1024(s2)
    st.time_slices[i] = p->time_slices;
    80002f3e:	3cc4a783          	lw	a5,972(s1)
    80002f42:	50f92023          	sw	a5,1280(s2)
    if (st.inuse[i])
    80002f46:	de45                	beqz	a2,80002efe <sys_getpinfo+0x52>
      printf("[sys_getpinfo] pid=%d inuse=%d tickets_o=%d tickets_c=%d slices=%d queue=%d\n",
    80002f48:	865a                	mv	a2,s6
    80002f4a:	8556                	mv	a0,s5
    80002f4c:	d82fd0ef          	jal	800004ce <printf>
    80002f50:	b77d                	j	80002efe <sys_getpinfo+0x52>
  }

  if (copyout(myproc()->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80002f52:	98bfe0ef          	jal	800018dc <myproc>
    80002f56:	60000693          	li	a3,1536
    80002f5a:	9b840613          	addi	a2,s0,-1608
    80002f5e:	fb843583          	ld	a1,-72(s0)
    80002f62:	6928                	ld	a0,80(a0)
    80002f64:	e20fe0ef          	jal	80001584 <copyout>
    return -1;
  return 0;
}
    80002f68:	957d                	srai	a0,a0,0x3f
    80002f6a:	64813083          	ld	ra,1608(sp)
    80002f6e:	64013403          	ld	s0,1600(sp)
    80002f72:	63813483          	ld	s1,1592(sp)
    80002f76:	63013903          	ld	s2,1584(sp)
    80002f7a:	62813983          	ld	s3,1576(sp)
    80002f7e:	62013a03          	ld	s4,1568(sp)
    80002f82:	61813a83          	ld	s5,1560(sp)
    80002f86:	61013b03          	ld	s6,1552(sp)
    80002f8a:	65010113          	addi	sp,sp,1616
    80002f8e:	8082                	ret

0000000080002f90 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f90:	7179                	addi	sp,sp,-48
    80002f92:	f406                	sd	ra,40(sp)
    80002f94:	f022                	sd	s0,32(sp)
    80002f96:	ec26                	sd	s1,24(sp)
    80002f98:	e84a                	sd	s2,16(sp)
    80002f9a:	e44e                	sd	s3,8(sp)
    80002f9c:	e052                	sd	s4,0(sp)
    80002f9e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fa0:	00004597          	auipc	a1,0x4
    80002fa4:	5a858593          	addi	a1,a1,1448 # 80007548 <etext+0x548>
    80002fa8:	0001c517          	auipc	a0,0x1c
    80002fac:	6c050513          	addi	a0,a0,1728 # 8001f668 <bcache>
    80002fb0:	bcbfd0ef          	jal	80000b7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fb4:	00024797          	auipc	a5,0x24
    80002fb8:	6b478793          	addi	a5,a5,1716 # 80027668 <bcache+0x8000>
    80002fbc:	00025717          	auipc	a4,0x25
    80002fc0:	91470713          	addi	a4,a4,-1772 # 800278d0 <bcache+0x8268>
    80002fc4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002fc8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fcc:	0001c497          	auipc	s1,0x1c
    80002fd0:	6b448493          	addi	s1,s1,1716 # 8001f680 <bcache+0x18>
    b->next = bcache.head.next;
    80002fd4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002fd6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fd8:	00004a17          	auipc	s4,0x4
    80002fdc:	578a0a13          	addi	s4,s4,1400 # 80007550 <etext+0x550>
    b->next = bcache.head.next;
    80002fe0:	2b893783          	ld	a5,696(s2)
    80002fe4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002fe6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002fea:	85d2                	mv	a1,s4
    80002fec:	01048513          	addi	a0,s1,16
    80002ff0:	244010ef          	jal	80004234 <initsleeplock>
    bcache.head.next->prev = b;
    80002ff4:	2b893783          	ld	a5,696(s2)
    80002ff8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002ffa:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ffe:	45848493          	addi	s1,s1,1112
    80003002:	fd349fe3          	bne	s1,s3,80002fe0 <binit+0x50>
  }
}
    80003006:	70a2                	ld	ra,40(sp)
    80003008:	7402                	ld	s0,32(sp)
    8000300a:	64e2                	ld	s1,24(sp)
    8000300c:	6942                	ld	s2,16(sp)
    8000300e:	69a2                	ld	s3,8(sp)
    80003010:	6a02                	ld	s4,0(sp)
    80003012:	6145                	addi	sp,sp,48
    80003014:	8082                	ret

0000000080003016 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003016:	7179                	addi	sp,sp,-48
    80003018:	f406                	sd	ra,40(sp)
    8000301a:	f022                	sd	s0,32(sp)
    8000301c:	ec26                	sd	s1,24(sp)
    8000301e:	e84a                	sd	s2,16(sp)
    80003020:	e44e                	sd	s3,8(sp)
    80003022:	1800                	addi	s0,sp,48
    80003024:	892a                	mv	s2,a0
    80003026:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003028:	0001c517          	auipc	a0,0x1c
    8000302c:	64050513          	addi	a0,a0,1600 # 8001f668 <bcache>
    80003030:	bcffd0ef          	jal	80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003034:	00025497          	auipc	s1,0x25
    80003038:	8ec4b483          	ld	s1,-1812(s1) # 80027920 <bcache+0x82b8>
    8000303c:	00025797          	auipc	a5,0x25
    80003040:	89478793          	addi	a5,a5,-1900 # 800278d0 <bcache+0x8268>
    80003044:	02f48b63          	beq	s1,a5,8000307a <bread+0x64>
    80003048:	873e                	mv	a4,a5
    8000304a:	a021                	j	80003052 <bread+0x3c>
    8000304c:	68a4                	ld	s1,80(s1)
    8000304e:	02e48663          	beq	s1,a4,8000307a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003052:	449c                	lw	a5,8(s1)
    80003054:	ff279ce3          	bne	a5,s2,8000304c <bread+0x36>
    80003058:	44dc                	lw	a5,12(s1)
    8000305a:	ff3799e3          	bne	a5,s3,8000304c <bread+0x36>
      b->refcnt++;
    8000305e:	40bc                	lw	a5,64(s1)
    80003060:	2785                	addiw	a5,a5,1
    80003062:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003064:	0001c517          	auipc	a0,0x1c
    80003068:	60450513          	addi	a0,a0,1540 # 8001f668 <bcache>
    8000306c:	c27fd0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80003070:	01048513          	addi	a0,s1,16
    80003074:	1f6010ef          	jal	8000426a <acquiresleep>
      return b;
    80003078:	a889                	j	800030ca <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000307a:	00025497          	auipc	s1,0x25
    8000307e:	89e4b483          	ld	s1,-1890(s1) # 80027918 <bcache+0x82b0>
    80003082:	00025797          	auipc	a5,0x25
    80003086:	84e78793          	addi	a5,a5,-1970 # 800278d0 <bcache+0x8268>
    8000308a:	00f48863          	beq	s1,a5,8000309a <bread+0x84>
    8000308e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003090:	40bc                	lw	a5,64(s1)
    80003092:	cb91                	beqz	a5,800030a6 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003094:	64a4                	ld	s1,72(s1)
    80003096:	fee49de3          	bne	s1,a4,80003090 <bread+0x7a>
  panic("bget: no buffers");
    8000309a:	00004517          	auipc	a0,0x4
    8000309e:	4be50513          	addi	a0,a0,1214 # 80007558 <etext+0x558>
    800030a2:	efcfd0ef          	jal	8000079e <panic>
      b->dev = dev;
    800030a6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800030aa:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800030ae:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030b2:	4785                	li	a5,1
    800030b4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030b6:	0001c517          	auipc	a0,0x1c
    800030ba:	5b250513          	addi	a0,a0,1458 # 8001f668 <bcache>
    800030be:	bd5fd0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    800030c2:	01048513          	addi	a0,s1,16
    800030c6:	1a4010ef          	jal	8000426a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030ca:	409c                	lw	a5,0(s1)
    800030cc:	cb89                	beqz	a5,800030de <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030ce:	8526                	mv	a0,s1
    800030d0:	70a2                	ld	ra,40(sp)
    800030d2:	7402                	ld	s0,32(sp)
    800030d4:	64e2                	ld	s1,24(sp)
    800030d6:	6942                	ld	s2,16(sp)
    800030d8:	69a2                	ld	s3,8(sp)
    800030da:	6145                	addi	sp,sp,48
    800030dc:	8082                	ret
    virtio_disk_rw(b, 0);
    800030de:	4581                	li	a1,0
    800030e0:	8526                	mv	a0,s1
    800030e2:	1ff020ef          	jal	80005ae0 <virtio_disk_rw>
    b->valid = 1;
    800030e6:	4785                	li	a5,1
    800030e8:	c09c                	sw	a5,0(s1)
  return b;
    800030ea:	b7d5                	j	800030ce <bread+0xb8>

00000000800030ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800030ec:	1101                	addi	sp,sp,-32
    800030ee:	ec06                	sd	ra,24(sp)
    800030f0:	e822                	sd	s0,16(sp)
    800030f2:	e426                	sd	s1,8(sp)
    800030f4:	1000                	addi	s0,sp,32
    800030f6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030f8:	0541                	addi	a0,a0,16
    800030fa:	1ee010ef          	jal	800042e8 <holdingsleep>
    800030fe:	c911                	beqz	a0,80003112 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003100:	4585                	li	a1,1
    80003102:	8526                	mv	a0,s1
    80003104:	1dd020ef          	jal	80005ae0 <virtio_disk_rw>
}
    80003108:	60e2                	ld	ra,24(sp)
    8000310a:	6442                	ld	s0,16(sp)
    8000310c:	64a2                	ld	s1,8(sp)
    8000310e:	6105                	addi	sp,sp,32
    80003110:	8082                	ret
    panic("bwrite");
    80003112:	00004517          	auipc	a0,0x4
    80003116:	45e50513          	addi	a0,a0,1118 # 80007570 <etext+0x570>
    8000311a:	e84fd0ef          	jal	8000079e <panic>

000000008000311e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000311e:	1101                	addi	sp,sp,-32
    80003120:	ec06                	sd	ra,24(sp)
    80003122:	e822                	sd	s0,16(sp)
    80003124:	e426                	sd	s1,8(sp)
    80003126:	e04a                	sd	s2,0(sp)
    80003128:	1000                	addi	s0,sp,32
    8000312a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000312c:	01050913          	addi	s2,a0,16
    80003130:	854a                	mv	a0,s2
    80003132:	1b6010ef          	jal	800042e8 <holdingsleep>
    80003136:	c125                	beqz	a0,80003196 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80003138:	854a                	mv	a0,s2
    8000313a:	176010ef          	jal	800042b0 <releasesleep>

  acquire(&bcache.lock);
    8000313e:	0001c517          	auipc	a0,0x1c
    80003142:	52a50513          	addi	a0,a0,1322 # 8001f668 <bcache>
    80003146:	ab9fd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    8000314a:	40bc                	lw	a5,64(s1)
    8000314c:	37fd                	addiw	a5,a5,-1
    8000314e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003150:	e79d                	bnez	a5,8000317e <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003152:	68b8                	ld	a4,80(s1)
    80003154:	64bc                	ld	a5,72(s1)
    80003156:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003158:	68b8                	ld	a4,80(s1)
    8000315a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000315c:	00024797          	auipc	a5,0x24
    80003160:	50c78793          	addi	a5,a5,1292 # 80027668 <bcache+0x8000>
    80003164:	2b87b703          	ld	a4,696(a5)
    80003168:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000316a:	00024717          	auipc	a4,0x24
    8000316e:	76670713          	addi	a4,a4,1894 # 800278d0 <bcache+0x8268>
    80003172:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003174:	2b87b703          	ld	a4,696(a5)
    80003178:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000317a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000317e:	0001c517          	auipc	a0,0x1c
    80003182:	4ea50513          	addi	a0,a0,1258 # 8001f668 <bcache>
    80003186:	b0dfd0ef          	jal	80000c92 <release>
}
    8000318a:	60e2                	ld	ra,24(sp)
    8000318c:	6442                	ld	s0,16(sp)
    8000318e:	64a2                	ld	s1,8(sp)
    80003190:	6902                	ld	s2,0(sp)
    80003192:	6105                	addi	sp,sp,32
    80003194:	8082                	ret
    panic("brelse");
    80003196:	00004517          	auipc	a0,0x4
    8000319a:	3e250513          	addi	a0,a0,994 # 80007578 <etext+0x578>
    8000319e:	e00fd0ef          	jal	8000079e <panic>

00000000800031a2 <bpin>:

void
bpin(struct buf *b) {
    800031a2:	1101                	addi	sp,sp,-32
    800031a4:	ec06                	sd	ra,24(sp)
    800031a6:	e822                	sd	s0,16(sp)
    800031a8:	e426                	sd	s1,8(sp)
    800031aa:	1000                	addi	s0,sp,32
    800031ac:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031ae:	0001c517          	auipc	a0,0x1c
    800031b2:	4ba50513          	addi	a0,a0,1210 # 8001f668 <bcache>
    800031b6:	a49fd0ef          	jal	80000bfe <acquire>
  b->refcnt++;
    800031ba:	40bc                	lw	a5,64(s1)
    800031bc:	2785                	addiw	a5,a5,1
    800031be:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031c0:	0001c517          	auipc	a0,0x1c
    800031c4:	4a850513          	addi	a0,a0,1192 # 8001f668 <bcache>
    800031c8:	acbfd0ef          	jal	80000c92 <release>
}
    800031cc:	60e2                	ld	ra,24(sp)
    800031ce:	6442                	ld	s0,16(sp)
    800031d0:	64a2                	ld	s1,8(sp)
    800031d2:	6105                	addi	sp,sp,32
    800031d4:	8082                	ret

00000000800031d6 <bunpin>:

void
bunpin(struct buf *b) {
    800031d6:	1101                	addi	sp,sp,-32
    800031d8:	ec06                	sd	ra,24(sp)
    800031da:	e822                	sd	s0,16(sp)
    800031dc:	e426                	sd	s1,8(sp)
    800031de:	1000                	addi	s0,sp,32
    800031e0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031e2:	0001c517          	auipc	a0,0x1c
    800031e6:	48650513          	addi	a0,a0,1158 # 8001f668 <bcache>
    800031ea:	a15fd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    800031ee:	40bc                	lw	a5,64(s1)
    800031f0:	37fd                	addiw	a5,a5,-1
    800031f2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031f4:	0001c517          	auipc	a0,0x1c
    800031f8:	47450513          	addi	a0,a0,1140 # 8001f668 <bcache>
    800031fc:	a97fd0ef          	jal	80000c92 <release>
}
    80003200:	60e2                	ld	ra,24(sp)
    80003202:	6442                	ld	s0,16(sp)
    80003204:	64a2                	ld	s1,8(sp)
    80003206:	6105                	addi	sp,sp,32
    80003208:	8082                	ret

000000008000320a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000320a:	1101                	addi	sp,sp,-32
    8000320c:	ec06                	sd	ra,24(sp)
    8000320e:	e822                	sd	s0,16(sp)
    80003210:	e426                	sd	s1,8(sp)
    80003212:	e04a                	sd	s2,0(sp)
    80003214:	1000                	addi	s0,sp,32
    80003216:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003218:	00d5d79b          	srliw	a5,a1,0xd
    8000321c:	00025597          	auipc	a1,0x25
    80003220:	b285a583          	lw	a1,-1240(a1) # 80027d44 <sb+0x1c>
    80003224:	9dbd                	addw	a1,a1,a5
    80003226:	df1ff0ef          	jal	80003016 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000322a:	0074f713          	andi	a4,s1,7
    8000322e:	4785                	li	a5,1
    80003230:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003234:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003236:	90d9                	srli	s1,s1,0x36
    80003238:	00950733          	add	a4,a0,s1
    8000323c:	05874703          	lbu	a4,88(a4)
    80003240:	00e7f6b3          	and	a3,a5,a4
    80003244:	c29d                	beqz	a3,8000326a <bfree+0x60>
    80003246:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003248:	94aa                	add	s1,s1,a0
    8000324a:	fff7c793          	not	a5,a5
    8000324e:	8f7d                	and	a4,a4,a5
    80003250:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003254:	711000ef          	jal	80004164 <log_write>
  brelse(bp);
    80003258:	854a                	mv	a0,s2
    8000325a:	ec5ff0ef          	jal	8000311e <brelse>
}
    8000325e:	60e2                	ld	ra,24(sp)
    80003260:	6442                	ld	s0,16(sp)
    80003262:	64a2                	ld	s1,8(sp)
    80003264:	6902                	ld	s2,0(sp)
    80003266:	6105                	addi	sp,sp,32
    80003268:	8082                	ret
    panic("freeing free block");
    8000326a:	00004517          	auipc	a0,0x4
    8000326e:	31650513          	addi	a0,a0,790 # 80007580 <etext+0x580>
    80003272:	d2cfd0ef          	jal	8000079e <panic>

0000000080003276 <balloc>:
{
    80003276:	715d                	addi	sp,sp,-80
    80003278:	e486                	sd	ra,72(sp)
    8000327a:	e0a2                	sd	s0,64(sp)
    8000327c:	fc26                	sd	s1,56(sp)
    8000327e:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003280:	00025797          	auipc	a5,0x25
    80003284:	aac7a783          	lw	a5,-1364(a5) # 80027d2c <sb+0x4>
    80003288:	0e078863          	beqz	a5,80003378 <balloc+0x102>
    8000328c:	f84a                	sd	s2,48(sp)
    8000328e:	f44e                	sd	s3,40(sp)
    80003290:	f052                	sd	s4,32(sp)
    80003292:	ec56                	sd	s5,24(sp)
    80003294:	e85a                	sd	s6,16(sp)
    80003296:	e45e                	sd	s7,8(sp)
    80003298:	e062                	sd	s8,0(sp)
    8000329a:	8baa                	mv	s7,a0
    8000329c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000329e:	00025b17          	auipc	s6,0x25
    800032a2:	a8ab0b13          	addi	s6,s6,-1398 # 80027d28 <sb>
      m = 1 << (bi % 8);
    800032a6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032a8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032aa:	6c09                	lui	s8,0x2
    800032ac:	a09d                	j	80003312 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032ae:	97ca                	add	a5,a5,s2
    800032b0:	8e55                	or	a2,a2,a3
    800032b2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800032b6:	854a                	mv	a0,s2
    800032b8:	6ad000ef          	jal	80004164 <log_write>
        brelse(bp);
    800032bc:	854a                	mv	a0,s2
    800032be:	e61ff0ef          	jal	8000311e <brelse>
  bp = bread(dev, bno);
    800032c2:	85a6                	mv	a1,s1
    800032c4:	855e                	mv	a0,s7
    800032c6:	d51ff0ef          	jal	80003016 <bread>
    800032ca:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032cc:	40000613          	li	a2,1024
    800032d0:	4581                	li	a1,0
    800032d2:	05850513          	addi	a0,a0,88
    800032d6:	9f9fd0ef          	jal	80000cce <memset>
  log_write(bp);
    800032da:	854a                	mv	a0,s2
    800032dc:	689000ef          	jal	80004164 <log_write>
  brelse(bp);
    800032e0:	854a                	mv	a0,s2
    800032e2:	e3dff0ef          	jal	8000311e <brelse>
}
    800032e6:	7942                	ld	s2,48(sp)
    800032e8:	79a2                	ld	s3,40(sp)
    800032ea:	7a02                	ld	s4,32(sp)
    800032ec:	6ae2                	ld	s5,24(sp)
    800032ee:	6b42                	ld	s6,16(sp)
    800032f0:	6ba2                	ld	s7,8(sp)
    800032f2:	6c02                	ld	s8,0(sp)
}
    800032f4:	8526                	mv	a0,s1
    800032f6:	60a6                	ld	ra,72(sp)
    800032f8:	6406                	ld	s0,64(sp)
    800032fa:	74e2                	ld	s1,56(sp)
    800032fc:	6161                	addi	sp,sp,80
    800032fe:	8082                	ret
    brelse(bp);
    80003300:	854a                	mv	a0,s2
    80003302:	e1dff0ef          	jal	8000311e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003306:	015c0abb          	addw	s5,s8,s5
    8000330a:	004b2783          	lw	a5,4(s6)
    8000330e:	04fafe63          	bgeu	s5,a5,8000336a <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    80003312:	41fad79b          	sraiw	a5,s5,0x1f
    80003316:	0137d79b          	srliw	a5,a5,0x13
    8000331a:	015787bb          	addw	a5,a5,s5
    8000331e:	40d7d79b          	sraiw	a5,a5,0xd
    80003322:	01cb2583          	lw	a1,28(s6)
    80003326:	9dbd                	addw	a1,a1,a5
    80003328:	855e                	mv	a0,s7
    8000332a:	cedff0ef          	jal	80003016 <bread>
    8000332e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003330:	004b2503          	lw	a0,4(s6)
    80003334:	84d6                	mv	s1,s5
    80003336:	4701                	li	a4,0
    80003338:	fca4f4e3          	bgeu	s1,a0,80003300 <balloc+0x8a>
      m = 1 << (bi % 8);
    8000333c:	00777693          	andi	a3,a4,7
    80003340:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003344:	41f7579b          	sraiw	a5,a4,0x1f
    80003348:	01d7d79b          	srliw	a5,a5,0x1d
    8000334c:	9fb9                	addw	a5,a5,a4
    8000334e:	4037d79b          	sraiw	a5,a5,0x3
    80003352:	00f90633          	add	a2,s2,a5
    80003356:	05864603          	lbu	a2,88(a2)
    8000335a:	00c6f5b3          	and	a1,a3,a2
    8000335e:	d9a1                	beqz	a1,800032ae <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003360:	2705                	addiw	a4,a4,1
    80003362:	2485                	addiw	s1,s1,1
    80003364:	fd471ae3          	bne	a4,s4,80003338 <balloc+0xc2>
    80003368:	bf61                	j	80003300 <balloc+0x8a>
    8000336a:	7942                	ld	s2,48(sp)
    8000336c:	79a2                	ld	s3,40(sp)
    8000336e:	7a02                	ld	s4,32(sp)
    80003370:	6ae2                	ld	s5,24(sp)
    80003372:	6b42                	ld	s6,16(sp)
    80003374:	6ba2                	ld	s7,8(sp)
    80003376:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003378:	00004517          	auipc	a0,0x4
    8000337c:	22050513          	addi	a0,a0,544 # 80007598 <etext+0x598>
    80003380:	94efd0ef          	jal	800004ce <printf>
  return 0;
    80003384:	4481                	li	s1,0
    80003386:	b7bd                	j	800032f4 <balloc+0x7e>

0000000080003388 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003388:	7179                	addi	sp,sp,-48
    8000338a:	f406                	sd	ra,40(sp)
    8000338c:	f022                	sd	s0,32(sp)
    8000338e:	ec26                	sd	s1,24(sp)
    80003390:	e84a                	sd	s2,16(sp)
    80003392:	e44e                	sd	s3,8(sp)
    80003394:	1800                	addi	s0,sp,48
    80003396:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003398:	47ad                	li	a5,11
    8000339a:	02b7e363          	bltu	a5,a1,800033c0 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    8000339e:	02059793          	slli	a5,a1,0x20
    800033a2:	01e7d593          	srli	a1,a5,0x1e
    800033a6:	00b504b3          	add	s1,a0,a1
    800033aa:	0504a903          	lw	s2,80(s1)
    800033ae:	06091363          	bnez	s2,80003414 <bmap+0x8c>
      addr = balloc(ip->dev);
    800033b2:	4108                	lw	a0,0(a0)
    800033b4:	ec3ff0ef          	jal	80003276 <balloc>
    800033b8:	892a                	mv	s2,a0
      if(addr == 0)
    800033ba:	cd29                	beqz	a0,80003414 <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    800033bc:	c8a8                	sw	a0,80(s1)
    800033be:	a899                	j	80003414 <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033c0:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    800033c4:	0ff00793          	li	a5,255
    800033c8:	0697e963          	bltu	a5,s1,8000343a <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033cc:	08052903          	lw	s2,128(a0)
    800033d0:	00091b63          	bnez	s2,800033e6 <bmap+0x5e>
      addr = balloc(ip->dev);
    800033d4:	4108                	lw	a0,0(a0)
    800033d6:	ea1ff0ef          	jal	80003276 <balloc>
    800033da:	892a                	mv	s2,a0
      if(addr == 0)
    800033dc:	cd05                	beqz	a0,80003414 <bmap+0x8c>
    800033de:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800033e0:	08a9a023          	sw	a0,128(s3)
    800033e4:	a011                	j	800033e8 <bmap+0x60>
    800033e6:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800033e8:	85ca                	mv	a1,s2
    800033ea:	0009a503          	lw	a0,0(s3)
    800033ee:	c29ff0ef          	jal	80003016 <bread>
    800033f2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033f4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033f8:	02049713          	slli	a4,s1,0x20
    800033fc:	01e75593          	srli	a1,a4,0x1e
    80003400:	00b784b3          	add	s1,a5,a1
    80003404:	0004a903          	lw	s2,0(s1)
    80003408:	00090e63          	beqz	s2,80003424 <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000340c:	8552                	mv	a0,s4
    8000340e:	d11ff0ef          	jal	8000311e <brelse>
    return addr;
    80003412:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003414:	854a                	mv	a0,s2
    80003416:	70a2                	ld	ra,40(sp)
    80003418:	7402                	ld	s0,32(sp)
    8000341a:	64e2                	ld	s1,24(sp)
    8000341c:	6942                	ld	s2,16(sp)
    8000341e:	69a2                	ld	s3,8(sp)
    80003420:	6145                	addi	sp,sp,48
    80003422:	8082                	ret
      addr = balloc(ip->dev);
    80003424:	0009a503          	lw	a0,0(s3)
    80003428:	e4fff0ef          	jal	80003276 <balloc>
    8000342c:	892a                	mv	s2,a0
      if(addr){
    8000342e:	dd79                	beqz	a0,8000340c <bmap+0x84>
        a[bn] = addr;
    80003430:	c088                	sw	a0,0(s1)
        log_write(bp);
    80003432:	8552                	mv	a0,s4
    80003434:	531000ef          	jal	80004164 <log_write>
    80003438:	bfd1                	j	8000340c <bmap+0x84>
    8000343a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000343c:	00004517          	auipc	a0,0x4
    80003440:	17450513          	addi	a0,a0,372 # 800075b0 <etext+0x5b0>
    80003444:	b5afd0ef          	jal	8000079e <panic>

0000000080003448 <iget>:
{
    80003448:	7179                	addi	sp,sp,-48
    8000344a:	f406                	sd	ra,40(sp)
    8000344c:	f022                	sd	s0,32(sp)
    8000344e:	ec26                	sd	s1,24(sp)
    80003450:	e84a                	sd	s2,16(sp)
    80003452:	e44e                	sd	s3,8(sp)
    80003454:	e052                	sd	s4,0(sp)
    80003456:	1800                	addi	s0,sp,48
    80003458:	89aa                	mv	s3,a0
    8000345a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000345c:	00025517          	auipc	a0,0x25
    80003460:	8ec50513          	addi	a0,a0,-1812 # 80027d48 <itable>
    80003464:	f9afd0ef          	jal	80000bfe <acquire>
  empty = 0;
    80003468:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000346a:	00025497          	auipc	s1,0x25
    8000346e:	8f648493          	addi	s1,s1,-1802 # 80027d60 <itable+0x18>
    80003472:	00026697          	auipc	a3,0x26
    80003476:	37e68693          	addi	a3,a3,894 # 800297f0 <log>
    8000347a:	a039                	j	80003488 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000347c:	02090963          	beqz	s2,800034ae <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003480:	08848493          	addi	s1,s1,136
    80003484:	02d48863          	beq	s1,a3,800034b4 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003488:	449c                	lw	a5,8(s1)
    8000348a:	fef059e3          	blez	a5,8000347c <iget+0x34>
    8000348e:	4098                	lw	a4,0(s1)
    80003490:	ff3716e3          	bne	a4,s3,8000347c <iget+0x34>
    80003494:	40d8                	lw	a4,4(s1)
    80003496:	ff4713e3          	bne	a4,s4,8000347c <iget+0x34>
      ip->ref++;
    8000349a:	2785                	addiw	a5,a5,1
    8000349c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000349e:	00025517          	auipc	a0,0x25
    800034a2:	8aa50513          	addi	a0,a0,-1878 # 80027d48 <itable>
    800034a6:	fecfd0ef          	jal	80000c92 <release>
      return ip;
    800034aa:	8926                	mv	s2,s1
    800034ac:	a02d                	j	800034d6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034ae:	fbe9                	bnez	a5,80003480 <iget+0x38>
      empty = ip;
    800034b0:	8926                	mv	s2,s1
    800034b2:	b7f9                	j	80003480 <iget+0x38>
  if(empty == 0)
    800034b4:	02090a63          	beqz	s2,800034e8 <iget+0xa0>
  ip->dev = dev;
    800034b8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034bc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034c0:	4785                	li	a5,1
    800034c2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034c6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034ca:	00025517          	auipc	a0,0x25
    800034ce:	87e50513          	addi	a0,a0,-1922 # 80027d48 <itable>
    800034d2:	fc0fd0ef          	jal	80000c92 <release>
}
    800034d6:	854a                	mv	a0,s2
    800034d8:	70a2                	ld	ra,40(sp)
    800034da:	7402                	ld	s0,32(sp)
    800034dc:	64e2                	ld	s1,24(sp)
    800034de:	6942                	ld	s2,16(sp)
    800034e0:	69a2                	ld	s3,8(sp)
    800034e2:	6a02                	ld	s4,0(sp)
    800034e4:	6145                	addi	sp,sp,48
    800034e6:	8082                	ret
    panic("iget: no inodes");
    800034e8:	00004517          	auipc	a0,0x4
    800034ec:	0e050513          	addi	a0,a0,224 # 800075c8 <etext+0x5c8>
    800034f0:	aaefd0ef          	jal	8000079e <panic>

00000000800034f4 <fsinit>:
fsinit(int dev) {
    800034f4:	7179                	addi	sp,sp,-48
    800034f6:	f406                	sd	ra,40(sp)
    800034f8:	f022                	sd	s0,32(sp)
    800034fa:	ec26                	sd	s1,24(sp)
    800034fc:	e84a                	sd	s2,16(sp)
    800034fe:	e44e                	sd	s3,8(sp)
    80003500:	1800                	addi	s0,sp,48
    80003502:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003504:	4585                	li	a1,1
    80003506:	b11ff0ef          	jal	80003016 <bread>
    8000350a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000350c:	00025997          	auipc	s3,0x25
    80003510:	81c98993          	addi	s3,s3,-2020 # 80027d28 <sb>
    80003514:	02000613          	li	a2,32
    80003518:	05850593          	addi	a1,a0,88
    8000351c:	854e                	mv	a0,s3
    8000351e:	815fd0ef          	jal	80000d32 <memmove>
  brelse(bp);
    80003522:	8526                	mv	a0,s1
    80003524:	bfbff0ef          	jal	8000311e <brelse>
  if(sb.magic != FSMAGIC)
    80003528:	0009a703          	lw	a4,0(s3)
    8000352c:	102037b7          	lui	a5,0x10203
    80003530:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003534:	02f71063          	bne	a4,a5,80003554 <fsinit+0x60>
  initlog(dev, &sb);
    80003538:	00024597          	auipc	a1,0x24
    8000353c:	7f058593          	addi	a1,a1,2032 # 80027d28 <sb>
    80003540:	854a                	mv	a0,s2
    80003542:	215000ef          	jal	80003f56 <initlog>
}
    80003546:	70a2                	ld	ra,40(sp)
    80003548:	7402                	ld	s0,32(sp)
    8000354a:	64e2                	ld	s1,24(sp)
    8000354c:	6942                	ld	s2,16(sp)
    8000354e:	69a2                	ld	s3,8(sp)
    80003550:	6145                	addi	sp,sp,48
    80003552:	8082                	ret
    panic("invalid file system");
    80003554:	00004517          	auipc	a0,0x4
    80003558:	08450513          	addi	a0,a0,132 # 800075d8 <etext+0x5d8>
    8000355c:	a42fd0ef          	jal	8000079e <panic>

0000000080003560 <iinit>:
{
    80003560:	7179                	addi	sp,sp,-48
    80003562:	f406                	sd	ra,40(sp)
    80003564:	f022                	sd	s0,32(sp)
    80003566:	ec26                	sd	s1,24(sp)
    80003568:	e84a                	sd	s2,16(sp)
    8000356a:	e44e                	sd	s3,8(sp)
    8000356c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000356e:	00004597          	auipc	a1,0x4
    80003572:	08258593          	addi	a1,a1,130 # 800075f0 <etext+0x5f0>
    80003576:	00024517          	auipc	a0,0x24
    8000357a:	7d250513          	addi	a0,a0,2002 # 80027d48 <itable>
    8000357e:	dfcfd0ef          	jal	80000b7a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003582:	00024497          	auipc	s1,0x24
    80003586:	7ee48493          	addi	s1,s1,2030 # 80027d70 <itable+0x28>
    8000358a:	00026997          	auipc	s3,0x26
    8000358e:	27698993          	addi	s3,s3,630 # 80029800 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003592:	00004917          	auipc	s2,0x4
    80003596:	06690913          	addi	s2,s2,102 # 800075f8 <etext+0x5f8>
    8000359a:	85ca                	mv	a1,s2
    8000359c:	8526                	mv	a0,s1
    8000359e:	497000ef          	jal	80004234 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035a2:	08848493          	addi	s1,s1,136
    800035a6:	ff349ae3          	bne	s1,s3,8000359a <iinit+0x3a>
}
    800035aa:	70a2                	ld	ra,40(sp)
    800035ac:	7402                	ld	s0,32(sp)
    800035ae:	64e2                	ld	s1,24(sp)
    800035b0:	6942                	ld	s2,16(sp)
    800035b2:	69a2                	ld	s3,8(sp)
    800035b4:	6145                	addi	sp,sp,48
    800035b6:	8082                	ret

00000000800035b8 <ialloc>:
{
    800035b8:	7139                	addi	sp,sp,-64
    800035ba:	fc06                	sd	ra,56(sp)
    800035bc:	f822                	sd	s0,48(sp)
    800035be:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035c0:	00024717          	auipc	a4,0x24
    800035c4:	77472703          	lw	a4,1908(a4) # 80027d34 <sb+0xc>
    800035c8:	4785                	li	a5,1
    800035ca:	06e7f063          	bgeu	a5,a4,8000362a <ialloc+0x72>
    800035ce:	f426                	sd	s1,40(sp)
    800035d0:	f04a                	sd	s2,32(sp)
    800035d2:	ec4e                	sd	s3,24(sp)
    800035d4:	e852                	sd	s4,16(sp)
    800035d6:	e456                	sd	s5,8(sp)
    800035d8:	e05a                	sd	s6,0(sp)
    800035da:	8aaa                	mv	s5,a0
    800035dc:	8b2e                	mv	s6,a1
    800035de:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800035e0:	00024a17          	auipc	s4,0x24
    800035e4:	748a0a13          	addi	s4,s4,1864 # 80027d28 <sb>
    800035e8:	00495593          	srli	a1,s2,0x4
    800035ec:	018a2783          	lw	a5,24(s4)
    800035f0:	9dbd                	addw	a1,a1,a5
    800035f2:	8556                	mv	a0,s5
    800035f4:	a23ff0ef          	jal	80003016 <bread>
    800035f8:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035fa:	05850993          	addi	s3,a0,88
    800035fe:	00f97793          	andi	a5,s2,15
    80003602:	079a                	slli	a5,a5,0x6
    80003604:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003606:	00099783          	lh	a5,0(s3)
    8000360a:	cb9d                	beqz	a5,80003640 <ialloc+0x88>
    brelse(bp);
    8000360c:	b13ff0ef          	jal	8000311e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003610:	0905                	addi	s2,s2,1
    80003612:	00ca2703          	lw	a4,12(s4)
    80003616:	0009079b          	sext.w	a5,s2
    8000361a:	fce7e7e3          	bltu	a5,a4,800035e8 <ialloc+0x30>
    8000361e:	74a2                	ld	s1,40(sp)
    80003620:	7902                	ld	s2,32(sp)
    80003622:	69e2                	ld	s3,24(sp)
    80003624:	6a42                	ld	s4,16(sp)
    80003626:	6aa2                	ld	s5,8(sp)
    80003628:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000362a:	00004517          	auipc	a0,0x4
    8000362e:	fd650513          	addi	a0,a0,-42 # 80007600 <etext+0x600>
    80003632:	e9dfc0ef          	jal	800004ce <printf>
  return 0;
    80003636:	4501                	li	a0,0
}
    80003638:	70e2                	ld	ra,56(sp)
    8000363a:	7442                	ld	s0,48(sp)
    8000363c:	6121                	addi	sp,sp,64
    8000363e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003640:	04000613          	li	a2,64
    80003644:	4581                	li	a1,0
    80003646:	854e                	mv	a0,s3
    80003648:	e86fd0ef          	jal	80000cce <memset>
      dip->type = type;
    8000364c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003650:	8526                	mv	a0,s1
    80003652:	313000ef          	jal	80004164 <log_write>
      brelse(bp);
    80003656:	8526                	mv	a0,s1
    80003658:	ac7ff0ef          	jal	8000311e <brelse>
      return iget(dev, inum);
    8000365c:	0009059b          	sext.w	a1,s2
    80003660:	8556                	mv	a0,s5
    80003662:	de7ff0ef          	jal	80003448 <iget>
    80003666:	74a2                	ld	s1,40(sp)
    80003668:	7902                	ld	s2,32(sp)
    8000366a:	69e2                	ld	s3,24(sp)
    8000366c:	6a42                	ld	s4,16(sp)
    8000366e:	6aa2                	ld	s5,8(sp)
    80003670:	6b02                	ld	s6,0(sp)
    80003672:	b7d9                	j	80003638 <ialloc+0x80>

0000000080003674 <iupdate>:
{
    80003674:	1101                	addi	sp,sp,-32
    80003676:	ec06                	sd	ra,24(sp)
    80003678:	e822                	sd	s0,16(sp)
    8000367a:	e426                	sd	s1,8(sp)
    8000367c:	e04a                	sd	s2,0(sp)
    8000367e:	1000                	addi	s0,sp,32
    80003680:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003682:	415c                	lw	a5,4(a0)
    80003684:	0047d79b          	srliw	a5,a5,0x4
    80003688:	00024597          	auipc	a1,0x24
    8000368c:	6b85a583          	lw	a1,1720(a1) # 80027d40 <sb+0x18>
    80003690:	9dbd                	addw	a1,a1,a5
    80003692:	4108                	lw	a0,0(a0)
    80003694:	983ff0ef          	jal	80003016 <bread>
    80003698:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000369a:	05850793          	addi	a5,a0,88
    8000369e:	40d8                	lw	a4,4(s1)
    800036a0:	8b3d                	andi	a4,a4,15
    800036a2:	071a                	slli	a4,a4,0x6
    800036a4:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036a6:	04449703          	lh	a4,68(s1)
    800036aa:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036ae:	04649703          	lh	a4,70(s1)
    800036b2:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036b6:	04849703          	lh	a4,72(s1)
    800036ba:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036be:	04a49703          	lh	a4,74(s1)
    800036c2:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800036c6:	44f8                	lw	a4,76(s1)
    800036c8:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036ca:	03400613          	li	a2,52
    800036ce:	05048593          	addi	a1,s1,80
    800036d2:	00c78513          	addi	a0,a5,12
    800036d6:	e5cfd0ef          	jal	80000d32 <memmove>
  log_write(bp);
    800036da:	854a                	mv	a0,s2
    800036dc:	289000ef          	jal	80004164 <log_write>
  brelse(bp);
    800036e0:	854a                	mv	a0,s2
    800036e2:	a3dff0ef          	jal	8000311e <brelse>
}
    800036e6:	60e2                	ld	ra,24(sp)
    800036e8:	6442                	ld	s0,16(sp)
    800036ea:	64a2                	ld	s1,8(sp)
    800036ec:	6902                	ld	s2,0(sp)
    800036ee:	6105                	addi	sp,sp,32
    800036f0:	8082                	ret

00000000800036f2 <idup>:
{
    800036f2:	1101                	addi	sp,sp,-32
    800036f4:	ec06                	sd	ra,24(sp)
    800036f6:	e822                	sd	s0,16(sp)
    800036f8:	e426                	sd	s1,8(sp)
    800036fa:	1000                	addi	s0,sp,32
    800036fc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036fe:	00024517          	auipc	a0,0x24
    80003702:	64a50513          	addi	a0,a0,1610 # 80027d48 <itable>
    80003706:	cf8fd0ef          	jal	80000bfe <acquire>
  ip->ref++;
    8000370a:	449c                	lw	a5,8(s1)
    8000370c:	2785                	addiw	a5,a5,1
    8000370e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003710:	00024517          	auipc	a0,0x24
    80003714:	63850513          	addi	a0,a0,1592 # 80027d48 <itable>
    80003718:	d7afd0ef          	jal	80000c92 <release>
}
    8000371c:	8526                	mv	a0,s1
    8000371e:	60e2                	ld	ra,24(sp)
    80003720:	6442                	ld	s0,16(sp)
    80003722:	64a2                	ld	s1,8(sp)
    80003724:	6105                	addi	sp,sp,32
    80003726:	8082                	ret

0000000080003728 <ilock>:
{
    80003728:	1101                	addi	sp,sp,-32
    8000372a:	ec06                	sd	ra,24(sp)
    8000372c:	e822                	sd	s0,16(sp)
    8000372e:	e426                	sd	s1,8(sp)
    80003730:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003732:	cd19                	beqz	a0,80003750 <ilock+0x28>
    80003734:	84aa                	mv	s1,a0
    80003736:	451c                	lw	a5,8(a0)
    80003738:	00f05c63          	blez	a5,80003750 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000373c:	0541                	addi	a0,a0,16
    8000373e:	32d000ef          	jal	8000426a <acquiresleep>
  if(ip->valid == 0){
    80003742:	40bc                	lw	a5,64(s1)
    80003744:	cf89                	beqz	a5,8000375e <ilock+0x36>
}
    80003746:	60e2                	ld	ra,24(sp)
    80003748:	6442                	ld	s0,16(sp)
    8000374a:	64a2                	ld	s1,8(sp)
    8000374c:	6105                	addi	sp,sp,32
    8000374e:	8082                	ret
    80003750:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003752:	00004517          	auipc	a0,0x4
    80003756:	ec650513          	addi	a0,a0,-314 # 80007618 <etext+0x618>
    8000375a:	844fd0ef          	jal	8000079e <panic>
    8000375e:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003760:	40dc                	lw	a5,4(s1)
    80003762:	0047d79b          	srliw	a5,a5,0x4
    80003766:	00024597          	auipc	a1,0x24
    8000376a:	5da5a583          	lw	a1,1498(a1) # 80027d40 <sb+0x18>
    8000376e:	9dbd                	addw	a1,a1,a5
    80003770:	4088                	lw	a0,0(s1)
    80003772:	8a5ff0ef          	jal	80003016 <bread>
    80003776:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003778:	05850593          	addi	a1,a0,88
    8000377c:	40dc                	lw	a5,4(s1)
    8000377e:	8bbd                	andi	a5,a5,15
    80003780:	079a                	slli	a5,a5,0x6
    80003782:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003784:	00059783          	lh	a5,0(a1)
    80003788:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000378c:	00259783          	lh	a5,2(a1)
    80003790:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003794:	00459783          	lh	a5,4(a1)
    80003798:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000379c:	00659783          	lh	a5,6(a1)
    800037a0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037a4:	459c                	lw	a5,8(a1)
    800037a6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037a8:	03400613          	li	a2,52
    800037ac:	05b1                	addi	a1,a1,12
    800037ae:	05048513          	addi	a0,s1,80
    800037b2:	d80fd0ef          	jal	80000d32 <memmove>
    brelse(bp);
    800037b6:	854a                	mv	a0,s2
    800037b8:	967ff0ef          	jal	8000311e <brelse>
    ip->valid = 1;
    800037bc:	4785                	li	a5,1
    800037be:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037c0:	04449783          	lh	a5,68(s1)
    800037c4:	c399                	beqz	a5,800037ca <ilock+0xa2>
    800037c6:	6902                	ld	s2,0(sp)
    800037c8:	bfbd                	j	80003746 <ilock+0x1e>
      panic("ilock: no type");
    800037ca:	00004517          	auipc	a0,0x4
    800037ce:	e5650513          	addi	a0,a0,-426 # 80007620 <etext+0x620>
    800037d2:	fcdfc0ef          	jal	8000079e <panic>

00000000800037d6 <iunlock>:
{
    800037d6:	1101                	addi	sp,sp,-32
    800037d8:	ec06                	sd	ra,24(sp)
    800037da:	e822                	sd	s0,16(sp)
    800037dc:	e426                	sd	s1,8(sp)
    800037de:	e04a                	sd	s2,0(sp)
    800037e0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037e2:	c505                	beqz	a0,8000380a <iunlock+0x34>
    800037e4:	84aa                	mv	s1,a0
    800037e6:	01050913          	addi	s2,a0,16
    800037ea:	854a                	mv	a0,s2
    800037ec:	2fd000ef          	jal	800042e8 <holdingsleep>
    800037f0:	cd09                	beqz	a0,8000380a <iunlock+0x34>
    800037f2:	449c                	lw	a5,8(s1)
    800037f4:	00f05b63          	blez	a5,8000380a <iunlock+0x34>
  releasesleep(&ip->lock);
    800037f8:	854a                	mv	a0,s2
    800037fa:	2b7000ef          	jal	800042b0 <releasesleep>
}
    800037fe:	60e2                	ld	ra,24(sp)
    80003800:	6442                	ld	s0,16(sp)
    80003802:	64a2                	ld	s1,8(sp)
    80003804:	6902                	ld	s2,0(sp)
    80003806:	6105                	addi	sp,sp,32
    80003808:	8082                	ret
    panic("iunlock");
    8000380a:	00004517          	auipc	a0,0x4
    8000380e:	e2650513          	addi	a0,a0,-474 # 80007630 <etext+0x630>
    80003812:	f8dfc0ef          	jal	8000079e <panic>

0000000080003816 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003816:	7179                	addi	sp,sp,-48
    80003818:	f406                	sd	ra,40(sp)
    8000381a:	f022                	sd	s0,32(sp)
    8000381c:	ec26                	sd	s1,24(sp)
    8000381e:	e84a                	sd	s2,16(sp)
    80003820:	e44e                	sd	s3,8(sp)
    80003822:	1800                	addi	s0,sp,48
    80003824:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003826:	05050493          	addi	s1,a0,80
    8000382a:	08050913          	addi	s2,a0,128
    8000382e:	a021                	j	80003836 <itrunc+0x20>
    80003830:	0491                	addi	s1,s1,4
    80003832:	01248b63          	beq	s1,s2,80003848 <itrunc+0x32>
    if(ip->addrs[i]){
    80003836:	408c                	lw	a1,0(s1)
    80003838:	dde5                	beqz	a1,80003830 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000383a:	0009a503          	lw	a0,0(s3)
    8000383e:	9cdff0ef          	jal	8000320a <bfree>
      ip->addrs[i] = 0;
    80003842:	0004a023          	sw	zero,0(s1)
    80003846:	b7ed                	j	80003830 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003848:	0809a583          	lw	a1,128(s3)
    8000384c:	ed89                	bnez	a1,80003866 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000384e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003852:	854e                	mv	a0,s3
    80003854:	e21ff0ef          	jal	80003674 <iupdate>
}
    80003858:	70a2                	ld	ra,40(sp)
    8000385a:	7402                	ld	s0,32(sp)
    8000385c:	64e2                	ld	s1,24(sp)
    8000385e:	6942                	ld	s2,16(sp)
    80003860:	69a2                	ld	s3,8(sp)
    80003862:	6145                	addi	sp,sp,48
    80003864:	8082                	ret
    80003866:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003868:	0009a503          	lw	a0,0(s3)
    8000386c:	faaff0ef          	jal	80003016 <bread>
    80003870:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003872:	05850493          	addi	s1,a0,88
    80003876:	45850913          	addi	s2,a0,1112
    8000387a:	a021                	j	80003882 <itrunc+0x6c>
    8000387c:	0491                	addi	s1,s1,4
    8000387e:	01248963          	beq	s1,s2,80003890 <itrunc+0x7a>
      if(a[j])
    80003882:	408c                	lw	a1,0(s1)
    80003884:	dde5                	beqz	a1,8000387c <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003886:	0009a503          	lw	a0,0(s3)
    8000388a:	981ff0ef          	jal	8000320a <bfree>
    8000388e:	b7fd                	j	8000387c <itrunc+0x66>
    brelse(bp);
    80003890:	8552                	mv	a0,s4
    80003892:	88dff0ef          	jal	8000311e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003896:	0809a583          	lw	a1,128(s3)
    8000389a:	0009a503          	lw	a0,0(s3)
    8000389e:	96dff0ef          	jal	8000320a <bfree>
    ip->addrs[NDIRECT] = 0;
    800038a2:	0809a023          	sw	zero,128(s3)
    800038a6:	6a02                	ld	s4,0(sp)
    800038a8:	b75d                	j	8000384e <itrunc+0x38>

00000000800038aa <iput>:
{
    800038aa:	1101                	addi	sp,sp,-32
    800038ac:	ec06                	sd	ra,24(sp)
    800038ae:	e822                	sd	s0,16(sp)
    800038b0:	e426                	sd	s1,8(sp)
    800038b2:	1000                	addi	s0,sp,32
    800038b4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038b6:	00024517          	auipc	a0,0x24
    800038ba:	49250513          	addi	a0,a0,1170 # 80027d48 <itable>
    800038be:	b40fd0ef          	jal	80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038c2:	4498                	lw	a4,8(s1)
    800038c4:	4785                	li	a5,1
    800038c6:	02f70063          	beq	a4,a5,800038e6 <iput+0x3c>
  ip->ref--;
    800038ca:	449c                	lw	a5,8(s1)
    800038cc:	37fd                	addiw	a5,a5,-1
    800038ce:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038d0:	00024517          	auipc	a0,0x24
    800038d4:	47850513          	addi	a0,a0,1144 # 80027d48 <itable>
    800038d8:	bbafd0ef          	jal	80000c92 <release>
}
    800038dc:	60e2                	ld	ra,24(sp)
    800038de:	6442                	ld	s0,16(sp)
    800038e0:	64a2                	ld	s1,8(sp)
    800038e2:	6105                	addi	sp,sp,32
    800038e4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038e6:	40bc                	lw	a5,64(s1)
    800038e8:	d3ed                	beqz	a5,800038ca <iput+0x20>
    800038ea:	04a49783          	lh	a5,74(s1)
    800038ee:	fff1                	bnez	a5,800038ca <iput+0x20>
    800038f0:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800038f2:	01048913          	addi	s2,s1,16
    800038f6:	854a                	mv	a0,s2
    800038f8:	173000ef          	jal	8000426a <acquiresleep>
    release(&itable.lock);
    800038fc:	00024517          	auipc	a0,0x24
    80003900:	44c50513          	addi	a0,a0,1100 # 80027d48 <itable>
    80003904:	b8efd0ef          	jal	80000c92 <release>
    itrunc(ip);
    80003908:	8526                	mv	a0,s1
    8000390a:	f0dff0ef          	jal	80003816 <itrunc>
    ip->type = 0;
    8000390e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003912:	8526                	mv	a0,s1
    80003914:	d61ff0ef          	jal	80003674 <iupdate>
    ip->valid = 0;
    80003918:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000391c:	854a                	mv	a0,s2
    8000391e:	193000ef          	jal	800042b0 <releasesleep>
    acquire(&itable.lock);
    80003922:	00024517          	auipc	a0,0x24
    80003926:	42650513          	addi	a0,a0,1062 # 80027d48 <itable>
    8000392a:	ad4fd0ef          	jal	80000bfe <acquire>
    8000392e:	6902                	ld	s2,0(sp)
    80003930:	bf69                	j	800038ca <iput+0x20>

0000000080003932 <iunlockput>:
{
    80003932:	1101                	addi	sp,sp,-32
    80003934:	ec06                	sd	ra,24(sp)
    80003936:	e822                	sd	s0,16(sp)
    80003938:	e426                	sd	s1,8(sp)
    8000393a:	1000                	addi	s0,sp,32
    8000393c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000393e:	e99ff0ef          	jal	800037d6 <iunlock>
  iput(ip);
    80003942:	8526                	mv	a0,s1
    80003944:	f67ff0ef          	jal	800038aa <iput>
}
    80003948:	60e2                	ld	ra,24(sp)
    8000394a:	6442                	ld	s0,16(sp)
    8000394c:	64a2                	ld	s1,8(sp)
    8000394e:	6105                	addi	sp,sp,32
    80003950:	8082                	ret

0000000080003952 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003952:	1141                	addi	sp,sp,-16
    80003954:	e406                	sd	ra,8(sp)
    80003956:	e022                	sd	s0,0(sp)
    80003958:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000395a:	411c                	lw	a5,0(a0)
    8000395c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000395e:	415c                	lw	a5,4(a0)
    80003960:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003962:	04451783          	lh	a5,68(a0)
    80003966:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000396a:	04a51783          	lh	a5,74(a0)
    8000396e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003972:	04c56783          	lwu	a5,76(a0)
    80003976:	e99c                	sd	a5,16(a1)
}
    80003978:	60a2                	ld	ra,8(sp)
    8000397a:	6402                	ld	s0,0(sp)
    8000397c:	0141                	addi	sp,sp,16
    8000397e:	8082                	ret

0000000080003980 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003980:	457c                	lw	a5,76(a0)
    80003982:	0ed7e663          	bltu	a5,a3,80003a6e <readi+0xee>
{
    80003986:	7159                	addi	sp,sp,-112
    80003988:	f486                	sd	ra,104(sp)
    8000398a:	f0a2                	sd	s0,96(sp)
    8000398c:	eca6                	sd	s1,88(sp)
    8000398e:	e0d2                	sd	s4,64(sp)
    80003990:	fc56                	sd	s5,56(sp)
    80003992:	f85a                	sd	s6,48(sp)
    80003994:	f45e                	sd	s7,40(sp)
    80003996:	1880                	addi	s0,sp,112
    80003998:	8b2a                	mv	s6,a0
    8000399a:	8bae                	mv	s7,a1
    8000399c:	8a32                	mv	s4,a2
    8000399e:	84b6                	mv	s1,a3
    800039a0:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800039a2:	9f35                	addw	a4,a4,a3
    return 0;
    800039a4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039a6:	0ad76b63          	bltu	a4,a3,80003a5c <readi+0xdc>
    800039aa:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800039ac:	00e7f463          	bgeu	a5,a4,800039b4 <readi+0x34>
    n = ip->size - off;
    800039b0:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039b4:	080a8b63          	beqz	s5,80003a4a <readi+0xca>
    800039b8:	e8ca                	sd	s2,80(sp)
    800039ba:	f062                	sd	s8,32(sp)
    800039bc:	ec66                	sd	s9,24(sp)
    800039be:	e86a                	sd	s10,16(sp)
    800039c0:	e46e                	sd	s11,8(sp)
    800039c2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039c4:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039c8:	5c7d                	li	s8,-1
    800039ca:	a80d                	j	800039fc <readi+0x7c>
    800039cc:	020d1d93          	slli	s11,s10,0x20
    800039d0:	020ddd93          	srli	s11,s11,0x20
    800039d4:	05890613          	addi	a2,s2,88
    800039d8:	86ee                	mv	a3,s11
    800039da:	963e                	add	a2,a2,a5
    800039dc:	85d2                	mv	a1,s4
    800039de:	855e                	mv	a0,s7
    800039e0:	b91fe0ef          	jal	80002570 <either_copyout>
    800039e4:	05850363          	beq	a0,s8,80003a2a <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039e8:	854a                	mv	a0,s2
    800039ea:	f34ff0ef          	jal	8000311e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039ee:	013d09bb          	addw	s3,s10,s3
    800039f2:	009d04bb          	addw	s1,s10,s1
    800039f6:	9a6e                	add	s4,s4,s11
    800039f8:	0559f363          	bgeu	s3,s5,80003a3e <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800039fc:	00a4d59b          	srliw	a1,s1,0xa
    80003a00:	855a                	mv	a0,s6
    80003a02:	987ff0ef          	jal	80003388 <bmap>
    80003a06:	85aa                	mv	a1,a0
    if(addr == 0)
    80003a08:	c139                	beqz	a0,80003a4e <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a0a:	000b2503          	lw	a0,0(s6)
    80003a0e:	e08ff0ef          	jal	80003016 <bread>
    80003a12:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a14:	3ff4f793          	andi	a5,s1,1023
    80003a18:	40fc873b          	subw	a4,s9,a5
    80003a1c:	413a86bb          	subw	a3,s5,s3
    80003a20:	8d3a                	mv	s10,a4
    80003a22:	fae6f5e3          	bgeu	a3,a4,800039cc <readi+0x4c>
    80003a26:	8d36                	mv	s10,a3
    80003a28:	b755                	j	800039cc <readi+0x4c>
      brelse(bp);
    80003a2a:	854a                	mv	a0,s2
    80003a2c:	ef2ff0ef          	jal	8000311e <brelse>
      tot = -1;
    80003a30:	59fd                	li	s3,-1
      break;
    80003a32:	6946                	ld	s2,80(sp)
    80003a34:	7c02                	ld	s8,32(sp)
    80003a36:	6ce2                	ld	s9,24(sp)
    80003a38:	6d42                	ld	s10,16(sp)
    80003a3a:	6da2                	ld	s11,8(sp)
    80003a3c:	a831                	j	80003a58 <readi+0xd8>
    80003a3e:	6946                	ld	s2,80(sp)
    80003a40:	7c02                	ld	s8,32(sp)
    80003a42:	6ce2                	ld	s9,24(sp)
    80003a44:	6d42                	ld	s10,16(sp)
    80003a46:	6da2                	ld	s11,8(sp)
    80003a48:	a801                	j	80003a58 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a4a:	89d6                	mv	s3,s5
    80003a4c:	a031                	j	80003a58 <readi+0xd8>
    80003a4e:	6946                	ld	s2,80(sp)
    80003a50:	7c02                	ld	s8,32(sp)
    80003a52:	6ce2                	ld	s9,24(sp)
    80003a54:	6d42                	ld	s10,16(sp)
    80003a56:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003a58:	854e                	mv	a0,s3
    80003a5a:	69a6                	ld	s3,72(sp)
}
    80003a5c:	70a6                	ld	ra,104(sp)
    80003a5e:	7406                	ld	s0,96(sp)
    80003a60:	64e6                	ld	s1,88(sp)
    80003a62:	6a06                	ld	s4,64(sp)
    80003a64:	7ae2                	ld	s5,56(sp)
    80003a66:	7b42                	ld	s6,48(sp)
    80003a68:	7ba2                	ld	s7,40(sp)
    80003a6a:	6165                	addi	sp,sp,112
    80003a6c:	8082                	ret
    return 0;
    80003a6e:	4501                	li	a0,0
}
    80003a70:	8082                	ret

0000000080003a72 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a72:	457c                	lw	a5,76(a0)
    80003a74:	0ed7eb63          	bltu	a5,a3,80003b6a <writei+0xf8>
{
    80003a78:	7159                	addi	sp,sp,-112
    80003a7a:	f486                	sd	ra,104(sp)
    80003a7c:	f0a2                	sd	s0,96(sp)
    80003a7e:	e8ca                	sd	s2,80(sp)
    80003a80:	e0d2                	sd	s4,64(sp)
    80003a82:	fc56                	sd	s5,56(sp)
    80003a84:	f85a                	sd	s6,48(sp)
    80003a86:	f45e                	sd	s7,40(sp)
    80003a88:	1880                	addi	s0,sp,112
    80003a8a:	8aaa                	mv	s5,a0
    80003a8c:	8bae                	mv	s7,a1
    80003a8e:	8a32                	mv	s4,a2
    80003a90:	8936                	mv	s2,a3
    80003a92:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a94:	00e687bb          	addw	a5,a3,a4
    80003a98:	0cd7eb63          	bltu	a5,a3,80003b6e <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a9c:	00043737          	lui	a4,0x43
    80003aa0:	0cf76963          	bltu	a4,a5,80003b72 <writei+0x100>
    80003aa4:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aa6:	0a0b0a63          	beqz	s6,80003b5a <writei+0xe8>
    80003aaa:	eca6                	sd	s1,88(sp)
    80003aac:	f062                	sd	s8,32(sp)
    80003aae:	ec66                	sd	s9,24(sp)
    80003ab0:	e86a                	sd	s10,16(sp)
    80003ab2:	e46e                	sd	s11,8(sp)
    80003ab4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ab6:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003aba:	5c7d                	li	s8,-1
    80003abc:	a825                	j	80003af4 <writei+0x82>
    80003abe:	020d1d93          	slli	s11,s10,0x20
    80003ac2:	020ddd93          	srli	s11,s11,0x20
    80003ac6:	05848513          	addi	a0,s1,88
    80003aca:	86ee                	mv	a3,s11
    80003acc:	8652                	mv	a2,s4
    80003ace:	85de                	mv	a1,s7
    80003ad0:	953e                	add	a0,a0,a5
    80003ad2:	ae9fe0ef          	jal	800025ba <either_copyin>
    80003ad6:	05850663          	beq	a0,s8,80003b22 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ada:	8526                	mv	a0,s1
    80003adc:	688000ef          	jal	80004164 <log_write>
    brelse(bp);
    80003ae0:	8526                	mv	a0,s1
    80003ae2:	e3cff0ef          	jal	8000311e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ae6:	013d09bb          	addw	s3,s10,s3
    80003aea:	012d093b          	addw	s2,s10,s2
    80003aee:	9a6e                	add	s4,s4,s11
    80003af0:	0369fc63          	bgeu	s3,s6,80003b28 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003af4:	00a9559b          	srliw	a1,s2,0xa
    80003af8:	8556                	mv	a0,s5
    80003afa:	88fff0ef          	jal	80003388 <bmap>
    80003afe:	85aa                	mv	a1,a0
    if(addr == 0)
    80003b00:	c505                	beqz	a0,80003b28 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003b02:	000aa503          	lw	a0,0(s5)
    80003b06:	d10ff0ef          	jal	80003016 <bread>
    80003b0a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b0c:	3ff97793          	andi	a5,s2,1023
    80003b10:	40fc873b          	subw	a4,s9,a5
    80003b14:	413b06bb          	subw	a3,s6,s3
    80003b18:	8d3a                	mv	s10,a4
    80003b1a:	fae6f2e3          	bgeu	a3,a4,80003abe <writei+0x4c>
    80003b1e:	8d36                	mv	s10,a3
    80003b20:	bf79                	j	80003abe <writei+0x4c>
      brelse(bp);
    80003b22:	8526                	mv	a0,s1
    80003b24:	dfaff0ef          	jal	8000311e <brelse>
  }

  if(off > ip->size)
    80003b28:	04caa783          	lw	a5,76(s5)
    80003b2c:	0327f963          	bgeu	a5,s2,80003b5e <writei+0xec>
    ip->size = off;
    80003b30:	052aa623          	sw	s2,76(s5)
    80003b34:	64e6                	ld	s1,88(sp)
    80003b36:	7c02                	ld	s8,32(sp)
    80003b38:	6ce2                	ld	s9,24(sp)
    80003b3a:	6d42                	ld	s10,16(sp)
    80003b3c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b3e:	8556                	mv	a0,s5
    80003b40:	b35ff0ef          	jal	80003674 <iupdate>

  return tot;
    80003b44:	854e                	mv	a0,s3
    80003b46:	69a6                	ld	s3,72(sp)
}
    80003b48:	70a6                	ld	ra,104(sp)
    80003b4a:	7406                	ld	s0,96(sp)
    80003b4c:	6946                	ld	s2,80(sp)
    80003b4e:	6a06                	ld	s4,64(sp)
    80003b50:	7ae2                	ld	s5,56(sp)
    80003b52:	7b42                	ld	s6,48(sp)
    80003b54:	7ba2                	ld	s7,40(sp)
    80003b56:	6165                	addi	sp,sp,112
    80003b58:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b5a:	89da                	mv	s3,s6
    80003b5c:	b7cd                	j	80003b3e <writei+0xcc>
    80003b5e:	64e6                	ld	s1,88(sp)
    80003b60:	7c02                	ld	s8,32(sp)
    80003b62:	6ce2                	ld	s9,24(sp)
    80003b64:	6d42                	ld	s10,16(sp)
    80003b66:	6da2                	ld	s11,8(sp)
    80003b68:	bfd9                	j	80003b3e <writei+0xcc>
    return -1;
    80003b6a:	557d                	li	a0,-1
}
    80003b6c:	8082                	ret
    return -1;
    80003b6e:	557d                	li	a0,-1
    80003b70:	bfe1                	j	80003b48 <writei+0xd6>
    return -1;
    80003b72:	557d                	li	a0,-1
    80003b74:	bfd1                	j	80003b48 <writei+0xd6>

0000000080003b76 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b76:	1141                	addi	sp,sp,-16
    80003b78:	e406                	sd	ra,8(sp)
    80003b7a:	e022                	sd	s0,0(sp)
    80003b7c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b7e:	4639                	li	a2,14
    80003b80:	a26fd0ef          	jal	80000da6 <strncmp>
}
    80003b84:	60a2                	ld	ra,8(sp)
    80003b86:	6402                	ld	s0,0(sp)
    80003b88:	0141                	addi	sp,sp,16
    80003b8a:	8082                	ret

0000000080003b8c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b8c:	711d                	addi	sp,sp,-96
    80003b8e:	ec86                	sd	ra,88(sp)
    80003b90:	e8a2                	sd	s0,80(sp)
    80003b92:	e4a6                	sd	s1,72(sp)
    80003b94:	e0ca                	sd	s2,64(sp)
    80003b96:	fc4e                	sd	s3,56(sp)
    80003b98:	f852                	sd	s4,48(sp)
    80003b9a:	f456                	sd	s5,40(sp)
    80003b9c:	f05a                	sd	s6,32(sp)
    80003b9e:	ec5e                	sd	s7,24(sp)
    80003ba0:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ba2:	04451703          	lh	a4,68(a0)
    80003ba6:	4785                	li	a5,1
    80003ba8:	00f71f63          	bne	a4,a5,80003bc6 <dirlookup+0x3a>
    80003bac:	892a                	mv	s2,a0
    80003bae:	8aae                	mv	s5,a1
    80003bb0:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bb2:	457c                	lw	a5,76(a0)
    80003bb4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bb6:	fa040a13          	addi	s4,s0,-96
    80003bba:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003bbc:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bc0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bc2:	e39d                	bnez	a5,80003be8 <dirlookup+0x5c>
    80003bc4:	a8b9                	j	80003c22 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003bc6:	00004517          	auipc	a0,0x4
    80003bca:	a7250513          	addi	a0,a0,-1422 # 80007638 <etext+0x638>
    80003bce:	bd1fc0ef          	jal	8000079e <panic>
      panic("dirlookup read");
    80003bd2:	00004517          	auipc	a0,0x4
    80003bd6:	a7e50513          	addi	a0,a0,-1410 # 80007650 <etext+0x650>
    80003bda:	bc5fc0ef          	jal	8000079e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bde:	24c1                	addiw	s1,s1,16
    80003be0:	04c92783          	lw	a5,76(s2)
    80003be4:	02f4fe63          	bgeu	s1,a5,80003c20 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003be8:	874e                	mv	a4,s3
    80003bea:	86a6                	mv	a3,s1
    80003bec:	8652                	mv	a2,s4
    80003bee:	4581                	li	a1,0
    80003bf0:	854a                	mv	a0,s2
    80003bf2:	d8fff0ef          	jal	80003980 <readi>
    80003bf6:	fd351ee3          	bne	a0,s3,80003bd2 <dirlookup+0x46>
    if(de.inum == 0)
    80003bfa:	fa045783          	lhu	a5,-96(s0)
    80003bfe:	d3e5                	beqz	a5,80003bde <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003c00:	85da                	mv	a1,s6
    80003c02:	8556                	mv	a0,s5
    80003c04:	f73ff0ef          	jal	80003b76 <namecmp>
    80003c08:	f979                	bnez	a0,80003bde <dirlookup+0x52>
      if(poff)
    80003c0a:	000b8463          	beqz	s7,80003c12 <dirlookup+0x86>
        *poff = off;
    80003c0e:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003c12:	fa045583          	lhu	a1,-96(s0)
    80003c16:	00092503          	lw	a0,0(s2)
    80003c1a:	82fff0ef          	jal	80003448 <iget>
    80003c1e:	a011                	j	80003c22 <dirlookup+0x96>
  return 0;
    80003c20:	4501                	li	a0,0
}
    80003c22:	60e6                	ld	ra,88(sp)
    80003c24:	6446                	ld	s0,80(sp)
    80003c26:	64a6                	ld	s1,72(sp)
    80003c28:	6906                	ld	s2,64(sp)
    80003c2a:	79e2                	ld	s3,56(sp)
    80003c2c:	7a42                	ld	s4,48(sp)
    80003c2e:	7aa2                	ld	s5,40(sp)
    80003c30:	7b02                	ld	s6,32(sp)
    80003c32:	6be2                	ld	s7,24(sp)
    80003c34:	6125                	addi	sp,sp,96
    80003c36:	8082                	ret

0000000080003c38 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c38:	711d                	addi	sp,sp,-96
    80003c3a:	ec86                	sd	ra,88(sp)
    80003c3c:	e8a2                	sd	s0,80(sp)
    80003c3e:	e4a6                	sd	s1,72(sp)
    80003c40:	e0ca                	sd	s2,64(sp)
    80003c42:	fc4e                	sd	s3,56(sp)
    80003c44:	f852                	sd	s4,48(sp)
    80003c46:	f456                	sd	s5,40(sp)
    80003c48:	f05a                	sd	s6,32(sp)
    80003c4a:	ec5e                	sd	s7,24(sp)
    80003c4c:	e862                	sd	s8,16(sp)
    80003c4e:	e466                	sd	s9,8(sp)
    80003c50:	e06a                	sd	s10,0(sp)
    80003c52:	1080                	addi	s0,sp,96
    80003c54:	84aa                	mv	s1,a0
    80003c56:	8b2e                	mv	s6,a1
    80003c58:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c5a:	00054703          	lbu	a4,0(a0)
    80003c5e:	02f00793          	li	a5,47
    80003c62:	00f70f63          	beq	a4,a5,80003c80 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c66:	c77fd0ef          	jal	800018dc <myproc>
    80003c6a:	15053503          	ld	a0,336(a0)
    80003c6e:	a85ff0ef          	jal	800036f2 <idup>
    80003c72:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c74:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c78:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003c7a:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c7c:	4b85                	li	s7,1
    80003c7e:	a879                	j	80003d1c <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003c80:	4585                	li	a1,1
    80003c82:	852e                	mv	a0,a1
    80003c84:	fc4ff0ef          	jal	80003448 <iget>
    80003c88:	8a2a                	mv	s4,a0
    80003c8a:	b7ed                	j	80003c74 <namex+0x3c>
      iunlockput(ip);
    80003c8c:	8552                	mv	a0,s4
    80003c8e:	ca5ff0ef          	jal	80003932 <iunlockput>
      return 0;
    80003c92:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c94:	8552                	mv	a0,s4
    80003c96:	60e6                	ld	ra,88(sp)
    80003c98:	6446                	ld	s0,80(sp)
    80003c9a:	64a6                	ld	s1,72(sp)
    80003c9c:	6906                	ld	s2,64(sp)
    80003c9e:	79e2                	ld	s3,56(sp)
    80003ca0:	7a42                	ld	s4,48(sp)
    80003ca2:	7aa2                	ld	s5,40(sp)
    80003ca4:	7b02                	ld	s6,32(sp)
    80003ca6:	6be2                	ld	s7,24(sp)
    80003ca8:	6c42                	ld	s8,16(sp)
    80003caa:	6ca2                	ld	s9,8(sp)
    80003cac:	6d02                	ld	s10,0(sp)
    80003cae:	6125                	addi	sp,sp,96
    80003cb0:	8082                	ret
      iunlock(ip);
    80003cb2:	8552                	mv	a0,s4
    80003cb4:	b23ff0ef          	jal	800037d6 <iunlock>
      return ip;
    80003cb8:	bff1                	j	80003c94 <namex+0x5c>
      iunlockput(ip);
    80003cba:	8552                	mv	a0,s4
    80003cbc:	c77ff0ef          	jal	80003932 <iunlockput>
      return 0;
    80003cc0:	8a4e                	mv	s4,s3
    80003cc2:	bfc9                	j	80003c94 <namex+0x5c>
  len = path - s;
    80003cc4:	40998633          	sub	a2,s3,s1
    80003cc8:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003ccc:	09ac5063          	bge	s8,s10,80003d4c <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003cd0:	8666                	mv	a2,s9
    80003cd2:	85a6                	mv	a1,s1
    80003cd4:	8556                	mv	a0,s5
    80003cd6:	85cfd0ef          	jal	80000d32 <memmove>
    80003cda:	84ce                	mv	s1,s3
  while(*path == '/')
    80003cdc:	0004c783          	lbu	a5,0(s1)
    80003ce0:	01279763          	bne	a5,s2,80003cee <namex+0xb6>
    path++;
    80003ce4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ce6:	0004c783          	lbu	a5,0(s1)
    80003cea:	ff278de3          	beq	a5,s2,80003ce4 <namex+0xac>
    ilock(ip);
    80003cee:	8552                	mv	a0,s4
    80003cf0:	a39ff0ef          	jal	80003728 <ilock>
    if(ip->type != T_DIR){
    80003cf4:	044a1783          	lh	a5,68(s4)
    80003cf8:	f9779ae3          	bne	a5,s7,80003c8c <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003cfc:	000b0563          	beqz	s6,80003d06 <namex+0xce>
    80003d00:	0004c783          	lbu	a5,0(s1)
    80003d04:	d7dd                	beqz	a5,80003cb2 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d06:	4601                	li	a2,0
    80003d08:	85d6                	mv	a1,s5
    80003d0a:	8552                	mv	a0,s4
    80003d0c:	e81ff0ef          	jal	80003b8c <dirlookup>
    80003d10:	89aa                	mv	s3,a0
    80003d12:	d545                	beqz	a0,80003cba <namex+0x82>
    iunlockput(ip);
    80003d14:	8552                	mv	a0,s4
    80003d16:	c1dff0ef          	jal	80003932 <iunlockput>
    ip = next;
    80003d1a:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d1c:	0004c783          	lbu	a5,0(s1)
    80003d20:	01279763          	bne	a5,s2,80003d2e <namex+0xf6>
    path++;
    80003d24:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d26:	0004c783          	lbu	a5,0(s1)
    80003d2a:	ff278de3          	beq	a5,s2,80003d24 <namex+0xec>
  if(*path == 0)
    80003d2e:	cb8d                	beqz	a5,80003d60 <namex+0x128>
  while(*path != '/' && *path != 0)
    80003d30:	0004c783          	lbu	a5,0(s1)
    80003d34:	89a6                	mv	s3,s1
  len = path - s;
    80003d36:	4d01                	li	s10,0
    80003d38:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003d3a:	01278963          	beq	a5,s2,80003d4c <namex+0x114>
    80003d3e:	d3d9                	beqz	a5,80003cc4 <namex+0x8c>
    path++;
    80003d40:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d42:	0009c783          	lbu	a5,0(s3)
    80003d46:	ff279ce3          	bne	a5,s2,80003d3e <namex+0x106>
    80003d4a:	bfad                	j	80003cc4 <namex+0x8c>
    memmove(name, s, len);
    80003d4c:	2601                	sext.w	a2,a2
    80003d4e:	85a6                	mv	a1,s1
    80003d50:	8556                	mv	a0,s5
    80003d52:	fe1fc0ef          	jal	80000d32 <memmove>
    name[len] = 0;
    80003d56:	9d56                	add	s10,s10,s5
    80003d58:	000d0023          	sb	zero,0(s10)
    80003d5c:	84ce                	mv	s1,s3
    80003d5e:	bfbd                	j	80003cdc <namex+0xa4>
  if(nameiparent){
    80003d60:	f20b0ae3          	beqz	s6,80003c94 <namex+0x5c>
    iput(ip);
    80003d64:	8552                	mv	a0,s4
    80003d66:	b45ff0ef          	jal	800038aa <iput>
    return 0;
    80003d6a:	4a01                	li	s4,0
    80003d6c:	b725                	j	80003c94 <namex+0x5c>

0000000080003d6e <dirlink>:
{
    80003d6e:	715d                	addi	sp,sp,-80
    80003d70:	e486                	sd	ra,72(sp)
    80003d72:	e0a2                	sd	s0,64(sp)
    80003d74:	f84a                	sd	s2,48(sp)
    80003d76:	ec56                	sd	s5,24(sp)
    80003d78:	e85a                	sd	s6,16(sp)
    80003d7a:	0880                	addi	s0,sp,80
    80003d7c:	892a                	mv	s2,a0
    80003d7e:	8aae                	mv	s5,a1
    80003d80:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d82:	4601                	li	a2,0
    80003d84:	e09ff0ef          	jal	80003b8c <dirlookup>
    80003d88:	ed1d                	bnez	a0,80003dc6 <dirlink+0x58>
    80003d8a:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d8c:	04c92483          	lw	s1,76(s2)
    80003d90:	c4b9                	beqz	s1,80003dde <dirlink+0x70>
    80003d92:	f44e                	sd	s3,40(sp)
    80003d94:	f052                	sd	s4,32(sp)
    80003d96:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d98:	fb040a13          	addi	s4,s0,-80
    80003d9c:	49c1                	li	s3,16
    80003d9e:	874e                	mv	a4,s3
    80003da0:	86a6                	mv	a3,s1
    80003da2:	8652                	mv	a2,s4
    80003da4:	4581                	li	a1,0
    80003da6:	854a                	mv	a0,s2
    80003da8:	bd9ff0ef          	jal	80003980 <readi>
    80003dac:	03351163          	bne	a0,s3,80003dce <dirlink+0x60>
    if(de.inum == 0)
    80003db0:	fb045783          	lhu	a5,-80(s0)
    80003db4:	c39d                	beqz	a5,80003dda <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003db6:	24c1                	addiw	s1,s1,16
    80003db8:	04c92783          	lw	a5,76(s2)
    80003dbc:	fef4e1e3          	bltu	s1,a5,80003d9e <dirlink+0x30>
    80003dc0:	79a2                	ld	s3,40(sp)
    80003dc2:	7a02                	ld	s4,32(sp)
    80003dc4:	a829                	j	80003dde <dirlink+0x70>
    iput(ip);
    80003dc6:	ae5ff0ef          	jal	800038aa <iput>
    return -1;
    80003dca:	557d                	li	a0,-1
    80003dcc:	a83d                	j	80003e0a <dirlink+0x9c>
      panic("dirlink read");
    80003dce:	00004517          	auipc	a0,0x4
    80003dd2:	89250513          	addi	a0,a0,-1902 # 80007660 <etext+0x660>
    80003dd6:	9c9fc0ef          	jal	8000079e <panic>
    80003dda:	79a2                	ld	s3,40(sp)
    80003ddc:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003dde:	4639                	li	a2,14
    80003de0:	85d6                	mv	a1,s5
    80003de2:	fb240513          	addi	a0,s0,-78
    80003de6:	ffbfc0ef          	jal	80000de0 <strncpy>
  de.inum = inum;
    80003dea:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dee:	4741                	li	a4,16
    80003df0:	86a6                	mv	a3,s1
    80003df2:	fb040613          	addi	a2,s0,-80
    80003df6:	4581                	li	a1,0
    80003df8:	854a                	mv	a0,s2
    80003dfa:	c79ff0ef          	jal	80003a72 <writei>
    80003dfe:	1541                	addi	a0,a0,-16
    80003e00:	00a03533          	snez	a0,a0
    80003e04:	40a0053b          	negw	a0,a0
    80003e08:	74e2                	ld	s1,56(sp)
}
    80003e0a:	60a6                	ld	ra,72(sp)
    80003e0c:	6406                	ld	s0,64(sp)
    80003e0e:	7942                	ld	s2,48(sp)
    80003e10:	6ae2                	ld	s5,24(sp)
    80003e12:	6b42                	ld	s6,16(sp)
    80003e14:	6161                	addi	sp,sp,80
    80003e16:	8082                	ret

0000000080003e18 <namei>:

struct inode*
namei(char *path)
{
    80003e18:	1101                	addi	sp,sp,-32
    80003e1a:	ec06                	sd	ra,24(sp)
    80003e1c:	e822                	sd	s0,16(sp)
    80003e1e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e20:	fe040613          	addi	a2,s0,-32
    80003e24:	4581                	li	a1,0
    80003e26:	e13ff0ef          	jal	80003c38 <namex>
}
    80003e2a:	60e2                	ld	ra,24(sp)
    80003e2c:	6442                	ld	s0,16(sp)
    80003e2e:	6105                	addi	sp,sp,32
    80003e30:	8082                	ret

0000000080003e32 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e32:	1141                	addi	sp,sp,-16
    80003e34:	e406                	sd	ra,8(sp)
    80003e36:	e022                	sd	s0,0(sp)
    80003e38:	0800                	addi	s0,sp,16
    80003e3a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e3c:	4585                	li	a1,1
    80003e3e:	dfbff0ef          	jal	80003c38 <namex>
}
    80003e42:	60a2                	ld	ra,8(sp)
    80003e44:	6402                	ld	s0,0(sp)
    80003e46:	0141                	addi	sp,sp,16
    80003e48:	8082                	ret

0000000080003e4a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e4a:	1101                	addi	sp,sp,-32
    80003e4c:	ec06                	sd	ra,24(sp)
    80003e4e:	e822                	sd	s0,16(sp)
    80003e50:	e426                	sd	s1,8(sp)
    80003e52:	e04a                	sd	s2,0(sp)
    80003e54:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e56:	00026917          	auipc	s2,0x26
    80003e5a:	99a90913          	addi	s2,s2,-1638 # 800297f0 <log>
    80003e5e:	01892583          	lw	a1,24(s2)
    80003e62:	02892503          	lw	a0,40(s2)
    80003e66:	9b0ff0ef          	jal	80003016 <bread>
    80003e6a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e6c:	02c92603          	lw	a2,44(s2)
    80003e70:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e72:	00c05f63          	blez	a2,80003e90 <write_head+0x46>
    80003e76:	00026717          	auipc	a4,0x26
    80003e7a:	9aa70713          	addi	a4,a4,-1622 # 80029820 <log+0x30>
    80003e7e:	87aa                	mv	a5,a0
    80003e80:	060a                	slli	a2,a2,0x2
    80003e82:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003e84:	4314                	lw	a3,0(a4)
    80003e86:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e88:	0711                	addi	a4,a4,4
    80003e8a:	0791                	addi	a5,a5,4
    80003e8c:	fec79ce3          	bne	a5,a2,80003e84 <write_head+0x3a>
  }
  bwrite(buf);
    80003e90:	8526                	mv	a0,s1
    80003e92:	a5aff0ef          	jal	800030ec <bwrite>
  brelse(buf);
    80003e96:	8526                	mv	a0,s1
    80003e98:	a86ff0ef          	jal	8000311e <brelse>
}
    80003e9c:	60e2                	ld	ra,24(sp)
    80003e9e:	6442                	ld	s0,16(sp)
    80003ea0:	64a2                	ld	s1,8(sp)
    80003ea2:	6902                	ld	s2,0(sp)
    80003ea4:	6105                	addi	sp,sp,32
    80003ea6:	8082                	ret

0000000080003ea8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ea8:	00026797          	auipc	a5,0x26
    80003eac:	9747a783          	lw	a5,-1676(a5) # 8002981c <log+0x2c>
    80003eb0:	0af05263          	blez	a5,80003f54 <install_trans+0xac>
{
    80003eb4:	715d                	addi	sp,sp,-80
    80003eb6:	e486                	sd	ra,72(sp)
    80003eb8:	e0a2                	sd	s0,64(sp)
    80003eba:	fc26                	sd	s1,56(sp)
    80003ebc:	f84a                	sd	s2,48(sp)
    80003ebe:	f44e                	sd	s3,40(sp)
    80003ec0:	f052                	sd	s4,32(sp)
    80003ec2:	ec56                	sd	s5,24(sp)
    80003ec4:	e85a                	sd	s6,16(sp)
    80003ec6:	e45e                	sd	s7,8(sp)
    80003ec8:	0880                	addi	s0,sp,80
    80003eca:	8b2a                	mv	s6,a0
    80003ecc:	00026a97          	auipc	s5,0x26
    80003ed0:	954a8a93          	addi	s5,s5,-1708 # 80029820 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ed4:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ed6:	00026997          	auipc	s3,0x26
    80003eda:	91a98993          	addi	s3,s3,-1766 # 800297f0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ede:	40000b93          	li	s7,1024
    80003ee2:	a829                	j	80003efc <install_trans+0x54>
    brelse(lbuf);
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	a38ff0ef          	jal	8000311e <brelse>
    brelse(dbuf);
    80003eea:	8526                	mv	a0,s1
    80003eec:	a32ff0ef          	jal	8000311e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ef0:	2a05                	addiw	s4,s4,1
    80003ef2:	0a91                	addi	s5,s5,4
    80003ef4:	02c9a783          	lw	a5,44(s3)
    80003ef8:	04fa5363          	bge	s4,a5,80003f3e <install_trans+0x96>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003efc:	0189a583          	lw	a1,24(s3)
    80003f00:	014585bb          	addw	a1,a1,s4
    80003f04:	2585                	addiw	a1,a1,1
    80003f06:	0289a503          	lw	a0,40(s3)
    80003f0a:	90cff0ef          	jal	80003016 <bread>
    80003f0e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f10:	000aa583          	lw	a1,0(s5)
    80003f14:	0289a503          	lw	a0,40(s3)
    80003f18:	8feff0ef          	jal	80003016 <bread>
    80003f1c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f1e:	865e                	mv	a2,s7
    80003f20:	05890593          	addi	a1,s2,88
    80003f24:	05850513          	addi	a0,a0,88
    80003f28:	e0bfc0ef          	jal	80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	9beff0ef          	jal	800030ec <bwrite>
    if(recovering == 0)
    80003f32:	fa0b19e3          	bnez	s6,80003ee4 <install_trans+0x3c>
      bunpin(dbuf);
    80003f36:	8526                	mv	a0,s1
    80003f38:	a9eff0ef          	jal	800031d6 <bunpin>
    80003f3c:	b765                	j	80003ee4 <install_trans+0x3c>
}
    80003f3e:	60a6                	ld	ra,72(sp)
    80003f40:	6406                	ld	s0,64(sp)
    80003f42:	74e2                	ld	s1,56(sp)
    80003f44:	7942                	ld	s2,48(sp)
    80003f46:	79a2                	ld	s3,40(sp)
    80003f48:	7a02                	ld	s4,32(sp)
    80003f4a:	6ae2                	ld	s5,24(sp)
    80003f4c:	6b42                	ld	s6,16(sp)
    80003f4e:	6ba2                	ld	s7,8(sp)
    80003f50:	6161                	addi	sp,sp,80
    80003f52:	8082                	ret
    80003f54:	8082                	ret

0000000080003f56 <initlog>:
{
    80003f56:	7179                	addi	sp,sp,-48
    80003f58:	f406                	sd	ra,40(sp)
    80003f5a:	f022                	sd	s0,32(sp)
    80003f5c:	ec26                	sd	s1,24(sp)
    80003f5e:	e84a                	sd	s2,16(sp)
    80003f60:	e44e                	sd	s3,8(sp)
    80003f62:	1800                	addi	s0,sp,48
    80003f64:	892a                	mv	s2,a0
    80003f66:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f68:	00026497          	auipc	s1,0x26
    80003f6c:	88848493          	addi	s1,s1,-1912 # 800297f0 <log>
    80003f70:	00003597          	auipc	a1,0x3
    80003f74:	70058593          	addi	a1,a1,1792 # 80007670 <etext+0x670>
    80003f78:	8526                	mv	a0,s1
    80003f7a:	c01fc0ef          	jal	80000b7a <initlock>
  log.start = sb->logstart;
    80003f7e:	0149a583          	lw	a1,20(s3)
    80003f82:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f84:	0109a783          	lw	a5,16(s3)
    80003f88:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f8a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f8e:	854a                	mv	a0,s2
    80003f90:	886ff0ef          	jal	80003016 <bread>
  log.lh.n = lh->n;
    80003f94:	4d30                	lw	a2,88(a0)
    80003f96:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f98:	00c05f63          	blez	a2,80003fb6 <initlog+0x60>
    80003f9c:	87aa                	mv	a5,a0
    80003f9e:	00026717          	auipc	a4,0x26
    80003fa2:	88270713          	addi	a4,a4,-1918 # 80029820 <log+0x30>
    80003fa6:	060a                	slli	a2,a2,0x2
    80003fa8:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003faa:	4ff4                	lw	a3,92(a5)
    80003fac:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fae:	0791                	addi	a5,a5,4
    80003fb0:	0711                	addi	a4,a4,4
    80003fb2:	fec79ce3          	bne	a5,a2,80003faa <initlog+0x54>
  brelse(buf);
    80003fb6:	968ff0ef          	jal	8000311e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003fba:	4505                	li	a0,1
    80003fbc:	eedff0ef          	jal	80003ea8 <install_trans>
  log.lh.n = 0;
    80003fc0:	00026797          	auipc	a5,0x26
    80003fc4:	8407ae23          	sw	zero,-1956(a5) # 8002981c <log+0x2c>
  write_head(); // clear the log
    80003fc8:	e83ff0ef          	jal	80003e4a <write_head>
}
    80003fcc:	70a2                	ld	ra,40(sp)
    80003fce:	7402                	ld	s0,32(sp)
    80003fd0:	64e2                	ld	s1,24(sp)
    80003fd2:	6942                	ld	s2,16(sp)
    80003fd4:	69a2                	ld	s3,8(sp)
    80003fd6:	6145                	addi	sp,sp,48
    80003fd8:	8082                	ret

0000000080003fda <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003fda:	1101                	addi	sp,sp,-32
    80003fdc:	ec06                	sd	ra,24(sp)
    80003fde:	e822                	sd	s0,16(sp)
    80003fe0:	e426                	sd	s1,8(sp)
    80003fe2:	e04a                	sd	s2,0(sp)
    80003fe4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003fe6:	00026517          	auipc	a0,0x26
    80003fea:	80a50513          	addi	a0,a0,-2038 # 800297f0 <log>
    80003fee:	c11fc0ef          	jal	80000bfe <acquire>
  while(1){
    if(log.committing){
    80003ff2:	00025497          	auipc	s1,0x25
    80003ff6:	7fe48493          	addi	s1,s1,2046 # 800297f0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003ffa:	4979                	li	s2,30
    80003ffc:	a029                	j	80004006 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003ffe:	85a6                	mv	a1,s1
    80004000:	8526                	mv	a0,s1
    80004002:	a18fe0ef          	jal	8000221a <sleep>
    if(log.committing){
    80004006:	50dc                	lw	a5,36(s1)
    80004008:	fbfd                	bnez	a5,80003ffe <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000400a:	5098                	lw	a4,32(s1)
    8000400c:	2705                	addiw	a4,a4,1
    8000400e:	0027179b          	slliw	a5,a4,0x2
    80004012:	9fb9                	addw	a5,a5,a4
    80004014:	0017979b          	slliw	a5,a5,0x1
    80004018:	54d4                	lw	a3,44(s1)
    8000401a:	9fb5                	addw	a5,a5,a3
    8000401c:	00f95763          	bge	s2,a5,8000402a <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004020:	85a6                	mv	a1,s1
    80004022:	8526                	mv	a0,s1
    80004024:	9f6fe0ef          	jal	8000221a <sleep>
    80004028:	bff9                	j	80004006 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000402a:	00025517          	auipc	a0,0x25
    8000402e:	7c650513          	addi	a0,a0,1990 # 800297f0 <log>
    80004032:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004034:	c5ffc0ef          	jal	80000c92 <release>
      break;
    }
  }
}
    80004038:	60e2                	ld	ra,24(sp)
    8000403a:	6442                	ld	s0,16(sp)
    8000403c:	64a2                	ld	s1,8(sp)
    8000403e:	6902                	ld	s2,0(sp)
    80004040:	6105                	addi	sp,sp,32
    80004042:	8082                	ret

0000000080004044 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004044:	7139                	addi	sp,sp,-64
    80004046:	fc06                	sd	ra,56(sp)
    80004048:	f822                	sd	s0,48(sp)
    8000404a:	f426                	sd	s1,40(sp)
    8000404c:	f04a                	sd	s2,32(sp)
    8000404e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004050:	00025497          	auipc	s1,0x25
    80004054:	7a048493          	addi	s1,s1,1952 # 800297f0 <log>
    80004058:	8526                	mv	a0,s1
    8000405a:	ba5fc0ef          	jal	80000bfe <acquire>
  log.outstanding -= 1;
    8000405e:	509c                	lw	a5,32(s1)
    80004060:	37fd                	addiw	a5,a5,-1
    80004062:	893e                	mv	s2,a5
    80004064:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004066:	50dc                	lw	a5,36(s1)
    80004068:	ef9d                	bnez	a5,800040a6 <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    8000406a:	04091863          	bnez	s2,800040ba <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000406e:	00025497          	auipc	s1,0x25
    80004072:	78248493          	addi	s1,s1,1922 # 800297f0 <log>
    80004076:	4785                	li	a5,1
    80004078:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000407a:	8526                	mv	a0,s1
    8000407c:	c17fc0ef          	jal	80000c92 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004080:	54dc                	lw	a5,44(s1)
    80004082:	04f04c63          	bgtz	a5,800040da <end_op+0x96>
    acquire(&log.lock);
    80004086:	00025497          	auipc	s1,0x25
    8000408a:	76a48493          	addi	s1,s1,1898 # 800297f0 <log>
    8000408e:	8526                	mv	a0,s1
    80004090:	b6ffc0ef          	jal	80000bfe <acquire>
    log.committing = 0;
    80004094:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004098:	8526                	mv	a0,s1
    8000409a:	9ccfe0ef          	jal	80002266 <wakeup>
    release(&log.lock);
    8000409e:	8526                	mv	a0,s1
    800040a0:	bf3fc0ef          	jal	80000c92 <release>
}
    800040a4:	a02d                	j	800040ce <end_op+0x8a>
    800040a6:	ec4e                	sd	s3,24(sp)
    800040a8:	e852                	sd	s4,16(sp)
    800040aa:	e456                	sd	s5,8(sp)
    800040ac:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    800040ae:	00003517          	auipc	a0,0x3
    800040b2:	5ca50513          	addi	a0,a0,1482 # 80007678 <etext+0x678>
    800040b6:	ee8fc0ef          	jal	8000079e <panic>
    wakeup(&log);
    800040ba:	00025497          	auipc	s1,0x25
    800040be:	73648493          	addi	s1,s1,1846 # 800297f0 <log>
    800040c2:	8526                	mv	a0,s1
    800040c4:	9a2fe0ef          	jal	80002266 <wakeup>
  release(&log.lock);
    800040c8:	8526                	mv	a0,s1
    800040ca:	bc9fc0ef          	jal	80000c92 <release>
}
    800040ce:	70e2                	ld	ra,56(sp)
    800040d0:	7442                	ld	s0,48(sp)
    800040d2:	74a2                	ld	s1,40(sp)
    800040d4:	7902                	ld	s2,32(sp)
    800040d6:	6121                	addi	sp,sp,64
    800040d8:	8082                	ret
    800040da:	ec4e                	sd	s3,24(sp)
    800040dc:	e852                	sd	s4,16(sp)
    800040de:	e456                	sd	s5,8(sp)
    800040e0:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800040e2:	00025a97          	auipc	s5,0x25
    800040e6:	73ea8a93          	addi	s5,s5,1854 # 80029820 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800040ea:	00025a17          	auipc	s4,0x25
    800040ee:	706a0a13          	addi	s4,s4,1798 # 800297f0 <log>
    memmove(to->data, from->data, BSIZE);
    800040f2:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800040f6:	018a2583          	lw	a1,24(s4)
    800040fa:	012585bb          	addw	a1,a1,s2
    800040fe:	2585                	addiw	a1,a1,1
    80004100:	028a2503          	lw	a0,40(s4)
    80004104:	f13fe0ef          	jal	80003016 <bread>
    80004108:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000410a:	000aa583          	lw	a1,0(s5)
    8000410e:	028a2503          	lw	a0,40(s4)
    80004112:	f05fe0ef          	jal	80003016 <bread>
    80004116:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004118:	865a                	mv	a2,s6
    8000411a:	05850593          	addi	a1,a0,88
    8000411e:	05848513          	addi	a0,s1,88
    80004122:	c11fc0ef          	jal	80000d32 <memmove>
    bwrite(to);  // write the log
    80004126:	8526                	mv	a0,s1
    80004128:	fc5fe0ef          	jal	800030ec <bwrite>
    brelse(from);
    8000412c:	854e                	mv	a0,s3
    8000412e:	ff1fe0ef          	jal	8000311e <brelse>
    brelse(to);
    80004132:	8526                	mv	a0,s1
    80004134:	febfe0ef          	jal	8000311e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004138:	2905                	addiw	s2,s2,1
    8000413a:	0a91                	addi	s5,s5,4
    8000413c:	02ca2783          	lw	a5,44(s4)
    80004140:	faf94be3          	blt	s2,a5,800040f6 <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004144:	d07ff0ef          	jal	80003e4a <write_head>
    install_trans(0); // Now install writes to home locations
    80004148:	4501                	li	a0,0
    8000414a:	d5fff0ef          	jal	80003ea8 <install_trans>
    log.lh.n = 0;
    8000414e:	00025797          	auipc	a5,0x25
    80004152:	6c07a723          	sw	zero,1742(a5) # 8002981c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004156:	cf5ff0ef          	jal	80003e4a <write_head>
    8000415a:	69e2                	ld	s3,24(sp)
    8000415c:	6a42                	ld	s4,16(sp)
    8000415e:	6aa2                	ld	s5,8(sp)
    80004160:	6b02                	ld	s6,0(sp)
    80004162:	b715                	j	80004086 <end_op+0x42>

0000000080004164 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004164:	1101                	addi	sp,sp,-32
    80004166:	ec06                	sd	ra,24(sp)
    80004168:	e822                	sd	s0,16(sp)
    8000416a:	e426                	sd	s1,8(sp)
    8000416c:	e04a                	sd	s2,0(sp)
    8000416e:	1000                	addi	s0,sp,32
    80004170:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004172:	00025917          	auipc	s2,0x25
    80004176:	67e90913          	addi	s2,s2,1662 # 800297f0 <log>
    8000417a:	854a                	mv	a0,s2
    8000417c:	a83fc0ef          	jal	80000bfe <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004180:	02c92603          	lw	a2,44(s2)
    80004184:	47f5                	li	a5,29
    80004186:	06c7c363          	blt	a5,a2,800041ec <log_write+0x88>
    8000418a:	00025797          	auipc	a5,0x25
    8000418e:	6827a783          	lw	a5,1666(a5) # 8002980c <log+0x1c>
    80004192:	37fd                	addiw	a5,a5,-1
    80004194:	04f65c63          	bge	a2,a5,800041ec <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004198:	00025797          	auipc	a5,0x25
    8000419c:	6787a783          	lw	a5,1656(a5) # 80029810 <log+0x20>
    800041a0:	04f05c63          	blez	a5,800041f8 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800041a4:	4781                	li	a5,0
    800041a6:	04c05f63          	blez	a2,80004204 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800041aa:	44cc                	lw	a1,12(s1)
    800041ac:	00025717          	auipc	a4,0x25
    800041b0:	67470713          	addi	a4,a4,1652 # 80029820 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800041b4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800041b6:	4314                	lw	a3,0(a4)
    800041b8:	04b68663          	beq	a3,a1,80004204 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    800041bc:	2785                	addiw	a5,a5,1
    800041be:	0711                	addi	a4,a4,4
    800041c0:	fef61be3          	bne	a2,a5,800041b6 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    800041c4:	0621                	addi	a2,a2,8
    800041c6:	060a                	slli	a2,a2,0x2
    800041c8:	00025797          	auipc	a5,0x25
    800041cc:	62878793          	addi	a5,a5,1576 # 800297f0 <log>
    800041d0:	97b2                	add	a5,a5,a2
    800041d2:	44d8                	lw	a4,12(s1)
    800041d4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800041d6:	8526                	mv	a0,s1
    800041d8:	fcbfe0ef          	jal	800031a2 <bpin>
    log.lh.n++;
    800041dc:	00025717          	auipc	a4,0x25
    800041e0:	61470713          	addi	a4,a4,1556 # 800297f0 <log>
    800041e4:	575c                	lw	a5,44(a4)
    800041e6:	2785                	addiw	a5,a5,1
    800041e8:	d75c                	sw	a5,44(a4)
    800041ea:	a80d                	j	8000421c <log_write+0xb8>
    panic("too big a transaction");
    800041ec:	00003517          	auipc	a0,0x3
    800041f0:	49c50513          	addi	a0,a0,1180 # 80007688 <etext+0x688>
    800041f4:	daafc0ef          	jal	8000079e <panic>
    panic("log_write outside of trans");
    800041f8:	00003517          	auipc	a0,0x3
    800041fc:	4a850513          	addi	a0,a0,1192 # 800076a0 <etext+0x6a0>
    80004200:	d9efc0ef          	jal	8000079e <panic>
  log.lh.block[i] = b->blockno;
    80004204:	00878693          	addi	a3,a5,8
    80004208:	068a                	slli	a3,a3,0x2
    8000420a:	00025717          	auipc	a4,0x25
    8000420e:	5e670713          	addi	a4,a4,1510 # 800297f0 <log>
    80004212:	9736                	add	a4,a4,a3
    80004214:	44d4                	lw	a3,12(s1)
    80004216:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004218:	faf60fe3          	beq	a2,a5,800041d6 <log_write+0x72>
  }
  release(&log.lock);
    8000421c:	00025517          	auipc	a0,0x25
    80004220:	5d450513          	addi	a0,a0,1492 # 800297f0 <log>
    80004224:	a6ffc0ef          	jal	80000c92 <release>
}
    80004228:	60e2                	ld	ra,24(sp)
    8000422a:	6442                	ld	s0,16(sp)
    8000422c:	64a2                	ld	s1,8(sp)
    8000422e:	6902                	ld	s2,0(sp)
    80004230:	6105                	addi	sp,sp,32
    80004232:	8082                	ret

0000000080004234 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004234:	1101                	addi	sp,sp,-32
    80004236:	ec06                	sd	ra,24(sp)
    80004238:	e822                	sd	s0,16(sp)
    8000423a:	e426                	sd	s1,8(sp)
    8000423c:	e04a                	sd	s2,0(sp)
    8000423e:	1000                	addi	s0,sp,32
    80004240:	84aa                	mv	s1,a0
    80004242:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004244:	00003597          	auipc	a1,0x3
    80004248:	47c58593          	addi	a1,a1,1148 # 800076c0 <etext+0x6c0>
    8000424c:	0521                	addi	a0,a0,8
    8000424e:	92dfc0ef          	jal	80000b7a <initlock>
  lk->name = name;
    80004252:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004256:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000425a:	0204a423          	sw	zero,40(s1)
}
    8000425e:	60e2                	ld	ra,24(sp)
    80004260:	6442                	ld	s0,16(sp)
    80004262:	64a2                	ld	s1,8(sp)
    80004264:	6902                	ld	s2,0(sp)
    80004266:	6105                	addi	sp,sp,32
    80004268:	8082                	ret

000000008000426a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000426a:	1101                	addi	sp,sp,-32
    8000426c:	ec06                	sd	ra,24(sp)
    8000426e:	e822                	sd	s0,16(sp)
    80004270:	e426                	sd	s1,8(sp)
    80004272:	e04a                	sd	s2,0(sp)
    80004274:	1000                	addi	s0,sp,32
    80004276:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004278:	00850913          	addi	s2,a0,8
    8000427c:	854a                	mv	a0,s2
    8000427e:	981fc0ef          	jal	80000bfe <acquire>
  while (lk->locked) {
    80004282:	409c                	lw	a5,0(s1)
    80004284:	c799                	beqz	a5,80004292 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004286:	85ca                	mv	a1,s2
    80004288:	8526                	mv	a0,s1
    8000428a:	f91fd0ef          	jal	8000221a <sleep>
  while (lk->locked) {
    8000428e:	409c                	lw	a5,0(s1)
    80004290:	fbfd                	bnez	a5,80004286 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004292:	4785                	li	a5,1
    80004294:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004296:	e46fd0ef          	jal	800018dc <myproc>
    8000429a:	591c                	lw	a5,48(a0)
    8000429c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000429e:	854a                	mv	a0,s2
    800042a0:	9f3fc0ef          	jal	80000c92 <release>
}
    800042a4:	60e2                	ld	ra,24(sp)
    800042a6:	6442                	ld	s0,16(sp)
    800042a8:	64a2                	ld	s1,8(sp)
    800042aa:	6902                	ld	s2,0(sp)
    800042ac:	6105                	addi	sp,sp,32
    800042ae:	8082                	ret

00000000800042b0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800042b0:	1101                	addi	sp,sp,-32
    800042b2:	ec06                	sd	ra,24(sp)
    800042b4:	e822                	sd	s0,16(sp)
    800042b6:	e426                	sd	s1,8(sp)
    800042b8:	e04a                	sd	s2,0(sp)
    800042ba:	1000                	addi	s0,sp,32
    800042bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042be:	00850913          	addi	s2,a0,8
    800042c2:	854a                	mv	a0,s2
    800042c4:	93bfc0ef          	jal	80000bfe <acquire>
  lk->locked = 0;
    800042c8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042cc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800042d0:	8526                	mv	a0,s1
    800042d2:	f95fd0ef          	jal	80002266 <wakeup>
  release(&lk->lk);
    800042d6:	854a                	mv	a0,s2
    800042d8:	9bbfc0ef          	jal	80000c92 <release>
}
    800042dc:	60e2                	ld	ra,24(sp)
    800042de:	6442                	ld	s0,16(sp)
    800042e0:	64a2                	ld	s1,8(sp)
    800042e2:	6902                	ld	s2,0(sp)
    800042e4:	6105                	addi	sp,sp,32
    800042e6:	8082                	ret

00000000800042e8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800042e8:	7179                	addi	sp,sp,-48
    800042ea:	f406                	sd	ra,40(sp)
    800042ec:	f022                	sd	s0,32(sp)
    800042ee:	ec26                	sd	s1,24(sp)
    800042f0:	e84a                	sd	s2,16(sp)
    800042f2:	1800                	addi	s0,sp,48
    800042f4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800042f6:	00850913          	addi	s2,a0,8
    800042fa:	854a                	mv	a0,s2
    800042fc:	903fc0ef          	jal	80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004300:	409c                	lw	a5,0(s1)
    80004302:	ef81                	bnez	a5,8000431a <holdingsleep+0x32>
    80004304:	4481                	li	s1,0
  release(&lk->lk);
    80004306:	854a                	mv	a0,s2
    80004308:	98bfc0ef          	jal	80000c92 <release>
  return r;
}
    8000430c:	8526                	mv	a0,s1
    8000430e:	70a2                	ld	ra,40(sp)
    80004310:	7402                	ld	s0,32(sp)
    80004312:	64e2                	ld	s1,24(sp)
    80004314:	6942                	ld	s2,16(sp)
    80004316:	6145                	addi	sp,sp,48
    80004318:	8082                	ret
    8000431a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000431c:	0284a983          	lw	s3,40(s1)
    80004320:	dbcfd0ef          	jal	800018dc <myproc>
    80004324:	5904                	lw	s1,48(a0)
    80004326:	413484b3          	sub	s1,s1,s3
    8000432a:	0014b493          	seqz	s1,s1
    8000432e:	69a2                	ld	s3,8(sp)
    80004330:	bfd9                	j	80004306 <holdingsleep+0x1e>

0000000080004332 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004332:	1141                	addi	sp,sp,-16
    80004334:	e406                	sd	ra,8(sp)
    80004336:	e022                	sd	s0,0(sp)
    80004338:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000433a:	00003597          	auipc	a1,0x3
    8000433e:	39658593          	addi	a1,a1,918 # 800076d0 <etext+0x6d0>
    80004342:	00025517          	auipc	a0,0x25
    80004346:	5f650513          	addi	a0,a0,1526 # 80029938 <ftable>
    8000434a:	831fc0ef          	jal	80000b7a <initlock>
}
    8000434e:	60a2                	ld	ra,8(sp)
    80004350:	6402                	ld	s0,0(sp)
    80004352:	0141                	addi	sp,sp,16
    80004354:	8082                	ret

0000000080004356 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004356:	1101                	addi	sp,sp,-32
    80004358:	ec06                	sd	ra,24(sp)
    8000435a:	e822                	sd	s0,16(sp)
    8000435c:	e426                	sd	s1,8(sp)
    8000435e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004360:	00025517          	auipc	a0,0x25
    80004364:	5d850513          	addi	a0,a0,1496 # 80029938 <ftable>
    80004368:	897fc0ef          	jal	80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000436c:	00025497          	auipc	s1,0x25
    80004370:	5e448493          	addi	s1,s1,1508 # 80029950 <ftable+0x18>
    80004374:	00026717          	auipc	a4,0x26
    80004378:	57c70713          	addi	a4,a4,1404 # 8002a8f0 <disk>
    if(f->ref == 0){
    8000437c:	40dc                	lw	a5,4(s1)
    8000437e:	cf89                	beqz	a5,80004398 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004380:	02848493          	addi	s1,s1,40
    80004384:	fee49ce3          	bne	s1,a4,8000437c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004388:	00025517          	auipc	a0,0x25
    8000438c:	5b050513          	addi	a0,a0,1456 # 80029938 <ftable>
    80004390:	903fc0ef          	jal	80000c92 <release>
  return 0;
    80004394:	4481                	li	s1,0
    80004396:	a809                	j	800043a8 <filealloc+0x52>
      f->ref = 1;
    80004398:	4785                	li	a5,1
    8000439a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000439c:	00025517          	auipc	a0,0x25
    800043a0:	59c50513          	addi	a0,a0,1436 # 80029938 <ftable>
    800043a4:	8effc0ef          	jal	80000c92 <release>
}
    800043a8:	8526                	mv	a0,s1
    800043aa:	60e2                	ld	ra,24(sp)
    800043ac:	6442                	ld	s0,16(sp)
    800043ae:	64a2                	ld	s1,8(sp)
    800043b0:	6105                	addi	sp,sp,32
    800043b2:	8082                	ret

00000000800043b4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800043b4:	1101                	addi	sp,sp,-32
    800043b6:	ec06                	sd	ra,24(sp)
    800043b8:	e822                	sd	s0,16(sp)
    800043ba:	e426                	sd	s1,8(sp)
    800043bc:	1000                	addi	s0,sp,32
    800043be:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800043c0:	00025517          	auipc	a0,0x25
    800043c4:	57850513          	addi	a0,a0,1400 # 80029938 <ftable>
    800043c8:	837fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    800043cc:	40dc                	lw	a5,4(s1)
    800043ce:	02f05063          	blez	a5,800043ee <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800043d2:	2785                	addiw	a5,a5,1
    800043d4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800043d6:	00025517          	auipc	a0,0x25
    800043da:	56250513          	addi	a0,a0,1378 # 80029938 <ftable>
    800043de:	8b5fc0ef          	jal	80000c92 <release>
  return f;
}
    800043e2:	8526                	mv	a0,s1
    800043e4:	60e2                	ld	ra,24(sp)
    800043e6:	6442                	ld	s0,16(sp)
    800043e8:	64a2                	ld	s1,8(sp)
    800043ea:	6105                	addi	sp,sp,32
    800043ec:	8082                	ret
    panic("filedup");
    800043ee:	00003517          	auipc	a0,0x3
    800043f2:	2ea50513          	addi	a0,a0,746 # 800076d8 <etext+0x6d8>
    800043f6:	ba8fc0ef          	jal	8000079e <panic>

00000000800043fa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800043fa:	7139                	addi	sp,sp,-64
    800043fc:	fc06                	sd	ra,56(sp)
    800043fe:	f822                	sd	s0,48(sp)
    80004400:	f426                	sd	s1,40(sp)
    80004402:	0080                	addi	s0,sp,64
    80004404:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004406:	00025517          	auipc	a0,0x25
    8000440a:	53250513          	addi	a0,a0,1330 # 80029938 <ftable>
    8000440e:	ff0fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80004412:	40dc                	lw	a5,4(s1)
    80004414:	04f05863          	blez	a5,80004464 <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    80004418:	37fd                	addiw	a5,a5,-1
    8000441a:	c0dc                	sw	a5,4(s1)
    8000441c:	04f04e63          	bgtz	a5,80004478 <fileclose+0x7e>
    80004420:	f04a                	sd	s2,32(sp)
    80004422:	ec4e                	sd	s3,24(sp)
    80004424:	e852                	sd	s4,16(sp)
    80004426:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004428:	0004a903          	lw	s2,0(s1)
    8000442c:	0094ca83          	lbu	s5,9(s1)
    80004430:	0104ba03          	ld	s4,16(s1)
    80004434:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004438:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000443c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004440:	00025517          	auipc	a0,0x25
    80004444:	4f850513          	addi	a0,a0,1272 # 80029938 <ftable>
    80004448:	84bfc0ef          	jal	80000c92 <release>

  if(ff.type == FD_PIPE){
    8000444c:	4785                	li	a5,1
    8000444e:	04f90063          	beq	s2,a5,8000448e <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004452:	3979                	addiw	s2,s2,-2
    80004454:	4785                	li	a5,1
    80004456:	0527f563          	bgeu	a5,s2,800044a0 <fileclose+0xa6>
    8000445a:	7902                	ld	s2,32(sp)
    8000445c:	69e2                	ld	s3,24(sp)
    8000445e:	6a42                	ld	s4,16(sp)
    80004460:	6aa2                	ld	s5,8(sp)
    80004462:	a00d                	j	80004484 <fileclose+0x8a>
    80004464:	f04a                	sd	s2,32(sp)
    80004466:	ec4e                	sd	s3,24(sp)
    80004468:	e852                	sd	s4,16(sp)
    8000446a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000446c:	00003517          	auipc	a0,0x3
    80004470:	27450513          	addi	a0,a0,628 # 800076e0 <etext+0x6e0>
    80004474:	b2afc0ef          	jal	8000079e <panic>
    release(&ftable.lock);
    80004478:	00025517          	auipc	a0,0x25
    8000447c:	4c050513          	addi	a0,a0,1216 # 80029938 <ftable>
    80004480:	813fc0ef          	jal	80000c92 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004484:	70e2                	ld	ra,56(sp)
    80004486:	7442                	ld	s0,48(sp)
    80004488:	74a2                	ld	s1,40(sp)
    8000448a:	6121                	addi	sp,sp,64
    8000448c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000448e:	85d6                	mv	a1,s5
    80004490:	8552                	mv	a0,s4
    80004492:	340000ef          	jal	800047d2 <pipeclose>
    80004496:	7902                	ld	s2,32(sp)
    80004498:	69e2                	ld	s3,24(sp)
    8000449a:	6a42                	ld	s4,16(sp)
    8000449c:	6aa2                	ld	s5,8(sp)
    8000449e:	b7dd                	j	80004484 <fileclose+0x8a>
    begin_op();
    800044a0:	b3bff0ef          	jal	80003fda <begin_op>
    iput(ff.ip);
    800044a4:	854e                	mv	a0,s3
    800044a6:	c04ff0ef          	jal	800038aa <iput>
    end_op();
    800044aa:	b9bff0ef          	jal	80004044 <end_op>
    800044ae:	7902                	ld	s2,32(sp)
    800044b0:	69e2                	ld	s3,24(sp)
    800044b2:	6a42                	ld	s4,16(sp)
    800044b4:	6aa2                	ld	s5,8(sp)
    800044b6:	b7f9                	j	80004484 <fileclose+0x8a>

00000000800044b8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800044b8:	715d                	addi	sp,sp,-80
    800044ba:	e486                	sd	ra,72(sp)
    800044bc:	e0a2                	sd	s0,64(sp)
    800044be:	fc26                	sd	s1,56(sp)
    800044c0:	f44e                	sd	s3,40(sp)
    800044c2:	0880                	addi	s0,sp,80
    800044c4:	84aa                	mv	s1,a0
    800044c6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800044c8:	c14fd0ef          	jal	800018dc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800044cc:	409c                	lw	a5,0(s1)
    800044ce:	37f9                	addiw	a5,a5,-2
    800044d0:	4705                	li	a4,1
    800044d2:	04f76263          	bltu	a4,a5,80004516 <filestat+0x5e>
    800044d6:	f84a                	sd	s2,48(sp)
    800044d8:	f052                	sd	s4,32(sp)
    800044da:	892a                	mv	s2,a0
    ilock(f->ip);
    800044dc:	6c88                	ld	a0,24(s1)
    800044de:	a4aff0ef          	jal	80003728 <ilock>
    stati(f->ip, &st);
    800044e2:	fb840a13          	addi	s4,s0,-72
    800044e6:	85d2                	mv	a1,s4
    800044e8:	6c88                	ld	a0,24(s1)
    800044ea:	c68ff0ef          	jal	80003952 <stati>
    iunlock(f->ip);
    800044ee:	6c88                	ld	a0,24(s1)
    800044f0:	ae6ff0ef          	jal	800037d6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800044f4:	46e1                	li	a3,24
    800044f6:	8652                	mv	a2,s4
    800044f8:	85ce                	mv	a1,s3
    800044fa:	05093503          	ld	a0,80(s2)
    800044fe:	886fd0ef          	jal	80001584 <copyout>
    80004502:	41f5551b          	sraiw	a0,a0,0x1f
    80004506:	7942                	ld	s2,48(sp)
    80004508:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000450a:	60a6                	ld	ra,72(sp)
    8000450c:	6406                	ld	s0,64(sp)
    8000450e:	74e2                	ld	s1,56(sp)
    80004510:	79a2                	ld	s3,40(sp)
    80004512:	6161                	addi	sp,sp,80
    80004514:	8082                	ret
  return -1;
    80004516:	557d                	li	a0,-1
    80004518:	bfcd                	j	8000450a <filestat+0x52>

000000008000451a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000451a:	7179                	addi	sp,sp,-48
    8000451c:	f406                	sd	ra,40(sp)
    8000451e:	f022                	sd	s0,32(sp)
    80004520:	e84a                	sd	s2,16(sp)
    80004522:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004524:	00854783          	lbu	a5,8(a0)
    80004528:	cfd1                	beqz	a5,800045c4 <fileread+0xaa>
    8000452a:	ec26                	sd	s1,24(sp)
    8000452c:	e44e                	sd	s3,8(sp)
    8000452e:	84aa                	mv	s1,a0
    80004530:	89ae                	mv	s3,a1
    80004532:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004534:	411c                	lw	a5,0(a0)
    80004536:	4705                	li	a4,1
    80004538:	04e78363          	beq	a5,a4,8000457e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000453c:	470d                	li	a4,3
    8000453e:	04e78763          	beq	a5,a4,8000458c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004542:	4709                	li	a4,2
    80004544:	06e79a63          	bne	a5,a4,800045b8 <fileread+0x9e>
    ilock(f->ip);
    80004548:	6d08                	ld	a0,24(a0)
    8000454a:	9deff0ef          	jal	80003728 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000454e:	874a                	mv	a4,s2
    80004550:	5094                	lw	a3,32(s1)
    80004552:	864e                	mv	a2,s3
    80004554:	4585                	li	a1,1
    80004556:	6c88                	ld	a0,24(s1)
    80004558:	c28ff0ef          	jal	80003980 <readi>
    8000455c:	892a                	mv	s2,a0
    8000455e:	00a05563          	blez	a0,80004568 <fileread+0x4e>
      f->off += r;
    80004562:	509c                	lw	a5,32(s1)
    80004564:	9fa9                	addw	a5,a5,a0
    80004566:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004568:	6c88                	ld	a0,24(s1)
    8000456a:	a6cff0ef          	jal	800037d6 <iunlock>
    8000456e:	64e2                	ld	s1,24(sp)
    80004570:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004572:	854a                	mv	a0,s2
    80004574:	70a2                	ld	ra,40(sp)
    80004576:	7402                	ld	s0,32(sp)
    80004578:	6942                	ld	s2,16(sp)
    8000457a:	6145                	addi	sp,sp,48
    8000457c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000457e:	6908                	ld	a0,16(a0)
    80004580:	3a2000ef          	jal	80004922 <piperead>
    80004584:	892a                	mv	s2,a0
    80004586:	64e2                	ld	s1,24(sp)
    80004588:	69a2                	ld	s3,8(sp)
    8000458a:	b7e5                	j	80004572 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000458c:	02451783          	lh	a5,36(a0)
    80004590:	03079693          	slli	a3,a5,0x30
    80004594:	92c1                	srli	a3,a3,0x30
    80004596:	4725                	li	a4,9
    80004598:	02d76863          	bltu	a4,a3,800045c8 <fileread+0xae>
    8000459c:	0792                	slli	a5,a5,0x4
    8000459e:	00025717          	auipc	a4,0x25
    800045a2:	2fa70713          	addi	a4,a4,762 # 80029898 <devsw>
    800045a6:	97ba                	add	a5,a5,a4
    800045a8:	639c                	ld	a5,0(a5)
    800045aa:	c39d                	beqz	a5,800045d0 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800045ac:	4505                	li	a0,1
    800045ae:	9782                	jalr	a5
    800045b0:	892a                	mv	s2,a0
    800045b2:	64e2                	ld	s1,24(sp)
    800045b4:	69a2                	ld	s3,8(sp)
    800045b6:	bf75                	j	80004572 <fileread+0x58>
    panic("fileread");
    800045b8:	00003517          	auipc	a0,0x3
    800045bc:	13850513          	addi	a0,a0,312 # 800076f0 <etext+0x6f0>
    800045c0:	9defc0ef          	jal	8000079e <panic>
    return -1;
    800045c4:	597d                	li	s2,-1
    800045c6:	b775                	j	80004572 <fileread+0x58>
      return -1;
    800045c8:	597d                	li	s2,-1
    800045ca:	64e2                	ld	s1,24(sp)
    800045cc:	69a2                	ld	s3,8(sp)
    800045ce:	b755                	j	80004572 <fileread+0x58>
    800045d0:	597d                	li	s2,-1
    800045d2:	64e2                	ld	s1,24(sp)
    800045d4:	69a2                	ld	s3,8(sp)
    800045d6:	bf71                	j	80004572 <fileread+0x58>

00000000800045d8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800045d8:	00954783          	lbu	a5,9(a0)
    800045dc:	10078e63          	beqz	a5,800046f8 <filewrite+0x120>
{
    800045e0:	711d                	addi	sp,sp,-96
    800045e2:	ec86                	sd	ra,88(sp)
    800045e4:	e8a2                	sd	s0,80(sp)
    800045e6:	e0ca                	sd	s2,64(sp)
    800045e8:	f456                	sd	s5,40(sp)
    800045ea:	f05a                	sd	s6,32(sp)
    800045ec:	1080                	addi	s0,sp,96
    800045ee:	892a                	mv	s2,a0
    800045f0:	8b2e                	mv	s6,a1
    800045f2:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800045f4:	411c                	lw	a5,0(a0)
    800045f6:	4705                	li	a4,1
    800045f8:	02e78963          	beq	a5,a4,8000462a <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045fc:	470d                	li	a4,3
    800045fe:	02e78a63          	beq	a5,a4,80004632 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004602:	4709                	li	a4,2
    80004604:	0ce79e63          	bne	a5,a4,800046e0 <filewrite+0x108>
    80004608:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000460a:	0ac05963          	blez	a2,800046bc <filewrite+0xe4>
    8000460e:	e4a6                	sd	s1,72(sp)
    80004610:	fc4e                	sd	s3,56(sp)
    80004612:	ec5e                	sd	s7,24(sp)
    80004614:	e862                	sd	s8,16(sp)
    80004616:	e466                	sd	s9,8(sp)
    int i = 0;
    80004618:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    8000461a:	6b85                	lui	s7,0x1
    8000461c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004620:	6c85                	lui	s9,0x1
    80004622:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004626:	4c05                	li	s8,1
    80004628:	a8ad                	j	800046a2 <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    8000462a:	6908                	ld	a0,16(a0)
    8000462c:	1fe000ef          	jal	8000482a <pipewrite>
    80004630:	a04d                	j	800046d2 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004632:	02451783          	lh	a5,36(a0)
    80004636:	03079693          	slli	a3,a5,0x30
    8000463a:	92c1                	srli	a3,a3,0x30
    8000463c:	4725                	li	a4,9
    8000463e:	0ad76f63          	bltu	a4,a3,800046fc <filewrite+0x124>
    80004642:	0792                	slli	a5,a5,0x4
    80004644:	00025717          	auipc	a4,0x25
    80004648:	25470713          	addi	a4,a4,596 # 80029898 <devsw>
    8000464c:	97ba                	add	a5,a5,a4
    8000464e:	679c                	ld	a5,8(a5)
    80004650:	cbc5                	beqz	a5,80004700 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004652:	4505                	li	a0,1
    80004654:	9782                	jalr	a5
    80004656:	a8b5                	j	800046d2 <filewrite+0xfa>
      if(n1 > max)
    80004658:	2981                	sext.w	s3,s3
      begin_op();
    8000465a:	981ff0ef          	jal	80003fda <begin_op>
      ilock(f->ip);
    8000465e:	01893503          	ld	a0,24(s2)
    80004662:	8c6ff0ef          	jal	80003728 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004666:	874e                	mv	a4,s3
    80004668:	02092683          	lw	a3,32(s2)
    8000466c:	016a0633          	add	a2,s4,s6
    80004670:	85e2                	mv	a1,s8
    80004672:	01893503          	ld	a0,24(s2)
    80004676:	bfcff0ef          	jal	80003a72 <writei>
    8000467a:	84aa                	mv	s1,a0
    8000467c:	00a05763          	blez	a0,8000468a <filewrite+0xb2>
        f->off += r;
    80004680:	02092783          	lw	a5,32(s2)
    80004684:	9fa9                	addw	a5,a5,a0
    80004686:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000468a:	01893503          	ld	a0,24(s2)
    8000468e:	948ff0ef          	jal	800037d6 <iunlock>
      end_op();
    80004692:	9b3ff0ef          	jal	80004044 <end_op>

      if(r != n1){
    80004696:	02999563          	bne	s3,s1,800046c0 <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    8000469a:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000469e:	015a5963          	bge	s4,s5,800046b0 <filewrite+0xd8>
      int n1 = n - i;
    800046a2:	414a87bb          	subw	a5,s5,s4
    800046a6:	89be                	mv	s3,a5
      if(n1 > max)
    800046a8:	fafbd8e3          	bge	s7,a5,80004658 <filewrite+0x80>
    800046ac:	89e6                	mv	s3,s9
    800046ae:	b76d                	j	80004658 <filewrite+0x80>
    800046b0:	64a6                	ld	s1,72(sp)
    800046b2:	79e2                	ld	s3,56(sp)
    800046b4:	6be2                	ld	s7,24(sp)
    800046b6:	6c42                	ld	s8,16(sp)
    800046b8:	6ca2                	ld	s9,8(sp)
    800046ba:	a801                	j	800046ca <filewrite+0xf2>
    int i = 0;
    800046bc:	4a01                	li	s4,0
    800046be:	a031                	j	800046ca <filewrite+0xf2>
    800046c0:	64a6                	ld	s1,72(sp)
    800046c2:	79e2                	ld	s3,56(sp)
    800046c4:	6be2                	ld	s7,24(sp)
    800046c6:	6c42                	ld	s8,16(sp)
    800046c8:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800046ca:	034a9d63          	bne	s5,s4,80004704 <filewrite+0x12c>
    800046ce:	8556                	mv	a0,s5
    800046d0:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800046d2:	60e6                	ld	ra,88(sp)
    800046d4:	6446                	ld	s0,80(sp)
    800046d6:	6906                	ld	s2,64(sp)
    800046d8:	7aa2                	ld	s5,40(sp)
    800046da:	7b02                	ld	s6,32(sp)
    800046dc:	6125                	addi	sp,sp,96
    800046de:	8082                	ret
    800046e0:	e4a6                	sd	s1,72(sp)
    800046e2:	fc4e                	sd	s3,56(sp)
    800046e4:	f852                	sd	s4,48(sp)
    800046e6:	ec5e                	sd	s7,24(sp)
    800046e8:	e862                	sd	s8,16(sp)
    800046ea:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800046ec:	00003517          	auipc	a0,0x3
    800046f0:	01450513          	addi	a0,a0,20 # 80007700 <etext+0x700>
    800046f4:	8aafc0ef          	jal	8000079e <panic>
    return -1;
    800046f8:	557d                	li	a0,-1
}
    800046fa:	8082                	ret
      return -1;
    800046fc:	557d                	li	a0,-1
    800046fe:	bfd1                	j	800046d2 <filewrite+0xfa>
    80004700:	557d                	li	a0,-1
    80004702:	bfc1                	j	800046d2 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004704:	557d                	li	a0,-1
    80004706:	7a42                	ld	s4,48(sp)
    80004708:	b7e9                	j	800046d2 <filewrite+0xfa>

000000008000470a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000470a:	7179                	addi	sp,sp,-48
    8000470c:	f406                	sd	ra,40(sp)
    8000470e:	f022                	sd	s0,32(sp)
    80004710:	ec26                	sd	s1,24(sp)
    80004712:	e052                	sd	s4,0(sp)
    80004714:	1800                	addi	s0,sp,48
    80004716:	84aa                	mv	s1,a0
    80004718:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000471a:	0005b023          	sd	zero,0(a1)
    8000471e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004722:	c35ff0ef          	jal	80004356 <filealloc>
    80004726:	e088                	sd	a0,0(s1)
    80004728:	c549                	beqz	a0,800047b2 <pipealloc+0xa8>
    8000472a:	c2dff0ef          	jal	80004356 <filealloc>
    8000472e:	00aa3023          	sd	a0,0(s4)
    80004732:	cd25                	beqz	a0,800047aa <pipealloc+0xa0>
    80004734:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004736:	bf4fc0ef          	jal	80000b2a <kalloc>
    8000473a:	892a                	mv	s2,a0
    8000473c:	c12d                	beqz	a0,8000479e <pipealloc+0x94>
    8000473e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004740:	4985                	li	s3,1
    80004742:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004746:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000474a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000474e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004752:	00003597          	auipc	a1,0x3
    80004756:	bae58593          	addi	a1,a1,-1106 # 80007300 <etext+0x300>
    8000475a:	c20fc0ef          	jal	80000b7a <initlock>
  (*f0)->type = FD_PIPE;
    8000475e:	609c                	ld	a5,0(s1)
    80004760:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004764:	609c                	ld	a5,0(s1)
    80004766:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000476a:	609c                	ld	a5,0(s1)
    8000476c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004770:	609c                	ld	a5,0(s1)
    80004772:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004776:	000a3783          	ld	a5,0(s4)
    8000477a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000477e:	000a3783          	ld	a5,0(s4)
    80004782:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004786:	000a3783          	ld	a5,0(s4)
    8000478a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000478e:	000a3783          	ld	a5,0(s4)
    80004792:	0127b823          	sd	s2,16(a5)
  return 0;
    80004796:	4501                	li	a0,0
    80004798:	6942                	ld	s2,16(sp)
    8000479a:	69a2                	ld	s3,8(sp)
    8000479c:	a01d                	j	800047c2 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000479e:	6088                	ld	a0,0(s1)
    800047a0:	c119                	beqz	a0,800047a6 <pipealloc+0x9c>
    800047a2:	6942                	ld	s2,16(sp)
    800047a4:	a029                	j	800047ae <pipealloc+0xa4>
    800047a6:	6942                	ld	s2,16(sp)
    800047a8:	a029                	j	800047b2 <pipealloc+0xa8>
    800047aa:	6088                	ld	a0,0(s1)
    800047ac:	c10d                	beqz	a0,800047ce <pipealloc+0xc4>
    fileclose(*f0);
    800047ae:	c4dff0ef          	jal	800043fa <fileclose>
  if(*f1)
    800047b2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800047b6:	557d                	li	a0,-1
  if(*f1)
    800047b8:	c789                	beqz	a5,800047c2 <pipealloc+0xb8>
    fileclose(*f1);
    800047ba:	853e                	mv	a0,a5
    800047bc:	c3fff0ef          	jal	800043fa <fileclose>
  return -1;
    800047c0:	557d                	li	a0,-1
}
    800047c2:	70a2                	ld	ra,40(sp)
    800047c4:	7402                	ld	s0,32(sp)
    800047c6:	64e2                	ld	s1,24(sp)
    800047c8:	6a02                	ld	s4,0(sp)
    800047ca:	6145                	addi	sp,sp,48
    800047cc:	8082                	ret
  return -1;
    800047ce:	557d                	li	a0,-1
    800047d0:	bfcd                	j	800047c2 <pipealloc+0xb8>

00000000800047d2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800047d2:	1101                	addi	sp,sp,-32
    800047d4:	ec06                	sd	ra,24(sp)
    800047d6:	e822                	sd	s0,16(sp)
    800047d8:	e426                	sd	s1,8(sp)
    800047da:	e04a                	sd	s2,0(sp)
    800047dc:	1000                	addi	s0,sp,32
    800047de:	84aa                	mv	s1,a0
    800047e0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800047e2:	c1cfc0ef          	jal	80000bfe <acquire>
  if(writable){
    800047e6:	02090763          	beqz	s2,80004814 <pipeclose+0x42>
    pi->writeopen = 0;
    800047ea:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800047ee:	21848513          	addi	a0,s1,536
    800047f2:	a75fd0ef          	jal	80002266 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800047f6:	2204b783          	ld	a5,544(s1)
    800047fa:	e785                	bnez	a5,80004822 <pipeclose+0x50>
    release(&pi->lock);
    800047fc:	8526                	mv	a0,s1
    800047fe:	c94fc0ef          	jal	80000c92 <release>
    kfree((char*)pi);
    80004802:	8526                	mv	a0,s1
    80004804:	a44fc0ef          	jal	80000a48 <kfree>
  } else
    release(&pi->lock);
}
    80004808:	60e2                	ld	ra,24(sp)
    8000480a:	6442                	ld	s0,16(sp)
    8000480c:	64a2                	ld	s1,8(sp)
    8000480e:	6902                	ld	s2,0(sp)
    80004810:	6105                	addi	sp,sp,32
    80004812:	8082                	ret
    pi->readopen = 0;
    80004814:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004818:	21c48513          	addi	a0,s1,540
    8000481c:	a4bfd0ef          	jal	80002266 <wakeup>
    80004820:	bfd9                	j	800047f6 <pipeclose+0x24>
    release(&pi->lock);
    80004822:	8526                	mv	a0,s1
    80004824:	c6efc0ef          	jal	80000c92 <release>
}
    80004828:	b7c5                	j	80004808 <pipeclose+0x36>

000000008000482a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000482a:	7159                	addi	sp,sp,-112
    8000482c:	f486                	sd	ra,104(sp)
    8000482e:	f0a2                	sd	s0,96(sp)
    80004830:	eca6                	sd	s1,88(sp)
    80004832:	e8ca                	sd	s2,80(sp)
    80004834:	e4ce                	sd	s3,72(sp)
    80004836:	e0d2                	sd	s4,64(sp)
    80004838:	fc56                	sd	s5,56(sp)
    8000483a:	1880                	addi	s0,sp,112
    8000483c:	84aa                	mv	s1,a0
    8000483e:	8aae                	mv	s5,a1
    80004840:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004842:	89afd0ef          	jal	800018dc <myproc>
    80004846:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004848:	8526                	mv	a0,s1
    8000484a:	bb4fc0ef          	jal	80000bfe <acquire>
  while(i < n){
    8000484e:	0d405263          	blez	s4,80004912 <pipewrite+0xe8>
    80004852:	f85a                	sd	s6,48(sp)
    80004854:	f45e                	sd	s7,40(sp)
    80004856:	f062                	sd	s8,32(sp)
    80004858:	ec66                	sd	s9,24(sp)
    8000485a:	e86a                	sd	s10,16(sp)
  int i = 0;
    8000485c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000485e:	f9f40c13          	addi	s8,s0,-97
    80004862:	4b85                	li	s7,1
    80004864:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004866:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000486a:	21c48c93          	addi	s9,s1,540
    8000486e:	a82d                	j	800048a8 <pipewrite+0x7e>
      release(&pi->lock);
    80004870:	8526                	mv	a0,s1
    80004872:	c20fc0ef          	jal	80000c92 <release>
      return -1;
    80004876:	597d                	li	s2,-1
    80004878:	7b42                	ld	s6,48(sp)
    8000487a:	7ba2                	ld	s7,40(sp)
    8000487c:	7c02                	ld	s8,32(sp)
    8000487e:	6ce2                	ld	s9,24(sp)
    80004880:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004882:	854a                	mv	a0,s2
    80004884:	70a6                	ld	ra,104(sp)
    80004886:	7406                	ld	s0,96(sp)
    80004888:	64e6                	ld	s1,88(sp)
    8000488a:	6946                	ld	s2,80(sp)
    8000488c:	69a6                	ld	s3,72(sp)
    8000488e:	6a06                	ld	s4,64(sp)
    80004890:	7ae2                	ld	s5,56(sp)
    80004892:	6165                	addi	sp,sp,112
    80004894:	8082                	ret
      wakeup(&pi->nread);
    80004896:	856a                	mv	a0,s10
    80004898:	9cffd0ef          	jal	80002266 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000489c:	85a6                	mv	a1,s1
    8000489e:	8566                	mv	a0,s9
    800048a0:	97bfd0ef          	jal	8000221a <sleep>
  while(i < n){
    800048a4:	05495a63          	bge	s2,s4,800048f8 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    800048a8:	2204a783          	lw	a5,544(s1)
    800048ac:	d3f1                	beqz	a5,80004870 <pipewrite+0x46>
    800048ae:	854e                	mv	a0,s3
    800048b0:	ba3fd0ef          	jal	80002452 <killed>
    800048b4:	fd55                	bnez	a0,80004870 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800048b6:	2184a783          	lw	a5,536(s1)
    800048ba:	21c4a703          	lw	a4,540(s1)
    800048be:	2007879b          	addiw	a5,a5,512
    800048c2:	fcf70ae3          	beq	a4,a5,80004896 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800048c6:	86de                	mv	a3,s7
    800048c8:	01590633          	add	a2,s2,s5
    800048cc:	85e2                	mv	a1,s8
    800048ce:	0509b503          	ld	a0,80(s3)
    800048d2:	d63fc0ef          	jal	80001634 <copyin>
    800048d6:	05650063          	beq	a0,s6,80004916 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800048da:	21c4a783          	lw	a5,540(s1)
    800048de:	0017871b          	addiw	a4,a5,1
    800048e2:	20e4ae23          	sw	a4,540(s1)
    800048e6:	1ff7f793          	andi	a5,a5,511
    800048ea:	97a6                	add	a5,a5,s1
    800048ec:	f9f44703          	lbu	a4,-97(s0)
    800048f0:	00e78c23          	sb	a4,24(a5)
      i++;
    800048f4:	2905                	addiw	s2,s2,1
    800048f6:	b77d                	j	800048a4 <pipewrite+0x7a>
    800048f8:	7b42                	ld	s6,48(sp)
    800048fa:	7ba2                	ld	s7,40(sp)
    800048fc:	7c02                	ld	s8,32(sp)
    800048fe:	6ce2                	ld	s9,24(sp)
    80004900:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004902:	21848513          	addi	a0,s1,536
    80004906:	961fd0ef          	jal	80002266 <wakeup>
  release(&pi->lock);
    8000490a:	8526                	mv	a0,s1
    8000490c:	b86fc0ef          	jal	80000c92 <release>
  return i;
    80004910:	bf8d                	j	80004882 <pipewrite+0x58>
  int i = 0;
    80004912:	4901                	li	s2,0
    80004914:	b7fd                	j	80004902 <pipewrite+0xd8>
    80004916:	7b42                	ld	s6,48(sp)
    80004918:	7ba2                	ld	s7,40(sp)
    8000491a:	7c02                	ld	s8,32(sp)
    8000491c:	6ce2                	ld	s9,24(sp)
    8000491e:	6d42                	ld	s10,16(sp)
    80004920:	b7cd                	j	80004902 <pipewrite+0xd8>

0000000080004922 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004922:	711d                	addi	sp,sp,-96
    80004924:	ec86                	sd	ra,88(sp)
    80004926:	e8a2                	sd	s0,80(sp)
    80004928:	e4a6                	sd	s1,72(sp)
    8000492a:	e0ca                	sd	s2,64(sp)
    8000492c:	fc4e                	sd	s3,56(sp)
    8000492e:	f852                	sd	s4,48(sp)
    80004930:	f456                	sd	s5,40(sp)
    80004932:	1080                	addi	s0,sp,96
    80004934:	84aa                	mv	s1,a0
    80004936:	892e                	mv	s2,a1
    80004938:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000493a:	fa3fc0ef          	jal	800018dc <myproc>
    8000493e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004940:	8526                	mv	a0,s1
    80004942:	abcfc0ef          	jal	80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004946:	2184a703          	lw	a4,536(s1)
    8000494a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000494e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004952:	02f71763          	bne	a4,a5,80004980 <piperead+0x5e>
    80004956:	2244a783          	lw	a5,548(s1)
    8000495a:	cf85                	beqz	a5,80004992 <piperead+0x70>
    if(killed(pr)){
    8000495c:	8552                	mv	a0,s4
    8000495e:	af5fd0ef          	jal	80002452 <killed>
    80004962:	e11d                	bnez	a0,80004988 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004964:	85a6                	mv	a1,s1
    80004966:	854e                	mv	a0,s3
    80004968:	8b3fd0ef          	jal	8000221a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000496c:	2184a703          	lw	a4,536(s1)
    80004970:	21c4a783          	lw	a5,540(s1)
    80004974:	fef701e3          	beq	a4,a5,80004956 <piperead+0x34>
    80004978:	f05a                	sd	s6,32(sp)
    8000497a:	ec5e                	sd	s7,24(sp)
    8000497c:	e862                	sd	s8,16(sp)
    8000497e:	a829                	j	80004998 <piperead+0x76>
    80004980:	f05a                	sd	s6,32(sp)
    80004982:	ec5e                	sd	s7,24(sp)
    80004984:	e862                	sd	s8,16(sp)
    80004986:	a809                	j	80004998 <piperead+0x76>
      release(&pi->lock);
    80004988:	8526                	mv	a0,s1
    8000498a:	b08fc0ef          	jal	80000c92 <release>
      return -1;
    8000498e:	59fd                	li	s3,-1
    80004990:	a0a5                	j	800049f8 <piperead+0xd6>
    80004992:	f05a                	sd	s6,32(sp)
    80004994:	ec5e                	sd	s7,24(sp)
    80004996:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004998:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000499a:	faf40c13          	addi	s8,s0,-81
    8000499e:	4b85                	li	s7,1
    800049a0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049a2:	05505163          	blez	s5,800049e4 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    800049a6:	2184a783          	lw	a5,536(s1)
    800049aa:	21c4a703          	lw	a4,540(s1)
    800049ae:	02f70b63          	beq	a4,a5,800049e4 <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800049b2:	0017871b          	addiw	a4,a5,1
    800049b6:	20e4ac23          	sw	a4,536(s1)
    800049ba:	1ff7f793          	andi	a5,a5,511
    800049be:	97a6                	add	a5,a5,s1
    800049c0:	0187c783          	lbu	a5,24(a5)
    800049c4:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800049c8:	86de                	mv	a3,s7
    800049ca:	8662                	mv	a2,s8
    800049cc:	85ca                	mv	a1,s2
    800049ce:	050a3503          	ld	a0,80(s4)
    800049d2:	bb3fc0ef          	jal	80001584 <copyout>
    800049d6:	01650763          	beq	a0,s6,800049e4 <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049da:	2985                	addiw	s3,s3,1
    800049dc:	0905                	addi	s2,s2,1
    800049de:	fd3a94e3          	bne	s5,s3,800049a6 <piperead+0x84>
    800049e2:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800049e4:	21c48513          	addi	a0,s1,540
    800049e8:	87ffd0ef          	jal	80002266 <wakeup>
  release(&pi->lock);
    800049ec:	8526                	mv	a0,s1
    800049ee:	aa4fc0ef          	jal	80000c92 <release>
    800049f2:	7b02                	ld	s6,32(sp)
    800049f4:	6be2                	ld	s7,24(sp)
    800049f6:	6c42                	ld	s8,16(sp)
  return i;
}
    800049f8:	854e                	mv	a0,s3
    800049fa:	60e6                	ld	ra,88(sp)
    800049fc:	6446                	ld	s0,80(sp)
    800049fe:	64a6                	ld	s1,72(sp)
    80004a00:	6906                	ld	s2,64(sp)
    80004a02:	79e2                	ld	s3,56(sp)
    80004a04:	7a42                	ld	s4,48(sp)
    80004a06:	7aa2                	ld	s5,40(sp)
    80004a08:	6125                	addi	sp,sp,96
    80004a0a:	8082                	ret

0000000080004a0c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004a0c:	1141                	addi	sp,sp,-16
    80004a0e:	e406                	sd	ra,8(sp)
    80004a10:	e022                	sd	s0,0(sp)
    80004a12:	0800                	addi	s0,sp,16
    80004a14:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004a16:	0035151b          	slliw	a0,a0,0x3
    80004a1a:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004a1c:	8b89                	andi	a5,a5,2
    80004a1e:	c399                	beqz	a5,80004a24 <flags2perm+0x18>
      perm |= PTE_W;
    80004a20:	00456513          	ori	a0,a0,4
    return perm;
}
    80004a24:	60a2                	ld	ra,8(sp)
    80004a26:	6402                	ld	s0,0(sp)
    80004a28:	0141                	addi	sp,sp,16
    80004a2a:	8082                	ret

0000000080004a2c <exec>:

int
exec(char *path, char **argv)
{
    80004a2c:	de010113          	addi	sp,sp,-544
    80004a30:	20113c23          	sd	ra,536(sp)
    80004a34:	20813823          	sd	s0,528(sp)
    80004a38:	20913423          	sd	s1,520(sp)
    80004a3c:	21213023          	sd	s2,512(sp)
    80004a40:	1400                	addi	s0,sp,544
    80004a42:	892a                	mv	s2,a0
    80004a44:	dea43823          	sd	a0,-528(s0)
    80004a48:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a4c:	e91fc0ef          	jal	800018dc <myproc>
    80004a50:	84aa                	mv	s1,a0

  begin_op();
    80004a52:	d88ff0ef          	jal	80003fda <begin_op>

  if((ip = namei(path)) == 0){
    80004a56:	854a                	mv	a0,s2
    80004a58:	bc0ff0ef          	jal	80003e18 <namei>
    80004a5c:	cd21                	beqz	a0,80004ab4 <exec+0x88>
    80004a5e:	fbd2                	sd	s4,496(sp)
    80004a60:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a62:	cc7fe0ef          	jal	80003728 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a66:	04000713          	li	a4,64
    80004a6a:	4681                	li	a3,0
    80004a6c:	e5040613          	addi	a2,s0,-432
    80004a70:	4581                	li	a1,0
    80004a72:	8552                	mv	a0,s4
    80004a74:	f0dfe0ef          	jal	80003980 <readi>
    80004a78:	04000793          	li	a5,64
    80004a7c:	00f51a63          	bne	a0,a5,80004a90 <exec+0x64>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004a80:	e5042703          	lw	a4,-432(s0)
    80004a84:	464c47b7          	lui	a5,0x464c4
    80004a88:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a8c:	02f70863          	beq	a4,a5,80004abc <exec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004a90:	8552                	mv	a0,s4
    80004a92:	ea1fe0ef          	jal	80003932 <iunlockput>
    end_op();
    80004a96:	daeff0ef          	jal	80004044 <end_op>
  }
  return -1;
    80004a9a:	557d                	li	a0,-1
    80004a9c:	7a5e                	ld	s4,496(sp)
}
    80004a9e:	21813083          	ld	ra,536(sp)
    80004aa2:	21013403          	ld	s0,528(sp)
    80004aa6:	20813483          	ld	s1,520(sp)
    80004aaa:	20013903          	ld	s2,512(sp)
    80004aae:	22010113          	addi	sp,sp,544
    80004ab2:	8082                	ret
    end_op();
    80004ab4:	d90ff0ef          	jal	80004044 <end_op>
    return -1;
    80004ab8:	557d                	li	a0,-1
    80004aba:	b7d5                	j	80004a9e <exec+0x72>
    80004abc:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004abe:	8526                	mv	a0,s1
    80004ac0:	ec5fc0ef          	jal	80001984 <proc_pagetable>
    80004ac4:	8b2a                	mv	s6,a0
    80004ac6:	26050d63          	beqz	a0,80004d40 <exec+0x314>
    80004aca:	ffce                	sd	s3,504(sp)
    80004acc:	f7d6                	sd	s5,488(sp)
    80004ace:	efde                	sd	s7,472(sp)
    80004ad0:	ebe2                	sd	s8,464(sp)
    80004ad2:	e7e6                	sd	s9,456(sp)
    80004ad4:	e3ea                	sd	s10,448(sp)
    80004ad6:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ad8:	e7042683          	lw	a3,-400(s0)
    80004adc:	e8845783          	lhu	a5,-376(s0)
    80004ae0:	0e078763          	beqz	a5,80004bce <exec+0x1a2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ae4:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ae6:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ae8:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004aec:	6c85                	lui	s9,0x1
    80004aee:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004af2:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004af6:	6a85                	lui	s5,0x1
    80004af8:	a085                	j	80004b58 <exec+0x12c>
      panic("loadseg: address should exist");
    80004afa:	00003517          	auipc	a0,0x3
    80004afe:	c1650513          	addi	a0,a0,-1002 # 80007710 <etext+0x710>
    80004b02:	c9dfb0ef          	jal	8000079e <panic>
    if(sz - i < PGSIZE)
    80004b06:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004b08:	874a                	mv	a4,s2
    80004b0a:	009c06bb          	addw	a3,s8,s1
    80004b0e:	4581                	li	a1,0
    80004b10:	8552                	mv	a0,s4
    80004b12:	e6ffe0ef          	jal	80003980 <readi>
    80004b16:	22a91963          	bne	s2,a0,80004d48 <exec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    80004b1a:	009a84bb          	addw	s1,s5,s1
    80004b1e:	0334f263          	bgeu	s1,s3,80004b42 <exec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004b22:	02049593          	slli	a1,s1,0x20
    80004b26:	9181                	srli	a1,a1,0x20
    80004b28:	95de                	add	a1,a1,s7
    80004b2a:	855a                	mv	a0,s6
    80004b2c:	cd0fc0ef          	jal	80000ffc <walkaddr>
    80004b30:	862a                	mv	a2,a0
    if(pa == 0)
    80004b32:	d561                	beqz	a0,80004afa <exec+0xce>
    if(sz - i < PGSIZE)
    80004b34:	409987bb          	subw	a5,s3,s1
    80004b38:	893e                	mv	s2,a5
    80004b3a:	fcfcf6e3          	bgeu	s9,a5,80004b06 <exec+0xda>
    80004b3e:	8956                	mv	s2,s5
    80004b40:	b7d9                	j	80004b06 <exec+0xda>
    sz = sz1;
    80004b42:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b46:	2d05                	addiw	s10,s10,1
    80004b48:	e0843783          	ld	a5,-504(s0)
    80004b4c:	0387869b          	addiw	a3,a5,56
    80004b50:	e8845783          	lhu	a5,-376(s0)
    80004b54:	06fd5e63          	bge	s10,a5,80004bd0 <exec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b58:	e0d43423          	sd	a3,-504(s0)
    80004b5c:	876e                	mv	a4,s11
    80004b5e:	e1840613          	addi	a2,s0,-488
    80004b62:	4581                	li	a1,0
    80004b64:	8552                	mv	a0,s4
    80004b66:	e1bfe0ef          	jal	80003980 <readi>
    80004b6a:	1db51d63          	bne	a0,s11,80004d44 <exec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    80004b6e:	e1842783          	lw	a5,-488(s0)
    80004b72:	4705                	li	a4,1
    80004b74:	fce799e3          	bne	a5,a4,80004b46 <exec+0x11a>
    if(ph.memsz < ph.filesz)
    80004b78:	e4043483          	ld	s1,-448(s0)
    80004b7c:	e3843783          	ld	a5,-456(s0)
    80004b80:	1ef4e263          	bltu	s1,a5,80004d64 <exec+0x338>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004b84:	e2843783          	ld	a5,-472(s0)
    80004b88:	94be                	add	s1,s1,a5
    80004b8a:	1ef4e063          	bltu	s1,a5,80004d6a <exec+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    80004b8e:	de843703          	ld	a4,-536(s0)
    80004b92:	8ff9                	and	a5,a5,a4
    80004b94:	1c079e63          	bnez	a5,80004d70 <exec+0x344>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004b98:	e1c42503          	lw	a0,-484(s0)
    80004b9c:	e71ff0ef          	jal	80004a0c <flags2perm>
    80004ba0:	86aa                	mv	a3,a0
    80004ba2:	8626                	mv	a2,s1
    80004ba4:	85ca                	mv	a1,s2
    80004ba6:	855a                	mv	a0,s6
    80004ba8:	fbcfc0ef          	jal	80001364 <uvmalloc>
    80004bac:	dea43c23          	sd	a0,-520(s0)
    80004bb0:	1c050363          	beqz	a0,80004d76 <exec+0x34a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004bb4:	e2843b83          	ld	s7,-472(s0)
    80004bb8:	e2042c03          	lw	s8,-480(s0)
    80004bbc:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004bc0:	00098463          	beqz	s3,80004bc8 <exec+0x19c>
    80004bc4:	4481                	li	s1,0
    80004bc6:	bfb1                	j	80004b22 <exec+0xf6>
    sz = sz1;
    80004bc8:	df843903          	ld	s2,-520(s0)
    80004bcc:	bfad                	j	80004b46 <exec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bce:	4901                	li	s2,0
  iunlockput(ip);
    80004bd0:	8552                	mv	a0,s4
    80004bd2:	d61fe0ef          	jal	80003932 <iunlockput>
  end_op();
    80004bd6:	c6eff0ef          	jal	80004044 <end_op>
  p = myproc();
    80004bda:	d03fc0ef          	jal	800018dc <myproc>
    80004bde:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004be0:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004be4:	6985                	lui	s3,0x1
    80004be6:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004be8:	99ca                	add	s3,s3,s2
    80004bea:	77fd                	lui	a5,0xfffff
    80004bec:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004bf0:	4691                	li	a3,4
    80004bf2:	6609                	lui	a2,0x2
    80004bf4:	964e                	add	a2,a2,s3
    80004bf6:	85ce                	mv	a1,s3
    80004bf8:	855a                	mv	a0,s6
    80004bfa:	f6afc0ef          	jal	80001364 <uvmalloc>
    80004bfe:	8a2a                	mv	s4,a0
    80004c00:	e105                	bnez	a0,80004c20 <exec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004c02:	85ce                	mv	a1,s3
    80004c04:	855a                	mv	a0,s6
    80004c06:	e03fc0ef          	jal	80001a08 <proc_freepagetable>
  return -1;
    80004c0a:	557d                	li	a0,-1
    80004c0c:	79fe                	ld	s3,504(sp)
    80004c0e:	7a5e                	ld	s4,496(sp)
    80004c10:	7abe                	ld	s5,488(sp)
    80004c12:	7b1e                	ld	s6,480(sp)
    80004c14:	6bfe                	ld	s7,472(sp)
    80004c16:	6c5e                	ld	s8,464(sp)
    80004c18:	6cbe                	ld	s9,456(sp)
    80004c1a:	6d1e                	ld	s10,448(sp)
    80004c1c:	7dfa                	ld	s11,440(sp)
    80004c1e:	b541                	j	80004a9e <exec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004c20:	75f9                	lui	a1,0xffffe
    80004c22:	95aa                	add	a1,a1,a0
    80004c24:	855a                	mv	a0,s6
    80004c26:	935fc0ef          	jal	8000155a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004c2a:	7bfd                	lui	s7,0xfffff
    80004c2c:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    80004c2e:	e0043783          	ld	a5,-512(s0)
    80004c32:	6388                	ld	a0,0(a5)
  sp = sz;
    80004c34:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004c36:	4481                	li	s1,0
    ustack[argc] = sp;
    80004c38:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004c3c:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004c40:	cd21                	beqz	a0,80004c98 <exec+0x26c>
    sp -= strlen(argv[argc]) + 1;
    80004c42:	a14fc0ef          	jal	80000e56 <strlen>
    80004c46:	0015079b          	addiw	a5,a0,1
    80004c4a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c4e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004c52:	13796563          	bltu	s2,s7,80004d7c <exec+0x350>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c56:	e0043d83          	ld	s11,-512(s0)
    80004c5a:	000db983          	ld	s3,0(s11)
    80004c5e:	854e                	mv	a0,s3
    80004c60:	9f6fc0ef          	jal	80000e56 <strlen>
    80004c64:	0015069b          	addiw	a3,a0,1
    80004c68:	864e                	mv	a2,s3
    80004c6a:	85ca                	mv	a1,s2
    80004c6c:	855a                	mv	a0,s6
    80004c6e:	917fc0ef          	jal	80001584 <copyout>
    80004c72:	10054763          	bltz	a0,80004d80 <exec+0x354>
    ustack[argc] = sp;
    80004c76:	00349793          	slli	a5,s1,0x3
    80004c7a:	97e6                	add	a5,a5,s9
    80004c7c:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd45d0>
  for(argc = 0; argv[argc]; argc++) {
    80004c80:	0485                	addi	s1,s1,1
    80004c82:	008d8793          	addi	a5,s11,8
    80004c86:	e0f43023          	sd	a5,-512(s0)
    80004c8a:	008db503          	ld	a0,8(s11)
    80004c8e:	c509                	beqz	a0,80004c98 <exec+0x26c>
    if(argc >= MAXARG)
    80004c90:	fb8499e3          	bne	s1,s8,80004c42 <exec+0x216>
  sz = sz1;
    80004c94:	89d2                	mv	s3,s4
    80004c96:	b7b5                	j	80004c02 <exec+0x1d6>
  ustack[argc] = 0;
    80004c98:	00349793          	slli	a5,s1,0x3
    80004c9c:	f9078793          	addi	a5,a5,-112
    80004ca0:	97a2                	add	a5,a5,s0
    80004ca2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004ca6:	00148693          	addi	a3,s1,1
    80004caa:	068e                	slli	a3,a3,0x3
    80004cac:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004cb0:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004cb4:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004cb6:	f57966e3          	bltu	s2,s7,80004c02 <exec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004cba:	e9040613          	addi	a2,s0,-368
    80004cbe:	85ca                	mv	a1,s2
    80004cc0:	855a                	mv	a0,s6
    80004cc2:	8c3fc0ef          	jal	80001584 <copyout>
    80004cc6:	f2054ee3          	bltz	a0,80004c02 <exec+0x1d6>
  p->trapframe->a1 = sp;
    80004cca:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004cce:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004cd2:	df043783          	ld	a5,-528(s0)
    80004cd6:	0007c703          	lbu	a4,0(a5)
    80004cda:	cf11                	beqz	a4,80004cf6 <exec+0x2ca>
    80004cdc:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004cde:	02f00693          	li	a3,47
    80004ce2:	a029                	j	80004cec <exec+0x2c0>
  for(last=s=path; *s; s++)
    80004ce4:	0785                	addi	a5,a5,1
    80004ce6:	fff7c703          	lbu	a4,-1(a5)
    80004cea:	c711                	beqz	a4,80004cf6 <exec+0x2ca>
    if(*s == '/')
    80004cec:	fed71ce3          	bne	a4,a3,80004ce4 <exec+0x2b8>
      last = s+1;
    80004cf0:	def43823          	sd	a5,-528(s0)
    80004cf4:	bfc5                	j	80004ce4 <exec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    80004cf6:	4641                	li	a2,16
    80004cf8:	df043583          	ld	a1,-528(s0)
    80004cfc:	158a8513          	addi	a0,s5,344
    80004d00:	920fc0ef          	jal	80000e20 <safestrcpy>
  oldpagetable = p->pagetable;
    80004d04:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004d08:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004d0c:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004d10:	058ab783          	ld	a5,88(s5)
    80004d14:	e6843703          	ld	a4,-408(s0)
    80004d18:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004d1a:	058ab783          	ld	a5,88(s5)
    80004d1e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004d22:	85ea                	mv	a1,s10
    80004d24:	ce5fc0ef          	jal	80001a08 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004d28:	0004851b          	sext.w	a0,s1
    80004d2c:	79fe                	ld	s3,504(sp)
    80004d2e:	7a5e                	ld	s4,496(sp)
    80004d30:	7abe                	ld	s5,488(sp)
    80004d32:	7b1e                	ld	s6,480(sp)
    80004d34:	6bfe                	ld	s7,472(sp)
    80004d36:	6c5e                	ld	s8,464(sp)
    80004d38:	6cbe                	ld	s9,456(sp)
    80004d3a:	6d1e                	ld	s10,448(sp)
    80004d3c:	7dfa                	ld	s11,440(sp)
    80004d3e:	b385                	j	80004a9e <exec+0x72>
    80004d40:	7b1e                	ld	s6,480(sp)
    80004d42:	b3b9                	j	80004a90 <exec+0x64>
    80004d44:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004d48:	df843583          	ld	a1,-520(s0)
    80004d4c:	855a                	mv	a0,s6
    80004d4e:	cbbfc0ef          	jal	80001a08 <proc_freepagetable>
  if(ip){
    80004d52:	79fe                	ld	s3,504(sp)
    80004d54:	7abe                	ld	s5,488(sp)
    80004d56:	7b1e                	ld	s6,480(sp)
    80004d58:	6bfe                	ld	s7,472(sp)
    80004d5a:	6c5e                	ld	s8,464(sp)
    80004d5c:	6cbe                	ld	s9,456(sp)
    80004d5e:	6d1e                	ld	s10,448(sp)
    80004d60:	7dfa                	ld	s11,440(sp)
    80004d62:	b33d                	j	80004a90 <exec+0x64>
    80004d64:	df243c23          	sd	s2,-520(s0)
    80004d68:	b7c5                	j	80004d48 <exec+0x31c>
    80004d6a:	df243c23          	sd	s2,-520(s0)
    80004d6e:	bfe9                	j	80004d48 <exec+0x31c>
    80004d70:	df243c23          	sd	s2,-520(s0)
    80004d74:	bfd1                	j	80004d48 <exec+0x31c>
    80004d76:	df243c23          	sd	s2,-520(s0)
    80004d7a:	b7f9                	j	80004d48 <exec+0x31c>
  sz = sz1;
    80004d7c:	89d2                	mv	s3,s4
    80004d7e:	b551                	j	80004c02 <exec+0x1d6>
    80004d80:	89d2                	mv	s3,s4
    80004d82:	b541                	j	80004c02 <exec+0x1d6>

0000000080004d84 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d84:	7179                	addi	sp,sp,-48
    80004d86:	f406                	sd	ra,40(sp)
    80004d88:	f022                	sd	s0,32(sp)
    80004d8a:	ec26                	sd	s1,24(sp)
    80004d8c:	e84a                	sd	s2,16(sp)
    80004d8e:	1800                	addi	s0,sp,48
    80004d90:	892e                	mv	s2,a1
    80004d92:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d94:	fdc40593          	addi	a1,s0,-36
    80004d98:	d67fd0ef          	jal	80002afe <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004d9c:	fdc42703          	lw	a4,-36(s0)
    80004da0:	47bd                	li	a5,15
    80004da2:	02e7e963          	bltu	a5,a4,80004dd4 <argfd+0x50>
    80004da6:	b37fc0ef          	jal	800018dc <myproc>
    80004daa:	fdc42703          	lw	a4,-36(s0)
    80004dae:	01a70793          	addi	a5,a4,26
    80004db2:	078e                	slli	a5,a5,0x3
    80004db4:	953e                	add	a0,a0,a5
    80004db6:	611c                	ld	a5,0(a0)
    80004db8:	c385                	beqz	a5,80004dd8 <argfd+0x54>
    return -1;
  if(pfd)
    80004dba:	00090463          	beqz	s2,80004dc2 <argfd+0x3e>
    *pfd = fd;
    80004dbe:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004dc2:	4501                	li	a0,0
  if(pf)
    80004dc4:	c091                	beqz	s1,80004dc8 <argfd+0x44>
    *pf = f;
    80004dc6:	e09c                	sd	a5,0(s1)
}
    80004dc8:	70a2                	ld	ra,40(sp)
    80004dca:	7402                	ld	s0,32(sp)
    80004dcc:	64e2                	ld	s1,24(sp)
    80004dce:	6942                	ld	s2,16(sp)
    80004dd0:	6145                	addi	sp,sp,48
    80004dd2:	8082                	ret
    return -1;
    80004dd4:	557d                	li	a0,-1
    80004dd6:	bfcd                	j	80004dc8 <argfd+0x44>
    80004dd8:	557d                	li	a0,-1
    80004dda:	b7fd                	j	80004dc8 <argfd+0x44>

0000000080004ddc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004ddc:	1101                	addi	sp,sp,-32
    80004dde:	ec06                	sd	ra,24(sp)
    80004de0:	e822                	sd	s0,16(sp)
    80004de2:	e426                	sd	s1,8(sp)
    80004de4:	1000                	addi	s0,sp,32
    80004de6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004de8:	af5fc0ef          	jal	800018dc <myproc>
    80004dec:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004dee:	0d050793          	addi	a5,a0,208
    80004df2:	4501                	li	a0,0
    80004df4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004df6:	6398                	ld	a4,0(a5)
    80004df8:	cb19                	beqz	a4,80004e0e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004dfa:	2505                	addiw	a0,a0,1
    80004dfc:	07a1                	addi	a5,a5,8
    80004dfe:	fed51ce3          	bne	a0,a3,80004df6 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004e02:	557d                	li	a0,-1
}
    80004e04:	60e2                	ld	ra,24(sp)
    80004e06:	6442                	ld	s0,16(sp)
    80004e08:	64a2                	ld	s1,8(sp)
    80004e0a:	6105                	addi	sp,sp,32
    80004e0c:	8082                	ret
      p->ofile[fd] = f;
    80004e0e:	01a50793          	addi	a5,a0,26
    80004e12:	078e                	slli	a5,a5,0x3
    80004e14:	963e                	add	a2,a2,a5
    80004e16:	e204                	sd	s1,0(a2)
      return fd;
    80004e18:	b7f5                	j	80004e04 <fdalloc+0x28>

0000000080004e1a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004e1a:	715d                	addi	sp,sp,-80
    80004e1c:	e486                	sd	ra,72(sp)
    80004e1e:	e0a2                	sd	s0,64(sp)
    80004e20:	fc26                	sd	s1,56(sp)
    80004e22:	f84a                	sd	s2,48(sp)
    80004e24:	f44e                	sd	s3,40(sp)
    80004e26:	ec56                	sd	s5,24(sp)
    80004e28:	e85a                	sd	s6,16(sp)
    80004e2a:	0880                	addi	s0,sp,80
    80004e2c:	8b2e                	mv	s6,a1
    80004e2e:	89b2                	mv	s3,a2
    80004e30:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004e32:	fb040593          	addi	a1,s0,-80
    80004e36:	ffdfe0ef          	jal	80003e32 <nameiparent>
    80004e3a:	84aa                	mv	s1,a0
    80004e3c:	10050a63          	beqz	a0,80004f50 <create+0x136>
    return 0;

  ilock(dp);
    80004e40:	8e9fe0ef          	jal	80003728 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004e44:	4601                	li	a2,0
    80004e46:	fb040593          	addi	a1,s0,-80
    80004e4a:	8526                	mv	a0,s1
    80004e4c:	d41fe0ef          	jal	80003b8c <dirlookup>
    80004e50:	8aaa                	mv	s5,a0
    80004e52:	c129                	beqz	a0,80004e94 <create+0x7a>
    iunlockput(dp);
    80004e54:	8526                	mv	a0,s1
    80004e56:	addfe0ef          	jal	80003932 <iunlockput>
    ilock(ip);
    80004e5a:	8556                	mv	a0,s5
    80004e5c:	8cdfe0ef          	jal	80003728 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e60:	4789                	li	a5,2
    80004e62:	02fb1463          	bne	s6,a5,80004e8a <create+0x70>
    80004e66:	044ad783          	lhu	a5,68(s5)
    80004e6a:	37f9                	addiw	a5,a5,-2
    80004e6c:	17c2                	slli	a5,a5,0x30
    80004e6e:	93c1                	srli	a5,a5,0x30
    80004e70:	4705                	li	a4,1
    80004e72:	00f76c63          	bltu	a4,a5,80004e8a <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e76:	8556                	mv	a0,s5
    80004e78:	60a6                	ld	ra,72(sp)
    80004e7a:	6406                	ld	s0,64(sp)
    80004e7c:	74e2                	ld	s1,56(sp)
    80004e7e:	7942                	ld	s2,48(sp)
    80004e80:	79a2                	ld	s3,40(sp)
    80004e82:	6ae2                	ld	s5,24(sp)
    80004e84:	6b42                	ld	s6,16(sp)
    80004e86:	6161                	addi	sp,sp,80
    80004e88:	8082                	ret
    iunlockput(ip);
    80004e8a:	8556                	mv	a0,s5
    80004e8c:	aa7fe0ef          	jal	80003932 <iunlockput>
    return 0;
    80004e90:	4a81                	li	s5,0
    80004e92:	b7d5                	j	80004e76 <create+0x5c>
    80004e94:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004e96:	85da                	mv	a1,s6
    80004e98:	4088                	lw	a0,0(s1)
    80004e9a:	f1efe0ef          	jal	800035b8 <ialloc>
    80004e9e:	8a2a                	mv	s4,a0
    80004ea0:	cd15                	beqz	a0,80004edc <create+0xc2>
  ilock(ip);
    80004ea2:	887fe0ef          	jal	80003728 <ilock>
  ip->major = major;
    80004ea6:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004eaa:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004eae:	4905                	li	s2,1
    80004eb0:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004eb4:	8552                	mv	a0,s4
    80004eb6:	fbefe0ef          	jal	80003674 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004eba:	032b0763          	beq	s6,s2,80004ee8 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ebe:	004a2603          	lw	a2,4(s4)
    80004ec2:	fb040593          	addi	a1,s0,-80
    80004ec6:	8526                	mv	a0,s1
    80004ec8:	ea7fe0ef          	jal	80003d6e <dirlink>
    80004ecc:	06054563          	bltz	a0,80004f36 <create+0x11c>
  iunlockput(dp);
    80004ed0:	8526                	mv	a0,s1
    80004ed2:	a61fe0ef          	jal	80003932 <iunlockput>
  return ip;
    80004ed6:	8ad2                	mv	s5,s4
    80004ed8:	7a02                	ld	s4,32(sp)
    80004eda:	bf71                	j	80004e76 <create+0x5c>
    iunlockput(dp);
    80004edc:	8526                	mv	a0,s1
    80004ede:	a55fe0ef          	jal	80003932 <iunlockput>
    return 0;
    80004ee2:	8ad2                	mv	s5,s4
    80004ee4:	7a02                	ld	s4,32(sp)
    80004ee6:	bf41                	j	80004e76 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ee8:	004a2603          	lw	a2,4(s4)
    80004eec:	00003597          	auipc	a1,0x3
    80004ef0:	84458593          	addi	a1,a1,-1980 # 80007730 <etext+0x730>
    80004ef4:	8552                	mv	a0,s4
    80004ef6:	e79fe0ef          	jal	80003d6e <dirlink>
    80004efa:	02054e63          	bltz	a0,80004f36 <create+0x11c>
    80004efe:	40d0                	lw	a2,4(s1)
    80004f00:	00003597          	auipc	a1,0x3
    80004f04:	83858593          	addi	a1,a1,-1992 # 80007738 <etext+0x738>
    80004f08:	8552                	mv	a0,s4
    80004f0a:	e65fe0ef          	jal	80003d6e <dirlink>
    80004f0e:	02054463          	bltz	a0,80004f36 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004f12:	004a2603          	lw	a2,4(s4)
    80004f16:	fb040593          	addi	a1,s0,-80
    80004f1a:	8526                	mv	a0,s1
    80004f1c:	e53fe0ef          	jal	80003d6e <dirlink>
    80004f20:	00054b63          	bltz	a0,80004f36 <create+0x11c>
    dp->nlink++;  // for ".."
    80004f24:	04a4d783          	lhu	a5,74(s1)
    80004f28:	2785                	addiw	a5,a5,1
    80004f2a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f2e:	8526                	mv	a0,s1
    80004f30:	f44fe0ef          	jal	80003674 <iupdate>
    80004f34:	bf71                	j	80004ed0 <create+0xb6>
  ip->nlink = 0;
    80004f36:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004f3a:	8552                	mv	a0,s4
    80004f3c:	f38fe0ef          	jal	80003674 <iupdate>
  iunlockput(ip);
    80004f40:	8552                	mv	a0,s4
    80004f42:	9f1fe0ef          	jal	80003932 <iunlockput>
  iunlockput(dp);
    80004f46:	8526                	mv	a0,s1
    80004f48:	9ebfe0ef          	jal	80003932 <iunlockput>
  return 0;
    80004f4c:	7a02                	ld	s4,32(sp)
    80004f4e:	b725                	j	80004e76 <create+0x5c>
    return 0;
    80004f50:	8aaa                	mv	s5,a0
    80004f52:	b715                	j	80004e76 <create+0x5c>

0000000080004f54 <sys_dup>:
{
    80004f54:	7179                	addi	sp,sp,-48
    80004f56:	f406                	sd	ra,40(sp)
    80004f58:	f022                	sd	s0,32(sp)
    80004f5a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004f5c:	fd840613          	addi	a2,s0,-40
    80004f60:	4581                	li	a1,0
    80004f62:	4501                	li	a0,0
    80004f64:	e21ff0ef          	jal	80004d84 <argfd>
    return -1;
    80004f68:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004f6a:	02054363          	bltz	a0,80004f90 <sys_dup+0x3c>
    80004f6e:	ec26                	sd	s1,24(sp)
    80004f70:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004f72:	fd843903          	ld	s2,-40(s0)
    80004f76:	854a                	mv	a0,s2
    80004f78:	e65ff0ef          	jal	80004ddc <fdalloc>
    80004f7c:	84aa                	mv	s1,a0
    return -1;
    80004f7e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004f80:	00054d63          	bltz	a0,80004f9a <sys_dup+0x46>
  filedup(f);
    80004f84:	854a                	mv	a0,s2
    80004f86:	c2eff0ef          	jal	800043b4 <filedup>
  return fd;
    80004f8a:	87a6                	mv	a5,s1
    80004f8c:	64e2                	ld	s1,24(sp)
    80004f8e:	6942                	ld	s2,16(sp)
}
    80004f90:	853e                	mv	a0,a5
    80004f92:	70a2                	ld	ra,40(sp)
    80004f94:	7402                	ld	s0,32(sp)
    80004f96:	6145                	addi	sp,sp,48
    80004f98:	8082                	ret
    80004f9a:	64e2                	ld	s1,24(sp)
    80004f9c:	6942                	ld	s2,16(sp)
    80004f9e:	bfcd                	j	80004f90 <sys_dup+0x3c>

0000000080004fa0 <sys_read>:
{
    80004fa0:	7179                	addi	sp,sp,-48
    80004fa2:	f406                	sd	ra,40(sp)
    80004fa4:	f022                	sd	s0,32(sp)
    80004fa6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fa8:	fd840593          	addi	a1,s0,-40
    80004fac:	4505                	li	a0,1
    80004fae:	b6dfd0ef          	jal	80002b1a <argaddr>
  argint(2, &n);
    80004fb2:	fe440593          	addi	a1,s0,-28
    80004fb6:	4509                	li	a0,2
    80004fb8:	b47fd0ef          	jal	80002afe <argint>
  if(argfd(0, 0, &f) < 0)
    80004fbc:	fe840613          	addi	a2,s0,-24
    80004fc0:	4581                	li	a1,0
    80004fc2:	4501                	li	a0,0
    80004fc4:	dc1ff0ef          	jal	80004d84 <argfd>
    80004fc8:	87aa                	mv	a5,a0
    return -1;
    80004fca:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fcc:	0007ca63          	bltz	a5,80004fe0 <sys_read+0x40>
  return fileread(f, p, n);
    80004fd0:	fe442603          	lw	a2,-28(s0)
    80004fd4:	fd843583          	ld	a1,-40(s0)
    80004fd8:	fe843503          	ld	a0,-24(s0)
    80004fdc:	d3eff0ef          	jal	8000451a <fileread>
}
    80004fe0:	70a2                	ld	ra,40(sp)
    80004fe2:	7402                	ld	s0,32(sp)
    80004fe4:	6145                	addi	sp,sp,48
    80004fe6:	8082                	ret

0000000080004fe8 <sys_write>:
{
    80004fe8:	7179                	addi	sp,sp,-48
    80004fea:	f406                	sd	ra,40(sp)
    80004fec:	f022                	sd	s0,32(sp)
    80004fee:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ff0:	fd840593          	addi	a1,s0,-40
    80004ff4:	4505                	li	a0,1
    80004ff6:	b25fd0ef          	jal	80002b1a <argaddr>
  argint(2, &n);
    80004ffa:	fe440593          	addi	a1,s0,-28
    80004ffe:	4509                	li	a0,2
    80005000:	afffd0ef          	jal	80002afe <argint>
  if(argfd(0, 0, &f) < 0)
    80005004:	fe840613          	addi	a2,s0,-24
    80005008:	4581                	li	a1,0
    8000500a:	4501                	li	a0,0
    8000500c:	d79ff0ef          	jal	80004d84 <argfd>
    80005010:	87aa                	mv	a5,a0
    return -1;
    80005012:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005014:	0007ca63          	bltz	a5,80005028 <sys_write+0x40>
  return filewrite(f, p, n);
    80005018:	fe442603          	lw	a2,-28(s0)
    8000501c:	fd843583          	ld	a1,-40(s0)
    80005020:	fe843503          	ld	a0,-24(s0)
    80005024:	db4ff0ef          	jal	800045d8 <filewrite>
}
    80005028:	70a2                	ld	ra,40(sp)
    8000502a:	7402                	ld	s0,32(sp)
    8000502c:	6145                	addi	sp,sp,48
    8000502e:	8082                	ret

0000000080005030 <sys_close>:
{
    80005030:	1101                	addi	sp,sp,-32
    80005032:	ec06                	sd	ra,24(sp)
    80005034:	e822                	sd	s0,16(sp)
    80005036:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005038:	fe040613          	addi	a2,s0,-32
    8000503c:	fec40593          	addi	a1,s0,-20
    80005040:	4501                	li	a0,0
    80005042:	d43ff0ef          	jal	80004d84 <argfd>
    return -1;
    80005046:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005048:	02054063          	bltz	a0,80005068 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000504c:	891fc0ef          	jal	800018dc <myproc>
    80005050:	fec42783          	lw	a5,-20(s0)
    80005054:	07e9                	addi	a5,a5,26
    80005056:	078e                	slli	a5,a5,0x3
    80005058:	953e                	add	a0,a0,a5
    8000505a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000505e:	fe043503          	ld	a0,-32(s0)
    80005062:	b98ff0ef          	jal	800043fa <fileclose>
  return 0;
    80005066:	4781                	li	a5,0
}
    80005068:	853e                	mv	a0,a5
    8000506a:	60e2                	ld	ra,24(sp)
    8000506c:	6442                	ld	s0,16(sp)
    8000506e:	6105                	addi	sp,sp,32
    80005070:	8082                	ret

0000000080005072 <sys_fstat>:
{
    80005072:	1101                	addi	sp,sp,-32
    80005074:	ec06                	sd	ra,24(sp)
    80005076:	e822                	sd	s0,16(sp)
    80005078:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000507a:	fe040593          	addi	a1,s0,-32
    8000507e:	4505                	li	a0,1
    80005080:	a9bfd0ef          	jal	80002b1a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005084:	fe840613          	addi	a2,s0,-24
    80005088:	4581                	li	a1,0
    8000508a:	4501                	li	a0,0
    8000508c:	cf9ff0ef          	jal	80004d84 <argfd>
    80005090:	87aa                	mv	a5,a0
    return -1;
    80005092:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005094:	0007c863          	bltz	a5,800050a4 <sys_fstat+0x32>
  return filestat(f, st);
    80005098:	fe043583          	ld	a1,-32(s0)
    8000509c:	fe843503          	ld	a0,-24(s0)
    800050a0:	c18ff0ef          	jal	800044b8 <filestat>
}
    800050a4:	60e2                	ld	ra,24(sp)
    800050a6:	6442                	ld	s0,16(sp)
    800050a8:	6105                	addi	sp,sp,32
    800050aa:	8082                	ret

00000000800050ac <sys_link>:
{
    800050ac:	7169                	addi	sp,sp,-304
    800050ae:	f606                	sd	ra,296(sp)
    800050b0:	f222                	sd	s0,288(sp)
    800050b2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050b4:	08000613          	li	a2,128
    800050b8:	ed040593          	addi	a1,s0,-304
    800050bc:	4501                	li	a0,0
    800050be:	a79fd0ef          	jal	80002b36 <argstr>
    return -1;
    800050c2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050c4:	0c054e63          	bltz	a0,800051a0 <sys_link+0xf4>
    800050c8:	08000613          	li	a2,128
    800050cc:	f5040593          	addi	a1,s0,-176
    800050d0:	4505                	li	a0,1
    800050d2:	a65fd0ef          	jal	80002b36 <argstr>
    return -1;
    800050d6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050d8:	0c054463          	bltz	a0,800051a0 <sys_link+0xf4>
    800050dc:	ee26                	sd	s1,280(sp)
  begin_op();
    800050de:	efdfe0ef          	jal	80003fda <begin_op>
  if((ip = namei(old)) == 0){
    800050e2:	ed040513          	addi	a0,s0,-304
    800050e6:	d33fe0ef          	jal	80003e18 <namei>
    800050ea:	84aa                	mv	s1,a0
    800050ec:	c53d                	beqz	a0,8000515a <sys_link+0xae>
  ilock(ip);
    800050ee:	e3afe0ef          	jal	80003728 <ilock>
  if(ip->type == T_DIR){
    800050f2:	04449703          	lh	a4,68(s1)
    800050f6:	4785                	li	a5,1
    800050f8:	06f70663          	beq	a4,a5,80005164 <sys_link+0xb8>
    800050fc:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800050fe:	04a4d783          	lhu	a5,74(s1)
    80005102:	2785                	addiw	a5,a5,1
    80005104:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005108:	8526                	mv	a0,s1
    8000510a:	d6afe0ef          	jal	80003674 <iupdate>
  iunlock(ip);
    8000510e:	8526                	mv	a0,s1
    80005110:	ec6fe0ef          	jal	800037d6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005114:	fd040593          	addi	a1,s0,-48
    80005118:	f5040513          	addi	a0,s0,-176
    8000511c:	d17fe0ef          	jal	80003e32 <nameiparent>
    80005120:	892a                	mv	s2,a0
    80005122:	cd21                	beqz	a0,8000517a <sys_link+0xce>
  ilock(dp);
    80005124:	e04fe0ef          	jal	80003728 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005128:	00092703          	lw	a4,0(s2)
    8000512c:	409c                	lw	a5,0(s1)
    8000512e:	04f71363          	bne	a4,a5,80005174 <sys_link+0xc8>
    80005132:	40d0                	lw	a2,4(s1)
    80005134:	fd040593          	addi	a1,s0,-48
    80005138:	854a                	mv	a0,s2
    8000513a:	c35fe0ef          	jal	80003d6e <dirlink>
    8000513e:	02054b63          	bltz	a0,80005174 <sys_link+0xc8>
  iunlockput(dp);
    80005142:	854a                	mv	a0,s2
    80005144:	feefe0ef          	jal	80003932 <iunlockput>
  iput(ip);
    80005148:	8526                	mv	a0,s1
    8000514a:	f60fe0ef          	jal	800038aa <iput>
  end_op();
    8000514e:	ef7fe0ef          	jal	80004044 <end_op>
  return 0;
    80005152:	4781                	li	a5,0
    80005154:	64f2                	ld	s1,280(sp)
    80005156:	6952                	ld	s2,272(sp)
    80005158:	a0a1                	j	800051a0 <sys_link+0xf4>
    end_op();
    8000515a:	eebfe0ef          	jal	80004044 <end_op>
    return -1;
    8000515e:	57fd                	li	a5,-1
    80005160:	64f2                	ld	s1,280(sp)
    80005162:	a83d                	j	800051a0 <sys_link+0xf4>
    iunlockput(ip);
    80005164:	8526                	mv	a0,s1
    80005166:	fccfe0ef          	jal	80003932 <iunlockput>
    end_op();
    8000516a:	edbfe0ef          	jal	80004044 <end_op>
    return -1;
    8000516e:	57fd                	li	a5,-1
    80005170:	64f2                	ld	s1,280(sp)
    80005172:	a03d                	j	800051a0 <sys_link+0xf4>
    iunlockput(dp);
    80005174:	854a                	mv	a0,s2
    80005176:	fbcfe0ef          	jal	80003932 <iunlockput>
  ilock(ip);
    8000517a:	8526                	mv	a0,s1
    8000517c:	dacfe0ef          	jal	80003728 <ilock>
  ip->nlink--;
    80005180:	04a4d783          	lhu	a5,74(s1)
    80005184:	37fd                	addiw	a5,a5,-1
    80005186:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000518a:	8526                	mv	a0,s1
    8000518c:	ce8fe0ef          	jal	80003674 <iupdate>
  iunlockput(ip);
    80005190:	8526                	mv	a0,s1
    80005192:	fa0fe0ef          	jal	80003932 <iunlockput>
  end_op();
    80005196:	eaffe0ef          	jal	80004044 <end_op>
  return -1;
    8000519a:	57fd                	li	a5,-1
    8000519c:	64f2                	ld	s1,280(sp)
    8000519e:	6952                	ld	s2,272(sp)
}
    800051a0:	853e                	mv	a0,a5
    800051a2:	70b2                	ld	ra,296(sp)
    800051a4:	7412                	ld	s0,288(sp)
    800051a6:	6155                	addi	sp,sp,304
    800051a8:	8082                	ret

00000000800051aa <sys_unlink>:
{
    800051aa:	7111                	addi	sp,sp,-256
    800051ac:	fd86                	sd	ra,248(sp)
    800051ae:	f9a2                	sd	s0,240(sp)
    800051b0:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    800051b2:	08000613          	li	a2,128
    800051b6:	f2040593          	addi	a1,s0,-224
    800051ba:	4501                	li	a0,0
    800051bc:	97bfd0ef          	jal	80002b36 <argstr>
    800051c0:	16054663          	bltz	a0,8000532c <sys_unlink+0x182>
    800051c4:	f5a6                	sd	s1,232(sp)
  begin_op();
    800051c6:	e15fe0ef          	jal	80003fda <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800051ca:	fa040593          	addi	a1,s0,-96
    800051ce:	f2040513          	addi	a0,s0,-224
    800051d2:	c61fe0ef          	jal	80003e32 <nameiparent>
    800051d6:	84aa                	mv	s1,a0
    800051d8:	c955                	beqz	a0,8000528c <sys_unlink+0xe2>
  ilock(dp);
    800051da:	d4efe0ef          	jal	80003728 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800051de:	00002597          	auipc	a1,0x2
    800051e2:	55258593          	addi	a1,a1,1362 # 80007730 <etext+0x730>
    800051e6:	fa040513          	addi	a0,s0,-96
    800051ea:	98dfe0ef          	jal	80003b76 <namecmp>
    800051ee:	12050463          	beqz	a0,80005316 <sys_unlink+0x16c>
    800051f2:	00002597          	auipc	a1,0x2
    800051f6:	54658593          	addi	a1,a1,1350 # 80007738 <etext+0x738>
    800051fa:	fa040513          	addi	a0,s0,-96
    800051fe:	979fe0ef          	jal	80003b76 <namecmp>
    80005202:	10050a63          	beqz	a0,80005316 <sys_unlink+0x16c>
    80005206:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005208:	f1c40613          	addi	a2,s0,-228
    8000520c:	fa040593          	addi	a1,s0,-96
    80005210:	8526                	mv	a0,s1
    80005212:	97bfe0ef          	jal	80003b8c <dirlookup>
    80005216:	892a                	mv	s2,a0
    80005218:	0e050e63          	beqz	a0,80005314 <sys_unlink+0x16a>
    8000521c:	edce                	sd	s3,216(sp)
  ilock(ip);
    8000521e:	d0afe0ef          	jal	80003728 <ilock>
  if(ip->nlink < 1)
    80005222:	04a91783          	lh	a5,74(s2)
    80005226:	06f05863          	blez	a5,80005296 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000522a:	04491703          	lh	a4,68(s2)
    8000522e:	4785                	li	a5,1
    80005230:	06f70b63          	beq	a4,a5,800052a6 <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    80005234:	fb040993          	addi	s3,s0,-80
    80005238:	4641                	li	a2,16
    8000523a:	4581                	li	a1,0
    8000523c:	854e                	mv	a0,s3
    8000523e:	a91fb0ef          	jal	80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005242:	4741                	li	a4,16
    80005244:	f1c42683          	lw	a3,-228(s0)
    80005248:	864e                	mv	a2,s3
    8000524a:	4581                	li	a1,0
    8000524c:	8526                	mv	a0,s1
    8000524e:	825fe0ef          	jal	80003a72 <writei>
    80005252:	47c1                	li	a5,16
    80005254:	08f51f63          	bne	a0,a5,800052f2 <sys_unlink+0x148>
  if(ip->type == T_DIR){
    80005258:	04491703          	lh	a4,68(s2)
    8000525c:	4785                	li	a5,1
    8000525e:	0af70263          	beq	a4,a5,80005302 <sys_unlink+0x158>
  iunlockput(dp);
    80005262:	8526                	mv	a0,s1
    80005264:	ecefe0ef          	jal	80003932 <iunlockput>
  ip->nlink--;
    80005268:	04a95783          	lhu	a5,74(s2)
    8000526c:	37fd                	addiw	a5,a5,-1
    8000526e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005272:	854a                	mv	a0,s2
    80005274:	c00fe0ef          	jal	80003674 <iupdate>
  iunlockput(ip);
    80005278:	854a                	mv	a0,s2
    8000527a:	eb8fe0ef          	jal	80003932 <iunlockput>
  end_op();
    8000527e:	dc7fe0ef          	jal	80004044 <end_op>
  return 0;
    80005282:	4501                	li	a0,0
    80005284:	74ae                	ld	s1,232(sp)
    80005286:	790e                	ld	s2,224(sp)
    80005288:	69ee                	ld	s3,216(sp)
    8000528a:	a869                	j	80005324 <sys_unlink+0x17a>
    end_op();
    8000528c:	db9fe0ef          	jal	80004044 <end_op>
    return -1;
    80005290:	557d                	li	a0,-1
    80005292:	74ae                	ld	s1,232(sp)
    80005294:	a841                	j	80005324 <sys_unlink+0x17a>
    80005296:	e9d2                	sd	s4,208(sp)
    80005298:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    8000529a:	00002517          	auipc	a0,0x2
    8000529e:	4a650513          	addi	a0,a0,1190 # 80007740 <etext+0x740>
    800052a2:	cfcfb0ef          	jal	8000079e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800052a6:	04c92703          	lw	a4,76(s2)
    800052aa:	02000793          	li	a5,32
    800052ae:	f8e7f3e3          	bgeu	a5,a4,80005234 <sys_unlink+0x8a>
    800052b2:	e9d2                	sd	s4,208(sp)
    800052b4:	e5d6                	sd	s5,200(sp)
    800052b6:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052b8:	f0840a93          	addi	s5,s0,-248
    800052bc:	4a41                	li	s4,16
    800052be:	8752                	mv	a4,s4
    800052c0:	86ce                	mv	a3,s3
    800052c2:	8656                	mv	a2,s5
    800052c4:	4581                	li	a1,0
    800052c6:	854a                	mv	a0,s2
    800052c8:	eb8fe0ef          	jal	80003980 <readi>
    800052cc:	01451d63          	bne	a0,s4,800052e6 <sys_unlink+0x13c>
    if(de.inum != 0)
    800052d0:	f0845783          	lhu	a5,-248(s0)
    800052d4:	efb1                	bnez	a5,80005330 <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800052d6:	29c1                	addiw	s3,s3,16
    800052d8:	04c92783          	lw	a5,76(s2)
    800052dc:	fef9e1e3          	bltu	s3,a5,800052be <sys_unlink+0x114>
    800052e0:	6a4e                	ld	s4,208(sp)
    800052e2:	6aae                	ld	s5,200(sp)
    800052e4:	bf81                	j	80005234 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800052e6:	00002517          	auipc	a0,0x2
    800052ea:	47250513          	addi	a0,a0,1138 # 80007758 <etext+0x758>
    800052ee:	cb0fb0ef          	jal	8000079e <panic>
    800052f2:	e9d2                	sd	s4,208(sp)
    800052f4:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    800052f6:	00002517          	auipc	a0,0x2
    800052fa:	47a50513          	addi	a0,a0,1146 # 80007770 <etext+0x770>
    800052fe:	ca0fb0ef          	jal	8000079e <panic>
    dp->nlink--;
    80005302:	04a4d783          	lhu	a5,74(s1)
    80005306:	37fd                	addiw	a5,a5,-1
    80005308:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000530c:	8526                	mv	a0,s1
    8000530e:	b66fe0ef          	jal	80003674 <iupdate>
    80005312:	bf81                	j	80005262 <sys_unlink+0xb8>
    80005314:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80005316:	8526                	mv	a0,s1
    80005318:	e1afe0ef          	jal	80003932 <iunlockput>
  end_op();
    8000531c:	d29fe0ef          	jal	80004044 <end_op>
  return -1;
    80005320:	557d                	li	a0,-1
    80005322:	74ae                	ld	s1,232(sp)
}
    80005324:	70ee                	ld	ra,248(sp)
    80005326:	744e                	ld	s0,240(sp)
    80005328:	6111                	addi	sp,sp,256
    8000532a:	8082                	ret
    return -1;
    8000532c:	557d                	li	a0,-1
    8000532e:	bfdd                	j	80005324 <sys_unlink+0x17a>
    iunlockput(ip);
    80005330:	854a                	mv	a0,s2
    80005332:	e00fe0ef          	jal	80003932 <iunlockput>
    goto bad;
    80005336:	790e                	ld	s2,224(sp)
    80005338:	69ee                	ld	s3,216(sp)
    8000533a:	6a4e                	ld	s4,208(sp)
    8000533c:	6aae                	ld	s5,200(sp)
    8000533e:	bfe1                	j	80005316 <sys_unlink+0x16c>

0000000080005340 <sys_open>:

uint64
sys_open(void)
{
    80005340:	7131                	addi	sp,sp,-192
    80005342:	fd06                	sd	ra,184(sp)
    80005344:	f922                	sd	s0,176(sp)
    80005346:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005348:	f4c40593          	addi	a1,s0,-180
    8000534c:	4505                	li	a0,1
    8000534e:	fb0fd0ef          	jal	80002afe <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005352:	08000613          	li	a2,128
    80005356:	f5040593          	addi	a1,s0,-176
    8000535a:	4501                	li	a0,0
    8000535c:	fdafd0ef          	jal	80002b36 <argstr>
    80005360:	87aa                	mv	a5,a0
    return -1;
    80005362:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005364:	0a07c363          	bltz	a5,8000540a <sys_open+0xca>
    80005368:	f526                	sd	s1,168(sp)

  begin_op();
    8000536a:	c71fe0ef          	jal	80003fda <begin_op>

  if(omode & O_CREATE){
    8000536e:	f4c42783          	lw	a5,-180(s0)
    80005372:	2007f793          	andi	a5,a5,512
    80005376:	c3dd                	beqz	a5,8000541c <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005378:	4681                	li	a3,0
    8000537a:	4601                	li	a2,0
    8000537c:	4589                	li	a1,2
    8000537e:	f5040513          	addi	a0,s0,-176
    80005382:	a99ff0ef          	jal	80004e1a <create>
    80005386:	84aa                	mv	s1,a0
    if(ip == 0){
    80005388:	c549                	beqz	a0,80005412 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000538a:	04449703          	lh	a4,68(s1)
    8000538e:	478d                	li	a5,3
    80005390:	00f71763          	bne	a4,a5,8000539e <sys_open+0x5e>
    80005394:	0464d703          	lhu	a4,70(s1)
    80005398:	47a5                	li	a5,9
    8000539a:	0ae7ee63          	bltu	a5,a4,80005456 <sys_open+0x116>
    8000539e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800053a0:	fb7fe0ef          	jal	80004356 <filealloc>
    800053a4:	892a                	mv	s2,a0
    800053a6:	c561                	beqz	a0,8000546e <sys_open+0x12e>
    800053a8:	ed4e                	sd	s3,152(sp)
    800053aa:	a33ff0ef          	jal	80004ddc <fdalloc>
    800053ae:	89aa                	mv	s3,a0
    800053b0:	0a054b63          	bltz	a0,80005466 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800053b4:	04449703          	lh	a4,68(s1)
    800053b8:	478d                	li	a5,3
    800053ba:	0cf70363          	beq	a4,a5,80005480 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800053be:	4789                	li	a5,2
    800053c0:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800053c4:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800053c8:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800053cc:	f4c42783          	lw	a5,-180(s0)
    800053d0:	0017f713          	andi	a4,a5,1
    800053d4:	00174713          	xori	a4,a4,1
    800053d8:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800053dc:	0037f713          	andi	a4,a5,3
    800053e0:	00e03733          	snez	a4,a4
    800053e4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800053e8:	4007f793          	andi	a5,a5,1024
    800053ec:	c791                	beqz	a5,800053f8 <sys_open+0xb8>
    800053ee:	04449703          	lh	a4,68(s1)
    800053f2:	4789                	li	a5,2
    800053f4:	08f70d63          	beq	a4,a5,8000548e <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800053f8:	8526                	mv	a0,s1
    800053fa:	bdcfe0ef          	jal	800037d6 <iunlock>
  end_op();
    800053fe:	c47fe0ef          	jal	80004044 <end_op>

  return fd;
    80005402:	854e                	mv	a0,s3
    80005404:	74aa                	ld	s1,168(sp)
    80005406:	790a                	ld	s2,160(sp)
    80005408:	69ea                	ld	s3,152(sp)
}
    8000540a:	70ea                	ld	ra,184(sp)
    8000540c:	744a                	ld	s0,176(sp)
    8000540e:	6129                	addi	sp,sp,192
    80005410:	8082                	ret
      end_op();
    80005412:	c33fe0ef          	jal	80004044 <end_op>
      return -1;
    80005416:	557d                	li	a0,-1
    80005418:	74aa                	ld	s1,168(sp)
    8000541a:	bfc5                	j	8000540a <sys_open+0xca>
    if((ip = namei(path)) == 0){
    8000541c:	f5040513          	addi	a0,s0,-176
    80005420:	9f9fe0ef          	jal	80003e18 <namei>
    80005424:	84aa                	mv	s1,a0
    80005426:	c11d                	beqz	a0,8000544c <sys_open+0x10c>
    ilock(ip);
    80005428:	b00fe0ef          	jal	80003728 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000542c:	04449703          	lh	a4,68(s1)
    80005430:	4785                	li	a5,1
    80005432:	f4f71ce3          	bne	a4,a5,8000538a <sys_open+0x4a>
    80005436:	f4c42783          	lw	a5,-180(s0)
    8000543a:	d3b5                	beqz	a5,8000539e <sys_open+0x5e>
      iunlockput(ip);
    8000543c:	8526                	mv	a0,s1
    8000543e:	cf4fe0ef          	jal	80003932 <iunlockput>
      end_op();
    80005442:	c03fe0ef          	jal	80004044 <end_op>
      return -1;
    80005446:	557d                	li	a0,-1
    80005448:	74aa                	ld	s1,168(sp)
    8000544a:	b7c1                	j	8000540a <sys_open+0xca>
      end_op();
    8000544c:	bf9fe0ef          	jal	80004044 <end_op>
      return -1;
    80005450:	557d                	li	a0,-1
    80005452:	74aa                	ld	s1,168(sp)
    80005454:	bf5d                	j	8000540a <sys_open+0xca>
    iunlockput(ip);
    80005456:	8526                	mv	a0,s1
    80005458:	cdafe0ef          	jal	80003932 <iunlockput>
    end_op();
    8000545c:	be9fe0ef          	jal	80004044 <end_op>
    return -1;
    80005460:	557d                	li	a0,-1
    80005462:	74aa                	ld	s1,168(sp)
    80005464:	b75d                	j	8000540a <sys_open+0xca>
      fileclose(f);
    80005466:	854a                	mv	a0,s2
    80005468:	f93fe0ef          	jal	800043fa <fileclose>
    8000546c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000546e:	8526                	mv	a0,s1
    80005470:	cc2fe0ef          	jal	80003932 <iunlockput>
    end_op();
    80005474:	bd1fe0ef          	jal	80004044 <end_op>
    return -1;
    80005478:	557d                	li	a0,-1
    8000547a:	74aa                	ld	s1,168(sp)
    8000547c:	790a                	ld	s2,160(sp)
    8000547e:	b771                	j	8000540a <sys_open+0xca>
    f->type = FD_DEVICE;
    80005480:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005484:	04649783          	lh	a5,70(s1)
    80005488:	02f91223          	sh	a5,36(s2)
    8000548c:	bf35                	j	800053c8 <sys_open+0x88>
    itrunc(ip);
    8000548e:	8526                	mv	a0,s1
    80005490:	b86fe0ef          	jal	80003816 <itrunc>
    80005494:	b795                	j	800053f8 <sys_open+0xb8>

0000000080005496 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005496:	7175                	addi	sp,sp,-144
    80005498:	e506                	sd	ra,136(sp)
    8000549a:	e122                	sd	s0,128(sp)
    8000549c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000549e:	b3dfe0ef          	jal	80003fda <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800054a2:	08000613          	li	a2,128
    800054a6:	f7040593          	addi	a1,s0,-144
    800054aa:	4501                	li	a0,0
    800054ac:	e8afd0ef          	jal	80002b36 <argstr>
    800054b0:	02054363          	bltz	a0,800054d6 <sys_mkdir+0x40>
    800054b4:	4681                	li	a3,0
    800054b6:	4601                	li	a2,0
    800054b8:	4585                	li	a1,1
    800054ba:	f7040513          	addi	a0,s0,-144
    800054be:	95dff0ef          	jal	80004e1a <create>
    800054c2:	c911                	beqz	a0,800054d6 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054c4:	c6efe0ef          	jal	80003932 <iunlockput>
  end_op();
    800054c8:	b7dfe0ef          	jal	80004044 <end_op>
  return 0;
    800054cc:	4501                	li	a0,0
}
    800054ce:	60aa                	ld	ra,136(sp)
    800054d0:	640a                	ld	s0,128(sp)
    800054d2:	6149                	addi	sp,sp,144
    800054d4:	8082                	ret
    end_op();
    800054d6:	b6ffe0ef          	jal	80004044 <end_op>
    return -1;
    800054da:	557d                	li	a0,-1
    800054dc:	bfcd                	j	800054ce <sys_mkdir+0x38>

00000000800054de <sys_mknod>:

uint64
sys_mknod(void)
{
    800054de:	7135                	addi	sp,sp,-160
    800054e0:	ed06                	sd	ra,152(sp)
    800054e2:	e922                	sd	s0,144(sp)
    800054e4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800054e6:	af5fe0ef          	jal	80003fda <begin_op>
  argint(1, &major);
    800054ea:	f6c40593          	addi	a1,s0,-148
    800054ee:	4505                	li	a0,1
    800054f0:	e0efd0ef          	jal	80002afe <argint>
  argint(2, &minor);
    800054f4:	f6840593          	addi	a1,s0,-152
    800054f8:	4509                	li	a0,2
    800054fa:	e04fd0ef          	jal	80002afe <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800054fe:	08000613          	li	a2,128
    80005502:	f7040593          	addi	a1,s0,-144
    80005506:	4501                	li	a0,0
    80005508:	e2efd0ef          	jal	80002b36 <argstr>
    8000550c:	02054563          	bltz	a0,80005536 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005510:	f6841683          	lh	a3,-152(s0)
    80005514:	f6c41603          	lh	a2,-148(s0)
    80005518:	458d                	li	a1,3
    8000551a:	f7040513          	addi	a0,s0,-144
    8000551e:	8fdff0ef          	jal	80004e1a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005522:	c911                	beqz	a0,80005536 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005524:	c0efe0ef          	jal	80003932 <iunlockput>
  end_op();
    80005528:	b1dfe0ef          	jal	80004044 <end_op>
  return 0;
    8000552c:	4501                	li	a0,0
}
    8000552e:	60ea                	ld	ra,152(sp)
    80005530:	644a                	ld	s0,144(sp)
    80005532:	610d                	addi	sp,sp,160
    80005534:	8082                	ret
    end_op();
    80005536:	b0ffe0ef          	jal	80004044 <end_op>
    return -1;
    8000553a:	557d                	li	a0,-1
    8000553c:	bfcd                	j	8000552e <sys_mknod+0x50>

000000008000553e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000553e:	7135                	addi	sp,sp,-160
    80005540:	ed06                	sd	ra,152(sp)
    80005542:	e922                	sd	s0,144(sp)
    80005544:	e14a                	sd	s2,128(sp)
    80005546:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005548:	b94fc0ef          	jal	800018dc <myproc>
    8000554c:	892a                	mv	s2,a0
  
  begin_op();
    8000554e:	a8dfe0ef          	jal	80003fda <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005552:	08000613          	li	a2,128
    80005556:	f6040593          	addi	a1,s0,-160
    8000555a:	4501                	li	a0,0
    8000555c:	ddafd0ef          	jal	80002b36 <argstr>
    80005560:	04054363          	bltz	a0,800055a6 <sys_chdir+0x68>
    80005564:	e526                	sd	s1,136(sp)
    80005566:	f6040513          	addi	a0,s0,-160
    8000556a:	8affe0ef          	jal	80003e18 <namei>
    8000556e:	84aa                	mv	s1,a0
    80005570:	c915                	beqz	a0,800055a4 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005572:	9b6fe0ef          	jal	80003728 <ilock>
  if(ip->type != T_DIR){
    80005576:	04449703          	lh	a4,68(s1)
    8000557a:	4785                	li	a5,1
    8000557c:	02f71963          	bne	a4,a5,800055ae <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005580:	8526                	mv	a0,s1
    80005582:	a54fe0ef          	jal	800037d6 <iunlock>
  iput(p->cwd);
    80005586:	15093503          	ld	a0,336(s2)
    8000558a:	b20fe0ef          	jal	800038aa <iput>
  end_op();
    8000558e:	ab7fe0ef          	jal	80004044 <end_op>
  p->cwd = ip;
    80005592:	14993823          	sd	s1,336(s2)
  return 0;
    80005596:	4501                	li	a0,0
    80005598:	64aa                	ld	s1,136(sp)
}
    8000559a:	60ea                	ld	ra,152(sp)
    8000559c:	644a                	ld	s0,144(sp)
    8000559e:	690a                	ld	s2,128(sp)
    800055a0:	610d                	addi	sp,sp,160
    800055a2:	8082                	ret
    800055a4:	64aa                	ld	s1,136(sp)
    end_op();
    800055a6:	a9ffe0ef          	jal	80004044 <end_op>
    return -1;
    800055aa:	557d                	li	a0,-1
    800055ac:	b7fd                	j	8000559a <sys_chdir+0x5c>
    iunlockput(ip);
    800055ae:	8526                	mv	a0,s1
    800055b0:	b82fe0ef          	jal	80003932 <iunlockput>
    end_op();
    800055b4:	a91fe0ef          	jal	80004044 <end_op>
    return -1;
    800055b8:	557d                	li	a0,-1
    800055ba:	64aa                	ld	s1,136(sp)
    800055bc:	bff9                	j	8000559a <sys_chdir+0x5c>

00000000800055be <sys_exec>:

uint64
sys_exec(void)
{
    800055be:	7105                	addi	sp,sp,-480
    800055c0:	ef86                	sd	ra,472(sp)
    800055c2:	eba2                	sd	s0,464(sp)
    800055c4:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800055c6:	e2840593          	addi	a1,s0,-472
    800055ca:	4505                	li	a0,1
    800055cc:	d4efd0ef          	jal	80002b1a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800055d0:	08000613          	li	a2,128
    800055d4:	f3040593          	addi	a1,s0,-208
    800055d8:	4501                	li	a0,0
    800055da:	d5cfd0ef          	jal	80002b36 <argstr>
    800055de:	87aa                	mv	a5,a0
    return -1;
    800055e0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800055e2:	0e07c063          	bltz	a5,800056c2 <sys_exec+0x104>
    800055e6:	e7a6                	sd	s1,456(sp)
    800055e8:	e3ca                	sd	s2,448(sp)
    800055ea:	ff4e                	sd	s3,440(sp)
    800055ec:	fb52                	sd	s4,432(sp)
    800055ee:	f756                	sd	s5,424(sp)
    800055f0:	f35a                	sd	s6,416(sp)
    800055f2:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800055f4:	e3040a13          	addi	s4,s0,-464
    800055f8:	10000613          	li	a2,256
    800055fc:	4581                	li	a1,0
    800055fe:	8552                	mv	a0,s4
    80005600:	ecefb0ef          	jal	80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005604:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005606:	89d2                	mv	s3,s4
    80005608:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000560a:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000560e:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005610:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005614:	00391513          	slli	a0,s2,0x3
    80005618:	85d6                	mv	a1,s5
    8000561a:	e2843783          	ld	a5,-472(s0)
    8000561e:	953e                	add	a0,a0,a5
    80005620:	c54fd0ef          	jal	80002a74 <fetchaddr>
    80005624:	02054663          	bltz	a0,80005650 <sys_exec+0x92>
    if(uarg == 0){
    80005628:	e2043783          	ld	a5,-480(s0)
    8000562c:	c7a1                	beqz	a5,80005674 <sys_exec+0xb6>
    argv[i] = kalloc();
    8000562e:	cfcfb0ef          	jal	80000b2a <kalloc>
    80005632:	85aa                	mv	a1,a0
    80005634:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005638:	cd01                	beqz	a0,80005650 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000563a:	865a                	mv	a2,s6
    8000563c:	e2043503          	ld	a0,-480(s0)
    80005640:	c7efd0ef          	jal	80002abe <fetchstr>
    80005644:	00054663          	bltz	a0,80005650 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005648:	0905                	addi	s2,s2,1
    8000564a:	09a1                	addi	s3,s3,8
    8000564c:	fd7914e3          	bne	s2,s7,80005614 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005650:	100a0a13          	addi	s4,s4,256
    80005654:	6088                	ld	a0,0(s1)
    80005656:	cd31                	beqz	a0,800056b2 <sys_exec+0xf4>
    kfree(argv[i]);
    80005658:	bf0fb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000565c:	04a1                	addi	s1,s1,8
    8000565e:	ff449be3          	bne	s1,s4,80005654 <sys_exec+0x96>
  return -1;
    80005662:	557d                	li	a0,-1
    80005664:	64be                	ld	s1,456(sp)
    80005666:	691e                	ld	s2,448(sp)
    80005668:	79fa                	ld	s3,440(sp)
    8000566a:	7a5a                	ld	s4,432(sp)
    8000566c:	7aba                	ld	s5,424(sp)
    8000566e:	7b1a                	ld	s6,416(sp)
    80005670:	6bfa                	ld	s7,408(sp)
    80005672:	a881                	j	800056c2 <sys_exec+0x104>
      argv[i] = 0;
    80005674:	0009079b          	sext.w	a5,s2
    80005678:	e3040593          	addi	a1,s0,-464
    8000567c:	078e                	slli	a5,a5,0x3
    8000567e:	97ae                	add	a5,a5,a1
    80005680:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80005684:	f3040513          	addi	a0,s0,-208
    80005688:	ba4ff0ef          	jal	80004a2c <exec>
    8000568c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000568e:	100a0a13          	addi	s4,s4,256
    80005692:	6088                	ld	a0,0(s1)
    80005694:	c511                	beqz	a0,800056a0 <sys_exec+0xe2>
    kfree(argv[i]);
    80005696:	bb2fb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000569a:	04a1                	addi	s1,s1,8
    8000569c:	ff449be3          	bne	s1,s4,80005692 <sys_exec+0xd4>
  return ret;
    800056a0:	854a                	mv	a0,s2
    800056a2:	64be                	ld	s1,456(sp)
    800056a4:	691e                	ld	s2,448(sp)
    800056a6:	79fa                	ld	s3,440(sp)
    800056a8:	7a5a                	ld	s4,432(sp)
    800056aa:	7aba                	ld	s5,424(sp)
    800056ac:	7b1a                	ld	s6,416(sp)
    800056ae:	6bfa                	ld	s7,408(sp)
    800056b0:	a809                	j	800056c2 <sys_exec+0x104>
  return -1;
    800056b2:	557d                	li	a0,-1
    800056b4:	64be                	ld	s1,456(sp)
    800056b6:	691e                	ld	s2,448(sp)
    800056b8:	79fa                	ld	s3,440(sp)
    800056ba:	7a5a                	ld	s4,432(sp)
    800056bc:	7aba                	ld	s5,424(sp)
    800056be:	7b1a                	ld	s6,416(sp)
    800056c0:	6bfa                	ld	s7,408(sp)
}
    800056c2:	60fe                	ld	ra,472(sp)
    800056c4:	645e                	ld	s0,464(sp)
    800056c6:	613d                	addi	sp,sp,480
    800056c8:	8082                	ret

00000000800056ca <sys_pipe>:

uint64
sys_pipe(void)
{
    800056ca:	7139                	addi	sp,sp,-64
    800056cc:	fc06                	sd	ra,56(sp)
    800056ce:	f822                	sd	s0,48(sp)
    800056d0:	f426                	sd	s1,40(sp)
    800056d2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800056d4:	a08fc0ef          	jal	800018dc <myproc>
    800056d8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800056da:	fd840593          	addi	a1,s0,-40
    800056de:	4501                	li	a0,0
    800056e0:	c3afd0ef          	jal	80002b1a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800056e4:	fc840593          	addi	a1,s0,-56
    800056e8:	fd040513          	addi	a0,s0,-48
    800056ec:	81eff0ef          	jal	8000470a <pipealloc>
    return -1;
    800056f0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800056f2:	0a054463          	bltz	a0,8000579a <sys_pipe+0xd0>
  fd0 = -1;
    800056f6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800056fa:	fd043503          	ld	a0,-48(s0)
    800056fe:	edeff0ef          	jal	80004ddc <fdalloc>
    80005702:	fca42223          	sw	a0,-60(s0)
    80005706:	08054163          	bltz	a0,80005788 <sys_pipe+0xbe>
    8000570a:	fc843503          	ld	a0,-56(s0)
    8000570e:	eceff0ef          	jal	80004ddc <fdalloc>
    80005712:	fca42023          	sw	a0,-64(s0)
    80005716:	06054063          	bltz	a0,80005776 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000571a:	4691                	li	a3,4
    8000571c:	fc440613          	addi	a2,s0,-60
    80005720:	fd843583          	ld	a1,-40(s0)
    80005724:	68a8                	ld	a0,80(s1)
    80005726:	e5ffb0ef          	jal	80001584 <copyout>
    8000572a:	00054e63          	bltz	a0,80005746 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000572e:	4691                	li	a3,4
    80005730:	fc040613          	addi	a2,s0,-64
    80005734:	fd843583          	ld	a1,-40(s0)
    80005738:	95b6                	add	a1,a1,a3
    8000573a:	68a8                	ld	a0,80(s1)
    8000573c:	e49fb0ef          	jal	80001584 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005740:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005742:	04055c63          	bgez	a0,8000579a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005746:	fc442783          	lw	a5,-60(s0)
    8000574a:	07e9                	addi	a5,a5,26
    8000574c:	078e                	slli	a5,a5,0x3
    8000574e:	97a6                	add	a5,a5,s1
    80005750:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005754:	fc042783          	lw	a5,-64(s0)
    80005758:	07e9                	addi	a5,a5,26
    8000575a:	078e                	slli	a5,a5,0x3
    8000575c:	94be                	add	s1,s1,a5
    8000575e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005762:	fd043503          	ld	a0,-48(s0)
    80005766:	c95fe0ef          	jal	800043fa <fileclose>
    fileclose(wf);
    8000576a:	fc843503          	ld	a0,-56(s0)
    8000576e:	c8dfe0ef          	jal	800043fa <fileclose>
    return -1;
    80005772:	57fd                	li	a5,-1
    80005774:	a01d                	j	8000579a <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005776:	fc442783          	lw	a5,-60(s0)
    8000577a:	0007c763          	bltz	a5,80005788 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000577e:	07e9                	addi	a5,a5,26
    80005780:	078e                	slli	a5,a5,0x3
    80005782:	97a6                	add	a5,a5,s1
    80005784:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005788:	fd043503          	ld	a0,-48(s0)
    8000578c:	c6ffe0ef          	jal	800043fa <fileclose>
    fileclose(wf);
    80005790:	fc843503          	ld	a0,-56(s0)
    80005794:	c67fe0ef          	jal	800043fa <fileclose>
    return -1;
    80005798:	57fd                	li	a5,-1
}
    8000579a:	853e                	mv	a0,a5
    8000579c:	70e2                	ld	ra,56(sp)
    8000579e:	7442                	ld	s0,48(sp)
    800057a0:	74a2                	ld	s1,40(sp)
    800057a2:	6121                	addi	sp,sp,64
    800057a4:	8082                	ret
	...

00000000800057b0 <kernelvec>:
    800057b0:	7111                	addi	sp,sp,-256
    800057b2:	e006                	sd	ra,0(sp)
    800057b4:	e40a                	sd	sp,8(sp)
    800057b6:	e80e                	sd	gp,16(sp)
    800057b8:	ec12                	sd	tp,24(sp)
    800057ba:	f016                	sd	t0,32(sp)
    800057bc:	f41a                	sd	t1,40(sp)
    800057be:	f81e                	sd	t2,48(sp)
    800057c0:	e4aa                	sd	a0,72(sp)
    800057c2:	e8ae                	sd	a1,80(sp)
    800057c4:	ecb2                	sd	a2,88(sp)
    800057c6:	f0b6                	sd	a3,96(sp)
    800057c8:	f4ba                	sd	a4,104(sp)
    800057ca:	f8be                	sd	a5,112(sp)
    800057cc:	fcc2                	sd	a6,120(sp)
    800057ce:	e146                	sd	a7,128(sp)
    800057d0:	edf2                	sd	t3,216(sp)
    800057d2:	f1f6                	sd	t4,224(sp)
    800057d4:	f5fa                	sd	t5,232(sp)
    800057d6:	f9fe                	sd	t6,240(sp)
    800057d8:	9acfd0ef          	jal	80002984 <kerneltrap>
    800057dc:	6082                	ld	ra,0(sp)
    800057de:	6122                	ld	sp,8(sp)
    800057e0:	61c2                	ld	gp,16(sp)
    800057e2:	7282                	ld	t0,32(sp)
    800057e4:	7322                	ld	t1,40(sp)
    800057e6:	73c2                	ld	t2,48(sp)
    800057e8:	6526                	ld	a0,72(sp)
    800057ea:	65c6                	ld	a1,80(sp)
    800057ec:	6666                	ld	a2,88(sp)
    800057ee:	7686                	ld	a3,96(sp)
    800057f0:	7726                	ld	a4,104(sp)
    800057f2:	77c6                	ld	a5,112(sp)
    800057f4:	7866                	ld	a6,120(sp)
    800057f6:	688a                	ld	a7,128(sp)
    800057f8:	6e6e                	ld	t3,216(sp)
    800057fa:	7e8e                	ld	t4,224(sp)
    800057fc:	7f2e                	ld	t5,232(sp)
    800057fe:	7fce                	ld	t6,240(sp)
    80005800:	6111                	addi	sp,sp,256
    80005802:	10200073          	sret
	...

000000008000580e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000580e:	1141                	addi	sp,sp,-16
    80005810:	e406                	sd	ra,8(sp)
    80005812:	e022                	sd	s0,0(sp)
    80005814:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005816:	0c000737          	lui	a4,0xc000
    8000581a:	4785                	li	a5,1
    8000581c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000581e:	c35c                	sw	a5,4(a4)
}
    80005820:	60a2                	ld	ra,8(sp)
    80005822:	6402                	ld	s0,0(sp)
    80005824:	0141                	addi	sp,sp,16
    80005826:	8082                	ret

0000000080005828 <plicinithart>:

void
plicinithart(void)
{
    80005828:	1141                	addi	sp,sp,-16
    8000582a:	e406                	sd	ra,8(sp)
    8000582c:	e022                	sd	s0,0(sp)
    8000582e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005830:	878fc0ef          	jal	800018a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005834:	0085171b          	slliw	a4,a0,0x8
    80005838:	0c0027b7          	lui	a5,0xc002
    8000583c:	97ba                	add	a5,a5,a4
    8000583e:	40200713          	li	a4,1026
    80005842:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005846:	00d5151b          	slliw	a0,a0,0xd
    8000584a:	0c2017b7          	lui	a5,0xc201
    8000584e:	97aa                	add	a5,a5,a0
    80005850:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005854:	60a2                	ld	ra,8(sp)
    80005856:	6402                	ld	s0,0(sp)
    80005858:	0141                	addi	sp,sp,16
    8000585a:	8082                	ret

000000008000585c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000585c:	1141                	addi	sp,sp,-16
    8000585e:	e406                	sd	ra,8(sp)
    80005860:	e022                	sd	s0,0(sp)
    80005862:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005864:	844fc0ef          	jal	800018a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005868:	00d5151b          	slliw	a0,a0,0xd
    8000586c:	0c2017b7          	lui	a5,0xc201
    80005870:	97aa                	add	a5,a5,a0
  return irq;
}
    80005872:	43c8                	lw	a0,4(a5)
    80005874:	60a2                	ld	ra,8(sp)
    80005876:	6402                	ld	s0,0(sp)
    80005878:	0141                	addi	sp,sp,16
    8000587a:	8082                	ret

000000008000587c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000587c:	1101                	addi	sp,sp,-32
    8000587e:	ec06                	sd	ra,24(sp)
    80005880:	e822                	sd	s0,16(sp)
    80005882:	e426                	sd	s1,8(sp)
    80005884:	1000                	addi	s0,sp,32
    80005886:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005888:	820fc0ef          	jal	800018a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000588c:	00d5179b          	slliw	a5,a0,0xd
    80005890:	0c201737          	lui	a4,0xc201
    80005894:	97ba                	add	a5,a5,a4
    80005896:	c3c4                	sw	s1,4(a5)
}
    80005898:	60e2                	ld	ra,24(sp)
    8000589a:	6442                	ld	s0,16(sp)
    8000589c:	64a2                	ld	s1,8(sp)
    8000589e:	6105                	addi	sp,sp,32
    800058a0:	8082                	ret

00000000800058a2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800058a2:	1141                	addi	sp,sp,-16
    800058a4:	e406                	sd	ra,8(sp)
    800058a6:	e022                	sd	s0,0(sp)
    800058a8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800058aa:	479d                	li	a5,7
    800058ac:	04a7ca63          	blt	a5,a0,80005900 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800058b0:	00025797          	auipc	a5,0x25
    800058b4:	04078793          	addi	a5,a5,64 # 8002a8f0 <disk>
    800058b8:	97aa                	add	a5,a5,a0
    800058ba:	0187c783          	lbu	a5,24(a5)
    800058be:	e7b9                	bnez	a5,8000590c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800058c0:	00451693          	slli	a3,a0,0x4
    800058c4:	00025797          	auipc	a5,0x25
    800058c8:	02c78793          	addi	a5,a5,44 # 8002a8f0 <disk>
    800058cc:	6398                	ld	a4,0(a5)
    800058ce:	9736                	add	a4,a4,a3
    800058d0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800058d4:	6398                	ld	a4,0(a5)
    800058d6:	9736                	add	a4,a4,a3
    800058d8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800058dc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800058e0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800058e4:	97aa                	add	a5,a5,a0
    800058e6:	4705                	li	a4,1
    800058e8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800058ec:	00025517          	auipc	a0,0x25
    800058f0:	01c50513          	addi	a0,a0,28 # 8002a908 <disk+0x18>
    800058f4:	973fc0ef          	jal	80002266 <wakeup>
}
    800058f8:	60a2                	ld	ra,8(sp)
    800058fa:	6402                	ld	s0,0(sp)
    800058fc:	0141                	addi	sp,sp,16
    800058fe:	8082                	ret
    panic("free_desc 1");
    80005900:	00002517          	auipc	a0,0x2
    80005904:	e8050513          	addi	a0,a0,-384 # 80007780 <etext+0x780>
    80005908:	e97fa0ef          	jal	8000079e <panic>
    panic("free_desc 2");
    8000590c:	00002517          	auipc	a0,0x2
    80005910:	e8450513          	addi	a0,a0,-380 # 80007790 <etext+0x790>
    80005914:	e8bfa0ef          	jal	8000079e <panic>

0000000080005918 <virtio_disk_init>:
{
    80005918:	1101                	addi	sp,sp,-32
    8000591a:	ec06                	sd	ra,24(sp)
    8000591c:	e822                	sd	s0,16(sp)
    8000591e:	e426                	sd	s1,8(sp)
    80005920:	e04a                	sd	s2,0(sp)
    80005922:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005924:	00002597          	auipc	a1,0x2
    80005928:	e7c58593          	addi	a1,a1,-388 # 800077a0 <etext+0x7a0>
    8000592c:	00025517          	auipc	a0,0x25
    80005930:	0ec50513          	addi	a0,a0,236 # 8002aa18 <disk+0x128>
    80005934:	a46fb0ef          	jal	80000b7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005938:	100017b7          	lui	a5,0x10001
    8000593c:	4398                	lw	a4,0(a5)
    8000593e:	2701                	sext.w	a4,a4
    80005940:	747277b7          	lui	a5,0x74727
    80005944:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005948:	14f71863          	bne	a4,a5,80005a98 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000594c:	100017b7          	lui	a5,0x10001
    80005950:	43dc                	lw	a5,4(a5)
    80005952:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005954:	4709                	li	a4,2
    80005956:	14e79163          	bne	a5,a4,80005a98 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000595a:	100017b7          	lui	a5,0x10001
    8000595e:	479c                	lw	a5,8(a5)
    80005960:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005962:	12e79b63          	bne	a5,a4,80005a98 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005966:	100017b7          	lui	a5,0x10001
    8000596a:	47d8                	lw	a4,12(a5)
    8000596c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000596e:	554d47b7          	lui	a5,0x554d4
    80005972:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005976:	12f71163          	bne	a4,a5,80005a98 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000597a:	100017b7          	lui	a5,0x10001
    8000597e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005982:	4705                	li	a4,1
    80005984:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005986:	470d                	li	a4,3
    80005988:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000598a:	10001737          	lui	a4,0x10001
    8000598e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005990:	c7ffe6b7          	lui	a3,0xc7ffe
    80005994:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd3d2f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005998:	8f75                	and	a4,a4,a3
    8000599a:	100016b7          	lui	a3,0x10001
    8000599e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059a0:	472d                	li	a4,11
    800059a2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059a4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800059a8:	439c                	lw	a5,0(a5)
    800059aa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800059ae:	8ba1                	andi	a5,a5,8
    800059b0:	0e078a63          	beqz	a5,80005aa4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800059b4:	100017b7          	lui	a5,0x10001
    800059b8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800059bc:	43fc                	lw	a5,68(a5)
    800059be:	2781                	sext.w	a5,a5
    800059c0:	0e079863          	bnez	a5,80005ab0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800059c4:	100017b7          	lui	a5,0x10001
    800059c8:	5bdc                	lw	a5,52(a5)
    800059ca:	2781                	sext.w	a5,a5
  if(max == 0)
    800059cc:	0e078863          	beqz	a5,80005abc <virtio_disk_init+0x1a4>
  if(max < NUM)
    800059d0:	471d                	li	a4,7
    800059d2:	0ef77b63          	bgeu	a4,a5,80005ac8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800059d6:	954fb0ef          	jal	80000b2a <kalloc>
    800059da:	00025497          	auipc	s1,0x25
    800059de:	f1648493          	addi	s1,s1,-234 # 8002a8f0 <disk>
    800059e2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800059e4:	946fb0ef          	jal	80000b2a <kalloc>
    800059e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800059ea:	940fb0ef          	jal	80000b2a <kalloc>
    800059ee:	87aa                	mv	a5,a0
    800059f0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800059f2:	6088                	ld	a0,0(s1)
    800059f4:	0e050063          	beqz	a0,80005ad4 <virtio_disk_init+0x1bc>
    800059f8:	00025717          	auipc	a4,0x25
    800059fc:	f0073703          	ld	a4,-256(a4) # 8002a8f8 <disk+0x8>
    80005a00:	cb71                	beqz	a4,80005ad4 <virtio_disk_init+0x1bc>
    80005a02:	cbe9                	beqz	a5,80005ad4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005a04:	6605                	lui	a2,0x1
    80005a06:	4581                	li	a1,0
    80005a08:	ac6fb0ef          	jal	80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005a0c:	00025497          	auipc	s1,0x25
    80005a10:	ee448493          	addi	s1,s1,-284 # 8002a8f0 <disk>
    80005a14:	6605                	lui	a2,0x1
    80005a16:	4581                	li	a1,0
    80005a18:	6488                	ld	a0,8(s1)
    80005a1a:	ab4fb0ef          	jal	80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005a1e:	6605                	lui	a2,0x1
    80005a20:	4581                	li	a1,0
    80005a22:	6888                	ld	a0,16(s1)
    80005a24:	aaafb0ef          	jal	80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a28:	100017b7          	lui	a5,0x10001
    80005a2c:	4721                	li	a4,8
    80005a2e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a30:	4098                	lw	a4,0(s1)
    80005a32:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a36:	40d8                	lw	a4,4(s1)
    80005a38:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a3c:	649c                	ld	a5,8(s1)
    80005a3e:	0007869b          	sext.w	a3,a5
    80005a42:	10001737          	lui	a4,0x10001
    80005a46:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a4a:	9781                	srai	a5,a5,0x20
    80005a4c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a50:	689c                	ld	a5,16(s1)
    80005a52:	0007869b          	sext.w	a3,a5
    80005a56:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a5a:	9781                	srai	a5,a5,0x20
    80005a5c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a60:	4785                	li	a5,1
    80005a62:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a64:	00f48c23          	sb	a5,24(s1)
    80005a68:	00f48ca3          	sb	a5,25(s1)
    80005a6c:	00f48d23          	sb	a5,26(s1)
    80005a70:	00f48da3          	sb	a5,27(s1)
    80005a74:	00f48e23          	sb	a5,28(s1)
    80005a78:	00f48ea3          	sb	a5,29(s1)
    80005a7c:	00f48f23          	sb	a5,30(s1)
    80005a80:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a84:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a88:	07272823          	sw	s2,112(a4)
}
    80005a8c:	60e2                	ld	ra,24(sp)
    80005a8e:	6442                	ld	s0,16(sp)
    80005a90:	64a2                	ld	s1,8(sp)
    80005a92:	6902                	ld	s2,0(sp)
    80005a94:	6105                	addi	sp,sp,32
    80005a96:	8082                	ret
    panic("could not find virtio disk");
    80005a98:	00002517          	auipc	a0,0x2
    80005a9c:	d1850513          	addi	a0,a0,-744 # 800077b0 <etext+0x7b0>
    80005aa0:	cfffa0ef          	jal	8000079e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005aa4:	00002517          	auipc	a0,0x2
    80005aa8:	d2c50513          	addi	a0,a0,-724 # 800077d0 <etext+0x7d0>
    80005aac:	cf3fa0ef          	jal	8000079e <panic>
    panic("virtio disk should not be ready");
    80005ab0:	00002517          	auipc	a0,0x2
    80005ab4:	d4050513          	addi	a0,a0,-704 # 800077f0 <etext+0x7f0>
    80005ab8:	ce7fa0ef          	jal	8000079e <panic>
    panic("virtio disk has no queue 0");
    80005abc:	00002517          	auipc	a0,0x2
    80005ac0:	d5450513          	addi	a0,a0,-684 # 80007810 <etext+0x810>
    80005ac4:	cdbfa0ef          	jal	8000079e <panic>
    panic("virtio disk max queue too short");
    80005ac8:	00002517          	auipc	a0,0x2
    80005acc:	d6850513          	addi	a0,a0,-664 # 80007830 <etext+0x830>
    80005ad0:	ccffa0ef          	jal	8000079e <panic>
    panic("virtio disk kalloc");
    80005ad4:	00002517          	auipc	a0,0x2
    80005ad8:	d7c50513          	addi	a0,a0,-644 # 80007850 <etext+0x850>
    80005adc:	cc3fa0ef          	jal	8000079e <panic>

0000000080005ae0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ae0:	711d                	addi	sp,sp,-96
    80005ae2:	ec86                	sd	ra,88(sp)
    80005ae4:	e8a2                	sd	s0,80(sp)
    80005ae6:	e4a6                	sd	s1,72(sp)
    80005ae8:	e0ca                	sd	s2,64(sp)
    80005aea:	fc4e                	sd	s3,56(sp)
    80005aec:	f852                	sd	s4,48(sp)
    80005aee:	f456                	sd	s5,40(sp)
    80005af0:	f05a                	sd	s6,32(sp)
    80005af2:	ec5e                	sd	s7,24(sp)
    80005af4:	e862                	sd	s8,16(sp)
    80005af6:	1080                	addi	s0,sp,96
    80005af8:	89aa                	mv	s3,a0
    80005afa:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005afc:	00c52b83          	lw	s7,12(a0)
    80005b00:	001b9b9b          	slliw	s7,s7,0x1
    80005b04:	1b82                	slli	s7,s7,0x20
    80005b06:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005b0a:	00025517          	auipc	a0,0x25
    80005b0e:	f0e50513          	addi	a0,a0,-242 # 8002aa18 <disk+0x128>
    80005b12:	8ecfb0ef          	jal	80000bfe <acquire>
  for(int i = 0; i < NUM; i++){
    80005b16:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b18:	00025a97          	auipc	s5,0x25
    80005b1c:	dd8a8a93          	addi	s5,s5,-552 # 8002a8f0 <disk>
  for(int i = 0; i < 3; i++){
    80005b20:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005b22:	5c7d                	li	s8,-1
    80005b24:	a095                	j	80005b88 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005b26:	00fa8733          	add	a4,s5,a5
    80005b2a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005b2e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005b30:	0207c563          	bltz	a5,80005b5a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005b34:	2905                	addiw	s2,s2,1
    80005b36:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b38:	05490c63          	beq	s2,s4,80005b90 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005b3c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005b3e:	00025717          	auipc	a4,0x25
    80005b42:	db270713          	addi	a4,a4,-590 # 8002a8f0 <disk>
    80005b46:	4781                	li	a5,0
    if(disk.free[i]){
    80005b48:	01874683          	lbu	a3,24(a4)
    80005b4c:	fee9                	bnez	a3,80005b26 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005b4e:	2785                	addiw	a5,a5,1
    80005b50:	0705                	addi	a4,a4,1
    80005b52:	fe979be3          	bne	a5,s1,80005b48 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005b56:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005b5a:	01205d63          	blez	s2,80005b74 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b5e:	fa042503          	lw	a0,-96(s0)
    80005b62:	d41ff0ef          	jal	800058a2 <free_desc>
      for(int j = 0; j < i; j++)
    80005b66:	4785                	li	a5,1
    80005b68:	0127d663          	bge	a5,s2,80005b74 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b6c:	fa442503          	lw	a0,-92(s0)
    80005b70:	d33ff0ef          	jal	800058a2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005b74:	00025597          	auipc	a1,0x25
    80005b78:	ea458593          	addi	a1,a1,-348 # 8002aa18 <disk+0x128>
    80005b7c:	00025517          	auipc	a0,0x25
    80005b80:	d8c50513          	addi	a0,a0,-628 # 8002a908 <disk+0x18>
    80005b84:	e96fc0ef          	jal	8000221a <sleep>
  for(int i = 0; i < 3; i++){
    80005b88:	fa040613          	addi	a2,s0,-96
    80005b8c:	4901                	li	s2,0
    80005b8e:	b77d                	j	80005b3c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b90:	fa042503          	lw	a0,-96(s0)
    80005b94:	00451693          	slli	a3,a0,0x4

  if(write)
    80005b98:	00025797          	auipc	a5,0x25
    80005b9c:	d5878793          	addi	a5,a5,-680 # 8002a8f0 <disk>
    80005ba0:	00a50713          	addi	a4,a0,10
    80005ba4:	0712                	slli	a4,a4,0x4
    80005ba6:	973e                	add	a4,a4,a5
    80005ba8:	01603633          	snez	a2,s6
    80005bac:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005bae:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005bb2:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005bb6:	6398                	ld	a4,0(a5)
    80005bb8:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bba:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005bbe:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005bc0:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005bc2:	6390                	ld	a2,0(a5)
    80005bc4:	00d605b3          	add	a1,a2,a3
    80005bc8:	4741                	li	a4,16
    80005bca:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005bcc:	4805                	li	a6,1
    80005bce:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005bd2:	fa442703          	lw	a4,-92(s0)
    80005bd6:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005bda:	0712                	slli	a4,a4,0x4
    80005bdc:	963a                	add	a2,a2,a4
    80005bde:	05898593          	addi	a1,s3,88
    80005be2:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005be4:	0007b883          	ld	a7,0(a5)
    80005be8:	9746                	add	a4,a4,a7
    80005bea:	40000613          	li	a2,1024
    80005bee:	c710                	sw	a2,8(a4)
  if(write)
    80005bf0:	001b3613          	seqz	a2,s6
    80005bf4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005bf8:	01066633          	or	a2,a2,a6
    80005bfc:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005c00:	fa842583          	lw	a1,-88(s0)
    80005c04:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005c08:	00250613          	addi	a2,a0,2
    80005c0c:	0612                	slli	a2,a2,0x4
    80005c0e:	963e                	add	a2,a2,a5
    80005c10:	577d                	li	a4,-1
    80005c12:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005c16:	0592                	slli	a1,a1,0x4
    80005c18:	98ae                	add	a7,a7,a1
    80005c1a:	03068713          	addi	a4,a3,48
    80005c1e:	973e                	add	a4,a4,a5
    80005c20:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005c24:	6398                	ld	a4,0(a5)
    80005c26:	972e                	add	a4,a4,a1
    80005c28:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c2c:	4689                	li	a3,2
    80005c2e:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c32:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c36:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    80005c3a:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c3e:	6794                	ld	a3,8(a5)
    80005c40:	0026d703          	lhu	a4,2(a3)
    80005c44:	8b1d                	andi	a4,a4,7
    80005c46:	0706                	slli	a4,a4,0x1
    80005c48:	96ba                	add	a3,a3,a4
    80005c4a:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005c4e:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c52:	6798                	ld	a4,8(a5)
    80005c54:	00275783          	lhu	a5,2(a4)
    80005c58:	2785                	addiw	a5,a5,1
    80005c5a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005c5e:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c62:	100017b7          	lui	a5,0x10001
    80005c66:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005c6a:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005c6e:	00025917          	auipc	s2,0x25
    80005c72:	daa90913          	addi	s2,s2,-598 # 8002aa18 <disk+0x128>
  while(b->disk == 1) {
    80005c76:	84c2                	mv	s1,a6
    80005c78:	01079a63          	bne	a5,a6,80005c8c <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    80005c7c:	85ca                	mv	a1,s2
    80005c7e:	854e                	mv	a0,s3
    80005c80:	d9afc0ef          	jal	8000221a <sleep>
  while(b->disk == 1) {
    80005c84:	0049a783          	lw	a5,4(s3)
    80005c88:	fe978ae3          	beq	a5,s1,80005c7c <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    80005c8c:	fa042903          	lw	s2,-96(s0)
    80005c90:	00290713          	addi	a4,s2,2
    80005c94:	0712                	slli	a4,a4,0x4
    80005c96:	00025797          	auipc	a5,0x25
    80005c9a:	c5a78793          	addi	a5,a5,-934 # 8002a8f0 <disk>
    80005c9e:	97ba                	add	a5,a5,a4
    80005ca0:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005ca4:	00025997          	auipc	s3,0x25
    80005ca8:	c4c98993          	addi	s3,s3,-948 # 8002a8f0 <disk>
    80005cac:	00491713          	slli	a4,s2,0x4
    80005cb0:	0009b783          	ld	a5,0(s3)
    80005cb4:	97ba                	add	a5,a5,a4
    80005cb6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005cba:	854a                	mv	a0,s2
    80005cbc:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005cc0:	be3ff0ef          	jal	800058a2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005cc4:	8885                	andi	s1,s1,1
    80005cc6:	f0fd                	bnez	s1,80005cac <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005cc8:	00025517          	auipc	a0,0x25
    80005ccc:	d5050513          	addi	a0,a0,-688 # 8002aa18 <disk+0x128>
    80005cd0:	fc3fa0ef          	jal	80000c92 <release>
}
    80005cd4:	60e6                	ld	ra,88(sp)
    80005cd6:	6446                	ld	s0,80(sp)
    80005cd8:	64a6                	ld	s1,72(sp)
    80005cda:	6906                	ld	s2,64(sp)
    80005cdc:	79e2                	ld	s3,56(sp)
    80005cde:	7a42                	ld	s4,48(sp)
    80005ce0:	7aa2                	ld	s5,40(sp)
    80005ce2:	7b02                	ld	s6,32(sp)
    80005ce4:	6be2                	ld	s7,24(sp)
    80005ce6:	6c42                	ld	s8,16(sp)
    80005ce8:	6125                	addi	sp,sp,96
    80005cea:	8082                	ret

0000000080005cec <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005cec:	1101                	addi	sp,sp,-32
    80005cee:	ec06                	sd	ra,24(sp)
    80005cf0:	e822                	sd	s0,16(sp)
    80005cf2:	e426                	sd	s1,8(sp)
    80005cf4:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005cf6:	00025497          	auipc	s1,0x25
    80005cfa:	bfa48493          	addi	s1,s1,-1030 # 8002a8f0 <disk>
    80005cfe:	00025517          	auipc	a0,0x25
    80005d02:	d1a50513          	addi	a0,a0,-742 # 8002aa18 <disk+0x128>
    80005d06:	ef9fa0ef          	jal	80000bfe <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005d0a:	100017b7          	lui	a5,0x10001
    80005d0e:	53bc                	lw	a5,96(a5)
    80005d10:	8b8d                	andi	a5,a5,3
    80005d12:	10001737          	lui	a4,0x10001
    80005d16:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005d18:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005d1c:	689c                	ld	a5,16(s1)
    80005d1e:	0204d703          	lhu	a4,32(s1)
    80005d22:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005d26:	04f70663          	beq	a4,a5,80005d72 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005d2a:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d2e:	6898                	ld	a4,16(s1)
    80005d30:	0204d783          	lhu	a5,32(s1)
    80005d34:	8b9d                	andi	a5,a5,7
    80005d36:	078e                	slli	a5,a5,0x3
    80005d38:	97ba                	add	a5,a5,a4
    80005d3a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005d3c:	00278713          	addi	a4,a5,2
    80005d40:	0712                	slli	a4,a4,0x4
    80005d42:	9726                	add	a4,a4,s1
    80005d44:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005d48:	e321                	bnez	a4,80005d88 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d4a:	0789                	addi	a5,a5,2
    80005d4c:	0792                	slli	a5,a5,0x4
    80005d4e:	97a6                	add	a5,a5,s1
    80005d50:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005d52:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d56:	d10fc0ef          	jal	80002266 <wakeup>

    disk.used_idx += 1;
    80005d5a:	0204d783          	lhu	a5,32(s1)
    80005d5e:	2785                	addiw	a5,a5,1
    80005d60:	17c2                	slli	a5,a5,0x30
    80005d62:	93c1                	srli	a5,a5,0x30
    80005d64:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005d68:	6898                	ld	a4,16(s1)
    80005d6a:	00275703          	lhu	a4,2(a4)
    80005d6e:	faf71ee3          	bne	a4,a5,80005d2a <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005d72:	00025517          	auipc	a0,0x25
    80005d76:	ca650513          	addi	a0,a0,-858 # 8002aa18 <disk+0x128>
    80005d7a:	f19fa0ef          	jal	80000c92 <release>
}
    80005d7e:	60e2                	ld	ra,24(sp)
    80005d80:	6442                	ld	s0,16(sp)
    80005d82:	64a2                	ld	s1,8(sp)
    80005d84:	6105                	addi	sp,sp,32
    80005d86:	8082                	ret
      panic("virtio_disk_intr status");
    80005d88:	00002517          	auipc	a0,0x2
    80005d8c:	ae050513          	addi	a0,a0,-1312 # 80007868 <etext+0x868>
    80005d90:	a0ffa0ef          	jal	8000079e <panic>
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
