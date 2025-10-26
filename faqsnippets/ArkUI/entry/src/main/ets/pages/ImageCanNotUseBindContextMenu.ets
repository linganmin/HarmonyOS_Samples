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
* FAQ:Image无法使用bindContextMenu
*/

// [Start image_can_not_use_bind_context_menu]
@Entry
@Component
struct Index {
  @Builder
  menuBuilder() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Button('Test ContextMenu1')
      Divider().strokeWidth(2).margin(5).color(Color.Black)
      Button('Test ContextMenu2')
      Divider().strokeWidth(2).margin(5).color(Color.Black)
      Button('Test ContextMenu3')
    }
    .width(200)
    .height(160)
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Column() {
        Image($r('app.media.icon'))
          .draggable(false)
          .width('100vp')
      }
      .bindContextMenu(this.menuBuilder, ResponseType.LongPress)
      .onDragStart(() => {
        // Close menu when dragging
        this.getUIContext().getContextMenuController().close()
      })

    }
    .width('100%')
    .height('100%')
  }
}
// [End image_can_not_use_bind_context_menu]