/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileIo, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import MediaFileUri from '../media/MediaFileUri';
import Logger from '../common/Logger';
import { Constants } from '../common/Constants';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

const TAG = 'ViewMedia';

interface myParams extends Object {
  uris: string[]
};

@Entry
@Component
struct ViewMedia {
  @State myContext: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State myFileSizes: number[] = [];
  @State myFileNames: string[] = [];
  @State myFileTypes: number[] = [];
  @StorageLink('myFileName') myFileName: string = '';
  @StorageLink('myFileSize') myFileSize: number = 0;
  @State myUris: string[] = (this.getUIContext().getRouter().getParams() as myParams).uris;
  @State uri: string = 'Hello World';
  @StorageLink('showPauses') showPauses: Array<number> = [];
  mediaFileUri: MediaFileUri = new MediaFileUri();
  scroller: Scroller = new Scroller();
  currentUri: string = '';
  controllers: Array<VideoController> = [];

  onPageShow() {
    this.getImagesInfo();
    this.myFileName = this.myFileNames[0];
    this.myFileSize = this.myFileSizes[0];
    Logger.info(TAG, 'onPageShow getFilenameByUriForMedia this.myFileName ' + this.myFileName);
    Logger.info(TAG, 'onPageShow getFilenameByUriForMedia begin ' + this.myFileSize);
    AppStorage.setOrCreate('myFileName', this.myFileName);
    AppStorage.setOrCreate('myFileSize', this.myFileSize);
  }

  async getMediaNameByUri(myUri: string, index: number) {
    Logger.info(TAG, 'getMediaNameByUri getFilenameByUriForMedia begin');
    this.myFileName = (myUri.split('/').pop()) as string;
    this.myFileNames[index] = this.myFileName;
  }

  getImagesInfo() {
    for (let index = 0; index < this.myUris.length; index++) {
      Logger.info(TAG, 'getFilenameByUriForMedia  getImagesInfo  index: ' + index);
      this.controllers[index] = new VideoController();
      this.getMediaNameByUri(this.myUris[index], index);
      this.myFileSizes[index] = this.mediaFileUri.myGetFileSize(this.myUris[index], fileIo.OpenMode.READ_ONLY);
      Logger.info(TAG, 'getFilenameByUriForMedia  getVideosInfo  this.myFileNames[index]: '
        + this.myFileNames[index] + ' index ' + index);
      Logger.info(TAG, 'getFilenameByUriForMedia getVideosInfo this.myFileSizes[index]' + this.myFileSizes[index]);
      Logger.info(TAG, 'getFilenameByUriForMedia getVideosInfo this.myFileTypes[index] cc' + this.myFileTypes[index]);
    }
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ic_back'))
            .focusable(true)
            .focusOnTouch(true)
            .width($r('app.float.image_size'))
            .height($r('app.float.image_size'))
            .align(Alignment.Start)
            .id('back2Index')
            .onClick(() => {
              this.getUIContext().getRouter().back();
            })
        }
        .width(Constants.BACK_WIDTH)
        .padding({ left: Constants.BACK_PADDING_LEFT })

        // File name and information.
        Column() {
          Row() {
            Text(this.myFileName)
              .focusable(true)
              .focusOnTouch(true)
              .fontSize($r('app.float.text_font_size'))
              .fontFamily('HarmonyHeiTi-Bold')
              .fontColor($r('app.color.text_font_color'))
              .textAlign(TextAlign.Start)
              .fontWeight(Constants.TEXT_FONT_WIGHT)
              .lineHeight($r('app.float.text_height'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width(Constants.FULL_PERCENT)
          .align(Alignment.Start)
          .margin({
            top: Constants.MARGIN_TOP,
            bottom: Constants.MARGIN_ZERO_POINT_THREE_PERCENT
          })

          Row() {
            Text('size: ' + JSON.stringify(this.myFileSize) + 'B')
              .focusable(true)
              .focusOnTouch(true)
              .opacity(Constants.TEXT_OPACITY)
              .fontFamily('HarmonyHeiTi')
              .fontSize($r('app.float.text_font_size_14'))
              .fontColor($r('app.color.text_font_color'))
              .textAlign(TextAlign.Start)
              .lineHeight($r('app.float.text_height_19'))
              .fontWeight(Constants.TEXT_FONT_WIGHT_400)
          }
          .width(Constants.FULL_PERCENT)
          .margin({
            top: Constants.MARGIN_ZERO_POINT_THREE_PERCENT,
            bottom: Constants.MARGIN_ZERO_POINT_FIVE_PERCENT
          })
          .align(Alignment.Start)
        }
        .width(Constants.FORTY_FIVE_PERCENT)
        .margin({ left: Constants.MARGIN_LEFT })

        Row() {
          Image($r('app.media.ic_saveas'))
            .focusable(true)
            .focusOnTouch(true)
            .width($r('app.float.image_size'))
            .height($r('app.float.image_size'))
            .visibility(Visibility.Hidden)
        }
        .height(Constants.FULL_PERCENT)
        .width(Constants.THIRTY_SEVEN_POINT_TWO)
        .padding({ right: Constants.BACK_PADDING_LEFT })
        .justifyContent(FlexAlign.End)
      }
      .height(Constants.SEVEN_POINT_FOUR)
      .width(Constants.FULL_PERCENT)

      Scroll(this.scroller) {
        Column() {
          List({ space: Constants.LIST_SPACE_20, initialIndex: 0 }) {
            ForEach(this.myUris, (uri: string, index?: number) => {
              ListItem() {
                Column() {
                  Image(uri)
                    .borderRadius(Constants.BORDER_RADIUS)
                    .onClick(() => {
                      if (index !== undefined) {
                        this.myFileSize = this.myFileSizes[index];
                        this.myFileName = this.myFileNames[index];
                      }
                      AppStorage.setOrCreate('myFileName', this.myFileName);
                      AppStorage.setOrCreate('myFileSize', this.myFileSize);
                      Logger.info(TAG, 'Image onClick myFileName is ' + this.myFileName);
                      Logger.info(TAG, 'Image onClick myFileName is ' + this.myFileSize);
                    })
                  if (index !== undefined) {
                    Stack({ alignContent: Alignment.Center }) {
                      Video({
                        src: uri,
                        controller: this.controllers[index]
                      })
                        .autoPlay(false)
                        .controls(true)
                        .borderRadius(Constants.BORDER_RADIUS)

                      Image($r('app.media.ic_PAUSE'))
                        .width($r('app.float.image_size'))
                        .height($r('app.float.image_size'))
                        .onClick(() => {
                          this.controllers[index].start();
                          this.showPauses[index] = 0;
                        })
                    }
                    .onClick(() => {
                      this.myFileSize = this.myFileSizes[index];
                      this.myFileName = this.myFileNames[index];

                      AppStorage.setOrCreate('myFileName', this.myFileName);
                      AppStorage.setOrCreate('myFileSize', this.myFileSize);
                    })
                  }
                }
                .height(Constants.FULL_PERCENT)
              }
              .height(Constants.TWENTY_FIVE_PERCENT)
            }, (item: string) => item)
          }
          .id('picScroller')
          .scrollBar(BarState.Auto)
        }
      }
      .padding({
        top: Constants.ONE_POINT_FIVE_PERCENT,
        left: Constants.PADDING_LEFT_RIGHT,
        right: Constants.PADDING_LEFT_RIGHT
      })
    }
    .backgroundColor($r('app.color.common_background'))
    .height(Constants.FULL_PERCENT)
  }
}