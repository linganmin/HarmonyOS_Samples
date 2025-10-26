# Printing Logs

### Overview

This sample shows how to use the loggers of the HiLog system so that your app or service can output logs based on the specified level, ID, and string format, helping you understand the running status of your app or service and better debug it.

### Preview
| Home page                                    |
|----------------------------------------|
| ![image](screenshots/device/index.png) |

Instructions:

1. Access the application and an empty log file is automatically generated.

2. Click the **log** button to export logs to a log file.

### Project Directory
```
├──entry
│  ├──src/main/ets
│  │  ├──entryability
│  │  │  └──EntryAbility.ets           // Entry ability
│  │  └──pages           
│  │     └──Index.ets                  // Home page
│  └──src/main/resources               // Static resources
└──log
   ├──src/main/ets
   │  └──components	                    
   │     └──mainpage                   
   │  	    ├──Configure.ets		   // Configuration items of the logger
   │        ├──Configure.ts            // Configure type
   │        ├──Logger.ets              // Logger
   │        ├──LoggerModel.ts          // Encapsulation of the logger
   │        └──LogLevel.ts             // Enums of the log level
   └──src/main/resources               // Static resources
```

### How to Implement
+ The log output function is encapsulated in the Logger. For details about the source code, see [Logger.ets](log/src/main/ets/components/mainpage/Logger.ets).
    + Output logs. The **Logger** class classifies logs into three types based on the **types** parameter of **Configure**. For the **file** type, logs are written into local files. For the **console** type, logs are output by calling the **ConsoleLoggerStrategy** class. For the **hilog** type, logs are output by calling the **HilogLoggerStrategy** class.
    + Write log files to the local host. The **FileLoggerStrategy** class uses **@ohos.file.fs** to write logs to a local file. This sample only shows how to write logs to a file. In practice, you are advised to run time-consuming operations in subthreads.

### Required Permissions

N/A

### Dependency

N/A

### Constraints

1. The sample is supported only on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.