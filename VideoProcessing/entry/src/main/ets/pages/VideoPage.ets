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
import { common } from '@kit.AbilityKit';
import { fileIo, picker } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import player from 'libplayer.so';
import { CommonConstants } from '../common/constant/CommonConstants';
import DateTimeUtil from '../common/utils/DateTimeUtil';
import Logger from '../common/utils/Logger';
import { MultiStatusButton } from '../view/MultiStatusButton';

const TAG: string = 'VideoPage';
const DATETIME: DateTimeUtil = new DateTimeUtil();

@Entry
@Component
struct VideoPage {
  @State selectFilePath: string = '';
  @State myFileNames: string[] = [];
  @State percent: number = 0;
  @State windowWidth: number = 300;
  @State windowHeight: number = 300;
  @State hdrMode: string = 'unknown';

  @State canConvertSDR: boolean = false;
  @State canConvertVividPQ: boolean = false;
  @State canConvertVividHLG: boolean = false;
  @State canConvertHLG: boolean = false;
  @State canGenerationMeta: boolean = false;

  @State targetType: string = '';

  @State colorSpaceIsShow: boolean = false;
  @State metaIsShow: boolean = false;
  @State scaleIsShow: boolean = false;

  @State viewState: number = 0;
  @State pixelMap: image.PixelMap | undefined = undefined;

  targetColorSpace: number = 0;
  targetMetaData: number = 0;

  zoomNoneStatus: number = 0;
  enhanceLowStatus: number = 0;
  enhanceMediumStatus: number = 0;
  enhanceHighStatus: number = 0;
  zoomLevel: number = 0;
  player1Playing: boolean = false;
  player2Playing: boolean = false;
  isVideoProcessing: boolean = false;

  aboutToDisappear(): void {
    Logger.info(TAG, 'aboutToDisappear' + this.selectFilePath);
    player.destroy();
  }

  async videoPicker(): Promise<void> {
    try {
      let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.maxSelectNumber = 1;
      let photoPicker = new picker.DocumentViewPicker();
      photoPicker.select(photoSelectOptions).then((photoSelectResult)=>{
        if (photoSelectResult !== null || photoSelectResult !== undefined) {
          Logger.info(TAG, `PhotoViewPicker select to file succeed and uri is: ${photoSelectResult[0]}`);
          if (photoSelectResult[0]) {
            this.selectFilePath = photoSelectResult[0];
            this.reset();
            this.preload();
          }
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `PhotoViewPicker select failed with err: ${err.message}`);
      });
    } catch (err) {
      Logger.error(TAG, `PhotoViewPicker failed with err: ${err.message}`);
    }
  }

  preload() {
    let inputFile = fileIo.openSync(this.selectFilePath, fileIo.OpenMode.READ_ONLY);
    let inputFileState = fileIo.statSync(inputFile.fd);
    let info: string = player.preload(inputFile.fd, inputFileState.size);
    fileIo.close(inputFile);
    Logger.info(TAG, `Video info: ${info}}`);
    let arr: string[] = info.split('@');
    let msg = arr[0] + ' ' + arr[1];
    this.hdrMode = info;
    if (msg.includes('HDRVivid HLG')) {
      this.canConvertVividPQ = true;
      this.canConvertSDR = true;
      this.canGenerationMeta = true;
    } else if (msg.includes('HDRVivid PQ')) {
      this.canConvertVividHLG = true;
      this.canConvertSDR = true;
      this.canGenerationMeta = true;
    } else if (msg.includes('HDR')) {
      this.canConvertHLG = true;
      this.canGenerationMeta = true;
    } else if (msg.includes('SDR')) {
      this.canConvertSDR = true;
      this.canGenerationMeta = false;
    }
    let pixel = arr[1].split('x');
    let width = Number(pixel[0]);
    let height = Number(pixel[1]);

    if (msg.includes('SDR') && (arr[2] === '0' || arr[2] === '2' || arr[2] === '3')) {
      if ((width >= 512 && width <= 2000) && (height >= 512 && height <= 2000)) {
        this.zoomNoneStatus = 1;
        this.enhanceLowStatus = 1;
        this.enhanceMediumStatus = 1;
        this.enhanceHighStatus = 1;
      } else if ((width > 32 && width <= 2000) && (height > 32 && height <= 2000)) {
        this.zoomNoneStatus = 1;
        this.enhanceLowStatus = 1;
        this.enhanceMediumStatus = 1;
        this.enhanceHighStatus = 1;
      } else {
        this.enhanceLowStatus = 0;
        this.enhanceMediumStatus = 0;
        this.enhanceHighStatus = 0;
      }
    }

    let timeUs: number = 0;
    let queryOption: media.AVImageQueryOptions = media.AVImageQueryOptions.AV_IMAGE_QUERY_PREVIOUS_SYNC;
    let param: media.PixelMapParams = {
      width: width,
      height: height
    };
    this.viewState = 1;
    media.createAVImageGenerator((err: BusinessError, generator: media.AVImageGenerator)=> {
      if (generator != null) {
        let inputFile = fileIo.openSync(this.selectFilePath, fileIo.OpenMode.READ_ONLY);
        let inputFileState = fileIo.statSync(inputFile.fd);
        generator.fdSrc = {fd: inputFile.fd, offset: 0, length: inputFileState.size};
        generator.fetchFrameByTime(timeUs, queryOption, param, (error: BusinessError, pixelMap)=> {
          if (error) {
            Logger.error(TAG, `Failed to fetch FrameByTime, err: ${error.message}}`);
          } else {
            this.pixelMap = pixelMap;
          }
          fileIo.close(inputFile);
          generator.release();
        })
      } else {
        Logger.error(TAG, `Failed to create AVImageGenerator, error: ${err.message}`);
      }
    });
  }

