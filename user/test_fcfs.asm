
user/_test_fcfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <acquire_lock>:


int printing = 0;

void acquire_lock()
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  while (__sync_lock_test_and_set(&printing, 1) != 0);
   6:	00001717          	auipc	a4,0x1
   a:	ffa70713          	addi	a4,a4,-6 # 1000 <printing>
   e:	4685                	li	a3,1
  10:	87b6                	mv	a5,a3
  12:	0cf727af          	amoswap.w.aq	a5,a5,(a4)
  16:	2781                	sext.w	a5,a5
  18:	ffe5                	bnez	a5,10 <acquire_lock+0x10>
}
  1a:	6422                	ld	s0,8(sp)
  1c:	0141                	addi	sp,sp,16
  1e:	8082                	ret

0000000000000020 <release_lock>:

void release_lock()
{
  20:	1141                	addi	sp,sp,-16
  22:	e422                	sd	s0,8(sp)
  24:	0800                	addi	s0,sp,16
  __sync_lock_release(&printing);
  26:	00001797          	auipc	a5,0x1
  2a:	fda78793          	addi	a5,a5,-38 # 1000 <printing>
  2e:	0f50000f          	fence	iorw,ow
  32:	0807a02f          	amoswap.w	zero,zero,(a5)
}
  36:	6422                	ld	s0,8(sp)
  38:	0141                	addi	sp,sp,16
  3a:	8082                	ret

000000000000003c <main>:

