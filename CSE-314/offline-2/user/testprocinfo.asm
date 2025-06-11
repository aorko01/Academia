
user/_testprocinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "./kernel/param.h"
// #include "./kernel/pstat.h"
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
  14:	3c8000ef          	jal	3dc <getpinfo>
    
    if (ret != 0)
  18:	c105                	beqz	a0,38 <main+0x38>
  1a:	60913c23          	sd	s1,1560(sp)
  1e:	61213823          	sd	s2,1552(sp)
  22:	61313423          	sd	s3,1544(sp)
    {
        printf("[testprocinfo] getpinfo failed\n");
  26:	00001517          	auipc	a0,0x1
  2a:	8ca50513          	addi	a0,a0,-1846 # 8f0 <malloc+0xf2>
  2e:	718000ef          	jal	746 <printf>
        exit(1);
  32:	4505                	li	a0,1
  34:	2f8000ef          	jal	32c <exit>
  38:	60913c23          	sd	s1,1560(sp)
  3c:	61213823          	sd	s2,1552(sp)
  40:	61313423          	sd	s3,1544(sp)
    }
    
    // Print header row matching the expected format
    printf("PID\t\t|\tIn Use\t\t|\tinQ\t|\tOriginal Tickets\t|\tCurrent Tickets\t|\tTime Slices\n");
  44:	00001517          	auipc	a0,0x1
  48:	8cc50513          	addi	a0,a0,-1844 # 910 <malloc+0x112>
  4c:	6fa000ef          	jal	746 <printf>
    
    // Print processes that are in use
    for (int i = 0; i < NPROC; i++)
  50:	9d040493          	addi	s1,s0,-1584
  54:	ad040913          	addi	s2,s0,-1328
    {
        if (st.inuse[i])
        {
            printf("%d\t\t|\t%d\t\t|\t%d\t|\t%d\t\t\t|\t%d\t\t|\t%d\n",
  58:	00001997          	auipc	s3,0x1
  5c:	90898993          	addi	s3,s3,-1784 # 960 <malloc+0x162>
  60:	a021                	j	68 <main+0x68>
    for (int i = 0; i < NPROC; i++)
  62:	0491                	addi	s1,s1,4
  64:	03248263          	beq	s1,s2,88 <main+0x88>
        if (st.inuse[i])
  68:	1004a603          	lw	a2,256(s1)
  6c:	da7d                	beqz	a2,62 <main+0x62>
            printf("%d\t\t|\t%d\t\t|\t%d\t|\t%d\t\t\t|\t%d\t\t|\t%d\n",
  6e:	5004a803          	lw	a6,1280(s1)
  72:	4004a783          	lw	a5,1024(s1)
  76:	3004a703          	lw	a4,768(s1)
  7a:	2004a683          	lw	a3,512(s1)
  7e:	408c                	lw	a1,0(s1)
  80:	854e                	mv	a0,s3
  82:	6c4000ef          	jal	746 <printf>
  86:	bff1                	j	62 <main+0x62>
                st.tickets_current[i],
                st.time_slices[i]);
        }
    }
    
    exit(0);
  88:	4501                	li	a0,0
  8a:	2a2000ef          	jal	32c <exit>

000000000000008e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  8e:	1141                	addi	sp,sp,-16
  90:	e406                	sd	ra,8(sp)
  92:	e022                	sd	s0,0(sp)
  94:	0800                	addi	s0,sp,16
  extern int main();
  main();
  96:	f6bff0ef          	jal	0 <main>
  exit(0);
  9a:	4501                	li	a0,0
  9c:	290000ef          	jal	32c <exit>

00000000000000a0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e406                	sd	ra,8(sp)
  a4:	e022                	sd	s0,0(sp)
  a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a8:	87aa                	mv	a5,a0
  aa:	0585                	addi	a1,a1,1
  ac:	0785                	addi	a5,a5,1
  ae:	fff5c703          	lbu	a4,-1(a1)
  b2:	fee78fa3          	sb	a4,-1(a5)
  b6:	fb75                	bnez	a4,aa <strcpy+0xa>
    ;
  return os;
}
  b8:	60a2                	ld	ra,8(sp)
  ba:	6402                	ld	s0,0(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e406                	sd	ra,8(sp)
  c4:	e022                	sd	s0,0(sp)
  c6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cb91                	beqz	a5,e0 <strcmp+0x20>
  ce:	0005c703          	lbu	a4,0(a1)
  d2:	00f71763          	bne	a4,a5,e0 <strcmp+0x20>
    p++, q++;
  d6:	0505                	addi	a0,a0,1
  d8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  da:	00054783          	lbu	a5,0(a0)
  de:	fbe5                	bnez	a5,ce <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  e0:	0005c503          	lbu	a0,0(a1)
}
  e4:	40a7853b          	subw	a0,a5,a0
  e8:	60a2                	ld	ra,8(sp)
  ea:	6402                	ld	s0,0(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e406                	sd	ra,8(sp)
  f4:	e022                	sd	s0,0(sp)
  f6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cf99                	beqz	a5,11a <strlen+0x2a>
  fe:	0505                	addi	a0,a0,1
 100:	87aa                	mv	a5,a0
 102:	86be                	mv	a3,a5
 104:	0785                	addi	a5,a5,1
 106:	fff7c703          	lbu	a4,-1(a5)
 10a:	ff65                	bnez	a4,102 <strlen+0x12>
 10c:	40a6853b          	subw	a0,a3,a0
 110:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 112:	60a2                	ld	ra,8(sp)
 114:	6402                	ld	s0,0(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret
  for(n = 0; s[n]; n++)
 11a:	4501                	li	a0,0
 11c:	bfdd                	j	112 <strlen+0x22>

000000000000011e <memset>:

void*
memset(void *dst, int c, uint n)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 126:	ca19                	beqz	a2,13c <memset+0x1e>
 128:	87aa                	mv	a5,a0
 12a:	1602                	slli	a2,a2,0x20
 12c:	9201                	srli	a2,a2,0x20
 12e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 132:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 136:	0785                	addi	a5,a5,1
 138:	fee79de3          	bne	a5,a4,132 <memset+0x14>
  }
  return dst;
}
 13c:	60a2                	ld	ra,8(sp)
 13e:	6402                	ld	s0,0(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret

0000000000000144 <strchr>:

char*
strchr(const char *s, char c)
{
 144:	1141                	addi	sp,sp,-16
 146:	e406                	sd	ra,8(sp)
 148:	e022                	sd	s0,0(sp)
 14a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 14c:	00054783          	lbu	a5,0(a0)
 150:	cf81                	beqz	a5,168 <strchr+0x24>
    if(*s == c)
 152:	00f58763          	beq	a1,a5,160 <strchr+0x1c>
  for(; *s; s++)
 156:	0505                	addi	a0,a0,1
 158:	00054783          	lbu	a5,0(a0)
 15c:	fbfd                	bnez	a5,152 <strchr+0xe>
      return (char*)s;
  return 0;
 15e:	4501                	li	a0,0
}
 160:	60a2                	ld	ra,8(sp)
 162:	6402                	ld	s0,0(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret
  return 0;
 168:	4501                	li	a0,0
 16a:	bfdd                	j	160 <strchr+0x1c>

000000000000016c <gets>:

char*
gets(char *buf, int max)
{
 16c:	7159                	addi	sp,sp,-112
 16e:	f486                	sd	ra,104(sp)
 170:	f0a2                	sd	s0,96(sp)
 172:	eca6                	sd	s1,88(sp)
 174:	e8ca                	sd	s2,80(sp)
 176:	e4ce                	sd	s3,72(sp)
 178:	e0d2                	sd	s4,64(sp)
 17a:	fc56                	sd	s5,56(sp)
 17c:	f85a                	sd	s6,48(sp)
 17e:	f45e                	sd	s7,40(sp)
 180:	f062                	sd	s8,32(sp)
 182:	ec66                	sd	s9,24(sp)
 184:	e86a                	sd	s10,16(sp)
 186:	1880                	addi	s0,sp,112
 188:	8caa                	mv	s9,a0
 18a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18c:	892a                	mv	s2,a0
 18e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 190:	f9f40b13          	addi	s6,s0,-97
 194:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 196:	4ba9                	li	s7,10
 198:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 19a:	8d26                	mv	s10,s1
 19c:	0014899b          	addiw	s3,s1,1
 1a0:	84ce                	mv	s1,s3
 1a2:	0349d563          	bge	s3,s4,1cc <gets+0x60>
    cc = read(0, &c, 1);
 1a6:	8656                	mv	a2,s5
 1a8:	85da                	mv	a1,s6
 1aa:	4501                	li	a0,0
 1ac:	198000ef          	jal	344 <read>
    if(cc < 1)
 1b0:	00a05e63          	blez	a0,1cc <gets+0x60>
    buf[i++] = c;
 1b4:	f9f44783          	lbu	a5,-97(s0)
 1b8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1bc:	01778763          	beq	a5,s7,1ca <gets+0x5e>
 1c0:	0905                	addi	s2,s2,1
 1c2:	fd879ce3          	bne	a5,s8,19a <gets+0x2e>
    buf[i++] = c;
 1c6:	8d4e                	mv	s10,s3
 1c8:	a011                	j	1cc <gets+0x60>
 1ca:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 1cc:	9d66                	add	s10,s10,s9
 1ce:	000d0023          	sb	zero,0(s10)
  return buf;
}
 1d2:	8566                	mv	a0,s9
 1d4:	70a6                	ld	ra,104(sp)
 1d6:	7406                	ld	s0,96(sp)
 1d8:	64e6                	ld	s1,88(sp)
 1da:	6946                	ld	s2,80(sp)
 1dc:	69a6                	ld	s3,72(sp)
 1de:	6a06                	ld	s4,64(sp)
 1e0:	7ae2                	ld	s5,56(sp)
 1e2:	7b42                	ld	s6,48(sp)
 1e4:	7ba2                	ld	s7,40(sp)
 1e6:	7c02                	ld	s8,32(sp)
 1e8:	6ce2                	ld	s9,24(sp)
 1ea:	6d42                	ld	s10,16(sp)
 1ec:	6165                	addi	sp,sp,112
 1ee:	8082                	ret

00000000000001f0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f0:	1101                	addi	sp,sp,-32
 1f2:	ec06                	sd	ra,24(sp)
 1f4:	e822                	sd	s0,16(sp)
 1f6:	e04a                	sd	s2,0(sp)
 1f8:	1000                	addi	s0,sp,32
 1fa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fc:	4581                	li	a1,0
 1fe:	16e000ef          	jal	36c <open>
  if(fd < 0)
 202:	02054263          	bltz	a0,226 <stat+0x36>
 206:	e426                	sd	s1,8(sp)
 208:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20a:	85ca                	mv	a1,s2
 20c:	178000ef          	jal	384 <fstat>
 210:	892a                	mv	s2,a0
  close(fd);
 212:	8526                	mv	a0,s1
 214:	140000ef          	jal	354 <close>
  return r;
 218:	64a2                	ld	s1,8(sp)
}
 21a:	854a                	mv	a0,s2
 21c:	60e2                	ld	ra,24(sp)
 21e:	6442                	ld	s0,16(sp)
 220:	6902                	ld	s2,0(sp)
 222:	6105                	addi	sp,sp,32
 224:	8082                	ret
    return -1;
 226:	597d                	li	s2,-1
 228:	bfcd                	j	21a <stat+0x2a>

000000000000022a <atoi>:

int
atoi(const char *s)
{
 22a:	1141                	addi	sp,sp,-16
 22c:	e406                	sd	ra,8(sp)
 22e:	e022                	sd	s0,0(sp)
 230:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 232:	00054683          	lbu	a3,0(a0)
 236:	fd06879b          	addiw	a5,a3,-48
 23a:	0ff7f793          	zext.b	a5,a5
 23e:	4625                	li	a2,9
 240:	02f66963          	bltu	a2,a5,272 <atoi+0x48>
 244:	872a                	mv	a4,a0
  n = 0;
 246:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 248:	0705                	addi	a4,a4,1
 24a:	0025179b          	slliw	a5,a0,0x2
 24e:	9fa9                	addw	a5,a5,a0
 250:	0017979b          	slliw	a5,a5,0x1
 254:	9fb5                	addw	a5,a5,a3
 256:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25a:	00074683          	lbu	a3,0(a4)
 25e:	fd06879b          	addiw	a5,a3,-48
 262:	0ff7f793          	zext.b	a5,a5
 266:	fef671e3          	bgeu	a2,a5,248 <atoi+0x1e>
  return n;
}
 26a:	60a2                	ld	ra,8(sp)
 26c:	6402                	ld	s0,0(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  n = 0;
 272:	4501                	li	a0,0
 274:	bfdd                	j	26a <atoi+0x40>

0000000000000276 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 276:	1141                	addi	sp,sp,-16
 278:	e406                	sd	ra,8(sp)
 27a:	e022                	sd	s0,0(sp)
 27c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 27e:	02b57563          	bgeu	a0,a1,2a8 <memmove+0x32>
    while(n-- > 0)
 282:	00c05f63          	blez	a2,2a0 <memmove+0x2a>
 286:	1602                	slli	a2,a2,0x20
 288:	9201                	srli	a2,a2,0x20
 28a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 28e:	872a                	mv	a4,a0
      *dst++ = *src++;
 290:	0585                	addi	a1,a1,1
 292:	0705                	addi	a4,a4,1
 294:	fff5c683          	lbu	a3,-1(a1)
 298:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29c:	fee79ae3          	bne	a5,a4,290 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a0:	60a2                	ld	ra,8(sp)
 2a2:	6402                	ld	s0,0(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret
    dst += n;
 2a8:	00c50733          	add	a4,a0,a2
    src += n;
 2ac:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ae:	fec059e3          	blez	a2,2a0 <memmove+0x2a>
 2b2:	fff6079b          	addiw	a5,a2,-1
 2b6:	1782                	slli	a5,a5,0x20
 2b8:	9381                	srli	a5,a5,0x20
 2ba:	fff7c793          	not	a5,a5
 2be:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c0:	15fd                	addi	a1,a1,-1
 2c2:	177d                	addi	a4,a4,-1
 2c4:	0005c683          	lbu	a3,0(a1)
 2c8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2cc:	fef71ae3          	bne	a4,a5,2c0 <memmove+0x4a>
 2d0:	bfc1                	j	2a0 <memmove+0x2a>

00000000000002d2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2da:	ca0d                	beqz	a2,30c <memcmp+0x3a>
 2dc:	fff6069b          	addiw	a3,a2,-1
 2e0:	1682                	slli	a3,a3,0x20
 2e2:	9281                	srli	a3,a3,0x20
 2e4:	0685                	addi	a3,a3,1
 2e6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e8:	00054783          	lbu	a5,0(a0)
 2ec:	0005c703          	lbu	a4,0(a1)
 2f0:	00e79863          	bne	a5,a4,300 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 2f4:	0505                	addi	a0,a0,1
    p2++;
 2f6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f8:	fed518e3          	bne	a0,a3,2e8 <memcmp+0x16>
  }
  return 0;
 2fc:	4501                	li	a0,0
 2fe:	a019                	j	304 <memcmp+0x32>
      return *p1 - *p2;
 300:	40e7853b          	subw	a0,a5,a4
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  return 0;
 30c:	4501                	li	a0,0
 30e:	bfdd                	j	304 <memcmp+0x32>

0000000000000310 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 318:	f5fff0ef          	jal	276 <memmove>
}
 31c:	60a2                	ld	ra,8(sp)
 31e:	6402                	ld	s0,0(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 324:	4885                	li	a7,1
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <exit>:
.global exit
exit:
 li a7, SYS_exit
 32c:	4889                	li	a7,2
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <wait>:
.global wait
wait:
 li a7, SYS_wait
 334:	488d                	li	a7,3
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33c:	4891                	li	a7,4
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <read>:
.global read
read:
 li a7, SYS_read
 344:	4895                	li	a7,5
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <write>:
.global write
write:
 li a7, SYS_write
 34c:	48c1                	li	a7,16
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <close>:
.global close
close:
 li a7, SYS_close
 354:	48d5                	li	a7,21
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <kill>:
.global kill
kill:
 li a7, SYS_kill
 35c:	4899                	li	a7,6
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <exec>:
.global exec
exec:
 li a7, SYS_exec
 364:	489d                	li	a7,7
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <open>:
.global open
open:
 li a7, SYS_open
 36c:	48bd                	li	a7,15
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 374:	48c5                	li	a7,17
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 37c:	48c9                	li	a7,18
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 384:	48a1                	li	a7,8
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <link>:
.global link
link:
 li a7, SYS_link
 38c:	48cd                	li	a7,19
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 394:	48d1                	li	a7,20
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 39c:	48a5                	li	a7,9
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a4:	48a9                	li	a7,10
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ac:	48ad                	li	a7,11
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b4:	48b1                	li	a7,12
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3bc:	48b5                	li	a7,13
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c4:	48b9                	li	a7,14
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <history>:
.global history
history:
 li a7, SYS_history
 3cc:	48d9                	li	a7,22
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3d4:	48dd                	li	a7,23
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 3dc:	48dd                	li	a7,23
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e4:	1101                	addi	sp,sp,-32
 3e6:	ec06                	sd	ra,24(sp)
 3e8:	e822                	sd	s0,16(sp)
 3ea:	1000                	addi	s0,sp,32
 3ec:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f0:	4605                	li	a2,1
 3f2:	fef40593          	addi	a1,s0,-17
 3f6:	f57ff0ef          	jal	34c <write>
}
 3fa:	60e2                	ld	ra,24(sp)
 3fc:	6442                	ld	s0,16(sp)
 3fe:	6105                	addi	sp,sp,32
 400:	8082                	ret

0000000000000402 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 402:	7139                	addi	sp,sp,-64
 404:	fc06                	sd	ra,56(sp)
 406:	f822                	sd	s0,48(sp)
 408:	f426                	sd	s1,40(sp)
 40a:	f04a                	sd	s2,32(sp)
 40c:	ec4e                	sd	s3,24(sp)
 40e:	0080                	addi	s0,sp,64
 410:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 412:	c299                	beqz	a3,418 <printint+0x16>
 414:	0605ce63          	bltz	a1,490 <printint+0x8e>
  neg = 0;
 418:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 41a:	fc040313          	addi	t1,s0,-64
  neg = 0;
 41e:	869a                	mv	a3,t1
  i = 0;
 420:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 422:	00000817          	auipc	a6,0x0
 426:	56e80813          	addi	a6,a6,1390 # 990 <digits>
 42a:	88be                	mv	a7,a5
 42c:	0017851b          	addiw	a0,a5,1
 430:	87aa                	mv	a5,a0
 432:	02c5f73b          	remuw	a4,a1,a2
 436:	1702                	slli	a4,a4,0x20
 438:	9301                	srli	a4,a4,0x20
 43a:	9742                	add	a4,a4,a6
 43c:	00074703          	lbu	a4,0(a4)
 440:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 444:	872e                	mv	a4,a1
 446:	02c5d5bb          	divuw	a1,a1,a2
 44a:	0685                	addi	a3,a3,1
 44c:	fcc77fe3          	bgeu	a4,a2,42a <printint+0x28>
  if(neg)
 450:	000e0c63          	beqz	t3,468 <printint+0x66>
    buf[i++] = '-';
 454:	fd050793          	addi	a5,a0,-48
 458:	00878533          	add	a0,a5,s0
 45c:	02d00793          	li	a5,45
 460:	fef50823          	sb	a5,-16(a0)
 464:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 468:	fff7899b          	addiw	s3,a5,-1
 46c:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 470:	fff4c583          	lbu	a1,-1(s1)
 474:	854a                	mv	a0,s2
 476:	f6fff0ef          	jal	3e4 <putc>
  while(--i >= 0)
 47a:	39fd                	addiw	s3,s3,-1
 47c:	14fd                	addi	s1,s1,-1
 47e:	fe09d9e3          	bgez	s3,470 <printint+0x6e>
}
 482:	70e2                	ld	ra,56(sp)
 484:	7442                	ld	s0,48(sp)
 486:	74a2                	ld	s1,40(sp)
 488:	7902                	ld	s2,32(sp)
 48a:	69e2                	ld	s3,24(sp)
 48c:	6121                	addi	sp,sp,64
 48e:	8082                	ret
    x = -xx;
 490:	40b005bb          	negw	a1,a1
    neg = 1;
 494:	4e05                	li	t3,1
    x = -xx;
 496:	b751                	j	41a <printint+0x18>

