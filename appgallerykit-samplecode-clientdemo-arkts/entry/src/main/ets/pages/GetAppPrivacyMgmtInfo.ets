/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { privacyManager } from '@kit.AppGalleryKit';

const TAG: string = 'getAppPrivacyMgmtInfo';

@Entry
@Component
struct GetAppPrivacyMgmtInfo {
  @State result: string = '';
  @State message: string = 'getAppPrivacyMgmtInfo';
  build() {
    Column() {
      Button(this.message)
        .onClick(() => {
          this.query()
        })
        .width('100%')
      Text(this.result)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .margin(20)
    }
    .margin(16)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  query() {
    this.result = '';
    try {
      let appPrivacyManageInfo: privacyManager.AppPrivacyMgmtInfo = privacyManager.getAppPrivacyMgmtInfo();
      hilog.info(0, TAG, "GetAppPrivacyManageInfo type:" + appPrivacyManageInfo["type"]);
      this.result += 'GetAppPrivacyManageInfo type：' + appPrivacyManageInfo["type"] + ";\n";
      let privacyLinkInfoArray : privacyManager.AppPrivacyLink[] = appPrivacyManageInfo.privacyInfo;
      hilog.info(0, TAG, "GetAppPrivacyManageInfo size = " + privacyLinkInfoArray.length);
      for (let i = 0; i < privacyLinkInfoArray.length; i++) {
        this.result += 'uri: ' + privacyLinkInfoArray[i]["url"] + ";\n";
      }
    } catch (error) {
      hilog.error(0, TAG, `getAppPrivacyMgmtInfo failed. code is ${error.code}, message is ${error.message}`);
      this.result = `getAppPrivacyMgmtInfo failed, error code: ${error.code}, error message: ${error.message}`;
    }
  }
}