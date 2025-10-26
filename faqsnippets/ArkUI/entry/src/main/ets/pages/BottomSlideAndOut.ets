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
* FAQ:自定义组件间如何实现从底部滑入滑出的效果
*/

// [Start component_transition]
@Entry
@Component
struct ComponentTransition {
  @State flag: boolean = true;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.flag) {
        ComponentChild1({ flag: $flag })
          .transition({ type: TransitionType.Insert,translate: { x: 0, y: 200 } })
      }
      if (!this.flag) {
        ComponentChild2({ flag: $flag })
          .transition({ type: TransitionType.Insert, translate: { x: 0, y: 200 } })
      }
    }.height('100%').width('100%')
  }
}

@Component
struct ComponentChild1 {
  @Link flag: boolean

  build() {
    Column() {
      Image($r('app.media.ic_banner01'))// path: resources\base\media
        .width('100%')
        .height(200)
        .onClick(() => {
          this.getUIContext().animateTo({ duration: 1000 }, () => {
            this.flag = !this.flag;
          })
        })
    }
  }
}

@Component
struct ComponentChild2 {
  @Link flag: boolean

  build() {
    Column() {
      Image($r('app.media.ic_banner02'))// path: resources\base\media
        .width('100%')
        .height(200)
        .onClick(() => {
          this.getUIContext().animateTo({ duration: 1000 }, () => {
            this.flag = !this.flag;
          })
        })
    }
  }
}
// [End component_transition]