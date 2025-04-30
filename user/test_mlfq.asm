
user/_test_mlfq:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <acquire_lock>:

extern void yield(void);

int printing = 0;

void acquire_lock() {
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

void release_lock() {
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

000000000000003c <simulate_workload>:

void simulate_workload(int loops, int print_every, int id, int start_time, const char *label) {
  3c:	711d                	addi	sp,sp,-96
  3e:	ec86                	sd	ra,88(sp)
  40:	e8a2                	sd	s0,80(sp)
  42:	1080                	addi	s0,sp,96
  volatile int x = 0;
  44:	fa042623          	sw	zero,-84(s0)
  for (volatile int i = 0; i < loops; i++) {
  48:	fa042423          	sw	zero,-88(s0)
  4c:	fa842783          	lw	a5,-88(s0)
  50:	08a7d063          	bge	a5,a0,d0 <simulate_workload+0x94>
  54:	e4a6                	sd	s1,72(sp)
  56:	e0ca                	sd	s2,64(sp)
  58:	fc4e                	sd	s3,56(sp)
  5a:	f852                	sd	s4,48(sp)
  5c:	f456                	sd	s5,40(sp)
  5e:	f05a                	sd	s6,32(sp)
  60:	ec5e                	sd	s7,24(sp)
  62:	84ae                	mv	s1,a1
  64:	89b2                	mv	s3,a2
  66:	8a36                	mv	s4,a3
  68:	8aba                	mv	s5,a4
  6a:	892a                	mv	s2,a0
    x++;
    if (i % print_every == 0) {
      int now = uptime();
      acquire_lock();
      printf("[%s] PID=%d running at tick=%d (+%d) (i=%d)\n",
  6c:	00001b17          	auipc	s6,0x1
  70:	a34b0b13          	addi	s6,s6,-1484 # aa0 <malloc+0x102>
  74:	a819                	j	8a <simulate_workload+0x4e>
  for (volatile int i = 0; i < loops; i++) {
  76:	fa842783          	lw	a5,-88(s0)
  7a:	2785                	addiw	a5,a5,1
  7c:	faf42423          	sw	a5,-88(s0)
  80:	fa842783          	lw	a5,-88(s0)
  84:	2781                	sext.w	a5,a5
  86:	0327de63          	bge	a5,s2,c2 <simulate_workload+0x86>
    x++;
  8a:	fac42783          	lw	a5,-84(s0)
  8e:	2785                	addiw	a5,a5,1
  90:	faf42623          	sw	a5,-84(s0)
    if (i % print_every == 0) {
  94:	fa842783          	lw	a5,-88(s0)
  98:	0297e7bb          	remw	a5,a5,s1
  9c:	ffe9                	bnez	a5,76 <simulate_workload+0x3a>
      int now = uptime();
  9e:	49c000ef          	jal	53a <uptime>
  a2:	8baa                	mv	s7,a0
      acquire_lock();
  a4:	f5dff0ef          	jal	0 <acquire_lock>
      printf("[%s] PID=%d running at tick=%d (+%d) (i=%d)\n",
  a8:	fa842783          	lw	a5,-88(s0)
  ac:	414b873b          	subw	a4,s7,s4
  b0:	86de                	mv	a3,s7
  b2:	864e                	mv	a2,s3
  b4:	85d6                	mv	a1,s5
  b6:	855a                	mv	a0,s6
  b8:	033000ef          	jal	8ea <printf>
             label, id, now, now - start_time, i);
      release_lock();
  bc:	f65ff0ef          	jal	20 <release_lock>
  c0:	bf5d                	j	76 <simulate_workload+0x3a>
  c2:	64a6                	ld	s1,72(sp)
  c4:	6906                	ld	s2,64(sp)
  c6:	79e2                	ld	s3,56(sp)
  c8:	7a42                	ld	s4,48(sp)
  ca:	7aa2                	ld	s5,40(sp)
  cc:	7b02                	ld	s6,32(sp)
  ce:	6be2                	ld	s7,24(sp)
    }
  }
}
  d0:	60e6                	ld	ra,88(sp)
  d2:	6446                	ld	s0,80(sp)
  d4:	6125                	addi	sp,sp,96
  d6:	8082                	ret

00000000000000d8 <main>:

int main() {
  d8:	7179                	addi	sp,sp,-48
  da:	f406                	sd	ra,40(sp)
  dc:	f022                	sd	s0,32(sp)
  de:	ec26                	sd	s1,24(sp)
  e0:	1800                	addi	s0,sp,48
  int boot_ticks = uptime();
  e2:	458000ef          	jal	53a <uptime>
  e6:	85aa                	mv	a1,a0
  printf("Current system tick at test start: %d\n", boot_ticks);
  e8:	00001517          	auipc	a0,0x1
  ec:	9f050513          	addi	a0,a0,-1552 # ad8 <malloc+0x13a>
  f0:	7fa000ef          	jal	8ea <printf>

  printf("Setting scheduling policy to MLFQ (4)...\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	a0c50513          	addi	a0,a0,-1524 # b00 <malloc+0x162>
  fc:	7ee000ef          	jal	8ea <printf>
  set_sched(4);
 100:	4511                	li	a0,4
 102:	440000ef          	jal	542 <set_sched>
  int start_time = uptime();
 106:	434000ef          	jal	53a <uptime>
 10a:	84aa                	mv	s1,a0

  int pid1 = fork();
 10c:	38e000ef          	jal	49a <fork>
  if (pid1 == 0) {
 110:	e935                	bnez	a0,184 <main+0xac>
 112:	e84a                	sd	s2,16(sp)
 114:	e44e                	sd	s3,8(sp)
    int mypid = getpid();
 116:	40c000ef          	jal	522 <getpid>
 11a:	892a                	mv	s2,a0
    int now = uptime();
 11c:	41e000ef          	jal	53a <uptime>
 120:	89aa                	mv	s3,a0
    acquire_lock();
 122:	edfff0ef          	jal	0 <acquire_lock>
    printf("Child1 (CPU-bound) PID=%d STARTED at tick=%d (+%d)\n", mypid, now, now - start_time);
 126:	409986bb          	subw	a3,s3,s1
 12a:	864e                	mv	a2,s3
 12c:	85ca                	mv	a1,s2
 12e:	00001517          	auipc	a0,0x1
 132:	a0250513          	addi	a0,a0,-1534 # b30 <malloc+0x192>
 136:	7b4000ef          	jal	8ea <printf>
    release_lock();
 13a:	ee7ff0ef          	jal	20 <release_lock>

    
    simulate_workload(200000000, 20000000, mypid, start_time, "Child1-Phase1");
 13e:	00001717          	auipc	a4,0x1
 142:	a2a70713          	addi	a4,a4,-1494 # b68 <malloc+0x1ca>
 146:	86a6                	mv	a3,s1
 148:	864a                	mv	a2,s2
 14a:	013135b7          	lui	a1,0x1313
 14e:	d0058593          	addi	a1,a1,-768 # 1312d00 <base+0x1311cf0>
 152:	0bebc537          	lui	a0,0xbebc
 156:	20050513          	addi	a0,a0,512 # bebc200 <base+0xbebb1f0>
 15a:	ee3ff0ef          	jal	3c <simulate_workload>

    now = uptime();
 15e:	3dc000ef          	jal	53a <uptime>
 162:	892a                	mv	s2,a0
    acquire_lock();
 164:	e9dff0ef          	jal	0 <acquire_lock>
    printf("Child1 DONE at tick=%d (+%d)\n", now, now - start_time);
 168:	4099063b          	subw	a2,s2,s1
 16c:	85ca                	mv	a1,s2
 16e:	00001517          	auipc	a0,0x1
 172:	a0a50513          	addi	a0,a0,-1526 # b78 <malloc+0x1da>
 176:	774000ef          	jal	8ea <printf>
    release_lock();
 17a:	ea7ff0ef          	jal	20 <release_lock>
    exit(0);
 17e:	4501                	li	a0,0
 180:	322000ef          	jal	4a2 <exit>
  }
  sleep(5);
 184:	4515                	li	a0,5
 186:	3ac000ef          	jal	532 <sleep>
  int pid2 = fork();
 18a:	310000ef          	jal	49a <fork>
  if (pid2 == 0) {
 18e:	e935                	bnez	a0,202 <main+0x12a>
 190:	e84a                	sd	s2,16(sp)
 192:	e44e                	sd	s3,8(sp)
    int mypid = getpid();
 194:	38e000ef          	jal	522 <getpid>
 198:	892a                	mv	s2,a0
    int now = uptime();
 19a:	3a0000ef          	jal	53a <uptime>
 19e:	89aa                	mv	s3,a0
    acquire_lock();
 1a0:	e61ff0ef          	jal	0 <acquire_lock>
    printf("Child2 (short-task x2) PID=%d STARTED at tick=%d (+%d)\n", mypid, now, now - start_time);
 1a4:	409986bb          	subw	a3,s3,s1
 1a8:	864e                	mv	a2,s3
 1aa:	85ca                	mv	a1,s2
 1ac:	00001517          	auipc	a0,0x1
 1b0:	9ec50513          	addi	a0,a0,-1556 # b98 <malloc+0x1fa>
 1b4:	736000ef          	jal	8ea <printf>
    release_lock();
 1b8:	e69ff0ef          	jal	20 <release_lock>

    
    simulate_workload(40000000, 10000000, mypid, start_time, "Child2-Phase1");
 1bc:	00001717          	auipc	a4,0x1
 1c0:	a1470713          	addi	a4,a4,-1516 # bd0 <malloc+0x232>
 1c4:	86a6                	mv	a3,s1
 1c6:	864a                	mv	a2,s2
 1c8:	009895b7          	lui	a1,0x989
 1cc:	68058593          	addi	a1,a1,1664 # 989680 <base+0x988670>
 1d0:	02626537          	lui	a0,0x2626
 1d4:	a0050513          	addi	a0,a0,-1536 # 2625a00 <base+0x26249f0>
 1d8:	e65ff0ef          	jal	3c <simulate_workload>
    

    now = uptime();
 1dc:	35e000ef          	jal	53a <uptime>
 1e0:	892a                	mv	s2,a0
    acquire_lock();
 1e2:	e1fff0ef          	jal	0 <acquire_lock>
    printf("Child2 DONE at tick=%d (+%d)\n", now, now - start_time);
 1e6:	4099063b          	subw	a2,s2,s1
 1ea:	85ca                	mv	a1,s2
 1ec:	00001517          	auipc	a0,0x1
 1f0:	9f450513          	addi	a0,a0,-1548 # be0 <malloc+0x242>
 1f4:	6f6000ef          	jal	8ea <printf>
    release_lock();
 1f8:	e29ff0ef          	jal	20 <release_lock>
    exit(0);
 1fc:	4501                	li	a0,0
 1fe:	2a4000ef          	jal	4a2 <exit>
 202:	e84a                	sd	s2,16(sp)
 204:	e44e                	sd	s3,8(sp)
  }

  wait(0);
 206:	4501                	li	a0,0
 208:	2a2000ef          	jal	4aa <wait>
  wait(0);
 20c:	4501                	li	a0,0
 20e:	29c000ef          	jal	4aa <wait>

  int now = uptime();
 212:	328000ef          	jal	53a <uptime>
 216:	892a                	mv	s2,a0
  acquire_lock();
 218:	de9ff0ef          	jal	0 <acquire_lock>
  printf("Parent done at tick=%d (+%d).\n", now, now - start_time);
 21c:	4099063b          	subw	a2,s2,s1
 220:	85ca                	mv	a1,s2
 222:	00001517          	auipc	a0,0x1
 226:	9de50513          	addi	a0,a0,-1570 # c00 <malloc+0x262>
 22a:	6c0000ef          	jal	8ea <printf>
  release_lock();
 22e:	df3ff0ef          	jal	20 <release_lock>

  exit(0);
 232:	4501                	li	a0,0
 234:	26e000ef          	jal	4a2 <exit>

0000000000000238 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 238:	1141                	addi	sp,sp,-16
 23a:	e406                	sd	ra,8(sp)
 23c:	e022                	sd	s0,0(sp)
 23e:	0800                	addi	s0,sp,16
  extern int main();
  main();
 240:	e99ff0ef          	jal	d8 <main>
  exit(0);
 244:	4501                	li	a0,0
 246:	25c000ef          	jal	4a2 <exit>

000000000000024a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 250:	87aa                	mv	a5,a0
 252:	0585                	addi	a1,a1,1
 254:	0785                	addi	a5,a5,1
 256:	fff5c703          	lbu	a4,-1(a1)
 25a:	fee78fa3          	sb	a4,-1(a5)
 25e:	fb75                	bnez	a4,252 <strcpy+0x8>
    ;
  return os;
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret

0000000000000266 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 266:	1141                	addi	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 26c:	00054783          	lbu	a5,0(a0)
 270:	cb91                	beqz	a5,284 <strcmp+0x1e>
 272:	0005c703          	lbu	a4,0(a1)
 276:	00f71763          	bne	a4,a5,284 <strcmp+0x1e>
    p++, q++;
 27a:	0505                	addi	a0,a0,1
 27c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 27e:	00054783          	lbu	a5,0(a0)
 282:	fbe5                	bnez	a5,272 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 284:	0005c503          	lbu	a0,0(a1)
}
 288:	40a7853b          	subw	a0,a5,a0
 28c:	6422                	ld	s0,8(sp)
 28e:	0141                	addi	sp,sp,16
 290:	8082                	ret

0000000000000292 <strlen>:

uint
strlen(const char *s)
{
 292:	1141                	addi	sp,sp,-16
 294:	e422                	sd	s0,8(sp)
 296:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 298:	00054783          	lbu	a5,0(a0)
 29c:	cf91                	beqz	a5,2b8 <strlen+0x26>
 29e:	0505                	addi	a0,a0,1
 2a0:	87aa                	mv	a5,a0
 2a2:	86be                	mv	a3,a5
 2a4:	0785                	addi	a5,a5,1
 2a6:	fff7c703          	lbu	a4,-1(a5)
 2aa:	ff65                	bnez	a4,2a2 <strlen+0x10>
 2ac:	40a6853b          	subw	a0,a3,a0
 2b0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2b2:	6422                	ld	s0,8(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret
  for(n = 0; s[n]; n++)
 2b8:	4501                	li	a0,0
 2ba:	bfe5                	j	2b2 <strlen+0x20>

00000000000002bc <memset>:

void*
memset(void *dst, int c, uint n)
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e422                	sd	s0,8(sp)
 2c0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2c2:	ca19                	beqz	a2,2d8 <memset+0x1c>
 2c4:	87aa                	mv	a5,a0
 2c6:	1602                	slli	a2,a2,0x20
 2c8:	9201                	srli	a2,a2,0x20
 2ca:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2ce:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2d2:	0785                	addi	a5,a5,1
 2d4:	fee79de3          	bne	a5,a4,2ce <memset+0x12>
  }
  return dst;
}
 2d8:	6422                	ld	s0,8(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret

00000000000002de <strchr>:

char*
strchr(const char *s, char c)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2e4:	00054783          	lbu	a5,0(a0)
 2e8:	cb99                	beqz	a5,2fe <strchr+0x20>
    if(*s == c)
 2ea:	00f58763          	beq	a1,a5,2f8 <strchr+0x1a>
  for(; *s; s++)
 2ee:	0505                	addi	a0,a0,1
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	fbfd                	bnez	a5,2ea <strchr+0xc>
      return (char*)s;
  return 0;
 2f6:	4501                	li	a0,0
}
 2f8:	6422                	ld	s0,8(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret
  return 0;
 2fe:	4501                	li	a0,0
 300:	bfe5                	j	2f8 <strchr+0x1a>

0000000000000302 <gets>:

char*
gets(char *buf, int max)
{
 302:	711d                	addi	sp,sp,-96
 304:	ec86                	sd	ra,88(sp)
 306:	e8a2                	sd	s0,80(sp)
 308:	e4a6                	sd	s1,72(sp)
 30a:	e0ca                	sd	s2,64(sp)
 30c:	fc4e                	sd	s3,56(sp)
 30e:	f852                	sd	s4,48(sp)
 310:	f456                	sd	s5,40(sp)
 312:	f05a                	sd	s6,32(sp)
 314:	ec5e                	sd	s7,24(sp)
 316:	1080                	addi	s0,sp,96
 318:	8baa                	mv	s7,a0
 31a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 31c:	892a                	mv	s2,a0
 31e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 320:	4aa9                	li	s5,10
 322:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 324:	89a6                	mv	s3,s1
 326:	2485                	addiw	s1,s1,1
 328:	0344d663          	bge	s1,s4,354 <gets+0x52>
    cc = read(0, &c, 1);
 32c:	4605                	li	a2,1
 32e:	faf40593          	addi	a1,s0,-81
 332:	4501                	li	a0,0
 334:	186000ef          	jal	4ba <read>
    if(cc < 1)
 338:	00a05e63          	blez	a0,354 <gets+0x52>
    buf[i++] = c;
 33c:	faf44783          	lbu	a5,-81(s0)
 340:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 344:	01578763          	beq	a5,s5,352 <gets+0x50>
 348:	0905                	addi	s2,s2,1
 34a:	fd679de3          	bne	a5,s6,324 <gets+0x22>
    buf[i++] = c;
 34e:	89a6                	mv	s3,s1
 350:	a011                	j	354 <gets+0x52>
 352:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 354:	99de                	add	s3,s3,s7
 356:	00098023          	sb	zero,0(s3)
  return buf;
}
 35a:	855e                	mv	a0,s7
 35c:	60e6                	ld	ra,88(sp)
 35e:	6446                	ld	s0,80(sp)
 360:	64a6                	ld	s1,72(sp)
 362:	6906                	ld	s2,64(sp)
 364:	79e2                	ld	s3,56(sp)
 366:	7a42                	ld	s4,48(sp)
 368:	7aa2                	ld	s5,40(sp)
 36a:	7b02                	ld	s6,32(sp)
 36c:	6be2                	ld	s7,24(sp)
 36e:	6125                	addi	sp,sp,96
 370:	8082                	ret

0000000000000372 <stat>:

int
stat(const char *n, struct stat *st)
{
 372:	1101                	addi	sp,sp,-32
 374:	ec06                	sd	ra,24(sp)
 376:	e822                	sd	s0,16(sp)
 378:	e04a                	sd	s2,0(sp)
 37a:	1000                	addi	s0,sp,32
 37c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 37e:	4581                	li	a1,0
 380:	162000ef          	jal	4e2 <open>
  if(fd < 0)
 384:	02054263          	bltz	a0,3a8 <stat+0x36>
 388:	e426                	sd	s1,8(sp)
 38a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 38c:	85ca                	mv	a1,s2
 38e:	16c000ef          	jal	4fa <fstat>
 392:	892a                	mv	s2,a0
  close(fd);
 394:	8526                	mv	a0,s1
 396:	134000ef          	jal	4ca <close>
  return r;
 39a:	64a2                	ld	s1,8(sp)
}
 39c:	854a                	mv	a0,s2
 39e:	60e2                	ld	ra,24(sp)
 3a0:	6442                	ld	s0,16(sp)
 3a2:	6902                	ld	s2,0(sp)
 3a4:	6105                	addi	sp,sp,32
 3a6:	8082                	ret
    return -1;
 3a8:	597d                	li	s2,-1
 3aa:	bfcd                	j	39c <stat+0x2a>

00000000000003ac <atoi>:

int
atoi(const char *s)
{
 3ac:	1141                	addi	sp,sp,-16
 3ae:	e422                	sd	s0,8(sp)
 3b0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b2:	00054683          	lbu	a3,0(a0)
 3b6:	fd06879b          	addiw	a5,a3,-48
 3ba:	0ff7f793          	zext.b	a5,a5
 3be:	4625                	li	a2,9
 3c0:	02f66863          	bltu	a2,a5,3f0 <atoi+0x44>
 3c4:	872a                	mv	a4,a0
  n = 0;
 3c6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3c8:	0705                	addi	a4,a4,1
 3ca:	0025179b          	slliw	a5,a0,0x2
 3ce:	9fa9                	addw	a5,a5,a0
 3d0:	0017979b          	slliw	a5,a5,0x1
 3d4:	9fb5                	addw	a5,a5,a3
 3d6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3da:	00074683          	lbu	a3,0(a4)
 3de:	fd06879b          	addiw	a5,a3,-48
 3e2:	0ff7f793          	zext.b	a5,a5
 3e6:	fef671e3          	bgeu	a2,a5,3c8 <atoi+0x1c>
  return n;
}
 3ea:	6422                	ld	s0,8(sp)
 3ec:	0141                	addi	sp,sp,16
 3ee:	8082                	ret
  n = 0;
 3f0:	4501                	li	a0,0
 3f2:	bfe5                	j	3ea <atoi+0x3e>

00000000000003f4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e422                	sd	s0,8(sp)
 3f8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3fa:	02b57463          	bgeu	a0,a1,422 <memmove+0x2e>
    while(n-- > 0)
 3fe:	00c05f63          	blez	a2,41c <memmove+0x28>
 402:	1602                	slli	a2,a2,0x20
 404:	9201                	srli	a2,a2,0x20
 406:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 40a:	872a                	mv	a4,a0
      *dst++ = *src++;
 40c:	0585                	addi	a1,a1,1
 40e:	0705                	addi	a4,a4,1
 410:	fff5c683          	lbu	a3,-1(a1)
 414:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 418:	fef71ae3          	bne	a4,a5,40c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 41c:	6422                	ld	s0,8(sp)
 41e:	0141                	addi	sp,sp,16
 420:	8082                	ret
    dst += n;
 422:	00c50733          	add	a4,a0,a2
    src += n;
 426:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 428:	fec05ae3          	blez	a2,41c <memmove+0x28>
 42c:	fff6079b          	addiw	a5,a2,-1
 430:	1782                	slli	a5,a5,0x20
 432:	9381                	srli	a5,a5,0x20
 434:	fff7c793          	not	a5,a5
 438:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 43a:	15fd                	addi	a1,a1,-1
 43c:	177d                	addi	a4,a4,-1
 43e:	0005c683          	lbu	a3,0(a1)
 442:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 446:	fee79ae3          	bne	a5,a4,43a <memmove+0x46>
 44a:	bfc9                	j	41c <memmove+0x28>

000000000000044c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 44c:	1141                	addi	sp,sp,-16
 44e:	e422                	sd	s0,8(sp)
 450:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 452:	ca05                	beqz	a2,482 <memcmp+0x36>
 454:	fff6069b          	addiw	a3,a2,-1
 458:	1682                	slli	a3,a3,0x20
 45a:	9281                	srli	a3,a3,0x20
 45c:	0685                	addi	a3,a3,1
 45e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 460:	00054783          	lbu	a5,0(a0)
 464:	0005c703          	lbu	a4,0(a1)
 468:	00e79863          	bne	a5,a4,478 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 46c:	0505                	addi	a0,a0,1
    p2++;
 46e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 470:	fed518e3          	bne	a0,a3,460 <memcmp+0x14>
  }
  return 0;
 474:	4501                	li	a0,0
 476:	a019                	j	47c <memcmp+0x30>
      return *p1 - *p2;
 478:	40e7853b          	subw	a0,a5,a4
}
 47c:	6422                	ld	s0,8(sp)
 47e:	0141                	addi	sp,sp,16
 480:	8082                	ret
  return 0;
 482:	4501                	li	a0,0
 484:	bfe5                	j	47c <memcmp+0x30>

0000000000000486 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 486:	1141                	addi	sp,sp,-16
 488:	e406                	sd	ra,8(sp)
 48a:	e022                	sd	s0,0(sp)
 48c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 48e:	f67ff0ef          	jal	3f4 <memmove>
}
 492:	60a2                	ld	ra,8(sp)
 494:	6402                	ld	s0,0(sp)
 496:	0141                	addi	sp,sp,16
 498:	8082                	ret

000000000000049a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 49a:	4885                	li	a7,1
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4a2:	4889                	li	a7,2
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <wait>:
.global wait
wait:
 li a7, SYS_wait
 4aa:	488d                	li	a7,3
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4b2:	4891                	li	a7,4
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <read>:
.global read
read:
 li a7, SYS_read
 4ba:	4895                	li	a7,5
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <write>:
.global write
write:
 li a7, SYS_write
 4c2:	48c1                	li	a7,16
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <close>:
.global close
close:
 li a7, SYS_close
 4ca:	48d5                	li	a7,21
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4d2:	4899                	li	a7,6
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <exec>:
.global exec
exec:
 li a7, SYS_exec
 4da:	489d                	li	a7,7
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <open>:
.global open
open:
 li a7, SYS_open
 4e2:	48bd                	li	a7,15
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ea:	48c5                	li	a7,17
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4f2:	48c9                	li	a7,18
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4fa:	48a1                	li	a7,8
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <link>:
.global link
link:
 li a7, SYS_link
 502:	48cd                	li	a7,19
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 50a:	48d1                	li	a7,20
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 512:	48a5                	li	a7,9
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <dup>:
.global dup
dup:
 li a7, SYS_dup
 51a:	48a9                	li	a7,10
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 522:	48ad                	li	a7,11
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 52a:	48b1                	li	a7,12
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 532:	48b5                	li	a7,13
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 53a:	48b9                	li	a7,14
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <set_sched>:
.global set_sched
set_sched:
 li a7, SYS_set_sched
 542:	48d9                	li	a7,22
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 54a:	48dd                	li	a7,23
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <top>:
.global top
top:
 li a7, SYS_top
 552:	48e1                	li	a7,24
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <fork_with_priority>:
.global fork_with_priority
fork_with_priority:
 li a7, SYS_fork_with_priority
 55a:	48e5                	li	a7,25
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <yield>:
.global yield
yield:
 li a7, SYS_yield
 562:	48e9                	li	a7,26
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <get_waiting_time>:
.global get_waiting_time
get_waiting_time:
  li a7, SYS_get_waiting_time
 56a:	48ed                	li	a7,27
  ecall
 56c:	00000073          	ecall
  ret
 570:	8082                	ret

0000000000000572 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 572:	1101                	addi	sp,sp,-32
 574:	ec06                	sd	ra,24(sp)
 576:	e822                	sd	s0,16(sp)
 578:	1000                	addi	s0,sp,32
 57a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 57e:	4605                	li	a2,1
 580:	fef40593          	addi	a1,s0,-17
 584:	f3fff0ef          	jal	4c2 <write>
}
 588:	60e2                	ld	ra,24(sp)
 58a:	6442                	ld	s0,16(sp)
 58c:	6105                	addi	sp,sp,32
 58e:	8082                	ret

0000000000000590 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 590:	7139                	addi	sp,sp,-64
 592:	fc06                	sd	ra,56(sp)
 594:	f822                	sd	s0,48(sp)
 596:	f426                	sd	s1,40(sp)
 598:	0080                	addi	s0,sp,64
 59a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 59c:	c299                	beqz	a3,5a2 <printint+0x12>
 59e:	0805c963          	bltz	a1,630 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5a2:	2581                	sext.w	a1,a1
  neg = 0;
 5a4:	4881                	li	a7,0
 5a6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5aa:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5ac:	2601                	sext.w	a2,a2
 5ae:	00000517          	auipc	a0,0x0
 5b2:	67a50513          	addi	a0,a0,1658 # c28 <digits>
 5b6:	883a                	mv	a6,a4
 5b8:	2705                	addiw	a4,a4,1
 5ba:	02c5f7bb          	remuw	a5,a1,a2
 5be:	1782                	slli	a5,a5,0x20
 5c0:	9381                	srli	a5,a5,0x20
 5c2:	97aa                	add	a5,a5,a0
 5c4:	0007c783          	lbu	a5,0(a5)
 5c8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5cc:	0005879b          	sext.w	a5,a1
 5d0:	02c5d5bb          	divuw	a1,a1,a2
 5d4:	0685                	addi	a3,a3,1
 5d6:	fec7f0e3          	bgeu	a5,a2,5b6 <printint+0x26>
  if(neg)
 5da:	00088c63          	beqz	a7,5f2 <printint+0x62>
    buf[i++] = '-';
 5de:	fd070793          	addi	a5,a4,-48
 5e2:	00878733          	add	a4,a5,s0
 5e6:	02d00793          	li	a5,45
 5ea:	fef70823          	sb	a5,-16(a4)
 5ee:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5f2:	02e05a63          	blez	a4,626 <printint+0x96>
 5f6:	f04a                	sd	s2,32(sp)
 5f8:	ec4e                	sd	s3,24(sp)
 5fa:	fc040793          	addi	a5,s0,-64
 5fe:	00e78933          	add	s2,a5,a4
 602:	fff78993          	addi	s3,a5,-1
 606:	99ba                	add	s3,s3,a4
 608:	377d                	addiw	a4,a4,-1
 60a:	1702                	slli	a4,a4,0x20
 60c:	9301                	srli	a4,a4,0x20
 60e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 612:	fff94583          	lbu	a1,-1(s2)
 616:	8526                	mv	a0,s1
 618:	f5bff0ef          	jal	572 <putc>
  while(--i >= 0)
 61c:	197d                	addi	s2,s2,-1
 61e:	ff391ae3          	bne	s2,s3,612 <printint+0x82>
 622:	7902                	ld	s2,32(sp)
 624:	69e2                	ld	s3,24(sp)
}
 626:	70e2                	ld	ra,56(sp)
 628:	7442                	ld	s0,48(sp)
 62a:	74a2                	ld	s1,40(sp)
 62c:	6121                	addi	sp,sp,64
 62e:	8082                	ret
    x = -xx;
 630:	40b005bb          	negw	a1,a1
    neg = 1;
 634:	4885                	li	a7,1
    x = -xx;
 636:	bf85                	j	5a6 <printint+0x16>

0000000000000638 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 638:	711d                	addi	sp,sp,-96
 63a:	ec86                	sd	ra,88(sp)
 63c:	e8a2                	sd	s0,80(sp)
 63e:	e0ca                	sd	s2,64(sp)
 640:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 642:	0005c903          	lbu	s2,0(a1)
 646:	26090863          	beqz	s2,8b6 <vprintf+0x27e>
 64a:	e4a6                	sd	s1,72(sp)
 64c:	fc4e                	sd	s3,56(sp)
 64e:	f852                	sd	s4,48(sp)
 650:	f456                	sd	s5,40(sp)
 652:	f05a                	sd	s6,32(sp)
 654:	ec5e                	sd	s7,24(sp)
 656:	e862                	sd	s8,16(sp)
 658:	e466                	sd	s9,8(sp)
 65a:	8b2a                	mv	s6,a0
 65c:	8a2e                	mv	s4,a1
 65e:	8bb2                	mv	s7,a2
  state = 0;
 660:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 662:	4481                	li	s1,0
 664:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 666:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 66a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 66e:	06c00c93          	li	s9,108
 672:	a005                	j	692 <vprintf+0x5a>
        putc(fd, c0);
 674:	85ca                	mv	a1,s2
 676:	855a                	mv	a0,s6
 678:	efbff0ef          	jal	572 <putc>
 67c:	a019                	j	682 <vprintf+0x4a>
    } else if(state == '%'){
 67e:	03598263          	beq	s3,s5,6a2 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 682:	2485                	addiw	s1,s1,1
 684:	8726                	mv	a4,s1
 686:	009a07b3          	add	a5,s4,s1
 68a:	0007c903          	lbu	s2,0(a5)
 68e:	20090c63          	beqz	s2,8a6 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 692:	0009079b          	sext.w	a5,s2
    if(state == 0){
 696:	fe0994e3          	bnez	s3,67e <vprintf+0x46>
      if(c0 == '%'){
 69a:	fd579de3          	bne	a5,s5,674 <vprintf+0x3c>
        state = '%';
 69e:	89be                	mv	s3,a5
 6a0:	b7cd                	j	682 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6a2:	00ea06b3          	add	a3,s4,a4
 6a6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6aa:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6ac:	c681                	beqz	a3,6b4 <vprintf+0x7c>
 6ae:	9752                	add	a4,a4,s4
 6b0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6b4:	03878f63          	beq	a5,s8,6f2 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 6b8:	05978963          	beq	a5,s9,70a <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6bc:	07500713          	li	a4,117
 6c0:	0ee78363          	beq	a5,a4,7a6 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6c4:	07800713          	li	a4,120
 6c8:	12e78563          	beq	a5,a4,7f2 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6cc:	07000713          	li	a4,112
 6d0:	14e78a63          	beq	a5,a4,824 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 6d4:	07300713          	li	a4,115
 6d8:	18e78a63          	beq	a5,a4,86c <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6dc:	02500713          	li	a4,37
 6e0:	04e79563          	bne	a5,a4,72a <vprintf+0xf2>
        putc(fd, '%');
 6e4:	02500593          	li	a1,37
 6e8:	855a                	mv	a0,s6
 6ea:	e89ff0ef          	jal	572 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bf49                	j	682 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6f2:	008b8913          	addi	s2,s7,8
 6f6:	4685                	li	a3,1
 6f8:	4629                	li	a2,10
 6fa:	000ba583          	lw	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	e91ff0ef          	jal	590 <printint>
 704:	8bca                	mv	s7,s2
      state = 0;
 706:	4981                	li	s3,0
 708:	bfad                	j	682 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 70a:	06400793          	li	a5,100
 70e:	02f68963          	beq	a3,a5,740 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 712:	06c00793          	li	a5,108
 716:	04f68263          	beq	a3,a5,75a <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 71a:	07500793          	li	a5,117
 71e:	0af68063          	beq	a3,a5,7be <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 722:	07800793          	li	a5,120
 726:	0ef68263          	beq	a3,a5,80a <vprintf+0x1d2>
        putc(fd, '%');
 72a:	02500593          	li	a1,37
 72e:	855a                	mv	a0,s6
 730:	e43ff0ef          	jal	572 <putc>
        putc(fd, c0);
 734:	85ca                	mv	a1,s2
 736:	855a                	mv	a0,s6
 738:	e3bff0ef          	jal	572 <putc>
      state = 0;
 73c:	4981                	li	s3,0
 73e:	b791                	j	682 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 740:	008b8913          	addi	s2,s7,8
 744:	4685                	li	a3,1
 746:	4629                	li	a2,10
 748:	000ba583          	lw	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	e43ff0ef          	jal	590 <printint>
        i += 1;
 752:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 754:	8bca                	mv	s7,s2
      state = 0;
 756:	4981                	li	s3,0
        i += 1;
 758:	b72d                	j	682 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 75a:	06400793          	li	a5,100
 75e:	02f60763          	beq	a2,a5,78c <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 762:	07500793          	li	a5,117
 766:	06f60963          	beq	a2,a5,7d8 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 76a:	07800793          	li	a5,120
 76e:	faf61ee3          	bne	a2,a5,72a <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 772:	008b8913          	addi	s2,s7,8
 776:	4681                	li	a3,0
 778:	4641                	li	a2,16
 77a:	000ba583          	lw	a1,0(s7)
 77e:	855a                	mv	a0,s6
 780:	e11ff0ef          	jal	590 <printint>
        i += 2;
 784:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 786:	8bca                	mv	s7,s2
      state = 0;
 788:	4981                	li	s3,0
        i += 2;
 78a:	bde5                	j	682 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 78c:	008b8913          	addi	s2,s7,8
 790:	4685                	li	a3,1
 792:	4629                	li	a2,10
 794:	000ba583          	lw	a1,0(s7)
 798:	855a                	mv	a0,s6
 79a:	df7ff0ef          	jal	590 <printint>
        i += 2;
 79e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7a0:	8bca                	mv	s7,s2
      state = 0;
 7a2:	4981                	li	s3,0
        i += 2;
 7a4:	bdf9                	j	682 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 7a6:	008b8913          	addi	s2,s7,8
 7aa:	4681                	li	a3,0
 7ac:	4629                	li	a2,10
 7ae:	000ba583          	lw	a1,0(s7)
 7b2:	855a                	mv	a0,s6
 7b4:	dddff0ef          	jal	590 <printint>
 7b8:	8bca                	mv	s7,s2
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	b5d9                	j	682 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7be:	008b8913          	addi	s2,s7,8
 7c2:	4681                	li	a3,0
 7c4:	4629                	li	a2,10
 7c6:	000ba583          	lw	a1,0(s7)
 7ca:	855a                	mv	a0,s6
 7cc:	dc5ff0ef          	jal	590 <printint>
        i += 1;
 7d0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d2:	8bca                	mv	s7,s2
      state = 0;
 7d4:	4981                	li	s3,0
        i += 1;
 7d6:	b575                	j	682 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d8:	008b8913          	addi	s2,s7,8
 7dc:	4681                	li	a3,0
 7de:	4629                	li	a2,10
 7e0:	000ba583          	lw	a1,0(s7)
 7e4:	855a                	mv	a0,s6
 7e6:	dabff0ef          	jal	590 <printint>
        i += 2;
 7ea:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ec:	8bca                	mv	s7,s2
      state = 0;
 7ee:	4981                	li	s3,0
        i += 2;
 7f0:	bd49                	j	682 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 7f2:	008b8913          	addi	s2,s7,8
 7f6:	4681                	li	a3,0
 7f8:	4641                	li	a2,16
 7fa:	000ba583          	lw	a1,0(s7)
 7fe:	855a                	mv	a0,s6
 800:	d91ff0ef          	jal	590 <printint>
 804:	8bca                	mv	s7,s2
      state = 0;
 806:	4981                	li	s3,0
 808:	bdad                	j	682 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 80a:	008b8913          	addi	s2,s7,8
 80e:	4681                	li	a3,0
 810:	4641                	li	a2,16
 812:	000ba583          	lw	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	d79ff0ef          	jal	590 <printint>
        i += 1;
 81c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 81e:	8bca                	mv	s7,s2
      state = 0;
 820:	4981                	li	s3,0
        i += 1;
 822:	b585                	j	682 <vprintf+0x4a>
 824:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 826:	008b8d13          	addi	s10,s7,8
 82a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 82e:	03000593          	li	a1,48
 832:	855a                	mv	a0,s6
 834:	d3fff0ef          	jal	572 <putc>
  putc(fd, 'x');
 838:	07800593          	li	a1,120
 83c:	855a                	mv	a0,s6
 83e:	d35ff0ef          	jal	572 <putc>
 842:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 844:	00000b97          	auipc	s7,0x0
 848:	3e4b8b93          	addi	s7,s7,996 # c28 <digits>
 84c:	03c9d793          	srli	a5,s3,0x3c
 850:	97de                	add	a5,a5,s7
 852:	0007c583          	lbu	a1,0(a5)
 856:	855a                	mv	a0,s6
 858:	d1bff0ef          	jal	572 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 85c:	0992                	slli	s3,s3,0x4
 85e:	397d                	addiw	s2,s2,-1
 860:	fe0916e3          	bnez	s2,84c <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 864:	8bea                	mv	s7,s10
      state = 0;
 866:	4981                	li	s3,0
 868:	6d02                	ld	s10,0(sp)
 86a:	bd21                	j	682 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 86c:	008b8993          	addi	s3,s7,8
 870:	000bb903          	ld	s2,0(s7)
 874:	00090f63          	beqz	s2,892 <vprintf+0x25a>
        for(; *s; s++)
 878:	00094583          	lbu	a1,0(s2)
 87c:	c195                	beqz	a1,8a0 <vprintf+0x268>
          putc(fd, *s);
 87e:	855a                	mv	a0,s6
 880:	cf3ff0ef          	jal	572 <putc>
        for(; *s; s++)
 884:	0905                	addi	s2,s2,1
 886:	00094583          	lbu	a1,0(s2)
 88a:	f9f5                	bnez	a1,87e <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 88c:	8bce                	mv	s7,s3
      state = 0;
 88e:	4981                	li	s3,0
 890:	bbcd                	j	682 <vprintf+0x4a>
          s = "(null)";
 892:	00000917          	auipc	s2,0x0
 896:	38e90913          	addi	s2,s2,910 # c20 <malloc+0x282>
        for(; *s; s++)
 89a:	02800593          	li	a1,40
 89e:	b7c5                	j	87e <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 8a0:	8bce                	mv	s7,s3
      state = 0;
 8a2:	4981                	li	s3,0
 8a4:	bbf9                	j	682 <vprintf+0x4a>
 8a6:	64a6                	ld	s1,72(sp)
 8a8:	79e2                	ld	s3,56(sp)
 8aa:	7a42                	ld	s4,48(sp)
 8ac:	7aa2                	ld	s5,40(sp)
 8ae:	7b02                	ld	s6,32(sp)
 8b0:	6be2                	ld	s7,24(sp)
 8b2:	6c42                	ld	s8,16(sp)
 8b4:	6ca2                	ld	s9,8(sp)
    }
  }
}
 8b6:	60e6                	ld	ra,88(sp)
 8b8:	6446                	ld	s0,80(sp)
 8ba:	6906                	ld	s2,64(sp)
 8bc:	6125                	addi	sp,sp,96
 8be:	8082                	ret

00000000000008c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8c0:	715d                	addi	sp,sp,-80
 8c2:	ec06                	sd	ra,24(sp)
 8c4:	e822                	sd	s0,16(sp)
 8c6:	1000                	addi	s0,sp,32
 8c8:	e010                	sd	a2,0(s0)
 8ca:	e414                	sd	a3,8(s0)
 8cc:	e818                	sd	a4,16(s0)
 8ce:	ec1c                	sd	a5,24(s0)
 8d0:	03043023          	sd	a6,32(s0)
 8d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8d8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8dc:	8622                	mv	a2,s0
 8de:	d5bff0ef          	jal	638 <vprintf>
}
 8e2:	60e2                	ld	ra,24(sp)
 8e4:	6442                	ld	s0,16(sp)
 8e6:	6161                	addi	sp,sp,80
 8e8:	8082                	ret

