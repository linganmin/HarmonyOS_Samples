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

import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../constants/CommonConstants';
import { DetailView } from '../views/DetailView';
import { ShortVideoView } from '../views/ShortVideoView';
import { WaterFlowView } from '../views/WaterFlowView';

const TAG: string = 'index';

@Entry
@Component
struct Index {
  // [Start avoid_value]
  @StorageLink('topAvoidHeight') @Watch('topBarHeightChange') topAvoidHeight: number = 0;
  @StorageLink('bottomAvoidHeight') @Watch('bottomBarHeightChange') bottomAvoidHeight: number = 0;
  // [StartExclude avoid_value]
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = WidthBreakpoint.WIDTH_SM;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: number = HeightBreakpoint.HEIGHT_SM;
  // [Start state_value]
  @StorageLink('topBarHeight') topBarHeight: number = CommonConstants.UTIL_HEIGHTS[1] + this.topAvoidHeight;
  @State bottomBarHeight: number = CommonConstants.UTIL_HEIGHTS[0] + this.bottomAvoidHeight;
  @State barOpacity: number = 1;
  // [End state_value]
  @State currentBottomIndex: number = 0;
  // The current vertical sliding distance of the list.
  @State currentYOffset: number = 0;
  // Whether the list slide to the bottom
  @State isReachingEnd: boolean = false;
  @State currentIndex: number = 0;
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();
  private listScroller: ListScroller = new ListScroller();
  private listArray: Resource[] = CommonConstants.INDEX_SCENES;
  private isHiding: boolean = false;

  // [Start list_reading_focus1]
  aboutToAppear(): void {
    let callback: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
      if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
        this.barOpacity = 1;
        this.listScroller.scrollToIndex(this.currentIndex);
      } else if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
        this.listScroller.scrollToIndex(this.currentIndex);
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

  // [End list_reading_focus1]

  // [EndExclude avoid_value]
  topBarHeightChange(): void {
    if (this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM &&
      (this.currentHeightBreakpoint === HeightBreakpoint.HEIGHT_MD ||
        this.currentHeightBreakpoint === HeightBreakpoint.HEIGHT_SM)) {
      this.topBarHeight = 78 + this.topAvoidHeight;
    }
    // [StartExclude avoid_value]
    else {
      this.topBarHeight = 134 + this.topAvoidHeight;
    }
    // [EndExclude avoid_value]
  };

  bottomBarHeightChange(): void {
    this.bottomBarHeight = 56 + this.bottomAvoidHeight;
  };

  // [End avoid_value]

  @Builder
  pageMap(name: string) {
    if (name === 'shortVideo') {
      ShortVideoView()
    } else if (name === 'detailView') {
      DetailView()
    } else {
      WaterFlowView()
    }
  }

  @Builder
  bottomTabBuilder(index: number) {
    Column() {
      // Bottom tab.
      Image(index === this.currentBottomIndex ? $r('app.media.tab_user_selected') : $r('app.media.tab_user'))
        .width($r('app.float.image_size_sm'))
        .height($r('app.float.image_size_sm'))
      Text(CommonConstants.INDEX_TAB_NAME)
        .fontSize($r('app.float.tab_font_size'))
        .fontWeight(CommonConstants.FONT_WEIGHTS[0])
        .fontColor(index === this.currentBottomIndex ? $r('app.color.font_blue') : Color.Black)
        .margin({ top: $r('app.float.margin_sm') })
        .opacity(index === this.currentBottomIndex ? 1 : CommonConstants.OPACITY)
    }
    .height(CommonConstants.HUNDRED_PERCENT)
    .width(CommonConstants.HUNDRED_PERCENT)
    // Control the transparency of the tab bar during sliding.
    .opacity(this.barOpacity)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.grey_background'))
    .padding({ bottom: this.bottomAvoidHeight })
  }

