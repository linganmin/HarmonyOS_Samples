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
import { BreakpointType } from '../utils/BreakpointSystem';
import { FooterTab, FooterTabData, FooterTabDataEn } from '../model/FooterTabData';
import { HomeConstants } from '../constants/HomeConstants';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct NavigationBarView {
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.LANGUAGE) language: string = CommonConstants.CHINESE_LANGUAGE;
  @State selectIndex: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  public swiperController: SwiperController | undefined = undefined;
  public scroller: Scroller = new Scroller();
  public waterFlowScroller: Scroller = new Scroller();
  private iconArr: FooterTab[] = [];

  aboutToAppear(): void {
    if (this.language === CommonConstants.CHINESE_LANGUAGE) {
      this.iconArr = new FooterTabData().tabList;
    } else {
      this.iconArr = new FooterTabDataEn().tabList;
    }
  }

  build() {
    Row() {
      ForEach(this.iconArr, (item: FooterTab, index: number) => {
        Column() {
          this.setNavigationItem(item, index);
        };
      });
    }
    .width($r('app.string.full_screen'))
    .height($r('app.float.navigation_height'))
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.start_window_background'));
  }

  @Builder
  setNavigationItem(item: FooterTab, index: number) {
    Column({ space: CommonConstants.SPACE_FOUR }) {
      Image(item.icon)
        .objectFit(ImageFit.Fill)
        .width($r('app.float.navigation_icon_size'))
        .height($r('app.float.navigation_icon_size'))
        .margin({ bottom: $r('app.float.margin_4') });

      Text(item.name)
        .fontSize($r('app.float.font_size_10'))
        .fontWeight(FontWeight.Medium);
    }
    .onClick(() => {
      if (item.name === this.iconArr[0].name) {
        this.scroller.scrollTo({ xOffset: 0, yOffset: 0 });
        this.waterFlowScroller.scrollToIndex(0);
      }
    })
    .width(new BreakpointType(
      {
        sm: $r('app.string.full_screen_20'),
        md: $r('app.string.full_screen_20'),
        lg: $r('app.string.full_screen'),
      }
    ).getValue(this.currentBreakpoint))
    .height(new BreakpointType(
      {
        sm: $r('app.string.full_screen'),
        md: $r('app.string.full_screen'),
        lg: $r('app.float.navigation_height_lg'),
      }
    ).getValue(this.currentBreakpoint))
    .opacity(index === 0 ? 1 : $r('app.float.opacity_percent_40'))
    .padding({
      top: new BreakpointType(
        {
          sm: $r('app.float.margin_4'),
          md: $r('app.float.margin_4'),
          lg: $r('app.float.zero'),
        }
      ).getValue(this.currentBreakpoint)
    });
  }
}