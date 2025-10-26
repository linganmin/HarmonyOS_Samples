/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { privacyManager } from '@kit.AppGalleryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'requestAppPrivacyConsent';

@Entry
@Component
struct RequestAppPrivacyConsent {
  @State message: string = 'requestAppPrivacyConsent';
  build() {
    Column() {
      Button(this.message)
        .onClick(() => {
          this.query()
        })
        .width('100%')
    }
    .margin(16)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  query() {
    try {
      hilog.info(0, TAG, "requestAppPrivacyConsent start!");
      const uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      privacyManager.requestAppPrivacyConsent(uiContext).then((consentResult : privacyManager.ConsentResult) => {
        let appPrivacyResults: privacyManager.AppPrivacyResult[] = consentResult["results"];
        for (let i = 0; i < appPrivacyResults.length; i++) {
          hilog.info(0, TAG, "GetAppPrivacyResult type = " + appPrivacyResults[i]["type"] + ", version = " + appPrivacyResults[i]["versionCode"] + ", result = " + appPrivacyResults[i]["result"] + ", signingTimeStamp = " + appPrivacyResults[i]["signingTimeStamp"]);
        }
      }).catch((error: BusinessError<Object>) => {
        hilog.error(0, TAG, `requestAppPrivacyConsent failed, Code: ${error.code}, message: ${error.message}`);
      });
    } catch (error) {
      hilog.error(0, TAG, "requestAppPrivacyConsent exception code: " + error.code + ", exception message: " + error.message);
    }
  }
}