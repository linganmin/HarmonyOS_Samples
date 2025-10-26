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
* FAQ：NavPathStack清空页面栈或者按返回键，为什么没有退出Navigation所在的页面，而是显示导航栏
*/

// [Start NavPathStackExitsTheNavigationPage]
@Entry
@Component
struct NavPathStackExitsTheNavigationPage {
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();

  @Builder
  myRouter(name: string) {
    if (name === 'PageOne') {
      PageOne()
    }
  }

  aboutToAppear(): void {
    this.pathInfos.pushPath({ name: 'PageOne' });
  }

  build() {
    Navigation(this.pathInfos) {
      Column() {
        Button('Jump to PageOne')
          .width('100%')
          .borderRadius(20)
          .margin({ bottom: 16 })
          .backgroundColor('#0A59F7')
          .onClick(() => {
            this.pathInfos.pushPath({ name: 'PageOne' });
          })
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .mode(NavigationMode.Auto)
    .title('title')
    .titleMode(NavigationTitleMode.Mini)
    .navDestination(this.myRouter)
    .hideBackButton(true)
    .hideNavBar(true) // Set the Navigation property's hideNavBar to true.
  }
}

@Component
export struct PageOne {
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Text('PageOne')
          .width('100%')
          .fontSize(20)
          .fontColor(0x333333)
          .textAlign(TextAlign.Center)
      }
      .size({ width: '100%', height: '100%' })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .title('PageOne')
    .onBackPressed(() => {
      this.getUIContext().getRouter().back(); // Override the return button logic to exit the navigation page.
      return true;
    })
  }
}

// [End NavPathStackExitsTheNavigationPage]