/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Demo_HMS_ServiceCollaboration_StopCollaboration } from 'libentry.so'

@CustomDialog
export struct CustomDialogExample {
  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }
  selectAbility: number = 1;
  deviceName: string = '';
  idResult: number = 0;
  jsonName: Resource | undefined = undefined;

  aboutToAppear(): void {
    this.transformFilterAbility();
  }

  build() {
    Column() {
      Column() {
        Text() {
          if (this.selectAbility == 1) {
            SymbolSpan($r('sys.symbol.camera_fill')).fontSize(32).fontColor(['#fff'])
          }
          if (this.selectAbility == 2) {
            SymbolSpan($r('sys.symbol.line_viewfinder')).fontSize(32).fontColor(['#fff'])
          }
          if (this.selectAbility == 3) {
            SymbolSpan($r('sys.symbol.picture_fill')).fontSize(32).fontColor(['#fff'])
          }
        }.maxFontScale(1).minFontScale(1)
      }
      .justifyContent(FlexAlign.Center)
      .width(64)
      .height(64)
      .margin({ top: 16 })
      .linearGradient({
        angle: 180,
        colors: [['#4C99F3', 0.0], ['#3778EF', 1.0]]
      })
      .borderRadius(16)

      Column() {
        Row() {
          Text($r('app.string.using', this.deviceName))
            .fontSize(16)
            .height(50)
          Text(this.jsonName)
            .fontSize(16)
            .height(50)
        }

        Button($r('app.string.Photo_cancel'))
          .onClick(() => {
            if (this.controller != undefined) {
              Demo_HMS_ServiceCollaboration_StopCollaboration(this.idResult);
              this.controller.close();
            }
          })
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
          .width('100%')
          .margin({ bottom: 16 })
          .padding({ left: 24, right: 24 })
      }
    }
  }

  public transformFilterAbility(): void {
    switch (this.selectAbility) {
      case 1:
        this.jsonName = $r('app.string.Take_photo');
        break;
      case 2:
        this.jsonName = $r('app.string.Scan');
        break;
      case 3:
        this.jsonName = $r('app.string.Picker_photo');
        break;
      default:
        break;
    }
  }
}