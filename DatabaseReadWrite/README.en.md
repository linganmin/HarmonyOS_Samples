# Using C APIs to Read/Write a Relational Store

### **Overview**

This sample shows how to use C APIs to add, delete, modify, and query a relational store.

### **Preview**

|                           Home Page                            |                    Adding/Editing Offerings                    |                      Filtering Offerings                       |
|:--------------------------------------------------------------:|:--------------------------------------------------------------:|:--------------------------------------------------------------:|
| <img src=./screenshots/pic1_en.png align="center" width=320 /> | <img src=./screenshots/pic2_en.png align="center" width=320 /> | <img src=./screenshots/pic3_en.png align="center" width=320 /> |

### **How to Use**

1. Tap **Add** to add an offering. After you tap **Submit**, the added offering information is displayed on the home page.
2. Tap the edit icon to modify the information of an offering in the current list. After you tap **Submit**, the modified offering information is displayed on the home page.
3. Tap the delete icon to delete an offering from the current list. After the deletion, the remaining offering information is displayed on the home page.
4. Tap **Offering** to filter offerings by category. Mate 60/Mate 40 series offerings can be filtered and displayed in the offering list.
5. Tap **Price** to filter offerings by price and display them on the home page.
6. Tap the refresh icon to clear the filters. All offerings are displayed.

### **How to Implement**

This sample consists of the following two parts:

- Encapsulate an RDB store using the NDK：

  (1) Encapsulate an RDB store using the NDK.

  (2) Code files: **RDB.h** and **RDB.cpp**.

  (3) For details, see [RelationalStore Development (C/C++)](https://developer.huawei.com/consumer/en/doc/harmonyos-guides-V5/native-relational-store-guidelines-V5), [Getting Started with the NDK](https://developer.huawei.com/consumer/en/doc/harmonyos-guides-V5/ndk-development-overview-V5).

- Implement data interaction between ArkUI and C/C++:

  (1) Implement data interaction between ArkUI and C/C++.

  (2) Code files: **napi_init.cpp**, **index.ets**, and **oh_modules/libentry.so/index.d.ts**.

  (3) For details, see [Getting Started with the NDK](https://developer.huawei.com/consumer/en/doc/harmonyos-guides-V5/ndk-development-overview-V5).

### **Project Directory**

```c++
 ├───entry/src/main/ets        
 │   ├───constant       
 │   │   └───FileConstants.ets                      // Encapsulation constants 
 │   ├───entryability 
 │   │   └───EntryAbility.ets                       // Ability lifecycle callbacks 
 │   ├───entrybackupability 
 │   │   └───EntryBackupAbility.ets                 // Backup ability lifecycle callbacks 
 │   ├───model 
 │   │   └───GoodModel.ets                          // Encapsulation offering class 
 │   └───pages 
 │       ├───Index.ets                              // Home page 
 │       └───GoodsList.ets                          // Offering list page 
 ├───entry/src/main/cpp   
 │   ├───types/libentry/Index.d.ts                  // Function and type declarations 
 │   ├───RDB.h									    // Encapsulated RDB 
 │   ├───RDB.cpp									// Encapsulated RDB 
 │   └───napi_init.cpp                              // Custom NDK functions encapsulated to ArkUI. 
 └───entry/src/main/resources                       // Static resources of the app
```

### **Permissions**

N/A

### **Dependencies**

N/A

### **Constraints**

1. The sample is only supported on Huawei phones with standard systems.
2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.

