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

import { inspector } from '@kit.ArkUI';
import { ComponentAttrUtils, RectInfoInPx } from '../../../utils/commonutils/ComponentAttrUtils';
import { WindowUtils } from '../../../utils/windowutils/WindowUtils';
import { createMyNode, getMyNode, MyNodeController } from './CustomComponent';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

class AnimationInfo {
  scale: number = 0;
  translateX: number = 0;
  translateY: number = 0;
  clipWidth: Dimension = 0;
  clipHeight: Dimension = 0;
}

@Builder
export function SemiModalImageBuilder() {
  SemiModalImage();
}

@Component
struct SemiModalImage {
  @State isShowSheet: boolean = false;
  @State isShowImage: boolean = false;
  @State isShowOverlay: boolean = false;
  @State isAnimating: boolean = false;
  @State isEnabled: boolean = true;
  @State scaleValue: number = 0;
  @State translateX: number = 0;
  @State translateY: number = 0;
  @State clipWidth: Dimension = 0;
  @State clipHeight: Dimension = 0;
  @State radius: number = 0;
  // Transparency of the artwork.
  @State opacityDegree: number = 1;
  // Set the layout listening of the image on the half mode.
  listener: inspector.ComponentObserver = this.getUIContext().getUIInspector().createComponentObserver('target');
  // Capture the original location of the photo.
  private originInfo: AnimationInfo = new AnimationInfo;
  // Grab photo position information on a semi-modal page.
  private targetInfo: AnimationInfo = new AnimationInfo;
  // Half-mode height.
  private bindSheetHeight: number = 450;
  // Half mode top picture rounded corners.
  private sheetRadius: number = 20;

  // [Start aboutToAppear_start]
  aboutToAppear(): void {
    // Set the layout of the image on the half mode to complete the callback.
    let onLayoutComplete: () => void = (): void => {
      // Grab the layout information when the target image layout is complete.
      this.targetInfo = this.calculateData('target');
      // Only half modes are correctly laid out and a mirror is triggered when there is no animation at this time.
      if (this.targetInfo.scale !== 0 && this.targetInfo.clipWidth !== 0 && this.targetInfo.clipHeight !== 0 &&
        !this.isAnimating) {
        this.isAnimating = true;
        // Property animation for a mirror to the bottom of a modal page.
        this.getUIContext().animateTo({
          duration: 1000,
          curve: Curve.Friction,
          onFinish: () => {
            // Custom node subtree on overlay page.
            this.isShowOverlay = false;
            // Custom nodes on the semi-modal tree, thus completing node migration.
            this.isShowImage = true;
          }
        }, () => {
          this.scaleValue = AppStorage.get('currentBreakpoint') === 'md' ? 0.382 : this.targetInfo.scale;
          this.translateX = AppStorage.get('currentBreakpoint') === 'md' ? 93.5 : this.targetInfo.translateX;
          this.clipWidth = AppStorage.get('currentBreakpoint') === 'md' ? 525 : this.targetInfo.clipWidth;
          this.clipHeight = AppStorage.get('currentBreakpoint') === 'md' ? 785 : this.targetInfo.clipHeight;
          // Fixed height differences due to half-mode height and scaling.
          this.translateY = this.targetInfo.translateY +
            (this.getUIContext().px2vp(WindowUtils.windowHeight_px) - this.bindSheetHeight -
            this.getUIContext().px2vp(WindowUtils.navigationIndicatorHeight_px) -
            this.getUIContext().px2vp(WindowUtils.topAvoidAreaHeight_px)) -
            (AppStorage.get('currentBreakpoint') === 'md' ? 134.3 : 0);
          // Fixed differences in rounded corners due to scaling.
          this.radius = this.sheetRadius / this.scaleValue;
        })
        // The artwork goes from transparent to animated.
        this.getUIContext().animateTo({
          duration: 2000,
          curve: Curve.Friction,
        }, () => {
          this.opacityDegree = 1;
        })
      }
    };
    // Open layout listening.
    this.listener.on('layout', onLayoutComplete);
  }

  // [End aboutToAppear_start]

  // Gets the properties in the upper-left corner of the relative window for the component with the corresponding id.
  calculateData(id: string): AnimationInfo {
    let itemInfo: RectInfoInPx | undefined = undefined;
    try {
      itemInfo = ComponentAttrUtils.getRectInfoById(WindowUtils.window.getUIContext(), id);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'SemiModalImage', `getRectInfoById error code=${error.code}, message=${error.message}`);
    }
    if (!itemInfo) {
      return {
        scale: 0,
        translateX: 0,
        translateY: 0,
        clipWidth: 0,
        clipHeight: 0
      };
    }
    // First, calculate the ratio of the width and height of the picture to the width and height of the window.
    let widthScaleRatio = itemInfo.width / WindowUtils.windowWidth_px;
    let heightScaleRatio = itemInfo.height / WindowUtils.windowHeight_px;
    let isUseWidthScale = widthScaleRatio > heightScaleRatio;
    let itemScale: number = isUseWidthScale ? widthScaleRatio : heightScaleRatio;
    let itemTranslateX: number = 0;
    let itemClipWidth: Dimension = 0;
    let itemClipHeight: Dimension = 0;
    let itemTranslateY: number = 0;