int main() {
  3c:	715d                	addi	sp,sp,-80
  3e:	e486                	sd	ra,72(sp)
  40:	e0a2                	sd	s0,64(sp)
  42:	fc26                	sd	s1,56(sp)
  44:	f84a                	sd	s2,48(sp)
  46:	f44e                	sd	s3,40(sp)
  48:	f052                	sd	s4,32(sp)
  4a:	0880                	addi	s0,sp,80
  int pid;
  int start_time;

  start_time = uptime();
  4c:	43a000ef          	jal	486 <uptime>
  50:	892a                	mv	s2,a0

  printf("Setting scheduling policy to FCFS (1)...\n");
  52:	00001517          	auipc	a0,0x1
  56:	99e50513          	addi	a0,a0,-1634 # 9f0 <malloc+0x106>
  5a:	7dc000ef          	jal	836 <printf>
  set_sched(1);
  5e:	4505                	li	a0,1
  60:	42e000ef          	jal	48e <set_sched>

  int workload[5] = {100000000, 80000000, 60000000, 40000000, 20000000};
  64:	05f5e7b7          	lui	a5,0x5f5e
  68:	10078793          	addi	a5,a5,256 # 5f5e100 <base+0x5f5d0f0>
  6c:	faf42c23          	sw	a5,-72(s0)
  70:	04c4b7b7          	lui	a5,0x4c4b
  74:	40078793          	addi	a5,a5,1024 # 4c4b400 <base+0x4c4a3f0>
  78:	faf42e23          	sw	a5,-68(s0)
  7c:	039387b7          	lui	a5,0x3938
  80:	70078793          	addi	a5,a5,1792 # 3938700 <base+0x39376f0>
  84:	fcf42023          	sw	a5,-64(s0)
  88:	026267b7          	lui	a5,0x2626
  8c:	a0078793          	addi	a5,a5,-1536 # 2625a00 <base+0x26249f0>
  90:	fcf42223          	sw	a5,-60(s0)
  94:	013137b7          	lui	a5,0x1313
  98:	d0078793          	addi	a5,a5,-768 # 1312d00 <base+0x1311cf0>
  9c:	fcf42423          	sw	a5,-56(s0)

  for (int i = 0; i < 5; i++) {
  a0:	4481                	li	s1,0
  a2:	4995                	li	s3,5
    pid = fork();
  a4:	342000ef          	jal	3e6 <fork>
    if (pid == 0) {
  a8:	c139                	beqz	a0,ee <main+0xb2>
      printf("Child %d DONE at %d ticks\n", mypid, uptime() - start_time);
      release_lock();

      exit(0);
    }
    sleep(3);
  aa:	450d                	li	a0,3
  ac:	3d2000ef          	jal	47e <sleep>
  for (int i = 0; i < 5; i++) {
  b0:	2485                	addiw	s1,s1,1
  b2:	ff3499e3          	bne	s1,s3,a4 <main+0x68>
  }

  
  for (int i = 0; i < 5; i++) {
    wait(0);
  b6:	4501                	li	a0,0
  b8:	33e000ef          	jal	3f6 <wait>
  bc:	4501                	li	a0,0
  be:	338000ef          	jal	3f6 <wait>
  c2:	4501                	li	a0,0
  c4:	332000ef          	jal	3f6 <wait>
  c8:	4501                	li	a0,0
  ca:	32c000ef          	jal	3f6 <wait>
  ce:	4501                	li	a0,0
  d0:	326000ef          	jal	3f6 <wait>
  }

  acquire_lock();
  d4:	f2dff0ef          	jal	0 <acquire_lock>
  printf("Parent done\n");
  d8:	00001517          	auipc	a0,0x1
  dc:	96850513          	addi	a0,a0,-1688 # a40 <malloc+0x156>
  e0:	756000ef          	jal	836 <printf>
  release_lock();
  e4:	f3dff0ef          	jal	20 <release_lock>

  exit(0);
  e8:	4501                	li	a0,0
  ea:	304000ef          	jal	3ee <exit>
      int mypid = getpid();
  ee:	380000ef          	jal	46e <getpid>
  f2:	89aa                	mv	s3,a0
      acquire_lock();
  f4:	f0dff0ef          	jal	0 <acquire_lock>
      release_lock();
  f8:	f29ff0ef          	jal	20 <release_lock>
      volatile int x = 0;
  fc:	fa042823          	sw	zero,-80(s0)
      for (volatile int j = 0; j < workload[i]; j++) {
 100:	fa042a23          	sw	zero,-76(s0)
 104:	048a                	slli	s1,s1,0x2
 106:	fd048793          	addi	a5,s1,-48
 10a:	008784b3          	add	s1,a5,s0
 10e:	fe84aa03          	lw	s4,-24(s1)
 112:	fb442783          	lw	a5,-76(s0)
 116:	2781                	sext.w	a5,a5
 118:	0547d463          	bge	a5,s4,160 <main+0x124>
        if (j % 20000000 == 0 && j != 0) {
 11c:	013134b7          	lui	s1,0x1313
 120:	d004849b          	addiw	s1,s1,-768 # 1312d00 <base+0x1311cf0>
 124:	a005                	j	144 <main+0x108>
        x++;
 126:	fb042783          	lw	a5,-80(s0)
 12a:	2785                	addiw	a5,a5,1
 12c:	faf42823          	sw	a5,-80(s0)
      for (volatile int j = 0; j < workload[i]; j++) {
 130:	fb442783          	lw	a5,-76(s0)
 134:	2785                	addiw	a5,a5,1
 136:	faf42a23          	sw	a5,-76(s0)
 13a:	fb442783          	lw	a5,-76(s0)
 13e:	2781                	sext.w	a5,a5
 140:	0347d063          	bge	a5,s4,160 <main+0x124>
        if (j % 20000000 == 0 && j != 0) {
 144:	fb442783          	lw	a5,-76(s0)
 148:	0297e7bb          	remw	a5,a5,s1
 14c:	ffe9                	bnez	a5,126 <main+0xea>
 14e:	fb442783          	lw	a5,-76(s0)
 152:	2781                	sext.w	a5,a5
 154:	dbe9                	beqz	a5,126 <main+0xea>
          acquire_lock();
 156:	eabff0ef          	jal	0 <acquire_lock>
          release_lock();
 15a:	ec7ff0ef          	jal	20 <release_lock>
 15e:	b7e1                	j	126 <main+0xea>
      acquire_lock();
 160:	ea1ff0ef          	jal	0 <acquire_lock>
      printf("Child %d DONE at %d ticks\n", mypid, uptime() - start_time);
 164:	322000ef          	jal	486 <uptime>
 168:	4125063b          	subw	a2,a0,s2
 16c:	85ce                	mv	a1,s3
 16e:	00001517          	auipc	a0,0x1
 172:	8b250513          	addi	a0,a0,-1870 # a20 <malloc+0x136>
 176:	6c0000ef          	jal	836 <printf>
      release_lock();
 17a:	ea7ff0ef          	jal	20 <release_lock>
      exit(0);
 17e:	4501                	li	a0,0
 180:	26e000ef          	jal	3ee <exit>

0000000000000184 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 184:	1141                	addi	sp,sp,-16
 186:	e406                	sd	ra,8(sp)
 188:	e022                	sd	s0,0(sp)
 18a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 18c:	eb1ff0ef          	jal	3c <main>
  exit(0);
 190:	4501                	li	a0,0
 192:	25c000ef          	jal	3ee <exit>

0000000000000196 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 19c:	87aa                	mv	a5,a0
 19e:	0585                	addi	a1,a1,1
 1a0:	0785                	addi	a5,a5,1
 1a2:	fff5c703          	lbu	a4,-1(a1)
 1a6:	fee78fa3          	sb	a4,-1(a5)
 1aa:	fb75                	bnez	a4,19e <strcpy+0x8>
    ;
  return os;
}
 1ac:	6422                	ld	s0,8(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret

00000000000001b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e422                	sd	s0,8(sp)
 1b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	cb91                	beqz	a5,1d0 <strcmp+0x1e>
 1be:	0005c703          	lbu	a4,0(a1)
 1c2:	00f71763          	bne	a4,a5,1d0 <strcmp+0x1e>
    p++, q++;
 1c6:	0505                	addi	a0,a0,1
 1c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	fbe5                	bnez	a5,1be <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1d0:	0005c503          	lbu	a0,0(a1)
}
 1d4:	40a7853b          	subw	a0,a5,a0
 1d8:	6422                	ld	s0,8(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret

00000000000001de <strlen>:

uint
strlen(const char *s)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	cf91                	beqz	a5,204 <strlen+0x26>
 1ea:	0505                	addi	a0,a0,1
 1ec:	87aa                	mv	a5,a0
 1ee:	86be                	mv	a3,a5
 1f0:	0785                	addi	a5,a5,1
 1f2:	fff7c703          	lbu	a4,-1(a5)
 1f6:	ff65                	bnez	a4,1ee <strlen+0x10>
 1f8:	40a6853b          	subw	a0,a3,a0
 1fc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  for(n = 0; s[n]; n++)
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <strlen+0x20>

0000000000000208 <memset>:

void*
memset(void *dst, int c, uint n)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 20e:	ca19                	beqz	a2,224 <memset+0x1c>
 210:	87aa                	mv	a5,a0
 212:	1602                	slli	a2,a2,0x20
 214:	9201                	srli	a2,a2,0x20
 216:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 21a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 21e:	0785                	addi	a5,a5,1
 220:	fee79de3          	bne	a5,a4,21a <memset+0x12>
  }
  return dst;
}
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret

000000000000022a <strchr>:

char*
strchr(const char *s, char c)
{
 22a:	1141                	addi	sp,sp,-16
 22c:	e422                	sd	s0,8(sp)
 22e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 230:	00054783          	lbu	a5,0(a0)
 234:	cb99                	beqz	a5,24a <strchr+0x20>
    if(*s == c)
 236:	00f58763          	beq	a1,a5,244 <strchr+0x1a>
  for(; *s; s++)
 23a:	0505                	addi	a0,a0,1
 23c:	00054783          	lbu	a5,0(a0)
 240:	fbfd                	bnez	a5,236 <strchr+0xc>
      return (char*)s;
  return 0;
 242:	4501                	li	a0,0
}
 244:	6422                	ld	s0,8(sp)
 246:	0141                	addi	sp,sp,16
 248:	8082                	ret
  return 0;
 24a:	4501                	li	a0,0
 24c:	bfe5                	j	244 <strchr+0x1a>

000000000000024e <gets>:

char*
gets(char *buf, int max)
{
 24e:	711d                	addi	sp,sp,-96
 250:	ec86                	sd	ra,88(sp)
 252:	e8a2                	sd	s0,80(sp)
 254:	e4a6                	sd	s1,72(sp)
 256:	e0ca                	sd	s2,64(sp)
 258:	fc4e                	sd	s3,56(sp)
 25a:	f852                	sd	s4,48(sp)
 25c:	f456                	sd	s5,40(sp)
 25e:	f05a                	sd	s6,32(sp)
 260:	ec5e                	sd	s7,24(sp)
 262:	1080                	addi	s0,sp,96
 264:	8baa                	mv	s7,a0
 266:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 268:	892a                	mv	s2,a0
 26a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 26c:	4aa9                	li	s5,10
 26e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 270:	89a6                	mv	s3,s1
 272:	2485                	addiw	s1,s1,1
 274:	0344d663          	bge	s1,s4,2a0 <gets+0x52>
    cc = read(0, &c, 1);
 278:	4605                	li	a2,1
 27a:	faf40593          	addi	a1,s0,-81
 27e:	4501                	li	a0,0
 280:	186000ef          	jal	406 <read>
    if(cc < 1)
 284:	00a05e63          	blez	a0,2a0 <gets+0x52>
    buf[i++] = c;
 288:	faf44783          	lbu	a5,-81(s0)
 28c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 290:	01578763          	beq	a5,s5,29e <gets+0x50>
 294:	0905                	addi	s2,s2,1
 296:	fd679de3          	bne	a5,s6,270 <gets+0x22>
    buf[i++] = c;
 29a:	89a6                	mv	s3,s1
 29c:	a011                	j	2a0 <gets+0x52>
 29e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a0:	99de                	add	s3,s3,s7
 2a2:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a6:	855e                	mv	a0,s7
 2a8:	60e6                	ld	ra,88(sp)
 2aa:	6446                	ld	s0,80(sp)
 2ac:	64a6                	ld	s1,72(sp)
 2ae:	6906                	ld	s2,64(sp)
 2b0:	79e2                	ld	s3,56(sp)
 2b2:	7a42                	ld	s4,48(sp)
 2b4:	7aa2                	ld	s5,40(sp)
 2b6:	7b02                	ld	s6,32(sp)
 2b8:	6be2                	ld	s7,24(sp)
 2ba:	6125                	addi	sp,sp,96
 2bc:	8082                	ret

00000000000002be <stat>:

int
stat(const char *n, struct stat *st)
{
 2be:	1101                	addi	sp,sp,-32
 2c0:	ec06                	sd	ra,24(sp)
 2c2:	e822                	sd	s0,16(sp)
 2c4:	e04a                	sd	s2,0(sp)
 2c6:	1000                	addi	s0,sp,32
 2c8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ca:	4581                	li	a1,0
 2cc:	162000ef          	jal	42e <open>
  if(fd < 0)
 2d0:	02054263          	bltz	a0,2f4 <stat+0x36>
 2d4:	e426                	sd	s1,8(sp)
 2d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2d8:	85ca                	mv	a1,s2
 2da:	16c000ef          	jal	446 <fstat>
 2de:	892a                	mv	s2,a0
  close(fd);
 2e0:	8526                	mv	a0,s1
 2e2:	134000ef          	jal	416 <close>
  return r;
 2e6:	64a2                	ld	s1,8(sp)
}
 2e8:	854a                	mv	a0,s2
 2ea:	60e2                	ld	ra,24(sp)
 2ec:	6442                	ld	s0,16(sp)
 2ee:	6902                	ld	s2,0(sp)
 2f0:	6105                	addi	sp,sp,32
 2f2:	8082                	ret
    return -1;
 2f4:	597d                	li	s2,-1
 2f6:	bfcd                	j	2e8 <stat+0x2a>

00000000000002f8 <atoi>:

int
atoi(const char *s)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e422                	sd	s0,8(sp)
 2fc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fe:	00054683          	lbu	a3,0(a0)
 302:	fd06879b          	addiw	a5,a3,-48
 306:	0ff7f793          	zext.b	a5,a5
 30a:	4625                	li	a2,9
 30c:	02f66863          	bltu	a2,a5,33c <atoi+0x44>
 310:	872a                	mv	a4,a0
  n = 0;
 312:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 314:	0705                	addi	a4,a4,1
 316:	0025179b          	slliw	a5,a0,0x2
 31a:	9fa9                	addw	a5,a5,a0
 31c:	0017979b          	slliw	a5,a5,0x1
 320:	9fb5                	addw	a5,a5,a3
 322:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 326:	00074683          	lbu	a3,0(a4)
 32a:	fd06879b          	addiw	a5,a3,-48
 32e:	0ff7f793          	zext.b	a5,a5
 332:	fef671e3          	bgeu	a2,a5,314 <atoi+0x1c>
  return n;
}
 336:	6422                	ld	s0,8(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret
  n = 0;
 33c:	4501                	li	a0,0
 33e:	bfe5                	j	336 <atoi+0x3e>

0000000000000340 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 346:	02b57463          	bgeu	a0,a1,36e <memmove+0x2e>
    while(n-- > 0)
 34a:	00c05f63          	blez	a2,368 <memmove+0x28>
 34e:	1602                	slli	a2,a2,0x20
 350:	9201                	srli	a2,a2,0x20
 352:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 356:	872a                	mv	a4,a0
      *dst++ = *src++;
 358:	0585                	addi	a1,a1,1
 35a:	0705                	addi	a4,a4,1
 35c:	fff5c683          	lbu	a3,-1(a1)
 360:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 364:	fef71ae3          	bne	a4,a5,358 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret
    dst += n;
 36e:	00c50733          	add	a4,a0,a2
    src += n;
 372:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 374:	fec05ae3          	blez	a2,368 <memmove+0x28>
 378:	fff6079b          	addiw	a5,a2,-1
 37c:	1782                	slli	a5,a5,0x20
 37e:	9381                	srli	a5,a5,0x20
 380:	fff7c793          	not	a5,a5
 384:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 386:	15fd                	addi	a1,a1,-1
 388:	177d                	addi	a4,a4,-1
 38a:	0005c683          	lbu	a3,0(a1)
 38e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 392:	fee79ae3          	bne	a5,a4,386 <memmove+0x46>
 396:	bfc9                	j	368 <memmove+0x28>

0000000000000398 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e422                	sd	s0,8(sp)
 39c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 39e:	ca05                	beqz	a2,3ce <memcmp+0x36>
 3a0:	fff6069b          	addiw	a3,a2,-1
 3a4:	1682                	slli	a3,a3,0x20
 3a6:	9281                	srli	a3,a3,0x20
 3a8:	0685                	addi	a3,a3,1
 3aa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ac:	00054783          	lbu	a5,0(a0)
 3b0:	0005c703          	lbu	a4,0(a1)
 3b4:	00e79863          	bne	a5,a4,3c4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3b8:	0505                	addi	a0,a0,1
    p2++;
 3ba:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3bc:	fed518e3          	bne	a0,a3,3ac <memcmp+0x14>
  }
  return 0;
 3c0:	4501                	li	a0,0
 3c2:	a019                	j	3c8 <memcmp+0x30>
      return *p1 - *p2;
 3c4:	40e7853b          	subw	a0,a5,a4
}
 3c8:	6422                	ld	s0,8(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret
  return 0;
 3ce:	4501                	li	a0,0
 3d0:	bfe5                	j	3c8 <memcmp+0x30>

00000000000003d2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d2:	1141                	addi	sp,sp,-16
 3d4:	e406                	sd	ra,8(sp)
 3d6:	e022                	sd	s0,0(sp)
 3d8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3da:	f67ff0ef          	jal	340 <memmove>
}
 3de:	60a2                	ld	ra,8(sp)
 3e0:	6402                	ld	s0,0(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret

00000000000003e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e6:	4885                	li	a7,1
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ee:	4889                	li	a7,2
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f6:	488d                	li	a7,3
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3fe:	4891                	li	a7,4
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <read>:
.global read
read:
 li a7, SYS_read
 406:	4895                	li	a7,5
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <write>:
.global write
write:
 li a7, SYS_write
 40e:	48c1                	li	a7,16
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <close>:
.global close
close:
 li a7, SYS_close
 416:	48d5                	li	a7,21
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <kill>:
.global kill
kill:
 li a7, SYS_kill
 41e:	4899                	li	a7,6
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <exec>:
.global exec
exec:
 li a7, SYS_exec
 426:	489d                	li	a7,7
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <open>:
.global open
open:
 li a7, SYS_open
 42e:	48bd                	li	a7,15
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 436:	48c5                	li	a7,17
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 43e:	48c9                	li	a7,18
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 446:	48a1                	li	a7,8
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <link>:
.global link
link:
 li a7, SYS_link
 44e:	48cd                	li	a7,19
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 456:	48d1                	li	a7,20
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 45e:	48a5                	li	a7,9
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <dup>:
.global dup
dup:
 li a7, SYS_dup
 466:	48a9                	li	a7,10
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 46e:	48ad                	li	a7,11
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 476:	48b1                	li	a7,12
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 47e:	48b5                	li	a7,13
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 486:	48b9                	li	a7,14
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <set_sched>:
.global set_sched
set_sched:
 li a7, SYS_set_sched
 48e:	48d9                	li	a7,22
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 496:	48dd                	li	a7,23
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <top>:
.global top
top:
 li a7, SYS_top
 49e:	48e1                	li	a7,24
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <fork_with_priority>:
.global fork_with_priority
fork_with_priority:
 li a7, SYS_fork_with_priority
 4a6:	48e5                	li	a7,25
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <yield>:
.global yield
yield:
 li a7, SYS_yield
 4ae:	48e9                	li	a7,26
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <get_waiting_time>:
.global get_waiting_time
get_waiting_time:
  li a7, SYS_get_waiting_time
 4b6:	48ed                	li	a7,27
  ecall
 4b8:	00000073          	ecall
  ret
 4bc:	8082                	ret

00000000000004be <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4be:	1101                	addi	sp,sp,-32
 4c0:	ec06                	sd	ra,24(sp)
 4c2:	e822                	sd	s0,16(sp)
 4c4:	1000                	addi	s0,sp,32
 4c6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ca:	4605                	li	a2,1
 4cc:	fef40593          	addi	a1,s0,-17
 4d0:	f3fff0ef          	jal	40e <write>
}
 4d4:	60e2                	ld	ra,24(sp)
 4d6:	6442                	ld	s0,16(sp)
 4d8:	6105                	addi	sp,sp,32
 4da:	8082                	ret

00000000000004dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4dc:	7139                	addi	sp,sp,-64
 4de:	fc06                	sd	ra,56(sp)
 4e0:	f822                	sd	s0,48(sp)
 4e2:	f426                	sd	s1,40(sp)
 4e4:	0080                	addi	s0,sp,64
 4e6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e8:	c299                	beqz	a3,4ee <printint+0x12>
 4ea:	0805c963          	bltz	a1,57c <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ee:	2581                	sext.w	a1,a1
  neg = 0;
 4f0:	4881                	li	a7,0
 4f2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f8:	2601                	sext.w	a2,a2
 4fa:	00000517          	auipc	a0,0x0
 4fe:	55e50513          	addi	a0,a0,1374 # a58 <digits>
 502:	883a                	mv	a6,a4
 504:	2705                	addiw	a4,a4,1
 506:	02c5f7bb          	remuw	a5,a1,a2
 50a:	1782                	slli	a5,a5,0x20
 50c:	9381                	srli	a5,a5,0x20
 50e:	97aa                	add	a5,a5,a0
 510:	0007c783          	lbu	a5,0(a5)
 514:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 518:	0005879b          	sext.w	a5,a1
 51c:	02c5d5bb          	divuw	a1,a1,a2
 520:	0685                	addi	a3,a3,1
 522:	fec7f0e3          	bgeu	a5,a2,502 <printint+0x26>
  if(neg)
 526:	00088c63          	beqz	a7,53e <printint+0x62>
    buf[i++] = '-';
 52a:	fd070793          	addi	a5,a4,-48
 52e:	00878733          	add	a4,a5,s0
 532:	02d00793          	li	a5,45
 536:	fef70823          	sb	a5,-16(a4)
 53a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 53e:	02e05a63          	blez	a4,572 <printint+0x96>
 542:	f04a                	sd	s2,32(sp)
 544:	ec4e                	sd	s3,24(sp)
 546:	fc040793          	addi	a5,s0,-64
 54a:	00e78933          	add	s2,a5,a4
 54e:	fff78993          	addi	s3,a5,-1
 552:	99ba                	add	s3,s3,a4
 554:	377d                	addiw	a4,a4,-1
 556:	1702                	slli	a4,a4,0x20
 558:	9301                	srli	a4,a4,0x20
 55a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 55e:	fff94583          	lbu	a1,-1(s2)
 562:	8526                	mv	a0,s1
 564:	f5bff0ef          	jal	4be <putc>
  while(--i >= 0)
 568:	197d                	addi	s2,s2,-1
 56a:	ff391ae3          	bne	s2,s3,55e <printint+0x82>
 56e:	7902                	ld	s2,32(sp)
 570:	69e2                	ld	s3,24(sp)
}
 572:	70e2                	ld	ra,56(sp)
 574:	7442                	ld	s0,48(sp)
 576:	74a2                	ld	s1,40(sp)
 578:	6121                	addi	sp,sp,64
 57a:	8082                	ret
    x = -xx;
 57c:	40b005bb          	negw	a1,a1
    neg = 1;
 580:	4885                	li	a7,1
    x = -xx;
 582:	bf85                	j	4f2 <printint+0x16>

0000000000000584 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 584:	711d                	addi	sp,sp,-96
 586:	ec86                	sd	ra,88(sp)
 588:	e8a2                	sd	s0,80(sp)
 58a:	e0ca                	sd	s2,64(sp)
 58c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 58e:	0005c903          	lbu	s2,0(a1)
 592:	26090863          	beqz	s2,802 <vprintf+0x27e>
 596:	e4a6                	sd	s1,72(sp)
 598:	fc4e                	sd	s3,56(sp)
 59a:	f852                	sd	s4,48(sp)
 59c:	f456                	sd	s5,40(sp)
 59e:	f05a                	sd	s6,32(sp)
 5a0:	ec5e                	sd	s7,24(sp)
 5a2:	e862                	sd	s8,16(sp)
 5a4:	e466                	sd	s9,8(sp)
 5a6:	8b2a                	mv	s6,a0
 5a8:	8a2e                	mv	s4,a1
 5aa:	8bb2                	mv	s7,a2
  state = 0;
 5ac:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5ae:	4481                	li	s1,0
 5b0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5b2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5b6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5ba:	06c00c93          	li	s9,108
 5be:	a005                	j	5de <vprintf+0x5a>
        putc(fd, c0);
 5c0:	85ca                	mv	a1,s2
 5c2:	855a                	mv	a0,s6
 5c4:	efbff0ef          	jal	4be <putc>
 5c8:	a019                	j	5ce <vprintf+0x4a>
    } else if(state == '%'){
 5ca:	03598263          	beq	s3,s5,5ee <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5ce:	2485                	addiw	s1,s1,1
 5d0:	8726                	mv	a4,s1
 5d2:	009a07b3          	add	a5,s4,s1
 5d6:	0007c903          	lbu	s2,0(a5)
 5da:	20090c63          	beqz	s2,7f2 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 5de:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e2:	fe0994e3          	bnez	s3,5ca <vprintf+0x46>
      if(c0 == '%'){
 5e6:	fd579de3          	bne	a5,s5,5c0 <vprintf+0x3c>
        state = '%';
 5ea:	89be                	mv	s3,a5
 5ec:	b7cd                	j	5ce <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5ee:	00ea06b3          	add	a3,s4,a4
 5f2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5f6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5f8:	c681                	beqz	a3,600 <vprintf+0x7c>
 5fa:	9752                	add	a4,a4,s4
 5fc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 600:	03878f63          	beq	a5,s8,63e <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 604:	05978963          	beq	a5,s9,656 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 608:	07500713          	li	a4,117
 60c:	0ee78363          	beq	a5,a4,6f2 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 610:	07800713          	li	a4,120
 614:	12e78563          	beq	a5,a4,73e <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 618:	07000713          	li	a4,112
 61c:	14e78a63          	beq	a5,a4,770 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 620:	07300713          	li	a4,115
 624:	18e78a63          	beq	a5,a4,7b8 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 628:	02500713          	li	a4,37
 62c:	04e79563          	bne	a5,a4,676 <vprintf+0xf2>
        putc(fd, '%');
 630:	02500593          	li	a1,37
 634:	855a                	mv	a0,s6
 636:	e89ff0ef          	jal	4be <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 63a:	4981                	li	s3,0
 63c:	bf49                	j	5ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 63e:	008b8913          	addi	s2,s7,8
 642:	4685                	li	a3,1
 644:	4629                	li	a2,10
 646:	000ba583          	lw	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	e91ff0ef          	jal	4dc <printint>
 650:	8bca                	mv	s7,s2
      state = 0;
 652:	4981                	li	s3,0
 654:	bfad                	j	5ce <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 656:	06400793          	li	a5,100
 65a:	02f68963          	beq	a3,a5,68c <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 65e:	06c00793          	li	a5,108
 662:	04f68263          	beq	a3,a5,6a6 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 666:	07500793          	li	a5,117
 66a:	0af68063          	beq	a3,a5,70a <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 66e:	07800793          	li	a5,120
 672:	0ef68263          	beq	a3,a5,756 <vprintf+0x1d2>
        putc(fd, '%');
 676:	02500593          	li	a1,37
 67a:	855a                	mv	a0,s6
 67c:	e43ff0ef          	jal	4be <putc>
        putc(fd, c0);
 680:	85ca                	mv	a1,s2
 682:	855a                	mv	a0,s6
 684:	e3bff0ef          	jal	4be <putc>
      state = 0;
 688:	4981                	li	s3,0
 68a:	b791                	j	5ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 68c:	008b8913          	addi	s2,s7,8
 690:	4685                	li	a3,1
 692:	4629                	li	a2,10
 694:	000ba583          	lw	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	e43ff0ef          	jal	4dc <printint>
        i += 1;
 69e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
        i += 1;
 6a4:	b72d                	j	5ce <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6a6:	06400793          	li	a5,100
 6aa:	02f60763          	beq	a2,a5,6d8 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6ae:	07500793          	li	a5,117
 6b2:	06f60963          	beq	a2,a5,724 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6b6:	07800793          	li	a5,120
 6ba:	faf61ee3          	bne	a2,a5,676 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6be:	008b8913          	addi	s2,s7,8
 6c2:	4681                	li	a3,0
 6c4:	4641                	li	a2,16
 6c6:	000ba583          	lw	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	e11ff0ef          	jal	4dc <printint>
        i += 2;
 6d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
        i += 2;
 6d6:	bde5                	j	5ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d8:	008b8913          	addi	s2,s7,8
 6dc:	4685                	li	a3,1
 6de:	4629                	li	a2,10
 6e0:	000ba583          	lw	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	df7ff0ef          	jal	4dc <printint>
        i += 2;
 6ea:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ec:	8bca                	mv	s7,s2
      state = 0;
 6ee:	4981                	li	s3,0
        i += 2;
 6f0:	bdf9                	j	5ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 6f2:	008b8913          	addi	s2,s7,8
 6f6:	4681                	li	a3,0
 6f8:	4629                	li	a2,10
 6fa:	000ba583          	lw	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	dddff0ef          	jal	4dc <printint>
 704:	8bca                	mv	s7,s2
      state = 0;
 706:	4981                	li	s3,0
 708:	b5d9                	j	5ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70a:	008b8913          	addi	s2,s7,8
 70e:	4681                	li	a3,0
 710:	4629                	li	a2,10
 712:	000ba583          	lw	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	dc5ff0ef          	jal	4dc <printint>
        i += 1;
 71c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 71e:	8bca                	mv	s7,s2
      state = 0;
 720:	4981                	li	s3,0
        i += 1;
 722:	b575                	j	5ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 724:	008b8913          	addi	s2,s7,8
 728:	4681                	li	a3,0
 72a:	4629                	li	a2,10
 72c:	000ba583          	lw	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	dabff0ef          	jal	4dc <printint>
        i += 2;
 736:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 738:	8bca                	mv	s7,s2
      state = 0;
 73a:	4981                	li	s3,0
        i += 2;
 73c:	bd49                	j	5ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 73e:	008b8913          	addi	s2,s7,8
 742:	4681                	li	a3,0
 744:	4641                	li	a2,16
 746:	000ba583          	lw	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	d91ff0ef          	jal	4dc <printint>
 750:	8bca                	mv	s7,s2
      state = 0;
 752:	4981                	li	s3,0
 754:	bdad                	j	5ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 756:	008b8913          	addi	s2,s7,8
 75a:	4681                	li	a3,0
 75c:	4641                	li	a2,16
 75e:	000ba583          	lw	a1,0(s7)
 762:	855a                	mv	a0,s6
 764:	d79ff0ef          	jal	4dc <printint>
        i += 1;
 768:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 76a:	8bca                	mv	s7,s2
      state = 0;
 76c:	4981                	li	s3,0
        i += 1;
 76e:	b585                	j	5ce <vprintf+0x4a>
 770:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 772:	008b8d13          	addi	s10,s7,8
 776:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 77a:	03000593          	li	a1,48
 77e:	855a                	mv	a0,s6
 780:	d3fff0ef          	jal	4be <putc>
  putc(fd, 'x');
 784:	07800593          	li	a1,120
 788:	855a                	mv	a0,s6
 78a:	d35ff0ef          	jal	4be <putc>
 78e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 790:	00000b97          	auipc	s7,0x0
 794:	2c8b8b93          	addi	s7,s7,712 # a58 <digits>
 798:	03c9d793          	srli	a5,s3,0x3c
 79c:	97de                	add	a5,a5,s7
 79e:	0007c583          	lbu	a1,0(a5)
 7a2:	855a                	mv	a0,s6
 7a4:	d1bff0ef          	jal	4be <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7a8:	0992                	slli	s3,s3,0x4
 7aa:	397d                	addiw	s2,s2,-1
 7ac:	fe0916e3          	bnez	s2,798 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 7b0:	8bea                	mv	s7,s10
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	6d02                	ld	s10,0(sp)
 7b6:	bd21                	j	5ce <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7b8:	008b8993          	addi	s3,s7,8
 7bc:	000bb903          	ld	s2,0(s7)
 7c0:	00090f63          	beqz	s2,7de <vprintf+0x25a>
        for(; *s; s++)
 7c4:	00094583          	lbu	a1,0(s2)
 7c8:	c195                	beqz	a1,7ec <vprintf+0x268>
          putc(fd, *s);
 7ca:	855a                	mv	a0,s6
 7cc:	cf3ff0ef          	jal	4be <putc>
        for(; *s; s++)
 7d0:	0905                	addi	s2,s2,1
 7d2:	00094583          	lbu	a1,0(s2)
 7d6:	f9f5                	bnez	a1,7ca <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7d8:	8bce                	mv	s7,s3
      state = 0;
 7da:	4981                	li	s3,0
 7dc:	bbcd                	j	5ce <vprintf+0x4a>
          s = "(null)";
 7de:	00000917          	auipc	s2,0x0
 7e2:	27290913          	addi	s2,s2,626 # a50 <malloc+0x166>
        for(; *s; s++)
 7e6:	02800593          	li	a1,40
 7ea:	b7c5                	j	7ca <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7ec:	8bce                	mv	s7,s3
      state = 0;
 7ee:	4981                	li	s3,0
 7f0:	bbf9                	j	5ce <vprintf+0x4a>
 7f2:	64a6                	ld	s1,72(sp)
 7f4:	79e2                	ld	s3,56(sp)
 7f6:	7a42                	ld	s4,48(sp)
 7f8:	7aa2                	ld	s5,40(sp)
 7fa:	7b02                	ld	s6,32(sp)
 7fc:	6be2                	ld	s7,24(sp)
 7fe:	6c42                	ld	s8,16(sp)
 800:	6ca2                	ld	s9,8(sp)
    }
  }
}
 802:	60e6                	ld	ra,88(sp)
 804:	6446                	ld	s0,80(sp)
 806:	6906                	ld	s2,64(sp)
 808:	6125                	addi	sp,sp,96
 80a:	8082                	ret

