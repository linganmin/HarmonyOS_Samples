/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import testNapi from 'libentry.so';

@CustomDialog
export struct CustomAlterDialog {
  customAlterDialogCtl: CustomDialogController;
  title: string = '';
  content: string = '';

  build() {
    Column() {
      Text(this.title)
        .fontColor($r('sys.color.font_primary'))
        .height(56)
        .fontSize(20)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bold)

      Column() {
        Text(this.content)
          .textAlign(TextAlign.Start)
          .opacity(0.6)
          .fontSize(14)
          .fontColor(Color.Black)
          .width('100%')
      }
      .layoutWeight(1)
      .padding({
        left: 8,
        right: 8
      })

      Row({ space: 12 }) {
        Button('OK')
          .layoutWeight(1)
          .height(40)
          .onClick(() => {
            this.customAlterDialogCtl.close();
          })
      }
      .height(56)
      .alignItems(VerticalAlign.Top)
    }
    .constraintSize({
      maxHeight: '80%'
    })
    .height(140)
    .width('calc(100% - 32vp)')
    .padding({
      left: 16,
      right: 16
    })
    .borderColor(Color.Red)
    .borderRadius(32)
  }
}

@Entry
@Component
struct Index {
  title: string = 'QoS Sample';
  @State message: string = '';
  customFaceDialogCtl: CustomDialogController = new CustomDialogController({
    builder: CustomAlterDialog({ title: this.title, content: this.message }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    isModal: true,
    customStyle: false
  });

  build() {
    Row() {
      Column({ space: 12 }) {
        Blank()
        Button('High level QoS test')
          .height(40)
          .width('100%')
          .onClick(() => {
            let ret: string = testNapi.useHighQos().toString();
            this.message = `High-level QoS time: ${ret} ms`;
            this.customFaceDialogCtl.open();
          })

        Button('Low level QoS test')
          .height(40)
          .width('100%')
          .onClick(() => {
            let ret: string = testNapi.useHighQos().toString();
            this.message = `Low-level QoS time: ${ret} ms`;
            this.customFaceDialogCtl.open();
          })
      }
      .height('100%')
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)
    }
    .height('100%')
  }
}