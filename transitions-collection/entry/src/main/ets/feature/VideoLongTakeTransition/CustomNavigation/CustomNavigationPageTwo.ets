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
import { RectInfoInPx } from '../../../utils/commonutils/ComponentAttrUtils';
import { CustomTransition } from '../../../utils/customtransition/CustomNavigationUtils';
import {
  VideoLongTakeAnimationProperties
} from '../../../utils/customtransition/VideoLongTakeAnimationProperties';
import { getMyNode, MyNodeController } from '../NodeController';


@Builder
export function CustomNavigationPageTwoBuilder() {
  CustomNavigationPageTwo()
}

@Component
export struct CustomNavigationPageTwo {
  @State pageInfos: NavPathStack = new NavPathStack();
  @State longTakeAnimationProperties: VideoLongTakeAnimationProperties = new VideoLongTakeAnimationProperties();
  @StorageProp('windowSizeChanged') @Watch('unRegisterNavParam') windowSizeChangedTime: number = 0;
  @StorageProp('onConfigurationUpdate') @Watch('unRegisterNavParam') onConfigurationUpdateTime: number = 0;
  @State myNodeController: MyNodeController | undefined = undefined;
  private cardItemInfo: RectInfoInPx = new RectInfoInPx();
  private xComponentId: string = '';
  private rectWidth: number = 0;
  private scaleValue: number = 0;
  private pageId: string = '';
  private shouldDoDefaultTransition: boolean = false;
  private prePageDoFinishTransition: () => void = () => {
  };

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
          const deltaX = event.offsetX;
          const deltaY = event.offsetY;
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
          const currentTransitionProxy = CustomTransition.getInstance().proxy;
          const deltaX = event.offsetX;
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
            this.longTakeAnimationProperties.doBackAnimation(currentTransitionProxy, this.prePageDoFinishTransition,
              this.myNodeController);
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
          Column() {
            NodeContainer(this.myNodeController)
          }
          .size({
            width: '100%',
            height: '100%'
          })
          .justifyContent(FlexAlign.Center)
          .id(this.xComponentId)
        }
        .position({ y: this.longTakeAnimationProperties.positionValue })
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
      .backgroundColor(Color.Black)
      .clip(true)
    }
    .backgroundColor(this.longTakeAnimationProperties.navDestinationBgColor)
    .GestureStyles()
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      if (context.navDestinationId) {
        this.pageId = context.navDestinationId;
      }
      let param = context.pathInfo?.param as Record<string, Object>;
      this.xComponentId = param['xComponentId'] as string;
      this.myNodeController = getMyNode(this.xComponentId);
      this.prePageDoFinishTransition = param['prePageCallback'] as () => void;
      this.cardItemInfo = param['cardItemInfo'] as RectInfoInPx;

      CustomTransition.getInstance().registerNavParam(this.pageId, 500,
        (transitionProxy: NavigationTransitionProxy) => {
          this.longTakeAnimationProperties.doAnimation(transitionProxy,
            this.cardItemInfo, 0, this.prePageDoFinishTransition, this.myNodeController);
        });

    })
    .onBackPressed(() => {
      return this.onBackPressed();
    })
    .onDisAppear(() => {
      CustomTransition.getInstance().unRegisterNavParam(this.pageId);
    })
  }
}