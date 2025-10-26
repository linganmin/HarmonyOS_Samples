//
// Created on 2025/5/29.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
/**
 * FAQ:多so相互依赖场景下如何解耦
 */
// [Start demo_so]
// b.h
extern "C" {
#ifndef DemoSO_b_H
#define DemoSO_b_H
int sub(int a, int b);
int geta(char *path, int a, int b);
#endif // DemoSO_b_H
}
// [End demo_so]