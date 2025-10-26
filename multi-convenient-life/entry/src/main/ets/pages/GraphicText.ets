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

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { BreakpointType } from '../utils/BreakpointType';
import { GraphicTextHeader } from '../view/GraphicTextHeader';
import { GraphicTextFooter } from '../view/GraphicTextFooter';
import { GraphicTextSwiper } from '../view/GraphicTextSwiper';
import { GraphicTextDescriptions } from '../view/GraphicTextDescriptions';
import { GraphicTextComments } from '../view/GraphicTextComments';
import { CommonConstants } from '../constants/CommonConstants';

@Entry
@Component
struct GraphicText {
  @StorageLink('currentBreakpoint') @Watch('breakpointChange') currentBreakpoint: string =
    BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowTop') windowTop: number = 0;
  @StorageLink('windowBottom') windowBottom: number = 0;
  @State headerColor: ResourceColor = $r('app.color.graphic_background');
  @State isShowHeader: boolean = true;
  @Provide('upDownStructure') upDownStructure: boolean = true;
  @Provide('showSideBar') showSideBar: boolean = false;
  @Provide('immersivePreview') immersivePreview: boolean = false;
  @Provide('isFullScreen') @Watch('isFullScreenChange') isFullScreen: boolean = false;
  @Provide('fullImageIndex') fullImageIndex: number = 0;
  @Provide('swiperIndex') swiperIndex: number = 0;
  @Provide('imgList') imgList: Array<Resource> =
    [$r('app.media.xq1_img'), $r('app.media.xq2_img'), $r('app.media.xq3_img'), $r('app.media.xq4_img')];
  @State swiperHeight: number = CommonConstants.SWIPER_HEIGHT;
  @State swiperMargin: number = CommonConstants.SWIPER_MARGIN;
  @State swiperItemSpace: number = CommonConstants.SWIPER_ITEM_SPACE;
  @State isSliding: boolean = false;
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();
  private mainScroller: Scroller = new Scroller();

