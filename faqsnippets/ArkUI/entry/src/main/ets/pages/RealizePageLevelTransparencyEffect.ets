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
* FAQ:跳转页面如何实现页面级别的透明效果
*/

// [Start realize_page_level_transparency_effect]
@Component
export struct TransparentPage {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  pageMapBuilder(name: string) {
    if (name === 'DialogPage') {
      DialogPage()
    }
  }

  build() {
    Navigation(this.pageStack) {
      Button('Push DialogPage')
        .margin(20)
        .width('80%')
        .onClick(() => {
          this.pageStack.pushPathByName('DialogPage', '');
        })
    }
    .mode(NavigationMode.Stack)
    .title('Main')
    .navDestination(this.pageMapBuilder)
  }
}

@Component
export struct DialogPage {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text("Dialog NavDestination")
            .fontSize(20)
            .margin({ bottom: 100 })
          Button("Close")
            .onClick(() => {
              this.pageStack?.pop() ?? console.warn("Navigation stack is empty");
            })
            .width('30%')
        }
        .justifyContent(FlexAlign.Center)
        .borderRadius(10)
        .height('30%')
        .width('80%')
      }
      .height("100%")
      .width('100%')
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
  }
}
// [End realize_page_level_transparency_effect]