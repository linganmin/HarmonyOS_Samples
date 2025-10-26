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

import { hilog, hiTraceMeter } from '@kit.PerformanceAnalysisKit';

// [Start negative_of_on_scroll]
// onWillScroll high-frequency event callback counterexample
@Entry
@Component
struct NegativeOfOnScroll {
  private arr: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  count(): number {
    let temp: number = 0;
    for (let i = 0; i < 1000000; i++) {
      temp += 1;
    }
    return temp;
  }

  build() {
    Column() {
      Row({ space: 5 }) {
        Column() {
          Image($r('app.media.chevron_left'))
            .width(16)
            .height(16)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#E8E8E8')
        .borderRadius(40)
        .onClick(() => {
          this.getUIContext().getRouter().back({
            url: 'pages/Index'
          });
        })

        Text($r('app.string.negative_of_onScroll'))
          .fontSize(20)
          .fontWeight(700)
          .height(26)
      }
      .width('100%')
      .height(56)
      .margin({ top: 20 })

      Scroll() {
        List() {
          ForEach(this.arr, (item: number) => {
            ListItem() {
              Text('TextItem' + item)
                .width('100%')
                .padding({ left: 12 })
            }
            .width('100%')
            .height(48)
          }, (item: number) => item.toString())
        }
        .divider({ strokeWidth: 1, color: '#F5F5F5' })
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height(492)
      .margin({ top: 8 })
      .backgroundColor(Color.White)
      .borderRadius(20)
      .onWillScroll(() => {
        hiTraceMeter.startTrace('ScrollSlide', 1001);
        hilog.info(0x0000, 'Sample', '%{public}s', 'Scroll TextItem');
        // Time-consuming operation
        this.count();
        // Business logic
        // ...
        hiTraceMeter.finishTrace('ScrollSlide', 1001);
      })
    }
    .padding(16)
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

// [End negative_of_on_scroll]