  build() {
    Navigation(this.pageInfo) {
      // [Start main_view]
      Tabs() {
        TabContent() {
          Stack({ alignContent: Alignment.Top }) {
            Row() {
              Text($r('app.string.app_title'))
                .fontSize($r('app.float.font_size_xl'))
                .fontWeight(CommonConstants.FONT_WEIGHTS[1])
                .height(this.topBarHeight)
                .align(Alignment.Bottom)
                .padding({ bottom: 12 })
            }
            .height(this.topBarHeight)
            .opacity(this.barOpacity)
            // [StartExclude main_view]
            .width(CommonConstants.HUNDRED_PERCENT)
            .padding({
              left: $r('app.float.margin_xl'),
              right: $r('app.float.margin_xl')
            })
            .backgroundColor($r('app.color.grey_background'))

            // [EndExclude main_view]
            // [Start list_reading_focus2]
            List({
              space: CommonConstants.LIST_SPACE[0],
              scroller: this.listScroller,
            }) {
              // [StartExclude list_reading_focus2]
              // [StartExclude main_view]
              // Content list.
              ForEach(this.listArray, (item: string, index: number) => {
                ListItem() {
                  Row() {
                    Text(item)
                      .fontSize($r('app.float.font_size_lg'))
                      .fontWeight(CommonConstants.FONT_WEIGHTS[0])
                      .lineHeight($r('app.float.line_height_lg'))
                    Blank()
                    Image($r('app.media.icon_arrow_right'))
                      .height($r('app.float.image_size_sm'))
                      .width($r('app.float.image_size_xxs'))
                  }
                  .backgroundColor(Color.White)
                  .height($r('app.float.index_item_height'))
                  .width(CommonConstants.HUNDRED_PERCENT)
                  .borderRadius($r('app.float.margin_xl'))
                  .padding({
                    left: $r('app.float.margin_lg'),
                    right: $r('app.float.margin_lg')
                  })
                  .onClick(() => {
                    if (index === 0) {
                      this.pageInfo.pushPath({ name: 'shortVideo' });
                    } else if (index === 1) {
                      this.pageInfo.pushPath({ name: 'detailView' })
                    } else if (index === 2) {
                      this.pageInfo.pushPath({ name: 'waterFlow' })
                    }
                  })
                }
                .width(CommonConstants.HUNDRED_PERCENT)
                .padding({
                  left: $r('app.float.margin_xl'),
                  right: $r('app.float.margin_xl')
                })
              }, (item: number, index: number) => JSON.stringify(item) + index)
              // [EndExclude main_view]
              // [EndExclude list_reading_focus2]
            }
            .onScrollIndex((start: number) => {
              this.currentIndex = start;
            })
            // [End list_reading_focus2]
            .margin({ top: this.topBarHeight })
            // [StartExclude main_view]
            .backgroundColor($r('app.color.grey_background'))
            .scrollBar(BarState.Off)
            // [Start scroll_effect]
            .onScrollFrameBegin((offset: number) => {
              if (this.currentWidthBreakpoint !== WidthBreakpoint.WIDTH_SM ||
                (this.currentHeightBreakpoint !== HeightBreakpoint.HEIGHT_MD &&
                  this.currentHeightBreakpoint !== HeightBreakpoint.HEIGHT_SM)) {
                return { offsetRemain: offset };
              }
              if (offset > 0) {
                this.currentYOffset += offset;
                if (this.currentYOffset <= 100) {
                  this.bottomBarHeight = this.bottomBarHeight * (1 - this.currentYOffset / 100);
                  this.topBarHeight = this.topBarHeight * (1 - this.currentYOffset / 100);
                  this.barOpacity = 1 - this.currentYOffset / 100;
                } else {
                  this.topBarHeight = 0;
                  this.bottomBarHeight = 0;
                  this.barOpacity = 0;
                }
                this.isHiding = true;
              }
              if (offset < 0 && this.isHiding) {
                this.getUIContext().animateTo({
                  duration: 300
                }, () => {
                  this.bottomBarHeight = 56 + this.bottomAvoidHeight;
                  this.topBarHeight = 78 + this.topAvoidHeight;
                  this.barOpacity = 1;
                  this.currentYOffset = 0;
                  this.isHiding = false;
                });
              }
              return { offsetRemain: offset };
            })

            // [End scroll_effect]
            // [EndExclude main_view]
          }
          .height('100%')
          .width('100%')
        }
        .tabBar(this.bottomTabBuilder(0))

        // [StartExclude main_view]

        TabContent()
          .tabBar(this.bottomTabBuilder(1))

        TabContent()
          .tabBar(this.bottomTabBuilder(2))

        TabContent()
          .tabBar(this.bottomTabBuilder(3))

        // [EndExclude main_view]
      }
      // [StartExclude main_view]
      .height(CommonConstants.HUNDRED_PERCENT)
      .width(CommonConstants.HUNDRED_PERCENT)
      .vertical(false)
      .barPosition(BarPosition.End)
      // [EndExclude main_view]
      .barHeight(this.bottomBarHeight)
      // [StartExclude main_view]
      .onChange((index: number) => {
        this.currentBottomIndex = index;
      })
      .scrollable(false)

      // [EndExclude main_view]
      // [End main_view]
    }
    .height(CommonConstants.HUNDRED_PERCENT)
    .width(CommonConstants.HUNDRED_PERCENT)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .hideToolBar(true)
    .hideTitleBar(true)
    .navDestination(this.pageMap)
  }

  aboutToDisappear(): void {
    let callback: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
      hilog.info(0x0000, TAG, 'unregistering FoldStatus changes callback. Data: ' + JSON.stringify(data));
    };
    try {
      display.off('foldStatusChange', callback);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to off fold status. Code: ${err.code}, message: ${err.message}`);
    }
  }
}