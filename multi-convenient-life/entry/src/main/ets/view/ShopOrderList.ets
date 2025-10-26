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

import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointType } from '../utils/BreakpointType';
import { ShopMenu } from './ShopMenu';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct ShopOrderList {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowTop') windowTop: number = 0;
  @StorageLink('windowBottom') windowBottom: number = 0;
  @Provide('ifScroll') ifScroll: boolean = false;
  @Consume('ifShowSides') ifShowSides: boolean;
  @State topTabsIndex: number = 0;
  private topTabsController: TabsController = new TabsController();
  private tabsList: string[] =
    [this.ResourceToString($r('app.string.order')), this.ResourceToString($r('app.string.appraise')),
      this.ResourceToString($r('app.string.preferential')), this.ResourceToString($r('app.string.business'))];

  build() {
    Column() {
      Row() {
        ForEach(this.tabsList, (item: string, index) => {
          Column() {
            Stack({ alignContent: Alignment.Bottom }) {
              Text(item)
                .fontSize($r('app.float.food_data_font'))
                .fontWeight(CommonConstants.FONT_WEIGHT_600)
                .margin({
                  bottom: $r('app.float.eight_padding')
                })
              Divider()
                .vertical(false)
                .color($r('app.color.currency_symbol'))
                .width($r('app.float.dish_lg'))
                .strokeWidth(2)
                .visibility(this.topTabsIndex === index ? Visibility.Visible : Visibility.None)
            }
          }
          .onClick(() => {
            this.topTabsIndex = index
            this.topTabsController.changeIndex(index)
          })
          .padding({
            right: $r('app.float.padding_small')
          })
        })
      }
      .padding({
        left: this.ifShowSides ? new BreakpointType($r('app.float.padding_small'), $r('app.float.padding_small'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint) :
        new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
          $r('app.float.common_padding')).getValue(this.currentBreakpoint)
      })

      // [Start scroll_in_tabs]
      Tabs({ controller: this.topTabsController }) {
        ForEach(this.tabsList, () => {
          TabContent() {
            ShopMenu().width(CommonConstants.FULL_PERCENT)
          }
        })
      }
      // [End scroll_in_tabs]
      .layoutWeight(1)
      .barHeight(0)
      .vertical(false)
      .onChange((index: number) => {
        this.topTabsIndex = index
      })
      .barMode(BarMode.Scrollable)
    }
    .alignItems(HorizontalAlign.Start)
    .margin({
      top: this.ifScroll ? this.windowTop : $r('app.float.tabs_padding')
    })
  }

  ResourceToString(resource: Resource): string {
    try {
      return this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (e) {
      hilog.error(0x0000, 'multi-convenient-life', `getStringSync error. Cause: ${JSON.stringify(e)}`);
    }
    return '';
  }
}