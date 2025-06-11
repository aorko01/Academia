
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
    80000106:	4c8020ef          	jal	800025ce <either_copyin>
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
    80000196:	2d0020ef          	jal	80002466 <killed>
    8000019a:	e12d                	bnez	a0,800001fc <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    8000019c:	85a6                	mv	a1,s1
    8000019e:	854a                	mv	a0,s2
    800001a0:	08e020ef          	jal	8000222e <sleep>
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
    800001e4:	3a0020ef          	jal	80002584 <either_copyout>
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
    800002ae:	36a020ef          	jal	80002618 <procdump>
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
    800003fa:	681010ef          	jal	8000227a <wakeup>
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
    80000906:	175010ef          	jal	8000227a <wakeup>
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
    8000099a:	095010ef          	jal	8000222e <sleep>
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
    80000eba:	091010ef          	jal	8000274a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	15b040ef          	jal	80005818 <plicinithart>
  }

  scheduler();        
    80000ec2:	6c7000ef          	jal	80001d88 <scheduler>
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
    80000f02:	025010ef          	jal	80002726 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f06:	045010ef          	jal	8000274a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f0a:	0f5040ef          	jal	800057fe <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f0e:	10b040ef          	jal	80005818 <plicinithart>
    binit();         // buffer cache
    80000f12:	074020ef          	jal	80002f86 <binit>
    iinit();         // inode table
    80000f16:	640020ef          	jal	80003556 <iinit>
    fileinit();      // file table
    80000f1a:	40e030ef          	jal	80004328 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1e:	1eb040ef          	jal	80005908 <virtio_disk_init>
    userinit();      // first user process
    80000f22:	48f000ef          	jal	80001bb0 <userinit>
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
    80001926:	641000ef          	jal	80002766 <usertrapret>
}
    8000192a:	60a2                	ld	ra,8(sp)
    8000192c:	6402                	ld	s0,0(sp)
    8000192e:	0141                	addi	sp,sp,16
    80001930:	8082                	ret
    fsinit(ROOTDEV);
    80001932:	4505                	li	a0,1
    80001934:	3b7010ef          	jal	800034ea <fsinit>
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
    80001964:	0c878793          	addi	a5,a5,200 # 80007a28 <nextpid>
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
    80001aae:	55648493          	addi	s1,s1,1366 # 80010000 <proc>
    80001ab2:	0001e917          	auipc	s2,0x1e
    80001ab6:	b4e90913          	addi	s2,s2,-1202 # 8001f600 <tickslock>
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
    80001ad4:	a04d                	j	80001b76 <allocproc+0xd8>
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
    80001aea:	d6a98993          	addi	s3,s3,-662 # 80007850 <syscall_names+0x8>
    80001aee:	18048913          	addi	s2,s1,384
    80001af2:	00006a17          	auipc	s4,0x6
    80001af6:	e1ea0a13          	addi	s4,s4,-482 # 80007910 <states.0>
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
  p->inq = 1;
    80001b22:	4785                	li	a5,1
    80001b24:	3cf4a423          	sw	a5,968(s1)
  p->curr_runtime = 0;
    80001b28:	3c04a823          	sw	zero,976(s1)
  p->time_slices = 0;
    80001b2c:	3c04a623          	sw	zero,972(s1)
  p->Original_tickets = DEFAULT_TICKET_COUNT;
    80001b30:	47a9                	li	a5,10
    80001b32:	3cf4a023          	sw	a5,960(s1)
  p->Current_tickets = DEFAULT_TICKET_COUNT;
    80001b36:	3cf4a223          	sw	a5,964(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001b3a:	ff1fe0ef          	jal	80000b2a <kalloc>
    80001b3e:	892a                	mv	s2,a0
    80001b40:	eca8                	sd	a0,88(s1)
    80001b42:	c129                	beqz	a0,80001b84 <allocproc+0xe6>
  p->pagetable = proc_pagetable(p);
    80001b44:	8526                	mv	a0,s1
    80001b46:	e3fff0ef          	jal	80001984 <proc_pagetable>
    80001b4a:	892a                	mv	s2,a0
    80001b4c:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001b4e:	c531                	beqz	a0,80001b9a <allocproc+0xfc>
  memset(&p->context, 0, sizeof(p->context));
    80001b50:	07000613          	li	a2,112
    80001b54:	4581                	li	a1,0
    80001b56:	06048513          	addi	a0,s1,96
    80001b5a:	974ff0ef          	jal	80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001b5e:	00000797          	auipc	a5,0x0
    80001b62:	dae78793          	addi	a5,a5,-594 # 8000190c <forkret>
    80001b66:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b68:	60bc                	ld	a5,64(s1)
    80001b6a:	6705                	lui	a4,0x1
    80001b6c:	97ba                	add	a5,a5,a4
    80001b6e:	f4bc                	sd	a5,104(s1)
    80001b70:	69e2                	ld	s3,24(sp)
    80001b72:	6a42                	ld	s4,16(sp)
    80001b74:	6aa2                	ld	s5,8(sp)
}
    80001b76:	8526                	mv	a0,s1
    80001b78:	70e2                	ld	ra,56(sp)
    80001b7a:	7442                	ld	s0,48(sp)
    80001b7c:	74a2                	ld	s1,40(sp)
    80001b7e:	7902                	ld	s2,32(sp)
    80001b80:	6121                	addi	sp,sp,64
    80001b82:	8082                	ret
    freeproc(p);
    80001b84:	8526                	mv	a0,s1
    80001b86:	ec9ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	906ff0ef          	jal	80000c92 <release>
    return 0;
    80001b90:	84ca                	mv	s1,s2
    80001b92:	69e2                	ld	s3,24(sp)
    80001b94:	6a42                	ld	s4,16(sp)
    80001b96:	6aa2                	ld	s5,8(sp)
    80001b98:	bff9                	j	80001b76 <allocproc+0xd8>
    freeproc(p);
    80001b9a:	8526                	mv	a0,s1
    80001b9c:	eb3ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001ba0:	8526                	mv	a0,s1
    80001ba2:	8f0ff0ef          	jal	80000c92 <release>
    return 0;
    80001ba6:	84ca                	mv	s1,s2
    80001ba8:	69e2                	ld	s3,24(sp)
    80001baa:	6a42                	ld	s4,16(sp)
    80001bac:	6aa2                	ld	s5,8(sp)
    80001bae:	b7e1                	j	80001b76 <allocproc+0xd8>

0000000080001bb0 <userinit>:
{
    80001bb0:	1101                	addi	sp,sp,-32
    80001bb2:	ec06                	sd	ra,24(sp)
    80001bb4:	e822                	sd	s0,16(sp)
    80001bb6:	e426                	sd	s1,8(sp)
    80001bb8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bba:	ee5ff0ef          	jal	80001a9e <allocproc>
    80001bbe:	84aa                	mv	s1,a0
  initproc = p;
    80001bc0:	00006797          	auipc	a5,0x6
    80001bc4:	eea7b023          	sd	a0,-288(a5) # 80007aa0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001bc8:	03400613          	li	a2,52
    80001bcc:	00006597          	auipc	a1,0x6
    80001bd0:	e6458593          	addi	a1,a1,-412 # 80007a30 <initcode>
    80001bd4:	6928                	ld	a0,80(a0)
    80001bd6:	eecff0ef          	jal	800012c2 <uvmfirst>
  p->sz = PGSIZE;
    80001bda:	6785                	lui	a5,0x1
    80001bdc:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001bde:	6cb8                	ld	a4,88(s1)
    80001be0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001be4:	6cb8                	ld	a4,88(s1)
    80001be6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001be8:	4641                	li	a2,16
    80001bea:	00005597          	auipc	a1,0x5
    80001bee:	63658593          	addi	a1,a1,1590 # 80007220 <etext+0x220>
    80001bf2:	15848513          	addi	a0,s1,344
    80001bf6:	a2aff0ef          	jal	80000e20 <safestrcpy>
  p->cwd = namei("/");
    80001bfa:	00005517          	auipc	a0,0x5
    80001bfe:	63650513          	addi	a0,a0,1590 # 80007230 <etext+0x230>
    80001c02:	20c020ef          	jal	80003e0e <namei>
    80001c06:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c0a:	478d                	li	a5,3
    80001c0c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c0e:	8526                	mv	a0,s1
    80001c10:	882ff0ef          	jal	80000c92 <release>
}
    80001c14:	60e2                	ld	ra,24(sp)
    80001c16:	6442                	ld	s0,16(sp)
    80001c18:	64a2                	ld	s1,8(sp)
    80001c1a:	6105                	addi	sp,sp,32
    80001c1c:	8082                	ret

0000000080001c1e <growproc>:
{
    80001c1e:	1101                	addi	sp,sp,-32
    80001c20:	ec06                	sd	ra,24(sp)
    80001c22:	e822                	sd	s0,16(sp)
    80001c24:	e426                	sd	s1,8(sp)
    80001c26:	e04a                	sd	s2,0(sp)
    80001c28:	1000                	addi	s0,sp,32
    80001c2a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001c2c:	cb1ff0ef          	jal	800018dc <myproc>
    80001c30:	84aa                	mv	s1,a0
  sz = p->sz;
    80001c32:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001c34:	01204c63          	bgtz	s2,80001c4c <growproc+0x2e>
  else if (n < 0)
    80001c38:	02094463          	bltz	s2,80001c60 <growproc+0x42>
  p->sz = sz;
    80001c3c:	e4ac                	sd	a1,72(s1)
  return 0;
    80001c3e:	4501                	li	a0,0
}
    80001c40:	60e2                	ld	ra,24(sp)
    80001c42:	6442                	ld	s0,16(sp)
    80001c44:	64a2                	ld	s1,8(sp)
    80001c46:	6902                	ld	s2,0(sp)
    80001c48:	6105                	addi	sp,sp,32
    80001c4a:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001c4c:	4691                	li	a3,4
    80001c4e:	00b90633          	add	a2,s2,a1
    80001c52:	6928                	ld	a0,80(a0)
    80001c54:	f10ff0ef          	jal	80001364 <uvmalloc>
    80001c58:	85aa                	mv	a1,a0
    80001c5a:	f16d                	bnez	a0,80001c3c <growproc+0x1e>
      return -1;
    80001c5c:	557d                	li	a0,-1
    80001c5e:	b7cd                	j	80001c40 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c60:	00b90633          	add	a2,s2,a1
    80001c64:	6928                	ld	a0,80(a0)
    80001c66:	ebaff0ef          	jal	80001320 <uvmdealloc>
    80001c6a:	85aa                	mv	a1,a0
    80001c6c:	bfc1                	j	80001c3c <growproc+0x1e>

0000000080001c6e <fork>:
{
    80001c6e:	7139                	addi	sp,sp,-64
    80001c70:	fc06                	sd	ra,56(sp)
    80001c72:	f822                	sd	s0,48(sp)
    80001c74:	f04a                	sd	s2,32(sp)
    80001c76:	e456                	sd	s5,8(sp)
    80001c78:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c7a:	c63ff0ef          	jal	800018dc <myproc>
    80001c7e:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001c80:	e1fff0ef          	jal	80001a9e <allocproc>
    80001c84:	10050063          	beqz	a0,80001d84 <fork+0x116>
    80001c88:	ec4e                	sd	s3,24(sp)
    80001c8a:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001c8c:	048ab603          	ld	a2,72(s5)
    80001c90:	692c                	ld	a1,80(a0)
    80001c92:	050ab503          	ld	a0,80(s5)
    80001c96:	80fff0ef          	jal	800014a4 <uvmcopy>
    80001c9a:	04054a63          	bltz	a0,80001cee <fork+0x80>
    80001c9e:	f426                	sd	s1,40(sp)
    80001ca0:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001ca2:	048ab783          	ld	a5,72(s5)
    80001ca6:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001caa:	058ab683          	ld	a3,88(s5)
    80001cae:	87b6                	mv	a5,a3
    80001cb0:	0589b703          	ld	a4,88(s3)
    80001cb4:	12068693          	addi	a3,a3,288
    80001cb8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001cbc:	6788                	ld	a0,8(a5)
    80001cbe:	6b8c                	ld	a1,16(a5)
    80001cc0:	6f90                	ld	a2,24(a5)
    80001cc2:	01073023          	sd	a6,0(a4)
    80001cc6:	e708                	sd	a0,8(a4)
    80001cc8:	eb0c                	sd	a1,16(a4)
    80001cca:	ef10                	sd	a2,24(a4)
    80001ccc:	02078793          	addi	a5,a5,32
    80001cd0:	02070713          	addi	a4,a4,32
    80001cd4:	fed792e3          	bne	a5,a3,80001cb8 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001cd8:	0589b783          	ld	a5,88(s3)
    80001cdc:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001ce0:	0d0a8493          	addi	s1,s5,208
    80001ce4:	0d098913          	addi	s2,s3,208
    80001ce8:	150a8a13          	addi	s4,s5,336
    80001cec:	a831                	j	80001d08 <fork+0x9a>
    freeproc(np);
    80001cee:	854e                	mv	a0,s3
    80001cf0:	d5fff0ef          	jal	80001a4e <freeproc>
    release(&np->lock);
    80001cf4:	854e                	mv	a0,s3
    80001cf6:	f9dfe0ef          	jal	80000c92 <release>
    return -1;
    80001cfa:	597d                	li	s2,-1
    80001cfc:	69e2                	ld	s3,24(sp)
    80001cfe:	a8a5                	j	80001d76 <fork+0x108>
  for (i = 0; i < NOFILE; i++)
    80001d00:	04a1                	addi	s1,s1,8
    80001d02:	0921                	addi	s2,s2,8
    80001d04:	01448963          	beq	s1,s4,80001d16 <fork+0xa8>
    if (p->ofile[i])
    80001d08:	6088                	ld	a0,0(s1)
    80001d0a:	d97d                	beqz	a0,80001d00 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d0c:	69e020ef          	jal	800043aa <filedup>
    80001d10:	00a93023          	sd	a0,0(s2)
    80001d14:	b7f5                	j	80001d00 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001d16:	150ab503          	ld	a0,336(s5)
    80001d1a:	1cf010ef          	jal	800036e8 <idup>
    80001d1e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d22:	4641                	li	a2,16
    80001d24:	158a8593          	addi	a1,s5,344
    80001d28:	15898513          	addi	a0,s3,344
    80001d2c:	8f4ff0ef          	jal	80000e20 <safestrcpy>
  pid = np->pid;
    80001d30:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001d34:	854e                	mv	a0,s3
    80001d36:	f5dfe0ef          	jal	80000c92 <release>
  acquire(&wait_lock);
    80001d3a:	0000e497          	auipc	s1,0xe
    80001d3e:	eae48493          	addi	s1,s1,-338 # 8000fbe8 <wait_lock>
    80001d42:	8526                	mv	a0,s1
    80001d44:	ebbfe0ef          	jal	80000bfe <acquire>
  np->parent = p;
    80001d48:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d4c:	8526                	mv	a0,s1
    80001d4e:	f45fe0ef          	jal	80000c92 <release>
  acquire(&np->lock);
    80001d52:	854e                	mv	a0,s3
    80001d54:	eabfe0ef          	jal	80000bfe <acquire>
  np->state = RUNNABLE;
    80001d58:	478d                	li	a5,3
    80001d5a:	00f9ac23          	sw	a5,24(s3)
  np->Current_tickets = p->Original_tickets;
    80001d5e:	3c0aa783          	lw	a5,960(s5)
    80001d62:	3cf9a223          	sw	a5,964(s3)
  np->Original_tickets = p->Original_tickets;
    80001d66:	3cf9a023          	sw	a5,960(s3)
  release(&np->lock);
    80001d6a:	854e                	mv	a0,s3
    80001d6c:	f27fe0ef          	jal	80000c92 <release>
  return pid;
    80001d70:	74a2                	ld	s1,40(sp)
    80001d72:	69e2                	ld	s3,24(sp)
    80001d74:	6a42                	ld	s4,16(sp)
}
    80001d76:	854a                	mv	a0,s2
    80001d78:	70e2                	ld	ra,56(sp)
    80001d7a:	7442                	ld	s0,48(sp)
    80001d7c:	7902                	ld	s2,32(sp)
    80001d7e:	6aa2                	ld	s5,8(sp)
    80001d80:	6121                	addi	sp,sp,64
    80001d82:	8082                	ret
    return -1;
    80001d84:	597d                	li	s2,-1
    80001d86:	bfc5                	j	80001d76 <fork+0x108>

0000000080001d88 <scheduler>:
{
    80001d88:	d8010113          	addi	sp,sp,-640
    80001d8c:	26113c23          	sd	ra,632(sp)
    80001d90:	26813823          	sd	s0,624(sp)
    80001d94:	26913423          	sd	s1,616(sp)
    80001d98:	27213023          	sd	s2,608(sp)
    80001d9c:	25313c23          	sd	s3,600(sp)
    80001da0:	25413823          	sd	s4,592(sp)
    80001da4:	25513423          	sd	s5,584(sp)
    80001da8:	25613023          	sd	s6,576(sp)
    80001dac:	23713c23          	sd	s7,568(sp)
    80001db0:	23813823          	sd	s8,560(sp)
    80001db4:	23913423          	sd	s9,552(sp)
    80001db8:	23a13023          	sd	s10,544(sp)
    80001dbc:	21b13c23          	sd	s11,536(sp)
    80001dc0:	0500                	addi	s0,sp,640
    80001dc2:	8792                	mv	a5,tp
  int id = r_tp();
    80001dc4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dc6:	00779693          	slli	a3,a5,0x7
    80001dca:	0000e717          	auipc	a4,0xe
    80001dce:	e0670713          	addi	a4,a4,-506 # 8000fbd0 <pid_lock>
    80001dd2:	9736                	add	a4,a4,a3
    80001dd4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001dd8:	0000e717          	auipc	a4,0xe
    80001ddc:	e3070713          	addi	a4,a4,-464 # 8000fc08 <cpus+0x8>
    80001de0:	9736                	add	a4,a4,a3
    80001de2:	d8e43423          	sd	a4,-632(s0)
        if (lp->state != RUNNABLE)
    80001de6:	4a0d                	li	s4,3
          lp->inq = 1;  // Move to high priority queue
    80001de8:	4b85                	li	s7,1
        c->proc = p;
    80001dea:	0000e717          	auipc	a4,0xe
    80001dee:	de670713          	addi	a4,a4,-538 # 8000fbd0 <pid_lock>
    80001df2:	00d707b3          	add	a5,a4,a3
    80001df6:	d8f43023          	sd	a5,-640(s0)
    80001dfa:	acf5                	j	800020f6 <scheduler+0x36e>
    80001dfc:	0000e497          	auipc	s1,0xe
    80001e00:	20448493          	addi	s1,s1,516 # 80010000 <proc>
    80001e04:	0001d997          	auipc	s3,0x1d
    80001e08:	7fc98993          	addi	s3,s3,2044 # 8001f600 <tickslock>
    80001e0c:	a801                	j	80001e1c <scheduler+0x94>
        release(&lp->lock);
    80001e0e:	854a                	mv	a0,s2
    80001e10:	e83fe0ef          	jal	80000c92 <release>
      for (int i = 0; i < NPROC; i++)
    80001e14:	3d848493          	addi	s1,s1,984
    80001e18:	03348263          	beq	s1,s3,80001e3c <scheduler+0xb4>
        acquire(&lp->lock);
    80001e1c:	8926                	mv	s2,s1
    80001e1e:	8526                	mv	a0,s1
    80001e20:	ddffe0ef          	jal	80000bfe <acquire>
        if (lp->state != RUNNABLE)
    80001e24:	4c9c                	lw	a5,24(s1)
    80001e26:	ff4784e3          	beq	a5,s4,80001e0e <scheduler+0x86>
          lp->inq = 1;  // Move to high priority queue
    80001e2a:	3d74a423          	sw	s7,968(s1)
          lp->curr_runtime = 0;  // Reset runtime
    80001e2e:	3c04a823          	sw	zero,976(s1)
          lp->Current_tickets = lp->Original_tickets;  // Restore tickets
    80001e32:	3c04a783          	lw	a5,960(s1)
    80001e36:	3cf4a223          	sw	a5,964(s1)
    80001e3a:	bfd1                	j	80001e0e <scheduler+0x86>
      boost_timer = 0;
    80001e3c:	00006797          	auipc	a5,0x6
    80001e40:	c6078793          	addi	a5,a5,-928 # 80007a9c <boost_timer.4>
    80001e44:	0007a023          	sw	zero,0(a5)
    80001e48:	acc1                	j	80002118 <scheduler+0x390>
        candidate_indices[candidate_count] = i;
    80001e4a:	002c1713          	slli	a4,s8,0x2
    80001e4e:	01b706b3          	add	a3,a4,s11
    80001e52:	0126a023          	sw	s2,0(a3)
        candidate_tickets[candidate_count] = lp->Current_tickets;
    80001e56:	976a                	add	a4,a4,s10
    80001e58:	c31c                	sw	a5,0(a4)
        total_tickets += lp->Current_tickets;
    80001e5a:	01978cbb          	addw	s9,a5,s9
        candidate_count++;
    80001e5e:	2c05                	addiw	s8,s8,1 # 1001 <_entry-0x7fffefff>
      release(&lp->lock);
    80001e60:	854e                	mv	a0,s3
    80001e62:	e31fe0ef          	jal	80000c92 <release>
    for (int i = 0; i < NPROC; i++)
    80001e66:	2905                	addiw	s2,s2,1
    80001e68:	3d848493          	addi	s1,s1,984
    80001e6c:	03690263          	beq	s2,s6,80001e90 <scheduler+0x108>
      acquire(&lp->lock);
    80001e70:	89a6                	mv	s3,s1
    80001e72:	8526                	mv	a0,s1
    80001e74:	d8bfe0ef          	jal	80000bfe <acquire>
      if (lp->state == RUNNABLE && lp->inq == 1 && lp->Current_tickets > 0)
    80001e78:	4c9c                	lw	a5,24(s1)
    80001e7a:	ff4793e3          	bne	a5,s4,80001e60 <scheduler+0xd8>
    80001e7e:	3c84a783          	lw	a5,968(s1)
    80001e82:	fd779fe3          	bne	a5,s7,80001e60 <scheduler+0xd8>
    80001e86:	3c44a783          	lw	a5,964(s1)
    80001e8a:	fcf040e3          	bgtz	a5,80001e4a <scheduler+0xc2>
    80001e8e:	bfc9                	j	80001e60 <scheduler+0xd8>
    if (candidate_count > 0 && total_tickets > 0)
    80001e90:	05805663          	blez	s8,80001edc <scheduler+0x154>
    80001e94:	05905463          	blez	s9,80001edc <scheduler+0x154>
      seed = (1103515245 * seed + 12345) & 0x7fffffff;
    80001e98:	00006697          	auipc	a3,0x6
    80001e9c:	b8c68693          	addi	a3,a3,-1140 # 80007a24 <seed.3>
    80001ea0:	429c                	lw	a5,0(a3)
    80001ea2:	41c65737          	lui	a4,0x41c65
    80001ea6:	e6d7071b          	addiw	a4,a4,-403 # 41c64e6d <_entry-0x3e39b193>
    80001eaa:	02f7073b          	mulw	a4,a4,a5
    80001eae:	678d                	lui	a5,0x3
    80001eb0:	0397879b          	addiw	a5,a5,57 # 3039 <_entry-0x7fffcfc7>
    80001eb4:	9fb9                	addw	a5,a5,a4
    80001eb6:	1786                	slli	a5,a5,0x21
    80001eb8:	9385                	srli	a5,a5,0x21
    80001eba:	c29c                	sw	a5,0(a3)
      int winning_ticket = (seed % total_tickets) + 1;
    80001ebc:	0397f7bb          	remuw	a5,a5,s9
    80001ec0:	0017861b          	addiw	a2,a5,1
      for (int j = 0; j < candidate_count; j++)
    80001ec4:	e9040693          	addi	a3,s0,-368
    80001ec8:	4781                	li	a5,0
      int ticket_sum = 0;
    80001eca:	4701                	li	a4,0
        ticket_sum += candidate_tickets[j];
    80001ecc:	428c                	lw	a1,0(a3)
    80001ece:	9f2d                	addw	a4,a4,a1
        if (ticket_sum >= winning_ticket)
    80001ed0:	00c75e63          	bge	a4,a2,80001eec <scheduler+0x164>
      for (int j = 0; j < candidate_count; j++)
    80001ed4:	2785                	addiw	a5,a5,1
    80001ed6:	0691                	addi	a3,a3,4
    80001ed8:	fefc1ae3          	bne	s8,a5,80001ecc <scheduler+0x144>
    for (int i = 0; i < NPROC; i++)
    80001edc:	69bd                	lui	s3,0xf
    80001ede:	60098993          	addi	s3,s3,1536 # f600 <_entry-0x7fff0a00>
    80001ee2:	99d6                	add	s3,s3,s5
      int ticket_sum = 0;
    80001ee4:	84d6                	mv	s1,s5
    int has_queue1_processes = 0;
    80001ee6:	4b01                	li	s6,0
    int need_ticket_refill = 0;
    80001ee8:	4c01                	li	s8,0
    80001eea:	a8c1                	j	80001fba <scheduler+0x232>
          winner_idx = candidate_indices[j];
    80001eec:	078a                	slli	a5,a5,0x2
    80001eee:	f9078793          	addi	a5,a5,-112
    80001ef2:	97a2                	add	a5,a5,s0
    80001ef4:	e007a983          	lw	s3,-512(a5)
      if (winner_idx >= 0)
    80001ef8:	fe09c2e3          	bltz	s3,80001edc <scheduler+0x154>
        struct proc *winner = &proc[winner_idx];
    80001efc:	3d800913          	li	s2,984
    80001f00:	03298933          	mul	s2,s3,s2
    80001f04:	0000e497          	auipc	s1,0xe
    80001f08:	0fc48493          	addi	s1,s1,252 # 80010000 <proc>
    80001f0c:	94ca                	add	s1,s1,s2
        acquire(&winner->lock);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	ceffe0ef          	jal	80000bfe <acquire>
        if (winner->state == RUNNABLE && winner->inq == 1 && winner->Current_tickets > 0)
    80001f14:	4c9c                	lw	a5,24(s1)
    80001f16:	01478663          	beq	a5,s4,80001f22 <scheduler+0x19a>
        release(&winner->lock);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	d77fe0ef          	jal	80000c92 <release>
      if (found)
    80001f20:	bf75                	j	80001edc <scheduler+0x154>
        if (winner->state == RUNNABLE && winner->inq == 1 && winner->Current_tickets > 0)
    80001f22:	3c84a783          	lw	a5,968(s1)
    80001f26:	ff779ae3          	bne	a5,s7,80001f1a <scheduler+0x192>
    80001f2a:	3c44a783          	lw	a5,964(s1)
    80001f2e:	fef056e3          	blez	a5,80001f1a <scheduler+0x192>
          winner->state = RUNNING;
    80001f32:	0000e597          	auipc	a1,0xe
    80001f36:	0ce58593          	addi	a1,a1,206 # 80010000 <proc>
    80001f3a:	4791                	li	a5,4
    80001f3c:	cc9c                	sw	a5,24(s1)
          c->proc = winner;
    80001f3e:	d8043b03          	ld	s6,-640(s0)
    80001f42:	029b3823          	sd	s1,48(s6)
          swtch(&c->context, &winner->context);
    80001f46:	06090913          	addi	s2,s2,96
    80001f4a:	95ca                	add	a1,a1,s2
    80001f4c:	d8843503          	ld	a0,-632(s0)
    80001f50:	76c000ef          	jal	800026bc <swtch>
          c->proc = 0;
    80001f54:	020b3823          	sd	zero,48(s6)
          winner->time_slices++;
    80001f58:	3cc4a783          	lw	a5,972(s1)
    80001f5c:	2785                	addiw	a5,a5,1
    80001f5e:	3cf4a623          	sw	a5,972(s1)
          winner->curr_runtime++;
    80001f62:	3d04a783          	lw	a5,976(s1)
    80001f66:	2785                	addiw	a5,a5,1
    80001f68:	863e                	mv	a2,a5
    80001f6a:	3cf4a823          	sw	a5,976(s1)
          if (winner->Current_tickets > 0)
    80001f6e:	3c44a783          	lw	a5,964(s1)
    80001f72:	00f05563          	blez	a5,80001f7c <scheduler+0x1f4>
            winner->Current_tickets--;
    80001f76:	37fd                	addiw	a5,a5,-1
    80001f78:	3cf4a223          	sw	a5,964(s1)
          if (winner->curr_runtime >= TIME_LIMIT_1)
    80001f7c:	02c05063          	blez	a2,80001f9c <scheduler+0x214>
            winner->inq = 2;
    80001f80:	3d800793          	li	a5,984
    80001f84:	02f987b3          	mul	a5,s3,a5
    80001f88:	0000e717          	auipc	a4,0xe
    80001f8c:	07870713          	addi	a4,a4,120 # 80010000 <proc>
    80001f90:	97ba                	add	a5,a5,a4
    80001f92:	4709                	li	a4,2
    80001f94:	3ce7a423          	sw	a4,968(a5)
            winner->curr_runtime = 0;
    80001f98:	3c07a823          	sw	zero,976(a5)
        release(&winner->lock);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	cf5fe0ef          	jal	80000c92 <release>
      if (found)
    80001fa2:	aa91                	j	800020f6 <scheduler+0x36e>
          release(&lp->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	cedfe0ef          	jal	80000c92 <release>
    if (need_ticket_refill && has_queue1_processes)
    80001faa:	a82d                	j	80001fe4 <scheduler+0x25c>
      release(&lp->lock);
    80001fac:	854a                	mv	a0,s2
    80001fae:	ce5fe0ef          	jal	80000c92 <release>
    for (int i = 0; i < NPROC; i++)
    80001fb2:	3d848493          	addi	s1,s1,984
    80001fb6:	03348363          	beq	s1,s3,80001fdc <scheduler+0x254>
      acquire(&lp->lock);
    80001fba:	8926                	mv	s2,s1
    80001fbc:	8526                	mv	a0,s1
    80001fbe:	c41fe0ef          	jal	80000bfe <acquire>
      if (lp->state == RUNNABLE && lp->inq == 1)
    80001fc2:	4c9c                	lw	a5,24(s1)
    80001fc4:	ff4794e3          	bne	a5,s4,80001fac <scheduler+0x224>
    80001fc8:	3c84a783          	lw	a5,968(s1)
    80001fcc:	ff7790e3          	bne	a5,s7,80001fac <scheduler+0x224>
        if (lp->Current_tickets == 0)
    80001fd0:	3c44a703          	lw	a4,964(s1)
    80001fd4:	fb61                	bnez	a4,80001fa4 <scheduler+0x21c>
        has_queue1_processes = 1;
    80001fd6:	8b3e                	mv	s6,a5
          need_ticket_refill = 1;
    80001fd8:	8c3e                	mv	s8,a5
    80001fda:	bfc9                	j	80001fac <scheduler+0x224>
    if (need_ticket_refill && has_queue1_processes)
    80001fdc:	000c0463          	beqz	s8,80001fe4 <scheduler+0x25c>
    80001fe0:	020b1863          	bnez	s6,80002010 <scheduler+0x288>
          need_ticket_refill = 1;
    80001fe4:	4981                	li	s3,0
      int idx = (last_idx + i) % NPROC;
    80001fe6:	00006c97          	auipc	s9,0x6
    80001fea:	ab2c8c93          	addi	s9,s9,-1358 # 80007a98 <last_idx.2>
    80001fee:	3d800c13          	li	s8,984
      p = &proc[idx];
    80001ff2:	0000eb17          	auipc	s6,0xe
    80001ff6:	00eb0b13          	addi	s6,s6,14 # 80010000 <proc>
      if (p->state == RUNNABLE && p->inq == 2)
    80001ffa:	4d89                	li	s11,2
    for (int i = 0; i < NPROC; i++)
    80001ffc:	04000d13          	li	s10,64
    80002000:	a091                	j	80002044 <scheduler+0x2bc>
        release(&lp->lock);
    80002002:	8526                	mv	a0,s1
    80002004:	c8ffe0ef          	jal	80000c92 <release>
      for (int i = 0; i < NPROC; i++)
    80002008:	3d8a8a93          	addi	s5,s5,984
    8000200c:	0f3a8563          	beq	s5,s3,800020f6 <scheduler+0x36e>
        acquire(&lp->lock);
    80002010:	84d6                	mv	s1,s5
    80002012:	8556                	mv	a0,s5
    80002014:	bebfe0ef          	jal	80000bfe <acquire>
        if (lp->state == RUNNABLE && lp->inq == 1)
    80002018:	018aa783          	lw	a5,24(s5)
    8000201c:	ff4793e3          	bne	a5,s4,80002002 <scheduler+0x27a>
    80002020:	3c8aa783          	lw	a5,968(s5)
    80002024:	fd779fe3          	bne	a5,s7,80002002 <scheduler+0x27a>
          lp->Current_tickets = lp->Original_tickets;
    80002028:	3c0aa783          	lw	a5,960(s5)
    8000202c:	3cfaa223          	sw	a5,964(s5)
    80002030:	bfc9                	j	80002002 <scheduler+0x27a>
          p->inq = 1;
    80002032:	3d79a423          	sw	s7,968(s3)
    80002036:	a061                	j	800020be <scheduler+0x336>
      release(&p->lock);
    80002038:	854a                	mv	a0,s2
    8000203a:	c59fe0ef          	jal	80000c92 <release>
    for (int i = 0; i < NPROC; i++)
    8000203e:	2985                	addiw	s3,s3,1
    80002040:	0fa98b63          	beq	s3,s10,80002136 <scheduler+0x3ae>
      int idx = (last_idx + i) % NPROC;
    80002044:	000ca483          	lw	s1,0(s9)
    80002048:	013484bb          	addw	s1,s1,s3
    8000204c:	41f4d79b          	sraiw	a5,s1,0x1f
    80002050:	01a7d79b          	srliw	a5,a5,0x1a
    80002054:	9cbd                	addw	s1,s1,a5
    80002056:	03f4f493          	andi	s1,s1,63
    8000205a:	9c9d                	subw	s1,s1,a5
      p = &proc[idx];
    8000205c:	03848ab3          	mul	s5,s1,s8
    80002060:	016a8933          	add	s2,s5,s6
      acquire(&p->lock);
    80002064:	854a                	mv	a0,s2
    80002066:	b99fe0ef          	jal	80000bfe <acquire>
      if (p->state == RUNNABLE && p->inq == 2)
    8000206a:	01892783          	lw	a5,24(s2)
    8000206e:	fd4795e3          	bne	a5,s4,80002038 <scheduler+0x2b0>
    80002072:	3c892783          	lw	a5,968(s2)
    80002076:	fdb791e3          	bne	a5,s11,80002038 <scheduler+0x2b0>
        p->state = RUNNING;
    8000207a:	0000e597          	auipc	a1,0xe
    8000207e:	f8658593          	addi	a1,a1,-122 # 80010000 <proc>
    80002082:	3d800993          	li	s3,984
    80002086:	033489b3          	mul	s3,s1,s3
    8000208a:	99ae                	add	s3,s3,a1
    8000208c:	4791                	li	a5,4
    8000208e:	00f9ac23          	sw	a5,24(s3)
        c->proc = p;
    80002092:	d8043b03          	ld	s6,-640(s0)
    80002096:	032b3823          	sd	s2,48(s6)
        swtch(&c->context, &p->context);
    8000209a:	060a8a93          	addi	s5,s5,96
    8000209e:	95d6                	add	a1,a1,s5
    800020a0:	d8843503          	ld	a0,-632(s0)
    800020a4:	618000ef          	jal	800026bc <swtch>
        c->proc = 0;
    800020a8:	020b3823          	sd	zero,48(s6)
        p->time_slices++;
    800020ac:	3cc9a783          	lw	a5,972(s3)
    800020b0:	2785                	addiw	a5,a5,1
    800020b2:	3cf9a623          	sw	a5,972(s3)
        if (p->curr_runtime < TIME_LIMIT_2)
    800020b6:	3d09a783          	lw	a5,976(s3)
    800020ba:	f6f05ce3          	blez	a5,80002032 <scheduler+0x2aa>
        p->curr_runtime = 0;
    800020be:	3d800713          	li	a4,984
    800020c2:	02e48733          	mul	a4,s1,a4
    800020c6:	0000e797          	auipc	a5,0xe
    800020ca:	f3a78793          	addi	a5,a5,-198 # 80010000 <proc>
    800020ce:	97ba                	add	a5,a5,a4
    800020d0:	3c07a823          	sw	zero,976(a5)
        last_idx = (idx + 1) % NPROC;
    800020d4:	2485                	addiw	s1,s1,1
    800020d6:	41f4d71b          	sraiw	a4,s1,0x1f
    800020da:	01a7571b          	srliw	a4,a4,0x1a
    800020de:	009707bb          	addw	a5,a4,s1
    800020e2:	03f7f793          	andi	a5,a5,63
    800020e6:	9f99                	subw	a5,a5,a4
    800020e8:	00006717          	auipc	a4,0x6
    800020ec:	9af72823          	sw	a5,-1616(a4) # 80007a98 <last_idx.2>
        release(&p->lock);
    800020f0:	854a                	mv	a0,s2
    800020f2:	ba1fe0ef          	jal	80000c92 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020fa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020fe:	10079073          	csrw	sstatus,a5
    boost_timer++;
    80002102:	00006717          	auipc	a4,0x6
    80002106:	99a70713          	addi	a4,a4,-1638 # 80007a9c <boost_timer.4>
    8000210a:	431c                	lw	a5,0(a4)
    8000210c:	2785                	addiw	a5,a5,1
    8000210e:	c31c                	sw	a5,0(a4)
    if (boost_timer >= BOOST_INTERVAL)
    80002110:	03f00713          	li	a4,63
    80002114:	cef744e3          	blt	a4,a5,80001dfc <scheduler+0x74>
    for (int i = 0; i < NPROC; i++)
    80002118:	0000ea97          	auipc	s5,0xe
    8000211c:	ee8a8a93          	addi	s5,s5,-280 # 80010000 <proc>
{
    80002120:	84d6                	mv	s1,s5
    80002122:	4901                	li	s2,0
    80002124:	4c01                	li	s8,0
    80002126:	4c81                	li	s9,0
        candidate_indices[candidate_count] = i;
    80002128:	d9040d93          	addi	s11,s0,-624
        candidate_tickets[candidate_count] = lp->Current_tickets;
    8000212c:	e9040d13          	addi	s10,s0,-368
    for (int i = 0; i < NPROC; i++)
    80002130:	04000b13          	li	s6,64
    80002134:	bb35                	j	80001e70 <scheduler+0xe8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002136:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000213a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000213e:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002142:	10500073          	wfi
    80002146:	bf45                	j	800020f6 <scheduler+0x36e>

0000000080002148 <sched>:
{
    80002148:	7179                	addi	sp,sp,-48
    8000214a:	f406                	sd	ra,40(sp)
    8000214c:	f022                	sd	s0,32(sp)
    8000214e:	ec26                	sd	s1,24(sp)
    80002150:	e84a                	sd	s2,16(sp)
    80002152:	e44e                	sd	s3,8(sp)
    80002154:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002156:	f86ff0ef          	jal	800018dc <myproc>
    8000215a:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000215c:	a39fe0ef          	jal	80000b94 <holding>
    80002160:	c92d                	beqz	a0,800021d2 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002162:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002164:	2781                	sext.w	a5,a5
    80002166:	079e                	slli	a5,a5,0x7
    80002168:	0000e717          	auipc	a4,0xe
    8000216c:	a6870713          	addi	a4,a4,-1432 # 8000fbd0 <pid_lock>
    80002170:	97ba                	add	a5,a5,a4
    80002172:	0a87a703          	lw	a4,168(a5)
    80002176:	4785                	li	a5,1
    80002178:	06f71363          	bne	a4,a5,800021de <sched+0x96>
  if (p->state == RUNNING)
    8000217c:	4c98                	lw	a4,24(s1)
    8000217e:	4791                	li	a5,4
    80002180:	06f70563          	beq	a4,a5,800021ea <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002184:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002188:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000218a:	e7b5                	bnez	a5,800021f6 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000218c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000218e:	0000e917          	auipc	s2,0xe
    80002192:	a4290913          	addi	s2,s2,-1470 # 8000fbd0 <pid_lock>
    80002196:	2781                	sext.w	a5,a5
    80002198:	079e                	slli	a5,a5,0x7
    8000219a:	97ca                	add	a5,a5,s2
    8000219c:	0ac7a983          	lw	s3,172(a5)
    800021a0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800021a2:	2781                	sext.w	a5,a5
    800021a4:	079e                	slli	a5,a5,0x7
    800021a6:	0000e597          	auipc	a1,0xe
    800021aa:	a6258593          	addi	a1,a1,-1438 # 8000fc08 <cpus+0x8>
    800021ae:	95be                	add	a1,a1,a5
    800021b0:	06048513          	addi	a0,s1,96
    800021b4:	508000ef          	jal	800026bc <swtch>
    800021b8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021ba:	2781                	sext.w	a5,a5
    800021bc:	079e                	slli	a5,a5,0x7
    800021be:	993e                	add	s2,s2,a5
    800021c0:	0b392623          	sw	s3,172(s2)
}
    800021c4:	70a2                	ld	ra,40(sp)
    800021c6:	7402                	ld	s0,32(sp)
    800021c8:	64e2                	ld	s1,24(sp)
    800021ca:	6942                	ld	s2,16(sp)
    800021cc:	69a2                	ld	s3,8(sp)
    800021ce:	6145                	addi	sp,sp,48
    800021d0:	8082                	ret
    panic("sched p->lock");
    800021d2:	00005517          	auipc	a0,0x5
    800021d6:	06650513          	addi	a0,a0,102 # 80007238 <etext+0x238>
    800021da:	dc4fe0ef          	jal	8000079e <panic>
    panic("sched locks");
    800021de:	00005517          	auipc	a0,0x5
    800021e2:	06a50513          	addi	a0,a0,106 # 80007248 <etext+0x248>
    800021e6:	db8fe0ef          	jal	8000079e <panic>
    panic("sched running");
    800021ea:	00005517          	auipc	a0,0x5
    800021ee:	06e50513          	addi	a0,a0,110 # 80007258 <etext+0x258>
    800021f2:	dacfe0ef          	jal	8000079e <panic>
    panic("sched interruptible");
    800021f6:	00005517          	auipc	a0,0x5
    800021fa:	07250513          	addi	a0,a0,114 # 80007268 <etext+0x268>
    800021fe:	da0fe0ef          	jal	8000079e <panic>

0000000080002202 <yield>:
{
    80002202:	1101                	addi	sp,sp,-32
    80002204:	ec06                	sd	ra,24(sp)
    80002206:	e822                	sd	s0,16(sp)
    80002208:	e426                	sd	s1,8(sp)
    8000220a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000220c:	ed0ff0ef          	jal	800018dc <myproc>
    80002210:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002212:	9edfe0ef          	jal	80000bfe <acquire>
  p->state = RUNNABLE;
    80002216:	478d                	li	a5,3
    80002218:	cc9c                	sw	a5,24(s1)
  sched();
    8000221a:	f2fff0ef          	jal	80002148 <sched>
  release(&p->lock);
    8000221e:	8526                	mv	a0,s1
    80002220:	a73fe0ef          	jal	80000c92 <release>
}
    80002224:	60e2                	ld	ra,24(sp)
    80002226:	6442                	ld	s0,16(sp)
    80002228:	64a2                	ld	s1,8(sp)
    8000222a:	6105                	addi	sp,sp,32
    8000222c:	8082                	ret

000000008000222e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000222e:	7179                	addi	sp,sp,-48
    80002230:	f406                	sd	ra,40(sp)
    80002232:	f022                	sd	s0,32(sp)
    80002234:	ec26                	sd	s1,24(sp)
    80002236:	e84a                	sd	s2,16(sp)
    80002238:	e44e                	sd	s3,8(sp)
    8000223a:	1800                	addi	s0,sp,48
    8000223c:	89aa                	mv	s3,a0
    8000223e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002240:	e9cff0ef          	jal	800018dc <myproc>
    80002244:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002246:	9b9fe0ef          	jal	80000bfe <acquire>
  release(lk);
    8000224a:	854a                	mv	a0,s2
    8000224c:	a47fe0ef          	jal	80000c92 <release>

  // Go to sleep.
  p->chan = chan;
    80002250:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002254:	4789                	li	a5,2
    80002256:	cc9c                	sw	a5,24(s1)

  sched();
    80002258:	ef1ff0ef          	jal	80002148 <sched>

  // Tidy up.
  p->chan = 0;
    8000225c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002260:	8526                	mv	a0,s1
    80002262:	a31fe0ef          	jal	80000c92 <release>
  acquire(lk);
    80002266:	854a                	mv	a0,s2
    80002268:	997fe0ef          	jal	80000bfe <acquire>
}
    8000226c:	70a2                	ld	ra,40(sp)
    8000226e:	7402                	ld	s0,32(sp)
    80002270:	64e2                	ld	s1,24(sp)
    80002272:	6942                	ld	s2,16(sp)
    80002274:	69a2                	ld	s3,8(sp)
    80002276:	6145                	addi	sp,sp,48
    80002278:	8082                	ret

000000008000227a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000227a:	7139                	addi	sp,sp,-64
    8000227c:	fc06                	sd	ra,56(sp)
    8000227e:	f822                	sd	s0,48(sp)
    80002280:	f426                	sd	s1,40(sp)
    80002282:	f04a                	sd	s2,32(sp)
    80002284:	ec4e                	sd	s3,24(sp)
    80002286:	e852                	sd	s4,16(sp)
    80002288:	e456                	sd	s5,8(sp)
    8000228a:	0080                	addi	s0,sp,64
    8000228c:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000228e:	0000e497          	auipc	s1,0xe
    80002292:	d7248493          	addi	s1,s1,-654 # 80010000 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002296:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002298:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000229a:	0001d917          	auipc	s2,0x1d
    8000229e:	36690913          	addi	s2,s2,870 # 8001f600 <tickslock>
    800022a2:	a801                	j	800022b2 <wakeup+0x38>
      }
      release(&p->lock);
    800022a4:	8526                	mv	a0,s1
    800022a6:	9edfe0ef          	jal	80000c92 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800022aa:	3d848493          	addi	s1,s1,984
    800022ae:	03248263          	beq	s1,s2,800022d2 <wakeup+0x58>
    if (p != myproc())
    800022b2:	e2aff0ef          	jal	800018dc <myproc>
    800022b6:	fea48ae3          	beq	s1,a0,800022aa <wakeup+0x30>
      acquire(&p->lock);
    800022ba:	8526                	mv	a0,s1
    800022bc:	943fe0ef          	jal	80000bfe <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800022c0:	4c9c                	lw	a5,24(s1)
    800022c2:	ff3791e3          	bne	a5,s3,800022a4 <wakeup+0x2a>
    800022c6:	709c                	ld	a5,32(s1)
    800022c8:	fd479ee3          	bne	a5,s4,800022a4 <wakeup+0x2a>
        p->state = RUNNABLE;
    800022cc:	0154ac23          	sw	s5,24(s1)
    800022d0:	bfd1                	j	800022a4 <wakeup+0x2a>
    }
  }
}
    800022d2:	70e2                	ld	ra,56(sp)
    800022d4:	7442                	ld	s0,48(sp)
    800022d6:	74a2                	ld	s1,40(sp)
    800022d8:	7902                	ld	s2,32(sp)
    800022da:	69e2                	ld	s3,24(sp)
    800022dc:	6a42                	ld	s4,16(sp)
    800022de:	6aa2                	ld	s5,8(sp)
    800022e0:	6121                	addi	sp,sp,64
    800022e2:	8082                	ret

00000000800022e4 <reparent>:
{
    800022e4:	7179                	addi	sp,sp,-48
    800022e6:	f406                	sd	ra,40(sp)
    800022e8:	f022                	sd	s0,32(sp)
    800022ea:	ec26                	sd	s1,24(sp)
    800022ec:	e84a                	sd	s2,16(sp)
    800022ee:	e44e                	sd	s3,8(sp)
    800022f0:	e052                	sd	s4,0(sp)
    800022f2:	1800                	addi	s0,sp,48
    800022f4:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800022f6:	0000e497          	auipc	s1,0xe
    800022fa:	d0a48493          	addi	s1,s1,-758 # 80010000 <proc>
      pp->parent = initproc;
    800022fe:	00005a17          	auipc	s4,0x5
    80002302:	7a2a0a13          	addi	s4,s4,1954 # 80007aa0 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002306:	0001d997          	auipc	s3,0x1d
    8000230a:	2fa98993          	addi	s3,s3,762 # 8001f600 <tickslock>
    8000230e:	a029                	j	80002318 <reparent+0x34>
    80002310:	3d848493          	addi	s1,s1,984
    80002314:	01348b63          	beq	s1,s3,8000232a <reparent+0x46>
    if (pp->parent == p)
    80002318:	7c9c                	ld	a5,56(s1)
    8000231a:	ff279be3          	bne	a5,s2,80002310 <reparent+0x2c>
      pp->parent = initproc;
    8000231e:	000a3503          	ld	a0,0(s4)
    80002322:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002324:	f57ff0ef          	jal	8000227a <wakeup>
    80002328:	b7e5                	j	80002310 <reparent+0x2c>
}
    8000232a:	70a2                	ld	ra,40(sp)
    8000232c:	7402                	ld	s0,32(sp)
    8000232e:	64e2                	ld	s1,24(sp)
    80002330:	6942                	ld	s2,16(sp)
    80002332:	69a2                	ld	s3,8(sp)
    80002334:	6a02                	ld	s4,0(sp)
    80002336:	6145                	addi	sp,sp,48
    80002338:	8082                	ret

000000008000233a <exit>:
{
    8000233a:	7179                	addi	sp,sp,-48
    8000233c:	f406                	sd	ra,40(sp)
    8000233e:	f022                	sd	s0,32(sp)
    80002340:	ec26                	sd	s1,24(sp)
    80002342:	e84a                	sd	s2,16(sp)
    80002344:	e44e                	sd	s3,8(sp)
    80002346:	e052                	sd	s4,0(sp)
    80002348:	1800                	addi	s0,sp,48
    8000234a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000234c:	d90ff0ef          	jal	800018dc <myproc>
    80002350:	89aa                	mv	s3,a0
  if (p == initproc)
    80002352:	00005797          	auipc	a5,0x5
    80002356:	74e7b783          	ld	a5,1870(a5) # 80007aa0 <initproc>
    8000235a:	0d050493          	addi	s1,a0,208
    8000235e:	15050913          	addi	s2,a0,336
    80002362:	00a79b63          	bne	a5,a0,80002378 <exit+0x3e>
    panic("init exiting");
    80002366:	00005517          	auipc	a0,0x5
    8000236a:	f1a50513          	addi	a0,a0,-230 # 80007280 <etext+0x280>
    8000236e:	c30fe0ef          	jal	8000079e <panic>
  for (int fd = 0; fd < NOFILE; fd++)
    80002372:	04a1                	addi	s1,s1,8
    80002374:	01248963          	beq	s1,s2,80002386 <exit+0x4c>
    if (p->ofile[fd])
    80002378:	6088                	ld	a0,0(s1)
    8000237a:	dd65                	beqz	a0,80002372 <exit+0x38>
      fileclose(f);
    8000237c:	074020ef          	jal	800043f0 <fileclose>
      p->ofile[fd] = 0;
    80002380:	0004b023          	sd	zero,0(s1)
    80002384:	b7fd                	j	80002372 <exit+0x38>
  begin_op();
    80002386:	44b010ef          	jal	80003fd0 <begin_op>
  iput(p->cwd);
    8000238a:	1509b503          	ld	a0,336(s3)
    8000238e:	512010ef          	jal	800038a0 <iput>
  end_op();
    80002392:	4a9010ef          	jal	8000403a <end_op>
  p->cwd = 0;
    80002396:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000239a:	0000e497          	auipc	s1,0xe
    8000239e:	84e48493          	addi	s1,s1,-1970 # 8000fbe8 <wait_lock>
    800023a2:	8526                	mv	a0,s1
    800023a4:	85bfe0ef          	jal	80000bfe <acquire>
  reparent(p);
    800023a8:	854e                	mv	a0,s3
    800023aa:	f3bff0ef          	jal	800022e4 <reparent>
  wakeup(p->parent);
    800023ae:	0389b503          	ld	a0,56(s3)
    800023b2:	ec9ff0ef          	jal	8000227a <wakeup>
  acquire(&p->lock);
    800023b6:	854e                	mv	a0,s3
    800023b8:	847fe0ef          	jal	80000bfe <acquire>
  p->xstate = status;
    800023bc:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023c0:	4795                	li	a5,5
    800023c2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023c6:	8526                	mv	a0,s1
    800023c8:	8cbfe0ef          	jal	80000c92 <release>
  sched();
    800023cc:	d7dff0ef          	jal	80002148 <sched>
  panic("zombie exit");
    800023d0:	00005517          	auipc	a0,0x5
    800023d4:	ec050513          	addi	a0,a0,-320 # 80007290 <etext+0x290>
    800023d8:	bc6fe0ef          	jal	8000079e <panic>

00000000800023dc <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800023dc:	7179                	addi	sp,sp,-48
    800023de:	f406                	sd	ra,40(sp)
    800023e0:	f022                	sd	s0,32(sp)
    800023e2:	ec26                	sd	s1,24(sp)
    800023e4:	e84a                	sd	s2,16(sp)
    800023e6:	e44e                	sd	s3,8(sp)
    800023e8:	1800                	addi	s0,sp,48
    800023ea:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023ec:	0000e497          	auipc	s1,0xe
    800023f0:	c1448493          	addi	s1,s1,-1004 # 80010000 <proc>
    800023f4:	0001d997          	auipc	s3,0x1d
    800023f8:	20c98993          	addi	s3,s3,524 # 8001f600 <tickslock>
  {
    acquire(&p->lock);
    800023fc:	8526                	mv	a0,s1
    800023fe:	801fe0ef          	jal	80000bfe <acquire>
    if (p->pid == pid)
    80002402:	589c                	lw	a5,48(s1)
    80002404:	01278b63          	beq	a5,s2,8000241a <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002408:	8526                	mv	a0,s1
    8000240a:	889fe0ef          	jal	80000c92 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000240e:	3d848493          	addi	s1,s1,984
    80002412:	ff3495e3          	bne	s1,s3,800023fc <kill+0x20>
  }
  return -1;
    80002416:	557d                	li	a0,-1
    80002418:	a819                	j	8000242e <kill+0x52>
      p->killed = 1;
    8000241a:	4785                	li	a5,1
    8000241c:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000241e:	4c98                	lw	a4,24(s1)
    80002420:	4789                	li	a5,2
    80002422:	00f70d63          	beq	a4,a5,8000243c <kill+0x60>
      release(&p->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	86bfe0ef          	jal	80000c92 <release>
      return 0;
    8000242c:	4501                	li	a0,0
}
    8000242e:	70a2                	ld	ra,40(sp)
    80002430:	7402                	ld	s0,32(sp)
    80002432:	64e2                	ld	s1,24(sp)
    80002434:	6942                	ld	s2,16(sp)
    80002436:	69a2                	ld	s3,8(sp)
    80002438:	6145                	addi	sp,sp,48
    8000243a:	8082                	ret
        p->state = RUNNABLE;
    8000243c:	478d                	li	a5,3
    8000243e:	cc9c                	sw	a5,24(s1)
    80002440:	b7dd                	j	80002426 <kill+0x4a>

0000000080002442 <setkilled>:

void setkilled(struct proc *p)
{
    80002442:	1101                	addi	sp,sp,-32
    80002444:	ec06                	sd	ra,24(sp)
    80002446:	e822                	sd	s0,16(sp)
    80002448:	e426                	sd	s1,8(sp)
    8000244a:	1000                	addi	s0,sp,32
    8000244c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000244e:	fb0fe0ef          	jal	80000bfe <acquire>
  p->killed = 1;
    80002452:	4785                	li	a5,1
    80002454:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002456:	8526                	mv	a0,s1
    80002458:	83bfe0ef          	jal	80000c92 <release>
}
    8000245c:	60e2                	ld	ra,24(sp)
    8000245e:	6442                	ld	s0,16(sp)
    80002460:	64a2                	ld	s1,8(sp)
    80002462:	6105                	addi	sp,sp,32
    80002464:	8082                	ret

0000000080002466 <killed>:

int killed(struct proc *p)
{
    80002466:	1101                	addi	sp,sp,-32
    80002468:	ec06                	sd	ra,24(sp)
    8000246a:	e822                	sd	s0,16(sp)
    8000246c:	e426                	sd	s1,8(sp)
    8000246e:	e04a                	sd	s2,0(sp)
    80002470:	1000                	addi	s0,sp,32
    80002472:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002474:	f8afe0ef          	jal	80000bfe <acquire>
  k = p->killed;
    80002478:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000247c:	8526                	mv	a0,s1
    8000247e:	815fe0ef          	jal	80000c92 <release>
  return k;
}
    80002482:	854a                	mv	a0,s2
    80002484:	60e2                	ld	ra,24(sp)
    80002486:	6442                	ld	s0,16(sp)
    80002488:	64a2                	ld	s1,8(sp)
    8000248a:	6902                	ld	s2,0(sp)
    8000248c:	6105                	addi	sp,sp,32
    8000248e:	8082                	ret

0000000080002490 <wait>:
{
    80002490:	715d                	addi	sp,sp,-80
    80002492:	e486                	sd	ra,72(sp)
    80002494:	e0a2                	sd	s0,64(sp)
    80002496:	fc26                	sd	s1,56(sp)
    80002498:	f84a                	sd	s2,48(sp)
    8000249a:	f44e                	sd	s3,40(sp)
    8000249c:	f052                	sd	s4,32(sp)
    8000249e:	ec56                	sd	s5,24(sp)
    800024a0:	e85a                	sd	s6,16(sp)
    800024a2:	e45e                	sd	s7,8(sp)
    800024a4:	0880                	addi	s0,sp,80
    800024a6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024a8:	c34ff0ef          	jal	800018dc <myproc>
    800024ac:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024ae:	0000d517          	auipc	a0,0xd
    800024b2:	73a50513          	addi	a0,a0,1850 # 8000fbe8 <wait_lock>
    800024b6:	f48fe0ef          	jal	80000bfe <acquire>
        if (pp->state == ZOMBIE)
    800024ba:	4a15                	li	s4,5
        havekids = 1;
    800024bc:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024be:	0001d997          	auipc	s3,0x1d
    800024c2:	14298993          	addi	s3,s3,322 # 8001f600 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024c6:	0000db97          	auipc	s7,0xd
    800024ca:	722b8b93          	addi	s7,s7,1826 # 8000fbe8 <wait_lock>
    800024ce:	a869                	j	80002568 <wait+0xd8>
          pid = pp->pid;
    800024d0:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024d4:	000b0c63          	beqz	s6,800024ec <wait+0x5c>
    800024d8:	4691                	li	a3,4
    800024da:	02c48613          	addi	a2,s1,44
    800024de:	85da                	mv	a1,s6
    800024e0:	05093503          	ld	a0,80(s2)
    800024e4:	8a0ff0ef          	jal	80001584 <copyout>
    800024e8:	02054a63          	bltz	a0,8000251c <wait+0x8c>
          freeproc(pp);
    800024ec:	8526                	mv	a0,s1
    800024ee:	d60ff0ef          	jal	80001a4e <freeproc>
          release(&pp->lock);
    800024f2:	8526                	mv	a0,s1
    800024f4:	f9efe0ef          	jal	80000c92 <release>
          release(&wait_lock);
    800024f8:	0000d517          	auipc	a0,0xd
    800024fc:	6f050513          	addi	a0,a0,1776 # 8000fbe8 <wait_lock>
    80002500:	f92fe0ef          	jal	80000c92 <release>
}
    80002504:	854e                	mv	a0,s3
    80002506:	60a6                	ld	ra,72(sp)
    80002508:	6406                	ld	s0,64(sp)
    8000250a:	74e2                	ld	s1,56(sp)
    8000250c:	7942                	ld	s2,48(sp)
    8000250e:	79a2                	ld	s3,40(sp)
    80002510:	7a02                	ld	s4,32(sp)
    80002512:	6ae2                	ld	s5,24(sp)
    80002514:	6b42                	ld	s6,16(sp)
    80002516:	6ba2                	ld	s7,8(sp)
    80002518:	6161                	addi	sp,sp,80
    8000251a:	8082                	ret
            release(&pp->lock);
    8000251c:	8526                	mv	a0,s1
    8000251e:	f74fe0ef          	jal	80000c92 <release>
            release(&wait_lock);
    80002522:	0000d517          	auipc	a0,0xd
    80002526:	6c650513          	addi	a0,a0,1734 # 8000fbe8 <wait_lock>
    8000252a:	f68fe0ef          	jal	80000c92 <release>
            return -1;
    8000252e:	59fd                	li	s3,-1
    80002530:	bfd1                	j	80002504 <wait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002532:	3d848493          	addi	s1,s1,984
    80002536:	03348063          	beq	s1,s3,80002556 <wait+0xc6>
      if (pp->parent == p)
    8000253a:	7c9c                	ld	a5,56(s1)
    8000253c:	ff279be3          	bne	a5,s2,80002532 <wait+0xa2>
        acquire(&pp->lock);
    80002540:	8526                	mv	a0,s1
    80002542:	ebcfe0ef          	jal	80000bfe <acquire>
        if (pp->state == ZOMBIE)
    80002546:	4c9c                	lw	a5,24(s1)
    80002548:	f94784e3          	beq	a5,s4,800024d0 <wait+0x40>
        release(&pp->lock);
    8000254c:	8526                	mv	a0,s1
    8000254e:	f44fe0ef          	jal	80000c92 <release>
        havekids = 1;
    80002552:	8756                	mv	a4,s5
    80002554:	bff9                	j	80002532 <wait+0xa2>
    if (!havekids || killed(p))
    80002556:	cf19                	beqz	a4,80002574 <wait+0xe4>
    80002558:	854a                	mv	a0,s2
    8000255a:	f0dff0ef          	jal	80002466 <killed>
    8000255e:	e919                	bnez	a0,80002574 <wait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002560:	85de                	mv	a1,s7
    80002562:	854a                	mv	a0,s2
    80002564:	ccbff0ef          	jal	8000222e <sleep>
    havekids = 0;
    80002568:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000256a:	0000e497          	auipc	s1,0xe
    8000256e:	a9648493          	addi	s1,s1,-1386 # 80010000 <proc>
    80002572:	b7e1                	j	8000253a <wait+0xaa>
      release(&wait_lock);
    80002574:	0000d517          	auipc	a0,0xd
    80002578:	67450513          	addi	a0,a0,1652 # 8000fbe8 <wait_lock>
    8000257c:	f16fe0ef          	jal	80000c92 <release>
      return -1;
    80002580:	59fd                	li	s3,-1
    80002582:	b749                	j	80002504 <wait+0x74>

0000000080002584 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002584:	7179                	addi	sp,sp,-48
    80002586:	f406                	sd	ra,40(sp)
    80002588:	f022                	sd	s0,32(sp)
    8000258a:	ec26                	sd	s1,24(sp)
    8000258c:	e84a                	sd	s2,16(sp)
    8000258e:	e44e                	sd	s3,8(sp)
    80002590:	e052                	sd	s4,0(sp)
    80002592:	1800                	addi	s0,sp,48
    80002594:	84aa                	mv	s1,a0
    80002596:	892e                	mv	s2,a1
    80002598:	89b2                	mv	s3,a2
    8000259a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000259c:	b40ff0ef          	jal	800018dc <myproc>
  if (user_dst)
    800025a0:	cc99                	beqz	s1,800025be <either_copyout+0x3a>
  {
    return copyout(p->pagetable, dst, src, len);
    800025a2:	86d2                	mv	a3,s4
    800025a4:	864e                	mv	a2,s3
    800025a6:	85ca                	mv	a1,s2
    800025a8:	6928                	ld	a0,80(a0)
    800025aa:	fdbfe0ef          	jal	80001584 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025ae:	70a2                	ld	ra,40(sp)
    800025b0:	7402                	ld	s0,32(sp)
    800025b2:	64e2                	ld	s1,24(sp)
    800025b4:	6942                	ld	s2,16(sp)
    800025b6:	69a2                	ld	s3,8(sp)
    800025b8:	6a02                	ld	s4,0(sp)
    800025ba:	6145                	addi	sp,sp,48
    800025bc:	8082                	ret
    memmove((char *)dst, src, len);
    800025be:	000a061b          	sext.w	a2,s4
    800025c2:	85ce                	mv	a1,s3
    800025c4:	854a                	mv	a0,s2
    800025c6:	f6cfe0ef          	jal	80000d32 <memmove>
    return 0;
    800025ca:	8526                	mv	a0,s1
    800025cc:	b7cd                	j	800025ae <either_copyout+0x2a>

00000000800025ce <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025ce:	7179                	addi	sp,sp,-48
    800025d0:	f406                	sd	ra,40(sp)
    800025d2:	f022                	sd	s0,32(sp)
    800025d4:	ec26                	sd	s1,24(sp)
    800025d6:	e84a                	sd	s2,16(sp)
    800025d8:	e44e                	sd	s3,8(sp)
    800025da:	e052                	sd	s4,0(sp)
    800025dc:	1800                	addi	s0,sp,48
    800025de:	892a                	mv	s2,a0
    800025e0:	84ae                	mv	s1,a1
    800025e2:	89b2                	mv	s3,a2
    800025e4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025e6:	af6ff0ef          	jal	800018dc <myproc>
  if (user_src)
    800025ea:	cc99                	beqz	s1,80002608 <either_copyin+0x3a>
  {
    return copyin(p->pagetable, dst, src, len);
    800025ec:	86d2                	mv	a3,s4
    800025ee:	864e                	mv	a2,s3
    800025f0:	85ca                	mv	a1,s2
    800025f2:	6928                	ld	a0,80(a0)
    800025f4:	840ff0ef          	jal	80001634 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800025f8:	70a2                	ld	ra,40(sp)
    800025fa:	7402                	ld	s0,32(sp)
    800025fc:	64e2                	ld	s1,24(sp)
    800025fe:	6942                	ld	s2,16(sp)
    80002600:	69a2                	ld	s3,8(sp)
    80002602:	6a02                	ld	s4,0(sp)
    80002604:	6145                	addi	sp,sp,48
    80002606:	8082                	ret
    memmove(dst, (char *)src, len);
    80002608:	000a061b          	sext.w	a2,s4
    8000260c:	85ce                	mv	a1,s3
    8000260e:	854a                	mv	a0,s2
    80002610:	f22fe0ef          	jal	80000d32 <memmove>
    return 0;
    80002614:	8526                	mv	a0,s1
    80002616:	b7cd                	j	800025f8 <either_copyin+0x2a>

0000000080002618 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002618:	715d                	addi	sp,sp,-80
    8000261a:	e486                	sd	ra,72(sp)
    8000261c:	e0a2                	sd	s0,64(sp)
    8000261e:	fc26                	sd	s1,56(sp)
    80002620:	f84a                	sd	s2,48(sp)
    80002622:	f44e                	sd	s3,40(sp)
    80002624:	f052                	sd	s4,32(sp)
    80002626:	ec56                	sd	s5,24(sp)
    80002628:	e85a                	sd	s6,16(sp)
    8000262a:	e45e                	sd	s7,8(sp)
    8000262c:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000262e:	00005517          	auipc	a0,0x5
    80002632:	a4a50513          	addi	a0,a0,-1462 # 80007078 <etext+0x78>
    80002636:	e99fd0ef          	jal	800004ce <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000263a:	0000e497          	auipc	s1,0xe
    8000263e:	b1e48493          	addi	s1,s1,-1250 # 80010158 <proc+0x158>
    80002642:	0001d917          	auipc	s2,0x1d
    80002646:	11690913          	addi	s2,s2,278 # 8001f758 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000264a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000264c:	00005997          	auipc	s3,0x5
    80002650:	c5498993          	addi	s3,s3,-940 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002654:	00005a97          	auipc	s5,0x5
    80002658:	c54a8a93          	addi	s5,s5,-940 # 800072a8 <etext+0x2a8>
    printf("\n");
    8000265c:	00005a17          	auipc	s4,0x5
    80002660:	a1ca0a13          	addi	s4,s4,-1508 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002664:	00005b97          	auipc	s7,0x5
    80002668:	1e4b8b93          	addi	s7,s7,484 # 80007848 <syscall_names>
    8000266c:	a829                	j	80002686 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000266e:	ed86a583          	lw	a1,-296(a3)
    80002672:	8556                	mv	a0,s5
    80002674:	e5bfd0ef          	jal	800004ce <printf>
    printf("\n");
    80002678:	8552                	mv	a0,s4
    8000267a:	e55fd0ef          	jal	800004ce <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000267e:	3d848493          	addi	s1,s1,984
    80002682:	03248263          	beq	s1,s2,800026a6 <procdump+0x8e>
    if (p->state == UNUSED)
    80002686:	86a6                	mv	a3,s1
    80002688:	ec04a783          	lw	a5,-320(s1)
    8000268c:	dbed                	beqz	a5,8000267e <procdump+0x66>
      state = "???";
    8000268e:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002690:	fcfb6fe3          	bltu	s6,a5,8000266e <procdump+0x56>
    80002694:	02079713          	slli	a4,a5,0x20
    80002698:	01d75793          	srli	a5,a4,0x1d
    8000269c:	97de                	add	a5,a5,s7
    8000269e:	67f0                	ld	a2,200(a5)
    800026a0:	f679                	bnez	a2,8000266e <procdump+0x56>
      state = "???";
    800026a2:	864e                	mv	a2,s3
    800026a4:	b7e9                	j	8000266e <procdump+0x56>
  }
}
    800026a6:	60a6                	ld	ra,72(sp)
    800026a8:	6406                	ld	s0,64(sp)
    800026aa:	74e2                	ld	s1,56(sp)
    800026ac:	7942                	ld	s2,48(sp)
    800026ae:	79a2                	ld	s3,40(sp)
    800026b0:	7a02                	ld	s4,32(sp)
    800026b2:	6ae2                	ld	s5,24(sp)
    800026b4:	6b42                	ld	s6,16(sp)
    800026b6:	6ba2                	ld	s7,8(sp)
    800026b8:	6161                	addi	sp,sp,80
    800026ba:	8082                	ret

00000000800026bc <swtch>:
    800026bc:	00153023          	sd	ra,0(a0)
    800026c0:	00253423          	sd	sp,8(a0)
    800026c4:	e900                	sd	s0,16(a0)
    800026c6:	ed04                	sd	s1,24(a0)
    800026c8:	03253023          	sd	s2,32(a0)
    800026cc:	03353423          	sd	s3,40(a0)
    800026d0:	03453823          	sd	s4,48(a0)
    800026d4:	03553c23          	sd	s5,56(a0)
    800026d8:	05653023          	sd	s6,64(a0)
    800026dc:	05753423          	sd	s7,72(a0)
    800026e0:	05853823          	sd	s8,80(a0)
    800026e4:	05953c23          	sd	s9,88(a0)
    800026e8:	07a53023          	sd	s10,96(a0)
    800026ec:	07b53423          	sd	s11,104(a0)
    800026f0:	0005b083          	ld	ra,0(a1)
    800026f4:	0085b103          	ld	sp,8(a1)
    800026f8:	6980                	ld	s0,16(a1)
    800026fa:	6d84                	ld	s1,24(a1)
    800026fc:	0205b903          	ld	s2,32(a1)
    80002700:	0285b983          	ld	s3,40(a1)
    80002704:	0305ba03          	ld	s4,48(a1)
    80002708:	0385ba83          	ld	s5,56(a1)
    8000270c:	0405bb03          	ld	s6,64(a1)
    80002710:	0485bb83          	ld	s7,72(a1)
    80002714:	0505bc03          	ld	s8,80(a1)
    80002718:	0585bc83          	ld	s9,88(a1)
    8000271c:	0605bd03          	ld	s10,96(a1)
    80002720:	0685bd83          	ld	s11,104(a1)
    80002724:	8082                	ret

0000000080002726 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002726:	1141                	addi	sp,sp,-16
    80002728:	e406                	sd	ra,8(sp)
    8000272a:	e022                	sd	s0,0(sp)
    8000272c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000272e:	00005597          	auipc	a1,0x5
    80002732:	c8258593          	addi	a1,a1,-894 # 800073b0 <etext+0x3b0>
    80002736:	0001d517          	auipc	a0,0x1d
    8000273a:	eca50513          	addi	a0,a0,-310 # 8001f600 <tickslock>
    8000273e:	c3cfe0ef          	jal	80000b7a <initlock>
}
    80002742:	60a2                	ld	ra,8(sp)
    80002744:	6402                	ld	s0,0(sp)
    80002746:	0141                	addi	sp,sp,16
    80002748:	8082                	ret

000000008000274a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000274a:	1141                	addi	sp,sp,-16
    8000274c:	e406                	sd	ra,8(sp)
    8000274e:	e022                	sd	s0,0(sp)
    80002750:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002752:	00003797          	auipc	a5,0x3
    80002756:	04e78793          	addi	a5,a5,78 # 800057a0 <kernelvec>
    8000275a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000275e:	60a2                	ld	ra,8(sp)
    80002760:	6402                	ld	s0,0(sp)
    80002762:	0141                	addi	sp,sp,16
    80002764:	8082                	ret

0000000080002766 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002766:	1141                	addi	sp,sp,-16
    80002768:	e406                	sd	ra,8(sp)
    8000276a:	e022                	sd	s0,0(sp)
    8000276c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000276e:	96eff0ef          	jal	800018dc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002772:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002776:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002778:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000277c:	00004697          	auipc	a3,0x4
    80002780:	88468693          	addi	a3,a3,-1916 # 80006000 <_trampoline>
    80002784:	00004717          	auipc	a4,0x4
    80002788:	87c70713          	addi	a4,a4,-1924 # 80006000 <_trampoline>
    8000278c:	8f15                	sub	a4,a4,a3
    8000278e:	040007b7          	lui	a5,0x4000
    80002792:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002794:	07b2                	slli	a5,a5,0xc
    80002796:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002798:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000279c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000279e:	18002673          	csrr	a2,satp
    800027a2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027a4:	6d30                	ld	a2,88(a0)
    800027a6:	6138                	ld	a4,64(a0)
    800027a8:	6585                	lui	a1,0x1
    800027aa:	972e                	add	a4,a4,a1
    800027ac:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027ae:	6d38                	ld	a4,88(a0)
    800027b0:	00000617          	auipc	a2,0x0
    800027b4:	11060613          	addi	a2,a2,272 # 800028c0 <usertrap>
    800027b8:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027ba:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027bc:	8612                	mv	a2,tp
    800027be:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027c0:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027c4:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027c8:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027cc:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027d0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027d2:	6f18                	ld	a4,24(a4)
    800027d4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027d8:	6928                	ld	a0,80(a0)
    800027da:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800027dc:	00004717          	auipc	a4,0x4
    800027e0:	8c070713          	addi	a4,a4,-1856 # 8000609c <userret>
    800027e4:	8f15                	sub	a4,a4,a3
    800027e6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800027e8:	577d                	li	a4,-1
    800027ea:	177e                	slli	a4,a4,0x3f
    800027ec:	8d59                	or	a0,a0,a4
    800027ee:	9782                	jalr	a5
}
    800027f0:	60a2                	ld	ra,8(sp)
    800027f2:	6402                	ld	s0,0(sp)
    800027f4:	0141                	addi	sp,sp,16
    800027f6:	8082                	ret

00000000800027f8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027f8:	1101                	addi	sp,sp,-32
    800027fa:	ec06                	sd	ra,24(sp)
    800027fc:	e822                	sd	s0,16(sp)
    800027fe:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002800:	8a8ff0ef          	jal	800018a8 <cpuid>
    80002804:	cd11                	beqz	a0,80002820 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002806:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000280a:	000f4737          	lui	a4,0xf4
    8000280e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002812:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002814:	14d79073          	csrw	stimecmp,a5
}
    80002818:	60e2                	ld	ra,24(sp)
    8000281a:	6442                	ld	s0,16(sp)
    8000281c:	6105                	addi	sp,sp,32
    8000281e:	8082                	ret
    80002820:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002822:	0001d497          	auipc	s1,0x1d
    80002826:	dde48493          	addi	s1,s1,-546 # 8001f600 <tickslock>
    8000282a:	8526                	mv	a0,s1
    8000282c:	bd2fe0ef          	jal	80000bfe <acquire>
    ticks++;
    80002830:	00005517          	auipc	a0,0x5
    80002834:	27850513          	addi	a0,a0,632 # 80007aa8 <ticks>
    80002838:	411c                	lw	a5,0(a0)
    8000283a:	2785                	addiw	a5,a5,1
    8000283c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000283e:	a3dff0ef          	jal	8000227a <wakeup>
    release(&tickslock);
    80002842:	8526                	mv	a0,s1
    80002844:	c4efe0ef          	jal	80000c92 <release>
    80002848:	64a2                	ld	s1,8(sp)
    8000284a:	bf75                	j	80002806 <clockintr+0xe>

000000008000284c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000284c:	1101                	addi	sp,sp,-32
    8000284e:	ec06                	sd	ra,24(sp)
    80002850:	e822                	sd	s0,16(sp)
    80002852:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002854:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002858:	57fd                	li	a5,-1
    8000285a:	17fe                	slli	a5,a5,0x3f
    8000285c:	07a5                	addi	a5,a5,9
    8000285e:	00f70c63          	beq	a4,a5,80002876 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002862:	57fd                	li	a5,-1
    80002864:	17fe                	slli	a5,a5,0x3f
    80002866:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002868:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000286a:	04f70763          	beq	a4,a5,800028b8 <devintr+0x6c>
  }
}
    8000286e:	60e2                	ld	ra,24(sp)
    80002870:	6442                	ld	s0,16(sp)
    80002872:	6105                	addi	sp,sp,32
    80002874:	8082                	ret
    80002876:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002878:	7d5020ef          	jal	8000584c <plic_claim>
    8000287c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000287e:	47a9                	li	a5,10
    80002880:	00f50963          	beq	a0,a5,80002892 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002884:	4785                	li	a5,1
    80002886:	00f50963          	beq	a0,a5,80002898 <devintr+0x4c>
    return 1;
    8000288a:	4505                	li	a0,1
    } else if(irq){
    8000288c:	e889                	bnez	s1,8000289e <devintr+0x52>
    8000288e:	64a2                	ld	s1,8(sp)
    80002890:	bff9                	j	8000286e <devintr+0x22>
      uartintr();
    80002892:	97afe0ef          	jal	80000a0c <uartintr>
    if(irq)
    80002896:	a819                	j	800028ac <devintr+0x60>
      virtio_disk_intr();
    80002898:	444030ef          	jal	80005cdc <virtio_disk_intr>
    if(irq)
    8000289c:	a801                	j	800028ac <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000289e:	85a6                	mv	a1,s1
    800028a0:	00005517          	auipc	a0,0x5
    800028a4:	b1850513          	addi	a0,a0,-1256 # 800073b8 <etext+0x3b8>
    800028a8:	c27fd0ef          	jal	800004ce <printf>
      plic_complete(irq);
    800028ac:	8526                	mv	a0,s1
    800028ae:	7bf020ef          	jal	8000586c <plic_complete>
    return 1;
    800028b2:	4505                	li	a0,1
    800028b4:	64a2                	ld	s1,8(sp)
    800028b6:	bf65                	j	8000286e <devintr+0x22>
    clockintr();
    800028b8:	f41ff0ef          	jal	800027f8 <clockintr>
    return 2;
    800028bc:	4509                	li	a0,2
    800028be:	bf45                	j	8000286e <devintr+0x22>

00000000800028c0 <usertrap>:
{
    800028c0:	1101                	addi	sp,sp,-32
    800028c2:	ec06                	sd	ra,24(sp)
    800028c4:	e822                	sd	s0,16(sp)
    800028c6:	e426                	sd	s1,8(sp)
    800028c8:	e04a                	sd	s2,0(sp)
    800028ca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028cc:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028d0:	1007f793          	andi	a5,a5,256
    800028d4:	ef85                	bnez	a5,8000290c <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028d6:	00003797          	auipc	a5,0x3
    800028da:	eca78793          	addi	a5,a5,-310 # 800057a0 <kernelvec>
    800028de:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028e2:	ffbfe0ef          	jal	800018dc <myproc>
    800028e6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028e8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ea:	14102773          	csrr	a4,sepc
    800028ee:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028f0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028f4:	47a1                	li	a5,8
    800028f6:	02f70163          	beq	a4,a5,80002918 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800028fa:	f53ff0ef          	jal	8000284c <devintr>
    800028fe:	892a                	mv	s2,a0
    80002900:	c135                	beqz	a0,80002964 <usertrap+0xa4>
  if(killed(p))
    80002902:	8526                	mv	a0,s1
    80002904:	b63ff0ef          	jal	80002466 <killed>
    80002908:	cd1d                	beqz	a0,80002946 <usertrap+0x86>
    8000290a:	a81d                	j	80002940 <usertrap+0x80>
    panic("usertrap: not from user mode");
    8000290c:	00005517          	auipc	a0,0x5
    80002910:	acc50513          	addi	a0,a0,-1332 # 800073d8 <etext+0x3d8>
    80002914:	e8bfd0ef          	jal	8000079e <panic>
    if(killed(p))
    80002918:	b4fff0ef          	jal	80002466 <killed>
    8000291c:	e121                	bnez	a0,8000295c <usertrap+0x9c>
    p->trapframe->epc += 4;
    8000291e:	6cb8                	ld	a4,88(s1)
    80002920:	6f1c                	ld	a5,24(a4)
    80002922:	0791                	addi	a5,a5,4
    80002924:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002926:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000292a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000292e:	10079073          	csrw	sstatus,a5
    syscall();
    80002932:	240000ef          	jal	80002b72 <syscall>
  if(killed(p))
    80002936:	8526                	mv	a0,s1
    80002938:	b2fff0ef          	jal	80002466 <killed>
    8000293c:	c901                	beqz	a0,8000294c <usertrap+0x8c>
    8000293e:	4901                	li	s2,0
    exit(-1);
    80002940:	557d                	li	a0,-1
    80002942:	9f9ff0ef          	jal	8000233a <exit>
  if(which_dev == 2)
    80002946:	4789                	li	a5,2
    80002948:	04f90563          	beq	s2,a5,80002992 <usertrap+0xd2>
  usertrapret();
    8000294c:	e1bff0ef          	jal	80002766 <usertrapret>
}
    80002950:	60e2                	ld	ra,24(sp)
    80002952:	6442                	ld	s0,16(sp)
    80002954:	64a2                	ld	s1,8(sp)
    80002956:	6902                	ld	s2,0(sp)
    80002958:	6105                	addi	sp,sp,32
    8000295a:	8082                	ret
      exit(-1);
    8000295c:	557d                	li	a0,-1
    8000295e:	9ddff0ef          	jal	8000233a <exit>
    80002962:	bf75                	j	8000291e <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002964:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002968:	5890                	lw	a2,48(s1)
    8000296a:	00005517          	auipc	a0,0x5
    8000296e:	a8e50513          	addi	a0,a0,-1394 # 800073f8 <etext+0x3f8>
    80002972:	b5dfd0ef          	jal	800004ce <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002976:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000297a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000297e:	00005517          	auipc	a0,0x5
    80002982:	aaa50513          	addi	a0,a0,-1366 # 80007428 <etext+0x428>
    80002986:	b49fd0ef          	jal	800004ce <printf>
    setkilled(p);
    8000298a:	8526                	mv	a0,s1
    8000298c:	ab7ff0ef          	jal	80002442 <setkilled>
    80002990:	b75d                	j	80002936 <usertrap+0x76>
    yield();
    80002992:	871ff0ef          	jal	80002202 <yield>
    80002996:	bf5d                	j	8000294c <usertrap+0x8c>

0000000080002998 <kerneltrap>:
{
    80002998:	7179                	addi	sp,sp,-48
    8000299a:	f406                	sd	ra,40(sp)
    8000299c:	f022                	sd	s0,32(sp)
    8000299e:	ec26                	sd	s1,24(sp)
    800029a0:	e84a                	sd	s2,16(sp)
    800029a2:	e44e                	sd	s3,8(sp)
    800029a4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029a6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029aa:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ae:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029b2:	1004f793          	andi	a5,s1,256
    800029b6:	c795                	beqz	a5,800029e2 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029bc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029be:	eb85                	bnez	a5,800029ee <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800029c0:	e8dff0ef          	jal	8000284c <devintr>
    800029c4:	c91d                	beqz	a0,800029fa <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800029c6:	4789                	li	a5,2
    800029c8:	04f50a63          	beq	a0,a5,80002a1c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029cc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029d0:	10049073          	csrw	sstatus,s1
}
    800029d4:	70a2                	ld	ra,40(sp)
    800029d6:	7402                	ld	s0,32(sp)
    800029d8:	64e2                	ld	s1,24(sp)
    800029da:	6942                	ld	s2,16(sp)
    800029dc:	69a2                	ld	s3,8(sp)
    800029de:	6145                	addi	sp,sp,48
    800029e0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029e2:	00005517          	auipc	a0,0x5
    800029e6:	a6e50513          	addi	a0,a0,-1426 # 80007450 <etext+0x450>
    800029ea:	db5fd0ef          	jal	8000079e <panic>
    panic("kerneltrap: interrupts enabled");
    800029ee:	00005517          	auipc	a0,0x5
    800029f2:	a8a50513          	addi	a0,a0,-1398 # 80007478 <etext+0x478>
    800029f6:	da9fd0ef          	jal	8000079e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029fa:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029fe:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002a02:	85ce                	mv	a1,s3
    80002a04:	00005517          	auipc	a0,0x5
    80002a08:	a9450513          	addi	a0,a0,-1388 # 80007498 <etext+0x498>
    80002a0c:	ac3fd0ef          	jal	800004ce <printf>
    panic("kerneltrap");
    80002a10:	00005517          	auipc	a0,0x5
    80002a14:	ab050513          	addi	a0,a0,-1360 # 800074c0 <etext+0x4c0>
    80002a18:	d87fd0ef          	jal	8000079e <panic>
  if(which_dev == 2 && myproc() != 0)
    80002a1c:	ec1fe0ef          	jal	800018dc <myproc>
    80002a20:	d555                	beqz	a0,800029cc <kerneltrap+0x34>
    yield();
    80002a22:	fe0ff0ef          	jal	80002202 <yield>
    80002a26:	b75d                	j	800029cc <kerneltrap+0x34>

0000000080002a28 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a28:	1101                	addi	sp,sp,-32
    80002a2a:	ec06                	sd	ra,24(sp)
    80002a2c:	e822                	sd	s0,16(sp)
    80002a2e:	e426                	sd	s1,8(sp)
    80002a30:	1000                	addi	s0,sp,32
    80002a32:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a34:	ea9fe0ef          	jal	800018dc <myproc>
  switch (n) {
    80002a38:	4795                	li	a5,5
    80002a3a:	0497e163          	bltu	a5,s1,80002a7c <argraw+0x54>
    80002a3e:	048a                	slli	s1,s1,0x2
    80002a40:	00005717          	auipc	a4,0x5
    80002a44:	f0070713          	addi	a4,a4,-256 # 80007940 <states.0+0x30>
    80002a48:	94ba                	add	s1,s1,a4
    80002a4a:	409c                	lw	a5,0(s1)
    80002a4c:	97ba                	add	a5,a5,a4
    80002a4e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a50:	6d3c                	ld	a5,88(a0)
    80002a52:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a54:	60e2                	ld	ra,24(sp)
    80002a56:	6442                	ld	s0,16(sp)
    80002a58:	64a2                	ld	s1,8(sp)
    80002a5a:	6105                	addi	sp,sp,32
    80002a5c:	8082                	ret
    return p->trapframe->a1;
    80002a5e:	6d3c                	ld	a5,88(a0)
    80002a60:	7fa8                	ld	a0,120(a5)
    80002a62:	bfcd                	j	80002a54 <argraw+0x2c>
    return p->trapframe->a2;
    80002a64:	6d3c                	ld	a5,88(a0)
    80002a66:	63c8                	ld	a0,128(a5)
    80002a68:	b7f5                	j	80002a54 <argraw+0x2c>
    return p->trapframe->a3;
    80002a6a:	6d3c                	ld	a5,88(a0)
    80002a6c:	67c8                	ld	a0,136(a5)
    80002a6e:	b7dd                	j	80002a54 <argraw+0x2c>
    return p->trapframe->a4;
    80002a70:	6d3c                	ld	a5,88(a0)
    80002a72:	6bc8                	ld	a0,144(a5)
    80002a74:	b7c5                	j	80002a54 <argraw+0x2c>
    return p->trapframe->a5;
    80002a76:	6d3c                	ld	a5,88(a0)
    80002a78:	6fc8                	ld	a0,152(a5)
    80002a7a:	bfe9                	j	80002a54 <argraw+0x2c>
  panic("argraw");
    80002a7c:	00005517          	auipc	a0,0x5
    80002a80:	a5450513          	addi	a0,a0,-1452 # 800074d0 <etext+0x4d0>
    80002a84:	d1bfd0ef          	jal	8000079e <panic>

0000000080002a88 <fetchaddr>:
{
    80002a88:	1101                	addi	sp,sp,-32
    80002a8a:	ec06                	sd	ra,24(sp)
    80002a8c:	e822                	sd	s0,16(sp)
    80002a8e:	e426                	sd	s1,8(sp)
    80002a90:	e04a                	sd	s2,0(sp)
    80002a92:	1000                	addi	s0,sp,32
    80002a94:	84aa                	mv	s1,a0
    80002a96:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a98:	e45fe0ef          	jal	800018dc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a9c:	653c                	ld	a5,72(a0)
    80002a9e:	02f4f663          	bgeu	s1,a5,80002aca <fetchaddr+0x42>
    80002aa2:	00848713          	addi	a4,s1,8
    80002aa6:	02e7e463          	bltu	a5,a4,80002ace <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002aaa:	46a1                	li	a3,8
    80002aac:	8626                	mv	a2,s1
    80002aae:	85ca                	mv	a1,s2
    80002ab0:	6928                	ld	a0,80(a0)
    80002ab2:	b83fe0ef          	jal	80001634 <copyin>
    80002ab6:	00a03533          	snez	a0,a0
    80002aba:	40a0053b          	negw	a0,a0
}
    80002abe:	60e2                	ld	ra,24(sp)
    80002ac0:	6442                	ld	s0,16(sp)
    80002ac2:	64a2                	ld	s1,8(sp)
    80002ac4:	6902                	ld	s2,0(sp)
    80002ac6:	6105                	addi	sp,sp,32
    80002ac8:	8082                	ret
    return -1;
    80002aca:	557d                	li	a0,-1
    80002acc:	bfcd                	j	80002abe <fetchaddr+0x36>
    80002ace:	557d                	li	a0,-1
    80002ad0:	b7fd                	j	80002abe <fetchaddr+0x36>

0000000080002ad2 <fetchstr>:
{
    80002ad2:	7179                	addi	sp,sp,-48
    80002ad4:	f406                	sd	ra,40(sp)
    80002ad6:	f022                	sd	s0,32(sp)
    80002ad8:	ec26                	sd	s1,24(sp)
    80002ada:	e84a                	sd	s2,16(sp)
    80002adc:	e44e                	sd	s3,8(sp)
    80002ade:	1800                	addi	s0,sp,48
    80002ae0:	892a                	mv	s2,a0
    80002ae2:	84ae                	mv	s1,a1
    80002ae4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ae6:	df7fe0ef          	jal	800018dc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002aea:	86ce                	mv	a3,s3
    80002aec:	864a                	mv	a2,s2
    80002aee:	85a6                	mv	a1,s1
    80002af0:	6928                	ld	a0,80(a0)
    80002af2:	bc9fe0ef          	jal	800016ba <copyinstr>
    80002af6:	00054c63          	bltz	a0,80002b0e <fetchstr+0x3c>
  return strlen(buf);
    80002afa:	8526                	mv	a0,s1
    80002afc:	b5afe0ef          	jal	80000e56 <strlen>
}
    80002b00:	70a2                	ld	ra,40(sp)
    80002b02:	7402                	ld	s0,32(sp)
    80002b04:	64e2                	ld	s1,24(sp)
    80002b06:	6942                	ld	s2,16(sp)
    80002b08:	69a2                	ld	s3,8(sp)
    80002b0a:	6145                	addi	sp,sp,48
    80002b0c:	8082                	ret
    return -1;
    80002b0e:	557d                	li	a0,-1
    80002b10:	bfc5                	j	80002b00 <fetchstr+0x2e>

0000000080002b12 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b12:	1101                	addi	sp,sp,-32
    80002b14:	ec06                	sd	ra,24(sp)
    80002b16:	e822                	sd	s0,16(sp)
    80002b18:	e426                	sd	s1,8(sp)
    80002b1a:	1000                	addi	s0,sp,32
    80002b1c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b1e:	f0bff0ef          	jal	80002a28 <argraw>
    80002b22:	c088                	sw	a0,0(s1)
}
    80002b24:	60e2                	ld	ra,24(sp)
    80002b26:	6442                	ld	s0,16(sp)
    80002b28:	64a2                	ld	s1,8(sp)
    80002b2a:	6105                	addi	sp,sp,32
    80002b2c:	8082                	ret

0000000080002b2e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b2e:	1101                	addi	sp,sp,-32
    80002b30:	ec06                	sd	ra,24(sp)
    80002b32:	e822                	sd	s0,16(sp)
    80002b34:	e426                	sd	s1,8(sp)
    80002b36:	1000                	addi	s0,sp,32
    80002b38:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b3a:	eefff0ef          	jal	80002a28 <argraw>
    80002b3e:	e088                	sd	a0,0(s1)
}
    80002b40:	60e2                	ld	ra,24(sp)
    80002b42:	6442                	ld	s0,16(sp)
    80002b44:	64a2                	ld	s1,8(sp)
    80002b46:	6105                	addi	sp,sp,32
    80002b48:	8082                	ret

0000000080002b4a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b4a:	1101                	addi	sp,sp,-32
    80002b4c:	ec06                	sd	ra,24(sp)
    80002b4e:	e822                	sd	s0,16(sp)
    80002b50:	e426                	sd	s1,8(sp)
    80002b52:	e04a                	sd	s2,0(sp)
    80002b54:	1000                	addi	s0,sp,32
    80002b56:	84ae                	mv	s1,a1
    80002b58:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b5a:	ecfff0ef          	jal	80002a28 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002b5e:	864a                	mv	a2,s2
    80002b60:	85a6                	mv	a1,s1
    80002b62:	f71ff0ef          	jal	80002ad2 <fetchstr>
}
    80002b66:	60e2                	ld	ra,24(sp)
    80002b68:	6442                	ld	s0,16(sp)
    80002b6a:	64a2                	ld	s1,8(sp)
    80002b6c:	6902                	ld	s2,0(sp)
    80002b6e:	6105                	addi	sp,sp,32
    80002b70:	8082                	ret

0000000080002b72 <syscall>:
};


void
syscall(void)
{
    80002b72:	7139                	addi	sp,sp,-64
    80002b74:	fc06                	sd	ra,56(sp)
    80002b76:	f822                	sd	s0,48(sp)
    80002b78:	f426                	sd	s1,40(sp)
    80002b7a:	f04a                	sd	s2,32(sp)
    80002b7c:	0080                	addi	s0,sp,64
  int num;
  struct proc *p = myproc();
    80002b7e:	d5ffe0ef          	jal	800018dc <myproc>
    80002b82:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b84:	6d3c                	ld	a5,88(a0)
    80002b86:	77dc                	ld	a5,168(a5)
    80002b88:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b8c:	37fd                	addiw	a5,a5,-1
    80002b8e:	4759                	li	a4,22
    80002b90:	08f76f63          	bltu	a4,a5,80002c2e <syscall+0xbc>
    80002b94:	ec4e                	sd	s3,24(sp)
    80002b96:	00391713          	slli	a4,s2,0x3
    80002b9a:	00005797          	auipc	a5,0x5
    80002b9e:	dbe78793          	addi	a5,a5,-578 # 80007958 <syscalls>
    80002ba2:	97ba                	add	a5,a5,a4
    80002ba4:	0007b983          	ld	s3,0(a5)
    80002ba8:	08098263          	beqz	s3,80002c2c <syscall+0xba>
    80002bac:	e852                	sd	s4,16(sp)
    80002bae:	e456                	sd	s5,8(sp)
    80002bb0:	e05a                	sd	s6,0(sp)
    acquire(&tickslock);
    80002bb2:	0001d517          	auipc	a0,0x1d
    80002bb6:	a4e50513          	addi	a0,a0,-1458 # 8001f600 <tickslock>
    80002bba:	844fe0ef          	jal	80000bfe <acquire>
    int start_ticks = ticks;
    80002bbe:	00005a97          	auipc	s5,0x5
    80002bc2:	eeaa8a93          	addi	s5,s5,-278 # 80007aa8 <ticks>
    80002bc6:	000aaa03          	lw	s4,0(s5)
    release(&tickslock);
    80002bca:	0001d517          	auipc	a0,0x1d
    80002bce:	a3650513          	addi	a0,a0,-1482 # 8001f600 <tickslock>
    80002bd2:	8c0fe0ef          	jal	80000c92 <release>
    p->trapframe->a0 = syscalls[num]();
    80002bd6:	0584bb03          	ld	s6,88(s1)
    80002bda:	9982                	jalr	s3
    80002bdc:	06ab3823          	sd	a0,112(s6)
    acquire(&tickslock);
    80002be0:	0001d517          	auipc	a0,0x1d
    80002be4:	a2050513          	addi	a0,a0,-1504 # 8001f600 <tickslock>
    80002be8:	816fe0ef          	jal	80000bfe <acquire>
    int end_ticks = ticks;
    80002bec:	000aa983          	lw	s3,0(s5)
    release(&tickslock);
    80002bf0:	0001d517          	auipc	a0,0x1d
    80002bf4:	a1050513          	addi	a0,a0,-1520 # 8001f600 <tickslock>
    80002bf8:	89afe0ef          	jal	80000c92 <release>

    struct syscall_stat *stat = &p->syscall_stats[num];
    stat->count++;
    80002bfc:	00191793          	slli	a5,s2,0x1
    80002c00:	01278733          	add	a4,a5,s2
    80002c04:	070e                	slli	a4,a4,0x3
    80002c06:	9726                	add	a4,a4,s1
    80002c08:	17872683          	lw	a3,376(a4)
    80002c0c:	2685                	addiw	a3,a3,1
    80002c0e:	16d72c23          	sw	a3,376(a4)
    stat->accum_time += (end_ticks - start_ticks);
    80002c12:	414989bb          	subw	s3,s3,s4
    80002c16:	17c72783          	lw	a5,380(a4)
    80002c1a:	013787bb          	addw	a5,a5,s3
    80002c1e:	16f72e23          	sw	a5,380(a4)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c22:	69e2                	ld	s3,24(sp)
    80002c24:	6a42                	ld	s4,16(sp)
    80002c26:	6aa2                	ld	s5,8(sp)
    80002c28:	6b02                	ld	s6,0(sp)
    80002c2a:	a839                	j	80002c48 <syscall+0xd6>
    80002c2c:	69e2                	ld	s3,24(sp)
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c2e:	86ca                	mv	a3,s2
    80002c30:	15848613          	addi	a2,s1,344
    80002c34:	588c                	lw	a1,48(s1)
    80002c36:	00005517          	auipc	a0,0x5
    80002c3a:	8a250513          	addi	a0,a0,-1886 # 800074d8 <etext+0x4d8>
    80002c3e:	891fd0ef          	jal	800004ce <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c42:	6cbc                	ld	a5,88(s1)
    80002c44:	577d                	li	a4,-1
    80002c46:	fbb8                	sd	a4,112(a5)
  }
}
    80002c48:	70e2                	ld	ra,56(sp)
    80002c4a:	7442                	ld	s0,48(sp)
    80002c4c:	74a2                	ld	s1,40(sp)
    80002c4e:	7902                	ld	s2,32(sp)
    80002c50:	6121                	addi	sp,sp,64
    80002c52:	8082                	ret

0000000080002c54 <sys_exit>:
#include "pstat.h"
extern struct proc proc[];

uint64
sys_exit(void)
{
    80002c54:	1101                	addi	sp,sp,-32
    80002c56:	ec06                	sd	ra,24(sp)
    80002c58:	e822                	sd	s0,16(sp)
    80002c5a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c5c:	fec40593          	addi	a1,s0,-20
    80002c60:	4501                	li	a0,0
    80002c62:	eb1ff0ef          	jal	80002b12 <argint>
  exit(n);
    80002c66:	fec42503          	lw	a0,-20(s0)
    80002c6a:	ed0ff0ef          	jal	8000233a <exit>
  return 0; // not reached
}
    80002c6e:	4501                	li	a0,0
    80002c70:	60e2                	ld	ra,24(sp)
    80002c72:	6442                	ld	s0,16(sp)
    80002c74:	6105                	addi	sp,sp,32
    80002c76:	8082                	ret

0000000080002c78 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c78:	1141                	addi	sp,sp,-16
    80002c7a:	e406                	sd	ra,8(sp)
    80002c7c:	e022                	sd	s0,0(sp)
    80002c7e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c80:	c5dfe0ef          	jal	800018dc <myproc>
}
    80002c84:	5908                	lw	a0,48(a0)
    80002c86:	60a2                	ld	ra,8(sp)
    80002c88:	6402                	ld	s0,0(sp)
    80002c8a:	0141                	addi	sp,sp,16
    80002c8c:	8082                	ret

0000000080002c8e <sys_fork>:

uint64
sys_fork(void)
{
    80002c8e:	1141                	addi	sp,sp,-16
    80002c90:	e406                	sd	ra,8(sp)
    80002c92:	e022                	sd	s0,0(sp)
    80002c94:	0800                	addi	s0,sp,16
  return fork();
    80002c96:	fd9fe0ef          	jal	80001c6e <fork>
}
    80002c9a:	60a2                	ld	ra,8(sp)
    80002c9c:	6402                	ld	s0,0(sp)
    80002c9e:	0141                	addi	sp,sp,16
    80002ca0:	8082                	ret

0000000080002ca2 <sys_wait>:

uint64
sys_wait(void)
{
    80002ca2:	1101                	addi	sp,sp,-32
    80002ca4:	ec06                	sd	ra,24(sp)
    80002ca6:	e822                	sd	s0,16(sp)
    80002ca8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002caa:	fe840593          	addi	a1,s0,-24
    80002cae:	4501                	li	a0,0
    80002cb0:	e7fff0ef          	jal	80002b2e <argaddr>
  return wait(p);
    80002cb4:	fe843503          	ld	a0,-24(s0)
    80002cb8:	fd8ff0ef          	jal	80002490 <wait>
}
    80002cbc:	60e2                	ld	ra,24(sp)
    80002cbe:	6442                	ld	s0,16(sp)
    80002cc0:	6105                	addi	sp,sp,32
    80002cc2:	8082                	ret

0000000080002cc4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cc4:	7179                	addi	sp,sp,-48
    80002cc6:	f406                	sd	ra,40(sp)
    80002cc8:	f022                	sd	s0,32(sp)
    80002cca:	ec26                	sd	s1,24(sp)
    80002ccc:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002cce:	fdc40593          	addi	a1,s0,-36
    80002cd2:	4501                	li	a0,0
    80002cd4:	e3fff0ef          	jal	80002b12 <argint>
  addr = myproc()->sz;
    80002cd8:	c05fe0ef          	jal	800018dc <myproc>
    80002cdc:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002cde:	fdc42503          	lw	a0,-36(s0)
    80002ce2:	f3dfe0ef          	jal	80001c1e <growproc>
    80002ce6:	00054863          	bltz	a0,80002cf6 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002cea:	8526                	mv	a0,s1
    80002cec:	70a2                	ld	ra,40(sp)
    80002cee:	7402                	ld	s0,32(sp)
    80002cf0:	64e2                	ld	s1,24(sp)
    80002cf2:	6145                	addi	sp,sp,48
    80002cf4:	8082                	ret
    return -1;
    80002cf6:	54fd                	li	s1,-1
    80002cf8:	bfcd                	j	80002cea <sys_sbrk+0x26>

0000000080002cfa <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cfa:	7139                	addi	sp,sp,-64
    80002cfc:	fc06                	sd	ra,56(sp)
    80002cfe:	f822                	sd	s0,48(sp)
    80002d00:	f04a                	sd	s2,32(sp)
    80002d02:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d04:	fcc40593          	addi	a1,s0,-52
    80002d08:	4501                	li	a0,0
    80002d0a:	e09ff0ef          	jal	80002b12 <argint>
  if (n < 0)
    80002d0e:	fcc42783          	lw	a5,-52(s0)
    80002d12:	0607c763          	bltz	a5,80002d80 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002d16:	0001d517          	auipc	a0,0x1d
    80002d1a:	8ea50513          	addi	a0,a0,-1814 # 8001f600 <tickslock>
    80002d1e:	ee1fd0ef          	jal	80000bfe <acquire>
  ticks0 = ticks;
    80002d22:	00005917          	auipc	s2,0x5
    80002d26:	d8692903          	lw	s2,-634(s2) # 80007aa8 <ticks>
  while (ticks - ticks0 < n)
    80002d2a:	fcc42783          	lw	a5,-52(s0)
    80002d2e:	cf8d                	beqz	a5,80002d68 <sys_sleep+0x6e>
    80002d30:	f426                	sd	s1,40(sp)
    80002d32:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d34:	0001d997          	auipc	s3,0x1d
    80002d38:	8cc98993          	addi	s3,s3,-1844 # 8001f600 <tickslock>
    80002d3c:	00005497          	auipc	s1,0x5
    80002d40:	d6c48493          	addi	s1,s1,-660 # 80007aa8 <ticks>
    if (killed(myproc()))
    80002d44:	b99fe0ef          	jal	800018dc <myproc>
    80002d48:	f1eff0ef          	jal	80002466 <killed>
    80002d4c:	ed0d                	bnez	a0,80002d86 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002d4e:	85ce                	mv	a1,s3
    80002d50:	8526                	mv	a0,s1
    80002d52:	cdcff0ef          	jal	8000222e <sleep>
  while (ticks - ticks0 < n)
    80002d56:	409c                	lw	a5,0(s1)
    80002d58:	412787bb          	subw	a5,a5,s2
    80002d5c:	fcc42703          	lw	a4,-52(s0)
    80002d60:	fee7e2e3          	bltu	a5,a4,80002d44 <sys_sleep+0x4a>
    80002d64:	74a2                	ld	s1,40(sp)
    80002d66:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d68:	0001d517          	auipc	a0,0x1d
    80002d6c:	89850513          	addi	a0,a0,-1896 # 8001f600 <tickslock>
    80002d70:	f23fd0ef          	jal	80000c92 <release>
  return 0;
    80002d74:	4501                	li	a0,0
}
    80002d76:	70e2                	ld	ra,56(sp)
    80002d78:	7442                	ld	s0,48(sp)
    80002d7a:	7902                	ld	s2,32(sp)
    80002d7c:	6121                	addi	sp,sp,64
    80002d7e:	8082                	ret
    n = 0;
    80002d80:	fc042623          	sw	zero,-52(s0)
    80002d84:	bf49                	j	80002d16 <sys_sleep+0x1c>
      release(&tickslock);
    80002d86:	0001d517          	auipc	a0,0x1d
    80002d8a:	87a50513          	addi	a0,a0,-1926 # 8001f600 <tickslock>
    80002d8e:	f05fd0ef          	jal	80000c92 <release>
      return -1;
    80002d92:	557d                	li	a0,-1
    80002d94:	74a2                	ld	s1,40(sp)
    80002d96:	69e2                	ld	s3,24(sp)
    80002d98:	bff9                	j	80002d76 <sys_sleep+0x7c>

0000000080002d9a <sys_kill>:

uint64
sys_kill(void)
{
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002da2:	fec40593          	addi	a1,s0,-20
    80002da6:	4501                	li	a0,0
    80002da8:	d6bff0ef          	jal	80002b12 <argint>
  return kill(pid);
    80002dac:	fec42503          	lw	a0,-20(s0)
    80002db0:	e2cff0ef          	jal	800023dc <kill>
}
    80002db4:	60e2                	ld	ra,24(sp)
    80002db6:	6442                	ld	s0,16(sp)
    80002db8:	6105                	addi	sp,sp,32
    80002dba:	8082                	ret

0000000080002dbc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dbc:	1101                	addi	sp,sp,-32
    80002dbe:	ec06                	sd	ra,24(sp)
    80002dc0:	e822                	sd	s0,16(sp)
    80002dc2:	e426                	sd	s1,8(sp)
    80002dc4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dc6:	0001d517          	auipc	a0,0x1d
    80002dca:	83a50513          	addi	a0,a0,-1990 # 8001f600 <tickslock>
    80002dce:	e31fd0ef          	jal	80000bfe <acquire>
  xticks = ticks;
    80002dd2:	00005497          	auipc	s1,0x5
    80002dd6:	cd64a483          	lw	s1,-810(s1) # 80007aa8 <ticks>
  release(&tickslock);
    80002dda:	0001d517          	auipc	a0,0x1d
    80002dde:	82650513          	addi	a0,a0,-2010 # 8001f600 <tickslock>
    80002de2:	eb1fd0ef          	jal	80000c92 <release>
  return xticks;
}
    80002de6:	02049513          	slli	a0,s1,0x20
    80002dea:	9101                	srli	a0,a0,0x20
    80002dec:	60e2                	ld	ra,24(sp)
    80002dee:	6442                	ld	s0,16(sp)
    80002df0:	64a2                	ld	s1,8(sp)
    80002df2:	6105                	addi	sp,sp,32
    80002df4:	8082                	ret

0000000080002df6 <sys_history>:

uint64 sys_history()
{
    80002df6:	7139                	addi	sp,sp,-64
    80002df8:	fc06                	sd	ra,56(sp)
    80002dfa:	f822                	sd	s0,48(sp)
    80002dfc:	0080                	addi	s0,sp,64
  int syscall_num;
  uint64 stat_addr;
  argint(0, &syscall_num);
    80002dfe:	fec40593          	addi	a1,s0,-20
    80002e02:	4501                	li	a0,0
    80002e04:	d0fff0ef          	jal	80002b12 <argint>
  argaddr(1, &stat_addr);
    80002e08:	fe040593          	addi	a1,s0,-32
    80002e0c:	4505                	li	a0,1
    80002e0e:	d21ff0ef          	jal	80002b2e <argaddr>
  struct proc *p = myproc();
    80002e12:	acbfe0ef          	jal	800018dc <myproc>
    80002e16:	872a                	mv	a4,a0
  if (syscall_num < 1 || syscall_num > NSYSCALL)
    80002e18:	fec42683          	lw	a3,-20(s0)
    80002e1c:	fff6861b          	addiw	a2,a3,-1
    80002e20:	47dd                	li	a5,23
    return -1;
    80002e22:	557d                	li	a0,-1
  if (syscall_num < 1 || syscall_num > NSYSCALL)
    80002e24:	02c7ec63          	bltu	a5,a2,80002e5c <sys_history+0x66>
  struct syscall_stat stat = p->syscall_stats[syscall_num];
    80002e28:	00169793          	slli	a5,a3,0x1
    80002e2c:	97b6                	add	a5,a5,a3
    80002e2e:	078e                	slli	a5,a5,0x3
    80002e30:	97ba                	add	a5,a5,a4
    80002e32:	1687b683          	ld	a3,360(a5)
    80002e36:	fcd43423          	sd	a3,-56(s0)
    80002e3a:	1707b683          	ld	a3,368(a5)
    80002e3e:	fcd43823          	sd	a3,-48(s0)
    80002e42:	1787b783          	ld	a5,376(a5)
    80002e46:	fcf43c23          	sd	a5,-40(s0)
  if (copyout(p->pagetable, stat_addr, (char *)&stat, sizeof(struct syscall_stat)) < 0)
    80002e4a:	46e1                	li	a3,24
    80002e4c:	fc840613          	addi	a2,s0,-56
    80002e50:	fe043583          	ld	a1,-32(s0)
    80002e54:	6b28                	ld	a0,80(a4)
    80002e56:	f2efe0ef          	jal	80001584 <copyout>
    80002e5a:	957d                	srai	a0,a0,0x3f
    return -1;
  return 0;
}
    80002e5c:	70e2                	ld	ra,56(sp)
    80002e5e:	7442                	ld	s0,48(sp)
    80002e60:	6121                	addi	sp,sp,64
    80002e62:	8082                	ret

0000000080002e64 <sys_settickets>:

uint64 sys_settickets()
{
    80002e64:	7179                	addi	sp,sp,-48
    80002e66:	f406                	sd	ra,40(sp)
    80002e68:	f022                	sd	s0,32(sp)
    80002e6a:	ec26                	sd	s1,24(sp)
    80002e6c:	1800                	addi	s0,sp,48
  int n;
  argint(0, &n);
    80002e6e:	fdc40593          	addi	a1,s0,-36
    80002e72:	4501                	li	a0,0
    80002e74:	c9fff0ef          	jal	80002b12 <argint>
  struct proc *p = myproc();
    80002e78:	a65fe0ef          	jal	800018dc <myproc>
    80002e7c:	84aa                	mv	s1,a0

  if (n < 1)
    80002e7e:	fdc42783          	lw	a5,-36(s0)
    80002e82:	02f05363          	blez	a5,80002ea8 <sys_settickets+0x44>
    p->Current_tickets = DEFAULT_TICKET_COUNT;
    release(&p->lock);
    return -1;
  }

  acquire(&p->lock);
    80002e86:	d79fd0ef          	jal	80000bfe <acquire>
  p->Original_tickets = n;
    80002e8a:	fdc42783          	lw	a5,-36(s0)
    80002e8e:	3cf4a023          	sw	a5,960(s1)
  p->Current_tickets = n;
    80002e92:	3cf4a223          	sw	a5,964(s1)
  release(&p->lock);
    80002e96:	8526                	mv	a0,s1
    80002e98:	dfbfd0ef          	jal	80000c92 <release>
  return 0;
    80002e9c:	4501                	li	a0,0
}
    80002e9e:	70a2                	ld	ra,40(sp)
    80002ea0:	7402                	ld	s0,32(sp)
    80002ea2:	64e2                	ld	s1,24(sp)
    80002ea4:	6145                	addi	sp,sp,48
    80002ea6:	8082                	ret
    acquire(&p->lock);
    80002ea8:	d57fd0ef          	jal	80000bfe <acquire>
    p->Original_tickets = DEFAULT_TICKET_COUNT;
    80002eac:	47a9                	li	a5,10
    80002eae:	3cf4a023          	sw	a5,960(s1)
    p->Current_tickets = DEFAULT_TICKET_COUNT;
    80002eb2:	3cf4a223          	sw	a5,964(s1)
    release(&p->lock);
    80002eb6:	8526                	mv	a0,s1
    80002eb8:	ddbfd0ef          	jal	80000c92 <release>
    return -1;
    80002ebc:	557d                	li	a0,-1
    80002ebe:	b7c5                	j	80002e9e <sys_settickets+0x3a>

0000000080002ec0 <sys_getpinfo>:


uint64 sys_getpinfo(void)
{
    80002ec0:	9c010113          	addi	sp,sp,-1600
    80002ec4:	62113c23          	sd	ra,1592(sp)
    80002ec8:	62813823          	sd	s0,1584(sp)
    80002ecc:	64010413          	addi	s0,sp,1600
  uint64 addr;
  struct proc *p;
  struct pstat st;
  
  // Get the user space address
  argaddr(0, &addr);
    80002ed0:	fc840593          	addi	a1,s0,-56
    80002ed4:	4501                	li	a0,0
    80002ed6:	c59ff0ef          	jal	80002b2e <argaddr>
    
  // Check for NULL pointer
  if (addr == 0)
    80002eda:	fc843783          	ld	a5,-56(s0)
    return -1;
    80002ede:	557d                	li	a0,-1
  if (addr == 0)
    80002ee0:	cfc1                	beqz	a5,80002f78 <sys_getpinfo+0xb8>
    80002ee2:	62913423          	sd	s1,1576(sp)
    80002ee6:	63213023          	sd	s2,1568(sp)
    80002eea:	61313c23          	sd	s3,1560(sp)

  // Initialize the pstat structure
  memset(&st, 0, sizeof(st));
    80002eee:	9c840913          	addi	s2,s0,-1592
    80002ef2:	60000613          	li	a2,1536
    80002ef6:	4581                	li	a1,0
    80002ef8:	854a                	mv	a0,s2
    80002efa:	dd5fd0ef          	jal	80000cce <memset>

  // Fill the pstat structure with process information
  for (int i = 0; i < NPROC; i++) {
    80002efe:	0000d497          	auipc	s1,0xd
    80002f02:	10248493          	addi	s1,s1,258 # 80010000 <proc>
    80002f06:	0001c997          	auipc	s3,0x1c
    80002f0a:	6fa98993          	addi	s3,s3,1786 # 8001f600 <tickslock>
    p = &proc[i];
    acquire(&p->lock);
    80002f0e:	8526                	mv	a0,s1
    80002f10:	ceffd0ef          	jal	80000bfe <acquire>
    
    st.pid[i] = p->pid;
    80002f14:	589c                	lw	a5,48(s1)
    80002f16:	00f92023          	sw	a5,0(s2)
    st.inuse[i] = (p->state != UNUSED);
    80002f1a:	4c9c                	lw	a5,24(s1)
    80002f1c:	00f037b3          	snez	a5,a5
    80002f20:	10f92023          	sw	a5,256(s2)
    st.inQ[i] = p->inq;
    80002f24:	3c84a783          	lw	a5,968(s1)
    80002f28:	20f92023          	sw	a5,512(s2)
    st.tickets_original[i] = p->Original_tickets;
    80002f2c:	3c04a783          	lw	a5,960(s1)
    80002f30:	30f92023          	sw	a5,768(s2)
    st.tickets_current[i] = p->Current_tickets;
    80002f34:	3c44a783          	lw	a5,964(s1)
    80002f38:	40f92023          	sw	a5,1024(s2)
    st.time_slices[i] = p->time_slices;
    80002f3c:	3cc4a783          	lw	a5,972(s1)
    80002f40:	50f92023          	sw	a5,1280(s2)
    
    release(&p->lock);
    80002f44:	8526                	mv	a0,s1
    80002f46:	d4dfd0ef          	jal	80000c92 <release>
  for (int i = 0; i < NPROC; i++) {
    80002f4a:	3d848493          	addi	s1,s1,984
    80002f4e:	0911                	addi	s2,s2,4
    80002f50:	fb349fe3          	bne	s1,s3,80002f0e <sys_getpinfo+0x4e>
  }

  // Copy the structure to user space
  if (copyout(myproc()->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80002f54:	989fe0ef          	jal	800018dc <myproc>
    80002f58:	60000693          	li	a3,1536
    80002f5c:	9c840613          	addi	a2,s0,-1592
    80002f60:	fc843583          	ld	a1,-56(s0)
    80002f64:	6928                	ld	a0,80(a0)
    80002f66:	e1efe0ef          	jal	80001584 <copyout>
    80002f6a:	957d                	srai	a0,a0,0x3f
    80002f6c:	62813483          	ld	s1,1576(sp)
    80002f70:	62013903          	ld	s2,1568(sp)
    80002f74:	61813983          	ld	s3,1560(sp)
    return -1;
    
  return 0;
    80002f78:	63813083          	ld	ra,1592(sp)
    80002f7c:	63013403          	ld	s0,1584(sp)
    80002f80:	64010113          	addi	sp,sp,1600
    80002f84:	8082                	ret

0000000080002f86 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f86:	7179                	addi	sp,sp,-48
    80002f88:	f406                	sd	ra,40(sp)
    80002f8a:	f022                	sd	s0,32(sp)
    80002f8c:	ec26                	sd	s1,24(sp)
    80002f8e:	e84a                	sd	s2,16(sp)
    80002f90:	e44e                	sd	s3,8(sp)
    80002f92:	e052                	sd	s4,0(sp)
    80002f94:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f96:	00004597          	auipc	a1,0x4
    80002f9a:	56258593          	addi	a1,a1,1378 # 800074f8 <etext+0x4f8>
    80002f9e:	0001c517          	auipc	a0,0x1c
    80002fa2:	67a50513          	addi	a0,a0,1658 # 8001f618 <bcache>
    80002fa6:	bd5fd0ef          	jal	80000b7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002faa:	00024797          	auipc	a5,0x24
    80002fae:	66e78793          	addi	a5,a5,1646 # 80027618 <bcache+0x8000>
    80002fb2:	00025717          	auipc	a4,0x25
    80002fb6:	8ce70713          	addi	a4,a4,-1842 # 80027880 <bcache+0x8268>
    80002fba:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002fbe:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fc2:	0001c497          	auipc	s1,0x1c
    80002fc6:	66e48493          	addi	s1,s1,1646 # 8001f630 <bcache+0x18>
    b->next = bcache.head.next;
    80002fca:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002fcc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fce:	00004a17          	auipc	s4,0x4
    80002fd2:	532a0a13          	addi	s4,s4,1330 # 80007500 <etext+0x500>
    b->next = bcache.head.next;
    80002fd6:	2b893783          	ld	a5,696(s2)
    80002fda:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002fdc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002fe0:	85d2                	mv	a1,s4
    80002fe2:	01048513          	addi	a0,s1,16
    80002fe6:	244010ef          	jal	8000422a <initsleeplock>
    bcache.head.next->prev = b;
    80002fea:	2b893783          	ld	a5,696(s2)
    80002fee:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002ff0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ff4:	45848493          	addi	s1,s1,1112
    80002ff8:	fd349fe3          	bne	s1,s3,80002fd6 <binit+0x50>
  }
}
    80002ffc:	70a2                	ld	ra,40(sp)
    80002ffe:	7402                	ld	s0,32(sp)
    80003000:	64e2                	ld	s1,24(sp)
    80003002:	6942                	ld	s2,16(sp)
    80003004:	69a2                	ld	s3,8(sp)
    80003006:	6a02                	ld	s4,0(sp)
    80003008:	6145                	addi	sp,sp,48
    8000300a:	8082                	ret

000000008000300c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000300c:	7179                	addi	sp,sp,-48
    8000300e:	f406                	sd	ra,40(sp)
    80003010:	f022                	sd	s0,32(sp)
    80003012:	ec26                	sd	s1,24(sp)
    80003014:	e84a                	sd	s2,16(sp)
    80003016:	e44e                	sd	s3,8(sp)
    80003018:	1800                	addi	s0,sp,48
    8000301a:	892a                	mv	s2,a0
    8000301c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000301e:	0001c517          	auipc	a0,0x1c
    80003022:	5fa50513          	addi	a0,a0,1530 # 8001f618 <bcache>
    80003026:	bd9fd0ef          	jal	80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000302a:	00025497          	auipc	s1,0x25
    8000302e:	8a64b483          	ld	s1,-1882(s1) # 800278d0 <bcache+0x82b8>
    80003032:	00025797          	auipc	a5,0x25
    80003036:	84e78793          	addi	a5,a5,-1970 # 80027880 <bcache+0x8268>
    8000303a:	02f48b63          	beq	s1,a5,80003070 <bread+0x64>
    8000303e:	873e                	mv	a4,a5
    80003040:	a021                	j	80003048 <bread+0x3c>
    80003042:	68a4                	ld	s1,80(s1)
    80003044:	02e48663          	beq	s1,a4,80003070 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003048:	449c                	lw	a5,8(s1)
    8000304a:	ff279ce3          	bne	a5,s2,80003042 <bread+0x36>
    8000304e:	44dc                	lw	a5,12(s1)
    80003050:	ff3799e3          	bne	a5,s3,80003042 <bread+0x36>
      b->refcnt++;
    80003054:	40bc                	lw	a5,64(s1)
    80003056:	2785                	addiw	a5,a5,1
    80003058:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000305a:	0001c517          	auipc	a0,0x1c
    8000305e:	5be50513          	addi	a0,a0,1470 # 8001f618 <bcache>
    80003062:	c31fd0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80003066:	01048513          	addi	a0,s1,16
    8000306a:	1f6010ef          	jal	80004260 <acquiresleep>
      return b;
    8000306e:	a889                	j	800030c0 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003070:	00025497          	auipc	s1,0x25
    80003074:	8584b483          	ld	s1,-1960(s1) # 800278c8 <bcache+0x82b0>
    80003078:	00025797          	auipc	a5,0x25
    8000307c:	80878793          	addi	a5,a5,-2040 # 80027880 <bcache+0x8268>
    80003080:	00f48863          	beq	s1,a5,80003090 <bread+0x84>
    80003084:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003086:	40bc                	lw	a5,64(s1)
    80003088:	cb91                	beqz	a5,8000309c <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000308a:	64a4                	ld	s1,72(s1)
    8000308c:	fee49de3          	bne	s1,a4,80003086 <bread+0x7a>
  panic("bget: no buffers");
    80003090:	00004517          	auipc	a0,0x4
    80003094:	47850513          	addi	a0,a0,1144 # 80007508 <etext+0x508>
    80003098:	f06fd0ef          	jal	8000079e <panic>
      b->dev = dev;
    8000309c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800030a0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800030a4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030a8:	4785                	li	a5,1
    800030aa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030ac:	0001c517          	auipc	a0,0x1c
    800030b0:	56c50513          	addi	a0,a0,1388 # 8001f618 <bcache>
    800030b4:	bdffd0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    800030b8:	01048513          	addi	a0,s1,16
    800030bc:	1a4010ef          	jal	80004260 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030c0:	409c                	lw	a5,0(s1)
    800030c2:	cb89                	beqz	a5,800030d4 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030c4:	8526                	mv	a0,s1
    800030c6:	70a2                	ld	ra,40(sp)
    800030c8:	7402                	ld	s0,32(sp)
    800030ca:	64e2                	ld	s1,24(sp)
    800030cc:	6942                	ld	s2,16(sp)
    800030ce:	69a2                	ld	s3,8(sp)
    800030d0:	6145                	addi	sp,sp,48
    800030d2:	8082                	ret
    virtio_disk_rw(b, 0);
    800030d4:	4581                	li	a1,0
    800030d6:	8526                	mv	a0,s1
    800030d8:	1f9020ef          	jal	80005ad0 <virtio_disk_rw>
    b->valid = 1;
    800030dc:	4785                	li	a5,1
    800030de:	c09c                	sw	a5,0(s1)
  return b;
    800030e0:	b7d5                	j	800030c4 <bread+0xb8>

00000000800030e2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800030e2:	1101                	addi	sp,sp,-32
    800030e4:	ec06                	sd	ra,24(sp)
    800030e6:	e822                	sd	s0,16(sp)
    800030e8:	e426                	sd	s1,8(sp)
    800030ea:	1000                	addi	s0,sp,32
    800030ec:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030ee:	0541                	addi	a0,a0,16
    800030f0:	1ee010ef          	jal	800042de <holdingsleep>
    800030f4:	c911                	beqz	a0,80003108 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800030f6:	4585                	li	a1,1
    800030f8:	8526                	mv	a0,s1
    800030fa:	1d7020ef          	jal	80005ad0 <virtio_disk_rw>
}
    800030fe:	60e2                	ld	ra,24(sp)
    80003100:	6442                	ld	s0,16(sp)
    80003102:	64a2                	ld	s1,8(sp)
    80003104:	6105                	addi	sp,sp,32
    80003106:	8082                	ret
    panic("bwrite");
    80003108:	00004517          	auipc	a0,0x4
    8000310c:	41850513          	addi	a0,a0,1048 # 80007520 <etext+0x520>
    80003110:	e8efd0ef          	jal	8000079e <panic>

0000000080003114 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003114:	1101                	addi	sp,sp,-32
    80003116:	ec06                	sd	ra,24(sp)
    80003118:	e822                	sd	s0,16(sp)
    8000311a:	e426                	sd	s1,8(sp)
    8000311c:	e04a                	sd	s2,0(sp)
    8000311e:	1000                	addi	s0,sp,32
    80003120:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003122:	01050913          	addi	s2,a0,16
    80003126:	854a                	mv	a0,s2
    80003128:	1b6010ef          	jal	800042de <holdingsleep>
    8000312c:	c125                	beqz	a0,8000318c <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    8000312e:	854a                	mv	a0,s2
    80003130:	176010ef          	jal	800042a6 <releasesleep>

  acquire(&bcache.lock);
    80003134:	0001c517          	auipc	a0,0x1c
    80003138:	4e450513          	addi	a0,a0,1252 # 8001f618 <bcache>
    8000313c:	ac3fd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80003140:	40bc                	lw	a5,64(s1)
    80003142:	37fd                	addiw	a5,a5,-1
    80003144:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003146:	e79d                	bnez	a5,80003174 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003148:	68b8                	ld	a4,80(s1)
    8000314a:	64bc                	ld	a5,72(s1)
    8000314c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000314e:	68b8                	ld	a4,80(s1)
    80003150:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003152:	00024797          	auipc	a5,0x24
    80003156:	4c678793          	addi	a5,a5,1222 # 80027618 <bcache+0x8000>
    8000315a:	2b87b703          	ld	a4,696(a5)
    8000315e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003160:	00024717          	auipc	a4,0x24
    80003164:	72070713          	addi	a4,a4,1824 # 80027880 <bcache+0x8268>
    80003168:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000316a:	2b87b703          	ld	a4,696(a5)
    8000316e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003170:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003174:	0001c517          	auipc	a0,0x1c
    80003178:	4a450513          	addi	a0,a0,1188 # 8001f618 <bcache>
    8000317c:	b17fd0ef          	jal	80000c92 <release>
}
    80003180:	60e2                	ld	ra,24(sp)
    80003182:	6442                	ld	s0,16(sp)
    80003184:	64a2                	ld	s1,8(sp)
    80003186:	6902                	ld	s2,0(sp)
    80003188:	6105                	addi	sp,sp,32
    8000318a:	8082                	ret
    panic("brelse");
    8000318c:	00004517          	auipc	a0,0x4
    80003190:	39c50513          	addi	a0,a0,924 # 80007528 <etext+0x528>
    80003194:	e0afd0ef          	jal	8000079e <panic>

0000000080003198 <bpin>:

void
bpin(struct buf *b) {
    80003198:	1101                	addi	sp,sp,-32
    8000319a:	ec06                	sd	ra,24(sp)
    8000319c:	e822                	sd	s0,16(sp)
    8000319e:	e426                	sd	s1,8(sp)
    800031a0:	1000                	addi	s0,sp,32
    800031a2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031a4:	0001c517          	auipc	a0,0x1c
    800031a8:	47450513          	addi	a0,a0,1140 # 8001f618 <bcache>
    800031ac:	a53fd0ef          	jal	80000bfe <acquire>
  b->refcnt++;
    800031b0:	40bc                	lw	a5,64(s1)
    800031b2:	2785                	addiw	a5,a5,1
    800031b4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031b6:	0001c517          	auipc	a0,0x1c
    800031ba:	46250513          	addi	a0,a0,1122 # 8001f618 <bcache>
    800031be:	ad5fd0ef          	jal	80000c92 <release>
}
    800031c2:	60e2                	ld	ra,24(sp)
    800031c4:	6442                	ld	s0,16(sp)
    800031c6:	64a2                	ld	s1,8(sp)
    800031c8:	6105                	addi	sp,sp,32
    800031ca:	8082                	ret

00000000800031cc <bunpin>:

void
bunpin(struct buf *b) {
    800031cc:	1101                	addi	sp,sp,-32
    800031ce:	ec06                	sd	ra,24(sp)
    800031d0:	e822                	sd	s0,16(sp)
    800031d2:	e426                	sd	s1,8(sp)
    800031d4:	1000                	addi	s0,sp,32
    800031d6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031d8:	0001c517          	auipc	a0,0x1c
    800031dc:	44050513          	addi	a0,a0,1088 # 8001f618 <bcache>
    800031e0:	a1ffd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    800031e4:	40bc                	lw	a5,64(s1)
    800031e6:	37fd                	addiw	a5,a5,-1
    800031e8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031ea:	0001c517          	auipc	a0,0x1c
    800031ee:	42e50513          	addi	a0,a0,1070 # 8001f618 <bcache>
    800031f2:	aa1fd0ef          	jal	80000c92 <release>
}
    800031f6:	60e2                	ld	ra,24(sp)
    800031f8:	6442                	ld	s0,16(sp)
    800031fa:	64a2                	ld	s1,8(sp)
    800031fc:	6105                	addi	sp,sp,32
    800031fe:	8082                	ret

0000000080003200 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003200:	1101                	addi	sp,sp,-32
    80003202:	ec06                	sd	ra,24(sp)
    80003204:	e822                	sd	s0,16(sp)
    80003206:	e426                	sd	s1,8(sp)
    80003208:	e04a                	sd	s2,0(sp)
    8000320a:	1000                	addi	s0,sp,32
    8000320c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000320e:	00d5d79b          	srliw	a5,a1,0xd
    80003212:	00025597          	auipc	a1,0x25
    80003216:	ae25a583          	lw	a1,-1310(a1) # 80027cf4 <sb+0x1c>
    8000321a:	9dbd                	addw	a1,a1,a5
    8000321c:	df1ff0ef          	jal	8000300c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003220:	0074f713          	andi	a4,s1,7
    80003224:	4785                	li	a5,1
    80003226:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000322a:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    8000322c:	90d9                	srli	s1,s1,0x36
    8000322e:	00950733          	add	a4,a0,s1
    80003232:	05874703          	lbu	a4,88(a4)
    80003236:	00e7f6b3          	and	a3,a5,a4
    8000323a:	c29d                	beqz	a3,80003260 <bfree+0x60>
    8000323c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000323e:	94aa                	add	s1,s1,a0
    80003240:	fff7c793          	not	a5,a5
    80003244:	8f7d                	and	a4,a4,a5
    80003246:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000324a:	711000ef          	jal	8000415a <log_write>
  brelse(bp);
    8000324e:	854a                	mv	a0,s2
    80003250:	ec5ff0ef          	jal	80003114 <brelse>
}
    80003254:	60e2                	ld	ra,24(sp)
    80003256:	6442                	ld	s0,16(sp)
    80003258:	64a2                	ld	s1,8(sp)
    8000325a:	6902                	ld	s2,0(sp)
    8000325c:	6105                	addi	sp,sp,32
    8000325e:	8082                	ret
    panic("freeing free block");
    80003260:	00004517          	auipc	a0,0x4
    80003264:	2d050513          	addi	a0,a0,720 # 80007530 <etext+0x530>
    80003268:	d36fd0ef          	jal	8000079e <panic>

000000008000326c <balloc>:
{
    8000326c:	715d                	addi	sp,sp,-80
    8000326e:	e486                	sd	ra,72(sp)
    80003270:	e0a2                	sd	s0,64(sp)
    80003272:	fc26                	sd	s1,56(sp)
    80003274:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003276:	00025797          	auipc	a5,0x25
    8000327a:	a667a783          	lw	a5,-1434(a5) # 80027cdc <sb+0x4>
    8000327e:	0e078863          	beqz	a5,8000336e <balloc+0x102>
    80003282:	f84a                	sd	s2,48(sp)
    80003284:	f44e                	sd	s3,40(sp)
    80003286:	f052                	sd	s4,32(sp)
    80003288:	ec56                	sd	s5,24(sp)
    8000328a:	e85a                	sd	s6,16(sp)
    8000328c:	e45e                	sd	s7,8(sp)
    8000328e:	e062                	sd	s8,0(sp)
    80003290:	8baa                	mv	s7,a0
    80003292:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003294:	00025b17          	auipc	s6,0x25
    80003298:	a44b0b13          	addi	s6,s6,-1468 # 80027cd8 <sb>
      m = 1 << (bi % 8);
    8000329c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000329e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032a0:	6c09                	lui	s8,0x2
    800032a2:	a09d                	j	80003308 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032a4:	97ca                	add	a5,a5,s2
    800032a6:	8e55                	or	a2,a2,a3
    800032a8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800032ac:	854a                	mv	a0,s2
    800032ae:	6ad000ef          	jal	8000415a <log_write>
        brelse(bp);
    800032b2:	854a                	mv	a0,s2
    800032b4:	e61ff0ef          	jal	80003114 <brelse>
  bp = bread(dev, bno);
    800032b8:	85a6                	mv	a1,s1
    800032ba:	855e                	mv	a0,s7
    800032bc:	d51ff0ef          	jal	8000300c <bread>
    800032c0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032c2:	40000613          	li	a2,1024
    800032c6:	4581                	li	a1,0
    800032c8:	05850513          	addi	a0,a0,88
    800032cc:	a03fd0ef          	jal	80000cce <memset>
  log_write(bp);
    800032d0:	854a                	mv	a0,s2
    800032d2:	689000ef          	jal	8000415a <log_write>
  brelse(bp);
    800032d6:	854a                	mv	a0,s2
    800032d8:	e3dff0ef          	jal	80003114 <brelse>
}
    800032dc:	7942                	ld	s2,48(sp)
    800032de:	79a2                	ld	s3,40(sp)
    800032e0:	7a02                	ld	s4,32(sp)
    800032e2:	6ae2                	ld	s5,24(sp)
    800032e4:	6b42                	ld	s6,16(sp)
    800032e6:	6ba2                	ld	s7,8(sp)
    800032e8:	6c02                	ld	s8,0(sp)
}
    800032ea:	8526                	mv	a0,s1
    800032ec:	60a6                	ld	ra,72(sp)
    800032ee:	6406                	ld	s0,64(sp)
    800032f0:	74e2                	ld	s1,56(sp)
    800032f2:	6161                	addi	sp,sp,80
    800032f4:	8082                	ret
    brelse(bp);
    800032f6:	854a                	mv	a0,s2
    800032f8:	e1dff0ef          	jal	80003114 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032fc:	015c0abb          	addw	s5,s8,s5
    80003300:	004b2783          	lw	a5,4(s6)
    80003304:	04fafe63          	bgeu	s5,a5,80003360 <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    80003308:	41fad79b          	sraiw	a5,s5,0x1f
    8000330c:	0137d79b          	srliw	a5,a5,0x13
    80003310:	015787bb          	addw	a5,a5,s5
    80003314:	40d7d79b          	sraiw	a5,a5,0xd
    80003318:	01cb2583          	lw	a1,28(s6)
    8000331c:	9dbd                	addw	a1,a1,a5
    8000331e:	855e                	mv	a0,s7
    80003320:	cedff0ef          	jal	8000300c <bread>
    80003324:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003326:	004b2503          	lw	a0,4(s6)
    8000332a:	84d6                	mv	s1,s5
    8000332c:	4701                	li	a4,0
    8000332e:	fca4f4e3          	bgeu	s1,a0,800032f6 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003332:	00777693          	andi	a3,a4,7
    80003336:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000333a:	41f7579b          	sraiw	a5,a4,0x1f
    8000333e:	01d7d79b          	srliw	a5,a5,0x1d
    80003342:	9fb9                	addw	a5,a5,a4
    80003344:	4037d79b          	sraiw	a5,a5,0x3
    80003348:	00f90633          	add	a2,s2,a5
    8000334c:	05864603          	lbu	a2,88(a2)
    80003350:	00c6f5b3          	and	a1,a3,a2
    80003354:	d9a1                	beqz	a1,800032a4 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003356:	2705                	addiw	a4,a4,1
    80003358:	2485                	addiw	s1,s1,1
    8000335a:	fd471ae3          	bne	a4,s4,8000332e <balloc+0xc2>
    8000335e:	bf61                	j	800032f6 <balloc+0x8a>
    80003360:	7942                	ld	s2,48(sp)
    80003362:	79a2                	ld	s3,40(sp)
    80003364:	7a02                	ld	s4,32(sp)
    80003366:	6ae2                	ld	s5,24(sp)
    80003368:	6b42                	ld	s6,16(sp)
    8000336a:	6ba2                	ld	s7,8(sp)
    8000336c:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    8000336e:	00004517          	auipc	a0,0x4
    80003372:	1da50513          	addi	a0,a0,474 # 80007548 <etext+0x548>
    80003376:	958fd0ef          	jal	800004ce <printf>
  return 0;
    8000337a:	4481                	li	s1,0
    8000337c:	b7bd                	j	800032ea <balloc+0x7e>

000000008000337e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000337e:	7179                	addi	sp,sp,-48
    80003380:	f406                	sd	ra,40(sp)
    80003382:	f022                	sd	s0,32(sp)
    80003384:	ec26                	sd	s1,24(sp)
    80003386:	e84a                	sd	s2,16(sp)
    80003388:	e44e                	sd	s3,8(sp)
    8000338a:	1800                	addi	s0,sp,48
    8000338c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000338e:	47ad                	li	a5,11
    80003390:	02b7e363          	bltu	a5,a1,800033b6 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80003394:	02059793          	slli	a5,a1,0x20
    80003398:	01e7d593          	srli	a1,a5,0x1e
    8000339c:	00b504b3          	add	s1,a0,a1
    800033a0:	0504a903          	lw	s2,80(s1)
    800033a4:	06091363          	bnez	s2,8000340a <bmap+0x8c>
      addr = balloc(ip->dev);
    800033a8:	4108                	lw	a0,0(a0)
    800033aa:	ec3ff0ef          	jal	8000326c <balloc>
    800033ae:	892a                	mv	s2,a0
      if(addr == 0)
    800033b0:	cd29                	beqz	a0,8000340a <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    800033b2:	c8a8                	sw	a0,80(s1)
    800033b4:	a899                	j	8000340a <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033b6:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    800033ba:	0ff00793          	li	a5,255
    800033be:	0697e963          	bltu	a5,s1,80003430 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033c2:	08052903          	lw	s2,128(a0)
    800033c6:	00091b63          	bnez	s2,800033dc <bmap+0x5e>
      addr = balloc(ip->dev);
    800033ca:	4108                	lw	a0,0(a0)
    800033cc:	ea1ff0ef          	jal	8000326c <balloc>
    800033d0:	892a                	mv	s2,a0
      if(addr == 0)
    800033d2:	cd05                	beqz	a0,8000340a <bmap+0x8c>
    800033d4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800033d6:	08a9a023          	sw	a0,128(s3)
    800033da:	a011                	j	800033de <bmap+0x60>
    800033dc:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800033de:	85ca                	mv	a1,s2
    800033e0:	0009a503          	lw	a0,0(s3)
    800033e4:	c29ff0ef          	jal	8000300c <bread>
    800033e8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033ea:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033ee:	02049713          	slli	a4,s1,0x20
    800033f2:	01e75593          	srli	a1,a4,0x1e
    800033f6:	00b784b3          	add	s1,a5,a1
    800033fa:	0004a903          	lw	s2,0(s1)
    800033fe:	00090e63          	beqz	s2,8000341a <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003402:	8552                	mv	a0,s4
    80003404:	d11ff0ef          	jal	80003114 <brelse>
    return addr;
    80003408:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000340a:	854a                	mv	a0,s2
    8000340c:	70a2                	ld	ra,40(sp)
    8000340e:	7402                	ld	s0,32(sp)
    80003410:	64e2                	ld	s1,24(sp)
    80003412:	6942                	ld	s2,16(sp)
    80003414:	69a2                	ld	s3,8(sp)
    80003416:	6145                	addi	sp,sp,48
    80003418:	8082                	ret
      addr = balloc(ip->dev);
    8000341a:	0009a503          	lw	a0,0(s3)
    8000341e:	e4fff0ef          	jal	8000326c <balloc>
    80003422:	892a                	mv	s2,a0
      if(addr){
    80003424:	dd79                	beqz	a0,80003402 <bmap+0x84>
        a[bn] = addr;
    80003426:	c088                	sw	a0,0(s1)
        log_write(bp);
    80003428:	8552                	mv	a0,s4
    8000342a:	531000ef          	jal	8000415a <log_write>
    8000342e:	bfd1                	j	80003402 <bmap+0x84>
    80003430:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003432:	00004517          	auipc	a0,0x4
    80003436:	12e50513          	addi	a0,a0,302 # 80007560 <etext+0x560>
    8000343a:	b64fd0ef          	jal	8000079e <panic>

000000008000343e <iget>:
{
    8000343e:	7179                	addi	sp,sp,-48
    80003440:	f406                	sd	ra,40(sp)
    80003442:	f022                	sd	s0,32(sp)
    80003444:	ec26                	sd	s1,24(sp)
    80003446:	e84a                	sd	s2,16(sp)
    80003448:	e44e                	sd	s3,8(sp)
    8000344a:	e052                	sd	s4,0(sp)
    8000344c:	1800                	addi	s0,sp,48
    8000344e:	89aa                	mv	s3,a0
    80003450:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003452:	00025517          	auipc	a0,0x25
    80003456:	8a650513          	addi	a0,a0,-1882 # 80027cf8 <itable>
    8000345a:	fa4fd0ef          	jal	80000bfe <acquire>
  empty = 0;
    8000345e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003460:	00025497          	auipc	s1,0x25
    80003464:	8b048493          	addi	s1,s1,-1872 # 80027d10 <itable+0x18>
    80003468:	00026697          	auipc	a3,0x26
    8000346c:	33868693          	addi	a3,a3,824 # 800297a0 <log>
    80003470:	a039                	j	8000347e <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003472:	02090963          	beqz	s2,800034a4 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003476:	08848493          	addi	s1,s1,136
    8000347a:	02d48863          	beq	s1,a3,800034aa <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000347e:	449c                	lw	a5,8(s1)
    80003480:	fef059e3          	blez	a5,80003472 <iget+0x34>
    80003484:	4098                	lw	a4,0(s1)
    80003486:	ff3716e3          	bne	a4,s3,80003472 <iget+0x34>
    8000348a:	40d8                	lw	a4,4(s1)
    8000348c:	ff4713e3          	bne	a4,s4,80003472 <iget+0x34>
      ip->ref++;
    80003490:	2785                	addiw	a5,a5,1
    80003492:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003494:	00025517          	auipc	a0,0x25
    80003498:	86450513          	addi	a0,a0,-1948 # 80027cf8 <itable>
    8000349c:	ff6fd0ef          	jal	80000c92 <release>
      return ip;
    800034a0:	8926                	mv	s2,s1
    800034a2:	a02d                	j	800034cc <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034a4:	fbe9                	bnez	a5,80003476 <iget+0x38>
      empty = ip;
    800034a6:	8926                	mv	s2,s1
    800034a8:	b7f9                	j	80003476 <iget+0x38>
  if(empty == 0)
    800034aa:	02090a63          	beqz	s2,800034de <iget+0xa0>
  ip->dev = dev;
    800034ae:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034b2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034b6:	4785                	li	a5,1
    800034b8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034bc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034c0:	00025517          	auipc	a0,0x25
    800034c4:	83850513          	addi	a0,a0,-1992 # 80027cf8 <itable>
    800034c8:	fcafd0ef          	jal	80000c92 <release>
}
    800034cc:	854a                	mv	a0,s2
    800034ce:	70a2                	ld	ra,40(sp)
    800034d0:	7402                	ld	s0,32(sp)
    800034d2:	64e2                	ld	s1,24(sp)
    800034d4:	6942                	ld	s2,16(sp)
    800034d6:	69a2                	ld	s3,8(sp)
    800034d8:	6a02                	ld	s4,0(sp)
    800034da:	6145                	addi	sp,sp,48
    800034dc:	8082                	ret
    panic("iget: no inodes");
    800034de:	00004517          	auipc	a0,0x4
    800034e2:	09a50513          	addi	a0,a0,154 # 80007578 <etext+0x578>
    800034e6:	ab8fd0ef          	jal	8000079e <panic>

00000000800034ea <fsinit>:
fsinit(int dev) {
    800034ea:	7179                	addi	sp,sp,-48
    800034ec:	f406                	sd	ra,40(sp)
    800034ee:	f022                	sd	s0,32(sp)
    800034f0:	ec26                	sd	s1,24(sp)
    800034f2:	e84a                	sd	s2,16(sp)
    800034f4:	e44e                	sd	s3,8(sp)
    800034f6:	1800                	addi	s0,sp,48
    800034f8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034fa:	4585                	li	a1,1
    800034fc:	b11ff0ef          	jal	8000300c <bread>
    80003500:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003502:	00024997          	auipc	s3,0x24
    80003506:	7d698993          	addi	s3,s3,2006 # 80027cd8 <sb>
    8000350a:	02000613          	li	a2,32
    8000350e:	05850593          	addi	a1,a0,88
    80003512:	854e                	mv	a0,s3
    80003514:	81ffd0ef          	jal	80000d32 <memmove>
  brelse(bp);
    80003518:	8526                	mv	a0,s1
    8000351a:	bfbff0ef          	jal	80003114 <brelse>
  if(sb.magic != FSMAGIC)
    8000351e:	0009a703          	lw	a4,0(s3)
    80003522:	102037b7          	lui	a5,0x10203
    80003526:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000352a:	02f71063          	bne	a4,a5,8000354a <fsinit+0x60>
  initlog(dev, &sb);
    8000352e:	00024597          	auipc	a1,0x24
    80003532:	7aa58593          	addi	a1,a1,1962 # 80027cd8 <sb>
    80003536:	854a                	mv	a0,s2
    80003538:	215000ef          	jal	80003f4c <initlog>
}
    8000353c:	70a2                	ld	ra,40(sp)
    8000353e:	7402                	ld	s0,32(sp)
    80003540:	64e2                	ld	s1,24(sp)
    80003542:	6942                	ld	s2,16(sp)
    80003544:	69a2                	ld	s3,8(sp)
    80003546:	6145                	addi	sp,sp,48
    80003548:	8082                	ret
    panic("invalid file system");
    8000354a:	00004517          	auipc	a0,0x4
    8000354e:	03e50513          	addi	a0,a0,62 # 80007588 <etext+0x588>
    80003552:	a4cfd0ef          	jal	8000079e <panic>

0000000080003556 <iinit>:
{
    80003556:	7179                	addi	sp,sp,-48
    80003558:	f406                	sd	ra,40(sp)
    8000355a:	f022                	sd	s0,32(sp)
    8000355c:	ec26                	sd	s1,24(sp)
    8000355e:	e84a                	sd	s2,16(sp)
    80003560:	e44e                	sd	s3,8(sp)
    80003562:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003564:	00004597          	auipc	a1,0x4
    80003568:	03c58593          	addi	a1,a1,60 # 800075a0 <etext+0x5a0>
    8000356c:	00024517          	auipc	a0,0x24
    80003570:	78c50513          	addi	a0,a0,1932 # 80027cf8 <itable>
    80003574:	e06fd0ef          	jal	80000b7a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003578:	00024497          	auipc	s1,0x24
    8000357c:	7a848493          	addi	s1,s1,1960 # 80027d20 <itable+0x28>
    80003580:	00026997          	auipc	s3,0x26
    80003584:	23098993          	addi	s3,s3,560 # 800297b0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003588:	00004917          	auipc	s2,0x4
    8000358c:	02090913          	addi	s2,s2,32 # 800075a8 <etext+0x5a8>
    80003590:	85ca                	mv	a1,s2
    80003592:	8526                	mv	a0,s1
    80003594:	497000ef          	jal	8000422a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003598:	08848493          	addi	s1,s1,136
    8000359c:	ff349ae3          	bne	s1,s3,80003590 <iinit+0x3a>
}
    800035a0:	70a2                	ld	ra,40(sp)
    800035a2:	7402                	ld	s0,32(sp)
    800035a4:	64e2                	ld	s1,24(sp)
    800035a6:	6942                	ld	s2,16(sp)
    800035a8:	69a2                	ld	s3,8(sp)
    800035aa:	6145                	addi	sp,sp,48
    800035ac:	8082                	ret

00000000800035ae <ialloc>:
{
    800035ae:	7139                	addi	sp,sp,-64
    800035b0:	fc06                	sd	ra,56(sp)
    800035b2:	f822                	sd	s0,48(sp)
    800035b4:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035b6:	00024717          	auipc	a4,0x24
    800035ba:	72e72703          	lw	a4,1838(a4) # 80027ce4 <sb+0xc>
    800035be:	4785                	li	a5,1
    800035c0:	06e7f063          	bgeu	a5,a4,80003620 <ialloc+0x72>
    800035c4:	f426                	sd	s1,40(sp)
    800035c6:	f04a                	sd	s2,32(sp)
    800035c8:	ec4e                	sd	s3,24(sp)
    800035ca:	e852                	sd	s4,16(sp)
    800035cc:	e456                	sd	s5,8(sp)
    800035ce:	e05a                	sd	s6,0(sp)
    800035d0:	8aaa                	mv	s5,a0
    800035d2:	8b2e                	mv	s6,a1
    800035d4:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800035d6:	00024a17          	auipc	s4,0x24
    800035da:	702a0a13          	addi	s4,s4,1794 # 80027cd8 <sb>
    800035de:	00495593          	srli	a1,s2,0x4
    800035e2:	018a2783          	lw	a5,24(s4)
    800035e6:	9dbd                	addw	a1,a1,a5
    800035e8:	8556                	mv	a0,s5
    800035ea:	a23ff0ef          	jal	8000300c <bread>
    800035ee:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035f0:	05850993          	addi	s3,a0,88
    800035f4:	00f97793          	andi	a5,s2,15
    800035f8:	079a                	slli	a5,a5,0x6
    800035fa:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035fc:	00099783          	lh	a5,0(s3)
    80003600:	cb9d                	beqz	a5,80003636 <ialloc+0x88>
    brelse(bp);
    80003602:	b13ff0ef          	jal	80003114 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003606:	0905                	addi	s2,s2,1
    80003608:	00ca2703          	lw	a4,12(s4)
    8000360c:	0009079b          	sext.w	a5,s2
    80003610:	fce7e7e3          	bltu	a5,a4,800035de <ialloc+0x30>
    80003614:	74a2                	ld	s1,40(sp)
    80003616:	7902                	ld	s2,32(sp)
    80003618:	69e2                	ld	s3,24(sp)
    8000361a:	6a42                	ld	s4,16(sp)
    8000361c:	6aa2                	ld	s5,8(sp)
    8000361e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003620:	00004517          	auipc	a0,0x4
    80003624:	f9050513          	addi	a0,a0,-112 # 800075b0 <etext+0x5b0>
    80003628:	ea7fc0ef          	jal	800004ce <printf>
  return 0;
    8000362c:	4501                	li	a0,0
}
    8000362e:	70e2                	ld	ra,56(sp)
    80003630:	7442                	ld	s0,48(sp)
    80003632:	6121                	addi	sp,sp,64
    80003634:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003636:	04000613          	li	a2,64
    8000363a:	4581                	li	a1,0
    8000363c:	854e                	mv	a0,s3
    8000363e:	e90fd0ef          	jal	80000cce <memset>
      dip->type = type;
    80003642:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003646:	8526                	mv	a0,s1
    80003648:	313000ef          	jal	8000415a <log_write>
      brelse(bp);
    8000364c:	8526                	mv	a0,s1
    8000364e:	ac7ff0ef          	jal	80003114 <brelse>
      return iget(dev, inum);
    80003652:	0009059b          	sext.w	a1,s2
    80003656:	8556                	mv	a0,s5
    80003658:	de7ff0ef          	jal	8000343e <iget>
    8000365c:	74a2                	ld	s1,40(sp)
    8000365e:	7902                	ld	s2,32(sp)
    80003660:	69e2                	ld	s3,24(sp)
    80003662:	6a42                	ld	s4,16(sp)
    80003664:	6aa2                	ld	s5,8(sp)
    80003666:	6b02                	ld	s6,0(sp)
    80003668:	b7d9                	j	8000362e <ialloc+0x80>

000000008000366a <iupdate>:
{
    8000366a:	1101                	addi	sp,sp,-32
    8000366c:	ec06                	sd	ra,24(sp)
    8000366e:	e822                	sd	s0,16(sp)
    80003670:	e426                	sd	s1,8(sp)
    80003672:	e04a                	sd	s2,0(sp)
    80003674:	1000                	addi	s0,sp,32
    80003676:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003678:	415c                	lw	a5,4(a0)
    8000367a:	0047d79b          	srliw	a5,a5,0x4
    8000367e:	00024597          	auipc	a1,0x24
    80003682:	6725a583          	lw	a1,1650(a1) # 80027cf0 <sb+0x18>
    80003686:	9dbd                	addw	a1,a1,a5
    80003688:	4108                	lw	a0,0(a0)
    8000368a:	983ff0ef          	jal	8000300c <bread>
    8000368e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003690:	05850793          	addi	a5,a0,88
    80003694:	40d8                	lw	a4,4(s1)
    80003696:	8b3d                	andi	a4,a4,15
    80003698:	071a                	slli	a4,a4,0x6
    8000369a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000369c:	04449703          	lh	a4,68(s1)
    800036a0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036a4:	04649703          	lh	a4,70(s1)
    800036a8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036ac:	04849703          	lh	a4,72(s1)
    800036b0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036b4:	04a49703          	lh	a4,74(s1)
    800036b8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800036bc:	44f8                	lw	a4,76(s1)
    800036be:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036c0:	03400613          	li	a2,52
    800036c4:	05048593          	addi	a1,s1,80
    800036c8:	00c78513          	addi	a0,a5,12
    800036cc:	e66fd0ef          	jal	80000d32 <memmove>
  log_write(bp);
    800036d0:	854a                	mv	a0,s2
    800036d2:	289000ef          	jal	8000415a <log_write>
  brelse(bp);
    800036d6:	854a                	mv	a0,s2
    800036d8:	a3dff0ef          	jal	80003114 <brelse>
}
    800036dc:	60e2                	ld	ra,24(sp)
    800036de:	6442                	ld	s0,16(sp)
    800036e0:	64a2                	ld	s1,8(sp)
    800036e2:	6902                	ld	s2,0(sp)
    800036e4:	6105                	addi	sp,sp,32
    800036e6:	8082                	ret

00000000800036e8 <idup>:
{
    800036e8:	1101                	addi	sp,sp,-32
    800036ea:	ec06                	sd	ra,24(sp)
    800036ec:	e822                	sd	s0,16(sp)
    800036ee:	e426                	sd	s1,8(sp)
    800036f0:	1000                	addi	s0,sp,32
    800036f2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036f4:	00024517          	auipc	a0,0x24
    800036f8:	60450513          	addi	a0,a0,1540 # 80027cf8 <itable>
    800036fc:	d02fd0ef          	jal	80000bfe <acquire>
  ip->ref++;
    80003700:	449c                	lw	a5,8(s1)
    80003702:	2785                	addiw	a5,a5,1
    80003704:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003706:	00024517          	auipc	a0,0x24
    8000370a:	5f250513          	addi	a0,a0,1522 # 80027cf8 <itable>
    8000370e:	d84fd0ef          	jal	80000c92 <release>
}
    80003712:	8526                	mv	a0,s1
    80003714:	60e2                	ld	ra,24(sp)
    80003716:	6442                	ld	s0,16(sp)
    80003718:	64a2                	ld	s1,8(sp)
    8000371a:	6105                	addi	sp,sp,32
    8000371c:	8082                	ret

000000008000371e <ilock>:
{
    8000371e:	1101                	addi	sp,sp,-32
    80003720:	ec06                	sd	ra,24(sp)
    80003722:	e822                	sd	s0,16(sp)
    80003724:	e426                	sd	s1,8(sp)
    80003726:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003728:	cd19                	beqz	a0,80003746 <ilock+0x28>
    8000372a:	84aa                	mv	s1,a0
    8000372c:	451c                	lw	a5,8(a0)
    8000372e:	00f05c63          	blez	a5,80003746 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003732:	0541                	addi	a0,a0,16
    80003734:	32d000ef          	jal	80004260 <acquiresleep>
  if(ip->valid == 0){
    80003738:	40bc                	lw	a5,64(s1)
    8000373a:	cf89                	beqz	a5,80003754 <ilock+0x36>
}
    8000373c:	60e2                	ld	ra,24(sp)
    8000373e:	6442                	ld	s0,16(sp)
    80003740:	64a2                	ld	s1,8(sp)
    80003742:	6105                	addi	sp,sp,32
    80003744:	8082                	ret
    80003746:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003748:	00004517          	auipc	a0,0x4
    8000374c:	e8050513          	addi	a0,a0,-384 # 800075c8 <etext+0x5c8>
    80003750:	84efd0ef          	jal	8000079e <panic>
    80003754:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003756:	40dc                	lw	a5,4(s1)
    80003758:	0047d79b          	srliw	a5,a5,0x4
    8000375c:	00024597          	auipc	a1,0x24
    80003760:	5945a583          	lw	a1,1428(a1) # 80027cf0 <sb+0x18>
    80003764:	9dbd                	addw	a1,a1,a5
    80003766:	4088                	lw	a0,0(s1)
    80003768:	8a5ff0ef          	jal	8000300c <bread>
    8000376c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000376e:	05850593          	addi	a1,a0,88
    80003772:	40dc                	lw	a5,4(s1)
    80003774:	8bbd                	andi	a5,a5,15
    80003776:	079a                	slli	a5,a5,0x6
    80003778:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000377a:	00059783          	lh	a5,0(a1)
    8000377e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003782:	00259783          	lh	a5,2(a1)
    80003786:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000378a:	00459783          	lh	a5,4(a1)
    8000378e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003792:	00659783          	lh	a5,6(a1)
    80003796:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000379a:	459c                	lw	a5,8(a1)
    8000379c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000379e:	03400613          	li	a2,52
    800037a2:	05b1                	addi	a1,a1,12
    800037a4:	05048513          	addi	a0,s1,80
    800037a8:	d8afd0ef          	jal	80000d32 <memmove>
    brelse(bp);
    800037ac:	854a                	mv	a0,s2
    800037ae:	967ff0ef          	jal	80003114 <brelse>
    ip->valid = 1;
    800037b2:	4785                	li	a5,1
    800037b4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037b6:	04449783          	lh	a5,68(s1)
    800037ba:	c399                	beqz	a5,800037c0 <ilock+0xa2>
    800037bc:	6902                	ld	s2,0(sp)
    800037be:	bfbd                	j	8000373c <ilock+0x1e>
      panic("ilock: no type");
    800037c0:	00004517          	auipc	a0,0x4
    800037c4:	e1050513          	addi	a0,a0,-496 # 800075d0 <etext+0x5d0>
    800037c8:	fd7fc0ef          	jal	8000079e <panic>

00000000800037cc <iunlock>:
{
    800037cc:	1101                	addi	sp,sp,-32
    800037ce:	ec06                	sd	ra,24(sp)
    800037d0:	e822                	sd	s0,16(sp)
    800037d2:	e426                	sd	s1,8(sp)
    800037d4:	e04a                	sd	s2,0(sp)
    800037d6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037d8:	c505                	beqz	a0,80003800 <iunlock+0x34>
    800037da:	84aa                	mv	s1,a0
    800037dc:	01050913          	addi	s2,a0,16
    800037e0:	854a                	mv	a0,s2
    800037e2:	2fd000ef          	jal	800042de <holdingsleep>
    800037e6:	cd09                	beqz	a0,80003800 <iunlock+0x34>
    800037e8:	449c                	lw	a5,8(s1)
    800037ea:	00f05b63          	blez	a5,80003800 <iunlock+0x34>
  releasesleep(&ip->lock);
    800037ee:	854a                	mv	a0,s2
    800037f0:	2b7000ef          	jal	800042a6 <releasesleep>
}
    800037f4:	60e2                	ld	ra,24(sp)
    800037f6:	6442                	ld	s0,16(sp)
    800037f8:	64a2                	ld	s1,8(sp)
    800037fa:	6902                	ld	s2,0(sp)
    800037fc:	6105                	addi	sp,sp,32
    800037fe:	8082                	ret
    panic("iunlock");
    80003800:	00004517          	auipc	a0,0x4
    80003804:	de050513          	addi	a0,a0,-544 # 800075e0 <etext+0x5e0>
    80003808:	f97fc0ef          	jal	8000079e <panic>

000000008000380c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000380c:	7179                	addi	sp,sp,-48
    8000380e:	f406                	sd	ra,40(sp)
    80003810:	f022                	sd	s0,32(sp)
    80003812:	ec26                	sd	s1,24(sp)
    80003814:	e84a                	sd	s2,16(sp)
    80003816:	e44e                	sd	s3,8(sp)
    80003818:	1800                	addi	s0,sp,48
    8000381a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000381c:	05050493          	addi	s1,a0,80
    80003820:	08050913          	addi	s2,a0,128
    80003824:	a021                	j	8000382c <itrunc+0x20>
    80003826:	0491                	addi	s1,s1,4
    80003828:	01248b63          	beq	s1,s2,8000383e <itrunc+0x32>
    if(ip->addrs[i]){
    8000382c:	408c                	lw	a1,0(s1)
    8000382e:	dde5                	beqz	a1,80003826 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003830:	0009a503          	lw	a0,0(s3)
    80003834:	9cdff0ef          	jal	80003200 <bfree>
      ip->addrs[i] = 0;
    80003838:	0004a023          	sw	zero,0(s1)
    8000383c:	b7ed                	j	80003826 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000383e:	0809a583          	lw	a1,128(s3)
    80003842:	ed89                	bnez	a1,8000385c <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003844:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003848:	854e                	mv	a0,s3
    8000384a:	e21ff0ef          	jal	8000366a <iupdate>
}
    8000384e:	70a2                	ld	ra,40(sp)
    80003850:	7402                	ld	s0,32(sp)
    80003852:	64e2                	ld	s1,24(sp)
    80003854:	6942                	ld	s2,16(sp)
    80003856:	69a2                	ld	s3,8(sp)
    80003858:	6145                	addi	sp,sp,48
    8000385a:	8082                	ret
    8000385c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000385e:	0009a503          	lw	a0,0(s3)
    80003862:	faaff0ef          	jal	8000300c <bread>
    80003866:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003868:	05850493          	addi	s1,a0,88
    8000386c:	45850913          	addi	s2,a0,1112
    80003870:	a021                	j	80003878 <itrunc+0x6c>
    80003872:	0491                	addi	s1,s1,4
    80003874:	01248963          	beq	s1,s2,80003886 <itrunc+0x7a>
      if(a[j])
    80003878:	408c                	lw	a1,0(s1)
    8000387a:	dde5                	beqz	a1,80003872 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000387c:	0009a503          	lw	a0,0(s3)
    80003880:	981ff0ef          	jal	80003200 <bfree>
    80003884:	b7fd                	j	80003872 <itrunc+0x66>
    brelse(bp);
    80003886:	8552                	mv	a0,s4
    80003888:	88dff0ef          	jal	80003114 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000388c:	0809a583          	lw	a1,128(s3)
    80003890:	0009a503          	lw	a0,0(s3)
    80003894:	96dff0ef          	jal	80003200 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003898:	0809a023          	sw	zero,128(s3)
    8000389c:	6a02                	ld	s4,0(sp)
    8000389e:	b75d                	j	80003844 <itrunc+0x38>

00000000800038a0 <iput>:
{
    800038a0:	1101                	addi	sp,sp,-32
    800038a2:	ec06                	sd	ra,24(sp)
    800038a4:	e822                	sd	s0,16(sp)
    800038a6:	e426                	sd	s1,8(sp)
    800038a8:	1000                	addi	s0,sp,32
    800038aa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038ac:	00024517          	auipc	a0,0x24
    800038b0:	44c50513          	addi	a0,a0,1100 # 80027cf8 <itable>
    800038b4:	b4afd0ef          	jal	80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038b8:	4498                	lw	a4,8(s1)
    800038ba:	4785                	li	a5,1
    800038bc:	02f70063          	beq	a4,a5,800038dc <iput+0x3c>
  ip->ref--;
    800038c0:	449c                	lw	a5,8(s1)
    800038c2:	37fd                	addiw	a5,a5,-1
    800038c4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038c6:	00024517          	auipc	a0,0x24
    800038ca:	43250513          	addi	a0,a0,1074 # 80027cf8 <itable>
    800038ce:	bc4fd0ef          	jal	80000c92 <release>
}
    800038d2:	60e2                	ld	ra,24(sp)
    800038d4:	6442                	ld	s0,16(sp)
    800038d6:	64a2                	ld	s1,8(sp)
    800038d8:	6105                	addi	sp,sp,32
    800038da:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038dc:	40bc                	lw	a5,64(s1)
    800038de:	d3ed                	beqz	a5,800038c0 <iput+0x20>
    800038e0:	04a49783          	lh	a5,74(s1)
    800038e4:	fff1                	bnez	a5,800038c0 <iput+0x20>
    800038e6:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800038e8:	01048913          	addi	s2,s1,16
    800038ec:	854a                	mv	a0,s2
    800038ee:	173000ef          	jal	80004260 <acquiresleep>
    release(&itable.lock);
    800038f2:	00024517          	auipc	a0,0x24
    800038f6:	40650513          	addi	a0,a0,1030 # 80027cf8 <itable>
    800038fa:	b98fd0ef          	jal	80000c92 <release>
    itrunc(ip);
    800038fe:	8526                	mv	a0,s1
    80003900:	f0dff0ef          	jal	8000380c <itrunc>
    ip->type = 0;
    80003904:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003908:	8526                	mv	a0,s1
    8000390a:	d61ff0ef          	jal	8000366a <iupdate>
    ip->valid = 0;
    8000390e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003912:	854a                	mv	a0,s2
    80003914:	193000ef          	jal	800042a6 <releasesleep>
    acquire(&itable.lock);
    80003918:	00024517          	auipc	a0,0x24
    8000391c:	3e050513          	addi	a0,a0,992 # 80027cf8 <itable>
    80003920:	adefd0ef          	jal	80000bfe <acquire>
    80003924:	6902                	ld	s2,0(sp)
    80003926:	bf69                	j	800038c0 <iput+0x20>

0000000080003928 <iunlockput>:
{
    80003928:	1101                	addi	sp,sp,-32
    8000392a:	ec06                	sd	ra,24(sp)
    8000392c:	e822                	sd	s0,16(sp)
    8000392e:	e426                	sd	s1,8(sp)
    80003930:	1000                	addi	s0,sp,32
    80003932:	84aa                	mv	s1,a0
  iunlock(ip);
    80003934:	e99ff0ef          	jal	800037cc <iunlock>
  iput(ip);
    80003938:	8526                	mv	a0,s1
    8000393a:	f67ff0ef          	jal	800038a0 <iput>
}
    8000393e:	60e2                	ld	ra,24(sp)
    80003940:	6442                	ld	s0,16(sp)
    80003942:	64a2                	ld	s1,8(sp)
    80003944:	6105                	addi	sp,sp,32
    80003946:	8082                	ret

0000000080003948 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003948:	1141                	addi	sp,sp,-16
    8000394a:	e406                	sd	ra,8(sp)
    8000394c:	e022                	sd	s0,0(sp)
    8000394e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003950:	411c                	lw	a5,0(a0)
    80003952:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003954:	415c                	lw	a5,4(a0)
    80003956:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003958:	04451783          	lh	a5,68(a0)
    8000395c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003960:	04a51783          	lh	a5,74(a0)
    80003964:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003968:	04c56783          	lwu	a5,76(a0)
    8000396c:	e99c                	sd	a5,16(a1)
}
    8000396e:	60a2                	ld	ra,8(sp)
    80003970:	6402                	ld	s0,0(sp)
    80003972:	0141                	addi	sp,sp,16
    80003974:	8082                	ret

0000000080003976 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003976:	457c                	lw	a5,76(a0)
    80003978:	0ed7e663          	bltu	a5,a3,80003a64 <readi+0xee>
{
    8000397c:	7159                	addi	sp,sp,-112
    8000397e:	f486                	sd	ra,104(sp)
    80003980:	f0a2                	sd	s0,96(sp)
    80003982:	eca6                	sd	s1,88(sp)
    80003984:	e0d2                	sd	s4,64(sp)
    80003986:	fc56                	sd	s5,56(sp)
    80003988:	f85a                	sd	s6,48(sp)
    8000398a:	f45e                	sd	s7,40(sp)
    8000398c:	1880                	addi	s0,sp,112
    8000398e:	8b2a                	mv	s6,a0
    80003990:	8bae                	mv	s7,a1
    80003992:	8a32                	mv	s4,a2
    80003994:	84b6                	mv	s1,a3
    80003996:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003998:	9f35                	addw	a4,a4,a3
    return 0;
    8000399a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000399c:	0ad76b63          	bltu	a4,a3,80003a52 <readi+0xdc>
    800039a0:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800039a2:	00e7f463          	bgeu	a5,a4,800039aa <readi+0x34>
    n = ip->size - off;
    800039a6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039aa:	080a8b63          	beqz	s5,80003a40 <readi+0xca>
    800039ae:	e8ca                	sd	s2,80(sp)
    800039b0:	f062                	sd	s8,32(sp)
    800039b2:	ec66                	sd	s9,24(sp)
    800039b4:	e86a                	sd	s10,16(sp)
    800039b6:	e46e                	sd	s11,8(sp)
    800039b8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ba:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039be:	5c7d                	li	s8,-1
    800039c0:	a80d                	j	800039f2 <readi+0x7c>
    800039c2:	020d1d93          	slli	s11,s10,0x20
    800039c6:	020ddd93          	srli	s11,s11,0x20
    800039ca:	05890613          	addi	a2,s2,88
    800039ce:	86ee                	mv	a3,s11
    800039d0:	963e                	add	a2,a2,a5
    800039d2:	85d2                	mv	a1,s4
    800039d4:	855e                	mv	a0,s7
    800039d6:	baffe0ef          	jal	80002584 <either_copyout>
    800039da:	05850363          	beq	a0,s8,80003a20 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039de:	854a                	mv	a0,s2
    800039e0:	f34ff0ef          	jal	80003114 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039e4:	013d09bb          	addw	s3,s10,s3
    800039e8:	009d04bb          	addw	s1,s10,s1
    800039ec:	9a6e                	add	s4,s4,s11
    800039ee:	0559f363          	bgeu	s3,s5,80003a34 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800039f2:	00a4d59b          	srliw	a1,s1,0xa
    800039f6:	855a                	mv	a0,s6
    800039f8:	987ff0ef          	jal	8000337e <bmap>
    800039fc:	85aa                	mv	a1,a0
    if(addr == 0)
    800039fe:	c139                	beqz	a0,80003a44 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a00:	000b2503          	lw	a0,0(s6)
    80003a04:	e08ff0ef          	jal	8000300c <bread>
    80003a08:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a0a:	3ff4f793          	andi	a5,s1,1023
    80003a0e:	40fc873b          	subw	a4,s9,a5
    80003a12:	413a86bb          	subw	a3,s5,s3
    80003a16:	8d3a                	mv	s10,a4
    80003a18:	fae6f5e3          	bgeu	a3,a4,800039c2 <readi+0x4c>
    80003a1c:	8d36                	mv	s10,a3
    80003a1e:	b755                	j	800039c2 <readi+0x4c>
      brelse(bp);
    80003a20:	854a                	mv	a0,s2
    80003a22:	ef2ff0ef          	jal	80003114 <brelse>
      tot = -1;
    80003a26:	59fd                	li	s3,-1
      break;
    80003a28:	6946                	ld	s2,80(sp)
    80003a2a:	7c02                	ld	s8,32(sp)
    80003a2c:	6ce2                	ld	s9,24(sp)
    80003a2e:	6d42                	ld	s10,16(sp)
    80003a30:	6da2                	ld	s11,8(sp)
    80003a32:	a831                	j	80003a4e <readi+0xd8>
    80003a34:	6946                	ld	s2,80(sp)
    80003a36:	7c02                	ld	s8,32(sp)
    80003a38:	6ce2                	ld	s9,24(sp)
    80003a3a:	6d42                	ld	s10,16(sp)
    80003a3c:	6da2                	ld	s11,8(sp)
    80003a3e:	a801                	j	80003a4e <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a40:	89d6                	mv	s3,s5
    80003a42:	a031                	j	80003a4e <readi+0xd8>
    80003a44:	6946                	ld	s2,80(sp)
    80003a46:	7c02                	ld	s8,32(sp)
    80003a48:	6ce2                	ld	s9,24(sp)
    80003a4a:	6d42                	ld	s10,16(sp)
    80003a4c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003a4e:	854e                	mv	a0,s3
    80003a50:	69a6                	ld	s3,72(sp)
}
    80003a52:	70a6                	ld	ra,104(sp)
    80003a54:	7406                	ld	s0,96(sp)
    80003a56:	64e6                	ld	s1,88(sp)
    80003a58:	6a06                	ld	s4,64(sp)
    80003a5a:	7ae2                	ld	s5,56(sp)
    80003a5c:	7b42                	ld	s6,48(sp)
    80003a5e:	7ba2                	ld	s7,40(sp)
    80003a60:	6165                	addi	sp,sp,112
    80003a62:	8082                	ret
    return 0;
    80003a64:	4501                	li	a0,0
}
    80003a66:	8082                	ret

0000000080003a68 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a68:	457c                	lw	a5,76(a0)
    80003a6a:	0ed7eb63          	bltu	a5,a3,80003b60 <writei+0xf8>
{
    80003a6e:	7159                	addi	sp,sp,-112
    80003a70:	f486                	sd	ra,104(sp)
    80003a72:	f0a2                	sd	s0,96(sp)
    80003a74:	e8ca                	sd	s2,80(sp)
    80003a76:	e0d2                	sd	s4,64(sp)
    80003a78:	fc56                	sd	s5,56(sp)
    80003a7a:	f85a                	sd	s6,48(sp)
    80003a7c:	f45e                	sd	s7,40(sp)
    80003a7e:	1880                	addi	s0,sp,112
    80003a80:	8aaa                	mv	s5,a0
    80003a82:	8bae                	mv	s7,a1
    80003a84:	8a32                	mv	s4,a2
    80003a86:	8936                	mv	s2,a3
    80003a88:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a8a:	00e687bb          	addw	a5,a3,a4
    80003a8e:	0cd7eb63          	bltu	a5,a3,80003b64 <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a92:	00043737          	lui	a4,0x43
    80003a96:	0cf76963          	bltu	a4,a5,80003b68 <writei+0x100>
    80003a9a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a9c:	0a0b0a63          	beqz	s6,80003b50 <writei+0xe8>
    80003aa0:	eca6                	sd	s1,88(sp)
    80003aa2:	f062                	sd	s8,32(sp)
    80003aa4:	ec66                	sd	s9,24(sp)
    80003aa6:	e86a                	sd	s10,16(sp)
    80003aa8:	e46e                	sd	s11,8(sp)
    80003aaa:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aac:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ab0:	5c7d                	li	s8,-1
    80003ab2:	a825                	j	80003aea <writei+0x82>
    80003ab4:	020d1d93          	slli	s11,s10,0x20
    80003ab8:	020ddd93          	srli	s11,s11,0x20
    80003abc:	05848513          	addi	a0,s1,88
    80003ac0:	86ee                	mv	a3,s11
    80003ac2:	8652                	mv	a2,s4
    80003ac4:	85de                	mv	a1,s7
    80003ac6:	953e                	add	a0,a0,a5
    80003ac8:	b07fe0ef          	jal	800025ce <either_copyin>
    80003acc:	05850663          	beq	a0,s8,80003b18 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ad0:	8526                	mv	a0,s1
    80003ad2:	688000ef          	jal	8000415a <log_write>
    brelse(bp);
    80003ad6:	8526                	mv	a0,s1
    80003ad8:	e3cff0ef          	jal	80003114 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003adc:	013d09bb          	addw	s3,s10,s3
    80003ae0:	012d093b          	addw	s2,s10,s2
    80003ae4:	9a6e                	add	s4,s4,s11
    80003ae6:	0369fc63          	bgeu	s3,s6,80003b1e <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003aea:	00a9559b          	srliw	a1,s2,0xa
    80003aee:	8556                	mv	a0,s5
    80003af0:	88fff0ef          	jal	8000337e <bmap>
    80003af4:	85aa                	mv	a1,a0
    if(addr == 0)
    80003af6:	c505                	beqz	a0,80003b1e <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003af8:	000aa503          	lw	a0,0(s5)
    80003afc:	d10ff0ef          	jal	8000300c <bread>
    80003b00:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b02:	3ff97793          	andi	a5,s2,1023
    80003b06:	40fc873b          	subw	a4,s9,a5
    80003b0a:	413b06bb          	subw	a3,s6,s3
    80003b0e:	8d3a                	mv	s10,a4
    80003b10:	fae6f2e3          	bgeu	a3,a4,80003ab4 <writei+0x4c>
    80003b14:	8d36                	mv	s10,a3
    80003b16:	bf79                	j	80003ab4 <writei+0x4c>
      brelse(bp);
    80003b18:	8526                	mv	a0,s1
    80003b1a:	dfaff0ef          	jal	80003114 <brelse>
  }

  if(off > ip->size)
    80003b1e:	04caa783          	lw	a5,76(s5)
    80003b22:	0327f963          	bgeu	a5,s2,80003b54 <writei+0xec>
    ip->size = off;
    80003b26:	052aa623          	sw	s2,76(s5)
    80003b2a:	64e6                	ld	s1,88(sp)
    80003b2c:	7c02                	ld	s8,32(sp)
    80003b2e:	6ce2                	ld	s9,24(sp)
    80003b30:	6d42                	ld	s10,16(sp)
    80003b32:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b34:	8556                	mv	a0,s5
    80003b36:	b35ff0ef          	jal	8000366a <iupdate>

  return tot;
    80003b3a:	854e                	mv	a0,s3
    80003b3c:	69a6                	ld	s3,72(sp)
}
    80003b3e:	70a6                	ld	ra,104(sp)
    80003b40:	7406                	ld	s0,96(sp)
    80003b42:	6946                	ld	s2,80(sp)
    80003b44:	6a06                	ld	s4,64(sp)
    80003b46:	7ae2                	ld	s5,56(sp)
    80003b48:	7b42                	ld	s6,48(sp)
    80003b4a:	7ba2                	ld	s7,40(sp)
    80003b4c:	6165                	addi	sp,sp,112
    80003b4e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b50:	89da                	mv	s3,s6
    80003b52:	b7cd                	j	80003b34 <writei+0xcc>
    80003b54:	64e6                	ld	s1,88(sp)
    80003b56:	7c02                	ld	s8,32(sp)
    80003b58:	6ce2                	ld	s9,24(sp)
    80003b5a:	6d42                	ld	s10,16(sp)
    80003b5c:	6da2                	ld	s11,8(sp)
    80003b5e:	bfd9                	j	80003b34 <writei+0xcc>
    return -1;
    80003b60:	557d                	li	a0,-1
}
    80003b62:	8082                	ret
    return -1;
    80003b64:	557d                	li	a0,-1
    80003b66:	bfe1                	j	80003b3e <writei+0xd6>
    return -1;
    80003b68:	557d                	li	a0,-1
    80003b6a:	bfd1                	j	80003b3e <writei+0xd6>

0000000080003b6c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b6c:	1141                	addi	sp,sp,-16
    80003b6e:	e406                	sd	ra,8(sp)
    80003b70:	e022                	sd	s0,0(sp)
    80003b72:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b74:	4639                	li	a2,14
    80003b76:	a30fd0ef          	jal	80000da6 <strncmp>
}
    80003b7a:	60a2                	ld	ra,8(sp)
    80003b7c:	6402                	ld	s0,0(sp)
    80003b7e:	0141                	addi	sp,sp,16
    80003b80:	8082                	ret

0000000080003b82 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b82:	711d                	addi	sp,sp,-96
    80003b84:	ec86                	sd	ra,88(sp)
    80003b86:	e8a2                	sd	s0,80(sp)
    80003b88:	e4a6                	sd	s1,72(sp)
    80003b8a:	e0ca                	sd	s2,64(sp)
    80003b8c:	fc4e                	sd	s3,56(sp)
    80003b8e:	f852                	sd	s4,48(sp)
    80003b90:	f456                	sd	s5,40(sp)
    80003b92:	f05a                	sd	s6,32(sp)
    80003b94:	ec5e                	sd	s7,24(sp)
    80003b96:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b98:	04451703          	lh	a4,68(a0)
    80003b9c:	4785                	li	a5,1
    80003b9e:	00f71f63          	bne	a4,a5,80003bbc <dirlookup+0x3a>
    80003ba2:	892a                	mv	s2,a0
    80003ba4:	8aae                	mv	s5,a1
    80003ba6:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ba8:	457c                	lw	a5,76(a0)
    80003baa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bac:	fa040a13          	addi	s4,s0,-96
    80003bb0:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003bb2:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bb6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bb8:	e39d                	bnez	a5,80003bde <dirlookup+0x5c>
    80003bba:	a8b9                	j	80003c18 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003bbc:	00004517          	auipc	a0,0x4
    80003bc0:	a2c50513          	addi	a0,a0,-1492 # 800075e8 <etext+0x5e8>
    80003bc4:	bdbfc0ef          	jal	8000079e <panic>
      panic("dirlookup read");
    80003bc8:	00004517          	auipc	a0,0x4
    80003bcc:	a3850513          	addi	a0,a0,-1480 # 80007600 <etext+0x600>
    80003bd0:	bcffc0ef          	jal	8000079e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bd4:	24c1                	addiw	s1,s1,16
    80003bd6:	04c92783          	lw	a5,76(s2)
    80003bda:	02f4fe63          	bgeu	s1,a5,80003c16 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bde:	874e                	mv	a4,s3
    80003be0:	86a6                	mv	a3,s1
    80003be2:	8652                	mv	a2,s4
    80003be4:	4581                	li	a1,0
    80003be6:	854a                	mv	a0,s2
    80003be8:	d8fff0ef          	jal	80003976 <readi>
    80003bec:	fd351ee3          	bne	a0,s3,80003bc8 <dirlookup+0x46>
    if(de.inum == 0)
    80003bf0:	fa045783          	lhu	a5,-96(s0)
    80003bf4:	d3e5                	beqz	a5,80003bd4 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003bf6:	85da                	mv	a1,s6
    80003bf8:	8556                	mv	a0,s5
    80003bfa:	f73ff0ef          	jal	80003b6c <namecmp>
    80003bfe:	f979                	bnez	a0,80003bd4 <dirlookup+0x52>
      if(poff)
    80003c00:	000b8463          	beqz	s7,80003c08 <dirlookup+0x86>
        *poff = off;
    80003c04:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003c08:	fa045583          	lhu	a1,-96(s0)
    80003c0c:	00092503          	lw	a0,0(s2)
    80003c10:	82fff0ef          	jal	8000343e <iget>
    80003c14:	a011                	j	80003c18 <dirlookup+0x96>
  return 0;
    80003c16:	4501                	li	a0,0
}
    80003c18:	60e6                	ld	ra,88(sp)
    80003c1a:	6446                	ld	s0,80(sp)
    80003c1c:	64a6                	ld	s1,72(sp)
    80003c1e:	6906                	ld	s2,64(sp)
    80003c20:	79e2                	ld	s3,56(sp)
    80003c22:	7a42                	ld	s4,48(sp)
    80003c24:	7aa2                	ld	s5,40(sp)
    80003c26:	7b02                	ld	s6,32(sp)
    80003c28:	6be2                	ld	s7,24(sp)
    80003c2a:	6125                	addi	sp,sp,96
    80003c2c:	8082                	ret

0000000080003c2e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c2e:	711d                	addi	sp,sp,-96
    80003c30:	ec86                	sd	ra,88(sp)
    80003c32:	e8a2                	sd	s0,80(sp)
    80003c34:	e4a6                	sd	s1,72(sp)
    80003c36:	e0ca                	sd	s2,64(sp)
    80003c38:	fc4e                	sd	s3,56(sp)
    80003c3a:	f852                	sd	s4,48(sp)
    80003c3c:	f456                	sd	s5,40(sp)
    80003c3e:	f05a                	sd	s6,32(sp)
    80003c40:	ec5e                	sd	s7,24(sp)
    80003c42:	e862                	sd	s8,16(sp)
    80003c44:	e466                	sd	s9,8(sp)
    80003c46:	e06a                	sd	s10,0(sp)
    80003c48:	1080                	addi	s0,sp,96
    80003c4a:	84aa                	mv	s1,a0
    80003c4c:	8b2e                	mv	s6,a1
    80003c4e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c50:	00054703          	lbu	a4,0(a0)
    80003c54:	02f00793          	li	a5,47
    80003c58:	00f70f63          	beq	a4,a5,80003c76 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c5c:	c81fd0ef          	jal	800018dc <myproc>
    80003c60:	15053503          	ld	a0,336(a0)
    80003c64:	a85ff0ef          	jal	800036e8 <idup>
    80003c68:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c6a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c6e:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003c70:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c72:	4b85                	li	s7,1
    80003c74:	a879                	j	80003d12 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003c76:	4585                	li	a1,1
    80003c78:	852e                	mv	a0,a1
    80003c7a:	fc4ff0ef          	jal	8000343e <iget>
    80003c7e:	8a2a                	mv	s4,a0
    80003c80:	b7ed                	j	80003c6a <namex+0x3c>
      iunlockput(ip);
    80003c82:	8552                	mv	a0,s4
    80003c84:	ca5ff0ef          	jal	80003928 <iunlockput>
      return 0;
    80003c88:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c8a:	8552                	mv	a0,s4
    80003c8c:	60e6                	ld	ra,88(sp)
    80003c8e:	6446                	ld	s0,80(sp)
    80003c90:	64a6                	ld	s1,72(sp)
    80003c92:	6906                	ld	s2,64(sp)
    80003c94:	79e2                	ld	s3,56(sp)
    80003c96:	7a42                	ld	s4,48(sp)
    80003c98:	7aa2                	ld	s5,40(sp)
    80003c9a:	7b02                	ld	s6,32(sp)
    80003c9c:	6be2                	ld	s7,24(sp)
    80003c9e:	6c42                	ld	s8,16(sp)
    80003ca0:	6ca2                	ld	s9,8(sp)
    80003ca2:	6d02                	ld	s10,0(sp)
    80003ca4:	6125                	addi	sp,sp,96
    80003ca6:	8082                	ret
      iunlock(ip);
    80003ca8:	8552                	mv	a0,s4
    80003caa:	b23ff0ef          	jal	800037cc <iunlock>
      return ip;
    80003cae:	bff1                	j	80003c8a <namex+0x5c>
      iunlockput(ip);
    80003cb0:	8552                	mv	a0,s4
    80003cb2:	c77ff0ef          	jal	80003928 <iunlockput>
      return 0;
    80003cb6:	8a4e                	mv	s4,s3
    80003cb8:	bfc9                	j	80003c8a <namex+0x5c>
  len = path - s;
    80003cba:	40998633          	sub	a2,s3,s1
    80003cbe:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003cc2:	09ac5063          	bge	s8,s10,80003d42 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003cc6:	8666                	mv	a2,s9
    80003cc8:	85a6                	mv	a1,s1
    80003cca:	8556                	mv	a0,s5
    80003ccc:	866fd0ef          	jal	80000d32 <memmove>
    80003cd0:	84ce                	mv	s1,s3
  while(*path == '/')
    80003cd2:	0004c783          	lbu	a5,0(s1)
    80003cd6:	01279763          	bne	a5,s2,80003ce4 <namex+0xb6>
    path++;
    80003cda:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cdc:	0004c783          	lbu	a5,0(s1)
    80003ce0:	ff278de3          	beq	a5,s2,80003cda <namex+0xac>
    ilock(ip);
    80003ce4:	8552                	mv	a0,s4
    80003ce6:	a39ff0ef          	jal	8000371e <ilock>
    if(ip->type != T_DIR){
    80003cea:	044a1783          	lh	a5,68(s4)
    80003cee:	f9779ae3          	bne	a5,s7,80003c82 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003cf2:	000b0563          	beqz	s6,80003cfc <namex+0xce>
    80003cf6:	0004c783          	lbu	a5,0(s1)
    80003cfa:	d7dd                	beqz	a5,80003ca8 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003cfc:	4601                	li	a2,0
    80003cfe:	85d6                	mv	a1,s5
    80003d00:	8552                	mv	a0,s4
    80003d02:	e81ff0ef          	jal	80003b82 <dirlookup>
    80003d06:	89aa                	mv	s3,a0
    80003d08:	d545                	beqz	a0,80003cb0 <namex+0x82>
    iunlockput(ip);
    80003d0a:	8552                	mv	a0,s4
    80003d0c:	c1dff0ef          	jal	80003928 <iunlockput>
    ip = next;
    80003d10:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d12:	0004c783          	lbu	a5,0(s1)
    80003d16:	01279763          	bne	a5,s2,80003d24 <namex+0xf6>
    path++;
    80003d1a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d1c:	0004c783          	lbu	a5,0(s1)
    80003d20:	ff278de3          	beq	a5,s2,80003d1a <namex+0xec>
  if(*path == 0)
    80003d24:	cb8d                	beqz	a5,80003d56 <namex+0x128>
  while(*path != '/' && *path != 0)
    80003d26:	0004c783          	lbu	a5,0(s1)
    80003d2a:	89a6                	mv	s3,s1
  len = path - s;
    80003d2c:	4d01                	li	s10,0
    80003d2e:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003d30:	01278963          	beq	a5,s2,80003d42 <namex+0x114>
    80003d34:	d3d9                	beqz	a5,80003cba <namex+0x8c>
    path++;
    80003d36:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d38:	0009c783          	lbu	a5,0(s3)
    80003d3c:	ff279ce3          	bne	a5,s2,80003d34 <namex+0x106>
    80003d40:	bfad                	j	80003cba <namex+0x8c>
    memmove(name, s, len);
    80003d42:	2601                	sext.w	a2,a2
    80003d44:	85a6                	mv	a1,s1
    80003d46:	8556                	mv	a0,s5
    80003d48:	febfc0ef          	jal	80000d32 <memmove>
    name[len] = 0;
    80003d4c:	9d56                	add	s10,s10,s5
    80003d4e:	000d0023          	sb	zero,0(s10)
    80003d52:	84ce                	mv	s1,s3
    80003d54:	bfbd                	j	80003cd2 <namex+0xa4>
  if(nameiparent){
    80003d56:	f20b0ae3          	beqz	s6,80003c8a <namex+0x5c>
    iput(ip);
    80003d5a:	8552                	mv	a0,s4
    80003d5c:	b45ff0ef          	jal	800038a0 <iput>
    return 0;
    80003d60:	4a01                	li	s4,0
    80003d62:	b725                	j	80003c8a <namex+0x5c>

0000000080003d64 <dirlink>:
{
    80003d64:	715d                	addi	sp,sp,-80
    80003d66:	e486                	sd	ra,72(sp)
    80003d68:	e0a2                	sd	s0,64(sp)
    80003d6a:	f84a                	sd	s2,48(sp)
    80003d6c:	ec56                	sd	s5,24(sp)
    80003d6e:	e85a                	sd	s6,16(sp)
    80003d70:	0880                	addi	s0,sp,80
    80003d72:	892a                	mv	s2,a0
    80003d74:	8aae                	mv	s5,a1
    80003d76:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d78:	4601                	li	a2,0
    80003d7a:	e09ff0ef          	jal	80003b82 <dirlookup>
    80003d7e:	ed1d                	bnez	a0,80003dbc <dirlink+0x58>
    80003d80:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d82:	04c92483          	lw	s1,76(s2)
    80003d86:	c4b9                	beqz	s1,80003dd4 <dirlink+0x70>
    80003d88:	f44e                	sd	s3,40(sp)
    80003d8a:	f052                	sd	s4,32(sp)
    80003d8c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d8e:	fb040a13          	addi	s4,s0,-80
    80003d92:	49c1                	li	s3,16
    80003d94:	874e                	mv	a4,s3
    80003d96:	86a6                	mv	a3,s1
    80003d98:	8652                	mv	a2,s4
    80003d9a:	4581                	li	a1,0
    80003d9c:	854a                	mv	a0,s2
    80003d9e:	bd9ff0ef          	jal	80003976 <readi>
    80003da2:	03351163          	bne	a0,s3,80003dc4 <dirlink+0x60>
    if(de.inum == 0)
    80003da6:	fb045783          	lhu	a5,-80(s0)
    80003daa:	c39d                	beqz	a5,80003dd0 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dac:	24c1                	addiw	s1,s1,16
    80003dae:	04c92783          	lw	a5,76(s2)
    80003db2:	fef4e1e3          	bltu	s1,a5,80003d94 <dirlink+0x30>
    80003db6:	79a2                	ld	s3,40(sp)
    80003db8:	7a02                	ld	s4,32(sp)
    80003dba:	a829                	j	80003dd4 <dirlink+0x70>
    iput(ip);
    80003dbc:	ae5ff0ef          	jal	800038a0 <iput>
    return -1;
    80003dc0:	557d                	li	a0,-1
    80003dc2:	a83d                	j	80003e00 <dirlink+0x9c>
      panic("dirlink read");
    80003dc4:	00004517          	auipc	a0,0x4
    80003dc8:	84c50513          	addi	a0,a0,-1972 # 80007610 <etext+0x610>
    80003dcc:	9d3fc0ef          	jal	8000079e <panic>
    80003dd0:	79a2                	ld	s3,40(sp)
    80003dd2:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003dd4:	4639                	li	a2,14
    80003dd6:	85d6                	mv	a1,s5
    80003dd8:	fb240513          	addi	a0,s0,-78
    80003ddc:	804fd0ef          	jal	80000de0 <strncpy>
  de.inum = inum;
    80003de0:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003de4:	4741                	li	a4,16
    80003de6:	86a6                	mv	a3,s1
    80003de8:	fb040613          	addi	a2,s0,-80
    80003dec:	4581                	li	a1,0
    80003dee:	854a                	mv	a0,s2
    80003df0:	c79ff0ef          	jal	80003a68 <writei>
    80003df4:	1541                	addi	a0,a0,-16
    80003df6:	00a03533          	snez	a0,a0
    80003dfa:	40a0053b          	negw	a0,a0
    80003dfe:	74e2                	ld	s1,56(sp)
}
    80003e00:	60a6                	ld	ra,72(sp)
    80003e02:	6406                	ld	s0,64(sp)
    80003e04:	7942                	ld	s2,48(sp)
    80003e06:	6ae2                	ld	s5,24(sp)
    80003e08:	6b42                	ld	s6,16(sp)
    80003e0a:	6161                	addi	sp,sp,80
    80003e0c:	8082                	ret

0000000080003e0e <namei>:

struct inode*
namei(char *path)
{
    80003e0e:	1101                	addi	sp,sp,-32
    80003e10:	ec06                	sd	ra,24(sp)
    80003e12:	e822                	sd	s0,16(sp)
    80003e14:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e16:	fe040613          	addi	a2,s0,-32
    80003e1a:	4581                	li	a1,0
    80003e1c:	e13ff0ef          	jal	80003c2e <namex>
}
    80003e20:	60e2                	ld	ra,24(sp)
    80003e22:	6442                	ld	s0,16(sp)
    80003e24:	6105                	addi	sp,sp,32
    80003e26:	8082                	ret

0000000080003e28 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e28:	1141                	addi	sp,sp,-16
    80003e2a:	e406                	sd	ra,8(sp)
    80003e2c:	e022                	sd	s0,0(sp)
    80003e2e:	0800                	addi	s0,sp,16
    80003e30:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e32:	4585                	li	a1,1
    80003e34:	dfbff0ef          	jal	80003c2e <namex>
}
    80003e38:	60a2                	ld	ra,8(sp)
    80003e3a:	6402                	ld	s0,0(sp)
    80003e3c:	0141                	addi	sp,sp,16
    80003e3e:	8082                	ret

0000000080003e40 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e40:	1101                	addi	sp,sp,-32
    80003e42:	ec06                	sd	ra,24(sp)
    80003e44:	e822                	sd	s0,16(sp)
    80003e46:	e426                	sd	s1,8(sp)
    80003e48:	e04a                	sd	s2,0(sp)
    80003e4a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e4c:	00026917          	auipc	s2,0x26
    80003e50:	95490913          	addi	s2,s2,-1708 # 800297a0 <log>
    80003e54:	01892583          	lw	a1,24(s2)
    80003e58:	02892503          	lw	a0,40(s2)
    80003e5c:	9b0ff0ef          	jal	8000300c <bread>
    80003e60:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e62:	02c92603          	lw	a2,44(s2)
    80003e66:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e68:	00c05f63          	blez	a2,80003e86 <write_head+0x46>
    80003e6c:	00026717          	auipc	a4,0x26
    80003e70:	96470713          	addi	a4,a4,-1692 # 800297d0 <log+0x30>
    80003e74:	87aa                	mv	a5,a0
    80003e76:	060a                	slli	a2,a2,0x2
    80003e78:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003e7a:	4314                	lw	a3,0(a4)
    80003e7c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e7e:	0711                	addi	a4,a4,4
    80003e80:	0791                	addi	a5,a5,4
    80003e82:	fec79ce3          	bne	a5,a2,80003e7a <write_head+0x3a>
  }
  bwrite(buf);
    80003e86:	8526                	mv	a0,s1
    80003e88:	a5aff0ef          	jal	800030e2 <bwrite>
  brelse(buf);
    80003e8c:	8526                	mv	a0,s1
    80003e8e:	a86ff0ef          	jal	80003114 <brelse>
}
    80003e92:	60e2                	ld	ra,24(sp)
    80003e94:	6442                	ld	s0,16(sp)
    80003e96:	64a2                	ld	s1,8(sp)
    80003e98:	6902                	ld	s2,0(sp)
    80003e9a:	6105                	addi	sp,sp,32
    80003e9c:	8082                	ret

0000000080003e9e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e9e:	00026797          	auipc	a5,0x26
    80003ea2:	92e7a783          	lw	a5,-1746(a5) # 800297cc <log+0x2c>
    80003ea6:	0af05263          	blez	a5,80003f4a <install_trans+0xac>
{
    80003eaa:	715d                	addi	sp,sp,-80
    80003eac:	e486                	sd	ra,72(sp)
    80003eae:	e0a2                	sd	s0,64(sp)
    80003eb0:	fc26                	sd	s1,56(sp)
    80003eb2:	f84a                	sd	s2,48(sp)
    80003eb4:	f44e                	sd	s3,40(sp)
    80003eb6:	f052                	sd	s4,32(sp)
    80003eb8:	ec56                	sd	s5,24(sp)
    80003eba:	e85a                	sd	s6,16(sp)
    80003ebc:	e45e                	sd	s7,8(sp)
    80003ebe:	0880                	addi	s0,sp,80
    80003ec0:	8b2a                	mv	s6,a0
    80003ec2:	00026a97          	auipc	s5,0x26
    80003ec6:	90ea8a93          	addi	s5,s5,-1778 # 800297d0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eca:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ecc:	00026997          	auipc	s3,0x26
    80003ed0:	8d498993          	addi	s3,s3,-1836 # 800297a0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ed4:	40000b93          	li	s7,1024
    80003ed8:	a829                	j	80003ef2 <install_trans+0x54>
    brelse(lbuf);
    80003eda:	854a                	mv	a0,s2
    80003edc:	a38ff0ef          	jal	80003114 <brelse>
    brelse(dbuf);
    80003ee0:	8526                	mv	a0,s1
    80003ee2:	a32ff0ef          	jal	80003114 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ee6:	2a05                	addiw	s4,s4,1
    80003ee8:	0a91                	addi	s5,s5,4
    80003eea:	02c9a783          	lw	a5,44(s3)
    80003eee:	04fa5363          	bge	s4,a5,80003f34 <install_trans+0x96>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ef2:	0189a583          	lw	a1,24(s3)
    80003ef6:	014585bb          	addw	a1,a1,s4
    80003efa:	2585                	addiw	a1,a1,1
    80003efc:	0289a503          	lw	a0,40(s3)
    80003f00:	90cff0ef          	jal	8000300c <bread>
    80003f04:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f06:	000aa583          	lw	a1,0(s5)
    80003f0a:	0289a503          	lw	a0,40(s3)
    80003f0e:	8feff0ef          	jal	8000300c <bread>
    80003f12:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f14:	865e                	mv	a2,s7
    80003f16:	05890593          	addi	a1,s2,88
    80003f1a:	05850513          	addi	a0,a0,88
    80003f1e:	e15fc0ef          	jal	80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f22:	8526                	mv	a0,s1
    80003f24:	9beff0ef          	jal	800030e2 <bwrite>
    if(recovering == 0)
    80003f28:	fa0b19e3          	bnez	s6,80003eda <install_trans+0x3c>
      bunpin(dbuf);
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	a9eff0ef          	jal	800031cc <bunpin>
    80003f32:	b765                	j	80003eda <install_trans+0x3c>
}
    80003f34:	60a6                	ld	ra,72(sp)
    80003f36:	6406                	ld	s0,64(sp)
    80003f38:	74e2                	ld	s1,56(sp)
    80003f3a:	7942                	ld	s2,48(sp)
    80003f3c:	79a2                	ld	s3,40(sp)
    80003f3e:	7a02                	ld	s4,32(sp)
    80003f40:	6ae2                	ld	s5,24(sp)
    80003f42:	6b42                	ld	s6,16(sp)
    80003f44:	6ba2                	ld	s7,8(sp)
    80003f46:	6161                	addi	sp,sp,80
    80003f48:	8082                	ret
    80003f4a:	8082                	ret

0000000080003f4c <initlog>:
{
    80003f4c:	7179                	addi	sp,sp,-48
    80003f4e:	f406                	sd	ra,40(sp)
    80003f50:	f022                	sd	s0,32(sp)
    80003f52:	ec26                	sd	s1,24(sp)
    80003f54:	e84a                	sd	s2,16(sp)
    80003f56:	e44e                	sd	s3,8(sp)
    80003f58:	1800                	addi	s0,sp,48
    80003f5a:	892a                	mv	s2,a0
    80003f5c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f5e:	00026497          	auipc	s1,0x26
    80003f62:	84248493          	addi	s1,s1,-1982 # 800297a0 <log>
    80003f66:	00003597          	auipc	a1,0x3
    80003f6a:	6ba58593          	addi	a1,a1,1722 # 80007620 <etext+0x620>
    80003f6e:	8526                	mv	a0,s1
    80003f70:	c0bfc0ef          	jal	80000b7a <initlock>
  log.start = sb->logstart;
    80003f74:	0149a583          	lw	a1,20(s3)
    80003f78:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f7a:	0109a783          	lw	a5,16(s3)
    80003f7e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f80:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f84:	854a                	mv	a0,s2
    80003f86:	886ff0ef          	jal	8000300c <bread>
  log.lh.n = lh->n;
    80003f8a:	4d30                	lw	a2,88(a0)
    80003f8c:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f8e:	00c05f63          	blez	a2,80003fac <initlog+0x60>
    80003f92:	87aa                	mv	a5,a0
    80003f94:	00026717          	auipc	a4,0x26
    80003f98:	83c70713          	addi	a4,a4,-1988 # 800297d0 <log+0x30>
    80003f9c:	060a                	slli	a2,a2,0x2
    80003f9e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003fa0:	4ff4                	lw	a3,92(a5)
    80003fa2:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fa4:	0791                	addi	a5,a5,4
    80003fa6:	0711                	addi	a4,a4,4
    80003fa8:	fec79ce3          	bne	a5,a2,80003fa0 <initlog+0x54>
  brelse(buf);
    80003fac:	968ff0ef          	jal	80003114 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003fb0:	4505                	li	a0,1
    80003fb2:	eedff0ef          	jal	80003e9e <install_trans>
  log.lh.n = 0;
    80003fb6:	00026797          	auipc	a5,0x26
    80003fba:	8007ab23          	sw	zero,-2026(a5) # 800297cc <log+0x2c>
  write_head(); // clear the log
    80003fbe:	e83ff0ef          	jal	80003e40 <write_head>
}
    80003fc2:	70a2                	ld	ra,40(sp)
    80003fc4:	7402                	ld	s0,32(sp)
    80003fc6:	64e2                	ld	s1,24(sp)
    80003fc8:	6942                	ld	s2,16(sp)
    80003fca:	69a2                	ld	s3,8(sp)
    80003fcc:	6145                	addi	sp,sp,48
    80003fce:	8082                	ret

0000000080003fd0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003fd0:	1101                	addi	sp,sp,-32
    80003fd2:	ec06                	sd	ra,24(sp)
    80003fd4:	e822                	sd	s0,16(sp)
    80003fd6:	e426                	sd	s1,8(sp)
    80003fd8:	e04a                	sd	s2,0(sp)
    80003fda:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003fdc:	00025517          	auipc	a0,0x25
    80003fe0:	7c450513          	addi	a0,a0,1988 # 800297a0 <log>
    80003fe4:	c1bfc0ef          	jal	80000bfe <acquire>
  while(1){
    if(log.committing){
    80003fe8:	00025497          	auipc	s1,0x25
    80003fec:	7b848493          	addi	s1,s1,1976 # 800297a0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003ff0:	4979                	li	s2,30
    80003ff2:	a029                	j	80003ffc <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003ff4:	85a6                	mv	a1,s1
    80003ff6:	8526                	mv	a0,s1
    80003ff8:	a36fe0ef          	jal	8000222e <sleep>
    if(log.committing){
    80003ffc:	50dc                	lw	a5,36(s1)
    80003ffe:	fbfd                	bnez	a5,80003ff4 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004000:	5098                	lw	a4,32(s1)
    80004002:	2705                	addiw	a4,a4,1
    80004004:	0027179b          	slliw	a5,a4,0x2
    80004008:	9fb9                	addw	a5,a5,a4
    8000400a:	0017979b          	slliw	a5,a5,0x1
    8000400e:	54d4                	lw	a3,44(s1)
    80004010:	9fb5                	addw	a5,a5,a3
    80004012:	00f95763          	bge	s2,a5,80004020 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004016:	85a6                	mv	a1,s1
    80004018:	8526                	mv	a0,s1
    8000401a:	a14fe0ef          	jal	8000222e <sleep>
    8000401e:	bff9                	j	80003ffc <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004020:	00025517          	auipc	a0,0x25
    80004024:	78050513          	addi	a0,a0,1920 # 800297a0 <log>
    80004028:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000402a:	c69fc0ef          	jal	80000c92 <release>
      break;
    }
  }
}
    8000402e:	60e2                	ld	ra,24(sp)
    80004030:	6442                	ld	s0,16(sp)
    80004032:	64a2                	ld	s1,8(sp)
    80004034:	6902                	ld	s2,0(sp)
    80004036:	6105                	addi	sp,sp,32
    80004038:	8082                	ret

000000008000403a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000403a:	7139                	addi	sp,sp,-64
    8000403c:	fc06                	sd	ra,56(sp)
    8000403e:	f822                	sd	s0,48(sp)
    80004040:	f426                	sd	s1,40(sp)
    80004042:	f04a                	sd	s2,32(sp)
    80004044:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004046:	00025497          	auipc	s1,0x25
    8000404a:	75a48493          	addi	s1,s1,1882 # 800297a0 <log>
    8000404e:	8526                	mv	a0,s1
    80004050:	baffc0ef          	jal	80000bfe <acquire>
  log.outstanding -= 1;
    80004054:	509c                	lw	a5,32(s1)
    80004056:	37fd                	addiw	a5,a5,-1
    80004058:	893e                	mv	s2,a5
    8000405a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000405c:	50dc                	lw	a5,36(s1)
    8000405e:	ef9d                	bnez	a5,8000409c <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    80004060:	04091863          	bnez	s2,800040b0 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004064:	00025497          	auipc	s1,0x25
    80004068:	73c48493          	addi	s1,s1,1852 # 800297a0 <log>
    8000406c:	4785                	li	a5,1
    8000406e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004070:	8526                	mv	a0,s1
    80004072:	c21fc0ef          	jal	80000c92 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004076:	54dc                	lw	a5,44(s1)
    80004078:	04f04c63          	bgtz	a5,800040d0 <end_op+0x96>
    acquire(&log.lock);
    8000407c:	00025497          	auipc	s1,0x25
    80004080:	72448493          	addi	s1,s1,1828 # 800297a0 <log>
    80004084:	8526                	mv	a0,s1
    80004086:	b79fc0ef          	jal	80000bfe <acquire>
    log.committing = 0;
    8000408a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000408e:	8526                	mv	a0,s1
    80004090:	9eafe0ef          	jal	8000227a <wakeup>
    release(&log.lock);
    80004094:	8526                	mv	a0,s1
    80004096:	bfdfc0ef          	jal	80000c92 <release>
}
    8000409a:	a02d                	j	800040c4 <end_op+0x8a>
    8000409c:	ec4e                	sd	s3,24(sp)
    8000409e:	e852                	sd	s4,16(sp)
    800040a0:	e456                	sd	s5,8(sp)
    800040a2:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    800040a4:	00003517          	auipc	a0,0x3
    800040a8:	58450513          	addi	a0,a0,1412 # 80007628 <etext+0x628>
    800040ac:	ef2fc0ef          	jal	8000079e <panic>
    wakeup(&log);
    800040b0:	00025497          	auipc	s1,0x25
    800040b4:	6f048493          	addi	s1,s1,1776 # 800297a0 <log>
    800040b8:	8526                	mv	a0,s1
    800040ba:	9c0fe0ef          	jal	8000227a <wakeup>
  release(&log.lock);
    800040be:	8526                	mv	a0,s1
    800040c0:	bd3fc0ef          	jal	80000c92 <release>
}
    800040c4:	70e2                	ld	ra,56(sp)
    800040c6:	7442                	ld	s0,48(sp)
    800040c8:	74a2                	ld	s1,40(sp)
    800040ca:	7902                	ld	s2,32(sp)
    800040cc:	6121                	addi	sp,sp,64
    800040ce:	8082                	ret
    800040d0:	ec4e                	sd	s3,24(sp)
    800040d2:	e852                	sd	s4,16(sp)
    800040d4:	e456                	sd	s5,8(sp)
    800040d6:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800040d8:	00025a97          	auipc	s5,0x25
    800040dc:	6f8a8a93          	addi	s5,s5,1784 # 800297d0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800040e0:	00025a17          	auipc	s4,0x25
    800040e4:	6c0a0a13          	addi	s4,s4,1728 # 800297a0 <log>
    memmove(to->data, from->data, BSIZE);
    800040e8:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800040ec:	018a2583          	lw	a1,24(s4)
    800040f0:	012585bb          	addw	a1,a1,s2
    800040f4:	2585                	addiw	a1,a1,1
    800040f6:	028a2503          	lw	a0,40(s4)
    800040fa:	f13fe0ef          	jal	8000300c <bread>
    800040fe:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004100:	000aa583          	lw	a1,0(s5)
    80004104:	028a2503          	lw	a0,40(s4)
    80004108:	f05fe0ef          	jal	8000300c <bread>
    8000410c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000410e:	865a                	mv	a2,s6
    80004110:	05850593          	addi	a1,a0,88
    80004114:	05848513          	addi	a0,s1,88
    80004118:	c1bfc0ef          	jal	80000d32 <memmove>
    bwrite(to);  // write the log
    8000411c:	8526                	mv	a0,s1
    8000411e:	fc5fe0ef          	jal	800030e2 <bwrite>
    brelse(from);
    80004122:	854e                	mv	a0,s3
    80004124:	ff1fe0ef          	jal	80003114 <brelse>
    brelse(to);
    80004128:	8526                	mv	a0,s1
    8000412a:	febfe0ef          	jal	80003114 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000412e:	2905                	addiw	s2,s2,1
    80004130:	0a91                	addi	s5,s5,4
    80004132:	02ca2783          	lw	a5,44(s4)
    80004136:	faf94be3          	blt	s2,a5,800040ec <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000413a:	d07ff0ef          	jal	80003e40 <write_head>
    install_trans(0); // Now install writes to home locations
    8000413e:	4501                	li	a0,0
    80004140:	d5fff0ef          	jal	80003e9e <install_trans>
    log.lh.n = 0;
    80004144:	00025797          	auipc	a5,0x25
    80004148:	6807a423          	sw	zero,1672(a5) # 800297cc <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000414c:	cf5ff0ef          	jal	80003e40 <write_head>
    80004150:	69e2                	ld	s3,24(sp)
    80004152:	6a42                	ld	s4,16(sp)
    80004154:	6aa2                	ld	s5,8(sp)
    80004156:	6b02                	ld	s6,0(sp)
    80004158:	b715                	j	8000407c <end_op+0x42>

000000008000415a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000415a:	1101                	addi	sp,sp,-32
    8000415c:	ec06                	sd	ra,24(sp)
    8000415e:	e822                	sd	s0,16(sp)
    80004160:	e426                	sd	s1,8(sp)
    80004162:	e04a                	sd	s2,0(sp)
    80004164:	1000                	addi	s0,sp,32
    80004166:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004168:	00025917          	auipc	s2,0x25
    8000416c:	63890913          	addi	s2,s2,1592 # 800297a0 <log>
    80004170:	854a                	mv	a0,s2
    80004172:	a8dfc0ef          	jal	80000bfe <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004176:	02c92603          	lw	a2,44(s2)
    8000417a:	47f5                	li	a5,29
    8000417c:	06c7c363          	blt	a5,a2,800041e2 <log_write+0x88>
    80004180:	00025797          	auipc	a5,0x25
    80004184:	63c7a783          	lw	a5,1596(a5) # 800297bc <log+0x1c>
    80004188:	37fd                	addiw	a5,a5,-1
    8000418a:	04f65c63          	bge	a2,a5,800041e2 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000418e:	00025797          	auipc	a5,0x25
    80004192:	6327a783          	lw	a5,1586(a5) # 800297c0 <log+0x20>
    80004196:	04f05c63          	blez	a5,800041ee <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000419a:	4781                	li	a5,0
    8000419c:	04c05f63          	blez	a2,800041fa <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800041a0:	44cc                	lw	a1,12(s1)
    800041a2:	00025717          	auipc	a4,0x25
    800041a6:	62e70713          	addi	a4,a4,1582 # 800297d0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800041aa:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800041ac:	4314                	lw	a3,0(a4)
    800041ae:	04b68663          	beq	a3,a1,800041fa <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    800041b2:	2785                	addiw	a5,a5,1
    800041b4:	0711                	addi	a4,a4,4
    800041b6:	fef61be3          	bne	a2,a5,800041ac <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    800041ba:	0621                	addi	a2,a2,8
    800041bc:	060a                	slli	a2,a2,0x2
    800041be:	00025797          	auipc	a5,0x25
    800041c2:	5e278793          	addi	a5,a5,1506 # 800297a0 <log>
    800041c6:	97b2                	add	a5,a5,a2
    800041c8:	44d8                	lw	a4,12(s1)
    800041ca:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800041cc:	8526                	mv	a0,s1
    800041ce:	fcbfe0ef          	jal	80003198 <bpin>
    log.lh.n++;
    800041d2:	00025717          	auipc	a4,0x25
    800041d6:	5ce70713          	addi	a4,a4,1486 # 800297a0 <log>
    800041da:	575c                	lw	a5,44(a4)
    800041dc:	2785                	addiw	a5,a5,1
    800041de:	d75c                	sw	a5,44(a4)
    800041e0:	a80d                	j	80004212 <log_write+0xb8>
    panic("too big a transaction");
    800041e2:	00003517          	auipc	a0,0x3
    800041e6:	45650513          	addi	a0,a0,1110 # 80007638 <etext+0x638>
    800041ea:	db4fc0ef          	jal	8000079e <panic>
    panic("log_write outside of trans");
    800041ee:	00003517          	auipc	a0,0x3
    800041f2:	46250513          	addi	a0,a0,1122 # 80007650 <etext+0x650>
    800041f6:	da8fc0ef          	jal	8000079e <panic>
  log.lh.block[i] = b->blockno;
    800041fa:	00878693          	addi	a3,a5,8
    800041fe:	068a                	slli	a3,a3,0x2
    80004200:	00025717          	auipc	a4,0x25
    80004204:	5a070713          	addi	a4,a4,1440 # 800297a0 <log>
    80004208:	9736                	add	a4,a4,a3
    8000420a:	44d4                	lw	a3,12(s1)
    8000420c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000420e:	faf60fe3          	beq	a2,a5,800041cc <log_write+0x72>
  }
  release(&log.lock);
    80004212:	00025517          	auipc	a0,0x25
    80004216:	58e50513          	addi	a0,a0,1422 # 800297a0 <log>
    8000421a:	a79fc0ef          	jal	80000c92 <release>
}
    8000421e:	60e2                	ld	ra,24(sp)
    80004220:	6442                	ld	s0,16(sp)
    80004222:	64a2                	ld	s1,8(sp)
    80004224:	6902                	ld	s2,0(sp)
    80004226:	6105                	addi	sp,sp,32
    80004228:	8082                	ret

000000008000422a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000422a:	1101                	addi	sp,sp,-32
    8000422c:	ec06                	sd	ra,24(sp)
    8000422e:	e822                	sd	s0,16(sp)
    80004230:	e426                	sd	s1,8(sp)
    80004232:	e04a                	sd	s2,0(sp)
    80004234:	1000                	addi	s0,sp,32
    80004236:	84aa                	mv	s1,a0
    80004238:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000423a:	00003597          	auipc	a1,0x3
    8000423e:	43658593          	addi	a1,a1,1078 # 80007670 <etext+0x670>
    80004242:	0521                	addi	a0,a0,8
    80004244:	937fc0ef          	jal	80000b7a <initlock>
  lk->name = name;
    80004248:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000424c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004250:	0204a423          	sw	zero,40(s1)
}
    80004254:	60e2                	ld	ra,24(sp)
    80004256:	6442                	ld	s0,16(sp)
    80004258:	64a2                	ld	s1,8(sp)
    8000425a:	6902                	ld	s2,0(sp)
    8000425c:	6105                	addi	sp,sp,32
    8000425e:	8082                	ret

0000000080004260 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004260:	1101                	addi	sp,sp,-32
    80004262:	ec06                	sd	ra,24(sp)
    80004264:	e822                	sd	s0,16(sp)
    80004266:	e426                	sd	s1,8(sp)
    80004268:	e04a                	sd	s2,0(sp)
    8000426a:	1000                	addi	s0,sp,32
    8000426c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000426e:	00850913          	addi	s2,a0,8
    80004272:	854a                	mv	a0,s2
    80004274:	98bfc0ef          	jal	80000bfe <acquire>
  while (lk->locked) {
    80004278:	409c                	lw	a5,0(s1)
    8000427a:	c799                	beqz	a5,80004288 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000427c:	85ca                	mv	a1,s2
    8000427e:	8526                	mv	a0,s1
    80004280:	faffd0ef          	jal	8000222e <sleep>
  while (lk->locked) {
    80004284:	409c                	lw	a5,0(s1)
    80004286:	fbfd                	bnez	a5,8000427c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004288:	4785                	li	a5,1
    8000428a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000428c:	e50fd0ef          	jal	800018dc <myproc>
    80004290:	591c                	lw	a5,48(a0)
    80004292:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004294:	854a                	mv	a0,s2
    80004296:	9fdfc0ef          	jal	80000c92 <release>
}
    8000429a:	60e2                	ld	ra,24(sp)
    8000429c:	6442                	ld	s0,16(sp)
    8000429e:	64a2                	ld	s1,8(sp)
    800042a0:	6902                	ld	s2,0(sp)
    800042a2:	6105                	addi	sp,sp,32
    800042a4:	8082                	ret

00000000800042a6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800042a6:	1101                	addi	sp,sp,-32
    800042a8:	ec06                	sd	ra,24(sp)
    800042aa:	e822                	sd	s0,16(sp)
    800042ac:	e426                	sd	s1,8(sp)
    800042ae:	e04a                	sd	s2,0(sp)
    800042b0:	1000                	addi	s0,sp,32
    800042b2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042b4:	00850913          	addi	s2,a0,8
    800042b8:	854a                	mv	a0,s2
    800042ba:	945fc0ef          	jal	80000bfe <acquire>
  lk->locked = 0;
    800042be:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042c2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800042c6:	8526                	mv	a0,s1
    800042c8:	fb3fd0ef          	jal	8000227a <wakeup>
  release(&lk->lk);
    800042cc:	854a                	mv	a0,s2
    800042ce:	9c5fc0ef          	jal	80000c92 <release>
}
    800042d2:	60e2                	ld	ra,24(sp)
    800042d4:	6442                	ld	s0,16(sp)
    800042d6:	64a2                	ld	s1,8(sp)
    800042d8:	6902                	ld	s2,0(sp)
    800042da:	6105                	addi	sp,sp,32
    800042dc:	8082                	ret

00000000800042de <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800042de:	7179                	addi	sp,sp,-48
    800042e0:	f406                	sd	ra,40(sp)
    800042e2:	f022                	sd	s0,32(sp)
    800042e4:	ec26                	sd	s1,24(sp)
    800042e6:	e84a                	sd	s2,16(sp)
    800042e8:	1800                	addi	s0,sp,48
    800042ea:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800042ec:	00850913          	addi	s2,a0,8
    800042f0:	854a                	mv	a0,s2
    800042f2:	90dfc0ef          	jal	80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800042f6:	409c                	lw	a5,0(s1)
    800042f8:	ef81                	bnez	a5,80004310 <holdingsleep+0x32>
    800042fa:	4481                	li	s1,0
  release(&lk->lk);
    800042fc:	854a                	mv	a0,s2
    800042fe:	995fc0ef          	jal	80000c92 <release>
  return r;
}
    80004302:	8526                	mv	a0,s1
    80004304:	70a2                	ld	ra,40(sp)
    80004306:	7402                	ld	s0,32(sp)
    80004308:	64e2                	ld	s1,24(sp)
    8000430a:	6942                	ld	s2,16(sp)
    8000430c:	6145                	addi	sp,sp,48
    8000430e:	8082                	ret
    80004310:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004312:	0284a983          	lw	s3,40(s1)
    80004316:	dc6fd0ef          	jal	800018dc <myproc>
    8000431a:	5904                	lw	s1,48(a0)
    8000431c:	413484b3          	sub	s1,s1,s3
    80004320:	0014b493          	seqz	s1,s1
    80004324:	69a2                	ld	s3,8(sp)
    80004326:	bfd9                	j	800042fc <holdingsleep+0x1e>

0000000080004328 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004328:	1141                	addi	sp,sp,-16
    8000432a:	e406                	sd	ra,8(sp)
    8000432c:	e022                	sd	s0,0(sp)
    8000432e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004330:	00003597          	auipc	a1,0x3
    80004334:	35058593          	addi	a1,a1,848 # 80007680 <etext+0x680>
    80004338:	00025517          	auipc	a0,0x25
    8000433c:	5b050513          	addi	a0,a0,1456 # 800298e8 <ftable>
    80004340:	83bfc0ef          	jal	80000b7a <initlock>
}
    80004344:	60a2                	ld	ra,8(sp)
    80004346:	6402                	ld	s0,0(sp)
    80004348:	0141                	addi	sp,sp,16
    8000434a:	8082                	ret

000000008000434c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000434c:	1101                	addi	sp,sp,-32
    8000434e:	ec06                	sd	ra,24(sp)
    80004350:	e822                	sd	s0,16(sp)
    80004352:	e426                	sd	s1,8(sp)
    80004354:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004356:	00025517          	auipc	a0,0x25
    8000435a:	59250513          	addi	a0,a0,1426 # 800298e8 <ftable>
    8000435e:	8a1fc0ef          	jal	80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004362:	00025497          	auipc	s1,0x25
    80004366:	59e48493          	addi	s1,s1,1438 # 80029900 <ftable+0x18>
    8000436a:	00026717          	auipc	a4,0x26
    8000436e:	53670713          	addi	a4,a4,1334 # 8002a8a0 <disk>
    if(f->ref == 0){
    80004372:	40dc                	lw	a5,4(s1)
    80004374:	cf89                	beqz	a5,8000438e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004376:	02848493          	addi	s1,s1,40
    8000437a:	fee49ce3          	bne	s1,a4,80004372 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000437e:	00025517          	auipc	a0,0x25
    80004382:	56a50513          	addi	a0,a0,1386 # 800298e8 <ftable>
    80004386:	90dfc0ef          	jal	80000c92 <release>
  return 0;
    8000438a:	4481                	li	s1,0
    8000438c:	a809                	j	8000439e <filealloc+0x52>
      f->ref = 1;
    8000438e:	4785                	li	a5,1
    80004390:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004392:	00025517          	auipc	a0,0x25
    80004396:	55650513          	addi	a0,a0,1366 # 800298e8 <ftable>
    8000439a:	8f9fc0ef          	jal	80000c92 <release>
}
    8000439e:	8526                	mv	a0,s1
    800043a0:	60e2                	ld	ra,24(sp)
    800043a2:	6442                	ld	s0,16(sp)
    800043a4:	64a2                	ld	s1,8(sp)
    800043a6:	6105                	addi	sp,sp,32
    800043a8:	8082                	ret

00000000800043aa <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800043aa:	1101                	addi	sp,sp,-32
    800043ac:	ec06                	sd	ra,24(sp)
    800043ae:	e822                	sd	s0,16(sp)
    800043b0:	e426                	sd	s1,8(sp)
    800043b2:	1000                	addi	s0,sp,32
    800043b4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800043b6:	00025517          	auipc	a0,0x25
    800043ba:	53250513          	addi	a0,a0,1330 # 800298e8 <ftable>
    800043be:	841fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    800043c2:	40dc                	lw	a5,4(s1)
    800043c4:	02f05063          	blez	a5,800043e4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800043c8:	2785                	addiw	a5,a5,1
    800043ca:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800043cc:	00025517          	auipc	a0,0x25
    800043d0:	51c50513          	addi	a0,a0,1308 # 800298e8 <ftable>
    800043d4:	8bffc0ef          	jal	80000c92 <release>
  return f;
}
    800043d8:	8526                	mv	a0,s1
    800043da:	60e2                	ld	ra,24(sp)
    800043dc:	6442                	ld	s0,16(sp)
    800043de:	64a2                	ld	s1,8(sp)
    800043e0:	6105                	addi	sp,sp,32
    800043e2:	8082                	ret
    panic("filedup");
    800043e4:	00003517          	auipc	a0,0x3
    800043e8:	2a450513          	addi	a0,a0,676 # 80007688 <etext+0x688>
    800043ec:	bb2fc0ef          	jal	8000079e <panic>

00000000800043f0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800043f0:	7139                	addi	sp,sp,-64
    800043f2:	fc06                	sd	ra,56(sp)
    800043f4:	f822                	sd	s0,48(sp)
    800043f6:	f426                	sd	s1,40(sp)
    800043f8:	0080                	addi	s0,sp,64
    800043fa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800043fc:	00025517          	auipc	a0,0x25
    80004400:	4ec50513          	addi	a0,a0,1260 # 800298e8 <ftable>
    80004404:	ffafc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80004408:	40dc                	lw	a5,4(s1)
    8000440a:	04f05863          	blez	a5,8000445a <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    8000440e:	37fd                	addiw	a5,a5,-1
    80004410:	c0dc                	sw	a5,4(s1)
    80004412:	04f04e63          	bgtz	a5,8000446e <fileclose+0x7e>
    80004416:	f04a                	sd	s2,32(sp)
    80004418:	ec4e                	sd	s3,24(sp)
    8000441a:	e852                	sd	s4,16(sp)
    8000441c:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000441e:	0004a903          	lw	s2,0(s1)
    80004422:	0094ca83          	lbu	s5,9(s1)
    80004426:	0104ba03          	ld	s4,16(s1)
    8000442a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000442e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004432:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004436:	00025517          	auipc	a0,0x25
    8000443a:	4b250513          	addi	a0,a0,1202 # 800298e8 <ftable>
    8000443e:	855fc0ef          	jal	80000c92 <release>

  if(ff.type == FD_PIPE){
    80004442:	4785                	li	a5,1
    80004444:	04f90063          	beq	s2,a5,80004484 <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004448:	3979                	addiw	s2,s2,-2
    8000444a:	4785                	li	a5,1
    8000444c:	0527f563          	bgeu	a5,s2,80004496 <fileclose+0xa6>
    80004450:	7902                	ld	s2,32(sp)
    80004452:	69e2                	ld	s3,24(sp)
    80004454:	6a42                	ld	s4,16(sp)
    80004456:	6aa2                	ld	s5,8(sp)
    80004458:	a00d                	j	8000447a <fileclose+0x8a>
    8000445a:	f04a                	sd	s2,32(sp)
    8000445c:	ec4e                	sd	s3,24(sp)
    8000445e:	e852                	sd	s4,16(sp)
    80004460:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004462:	00003517          	auipc	a0,0x3
    80004466:	22e50513          	addi	a0,a0,558 # 80007690 <etext+0x690>
    8000446a:	b34fc0ef          	jal	8000079e <panic>
    release(&ftable.lock);
    8000446e:	00025517          	auipc	a0,0x25
    80004472:	47a50513          	addi	a0,a0,1146 # 800298e8 <ftable>
    80004476:	81dfc0ef          	jal	80000c92 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000447a:	70e2                	ld	ra,56(sp)
    8000447c:	7442                	ld	s0,48(sp)
    8000447e:	74a2                	ld	s1,40(sp)
    80004480:	6121                	addi	sp,sp,64
    80004482:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004484:	85d6                	mv	a1,s5
    80004486:	8552                	mv	a0,s4
    80004488:	340000ef          	jal	800047c8 <pipeclose>
    8000448c:	7902                	ld	s2,32(sp)
    8000448e:	69e2                	ld	s3,24(sp)
    80004490:	6a42                	ld	s4,16(sp)
    80004492:	6aa2                	ld	s5,8(sp)
    80004494:	b7dd                	j	8000447a <fileclose+0x8a>
    begin_op();
    80004496:	b3bff0ef          	jal	80003fd0 <begin_op>
    iput(ff.ip);
    8000449a:	854e                	mv	a0,s3
    8000449c:	c04ff0ef          	jal	800038a0 <iput>
    end_op();
    800044a0:	b9bff0ef          	jal	8000403a <end_op>
    800044a4:	7902                	ld	s2,32(sp)
    800044a6:	69e2                	ld	s3,24(sp)
    800044a8:	6a42                	ld	s4,16(sp)
    800044aa:	6aa2                	ld	s5,8(sp)
    800044ac:	b7f9                	j	8000447a <fileclose+0x8a>

00000000800044ae <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800044ae:	715d                	addi	sp,sp,-80
    800044b0:	e486                	sd	ra,72(sp)
    800044b2:	e0a2                	sd	s0,64(sp)
    800044b4:	fc26                	sd	s1,56(sp)
    800044b6:	f44e                	sd	s3,40(sp)
    800044b8:	0880                	addi	s0,sp,80
    800044ba:	84aa                	mv	s1,a0
    800044bc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800044be:	c1efd0ef          	jal	800018dc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800044c2:	409c                	lw	a5,0(s1)
    800044c4:	37f9                	addiw	a5,a5,-2
    800044c6:	4705                	li	a4,1
    800044c8:	04f76263          	bltu	a4,a5,8000450c <filestat+0x5e>
    800044cc:	f84a                	sd	s2,48(sp)
    800044ce:	f052                	sd	s4,32(sp)
    800044d0:	892a                	mv	s2,a0
    ilock(f->ip);
    800044d2:	6c88                	ld	a0,24(s1)
    800044d4:	a4aff0ef          	jal	8000371e <ilock>
    stati(f->ip, &st);
    800044d8:	fb840a13          	addi	s4,s0,-72
    800044dc:	85d2                	mv	a1,s4
    800044de:	6c88                	ld	a0,24(s1)
    800044e0:	c68ff0ef          	jal	80003948 <stati>
    iunlock(f->ip);
    800044e4:	6c88                	ld	a0,24(s1)
    800044e6:	ae6ff0ef          	jal	800037cc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800044ea:	46e1                	li	a3,24
    800044ec:	8652                	mv	a2,s4
    800044ee:	85ce                	mv	a1,s3
    800044f0:	05093503          	ld	a0,80(s2)
    800044f4:	890fd0ef          	jal	80001584 <copyout>
    800044f8:	41f5551b          	sraiw	a0,a0,0x1f
    800044fc:	7942                	ld	s2,48(sp)
    800044fe:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004500:	60a6                	ld	ra,72(sp)
    80004502:	6406                	ld	s0,64(sp)
    80004504:	74e2                	ld	s1,56(sp)
    80004506:	79a2                	ld	s3,40(sp)
    80004508:	6161                	addi	sp,sp,80
    8000450a:	8082                	ret
  return -1;
    8000450c:	557d                	li	a0,-1
    8000450e:	bfcd                	j	80004500 <filestat+0x52>

0000000080004510 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004510:	7179                	addi	sp,sp,-48
    80004512:	f406                	sd	ra,40(sp)
    80004514:	f022                	sd	s0,32(sp)
    80004516:	e84a                	sd	s2,16(sp)
    80004518:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000451a:	00854783          	lbu	a5,8(a0)
    8000451e:	cfd1                	beqz	a5,800045ba <fileread+0xaa>
    80004520:	ec26                	sd	s1,24(sp)
    80004522:	e44e                	sd	s3,8(sp)
    80004524:	84aa                	mv	s1,a0
    80004526:	89ae                	mv	s3,a1
    80004528:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000452a:	411c                	lw	a5,0(a0)
    8000452c:	4705                	li	a4,1
    8000452e:	04e78363          	beq	a5,a4,80004574 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004532:	470d                	li	a4,3
    80004534:	04e78763          	beq	a5,a4,80004582 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004538:	4709                	li	a4,2
    8000453a:	06e79a63          	bne	a5,a4,800045ae <fileread+0x9e>
    ilock(f->ip);
    8000453e:	6d08                	ld	a0,24(a0)
    80004540:	9deff0ef          	jal	8000371e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004544:	874a                	mv	a4,s2
    80004546:	5094                	lw	a3,32(s1)
    80004548:	864e                	mv	a2,s3
    8000454a:	4585                	li	a1,1
    8000454c:	6c88                	ld	a0,24(s1)
    8000454e:	c28ff0ef          	jal	80003976 <readi>
    80004552:	892a                	mv	s2,a0
    80004554:	00a05563          	blez	a0,8000455e <fileread+0x4e>
      f->off += r;
    80004558:	509c                	lw	a5,32(s1)
    8000455a:	9fa9                	addw	a5,a5,a0
    8000455c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000455e:	6c88                	ld	a0,24(s1)
    80004560:	a6cff0ef          	jal	800037cc <iunlock>
    80004564:	64e2                	ld	s1,24(sp)
    80004566:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004568:	854a                	mv	a0,s2
    8000456a:	70a2                	ld	ra,40(sp)
    8000456c:	7402                	ld	s0,32(sp)
    8000456e:	6942                	ld	s2,16(sp)
    80004570:	6145                	addi	sp,sp,48
    80004572:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004574:	6908                	ld	a0,16(a0)
    80004576:	3a2000ef          	jal	80004918 <piperead>
    8000457a:	892a                	mv	s2,a0
    8000457c:	64e2                	ld	s1,24(sp)
    8000457e:	69a2                	ld	s3,8(sp)
    80004580:	b7e5                	j	80004568 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004582:	02451783          	lh	a5,36(a0)
    80004586:	03079693          	slli	a3,a5,0x30
    8000458a:	92c1                	srli	a3,a3,0x30
    8000458c:	4725                	li	a4,9
    8000458e:	02d76863          	bltu	a4,a3,800045be <fileread+0xae>
    80004592:	0792                	slli	a5,a5,0x4
    80004594:	00025717          	auipc	a4,0x25
    80004598:	2b470713          	addi	a4,a4,692 # 80029848 <devsw>
    8000459c:	97ba                	add	a5,a5,a4
    8000459e:	639c                	ld	a5,0(a5)
    800045a0:	c39d                	beqz	a5,800045c6 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800045a2:	4505                	li	a0,1
    800045a4:	9782                	jalr	a5
    800045a6:	892a                	mv	s2,a0
    800045a8:	64e2                	ld	s1,24(sp)
    800045aa:	69a2                	ld	s3,8(sp)
    800045ac:	bf75                	j	80004568 <fileread+0x58>
    panic("fileread");
    800045ae:	00003517          	auipc	a0,0x3
    800045b2:	0f250513          	addi	a0,a0,242 # 800076a0 <etext+0x6a0>
    800045b6:	9e8fc0ef          	jal	8000079e <panic>
    return -1;
    800045ba:	597d                	li	s2,-1
    800045bc:	b775                	j	80004568 <fileread+0x58>
      return -1;
    800045be:	597d                	li	s2,-1
    800045c0:	64e2                	ld	s1,24(sp)
    800045c2:	69a2                	ld	s3,8(sp)
    800045c4:	b755                	j	80004568 <fileread+0x58>
    800045c6:	597d                	li	s2,-1
    800045c8:	64e2                	ld	s1,24(sp)
    800045ca:	69a2                	ld	s3,8(sp)
    800045cc:	bf71                	j	80004568 <fileread+0x58>

00000000800045ce <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800045ce:	00954783          	lbu	a5,9(a0)
    800045d2:	10078e63          	beqz	a5,800046ee <filewrite+0x120>
{
    800045d6:	711d                	addi	sp,sp,-96
    800045d8:	ec86                	sd	ra,88(sp)
    800045da:	e8a2                	sd	s0,80(sp)
    800045dc:	e0ca                	sd	s2,64(sp)
    800045de:	f456                	sd	s5,40(sp)
    800045e0:	f05a                	sd	s6,32(sp)
    800045e2:	1080                	addi	s0,sp,96
    800045e4:	892a                	mv	s2,a0
    800045e6:	8b2e                	mv	s6,a1
    800045e8:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800045ea:	411c                	lw	a5,0(a0)
    800045ec:	4705                	li	a4,1
    800045ee:	02e78963          	beq	a5,a4,80004620 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045f2:	470d                	li	a4,3
    800045f4:	02e78a63          	beq	a5,a4,80004628 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800045f8:	4709                	li	a4,2
    800045fa:	0ce79e63          	bne	a5,a4,800046d6 <filewrite+0x108>
    800045fe:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004600:	0ac05963          	blez	a2,800046b2 <filewrite+0xe4>
    80004604:	e4a6                	sd	s1,72(sp)
    80004606:	fc4e                	sd	s3,56(sp)
    80004608:	ec5e                	sd	s7,24(sp)
    8000460a:	e862                	sd	s8,16(sp)
    8000460c:	e466                	sd	s9,8(sp)
    int i = 0;
    8000460e:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004610:	6b85                	lui	s7,0x1
    80004612:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004616:	6c85                	lui	s9,0x1
    80004618:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000461c:	4c05                	li	s8,1
    8000461e:	a8ad                	j	80004698 <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    80004620:	6908                	ld	a0,16(a0)
    80004622:	1fe000ef          	jal	80004820 <pipewrite>
    80004626:	a04d                	j	800046c8 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004628:	02451783          	lh	a5,36(a0)
    8000462c:	03079693          	slli	a3,a5,0x30
    80004630:	92c1                	srli	a3,a3,0x30
    80004632:	4725                	li	a4,9
    80004634:	0ad76f63          	bltu	a4,a3,800046f2 <filewrite+0x124>
    80004638:	0792                	slli	a5,a5,0x4
    8000463a:	00025717          	auipc	a4,0x25
    8000463e:	20e70713          	addi	a4,a4,526 # 80029848 <devsw>
    80004642:	97ba                	add	a5,a5,a4
    80004644:	679c                	ld	a5,8(a5)
    80004646:	cbc5                	beqz	a5,800046f6 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004648:	4505                	li	a0,1
    8000464a:	9782                	jalr	a5
    8000464c:	a8b5                	j	800046c8 <filewrite+0xfa>
      if(n1 > max)
    8000464e:	2981                	sext.w	s3,s3
      begin_op();
    80004650:	981ff0ef          	jal	80003fd0 <begin_op>
      ilock(f->ip);
    80004654:	01893503          	ld	a0,24(s2)
    80004658:	8c6ff0ef          	jal	8000371e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000465c:	874e                	mv	a4,s3
    8000465e:	02092683          	lw	a3,32(s2)
    80004662:	016a0633          	add	a2,s4,s6
    80004666:	85e2                	mv	a1,s8
    80004668:	01893503          	ld	a0,24(s2)
    8000466c:	bfcff0ef          	jal	80003a68 <writei>
    80004670:	84aa                	mv	s1,a0
    80004672:	00a05763          	blez	a0,80004680 <filewrite+0xb2>
        f->off += r;
    80004676:	02092783          	lw	a5,32(s2)
    8000467a:	9fa9                	addw	a5,a5,a0
    8000467c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004680:	01893503          	ld	a0,24(s2)
    80004684:	948ff0ef          	jal	800037cc <iunlock>
      end_op();
    80004688:	9b3ff0ef          	jal	8000403a <end_op>

      if(r != n1){
    8000468c:	02999563          	bne	s3,s1,800046b6 <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    80004690:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004694:	015a5963          	bge	s4,s5,800046a6 <filewrite+0xd8>
      int n1 = n - i;
    80004698:	414a87bb          	subw	a5,s5,s4
    8000469c:	89be                	mv	s3,a5
      if(n1 > max)
    8000469e:	fafbd8e3          	bge	s7,a5,8000464e <filewrite+0x80>
    800046a2:	89e6                	mv	s3,s9
    800046a4:	b76d                	j	8000464e <filewrite+0x80>
    800046a6:	64a6                	ld	s1,72(sp)
    800046a8:	79e2                	ld	s3,56(sp)
    800046aa:	6be2                	ld	s7,24(sp)
    800046ac:	6c42                	ld	s8,16(sp)
    800046ae:	6ca2                	ld	s9,8(sp)
    800046b0:	a801                	j	800046c0 <filewrite+0xf2>
    int i = 0;
    800046b2:	4a01                	li	s4,0
    800046b4:	a031                	j	800046c0 <filewrite+0xf2>
    800046b6:	64a6                	ld	s1,72(sp)
    800046b8:	79e2                	ld	s3,56(sp)
    800046ba:	6be2                	ld	s7,24(sp)
    800046bc:	6c42                	ld	s8,16(sp)
    800046be:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800046c0:	034a9d63          	bne	s5,s4,800046fa <filewrite+0x12c>
    800046c4:	8556                	mv	a0,s5
    800046c6:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800046c8:	60e6                	ld	ra,88(sp)
    800046ca:	6446                	ld	s0,80(sp)
    800046cc:	6906                	ld	s2,64(sp)
    800046ce:	7aa2                	ld	s5,40(sp)
    800046d0:	7b02                	ld	s6,32(sp)
    800046d2:	6125                	addi	sp,sp,96
    800046d4:	8082                	ret
    800046d6:	e4a6                	sd	s1,72(sp)
    800046d8:	fc4e                	sd	s3,56(sp)
    800046da:	f852                	sd	s4,48(sp)
    800046dc:	ec5e                	sd	s7,24(sp)
    800046de:	e862                	sd	s8,16(sp)
    800046e0:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800046e2:	00003517          	auipc	a0,0x3
    800046e6:	fce50513          	addi	a0,a0,-50 # 800076b0 <etext+0x6b0>
    800046ea:	8b4fc0ef          	jal	8000079e <panic>
    return -1;
    800046ee:	557d                	li	a0,-1
}
    800046f0:	8082                	ret
      return -1;
    800046f2:	557d                	li	a0,-1
    800046f4:	bfd1                	j	800046c8 <filewrite+0xfa>
    800046f6:	557d                	li	a0,-1
    800046f8:	bfc1                	j	800046c8 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    800046fa:	557d                	li	a0,-1
    800046fc:	7a42                	ld	s4,48(sp)
    800046fe:	b7e9                	j	800046c8 <filewrite+0xfa>

0000000080004700 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004700:	7179                	addi	sp,sp,-48
    80004702:	f406                	sd	ra,40(sp)
    80004704:	f022                	sd	s0,32(sp)
    80004706:	ec26                	sd	s1,24(sp)
    80004708:	e052                	sd	s4,0(sp)
    8000470a:	1800                	addi	s0,sp,48
    8000470c:	84aa                	mv	s1,a0
    8000470e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004710:	0005b023          	sd	zero,0(a1)
    80004714:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004718:	c35ff0ef          	jal	8000434c <filealloc>
    8000471c:	e088                	sd	a0,0(s1)
    8000471e:	c549                	beqz	a0,800047a8 <pipealloc+0xa8>
    80004720:	c2dff0ef          	jal	8000434c <filealloc>
    80004724:	00aa3023          	sd	a0,0(s4)
    80004728:	cd25                	beqz	a0,800047a0 <pipealloc+0xa0>
    8000472a:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000472c:	bfefc0ef          	jal	80000b2a <kalloc>
    80004730:	892a                	mv	s2,a0
    80004732:	c12d                	beqz	a0,80004794 <pipealloc+0x94>
    80004734:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004736:	4985                	li	s3,1
    80004738:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000473c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004740:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004744:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004748:	00003597          	auipc	a1,0x3
    8000474c:	bb858593          	addi	a1,a1,-1096 # 80007300 <etext+0x300>
    80004750:	c2afc0ef          	jal	80000b7a <initlock>
  (*f0)->type = FD_PIPE;
    80004754:	609c                	ld	a5,0(s1)
    80004756:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000475a:	609c                	ld	a5,0(s1)
    8000475c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004760:	609c                	ld	a5,0(s1)
    80004762:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004766:	609c                	ld	a5,0(s1)
    80004768:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000476c:	000a3783          	ld	a5,0(s4)
    80004770:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004774:	000a3783          	ld	a5,0(s4)
    80004778:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000477c:	000a3783          	ld	a5,0(s4)
    80004780:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004784:	000a3783          	ld	a5,0(s4)
    80004788:	0127b823          	sd	s2,16(a5)
  return 0;
    8000478c:	4501                	li	a0,0
    8000478e:	6942                	ld	s2,16(sp)
    80004790:	69a2                	ld	s3,8(sp)
    80004792:	a01d                	j	800047b8 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004794:	6088                	ld	a0,0(s1)
    80004796:	c119                	beqz	a0,8000479c <pipealloc+0x9c>
    80004798:	6942                	ld	s2,16(sp)
    8000479a:	a029                	j	800047a4 <pipealloc+0xa4>
    8000479c:	6942                	ld	s2,16(sp)
    8000479e:	a029                	j	800047a8 <pipealloc+0xa8>
    800047a0:	6088                	ld	a0,0(s1)
    800047a2:	c10d                	beqz	a0,800047c4 <pipealloc+0xc4>
    fileclose(*f0);
    800047a4:	c4dff0ef          	jal	800043f0 <fileclose>
  if(*f1)
    800047a8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800047ac:	557d                	li	a0,-1
  if(*f1)
    800047ae:	c789                	beqz	a5,800047b8 <pipealloc+0xb8>
    fileclose(*f1);
    800047b0:	853e                	mv	a0,a5
    800047b2:	c3fff0ef          	jal	800043f0 <fileclose>
  return -1;
    800047b6:	557d                	li	a0,-1
}
    800047b8:	70a2                	ld	ra,40(sp)
    800047ba:	7402                	ld	s0,32(sp)
    800047bc:	64e2                	ld	s1,24(sp)
    800047be:	6a02                	ld	s4,0(sp)
    800047c0:	6145                	addi	sp,sp,48
    800047c2:	8082                	ret
  return -1;
    800047c4:	557d                	li	a0,-1
    800047c6:	bfcd                	j	800047b8 <pipealloc+0xb8>

00000000800047c8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800047c8:	1101                	addi	sp,sp,-32
    800047ca:	ec06                	sd	ra,24(sp)
    800047cc:	e822                	sd	s0,16(sp)
    800047ce:	e426                	sd	s1,8(sp)
    800047d0:	e04a                	sd	s2,0(sp)
    800047d2:	1000                	addi	s0,sp,32
    800047d4:	84aa                	mv	s1,a0
    800047d6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800047d8:	c26fc0ef          	jal	80000bfe <acquire>
  if(writable){
    800047dc:	02090763          	beqz	s2,8000480a <pipeclose+0x42>
    pi->writeopen = 0;
    800047e0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800047e4:	21848513          	addi	a0,s1,536
    800047e8:	a93fd0ef          	jal	8000227a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800047ec:	2204b783          	ld	a5,544(s1)
    800047f0:	e785                	bnez	a5,80004818 <pipeclose+0x50>
    release(&pi->lock);
    800047f2:	8526                	mv	a0,s1
    800047f4:	c9efc0ef          	jal	80000c92 <release>
    kfree((char*)pi);
    800047f8:	8526                	mv	a0,s1
    800047fa:	a4efc0ef          	jal	80000a48 <kfree>
  } else
    release(&pi->lock);
}
    800047fe:	60e2                	ld	ra,24(sp)
    80004800:	6442                	ld	s0,16(sp)
    80004802:	64a2                	ld	s1,8(sp)
    80004804:	6902                	ld	s2,0(sp)
    80004806:	6105                	addi	sp,sp,32
    80004808:	8082                	ret
    pi->readopen = 0;
    8000480a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000480e:	21c48513          	addi	a0,s1,540
    80004812:	a69fd0ef          	jal	8000227a <wakeup>
    80004816:	bfd9                	j	800047ec <pipeclose+0x24>
    release(&pi->lock);
    80004818:	8526                	mv	a0,s1
    8000481a:	c78fc0ef          	jal	80000c92 <release>
}
    8000481e:	b7c5                	j	800047fe <pipeclose+0x36>

0000000080004820 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004820:	7159                	addi	sp,sp,-112
    80004822:	f486                	sd	ra,104(sp)
    80004824:	f0a2                	sd	s0,96(sp)
    80004826:	eca6                	sd	s1,88(sp)
    80004828:	e8ca                	sd	s2,80(sp)
    8000482a:	e4ce                	sd	s3,72(sp)
    8000482c:	e0d2                	sd	s4,64(sp)
    8000482e:	fc56                	sd	s5,56(sp)
    80004830:	1880                	addi	s0,sp,112
    80004832:	84aa                	mv	s1,a0
    80004834:	8aae                	mv	s5,a1
    80004836:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004838:	8a4fd0ef          	jal	800018dc <myproc>
    8000483c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000483e:	8526                	mv	a0,s1
    80004840:	bbefc0ef          	jal	80000bfe <acquire>
  while(i < n){
    80004844:	0d405263          	blez	s4,80004908 <pipewrite+0xe8>
    80004848:	f85a                	sd	s6,48(sp)
    8000484a:	f45e                	sd	s7,40(sp)
    8000484c:	f062                	sd	s8,32(sp)
    8000484e:	ec66                	sd	s9,24(sp)
    80004850:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004852:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004854:	f9f40c13          	addi	s8,s0,-97
    80004858:	4b85                	li	s7,1
    8000485a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000485c:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004860:	21c48c93          	addi	s9,s1,540
    80004864:	a82d                	j	8000489e <pipewrite+0x7e>
      release(&pi->lock);
    80004866:	8526                	mv	a0,s1
    80004868:	c2afc0ef          	jal	80000c92 <release>
      return -1;
    8000486c:	597d                	li	s2,-1
    8000486e:	7b42                	ld	s6,48(sp)
    80004870:	7ba2                	ld	s7,40(sp)
    80004872:	7c02                	ld	s8,32(sp)
    80004874:	6ce2                	ld	s9,24(sp)
    80004876:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004878:	854a                	mv	a0,s2
    8000487a:	70a6                	ld	ra,104(sp)
    8000487c:	7406                	ld	s0,96(sp)
    8000487e:	64e6                	ld	s1,88(sp)
    80004880:	6946                	ld	s2,80(sp)
    80004882:	69a6                	ld	s3,72(sp)
    80004884:	6a06                	ld	s4,64(sp)
    80004886:	7ae2                	ld	s5,56(sp)
    80004888:	6165                	addi	sp,sp,112
    8000488a:	8082                	ret
      wakeup(&pi->nread);
    8000488c:	856a                	mv	a0,s10
    8000488e:	9edfd0ef          	jal	8000227a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004892:	85a6                	mv	a1,s1
    80004894:	8566                	mv	a0,s9
    80004896:	999fd0ef          	jal	8000222e <sleep>
  while(i < n){
    8000489a:	05495a63          	bge	s2,s4,800048ee <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000489e:	2204a783          	lw	a5,544(s1)
    800048a2:	d3f1                	beqz	a5,80004866 <pipewrite+0x46>
    800048a4:	854e                	mv	a0,s3
    800048a6:	bc1fd0ef          	jal	80002466 <killed>
    800048aa:	fd55                	bnez	a0,80004866 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800048ac:	2184a783          	lw	a5,536(s1)
    800048b0:	21c4a703          	lw	a4,540(s1)
    800048b4:	2007879b          	addiw	a5,a5,512
    800048b8:	fcf70ae3          	beq	a4,a5,8000488c <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800048bc:	86de                	mv	a3,s7
    800048be:	01590633          	add	a2,s2,s5
    800048c2:	85e2                	mv	a1,s8
    800048c4:	0509b503          	ld	a0,80(s3)
    800048c8:	d6dfc0ef          	jal	80001634 <copyin>
    800048cc:	05650063          	beq	a0,s6,8000490c <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800048d0:	21c4a783          	lw	a5,540(s1)
    800048d4:	0017871b          	addiw	a4,a5,1
    800048d8:	20e4ae23          	sw	a4,540(s1)
    800048dc:	1ff7f793          	andi	a5,a5,511
    800048e0:	97a6                	add	a5,a5,s1
    800048e2:	f9f44703          	lbu	a4,-97(s0)
    800048e6:	00e78c23          	sb	a4,24(a5)
      i++;
    800048ea:	2905                	addiw	s2,s2,1
    800048ec:	b77d                	j	8000489a <pipewrite+0x7a>
    800048ee:	7b42                	ld	s6,48(sp)
    800048f0:	7ba2                	ld	s7,40(sp)
    800048f2:	7c02                	ld	s8,32(sp)
    800048f4:	6ce2                	ld	s9,24(sp)
    800048f6:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800048f8:	21848513          	addi	a0,s1,536
    800048fc:	97ffd0ef          	jal	8000227a <wakeup>
  release(&pi->lock);
    80004900:	8526                	mv	a0,s1
    80004902:	b90fc0ef          	jal	80000c92 <release>
  return i;
    80004906:	bf8d                	j	80004878 <pipewrite+0x58>
  int i = 0;
    80004908:	4901                	li	s2,0
    8000490a:	b7fd                	j	800048f8 <pipewrite+0xd8>
    8000490c:	7b42                	ld	s6,48(sp)
    8000490e:	7ba2                	ld	s7,40(sp)
    80004910:	7c02                	ld	s8,32(sp)
    80004912:	6ce2                	ld	s9,24(sp)
    80004914:	6d42                	ld	s10,16(sp)
    80004916:	b7cd                	j	800048f8 <pipewrite+0xd8>

0000000080004918 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004918:	711d                	addi	sp,sp,-96
    8000491a:	ec86                	sd	ra,88(sp)
    8000491c:	e8a2                	sd	s0,80(sp)
    8000491e:	e4a6                	sd	s1,72(sp)
    80004920:	e0ca                	sd	s2,64(sp)
    80004922:	fc4e                	sd	s3,56(sp)
    80004924:	f852                	sd	s4,48(sp)
    80004926:	f456                	sd	s5,40(sp)
    80004928:	1080                	addi	s0,sp,96
    8000492a:	84aa                	mv	s1,a0
    8000492c:	892e                	mv	s2,a1
    8000492e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004930:	fadfc0ef          	jal	800018dc <myproc>
    80004934:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004936:	8526                	mv	a0,s1
    80004938:	ac6fc0ef          	jal	80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000493c:	2184a703          	lw	a4,536(s1)
    80004940:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004944:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004948:	02f71763          	bne	a4,a5,80004976 <piperead+0x5e>
    8000494c:	2244a783          	lw	a5,548(s1)
    80004950:	cf85                	beqz	a5,80004988 <piperead+0x70>
    if(killed(pr)){
    80004952:	8552                	mv	a0,s4
    80004954:	b13fd0ef          	jal	80002466 <killed>
    80004958:	e11d                	bnez	a0,8000497e <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000495a:	85a6                	mv	a1,s1
    8000495c:	854e                	mv	a0,s3
    8000495e:	8d1fd0ef          	jal	8000222e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004962:	2184a703          	lw	a4,536(s1)
    80004966:	21c4a783          	lw	a5,540(s1)
    8000496a:	fef701e3          	beq	a4,a5,8000494c <piperead+0x34>
    8000496e:	f05a                	sd	s6,32(sp)
    80004970:	ec5e                	sd	s7,24(sp)
    80004972:	e862                	sd	s8,16(sp)
    80004974:	a829                	j	8000498e <piperead+0x76>
    80004976:	f05a                	sd	s6,32(sp)
    80004978:	ec5e                	sd	s7,24(sp)
    8000497a:	e862                	sd	s8,16(sp)
    8000497c:	a809                	j	8000498e <piperead+0x76>
      release(&pi->lock);
    8000497e:	8526                	mv	a0,s1
    80004980:	b12fc0ef          	jal	80000c92 <release>
      return -1;
    80004984:	59fd                	li	s3,-1
    80004986:	a0a5                	j	800049ee <piperead+0xd6>
    80004988:	f05a                	sd	s6,32(sp)
    8000498a:	ec5e                	sd	s7,24(sp)
    8000498c:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000498e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004990:	faf40c13          	addi	s8,s0,-81
    80004994:	4b85                	li	s7,1
    80004996:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004998:	05505163          	blez	s5,800049da <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    8000499c:	2184a783          	lw	a5,536(s1)
    800049a0:	21c4a703          	lw	a4,540(s1)
    800049a4:	02f70b63          	beq	a4,a5,800049da <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800049a8:	0017871b          	addiw	a4,a5,1
    800049ac:	20e4ac23          	sw	a4,536(s1)
    800049b0:	1ff7f793          	andi	a5,a5,511
    800049b4:	97a6                	add	a5,a5,s1
    800049b6:	0187c783          	lbu	a5,24(a5)
    800049ba:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800049be:	86de                	mv	a3,s7
    800049c0:	8662                	mv	a2,s8
    800049c2:	85ca                	mv	a1,s2
    800049c4:	050a3503          	ld	a0,80(s4)
    800049c8:	bbdfc0ef          	jal	80001584 <copyout>
    800049cc:	01650763          	beq	a0,s6,800049da <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049d0:	2985                	addiw	s3,s3,1
    800049d2:	0905                	addi	s2,s2,1
    800049d4:	fd3a94e3          	bne	s5,s3,8000499c <piperead+0x84>
    800049d8:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800049da:	21c48513          	addi	a0,s1,540
    800049de:	89dfd0ef          	jal	8000227a <wakeup>
  release(&pi->lock);
    800049e2:	8526                	mv	a0,s1
    800049e4:	aaefc0ef          	jal	80000c92 <release>
    800049e8:	7b02                	ld	s6,32(sp)
    800049ea:	6be2                	ld	s7,24(sp)
    800049ec:	6c42                	ld	s8,16(sp)
  return i;
}
    800049ee:	854e                	mv	a0,s3
    800049f0:	60e6                	ld	ra,88(sp)
    800049f2:	6446                	ld	s0,80(sp)
    800049f4:	64a6                	ld	s1,72(sp)
    800049f6:	6906                	ld	s2,64(sp)
    800049f8:	79e2                	ld	s3,56(sp)
    800049fa:	7a42                	ld	s4,48(sp)
    800049fc:	7aa2                	ld	s5,40(sp)
    800049fe:	6125                	addi	sp,sp,96
    80004a00:	8082                	ret

0000000080004a02 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004a02:	1141                	addi	sp,sp,-16
    80004a04:	e406                	sd	ra,8(sp)
    80004a06:	e022                	sd	s0,0(sp)
    80004a08:	0800                	addi	s0,sp,16
    80004a0a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004a0c:	0035151b          	slliw	a0,a0,0x3
    80004a10:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004a12:	8b89                	andi	a5,a5,2
    80004a14:	c399                	beqz	a5,80004a1a <flags2perm+0x18>
      perm |= PTE_W;
    80004a16:	00456513          	ori	a0,a0,4
    return perm;
}
    80004a1a:	60a2                	ld	ra,8(sp)
    80004a1c:	6402                	ld	s0,0(sp)
    80004a1e:	0141                	addi	sp,sp,16
    80004a20:	8082                	ret

0000000080004a22 <exec>:

int
exec(char *path, char **argv)
{
    80004a22:	de010113          	addi	sp,sp,-544
    80004a26:	20113c23          	sd	ra,536(sp)
    80004a2a:	20813823          	sd	s0,528(sp)
    80004a2e:	20913423          	sd	s1,520(sp)
    80004a32:	21213023          	sd	s2,512(sp)
    80004a36:	1400                	addi	s0,sp,544
    80004a38:	892a                	mv	s2,a0
    80004a3a:	dea43823          	sd	a0,-528(s0)
    80004a3e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a42:	e9bfc0ef          	jal	800018dc <myproc>
    80004a46:	84aa                	mv	s1,a0

  begin_op();
    80004a48:	d88ff0ef          	jal	80003fd0 <begin_op>

  if((ip = namei(path)) == 0){
    80004a4c:	854a                	mv	a0,s2
    80004a4e:	bc0ff0ef          	jal	80003e0e <namei>
    80004a52:	cd21                	beqz	a0,80004aaa <exec+0x88>
    80004a54:	fbd2                	sd	s4,496(sp)
    80004a56:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a58:	cc7fe0ef          	jal	8000371e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a5c:	04000713          	li	a4,64
    80004a60:	4681                	li	a3,0
    80004a62:	e5040613          	addi	a2,s0,-432
    80004a66:	4581                	li	a1,0
    80004a68:	8552                	mv	a0,s4
    80004a6a:	f0dfe0ef          	jal	80003976 <readi>
    80004a6e:	04000793          	li	a5,64
    80004a72:	00f51a63          	bne	a0,a5,80004a86 <exec+0x64>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004a76:	e5042703          	lw	a4,-432(s0)
    80004a7a:	464c47b7          	lui	a5,0x464c4
    80004a7e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a82:	02f70863          	beq	a4,a5,80004ab2 <exec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004a86:	8552                	mv	a0,s4
    80004a88:	ea1fe0ef          	jal	80003928 <iunlockput>
    end_op();
    80004a8c:	daeff0ef          	jal	8000403a <end_op>
  }
  return -1;
    80004a90:	557d                	li	a0,-1
    80004a92:	7a5e                	ld	s4,496(sp)
}
    80004a94:	21813083          	ld	ra,536(sp)
    80004a98:	21013403          	ld	s0,528(sp)
    80004a9c:	20813483          	ld	s1,520(sp)
    80004aa0:	20013903          	ld	s2,512(sp)
    80004aa4:	22010113          	addi	sp,sp,544
    80004aa8:	8082                	ret
    end_op();
    80004aaa:	d90ff0ef          	jal	8000403a <end_op>
    return -1;
    80004aae:	557d                	li	a0,-1
    80004ab0:	b7d5                	j	80004a94 <exec+0x72>
    80004ab2:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004ab4:	8526                	mv	a0,s1
    80004ab6:	ecffc0ef          	jal	80001984 <proc_pagetable>
    80004aba:	8b2a                	mv	s6,a0
    80004abc:	26050d63          	beqz	a0,80004d36 <exec+0x314>
    80004ac0:	ffce                	sd	s3,504(sp)
    80004ac2:	f7d6                	sd	s5,488(sp)
    80004ac4:	efde                	sd	s7,472(sp)
    80004ac6:	ebe2                	sd	s8,464(sp)
    80004ac8:	e7e6                	sd	s9,456(sp)
    80004aca:	e3ea                	sd	s10,448(sp)
    80004acc:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ace:	e7042683          	lw	a3,-400(s0)
    80004ad2:	e8845783          	lhu	a5,-376(s0)
    80004ad6:	0e078763          	beqz	a5,80004bc4 <exec+0x1a2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ada:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004adc:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ade:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004ae2:	6c85                	lui	s9,0x1
    80004ae4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ae8:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004aec:	6a85                	lui	s5,0x1
    80004aee:	a085                	j	80004b4e <exec+0x12c>
      panic("loadseg: address should exist");
    80004af0:	00003517          	auipc	a0,0x3
    80004af4:	bd050513          	addi	a0,a0,-1072 # 800076c0 <etext+0x6c0>
    80004af8:	ca7fb0ef          	jal	8000079e <panic>
    if(sz - i < PGSIZE)
    80004afc:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004afe:	874a                	mv	a4,s2
    80004b00:	009c06bb          	addw	a3,s8,s1
    80004b04:	4581                	li	a1,0
    80004b06:	8552                	mv	a0,s4
    80004b08:	e6ffe0ef          	jal	80003976 <readi>
    80004b0c:	22a91963          	bne	s2,a0,80004d3e <exec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    80004b10:	009a84bb          	addw	s1,s5,s1
    80004b14:	0334f263          	bgeu	s1,s3,80004b38 <exec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004b18:	02049593          	slli	a1,s1,0x20
    80004b1c:	9181                	srli	a1,a1,0x20
    80004b1e:	95de                	add	a1,a1,s7
    80004b20:	855a                	mv	a0,s6
    80004b22:	cdafc0ef          	jal	80000ffc <walkaddr>
    80004b26:	862a                	mv	a2,a0
    if(pa == 0)
    80004b28:	d561                	beqz	a0,80004af0 <exec+0xce>
    if(sz - i < PGSIZE)
    80004b2a:	409987bb          	subw	a5,s3,s1
    80004b2e:	893e                	mv	s2,a5
    80004b30:	fcfcf6e3          	bgeu	s9,a5,80004afc <exec+0xda>
    80004b34:	8956                	mv	s2,s5
    80004b36:	b7d9                	j	80004afc <exec+0xda>
    sz = sz1;
    80004b38:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b3c:	2d05                	addiw	s10,s10,1
    80004b3e:	e0843783          	ld	a5,-504(s0)
    80004b42:	0387869b          	addiw	a3,a5,56
    80004b46:	e8845783          	lhu	a5,-376(s0)
    80004b4a:	06fd5e63          	bge	s10,a5,80004bc6 <exec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b4e:	e0d43423          	sd	a3,-504(s0)
    80004b52:	876e                	mv	a4,s11
    80004b54:	e1840613          	addi	a2,s0,-488
    80004b58:	4581                	li	a1,0
    80004b5a:	8552                	mv	a0,s4
    80004b5c:	e1bfe0ef          	jal	80003976 <readi>
    80004b60:	1db51d63          	bne	a0,s11,80004d3a <exec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    80004b64:	e1842783          	lw	a5,-488(s0)
    80004b68:	4705                	li	a4,1
    80004b6a:	fce799e3          	bne	a5,a4,80004b3c <exec+0x11a>
    if(ph.memsz < ph.filesz)
    80004b6e:	e4043483          	ld	s1,-448(s0)
    80004b72:	e3843783          	ld	a5,-456(s0)
    80004b76:	1ef4e263          	bltu	s1,a5,80004d5a <exec+0x338>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004b7a:	e2843783          	ld	a5,-472(s0)
    80004b7e:	94be                	add	s1,s1,a5
    80004b80:	1ef4e063          	bltu	s1,a5,80004d60 <exec+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    80004b84:	de843703          	ld	a4,-536(s0)
    80004b88:	8ff9                	and	a5,a5,a4
    80004b8a:	1c079e63          	bnez	a5,80004d66 <exec+0x344>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004b8e:	e1c42503          	lw	a0,-484(s0)
    80004b92:	e71ff0ef          	jal	80004a02 <flags2perm>
    80004b96:	86aa                	mv	a3,a0
    80004b98:	8626                	mv	a2,s1
    80004b9a:	85ca                	mv	a1,s2
    80004b9c:	855a                	mv	a0,s6
    80004b9e:	fc6fc0ef          	jal	80001364 <uvmalloc>
    80004ba2:	dea43c23          	sd	a0,-520(s0)
    80004ba6:	1c050363          	beqz	a0,80004d6c <exec+0x34a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004baa:	e2843b83          	ld	s7,-472(s0)
    80004bae:	e2042c03          	lw	s8,-480(s0)
    80004bb2:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004bb6:	00098463          	beqz	s3,80004bbe <exec+0x19c>
    80004bba:	4481                	li	s1,0
    80004bbc:	bfb1                	j	80004b18 <exec+0xf6>
    sz = sz1;
    80004bbe:	df843903          	ld	s2,-520(s0)
    80004bc2:	bfad                	j	80004b3c <exec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bc4:	4901                	li	s2,0
  iunlockput(ip);
    80004bc6:	8552                	mv	a0,s4
    80004bc8:	d61fe0ef          	jal	80003928 <iunlockput>
  end_op();
    80004bcc:	c6eff0ef          	jal	8000403a <end_op>
  p = myproc();
    80004bd0:	d0dfc0ef          	jal	800018dc <myproc>
    80004bd4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004bd6:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004bda:	6985                	lui	s3,0x1
    80004bdc:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004bde:	99ca                	add	s3,s3,s2
    80004be0:	77fd                	lui	a5,0xfffff
    80004be2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004be6:	4691                	li	a3,4
    80004be8:	6609                	lui	a2,0x2
    80004bea:	964e                	add	a2,a2,s3
    80004bec:	85ce                	mv	a1,s3
    80004bee:	855a                	mv	a0,s6
    80004bf0:	f74fc0ef          	jal	80001364 <uvmalloc>
    80004bf4:	8a2a                	mv	s4,a0
    80004bf6:	e105                	bnez	a0,80004c16 <exec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004bf8:	85ce                	mv	a1,s3
    80004bfa:	855a                	mv	a0,s6
    80004bfc:	e0dfc0ef          	jal	80001a08 <proc_freepagetable>
  return -1;
    80004c00:	557d                	li	a0,-1
    80004c02:	79fe                	ld	s3,504(sp)
    80004c04:	7a5e                	ld	s4,496(sp)
    80004c06:	7abe                	ld	s5,488(sp)
    80004c08:	7b1e                	ld	s6,480(sp)
    80004c0a:	6bfe                	ld	s7,472(sp)
    80004c0c:	6c5e                	ld	s8,464(sp)
    80004c0e:	6cbe                	ld	s9,456(sp)
    80004c10:	6d1e                	ld	s10,448(sp)
    80004c12:	7dfa                	ld	s11,440(sp)
    80004c14:	b541                	j	80004a94 <exec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004c16:	75f9                	lui	a1,0xffffe
    80004c18:	95aa                	add	a1,a1,a0
    80004c1a:	855a                	mv	a0,s6
    80004c1c:	93ffc0ef          	jal	8000155a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004c20:	7bfd                	lui	s7,0xfffff
    80004c22:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    80004c24:	e0043783          	ld	a5,-512(s0)
    80004c28:	6388                	ld	a0,0(a5)
  sp = sz;
    80004c2a:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004c2c:	4481                	li	s1,0
    ustack[argc] = sp;
    80004c2e:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004c32:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004c36:	cd21                	beqz	a0,80004c8e <exec+0x26c>
    sp -= strlen(argv[argc]) + 1;
    80004c38:	a1efc0ef          	jal	80000e56 <strlen>
    80004c3c:	0015079b          	addiw	a5,a0,1
    80004c40:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c44:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004c48:	13796563          	bltu	s2,s7,80004d72 <exec+0x350>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c4c:	e0043d83          	ld	s11,-512(s0)
    80004c50:	000db983          	ld	s3,0(s11)
    80004c54:	854e                	mv	a0,s3
    80004c56:	a00fc0ef          	jal	80000e56 <strlen>
    80004c5a:	0015069b          	addiw	a3,a0,1
    80004c5e:	864e                	mv	a2,s3
    80004c60:	85ca                	mv	a1,s2
    80004c62:	855a                	mv	a0,s6
    80004c64:	921fc0ef          	jal	80001584 <copyout>
    80004c68:	10054763          	bltz	a0,80004d76 <exec+0x354>
    ustack[argc] = sp;
    80004c6c:	00349793          	slli	a5,s1,0x3
    80004c70:	97e6                	add	a5,a5,s9
    80004c72:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd4620>
  for(argc = 0; argv[argc]; argc++) {
    80004c76:	0485                	addi	s1,s1,1
    80004c78:	008d8793          	addi	a5,s11,8
    80004c7c:	e0f43023          	sd	a5,-512(s0)
    80004c80:	008db503          	ld	a0,8(s11)
    80004c84:	c509                	beqz	a0,80004c8e <exec+0x26c>
    if(argc >= MAXARG)
    80004c86:	fb8499e3          	bne	s1,s8,80004c38 <exec+0x216>
  sz = sz1;
    80004c8a:	89d2                	mv	s3,s4
    80004c8c:	b7b5                	j	80004bf8 <exec+0x1d6>
  ustack[argc] = 0;
    80004c8e:	00349793          	slli	a5,s1,0x3
    80004c92:	f9078793          	addi	a5,a5,-112
    80004c96:	97a2                	add	a5,a5,s0
    80004c98:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004c9c:	00148693          	addi	a3,s1,1
    80004ca0:	068e                	slli	a3,a3,0x3
    80004ca2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ca6:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004caa:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004cac:	f57966e3          	bltu	s2,s7,80004bf8 <exec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004cb0:	e9040613          	addi	a2,s0,-368
    80004cb4:	85ca                	mv	a1,s2
    80004cb6:	855a                	mv	a0,s6
    80004cb8:	8cdfc0ef          	jal	80001584 <copyout>
    80004cbc:	f2054ee3          	bltz	a0,80004bf8 <exec+0x1d6>
  p->trapframe->a1 = sp;
    80004cc0:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004cc4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004cc8:	df043783          	ld	a5,-528(s0)
    80004ccc:	0007c703          	lbu	a4,0(a5)
    80004cd0:	cf11                	beqz	a4,80004cec <exec+0x2ca>
    80004cd2:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004cd4:	02f00693          	li	a3,47
    80004cd8:	a029                	j	80004ce2 <exec+0x2c0>
  for(last=s=path; *s; s++)
    80004cda:	0785                	addi	a5,a5,1
    80004cdc:	fff7c703          	lbu	a4,-1(a5)
    80004ce0:	c711                	beqz	a4,80004cec <exec+0x2ca>
    if(*s == '/')
    80004ce2:	fed71ce3          	bne	a4,a3,80004cda <exec+0x2b8>
      last = s+1;
    80004ce6:	def43823          	sd	a5,-528(s0)
    80004cea:	bfc5                	j	80004cda <exec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    80004cec:	4641                	li	a2,16
    80004cee:	df043583          	ld	a1,-528(s0)
    80004cf2:	158a8513          	addi	a0,s5,344
    80004cf6:	92afc0ef          	jal	80000e20 <safestrcpy>
  oldpagetable = p->pagetable;
    80004cfa:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004cfe:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004d02:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004d06:	058ab783          	ld	a5,88(s5)
    80004d0a:	e6843703          	ld	a4,-408(s0)
    80004d0e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004d10:	058ab783          	ld	a5,88(s5)
    80004d14:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004d18:	85ea                	mv	a1,s10
    80004d1a:	ceffc0ef          	jal	80001a08 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004d1e:	0004851b          	sext.w	a0,s1
    80004d22:	79fe                	ld	s3,504(sp)
    80004d24:	7a5e                	ld	s4,496(sp)
    80004d26:	7abe                	ld	s5,488(sp)
    80004d28:	7b1e                	ld	s6,480(sp)
    80004d2a:	6bfe                	ld	s7,472(sp)
    80004d2c:	6c5e                	ld	s8,464(sp)
    80004d2e:	6cbe                	ld	s9,456(sp)
    80004d30:	6d1e                	ld	s10,448(sp)
    80004d32:	7dfa                	ld	s11,440(sp)
    80004d34:	b385                	j	80004a94 <exec+0x72>
    80004d36:	7b1e                	ld	s6,480(sp)
    80004d38:	b3b9                	j	80004a86 <exec+0x64>
    80004d3a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004d3e:	df843583          	ld	a1,-520(s0)
    80004d42:	855a                	mv	a0,s6
    80004d44:	cc5fc0ef          	jal	80001a08 <proc_freepagetable>
  if(ip){
    80004d48:	79fe                	ld	s3,504(sp)
    80004d4a:	7abe                	ld	s5,488(sp)
    80004d4c:	7b1e                	ld	s6,480(sp)
    80004d4e:	6bfe                	ld	s7,472(sp)
    80004d50:	6c5e                	ld	s8,464(sp)
    80004d52:	6cbe                	ld	s9,456(sp)
    80004d54:	6d1e                	ld	s10,448(sp)
    80004d56:	7dfa                	ld	s11,440(sp)
    80004d58:	b33d                	j	80004a86 <exec+0x64>
    80004d5a:	df243c23          	sd	s2,-520(s0)
    80004d5e:	b7c5                	j	80004d3e <exec+0x31c>
    80004d60:	df243c23          	sd	s2,-520(s0)
    80004d64:	bfe9                	j	80004d3e <exec+0x31c>
    80004d66:	df243c23          	sd	s2,-520(s0)
    80004d6a:	bfd1                	j	80004d3e <exec+0x31c>
    80004d6c:	df243c23          	sd	s2,-520(s0)
    80004d70:	b7f9                	j	80004d3e <exec+0x31c>
  sz = sz1;
    80004d72:	89d2                	mv	s3,s4
    80004d74:	b551                	j	80004bf8 <exec+0x1d6>
    80004d76:	89d2                	mv	s3,s4
    80004d78:	b541                	j	80004bf8 <exec+0x1d6>

0000000080004d7a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d7a:	7179                	addi	sp,sp,-48
    80004d7c:	f406                	sd	ra,40(sp)
    80004d7e:	f022                	sd	s0,32(sp)
    80004d80:	ec26                	sd	s1,24(sp)
    80004d82:	e84a                	sd	s2,16(sp)
    80004d84:	1800                	addi	s0,sp,48
    80004d86:	892e                	mv	s2,a1
    80004d88:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d8a:	fdc40593          	addi	a1,s0,-36
    80004d8e:	d85fd0ef          	jal	80002b12 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004d92:	fdc42703          	lw	a4,-36(s0)
    80004d96:	47bd                	li	a5,15
    80004d98:	02e7e963          	bltu	a5,a4,80004dca <argfd+0x50>
    80004d9c:	b41fc0ef          	jal	800018dc <myproc>
    80004da0:	fdc42703          	lw	a4,-36(s0)
    80004da4:	01a70793          	addi	a5,a4,26
    80004da8:	078e                	slli	a5,a5,0x3
    80004daa:	953e                	add	a0,a0,a5
    80004dac:	611c                	ld	a5,0(a0)
    80004dae:	c385                	beqz	a5,80004dce <argfd+0x54>
    return -1;
  if(pfd)
    80004db0:	00090463          	beqz	s2,80004db8 <argfd+0x3e>
    *pfd = fd;
    80004db4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004db8:	4501                	li	a0,0
  if(pf)
    80004dba:	c091                	beqz	s1,80004dbe <argfd+0x44>
    *pf = f;
    80004dbc:	e09c                	sd	a5,0(s1)
}
    80004dbe:	70a2                	ld	ra,40(sp)
    80004dc0:	7402                	ld	s0,32(sp)
    80004dc2:	64e2                	ld	s1,24(sp)
    80004dc4:	6942                	ld	s2,16(sp)
    80004dc6:	6145                	addi	sp,sp,48
    80004dc8:	8082                	ret
    return -1;
    80004dca:	557d                	li	a0,-1
    80004dcc:	bfcd                	j	80004dbe <argfd+0x44>
    80004dce:	557d                	li	a0,-1
    80004dd0:	b7fd                	j	80004dbe <argfd+0x44>

0000000080004dd2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004dd2:	1101                	addi	sp,sp,-32
    80004dd4:	ec06                	sd	ra,24(sp)
    80004dd6:	e822                	sd	s0,16(sp)
    80004dd8:	e426                	sd	s1,8(sp)
    80004dda:	1000                	addi	s0,sp,32
    80004ddc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004dde:	afffc0ef          	jal	800018dc <myproc>
    80004de2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004de4:	0d050793          	addi	a5,a0,208
    80004de8:	4501                	li	a0,0
    80004dea:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004dec:	6398                	ld	a4,0(a5)
    80004dee:	cb19                	beqz	a4,80004e04 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004df0:	2505                	addiw	a0,a0,1
    80004df2:	07a1                	addi	a5,a5,8
    80004df4:	fed51ce3          	bne	a0,a3,80004dec <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004df8:	557d                	li	a0,-1
}
    80004dfa:	60e2                	ld	ra,24(sp)
    80004dfc:	6442                	ld	s0,16(sp)
    80004dfe:	64a2                	ld	s1,8(sp)
    80004e00:	6105                	addi	sp,sp,32
    80004e02:	8082                	ret
      p->ofile[fd] = f;
    80004e04:	01a50793          	addi	a5,a0,26
    80004e08:	078e                	slli	a5,a5,0x3
    80004e0a:	963e                	add	a2,a2,a5
    80004e0c:	e204                	sd	s1,0(a2)
      return fd;
    80004e0e:	b7f5                	j	80004dfa <fdalloc+0x28>

0000000080004e10 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004e10:	715d                	addi	sp,sp,-80
    80004e12:	e486                	sd	ra,72(sp)
    80004e14:	e0a2                	sd	s0,64(sp)
    80004e16:	fc26                	sd	s1,56(sp)
    80004e18:	f84a                	sd	s2,48(sp)
    80004e1a:	f44e                	sd	s3,40(sp)
    80004e1c:	ec56                	sd	s5,24(sp)
    80004e1e:	e85a                	sd	s6,16(sp)
    80004e20:	0880                	addi	s0,sp,80
    80004e22:	8b2e                	mv	s6,a1
    80004e24:	89b2                	mv	s3,a2
    80004e26:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004e28:	fb040593          	addi	a1,s0,-80
    80004e2c:	ffdfe0ef          	jal	80003e28 <nameiparent>
    80004e30:	84aa                	mv	s1,a0
    80004e32:	10050a63          	beqz	a0,80004f46 <create+0x136>
    return 0;

  ilock(dp);
    80004e36:	8e9fe0ef          	jal	8000371e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004e3a:	4601                	li	a2,0
    80004e3c:	fb040593          	addi	a1,s0,-80
    80004e40:	8526                	mv	a0,s1
    80004e42:	d41fe0ef          	jal	80003b82 <dirlookup>
    80004e46:	8aaa                	mv	s5,a0
    80004e48:	c129                	beqz	a0,80004e8a <create+0x7a>
    iunlockput(dp);
    80004e4a:	8526                	mv	a0,s1
    80004e4c:	addfe0ef          	jal	80003928 <iunlockput>
    ilock(ip);
    80004e50:	8556                	mv	a0,s5
    80004e52:	8cdfe0ef          	jal	8000371e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e56:	4789                	li	a5,2
    80004e58:	02fb1463          	bne	s6,a5,80004e80 <create+0x70>
    80004e5c:	044ad783          	lhu	a5,68(s5)
    80004e60:	37f9                	addiw	a5,a5,-2
    80004e62:	17c2                	slli	a5,a5,0x30
    80004e64:	93c1                	srli	a5,a5,0x30
    80004e66:	4705                	li	a4,1
    80004e68:	00f76c63          	bltu	a4,a5,80004e80 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e6c:	8556                	mv	a0,s5
    80004e6e:	60a6                	ld	ra,72(sp)
    80004e70:	6406                	ld	s0,64(sp)
    80004e72:	74e2                	ld	s1,56(sp)
    80004e74:	7942                	ld	s2,48(sp)
    80004e76:	79a2                	ld	s3,40(sp)
    80004e78:	6ae2                	ld	s5,24(sp)
    80004e7a:	6b42                	ld	s6,16(sp)
    80004e7c:	6161                	addi	sp,sp,80
    80004e7e:	8082                	ret
    iunlockput(ip);
    80004e80:	8556                	mv	a0,s5
    80004e82:	aa7fe0ef          	jal	80003928 <iunlockput>
    return 0;
    80004e86:	4a81                	li	s5,0
    80004e88:	b7d5                	j	80004e6c <create+0x5c>
    80004e8a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004e8c:	85da                	mv	a1,s6
    80004e8e:	4088                	lw	a0,0(s1)
    80004e90:	f1efe0ef          	jal	800035ae <ialloc>
    80004e94:	8a2a                	mv	s4,a0
    80004e96:	cd15                	beqz	a0,80004ed2 <create+0xc2>
  ilock(ip);
    80004e98:	887fe0ef          	jal	8000371e <ilock>
  ip->major = major;
    80004e9c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004ea0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004ea4:	4905                	li	s2,1
    80004ea6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004eaa:	8552                	mv	a0,s4
    80004eac:	fbefe0ef          	jal	8000366a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004eb0:	032b0763          	beq	s6,s2,80004ede <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004eb4:	004a2603          	lw	a2,4(s4)
    80004eb8:	fb040593          	addi	a1,s0,-80
    80004ebc:	8526                	mv	a0,s1
    80004ebe:	ea7fe0ef          	jal	80003d64 <dirlink>
    80004ec2:	06054563          	bltz	a0,80004f2c <create+0x11c>
  iunlockput(dp);
    80004ec6:	8526                	mv	a0,s1
    80004ec8:	a61fe0ef          	jal	80003928 <iunlockput>
  return ip;
    80004ecc:	8ad2                	mv	s5,s4
    80004ece:	7a02                	ld	s4,32(sp)
    80004ed0:	bf71                	j	80004e6c <create+0x5c>
    iunlockput(dp);
    80004ed2:	8526                	mv	a0,s1
    80004ed4:	a55fe0ef          	jal	80003928 <iunlockput>
    return 0;
    80004ed8:	8ad2                	mv	s5,s4
    80004eda:	7a02                	ld	s4,32(sp)
    80004edc:	bf41                	j	80004e6c <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ede:	004a2603          	lw	a2,4(s4)
    80004ee2:	00002597          	auipc	a1,0x2
    80004ee6:	7fe58593          	addi	a1,a1,2046 # 800076e0 <etext+0x6e0>
    80004eea:	8552                	mv	a0,s4
    80004eec:	e79fe0ef          	jal	80003d64 <dirlink>
    80004ef0:	02054e63          	bltz	a0,80004f2c <create+0x11c>
    80004ef4:	40d0                	lw	a2,4(s1)
    80004ef6:	00002597          	auipc	a1,0x2
    80004efa:	7f258593          	addi	a1,a1,2034 # 800076e8 <etext+0x6e8>
    80004efe:	8552                	mv	a0,s4
    80004f00:	e65fe0ef          	jal	80003d64 <dirlink>
    80004f04:	02054463          	bltz	a0,80004f2c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004f08:	004a2603          	lw	a2,4(s4)
    80004f0c:	fb040593          	addi	a1,s0,-80
    80004f10:	8526                	mv	a0,s1
    80004f12:	e53fe0ef          	jal	80003d64 <dirlink>
    80004f16:	00054b63          	bltz	a0,80004f2c <create+0x11c>
    dp->nlink++;  // for ".."
    80004f1a:	04a4d783          	lhu	a5,74(s1)
    80004f1e:	2785                	addiw	a5,a5,1
    80004f20:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f24:	8526                	mv	a0,s1
    80004f26:	f44fe0ef          	jal	8000366a <iupdate>
    80004f2a:	bf71                	j	80004ec6 <create+0xb6>
  ip->nlink = 0;
    80004f2c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004f30:	8552                	mv	a0,s4
    80004f32:	f38fe0ef          	jal	8000366a <iupdate>
  iunlockput(ip);
    80004f36:	8552                	mv	a0,s4
    80004f38:	9f1fe0ef          	jal	80003928 <iunlockput>
  iunlockput(dp);
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	9ebfe0ef          	jal	80003928 <iunlockput>
  return 0;
    80004f42:	7a02                	ld	s4,32(sp)
    80004f44:	b725                	j	80004e6c <create+0x5c>
    return 0;
    80004f46:	8aaa                	mv	s5,a0
    80004f48:	b715                	j	80004e6c <create+0x5c>

0000000080004f4a <sys_dup>:
{
    80004f4a:	7179                	addi	sp,sp,-48
    80004f4c:	f406                	sd	ra,40(sp)
    80004f4e:	f022                	sd	s0,32(sp)
    80004f50:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004f52:	fd840613          	addi	a2,s0,-40
    80004f56:	4581                	li	a1,0
    80004f58:	4501                	li	a0,0
    80004f5a:	e21ff0ef          	jal	80004d7a <argfd>
    return -1;
    80004f5e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004f60:	02054363          	bltz	a0,80004f86 <sys_dup+0x3c>
    80004f64:	ec26                	sd	s1,24(sp)
    80004f66:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004f68:	fd843903          	ld	s2,-40(s0)
    80004f6c:	854a                	mv	a0,s2
    80004f6e:	e65ff0ef          	jal	80004dd2 <fdalloc>
    80004f72:	84aa                	mv	s1,a0
    return -1;
    80004f74:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004f76:	00054d63          	bltz	a0,80004f90 <sys_dup+0x46>
  filedup(f);
    80004f7a:	854a                	mv	a0,s2
    80004f7c:	c2eff0ef          	jal	800043aa <filedup>
  return fd;
    80004f80:	87a6                	mv	a5,s1
    80004f82:	64e2                	ld	s1,24(sp)
    80004f84:	6942                	ld	s2,16(sp)
}
    80004f86:	853e                	mv	a0,a5
    80004f88:	70a2                	ld	ra,40(sp)
    80004f8a:	7402                	ld	s0,32(sp)
    80004f8c:	6145                	addi	sp,sp,48
    80004f8e:	8082                	ret
    80004f90:	64e2                	ld	s1,24(sp)
    80004f92:	6942                	ld	s2,16(sp)
    80004f94:	bfcd                	j	80004f86 <sys_dup+0x3c>

0000000080004f96 <sys_read>:
{
    80004f96:	7179                	addi	sp,sp,-48
    80004f98:	f406                	sd	ra,40(sp)
    80004f9a:	f022                	sd	s0,32(sp)
    80004f9c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f9e:	fd840593          	addi	a1,s0,-40
    80004fa2:	4505                	li	a0,1
    80004fa4:	b8bfd0ef          	jal	80002b2e <argaddr>
  argint(2, &n);
    80004fa8:	fe440593          	addi	a1,s0,-28
    80004fac:	4509                	li	a0,2
    80004fae:	b65fd0ef          	jal	80002b12 <argint>
  if(argfd(0, 0, &f) < 0)
    80004fb2:	fe840613          	addi	a2,s0,-24
    80004fb6:	4581                	li	a1,0
    80004fb8:	4501                	li	a0,0
    80004fba:	dc1ff0ef          	jal	80004d7a <argfd>
    80004fbe:	87aa                	mv	a5,a0
    return -1;
    80004fc0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fc2:	0007ca63          	bltz	a5,80004fd6 <sys_read+0x40>
  return fileread(f, p, n);
    80004fc6:	fe442603          	lw	a2,-28(s0)
    80004fca:	fd843583          	ld	a1,-40(s0)
    80004fce:	fe843503          	ld	a0,-24(s0)
    80004fd2:	d3eff0ef          	jal	80004510 <fileread>
}
    80004fd6:	70a2                	ld	ra,40(sp)
    80004fd8:	7402                	ld	s0,32(sp)
    80004fda:	6145                	addi	sp,sp,48
    80004fdc:	8082                	ret

0000000080004fde <sys_write>:
{
    80004fde:	7179                	addi	sp,sp,-48
    80004fe0:	f406                	sd	ra,40(sp)
    80004fe2:	f022                	sd	s0,32(sp)
    80004fe4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fe6:	fd840593          	addi	a1,s0,-40
    80004fea:	4505                	li	a0,1
    80004fec:	b43fd0ef          	jal	80002b2e <argaddr>
  argint(2, &n);
    80004ff0:	fe440593          	addi	a1,s0,-28
    80004ff4:	4509                	li	a0,2
    80004ff6:	b1dfd0ef          	jal	80002b12 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ffa:	fe840613          	addi	a2,s0,-24
    80004ffe:	4581                	li	a1,0
    80005000:	4501                	li	a0,0
    80005002:	d79ff0ef          	jal	80004d7a <argfd>
    80005006:	87aa                	mv	a5,a0
    return -1;
    80005008:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000500a:	0007ca63          	bltz	a5,8000501e <sys_write+0x40>
  return filewrite(f, p, n);
    8000500e:	fe442603          	lw	a2,-28(s0)
    80005012:	fd843583          	ld	a1,-40(s0)
    80005016:	fe843503          	ld	a0,-24(s0)
    8000501a:	db4ff0ef          	jal	800045ce <filewrite>
}
    8000501e:	70a2                	ld	ra,40(sp)
    80005020:	7402                	ld	s0,32(sp)
    80005022:	6145                	addi	sp,sp,48
    80005024:	8082                	ret

0000000080005026 <sys_close>:
{
    80005026:	1101                	addi	sp,sp,-32
    80005028:	ec06                	sd	ra,24(sp)
    8000502a:	e822                	sd	s0,16(sp)
    8000502c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000502e:	fe040613          	addi	a2,s0,-32
    80005032:	fec40593          	addi	a1,s0,-20
    80005036:	4501                	li	a0,0
    80005038:	d43ff0ef          	jal	80004d7a <argfd>
    return -1;
    8000503c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000503e:	02054063          	bltz	a0,8000505e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005042:	89bfc0ef          	jal	800018dc <myproc>
    80005046:	fec42783          	lw	a5,-20(s0)
    8000504a:	07e9                	addi	a5,a5,26
    8000504c:	078e                	slli	a5,a5,0x3
    8000504e:	953e                	add	a0,a0,a5
    80005050:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005054:	fe043503          	ld	a0,-32(s0)
    80005058:	b98ff0ef          	jal	800043f0 <fileclose>
  return 0;
    8000505c:	4781                	li	a5,0
}
    8000505e:	853e                	mv	a0,a5
    80005060:	60e2                	ld	ra,24(sp)
    80005062:	6442                	ld	s0,16(sp)
    80005064:	6105                	addi	sp,sp,32
    80005066:	8082                	ret

0000000080005068 <sys_fstat>:
{
    80005068:	1101                	addi	sp,sp,-32
    8000506a:	ec06                	sd	ra,24(sp)
    8000506c:	e822                	sd	s0,16(sp)
    8000506e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005070:	fe040593          	addi	a1,s0,-32
    80005074:	4505                	li	a0,1
    80005076:	ab9fd0ef          	jal	80002b2e <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000507a:	fe840613          	addi	a2,s0,-24
    8000507e:	4581                	li	a1,0
    80005080:	4501                	li	a0,0
    80005082:	cf9ff0ef          	jal	80004d7a <argfd>
    80005086:	87aa                	mv	a5,a0
    return -1;
    80005088:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000508a:	0007c863          	bltz	a5,8000509a <sys_fstat+0x32>
  return filestat(f, st);
    8000508e:	fe043583          	ld	a1,-32(s0)
    80005092:	fe843503          	ld	a0,-24(s0)
    80005096:	c18ff0ef          	jal	800044ae <filestat>
}
    8000509a:	60e2                	ld	ra,24(sp)
    8000509c:	6442                	ld	s0,16(sp)
    8000509e:	6105                	addi	sp,sp,32
    800050a0:	8082                	ret

00000000800050a2 <sys_link>:
{
    800050a2:	7169                	addi	sp,sp,-304
    800050a4:	f606                	sd	ra,296(sp)
    800050a6:	f222                	sd	s0,288(sp)
    800050a8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050aa:	08000613          	li	a2,128
    800050ae:	ed040593          	addi	a1,s0,-304
    800050b2:	4501                	li	a0,0
    800050b4:	a97fd0ef          	jal	80002b4a <argstr>
    return -1;
    800050b8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050ba:	0c054e63          	bltz	a0,80005196 <sys_link+0xf4>
    800050be:	08000613          	li	a2,128
    800050c2:	f5040593          	addi	a1,s0,-176
    800050c6:	4505                	li	a0,1
    800050c8:	a83fd0ef          	jal	80002b4a <argstr>
    return -1;
    800050cc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050ce:	0c054463          	bltz	a0,80005196 <sys_link+0xf4>
    800050d2:	ee26                	sd	s1,280(sp)
  begin_op();
    800050d4:	efdfe0ef          	jal	80003fd0 <begin_op>
  if((ip = namei(old)) == 0){
    800050d8:	ed040513          	addi	a0,s0,-304
    800050dc:	d33fe0ef          	jal	80003e0e <namei>
    800050e0:	84aa                	mv	s1,a0
    800050e2:	c53d                	beqz	a0,80005150 <sys_link+0xae>
  ilock(ip);
    800050e4:	e3afe0ef          	jal	8000371e <ilock>
  if(ip->type == T_DIR){
    800050e8:	04449703          	lh	a4,68(s1)
    800050ec:	4785                	li	a5,1
    800050ee:	06f70663          	beq	a4,a5,8000515a <sys_link+0xb8>
    800050f2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800050f4:	04a4d783          	lhu	a5,74(s1)
    800050f8:	2785                	addiw	a5,a5,1
    800050fa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050fe:	8526                	mv	a0,s1
    80005100:	d6afe0ef          	jal	8000366a <iupdate>
  iunlock(ip);
    80005104:	8526                	mv	a0,s1
    80005106:	ec6fe0ef          	jal	800037cc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000510a:	fd040593          	addi	a1,s0,-48
    8000510e:	f5040513          	addi	a0,s0,-176
    80005112:	d17fe0ef          	jal	80003e28 <nameiparent>
    80005116:	892a                	mv	s2,a0
    80005118:	cd21                	beqz	a0,80005170 <sys_link+0xce>
  ilock(dp);
    8000511a:	e04fe0ef          	jal	8000371e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000511e:	00092703          	lw	a4,0(s2)
    80005122:	409c                	lw	a5,0(s1)
    80005124:	04f71363          	bne	a4,a5,8000516a <sys_link+0xc8>
    80005128:	40d0                	lw	a2,4(s1)
    8000512a:	fd040593          	addi	a1,s0,-48
    8000512e:	854a                	mv	a0,s2
    80005130:	c35fe0ef          	jal	80003d64 <dirlink>
    80005134:	02054b63          	bltz	a0,8000516a <sys_link+0xc8>
  iunlockput(dp);
    80005138:	854a                	mv	a0,s2
    8000513a:	feefe0ef          	jal	80003928 <iunlockput>
  iput(ip);
    8000513e:	8526                	mv	a0,s1
    80005140:	f60fe0ef          	jal	800038a0 <iput>
  end_op();
    80005144:	ef7fe0ef          	jal	8000403a <end_op>
  return 0;
    80005148:	4781                	li	a5,0
    8000514a:	64f2                	ld	s1,280(sp)
    8000514c:	6952                	ld	s2,272(sp)
    8000514e:	a0a1                	j	80005196 <sys_link+0xf4>
    end_op();
    80005150:	eebfe0ef          	jal	8000403a <end_op>
    return -1;
    80005154:	57fd                	li	a5,-1
    80005156:	64f2                	ld	s1,280(sp)
    80005158:	a83d                	j	80005196 <sys_link+0xf4>
    iunlockput(ip);
    8000515a:	8526                	mv	a0,s1
    8000515c:	fccfe0ef          	jal	80003928 <iunlockput>
    end_op();
    80005160:	edbfe0ef          	jal	8000403a <end_op>
    return -1;
    80005164:	57fd                	li	a5,-1
    80005166:	64f2                	ld	s1,280(sp)
    80005168:	a03d                	j	80005196 <sys_link+0xf4>
    iunlockput(dp);
    8000516a:	854a                	mv	a0,s2
    8000516c:	fbcfe0ef          	jal	80003928 <iunlockput>
  ilock(ip);
    80005170:	8526                	mv	a0,s1
    80005172:	dacfe0ef          	jal	8000371e <ilock>
  ip->nlink--;
    80005176:	04a4d783          	lhu	a5,74(s1)
    8000517a:	37fd                	addiw	a5,a5,-1
    8000517c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005180:	8526                	mv	a0,s1
    80005182:	ce8fe0ef          	jal	8000366a <iupdate>
  iunlockput(ip);
    80005186:	8526                	mv	a0,s1
    80005188:	fa0fe0ef          	jal	80003928 <iunlockput>
  end_op();
    8000518c:	eaffe0ef          	jal	8000403a <end_op>
  return -1;
    80005190:	57fd                	li	a5,-1
    80005192:	64f2                	ld	s1,280(sp)
    80005194:	6952                	ld	s2,272(sp)
}
    80005196:	853e                	mv	a0,a5
    80005198:	70b2                	ld	ra,296(sp)
    8000519a:	7412                	ld	s0,288(sp)
    8000519c:	6155                	addi	sp,sp,304
    8000519e:	8082                	ret

00000000800051a0 <sys_unlink>:
{
    800051a0:	7111                	addi	sp,sp,-256
    800051a2:	fd86                	sd	ra,248(sp)
    800051a4:	f9a2                	sd	s0,240(sp)
    800051a6:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    800051a8:	08000613          	li	a2,128
    800051ac:	f2040593          	addi	a1,s0,-224
    800051b0:	4501                	li	a0,0
    800051b2:	999fd0ef          	jal	80002b4a <argstr>
    800051b6:	16054663          	bltz	a0,80005322 <sys_unlink+0x182>
    800051ba:	f5a6                	sd	s1,232(sp)
  begin_op();
    800051bc:	e15fe0ef          	jal	80003fd0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800051c0:	fa040593          	addi	a1,s0,-96
    800051c4:	f2040513          	addi	a0,s0,-224
    800051c8:	c61fe0ef          	jal	80003e28 <nameiparent>
    800051cc:	84aa                	mv	s1,a0
    800051ce:	c955                	beqz	a0,80005282 <sys_unlink+0xe2>
  ilock(dp);
    800051d0:	d4efe0ef          	jal	8000371e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800051d4:	00002597          	auipc	a1,0x2
    800051d8:	50c58593          	addi	a1,a1,1292 # 800076e0 <etext+0x6e0>
    800051dc:	fa040513          	addi	a0,s0,-96
    800051e0:	98dfe0ef          	jal	80003b6c <namecmp>
    800051e4:	12050463          	beqz	a0,8000530c <sys_unlink+0x16c>
    800051e8:	00002597          	auipc	a1,0x2
    800051ec:	50058593          	addi	a1,a1,1280 # 800076e8 <etext+0x6e8>
    800051f0:	fa040513          	addi	a0,s0,-96
    800051f4:	979fe0ef          	jal	80003b6c <namecmp>
    800051f8:	10050a63          	beqz	a0,8000530c <sys_unlink+0x16c>
    800051fc:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800051fe:	f1c40613          	addi	a2,s0,-228
    80005202:	fa040593          	addi	a1,s0,-96
    80005206:	8526                	mv	a0,s1
    80005208:	97bfe0ef          	jal	80003b82 <dirlookup>
    8000520c:	892a                	mv	s2,a0
    8000520e:	0e050e63          	beqz	a0,8000530a <sys_unlink+0x16a>
    80005212:	edce                	sd	s3,216(sp)
  ilock(ip);
    80005214:	d0afe0ef          	jal	8000371e <ilock>
  if(ip->nlink < 1)
    80005218:	04a91783          	lh	a5,74(s2)
    8000521c:	06f05863          	blez	a5,8000528c <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005220:	04491703          	lh	a4,68(s2)
    80005224:	4785                	li	a5,1
    80005226:	06f70b63          	beq	a4,a5,8000529c <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    8000522a:	fb040993          	addi	s3,s0,-80
    8000522e:	4641                	li	a2,16
    80005230:	4581                	li	a1,0
    80005232:	854e                	mv	a0,s3
    80005234:	a9bfb0ef          	jal	80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005238:	4741                	li	a4,16
    8000523a:	f1c42683          	lw	a3,-228(s0)
    8000523e:	864e                	mv	a2,s3
    80005240:	4581                	li	a1,0
    80005242:	8526                	mv	a0,s1
    80005244:	825fe0ef          	jal	80003a68 <writei>
    80005248:	47c1                	li	a5,16
    8000524a:	08f51f63          	bne	a0,a5,800052e8 <sys_unlink+0x148>
  if(ip->type == T_DIR){
    8000524e:	04491703          	lh	a4,68(s2)
    80005252:	4785                	li	a5,1
    80005254:	0af70263          	beq	a4,a5,800052f8 <sys_unlink+0x158>
  iunlockput(dp);
    80005258:	8526                	mv	a0,s1
    8000525a:	ecefe0ef          	jal	80003928 <iunlockput>
  ip->nlink--;
    8000525e:	04a95783          	lhu	a5,74(s2)
    80005262:	37fd                	addiw	a5,a5,-1
    80005264:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005268:	854a                	mv	a0,s2
    8000526a:	c00fe0ef          	jal	8000366a <iupdate>
  iunlockput(ip);
    8000526e:	854a                	mv	a0,s2
    80005270:	eb8fe0ef          	jal	80003928 <iunlockput>
  end_op();
    80005274:	dc7fe0ef          	jal	8000403a <end_op>
  return 0;
    80005278:	4501                	li	a0,0
    8000527a:	74ae                	ld	s1,232(sp)
    8000527c:	790e                	ld	s2,224(sp)
    8000527e:	69ee                	ld	s3,216(sp)
    80005280:	a869                	j	8000531a <sys_unlink+0x17a>
    end_op();
    80005282:	db9fe0ef          	jal	8000403a <end_op>
    return -1;
    80005286:	557d                	li	a0,-1
    80005288:	74ae                	ld	s1,232(sp)
    8000528a:	a841                	j	8000531a <sys_unlink+0x17a>
    8000528c:	e9d2                	sd	s4,208(sp)
    8000528e:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80005290:	00002517          	auipc	a0,0x2
    80005294:	46050513          	addi	a0,a0,1120 # 800076f0 <etext+0x6f0>
    80005298:	d06fb0ef          	jal	8000079e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000529c:	04c92703          	lw	a4,76(s2)
    800052a0:	02000793          	li	a5,32
    800052a4:	f8e7f3e3          	bgeu	a5,a4,8000522a <sys_unlink+0x8a>
    800052a8:	e9d2                	sd	s4,208(sp)
    800052aa:	e5d6                	sd	s5,200(sp)
    800052ac:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052ae:	f0840a93          	addi	s5,s0,-248
    800052b2:	4a41                	li	s4,16
    800052b4:	8752                	mv	a4,s4
    800052b6:	86ce                	mv	a3,s3
    800052b8:	8656                	mv	a2,s5
    800052ba:	4581                	li	a1,0
    800052bc:	854a                	mv	a0,s2
    800052be:	eb8fe0ef          	jal	80003976 <readi>
    800052c2:	01451d63          	bne	a0,s4,800052dc <sys_unlink+0x13c>
    if(de.inum != 0)
    800052c6:	f0845783          	lhu	a5,-248(s0)
    800052ca:	efb1                	bnez	a5,80005326 <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800052cc:	29c1                	addiw	s3,s3,16
    800052ce:	04c92783          	lw	a5,76(s2)
    800052d2:	fef9e1e3          	bltu	s3,a5,800052b4 <sys_unlink+0x114>
    800052d6:	6a4e                	ld	s4,208(sp)
    800052d8:	6aae                	ld	s5,200(sp)
    800052da:	bf81                	j	8000522a <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800052dc:	00002517          	auipc	a0,0x2
    800052e0:	42c50513          	addi	a0,a0,1068 # 80007708 <etext+0x708>
    800052e4:	cbafb0ef          	jal	8000079e <panic>
    800052e8:	e9d2                	sd	s4,208(sp)
    800052ea:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    800052ec:	00002517          	auipc	a0,0x2
    800052f0:	43450513          	addi	a0,a0,1076 # 80007720 <etext+0x720>
    800052f4:	caafb0ef          	jal	8000079e <panic>
    dp->nlink--;
    800052f8:	04a4d783          	lhu	a5,74(s1)
    800052fc:	37fd                	addiw	a5,a5,-1
    800052fe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005302:	8526                	mv	a0,s1
    80005304:	b66fe0ef          	jal	8000366a <iupdate>
    80005308:	bf81                	j	80005258 <sys_unlink+0xb8>
    8000530a:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    8000530c:	8526                	mv	a0,s1
    8000530e:	e1afe0ef          	jal	80003928 <iunlockput>
  end_op();
    80005312:	d29fe0ef          	jal	8000403a <end_op>
  return -1;
    80005316:	557d                	li	a0,-1
    80005318:	74ae                	ld	s1,232(sp)
}
    8000531a:	70ee                	ld	ra,248(sp)
    8000531c:	744e                	ld	s0,240(sp)
    8000531e:	6111                	addi	sp,sp,256
    80005320:	8082                	ret
    return -1;
    80005322:	557d                	li	a0,-1
    80005324:	bfdd                	j	8000531a <sys_unlink+0x17a>
    iunlockput(ip);
    80005326:	854a                	mv	a0,s2
    80005328:	e00fe0ef          	jal	80003928 <iunlockput>
    goto bad;
    8000532c:	790e                	ld	s2,224(sp)
    8000532e:	69ee                	ld	s3,216(sp)
    80005330:	6a4e                	ld	s4,208(sp)
    80005332:	6aae                	ld	s5,200(sp)
    80005334:	bfe1                	j	8000530c <sys_unlink+0x16c>

0000000080005336 <sys_open>:

uint64
sys_open(void)
{
    80005336:	7131                	addi	sp,sp,-192
    80005338:	fd06                	sd	ra,184(sp)
    8000533a:	f922                	sd	s0,176(sp)
    8000533c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000533e:	f4c40593          	addi	a1,s0,-180
    80005342:	4505                	li	a0,1
    80005344:	fcefd0ef          	jal	80002b12 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005348:	08000613          	li	a2,128
    8000534c:	f5040593          	addi	a1,s0,-176
    80005350:	4501                	li	a0,0
    80005352:	ff8fd0ef          	jal	80002b4a <argstr>
    80005356:	87aa                	mv	a5,a0
    return -1;
    80005358:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000535a:	0a07c363          	bltz	a5,80005400 <sys_open+0xca>
    8000535e:	f526                	sd	s1,168(sp)

  begin_op();
    80005360:	c71fe0ef          	jal	80003fd0 <begin_op>

  if(omode & O_CREATE){
    80005364:	f4c42783          	lw	a5,-180(s0)
    80005368:	2007f793          	andi	a5,a5,512
    8000536c:	c3dd                	beqz	a5,80005412 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000536e:	4681                	li	a3,0
    80005370:	4601                	li	a2,0
    80005372:	4589                	li	a1,2
    80005374:	f5040513          	addi	a0,s0,-176
    80005378:	a99ff0ef          	jal	80004e10 <create>
    8000537c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000537e:	c549                	beqz	a0,80005408 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005380:	04449703          	lh	a4,68(s1)
    80005384:	478d                	li	a5,3
    80005386:	00f71763          	bne	a4,a5,80005394 <sys_open+0x5e>
    8000538a:	0464d703          	lhu	a4,70(s1)
    8000538e:	47a5                	li	a5,9
    80005390:	0ae7ee63          	bltu	a5,a4,8000544c <sys_open+0x116>
    80005394:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005396:	fb7fe0ef          	jal	8000434c <filealloc>
    8000539a:	892a                	mv	s2,a0
    8000539c:	c561                	beqz	a0,80005464 <sys_open+0x12e>
    8000539e:	ed4e                	sd	s3,152(sp)
    800053a0:	a33ff0ef          	jal	80004dd2 <fdalloc>
    800053a4:	89aa                	mv	s3,a0
    800053a6:	0a054b63          	bltz	a0,8000545c <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800053aa:	04449703          	lh	a4,68(s1)
    800053ae:	478d                	li	a5,3
    800053b0:	0cf70363          	beq	a4,a5,80005476 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800053b4:	4789                	li	a5,2
    800053b6:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800053ba:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800053be:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800053c2:	f4c42783          	lw	a5,-180(s0)
    800053c6:	0017f713          	andi	a4,a5,1
    800053ca:	00174713          	xori	a4,a4,1
    800053ce:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800053d2:	0037f713          	andi	a4,a5,3
    800053d6:	00e03733          	snez	a4,a4
    800053da:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800053de:	4007f793          	andi	a5,a5,1024
    800053e2:	c791                	beqz	a5,800053ee <sys_open+0xb8>
    800053e4:	04449703          	lh	a4,68(s1)
    800053e8:	4789                	li	a5,2
    800053ea:	08f70d63          	beq	a4,a5,80005484 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800053ee:	8526                	mv	a0,s1
    800053f0:	bdcfe0ef          	jal	800037cc <iunlock>
  end_op();
    800053f4:	c47fe0ef          	jal	8000403a <end_op>

  return fd;
    800053f8:	854e                	mv	a0,s3
    800053fa:	74aa                	ld	s1,168(sp)
    800053fc:	790a                	ld	s2,160(sp)
    800053fe:	69ea                	ld	s3,152(sp)
}
    80005400:	70ea                	ld	ra,184(sp)
    80005402:	744a                	ld	s0,176(sp)
    80005404:	6129                	addi	sp,sp,192
    80005406:	8082                	ret
      end_op();
    80005408:	c33fe0ef          	jal	8000403a <end_op>
      return -1;
    8000540c:	557d                	li	a0,-1
    8000540e:	74aa                	ld	s1,168(sp)
    80005410:	bfc5                	j	80005400 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005412:	f5040513          	addi	a0,s0,-176
    80005416:	9f9fe0ef          	jal	80003e0e <namei>
    8000541a:	84aa                	mv	s1,a0
    8000541c:	c11d                	beqz	a0,80005442 <sys_open+0x10c>
    ilock(ip);
    8000541e:	b00fe0ef          	jal	8000371e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005422:	04449703          	lh	a4,68(s1)
    80005426:	4785                	li	a5,1
    80005428:	f4f71ce3          	bne	a4,a5,80005380 <sys_open+0x4a>
    8000542c:	f4c42783          	lw	a5,-180(s0)
    80005430:	d3b5                	beqz	a5,80005394 <sys_open+0x5e>
      iunlockput(ip);
    80005432:	8526                	mv	a0,s1
    80005434:	cf4fe0ef          	jal	80003928 <iunlockput>
      end_op();
    80005438:	c03fe0ef          	jal	8000403a <end_op>
      return -1;
    8000543c:	557d                	li	a0,-1
    8000543e:	74aa                	ld	s1,168(sp)
    80005440:	b7c1                	j	80005400 <sys_open+0xca>
      end_op();
    80005442:	bf9fe0ef          	jal	8000403a <end_op>
      return -1;
    80005446:	557d                	li	a0,-1
    80005448:	74aa                	ld	s1,168(sp)
    8000544a:	bf5d                	j	80005400 <sys_open+0xca>
    iunlockput(ip);
    8000544c:	8526                	mv	a0,s1
    8000544e:	cdafe0ef          	jal	80003928 <iunlockput>
    end_op();
    80005452:	be9fe0ef          	jal	8000403a <end_op>
    return -1;
    80005456:	557d                	li	a0,-1
    80005458:	74aa                	ld	s1,168(sp)
    8000545a:	b75d                	j	80005400 <sys_open+0xca>
      fileclose(f);
    8000545c:	854a                	mv	a0,s2
    8000545e:	f93fe0ef          	jal	800043f0 <fileclose>
    80005462:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005464:	8526                	mv	a0,s1
    80005466:	cc2fe0ef          	jal	80003928 <iunlockput>
    end_op();
    8000546a:	bd1fe0ef          	jal	8000403a <end_op>
    return -1;
    8000546e:	557d                	li	a0,-1
    80005470:	74aa                	ld	s1,168(sp)
    80005472:	790a                	ld	s2,160(sp)
    80005474:	b771                	j	80005400 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005476:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000547a:	04649783          	lh	a5,70(s1)
    8000547e:	02f91223          	sh	a5,36(s2)
    80005482:	bf35                	j	800053be <sys_open+0x88>
    itrunc(ip);
    80005484:	8526                	mv	a0,s1
    80005486:	b86fe0ef          	jal	8000380c <itrunc>
    8000548a:	b795                	j	800053ee <sys_open+0xb8>

000000008000548c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000548c:	7175                	addi	sp,sp,-144
    8000548e:	e506                	sd	ra,136(sp)
    80005490:	e122                	sd	s0,128(sp)
    80005492:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005494:	b3dfe0ef          	jal	80003fd0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005498:	08000613          	li	a2,128
    8000549c:	f7040593          	addi	a1,s0,-144
    800054a0:	4501                	li	a0,0
    800054a2:	ea8fd0ef          	jal	80002b4a <argstr>
    800054a6:	02054363          	bltz	a0,800054cc <sys_mkdir+0x40>
    800054aa:	4681                	li	a3,0
    800054ac:	4601                	li	a2,0
    800054ae:	4585                	li	a1,1
    800054b0:	f7040513          	addi	a0,s0,-144
    800054b4:	95dff0ef          	jal	80004e10 <create>
    800054b8:	c911                	beqz	a0,800054cc <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054ba:	c6efe0ef          	jal	80003928 <iunlockput>
  end_op();
    800054be:	b7dfe0ef          	jal	8000403a <end_op>
  return 0;
    800054c2:	4501                	li	a0,0
}
    800054c4:	60aa                	ld	ra,136(sp)
    800054c6:	640a                	ld	s0,128(sp)
    800054c8:	6149                	addi	sp,sp,144
    800054ca:	8082                	ret
    end_op();
    800054cc:	b6ffe0ef          	jal	8000403a <end_op>
    return -1;
    800054d0:	557d                	li	a0,-1
    800054d2:	bfcd                	j	800054c4 <sys_mkdir+0x38>

00000000800054d4 <sys_mknod>:

uint64
sys_mknod(void)
{
    800054d4:	7135                	addi	sp,sp,-160
    800054d6:	ed06                	sd	ra,152(sp)
    800054d8:	e922                	sd	s0,144(sp)
    800054da:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800054dc:	af5fe0ef          	jal	80003fd0 <begin_op>
  argint(1, &major);
    800054e0:	f6c40593          	addi	a1,s0,-148
    800054e4:	4505                	li	a0,1
    800054e6:	e2cfd0ef          	jal	80002b12 <argint>
  argint(2, &minor);
    800054ea:	f6840593          	addi	a1,s0,-152
    800054ee:	4509                	li	a0,2
    800054f0:	e22fd0ef          	jal	80002b12 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800054f4:	08000613          	li	a2,128
    800054f8:	f7040593          	addi	a1,s0,-144
    800054fc:	4501                	li	a0,0
    800054fe:	e4cfd0ef          	jal	80002b4a <argstr>
    80005502:	02054563          	bltz	a0,8000552c <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005506:	f6841683          	lh	a3,-152(s0)
    8000550a:	f6c41603          	lh	a2,-148(s0)
    8000550e:	458d                	li	a1,3
    80005510:	f7040513          	addi	a0,s0,-144
    80005514:	8fdff0ef          	jal	80004e10 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005518:	c911                	beqz	a0,8000552c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000551a:	c0efe0ef          	jal	80003928 <iunlockput>
  end_op();
    8000551e:	b1dfe0ef          	jal	8000403a <end_op>
  return 0;
    80005522:	4501                	li	a0,0
}
    80005524:	60ea                	ld	ra,152(sp)
    80005526:	644a                	ld	s0,144(sp)
    80005528:	610d                	addi	sp,sp,160
    8000552a:	8082                	ret
    end_op();
    8000552c:	b0ffe0ef          	jal	8000403a <end_op>
    return -1;
    80005530:	557d                	li	a0,-1
    80005532:	bfcd                	j	80005524 <sys_mknod+0x50>

0000000080005534 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005534:	7135                	addi	sp,sp,-160
    80005536:	ed06                	sd	ra,152(sp)
    80005538:	e922                	sd	s0,144(sp)
    8000553a:	e14a                	sd	s2,128(sp)
    8000553c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000553e:	b9efc0ef          	jal	800018dc <myproc>
    80005542:	892a                	mv	s2,a0
  
  begin_op();
    80005544:	a8dfe0ef          	jal	80003fd0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005548:	08000613          	li	a2,128
    8000554c:	f6040593          	addi	a1,s0,-160
    80005550:	4501                	li	a0,0
    80005552:	df8fd0ef          	jal	80002b4a <argstr>
    80005556:	04054363          	bltz	a0,8000559c <sys_chdir+0x68>
    8000555a:	e526                	sd	s1,136(sp)
    8000555c:	f6040513          	addi	a0,s0,-160
    80005560:	8affe0ef          	jal	80003e0e <namei>
    80005564:	84aa                	mv	s1,a0
    80005566:	c915                	beqz	a0,8000559a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005568:	9b6fe0ef          	jal	8000371e <ilock>
  if(ip->type != T_DIR){
    8000556c:	04449703          	lh	a4,68(s1)
    80005570:	4785                	li	a5,1
    80005572:	02f71963          	bne	a4,a5,800055a4 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005576:	8526                	mv	a0,s1
    80005578:	a54fe0ef          	jal	800037cc <iunlock>
  iput(p->cwd);
    8000557c:	15093503          	ld	a0,336(s2)
    80005580:	b20fe0ef          	jal	800038a0 <iput>
  end_op();
    80005584:	ab7fe0ef          	jal	8000403a <end_op>
  p->cwd = ip;
    80005588:	14993823          	sd	s1,336(s2)
  return 0;
    8000558c:	4501                	li	a0,0
    8000558e:	64aa                	ld	s1,136(sp)
}
    80005590:	60ea                	ld	ra,152(sp)
    80005592:	644a                	ld	s0,144(sp)
    80005594:	690a                	ld	s2,128(sp)
    80005596:	610d                	addi	sp,sp,160
    80005598:	8082                	ret
    8000559a:	64aa                	ld	s1,136(sp)
    end_op();
    8000559c:	a9ffe0ef          	jal	8000403a <end_op>
    return -1;
    800055a0:	557d                	li	a0,-1
    800055a2:	b7fd                	j	80005590 <sys_chdir+0x5c>
    iunlockput(ip);
    800055a4:	8526                	mv	a0,s1
    800055a6:	b82fe0ef          	jal	80003928 <iunlockput>
    end_op();
    800055aa:	a91fe0ef          	jal	8000403a <end_op>
    return -1;
    800055ae:	557d                	li	a0,-1
    800055b0:	64aa                	ld	s1,136(sp)
    800055b2:	bff9                	j	80005590 <sys_chdir+0x5c>

00000000800055b4 <sys_exec>:

uint64
sys_exec(void)
{
    800055b4:	7105                	addi	sp,sp,-480
    800055b6:	ef86                	sd	ra,472(sp)
    800055b8:	eba2                	sd	s0,464(sp)
    800055ba:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800055bc:	e2840593          	addi	a1,s0,-472
    800055c0:	4505                	li	a0,1
    800055c2:	d6cfd0ef          	jal	80002b2e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800055c6:	08000613          	li	a2,128
    800055ca:	f3040593          	addi	a1,s0,-208
    800055ce:	4501                	li	a0,0
    800055d0:	d7afd0ef          	jal	80002b4a <argstr>
    800055d4:	87aa                	mv	a5,a0
    return -1;
    800055d6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800055d8:	0e07c063          	bltz	a5,800056b8 <sys_exec+0x104>
    800055dc:	e7a6                	sd	s1,456(sp)
    800055de:	e3ca                	sd	s2,448(sp)
    800055e0:	ff4e                	sd	s3,440(sp)
    800055e2:	fb52                	sd	s4,432(sp)
    800055e4:	f756                	sd	s5,424(sp)
    800055e6:	f35a                	sd	s6,416(sp)
    800055e8:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800055ea:	e3040a13          	addi	s4,s0,-464
    800055ee:	10000613          	li	a2,256
    800055f2:	4581                	li	a1,0
    800055f4:	8552                	mv	a0,s4
    800055f6:	ed8fb0ef          	jal	80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800055fa:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800055fc:	89d2                	mv	s3,s4
    800055fe:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005600:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005604:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005606:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000560a:	00391513          	slli	a0,s2,0x3
    8000560e:	85d6                	mv	a1,s5
    80005610:	e2843783          	ld	a5,-472(s0)
    80005614:	953e                	add	a0,a0,a5
    80005616:	c72fd0ef          	jal	80002a88 <fetchaddr>
    8000561a:	02054663          	bltz	a0,80005646 <sys_exec+0x92>
    if(uarg == 0){
    8000561e:	e2043783          	ld	a5,-480(s0)
    80005622:	c7a1                	beqz	a5,8000566a <sys_exec+0xb6>
    argv[i] = kalloc();
    80005624:	d06fb0ef          	jal	80000b2a <kalloc>
    80005628:	85aa                	mv	a1,a0
    8000562a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000562e:	cd01                	beqz	a0,80005646 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005630:	865a                	mv	a2,s6
    80005632:	e2043503          	ld	a0,-480(s0)
    80005636:	c9cfd0ef          	jal	80002ad2 <fetchstr>
    8000563a:	00054663          	bltz	a0,80005646 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    8000563e:	0905                	addi	s2,s2,1
    80005640:	09a1                	addi	s3,s3,8
    80005642:	fd7914e3          	bne	s2,s7,8000560a <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005646:	100a0a13          	addi	s4,s4,256
    8000564a:	6088                	ld	a0,0(s1)
    8000564c:	cd31                	beqz	a0,800056a8 <sys_exec+0xf4>
    kfree(argv[i]);
    8000564e:	bfafb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005652:	04a1                	addi	s1,s1,8
    80005654:	ff449be3          	bne	s1,s4,8000564a <sys_exec+0x96>
  return -1;
    80005658:	557d                	li	a0,-1
    8000565a:	64be                	ld	s1,456(sp)
    8000565c:	691e                	ld	s2,448(sp)
    8000565e:	79fa                	ld	s3,440(sp)
    80005660:	7a5a                	ld	s4,432(sp)
    80005662:	7aba                	ld	s5,424(sp)
    80005664:	7b1a                	ld	s6,416(sp)
    80005666:	6bfa                	ld	s7,408(sp)
    80005668:	a881                	j	800056b8 <sys_exec+0x104>
      argv[i] = 0;
    8000566a:	0009079b          	sext.w	a5,s2
    8000566e:	e3040593          	addi	a1,s0,-464
    80005672:	078e                	slli	a5,a5,0x3
    80005674:	97ae                	add	a5,a5,a1
    80005676:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    8000567a:	f3040513          	addi	a0,s0,-208
    8000567e:	ba4ff0ef          	jal	80004a22 <exec>
    80005682:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005684:	100a0a13          	addi	s4,s4,256
    80005688:	6088                	ld	a0,0(s1)
    8000568a:	c511                	beqz	a0,80005696 <sys_exec+0xe2>
    kfree(argv[i]);
    8000568c:	bbcfb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005690:	04a1                	addi	s1,s1,8
    80005692:	ff449be3          	bne	s1,s4,80005688 <sys_exec+0xd4>
  return ret;
    80005696:	854a                	mv	a0,s2
    80005698:	64be                	ld	s1,456(sp)
    8000569a:	691e                	ld	s2,448(sp)
    8000569c:	79fa                	ld	s3,440(sp)
    8000569e:	7a5a                	ld	s4,432(sp)
    800056a0:	7aba                	ld	s5,424(sp)
    800056a2:	7b1a                	ld	s6,416(sp)
    800056a4:	6bfa                	ld	s7,408(sp)
    800056a6:	a809                	j	800056b8 <sys_exec+0x104>
  return -1;
    800056a8:	557d                	li	a0,-1
    800056aa:	64be                	ld	s1,456(sp)
    800056ac:	691e                	ld	s2,448(sp)
    800056ae:	79fa                	ld	s3,440(sp)
    800056b0:	7a5a                	ld	s4,432(sp)
    800056b2:	7aba                	ld	s5,424(sp)
    800056b4:	7b1a                	ld	s6,416(sp)
    800056b6:	6bfa                	ld	s7,408(sp)
}
    800056b8:	60fe                	ld	ra,472(sp)
    800056ba:	645e                	ld	s0,464(sp)
    800056bc:	613d                	addi	sp,sp,480
    800056be:	8082                	ret

00000000800056c0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800056c0:	7139                	addi	sp,sp,-64
    800056c2:	fc06                	sd	ra,56(sp)
    800056c4:	f822                	sd	s0,48(sp)
    800056c6:	f426                	sd	s1,40(sp)
    800056c8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800056ca:	a12fc0ef          	jal	800018dc <myproc>
    800056ce:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800056d0:	fd840593          	addi	a1,s0,-40
    800056d4:	4501                	li	a0,0
    800056d6:	c58fd0ef          	jal	80002b2e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800056da:	fc840593          	addi	a1,s0,-56
    800056de:	fd040513          	addi	a0,s0,-48
    800056e2:	81eff0ef          	jal	80004700 <pipealloc>
    return -1;
    800056e6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800056e8:	0a054463          	bltz	a0,80005790 <sys_pipe+0xd0>
  fd0 = -1;
    800056ec:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800056f0:	fd043503          	ld	a0,-48(s0)
    800056f4:	edeff0ef          	jal	80004dd2 <fdalloc>
    800056f8:	fca42223          	sw	a0,-60(s0)
    800056fc:	08054163          	bltz	a0,8000577e <sys_pipe+0xbe>
    80005700:	fc843503          	ld	a0,-56(s0)
    80005704:	eceff0ef          	jal	80004dd2 <fdalloc>
    80005708:	fca42023          	sw	a0,-64(s0)
    8000570c:	06054063          	bltz	a0,8000576c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005710:	4691                	li	a3,4
    80005712:	fc440613          	addi	a2,s0,-60
    80005716:	fd843583          	ld	a1,-40(s0)
    8000571a:	68a8                	ld	a0,80(s1)
    8000571c:	e69fb0ef          	jal	80001584 <copyout>
    80005720:	00054e63          	bltz	a0,8000573c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005724:	4691                	li	a3,4
    80005726:	fc040613          	addi	a2,s0,-64
    8000572a:	fd843583          	ld	a1,-40(s0)
    8000572e:	95b6                	add	a1,a1,a3
    80005730:	68a8                	ld	a0,80(s1)
    80005732:	e53fb0ef          	jal	80001584 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005736:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005738:	04055c63          	bgez	a0,80005790 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000573c:	fc442783          	lw	a5,-60(s0)
    80005740:	07e9                	addi	a5,a5,26
    80005742:	078e                	slli	a5,a5,0x3
    80005744:	97a6                	add	a5,a5,s1
    80005746:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000574a:	fc042783          	lw	a5,-64(s0)
    8000574e:	07e9                	addi	a5,a5,26
    80005750:	078e                	slli	a5,a5,0x3
    80005752:	94be                	add	s1,s1,a5
    80005754:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005758:	fd043503          	ld	a0,-48(s0)
    8000575c:	c95fe0ef          	jal	800043f0 <fileclose>
    fileclose(wf);
    80005760:	fc843503          	ld	a0,-56(s0)
    80005764:	c8dfe0ef          	jal	800043f0 <fileclose>
    return -1;
    80005768:	57fd                	li	a5,-1
    8000576a:	a01d                	j	80005790 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000576c:	fc442783          	lw	a5,-60(s0)
    80005770:	0007c763          	bltz	a5,8000577e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005774:	07e9                	addi	a5,a5,26
    80005776:	078e                	slli	a5,a5,0x3
    80005778:	97a6                	add	a5,a5,s1
    8000577a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000577e:	fd043503          	ld	a0,-48(s0)
    80005782:	c6ffe0ef          	jal	800043f0 <fileclose>
    fileclose(wf);
    80005786:	fc843503          	ld	a0,-56(s0)
    8000578a:	c67fe0ef          	jal	800043f0 <fileclose>
    return -1;
    8000578e:	57fd                	li	a5,-1
}
    80005790:	853e                	mv	a0,a5
    80005792:	70e2                	ld	ra,56(sp)
    80005794:	7442                	ld	s0,48(sp)
    80005796:	74a2                	ld	s1,40(sp)
    80005798:	6121                	addi	sp,sp,64
    8000579a:	8082                	ret
    8000579c:	0000                	unimp
	...

00000000800057a0 <kernelvec>:
    800057a0:	7111                	addi	sp,sp,-256
    800057a2:	e006                	sd	ra,0(sp)
    800057a4:	e40a                	sd	sp,8(sp)
    800057a6:	e80e                	sd	gp,16(sp)
    800057a8:	ec12                	sd	tp,24(sp)
    800057aa:	f016                	sd	t0,32(sp)
    800057ac:	f41a                	sd	t1,40(sp)
    800057ae:	f81e                	sd	t2,48(sp)
    800057b0:	e4aa                	sd	a0,72(sp)
    800057b2:	e8ae                	sd	a1,80(sp)
    800057b4:	ecb2                	sd	a2,88(sp)
    800057b6:	f0b6                	sd	a3,96(sp)
    800057b8:	f4ba                	sd	a4,104(sp)
    800057ba:	f8be                	sd	a5,112(sp)
    800057bc:	fcc2                	sd	a6,120(sp)
    800057be:	e146                	sd	a7,128(sp)
    800057c0:	edf2                	sd	t3,216(sp)
    800057c2:	f1f6                	sd	t4,224(sp)
    800057c4:	f5fa                	sd	t5,232(sp)
    800057c6:	f9fe                	sd	t6,240(sp)
    800057c8:	9d0fd0ef          	jal	80002998 <kerneltrap>
    800057cc:	6082                	ld	ra,0(sp)
    800057ce:	6122                	ld	sp,8(sp)
    800057d0:	61c2                	ld	gp,16(sp)
    800057d2:	7282                	ld	t0,32(sp)
    800057d4:	7322                	ld	t1,40(sp)
    800057d6:	73c2                	ld	t2,48(sp)
    800057d8:	6526                	ld	a0,72(sp)
    800057da:	65c6                	ld	a1,80(sp)
    800057dc:	6666                	ld	a2,88(sp)
    800057de:	7686                	ld	a3,96(sp)
    800057e0:	7726                	ld	a4,104(sp)
    800057e2:	77c6                	ld	a5,112(sp)
    800057e4:	7866                	ld	a6,120(sp)
    800057e6:	688a                	ld	a7,128(sp)
    800057e8:	6e6e                	ld	t3,216(sp)
    800057ea:	7e8e                	ld	t4,224(sp)
    800057ec:	7f2e                	ld	t5,232(sp)
    800057ee:	7fce                	ld	t6,240(sp)
    800057f0:	6111                	addi	sp,sp,256
    800057f2:	10200073          	sret
	...

00000000800057fe <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800057fe:	1141                	addi	sp,sp,-16
    80005800:	e406                	sd	ra,8(sp)
    80005802:	e022                	sd	s0,0(sp)
    80005804:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005806:	0c000737          	lui	a4,0xc000
    8000580a:	4785                	li	a5,1
    8000580c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000580e:	c35c                	sw	a5,4(a4)
}
    80005810:	60a2                	ld	ra,8(sp)
    80005812:	6402                	ld	s0,0(sp)
    80005814:	0141                	addi	sp,sp,16
    80005816:	8082                	ret

0000000080005818 <plicinithart>:

void
plicinithart(void)
{
    80005818:	1141                	addi	sp,sp,-16
    8000581a:	e406                	sd	ra,8(sp)
    8000581c:	e022                	sd	s0,0(sp)
    8000581e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005820:	888fc0ef          	jal	800018a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005824:	0085171b          	slliw	a4,a0,0x8
    80005828:	0c0027b7          	lui	a5,0xc002
    8000582c:	97ba                	add	a5,a5,a4
    8000582e:	40200713          	li	a4,1026
    80005832:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005836:	00d5151b          	slliw	a0,a0,0xd
    8000583a:	0c2017b7          	lui	a5,0xc201
    8000583e:	97aa                	add	a5,a5,a0
    80005840:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005844:	60a2                	ld	ra,8(sp)
    80005846:	6402                	ld	s0,0(sp)
    80005848:	0141                	addi	sp,sp,16
    8000584a:	8082                	ret

000000008000584c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000584c:	1141                	addi	sp,sp,-16
    8000584e:	e406                	sd	ra,8(sp)
    80005850:	e022                	sd	s0,0(sp)
    80005852:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005854:	854fc0ef          	jal	800018a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005858:	00d5151b          	slliw	a0,a0,0xd
    8000585c:	0c2017b7          	lui	a5,0xc201
    80005860:	97aa                	add	a5,a5,a0
  return irq;
}
    80005862:	43c8                	lw	a0,4(a5)
    80005864:	60a2                	ld	ra,8(sp)
    80005866:	6402                	ld	s0,0(sp)
    80005868:	0141                	addi	sp,sp,16
    8000586a:	8082                	ret

000000008000586c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000586c:	1101                	addi	sp,sp,-32
    8000586e:	ec06                	sd	ra,24(sp)
    80005870:	e822                	sd	s0,16(sp)
    80005872:	e426                	sd	s1,8(sp)
    80005874:	1000                	addi	s0,sp,32
    80005876:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005878:	830fc0ef          	jal	800018a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000587c:	00d5179b          	slliw	a5,a0,0xd
    80005880:	0c201737          	lui	a4,0xc201
    80005884:	97ba                	add	a5,a5,a4
    80005886:	c3c4                	sw	s1,4(a5)
}
    80005888:	60e2                	ld	ra,24(sp)
    8000588a:	6442                	ld	s0,16(sp)
    8000588c:	64a2                	ld	s1,8(sp)
    8000588e:	6105                	addi	sp,sp,32
    80005890:	8082                	ret

0000000080005892 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005892:	1141                	addi	sp,sp,-16
    80005894:	e406                	sd	ra,8(sp)
    80005896:	e022                	sd	s0,0(sp)
    80005898:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000589a:	479d                	li	a5,7
    8000589c:	04a7ca63          	blt	a5,a0,800058f0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800058a0:	00025797          	auipc	a5,0x25
    800058a4:	00078793          	mv	a5,a5
    800058a8:	97aa                	add	a5,a5,a0
    800058aa:	0187c783          	lbu	a5,24(a5) # 8002a8b8 <disk+0x18>
    800058ae:	e7b9                	bnez	a5,800058fc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800058b0:	00451693          	slli	a3,a0,0x4
    800058b4:	00025797          	auipc	a5,0x25
    800058b8:	fec78793          	addi	a5,a5,-20 # 8002a8a0 <disk>
    800058bc:	6398                	ld	a4,0(a5)
    800058be:	9736                	add	a4,a4,a3
    800058c0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800058c4:	6398                	ld	a4,0(a5)
    800058c6:	9736                	add	a4,a4,a3
    800058c8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800058cc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800058d0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800058d4:	97aa                	add	a5,a5,a0
    800058d6:	4705                	li	a4,1
    800058d8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800058dc:	00025517          	auipc	a0,0x25
    800058e0:	fdc50513          	addi	a0,a0,-36 # 8002a8b8 <disk+0x18>
    800058e4:	997fc0ef          	jal	8000227a <wakeup>
}
    800058e8:	60a2                	ld	ra,8(sp)
    800058ea:	6402                	ld	s0,0(sp)
    800058ec:	0141                	addi	sp,sp,16
    800058ee:	8082                	ret
    panic("free_desc 1");
    800058f0:	00002517          	auipc	a0,0x2
    800058f4:	e4050513          	addi	a0,a0,-448 # 80007730 <etext+0x730>
    800058f8:	ea7fa0ef          	jal	8000079e <panic>
    panic("free_desc 2");
    800058fc:	00002517          	auipc	a0,0x2
    80005900:	e4450513          	addi	a0,a0,-444 # 80007740 <etext+0x740>
    80005904:	e9bfa0ef          	jal	8000079e <panic>

0000000080005908 <virtio_disk_init>:
{
    80005908:	1101                	addi	sp,sp,-32
    8000590a:	ec06                	sd	ra,24(sp)
    8000590c:	e822                	sd	s0,16(sp)
    8000590e:	e426                	sd	s1,8(sp)
    80005910:	e04a                	sd	s2,0(sp)
    80005912:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005914:	00002597          	auipc	a1,0x2
    80005918:	e3c58593          	addi	a1,a1,-452 # 80007750 <etext+0x750>
    8000591c:	00025517          	auipc	a0,0x25
    80005920:	0ac50513          	addi	a0,a0,172 # 8002a9c8 <disk+0x128>
    80005924:	a56fb0ef          	jal	80000b7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005928:	100017b7          	lui	a5,0x10001
    8000592c:	4398                	lw	a4,0(a5)
    8000592e:	2701                	sext.w	a4,a4
    80005930:	747277b7          	lui	a5,0x74727
    80005934:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005938:	14f71863          	bne	a4,a5,80005a88 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000593c:	100017b7          	lui	a5,0x10001
    80005940:	43dc                	lw	a5,4(a5)
    80005942:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005944:	4709                	li	a4,2
    80005946:	14e79163          	bne	a5,a4,80005a88 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000594a:	100017b7          	lui	a5,0x10001
    8000594e:	479c                	lw	a5,8(a5)
    80005950:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005952:	12e79b63          	bne	a5,a4,80005a88 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005956:	100017b7          	lui	a5,0x10001
    8000595a:	47d8                	lw	a4,12(a5)
    8000595c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000595e:	554d47b7          	lui	a5,0x554d4
    80005962:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005966:	12f71163          	bne	a4,a5,80005a88 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000596a:	100017b7          	lui	a5,0x10001
    8000596e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005972:	4705                	li	a4,1
    80005974:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005976:	470d                	li	a4,3
    80005978:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000597a:	10001737          	lui	a4,0x10001
    8000597e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005980:	c7ffe6b7          	lui	a3,0xc7ffe
    80005984:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd3d7f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005988:	8f75                	and	a4,a4,a3
    8000598a:	100016b7          	lui	a3,0x10001
    8000598e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005990:	472d                	li	a4,11
    80005992:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005994:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005998:	439c                	lw	a5,0(a5)
    8000599a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000599e:	8ba1                	andi	a5,a5,8
    800059a0:	0e078a63          	beqz	a5,80005a94 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800059a4:	100017b7          	lui	a5,0x10001
    800059a8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800059ac:	43fc                	lw	a5,68(a5)
    800059ae:	2781                	sext.w	a5,a5
    800059b0:	0e079863          	bnez	a5,80005aa0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800059b4:	100017b7          	lui	a5,0x10001
    800059b8:	5bdc                	lw	a5,52(a5)
    800059ba:	2781                	sext.w	a5,a5
  if(max == 0)
    800059bc:	0e078863          	beqz	a5,80005aac <virtio_disk_init+0x1a4>
  if(max < NUM)
    800059c0:	471d                	li	a4,7
    800059c2:	0ef77b63          	bgeu	a4,a5,80005ab8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800059c6:	964fb0ef          	jal	80000b2a <kalloc>
    800059ca:	00025497          	auipc	s1,0x25
    800059ce:	ed648493          	addi	s1,s1,-298 # 8002a8a0 <disk>
    800059d2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800059d4:	956fb0ef          	jal	80000b2a <kalloc>
    800059d8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800059da:	950fb0ef          	jal	80000b2a <kalloc>
    800059de:	87aa                	mv	a5,a0
    800059e0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800059e2:	6088                	ld	a0,0(s1)
    800059e4:	0e050063          	beqz	a0,80005ac4 <virtio_disk_init+0x1bc>
    800059e8:	00025717          	auipc	a4,0x25
    800059ec:	ec073703          	ld	a4,-320(a4) # 8002a8a8 <disk+0x8>
    800059f0:	cb71                	beqz	a4,80005ac4 <virtio_disk_init+0x1bc>
    800059f2:	cbe9                	beqz	a5,80005ac4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800059f4:	6605                	lui	a2,0x1
    800059f6:	4581                	li	a1,0
    800059f8:	ad6fb0ef          	jal	80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    800059fc:	00025497          	auipc	s1,0x25
    80005a00:	ea448493          	addi	s1,s1,-348 # 8002a8a0 <disk>
    80005a04:	6605                	lui	a2,0x1
    80005a06:	4581                	li	a1,0
    80005a08:	6488                	ld	a0,8(s1)
    80005a0a:	ac4fb0ef          	jal	80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005a0e:	6605                	lui	a2,0x1
    80005a10:	4581                	li	a1,0
    80005a12:	6888                	ld	a0,16(s1)
    80005a14:	abafb0ef          	jal	80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a18:	100017b7          	lui	a5,0x10001
    80005a1c:	4721                	li	a4,8
    80005a1e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a20:	4098                	lw	a4,0(s1)
    80005a22:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a26:	40d8                	lw	a4,4(s1)
    80005a28:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a2c:	649c                	ld	a5,8(s1)
    80005a2e:	0007869b          	sext.w	a3,a5
    80005a32:	10001737          	lui	a4,0x10001
    80005a36:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a3a:	9781                	srai	a5,a5,0x20
    80005a3c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a40:	689c                	ld	a5,16(s1)
    80005a42:	0007869b          	sext.w	a3,a5
    80005a46:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a4a:	9781                	srai	a5,a5,0x20
    80005a4c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a50:	4785                	li	a5,1
    80005a52:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a54:	00f48c23          	sb	a5,24(s1)
    80005a58:	00f48ca3          	sb	a5,25(s1)
    80005a5c:	00f48d23          	sb	a5,26(s1)
    80005a60:	00f48da3          	sb	a5,27(s1)
    80005a64:	00f48e23          	sb	a5,28(s1)
    80005a68:	00f48ea3          	sb	a5,29(s1)
    80005a6c:	00f48f23          	sb	a5,30(s1)
    80005a70:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a74:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a78:	07272823          	sw	s2,112(a4)
}
    80005a7c:	60e2                	ld	ra,24(sp)
    80005a7e:	6442                	ld	s0,16(sp)
    80005a80:	64a2                	ld	s1,8(sp)
    80005a82:	6902                	ld	s2,0(sp)
    80005a84:	6105                	addi	sp,sp,32
    80005a86:	8082                	ret
    panic("could not find virtio disk");
    80005a88:	00002517          	auipc	a0,0x2
    80005a8c:	cd850513          	addi	a0,a0,-808 # 80007760 <etext+0x760>
    80005a90:	d0ffa0ef          	jal	8000079e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a94:	00002517          	auipc	a0,0x2
    80005a98:	cec50513          	addi	a0,a0,-788 # 80007780 <etext+0x780>
    80005a9c:	d03fa0ef          	jal	8000079e <panic>
    panic("virtio disk should not be ready");
    80005aa0:	00002517          	auipc	a0,0x2
    80005aa4:	d0050513          	addi	a0,a0,-768 # 800077a0 <etext+0x7a0>
    80005aa8:	cf7fa0ef          	jal	8000079e <panic>
    panic("virtio disk has no queue 0");
    80005aac:	00002517          	auipc	a0,0x2
    80005ab0:	d1450513          	addi	a0,a0,-748 # 800077c0 <etext+0x7c0>
    80005ab4:	cebfa0ef          	jal	8000079e <panic>
    panic("virtio disk max queue too short");
    80005ab8:	00002517          	auipc	a0,0x2
    80005abc:	d2850513          	addi	a0,a0,-728 # 800077e0 <etext+0x7e0>
    80005ac0:	cdffa0ef          	jal	8000079e <panic>
    panic("virtio disk kalloc");
    80005ac4:	00002517          	auipc	a0,0x2
    80005ac8:	d3c50513          	addi	a0,a0,-708 # 80007800 <etext+0x800>
    80005acc:	cd3fa0ef          	jal	8000079e <panic>

0000000080005ad0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ad0:	711d                	addi	sp,sp,-96
    80005ad2:	ec86                	sd	ra,88(sp)
    80005ad4:	e8a2                	sd	s0,80(sp)
    80005ad6:	e4a6                	sd	s1,72(sp)
    80005ad8:	e0ca                	sd	s2,64(sp)
    80005ada:	fc4e                	sd	s3,56(sp)
    80005adc:	f852                	sd	s4,48(sp)
    80005ade:	f456                	sd	s5,40(sp)
    80005ae0:	f05a                	sd	s6,32(sp)
    80005ae2:	ec5e                	sd	s7,24(sp)
    80005ae4:	e862                	sd	s8,16(sp)
    80005ae6:	1080                	addi	s0,sp,96
    80005ae8:	89aa                	mv	s3,a0
    80005aea:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005aec:	00c52b83          	lw	s7,12(a0)
    80005af0:	001b9b9b          	slliw	s7,s7,0x1
    80005af4:	1b82                	slli	s7,s7,0x20
    80005af6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005afa:	00025517          	auipc	a0,0x25
    80005afe:	ece50513          	addi	a0,a0,-306 # 8002a9c8 <disk+0x128>
    80005b02:	8fcfb0ef          	jal	80000bfe <acquire>
  for(int i = 0; i < NUM; i++){
    80005b06:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b08:	00025a97          	auipc	s5,0x25
    80005b0c:	d98a8a93          	addi	s5,s5,-616 # 8002a8a0 <disk>
  for(int i = 0; i < 3; i++){
    80005b10:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005b12:	5c7d                	li	s8,-1
    80005b14:	a095                	j	80005b78 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005b16:	00fa8733          	add	a4,s5,a5
    80005b1a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005b1e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005b20:	0207c563          	bltz	a5,80005b4a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005b24:	2905                	addiw	s2,s2,1
    80005b26:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b28:	05490c63          	beq	s2,s4,80005b80 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005b2c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005b2e:	00025717          	auipc	a4,0x25
    80005b32:	d7270713          	addi	a4,a4,-654 # 8002a8a0 <disk>
    80005b36:	4781                	li	a5,0
    if(disk.free[i]){
    80005b38:	01874683          	lbu	a3,24(a4)
    80005b3c:	fee9                	bnez	a3,80005b16 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005b3e:	2785                	addiw	a5,a5,1
    80005b40:	0705                	addi	a4,a4,1
    80005b42:	fe979be3          	bne	a5,s1,80005b38 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005b46:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005b4a:	01205d63          	blez	s2,80005b64 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b4e:	fa042503          	lw	a0,-96(s0)
    80005b52:	d41ff0ef          	jal	80005892 <free_desc>
      for(int j = 0; j < i; j++)
    80005b56:	4785                	li	a5,1
    80005b58:	0127d663          	bge	a5,s2,80005b64 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b5c:	fa442503          	lw	a0,-92(s0)
    80005b60:	d33ff0ef          	jal	80005892 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005b64:	00025597          	auipc	a1,0x25
    80005b68:	e6458593          	addi	a1,a1,-412 # 8002a9c8 <disk+0x128>
    80005b6c:	00025517          	auipc	a0,0x25
    80005b70:	d4c50513          	addi	a0,a0,-692 # 8002a8b8 <disk+0x18>
    80005b74:	ebafc0ef          	jal	8000222e <sleep>
  for(int i = 0; i < 3; i++){
    80005b78:	fa040613          	addi	a2,s0,-96
    80005b7c:	4901                	li	s2,0
    80005b7e:	b77d                	j	80005b2c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b80:	fa042503          	lw	a0,-96(s0)
    80005b84:	00451693          	slli	a3,a0,0x4

  if(write)
    80005b88:	00025797          	auipc	a5,0x25
    80005b8c:	d1878793          	addi	a5,a5,-744 # 8002a8a0 <disk>
    80005b90:	00a50713          	addi	a4,a0,10
    80005b94:	0712                	slli	a4,a4,0x4
    80005b96:	973e                	add	a4,a4,a5
    80005b98:	01603633          	snez	a2,s6
    80005b9c:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b9e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005ba2:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ba6:	6398                	ld	a4,0(a5)
    80005ba8:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005baa:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005bae:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005bb0:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005bb2:	6390                	ld	a2,0(a5)
    80005bb4:	00d605b3          	add	a1,a2,a3
    80005bb8:	4741                	li	a4,16
    80005bba:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005bbc:	4805                	li	a6,1
    80005bbe:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005bc2:	fa442703          	lw	a4,-92(s0)
    80005bc6:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005bca:	0712                	slli	a4,a4,0x4
    80005bcc:	963a                	add	a2,a2,a4
    80005bce:	05898593          	addi	a1,s3,88
    80005bd2:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005bd4:	0007b883          	ld	a7,0(a5)
    80005bd8:	9746                	add	a4,a4,a7
    80005bda:	40000613          	li	a2,1024
    80005bde:	c710                	sw	a2,8(a4)
  if(write)
    80005be0:	001b3613          	seqz	a2,s6
    80005be4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005be8:	01066633          	or	a2,a2,a6
    80005bec:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005bf0:	fa842583          	lw	a1,-88(s0)
    80005bf4:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005bf8:	00250613          	addi	a2,a0,2
    80005bfc:	0612                	slli	a2,a2,0x4
    80005bfe:	963e                	add	a2,a2,a5
    80005c00:	577d                	li	a4,-1
    80005c02:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005c06:	0592                	slli	a1,a1,0x4
    80005c08:	98ae                	add	a7,a7,a1
    80005c0a:	03068713          	addi	a4,a3,48
    80005c0e:	973e                	add	a4,a4,a5
    80005c10:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005c14:	6398                	ld	a4,0(a5)
    80005c16:	972e                	add	a4,a4,a1
    80005c18:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c1c:	4689                	li	a3,2
    80005c1e:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c22:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c26:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    80005c2a:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c2e:	6794                	ld	a3,8(a5)
    80005c30:	0026d703          	lhu	a4,2(a3)
    80005c34:	8b1d                	andi	a4,a4,7
    80005c36:	0706                	slli	a4,a4,0x1
    80005c38:	96ba                	add	a3,a3,a4
    80005c3a:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005c3e:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c42:	6798                	ld	a4,8(a5)
    80005c44:	00275783          	lhu	a5,2(a4)
    80005c48:	2785                	addiw	a5,a5,1
    80005c4a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005c4e:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c52:	100017b7          	lui	a5,0x10001
    80005c56:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005c5a:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005c5e:	00025917          	auipc	s2,0x25
    80005c62:	d6a90913          	addi	s2,s2,-662 # 8002a9c8 <disk+0x128>
  while(b->disk == 1) {
    80005c66:	84c2                	mv	s1,a6
    80005c68:	01079a63          	bne	a5,a6,80005c7c <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    80005c6c:	85ca                	mv	a1,s2
    80005c6e:	854e                	mv	a0,s3
    80005c70:	dbefc0ef          	jal	8000222e <sleep>
  while(b->disk == 1) {
    80005c74:	0049a783          	lw	a5,4(s3)
    80005c78:	fe978ae3          	beq	a5,s1,80005c6c <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    80005c7c:	fa042903          	lw	s2,-96(s0)
    80005c80:	00290713          	addi	a4,s2,2
    80005c84:	0712                	slli	a4,a4,0x4
    80005c86:	00025797          	auipc	a5,0x25
    80005c8a:	c1a78793          	addi	a5,a5,-998 # 8002a8a0 <disk>
    80005c8e:	97ba                	add	a5,a5,a4
    80005c90:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c94:	00025997          	auipc	s3,0x25
    80005c98:	c0c98993          	addi	s3,s3,-1012 # 8002a8a0 <disk>
    80005c9c:	00491713          	slli	a4,s2,0x4
    80005ca0:	0009b783          	ld	a5,0(s3)
    80005ca4:	97ba                	add	a5,a5,a4
    80005ca6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005caa:	854a                	mv	a0,s2
    80005cac:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005cb0:	be3ff0ef          	jal	80005892 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005cb4:	8885                	andi	s1,s1,1
    80005cb6:	f0fd                	bnez	s1,80005c9c <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005cb8:	00025517          	auipc	a0,0x25
    80005cbc:	d1050513          	addi	a0,a0,-752 # 8002a9c8 <disk+0x128>
    80005cc0:	fd3fa0ef          	jal	80000c92 <release>
}
    80005cc4:	60e6                	ld	ra,88(sp)
    80005cc6:	6446                	ld	s0,80(sp)
    80005cc8:	64a6                	ld	s1,72(sp)
    80005cca:	6906                	ld	s2,64(sp)
    80005ccc:	79e2                	ld	s3,56(sp)
    80005cce:	7a42                	ld	s4,48(sp)
    80005cd0:	7aa2                	ld	s5,40(sp)
    80005cd2:	7b02                	ld	s6,32(sp)
    80005cd4:	6be2                	ld	s7,24(sp)
    80005cd6:	6c42                	ld	s8,16(sp)
    80005cd8:	6125                	addi	sp,sp,96
    80005cda:	8082                	ret

0000000080005cdc <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005cdc:	1101                	addi	sp,sp,-32
    80005cde:	ec06                	sd	ra,24(sp)
    80005ce0:	e822                	sd	s0,16(sp)
    80005ce2:	e426                	sd	s1,8(sp)
    80005ce4:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005ce6:	00025497          	auipc	s1,0x25
    80005cea:	bba48493          	addi	s1,s1,-1094 # 8002a8a0 <disk>
    80005cee:	00025517          	auipc	a0,0x25
    80005cf2:	cda50513          	addi	a0,a0,-806 # 8002a9c8 <disk+0x128>
    80005cf6:	f09fa0ef          	jal	80000bfe <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005cfa:	100017b7          	lui	a5,0x10001
    80005cfe:	53bc                	lw	a5,96(a5)
    80005d00:	8b8d                	andi	a5,a5,3
    80005d02:	10001737          	lui	a4,0x10001
    80005d06:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005d08:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005d0c:	689c                	ld	a5,16(s1)
    80005d0e:	0204d703          	lhu	a4,32(s1)
    80005d12:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005d16:	04f70663          	beq	a4,a5,80005d62 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005d1a:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d1e:	6898                	ld	a4,16(s1)
    80005d20:	0204d783          	lhu	a5,32(s1)
    80005d24:	8b9d                	andi	a5,a5,7
    80005d26:	078e                	slli	a5,a5,0x3
    80005d28:	97ba                	add	a5,a5,a4
    80005d2a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005d2c:	00278713          	addi	a4,a5,2
    80005d30:	0712                	slli	a4,a4,0x4
    80005d32:	9726                	add	a4,a4,s1
    80005d34:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005d38:	e321                	bnez	a4,80005d78 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d3a:	0789                	addi	a5,a5,2
    80005d3c:	0792                	slli	a5,a5,0x4
    80005d3e:	97a6                	add	a5,a5,s1
    80005d40:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005d42:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d46:	d34fc0ef          	jal	8000227a <wakeup>

    disk.used_idx += 1;
    80005d4a:	0204d783          	lhu	a5,32(s1)
    80005d4e:	2785                	addiw	a5,a5,1
    80005d50:	17c2                	slli	a5,a5,0x30
    80005d52:	93c1                	srli	a5,a5,0x30
    80005d54:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005d58:	6898                	ld	a4,16(s1)
    80005d5a:	00275703          	lhu	a4,2(a4)
    80005d5e:	faf71ee3          	bne	a4,a5,80005d1a <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005d62:	00025517          	auipc	a0,0x25
    80005d66:	c6650513          	addi	a0,a0,-922 # 8002a9c8 <disk+0x128>
    80005d6a:	f29fa0ef          	jal	80000c92 <release>
}
    80005d6e:	60e2                	ld	ra,24(sp)
    80005d70:	6442                	ld	s0,16(sp)
    80005d72:	64a2                	ld	s1,8(sp)
    80005d74:	6105                	addi	sp,sp,32
    80005d76:	8082                	ret
      panic("virtio_disk_intr status");
    80005d78:	00002517          	auipc	a0,0x2
    80005d7c:	aa050513          	addi	a0,a0,-1376 # 80007818 <etext+0x818>
    80005d80:	a1ffa0ef          	jal	8000079e <panic>
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
