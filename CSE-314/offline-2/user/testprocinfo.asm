
user/_testprocinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "./kernel/types.h"
#include "user.h"


int main(void)
{
   0:	d9010113          	addi	sp,sp,-624
   4:	26113423          	sd	ra,616(sp)
   8:	26813023          	sd	s0,608(sp)
   c:	1c80                	addi	s0,sp,624
    struct pstat st;
    int ret = getpinfo(&st);
   e:	d9040513          	addi	a0,s0,-624
  12:	400000ef          	jal	412 <getpinfo>
    if (ret != 0)
  16:	c105                	beqz	a0,36 <main+0x36>
  18:	24913c23          	sd	s1,600(sp)
  1c:	25213823          	sd	s2,592(sp)
  20:	25313423          	sd	s3,584(sp)
    {
        printf("[testprocinfo] getpinfo failed\n");
  24:	00001517          	auipc	a0,0x1
  28:	90c50513          	addi	a0,a0,-1780 # 930 <malloc+0xfc>
  2c:	750000ef          	jal	77c <printf>
        exit(1);
  30:	4505                	li	a0,1
  32:	330000ef          	jal	362 <exit>
  36:	24913c23          	sd	s1,600(sp)
  3a:	25213823          	sd	s2,592(sp)
  3e:	25313423          	sd	s3,584(sp)
    }
    printf("%-5s %-5s %-7s %-7s %-7s %-7s %-3s\n", "PID", "INUSE", "TICKETS_O", "TICKETS_C", "SLICES", "QUEUE", "Q");
  42:	00001897          	auipc	a7,0x1
  46:	90e88893          	addi	a7,a7,-1778 # 950 <malloc+0x11c>
  4a:	00001817          	auipc	a6,0x1
  4e:	90e80813          	addi	a6,a6,-1778 # 958 <malloc+0x124>
  52:	00001797          	auipc	a5,0x1
  56:	90e78793          	addi	a5,a5,-1778 # 960 <malloc+0x12c>
  5a:	00001717          	auipc	a4,0x1
  5e:	90e70713          	addi	a4,a4,-1778 # 968 <malloc+0x134>
  62:	00001697          	auipc	a3,0x1
  66:	91668693          	addi	a3,a3,-1770 # 978 <malloc+0x144>
  6a:	00001617          	auipc	a2,0x1
  6e:	91e60613          	addi	a2,a2,-1762 # 988 <malloc+0x154>
  72:	00001597          	auipc	a1,0x1
  76:	91e58593          	addi	a1,a1,-1762 # 990 <malloc+0x15c>
  7a:	00001517          	auipc	a0,0x1
  7e:	91e50513          	addi	a0,a0,-1762 # 998 <malloc+0x164>
  82:	6fa000ef          	jal	77c <printf>
    for (int i = 0; i < NSYSCALL; i++)
  86:	d9040493          	addi	s1,s0,-624
  8a:	df040913          	addi	s2,s0,-528
    {
        if (st.inuse[i])
        {
            printf("%-5d %-5d %-7d %-7d %-7d %-7d %-3d\n",
  8e:	00001997          	auipc	s3,0x1
  92:	93298993          	addi	s3,s3,-1742 # 9c0 <malloc+0x18c>
  96:	a021                	j	9e <main+0x9e>
    for (int i = 0; i < NSYSCALL; i++)
  98:	0491                	addi	s1,s1,4
  9a:	03248263          	beq	s1,s2,be <main+0xbe>
        if (st.inuse[i])
  9e:	50b0                	lw	a2,96(s1)
  a0:	de65                	beqz	a2,98 <main+0x98>
            printf("%-5d %-5d %-7d %-7d %-7d %-7d %-3d\n",
  a2:	0c04a803          	lw	a6,192(s1)
  a6:	88c2                	mv	a7,a6
  a8:	1e04a783          	lw	a5,480(s1)
  ac:	1804a703          	lw	a4,384(s1)
  b0:	1204a683          	lw	a3,288(s1)
  b4:	408c                	lw	a1,0(s1)
  b6:	854e                	mv	a0,s3
  b8:	6c4000ef          	jal	77c <printf>
  bc:	bff1                	j	98 <main+0x98>
                st.time_slices[i],
                st.inQ[i],
                st.inQ[i]);
        }
    }
    exit(0);
  be:	4501                	li	a0,0
  c0:	2a2000ef          	jal	362 <exit>

00000000000000c4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e406                	sd	ra,8(sp)
  c8:	e022                	sd	s0,0(sp)
  ca:	0800                	addi	s0,sp,16
  extern int main();
  main();
  cc:	f35ff0ef          	jal	0 <main>
  exit(0);
  d0:	4501                	li	a0,0
  d2:	290000ef          	jal	362 <exit>

00000000000000d6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e406                	sd	ra,8(sp)
  da:	e022                	sd	s0,0(sp)
  dc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  de:	87aa                	mv	a5,a0
  e0:	0585                	addi	a1,a1,1
  e2:	0785                	addi	a5,a5,1
  e4:	fff5c703          	lbu	a4,-1(a1)
  e8:	fee78fa3          	sb	a4,-1(a5)
  ec:	fb75                	bnez	a4,e0 <strcpy+0xa>
    ;
  return os;
}
  ee:	60a2                	ld	ra,8(sp)
  f0:	6402                	ld	s0,0(sp)
  f2:	0141                	addi	sp,sp,16
  f4:	8082                	ret

00000000000000f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e406                	sd	ra,8(sp)
  fa:	e022                	sd	s0,0(sp)
  fc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  fe:	00054783          	lbu	a5,0(a0)
 102:	cb91                	beqz	a5,116 <strcmp+0x20>
 104:	0005c703          	lbu	a4,0(a1)
 108:	00f71763          	bne	a4,a5,116 <strcmp+0x20>
    p++, q++;
 10c:	0505                	addi	a0,a0,1
 10e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 110:	00054783          	lbu	a5,0(a0)
 114:	fbe5                	bnez	a5,104 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 116:	0005c503          	lbu	a0,0(a1)
}
 11a:	40a7853b          	subw	a0,a5,a0
 11e:	60a2                	ld	ra,8(sp)
 120:	6402                	ld	s0,0(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strlen>:

uint
strlen(const char *s)
{
 126:	1141                	addi	sp,sp,-16
 128:	e406                	sd	ra,8(sp)
 12a:	e022                	sd	s0,0(sp)
 12c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 12e:	00054783          	lbu	a5,0(a0)
 132:	cf99                	beqz	a5,150 <strlen+0x2a>
 134:	0505                	addi	a0,a0,1
 136:	87aa                	mv	a5,a0
 138:	86be                	mv	a3,a5
 13a:	0785                	addi	a5,a5,1
 13c:	fff7c703          	lbu	a4,-1(a5)
 140:	ff65                	bnez	a4,138 <strlen+0x12>
 142:	40a6853b          	subw	a0,a3,a0
 146:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 148:	60a2                	ld	ra,8(sp)
 14a:	6402                	ld	s0,0(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret
  for(n = 0; s[n]; n++)
 150:	4501                	li	a0,0
 152:	bfdd                	j	148 <strlen+0x22>

0000000000000154 <memset>:

void*
memset(void *dst, int c, uint n)
{
 154:	1141                	addi	sp,sp,-16
 156:	e406                	sd	ra,8(sp)
 158:	e022                	sd	s0,0(sp)
 15a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 15c:	ca19                	beqz	a2,172 <memset+0x1e>
 15e:	87aa                	mv	a5,a0
 160:	1602                	slli	a2,a2,0x20
 162:	9201                	srli	a2,a2,0x20
 164:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 168:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 16c:	0785                	addi	a5,a5,1
 16e:	fee79de3          	bne	a5,a4,168 <memset+0x14>
  }
  return dst;
}
 172:	60a2                	ld	ra,8(sp)
 174:	6402                	ld	s0,0(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret

000000000000017a <strchr>:

char*
strchr(const char *s, char c)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e406                	sd	ra,8(sp)
 17e:	e022                	sd	s0,0(sp)
 180:	0800                	addi	s0,sp,16
  for(; *s; s++)
 182:	00054783          	lbu	a5,0(a0)
 186:	cf81                	beqz	a5,19e <strchr+0x24>
    if(*s == c)
 188:	00f58763          	beq	a1,a5,196 <strchr+0x1c>
  for(; *s; s++)
 18c:	0505                	addi	a0,a0,1
 18e:	00054783          	lbu	a5,0(a0)
 192:	fbfd                	bnez	a5,188 <strchr+0xe>
      return (char*)s;
  return 0;
 194:	4501                	li	a0,0
}
 196:	60a2                	ld	ra,8(sp)
 198:	6402                	ld	s0,0(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret
  return 0;
 19e:	4501                	li	a0,0
 1a0:	bfdd                	j	196 <strchr+0x1c>

00000000000001a2 <gets>:

char*
gets(char *buf, int max)
{
 1a2:	7159                	addi	sp,sp,-112
 1a4:	f486                	sd	ra,104(sp)
 1a6:	f0a2                	sd	s0,96(sp)
 1a8:	eca6                	sd	s1,88(sp)
 1aa:	e8ca                	sd	s2,80(sp)
 1ac:	e4ce                	sd	s3,72(sp)
 1ae:	e0d2                	sd	s4,64(sp)
 1b0:	fc56                	sd	s5,56(sp)
 1b2:	f85a                	sd	s6,48(sp)
 1b4:	f45e                	sd	s7,40(sp)
 1b6:	f062                	sd	s8,32(sp)
 1b8:	ec66                	sd	s9,24(sp)
 1ba:	e86a                	sd	s10,16(sp)
 1bc:	1880                	addi	s0,sp,112
 1be:	8caa                	mv	s9,a0
 1c0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c2:	892a                	mv	s2,a0
 1c4:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1c6:	f9f40b13          	addi	s6,s0,-97
 1ca:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1cc:	4ba9                	li	s7,10
 1ce:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 1d0:	8d26                	mv	s10,s1
 1d2:	0014899b          	addiw	s3,s1,1
 1d6:	84ce                	mv	s1,s3
 1d8:	0349d563          	bge	s3,s4,202 <gets+0x60>
    cc = read(0, &c, 1);
 1dc:	8656                	mv	a2,s5
 1de:	85da                	mv	a1,s6
 1e0:	4501                	li	a0,0
 1e2:	198000ef          	jal	37a <read>
    if(cc < 1)
 1e6:	00a05e63          	blez	a0,202 <gets+0x60>
    buf[i++] = c;
 1ea:	f9f44783          	lbu	a5,-97(s0)
 1ee:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f2:	01778763          	beq	a5,s7,200 <gets+0x5e>
 1f6:	0905                	addi	s2,s2,1
 1f8:	fd879ce3          	bne	a5,s8,1d0 <gets+0x2e>
    buf[i++] = c;
 1fc:	8d4e                	mv	s10,s3
 1fe:	a011                	j	202 <gets+0x60>
 200:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 202:	9d66                	add	s10,s10,s9
 204:	000d0023          	sb	zero,0(s10)
  return buf;
}
 208:	8566                	mv	a0,s9
 20a:	70a6                	ld	ra,104(sp)
 20c:	7406                	ld	s0,96(sp)
 20e:	64e6                	ld	s1,88(sp)
 210:	6946                	ld	s2,80(sp)
 212:	69a6                	ld	s3,72(sp)
 214:	6a06                	ld	s4,64(sp)
 216:	7ae2                	ld	s5,56(sp)
 218:	7b42                	ld	s6,48(sp)
 21a:	7ba2                	ld	s7,40(sp)
 21c:	7c02                	ld	s8,32(sp)
 21e:	6ce2                	ld	s9,24(sp)
 220:	6d42                	ld	s10,16(sp)
 222:	6165                	addi	sp,sp,112
 224:	8082                	ret

0000000000000226 <stat>:

int
stat(const char *n, struct stat *st)
{
 226:	1101                	addi	sp,sp,-32
 228:	ec06                	sd	ra,24(sp)
 22a:	e822                	sd	s0,16(sp)
 22c:	e04a                	sd	s2,0(sp)
 22e:	1000                	addi	s0,sp,32
 230:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 232:	4581                	li	a1,0
 234:	16e000ef          	jal	3a2 <open>
  if(fd < 0)
 238:	02054263          	bltz	a0,25c <stat+0x36>
 23c:	e426                	sd	s1,8(sp)
 23e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 240:	85ca                	mv	a1,s2
 242:	178000ef          	jal	3ba <fstat>
 246:	892a                	mv	s2,a0
  close(fd);
 248:	8526                	mv	a0,s1
 24a:	140000ef          	jal	38a <close>
  return r;
 24e:	64a2                	ld	s1,8(sp)
}
 250:	854a                	mv	a0,s2
 252:	60e2                	ld	ra,24(sp)
 254:	6442                	ld	s0,16(sp)
 256:	6902                	ld	s2,0(sp)
 258:	6105                	addi	sp,sp,32
 25a:	8082                	ret
    return -1;
 25c:	597d                	li	s2,-1
 25e:	bfcd                	j	250 <stat+0x2a>

0000000000000260 <atoi>:

int
atoi(const char *s)
{
 260:	1141                	addi	sp,sp,-16
 262:	e406                	sd	ra,8(sp)
 264:	e022                	sd	s0,0(sp)
 266:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 268:	00054683          	lbu	a3,0(a0)
 26c:	fd06879b          	addiw	a5,a3,-48
 270:	0ff7f793          	zext.b	a5,a5
 274:	4625                	li	a2,9
 276:	02f66963          	bltu	a2,a5,2a8 <atoi+0x48>
 27a:	872a                	mv	a4,a0
  n = 0;
 27c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 27e:	0705                	addi	a4,a4,1
 280:	0025179b          	slliw	a5,a0,0x2
 284:	9fa9                	addw	a5,a5,a0
 286:	0017979b          	slliw	a5,a5,0x1
 28a:	9fb5                	addw	a5,a5,a3
 28c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 290:	00074683          	lbu	a3,0(a4)
 294:	fd06879b          	addiw	a5,a3,-48
 298:	0ff7f793          	zext.b	a5,a5
 29c:	fef671e3          	bgeu	a2,a5,27e <atoi+0x1e>
  return n;
}
 2a0:	60a2                	ld	ra,8(sp)
 2a2:	6402                	ld	s0,0(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret
  n = 0;
 2a8:	4501                	li	a0,0
 2aa:	bfdd                	j	2a0 <atoi+0x40>

00000000000002ac <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e406                	sd	ra,8(sp)
 2b0:	e022                	sd	s0,0(sp)
 2b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b4:	02b57563          	bgeu	a0,a1,2de <memmove+0x32>
    while(n-- > 0)
 2b8:	00c05f63          	blez	a2,2d6 <memmove+0x2a>
 2bc:	1602                	slli	a2,a2,0x20
 2be:	9201                	srli	a2,a2,0x20
 2c0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c6:	0585                	addi	a1,a1,1
 2c8:	0705                	addi	a4,a4,1
 2ca:	fff5c683          	lbu	a3,-1(a1)
 2ce:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d2:	fee79ae3          	bne	a5,a4,2c6 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d6:	60a2                	ld	ra,8(sp)
 2d8:	6402                	ld	s0,0(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret
    dst += n;
 2de:	00c50733          	add	a4,a0,a2
    src += n;
 2e2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e4:	fec059e3          	blez	a2,2d6 <memmove+0x2a>
 2e8:	fff6079b          	addiw	a5,a2,-1
 2ec:	1782                	slli	a5,a5,0x20
 2ee:	9381                	srli	a5,a5,0x20
 2f0:	fff7c793          	not	a5,a5
 2f4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f6:	15fd                	addi	a1,a1,-1
 2f8:	177d                	addi	a4,a4,-1
 2fa:	0005c683          	lbu	a3,0(a1)
 2fe:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 302:	fef71ae3          	bne	a4,a5,2f6 <memmove+0x4a>
 306:	bfc1                	j	2d6 <memmove+0x2a>

0000000000000308 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 310:	ca0d                	beqz	a2,342 <memcmp+0x3a>
 312:	fff6069b          	addiw	a3,a2,-1
 316:	1682                	slli	a3,a3,0x20
 318:	9281                	srli	a3,a3,0x20
 31a:	0685                	addi	a3,a3,1
 31c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 31e:	00054783          	lbu	a5,0(a0)
 322:	0005c703          	lbu	a4,0(a1)
 326:	00e79863          	bne	a5,a4,336 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 32a:	0505                	addi	a0,a0,1
    p2++;
 32c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 32e:	fed518e3          	bne	a0,a3,31e <memcmp+0x16>
  }
  return 0;
 332:	4501                	li	a0,0
 334:	a019                	j	33a <memcmp+0x32>
      return *p1 - *p2;
 336:	40e7853b          	subw	a0,a5,a4
}
 33a:	60a2                	ld	ra,8(sp)
 33c:	6402                	ld	s0,0(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  return 0;
 342:	4501                	li	a0,0
 344:	bfdd                	j	33a <memcmp+0x32>

0000000000000346 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 346:	1141                	addi	sp,sp,-16
 348:	e406                	sd	ra,8(sp)
 34a:	e022                	sd	s0,0(sp)
 34c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 34e:	f5fff0ef          	jal	2ac <memmove>
}
 352:	60a2                	ld	ra,8(sp)
 354:	6402                	ld	s0,0(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret

000000000000035a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 35a:	4885                	li	a7,1
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <exit>:
.global exit
exit:
 li a7, SYS_exit
 362:	4889                	li	a7,2
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <wait>:
.global wait
wait:
 li a7, SYS_wait
 36a:	488d                	li	a7,3
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 372:	4891                	li	a7,4
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <read>:
.global read
read:
 li a7, SYS_read
 37a:	4895                	li	a7,5
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <write>:
.global write
write:
 li a7, SYS_write
 382:	48c1                	li	a7,16
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <close>:
.global close
close:
 li a7, SYS_close
 38a:	48d5                	li	a7,21
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <kill>:
.global kill
kill:
 li a7, SYS_kill
 392:	4899                	li	a7,6
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <exec>:
.global exec
exec:
 li a7, SYS_exec
 39a:	489d                	li	a7,7
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <open>:
.global open
open:
 li a7, SYS_open
 3a2:	48bd                	li	a7,15
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3aa:	48c5                	li	a7,17
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b2:	48c9                	li	a7,18
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ba:	48a1                	li	a7,8
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <link>:
.global link
link:
 li a7, SYS_link
 3c2:	48cd                	li	a7,19
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ca:	48d1                	li	a7,20
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d2:	48a5                	li	a7,9
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <dup>:
.global dup
dup:
 li a7, SYS_dup
 3da:	48a9                	li	a7,10
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e2:	48ad                	li	a7,11
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ea:	48b1                	li	a7,12
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3f2:	48b5                	li	a7,13
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3fa:	48b9                	li	a7,14
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <history>:
.global history
history:
 li a7, SYS_history
 402:	48d9                	li	a7,22
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 40a:	48dd                	li	a7,23
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 412:	48dd                	li	a7,23
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 41a:	1101                	addi	sp,sp,-32
 41c:	ec06                	sd	ra,24(sp)
 41e:	e822                	sd	s0,16(sp)
 420:	1000                	addi	s0,sp,32
 422:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 426:	4605                	li	a2,1
 428:	fef40593          	addi	a1,s0,-17
 42c:	f57ff0ef          	jal	382 <write>
}
 430:	60e2                	ld	ra,24(sp)
 432:	6442                	ld	s0,16(sp)
 434:	6105                	addi	sp,sp,32
 436:	8082                	ret

0000000000000438 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 438:	7139                	addi	sp,sp,-64
 43a:	fc06                	sd	ra,56(sp)
 43c:	f822                	sd	s0,48(sp)
 43e:	f426                	sd	s1,40(sp)
 440:	f04a                	sd	s2,32(sp)
 442:	ec4e                	sd	s3,24(sp)
 444:	0080                	addi	s0,sp,64
 446:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 448:	c299                	beqz	a3,44e <printint+0x16>
 44a:	0605ce63          	bltz	a1,4c6 <printint+0x8e>
  neg = 0;
 44e:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 450:	fc040313          	addi	t1,s0,-64
  neg = 0;
 454:	869a                	mv	a3,t1
  i = 0;
 456:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 458:	00000817          	auipc	a6,0x0
 45c:	59880813          	addi	a6,a6,1432 # 9f0 <digits>
 460:	88be                	mv	a7,a5
 462:	0017851b          	addiw	a0,a5,1
 466:	87aa                	mv	a5,a0
 468:	02c5f73b          	remuw	a4,a1,a2
 46c:	1702                	slli	a4,a4,0x20
 46e:	9301                	srli	a4,a4,0x20
 470:	9742                	add	a4,a4,a6
 472:	00074703          	lbu	a4,0(a4)
 476:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 47a:	872e                	mv	a4,a1
 47c:	02c5d5bb          	divuw	a1,a1,a2
 480:	0685                	addi	a3,a3,1
 482:	fcc77fe3          	bgeu	a4,a2,460 <printint+0x28>
  if(neg)
 486:	000e0c63          	beqz	t3,49e <printint+0x66>
    buf[i++] = '-';
 48a:	fd050793          	addi	a5,a0,-48
 48e:	00878533          	add	a0,a5,s0
 492:	02d00793          	li	a5,45
 496:	fef50823          	sb	a5,-16(a0)
 49a:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 49e:	fff7899b          	addiw	s3,a5,-1
 4a2:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 4a6:	fff4c583          	lbu	a1,-1(s1)
 4aa:	854a                	mv	a0,s2
 4ac:	f6fff0ef          	jal	41a <putc>
  while(--i >= 0)
 4b0:	39fd                	addiw	s3,s3,-1
 4b2:	14fd                	addi	s1,s1,-1
 4b4:	fe09d9e3          	bgez	s3,4a6 <printint+0x6e>
}
 4b8:	70e2                	ld	ra,56(sp)
 4ba:	7442                	ld	s0,48(sp)
 4bc:	74a2                	ld	s1,40(sp)
 4be:	7902                	ld	s2,32(sp)
 4c0:	69e2                	ld	s3,24(sp)
 4c2:	6121                	addi	sp,sp,64
 4c4:	8082                	ret
    x = -xx;
 4c6:	40b005bb          	negw	a1,a1
    neg = 1;
 4ca:	4e05                	li	t3,1
    x = -xx;
 4cc:	b751                	j	450 <printint+0x18>

00000000000004ce <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ce:	711d                	addi	sp,sp,-96
 4d0:	ec86                	sd	ra,88(sp)
 4d2:	e8a2                	sd	s0,80(sp)
 4d4:	e4a6                	sd	s1,72(sp)
 4d6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4d8:	0005c483          	lbu	s1,0(a1)
 4dc:	26048663          	beqz	s1,748 <vprintf+0x27a>
 4e0:	e0ca                	sd	s2,64(sp)
 4e2:	fc4e                	sd	s3,56(sp)
 4e4:	f852                	sd	s4,48(sp)
 4e6:	f456                	sd	s5,40(sp)
 4e8:	f05a                	sd	s6,32(sp)
 4ea:	ec5e                	sd	s7,24(sp)
 4ec:	e862                	sd	s8,16(sp)
 4ee:	e466                	sd	s9,8(sp)
 4f0:	8b2a                	mv	s6,a0
 4f2:	8a2e                	mv	s4,a1
 4f4:	8bb2                	mv	s7,a2
  state = 0;
 4f6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4f8:	4901                	li	s2,0
 4fa:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4fc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 500:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 504:	06c00c93          	li	s9,108
 508:	a00d                	j	52a <vprintf+0x5c>
        putc(fd, c0);
 50a:	85a6                	mv	a1,s1
 50c:	855a                	mv	a0,s6
 50e:	f0dff0ef          	jal	41a <putc>
 512:	a019                	j	518 <vprintf+0x4a>
    } else if(state == '%'){
 514:	03598363          	beq	s3,s5,53a <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 518:	0019079b          	addiw	a5,s2,1
 51c:	893e                	mv	s2,a5
 51e:	873e                	mv	a4,a5
 520:	97d2                	add	a5,a5,s4
 522:	0007c483          	lbu	s1,0(a5)
 526:	20048963          	beqz	s1,738 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 52a:	0004879b          	sext.w	a5,s1
    if(state == 0){
 52e:	fe0993e3          	bnez	s3,514 <vprintf+0x46>
      if(c0 == '%'){
 532:	fd579ce3          	bne	a5,s5,50a <vprintf+0x3c>
        state = '%';
 536:	89be                	mv	s3,a5
 538:	b7c5                	j	518 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 53a:	00ea06b3          	add	a3,s4,a4
 53e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 542:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 544:	c681                	beqz	a3,54c <vprintf+0x7e>
 546:	9752                	add	a4,a4,s4
 548:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 54c:	03878e63          	beq	a5,s8,588 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 550:	05978863          	beq	a5,s9,5a0 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 554:	07500713          	li	a4,117
 558:	0ee78263          	beq	a5,a4,63c <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 55c:	07800713          	li	a4,120
 560:	12e78463          	beq	a5,a4,688 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 564:	07000713          	li	a4,112
 568:	14e78963          	beq	a5,a4,6ba <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 56c:	07300713          	li	a4,115
 570:	18e78863          	beq	a5,a4,700 <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 574:	02500713          	li	a4,37
 578:	04e79463          	bne	a5,a4,5c0 <vprintf+0xf2>
        putc(fd, '%');
 57c:	85ba                	mv	a1,a4
 57e:	855a                	mv	a0,s6
 580:	e9bff0ef          	jal	41a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 584:	4981                	li	s3,0
 586:	bf49                	j	518 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 588:	008b8493          	addi	s1,s7,8
 58c:	4685                	li	a3,1
 58e:	4629                	li	a2,10
 590:	000ba583          	lw	a1,0(s7)
 594:	855a                	mv	a0,s6
 596:	ea3ff0ef          	jal	438 <printint>
 59a:	8ba6                	mv	s7,s1
      state = 0;
 59c:	4981                	li	s3,0
 59e:	bfad                	j	518 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5a0:	06400793          	li	a5,100
 5a4:	02f68963          	beq	a3,a5,5d6 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a8:	06c00793          	li	a5,108
 5ac:	04f68263          	beq	a3,a5,5f0 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 5b0:	07500793          	li	a5,117
 5b4:	0af68063          	beq	a3,a5,654 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 5b8:	07800793          	li	a5,120
 5bc:	0ef68263          	beq	a3,a5,6a0 <vprintf+0x1d2>
        putc(fd, '%');
 5c0:	02500593          	li	a1,37
 5c4:	855a                	mv	a0,s6
 5c6:	e55ff0ef          	jal	41a <putc>
        putc(fd, c0);
 5ca:	85a6                	mv	a1,s1
 5cc:	855a                	mv	a0,s6
 5ce:	e4dff0ef          	jal	41a <putc>
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b791                	j	518 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d6:	008b8493          	addi	s1,s7,8
 5da:	4685                	li	a3,1
 5dc:	4629                	li	a2,10
 5de:	000ba583          	lw	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	e55ff0ef          	jal	438 <printint>
        i += 1;
 5e8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ea:	8ba6                	mv	s7,s1
      state = 0;
 5ec:	4981                	li	s3,0
        i += 1;
 5ee:	b72d                	j	518 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f0:	06400793          	li	a5,100
 5f4:	02f60763          	beq	a2,a5,622 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5f8:	07500793          	li	a5,117
 5fc:	06f60963          	beq	a2,a5,66e <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 600:	07800793          	li	a5,120
 604:	faf61ee3          	bne	a2,a5,5c0 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 608:	008b8493          	addi	s1,s7,8
 60c:	4681                	li	a3,0
 60e:	4641                	li	a2,16
 610:	000ba583          	lw	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	e23ff0ef          	jal	438 <printint>
        i += 2;
 61a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 61c:	8ba6                	mv	s7,s1
      state = 0;
 61e:	4981                	li	s3,0
        i += 2;
 620:	bde5                	j	518 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 622:	008b8493          	addi	s1,s7,8
 626:	4685                	li	a3,1
 628:	4629                	li	a2,10
 62a:	000ba583          	lw	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	e09ff0ef          	jal	438 <printint>
        i += 2;
 634:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 636:	8ba6                	mv	s7,s1
      state = 0;
 638:	4981                	li	s3,0
        i += 2;
 63a:	bdf9                	j	518 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 63c:	008b8493          	addi	s1,s7,8
 640:	4681                	li	a3,0
 642:	4629                	li	a2,10
 644:	000ba583          	lw	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	defff0ef          	jal	438 <printint>
 64e:	8ba6                	mv	s7,s1
      state = 0;
 650:	4981                	li	s3,0
 652:	b5d9                	j	518 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 654:	008b8493          	addi	s1,s7,8
 658:	4681                	li	a3,0
 65a:	4629                	li	a2,10
 65c:	000ba583          	lw	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	dd7ff0ef          	jal	438 <printint>
        i += 1;
 666:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 668:	8ba6                	mv	s7,s1
      state = 0;
 66a:	4981                	li	s3,0
        i += 1;
 66c:	b575                	j	518 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66e:	008b8493          	addi	s1,s7,8
 672:	4681                	li	a3,0
 674:	4629                	li	a2,10
 676:	000ba583          	lw	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	dbdff0ef          	jal	438 <printint>
        i += 2;
 680:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	8ba6                	mv	s7,s1
      state = 0;
 684:	4981                	li	s3,0
        i += 2;
 686:	bd49                	j	518 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 688:	008b8493          	addi	s1,s7,8
 68c:	4681                	li	a3,0
 68e:	4641                	li	a2,16
 690:	000ba583          	lw	a1,0(s7)
 694:	855a                	mv	a0,s6
 696:	da3ff0ef          	jal	438 <printint>
 69a:	8ba6                	mv	s7,s1
      state = 0;
 69c:	4981                	li	s3,0
 69e:	bdad                	j	518 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a0:	008b8493          	addi	s1,s7,8
 6a4:	4681                	li	a3,0
 6a6:	4641                	li	a2,16
 6a8:	000ba583          	lw	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	d8bff0ef          	jal	438 <printint>
        i += 1;
 6b2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b4:	8ba6                	mv	s7,s1
      state = 0;
 6b6:	4981                	li	s3,0
        i += 1;
 6b8:	b585                	j	518 <vprintf+0x4a>
 6ba:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6bc:	008b8d13          	addi	s10,s7,8
 6c0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6c4:	03000593          	li	a1,48
 6c8:	855a                	mv	a0,s6
 6ca:	d51ff0ef          	jal	41a <putc>
  putc(fd, 'x');
 6ce:	07800593          	li	a1,120
 6d2:	855a                	mv	a0,s6
 6d4:	d47ff0ef          	jal	41a <putc>
 6d8:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6da:	00000b97          	auipc	s7,0x0
 6de:	316b8b93          	addi	s7,s7,790 # 9f0 <digits>
 6e2:	03c9d793          	srli	a5,s3,0x3c
 6e6:	97de                	add	a5,a5,s7
 6e8:	0007c583          	lbu	a1,0(a5)
 6ec:	855a                	mv	a0,s6
 6ee:	d2dff0ef          	jal	41a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f2:	0992                	slli	s3,s3,0x4
 6f4:	34fd                	addiw	s1,s1,-1
 6f6:	f4f5                	bnez	s1,6e2 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 6f8:	8bea                	mv	s7,s10
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	6d02                	ld	s10,0(sp)
 6fe:	bd29                	j	518 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 700:	008b8993          	addi	s3,s7,8
 704:	000bb483          	ld	s1,0(s7)
 708:	cc91                	beqz	s1,724 <vprintf+0x256>
        for(; *s; s++)
 70a:	0004c583          	lbu	a1,0(s1)
 70e:	c195                	beqz	a1,732 <vprintf+0x264>
          putc(fd, *s);
 710:	855a                	mv	a0,s6
 712:	d09ff0ef          	jal	41a <putc>
        for(; *s; s++)
 716:	0485                	addi	s1,s1,1
 718:	0004c583          	lbu	a1,0(s1)
 71c:	f9f5                	bnez	a1,710 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 71e:	8bce                	mv	s7,s3
      state = 0;
 720:	4981                	li	s3,0
 722:	bbdd                	j	518 <vprintf+0x4a>
          s = "(null)";
 724:	00000497          	auipc	s1,0x0
 728:	2c448493          	addi	s1,s1,708 # 9e8 <malloc+0x1b4>
        for(; *s; s++)
 72c:	02800593          	li	a1,40
 730:	b7c5                	j	710 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 732:	8bce                	mv	s7,s3
      state = 0;
 734:	4981                	li	s3,0
 736:	b3cd                	j	518 <vprintf+0x4a>
 738:	6906                	ld	s2,64(sp)
 73a:	79e2                	ld	s3,56(sp)
 73c:	7a42                	ld	s4,48(sp)
 73e:	7aa2                	ld	s5,40(sp)
 740:	7b02                	ld	s6,32(sp)
 742:	6be2                	ld	s7,24(sp)
 744:	6c42                	ld	s8,16(sp)
 746:	6ca2                	ld	s9,8(sp)
    }
  }
}
 748:	60e6                	ld	ra,88(sp)
 74a:	6446                	ld	s0,80(sp)
 74c:	64a6                	ld	s1,72(sp)
 74e:	6125                	addi	sp,sp,96
 750:	8082                	ret

0000000000000752 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 752:	715d                	addi	sp,sp,-80
 754:	ec06                	sd	ra,24(sp)
 756:	e822                	sd	s0,16(sp)
 758:	1000                	addi	s0,sp,32
 75a:	e010                	sd	a2,0(s0)
 75c:	e414                	sd	a3,8(s0)
 75e:	e818                	sd	a4,16(s0)
 760:	ec1c                	sd	a5,24(s0)
 762:	03043023          	sd	a6,32(s0)
 766:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 76a:	8622                	mv	a2,s0
 76c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 770:	d5fff0ef          	jal	4ce <vprintf>
}
 774:	60e2                	ld	ra,24(sp)
 776:	6442                	ld	s0,16(sp)
 778:	6161                	addi	sp,sp,80
 77a:	8082                	ret

