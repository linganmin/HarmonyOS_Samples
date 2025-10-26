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

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text($r('app.string.wearable_label'))
          .width(150)
          .fontColor(Color.White)
          .font({
            size: 19,
            weight: 700
          })
          .margin({
            top: 20
          })
        Button($r('app.string.interconnection_communication'))
          .width(150)
          .margin({
            top: 35
          })
          .onClick(() => {
            this.pathStack.pushPathByName('ConnectPage', null);
          })
        Button($r('app.string.Watch_sensor'))
          .width(150)
          .margin({
            top: 12
          })
          .onClick(() => {
            this.pathStack.pushPathByName('SensorsPage', null);
          })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
  }
}