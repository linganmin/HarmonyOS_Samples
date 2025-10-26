# Social Sharing Redirection Based on App Linking

### Overview

This sample shows how to implement a social application based on App Linking. You can share the App Linking link of the article details to friends (MeeTime friends) through Share Kit. They can tap the link to jump to the article details, improving user experience. When the social application is not installed, your friends can tap the link to go to the article details page or AppGallery for installation.

### Effect

![image](screenshots/devices/image.en.gif)

**How to Use**

1.	Before running your project, configure App Linking and manually sign your application. For details, see [Using App Linking for App-to-App Redirection](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/app-linking-startup).
2.	Open the [Detail.ets](entry/src/main/ets/pages/Detail.ets) file, replace the content parameter in the share() method with a valid link, and change the host field of uris in the [module.json5](./entry/src/main/module.json5) file to a valid domain name.
3.	Start the application, and tap an article on the home page to go to the details page.
4.	Tap the share button in the upper right corner of the details page to start the share panel and share the article to a MeeTime friend.
5.	The friend can tap the MeeTime message to jump to the article page.

### Project Structure

```
├──entry/src/main/ets                           // Code 
│  ├──common 
│  │  ├──LazyDataSource.ets                     // Data source management for lazy loading 
│  │  └──Logger.ets                             // Logger 
│  ├──entryability 
│  │  └──EntryAbility.ets                       // Entry point 
│  ├──entrybackupability 
│  │  └──EntryBackupAbility.ets                 // Data backup and restoration 
│  ├──model
│  │  └──Article.ets                            // Article entity class
│  ├──pages 
│  │  ├──Detail.ets                             // Article details page 
│  │  └──Index.ets                              // Application entry page 
│  └──view 
│     └──IArticleItem.ets                       // Article list item component 
└──service 
   ├──detail                                    // Web details page of the article, which is deployed on the server 
   └──index                                     // Web page corresponding to App Linking    
```

### How to Implement

* Use the systemShare module of Share Kit to implement the sharing feature.
* When an application is launched for the first time, deferredLink.popDeferredLink() is used to obtain the application link tapped by the user and redirect the user to the details page based on the parameters in the link.
* Configure direct access to AppGallery in AppGallery Connect in case the application is not installed.

### Required Permissions

**N/A**

### Module Dependencies

**N/A**

### Constraints

1.	This sample is only supported on Huawei phones with standard systems.
2.	The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.
3.	The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.
4.	The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK or later.