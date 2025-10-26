/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { privacyManager } from '@kit.StoreKit';

const TAG: string = 'disableService';

@Entry
@Component
struct DisableService {
  @State result: string = '';
  @State message: string = 'disableService';
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
      privacyManager.disableService();
      this.result = 'disableService success!';
    } catch (error) {
      hilog.error(0, TAG, `disableService failed. code is ${error.code}, message is ${error.message}`);
      this.result = `disableService failed, error code: ${error.code}, error message: ${error.message}`;
    }
  }
}