# Basic Data Type Conversion

## Overview

This sample shows how to use DevEco Studio to create a native C++ app, pass ArkTS data (of basic data types) to native for processing, and return the result to ArkTS.

## Preview

![synchronized_operation](screenshots/device/data_conversion.en.gif)

### Project Directory

```
├──conversion/src/main/cpp                    // C++ code
│  ├──types
│  │  └──libconversion                        // C++ APIs
│  │     ├──index.d.ts                        
│  │     └──oh-package.josn5                 
│  ├──ArraybufferType.cpp                     // ArrayBuffer conversion
│  ├──ArraybufferType.h                       
│  ├──ArrayType.cpp                           // Array conversion
│  ├──ArrayType.h
│  ├──CMakeLists.txt                          // CMake file
│  ├──DateType.cpp                            // Date conversion
│  ├──DateType.h
│  ├──hello.cpp                               // Native module                             
│  ├──NumberType.cpp                          // Number conversion
│  ├──NumberType.h                          
│  ├──ObjectType.cpp                          // Object conversion
│  ├──ObjectType.h                            
│  ├──StringBoolType.cpp                      // string and boolean type conversion
│  └──StringBoolType.h                        
├──conversion/src/main/ets                    // ets code
│  ├──common
│  │  ├──constants  
│  │  │  └──CommonConstants.ets               // Constants
│  │  └──utils
│  │     └──Logger.ets                        // Logging utility
│  ├──conversionability
│  │  └──ConversionAbility.ets       
│  └──pages
│     ├──ArraybufferType.ets                  // ArrayBuffer conversion page
│     ├──ArrayType.ets                        // Array conversion page
│     ├──DateType.ets                         // Date conversion page
│     └──Index.ets                            // Home page
│     ├──NumberType.ets                       // Number conversion type
│     ├──ObjectType.ets                       // Object conversion type
│     ├──StringBoolType.ets                   // String and boolean type conversion page
│     └──Types.ts                             // object APIs
└──entry/src/main/resources                   // Static resources of the app
```

## How to Use

1. On the home page, tap different types of data conversion to go to the corresponding data conversion pages.

2. Process data.
   
   - Add data of int type. 
     Use **napi_get_value_int32()** and **napi_create_int32 ()** to obtain and construct int data, respectively.
   
   - Concatenate strings (data of string type and boolean type) 
     Use **napi_get_value_string_utf8()**, **napi_get_value_bool()**, and **napi_create_string_utf8()**.
   
   - Obtain an array in reverse order (data of arr type). 
     Use **napi_get_array_length()**, **napi_create_array_with_length()**, **napi_get_element ()**, and **napi_set_element ()**. Obtain the length of the array, and then construct an array of the length obtained. Use **napi_get_element()** to obtain the value of each element in an array, and use **napi_set_element ()** to assign a value to each element.
   
   - Calculate the square for an **ArrayBuffer** (data of the **ArrayBuffer** type). 
     Use **napi_get_arraybuffer_info()** and **napi_create_external_arraybuffer()**. Use **napi_get_arraybuffer_info()** to obtain the pointer to the underlying buffer and the pointer length. To modify data, use **reinterpret_cast** to convert the pointer to a uint pointer and modify data. After the modification, use **reinterpret_cast** to convert the pointer back to a viod pointer. The pointer is referenced when **napi_create_external_arraybuffer()** is called to construct a new **ArrayBuffer**.
   
   - Assign a value to an object (data of the object type). 
     Use **napi_create_object ()** and **napi_set_named_property()**. You need to construct an object and use **napi_set_named_property()** to assign a value to a property of the object.
   
   - Convert data of the date type. 
     Use **napi_create_date ()** to create an object of the date type, and use **napi_get_date_value()** to parse the object.

## Concepts

- Node-API: Node-API, formerly known as N-API), provides a set of APIs for building native addons in Node.js. It allows developers to write C/C++ code that interacts with JavaScript code. Currently, only some Node-API interfaces are supports.
- Currently, the following Node-API standard libraries are supported: C Standard Library, C++ library, OpenSL ES, and zlib.

## Required Permissions

N/A

## Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
