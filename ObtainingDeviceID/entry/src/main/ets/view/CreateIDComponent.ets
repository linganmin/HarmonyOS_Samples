/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AAID } from '@kit.PushKit';
import { asset } from '@kit.AssetStoreKit';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { abilityAccessCtrl, bundleManager } from '@kit.AbilityKit';
import { identifier } from '@kit.AdsKit';

@Component
export struct CreateIDComponent {
  @State isSaveButtonActive: boolean = false;
  @State isQueryButtonActive: boolean = false;
  @State typeId: string = '';
  @State queryId: string = '';
  @State @Watch('onChange') createId: string = '';

  onChange() {
    // Control the button status based on whether createId are empty string.
    this.isSaveButtonActive = (this.createId !== '');
  }

  aboutToAppear() {
    let asset = this.queryAsset();
    // Control the button status based on whether key assets are found.
    this.isQueryButtonActive = asset.length !== 0;
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text($r('app.string.create', this.typeId))
            .width('100%')
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
            .opacity(0.6)
            .fontSize(20)
            .lineHeight(24)
        }
        .width('100%')
        .height(50)
        .padding({ top: 5 })
        .margin({ top: 8 })

        TextArea({
          text: this.createId,
          placeholder: $r('app.string.toBeCreate')
        })
          .margin({ bottom: 12 })
          .borderRadius(16)
          .lineHeight(21)
          .padding({ top: 11.5, bottom: 11.5 })
          .onChange((value: string) => {
            this.createId = value;
          })

        Button($r('app.string.create', this.typeId))
          .width('100%')
          .height(44)
          .margin({ bottom: 12 })
          .borderRadius(20)
          .backgroundColor('#0A59F7')
          .onClick(() => {
            if (this.typeId === 'ODID') {
              this.createId = deviceInfo.ODID;
            } else if (this.typeId === 'OAID') {
              this.checkPermissionGrant();
            } else if (this.typeId === 'AAID') {
              AAID.getAAID().then((data: string) => {
                this.createId = data;
              }).catch((err: BusinessError) => {
                hilog.error(0x0000, 'testTag', 'Failed to get AAID', err.code, err.message);
              })
            }
          })

        Button($r('app.string.saveToKeyAssets'))
          .width('100%')
          .height(44)
          .margin({ bottom: 24 })
          .borderRadius(20)
          .backgroundColor('#0A59F7')
          .opacity(this.isSaveButtonActive ? 1 : 0.4)
          .onClick(() => {
            if (this.isSaveButtonActive) {
              this.saveAsset();
            }
          })

        Row() {
          Text($r('app.string.queryKeyAssets'))
            .width('100%')
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
            .opacity(0.6)
            .fontSize(20)
            .lineHeight(24)
        }
        .width('100%')
        .height(50)
        .padding({ top: 5 })

        TextArea({
          text: this.queryId,
          placeholder: this.isQueryButtonActive ? '' : $r('app.string.pleaseCreateAndSaveFirst', this.typeId)
        })
          .margin({ bottom: 12 })
          .lineHeight(21)
          .padding({ top: 11.5, bottom: 11.5 })
          .onChange((value: string) => {
            this.queryId = value;
          })

