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

// [Start conditional_rendering]
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct MyComponent {
  // Toggles the custom component flag
  @State flag: boolean = false;

  build() {
    Column({ space: 10 }) {
      Row({ space: 5 }) {
        Column() {
          // $r('app.media.chevron_left') It needs to be replaced with the resources required by the developers
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

        Text('Conditional rendering')
          .fontSize(20)
          .fontWeight(700)
          .height(26)
      }
      .width('100%')
      .height(56)
      .margin({ top: 36 })

      // Use conditional rendering to simulate a scene where components are frequently created and destroyed with the click of a button
      if (this.flag) {
        // Custom component A
        CustomComponentA()
      } else {
        // Custom component B
        CustomComponentB()
      }
      Button('switch custom component')
        .width('100%')
        .backgroundColor('#0A59F7')
        .onClick(() => {
          // Click the button to switch to the custom component
          this.flag = !this.flag;
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, bottom: 44 })
    .backgroundColor('#F5F5F5')
  }
}

@Component
struct CustomComponentA {
  aboutToAppear(): void {
    let temp: number = 0;
    for (let i = 0; i < 1000000; i++) {
      temp += 1;
    }
    hilog.info(0x0001, 'Sample', `%{public}s', 'CustomComponentA aboutToAppear ${temp}`);
  }

  aboutToDisappear(): void {
    let temp: number = 0;
    for (let i = 0; i < 1000000; i++) {
      temp += 1;
    }
    hilog.info(0x0001, 'Sample', '%{public}s', `CustomComponentA aboutToDisappear ${temp}`);
  }

  build() {
    Column()
      .backgroundColor(Color.Blue)
      .width(200)
      .height(200)
  }
}

@Component
struct CustomComponentB {
  aboutToAppear(): void {
    let temp: number = 0;
    for (let i = 0; i < 1000000; i++) {
      temp += 1;
    }
    hilog.info(0x0001, 'Sample', '%{public}s', `CustomComponentB aboutToAppear ${temp}`);
  }

  aboutToDisappear(): void {
    let temp: number = 0;
    for (let i = 0; i < 1000000; i++) {
      temp += 1;
    }
    hilog.info(0x0001, 'Sample', '%{public}s', `CustomComponentB aboutToDisappear ${temp}`);
  }

  build() {
    Column()
      .backgroundColor(Color.Gray)
      .width(200)
      .height(200)
  }
}

// [End conditional_rendering]