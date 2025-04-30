
user/_top:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  top();
   8:	324000ef          	jal	32c <top>
  exit(0);
   c:	4501                	li	a0,0
   e:	26e000ef          	jal	27c <exit>

0000000000000012 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  12:	1141                	addi	sp,sp,-16
  14:	e406                	sd	ra,8(sp)
  16:	e022                	sd	s0,0(sp)
  18:	0800                	addi	s0,sp,16
  extern int main();
  main();
  1a:	fe7ff0ef          	jal	0 <main>
  exit(0);
  1e:	4501                	li	a0,0
  20:	25c000ef          	jal	27c <exit>

0000000000000024 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  24:	1141                	addi	sp,sp,-16
  26:	e422                	sd	s0,8(sp)
  28:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  2a:	87aa                	mv	a5,a0
  2c:	0585                	addi	a1,a1,1
  2e:	0785                	addi	a5,a5,1
  30:	fff5c703          	lbu	a4,-1(a1)
  34:	fee78fa3          	sb	a4,-1(a5)
  38:	fb75                	bnez	a4,2c <strcpy+0x8>
    ;
  return os;
}
  3a:	6422                	ld	s0,8(sp)
  3c:	0141                	addi	sp,sp,16
  3e:	8082                	ret

0000000000000040 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  40:	1141                	addi	sp,sp,-16
  42:	e422                	sd	s0,8(sp)
  44:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  46:	00054783          	lbu	a5,0(a0)
  4a:	cb91                	beqz	a5,5e <strcmp+0x1e>
  4c:	0005c703          	lbu	a4,0(a1)
  50:	00f71763          	bne	a4,a5,5e <strcmp+0x1e>
    p++, q++;
  54:	0505                	addi	a0,a0,1
  56:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  58:	00054783          	lbu	a5,0(a0)
  5c:	fbe5                	bnez	a5,4c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  5e:	0005c503          	lbu	a0,0(a1)
}
  62:	40a7853b          	subw	a0,a5,a0
  66:	6422                	ld	s0,8(sp)
  68:	0141                	addi	sp,sp,16
  6a:	8082                	ret

000000000000006c <strlen>:

uint
strlen(const char *s)
{
  6c:	1141                	addi	sp,sp,-16
  6e:	e422                	sd	s0,8(sp)
  70:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  72:	00054783          	lbu	a5,0(a0)
  76:	cf91                	beqz	a5,92 <strlen+0x26>
  78:	0505                	addi	a0,a0,1
  7a:	87aa                	mv	a5,a0
  7c:	86be                	mv	a3,a5
  7e:	0785                	addi	a5,a5,1
  80:	fff7c703          	lbu	a4,-1(a5)
  84:	ff65                	bnez	a4,7c <strlen+0x10>
  86:	40a6853b          	subw	a0,a3,a0
  8a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  8c:	6422                	ld	s0,8(sp)
  8e:	0141                	addi	sp,sp,16
  90:	8082                	ret
  for(n = 0; s[n]; n++)
  92:	4501                	li	a0,0
  94:	bfe5                	j	8c <strlen+0x20>

0000000000000096 <memset>:

void*
memset(void *dst, int c, uint n)
{
  96:	1141                	addi	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  9c:	ca19                	beqz	a2,b2 <memset+0x1c>
  9e:	87aa                	mv	a5,a0
  a0:	1602                	slli	a2,a2,0x20
  a2:	9201                	srli	a2,a2,0x20
  a4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  a8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ac:	0785                	addi	a5,a5,1
  ae:	fee79de3          	bne	a5,a4,a8 <memset+0x12>
  }
  return dst;
}
  b2:	6422                	ld	s0,8(sp)
  b4:	0141                	addi	sp,sp,16
  b6:	8082                	ret

00000000000000b8 <strchr>:

char*
strchr(const char *s, char c)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e422                	sd	s0,8(sp)
  bc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  be:	00054783          	lbu	a5,0(a0)
  c2:	cb99                	beqz	a5,d8 <strchr+0x20>
    if(*s == c)
  c4:	00f58763          	beq	a1,a5,d2 <strchr+0x1a>
  for(; *s; s++)
  c8:	0505                	addi	a0,a0,1
  ca:	00054783          	lbu	a5,0(a0)
  ce:	fbfd                	bnez	a5,c4 <strchr+0xc>
      return (char*)s;
  return 0;
  d0:	4501                	li	a0,0
}
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret
  return 0;
  d8:	4501                	li	a0,0
  da:	bfe5                	j	d2 <strchr+0x1a>

00000000000000dc <gets>:

char*
gets(char *buf, int max)
{
  dc:	711d                	addi	sp,sp,-96
  de:	ec86                	sd	ra,88(sp)
  e0:	e8a2                	sd	s0,80(sp)
  e2:	e4a6                	sd	s1,72(sp)
  e4:	e0ca                	sd	s2,64(sp)
  e6:	fc4e                	sd	s3,56(sp)
  e8:	f852                	sd	s4,48(sp)
  ea:	f456                	sd	s5,40(sp)
  ec:	f05a                	sd	s6,32(sp)
  ee:	ec5e                	sd	s7,24(sp)
  f0:	1080                	addi	s0,sp,96
  f2:	8baa                	mv	s7,a0
  f4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  f6:	892a                	mv	s2,a0
  f8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
  fa:	4aa9                	li	s5,10
  fc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
  fe:	89a6                	mv	s3,s1
 100:	2485                	addiw	s1,s1,1
 102:	0344d663          	bge	s1,s4,12e <gets+0x52>
    cc = read(0, &c, 1);
 106:	4605                	li	a2,1
 108:	faf40593          	addi	a1,s0,-81
 10c:	4501                	li	a0,0
 10e:	186000ef          	jal	294 <read>
    if(cc < 1)
 112:	00a05e63          	blez	a0,12e <gets+0x52>
    buf[i++] = c;
 116:	faf44783          	lbu	a5,-81(s0)
 11a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 11e:	01578763          	beq	a5,s5,12c <gets+0x50>
 122:	0905                	addi	s2,s2,1
 124:	fd679de3          	bne	a5,s6,fe <gets+0x22>
    buf[i++] = c;
 128:	89a6                	mv	s3,s1
 12a:	a011                	j	12e <gets+0x52>
 12c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 12e:	99de                	add	s3,s3,s7
 130:	00098023          	sb	zero,0(s3)
  return buf;
}
 134:	855e                	mv	a0,s7
 136:	60e6                	ld	ra,88(sp)
 138:	6446                	ld	s0,80(sp)
 13a:	64a6                	ld	s1,72(sp)
 13c:	6906                	ld	s2,64(sp)
 13e:	79e2                	ld	s3,56(sp)
 140:	7a42                	ld	s4,48(sp)
 142:	7aa2                	ld	s5,40(sp)
 144:	7b02                	ld	s6,32(sp)
 146:	6be2                	ld	s7,24(sp)
 148:	6125                	addi	sp,sp,96
 14a:	8082                	ret

000000000000014c <stat>:

int
stat(const char *n, struct stat *st)
{
 14c:	1101                	addi	sp,sp,-32
 14e:	ec06                	sd	ra,24(sp)
 150:	e822                	sd	s0,16(sp)
 152:	e04a                	sd	s2,0(sp)
 154:	1000                	addi	s0,sp,32
 156:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 158:	4581                	li	a1,0
 15a:	162000ef          	jal	2bc <open>
  if(fd < 0)
 15e:	02054263          	bltz	a0,182 <stat+0x36>
 162:	e426                	sd	s1,8(sp)
 164:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 166:	85ca                	mv	a1,s2
 168:	16c000ef          	jal	2d4 <fstat>
 16c:	892a                	mv	s2,a0
  close(fd);
 16e:	8526                	mv	a0,s1
 170:	134000ef          	jal	2a4 <close>
  return r;
 174:	64a2                	ld	s1,8(sp)
}
 176:	854a                	mv	a0,s2
 178:	60e2                	ld	ra,24(sp)
 17a:	6442                	ld	s0,16(sp)
 17c:	6902                	ld	s2,0(sp)
 17e:	6105                	addi	sp,sp,32
 180:	8082                	ret
    return -1;
 182:	597d                	li	s2,-1
 184:	bfcd                	j	176 <stat+0x2a>

0000000000000186 <atoi>:

int
atoi(const char *s)
{
 186:	1141                	addi	sp,sp,-16
 188:	e422                	sd	s0,8(sp)
 18a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 18c:	00054683          	lbu	a3,0(a0)
 190:	fd06879b          	addiw	a5,a3,-48
 194:	0ff7f793          	zext.b	a5,a5
 198:	4625                	li	a2,9
 19a:	02f66863          	bltu	a2,a5,1ca <atoi+0x44>
 19e:	872a                	mv	a4,a0
  n = 0;
 1a0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1a2:	0705                	addi	a4,a4,1
 1a4:	0025179b          	slliw	a5,a0,0x2
 1a8:	9fa9                	addw	a5,a5,a0
 1aa:	0017979b          	slliw	a5,a5,0x1
 1ae:	9fb5                	addw	a5,a5,a3
 1b0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1b4:	00074683          	lbu	a3,0(a4)
 1b8:	fd06879b          	addiw	a5,a3,-48
 1bc:	0ff7f793          	zext.b	a5,a5
 1c0:	fef671e3          	bgeu	a2,a5,1a2 <atoi+0x1c>
  return n;
}
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret
  n = 0;
 1ca:	4501                	li	a0,0
 1cc:	bfe5                	j	1c4 <atoi+0x3e>

