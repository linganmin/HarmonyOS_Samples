/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import hilog from '@ohos.hilog';

@Entry
@Component
struct Index {
  // message
  @State message: string = 'FIDO2'

  aboutToAppear() {
    hilog.info(0x0000, 'FIDO2', '%{public}s', 'FIDO2 index aboutToAppear');
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
        Button() {
          Text('FIDO2')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({
          top: 15
        })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('4%')
        .onClick(() => {
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}