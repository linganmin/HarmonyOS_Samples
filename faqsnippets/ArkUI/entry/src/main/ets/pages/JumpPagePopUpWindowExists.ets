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
* FAQ:如何实现不关闭弹窗的情况下，跳转页面，并且返回时弹窗存在？
*/

// [Start jump_page_pop_up_window_exists]
@Component
struct DialogCpt {
  @Consume('pageStack') pageStack: NavPathStack;


  build() {
    NavDestination() {
      Column(){
        Column() {
          Button('Next page').onClick(() => {
            this.pageStack.pushPathByName('NextPage', '');
          })
          Blank()
          Row() {
            Button('Cancel')
              .onClick(() => {
                this.pageStack.pop();
              })
            Button('Confirm')
              .onClick(() => {
                this.pageStack.pop();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .padding(16)


        .height(300)
        .width(300)
        .backgroundColor(Color.White)
        .borderRadius(16)
      }
      .justifyContent(FlexAlign.Center)
      .height('100%')
      .width('100%')
    }
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
    .backgroundColor('#40000000')
  }
}


@Component
struct NextPage {
  @Consume('pageStack') pageStack: NavPathStack;


  build() {
    NavDestination() {
      Column() {
        Button('Back')
          .onClick(() => {
            this.pageStack.pop();
          })
      }
    }
  }
}


@Entry
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack()


  @Builder
  PageMap(name: string) {
    if (name === 'DialogCpt') {
      DialogCpt()
    } else if (name === 'NextPage') {
      NextPage()
    }
  }


  build() {
    Navigation(this.pageStack) {
      Column() {
        Button('Open dialog')
          .onClick(() => {
            this.pageStack.pushPathByName('DialogCpt', '');
          })
      }
    }
    .navDestination(this.PageMap)
    .backgroundColor('#F1F3F5')
  }
}
// [End jump_page_pop_up_window_exists]