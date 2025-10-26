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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { curves } from '@kit.ArkUI';
import { CustomTransition } from '../../utils/customtransition/CustomNavigationUtils';
import { LongTakeAnimationProperties } from '../../utils/customtransition/LongTakeAnimationProperties';
import { CardUtil } from '../../utils/commonutils/CardUtil';
import { DetailPageContent } from './DetailPageContent';
import { SnapShotImage } from '../../utils/customtransition/SnapShotImage';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function CardLongTakeTransitionPageTwoBuilder() {
  CardLongTakeTransitionPageTwo()
}

@Component
export struct CardLongTakeTransitionPageTwo {
  @State pageInfos: NavPathStack = new NavPathStack();
  @State longTakeAnimationProperties: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @StorageProp('windowSizeChanged') @Watch('unRegisterNavParam') windowSizeChangedTime: number = 0;
  @StorageProp('onConfigurationUpdate') @Watch('unRegisterNavParam') onConfigurationUpdateTime: number = 0;
  @State snapShotImage: PixelMap | undefined = SnapShotImage.pixelMap;
  private rectWidth: number = 0;
  private scaleValue: number = 0;
  private indexValue: number = -1;
  private pageId: string = '';
  private shouldDoDefaultTransition: boolean = false;
  private clickedCardId: string | undefined = undefined;

  unRegisterNavParam(): void {
    this.shouldDoDefaultTransition = true;
  }

  onBackPressed(): boolean {
    if (this.shouldDoDefaultTransition) {
      CustomTransition.getInstance().unRegisterNavParam(this.pageId);
      this.pageInfos.pop();
      this.prePageDoFinishTransition();
      this.shouldDoDefaultTransition = false;
      return true;
    }
    this.pageInfos.pop();
    return true;
  }

  // Try to register a custom transition animation to restore the page properties to their normal state in case of an exception.
  tryRegisterCustomTransition(clickedCardId: string): void {
    try {
      // First initialize some transition information.
      this.longTakeAnimationProperties.init(clickedCardId, this.prePageDoFinishTransition);
      CustomTransition.getInstance().registerNavParam(this.pageId, 2000,
        (transitionProxy: NavigationTransitionProxy) => {
          this.longTakeAnimationProperties.doAnimation(transitionProxy);
        });
      hilog.info(0x0000, 'CardLongTakePageTwo', 'register successes');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'CardLongTakePageTwo', `this is error:code=${err.code}, message=${err.message}`);
      this.longTakeAnimationProperties.setFinalStatus();
    }
  }

  // [Start tryRegisterCustomTransition_start]

  // [StartExclude tryRegisterCustomTransition_start]
  @Styles
  GestureStyles() {
    .gesture(PanGesture()
      .onActionStart((event: GestureEvent) => {
        CustomTransition.getInstance().isInteractive = true;
        this.pageInfos.pop();
        this.rectWidth = event.target.area.width as number;
      })
      .onActionUpdate((event: GestureEvent) => {
        if (CustomTransition.getInstance().isInteractive) {
          let deltaX = event.offsetX;
          let deltaY = event.offsetY;
          this.scaleValue = Math.max(1 - (1 - 0.5) * Math.abs(deltaX) / this.rectWidth, 0.5);
          this.getUIContext().animateTo({
            curve: curves.responsiveSpringMotion()
          }, () => {
            this.longTakeAnimationProperties.translateX = deltaX;
            this.longTakeAnimationProperties.translateY = deltaY;
            this.longTakeAnimationProperties.scaleValue = this.scaleValue;
          })
        }
      })
      .onActionEnd((event: GestureEvent) => {
        if (CustomTransition.getInstance().isInteractive) {
          let currentTransitionProxy = CustomTransition.getInstance().proxy;
          let deltaX = event.offsetX;
          this.scaleValue = Math.max(1 - (1 - 0.5) * Math.abs(deltaX) / this.rectWidth, 0.5);
          if (this.scaleValue > 0.75) {
            this.getUIContext().animateTo({
              curve: curves.springMotion(),
              onFinish: () => {
                currentTransitionProxy?.cancelTransition?.();
              }
            }, () => {
              this.longTakeAnimationProperties.translateX = 0;
              this.longTakeAnimationProperties.translateY = 0;
              this.longTakeAnimationProperties.scaleValue = 1;
            })
          } else {
            this.longTakeAnimationProperties.doBackAnimation(currentTransitionProxy);
          }
          CustomTransition.getInstance().isInteractive = false;
        }
      }))
  }

  build() {
    NavDestination() {
      // Stack needs to set the alignContent to TopStart, otherwise the screenshot and content will be repositioned with the height as it changes.
      Stack({ alignContent: Alignment.TopStart }) {
        Stack({ alignContent: Alignment.TopStart }) {
          // Used to display a screenshot of the card clicked on the previous page.
          Image(this.snapShotImage)
            .size(this.longTakeAnimationProperties.snapShotSize)
            .objectFit(ImageFit.Auto)
            .opacity(this.longTakeAnimationProperties.snapShotOpacity)
            // eslint-disable-next-line @performance/hp-arkui-image-async-load
            .syncLoad(true)// The position here gives the distance from the screenshot position to the expanded page image position.
            .position({
              x: this.longTakeAnimationProperties.snapShotPositionX,
              y: this.longTakeAnimationProperties.snapShotPositionY
            })

          // The pop-up page originally displays the content, adding transparency to control its display during animation.
          DetailPageContent({
            indexValue: this.indexValue,
            pageInfos: this.pageInfos,
            onBackPressed: () => {
              this.onBackPressed()
            },
            SharedComponentId: CardUtil.getPostPageImageId(this.clickedCardId)
          })
            .size({
              width: '100%',
              height: '100%'
            })
            .opacity(this.longTakeAnimationProperties.postPageOpacity)
        }
        .width('100%')
        .position({
          x: this.longTakeAnimationProperties.positionXValue,
          y: this.longTakeAnimationProperties.positionYValue
        })
      }
      .scale({
        x: this.longTakeAnimationProperties.scaleValue,
        y: this.longTakeAnimationProperties.scaleValue
      })
      .translate({
        x: this.longTakeAnimationProperties.translateX,
        y: this.longTakeAnimationProperties.translateY
      })
      .width(this.longTakeAnimationProperties.clipWidth)
      .height(this.longTakeAnimationProperties.clipHeight)
      .borderRadius(this.longTakeAnimationProperties.radius)
      .expandSafeArea([SafeAreaType.SYSTEM])
      .backgroundColor($r('app.color.water_flow_background_color'))
      .clip(true)
    }
    .backgroundColor(this.longTakeAnimationProperties.navDestinationBgColor)
    .GestureStyles()
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      let param = context.pathInfo?.param as Record<string, Object>;
      let clickedCardId = param['clickedComponentId'] as string;
      this.indexValue = param['indexValue'] as number;
      this.prePageDoFinishTransition = param['doDefaultTransition'] as () => void;
      if (context.navDestinationId && clickedCardId) {
        this.pageId = context.navDestinationId;
        this.clickedCardId = clickedCardId;
        this.tryRegisterCustomTransition(clickedCardId);
      }
    })
    .onBackPressed(() => {
      return this.onBackPressed();
    })
    .onDisAppear(() => {
      CustomTransition.getInstance().unRegisterNavParam(this.pageId);
    })
  }

  // [EndExclude tryRegisterCustomTransition_start]

  private prePageDoFinishTransition: () => void = () => {
  };
  // [End tryRegisterCustomTransition_start]
}