00000000000008ea <printf>:

void
printf(const char *fmt, ...)
{
 8ea:	711d                	addi	sp,sp,-96
 8ec:	ec06                	sd	ra,24(sp)
 8ee:	e822                	sd	s0,16(sp)
 8f0:	1000                	addi	s0,sp,32
 8f2:	e40c                	sd	a1,8(s0)
 8f4:	e810                	sd	a2,16(s0)
 8f6:	ec14                	sd	a3,24(s0)
 8f8:	f018                	sd	a4,32(s0)
 8fa:	f41c                	sd	a5,40(s0)
 8fc:	03043823          	sd	a6,48(s0)
 900:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 904:	00840613          	addi	a2,s0,8
 908:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 90c:	85aa                	mv	a1,a0
 90e:	4505                	li	a0,1
 910:	d29ff0ef          	jal	638 <vprintf>
}
 914:	60e2                	ld	ra,24(sp)
 916:	6442                	ld	s0,16(sp)
 918:	6125                	addi	sp,sp,96
 91a:	8082                	ret

000000000000091c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 91c:	1141                	addi	sp,sp,-16
 91e:	e422                	sd	s0,8(sp)
 920:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 922:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 926:	00000797          	auipc	a5,0x0
 92a:	6e27b783          	ld	a5,1762(a5) # 1008 <freep>
 92e:	a02d                	j	958 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 930:	4618                	lw	a4,8(a2)
 932:	9f2d                	addw	a4,a4,a1
 934:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 938:	6398                	ld	a4,0(a5)
 93a:	6310                	ld	a2,0(a4)
 93c:	a83d                	j	97a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 93e:	ff852703          	lw	a4,-8(a0)
 942:	9f31                	addw	a4,a4,a2
 944:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 946:	ff053683          	ld	a3,-16(a0)
 94a:	a091                	j	98e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 94c:	6398                	ld	a4,0(a5)
 94e:	00e7e463          	bltu	a5,a4,956 <free+0x3a>
 952:	00e6ea63          	bltu	a3,a4,966 <free+0x4a>
{
 956:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 958:	fed7fae3          	bgeu	a5,a3,94c <free+0x30>
 95c:	6398                	ld	a4,0(a5)
 95e:	00e6e463          	bltu	a3,a4,966 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 962:	fee7eae3          	bltu	a5,a4,956 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 966:	ff852583          	lw	a1,-8(a0)
 96a:	6390                	ld	a2,0(a5)
 96c:	02059813          	slli	a6,a1,0x20
 970:	01c85713          	srli	a4,a6,0x1c
 974:	9736                	add	a4,a4,a3
 976:	fae60de3          	beq	a2,a4,930 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 97a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 97e:	4790                	lw	a2,8(a5)
 980:	02061593          	slli	a1,a2,0x20
 984:	01c5d713          	srli	a4,a1,0x1c
 988:	973e                	add	a4,a4,a5
 98a:	fae68ae3          	beq	a3,a4,93e <free+0x22>
    p->s.ptr = bp->s.ptr;
 98e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 990:	00000717          	auipc	a4,0x0
 994:	66f73c23          	sd	a5,1656(a4) # 1008 <freep>
}
 998:	6422                	ld	s0,8(sp)
 99a:	0141                	addi	sp,sp,16
 99c:	8082                	ret