0000000000000498 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 498:	711d                	addi	sp,sp,-96
 49a:	ec86                	sd	ra,88(sp)
 49c:	e8a2                	sd	s0,80(sp)
 49e:	e4a6                	sd	s1,72(sp)
 4a0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a2:	0005c483          	lbu	s1,0(a1)
 4a6:	26048663          	beqz	s1,712 <vprintf+0x27a>
 4aa:	e0ca                	sd	s2,64(sp)
 4ac:	fc4e                	sd	s3,56(sp)
 4ae:	f852                	sd	s4,48(sp)
 4b0:	f456                	sd	s5,40(sp)
 4b2:	f05a                	sd	s6,32(sp)
 4b4:	ec5e                	sd	s7,24(sp)
 4b6:	e862                	sd	s8,16(sp)
 4b8:	e466                	sd	s9,8(sp)
 4ba:	8b2a                	mv	s6,a0
 4bc:	8a2e                	mv	s4,a1
 4be:	8bb2                	mv	s7,a2
  state = 0;
 4c0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4c2:	4901                	li	s2,0
 4c4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4c6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4ca:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4ce:	06c00c93          	li	s9,108
 4d2:	a00d                	j	4f4 <vprintf+0x5c>
        putc(fd, c0);
 4d4:	85a6                	mv	a1,s1
 4d6:	855a                	mv	a0,s6
 4d8:	f0dff0ef          	jal	3e4 <putc>
 4dc:	a019                	j	4e2 <vprintf+0x4a>
    } else if(state == '%'){
 4de:	03598363          	beq	s3,s5,504 <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 4e2:	0019079b          	addiw	a5,s2,1
 4e6:	893e                	mv	s2,a5
 4e8:	873e                	mv	a4,a5
 4ea:	97d2                	add	a5,a5,s4
 4ec:	0007c483          	lbu	s1,0(a5)
 4f0:	20048963          	beqz	s1,702 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 4f4:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4f8:	fe0993e3          	bnez	s3,4de <vprintf+0x46>
      if(c0 == '%'){
 4fc:	fd579ce3          	bne	a5,s5,4d4 <vprintf+0x3c>
        state = '%';
 500:	89be                	mv	s3,a5
 502:	b7c5                	j	4e2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 504:	00ea06b3          	add	a3,s4,a4
 508:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 50c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 50e:	c681                	beqz	a3,516 <vprintf+0x7e>
 510:	9752                	add	a4,a4,s4
 512:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 516:	03878e63          	beq	a5,s8,552 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 51a:	05978863          	beq	a5,s9,56a <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 51e:	07500713          	li	a4,117
 522:	0ee78263          	beq	a5,a4,606 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 526:	07800713          	li	a4,120
 52a:	12e78463          	beq	a5,a4,652 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 52e:	07000713          	li	a4,112
 532:	14e78963          	beq	a5,a4,684 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 536:	07300713          	li	a4,115
 53a:	18e78863          	beq	a5,a4,6ca <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 53e:	02500713          	li	a4,37
 542:	04e79463          	bne	a5,a4,58a <vprintf+0xf2>
        putc(fd, '%');
 546:	85ba                	mv	a1,a4
 548:	855a                	mv	a0,s6
 54a:	e9bff0ef          	jal	3e4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 54e:	4981                	li	s3,0
 550:	bf49                	j	4e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 552:	008b8493          	addi	s1,s7,8
 556:	4685                	li	a3,1
 558:	4629                	li	a2,10
 55a:	000ba583          	lw	a1,0(s7)
 55e:	855a                	mv	a0,s6
 560:	ea3ff0ef          	jal	402 <printint>
 564:	8ba6                	mv	s7,s1
      state = 0;
 566:	4981                	li	s3,0
 568:	bfad                	j	4e2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 56a:	06400793          	li	a5,100
 56e:	02f68963          	beq	a3,a5,5a0 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 572:	06c00793          	li	a5,108
 576:	04f68263          	beq	a3,a5,5ba <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 57a:	07500793          	li	a5,117
 57e:	0af68063          	beq	a3,a5,61e <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 582:	07800793          	li	a5,120
 586:	0ef68263          	beq	a3,a5,66a <vprintf+0x1d2>
        putc(fd, '%');
 58a:	02500593          	li	a1,37
 58e:	855a                	mv	a0,s6
 590:	e55ff0ef          	jal	3e4 <putc>
        putc(fd, c0);
 594:	85a6                	mv	a1,s1
 596:	855a                	mv	a0,s6
 598:	e4dff0ef          	jal	3e4 <putc>
      state = 0;
 59c:	4981                	li	s3,0
 59e:	b791                	j	4e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a0:	008b8493          	addi	s1,s7,8
 5a4:	4685                	li	a3,1
 5a6:	4629                	li	a2,10
 5a8:	000ba583          	lw	a1,0(s7)
 5ac:	855a                	mv	a0,s6
 5ae:	e55ff0ef          	jal	402 <printint>
        i += 1;
 5b2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b4:	8ba6                	mv	s7,s1
      state = 0;
 5b6:	4981                	li	s3,0
        i += 1;
 5b8:	b72d                	j	4e2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ba:	06400793          	li	a5,100
 5be:	02f60763          	beq	a2,a5,5ec <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5c2:	07500793          	li	a5,117
 5c6:	06f60963          	beq	a2,a5,638 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5ca:	07800793          	li	a5,120
 5ce:	faf61ee3          	bne	a2,a5,58a <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d2:	008b8493          	addi	s1,s7,8
 5d6:	4681                	li	a3,0
 5d8:	4641                	li	a2,16
 5da:	000ba583          	lw	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	e23ff0ef          	jal	402 <printint>
        i += 2;
 5e4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e6:	8ba6                	mv	s7,s1
      state = 0;
 5e8:	4981                	li	s3,0
        i += 2;
 5ea:	bde5                	j	4e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ec:	008b8493          	addi	s1,s7,8
 5f0:	4685                	li	a3,1
 5f2:	4629                	li	a2,10
 5f4:	000ba583          	lw	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	e09ff0ef          	jal	402 <printint>
        i += 2;
 5fe:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 600:	8ba6                	mv	s7,s1
      state = 0;
 602:	4981                	li	s3,0
        i += 2;
 604:	bdf9                	j	4e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 606:	008b8493          	addi	s1,s7,8
 60a:	4681                	li	a3,0
 60c:	4629                	li	a2,10
 60e:	000ba583          	lw	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	defff0ef          	jal	402 <printint>
 618:	8ba6                	mv	s7,s1
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b5d9                	j	4e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61e:	008b8493          	addi	s1,s7,8
 622:	4681                	li	a3,0
 624:	4629                	li	a2,10
 626:	000ba583          	lw	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	dd7ff0ef          	jal	402 <printint>
        i += 1;
 630:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 632:	8ba6                	mv	s7,s1
      state = 0;
 634:	4981                	li	s3,0
        i += 1;
 636:	b575                	j	4e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 638:	008b8493          	addi	s1,s7,8
 63c:	4681                	li	a3,0
 63e:	4629                	li	a2,10
 640:	000ba583          	lw	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	dbdff0ef          	jal	402 <printint>
        i += 2;
 64a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 64c:	8ba6                	mv	s7,s1
      state = 0;
 64e:	4981                	li	s3,0
        i += 2;
 650:	bd49                	j	4e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 652:	008b8493          	addi	s1,s7,8
 656:	4681                	li	a3,0
 658:	4641                	li	a2,16
 65a:	000ba583          	lw	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	da3ff0ef          	jal	402 <printint>
 664:	8ba6                	mv	s7,s1
      state = 0;
 666:	4981                	li	s3,0
 668:	bdad                	j	4e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 66a:	008b8493          	addi	s1,s7,8
 66e:	4681                	li	a3,0
 670:	4641                	li	a2,16
 672:	000ba583          	lw	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	d8bff0ef          	jal	402 <printint>
        i += 1;
 67c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 67e:	8ba6                	mv	s7,s1
      state = 0;
 680:	4981                	li	s3,0
        i += 1;
 682:	b585                	j	4e2 <vprintf+0x4a>
 684:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 686:	008b8d13          	addi	s10,s7,8
 68a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 68e:	03000593          	li	a1,48
 692:	855a                	mv	a0,s6
 694:	d51ff0ef          	jal	3e4 <putc>
  putc(fd, 'x');
 698:	07800593          	li	a1,120
 69c:	855a                	mv	a0,s6
 69e:	d47ff0ef          	jal	3e4 <putc>
 6a2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a4:	00000b97          	auipc	s7,0x0
 6a8:	2ecb8b93          	addi	s7,s7,748 # 990 <digits>
 6ac:	03c9d793          	srli	a5,s3,0x3c
 6b0:	97de                	add	a5,a5,s7
 6b2:	0007c583          	lbu	a1,0(a5)
 6b6:	855a                	mv	a0,s6
 6b8:	d2dff0ef          	jal	3e4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6bc:	0992                	slli	s3,s3,0x4
 6be:	34fd                	addiw	s1,s1,-1
 6c0:	f4f5                	bnez	s1,6ac <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 6c2:	8bea                	mv	s7,s10
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	6d02                	ld	s10,0(sp)
 6c8:	bd29                	j	4e2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6ca:	008b8993          	addi	s3,s7,8
 6ce:	000bb483          	ld	s1,0(s7)
 6d2:	cc91                	beqz	s1,6ee <vprintf+0x256>
        for(; *s; s++)
 6d4:	0004c583          	lbu	a1,0(s1)
 6d8:	c195                	beqz	a1,6fc <vprintf+0x264>
          putc(fd, *s);
 6da:	855a                	mv	a0,s6
 6dc:	d09ff0ef          	jal	3e4 <putc>
        for(; *s; s++)
 6e0:	0485                	addi	s1,s1,1
 6e2:	0004c583          	lbu	a1,0(s1)
 6e6:	f9f5                	bnez	a1,6da <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 6e8:	8bce                	mv	s7,s3
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bbdd                	j	4e2 <vprintf+0x4a>
          s = "(null)";
 6ee:	00000497          	auipc	s1,0x0
 6f2:	29a48493          	addi	s1,s1,666 # 988 <malloc+0x18a>
        for(; *s; s++)
 6f6:	02800593          	li	a1,40
 6fa:	b7c5                	j	6da <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 6fc:	8bce                	mv	s7,s3
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b3cd                	j	4e2 <vprintf+0x4a>
 702:	6906                	ld	s2,64(sp)
 704:	79e2                	ld	s3,56(sp)
 706:	7a42                	ld	s4,48(sp)
 708:	7aa2                	ld	s5,40(sp)
 70a:	7b02                	ld	s6,32(sp)
 70c:	6be2                	ld	s7,24(sp)
 70e:	6c42                	ld	s8,16(sp)
 710:	6ca2                	ld	s9,8(sp)
    }
  }
}
 712:	60e6                	ld	ra,88(sp)
 714:	6446                	ld	s0,80(sp)
 716:	64a6                	ld	s1,72(sp)
 718:	6125                	addi	sp,sp,96
 71a:	8082                	ret

