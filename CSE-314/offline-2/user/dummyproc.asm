
user/_dummyproc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user.h"



int main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
    int tickets = -1;
    if (argc > 1) {
   a:	4785                	li	a5,1
    int tickets = -1;
   c:	54fd                	li	s1,-1
    if (argc > 1) {
   e:	06a7c663          	blt	a5,a0,7a <main+0x7a>
        tickets = atoi(argv[1]);
    }
    printf("[dummyproc] Setting tickets to %d\n", tickets);
  12:	85a6                	mv	a1,s1
  14:	00001517          	auipc	a0,0x1
  18:	93c50513          	addi	a0,a0,-1732 # 950 <malloc+0xf6>
  1c:	786000ef          	jal	7a2 <printf>
    int ret = settickets(tickets);
  20:	8526                	mv	a0,s1
  22:	40e000ef          	jal	430 <settickets>
    if (ret == 0) {
  26:	ed39                	bnez	a0,84 <main+0x84>
        printf("[dummyproc] settickets succeeded\n");
  28:	00001517          	auipc	a0,0x1
  2c:	95050513          	addi	a0,a0,-1712 # 978 <malloc+0x11e>
  30:	772000ef          	jal	7a2 <printf>
    } else {
        printf("[dummyproc] settickets failed, using default tickets\n");
    }

    int pid = fork();
  34:	34c000ef          	jal	380 <fork>
  38:	84aa                	mv	s1,a0
    if (pid < 0) {
  3a:	04054c63          	bltz	a0,92 <main+0x92>
        printf("[dummyproc] fork failed\n");
        exit(1);
    } else if (pid == 0) {
  3e:	e52d                	bnez	a0,a8 <main+0xa8>
  40:	e84a                	sd	s2,16(sp)
  42:	e44e                	sd	s3,8(sp)
        // Child process
        printf("[dummyproc] Child process running (pid=%d)\n", getpid());
  44:	3c4000ef          	jal	408 <getpid>
  48:	85aa                	mv	a1,a0
  4a:	00001517          	auipc	a0,0x1
  4e:	9ae50513          	addi	a0,a0,-1618 # 9f8 <malloc+0x19e>
  52:	750000ef          	jal	7a2 <printf>
        for (int i = 0; i < 10; i++) {
            printf("[dummyproc] Child loop %d\n", i);
  56:	00001997          	auipc	s3,0x1
  5a:	9d298993          	addi	s3,s3,-1582 # a28 <malloc+0x1ce>
            sleep(10);
  5e:	4929                	li	s2,10
            printf("[dummyproc] Child loop %d\n", i);
  60:	85a6                	mv	a1,s1
  62:	854e                	mv	a0,s3
  64:	73e000ef          	jal	7a2 <printf>
            sleep(10);
  68:	854a                	mv	a0,s2
  6a:	3ae000ef          	jal	418 <sleep>
        for (int i = 0; i < 10; i++) {
  6e:	2485                	addiw	s1,s1,1
  70:	ff2498e3          	bne	s1,s2,60 <main+0x60>
        }
        exit(0);
  74:	4501                	li	a0,0
  76:	312000ef          	jal	388 <exit>
        tickets = atoi(argv[1]);
  7a:	6588                	ld	a0,8(a1)
  7c:	20a000ef          	jal	286 <atoi>
  80:	84aa                	mv	s1,a0
  82:	bf41                	j	12 <main+0x12>
        printf("[dummyproc] settickets failed, using default tickets\n");
  84:	00001517          	auipc	a0,0x1
  88:	91c50513          	addi	a0,a0,-1764 # 9a0 <malloc+0x146>
  8c:	716000ef          	jal	7a2 <printf>
  90:	b755                	j	34 <main+0x34>
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
        printf("[dummyproc] fork failed\n");
  96:	00001517          	auipc	a0,0x1
  9a:	94250513          	addi	a0,a0,-1726 # 9d8 <malloc+0x17e>
  9e:	704000ef          	jal	7a2 <printf>
        exit(1);
  a2:	4505                	li	a0,1
  a4:	2e4000ef          	jal	388 <exit>
  a8:	e84a                	sd	s2,16(sp)
  aa:	e44e                	sd	s3,8(sp)
    } else {
        // Parent process
        printf("[dummyproc] Parent process running (pid=%d)\n", getpid());
  ac:	35c000ef          	jal	408 <getpid>
  b0:	85aa                	mv	a1,a0
  b2:	00001517          	auipc	a0,0x1
  b6:	99650513          	addi	a0,a0,-1642 # a48 <malloc+0x1ee>
  ba:	6e8000ef          	jal	7a2 <printf>
        for (int i = 0; i < 10; i++) {
  be:	4481                	li	s1,0
            printf("[dummyproc] Parent loop %d\n", i);
  c0:	00001997          	auipc	s3,0x1
  c4:	9b898993          	addi	s3,s3,-1608 # a78 <malloc+0x21e>
            sleep(10);
  c8:	4929                	li	s2,10
            printf("[dummyproc] Parent loop %d\n", i);
  ca:	85a6                	mv	a1,s1
  cc:	854e                	mv	a0,s3
  ce:	6d4000ef          	jal	7a2 <printf>
            sleep(10);
  d2:	854a                	mv	a0,s2
  d4:	344000ef          	jal	418 <sleep>
        for (int i = 0; i < 10; i++) {
  d8:	2485                	addiw	s1,s1,1
  da:	ff2498e3          	bne	s1,s2,ca <main+0xca>
        }
        wait(0);
  de:	4501                	li	a0,0
  e0:	2b0000ef          	jal	390 <wait>
    }
    exit(0);
  e4:	4501                	li	a0,0
  e6:	2a2000ef          	jal	388 <exit>

00000000000000ea <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e406                	sd	ra,8(sp)
  ee:	e022                	sd	s0,0(sp)
  f0:	0800                	addi	s0,sp,16
  extern int main();
  main();
  f2:	f0fff0ef          	jal	0 <main>
  exit(0);
  f6:	4501                	li	a0,0
  f8:	290000ef          	jal	388 <exit>

00000000000000fc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e406                	sd	ra,8(sp)
 100:	e022                	sd	s0,0(sp)
 102:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 104:	87aa                	mv	a5,a0
 106:	0585                	addi	a1,a1,1
 108:	0785                	addi	a5,a5,1
 10a:	fff5c703          	lbu	a4,-1(a1)
 10e:	fee78fa3          	sb	a4,-1(a5)
 112:	fb75                	bnez	a4,106 <strcpy+0xa>
    ;
  return os;
}
 114:	60a2                	ld	ra,8(sp)
 116:	6402                	ld	s0,0(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 124:	00054783          	lbu	a5,0(a0)
 128:	cb91                	beqz	a5,13c <strcmp+0x20>
 12a:	0005c703          	lbu	a4,0(a1)
 12e:	00f71763          	bne	a4,a5,13c <strcmp+0x20>
    p++, q++;
 132:	0505                	addi	a0,a0,1
 134:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 136:	00054783          	lbu	a5,0(a0)
 13a:	fbe5                	bnez	a5,12a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 13c:	0005c503          	lbu	a0,0(a1)
}
 140:	40a7853b          	subw	a0,a5,a0
 144:	60a2                	ld	ra,8(sp)
 146:	6402                	ld	s0,0(sp)
 148:	0141                	addi	sp,sp,16
 14a:	8082                	ret

000000000000014c <strlen>:

uint
strlen(const char *s)
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e406                	sd	ra,8(sp)
 150:	e022                	sd	s0,0(sp)
 152:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 154:	00054783          	lbu	a5,0(a0)
 158:	cf99                	beqz	a5,176 <strlen+0x2a>
 15a:	0505                	addi	a0,a0,1
 15c:	87aa                	mv	a5,a0
 15e:	86be                	mv	a3,a5
 160:	0785                	addi	a5,a5,1
 162:	fff7c703          	lbu	a4,-1(a5)
 166:	ff65                	bnez	a4,15e <strlen+0x12>
 168:	40a6853b          	subw	a0,a3,a0
 16c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 16e:	60a2                	ld	ra,8(sp)
 170:	6402                	ld	s0,0(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret
  for(n = 0; s[n]; n++)
 176:	4501                	li	a0,0
 178:	bfdd                	j	16e <strlen+0x22>

000000000000017a <memset>:

void*
memset(void *dst, int c, uint n)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e406                	sd	ra,8(sp)
 17e:	e022                	sd	s0,0(sp)
 180:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 182:	ca19                	beqz	a2,198 <memset+0x1e>
 184:	87aa                	mv	a5,a0
 186:	1602                	slli	a2,a2,0x20
 188:	9201                	srli	a2,a2,0x20
 18a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 18e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 192:	0785                	addi	a5,a5,1
 194:	fee79de3          	bne	a5,a4,18e <memset+0x14>
  }
  return dst;
}
 198:	60a2                	ld	ra,8(sp)
 19a:	6402                	ld	s0,0(sp)
 19c:	0141                	addi	sp,sp,16
 19e:	8082                	ret

00000000000001a0 <strchr>:

char*
strchr(const char *s, char c)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e406                	sd	ra,8(sp)
 1a4:	e022                	sd	s0,0(sp)
 1a6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a8:	00054783          	lbu	a5,0(a0)
 1ac:	cf81                	beqz	a5,1c4 <strchr+0x24>
    if(*s == c)
 1ae:	00f58763          	beq	a1,a5,1bc <strchr+0x1c>
  for(; *s; s++)
 1b2:	0505                	addi	a0,a0,1
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	fbfd                	bnez	a5,1ae <strchr+0xe>
      return (char*)s;
  return 0;
 1ba:	4501                	li	a0,0
}
 1bc:	60a2                	ld	ra,8(sp)
 1be:	6402                	ld	s0,0(sp)
 1c0:	0141                	addi	sp,sp,16
 1c2:	8082                	ret
  return 0;
 1c4:	4501                	li	a0,0
 1c6:	bfdd                	j	1bc <strchr+0x1c>

