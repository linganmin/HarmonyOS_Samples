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

import { HMRouterMgr } from '@hadss/hmrouter';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { CommonConstants } from '../common/constants/CommonConstants';
import { LiveConstants } from '../common/constants/LiveConstants';
import { ResourceUtil } from '../common/utils/ResourceUtil';
import { LiveProduct, LiveViewModel } from '../viewmodel/LiveViewModel';
import { LiveHomeLifecycle } from './LiveHome';

@Component
export struct LiveShopList {
  @StorageLink('currentBreakpoint') realBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('changeVideoSrc') VideoSrc: string | Resource = $rawfile('camera-ais.mp4');
  @State currentProductIndex: number = 0;
  @Prop @Watch('getLiveProductList') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @State liveProductList: LiveProduct[] = new LiveViewModel().getProductList().reverse();
  @Link detailType: string;
  @Link isMoreDetail: boolean;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.getLiveProductList();
    this.isMoreDetail = true;
    this.detailType = CommonConstants.BIND_SHEET_PAGE_TYPES[2];
  }

  getLiveProductList(): void {
    if(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
      this.liveProductList = new LiveViewModel().getProductList().reverse();
      this.currentProductIndex = this.liveProductList.length - 1;
    } else {
      this.liveProductList = new LiveViewModel().getProductList();
      this.currentProductIndex = 0;
    }
    this.scroller.scrollToIndex(this.currentProductIndex);
  }

  build() {
    List({
      space: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? LiveConstants.SHOPPING_LIST_SPACE[0] :
      LiveConstants.SHOPPING_LIST_SPACE[1],
      initialIndex: this.currentProductIndex,
      scroller: this.scroller
    }) {
      ForEach(this.liveProductList, (item: LiveProduct, index: number) => {
        ListItem() {
          Row() {
            Image(item.getImage())
              .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
              $r('app.float.shop_list_image_size_lg') : $r('app.float.shop_list_image_size'))
              .aspectRatio(1)
              .borderRadius(ResourceUtil.getCommonBorderRadius()[3]);
            Column() {
              Text(item.getName())
                .fontSize($r('app.float.shop_list_text_font_size'))
                .lineHeight($r('app.float.shop_list_text_line_height'))
                .fontWeight(CommonConstants.FONT_WEIGHT_500)
                .maxLines(1)
                .textOverflow({overflow: TextOverflow.Ellipsis})
                .margin({
                  bottom: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
                  $r('app.float.shop_list_text_margin_lg') : $r('app.float.shop_list_text_margin')
                });
              Row() {
                Text(item.getPrice())
                  .fontSize($r('app.float.shop_list_text_font_size'))
                  .lineHeight($r('app.float.shop_list_text_line_height'))
                  .fontWeight(CommonConstants.FONT_WEIGHT_500)
                  .fontColor($r('app.color.live_shop_list_font_color'));
                Image($r('app.media.icon_play'))
                  .width(24)
                  .height(24);
              }
              .width('100%')
              .padding({right: 10})
              .justifyContent(FlexAlign.SpaceBetween);
            }
            .alignItems(HorizontalAlign.Start)
            .visibility(index === this.currentProductIndex ? Visibility.Visible : Visibility.None)
            .padding({
              top: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
              $r('app.float.shop_text_padding_top_lg') : $r('app.float.shop_text_padding_top'),
              bottom: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
              $r('app.float.shop_text_padding_bottom_lg') : $r('app.float.shop_text_padding_bottom'),
              left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
              $r('app.float.shop_text_padding_left_lg') : 0
            })
            .layoutWeight(1)
            .height(CommonConstants.FULL_PERCENT);
          }
          .borderRadius(ResourceUtil.getCommonBorderRadius()[3])
          .backgroundColor($r('app.color.live_shop_list_row_background_color'))
          .width(index === this.currentProductIndex ? (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
          $r('app.float.shop_width_index0_lg') : $r('app.float.shop_width_index0')) :
            (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.shop_width_lg') :
            $r('app.float.shop_width')))
          .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.shop_width_lg') :
          $r('app.float.shop_width'));
        }
        .onClick(() => {
          this.currentProductIndex = index
          let lifecycle = HMRouterMgr.getCurrentLifecycleOwner()?.getLifecycle() as LiveHomeLifecycle
          if (index == 0) {
            HMRouterMgr.to('liveHome')
              .onArrival(()=>{
                lifecycle.videoSrc.src = $rawfile('camera-ais.mp4')
              })
              .pushAsync()
          } else {
            HMRouterMgr.to('liveHome')
              .onArrival(()=>{
                lifecycle.videoSrc.src = $rawfile('sellpoint-1.mp4')
              })
              .pushAsync()
          }
        });
      }, (item: LiveProduct, index: number) => index + JSON.stringify(item));
    }
    .edgeEffect(EdgeEffect.Fade)
    .alignListItem(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? ListItemAlign.End :
    ListItemAlign.Start)
    .scrollBar(BarState.Off)
    .height(this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_LG ? $r('app.float.shop_width') :
    CommonConstants.FULL_PERCENT)
    .width(this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_LG ? CommonConstants.FULL_PERCENT :
    $r('app.float.shop_width_index0_lg'))
    .listDirection(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? Axis.Vertical :
    Axis.Horizontal);
  }
}