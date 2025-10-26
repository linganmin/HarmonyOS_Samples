/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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

import { EditableLeftIconType, EditableTitleBar, router } from '@kit.ArkUI';

@Entry
@Component
struct RouterPageA {
  build() {
    Column() {
      EditableTitleBar({
        leftIconStyle: EditableLeftIconType.Back,
        title: 'Router Page A',
        isSaveIconRequired: false,
        onCancel: () => {
          this.getUIContext().getRouter().back();
        }
      })

      Row() {
        Button('To Router PageB')
          .width('100%')
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/RouterPageB' });
          })
      }
      .padding({
        right: 16,
        left: 16
      })
    }
    .backgroundColor('#F1F3F5')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: AppStorage.get<number>('statusBarHeight') ?? 0,
      bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16
    })
    .height('100%')
    .width('100%')
  }
}