
user/_history:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user.h"

#define USR_NSYSCALL 22

int main(int argc, char *argv[])
{
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	f852                	sd	s4,48(sp)
   e:	f456                	sd	s5,40(sp)
  10:	f05a                	sd	s6,32(sp)
  12:	1080                	addi	s0,sp,96
  14:	8aaa                	mv	s5,a0
  16:	8b2e                	mv	s6,a1
    int pid1 = fork();
  18:	39c000ef          	jal	3b4 <fork>
    if (pid1 == 0)
  1c:	cd39                	beqz	a0,7a <main+0x7a>
        exit(0); // child exits

    int pid2 = fork();
  1e:	396000ef          	jal	3b4 <fork>
    if (pid2 == 0)
  22:	cd31                	beqz	a0,7e <main+0x7e>
        exit(0);

    int pid3 = fork();
  24:	390000ef          	jal	3b4 <fork>
    if (pid3 == 0)
  28:	44d5                	li	s1,21
  2a:	cd21                	beqz	a0,82 <main+0x82>
        exit(0);

    // Call read 21 times before calling history
    char buf[1];
    for (int i = 0; i < 21; i++) {
        read(-1, buf, 1); // invalid fd, just to increment syscall count
  2c:	fb840a13          	addi	s4,s0,-72
  30:	4985                	li	s3,1
  32:	597d                	li	s2,-1
  34:	864e                	mv	a2,s3
  36:	85d2                	mv	a1,s4
  38:	854a                	mv	a0,s2
  3a:	39a000ef          	jal	3d4 <read>
    for (int i = 0; i < 21; i++) {
  3e:	34fd                	addiw	s1,s1,-1
  40:	f8f5                	bnez	s1,34 <main+0x34>
    }

    // Perform some system calls to test syscall_stats
    getpid();
  42:	3fa000ef          	jal	43c <getpid>
    uptime();
  46:	40e000ef          	jal	454 <uptime>
    sleep(1);
  4a:	4505                	li	a0,1
  4c:	400000ef          	jal	44c <sleep>
    int fd = open("history.c", 0);
  50:	4581                	li	a1,0
  52:	00001517          	auipc	a0,0x1
  56:	91e50513          	addi	a0,a0,-1762 # 970 <malloc+0xf2>
  5a:	3a2000ef          	jal	3fc <open>
    if (fd >= 0)
  5e:	02055563          	bgez	a0,88 <main+0x88>
    {
        close(fd);
    }
    // Only parent reaches here
    if (argc > 1) {
  62:	4785                	li	a5,1
        struct syscall_stat stat;
        history(syscall_num, &stat);
        if (stat.syscall_name[0] != '\0')
            printf("%d: syscall: %s, #: %d, time: %d\n", syscall_num, stat.syscall_name, stat.count, stat.accum_time);
    } else {
        for (int i = 1; i <= USR_NSYSCALL; i++) {
  64:	84be                	mv	s1,a5
    if (argc > 1) {
  66:	0357c463          	blt	a5,s5,8e <main+0x8e>
            struct syscall_stat stat;
            history(i, &stat);
  6a:	fa040913          	addi	s2,s0,-96
            if (stat.syscall_name[0] != '\0')
                printf("%d: syscall: %s, #: %d, time: %d\n", i, stat.syscall_name, stat.count, stat.accum_time);
  6e:	00001a17          	auipc	s4,0x1
  72:	932a0a13          	addi	s4,s4,-1742 # 9a0 <malloc+0x122>
        for (int i = 1; i <= USR_NSYSCALL; i++) {
  76:	49dd                	li	s3,23
  78:	a0bd                	j	e6 <main+0xe6>
        exit(0); // child exits
  7a:	342000ef          	jal	3bc <exit>
        exit(0);
  7e:	33e000ef          	jal	3bc <exit>
        exit(0);
  82:	4501                	li	a0,0
  84:	338000ef          	jal	3bc <exit>
        close(fd);
  88:	35c000ef          	jal	3e4 <close>
  8c:	bfd9                	j	62 <main+0x62>
        int syscall_num = atoi(argv[1]);
  8e:	008b3503          	ld	a0,8(s6)
  92:	228000ef          	jal	2ba <atoi>
  96:	84aa                	mv	s1,a0
        if (syscall_num < 1 || syscall_num > USR_NSYSCALL) {
  98:	fff5071b          	addiw	a4,a0,-1
  9c:	47d5                	li	a5,21
  9e:	00e7eb63          	bltu	a5,a4,b4 <main+0xb4>
        history(syscall_num, &stat);
  a2:	fa040593          	addi	a1,s0,-96
  a6:	3b6000ef          	jal	45c <history>
        if (stat.syscall_name[0] != '\0')
  aa:	fa044783          	lbu	a5,-96(s0)
  ae:	eb99                	bnez	a5,c4 <main+0xc4>
        }
    }
    return 0;
  b0:	4501                	li	a0,0
  b2:	a8a1                	j	10a <main+0x10a>
            printf("Invalid syscall number.\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	8cc50513          	addi	a0,a0,-1844 # 980 <malloc+0x102>
  bc:	70a000ef          	jal	7c6 <printf>
            return 1;
  c0:	4505                	li	a0,1
  c2:	a0a1                	j	10a <main+0x10a>
            printf("%d: syscall: %s, #: %d, time: %d\n", syscall_num, stat.syscall_name, stat.count, stat.accum_time);
  c4:	fb442703          	lw	a4,-76(s0)
  c8:	fb042683          	lw	a3,-80(s0)
  cc:	fa040613          	addi	a2,s0,-96
  d0:	85a6                	mv	a1,s1
  d2:	00001517          	auipc	a0,0x1
  d6:	8ce50513          	addi	a0,a0,-1842 # 9a0 <malloc+0x122>
  da:	6ec000ef          	jal	7c6 <printf>
  de:	bfc9                	j	b0 <main+0xb0>
        for (int i = 1; i <= USR_NSYSCALL; i++) {
  e0:	2485                	addiw	s1,s1,1
  e2:	03348363          	beq	s1,s3,108 <main+0x108>
            history(i, &stat);
  e6:	85ca                	mv	a1,s2
  e8:	8526                	mv	a0,s1
  ea:	372000ef          	jal	45c <history>
            if (stat.syscall_name[0] != '\0')
  ee:	fa044783          	lbu	a5,-96(s0)
  f2:	d7fd                	beqz	a5,e0 <main+0xe0>
                printf("%d: syscall: %s, #: %d, time: %d\n", i, stat.syscall_name, stat.count, stat.accum_time);
  f4:	fb442703          	lw	a4,-76(s0)
  f8:	fb042683          	lw	a3,-80(s0)
  fc:	864a                	mv	a2,s2
  fe:	85a6                	mv	a1,s1
 100:	8552                	mv	a0,s4
 102:	6c4000ef          	jal	7c6 <printf>
 106:	bfe9                	j	e0 <main+0xe0>
    return 0;
 108:	4501                	li	a0,0
 10a:	60e6                	ld	ra,88(sp)
 10c:	6446                	ld	s0,80(sp)
 10e:	64a6                	ld	s1,72(sp)
 110:	6906                	ld	s2,64(sp)
 112:	79e2                	ld	s3,56(sp)
 114:	7a42                	ld	s4,48(sp)
 116:	7aa2                	ld	s5,40(sp)
 118:	7b02                	ld	s6,32(sp)
 11a:	6125                	addi	sp,sp,96
 11c:	8082                	ret

000000000000011e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  extern int main();
  main();
 126:	edbff0ef          	jal	0 <main>
  exit(0);
 12a:	4501                	li	a0,0
 12c:	290000ef          	jal	3bc <exit>

0000000000000130 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 130:	1141                	addi	sp,sp,-16
 132:	e406                	sd	ra,8(sp)
 134:	e022                	sd	s0,0(sp)
 136:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 138:	87aa                	mv	a5,a0
 13a:	0585                	addi	a1,a1,1
 13c:	0785                	addi	a5,a5,1
 13e:	fff5c703          	lbu	a4,-1(a1)
 142:	fee78fa3          	sb	a4,-1(a5)
 146:	fb75                	bnez	a4,13a <strcpy+0xa>
    ;
  return os;
}
 148:	60a2                	ld	ra,8(sp)
 14a:	6402                	ld	s0,0(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret

0000000000000150 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 150:	1141                	addi	sp,sp,-16
 152:	e406                	sd	ra,8(sp)
 154:	e022                	sd	s0,0(sp)
 156:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cb91                	beqz	a5,170 <strcmp+0x20>
 15e:	0005c703          	lbu	a4,0(a1)
 162:	00f71763          	bne	a4,a5,170 <strcmp+0x20>
    p++, q++;
 166:	0505                	addi	a0,a0,1
 168:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	fbe5                	bnez	a5,15e <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 170:	0005c503          	lbu	a0,0(a1)
}
 174:	40a7853b          	subw	a0,a5,a0
 178:	60a2                	ld	ra,8(sp)
 17a:	6402                	ld	s0,0(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret

0000000000000180 <strlen>:

uint
strlen(const char *s)
{
 180:	1141                	addi	sp,sp,-16
 182:	e406                	sd	ra,8(sp)
 184:	e022                	sd	s0,0(sp)
 186:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 188:	00054783          	lbu	a5,0(a0)
 18c:	cf99                	beqz	a5,1aa <strlen+0x2a>
 18e:	0505                	addi	a0,a0,1
 190:	87aa                	mv	a5,a0
 192:	86be                	mv	a3,a5
 194:	0785                	addi	a5,a5,1
 196:	fff7c703          	lbu	a4,-1(a5)
 19a:	ff65                	bnez	a4,192 <strlen+0x12>
 19c:	40a6853b          	subw	a0,a3,a0
 1a0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1a2:	60a2                	ld	ra,8(sp)
 1a4:	6402                	ld	s0,0(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret
  for(n = 0; s[n]; n++)
 1aa:	4501                	li	a0,0
 1ac:	bfdd                	j	1a2 <strlen+0x22>

00000000000001ae <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e406                	sd	ra,8(sp)
 1b2:	e022                	sd	s0,0(sp)
 1b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b6:	ca19                	beqz	a2,1cc <memset+0x1e>
 1b8:	87aa                	mv	a5,a0
 1ba:	1602                	slli	a2,a2,0x20
 1bc:	9201                	srli	a2,a2,0x20
 1be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c6:	0785                	addi	a5,a5,1
 1c8:	fee79de3          	bne	a5,a4,1c2 <memset+0x14>
  }
  return dst;
}
 1cc:	60a2                	ld	ra,8(sp)
 1ce:	6402                	ld	s0,0(sp)
 1d0:	0141                	addi	sp,sp,16
 1d2:	8082                	ret

00000000000001d4 <strchr>:

char*
strchr(const char *s, char c)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e406                	sd	ra,8(sp)
 1d8:	e022                	sd	s0,0(sp)
 1da:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	cf81                	beqz	a5,1f8 <strchr+0x24>
    if(*s == c)
 1e2:	00f58763          	beq	a1,a5,1f0 <strchr+0x1c>
  for(; *s; s++)
 1e6:	0505                	addi	a0,a0,1
 1e8:	00054783          	lbu	a5,0(a0)
 1ec:	fbfd                	bnez	a5,1e2 <strchr+0xe>
      return (char*)s;
  return 0;
 1ee:	4501                	li	a0,0
}
 1f0:	60a2                	ld	ra,8(sp)
 1f2:	6402                	ld	s0,0(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret
  return 0;
 1f8:	4501                	li	a0,0
 1fa:	bfdd                	j	1f0 <strchr+0x1c>

00000000000001fc <gets>:

char*
gets(char *buf, int max)
{
 1fc:	7159                	addi	sp,sp,-112
 1fe:	f486                	sd	ra,104(sp)
 200:	f0a2                	sd	s0,96(sp)
 202:	eca6                	sd	s1,88(sp)
 204:	e8ca                	sd	s2,80(sp)
 206:	e4ce                	sd	s3,72(sp)
 208:	e0d2                	sd	s4,64(sp)
 20a:	fc56                	sd	s5,56(sp)
 20c:	f85a                	sd	s6,48(sp)
 20e:	f45e                	sd	s7,40(sp)
 210:	f062                	sd	s8,32(sp)
 212:	ec66                	sd	s9,24(sp)
 214:	e86a                	sd	s10,16(sp)
 216:	1880                	addi	s0,sp,112
 218:	8caa                	mv	s9,a0
 21a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21c:	892a                	mv	s2,a0
 21e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 220:	f9f40b13          	addi	s6,s0,-97
 224:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 226:	4ba9                	li	s7,10
 228:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 22a:	8d26                	mv	s10,s1
 22c:	0014899b          	addiw	s3,s1,1
 230:	84ce                	mv	s1,s3
 232:	0349d563          	bge	s3,s4,25c <gets+0x60>
    cc = read(0, &c, 1);
 236:	8656                	mv	a2,s5
 238:	85da                	mv	a1,s6
 23a:	4501                	li	a0,0
 23c:	198000ef          	jal	3d4 <read>
    if(cc < 1)
 240:	00a05e63          	blez	a0,25c <gets+0x60>
    buf[i++] = c;
 244:	f9f44783          	lbu	a5,-97(s0)
 248:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 24c:	01778763          	beq	a5,s7,25a <gets+0x5e>
 250:	0905                	addi	s2,s2,1
 252:	fd879ce3          	bne	a5,s8,22a <gets+0x2e>
    buf[i++] = c;
 256:	8d4e                	mv	s10,s3
 258:	a011                	j	25c <gets+0x60>
 25a:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 25c:	9d66                	add	s10,s10,s9
 25e:	000d0023          	sb	zero,0(s10)
  return buf;
}
 262:	8566                	mv	a0,s9
 264:	70a6                	ld	ra,104(sp)
 266:	7406                	ld	s0,96(sp)
 268:	64e6                	ld	s1,88(sp)
 26a:	6946                	ld	s2,80(sp)
 26c:	69a6                	ld	s3,72(sp)
 26e:	6a06                	ld	s4,64(sp)
 270:	7ae2                	ld	s5,56(sp)
 272:	7b42                	ld	s6,48(sp)
 274:	7ba2                	ld	s7,40(sp)
 276:	7c02                	ld	s8,32(sp)
 278:	6ce2                	ld	s9,24(sp)
 27a:	6d42                	ld	s10,16(sp)
 27c:	6165                	addi	sp,sp,112
 27e:	8082                	ret

0000000000000280 <stat>:

int
stat(const char *n, struct stat *st)
{
 280:	1101                	addi	sp,sp,-32
 282:	ec06                	sd	ra,24(sp)
 284:	e822                	sd	s0,16(sp)
 286:	e04a                	sd	s2,0(sp)
 288:	1000                	addi	s0,sp,32
 28a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28c:	4581                	li	a1,0
 28e:	16e000ef          	jal	3fc <open>
  if(fd < 0)
 292:	02054263          	bltz	a0,2b6 <stat+0x36>
 296:	e426                	sd	s1,8(sp)
 298:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 29a:	85ca                	mv	a1,s2
 29c:	178000ef          	jal	414 <fstat>
 2a0:	892a                	mv	s2,a0
  close(fd);
 2a2:	8526                	mv	a0,s1
 2a4:	140000ef          	jal	3e4 <close>
  return r;
 2a8:	64a2                	ld	s1,8(sp)
}
 2aa:	854a                	mv	a0,s2
 2ac:	60e2                	ld	ra,24(sp)
 2ae:	6442                	ld	s0,16(sp)
 2b0:	6902                	ld	s2,0(sp)
 2b2:	6105                	addi	sp,sp,32
 2b4:	8082                	ret
    return -1;
 2b6:	597d                	li	s2,-1
 2b8:	bfcd                	j	2aa <stat+0x2a>

00000000000002ba <atoi>:

int
atoi(const char *s)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e406                	sd	ra,8(sp)
 2be:	e022                	sd	s0,0(sp)
 2c0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c2:	00054683          	lbu	a3,0(a0)
 2c6:	fd06879b          	addiw	a5,a3,-48
 2ca:	0ff7f793          	zext.b	a5,a5
 2ce:	4625                	li	a2,9
 2d0:	02f66963          	bltu	a2,a5,302 <atoi+0x48>
 2d4:	872a                	mv	a4,a0
  n = 0;
 2d6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2d8:	0705                	addi	a4,a4,1
 2da:	0025179b          	slliw	a5,a0,0x2
 2de:	9fa9                	addw	a5,a5,a0
 2e0:	0017979b          	slliw	a5,a5,0x1
 2e4:	9fb5                	addw	a5,a5,a3
 2e6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ea:	00074683          	lbu	a3,0(a4)
 2ee:	fd06879b          	addiw	a5,a3,-48
 2f2:	0ff7f793          	zext.b	a5,a5
 2f6:	fef671e3          	bgeu	a2,a5,2d8 <atoi+0x1e>
  return n;
}
 2fa:	60a2                	ld	ra,8(sp)
 2fc:	6402                	ld	s0,0(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret
  n = 0;
 302:	4501                	li	a0,0
 304:	bfdd                	j	2fa <atoi+0x40>

0000000000000306 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 306:	1141                	addi	sp,sp,-16
 308:	e406                	sd	ra,8(sp)
 30a:	e022                	sd	s0,0(sp)
 30c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 30e:	02b57563          	bgeu	a0,a1,338 <memmove+0x32>
    while(n-- > 0)
 312:	00c05f63          	blez	a2,330 <memmove+0x2a>
 316:	1602                	slli	a2,a2,0x20
 318:	9201                	srli	a2,a2,0x20
 31a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 31e:	872a                	mv	a4,a0
      *dst++ = *src++;
 320:	0585                	addi	a1,a1,1
 322:	0705                	addi	a4,a4,1
 324:	fff5c683          	lbu	a3,-1(a1)
 328:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 32c:	fee79ae3          	bne	a5,a4,320 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret
    dst += n;
 338:	00c50733          	add	a4,a0,a2
    src += n;
 33c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 33e:	fec059e3          	blez	a2,330 <memmove+0x2a>
 342:	fff6079b          	addiw	a5,a2,-1
 346:	1782                	slli	a5,a5,0x20
 348:	9381                	srli	a5,a5,0x20
 34a:	fff7c793          	not	a5,a5
 34e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 350:	15fd                	addi	a1,a1,-1
 352:	177d                	addi	a4,a4,-1
 354:	0005c683          	lbu	a3,0(a1)
 358:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 35c:	fef71ae3          	bne	a4,a5,350 <memmove+0x4a>
 360:	bfc1                	j	330 <memmove+0x2a>

0000000000000362 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 362:	1141                	addi	sp,sp,-16
 364:	e406                	sd	ra,8(sp)
 366:	e022                	sd	s0,0(sp)
 368:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 36a:	ca0d                	beqz	a2,39c <memcmp+0x3a>
 36c:	fff6069b          	addiw	a3,a2,-1
 370:	1682                	slli	a3,a3,0x20
 372:	9281                	srli	a3,a3,0x20
 374:	0685                	addi	a3,a3,1
 376:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 378:	00054783          	lbu	a5,0(a0)
 37c:	0005c703          	lbu	a4,0(a1)
 380:	00e79863          	bne	a5,a4,390 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 384:	0505                	addi	a0,a0,1
    p2++;
 386:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 388:	fed518e3          	bne	a0,a3,378 <memcmp+0x16>
  }
  return 0;
 38c:	4501                	li	a0,0
 38e:	a019                	j	394 <memcmp+0x32>
      return *p1 - *p2;
 390:	40e7853b          	subw	a0,a5,a4
}
 394:	60a2                	ld	ra,8(sp)
 396:	6402                	ld	s0,0(sp)
 398:	0141                	addi	sp,sp,16
 39a:	8082                	ret
  return 0;
 39c:	4501                	li	a0,0
 39e:	bfdd                	j	394 <memcmp+0x32>

00000000000003a0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a0:	1141                	addi	sp,sp,-16
 3a2:	e406                	sd	ra,8(sp)
 3a4:	e022                	sd	s0,0(sp)
 3a6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a8:	f5fff0ef          	jal	306 <memmove>
}
 3ac:	60a2                	ld	ra,8(sp)
 3ae:	6402                	ld	s0,0(sp)
 3b0:	0141                	addi	sp,sp,16
 3b2:	8082                	ret

00000000000003b4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b4:	4885                	li	a7,1
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3bc:	4889                	li	a7,2
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c4:	488d                	li	a7,3
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3cc:	4891                	li	a7,4
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <read>:
.global read
read:
 li a7, SYS_read
 3d4:	4895                	li	a7,5
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <write>:
.global write
write:
 li a7, SYS_write
 3dc:	48c1                	li	a7,16
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <close>:
.global close
close:
 li a7, SYS_close
 3e4:	48d5                	li	a7,21
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ec:	4899                	li	a7,6
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f4:	489d                	li	a7,7
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <open>:
.global open
open:
 li a7, SYS_open
 3fc:	48bd                	li	a7,15
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 404:	48c5                	li	a7,17
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 40c:	48c9                	li	a7,18
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 414:	48a1                	li	a7,8
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <link>:
.global link
link:
 li a7, SYS_link
 41c:	48cd                	li	a7,19
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 424:	48d1                	li	a7,20
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 42c:	48a5                	li	a7,9
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <dup>:
.global dup
dup:
 li a7, SYS_dup
 434:	48a9                	li	a7,10
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 43c:	48ad                	li	a7,11
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 444:	48b1                	li	a7,12
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 44c:	48b5                	li	a7,13
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 454:	48b9                	li	a7,14
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <history>:
.global history
history:
 li a7, SYS_history
 45c:	48d9                	li	a7,22
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 464:	1101                	addi	sp,sp,-32
 466:	ec06                	sd	ra,24(sp)
 468:	e822                	sd	s0,16(sp)
 46a:	1000                	addi	s0,sp,32
 46c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 470:	4605                	li	a2,1
 472:	fef40593          	addi	a1,s0,-17
 476:	f67ff0ef          	jal	3dc <write>
}
 47a:	60e2                	ld	ra,24(sp)
 47c:	6442                	ld	s0,16(sp)
 47e:	6105                	addi	sp,sp,32
 480:	8082                	ret

0000000000000482 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 482:	7139                	addi	sp,sp,-64
 484:	fc06                	sd	ra,56(sp)
 486:	f822                	sd	s0,48(sp)
 488:	f426                	sd	s1,40(sp)
 48a:	f04a                	sd	s2,32(sp)
 48c:	ec4e                	sd	s3,24(sp)
 48e:	0080                	addi	s0,sp,64
 490:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 492:	c299                	beqz	a3,498 <printint+0x16>
 494:	0605ce63          	bltz	a1,510 <printint+0x8e>
  neg = 0;
 498:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 49a:	fc040313          	addi	t1,s0,-64
  neg = 0;
 49e:	869a                	mv	a3,t1
  i = 0;
 4a0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4a2:	00000817          	auipc	a6,0x0
 4a6:	52e80813          	addi	a6,a6,1326 # 9d0 <digits>
 4aa:	88be                	mv	a7,a5
 4ac:	0017851b          	addiw	a0,a5,1
 4b0:	87aa                	mv	a5,a0
 4b2:	02c5f73b          	remuw	a4,a1,a2
 4b6:	1702                	slli	a4,a4,0x20
 4b8:	9301                	srli	a4,a4,0x20
 4ba:	9742                	add	a4,a4,a6
 4bc:	00074703          	lbu	a4,0(a4)
 4c0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4c4:	872e                	mv	a4,a1
 4c6:	02c5d5bb          	divuw	a1,a1,a2
 4ca:	0685                	addi	a3,a3,1
 4cc:	fcc77fe3          	bgeu	a4,a2,4aa <printint+0x28>
  if(neg)
 4d0:	000e0c63          	beqz	t3,4e8 <printint+0x66>
    buf[i++] = '-';
 4d4:	fd050793          	addi	a5,a0,-48
 4d8:	00878533          	add	a0,a5,s0
 4dc:	02d00793          	li	a5,45
 4e0:	fef50823          	sb	a5,-16(a0)
 4e4:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 4e8:	fff7899b          	addiw	s3,a5,-1
 4ec:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 4f0:	fff4c583          	lbu	a1,-1(s1)
 4f4:	854a                	mv	a0,s2
 4f6:	f6fff0ef          	jal	464 <putc>
  while(--i >= 0)
 4fa:	39fd                	addiw	s3,s3,-1
 4fc:	14fd                	addi	s1,s1,-1
 4fe:	fe09d9e3          	bgez	s3,4f0 <printint+0x6e>
}
 502:	70e2                	ld	ra,56(sp)
 504:	7442                	ld	s0,48(sp)
 506:	74a2                	ld	s1,40(sp)
 508:	7902                	ld	s2,32(sp)
 50a:	69e2                	ld	s3,24(sp)
 50c:	6121                	addi	sp,sp,64
 50e:	8082                	ret
    x = -xx;
 510:	40b005bb          	negw	a1,a1
    neg = 1;
 514:	4e05                	li	t3,1
    x = -xx;
 516:	b751                	j	49a <printint+0x18>

0000000000000518 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 518:	711d                	addi	sp,sp,-96
 51a:	ec86                	sd	ra,88(sp)
 51c:	e8a2                	sd	s0,80(sp)
 51e:	e4a6                	sd	s1,72(sp)
 520:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 522:	0005c483          	lbu	s1,0(a1)
 526:	26048663          	beqz	s1,792 <vprintf+0x27a>
 52a:	e0ca                	sd	s2,64(sp)
 52c:	fc4e                	sd	s3,56(sp)
 52e:	f852                	sd	s4,48(sp)
 530:	f456                	sd	s5,40(sp)
 532:	f05a                	sd	s6,32(sp)
 534:	ec5e                	sd	s7,24(sp)
 536:	e862                	sd	s8,16(sp)
 538:	e466                	sd	s9,8(sp)
 53a:	8b2a                	mv	s6,a0
 53c:	8a2e                	mv	s4,a1
 53e:	8bb2                	mv	s7,a2
  state = 0;
 540:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 542:	4901                	li	s2,0
 544:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 546:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 54a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 54e:	06c00c93          	li	s9,108
 552:	a00d                	j	574 <vprintf+0x5c>
        putc(fd, c0);
 554:	85a6                	mv	a1,s1
 556:	855a                	mv	a0,s6
 558:	f0dff0ef          	jal	464 <putc>
 55c:	a019                	j	562 <vprintf+0x4a>
    } else if(state == '%'){
 55e:	03598363          	beq	s3,s5,584 <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 562:	0019079b          	addiw	a5,s2,1
 566:	893e                	mv	s2,a5
 568:	873e                	mv	a4,a5
 56a:	97d2                	add	a5,a5,s4
 56c:	0007c483          	lbu	s1,0(a5)
 570:	20048963          	beqz	s1,782 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 574:	0004879b          	sext.w	a5,s1
    if(state == 0){
 578:	fe0993e3          	bnez	s3,55e <vprintf+0x46>
      if(c0 == '%'){
 57c:	fd579ce3          	bne	a5,s5,554 <vprintf+0x3c>
        state = '%';
 580:	89be                	mv	s3,a5
 582:	b7c5                	j	562 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 584:	00ea06b3          	add	a3,s4,a4
 588:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 58c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 58e:	c681                	beqz	a3,596 <vprintf+0x7e>
 590:	9752                	add	a4,a4,s4
 592:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 596:	03878e63          	beq	a5,s8,5d2 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 59a:	05978863          	beq	a5,s9,5ea <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 59e:	07500713          	li	a4,117
 5a2:	0ee78263          	beq	a5,a4,686 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5a6:	07800713          	li	a4,120
 5aa:	12e78463          	beq	a5,a4,6d2 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ae:	07000713          	li	a4,112
 5b2:	14e78963          	beq	a5,a4,704 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 5b6:	07300713          	li	a4,115
 5ba:	18e78863          	beq	a5,a4,74a <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5be:	02500713          	li	a4,37
 5c2:	04e79463          	bne	a5,a4,60a <vprintf+0xf2>
        putc(fd, '%');
 5c6:	85ba                	mv	a1,a4
 5c8:	855a                	mv	a0,s6
 5ca:	e9bff0ef          	jal	464 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	bf49                	j	562 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5d2:	008b8493          	addi	s1,s7,8
 5d6:	4685                	li	a3,1
 5d8:	4629                	li	a2,10
 5da:	000ba583          	lw	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	ea3ff0ef          	jal	482 <printint>
 5e4:	8ba6                	mv	s7,s1
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	bfad                	j	562 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ea:	06400793          	li	a5,100
 5ee:	02f68963          	beq	a3,a5,620 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f2:	06c00793          	li	a5,108
 5f6:	04f68263          	beq	a3,a5,63a <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 5fa:	07500793          	li	a5,117
 5fe:	0af68063          	beq	a3,a5,69e <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 602:	07800793          	li	a5,120
 606:	0ef68263          	beq	a3,a5,6ea <vprintf+0x1d2>
        putc(fd, '%');
 60a:	02500593          	li	a1,37
 60e:	855a                	mv	a0,s6
 610:	e55ff0ef          	jal	464 <putc>
        putc(fd, c0);
 614:	85a6                	mv	a1,s1
 616:	855a                	mv	a0,s6
 618:	e4dff0ef          	jal	464 <putc>
      state = 0;
 61c:	4981                	li	s3,0
 61e:	b791                	j	562 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 620:	008b8493          	addi	s1,s7,8
 624:	4685                	li	a3,1
 626:	4629                	li	a2,10
 628:	000ba583          	lw	a1,0(s7)
 62c:	855a                	mv	a0,s6
 62e:	e55ff0ef          	jal	482 <printint>
        i += 1;
 632:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 634:	8ba6                	mv	s7,s1
      state = 0;
 636:	4981                	li	s3,0
        i += 1;
 638:	b72d                	j	562 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 63a:	06400793          	li	a5,100
 63e:	02f60763          	beq	a2,a5,66c <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 642:	07500793          	li	a5,117
 646:	06f60963          	beq	a2,a5,6b8 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 64a:	07800793          	li	a5,120
 64e:	faf61ee3          	bne	a2,a5,60a <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 652:	008b8493          	addi	s1,s7,8
 656:	4681                	li	a3,0
 658:	4641                	li	a2,16
 65a:	000ba583          	lw	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	e23ff0ef          	jal	482 <printint>
        i += 2;
 664:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 666:	8ba6                	mv	s7,s1
      state = 0;
 668:	4981                	li	s3,0
        i += 2;
 66a:	bde5                	j	562 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 66c:	008b8493          	addi	s1,s7,8
 670:	4685                	li	a3,1
 672:	4629                	li	a2,10
 674:	000ba583          	lw	a1,0(s7)
 678:	855a                	mv	a0,s6
 67a:	e09ff0ef          	jal	482 <printint>
        i += 2;
 67e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 680:	8ba6                	mv	s7,s1
      state = 0;
 682:	4981                	li	s3,0
        i += 2;
 684:	bdf9                	j	562 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 686:	008b8493          	addi	s1,s7,8
 68a:	4681                	li	a3,0
 68c:	4629                	li	a2,10
 68e:	000ba583          	lw	a1,0(s7)
 692:	855a                	mv	a0,s6
 694:	defff0ef          	jal	482 <printint>
 698:	8ba6                	mv	s7,s1
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b5d9                	j	562 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 69e:	008b8493          	addi	s1,s7,8
 6a2:	4681                	li	a3,0
 6a4:	4629                	li	a2,10
 6a6:	000ba583          	lw	a1,0(s7)
 6aa:	855a                	mv	a0,s6
 6ac:	dd7ff0ef          	jal	482 <printint>
        i += 1;
 6b0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b2:	8ba6                	mv	s7,s1
      state = 0;
 6b4:	4981                	li	s3,0
        i += 1;
 6b6:	b575                	j	562 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b8:	008b8493          	addi	s1,s7,8
 6bc:	4681                	li	a3,0
 6be:	4629                	li	a2,10
 6c0:	000ba583          	lw	a1,0(s7)
 6c4:	855a                	mv	a0,s6
 6c6:	dbdff0ef          	jal	482 <printint>
        i += 2;
 6ca:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6cc:	8ba6                	mv	s7,s1
      state = 0;
 6ce:	4981                	li	s3,0
        i += 2;
 6d0:	bd49                	j	562 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 6d2:	008b8493          	addi	s1,s7,8
 6d6:	4681                	li	a3,0
 6d8:	4641                	li	a2,16
 6da:	000ba583          	lw	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	da3ff0ef          	jal	482 <printint>
 6e4:	8ba6                	mv	s7,s1
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	bdad                	j	562 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ea:	008b8493          	addi	s1,s7,8
 6ee:	4681                	li	a3,0
 6f0:	4641                	li	a2,16
 6f2:	000ba583          	lw	a1,0(s7)
 6f6:	855a                	mv	a0,s6
 6f8:	d8bff0ef          	jal	482 <printint>
        i += 1;
 6fc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fe:	8ba6                	mv	s7,s1
      state = 0;
 700:	4981                	li	s3,0
        i += 1;
 702:	b585                	j	562 <vprintf+0x4a>
 704:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 706:	008b8d13          	addi	s10,s7,8
 70a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 70e:	03000593          	li	a1,48
 712:	855a                	mv	a0,s6
 714:	d51ff0ef          	jal	464 <putc>
  putc(fd, 'x');
 718:	07800593          	li	a1,120
 71c:	855a                	mv	a0,s6
 71e:	d47ff0ef          	jal	464 <putc>
 722:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 724:	00000b97          	auipc	s7,0x0
 728:	2acb8b93          	addi	s7,s7,684 # 9d0 <digits>
 72c:	03c9d793          	srli	a5,s3,0x3c
 730:	97de                	add	a5,a5,s7
 732:	0007c583          	lbu	a1,0(a5)
 736:	855a                	mv	a0,s6
 738:	d2dff0ef          	jal	464 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 73c:	0992                	slli	s3,s3,0x4
 73e:	34fd                	addiw	s1,s1,-1
 740:	f4f5                	bnez	s1,72c <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 742:	8bea                	mv	s7,s10
      state = 0;
 744:	4981                	li	s3,0
 746:	6d02                	ld	s10,0(sp)
 748:	bd29                	j	562 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 74a:	008b8993          	addi	s3,s7,8
 74e:	000bb483          	ld	s1,0(s7)
 752:	cc91                	beqz	s1,76e <vprintf+0x256>
        for(; *s; s++)
 754:	0004c583          	lbu	a1,0(s1)
 758:	c195                	beqz	a1,77c <vprintf+0x264>
          putc(fd, *s);
 75a:	855a                	mv	a0,s6
 75c:	d09ff0ef          	jal	464 <putc>
        for(; *s; s++)
 760:	0485                	addi	s1,s1,1
 762:	0004c583          	lbu	a1,0(s1)
 766:	f9f5                	bnez	a1,75a <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 768:	8bce                	mv	s7,s3
      state = 0;
 76a:	4981                	li	s3,0
 76c:	bbdd                	j	562 <vprintf+0x4a>
          s = "(null)";
 76e:	00000497          	auipc	s1,0x0
 772:	25a48493          	addi	s1,s1,602 # 9c8 <malloc+0x14a>
        for(; *s; s++)
 776:	02800593          	li	a1,40
 77a:	b7c5                	j	75a <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 77c:	8bce                	mv	s7,s3
      state = 0;
 77e:	4981                	li	s3,0
 780:	b3cd                	j	562 <vprintf+0x4a>
 782:	6906                	ld	s2,64(sp)
 784:	79e2                	ld	s3,56(sp)
 786:	7a42                	ld	s4,48(sp)
 788:	7aa2                	ld	s5,40(sp)
 78a:	7b02                	ld	s6,32(sp)
 78c:	6be2                	ld	s7,24(sp)
 78e:	6c42                	ld	s8,16(sp)
 790:	6ca2                	ld	s9,8(sp)
    }
  }
}
 792:	60e6                	ld	ra,88(sp)
 794:	6446                	ld	s0,80(sp)
 796:	64a6                	ld	s1,72(sp)
 798:	6125                	addi	sp,sp,96
 79a:	8082                	ret

000000000000079c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 79c:	715d                	addi	sp,sp,-80
 79e:	ec06                	sd	ra,24(sp)
 7a0:	e822                	sd	s0,16(sp)
 7a2:	1000                	addi	s0,sp,32
 7a4:	e010                	sd	a2,0(s0)
 7a6:	e414                	sd	a3,8(s0)
 7a8:	e818                	sd	a4,16(s0)
 7aa:	ec1c                	sd	a5,24(s0)
 7ac:	03043023          	sd	a6,32(s0)
 7b0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7b4:	8622                	mv	a2,s0
 7b6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ba:	d5fff0ef          	jal	518 <vprintf>
}
 7be:	60e2                	ld	ra,24(sp)
 7c0:	6442                	ld	s0,16(sp)
 7c2:	6161                	addi	sp,sp,80
 7c4:	8082                	ret

