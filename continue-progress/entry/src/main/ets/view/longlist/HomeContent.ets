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

import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { WaterFlowView } from './WaterFlowView';
import { WaterFlowListData } from '../../viewmodel/longlist/WaterFlowListData';
import { CommonConstants, NetConnectionState } from '../../constants/CommonConstants';
import { BreakpointConstants } from '../../constants/BreakpointConstants';
import { SearchBarView } from './SearchBarView';
import { FunctionView } from './FunctionView';
import { HomeConstants } from '../../constants/HomeConstants';
import { BreakpointType } from '../../utils/BreakpointSystem';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct HomeContent {
  @StorageLink('pageInfos') pageInfo: NavPathStack = new NavPathStack();
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageProp('topHeight') topHeight: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @StorageLink('currentOffset') currentOffset: number = 0;
  @StorageLink('continueOffset') continueOffset: number = 0;
  @StorageLink('continueHeight') continueHeight: number = 0;
  @StorageLink('listItemHeight') listItemHeight: number = 0;
  @StorageLink('continueBreakpoint') continueBreakpoint: string = '';
  @StorageLink('setCurrentOffset') setCurrentOffset: boolean = false;
  @Link windowsHeight: number;
  @State isShowFoot: boolean = false;
  @State isRefreshing: boolean = false;
  @State waterFlowListData: WaterFlowListData = new WaterFlowListData();
  @State freshFlag: boolean = false;
  @State netConnectState: NetConnectionState = NetConnectionState.UNKNOWN_STATE;
  public scroller: Scroller = new Scroller();
  public waterFlowScroller: Scroller = new Scroller();

  listenNetworkEvent(firstLoading: boolean) {
    let netCon: connection.NetConnection = connection.createNetConnection();
    let loading: boolean = false;
    netCon.register((error: BusinessError) => {
      hilog.info(0x000, 'progress', JSON.stringify(error));
    });
    netCon.on('netUnavailable', () => {
      if (!loading) {
        loading = true;
        if (this.netConnectState !== NetConnectionState.SUCCEED_STATE) {
          this.netConnectState = NetConnectionState.LOADING_STATE;
          setTimeout(() => {
            this.netConnectState = NetConnectionState.FAIL_STATE;
          }, 3000);
        } else {
          try {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.net_connection_description'),
              bottom: 120,
              duration: 3000
            });
          } catch (error) {
            let message = (error as BusinessError).message;
            let code = (error as BusinessError).code;
            hilog.error(0x000, 'progress', 'showToast args error code is ', code.toString(), 'message is ',
              message.toString());
          }
        }
      }
    });
    netCon.on('netAvailable', () => {
      if (!loading) {
        loading = true;
        this.netConnectState = NetConnectionState.SUCCEED_STATE;
        if (!firstLoading) {
          this.isShowFoot = false;
          setTimeout(() => {
            this.waterFlowListData.dataSource.clearData();
            this.waterFlowListData.addData(CommonConstants.MOCK_INTERFACE_WATER_FLOW_FILE_NAME,
              Math.ceil(Math.random() * 20), CommonConstants.WATER_FLOW_PAGE_SIZE);
            this.freshFlag = !this.freshFlag;
            this.isRefreshing = false;
          }, 1000);
        }
      }
    });
    setTimeout(() => {
      this.isRefreshing = false;
      netCon.unregister((error: BusinessError) => {
        hilog.error(0x000, 'progress', 'unregister err:' + JSON.stringify(error));
      });
    }, 1000);
  }

  aboutToAppear(): void {
    this.listenNetworkEvent(true);
  }

  // [Start on_did_build]
  onDidBuild(): void {
    hilog.info(0x000, 'progress', `onDidBuild ${this.setCurrentOffset} ${this.continueOffset}`);
    if (this.setCurrentOffset) {
      this.scroller.scrollTo({ xOffset: 0, yOffset: this.continueOffset });
      this.setCurrentOffset = false;
    }
  }

  // [End on_did_build]

  build() {
    Column() {
      if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ||
        this.currentBreakpoint === BreakpointConstants.BREAKPOINT_XL) {
        Row() {
          Row() {
            Image($r('app.media.back'))
              .width(40)
              .height(40)
              .margin({
                right: 8
              })
              .onClick(() => {
                this.pageInfo.pop();
              })
            Text($r('app.string.button1'))
              .fontSize(20)
              .fontWeight(700)
              .lineHeight(27)
          }
          .height(56)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)

          .padding({
            left: 19,
            right: 19
          })

          SearchBarView()
            .width(400)
            .height(56)
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({
          top: this.topHeight,
          bottom: 16
        })
      } else {
        Row() {
          Image($r('app.media.back'))
            .width(40)
            .height(40)
            .margin({
              right: 8
            })
            .onClick(() => {
              this.pageInfo.pop();
            })
          Text($r('app.string.button1'))
            .fontSize(20)
            .fontWeight(700)
            .lineHeight(27)
        }
        .height(56)
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .margin({
          top: this.topHeight
        })
        .padding({
          left: 19,
          right: 19
        })

        SearchBarView()
          .margin({
            bottom: 16
          })
      }
      Column() {
        // [Start scroll_water_flow_view]
        Scroll(this.scroller) {
          // [StartExclude scroll_water_flow_view]
          if (this.netConnectState === NetConnectionState.SUCCEED_STATE) {
            Column() {
              FunctionView({ freshFlag: this.freshFlag });
              WaterFlowView({
                waterFlowListData: this.waterFlowListData,
                waterFlowScroller: this.waterFlowScroller,
                scroller: this.scroller,
                windowsHeight: this.windowsHeight,
                isShowFoot: this.isShowFoot
              })
            }
            .justifyContent(FlexAlign.Start);
          } else if (this.netConnectState === NetConnectionState.LOADING_STATE) {
            Column() {
              this.loadingData()
            }
            .justifyContent(FlexAlign.Start);
          } else if (this.netConnectState === NetConnectionState.FAIL_STATE) {
            Column() {
              this.netUnavailable()
            }
            .justifyContent(FlexAlign.Start)
          }
        }
        // [EndExclude scroll_water_flow_view]
        .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
          if (!this.setCurrentOffset) {
            this.currentOffset = this.scroller.currentOffset().yOffset;
          }
        })
        // [End scroll_water_flow_view]
        .width(CommonConstants.FULL_PERCENT)
        .scrollBar(BarState.Off)
      }
    }
    .backgroundColor($r('app.color.start_window_background'))
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  loadingData() {
    Stack() {
      Column() {
        Grid() {
          ForEach(HomeConstants.FUNCTION_DEFAULT_ICONS.slice(CommonConstants.NUMBER_DEFAULT_VALUE,
            CommonConstants.FUNCTION_FIRST_COUNT),
            () => {
              GridItem() {
                Column() {
                  Column() {
                  }
                  .height($r('app.float.function_gridItem_image_height'))
                  .width($r('app.float.function_gridItem_image_width'))
                  .backgroundColor($r('app.color.function_default_color'));

                  Column() {
                  }
                  .height($r('app.float.function_gridItem_gray_height'))
                  .width($r('app.float.function_gridItem_gray_width'))
                  .backgroundColor($r('app.color.function_default_color'))
                  .margin({ top: $r('app.float.function_gridItem_gray_marge_top') })
                }
              }
              .width($r('app.float.function_gridItem_width'))
              .height($r('app.float.function_gridItem_height'));
            }, (index: number): string => index.toString());
        }
        .rowsGap($r('app.float.function_row_gap'))
        .padding({
          bottom: $r('app.float.function_padding_default_bottom'),
          left: $r('app.float.function_padding_left'),
          right: $r('app.float.function_padding_right'),
        })
        .height($r('app.float.function_two_lines_default_height'))
        .rowsTemplate(HomeConstants.FUNCTION_ROWS_PAGE_ONE)
        .columnsTemplate(HomeConstants.FUNCTION_COLUMN)

        Grid() {
          ForEach(HomeConstants.FUNCTION_DEFAULT_ICONS.slice(CommonConstants.NUMBER_DEFAULT_VALUE,
            CommonConstants.WATER_FLOW_DEFAULT_PAGE_COUNT),
            () => {
              GridItem() {
                Column() {
                }
                .height($r('app.float.water_flow_gridItem_image_height'))
                .width(CommonConstants.FULL_PERCENT)
                .backgroundColor($r('app.color.function_default_color'))
                .borderRadius($r('app.float.rounded_size_16'));
              };
            }, (index: number): string => index.toString());
        }
        .rowsGap($r('app.float.water_flow_default_item_gap'))
        .columnsGap($r('app.float.water_flow_default_item_gap'))
        .padding({
          bottom: $r('app.float.function_padding_bottom'),
          left: $r('app.float.function_padding_left'),
          right: $r('app.float.function_padding_right')
        })
        .height($r('app.float.water_flow_default_height'))
        .rowsTemplate(BreakpointConstants.GRID_NUM_TWO)
        .columnsTemplate(new BreakpointType({
          sm: BreakpointConstants.GRID_NUM_TWO,
          md: BreakpointConstants.GRID_NUM_THREE,
          lg: BreakpointConstants.GRID_NUM_THREE,
          xl: BreakpointConstants.GRID_NUM_THREE
        }).getValue(this.currentBreakpoint))
      }

      LoadingProgress()
        .color(Color.Black)
        .opacity($r('app.float.net_unavailable_opacity'))
        .width($r('app.float.net_unavailable_loading_width'))
        .height($r('app.float.net_unavailable_loading_height'))
    }
  }

  @Builder
  netUnavailable() {
    Column() {
      Image($r('app.media.moon'))
        .width($r('app.float.net_unavailable_moon_width'))
        .height($r('app.float.net_unavailable_moon_height'))
        .margin({
          top: $r('app.float.net_unavailable_moon_margin_top'),
          bottom: $r('app.float.net_unavailable_moon_margin_bottom')
        });
      Text($r('app.string.net_connection_description'))
        .fontSize($r('app.float.net_unavailable_text_fontsize'))
        .opacity($r('app.float.net_unavailable_opacity'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}