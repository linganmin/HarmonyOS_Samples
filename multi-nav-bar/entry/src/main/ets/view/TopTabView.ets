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

import { BreakpointType } from '../common/utils/BreakpointType';
import { TabDataModel } from '../model/TabDataModel';
import { VideoInfoView } from './VideoInfoView';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct TopTabView {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'sm';
  @State secondLevelIndex: number = 0;
  @Link firstLevelIndex: number;
  @Link tabData: TabDataModel;
  private firstLevel: string = this.getFirstLevel();

  getFirstLevel() {
    let res: string = '';
    try {
      res = this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.tab_home').id);
    } catch (error) {
      hilog.error(0x0000, 'testTag', 'Failed to get string. Cause: %{public}s', JSON.stringify(error) ?? '');
    }
    return res;
  }

  build() {
    // [Start top_tab_view]
    // entry/src/main/ets/view/TopTabView.ets
    Column() {
      List() {
        ForEach(this.tabData.getSecondList(this.firstLevel), (item: string, index: number) => {
          ListItem() {
            Text(item)
              .fontSize(index === this.secondLevelIndex ? '24fp' : '18fp')
              .fontWeight(index === this.secondLevelIndex ? 700 : 500)
              .fontColor(index === this.secondLevelIndex ? '#E6000000' : '#99000000')
              .width(index === this.secondLevelIndex ? 65 : 50)
              .textAlign(TextAlign.Center)
              .lineHeight(index === this.secondLevelIndex ? 33 : 25)
              .borderRadius(4)
                // [StartExclude top_tab_view]
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            // [EndExclude top_tab_view]
          }
          // [StartExclude top_tab_view]
          .align(Alignment.Center)
          .margin({
            top: index === this.secondLevelIndex ? 12 : 18,
            bottom: index === this.secondLevelIndex ? 11 : 13
          })
          .padding({
            left: new BreakpointType(8, 12, 18, 0).getValue(this.currentWidthBreakpoint),
            right: new BreakpointType(8, 12, 18, 0).getValue(this.currentWidthBreakpoint)
          })
          // [EndExclude top_tab_view]
          .onClick(() => {
            this.secondLevelIndex = index;
          })
        }, (item: string, index: number) => index + item)
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .padding({ left: 24 })
      .height(56)
      .width('100%')

      VideoInfoView({
        firstLevelIndex: this.firstLevelIndex,
        secondLevelIndex: this.secondLevelIndex
      })
    }
    .height('100%')
    .width('100%')
    .padding({
      top: 30
    })
    // [End top_tab_view]
  }
}