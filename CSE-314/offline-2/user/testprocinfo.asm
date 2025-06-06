
user/_testprocinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "./kernel/param.h"
#include "user.h"


int main(void)
{
   0:	9d010113          	addi	sp,sp,-1584
   4:	62113423          	sd	ra,1576(sp)
   8:	62813023          	sd	s0,1568(sp)
   c:	63010413          	addi	s0,sp,1584
    struct pstat st;
    int ret = getpinfo(&st);
  10:	9d040513          	addi	a0,s0,-1584
  14:	3ca000ef          	jal	3de <getpinfo>
    if (ret != 0)
  18:	c105                	beqz	a0,38 <main+0x38>
  1a:	60913c23          	sd	s1,1560(sp)
  1e:	61213823          	sd	s2,1552(sp)
  22:	61313423          	sd	s3,1544(sp)
    {
        printf("[testprocinfo] getpinfo failed\n");
  26:	00001517          	auipc	a0,0x1
  2a:	8da50513          	addi	a0,a0,-1830 # 900 <malloc+0x100>
  2e:	71a000ef          	jal	748 <printf>
        exit(1);
  32:	4505                	li	a0,1
  34:	2fa000ef          	jal	32e <exit>
  38:	60913c23          	sd	s1,1560(sp)
  3c:	61213823          	sd	s2,1552(sp)
  40:	61313423          	sd	s3,1544(sp)
    }
    // Print header row
    printf("PID   INUSE TICKETS_O TICKETS_C SLICES   QUEUE Q\n");
  44:	00001517          	auipc	a0,0x1
  48:	8dc50513          	addi	a0,a0,-1828 # 920 <malloc+0x120>
  4c:	6fc000ef          	jal	748 <printf>
    for (int i = 0; i < NPROC; i++)
  50:	9d040493          	addi	s1,s0,-1584
  54:	ad040913          	addi	s2,s0,-1328
    {
        if (st.inuse[i])
        {
            printf("%-5d %-5d %-9d %-9d %-8d %-6d %-3d\n",
  58:	00001997          	auipc	s3,0x1
  5c:	90098993          	addi	s3,s3,-1792 # 958 <malloc+0x158>
  60:	a021                	j	68 <main+0x68>
    for (int i = 0; i < NPROC; i++)
  62:	0491                	addi	s1,s1,4
  64:	03248363          	beq	s1,s2,8a <main+0x8a>
        if (st.inuse[i])
  68:	1004a603          	lw	a2,256(s1)
  6c:	da7d                	beqz	a2,62 <main+0x62>
            printf("%-5d %-5d %-9d %-9d %-8d %-6d %-3d\n",
  6e:	2004a803          	lw	a6,512(s1)
  72:	88c2                	mv	a7,a6
  74:	5004a783          	lw	a5,1280(s1)
  78:	4004a703          	lw	a4,1024(s1)
  7c:	3004a683          	lw	a3,768(s1)
  80:	408c                	lw	a1,0(s1)
  82:	854e                	mv	a0,s3
  84:	6c4000ef          	jal	748 <printf>
  88:	bfe9                	j	62 <main+0x62>
                st.time_slices[i],
                st.inQ[i],
                st.inQ[i]);
        }
    }
    exit(0);
  8a:	4501                	li	a0,0
  8c:	2a2000ef          	jal	32e <exit>

0000000000000090 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  90:	1141                	addi	sp,sp,-16
  92:	e406                	sd	ra,8(sp)
  94:	e022                	sd	s0,0(sp)
  96:	0800                	addi	s0,sp,16
  extern int main();
  main();
  98:	f69ff0ef          	jal	0 <main>
  exit(0);
  9c:	4501                	li	a0,0
  9e:	290000ef          	jal	32e <exit>

00000000000000a2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e406                	sd	ra,8(sp)
  a6:	e022                	sd	s0,0(sp)
  a8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  aa:	87aa                	mv	a5,a0
  ac:	0585                	addi	a1,a1,1
  ae:	0785                	addi	a5,a5,1
  b0:	fff5c703          	lbu	a4,-1(a1)
  b4:	fee78fa3          	sb	a4,-1(a5)
  b8:	fb75                	bnez	a4,ac <strcpy+0xa>
    ;
  return os;
}
  ba:	60a2                	ld	ra,8(sp)
  bc:	6402                	ld	s0,0(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e406                	sd	ra,8(sp)
  c6:	e022                	sd	s0,0(sp)
  c8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cb91                	beqz	a5,e2 <strcmp+0x20>
  d0:	0005c703          	lbu	a4,0(a1)
  d4:	00f71763          	bne	a4,a5,e2 <strcmp+0x20>
    p++, q++;
  d8:	0505                	addi	a0,a0,1
  da:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	fbe5                	bnez	a5,d0 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  e2:	0005c503          	lbu	a0,0(a1)
}
  e6:	40a7853b          	subw	a0,a5,a0
  ea:	60a2                	ld	ra,8(sp)
  ec:	6402                	ld	s0,0(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strlen>:

uint
strlen(const char *s)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e406                	sd	ra,8(sp)
  f6:	e022                	sd	s0,0(sp)
  f8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cf99                	beqz	a5,11c <strlen+0x2a>
 100:	0505                	addi	a0,a0,1
 102:	87aa                	mv	a5,a0
 104:	86be                	mv	a3,a5
 106:	0785                	addi	a5,a5,1
 108:	fff7c703          	lbu	a4,-1(a5)
 10c:	ff65                	bnez	a4,104 <strlen+0x12>
 10e:	40a6853b          	subw	a0,a3,a0
 112:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 114:	60a2                	ld	ra,8(sp)
 116:	6402                	ld	s0,0(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret
  for(n = 0; s[n]; n++)
 11c:	4501                	li	a0,0
 11e:	bfdd                	j	114 <strlen+0x22>

0000000000000120 <memset>:

void*
memset(void *dst, int c, uint n)
{
 120:	1141                	addi	sp,sp,-16
 122:	e406                	sd	ra,8(sp)
 124:	e022                	sd	s0,0(sp)
 126:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 128:	ca19                	beqz	a2,13e <memset+0x1e>
 12a:	87aa                	mv	a5,a0
 12c:	1602                	slli	a2,a2,0x20
 12e:	9201                	srli	a2,a2,0x20
 130:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 134:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 138:	0785                	addi	a5,a5,1
 13a:	fee79de3          	bne	a5,a4,134 <memset+0x14>
  }
  return dst;
}
 13e:	60a2                	ld	ra,8(sp)
 140:	6402                	ld	s0,0(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret

0000000000000146 <strchr>:

char*
strchr(const char *s, char c)
{
 146:	1141                	addi	sp,sp,-16
 148:	e406                	sd	ra,8(sp)
 14a:	e022                	sd	s0,0(sp)
 14c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 14e:	00054783          	lbu	a5,0(a0)
 152:	cf81                	beqz	a5,16a <strchr+0x24>
    if(*s == c)
 154:	00f58763          	beq	a1,a5,162 <strchr+0x1c>
  for(; *s; s++)
 158:	0505                	addi	a0,a0,1
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbfd                	bnez	a5,154 <strchr+0xe>
      return (char*)s;
  return 0;
 160:	4501                	li	a0,0
}
 162:	60a2                	ld	ra,8(sp)
 164:	6402                	ld	s0,0(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret
  return 0;
 16a:	4501                	li	a0,0
 16c:	bfdd                	j	162 <strchr+0x1c>

000000000000016e <gets>:

char*
gets(char *buf, int max)
{
 16e:	7159                	addi	sp,sp,-112
 170:	f486                	sd	ra,104(sp)
 172:	f0a2                	sd	s0,96(sp)
 174:	eca6                	sd	s1,88(sp)
 176:	e8ca                	sd	s2,80(sp)
 178:	e4ce                	sd	s3,72(sp)
 17a:	e0d2                	sd	s4,64(sp)
 17c:	fc56                	sd	s5,56(sp)
 17e:	f85a                	sd	s6,48(sp)
 180:	f45e                	sd	s7,40(sp)
 182:	f062                	sd	s8,32(sp)
 184:	ec66                	sd	s9,24(sp)
 186:	e86a                	sd	s10,16(sp)
 188:	1880                	addi	s0,sp,112
 18a:	8caa                	mv	s9,a0
 18c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18e:	892a                	mv	s2,a0
 190:	4481                	li	s1,0
    cc = read(0, &c, 1);
 192:	f9f40b13          	addi	s6,s0,-97
 196:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 198:	4ba9                	li	s7,10
 19a:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 19c:	8d26                	mv	s10,s1
 19e:	0014899b          	addiw	s3,s1,1
 1a2:	84ce                	mv	s1,s3
 1a4:	0349d563          	bge	s3,s4,1ce <gets+0x60>
    cc = read(0, &c, 1);
 1a8:	8656                	mv	a2,s5
 1aa:	85da                	mv	a1,s6
 1ac:	4501                	li	a0,0
 1ae:	198000ef          	jal	346 <read>
    if(cc < 1)
 1b2:	00a05e63          	blez	a0,1ce <gets+0x60>
    buf[i++] = c;
 1b6:	f9f44783          	lbu	a5,-97(s0)
 1ba:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1be:	01778763          	beq	a5,s7,1cc <gets+0x5e>
 1c2:	0905                	addi	s2,s2,1
 1c4:	fd879ce3          	bne	a5,s8,19c <gets+0x2e>
    buf[i++] = c;
 1c8:	8d4e                	mv	s10,s3
 1ca:	a011                	j	1ce <gets+0x60>
 1cc:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 1ce:	9d66                	add	s10,s10,s9
 1d0:	000d0023          	sb	zero,0(s10)
  return buf;
}
 1d4:	8566                	mv	a0,s9
 1d6:	70a6                	ld	ra,104(sp)
 1d8:	7406                	ld	s0,96(sp)
 1da:	64e6                	ld	s1,88(sp)
 1dc:	6946                	ld	s2,80(sp)
 1de:	69a6                	ld	s3,72(sp)
 1e0:	6a06                	ld	s4,64(sp)
 1e2:	7ae2                	ld	s5,56(sp)
 1e4:	7b42                	ld	s6,48(sp)
 1e6:	7ba2                	ld	s7,40(sp)
 1e8:	7c02                	ld	s8,32(sp)
 1ea:	6ce2                	ld	s9,24(sp)
 1ec:	6d42                	ld	s10,16(sp)
 1ee:	6165                	addi	sp,sp,112
 1f0:	8082                	ret

00000000000001f2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f2:	1101                	addi	sp,sp,-32
 1f4:	ec06                	sd	ra,24(sp)
 1f6:	e822                	sd	s0,16(sp)
 1f8:	e04a                	sd	s2,0(sp)
 1fa:	1000                	addi	s0,sp,32
 1fc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fe:	4581                	li	a1,0
 200:	16e000ef          	jal	36e <open>
  if(fd < 0)
 204:	02054263          	bltz	a0,228 <stat+0x36>
 208:	e426                	sd	s1,8(sp)
 20a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20c:	85ca                	mv	a1,s2
 20e:	178000ef          	jal	386 <fstat>
 212:	892a                	mv	s2,a0
  close(fd);
 214:	8526                	mv	a0,s1
 216:	140000ef          	jal	356 <close>
  return r;
 21a:	64a2                	ld	s1,8(sp)
}
 21c:	854a                	mv	a0,s2
 21e:	60e2                	ld	ra,24(sp)
 220:	6442                	ld	s0,16(sp)
 222:	6902                	ld	s2,0(sp)
 224:	6105                	addi	sp,sp,32
 226:	8082                	ret
    return -1;
 228:	597d                	li	s2,-1
 22a:	bfcd                	j	21c <stat+0x2a>

000000000000022c <atoi>:

int
atoi(const char *s)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e406                	sd	ra,8(sp)
 230:	e022                	sd	s0,0(sp)
 232:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 234:	00054683          	lbu	a3,0(a0)
 238:	fd06879b          	addiw	a5,a3,-48
 23c:	0ff7f793          	zext.b	a5,a5
 240:	4625                	li	a2,9
 242:	02f66963          	bltu	a2,a5,274 <atoi+0x48>
 246:	872a                	mv	a4,a0
  n = 0;
 248:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 24a:	0705                	addi	a4,a4,1
 24c:	0025179b          	slliw	a5,a0,0x2
 250:	9fa9                	addw	a5,a5,a0
 252:	0017979b          	slliw	a5,a5,0x1
 256:	9fb5                	addw	a5,a5,a3
 258:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25c:	00074683          	lbu	a3,0(a4)
 260:	fd06879b          	addiw	a5,a3,-48
 264:	0ff7f793          	zext.b	a5,a5
 268:	fef671e3          	bgeu	a2,a5,24a <atoi+0x1e>
  return n;
}
 26c:	60a2                	ld	ra,8(sp)
 26e:	6402                	ld	s0,0(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret
  n = 0;
 274:	4501                	li	a0,0
 276:	bfdd                	j	26c <atoi+0x40>

0000000000000278 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e406                	sd	ra,8(sp)
 27c:	e022                	sd	s0,0(sp)
 27e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 280:	02b57563          	bgeu	a0,a1,2aa <memmove+0x32>
    while(n-- > 0)
 284:	00c05f63          	blez	a2,2a2 <memmove+0x2a>
 288:	1602                	slli	a2,a2,0x20
 28a:	9201                	srli	a2,a2,0x20
 28c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 290:	872a                	mv	a4,a0
      *dst++ = *src++;
 292:	0585                	addi	a1,a1,1
 294:	0705                	addi	a4,a4,1
 296:	fff5c683          	lbu	a3,-1(a1)
 29a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29e:	fee79ae3          	bne	a5,a4,292 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret
    dst += n;
 2aa:	00c50733          	add	a4,a0,a2
    src += n;
 2ae:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b0:	fec059e3          	blez	a2,2a2 <memmove+0x2a>
 2b4:	fff6079b          	addiw	a5,a2,-1
 2b8:	1782                	slli	a5,a5,0x20
 2ba:	9381                	srli	a5,a5,0x20
 2bc:	fff7c793          	not	a5,a5
 2c0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c2:	15fd                	addi	a1,a1,-1
 2c4:	177d                	addi	a4,a4,-1
 2c6:	0005c683          	lbu	a3,0(a1)
 2ca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ce:	fef71ae3          	bne	a4,a5,2c2 <memmove+0x4a>
 2d2:	bfc1                	j	2a2 <memmove+0x2a>

00000000000002d4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e406                	sd	ra,8(sp)
 2d8:	e022                	sd	s0,0(sp)
 2da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2dc:	ca0d                	beqz	a2,30e <memcmp+0x3a>
 2de:	fff6069b          	addiw	a3,a2,-1
 2e2:	1682                	slli	a3,a3,0x20
 2e4:	9281                	srli	a3,a3,0x20
 2e6:	0685                	addi	a3,a3,1
 2e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ea:	00054783          	lbu	a5,0(a0)
 2ee:	0005c703          	lbu	a4,0(a1)
 2f2:	00e79863          	bne	a5,a4,302 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 2f6:	0505                	addi	a0,a0,1
    p2++;
 2f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fa:	fed518e3          	bne	a0,a3,2ea <memcmp+0x16>
  }
  return 0;
 2fe:	4501                	li	a0,0
 300:	a019                	j	306 <memcmp+0x32>
      return *p1 - *p2;
 302:	40e7853b          	subw	a0,a5,a4
}
 306:	60a2                	ld	ra,8(sp)
 308:	6402                	ld	s0,0(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret
  return 0;
 30e:	4501                	li	a0,0
 310:	bfdd                	j	306 <memcmp+0x32>

0000000000000312 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 312:	1141                	addi	sp,sp,-16
 314:	e406                	sd	ra,8(sp)
 316:	e022                	sd	s0,0(sp)
 318:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31a:	f5fff0ef          	jal	278 <memmove>
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 326:	4885                	li	a7,1
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <exit>:
.global exit
exit:
 li a7, SYS_exit
 32e:	4889                	li	a7,2
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <wait>:
.global wait
wait:
 li a7, SYS_wait
 336:	488d                	li	a7,3
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33e:	4891                	li	a7,4
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <read>:
.global read
read:
 li a7, SYS_read
 346:	4895                	li	a7,5
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <write>:
.global write
write:
 li a7, SYS_write
 34e:	48c1                	li	a7,16
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <close>:
.global close
close:
 li a7, SYS_close
 356:	48d5                	li	a7,21
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <kill>:
.global kill
kill:
 li a7, SYS_kill
 35e:	4899                	li	a7,6
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <exec>:
.global exec
exec:
 li a7, SYS_exec
 366:	489d                	li	a7,7
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <open>:
.global open
open:
 li a7, SYS_open
 36e:	48bd                	li	a7,15
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 376:	48c5                	li	a7,17
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 37e:	48c9                	li	a7,18
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 386:	48a1                	li	a7,8
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <link>:
.global link
link:
 li a7, SYS_link
 38e:	48cd                	li	a7,19
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 396:	48d1                	li	a7,20
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 39e:	48a5                	li	a7,9
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a6:	48a9                	li	a7,10
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ae:	48ad                	li	a7,11
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b6:	48b1                	li	a7,12
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3be:	48b5                	li	a7,13
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c6:	48b9                	li	a7,14
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <history>:
.global history
history:
 li a7, SYS_history
 3ce:	48d9                	li	a7,22
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3d6:	48dd                	li	a7,23
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 3de:	48dd                	li	a7,23
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e6:	1101                	addi	sp,sp,-32
 3e8:	ec06                	sd	ra,24(sp)
 3ea:	e822                	sd	s0,16(sp)
 3ec:	1000                	addi	s0,sp,32
 3ee:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f2:	4605                	li	a2,1
 3f4:	fef40593          	addi	a1,s0,-17
 3f8:	f57ff0ef          	jal	34e <write>
}
 3fc:	60e2                	ld	ra,24(sp)
 3fe:	6442                	ld	s0,16(sp)
 400:	6105                	addi	sp,sp,32
 402:	8082                	ret

0000000000000404 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 404:	7139                	addi	sp,sp,-64
 406:	fc06                	sd	ra,56(sp)
 408:	f822                	sd	s0,48(sp)
 40a:	f426                	sd	s1,40(sp)
 40c:	f04a                	sd	s2,32(sp)
 40e:	ec4e                	sd	s3,24(sp)
 410:	0080                	addi	s0,sp,64
 412:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 414:	c299                	beqz	a3,41a <printint+0x16>
 416:	0605ce63          	bltz	a1,492 <printint+0x8e>
  neg = 0;
 41a:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 41c:	fc040313          	addi	t1,s0,-64
  neg = 0;
 420:	869a                	mv	a3,t1
  i = 0;
 422:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 424:	00000817          	auipc	a6,0x0
 428:	56480813          	addi	a6,a6,1380 # 988 <digits>
 42c:	88be                	mv	a7,a5
 42e:	0017851b          	addiw	a0,a5,1
 432:	87aa                	mv	a5,a0
 434:	02c5f73b          	remuw	a4,a1,a2
 438:	1702                	slli	a4,a4,0x20
 43a:	9301                	srli	a4,a4,0x20
 43c:	9742                	add	a4,a4,a6
 43e:	00074703          	lbu	a4,0(a4)
 442:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 446:	872e                	mv	a4,a1
 448:	02c5d5bb          	divuw	a1,a1,a2
 44c:	0685                	addi	a3,a3,1
 44e:	fcc77fe3          	bgeu	a4,a2,42c <printint+0x28>
  if(neg)
 452:	000e0c63          	beqz	t3,46a <printint+0x66>
    buf[i++] = '-';
 456:	fd050793          	addi	a5,a0,-48
 45a:	00878533          	add	a0,a5,s0
 45e:	02d00793          	li	a5,45
 462:	fef50823          	sb	a5,-16(a0)
 466:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 46a:	fff7899b          	addiw	s3,a5,-1
 46e:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 472:	fff4c583          	lbu	a1,-1(s1)
 476:	854a                	mv	a0,s2
 478:	f6fff0ef          	jal	3e6 <putc>
  while(--i >= 0)
 47c:	39fd                	addiw	s3,s3,-1
 47e:	14fd                	addi	s1,s1,-1
 480:	fe09d9e3          	bgez	s3,472 <printint+0x6e>
}
 484:	70e2                	ld	ra,56(sp)
 486:	7442                	ld	s0,48(sp)
 488:	74a2                	ld	s1,40(sp)
 48a:	7902                	ld	s2,32(sp)
 48c:	69e2                	ld	s3,24(sp)
 48e:	6121                	addi	sp,sp,64
 490:	8082                	ret
    x = -xx;
 492:	40b005bb          	negw	a1,a1
    neg = 1;
 496:	4e05                	li	t3,1
    x = -xx;
 498:	b751                	j	41c <printint+0x18>

