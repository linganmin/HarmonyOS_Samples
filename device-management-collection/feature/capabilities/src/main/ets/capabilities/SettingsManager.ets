/*
 * Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
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

import { settings } from '@kit.BasicServicesKit';
import { getString } from '@ohos/common';
import { ColumnOperation } from '../components/ColumnOperation';

@Builder
export function SettingsManagerBuilder() {
  SettingsManager()
}

@Component
export struct SettingsManager {
  @State result: string = '';
  public pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Text(this.result)
              .fontWeight(FontWeight.Medium)
              .fontSize(20)
          }
          .alignItems(VerticalAlign.Top)
          .width('100%')
          .backgroundColor($r("app.color.white"))
          .height(160)
          .padding(16)
          .borderRadius(20)
          .margin({ top: 16 })

          ColumnOperation({ operationRes: $r('app.strarray.settings_operations'), doOperation: this.doOperation })
        }
        .width('100%')
        .padding(4)
      }
      .scrollBar(BarState.Off)
    }
    .title(getString(this.getUIContext(), $r('app.string.settings')))
  }

  doOperation = async (index: number) => {
    switch (index) {
      case 0:
        let uri = settings.getUriSync(settings.display.SCREEN_BRIGHTNESS_STATUS);
        this.result = `${uri}`;
        break;
      default:
        break;
    }
  }
}