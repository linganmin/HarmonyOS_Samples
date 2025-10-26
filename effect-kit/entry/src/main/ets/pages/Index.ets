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
import { window } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';
import { image } from '@kit.ImageKit';
import { effectKit } from '@kit.ArkGraphics2D';
import CommonConstants from '../constants/CommonContants';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State imgData: Resource[] = [
    $r('app.media.image1'),
    $r('app.media.image2'),
    $r('app.media.image3'),
    $r('app.media.image4'),
    $r('app.media.image5'),
    $r('app.media.image6'),
    $r('app.media.image7'),
    $r('app.media.image8'),
  ];
  @State bgColor: string = CommonConstants.START_WINDOW_BACKGROUND;
  @State topSafeHeight: number = 0;
  private swiperController: SwiperController = new SwiperController();
  private swiperInterval: number = CommonConstants.SWIPER_INTERVAL;
  private swiperDuration: number = CommonConstants.SWIPER_DURATION;
  private swiperItemSpace: number = CommonConstants.SWIPER_ITEM_SPACE;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  async aboutToAppear() {
    try {
      let windowHeight: window.Window = await window.getLastWindow(this.context);
      await windowHeight.setWindowLayoutFullScreen(true);
      this.topSafeHeight = this.getUIContext().px2vp(windowHeight.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height)

      const context = this.context;
      const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
      const fileData: Uint8Array = await resourceMgr.getMediaContent(this.imgData[0].id);
      const buffer = fileData.buffer as ArrayBuffer;
      const imageSource: image.ImageSource = image.createImageSource(buffer);
      const pixelMap: image.PixelMap = await imageSource.createPixelMap();

      effectKit.createColorPicker(pixelMap, (err, colorPicker) => {
        let color = colorPicker.getMainColorSync();
        this.bgColor =
          "#" + color.alpha.toString(CommonConstants.HEXADECIMAL) + color.red.toString(CommonConstants.HEXADECIMAL) +
          color.green.toString(CommonConstants.HEXADECIMAL) + color.blue.toString(CommonConstants.HEXADECIMAL)
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `createColorPicker fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  build() {
    Column() {
      Swiper(this.swiperController) {
        ForEach(this.imgData, (item: Resource) => {
          Image(item).borderRadius($r('app.integer.image_borderRadius'))
            .margin({ top: $r('app.integer.image_margin_top') })
        }, (item: Resource) => JSON.stringify(item))
      }
      .width(CommonConstants.FULL_PARENT)
      .padding({ left: $r('app.integer.swiper_padding_left'), right: $r('app.integer.swiper_padding_right') })
      .autoPlay(true)
      .interval(this.swiperInterval)
      .duration(this.swiperDuration)
      .loop(true)
      .itemSpace(this.swiperItemSpace)
      .indicator(false)
      .onAnimationStart(async (index, targetIndex) => {
        try {
          const context = this.context;
          const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
          const fileData: Uint8Array = await resourceMgr.getMediaContent(this.imgData[targetIndex].id);
          const buffer = fileData.buffer as ArrayBuffer;
          const imageSource: image.ImageSource = image.createImageSource(buffer);
          const pixelMap: image.PixelMap = await imageSource.createPixelMap();

          effectKit.createColorPicker(pixelMap, (err, colorPicker) => {
            let color = colorPicker.getMainColorSync();
            this.getUIContext().animateTo({
              duration: CommonConstants.ANIMATION_DURATION,
              curve: Curve.Linear,
              iterations: CommonConstants.ANIMATION_ITERATIONS
            }, () => {
              this.bgColor = "#" + color.alpha.toString(CommonConstants.HEXADECIMAL) +
              color.red.toString(CommonConstants.HEXADECIMAL) + color.green.toString(CommonConstants.HEXADECIMAL) +
              color.blue.toString(CommonConstants.HEXADECIMAL);
            })
          })
        } catch (e) {
          hilog.error(0x0000, 'TestTag', 'Failed error.code is %{public}d,error.message is %{public}s', e.code,
            e.message);
        }
      })
    }
    .width(CommonConstants.FULL_PARENT)
    .height(CommonConstants.FULL_PARENT)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[this.bgColor, CommonConstants.START_GRADIENT_RANGE], [Color.White, CommonConstants.END_GRADIENT_RANGE]]
    })
    .padding({ top: this.topSafeHeight })
  }
}