00000000000001c8 <gets>:

char*
gets(char *buf, int max)
{
 1c8:	7159                	addi	sp,sp,-112
 1ca:	f486                	sd	ra,104(sp)
 1cc:	f0a2                	sd	s0,96(sp)
 1ce:	eca6                	sd	s1,88(sp)
 1d0:	e8ca                	sd	s2,80(sp)
 1d2:	e4ce                	sd	s3,72(sp)
 1d4:	e0d2                	sd	s4,64(sp)
 1d6:	fc56                	sd	s5,56(sp)
 1d8:	f85a                	sd	s6,48(sp)
 1da:	f45e                	sd	s7,40(sp)
 1dc:	f062                	sd	s8,32(sp)
 1de:	ec66                	sd	s9,24(sp)
 1e0:	e86a                	sd	s10,16(sp)
 1e2:	1880                	addi	s0,sp,112
 1e4:	8caa                	mv	s9,a0
 1e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e8:	892a                	mv	s2,a0
 1ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1ec:	f9f40b13          	addi	s6,s0,-97
 1f0:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f2:	4ba9                	li	s7,10
 1f4:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 1f6:	8d26                	mv	s10,s1
 1f8:	0014899b          	addiw	s3,s1,1
 1fc:	84ce                	mv	s1,s3
 1fe:	0349d563          	bge	s3,s4,228 <gets+0x60>
    cc = read(0, &c, 1);
 202:	8656                	mv	a2,s5
 204:	85da                	mv	a1,s6
 206:	4501                	li	a0,0
 208:	198000ef          	jal	3a0 <read>
    if(cc < 1)
 20c:	00a05e63          	blez	a0,228 <gets+0x60>
    buf[i++] = c;
 210:	f9f44783          	lbu	a5,-97(s0)
 214:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 218:	01778763          	beq	a5,s7,226 <gets+0x5e>
 21c:	0905                	addi	s2,s2,1
 21e:	fd879ce3          	bne	a5,s8,1f6 <gets+0x2e>
    buf[i++] = c;
 222:	8d4e                	mv	s10,s3
 224:	a011                	j	228 <gets+0x60>
 226:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 228:	9d66                	add	s10,s10,s9
 22a:	000d0023          	sb	zero,0(s10)
  return buf;
}
 22e:	8566                	mv	a0,s9
 230:	70a6                	ld	ra,104(sp)
 232:	7406                	ld	s0,96(sp)
 234:	64e6                	ld	s1,88(sp)
 236:	6946                	ld	s2,80(sp)
 238:	69a6                	ld	s3,72(sp)
 23a:	6a06                	ld	s4,64(sp)
 23c:	7ae2                	ld	s5,56(sp)
 23e:	7b42                	ld	s6,48(sp)
 240:	7ba2                	ld	s7,40(sp)
 242:	7c02                	ld	s8,32(sp)
 244:	6ce2                	ld	s9,24(sp)
 246:	6d42                	ld	s10,16(sp)
 248:	6165                	addi	sp,sp,112
 24a:	8082                	ret

