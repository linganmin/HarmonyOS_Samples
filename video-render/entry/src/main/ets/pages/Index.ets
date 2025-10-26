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

@Entry
@Component
struct Index {
  private pathStack: NavPathStack = new NavPathStack();

  @Builder
  NavigationTitle() {
    Column() {
      Text($r('app.string.title'))
        .width(328)
        .height(40)
        .margin({ left: '16' })
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }.alignItems(HorizontalAlign.Start)
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 12 }) {
        Button($r('app.string.xcomponent_title'))
          .type(ButtonType.ROUNDED_RECTANGLE)
          .controlSize(ControlSize.NORMAL)
          .fontWeight(FontWeight.Medium)
          .align(Alignment.Center)
          .width('100%')
          .height(40)
          .onClick(() => {
            this.pathStack.pushPathByName('XComponentPlayer', null);
          })

        Button($r('app.string.opengl_title'))
          .type(ButtonType.ROUNDED_RECTANGLE)
          .controlSize(ControlSize.NORMAL)
          .fontWeight(FontWeight.Medium)
          .align(Alignment.Center)
          .width('100%')
          .height(40)
          .onClick(() => {
            this.pathStack.pushPathByName('OpenGLPlayer', null);
          })

        Button($r('app.string.vulkan_title'))
          .type(ButtonType.ROUNDED_RECTANGLE)
          .controlSize(ControlSize.NORMAL)
          .fontWeight(FontWeight.Medium)
          .align(Alignment.Center)
          .width('100%')
          .height(40)
          .onClick(() => {
            this.pathStack.pushPathByName('VulkanPlayer', null);
          })
      }
      .margin({ bottom: 16, left: 12, right: 12 })
      .height('100%')
      .justifyContent(FlexAlign.End)
    }
    .title(this.NavigationTitle())
    .titleMode(NavigationTitleMode.Full)
    .height('100%')
    .width('100%')
  }
}
