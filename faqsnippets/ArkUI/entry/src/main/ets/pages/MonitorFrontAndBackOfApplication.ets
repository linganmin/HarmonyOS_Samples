/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

/*
* FAQ:Component如何监听应用前后台切换
*/

// [Start monitor_front_and_back_of_application]
@Entry
@Component
struct ComponentListenFrontAndBack {
  @State message: string = 'Hello World';
  @StorageLink('isOnForeground') isOnForeground: boolean = true;

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        ForegroundAwareComponent({ isOnForeground: this.isOnForeground })
      }
      .width('100%')
    }
    .height('100%')
  }
}

@Component
struct ForegroundAwareComponent {
  @Watch('change') @Link isOnForeground: boolean;
  @State message: string = 'video';

  build() {
    Text('message')
      .fontSize(50)
      .fontWeight(FontWeight.Bold)
      .onClick(() => {
        this.message += this.isOnForeground;
        console.info('' + this.isOnForeground);
      })
  }

  change() {
    if (this.isOnForeground) {
      console.info('The component is on foreground.');
    } else {
      console.info('The component is on background.');
    }
  }
}

// [End monitor_front_and_back_of_application]