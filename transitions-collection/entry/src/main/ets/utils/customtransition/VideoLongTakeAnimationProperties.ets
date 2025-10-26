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

import { curves } from '@kit.ArkUI';
import { MyNodeController } from '../../feature/VideoLongTakeTransition/NodeController';
import { RectInfoInPx } from '../commonutils/ComponentAttrUtils';
import { WindowUtils } from '../windowutils/WindowUtils';
import { CustomTransition } from './CustomNavigationUtils';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
// Encapsulate the custom mirror transition animation, so that if other interfaces also need to customize a mirror transition, they can be reused directly and reduce the workload.
@Observed
export class VideoLongTakeAnimationProperties {
  public navDestinationBgColor: ResourceColor = Color.Transparent;
  public translateX: number = 0;
  public translateY: number = 0;
  public scaleValue: number = 1;
  public clipWidth: Dimension = 0;
  public clipHeight: Dimension = 0;
  public radius: number = 16;
  public positionValue: number = 0;
  private animationCount: number = 0;
  private initScale: number = 1;
  private initTranslateX: number = 0;
  private initClipWidth: Dimension = 0;
  private initClipHeight: Dimension = 0;
  private initTranslateY: number = 0;
  private initPositionValue: number = 0;

  public doAnimation(transitionProxy: NavigationTransitionProxy, cardItemInfo_px: RectInfoInPx,
    extraTranslateValue: number, prePageOnFinish: () => void,
    nodeController: MyNodeController | undefined): void {
    // First calculate the ratio of the width and height of the card to the width and height of the window.
    let widthScaleRatio = cardItemInfo_px.width / WindowUtils.windowWidth_px;
    let heightScaleRatio = cardItemInfo_px.height / WindowUtils.windowHeight_px;
    let isUseWidthScale = widthScaleRatio > heightScaleRatio;
    this.initScale = isUseWidthScale ? widthScaleRatio : heightScaleRatio;
    this.initPositionValue = -(uiContext?.px2vp(WindowUtils.topAvoidAreaHeight_px + extraTranslateValue) as number);

    if (isUseWidthScale) {
      this.initTranslateX = uiContext?.px2vp(cardItemInfo_px.left - (WindowUtils.windowWidth_px - cardItemInfo_px.width) / 2) as number;
      this.initClipWidth = '100%';
      this.initClipHeight = uiContext?.px2vp((cardItemInfo_px.height) / this.initScale) as number;
      this.initTranslateY =
        uiContext?.px2vp(cardItemInfo_px.top - ((uiContext?.vp2px(this.initClipHeight) - uiContext?.vp2px(this.initClipHeight) * this.initScale) / 2)) as number;
    } else {
      this.initTranslateY = uiContext?.px2vp(cardItemInfo_px.top - (WindowUtils.windowHeight_px - cardItemInfo_px.height) / 2) as number;
      this.initClipHeight = '100%';
      this.initClipWidth = uiContext?.px2vp((cardItemInfo_px.width) / this.initScale) as number;
      this.initTranslateX = uiContext?.px2vp(cardItemInfo_px.left - (WindowUtils.windowWidth_px / 2 - cardItemInfo_px.width / 2)) as number;
    }


    if (CustomTransition.getInstance().operation === NavigationOperation.PUSH) {
      this.scaleValue = this.initScale;
      this.translateX = this.initTranslateX;
      this.clipWidth = this.initClipWidth;
      this.clipHeight = this.initClipHeight;
      this.translateY = this.initTranslateY;
      this.positionValue = this.initPositionValue;

      let animationCount = ++this.animationCount;

      // Start animation.
      uiContext?.animateTo({
        curve: curves.interpolatingSpring(0, 1, 328, 36),
        onFinish: () => {
          transitionProxy.finishTransition()
          if (animationCount === this.animationCount) {
            this.radius = 0;
          }
        }
      }, () => {
        this.scaleValue = 1.0;
        this.translateX = 0;
        this.translateY = 0;
        this.clipWidth = '100%';
        this.clipHeight = '100%';
        this.positionValue = 0;
        this.radius = 34;
      });

      uiContext?.animateTo({
        duration: 100,
        curve: Curve.Sharp,
      }, () => {
        this.navDestinationBgColor = '#33000000';
      });

    } else if (CustomTransition.getInstance().operation === NavigationOperation.POP) {
      ++this.animationCount;
      this.doBackAnimation(transitionProxy, prePageOnFinish, nodeController);
    }
  }

  public doBackAnimation(transitionProxy: NavigationTransitionProxy | undefined, prePageOnFinish: () => void, _nodeController: MyNodeController | undefined) {
    uiContext?.animateTo({
      duration: 350,
      curve: Curve.EaseInOut,
      onFinish: () => {
        transitionProxy?.finishTransition()
        _nodeController = undefined;
        prePageOnFinish();
      }
    }, () => {
      this.scaleValue = this.initScale;
      this.translateX = this.initTranslateX;
      this.clipWidth = this.initClipWidth;
      this.clipHeight = this.initClipHeight;
      this.translateY = this.initTranslateY;
      this.radius = 16;
      this.positionValue = this.initPositionValue;
    })

    uiContext?.animateTo({
      duration: 200,
      delay: 150,
      curve: Curve.Friction,
    }, () => {
      this.navDestinationBgColor = '#00ffffff';
    })
  }
}