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

// [Start redundant_operation]
import { hilog, hiTraceMeter } from '@kit.PerformanceAnalysisKit';

// Redundant operations are counterexamples
@Entry
@Component
struct RedundantOperation {
  private arr: number[] = [];

  aboutToAppear(): void {
    for (let i = 0; i < 500; i++) {
      this.arr[i] = i;
    }
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

        Text('Redundant operations')
          .fontSize(20)
          .fontWeight(700)
          .height(26)
      }
      .width('100%')
      .height(56)
      .margin({ top: 36 })

      Scroll() {
        List() {
          ForEach(this.arr, (item: number) => {
            ListItem() {
              Text('TextItem' + item)
                .width('100%')
                .padding({ left: 12 })
            }
            .onAreaChange(() => {
              // No business operations
              // Negative example.
            })
            .width('100%')
            .height(48)
          }, (item: number) => item.toString())
        }
        .divider({ strokeWidth: 1, color: '#F5F5F5' })
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('86%')
      .margin({ top: 8 })
      .backgroundColor(Color.White)
      .borderRadius(20)
      .onWillScroll(() => {
        hiTraceMeter.startTrace('ScrollSlide', 1001);

        hilog.debug(0x0000, 'Sample', 'Debug %{public}s', 'contents: logs');
        // Business logic
        // [StartExclude redundant_operation]
        // [EndExclude redundant_operation]
        hiTraceMeter.finishTrace('ScrollSlide', 1001);
      })
    }
    .backgroundColor('#F5F5F5')
    .height('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
  }
}

// [End redundant_operation]