000000000000049a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 49a:	711d                	addi	sp,sp,-96
 49c:	ec86                	sd	ra,88(sp)
 49e:	e8a2                	sd	s0,80(sp)
 4a0:	e4a6                	sd	s1,72(sp)
 4a2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a4:	0005c483          	lbu	s1,0(a1)
 4a8:	26048663          	beqz	s1,714 <vprintf+0x27a>
 4ac:	e0ca                	sd	s2,64(sp)
 4ae:	fc4e                	sd	s3,56(sp)
 4b0:	f852                	sd	s4,48(sp)
 4b2:	f456                	sd	s5,40(sp)
 4b4:	f05a                	sd	s6,32(sp)
 4b6:	ec5e                	sd	s7,24(sp)
 4b8:	e862                	sd	s8,16(sp)
 4ba:	e466                	sd	s9,8(sp)
 4bc:	8b2a                	mv	s6,a0
 4be:	8a2e                	mv	s4,a1
 4c0:	8bb2                	mv	s7,a2
  state = 0;
 4c2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4c4:	4901                	li	s2,0
 4c6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4c8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4cc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4d0:	06c00c93          	li	s9,108
 4d4:	a00d                	j	4f6 <vprintf+0x5c>
        putc(fd, c0);
 4d6:	85a6                	mv	a1,s1
 4d8:	855a                	mv	a0,s6
 4da:	f0dff0ef          	jal	3e6 <putc>
 4de:	a019                	j	4e4 <vprintf+0x4a>
    } else if(state == '%'){
 4e0:	03598363          	beq	s3,s5,506 <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 4e4:	0019079b          	addiw	a5,s2,1
 4e8:	893e                	mv	s2,a5
 4ea:	873e                	mv	a4,a5
 4ec:	97d2                	add	a5,a5,s4
 4ee:	0007c483          	lbu	s1,0(a5)
 4f2:	20048963          	beqz	s1,704 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 4f6:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4fa:	fe0993e3          	bnez	s3,4e0 <vprintf+0x46>
      if(c0 == '%'){
 4fe:	fd579ce3          	bne	a5,s5,4d6 <vprintf+0x3c>
        state = '%';
 502:	89be                	mv	s3,a5
 504:	b7c5                	j	4e4 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 506:	00ea06b3          	add	a3,s4,a4
 50a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 50e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 510:	c681                	beqz	a3,518 <vprintf+0x7e>
 512:	9752                	add	a4,a4,s4
 514:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 518:	03878e63          	beq	a5,s8,554 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 51c:	05978863          	beq	a5,s9,56c <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 520:	07500713          	li	a4,117
 524:	0ee78263          	beq	a5,a4,608 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 528:	07800713          	li	a4,120
 52c:	12e78463          	beq	a5,a4,654 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 530:	07000713          	li	a4,112
 534:	14e78963          	beq	a5,a4,686 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 538:	07300713          	li	a4,115
 53c:	18e78863          	beq	a5,a4,6cc <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 540:	02500713          	li	a4,37
 544:	04e79463          	bne	a5,a4,58c <vprintf+0xf2>
        putc(fd, '%');
 548:	85ba                	mv	a1,a4
 54a:	855a                	mv	a0,s6
 54c:	e9bff0ef          	jal	3e6 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 550:	4981                	li	s3,0
 552:	bf49                	j	4e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 554:	008b8493          	addi	s1,s7,8
 558:	4685                	li	a3,1
 55a:	4629                	li	a2,10
 55c:	000ba583          	lw	a1,0(s7)
 560:	855a                	mv	a0,s6
 562:	ea3ff0ef          	jal	404 <printint>
 566:	8ba6                	mv	s7,s1
      state = 0;
 568:	4981                	li	s3,0
 56a:	bfad                	j	4e4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 56c:	06400793          	li	a5,100
 570:	02f68963          	beq	a3,a5,5a2 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 574:	06c00793          	li	a5,108
 578:	04f68263          	beq	a3,a5,5bc <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 57c:	07500793          	li	a5,117
 580:	0af68063          	beq	a3,a5,620 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 584:	07800793          	li	a5,120
 588:	0ef68263          	beq	a3,a5,66c <vprintf+0x1d2>
        putc(fd, '%');
 58c:	02500593          	li	a1,37
 590:	855a                	mv	a0,s6
 592:	e55ff0ef          	jal	3e6 <putc>
        putc(fd, c0);
 596:	85a6                	mv	a1,s1
 598:	855a                	mv	a0,s6
 59a:	e4dff0ef          	jal	3e6 <putc>
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	b791                	j	4e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a2:	008b8493          	addi	s1,s7,8
 5a6:	4685                	li	a3,1
 5a8:	4629                	li	a2,10
 5aa:	000ba583          	lw	a1,0(s7)
 5ae:	855a                	mv	a0,s6
 5b0:	e55ff0ef          	jal	404 <printint>
        i += 1;
 5b4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b6:	8ba6                	mv	s7,s1
      state = 0;
 5b8:	4981                	li	s3,0
        i += 1;
 5ba:	b72d                	j	4e4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5bc:	06400793          	li	a5,100
 5c0:	02f60763          	beq	a2,a5,5ee <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5c4:	07500793          	li	a5,117
 5c8:	06f60963          	beq	a2,a5,63a <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5cc:	07800793          	li	a5,120
 5d0:	faf61ee3          	bne	a2,a5,58c <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d4:	008b8493          	addi	s1,s7,8
 5d8:	4681                	li	a3,0
 5da:	4641                	li	a2,16
 5dc:	000ba583          	lw	a1,0(s7)
 5e0:	855a                	mv	a0,s6
 5e2:	e23ff0ef          	jal	404 <printint>
        i += 2;
 5e6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e8:	8ba6                	mv	s7,s1
      state = 0;
 5ea:	4981                	li	s3,0
        i += 2;
 5ec:	bde5                	j	4e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ee:	008b8493          	addi	s1,s7,8
 5f2:	4685                	li	a3,1
 5f4:	4629                	li	a2,10
 5f6:	000ba583          	lw	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	e09ff0ef          	jal	404 <printint>
        i += 2;
 600:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 602:	8ba6                	mv	s7,s1
      state = 0;
 604:	4981                	li	s3,0
        i += 2;
 606:	bdf9                	j	4e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 608:	008b8493          	addi	s1,s7,8
 60c:	4681                	li	a3,0
 60e:	4629                	li	a2,10
 610:	000ba583          	lw	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	defff0ef          	jal	404 <printint>
 61a:	8ba6                	mv	s7,s1
      state = 0;
 61c:	4981                	li	s3,0
 61e:	b5d9                	j	4e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 620:	008b8493          	addi	s1,s7,8
 624:	4681                	li	a3,0
 626:	4629                	li	a2,10
 628:	000ba583          	lw	a1,0(s7)
 62c:	855a                	mv	a0,s6
 62e:	dd7ff0ef          	jal	404 <printint>
        i += 1;
 632:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 634:	8ba6                	mv	s7,s1
      state = 0;
 636:	4981                	li	s3,0
        i += 1;
 638:	b575                	j	4e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 63a:	008b8493          	addi	s1,s7,8
 63e:	4681                	li	a3,0
 640:	4629                	li	a2,10
 642:	000ba583          	lw	a1,0(s7)
 646:	855a                	mv	a0,s6
 648:	dbdff0ef          	jal	404 <printint>
        i += 2;
 64c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 64e:	8ba6                	mv	s7,s1
      state = 0;
 650:	4981                	li	s3,0
        i += 2;
 652:	bd49                	j	4e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 654:	008b8493          	addi	s1,s7,8
 658:	4681                	li	a3,0
 65a:	4641                	li	a2,16
 65c:	000ba583          	lw	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	da3ff0ef          	jal	404 <printint>
 666:	8ba6                	mv	s7,s1
      state = 0;
 668:	4981                	li	s3,0
 66a:	bdad                	j	4e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 66c:	008b8493          	addi	s1,s7,8
 670:	4681                	li	a3,0
 672:	4641                	li	a2,16
 674:	000ba583          	lw	a1,0(s7)
 678:	855a                	mv	a0,s6
 67a:	d8bff0ef          	jal	404 <printint>
        i += 1;
 67e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 680:	8ba6                	mv	s7,s1
      state = 0;
 682:	4981                	li	s3,0
        i += 1;
 684:	b585                	j	4e4 <vprintf+0x4a>
 686:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 688:	008b8d13          	addi	s10,s7,8
 68c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 690:	03000593          	li	a1,48
 694:	855a                	mv	a0,s6
 696:	d51ff0ef          	jal	3e6 <putc>
  putc(fd, 'x');
 69a:	07800593          	li	a1,120
 69e:	855a                	mv	a0,s6
 6a0:	d47ff0ef          	jal	3e6 <putc>
 6a4:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a6:	00000b97          	auipc	s7,0x0
 6aa:	2e2b8b93          	addi	s7,s7,738 # 988 <digits>
 6ae:	03c9d793          	srli	a5,s3,0x3c
 6b2:	97de                	add	a5,a5,s7
 6b4:	0007c583          	lbu	a1,0(a5)
 6b8:	855a                	mv	a0,s6
 6ba:	d2dff0ef          	jal	3e6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6be:	0992                	slli	s3,s3,0x4
 6c0:	34fd                	addiw	s1,s1,-1
 6c2:	f4f5                	bnez	s1,6ae <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 6c4:	8bea                	mv	s7,s10
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	6d02                	ld	s10,0(sp)
 6ca:	bd29                	j	4e4 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6cc:	008b8993          	addi	s3,s7,8
 6d0:	000bb483          	ld	s1,0(s7)
 6d4:	cc91                	beqz	s1,6f0 <vprintf+0x256>
        for(; *s; s++)
 6d6:	0004c583          	lbu	a1,0(s1)
 6da:	c195                	beqz	a1,6fe <vprintf+0x264>
          putc(fd, *s);
 6dc:	855a                	mv	a0,s6
 6de:	d09ff0ef          	jal	3e6 <putc>
        for(; *s; s++)
 6e2:	0485                	addi	s1,s1,1
 6e4:	0004c583          	lbu	a1,0(s1)
 6e8:	f9f5                	bnez	a1,6dc <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 6ea:	8bce                	mv	s7,s3
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bbdd                	j	4e4 <vprintf+0x4a>
          s = "(null)";
 6f0:	00000497          	auipc	s1,0x0
 6f4:	29048493          	addi	s1,s1,656 # 980 <malloc+0x180>
        for(; *s; s++)
 6f8:	02800593          	li	a1,40
 6fc:	b7c5                	j	6dc <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 6fe:	8bce                	mv	s7,s3
      state = 0;
 700:	4981                	li	s3,0
 702:	b3cd                	j	4e4 <vprintf+0x4a>
 704:	6906                	ld	s2,64(sp)
 706:	79e2                	ld	s3,56(sp)
 708:	7a42                	ld	s4,48(sp)
 70a:	7aa2                	ld	s5,40(sp)
 70c:	7b02                	ld	s6,32(sp)
 70e:	6be2                	ld	s7,24(sp)
 710:	6c42                	ld	s8,16(sp)
 712:	6ca2                	ld	s9,8(sp)
    }
  }
}
 714:	60e6                	ld	ra,88(sp)
 716:	6446                	ld	s0,80(sp)
 718:	64a6                	ld	s1,72(sp)
 71a:	6125                	addi	sp,sp,96
 71c:	8082                	ret

