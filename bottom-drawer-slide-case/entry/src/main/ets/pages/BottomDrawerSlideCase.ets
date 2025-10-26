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
import { JSON } from '@kit.ArkTS';
import { HomeTop, ImageMapView, ItemHead, SettingItemView, StatusHead } from '../view/ComComponent';
import { CommonConstants } from '../constants/CommonConstants';
import { GlobalContext } from '../utils/GlobalContext';
import { SettingItem } from '../utils/SettingItem';
import WindowModel from '../utils/WindowModel';
import Logger from '../utils/Logger';

@Entry
@Component
struct BottomDrawerSlideCase {
  // Height of the bottom navigation bar.
  @State bottomAvoidHeight: number = 0;
  // List height.
  @State listHeight: number = 0;
  // Window height.
  @State windowHeight: number = 0;
  // Height of the status bar at the top.
  @State statusBarHeight: number = 0;
  // Whether the list can be scrolled.
  @State isScroll: boolean = false;
  // Whether the list is sliding up.
  @State isUp: boolean = true;
  // Whether to display the top masked navigation bar area
  @State isShow: boolean = false;
  // List content items.
  @State listItem: SettingItem[] = CommonConstants.LIST_IMAGE_DATA;
  // height of the first item in the list.
  @State firstListItemHeight: number = CommonConstants.FIRST_LIST_ITEM_HEIGHT;
  // Height of the second item in the list.
  @State secondListItemHeight: number = this.bottomAvoidHeight + 150;
  // Display the first item in the list.
  @State itemNumber: number = 0;
  // Y-axis offset of the list.
  @State positionY: number = 0;
  // list Start vertical coordinate of the touch event.
  private yStart: number = 0;
  // Window management model.
  private windowModel: WindowModel = WindowModel.getInstance();
  // list scroll controller.
  private listScroller = new ListScroller();

  aboutToAppear(): void {
    // list scroll controller.
    let windowStage: window.WindowStage = GlobalContext.getContext().getObject('windowStage') as window.WindowStage;

    // The following logic cannot be performed without a windowStage.
    if (!windowStage) {
      Logger.warn('windowStage init error!');
      return;
    }
    this.windowModel.setWindowStage(windowStage);

    // Set Immersive Mode.
    this.windowModel.setMainWindowImmersive(true);

    // Obtains the height of the top navigation bar.
    this.windowModel.getStatusBarHeight((statusBarHeight) => {
      this.statusBarHeight = this.getUIContext().px2vp(statusBarHeight);
    });

    // Obtains the height of the bottom navigation bar.
    this.windowModel.getBottomAvoidHeight((bottomAvoidHeight) => {
      this.bottomAvoidHeight = this.getUIContext().px2vp(bottomAvoidHeight) / 2;
    });

    // Obtains the window height.
    this.windowModel.getWindowHeight().then(s => {
      this.windowHeight = s;
    });

    // Initial display height of the list at the bottom.
    this.listHeight = this.firstListItemHeight;
  }

