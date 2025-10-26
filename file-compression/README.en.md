# File Compression and Decompression in Different Paths

### Overview

This sample shows how to use the interfaces provided by the third-party libraries @ohos.file.fs and @ohos/commons-compress to compress and decompress files in ZIP, GZIP, TAR, and 7Z formats in different paths.

### Preview

![](screenshots/device/phone_EN.gif)

### How to Use

1. Touch **Preview** to preview the text content. Touch **Compress** and select a compression format to decompress the file.
2. Touch **Decompress** to decompress the compressed file. The decompressed file is saved in the **/decompressedFile** directory. Repeated decompression will overwrite the existing file.
3. Touch **Import from rawfile** to import a file from **rawfile**. You can preview, compress, and decompress the file.

### Project Directory

```
handletabs
│  ├──constant
│  │  └──FileConstants.ets
│  ├──entryability
│  │  └──EntryAbility.ets                        // Entry ability
│  ├──model
│  │  └──FileItem.ets                            // File class
│  ├──pages
│  │  └──Index.ets                               // Home page
│  ├──utils
│  │  ├──CompressUtil.ets                        // Compression utility class
│  │  ├──FileUtil.ets                            // File utility class
│  │  └──Logger.ets                              // Log utility
│  └──view
│     └──DialogView.ets                          // Dialog box view
└────entry/src/main/resources 
```

### Required Permissions
N/A

### Dependencies
The **common-compress** package has been installed by running the **ohpm install @ohos/commons-compress** command.

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.