  isFullScreenChange() {
    if (this.isFullScreen) {
      window.getLastWindow(this.getUIContext().getHostContext()).then(async (windowStage: window.Window) => {
        windowStage.setWindowSystemBarEnable([]).catch((error: BusinessError) => {
          hilog.error(0x0000, 'multi-convenient-life', `setWindowSystemBarEnable error. Cause: ${error.code}`);
        });
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'multi-convenient-life', `getLastWindow error. Cause: ${error.code}`);
      });
    } else {
      window.getLastWindow(this.getUIContext().getHostContext()).then(async (windowStage: window.Window) => {
        windowStage.setWindowSystemBarEnable(['status', 'navigation']).catch((error: BusinessError) => {
          hilog.error(0x0000, 'multi-convenient-life', `setWindowSystemBarEnable error. Cause: ${error.code}`);
        });
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'multi-convenient-life', `getLastWindow error. Cause: ${error.code}`);
      });
    }
  }

  breakpointChange() {
    if (this.isFullScreen) {
      this.isFullScreen = false;
    }
  }

  onBackPress(): boolean | void {
    this.pageInfo.pop();
  }

  build() {
    SideBarContainer(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
    SideBarContainerType.Embed : SideBarContainerType.Overlay) {
      Column() {
        GraphicTextComments()
      }

      Stack() {
        if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
          Column() {
            Stack() {
              Scroll(this.mainScroller) {
                GridRow({
                  columns: {
                    sm: BreakpointConstants.GRID_ROW_COLUMNS[5],
                    md: BreakpointConstants.GRID_ROW_COLUMNS[6],
                    lg: BreakpointConstants.GRID_ROW_COLUMNS[0]
                  }
                }) {
                  GridCol({
                    span: {
                      sm: BreakpointConstants.GRID_COLUMN_SPANS[0],
                      md: this.upDownStructure ? BreakpointConstants.GRID_COLUMN_SPANS[5] :
                      BreakpointConstants.GRID_COLUMN_SPANS[1],
                      lg: BreakpointConstants.GRID_COLUMN_SPANS[0]
                    }
                  }) {
                    Column() {
                      GraphicTextSwiper({
                        swiperHeight: this.swiperHeight,
                        swiperMargin: this.swiperMargin,
                        swiperItemSpace: this.swiperItemSpace
                      })
                        .layoutWeight(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ||
                          (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && !this.upDownStructure) ? 1 :
                          0)
                      GraphicTextFooter()
                        .visibility(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ||
                          (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && !this.upDownStructure) ?
                        Visibility.Visible : Visibility.None)
                    }
                    .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ||
                      this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ?
                    CommonConstants.SELF_ADAPTING : CommonConstants.FULL_PERCENT)
                  }

                  GridCol({
                    span: {
                      sm: BreakpointConstants.GRID_COLUMN_SPANS[0],
                      md: this.upDownStructure ? BreakpointConstants.GRID_COLUMN_SPANS[5] :
                      BreakpointConstants.GRID_COLUMN_SPANS[0],
                      lg: BreakpointConstants.GRID_COLUMN_SPANS[0]
                    }
                  }) {
                    Scroll() {
                      GraphicTextDescriptions()
                    }
                    .align(Alignment.Top)
                    .layoutWeight(1)
                    .width(CommonConstants.FULL_PERCENT)
                    .nestedScroll({
                      scrollForward: NestedScrollMode.PARENT_FIRST,
                      scrollBackward: NestedScrollMode.SELF_FIRST
                    })
                    .onScrollFrameBegin((offset: number) => {
                      return { offsetRemain: offset };
                    })
                  }
                  .padding({
                    top: this.upDownStructure ? 0 : $r('app.float.not_up_down_padding')
                  })
                }
                .height(this.upDownStructure ? '100%' : 'auto')
                .margin({
                  top: $r('app.float.title_height')
                })
              }
              .scrollBarWidth(0)
              .layoutWeight(1)
              .onScrollFrameBegin((offset: number) => {
                let yOffset = this.mainScroller.currentOffset().yOffset;
                if (yOffset > CommonConstants.OFFSET_ARRAY[0]) {
                  this.isSliding = true;
                  window.getLastWindow(this.getUIContext().getHostContext()).then((windowStage: window.Window) => {
                    windowStage.setWindowSystemBarEnable([]);
                  });
                } else {
                  this.isSliding = false;
                  window.getLastWindow(this.getUIContext().getHostContext()).then((windowStage: window.Window) => {
                    windowStage.setWindowSystemBarEnable(['status', 'navigation']);
                  });
                }
                if (yOffset < CommonConstants.OFFSET_ARRAY[0]) {
                  this.headerColor = $r('app.color.graphic_background');
                } else if (yOffset < CommonConstants.OFFSET_ARRAY[1]) {
                  this.headerColor = $r('app.color.eighty_graphic_background');
                  this.isShowHeader = true;
                } else if (yOffset < CommonConstants.OFFSET_ARRAY[2]) {
                  this.headerColor = $r('app.color.sixty_graphic_background');
                  this.isShowHeader = true;
                } else if (yOffset < CommonConstants.OFFSET_ARRAY[3]) {
                  this.headerColor = $r('app.color.forty_graphic_background');
                  this.isShowHeader = true;
                } else if (yOffset < CommonConstants.OFFSET_ARRAY[4]) {
                  this.headerColor = $r('app.color.twenty_graphic_background');
                  this.isShowHeader = true;
                } else if (yOffset < CommonConstants.OFFSET_ARRAY[5]) {
                  this.headerColor = $r('app.color.ten_graphic_background');
                  this.isShowHeader = true;
                } else {
                  this.isShowHeader = false;
                }
                this.swiperHeight = CommonConstants.SWIPER_HEIGHT - yOffset * CommonConstants.HEIGHT_COEFFICIENTS;
                this.swiperMargin = CommonConstants.SWIPER_MARGIN + yOffset * CommonConstants.MARGIN_COEFFICIENTS;
                this.swiperItemSpace =
                  CommonConstants.SWIPER_ITEM_SPACE - yOffset * CommonConstants.MARGIN_COEFFICIENTS;
                return { offsetRemain: offset };
              })

              GraphicTextHeader()
                .transition(TransitionEffect.OPACITY.animation({ duration: 0 }))
                .backgroundColor(this.headerColor)
                .visibility(this.isShowHeader ? Visibility.Visible : Visibility.Hidden)
            }
            .layoutWeight(1)
            .alignContent(Alignment.Top)
            .margin({
              top: this.showSideBar ? this.windowTop : 0
            })

            GraphicTextFooter()
              .visibility(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ||
                (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && this.upDownStructure) ?
              Visibility.Visible : Visibility.None)
          }
        } else {
          Column() {
            GraphicTextHeader()
              .transition(TransitionEffect.OPACITY.animation({ duration: 0 }))
            Scroll(this.mainScroller) {
              GridRow({
                columns: {
                  sm: BreakpointConstants.GRID_ROW_COLUMNS[5],
                  md: BreakpointConstants.GRID_ROW_COLUMNS[0],
                  lg: BreakpointConstants.GRID_ROW_COLUMNS[0]
                }
              }) {
                GridCol({
                  span: {
                    sm: BreakpointConstants.GRID_COLUMN_SPANS[0],
                    md: this.upDownStructure ? BreakpointConstants.GRID_COLUMN_SPANS[2] :
                    BreakpointConstants.GRID_COLUMN_SPANS[0],
                    lg: BreakpointConstants.GRID_COLUMN_SPANS[0]
                  }
                }) {
                  Column() {
                    GraphicTextSwiper({
                      swiperHeight: this.swiperHeight,
                      swiperMargin: this.swiperMargin,
                      swiperItemSpace: this.swiperItemSpace
                    })
                      .layoutWeight(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ||
                        (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && !this.upDownStructure) ? 1 : 0)
                    GraphicTextFooter()
                      .visibility(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ||
                        (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && !this.upDownStructure) ?
                      Visibility.Visible : Visibility.None)
                  }
                  .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ||
                    (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && this.upDownStructure) ?
                  CommonConstants.SELF_ADAPTING : CommonConstants.FULL_PERCENT)
                }

                GridCol({
                  span: {
                    sm: BreakpointConstants.GRID_COLUMN_SPANS[0],
                    md: this.upDownStructure ? BreakpointConstants.GRID_COLUMN_SPANS[2] :
                    BreakpointConstants.GRID_COLUMN_SPANS[0],
                    lg: BreakpointConstants.GRID_COLUMN_SPANS[0]
                  }
                }) {
                  Scroll() {
                    GraphicTextDescriptions()
                  }
                  .scrollBarWidth(0)
                  .align(Alignment.Top)
                  .height(this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_SM ?
                  CommonConstants.FULL_PERCENT : CommonConstants.SELF_ADAPTING)
                  .width(CommonConstants.FULL_PERCENT)
                  .nestedScroll({
                    scrollForward: NestedScrollMode.SELF_FIRST,
                    scrollBackward: NestedScrollMode.SELF_FIRST
                  })
                }
              }
            }
            .scrollBarWidth(0)
            .layoutWeight(1)

            GraphicTextFooter()
              .visibility(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ||
                (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && this.upDownStructure) ?
              Visibility.Visible : Visibility.None)
          }
          .margin({
            top: this.showSideBar ? this.windowTop : 0
          })
        }
        if (this.isFullScreen) {
          Swiper() {
            ForEach(this.imgList, ((item: Resource, index: number) => {
              Column() {
                Image(item)
                  .aspectRatio(CommonConstants.GRAPHIC_ASPECT_RATIO)
                  .geometryTransition(CommonConstants.GRAPHIC_GEOMETRY_ID)
                  .transition(TransitionEffect.OPACITY)
                  .id(CommonConstants.GRAPHIC_IMAGE_ID)
                  .onClick(() => {
                    this.getUIContext().animateTo({
                      duration: CommonConstants.ANIMATE_DURATION,
                      curve: Curve.Friction
                    }, () => {
                      this.isFullScreen = false;
                      this.fullImageIndex = index;
                    });
                  })
                  .gesture(
                    PinchGesture({ fingers: 2 })
                      .onActionUpdate((event: GestureEvent) => {
                        this.getUIContext().animateTo({
                          duration: CommonConstants.ANIMATE_DURATION,
                          curve: Curve.Friction
                        }, () => {
                          this.isFullScreen = false;
                          this.fullImageIndex = index;
                        });
                      })
                  )

              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.getUIContext().animateTo({ duration: CommonConstants.DEFAULT_DURATION }, () => {
                  this.isFullScreen = false;
                })
              })
              .backgroundColor(Color.Black)
              .height(CommonConstants.FULL_PERCENT)
              .width(CommonConstants.FULL_PERCENT)
            }))
          }
          .backgroundColor(Color.Black)
          .index($$this.fullImageIndex)
          .height('100%')
          .width('100%')
        }
      }
      .height('100%')
    }
    .backgroundColor('#F1F3F5')
    .showSideBar(this.showSideBar)
    .sideBarPosition(SideBarPosition.End)
    .showControlButton(false)
    .minSideBarWidth(new BreakpointType(
      CommonConstants.FULL_PERCENT,
      CommonConstants.FORTY_PERCENT_STRING,
      CommonConstants.THIRTY_THREE_PERCENT).getValue(this.currentBreakpoint))
    .padding({
      top: this.isSliding || this.showSideBar || this.isFullScreen ? 0 : this.windowTop,
      bottom: this.isFullScreen ? 0 : this.windowBottom
    })
  }
}