  aboutToDisappear(): void {
    // Turn off immersive mode.
    this.windowModel.setMainWindowImmersive(false);
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      RelativeContainer() {
        // Image map.
        ImageMapView()
          .id('map')

        // Title bar at the top of the map.
        HomeTop({ statusBarHeight: this.statusBarHeight })
          .alignRules(CommonConstants.HOME_TOP_ALIGN_RULES)
          .id('title_bar')

        // Title bar at the top of the list.
        ItemHead({ headerContent: $r('app.string.list_item_title') })

        // Bottom Variable Staging Sliding List.
        List({ scroller: this.listScroller }) {
          ListItem() {
            Column() {
              Row() {
                Blank()
                  .width($r('app.integer.dot_size'))
                  .height($r('app.integer.dot_size'))
                  .borderRadius($r('app.integer.comm_border_radius8'))
                  .backgroundColor($r('app.color.blank_background_color1'))
                  .margin({
                    left: $r('app.integer.comm_margin_padding_size12'),
                    right: $r('app.integer.comm_margin_padding_size12')
                  })
                Text() {
                  Span($r('app.string.pick_up_location'))
                    .fontColor($r('app.color.location_background_color'))
                  Span($r('app.string.get_on'))
                }
                .fontSize($r('app.integer.comm_font_size14'))

                Image($r('app.media.ic_public_arrow_right'))
                  .width($r('app.integer.comm_icon_size18'))
              }
              .width(CommonConstants.FULL_PERCENT)
              .height($r('app.integer.comm_height50'))

              Row() {
                Blank()
                  .width($r('app.integer.dot_size'))
                  .height($r('app.integer.dot_size'))
                  .borderRadius($r('app.integer.comm_border_radius8'))
                  .backgroundColor($r('app.color.blank_background_color2'))
                  .margin({
                    left: $r('app.integer.comm_margin_padding_size12'),
                    right: $r('app.integer.comm_margin_padding_size12')
                  })
                Text($r('app.string.drop_off_location'))
                  .fontSize($r('app.integer.comm_font_size24'))
                  .fontWeight(FontWeight.Bold)

              }
              .height($r('app.integer.comm_height50'))
              .width(CommonConstants.FULL_PERCENT)
            }
            .height(CommonConstants.SLIDE_DOWN_LIST_HEIGHT)
            .justifyContent(FlexAlign.Center)
            .borderRadius($r('app.integer.comm_border_radius10'))
            .margin({
              left: $r('app.integer.comm_margin_padding_size16'),
              right: $r('app.integer.comm_margin_padding_size16')
            })
            .shadow({
              radius: $r('app.integer.comm_border_radius30'),
              color: $r('app.color.list_first_color'),
              offsetY: $r('app.integer.offset_y')
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(this.firstListItemHeight)
          .backgroundColor(Color.White)
          .borderRadius({
            topLeft: $r('app.integer.comm_border_radius32'),
            topRight: $r('app.integer.comm_border_radius32')
          })

          ForEach(this.listItem, (item: SettingItem) => {
            ListItem() {
              SettingItemView({ bottomAvoidHeight: this.bottomAvoidHeight })
            }
            .backgroundColor(Color.White)
            .width(CommonConstants.FULL_PERCENT)
          }, (item: SettingItem, index: number) => JSON.stringify(item) + index)
        }
        .id('scrollPart')
        .alignRules(CommonConstants.LIST_ALIGN_RULES)
        .enableScrollInteraction(this.isScroll)
        .width(CommonConstants.FULL_PERCENT)
        .edgeEffect(EdgeEffect.None) // List sliding to the top and bottom effects.
        .scrollBar(BarState.Off) // The scroll bar is not displayed.
        .sticky(StickyStyle.None) // List ceiling effect.
        .backgroundColor(Color.White)
        .height(this.listHeight)
        .offset({ y: this.positionY })
        .borderRadius(this.isShow ? $r('app.integer.not_border_radius') : $r('app.integer.comm_border_radius20'))
        .animation({
          duration: CommonConstants.PANEL_ANIMATION_DURATION,
          curve: Curve.Friction,
          iterations: CommonConstants.ANIMATION_PLAY_TIMES,
          playMode: PlayMode.Normal
        })
        .onReachStart(() => {
          this.itemNumber = 0;
        })
        .onScrollIndex((start: number) => {
          this.itemNumber = start;
        })
        .onTouch((event: TouchEvent) => {
          switch (event.type) {
            // Finger press touch screen.
            case TouchType.Down: {
              this.yStart = event.touches[0].y;
              break;
            }
            // Swipe your finger on the screen.
            case TouchType.Move: {
              // vertical coordinate of the finger leaving the screen.
              const yEnd = event.touches[0].y;
              //vertical coordinate of the finger leaving the screen.
              const height = Math.abs(Math.abs(yEnd) - Math.abs(this.yStart));
              // Sets the maximum height of the list.
              const maxHeight = this.windowHeight - this.statusBarHeight - CommonConstants.LIST_HEADER_HEIGHT;
              // Determine to swipe up, and the list slides with the gesture.
              if (yEnd <= this.yStart) {
                this.isUp = true;
                const temHeight = this.listHeight + height;
                if (temHeight >= maxHeight) {
                  this.isScroll = true;
                  this.isShow = true;
                  this.listHeight = maxHeight;
                } else {
                  this.isScroll = false;
                  this.listHeight = temHeight;
                }
              }
              // Decide to slide down, and the list slides along with the gesture.
              else {
                this.isUp = false;
                const temHeight = this.listHeight - height;
                if (this.itemNumber === 0) {
                  if (temHeight < CommonConstants.FIRST_LIST_ITEM_HEIGHT) {
                    this.listHeight = CommonConstants.FIRST_LIST_ITEM_HEIGHT;
                  } else {
                    // The list height changes with the sliding height.
                    this.listHeight = temHeight;
                  }
                } else {
                  this.listHeight = maxHeight;
                }
              }
              this.yStart = event.touches[0].y;
              break;
            }
            // Fingers off the screen
            case TouchType.Up: {
              // The list height changes with the sliding height.
              let maxHeight = this.windowHeight - this.statusBarHeight - CommonConstants.LIST_HEADER_HEIGHT;
              // Phased sliding when sliding up the list.
              if (this.isUp) {
                // phased sliding.
                // When the list height is between the first item and the second item, slide to the second item.
                if (this.listHeight > this.firstListItemHeight &&
                  this.listHeight <= this.firstListItemHeight + this.bottomAvoidHeight + this.secondListItemHeight) {
                  this.listHeight = +this.firstListItemHeight + this.secondListItemHeight;
                  this.isScroll = false;
                  this.isShow = false;
                  return;
                }
                // phased sliding.
                // When the list height is between the top and the second item, slide to the top of the page.
                else if (this.firstListItemHeight + this.bottomAvoidHeight + this.secondListItemHeight <
                this.listHeight && this.listHeight <= maxHeight) {
                  this.listHeight = maxHeight;
                  this.isScroll = true;
                  this.isShow = true;
                  return;
                }
              }
              // Sliding in stages when the list slides down.
              else {
                if (this.listHeight === maxHeight) {
                  this.isShow = true;
                  this.listHeight = maxHeight;
                }
                // Sliding in stages.
                // When the list height is between the top and the second item, slide to the second item.
                else if (this.listHeight >= this.firstListItemHeight + this.secondListItemHeight &&
                  this.listHeight <= maxHeight) {
                  this.listHeight = this.firstListItemHeight + this.secondListItemHeight;
                  this.isShow = false;
                  this.isScroll = false;
                  return;
                }
                // Sliding by stage.When the list height is between the first item and the second item,
                // the list slides to the first item.
                else if (this.listHeight <= this.firstListItemHeight + this.secondListItemHeight +
                this.bottomAvoidHeight || this.listHeight <= this.firstListItemHeight) {
                  this.listHeight = this.firstListItemHeight;
                  this.isShow = false;
                  this.isScroll = false;
                  return;
                }
              }
            }
          }
        })
      }

      // When the list slides to the third stage and then swipes up, the top navigation bar appears in the masked area.
      StatusHead({
        statusBarHeight: this.statusBarHeight,
        topHeaderHeight: CommonConstants.PAGE_HEADER_HEIGHT,
        isShow: this.isShow
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}