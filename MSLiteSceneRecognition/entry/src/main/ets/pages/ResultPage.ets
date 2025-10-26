/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { fileIo } from "@kit.CoreFileKit";
import { image } from "@kit.ImageKit";
import { resourceManager } from "@kit.LocalizationKit";
import lib from 'libentry.so';
import { HashMap } from "@kit.ArkTS";
import NavigationParam from "../model/NavigationParam";
import { Places } from "../constants/Constants";
import Logger from '../utils/Logger';

@Builder
export function ResultPageBuilder() {
  ResultPage()
}

@Component
export struct ResultPage {
  pathStack: NavPathStack = new NavPathStack();
  @State photoUri: string = '';
  @State modelName: string = 'resnet18-place365';
  @State modelInputHeight: number = 224;
  @State modelInputWidth: number = 224;
  @State uris: Array<string> = [];
  @State probabilityPlace5: Array<number> = [];
  @State probablyPlace5: Array<string> = [];

  aboutToAppear(): void {
    Logger.info("ResultPage");
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text($r("app.string.result_header_title"))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('rgba(0,0,0,0.9)')
            .lineHeight(24)
            .textAlign(TextAlign.Start)
            .margin({ top: 24, bottom: 8 })

          Text($r("app.string.result_select_photo_text"))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgb(10, 89, 247)')
            .lineHeight(18)
            .textAlign(TextAlign.End)
            .margin({ top: 28, bottom: 8 })
            .onClick(() => {
              // 1. Create Image-Video Type File Selection Option Instance
              let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();

              // 2. Filter and select media file type as IMAGE
              photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
              photoSelectOptions.maxSelectNumber = 1; // Maximum number of media files to select

              // 3. Create an instance of the gallery selector and call the select() interface to launch the gallery interface for file selection. upon successful file selection. return the photoSelectResult result ret.
              let photoPicker = new photoAccessHelper.PhotoViewPicker();
              photoPicker.select(photoSelectOptions,
                async (err: BusinessError, photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
                  if (err) {
                    Logger.error('MS_LITE_ERR, photoViewPicker.select failed with err:' + JSON.stringify(err));
                    return;
                  }
                  this.photoUri = photoSelectResult.photoUris[0];
                  this.handlePredict();
                });
            })
        }.height(56).width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16 })

        RelativeContainer() {
          // Original image placeholder
          Image(this.photoUri)
            .id("id_display_img")
            .alignRules({
              middle: { anchor: "__container__", align: HorizontalAlign.Center },
              center: { anchor: "__container__", align: VerticalAlign.Center }
            })
            .objectFit(ImageFit.Contain)
        }.width("100%")
        .height(232)
        .padding({
          top: 24,
          bottom: 24,
          left: 16,
          right: 16
        })
        .backgroundColor($r("app.color.image_display_area_background"))

        Text($r("app.string.display_result"))
          .fontSize(14)
          .lineHeight(19)
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(0,0,0,0.6)')
          .width("100%")
          .textAlign(TextAlign.Start)
          .padding({ left: 20 })
          .margin({ top: 29, bottom: 8 })

        // Recognition results
        RelativeContainer() {
          List() {
            ForEach(this.probablyPlace5, (item: string, index: number) => {
              ListItem() {
                Row() {
                  Text(item + "：")
                    .fontSize(16)
                    .lineHeight(21)
                    .textAlign(TextAlign.Start)
                    .fontColor('rgba(0,0,0,0.9)')
                    .fontWeight(FontWeight.Medium)

                  Text((this.probabilityPlace5[index] * 100).toFixed(2) + "%")
                    .fontSize(14)
                    .fontWeight(FontWeight.Normal)
                    .lineHeight(19)
                    .textAlign(TextAlign.End)
                    .fontColor('rgba(0,0,0,0.6)')
                }.width("100%").justifyContent(FlexAlign.SpaceBetween).height(48)
              }
            }, (item: string) => item)
          }
          .height(248).width("100%")
          .scrollBar(BarState.Off)
          .enabled(false)
          .divider({ strokeWidth: 0.5, color: 'rgba(0,0,0,0.2)' })
          .padding({
            left: 12,
            right: 12,
            top: 4,
            bottom: 4
          })
          .id("id_result_card")
          .alignRules({
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .backgroundColor("#FFF")
          .borderRadius(16)

        }.width("100%").height("100%")
        .padding({ left: 16, right: 16 })
      }.width("100%").height("100%")
    }
    .title({ builder: this.navigationTitle($r("app.string.result_title")), height: 56 })
    .backgroundColor($r("app.color.window_background"))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      const ret = this.pathStack.getParamByIndex(0) as NavigationParam;
      this.photoUri = ret.photoUri;
      this.handlePredict();
    })
  }


  async handlePredict() {
    // Preprocess image data
    try {
      // 1. use the `fileIo.openSync` interface to open the file via URI and obtain the file descriptor (fd)
      let file = fileIo.openSync(this.photoUri, fileIo.OpenMode.READ_ONLY);
      Logger.info('MS_LITE_LOG: file.fd: ' + file.fd);

      // 2. Read the data within this file using the fileIo.readSync interface through fd
      let inputBuffer = new ArrayBuffer(4096000);
      let readLen = fileIo.readSync(file.fd, inputBuffer);
      Logger.info('MS_LITE_LOG: readSync data to file succeed and inputBuffer size is: ' + readLen);

      // 3. Preprocessing through PixelMap
      let imageSource = image.createImageSource(file.fd);
      let pixelMap = imageSource.createPixelMapSync();
      let info = pixelMap.getImageInfoSync();
      Logger.info(`MS_LITE_LOG: info.size is => ${JSON.stringify(info.size)}`);

      // 4. Obtain the image buffer data readBuffer and process it.
      pixelMap.scaleSync(256.0 / info.size.width, 256.0 / info.size.height);
      pixelMap.cropSync({ x: 16, y: 16, size: { height: this.modelInputHeight, width: this.modelInputWidth}});
      let cropInfo = pixelMap.getImageInfoSync();
      Logger.info(`MS_LITE_LOG: crop info.size: ` + JSON.stringify(cropInfo.size));

      // create buffer size
      let readBuffer = new ArrayBuffer(this.modelInputHeight * this.modelInputWidth * 4);
      pixelMap.readPixelsToBufferSync(readBuffer);
      Logger.info('MS_LITE_LOG: Succeeded in reading image pixel data, buffer: ' + readBuffer.byteLength);

      // handle readBuffer
      const imageArr = new Uint8Array(
        readBuffer.slice(0, this.modelInputHeight * this.modelInputWidth * 4));
      Logger.info('MS_LITE_LOG: imageArr length: ' + imageArr.length);

      let means = [0.485, 0.456, 0.406];
      let stds = [0.229, 0.224, 0.225];
      let float32View = new Float32Array(this.modelInputHeight * this.modelInputWidth * 3);
      let index = 0;
      for (let i = 0; i < imageArr.length; i++) {
        if ((i + 1) % 4 === 0) {
          float32View[index] = (imageArr[i - 3] / 255.0 - means[0]) / stds[0]; // B
          float32View[index + 1] = (imageArr[i - 2] / 255.0 - means[1]) / stds[1]; // G
          float32View[index + 2] = (imageArr[i - 1] / 255.0 - means[2]) / stds[2]; // R
          index += 3;
        }
      }

      let resMgr: resourceManager.ResourceManager = this.getUIContext().getHostContext()?.getApplicationContext().resourceManager as resourceManager.ResourceManager;
      // Input image and preprocess
      // call c++ predict method
      Logger.info("MS_LITE_LOG: *** Start MSLite Demo ***");
      let output: Array<number> = lib.predict(Array.from(float32View), resMgr);
      Logger.info(`=== MS_LITE_LOG, ${JSON.stringify(output)} ===`);
      for (let i = 0; i < output.length; i++) {
        Logger.info(`=== for while === ${output[i]}`);
        let out = new Float32Array(output);
        Logger.info('MS_LITE_LOG => ' + out);
        let placeIndexMap: HashMap<number, number> = new HashMap();
        for (let j = 0; j < out.length; ++j) {
          placeIndexMap.set(out[j], j);
        }

        out.sort((a: number, b: number) => b - a);
        let places5 = new Array<string>();
        let placesScore = new Array<number>();
        let sumScore = 0;
        for (let j = 0; j < 5; ++j) {
          places5.push(Places.NAME[placeIndexMap.get(out[j])]);
          sumScore += out[j];
        }
        for (let j = 0; j < 5; ++j) {
          placesScore.push(out[j] / sumScore);
        }
        this.probabilityPlace5 = placesScore;
        this.probablyPlace5 = places5;
      }
      imageSource.release();
    } catch (e) {
      Logger.error('MS_LITE_LOG: uri: open file fd failed.' + JSON.stringify(e));
    }
  }

  @Builder
  navigationTitle(content: ResourceStr) {
    Text(content)
      .fontColor("rgba(0,0,0,0.9)")
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .lineHeight(27)
      .margin({ top: 14.5, left: 8, bottom: 14.5 })
  }
}