/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { Params } from '../viewmodel/DataModel'
import { common } from '@kit.AbilityKit'
import { PromptActionManager } from '../common/utils/PromptActionManager'
import { OCRManager } from '../common/utils/OCRManager'

@Builder
export function dialogBuilder(params: Params): void {
  Column() {
    Text($r('app.string.dialog_title'))
      .font({ size: 20, weight: 700 })
      .lineHeight(27)
      .margin({ bottom: 16 })
    Text($r('app.string.dialog_subtitle'))
      .font({ size: 16, weight: 50 })
      .lineHeight(21)
      .margin({ bottom: 8 })
    Column({ space: 8 }) {
      Button($r('app.string.dialog_camera_btn'))
        .width('100%')
        .height(40)
        .onClick(async () => {
          PromptActionManager.closeCustomDialog();
          let text: string =
            await OCRManager.recognizeByCamera(params.uiContext.getHostContext() as common.UIAbilityContext,
              params.loadingController);
          params.loadingController.close();
          if (text) {
            params.textAreaController.deleteText();
            params.textAreaController.addText(text);
          }
        })
      Button($r('app.string.dialog_photo_btn'))
        .width('100%')
        .height(40)
        .fontColor($r('app.color.btn_font_color'))
        .backgroundColor($r('app.color.light_background'))
        .onClick(async () => {
          PromptActionManager.closeCustomDialog();
          let text: string =
            await OCRManager.recognizeByAlbum(params.loadingController);
          params.loadingController.close();
          if (text) {
            params.textAreaController.deleteText();
            params.textAreaController.addText(text);
          }
        })
      Button($r('app.string.dialog_cancel_btn'))
        .width('100%')
        .height(40)
        .fontColor($r('app.color.btn_font_color'))
        .backgroundColor($r('app.color.light_background'))
        .onClick(() => {
          PromptActionManager.closeCustomDialog();
        })
    }
  }
  .size({ width: 'calc(100% - 32vp)', height: 235 })
  .borderRadius(32)
  .backgroundColor($r('app.color.light_background'))
  .padding(16)
}