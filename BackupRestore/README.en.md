# Data Migration Based on the Backup and Restoration Framework

### Overview
This sample introduces how to migrate RDB, file, and XML data and restore the data with the help of the backup and restoration framework after the device is upgraded from HarmonyOS 4.0 to HarmonyOS 5.0.0. The [EntryBackupAbility.ets](entry/src/main/ets/entrybackupability/EntryBackupAbility.ets) file and the onRestore() method can be used to restore data.

### Preview

|               Home page                |
| :------------------------------------: |
| ![home](screenshots/devices/phone_en.gif) |

How to Use
1. Obtain the migration tool by referring to section "Developer Verification" in the adaptation process in Guidelines on Application Data Migration and Adaptation After Device Upgrade.
2. Run the hdc file send com.example.backuprestore.zip /storage/media/100/local/files/Docs/Download command to send the [com.example.backuprestore.zip](com.example.backuprestore.zip) file in the same directory to the device.
3. Refer to Simulating and Verifying Application Data Migration on HarmonyOS NEXT.
4. Tap the RDB, File, and XML Data buttons to view the migrated data.

### Project Directory

```
├──entry/src/main/ets/
│  ├──entryability
│  │  └──EntryAbility.ets                    // Entry ability
│  ├──entryability
│  │  └──EntryBackupAbility.ets              // Backup and restoration framework
│  ├──pages
│  │  └──Index.ets                           // Home page
│  ├──restore
│  │  ├──db
│  │  │  └──DbTransferManager.ets            // RDB data restoration
│  │  ├──fileMigrate
│  │  │  └──FileTransferManager.ets          // File data restoration
│  │  └──sp
│  │     └──SpTransferManager.ets            // XML data restoration
│  └──view
│     ├──FileShow.ets                        // File data show
│     ├──RdbDataShow.ets                     // RDB data show
│     └──XMLDataShow.ets                     // XML data show
└──entry/src/main/resources                  // Static resources of the app

```

### How to Implement

1. The entry of the application backup and restoration framework is implemented by the EntryBackupAbility.ets file. The onRestore() method is used to restore data.
2. RDB data restoration is implemented by the DbTransferManager.ets file.
3. File data restoration is implemented by the FileTransferManager.ets file.
4. XML data restoration is implemented by the SpTransferManager.ets file.

### Permissions

N/A

### Dependencies

N/A

### Constraints

1. The sample is only supported on Huawei phones with standard systems.

2. The HarmonyOS version must be HarmonyOS 5.0.5 Release.

3. The DevEco Studio version must be DevEco Studio 5.0.5 Release.

4. The HarmonyOS SDK version must be HarmonyOS 5.0.5 Release SDK.