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

import { RectInfoInPx } from '../commonutils/ComponentAttrUtils';
import { WindowUtils } from '../windowutils/WindowUtils';
import { CustomTransition } from './CustomNavigationUtils';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
interface Information {
  initTranslateX: number;
  initClipWidth: Dimension;
  initClipHeight: Dimension;
  initTranslateY: number;
  initScale: number;
  isUseWidthScale: boolean;
}

const getInitialInformation = (cardItemInfo_px: RectInfoInPx): Information => {
  // First calculate the ratio of the width and height of the card to the width and height of the window.
  let widthScaleRatio = cardItemInfo_px.width / WindowUtils.windowWidth_px;
  let heightScaleRatio = cardItemInfo_px.height / WindowUtils.windowHeight_px;
  let isUseWidthScale = widthScaleRatio > heightScaleRatio;
  let initScale: number = isUseWidthScale ? widthScaleRatio : heightScaleRatio;

  let initTranslateX: number = 0;
  let initClipWidth: Dimension = 0;
  let initClipHeight: Dimension = 0;
  let initTranslateY: number = 0;

  if (isUseWidthScale) {
    initTranslateX = uiContext?.px2vp(cardItemInfo_px.left - (WindowUtils.windowWidth_px - cardItemInfo_px.width) / 2) as number;
    initClipWidth = '100%';
    initClipHeight = uiContext?.px2vp((cardItemInfo_px.height) / initScale) as number;
    initTranslateY = uiContext?.px2vp(cardItemInfo_px.top - ((uiContext?.vp2px(initClipHeight) - uiContext?.vp2px(initClipHeight) * initScale) / 2)) as number;

  } else {
    initTranslateY = uiContext?.px2vp(cardItemInfo_px.top - (WindowUtils.windowHeight_px - cardItemInfo_px.height) / 2) as number;
    initClipHeight = '100%';
    initClipWidth = uiContext?.px2vp((cardItemInfo_px.width) / initScale) as number;
    initTranslateX = uiContext?.px2vp(cardItemInfo_px.left - (WindowUtils.windowWidth_px / 2 - cardItemInfo_px.width / 2)) as number;
  }

  return {
    initTranslateX,
    initTranslateY,
    initClipWidth,
    initClipHeight,
    initScale,
    isUseWidthScale
  };
}

@Observed
export class BookFlipLongTakeTransitionProperties {
  public navDestinationBgColor: ResourceColor = Color.Transparent;
  public translateX: number = 0;
  public translateY: number = 0;
  public scaleValue: number = 1;
  public coverRotateAngle: number = 0;
  public coverScale: number = 1;
  public clipWidth: Dimension = 0;
  public clipHeight: Dimension = 0;

  private doEnterAnimation(fromCardItemInfo_px: RectInfoInPx, isInteractive?: boolean,
    transitionProxy?: NavigationTransitionProxy) {
    const fromCardItemInfo = getInitialInformation(fromCardItemInfo_px);
    this.scaleValue = fromCardItemInfo.initScale;
    this.translateX = fromCardItemInfo.initTranslateX;
    this.clipWidth = fromCardItemInfo.initClipWidth;
    this.clipHeight = fromCardItemInfo.initClipHeight;
    this.translateY = fromCardItemInfo.initTranslateY;

    // Start animation.
    uiContext?.animateTo({
      duration: 500,
      curve: Curve.EaseInOut,
      onFinish: () => {
        transitionProxy?.finishTransition();
      }
    }, () => {
      this.scaleValue = 1;
      this.translateX = 0;
      this.translateY = 0;
      this.clipWidth = '100%';
      this.clipHeight = '100%';
      // When following the hand, the cover only scales in the X-axis direction and does not rotate.
      if (!isInteractive) {
        this.coverRotateAngle = -90;
      }
      this.coverScale = 0;
    });

    uiContext?.animateTo({
      duration: 200,
      curve: Curve.Sharp
    }, () => {
      this.navDestinationBgColor = '#33000000';
    });
  }


  private doExistAnimation(toCardItemInfo_px: RectInfoInPx, isInteractive?: boolean,
    transitionProxy?: NavigationTransitionProxy) {
    const toCardItemInfo = getInitialInformation(toCardItemInfo_px);

    // When following the hand, the cover only scales in the X-axis direction and does not rotate.
    if (isInteractive) {
      this.coverRotateAngle = 0;
    }

    uiContext?.animateTo({
      duration: 500,
      curve: Curve.EaseInOut,
      onFinish: () => {
        transitionProxy?.finishTransition();
      }
    }, () => {
      this.scaleValue = toCardItemInfo.initScale;
      this.translateX = toCardItemInfo.initTranslateX;
      this.clipWidth = toCardItemInfo.initClipWidth;
      this.clipHeight = toCardItemInfo.initClipHeight;
      this.translateY = toCardItemInfo.initTranslateY;
      this.coverRotateAngle = 0;
      this.coverScale = 1;
    });

    uiContext?.animateTo({
      duration: 200,
      delay: 150,
      curve: Curve.Friction
    }, () => {
      this.navDestinationBgColor = '#00ffffff';
    });
  }


  public doAnimation(transitionProxy: NavigationTransitionProxy, fromCardItemInfo_px: RectInfoInPx,
    toCardItemInfo_px: RectInfoInPx): void {
    if (CustomTransition.getInstance().operation === NavigationOperation.PUSH) {
      this.doEnterAnimation(fromCardItemInfo_px, false, transitionProxy);
    } else if (CustomTransition.getInstance().operation === NavigationOperation.POP) {
      this.doExistAnimation(toCardItemInfo_px, false, transitionProxy);
    }
  }

  public onInteractive(fromCardItemInfo_px: RectInfoInPx, toCardItemInfo_px: RectInfoInPx) {
    if (CustomTransition.getInstance().operation === NavigationOperation.PUSH) {
      this.doEnterAnimation(fromCardItemInfo_px, true);
    } else if (CustomTransition.getInstance().operation === NavigationOperation.POP) {
      this.doExistAnimation(toCardItemInfo_px, true);
    }
  }

  public onInteractiveFinish() {
    this.scaleValue = 1;
    this.translateX = 0;
    this.translateY = 0;
    this.clipWidth = '100%';
    this.clipHeight = '100%';
    this.coverScale = 0;
  }
}