00000000000007c6 <printf>:

void
printf(const char *fmt, ...)
{
 7c6:	711d                	addi	sp,sp,-96
 7c8:	ec06                	sd	ra,24(sp)
 7ca:	e822                	sd	s0,16(sp)
 7cc:	1000                	addi	s0,sp,32
 7ce:	e40c                	sd	a1,8(s0)
 7d0:	e810                	sd	a2,16(s0)
 7d2:	ec14                	sd	a3,24(s0)
 7d4:	f018                	sd	a4,32(s0)
 7d6:	f41c                	sd	a5,40(s0)
 7d8:	03043823          	sd	a6,48(s0)
 7dc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e0:	00840613          	addi	a2,s0,8
 7e4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e8:	85aa                	mv	a1,a0
 7ea:	4505                	li	a0,1
 7ec:	d2dff0ef          	jal	518 <vprintf>
}
 7f0:	60e2                	ld	ra,24(sp)
 7f2:	6442                	ld	s0,16(sp)
 7f4:	6125                	addi	sp,sp,96
 7f6:	8082                	ret

00000000000007f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f8:	1141                	addi	sp,sp,-16
 7fa:	e406                	sd	ra,8(sp)
 7fc:	e022                	sd	s0,0(sp)
 7fe:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 800:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 804:	00000797          	auipc	a5,0x0
 808:	7fc7b783          	ld	a5,2044(a5) # 1000 <freep>
 80c:	a02d                	j	836 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 80e:	4618                	lw	a4,8(a2)
 810:	9f2d                	addw	a4,a4,a1
 812:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 816:	6398                	ld	a4,0(a5)
 818:	6310                	ld	a2,0(a4)
 81a:	a83d                	j	858 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 81c:	ff852703          	lw	a4,-8(a0)
 820:	9f31                	addw	a4,a4,a2
 822:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 824:	ff053683          	ld	a3,-16(a0)
 828:	a091                	j	86c <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82a:	6398                	ld	a4,0(a5)
 82c:	00e7e463          	bltu	a5,a4,834 <free+0x3c>
 830:	00e6ea63          	bltu	a3,a4,844 <free+0x4c>
{
 834:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 836:	fed7fae3          	bgeu	a5,a3,82a <free+0x32>
 83a:	6398                	ld	a4,0(a5)
 83c:	00e6e463          	bltu	a3,a4,844 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 840:	fee7eae3          	bltu	a5,a4,834 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 844:	ff852583          	lw	a1,-8(a0)
 848:	6390                	ld	a2,0(a5)
 84a:	02059813          	slli	a6,a1,0x20
 84e:	01c85713          	srli	a4,a6,0x1c
 852:	9736                	add	a4,a4,a3
 854:	fae60de3          	beq	a2,a4,80e <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 858:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 85c:	4790                	lw	a2,8(a5)
 85e:	02061593          	slli	a1,a2,0x20
 862:	01c5d713          	srli	a4,a1,0x1c
 866:	973e                	add	a4,a4,a5
 868:	fae68ae3          	beq	a3,a4,81c <free+0x24>
    p->s.ptr = bp->s.ptr;
 86c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 86e:	00000717          	auipc	a4,0x0
 872:	78f73923          	sd	a5,1938(a4) # 1000 <freep>
}
 876:	60a2                	ld	ra,8(sp)
 878:	6402                	ld	s0,0(sp)
 87a:	0141                	addi	sp,sp,16
 87c:	8082                	ret