  play(): void {
    let inputFile1 = fileIo.openSync(this.selectFilePath, fileIo.OpenMode.READ_ONLY);
    let inputFileState1 = fileIo.statSync(inputFile1.fd);
    this.player1Playing = true;
    player.playNative(inputFile1.fd, 0, inputFileState1.size, 0, -1, this.targetColorSpace,
      this.targetMetaData, 0, 0, ()=> {
        this.viewState = 1;
        fileIo.close(inputFile1);
        this.player1Playing = false;
        this.isVideoProcessing = this.player1Playing || this.player2Playing;
      });
    let inputFile2 = fileIo.openSync(this.selectFilePath, fileIo.OpenMode.READ_ONLY);
    let inputFileState2 = fileIo.statSync(inputFile2.fd);
    this.player2Playing = true;
    player.playNative(inputFile2.fd, 0, inputFileState2.size, 1, -1, this.targetColorSpace,
      this.targetMetaData, 0, 0, ()=> {
          this.viewState = 1;
          fileIo.close(inputFile2);
          this.player2Playing = false;
          this.isVideoProcessing = this.player1Playing || this.player2Playing;
      });
    this.isVideoProcessing = true;
  }

  reset(): void {
    this.zoomNoneStatus = 0;
    this.enhanceLowStatus = 0;
    this.enhanceMediumStatus = 0;
    this.enhanceHighStatus = 0;

    this.canGenerationMeta = false;

    this.canConvertVividHLG = false;
    this.canConvertVividPQ = false;
    this.canConvertHLG = false;
    this.canConvertSDR = false;
    Logger.info(TAG, 'reset process status');
  }

  async  processVideo(option: number, isSave: boolean): Promise<void> {
    let inputFile1 = fileIo.openSync(this.selectFilePath, fileIo.OpenMode.READ_ONLY);
    let inputFileState1 = fileIo.statSync(inputFile1.fd);
    this.player1Playing = true;
    player.playNative(inputFile1.fd, 0, inputFileState1.size, 0, -1, this.targetColorSpace,
      this.targetMetaData, 0, 0, (ret: number)=> {
        fileIo.close(inputFile1);
        this.player1Playing = false;
        this.isVideoProcessing = this.player1Playing || this.player2Playing;
      });
    let inputFile2 = fileIo.openSync(this.selectFilePath, fileIo.OpenMode.READ_ONLY);
    let inputFileState2 = fileIo.statSync(inputFile2.fd);
    if (isSave) {
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      let helper = photoAccessHelper.getPhotoAccessHelper(context);
      let videoName = `AVCodecVideo_${DATETIME.getDate()}_${DATETIME.getTime()}`;
      Logger.info(TAG, `video save name is : ${videoName}`);
      if (!canIUse('SystemCapability.FileManagement.PhotoAccessHelper.Core')) {
        return;
      }
      helper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', {title: videoName})
        .then((uri)=> {
          Logger.info(TAG, `video save uri is: ${uri}`);
          let outputFile = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
          if (outputFile.fd !== null) {
            this.player2Playing = true;
            player.playNative(inputFile2.fd, 0, inputFileState2.size, 1, outputFile.fd, this.targetColorSpace,
              this.targetMetaData, this.zoomLevel, option, (ret: number)=> {
                fileIo.close(inputFile2);
                fileIo.close(outputFile);
                if (ret && ret === 5) {
                  this.getUIContext().getPromptAction().showToast({ message: $r('app.string.video_processing_not_support') });
                }
                this.player2Playing = false;
                this.isVideoProcessing = this.player1Playing || this.player2Playing;
              });
          }
        });
    } else {
      this.player2Playing = true;
      player.playNative(inputFile2.fd, 0, inputFileState2.size, 1, -1, this.targetColorSpace,
        this.targetMetaData, this.zoomLevel, option, (ret: number)=> {
          fileIo.close(inputFile2);
          if (ret && ret === 5) {
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.video_processing_not_support') });
          }
          this.player2Playing = false;
          this.isVideoProcessing = this.player1Playing || this.player2Playing;
        });
    }
    this.isVideoProcessing = true;
  }

