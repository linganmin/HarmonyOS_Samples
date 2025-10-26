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

import { display, MeasureText, promptAction } from '@kit.ArkUI';
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointType } from '../../utils/BreakpointSystem';
import { WaterFlowListData } from '../../viewmodel/longlist/WaterFlowListData';
import { WaterFlowData } from '../../viewmodel/longlist/WaterFlowData';
import { WaterFlowImageView } from './WaterFlowImageView';
import { WaterFlowVideoView } from './WaterFlowVideoView';
import { WaterFlowLivingView } from './WaterFlowLivingView';
import { CommonConstants } from '../../constants/CommonConstants';
import { BreakpointConstants } from '../../constants/BreakpointConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct WaterFlowView {
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.LANGUAGE) language: string = CommonConstants.CHINESE_LANGUAGE;
  @StorageLink('continueIndex') continueIndex: number = 0;
  @StorageLink('continueWaterOffset') continueWaterOffset: number = 0;
  @StorageLink('listItemHeight') listItemHeight: number = 0;
  @StorageLink('continueEntry') continueEntry: boolean = false;
  @StorageLink('windowWidth') windowWidth: number = 0;
  @StorageLink('continueBreakpoint') continueBreakpoint: string = '';
  @StorageLink('continueHeight') continueHeight: number = 0;
  @State loadFinish: boolean = false;
  @State listDataCount: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @State waterFlowItemWidth: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @State waterFlowHeight: number = 0;
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
      hilog.info(0x000, 'progress', 'register info:' + JSON.stringify(error));
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
        hilog.error(0x000, 'progress', 'showToast args error code is ', code.toString(), 'message is ',
          message.toString());
      }
    });
    netCon.on('netAvailable', () => {
      if (this.isShowFoot === false) {
        this.isShowFoot = true;
      }
    });
    setTimeout(() => {
      netCon.unregister((error: BusinessError) => {
        hilog.info(0x000, 'progress', 'unregister info:' + JSON.stringify(error));
      });
    }, 500);
  }

  updateWaterFlowItemWidth() {
    let windowWidth: number = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
    let columns = windowWidth > CommonConstants.CRITICAL_VALUE ? CommonConstants.WATER_FLOW_THREE_COLUMNS :
    CommonConstants.WATER_FLOW_TWO_COLUMNS;
    let marginLeft = windowWidth > CommonConstants.CRITICAL_VALUE ?
    BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_MD :
    BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_SM;
    this.waterFlowItemWidth =
      (this.getUIContext().px2vp(display.getDefaultDisplaySync().width) - marginLeft * 2 -
        (columns - 1) * CommonConstants.WATER_FLOW_COLUMN_GAP) / columns;
  }

  getTitleHeight(title: string) {
    let textWidth: number = this.getUIContext().getMeasureUtils().measureText({
      textContent: title,
      fontSize: $r('app.float.font_size_14')
    });
    return textWidth > (this.waterFlowItemWidth - CommonConstants.DESCRIPTION_MARGIN_LEFT * 2) ?
    CommonConstants.DESCRIPTION_THREE_LINES_HEIGHT : CommonConstants.DESCRIPTION_TWO_LINES_HEIGHT;
  }

  aboutToAppear(): void {
    this.waterFlowListData.addData(CommonConstants.MOCK_INTERFACE_WATER_FLOW_FILE_NAME, this.pageNo, this.pageSize);

    this.updateWaterFlowItemWidth();
    let callback: Callback<display.FoldDisplayMode> = () => {
      this.updateWaterFlowItemWidth();
      this.scroller.scrollTo({ xOffset: 0, yOffset: 0 });
      this.waterFlowScroller.scrollToIndex(0);
    };
    display.on('foldDisplayModeChange', callback);
  }

  build() {
    Column({ space: CommonConstants.SPACE_EIGHT }) {
      Column() {
        // [Start water_flow]
        WaterFlow({ footer: this.footStyle, scroller: this.waterFlowScroller }) {
          // [StartExclude water_flow]
          LazyForEach(this.waterFlowListData.getData(), (item: WaterFlowData, index: number) => {
            FlowItem() {
              if (item.waterFlowHead.type === CommonConstants.WATER_FLOW_IMAGE_TYPE) {
                WaterFlowImageView({
                  source: item.waterFlowHead.source,
                  title: item.waterFlowDescription.title,
                  titleEn: item.waterFlowDescription.titleEn,
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
                  title: item.waterFlowDescription.title,
                  titleEn: item.waterFlowDescription.titleEn,
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
                  title: item.waterFlowDescription.title,
                  titleEn: item.waterFlowDescription.titleEn,
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
            }
            .backgroundColor(Color.White)
            .width($r('app.string.full_screen'))
            .clip(true)
            .borderRadius($r('app.float.rounded_size_16'))
            .onAppear(() => {
              if (index + 20 === this.waterFlowListData.dataSource.totalCount() &&
                this.waterFlowListData.dataSource.totalCount() < 15) {
                this.pageNo = this.pageNo + 1 > 25 ? this.pageNo - 24 : this.pageNo + 1;
                this.waterFlowListData.addData(CommonConstants.MOCK_INTERFACE_WATER_FLOW_FILE_NAME, this.pageNo,
                  this.pageSize);
              }
              this.listDataCount = this.waterFlowListData.dataSource.totalCount();
              this.loadFinish = true;
              let imageWidth = this.waterFlowListData.dataSource.getData(0)
                .waterFlowHead
                .width;
              let imageHeight = this.waterFlowListData.dataSource.getData(0)
                .waterFlowHead
                .height;
              this.listItemHeight = imageHeight / imageWidth * this.getUIContext().px2vp(this.windowWidth) /
              new BreakpointType({
                sm: 2,
                md: 3,
                lg: 4,
                xl: 4
              }).getValue(this.currentBreakpoint);
            })
          }, (item: WaterFlowData) => {
            return item.waterFlowDescription.index.toString();
          })
          // [EndExclude water_flow]
        }
        .restoreId(1)
        // [End water_flow]
        .onDisAppear(() => {
          this.continueIndex = this.waterFlowScroller.currentOffset().yOffset;
        })
        .onScrollIndex((first: number, last: number) => {
          if (!this.continueEntry) {
            this.continueIndex = this.waterFlowScroller.currentOffset().yOffset;
          }
        })
        .flingSpeedLimit(4800)
        .onReachEnd(() => {
          this.listenNetworkEvent();
          if (this.waterFlowListData.dataSource.totalCount() < CommonConstants.WATER_FLOW_MAX_COUNT) {
            this.pageNo = this.pageNo + 1 > 25 ? this.pageNo - 24 : this.pageNo + 1;
            this.waterFlowListData.addData(CommonConstants.MOCK_INTERFACE_WATER_FLOW_FILE_NAME, this.pageNo,
              this.pageSize);
          }
          this.listDataCount = this.waterFlowListData.dataSource.totalCount();
        })
        .cachedCount(CommonConstants.WATER_FLOW_CACHED_COUNT)
        .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
        .columnsTemplate(new BreakpointType({
          sm: BreakpointConstants.GRID_NUM_TWO,
          md: BreakpointConstants.GRID_NUM_THREE,
          lg: BreakpointConstants.GRID_NUM_FOUR,
          xl: BreakpointConstants.GRID_NUM_FOUR
        }).getValue(this.currentBreakpoint))
        .columnsGap($r('app.float.water_flow_column_gap'))
        .rowsGap($r('app.float.water_flow_row_gap'))
        .layoutDirection(FlexDirection.Column)
        .itemConstraintSize({
          minWidth: $r('app.string.zero_screen'),
          maxWidth: $r('app.string.full_screen'),
          minHeight: $r('app.string.zero_screen')
        })
        .onAreaChange((oldArea: Area, newArea: Area) => {
          let height = oldArea.height;
          hilog.info(0x000, 'progress', `onAreaChange ${this.continueEntry} ${this.continueWaterOffset}
           ${this.listItemHeight}`);
          if (this.continueEntry && height != 0) {
            if (this.continueBreakpoint !== '' && this.continueBreakpoint !== this.currentBreakpoint) {
              let countBreakPoint = new BreakpointType({
                sm: 2,
                md: 3,
                lg: 4,
                xl: 4
              });
              let index = this.continueWaterOffset / this.continueHeight *
              countBreakPoint.getValue(this.continueBreakpoint);
              let offset = index / countBreakPoint.getValue(this.currentBreakpoint) * this.listItemHeight;
              this.waterFlowScroller.scrollTo({ xOffset: 0, yOffset: offset });
            } else {
              this.waterFlowScroller.scrollTo({ xOffset: 0, yOffset: this.continueWaterOffset });
            }
            this.continueEntry = false;
          }
        })
      }
      .width($r('app.string.full_screen'))
      .height($r('app.string.full_screen'))
    }
    .height($r('app.string.full_screen'))
    .margin({
      top: $r('app.float.margin_8'),
      bottom: $r('app.float.navigation_height'),
      left: new BreakpointType({
        sm: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_SM,
        md: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_MD,
        lg: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_LG,
        xl: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_LEFT_LG
      }).getValue(this.currentBreakpoint),
      right: new BreakpointType({
        sm: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_SM,
        md: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_MD,
        lg: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_LG,
        xl: BreakpointConstants.SEARCHBAR_AND_WATER_FLOW_MARGIN_RIGHT_LG
      }).getValue(this.currentBreakpoint)
    })
    .animation({
      duration: CommonConstants.ANIMATION_DURATION_TIME,
      curve: Curve.EaseOut,
      playMode: PlayMode.Normal
    })
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
          .opacity($r('app.float.opacity_percent_40'))
      } else if (this.isShowFoot) {
        Row() {
          LoadingProgress()
            .color(Color.Black)
            .opacity($r('app.float.net_unavailable_opacity'))
            .width($r('app.float.net_request_loading_width'))
            .height($r('app.float.net_request_loading_height'))

          Text($r('app.string.footer_text_loading'))
            .fontWeight(CommonConstants.TEXT_FONT_WEIGHT_400)
            .fontSize($r('app.float.font_size_14'))
            .height($r('app.float.text_height'))
            .opacity($r('app.float.opacity_percent_40'))
        }
        .height($r('app.float.net_request_loading_width'))
        .width(CommonConstants.FULL_PERCENT)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.TWENTY_PERCENT)
    .margin({ bottom: $r('app.float.margin_30') })
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.Center)
  }
}