000000000000024c <stat>:

int
stat(const char *n, struct stat *st)
{
 24c:	1101                	addi	sp,sp,-32
 24e:	ec06                	sd	ra,24(sp)
 250:	e822                	sd	s0,16(sp)
 252:	e04a                	sd	s2,0(sp)
 254:	1000                	addi	s0,sp,32
 256:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 258:	4581                	li	a1,0
 25a:	16e000ef          	jal	3c8 <open>
  if(fd < 0)
 25e:	02054263          	bltz	a0,282 <stat+0x36>
 262:	e426                	sd	s1,8(sp)
 264:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 266:	85ca                	mv	a1,s2
 268:	178000ef          	jal	3e0 <fstat>
 26c:	892a                	mv	s2,a0
  close(fd);
 26e:	8526                	mv	a0,s1
 270:	140000ef          	jal	3b0 <close>
  return r;
 274:	64a2                	ld	s1,8(sp)
}
 276:	854a                	mv	a0,s2
 278:	60e2                	ld	ra,24(sp)
 27a:	6442                	ld	s0,16(sp)
 27c:	6902                	ld	s2,0(sp)
 27e:	6105                	addi	sp,sp,32
 280:	8082                	ret
    return -1;
 282:	597d                	li	s2,-1
 284:	bfcd                	j	276 <stat+0x2a>

0000000000000286 <atoi>:

int
atoi(const char *s)
{
 286:	1141                	addi	sp,sp,-16
 288:	e406                	sd	ra,8(sp)
 28a:	e022                	sd	s0,0(sp)
 28c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28e:	00054683          	lbu	a3,0(a0)
 292:	fd06879b          	addiw	a5,a3,-48
 296:	0ff7f793          	zext.b	a5,a5
 29a:	4625                	li	a2,9
 29c:	02f66963          	bltu	a2,a5,2ce <atoi+0x48>
 2a0:	872a                	mv	a4,a0
  n = 0;
 2a2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a4:	0705                	addi	a4,a4,1
 2a6:	0025179b          	slliw	a5,a0,0x2
 2aa:	9fa9                	addw	a5,a5,a0
 2ac:	0017979b          	slliw	a5,a5,0x1
 2b0:	9fb5                	addw	a5,a5,a3
 2b2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b6:	00074683          	lbu	a3,0(a4)
 2ba:	fd06879b          	addiw	a5,a3,-48
 2be:	0ff7f793          	zext.b	a5,a5
 2c2:	fef671e3          	bgeu	a2,a5,2a4 <atoi+0x1e>
  return n;
}
 2c6:	60a2                	ld	ra,8(sp)
 2c8:	6402                	ld	s0,0(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
  n = 0;
 2ce:	4501                	li	a0,0
 2d0:	bfdd                	j	2c6 <atoi+0x40>

00000000000002d2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2da:	02b57563          	bgeu	a0,a1,304 <memmove+0x32>
    while(n-- > 0)
 2de:	00c05f63          	blez	a2,2fc <memmove+0x2a>
 2e2:	1602                	slli	a2,a2,0x20
 2e4:	9201                	srli	a2,a2,0x20
 2e6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ea:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ec:	0585                	addi	a1,a1,1
 2ee:	0705                	addi	a4,a4,1
 2f0:	fff5c683          	lbu	a3,-1(a1)
 2f4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f8:	fee79ae3          	bne	a5,a4,2ec <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2fc:	60a2                	ld	ra,8(sp)
 2fe:	6402                	ld	s0,0(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
    dst += n;
 304:	00c50733          	add	a4,a0,a2
    src += n;
 308:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 30a:	fec059e3          	blez	a2,2fc <memmove+0x2a>
 30e:	fff6079b          	addiw	a5,a2,-1
 312:	1782                	slli	a5,a5,0x20
 314:	9381                	srli	a5,a5,0x20
 316:	fff7c793          	not	a5,a5
 31a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 31c:	15fd                	addi	a1,a1,-1
 31e:	177d                	addi	a4,a4,-1
 320:	0005c683          	lbu	a3,0(a1)
 324:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 328:	fef71ae3          	bne	a4,a5,31c <memmove+0x4a>
 32c:	bfc1                	j	2fc <memmove+0x2a>

000000000000032e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e406                	sd	ra,8(sp)
 332:	e022                	sd	s0,0(sp)
 334:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 336:	ca0d                	beqz	a2,368 <memcmp+0x3a>
 338:	fff6069b          	addiw	a3,a2,-1
 33c:	1682                	slli	a3,a3,0x20
 33e:	9281                	srli	a3,a3,0x20
 340:	0685                	addi	a3,a3,1
 342:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 344:	00054783          	lbu	a5,0(a0)
 348:	0005c703          	lbu	a4,0(a1)
 34c:	00e79863          	bne	a5,a4,35c <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 350:	0505                	addi	a0,a0,1
    p2++;
 352:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 354:	fed518e3          	bne	a0,a3,344 <memcmp+0x16>
  }
  return 0;
 358:	4501                	li	a0,0
 35a:	a019                	j	360 <memcmp+0x32>
      return *p1 - *p2;
 35c:	40e7853b          	subw	a0,a5,a4
}
 360:	60a2                	ld	ra,8(sp)
 362:	6402                	ld	s0,0(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret
  return 0;
 368:	4501                	li	a0,0
 36a:	bfdd                	j	360 <memcmp+0x32>

000000000000036c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e406                	sd	ra,8(sp)
 370:	e022                	sd	s0,0(sp)
 372:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 374:	f5fff0ef          	jal	2d2 <memmove>
}
 378:	60a2                	ld	ra,8(sp)
 37a:	6402                	ld	s0,0(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret

0000000000000380 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 380:	4885                	li	a7,1
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <exit>:
.global exit
exit:
 li a7, SYS_exit
 388:	4889                	li	a7,2
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <wait>:
.global wait
wait:
 li a7, SYS_wait
 390:	488d                	li	a7,3
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 398:	4891                	li	a7,4
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <read>:
.global read
read:
 li a7, SYS_read
 3a0:	4895                	li	a7,5
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <write>:
.global write
write:
 li a7, SYS_write
 3a8:	48c1                	li	a7,16
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <close>:
.global close
close:
 li a7, SYS_close
 3b0:	48d5                	li	a7,21
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b8:	4899                	li	a7,6
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c0:	489d                	li	a7,7
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <open>:
.global open
open:
 li a7, SYS_open
 3c8:	48bd                	li	a7,15
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d0:	48c5                	li	a7,17
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d8:	48c9                	li	a7,18
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e0:	48a1                	li	a7,8
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <link>:
.global link
link:
 li a7, SYS_link
 3e8:	48cd                	li	a7,19
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f0:	48d1                	li	a7,20
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f8:	48a5                	li	a7,9
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <dup>:
.global dup
dup:
 li a7, SYS_dup
 400:	48a9                	li	a7,10
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 408:	48ad                	li	a7,11
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 410:	48b1                	li	a7,12
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 418:	48b5                	li	a7,13
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 420:	48b9                	li	a7,14
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <history>:
.global history
history:
 li a7, SYS_history
 428:	48d9                	li	a7,22
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 430:	48dd                	li	a7,23
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 438:	48dd                	li	a7,23
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 440:	1101                	addi	sp,sp,-32
 442:	ec06                	sd	ra,24(sp)
 444:	e822                	sd	s0,16(sp)
 446:	1000                	addi	s0,sp,32
 448:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 44c:	4605                	li	a2,1
 44e:	fef40593          	addi	a1,s0,-17
 452:	f57ff0ef          	jal	3a8 <write>
}
 456:	60e2                	ld	ra,24(sp)
 458:	6442                	ld	s0,16(sp)
 45a:	6105                	addi	sp,sp,32
 45c:	8082                	ret

