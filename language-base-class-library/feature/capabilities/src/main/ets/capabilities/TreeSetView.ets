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

import { emitter } from '@kit.BasicServicesKit';
import { customTitle, EmptyPage } from '@ohos/common';
import { TreeSetDataSource } from '../components/treesetcomponents/TreeSetDataSource';
import { ValueItemView } from '../components/ValueItemView';
import { Constant } from '../Constant';

const MIN_LENGTH = 0;

@Builder
export function TreeSetViewBuilder() {
  TreeSetView()
}

@Component
export struct TreeSetView {
  private dataSource: TreeSetDataSource = new TreeSetDataSource();
  @State totalCount: number = MIN_LENGTH;
  @StorageLink('selectedLabel') selectedLabel: string = '';
  public pathStack: NavPathStack = new NavPathStack();

  aboutToAppear() {
    emitter.on({ eventId: Constant.EMITTER_ID_TREE_SET }, (eventData) => {
      this.dataSource.addData((eventData.data as Record<string, Object>)['value'] as string);
      this.totalCount = this.dataSource.totalCount();
    });
  }

  aboutToDisappear() {
    emitter.off(Constant.EMITTER_ID_TREE_SET);
  }

  build() {
    NavDestination() {
      Column() {
        if (this.totalCount > MIN_LENGTH) {
          List() {
            LazyForEach(this.dataSource, (item: string, index: number) => {
              ListItem() {
                ValueItemView({ index: index, value: item, deleteAction: () => {
                  this.dataSource.deleteData(item, index);
                  this.totalCount = this.dataSource.totalCount();
                } })
              }
              .height(72)
              .width('100%')
              .margin({ bottom: 20 })
            }, (item: string, index: number) => JSON.stringify(item) + index)
          }
          .width('100%')
          .layoutWeight(1)

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