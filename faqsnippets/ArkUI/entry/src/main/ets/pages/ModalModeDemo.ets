/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
* FAQ:Tabs如何设置页面margin，使得边距空白跟随页面滑动
*/

// [Start ModalModeDemo]
@Entry
@Component
struct ModalModeDemo {
  @State btnMessage: string = "Click To Trigger, longPress To Pop Up Menu"
  @State toastMessage: string = "The Click event was triggered."
  @Builder
  MyMenu() {
    Menu() {
      MenuItem({ content: "MenuOptionOne" })
      MenuItem({ content: "MenuOptionTwo" })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
          Column() {
            Button(this.btnMessage)
              .bindContextMenu(this.MyMenu, ResponseType.LongPress, {
                modalMode: ModalMode.TARGET_WINDOW,
                placement: Placement.BottomLeft
              })
              .onClick(() => {
                this.getUIContext().getPromptAction().showToast({
                  message: this.toastMessage
                })
              })
          }
        }
      }
    }.width('100%').height('100%')
  }
}
// [End ModalModeDemo]