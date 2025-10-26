/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { TipsDialog } from '@kit.ArkUI';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, bundleManager, PermissionRequestResult } from '@kit.AbilityKit';
import { BreakpointType, CommonConstants } from '../common/CommonConstants';
import Logger from '../common/Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @StorageLink('bottomHeight') bottomRectHeight: number = 0;
  @StorageLink('statusBarHeight') topRectHeight: number = 0;
  @StorageProp('currentBreakpoint') curBp: string = CommonConstants.BREAK_POINT_SM;
  @State uri: string = '';
  scroller: Scroller = new Scroller();
  pageStack: NavPathStack = new NavPathStack();

  // [Start share]
  onPageShow(): void {
    let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    try {
      let result: boolean = systemPasteboard.hasDataType(pasteboard.MIMETYPE_TEXT_URI);
      if (result) {
        this.checkPermissionGrant();
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, '[Home]',
        `Check data type failed. Code is ${err.code}, message is ${err.message}`);
    }
  }

  checkPermissionGrant(): void {
    let hasPermission = false;
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, '[Home]',
        `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    try {
      let atManager = abilityAccessCtrl.createAtManager();
      let approximatelyLocation = atManager.checkAccessTokenSync(tokenId, 'ohos.permission.READ_PASTEBOARD');
      hasPermission = approximatelyLocation === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, '[Home]', `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
    if (hasPermission) {
      let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.getData().then((pasteData: pasteboard.PasteData) => {
        this.uri = pasteData.getPrimaryUri();
        if (this.uri === 'PageABuilder' || this.uri === 'PageBBuilder') {
          this.dialogControllerImage.open();
        }
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, '[Home]', 'Failed to get PasteData. Cause: ' + err.message);
      })
    } else {
      hilog.error(0x0000, '[Home]', 'The app is not authorized.');
      this.requestPermissionsFn();
    }
  }
  // [End share]

  requestPermissionsFn(): void {
    let atManager = abilityAccessCtrl.createAtManager();
    let context: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    atManager.requestPermissionsFromUser(context, [
      'ohos.permission.READ_PASTEBOARD'
    ]).then((data: PermissionRequestResult): void => {
      Logger.info('[Home]', 'request Permissions success!');
      if (data.authResults.toString() === '0') {
        let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
        systemPasteboard.getData().then((pasteData: pasteboard.PasteData) => {
          this.uri = pasteData.getPrimaryUri();
          if (this.uri === 'PageABuilder' || this.uri === 'PageBBuilder') {
            this.dialogControllerImage.open();
          }
        }).catch((err: BusinessError) => {
          Logger.error('[Home]', 'Failed to get PasteData. Cause: ' + err.message);
        })
      }
    }).catch((error: BusinessError): void => {
      Logger.info('[Home]', `requestPermissionsFromUser call Failed! error: ${error.code}`);
    });
  }

  dialogControllerImage: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      content: $r('app.string.reason_router'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          Logger.info('[Home]', 'Callback when the first button is clicked');
          let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
          systemPasteboard.clearData();
        }
      },
      secondaryButton: {
        value: $r('app.string.jumping'),
        action: () => {
          this.pageStack.pushPathByName(this.uri, null, false);
          let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
          systemPasteboard.clearData();
        }
      },
      onCheckedChange: () => {
        Logger.info('[Home]', 'Callback when the checkbox is clicked');
      }
    }),
  })

  build() {
    Navigation(this.pageStack) {
      Column() {
        Button($r('app.string.button_jump'))
          .fontSize(16)
          .width(this.curBp === 'sm' ? CommonConstants.FULL_PERCENT : 448)
          .height(40)
          .margin({ bottom: $r('sys.float.padding_level6') })
          .backgroundColor($r('sys.color.brand'))
          .onClick(() => {
            this.pageStack.pushPathByName('ShareDirectBuilder', null, false);
          })

        Button($r('app.string.button_mixed'))
          .fontSize(16)
          .width(this.curBp === 'sm' ? CommonConstants.FULL_PERCENT : 448)
          .height(40)
          .margin({ bottom: $r('sys.float.padding_level6') })
          .backgroundColor($r('sys.color.brand'))
          .onClick(() => {
            this.pageStack.pushPathByName('PasteBoardBuilder', null, false);
          })

        Button($r('app.string.button_progress'))
          .fontSize(16)
          .width(this.curBp === 'sm' ? CommonConstants.FULL_PERCENT : 448)
          .height(40)
          .margin({ bottom: $r('sys.float.padding_level6') })
          .backgroundColor($r('sys.color.brand'))
          .onClick(() => {
            this.pageStack.pushPathByName('ProgressBarBuilder', null, false);
          })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)
      .padding({
        right: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level0'),
          $r('sys.float.padding_level0')).GetValue(this.curBp),
        left: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level0'),
          $r('sys.float.padding_level0')).GetValue(this.curBp)
      })
    }
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
    .title($r('app.string.title'))
    .padding({
      top: this.topRectHeight,
      bottom: this.bottomRectHeight,
      right: new BreakpointType($r('sys.float.padding_level0'), $r('sys.float.padding_level4'),
        $r('sys.float.padding_level8')).GetValue(this.curBp),
      left: new BreakpointType($r('sys.float.padding_level0'), $r('sys.float.padding_level4'),
        $r('sys.float.padding_level8')).GetValue(this.curBp)
    })
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}