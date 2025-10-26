/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <cstdio>
#include <stdlib.h>

/**
 * 最佳实践：地址越界经典问题类型
 * heap-use-after-free
 */
// [Start heap-use-after-free]
int HeapUseAfterFree()
{
    int *array = new int[100];
    delete[] array;
    return array[5];
}
// [End heap-use-after-free]

/**
 * 最佳实践：地址越界经典问题类型
 * stack-user-after-return
 */
// [Start stack-use-after-return]
int *ptr;

__attribute__((noinline))
void FunctionThatEscapesLocalObject()
{
    int local[100];
    ptr = &local[0];
    printf("address: %p", local);
}

int StackUseAfterReturn(int argc)
{
    FunctionThatEscapesLocalObject();
    return ptr[argc];
}
// [End stack-use-after-return]

/**
 * 最佳实践：地址越界经典问题类型
 * heap-buffer-overflow
 */
// [Start heap-buffer-overflow]
int HeapBufferOverflow()
{
    char* buffer;
    buffer = (char *)malloc(100);
    *(buffer + 101) = 'n';
    *(buffer + 102) = 'n';
    free(buffer);
    printf("address: %p", buffer);
    return buffer[1];
}
// [End heap-buffer-overflow]

/**
 * 最佳实践：地址越界类问题分析方法
 */
// [Start address_overflow_code]
int AddressOverflowCode(int argc)
{
    int stack_array[99];
    stack_array[1] = 0;
    return stack_array[argc + 100]; // BOOM
}
// [End address_overflow_code]

/**
 * 最佳实践：使用Asan检测内存错误
 * 场景七：stack-buffer-overflow-错误示例
 */

// [Start stack_buffer_overflow]
int StackBufferOverflow() {
    int subscript = 43;
    char buffer[42];
    buffer[subscript] = 42;
    printf("address: %p", buffer);
    return 0;
}
// [End stack_buffer_overflow]

/**
 * 最佳实践：使用Asan检测内存错误
 * 场景八：stack-buffer-underflow-错误示例
 */

// [Start stack_buffer_underflow]
int StackBufferUnderflow() {
    int subscript = -1;
    char buffer[42];
    buffer[subscript] = 42;
    printf("address: %p", buffer);
    return 0;
}
// [End stack_buffer_underflow]

/**
 * 最佳实践：使用Asan检测内存错误
 * 场景十一：stack-use-after-scope-错误示例
 */

// [Start stack_use_after_scope]
int *gp;
bool b = true;
int StackUseAfterScope() {
    if (b) {
        int x[5];
        gp = x + 1;
        printf("address: %p", gp);
    }
    return *gp;
}
// [End stack_use_after_scope]

/**
 * 最佳实践：使用Asan检测内存错误
 * 场景十三：attempt-free-nonallocated-memory-错误示例
 */

// [Start attempt_free_nonallocated_memory]
int AttempFreeNonAllocatedMem() {
    int value = 42;
    printf("address: %p", &value);
    free(&value);
    return 0;
}
// [End attempt_free_nonallocated_memory]

/**
 * 最佳实践：使用Asan检测内存错误
 * 场景十五：double-free-错误示例
 */

// [Start double_free]
int DoubleFree() {
    int *x = new int[42];
    printf("address: %p", &x);
    delete [] x;
    delete [] x;
    return 0;
}
// [End double_free]

/**
* 最佳实践：使用HWAsan检测内存错误
* 场景五：stack tag-mismatch-错误示例
*/

// [Start stack_tag_mismatch]
// stack-buffer-overflow
int stackBufferOverflowEx() {
    int subscript = 43;
    char buffer[42];
    buffer[subscript] = 42;
    printf("address: %p", buffer);
    return 0;
}


// stack-buffer-underflow
int stackBufferUnderflowEX() {
    int subscript = -1;
    char buffer[42];
    buffer[subscript] = 42;
    printf("address: %p", buffer);
    return 0;
}


// stack-use-after-return
int *ptrEx;
__attribute__((noinline))
void FunctionThatEscapesLocalObjectEx()
{
    int local[100];
    ptrEx = &local[0];
    printf("address: %p", local);
}

int Run(int argc)
{
    FunctionThatEscapesLocalObjectEx();
    return ptrEx[argc];
}
// [End stack_tag_mismatch]

/**
* 最佳实践：使用HWAsan检测内存错误
* 场景七：heap-buffer-overflow-错误示例
*/

// [Start hw_heap_buffer_overflow]
// heap-buffer-overflow
void HeapBufferOverflowEx()
{
    char *buffer;
    buffer = (char *)malloc(10);
    *(buffer + 11) = 'n';
    *(buffer + 12) = 'n';
    printf("address: %p", buffer);
    free(buffer);
}

// heap-buffer-underflow
void HeapBufferUnderflowEx()
{
    char *buffer;
    buffer = (char *)malloc(10);
    *(buffer - 11) = 'n';
    *(buffer - 12) = 'n';
    printf("address: %p", buffer);
    free(buffer);
}
// [End hw_heap_buffer_overflow]

/**
* 最佳实践：使用HWAsan检测内存错误
* 场景九：Use-after-free-错误示例
*/

// [Start hw_use_after_free]
// heap-use-after-free
int UseAfterFreeEx(int argc)
{
    int *array = new int[100];
    delete[] array;
    return array[argc];
}

// double free
void DoubleFreeEx()
{
    char *p = (char *)malloc(32 * sizeof(char));
    printf("address: %p", p);
    free(p);
    free(p);
}
// [End hw_use_after_free]