00000000000001ce <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ce:	1141                	addi	sp,sp,-16
 1d0:	e422                	sd	s0,8(sp)
 1d2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1d4:	02b57463          	bgeu	a0,a1,1fc <memmove+0x2e>
    while(n-- > 0)
 1d8:	00c05f63          	blez	a2,1f6 <memmove+0x28>
 1dc:	1602                	slli	a2,a2,0x20
 1de:	9201                	srli	a2,a2,0x20
 1e0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1e4:	872a                	mv	a4,a0
      *dst++ = *src++;
 1e6:	0585                	addi	a1,a1,1
 1e8:	0705                	addi	a4,a4,1
 1ea:	fff5c683          	lbu	a3,-1(a1)
 1ee:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1f2:	fef71ae3          	bne	a4,a5,1e6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
    dst += n;
 1fc:	00c50733          	add	a4,a0,a2
    src += n;
 200:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 202:	fec05ae3          	blez	a2,1f6 <memmove+0x28>
 206:	fff6079b          	addiw	a5,a2,-1
 20a:	1782                	slli	a5,a5,0x20
 20c:	9381                	srli	a5,a5,0x20
 20e:	fff7c793          	not	a5,a5
 212:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 214:	15fd                	addi	a1,a1,-1
 216:	177d                	addi	a4,a4,-1
 218:	0005c683          	lbu	a3,0(a1)
 21c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 220:	fee79ae3          	bne	a5,a4,214 <memmove+0x46>
 224:	bfc9                	j	1f6 <memmove+0x28>

0000000000000226 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 226:	1141                	addi	sp,sp,-16
 228:	e422                	sd	s0,8(sp)
 22a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 22c:	ca05                	beqz	a2,25c <memcmp+0x36>
 22e:	fff6069b          	addiw	a3,a2,-1
 232:	1682                	slli	a3,a3,0x20
 234:	9281                	srli	a3,a3,0x20
 236:	0685                	addi	a3,a3,1
 238:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 23a:	00054783          	lbu	a5,0(a0)
 23e:	0005c703          	lbu	a4,0(a1)
 242:	00e79863          	bne	a5,a4,252 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 246:	0505                	addi	a0,a0,1
    p2++;
 248:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 24a:	fed518e3          	bne	a0,a3,23a <memcmp+0x14>
  }
  return 0;
 24e:	4501                	li	a0,0
 250:	a019                	j	256 <memcmp+0x30>
      return *p1 - *p2;
 252:	40e7853b          	subw	a0,a5,a4
}
 256:	6422                	ld	s0,8(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret
  return 0;
 25c:	4501                	li	a0,0
 25e:	bfe5                	j	256 <memcmp+0x30>

0000000000000260 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 260:	1141                	addi	sp,sp,-16
 262:	e406                	sd	ra,8(sp)
 264:	e022                	sd	s0,0(sp)
 266:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 268:	f67ff0ef          	jal	1ce <memmove>
}
 26c:	60a2                	ld	ra,8(sp)
 26e:	6402                	ld	s0,0(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret

0000000000000274 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 274:	4885                	li	a7,1
 ecall
 276:	00000073          	ecall
 ret
 27a:	8082                	ret

000000000000027c <exit>:
.global exit
exit:
 li a7, SYS_exit
 27c:	4889                	li	a7,2
 ecall
 27e:	00000073          	ecall
 ret
 282:	8082                	ret

0000000000000284 <wait>:
.global wait
wait:
 li a7, SYS_wait
 284:	488d                	li	a7,3
 ecall
 286:	00000073          	ecall
 ret
 28a:	8082                	ret

000000000000028c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 28c:	4891                	li	a7,4
 ecall
 28e:	00000073          	ecall
 ret
 292:	8082                	ret

0000000000000294 <read>:
.global read
read:
 li a7, SYS_read
 294:	4895                	li	a7,5
 ecall
 296:	00000073          	ecall
 ret
 29a:	8082                	ret

000000000000029c <write>:
.global write
write:
 li a7, SYS_write
 29c:	48c1                	li	a7,16
 ecall
 29e:	00000073          	ecall
 ret
 2a2:	8082                	ret

00000000000002a4 <close>:
.global close
close:
 li a7, SYS_close
 2a4:	48d5                	li	a7,21
 ecall
 2a6:	00000073          	ecall
 ret
 2aa:	8082                	ret

00000000000002ac <kill>:
.global kill
kill:
 li a7, SYS_kill
 2ac:	4899                	li	a7,6
 ecall
 2ae:	00000073          	ecall
 ret
 2b2:	8082                	ret

00000000000002b4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2b4:	489d                	li	a7,7
 ecall
 2b6:	00000073          	ecall
 ret
 2ba:	8082                	ret

00000000000002bc <open>:
.global open
open:
 li a7, SYS_open
 2bc:	48bd                	li	a7,15
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2c4:	48c5                	li	a7,17
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2cc:	48c9                	li	a7,18
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2d4:	48a1                	li	a7,8
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <link>:
.global link
link:
 li a7, SYS_link
 2dc:	48cd                	li	a7,19
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2e4:	48d1                	li	a7,20
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2ec:	48a5                	li	a7,9
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 2f4:	48a9                	li	a7,10
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 2fc:	48ad                	li	a7,11
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 304:	48b1                	li	a7,12
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 30c:	48b5                	li	a7,13
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 314:	48b9                	li	a7,14
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <set_sched>:
.global set_sched
set_sched:
 li a7, SYS_set_sched
 31c:	48d9                	li	a7,22
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 324:	48dd                	li	a7,23
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <top>:
.global top
top:
 li a7, SYS_top
 32c:	48e1                	li	a7,24
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <fork_with_priority>:
.global fork_with_priority
fork_with_priority:
 li a7, SYS_fork_with_priority
 334:	48e5                	li	a7,25
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <yield>:
.global yield
yield:
 li a7, SYS_yield
 33c:	48e9                	li	a7,26
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <get_waiting_time>:
.global get_waiting_time
get_waiting_time:
  li a7, SYS_get_waiting_time
 344:	48ed                	li	a7,27
  ecall
 346:	00000073          	ecall
  ret
 34a:	8082                	ret

000000000000034c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 34c:	1101                	addi	sp,sp,-32
 34e:	ec06                	sd	ra,24(sp)
 350:	e822                	sd	s0,16(sp)
 352:	1000                	addi	s0,sp,32
 354:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 358:	4605                	li	a2,1
 35a:	fef40593          	addi	a1,s0,-17
 35e:	f3fff0ef          	jal	29c <write>
}
 362:	60e2                	ld	ra,24(sp)
 364:	6442                	ld	s0,16(sp)
 366:	6105                	addi	sp,sp,32
 368:	8082                	ret

