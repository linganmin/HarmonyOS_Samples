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

import { promptAction } from '@kit.ArkUI';
import { LiveView } from '../utils/LiveView'

@Component
export struct TrafficInfoView {
  @State private isShowButton: boolean = false;

  build() {
    Row() {
      if (this.isShowButton === false) {
        Column() {
          Text($r('app.string.traffic_info_first'))
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
            .fontSize($r('sys.float.padding_level12'))
            .margin({
              left: $r('sys.float.padding_level12'),
            })
          Row() {
            Text($r('app.string.traffic_info_second'))
              .fontColor(Color.Grey)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .fontSize($r('sys.float.padding_level8'))
            Image($r('app.media.traffic_light'))
              .height(32)
            Text($r('app.string.traffic_info_third'))
              .fontColor(Color.Grey)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .fontSize($r('sys.float.padding_level8'))
          }
          .padding({
            top: $r('sys.float.padding_level4'),
            left: $r('sys.float.padding_level12'),
            bottom: $r('sys.float.padding_level12'),
          })
        }
        .alignItems(HorizontalAlign.Start)

        Column() {
          SymbolGlyph($r('sys.symbol.arrow_right_and_square'))
            .fontColor([Color.Black])
            .fontSize(25)
            .margin(10)
        }
        .onClick(() => {
          this.isShowButton = true;
        })
        .backgroundColor($r('app.color.component_background_color'))
        .borderRadius(32)
        .position({
          right: 16,
        })
      } else {
        Row() {
          Blank()
          Button($r('app.string.Continue'))
            .fontColor($r('sys.color.font_emphasize'))
            .backgroundColor($r('app.color.traffic_info_button'))
            .fontSize(16)
            .width('40%')
            .onClick(() => {
              this.isShowButton = false;
              LiveView.getInstance(this.getUIContext().getHostContext() as Context).createLiveView();
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.toast'),
                duration: 2000,
                showMode: promptAction.ToastShowMode.DEFAULT,
                bottom: 180
              });
            })
          Blank()
          Button($r('app.string.Finish'))
            .fontColor($r('sys.color.warning'))
            .backgroundColor($r('app.color.traffic_info_button'))
            .fontSize(16)
            .width('40%')
            .onClick(() => {
              this.isShowButton = false;
              LiveView.getInstance(this.getUIContext().getHostContext() as Context).finishLiveView();
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.toast'),
                duration: 2000,
                showMode: promptAction.ToastShowMode.DEFAULT,
                bottom: 180
              });
            })
          Blank()
        }
        .margin({
          top: 6,
        })
        .width('100%')
      }
    }
    .width('100%')
  }
}