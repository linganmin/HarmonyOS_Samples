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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { LineChart, LineChartModel } from '@ohos/mpchart';
import { CYCLE_TITLE, OTHER_TITLE } from '../models/DataModel';
import { BarChartView } from '../chartmodels/BarChartView';
import { BreakpointType } from '../utils/BreakpointType';
import { StockDetailsInfo } from './StockDetailsInfo';
import { StockDealDetails } from './StockDealDetails';
import { CommSlide, TitleIcon } from './CommonView';
import { RegularWayPopUp } from './RegularWayPopUp';
import { TopTitleBar } from './TopTitleBar';
import { BuyPopUp } from './BuyPopUp';
import ChartViewModel from '../chartmodels/LineChartModel';

@Component
export struct StockDetailsView {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = 1;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: number = 1;
  @StorageLink('lastWidthBreakpoint') lastWidthBreakpoint: number = 1;
  @StorageLink('sharesHeldNumber') sharesHeldNumber: number = 0;
  @StorageLink('isSplitScreen') isSplitScreen: boolean = false;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('tabletMode') tabletMode: NavigationMode;
  @State lineChartModel: LineChartModel = ChartViewModel.getLineChartModel();
  @State cycleTabIndexSelected: number = 0;
  @State currentIndex: number = 0;
  @State selectedIndex: number = 0;
  private scroller: Scroller = new Scroller();
  @State closeInfoCarousel: boolean = false;
  private cardList: number[] = [1, 2];
  private windowClass: window.Window = AppStorage.get<window.Window>('windowClass')!;
  @Provide('isFirstBulletBox') isFirstBulletBox: boolean = true;
  @Provide('popUpBoxIsShow') @Watch('bindSheetMonitor') popUpBoxIsShow: boolean = false;
  @Provide('currentStockPrice') currentStockPrice: number = 20;
  @Provide('purchaseQuantity') purchaseQuantity: number = 100;
  @Provide('buyIsShow') buyIsShow: boolean = false;
  @Provide('isExpand') isExpand: boolean = false;
  @State firstTabIndexSelected: number = 0;
  @State secondTabIndexSelected: number = 0;

  bindSheetMonitor() {
    if (!this.popUpBoxIsShow) {
      this.isFirstBulletBox = true;
    }
  }