000000000000077c <printf>:

void
printf(const char *fmt, ...)
{
 77c:	711d                	addi	sp,sp,-96
 77e:	ec06                	sd	ra,24(sp)
 780:	e822                	sd	s0,16(sp)
 782:	1000                	addi	s0,sp,32
 784:	e40c                	sd	a1,8(s0)
 786:	e810                	sd	a2,16(s0)
 788:	ec14                	sd	a3,24(s0)
 78a:	f018                	sd	a4,32(s0)
 78c:	f41c                	sd	a5,40(s0)
 78e:	03043823          	sd	a6,48(s0)
 792:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 796:	00840613          	addi	a2,s0,8
 79a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 79e:	85aa                	mv	a1,a0
 7a0:	4505                	li	a0,1
 7a2:	d2dff0ef          	jal	4ce <vprintf>
}
 7a6:	60e2                	ld	ra,24(sp)
 7a8:	6442                	ld	s0,16(sp)
 7aa:	6125                	addi	sp,sp,96
 7ac:	8082                	ret

00000000000007ae <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ae:	1141                	addi	sp,sp,-16
 7b0:	e406                	sd	ra,8(sp)
 7b2:	e022                	sd	s0,0(sp)
 7b4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	00001797          	auipc	a5,0x1
 7be:	8467b783          	ld	a5,-1978(a5) # 1000 <freep>
 7c2:	a02d                	j	7ec <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c4:	4618                	lw	a4,8(a2)
 7c6:	9f2d                	addw	a4,a4,a1
 7c8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7cc:	6398                	ld	a4,0(a5)
 7ce:	6310                	ld	a2,0(a4)
 7d0:	a83d                	j	80e <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7d2:	ff852703          	lw	a4,-8(a0)
 7d6:	9f31                	addw	a4,a4,a2
 7d8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7da:	ff053683          	ld	a3,-16(a0)
 7de:	a091                	j	822 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	6398                	ld	a4,0(a5)
 7e2:	00e7e463          	bltu	a5,a4,7ea <free+0x3c>
 7e6:	00e6ea63          	bltu	a3,a4,7fa <free+0x4c>
{
 7ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ec:	fed7fae3          	bgeu	a5,a3,7e0 <free+0x32>
 7f0:	6398                	ld	a4,0(a5)
 7f2:	00e6e463          	bltu	a3,a4,7fa <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f6:	fee7eae3          	bltu	a5,a4,7ea <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7fa:	ff852583          	lw	a1,-8(a0)
 7fe:	6390                	ld	a2,0(a5)
 800:	02059813          	slli	a6,a1,0x20
 804:	01c85713          	srli	a4,a6,0x1c
 808:	9736                	add	a4,a4,a3
 80a:	fae60de3          	beq	a2,a4,7c4 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 80e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 812:	4790                	lw	a2,8(a5)
 814:	02061593          	slli	a1,a2,0x20
 818:	01c5d713          	srli	a4,a1,0x1c
 81c:	973e                	add	a4,a4,a5
 81e:	fae68ae3          	beq	a3,a4,7d2 <free+0x24>
    p->s.ptr = bp->s.ptr;
 822:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 824:	00000717          	auipc	a4,0x0
 828:	7cf73e23          	sd	a5,2012(a4) # 1000 <freep>
}
 82c:	60a2                	ld	ra,8(sp)
 82e:	6402                	ld	s0,0(sp)
 830:	0141                	addi	sp,sp,16
 832:	8082                	ret