  @Builder
  ScaleEnhancerMenu() {
    Column() {
      MultiStatusButton({text: 'NONE', status: this.zoomNoneStatus})
        .onClick(()=> {
          if (this.zoomNoneStatus === 0) {
            return;
          }
          this.scaleIsShow = false;
          this.viewState = 2;
          this.zoomLevel = 0;
          this.processVideo(1, false);
        })
      MultiStatusButton({text: 'LOW', status: this.enhanceLowStatus})
        .onClick(()=> {
          if (this.enhanceLowStatus === 0) {
            return;
          }
          this.scaleIsShow = false;
          this.viewState = 2;
          this.zoomLevel = 1;
          this.processVideo(1, false);
        })
      MultiStatusButton({text: 'MEDIUM', status: this.enhanceMediumStatus})
        .onClick(()=> {
          if (this.enhanceMediumStatus === 0) {
            return;
          }
          this.scaleIsShow = false;
          this.viewState = 2;
          this.zoomLevel = 2;
          this.processVideo(1, false);
        })
      MultiStatusButton({text: 'HIGH', status: this.enhanceHighStatus})
        .onClick(()=> {
          if (this.enhanceHighStatus === 0) {
            return;
          }
          this.scaleIsShow = false;
          this.viewState = 2;
          this.zoomLevel = 3;
          this.processVideo(1, false);
        })
        .margin({bottom: $r('app.float.color_space_item_margin_bottom')})
    }
    .margin({left: $r('app.float.color_space_item_padding_left'),
      right: $r('app.float.color_space_item_padding_left')})
  }

  @Builder
  MetaDataMenu() {
    Column() {
      MultiStatusButton({text: 'HDR Vivid', status: this.canGenerationMeta ? 1 : 0})
        .onClick(()=> {
          if (!this.canGenerationMeta) {
            return;
          }
          this.metaIsShow = false;
          this.viewState = 2;
          this.targetType = 'HDR Vivid';
          if (this.canConvertHLG || this.canConvertVividHLG) {
            this.targetColorSpace = 9;//OH_COLORSPACE_BT2020_HLG_LIMIT
          } else {
            this.targetColorSpace = 10;//OH_COLORSPACE_BT2020_PQ_LIMIT
          }
          this.targetMetaData = 2;//OH_VIDEO_HDR_VIVID
          this.processVideo(2, false);
        })
        .margin({bottom: $r('app.float.color_space_item_margin_bottom')})
    }
    .margin({left: $r('app.float.color_space_item_padding_left'),
      right: $r('app.float.color_space_item_padding_left')})
  }