000000000000045e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45e:	7139                	addi	sp,sp,-64
 460:	fc06                	sd	ra,56(sp)
 462:	f822                	sd	s0,48(sp)
 464:	f426                	sd	s1,40(sp)
 466:	f04a                	sd	s2,32(sp)
 468:	ec4e                	sd	s3,24(sp)
 46a:	0080                	addi	s0,sp,64
 46c:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 46e:	c299                	beqz	a3,474 <printint+0x16>
 470:	0605ce63          	bltz	a1,4ec <printint+0x8e>
  neg = 0;
 474:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 476:	fc040313          	addi	t1,s0,-64
  neg = 0;
 47a:	869a                	mv	a3,t1
  i = 0;
 47c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 47e:	00000817          	auipc	a6,0x0
 482:	62280813          	addi	a6,a6,1570 # aa0 <digits>
 486:	88be                	mv	a7,a5
 488:	0017851b          	addiw	a0,a5,1
 48c:	87aa                	mv	a5,a0
 48e:	02c5f73b          	remuw	a4,a1,a2
 492:	1702                	slli	a4,a4,0x20
 494:	9301                	srli	a4,a4,0x20
 496:	9742                	add	a4,a4,a6
 498:	00074703          	lbu	a4,0(a4)
 49c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4a0:	872e                	mv	a4,a1
 4a2:	02c5d5bb          	divuw	a1,a1,a2
 4a6:	0685                	addi	a3,a3,1
 4a8:	fcc77fe3          	bgeu	a4,a2,486 <printint+0x28>
  if(neg)
 4ac:	000e0c63          	beqz	t3,4c4 <printint+0x66>
    buf[i++] = '-';
 4b0:	fd050793          	addi	a5,a0,-48
 4b4:	00878533          	add	a0,a5,s0
 4b8:	02d00793          	li	a5,45
 4bc:	fef50823          	sb	a5,-16(a0)
 4c0:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 4c4:	fff7899b          	addiw	s3,a5,-1
 4c8:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 4cc:	fff4c583          	lbu	a1,-1(s1)
 4d0:	854a                	mv	a0,s2
 4d2:	f6fff0ef          	jal	440 <putc>
  while(--i >= 0)
 4d6:	39fd                	addiw	s3,s3,-1
 4d8:	14fd                	addi	s1,s1,-1
 4da:	fe09d9e3          	bgez	s3,4cc <printint+0x6e>
}
 4de:	70e2                	ld	ra,56(sp)
 4e0:	7442                	ld	s0,48(sp)
 4e2:	74a2                	ld	s1,40(sp)
 4e4:	7902                	ld	s2,32(sp)
 4e6:	69e2                	ld	s3,24(sp)
 4e8:	6121                	addi	sp,sp,64
 4ea:	8082                	ret
    x = -xx;
 4ec:	40b005bb          	negw	a1,a1
    neg = 1;
 4f0:	4e05                	li	t3,1
    x = -xx;
 4f2:	b751                	j	476 <printint+0x18>