000000000000071c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 71c:	715d                	addi	sp,sp,-80
 71e:	ec06                	sd	ra,24(sp)
 720:	e822                	sd	s0,16(sp)
 722:	1000                	addi	s0,sp,32
 724:	e010                	sd	a2,0(s0)
 726:	e414                	sd	a3,8(s0)
 728:	e818                	sd	a4,16(s0)
 72a:	ec1c                	sd	a5,24(s0)
 72c:	03043023          	sd	a6,32(s0)
 730:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 734:	8622                	mv	a2,s0
 736:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 73a:	d5fff0ef          	jal	498 <vprintf>
}
 73e:	60e2                	ld	ra,24(sp)
 740:	6442                	ld	s0,16(sp)
 742:	6161                	addi	sp,sp,80
 744:	8082                	ret

0000000000000746 <printf>:

void
printf(const char *fmt, ...)
{
 746:	711d                	addi	sp,sp,-96
 748:	ec06                	sd	ra,24(sp)
 74a:	e822                	sd	s0,16(sp)
 74c:	1000                	addi	s0,sp,32
 74e:	e40c                	sd	a1,8(s0)
 750:	e810                	sd	a2,16(s0)
 752:	ec14                	sd	a3,24(s0)
 754:	f018                	sd	a4,32(s0)
 756:	f41c                	sd	a5,40(s0)
 758:	03043823          	sd	a6,48(s0)
 75c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 760:	00840613          	addi	a2,s0,8
 764:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 768:	85aa                	mv	a1,a0
 76a:	4505                	li	a0,1
 76c:	d2dff0ef          	jal	498 <vprintf>
}
 770:	60e2                	ld	ra,24(sp)
 772:	6442                	ld	s0,16(sp)
 774:	6125                	addi	sp,sp,96
 776:	8082                	ret

