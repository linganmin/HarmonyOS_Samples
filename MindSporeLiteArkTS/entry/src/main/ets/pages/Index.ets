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

import modelPredict from '../model/Model';
import Logger from '../common/utils/Logger'
import { resourceManager } from '@kit.LocalizationKit'
import { fileIo } from '@kit.CoreFileKit'
import { CommonConstants } from '../common/constants/CommonConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

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
    resMgr.getRawFileContent(CommonConstants.MODEL_NAME).then(modelBuffer => {
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
              { x: CommonConstants.X_COORDINATE,
                y: CommonConstants.Y_COORDINATE, 
                size: { height: CommonConstants.MODEL_INPUT_HEIGHT, width: CommonConstants.MODEL_INPUT_WIDTH } }
            ).then(async () => {
              let info = await pixelMap.getImageInfo();
              Logger.info('MS_LITE_LOG: crop info.width = ' + info.size.width);
              Logger.info('MS_LITE_LOG: crop info.height = ' + info.size.height);
              let readBuffer = new ArrayBuffer(CommonConstants.MODEL_INPUT_HEIGHT * CommonConstants.MODEL_INPUT_WIDTH * 4);
              await pixelMap.readPixelsToBuffer(readBuffer);
              Logger.info('MS_LITE_LOG: Succeeded in reading image pixel data, buffer: ' +
              readBuffer.byteLength);
              const imageArr = new Uint8Array(
                readBuffer.slice(0, CommonConstants.MODEL_INPUT_HEIGHT * CommonConstants.MODEL_INPUT_WIDTH * 4));
              Logger.info('MS_LITE_LOG: imageArr length: ' + imageArr.length);
              let float32View = new Float32Array(CommonConstants.MODEL_INPUT_HEIGHT * CommonConstants.MODEL_INPUT_WIDTH * 3);
              let index = 0;
              for (let i = 0; i < imageArr.length; i++) {
                if ((i + 1) % 4 == 0) {
                  float32View[index] = (imageArr[i - 3] / CommonConstants.RGB_MAX_VALUE - CommonConstants.MEANS[0]) / CommonConstants.STDS[0]; // B
                  float32View[index+1] = (imageArr[i - 2] / CommonConstants.RGB_MAX_VALUE - CommonConstants.MEANS[1]) / CommonConstants.STDS[1]; // G
                  float32View[index+2] = (imageArr[i - 1] / CommonConstants.RGB_MAX_VALUE - CommonConstants.MEANS[2]) / CommonConstants.STDS[2]; // R
                  index += 3;
                }
              }
              Logger.info('MS_LITE_LOG: float32View length: ' + float32View.length);
              let printStr = 'float32View data:';
              for (let i = 0; i < 20; i++) {
                printStr += ' ' + float32View[i];
              }
              Logger.info('MS_LITE_LOG: float32View data: ' + printStr);
              let inputs: ArrayBuffer[] = [float32View.buffer];
              // predict
              modelPredict(modelBuffer.buffer.slice(0), inputs).then(outputs => {
                Logger.info('=========MS_LITE_LOG: MS_LITE predict success=====');
                for (let i = 0; i < outputs.length; i++) {
                  let out = new Float32Array(outputs[i].getData());
                  let printStr = outputs[i].name + ':';
                  for (let j = 0; j < out.length; j++) {
                    printStr += out[j].toString() + ',';
                  }
                  Logger.info('MS_LITE_LOG: ' + printStr);
                  this.max = 0;
                  this.maxIndex = 0;
                  this.maxArray = [];
                  this.maxIndexArray = [];
                  let newArray = out.filter(value => value !== this.max)
                  for (let n = 0; n < 4; n++) {
                    this.max = out[0];
                    this.maxIndex = 0;
                    for (let m = 0; m < newArray.length; m++) {
                      if (newArray[m] > this.max) {
                        this.max = newArray[m];
                        this.maxIndex = m;
                      }
                    }
                    let localMax: number = this.max;
                    let localMaxIndex: number = this.maxIndex;
                    this.maxArray.push(Math.round(localMax * CommonConstants.TEN_THOUSAND))
                    this.maxIndexArray.push(localMaxIndex)
                    newArray = newArray.filter(value => value !== this.max)
                  }
                  Logger.info('MS_LITE_LOG: max:' + this.maxArray);
                  Logger.info('MS_LITE_LOG: maxIndex:' + this.maxIndexArray);
                }
                Logger.info('=========MS_LITE_LOG END=========');
              })
            })
          })
          fileIo.closeSync(file)
        } catch (err) {
          Logger.error('MS_LITE_LOG: uri: open file fd failed.' + err)
        }
      })
    })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'Index', `getRawFileContent failed. code=${err.code}, message=${err.message}`);
      })    
  }

  build() {
    Column(){
      Text($r('app.string.EntryAbility_label'))
        .width(CommonConstants.FULL_PERCENT)
        .font({
          size: $r('app.float.All_title_font_size'),
          weight: CommonConstants.FONT_WEIGHT_700
        })
        .margin({
          top: $r('app.float.title_margin_top'),
          left: $r('app.float.title_margin_left'),
          bottom: $r('app.float.title_margin_bottom')
        })
      Image(this.uris[0])
        .height($r('app.float.image_height'))
        .objectFit(ImageFit.Contain)
        .borderRadius($r('sys.float.corner_radius_level10'))
        .margin({
          bottom: $r('app.float.image_margin_bottom')
        })
      if(this.max){
        List(){
          ForEach(this.maxIndexArray, (item: number, index: number) => {
            ListItem(){
              Row(){
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
      } else {
        Blank()
          .width($r('app.float.blank_width'))
          .height($r('app.float.blank_height'))
      }
      Button($r('app.string.Button_Title'))
        .width($r('app.float.button_width'))
        .height($r('app.float.button_height'))
        .margin({
          top: $r('app.float.button_margin_top')
        })
        .onClick(() =>{
          this.processImage()
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}