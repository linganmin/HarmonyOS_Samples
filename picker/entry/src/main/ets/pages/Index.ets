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
import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import Logger from '../common/Logger';
import MediaFileUri from '../media/MediaFileUri';
import { Constants } from '../common/Constants';

const MAX_SELECT_NUM = 3; // Select the maximum number of media files.
const TAG = 'pickerIndex';

@Entry
@Component
struct Index {
  @State uri: string = 'Hello World';
  @State filename: string = '';
  @State sizeFile: number = 0;
  @State log: string = '';
  @State imageFlagCur: number = 0;
  @StorageLink('fileSizeList') fileSizeList: Array<number> = [];
  @StorageLink('fileNameList') fileNameList: Array<string> = [];
  @StorageLink('fileUriList') fileUriList: Array<string> = [];
  @StorageLink('imageNames') imageNames: Array<string> = [];
  mediaFileUri: MediaFileUri = new MediaFileUri();
  scroller: Scroller = new Scroller();
  authorizeBundleName: string = 'com.open.file.uri.demo';

  // Pull up the picker to select files.
  async callFilePickerSelectFile(): Promise<void> {
    try {
      let DocumentSelectOptions = new picker.DocumentSelectOptions();
      let documentPicker = new picker.DocumentViewPicker();
      documentPicker.select(DocumentSelectOptions).then((DocumentSelectResult) => {
        Logger.info(TAG,
          'DocumentViewPicker.select successfully, DocumentSelectResult uri: ' + JSON.stringify(DocumentSelectResult));
        let editFlag = false;
        if (DocumentSelectResult !== null && DocumentSelectResult !== undefined) {
          DocumentSelectResult.forEach((value) => {
            this.uri = value;
            editFlag = true;
            Logger.info(TAG, `select file uri: ${this.uri}`);
          })
        }
        if (editFlag) {
          this.getFilenameByUri(this.uri);
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
      });
    } catch (err) {
      Logger.error(TAG, 'DocumentViewPicker failed with err: ' + JSON.stringify(err));
    }
  }

  // Pull up the picker to save the file.
  async callFilePickerSaveFile(): Promise<void> {
    try {
      let DocumentSaveOptions = new picker.DocumentSaveOptions();
      DocumentSaveOptions.newFileNames = ['MyDocument_01.txt'];
      let documentPicker = new picker.DocumentViewPicker();
      documentPicker.save(DocumentSaveOptions).then((DocumentSaveResult) => {
        Logger.info(TAG,
          'DocumentViewPicker.save successfully, DocumentSaveResult uri: ' + JSON.stringify(DocumentSaveResult));
        if (DocumentSaveResult !== null && DocumentSaveResult !== undefined) {
          this.uri = DocumentSaveResult[0];
          Logger.info(TAG, `save file uri: ${this.uri}`);
        }
        this.getFilenameByUri(this.uri);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'DocumentViewPicker.save failed with err: ' + JSON.stringify(err));
      });
    } catch (err) {
      Logger.error(TAG, 'DocumentViewPicker failed with err: ' + err);
    }
  }