0000000000000778 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 778:	1141                	addi	sp,sp,-16
 77a:	e406                	sd	ra,8(sp)
 77c:	e022                	sd	s0,0(sp)
 77e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 780:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 784:	00001797          	auipc	a5,0x1
 788:	87c7b783          	ld	a5,-1924(a5) # 1000 <freep>
 78c:	a02d                	j	7b6 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 78e:	4618                	lw	a4,8(a2)
 790:	9f2d                	addw	a4,a4,a1
 792:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 796:	6398                	ld	a4,0(a5)
 798:	6310                	ld	a2,0(a4)
 79a:	a83d                	j	7d8 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 79c:	ff852703          	lw	a4,-8(a0)
 7a0:	9f31                	addw	a4,a4,a2
 7a2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7a4:	ff053683          	ld	a3,-16(a0)
 7a8:	a091                	j	7ec <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7aa:	6398                	ld	a4,0(a5)
 7ac:	00e7e463          	bltu	a5,a4,7b4 <free+0x3c>
 7b0:	00e6ea63          	bltu	a3,a4,7c4 <free+0x4c>
{
 7b4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b6:	fed7fae3          	bgeu	a5,a3,7aa <free+0x32>
 7ba:	6398                	ld	a4,0(a5)
 7bc:	00e6e463          	bltu	a3,a4,7c4 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c0:	fee7eae3          	bltu	a5,a4,7b4 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7c4:	ff852583          	lw	a1,-8(a0)
 7c8:	6390                	ld	a2,0(a5)
 7ca:	02059813          	slli	a6,a1,0x20
 7ce:	01c85713          	srli	a4,a6,0x1c
 7d2:	9736                	add	a4,a4,a3
 7d4:	fae60de3          	beq	a2,a4,78e <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 7d8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7dc:	4790                	lw	a2,8(a5)
 7de:	02061593          	slli	a1,a2,0x20
 7e2:	01c5d713          	srli	a4,a1,0x1c
 7e6:	973e                	add	a4,a4,a5
 7e8:	fae68ae3          	beq	a3,a4,79c <free+0x24>
    p->s.ptr = bp->s.ptr;
 7ec:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7ee:	00001717          	auipc	a4,0x1
 7f2:	80f73923          	sd	a5,-2030(a4) # 1000 <freep>
}
 7f6:	60a2                	ld	ra,8(sp)
 7f8:	6402                	ld	s0,0(sp)
 7fa:	0141                	addi	sp,sp,16
 7fc:	8082                	ret

