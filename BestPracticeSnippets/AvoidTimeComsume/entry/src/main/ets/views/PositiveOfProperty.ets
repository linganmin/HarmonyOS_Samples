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

// [Start positive_of_property]
import { taskpool } from '@kit.ArkTS'; // Task pools
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Concurrent
function getHeight(): number {
  let height: number = 0;
  // Simulate time-consuming operations with loop functions
  for (let index = 0; index < 1000000; index++) {
    height += 0.0001;
  }
  hilog.info(0x0000, 'Sample', '%{public}s', 'Scenario 4 call getHeight');
  return height;
}

// Execute getHeight
taskpool.execute(getHeight).then((value: Object) => {
  AppStorage.setOrCreate('height', value);
}).catch((error: BusinessError)=>{
  hilog.error(0x0000,'',`execute failed. code=${error.code}, message=${error.message}`);
});

@Entry
@Component
struct PositiveOfProperty {
  // Row width
  @State rowWidth: number = 200;
  // Row height
  @StorageLink('height') rowHeight: number = 0;
  // The number of times you click the button to change the width of the row
  private count: number = 0;

  build() {
    Column({ space: 10 }) {
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

        Text('Component property examples')
          .fontSize(20)
          .fontWeight(700)
          .height(26)
      }
      .width('100%')
      .height(56)
      .margin({ top: 36 })

      Row()
        .width(this.rowWidth)
        .height(this.rowHeight)
        .backgroundColor(Color.Blue)

      Button('change row width')
        .width('100%')
        .backgroundColor('#0A59F7')
        .onClick(() => {
          this.rowWidth = this.rowWidth + 20;
          this.count++;
          hilog.info(0x0000, 'Sample', 'Scenario 4 call getHeight: %{public}s', this.count);
          if (this.rowWidth > 300) {
            this.rowWidth = 200;
          }
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, bottom: 44 })
    .backgroundColor('#F5F5F5')
  }
}

// [End positive_of_property]