000000000000099e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 99e:	7139                	addi	sp,sp,-64
 9a0:	fc06                	sd	ra,56(sp)
 9a2:	f822                	sd	s0,48(sp)
 9a4:	f426                	sd	s1,40(sp)
 9a6:	ec4e                	sd	s3,24(sp)
 9a8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9aa:	02051493          	slli	s1,a0,0x20
 9ae:	9081                	srli	s1,s1,0x20
 9b0:	04bd                	addi	s1,s1,15
 9b2:	8091                	srli	s1,s1,0x4
 9b4:	0014899b          	addiw	s3,s1,1
 9b8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9ba:	00000517          	auipc	a0,0x0
 9be:	64e53503          	ld	a0,1614(a0) # 1008 <freep>
 9c2:	c915                	beqz	a0,9f6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c6:	4798                	lw	a4,8(a5)
 9c8:	08977a63          	bgeu	a4,s1,a5c <malloc+0xbe>
 9cc:	f04a                	sd	s2,32(sp)
 9ce:	e852                	sd	s4,16(sp)
 9d0:	e456                	sd	s5,8(sp)
 9d2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9d4:	8a4e                	mv	s4,s3
 9d6:	0009871b          	sext.w	a4,s3
 9da:	6685                	lui	a3,0x1
 9dc:	00d77363          	bgeu	a4,a3,9e2 <malloc+0x44>
 9e0:	6a05                	lui	s4,0x1
 9e2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9e6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9ea:	00000917          	auipc	s2,0x0
 9ee:	61e90913          	addi	s2,s2,1566 # 1008 <freep>
  if(p == (char*)-1)
 9f2:	5afd                	li	s5,-1
 9f4:	a081                	j	a34 <malloc+0x96>
 9f6:	f04a                	sd	s2,32(sp)
 9f8:	e852                	sd	s4,16(sp)
 9fa:	e456                	sd	s5,8(sp)
 9fc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9fe:	00000797          	auipc	a5,0x0
 a02:	61278793          	addi	a5,a5,1554 # 1010 <base>
 a06:	00000717          	auipc	a4,0x0
 a0a:	60f73123          	sd	a5,1538(a4) # 1008 <freep>
 a0e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a10:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a14:	b7c1                	j	9d4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a16:	6398                	ld	a4,0(a5)
 a18:	e118                	sd	a4,0(a0)
 a1a:	a8a9                	j	a74 <malloc+0xd6>
  hp->s.size = nu;
 a1c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a20:	0541                	addi	a0,a0,16
 a22:	efbff0ef          	jal	91c <free>
  return freep;
 a26:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a2a:	c12d                	beqz	a0,a8c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a2e:	4798                	lw	a4,8(a5)
 a30:	02977263          	bgeu	a4,s1,a54 <malloc+0xb6>
    if(p == freep)
 a34:	00093703          	ld	a4,0(s2)
 a38:	853e                	mv	a0,a5
 a3a:	fef719e3          	bne	a4,a5,a2c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a3e:	8552                	mv	a0,s4
 a40:	aebff0ef          	jal	52a <sbrk>
  if(p == (char*)-1)
 a44:	fd551ce3          	bne	a0,s5,a1c <malloc+0x7e>
        return 0;
 a48:	4501                	li	a0,0
 a4a:	7902                	ld	s2,32(sp)
 a4c:	6a42                	ld	s4,16(sp)
 a4e:	6aa2                	ld	s5,8(sp)
 a50:	6b02                	ld	s6,0(sp)
 a52:	a03d                	j	a80 <malloc+0xe2>
 a54:	7902                	ld	s2,32(sp)
 a56:	6a42                	ld	s4,16(sp)
 a58:	6aa2                	ld	s5,8(sp)
 a5a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a5c:	fae48de3          	beq	s1,a4,a16 <malloc+0x78>
        p->s.size -= nunits;
 a60:	4137073b          	subw	a4,a4,s3
 a64:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a66:	02071693          	slli	a3,a4,0x20
 a6a:	01c6d713          	srli	a4,a3,0x1c
 a6e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a70:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a74:	00000717          	auipc	a4,0x0
 a78:	58a73a23          	sd	a0,1428(a4) # 1008 <freep>
      return (void*)(p + 1);
 a7c:	01078513          	addi	a0,a5,16
  }
}
 a80:	70e2                	ld	ra,56(sp)
 a82:	7442                	ld	s0,48(sp)
 a84:	74a2                	ld	s1,40(sp)
 a86:	69e2                	ld	s3,24(sp)
 a88:	6121                	addi	sp,sp,64
 a8a:	8082                	ret
 a8c:	7902                	ld	s2,32(sp)
 a8e:	6a42                	ld	s4,16(sp)
 a90:	6aa2                	ld	s5,8(sp)
 a92:	6b02                	ld	s6,0(sp)
 a94:	b7f5                	j	a80 <malloc+0xe2>