000000000000080c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 80c:	715d                	addi	sp,sp,-80
 80e:	ec06                	sd	ra,24(sp)
 810:	e822                	sd	s0,16(sp)
 812:	1000                	addi	s0,sp,32
 814:	e010                	sd	a2,0(s0)
 816:	e414                	sd	a3,8(s0)
 818:	e818                	sd	a4,16(s0)
 81a:	ec1c                	sd	a5,24(s0)
 81c:	03043023          	sd	a6,32(s0)
 820:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 824:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 828:	8622                	mv	a2,s0
 82a:	d5bff0ef          	jal	584 <vprintf>
}
 82e:	60e2                	ld	ra,24(sp)
 830:	6442                	ld	s0,16(sp)
 832:	6161                	addi	sp,sp,80
 834:	8082                	ret

0000000000000836 <printf>:

void
printf(const char *fmt, ...)
{
 836:	711d                	addi	sp,sp,-96
 838:	ec06                	sd	ra,24(sp)
 83a:	e822                	sd	s0,16(sp)
 83c:	1000                	addi	s0,sp,32
 83e:	e40c                	sd	a1,8(s0)
 840:	e810                	sd	a2,16(s0)
 842:	ec14                	sd	a3,24(s0)
 844:	f018                	sd	a4,32(s0)
 846:	f41c                	sd	a5,40(s0)
 848:	03043823          	sd	a6,48(s0)
 84c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 850:	00840613          	addi	a2,s0,8
 854:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 858:	85aa                	mv	a1,a0
 85a:	4505                	li	a0,1
 85c:	d29ff0ef          	jal	584 <vprintf>
}
 860:	60e2                	ld	ra,24(sp)
 862:	6442                	ld	s0,16(sp)
 864:	6125                	addi	sp,sp,96
 866:	8082                	ret

