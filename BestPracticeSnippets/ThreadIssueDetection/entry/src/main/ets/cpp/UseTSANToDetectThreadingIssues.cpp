/**
 * 最佳实践: 使用Tsan检测线程问题
 */

// [Start Global]
int Global = 12;


void Set1() {
    *(char *)&Global = 4;
}


void Set2() {
    Global=43;
}


void *Thread1(void *x){
    Set1();
    return x;
}


static napi_value Add(napi_env env, napi_callback_info info){
    ...
    pthread_t t;
    pthread_create(&t, NULL, Thread1, NULL);
    Set2();
    pthread_join(t, NULL);
    ...
}
// [End Global]

// [Start struct_a]
#include <semaphore.h>
#include <pthread.h>


struct A {
  A() {
    sem_init(&sem_, 0, 0);
  }
  virtual void F() {
  }
  void Done() {
    sem_post(&sem_);
  }
  virtual ~A() {
    sem_wait(&sem_);
    sem_destroy(&sem_);
  }
  sem_t sem_;
};


struct B : A {
  virtual void F() {
  }
  virtual ~B() { }
};


static A *obj = new B;


void *Thread1(void *x) {
  obj->F();
  obj->Done();
  return NULL;
}


void *Thread2(void *x) {
  delete obj;
  return NULL;
}


static napi_value Add(napi_env env, napi_callback_info info){
    ...
    pthread_t t[2];
    pthread_create(&t[0], NULL, Thread1, NULL);
    pthread_create(&t[1], NULL, Thread2, NULL);
    pthread_join(t[0], NULL);
    pthread_join(t[1], NULL);
    ...
}
// [End struct_a]

// [Start Thread1]
#include <pthread.h>


int *mem;
pthread_mutex_t mtx;


void *Thread1(void *x) {
  pthread_mutex_lock(&mtx);
  free(mem);
  pthread_mutex_unlock(&mtx);
  return NULL;
}


__attribute__((noinline)) void *Thread2(void *x) {
  pthread_mutex_lock(&mtx);
  mem[0] = 42;
  pthread_mutex_unlock(&mtx);
  return NULL;
}


static napi_value Add(napi_env env, napi_callback_info info){
    ...
    mem = (int*)malloc(100);
    pthread_mutex_init(&mtx, 0);
    pthread_t t;
    pthread_create(&t, NULL, Thread1, NULL);
    Thread2(0);
    pthread_join(t, NULL);
    pthread_mutex_destroy(&mtx);
    ...
}
// [End Thread1]

// [Start MyHandler]
#include "napi/native_api.h"
#include <signal.h>
#include <sys/types.h>
#include <errno.h>
#include <malloc.h>
#include <pthread.h>


static void MyHandler(int, siginfo_t *s, void *c) {
  errno = 1;
  done = 1;
}


static void* sendsignal(void *p) {
  pthread_kill(mainth, SIGPROF);
  return 0;
}


static __attribute__((noinline)) void loop() {
  while (done == 0) {
    volatile char *p = (char*)malloc(1);
    p[0] = 0;
    free((void*)p);
  }
}


static napi_value Add(napi_env env, napi_callback_info info){
    ...
    mainth = pthread_self();
    struct sigaction act = {};
    act.sa_sigaction = &MyHandler;
    sigaction(SIGPROF, &act, 0);
    pthread_t th;
    pthread_create(&th, 0, sendsignal, 0);
    loop();
    pthread_join(th, 0);
    ...
}
// [End MyHandler]

// [Start handler]
#include "napi/native_api.h"
#include <signal.h>
#include <sys/types.h>
#include <malloc.h>
#include <pthread.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h> 


pthread_t mainth;
volatile int done;


static void handler(int, siginfo_t*, void*) {
  volatile char *p = (char*)malloc(1);
  p[0] = 0;
  free((void*)p);
}


static napi_value Add(napi_env env, napi_callback_info info)
{
    ...
    struct sigaction act = {};
    act.sa_sigaction = &handler;
    sigaction(SIGPROF, &act, 0);
    kill(getpid(), SIGPROF);
    sleep(1); 
    fprintf(stderr, "DONE\n");
    ...
}
// [End handler]

// [Start pthread_mutex_t]
#include "napi/native_api.h"
#include <pthread.h>
#include <iostream>


pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;


void* unlocker(void* arg) {
    pthread_mutex_unlock(&mutex);
    return nullptr;
}


static napi_value Add(napi_env env, napi_callback_info info){
    ...
    pthread_t tid;
    pthread_create(&tid, nullptr, unlocker, nullptr);
    pthread_join(tid, nullptr);
    ...
}
// [End pthread_mutex_t]
