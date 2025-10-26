# Previewing PDF Files Using the Web Component

### Overview

This sample shows how to use the **Web** component to preview local and online PDF files. The **Tabs** container component contains two independent **TabContent** subcomponents, which are used to preview local PDF files and online PDF files respectively. Each subcomponent is equipped with a built-in **Web** component. The first **Web** component previews the local PDF files by using the resource protocol to associate the paths of the local PDF files. The second **Web** component loads and previews the online PDF files by configuring the network connection properties.

### Preview

![](screenshots/device/WebPDFViewer_EN.gif)


##### How to Use

- Before running the code, replace **REMOTE_URL** in the [VideoPlay.ets](entry/src/main/ets/constants/CommonConstants.ets) file with the address of the online PDF file.
- By default, the local PDF file is previewed on the page. You can click the **Preview online PDF** button to preview online PDF files.

### Project Directory

```
├──entry/src/main/ets/
│  ├──constants
│  │  └──CommonConstants.ets         // Common constant class
│  ├──entryability
│  │  └──EntryAbility.ets            // Entry point class
│  ├──pages
│  │  └──Index.ets                   // App home page
│  └──utils
│     └──Logger.ets                  // Logger
└──entry/src/main/resources          // Static resources
```

### How to Implement

1. Load the local PDF files using the resource protocol. Specifically, add the PDF files obtained through **RESOURCE_URL** to the **resources/rawfile** directory of the project. In this case, the local PDF files can be loaded and previewed without network connection.
2. Load the online PDF files by setting network connection properties, which can connect to the PDF resources on the Internet. You can also load and preview PDF resources on the cloud by providing valid URLs (**REMOTE_URL**) of the remote PDF files.

### Required Permissions

- **ohos.permission.INTERNET**, which allows an app to access the Internet.

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.
