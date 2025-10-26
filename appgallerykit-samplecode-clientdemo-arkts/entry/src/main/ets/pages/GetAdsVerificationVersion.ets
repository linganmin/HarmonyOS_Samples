/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { sceneManager } from '@kit.AppGalleryKit';

const TAG: string = 'getAdsVerificationVersion';

@Entry
@Component
struct GetAdsVerificationVersion {
  @State result: string = '';
  @State message: string = 'getAdsVerificationVersion';
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
    try {
      const version: string = sceneManager.getAdsVerificationVersion().toString();
      this.result = 'Ads verify version：' + version;
    } catch (error) {
      hilog.error(0, TAG, `getAdsVerificationVersion failed. code is ${error.code}, message is ${error.message}`);
    }
  }
}