  @Builder
  ColorSpaceMenu() {
    Column() {
      Text($r('app.string.color_space_sdr'))
        .fontColor($r('app.color.color_space_sdr_hint_font_color'))
        .width(CommonConstants.FULL_PERCENT)
        .padding({left: $r('app.float.color_space_item_padding_left')})
      MultiStatusButton({text: 'BT709', status: this.canConvertSDR ? 1 : 0})
        .onClick(()=> {
          if (!this.canConvertSDR) {
            return;
          }
          this.colorSpaceIsShow = false;
          this.viewState = 2;
          this.targetType = 'SDR BT709';
          this.targetColorSpace = 8;//OH_COLORSPACE_BT709_LIMIT
          this.targetMetaData = -1;//OH_VIDEO_NONE
          this.processVideo(3, false);
        })
      Text($r('app.string.color_space_hdr'))
        .fontColor($r('app.color.color_space_sdr_hint_font_color'))
        .width(CommonConstants.FULL_PERCENT)
        .padding({left: $r('app.float.color_space_item_padding_left')})
        .margin({top: $r('app.float.color_space_hdr_hint_margin_top')})
      MultiStatusButton({text: 'HLG', status: this.canConvertHLG ? 1 : 0})
        .onClick(()=> {
          if (!this.canConvertHLG) {
            return;
          }
          this.colorSpaceIsShow = false;
          this.viewState = 2;
          this.targetType = 'HDR HLG';
          this.targetColorSpace = 9;//OH_COLORSPACE_BT2020_HLG_LIMIT
          this.targetMetaData = 0;//OH_VIDEO_HDR_HLG
          this.processVideo(3, false);
        })
      MultiStatusButton({text: 'Vivid-HLG', status: this.canConvertVividHLG ? 1 : 0})
        .onClick(()=> {
          if (!this.canConvertVividHLG) {
            return;
          }
          this.colorSpaceIsShow = false;
          this.viewState = 2;
          this.targetType = 'HDR Vivid-HLG';
          this.targetColorSpace = 9;//OH_COLORSPACE_BT2020_HLG_LIMIT
          this.targetMetaData = 2;//OH_VIDEO_HDR_VIVID
          this.processVideo(3, false);
        })
      MultiStatusButton({text: 'Vivid-PQ', status: this.canConvertVividPQ ? 1 : 0})
        .onClick(()=> {
          if (!this.canConvertVividPQ) {
            return;
          }
          this.colorSpaceIsShow = false;
          this.viewState = 2;
          this.targetType = 'HDR Vivid-PQ';
          this.targetColorSpace = 10;//OH_COLORSPACE_BT2020_PQ_LIMIT
          this.targetMetaData = 2;//OH_VIDEO_HDR_VIVID
          this.processVideo(3, false);
        })
        .margin({bottom: $r('app.float.color_space_item_margin_bottom')})
    }
    .margin({left: $r('app.float.color_space_item_padding_left'),
      right: $r('app.float.color_space_item_padding_left')})
  }

