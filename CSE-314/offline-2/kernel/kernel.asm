
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	ab010113          	addi	sp,sp,-1360 # 80007ab0 <stack0>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd3e1f>
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
    80000106:	29c020ef          	jal	800023a2 <either_copyin>
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
    8000016a:	94a50513          	addi	a0,a0,-1718 # 8000fab0 <cons>
    8000016e:	291000ef          	jal	80000bfe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000172:	00010497          	auipc	s1,0x10
    80000176:	93e48493          	addi	s1,s1,-1730 # 8000fab0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000017a:	00010917          	auipc	s2,0x10
    8000017e:	9ce90913          	addi	s2,s2,-1586 # 8000fb48 <cons+0x98>
  while(n > 0){
    80000182:	0b305b63          	blez	s3,80000238 <consoleread+0xee>
    while(cons.r == cons.w){
    80000186:	0984a783          	lw	a5,152(s1)
    8000018a:	09c4a703          	lw	a4,156(s1)
    8000018e:	0af71063          	bne	a4,a5,8000022e <consoleread+0xe4>
      if(killed(myproc())){
    80000192:	74a010ef          	jal	800018dc <myproc>
    80000196:	0a4020ef          	jal	8000223a <killed>
    8000019a:	e12d                	bnez	a0,800001fc <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    8000019c:	85a6                	mv	a1,s1
    8000019e:	854a                	mv	a0,s2
    800001a0:	663010ef          	jal	80002002 <sleep>
    while(cons.r == cons.w){
    800001a4:	0984a783          	lw	a5,152(s1)
    800001a8:	09c4a703          	lw	a4,156(s1)
    800001ac:	fef703e3          	beq	a4,a5,80000192 <consoleread+0x48>
    800001b0:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001b2:	00010717          	auipc	a4,0x10
    800001b6:	8fe70713          	addi	a4,a4,-1794 # 8000fab0 <cons>
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
    800001e4:	174020ef          	jal	80002358 <either_copyout>
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
    80000200:	8b450513          	addi	a0,a0,-1868 # 8000fab0 <cons>
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
    80000226:	92f72323          	sw	a5,-1754(a4) # 8000fb48 <cons+0x98>
    8000022a:	6be2                	ld	s7,24(sp)
    8000022c:	a031                	j	80000238 <consoleread+0xee>
    8000022e:	ec5e                	sd	s7,24(sp)
    80000230:	b749                	j	800001b2 <consoleread+0x68>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	a011                	j	80000238 <consoleread+0xee>
    80000236:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000238:	00010517          	auipc	a0,0x10
    8000023c:	87850513          	addi	a0,a0,-1928 # 8000fab0 <cons>
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
    80000290:	82450513          	addi	a0,a0,-2012 # 8000fab0 <cons>
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
    800002ae:	13e020ef          	jal	800023ec <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002b2:	0000f517          	auipc	a0,0xf
    800002b6:	7fe50513          	addi	a0,a0,2046 # 8000fab0 <cons>
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
    800002d4:	7e070713          	addi	a4,a4,2016 # 8000fab0 <cons>
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
    800002fa:	7ba78793          	addi	a5,a5,1978 # 8000fab0 <cons>
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
    80000326:	8267a783          	lw	a5,-2010(a5) # 8000fb48 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f8f711e3          	bne	a4,a5,800002b2 <consoleintr+0x32>
    80000334:	a85d                	j	800003ea <consoleintr+0x16a>
    80000336:	e84a                	sd	s2,16(sp)
    80000338:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    8000033a:	0000f717          	auipc	a4,0xf
    8000033e:	77670713          	addi	a4,a4,1910 # 8000fab0 <cons>
    80000342:	0a072783          	lw	a5,160(a4)
    80000346:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	0000f497          	auipc	s1,0xf
    8000034e:	76648493          	addi	s1,s1,1894 # 8000fab0 <cons>
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
    80000398:	71c70713          	addi	a4,a4,1820 # 8000fab0 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
    800003a4:	f0f707e3          	beq	a4,a5,800002b2 <consoleintr+0x32>
      cons.e--;
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	0000f717          	auipc	a4,0xf
    800003ae:	7af72323          	sw	a5,1958(a4) # 8000fb50 <cons+0xa0>
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
    800003cc:	6e878793          	addi	a5,a5,1768 # 8000fab0 <cons>
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
    800003ee:	76c7a123          	sw	a2,1890(a5) # 8000fb4c <cons+0x9c>
        wakeup(&cons.r);
    800003f2:	0000f517          	auipc	a0,0xf
    800003f6:	75650513          	addi	a0,a0,1878 # 8000fb48 <cons+0x98>
    800003fa:	455010ef          	jal	8000204e <wakeup>
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
    80000414:	6a050513          	addi	a0,a0,1696 # 8000fab0 <cons>
    80000418:	762000ef          	jal	80000b7a <initlock>

  uartinit();
    8000041c:	3ea000ef          	jal	80000806 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000420:	00029797          	auipc	a5,0x29
    80000424:	42878793          	addi	a5,a5,1064 # 80029848 <devsw>
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
    80000464:	3d080813          	addi	a6,a6,976 # 80007830 <digits>
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
    800004f0:	6847a783          	lw	a5,1668(a5) # 8000fb70 <pr+0x18>
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
    8000053c:	62050513          	addi	a0,a0,1568 # 8000fb58 <pr>
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
    800006fa:	13ab8b93          	addi	s7,s7,314 # 80007830 <digits>
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
    80000794:	3c850513          	addi	a0,a0,968 # 8000fb58 <pr>
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
    800007ae:	3c07a323          	sw	zero,966(a5) # 8000fb70 <pr+0x18>
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
    800007d2:	2af72123          	sw	a5,674(a4) # 80007a70 <panicked>
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
    800007e6:	37648493          	addi	s1,s1,886 # 8000fb58 <pr>
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
    8000084c:	33050513          	addi	a0,a0,816 # 8000fb78 <uart_tx_lock>
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
    80000870:	2047a783          	lw	a5,516(a5) # 80007a70 <panicked>
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
    800008a6:	1d67b783          	ld	a5,470(a5) # 80007a78 <uart_tx_r>
    800008aa:	00007717          	auipc	a4,0x7
    800008ae:	1d673703          	ld	a4,470(a4) # 80007a80 <uart_tx_w>
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
    800008d4:	2a8a8a93          	addi	s5,s5,680 # 8000fb78 <uart_tx_lock>
    uart_tx_r += 1;
    800008d8:	00007497          	auipc	s1,0x7
    800008dc:	1a048493          	addi	s1,s1,416 # 80007a78 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008e0:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e4:	00007997          	auipc	s3,0x7
    800008e8:	19c98993          	addi	s3,s3,412 # 80007a80 <uart_tx_w>
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
    80000906:	748010ef          	jal	8000204e <wakeup>
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
    80000954:	22850513          	addi	a0,a0,552 # 8000fb78 <uart_tx_lock>
    80000958:	2a6000ef          	jal	80000bfe <acquire>
  if(panicked){
    8000095c:	00007797          	auipc	a5,0x7
    80000960:	1147a783          	lw	a5,276(a5) # 80007a70 <panicked>
    80000964:	efbd                	bnez	a5,800009e2 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000966:	00007717          	auipc	a4,0x7
    8000096a:	11a73703          	ld	a4,282(a4) # 80007a80 <uart_tx_w>
    8000096e:	00007797          	auipc	a5,0x7
    80000972:	10a7b783          	ld	a5,266(a5) # 80007a78 <uart_tx_r>
    80000976:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	0000f997          	auipc	s3,0xf
    8000097e:	1fe98993          	addi	s3,s3,510 # 8000fb78 <uart_tx_lock>
    80000982:	00007497          	auipc	s1,0x7
    80000986:	0f648493          	addi	s1,s1,246 # 80007a78 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000098a:	00007917          	auipc	s2,0x7
    8000098e:	0f690913          	addi	s2,s2,246 # 80007a80 <uart_tx_w>
    80000992:	00e79d63          	bne	a5,a4,800009ac <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000996:	85ce                	mv	a1,s3
    80000998:	8526                	mv	a0,s1
    8000099a:	668010ef          	jal	80002002 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099e:	00093703          	ld	a4,0(s2)
    800009a2:	609c                	ld	a5,0(s1)
    800009a4:	02078793          	addi	a5,a5,32
    800009a8:	fee787e3          	beq	a5,a4,80000996 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009ac:	0000f497          	auipc	s1,0xf
    800009b0:	1cc48493          	addi	s1,s1,460 # 8000fb78 <uart_tx_lock>
    800009b4:	01f77793          	andi	a5,a4,31
    800009b8:	97a6                	add	a5,a5,s1
    800009ba:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009be:	0705                	addi	a4,a4,1
    800009c0:	00007797          	auipc	a5,0x7
    800009c4:	0ce7b023          	sd	a4,192(a5) # 80007a80 <uart_tx_w>
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
    80000a2a:	15248493          	addi	s1,s1,338 # 8000fb78 <uart_tx_lock>
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
    80000a60:	f8478793          	addi	a5,a5,-124 # 8002a9e0 <end>
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
    80000a7c:	13890913          	addi	s2,s2,312 # 8000fbb0 <kmem>
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
    80000b0a:	0aa50513          	addi	a0,a0,170 # 8000fbb0 <kmem>
    80000b0e:	06c000ef          	jal	80000b7a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b12:	45c5                	li	a1,17
    80000b14:	05ee                	slli	a1,a1,0x1b
    80000b16:	0002a517          	auipc	a0,0x2a
    80000b1a:	eca50513          	addi	a0,a0,-310 # 8002a9e0 <end>
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
    80000b38:	07c48493          	addi	s1,s1,124 # 8000fbb0 <kmem>
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	0c0000ef          	jal	80000bfe <acquire>
  r = kmem.freelist;
    80000b42:	6c84                	ld	s1,24(s1)
  if(r)
    80000b44:	c485                	beqz	s1,80000b6c <kalloc+0x42>
    kmem.freelist = r->next;
    80000b46:	609c                	ld	a5,0(s1)
    80000b48:	0000f517          	auipc	a0,0xf
    80000b4c:	06850513          	addi	a0,a0,104 # 8000fbb0 <kmem>
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
    80000b70:	04450513          	addi	a0,a0,68 # 8000fbb0 <kmem>
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
    80000d4c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd4621>
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
    80000e94:	bf870713          	addi	a4,a4,-1032 # 80007a88 <started>
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
    80000eba:	664010ef          	jal	8000251e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	71a040ef          	jal	800055d8 <plicinithart>
  }

  scheduler();        
    80000ec2:	6bf000ef          	jal	80001d80 <scheduler>
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
    80000f02:	5f8010ef          	jal	800024fa <trapinit>
    trapinithart();  // install kernel trap vector
    80000f06:	618010ef          	jal	8000251e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f0a:	6b4040ef          	jal	800055be <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f0e:	6ca040ef          	jal	800055d8 <plicinithart>
    binit();         // buffer cache
    80000f12:	635010ef          	jal	80002d46 <binit>
    iinit();         // inode table
    80000f16:	400020ef          	jal	80003316 <iinit>
    fileinit();      // file table
    80000f1a:	1ce030ef          	jal	800040e8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1e:	7aa040ef          	jal	800056c8 <virtio_disk_init>
    userinit();      // first user process
    80000f22:	487000ef          	jal	80001ba8 <userinit>
    __sync_synchronize();
    80000f26:	0330000f          	fence	rw,rw
    started = 1;
    80000f2a:	4785                	li	a5,1
    80000f2c:	00007717          	auipc	a4,0x7
    80000f30:	b4f72e23          	sw	a5,-1188(a4) # 80007a88 <started>
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
    80000f46:	b4e7b783          	ld	a5,-1202(a5) # 80007a90 <kernel_pagetable>
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
    800011d4:	8ca7b023          	sd	a0,-1856(a5) # 80007a90 <kernel_pagetable>
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
    80001778:	88c48493          	addi	s1,s1,-1908 # 80010000 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000177c:	8c26                	mv	s8,s1
    8000177e:	eb2fe7b7          	lui	a5,0xeb2fe
    80001782:	eb378793          	addi	a5,a5,-333 # ffffffffeb2fdeb3 <end+0xffffffff6b2d34d3>
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
    800017a2:	e62a8a93          	addi	s5,s5,-414 # 8001f600 <tickslock>
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
    80001818:	3bc50513          	addi	a0,a0,956 # 8000fbd0 <pid_lock>
    8000181c:	b5eff0ef          	jal	80000b7a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001820:	00006597          	auipc	a1,0x6
    80001824:	9e858593          	addi	a1,a1,-1560 # 80007208 <etext+0x208>
    80001828:	0000e517          	auipc	a0,0xe
    8000182c:	3c050513          	addi	a0,a0,960 # 8000fbe8 <wait_lock>
    80001830:	b4aff0ef          	jal	80000b7a <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001834:	0000e497          	auipc	s1,0xe
    80001838:	7cc48493          	addi	s1,s1,1996 # 80010000 <proc>
  {
    initlock(&p->lock, "proc");
    8000183c:	00006b17          	auipc	s6,0x6
    80001840:	9dcb0b13          	addi	s6,s6,-1572 # 80007218 <etext+0x218>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001844:	8aa6                	mv	s5,s1
    80001846:	eb2fe7b7          	lui	a5,0xeb2fe
    8000184a:	eb378793          	addi	a5,a5,-333 # ffffffffeb2fdeb3 <end+0xffffffff6b2d34d3>
    8000184e:	2fdeb937          	lui	s2,0x2fdeb
    80001852:	2fe90913          	addi	s2,s2,766 # 2fdeb2fe <_entry-0x50214d02>
    80001856:	1902                	slli	s2,s2,0x20
    80001858:	993e                	add	s2,s2,a5
    8000185a:	040009b7          	lui	s3,0x4000
    8000185e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001860:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001862:	0001ea17          	auipc	s4,0x1e
    80001866:	d9ea0a13          	addi	s4,s4,-610 # 8001f600 <tickslock>
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
    800018ce:	33650513          	addi	a0,a0,822 # 8000fc00 <cpus>
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
    800018f4:	2e070713          	addi	a4,a4,736 # 8000fbd0 <pid_lock>
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
    80001920:	1047a783          	lw	a5,260(a5) # 80007a20 <first.1>
    80001924:	e799                	bnez	a5,80001932 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001926:	415000ef          	jal	8000253a <usertrapret>
}
    8000192a:	60a2                	ld	ra,8(sp)
    8000192c:	6402                	ld	s0,0(sp)
    8000192e:	0141                	addi	sp,sp,16
    80001930:	8082                	ret
    fsinit(ROOTDEV);
    80001932:	4505                	li	a0,1
    80001934:	177010ef          	jal	800032aa <fsinit>
    first = 0;
    80001938:	00006797          	auipc	a5,0x6
    8000193c:	0e07a423          	sw	zero,232(a5) # 80007a20 <first.1>
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
    80001956:	27e90913          	addi	s2,s2,638 # 8000fbd0 <pid_lock>
    8000195a:	854a                	mv	a0,s2
    8000195c:	aa2ff0ef          	jal	80000bfe <acquire>
  pid = nextpid;
    80001960:	00006797          	auipc	a5,0x6
    80001964:	0c478793          	addi	a5,a5,196 # 80007a24 <nextpid>
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
    80001aaa:	0000e917          	auipc	s2,0xe
    80001aae:	55690913          	addi	s2,s2,1366 # 80010000 <proc>
    80001ab2:	0001e497          	auipc	s1,0x1e
    80001ab6:	b4e48493          	addi	s1,s1,-1202 # 8001f600 <tickslock>
    acquire(&p->lock);
    80001aba:	854a                	mv	a0,s2
    80001abc:	942ff0ef          	jal	80000bfe <acquire>
    if (p->state == UNUSED)
    80001ac0:	01892783          	lw	a5,24(s2)
    80001ac4:	cb91                	beqz	a5,80001ad8 <allocproc+0x3a>
      release(&p->lock);
    80001ac6:	854a                	mv	a0,s2
    80001ac8:	9caff0ef          	jal	80000c92 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001acc:	3d890913          	addi	s2,s2,984
    80001ad0:	fe9915e3          	bne	s2,s1,80001aba <allocproc+0x1c>
  return 0;
    80001ad4:	4901                	li	s2,0
    80001ad6:	a861                	j	80001b6e <allocproc+0xd0>
    80001ad8:	ec4e                	sd	s3,24(sp)
    80001ada:	e852                	sd	s4,16(sp)
    80001adc:	e456                	sd	s5,8(sp)
  p->pid = allocpid();
    80001ade:	e69ff0ef          	jal	80001946 <allocpid>
    80001ae2:	02a92823          	sw	a0,48(s2)
  p->state = USED;
    80001ae6:	4785                	li	a5,1
    80001ae8:	00f92c23          	sw	a5,24(s2)
  for (int i = 1; i <= NSYSCALL; i++)
    80001aec:	00006997          	auipc	s3,0x6
    80001af0:	d6498993          	addi	s3,s3,-668 # 80007850 <syscall_names+0x8>
    80001af4:	18090493          	addi	s1,s2,384
    80001af8:	00006a17          	auipc	s4,0x6
    80001afc:	e18a0a13          	addi	s4,s4,-488 # 80007910 <states.0>
      safestrcpy(p->syscall_stats[i].syscall_name, syscall_names[i], sizeof(p->syscall_stats[i].syscall_name));
    80001b00:	4ac1                	li	s5,16
    80001b02:	a829                	j	80001b1c <allocproc+0x7e>
    80001b04:	8656                	mv	a2,s5
    80001b06:	8526                	mv	a0,s1
    80001b08:	b18ff0ef          	jal	80000e20 <safestrcpy>
    p->syscall_stats[i].count = 0;
    80001b0c:	0004a823          	sw	zero,16(s1)
    p->syscall_stats[i].accum_time = 0;
    80001b10:	0004aa23          	sw	zero,20(s1)
  for (int i = 1; i <= NSYSCALL; i++)
    80001b14:	09a1                	addi	s3,s3,8
    80001b16:	04e1                	addi	s1,s1,24
    80001b18:	01498863          	beq	s3,s4,80001b28 <allocproc+0x8a>
    if (syscall_names[i])
    80001b1c:	0009b583          	ld	a1,0(s3)
    80001b20:	f1f5                	bnez	a1,80001b04 <allocproc+0x66>
      p->syscall_stats[i].syscall_name[0] = '\0';
    80001b22:	00048023          	sb	zero,0(s1)
    80001b26:	b7dd                	j	80001b0c <allocproc+0x6e>
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001b28:	802ff0ef          	jal	80000b2a <kalloc>
    80001b2c:	84aa                	mv	s1,a0
    80001b2e:	04a93c23          	sd	a0,88(s2)
    80001b32:	c529                	beqz	a0,80001b7c <allocproc+0xde>
  p->pagetable = proc_pagetable(p);
    80001b34:	854a                	mv	a0,s2
    80001b36:	e4fff0ef          	jal	80001984 <proc_pagetable>
    80001b3a:	84aa                	mv	s1,a0
    80001b3c:	04a93823          	sd	a0,80(s2)
  if (p->pagetable == 0)
    80001b40:	c929                	beqz	a0,80001b92 <allocproc+0xf4>
  memset(&p->context, 0, sizeof(p->context));
    80001b42:	07000613          	li	a2,112
    80001b46:	4581                	li	a1,0
    80001b48:	06090513          	addi	a0,s2,96
    80001b4c:	982ff0ef          	jal	80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001b50:	00000797          	auipc	a5,0x0
    80001b54:	dbc78793          	addi	a5,a5,-580 # 8000190c <forkret>
    80001b58:	06f93023          	sd	a5,96(s2)
  p->context.sp = p->kstack + PGSIZE;
    80001b5c:	04093783          	ld	a5,64(s2)
    80001b60:	6705                	lui	a4,0x1
    80001b62:	97ba                	add	a5,a5,a4
    80001b64:	06f93423          	sd	a5,104(s2)
    80001b68:	69e2                	ld	s3,24(sp)
    80001b6a:	6a42                	ld	s4,16(sp)
    80001b6c:	6aa2                	ld	s5,8(sp)
}
    80001b6e:	854a                	mv	a0,s2
    80001b70:	70e2                	ld	ra,56(sp)
    80001b72:	7442                	ld	s0,48(sp)
    80001b74:	74a2                	ld	s1,40(sp)
    80001b76:	7902                	ld	s2,32(sp)
    80001b78:	6121                	addi	sp,sp,64
    80001b7a:	8082                	ret
    freeproc(p);
    80001b7c:	854a                	mv	a0,s2
    80001b7e:	ed1ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b82:	854a                	mv	a0,s2
    80001b84:	90eff0ef          	jal	80000c92 <release>
    return 0;
    80001b88:	8926                	mv	s2,s1
    80001b8a:	69e2                	ld	s3,24(sp)
    80001b8c:	6a42                	ld	s4,16(sp)
    80001b8e:	6aa2                	ld	s5,8(sp)
    80001b90:	bff9                	j	80001b6e <allocproc+0xd0>
    freeproc(p);
    80001b92:	854a                	mv	a0,s2
    80001b94:	ebbff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b98:	854a                	mv	a0,s2
    80001b9a:	8f8ff0ef          	jal	80000c92 <release>
    return 0;
    80001b9e:	8926                	mv	s2,s1
    80001ba0:	69e2                	ld	s3,24(sp)
    80001ba2:	6a42                	ld	s4,16(sp)
    80001ba4:	6aa2                	ld	s5,8(sp)
    80001ba6:	b7e1                	j	80001b6e <allocproc+0xd0>

0000000080001ba8 <userinit>:
{
    80001ba8:	1101                	addi	sp,sp,-32
    80001baa:	ec06                	sd	ra,24(sp)
    80001bac:	e822                	sd	s0,16(sp)
    80001bae:	e426                	sd	s1,8(sp)
    80001bb0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bb2:	eedff0ef          	jal	80001a9e <allocproc>
    80001bb6:	84aa                	mv	s1,a0
  initproc = p;
    80001bb8:	00006797          	auipc	a5,0x6
    80001bbc:	eea7b423          	sd	a0,-280(a5) # 80007aa0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001bc0:	03400613          	li	a2,52
    80001bc4:	00006597          	auipc	a1,0x6
    80001bc8:	e6c58593          	addi	a1,a1,-404 # 80007a30 <initcode>
    80001bcc:	6928                	ld	a0,80(a0)
    80001bce:	ef4ff0ef          	jal	800012c2 <uvmfirst>
  p->sz = PGSIZE;
    80001bd2:	6785                	lui	a5,0x1
    80001bd4:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001bd6:	6cb8                	ld	a4,88(s1)
    80001bd8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001bdc:	6cb8                	ld	a4,88(s1)
    80001bde:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001be0:	4641                	li	a2,16
    80001be2:	00005597          	auipc	a1,0x5
    80001be6:	63e58593          	addi	a1,a1,1598 # 80007220 <etext+0x220>
    80001bea:	15848513          	addi	a0,s1,344
    80001bee:	a32ff0ef          	jal	80000e20 <safestrcpy>
  p->cwd = namei("/");
    80001bf2:	00005517          	auipc	a0,0x5
    80001bf6:	63e50513          	addi	a0,a0,1598 # 80007230 <etext+0x230>
    80001bfa:	7d5010ef          	jal	80003bce <namei>
    80001bfe:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c02:	478d                	li	a5,3
    80001c04:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c06:	8526                	mv	a0,s1
    80001c08:	88aff0ef          	jal	80000c92 <release>
}
    80001c0c:	60e2                	ld	ra,24(sp)
    80001c0e:	6442                	ld	s0,16(sp)
    80001c10:	64a2                	ld	s1,8(sp)
    80001c12:	6105                	addi	sp,sp,32
    80001c14:	8082                	ret

0000000080001c16 <growproc>:
{
    80001c16:	1101                	addi	sp,sp,-32
    80001c18:	ec06                	sd	ra,24(sp)
    80001c1a:	e822                	sd	s0,16(sp)
    80001c1c:	e426                	sd	s1,8(sp)
    80001c1e:	e04a                	sd	s2,0(sp)
    80001c20:	1000                	addi	s0,sp,32
    80001c22:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001c24:	cb9ff0ef          	jal	800018dc <myproc>
    80001c28:	84aa                	mv	s1,a0
  sz = p->sz;
    80001c2a:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001c2c:	01204c63          	bgtz	s2,80001c44 <growproc+0x2e>
  else if (n < 0)
    80001c30:	02094463          	bltz	s2,80001c58 <growproc+0x42>
  p->sz = sz;
    80001c34:	e4ac                	sd	a1,72(s1)
  return 0;
    80001c36:	4501                	li	a0,0
}
    80001c38:	60e2                	ld	ra,24(sp)
    80001c3a:	6442                	ld	s0,16(sp)
    80001c3c:	64a2                	ld	s1,8(sp)
    80001c3e:	6902                	ld	s2,0(sp)
    80001c40:	6105                	addi	sp,sp,32
    80001c42:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001c44:	4691                	li	a3,4
    80001c46:	00b90633          	add	a2,s2,a1
    80001c4a:	6928                	ld	a0,80(a0)
    80001c4c:	f18ff0ef          	jal	80001364 <uvmalloc>
    80001c50:	85aa                	mv	a1,a0
    80001c52:	f16d                	bnez	a0,80001c34 <growproc+0x1e>
      return -1;
    80001c54:	557d                	li	a0,-1
    80001c56:	b7cd                	j	80001c38 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c58:	00b90633          	add	a2,s2,a1
    80001c5c:	6928                	ld	a0,80(a0)
    80001c5e:	ec2ff0ef          	jal	80001320 <uvmdealloc>
    80001c62:	85aa                	mv	a1,a0
    80001c64:	bfc1                	j	80001c34 <growproc+0x1e>

0000000080001c66 <fork>:
{
    80001c66:	7139                	addi	sp,sp,-64
    80001c68:	fc06                	sd	ra,56(sp)
    80001c6a:	f822                	sd	s0,48(sp)
    80001c6c:	f04a                	sd	s2,32(sp)
    80001c6e:	e456                	sd	s5,8(sp)
    80001c70:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c72:	c6bff0ef          	jal	800018dc <myproc>
    80001c76:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001c78:	e27ff0ef          	jal	80001a9e <allocproc>
    80001c7c:	10050063          	beqz	a0,80001d7c <fork+0x116>
    80001c80:	ec4e                	sd	s3,24(sp)
    80001c82:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001c84:	048ab603          	ld	a2,72(s5)
    80001c88:	692c                	ld	a1,80(a0)
    80001c8a:	050ab503          	ld	a0,80(s5)
    80001c8e:	817ff0ef          	jal	800014a4 <uvmcopy>
    80001c92:	04054a63          	bltz	a0,80001ce6 <fork+0x80>
    80001c96:	f426                	sd	s1,40(sp)
    80001c98:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c9a:	048ab783          	ld	a5,72(s5)
    80001c9e:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ca2:	058ab683          	ld	a3,88(s5)
    80001ca6:	87b6                	mv	a5,a3
    80001ca8:	0589b703          	ld	a4,88(s3)
    80001cac:	12068693          	addi	a3,a3,288
    80001cb0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001cb4:	6788                	ld	a0,8(a5)
    80001cb6:	6b8c                	ld	a1,16(a5)
    80001cb8:	6f90                	ld	a2,24(a5)
    80001cba:	01073023          	sd	a6,0(a4)
    80001cbe:	e708                	sd	a0,8(a4)
    80001cc0:	eb0c                	sd	a1,16(a4)
    80001cc2:	ef10                	sd	a2,24(a4)
    80001cc4:	02078793          	addi	a5,a5,32
    80001cc8:	02070713          	addi	a4,a4,32
    80001ccc:	fed792e3          	bne	a5,a3,80001cb0 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001cd0:	0589b783          	ld	a5,88(s3)
    80001cd4:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001cd8:	0d0a8493          	addi	s1,s5,208
    80001cdc:	0d098913          	addi	s2,s3,208
    80001ce0:	150a8a13          	addi	s4,s5,336
    80001ce4:	a831                	j	80001d00 <fork+0x9a>
    freeproc(np);
    80001ce6:	854e                	mv	a0,s3
    80001ce8:	d67ff0ef          	jal	80001a4e <freeproc>
    release(&np->lock);
    80001cec:	854e                	mv	a0,s3
    80001cee:	fa5fe0ef          	jal	80000c92 <release>
    return -1;
    80001cf2:	597d                	li	s2,-1
    80001cf4:	69e2                	ld	s3,24(sp)
    80001cf6:	a8a5                	j	80001d6e <fork+0x108>
  for (i = 0; i < NOFILE; i++)
    80001cf8:	04a1                	addi	s1,s1,8
    80001cfa:	0921                	addi	s2,s2,8
    80001cfc:	01448963          	beq	s1,s4,80001d0e <fork+0xa8>
    if (p->ofile[i])
    80001d00:	6088                	ld	a0,0(s1)
    80001d02:	d97d                	beqz	a0,80001cf8 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d04:	466020ef          	jal	8000416a <filedup>
    80001d08:	00a93023          	sd	a0,0(s2)
    80001d0c:	b7f5                	j	80001cf8 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001d0e:	150ab503          	ld	a0,336(s5)
    80001d12:	796010ef          	jal	800034a8 <idup>
    80001d16:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d1a:	4641                	li	a2,16
    80001d1c:	158a8593          	addi	a1,s5,344
    80001d20:	15898513          	addi	a0,s3,344
    80001d24:	8fcff0ef          	jal	80000e20 <safestrcpy>
  pid = np->pid;
    80001d28:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001d2c:	854e                	mv	a0,s3
    80001d2e:	f65fe0ef          	jal	80000c92 <release>
  acquire(&wait_lock);
    80001d32:	0000e497          	auipc	s1,0xe
    80001d36:	eb648493          	addi	s1,s1,-330 # 8000fbe8 <wait_lock>
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	ec3fe0ef          	jal	80000bfe <acquire>
  np->parent = p;
    80001d40:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d44:	8526                	mv	a0,s1
    80001d46:	f4dfe0ef          	jal	80000c92 <release>
  acquire(&np->lock);
    80001d4a:	854e                	mv	a0,s3
    80001d4c:	eb3fe0ef          	jal	80000bfe <acquire>
  np->state = RUNNABLE;
    80001d50:	478d                	li	a5,3
    80001d52:	00f9ac23          	sw	a5,24(s3)
  np->Current_tickets=p->Original_tickets;
    80001d56:	3c0aa783          	lw	a5,960(s5)
    80001d5a:	3cf9a223          	sw	a5,964(s3)
  np->Original_tickets=p->Original_tickets;
    80001d5e:	3cf9a023          	sw	a5,960(s3)
  release(&np->lock);
    80001d62:	854e                	mv	a0,s3
    80001d64:	f2ffe0ef          	jal	80000c92 <release>
  return pid;
    80001d68:	74a2                	ld	s1,40(sp)
    80001d6a:	69e2                	ld	s3,24(sp)
    80001d6c:	6a42                	ld	s4,16(sp)
}
    80001d6e:	854a                	mv	a0,s2
    80001d70:	70e2                	ld	ra,56(sp)
    80001d72:	7442                	ld	s0,48(sp)
    80001d74:	7902                	ld	s2,32(sp)
    80001d76:	6aa2                	ld	s5,8(sp)
    80001d78:	6121                	addi	sp,sp,64
    80001d7a:	8082                	ret
    return -1;
    80001d7c:	597d                	li	s2,-1
    80001d7e:	bfc5                	j	80001d6e <fork+0x108>

0000000080001d80 <scheduler>:
{
    80001d80:	7119                	addi	sp,sp,-128
    80001d82:	fc86                	sd	ra,120(sp)
    80001d84:	f8a2                	sd	s0,112(sp)
    80001d86:	f4a6                	sd	s1,104(sp)
    80001d88:	f0ca                	sd	s2,96(sp)
    80001d8a:	ecce                	sd	s3,88(sp)
    80001d8c:	e8d2                	sd	s4,80(sp)
    80001d8e:	e4d6                	sd	s5,72(sp)
    80001d90:	e0da                	sd	s6,64(sp)
    80001d92:	fc5e                	sd	s7,56(sp)
    80001d94:	f862                	sd	s8,48(sp)
    80001d96:	f466                	sd	s9,40(sp)
    80001d98:	f06a                	sd	s10,32(sp)
    80001d9a:	ec6e                	sd	s11,24(sp)
    80001d9c:	0100                	addi	s0,sp,128
    80001d9e:	8792                	mv	a5,tp
  int id = r_tp();
    80001da0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001da2:	00779693          	slli	a3,a5,0x7
    80001da6:	0000e717          	auipc	a4,0xe
    80001daa:	e2a70713          	addi	a4,a4,-470 # 8000fbd0 <pid_lock>
    80001dae:	9736                	add	a4,a4,a3
    80001db0:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001db4:	0000e717          	auipc	a4,0xe
    80001db8:	e5470713          	addi	a4,a4,-428 # 8000fc08 <cpus+0x8>
    80001dbc:	9736                	add	a4,a4,a3
    80001dbe:	f8e43423          	sd	a4,-120(s0)
    for (int i = 0; i < NPROC; i++)
    80001dc2:	04000c93          	li	s9,64
          c->proc = p;
    80001dc6:	0000ed17          	auipc	s10,0xe
    80001dca:	e0ad0d13          	addi	s10,s10,-502 # 8000fbd0 <pid_lock>
    80001dce:	9d36                	add	s10,s10,a3
    80001dd0:	a0ed                	j	80001eba <scheduler+0x13a>
        while (p->curr_runtime < TIME_LIMIT_2)
    80001dd2:	3d800713          	li	a4,984
    80001dd6:	02e48733          	mul	a4,s1,a4
    80001dda:	0000e797          	auipc	a5,0xe
    80001dde:	22678793          	addi	a5,a5,550 # 80010000 <proc>
    80001de2:	97ba                	add	a5,a5,a4
    80001de4:	3d07a703          	lw	a4,976(a5)
    80001de8:	4785                	li	a5,1
    80001dea:	08e7c463          	blt	a5,a4,80001e72 <scheduler+0xf2>
          swtch(&c->context, &p->context);
    80001dee:	0000e797          	auipc	a5,0xe
    80001df2:	27278793          	addi	a5,a5,626 # 80010060 <proc+0x60>
    80001df6:	9a3e                	add	s4,s4,a5
          p->state = RUNNING;
    80001df8:	3d800793          	li	a5,984
    80001dfc:	02f487b3          	mul	a5,s1,a5
    80001e00:	0000e997          	auipc	s3,0xe
    80001e04:	20098993          	addi	s3,s3,512 # 80010000 <proc>
    80001e08:	99be                	add	s3,s3,a5
        while (p->curr_runtime < TIME_LIMIT_2)
    80001e0a:	4a85                	li	s5,1
          p->state = RUNNING;
    80001e0c:	01b9ac23          	sw	s11,24(s3)
          c->proc = p;
    80001e10:	032d3823          	sd	s2,48(s10)
          swtch(&c->context, &p->context);
    80001e14:	85d2                	mv	a1,s4
    80001e16:	f8843503          	ld	a0,-120(s0)
    80001e1a:	676000ef          	jal	80002490 <swtch>
          c->proc = 0;
    80001e1e:	020d3823          	sd	zero,48(s10)
          p->time_slices++;
    80001e22:	3cc9a783          	lw	a5,972(s3)
    80001e26:	2785                	addiw	a5,a5,1
    80001e28:	3cf9a623          	sw	a5,972(s3)
          p->curr_runtime++;
    80001e2c:	3d09a783          	lw	a5,976(s3)
    80001e30:	2785                	addiw	a5,a5,1
    80001e32:	3cf9a823          	sw	a5,976(s3)
        while (p->curr_runtime < TIME_LIMIT_2)
    80001e36:	fcfadbe3          	bge	s5,a5,80001e0c <scheduler+0x8c>
        p->curr_runtime = 0;
    80001e3a:	3d800713          	li	a4,984
    80001e3e:	02e48733          	mul	a4,s1,a4
    80001e42:	0000e797          	auipc	a5,0xe
    80001e46:	1be78793          	addi	a5,a5,446 # 80010000 <proc>
    80001e4a:	97ba                	add	a5,a5,a4
    80001e4c:	3c07a823          	sw	zero,976(a5)
        last_idx = (idx + 1) % NPROC; // Next time, start from here
    80001e50:	2485                	addiw	s1,s1,1
    80001e52:	41f4d71b          	sraiw	a4,s1,0x1f
    80001e56:	01a7571b          	srliw	a4,a4,0x1a
    80001e5a:	9cb9                	addw	s1,s1,a4
    80001e5c:	03f4f793          	andi	a5,s1,63
    80001e60:	9f99                	subw	a5,a5,a4
    80001e62:	00006717          	auipc	a4,0x6
    80001e66:	c2f72b23          	sw	a5,-970(a4) # 80007a98 <last_idx.2>
        release(&p->lock);
    80001e6a:	854a                	mv	a0,s2
    80001e6c:	e27fe0ef          	jal	80000c92 <release>
    if (found == 0)
    80001e70:	a0b1                	j	80001ebc <scheduler+0x13c>
        p->curr_runtime = 0;
    80001e72:	3d800713          	li	a4,984
    80001e76:	02e48733          	mul	a4,s1,a4
    80001e7a:	0000e797          	auipc	a5,0xe
    80001e7e:	18678793          	addi	a5,a5,390 # 80010000 <proc>
    80001e82:	97ba                	add	a5,a5,a4
    80001e84:	3c07a823          	sw	zero,976(a5)
        last_idx = (idx + 1) % NPROC; // Next time, start from here
    80001e88:	2485                	addiw	s1,s1,1
    80001e8a:	41f4d71b          	sraiw	a4,s1,0x1f
    80001e8e:	01a7571b          	srliw	a4,a4,0x1a
    80001e92:	009707bb          	addw	a5,a4,s1
    80001e96:	03f7f793          	andi	a5,a5,63
    80001e9a:	9f99                	subw	a5,a5,a4
    80001e9c:	00006717          	auipc	a4,0x6
    80001ea0:	bef72e23          	sw	a5,-1028(a4) # 80007a98 <last_idx.2>
        release(&p->lock);
    80001ea4:	854a                	mv	a0,s2
    80001ea6:	dedfe0ef          	jal	80000c92 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eaa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001eae:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001eb2:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001eb6:	10500073          	wfi
          p->state = RUNNING;
    80001eba:	4d91                	li	s11,4
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ebc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ec0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ec4:	10079073          	csrw	sstatus,a5
    for (int i = 0; i < NPROC; i++)
    80001ec8:	4981                	li	s3,0
      int idx = (last_idx + i) % NPROC;
    80001eca:	00006c17          	auipc	s8,0x6
    80001ece:	bcec0c13          	addi	s8,s8,-1074 # 80007a98 <last_idx.2>
    80001ed2:	3d800b93          	li	s7,984
      p = &proc[idx];
    80001ed6:	0000eb17          	auipc	s6,0xe
    80001eda:	12ab0b13          	addi	s6,s6,298 # 80010000 <proc>
      if (p->state == RUNNABLE )
    80001ede:	4a8d                	li	s5,3
      int idx = (last_idx + i) % NPROC;
    80001ee0:	000c2483          	lw	s1,0(s8)
    80001ee4:	013484bb          	addw	s1,s1,s3
    80001ee8:	41f4d79b          	sraiw	a5,s1,0x1f
    80001eec:	01a7d79b          	srliw	a5,a5,0x1a
    80001ef0:	9cbd                	addw	s1,s1,a5
    80001ef2:	03f4f493          	andi	s1,s1,63
    80001ef6:	9c9d                	subw	s1,s1,a5
      p = &proc[idx];
    80001ef8:	03748a33          	mul	s4,s1,s7
    80001efc:	016a0933          	add	s2,s4,s6
      acquire(&p->lock);
    80001f00:	854a                	mv	a0,s2
    80001f02:	cfdfe0ef          	jal	80000bfe <acquire>
      if (p->state == RUNNABLE )
    80001f06:	01892783          	lw	a5,24(s2)
    80001f0a:	ed5784e3          	beq	a5,s5,80001dd2 <scheduler+0x52>
      release(&p->lock);
    80001f0e:	854a                	mv	a0,s2
    80001f10:	d83fe0ef          	jal	80000c92 <release>
    for (int i = 0; i < NPROC; i++)
    80001f14:	2985                	addiw	s3,s3,1
    80001f16:	fd9995e3          	bne	s3,s9,80001ee0 <scheduler+0x160>
    80001f1a:	bf41                	j	80001eaa <scheduler+0x12a>

0000000080001f1c <sched>:
{
    80001f1c:	7179                	addi	sp,sp,-48
    80001f1e:	f406                	sd	ra,40(sp)
    80001f20:	f022                	sd	s0,32(sp)
    80001f22:	ec26                	sd	s1,24(sp)
    80001f24:	e84a                	sd	s2,16(sp)
    80001f26:	e44e                	sd	s3,8(sp)
    80001f28:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f2a:	9b3ff0ef          	jal	800018dc <myproc>
    80001f2e:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f30:	c65fe0ef          	jal	80000b94 <holding>
    80001f34:	c92d                	beqz	a0,80001fa6 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f36:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f38:	2781                	sext.w	a5,a5
    80001f3a:	079e                	slli	a5,a5,0x7
    80001f3c:	0000e717          	auipc	a4,0xe
    80001f40:	c9470713          	addi	a4,a4,-876 # 8000fbd0 <pid_lock>
    80001f44:	97ba                	add	a5,a5,a4
    80001f46:	0a87a703          	lw	a4,168(a5)
    80001f4a:	4785                	li	a5,1
    80001f4c:	06f71363          	bne	a4,a5,80001fb2 <sched+0x96>
  if (p->state == RUNNING)
    80001f50:	4c98                	lw	a4,24(s1)
    80001f52:	4791                	li	a5,4
    80001f54:	06f70563          	beq	a4,a5,80001fbe <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f58:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f5c:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f5e:	e7b5                	bnez	a5,80001fca <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f60:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f62:	0000e917          	auipc	s2,0xe
    80001f66:	c6e90913          	addi	s2,s2,-914 # 8000fbd0 <pid_lock>
    80001f6a:	2781                	sext.w	a5,a5
    80001f6c:	079e                	slli	a5,a5,0x7
    80001f6e:	97ca                	add	a5,a5,s2
    80001f70:	0ac7a983          	lw	s3,172(a5)
    80001f74:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f76:	2781                	sext.w	a5,a5
    80001f78:	079e                	slli	a5,a5,0x7
    80001f7a:	0000e597          	auipc	a1,0xe
    80001f7e:	c8e58593          	addi	a1,a1,-882 # 8000fc08 <cpus+0x8>
    80001f82:	95be                	add	a1,a1,a5
    80001f84:	06048513          	addi	a0,s1,96
    80001f88:	508000ef          	jal	80002490 <swtch>
    80001f8c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f8e:	2781                	sext.w	a5,a5
    80001f90:	079e                	slli	a5,a5,0x7
    80001f92:	993e                	add	s2,s2,a5
    80001f94:	0b392623          	sw	s3,172(s2)
}
    80001f98:	70a2                	ld	ra,40(sp)
    80001f9a:	7402                	ld	s0,32(sp)
    80001f9c:	64e2                	ld	s1,24(sp)
    80001f9e:	6942                	ld	s2,16(sp)
    80001fa0:	69a2                	ld	s3,8(sp)
    80001fa2:	6145                	addi	sp,sp,48
    80001fa4:	8082                	ret
    panic("sched p->lock");
    80001fa6:	00005517          	auipc	a0,0x5
    80001faa:	29250513          	addi	a0,a0,658 # 80007238 <etext+0x238>
    80001fae:	ff0fe0ef          	jal	8000079e <panic>
    panic("sched locks");
    80001fb2:	00005517          	auipc	a0,0x5
    80001fb6:	29650513          	addi	a0,a0,662 # 80007248 <etext+0x248>
    80001fba:	fe4fe0ef          	jal	8000079e <panic>
    panic("sched running");
    80001fbe:	00005517          	auipc	a0,0x5
    80001fc2:	29a50513          	addi	a0,a0,666 # 80007258 <etext+0x258>
    80001fc6:	fd8fe0ef          	jal	8000079e <panic>
    panic("sched interruptible");
    80001fca:	00005517          	auipc	a0,0x5
    80001fce:	29e50513          	addi	a0,a0,670 # 80007268 <etext+0x268>
    80001fd2:	fccfe0ef          	jal	8000079e <panic>

0000000080001fd6 <yield>:
{
    80001fd6:	1101                	addi	sp,sp,-32
    80001fd8:	ec06                	sd	ra,24(sp)
    80001fda:	e822                	sd	s0,16(sp)
    80001fdc:	e426                	sd	s1,8(sp)
    80001fde:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fe0:	8fdff0ef          	jal	800018dc <myproc>
    80001fe4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fe6:	c19fe0ef          	jal	80000bfe <acquire>
  p->state = RUNNABLE;
    80001fea:	478d                	li	a5,3
    80001fec:	cc9c                	sw	a5,24(s1)
  sched();
    80001fee:	f2fff0ef          	jal	80001f1c <sched>
  release(&p->lock);
    80001ff2:	8526                	mv	a0,s1
    80001ff4:	c9ffe0ef          	jal	80000c92 <release>
}
    80001ff8:	60e2                	ld	ra,24(sp)
    80001ffa:	6442                	ld	s0,16(sp)
    80001ffc:	64a2                	ld	s1,8(sp)
    80001ffe:	6105                	addi	sp,sp,32
    80002000:	8082                	ret

0000000080002002 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002002:	7179                	addi	sp,sp,-48
    80002004:	f406                	sd	ra,40(sp)
    80002006:	f022                	sd	s0,32(sp)
    80002008:	ec26                	sd	s1,24(sp)
    8000200a:	e84a                	sd	s2,16(sp)
    8000200c:	e44e                	sd	s3,8(sp)
    8000200e:	1800                	addi	s0,sp,48
    80002010:	89aa                	mv	s3,a0
    80002012:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002014:	8c9ff0ef          	jal	800018dc <myproc>
    80002018:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000201a:	be5fe0ef          	jal	80000bfe <acquire>
  release(lk);
    8000201e:	854a                	mv	a0,s2
    80002020:	c73fe0ef          	jal	80000c92 <release>

  // Go to sleep.
  p->chan = chan;
    80002024:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002028:	4789                	li	a5,2
    8000202a:	cc9c                	sw	a5,24(s1)

  sched();
    8000202c:	ef1ff0ef          	jal	80001f1c <sched>

  // Tidy up.
  p->chan = 0;
    80002030:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002034:	8526                	mv	a0,s1
    80002036:	c5dfe0ef          	jal	80000c92 <release>
  acquire(lk);
    8000203a:	854a                	mv	a0,s2
    8000203c:	bc3fe0ef          	jal	80000bfe <acquire>
}
    80002040:	70a2                	ld	ra,40(sp)
    80002042:	7402                	ld	s0,32(sp)
    80002044:	64e2                	ld	s1,24(sp)
    80002046:	6942                	ld	s2,16(sp)
    80002048:	69a2                	ld	s3,8(sp)
    8000204a:	6145                	addi	sp,sp,48
    8000204c:	8082                	ret

000000008000204e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000204e:	7139                	addi	sp,sp,-64
    80002050:	fc06                	sd	ra,56(sp)
    80002052:	f822                	sd	s0,48(sp)
    80002054:	f426                	sd	s1,40(sp)
    80002056:	f04a                	sd	s2,32(sp)
    80002058:	ec4e                	sd	s3,24(sp)
    8000205a:	e852                	sd	s4,16(sp)
    8000205c:	e456                	sd	s5,8(sp)
    8000205e:	0080                	addi	s0,sp,64
    80002060:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002062:	0000e497          	auipc	s1,0xe
    80002066:	f9e48493          	addi	s1,s1,-98 # 80010000 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    8000206a:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    8000206c:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000206e:	0001d917          	auipc	s2,0x1d
    80002072:	59290913          	addi	s2,s2,1426 # 8001f600 <tickslock>
    80002076:	a801                	j	80002086 <wakeup+0x38>
      }
      release(&p->lock);
    80002078:	8526                	mv	a0,s1
    8000207a:	c19fe0ef          	jal	80000c92 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000207e:	3d848493          	addi	s1,s1,984
    80002082:	03248263          	beq	s1,s2,800020a6 <wakeup+0x58>
    if (p != myproc())
    80002086:	857ff0ef          	jal	800018dc <myproc>
    8000208a:	fea48ae3          	beq	s1,a0,8000207e <wakeup+0x30>
      acquire(&p->lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	b6ffe0ef          	jal	80000bfe <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002094:	4c9c                	lw	a5,24(s1)
    80002096:	ff3791e3          	bne	a5,s3,80002078 <wakeup+0x2a>
    8000209a:	709c                	ld	a5,32(s1)
    8000209c:	fd479ee3          	bne	a5,s4,80002078 <wakeup+0x2a>
        p->state = RUNNABLE;
    800020a0:	0154ac23          	sw	s5,24(s1)
    800020a4:	bfd1                	j	80002078 <wakeup+0x2a>
    }
  }
}
    800020a6:	70e2                	ld	ra,56(sp)
    800020a8:	7442                	ld	s0,48(sp)
    800020aa:	74a2                	ld	s1,40(sp)
    800020ac:	7902                	ld	s2,32(sp)
    800020ae:	69e2                	ld	s3,24(sp)
    800020b0:	6a42                	ld	s4,16(sp)
    800020b2:	6aa2                	ld	s5,8(sp)
    800020b4:	6121                	addi	sp,sp,64
    800020b6:	8082                	ret

00000000800020b8 <reparent>:
{
    800020b8:	7179                	addi	sp,sp,-48
    800020ba:	f406                	sd	ra,40(sp)
    800020bc:	f022                	sd	s0,32(sp)
    800020be:	ec26                	sd	s1,24(sp)
    800020c0:	e84a                	sd	s2,16(sp)
    800020c2:	e44e                	sd	s3,8(sp)
    800020c4:	e052                	sd	s4,0(sp)
    800020c6:	1800                	addi	s0,sp,48
    800020c8:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800020ca:	0000e497          	auipc	s1,0xe
    800020ce:	f3648493          	addi	s1,s1,-202 # 80010000 <proc>
      pp->parent = initproc;
    800020d2:	00006a17          	auipc	s4,0x6
    800020d6:	9cea0a13          	addi	s4,s4,-1586 # 80007aa0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800020da:	0001d997          	auipc	s3,0x1d
    800020de:	52698993          	addi	s3,s3,1318 # 8001f600 <tickslock>
    800020e2:	a029                	j	800020ec <reparent+0x34>
    800020e4:	3d848493          	addi	s1,s1,984
    800020e8:	01348b63          	beq	s1,s3,800020fe <reparent+0x46>
    if (pp->parent == p)
    800020ec:	7c9c                	ld	a5,56(s1)
    800020ee:	ff279be3          	bne	a5,s2,800020e4 <reparent+0x2c>
      pp->parent = initproc;
    800020f2:	000a3503          	ld	a0,0(s4)
    800020f6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020f8:	f57ff0ef          	jal	8000204e <wakeup>
    800020fc:	b7e5                	j	800020e4 <reparent+0x2c>
}
    800020fe:	70a2                	ld	ra,40(sp)
    80002100:	7402                	ld	s0,32(sp)
    80002102:	64e2                	ld	s1,24(sp)
    80002104:	6942                	ld	s2,16(sp)
    80002106:	69a2                	ld	s3,8(sp)
    80002108:	6a02                	ld	s4,0(sp)
    8000210a:	6145                	addi	sp,sp,48
    8000210c:	8082                	ret

000000008000210e <exit>:
{
    8000210e:	7179                	addi	sp,sp,-48
    80002110:	f406                	sd	ra,40(sp)
    80002112:	f022                	sd	s0,32(sp)
    80002114:	ec26                	sd	s1,24(sp)
    80002116:	e84a                	sd	s2,16(sp)
    80002118:	e44e                	sd	s3,8(sp)
    8000211a:	e052                	sd	s4,0(sp)
    8000211c:	1800                	addi	s0,sp,48
    8000211e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002120:	fbcff0ef          	jal	800018dc <myproc>
    80002124:	89aa                	mv	s3,a0
  if (p == initproc)
    80002126:	00006797          	auipc	a5,0x6
    8000212a:	97a7b783          	ld	a5,-1670(a5) # 80007aa0 <initproc>
    8000212e:	0d050493          	addi	s1,a0,208
    80002132:	15050913          	addi	s2,a0,336
    80002136:	00a79b63          	bne	a5,a0,8000214c <exit+0x3e>
    panic("init exiting");
    8000213a:	00005517          	auipc	a0,0x5
    8000213e:	14650513          	addi	a0,a0,326 # 80007280 <etext+0x280>
    80002142:	e5cfe0ef          	jal	8000079e <panic>
  for (int fd = 0; fd < NOFILE; fd++)
    80002146:	04a1                	addi	s1,s1,8
    80002148:	01248963          	beq	s1,s2,8000215a <exit+0x4c>
    if (p->ofile[fd])
    8000214c:	6088                	ld	a0,0(s1)
    8000214e:	dd65                	beqz	a0,80002146 <exit+0x38>
      fileclose(f);
    80002150:	060020ef          	jal	800041b0 <fileclose>
      p->ofile[fd] = 0;
    80002154:	0004b023          	sd	zero,0(s1)
    80002158:	b7fd                	j	80002146 <exit+0x38>
  begin_op();
    8000215a:	437010ef          	jal	80003d90 <begin_op>
  iput(p->cwd);
    8000215e:	1509b503          	ld	a0,336(s3)
    80002162:	4fe010ef          	jal	80003660 <iput>
  end_op();
    80002166:	495010ef          	jal	80003dfa <end_op>
  p->cwd = 0;
    8000216a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000216e:	0000e497          	auipc	s1,0xe
    80002172:	a7a48493          	addi	s1,s1,-1414 # 8000fbe8 <wait_lock>
    80002176:	8526                	mv	a0,s1
    80002178:	a87fe0ef          	jal	80000bfe <acquire>
  reparent(p);
    8000217c:	854e                	mv	a0,s3
    8000217e:	f3bff0ef          	jal	800020b8 <reparent>
  wakeup(p->parent);
    80002182:	0389b503          	ld	a0,56(s3)
    80002186:	ec9ff0ef          	jal	8000204e <wakeup>
  acquire(&p->lock);
    8000218a:	854e                	mv	a0,s3
    8000218c:	a73fe0ef          	jal	80000bfe <acquire>
  p->xstate = status;
    80002190:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002194:	4795                	li	a5,5
    80002196:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000219a:	8526                	mv	a0,s1
    8000219c:	af7fe0ef          	jal	80000c92 <release>
  sched();
    800021a0:	d7dff0ef          	jal	80001f1c <sched>
  panic("zombie exit");
    800021a4:	00005517          	auipc	a0,0x5
    800021a8:	0ec50513          	addi	a0,a0,236 # 80007290 <etext+0x290>
    800021ac:	df2fe0ef          	jal	8000079e <panic>

00000000800021b0 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800021b0:	7179                	addi	sp,sp,-48
    800021b2:	f406                	sd	ra,40(sp)
    800021b4:	f022                	sd	s0,32(sp)
    800021b6:	ec26                	sd	s1,24(sp)
    800021b8:	e84a                	sd	s2,16(sp)
    800021ba:	e44e                	sd	s3,8(sp)
    800021bc:	1800                	addi	s0,sp,48
    800021be:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800021c0:	0000e497          	auipc	s1,0xe
    800021c4:	e4048493          	addi	s1,s1,-448 # 80010000 <proc>
    800021c8:	0001d997          	auipc	s3,0x1d
    800021cc:	43898993          	addi	s3,s3,1080 # 8001f600 <tickslock>
  {
    acquire(&p->lock);
    800021d0:	8526                	mv	a0,s1
    800021d2:	a2dfe0ef          	jal	80000bfe <acquire>
    if (p->pid == pid)
    800021d6:	589c                	lw	a5,48(s1)
    800021d8:	01278b63          	beq	a5,s2,800021ee <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021dc:	8526                	mv	a0,s1
    800021de:	ab5fe0ef          	jal	80000c92 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800021e2:	3d848493          	addi	s1,s1,984
    800021e6:	ff3495e3          	bne	s1,s3,800021d0 <kill+0x20>
  }
  return -1;
    800021ea:	557d                	li	a0,-1
    800021ec:	a819                	j	80002202 <kill+0x52>
      p->killed = 1;
    800021ee:	4785                	li	a5,1
    800021f0:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800021f2:	4c98                	lw	a4,24(s1)
    800021f4:	4789                	li	a5,2
    800021f6:	00f70d63          	beq	a4,a5,80002210 <kill+0x60>
      release(&p->lock);
    800021fa:	8526                	mv	a0,s1
    800021fc:	a97fe0ef          	jal	80000c92 <release>
      return 0;
    80002200:	4501                	li	a0,0
}
    80002202:	70a2                	ld	ra,40(sp)
    80002204:	7402                	ld	s0,32(sp)
    80002206:	64e2                	ld	s1,24(sp)
    80002208:	6942                	ld	s2,16(sp)
    8000220a:	69a2                	ld	s3,8(sp)
    8000220c:	6145                	addi	sp,sp,48
    8000220e:	8082                	ret
        p->state = RUNNABLE;
    80002210:	478d                	li	a5,3
    80002212:	cc9c                	sw	a5,24(s1)
    80002214:	b7dd                	j	800021fa <kill+0x4a>

0000000080002216 <setkilled>:

void setkilled(struct proc *p)
{
    80002216:	1101                	addi	sp,sp,-32
    80002218:	ec06                	sd	ra,24(sp)
    8000221a:	e822                	sd	s0,16(sp)
    8000221c:	e426                	sd	s1,8(sp)
    8000221e:	1000                	addi	s0,sp,32
    80002220:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002222:	9ddfe0ef          	jal	80000bfe <acquire>
  p->killed = 1;
    80002226:	4785                	li	a5,1
    80002228:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000222a:	8526                	mv	a0,s1
    8000222c:	a67fe0ef          	jal	80000c92 <release>
}
    80002230:	60e2                	ld	ra,24(sp)
    80002232:	6442                	ld	s0,16(sp)
    80002234:	64a2                	ld	s1,8(sp)
    80002236:	6105                	addi	sp,sp,32
    80002238:	8082                	ret

000000008000223a <killed>:

int killed(struct proc *p)
{
    8000223a:	1101                	addi	sp,sp,-32
    8000223c:	ec06                	sd	ra,24(sp)
    8000223e:	e822                	sd	s0,16(sp)
    80002240:	e426                	sd	s1,8(sp)
    80002242:	e04a                	sd	s2,0(sp)
    80002244:	1000                	addi	s0,sp,32
    80002246:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002248:	9b7fe0ef          	jal	80000bfe <acquire>
  k = p->killed;
    8000224c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002250:	8526                	mv	a0,s1
    80002252:	a41fe0ef          	jal	80000c92 <release>
  return k;
}
    80002256:	854a                	mv	a0,s2
    80002258:	60e2                	ld	ra,24(sp)
    8000225a:	6442                	ld	s0,16(sp)
    8000225c:	64a2                	ld	s1,8(sp)
    8000225e:	6902                	ld	s2,0(sp)
    80002260:	6105                	addi	sp,sp,32
    80002262:	8082                	ret

0000000080002264 <wait>:
{
    80002264:	715d                	addi	sp,sp,-80
    80002266:	e486                	sd	ra,72(sp)
    80002268:	e0a2                	sd	s0,64(sp)
    8000226a:	fc26                	sd	s1,56(sp)
    8000226c:	f84a                	sd	s2,48(sp)
    8000226e:	f44e                	sd	s3,40(sp)
    80002270:	f052                	sd	s4,32(sp)
    80002272:	ec56                	sd	s5,24(sp)
    80002274:	e85a                	sd	s6,16(sp)
    80002276:	e45e                	sd	s7,8(sp)
    80002278:	0880                	addi	s0,sp,80
    8000227a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000227c:	e60ff0ef          	jal	800018dc <myproc>
    80002280:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002282:	0000e517          	auipc	a0,0xe
    80002286:	96650513          	addi	a0,a0,-1690 # 8000fbe8 <wait_lock>
    8000228a:	975fe0ef          	jal	80000bfe <acquire>
        if (pp->state == ZOMBIE)
    8000228e:	4a15                	li	s4,5
        havekids = 1;
    80002290:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002292:	0001d997          	auipc	s3,0x1d
    80002296:	36e98993          	addi	s3,s3,878 # 8001f600 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000229a:	0000eb97          	auipc	s7,0xe
    8000229e:	94eb8b93          	addi	s7,s7,-1714 # 8000fbe8 <wait_lock>
    800022a2:	a869                	j	8000233c <wait+0xd8>
          pid = pp->pid;
    800022a4:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800022a8:	000b0c63          	beqz	s6,800022c0 <wait+0x5c>
    800022ac:	4691                	li	a3,4
    800022ae:	02c48613          	addi	a2,s1,44
    800022b2:	85da                	mv	a1,s6
    800022b4:	05093503          	ld	a0,80(s2)
    800022b8:	accff0ef          	jal	80001584 <copyout>
    800022bc:	02054a63          	bltz	a0,800022f0 <wait+0x8c>
          freeproc(pp);
    800022c0:	8526                	mv	a0,s1
    800022c2:	f8cff0ef          	jal	80001a4e <freeproc>
          release(&pp->lock);
    800022c6:	8526                	mv	a0,s1
    800022c8:	9cbfe0ef          	jal	80000c92 <release>
          release(&wait_lock);
    800022cc:	0000e517          	auipc	a0,0xe
    800022d0:	91c50513          	addi	a0,a0,-1764 # 8000fbe8 <wait_lock>
    800022d4:	9bffe0ef          	jal	80000c92 <release>
}
    800022d8:	854e                	mv	a0,s3
    800022da:	60a6                	ld	ra,72(sp)
    800022dc:	6406                	ld	s0,64(sp)
    800022de:	74e2                	ld	s1,56(sp)
    800022e0:	7942                	ld	s2,48(sp)
    800022e2:	79a2                	ld	s3,40(sp)
    800022e4:	7a02                	ld	s4,32(sp)
    800022e6:	6ae2                	ld	s5,24(sp)
    800022e8:	6b42                	ld	s6,16(sp)
    800022ea:	6ba2                	ld	s7,8(sp)
    800022ec:	6161                	addi	sp,sp,80
    800022ee:	8082                	ret
            release(&pp->lock);
    800022f0:	8526                	mv	a0,s1
    800022f2:	9a1fe0ef          	jal	80000c92 <release>
            release(&wait_lock);
    800022f6:	0000e517          	auipc	a0,0xe
    800022fa:	8f250513          	addi	a0,a0,-1806 # 8000fbe8 <wait_lock>
    800022fe:	995fe0ef          	jal	80000c92 <release>
            return -1;
    80002302:	59fd                	li	s3,-1
    80002304:	bfd1                	j	800022d8 <wait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002306:	3d848493          	addi	s1,s1,984
    8000230a:	03348063          	beq	s1,s3,8000232a <wait+0xc6>
      if (pp->parent == p)
    8000230e:	7c9c                	ld	a5,56(s1)
    80002310:	ff279be3          	bne	a5,s2,80002306 <wait+0xa2>
        acquire(&pp->lock);
    80002314:	8526                	mv	a0,s1
    80002316:	8e9fe0ef          	jal	80000bfe <acquire>
        if (pp->state == ZOMBIE)
    8000231a:	4c9c                	lw	a5,24(s1)
    8000231c:	f94784e3          	beq	a5,s4,800022a4 <wait+0x40>
        release(&pp->lock);
    80002320:	8526                	mv	a0,s1
    80002322:	971fe0ef          	jal	80000c92 <release>
        havekids = 1;
    80002326:	8756                	mv	a4,s5
    80002328:	bff9                	j	80002306 <wait+0xa2>
    if (!havekids || killed(p))
    8000232a:	cf19                	beqz	a4,80002348 <wait+0xe4>
    8000232c:	854a                	mv	a0,s2
    8000232e:	f0dff0ef          	jal	8000223a <killed>
    80002332:	e919                	bnez	a0,80002348 <wait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002334:	85de                	mv	a1,s7
    80002336:	854a                	mv	a0,s2
    80002338:	ccbff0ef          	jal	80002002 <sleep>
    havekids = 0;
    8000233c:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000233e:	0000e497          	auipc	s1,0xe
    80002342:	cc248493          	addi	s1,s1,-830 # 80010000 <proc>
    80002346:	b7e1                	j	8000230e <wait+0xaa>
      release(&wait_lock);
    80002348:	0000e517          	auipc	a0,0xe
    8000234c:	8a050513          	addi	a0,a0,-1888 # 8000fbe8 <wait_lock>
    80002350:	943fe0ef          	jal	80000c92 <release>
      return -1;
    80002354:	59fd                	li	s3,-1
    80002356:	b749                	j	800022d8 <wait+0x74>

0000000080002358 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002358:	7179                	addi	sp,sp,-48
    8000235a:	f406                	sd	ra,40(sp)
    8000235c:	f022                	sd	s0,32(sp)
    8000235e:	ec26                	sd	s1,24(sp)
    80002360:	e84a                	sd	s2,16(sp)
    80002362:	e44e                	sd	s3,8(sp)
    80002364:	e052                	sd	s4,0(sp)
    80002366:	1800                	addi	s0,sp,48
    80002368:	84aa                	mv	s1,a0
    8000236a:	892e                	mv	s2,a1
    8000236c:	89b2                	mv	s3,a2
    8000236e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002370:	d6cff0ef          	jal	800018dc <myproc>
  if (user_dst)
    80002374:	cc99                	beqz	s1,80002392 <either_copyout+0x3a>
  {
    return copyout(p->pagetable, dst, src, len);
    80002376:	86d2                	mv	a3,s4
    80002378:	864e                	mv	a2,s3
    8000237a:	85ca                	mv	a1,s2
    8000237c:	6928                	ld	a0,80(a0)
    8000237e:	a06ff0ef          	jal	80001584 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002382:	70a2                	ld	ra,40(sp)
    80002384:	7402                	ld	s0,32(sp)
    80002386:	64e2                	ld	s1,24(sp)
    80002388:	6942                	ld	s2,16(sp)
    8000238a:	69a2                	ld	s3,8(sp)
    8000238c:	6a02                	ld	s4,0(sp)
    8000238e:	6145                	addi	sp,sp,48
    80002390:	8082                	ret
    memmove((char *)dst, src, len);
    80002392:	000a061b          	sext.w	a2,s4
    80002396:	85ce                	mv	a1,s3
    80002398:	854a                	mv	a0,s2
    8000239a:	999fe0ef          	jal	80000d32 <memmove>
    return 0;
    8000239e:	8526                	mv	a0,s1
    800023a0:	b7cd                	j	80002382 <either_copyout+0x2a>

00000000800023a2 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023a2:	7179                	addi	sp,sp,-48
    800023a4:	f406                	sd	ra,40(sp)
    800023a6:	f022                	sd	s0,32(sp)
    800023a8:	ec26                	sd	s1,24(sp)
    800023aa:	e84a                	sd	s2,16(sp)
    800023ac:	e44e                	sd	s3,8(sp)
    800023ae:	e052                	sd	s4,0(sp)
    800023b0:	1800                	addi	s0,sp,48
    800023b2:	892a                	mv	s2,a0
    800023b4:	84ae                	mv	s1,a1
    800023b6:	89b2                	mv	s3,a2
    800023b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800023ba:	d22ff0ef          	jal	800018dc <myproc>
  if (user_src)
    800023be:	cc99                	beqz	s1,800023dc <either_copyin+0x3a>
  {
    return copyin(p->pagetable, dst, src, len);
    800023c0:	86d2                	mv	a3,s4
    800023c2:	864e                	mv	a2,s3
    800023c4:	85ca                	mv	a1,s2
    800023c6:	6928                	ld	a0,80(a0)
    800023c8:	a6cff0ef          	jal	80001634 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800023cc:	70a2                	ld	ra,40(sp)
    800023ce:	7402                	ld	s0,32(sp)
    800023d0:	64e2                	ld	s1,24(sp)
    800023d2:	6942                	ld	s2,16(sp)
    800023d4:	69a2                	ld	s3,8(sp)
    800023d6:	6a02                	ld	s4,0(sp)
    800023d8:	6145                	addi	sp,sp,48
    800023da:	8082                	ret
    memmove(dst, (char *)src, len);
    800023dc:	000a061b          	sext.w	a2,s4
    800023e0:	85ce                	mv	a1,s3
    800023e2:	854a                	mv	a0,s2
    800023e4:	94ffe0ef          	jal	80000d32 <memmove>
    return 0;
    800023e8:	8526                	mv	a0,s1
    800023ea:	b7cd                	j	800023cc <either_copyin+0x2a>

00000000800023ec <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800023ec:	715d                	addi	sp,sp,-80
    800023ee:	e486                	sd	ra,72(sp)
    800023f0:	e0a2                	sd	s0,64(sp)
    800023f2:	fc26                	sd	s1,56(sp)
    800023f4:	f84a                	sd	s2,48(sp)
    800023f6:	f44e                	sd	s3,40(sp)
    800023f8:	f052                	sd	s4,32(sp)
    800023fa:	ec56                	sd	s5,24(sp)
    800023fc:	e85a                	sd	s6,16(sp)
    800023fe:	e45e                	sd	s7,8(sp)
    80002400:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002402:	00005517          	auipc	a0,0x5
    80002406:	c7650513          	addi	a0,a0,-906 # 80007078 <etext+0x78>
    8000240a:	8c4fe0ef          	jal	800004ce <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000240e:	0000e497          	auipc	s1,0xe
    80002412:	d4a48493          	addi	s1,s1,-694 # 80010158 <proc+0x158>
    80002416:	0001d917          	auipc	s2,0x1d
    8000241a:	34290913          	addi	s2,s2,834 # 8001f758 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000241e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002420:	00005997          	auipc	s3,0x5
    80002424:	e8098993          	addi	s3,s3,-384 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002428:	00005a97          	auipc	s5,0x5
    8000242c:	e80a8a93          	addi	s5,s5,-384 # 800072a8 <etext+0x2a8>
    printf("\n");
    80002430:	00005a17          	auipc	s4,0x5
    80002434:	c48a0a13          	addi	s4,s4,-952 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002438:	00005b97          	auipc	s7,0x5
    8000243c:	410b8b93          	addi	s7,s7,1040 # 80007848 <syscall_names>
    80002440:	a829                	j	8000245a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002442:	ed86a583          	lw	a1,-296(a3)
    80002446:	8556                	mv	a0,s5
    80002448:	886fe0ef          	jal	800004ce <printf>
    printf("\n");
    8000244c:	8552                	mv	a0,s4
    8000244e:	880fe0ef          	jal	800004ce <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002452:	3d848493          	addi	s1,s1,984
    80002456:	03248263          	beq	s1,s2,8000247a <procdump+0x8e>
    if (p->state == UNUSED)
    8000245a:	86a6                	mv	a3,s1
    8000245c:	ec04a783          	lw	a5,-320(s1)
    80002460:	dbed                	beqz	a5,80002452 <procdump+0x66>
      state = "???";
    80002462:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002464:	fcfb6fe3          	bltu	s6,a5,80002442 <procdump+0x56>
    80002468:	02079713          	slli	a4,a5,0x20
    8000246c:	01d75793          	srli	a5,a4,0x1d
    80002470:	97de                	add	a5,a5,s7
    80002472:	67f0                	ld	a2,200(a5)
    80002474:	f679                	bnez	a2,80002442 <procdump+0x56>
      state = "???";
    80002476:	864e                	mv	a2,s3
    80002478:	b7e9                	j	80002442 <procdump+0x56>
  }
}
    8000247a:	60a6                	ld	ra,72(sp)
    8000247c:	6406                	ld	s0,64(sp)
    8000247e:	74e2                	ld	s1,56(sp)
    80002480:	7942                	ld	s2,48(sp)
    80002482:	79a2                	ld	s3,40(sp)
    80002484:	7a02                	ld	s4,32(sp)
    80002486:	6ae2                	ld	s5,24(sp)
    80002488:	6b42                	ld	s6,16(sp)
    8000248a:	6ba2                	ld	s7,8(sp)
    8000248c:	6161                	addi	sp,sp,80
    8000248e:	8082                	ret

0000000080002490 <swtch>:
    80002490:	00153023          	sd	ra,0(a0)
    80002494:	00253423          	sd	sp,8(a0)
    80002498:	e900                	sd	s0,16(a0)
    8000249a:	ed04                	sd	s1,24(a0)
    8000249c:	03253023          	sd	s2,32(a0)
    800024a0:	03353423          	sd	s3,40(a0)
    800024a4:	03453823          	sd	s4,48(a0)
    800024a8:	03553c23          	sd	s5,56(a0)
    800024ac:	05653023          	sd	s6,64(a0)
    800024b0:	05753423          	sd	s7,72(a0)
    800024b4:	05853823          	sd	s8,80(a0)
    800024b8:	05953c23          	sd	s9,88(a0)
    800024bc:	07a53023          	sd	s10,96(a0)
    800024c0:	07b53423          	sd	s11,104(a0)
    800024c4:	0005b083          	ld	ra,0(a1)
    800024c8:	0085b103          	ld	sp,8(a1)
    800024cc:	6980                	ld	s0,16(a1)
    800024ce:	6d84                	ld	s1,24(a1)
    800024d0:	0205b903          	ld	s2,32(a1)
    800024d4:	0285b983          	ld	s3,40(a1)
    800024d8:	0305ba03          	ld	s4,48(a1)
    800024dc:	0385ba83          	ld	s5,56(a1)
    800024e0:	0405bb03          	ld	s6,64(a1)
    800024e4:	0485bb83          	ld	s7,72(a1)
    800024e8:	0505bc03          	ld	s8,80(a1)
    800024ec:	0585bc83          	ld	s9,88(a1)
    800024f0:	0605bd03          	ld	s10,96(a1)
    800024f4:	0685bd83          	ld	s11,104(a1)
    800024f8:	8082                	ret

00000000800024fa <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024fa:	1141                	addi	sp,sp,-16
    800024fc:	e406                	sd	ra,8(sp)
    800024fe:	e022                	sd	s0,0(sp)
    80002500:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002502:	00005597          	auipc	a1,0x5
    80002506:	eae58593          	addi	a1,a1,-338 # 800073b0 <etext+0x3b0>
    8000250a:	0001d517          	auipc	a0,0x1d
    8000250e:	0f650513          	addi	a0,a0,246 # 8001f600 <tickslock>
    80002512:	e68fe0ef          	jal	80000b7a <initlock>
}
    80002516:	60a2                	ld	ra,8(sp)
    80002518:	6402                	ld	s0,0(sp)
    8000251a:	0141                	addi	sp,sp,16
    8000251c:	8082                	ret

000000008000251e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000251e:	1141                	addi	sp,sp,-16
    80002520:	e406                	sd	ra,8(sp)
    80002522:	e022                	sd	s0,0(sp)
    80002524:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002526:	00003797          	auipc	a5,0x3
    8000252a:	03a78793          	addi	a5,a5,58 # 80005560 <kernelvec>
    8000252e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002532:	60a2                	ld	ra,8(sp)
    80002534:	6402                	ld	s0,0(sp)
    80002536:	0141                	addi	sp,sp,16
    80002538:	8082                	ret

000000008000253a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000253a:	1141                	addi	sp,sp,-16
    8000253c:	e406                	sd	ra,8(sp)
    8000253e:	e022                	sd	s0,0(sp)
    80002540:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002542:	b9aff0ef          	jal	800018dc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002546:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000254a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000254c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002550:	00004697          	auipc	a3,0x4
    80002554:	ab068693          	addi	a3,a3,-1360 # 80006000 <_trampoline>
    80002558:	00004717          	auipc	a4,0x4
    8000255c:	aa870713          	addi	a4,a4,-1368 # 80006000 <_trampoline>
    80002560:	8f15                	sub	a4,a4,a3
    80002562:	040007b7          	lui	a5,0x4000
    80002566:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002568:	07b2                	slli	a5,a5,0xc
    8000256a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000256c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002570:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002572:	18002673          	csrr	a2,satp
    80002576:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002578:	6d30                	ld	a2,88(a0)
    8000257a:	6138                	ld	a4,64(a0)
    8000257c:	6585                	lui	a1,0x1
    8000257e:	972e                	add	a4,a4,a1
    80002580:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002582:	6d38                	ld	a4,88(a0)
    80002584:	00000617          	auipc	a2,0x0
    80002588:	11060613          	addi	a2,a2,272 # 80002694 <usertrap>
    8000258c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000258e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002590:	8612                	mv	a2,tp
    80002592:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002594:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002598:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000259c:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025a0:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025a4:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800025a6:	6f18                	ld	a4,24(a4)
    800025a8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800025ac:	6928                	ld	a0,80(a0)
    800025ae:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800025b0:	00004717          	auipc	a4,0x4
    800025b4:	aec70713          	addi	a4,a4,-1300 # 8000609c <userret>
    800025b8:	8f15                	sub	a4,a4,a3
    800025ba:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800025bc:	577d                	li	a4,-1
    800025be:	177e                	slli	a4,a4,0x3f
    800025c0:	8d59                	or	a0,a0,a4
    800025c2:	9782                	jalr	a5
}
    800025c4:	60a2                	ld	ra,8(sp)
    800025c6:	6402                	ld	s0,0(sp)
    800025c8:	0141                	addi	sp,sp,16
    800025ca:	8082                	ret

00000000800025cc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025cc:	1101                	addi	sp,sp,-32
    800025ce:	ec06                	sd	ra,24(sp)
    800025d0:	e822                	sd	s0,16(sp)
    800025d2:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800025d4:	ad4ff0ef          	jal	800018a8 <cpuid>
    800025d8:	cd11                	beqz	a0,800025f4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800025da:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800025de:	000f4737          	lui	a4,0xf4
    800025e2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025e6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800025e8:	14d79073          	csrw	stimecmp,a5
}
    800025ec:	60e2                	ld	ra,24(sp)
    800025ee:	6442                	ld	s0,16(sp)
    800025f0:	6105                	addi	sp,sp,32
    800025f2:	8082                	ret
    800025f4:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800025f6:	0001d497          	auipc	s1,0x1d
    800025fa:	00a48493          	addi	s1,s1,10 # 8001f600 <tickslock>
    800025fe:	8526                	mv	a0,s1
    80002600:	dfefe0ef          	jal	80000bfe <acquire>
    ticks++;
    80002604:	00005517          	auipc	a0,0x5
    80002608:	4a450513          	addi	a0,a0,1188 # 80007aa8 <ticks>
    8000260c:	411c                	lw	a5,0(a0)
    8000260e:	2785                	addiw	a5,a5,1
    80002610:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002612:	a3dff0ef          	jal	8000204e <wakeup>
    release(&tickslock);
    80002616:	8526                	mv	a0,s1
    80002618:	e7afe0ef          	jal	80000c92 <release>
    8000261c:	64a2                	ld	s1,8(sp)
    8000261e:	bf75                	j	800025da <clockintr+0xe>

0000000080002620 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002620:	1101                	addi	sp,sp,-32
    80002622:	ec06                	sd	ra,24(sp)
    80002624:	e822                	sd	s0,16(sp)
    80002626:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002628:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000262c:	57fd                	li	a5,-1
    8000262e:	17fe                	slli	a5,a5,0x3f
    80002630:	07a5                	addi	a5,a5,9
    80002632:	00f70c63          	beq	a4,a5,8000264a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002636:	57fd                	li	a5,-1
    80002638:	17fe                	slli	a5,a5,0x3f
    8000263a:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000263c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000263e:	04f70763          	beq	a4,a5,8000268c <devintr+0x6c>
  }
}
    80002642:	60e2                	ld	ra,24(sp)
    80002644:	6442                	ld	s0,16(sp)
    80002646:	6105                	addi	sp,sp,32
    80002648:	8082                	ret
    8000264a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000264c:	7c1020ef          	jal	8000560c <plic_claim>
    80002650:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002652:	47a9                	li	a5,10
    80002654:	00f50963          	beq	a0,a5,80002666 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002658:	4785                	li	a5,1
    8000265a:	00f50963          	beq	a0,a5,8000266c <devintr+0x4c>
    return 1;
    8000265e:	4505                	li	a0,1
    } else if(irq){
    80002660:	e889                	bnez	s1,80002672 <devintr+0x52>
    80002662:	64a2                	ld	s1,8(sp)
    80002664:	bff9                	j	80002642 <devintr+0x22>
      uartintr();
    80002666:	ba6fe0ef          	jal	80000a0c <uartintr>
    if(irq)
    8000266a:	a819                	j	80002680 <devintr+0x60>
      virtio_disk_intr();
    8000266c:	430030ef          	jal	80005a9c <virtio_disk_intr>
    if(irq)
    80002670:	a801                	j	80002680 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002672:	85a6                	mv	a1,s1
    80002674:	00005517          	auipc	a0,0x5
    80002678:	d4450513          	addi	a0,a0,-700 # 800073b8 <etext+0x3b8>
    8000267c:	e53fd0ef          	jal	800004ce <printf>
      plic_complete(irq);
    80002680:	8526                	mv	a0,s1
    80002682:	7ab020ef          	jal	8000562c <plic_complete>
    return 1;
    80002686:	4505                	li	a0,1
    80002688:	64a2                	ld	s1,8(sp)
    8000268a:	bf65                	j	80002642 <devintr+0x22>
    clockintr();
    8000268c:	f41ff0ef          	jal	800025cc <clockintr>
    return 2;
    80002690:	4509                	li	a0,2
    80002692:	bf45                	j	80002642 <devintr+0x22>

0000000080002694 <usertrap>:
{
    80002694:	1101                	addi	sp,sp,-32
    80002696:	ec06                	sd	ra,24(sp)
    80002698:	e822                	sd	s0,16(sp)
    8000269a:	e426                	sd	s1,8(sp)
    8000269c:	e04a                	sd	s2,0(sp)
    8000269e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800026a4:	1007f793          	andi	a5,a5,256
    800026a8:	ef85                	bnez	a5,800026e0 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026aa:	00003797          	auipc	a5,0x3
    800026ae:	eb678793          	addi	a5,a5,-330 # 80005560 <kernelvec>
    800026b2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026b6:	a26ff0ef          	jal	800018dc <myproc>
    800026ba:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026bc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026be:	14102773          	csrr	a4,sepc
    800026c2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026c4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800026c8:	47a1                	li	a5,8
    800026ca:	02f70163          	beq	a4,a5,800026ec <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800026ce:	f53ff0ef          	jal	80002620 <devintr>
    800026d2:	892a                	mv	s2,a0
    800026d4:	c135                	beqz	a0,80002738 <usertrap+0xa4>
  if(killed(p))
    800026d6:	8526                	mv	a0,s1
    800026d8:	b63ff0ef          	jal	8000223a <killed>
    800026dc:	cd1d                	beqz	a0,8000271a <usertrap+0x86>
    800026de:	a81d                	j	80002714 <usertrap+0x80>
    panic("usertrap: not from user mode");
    800026e0:	00005517          	auipc	a0,0x5
    800026e4:	cf850513          	addi	a0,a0,-776 # 800073d8 <etext+0x3d8>
    800026e8:	8b6fe0ef          	jal	8000079e <panic>
    if(killed(p))
    800026ec:	b4fff0ef          	jal	8000223a <killed>
    800026f0:	e121                	bnez	a0,80002730 <usertrap+0x9c>
    p->trapframe->epc += 4;
    800026f2:	6cb8                	ld	a4,88(s1)
    800026f4:	6f1c                	ld	a5,24(a4)
    800026f6:	0791                	addi	a5,a5,4
    800026f8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026fe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002702:	10079073          	csrw	sstatus,a5
    syscall();
    80002706:	240000ef          	jal	80002946 <syscall>
  if(killed(p))
    8000270a:	8526                	mv	a0,s1
    8000270c:	b2fff0ef          	jal	8000223a <killed>
    80002710:	c901                	beqz	a0,80002720 <usertrap+0x8c>
    80002712:	4901                	li	s2,0
    exit(-1);
    80002714:	557d                	li	a0,-1
    80002716:	9f9ff0ef          	jal	8000210e <exit>
  if(which_dev == 2)
    8000271a:	4789                	li	a5,2
    8000271c:	04f90563          	beq	s2,a5,80002766 <usertrap+0xd2>
  usertrapret();
    80002720:	e1bff0ef          	jal	8000253a <usertrapret>
}
    80002724:	60e2                	ld	ra,24(sp)
    80002726:	6442                	ld	s0,16(sp)
    80002728:	64a2                	ld	s1,8(sp)
    8000272a:	6902                	ld	s2,0(sp)
    8000272c:	6105                	addi	sp,sp,32
    8000272e:	8082                	ret
      exit(-1);
    80002730:	557d                	li	a0,-1
    80002732:	9ddff0ef          	jal	8000210e <exit>
    80002736:	bf75                	j	800026f2 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002738:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000273c:	5890                	lw	a2,48(s1)
    8000273e:	00005517          	auipc	a0,0x5
    80002742:	cba50513          	addi	a0,a0,-838 # 800073f8 <etext+0x3f8>
    80002746:	d89fd0ef          	jal	800004ce <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000274a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000274e:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002752:	00005517          	auipc	a0,0x5
    80002756:	cd650513          	addi	a0,a0,-810 # 80007428 <etext+0x428>
    8000275a:	d75fd0ef          	jal	800004ce <printf>
    setkilled(p);
    8000275e:	8526                	mv	a0,s1
    80002760:	ab7ff0ef          	jal	80002216 <setkilled>
    80002764:	b75d                	j	8000270a <usertrap+0x76>
    yield();
    80002766:	871ff0ef          	jal	80001fd6 <yield>
    8000276a:	bf5d                	j	80002720 <usertrap+0x8c>

000000008000276c <kerneltrap>:
{
    8000276c:	7179                	addi	sp,sp,-48
    8000276e:	f406                	sd	ra,40(sp)
    80002770:	f022                	sd	s0,32(sp)
    80002772:	ec26                	sd	s1,24(sp)
    80002774:	e84a                	sd	s2,16(sp)
    80002776:	e44e                	sd	s3,8(sp)
    80002778:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000277a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000277e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002782:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002786:	1004f793          	andi	a5,s1,256
    8000278a:	c795                	beqz	a5,800027b6 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000278c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002790:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002792:	eb85                	bnez	a5,800027c2 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002794:	e8dff0ef          	jal	80002620 <devintr>
    80002798:	c91d                	beqz	a0,800027ce <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000279a:	4789                	li	a5,2
    8000279c:	04f50a63          	beq	a0,a5,800027f0 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027a0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027a4:	10049073          	csrw	sstatus,s1
}
    800027a8:	70a2                	ld	ra,40(sp)
    800027aa:	7402                	ld	s0,32(sp)
    800027ac:	64e2                	ld	s1,24(sp)
    800027ae:	6942                	ld	s2,16(sp)
    800027b0:	69a2                	ld	s3,8(sp)
    800027b2:	6145                	addi	sp,sp,48
    800027b4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027b6:	00005517          	auipc	a0,0x5
    800027ba:	c9a50513          	addi	a0,a0,-870 # 80007450 <etext+0x450>
    800027be:	fe1fd0ef          	jal	8000079e <panic>
    panic("kerneltrap: interrupts enabled");
    800027c2:	00005517          	auipc	a0,0x5
    800027c6:	cb650513          	addi	a0,a0,-842 # 80007478 <etext+0x478>
    800027ca:	fd5fd0ef          	jal	8000079e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027ce:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027d2:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800027d6:	85ce                	mv	a1,s3
    800027d8:	00005517          	auipc	a0,0x5
    800027dc:	cc050513          	addi	a0,a0,-832 # 80007498 <etext+0x498>
    800027e0:	ceffd0ef          	jal	800004ce <printf>
    panic("kerneltrap");
    800027e4:	00005517          	auipc	a0,0x5
    800027e8:	cdc50513          	addi	a0,a0,-804 # 800074c0 <etext+0x4c0>
    800027ec:	fb3fd0ef          	jal	8000079e <panic>
  if(which_dev == 2 && myproc() != 0)
    800027f0:	8ecff0ef          	jal	800018dc <myproc>
    800027f4:	d555                	beqz	a0,800027a0 <kerneltrap+0x34>
    yield();
    800027f6:	fe0ff0ef          	jal	80001fd6 <yield>
    800027fa:	b75d                	j	800027a0 <kerneltrap+0x34>

00000000800027fc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027fc:	1101                	addi	sp,sp,-32
    800027fe:	ec06                	sd	ra,24(sp)
    80002800:	e822                	sd	s0,16(sp)
    80002802:	e426                	sd	s1,8(sp)
    80002804:	1000                	addi	s0,sp,32
    80002806:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002808:	8d4ff0ef          	jal	800018dc <myproc>
  switch (n) {
    8000280c:	4795                	li	a5,5
    8000280e:	0497e163          	bltu	a5,s1,80002850 <argraw+0x54>
    80002812:	048a                	slli	s1,s1,0x2
    80002814:	00005717          	auipc	a4,0x5
    80002818:	12c70713          	addi	a4,a4,300 # 80007940 <states.0+0x30>
    8000281c:	94ba                	add	s1,s1,a4
    8000281e:	409c                	lw	a5,0(s1)
    80002820:	97ba                	add	a5,a5,a4
    80002822:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002824:	6d3c                	ld	a5,88(a0)
    80002826:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002828:	60e2                	ld	ra,24(sp)
    8000282a:	6442                	ld	s0,16(sp)
    8000282c:	64a2                	ld	s1,8(sp)
    8000282e:	6105                	addi	sp,sp,32
    80002830:	8082                	ret
    return p->trapframe->a1;
    80002832:	6d3c                	ld	a5,88(a0)
    80002834:	7fa8                	ld	a0,120(a5)
    80002836:	bfcd                	j	80002828 <argraw+0x2c>
    return p->trapframe->a2;
    80002838:	6d3c                	ld	a5,88(a0)
    8000283a:	63c8                	ld	a0,128(a5)
    8000283c:	b7f5                	j	80002828 <argraw+0x2c>
    return p->trapframe->a3;
    8000283e:	6d3c                	ld	a5,88(a0)
    80002840:	67c8                	ld	a0,136(a5)
    80002842:	b7dd                	j	80002828 <argraw+0x2c>
    return p->trapframe->a4;
    80002844:	6d3c                	ld	a5,88(a0)
    80002846:	6bc8                	ld	a0,144(a5)
    80002848:	b7c5                	j	80002828 <argraw+0x2c>
    return p->trapframe->a5;
    8000284a:	6d3c                	ld	a5,88(a0)
    8000284c:	6fc8                	ld	a0,152(a5)
    8000284e:	bfe9                	j	80002828 <argraw+0x2c>
  panic("argraw");
    80002850:	00005517          	auipc	a0,0x5
    80002854:	c8050513          	addi	a0,a0,-896 # 800074d0 <etext+0x4d0>
    80002858:	f47fd0ef          	jal	8000079e <panic>

000000008000285c <fetchaddr>:
{
    8000285c:	1101                	addi	sp,sp,-32
    8000285e:	ec06                	sd	ra,24(sp)
    80002860:	e822                	sd	s0,16(sp)
    80002862:	e426                	sd	s1,8(sp)
    80002864:	e04a                	sd	s2,0(sp)
    80002866:	1000                	addi	s0,sp,32
    80002868:	84aa                	mv	s1,a0
    8000286a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000286c:	870ff0ef          	jal	800018dc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002870:	653c                	ld	a5,72(a0)
    80002872:	02f4f663          	bgeu	s1,a5,8000289e <fetchaddr+0x42>
    80002876:	00848713          	addi	a4,s1,8
    8000287a:	02e7e463          	bltu	a5,a4,800028a2 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000287e:	46a1                	li	a3,8
    80002880:	8626                	mv	a2,s1
    80002882:	85ca                	mv	a1,s2
    80002884:	6928                	ld	a0,80(a0)
    80002886:	daffe0ef          	jal	80001634 <copyin>
    8000288a:	00a03533          	snez	a0,a0
    8000288e:	40a0053b          	negw	a0,a0
}
    80002892:	60e2                	ld	ra,24(sp)
    80002894:	6442                	ld	s0,16(sp)
    80002896:	64a2                	ld	s1,8(sp)
    80002898:	6902                	ld	s2,0(sp)
    8000289a:	6105                	addi	sp,sp,32
    8000289c:	8082                	ret
    return -1;
    8000289e:	557d                	li	a0,-1
    800028a0:	bfcd                	j	80002892 <fetchaddr+0x36>
    800028a2:	557d                	li	a0,-1
    800028a4:	b7fd                	j	80002892 <fetchaddr+0x36>

00000000800028a6 <fetchstr>:
{
    800028a6:	7179                	addi	sp,sp,-48
    800028a8:	f406                	sd	ra,40(sp)
    800028aa:	f022                	sd	s0,32(sp)
    800028ac:	ec26                	sd	s1,24(sp)
    800028ae:	e84a                	sd	s2,16(sp)
    800028b0:	e44e                	sd	s3,8(sp)
    800028b2:	1800                	addi	s0,sp,48
    800028b4:	892a                	mv	s2,a0
    800028b6:	84ae                	mv	s1,a1
    800028b8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800028ba:	822ff0ef          	jal	800018dc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800028be:	86ce                	mv	a3,s3
    800028c0:	864a                	mv	a2,s2
    800028c2:	85a6                	mv	a1,s1
    800028c4:	6928                	ld	a0,80(a0)
    800028c6:	df5fe0ef          	jal	800016ba <copyinstr>
    800028ca:	00054c63          	bltz	a0,800028e2 <fetchstr+0x3c>
  return strlen(buf);
    800028ce:	8526                	mv	a0,s1
    800028d0:	d86fe0ef          	jal	80000e56 <strlen>
}
    800028d4:	70a2                	ld	ra,40(sp)
    800028d6:	7402                	ld	s0,32(sp)
    800028d8:	64e2                	ld	s1,24(sp)
    800028da:	6942                	ld	s2,16(sp)
    800028dc:	69a2                	ld	s3,8(sp)
    800028de:	6145                	addi	sp,sp,48
    800028e0:	8082                	ret
    return -1;
    800028e2:	557d                	li	a0,-1
    800028e4:	bfc5                	j	800028d4 <fetchstr+0x2e>

00000000800028e6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028e6:	1101                	addi	sp,sp,-32
    800028e8:	ec06                	sd	ra,24(sp)
    800028ea:	e822                	sd	s0,16(sp)
    800028ec:	e426                	sd	s1,8(sp)
    800028ee:	1000                	addi	s0,sp,32
    800028f0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028f2:	f0bff0ef          	jal	800027fc <argraw>
    800028f6:	c088                	sw	a0,0(s1)
}
    800028f8:	60e2                	ld	ra,24(sp)
    800028fa:	6442                	ld	s0,16(sp)
    800028fc:	64a2                	ld	s1,8(sp)
    800028fe:	6105                	addi	sp,sp,32
    80002900:	8082                	ret

0000000080002902 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002902:	1101                	addi	sp,sp,-32
    80002904:	ec06                	sd	ra,24(sp)
    80002906:	e822                	sd	s0,16(sp)
    80002908:	e426                	sd	s1,8(sp)
    8000290a:	1000                	addi	s0,sp,32
    8000290c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000290e:	eefff0ef          	jal	800027fc <argraw>
    80002912:	e088                	sd	a0,0(s1)
}
    80002914:	60e2                	ld	ra,24(sp)
    80002916:	6442                	ld	s0,16(sp)
    80002918:	64a2                	ld	s1,8(sp)
    8000291a:	6105                	addi	sp,sp,32
    8000291c:	8082                	ret

000000008000291e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000291e:	1101                	addi	sp,sp,-32
    80002920:	ec06                	sd	ra,24(sp)
    80002922:	e822                	sd	s0,16(sp)
    80002924:	e426                	sd	s1,8(sp)
    80002926:	e04a                	sd	s2,0(sp)
    80002928:	1000                	addi	s0,sp,32
    8000292a:	84ae                	mv	s1,a1
    8000292c:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000292e:	ecfff0ef          	jal	800027fc <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002932:	864a                	mv	a2,s2
    80002934:	85a6                	mv	a1,s1
    80002936:	f71ff0ef          	jal	800028a6 <fetchstr>
}
    8000293a:	60e2                	ld	ra,24(sp)
    8000293c:	6442                	ld	s0,16(sp)
    8000293e:	64a2                	ld	s1,8(sp)
    80002940:	6902                	ld	s2,0(sp)
    80002942:	6105                	addi	sp,sp,32
    80002944:	8082                	ret

0000000080002946 <syscall>:
};


void
syscall(void)
{
    80002946:	7139                	addi	sp,sp,-64
    80002948:	fc06                	sd	ra,56(sp)
    8000294a:	f822                	sd	s0,48(sp)
    8000294c:	f426                	sd	s1,40(sp)
    8000294e:	f04a                	sd	s2,32(sp)
    80002950:	0080                	addi	s0,sp,64
  int num;
  struct proc *p = myproc();
    80002952:	f8bfe0ef          	jal	800018dc <myproc>
    80002956:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002958:	6d3c                	ld	a5,88(a0)
    8000295a:	77dc                	ld	a5,168(a5)
    8000295c:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002960:	37fd                	addiw	a5,a5,-1
    80002962:	4759                	li	a4,22
    80002964:	08f76f63          	bltu	a4,a5,80002a02 <syscall+0xbc>
    80002968:	ec4e                	sd	s3,24(sp)
    8000296a:	00391713          	slli	a4,s2,0x3
    8000296e:	00005797          	auipc	a5,0x5
    80002972:	fea78793          	addi	a5,a5,-22 # 80007958 <syscalls>
    80002976:	97ba                	add	a5,a5,a4
    80002978:	0007b983          	ld	s3,0(a5)
    8000297c:	08098263          	beqz	s3,80002a00 <syscall+0xba>
    80002980:	e852                	sd	s4,16(sp)
    80002982:	e456                	sd	s5,8(sp)
    80002984:	e05a                	sd	s6,0(sp)
    acquire(&tickslock);
    80002986:	0001d517          	auipc	a0,0x1d
    8000298a:	c7a50513          	addi	a0,a0,-902 # 8001f600 <tickslock>
    8000298e:	a70fe0ef          	jal	80000bfe <acquire>
    int start_ticks = ticks;
    80002992:	00005a97          	auipc	s5,0x5
    80002996:	116a8a93          	addi	s5,s5,278 # 80007aa8 <ticks>
    8000299a:	000aaa03          	lw	s4,0(s5)
    release(&tickslock);
    8000299e:	0001d517          	auipc	a0,0x1d
    800029a2:	c6250513          	addi	a0,a0,-926 # 8001f600 <tickslock>
    800029a6:	aecfe0ef          	jal	80000c92 <release>
    p->trapframe->a0 = syscalls[num]();
    800029aa:	0584bb03          	ld	s6,88(s1)
    800029ae:	9982                	jalr	s3
    800029b0:	06ab3823          	sd	a0,112(s6)
    acquire(&tickslock);
    800029b4:	0001d517          	auipc	a0,0x1d
    800029b8:	c4c50513          	addi	a0,a0,-948 # 8001f600 <tickslock>
    800029bc:	a42fe0ef          	jal	80000bfe <acquire>
    int end_ticks = ticks;
    800029c0:	000aa983          	lw	s3,0(s5)
    release(&tickslock);
    800029c4:	0001d517          	auipc	a0,0x1d
    800029c8:	c3c50513          	addi	a0,a0,-964 # 8001f600 <tickslock>
    800029cc:	ac6fe0ef          	jal	80000c92 <release>

    struct syscall_stat *stat = &p->syscall_stats[num];
    stat->count++;
    800029d0:	00191793          	slli	a5,s2,0x1
    800029d4:	01278733          	add	a4,a5,s2
    800029d8:	070e                	slli	a4,a4,0x3
    800029da:	9726                	add	a4,a4,s1
    800029dc:	17872683          	lw	a3,376(a4)
    800029e0:	2685                	addiw	a3,a3,1
    800029e2:	16d72c23          	sw	a3,376(a4)
    stat->accum_time += (end_ticks - start_ticks);
    800029e6:	414989bb          	subw	s3,s3,s4
    800029ea:	17c72783          	lw	a5,380(a4)
    800029ee:	013787bb          	addw	a5,a5,s3
    800029f2:	16f72e23          	sw	a5,380(a4)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029f6:	69e2                	ld	s3,24(sp)
    800029f8:	6a42                	ld	s4,16(sp)
    800029fa:	6aa2                	ld	s5,8(sp)
    800029fc:	6b02                	ld	s6,0(sp)
    800029fe:	a839                	j	80002a1c <syscall+0xd6>
    80002a00:	69e2                	ld	s3,24(sp)
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002a02:	86ca                	mv	a3,s2
    80002a04:	15848613          	addi	a2,s1,344
    80002a08:	588c                	lw	a1,48(s1)
    80002a0a:	00005517          	auipc	a0,0x5
    80002a0e:	ace50513          	addi	a0,a0,-1330 # 800074d8 <etext+0x4d8>
    80002a12:	abdfd0ef          	jal	800004ce <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002a16:	6cbc                	ld	a5,88(s1)
    80002a18:	577d                	li	a4,-1
    80002a1a:	fbb8                	sd	a4,112(a5)
  }
}
    80002a1c:	70e2                	ld	ra,56(sp)
    80002a1e:	7442                	ld	s0,48(sp)
    80002a20:	74a2                	ld	s1,40(sp)
    80002a22:	7902                	ld	s2,32(sp)
    80002a24:	6121                	addi	sp,sp,64
    80002a26:	8082                	ret

0000000080002a28 <sys_exit>:
#include "pstat.h"
extern struct proc proc[];

uint64
sys_exit(void)
{
    80002a28:	1101                	addi	sp,sp,-32
    80002a2a:	ec06                	sd	ra,24(sp)
    80002a2c:	e822                	sd	s0,16(sp)
    80002a2e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a30:	fec40593          	addi	a1,s0,-20
    80002a34:	4501                	li	a0,0
    80002a36:	eb1ff0ef          	jal	800028e6 <argint>
  exit(n);
    80002a3a:	fec42503          	lw	a0,-20(s0)
    80002a3e:	ed0ff0ef          	jal	8000210e <exit>
  return 0; // not reached
}
    80002a42:	4501                	li	a0,0
    80002a44:	60e2                	ld	ra,24(sp)
    80002a46:	6442                	ld	s0,16(sp)
    80002a48:	6105                	addi	sp,sp,32
    80002a4a:	8082                	ret

0000000080002a4c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a4c:	1141                	addi	sp,sp,-16
    80002a4e:	e406                	sd	ra,8(sp)
    80002a50:	e022                	sd	s0,0(sp)
    80002a52:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a54:	e89fe0ef          	jal	800018dc <myproc>
}
    80002a58:	5908                	lw	a0,48(a0)
    80002a5a:	60a2                	ld	ra,8(sp)
    80002a5c:	6402                	ld	s0,0(sp)
    80002a5e:	0141                	addi	sp,sp,16
    80002a60:	8082                	ret

0000000080002a62 <sys_fork>:

uint64
sys_fork(void)
{
    80002a62:	1141                	addi	sp,sp,-16
    80002a64:	e406                	sd	ra,8(sp)
    80002a66:	e022                	sd	s0,0(sp)
    80002a68:	0800                	addi	s0,sp,16
  return fork();
    80002a6a:	9fcff0ef          	jal	80001c66 <fork>
}
    80002a6e:	60a2                	ld	ra,8(sp)
    80002a70:	6402                	ld	s0,0(sp)
    80002a72:	0141                	addi	sp,sp,16
    80002a74:	8082                	ret

0000000080002a76 <sys_wait>:

uint64
sys_wait(void)
{
    80002a76:	1101                	addi	sp,sp,-32
    80002a78:	ec06                	sd	ra,24(sp)
    80002a7a:	e822                	sd	s0,16(sp)
    80002a7c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a7e:	fe840593          	addi	a1,s0,-24
    80002a82:	4501                	li	a0,0
    80002a84:	e7fff0ef          	jal	80002902 <argaddr>
  return wait(p);
    80002a88:	fe843503          	ld	a0,-24(s0)
    80002a8c:	fd8ff0ef          	jal	80002264 <wait>
}
    80002a90:	60e2                	ld	ra,24(sp)
    80002a92:	6442                	ld	s0,16(sp)
    80002a94:	6105                	addi	sp,sp,32
    80002a96:	8082                	ret

0000000080002a98 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a98:	7179                	addi	sp,sp,-48
    80002a9a:	f406                	sd	ra,40(sp)
    80002a9c:	f022                	sd	s0,32(sp)
    80002a9e:	ec26                	sd	s1,24(sp)
    80002aa0:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002aa2:	fdc40593          	addi	a1,s0,-36
    80002aa6:	4501                	li	a0,0
    80002aa8:	e3fff0ef          	jal	800028e6 <argint>
  addr = myproc()->sz;
    80002aac:	e31fe0ef          	jal	800018dc <myproc>
    80002ab0:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002ab2:	fdc42503          	lw	a0,-36(s0)
    80002ab6:	960ff0ef          	jal	80001c16 <growproc>
    80002aba:	00054863          	bltz	a0,80002aca <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002abe:	8526                	mv	a0,s1
    80002ac0:	70a2                	ld	ra,40(sp)
    80002ac2:	7402                	ld	s0,32(sp)
    80002ac4:	64e2                	ld	s1,24(sp)
    80002ac6:	6145                	addi	sp,sp,48
    80002ac8:	8082                	ret
    return -1;
    80002aca:	54fd                	li	s1,-1
    80002acc:	bfcd                	j	80002abe <sys_sbrk+0x26>

0000000080002ace <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ace:	7139                	addi	sp,sp,-64
    80002ad0:	fc06                	sd	ra,56(sp)
    80002ad2:	f822                	sd	s0,48(sp)
    80002ad4:	f04a                	sd	s2,32(sp)
    80002ad6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ad8:	fcc40593          	addi	a1,s0,-52
    80002adc:	4501                	li	a0,0
    80002ade:	e09ff0ef          	jal	800028e6 <argint>
  if (n < 0)
    80002ae2:	fcc42783          	lw	a5,-52(s0)
    80002ae6:	0607c763          	bltz	a5,80002b54 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002aea:	0001d517          	auipc	a0,0x1d
    80002aee:	b1650513          	addi	a0,a0,-1258 # 8001f600 <tickslock>
    80002af2:	90cfe0ef          	jal	80000bfe <acquire>
  ticks0 = ticks;
    80002af6:	00005917          	auipc	s2,0x5
    80002afa:	fb292903          	lw	s2,-78(s2) # 80007aa8 <ticks>
  while (ticks - ticks0 < n)
    80002afe:	fcc42783          	lw	a5,-52(s0)
    80002b02:	cf8d                	beqz	a5,80002b3c <sys_sleep+0x6e>
    80002b04:	f426                	sd	s1,40(sp)
    80002b06:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b08:	0001d997          	auipc	s3,0x1d
    80002b0c:	af898993          	addi	s3,s3,-1288 # 8001f600 <tickslock>
    80002b10:	00005497          	auipc	s1,0x5
    80002b14:	f9848493          	addi	s1,s1,-104 # 80007aa8 <ticks>
    if (killed(myproc()))
    80002b18:	dc5fe0ef          	jal	800018dc <myproc>
    80002b1c:	f1eff0ef          	jal	8000223a <killed>
    80002b20:	ed0d                	bnez	a0,80002b5a <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002b22:	85ce                	mv	a1,s3
    80002b24:	8526                	mv	a0,s1
    80002b26:	cdcff0ef          	jal	80002002 <sleep>
  while (ticks - ticks0 < n)
    80002b2a:	409c                	lw	a5,0(s1)
    80002b2c:	412787bb          	subw	a5,a5,s2
    80002b30:	fcc42703          	lw	a4,-52(s0)
    80002b34:	fee7e2e3          	bltu	a5,a4,80002b18 <sys_sleep+0x4a>
    80002b38:	74a2                	ld	s1,40(sp)
    80002b3a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b3c:	0001d517          	auipc	a0,0x1d
    80002b40:	ac450513          	addi	a0,a0,-1340 # 8001f600 <tickslock>
    80002b44:	94efe0ef          	jal	80000c92 <release>
  return 0;
    80002b48:	4501                	li	a0,0
}
    80002b4a:	70e2                	ld	ra,56(sp)
    80002b4c:	7442                	ld	s0,48(sp)
    80002b4e:	7902                	ld	s2,32(sp)
    80002b50:	6121                	addi	sp,sp,64
    80002b52:	8082                	ret
    n = 0;
    80002b54:	fc042623          	sw	zero,-52(s0)
    80002b58:	bf49                	j	80002aea <sys_sleep+0x1c>
      release(&tickslock);
    80002b5a:	0001d517          	auipc	a0,0x1d
    80002b5e:	aa650513          	addi	a0,a0,-1370 # 8001f600 <tickslock>
    80002b62:	930fe0ef          	jal	80000c92 <release>
      return -1;
    80002b66:	557d                	li	a0,-1
    80002b68:	74a2                	ld	s1,40(sp)
    80002b6a:	69e2                	ld	s3,24(sp)
    80002b6c:	bff9                	j	80002b4a <sys_sleep+0x7c>

0000000080002b6e <sys_kill>:

uint64
sys_kill(void)
{
    80002b6e:	1101                	addi	sp,sp,-32
    80002b70:	ec06                	sd	ra,24(sp)
    80002b72:	e822                	sd	s0,16(sp)
    80002b74:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b76:	fec40593          	addi	a1,s0,-20
    80002b7a:	4501                	li	a0,0
    80002b7c:	d6bff0ef          	jal	800028e6 <argint>
  return kill(pid);
    80002b80:	fec42503          	lw	a0,-20(s0)
    80002b84:	e2cff0ef          	jal	800021b0 <kill>
}
    80002b88:	60e2                	ld	ra,24(sp)
    80002b8a:	6442                	ld	s0,16(sp)
    80002b8c:	6105                	addi	sp,sp,32
    80002b8e:	8082                	ret

0000000080002b90 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b90:	1101                	addi	sp,sp,-32
    80002b92:	ec06                	sd	ra,24(sp)
    80002b94:	e822                	sd	s0,16(sp)
    80002b96:	e426                	sd	s1,8(sp)
    80002b98:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b9a:	0001d517          	auipc	a0,0x1d
    80002b9e:	a6650513          	addi	a0,a0,-1434 # 8001f600 <tickslock>
    80002ba2:	85cfe0ef          	jal	80000bfe <acquire>
  xticks = ticks;
    80002ba6:	00005497          	auipc	s1,0x5
    80002baa:	f024a483          	lw	s1,-254(s1) # 80007aa8 <ticks>
  release(&tickslock);
    80002bae:	0001d517          	auipc	a0,0x1d
    80002bb2:	a5250513          	addi	a0,a0,-1454 # 8001f600 <tickslock>
    80002bb6:	8dcfe0ef          	jal	80000c92 <release>
  return xticks;
}
    80002bba:	02049513          	slli	a0,s1,0x20
    80002bbe:	9101                	srli	a0,a0,0x20
    80002bc0:	60e2                	ld	ra,24(sp)
    80002bc2:	6442                	ld	s0,16(sp)
    80002bc4:	64a2                	ld	s1,8(sp)
    80002bc6:	6105                	addi	sp,sp,32
    80002bc8:	8082                	ret

0000000080002bca <sys_history>:

uint64 sys_history()
{
    80002bca:	7139                	addi	sp,sp,-64
    80002bcc:	fc06                	sd	ra,56(sp)
    80002bce:	f822                	sd	s0,48(sp)
    80002bd0:	0080                	addi	s0,sp,64
  int syscall_num;
  uint64 stat_addr;
  argint(0, &syscall_num);
    80002bd2:	fec40593          	addi	a1,s0,-20
    80002bd6:	4501                	li	a0,0
    80002bd8:	d0fff0ef          	jal	800028e6 <argint>
  argaddr(1, &stat_addr);
    80002bdc:	fe040593          	addi	a1,s0,-32
    80002be0:	4505                	li	a0,1
    80002be2:	d21ff0ef          	jal	80002902 <argaddr>
  struct proc *p = myproc();
    80002be6:	cf7fe0ef          	jal	800018dc <myproc>
    80002bea:	872a                	mv	a4,a0
  if (syscall_num < 1 || syscall_num > NSYSCALL)
    80002bec:	fec42683          	lw	a3,-20(s0)
    80002bf0:	fff6861b          	addiw	a2,a3,-1
    80002bf4:	47dd                	li	a5,23
    return -1;
    80002bf6:	557d                	li	a0,-1
  if (syscall_num < 1 || syscall_num > NSYSCALL)
    80002bf8:	02c7ec63          	bltu	a5,a2,80002c30 <sys_history+0x66>
  struct syscall_stat stat = p->syscall_stats[syscall_num];
    80002bfc:	00169793          	slli	a5,a3,0x1
    80002c00:	97b6                	add	a5,a5,a3
    80002c02:	078e                	slli	a5,a5,0x3
    80002c04:	97ba                	add	a5,a5,a4
    80002c06:	1687b683          	ld	a3,360(a5)
    80002c0a:	fcd43423          	sd	a3,-56(s0)
    80002c0e:	1707b683          	ld	a3,368(a5)
    80002c12:	fcd43823          	sd	a3,-48(s0)
    80002c16:	1787b783          	ld	a5,376(a5)
    80002c1a:	fcf43c23          	sd	a5,-40(s0)
  if (copyout(p->pagetable, stat_addr, (char *)&stat, sizeof(struct syscall_stat)) < 0)
    80002c1e:	46e1                	li	a3,24
    80002c20:	fc840613          	addi	a2,s0,-56
    80002c24:	fe043583          	ld	a1,-32(s0)
    80002c28:	6b28                	ld	a0,80(a4)
    80002c2a:	95bfe0ef          	jal	80001584 <copyout>
    80002c2e:	957d                	srai	a0,a0,0x3f
    return -1;
  return 0;
}
    80002c30:	70e2                	ld	ra,56(sp)
    80002c32:	7442                	ld	s0,48(sp)
    80002c34:	6121                	addi	sp,sp,64
    80002c36:	8082                	ret

0000000080002c38 <sys_settickets>:

uint64 sys_settickets()
{
    80002c38:	7179                	addi	sp,sp,-48
    80002c3a:	f406                	sd	ra,40(sp)
    80002c3c:	f022                	sd	s0,32(sp)
    80002c3e:	ec26                	sd	s1,24(sp)
    80002c40:	1800                	addi	s0,sp,48
  int n;
  argint(0, &n);
    80002c42:	fdc40593          	addi	a1,s0,-36
    80002c46:	4501                	li	a0,0
    80002c48:	c9fff0ef          	jal	800028e6 <argint>
  struct proc *p = myproc();
    80002c4c:	c91fe0ef          	jal	800018dc <myproc>
    80002c50:	84aa                	mv	s1,a0

  if (n < 1) {
    80002c52:	fdc42783          	lw	a5,-36(s0)
    80002c56:	02f05363          	blez	a5,80002c7c <sys_settickets+0x44>
    p->Current_tickets = DEFAULT_TICKET_COUNT;
    release(&p->lock);
    return -1;
  }

  acquire(&p->lock);
    80002c5a:	fa5fd0ef          	jal	80000bfe <acquire>
  p->Original_tickets = n;
    80002c5e:	fdc42783          	lw	a5,-36(s0)
    80002c62:	3cf4a023          	sw	a5,960(s1)
  p->Current_tickets = n;
    80002c66:	3cf4a223          	sw	a5,964(s1)
  release(&p->lock);
    80002c6a:	8526                	mv	a0,s1
    80002c6c:	826fe0ef          	jal	80000c92 <release>
  return 0;
    80002c70:	4501                	li	a0,0
}
    80002c72:	70a2                	ld	ra,40(sp)
    80002c74:	7402                	ld	s0,32(sp)
    80002c76:	64e2                	ld	s1,24(sp)
    80002c78:	6145                	addi	sp,sp,48
    80002c7a:	8082                	ret
    acquire(&p->lock);
    80002c7c:	f83fd0ef          	jal	80000bfe <acquire>
    p->Original_tickets = DEFAULT_TICKET_COUNT;
    80002c80:	47a9                	li	a5,10
    80002c82:	3cf4a023          	sw	a5,960(s1)
    p->Current_tickets = DEFAULT_TICKET_COUNT;
    80002c86:	3cf4a223          	sw	a5,964(s1)
    release(&p->lock);
    80002c8a:	8526                	mv	a0,s1
    80002c8c:	806fe0ef          	jal	80000c92 <release>
    return -1;
    80002c90:	557d                	li	a0,-1
    80002c92:	b7c5                	j	80002c72 <sys_settickets+0x3a>

0000000080002c94 <sys_getpinfo>:
uint64 sys_getpinfo()
{
    80002c94:	9c010113          	addi	sp,sp,-1600
    80002c98:	62113c23          	sd	ra,1592(sp)
    80002c9c:	62813823          	sd	s0,1584(sp)
    80002ca0:	62913423          	sd	s1,1576(sp)
    80002ca4:	63213023          	sd	s2,1568(sp)
    80002ca8:	61313c23          	sd	s3,1560(sp)
    80002cac:	64010413          	addi	s0,sp,1600
  uint64 addr;
  argaddr(0, &addr);
    80002cb0:	fc840593          	addi	a1,s0,-56
    80002cb4:	4501                	li	a0,0
    80002cb6:	c4dff0ef          	jal	80002902 <argaddr>
  struct proc *p;
  struct pstat st;

  for (int i = 0; i < NPROC; i++) {
    80002cba:	0000d497          	auipc	s1,0xd
    80002cbe:	34648493          	addi	s1,s1,838 # 80010000 <proc>
    80002cc2:	9c840913          	addi	s2,s0,-1592
    80002cc6:	0001d997          	auipc	s3,0x1d
    80002cca:	93a98993          	addi	s3,s3,-1734 # 8001f600 <tickslock>
    p = &proc[i];
    acquire(&p->lock);
    80002cce:	8526                	mv	a0,s1
    80002cd0:	f2ffd0ef          	jal	80000bfe <acquire>
    st.pid[i] = p->pid;
    80002cd4:	589c                	lw	a5,48(s1)
    80002cd6:	00f92023          	sw	a5,0(s2)
    st.inuse[i] = (p->state != UNUSED);
    80002cda:	4c9c                	lw	a5,24(s1)
    80002cdc:	00f037b3          	snez	a5,a5
    80002ce0:	10f92023          	sw	a5,256(s2)
    st.inQ[i] = p->inq;
    80002ce4:	3c84a783          	lw	a5,968(s1)
    80002ce8:	20f92023          	sw	a5,512(s2)
    st.tickets_original[i] = p->Original_tickets;
    80002cec:	3c04a783          	lw	a5,960(s1)
    80002cf0:	30f92023          	sw	a5,768(s2)
    st.tickets_current[i] = p->Current_tickets;
    80002cf4:	3c44a783          	lw	a5,964(s1)
    80002cf8:	40f92023          	sw	a5,1024(s2)
    st.time_slices[i] = p->time_slices;
    80002cfc:	3cc4a783          	lw	a5,972(s1)
    80002d00:	50f92023          	sw	a5,1280(s2)
    release(&p->lock);
    80002d04:	8526                	mv	a0,s1
    80002d06:	f8dfd0ef          	jal	80000c92 <release>
  for (int i = 0; i < NPROC; i++) {
    80002d0a:	3d848493          	addi	s1,s1,984
    80002d0e:	0911                	addi	s2,s2,4
    80002d10:	fb349fe3          	bne	s1,s3,80002cce <sys_getpinfo+0x3a>
  }

  if (copyout(myproc()->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80002d14:	bc9fe0ef          	jal	800018dc <myproc>
    80002d18:	60000693          	li	a3,1536
    80002d1c:	9c840613          	addi	a2,s0,-1592
    80002d20:	fc843583          	ld	a1,-56(s0)
    80002d24:	6928                	ld	a0,80(a0)
    80002d26:	85ffe0ef          	jal	80001584 <copyout>
    return -1;
  return 0;
}
    80002d2a:	957d                	srai	a0,a0,0x3f
    80002d2c:	63813083          	ld	ra,1592(sp)
    80002d30:	63013403          	ld	s0,1584(sp)
    80002d34:	62813483          	ld	s1,1576(sp)
    80002d38:	62013903          	ld	s2,1568(sp)
    80002d3c:	61813983          	ld	s3,1560(sp)
    80002d40:	64010113          	addi	sp,sp,1600
    80002d44:	8082                	ret

0000000080002d46 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d46:	7179                	addi	sp,sp,-48
    80002d48:	f406                	sd	ra,40(sp)
    80002d4a:	f022                	sd	s0,32(sp)
    80002d4c:	ec26                	sd	s1,24(sp)
    80002d4e:	e84a                	sd	s2,16(sp)
    80002d50:	e44e                	sd	s3,8(sp)
    80002d52:	e052                	sd	s4,0(sp)
    80002d54:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d56:	00004597          	auipc	a1,0x4
    80002d5a:	7a258593          	addi	a1,a1,1954 # 800074f8 <etext+0x4f8>
    80002d5e:	0001d517          	auipc	a0,0x1d
    80002d62:	8ba50513          	addi	a0,a0,-1862 # 8001f618 <bcache>
    80002d66:	e15fd0ef          	jal	80000b7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d6a:	00025797          	auipc	a5,0x25
    80002d6e:	8ae78793          	addi	a5,a5,-1874 # 80027618 <bcache+0x8000>
    80002d72:	00025717          	auipc	a4,0x25
    80002d76:	b0e70713          	addi	a4,a4,-1266 # 80027880 <bcache+0x8268>
    80002d7a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d7e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d82:	0001d497          	auipc	s1,0x1d
    80002d86:	8ae48493          	addi	s1,s1,-1874 # 8001f630 <bcache+0x18>
    b->next = bcache.head.next;
    80002d8a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d8c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d8e:	00004a17          	auipc	s4,0x4
    80002d92:	772a0a13          	addi	s4,s4,1906 # 80007500 <etext+0x500>
    b->next = bcache.head.next;
    80002d96:	2b893783          	ld	a5,696(s2)
    80002d9a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d9c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002da0:	85d2                	mv	a1,s4
    80002da2:	01048513          	addi	a0,s1,16
    80002da6:	244010ef          	jal	80003fea <initsleeplock>
    bcache.head.next->prev = b;
    80002daa:	2b893783          	ld	a5,696(s2)
    80002dae:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002db0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002db4:	45848493          	addi	s1,s1,1112
    80002db8:	fd349fe3          	bne	s1,s3,80002d96 <binit+0x50>
  }
}
    80002dbc:	70a2                	ld	ra,40(sp)
    80002dbe:	7402                	ld	s0,32(sp)
    80002dc0:	64e2                	ld	s1,24(sp)
    80002dc2:	6942                	ld	s2,16(sp)
    80002dc4:	69a2                	ld	s3,8(sp)
    80002dc6:	6a02                	ld	s4,0(sp)
    80002dc8:	6145                	addi	sp,sp,48
    80002dca:	8082                	ret

0000000080002dcc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002dcc:	7179                	addi	sp,sp,-48
    80002dce:	f406                	sd	ra,40(sp)
    80002dd0:	f022                	sd	s0,32(sp)
    80002dd2:	ec26                	sd	s1,24(sp)
    80002dd4:	e84a                	sd	s2,16(sp)
    80002dd6:	e44e                	sd	s3,8(sp)
    80002dd8:	1800                	addi	s0,sp,48
    80002dda:	892a                	mv	s2,a0
    80002ddc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002dde:	0001d517          	auipc	a0,0x1d
    80002de2:	83a50513          	addi	a0,a0,-1990 # 8001f618 <bcache>
    80002de6:	e19fd0ef          	jal	80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002dea:	00025497          	auipc	s1,0x25
    80002dee:	ae64b483          	ld	s1,-1306(s1) # 800278d0 <bcache+0x82b8>
    80002df2:	00025797          	auipc	a5,0x25
    80002df6:	a8e78793          	addi	a5,a5,-1394 # 80027880 <bcache+0x8268>
    80002dfa:	02f48b63          	beq	s1,a5,80002e30 <bread+0x64>
    80002dfe:	873e                	mv	a4,a5
    80002e00:	a021                	j	80002e08 <bread+0x3c>
    80002e02:	68a4                	ld	s1,80(s1)
    80002e04:	02e48663          	beq	s1,a4,80002e30 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002e08:	449c                	lw	a5,8(s1)
    80002e0a:	ff279ce3          	bne	a5,s2,80002e02 <bread+0x36>
    80002e0e:	44dc                	lw	a5,12(s1)
    80002e10:	ff3799e3          	bne	a5,s3,80002e02 <bread+0x36>
      b->refcnt++;
    80002e14:	40bc                	lw	a5,64(s1)
    80002e16:	2785                	addiw	a5,a5,1
    80002e18:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e1a:	0001c517          	auipc	a0,0x1c
    80002e1e:	7fe50513          	addi	a0,a0,2046 # 8001f618 <bcache>
    80002e22:	e71fd0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002e26:	01048513          	addi	a0,s1,16
    80002e2a:	1f6010ef          	jal	80004020 <acquiresleep>
      return b;
    80002e2e:	a889                	j	80002e80 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e30:	00025497          	auipc	s1,0x25
    80002e34:	a984b483          	ld	s1,-1384(s1) # 800278c8 <bcache+0x82b0>
    80002e38:	00025797          	auipc	a5,0x25
    80002e3c:	a4878793          	addi	a5,a5,-1464 # 80027880 <bcache+0x8268>
    80002e40:	00f48863          	beq	s1,a5,80002e50 <bread+0x84>
    80002e44:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e46:	40bc                	lw	a5,64(s1)
    80002e48:	cb91                	beqz	a5,80002e5c <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e4a:	64a4                	ld	s1,72(s1)
    80002e4c:	fee49de3          	bne	s1,a4,80002e46 <bread+0x7a>
  panic("bget: no buffers");
    80002e50:	00004517          	auipc	a0,0x4
    80002e54:	6b850513          	addi	a0,a0,1720 # 80007508 <etext+0x508>
    80002e58:	947fd0ef          	jal	8000079e <panic>
      b->dev = dev;
    80002e5c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e60:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e64:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e68:	4785                	li	a5,1
    80002e6a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e6c:	0001c517          	auipc	a0,0x1c
    80002e70:	7ac50513          	addi	a0,a0,1964 # 8001f618 <bcache>
    80002e74:	e1ffd0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002e78:	01048513          	addi	a0,s1,16
    80002e7c:	1a4010ef          	jal	80004020 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e80:	409c                	lw	a5,0(s1)
    80002e82:	cb89                	beqz	a5,80002e94 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e84:	8526                	mv	a0,s1
    80002e86:	70a2                	ld	ra,40(sp)
    80002e88:	7402                	ld	s0,32(sp)
    80002e8a:	64e2                	ld	s1,24(sp)
    80002e8c:	6942                	ld	s2,16(sp)
    80002e8e:	69a2                	ld	s3,8(sp)
    80002e90:	6145                	addi	sp,sp,48
    80002e92:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e94:	4581                	li	a1,0
    80002e96:	8526                	mv	a0,s1
    80002e98:	1f9020ef          	jal	80005890 <virtio_disk_rw>
    b->valid = 1;
    80002e9c:	4785                	li	a5,1
    80002e9e:	c09c                	sw	a5,0(s1)
  return b;
    80002ea0:	b7d5                	j	80002e84 <bread+0xb8>

0000000080002ea2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002ea2:	1101                	addi	sp,sp,-32
    80002ea4:	ec06                	sd	ra,24(sp)
    80002ea6:	e822                	sd	s0,16(sp)
    80002ea8:	e426                	sd	s1,8(sp)
    80002eaa:	1000                	addi	s0,sp,32
    80002eac:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002eae:	0541                	addi	a0,a0,16
    80002eb0:	1ee010ef          	jal	8000409e <holdingsleep>
    80002eb4:	c911                	beqz	a0,80002ec8 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002eb6:	4585                	li	a1,1
    80002eb8:	8526                	mv	a0,s1
    80002eba:	1d7020ef          	jal	80005890 <virtio_disk_rw>
}
    80002ebe:	60e2                	ld	ra,24(sp)
    80002ec0:	6442                	ld	s0,16(sp)
    80002ec2:	64a2                	ld	s1,8(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret
    panic("bwrite");
    80002ec8:	00004517          	auipc	a0,0x4
    80002ecc:	65850513          	addi	a0,a0,1624 # 80007520 <etext+0x520>
    80002ed0:	8cffd0ef          	jal	8000079e <panic>

0000000080002ed4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ed4:	1101                	addi	sp,sp,-32
    80002ed6:	ec06                	sd	ra,24(sp)
    80002ed8:	e822                	sd	s0,16(sp)
    80002eda:	e426                	sd	s1,8(sp)
    80002edc:	e04a                	sd	s2,0(sp)
    80002ede:	1000                	addi	s0,sp,32
    80002ee0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ee2:	01050913          	addi	s2,a0,16
    80002ee6:	854a                	mv	a0,s2
    80002ee8:	1b6010ef          	jal	8000409e <holdingsleep>
    80002eec:	c125                	beqz	a0,80002f4c <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002eee:	854a                	mv	a0,s2
    80002ef0:	176010ef          	jal	80004066 <releasesleep>

  acquire(&bcache.lock);
    80002ef4:	0001c517          	auipc	a0,0x1c
    80002ef8:	72450513          	addi	a0,a0,1828 # 8001f618 <bcache>
    80002efc:	d03fd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002f00:	40bc                	lw	a5,64(s1)
    80002f02:	37fd                	addiw	a5,a5,-1
    80002f04:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f06:	e79d                	bnez	a5,80002f34 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f08:	68b8                	ld	a4,80(s1)
    80002f0a:	64bc                	ld	a5,72(s1)
    80002f0c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002f0e:	68b8                	ld	a4,80(s1)
    80002f10:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f12:	00024797          	auipc	a5,0x24
    80002f16:	70678793          	addi	a5,a5,1798 # 80027618 <bcache+0x8000>
    80002f1a:	2b87b703          	ld	a4,696(a5)
    80002f1e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f20:	00025717          	auipc	a4,0x25
    80002f24:	96070713          	addi	a4,a4,-1696 # 80027880 <bcache+0x8268>
    80002f28:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f2a:	2b87b703          	ld	a4,696(a5)
    80002f2e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f30:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f34:	0001c517          	auipc	a0,0x1c
    80002f38:	6e450513          	addi	a0,a0,1764 # 8001f618 <bcache>
    80002f3c:	d57fd0ef          	jal	80000c92 <release>
}
    80002f40:	60e2                	ld	ra,24(sp)
    80002f42:	6442                	ld	s0,16(sp)
    80002f44:	64a2                	ld	s1,8(sp)
    80002f46:	6902                	ld	s2,0(sp)
    80002f48:	6105                	addi	sp,sp,32
    80002f4a:	8082                	ret
    panic("brelse");
    80002f4c:	00004517          	auipc	a0,0x4
    80002f50:	5dc50513          	addi	a0,a0,1500 # 80007528 <etext+0x528>
    80002f54:	84bfd0ef          	jal	8000079e <panic>

0000000080002f58 <bpin>:

void
bpin(struct buf *b) {
    80002f58:	1101                	addi	sp,sp,-32
    80002f5a:	ec06                	sd	ra,24(sp)
    80002f5c:	e822                	sd	s0,16(sp)
    80002f5e:	e426                	sd	s1,8(sp)
    80002f60:	1000                	addi	s0,sp,32
    80002f62:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f64:	0001c517          	auipc	a0,0x1c
    80002f68:	6b450513          	addi	a0,a0,1716 # 8001f618 <bcache>
    80002f6c:	c93fd0ef          	jal	80000bfe <acquire>
  b->refcnt++;
    80002f70:	40bc                	lw	a5,64(s1)
    80002f72:	2785                	addiw	a5,a5,1
    80002f74:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f76:	0001c517          	auipc	a0,0x1c
    80002f7a:	6a250513          	addi	a0,a0,1698 # 8001f618 <bcache>
    80002f7e:	d15fd0ef          	jal	80000c92 <release>
}
    80002f82:	60e2                	ld	ra,24(sp)
    80002f84:	6442                	ld	s0,16(sp)
    80002f86:	64a2                	ld	s1,8(sp)
    80002f88:	6105                	addi	sp,sp,32
    80002f8a:	8082                	ret

0000000080002f8c <bunpin>:

void
bunpin(struct buf *b) {
    80002f8c:	1101                	addi	sp,sp,-32
    80002f8e:	ec06                	sd	ra,24(sp)
    80002f90:	e822                	sd	s0,16(sp)
    80002f92:	e426                	sd	s1,8(sp)
    80002f94:	1000                	addi	s0,sp,32
    80002f96:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f98:	0001c517          	auipc	a0,0x1c
    80002f9c:	68050513          	addi	a0,a0,1664 # 8001f618 <bcache>
    80002fa0:	c5ffd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002fa4:	40bc                	lw	a5,64(s1)
    80002fa6:	37fd                	addiw	a5,a5,-1
    80002fa8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002faa:	0001c517          	auipc	a0,0x1c
    80002fae:	66e50513          	addi	a0,a0,1646 # 8001f618 <bcache>
    80002fb2:	ce1fd0ef          	jal	80000c92 <release>
}
    80002fb6:	60e2                	ld	ra,24(sp)
    80002fb8:	6442                	ld	s0,16(sp)
    80002fba:	64a2                	ld	s1,8(sp)
    80002fbc:	6105                	addi	sp,sp,32
    80002fbe:	8082                	ret

0000000080002fc0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002fc0:	1101                	addi	sp,sp,-32
    80002fc2:	ec06                	sd	ra,24(sp)
    80002fc4:	e822                	sd	s0,16(sp)
    80002fc6:	e426                	sd	s1,8(sp)
    80002fc8:	e04a                	sd	s2,0(sp)
    80002fca:	1000                	addi	s0,sp,32
    80002fcc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002fce:	00d5d79b          	srliw	a5,a1,0xd
    80002fd2:	00025597          	auipc	a1,0x25
    80002fd6:	d225a583          	lw	a1,-734(a1) # 80027cf4 <sb+0x1c>
    80002fda:	9dbd                	addw	a1,a1,a5
    80002fdc:	df1ff0ef          	jal	80002dcc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002fe0:	0074f713          	andi	a4,s1,7
    80002fe4:	4785                	li	a5,1
    80002fe6:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002fea:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002fec:	90d9                	srli	s1,s1,0x36
    80002fee:	00950733          	add	a4,a0,s1
    80002ff2:	05874703          	lbu	a4,88(a4)
    80002ff6:	00e7f6b3          	and	a3,a5,a4
    80002ffa:	c29d                	beqz	a3,80003020 <bfree+0x60>
    80002ffc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002ffe:	94aa                	add	s1,s1,a0
    80003000:	fff7c793          	not	a5,a5
    80003004:	8f7d                	and	a4,a4,a5
    80003006:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000300a:	711000ef          	jal	80003f1a <log_write>
  brelse(bp);
    8000300e:	854a                	mv	a0,s2
    80003010:	ec5ff0ef          	jal	80002ed4 <brelse>
}
    80003014:	60e2                	ld	ra,24(sp)
    80003016:	6442                	ld	s0,16(sp)
    80003018:	64a2                	ld	s1,8(sp)
    8000301a:	6902                	ld	s2,0(sp)
    8000301c:	6105                	addi	sp,sp,32
    8000301e:	8082                	ret
    panic("freeing free block");
    80003020:	00004517          	auipc	a0,0x4
    80003024:	51050513          	addi	a0,a0,1296 # 80007530 <etext+0x530>
    80003028:	f76fd0ef          	jal	8000079e <panic>

000000008000302c <balloc>:
{
    8000302c:	715d                	addi	sp,sp,-80
    8000302e:	e486                	sd	ra,72(sp)
    80003030:	e0a2                	sd	s0,64(sp)
    80003032:	fc26                	sd	s1,56(sp)
    80003034:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003036:	00025797          	auipc	a5,0x25
    8000303a:	ca67a783          	lw	a5,-858(a5) # 80027cdc <sb+0x4>
    8000303e:	0e078863          	beqz	a5,8000312e <balloc+0x102>
    80003042:	f84a                	sd	s2,48(sp)
    80003044:	f44e                	sd	s3,40(sp)
    80003046:	f052                	sd	s4,32(sp)
    80003048:	ec56                	sd	s5,24(sp)
    8000304a:	e85a                	sd	s6,16(sp)
    8000304c:	e45e                	sd	s7,8(sp)
    8000304e:	e062                	sd	s8,0(sp)
    80003050:	8baa                	mv	s7,a0
    80003052:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003054:	00025b17          	auipc	s6,0x25
    80003058:	c84b0b13          	addi	s6,s6,-892 # 80027cd8 <sb>
      m = 1 << (bi % 8);
    8000305c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000305e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003060:	6c09                	lui	s8,0x2
    80003062:	a09d                	j	800030c8 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003064:	97ca                	add	a5,a5,s2
    80003066:	8e55                	or	a2,a2,a3
    80003068:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000306c:	854a                	mv	a0,s2
    8000306e:	6ad000ef          	jal	80003f1a <log_write>
        brelse(bp);
    80003072:	854a                	mv	a0,s2
    80003074:	e61ff0ef          	jal	80002ed4 <brelse>
  bp = bread(dev, bno);
    80003078:	85a6                	mv	a1,s1
    8000307a:	855e                	mv	a0,s7
    8000307c:	d51ff0ef          	jal	80002dcc <bread>
    80003080:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003082:	40000613          	li	a2,1024
    80003086:	4581                	li	a1,0
    80003088:	05850513          	addi	a0,a0,88
    8000308c:	c43fd0ef          	jal	80000cce <memset>
  log_write(bp);
    80003090:	854a                	mv	a0,s2
    80003092:	689000ef          	jal	80003f1a <log_write>
  brelse(bp);
    80003096:	854a                	mv	a0,s2
    80003098:	e3dff0ef          	jal	80002ed4 <brelse>
}
    8000309c:	7942                	ld	s2,48(sp)
    8000309e:	79a2                	ld	s3,40(sp)
    800030a0:	7a02                	ld	s4,32(sp)
    800030a2:	6ae2                	ld	s5,24(sp)
    800030a4:	6b42                	ld	s6,16(sp)
    800030a6:	6ba2                	ld	s7,8(sp)
    800030a8:	6c02                	ld	s8,0(sp)
}
    800030aa:	8526                	mv	a0,s1
    800030ac:	60a6                	ld	ra,72(sp)
    800030ae:	6406                	ld	s0,64(sp)
    800030b0:	74e2                	ld	s1,56(sp)
    800030b2:	6161                	addi	sp,sp,80
    800030b4:	8082                	ret
    brelse(bp);
    800030b6:	854a                	mv	a0,s2
    800030b8:	e1dff0ef          	jal	80002ed4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800030bc:	015c0abb          	addw	s5,s8,s5
    800030c0:	004b2783          	lw	a5,4(s6)
    800030c4:	04fafe63          	bgeu	s5,a5,80003120 <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    800030c8:	41fad79b          	sraiw	a5,s5,0x1f
    800030cc:	0137d79b          	srliw	a5,a5,0x13
    800030d0:	015787bb          	addw	a5,a5,s5
    800030d4:	40d7d79b          	sraiw	a5,a5,0xd
    800030d8:	01cb2583          	lw	a1,28(s6)
    800030dc:	9dbd                	addw	a1,a1,a5
    800030de:	855e                	mv	a0,s7
    800030e0:	cedff0ef          	jal	80002dcc <bread>
    800030e4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030e6:	004b2503          	lw	a0,4(s6)
    800030ea:	84d6                	mv	s1,s5
    800030ec:	4701                	li	a4,0
    800030ee:	fca4f4e3          	bgeu	s1,a0,800030b6 <balloc+0x8a>
      m = 1 << (bi % 8);
    800030f2:	00777693          	andi	a3,a4,7
    800030f6:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800030fa:	41f7579b          	sraiw	a5,a4,0x1f
    800030fe:	01d7d79b          	srliw	a5,a5,0x1d
    80003102:	9fb9                	addw	a5,a5,a4
    80003104:	4037d79b          	sraiw	a5,a5,0x3
    80003108:	00f90633          	add	a2,s2,a5
    8000310c:	05864603          	lbu	a2,88(a2)
    80003110:	00c6f5b3          	and	a1,a3,a2
    80003114:	d9a1                	beqz	a1,80003064 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003116:	2705                	addiw	a4,a4,1
    80003118:	2485                	addiw	s1,s1,1
    8000311a:	fd471ae3          	bne	a4,s4,800030ee <balloc+0xc2>
    8000311e:	bf61                	j	800030b6 <balloc+0x8a>
    80003120:	7942                	ld	s2,48(sp)
    80003122:	79a2                	ld	s3,40(sp)
    80003124:	7a02                	ld	s4,32(sp)
    80003126:	6ae2                	ld	s5,24(sp)
    80003128:	6b42                	ld	s6,16(sp)
    8000312a:	6ba2                	ld	s7,8(sp)
    8000312c:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    8000312e:	00004517          	auipc	a0,0x4
    80003132:	41a50513          	addi	a0,a0,1050 # 80007548 <etext+0x548>
    80003136:	b98fd0ef          	jal	800004ce <printf>
  return 0;
    8000313a:	4481                	li	s1,0
    8000313c:	b7bd                	j	800030aa <balloc+0x7e>

000000008000313e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000313e:	7179                	addi	sp,sp,-48
    80003140:	f406                	sd	ra,40(sp)
    80003142:	f022                	sd	s0,32(sp)
    80003144:	ec26                	sd	s1,24(sp)
    80003146:	e84a                	sd	s2,16(sp)
    80003148:	e44e                	sd	s3,8(sp)
    8000314a:	1800                	addi	s0,sp,48
    8000314c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000314e:	47ad                	li	a5,11
    80003150:	02b7e363          	bltu	a5,a1,80003176 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80003154:	02059793          	slli	a5,a1,0x20
    80003158:	01e7d593          	srli	a1,a5,0x1e
    8000315c:	00b504b3          	add	s1,a0,a1
    80003160:	0504a903          	lw	s2,80(s1)
    80003164:	06091363          	bnez	s2,800031ca <bmap+0x8c>
      addr = balloc(ip->dev);
    80003168:	4108                	lw	a0,0(a0)
    8000316a:	ec3ff0ef          	jal	8000302c <balloc>
    8000316e:	892a                	mv	s2,a0
      if(addr == 0)
    80003170:	cd29                	beqz	a0,800031ca <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    80003172:	c8a8                	sw	a0,80(s1)
    80003174:	a899                	j	800031ca <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003176:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    8000317a:	0ff00793          	li	a5,255
    8000317e:	0697e963          	bltu	a5,s1,800031f0 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003182:	08052903          	lw	s2,128(a0)
    80003186:	00091b63          	bnez	s2,8000319c <bmap+0x5e>
      addr = balloc(ip->dev);
    8000318a:	4108                	lw	a0,0(a0)
    8000318c:	ea1ff0ef          	jal	8000302c <balloc>
    80003190:	892a                	mv	s2,a0
      if(addr == 0)
    80003192:	cd05                	beqz	a0,800031ca <bmap+0x8c>
    80003194:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003196:	08a9a023          	sw	a0,128(s3)
    8000319a:	a011                	j	8000319e <bmap+0x60>
    8000319c:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000319e:	85ca                	mv	a1,s2
    800031a0:	0009a503          	lw	a0,0(s3)
    800031a4:	c29ff0ef          	jal	80002dcc <bread>
    800031a8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800031aa:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800031ae:	02049713          	slli	a4,s1,0x20
    800031b2:	01e75593          	srli	a1,a4,0x1e
    800031b6:	00b784b3          	add	s1,a5,a1
    800031ba:	0004a903          	lw	s2,0(s1)
    800031be:	00090e63          	beqz	s2,800031da <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800031c2:	8552                	mv	a0,s4
    800031c4:	d11ff0ef          	jal	80002ed4 <brelse>
    return addr;
    800031c8:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800031ca:	854a                	mv	a0,s2
    800031cc:	70a2                	ld	ra,40(sp)
    800031ce:	7402                	ld	s0,32(sp)
    800031d0:	64e2                	ld	s1,24(sp)
    800031d2:	6942                	ld	s2,16(sp)
    800031d4:	69a2                	ld	s3,8(sp)
    800031d6:	6145                	addi	sp,sp,48
    800031d8:	8082                	ret
      addr = balloc(ip->dev);
    800031da:	0009a503          	lw	a0,0(s3)
    800031de:	e4fff0ef          	jal	8000302c <balloc>
    800031e2:	892a                	mv	s2,a0
      if(addr){
    800031e4:	dd79                	beqz	a0,800031c2 <bmap+0x84>
        a[bn] = addr;
    800031e6:	c088                	sw	a0,0(s1)
        log_write(bp);
    800031e8:	8552                	mv	a0,s4
    800031ea:	531000ef          	jal	80003f1a <log_write>
    800031ee:	bfd1                	j	800031c2 <bmap+0x84>
    800031f0:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800031f2:	00004517          	auipc	a0,0x4
    800031f6:	36e50513          	addi	a0,a0,878 # 80007560 <etext+0x560>
    800031fa:	da4fd0ef          	jal	8000079e <panic>

00000000800031fe <iget>:
{
    800031fe:	7179                	addi	sp,sp,-48
    80003200:	f406                	sd	ra,40(sp)
    80003202:	f022                	sd	s0,32(sp)
    80003204:	ec26                	sd	s1,24(sp)
    80003206:	e84a                	sd	s2,16(sp)
    80003208:	e44e                	sd	s3,8(sp)
    8000320a:	e052                	sd	s4,0(sp)
    8000320c:	1800                	addi	s0,sp,48
    8000320e:	89aa                	mv	s3,a0
    80003210:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003212:	00025517          	auipc	a0,0x25
    80003216:	ae650513          	addi	a0,a0,-1306 # 80027cf8 <itable>
    8000321a:	9e5fd0ef          	jal	80000bfe <acquire>
  empty = 0;
    8000321e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003220:	00025497          	auipc	s1,0x25
    80003224:	af048493          	addi	s1,s1,-1296 # 80027d10 <itable+0x18>
    80003228:	00026697          	auipc	a3,0x26
    8000322c:	57868693          	addi	a3,a3,1400 # 800297a0 <log>
    80003230:	a039                	j	8000323e <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003232:	02090963          	beqz	s2,80003264 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003236:	08848493          	addi	s1,s1,136
    8000323a:	02d48863          	beq	s1,a3,8000326a <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000323e:	449c                	lw	a5,8(s1)
    80003240:	fef059e3          	blez	a5,80003232 <iget+0x34>
    80003244:	4098                	lw	a4,0(s1)
    80003246:	ff3716e3          	bne	a4,s3,80003232 <iget+0x34>
    8000324a:	40d8                	lw	a4,4(s1)
    8000324c:	ff4713e3          	bne	a4,s4,80003232 <iget+0x34>
      ip->ref++;
    80003250:	2785                	addiw	a5,a5,1
    80003252:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003254:	00025517          	auipc	a0,0x25
    80003258:	aa450513          	addi	a0,a0,-1372 # 80027cf8 <itable>
    8000325c:	a37fd0ef          	jal	80000c92 <release>
      return ip;
    80003260:	8926                	mv	s2,s1
    80003262:	a02d                	j	8000328c <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003264:	fbe9                	bnez	a5,80003236 <iget+0x38>
      empty = ip;
    80003266:	8926                	mv	s2,s1
    80003268:	b7f9                	j	80003236 <iget+0x38>
  if(empty == 0)
    8000326a:	02090a63          	beqz	s2,8000329e <iget+0xa0>
  ip->dev = dev;
    8000326e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003272:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003276:	4785                	li	a5,1
    80003278:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000327c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003280:	00025517          	auipc	a0,0x25
    80003284:	a7850513          	addi	a0,a0,-1416 # 80027cf8 <itable>
    80003288:	a0bfd0ef          	jal	80000c92 <release>
}
    8000328c:	854a                	mv	a0,s2
    8000328e:	70a2                	ld	ra,40(sp)
    80003290:	7402                	ld	s0,32(sp)
    80003292:	64e2                	ld	s1,24(sp)
    80003294:	6942                	ld	s2,16(sp)
    80003296:	69a2                	ld	s3,8(sp)
    80003298:	6a02                	ld	s4,0(sp)
    8000329a:	6145                	addi	sp,sp,48
    8000329c:	8082                	ret
    panic("iget: no inodes");
    8000329e:	00004517          	auipc	a0,0x4
    800032a2:	2da50513          	addi	a0,a0,730 # 80007578 <etext+0x578>
    800032a6:	cf8fd0ef          	jal	8000079e <panic>

00000000800032aa <fsinit>:
fsinit(int dev) {
    800032aa:	7179                	addi	sp,sp,-48
    800032ac:	f406                	sd	ra,40(sp)
    800032ae:	f022                	sd	s0,32(sp)
    800032b0:	ec26                	sd	s1,24(sp)
    800032b2:	e84a                	sd	s2,16(sp)
    800032b4:	e44e                	sd	s3,8(sp)
    800032b6:	1800                	addi	s0,sp,48
    800032b8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800032ba:	4585                	li	a1,1
    800032bc:	b11ff0ef          	jal	80002dcc <bread>
    800032c0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800032c2:	00025997          	auipc	s3,0x25
    800032c6:	a1698993          	addi	s3,s3,-1514 # 80027cd8 <sb>
    800032ca:	02000613          	li	a2,32
    800032ce:	05850593          	addi	a1,a0,88
    800032d2:	854e                	mv	a0,s3
    800032d4:	a5ffd0ef          	jal	80000d32 <memmove>
  brelse(bp);
    800032d8:	8526                	mv	a0,s1
    800032da:	bfbff0ef          	jal	80002ed4 <brelse>
  if(sb.magic != FSMAGIC)
    800032de:	0009a703          	lw	a4,0(s3)
    800032e2:	102037b7          	lui	a5,0x10203
    800032e6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800032ea:	02f71063          	bne	a4,a5,8000330a <fsinit+0x60>
  initlog(dev, &sb);
    800032ee:	00025597          	auipc	a1,0x25
    800032f2:	9ea58593          	addi	a1,a1,-1558 # 80027cd8 <sb>
    800032f6:	854a                	mv	a0,s2
    800032f8:	215000ef          	jal	80003d0c <initlog>
}
    800032fc:	70a2                	ld	ra,40(sp)
    800032fe:	7402                	ld	s0,32(sp)
    80003300:	64e2                	ld	s1,24(sp)
    80003302:	6942                	ld	s2,16(sp)
    80003304:	69a2                	ld	s3,8(sp)
    80003306:	6145                	addi	sp,sp,48
    80003308:	8082                	ret
    panic("invalid file system");
    8000330a:	00004517          	auipc	a0,0x4
    8000330e:	27e50513          	addi	a0,a0,638 # 80007588 <etext+0x588>
    80003312:	c8cfd0ef          	jal	8000079e <panic>

0000000080003316 <iinit>:
{
    80003316:	7179                	addi	sp,sp,-48
    80003318:	f406                	sd	ra,40(sp)
    8000331a:	f022                	sd	s0,32(sp)
    8000331c:	ec26                	sd	s1,24(sp)
    8000331e:	e84a                	sd	s2,16(sp)
    80003320:	e44e                	sd	s3,8(sp)
    80003322:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003324:	00004597          	auipc	a1,0x4
    80003328:	27c58593          	addi	a1,a1,636 # 800075a0 <etext+0x5a0>
    8000332c:	00025517          	auipc	a0,0x25
    80003330:	9cc50513          	addi	a0,a0,-1588 # 80027cf8 <itable>
    80003334:	847fd0ef          	jal	80000b7a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003338:	00025497          	auipc	s1,0x25
    8000333c:	9e848493          	addi	s1,s1,-1560 # 80027d20 <itable+0x28>
    80003340:	00026997          	auipc	s3,0x26
    80003344:	47098993          	addi	s3,s3,1136 # 800297b0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003348:	00004917          	auipc	s2,0x4
    8000334c:	26090913          	addi	s2,s2,608 # 800075a8 <etext+0x5a8>
    80003350:	85ca                	mv	a1,s2
    80003352:	8526                	mv	a0,s1
    80003354:	497000ef          	jal	80003fea <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003358:	08848493          	addi	s1,s1,136
    8000335c:	ff349ae3          	bne	s1,s3,80003350 <iinit+0x3a>
}
    80003360:	70a2                	ld	ra,40(sp)
    80003362:	7402                	ld	s0,32(sp)
    80003364:	64e2                	ld	s1,24(sp)
    80003366:	6942                	ld	s2,16(sp)
    80003368:	69a2                	ld	s3,8(sp)
    8000336a:	6145                	addi	sp,sp,48
    8000336c:	8082                	ret

000000008000336e <ialloc>:
{
    8000336e:	7139                	addi	sp,sp,-64
    80003370:	fc06                	sd	ra,56(sp)
    80003372:	f822                	sd	s0,48(sp)
    80003374:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003376:	00025717          	auipc	a4,0x25
    8000337a:	96e72703          	lw	a4,-1682(a4) # 80027ce4 <sb+0xc>
    8000337e:	4785                	li	a5,1
    80003380:	06e7f063          	bgeu	a5,a4,800033e0 <ialloc+0x72>
    80003384:	f426                	sd	s1,40(sp)
    80003386:	f04a                	sd	s2,32(sp)
    80003388:	ec4e                	sd	s3,24(sp)
    8000338a:	e852                	sd	s4,16(sp)
    8000338c:	e456                	sd	s5,8(sp)
    8000338e:	e05a                	sd	s6,0(sp)
    80003390:	8aaa                	mv	s5,a0
    80003392:	8b2e                	mv	s6,a1
    80003394:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003396:	00025a17          	auipc	s4,0x25
    8000339a:	942a0a13          	addi	s4,s4,-1726 # 80027cd8 <sb>
    8000339e:	00495593          	srli	a1,s2,0x4
    800033a2:	018a2783          	lw	a5,24(s4)
    800033a6:	9dbd                	addw	a1,a1,a5
    800033a8:	8556                	mv	a0,s5
    800033aa:	a23ff0ef          	jal	80002dcc <bread>
    800033ae:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800033b0:	05850993          	addi	s3,a0,88
    800033b4:	00f97793          	andi	a5,s2,15
    800033b8:	079a                	slli	a5,a5,0x6
    800033ba:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800033bc:	00099783          	lh	a5,0(s3)
    800033c0:	cb9d                	beqz	a5,800033f6 <ialloc+0x88>
    brelse(bp);
    800033c2:	b13ff0ef          	jal	80002ed4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800033c6:	0905                	addi	s2,s2,1
    800033c8:	00ca2703          	lw	a4,12(s4)
    800033cc:	0009079b          	sext.w	a5,s2
    800033d0:	fce7e7e3          	bltu	a5,a4,8000339e <ialloc+0x30>
    800033d4:	74a2                	ld	s1,40(sp)
    800033d6:	7902                	ld	s2,32(sp)
    800033d8:	69e2                	ld	s3,24(sp)
    800033da:	6a42                	ld	s4,16(sp)
    800033dc:	6aa2                	ld	s5,8(sp)
    800033de:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800033e0:	00004517          	auipc	a0,0x4
    800033e4:	1d050513          	addi	a0,a0,464 # 800075b0 <etext+0x5b0>
    800033e8:	8e6fd0ef          	jal	800004ce <printf>
  return 0;
    800033ec:	4501                	li	a0,0
}
    800033ee:	70e2                	ld	ra,56(sp)
    800033f0:	7442                	ld	s0,48(sp)
    800033f2:	6121                	addi	sp,sp,64
    800033f4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800033f6:	04000613          	li	a2,64
    800033fa:	4581                	li	a1,0
    800033fc:	854e                	mv	a0,s3
    800033fe:	8d1fd0ef          	jal	80000cce <memset>
      dip->type = type;
    80003402:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003406:	8526                	mv	a0,s1
    80003408:	313000ef          	jal	80003f1a <log_write>
      brelse(bp);
    8000340c:	8526                	mv	a0,s1
    8000340e:	ac7ff0ef          	jal	80002ed4 <brelse>
      return iget(dev, inum);
    80003412:	0009059b          	sext.w	a1,s2
    80003416:	8556                	mv	a0,s5
    80003418:	de7ff0ef          	jal	800031fe <iget>
    8000341c:	74a2                	ld	s1,40(sp)
    8000341e:	7902                	ld	s2,32(sp)
    80003420:	69e2                	ld	s3,24(sp)
    80003422:	6a42                	ld	s4,16(sp)
    80003424:	6aa2                	ld	s5,8(sp)
    80003426:	6b02                	ld	s6,0(sp)
    80003428:	b7d9                	j	800033ee <ialloc+0x80>

000000008000342a <iupdate>:
{
    8000342a:	1101                	addi	sp,sp,-32
    8000342c:	ec06                	sd	ra,24(sp)
    8000342e:	e822                	sd	s0,16(sp)
    80003430:	e426                	sd	s1,8(sp)
    80003432:	e04a                	sd	s2,0(sp)
    80003434:	1000                	addi	s0,sp,32
    80003436:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003438:	415c                	lw	a5,4(a0)
    8000343a:	0047d79b          	srliw	a5,a5,0x4
    8000343e:	00025597          	auipc	a1,0x25
    80003442:	8b25a583          	lw	a1,-1870(a1) # 80027cf0 <sb+0x18>
    80003446:	9dbd                	addw	a1,a1,a5
    80003448:	4108                	lw	a0,0(a0)
    8000344a:	983ff0ef          	jal	80002dcc <bread>
    8000344e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003450:	05850793          	addi	a5,a0,88
    80003454:	40d8                	lw	a4,4(s1)
    80003456:	8b3d                	andi	a4,a4,15
    80003458:	071a                	slli	a4,a4,0x6
    8000345a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000345c:	04449703          	lh	a4,68(s1)
    80003460:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003464:	04649703          	lh	a4,70(s1)
    80003468:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000346c:	04849703          	lh	a4,72(s1)
    80003470:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003474:	04a49703          	lh	a4,74(s1)
    80003478:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000347c:	44f8                	lw	a4,76(s1)
    8000347e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003480:	03400613          	li	a2,52
    80003484:	05048593          	addi	a1,s1,80
    80003488:	00c78513          	addi	a0,a5,12
    8000348c:	8a7fd0ef          	jal	80000d32 <memmove>
  log_write(bp);
    80003490:	854a                	mv	a0,s2
    80003492:	289000ef          	jal	80003f1a <log_write>
  brelse(bp);
    80003496:	854a                	mv	a0,s2
    80003498:	a3dff0ef          	jal	80002ed4 <brelse>
}
    8000349c:	60e2                	ld	ra,24(sp)
    8000349e:	6442                	ld	s0,16(sp)
    800034a0:	64a2                	ld	s1,8(sp)
    800034a2:	6902                	ld	s2,0(sp)
    800034a4:	6105                	addi	sp,sp,32
    800034a6:	8082                	ret

00000000800034a8 <idup>:
{
    800034a8:	1101                	addi	sp,sp,-32
    800034aa:	ec06                	sd	ra,24(sp)
    800034ac:	e822                	sd	s0,16(sp)
    800034ae:	e426                	sd	s1,8(sp)
    800034b0:	1000                	addi	s0,sp,32
    800034b2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034b4:	00025517          	auipc	a0,0x25
    800034b8:	84450513          	addi	a0,a0,-1980 # 80027cf8 <itable>
    800034bc:	f42fd0ef          	jal	80000bfe <acquire>
  ip->ref++;
    800034c0:	449c                	lw	a5,8(s1)
    800034c2:	2785                	addiw	a5,a5,1
    800034c4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034c6:	00025517          	auipc	a0,0x25
    800034ca:	83250513          	addi	a0,a0,-1998 # 80027cf8 <itable>
    800034ce:	fc4fd0ef          	jal	80000c92 <release>
}
    800034d2:	8526                	mv	a0,s1
    800034d4:	60e2                	ld	ra,24(sp)
    800034d6:	6442                	ld	s0,16(sp)
    800034d8:	64a2                	ld	s1,8(sp)
    800034da:	6105                	addi	sp,sp,32
    800034dc:	8082                	ret

00000000800034de <ilock>:
{
    800034de:	1101                	addi	sp,sp,-32
    800034e0:	ec06                	sd	ra,24(sp)
    800034e2:	e822                	sd	s0,16(sp)
    800034e4:	e426                	sd	s1,8(sp)
    800034e6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800034e8:	cd19                	beqz	a0,80003506 <ilock+0x28>
    800034ea:	84aa                	mv	s1,a0
    800034ec:	451c                	lw	a5,8(a0)
    800034ee:	00f05c63          	blez	a5,80003506 <ilock+0x28>
  acquiresleep(&ip->lock);
    800034f2:	0541                	addi	a0,a0,16
    800034f4:	32d000ef          	jal	80004020 <acquiresleep>
  if(ip->valid == 0){
    800034f8:	40bc                	lw	a5,64(s1)
    800034fa:	cf89                	beqz	a5,80003514 <ilock+0x36>
}
    800034fc:	60e2                	ld	ra,24(sp)
    800034fe:	6442                	ld	s0,16(sp)
    80003500:	64a2                	ld	s1,8(sp)
    80003502:	6105                	addi	sp,sp,32
    80003504:	8082                	ret
    80003506:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003508:	00004517          	auipc	a0,0x4
    8000350c:	0c050513          	addi	a0,a0,192 # 800075c8 <etext+0x5c8>
    80003510:	a8efd0ef          	jal	8000079e <panic>
    80003514:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003516:	40dc                	lw	a5,4(s1)
    80003518:	0047d79b          	srliw	a5,a5,0x4
    8000351c:	00024597          	auipc	a1,0x24
    80003520:	7d45a583          	lw	a1,2004(a1) # 80027cf0 <sb+0x18>
    80003524:	9dbd                	addw	a1,a1,a5
    80003526:	4088                	lw	a0,0(s1)
    80003528:	8a5ff0ef          	jal	80002dcc <bread>
    8000352c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000352e:	05850593          	addi	a1,a0,88
    80003532:	40dc                	lw	a5,4(s1)
    80003534:	8bbd                	andi	a5,a5,15
    80003536:	079a                	slli	a5,a5,0x6
    80003538:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000353a:	00059783          	lh	a5,0(a1)
    8000353e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003542:	00259783          	lh	a5,2(a1)
    80003546:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000354a:	00459783          	lh	a5,4(a1)
    8000354e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003552:	00659783          	lh	a5,6(a1)
    80003556:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000355a:	459c                	lw	a5,8(a1)
    8000355c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000355e:	03400613          	li	a2,52
    80003562:	05b1                	addi	a1,a1,12
    80003564:	05048513          	addi	a0,s1,80
    80003568:	fcafd0ef          	jal	80000d32 <memmove>
    brelse(bp);
    8000356c:	854a                	mv	a0,s2
    8000356e:	967ff0ef          	jal	80002ed4 <brelse>
    ip->valid = 1;
    80003572:	4785                	li	a5,1
    80003574:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003576:	04449783          	lh	a5,68(s1)
    8000357a:	c399                	beqz	a5,80003580 <ilock+0xa2>
    8000357c:	6902                	ld	s2,0(sp)
    8000357e:	bfbd                	j	800034fc <ilock+0x1e>
      panic("ilock: no type");
    80003580:	00004517          	auipc	a0,0x4
    80003584:	05050513          	addi	a0,a0,80 # 800075d0 <etext+0x5d0>
    80003588:	a16fd0ef          	jal	8000079e <panic>

000000008000358c <iunlock>:
{
    8000358c:	1101                	addi	sp,sp,-32
    8000358e:	ec06                	sd	ra,24(sp)
    80003590:	e822                	sd	s0,16(sp)
    80003592:	e426                	sd	s1,8(sp)
    80003594:	e04a                	sd	s2,0(sp)
    80003596:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003598:	c505                	beqz	a0,800035c0 <iunlock+0x34>
    8000359a:	84aa                	mv	s1,a0
    8000359c:	01050913          	addi	s2,a0,16
    800035a0:	854a                	mv	a0,s2
    800035a2:	2fd000ef          	jal	8000409e <holdingsleep>
    800035a6:	cd09                	beqz	a0,800035c0 <iunlock+0x34>
    800035a8:	449c                	lw	a5,8(s1)
    800035aa:	00f05b63          	blez	a5,800035c0 <iunlock+0x34>
  releasesleep(&ip->lock);
    800035ae:	854a                	mv	a0,s2
    800035b0:	2b7000ef          	jal	80004066 <releasesleep>
}
    800035b4:	60e2                	ld	ra,24(sp)
    800035b6:	6442                	ld	s0,16(sp)
    800035b8:	64a2                	ld	s1,8(sp)
    800035ba:	6902                	ld	s2,0(sp)
    800035bc:	6105                	addi	sp,sp,32
    800035be:	8082                	ret
    panic("iunlock");
    800035c0:	00004517          	auipc	a0,0x4
    800035c4:	02050513          	addi	a0,a0,32 # 800075e0 <etext+0x5e0>
    800035c8:	9d6fd0ef          	jal	8000079e <panic>

00000000800035cc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800035cc:	7179                	addi	sp,sp,-48
    800035ce:	f406                	sd	ra,40(sp)
    800035d0:	f022                	sd	s0,32(sp)
    800035d2:	ec26                	sd	s1,24(sp)
    800035d4:	e84a                	sd	s2,16(sp)
    800035d6:	e44e                	sd	s3,8(sp)
    800035d8:	1800                	addi	s0,sp,48
    800035da:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800035dc:	05050493          	addi	s1,a0,80
    800035e0:	08050913          	addi	s2,a0,128
    800035e4:	a021                	j	800035ec <itrunc+0x20>
    800035e6:	0491                	addi	s1,s1,4
    800035e8:	01248b63          	beq	s1,s2,800035fe <itrunc+0x32>
    if(ip->addrs[i]){
    800035ec:	408c                	lw	a1,0(s1)
    800035ee:	dde5                	beqz	a1,800035e6 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800035f0:	0009a503          	lw	a0,0(s3)
    800035f4:	9cdff0ef          	jal	80002fc0 <bfree>
      ip->addrs[i] = 0;
    800035f8:	0004a023          	sw	zero,0(s1)
    800035fc:	b7ed                	j	800035e6 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800035fe:	0809a583          	lw	a1,128(s3)
    80003602:	ed89                	bnez	a1,8000361c <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003604:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003608:	854e                	mv	a0,s3
    8000360a:	e21ff0ef          	jal	8000342a <iupdate>
}
    8000360e:	70a2                	ld	ra,40(sp)
    80003610:	7402                	ld	s0,32(sp)
    80003612:	64e2                	ld	s1,24(sp)
    80003614:	6942                	ld	s2,16(sp)
    80003616:	69a2                	ld	s3,8(sp)
    80003618:	6145                	addi	sp,sp,48
    8000361a:	8082                	ret
    8000361c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000361e:	0009a503          	lw	a0,0(s3)
    80003622:	faaff0ef          	jal	80002dcc <bread>
    80003626:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003628:	05850493          	addi	s1,a0,88
    8000362c:	45850913          	addi	s2,a0,1112
    80003630:	a021                	j	80003638 <itrunc+0x6c>
    80003632:	0491                	addi	s1,s1,4
    80003634:	01248963          	beq	s1,s2,80003646 <itrunc+0x7a>
      if(a[j])
    80003638:	408c                	lw	a1,0(s1)
    8000363a:	dde5                	beqz	a1,80003632 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000363c:	0009a503          	lw	a0,0(s3)
    80003640:	981ff0ef          	jal	80002fc0 <bfree>
    80003644:	b7fd                	j	80003632 <itrunc+0x66>
    brelse(bp);
    80003646:	8552                	mv	a0,s4
    80003648:	88dff0ef          	jal	80002ed4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000364c:	0809a583          	lw	a1,128(s3)
    80003650:	0009a503          	lw	a0,0(s3)
    80003654:	96dff0ef          	jal	80002fc0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003658:	0809a023          	sw	zero,128(s3)
    8000365c:	6a02                	ld	s4,0(sp)
    8000365e:	b75d                	j	80003604 <itrunc+0x38>

0000000080003660 <iput>:
{
    80003660:	1101                	addi	sp,sp,-32
    80003662:	ec06                	sd	ra,24(sp)
    80003664:	e822                	sd	s0,16(sp)
    80003666:	e426                	sd	s1,8(sp)
    80003668:	1000                	addi	s0,sp,32
    8000366a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000366c:	00024517          	auipc	a0,0x24
    80003670:	68c50513          	addi	a0,a0,1676 # 80027cf8 <itable>
    80003674:	d8afd0ef          	jal	80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003678:	4498                	lw	a4,8(s1)
    8000367a:	4785                	li	a5,1
    8000367c:	02f70063          	beq	a4,a5,8000369c <iput+0x3c>
  ip->ref--;
    80003680:	449c                	lw	a5,8(s1)
    80003682:	37fd                	addiw	a5,a5,-1
    80003684:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003686:	00024517          	auipc	a0,0x24
    8000368a:	67250513          	addi	a0,a0,1650 # 80027cf8 <itable>
    8000368e:	e04fd0ef          	jal	80000c92 <release>
}
    80003692:	60e2                	ld	ra,24(sp)
    80003694:	6442                	ld	s0,16(sp)
    80003696:	64a2                	ld	s1,8(sp)
    80003698:	6105                	addi	sp,sp,32
    8000369a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000369c:	40bc                	lw	a5,64(s1)
    8000369e:	d3ed                	beqz	a5,80003680 <iput+0x20>
    800036a0:	04a49783          	lh	a5,74(s1)
    800036a4:	fff1                	bnez	a5,80003680 <iput+0x20>
    800036a6:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800036a8:	01048913          	addi	s2,s1,16
    800036ac:	854a                	mv	a0,s2
    800036ae:	173000ef          	jal	80004020 <acquiresleep>
    release(&itable.lock);
    800036b2:	00024517          	auipc	a0,0x24
    800036b6:	64650513          	addi	a0,a0,1606 # 80027cf8 <itable>
    800036ba:	dd8fd0ef          	jal	80000c92 <release>
    itrunc(ip);
    800036be:	8526                	mv	a0,s1
    800036c0:	f0dff0ef          	jal	800035cc <itrunc>
    ip->type = 0;
    800036c4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800036c8:	8526                	mv	a0,s1
    800036ca:	d61ff0ef          	jal	8000342a <iupdate>
    ip->valid = 0;
    800036ce:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800036d2:	854a                	mv	a0,s2
    800036d4:	193000ef          	jal	80004066 <releasesleep>
    acquire(&itable.lock);
    800036d8:	00024517          	auipc	a0,0x24
    800036dc:	62050513          	addi	a0,a0,1568 # 80027cf8 <itable>
    800036e0:	d1efd0ef          	jal	80000bfe <acquire>
    800036e4:	6902                	ld	s2,0(sp)
    800036e6:	bf69                	j	80003680 <iput+0x20>

00000000800036e8 <iunlockput>:
{
    800036e8:	1101                	addi	sp,sp,-32
    800036ea:	ec06                	sd	ra,24(sp)
    800036ec:	e822                	sd	s0,16(sp)
    800036ee:	e426                	sd	s1,8(sp)
    800036f0:	1000                	addi	s0,sp,32
    800036f2:	84aa                	mv	s1,a0
  iunlock(ip);
    800036f4:	e99ff0ef          	jal	8000358c <iunlock>
  iput(ip);
    800036f8:	8526                	mv	a0,s1
    800036fa:	f67ff0ef          	jal	80003660 <iput>
}
    800036fe:	60e2                	ld	ra,24(sp)
    80003700:	6442                	ld	s0,16(sp)
    80003702:	64a2                	ld	s1,8(sp)
    80003704:	6105                	addi	sp,sp,32
    80003706:	8082                	ret

0000000080003708 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003708:	1141                	addi	sp,sp,-16
    8000370a:	e406                	sd	ra,8(sp)
    8000370c:	e022                	sd	s0,0(sp)
    8000370e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003710:	411c                	lw	a5,0(a0)
    80003712:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003714:	415c                	lw	a5,4(a0)
    80003716:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003718:	04451783          	lh	a5,68(a0)
    8000371c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003720:	04a51783          	lh	a5,74(a0)
    80003724:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003728:	04c56783          	lwu	a5,76(a0)
    8000372c:	e99c                	sd	a5,16(a1)
}
    8000372e:	60a2                	ld	ra,8(sp)
    80003730:	6402                	ld	s0,0(sp)
    80003732:	0141                	addi	sp,sp,16
    80003734:	8082                	ret

0000000080003736 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003736:	457c                	lw	a5,76(a0)
    80003738:	0ed7e663          	bltu	a5,a3,80003824 <readi+0xee>
{
    8000373c:	7159                	addi	sp,sp,-112
    8000373e:	f486                	sd	ra,104(sp)
    80003740:	f0a2                	sd	s0,96(sp)
    80003742:	eca6                	sd	s1,88(sp)
    80003744:	e0d2                	sd	s4,64(sp)
    80003746:	fc56                	sd	s5,56(sp)
    80003748:	f85a                	sd	s6,48(sp)
    8000374a:	f45e                	sd	s7,40(sp)
    8000374c:	1880                	addi	s0,sp,112
    8000374e:	8b2a                	mv	s6,a0
    80003750:	8bae                	mv	s7,a1
    80003752:	8a32                	mv	s4,a2
    80003754:	84b6                	mv	s1,a3
    80003756:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003758:	9f35                	addw	a4,a4,a3
    return 0;
    8000375a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000375c:	0ad76b63          	bltu	a4,a3,80003812 <readi+0xdc>
    80003760:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003762:	00e7f463          	bgeu	a5,a4,8000376a <readi+0x34>
    n = ip->size - off;
    80003766:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000376a:	080a8b63          	beqz	s5,80003800 <readi+0xca>
    8000376e:	e8ca                	sd	s2,80(sp)
    80003770:	f062                	sd	s8,32(sp)
    80003772:	ec66                	sd	s9,24(sp)
    80003774:	e86a                	sd	s10,16(sp)
    80003776:	e46e                	sd	s11,8(sp)
    80003778:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000377a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000377e:	5c7d                	li	s8,-1
    80003780:	a80d                	j	800037b2 <readi+0x7c>
    80003782:	020d1d93          	slli	s11,s10,0x20
    80003786:	020ddd93          	srli	s11,s11,0x20
    8000378a:	05890613          	addi	a2,s2,88
    8000378e:	86ee                	mv	a3,s11
    80003790:	963e                	add	a2,a2,a5
    80003792:	85d2                	mv	a1,s4
    80003794:	855e                	mv	a0,s7
    80003796:	bc3fe0ef          	jal	80002358 <either_copyout>
    8000379a:	05850363          	beq	a0,s8,800037e0 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000379e:	854a                	mv	a0,s2
    800037a0:	f34ff0ef          	jal	80002ed4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037a4:	013d09bb          	addw	s3,s10,s3
    800037a8:	009d04bb          	addw	s1,s10,s1
    800037ac:	9a6e                	add	s4,s4,s11
    800037ae:	0559f363          	bgeu	s3,s5,800037f4 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800037b2:	00a4d59b          	srliw	a1,s1,0xa
    800037b6:	855a                	mv	a0,s6
    800037b8:	987ff0ef          	jal	8000313e <bmap>
    800037bc:	85aa                	mv	a1,a0
    if(addr == 0)
    800037be:	c139                	beqz	a0,80003804 <readi+0xce>
    bp = bread(ip->dev, addr);
    800037c0:	000b2503          	lw	a0,0(s6)
    800037c4:	e08ff0ef          	jal	80002dcc <bread>
    800037c8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037ca:	3ff4f793          	andi	a5,s1,1023
    800037ce:	40fc873b          	subw	a4,s9,a5
    800037d2:	413a86bb          	subw	a3,s5,s3
    800037d6:	8d3a                	mv	s10,a4
    800037d8:	fae6f5e3          	bgeu	a3,a4,80003782 <readi+0x4c>
    800037dc:	8d36                	mv	s10,a3
    800037de:	b755                	j	80003782 <readi+0x4c>
      brelse(bp);
    800037e0:	854a                	mv	a0,s2
    800037e2:	ef2ff0ef          	jal	80002ed4 <brelse>
      tot = -1;
    800037e6:	59fd                	li	s3,-1
      break;
    800037e8:	6946                	ld	s2,80(sp)
    800037ea:	7c02                	ld	s8,32(sp)
    800037ec:	6ce2                	ld	s9,24(sp)
    800037ee:	6d42                	ld	s10,16(sp)
    800037f0:	6da2                	ld	s11,8(sp)
    800037f2:	a831                	j	8000380e <readi+0xd8>
    800037f4:	6946                	ld	s2,80(sp)
    800037f6:	7c02                	ld	s8,32(sp)
    800037f8:	6ce2                	ld	s9,24(sp)
    800037fa:	6d42                	ld	s10,16(sp)
    800037fc:	6da2                	ld	s11,8(sp)
    800037fe:	a801                	j	8000380e <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003800:	89d6                	mv	s3,s5
    80003802:	a031                	j	8000380e <readi+0xd8>
    80003804:	6946                	ld	s2,80(sp)
    80003806:	7c02                	ld	s8,32(sp)
    80003808:	6ce2                	ld	s9,24(sp)
    8000380a:	6d42                	ld	s10,16(sp)
    8000380c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000380e:	854e                	mv	a0,s3
    80003810:	69a6                	ld	s3,72(sp)
}
    80003812:	70a6                	ld	ra,104(sp)
    80003814:	7406                	ld	s0,96(sp)
    80003816:	64e6                	ld	s1,88(sp)
    80003818:	6a06                	ld	s4,64(sp)
    8000381a:	7ae2                	ld	s5,56(sp)
    8000381c:	7b42                	ld	s6,48(sp)
    8000381e:	7ba2                	ld	s7,40(sp)
    80003820:	6165                	addi	sp,sp,112
    80003822:	8082                	ret
    return 0;
    80003824:	4501                	li	a0,0
}
    80003826:	8082                	ret

0000000080003828 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003828:	457c                	lw	a5,76(a0)
    8000382a:	0ed7eb63          	bltu	a5,a3,80003920 <writei+0xf8>
{
    8000382e:	7159                	addi	sp,sp,-112
    80003830:	f486                	sd	ra,104(sp)
    80003832:	f0a2                	sd	s0,96(sp)
    80003834:	e8ca                	sd	s2,80(sp)
    80003836:	e0d2                	sd	s4,64(sp)
    80003838:	fc56                	sd	s5,56(sp)
    8000383a:	f85a                	sd	s6,48(sp)
    8000383c:	f45e                	sd	s7,40(sp)
    8000383e:	1880                	addi	s0,sp,112
    80003840:	8aaa                	mv	s5,a0
    80003842:	8bae                	mv	s7,a1
    80003844:	8a32                	mv	s4,a2
    80003846:	8936                	mv	s2,a3
    80003848:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000384a:	00e687bb          	addw	a5,a3,a4
    8000384e:	0cd7eb63          	bltu	a5,a3,80003924 <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003852:	00043737          	lui	a4,0x43
    80003856:	0cf76963          	bltu	a4,a5,80003928 <writei+0x100>
    8000385a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000385c:	0a0b0a63          	beqz	s6,80003910 <writei+0xe8>
    80003860:	eca6                	sd	s1,88(sp)
    80003862:	f062                	sd	s8,32(sp)
    80003864:	ec66                	sd	s9,24(sp)
    80003866:	e86a                	sd	s10,16(sp)
    80003868:	e46e                	sd	s11,8(sp)
    8000386a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000386c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003870:	5c7d                	li	s8,-1
    80003872:	a825                	j	800038aa <writei+0x82>
    80003874:	020d1d93          	slli	s11,s10,0x20
    80003878:	020ddd93          	srli	s11,s11,0x20
    8000387c:	05848513          	addi	a0,s1,88
    80003880:	86ee                	mv	a3,s11
    80003882:	8652                	mv	a2,s4
    80003884:	85de                	mv	a1,s7
    80003886:	953e                	add	a0,a0,a5
    80003888:	b1bfe0ef          	jal	800023a2 <either_copyin>
    8000388c:	05850663          	beq	a0,s8,800038d8 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003890:	8526                	mv	a0,s1
    80003892:	688000ef          	jal	80003f1a <log_write>
    brelse(bp);
    80003896:	8526                	mv	a0,s1
    80003898:	e3cff0ef          	jal	80002ed4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000389c:	013d09bb          	addw	s3,s10,s3
    800038a0:	012d093b          	addw	s2,s10,s2
    800038a4:	9a6e                	add	s4,s4,s11
    800038a6:	0369fc63          	bgeu	s3,s6,800038de <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    800038aa:	00a9559b          	srliw	a1,s2,0xa
    800038ae:	8556                	mv	a0,s5
    800038b0:	88fff0ef          	jal	8000313e <bmap>
    800038b4:	85aa                	mv	a1,a0
    if(addr == 0)
    800038b6:	c505                	beqz	a0,800038de <writei+0xb6>
    bp = bread(ip->dev, addr);
    800038b8:	000aa503          	lw	a0,0(s5)
    800038bc:	d10ff0ef          	jal	80002dcc <bread>
    800038c0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038c2:	3ff97793          	andi	a5,s2,1023
    800038c6:	40fc873b          	subw	a4,s9,a5
    800038ca:	413b06bb          	subw	a3,s6,s3
    800038ce:	8d3a                	mv	s10,a4
    800038d0:	fae6f2e3          	bgeu	a3,a4,80003874 <writei+0x4c>
    800038d4:	8d36                	mv	s10,a3
    800038d6:	bf79                	j	80003874 <writei+0x4c>
      brelse(bp);
    800038d8:	8526                	mv	a0,s1
    800038da:	dfaff0ef          	jal	80002ed4 <brelse>
  }

  if(off > ip->size)
    800038de:	04caa783          	lw	a5,76(s5)
    800038e2:	0327f963          	bgeu	a5,s2,80003914 <writei+0xec>
    ip->size = off;
    800038e6:	052aa623          	sw	s2,76(s5)
    800038ea:	64e6                	ld	s1,88(sp)
    800038ec:	7c02                	ld	s8,32(sp)
    800038ee:	6ce2                	ld	s9,24(sp)
    800038f0:	6d42                	ld	s10,16(sp)
    800038f2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800038f4:	8556                	mv	a0,s5
    800038f6:	b35ff0ef          	jal	8000342a <iupdate>

  return tot;
    800038fa:	854e                	mv	a0,s3
    800038fc:	69a6                	ld	s3,72(sp)
}
    800038fe:	70a6                	ld	ra,104(sp)
    80003900:	7406                	ld	s0,96(sp)
    80003902:	6946                	ld	s2,80(sp)
    80003904:	6a06                	ld	s4,64(sp)
    80003906:	7ae2                	ld	s5,56(sp)
    80003908:	7b42                	ld	s6,48(sp)
    8000390a:	7ba2                	ld	s7,40(sp)
    8000390c:	6165                	addi	sp,sp,112
    8000390e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003910:	89da                	mv	s3,s6
    80003912:	b7cd                	j	800038f4 <writei+0xcc>
    80003914:	64e6                	ld	s1,88(sp)
    80003916:	7c02                	ld	s8,32(sp)
    80003918:	6ce2                	ld	s9,24(sp)
    8000391a:	6d42                	ld	s10,16(sp)
    8000391c:	6da2                	ld	s11,8(sp)
    8000391e:	bfd9                	j	800038f4 <writei+0xcc>
    return -1;
    80003920:	557d                	li	a0,-1
}
    80003922:	8082                	ret
    return -1;
    80003924:	557d                	li	a0,-1
    80003926:	bfe1                	j	800038fe <writei+0xd6>
    return -1;
    80003928:	557d                	li	a0,-1
    8000392a:	bfd1                	j	800038fe <writei+0xd6>

000000008000392c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000392c:	1141                	addi	sp,sp,-16
    8000392e:	e406                	sd	ra,8(sp)
    80003930:	e022                	sd	s0,0(sp)
    80003932:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003934:	4639                	li	a2,14
    80003936:	c70fd0ef          	jal	80000da6 <strncmp>
}
    8000393a:	60a2                	ld	ra,8(sp)
    8000393c:	6402                	ld	s0,0(sp)
    8000393e:	0141                	addi	sp,sp,16
    80003940:	8082                	ret

0000000080003942 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003942:	711d                	addi	sp,sp,-96
    80003944:	ec86                	sd	ra,88(sp)
    80003946:	e8a2                	sd	s0,80(sp)
    80003948:	e4a6                	sd	s1,72(sp)
    8000394a:	e0ca                	sd	s2,64(sp)
    8000394c:	fc4e                	sd	s3,56(sp)
    8000394e:	f852                	sd	s4,48(sp)
    80003950:	f456                	sd	s5,40(sp)
    80003952:	f05a                	sd	s6,32(sp)
    80003954:	ec5e                	sd	s7,24(sp)
    80003956:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003958:	04451703          	lh	a4,68(a0)
    8000395c:	4785                	li	a5,1
    8000395e:	00f71f63          	bne	a4,a5,8000397c <dirlookup+0x3a>
    80003962:	892a                	mv	s2,a0
    80003964:	8aae                	mv	s5,a1
    80003966:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003968:	457c                	lw	a5,76(a0)
    8000396a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000396c:	fa040a13          	addi	s4,s0,-96
    80003970:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003972:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003976:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003978:	e39d                	bnez	a5,8000399e <dirlookup+0x5c>
    8000397a:	a8b9                	j	800039d8 <dirlookup+0x96>
    panic("dirlookup not DIR");
    8000397c:	00004517          	auipc	a0,0x4
    80003980:	c6c50513          	addi	a0,a0,-916 # 800075e8 <etext+0x5e8>
    80003984:	e1bfc0ef          	jal	8000079e <panic>
      panic("dirlookup read");
    80003988:	00004517          	auipc	a0,0x4
    8000398c:	c7850513          	addi	a0,a0,-904 # 80007600 <etext+0x600>
    80003990:	e0ffc0ef          	jal	8000079e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003994:	24c1                	addiw	s1,s1,16
    80003996:	04c92783          	lw	a5,76(s2)
    8000399a:	02f4fe63          	bgeu	s1,a5,800039d6 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000399e:	874e                	mv	a4,s3
    800039a0:	86a6                	mv	a3,s1
    800039a2:	8652                	mv	a2,s4
    800039a4:	4581                	li	a1,0
    800039a6:	854a                	mv	a0,s2
    800039a8:	d8fff0ef          	jal	80003736 <readi>
    800039ac:	fd351ee3          	bne	a0,s3,80003988 <dirlookup+0x46>
    if(de.inum == 0)
    800039b0:	fa045783          	lhu	a5,-96(s0)
    800039b4:	d3e5                	beqz	a5,80003994 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800039b6:	85da                	mv	a1,s6
    800039b8:	8556                	mv	a0,s5
    800039ba:	f73ff0ef          	jal	8000392c <namecmp>
    800039be:	f979                	bnez	a0,80003994 <dirlookup+0x52>
      if(poff)
    800039c0:	000b8463          	beqz	s7,800039c8 <dirlookup+0x86>
        *poff = off;
    800039c4:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800039c8:	fa045583          	lhu	a1,-96(s0)
    800039cc:	00092503          	lw	a0,0(s2)
    800039d0:	82fff0ef          	jal	800031fe <iget>
    800039d4:	a011                	j	800039d8 <dirlookup+0x96>
  return 0;
    800039d6:	4501                	li	a0,0
}
    800039d8:	60e6                	ld	ra,88(sp)
    800039da:	6446                	ld	s0,80(sp)
    800039dc:	64a6                	ld	s1,72(sp)
    800039de:	6906                	ld	s2,64(sp)
    800039e0:	79e2                	ld	s3,56(sp)
    800039e2:	7a42                	ld	s4,48(sp)
    800039e4:	7aa2                	ld	s5,40(sp)
    800039e6:	7b02                	ld	s6,32(sp)
    800039e8:	6be2                	ld	s7,24(sp)
    800039ea:	6125                	addi	sp,sp,96
    800039ec:	8082                	ret

00000000800039ee <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800039ee:	711d                	addi	sp,sp,-96
    800039f0:	ec86                	sd	ra,88(sp)
    800039f2:	e8a2                	sd	s0,80(sp)
    800039f4:	e4a6                	sd	s1,72(sp)
    800039f6:	e0ca                	sd	s2,64(sp)
    800039f8:	fc4e                	sd	s3,56(sp)
    800039fa:	f852                	sd	s4,48(sp)
    800039fc:	f456                	sd	s5,40(sp)
    800039fe:	f05a                	sd	s6,32(sp)
    80003a00:	ec5e                	sd	s7,24(sp)
    80003a02:	e862                	sd	s8,16(sp)
    80003a04:	e466                	sd	s9,8(sp)
    80003a06:	e06a                	sd	s10,0(sp)
    80003a08:	1080                	addi	s0,sp,96
    80003a0a:	84aa                	mv	s1,a0
    80003a0c:	8b2e                	mv	s6,a1
    80003a0e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a10:	00054703          	lbu	a4,0(a0)
    80003a14:	02f00793          	li	a5,47
    80003a18:	00f70f63          	beq	a4,a5,80003a36 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a1c:	ec1fd0ef          	jal	800018dc <myproc>
    80003a20:	15053503          	ld	a0,336(a0)
    80003a24:	a85ff0ef          	jal	800034a8 <idup>
    80003a28:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003a2a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003a2e:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003a30:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a32:	4b85                	li	s7,1
    80003a34:	a879                	j	80003ad2 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003a36:	4585                	li	a1,1
    80003a38:	852e                	mv	a0,a1
    80003a3a:	fc4ff0ef          	jal	800031fe <iget>
    80003a3e:	8a2a                	mv	s4,a0
    80003a40:	b7ed                	j	80003a2a <namex+0x3c>
      iunlockput(ip);
    80003a42:	8552                	mv	a0,s4
    80003a44:	ca5ff0ef          	jal	800036e8 <iunlockput>
      return 0;
    80003a48:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a4a:	8552                	mv	a0,s4
    80003a4c:	60e6                	ld	ra,88(sp)
    80003a4e:	6446                	ld	s0,80(sp)
    80003a50:	64a6                	ld	s1,72(sp)
    80003a52:	6906                	ld	s2,64(sp)
    80003a54:	79e2                	ld	s3,56(sp)
    80003a56:	7a42                	ld	s4,48(sp)
    80003a58:	7aa2                	ld	s5,40(sp)
    80003a5a:	7b02                	ld	s6,32(sp)
    80003a5c:	6be2                	ld	s7,24(sp)
    80003a5e:	6c42                	ld	s8,16(sp)
    80003a60:	6ca2                	ld	s9,8(sp)
    80003a62:	6d02                	ld	s10,0(sp)
    80003a64:	6125                	addi	sp,sp,96
    80003a66:	8082                	ret
      iunlock(ip);
    80003a68:	8552                	mv	a0,s4
    80003a6a:	b23ff0ef          	jal	8000358c <iunlock>
      return ip;
    80003a6e:	bff1                	j	80003a4a <namex+0x5c>
      iunlockput(ip);
    80003a70:	8552                	mv	a0,s4
    80003a72:	c77ff0ef          	jal	800036e8 <iunlockput>
      return 0;
    80003a76:	8a4e                	mv	s4,s3
    80003a78:	bfc9                	j	80003a4a <namex+0x5c>
  len = path - s;
    80003a7a:	40998633          	sub	a2,s3,s1
    80003a7e:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003a82:	09ac5063          	bge	s8,s10,80003b02 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003a86:	8666                	mv	a2,s9
    80003a88:	85a6                	mv	a1,s1
    80003a8a:	8556                	mv	a0,s5
    80003a8c:	aa6fd0ef          	jal	80000d32 <memmove>
    80003a90:	84ce                	mv	s1,s3
  while(*path == '/')
    80003a92:	0004c783          	lbu	a5,0(s1)
    80003a96:	01279763          	bne	a5,s2,80003aa4 <namex+0xb6>
    path++;
    80003a9a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a9c:	0004c783          	lbu	a5,0(s1)
    80003aa0:	ff278de3          	beq	a5,s2,80003a9a <namex+0xac>
    ilock(ip);
    80003aa4:	8552                	mv	a0,s4
    80003aa6:	a39ff0ef          	jal	800034de <ilock>
    if(ip->type != T_DIR){
    80003aaa:	044a1783          	lh	a5,68(s4)
    80003aae:	f9779ae3          	bne	a5,s7,80003a42 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003ab2:	000b0563          	beqz	s6,80003abc <namex+0xce>
    80003ab6:	0004c783          	lbu	a5,0(s1)
    80003aba:	d7dd                	beqz	a5,80003a68 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003abc:	4601                	li	a2,0
    80003abe:	85d6                	mv	a1,s5
    80003ac0:	8552                	mv	a0,s4
    80003ac2:	e81ff0ef          	jal	80003942 <dirlookup>
    80003ac6:	89aa                	mv	s3,a0
    80003ac8:	d545                	beqz	a0,80003a70 <namex+0x82>
    iunlockput(ip);
    80003aca:	8552                	mv	a0,s4
    80003acc:	c1dff0ef          	jal	800036e8 <iunlockput>
    ip = next;
    80003ad0:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003ad2:	0004c783          	lbu	a5,0(s1)
    80003ad6:	01279763          	bne	a5,s2,80003ae4 <namex+0xf6>
    path++;
    80003ada:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003adc:	0004c783          	lbu	a5,0(s1)
    80003ae0:	ff278de3          	beq	a5,s2,80003ada <namex+0xec>
  if(*path == 0)
    80003ae4:	cb8d                	beqz	a5,80003b16 <namex+0x128>
  while(*path != '/' && *path != 0)
    80003ae6:	0004c783          	lbu	a5,0(s1)
    80003aea:	89a6                	mv	s3,s1
  len = path - s;
    80003aec:	4d01                	li	s10,0
    80003aee:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003af0:	01278963          	beq	a5,s2,80003b02 <namex+0x114>
    80003af4:	d3d9                	beqz	a5,80003a7a <namex+0x8c>
    path++;
    80003af6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003af8:	0009c783          	lbu	a5,0(s3)
    80003afc:	ff279ce3          	bne	a5,s2,80003af4 <namex+0x106>
    80003b00:	bfad                	j	80003a7a <namex+0x8c>
    memmove(name, s, len);
    80003b02:	2601                	sext.w	a2,a2
    80003b04:	85a6                	mv	a1,s1
    80003b06:	8556                	mv	a0,s5
    80003b08:	a2afd0ef          	jal	80000d32 <memmove>
    name[len] = 0;
    80003b0c:	9d56                	add	s10,s10,s5
    80003b0e:	000d0023          	sb	zero,0(s10)
    80003b12:	84ce                	mv	s1,s3
    80003b14:	bfbd                	j	80003a92 <namex+0xa4>
  if(nameiparent){
    80003b16:	f20b0ae3          	beqz	s6,80003a4a <namex+0x5c>
    iput(ip);
    80003b1a:	8552                	mv	a0,s4
    80003b1c:	b45ff0ef          	jal	80003660 <iput>
    return 0;
    80003b20:	4a01                	li	s4,0
    80003b22:	b725                	j	80003a4a <namex+0x5c>

0000000080003b24 <dirlink>:
{
    80003b24:	715d                	addi	sp,sp,-80
    80003b26:	e486                	sd	ra,72(sp)
    80003b28:	e0a2                	sd	s0,64(sp)
    80003b2a:	f84a                	sd	s2,48(sp)
    80003b2c:	ec56                	sd	s5,24(sp)
    80003b2e:	e85a                	sd	s6,16(sp)
    80003b30:	0880                	addi	s0,sp,80
    80003b32:	892a                	mv	s2,a0
    80003b34:	8aae                	mv	s5,a1
    80003b36:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b38:	4601                	li	a2,0
    80003b3a:	e09ff0ef          	jal	80003942 <dirlookup>
    80003b3e:	ed1d                	bnez	a0,80003b7c <dirlink+0x58>
    80003b40:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b42:	04c92483          	lw	s1,76(s2)
    80003b46:	c4b9                	beqz	s1,80003b94 <dirlink+0x70>
    80003b48:	f44e                	sd	s3,40(sp)
    80003b4a:	f052                	sd	s4,32(sp)
    80003b4c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b4e:	fb040a13          	addi	s4,s0,-80
    80003b52:	49c1                	li	s3,16
    80003b54:	874e                	mv	a4,s3
    80003b56:	86a6                	mv	a3,s1
    80003b58:	8652                	mv	a2,s4
    80003b5a:	4581                	li	a1,0
    80003b5c:	854a                	mv	a0,s2
    80003b5e:	bd9ff0ef          	jal	80003736 <readi>
    80003b62:	03351163          	bne	a0,s3,80003b84 <dirlink+0x60>
    if(de.inum == 0)
    80003b66:	fb045783          	lhu	a5,-80(s0)
    80003b6a:	c39d                	beqz	a5,80003b90 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b6c:	24c1                	addiw	s1,s1,16
    80003b6e:	04c92783          	lw	a5,76(s2)
    80003b72:	fef4e1e3          	bltu	s1,a5,80003b54 <dirlink+0x30>
    80003b76:	79a2                	ld	s3,40(sp)
    80003b78:	7a02                	ld	s4,32(sp)
    80003b7a:	a829                	j	80003b94 <dirlink+0x70>
    iput(ip);
    80003b7c:	ae5ff0ef          	jal	80003660 <iput>
    return -1;
    80003b80:	557d                	li	a0,-1
    80003b82:	a83d                	j	80003bc0 <dirlink+0x9c>
      panic("dirlink read");
    80003b84:	00004517          	auipc	a0,0x4
    80003b88:	a8c50513          	addi	a0,a0,-1396 # 80007610 <etext+0x610>
    80003b8c:	c13fc0ef          	jal	8000079e <panic>
    80003b90:	79a2                	ld	s3,40(sp)
    80003b92:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003b94:	4639                	li	a2,14
    80003b96:	85d6                	mv	a1,s5
    80003b98:	fb240513          	addi	a0,s0,-78
    80003b9c:	a44fd0ef          	jal	80000de0 <strncpy>
  de.inum = inum;
    80003ba0:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ba4:	4741                	li	a4,16
    80003ba6:	86a6                	mv	a3,s1
    80003ba8:	fb040613          	addi	a2,s0,-80
    80003bac:	4581                	li	a1,0
    80003bae:	854a                	mv	a0,s2
    80003bb0:	c79ff0ef          	jal	80003828 <writei>
    80003bb4:	1541                	addi	a0,a0,-16
    80003bb6:	00a03533          	snez	a0,a0
    80003bba:	40a0053b          	negw	a0,a0
    80003bbe:	74e2                	ld	s1,56(sp)
}
    80003bc0:	60a6                	ld	ra,72(sp)
    80003bc2:	6406                	ld	s0,64(sp)
    80003bc4:	7942                	ld	s2,48(sp)
    80003bc6:	6ae2                	ld	s5,24(sp)
    80003bc8:	6b42                	ld	s6,16(sp)
    80003bca:	6161                	addi	sp,sp,80
    80003bcc:	8082                	ret

0000000080003bce <namei>:

struct inode*
namei(char *path)
{
    80003bce:	1101                	addi	sp,sp,-32
    80003bd0:	ec06                	sd	ra,24(sp)
    80003bd2:	e822                	sd	s0,16(sp)
    80003bd4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003bd6:	fe040613          	addi	a2,s0,-32
    80003bda:	4581                	li	a1,0
    80003bdc:	e13ff0ef          	jal	800039ee <namex>
}
    80003be0:	60e2                	ld	ra,24(sp)
    80003be2:	6442                	ld	s0,16(sp)
    80003be4:	6105                	addi	sp,sp,32
    80003be6:	8082                	ret

0000000080003be8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003be8:	1141                	addi	sp,sp,-16
    80003bea:	e406                	sd	ra,8(sp)
    80003bec:	e022                	sd	s0,0(sp)
    80003bee:	0800                	addi	s0,sp,16
    80003bf0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003bf2:	4585                	li	a1,1
    80003bf4:	dfbff0ef          	jal	800039ee <namex>
}
    80003bf8:	60a2                	ld	ra,8(sp)
    80003bfa:	6402                	ld	s0,0(sp)
    80003bfc:	0141                	addi	sp,sp,16
    80003bfe:	8082                	ret

0000000080003c00 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c00:	1101                	addi	sp,sp,-32
    80003c02:	ec06                	sd	ra,24(sp)
    80003c04:	e822                	sd	s0,16(sp)
    80003c06:	e426                	sd	s1,8(sp)
    80003c08:	e04a                	sd	s2,0(sp)
    80003c0a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c0c:	00026917          	auipc	s2,0x26
    80003c10:	b9490913          	addi	s2,s2,-1132 # 800297a0 <log>
    80003c14:	01892583          	lw	a1,24(s2)
    80003c18:	02892503          	lw	a0,40(s2)
    80003c1c:	9b0ff0ef          	jal	80002dcc <bread>
    80003c20:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c22:	02c92603          	lw	a2,44(s2)
    80003c26:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c28:	00c05f63          	blez	a2,80003c46 <write_head+0x46>
    80003c2c:	00026717          	auipc	a4,0x26
    80003c30:	ba470713          	addi	a4,a4,-1116 # 800297d0 <log+0x30>
    80003c34:	87aa                	mv	a5,a0
    80003c36:	060a                	slli	a2,a2,0x2
    80003c38:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c3a:	4314                	lw	a3,0(a4)
    80003c3c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c3e:	0711                	addi	a4,a4,4
    80003c40:	0791                	addi	a5,a5,4
    80003c42:	fec79ce3          	bne	a5,a2,80003c3a <write_head+0x3a>
  }
  bwrite(buf);
    80003c46:	8526                	mv	a0,s1
    80003c48:	a5aff0ef          	jal	80002ea2 <bwrite>
  brelse(buf);
    80003c4c:	8526                	mv	a0,s1
    80003c4e:	a86ff0ef          	jal	80002ed4 <brelse>
}
    80003c52:	60e2                	ld	ra,24(sp)
    80003c54:	6442                	ld	s0,16(sp)
    80003c56:	64a2                	ld	s1,8(sp)
    80003c58:	6902                	ld	s2,0(sp)
    80003c5a:	6105                	addi	sp,sp,32
    80003c5c:	8082                	ret

0000000080003c5e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c5e:	00026797          	auipc	a5,0x26
    80003c62:	b6e7a783          	lw	a5,-1170(a5) # 800297cc <log+0x2c>
    80003c66:	0af05263          	blez	a5,80003d0a <install_trans+0xac>
{
    80003c6a:	715d                	addi	sp,sp,-80
    80003c6c:	e486                	sd	ra,72(sp)
    80003c6e:	e0a2                	sd	s0,64(sp)
    80003c70:	fc26                	sd	s1,56(sp)
    80003c72:	f84a                	sd	s2,48(sp)
    80003c74:	f44e                	sd	s3,40(sp)
    80003c76:	f052                	sd	s4,32(sp)
    80003c78:	ec56                	sd	s5,24(sp)
    80003c7a:	e85a                	sd	s6,16(sp)
    80003c7c:	e45e                	sd	s7,8(sp)
    80003c7e:	0880                	addi	s0,sp,80
    80003c80:	8b2a                	mv	s6,a0
    80003c82:	00026a97          	auipc	s5,0x26
    80003c86:	b4ea8a93          	addi	s5,s5,-1202 # 800297d0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c8a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c8c:	00026997          	auipc	s3,0x26
    80003c90:	b1498993          	addi	s3,s3,-1260 # 800297a0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c94:	40000b93          	li	s7,1024
    80003c98:	a829                	j	80003cb2 <install_trans+0x54>
    brelse(lbuf);
    80003c9a:	854a                	mv	a0,s2
    80003c9c:	a38ff0ef          	jal	80002ed4 <brelse>
    brelse(dbuf);
    80003ca0:	8526                	mv	a0,s1
    80003ca2:	a32ff0ef          	jal	80002ed4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ca6:	2a05                	addiw	s4,s4,1
    80003ca8:	0a91                	addi	s5,s5,4
    80003caa:	02c9a783          	lw	a5,44(s3)
    80003cae:	04fa5363          	bge	s4,a5,80003cf4 <install_trans+0x96>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003cb2:	0189a583          	lw	a1,24(s3)
    80003cb6:	014585bb          	addw	a1,a1,s4
    80003cba:	2585                	addiw	a1,a1,1
    80003cbc:	0289a503          	lw	a0,40(s3)
    80003cc0:	90cff0ef          	jal	80002dcc <bread>
    80003cc4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003cc6:	000aa583          	lw	a1,0(s5)
    80003cca:	0289a503          	lw	a0,40(s3)
    80003cce:	8feff0ef          	jal	80002dcc <bread>
    80003cd2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003cd4:	865e                	mv	a2,s7
    80003cd6:	05890593          	addi	a1,s2,88
    80003cda:	05850513          	addi	a0,a0,88
    80003cde:	854fd0ef          	jal	80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ce2:	8526                	mv	a0,s1
    80003ce4:	9beff0ef          	jal	80002ea2 <bwrite>
    if(recovering == 0)
    80003ce8:	fa0b19e3          	bnez	s6,80003c9a <install_trans+0x3c>
      bunpin(dbuf);
    80003cec:	8526                	mv	a0,s1
    80003cee:	a9eff0ef          	jal	80002f8c <bunpin>
    80003cf2:	b765                	j	80003c9a <install_trans+0x3c>
}
    80003cf4:	60a6                	ld	ra,72(sp)
    80003cf6:	6406                	ld	s0,64(sp)
    80003cf8:	74e2                	ld	s1,56(sp)
    80003cfa:	7942                	ld	s2,48(sp)
    80003cfc:	79a2                	ld	s3,40(sp)
    80003cfe:	7a02                	ld	s4,32(sp)
    80003d00:	6ae2                	ld	s5,24(sp)
    80003d02:	6b42                	ld	s6,16(sp)
    80003d04:	6ba2                	ld	s7,8(sp)
    80003d06:	6161                	addi	sp,sp,80
    80003d08:	8082                	ret
    80003d0a:	8082                	ret

0000000080003d0c <initlog>:
{
    80003d0c:	7179                	addi	sp,sp,-48
    80003d0e:	f406                	sd	ra,40(sp)
    80003d10:	f022                	sd	s0,32(sp)
    80003d12:	ec26                	sd	s1,24(sp)
    80003d14:	e84a                	sd	s2,16(sp)
    80003d16:	e44e                	sd	s3,8(sp)
    80003d18:	1800                	addi	s0,sp,48
    80003d1a:	892a                	mv	s2,a0
    80003d1c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d1e:	00026497          	auipc	s1,0x26
    80003d22:	a8248493          	addi	s1,s1,-1406 # 800297a0 <log>
    80003d26:	00004597          	auipc	a1,0x4
    80003d2a:	8fa58593          	addi	a1,a1,-1798 # 80007620 <etext+0x620>
    80003d2e:	8526                	mv	a0,s1
    80003d30:	e4bfc0ef          	jal	80000b7a <initlock>
  log.start = sb->logstart;
    80003d34:	0149a583          	lw	a1,20(s3)
    80003d38:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003d3a:	0109a783          	lw	a5,16(s3)
    80003d3e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003d40:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003d44:	854a                	mv	a0,s2
    80003d46:	886ff0ef          	jal	80002dcc <bread>
  log.lh.n = lh->n;
    80003d4a:	4d30                	lw	a2,88(a0)
    80003d4c:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003d4e:	00c05f63          	blez	a2,80003d6c <initlog+0x60>
    80003d52:	87aa                	mv	a5,a0
    80003d54:	00026717          	auipc	a4,0x26
    80003d58:	a7c70713          	addi	a4,a4,-1412 # 800297d0 <log+0x30>
    80003d5c:	060a                	slli	a2,a2,0x2
    80003d5e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003d60:	4ff4                	lw	a3,92(a5)
    80003d62:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d64:	0791                	addi	a5,a5,4
    80003d66:	0711                	addi	a4,a4,4
    80003d68:	fec79ce3          	bne	a5,a2,80003d60 <initlog+0x54>
  brelse(buf);
    80003d6c:	968ff0ef          	jal	80002ed4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d70:	4505                	li	a0,1
    80003d72:	eedff0ef          	jal	80003c5e <install_trans>
  log.lh.n = 0;
    80003d76:	00026797          	auipc	a5,0x26
    80003d7a:	a407ab23          	sw	zero,-1450(a5) # 800297cc <log+0x2c>
  write_head(); // clear the log
    80003d7e:	e83ff0ef          	jal	80003c00 <write_head>
}
    80003d82:	70a2                	ld	ra,40(sp)
    80003d84:	7402                	ld	s0,32(sp)
    80003d86:	64e2                	ld	s1,24(sp)
    80003d88:	6942                	ld	s2,16(sp)
    80003d8a:	69a2                	ld	s3,8(sp)
    80003d8c:	6145                	addi	sp,sp,48
    80003d8e:	8082                	ret

0000000080003d90 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d90:	1101                	addi	sp,sp,-32
    80003d92:	ec06                	sd	ra,24(sp)
    80003d94:	e822                	sd	s0,16(sp)
    80003d96:	e426                	sd	s1,8(sp)
    80003d98:	e04a                	sd	s2,0(sp)
    80003d9a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d9c:	00026517          	auipc	a0,0x26
    80003da0:	a0450513          	addi	a0,a0,-1532 # 800297a0 <log>
    80003da4:	e5bfc0ef          	jal	80000bfe <acquire>
  while(1){
    if(log.committing){
    80003da8:	00026497          	auipc	s1,0x26
    80003dac:	9f848493          	addi	s1,s1,-1544 # 800297a0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003db0:	4979                	li	s2,30
    80003db2:	a029                	j	80003dbc <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003db4:	85a6                	mv	a1,s1
    80003db6:	8526                	mv	a0,s1
    80003db8:	a4afe0ef          	jal	80002002 <sleep>
    if(log.committing){
    80003dbc:	50dc                	lw	a5,36(s1)
    80003dbe:	fbfd                	bnez	a5,80003db4 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003dc0:	5098                	lw	a4,32(s1)
    80003dc2:	2705                	addiw	a4,a4,1
    80003dc4:	0027179b          	slliw	a5,a4,0x2
    80003dc8:	9fb9                	addw	a5,a5,a4
    80003dca:	0017979b          	slliw	a5,a5,0x1
    80003dce:	54d4                	lw	a3,44(s1)
    80003dd0:	9fb5                	addw	a5,a5,a3
    80003dd2:	00f95763          	bge	s2,a5,80003de0 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003dd6:	85a6                	mv	a1,s1
    80003dd8:	8526                	mv	a0,s1
    80003dda:	a28fe0ef          	jal	80002002 <sleep>
    80003dde:	bff9                	j	80003dbc <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003de0:	00026517          	auipc	a0,0x26
    80003de4:	9c050513          	addi	a0,a0,-1600 # 800297a0 <log>
    80003de8:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003dea:	ea9fc0ef          	jal	80000c92 <release>
      break;
    }
  }
}
    80003dee:	60e2                	ld	ra,24(sp)
    80003df0:	6442                	ld	s0,16(sp)
    80003df2:	64a2                	ld	s1,8(sp)
    80003df4:	6902                	ld	s2,0(sp)
    80003df6:	6105                	addi	sp,sp,32
    80003df8:	8082                	ret

0000000080003dfa <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003dfa:	7139                	addi	sp,sp,-64
    80003dfc:	fc06                	sd	ra,56(sp)
    80003dfe:	f822                	sd	s0,48(sp)
    80003e00:	f426                	sd	s1,40(sp)
    80003e02:	f04a                	sd	s2,32(sp)
    80003e04:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e06:	00026497          	auipc	s1,0x26
    80003e0a:	99a48493          	addi	s1,s1,-1638 # 800297a0 <log>
    80003e0e:	8526                	mv	a0,s1
    80003e10:	deffc0ef          	jal	80000bfe <acquire>
  log.outstanding -= 1;
    80003e14:	509c                	lw	a5,32(s1)
    80003e16:	37fd                	addiw	a5,a5,-1
    80003e18:	893e                	mv	s2,a5
    80003e1a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003e1c:	50dc                	lw	a5,36(s1)
    80003e1e:	ef9d                	bnez	a5,80003e5c <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    80003e20:	04091863          	bnez	s2,80003e70 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003e24:	00026497          	auipc	s1,0x26
    80003e28:	97c48493          	addi	s1,s1,-1668 # 800297a0 <log>
    80003e2c:	4785                	li	a5,1
    80003e2e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e30:	8526                	mv	a0,s1
    80003e32:	e61fc0ef          	jal	80000c92 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e36:	54dc                	lw	a5,44(s1)
    80003e38:	04f04c63          	bgtz	a5,80003e90 <end_op+0x96>
    acquire(&log.lock);
    80003e3c:	00026497          	auipc	s1,0x26
    80003e40:	96448493          	addi	s1,s1,-1692 # 800297a0 <log>
    80003e44:	8526                	mv	a0,s1
    80003e46:	db9fc0ef          	jal	80000bfe <acquire>
    log.committing = 0;
    80003e4a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003e4e:	8526                	mv	a0,s1
    80003e50:	9fefe0ef          	jal	8000204e <wakeup>
    release(&log.lock);
    80003e54:	8526                	mv	a0,s1
    80003e56:	e3dfc0ef          	jal	80000c92 <release>
}
    80003e5a:	a02d                	j	80003e84 <end_op+0x8a>
    80003e5c:	ec4e                	sd	s3,24(sp)
    80003e5e:	e852                	sd	s4,16(sp)
    80003e60:	e456                	sd	s5,8(sp)
    80003e62:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80003e64:	00003517          	auipc	a0,0x3
    80003e68:	7c450513          	addi	a0,a0,1988 # 80007628 <etext+0x628>
    80003e6c:	933fc0ef          	jal	8000079e <panic>
    wakeup(&log);
    80003e70:	00026497          	auipc	s1,0x26
    80003e74:	93048493          	addi	s1,s1,-1744 # 800297a0 <log>
    80003e78:	8526                	mv	a0,s1
    80003e7a:	9d4fe0ef          	jal	8000204e <wakeup>
  release(&log.lock);
    80003e7e:	8526                	mv	a0,s1
    80003e80:	e13fc0ef          	jal	80000c92 <release>
}
    80003e84:	70e2                	ld	ra,56(sp)
    80003e86:	7442                	ld	s0,48(sp)
    80003e88:	74a2                	ld	s1,40(sp)
    80003e8a:	7902                	ld	s2,32(sp)
    80003e8c:	6121                	addi	sp,sp,64
    80003e8e:	8082                	ret
    80003e90:	ec4e                	sd	s3,24(sp)
    80003e92:	e852                	sd	s4,16(sp)
    80003e94:	e456                	sd	s5,8(sp)
    80003e96:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e98:	00026a97          	auipc	s5,0x26
    80003e9c:	938a8a93          	addi	s5,s5,-1736 # 800297d0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003ea0:	00026a17          	auipc	s4,0x26
    80003ea4:	900a0a13          	addi	s4,s4,-1792 # 800297a0 <log>
    memmove(to->data, from->data, BSIZE);
    80003ea8:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003eac:	018a2583          	lw	a1,24(s4)
    80003eb0:	012585bb          	addw	a1,a1,s2
    80003eb4:	2585                	addiw	a1,a1,1
    80003eb6:	028a2503          	lw	a0,40(s4)
    80003eba:	f13fe0ef          	jal	80002dcc <bread>
    80003ebe:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003ec0:	000aa583          	lw	a1,0(s5)
    80003ec4:	028a2503          	lw	a0,40(s4)
    80003ec8:	f05fe0ef          	jal	80002dcc <bread>
    80003ecc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ece:	865a                	mv	a2,s6
    80003ed0:	05850593          	addi	a1,a0,88
    80003ed4:	05848513          	addi	a0,s1,88
    80003ed8:	e5bfc0ef          	jal	80000d32 <memmove>
    bwrite(to);  // write the log
    80003edc:	8526                	mv	a0,s1
    80003ede:	fc5fe0ef          	jal	80002ea2 <bwrite>
    brelse(from);
    80003ee2:	854e                	mv	a0,s3
    80003ee4:	ff1fe0ef          	jal	80002ed4 <brelse>
    brelse(to);
    80003ee8:	8526                	mv	a0,s1
    80003eea:	febfe0ef          	jal	80002ed4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eee:	2905                	addiw	s2,s2,1
    80003ef0:	0a91                	addi	s5,s5,4
    80003ef2:	02ca2783          	lw	a5,44(s4)
    80003ef6:	faf94be3          	blt	s2,a5,80003eac <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003efa:	d07ff0ef          	jal	80003c00 <write_head>
    install_trans(0); // Now install writes to home locations
    80003efe:	4501                	li	a0,0
    80003f00:	d5fff0ef          	jal	80003c5e <install_trans>
    log.lh.n = 0;
    80003f04:	00026797          	auipc	a5,0x26
    80003f08:	8c07a423          	sw	zero,-1848(a5) # 800297cc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003f0c:	cf5ff0ef          	jal	80003c00 <write_head>
    80003f10:	69e2                	ld	s3,24(sp)
    80003f12:	6a42                	ld	s4,16(sp)
    80003f14:	6aa2                	ld	s5,8(sp)
    80003f16:	6b02                	ld	s6,0(sp)
    80003f18:	b715                	j	80003e3c <end_op+0x42>

0000000080003f1a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f1a:	1101                	addi	sp,sp,-32
    80003f1c:	ec06                	sd	ra,24(sp)
    80003f1e:	e822                	sd	s0,16(sp)
    80003f20:	e426                	sd	s1,8(sp)
    80003f22:	e04a                	sd	s2,0(sp)
    80003f24:	1000                	addi	s0,sp,32
    80003f26:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f28:	00026917          	auipc	s2,0x26
    80003f2c:	87890913          	addi	s2,s2,-1928 # 800297a0 <log>
    80003f30:	854a                	mv	a0,s2
    80003f32:	ccdfc0ef          	jal	80000bfe <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003f36:	02c92603          	lw	a2,44(s2)
    80003f3a:	47f5                	li	a5,29
    80003f3c:	06c7c363          	blt	a5,a2,80003fa2 <log_write+0x88>
    80003f40:	00026797          	auipc	a5,0x26
    80003f44:	87c7a783          	lw	a5,-1924(a5) # 800297bc <log+0x1c>
    80003f48:	37fd                	addiw	a5,a5,-1
    80003f4a:	04f65c63          	bge	a2,a5,80003fa2 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f4e:	00026797          	auipc	a5,0x26
    80003f52:	8727a783          	lw	a5,-1934(a5) # 800297c0 <log+0x20>
    80003f56:	04f05c63          	blez	a5,80003fae <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f5a:	4781                	li	a5,0
    80003f5c:	04c05f63          	blez	a2,80003fba <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f60:	44cc                	lw	a1,12(s1)
    80003f62:	00026717          	auipc	a4,0x26
    80003f66:	86e70713          	addi	a4,a4,-1938 # 800297d0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003f6a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f6c:	4314                	lw	a3,0(a4)
    80003f6e:	04b68663          	beq	a3,a1,80003fba <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003f72:	2785                	addiw	a5,a5,1
    80003f74:	0711                	addi	a4,a4,4
    80003f76:	fef61be3          	bne	a2,a5,80003f6c <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f7a:	0621                	addi	a2,a2,8
    80003f7c:	060a                	slli	a2,a2,0x2
    80003f7e:	00026797          	auipc	a5,0x26
    80003f82:	82278793          	addi	a5,a5,-2014 # 800297a0 <log>
    80003f86:	97b2                	add	a5,a5,a2
    80003f88:	44d8                	lw	a4,12(s1)
    80003f8a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003f8c:	8526                	mv	a0,s1
    80003f8e:	fcbfe0ef          	jal	80002f58 <bpin>
    log.lh.n++;
    80003f92:	00026717          	auipc	a4,0x26
    80003f96:	80e70713          	addi	a4,a4,-2034 # 800297a0 <log>
    80003f9a:	575c                	lw	a5,44(a4)
    80003f9c:	2785                	addiw	a5,a5,1
    80003f9e:	d75c                	sw	a5,44(a4)
    80003fa0:	a80d                	j	80003fd2 <log_write+0xb8>
    panic("too big a transaction");
    80003fa2:	00003517          	auipc	a0,0x3
    80003fa6:	69650513          	addi	a0,a0,1686 # 80007638 <etext+0x638>
    80003faa:	ff4fc0ef          	jal	8000079e <panic>
    panic("log_write outside of trans");
    80003fae:	00003517          	auipc	a0,0x3
    80003fb2:	6a250513          	addi	a0,a0,1698 # 80007650 <etext+0x650>
    80003fb6:	fe8fc0ef          	jal	8000079e <panic>
  log.lh.block[i] = b->blockno;
    80003fba:	00878693          	addi	a3,a5,8
    80003fbe:	068a                	slli	a3,a3,0x2
    80003fc0:	00025717          	auipc	a4,0x25
    80003fc4:	7e070713          	addi	a4,a4,2016 # 800297a0 <log>
    80003fc8:	9736                	add	a4,a4,a3
    80003fca:	44d4                	lw	a3,12(s1)
    80003fcc:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003fce:	faf60fe3          	beq	a2,a5,80003f8c <log_write+0x72>
  }
  release(&log.lock);
    80003fd2:	00025517          	auipc	a0,0x25
    80003fd6:	7ce50513          	addi	a0,a0,1998 # 800297a0 <log>
    80003fda:	cb9fc0ef          	jal	80000c92 <release>
}
    80003fde:	60e2                	ld	ra,24(sp)
    80003fe0:	6442                	ld	s0,16(sp)
    80003fe2:	64a2                	ld	s1,8(sp)
    80003fe4:	6902                	ld	s2,0(sp)
    80003fe6:	6105                	addi	sp,sp,32
    80003fe8:	8082                	ret

0000000080003fea <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003fea:	1101                	addi	sp,sp,-32
    80003fec:	ec06                	sd	ra,24(sp)
    80003fee:	e822                	sd	s0,16(sp)
    80003ff0:	e426                	sd	s1,8(sp)
    80003ff2:	e04a                	sd	s2,0(sp)
    80003ff4:	1000                	addi	s0,sp,32
    80003ff6:	84aa                	mv	s1,a0
    80003ff8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ffa:	00003597          	auipc	a1,0x3
    80003ffe:	67658593          	addi	a1,a1,1654 # 80007670 <etext+0x670>
    80004002:	0521                	addi	a0,a0,8
    80004004:	b77fc0ef          	jal	80000b7a <initlock>
  lk->name = name;
    80004008:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000400c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004010:	0204a423          	sw	zero,40(s1)
}
    80004014:	60e2                	ld	ra,24(sp)
    80004016:	6442                	ld	s0,16(sp)
    80004018:	64a2                	ld	s1,8(sp)
    8000401a:	6902                	ld	s2,0(sp)
    8000401c:	6105                	addi	sp,sp,32
    8000401e:	8082                	ret

0000000080004020 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004020:	1101                	addi	sp,sp,-32
    80004022:	ec06                	sd	ra,24(sp)
    80004024:	e822                	sd	s0,16(sp)
    80004026:	e426                	sd	s1,8(sp)
    80004028:	e04a                	sd	s2,0(sp)
    8000402a:	1000                	addi	s0,sp,32
    8000402c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000402e:	00850913          	addi	s2,a0,8
    80004032:	854a                	mv	a0,s2
    80004034:	bcbfc0ef          	jal	80000bfe <acquire>
  while (lk->locked) {
    80004038:	409c                	lw	a5,0(s1)
    8000403a:	c799                	beqz	a5,80004048 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000403c:	85ca                	mv	a1,s2
    8000403e:	8526                	mv	a0,s1
    80004040:	fc3fd0ef          	jal	80002002 <sleep>
  while (lk->locked) {
    80004044:	409c                	lw	a5,0(s1)
    80004046:	fbfd                	bnez	a5,8000403c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004048:	4785                	li	a5,1
    8000404a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000404c:	891fd0ef          	jal	800018dc <myproc>
    80004050:	591c                	lw	a5,48(a0)
    80004052:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004054:	854a                	mv	a0,s2
    80004056:	c3dfc0ef          	jal	80000c92 <release>
}
    8000405a:	60e2                	ld	ra,24(sp)
    8000405c:	6442                	ld	s0,16(sp)
    8000405e:	64a2                	ld	s1,8(sp)
    80004060:	6902                	ld	s2,0(sp)
    80004062:	6105                	addi	sp,sp,32
    80004064:	8082                	ret

0000000080004066 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004066:	1101                	addi	sp,sp,-32
    80004068:	ec06                	sd	ra,24(sp)
    8000406a:	e822                	sd	s0,16(sp)
    8000406c:	e426                	sd	s1,8(sp)
    8000406e:	e04a                	sd	s2,0(sp)
    80004070:	1000                	addi	s0,sp,32
    80004072:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004074:	00850913          	addi	s2,a0,8
    80004078:	854a                	mv	a0,s2
    8000407a:	b85fc0ef          	jal	80000bfe <acquire>
  lk->locked = 0;
    8000407e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004082:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004086:	8526                	mv	a0,s1
    80004088:	fc7fd0ef          	jal	8000204e <wakeup>
  release(&lk->lk);
    8000408c:	854a                	mv	a0,s2
    8000408e:	c05fc0ef          	jal	80000c92 <release>
}
    80004092:	60e2                	ld	ra,24(sp)
    80004094:	6442                	ld	s0,16(sp)
    80004096:	64a2                	ld	s1,8(sp)
    80004098:	6902                	ld	s2,0(sp)
    8000409a:	6105                	addi	sp,sp,32
    8000409c:	8082                	ret

000000008000409e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000409e:	7179                	addi	sp,sp,-48
    800040a0:	f406                	sd	ra,40(sp)
    800040a2:	f022                	sd	s0,32(sp)
    800040a4:	ec26                	sd	s1,24(sp)
    800040a6:	e84a                	sd	s2,16(sp)
    800040a8:	1800                	addi	s0,sp,48
    800040aa:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800040ac:	00850913          	addi	s2,a0,8
    800040b0:	854a                	mv	a0,s2
    800040b2:	b4dfc0ef          	jal	80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040b6:	409c                	lw	a5,0(s1)
    800040b8:	ef81                	bnez	a5,800040d0 <holdingsleep+0x32>
    800040ba:	4481                	li	s1,0
  release(&lk->lk);
    800040bc:	854a                	mv	a0,s2
    800040be:	bd5fc0ef          	jal	80000c92 <release>
  return r;
}
    800040c2:	8526                	mv	a0,s1
    800040c4:	70a2                	ld	ra,40(sp)
    800040c6:	7402                	ld	s0,32(sp)
    800040c8:	64e2                	ld	s1,24(sp)
    800040ca:	6942                	ld	s2,16(sp)
    800040cc:	6145                	addi	sp,sp,48
    800040ce:	8082                	ret
    800040d0:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800040d2:	0284a983          	lw	s3,40(s1)
    800040d6:	807fd0ef          	jal	800018dc <myproc>
    800040da:	5904                	lw	s1,48(a0)
    800040dc:	413484b3          	sub	s1,s1,s3
    800040e0:	0014b493          	seqz	s1,s1
    800040e4:	69a2                	ld	s3,8(sp)
    800040e6:	bfd9                	j	800040bc <holdingsleep+0x1e>

00000000800040e8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800040e8:	1141                	addi	sp,sp,-16
    800040ea:	e406                	sd	ra,8(sp)
    800040ec:	e022                	sd	s0,0(sp)
    800040ee:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800040f0:	00003597          	auipc	a1,0x3
    800040f4:	59058593          	addi	a1,a1,1424 # 80007680 <etext+0x680>
    800040f8:	00025517          	auipc	a0,0x25
    800040fc:	7f050513          	addi	a0,a0,2032 # 800298e8 <ftable>
    80004100:	a7bfc0ef          	jal	80000b7a <initlock>
}
    80004104:	60a2                	ld	ra,8(sp)
    80004106:	6402                	ld	s0,0(sp)
    80004108:	0141                	addi	sp,sp,16
    8000410a:	8082                	ret

000000008000410c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000410c:	1101                	addi	sp,sp,-32
    8000410e:	ec06                	sd	ra,24(sp)
    80004110:	e822                	sd	s0,16(sp)
    80004112:	e426                	sd	s1,8(sp)
    80004114:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004116:	00025517          	auipc	a0,0x25
    8000411a:	7d250513          	addi	a0,a0,2002 # 800298e8 <ftable>
    8000411e:	ae1fc0ef          	jal	80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004122:	00025497          	auipc	s1,0x25
    80004126:	7de48493          	addi	s1,s1,2014 # 80029900 <ftable+0x18>
    8000412a:	00026717          	auipc	a4,0x26
    8000412e:	77670713          	addi	a4,a4,1910 # 8002a8a0 <disk>
    if(f->ref == 0){
    80004132:	40dc                	lw	a5,4(s1)
    80004134:	cf89                	beqz	a5,8000414e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004136:	02848493          	addi	s1,s1,40
    8000413a:	fee49ce3          	bne	s1,a4,80004132 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000413e:	00025517          	auipc	a0,0x25
    80004142:	7aa50513          	addi	a0,a0,1962 # 800298e8 <ftable>
    80004146:	b4dfc0ef          	jal	80000c92 <release>
  return 0;
    8000414a:	4481                	li	s1,0
    8000414c:	a809                	j	8000415e <filealloc+0x52>
      f->ref = 1;
    8000414e:	4785                	li	a5,1
    80004150:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004152:	00025517          	auipc	a0,0x25
    80004156:	79650513          	addi	a0,a0,1942 # 800298e8 <ftable>
    8000415a:	b39fc0ef          	jal	80000c92 <release>
}
    8000415e:	8526                	mv	a0,s1
    80004160:	60e2                	ld	ra,24(sp)
    80004162:	6442                	ld	s0,16(sp)
    80004164:	64a2                	ld	s1,8(sp)
    80004166:	6105                	addi	sp,sp,32
    80004168:	8082                	ret

000000008000416a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000416a:	1101                	addi	sp,sp,-32
    8000416c:	ec06                	sd	ra,24(sp)
    8000416e:	e822                	sd	s0,16(sp)
    80004170:	e426                	sd	s1,8(sp)
    80004172:	1000                	addi	s0,sp,32
    80004174:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004176:	00025517          	auipc	a0,0x25
    8000417a:	77250513          	addi	a0,a0,1906 # 800298e8 <ftable>
    8000417e:	a81fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80004182:	40dc                	lw	a5,4(s1)
    80004184:	02f05063          	blez	a5,800041a4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004188:	2785                	addiw	a5,a5,1
    8000418a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000418c:	00025517          	auipc	a0,0x25
    80004190:	75c50513          	addi	a0,a0,1884 # 800298e8 <ftable>
    80004194:	afffc0ef          	jal	80000c92 <release>
  return f;
}
    80004198:	8526                	mv	a0,s1
    8000419a:	60e2                	ld	ra,24(sp)
    8000419c:	6442                	ld	s0,16(sp)
    8000419e:	64a2                	ld	s1,8(sp)
    800041a0:	6105                	addi	sp,sp,32
    800041a2:	8082                	ret
    panic("filedup");
    800041a4:	00003517          	auipc	a0,0x3
    800041a8:	4e450513          	addi	a0,a0,1252 # 80007688 <etext+0x688>
    800041ac:	df2fc0ef          	jal	8000079e <panic>

00000000800041b0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800041b0:	7139                	addi	sp,sp,-64
    800041b2:	fc06                	sd	ra,56(sp)
    800041b4:	f822                	sd	s0,48(sp)
    800041b6:	f426                	sd	s1,40(sp)
    800041b8:	0080                	addi	s0,sp,64
    800041ba:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041bc:	00025517          	auipc	a0,0x25
    800041c0:	72c50513          	addi	a0,a0,1836 # 800298e8 <ftable>
    800041c4:	a3bfc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    800041c8:	40dc                	lw	a5,4(s1)
    800041ca:	04f05863          	blez	a5,8000421a <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    800041ce:	37fd                	addiw	a5,a5,-1
    800041d0:	c0dc                	sw	a5,4(s1)
    800041d2:	04f04e63          	bgtz	a5,8000422e <fileclose+0x7e>
    800041d6:	f04a                	sd	s2,32(sp)
    800041d8:	ec4e                	sd	s3,24(sp)
    800041da:	e852                	sd	s4,16(sp)
    800041dc:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800041de:	0004a903          	lw	s2,0(s1)
    800041e2:	0094ca83          	lbu	s5,9(s1)
    800041e6:	0104ba03          	ld	s4,16(s1)
    800041ea:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800041ee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800041f2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800041f6:	00025517          	auipc	a0,0x25
    800041fa:	6f250513          	addi	a0,a0,1778 # 800298e8 <ftable>
    800041fe:	a95fc0ef          	jal	80000c92 <release>

  if(ff.type == FD_PIPE){
    80004202:	4785                	li	a5,1
    80004204:	04f90063          	beq	s2,a5,80004244 <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004208:	3979                	addiw	s2,s2,-2
    8000420a:	4785                	li	a5,1
    8000420c:	0527f563          	bgeu	a5,s2,80004256 <fileclose+0xa6>
    80004210:	7902                	ld	s2,32(sp)
    80004212:	69e2                	ld	s3,24(sp)
    80004214:	6a42                	ld	s4,16(sp)
    80004216:	6aa2                	ld	s5,8(sp)
    80004218:	a00d                	j	8000423a <fileclose+0x8a>
    8000421a:	f04a                	sd	s2,32(sp)
    8000421c:	ec4e                	sd	s3,24(sp)
    8000421e:	e852                	sd	s4,16(sp)
    80004220:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004222:	00003517          	auipc	a0,0x3
    80004226:	46e50513          	addi	a0,a0,1134 # 80007690 <etext+0x690>
    8000422a:	d74fc0ef          	jal	8000079e <panic>
    release(&ftable.lock);
    8000422e:	00025517          	auipc	a0,0x25
    80004232:	6ba50513          	addi	a0,a0,1722 # 800298e8 <ftable>
    80004236:	a5dfc0ef          	jal	80000c92 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000423a:	70e2                	ld	ra,56(sp)
    8000423c:	7442                	ld	s0,48(sp)
    8000423e:	74a2                	ld	s1,40(sp)
    80004240:	6121                	addi	sp,sp,64
    80004242:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004244:	85d6                	mv	a1,s5
    80004246:	8552                	mv	a0,s4
    80004248:	340000ef          	jal	80004588 <pipeclose>
    8000424c:	7902                	ld	s2,32(sp)
    8000424e:	69e2                	ld	s3,24(sp)
    80004250:	6a42                	ld	s4,16(sp)
    80004252:	6aa2                	ld	s5,8(sp)
    80004254:	b7dd                	j	8000423a <fileclose+0x8a>
    begin_op();
    80004256:	b3bff0ef          	jal	80003d90 <begin_op>
    iput(ff.ip);
    8000425a:	854e                	mv	a0,s3
    8000425c:	c04ff0ef          	jal	80003660 <iput>
    end_op();
    80004260:	b9bff0ef          	jal	80003dfa <end_op>
    80004264:	7902                	ld	s2,32(sp)
    80004266:	69e2                	ld	s3,24(sp)
    80004268:	6a42                	ld	s4,16(sp)
    8000426a:	6aa2                	ld	s5,8(sp)
    8000426c:	b7f9                	j	8000423a <fileclose+0x8a>

000000008000426e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000426e:	715d                	addi	sp,sp,-80
    80004270:	e486                	sd	ra,72(sp)
    80004272:	e0a2                	sd	s0,64(sp)
    80004274:	fc26                	sd	s1,56(sp)
    80004276:	f44e                	sd	s3,40(sp)
    80004278:	0880                	addi	s0,sp,80
    8000427a:	84aa                	mv	s1,a0
    8000427c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000427e:	e5efd0ef          	jal	800018dc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004282:	409c                	lw	a5,0(s1)
    80004284:	37f9                	addiw	a5,a5,-2
    80004286:	4705                	li	a4,1
    80004288:	04f76263          	bltu	a4,a5,800042cc <filestat+0x5e>
    8000428c:	f84a                	sd	s2,48(sp)
    8000428e:	f052                	sd	s4,32(sp)
    80004290:	892a                	mv	s2,a0
    ilock(f->ip);
    80004292:	6c88                	ld	a0,24(s1)
    80004294:	a4aff0ef          	jal	800034de <ilock>
    stati(f->ip, &st);
    80004298:	fb840a13          	addi	s4,s0,-72
    8000429c:	85d2                	mv	a1,s4
    8000429e:	6c88                	ld	a0,24(s1)
    800042a0:	c68ff0ef          	jal	80003708 <stati>
    iunlock(f->ip);
    800042a4:	6c88                	ld	a0,24(s1)
    800042a6:	ae6ff0ef          	jal	8000358c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800042aa:	46e1                	li	a3,24
    800042ac:	8652                	mv	a2,s4
    800042ae:	85ce                	mv	a1,s3
    800042b0:	05093503          	ld	a0,80(s2)
    800042b4:	ad0fd0ef          	jal	80001584 <copyout>
    800042b8:	41f5551b          	sraiw	a0,a0,0x1f
    800042bc:	7942                	ld	s2,48(sp)
    800042be:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800042c0:	60a6                	ld	ra,72(sp)
    800042c2:	6406                	ld	s0,64(sp)
    800042c4:	74e2                	ld	s1,56(sp)
    800042c6:	79a2                	ld	s3,40(sp)
    800042c8:	6161                	addi	sp,sp,80
    800042ca:	8082                	ret
  return -1;
    800042cc:	557d                	li	a0,-1
    800042ce:	bfcd                	j	800042c0 <filestat+0x52>

00000000800042d0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042d0:	7179                	addi	sp,sp,-48
    800042d2:	f406                	sd	ra,40(sp)
    800042d4:	f022                	sd	s0,32(sp)
    800042d6:	e84a                	sd	s2,16(sp)
    800042d8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800042da:	00854783          	lbu	a5,8(a0)
    800042de:	cfd1                	beqz	a5,8000437a <fileread+0xaa>
    800042e0:	ec26                	sd	s1,24(sp)
    800042e2:	e44e                	sd	s3,8(sp)
    800042e4:	84aa                	mv	s1,a0
    800042e6:	89ae                	mv	s3,a1
    800042e8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800042ea:	411c                	lw	a5,0(a0)
    800042ec:	4705                	li	a4,1
    800042ee:	04e78363          	beq	a5,a4,80004334 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042f2:	470d                	li	a4,3
    800042f4:	04e78763          	beq	a5,a4,80004342 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800042f8:	4709                	li	a4,2
    800042fa:	06e79a63          	bne	a5,a4,8000436e <fileread+0x9e>
    ilock(f->ip);
    800042fe:	6d08                	ld	a0,24(a0)
    80004300:	9deff0ef          	jal	800034de <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004304:	874a                	mv	a4,s2
    80004306:	5094                	lw	a3,32(s1)
    80004308:	864e                	mv	a2,s3
    8000430a:	4585                	li	a1,1
    8000430c:	6c88                	ld	a0,24(s1)
    8000430e:	c28ff0ef          	jal	80003736 <readi>
    80004312:	892a                	mv	s2,a0
    80004314:	00a05563          	blez	a0,8000431e <fileread+0x4e>
      f->off += r;
    80004318:	509c                	lw	a5,32(s1)
    8000431a:	9fa9                	addw	a5,a5,a0
    8000431c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000431e:	6c88                	ld	a0,24(s1)
    80004320:	a6cff0ef          	jal	8000358c <iunlock>
    80004324:	64e2                	ld	s1,24(sp)
    80004326:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004328:	854a                	mv	a0,s2
    8000432a:	70a2                	ld	ra,40(sp)
    8000432c:	7402                	ld	s0,32(sp)
    8000432e:	6942                	ld	s2,16(sp)
    80004330:	6145                	addi	sp,sp,48
    80004332:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004334:	6908                	ld	a0,16(a0)
    80004336:	3a2000ef          	jal	800046d8 <piperead>
    8000433a:	892a                	mv	s2,a0
    8000433c:	64e2                	ld	s1,24(sp)
    8000433e:	69a2                	ld	s3,8(sp)
    80004340:	b7e5                	j	80004328 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004342:	02451783          	lh	a5,36(a0)
    80004346:	03079693          	slli	a3,a5,0x30
    8000434a:	92c1                	srli	a3,a3,0x30
    8000434c:	4725                	li	a4,9
    8000434e:	02d76863          	bltu	a4,a3,8000437e <fileread+0xae>
    80004352:	0792                	slli	a5,a5,0x4
    80004354:	00025717          	auipc	a4,0x25
    80004358:	4f470713          	addi	a4,a4,1268 # 80029848 <devsw>
    8000435c:	97ba                	add	a5,a5,a4
    8000435e:	639c                	ld	a5,0(a5)
    80004360:	c39d                	beqz	a5,80004386 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004362:	4505                	li	a0,1
    80004364:	9782                	jalr	a5
    80004366:	892a                	mv	s2,a0
    80004368:	64e2                	ld	s1,24(sp)
    8000436a:	69a2                	ld	s3,8(sp)
    8000436c:	bf75                	j	80004328 <fileread+0x58>
    panic("fileread");
    8000436e:	00003517          	auipc	a0,0x3
    80004372:	33250513          	addi	a0,a0,818 # 800076a0 <etext+0x6a0>
    80004376:	c28fc0ef          	jal	8000079e <panic>
    return -1;
    8000437a:	597d                	li	s2,-1
    8000437c:	b775                	j	80004328 <fileread+0x58>
      return -1;
    8000437e:	597d                	li	s2,-1
    80004380:	64e2                	ld	s1,24(sp)
    80004382:	69a2                	ld	s3,8(sp)
    80004384:	b755                	j	80004328 <fileread+0x58>
    80004386:	597d                	li	s2,-1
    80004388:	64e2                	ld	s1,24(sp)
    8000438a:	69a2                	ld	s3,8(sp)
    8000438c:	bf71                	j	80004328 <fileread+0x58>

000000008000438e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000438e:	00954783          	lbu	a5,9(a0)
    80004392:	10078e63          	beqz	a5,800044ae <filewrite+0x120>
{
    80004396:	711d                	addi	sp,sp,-96
    80004398:	ec86                	sd	ra,88(sp)
    8000439a:	e8a2                	sd	s0,80(sp)
    8000439c:	e0ca                	sd	s2,64(sp)
    8000439e:	f456                	sd	s5,40(sp)
    800043a0:	f05a                	sd	s6,32(sp)
    800043a2:	1080                	addi	s0,sp,96
    800043a4:	892a                	mv	s2,a0
    800043a6:	8b2e                	mv	s6,a1
    800043a8:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800043aa:	411c                	lw	a5,0(a0)
    800043ac:	4705                	li	a4,1
    800043ae:	02e78963          	beq	a5,a4,800043e0 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043b2:	470d                	li	a4,3
    800043b4:	02e78a63          	beq	a5,a4,800043e8 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800043b8:	4709                	li	a4,2
    800043ba:	0ce79e63          	bne	a5,a4,80004496 <filewrite+0x108>
    800043be:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800043c0:	0ac05963          	blez	a2,80004472 <filewrite+0xe4>
    800043c4:	e4a6                	sd	s1,72(sp)
    800043c6:	fc4e                	sd	s3,56(sp)
    800043c8:	ec5e                	sd	s7,24(sp)
    800043ca:	e862                	sd	s8,16(sp)
    800043cc:	e466                	sd	s9,8(sp)
    int i = 0;
    800043ce:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800043d0:	6b85                	lui	s7,0x1
    800043d2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800043d6:	6c85                	lui	s9,0x1
    800043d8:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800043dc:	4c05                	li	s8,1
    800043de:	a8ad                	j	80004458 <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    800043e0:	6908                	ld	a0,16(a0)
    800043e2:	1fe000ef          	jal	800045e0 <pipewrite>
    800043e6:	a04d                	j	80004488 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800043e8:	02451783          	lh	a5,36(a0)
    800043ec:	03079693          	slli	a3,a5,0x30
    800043f0:	92c1                	srli	a3,a3,0x30
    800043f2:	4725                	li	a4,9
    800043f4:	0ad76f63          	bltu	a4,a3,800044b2 <filewrite+0x124>
    800043f8:	0792                	slli	a5,a5,0x4
    800043fa:	00025717          	auipc	a4,0x25
    800043fe:	44e70713          	addi	a4,a4,1102 # 80029848 <devsw>
    80004402:	97ba                	add	a5,a5,a4
    80004404:	679c                	ld	a5,8(a5)
    80004406:	cbc5                	beqz	a5,800044b6 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004408:	4505                	li	a0,1
    8000440a:	9782                	jalr	a5
    8000440c:	a8b5                	j	80004488 <filewrite+0xfa>
      if(n1 > max)
    8000440e:	2981                	sext.w	s3,s3
      begin_op();
    80004410:	981ff0ef          	jal	80003d90 <begin_op>
      ilock(f->ip);
    80004414:	01893503          	ld	a0,24(s2)
    80004418:	8c6ff0ef          	jal	800034de <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000441c:	874e                	mv	a4,s3
    8000441e:	02092683          	lw	a3,32(s2)
    80004422:	016a0633          	add	a2,s4,s6
    80004426:	85e2                	mv	a1,s8
    80004428:	01893503          	ld	a0,24(s2)
    8000442c:	bfcff0ef          	jal	80003828 <writei>
    80004430:	84aa                	mv	s1,a0
    80004432:	00a05763          	blez	a0,80004440 <filewrite+0xb2>
        f->off += r;
    80004436:	02092783          	lw	a5,32(s2)
    8000443a:	9fa9                	addw	a5,a5,a0
    8000443c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004440:	01893503          	ld	a0,24(s2)
    80004444:	948ff0ef          	jal	8000358c <iunlock>
      end_op();
    80004448:	9b3ff0ef          	jal	80003dfa <end_op>

      if(r != n1){
    8000444c:	02999563          	bne	s3,s1,80004476 <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    80004450:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004454:	015a5963          	bge	s4,s5,80004466 <filewrite+0xd8>
      int n1 = n - i;
    80004458:	414a87bb          	subw	a5,s5,s4
    8000445c:	89be                	mv	s3,a5
      if(n1 > max)
    8000445e:	fafbd8e3          	bge	s7,a5,8000440e <filewrite+0x80>
    80004462:	89e6                	mv	s3,s9
    80004464:	b76d                	j	8000440e <filewrite+0x80>
    80004466:	64a6                	ld	s1,72(sp)
    80004468:	79e2                	ld	s3,56(sp)
    8000446a:	6be2                	ld	s7,24(sp)
    8000446c:	6c42                	ld	s8,16(sp)
    8000446e:	6ca2                	ld	s9,8(sp)
    80004470:	a801                	j	80004480 <filewrite+0xf2>
    int i = 0;
    80004472:	4a01                	li	s4,0
    80004474:	a031                	j	80004480 <filewrite+0xf2>
    80004476:	64a6                	ld	s1,72(sp)
    80004478:	79e2                	ld	s3,56(sp)
    8000447a:	6be2                	ld	s7,24(sp)
    8000447c:	6c42                	ld	s8,16(sp)
    8000447e:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004480:	034a9d63          	bne	s5,s4,800044ba <filewrite+0x12c>
    80004484:	8556                	mv	a0,s5
    80004486:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004488:	60e6                	ld	ra,88(sp)
    8000448a:	6446                	ld	s0,80(sp)
    8000448c:	6906                	ld	s2,64(sp)
    8000448e:	7aa2                	ld	s5,40(sp)
    80004490:	7b02                	ld	s6,32(sp)
    80004492:	6125                	addi	sp,sp,96
    80004494:	8082                	ret
    80004496:	e4a6                	sd	s1,72(sp)
    80004498:	fc4e                	sd	s3,56(sp)
    8000449a:	f852                	sd	s4,48(sp)
    8000449c:	ec5e                	sd	s7,24(sp)
    8000449e:	e862                	sd	s8,16(sp)
    800044a0:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800044a2:	00003517          	auipc	a0,0x3
    800044a6:	20e50513          	addi	a0,a0,526 # 800076b0 <etext+0x6b0>
    800044aa:	af4fc0ef          	jal	8000079e <panic>
    return -1;
    800044ae:	557d                	li	a0,-1
}
    800044b0:	8082                	ret
      return -1;
    800044b2:	557d                	li	a0,-1
    800044b4:	bfd1                	j	80004488 <filewrite+0xfa>
    800044b6:	557d                	li	a0,-1
    800044b8:	bfc1                	j	80004488 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    800044ba:	557d                	li	a0,-1
    800044bc:	7a42                	ld	s4,48(sp)
    800044be:	b7e9                	j	80004488 <filewrite+0xfa>

00000000800044c0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800044c0:	7179                	addi	sp,sp,-48
    800044c2:	f406                	sd	ra,40(sp)
    800044c4:	f022                	sd	s0,32(sp)
    800044c6:	ec26                	sd	s1,24(sp)
    800044c8:	e052                	sd	s4,0(sp)
    800044ca:	1800                	addi	s0,sp,48
    800044cc:	84aa                	mv	s1,a0
    800044ce:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800044d0:	0005b023          	sd	zero,0(a1)
    800044d4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044d8:	c35ff0ef          	jal	8000410c <filealloc>
    800044dc:	e088                	sd	a0,0(s1)
    800044de:	c549                	beqz	a0,80004568 <pipealloc+0xa8>
    800044e0:	c2dff0ef          	jal	8000410c <filealloc>
    800044e4:	00aa3023          	sd	a0,0(s4)
    800044e8:	cd25                	beqz	a0,80004560 <pipealloc+0xa0>
    800044ea:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800044ec:	e3efc0ef          	jal	80000b2a <kalloc>
    800044f0:	892a                	mv	s2,a0
    800044f2:	c12d                	beqz	a0,80004554 <pipealloc+0x94>
    800044f4:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800044f6:	4985                	li	s3,1
    800044f8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800044fc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004500:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004504:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004508:	00003597          	auipc	a1,0x3
    8000450c:	df858593          	addi	a1,a1,-520 # 80007300 <etext+0x300>
    80004510:	e6afc0ef          	jal	80000b7a <initlock>
  (*f0)->type = FD_PIPE;
    80004514:	609c                	ld	a5,0(s1)
    80004516:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000451a:	609c                	ld	a5,0(s1)
    8000451c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004520:	609c                	ld	a5,0(s1)
    80004522:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004526:	609c                	ld	a5,0(s1)
    80004528:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000452c:	000a3783          	ld	a5,0(s4)
    80004530:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004534:	000a3783          	ld	a5,0(s4)
    80004538:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000453c:	000a3783          	ld	a5,0(s4)
    80004540:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004544:	000a3783          	ld	a5,0(s4)
    80004548:	0127b823          	sd	s2,16(a5)
  return 0;
    8000454c:	4501                	li	a0,0
    8000454e:	6942                	ld	s2,16(sp)
    80004550:	69a2                	ld	s3,8(sp)
    80004552:	a01d                	j	80004578 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004554:	6088                	ld	a0,0(s1)
    80004556:	c119                	beqz	a0,8000455c <pipealloc+0x9c>
    80004558:	6942                	ld	s2,16(sp)
    8000455a:	a029                	j	80004564 <pipealloc+0xa4>
    8000455c:	6942                	ld	s2,16(sp)
    8000455e:	a029                	j	80004568 <pipealloc+0xa8>
    80004560:	6088                	ld	a0,0(s1)
    80004562:	c10d                	beqz	a0,80004584 <pipealloc+0xc4>
    fileclose(*f0);
    80004564:	c4dff0ef          	jal	800041b0 <fileclose>
  if(*f1)
    80004568:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000456c:	557d                	li	a0,-1
  if(*f1)
    8000456e:	c789                	beqz	a5,80004578 <pipealloc+0xb8>
    fileclose(*f1);
    80004570:	853e                	mv	a0,a5
    80004572:	c3fff0ef          	jal	800041b0 <fileclose>
  return -1;
    80004576:	557d                	li	a0,-1
}
    80004578:	70a2                	ld	ra,40(sp)
    8000457a:	7402                	ld	s0,32(sp)
    8000457c:	64e2                	ld	s1,24(sp)
    8000457e:	6a02                	ld	s4,0(sp)
    80004580:	6145                	addi	sp,sp,48
    80004582:	8082                	ret
  return -1;
    80004584:	557d                	li	a0,-1
    80004586:	bfcd                	j	80004578 <pipealloc+0xb8>

0000000080004588 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004588:	1101                	addi	sp,sp,-32
    8000458a:	ec06                	sd	ra,24(sp)
    8000458c:	e822                	sd	s0,16(sp)
    8000458e:	e426                	sd	s1,8(sp)
    80004590:	e04a                	sd	s2,0(sp)
    80004592:	1000                	addi	s0,sp,32
    80004594:	84aa                	mv	s1,a0
    80004596:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004598:	e66fc0ef          	jal	80000bfe <acquire>
  if(writable){
    8000459c:	02090763          	beqz	s2,800045ca <pipeclose+0x42>
    pi->writeopen = 0;
    800045a0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800045a4:	21848513          	addi	a0,s1,536
    800045a8:	aa7fd0ef          	jal	8000204e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800045ac:	2204b783          	ld	a5,544(s1)
    800045b0:	e785                	bnez	a5,800045d8 <pipeclose+0x50>
    release(&pi->lock);
    800045b2:	8526                	mv	a0,s1
    800045b4:	edefc0ef          	jal	80000c92 <release>
    kfree((char*)pi);
    800045b8:	8526                	mv	a0,s1
    800045ba:	c8efc0ef          	jal	80000a48 <kfree>
  } else
    release(&pi->lock);
}
    800045be:	60e2                	ld	ra,24(sp)
    800045c0:	6442                	ld	s0,16(sp)
    800045c2:	64a2                	ld	s1,8(sp)
    800045c4:	6902                	ld	s2,0(sp)
    800045c6:	6105                	addi	sp,sp,32
    800045c8:	8082                	ret
    pi->readopen = 0;
    800045ca:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800045ce:	21c48513          	addi	a0,s1,540
    800045d2:	a7dfd0ef          	jal	8000204e <wakeup>
    800045d6:	bfd9                	j	800045ac <pipeclose+0x24>
    release(&pi->lock);
    800045d8:	8526                	mv	a0,s1
    800045da:	eb8fc0ef          	jal	80000c92 <release>
}
    800045de:	b7c5                	j	800045be <pipeclose+0x36>

00000000800045e0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045e0:	7159                	addi	sp,sp,-112
    800045e2:	f486                	sd	ra,104(sp)
    800045e4:	f0a2                	sd	s0,96(sp)
    800045e6:	eca6                	sd	s1,88(sp)
    800045e8:	e8ca                	sd	s2,80(sp)
    800045ea:	e4ce                	sd	s3,72(sp)
    800045ec:	e0d2                	sd	s4,64(sp)
    800045ee:	fc56                	sd	s5,56(sp)
    800045f0:	1880                	addi	s0,sp,112
    800045f2:	84aa                	mv	s1,a0
    800045f4:	8aae                	mv	s5,a1
    800045f6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800045f8:	ae4fd0ef          	jal	800018dc <myproc>
    800045fc:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800045fe:	8526                	mv	a0,s1
    80004600:	dfefc0ef          	jal	80000bfe <acquire>
  while(i < n){
    80004604:	0d405263          	blez	s4,800046c8 <pipewrite+0xe8>
    80004608:	f85a                	sd	s6,48(sp)
    8000460a:	f45e                	sd	s7,40(sp)
    8000460c:	f062                	sd	s8,32(sp)
    8000460e:	ec66                	sd	s9,24(sp)
    80004610:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004612:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004614:	f9f40c13          	addi	s8,s0,-97
    80004618:	4b85                	li	s7,1
    8000461a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000461c:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004620:	21c48c93          	addi	s9,s1,540
    80004624:	a82d                	j	8000465e <pipewrite+0x7e>
      release(&pi->lock);
    80004626:	8526                	mv	a0,s1
    80004628:	e6afc0ef          	jal	80000c92 <release>
      return -1;
    8000462c:	597d                	li	s2,-1
    8000462e:	7b42                	ld	s6,48(sp)
    80004630:	7ba2                	ld	s7,40(sp)
    80004632:	7c02                	ld	s8,32(sp)
    80004634:	6ce2                	ld	s9,24(sp)
    80004636:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004638:	854a                	mv	a0,s2
    8000463a:	70a6                	ld	ra,104(sp)
    8000463c:	7406                	ld	s0,96(sp)
    8000463e:	64e6                	ld	s1,88(sp)
    80004640:	6946                	ld	s2,80(sp)
    80004642:	69a6                	ld	s3,72(sp)
    80004644:	6a06                	ld	s4,64(sp)
    80004646:	7ae2                	ld	s5,56(sp)
    80004648:	6165                	addi	sp,sp,112
    8000464a:	8082                	ret
      wakeup(&pi->nread);
    8000464c:	856a                	mv	a0,s10
    8000464e:	a01fd0ef          	jal	8000204e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004652:	85a6                	mv	a1,s1
    80004654:	8566                	mv	a0,s9
    80004656:	9adfd0ef          	jal	80002002 <sleep>
  while(i < n){
    8000465a:	05495a63          	bge	s2,s4,800046ae <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000465e:	2204a783          	lw	a5,544(s1)
    80004662:	d3f1                	beqz	a5,80004626 <pipewrite+0x46>
    80004664:	854e                	mv	a0,s3
    80004666:	bd5fd0ef          	jal	8000223a <killed>
    8000466a:	fd55                	bnez	a0,80004626 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000466c:	2184a783          	lw	a5,536(s1)
    80004670:	21c4a703          	lw	a4,540(s1)
    80004674:	2007879b          	addiw	a5,a5,512
    80004678:	fcf70ae3          	beq	a4,a5,8000464c <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000467c:	86de                	mv	a3,s7
    8000467e:	01590633          	add	a2,s2,s5
    80004682:	85e2                	mv	a1,s8
    80004684:	0509b503          	ld	a0,80(s3)
    80004688:	fadfc0ef          	jal	80001634 <copyin>
    8000468c:	05650063          	beq	a0,s6,800046cc <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004690:	21c4a783          	lw	a5,540(s1)
    80004694:	0017871b          	addiw	a4,a5,1
    80004698:	20e4ae23          	sw	a4,540(s1)
    8000469c:	1ff7f793          	andi	a5,a5,511
    800046a0:	97a6                	add	a5,a5,s1
    800046a2:	f9f44703          	lbu	a4,-97(s0)
    800046a6:	00e78c23          	sb	a4,24(a5)
      i++;
    800046aa:	2905                	addiw	s2,s2,1
    800046ac:	b77d                	j	8000465a <pipewrite+0x7a>
    800046ae:	7b42                	ld	s6,48(sp)
    800046b0:	7ba2                	ld	s7,40(sp)
    800046b2:	7c02                	ld	s8,32(sp)
    800046b4:	6ce2                	ld	s9,24(sp)
    800046b6:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800046b8:	21848513          	addi	a0,s1,536
    800046bc:	993fd0ef          	jal	8000204e <wakeup>
  release(&pi->lock);
    800046c0:	8526                	mv	a0,s1
    800046c2:	dd0fc0ef          	jal	80000c92 <release>
  return i;
    800046c6:	bf8d                	j	80004638 <pipewrite+0x58>
  int i = 0;
    800046c8:	4901                	li	s2,0
    800046ca:	b7fd                	j	800046b8 <pipewrite+0xd8>
    800046cc:	7b42                	ld	s6,48(sp)
    800046ce:	7ba2                	ld	s7,40(sp)
    800046d0:	7c02                	ld	s8,32(sp)
    800046d2:	6ce2                	ld	s9,24(sp)
    800046d4:	6d42                	ld	s10,16(sp)
    800046d6:	b7cd                	j	800046b8 <pipewrite+0xd8>

00000000800046d8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800046d8:	711d                	addi	sp,sp,-96
    800046da:	ec86                	sd	ra,88(sp)
    800046dc:	e8a2                	sd	s0,80(sp)
    800046de:	e4a6                	sd	s1,72(sp)
    800046e0:	e0ca                	sd	s2,64(sp)
    800046e2:	fc4e                	sd	s3,56(sp)
    800046e4:	f852                	sd	s4,48(sp)
    800046e6:	f456                	sd	s5,40(sp)
    800046e8:	1080                	addi	s0,sp,96
    800046ea:	84aa                	mv	s1,a0
    800046ec:	892e                	mv	s2,a1
    800046ee:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800046f0:	9ecfd0ef          	jal	800018dc <myproc>
    800046f4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800046f6:	8526                	mv	a0,s1
    800046f8:	d06fc0ef          	jal	80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046fc:	2184a703          	lw	a4,536(s1)
    80004700:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004704:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004708:	02f71763          	bne	a4,a5,80004736 <piperead+0x5e>
    8000470c:	2244a783          	lw	a5,548(s1)
    80004710:	cf85                	beqz	a5,80004748 <piperead+0x70>
    if(killed(pr)){
    80004712:	8552                	mv	a0,s4
    80004714:	b27fd0ef          	jal	8000223a <killed>
    80004718:	e11d                	bnez	a0,8000473e <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000471a:	85a6                	mv	a1,s1
    8000471c:	854e                	mv	a0,s3
    8000471e:	8e5fd0ef          	jal	80002002 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004722:	2184a703          	lw	a4,536(s1)
    80004726:	21c4a783          	lw	a5,540(s1)
    8000472a:	fef701e3          	beq	a4,a5,8000470c <piperead+0x34>
    8000472e:	f05a                	sd	s6,32(sp)
    80004730:	ec5e                	sd	s7,24(sp)
    80004732:	e862                	sd	s8,16(sp)
    80004734:	a829                	j	8000474e <piperead+0x76>
    80004736:	f05a                	sd	s6,32(sp)
    80004738:	ec5e                	sd	s7,24(sp)
    8000473a:	e862                	sd	s8,16(sp)
    8000473c:	a809                	j	8000474e <piperead+0x76>
      release(&pi->lock);
    8000473e:	8526                	mv	a0,s1
    80004740:	d52fc0ef          	jal	80000c92 <release>
      return -1;
    80004744:	59fd                	li	s3,-1
    80004746:	a0a5                	j	800047ae <piperead+0xd6>
    80004748:	f05a                	sd	s6,32(sp)
    8000474a:	ec5e                	sd	s7,24(sp)
    8000474c:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000474e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004750:	faf40c13          	addi	s8,s0,-81
    80004754:	4b85                	li	s7,1
    80004756:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004758:	05505163          	blez	s5,8000479a <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    8000475c:	2184a783          	lw	a5,536(s1)
    80004760:	21c4a703          	lw	a4,540(s1)
    80004764:	02f70b63          	beq	a4,a5,8000479a <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004768:	0017871b          	addiw	a4,a5,1
    8000476c:	20e4ac23          	sw	a4,536(s1)
    80004770:	1ff7f793          	andi	a5,a5,511
    80004774:	97a6                	add	a5,a5,s1
    80004776:	0187c783          	lbu	a5,24(a5)
    8000477a:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000477e:	86de                	mv	a3,s7
    80004780:	8662                	mv	a2,s8
    80004782:	85ca                	mv	a1,s2
    80004784:	050a3503          	ld	a0,80(s4)
    80004788:	dfdfc0ef          	jal	80001584 <copyout>
    8000478c:	01650763          	beq	a0,s6,8000479a <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004790:	2985                	addiw	s3,s3,1
    80004792:	0905                	addi	s2,s2,1
    80004794:	fd3a94e3          	bne	s5,s3,8000475c <piperead+0x84>
    80004798:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000479a:	21c48513          	addi	a0,s1,540
    8000479e:	8b1fd0ef          	jal	8000204e <wakeup>
  release(&pi->lock);
    800047a2:	8526                	mv	a0,s1
    800047a4:	ceefc0ef          	jal	80000c92 <release>
    800047a8:	7b02                	ld	s6,32(sp)
    800047aa:	6be2                	ld	s7,24(sp)
    800047ac:	6c42                	ld	s8,16(sp)
  return i;
}
    800047ae:	854e                	mv	a0,s3
    800047b0:	60e6                	ld	ra,88(sp)
    800047b2:	6446                	ld	s0,80(sp)
    800047b4:	64a6                	ld	s1,72(sp)
    800047b6:	6906                	ld	s2,64(sp)
    800047b8:	79e2                	ld	s3,56(sp)
    800047ba:	7a42                	ld	s4,48(sp)
    800047bc:	7aa2                	ld	s5,40(sp)
    800047be:	6125                	addi	sp,sp,96
    800047c0:	8082                	ret

00000000800047c2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800047c2:	1141                	addi	sp,sp,-16
    800047c4:	e406                	sd	ra,8(sp)
    800047c6:	e022                	sd	s0,0(sp)
    800047c8:	0800                	addi	s0,sp,16
    800047ca:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800047cc:	0035151b          	slliw	a0,a0,0x3
    800047d0:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800047d2:	8b89                	andi	a5,a5,2
    800047d4:	c399                	beqz	a5,800047da <flags2perm+0x18>
      perm |= PTE_W;
    800047d6:	00456513          	ori	a0,a0,4
    return perm;
}
    800047da:	60a2                	ld	ra,8(sp)
    800047dc:	6402                	ld	s0,0(sp)
    800047de:	0141                	addi	sp,sp,16
    800047e0:	8082                	ret

00000000800047e2 <exec>:

int
exec(char *path, char **argv)
{
    800047e2:	de010113          	addi	sp,sp,-544
    800047e6:	20113c23          	sd	ra,536(sp)
    800047ea:	20813823          	sd	s0,528(sp)
    800047ee:	20913423          	sd	s1,520(sp)
    800047f2:	21213023          	sd	s2,512(sp)
    800047f6:	1400                	addi	s0,sp,544
    800047f8:	892a                	mv	s2,a0
    800047fa:	dea43823          	sd	a0,-528(s0)
    800047fe:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004802:	8dafd0ef          	jal	800018dc <myproc>
    80004806:	84aa                	mv	s1,a0

  begin_op();
    80004808:	d88ff0ef          	jal	80003d90 <begin_op>

  if((ip = namei(path)) == 0){
    8000480c:	854a                	mv	a0,s2
    8000480e:	bc0ff0ef          	jal	80003bce <namei>
    80004812:	cd21                	beqz	a0,8000486a <exec+0x88>
    80004814:	fbd2                	sd	s4,496(sp)
    80004816:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004818:	cc7fe0ef          	jal	800034de <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000481c:	04000713          	li	a4,64
    80004820:	4681                	li	a3,0
    80004822:	e5040613          	addi	a2,s0,-432
    80004826:	4581                	li	a1,0
    80004828:	8552                	mv	a0,s4
    8000482a:	f0dfe0ef          	jal	80003736 <readi>
    8000482e:	04000793          	li	a5,64
    80004832:	00f51a63          	bne	a0,a5,80004846 <exec+0x64>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004836:	e5042703          	lw	a4,-432(s0)
    8000483a:	464c47b7          	lui	a5,0x464c4
    8000483e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004842:	02f70863          	beq	a4,a5,80004872 <exec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004846:	8552                	mv	a0,s4
    80004848:	ea1fe0ef          	jal	800036e8 <iunlockput>
    end_op();
    8000484c:	daeff0ef          	jal	80003dfa <end_op>
  }
  return -1;
    80004850:	557d                	li	a0,-1
    80004852:	7a5e                	ld	s4,496(sp)
}
    80004854:	21813083          	ld	ra,536(sp)
    80004858:	21013403          	ld	s0,528(sp)
    8000485c:	20813483          	ld	s1,520(sp)
    80004860:	20013903          	ld	s2,512(sp)
    80004864:	22010113          	addi	sp,sp,544
    80004868:	8082                	ret
    end_op();
    8000486a:	d90ff0ef          	jal	80003dfa <end_op>
    return -1;
    8000486e:	557d                	li	a0,-1
    80004870:	b7d5                	j	80004854 <exec+0x72>
    80004872:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004874:	8526                	mv	a0,s1
    80004876:	90efd0ef          	jal	80001984 <proc_pagetable>
    8000487a:	8b2a                	mv	s6,a0
    8000487c:	26050d63          	beqz	a0,80004af6 <exec+0x314>
    80004880:	ffce                	sd	s3,504(sp)
    80004882:	f7d6                	sd	s5,488(sp)
    80004884:	efde                	sd	s7,472(sp)
    80004886:	ebe2                	sd	s8,464(sp)
    80004888:	e7e6                	sd	s9,456(sp)
    8000488a:	e3ea                	sd	s10,448(sp)
    8000488c:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000488e:	e7042683          	lw	a3,-400(s0)
    80004892:	e8845783          	lhu	a5,-376(s0)
    80004896:	0e078763          	beqz	a5,80004984 <exec+0x1a2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000489a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000489c:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000489e:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800048a2:	6c85                	lui	s9,0x1
    800048a4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800048a8:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800048ac:	6a85                	lui	s5,0x1
    800048ae:	a085                	j	8000490e <exec+0x12c>
      panic("loadseg: address should exist");
    800048b0:	00003517          	auipc	a0,0x3
    800048b4:	e1050513          	addi	a0,a0,-496 # 800076c0 <etext+0x6c0>
    800048b8:	ee7fb0ef          	jal	8000079e <panic>
    if(sz - i < PGSIZE)
    800048bc:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800048be:	874a                	mv	a4,s2
    800048c0:	009c06bb          	addw	a3,s8,s1
    800048c4:	4581                	li	a1,0
    800048c6:	8552                	mv	a0,s4
    800048c8:	e6ffe0ef          	jal	80003736 <readi>
    800048cc:	22a91963          	bne	s2,a0,80004afe <exec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    800048d0:	009a84bb          	addw	s1,s5,s1
    800048d4:	0334f263          	bgeu	s1,s3,800048f8 <exec+0x116>
    pa = walkaddr(pagetable, va + i);
    800048d8:	02049593          	slli	a1,s1,0x20
    800048dc:	9181                	srli	a1,a1,0x20
    800048de:	95de                	add	a1,a1,s7
    800048e0:	855a                	mv	a0,s6
    800048e2:	f1afc0ef          	jal	80000ffc <walkaddr>
    800048e6:	862a                	mv	a2,a0
    if(pa == 0)
    800048e8:	d561                	beqz	a0,800048b0 <exec+0xce>
    if(sz - i < PGSIZE)
    800048ea:	409987bb          	subw	a5,s3,s1
    800048ee:	893e                	mv	s2,a5
    800048f0:	fcfcf6e3          	bgeu	s9,a5,800048bc <exec+0xda>
    800048f4:	8956                	mv	s2,s5
    800048f6:	b7d9                	j	800048bc <exec+0xda>
    sz = sz1;
    800048f8:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048fc:	2d05                	addiw	s10,s10,1
    800048fe:	e0843783          	ld	a5,-504(s0)
    80004902:	0387869b          	addiw	a3,a5,56
    80004906:	e8845783          	lhu	a5,-376(s0)
    8000490a:	06fd5e63          	bge	s10,a5,80004986 <exec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000490e:	e0d43423          	sd	a3,-504(s0)
    80004912:	876e                	mv	a4,s11
    80004914:	e1840613          	addi	a2,s0,-488
    80004918:	4581                	li	a1,0
    8000491a:	8552                	mv	a0,s4
    8000491c:	e1bfe0ef          	jal	80003736 <readi>
    80004920:	1db51d63          	bne	a0,s11,80004afa <exec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    80004924:	e1842783          	lw	a5,-488(s0)
    80004928:	4705                	li	a4,1
    8000492a:	fce799e3          	bne	a5,a4,800048fc <exec+0x11a>
    if(ph.memsz < ph.filesz)
    8000492e:	e4043483          	ld	s1,-448(s0)
    80004932:	e3843783          	ld	a5,-456(s0)
    80004936:	1ef4e263          	bltu	s1,a5,80004b1a <exec+0x338>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000493a:	e2843783          	ld	a5,-472(s0)
    8000493e:	94be                	add	s1,s1,a5
    80004940:	1ef4e063          	bltu	s1,a5,80004b20 <exec+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    80004944:	de843703          	ld	a4,-536(s0)
    80004948:	8ff9                	and	a5,a5,a4
    8000494a:	1c079e63          	bnez	a5,80004b26 <exec+0x344>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000494e:	e1c42503          	lw	a0,-484(s0)
    80004952:	e71ff0ef          	jal	800047c2 <flags2perm>
    80004956:	86aa                	mv	a3,a0
    80004958:	8626                	mv	a2,s1
    8000495a:	85ca                	mv	a1,s2
    8000495c:	855a                	mv	a0,s6
    8000495e:	a07fc0ef          	jal	80001364 <uvmalloc>
    80004962:	dea43c23          	sd	a0,-520(s0)
    80004966:	1c050363          	beqz	a0,80004b2c <exec+0x34a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000496a:	e2843b83          	ld	s7,-472(s0)
    8000496e:	e2042c03          	lw	s8,-480(s0)
    80004972:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004976:	00098463          	beqz	s3,8000497e <exec+0x19c>
    8000497a:	4481                	li	s1,0
    8000497c:	bfb1                	j	800048d8 <exec+0xf6>
    sz = sz1;
    8000497e:	df843903          	ld	s2,-520(s0)
    80004982:	bfad                	j	800048fc <exec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004984:	4901                	li	s2,0
  iunlockput(ip);
    80004986:	8552                	mv	a0,s4
    80004988:	d61fe0ef          	jal	800036e8 <iunlockput>
  end_op();
    8000498c:	c6eff0ef          	jal	80003dfa <end_op>
  p = myproc();
    80004990:	f4dfc0ef          	jal	800018dc <myproc>
    80004994:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004996:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000499a:	6985                	lui	s3,0x1
    8000499c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000499e:	99ca                	add	s3,s3,s2
    800049a0:	77fd                	lui	a5,0xfffff
    800049a2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800049a6:	4691                	li	a3,4
    800049a8:	6609                	lui	a2,0x2
    800049aa:	964e                	add	a2,a2,s3
    800049ac:	85ce                	mv	a1,s3
    800049ae:	855a                	mv	a0,s6
    800049b0:	9b5fc0ef          	jal	80001364 <uvmalloc>
    800049b4:	8a2a                	mv	s4,a0
    800049b6:	e105                	bnez	a0,800049d6 <exec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800049b8:	85ce                	mv	a1,s3
    800049ba:	855a                	mv	a0,s6
    800049bc:	84cfd0ef          	jal	80001a08 <proc_freepagetable>
  return -1;
    800049c0:	557d                	li	a0,-1
    800049c2:	79fe                	ld	s3,504(sp)
    800049c4:	7a5e                	ld	s4,496(sp)
    800049c6:	7abe                	ld	s5,488(sp)
    800049c8:	7b1e                	ld	s6,480(sp)
    800049ca:	6bfe                	ld	s7,472(sp)
    800049cc:	6c5e                	ld	s8,464(sp)
    800049ce:	6cbe                	ld	s9,456(sp)
    800049d0:	6d1e                	ld	s10,448(sp)
    800049d2:	7dfa                	ld	s11,440(sp)
    800049d4:	b541                	j	80004854 <exec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800049d6:	75f9                	lui	a1,0xffffe
    800049d8:	95aa                	add	a1,a1,a0
    800049da:	855a                	mv	a0,s6
    800049dc:	b7ffc0ef          	jal	8000155a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800049e0:	7bfd                	lui	s7,0xfffff
    800049e2:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    800049e4:	e0043783          	ld	a5,-512(s0)
    800049e8:	6388                	ld	a0,0(a5)
  sp = sz;
    800049ea:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    800049ec:	4481                	li	s1,0
    ustack[argc] = sp;
    800049ee:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    800049f2:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    800049f6:	cd21                	beqz	a0,80004a4e <exec+0x26c>
    sp -= strlen(argv[argc]) + 1;
    800049f8:	c5efc0ef          	jal	80000e56 <strlen>
    800049fc:	0015079b          	addiw	a5,a0,1
    80004a00:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a04:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004a08:	13796563          	bltu	s2,s7,80004b32 <exec+0x350>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a0c:	e0043d83          	ld	s11,-512(s0)
    80004a10:	000db983          	ld	s3,0(s11)
    80004a14:	854e                	mv	a0,s3
    80004a16:	c40fc0ef          	jal	80000e56 <strlen>
    80004a1a:	0015069b          	addiw	a3,a0,1
    80004a1e:	864e                	mv	a2,s3
    80004a20:	85ca                	mv	a1,s2
    80004a22:	855a                	mv	a0,s6
    80004a24:	b61fc0ef          	jal	80001584 <copyout>
    80004a28:	10054763          	bltz	a0,80004b36 <exec+0x354>
    ustack[argc] = sp;
    80004a2c:	00349793          	slli	a5,s1,0x3
    80004a30:	97e6                	add	a5,a5,s9
    80004a32:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd4620>
  for(argc = 0; argv[argc]; argc++) {
    80004a36:	0485                	addi	s1,s1,1
    80004a38:	008d8793          	addi	a5,s11,8
    80004a3c:	e0f43023          	sd	a5,-512(s0)
    80004a40:	008db503          	ld	a0,8(s11)
    80004a44:	c509                	beqz	a0,80004a4e <exec+0x26c>
    if(argc >= MAXARG)
    80004a46:	fb8499e3          	bne	s1,s8,800049f8 <exec+0x216>
  sz = sz1;
    80004a4a:	89d2                	mv	s3,s4
    80004a4c:	b7b5                	j	800049b8 <exec+0x1d6>
  ustack[argc] = 0;
    80004a4e:	00349793          	slli	a5,s1,0x3
    80004a52:	f9078793          	addi	a5,a5,-112
    80004a56:	97a2                	add	a5,a5,s0
    80004a58:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004a5c:	00148693          	addi	a3,s1,1
    80004a60:	068e                	slli	a3,a3,0x3
    80004a62:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004a66:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004a6a:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004a6c:	f57966e3          	bltu	s2,s7,800049b8 <exec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004a70:	e9040613          	addi	a2,s0,-368
    80004a74:	85ca                	mv	a1,s2
    80004a76:	855a                	mv	a0,s6
    80004a78:	b0dfc0ef          	jal	80001584 <copyout>
    80004a7c:	f2054ee3          	bltz	a0,800049b8 <exec+0x1d6>
  p->trapframe->a1 = sp;
    80004a80:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004a84:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004a88:	df043783          	ld	a5,-528(s0)
    80004a8c:	0007c703          	lbu	a4,0(a5)
    80004a90:	cf11                	beqz	a4,80004aac <exec+0x2ca>
    80004a92:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004a94:	02f00693          	li	a3,47
    80004a98:	a029                	j	80004aa2 <exec+0x2c0>
  for(last=s=path; *s; s++)
    80004a9a:	0785                	addi	a5,a5,1
    80004a9c:	fff7c703          	lbu	a4,-1(a5)
    80004aa0:	c711                	beqz	a4,80004aac <exec+0x2ca>
    if(*s == '/')
    80004aa2:	fed71ce3          	bne	a4,a3,80004a9a <exec+0x2b8>
      last = s+1;
    80004aa6:	def43823          	sd	a5,-528(s0)
    80004aaa:	bfc5                	j	80004a9a <exec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    80004aac:	4641                	li	a2,16
    80004aae:	df043583          	ld	a1,-528(s0)
    80004ab2:	158a8513          	addi	a0,s5,344
    80004ab6:	b6afc0ef          	jal	80000e20 <safestrcpy>
  oldpagetable = p->pagetable;
    80004aba:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004abe:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004ac2:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ac6:	058ab783          	ld	a5,88(s5)
    80004aca:	e6843703          	ld	a4,-408(s0)
    80004ace:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ad0:	058ab783          	ld	a5,88(s5)
    80004ad4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ad8:	85ea                	mv	a1,s10
    80004ada:	f2ffc0ef          	jal	80001a08 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ade:	0004851b          	sext.w	a0,s1
    80004ae2:	79fe                	ld	s3,504(sp)
    80004ae4:	7a5e                	ld	s4,496(sp)
    80004ae6:	7abe                	ld	s5,488(sp)
    80004ae8:	7b1e                	ld	s6,480(sp)
    80004aea:	6bfe                	ld	s7,472(sp)
    80004aec:	6c5e                	ld	s8,464(sp)
    80004aee:	6cbe                	ld	s9,456(sp)
    80004af0:	6d1e                	ld	s10,448(sp)
    80004af2:	7dfa                	ld	s11,440(sp)
    80004af4:	b385                	j	80004854 <exec+0x72>
    80004af6:	7b1e                	ld	s6,480(sp)
    80004af8:	b3b9                	j	80004846 <exec+0x64>
    80004afa:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004afe:	df843583          	ld	a1,-520(s0)
    80004b02:	855a                	mv	a0,s6
    80004b04:	f05fc0ef          	jal	80001a08 <proc_freepagetable>
  if(ip){
    80004b08:	79fe                	ld	s3,504(sp)
    80004b0a:	7abe                	ld	s5,488(sp)
    80004b0c:	7b1e                	ld	s6,480(sp)
    80004b0e:	6bfe                	ld	s7,472(sp)
    80004b10:	6c5e                	ld	s8,464(sp)
    80004b12:	6cbe                	ld	s9,456(sp)
    80004b14:	6d1e                	ld	s10,448(sp)
    80004b16:	7dfa                	ld	s11,440(sp)
    80004b18:	b33d                	j	80004846 <exec+0x64>
    80004b1a:	df243c23          	sd	s2,-520(s0)
    80004b1e:	b7c5                	j	80004afe <exec+0x31c>
    80004b20:	df243c23          	sd	s2,-520(s0)
    80004b24:	bfe9                	j	80004afe <exec+0x31c>
    80004b26:	df243c23          	sd	s2,-520(s0)
    80004b2a:	bfd1                	j	80004afe <exec+0x31c>
    80004b2c:	df243c23          	sd	s2,-520(s0)
    80004b30:	b7f9                	j	80004afe <exec+0x31c>
  sz = sz1;
    80004b32:	89d2                	mv	s3,s4
    80004b34:	b551                	j	800049b8 <exec+0x1d6>
    80004b36:	89d2                	mv	s3,s4
    80004b38:	b541                	j	800049b8 <exec+0x1d6>

0000000080004b3a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004b3a:	7179                	addi	sp,sp,-48
    80004b3c:	f406                	sd	ra,40(sp)
    80004b3e:	f022                	sd	s0,32(sp)
    80004b40:	ec26                	sd	s1,24(sp)
    80004b42:	e84a                	sd	s2,16(sp)
    80004b44:	1800                	addi	s0,sp,48
    80004b46:	892e                	mv	s2,a1
    80004b48:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004b4a:	fdc40593          	addi	a1,s0,-36
    80004b4e:	d99fd0ef          	jal	800028e6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004b52:	fdc42703          	lw	a4,-36(s0)
    80004b56:	47bd                	li	a5,15
    80004b58:	02e7e963          	bltu	a5,a4,80004b8a <argfd+0x50>
    80004b5c:	d81fc0ef          	jal	800018dc <myproc>
    80004b60:	fdc42703          	lw	a4,-36(s0)
    80004b64:	01a70793          	addi	a5,a4,26
    80004b68:	078e                	slli	a5,a5,0x3
    80004b6a:	953e                	add	a0,a0,a5
    80004b6c:	611c                	ld	a5,0(a0)
    80004b6e:	c385                	beqz	a5,80004b8e <argfd+0x54>
    return -1;
  if(pfd)
    80004b70:	00090463          	beqz	s2,80004b78 <argfd+0x3e>
    *pfd = fd;
    80004b74:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004b78:	4501                	li	a0,0
  if(pf)
    80004b7a:	c091                	beqz	s1,80004b7e <argfd+0x44>
    *pf = f;
    80004b7c:	e09c                	sd	a5,0(s1)
}
    80004b7e:	70a2                	ld	ra,40(sp)
    80004b80:	7402                	ld	s0,32(sp)
    80004b82:	64e2                	ld	s1,24(sp)
    80004b84:	6942                	ld	s2,16(sp)
    80004b86:	6145                	addi	sp,sp,48
    80004b88:	8082                	ret
    return -1;
    80004b8a:	557d                	li	a0,-1
    80004b8c:	bfcd                	j	80004b7e <argfd+0x44>
    80004b8e:	557d                	li	a0,-1
    80004b90:	b7fd                	j	80004b7e <argfd+0x44>

0000000080004b92 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b92:	1101                	addi	sp,sp,-32
    80004b94:	ec06                	sd	ra,24(sp)
    80004b96:	e822                	sd	s0,16(sp)
    80004b98:	e426                	sd	s1,8(sp)
    80004b9a:	1000                	addi	s0,sp,32
    80004b9c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004b9e:	d3ffc0ef          	jal	800018dc <myproc>
    80004ba2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004ba4:	0d050793          	addi	a5,a0,208
    80004ba8:	4501                	li	a0,0
    80004baa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004bac:	6398                	ld	a4,0(a5)
    80004bae:	cb19                	beqz	a4,80004bc4 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004bb0:	2505                	addiw	a0,a0,1
    80004bb2:	07a1                	addi	a5,a5,8
    80004bb4:	fed51ce3          	bne	a0,a3,80004bac <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004bb8:	557d                	li	a0,-1
}
    80004bba:	60e2                	ld	ra,24(sp)
    80004bbc:	6442                	ld	s0,16(sp)
    80004bbe:	64a2                	ld	s1,8(sp)
    80004bc0:	6105                	addi	sp,sp,32
    80004bc2:	8082                	ret
      p->ofile[fd] = f;
    80004bc4:	01a50793          	addi	a5,a0,26
    80004bc8:	078e                	slli	a5,a5,0x3
    80004bca:	963e                	add	a2,a2,a5
    80004bcc:	e204                	sd	s1,0(a2)
      return fd;
    80004bce:	b7f5                	j	80004bba <fdalloc+0x28>

0000000080004bd0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004bd0:	715d                	addi	sp,sp,-80
    80004bd2:	e486                	sd	ra,72(sp)
    80004bd4:	e0a2                	sd	s0,64(sp)
    80004bd6:	fc26                	sd	s1,56(sp)
    80004bd8:	f84a                	sd	s2,48(sp)
    80004bda:	f44e                	sd	s3,40(sp)
    80004bdc:	ec56                	sd	s5,24(sp)
    80004bde:	e85a                	sd	s6,16(sp)
    80004be0:	0880                	addi	s0,sp,80
    80004be2:	8b2e                	mv	s6,a1
    80004be4:	89b2                	mv	s3,a2
    80004be6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004be8:	fb040593          	addi	a1,s0,-80
    80004bec:	ffdfe0ef          	jal	80003be8 <nameiparent>
    80004bf0:	84aa                	mv	s1,a0
    80004bf2:	10050a63          	beqz	a0,80004d06 <create+0x136>
    return 0;

  ilock(dp);
    80004bf6:	8e9fe0ef          	jal	800034de <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004bfa:	4601                	li	a2,0
    80004bfc:	fb040593          	addi	a1,s0,-80
    80004c00:	8526                	mv	a0,s1
    80004c02:	d41fe0ef          	jal	80003942 <dirlookup>
    80004c06:	8aaa                	mv	s5,a0
    80004c08:	c129                	beqz	a0,80004c4a <create+0x7a>
    iunlockput(dp);
    80004c0a:	8526                	mv	a0,s1
    80004c0c:	addfe0ef          	jal	800036e8 <iunlockput>
    ilock(ip);
    80004c10:	8556                	mv	a0,s5
    80004c12:	8cdfe0ef          	jal	800034de <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004c16:	4789                	li	a5,2
    80004c18:	02fb1463          	bne	s6,a5,80004c40 <create+0x70>
    80004c1c:	044ad783          	lhu	a5,68(s5)
    80004c20:	37f9                	addiw	a5,a5,-2
    80004c22:	17c2                	slli	a5,a5,0x30
    80004c24:	93c1                	srli	a5,a5,0x30
    80004c26:	4705                	li	a4,1
    80004c28:	00f76c63          	bltu	a4,a5,80004c40 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004c2c:	8556                	mv	a0,s5
    80004c2e:	60a6                	ld	ra,72(sp)
    80004c30:	6406                	ld	s0,64(sp)
    80004c32:	74e2                	ld	s1,56(sp)
    80004c34:	7942                	ld	s2,48(sp)
    80004c36:	79a2                	ld	s3,40(sp)
    80004c38:	6ae2                	ld	s5,24(sp)
    80004c3a:	6b42                	ld	s6,16(sp)
    80004c3c:	6161                	addi	sp,sp,80
    80004c3e:	8082                	ret
    iunlockput(ip);
    80004c40:	8556                	mv	a0,s5
    80004c42:	aa7fe0ef          	jal	800036e8 <iunlockput>
    return 0;
    80004c46:	4a81                	li	s5,0
    80004c48:	b7d5                	j	80004c2c <create+0x5c>
    80004c4a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004c4c:	85da                	mv	a1,s6
    80004c4e:	4088                	lw	a0,0(s1)
    80004c50:	f1efe0ef          	jal	8000336e <ialloc>
    80004c54:	8a2a                	mv	s4,a0
    80004c56:	cd15                	beqz	a0,80004c92 <create+0xc2>
  ilock(ip);
    80004c58:	887fe0ef          	jal	800034de <ilock>
  ip->major = major;
    80004c5c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004c60:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004c64:	4905                	li	s2,1
    80004c66:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004c6a:	8552                	mv	a0,s4
    80004c6c:	fbefe0ef          	jal	8000342a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004c70:	032b0763          	beq	s6,s2,80004c9e <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c74:	004a2603          	lw	a2,4(s4)
    80004c78:	fb040593          	addi	a1,s0,-80
    80004c7c:	8526                	mv	a0,s1
    80004c7e:	ea7fe0ef          	jal	80003b24 <dirlink>
    80004c82:	06054563          	bltz	a0,80004cec <create+0x11c>
  iunlockput(dp);
    80004c86:	8526                	mv	a0,s1
    80004c88:	a61fe0ef          	jal	800036e8 <iunlockput>
  return ip;
    80004c8c:	8ad2                	mv	s5,s4
    80004c8e:	7a02                	ld	s4,32(sp)
    80004c90:	bf71                	j	80004c2c <create+0x5c>
    iunlockput(dp);
    80004c92:	8526                	mv	a0,s1
    80004c94:	a55fe0ef          	jal	800036e8 <iunlockput>
    return 0;
    80004c98:	8ad2                	mv	s5,s4
    80004c9a:	7a02                	ld	s4,32(sp)
    80004c9c:	bf41                	j	80004c2c <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004c9e:	004a2603          	lw	a2,4(s4)
    80004ca2:	00003597          	auipc	a1,0x3
    80004ca6:	a3e58593          	addi	a1,a1,-1474 # 800076e0 <etext+0x6e0>
    80004caa:	8552                	mv	a0,s4
    80004cac:	e79fe0ef          	jal	80003b24 <dirlink>
    80004cb0:	02054e63          	bltz	a0,80004cec <create+0x11c>
    80004cb4:	40d0                	lw	a2,4(s1)
    80004cb6:	00003597          	auipc	a1,0x3
    80004cba:	a3258593          	addi	a1,a1,-1486 # 800076e8 <etext+0x6e8>
    80004cbe:	8552                	mv	a0,s4
    80004cc0:	e65fe0ef          	jal	80003b24 <dirlink>
    80004cc4:	02054463          	bltz	a0,80004cec <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004cc8:	004a2603          	lw	a2,4(s4)
    80004ccc:	fb040593          	addi	a1,s0,-80
    80004cd0:	8526                	mv	a0,s1
    80004cd2:	e53fe0ef          	jal	80003b24 <dirlink>
    80004cd6:	00054b63          	bltz	a0,80004cec <create+0x11c>
    dp->nlink++;  // for ".."
    80004cda:	04a4d783          	lhu	a5,74(s1)
    80004cde:	2785                	addiw	a5,a5,1
    80004ce0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ce4:	8526                	mv	a0,s1
    80004ce6:	f44fe0ef          	jal	8000342a <iupdate>
    80004cea:	bf71                	j	80004c86 <create+0xb6>
  ip->nlink = 0;
    80004cec:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004cf0:	8552                	mv	a0,s4
    80004cf2:	f38fe0ef          	jal	8000342a <iupdate>
  iunlockput(ip);
    80004cf6:	8552                	mv	a0,s4
    80004cf8:	9f1fe0ef          	jal	800036e8 <iunlockput>
  iunlockput(dp);
    80004cfc:	8526                	mv	a0,s1
    80004cfe:	9ebfe0ef          	jal	800036e8 <iunlockput>
  return 0;
    80004d02:	7a02                	ld	s4,32(sp)
    80004d04:	b725                	j	80004c2c <create+0x5c>
    return 0;
    80004d06:	8aaa                	mv	s5,a0
    80004d08:	b715                	j	80004c2c <create+0x5c>

0000000080004d0a <sys_dup>:
{
    80004d0a:	7179                	addi	sp,sp,-48
    80004d0c:	f406                	sd	ra,40(sp)
    80004d0e:	f022                	sd	s0,32(sp)
    80004d10:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004d12:	fd840613          	addi	a2,s0,-40
    80004d16:	4581                	li	a1,0
    80004d18:	4501                	li	a0,0
    80004d1a:	e21ff0ef          	jal	80004b3a <argfd>
    return -1;
    80004d1e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004d20:	02054363          	bltz	a0,80004d46 <sys_dup+0x3c>
    80004d24:	ec26                	sd	s1,24(sp)
    80004d26:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004d28:	fd843903          	ld	s2,-40(s0)
    80004d2c:	854a                	mv	a0,s2
    80004d2e:	e65ff0ef          	jal	80004b92 <fdalloc>
    80004d32:	84aa                	mv	s1,a0
    return -1;
    80004d34:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004d36:	00054d63          	bltz	a0,80004d50 <sys_dup+0x46>
  filedup(f);
    80004d3a:	854a                	mv	a0,s2
    80004d3c:	c2eff0ef          	jal	8000416a <filedup>
  return fd;
    80004d40:	87a6                	mv	a5,s1
    80004d42:	64e2                	ld	s1,24(sp)
    80004d44:	6942                	ld	s2,16(sp)
}
    80004d46:	853e                	mv	a0,a5
    80004d48:	70a2                	ld	ra,40(sp)
    80004d4a:	7402                	ld	s0,32(sp)
    80004d4c:	6145                	addi	sp,sp,48
    80004d4e:	8082                	ret
    80004d50:	64e2                	ld	s1,24(sp)
    80004d52:	6942                	ld	s2,16(sp)
    80004d54:	bfcd                	j	80004d46 <sys_dup+0x3c>

0000000080004d56 <sys_read>:
{
    80004d56:	7179                	addi	sp,sp,-48
    80004d58:	f406                	sd	ra,40(sp)
    80004d5a:	f022                	sd	s0,32(sp)
    80004d5c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d5e:	fd840593          	addi	a1,s0,-40
    80004d62:	4505                	li	a0,1
    80004d64:	b9ffd0ef          	jal	80002902 <argaddr>
  argint(2, &n);
    80004d68:	fe440593          	addi	a1,s0,-28
    80004d6c:	4509                	li	a0,2
    80004d6e:	b79fd0ef          	jal	800028e6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004d72:	fe840613          	addi	a2,s0,-24
    80004d76:	4581                	li	a1,0
    80004d78:	4501                	li	a0,0
    80004d7a:	dc1ff0ef          	jal	80004b3a <argfd>
    80004d7e:	87aa                	mv	a5,a0
    return -1;
    80004d80:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d82:	0007ca63          	bltz	a5,80004d96 <sys_read+0x40>
  return fileread(f, p, n);
    80004d86:	fe442603          	lw	a2,-28(s0)
    80004d8a:	fd843583          	ld	a1,-40(s0)
    80004d8e:	fe843503          	ld	a0,-24(s0)
    80004d92:	d3eff0ef          	jal	800042d0 <fileread>
}
    80004d96:	70a2                	ld	ra,40(sp)
    80004d98:	7402                	ld	s0,32(sp)
    80004d9a:	6145                	addi	sp,sp,48
    80004d9c:	8082                	ret

0000000080004d9e <sys_write>:
{
    80004d9e:	7179                	addi	sp,sp,-48
    80004da0:	f406                	sd	ra,40(sp)
    80004da2:	f022                	sd	s0,32(sp)
    80004da4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004da6:	fd840593          	addi	a1,s0,-40
    80004daa:	4505                	li	a0,1
    80004dac:	b57fd0ef          	jal	80002902 <argaddr>
  argint(2, &n);
    80004db0:	fe440593          	addi	a1,s0,-28
    80004db4:	4509                	li	a0,2
    80004db6:	b31fd0ef          	jal	800028e6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004dba:	fe840613          	addi	a2,s0,-24
    80004dbe:	4581                	li	a1,0
    80004dc0:	4501                	li	a0,0
    80004dc2:	d79ff0ef          	jal	80004b3a <argfd>
    80004dc6:	87aa                	mv	a5,a0
    return -1;
    80004dc8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004dca:	0007ca63          	bltz	a5,80004dde <sys_write+0x40>
  return filewrite(f, p, n);
    80004dce:	fe442603          	lw	a2,-28(s0)
    80004dd2:	fd843583          	ld	a1,-40(s0)
    80004dd6:	fe843503          	ld	a0,-24(s0)
    80004dda:	db4ff0ef          	jal	8000438e <filewrite>
}
    80004dde:	70a2                	ld	ra,40(sp)
    80004de0:	7402                	ld	s0,32(sp)
    80004de2:	6145                	addi	sp,sp,48
    80004de4:	8082                	ret

0000000080004de6 <sys_close>:
{
    80004de6:	1101                	addi	sp,sp,-32
    80004de8:	ec06                	sd	ra,24(sp)
    80004dea:	e822                	sd	s0,16(sp)
    80004dec:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004dee:	fe040613          	addi	a2,s0,-32
    80004df2:	fec40593          	addi	a1,s0,-20
    80004df6:	4501                	li	a0,0
    80004df8:	d43ff0ef          	jal	80004b3a <argfd>
    return -1;
    80004dfc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004dfe:	02054063          	bltz	a0,80004e1e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004e02:	adbfc0ef          	jal	800018dc <myproc>
    80004e06:	fec42783          	lw	a5,-20(s0)
    80004e0a:	07e9                	addi	a5,a5,26
    80004e0c:	078e                	slli	a5,a5,0x3
    80004e0e:	953e                	add	a0,a0,a5
    80004e10:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004e14:	fe043503          	ld	a0,-32(s0)
    80004e18:	b98ff0ef          	jal	800041b0 <fileclose>
  return 0;
    80004e1c:	4781                	li	a5,0
}
    80004e1e:	853e                	mv	a0,a5
    80004e20:	60e2                	ld	ra,24(sp)
    80004e22:	6442                	ld	s0,16(sp)
    80004e24:	6105                	addi	sp,sp,32
    80004e26:	8082                	ret

0000000080004e28 <sys_fstat>:
{
    80004e28:	1101                	addi	sp,sp,-32
    80004e2a:	ec06                	sd	ra,24(sp)
    80004e2c:	e822                	sd	s0,16(sp)
    80004e2e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004e30:	fe040593          	addi	a1,s0,-32
    80004e34:	4505                	li	a0,1
    80004e36:	acdfd0ef          	jal	80002902 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004e3a:	fe840613          	addi	a2,s0,-24
    80004e3e:	4581                	li	a1,0
    80004e40:	4501                	li	a0,0
    80004e42:	cf9ff0ef          	jal	80004b3a <argfd>
    80004e46:	87aa                	mv	a5,a0
    return -1;
    80004e48:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e4a:	0007c863          	bltz	a5,80004e5a <sys_fstat+0x32>
  return filestat(f, st);
    80004e4e:	fe043583          	ld	a1,-32(s0)
    80004e52:	fe843503          	ld	a0,-24(s0)
    80004e56:	c18ff0ef          	jal	8000426e <filestat>
}
    80004e5a:	60e2                	ld	ra,24(sp)
    80004e5c:	6442                	ld	s0,16(sp)
    80004e5e:	6105                	addi	sp,sp,32
    80004e60:	8082                	ret

0000000080004e62 <sys_link>:
{
    80004e62:	7169                	addi	sp,sp,-304
    80004e64:	f606                	sd	ra,296(sp)
    80004e66:	f222                	sd	s0,288(sp)
    80004e68:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e6a:	08000613          	li	a2,128
    80004e6e:	ed040593          	addi	a1,s0,-304
    80004e72:	4501                	li	a0,0
    80004e74:	aabfd0ef          	jal	8000291e <argstr>
    return -1;
    80004e78:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e7a:	0c054e63          	bltz	a0,80004f56 <sys_link+0xf4>
    80004e7e:	08000613          	li	a2,128
    80004e82:	f5040593          	addi	a1,s0,-176
    80004e86:	4505                	li	a0,1
    80004e88:	a97fd0ef          	jal	8000291e <argstr>
    return -1;
    80004e8c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e8e:	0c054463          	bltz	a0,80004f56 <sys_link+0xf4>
    80004e92:	ee26                	sd	s1,280(sp)
  begin_op();
    80004e94:	efdfe0ef          	jal	80003d90 <begin_op>
  if((ip = namei(old)) == 0){
    80004e98:	ed040513          	addi	a0,s0,-304
    80004e9c:	d33fe0ef          	jal	80003bce <namei>
    80004ea0:	84aa                	mv	s1,a0
    80004ea2:	c53d                	beqz	a0,80004f10 <sys_link+0xae>
  ilock(ip);
    80004ea4:	e3afe0ef          	jal	800034de <ilock>
  if(ip->type == T_DIR){
    80004ea8:	04449703          	lh	a4,68(s1)
    80004eac:	4785                	li	a5,1
    80004eae:	06f70663          	beq	a4,a5,80004f1a <sys_link+0xb8>
    80004eb2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004eb4:	04a4d783          	lhu	a5,74(s1)
    80004eb8:	2785                	addiw	a5,a5,1
    80004eba:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	d6afe0ef          	jal	8000342a <iupdate>
  iunlock(ip);
    80004ec4:	8526                	mv	a0,s1
    80004ec6:	ec6fe0ef          	jal	8000358c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004eca:	fd040593          	addi	a1,s0,-48
    80004ece:	f5040513          	addi	a0,s0,-176
    80004ed2:	d17fe0ef          	jal	80003be8 <nameiparent>
    80004ed6:	892a                	mv	s2,a0
    80004ed8:	cd21                	beqz	a0,80004f30 <sys_link+0xce>
  ilock(dp);
    80004eda:	e04fe0ef          	jal	800034de <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004ede:	00092703          	lw	a4,0(s2)
    80004ee2:	409c                	lw	a5,0(s1)
    80004ee4:	04f71363          	bne	a4,a5,80004f2a <sys_link+0xc8>
    80004ee8:	40d0                	lw	a2,4(s1)
    80004eea:	fd040593          	addi	a1,s0,-48
    80004eee:	854a                	mv	a0,s2
    80004ef0:	c35fe0ef          	jal	80003b24 <dirlink>
    80004ef4:	02054b63          	bltz	a0,80004f2a <sys_link+0xc8>
  iunlockput(dp);
    80004ef8:	854a                	mv	a0,s2
    80004efa:	feefe0ef          	jal	800036e8 <iunlockput>
  iput(ip);
    80004efe:	8526                	mv	a0,s1
    80004f00:	f60fe0ef          	jal	80003660 <iput>
  end_op();
    80004f04:	ef7fe0ef          	jal	80003dfa <end_op>
  return 0;
    80004f08:	4781                	li	a5,0
    80004f0a:	64f2                	ld	s1,280(sp)
    80004f0c:	6952                	ld	s2,272(sp)
    80004f0e:	a0a1                	j	80004f56 <sys_link+0xf4>
    end_op();
    80004f10:	eebfe0ef          	jal	80003dfa <end_op>
    return -1;
    80004f14:	57fd                	li	a5,-1
    80004f16:	64f2                	ld	s1,280(sp)
    80004f18:	a83d                	j	80004f56 <sys_link+0xf4>
    iunlockput(ip);
    80004f1a:	8526                	mv	a0,s1
    80004f1c:	fccfe0ef          	jal	800036e8 <iunlockput>
    end_op();
    80004f20:	edbfe0ef          	jal	80003dfa <end_op>
    return -1;
    80004f24:	57fd                	li	a5,-1
    80004f26:	64f2                	ld	s1,280(sp)
    80004f28:	a03d                	j	80004f56 <sys_link+0xf4>
    iunlockput(dp);
    80004f2a:	854a                	mv	a0,s2
    80004f2c:	fbcfe0ef          	jal	800036e8 <iunlockput>
  ilock(ip);
    80004f30:	8526                	mv	a0,s1
    80004f32:	dacfe0ef          	jal	800034de <ilock>
  ip->nlink--;
    80004f36:	04a4d783          	lhu	a5,74(s1)
    80004f3a:	37fd                	addiw	a5,a5,-1
    80004f3c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f40:	8526                	mv	a0,s1
    80004f42:	ce8fe0ef          	jal	8000342a <iupdate>
  iunlockput(ip);
    80004f46:	8526                	mv	a0,s1
    80004f48:	fa0fe0ef          	jal	800036e8 <iunlockput>
  end_op();
    80004f4c:	eaffe0ef          	jal	80003dfa <end_op>
  return -1;
    80004f50:	57fd                	li	a5,-1
    80004f52:	64f2                	ld	s1,280(sp)
    80004f54:	6952                	ld	s2,272(sp)
}
    80004f56:	853e                	mv	a0,a5
    80004f58:	70b2                	ld	ra,296(sp)
    80004f5a:	7412                	ld	s0,288(sp)
    80004f5c:	6155                	addi	sp,sp,304
    80004f5e:	8082                	ret

0000000080004f60 <sys_unlink>:
{
    80004f60:	7111                	addi	sp,sp,-256
    80004f62:	fd86                	sd	ra,248(sp)
    80004f64:	f9a2                	sd	s0,240(sp)
    80004f66:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80004f68:	08000613          	li	a2,128
    80004f6c:	f2040593          	addi	a1,s0,-224
    80004f70:	4501                	li	a0,0
    80004f72:	9adfd0ef          	jal	8000291e <argstr>
    80004f76:	16054663          	bltz	a0,800050e2 <sys_unlink+0x182>
    80004f7a:	f5a6                	sd	s1,232(sp)
  begin_op();
    80004f7c:	e15fe0ef          	jal	80003d90 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004f80:	fa040593          	addi	a1,s0,-96
    80004f84:	f2040513          	addi	a0,s0,-224
    80004f88:	c61fe0ef          	jal	80003be8 <nameiparent>
    80004f8c:	84aa                	mv	s1,a0
    80004f8e:	c955                	beqz	a0,80005042 <sys_unlink+0xe2>
  ilock(dp);
    80004f90:	d4efe0ef          	jal	800034de <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f94:	00002597          	auipc	a1,0x2
    80004f98:	74c58593          	addi	a1,a1,1868 # 800076e0 <etext+0x6e0>
    80004f9c:	fa040513          	addi	a0,s0,-96
    80004fa0:	98dfe0ef          	jal	8000392c <namecmp>
    80004fa4:	12050463          	beqz	a0,800050cc <sys_unlink+0x16c>
    80004fa8:	00002597          	auipc	a1,0x2
    80004fac:	74058593          	addi	a1,a1,1856 # 800076e8 <etext+0x6e8>
    80004fb0:	fa040513          	addi	a0,s0,-96
    80004fb4:	979fe0ef          	jal	8000392c <namecmp>
    80004fb8:	10050a63          	beqz	a0,800050cc <sys_unlink+0x16c>
    80004fbc:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004fbe:	f1c40613          	addi	a2,s0,-228
    80004fc2:	fa040593          	addi	a1,s0,-96
    80004fc6:	8526                	mv	a0,s1
    80004fc8:	97bfe0ef          	jal	80003942 <dirlookup>
    80004fcc:	892a                	mv	s2,a0
    80004fce:	0e050e63          	beqz	a0,800050ca <sys_unlink+0x16a>
    80004fd2:	edce                	sd	s3,216(sp)
  ilock(ip);
    80004fd4:	d0afe0ef          	jal	800034de <ilock>
  if(ip->nlink < 1)
    80004fd8:	04a91783          	lh	a5,74(s2)
    80004fdc:	06f05863          	blez	a5,8000504c <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004fe0:	04491703          	lh	a4,68(s2)
    80004fe4:	4785                	li	a5,1
    80004fe6:	06f70b63          	beq	a4,a5,8000505c <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    80004fea:	fb040993          	addi	s3,s0,-80
    80004fee:	4641                	li	a2,16
    80004ff0:	4581                	li	a1,0
    80004ff2:	854e                	mv	a0,s3
    80004ff4:	cdbfb0ef          	jal	80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ff8:	4741                	li	a4,16
    80004ffa:	f1c42683          	lw	a3,-228(s0)
    80004ffe:	864e                	mv	a2,s3
    80005000:	4581                	li	a1,0
    80005002:	8526                	mv	a0,s1
    80005004:	825fe0ef          	jal	80003828 <writei>
    80005008:	47c1                	li	a5,16
    8000500a:	08f51f63          	bne	a0,a5,800050a8 <sys_unlink+0x148>
  if(ip->type == T_DIR){
    8000500e:	04491703          	lh	a4,68(s2)
    80005012:	4785                	li	a5,1
    80005014:	0af70263          	beq	a4,a5,800050b8 <sys_unlink+0x158>
  iunlockput(dp);
    80005018:	8526                	mv	a0,s1
    8000501a:	ecefe0ef          	jal	800036e8 <iunlockput>
  ip->nlink--;
    8000501e:	04a95783          	lhu	a5,74(s2)
    80005022:	37fd                	addiw	a5,a5,-1
    80005024:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005028:	854a                	mv	a0,s2
    8000502a:	c00fe0ef          	jal	8000342a <iupdate>
  iunlockput(ip);
    8000502e:	854a                	mv	a0,s2
    80005030:	eb8fe0ef          	jal	800036e8 <iunlockput>
  end_op();
    80005034:	dc7fe0ef          	jal	80003dfa <end_op>
  return 0;
    80005038:	4501                	li	a0,0
    8000503a:	74ae                	ld	s1,232(sp)
    8000503c:	790e                	ld	s2,224(sp)
    8000503e:	69ee                	ld	s3,216(sp)
    80005040:	a869                	j	800050da <sys_unlink+0x17a>
    end_op();
    80005042:	db9fe0ef          	jal	80003dfa <end_op>
    return -1;
    80005046:	557d                	li	a0,-1
    80005048:	74ae                	ld	s1,232(sp)
    8000504a:	a841                	j	800050da <sys_unlink+0x17a>
    8000504c:	e9d2                	sd	s4,208(sp)
    8000504e:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80005050:	00002517          	auipc	a0,0x2
    80005054:	6a050513          	addi	a0,a0,1696 # 800076f0 <etext+0x6f0>
    80005058:	f46fb0ef          	jal	8000079e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000505c:	04c92703          	lw	a4,76(s2)
    80005060:	02000793          	li	a5,32
    80005064:	f8e7f3e3          	bgeu	a5,a4,80004fea <sys_unlink+0x8a>
    80005068:	e9d2                	sd	s4,208(sp)
    8000506a:	e5d6                	sd	s5,200(sp)
    8000506c:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000506e:	f0840a93          	addi	s5,s0,-248
    80005072:	4a41                	li	s4,16
    80005074:	8752                	mv	a4,s4
    80005076:	86ce                	mv	a3,s3
    80005078:	8656                	mv	a2,s5
    8000507a:	4581                	li	a1,0
    8000507c:	854a                	mv	a0,s2
    8000507e:	eb8fe0ef          	jal	80003736 <readi>
    80005082:	01451d63          	bne	a0,s4,8000509c <sys_unlink+0x13c>
    if(de.inum != 0)
    80005086:	f0845783          	lhu	a5,-248(s0)
    8000508a:	efb1                	bnez	a5,800050e6 <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000508c:	29c1                	addiw	s3,s3,16
    8000508e:	04c92783          	lw	a5,76(s2)
    80005092:	fef9e1e3          	bltu	s3,a5,80005074 <sys_unlink+0x114>
    80005096:	6a4e                	ld	s4,208(sp)
    80005098:	6aae                	ld	s5,200(sp)
    8000509a:	bf81                	j	80004fea <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000509c:	00002517          	auipc	a0,0x2
    800050a0:	66c50513          	addi	a0,a0,1644 # 80007708 <etext+0x708>
    800050a4:	efafb0ef          	jal	8000079e <panic>
    800050a8:	e9d2                	sd	s4,208(sp)
    800050aa:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    800050ac:	00002517          	auipc	a0,0x2
    800050b0:	67450513          	addi	a0,a0,1652 # 80007720 <etext+0x720>
    800050b4:	eeafb0ef          	jal	8000079e <panic>
    dp->nlink--;
    800050b8:	04a4d783          	lhu	a5,74(s1)
    800050bc:	37fd                	addiw	a5,a5,-1
    800050be:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050c2:	8526                	mv	a0,s1
    800050c4:	b66fe0ef          	jal	8000342a <iupdate>
    800050c8:	bf81                	j	80005018 <sys_unlink+0xb8>
    800050ca:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    800050cc:	8526                	mv	a0,s1
    800050ce:	e1afe0ef          	jal	800036e8 <iunlockput>
  end_op();
    800050d2:	d29fe0ef          	jal	80003dfa <end_op>
  return -1;
    800050d6:	557d                	li	a0,-1
    800050d8:	74ae                	ld	s1,232(sp)
}
    800050da:	70ee                	ld	ra,248(sp)
    800050dc:	744e                	ld	s0,240(sp)
    800050de:	6111                	addi	sp,sp,256
    800050e0:	8082                	ret
    return -1;
    800050e2:	557d                	li	a0,-1
    800050e4:	bfdd                	j	800050da <sys_unlink+0x17a>
    iunlockput(ip);
    800050e6:	854a                	mv	a0,s2
    800050e8:	e00fe0ef          	jal	800036e8 <iunlockput>
    goto bad;
    800050ec:	790e                	ld	s2,224(sp)
    800050ee:	69ee                	ld	s3,216(sp)
    800050f0:	6a4e                	ld	s4,208(sp)
    800050f2:	6aae                	ld	s5,200(sp)
    800050f4:	bfe1                	j	800050cc <sys_unlink+0x16c>

00000000800050f6 <sys_open>:

uint64
sys_open(void)
{
    800050f6:	7131                	addi	sp,sp,-192
    800050f8:	fd06                	sd	ra,184(sp)
    800050fa:	f922                	sd	s0,176(sp)
    800050fc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800050fe:	f4c40593          	addi	a1,s0,-180
    80005102:	4505                	li	a0,1
    80005104:	fe2fd0ef          	jal	800028e6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005108:	08000613          	li	a2,128
    8000510c:	f5040593          	addi	a1,s0,-176
    80005110:	4501                	li	a0,0
    80005112:	80dfd0ef          	jal	8000291e <argstr>
    80005116:	87aa                	mv	a5,a0
    return -1;
    80005118:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000511a:	0a07c363          	bltz	a5,800051c0 <sys_open+0xca>
    8000511e:	f526                	sd	s1,168(sp)

  begin_op();
    80005120:	c71fe0ef          	jal	80003d90 <begin_op>

  if(omode & O_CREATE){
    80005124:	f4c42783          	lw	a5,-180(s0)
    80005128:	2007f793          	andi	a5,a5,512
    8000512c:	c3dd                	beqz	a5,800051d2 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000512e:	4681                	li	a3,0
    80005130:	4601                	li	a2,0
    80005132:	4589                	li	a1,2
    80005134:	f5040513          	addi	a0,s0,-176
    80005138:	a99ff0ef          	jal	80004bd0 <create>
    8000513c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000513e:	c549                	beqz	a0,800051c8 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005140:	04449703          	lh	a4,68(s1)
    80005144:	478d                	li	a5,3
    80005146:	00f71763          	bne	a4,a5,80005154 <sys_open+0x5e>
    8000514a:	0464d703          	lhu	a4,70(s1)
    8000514e:	47a5                	li	a5,9
    80005150:	0ae7ee63          	bltu	a5,a4,8000520c <sys_open+0x116>
    80005154:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005156:	fb7fe0ef          	jal	8000410c <filealloc>
    8000515a:	892a                	mv	s2,a0
    8000515c:	c561                	beqz	a0,80005224 <sys_open+0x12e>
    8000515e:	ed4e                	sd	s3,152(sp)
    80005160:	a33ff0ef          	jal	80004b92 <fdalloc>
    80005164:	89aa                	mv	s3,a0
    80005166:	0a054b63          	bltz	a0,8000521c <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000516a:	04449703          	lh	a4,68(s1)
    8000516e:	478d                	li	a5,3
    80005170:	0cf70363          	beq	a4,a5,80005236 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005174:	4789                	li	a5,2
    80005176:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000517a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000517e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005182:	f4c42783          	lw	a5,-180(s0)
    80005186:	0017f713          	andi	a4,a5,1
    8000518a:	00174713          	xori	a4,a4,1
    8000518e:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005192:	0037f713          	andi	a4,a5,3
    80005196:	00e03733          	snez	a4,a4
    8000519a:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000519e:	4007f793          	andi	a5,a5,1024
    800051a2:	c791                	beqz	a5,800051ae <sys_open+0xb8>
    800051a4:	04449703          	lh	a4,68(s1)
    800051a8:	4789                	li	a5,2
    800051aa:	08f70d63          	beq	a4,a5,80005244 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800051ae:	8526                	mv	a0,s1
    800051b0:	bdcfe0ef          	jal	8000358c <iunlock>
  end_op();
    800051b4:	c47fe0ef          	jal	80003dfa <end_op>

  return fd;
    800051b8:	854e                	mv	a0,s3
    800051ba:	74aa                	ld	s1,168(sp)
    800051bc:	790a                	ld	s2,160(sp)
    800051be:	69ea                	ld	s3,152(sp)
}
    800051c0:	70ea                	ld	ra,184(sp)
    800051c2:	744a                	ld	s0,176(sp)
    800051c4:	6129                	addi	sp,sp,192
    800051c6:	8082                	ret
      end_op();
    800051c8:	c33fe0ef          	jal	80003dfa <end_op>
      return -1;
    800051cc:	557d                	li	a0,-1
    800051ce:	74aa                	ld	s1,168(sp)
    800051d0:	bfc5                	j	800051c0 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    800051d2:	f5040513          	addi	a0,s0,-176
    800051d6:	9f9fe0ef          	jal	80003bce <namei>
    800051da:	84aa                	mv	s1,a0
    800051dc:	c11d                	beqz	a0,80005202 <sys_open+0x10c>
    ilock(ip);
    800051de:	b00fe0ef          	jal	800034de <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800051e2:	04449703          	lh	a4,68(s1)
    800051e6:	4785                	li	a5,1
    800051e8:	f4f71ce3          	bne	a4,a5,80005140 <sys_open+0x4a>
    800051ec:	f4c42783          	lw	a5,-180(s0)
    800051f0:	d3b5                	beqz	a5,80005154 <sys_open+0x5e>
      iunlockput(ip);
    800051f2:	8526                	mv	a0,s1
    800051f4:	cf4fe0ef          	jal	800036e8 <iunlockput>
      end_op();
    800051f8:	c03fe0ef          	jal	80003dfa <end_op>
      return -1;
    800051fc:	557d                	li	a0,-1
    800051fe:	74aa                	ld	s1,168(sp)
    80005200:	b7c1                	j	800051c0 <sys_open+0xca>
      end_op();
    80005202:	bf9fe0ef          	jal	80003dfa <end_op>
      return -1;
    80005206:	557d                	li	a0,-1
    80005208:	74aa                	ld	s1,168(sp)
    8000520a:	bf5d                	j	800051c0 <sys_open+0xca>
    iunlockput(ip);
    8000520c:	8526                	mv	a0,s1
    8000520e:	cdafe0ef          	jal	800036e8 <iunlockput>
    end_op();
    80005212:	be9fe0ef          	jal	80003dfa <end_op>
    return -1;
    80005216:	557d                	li	a0,-1
    80005218:	74aa                	ld	s1,168(sp)
    8000521a:	b75d                	j	800051c0 <sys_open+0xca>
      fileclose(f);
    8000521c:	854a                	mv	a0,s2
    8000521e:	f93fe0ef          	jal	800041b0 <fileclose>
    80005222:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005224:	8526                	mv	a0,s1
    80005226:	cc2fe0ef          	jal	800036e8 <iunlockput>
    end_op();
    8000522a:	bd1fe0ef          	jal	80003dfa <end_op>
    return -1;
    8000522e:	557d                	li	a0,-1
    80005230:	74aa                	ld	s1,168(sp)
    80005232:	790a                	ld	s2,160(sp)
    80005234:	b771                	j	800051c0 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005236:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000523a:	04649783          	lh	a5,70(s1)
    8000523e:	02f91223          	sh	a5,36(s2)
    80005242:	bf35                	j	8000517e <sys_open+0x88>
    itrunc(ip);
    80005244:	8526                	mv	a0,s1
    80005246:	b86fe0ef          	jal	800035cc <itrunc>
    8000524a:	b795                	j	800051ae <sys_open+0xb8>

000000008000524c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000524c:	7175                	addi	sp,sp,-144
    8000524e:	e506                	sd	ra,136(sp)
    80005250:	e122                	sd	s0,128(sp)
    80005252:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005254:	b3dfe0ef          	jal	80003d90 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005258:	08000613          	li	a2,128
    8000525c:	f7040593          	addi	a1,s0,-144
    80005260:	4501                	li	a0,0
    80005262:	ebcfd0ef          	jal	8000291e <argstr>
    80005266:	02054363          	bltz	a0,8000528c <sys_mkdir+0x40>
    8000526a:	4681                	li	a3,0
    8000526c:	4601                	li	a2,0
    8000526e:	4585                	li	a1,1
    80005270:	f7040513          	addi	a0,s0,-144
    80005274:	95dff0ef          	jal	80004bd0 <create>
    80005278:	c911                	beqz	a0,8000528c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000527a:	c6efe0ef          	jal	800036e8 <iunlockput>
  end_op();
    8000527e:	b7dfe0ef          	jal	80003dfa <end_op>
  return 0;
    80005282:	4501                	li	a0,0
}
    80005284:	60aa                	ld	ra,136(sp)
    80005286:	640a                	ld	s0,128(sp)
    80005288:	6149                	addi	sp,sp,144
    8000528a:	8082                	ret
    end_op();
    8000528c:	b6ffe0ef          	jal	80003dfa <end_op>
    return -1;
    80005290:	557d                	li	a0,-1
    80005292:	bfcd                	j	80005284 <sys_mkdir+0x38>

0000000080005294 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005294:	7135                	addi	sp,sp,-160
    80005296:	ed06                	sd	ra,152(sp)
    80005298:	e922                	sd	s0,144(sp)
    8000529a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000529c:	af5fe0ef          	jal	80003d90 <begin_op>
  argint(1, &major);
    800052a0:	f6c40593          	addi	a1,s0,-148
    800052a4:	4505                	li	a0,1
    800052a6:	e40fd0ef          	jal	800028e6 <argint>
  argint(2, &minor);
    800052aa:	f6840593          	addi	a1,s0,-152
    800052ae:	4509                	li	a0,2
    800052b0:	e36fd0ef          	jal	800028e6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800052b4:	08000613          	li	a2,128
    800052b8:	f7040593          	addi	a1,s0,-144
    800052bc:	4501                	li	a0,0
    800052be:	e60fd0ef          	jal	8000291e <argstr>
    800052c2:	02054563          	bltz	a0,800052ec <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800052c6:	f6841683          	lh	a3,-152(s0)
    800052ca:	f6c41603          	lh	a2,-148(s0)
    800052ce:	458d                	li	a1,3
    800052d0:	f7040513          	addi	a0,s0,-144
    800052d4:	8fdff0ef          	jal	80004bd0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800052d8:	c911                	beqz	a0,800052ec <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800052da:	c0efe0ef          	jal	800036e8 <iunlockput>
  end_op();
    800052de:	b1dfe0ef          	jal	80003dfa <end_op>
  return 0;
    800052e2:	4501                	li	a0,0
}
    800052e4:	60ea                	ld	ra,152(sp)
    800052e6:	644a                	ld	s0,144(sp)
    800052e8:	610d                	addi	sp,sp,160
    800052ea:	8082                	ret
    end_op();
    800052ec:	b0ffe0ef          	jal	80003dfa <end_op>
    return -1;
    800052f0:	557d                	li	a0,-1
    800052f2:	bfcd                	j	800052e4 <sys_mknod+0x50>

00000000800052f4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800052f4:	7135                	addi	sp,sp,-160
    800052f6:	ed06                	sd	ra,152(sp)
    800052f8:	e922                	sd	s0,144(sp)
    800052fa:	e14a                	sd	s2,128(sp)
    800052fc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800052fe:	ddefc0ef          	jal	800018dc <myproc>
    80005302:	892a                	mv	s2,a0
  
  begin_op();
    80005304:	a8dfe0ef          	jal	80003d90 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005308:	08000613          	li	a2,128
    8000530c:	f6040593          	addi	a1,s0,-160
    80005310:	4501                	li	a0,0
    80005312:	e0cfd0ef          	jal	8000291e <argstr>
    80005316:	04054363          	bltz	a0,8000535c <sys_chdir+0x68>
    8000531a:	e526                	sd	s1,136(sp)
    8000531c:	f6040513          	addi	a0,s0,-160
    80005320:	8affe0ef          	jal	80003bce <namei>
    80005324:	84aa                	mv	s1,a0
    80005326:	c915                	beqz	a0,8000535a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005328:	9b6fe0ef          	jal	800034de <ilock>
  if(ip->type != T_DIR){
    8000532c:	04449703          	lh	a4,68(s1)
    80005330:	4785                	li	a5,1
    80005332:	02f71963          	bne	a4,a5,80005364 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005336:	8526                	mv	a0,s1
    80005338:	a54fe0ef          	jal	8000358c <iunlock>
  iput(p->cwd);
    8000533c:	15093503          	ld	a0,336(s2)
    80005340:	b20fe0ef          	jal	80003660 <iput>
  end_op();
    80005344:	ab7fe0ef          	jal	80003dfa <end_op>
  p->cwd = ip;
    80005348:	14993823          	sd	s1,336(s2)
  return 0;
    8000534c:	4501                	li	a0,0
    8000534e:	64aa                	ld	s1,136(sp)
}
    80005350:	60ea                	ld	ra,152(sp)
    80005352:	644a                	ld	s0,144(sp)
    80005354:	690a                	ld	s2,128(sp)
    80005356:	610d                	addi	sp,sp,160
    80005358:	8082                	ret
    8000535a:	64aa                	ld	s1,136(sp)
    end_op();
    8000535c:	a9ffe0ef          	jal	80003dfa <end_op>
    return -1;
    80005360:	557d                	li	a0,-1
    80005362:	b7fd                	j	80005350 <sys_chdir+0x5c>
    iunlockput(ip);
    80005364:	8526                	mv	a0,s1
    80005366:	b82fe0ef          	jal	800036e8 <iunlockput>
    end_op();
    8000536a:	a91fe0ef          	jal	80003dfa <end_op>
    return -1;
    8000536e:	557d                	li	a0,-1
    80005370:	64aa                	ld	s1,136(sp)
    80005372:	bff9                	j	80005350 <sys_chdir+0x5c>

0000000080005374 <sys_exec>:

uint64
sys_exec(void)
{
    80005374:	7105                	addi	sp,sp,-480
    80005376:	ef86                	sd	ra,472(sp)
    80005378:	eba2                	sd	s0,464(sp)
    8000537a:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000537c:	e2840593          	addi	a1,s0,-472
    80005380:	4505                	li	a0,1
    80005382:	d80fd0ef          	jal	80002902 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005386:	08000613          	li	a2,128
    8000538a:	f3040593          	addi	a1,s0,-208
    8000538e:	4501                	li	a0,0
    80005390:	d8efd0ef          	jal	8000291e <argstr>
    80005394:	87aa                	mv	a5,a0
    return -1;
    80005396:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005398:	0e07c063          	bltz	a5,80005478 <sys_exec+0x104>
    8000539c:	e7a6                	sd	s1,456(sp)
    8000539e:	e3ca                	sd	s2,448(sp)
    800053a0:	ff4e                	sd	s3,440(sp)
    800053a2:	fb52                	sd	s4,432(sp)
    800053a4:	f756                	sd	s5,424(sp)
    800053a6:	f35a                	sd	s6,416(sp)
    800053a8:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800053aa:	e3040a13          	addi	s4,s0,-464
    800053ae:	10000613          	li	a2,256
    800053b2:	4581                	li	a1,0
    800053b4:	8552                	mv	a0,s4
    800053b6:	919fb0ef          	jal	80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800053ba:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800053bc:	89d2                	mv	s3,s4
    800053be:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800053c0:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800053c4:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800053c6:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800053ca:	00391513          	slli	a0,s2,0x3
    800053ce:	85d6                	mv	a1,s5
    800053d0:	e2843783          	ld	a5,-472(s0)
    800053d4:	953e                	add	a0,a0,a5
    800053d6:	c86fd0ef          	jal	8000285c <fetchaddr>
    800053da:	02054663          	bltz	a0,80005406 <sys_exec+0x92>
    if(uarg == 0){
    800053de:	e2043783          	ld	a5,-480(s0)
    800053e2:	c7a1                	beqz	a5,8000542a <sys_exec+0xb6>
    argv[i] = kalloc();
    800053e4:	f46fb0ef          	jal	80000b2a <kalloc>
    800053e8:	85aa                	mv	a1,a0
    800053ea:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800053ee:	cd01                	beqz	a0,80005406 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800053f0:	865a                	mv	a2,s6
    800053f2:	e2043503          	ld	a0,-480(s0)
    800053f6:	cb0fd0ef          	jal	800028a6 <fetchstr>
    800053fa:	00054663          	bltz	a0,80005406 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    800053fe:	0905                	addi	s2,s2,1
    80005400:	09a1                	addi	s3,s3,8
    80005402:	fd7914e3          	bne	s2,s7,800053ca <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005406:	100a0a13          	addi	s4,s4,256
    8000540a:	6088                	ld	a0,0(s1)
    8000540c:	cd31                	beqz	a0,80005468 <sys_exec+0xf4>
    kfree(argv[i]);
    8000540e:	e3afb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005412:	04a1                	addi	s1,s1,8
    80005414:	ff449be3          	bne	s1,s4,8000540a <sys_exec+0x96>
  return -1;
    80005418:	557d                	li	a0,-1
    8000541a:	64be                	ld	s1,456(sp)
    8000541c:	691e                	ld	s2,448(sp)
    8000541e:	79fa                	ld	s3,440(sp)
    80005420:	7a5a                	ld	s4,432(sp)
    80005422:	7aba                	ld	s5,424(sp)
    80005424:	7b1a                	ld	s6,416(sp)
    80005426:	6bfa                	ld	s7,408(sp)
    80005428:	a881                	j	80005478 <sys_exec+0x104>
      argv[i] = 0;
    8000542a:	0009079b          	sext.w	a5,s2
    8000542e:	e3040593          	addi	a1,s0,-464
    80005432:	078e                	slli	a5,a5,0x3
    80005434:	97ae                	add	a5,a5,a1
    80005436:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    8000543a:	f3040513          	addi	a0,s0,-208
    8000543e:	ba4ff0ef          	jal	800047e2 <exec>
    80005442:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005444:	100a0a13          	addi	s4,s4,256
    80005448:	6088                	ld	a0,0(s1)
    8000544a:	c511                	beqz	a0,80005456 <sys_exec+0xe2>
    kfree(argv[i]);
    8000544c:	dfcfb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005450:	04a1                	addi	s1,s1,8
    80005452:	ff449be3          	bne	s1,s4,80005448 <sys_exec+0xd4>
  return ret;
    80005456:	854a                	mv	a0,s2
    80005458:	64be                	ld	s1,456(sp)
    8000545a:	691e                	ld	s2,448(sp)
    8000545c:	79fa                	ld	s3,440(sp)
    8000545e:	7a5a                	ld	s4,432(sp)
    80005460:	7aba                	ld	s5,424(sp)
    80005462:	7b1a                	ld	s6,416(sp)
    80005464:	6bfa                	ld	s7,408(sp)
    80005466:	a809                	j	80005478 <sys_exec+0x104>
  return -1;
    80005468:	557d                	li	a0,-1
    8000546a:	64be                	ld	s1,456(sp)
    8000546c:	691e                	ld	s2,448(sp)
    8000546e:	79fa                	ld	s3,440(sp)
    80005470:	7a5a                	ld	s4,432(sp)
    80005472:	7aba                	ld	s5,424(sp)
    80005474:	7b1a                	ld	s6,416(sp)
    80005476:	6bfa                	ld	s7,408(sp)
}
    80005478:	60fe                	ld	ra,472(sp)
    8000547a:	645e                	ld	s0,464(sp)
    8000547c:	613d                	addi	sp,sp,480
    8000547e:	8082                	ret

0000000080005480 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005480:	7139                	addi	sp,sp,-64
    80005482:	fc06                	sd	ra,56(sp)
    80005484:	f822                	sd	s0,48(sp)
    80005486:	f426                	sd	s1,40(sp)
    80005488:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000548a:	c52fc0ef          	jal	800018dc <myproc>
    8000548e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005490:	fd840593          	addi	a1,s0,-40
    80005494:	4501                	li	a0,0
    80005496:	c6cfd0ef          	jal	80002902 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000549a:	fc840593          	addi	a1,s0,-56
    8000549e:	fd040513          	addi	a0,s0,-48
    800054a2:	81eff0ef          	jal	800044c0 <pipealloc>
    return -1;
    800054a6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800054a8:	0a054463          	bltz	a0,80005550 <sys_pipe+0xd0>
  fd0 = -1;
    800054ac:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800054b0:	fd043503          	ld	a0,-48(s0)
    800054b4:	edeff0ef          	jal	80004b92 <fdalloc>
    800054b8:	fca42223          	sw	a0,-60(s0)
    800054bc:	08054163          	bltz	a0,8000553e <sys_pipe+0xbe>
    800054c0:	fc843503          	ld	a0,-56(s0)
    800054c4:	eceff0ef          	jal	80004b92 <fdalloc>
    800054c8:	fca42023          	sw	a0,-64(s0)
    800054cc:	06054063          	bltz	a0,8000552c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800054d0:	4691                	li	a3,4
    800054d2:	fc440613          	addi	a2,s0,-60
    800054d6:	fd843583          	ld	a1,-40(s0)
    800054da:	68a8                	ld	a0,80(s1)
    800054dc:	8a8fc0ef          	jal	80001584 <copyout>
    800054e0:	00054e63          	bltz	a0,800054fc <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800054e4:	4691                	li	a3,4
    800054e6:	fc040613          	addi	a2,s0,-64
    800054ea:	fd843583          	ld	a1,-40(s0)
    800054ee:	95b6                	add	a1,a1,a3
    800054f0:	68a8                	ld	a0,80(s1)
    800054f2:	892fc0ef          	jal	80001584 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800054f6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800054f8:	04055c63          	bgez	a0,80005550 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800054fc:	fc442783          	lw	a5,-60(s0)
    80005500:	07e9                	addi	a5,a5,26
    80005502:	078e                	slli	a5,a5,0x3
    80005504:	97a6                	add	a5,a5,s1
    80005506:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000550a:	fc042783          	lw	a5,-64(s0)
    8000550e:	07e9                	addi	a5,a5,26
    80005510:	078e                	slli	a5,a5,0x3
    80005512:	94be                	add	s1,s1,a5
    80005514:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005518:	fd043503          	ld	a0,-48(s0)
    8000551c:	c95fe0ef          	jal	800041b0 <fileclose>
    fileclose(wf);
    80005520:	fc843503          	ld	a0,-56(s0)
    80005524:	c8dfe0ef          	jal	800041b0 <fileclose>
    return -1;
    80005528:	57fd                	li	a5,-1
    8000552a:	a01d                	j	80005550 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000552c:	fc442783          	lw	a5,-60(s0)
    80005530:	0007c763          	bltz	a5,8000553e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005534:	07e9                	addi	a5,a5,26
    80005536:	078e                	slli	a5,a5,0x3
    80005538:	97a6                	add	a5,a5,s1
    8000553a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000553e:	fd043503          	ld	a0,-48(s0)
    80005542:	c6ffe0ef          	jal	800041b0 <fileclose>
    fileclose(wf);
    80005546:	fc843503          	ld	a0,-56(s0)
    8000554a:	c67fe0ef          	jal	800041b0 <fileclose>
    return -1;
    8000554e:	57fd                	li	a5,-1
}
    80005550:	853e                	mv	a0,a5
    80005552:	70e2                	ld	ra,56(sp)
    80005554:	7442                	ld	s0,48(sp)
    80005556:	74a2                	ld	s1,40(sp)
    80005558:	6121                	addi	sp,sp,64
    8000555a:	8082                	ret
    8000555c:	0000                	unimp
	...

0000000080005560 <kernelvec>:
    80005560:	7111                	addi	sp,sp,-256
    80005562:	e006                	sd	ra,0(sp)
    80005564:	e40a                	sd	sp,8(sp)
    80005566:	e80e                	sd	gp,16(sp)
    80005568:	ec12                	sd	tp,24(sp)
    8000556a:	f016                	sd	t0,32(sp)
    8000556c:	f41a                	sd	t1,40(sp)
    8000556e:	f81e                	sd	t2,48(sp)
    80005570:	e4aa                	sd	a0,72(sp)
    80005572:	e8ae                	sd	a1,80(sp)
    80005574:	ecb2                	sd	a2,88(sp)
    80005576:	f0b6                	sd	a3,96(sp)
    80005578:	f4ba                	sd	a4,104(sp)
    8000557a:	f8be                	sd	a5,112(sp)
    8000557c:	fcc2                	sd	a6,120(sp)
    8000557e:	e146                	sd	a7,128(sp)
    80005580:	edf2                	sd	t3,216(sp)
    80005582:	f1f6                	sd	t4,224(sp)
    80005584:	f5fa                	sd	t5,232(sp)
    80005586:	f9fe                	sd	t6,240(sp)
    80005588:	9e4fd0ef          	jal	8000276c <kerneltrap>
    8000558c:	6082                	ld	ra,0(sp)
    8000558e:	6122                	ld	sp,8(sp)
    80005590:	61c2                	ld	gp,16(sp)
    80005592:	7282                	ld	t0,32(sp)
    80005594:	7322                	ld	t1,40(sp)
    80005596:	73c2                	ld	t2,48(sp)
    80005598:	6526                	ld	a0,72(sp)
    8000559a:	65c6                	ld	a1,80(sp)
    8000559c:	6666                	ld	a2,88(sp)
    8000559e:	7686                	ld	a3,96(sp)
    800055a0:	7726                	ld	a4,104(sp)
    800055a2:	77c6                	ld	a5,112(sp)
    800055a4:	7866                	ld	a6,120(sp)
    800055a6:	688a                	ld	a7,128(sp)
    800055a8:	6e6e                	ld	t3,216(sp)
    800055aa:	7e8e                	ld	t4,224(sp)
    800055ac:	7f2e                	ld	t5,232(sp)
    800055ae:	7fce                	ld	t6,240(sp)
    800055b0:	6111                	addi	sp,sp,256
    800055b2:	10200073          	sret
	...

00000000800055be <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800055be:	1141                	addi	sp,sp,-16
    800055c0:	e406                	sd	ra,8(sp)
    800055c2:	e022                	sd	s0,0(sp)
    800055c4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800055c6:	0c000737          	lui	a4,0xc000
    800055ca:	4785                	li	a5,1
    800055cc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800055ce:	c35c                	sw	a5,4(a4)
}
    800055d0:	60a2                	ld	ra,8(sp)
    800055d2:	6402                	ld	s0,0(sp)
    800055d4:	0141                	addi	sp,sp,16
    800055d6:	8082                	ret

00000000800055d8 <plicinithart>:

void
plicinithart(void)
{
    800055d8:	1141                	addi	sp,sp,-16
    800055da:	e406                	sd	ra,8(sp)
    800055dc:	e022                	sd	s0,0(sp)
    800055de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800055e0:	ac8fc0ef          	jal	800018a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800055e4:	0085171b          	slliw	a4,a0,0x8
    800055e8:	0c0027b7          	lui	a5,0xc002
    800055ec:	97ba                	add	a5,a5,a4
    800055ee:	40200713          	li	a4,1026
    800055f2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800055f6:	00d5151b          	slliw	a0,a0,0xd
    800055fa:	0c2017b7          	lui	a5,0xc201
    800055fe:	97aa                	add	a5,a5,a0
    80005600:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005604:	60a2                	ld	ra,8(sp)
    80005606:	6402                	ld	s0,0(sp)
    80005608:	0141                	addi	sp,sp,16
    8000560a:	8082                	ret

000000008000560c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000560c:	1141                	addi	sp,sp,-16
    8000560e:	e406                	sd	ra,8(sp)
    80005610:	e022                	sd	s0,0(sp)
    80005612:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005614:	a94fc0ef          	jal	800018a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005618:	00d5151b          	slliw	a0,a0,0xd
    8000561c:	0c2017b7          	lui	a5,0xc201
    80005620:	97aa                	add	a5,a5,a0
  return irq;
}
    80005622:	43c8                	lw	a0,4(a5)
    80005624:	60a2                	ld	ra,8(sp)
    80005626:	6402                	ld	s0,0(sp)
    80005628:	0141                	addi	sp,sp,16
    8000562a:	8082                	ret

000000008000562c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000562c:	1101                	addi	sp,sp,-32
    8000562e:	ec06                	sd	ra,24(sp)
    80005630:	e822                	sd	s0,16(sp)
    80005632:	e426                	sd	s1,8(sp)
    80005634:	1000                	addi	s0,sp,32
    80005636:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005638:	a70fc0ef          	jal	800018a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000563c:	00d5179b          	slliw	a5,a0,0xd
    80005640:	0c201737          	lui	a4,0xc201
    80005644:	97ba                	add	a5,a5,a4
    80005646:	c3c4                	sw	s1,4(a5)
}
    80005648:	60e2                	ld	ra,24(sp)
    8000564a:	6442                	ld	s0,16(sp)
    8000564c:	64a2                	ld	s1,8(sp)
    8000564e:	6105                	addi	sp,sp,32
    80005650:	8082                	ret

0000000080005652 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005652:	1141                	addi	sp,sp,-16
    80005654:	e406                	sd	ra,8(sp)
    80005656:	e022                	sd	s0,0(sp)
    80005658:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000565a:	479d                	li	a5,7
    8000565c:	04a7ca63          	blt	a5,a0,800056b0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005660:	00025797          	auipc	a5,0x25
    80005664:	24078793          	addi	a5,a5,576 # 8002a8a0 <disk>
    80005668:	97aa                	add	a5,a5,a0
    8000566a:	0187c783          	lbu	a5,24(a5)
    8000566e:	e7b9                	bnez	a5,800056bc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005670:	00451693          	slli	a3,a0,0x4
    80005674:	00025797          	auipc	a5,0x25
    80005678:	22c78793          	addi	a5,a5,556 # 8002a8a0 <disk>
    8000567c:	6398                	ld	a4,0(a5)
    8000567e:	9736                	add	a4,a4,a3
    80005680:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005684:	6398                	ld	a4,0(a5)
    80005686:	9736                	add	a4,a4,a3
    80005688:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000568c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005690:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005694:	97aa                	add	a5,a5,a0
    80005696:	4705                	li	a4,1
    80005698:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000569c:	00025517          	auipc	a0,0x25
    800056a0:	21c50513          	addi	a0,a0,540 # 8002a8b8 <disk+0x18>
    800056a4:	9abfc0ef          	jal	8000204e <wakeup>
}
    800056a8:	60a2                	ld	ra,8(sp)
    800056aa:	6402                	ld	s0,0(sp)
    800056ac:	0141                	addi	sp,sp,16
    800056ae:	8082                	ret
    panic("free_desc 1");
    800056b0:	00002517          	auipc	a0,0x2
    800056b4:	08050513          	addi	a0,a0,128 # 80007730 <etext+0x730>
    800056b8:	8e6fb0ef          	jal	8000079e <panic>
    panic("free_desc 2");
    800056bc:	00002517          	auipc	a0,0x2
    800056c0:	08450513          	addi	a0,a0,132 # 80007740 <etext+0x740>
    800056c4:	8dafb0ef          	jal	8000079e <panic>

00000000800056c8 <virtio_disk_init>:
{
    800056c8:	1101                	addi	sp,sp,-32
    800056ca:	ec06                	sd	ra,24(sp)
    800056cc:	e822                	sd	s0,16(sp)
    800056ce:	e426                	sd	s1,8(sp)
    800056d0:	e04a                	sd	s2,0(sp)
    800056d2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800056d4:	00002597          	auipc	a1,0x2
    800056d8:	07c58593          	addi	a1,a1,124 # 80007750 <etext+0x750>
    800056dc:	00025517          	auipc	a0,0x25
    800056e0:	2ec50513          	addi	a0,a0,748 # 8002a9c8 <disk+0x128>
    800056e4:	c96fb0ef          	jal	80000b7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800056e8:	100017b7          	lui	a5,0x10001
    800056ec:	4398                	lw	a4,0(a5)
    800056ee:	2701                	sext.w	a4,a4
    800056f0:	747277b7          	lui	a5,0x74727
    800056f4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800056f8:	14f71863          	bne	a4,a5,80005848 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800056fc:	100017b7          	lui	a5,0x10001
    80005700:	43dc                	lw	a5,4(a5)
    80005702:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005704:	4709                	li	a4,2
    80005706:	14e79163          	bne	a5,a4,80005848 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000570a:	100017b7          	lui	a5,0x10001
    8000570e:	479c                	lw	a5,8(a5)
    80005710:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005712:	12e79b63          	bne	a5,a4,80005848 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005716:	100017b7          	lui	a5,0x10001
    8000571a:	47d8                	lw	a4,12(a5)
    8000571c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000571e:	554d47b7          	lui	a5,0x554d4
    80005722:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005726:	12f71163          	bne	a4,a5,80005848 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000572a:	100017b7          	lui	a5,0x10001
    8000572e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005732:	4705                	li	a4,1
    80005734:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005736:	470d                	li	a4,3
    80005738:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000573a:	10001737          	lui	a4,0x10001
    8000573e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005740:	c7ffe6b7          	lui	a3,0xc7ffe
    80005744:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd3d7f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005748:	8f75                	and	a4,a4,a3
    8000574a:	100016b7          	lui	a3,0x10001
    8000574e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005750:	472d                	li	a4,11
    80005752:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005754:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005758:	439c                	lw	a5,0(a5)
    8000575a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000575e:	8ba1                	andi	a5,a5,8
    80005760:	0e078a63          	beqz	a5,80005854 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005764:	100017b7          	lui	a5,0x10001
    80005768:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000576c:	43fc                	lw	a5,68(a5)
    8000576e:	2781                	sext.w	a5,a5
    80005770:	0e079863          	bnez	a5,80005860 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005774:	100017b7          	lui	a5,0x10001
    80005778:	5bdc                	lw	a5,52(a5)
    8000577a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000577c:	0e078863          	beqz	a5,8000586c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005780:	471d                	li	a4,7
    80005782:	0ef77b63          	bgeu	a4,a5,80005878 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005786:	ba4fb0ef          	jal	80000b2a <kalloc>
    8000578a:	00025497          	auipc	s1,0x25
    8000578e:	11648493          	addi	s1,s1,278 # 8002a8a0 <disk>
    80005792:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005794:	b96fb0ef          	jal	80000b2a <kalloc>
    80005798:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000579a:	b90fb0ef          	jal	80000b2a <kalloc>
    8000579e:	87aa                	mv	a5,a0
    800057a0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800057a2:	6088                	ld	a0,0(s1)
    800057a4:	0e050063          	beqz	a0,80005884 <virtio_disk_init+0x1bc>
    800057a8:	00025717          	auipc	a4,0x25
    800057ac:	10073703          	ld	a4,256(a4) # 8002a8a8 <disk+0x8>
    800057b0:	cb71                	beqz	a4,80005884 <virtio_disk_init+0x1bc>
    800057b2:	cbe9                	beqz	a5,80005884 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800057b4:	6605                	lui	a2,0x1
    800057b6:	4581                	li	a1,0
    800057b8:	d16fb0ef          	jal	80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    800057bc:	00025497          	auipc	s1,0x25
    800057c0:	0e448493          	addi	s1,s1,228 # 8002a8a0 <disk>
    800057c4:	6605                	lui	a2,0x1
    800057c6:	4581                	li	a1,0
    800057c8:	6488                	ld	a0,8(s1)
    800057ca:	d04fb0ef          	jal	80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    800057ce:	6605                	lui	a2,0x1
    800057d0:	4581                	li	a1,0
    800057d2:	6888                	ld	a0,16(s1)
    800057d4:	cfafb0ef          	jal	80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800057d8:	100017b7          	lui	a5,0x10001
    800057dc:	4721                	li	a4,8
    800057de:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800057e0:	4098                	lw	a4,0(s1)
    800057e2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800057e6:	40d8                	lw	a4,4(s1)
    800057e8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800057ec:	649c                	ld	a5,8(s1)
    800057ee:	0007869b          	sext.w	a3,a5
    800057f2:	10001737          	lui	a4,0x10001
    800057f6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800057fa:	9781                	srai	a5,a5,0x20
    800057fc:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005800:	689c                	ld	a5,16(s1)
    80005802:	0007869b          	sext.w	a3,a5
    80005806:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000580a:	9781                	srai	a5,a5,0x20
    8000580c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005810:	4785                	li	a5,1
    80005812:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005814:	00f48c23          	sb	a5,24(s1)
    80005818:	00f48ca3          	sb	a5,25(s1)
    8000581c:	00f48d23          	sb	a5,26(s1)
    80005820:	00f48da3          	sb	a5,27(s1)
    80005824:	00f48e23          	sb	a5,28(s1)
    80005828:	00f48ea3          	sb	a5,29(s1)
    8000582c:	00f48f23          	sb	a5,30(s1)
    80005830:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005834:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005838:	07272823          	sw	s2,112(a4)
}
    8000583c:	60e2                	ld	ra,24(sp)
    8000583e:	6442                	ld	s0,16(sp)
    80005840:	64a2                	ld	s1,8(sp)
    80005842:	6902                	ld	s2,0(sp)
    80005844:	6105                	addi	sp,sp,32
    80005846:	8082                	ret
    panic("could not find virtio disk");
    80005848:	00002517          	auipc	a0,0x2
    8000584c:	f1850513          	addi	a0,a0,-232 # 80007760 <etext+0x760>
    80005850:	f4ffa0ef          	jal	8000079e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005854:	00002517          	auipc	a0,0x2
    80005858:	f2c50513          	addi	a0,a0,-212 # 80007780 <etext+0x780>
    8000585c:	f43fa0ef          	jal	8000079e <panic>
    panic("virtio disk should not be ready");
    80005860:	00002517          	auipc	a0,0x2
    80005864:	f4050513          	addi	a0,a0,-192 # 800077a0 <etext+0x7a0>
    80005868:	f37fa0ef          	jal	8000079e <panic>
    panic("virtio disk has no queue 0");
    8000586c:	00002517          	auipc	a0,0x2
    80005870:	f5450513          	addi	a0,a0,-172 # 800077c0 <etext+0x7c0>
    80005874:	f2bfa0ef          	jal	8000079e <panic>
    panic("virtio disk max queue too short");
    80005878:	00002517          	auipc	a0,0x2
    8000587c:	f6850513          	addi	a0,a0,-152 # 800077e0 <etext+0x7e0>
    80005880:	f1ffa0ef          	jal	8000079e <panic>
    panic("virtio disk kalloc");
    80005884:	00002517          	auipc	a0,0x2
    80005888:	f7c50513          	addi	a0,a0,-132 # 80007800 <etext+0x800>
    8000588c:	f13fa0ef          	jal	8000079e <panic>

0000000080005890 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005890:	711d                	addi	sp,sp,-96
    80005892:	ec86                	sd	ra,88(sp)
    80005894:	e8a2                	sd	s0,80(sp)
    80005896:	e4a6                	sd	s1,72(sp)
    80005898:	e0ca                	sd	s2,64(sp)
    8000589a:	fc4e                	sd	s3,56(sp)
    8000589c:	f852                	sd	s4,48(sp)
    8000589e:	f456                	sd	s5,40(sp)
    800058a0:	f05a                	sd	s6,32(sp)
    800058a2:	ec5e                	sd	s7,24(sp)
    800058a4:	e862                	sd	s8,16(sp)
    800058a6:	1080                	addi	s0,sp,96
    800058a8:	89aa                	mv	s3,a0
    800058aa:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800058ac:	00c52b83          	lw	s7,12(a0)
    800058b0:	001b9b9b          	slliw	s7,s7,0x1
    800058b4:	1b82                	slli	s7,s7,0x20
    800058b6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800058ba:	00025517          	auipc	a0,0x25
    800058be:	10e50513          	addi	a0,a0,270 # 8002a9c8 <disk+0x128>
    800058c2:	b3cfb0ef          	jal	80000bfe <acquire>
  for(int i = 0; i < NUM; i++){
    800058c6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800058c8:	00025a97          	auipc	s5,0x25
    800058cc:	fd8a8a93          	addi	s5,s5,-40 # 8002a8a0 <disk>
  for(int i = 0; i < 3; i++){
    800058d0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800058d2:	5c7d                	li	s8,-1
    800058d4:	a095                	j	80005938 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800058d6:	00fa8733          	add	a4,s5,a5
    800058da:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800058de:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800058e0:	0207c563          	bltz	a5,8000590a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    800058e4:	2905                	addiw	s2,s2,1
    800058e6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800058e8:	05490c63          	beq	s2,s4,80005940 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800058ec:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800058ee:	00025717          	auipc	a4,0x25
    800058f2:	fb270713          	addi	a4,a4,-78 # 8002a8a0 <disk>
    800058f6:	4781                	li	a5,0
    if(disk.free[i]){
    800058f8:	01874683          	lbu	a3,24(a4)
    800058fc:	fee9                	bnez	a3,800058d6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    800058fe:	2785                	addiw	a5,a5,1
    80005900:	0705                	addi	a4,a4,1
    80005902:	fe979be3          	bne	a5,s1,800058f8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005906:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000590a:	01205d63          	blez	s2,80005924 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000590e:	fa042503          	lw	a0,-96(s0)
    80005912:	d41ff0ef          	jal	80005652 <free_desc>
      for(int j = 0; j < i; j++)
    80005916:	4785                	li	a5,1
    80005918:	0127d663          	bge	a5,s2,80005924 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000591c:	fa442503          	lw	a0,-92(s0)
    80005920:	d33ff0ef          	jal	80005652 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005924:	00025597          	auipc	a1,0x25
    80005928:	0a458593          	addi	a1,a1,164 # 8002a9c8 <disk+0x128>
    8000592c:	00025517          	auipc	a0,0x25
    80005930:	f8c50513          	addi	a0,a0,-116 # 8002a8b8 <disk+0x18>
    80005934:	ecefc0ef          	jal	80002002 <sleep>
  for(int i = 0; i < 3; i++){
    80005938:	fa040613          	addi	a2,s0,-96
    8000593c:	4901                	li	s2,0
    8000593e:	b77d                	j	800058ec <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005940:	fa042503          	lw	a0,-96(s0)
    80005944:	00451693          	slli	a3,a0,0x4

  if(write)
    80005948:	00025797          	auipc	a5,0x25
    8000594c:	f5878793          	addi	a5,a5,-168 # 8002a8a0 <disk>
    80005950:	00a50713          	addi	a4,a0,10
    80005954:	0712                	slli	a4,a4,0x4
    80005956:	973e                	add	a4,a4,a5
    80005958:	01603633          	snez	a2,s6
    8000595c:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000595e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005962:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005966:	6398                	ld	a4,0(a5)
    80005968:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000596a:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    8000596e:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005970:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005972:	6390                	ld	a2,0(a5)
    80005974:	00d605b3          	add	a1,a2,a3
    80005978:	4741                	li	a4,16
    8000597a:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000597c:	4805                	li	a6,1
    8000597e:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005982:	fa442703          	lw	a4,-92(s0)
    80005986:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000598a:	0712                	slli	a4,a4,0x4
    8000598c:	963a                	add	a2,a2,a4
    8000598e:	05898593          	addi	a1,s3,88
    80005992:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005994:	0007b883          	ld	a7,0(a5)
    80005998:	9746                	add	a4,a4,a7
    8000599a:	40000613          	li	a2,1024
    8000599e:	c710                	sw	a2,8(a4)
  if(write)
    800059a0:	001b3613          	seqz	a2,s6
    800059a4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800059a8:	01066633          	or	a2,a2,a6
    800059ac:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800059b0:	fa842583          	lw	a1,-88(s0)
    800059b4:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800059b8:	00250613          	addi	a2,a0,2
    800059bc:	0612                	slli	a2,a2,0x4
    800059be:	963e                	add	a2,a2,a5
    800059c0:	577d                	li	a4,-1
    800059c2:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800059c6:	0592                	slli	a1,a1,0x4
    800059c8:	98ae                	add	a7,a7,a1
    800059ca:	03068713          	addi	a4,a3,48
    800059ce:	973e                	add	a4,a4,a5
    800059d0:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800059d4:	6398                	ld	a4,0(a5)
    800059d6:	972e                	add	a4,a4,a1
    800059d8:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800059dc:	4689                	li	a3,2
    800059de:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800059e2:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800059e6:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    800059ea:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800059ee:	6794                	ld	a3,8(a5)
    800059f0:	0026d703          	lhu	a4,2(a3)
    800059f4:	8b1d                	andi	a4,a4,7
    800059f6:	0706                	slli	a4,a4,0x1
    800059f8:	96ba                	add	a3,a3,a4
    800059fa:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800059fe:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005a02:	6798                	ld	a4,8(a5)
    80005a04:	00275783          	lhu	a5,2(a4)
    80005a08:	2785                	addiw	a5,a5,1
    80005a0a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005a0e:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005a12:	100017b7          	lui	a5,0x10001
    80005a16:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005a1a:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005a1e:	00025917          	auipc	s2,0x25
    80005a22:	faa90913          	addi	s2,s2,-86 # 8002a9c8 <disk+0x128>
  while(b->disk == 1) {
    80005a26:	84c2                	mv	s1,a6
    80005a28:	01079a63          	bne	a5,a6,80005a3c <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    80005a2c:	85ca                	mv	a1,s2
    80005a2e:	854e                	mv	a0,s3
    80005a30:	dd2fc0ef          	jal	80002002 <sleep>
  while(b->disk == 1) {
    80005a34:	0049a783          	lw	a5,4(s3)
    80005a38:	fe978ae3          	beq	a5,s1,80005a2c <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    80005a3c:	fa042903          	lw	s2,-96(s0)
    80005a40:	00290713          	addi	a4,s2,2
    80005a44:	0712                	slli	a4,a4,0x4
    80005a46:	00025797          	auipc	a5,0x25
    80005a4a:	e5a78793          	addi	a5,a5,-422 # 8002a8a0 <disk>
    80005a4e:	97ba                	add	a5,a5,a4
    80005a50:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005a54:	00025997          	auipc	s3,0x25
    80005a58:	e4c98993          	addi	s3,s3,-436 # 8002a8a0 <disk>
    80005a5c:	00491713          	slli	a4,s2,0x4
    80005a60:	0009b783          	ld	a5,0(s3)
    80005a64:	97ba                	add	a5,a5,a4
    80005a66:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005a6a:	854a                	mv	a0,s2
    80005a6c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005a70:	be3ff0ef          	jal	80005652 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005a74:	8885                	andi	s1,s1,1
    80005a76:	f0fd                	bnez	s1,80005a5c <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005a78:	00025517          	auipc	a0,0x25
    80005a7c:	f5050513          	addi	a0,a0,-176 # 8002a9c8 <disk+0x128>
    80005a80:	a12fb0ef          	jal	80000c92 <release>
}
    80005a84:	60e6                	ld	ra,88(sp)
    80005a86:	6446                	ld	s0,80(sp)
    80005a88:	64a6                	ld	s1,72(sp)
    80005a8a:	6906                	ld	s2,64(sp)
    80005a8c:	79e2                	ld	s3,56(sp)
    80005a8e:	7a42                	ld	s4,48(sp)
    80005a90:	7aa2                	ld	s5,40(sp)
    80005a92:	7b02                	ld	s6,32(sp)
    80005a94:	6be2                	ld	s7,24(sp)
    80005a96:	6c42                	ld	s8,16(sp)
    80005a98:	6125                	addi	sp,sp,96
    80005a9a:	8082                	ret

0000000080005a9c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005a9c:	1101                	addi	sp,sp,-32
    80005a9e:	ec06                	sd	ra,24(sp)
    80005aa0:	e822                	sd	s0,16(sp)
    80005aa2:	e426                	sd	s1,8(sp)
    80005aa4:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005aa6:	00025497          	auipc	s1,0x25
    80005aaa:	dfa48493          	addi	s1,s1,-518 # 8002a8a0 <disk>
    80005aae:	00025517          	auipc	a0,0x25
    80005ab2:	f1a50513          	addi	a0,a0,-230 # 8002a9c8 <disk+0x128>
    80005ab6:	948fb0ef          	jal	80000bfe <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005aba:	100017b7          	lui	a5,0x10001
    80005abe:	53bc                	lw	a5,96(a5)
    80005ac0:	8b8d                	andi	a5,a5,3
    80005ac2:	10001737          	lui	a4,0x10001
    80005ac6:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005ac8:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005acc:	689c                	ld	a5,16(s1)
    80005ace:	0204d703          	lhu	a4,32(s1)
    80005ad2:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005ad6:	04f70663          	beq	a4,a5,80005b22 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005ada:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005ade:	6898                	ld	a4,16(s1)
    80005ae0:	0204d783          	lhu	a5,32(s1)
    80005ae4:	8b9d                	andi	a5,a5,7
    80005ae6:	078e                	slli	a5,a5,0x3
    80005ae8:	97ba                	add	a5,a5,a4
    80005aea:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005aec:	00278713          	addi	a4,a5,2
    80005af0:	0712                	slli	a4,a4,0x4
    80005af2:	9726                	add	a4,a4,s1
    80005af4:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005af8:	e321                	bnez	a4,80005b38 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005afa:	0789                	addi	a5,a5,2
    80005afc:	0792                	slli	a5,a5,0x4
    80005afe:	97a6                	add	a5,a5,s1
    80005b00:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005b02:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005b06:	d48fc0ef          	jal	8000204e <wakeup>

    disk.used_idx += 1;
    80005b0a:	0204d783          	lhu	a5,32(s1)
    80005b0e:	2785                	addiw	a5,a5,1
    80005b10:	17c2                	slli	a5,a5,0x30
    80005b12:	93c1                	srli	a5,a5,0x30
    80005b14:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005b18:	6898                	ld	a4,16(s1)
    80005b1a:	00275703          	lhu	a4,2(a4)
    80005b1e:	faf71ee3          	bne	a4,a5,80005ada <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005b22:	00025517          	auipc	a0,0x25
    80005b26:	ea650513          	addi	a0,a0,-346 # 8002a9c8 <disk+0x128>
    80005b2a:	968fb0ef          	jal	80000c92 <release>
}
    80005b2e:	60e2                	ld	ra,24(sp)
    80005b30:	6442                	ld	s0,16(sp)
    80005b32:	64a2                	ld	s1,8(sp)
    80005b34:	6105                	addi	sp,sp,32
    80005b36:	8082                	ret
      panic("virtio_disk_intr status");
    80005b38:	00002517          	auipc	a0,0x2
    80005b3c:	ce050513          	addi	a0,a0,-800 # 80007818 <etext+0x818>
    80005b40:	c5ffa0ef          	jal	8000079e <panic>
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
