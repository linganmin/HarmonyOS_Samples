/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
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

import { saveFile } from '../common/utils/VideoOperationUtils';

@CustomDialog
struct SaveCustomDialog {
  controller: CustomDialogController;
  build() {
    Column() {
      Text($r('app.string.save_button_title'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .height('56vp')
        .width('100%')
        .textAlign(TextAlign.Center)

      Text($r('app.string.save_button_note'))
        .width('100%')
        .fontSize(16)
        .textAlign(TextAlign.Center)


      Row() {
        Button($r('app.string.save_button_cancel'))
          .onClick(() => {
            this.controller.close()
          })
          .width('48%')
          .backgroundColor(Color.White)
          .fontColor($r('app.color.button_text_color'))

        Blank()

        Button($r('app.string.confirm'))
          .onClick(async () => {
            const context = this.getUIContext().getHostContext() as Context;
            await saveFile(context)
            this.controller.close()
          })
          .width('48%')
          .height('40vp')
          .backgroundColor(Color.White)
          .fontColor($r('app.color.button_text_color'))
      }
      .width('100%')
      .height('56vp')
    }
    .padding({ left: '24vp', right: '24vp', top: '8vp' })
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct SaveDialog {
  dialogController: CustomDialogController = new CustomDialogController({
    builder: SaveCustomDialog(),
    autoCancel: true
  })

  build() {
    Button($r('app.string.save_video'))
      .layoutWeight(1)
      .backgroundColor($r('app.color.button_bg_color'))
      .fontColor($r('app.color.button_text_color'))
      .fontWeight(500)
      .margin({ right: 6 })
      .size({
        width: '100%',
        height: '40vp'
      })
      .onClick(() => {
        this.dialogController.open()
      })
  }
}