000000000000071e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 71e:	715d                	addi	sp,sp,-80
 720:	ec06                	sd	ra,24(sp)
 722:	e822                	sd	s0,16(sp)
 724:	1000                	addi	s0,sp,32
 726:	e010                	sd	a2,0(s0)
 728:	e414                	sd	a3,8(s0)
 72a:	e818                	sd	a4,16(s0)
 72c:	ec1c                	sd	a5,24(s0)
 72e:	03043023          	sd	a6,32(s0)
 732:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 736:	8622                	mv	a2,s0
 738:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 73c:	d5fff0ef          	jal	49a <vprintf>
}
 740:	60e2                	ld	ra,24(sp)
 742:	6442                	ld	s0,16(sp)
 744:	6161                	addi	sp,sp,80
 746:	8082                	ret

0000000000000748 <printf>:

void
printf(const char *fmt, ...)
{
 748:	711d                	addi	sp,sp,-96
 74a:	ec06                	sd	ra,24(sp)
 74c:	e822                	sd	s0,16(sp)
 74e:	1000                	addi	s0,sp,32
 750:	e40c                	sd	a1,8(s0)
 752:	e810                	sd	a2,16(s0)
 754:	ec14                	sd	a3,24(s0)
 756:	f018                	sd	a4,32(s0)
 758:	f41c                	sd	a5,40(s0)
 75a:	03043823          	sd	a6,48(s0)
 75e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 762:	00840613          	addi	a2,s0,8
 766:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 76a:	85aa                	mv	a1,a0
 76c:	4505                	li	a0,1
 76e:	d2dff0ef          	jal	49a <vprintf>
}
 772:	60e2                	ld	ra,24(sp)
 774:	6442                	ld	s0,16(sp)
 776:	6125                	addi	sp,sp,96
 778:	8082                	ret