        Button($r('app.string.query'))
          .width('100%')
          .height(44)
          .borderRadius(20)
          .backgroundColor('#0A59F7')
          .opacity(this.isQueryButtonActive ? 1 : 0.4)
          .onClick(() => {
            if (this.isQueryButtonActive) {
              this.queryId = this.queryAsset();
            }
          })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .title(this.typeId)
    .backgroundColor('#F1F3F5')
  }

  // save asset.
  saveAsset() {
    let attr: asset.AssetMap = new Map();
    attr.set(asset.Tag.SECRET, this.stringToArray(this.typeId));
    attr.set(asset.Tag.ALIAS, this.stringToArray(this.typeId + '_alias'));
    attr.set(asset.Tag.DATA_LABEL_NORMAL_1, this.stringToArray(this.createId));
    try {
      // Add a key asset through asset.Tag.SECRET, asset.Tag.ALIAS, and asset.Tag.DATA_LABEL_NORMAL_1.
      asset.add(attr).then(() => {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.savedToKeyAssets')
        });
        this.isQueryButtonActive = true;
      }).catch((err: BusinessError) => {
        // Code is 24000003, message is The asset already exists.
        hilog.error(0x0000, 'testTag', '%{public}s',
          `Failed to add Asset. Code: ${err.code}, message: ${err.message}`);
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', '%{public}s',
        `Failed to add Asset. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // query asset.
  queryAsset() {
    let query: asset.AssetMap = new Map();
    // Type of attribute name supported by key assets, key asset aliases and the result types returned by key asset queries are used.
    query.set(asset.Tag.ALIAS, this.stringToArray(this.typeId + '_alias'));
    query.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ALL);
    let queryAsset: string = '';
    try {
      // Search for one or more key assets that meet the criteria.
      let res: Array<asset.AssetMap> = asset.querySync(query);
      for (let i = 0; i < res.length; i++) {
        // parse the secret.
        let data: Uint8Array = res[i].get(asset.Tag.DATA_LABEL_NORMAL_1) as Uint8Array;
        queryAsset = this.arrayToString(data);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', '%{public}s',
        `Failed to query Asset. Code: ${err.code}, message: ${err.message}`);
    }
    return queryAsset;
  }

  stringToArray(str: string): Uint8Array {
    let textEncoder = new util.TextEncoder();
    return textEncoder.encodeInto(str);
  }

  arrayToString(arr: Uint8Array): string {
    let textDecoder = util.TextDecoder.create('utf-8');
    return textDecoder.decodeToString(arr);
  }

  // Check whether the permission is granted to the application.
  checkPermissionGrant() {
    let hasPermission = false;
    let tokenId: number = 0;
    try {
      // Obtain the current application's BundleInfo based on the given BundleFlags using synchronous methods.
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'testTag', '%{public}s',
        `Failed to query Asset. Code: ${err.code}, message: ${err.message}`);
    }

    try {
      let atManager = abilityAccessCtrl.createAtManager();
      // Verify whether the application has been granted permissions through tokenID and permissionName.
      let access = atManager.checkAccessTokenSync(tokenId, 'ohos.permission.APP_TRACKING_CONSENT');
      hasPermission = access === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'testTag', '%{public}s',
        `Failed to check access token. Code: ${err.code}, message: ${err.message}`);
    }

    if (hasPermission) {
      this.getOAID();
    } else {
      this.requestPermissions();
    }
  }

  // Get OAID.
  getOAID() {
    // The API is not supported on all devices. Use the canIUse condition to determine whether the API is supported.
    if (canIUse('SystemCapability.Advertising.OAID')) {
      try {
        // Obtain open anonymous device identifiers.
        identifier.getOAID().then((data) => {
          this.createId = data;
          hilog.info(0x0000, 'testTag', '%{public}s', `Success getting OAID by promise, OAID:', ${data}`);
        }).catch((err: BusinessError) => {
          hilog.error(0x0000, 'testTag', '%{public}s',
            `get oaid by promise failed, code: ${err.code}, message: ${err.message}`);
        })
      } catch (err) {
        hilog.error(0x0000, 'testTag', '%{public}s',
          `Failed to get oaid by promise, catch error: ${err.code}, ${err.message}`);
      }
    } else {
      hilog.info(0x0000, 'testTag', '%{public}s', 'Advertising not by this device.');
    }
  }

  // Request Permissions.
  requestPermissions() {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(this.getUIContext().getHostContext(),
        ['ohos.permission.APP_TRACKING_CONSENT']).then((data) => {
        hilog.info(0x0000, 'testTag', '%{public}s', `requestPermissionsFromUser: ${JSON.stringify(data)}`)
        if (data.authResults[0] === -1 && data.dialogShownResults && !data.dialogShownResults[0]) {
          // User not authorized.
          this.openPermissionsSetting();
        }
        if (data.authResults[0] !== 0) {
          // No permission obtained.
          return;
        }
        this.getOAID();
      }).catch((err: Error) => {
        hilog.error(0x0000, 'testTag', '%{public}s', `requestPermissionsFromUser err: ${JSON.stringify(err)}`);
      })
    } catch (err) {
      hilog.error(0x0000, 'testTag', '%{public}s', `requestPermissionsFromUser err: ${JSON.stringify(err)}`);
    }
  }

  // Open permissions setting.
  private openPermissionsSetting() {
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionOnSetting(this.getUIContext().getHostContext(), ['ohos.permission.APP_TRACKING_CONSENT'])
      .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
        if (data[0] === -1) {
          return;
        }
        this.getOAID();
      }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', '%{public}s', `requestPermissionOnSetting err: ${JSON.stringify(err)}`);
    })
  }
}