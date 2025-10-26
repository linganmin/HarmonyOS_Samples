/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { privacyManager } from '@kit.StoreKit';

const TAG: string = 'getAppPrivacyResult';

@Entry
@Component
struct GetAppPrivacyResult {
  @State result: string = '';
  @State message: string = 'getAppPrivacyResult';
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
      let appPrivacyResults: privacyManager.AppPrivacyResult[] = privacyManager.getAppPrivacyResult();
      hilog.info(0, TAG, "getAppPrivacyResult size = " + appPrivacyResults.length);
      if (appPrivacyResults.length == 0) {
        this.result += 'privacy result is empty!';
        return;
      }
      for (let i = 0; i < appPrivacyResults.length; i++) {
        hilog.info(0, TAG, "getAppPrivacyResult type = " + appPrivacyResults[i]["type"] + ", version = " + appPrivacyResults[i]["versionCode"] + ", result = " + appPrivacyResults[i]["result"]);
        this.result += 'getAppPrivacyResult type = ' + appPrivacyResults[i]["type"] + ", result = " + appPrivacyResults[i]["result"] + ";\n";
      }
    } catch (error) {
      hilog.error(0, TAG, `getAppPrivacyResult failed. code is ${error.code}, message is ${error.message}`);
      this.result = `getAppPrivacyResult failed, error code: ${error.code}, error message: ${error.message}`;
    }
  }
}