    if (isUseWidthScale) {
      itemTranslateX = this.getUIContext().px2vp(itemInfo.left - (WindowUtils.windowWidth_px - itemInfo.width) / 2);
      itemClipWidth = '100%';
      itemClipHeight = this.getUIContext().px2vp((itemInfo.height) / itemScale);
      itemTranslateY = this.getUIContext()
        .px2vp(itemInfo.top -
          ((this.getUIContext().vp2px(itemClipHeight) - this.getUIContext().vp2px(itemClipHeight) * itemScale) / 2));
    } else {
      itemTranslateY = this.getUIContext().px2vp(itemInfo.top - (WindowUtils.windowHeight_px - itemInfo.height) / 2);
      itemClipHeight = '100%';
      itemClipWidth = this.getUIContext().px2vp((itemInfo.width) / itemScale);
      itemTranslateX = this.getUIContext().px2vp(itemInfo.left - (WindowUtils.windowWidth_px / 2 - itemInfo.width / 2));
    }

    return {
      scale: itemScale,
      translateX: itemTranslateX,
      translateY: itemTranslateY,
      clipWidth: itemClipWidth,
      clipHeight: itemClipHeight
    }
  }

  // Photo page.
  build() {
    // [Start NavDestination2_start]
    NavDestination() {
      Column() {
        Image($r('app.media.flower'))
          .opacity(this.opacityDegree)
          .width('90%')
          .id('origin')
          .enabled(this.isEnabled)
          .onClick(() => {
            this.originInfo = this.calculateData('origin');
            this.scaleValue = this.originInfo.scale;
            this.translateX = this.originInfo.translateX;
            this.translateY = this.originInfo.translateY;
            this.clipWidth = this.originInfo.clipWidth;
            this.clipHeight = this.originInfo.clipHeight;
            this.radius = 0;
            this.opacityDegree = 0;
            this.isShowSheet = true;
            this.isShowOverlay = true;
            // Set the artwork to non-interactive interrupt resistant.
            this.isEnabled = false;
          })
      }
      .width('100%')
      .height('100%')
      .padding({ top: 16 })
      .alignItems(HorizontalAlign.Center)
      .bindSheet(this.isShowSheet, this.mySheet(), {
        mode: SheetMode.EMBEDDED,
        height: this.bindSheetHeight,
        onDisappear: () => {
          // Ensure that the state is correct when the half-mode disappears.
          this.isShowImage = false;
          this.isShowSheet = false;
          // Set a mirror at the end of the animation to enter the trigger state.
          this.isAnimating = false;
          // The artwork becomes interoperable again.
          this.isEnabled = true;
        }
      })
      .bindContentCover(this.isShowOverlay, this.overlayNode(), {
        // The modal page is set to no transition
        transition: TransitionEffect.IDENTITY
      })
    }
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .title('half mode')

    // [End NavDestination2_start]
  }

  // Semi-modal page.
  @Builder
  mySheet() {
    Column() {
      Row() {
        Column() {
          if (this.isShowImage) {
            // Custom image nodes for semi-modal pages.
            ImageNode()
          } else {
            // Grab layout and placeholder, not actually displayed.
            Image($r('app.media.flower'))
              .visibility(Visibility.Hidden)
          }
        }
        .height(300)
        .width(200)
        .borderRadius(20)
        .clip(true)
        .id('target')
      }
      .alignItems(VerticalAlign.Center)
    }
    .alignItems(HorizontalAlign.Center)
    .height('100%')
    .width('100%')
    .margin({ top: 56 })
  }

  @Builder
  overlayNode() {
    // Stack needs to set the alignContent to TopStart, otherwise the screenshot and content will be repositioned with the height as it changes.
    Stack({ alignContent: Alignment.TopStart }) {
      ImageNode()
    }
    .scale({
      x: this.scaleValue,
      y: this.scaleValue,
      centerX: undefined,
      centerY: undefined
    })
    .translate({
      x: this.translateX,
      y: this.translateY
    })
    .width(this.clipWidth)
    .height(this.clipHeight)
    .borderRadius(this.radius)
    .clip(true)
  }
}

@Component
struct ImageNode {
  @State myNodeController: MyNodeController | undefined = new MyNodeController(false);

  aboutToAppear(): void {
    // Get a custom node.
    let node = getMyNode();
    if (node === undefined) {
      // Creating a user-defined node.
      createMyNode(this.getUIContext());
    }
    this.myNodeController = getMyNode();
  }

  aboutToDisappear(): void {
    if (this.myNodeController !== undefined) {
      // Nodal tree.
      this.myNodeController.onRemove();
    }
  }

  build() {
    NodeContainer(this.myNodeController)
  }
}