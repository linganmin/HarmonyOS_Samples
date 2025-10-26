/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

/**
 * 最佳实践：基于HMRouter路由框架的页面跳转开发实践
 */

import { HMPopInfo, HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ResourceUtil } from '../common/utils/ResourceUtil';
import { Categories } from './Categories';
import { HomeHeader } from './HomeHeader';
import { RecommendedProductView } from './RecommendedProductView';
import { WelfareView } from './WelfareView';

@Builder
function flashSaleCard() {
  Column() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Text('限时秒杀')
        .fontSize(16);
      Text() {
        Span('更多')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.6)');
        ImageSpan($r('app.media.arrow_right'))
          .height(18);
      }
      .align(Alignment.Center);
    }
    .padding({ left: 16 });

    Row() {
      Image($r('app.media.flash_sale_product_1'))
        .width(134)
        .height(134)
        .margin({ right: 7.5 });
      Column() {
        Text('HUAWEI MATE 50')
          .fontSize(14)
          .fontWeight(500)
          .lineHeight(19);
        Text('北斗卫星消息 ｜ 低电量应急模式')
          .fontSize(10)
          .fontColor('rgba(0,0,0,0.6)')
          .lineHeight(13);
        Row() {
          Text('新一代志平旗舰机')
            .fontSize(9)
            .fontColor('rgba(207, 10, 44, 0.4)')
            .border({
              width: 0.5,
              style: BorderStyle.Solid,
              color: 'rgba(207, 10, 44, 0.4)',
              radius: 4
            })
            .lineHeight(14)
            .padding({ left: 4, right: 4 });
          Text('赚积分')
            .fontSize(9)
            .fontColor('rgba(207, 10, 44, 0.4)')
            .border({
              width: 0.5,
              style: BorderStyle.Solid,
              color: 'rgba(207, 10, 44, 0.4)',
              radius: 4
            })
            .margin({ left: 4 })
            .lineHeight(14)
            .padding({ left: 4, right: 4 });
        }.margin({ top: 8 });

        Row() {
          Text('¥ 4999')
            .fontColor('rgb(207, 10, 44)')
            .fontWeight(500)
            .fontSize(14)
            .lineHeight(19);
          Text('¥5488')
            .fontSize(10)
            .fontColor('rgba(0,0,0,0.4)')
            .margin({ left: 4 })
            .lineHeight(14)
            .decoration({
              style: TextDecorationStyle.SOLID,
              type: TextDecorationType.LineThrough,
              color: 'rgba(0,0,0,0.4)'
            });
        }.margin({ top: 4 })
        .alignItems(VerticalAlign.Bottom);
      }
      .alignItems(HorizontalAlign.Start);
    }
    .margin({ top: 13 });
  }.backgroundColor($r('app.color.home_content_card_background_color'))
  .borderRadius(16)
  .padding({ top: 16, right: 16, bottom: 16 });
}

@Builder
function recommendCard() {
  Column() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Text('甄选推荐')
        .fontSize(16);
      Text() {
        Span('更多')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.6)');
        ImageSpan($r('app.media.arrow_right'))
          .height(18);
      }
      .align(Alignment.Center);
    }
    .padding({ left: 16 });

    Row() {
      Column() {
        Image($r('app.media.section_product_1'))
          .width(134)
          .height(134)
          .margin({ right: 7.5 });
        Column() {
          Text('MateBook X Pro 12')
            .fontSize(12)
            .fontWeight(500)
            .lineHeight(19);
          Text(' ')
            .fontSize(10)
            .fontColor('rgba(0,0,0,0.6)')
            .lineHeight(13);
          Text('V1-V5优惠400元')
            .fontSize(9)
            .fontColor('rgba(207, 10, 44, 0.4)')
            .border({
              width: 0.5,
              style: BorderStyle.Solid,
              color: 'rgba(207, 10, 44, 0.4)',
              radius: 4
            })
            .lineHeight(14)
            .padding({ left: 4, right: 4 })
            .margin({ top: 4 });
          Text('¥ 10999')
            .fontColor('rgb(207, 10, 44)')
            .fontWeight(500)
            .fontSize(14)
            .lineHeight(19)
            .margin({ top: 6 });
          Text('2571评论  95%好评')
            .fontSize(10)
            .fontColor('rgba(0,0,0,0.4)')
            .margin({ left: 4 })
            .lineHeight(14);
        }
        .alignItems(HorizontalAlign.Center);
      };

      Column() {
        Image($r('app.media.section_product_2'))
          .width(134)
          .height(134)
          .margin({ right: 7.5 });
        Column() {
          Text('HUAWEI Mate 50')
            .fontSize(12)
            .fontWeight(500)
            .lineHeight(19);
          Text('北斗卫星消息')
            .fontSize(10)
            .fontColor('rgba(0,0,0,0.6)')
            .lineHeight(13);
          Text('新一代志平旗舰机')
            .fontSize(9)
            .fontColor('rgba(207, 10, 44, 0.4)')
            .border({
              width: 0.5,
              style: BorderStyle.Solid,
              color: 'rgba(207, 10, 44, 0.4)',
              radius: 4
            })
            .lineHeight(14)
            .padding({ left: 4, right: 4 })
            .margin({ top: 4 });
          Text('¥ 10999')
            .fontColor('rgb(207, 10, 44)')
            .fontWeight(500)
            .fontSize(14)
            .lineHeight(19)
            .margin({ top: 6 });
          Text('2571评论  95%好评')
            .fontSize(10)
            .fontColor('rgba(0,0,0,0.4)')
            .margin({ left: 4 })
            .lineHeight(14);
        }
        .alignItems(HorizontalAlign.Center);
      };
    }
    .margin({ top: 13 });
  }.backgroundColor($r('app.color.home_content_card_background_color'))
  .borderRadius(16)
  .padding({ top: 16, right: 16, bottom: 16 });
}

// [Start HMRouter_home_content]
@Component
export struct HomeContent {
  // [StartExclude HMRouter_home_content]
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  private scroller: Scroller = new Scroller();

  build() {
    Column() {
      HomeHeader()
        .padding({
          left: ResourceUtil.getPageColPadding().getValue(this.currentBreakpoint),
          right: ResourceUtil.getPageColPadding().getValue(this.currentBreakpoint)
        });

      Scroll(this.scroller) {
        Column() {
          Categories();

          WaterFlow() {
            FlowItem() {
              RecommendedProductView();
            };

            FlowItem() {
              WelfareView();
            };

            FlowItem() {
              recommendCard();
            };

            FlowItem() {
              flashSaleCard();
            };
          }
          .onClick(() => {
            // [Start HMRouterMgr]
            HMRouterMgr.to('ProductContent')
              .withNavigation('mainNavigationId')
              .withParam({ a: 1, b: 2 })
              .onResult((popInfo: HMPopInfo) => {
                const pageName = popInfo.srcPageInfo.name;
                const params = popInfo.result;
                console.log(`page name is ${pageName}, params is ${JSON.stringify(params)}`);
              })
              .pushAsync()
            // [End HMRouterMgr]
          })
          .columnsGap(12)
          .rowsGap(12)
          .columnsTemplate(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? '1fr' : '1fr 1fr')
          .width(CommonConstants.FULL_PERCENT)
          .id('homeLivePicture');
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Start);
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .padding({
        left: ResourceUtil.getPageColPadding().getValue(this.currentBreakpoint),
        right: ResourceUtil.getPageColPadding().getValue(this.currentBreakpoint)
      });
    }
    .backgroundColor($r('app.color.home_content_background_color'))
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  // [EndExclude HMRouter_home_content]
}

// [End HMRouter_home_content]
