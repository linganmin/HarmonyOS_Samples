/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { cloudFunction } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'FunctionPage';

interface res {
  result: result
}

interface result {
  sort: string
}

@Entry
@Component
struct FunctionPage {
  @State sort: string = '';

  build() {
    Column() {
      Navigation()
        .title($r('app.string.cloud_function_title'))
        .height('50vp')
        .width('100%')
        .margin({ bottom: 10 })
        .titleMode(NavigationTitleMode.Mini)

      Text($r('app.string.cloud_function_button_text'))
        .width('90%')
        .textAlign(TextAlign.Center)
        .margin({
          top: 20,
          bottom: 20
        })
        .fontSize($r('app.float.body_font_size'))
      Button({ type: ButtonType.Normal }) {
        Text($r('app.string.cloud_function_button_text1'))
          .fontColor($r('app.color.white'))
          .margin({
            top: 5,
            bottom: 5
          })
          .fontSize(15)
      }
      .width('90%')
      .borderRadius(4)
      .height('30vp')
      .margin({ top: 10 })
      .onClick(() => {
        // 云函数
        cloudFunction.call({ name: 'sort' }).then((res: cloudFunction.FunctionResult) => {
          let currentRes = res as res;
          this.sort = currentRes.result.sort;
        }).catch((err: BusinessError) => {
          hilog.error(DOMAIN, TAG, `Failed to call function , code: ${err.code}, message: ${err.message}`);
        });
      })

      Button({ type: ButtonType.Normal }) {
        Text($r('app.string.cloud_function_button_text2'))
          .fontColor($r('app.color.white'))
          .margin({
            top: 5,
            bottom: 5
          })
          .fontSize(15)
      }
      .width('90%')
      .borderRadius(4)
      .height('30vp')
      .margin({ top: 60 })
      .onClick(() => {
        cloudFunction.call({ name: 'sort-id' }, (err: BusinessError, data: cloudFunction.FunctionResult) => {
          if (err) {
            hilog.error(DOMAIN, TAG, `Failed to call function , code: ${err.code}, message: ${err.message}`);
            return;
          }
          let currentRes = data as res;
          this.sort = currentRes.result.sort;
        });
      })

      Column() {
        Text(this.sort).width('90%').height('50vp').textAlign(TextAlign.Center);
      }
      .width('90%')
      .padding({
        top: 20,
        bottom: 20
      })
      .margin({ top: 20 })
    }.height('100%')
  }
}