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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { windowSizeManager } from '../utils/CommonUtils';
import { ImageModel } from '../model/CommonModel';

const TAG: string = '[ImageItemView]';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext!.getHostContext()!;
@Reusable
@Component
export struct ImageItemView {
  @State imageData: Resource = $r('app.media.ic_image1');
  @State imageModel: ImageModel = new ImageModel();
  // Whether to display the picture toolbar
  @Link isOverlay: boolean;
  // Swipe whether to switch
  @Consume isDisableSwipe: boolean;
  @Consume @Watch('onImageReset') isImageReset: boolean;
  @Consume bgc: Color;
  private context: common.UIAbilityContext = context as common.UIAbilityContext;
  // Image original aspect ratio
  private imageWHRatio: number = 0;

  aboutToAppear(): void {
    this.imageModel.windowSize();
    setTimeout(() => {
      this.initCurrentImageInfo();
    }, 10);
  }

  // When switching images, reset the previous image
  onImageReset(): void {
    if (this.isImageReset) {
      this.imageModel.imageReset();
    }
  }

  // [Start init_current_image_info]
  /**
   * Set information about the current image: uri, whRatio, pixelMap, defaultSize, maxScaleValue
   * Obtain the Image information in advance for the size setting of
   * the image component and subsequent related calculations
   */
  initCurrentImageInfo(): void {
    try {
      let img = this.context.resourceManager.getMediaContentSync(this.imageData?.id);
      let imageSource = image.createImageSource(img.buffer.slice(0));
      imageSource.getImageInfo(0).then((data: image.ImageInfo) => {
        this.imageWHRatio = data.size.width / data.size.height;
        this.imageModel.imageWidth = this.imageModel.componentWidth;
        this.imageModel.imageHeight = this.imageModel.imageWidth / this.imageWHRatio;
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `[error][getImageInfo]${err.message}`);
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `GetMediaContentSync failed. Cause code: ${err.code}, message: ${err.message}`);
    }
  }
  // [End init_current_image_info]

  build() {
    Stack() {
      Image(this.imageData)
        .width(this.imageModel.imageWidth)
        .height(this.imageModel.imageHeight)
        .aspectRatio(this.imageWHRatio)
        .objectFit(ImageFit.Cover)
        .autoResize(false)
        .defaultFocus(true)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .transform(this.imageModel.matrix)// Control picture scaling with matrix
        .translate({
          x: this.imageModel.curOffsetX,
          y: this.imageModel.curOffsetY
        })
        .onComplete(() => {
          this.imageModel.maxScale = this.imageModel.calcFitScaleRatio({
            width: this.imageModel.imageWidth,
            height: this.imageModel.imageHeight
          }, windowSizeManager.get());
        })
    }
    .backgroundColor(this.bgc)
    .alignContent(Alignment.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .width('100%')
    .height('100%')
    .parallelGesture(
      GestureGroup(
        GestureMode.Exclusive,
        // [Start pan_gesture_fingers_one]
        // Slide picture
        // Swiping left and right under the default size should switch images
        // [Start component_pan_gesture]
        PanGesture({ fingers: 1, distance: this.isDisableSwipe ? 3 : 50 })
          // [End component_pan_gesture]
          .onActionUpdate((event: GestureEvent) => {
            this.isDisableSwipe = this.imageModel.panGestureUpdate(event);
          })
          .onActionEnd(() => {
            this.imageModel.gestureEnd();
          }),
        // [End pan_gesture_fingers_one]
        // [Start pan_gesture_fingers_two]
        // Two-finger scaling
        PinchGesture({ fingers: 2, distance: 1 })
          .onActionStart((event: GestureEvent) => {
            this.imageModel.pinchGestureStart(event);
            if (this.isOverlay) {
              this.isOverlay = false;
            }
          })
          .onActionUpdate((event: GestureEvent) => {
            this.isDisableSwipe = this.imageModel.pinchGestureUpdate(event);
          })
          .onActionEnd(() => {
            this.imageModel.pinchGestureEnd();
          }),
        // [End pan_gesture_fingers_two]
        // Double click picture
        TapGesture({ count: 2 })
          .onAction((event: GestureEvent) => {
            this.isDisableSwipe = this.imageModel.doubleTapGesture(event);
          }),
        // Click Switch picture toolbar
        TapGesture({ count: 1 })
          .onAction(() => {
            this.isOverlay = !this.isOverlay;
          })
        // Pinching and scaling images with two fingers
      ), GestureMask.Normal
    )
  }
}