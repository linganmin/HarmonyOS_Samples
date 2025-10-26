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

import { resourceManager } from '@kit.LocalizationKit';
import { fileIo, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import Logger from '../common/utils/Logger';
import { CommonConstants } from '../common/constants/CommonConstants';
import msliteNapi from 'libentry.so';
import { common } from '@kit.AbilityKit';


@Entry
@Component
struct Index {
  @State uris: Array<string> = [];
  @State max: number = 0;
  @State maxIndex: number = 0;
  @State maxArray: Array<number> = [];
  @State maxIndexArray: Array<number> = [];
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  processImage(): void {
    let resMgr: resourceManager.ResourceManager = this.context.getApplicationContext().resourceManager;
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoSelectOptions, async (
      err: BusinessError, photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      if (err) {
        Logger.error('MS_LITE_ERR: PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
        return;
      }
      Logger.info('MS_LITE_LOG: PhotoViewPicker.select successfully, ' +
        'photoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      this.uris = photoSelectResult.photoUris;
      Logger.info('MS_LITE_LOG: uri: ' + this.uris);
      try {
        let file = fileIo.openSync(this.uris[0], fileIo.OpenMode.READ_ONLY);
        Logger.info('MS_LITE_LOG: file fd: ' + file.fd);
        let inputBuffer = new ArrayBuffer(CommonConstants.ARRAY_BUFFER_SIZE);
        let readLen = fileIo.readSync(file.fd, inputBuffer);
        Logger.info('MS_LITE_LOG: readSync data to file succeed and inputBuffer size is:' + readLen);
        let imageSource = image.createImageSource(file.fd);
        let pixelMap = await imageSource.createPixelMap();
        let info = await pixelMap.getImageInfo();
        Logger.info('MS_LITE_LOG: info.width = ' + info.size.width);
        Logger.info('MS_LITE_LOG: info.height = ' + info.size.height);
        pixelMap.scale(CommonConstants.MAX_ZOOM_VALUE / info.size.width,
          CommonConstants.MAX_ZOOM_VALUE / info.size.height).then(() => {
          pixelMap.crop(
            {
              x: CommonConstants.X_COORDINATE,
              y: CommonConstants.Y_COORDINATE,
              size: { height: CommonConstants.MODEL_INPUT_HEIGHT, width: CommonConstants.MODEL_INPUT_WIDTH }
            }
          ).then(async () => {
            let info = await pixelMap.getImageInfo();
            Logger.info('MS_LITE_LOG: crop info.width = ' + info.size.width);
            Logger.info('MS_LITE_LOG: crop info.height = ' + info.size.height);
            let readBuffer =
              new ArrayBuffer(CommonConstants.MODEL_INPUT_HEIGHT * CommonConstants.MODEL_INPUT_WIDTH * 4);
            await pixelMap.readPixelsToBuffer(readBuffer);
            Logger.info('MS_LITE_LOG: Succeeded in reading image pixel data, buffer: ' +
            readBuffer.byteLength);
            const imageArr = new Uint8Array(
              readBuffer.slice(0, CommonConstants.MODEL_INPUT_HEIGHT * CommonConstants.MODEL_INPUT_WIDTH * 4));
            Logger.info('MS_LITE_LOG: imageArr length: ' + imageArr.length);
            let float32View =
              new Float32Array(CommonConstants.MODEL_INPUT_HEIGHT * CommonConstants.MODEL_INPUT_WIDTH * 3);
            let index = 0;
            for (let i = 0; i < imageArr.length; i++) {
              if ((i + 1) % 4 == 0) {
                float32View[index] = (imageArr[i - 3] / CommonConstants.RGB_MAX_VALUE - CommonConstants.MEANS[0]) /
                CommonConstants.STDS[0]; // B
                float32View[index+1] = (imageArr[i - 2] / CommonConstants.RGB_MAX_VALUE - CommonConstants.MEANS[1]) /
                CommonConstants.STDS[1]; // G
                float32View[index+2] = (imageArr[i - 1] / CommonConstants.RGB_MAX_VALUE - CommonConstants.MEANS[2]) /
                CommonConstants.STDS[2]; // R
                index += 3;
              }
            }
            Logger.info('MS_LITE_LOG: float32View length: ' + float32View.length);

            console.info('MS_LITE_LOG: *** Start MSLite Demo ***');
            let output: Array<number> = msliteNapi.runDemo(Array.from(float32View), resMgr);
            this.max = 0;
            this.maxIndex = 0;
            this.maxArray = [];
            this.maxIndexArray = [];
            let newArray = output.filter(value => value !== this.max);
            for (let n = 0; n < 4; n++) {
              this.max = output[0];
              this.maxIndex = 0;
              for (let m = 0; m < newArray.length; m++) {
                if (newArray[m] > this.max) {
                  this.max = newArray[m];
                  this.maxIndex = m;
                }
              }
              this.maxArray.push(Math.round(this.max * 10000));
              this.maxIndexArray.push(this.maxIndex);
              newArray = newArray.filter(value => value !== this.max);
            }
            Logger.info('MS_LITE_LOG: max:' + this.maxArray);
            Logger.info('MS_LITE_LOG: maxIndex:' + this.maxIndexArray);
            Logger.info('MS_LITE_LOG: *** Finished MSLite Demo ***');
          })
        })
        fileIo.closeSync(file);
      } catch (err) {
        Logger.error('MS_LITE_LOG: uri: open file fd failed.' + err);
      }
    })
  }

  build() {
    Column() {
      Text($r('app.string.EntryAbility_label'))
        .width(CommonConstants.FULL_PERCENT)
        .font({
          size: $r('app.float.All_title_font_size'),
          weight: CommonConstants.FONT_WEIGHT_700
        })
        .margin({
          top: $r('app.float.title_margin_top'),
          bottom: $r('app.float.title_margin_bottom')
        })
      Image(this.uris[0])
        .height($r('app.float.image_height'))
        .objectFit(ImageFit.Contain)
        .margin({
          bottom: $r('app.float.image_margin_bottom')
        })
      if (this.max) {
        List() {
          ForEach(this.maxIndexArray, (item: number, index: number) => {
            ListItem() {
              Row() {
                Text(CommonConstants.LABELS_NAME_MAP[item] + ': ')
                  .fontSize($r('app.float.common_font_size'))
                  .fontWeight(CommonConstants.FONT_WEIGHT_500)
                  .fontFamily($r('app.string.Font_family_black'))
                Text((this.maxArray[index] / 100).toString() + '%')
                  .fontSize($r('app.float.common_font_size'))
                  .fontWeight(CommonConstants.FONT_WEIGHT_500)
                  .fontFamily($r('app.string.Font_family_black'))
                  .textAlign(TextAlign.End)
              }
              .width(CommonConstants.FULL_PERCENT)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .height($r('app.float.list_item_height'))
          }, (item: number, index: number) => index + JSON.stringify(item))
        }
        .backgroundColor($r("app.color.list_background"))
        .borderRadius($r('sys.float.corner_radius_level8'))
        .divider({
          strokeWidth: $r('app.float.stroke_width'),
          color: $r('app.color.five_black')
        })
        .padding({
          left: $r('app.float.small_padding'),
          right: $r('app.float.small_padding')
        })
        .width($r('app.float.list_width'))
        .height($r('app.float.list_height'))
      }
      Blank();
      Button($r('app.string.Button_Title'))
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.button_height'))
        .margin({
          top: $r('app.float.button_margin_top')
        })
        .onClick(() => {
          this.processImage();
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .expandSafeArea([SafeAreaType.SYSTEM])
    .backgroundColor(0XF1F3F5)
    .padding({
      left: $r('app.float.title_margin_left'),
      right: $r('app.float.title_margin_left')
    })
  }
}
