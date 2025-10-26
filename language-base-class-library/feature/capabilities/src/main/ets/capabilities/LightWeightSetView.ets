/*
* Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
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

import { LightWeightSet } from '@kit.ArkTS';
import { emitter } from '@kit.BasicServicesKit';
import { customTitle, EmptyPage, logger } from '@ohos/common';
import { ValueItemView } from '../components/ValueItemView';
import { LightWeightSetDataSource } from '../components/lightweightsetcomponents/LightWeightSetDataSource';
import { Constant } from '../Constant';

const TAG = 'LightWeightSetView';

@Builder
export function LightWeightSetViewViewBuilder() {
  LightWeightSetView()
}

@Component
export struct LightWeightSetView {
  @State totalCount: number = 0;
  @State lightWeightSet: LightWeightSet<string> = new LightWeightSet();
  @StorageLink('selectedLabel') selectedLabel: string = '';
  public pathStack: NavPathStack = new NavPathStack();
  private dataSource: LightWeightSetDataSource = new LightWeightSetDataSource();

  aboutToAppear() {
    emitter.on({ eventId: Constant.EMITTER_ID_LIGHT_WEIGHT_SET }, (eventData: emitter.EventData) => {
      if (eventData.data === undefined) {
        return;
      }
      let item: string = eventData.data.value;
      this.dataSource.addData(item);
      this.lightWeightSet.add(item);
      this.totalCount = this.dataSource.totalCount();
    });
  }

  aboutToDisappear() {
    emitter.off(Constant.EMITTER_ID_LIGHT_WEIGHT_SET);
  }

  build() {
    NavDestination() {
      Column() {
        if (this.totalCount != 0) {
          List({ space: 12 }) {
            LazyForEach(this.dataSource, (item: string, index: number) => {
              ListItem() {
                ValueItemView({
                  index: index,
                  value: item,
                  deleteAction: () => {
                    logger.info(TAG, `item = ${JSON.stringify(item)}`)
                    this.dataSource.deleteData(item, index);
                    this.totalCount = this.dataSource.totalCount();
                    this.lightWeightSet.remove(item);
                  }
                })
              }
              .height(72)
              .width('100%')
            }, (item: string, index: number) => JSON.stringify(item) + index)
          }
          .width('100%')
          .height('100%')
          .padding({ top: 8, left: 12, right: 12 })
        } else {
          EmptyPage()
        }
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    }
    .title(customTitle(this.selectedLabel))
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}