00000000000004f4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f4:	711d                	addi	sp,sp,-96
 4f6:	ec86                	sd	ra,88(sp)
 4f8:	e8a2                	sd	s0,80(sp)
 4fa:	e4a6                	sd	s1,72(sp)
 4fc:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4fe:	0005c483          	lbu	s1,0(a1)
 502:	26048663          	beqz	s1,76e <vprintf+0x27a>
 506:	e0ca                	sd	s2,64(sp)
 508:	fc4e                	sd	s3,56(sp)
 50a:	f852                	sd	s4,48(sp)
 50c:	f456                	sd	s5,40(sp)
 50e:	f05a                	sd	s6,32(sp)
 510:	ec5e                	sd	s7,24(sp)
 512:	e862                	sd	s8,16(sp)
 514:	e466                	sd	s9,8(sp)
 516:	8b2a                	mv	s6,a0
 518:	8a2e                	mv	s4,a1
 51a:	8bb2                	mv	s7,a2
  state = 0;
 51c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 51e:	4901                	li	s2,0
 520:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 522:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 526:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 52a:	06c00c93          	li	s9,108
 52e:	a00d                	j	550 <vprintf+0x5c>
        putc(fd, c0);
 530:	85a6                	mv	a1,s1
 532:	855a                	mv	a0,s6
 534:	f0dff0ef          	jal	440 <putc>
 538:	a019                	j	53e <vprintf+0x4a>
    } else if(state == '%'){
 53a:	03598363          	beq	s3,s5,560 <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 53e:	0019079b          	addiw	a5,s2,1
 542:	893e                	mv	s2,a5
 544:	873e                	mv	a4,a5
 546:	97d2                	add	a5,a5,s4
 548:	0007c483          	lbu	s1,0(a5)
 54c:	20048963          	beqz	s1,75e <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 550:	0004879b          	sext.w	a5,s1
    if(state == 0){
 554:	fe0993e3          	bnez	s3,53a <vprintf+0x46>
      if(c0 == '%'){
 558:	fd579ce3          	bne	a5,s5,530 <vprintf+0x3c>
        state = '%';
 55c:	89be                	mv	s3,a5
 55e:	b7c5                	j	53e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 560:	00ea06b3          	add	a3,s4,a4
 564:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 568:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 56a:	c681                	beqz	a3,572 <vprintf+0x7e>
 56c:	9752                	add	a4,a4,s4
 56e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 572:	03878e63          	beq	a5,s8,5ae <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 576:	05978863          	beq	a5,s9,5c6 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 57a:	07500713          	li	a4,117
 57e:	0ee78263          	beq	a5,a4,662 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 582:	07800713          	li	a4,120
 586:	12e78463          	beq	a5,a4,6ae <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 58a:	07000713          	li	a4,112
 58e:	14e78963          	beq	a5,a4,6e0 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 592:	07300713          	li	a4,115
 596:	18e78863          	beq	a5,a4,726 <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 59a:	02500713          	li	a4,37
 59e:	04e79463          	bne	a5,a4,5e6 <vprintf+0xf2>
        putc(fd, '%');
 5a2:	85ba                	mv	a1,a4
 5a4:	855a                	mv	a0,s6
 5a6:	e9bff0ef          	jal	440 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	bf49                	j	53e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5ae:	008b8493          	addi	s1,s7,8
 5b2:	4685                	li	a3,1
 5b4:	4629                	li	a2,10
 5b6:	000ba583          	lw	a1,0(s7)
 5ba:	855a                	mv	a0,s6
 5bc:	ea3ff0ef          	jal	45e <printint>
 5c0:	8ba6                	mv	s7,s1
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	bfad                	j	53e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5c6:	06400793          	li	a5,100
 5ca:	02f68963          	beq	a3,a5,5fc <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ce:	06c00793          	li	a5,108
 5d2:	04f68263          	beq	a3,a5,616 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 5d6:	07500793          	li	a5,117
 5da:	0af68063          	beq	a3,a5,67a <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 5de:	07800793          	li	a5,120
 5e2:	0ef68263          	beq	a3,a5,6c6 <vprintf+0x1d2>
        putc(fd, '%');
 5e6:	02500593          	li	a1,37
 5ea:	855a                	mv	a0,s6
 5ec:	e55ff0ef          	jal	440 <putc>
        putc(fd, c0);
 5f0:	85a6                	mv	a1,s1
 5f2:	855a                	mv	a0,s6
 5f4:	e4dff0ef          	jal	440 <putc>
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	b791                	j	53e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fc:	008b8493          	addi	s1,s7,8
 600:	4685                	li	a3,1
 602:	4629                	li	a2,10
 604:	000ba583          	lw	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	e55ff0ef          	jal	45e <printint>
        i += 1;
 60e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 610:	8ba6                	mv	s7,s1
      state = 0;
 612:	4981                	li	s3,0
        i += 1;
 614:	b72d                	j	53e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 616:	06400793          	li	a5,100
 61a:	02f60763          	beq	a2,a5,648 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 61e:	07500793          	li	a5,117
 622:	06f60963          	beq	a2,a5,694 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 626:	07800793          	li	a5,120
 62a:	faf61ee3          	bne	a2,a5,5e6 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 62e:	008b8493          	addi	s1,s7,8
 632:	4681                	li	a3,0
 634:	4641                	li	a2,16
 636:	000ba583          	lw	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	e23ff0ef          	jal	45e <printint>
        i += 2;
 640:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 642:	8ba6                	mv	s7,s1
      state = 0;
 644:	4981                	li	s3,0
        i += 2;
 646:	bde5                	j	53e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 648:	008b8493          	addi	s1,s7,8
 64c:	4685                	li	a3,1
 64e:	4629                	li	a2,10
 650:	000ba583          	lw	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	e09ff0ef          	jal	45e <printint>
        i += 2;
 65a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 65c:	8ba6                	mv	s7,s1
      state = 0;
 65e:	4981                	li	s3,0
        i += 2;
 660:	bdf9                	j	53e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 662:	008b8493          	addi	s1,s7,8
 666:	4681                	li	a3,0
 668:	4629                	li	a2,10
 66a:	000ba583          	lw	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	defff0ef          	jal	45e <printint>
 674:	8ba6                	mv	s7,s1
      state = 0;
 676:	4981                	li	s3,0
 678:	b5d9                	j	53e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	008b8493          	addi	s1,s7,8
 67e:	4681                	li	a3,0
 680:	4629                	li	a2,10
 682:	000ba583          	lw	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	dd7ff0ef          	jal	45e <printint>
        i += 1;
 68c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	8ba6                	mv	s7,s1
      state = 0;
 690:	4981                	li	s3,0
        i += 1;
 692:	b575                	j	53e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 694:	008b8493          	addi	s1,s7,8
 698:	4681                	li	a3,0
 69a:	4629                	li	a2,10
 69c:	000ba583          	lw	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	dbdff0ef          	jal	45e <printint>
        i += 2;
 6a6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a8:	8ba6                	mv	s7,s1
      state = 0;
 6aa:	4981                	li	s3,0
        i += 2;
 6ac:	bd49                	j	53e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 6ae:	008b8493          	addi	s1,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4641                	li	a2,16
 6b6:	000ba583          	lw	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	da3ff0ef          	jal	45e <printint>
 6c0:	8ba6                	mv	s7,s1
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bdad                	j	53e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c6:	008b8493          	addi	s1,s7,8
 6ca:	4681                	li	a3,0
 6cc:	4641                	li	a2,16
 6ce:	000ba583          	lw	a1,0(s7)
 6d2:	855a                	mv	a0,s6
 6d4:	d8bff0ef          	jal	45e <printint>
        i += 1;
 6d8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6da:	8ba6                	mv	s7,s1
      state = 0;
 6dc:	4981                	li	s3,0
        i += 1;
 6de:	b585                	j	53e <vprintf+0x4a>
 6e0:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6e2:	008b8d13          	addi	s10,s7,8
 6e6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ea:	03000593          	li	a1,48
 6ee:	855a                	mv	a0,s6
 6f0:	d51ff0ef          	jal	440 <putc>
  putc(fd, 'x');
 6f4:	07800593          	li	a1,120
 6f8:	855a                	mv	a0,s6
 6fa:	d47ff0ef          	jal	440 <putc>
 6fe:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 700:	00000b97          	auipc	s7,0x0
 704:	3a0b8b93          	addi	s7,s7,928 # aa0 <digits>
 708:	03c9d793          	srli	a5,s3,0x3c
 70c:	97de                	add	a5,a5,s7
 70e:	0007c583          	lbu	a1,0(a5)
 712:	855a                	mv	a0,s6
 714:	d2dff0ef          	jal	440 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 718:	0992                	slli	s3,s3,0x4
 71a:	34fd                	addiw	s1,s1,-1
 71c:	f4f5                	bnez	s1,708 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 71e:	8bea                	mv	s7,s10
      state = 0;
 720:	4981                	li	s3,0
 722:	6d02                	ld	s10,0(sp)
 724:	bd29                	j	53e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 726:	008b8993          	addi	s3,s7,8
 72a:	000bb483          	ld	s1,0(s7)
 72e:	cc91                	beqz	s1,74a <vprintf+0x256>
        for(; *s; s++)
 730:	0004c583          	lbu	a1,0(s1)
 734:	c195                	beqz	a1,758 <vprintf+0x264>
          putc(fd, *s);
 736:	855a                	mv	a0,s6
 738:	d09ff0ef          	jal	440 <putc>
        for(; *s; s++)
 73c:	0485                	addi	s1,s1,1
 73e:	0004c583          	lbu	a1,0(s1)
 742:	f9f5                	bnez	a1,736 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 744:	8bce                	mv	s7,s3
      state = 0;
 746:	4981                	li	s3,0
 748:	bbdd                	j	53e <vprintf+0x4a>
          s = "(null)";
 74a:	00000497          	auipc	s1,0x0
 74e:	34e48493          	addi	s1,s1,846 # a98 <malloc+0x23e>
        for(; *s; s++)
 752:	02800593          	li	a1,40
 756:	b7c5                	j	736 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 758:	8bce                	mv	s7,s3
      state = 0;
 75a:	4981                	li	s3,0
 75c:	b3cd                	j	53e <vprintf+0x4a>
 75e:	6906                	ld	s2,64(sp)
 760:	79e2                	ld	s3,56(sp)
 762:	7a42                	ld	s4,48(sp)
 764:	7aa2                	ld	s5,40(sp)
 766:	7b02                	ld	s6,32(sp)
 768:	6be2                	ld	s7,24(sp)
 76a:	6c42                	ld	s8,16(sp)
 76c:	6ca2                	ld	s9,8(sp)
    }
  }
}
 76e:	60e6                	ld	ra,88(sp)
 770:	6446                	ld	s0,80(sp)
 772:	64a6                	ld	s1,72(sp)
 774:	6125                	addi	sp,sp,96
 776:	8082                	ret

