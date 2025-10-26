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

import { Want } from '@kit.AbilityKit';
import Logger from '../utils/Logger';

const DATA_KEY = 'testKey';

@Entry({ useSharedStorage: true })
@Component
struct ClickActionInnerPage {
  @LocalStorageLink('want') want: Want = {};

  build() {
    Column() {
      Row() {
        Text($r('app.string.ClickActionAbility_desc'))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(20)
      .margin({
        top: 30
      })

      if (this.want.parameters) {
        Text($r('app.string.click_action_data'))
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#317AF7')
          .margin({
            top: 20
          })

        // get data passed by REST API from want.parameters
        Text(`${DATA_KEY}: ${this.want.parameters[DATA_KEY]}`)
          .margin({
            top: 8
          })
      }
    }
    .width('100%')
  }

  aboutToAppear(): void {
    Logger.info('Click action inner page aboutToAppear');
  }
}