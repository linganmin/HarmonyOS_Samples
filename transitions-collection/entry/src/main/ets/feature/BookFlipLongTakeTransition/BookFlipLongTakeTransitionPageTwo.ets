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

import { RectInfoInPx } from '../../utils/commonutils/ComponentAttrUtils';
import {
  BookFlipLongTakeTransitionProperties
} from '../../utils/customtransition/BookFlipLongTakeTransitionProperties';
import { CustomTransition } from '../../utils/customtransition/CustomNavigationUtils';
import { WindowUtils } from '../../utils/windowutils/WindowUtils';

@Builder
export function BookFlipLongTakeTransitionPageTwoBuilder() {
  BookFlipLongTakeTransitionPageTwo()
}

@Component
export struct BookFlipLongTakeTransitionPageTwo {
  @StorageProp('windowSizeChanged') @Watch('unRegisterNavParam') windowSizeChangedTime: number = 0;
  @State pageInfos: NavPathStack = new NavPathStack();
  @State bookFlipLongTakeTransitionProperties: BookFlipLongTakeTransitionProperties =
    new BookFlipLongTakeTransitionProperties();
  @State bookCoverUrl: string = '';
  private pageId: string = '';
  private initPositionX: number = 0;
  private toCardItemInfo: RectInfoInPx = new RectInfoInPx();
  private fromCardItemInfo: RectInfoInPx = new RectInfoInPx();
  private doDefaultTransition: boolean = false;
  private progress: number = 0;

  unRegisterNavParam(): void {
    CustomTransition.getInstance().unRegisterNavParam(this.pageId);
  }

  onBackPressed(): boolean {
    this.prePageCallback?.();
    this.pageInfos.pop();
    return true;
  }

  @Styles
  GestureStyles() {
    .gesture(PanGesture()
      .onActionStart((event: GestureEvent) => {
        this.initPositionX = event.fingerList[0].globalX;
        if (this.initPositionX > 0 && this.initPositionX <= 50) {
          this.prePageCallback?.();
          CustomTransition.getInstance().isInteractive = true;
          this.pageInfos.pop();
        }
      })
      .onActionUpdate((event: GestureEvent) => {
        if (CustomTransition.getInstance().isInteractive) {
          let deltaX = event.fingerList[0].globalX - this.initPositionX;
          this.progress = deltaX / (this.getUIContext().px2vp(WindowUtils.windowWidth_px) / 2);
          CustomTransition.getInstance().updateProgress(this.progress);
        }
      })
      .onActionEnd(() => {
        if (CustomTransition.getInstance().isInteractive) {
          CustomTransition.getInstance().finishInteractiveAnimation(this.progress);
          CustomTransition.getInstance().isInteractive = false;
        }
      }))
  }

  build() {
    // [Start NavDestination4_start]
    NavDestination() {
      Stack() {
        Column() {
          Text($r('app.string.DetailPage_text'))
            .fontColor($r('sys.color.password_icon_focus_color'))
            .lineHeight(28)
            .fontSize(16)
        }
        .width(AppStorage.get('currentBreakpoint') === 'md' ? '75%' : '100%')
        .height('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({
          left: 16,
          right: 16,
          top: 46
        })

        if (!this.doDefaultTransition) {
          Image($r(this.bookCoverUrl))
            .objectFit(ImageFit.Cover)
            // eslint-disable-next-line @performance/hp-arkui-image-async-load
            .syncLoad(true)
            .rotate({
              x: 0,
              y: 1,
              z: 0,
              angle: this.bookFlipLongTakeTransitionProperties.coverRotateAngle,
              centerX: 0,
              centerY: '50%'
            })
            .scale({
              x: this.bookFlipLongTakeTransitionProperties.coverScale,
              centerX: 0,
              centerY: '50%'
            })
        }
      }
      .scale({
        x: this.bookFlipLongTakeTransitionProperties.scaleValue,
        y: this.bookFlipLongTakeTransitionProperties.scaleValue
      })
      .translate({
        x: this.bookFlipLongTakeTransitionProperties.translateX,
        y: this.bookFlipLongTakeTransitionProperties.translateY
      })
      .width(this.bookFlipLongTakeTransitionProperties.clipWidth)
      .height(this.bookFlipLongTakeTransitionProperties.clipHeight)
      .backgroundColor('#DEDFDF')
    }
    .backgroundColor(this.bookFlipLongTakeTransitionProperties.navDestinationBgColor)
    .GestureStyles()
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      let param = context.pathInfo?.param as Record<string, Object>;
      this.bookCoverUrl = param['bookCoverUrl'] as string;
      this.fromCardItemInfo = param['fromCardItemInfo'] as RectInfoInPx;
      this.toCardItemInfo = (param['toCardItemInfo'] || param['fromCardItemInfo']) as RectInfoInPx;
      this.prePageCallback = param['prePageCallback'] as () => void;
      if (context.navDestinationId) {
        this.pageId = context.navDestinationId;
      }
      CustomTransition.getInstance()
        .registerNavParam(this.pageId, 500, (transitionProxy: NavigationTransitionProxy) => {
          this.bookFlipLongTakeTransitionProperties.doAnimation(transitionProxy, this.fromCardItemInfo,
            this.toCardItemInfo);
        }, () => {
          this.bookFlipLongTakeTransitionProperties.onInteractiveFinish();
        }, () => {
          this.bookFlipLongTakeTransitionProperties.onInteractive(
            this.fromCardItemInfo, this.toCardItemInfo);
        });
    })
    .onBackPressed(() => {
      return this.onBackPressed();
    })
    .onDisAppear(() => {
      CustomTransition.getInstance().unRegisterNavParam(this.pageId);
    })

    // [End NavDestination4_start]
  }

  private prePageCallback?: () => void = () => {
  };
}