000000000000036a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 36a:	7139                	addi	sp,sp,-64
 36c:	fc06                	sd	ra,56(sp)
 36e:	f822                	sd	s0,48(sp)
 370:	f426                	sd	s1,40(sp)
 372:	0080                	addi	s0,sp,64
 374:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 376:	c299                	beqz	a3,37c <printint+0x12>
 378:	0805c963          	bltz	a1,40a <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 37c:	2581                	sext.w	a1,a1
  neg = 0;
 37e:	4881                	li	a7,0
 380:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 384:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 386:	2601                	sext.w	a2,a2
 388:	00000517          	auipc	a0,0x0
 38c:	4f050513          	addi	a0,a0,1264 # 878 <digits>
 390:	883a                	mv	a6,a4
 392:	2705                	addiw	a4,a4,1
 394:	02c5f7bb          	remuw	a5,a1,a2
 398:	1782                	slli	a5,a5,0x20
 39a:	9381                	srli	a5,a5,0x20
 39c:	97aa                	add	a5,a5,a0
 39e:	0007c783          	lbu	a5,0(a5)
 3a2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3a6:	0005879b          	sext.w	a5,a1
 3aa:	02c5d5bb          	divuw	a1,a1,a2
 3ae:	0685                	addi	a3,a3,1
 3b0:	fec7f0e3          	bgeu	a5,a2,390 <printint+0x26>
  if(neg)
 3b4:	00088c63          	beqz	a7,3cc <printint+0x62>
    buf[i++] = '-';
 3b8:	fd070793          	addi	a5,a4,-48
 3bc:	00878733          	add	a4,a5,s0
 3c0:	02d00793          	li	a5,45
 3c4:	fef70823          	sb	a5,-16(a4)
 3c8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3cc:	02e05a63          	blez	a4,400 <printint+0x96>
 3d0:	f04a                	sd	s2,32(sp)
 3d2:	ec4e                	sd	s3,24(sp)
 3d4:	fc040793          	addi	a5,s0,-64
 3d8:	00e78933          	add	s2,a5,a4
 3dc:	fff78993          	addi	s3,a5,-1
 3e0:	99ba                	add	s3,s3,a4
 3e2:	377d                	addiw	a4,a4,-1
 3e4:	1702                	slli	a4,a4,0x20
 3e6:	9301                	srli	a4,a4,0x20
 3e8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3ec:	fff94583          	lbu	a1,-1(s2)
 3f0:	8526                	mv	a0,s1
 3f2:	f5bff0ef          	jal	34c <putc>
  while(--i >= 0)
 3f6:	197d                	addi	s2,s2,-1
 3f8:	ff391ae3          	bne	s2,s3,3ec <printint+0x82>
 3fc:	7902                	ld	s2,32(sp)
 3fe:	69e2                	ld	s3,24(sp)
}
 400:	70e2                	ld	ra,56(sp)
 402:	7442                	ld	s0,48(sp)
 404:	74a2                	ld	s1,40(sp)
 406:	6121                	addi	sp,sp,64
 408:	8082                	ret
    x = -xx;
 40a:	40b005bb          	negw	a1,a1
    neg = 1;
 40e:	4885                	li	a7,1
    x = -xx;
 410:	bf85                	j	380 <printint+0x16>

