
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <acquire_lock>:

extern void yield(void);  // 内核导出函数

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

void simulate_workload(int loops) {
  3c:	1101                	addi	sp,sp,-32
  3e:	ec22                	sd	s0,24(sp)
  40:	1000                	addi	s0,sp,32
  volatile int x = 0;
  42:	fe042623          	sw	zero,-20(s0)
  for (volatile int i = 0; i < loops; i++) {
  46:	fe042423          	sw	zero,-24(s0)
  4a:	fe842783          	lw	a5,-24(s0)
  4e:	872a                	mv	a4,a0
  50:	02a7d163          	bge	a5,a0,72 <simulate_workload+0x36>
    x++;
  54:	fec42783          	lw	a5,-20(s0)
  58:	2785                	addiw	a5,a5,1
  5a:	fef42623          	sw	a5,-20(s0)
  for (volatile int i = 0; i < loops; i++) {
  5e:	fe842783          	lw	a5,-24(s0)
  62:	2785                	addiw	a5,a5,1
  64:	fef42423          	sw	a5,-24(s0)
  68:	fe842783          	lw	a5,-24(s0)
  6c:	2781                	sext.w	a5,a5
  6e:	fee7c3e3          	blt	a5,a4,54 <simulate_workload+0x18>
  }
}
  72:	6462                	ld	s0,24(sp)
  74:	6105                	addi	sp,sp,32
  76:	8082                	ret

0000000000000078 <main>:
  int waiting_time;
};

struct proc_info infos[NPROCS];

