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

import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { WaterFlowView } from './WaterFlowView';
import { WaterFlowListData } from '../model/WaterFlowListData';
import { CommonConstants, NetConnectionState } from '../constants/CommonConstants';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { SearchBarView } from './SearchBarView';
import { FunctionView } from './FunctionView';
import { HomeConstants } from '../constants/HomeConstants';
import { BreakpointType } from '../utils/BreakpointSystem';
import Logger from '../utils/Logger';

@Component
export struct HomeContent {
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
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
      Logger.info(JSON.stringify(error));
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
            Logger.error('showToast args error code is ', code.toString(), 'message is ', message.toString());
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
          // 模拟网络请求，设置1s延迟
          setTimeout(() => {
            this.waterFlowListData.dataSource.clearData();
            // 通过随机数来模拟刷新获取不同数据的效果
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
        Logger.error('unregister err:' + JSON.stringify(error));
      });
    }, 1000);
  }

  aboutToAppear(): void {
    this.listenNetworkEvent(true);
  }

  build() {
    Column() {
      SearchBarView();
      Refresh({ refreshing: $$this.isRefreshing, builder: this.refreshComponent() }) {
        Scroll(this.scroller) {
          if (this.netConnectState === NetConnectionState.SUCCEED_STATE) {
            Column() {
              FunctionView({ freshFlag: this.freshFlag });
              WaterFlowView({
                waterFlowListData: this.waterFlowListData,
                waterFlowScroller: this.waterFlowScroller,
                scroller: this.scroller,
                windowsHeight: this.windowsHeight,
                isShowFoot: this.isShowFoot
              });
            }
            .justifyContent(FlexAlign.Start);
          } else if (this.netConnectState === NetConnectionState.LOADING_STATE) {
            Column() {
              this.loadingData();
            }
            .justifyContent(FlexAlign.Start);
          } else if (this.netConnectState === NetConnectionState.FAIL_STATE) {
            Column() {
              this.netUnavailable();
            }
            .justifyContent(FlexAlign.Start);
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .scrollBar(BarState.Off);
      }
      .refreshOffset(CommonConstants.PULL_TO_REFRESH_HEIGHT)
      .onRefreshing(() => {
        this.listenNetworkEvent(this.netConnectState !== NetConnectionState.SUCCEED_STATE);
      });
    }
    .backgroundColor($r('app.color.start_window_background'))
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT);
  }
  @Builder
  refreshComponent(){
    Column(){
      if (this.netConnectState === NetConnectionState.SUCCEED_STATE) {
        LoadingProgress()
          .color(Color.Black)
          .opacity($r('app.float.net_unavailable_opacity'))
          .width($r('app.float.net_unavailable_loading_little_width'))
          .height($r('app.float.net_unavailable_loading_little_height'));
      }
    }
    .justifyContent(FlexAlign.Center);
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
                  .margin({ top: $r('app.float.function_gridItem_gray_marge_top') });
                };
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
        .columnsTemplate(HomeConstants.FUNCTION_COLUMN);

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
          right: $r('app.float.function_padding_right'),
        })
        .height($r('app.float.water_flow_default_height'))
        .rowsTemplate(BreakpointConstants.GRID_NUM_TWO)
        .columnsTemplate(new BreakpointType({
          sm: BreakpointConstants.GRID_NUM_TWO,
          md: BreakpointConstants.GRID_NUM_THREE,
          lg: BreakpointConstants.GRID_NUM_THREE
        }).getValue(this.currentBreakpoint));
      };

      LoadingProgress()
        .color(Color.Black)
        .opacity($r('app.float.net_unavailable_opacity'))
        .width($r('app.float.net_unavailable_loading_width'))
        .height($r('app.float.net_unavailable_loading_height'));
    };
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
        .opacity($r('app.float.net_unavailable_opacity'));
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT);
  }
}