000000000000087e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 87e:	7139                	addi	sp,sp,-64
 880:	fc06                	sd	ra,56(sp)
 882:	f822                	sd	s0,48(sp)
 884:	f04a                	sd	s2,32(sp)
 886:	ec4e                	sd	s3,24(sp)
 888:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 88a:	02051993          	slli	s3,a0,0x20
 88e:	0209d993          	srli	s3,s3,0x20
 892:	09bd                	addi	s3,s3,15
 894:	0049d993          	srli	s3,s3,0x4
 898:	2985                	addiw	s3,s3,1
 89a:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 89c:	00000517          	auipc	a0,0x0
 8a0:	76453503          	ld	a0,1892(a0) # 1000 <freep>
 8a4:	c905                	beqz	a0,8d4 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a8:	4798                	lw	a4,8(a5)
 8aa:	09377663          	bgeu	a4,s3,936 <malloc+0xb8>
 8ae:	f426                	sd	s1,40(sp)
 8b0:	e852                	sd	s4,16(sp)
 8b2:	e456                	sd	s5,8(sp)
 8b4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8b6:	8a4e                	mv	s4,s3
 8b8:	6705                	lui	a4,0x1
 8ba:	00e9f363          	bgeu	s3,a4,8c0 <malloc+0x42>
 8be:	6a05                	lui	s4,0x1
 8c0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c8:	00000497          	auipc	s1,0x0
 8cc:	73848493          	addi	s1,s1,1848 # 1000 <freep>
  if(p == (char*)-1)
 8d0:	5afd                	li	s5,-1
 8d2:	a83d                	j	910 <malloc+0x92>
 8d4:	f426                	sd	s1,40(sp)
 8d6:	e852                	sd	s4,16(sp)
 8d8:	e456                	sd	s5,8(sp)
 8da:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8dc:	00000797          	auipc	a5,0x0
 8e0:	73478793          	addi	a5,a5,1844 # 1010 <base>
 8e4:	00000717          	auipc	a4,0x0
 8e8:	70f73e23          	sd	a5,1820(a4) # 1000 <freep>
 8ec:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ee:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f2:	b7d1                	j	8b6 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8f4:	6398                	ld	a4,0(a5)
 8f6:	e118                	sd	a4,0(a0)
 8f8:	a899                	j	94e <malloc+0xd0>
  hp->s.size = nu;
 8fa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8fe:	0541                	addi	a0,a0,16
 900:	ef9ff0ef          	jal	7f8 <free>
  return freep;
 904:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 906:	c125                	beqz	a0,966 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 908:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90a:	4798                	lw	a4,8(a5)
 90c:	03277163          	bgeu	a4,s2,92e <malloc+0xb0>
    if(p == freep)
 910:	6098                	ld	a4,0(s1)
 912:	853e                	mv	a0,a5
 914:	fef71ae3          	bne	a4,a5,908 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 918:	8552                	mv	a0,s4
 91a:	b2bff0ef          	jal	444 <sbrk>
  if(p == (char*)-1)
 91e:	fd551ee3          	bne	a0,s5,8fa <malloc+0x7c>
        return 0;
 922:	4501                	li	a0,0
 924:	74a2                	ld	s1,40(sp)
 926:	6a42                	ld	s4,16(sp)
 928:	6aa2                	ld	s5,8(sp)
 92a:	6b02                	ld	s6,0(sp)
 92c:	a03d                	j	95a <malloc+0xdc>
 92e:	74a2                	ld	s1,40(sp)
 930:	6a42                	ld	s4,16(sp)
 932:	6aa2                	ld	s5,8(sp)
 934:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 936:	fae90fe3          	beq	s2,a4,8f4 <malloc+0x76>
        p->s.size -= nunits;
 93a:	4137073b          	subw	a4,a4,s3
 93e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 940:	02071693          	slli	a3,a4,0x20
 944:	01c6d713          	srli	a4,a3,0x1c
 948:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 94a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 94e:	00000717          	auipc	a4,0x0
 952:	6aa73923          	sd	a0,1714(a4) # 1000 <freep>
      return (void*)(p + 1);
 956:	01078513          	addi	a0,a5,16
  }
}
 95a:	70e2                	ld	ra,56(sp)
 95c:	7442                	ld	s0,48(sp)
 95e:	7902                	ld	s2,32(sp)
 960:	69e2                	ld	s3,24(sp)
 962:	6121                	addi	sp,sp,64
 964:	8082                	ret
 966:	74a2                	ld	s1,40(sp)
 968:	6a42                	ld	s4,16(sp)
 96a:	6aa2                	ld	s5,8(sp)
 96c:	6b02                	ld	s6,0(sp)
 96e:	b7f5                	j	95a <malloc+0xdc>