0000000000000868 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 868:	1141                	addi	sp,sp,-16
 86a:	e422                	sd	s0,8(sp)
 86c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 86e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 872:	00000797          	auipc	a5,0x0
 876:	7967b783          	ld	a5,1942(a5) # 1008 <freep>
 87a:	a02d                	j	8a4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 87c:	4618                	lw	a4,8(a2)
 87e:	9f2d                	addw	a4,a4,a1
 880:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 884:	6398                	ld	a4,0(a5)
 886:	6310                	ld	a2,0(a4)
 888:	a83d                	j	8c6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 88a:	ff852703          	lw	a4,-8(a0)
 88e:	9f31                	addw	a4,a4,a2
 890:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 892:	ff053683          	ld	a3,-16(a0)
 896:	a091                	j	8da <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 898:	6398                	ld	a4,0(a5)
 89a:	00e7e463          	bltu	a5,a4,8a2 <free+0x3a>
 89e:	00e6ea63          	bltu	a3,a4,8b2 <free+0x4a>
{
 8a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a4:	fed7fae3          	bgeu	a5,a3,898 <free+0x30>
 8a8:	6398                	ld	a4,0(a5)
 8aa:	00e6e463          	bltu	a3,a4,8b2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ae:	fee7eae3          	bltu	a5,a4,8a2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8b2:	ff852583          	lw	a1,-8(a0)
 8b6:	6390                	ld	a2,0(a5)
 8b8:	02059813          	slli	a6,a1,0x20
 8bc:	01c85713          	srli	a4,a6,0x1c
 8c0:	9736                	add	a4,a4,a3
 8c2:	fae60de3          	beq	a2,a4,87c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ca:	4790                	lw	a2,8(a5)
 8cc:	02061593          	slli	a1,a2,0x20
 8d0:	01c5d713          	srli	a4,a1,0x1c
 8d4:	973e                	add	a4,a4,a5
 8d6:	fae68ae3          	beq	a3,a4,88a <free+0x22>
    p->s.ptr = bp->s.ptr;
 8da:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8dc:	00000717          	auipc	a4,0x0
 8e0:	72f73623          	sd	a5,1836(a4) # 1008 <freep>
}
 8e4:	6422                	ld	s0,8(sp)
 8e6:	0141                	addi	sp,sp,16
 8e8:	8082                	ret