000000000000077a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77a:	1141                	addi	sp,sp,-16
 77c:	e406                	sd	ra,8(sp)
 77e:	e022                	sd	s0,0(sp)
 780:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 782:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 786:	00001797          	auipc	a5,0x1
 78a:	87a7b783          	ld	a5,-1926(a5) # 1000 <freep>
 78e:	a02d                	j	7b8 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 790:	4618                	lw	a4,8(a2)
 792:	9f2d                	addw	a4,a4,a1
 794:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 798:	6398                	ld	a4,0(a5)
 79a:	6310                	ld	a2,0(a4)
 79c:	a83d                	j	7da <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 79e:	ff852703          	lw	a4,-8(a0)
 7a2:	9f31                	addw	a4,a4,a2
 7a4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7a6:	ff053683          	ld	a3,-16(a0)
 7aa:	a091                	j	7ee <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ac:	6398                	ld	a4,0(a5)
 7ae:	00e7e463          	bltu	a5,a4,7b6 <free+0x3c>
 7b2:	00e6ea63          	bltu	a3,a4,7c6 <free+0x4c>
{
 7b6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b8:	fed7fae3          	bgeu	a5,a3,7ac <free+0x32>
 7bc:	6398                	ld	a4,0(a5)
 7be:	00e6e463          	bltu	a3,a4,7c6 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c2:	fee7eae3          	bltu	a5,a4,7b6 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7c6:	ff852583          	lw	a1,-8(a0)
 7ca:	6390                	ld	a2,0(a5)
 7cc:	02059813          	slli	a6,a1,0x20
 7d0:	01c85713          	srli	a4,a6,0x1c
 7d4:	9736                	add	a4,a4,a3
 7d6:	fae60de3          	beq	a2,a4,790 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 7da:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7de:	4790                	lw	a2,8(a5)
 7e0:	02061593          	slli	a1,a2,0x20
 7e4:	01c5d713          	srli	a4,a1,0x1c
 7e8:	973e                	add	a4,a4,a5
 7ea:	fae68ae3          	beq	a3,a4,79e <free+0x24>
    p->s.ptr = bp->s.ptr;
 7ee:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7f0:	00001717          	auipc	a4,0x1
 7f4:	80f73823          	sd	a5,-2032(a4) # 1000 <freep>
}
 7f8:	60a2                	ld	ra,8(sp)
 7fa:	6402                	ld	s0,0(sp)
 7fc:	0141                	addi	sp,sp,16
 7fe:	8082                	ret

