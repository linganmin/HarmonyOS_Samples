/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { updateManager } from '@kit.AppGalleryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'CheckUpdatePage';

@Entry
@Component
struct Index {
  @State messageShowDialog: string | Resource = '';
  @State messageCheckUpdate: string | Resource = '';

  /**
   * Show the update pop-up.
   */
  private showUpdateDialog() {
    try {
      this.messageShowDialog = $r('app.string.messageShowDialog');
      const uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      updateManager.showUpdateDialog(uiContext)
        .then((resultCode: updateManager.ShowUpdateResultCode) => {
          hilog.info(0, TAG, "showUpdateDialog resultCode:" + JSON.stringify(resultCode));
          this.messageShowDialog = JSON.stringify(resultCode);
        })
        .catch((error: BusinessError) => {
          hilog.error(0, TAG, `showUpdateDialog error.code is ${error.code}, message is ${error.message}`);
          this.messageShowDialog = JSON.stringify(error);
        });
    } catch (error) {
      hilog.error(0, TAG, `showUpdateDialog error.code is ${error.code}, message is ${error.message}`);
      this.messageShowDialog = JSON.stringify(error);
    }
  }

  /**
   * Check for updates.
   */
  private checkUpdate() {
    try {
      this.messageCheckUpdate = $r('app.string.messageCheckUpdate');
      const uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      updateManager.checkAppUpdate(uiContext)
        .then((checkResult: updateManager.CheckUpdateResult) => {
          hilog.info(0, TAG, "checkResult updateAvailable: " + checkResult.updateAvailable);
          this.messageCheckUpdate = JSON.stringify(checkResult);
        }).catch((error: BusinessError) => {
        hilog.error(0, TAG, `checkUpdate error.code is ${error.code}, message is ${error.message}`);
        this.messageCheckUpdate = JSON.stringify(error);
      });
    } catch (error) {
      hilog.error(0, TAG, `checkUpdate error.code is ${error.code}, message is ${error.message}`);
      this.messageCheckUpdate = JSON.stringify(error);
    }
  }

  build() {
    Row() {
      Column() {
        Text($r('app.string.updateSdkTitle'))
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.JUSTIFY)
          .width(300)

        Button($r('app.string.showUpdateDialog'))
          .height(34)
          .fontSize(14)
          .margin({ top: 40 })
          .onClick(() => {
            this.showUpdateDialog();
          })
        Text(this.messageShowDialog)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.JUSTIFY)
          .width(300)
        Button($r('app.string.checkAppUpdate'))
          .height(34)
          .fontSize(14)
          .margin({ top: 40 })
          .onClick(() => {
            this.checkUpdate();
          })
        Text(this.messageCheckUpdate)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.JUSTIFY)
          .width(300)
      }
      .width('100%')
    }
    .height('100%')
  }
}