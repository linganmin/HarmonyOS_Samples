# Large File Copy

### Overview

File copy is a common scenario in application development. To copy files, you can either read and write all content of a file directly or use the buffer to read and write the file for multiple times. The former is easy to use, but the memory usage is high in large file copy scenarios, affecting application performance. The latter uses less memory usage, but the programming is more complex. This sample shows how to use the buffer to copy the rawfile of a large file to the application sandbox.

### Preview
![Index](screenshot/LargeFileCopy_EN.gif)

### Project Directory
```
├──entry/src/main/ets               
│  ├──constants
│  │  └──BigFileCopyConstants.ets        // Constant class               
│  ├──entryability  
│  │  └──EntryAbility.ets               // Entry point class
│  └──view                              
│     └──Index.ets                      // Home page
└──entry/src/main/resources             // App resource directory
```

How to Use

1. Tap the copy button to start copying.
2. When the copy progress reaches 100%, tap the preview button to verify the file replication.
3. If you want to repeatedly verify this scenario, tap the reset button after the copy is complete to reset the progress and then perform subsequent verification.

### Required Permissions

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.

