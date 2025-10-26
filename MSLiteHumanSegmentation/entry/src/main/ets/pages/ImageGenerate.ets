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

import { image } from '@kit.ImageKit';
import { resourceManager } from '@kit.LocalizationKit';
import { fileIo } from '@kit.CoreFileKit';
import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@kit.ArkUI';
import {
  BLACKGROUND_THEADHOLD,
  ListDataConstants,
  MODEL_INPUT_HEIGHT,
  MODEL_INPUT_WIDTH,
  MODEL_NAME
} from '../common/constants/ImageDataListConstant';
import NavigationParam from '../model/NavigationParam';
import modelPredict from '../utils/Predict';
import Logger from '../utils/Logger';

@Observed
class BackgroundImageItem {
  src: ResourceStr = '';
  content: ResourceStr = '';
  selected: boolean = false;

  constructor(src: ResourceStr, content: ResourceStr, selected: boolean) {
    this.src = src;
    this.content = content;
    this.selected = selected;
  }
}

@Builder
export function ImageGeneratePageBuilder() {
  ImageGenerate()
}

@Component
export struct PreviewImage {
  @ObjectLink imgItem: BackgroundImageItem;

  build() {
    ListItem() {
      RelativeContainer() {
        Column() {
        }
        .height(34)
        .width('100%')
        .id('id_swiper_image_gradient')
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        })
        .margin({ top: 34 })
        .linearGradient({
          direction: GradientDirection.Bottom,
          repeating: false,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.45)', 1.0]]
        })
        .zIndex(1)
        .borderRadius({
          bottomLeft: 8,
          bottomRight: 8
        })

        Text(this.imgItem.content)
          .width(52)
          .height(16)
          .fontSize(12)
          .lineHeight(16)
          .id('id_swiper_image_type')
          .fontColor('#FFF')
          .alignRules({
            top: { anchor: 'id_swiper_image_gradient', align: VerticalAlign.Top },
            left: { anchor: 'id_swiper_image_gradient', align: HorizontalAlign.Start },
            right: { anchor: 'id_swiper_image_gradient', align: HorizontalAlign.End },
            bottom: { anchor: 'id_swiper_image_gradient', align: VerticalAlign.Bottom }
          })
          .margin({
            top: 10,
            left: 8,
            bottom: 8,
            right: 8
          })
          .zIndex(2)
      }.borderRadius(8)
    }
    .backgroundImage(this.imgItem.src)
    .backgroundImageSize(ImageSize.Cover)
    .width(68)
    .height(68)
    .border({
      width: this.imgItem.selected ? 1 : 0,
      radius: 8,
      color: this.imgItem.selected ? '#0A59F7' : Color.Transparent
    })
  }
}

