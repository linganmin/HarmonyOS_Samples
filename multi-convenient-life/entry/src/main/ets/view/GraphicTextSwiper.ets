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

import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointType } from '../utils/BreakpointType';

@Reusable
@Component
export struct GraphicTextSwiper {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Consume('upDownStructure') upDownStructure: boolean;
  @Consume('showSideBar') showSideBar: boolean;
  @Consume('isFullScreen') isFullScreen: boolean;
  @Consume('fullImageIndex') fullImageIndex: number;
  @Consume('imgList') imgList: Array<Resource>;
  @Link swiperHeight: number;
  @Link swiperMargin: number;
  @Link swiperItemSpace: number;
  private swiperController: SwiperController = new SwiperController()

  aboutToAppear(): void {
    this.swiperController.changeIndex(this.fullImageIndex);
  };

  aboutToReuse(): void {
    this.swiperController.changeIndex(this.fullImageIndex);
  };

  build() {
    Column() {
      Swiper(this.swiperController) {
        ForEach(this.imgList, ((item: Resource, index: number) => {
          Column() {
            // [Start set_gesture]
            Image(item)
            // [StartExclude set_gesture]
              .width('100%')
              .borderRadius(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? 0 :
              $r('app.float.image_border'))
              .height(CommonConstants.FULL_PERCENT)
              // [EndExclude set_gesture]
              .onClick(() => {
                this.getUIContext().animateTo({
                  duration: CommonConstants.ANIMATE_DURATION,
                  curve: Curve.Friction
                }, () => {
                  this.isFullScreen = true;
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
                      this.isFullScreen = true;
                      this.fullImageIndex = index;
                    });
                  })
              )
            // [End set_gesture]
          }
        }))
      }
      .layoutWeight(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ||
        (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && this.upDownStructure) ? 0 : 1)
      .height(this.upDownStructure ?
      new BreakpointType(CommonConstants.TEXT_SWIPER_HEIGHT, JSON.stringify(this.swiperHeight),
        JSON.stringify(this.swiperHeight)).getValue(this.currentBreakpoint) :
      new BreakpointType(CommonConstants.TEXT_SWIPER_HEIGHT, CommonConstants.SELF_ADAPTING,
        CommonConstants.SELF_ADAPTING).getValue(this.currentBreakpoint))
      .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.showSideBar ? '400vp' :
        this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && this.upDownStructure ?
        CommonConstants.FULL_PERCENT : CommonConstants.SELF_ADAPTING)
      .displayCount(1)
      .displayMode(SwiperDisplayMode.STRETCH)
      .prevMargin(this.upDownStructure && this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ?
      this.swiperMargin : 0)
      .nextMargin(this.upDownStructure && this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ?
      this.swiperMargin : 0)
      .itemSpace(this.upDownStructure && this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ?
      this.swiperItemSpace : 0)
      .cachedCount(4)
      .indicator(false)
      .index($$this.fullImageIndex)
      .geometryTransition('picture')
      .transition(TransitionEffect.OPACITY)
      .onChange((index) => {
        this.fullImageIndex = index;
      })

      Row() {
        ForEach(this.imgList, ((item: Resource, index) => {
          Row() {
          }
          .width(this.fullImageIndex === index ? $r('app.float.img_list_width') : $r('app.float.img_choose_width'))
          .height(8)
          .backgroundColor(this.fullImageIndex === index ?
          $r('app.color.swiper_img_background') : $r('app.color.swiper_choose_background'))
          .margin({
            left: $r('app.float.five_margin'),
            right: $r('app.float.five_margin')
          })
          .borderRadius($r('app.float.add_cart_border'))
        }))
      }
      .margin({
        top: $r('app.float.swiper_margin_top'),
        bottom: $r('app.float.swiper_margin_bottom')
      })
      .justifyContent(FlexAlign.Center)
    }
    .padding({
      top: this.upDownStructure ? $r('app.float.padding_small') : new BreakpointType($r('app.float.padding_small'),
        $r('app.float.swiper_padding_md'), $r('app.float.padding_small')).getValue(this.currentBreakpoint),
      left: this.upDownStructure ? new BreakpointType($r('app.float.zero_padding'), $r('app.float.zero_padding'),
        $r('app.float.padding_header')).getValue(this.currentBreakpoint) :
      new BreakpointType($r('app.float.zero_padding'), $r('app.float.common_padding'), $r('app.float.padding_header'))
        .getValue(this.currentBreakpoint),
      right: this.upDownStructure ? new BreakpointType($r('app.float.zero_padding'), $r('app.float.zero_padding'),
        $r('app.float.padding_header')).getValue(this.currentBreakpoint) :
      new BreakpointType($r('app.float.zero_padding'), $r('app.float.common_padding'), $r('app.float.padding_header'))
        .getValue(this.currentBreakpoint),
    })
    .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.showSideBar ?
    CommonConstants.SEVENTY_PERCENT : CommonConstants.FULL_PERCENT)
  }
}