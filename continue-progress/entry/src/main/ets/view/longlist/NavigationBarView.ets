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

import { BreakpointConstants } from '../../constants/BreakpointConstants';
import { BreakpointType } from '../../utils/BreakpointSystem';
import { FooterTab, FooterTabData, FooterTabDataEn } from '../../viewmodel/longlist/FooterTabData';
import { CommonConstants } from '../../constants/CommonConstants';

@Component
export struct NavigationBarView {
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.LANGUAGE) @Watch('changeTab') language: string = CommonConstants.CHINESE_LANGUAGE;
  @StorageLink('bottomHeight') bottomHeight: number = 0;
  @State selectIndex: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @State iconArr: FooterTab[] = [];
  public swiperController: SwiperController | undefined = undefined;
  public scroller: Scroller = new Scroller();
  public waterFlowScroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.changeTab();
  }

  changeTab() {
    if (this.language.includes(CommonConstants.CHINESE_LANGUAGE)) {
      this.iconArr = new FooterTabData().tabList;
    } else {
      this.iconArr = new FooterTabDataEn().tabList;
    }
  }

  build() {
    Flex({
      direction: this.currentBreakpoint === 'lg' || this.currentBreakpoint === 'xl' ? FlexDirection.Column :
      FlexDirection.Row,
      justifyContent: this.currentBreakpoint === 'xl' ? FlexAlign.Start : FlexAlign.SpaceBetween
    }) {
      ForEach(this.iconArr, (item: FooterTab, index: number) => {
        Column() {
          this.setNavigationItem(item, index);
        }
      }, (index: number) => JSON.stringify(index));
    }
    .width(new BreakpointType(
      {
        sm: '100%',
        md: '100%',
        lg: '84vp',
        xl: '240vp'
      }
    ).getValue(this.currentBreakpoint))
    .height(new BreakpointType(
      {
        sm: '84vp',
        md: '84vp',
        lg: '100%',
        xl: '100%'
      }
    ).getValue(this.currentBreakpoint))
    .backgroundColor($r('app.color.start_window_background'))
    .backgroundBlurStyle(BlurStyle.Thin, {
      colorMode: ThemeColorMode.LIGHT,
      adaptiveColor: AdaptiveColor.DEFAULT,
      policy: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ||
        this.currentBreakpoint === BreakpointConstants.BREAKPOINT_XL ? BlurStyleActivePolicy.ALWAYS_INACTIVE :
      BlurStyleActivePolicy.ALWAYS_ACTIVE
    })
    .padding({
      top: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_XL ? 56 : 0,
      left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_XL ? 16 : 0,
      right: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_XL ? 16 : 0,
      bottom: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_XL ||
        this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 0 : this.bottomHeight
    })
  }

  @Builder
  setNavigationItem(item: FooterTab, index: number) {
    if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_XL) {
      Row({ space: 8 }) {
        Image(item.icon)
          .objectFit(ImageFit.Fill)
          .width($r('app.float.navigation_icon_size'))
          .height($r('app.float.navigation_icon_size'))
          .margin({ bottom: $r('app.float.margin_4') })

        Text(item.name)
          .fontSize(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_XL ? 16 : 10)
          .fontWeight(FontWeight.Medium)
      }
      .height(40)
      .margin({
        left: 8
      })
    } else {
      Column({ space: CommonConstants.SPACE_FOUR }) {
        Image(item.icon)
          .objectFit(ImageFit.Fill)
          .width($r('app.float.navigation_icon_size'))
          .height($r('app.float.navigation_icon_size'))
          .margin({ bottom: $r('app.float.margin_4') })

        Text(item.name)
          .fontSize($r('app.float.font_size_10'))
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
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
          xl: $r('app.string.full_screen')
        }
      ).getValue(this.currentBreakpoint))
      .height(new BreakpointType(
        {
          sm: $r('app.string.full_screen'),
          md: $r('app.string.full_screen'),
          lg: $r('app.string.full_screen_20'),
          xl: $r('app.string.full_screen_20')
        }
      ).getValue(this.currentBreakpoint))
      .opacity(index === 0 ? 1 : $r('app.float.opacity_percent_40'))
      .padding({
        top: new BreakpointType(
          {
            sm: $r('app.float.margin_4'),
            md: $r('app.float.margin_4'),
            lg: $r('app.float.zero'),
            xl: $r('app.float.zero')
          }
        ).getValue(this.currentBreakpoint)
      })
    }
  }
}