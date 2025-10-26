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

import { Callback } from '@kit.BasicServicesKit';
import { MemoDataSource } from '../model/DataSource';
import { MemoInfo } from '../model/MemoInfo';
import MemoItem from './MemoItem';
import Constants from '../common/Constants';

@Component
export struct PageExpandTitle {
  // Title Whether to expand the list Whether to complete the first slide.
  @State @Watch('isContinuePullDown') isExpanded: boolean = false;
  // Is the note list being dragged.
  @State @Watch('isContinuePullDown') isMoving: boolean = false;
  // List Y-Offset.
  @State @Watch('isContinuePullDown') offsetY: number = Constants.INIT_COORDINATE;
  // Whether the note list content is on the top.
  @State @Watch('isContinuePullDown') atStart: boolean = true;
  // Note List Layout Height.
  @State heightValue: ResourceStr = Constants.AREA_HEIGHT_BEFORE;
  // Animation Duration.
  @State duration: number = Constants.ANIMATE_DURATION_DRAG;
  // Deferred loading simulation data source.
  @State memoData: MemoDataSource = new MemoDataSource();
  // Y coordinate when the button is pressed.
  private downY: number = Constants.INIT_COORDINATE;
  // Coordinates at the end of the last move.
  private lastMoveY: number = Constants.INIT_COORDINATE;
  // Throttle status.
  private throttleStatus: boolean = true;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // [Start set_animation]
      Column() {
        Row() {
          Text(!this.isExpanded ? $r('app.string.memo_title') : '')
            .fontSize($r('app.float.init_title_font_size'))
          Blank()
          // Image($r('app.media.is_public_add'))
          //   .width($r('app.float.menu_pic_layout'))
          //   .height($r('app.float.menu_pic_layout'))
          // Image($r('app.media.ic_public_more'))
          //   .width($r('app.float.menu_pic_layout'))
          //   .height($r('app.float.menu_pic_layout'))
          //   .margin({ left: $r('app.float.layout_8') })
        }
        .width(Constants.LAYOUT_MAX_PERCENT)
        .padding($r('app.float.layout_25'))
        .margin({ top: $r('app.float.layout_10') })
        .alignItems(VerticalAlign.Center)
        .translate(this.getMenuTranslateOptions())
        .animation({ duration: this.duration, curve: Curve.FastOutLinearIn })

        Column() {
          Text($r('app.string.memo_title'))
            .fontSize($r('app.float.expanded_title_font_size'))
          Text($r('app.string.memo_counts'))
            .fontSize($r('app.float.memo_counts_font_size'))
            .fontColor(Color.Grey)
        }
        .width(Constants.LAYOUT_MAX_PERCENT)
        .padding({ left: $r('app.float.layout_25') })
        .margin({ top: $r('app.float.layout_10') })
        .alignItems(HorizontalAlign.Start)
        .translate(this.getTitleTranslateOptions())
        .scale(this.getTitleScaleOptions())
        .animation({ duration: this.duration, curve: Curve.FastOutLinearIn })
        .transition({ type: TransitionType.Insert, translate: { y: Constants.TRANSLATE_Y } })
        .visibility(this.isExpanded ? Visibility.Visible : Visibility.Hidden)
      }
      .height(Constants.LAYOUT_MAX_PERCENT)
      .width(Constants.LAYOUT_MAX_PERCENT)
      // [End set_animation]

