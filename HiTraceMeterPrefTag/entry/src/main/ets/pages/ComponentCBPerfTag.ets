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
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import { MyDataSource } from '../model/GridDataSource';
import { TextItem } from '../view/TextComponent';
import CommonConstants from '../common/CommonConstants'

@Component
export struct ComponentCBPerfTag {
  // Used for avoiding the status bar.
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State title: string = this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.ComponentCBPerfTag_Title'));
  private datasource: MyDataSource = new MyDataSource();
  scroller: Scroller = new Scroller();
  private irregularData: number[] = [];
  // Layout format of the grid component.
  layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
    irregularIndexes: this.irregularData,
  };

  aboutToAppear() {
    for (let i = 1; i <= CommonConstants.GRID_TOTAL_DATA; i++) {
      this.datasource.pushData(i + '');
      // Irregular data array.
      if ((i - 1) % 4 === 0) {
        this.irregularData.push(i - 1);
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        Grid(this.scroller, this.layoutOptions) {
          LazyForEach(this.datasource, (item: string, index: number) => {
            GridItem() {
              TextItem({ item: item })
            }
          }, (item: string) => item)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .layoutWeight(1)

        Button($r('app.string.ComponentCBPerfTag_Button'))
          .width(CommonConstants.FULL_PARENT)
          .fontWeight(CommonConstants.BUTTON_FONT_WEIGHT)
          .fontSize(CommonConstants.BUTTON_FONT_SIZE)
          .margin({ top: 20 })
          .onClick(() => {
            // HiTraceMeter start tagging
            hiTraceMeter.startTrace(CommonConstants.COMPONENT_TASK_NAME, CommonConstants.COMPONENT_CB_TASK_ID);
            this.scroller.scrollToIndex(CommonConstants.TARGET_INDEX);
          })
      }
      .width(CommonConstants.FULL_PARENT)
      .height(CommonConstants.FULL_PARENT)
      .padding(16)
    }
    .padding({ top: this.topRectHeight, bottom: this.bottomRectHeight })
    .backgroundColor($r('app.color.window_background_color'))
    .title(this.title)
  }
}
