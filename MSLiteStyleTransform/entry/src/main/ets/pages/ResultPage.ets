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
import NavigationParam from '../model/NavigationParam';
import modelPredict from '../utils/Predict';
import Logger from '../utils/Logger';

@Builder
export function ResultPageBuilder() {
  ResultPage()
}

@Observed
class BackgroundImageItem {
  src: ResourceStr = '';
  content: ResourceStr = '';
  modelName: string = '';
  selected: boolean = false;
  constructor(src: ResourceStr, content: ResourceStr, modelName: string, selected: boolean) {
    this.src = src;
    this.content = content;
    this.modelName = modelName;
    this.selected = selected;
  }
}

@Component
export struct PreviewImage {
  @ObjectLink imgItem: BackgroundImageItem;

  build() {
    ListItem() {
      RelativeContainer() {
        Column() {}.height(34).width('100%')
        .id('id_swiper_image_gradient')
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        }).margin({ top: 34 })
        .linearGradient({
          direction: GradientDirection.Bottom,
          repeating: false,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.45)', 1.0]]
        }).zIndex(1)
        .borderRadius({
          bottomLeft: 8,
          bottomRight: 8
        })

        Text(this.imgItem.content).width(52).height(16).fontSize(12).lineHeight(16).fontWeight(FontWeight.Normal).textAlign(TextAlign.Start)
          .id('id_swiper_text')
          .fontColor('#FFF')
          .alignRules({
            top: { anchor: 'id_swiper_image_gradient', align: VerticalAlign.Top },
            left: { anchor: 'id_swiper_image_gradient', align: HorizontalAlign.Start },
            right: { anchor: 'id_swiper_image_gradient', align: HorizontalAlign.End },
            bottom: { anchor: 'id_swiper_image_gradient', align: VerticalAlign.Bottom }
          }).margin({ top: 10, left: 8, bottom: 8, right: 8}).zIndex(2)
      }.borderRadius(8).width('100%').height('100%')
    }
    .backgroundImage(this.imgItem.src).backgroundImageSize(ImageSize.Cover).width(68).height(68)
    .border({
      width: this.imgItem.selected ? 2 : 0,
      radius: 8,
      color: this.imgItem.selected ? '#0A59F7' : Color.Transparent
    })
  }
}

