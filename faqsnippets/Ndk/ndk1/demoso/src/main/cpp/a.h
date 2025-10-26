//
// Created on 2025/5/29.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
/**
 * FAQ:多so相互依赖场景下如何解耦
 */
// [Start demo_so]
// a.h
extern "C" {
#ifndef DemoSO_a_H
#define DemoSO_a_H
int add(int a, int b);
int getb(char *path, int a, int b);
#endif // DemoSO_a_H
}
// [End demo_so]