0000000000000778 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 778:	715d                	addi	sp,sp,-80
 77a:	ec06                	sd	ra,24(sp)
 77c:	e822                	sd	s0,16(sp)
 77e:	1000                	addi	s0,sp,32
 780:	e010                	sd	a2,0(s0)
 782:	e414                	sd	a3,8(s0)
 784:	e818                	sd	a4,16(s0)
 786:	ec1c                	sd	a5,24(s0)
 788:	03043023          	sd	a6,32(s0)
 78c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 790:	8622                	mv	a2,s0
 792:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 796:	d5fff0ef          	jal	4f4 <vprintf>
}
 79a:	60e2                	ld	ra,24(sp)
 79c:	6442                	ld	s0,16(sp)
 79e:	6161                	addi	sp,sp,80
 7a0:	8082                	ret

00000000000007a2 <printf>:

void
printf(const char *fmt, ...)
{
 7a2:	711d                	addi	sp,sp,-96
 7a4:	ec06                	sd	ra,24(sp)
 7a6:	e822                	sd	s0,16(sp)
 7a8:	1000                	addi	s0,sp,32
 7aa:	e40c                	sd	a1,8(s0)
 7ac:	e810                	sd	a2,16(s0)
 7ae:	ec14                	sd	a3,24(s0)
 7b0:	f018                	sd	a4,32(s0)
 7b2:	f41c                	sd	a5,40(s0)
 7b4:	03043823          	sd	a6,48(s0)
 7b8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7bc:	00840613          	addi	a2,s0,8
 7c0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c4:	85aa                	mv	a1,a0
 7c6:	4505                	li	a0,1
 7c8:	d2dff0ef          	jal	4f4 <vprintf>
}
 7cc:	60e2                	ld	ra,24(sp)
 7ce:	6442                	ld	s0,16(sp)
 7d0:	6125                	addi	sp,sp,96
 7d2:	8082                	ret

00000000000007d4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d4:	1141                	addi	sp,sp,-16
 7d6:	e406                	sd	ra,8(sp)
 7d8:	e022                	sd	s0,0(sp)
 7da:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7dc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e0:	00001797          	auipc	a5,0x1
 7e4:	8207b783          	ld	a5,-2016(a5) # 1000 <freep>
 7e8:	a02d                	j	812 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ea:	4618                	lw	a4,8(a2)
 7ec:	9f2d                	addw	a4,a4,a1
 7ee:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f2:	6398                	ld	a4,0(a5)
 7f4:	6310                	ld	a2,0(a4)
 7f6:	a83d                	j	834 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f8:	ff852703          	lw	a4,-8(a0)
 7fc:	9f31                	addw	a4,a4,a2
 7fe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 800:	ff053683          	ld	a3,-16(a0)
 804:	a091                	j	848 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 806:	6398                	ld	a4,0(a5)
 808:	00e7e463          	bltu	a5,a4,810 <free+0x3c>
 80c:	00e6ea63          	bltu	a3,a4,820 <free+0x4c>
{
 810:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 812:	fed7fae3          	bgeu	a5,a3,806 <free+0x32>
 816:	6398                	ld	a4,0(a5)
 818:	00e6e463          	bltu	a3,a4,820 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	fee7eae3          	bltu	a5,a4,810 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 820:	ff852583          	lw	a1,-8(a0)
 824:	6390                	ld	a2,0(a5)
 826:	02059813          	slli	a6,a1,0x20
 82a:	01c85713          	srli	a4,a6,0x1c
 82e:	9736                	add	a4,a4,a3
 830:	fae60de3          	beq	a2,a4,7ea <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 834:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 838:	4790                	lw	a2,8(a5)
 83a:	02061593          	slli	a1,a2,0x20
 83e:	01c5d713          	srli	a4,a1,0x1c
 842:	973e                	add	a4,a4,a5
 844:	fae68ae3          	beq	a3,a4,7f8 <free+0x24>
    p->s.ptr = bp->s.ptr;
 848:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 84a:	00000717          	auipc	a4,0x0
 84e:	7af73b23          	sd	a5,1974(a4) # 1000 <freep>
}
 852:	60a2                	ld	ra,8(sp)
 854:	6402                	ld	s0,0(sp)
 856:	0141                	addi	sp,sp,16
 858:	8082                	ret

