//
// Created on 2025/5/22.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
/**
 * FAQ: 如何导出C++自定义类，导出后如何在ArkTS侧进行类方法调用
 */
#ifndef NDK1_MYDEMO_H
#define NDK1_MYDEMO_H
#include "string"
// [Start native_class_mydome]
// MyDemo.h Define C++classes
class MyDemo { 
  public: 
    MyDemo(std::string m_name); 
    MyDemo(); 
    ~MyDemo();   
    std::string name; 
    int add(int a, int b); 
    int sub(int a, int b); 
};
// [End native_class_mydome]
#endif //NDK1_MYDEMO_H