  async getFilenameByUriForMedia(myUris: string[]) {
    try {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/ViewMedia',
        params: {
          uris: myUris
        }
      }, router.RouterMode.Standard);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getFilenameByUriForMedia pushUrl failed, error code=${err.code}, message=${err.message}`);
    }
  }

  async getFilenameByUri(myUri: string): Promise<void> {
    this.filename = (myUri.split('/').pop()) as string;
    try {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/EditFile',
        params: {
          fileName: this.filename,
          myUri: myUri
        }
      }, router.RouterMode.Standard);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getFilenameByUri pushUrl failed, error code=${err.code}, message=${err.message}`);
    }
  }

  // Pull up the picker to select images/videos.
  async callFilePickerSelectImage(): Promise<void> {
    let array: string[];
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
      PhotoSelectOptions.maxSelectNumber = MAX_SELECT_NUM;
      let mediaFlag = false;
      // Create a PhotoViewPicker object.
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
        Logger.info(TAG,
          'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
        if (PhotoSelectResult !== null && PhotoSelectResult !== undefined) {
          // Declare variable array, whose value is the array in PhotoSelectResult.
          array = PhotoSelectResult['photoUris'];
          array.forEach((value) => {
            this.uri = value;
            mediaFlag = true;
            Logger.info(TAG, `select image/video uri: ${this.uri}`);
          })
        }
        if (mediaFlag) {
          this.getFilenameByUriForMedia(array);
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
      });
    } catch (err) {
      Logger.error(TAG, 'PhotoViewPicker failed with err: ' + err);
    }
  }

  aboutToDisappear(): void {
    this.fileNameList = [];
    this.fileSizeList = [];
    this.fileUriList = [];
  }

  onPageShow(): void {
    this.mediaFileUri.getAllFiles();
  }

  build() {
    Scroll(this.scroller) {
      Row() {
        Column() {
          Row() {
            Column() {
              Text($r('app.string.last_open'))
                .fontFamily('HarmonyHeiTi-Bold')
                .fontSize($r('app.float.text_font_size_30'))
                .fontWeight(Constants.TEXT_FONT_WIGHT)
                .textAlign(TextAlign.Start)
                .fontColor($r('app.color.text_font_color'))
                .lineHeight($r('app.float.first_line_height'))
                .width(Constants.SEVENTY_PERCENT)
                .height($r('app.float.first_line_height'))
            }
            .width(Constants.FIFTY_PERCENT)
            .margin({ left: Constants.PADDING_LEFT_RIGHT })
            .alignItems(HorizontalAlign.Start)

            Row() {
              Image($r('app.media.ic_saveas'))
                .width($r('app.float.image_size'))
                .height($r('app.float.image_size'))
                .margin({ right: Constants.IMAGE_MARGIN_RIGHT })
                .id('newFile')
                .onClick(() => {
                  this.callFilePickerSaveFile();
                })

              Image($r('app.media.ic_picture'))
                .width($r('app.float.image_size'))
                .height($r('app.float.image_size'))
                .id('picture')
                .margin({ right: Constants.IMAGE_MARGIN_RIGHT })
                .onClick(() => {
                  this.callFilePickerSelectImage();
                })

              Image($r('app.media.ic_folder'))
                .width($r('app.float.image_size'))
                .height($r('app.float.image_size'))
                .id('folder')
                .opacity(1)
                .margin({ right: Constants.MARGIN_RIGHT })
                .onClick(() => {
                  this.callFilePickerSelectFile();
                })
            }
            .justifyContent(FlexAlign.End)
            .padding({ right: Constants.PADDING_RIGHT })
            .width(Constants.FIFTY_PERCENT)
          }
          .width(Constants.FULL_PERCENT)
          .height($r('app.float.first_line_height'))
          .margin({
            top: $r('app.float.first_line_margin_top'),
            left: $r('app.float.first_line_margin_left'),
            right: $r('app.float.first_line_margin_right'),
            bottom: $r('app.float.first_line_margin_bottom')
          })

          Row() {
            Text($r('app.string.view_last_open'))
              .fontSize($r('app.float.text_area_font_size'))
              .textAlign(TextAlign.Start)
              .lineHeight($r('app.float.line_height'))
              .margin({ left: $r('app.float.image_margin_left') })

            Blank()

            Image($r('app.media.right_arrow'))
              .height($r('app.float.text_height_19'))
              .width($r('app.float.image_width'))
              .margin({
                left: $r('app.float.image_margin_left'),
                right: $r('app.float.image_margin_left'),
                top: $r('app.float.image_margin_top'),
                bottom: $r('app.float.image_margin_top')
              })
          }
          .backgroundColor($r('app.color.start_window_background'))
          .width(Constants.FULL_PERCENT)
          .height($r('app.float.row_height'))
          .padding({
            top: $r('app.float.row_padding'),
            left: $r('app.float.margin_padding_12'),
            right: $r('app.float.margin_padding_12')
          })
          .onClick(() => {
            this.callFilePickerSelectFile();
          })

          Column() {
            List({ space: Constants.LIST_SPACE, initialIndex: 0 }) {
              ForEach(this.fileNameList, (item: string, index?: number) => {
                ListItem() {
                  Row() {
                    Image($r('app.media.ic_docs'))
                      .width(Constants.IMAGE_WIDTH)
                      .height($r('app.float.line_height'))
                      .margin({
                        left: $r('app.float.margin_left'),
                        right: $r('app.float.margin_right')
                      })

                    Text(item)
                      .fontSize($r('app.float.text_area_font_size'))
                      .fontFamily('HarmonyHeiTi-Medium')
                      .fontColor($r('app.color.text_font_color'))
                      .lineHeight($r('app.float.line_height'))
                      .textAlign(TextAlign.Start)
                      .margin({ right: $r('app.float.padding_left_right') })
                      .width(Constants.SIXTY_FOUR_PERCENT)
                    if (index !== undefined) {
                      Text('Size: ' + JSON.stringify(this.fileSizeList[index]) + 'B')
                        .fontSize($r('app.float.text_font_size_14'))
                        .fontFamily('HarmonyHeiTi-Medium')
                        .lineHeight($r('app.float.text_height_19'))
                        .fontColor($r('app.color.text_font_color'))
                        .textAlign(TextAlign.End)
                        .opacity(Constants.TEXT_OPACITY)
                        .width(Constants.TEXT_WIDTH)
                        .margin({ right: $r('app.float.margin_padding_12') })
                    }
                  }
                  .id('fileItem' + (index !== undefined ? index : ""))
                  .borderRadius(Constants.BORDER_RADIUS)
                  .width(Constants.FULL_PERCENT)
                  .height($r('app.float.row_height_64'))
                  .padding({ right: $r('app.float.margin_padding_12') })
                  .backgroundColor($r('app.color.start_window_background'))
                }
                .onClick(() => {
                  Logger.info(TAG, 'fileAsset.displayName fileName item: ' + item);
                  if (index !== undefined) {
                    this.getUIContext().getRouter().pushUrl({
                      url: 'pages/EditFile',
                      params: {
                        fileName: item,
                        myUri: this.fileUriList[index]
                      }
                    }, router.RouterMode.Standard);
                  }
                })
              }, (item: string) => item)
            }
            .listDirection(Axis.Vertical)
            .id('indexList')
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Auto)
            .alignListItem(ListItemAlign.Center)
            .margin({
              top: Constants.LIST_MARGIN_TOP,
              left: $r('app.float.margin_padding_12'),
              right: $r('app.float.margin_padding_12')
            })
          }
          .height(Constants.FULL_PERCENT)
          .width(Constants.FULL_PERCENT)
        }
        .alignItems(HorizontalAlign.Center)
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
        .backgroundColor($r('app.color.common_background'))
      }
      .height(Constants.FULL_PERCENT)
    }
  }
}