      // [Start set_touch_event]
      Column() {
        List({ space: Constants.SEARCH_MEMO_SPACE }) {
          ListItem() {
            Search({ placeholder: $r('app.string.search_placeholder') })
              .width(Constants.LAYOUT_MAX_PERCENT)
              .height(Constants.LAYOUT_EIGHT_PERCENT)
              .backgroundColor(Color.White)
              .enableKeyboardOnFocus(false)
          }

          LazyForEach(this.memoData, (item: MemoInfo) => {
            ListItem() {
              MemoItem({ memoItem: item })
            }
          }, (item: MemoInfo) => JSON.stringify(item))
        }
        .scrollBar(BarState.Off)
        .margin({ left: $r('app.float.layout_10'), right: $r('app.float.layout_10') })
        .width(Constants.LAYOUT_NINETY_PERCENT)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onReachStart(() => {
          this.atStart = true;
        })
      }
      .width(Constants.LAYOUT_MAX_PERCENT)
      .height(this.heightValue)
      .animation({ duration: this.duration, curve: Curve.FastOutLinearIn })
      .onTouch((event: TouchEvent) => this.handleTouchEvent(event))
      // [End set_touch_event]
    }
    .backgroundColor('#F1F3F5')
  }

  getMenuTranslateOptions(): TranslateOptions {
    return this.isContinuePullDown() ? {
      y: Math.min(this.offsetY - Constants.CONTENT_DOWN_Y_THRESHOLD, Constants.MENU_DOWN_Y_MAX_VALUE)
    } : { y: Constants.INIT_COORDINATE };
  }

  getTitleTranslateOptions(): TranslateOptions {
    return this.isContinuePullDown() ?
      { y: Math.min(this.offsetY - Constants.CONTENT_DOWN_Y_THRESHOLD, Constants.TITLE_DOWN_Y_MAX_VALUE) } :
      { y: Constants.INIT_COORDINATE };
  }

  getTitleScaleOptions(): ScaleOptions {
    return this.isContinuePullDown() ? {
      x: Constants.TITLE_SCALE_MAX_VALUE,
      y: Constants.TITLE_SCALE_MAX_VALUE,
      centerX: Constants.INIT_COORDINATE,
      centerY: Constants.INIT_COORDINATE
    } : {
      x: Constants.TITLE_SCALE_DEFAULT_VALUE,
      y: Constants.TITLE_SCALE_DEFAULT_VALUE,
      centerX: Constants.INIT_COORDINATE,
      centerY: Constants.INIT_COORDINATE
    };
  }

  isContinuePullDown(): boolean {
    return this.isMoving && this.isExpanded && this.offsetY >= Constants.CONTENT_DOWN_Y_THRESHOLD;
  }

  // [Start handle_touch_event]
  handleTouchEvent(event: TouchEvent): void {
    switch (event.type) {
      case TouchType.Down:
        this.downY = event.touches[0].y;
        this.lastMoveY = event.touches[0].y;
        this.isMoving = true;
        this.duration = Constants.ANIMATE_DURATION_DRAG;
        break;

      case TouchType.Move:
        const delta = event.touches[0].y - this.lastMoveY;
        this.offsetY = event.touches[0].y - this.downY;
        if (delta < 0) {
          this.heightValue = Constants.AREA_HEIGHT_BEFORE;
          this.isExpanded = false;
          this.atStart = false;
        }
        if (delta > 0 && this.atStart) {
          this.animateToThrottle(() => {
            this.heightValue = Constants.AREA_HEIGHT_AFTER;
            this.isExpanded = true;
          }, 1000);
        }
        this.lastMoveY = event.touches[0].y;
        break;

      case TouchType.Cancel:
        this.isMoving = false;
        this.duration = Constants.ANIMATE_DURATION_BACK;
        break;
      default:
        break;
    }
  }
  // [End handle_touch_event]

  animateToThrottle(fn: Callback<void>, delay: number) {
    if (this.throttleStatus) {
      this.getUIContext().animateTo({
        duration: this.duration, curve: Curve.FastOutLinearIn
      }, fn);
      this.throttleStatus = false;
      setTimeout(() => {
        this.throttleStatus = true;
      }, delay);
    }
  }
}

@Builder
export function getPageExpandTitle(name: string): void {
  if (name === 'PageExpandTitle') {
    NavDestination() {
      PageExpandTitle()
    }
    .backgroundColor('#F1F3F5')
  }
}

export const wrappedBuilderExpandTitle: WrappedBuilder<[string, number]> = wrapBuilder(getPageExpandTitle);