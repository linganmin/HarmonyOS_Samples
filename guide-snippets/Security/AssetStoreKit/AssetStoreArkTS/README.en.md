# Asset Store Kit Development (ArkTS)

### Introduction

Asset Store Kit (ASSET for short) provides a series of open APIs to securely store and manage short sensitive data, including but not limited to passwords (accounts/passwords), tokens (application credentials), and important plaintext (such as bank card numbers).

This sample primarily demonstrates scenarios from the Asset Store Kit Development (ArkTS), including adding, deleting, updating, and querying assets. The detailed description of the code demonstrated in this project can be found via the following links.

- [Adding an Asset (ArkTS)](https://docs.openharmony.cn/pages/v6.0/en/application-dev/security/AssetStoreKit/asset-js-add.md)
- [Removing Assets (ArkTS)](https://docs.openharmony.cn/pages/v6.0/en/application-dev/security/AssetStoreKit/asset-js-remove.md)
- [Updating an Asset (ArkTS)](https://docs.openharmony.cn/pages/v6.0/en/application-dev/security/AssetStoreKit/asset-js-update.md)
- [Querying Assets (ArkTS)](https://docs.openharmony.cn/pages/v6.0/en/application-dev/security/AssetStoreKit/asset-js-query.md)
- [Querying an Asset with User Authentication (ArkTS)](https://docs.openharmony.cn/pages/v6.0/en/application-dev/security/AssetStoreKit/asset-js-query-auth.md)
- [Managing Assets in a Group (ArkTS)](https://docs.openharmony.cn/pages/v6.0/en/application-dev/security/AssetStoreKit/asset-js-group-access-control.md)
- [Syncing Assets (Backup and Restore) (ArkTS)](https://docs.openharmony.cn/pages/v6.0/en/application-dev/security/AssetStoreKit/asset-js-sync.md)

### Preview

| Home Page                                                   | Execution Result                                                   |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="./screenshots/AssetStoreArkTS1.png" style="zoom: 50%;" /> | <img src="./screenshots/AssetStoreArkTS2.png" style="zoom: 50%;" /> |

### How to Use

1. Run the app.
2. The page will display the effect shown in the Home Page above. Click the buttons to manage assets correspondingly. Note that the 'Query User-Auth Asset' button requires a lock screen password to be set for a successful query.

### Project Directory

```
entry/src/
 ├── main
     ├── ets
     │   ├── entryability
     │   ├── entrybackupability
     │   ├── operations                    // Asset Store Kit Development (ArkTS) Sample Code
     │       ├── add.ets
     │       ├── add_auth.ets
     │       ├── add_group.ets
     │       ├── add_sync.ets
     │       ├── index.ets
     │       ├── query_attr.ets
     │       ├── query_auth.ets
     │       ├── query_batch_attrs.ets
     │       ├── query_group_attr.ets
     │       ├── query_group_plaintext.ets
     │       ├── query_plaintext.ets
     │       ├── query_sync_result.ets
     │       ├── remove.ets
     │       ├── remove_auth.ets
     │       ├── remove_group.ets
     │       ├── update.ets
     │       ├── update_group.ets
     │   ├── pages
     │       ├── Index.ets
     ├── module.json5
     └── resources
```

### Required Permissions

ohos.permission.ACCESS_BIOMETRIC

### Dependencies

N/A

### Constraints and Limitations

1.The sample app is supported only on Huawei phones running the standard system.

2.The HarmonyOS version must be HarmonyOS 6.0.0 or later.

3.The DevEco Studio version must be DevEco Studio 6.0.0 Release or later.

4.The HarmonyOS SDK version must be HarmonyOS 6.0.0 Release or later.