  isOverlayMethod(statusBarColor: string): void {
    let SystemBarProperties: window.SystemBarProperties;
    SystemBarProperties = { statusBarColor: statusBarColor };
    try {
      this.windowClass.setWindowSystemBarProperties(SystemBarProperties);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'StockDetailsView',
        `setWindowSystemBarProperties failed, error code=${err.code}, message=${err.message}`);
    }
  }

  @Builder
  myBuilder() {
    if (this.isFirstBulletBox) {
      RegularWayPopUp()
    } else {
      BuyPopUp()
    }
  }

  build() {
    NavDestination() {
      // Top toolbar
      TopTitleBar()
        .bindSheet($$this.popUpBoxIsShow, this.myBuilder(), {
          detents: [400],
          backgroundColor: '#F9F9F9',
          showClose: false,
          maskColor: $r('sys.color.mask_fourth'),
          preferType: SheetType.CENTER
        })

      // Content Area
      Scroll(this.scroller) {
        Column() {
          // Stock details information
          StockDetailsInfo()

          // Stock Notification
          Row() {
            Row() {
              Text($r('app.string.information'))
                .fontSize(12)
                .lineHeight(16)
                .fontColor($r('sys.color.icon_primary'))
                .fontWeight(FontWeight.Bold)
                .margin({
                  right: 16
                })
              Text($r('app.string.announcement'))
                .fontSize(11)
                .lineHeight(15)
                .fontColor($r('sys.color.font_primary'))
            }

            Blank()

            SymbolGlyph($r('sys.symbol.xmark'))
              .fontColor([$r('sys.color.icon_primary')])
              .fontSize(12)
              .onClick(() => {
                this.closeInfoCarousel = true;
              })
          }
          .width('100%')
          .height(40)
          .backgroundColor(Color.White)
          .visibility(this.closeInfoCarousel ? Visibility.None : Visibility.Visible)
          .padding({
            right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
            left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
          })
          .margin({
            top: this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG ? 8 : 4
          })

          // Stock trading time period area
          Row() {
            Column() {
              CommSlide({
                commSlideData: CYCLE_TITLE,
                tabIndexSelected: this.firstTabIndexSelected
              })
            }
            .width('100%')
            .height(40)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(Color.White)
            .margin({
              top: this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG ? 8 : 4,
              bottom: this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM ? 4 : 1
            })
          }

          // [Start Stock_candlestick_chart_area]
          Row() {
            Row() {
              // Stock chart area
              Column() {
                // Stock candlestick chart area
                Row() {
                  LineChart({ model: this.lineChartModel })
                }
                // [StartExclude Stock_candlestick_chart_area]
                .height('80%')
                .padding({
                  top: 20
                })

                // [EndExclude Stock_candlestick_chart_area]

                // Stock bar chart area
                Row() {
                  BarChartView()
                }
                // [StartExclude Stock_candlestick_chart_area]
                .width('100%')
                .height('20%')

                // [EndExclude Stock_candlestick_chart_area]
              }
              .height('100%')
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.SpaceBetween)

            // Stock price details
            StockDealDetails()
          }
          .width('100%')
          .height(new BreakpointType(294, 286, 376).getValue(this.currentWidthBreakpoint))
          // [End Stock_candlestick_chart_area]
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor(Color.White)
          .padding({
            right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
            left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
          })

          // Stock Circle
          Row() {
            Column() {
              CommSlide({
                commSlideData: OTHER_TITLE,
                tabIndexSelected: this.secondTabIndexSelected
              })
            }
            .width('100%')
            .height(40)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(Color.White)
            .margin({
              top: 4,
              bottom: 8
            })
          }

          // List of stock cards
          Column({ space: 12 }) {
            ForEach(this.cardList, (item: number) => {
              Blank()
                .id(item.toString())
                .width('100%')
                .borderRadius(12)
                .backgroundColor($r('sys.color.comp_background_primary'))
                .height(40 * item)
            }, (item: number, index: number) => (index + item).toString())
          }
          .margin({
            right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
            left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
          })
        }
      }
      .backgroundColor($r('sys.color.comp_background_gray'))
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .padding({
        bottom: 8
      })

      // [Start trading_operation_line]
      // Bottom toolbar
      Row() {
        Row({ space: 24 }) {
          TitleIcon({ icon: $r('sys.symbol.dot_grid_2x2'), title: $r('app.string.self_selected_settings') })
          TitleIcon({ icon: $r('sys.symbol.Investment_stable_value_add'), title: $r('app.string.stock_pk') })
          TitleIcon({ icon: $r('sys.symbol.more'), title: $r('app.string.more') })
        }
        .margin({
          right: new BreakpointType(32, 101, 32).getValue(this.currentWidthBreakpoint)
        })

        Blank()
          .visibility(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG &&
            this.tabletMode === NavigationMode.Stack ? Visibility.None : Visibility.Visible)

        Row() {
          Text($r('app.string.go_trade'))
          // [StartExclude trading_operation_line]
            .fontSize(16)
            .lineHeight(21)
            .fontWeight(500)
            .fontColor($r('sys.color.font_on_primary'))
          // [EndExclude trading_operation_line]
        }
        .layoutWeight(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG ? 0 : 1)
        .width(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG && this.tabletMode === NavigationMode.Stack ?
          448 : 360)
        // [StartExclude trading_operation_line]
        .height(40)
        .borderRadius(20)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#E53137')
        .padding({
          top: 2
        })
        // [EndExclude trading_operation_line]
        .onClick(() => {
          this.buyIsShow = false;
          this.popUpBoxIsShow = true;
        })
      }
      // [End trading_operation_line]
      .width('100%')
      .height(78)
      .backgroundColor($r('sys.color.font_on_primary'))
      .alignItems(VerticalAlign.Top)
      .justifyContent(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG ? FlexAlign.End : FlexAlign.Start)
      .padding({
        top: 6,
        right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
        left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
      })
      .border({
        width: { top: 0.5 },
        color: { top: '#33000000' },
        style: { top: BorderStyle.Solid }
      })
    }
    .title('StockDetailsPage')
    .hideTitleBar(true)
    .width('100%')
    .backgroundColor(Color.White)
    .padding({
      top: AppStorage.get<number>('statusBarHeight')
    })
    .onBackPressed(() => {
      if (this.tabletMode === NavigationMode.Stack) {
        this.tabletMode = NavigationMode.Split;
        return true;
      }
      return false;
    })
  }
}