00000000000008ea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ea:	7139                	addi	sp,sp,-64
 8ec:	fc06                	sd	ra,56(sp)
 8ee:	f822                	sd	s0,48(sp)
 8f0:	f426                	sd	s1,40(sp)
 8f2:	ec4e                	sd	s3,24(sp)
 8f4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f6:	02051493          	slli	s1,a0,0x20
 8fa:	9081                	srli	s1,s1,0x20
 8fc:	04bd                	addi	s1,s1,15
 8fe:	8091                	srli	s1,s1,0x4
 900:	0014899b          	addiw	s3,s1,1
 904:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 906:	00000517          	auipc	a0,0x0
 90a:	70253503          	ld	a0,1794(a0) # 1008 <freep>
 90e:	c915                	beqz	a0,942 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 910:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 912:	4798                	lw	a4,8(a5)
 914:	08977a63          	bgeu	a4,s1,9a8 <malloc+0xbe>
 918:	f04a                	sd	s2,32(sp)
 91a:	e852                	sd	s4,16(sp)
 91c:	e456                	sd	s5,8(sp)
 91e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 920:	8a4e                	mv	s4,s3
 922:	0009871b          	sext.w	a4,s3
 926:	6685                	lui	a3,0x1
 928:	00d77363          	bgeu	a4,a3,92e <malloc+0x44>
 92c:	6a05                	lui	s4,0x1
 92e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 932:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 936:	00000917          	auipc	s2,0x0
 93a:	6d290913          	addi	s2,s2,1746 # 1008 <freep>
  if(p == (char*)-1)
 93e:	5afd                	li	s5,-1
 940:	a081                	j	980 <malloc+0x96>
 942:	f04a                	sd	s2,32(sp)
 944:	e852                	sd	s4,16(sp)
 946:	e456                	sd	s5,8(sp)
 948:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 94a:	00000797          	auipc	a5,0x0
 94e:	6c678793          	addi	a5,a5,1734 # 1010 <base>
 952:	00000717          	auipc	a4,0x0
 956:	6af73b23          	sd	a5,1718(a4) # 1008 <freep>
 95a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 95c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 960:	b7c1                	j	920 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 962:	6398                	ld	a4,0(a5)
 964:	e118                	sd	a4,0(a0)
 966:	a8a9                	j	9c0 <malloc+0xd6>
  hp->s.size = nu;
 968:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 96c:	0541                	addi	a0,a0,16
 96e:	efbff0ef          	jal	868 <free>
  return freep;
 972:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 976:	c12d                	beqz	a0,9d8 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 978:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 97a:	4798                	lw	a4,8(a5)
 97c:	02977263          	bgeu	a4,s1,9a0 <malloc+0xb6>
    if(p == freep)
 980:	00093703          	ld	a4,0(s2)
 984:	853e                	mv	a0,a5
 986:	fef719e3          	bne	a4,a5,978 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 98a:	8552                	mv	a0,s4
 98c:	aebff0ef          	jal	476 <sbrk>
  if(p == (char*)-1)
 990:	fd551ce3          	bne	a0,s5,968 <malloc+0x7e>
        return 0;
 994:	4501                	li	a0,0
 996:	7902                	ld	s2,32(sp)
 998:	6a42                	ld	s4,16(sp)
 99a:	6aa2                	ld	s5,8(sp)
 99c:	6b02                	ld	s6,0(sp)
 99e:	a03d                	j	9cc <malloc+0xe2>
 9a0:	7902                	ld	s2,32(sp)
 9a2:	6a42                	ld	s4,16(sp)
 9a4:	6aa2                	ld	s5,8(sp)
 9a6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9a8:	fae48de3          	beq	s1,a4,962 <malloc+0x78>
        p->s.size -= nunits;
 9ac:	4137073b          	subw	a4,a4,s3
 9b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9b2:	02071693          	slli	a3,a4,0x20
 9b6:	01c6d713          	srli	a4,a3,0x1c
 9ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9c0:	00000717          	auipc	a4,0x0
 9c4:	64a73423          	sd	a0,1608(a4) # 1008 <freep>
      return (void*)(p + 1);
 9c8:	01078513          	addi	a0,a5,16
  }
}
 9cc:	70e2                	ld	ra,56(sp)
 9ce:	7442                	ld	s0,48(sp)
 9d0:	74a2                	ld	s1,40(sp)
 9d2:	69e2                	ld	s3,24(sp)
 9d4:	6121                	addi	sp,sp,64
 9d6:	8082                	ret
 9d8:	7902                	ld	s2,32(sp)
 9da:	6a42                	ld	s4,16(sp)
 9dc:	6aa2                	ld	s5,8(sp)
 9de:	6b02                	ld	s6,0(sp)
 9e0:	b7f5                	j	9cc <malloc+0xe2>
