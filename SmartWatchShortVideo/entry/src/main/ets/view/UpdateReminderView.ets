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

import { common } from '@kit.AbilityKit';

@Component
export struct UpdateReminderView {
  @StorageLink('context') context: common.UIAbilityContext | undefined = undefined;

  build() {
    Column() {
      Text($r('app.string.title_update_reminder'))
        .fontSize('19fp')
        .fontWeight(700)
        .margin({ bottom: 19 })

      QRCode('https://developer.huawei.com/consumer/cn/')
        .backgroundColor(Color.White)
        .border({
          width: 8.5,
          color: Color.White,
          radius: 6
        })

      Text($r('app.string.update_reminder'))
        .fontSize('15fp')
        .margin({ top: 6 })
    }
    .width('100%')
  }
}

@Builder
export function updateReminderViewBuilder() {
  UpdateReminderView()
}