000000000000085a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 85a:	7139                	addi	sp,sp,-64
 85c:	fc06                	sd	ra,56(sp)
 85e:	f822                	sd	s0,48(sp)
 860:	f04a                	sd	s2,32(sp)
 862:	ec4e                	sd	s3,24(sp)
 864:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 866:	02051993          	slli	s3,a0,0x20
 86a:	0209d993          	srli	s3,s3,0x20
 86e:	09bd                	addi	s3,s3,15
 870:	0049d993          	srli	s3,s3,0x4
 874:	2985                	addiw	s3,s3,1
 876:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 878:	00000517          	auipc	a0,0x0
 87c:	78853503          	ld	a0,1928(a0) # 1000 <freep>
 880:	c905                	beqz	a0,8b0 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 882:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 884:	4798                	lw	a4,8(a5)
 886:	09377663          	bgeu	a4,s3,912 <malloc+0xb8>
 88a:	f426                	sd	s1,40(sp)
 88c:	e852                	sd	s4,16(sp)
 88e:	e456                	sd	s5,8(sp)
 890:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 892:	8a4e                	mv	s4,s3
 894:	6705                	lui	a4,0x1
 896:	00e9f363          	bgeu	s3,a4,89c <malloc+0x42>
 89a:	6a05                	lui	s4,0x1
 89c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a4:	00000497          	auipc	s1,0x0
 8a8:	75c48493          	addi	s1,s1,1884 # 1000 <freep>
  if(p == (char*)-1)
 8ac:	5afd                	li	s5,-1
 8ae:	a83d                	j	8ec <malloc+0x92>
 8b0:	f426                	sd	s1,40(sp)
 8b2:	e852                	sd	s4,16(sp)
 8b4:	e456                	sd	s5,8(sp)
 8b6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8b8:	00000797          	auipc	a5,0x0
 8bc:	75878793          	addi	a5,a5,1880 # 1010 <base>
 8c0:	00000717          	auipc	a4,0x0
 8c4:	74f73023          	sd	a5,1856(a4) # 1000 <freep>
 8c8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ca:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ce:	b7d1                	j	892 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8d0:	6398                	ld	a4,0(a5)
 8d2:	e118                	sd	a4,0(a0)
 8d4:	a899                	j	92a <malloc+0xd0>
  hp->s.size = nu;
 8d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8da:	0541                	addi	a0,a0,16
 8dc:	ef9ff0ef          	jal	7d4 <free>
  return freep;
 8e0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8e2:	c125                	beqz	a0,942 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e6:	4798                	lw	a4,8(a5)
 8e8:	03277163          	bgeu	a4,s2,90a <malloc+0xb0>
    if(p == freep)
 8ec:	6098                	ld	a4,0(s1)
 8ee:	853e                	mv	a0,a5
 8f0:	fef71ae3          	bne	a4,a5,8e4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8f4:	8552                	mv	a0,s4
 8f6:	b1bff0ef          	jal	410 <sbrk>
  if(p == (char*)-1)
 8fa:	fd551ee3          	bne	a0,s5,8d6 <malloc+0x7c>
        return 0;
 8fe:	4501                	li	a0,0
 900:	74a2                	ld	s1,40(sp)
 902:	6a42                	ld	s4,16(sp)
 904:	6aa2                	ld	s5,8(sp)
 906:	6b02                	ld	s6,0(sp)
 908:	a03d                	j	936 <malloc+0xdc>
 90a:	74a2                	ld	s1,40(sp)
 90c:	6a42                	ld	s4,16(sp)
 90e:	6aa2                	ld	s5,8(sp)
 910:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 912:	fae90fe3          	beq	s2,a4,8d0 <malloc+0x76>
        p->s.size -= nunits;
 916:	4137073b          	subw	a4,a4,s3
 91a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 91c:	02071693          	slli	a3,a4,0x20
 920:	01c6d713          	srli	a4,a3,0x1c
 924:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 926:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 92a:	00000717          	auipc	a4,0x0
 92e:	6ca73b23          	sd	a0,1750(a4) # 1000 <freep>
      return (void*)(p + 1);
 932:	01078513          	addi	a0,a5,16
  }
}
 936:	70e2                	ld	ra,56(sp)
 938:	7442                	ld	s0,48(sp)
 93a:	7902                	ld	s2,32(sp)
 93c:	69e2                	ld	s3,24(sp)
 93e:	6121                	addi	sp,sp,64
 940:	8082                	ret
 942:	74a2                	ld	s1,40(sp)
 944:	6a42                	ld	s4,16(sp)
 946:	6aa2                	ld	s5,8(sp)
 948:	6b02                	ld	s6,0(sp)
 94a:	b7f5                	j	936 <malloc+0xdc>