0000000000000800 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 800:	7139                	addi	sp,sp,-64
 802:	fc06                	sd	ra,56(sp)
 804:	f822                	sd	s0,48(sp)
 806:	f04a                	sd	s2,32(sp)
 808:	ec4e                	sd	s3,24(sp)
 80a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80c:	02051993          	slli	s3,a0,0x20
 810:	0209d993          	srli	s3,s3,0x20
 814:	09bd                	addi	s3,s3,15
 816:	0049d993          	srli	s3,s3,0x4
 81a:	2985                	addiw	s3,s3,1
 81c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 81e:	00000517          	auipc	a0,0x0
 822:	7e253503          	ld	a0,2018(a0) # 1000 <freep>
 826:	c905                	beqz	a0,856 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 828:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82a:	4798                	lw	a4,8(a5)
 82c:	09377663          	bgeu	a4,s3,8b8 <malloc+0xb8>
 830:	f426                	sd	s1,40(sp)
 832:	e852                	sd	s4,16(sp)
 834:	e456                	sd	s5,8(sp)
 836:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 838:	8a4e                	mv	s4,s3
 83a:	6705                	lui	a4,0x1
 83c:	00e9f363          	bgeu	s3,a4,842 <malloc+0x42>
 840:	6a05                	lui	s4,0x1
 842:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 846:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84a:	00000497          	auipc	s1,0x0
 84e:	7b648493          	addi	s1,s1,1974 # 1000 <freep>
  if(p == (char*)-1)
 852:	5afd                	li	s5,-1
 854:	a83d                	j	892 <malloc+0x92>
 856:	f426                	sd	s1,40(sp)
 858:	e852                	sd	s4,16(sp)
 85a:	e456                	sd	s5,8(sp)
 85c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 85e:	00000797          	auipc	a5,0x0
 862:	7b278793          	addi	a5,a5,1970 # 1010 <base>
 866:	00000717          	auipc	a4,0x0
 86a:	78f73d23          	sd	a5,1946(a4) # 1000 <freep>
 86e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 870:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 874:	b7d1                	j	838 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 876:	6398                	ld	a4,0(a5)
 878:	e118                	sd	a4,0(a0)
 87a:	a899                	j	8d0 <malloc+0xd0>
  hp->s.size = nu;
 87c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 880:	0541                	addi	a0,a0,16
 882:	ef9ff0ef          	jal	77a <free>
  return freep;
 886:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 888:	c125                	beqz	a0,8e8 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88c:	4798                	lw	a4,8(a5)
 88e:	03277163          	bgeu	a4,s2,8b0 <malloc+0xb0>
    if(p == freep)
 892:	6098                	ld	a4,0(s1)
 894:	853e                	mv	a0,a5
 896:	fef71ae3          	bne	a4,a5,88a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 89a:	8552                	mv	a0,s4
 89c:	b1bff0ef          	jal	3b6 <sbrk>
  if(p == (char*)-1)
 8a0:	fd551ee3          	bne	a0,s5,87c <malloc+0x7c>
        return 0;
 8a4:	4501                	li	a0,0
 8a6:	74a2                	ld	s1,40(sp)
 8a8:	6a42                	ld	s4,16(sp)
 8aa:	6aa2                	ld	s5,8(sp)
 8ac:	6b02                	ld	s6,0(sp)
 8ae:	a03d                	j	8dc <malloc+0xdc>
 8b0:	74a2                	ld	s1,40(sp)
 8b2:	6a42                	ld	s4,16(sp)
 8b4:	6aa2                	ld	s5,8(sp)
 8b6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8b8:	fae90fe3          	beq	s2,a4,876 <malloc+0x76>
        p->s.size -= nunits;
 8bc:	4137073b          	subw	a4,a4,s3
 8c0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c2:	02071693          	slli	a3,a4,0x20
 8c6:	01c6d713          	srli	a4,a3,0x1c
 8ca:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8cc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d0:	00000717          	auipc	a4,0x0
 8d4:	72a73823          	sd	a0,1840(a4) # 1000 <freep>
      return (void*)(p + 1);
 8d8:	01078513          	addi	a0,a5,16
  }
}
 8dc:	70e2                	ld	ra,56(sp)
 8de:	7442                	ld	s0,48(sp)
 8e0:	7902                	ld	s2,32(sp)
 8e2:	69e2                	ld	s3,24(sp)
 8e4:	6121                	addi	sp,sp,64
 8e6:	8082                	ret
 8e8:	74a2                	ld	s1,40(sp)
 8ea:	6a42                	ld	s4,16(sp)
 8ec:	6aa2                	ld	s5,8(sp)
 8ee:	6b02                	ld	s6,0(sp)
 8f0:	b7f5                	j	8dc <malloc+0xdc>
