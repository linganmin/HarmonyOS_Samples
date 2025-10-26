# Pako Compression and Decompression

### Overview

This sample demonstrates the compression and decompression features. It compresses a string into a file. It also decompresses the file to read and display the string.

## How to Install

```
  ohpm install pako
  ohpm install @types/pako --save-dev  // Install @types/pako to prevent import syntax errors due to missing type declarations in the pako package.
```

### Preview
![image](screenshots/device/StreamCompression_EN.gif)

### How to Use

1. Enter a string in the text box, touch the **Compress and save** button. The file management page is displayed, the string is compressed, and a compressed file is created.

2. Touch the **Decompress and read** button. The file management page is displayed. After you select the compressed file, the file is decompressed and a string is displayed.


### Project Directory
```
├──entry/src/main/ets/
│  ├──common
│  │  ├──constants
│  │  │  └──CommonConstants.ets             // Common constants
│  │  └──utils
│  │     ├──CommonUtils.ets                 // Common util class
│  │     ├──CompressionUtils.ets            // Compression and decompression utility class
│  │     └──Logger.ets                      // Log utility
│  ├──entryability
│  │  └──EntryAbility.ets                   // Entry ability
│  └──pages
│     ├──Index.ets                          // Home page
└──entry/src/main/resources                 // Static resources
```
### How to Implement

The compression and decompression functions is implemented by referring to the third-party JS library [pako](https://github.com/nodeca/pako). Pako supports compression and decompression of code in gzip and deflate formats.

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.