@Component
export struct ResultPage {
  @State modelInputHeight: number = 224;
  @State modelInputWidth: number = 224;
  @State outMergePixMap: image.PixelMap | undefined = undefined;
  pathStack: NavPathStack = new NavPathStack();
  private modelName: string = 'candy-9.ms';
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.segment_btn_text_first')}, { text: $r('app.string.segment_btn_text_second')}] as ItemRestriction<SegmentButtonTextItem>,
    fontColor: 'rgba(0,0,0,0.9)',
    selectedFontColor: 'rgba(0,0,0,0.6)',
    fontSize: 14,
    selectedFontSize: 14,
    buttonPadding: { top: 10, bottom: 10, left: 16, right: 16},
    selectedFontWeight: FontWeight.Medium,
    fontWeight: FontWeight.Medium,
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK
  });
  @State currentTab: number = 0;
  @State tabSelectedIndexes: number[] = [this.currentTab];
  @State currentPreviewImageIndex: number = 0;
  @State previewImageList: BackgroundImageItem[] = [
    new BackgroundImageItem($r('app.media.img_001'), $r('app.string.preview_img_list_001'), 'candy-9.ms', true),
    new BackgroundImageItem($r('app.media.img_002'), $r('app.string.preview_img_list_002'), 'mosaic-9.ms', false),
    new BackgroundImageItem($r('app.media.img_003'), $r('app.string.preview_img_list_003'), 'pointilism-9.ms', false),
    new BackgroundImageItem($r('app.media.img_004'), $r('app.string.preview_img_list_004'), 'rain-princess-9.ms', false),
  ];
  @State photoUri: string = '';
  handleSegmentButtonChange: Callback<number> = (index: number) => {
    this.currentTab = index;
    // combine image
    if (this.currentTab === 1) {
      this.handleMergeImage();
    }
  }

  handleMergeImage = async () => {
    let resMgr: resourceManager.ResourceManager = this.getUIContext().getHostContext()?.getApplicationContext().resourceManager as resourceManager.ResourceManager;
    if (!resMgr) {
      return
    }
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
      pixelMap.scaleSync(256.0 / info.size.width, 256.0 / info.size.height);
      pixelMap.cropSync({ x: 16, y: 16, size: { height: this.modelInputHeight, width: this.modelInputWidth}});
      // The size of the pixel buffer that needs to be created.
      let readBuffer = new ArrayBuffer(this.modelInputHeight * this.modelInputWidth * 4);
      await pixelMap.readPixelsToBuffer(readBuffer);
      Logger.info('MS_LITE_LOG: Succeeded in reading image pixel data, buffer: ' + readBuffer.byteLength);

      // Process the read buffer
      const imageArr = new Uint8Array(
        readBuffer.slice(0, this.modelInputHeight * this.modelInputWidth * 4));
      Logger.info('MS_LITE_LOG: imageArr length: ' + imageArr.length);

      // Construct Input Tensor (Input Preprocessing);
      // === Attention! This step needs to be performed according to the image storage format of the model, as NCHW and NHWC are constructed differently! ===

      let float32View = new Float32Array(this.modelInputHeight * this.modelInputWidth * 3);
      let index = 0;
      for (let i = 0; i < imageArr.length; i++) {
        if ((i + 1) % 4 == 0) {
          float32View[index + 1] = imageArr[i - 3];
          float32View[index + 2] = imageArr[i - 2];
          float32View[index + 3] = imageArr[i - 1];
          index+=3;
        }
      }

      let inputs: ArrayBuffer[] = [float32View.buffer];
      Logger.info('inputs length is ' + inputs.length);
      // predict
      modelPredict(modelBuffer.buffer.slice(0), inputs).then(outputs => {
        Logger.info('==== MS_LITE_LOG: MS_LITE predict success ====');

        let outArray = new Uint8Array(this.modelInputHeight * this.modelInputWidth * 4);
        for(let i = 0; i < outputs.length; i++) {
          let out = new Float32Array(outputs[i].getData());
          Logger.info('out size is ' + out.length);
          index = 0;
          for (let j = 0; j < outArray.length; ++j) {
            outArray[j] = 255;
            if ((j + 1) % 4 == 0) {
              outArray[j-3] = Math.floor((out[index + this.modelInputHeight * this.modelInputWidth * 2] ));
              outArray[j-2] = Math.floor((out[index + this.modelInputHeight * this.modelInputWidth ]));
              outArray[j-1] = Math.floor((out[index]));
              index++;
            }
          }
        }

        // Display the extracted character image
        let opts: image.InitializationOptions = { editable: true, pixelFormat: image.PixelMapFormat.RGBA_8888,
          size: { height: this.modelInputHeight, width: this.modelInputWidth }};

        const pixelmap = image.createPixelMapSync(outArray.buffer, opts);
        pixelmap.scaleSync( info.size.width / this.modelInputWidth, info.size.height / this.modelInputHeight);
        this.outMergePixMap = pixelmap;
          // Image cutout effect
        Logger.info('==== MS_LITE_LOG END ====');
      })
      // 5. close fileIo
      fileIo.closeSync(file);
      imageSource.release();
    } catch (err) {
      Logger.error('MS_LITE_LOG: uri: open file fd failed.' + err);
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
            .padding({ top: 24, bottom: 24, left: 16, right: 16 })
            .objectFit(ImageFit.Contain)
        }
        .width('100%')
        .height(480)
        .backgroundColor($r('app.color.image_display_are_background'))

        if (this.currentTab === 1) {
          Row() {
            List({ space: 4}) {
              ForEach(this.previewImageList, (item: BackgroundImageItem, index: number) => {
                PreviewImage({ imgItem: item})
                  .onClick(async () => {
                    this.previewImageList[index].selected = true;
                    this.currentPreviewImageIndex = index;
                    this.modelName = item.modelName;
                    await this.handleMergeImage();
                    this.previewImageList.forEach((item, idx) => {
                      if (idx !== index) {
                        this.previewImageList[idx].selected = false;
                      }
                    })
                  })
              }, (item: BackgroundImageItem) => JSON.stringify(item))
            }
            .margin({ left: 16, top: 12}).height(68).listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).friction(0.8)
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