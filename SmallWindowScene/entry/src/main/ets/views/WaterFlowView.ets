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


import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants } from '../constants/CommonConstants';
import { WaterFlowDataSource } from '../utils/WaterFlowDataSource';

const TAG: string = 'WaterFlowView';

@Component
export struct WaterFlowView {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = WidthBreakpoint.WIDTH_SM;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: number = HeightBreakpoint.HEIGHT_SM;
  @State minSize: number = 80;
  @State maxSize: number = 180;
  @State fontSize: number = 24;
  @State colors: number[] = [0xFFC0CB, 0xDA70D6, 0x6B8E23, 0x6A5ACD, 0x00FFFF, 0x00FF7F];
  @State waterFlowColumnsTemplate: string = '1fr';
  scroller: Scroller = new Scroller();
  dataSource: WaterFlowDataSource = new WaterFlowDataSource();
  private itemWidthArray: number[] = [];
  private itemHeightArray: number[] = [];

  getSize() {
    let ret = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray() {
    for (let i = 0; i < 100; i++) {
      this.itemWidthArray.push(this.getSize());
      this.itemHeightArray.push(this.getSize());
    }
  }

  aboutToAppear() {
    this.setItemSizeArray();
    // Set the initial value of the waterfallFlowColumnsTemplate according to the breakpoints.
    if (this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM &&
      this.currentHeightBreakpoint === HeightBreakpoint.HEIGHT_MD) {
      this.waterFlowColumnsTemplate = '1fr';
    } else if (this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM &&
      this.currentHeightBreakpoint === HeightBreakpoint.HEIGHT_LG) {
      this.waterFlowColumnsTemplate = '1fr 1fr';
    }
    // Define a callback function to listen for the collapse state change event.
    let callback: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
      if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
        this.waterFlowColumnsTemplate = '1fr 1fr';
      } else {
        this.waterFlowColumnsTemplate = '1fr';
      }
      hilog.info(0x0000, TAG, 'Listening enabled. Data: ' + JSON.stringify(data));
    };
    try {
      display.on('foldStatusChange', callback);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to update fold status. Code: ${err.code}, message: ${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column({ space: 2 }) {
        // [Start waterFlow_reading_focus]
        WaterFlow({ layoutMode: WaterFlowLayoutMode.SLIDING_WINDOW }) {
          LazyForEach(this.dataSource, (item: number) => {
            FlowItem() {
              Column() {
                Text('Num' + item).fontSize(12).height('16')
              }
            }
            .onAppear(() => {
              if (item + 20 == this.dataSource.totalCount()) {
                for (let i = 0; i < 100; i++) {
                  this.dataSource.addLastItem();
                }
              }
            })
            .width('100%')
            .height(this.itemHeightArray[item % 100])
            .backgroundColor(this.colors[item % 5])
          }, (item: string) => item)
        }
        .columnsTemplate(this.waterFlowColumnsTemplate)
        // [End waterFlow_reading_focus]
        .columnsGap(10)
        .rowsGap(5)
        .backgroundColor(0xFAEEE0)
        .width('100%')
        .height('100%')
        .onReachStart(() => {
          hilog.info(0x0000, TAG, 'waterFlow reach start');
        })
        .onScrollStart(() => {
          hilog.info(0x0000, TAG, 'waterFlow scroll start');
        })
        .onScrollStop(() => {
          hilog.info(0x0000, TAG, 'waterFlow scroll stop');
        })
        .onScrollFrameBegin((offset: number, state: ScrollState) => {
          hilog.info(0x0000, TAG, 'waterFlow scrollFrameBegin offset: ' + offset + ' state: ' + state.toString());
          return { offsetRemain: offset };
        })
      }
    }
    .height(CommonConstants.HUNDRED_PERCENT)
    .width(CommonConstants.HUNDRED_PERCENT)
    .hideTitleBar(true)
  }
}