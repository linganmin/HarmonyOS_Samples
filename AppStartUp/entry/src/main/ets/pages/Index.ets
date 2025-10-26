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

import { startupManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import Constants from '../common/Constants';
import GlobalBuilderContext from '../common/GlobalBuilderContext';

const TAG = 'Index';

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack();
  private readonly COLUMN_SPACE: number = 12;
  private readonly IMAGE_KNIFE_TASK: string = 'ImageKnifeTask';

  build() {
    Column() {
      Navigation(this.pageStack) {
        Column({ space: this.COLUMN_SPACE }) {
          Button($r('app.string.auto_mode'))
            .width(Constants.FULL_PERCENT)
            .onClick(() => {
              this.pageStack.pushPathByName(Constants.NAV_DESTINATION_ITEM_AUTO_MODE, '');
            })
          Button($r('app.string.manual_mode'))
            .width(Constants.FULL_PERCENT)
            .onClick(() => {
              this.openManualMode();
            })
        }
        .padding({
          left: 16,
          right: 16,
          bottom: 16
        })
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.Center)
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
      }
      .mode(NavigationMode.Stack)
      .title({
        builder: this.navTitle(),
        height: 112
      })
      .navDestination(this.pagesMap)
    }
    .height(Constants.FULL_PERCENT)
    .width(Constants.FULL_PERCENT)
    .backgroundColor('#F1F3F5')
  }

  @Builder
  navTitle() {
    Column() {
      Text($r('app.string.EntryAbility_label'))
        .fontSize(30)
        .fontWeight(700)
        .lineHeight(40)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Start)
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .padding({
      left: 16,
      right: 16,
      bottom: 8
    })
  }

  @Builder
  pagesMap(id: string) {
    if (GlobalBuilderContext.getContext().getObject(id)) {
      (GlobalBuilderContext.getContext().getObject(id) as WrappedBuilder<[string]>).builder(id);
    }
  }

  openManualMode(): void {
    if (startupManager.isStartupTaskInitialized(this.IMAGE_KNIFE_TASK)) {
      this.pageStack.pushPathByName(Constants.NAV_DESTINATION_ITEM_MANUAL_MODE, '');
      return;
    }
    let startParams = [this.IMAGE_KNIFE_TASK];
    try {
      startupManager.run(startParams).then(() => {
        hilog.info(0x0000, 'testTag', `Manual Task execute success`);
        this.pageStack.pushPathByName(Constants.NAV_DESTINATION_ITEM_MANUAL_MODE, '');
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, TAG, `Failed Startup run, errorCode:${error.code}`);
      })
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed Startup run, errorCode:${err.code}`);
    }
  }
}