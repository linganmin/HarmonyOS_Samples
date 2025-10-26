# 实现ArkTS侧基础类型转化为Native侧数据类型功能

## 简介

本示例介绍如何使用DevEco Studio创建一个Native C++应用，将ArkTS侧的数据（基础的数据类型）传递到Native侧进行处理并返回结果到ArkTS侧。
界面如下所示：

![synchronized_operation](screenshots/device/data_conversion.gif)

## 工程目录

```
├──conversion/src/main/cpp                    // C++ 代码区
│  ├──types
│  │  └──libconversion                        // C++接口导出
│  │     ├──index.d.ts                        
│  │     └──oh-package.josn5                 
│  ├──ArraybufferType.cpp                     // Arraybuffer类型转换
│  ├──ArraybufferType.h                       
│  ├──ArrayType.cpp                           // 数组类型转换
│  ├──ArrayType.h
│  ├──CMakeLists.txt                          // CMake配置文件
│  ├──DateType.cpp                            // Date类型转换
│  ├──DateType.h
│  ├──hello.cpp                               // Native模块注册                             
│  ├──NumberType.cpp                          // number类型转换
│  ├──NumberType.h                          
│  ├──ObjectType.cpp                          // Object类型转换
│  ├──ObjectType.h                            
│  ├──StringBoolType.cpp                      // string,bool类型转换
│  └──StringBoolType.h                        
├──conversion/src/main/ets                    // ets 代码区
│  ├──common
│  │  ├──constants  
│  │  │  └──CommonConstants.ets               // 常量定义文件
│  │  └──utils
│  │     └──Logger.ets                        // 日志类
│  ├──conversionability
│  │  └──ConversionAbility.ets       
│  └──pages
│     ├──ArraybufferType.ets                  // Arraybuffer类型转换界面
│     ├──ArrayType.ets                        // 数组类型转换界面
│     ├──DateType.ets                         // Date类型转换页面
│     ├──Index.ets                            // 主页界面
│     ├──NumberType.ets                       // number类型转换界面
│     ├──ObjectType.ets                       // Object类型转换界面
│     ├──StringBoolType.ets                   // string,bool类型转换界面
│     └──Types.ts                             // object接口声明
└──entry/src/main/resources                   // 应用资源目录
```

## 使用说明

1. 主页面：点击不同场景进入到不同类型的数据转化实例。
2. 子页面：
   - 场景一：int类型加法(int类型数据)。主要通过napi_get_value_int32()函数与napi_create_int32()函数、分别获取int型数据和构造int型数据。
   - 场景二：string类型拼接(string类型数据和bool类型数据)。主要通过napi_get_value_string_utf8()、napi_get_value_bool()、以及napi_create_string_utf8()函数实现、与场景一用法类似。
   - 场景三：数组逆序(arr类型数据)。主要使用napi_get_array_length()、napi_create_array_with_length()、napi_get_element()和napi_set_element()函数。与场景一二的区别是先获取数组长度、然后构建相应长度的数组。针对数组的每一项元素值通过napi_get_element()获取、每一项元素赋值时使用napi_set_element()实现。
   - 场景四：arraybuffer求平方(arraybuffer类型数据)。主要使用napi_get_arraybuffer_info()、napi_create_external_arraybuffer()函数。区别在于napi_get_arraybuffer_info()获取的是底层缓冲区指针和指针长度。对于数据的修改需要利用reinterpret_cast将指针转化为uint型指针进行数据修改，修改后还需利用reinterpret_cast将指针转换回viod指针，该指针在napi_create_external_arraybuffer()构造新的arraybuffer时被引用。
   - 场景五：object对象赋值(object类型)。主要使用napi_create_object()、napi_set_named_property()函数、区别在于需要先构造出object对象、然后利用napi_set_named_property()函数对object对象的某个属性进行赋值操作。
   - 场景六：Date类型转换。主要使用napi_create_date()、napi_get_date_value()函数，创建、解析Date类型的对象。

## 相关概念

- NAPI：NAPI提供的接口名与三方Node.js一致，目前支持部分接口。
- NAPI中支持的标准库：目前支持标准C库、C++库、OpenSL ES、zlib。

## 相关权限

不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
