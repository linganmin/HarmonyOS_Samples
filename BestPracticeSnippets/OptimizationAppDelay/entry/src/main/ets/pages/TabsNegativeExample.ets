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
import { CustomContent } from './CustomContent';

/**
 * 最佳实践：合理使用动画-合理设置隐式动画 反例
 */

// [Start tabs_negative_example]
@Entry
@Component
struct TabsNegativeExample {
  // [StartExclude tabs_negative_example]
  @State currentIndex: number = 0;
  private list: string[] = ['green', 'blue', 'yellow', 'pink'];
  // [EndExclude tabs_negative_example]
  private controller: TabsController = new TabsController();

  // [StartExclude tabs_negative_example]
  @Builder
  customContent(color: Color) {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor(color)
  }

  // [EndExclude tabs_negative_example]

  build() {
    Column() {
      // [StartExclude tabs_negative_example]
      Row({ space: 10 }) {
        ForEach(this.list, (item: string, index: number) => {
          Text(item)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .height(32)
            .layoutWeight(1)
            .fontColor(this.currentIndex === index ? Color.White : Color.Black)
            .backgroundColor(this.currentIndex === index ? Color.Blue : '#f2f2f2')
            .borderRadius(16)
            .onClick(() => {
              this.controller.changeIndex(index);
              this.currentIndex = index;
            })
        }, (item: string, index: number) => JSON.stringify(item) + index)
      }
      .margin(10)

      // [EndExclude tabs_negative_example]

      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        // [StartExclude tabs_negative_example]
        TabContent() {
          this.customContent(Color.Green)
        }

        TabContent() {
          this.customContent(Color.Blue)
        }

        TabContent() {
          this.customContent(Color.Yellow)
        }

        TabContent() {
          this.customContent(Color.Pink)
        }

        // [EndExclude tabs_negative_example]

      }
      .barHeight(0)
      .layoutWeight(1)
      .animationDuration(1000)
      .scrollable(false)
    }
    .width('100%')
  }
}

// [End tabs_negative_example]