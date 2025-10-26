# Database Update

### Overview

This sample shows how to perform operations on a relational database (RDB) store, including adding, deleting, modifying, and querying data and performing database transactions.

For details, see RDB store.


### Preview
![image](screenshots/device/DataBaseUpgrade_en.gif)

### How to Use

1. Tap the drop-down list box, select an option, and enter the field to add.
2. Tap **Update**. The progress bar is displayed. If you tap the cross (x) icon before the progress bar reaches 100%, a transaction rollback is performed. As a result, the user information is not updated.
3. Tap **Update**. The progress bar is displayed. If the progress bar reaches 100%, the transaction is committed and the user information and the backup RDB store are updated.

4. Tap **Roll back**. The RDB store will be rolled back to the previous version.

   You may need to roll back an RDB store when an error occurs during database execution. The RDB store can be rolled back to its previous version only. If the RDB store is updated, you can roll back to the latest version.



### Project Directory
```
├──entry/src/main/ets/
│  ├──common
│  │  ├──constants
│  │  │  └──CommonConstants.ets             // Common constants
│  │  └──utils
│  │     ├──CommonUtils.ets                 // Utility for displaying pop-up dialogs
│  │     ├──DBUtils.ets                     // Utility for database operations
│  │     └──Logger.ets                      // Logging utility
│  ├──entryability
│  │  └──EntryAbility.ets                   // Entry ability
│  ├──pages
│  │  └──Index.ets                          // Home page
│  ├──view
│  │  └──ProgressDialog.ets                 // Implementation of the progress bar.
│  └──viewmodel
│     └──userInfo.ets                       // Class holding user information
└──entry/src/main/resources                 // Static resources of the app
```
### How to Implement

* The functionalities in this sample are based on the RDB store.
* The operation of adding field values is implemented based on **executeSql**.
* The transaction operations are implemented by **commit()** and **rollback()**.
* Version rollback is implemented based on RDB backup and restore. When the version is updated, the database is backed up. When the version is rolled back, the database is restored.

### Required Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample app is supported only on Huawei phones running the standard system.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release or later.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release or later.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release or later.

