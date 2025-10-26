/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { sceneManager } from '@kit.StoreKit';

const TAG: string = 'getSelfSceneCode';

@Entry
@Component
struct GetSelfSceneCode {
  @State result: string = '';
  @State message: string = 'getSelfSceneCode';
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
      const sceneCode: string = sceneManager.getSelfSceneCode();
      this.result = 'Self sceneCode:' + sceneCode;
    } catch (error) {
      hilog.error(0, TAG, `getSelfSceneCode failed. code is ${error.code}, message is ${error.message}`);
    }
  }
}