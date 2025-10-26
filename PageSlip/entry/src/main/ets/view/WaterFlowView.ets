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

import { display } from '@kit.ArkUI';
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointType } from '../utils/BreakpointSystem';
import { WaterFlowListData } from '../model/WaterFlowListData';
import { WaterFlowData } from '../model/WaterFlowData';
import { WaterFlowImageView } from './WaterFlowImageView';
import { WaterFlowVideoView } from './WaterFlowVideoView';
import { WaterFlowLivingView } from './WaterFlowLivingView';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import Logger from '../utils/Logger';

@Component
export struct WaterFlowView {
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.LANGUAGE) language: string = CommonConstants.CHINESE_LANGUAGE;
  @State listDataCount: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @State waterFlowItemWidth: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @Link isShowFoot: boolean;
  @Link waterFlowListData: WaterFlowListData;
  @Link windowsHeight: number;
  public waterFlowScroller: Scroller = new Scroller();
  public scroller: Scroller = new Scroller();
  private pageNo: number = CommonConstants.WATER_FLOW_PAGE_START_INDEX;
  private pageSize: number = CommonConstants.WATER_FLOW_PAGE_SIZE;

  listenNetworkEvent() {
    let netCon: connection.NetConnection = connection.createNetConnection();
    netCon.register((error: BusinessError) => {
      Logger.info('register info:' + JSON.stringify(error));
    });
    netCon.on('netUnavailable', () => {
      if (this.isShowFoot === true) {
        this.isShowFoot = false;
      }
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.net_connection_description'),
          bottom: CommonConstants.TOAST_SHOW_MARGIN_BOTTOM,
          duration: CommonConstants.TOAST_SHOW_TIME
        });
      } catch (error) {
        let message = (error as BusinessError).message;
        let code = (error as BusinessError).code;
        Logger.error('showToast args error code is ', code.toString(), 'message is ', message.toString());
      }
    });
    netCon.on('netAvailable', () => {
      if (this.isShowFoot === false) {
        this.isShowFoot = true;
      }
    });
    setTimeout(() => {
      netCon.unregister((error: BusinessError) => {
        Logger.info('unregister info:' + JSON.stringify(error));
      });
    }, 500);
  }

  updateWaterFlowItemWidth() {
    try {
      let windowWidth: number = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
      let columns = windowWidth > CommonConstants.CRITICAL_VALUE ? CommonConstants.WATER_FLOW_THREE_COLUMNS :
        CommonConstants.WATER_FLOW_TWO_COLUMNS;
      let marginLeft = windowWidth > CommonConstants.CRITICAL_VALUE ?
        BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_MD :
        BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_SM;
      this.waterFlowItemWidth =
        (this.getUIContext().px2vp(display.getDefaultDisplaySync().width) - marginLeft * 2 -
          (columns - 1) * CommonConstants.WATER_FLOW_COLUMN_GAP) / columns;
    } catch (error) {
      Logger.error(`updateWaterFlowItemWidth error: ${JSON.stringify(error)}`);
    }
  }

  // [Start get_title_height]
  getTitleHeight(title: string) {
    let textWidth: number = this.getUIContext().getMeasureUtils().measureText({
      textContent: title,
      fontSize: 14
    });
    return textWidth > (this.waterFlowItemWidth - CommonConstants.DESCRIPTION_MARGIN_LEFT * 2) ?
      CommonConstants.DESCRIPTION_THREE_LINES_HEIGHT : CommonConstants.DESCRIPTION_TWO_LINES_HEIGHT;
  }

  // [End get_title_height]

  aboutToAppear(): void {
    this.waterFlowListData.addData(CommonConstants.MOCK_INTERFACE_WATER_FLOW_FILE_NAME, this.pageNo, this.pageSize);

    this.updateWaterFlowItemWidth();
    let callback: Callback<display.FoldDisplayMode> = () => {
      this.updateWaterFlowItemWidth();
      this.scroller.scrollTo({ xOffset: 0, yOffset: 0 });
      this.waterFlowScroller.scrollToIndex(0);
    };
    try {
      display.on('foldDisplayModeChange', callback);
    } catch (error) {
      Logger.error(`on foldDisplayModeChange error: ${JSON.stringify(error)}`);
    }
  }

  build() {
    Column({ space: CommonConstants.SPACE_EIGHT }) {
      Column() {
        // [Start water_flow]
        WaterFlow({ footer: this.footStyle, scroller: this.waterFlowScroller }) {
          LazyForEach(this.waterFlowListData.getData(), (item: WaterFlowData, index: number) => {
            FlowItem() {
              // [StartExclude water_flow]
              if (item.waterFlowHead.type === CommonConstants.WATER_FLOW_IMAGE_TYPE) {
                WaterFlowImageView({
                  source: item.waterFlowHead.source,
                  title: this.language === CommonConstants.CHINESE_LANGUAGE ? item.waterFlowDescription.title :
                    item.waterFlowDescription.titleEn,
                  userImage: item.waterFlowDescription.userImage,
                  userName: item.waterFlowDescription.userName,
                  collectionsCount: item.waterFlowDescription.collectionsCount,
                  waterFlowItemWidth: this.waterFlowItemWidth,
                  imageWidth: item.waterFlowHead.width,
                  vipSign: item.waterFlowDescription.vipSign,
                  imageHeight: item.waterFlowHead.height
                })
                  .reuseId(CommonConstants.WATER_FLOW_IMAGE_REUSE_ID);
              } else if (item.waterFlowHead.type === CommonConstants.WATER_FLOW_VIDEO_TYPE) {
                WaterFlowVideoView({
                  source: item.waterFlowHead.source,
                  thumbnails: item.waterFlowHead.thumbnails,
                  currentBreakpoint: this.currentBreakpoint,
                  title: this.language === CommonConstants.CHINESE_LANGUAGE ? item.waterFlowDescription.title :
                    item.waterFlowDescription.titleEn,
                  userImage: item.waterFlowDescription.userImage,
                  userName: item.waterFlowDescription.userName,
                  collectionsCount: item.waterFlowDescription.collectionsCount,
                  waterFlowItemWidth: this.waterFlowItemWidth,
                  vipSign: item.waterFlowDescription.vipSign,
                  videoWidth: item.waterFlowHead.width,
                  videoHeight: item.waterFlowHead.height
                })
                  .reuseId(CommonConstants.WATER_FLOW_VIDEO_REUSE_ID);
              } else {
                WaterFlowLivingView({
                  source: item.waterFlowHead.source,
                  thumbnails: item.waterFlowHead.thumbnails,
                  currentBreakpoint: this.currentBreakpoint,
                  windowsHeight: this.windowsHeight,
                  title: this.language === CommonConstants.CHINESE_LANGUAGE ? item.waterFlowDescription.title :
                    item.waterFlowDescription.titleEn,
                  userImage: item.waterFlowDescription.userImage,
                  userName: item.waterFlowDescription.userName,
                  collectionsCount: item.waterFlowDescription.collectionsCount,
                  itemIndex: item.waterFlowDescription.index,
                  waterFlowItemWidth: this.waterFlowItemWidth,
                  livingWidth: item.waterFlowHead.width,
                  livingHeight: item.waterFlowHead.height,
                  vipSign: item.waterFlowDescription.vipSign,
                })
                  .reuseId(CommonConstants.WATER_FLOW_LIVING_REUSE_ID);
              }
              // [EndExclude water_flow]
            }
            .height(item.waterFlowHead.height / item.waterFlowHead.width * this.waterFlowItemWidth +
            this.getTitleHeight(item.waterFlowDescription.title))
            .backgroundColor(Color.White)
            // [StartExclude water_flow]
            .width($r('app.string.full_screen'))
            .clip(true)
            .borderRadius($r('app.float.rounded_size_16'))
            .onAppear(() => {
              if (index + 20 === this.waterFlowListData.dataSource.totalCount() &&
                this.waterFlowListData.dataSource.totalCount() < CommonConstants.WATER_FLOW_MAX_COUNT) {
                // There are only 500 analog data, so the limit here is pageNo less than 25
                this.pageNo = this.pageNo + 1 > 25 ? this.pageNo - 24 : this.pageNo + 1;
                this.waterFlowListData.addData(CommonConstants.MOCK_INTERFACE_WATER_FLOW_FILE_NAME, this.pageNo,
                  this.pageSize);
              }
              this.listDataCount = this.waterFlowListData.dataSource.totalCount();
            });

            // [EndExclude water_flow]
          }, (item: WaterFlowData) => {
            return item.waterFlowDescription.index.toString();
          });
        }
        .flingSpeedLimit(4800)
        .onReachEnd(() => {
          this.listenNetworkEvent();
          if (this.waterFlowListData.dataSource.totalCount() < CommonConstants.WATER_FLOW_MAX_COUNT) {
            // There are only 500 analog data, so the limit here is pageNo less than 25
            this.pageNo = this.pageNo + 1 > 25 ? this.pageNo - 24 : this.pageNo + 1;
            this.waterFlowListData.addData(CommonConstants.MOCK_INTERFACE_WATER_FLOW_FILE_NAME, this.pageNo,
              this.pageSize);
          }
          this.listDataCount = this.waterFlowListData.dataSource.totalCount();
        })
        // [End water_flow]
        .cachedCount(CommonConstants.WATER_FLOW_CACHED_COUNT)
        .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
        .columnsTemplate(new BreakpointType({
          sm: BreakpointConstants.GRID_NUM_TWO,
          md: BreakpointConstants.GRID_NUM_THREE,
          lg: BreakpointConstants.GRID_NUM_FOUR
        }).getValue(this.currentBreakpoint))
        .columnsGap($r('app.float.water_flow_column_gap'))
        .rowsGap($r('app.float.water_flow_row_gap'))
        .layoutDirection(FlexDirection.Column)
        .itemConstraintSize({
          minWidth: $r('app.string.zero_screen'),
          maxWidth: $r('app.string.full_screen'),
          minHeight: $r('app.string.zero_screen'),
        });
      }
      .width($r('app.string.full_screen'))
      .height($r('app.string.full_screen'));
    }
    .height($r('app.string.full_screen'))
    .margin({
      top: $r('app.float.margin_8'),
      bottom: $r('app.float.navigation_height'),
      left: new BreakpointType({
        sm: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_SM,
        md: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_MD,
        lg: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_LG
      }).getValue(this.currentBreakpoint),
      right: new BreakpointType({
        sm: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_SM,
        md: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_MD,
        lg: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_LG
      }).getValue(this.currentBreakpoint)
    })
    .animation({
      duration: CommonConstants.ANIMATION_DURATION_TIME,
      curve: Curve.EaseOut,
      playMode: PlayMode.Normal
    });
  }

  @Builder
  footStyle() {
    Row() {
      if (this.isShowFoot && this.listDataCount >= CommonConstants.WATER_FLOW_MAX_COUNT) {
        Text($r('app.string.footer_text_max_count'))
          .fontWeight(CommonConstants.TEXT_FONT_WEIGHT_400)
          .fontSize($r('app.float.font_size_14'))
          .height($r('app.float.text_height'))
          .margin({ bottom: $r('app.float.margin_10') })
          .opacity($r('app.float.opacity_percent_40'));
      } else if (this.isShowFoot) {
        Row() {
          LoadingProgress()
            .color(Color.Black)
            .opacity($r('app.float.net_unavailable_opacity'))
            .width($r('app.float.net_request_loading_width'))
            .height($r('app.float.net_request_loading_height'));

          Text($r('app.string.footer_text_loading'))
            .fontWeight(CommonConstants.TEXT_FONT_WEIGHT_400)
            .fontSize($r('app.float.font_size_14'))
            .height($r('app.float.text_height'))
            .opacity($r('app.float.opacity_percent_40'));
        }
        .height($r('app.float.net_request_loading_width'))
        .width(CommonConstants.FULL_PERCENT)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center);
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.TWENTY_PERCENT)
    .margin({ bottom: $r('app.float.margin_30') })
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.Center);
  }
}