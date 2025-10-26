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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { netHandover } from '@kit.NetworkBoostKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct requestContent {
  @State content: string = '';
  @State mode: netHandover.HandoverMode = netHandover.HandoverMode.DISCRETION;

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('SetHandoverMode')
            .fontSize(30)
            .fontWeight(500)
            .fontColor($r('sys.color.black'))
            .height(48)
            .width(400)
            .margin({ top: '5%', right: '16%' })
        }
        .height(40)
        .width(124)
        .margin({ top: 32, right: '16%' })

        Divider().color('gray').strokeWidth(1)
        Text('mode:')
          .fontSize(24)
          .fontWeight(500)
          .fontColor($r('sys.color.navigation_drag_bar_item_default'))
          .height(40)
          .width('100%')
          .margin({ top: '10%', right: '16%' })

        Text(String(this.mode))
          .width('100%')
          .height(40)
          .margin({ top: '1%', right: '5%' })
          .backgroundColor($r('sys.color.navigation_drag_bar_item_default'))
          .fontColor($r('sys.color.black'))
          .fontSize(18)
          .fontWeight(500)
          .borderRadius(10)

        Button($r('app.string.Click_to_set_handover_mode'))
          .width('100%')
          .height(40)
          .margin({ top: '11%' })
          .fontColor($r('sys.color.navigation_drag_bar_item_default'))
          .fontSize(24)
          .fontWeight(500)
          .borderRadius(20)
          .onClick(this.getSetHandoverMode)

        Text($r('app.string.Result'))
          .fontSize(24)
          .fontWeight(500)
          .fontColor($r('sys.color.black'))
          .width('100%')
          .height(40)
          .margin({ top: '11%', right: '16%' })
        TextArea({
          text: this.content
        })
          .width('100%')
          .height(200)
          .margin({ top: '11%', left: 0 })
          .backgroundColor($r('sys.color.gray_01'))
          .fontColor($r('sys.color.black'))
          .fontSize(24)
          .fontWeight(500)
          .borderRadius(10)
      }
      .padding({ left: '16vp', right: '16vp' })
      .alignItems(HorizontalAlign.Start)
    }
    .height('100%')
    .width('100%')
  }

  private getSetHandoverMode = async () => {
    hilog.info(0x0000, 'testTag', 'setHandoverMode event');
    try {
      let mode: netHandover.HandoverMode = netHandover.HandoverMode.DISCRETION;
      netHandover.setHandoverMode(mode);
      this.content = `Succeed to set handover mode.`;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      this.content = `Failed to set handover mode:` + JSON.stringify(err);
      hilog.error(0x0000, 'testTag', 'setHandoverMode error: %{public}d %{public}s', e.code, e.message);
    }
  }
}