00000000000007fe <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7fe:	7139                	addi	sp,sp,-64
 800:	fc06                	sd	ra,56(sp)
 802:	f822                	sd	s0,48(sp)
 804:	f04a                	sd	s2,32(sp)
 806:	ec4e                	sd	s3,24(sp)
 808:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80a:	02051993          	slli	s3,a0,0x20
 80e:	0209d993          	srli	s3,s3,0x20
 812:	09bd                	addi	s3,s3,15
 814:	0049d993          	srli	s3,s3,0x4
 818:	2985                	addiw	s3,s3,1
 81a:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 81c:	00000517          	auipc	a0,0x0
 820:	7e453503          	ld	a0,2020(a0) # 1000 <freep>
 824:	c905                	beqz	a0,854 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 826:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 828:	4798                	lw	a4,8(a5)
 82a:	09377663          	bgeu	a4,s3,8b6 <malloc+0xb8>
 82e:	f426                	sd	s1,40(sp)
 830:	e852                	sd	s4,16(sp)
 832:	e456                	sd	s5,8(sp)
 834:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 836:	8a4e                	mv	s4,s3
 838:	6705                	lui	a4,0x1
 83a:	00e9f363          	bgeu	s3,a4,840 <malloc+0x42>
 83e:	6a05                	lui	s4,0x1
 840:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 844:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 848:	00000497          	auipc	s1,0x0
 84c:	7b848493          	addi	s1,s1,1976 # 1000 <freep>
  if(p == (char*)-1)
 850:	5afd                	li	s5,-1
 852:	a83d                	j	890 <malloc+0x92>
 854:	f426                	sd	s1,40(sp)
 856:	e852                	sd	s4,16(sp)
 858:	e456                	sd	s5,8(sp)
 85a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 85c:	00000797          	auipc	a5,0x0
 860:	7b478793          	addi	a5,a5,1972 # 1010 <base>
 864:	00000717          	auipc	a4,0x0
 868:	78f73e23          	sd	a5,1948(a4) # 1000 <freep>
 86c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 86e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 872:	b7d1                	j	836 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 874:	6398                	ld	a4,0(a5)
 876:	e118                	sd	a4,0(a0)
 878:	a899                	j	8ce <malloc+0xd0>
  hp->s.size = nu;
 87a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 87e:	0541                	addi	a0,a0,16
 880:	ef9ff0ef          	jal	778 <free>
  return freep;
 884:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 886:	c125                	beqz	a0,8e6 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 888:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88a:	4798                	lw	a4,8(a5)
 88c:	03277163          	bgeu	a4,s2,8ae <malloc+0xb0>
    if(p == freep)
 890:	6098                	ld	a4,0(s1)
 892:	853e                	mv	a0,a5
 894:	fef71ae3          	bne	a4,a5,888 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 898:	8552                	mv	a0,s4
 89a:	b1bff0ef          	jal	3b4 <sbrk>
  if(p == (char*)-1)
 89e:	fd551ee3          	bne	a0,s5,87a <malloc+0x7c>
        return 0;
 8a2:	4501                	li	a0,0
 8a4:	74a2                	ld	s1,40(sp)
 8a6:	6a42                	ld	s4,16(sp)
 8a8:	6aa2                	ld	s5,8(sp)
 8aa:	6b02                	ld	s6,0(sp)
 8ac:	a03d                	j	8da <malloc+0xdc>
 8ae:	74a2                	ld	s1,40(sp)
 8b0:	6a42                	ld	s4,16(sp)
 8b2:	6aa2                	ld	s5,8(sp)
 8b4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8b6:	fae90fe3          	beq	s2,a4,874 <malloc+0x76>
        p->s.size -= nunits;
 8ba:	4137073b          	subw	a4,a4,s3
 8be:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c0:	02071693          	slli	a3,a4,0x20
 8c4:	01c6d713          	srli	a4,a3,0x1c
 8c8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ca:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ce:	00000717          	auipc	a4,0x0
 8d2:	72a73923          	sd	a0,1842(a4) # 1000 <freep>
      return (void*)(p + 1);
 8d6:	01078513          	addi	a0,a5,16
  }
}
 8da:	70e2                	ld	ra,56(sp)
 8dc:	7442                	ld	s0,48(sp)
 8de:	7902                	ld	s2,32(sp)
 8e0:	69e2                	ld	s3,24(sp)
 8e2:	6121                	addi	sp,sp,64
 8e4:	8082                	ret
 8e6:	74a2                	ld	s1,40(sp)
 8e8:	6a42                	ld	s4,16(sp)
 8ea:	6aa2                	ld	s5,8(sp)
 8ec:	6b02                	ld	s6,0(sp)
 8ee:	b7f5                	j	8da <malloc+0xdc>
