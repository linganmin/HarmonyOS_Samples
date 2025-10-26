/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import { thermal } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { getString, logger } from '@ohos/common/Index';
import { ListModel } from '../model/ListModel';
import { ThermalUtil } from '../util/ThermalUtil';

@Extend(Text)
function fancy() {
  .height(50)
  .fontSize(16)
  .fontWeight(500)
}

@Builder
export function ThermalBuilder() {
  Thermal()
}

@Component
export struct Thermal {
  @State table: ListModel[] = [
    new ListModel('Thermal level', ThermalUtil.getLevel),
    new ListModel('Callback level', undefined),
    new ListModel('Last callback time', undefined)
  ];
  public pathStack: NavPathStack = new NavPathStack();

  aboutToAppear() {
    this.initThermal();
  }

  aboutToDisappear() {
    ThermalUtil.unregisterThermalLevelCallback();
  }

  build() {
    NavDestination() {
      List() {
        ForEach(this.table, (item: ListModel) => {
          ListItem() {
            Row() {
              Text(item.title)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor($r("app.color.list_title"))
                .textAlign(TextAlign.Start)
              Blank()
              Text(item.getValue())
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor($r("app.color.list_sub_content"))
                .textAlign(TextAlign.End)
            }
            .padding({ left: 16, right: 16 })
            .height(62)
            .width('100%')
          }
        })
      }
      .divider({
        strokeWidth: this.getUIContext().px2vp(1),
        color: $r("app.color.divider"),
        startMargin: 16,
        endMargin: 16
      })
      .borderRadius(20)
      .backgroundColor($r("app.color.white"))
      .margin({
        top: 16,
        bottom: 16,
        left: 4,
        right: 4
      })
      .width('100%')
    }
    .title(getString(this.getUIContext(), $r('app.string.thermal')))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }

  initThermal() {
    const INDEX_0 = 0;
    const INDEX_1 = 1;
    ThermalUtil.registerThermalLevelCallback((level: number) => {
      this.table[INDEX_0] = new ListModel('Thermal level', undefined, ThermalUtil.getLevel());
      this.table[INDEX_1] = new ListModel('Callback level', undefined, ThermalUtil.getStrLevel(level));
      this.getCurrentTime();
      if (level === thermal.ThermalLevel.WARNING) {
        try {
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.thermal_warning'),
            duration: 2000,
          });
        } catch (error) {
          logger.error(`showToast args error code is ${error?.code}, message is ${error?.message}`);
        }
      }
    })
  }

  getCurrentTime() {
    const INDEX_2 = 2;
    try {
      this.table[INDEX_2] =
        new ListModel('Last callback time', undefined, ThermalUtil.timestampToTime(systemDateTime.getTime(false)));
    } catch (err) {
      let error = err as BusinessError;
      logger.info(`Failed to get time. message: ${error.message}, code: ${error.code}`);
    }
  }
}