  build() {
    RelativeContainer() {
      Text($r('app.string.video_processing_title'))
        .height($r('app.float.videoProcessing_title_height'))
        .fontSize($r('app.float.video_processing_title_size'))
        .fontWeight(CommonConstants.FONT_WEIGHT_700)
        .margin({left: $r('app.float.title_margin_left')})
        .id('title')
      Column() {
        Row() {
          Text($r('app.string.video_processing_after'))
            .fontWeight(CommonConstants.FONT_WEIGHT_700)
            .margin({left: $r('app.float.title_margin_left')})
            .fontSize($r('app.float.processing_title_size'))
        }
        .margin({
          top: $r('app.float.processing_title_margin_top'),
          bottom: $r('app.float.processing_title_margin_bottom')
        })
        .width(CommonConstants.FULL_PERCENT)
        Stack({alignContent: Alignment.BottomStart}) {
          Text($r('app.string.video_processing_after_area'))
            .fontSize($r('app.float.video_processing_after_area_hint_font_size'))
            .fontColor($r('app.color.video_processing_after_area_hint_font_color'))
            .textAlign(TextAlign.Center)
            .backgroundColor($r('app.color.video_processing_after_area_bg_color'))
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .visibility(this.viewState === 0 ? Visibility.Visible : Visibility.Hidden)

          Image(this.pixelMap)
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .visibility(this.viewState === 1 ? Visibility.Visible : Visibility.Hidden)

          XComponent({id: 'dstPlayer', type: XComponentType.SURFACE, libraryname: 'player'})
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .visibility(this.viewState === 2 ? Visibility.Visible : Visibility.Hidden)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.video_surface_height'))
        Row() {
          Text($r('app.string.video_processing_before'))
            .fontWeight(CommonConstants.FONT_WEIGHT_700)
            .fontSize($r('app.float.processing_title_size'))
            .margin({left: $r('app.float.title_margin_left')})
          Text($r('app.string.video_processing_select_file'))
            .fontColor($r('app.color.button_select_file_color'))
            .fontSize($r('app.float.video_select_button_font_size'))
            .margin({right: $r('app.float.title_margin_right')})
            .onClick(()=> {
              if (this.isVideoProcessing) {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.video_is_processing_try_later') });
                return;
              }
              this.videoPicker();
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          top: $r('app.float.processing_before_title_margin_top'),
          bottom: $r('app.float.processing_title_margin_bottom')
        })
        .justifyContent(FlexAlign.SpaceBetween)
        Stack({alignContent: Alignment.BottomStart}) {
          Text($r('app.string.video_processing_before_are'))
            .fontSize($r('app.float.video_processing_after_area_hint_font_size'))
            .fontColor($r('app.color.video_processing_after_area_hint_font_color'))
            .textAlign(TextAlign.Center)
            .backgroundColor($r('app.color.video_processing_after_area_bg_color'))
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .visibility(this.viewState === 0 ? Visibility.Visible : Visibility.Hidden)
          Image(this.pixelMap)
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .visibility(this.viewState === 1 ? Visibility.Visible : Visibility.Hidden)
          XComponent({id: 'srcPlayer', type: XComponentType.SURFACE, libraryname: 'player'})
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .visibility(this.viewState === 2 ? Visibility.Visible : Visibility.Hidden)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.video_surface_height'))
        Row() {
          Button($r('app.string.video_processing_meta_generate'))
            .layoutWeight(1)
            .backgroundColor($r('app.color.button_bg_color'))
            .fontColor($r('app.color.button_text_color'))
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .margin({right: $r('app.float.meta_button_margin')})
            .bindSheet($$this.metaIsShow, this.MetaDataMenu(), {
              detents: [SheetSize.FIT_CONTENT],
              backgroundColor: Color.White,
              blurStyle: BlurStyle.NONE,
              showClose: true,
              title: {title: $r('app.string.meta_list')}
            })
            .onClick(()=> {
              if (this.isVideoProcessing) {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.video_is_processing_try_later') });
                return;
              }
              this.metaIsShow = true;
            })
          Button($r('app.string.video_processing_scale'))
            .layoutWeight(1)
            .backgroundColor($r('app.color.button_bg_color'))
            .fontColor($r('app.color.button_text_color'))
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .margin({right: $r('app.float.scale_button_margin')})
            .bindSheet($$this.scaleIsShow, this.ScaleEnhancerMenu(), {
              detents: [SheetSize.FIT_CONTENT],
              backgroundColor: Color.White,
              blurStyle: BlurStyle.NONE,
              showClose: true,
              title: {title: $r('app.string.scale_enhance_list')}
            })
            .onClick(()=> {
              if (this.isVideoProcessing) {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.video_is_processing_try_later') });
                return;
              }
              this.scaleIsShow = true;
            })
        }
        .justifyContent(FlexAlign.Center)
        .margin({
          left: $r('app.float.scale_meta_area_margin_left'),
          top: $r('app.float.scale_meta_area_margin_top'),
          right: $r('app.float.scale_meta_area_margin_right')
        })

        Button($r('app.string.video_processing_color_space'))
          .width(CommonConstants.FULL_PERCENT)
          .constraintSize({maxWidth: CommonConstants.FULL_PERCENT})
          .margin({
            left: $r('app.float.title_margin_left'),
            top: $r('app.float.color_space_button_margin_top'),
            right: $r('app.float.title_margin_right')
          })
          .fontWeight(CommonConstants.FONT_WEIGHT_500)
          .backgroundColor($r('app.color.button_bg_color'))
          .fontColor($r('app.color.button_text_color'))
          .bindSheet($$this.colorSpaceIsShow, this.ColorSpaceMenu(), {
            detents: [SheetSize.FIT_CONTENT],
            backgroundColor: Color.White,
            blurStyle: BlurStyle.NONE,
            showClose: true,
            title: {title: $r('app.string.color_space_list')}
          })
          .onClick(()=>{
            if (this.isVideoProcessing) {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.video_is_processing_try_later') });
              return;
            }
            this.colorSpaceIsShow = true;
          })
        Button($r('app.string.video_processing_play'))
          .width(CommonConstants.FULL_PERCENT)
          .constraintSize({ maxWidth: CommonConstants.FULL_PERCENT})
          .margin({
            left: $r('app.float.title_margin_left'),
            top: $r('app.float.color_space_button_margin_top'),
            right: $r('app.float.title_margin_right')
          })
          .fontWeight(CommonConstants.FONT_WEIGHT_500)
          .backgroundColor($r('app.color.button_bg_color'))
          .fontColor($r('app.color.button_text_color'))
          .onClick(()=>{
            if (this.isVideoProcessing) {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.video_is_processing_try_later') });
              return;
            }
            if(this.selectFilePath) {
              this.viewState = 2;
              this.play();
            }
          })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .alignRules({
        top: { anchor: 'title', align: VerticalAlign.Bottom}
      })
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
  }
}