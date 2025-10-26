/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

// entry\src\main\ets\pages\WaterFlowPage.ets
import { hilog } from '@kit.PerformanceAnalysisKit';
import { WaterFlowDataSource } from '../viewModel/WaterFlowDataSource';
import { TrackNode, Track } from '../viewModel/TrackNode';
import WaterFlowCard from './WaterFlowCard';

@Builder
export function WaterFlowPageBuilder() {
  WaterFlowPage()
}

@Component
export struct WaterFlowPage {
  @State minSize: number = 80;
  @State maxSize: number = 180;
  @State fontSize: number = 24;
  @State colors: number[] = [0xFFC0CB, 0xDA70D6, 0x6B8E23, 0x6A5ACD, 0x00FFFF, 0x00FF7F];
  scroller: Scroller = new Scroller();
  dataSource: WaterFlowDataSource = new WaterFlowDataSource();
  private itemWidthArray: number[] = [];
  private itemHeightArray: number[] = [];

  // Calculate FlowItem width/height
  getSize() {
    let ret = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  // Sets the width/height array of FlowItem.
  setItemSizeArray() {
    for (let i = 0; i < 100; i++) {
      this.itemWidthArray.push(this.getSize());
      this.itemHeightArray.push(this.getSize());
    }
  }

  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (error) {
      hilog.error(0x0000, '[getResourceString]', `getResourceString err: ${JSON.stringify(error)}`);
    }
    return resourceString;
  }

  aboutToAppear() {
    this.setItemSizeArray();
  }

  @Builder
  itemFoot() {
    Text(`Footer`)
      .fontSize(10)
      .backgroundColor(Color.Red)
      .width(50)
      .height(50)
      .align(Alignment.Center)
      .margin({ top: 2 })
  }
  build() {
    NavDestination() {
      Column({ space: 2 }) {
        // [Start track_node]
        // entry\src\main\ets\pages\WaterFlowPage.ets
        TrackNode({ track: new Track().id('WaterFlow-1') }) {
          WaterFlow() {
            LazyForEach(this.dataSource, (item: number, index: number) => {
              FlowItem() {
                TrackNode({ track: new Track().id(`flowItem_${index}`) }) {
                  WaterFlowCard({ item: item, index: index }).id(`flowItem_${index}`)
                }
              }
              // [StartExclude track_node]
              .borderRadius(12)
              .width('100%')
              .height(500)
              .backgroundColor(this.colors[item % 5])
              // [EndExclude track_node]
            }, (item: number) => item.toString())
          }
          .id('WaterFlow-1')
          // [StartExclude track_node]
          .columnsTemplate('1fr 1fr')
          .columnsGap(10)
          .rowsGap(5)
          .backgroundColor(0xFAEEE0)
          .width('100%')
          .height('100%')
          // [EndExclude track_node]
          .onReachStart(() => {
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'waterFlow reach start');
          })
          .onScrollStart(() => {
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'waterFlow scroll start');
          })
          .onScrollStop(() => {
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'waterFlow scroll stop');
          })
          .onScrollFrameBegin((offset: number, state: ScrollState) => {
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `waterFlow scrollFrameBegin offset: ${offset}`);
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
              `waterFlow scrollFrameBegin state: ${state.toString()}`);
            return { offsetRemain: offset };
          })
        }
        // [Start track_node]
      }
      .margin({
        right: 12,
        left: 12
      })
    }
    .title(this.getResourceString($r('app.string.exposure_embedment_point_detail')))
    .backgroundColor('#F1F3F5')
  }
}