0000000000000834 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 834:	7139                	addi	sp,sp,-64
 836:	fc06                	sd	ra,56(sp)
 838:	f822                	sd	s0,48(sp)
 83a:	f04a                	sd	s2,32(sp)
 83c:	ec4e                	sd	s3,24(sp)
 83e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 840:	02051993          	slli	s3,a0,0x20
 844:	0209d993          	srli	s3,s3,0x20
 848:	09bd                	addi	s3,s3,15
 84a:	0049d993          	srli	s3,s3,0x4
 84e:	2985                	addiw	s3,s3,1
 850:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 852:	00000517          	auipc	a0,0x0
 856:	7ae53503          	ld	a0,1966(a0) # 1000 <freep>
 85a:	c905                	beqz	a0,88a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85e:	4798                	lw	a4,8(a5)
 860:	09377663          	bgeu	a4,s3,8ec <malloc+0xb8>
 864:	f426                	sd	s1,40(sp)
 866:	e852                	sd	s4,16(sp)
 868:	e456                	sd	s5,8(sp)
 86a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 86c:	8a4e                	mv	s4,s3
 86e:	6705                	lui	a4,0x1
 870:	00e9f363          	bgeu	s3,a4,876 <malloc+0x42>
 874:	6a05                	lui	s4,0x1
 876:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 87a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 87e:	00000497          	auipc	s1,0x0
 882:	78248493          	addi	s1,s1,1922 # 1000 <freep>
  if(p == (char*)-1)
 886:	5afd                	li	s5,-1
 888:	a83d                	j	8c6 <malloc+0x92>
 88a:	f426                	sd	s1,40(sp)
 88c:	e852                	sd	s4,16(sp)
 88e:	e456                	sd	s5,8(sp)
 890:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 892:	00000797          	auipc	a5,0x0
 896:	77e78793          	addi	a5,a5,1918 # 1010 <base>
 89a:	00000717          	auipc	a4,0x0
 89e:	76f73323          	sd	a5,1894(a4) # 1000 <freep>
 8a2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a8:	b7d1                	j	86c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8aa:	6398                	ld	a4,0(a5)
 8ac:	e118                	sd	a4,0(a0)
 8ae:	a899                	j	904 <malloc+0xd0>
  hp->s.size = nu;
 8b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b4:	0541                	addi	a0,a0,16
 8b6:	ef9ff0ef          	jal	7ae <free>
  return freep;
 8ba:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8bc:	c125                	beqz	a0,91c <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c0:	4798                	lw	a4,8(a5)
 8c2:	03277163          	bgeu	a4,s2,8e4 <malloc+0xb0>
    if(p == freep)
 8c6:	6098                	ld	a4,0(s1)
 8c8:	853e                	mv	a0,a5
 8ca:	fef71ae3          	bne	a4,a5,8be <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8ce:	8552                	mv	a0,s4
 8d0:	b1bff0ef          	jal	3ea <sbrk>
  if(p == (char*)-1)
 8d4:	fd551ee3          	bne	a0,s5,8b0 <malloc+0x7c>
        return 0;
 8d8:	4501                	li	a0,0
 8da:	74a2                	ld	s1,40(sp)
 8dc:	6a42                	ld	s4,16(sp)
 8de:	6aa2                	ld	s5,8(sp)
 8e0:	6b02                	ld	s6,0(sp)
 8e2:	a03d                	j	910 <malloc+0xdc>
 8e4:	74a2                	ld	s1,40(sp)
 8e6:	6a42                	ld	s4,16(sp)
 8e8:	6aa2                	ld	s5,8(sp)
 8ea:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8ec:	fae90fe3          	beq	s2,a4,8aa <malloc+0x76>
        p->s.size -= nunits;
 8f0:	4137073b          	subw	a4,a4,s3
 8f4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8f6:	02071693          	slli	a3,a4,0x20
 8fa:	01c6d713          	srli	a4,a3,0x1c
 8fe:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 900:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 904:	00000717          	auipc	a4,0x0
 908:	6ea73e23          	sd	a0,1788(a4) # 1000 <freep>
      return (void*)(p + 1);
 90c:	01078513          	addi	a0,a5,16
  }
}
 910:	70e2                	ld	ra,56(sp)
 912:	7442                	ld	s0,48(sp)
 914:	7902                	ld	s2,32(sp)
 916:	69e2                	ld	s3,24(sp)
 918:	6121                	addi	sp,sp,64
 91a:	8082                	ret
 91c:	74a2                	ld	s1,40(sp)
 91e:	6a42                	ld	s4,16(sp)
 920:	6aa2                	ld	s5,8(sp)
 922:	6b02                	ld	s6,0(sp)
 924:	b7f5                	j	910 <malloc+0xdc>
