/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { WidthBreakpointType } from '../utils/WidthBreakpointType';
import { WindowInfo } from '../utils/WindowUtil';

@Component
export struct WaterFlowView {
  @ObjectLink mainWindowInfo: WindowInfo;
  pageInfos: NavPathStack = new NavPathStack();
  dataSource: WaterFlowDataSource = new WaterFlowDataSource();
  itemHeightArray: number[] = [];

  // Calculate flow item width/height.
  getSize(): number {
    return 200 + Math.random() * 100;
  }

  setItemSizeArray() {
    for (let i = 0; i < 24; i++) {
      this.itemHeightArray.push(this.getSize());
    }
  }

  aboutToAppear(): void {
    this.dataSource = new WaterFlowDataSource();
    this.setItemSizeArray();
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Image($r('app.media.ic_public_back'))
            .width(40)
            .height(40)
            .margin({ right: 12 })
            .onClick(() => {
              this.pageInfos.pop();
            })
          Text($r('app.string.water_flow'))
            .fontSize(24)
        }
        .width('100%')
        .margin({ bottom: 12 })

        // [Start water_flow_view]
        WaterFlow() {
          LazyForEach(this.dataSource, (item: number, index: number) => {
            FlowItem() {
              Row() {}
              .width('100%')
              .height('100%')
              .borderRadius(16)
              .backgroundColor('#F1F3F5')
            }
            .width('100%')
            .height(this.itemHeightArray[index])
          }, (item: number, index: number) => JSON.stringify(item) + index)
        }
        .columnsTemplate(`repeat(${new WidthBreakpointType(2, 3, 4).getValue(this.mainWindowInfo.widthBp)}, 1fr)`)
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
        // [End water_flow_view]
      }
      .padding({
        top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12,
        bottom: this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height),
        left: 16,
        right: 16
      })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Center)
    .scrollBar(BarState.Off)
  }
}

export class WaterFlowDataSource implements IDataSource {
  private dataArray: number[] = [];

  constructor() {
    for (let i = 0; i < 24; i++) {
      this.dataArray.push(i);
    }
  }

  public getData(index: number): number {
    return this.dataArray[index];
  }

  public totalCount(): number {
    return this.dataArray.length;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}