@Component
export struct ImageGenerate {
  @State outMergePixMap: image.PixelMap | undefined = undefined;
  pathStack: NavPathStack = new NavPathStack();
  private modelName: string = MODEL_NAME;
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.segment_btn_text_first') },
      { text: $r('app.string.segment_btn_text_second') }] as ItemRestriction<SegmentButtonTextItem>,
    fontColor: 'rgba(0,0,0,0.9)',
    selectedFontColor: 'rgba(0,0,0,0.6)',
    fontSize: 14,
    selectedFontSize: 14,
    buttonPadding: {
      top: 10,
      bottom: 10,
      left: 16,
      right: 16
    },
    selectedFontWeight: FontWeight.Medium,
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK
  });
  @State currentTab: number = 0;
  @State canMergeImage: boolean = true;
  @State tabSelectedIndexes: number[] = [this.currentTab];
  @State currentPreviewImageIndex: number = 0;
  @State previewImageList: BackgroundImageItem[] = [
    new BackgroundImageItem($r('app.media.img_001'), $r('app.string.preview_img_list_001'), true),
    new BackgroundImageItem($r('app.media.img_002'), $r('app.string.preview_img_list_002'), false),
    new BackgroundImageItem($r('app.media.img_003'), $r('app.string.preview_img_list_003'), false),
    new BackgroundImageItem($r('app.media.img_004'), $r('app.string.preview_img_list_004'), false),
    new BackgroundImageItem($r('app.media.img_005'), $r('app.string.preview_img_list_005'), false),
    new BackgroundImageItem($r('app.media.img_006'), $r('app.string.preview_img_list_006'), false),
    new BackgroundImageItem($r('app.media.img_007'), $r('app.string.preview_img_list_007'), false),
    new BackgroundImageItem($r('app.media.img_008'), $r('app.string.preview_img_list_008'), false),
    new BackgroundImageItem($r('app.media.img_009'), $r('app.string.preview_img_list_009'), false)
  ];
  @State photoUri: string = '';
  handleSegmentButtonChange: Callback<number> = (index: number) => {
    this.currentTab = index;
    // combine image
    if (this.currentTab === 1 && this.canMergeImage) {
      this.handleMergeImage();
    }
  }
  handleMergeImage = async () => {
    let resMgr: resourceManager.ResourceManager =
      this.getUIContext().getHostContext()?.getApplicationContext().resourceManager as resourceManager.ResourceManager;
    if (!resMgr) {
      return;
    }
    this.canMergeImage = false;
    const modelBuffer = resMgr.getRawFileContentSync(this.modelName);
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
      pixelMap.scaleSync(MODEL_INPUT_WIDTH / info.size.width, MODEL_INPUT_HEIGHT / info.size.height);
      // The size of the pixel buffer that needs to be created.
      let readBuffer = new ArrayBuffer(MODEL_INPUT_HEIGHT * MODEL_INPUT_WIDTH * 4);
      await pixelMap.readPixelsToBuffer(readBuffer);
      Logger.info('MS_LITE_LOG: Succeeded in reading image pixel data, buffer: ' + readBuffer.byteLength);
      pixelMap.release();

      // Process the read buffer
      const imageArr = new Uint8Array(
        readBuffer.slice(0, MODEL_INPUT_HEIGHT * MODEL_INPUT_WIDTH * 4));
      Logger.info('MS_LITE_LOG: imageArr length: ' + imageArr.length);

      // Construct Input Tensor (Input Preprocessing);
      // === Attention! This step needs to be performed according to the image storage format of the model, as NCHW and NHWC are constructed differently! ===

      let float32View = new Float32Array(MODEL_INPUT_HEIGHT * MODEL_INPUT_WIDTH * 3);
      let means = [0.5, 0.5, 0.5];
      let stds = [1.0, 1.0, 1.0];
      let index = 0;
      for (let i = 0; i < imageArr.length; i++) {
        if ((i + 1) % 4 === 0) {
          float32View[index] = (imageArr[i - 3] / 255.0 - means[0]) / stds[0]; // R
          float32View[index + 1] = (imageArr[i - 2] / 255.0 - means[1]) / stds[1]; // B
          float32View[index + 2] = (imageArr[i - 1] / 255.0 - means[2]) / stds[2]; // G
          index += 3;
        }
      }

      let inputs: ArrayBuffer[] = [float32View.buffer];
      Logger.info('inputs length is ' + inputs.length);
      // predict
      modelPredict(modelBuffer.buffer.slice(0), inputs).then(async outputs => {
        Logger.info('==== MS_LITE_LOG: MS_LITE predict success ====');

        let output: Float32Array = new Float32Array(outputs[0].getData());

        let picArr = new Uint8Array(MODEL_INPUT_HEIGHT * MODEL_INPUT_WIDTH * 4);
        let isHumanArr = new Array<boolean>(MODEL_INPUT_HEIGHT * MODEL_INPUT_WIDTH);
        for (let i = 0; i < picArr.length; i++) {
          if ((i + 1) % 4 === 0) {
            let isHuman = output[(i + 1) / 4 - 1] >  BLACKGROUND_THEADHOLD;
            isHumanArr[(i + 1) / 4] = isHuman;
            if (isHuman) {
              picArr[i - 1] = imageArr[i - 3];
              picArr[i - 2] = imageArr[i - 2];
              picArr[i - 3] = imageArr[i - 1];
              picArr[i] = 255;
            } else {
              picArr[i - 1] = 0;
              picArr[i - 2] = 0;
              picArr[i - 3] = 0;
              picArr[i] = 0;
            }
          }
        }

        // Display the extracted character image
        let opts: image.InitializationOptions = {
          editable: true, pixelFormat: image.PixelMapFormat.RGBA_8888,
          size: { height: MODEL_INPUT_HEIGHT, width: MODEL_INPUT_WIDTH }
        };
        image.createPixelMap(picArr.buffer, opts).then(async (pixelmap) => {
          // Image cutout effect
          pixelmap.release();
        });

        // composite image
        try {
          // Synthesize the next image
          let img = this.currentPreviewImageIndex >= 3 ? ListDataConstants.IMG_LIST[this.currentPreviewImageIndex] :
            this.previewImageList[this.currentPreviewImageIndex].src as Resource;
          resMgr.getMediaContent(img.id).then(async (img) => {
            let imageSourceBg: image.ImageSource = image.createImageSource(img.buffer.slice(0));
            // Create pixelMap
            let pixelMapBg: image.PixelMap = imageSourceBg.createPixelMapSync();
            let infoBg = await pixelMapBg.getImageInfo();
            pixelMapBg.scaleSync(MODEL_INPUT_WIDTH / infoBg.size.width, MODEL_INPUT_HEIGHT / infoBg.size.height);
            let readBufferBg = new ArrayBuffer(MODEL_INPUT_HEIGHT * MODEL_INPUT_WIDTH * 4);
            pixelMapBg.readPixelsToBufferSync(readBufferBg);
            let bgArr = new Uint8Array(readBufferBg.slice(0, MODEL_INPUT_HEIGHT * MODEL_INPUT_WIDTH * 4));
            let resArr = new Uint8Array(MODEL_INPUT_HEIGHT * MODEL_INPUT_WIDTH * 4);
            for (let i = 0; i < resArr.length; ++i) {
              if ((i + 1) % 4 === 0) {
                if (isHumanArr[(i + 1) / 4 - 1]) {
                  resArr[i - 1] = picArr[i - 1];
                  resArr[i - 2] = picArr[i - 2];
                  resArr[i - 3] = picArr[i - 3];
                  resArr[i] = 255;
                } else {
                  resArr[i - 1] = bgArr[i - 3];
                  resArr[i - 2] = bgArr[i - 2];
                  resArr[i - 3] = bgArr[i - 1];
                  resArr[i] = 255;
                }
              }
            }
            let opts: image.InitializationOptions = {
              editable: true, pixelFormat: image.PixelMapFormat.RGBA_8888,
              size: { height: MODEL_INPUT_HEIGHT, width: MODEL_INPUT_WIDTH }
            };
            // Gaussian filtering: This step is not mandatory
            // gaussianRun(resArr)
            image.createPixelMap(resArr.buffer, opts)
              .then(outMergeImage => {
                this.outMergePixMap = outMergeImage;
                this.canMergeImage = true;
              })
            pixelMapBg.release();
            imageSourceBg.release();
          })
        } catch (error) {
          Logger.error('Failed to get media content', JSON.stringify(error));
        }
      })
      // 5. close fileIo
      fileIo.closeSync(file);
      imageSource.release();
    } catch (err) {
      Logger.error('MS_LITE_LOG: uri: open file fd failed.' + err);
    }
  }

  aboutToDisappear(): void {
    if (this.outMergePixMap) {
      this.outMergePixMap.release();
    }
  }
  build() {
    NavDestination() {
      Column() {
        SegmentButton({
          options: this.tabOptions,
          selectedIndexes: $tabSelectedIndexes,
          onItemClicked: this.handleSegmentButtonChange
        })
          .margin({ bottom: 16 })
          .width(164).height(40)

        RelativeContainer() {
          // Original Image Placeholder
          Image(this.currentTab === 0 ? this.photoUri : this.outMergePixMap)
            .id('id_display_img')
            .alignRules({
              middle: { anchor: '__container__', align: HorizontalAlign.Center },
              center: { anchor: '__container__', align: VerticalAlign.Center }
            })
            .padding({
              top: 24,
              bottom: 24,
              left: 16,
              right: 16
            })
            .objectFit(ImageFit.Contain)
        }
        .width('100%')
        .height(480)
        .backgroundColor($r('app.color.image_display_are_background'))

        if (this.currentTab === 1) {
          Row() {
            List({ space: 4 }) {
              ForEach(this.previewImageList, (item: BackgroundImageItem, index: number) => {
                PreviewImage({ imgItem: item })
                  .onClick(() => {
                    if (!this.canMergeImage) {
                      this.getUIContext().getPromptAction().showToast({
                        message: $r('app.string.generate_tips'),
                        alignment: Alignment.Center,
                      })
                      return;
                    }

                    this.previewImageList[index].selected = true;
                    this.currentPreviewImageIndex = index;
                    this.handleMergeImage();
                    this.previewImageList.forEach((item, idx) => {
                      Logger.info(`PreviewImage => ${JSON.stringify(item)}, idx => ${idx}`);
                      if (idx !== index) {
                        this.previewImageList[idx].selected = false;
                      }
                    })
                  })
              }, (item: BackgroundImageItem) => JSON.stringify(item))
            }
            .margin({ left: 16, top: 12 })
            .height(68)
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .friction(0.8)
          }.width('100%')

          // List End
        }
      }.width('100%').height('100%').margin({ top: 8 })
    }
    .title({ builder: this.navigationTitle($r('app.string.image_page_navbar_title')), height: 56 })
    .backgroundColor($r('app.color.window_background'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      const ret = this.pathStack.getParamByIndex(0) as NavigationParam;
      this.photoUri = ret.photoUri;
    })
  }

  @Builder
  navigationTitle(content: ResourceStr) {
    Text(content)
      .fontColor('rgba(0,0,0,0.9)')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .lineHeight(27)
      .margin({ top: 14.5, left: 8, bottom: 14.5 })
  }
}