0000000000000412 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 412:	711d                	addi	sp,sp,-96
 414:	ec86                	sd	ra,88(sp)
 416:	e8a2                	sd	s0,80(sp)
 418:	e0ca                	sd	s2,64(sp)
 41a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 41c:	0005c903          	lbu	s2,0(a1)
 420:	26090863          	beqz	s2,690 <vprintf+0x27e>
 424:	e4a6                	sd	s1,72(sp)
 426:	fc4e                	sd	s3,56(sp)
 428:	f852                	sd	s4,48(sp)
 42a:	f456                	sd	s5,40(sp)
 42c:	f05a                	sd	s6,32(sp)
 42e:	ec5e                	sd	s7,24(sp)
 430:	e862                	sd	s8,16(sp)
 432:	e466                	sd	s9,8(sp)
 434:	8b2a                	mv	s6,a0
 436:	8a2e                	mv	s4,a1
 438:	8bb2                	mv	s7,a2
  state = 0;
 43a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 43c:	4481                	li	s1,0
 43e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 440:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 444:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 448:	06c00c93          	li	s9,108
 44c:	a005                	j	46c <vprintf+0x5a>
        putc(fd, c0);
 44e:	85ca                	mv	a1,s2
 450:	855a                	mv	a0,s6
 452:	efbff0ef          	jal	34c <putc>
 456:	a019                	j	45c <vprintf+0x4a>
    } else if(state == '%'){
 458:	03598263          	beq	s3,s5,47c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 45c:	2485                	addiw	s1,s1,1
 45e:	8726                	mv	a4,s1
 460:	009a07b3          	add	a5,s4,s1
 464:	0007c903          	lbu	s2,0(a5)
 468:	20090c63          	beqz	s2,680 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 46c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 470:	fe0994e3          	bnez	s3,458 <vprintf+0x46>
      if(c0 == '%'){
 474:	fd579de3          	bne	a5,s5,44e <vprintf+0x3c>
        state = '%';
 478:	89be                	mv	s3,a5
 47a:	b7cd                	j	45c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 47c:	00ea06b3          	add	a3,s4,a4
 480:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 484:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 486:	c681                	beqz	a3,48e <vprintf+0x7c>
 488:	9752                	add	a4,a4,s4
 48a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 48e:	03878f63          	beq	a5,s8,4cc <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 492:	05978963          	beq	a5,s9,4e4 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 496:	07500713          	li	a4,117
 49a:	0ee78363          	beq	a5,a4,580 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 49e:	07800713          	li	a4,120
 4a2:	12e78563          	beq	a5,a4,5cc <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4a6:	07000713          	li	a4,112
 4aa:	14e78a63          	beq	a5,a4,5fe <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4ae:	07300713          	li	a4,115
 4b2:	18e78a63          	beq	a5,a4,646 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4b6:	02500713          	li	a4,37
 4ba:	04e79563          	bne	a5,a4,504 <vprintf+0xf2>
        putc(fd, '%');
 4be:	02500593          	li	a1,37
 4c2:	855a                	mv	a0,s6
 4c4:	e89ff0ef          	jal	34c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4c8:	4981                	li	s3,0
 4ca:	bf49                	j	45c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4cc:	008b8913          	addi	s2,s7,8
 4d0:	4685                	li	a3,1
 4d2:	4629                	li	a2,10
 4d4:	000ba583          	lw	a1,0(s7)
 4d8:	855a                	mv	a0,s6
 4da:	e91ff0ef          	jal	36a <printint>
 4de:	8bca                	mv	s7,s2
      state = 0;
 4e0:	4981                	li	s3,0
 4e2:	bfad                	j	45c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4e4:	06400793          	li	a5,100
 4e8:	02f68963          	beq	a3,a5,51a <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4ec:	06c00793          	li	a5,108
 4f0:	04f68263          	beq	a3,a5,534 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 4f4:	07500793          	li	a5,117
 4f8:	0af68063          	beq	a3,a5,598 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 4fc:	07800793          	li	a5,120
 500:	0ef68263          	beq	a3,a5,5e4 <vprintf+0x1d2>
        putc(fd, '%');
 504:	02500593          	li	a1,37
 508:	855a                	mv	a0,s6
 50a:	e43ff0ef          	jal	34c <putc>
        putc(fd, c0);
 50e:	85ca                	mv	a1,s2
 510:	855a                	mv	a0,s6
 512:	e3bff0ef          	jal	34c <putc>
      state = 0;
 516:	4981                	li	s3,0
 518:	b791                	j	45c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 51a:	008b8913          	addi	s2,s7,8
 51e:	4685                	li	a3,1
 520:	4629                	li	a2,10
 522:	000ba583          	lw	a1,0(s7)
 526:	855a                	mv	a0,s6
 528:	e43ff0ef          	jal	36a <printint>
        i += 1;
 52c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 52e:	8bca                	mv	s7,s2
      state = 0;
 530:	4981                	li	s3,0
        i += 1;
 532:	b72d                	j	45c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 534:	06400793          	li	a5,100
 538:	02f60763          	beq	a2,a5,566 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 53c:	07500793          	li	a5,117
 540:	06f60963          	beq	a2,a5,5b2 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 544:	07800793          	li	a5,120
 548:	faf61ee3          	bne	a2,a5,504 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 54c:	008b8913          	addi	s2,s7,8
 550:	4681                	li	a3,0
 552:	4641                	li	a2,16
 554:	000ba583          	lw	a1,0(s7)
 558:	855a                	mv	a0,s6
 55a:	e11ff0ef          	jal	36a <printint>
        i += 2;
 55e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 560:	8bca                	mv	s7,s2
      state = 0;
 562:	4981                	li	s3,0
        i += 2;
 564:	bde5                	j	45c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 566:	008b8913          	addi	s2,s7,8
 56a:	4685                	li	a3,1
 56c:	4629                	li	a2,10
 56e:	000ba583          	lw	a1,0(s7)
 572:	855a                	mv	a0,s6
 574:	df7ff0ef          	jal	36a <printint>
        i += 2;
 578:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 57a:	8bca                	mv	s7,s2
      state = 0;
 57c:	4981                	li	s3,0
        i += 2;
 57e:	bdf9                	j	45c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 580:	008b8913          	addi	s2,s7,8
 584:	4681                	li	a3,0
 586:	4629                	li	a2,10
 588:	000ba583          	lw	a1,0(s7)
 58c:	855a                	mv	a0,s6
 58e:	dddff0ef          	jal	36a <printint>
 592:	8bca                	mv	s7,s2
      state = 0;
 594:	4981                	li	s3,0
 596:	b5d9                	j	45c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 598:	008b8913          	addi	s2,s7,8
 59c:	4681                	li	a3,0
 59e:	4629                	li	a2,10
 5a0:	000ba583          	lw	a1,0(s7)
 5a4:	855a                	mv	a0,s6
 5a6:	dc5ff0ef          	jal	36a <printint>
        i += 1;
 5aa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
        i += 1;
 5b0:	b575                	j	45c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b2:	008b8913          	addi	s2,s7,8
 5b6:	4681                	li	a3,0
 5b8:	4629                	li	a2,10
 5ba:	000ba583          	lw	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	dabff0ef          	jal	36a <printint>
        i += 2;
 5c4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c6:	8bca                	mv	s7,s2
      state = 0;
 5c8:	4981                	li	s3,0
        i += 2;
 5ca:	bd49                	j	45c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 5cc:	008b8913          	addi	s2,s7,8
 5d0:	4681                	li	a3,0
 5d2:	4641                	li	a2,16
 5d4:	000ba583          	lw	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	d91ff0ef          	jal	36a <printint>
 5de:	8bca                	mv	s7,s2
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	bdad                	j	45c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e4:	008b8913          	addi	s2,s7,8
 5e8:	4681                	li	a3,0
 5ea:	4641                	li	a2,16
 5ec:	000ba583          	lw	a1,0(s7)
 5f0:	855a                	mv	a0,s6
 5f2:	d79ff0ef          	jal	36a <printint>
        i += 1;
 5f6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
        i += 1;
 5fc:	b585                	j	45c <vprintf+0x4a>
 5fe:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 600:	008b8d13          	addi	s10,s7,8
 604:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 608:	03000593          	li	a1,48
 60c:	855a                	mv	a0,s6
 60e:	d3fff0ef          	jal	34c <putc>
  putc(fd, 'x');
 612:	07800593          	li	a1,120
 616:	855a                	mv	a0,s6
 618:	d35ff0ef          	jal	34c <putc>
 61c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61e:	00000b97          	auipc	s7,0x0
 622:	25ab8b93          	addi	s7,s7,602 # 878 <digits>
 626:	03c9d793          	srli	a5,s3,0x3c
 62a:	97de                	add	a5,a5,s7
 62c:	0007c583          	lbu	a1,0(a5)
 630:	855a                	mv	a0,s6
 632:	d1bff0ef          	jal	34c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 636:	0992                	slli	s3,s3,0x4
 638:	397d                	addiw	s2,s2,-1
 63a:	fe0916e3          	bnez	s2,626 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 63e:	8bea                	mv	s7,s10
      state = 0;
 640:	4981                	li	s3,0
 642:	6d02                	ld	s10,0(sp)
 644:	bd21                	j	45c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 646:	008b8993          	addi	s3,s7,8
 64a:	000bb903          	ld	s2,0(s7)
 64e:	00090f63          	beqz	s2,66c <vprintf+0x25a>
        for(; *s; s++)
 652:	00094583          	lbu	a1,0(s2)
 656:	c195                	beqz	a1,67a <vprintf+0x268>
          putc(fd, *s);
 658:	855a                	mv	a0,s6
 65a:	cf3ff0ef          	jal	34c <putc>
        for(; *s; s++)
 65e:	0905                	addi	s2,s2,1
 660:	00094583          	lbu	a1,0(s2)
 664:	f9f5                	bnez	a1,658 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 666:	8bce                	mv	s7,s3
      state = 0;
 668:	4981                	li	s3,0
 66a:	bbcd                	j	45c <vprintf+0x4a>
          s = "(null)";
 66c:	00000917          	auipc	s2,0x0
 670:	20490913          	addi	s2,s2,516 # 870 <malloc+0xf8>
        for(; *s; s++)
 674:	02800593          	li	a1,40
 678:	b7c5                	j	658 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 67a:	8bce                	mv	s7,s3
      state = 0;
 67c:	4981                	li	s3,0
 67e:	bbf9                	j	45c <vprintf+0x4a>
 680:	64a6                	ld	s1,72(sp)
 682:	79e2                	ld	s3,56(sp)
 684:	7a42                	ld	s4,48(sp)
 686:	7aa2                	ld	s5,40(sp)
 688:	7b02                	ld	s6,32(sp)
 68a:	6be2                	ld	s7,24(sp)
 68c:	6c42                	ld	s8,16(sp)
 68e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 690:	60e6                	ld	ra,88(sp)
 692:	6446                	ld	s0,80(sp)
 694:	6906                	ld	s2,64(sp)
 696:	6125                	addi	sp,sp,96
 698:	8082                	ret

000000000000069a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 69a:	715d                	addi	sp,sp,-80
 69c:	ec06                	sd	ra,24(sp)
 69e:	e822                	sd	s0,16(sp)
 6a0:	1000                	addi	s0,sp,32
 6a2:	e010                	sd	a2,0(s0)
 6a4:	e414                	sd	a3,8(s0)
 6a6:	e818                	sd	a4,16(s0)
 6a8:	ec1c                	sd	a5,24(s0)
 6aa:	03043023          	sd	a6,32(s0)
 6ae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6b2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b6:	8622                	mv	a2,s0
 6b8:	d5bff0ef          	jal	412 <vprintf>
}
 6bc:	60e2                	ld	ra,24(sp)
 6be:	6442                	ld	s0,16(sp)
 6c0:	6161                	addi	sp,sp,80
 6c2:	8082                	ret

00000000000006c4 <printf>:

void
printf(const char *fmt, ...)
{
 6c4:	711d                	addi	sp,sp,-96
 6c6:	ec06                	sd	ra,24(sp)
 6c8:	e822                	sd	s0,16(sp)
 6ca:	1000                	addi	s0,sp,32
 6cc:	e40c                	sd	a1,8(s0)
 6ce:	e810                	sd	a2,16(s0)
 6d0:	ec14                	sd	a3,24(s0)
 6d2:	f018                	sd	a4,32(s0)
 6d4:	f41c                	sd	a5,40(s0)
 6d6:	03043823          	sd	a6,48(s0)
 6da:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6de:	00840613          	addi	a2,s0,8
 6e2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6e6:	85aa                	mv	a1,a0
 6e8:	4505                	li	a0,1
 6ea:	d29ff0ef          	jal	412 <vprintf>
}
 6ee:	60e2                	ld	ra,24(sp)
 6f0:	6442                	ld	s0,16(sp)
 6f2:	6125                	addi	sp,sp,96
 6f4:	8082                	ret

00000000000006f6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f6:	1141                	addi	sp,sp,-16
 6f8:	e422                	sd	s0,8(sp)
 6fa:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6fc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 700:	00001797          	auipc	a5,0x1
 704:	9007b783          	ld	a5,-1792(a5) # 1000 <freep>
 708:	a02d                	j	732 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 70a:	4618                	lw	a4,8(a2)
 70c:	9f2d                	addw	a4,a4,a1
 70e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 712:	6398                	ld	a4,0(a5)
 714:	6310                	ld	a2,0(a4)
 716:	a83d                	j	754 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 718:	ff852703          	lw	a4,-8(a0)
 71c:	9f31                	addw	a4,a4,a2
 71e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 720:	ff053683          	ld	a3,-16(a0)
 724:	a091                	j	768 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 726:	6398                	ld	a4,0(a5)
 728:	00e7e463          	bltu	a5,a4,730 <free+0x3a>
 72c:	00e6ea63          	bltu	a3,a4,740 <free+0x4a>
{
 730:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 732:	fed7fae3          	bgeu	a5,a3,726 <free+0x30>
 736:	6398                	ld	a4,0(a5)
 738:	00e6e463          	bltu	a3,a4,740 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73c:	fee7eae3          	bltu	a5,a4,730 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 740:	ff852583          	lw	a1,-8(a0)
 744:	6390                	ld	a2,0(a5)
 746:	02059813          	slli	a6,a1,0x20
 74a:	01c85713          	srli	a4,a6,0x1c
 74e:	9736                	add	a4,a4,a3
 750:	fae60de3          	beq	a2,a4,70a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 754:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 758:	4790                	lw	a2,8(a5)
 75a:	02061593          	slli	a1,a2,0x20
 75e:	01c5d713          	srli	a4,a1,0x1c
 762:	973e                	add	a4,a4,a5
 764:	fae68ae3          	beq	a3,a4,718 <free+0x22>
    p->s.ptr = bp->s.ptr;
 768:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 76a:	00001717          	auipc	a4,0x1
 76e:	88f73b23          	sd	a5,-1898(a4) # 1000 <freep>
}
 772:	6422                	ld	s0,8(sp)
 774:	0141                	addi	sp,sp,16
 776:	8082                	ret

0000000000000778 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 778:	7139                	addi	sp,sp,-64
 77a:	fc06                	sd	ra,56(sp)
 77c:	f822                	sd	s0,48(sp)
 77e:	f426                	sd	s1,40(sp)
 780:	ec4e                	sd	s3,24(sp)
 782:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 784:	02051493          	slli	s1,a0,0x20
 788:	9081                	srli	s1,s1,0x20
 78a:	04bd                	addi	s1,s1,15
 78c:	8091                	srli	s1,s1,0x4
 78e:	0014899b          	addiw	s3,s1,1
 792:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 794:	00001517          	auipc	a0,0x1
 798:	86c53503          	ld	a0,-1940(a0) # 1000 <freep>
 79c:	c915                	beqz	a0,7d0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a0:	4798                	lw	a4,8(a5)
 7a2:	08977a63          	bgeu	a4,s1,836 <malloc+0xbe>
 7a6:	f04a                	sd	s2,32(sp)
 7a8:	e852                	sd	s4,16(sp)
 7aa:	e456                	sd	s5,8(sp)
 7ac:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7ae:	8a4e                	mv	s4,s3
 7b0:	0009871b          	sext.w	a4,s3
 7b4:	6685                	lui	a3,0x1
 7b6:	00d77363          	bgeu	a4,a3,7bc <malloc+0x44>
 7ba:	6a05                	lui	s4,0x1
 7bc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7c0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7c4:	00001917          	auipc	s2,0x1
 7c8:	83c90913          	addi	s2,s2,-1988 # 1000 <freep>
  if(p == (char*)-1)
 7cc:	5afd                	li	s5,-1
 7ce:	a081                	j	80e <malloc+0x96>
 7d0:	f04a                	sd	s2,32(sp)
 7d2:	e852                	sd	s4,16(sp)
 7d4:	e456                	sd	s5,8(sp)
 7d6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7d8:	00001797          	auipc	a5,0x1
 7dc:	83878793          	addi	a5,a5,-1992 # 1010 <base>
 7e0:	00001717          	auipc	a4,0x1
 7e4:	82f73023          	sd	a5,-2016(a4) # 1000 <freep>
 7e8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7ea:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ee:	b7c1                	j	7ae <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7f0:	6398                	ld	a4,0(a5)
 7f2:	e118                	sd	a4,0(a0)
 7f4:	a8a9                	j	84e <malloc+0xd6>
  hp->s.size = nu;
 7f6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7fa:	0541                	addi	a0,a0,16
 7fc:	efbff0ef          	jal	6f6 <free>
  return freep;
 800:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 804:	c12d                	beqz	a0,866 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 806:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 808:	4798                	lw	a4,8(a5)
 80a:	02977263          	bgeu	a4,s1,82e <malloc+0xb6>
    if(p == freep)
 80e:	00093703          	ld	a4,0(s2)
 812:	853e                	mv	a0,a5
 814:	fef719e3          	bne	a4,a5,806 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 818:	8552                	mv	a0,s4
 81a:	aebff0ef          	jal	304 <sbrk>
  if(p == (char*)-1)
 81e:	fd551ce3          	bne	a0,s5,7f6 <malloc+0x7e>
        return 0;
 822:	4501                	li	a0,0
 824:	7902                	ld	s2,32(sp)
 826:	6a42                	ld	s4,16(sp)
 828:	6aa2                	ld	s5,8(sp)
 82a:	6b02                	ld	s6,0(sp)
 82c:	a03d                	j	85a <malloc+0xe2>
 82e:	7902                	ld	s2,32(sp)
 830:	6a42                	ld	s4,16(sp)
 832:	6aa2                	ld	s5,8(sp)
 834:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 836:	fae48de3          	beq	s1,a4,7f0 <malloc+0x78>
        p->s.size -= nunits;
 83a:	4137073b          	subw	a4,a4,s3
 83e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 840:	02071693          	slli	a3,a4,0x20
 844:	01c6d713          	srli	a4,a3,0x1c
 848:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 84a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 84e:	00000717          	auipc	a4,0x0
 852:	7aa73923          	sd	a0,1970(a4) # 1000 <freep>
      return (void*)(p + 1);
 856:	01078513          	addi	a0,a5,16
  }
}
 85a:	70e2                	ld	ra,56(sp)
 85c:	7442                	ld	s0,48(sp)
 85e:	74a2                	ld	s1,40(sp)
 860:	69e2                	ld	s3,24(sp)
 862:	6121                	addi	sp,sp,64
 864:	8082                	ret
 866:	7902                	ld	s2,32(sp)
 868:	6a42                	ld	s4,16(sp)
 86a:	6aa2                	ld	s5,8(sp)
 86c:	6b02                	ld	s6,0(sp)
 86e:	b7f5                	j	85a <malloc+0xe2>