int main() {
  78:	711d                	addi	sp,sp,-96
  7a:	ec86                	sd	ra,88(sp)
  7c:	e8a2                	sd	s0,80(sp)
  7e:	e4a6                	sd	s1,72(sp)
  80:	e0ca                	sd	s2,64(sp)
  82:	fc4e                	sd	s3,56(sp)
  84:	f852                	sd	s4,48(sp)
  86:	f456                	sd	s5,40(sp)
  88:	ec5e                	sd	s7,24(sp)
  8a:	1080                	addi	s0,sp,96
  printf("Starting massive scheduling test with %d processes\n", NPROCS);
  8c:	5dc00593          	li	a1,1500
  90:	00001517          	auipc	a0,0x1
  94:	a7050513          	addi	a0,a0,-1424 # b00 <malloc+0x116>
  98:	09f000ef          	jal	936 <printf>

  set_sched(4);  // 设置调度策略，例如 0=RR，1=FCFS，2=Priority，3=HRRN，4=MLFQ
  9c:	4511                	li	a0,4
  9e:	4f0000ef          	jal	58e <set_sched>

  int start_time = uptime();
  a2:	4e4000ef          	jal	586 <uptime>
  a6:	8baa                	mv	s7,a0

  for (int i = 0; i < NPROCS; i++) {
  a8:	00001a17          	auipc	s4,0x1
  ac:	f68a0a13          	addi	s4,s4,-152 # 1010 <infos>
  int start_time = uptime();
  b0:	8952                	mv	s2,s4
  for (int i = 0; i < NPROCS; i++) {
  b2:	4481                	li	s1,0
      exit(waiting);  // 将 waiting time 返回给父进程
    } else if (pid > 0) {
      infos[i].pid = pid;
      infos[i].start_tick = uptime();
    } else {
      printf("Fork failed at i=%d!\n", i);
  b4:	00001a97          	auipc	s5,0x1
  b8:	a84a8a93          	addi	s5,s5,-1404 # b38 <malloc+0x14e>
  for (int i = 0; i < NPROCS; i++) {
  bc:	5dc00993          	li	s3,1500
  c0:	a049                	j	142 <main+0xca>
  c2:	f05a                	sd	s6,32(sp)
      int mypid = getpid();
  c4:	4aa000ef          	jal	56e <getpid>
  c8:	892a                	mv	s2,a0
      if (i % 4 == 0) {
  ca:	0034f793          	andi	a5,s1,3
  ce:	c78d                	beqz	a5,f8 <main+0x80>
      } else if (i % 4 == 1) {
  d0:	4791                	li	a5,4
  d2:	02f4e4bb          	remw	s1,s1,a5
  d6:	4785                	li	a5,1
  d8:	02f48763          	beq	s1,a5,106 <main+0x8e>
      } else if (i % 4 == 2) {
  dc:	4789                	li	a5,2
  de:	02f48b63          	beq	s1,a5,114 <main+0x9c>
        simulate_workload(10000000); // medium task
  e2:	00989537          	lui	a0,0x989
  e6:	68050513          	addi	a0,a0,1664 # 989680 <base+0x981140>
  ea:	f53ff0ef          	jal	3c <simulate_workload>
      int waiting = get_waiting_time(mypid);
  ee:	854a                	mv	a0,s2
  f0:	4c6000ef          	jal	5b6 <get_waiting_time>
      exit(waiting);  // 将 waiting time 返回给父进程
  f4:	3fa000ef          	jal	4ee <exit>
        simulate_workload(50000000); // long task
  f8:	02faf537          	lui	a0,0x2faf
  fc:	08050513          	addi	a0,a0,128 # 2faf080 <base+0x2fa6b40>
 100:	f3dff0ef          	jal	3c <simulate_workload>
 104:	b7ed                	j	ee <main+0x76>
        simulate_workload(5000000); // short task
 106:	004c5537          	lui	a0,0x4c5
 10a:	b4050513          	addi	a0,a0,-1216 # 4c4b40 <base+0x4bc600>
 10e:	f2fff0ef          	jal	3c <simulate_workload>
 112:	bff1                	j	ee <main+0x76>
        simulate_workload(2000000);
 114:	001e8537          	lui	a0,0x1e8
 118:	48050513          	addi	a0,a0,1152 # 1e8480 <base+0x1dff40>
 11c:	f21ff0ef          	jal	3c <simulate_workload>
        yield();
 120:	48e000ef          	jal	5ae <yield>
        simulate_workload(3000000);
 124:	002dc537          	lui	a0,0x2dc
 128:	6c050513          	addi	a0,a0,1728 # 2dc6c0 <base+0x2d4180>
 12c:	f11ff0ef          	jal	3c <simulate_workload>
 130:	bf7d                	j	ee <main+0x76>
      printf("Fork failed at i=%d!\n", i);
 132:	85a6                	mv	a1,s1
 134:	8556                	mv	a0,s5
 136:	001000ef          	jal	936 <printf>
  for (int i = 0; i < NPROCS; i++) {
 13a:	2485                	addiw	s1,s1,1
 13c:	0951                	addi	s2,s2,20
 13e:	01348e63          	beq	s1,s3,15a <main+0xe2>
    int pid = fork();
 142:	3a4000ef          	jal	4e6 <fork>
    if (pid == 0) {
 146:	dd35                	beqz	a0,c2 <main+0x4a>
    } else if (pid > 0) {
 148:	fea055e3          	blez	a0,132 <main+0xba>
      infos[i].pid = pid;
 14c:	00a92023          	sw	a0,0(s2)
      infos[i].start_tick = uptime();
 150:	436000ef          	jal	586 <uptime>
 154:	00a92223          	sw	a0,4(s2)
 158:	b7cd                	j	13a <main+0xc2>
 15a:	f05a                	sd	s6,32(sp)
 15c:	5dc00993          	li	s3,1500
  for (int i = 0; i < NPROCS; i++) {
    int status;
    int pid = wait(&status);  // status 就是子进程返回的 waiting time
    int finish = uptime();

    for (int j = 0; j < NPROCS; j++) {
 160:	4b01                	li	s6,0
 162:	5dc00913          	li	s2,1500
      if (infos[j].pid == pid) {
        infos[j].finish_tick = finish;
 166:	00001a97          	auipc	s5,0x1
 16a:	eaaa8a93          	addi	s5,s5,-342 # 1010 <infos>
 16e:	a00d                	j	190 <main+0x118>
 170:	00279713          	slli	a4,a5,0x2
 174:	00f706b3          	add	a3,a4,a5
 178:	068a                	slli	a3,a3,0x2
 17a:	96d6                	add	a3,a3,s5
 17c:	c688                	sw	a0,8(a3)
        infos[j].runtime_ticks = finish - infos[j].start_tick;
 17e:	42d0                	lw	a2,4(a3)
 180:	9d11                	subw	a0,a0,a2
 182:	c6c8                	sw	a0,12(a3)
        infos[j].waiting_time = status;
 184:	fac42703          	lw	a4,-84(s0)
 188:	ca98                	sw	a4,16(a3)
  for (int i = 0; i < NPROCS; i++) {
 18a:	39fd                	addiw	s3,s3,-1
 18c:	02098363          	beqz	s3,1b2 <main+0x13a>
    int pid = wait(&status);  // status 就是子进程返回的 waiting time
 190:	fac40513          	addi	a0,s0,-84
 194:	362000ef          	jal	4f6 <wait>
 198:	84aa                	mv	s1,a0
    int finish = uptime();
 19a:	3ec000ef          	jal	586 <uptime>
 19e:	8752                	mv	a4,s4
    for (int j = 0; j < NPROCS; j++) {
 1a0:	87da                	mv	a5,s6
      if (infos[j].pid == pid) {
 1a2:	4314                	lw	a3,0(a4)
 1a4:	fc9686e3          	beq	a3,s1,170 <main+0xf8>
    for (int j = 0; j < NPROCS; j++) {
 1a8:	2785                	addiw	a5,a5,1
 1aa:	0751                	addi	a4,a4,20
 1ac:	ff279be3          	bne	a5,s2,1a2 <main+0x12a>
 1b0:	bfe9                	j	18a <main+0x112>
 1b2:	00001797          	auipc	a5,0x1
 1b6:	e6278793          	addi	a5,a5,-414 # 1014 <infos+0x4>
 1ba:	671d                	lui	a4,0x7
 1bc:	53470713          	addi	a4,a4,1332 # 7534 <infos+0x6524>
 1c0:	9a3a                	add	s4,s4,a4
  int total_waiting = 0;
 1c2:	4681                	li	a3,0
  int total_turnaround = 0;
 1c4:	4701                	li	a4,0
      }
    }
  }

  for (int i = 0; i < NPROCS; i++) {
    int turnaround = infos[i].finish_tick - infos[i].start_tick;
 1c6:	43c4                	lw	s1,4(a5)
 1c8:	4390                	lw	a2,0(a5)
 1ca:	9c91                	subw	s1,s1,a2
    total_turnaround += turnaround;
 1cc:	9cb9                	addw	s1,s1,a4
 1ce:	0004871b          	sext.w	a4,s1
    total_waiting += infos[i].waiting_time;
 1d2:	00c7a903          	lw	s2,12(a5)
 1d6:	00d9093b          	addw	s2,s2,a3
 1da:	0009069b          	sext.w	a3,s2
  for (int i = 0; i < NPROCS; i++) {
 1de:	07d1                	addi	a5,a5,20
 1e0:	ff4793e3          	bne	a5,s4,1c6 <main+0x14e>
  }

  int end_time = uptime();
 1e4:	3a2000ef          	jal	586 <uptime>
 1e8:	89aa                	mv	s3,a0

  printf("\n======== Test Summary ========\n");
 1ea:	00001517          	auipc	a0,0x1
 1ee:	96650513          	addi	a0,a0,-1690 # b50 <malloc+0x166>
 1f2:	744000ef          	jal	936 <printf>
  printf("Total Processes: %d\n", NPROCS);
 1f6:	5dc00593          	li	a1,1500
 1fa:	00001517          	auipc	a0,0x1
 1fe:	97e50513          	addi	a0,a0,-1666 # b78 <malloc+0x18e>
 202:	734000ef          	jal	936 <printf>
  printf("Total Time: %d ticks\n", end_time - start_time);
 206:	417989bb          	subw	s3,s3,s7
 20a:	0009859b          	sext.w	a1,s3
 20e:	00001517          	auipc	a0,0x1
 212:	98250513          	addi	a0,a0,-1662 # b90 <malloc+0x1a6>
 216:	720000ef          	jal	936 <printf>
  printf("Average Turnaround Time: %d ticks\n", total_turnaround / NPROCS);
 21a:	5dc00a13          	li	s4,1500
 21e:	0344c5bb          	divw	a1,s1,s4
 222:	00001517          	auipc	a0,0x1
 226:	98650513          	addi	a0,a0,-1658 # ba8 <malloc+0x1be>
 22a:	70c000ef          	jal	936 <printf>
  printf("Average Waiting Time: %d ticks\n", total_waiting / NPROCS);
 22e:	034945bb          	divw	a1,s2,s4
 232:	00001517          	auipc	a0,0x1
 236:	99e50513          	addi	a0,a0,-1634 # bd0 <malloc+0x1e6>
 23a:	6fc000ef          	jal	936 <printf>

  float seconds = (end_time - start_time) * 0.01;  // 1 tick = 10ms
 23e:	d20987d3          	fcvt.d.w	fa5,s3
 242:	00001797          	auipc	a5,0x1
 246:	8ae7b707          	fld	fa4,-1874(a5) # af0 <malloc+0x106>
 24a:	12e7f7d3          	fmul.d	fa5,fa5,fa4
 24e:	4017f7d3          	fcvt.s.d	fa5,fa5
  float throughput = NPROCS / seconds;
 252:	00001797          	auipc	a5,0x1
 256:	8a67a707          	flw	fa4,-1882(a5) # af8 <malloc+0x10e>
 25a:	18f777d3          	fdiv.s	fa5,fa4,fa5
  printf("Throughput: %.2f processes per second\n", throughput);
 25e:	420787d3          	fcvt.d.s	fa5,fa5
 262:	e20785d3          	fmv.x.d	a1,fa5
 266:	00001517          	auipc	a0,0x1
 26a:	98a50513          	addi	a0,a0,-1654 # bf0 <malloc+0x206>
 26e:	6c8000ef          	jal	936 <printf>
  printf("===============================\n");
 272:	00001517          	auipc	a0,0x1
 276:	9a650513          	addi	a0,a0,-1626 # c18 <malloc+0x22e>
 27a:	6bc000ef          	jal	936 <printf>

  exit(0);
 27e:	4501                	li	a0,0
 280:	26e000ef          	jal	4ee <exit>

0000000000000284 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 284:	1141                	addi	sp,sp,-16
 286:	e406                	sd	ra,8(sp)
 288:	e022                	sd	s0,0(sp)
 28a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 28c:	dedff0ef          	jal	78 <main>
  exit(0);
 290:	4501                	li	a0,0
 292:	25c000ef          	jal	4ee <exit>

0000000000000296 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 296:	1141                	addi	sp,sp,-16
 298:	e422                	sd	s0,8(sp)
 29a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 29c:	87aa                	mv	a5,a0
 29e:	0585                	addi	a1,a1,1
 2a0:	0785                	addi	a5,a5,1
 2a2:	fff5c703          	lbu	a4,-1(a1)
 2a6:	fee78fa3          	sb	a4,-1(a5)
 2aa:	fb75                	bnez	a4,29e <strcpy+0x8>
    ;
  return os;
}
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret

00000000000002b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2b8:	00054783          	lbu	a5,0(a0)
 2bc:	cb91                	beqz	a5,2d0 <strcmp+0x1e>
 2be:	0005c703          	lbu	a4,0(a1)
 2c2:	00f71763          	bne	a4,a5,2d0 <strcmp+0x1e>
    p++, q++;
 2c6:	0505                	addi	a0,a0,1
 2c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	fbe5                	bnez	a5,2be <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2d0:	0005c503          	lbu	a0,0(a1)
}
 2d4:	40a7853b          	subw	a0,a5,a0
 2d8:	6422                	ld	s0,8(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret

00000000000002de <strlen>:

uint
strlen(const char *s)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2e4:	00054783          	lbu	a5,0(a0)
 2e8:	cf91                	beqz	a5,304 <strlen+0x26>
 2ea:	0505                	addi	a0,a0,1
 2ec:	87aa                	mv	a5,a0
 2ee:	86be                	mv	a3,a5
 2f0:	0785                	addi	a5,a5,1
 2f2:	fff7c703          	lbu	a4,-1(a5)
 2f6:	ff65                	bnez	a4,2ee <strlen+0x10>
 2f8:	40a6853b          	subw	a0,a3,a0
 2fc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2fe:	6422                	ld	s0,8(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
  for(n = 0; s[n]; n++)
 304:	4501                	li	a0,0
 306:	bfe5                	j	2fe <strlen+0x20>

0000000000000308 <memset>:

void*
memset(void *dst, int c, uint n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e422                	sd	s0,8(sp)
 30c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 30e:	ca19                	beqz	a2,324 <memset+0x1c>
 310:	87aa                	mv	a5,a0
 312:	1602                	slli	a2,a2,0x20
 314:	9201                	srli	a2,a2,0x20
 316:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 31a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 31e:	0785                	addi	a5,a5,1
 320:	fee79de3          	bne	a5,a4,31a <memset+0x12>
  }
  return dst;
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret

000000000000032a <strchr>:

char*
strchr(const char *s, char c)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 330:	00054783          	lbu	a5,0(a0)
 334:	cb99                	beqz	a5,34a <strchr+0x20>
    if(*s == c)
 336:	00f58763          	beq	a1,a5,344 <strchr+0x1a>
  for(; *s; s++)
 33a:	0505                	addi	a0,a0,1
 33c:	00054783          	lbu	a5,0(a0)
 340:	fbfd                	bnez	a5,336 <strchr+0xc>
      return (char*)s;
  return 0;
 342:	4501                	li	a0,0
}
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret
  return 0;
 34a:	4501                	li	a0,0
 34c:	bfe5                	j	344 <strchr+0x1a>

000000000000034e <gets>:

char*
gets(char *buf, int max)
{
 34e:	711d                	addi	sp,sp,-96
 350:	ec86                	sd	ra,88(sp)
 352:	e8a2                	sd	s0,80(sp)
 354:	e4a6                	sd	s1,72(sp)
 356:	e0ca                	sd	s2,64(sp)
 358:	fc4e                	sd	s3,56(sp)
 35a:	f852                	sd	s4,48(sp)
 35c:	f456                	sd	s5,40(sp)
 35e:	f05a                	sd	s6,32(sp)
 360:	ec5e                	sd	s7,24(sp)
 362:	1080                	addi	s0,sp,96
 364:	8baa                	mv	s7,a0
 366:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 368:	892a                	mv	s2,a0
 36a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 36c:	4aa9                	li	s5,10
 36e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 370:	89a6                	mv	s3,s1
 372:	2485                	addiw	s1,s1,1
 374:	0344d663          	bge	s1,s4,3a0 <gets+0x52>
    cc = read(0, &c, 1);
 378:	4605                	li	a2,1
 37a:	faf40593          	addi	a1,s0,-81
 37e:	4501                	li	a0,0
 380:	186000ef          	jal	506 <read>
    if(cc < 1)
 384:	00a05e63          	blez	a0,3a0 <gets+0x52>
    buf[i++] = c;
 388:	faf44783          	lbu	a5,-81(s0)
 38c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 390:	01578763          	beq	a5,s5,39e <gets+0x50>
 394:	0905                	addi	s2,s2,1
 396:	fd679de3          	bne	a5,s6,370 <gets+0x22>
    buf[i++] = c;
 39a:	89a6                	mv	s3,s1
 39c:	a011                	j	3a0 <gets+0x52>
 39e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3a0:	99de                	add	s3,s3,s7
 3a2:	00098023          	sb	zero,0(s3)
  return buf;
}
 3a6:	855e                	mv	a0,s7
 3a8:	60e6                	ld	ra,88(sp)
 3aa:	6446                	ld	s0,80(sp)
 3ac:	64a6                	ld	s1,72(sp)
 3ae:	6906                	ld	s2,64(sp)
 3b0:	79e2                	ld	s3,56(sp)
 3b2:	7a42                	ld	s4,48(sp)
 3b4:	7aa2                	ld	s5,40(sp)
 3b6:	7b02                	ld	s6,32(sp)
 3b8:	6be2                	ld	s7,24(sp)
 3ba:	6125                	addi	sp,sp,96
 3bc:	8082                	ret

00000000000003be <stat>:

int
stat(const char *n, struct stat *st)
{
 3be:	1101                	addi	sp,sp,-32
 3c0:	ec06                	sd	ra,24(sp)
 3c2:	e822                	sd	s0,16(sp)
 3c4:	e04a                	sd	s2,0(sp)
 3c6:	1000                	addi	s0,sp,32
 3c8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3ca:	4581                	li	a1,0
 3cc:	162000ef          	jal	52e <open>
  if(fd < 0)
 3d0:	02054263          	bltz	a0,3f4 <stat+0x36>
 3d4:	e426                	sd	s1,8(sp)
 3d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3d8:	85ca                	mv	a1,s2
 3da:	16c000ef          	jal	546 <fstat>
 3de:	892a                	mv	s2,a0
  close(fd);
 3e0:	8526                	mv	a0,s1
 3e2:	134000ef          	jal	516 <close>
  return r;
 3e6:	64a2                	ld	s1,8(sp)
}
 3e8:	854a                	mv	a0,s2
 3ea:	60e2                	ld	ra,24(sp)
 3ec:	6442                	ld	s0,16(sp)
 3ee:	6902                	ld	s2,0(sp)
 3f0:	6105                	addi	sp,sp,32
 3f2:	8082                	ret
    return -1;
 3f4:	597d                	li	s2,-1
 3f6:	bfcd                	j	3e8 <stat+0x2a>

00000000000003f8 <atoi>:

int
atoi(const char *s)
{
 3f8:	1141                	addi	sp,sp,-16
 3fa:	e422                	sd	s0,8(sp)
 3fc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3fe:	00054683          	lbu	a3,0(a0)
 402:	fd06879b          	addiw	a5,a3,-48
 406:	0ff7f793          	zext.b	a5,a5
 40a:	4625                	li	a2,9
 40c:	02f66863          	bltu	a2,a5,43c <atoi+0x44>
 410:	872a                	mv	a4,a0
  n = 0;
 412:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 414:	0705                	addi	a4,a4,1
 416:	0025179b          	slliw	a5,a0,0x2
 41a:	9fa9                	addw	a5,a5,a0
 41c:	0017979b          	slliw	a5,a5,0x1
 420:	9fb5                	addw	a5,a5,a3
 422:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 426:	00074683          	lbu	a3,0(a4)
 42a:	fd06879b          	addiw	a5,a3,-48
 42e:	0ff7f793          	zext.b	a5,a5
 432:	fef671e3          	bgeu	a2,a5,414 <atoi+0x1c>
  return n;
}
 436:	6422                	ld	s0,8(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret
  n = 0;
 43c:	4501                	li	a0,0
 43e:	bfe5                	j	436 <atoi+0x3e>

0000000000000440 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 440:	1141                	addi	sp,sp,-16
 442:	e422                	sd	s0,8(sp)
 444:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 446:	02b57463          	bgeu	a0,a1,46e <memmove+0x2e>
    while(n-- > 0)
 44a:	00c05f63          	blez	a2,468 <memmove+0x28>
 44e:	1602                	slli	a2,a2,0x20
 450:	9201                	srli	a2,a2,0x20
 452:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 456:	872a                	mv	a4,a0
      *dst++ = *src++;
 458:	0585                	addi	a1,a1,1
 45a:	0705                	addi	a4,a4,1
 45c:	fff5c683          	lbu	a3,-1(a1)
 460:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 464:	fef71ae3          	bne	a4,a5,458 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 468:	6422                	ld	s0,8(sp)
 46a:	0141                	addi	sp,sp,16
 46c:	8082                	ret
    dst += n;
 46e:	00c50733          	add	a4,a0,a2
    src += n;
 472:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 474:	fec05ae3          	blez	a2,468 <memmove+0x28>
 478:	fff6079b          	addiw	a5,a2,-1
 47c:	1782                	slli	a5,a5,0x20
 47e:	9381                	srli	a5,a5,0x20
 480:	fff7c793          	not	a5,a5
 484:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 486:	15fd                	addi	a1,a1,-1
 488:	177d                	addi	a4,a4,-1
 48a:	0005c683          	lbu	a3,0(a1)
 48e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 492:	fee79ae3          	bne	a5,a4,486 <memmove+0x46>
 496:	bfc9                	j	468 <memmove+0x28>

0000000000000498 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 498:	1141                	addi	sp,sp,-16
 49a:	e422                	sd	s0,8(sp)
 49c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 49e:	ca05                	beqz	a2,4ce <memcmp+0x36>
 4a0:	fff6069b          	addiw	a3,a2,-1
 4a4:	1682                	slli	a3,a3,0x20
 4a6:	9281                	srli	a3,a3,0x20
 4a8:	0685                	addi	a3,a3,1
 4aa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4ac:	00054783          	lbu	a5,0(a0)
 4b0:	0005c703          	lbu	a4,0(a1)
 4b4:	00e79863          	bne	a5,a4,4c4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4b8:	0505                	addi	a0,a0,1
    p2++;
 4ba:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4bc:	fed518e3          	bne	a0,a3,4ac <memcmp+0x14>
  }
  return 0;
 4c0:	4501                	li	a0,0
 4c2:	a019                	j	4c8 <memcmp+0x30>
      return *p1 - *p2;
 4c4:	40e7853b          	subw	a0,a5,a4
}
 4c8:	6422                	ld	s0,8(sp)
 4ca:	0141                	addi	sp,sp,16
 4cc:	8082                	ret
  return 0;
 4ce:	4501                	li	a0,0
 4d0:	bfe5                	j	4c8 <memcmp+0x30>

00000000000004d2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4d2:	1141                	addi	sp,sp,-16
 4d4:	e406                	sd	ra,8(sp)
 4d6:	e022                	sd	s0,0(sp)
 4d8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4da:	f67ff0ef          	jal	440 <memmove>
}
 4de:	60a2                	ld	ra,8(sp)
 4e0:	6402                	ld	s0,0(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret

00000000000004e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4e6:	4885                	li	a7,1
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ee:	4889                	li	a7,2
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4f6:	488d                	li	a7,3
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4fe:	4891                	li	a7,4
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <read>:
.global read
read:
 li a7, SYS_read
 506:	4895                	li	a7,5
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <write>:
.global write
write:
 li a7, SYS_write
 50e:	48c1                	li	a7,16
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <close>:
.global close
close:
 li a7, SYS_close
 516:	48d5                	li	a7,21
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <kill>:
.global kill
kill:
 li a7, SYS_kill
 51e:	4899                	li	a7,6
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <exec>:
.global exec
exec:
 li a7, SYS_exec
 526:	489d                	li	a7,7
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <open>:
.global open
open:
 li a7, SYS_open
 52e:	48bd                	li	a7,15
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 536:	48c5                	li	a7,17
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 53e:	48c9                	li	a7,18
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 546:	48a1                	li	a7,8
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <link>:
.global link
link:
 li a7, SYS_link
 54e:	48cd                	li	a7,19
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 556:	48d1                	li	a7,20
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 55e:	48a5                	li	a7,9
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <dup>:
.global dup
dup:
 li a7, SYS_dup
 566:	48a9                	li	a7,10
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 56e:	48ad                	li	a7,11
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 576:	48b1                	li	a7,12
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 57e:	48b5                	li	a7,13
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 586:	48b9                	li	a7,14
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <set_sched>:
.global set_sched
set_sched:
 li a7, SYS_set_sched
 58e:	48d9                	li	a7,22
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 596:	48dd                	li	a7,23
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <top>:
.global top
top:
 li a7, SYS_top
 59e:	48e1                	li	a7,24
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <fork_with_priority>:
.global fork_with_priority
fork_with_priority:
 li a7, SYS_fork_with_priority
 5a6:	48e5                	li	a7,25
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <yield>:
.global yield
yield:
 li a7, SYS_yield
 5ae:	48e9                	li	a7,26
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <get_waiting_time>:
.global get_waiting_time
get_waiting_time:
  li a7, SYS_get_waiting_time
 5b6:	48ed                	li	a7,27
  ecall
 5b8:	00000073          	ecall
  ret
 5bc:	8082                	ret

00000000000005be <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5be:	1101                	addi	sp,sp,-32
 5c0:	ec06                	sd	ra,24(sp)
 5c2:	e822                	sd	s0,16(sp)
 5c4:	1000                	addi	s0,sp,32
 5c6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5ca:	4605                	li	a2,1
 5cc:	fef40593          	addi	a1,s0,-17
 5d0:	f3fff0ef          	jal	50e <write>
}
 5d4:	60e2                	ld	ra,24(sp)
 5d6:	6442                	ld	s0,16(sp)
 5d8:	6105                	addi	sp,sp,32
 5da:	8082                	ret

00000000000005dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5dc:	7139                	addi	sp,sp,-64
 5de:	fc06                	sd	ra,56(sp)
 5e0:	f822                	sd	s0,48(sp)
 5e2:	f426                	sd	s1,40(sp)
 5e4:	0080                	addi	s0,sp,64
 5e6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5e8:	c299                	beqz	a3,5ee <printint+0x12>
 5ea:	0805c963          	bltz	a1,67c <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ee:	2581                	sext.w	a1,a1
  neg = 0;
 5f0:	4881                	li	a7,0
 5f2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5f8:	2601                	sext.w	a2,a2
 5fa:	00000517          	auipc	a0,0x0
 5fe:	64e50513          	addi	a0,a0,1614 # c48 <digits>
 602:	883a                	mv	a6,a4
 604:	2705                	addiw	a4,a4,1
 606:	02c5f7bb          	remuw	a5,a1,a2
 60a:	1782                	slli	a5,a5,0x20
 60c:	9381                	srli	a5,a5,0x20
 60e:	97aa                	add	a5,a5,a0
 610:	0007c783          	lbu	a5,0(a5)
 614:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 618:	0005879b          	sext.w	a5,a1
 61c:	02c5d5bb          	divuw	a1,a1,a2
 620:	0685                	addi	a3,a3,1
 622:	fec7f0e3          	bgeu	a5,a2,602 <printint+0x26>
  if(neg)
 626:	00088c63          	beqz	a7,63e <printint+0x62>
    buf[i++] = '-';
 62a:	fd070793          	addi	a5,a4,-48
 62e:	00878733          	add	a4,a5,s0
 632:	02d00793          	li	a5,45
 636:	fef70823          	sb	a5,-16(a4)
 63a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 63e:	02e05a63          	blez	a4,672 <printint+0x96>
 642:	f04a                	sd	s2,32(sp)
 644:	ec4e                	sd	s3,24(sp)
 646:	fc040793          	addi	a5,s0,-64
 64a:	00e78933          	add	s2,a5,a4
 64e:	fff78993          	addi	s3,a5,-1
 652:	99ba                	add	s3,s3,a4
 654:	377d                	addiw	a4,a4,-1
 656:	1702                	slli	a4,a4,0x20
 658:	9301                	srli	a4,a4,0x20
 65a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 65e:	fff94583          	lbu	a1,-1(s2)
 662:	8526                	mv	a0,s1
 664:	f5bff0ef          	jal	5be <putc>
  while(--i >= 0)
 668:	197d                	addi	s2,s2,-1
 66a:	ff391ae3          	bne	s2,s3,65e <printint+0x82>
 66e:	7902                	ld	s2,32(sp)
 670:	69e2                	ld	s3,24(sp)
}
 672:	70e2                	ld	ra,56(sp)
 674:	7442                	ld	s0,48(sp)
 676:	74a2                	ld	s1,40(sp)
 678:	6121                	addi	sp,sp,64
 67a:	8082                	ret
    x = -xx;
 67c:	40b005bb          	negw	a1,a1
    neg = 1;
 680:	4885                	li	a7,1
    x = -xx;
 682:	bf85                	j	5f2 <printint+0x16>

0000000000000684 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 684:	711d                	addi	sp,sp,-96
 686:	ec86                	sd	ra,88(sp)
 688:	e8a2                	sd	s0,80(sp)
 68a:	e0ca                	sd	s2,64(sp)
 68c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 68e:	0005c903          	lbu	s2,0(a1)
 692:	26090863          	beqz	s2,902 <vprintf+0x27e>
 696:	e4a6                	sd	s1,72(sp)
 698:	fc4e                	sd	s3,56(sp)
 69a:	f852                	sd	s4,48(sp)
 69c:	f456                	sd	s5,40(sp)
 69e:	f05a                	sd	s6,32(sp)
 6a0:	ec5e                	sd	s7,24(sp)
 6a2:	e862                	sd	s8,16(sp)
 6a4:	e466                	sd	s9,8(sp)
 6a6:	8b2a                	mv	s6,a0
 6a8:	8a2e                	mv	s4,a1
 6aa:	8bb2                	mv	s7,a2
  state = 0;
 6ac:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6ae:	4481                	li	s1,0
 6b0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6b2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6b6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6ba:	06c00c93          	li	s9,108
 6be:	a005                	j	6de <vprintf+0x5a>
        putc(fd, c0);
 6c0:	85ca                	mv	a1,s2
 6c2:	855a                	mv	a0,s6
 6c4:	efbff0ef          	jal	5be <putc>
 6c8:	a019                	j	6ce <vprintf+0x4a>
    } else if(state == '%'){
 6ca:	03598263          	beq	s3,s5,6ee <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 6ce:	2485                	addiw	s1,s1,1
 6d0:	8726                	mv	a4,s1
 6d2:	009a07b3          	add	a5,s4,s1
 6d6:	0007c903          	lbu	s2,0(a5)
 6da:	20090c63          	beqz	s2,8f2 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 6de:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6e2:	fe0994e3          	bnez	s3,6ca <vprintf+0x46>
      if(c0 == '%'){
 6e6:	fd579de3          	bne	a5,s5,6c0 <vprintf+0x3c>
        state = '%';
 6ea:	89be                	mv	s3,a5
 6ec:	b7cd                	j	6ce <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6ee:	00ea06b3          	add	a3,s4,a4
 6f2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6f6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6f8:	c681                	beqz	a3,700 <vprintf+0x7c>
 6fa:	9752                	add	a4,a4,s4
 6fc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 700:	03878f63          	beq	a5,s8,73e <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 704:	05978963          	beq	a5,s9,756 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 708:	07500713          	li	a4,117
 70c:	0ee78363          	beq	a5,a4,7f2 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 710:	07800713          	li	a4,120
 714:	12e78563          	beq	a5,a4,83e <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 718:	07000713          	li	a4,112
 71c:	14e78a63          	beq	a5,a4,870 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 720:	07300713          	li	a4,115
 724:	18e78a63          	beq	a5,a4,8b8 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 728:	02500713          	li	a4,37
 72c:	04e79563          	bne	a5,a4,776 <vprintf+0xf2>
        putc(fd, '%');
 730:	02500593          	li	a1,37
 734:	855a                	mv	a0,s6
 736:	e89ff0ef          	jal	5be <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bf49                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 73e:	008b8913          	addi	s2,s7,8
 742:	4685                	li	a3,1
 744:	4629                	li	a2,10
 746:	000ba583          	lw	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	e91ff0ef          	jal	5dc <printint>
 750:	8bca                	mv	s7,s2
      state = 0;
 752:	4981                	li	s3,0
 754:	bfad                	j	6ce <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 756:	06400793          	li	a5,100
 75a:	02f68963          	beq	a3,a5,78c <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 75e:	06c00793          	li	a5,108
 762:	04f68263          	beq	a3,a5,7a6 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 766:	07500793          	li	a5,117
 76a:	0af68063          	beq	a3,a5,80a <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 76e:	07800793          	li	a5,120
 772:	0ef68263          	beq	a3,a5,856 <vprintf+0x1d2>
        putc(fd, '%');
 776:	02500593          	li	a1,37
 77a:	855a                	mv	a0,s6
 77c:	e43ff0ef          	jal	5be <putc>
        putc(fd, c0);
 780:	85ca                	mv	a1,s2
 782:	855a                	mv	a0,s6
 784:	e3bff0ef          	jal	5be <putc>
      state = 0;
 788:	4981                	li	s3,0
 78a:	b791                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 78c:	008b8913          	addi	s2,s7,8
 790:	4685                	li	a3,1
 792:	4629                	li	a2,10
 794:	000ba583          	lw	a1,0(s7)
 798:	855a                	mv	a0,s6
 79a:	e43ff0ef          	jal	5dc <printint>
        i += 1;
 79e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7a0:	8bca                	mv	s7,s2
      state = 0;
 7a2:	4981                	li	s3,0
        i += 1;
 7a4:	b72d                	j	6ce <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7a6:	06400793          	li	a5,100
 7aa:	02f60763          	beq	a2,a5,7d8 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7ae:	07500793          	li	a5,117
 7b2:	06f60963          	beq	a2,a5,824 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7b6:	07800793          	li	a5,120
 7ba:	faf61ee3          	bne	a2,a5,776 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7be:	008b8913          	addi	s2,s7,8
 7c2:	4681                	li	a3,0
 7c4:	4641                	li	a2,16
 7c6:	000ba583          	lw	a1,0(s7)
 7ca:	855a                	mv	a0,s6
 7cc:	e11ff0ef          	jal	5dc <printint>
        i += 2;
 7d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d2:	8bca                	mv	s7,s2
      state = 0;
 7d4:	4981                	li	s3,0
        i += 2;
 7d6:	bde5                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d8:	008b8913          	addi	s2,s7,8
 7dc:	4685                	li	a3,1
 7de:	4629                	li	a2,10
 7e0:	000ba583          	lw	a1,0(s7)
 7e4:	855a                	mv	a0,s6
 7e6:	df7ff0ef          	jal	5dc <printint>
        i += 2;
 7ea:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ec:	8bca                	mv	s7,s2
      state = 0;
 7ee:	4981                	li	s3,0
        i += 2;
 7f0:	bdf9                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 7f2:	008b8913          	addi	s2,s7,8
 7f6:	4681                	li	a3,0
 7f8:	4629                	li	a2,10
 7fa:	000ba583          	lw	a1,0(s7)
 7fe:	855a                	mv	a0,s6
 800:	dddff0ef          	jal	5dc <printint>
 804:	8bca                	mv	s7,s2
      state = 0;
 806:	4981                	li	s3,0
 808:	b5d9                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 80a:	008b8913          	addi	s2,s7,8
 80e:	4681                	li	a3,0
 810:	4629                	li	a2,10
 812:	000ba583          	lw	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	dc5ff0ef          	jal	5dc <printint>
        i += 1;
 81c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 81e:	8bca                	mv	s7,s2
      state = 0;
 820:	4981                	li	s3,0
        i += 1;
 822:	b575                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 824:	008b8913          	addi	s2,s7,8
 828:	4681                	li	a3,0
 82a:	4629                	li	a2,10
 82c:	000ba583          	lw	a1,0(s7)
 830:	855a                	mv	a0,s6
 832:	dabff0ef          	jal	5dc <printint>
        i += 2;
 836:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 838:	8bca                	mv	s7,s2
      state = 0;
 83a:	4981                	li	s3,0
        i += 2;
 83c:	bd49                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 83e:	008b8913          	addi	s2,s7,8
 842:	4681                	li	a3,0
 844:	4641                	li	a2,16
 846:	000ba583          	lw	a1,0(s7)
 84a:	855a                	mv	a0,s6
 84c:	d91ff0ef          	jal	5dc <printint>
 850:	8bca                	mv	s7,s2
      state = 0;
 852:	4981                	li	s3,0
 854:	bdad                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 856:	008b8913          	addi	s2,s7,8
 85a:	4681                	li	a3,0
 85c:	4641                	li	a2,16
 85e:	000ba583          	lw	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	d79ff0ef          	jal	5dc <printint>
        i += 1;
 868:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 86a:	8bca                	mv	s7,s2
      state = 0;
 86c:	4981                	li	s3,0
        i += 1;
 86e:	b585                	j	6ce <vprintf+0x4a>
 870:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 872:	008b8d13          	addi	s10,s7,8
 876:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 87a:	03000593          	li	a1,48
 87e:	855a                	mv	a0,s6
 880:	d3fff0ef          	jal	5be <putc>
  putc(fd, 'x');
 884:	07800593          	li	a1,120
 888:	855a                	mv	a0,s6
 88a:	d35ff0ef          	jal	5be <putc>
 88e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 890:	00000b97          	auipc	s7,0x0
 894:	3b8b8b93          	addi	s7,s7,952 # c48 <digits>
 898:	03c9d793          	srli	a5,s3,0x3c
 89c:	97de                	add	a5,a5,s7
 89e:	0007c583          	lbu	a1,0(a5)
 8a2:	855a                	mv	a0,s6
 8a4:	d1bff0ef          	jal	5be <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8a8:	0992                	slli	s3,s3,0x4
 8aa:	397d                	addiw	s2,s2,-1
 8ac:	fe0916e3          	bnez	s2,898 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 8b0:	8bea                	mv	s7,s10
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	6d02                	ld	s10,0(sp)
 8b6:	bd21                	j	6ce <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8b8:	008b8993          	addi	s3,s7,8
 8bc:	000bb903          	ld	s2,0(s7)
 8c0:	00090f63          	beqz	s2,8de <vprintf+0x25a>
        for(; *s; s++)
 8c4:	00094583          	lbu	a1,0(s2)
 8c8:	c195                	beqz	a1,8ec <vprintf+0x268>
          putc(fd, *s);
 8ca:	855a                	mv	a0,s6
 8cc:	cf3ff0ef          	jal	5be <putc>
        for(; *s; s++)
 8d0:	0905                	addi	s2,s2,1
 8d2:	00094583          	lbu	a1,0(s2)
 8d6:	f9f5                	bnez	a1,8ca <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 8d8:	8bce                	mv	s7,s3
      state = 0;
 8da:	4981                	li	s3,0
 8dc:	bbcd                	j	6ce <vprintf+0x4a>
          s = "(null)";
 8de:	00000917          	auipc	s2,0x0
 8e2:	36290913          	addi	s2,s2,866 # c40 <malloc+0x256>
        for(; *s; s++)
 8e6:	02800593          	li	a1,40
 8ea:	b7c5                	j	8ca <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 8ec:	8bce                	mv	s7,s3
      state = 0;
 8ee:	4981                	li	s3,0
 8f0:	bbf9                	j	6ce <vprintf+0x4a>
 8f2:	64a6                	ld	s1,72(sp)
 8f4:	79e2                	ld	s3,56(sp)
 8f6:	7a42                	ld	s4,48(sp)
 8f8:	7aa2                	ld	s5,40(sp)
 8fa:	7b02                	ld	s6,32(sp)
 8fc:	6be2                	ld	s7,24(sp)
 8fe:	6c42                	ld	s8,16(sp)
 900:	6ca2                	ld	s9,8(sp)
    }
  }
}
 902:	60e6                	ld	ra,88(sp)
 904:	6446                	ld	s0,80(sp)
 906:	6906                	ld	s2,64(sp)
 908:	6125                	addi	sp,sp,96
 90a:	8082                	ret

000000000000090c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 90c:	715d                	addi	sp,sp,-80
 90e:	ec06                	sd	ra,24(sp)
 910:	e822                	sd	s0,16(sp)
 912:	1000                	addi	s0,sp,32
 914:	e010                	sd	a2,0(s0)
 916:	e414                	sd	a3,8(s0)
 918:	e818                	sd	a4,16(s0)
 91a:	ec1c                	sd	a5,24(s0)
 91c:	03043023          	sd	a6,32(s0)
 920:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 924:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 928:	8622                	mv	a2,s0
 92a:	d5bff0ef          	jal	684 <vprintf>
}
 92e:	60e2                	ld	ra,24(sp)
 930:	6442                	ld	s0,16(sp)
 932:	6161                	addi	sp,sp,80
 934:	8082                	ret

0000000000000936 <printf>:

void
printf(const char *fmt, ...)
{
 936:	711d                	addi	sp,sp,-96
 938:	ec06                	sd	ra,24(sp)
 93a:	e822                	sd	s0,16(sp)
 93c:	1000                	addi	s0,sp,32
 93e:	e40c                	sd	a1,8(s0)
 940:	e810                	sd	a2,16(s0)
 942:	ec14                	sd	a3,24(s0)
 944:	f018                	sd	a4,32(s0)
 946:	f41c                	sd	a5,40(s0)
 948:	03043823          	sd	a6,48(s0)
 94c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 950:	00840613          	addi	a2,s0,8
 954:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 958:	85aa                	mv	a1,a0
 95a:	4505                	li	a0,1
 95c:	d29ff0ef          	jal	684 <vprintf>
}
 960:	60e2                	ld	ra,24(sp)
 962:	6442                	ld	s0,16(sp)
 964:	6125                	addi	sp,sp,96
 966:	8082                	ret

0000000000000968 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 968:	1141                	addi	sp,sp,-16
 96a:	e422                	sd	s0,8(sp)
 96c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 96e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 972:	00000797          	auipc	a5,0x0
 976:	6967b783          	ld	a5,1686(a5) # 1008 <freep>
 97a:	a02d                	j	9a4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 97c:	4618                	lw	a4,8(a2)
 97e:	9f2d                	addw	a4,a4,a1
 980:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 984:	6398                	ld	a4,0(a5)
 986:	6310                	ld	a2,0(a4)
 988:	a83d                	j	9c6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 98a:	ff852703          	lw	a4,-8(a0)
 98e:	9f31                	addw	a4,a4,a2
 990:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 992:	ff053683          	ld	a3,-16(a0)
 996:	a091                	j	9da <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 998:	6398                	ld	a4,0(a5)
 99a:	00e7e463          	bltu	a5,a4,9a2 <free+0x3a>
 99e:	00e6ea63          	bltu	a3,a4,9b2 <free+0x4a>
{
 9a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a4:	fed7fae3          	bgeu	a5,a3,998 <free+0x30>
 9a8:	6398                	ld	a4,0(a5)
 9aa:	00e6e463          	bltu	a3,a4,9b2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ae:	fee7eae3          	bltu	a5,a4,9a2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9b2:	ff852583          	lw	a1,-8(a0)
 9b6:	6390                	ld	a2,0(a5)
 9b8:	02059813          	slli	a6,a1,0x20
 9bc:	01c85713          	srli	a4,a6,0x1c
 9c0:	9736                	add	a4,a4,a3
 9c2:	fae60de3          	beq	a2,a4,97c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9ca:	4790                	lw	a2,8(a5)
 9cc:	02061593          	slli	a1,a2,0x20
 9d0:	01c5d713          	srli	a4,a1,0x1c
 9d4:	973e                	add	a4,a4,a5
 9d6:	fae68ae3          	beq	a3,a4,98a <free+0x22>
    p->s.ptr = bp->s.ptr;
 9da:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9dc:	00000717          	auipc	a4,0x0
 9e0:	62f73623          	sd	a5,1580(a4) # 1008 <freep>
}
 9e4:	6422                	ld	s0,8(sp)
 9e6:	0141                	addi	sp,sp,16
 9e8:	8082                	ret

00000000000009ea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ea:	7139                	addi	sp,sp,-64
 9ec:	fc06                	sd	ra,56(sp)
 9ee:	f822                	sd	s0,48(sp)
 9f0:	f426                	sd	s1,40(sp)
 9f2:	ec4e                	sd	s3,24(sp)
 9f4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f6:	02051493          	slli	s1,a0,0x20
 9fa:	9081                	srli	s1,s1,0x20
 9fc:	04bd                	addi	s1,s1,15
 9fe:	8091                	srli	s1,s1,0x4
 a00:	0014899b          	addiw	s3,s1,1
 a04:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a06:	00000517          	auipc	a0,0x0
 a0a:	60253503          	ld	a0,1538(a0) # 1008 <freep>
 a0e:	c915                	beqz	a0,a42 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a10:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a12:	4798                	lw	a4,8(a5)
 a14:	08977a63          	bgeu	a4,s1,aa8 <malloc+0xbe>
 a18:	f04a                	sd	s2,32(sp)
 a1a:	e852                	sd	s4,16(sp)
 a1c:	e456                	sd	s5,8(sp)
 a1e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a20:	8a4e                	mv	s4,s3
 a22:	0009871b          	sext.w	a4,s3
 a26:	6685                	lui	a3,0x1
 a28:	00d77363          	bgeu	a4,a3,a2e <malloc+0x44>
 a2c:	6a05                	lui	s4,0x1
 a2e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a32:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a36:	00000917          	auipc	s2,0x0
 a3a:	5d290913          	addi	s2,s2,1490 # 1008 <freep>
  if(p == (char*)-1)
 a3e:	5afd                	li	s5,-1
 a40:	a081                	j	a80 <malloc+0x96>
 a42:	f04a                	sd	s2,32(sp)
 a44:	e852                	sd	s4,16(sp)
 a46:	e456                	sd	s5,8(sp)
 a48:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a4a:	00008797          	auipc	a5,0x8
 a4e:	af678793          	addi	a5,a5,-1290 # 8540 <base>
 a52:	00000717          	auipc	a4,0x0
 a56:	5af73b23          	sd	a5,1462(a4) # 1008 <freep>
 a5a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a5c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a60:	b7c1                	j	a20 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a62:	6398                	ld	a4,0(a5)
 a64:	e118                	sd	a4,0(a0)
 a66:	a8a9                	j	ac0 <malloc+0xd6>
  hp->s.size = nu;
 a68:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a6c:	0541                	addi	a0,a0,16
 a6e:	efbff0ef          	jal	968 <free>
  return freep;
 a72:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a76:	c12d                	beqz	a0,ad8 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a7a:	4798                	lw	a4,8(a5)
 a7c:	02977263          	bgeu	a4,s1,aa0 <malloc+0xb6>
    if(p == freep)
 a80:	00093703          	ld	a4,0(s2)
 a84:	853e                	mv	a0,a5
 a86:	fef719e3          	bne	a4,a5,a78 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a8a:	8552                	mv	a0,s4
 a8c:	aebff0ef          	jal	576 <sbrk>
  if(p == (char*)-1)
 a90:	fd551ce3          	bne	a0,s5,a68 <malloc+0x7e>
        return 0;
 a94:	4501                	li	a0,0
 a96:	7902                	ld	s2,32(sp)
 a98:	6a42                	ld	s4,16(sp)
 a9a:	6aa2                	ld	s5,8(sp)
 a9c:	6b02                	ld	s6,0(sp)
 a9e:	a03d                	j	acc <malloc+0xe2>
 aa0:	7902                	ld	s2,32(sp)
 aa2:	6a42                	ld	s4,16(sp)
 aa4:	6aa2                	ld	s5,8(sp)
 aa6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 aa8:	fae48de3          	beq	s1,a4,a62 <malloc+0x78>
        p->s.size -= nunits;
 aac:	4137073b          	subw	a4,a4,s3
 ab0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ab2:	02071693          	slli	a3,a4,0x20
 ab6:	01c6d713          	srli	a4,a3,0x1c
 aba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 abc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ac0:	00000717          	auipc	a4,0x0
 ac4:	54a73423          	sd	a0,1352(a4) # 1008 <freep>
      return (void*)(p + 1);
 ac8:	01078513          	addi	a0,a5,16
  }
}
 acc:	70e2                	ld	ra,56(sp)
 ace:	7442                	ld	s0,48(sp)
 ad0:	74a2                	ld	s1,40(sp)
 ad2:	69e2                	ld	s3,24(sp)
 ad4:	6121                	addi	sp,sp,64
 ad6:	8082                	ret
 ad8:	7902                	ld	s2,32(sp)
 ada:	6a42                	ld	s4,16(sp)
 adc:	6aa2                	ld	s5,8(sp)
 ade:	6b02                	ld	s6,0(sp)
 ae0:	b7f5                	j	acc <malloc+0xe2>
