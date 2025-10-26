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

import { promptAction, router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { fileIo, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import MediaFileUri from '../media/MediaFileUri';
import Logger from '../common/Logger';
import { terminateSelf } from '../utils/utils';
import { Constants } from '../common/Constants';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const TAG = 'EditFile: ';
let storage = uiContext!.getSharedLocalStorage();
const OPACITY_VALUE = 0.6;

interface myParams extends Object {
  myUri: string,
  fileName: string
};

@Entry(storage)
@Component
struct EditFile {
  @LocalStorageLink('loadFlag') loadFlag: Boolean = false;
  @LocalStorageLink('loadFileSize') loadFileSize: number = 0;
  @LocalStorageLink('loadFileName') loadFileName: string = '';
  @LocalStorageLink('loadFileContent') loadFileContent: string = '';
  @LocalStorageLink('loadUri') loadUri: string = '';
  @LocalStorageLink('fd') loadFd: number = 0;
  @StorageLink('editable') editable: Boolean = false;
  @StorageLink('myFileSize') myFileSize: number = 0;
  @StorageLink('myFileContent') myFileContent: string = '';
  @State myContext: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State myUri: string = '';
  @State opacityValue: number = OPACITY_VALUE;
  @State uriSave: string = '';
  @State myFileName: string = '';
  public fileContentFlag: boolean = false;
  newFileContent: string = '';
  scroller: Scroller = new Scroller();
  controller: TextAreaController = new TextAreaController();
  mediaFileUri: MediaFileUri = new MediaFileUri();

  getFileInfo(): void {
    if (this.loadFlag) {
      this.myFileName = this.loadFileName;
      this.myFileContent = this.loadFileContent;
      this.myFileSize = this.loadFileSize;
      this.myUri = this.loadUri;
      Logger.info(TAG, 'The count of getFileInfo is myFileContent ' + this.myFileContent);
    } else {
      this.myUri = (this.getUIContext().getRouter().getParams() as myParams).myUri;
      this.myFileName = (this.getUIContext().getRouter().getParams() as myParams).fileName;
      this.myFileContent = this.mediaFileUri.readFileContent(this.myUri);
      this.myFileSize = this.mediaFileUri.myGetFileSize(this.myUri, fileIo.OpenMode.READ_ONLY);
      Logger.info(TAG, 'The count of getFileInfo is myFileName is: ' + this.myFileName);
      Logger.info(TAG, 'The count of getFileInfo is myFileContent ' + this.myFileContent);
      Logger.info(TAG, 'The count of getFileInfo is myFileSize ' + this.myFileSize);
    }
    AppStorage.setOrCreate('myFileContent', this.myFileContent);
    AppStorage.setOrCreate('myFileSize', this.myFileSize);
  }

  async writeContentForSaveAsFile(myUri: string, wrFlag: Boolean = false): Promise<void> {
    if (wrFlag) {
      Logger.info(TAG, 'fileAsset.displayName wrFlag is true');
      Logger.info(TAG, 'fileAsset.displayName wrFlag myFileContent :' + this.myFileContent);
      this.mediaFileUri.writeFileContent(myUri, this.myFileContent);
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
          this.uriSave = DocumentSaveResult[0];
          Logger.info(TAG, `save callFilePickerSaveFile file this.uriSave: ${this.uriSave}`);
        }
        Logger.info(TAG, 'fileAsset.displayName wrFlag myFileContent :' + this.myFileContent);
        // Retrieve URI using medialibrary and perform write operation.
        this.writeContentForSaveAsFile(this.uriSave, true);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'DocumentViewPicker.save failed with err: ' + JSON.stringify(err));
      });
    } catch (err) {
      Logger.error(TAG, 'DocumentViewPicker failed with err: ' + err);
    }
  }

  onPageShow(): void {
    this.getFileInfo();
    this.editable = false;
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ic_back'))
            .focusable(true)
            .focusOnTouch(true)
            .id('backIndex')
            .width($r('app.float.image_size'))
            .height($r('app.float.image_size'))
            .align(Alignment.Start)
            .onClick(() => {
              if (this.loadFlag) {
                Logger.info(TAG, 'end page');
                let context = this.getUIContext().getHostContext();
                terminateSelf(context);
              } else {
                this.getUIContext().getRouter().back();
              }
            })
        }
        .margin({ left: Constants.MARGIN_LEFT })

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
              .lineHeight(Constants.TEXT_LINE_HEIGHT)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width(Constants.FULL_PERCENT)
          .align(Alignment.Start)
          .margin({
            left: Constants.MARGIN_LEFT,
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
              .lineHeight(Constants.TEXT_LINE_HEIGHT_19)
              .fontWeight(Constants.TEXT_FONT_WIGHT_400)
          }
          .width(Constants.FULL_PERCENT)
          .margin({
            left: Constants.MARGIN_LEFT,
            top: Constants.MARGIN_ZERO_POINT_THREE_PERCENT,
            bottom: Constants.MARGIN_ZERO_POINT_FIVE_PERCENT
          })
          .align(Alignment.Start)
        }
        .width(Constants.FORTY_FIVE_PERCENT)
        .margin({ left: Constants.MARGIN_LEFT })

        // Three icons on the right.
        Row() {
          Image($r('app.media.ic_saveas'))
            .focusable(true)
            .focusOnTouch(true)
            .width($r('app.float.image_size'))
            .height($r('app.float.image_size'))
            .id('saveAs')
            .margin({ right: Constants.IMAGE_MARGIN_RIGHT })
            .onClick(() => {
              this.callFilePickerSaveFile();
            })
            .visibility(this.loadFlag ? Visibility.Hidden : Visibility.Visible)

          Image($r('app.media.ic_writting'))
            .focusable(true)
            .focusOnTouch(true)
            .width($r('app.float.image_size'))
            .height($r('app.float.image_size'))
            .id('editable')
            .margin({ right: Constants.IMAGE_MARGIN_RIGHT })
            .onClick(() => {
              this.editable = true;
              AppStorage.setOrCreate('editable', this.editable);
              Logger.info(TAG, 'EditFile caretPosition length = ' + this.myFileContent.length);
              this.controller.caretPosition(this.myFileContent.length);
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.editable') });
            })

          Image($r('app.media.ic_save'))
            .focusable(true)
            .focusOnTouch(true)
            .width($r('app.float.image_size'))
            .height($r('app.float.image_size'))
            .id('save')
            .margin({ right: Constants.MARGIN_LEFT })
            .onClick(() => {
              if (this.fileContentFlag) {
                let flage: boolean = true;
                this.myFileContent = this.newFileContent;
                AppStorage.setOrCreate('myFileContent', this.myFileContent);
                Logger.info(TAG, 'save onClick myFileContent is: ' + this.myFileContent);
                Logger.info(TAG, 'save onClick this.loadUri: ' + this.loadUri);
                if (this.loadFlag) {
                  let file = fileIo.openSync(this.loadUri,
                    fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC);
                  Logger.info(TAG, 'save onClick file.fd is: ' + file.fd);
                  fileIo.write(file.fd, this.myFileContent).then((writeLen) => {
                    Logger.info(TAG, 'write data to file succeed and size is:' + writeLen);
                    this.myFileSize = fileIo.statSync(file.fd).size;
                    AppStorage.setOrCreate('myFileSize', this.myFileSize);
                    Logger.info(TAG, 'save onClick this.myFileSize ' + this.myFileSize);
                  }).catch((err: BusinessError) => {
                    Logger.info(TAG, 'write data to file failed with error:' + JSON.stringify(err));
                  });
                  fileIo.closeSync(file);
                } else {
                  try {
                    let file = fileIo.openSync(this.myUri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC);
                    let writeLen = fileIo.writeSync(file.fd, this.myFileContent);
                    this.myFileSize = fileIo.statSync(file.fd).size;
                    AppStorage.setOrCreate('myFileSize', this.myFileSize);
                    Logger.info(TAG, 'write data to file succeed and size is:' + writeLen);
                    fileIo.closeSync(file);
                  } catch (err) {
                    flage = false;
                    Logger.info(`save data to file failed with error:
                      ${JSON.stringify(err)}: ${JSON.stringify(err?.message)}`);
                    this.getUIContext().getPromptAction().showToast({
                      message: $r('app.string.show_toast_message'),
                      duration: 6500
                    })
                  }
                }
                if (flage) {
                  this.editable = false;
                  AppStorage.setOrCreate('editable', this.editable);
                  this.getUIContext().getPromptAction().showToast({ message: $r('app.string.saved') });
                }
              }
            })
        }
        .height(Constants.FIFTY_PERCENT)
        .width(Constants.THIRTY_SEVEN_POINT_TWO)
        .padding({ right: Constants.MARGIN_ZERO_POINT_FIVE_PERCENT })
        .justifyContent(FlexAlign.End)
      }
      .height(Constants.SEVEN_POINT_FOUR)
      .width(Constants.FULL_PERCENT)

      Scroll(this.scroller) {
        Row() {
          TextArea({
            text: this.newFileContent ? this.newFileContent : this.myFileContent,
            placeholder: Constants.TEXT_AREA_PLACEHOLDER,
            controller: this.controller
          })
            .id('textArea')
            .fontSize($r('app.float.text_area_font_size'))
            .fontColor($r('app.color.text_font_color'))
            .opacity(this.opacityValue)
            .fontWeight(Constants.TEXT_FONT_WIGHT_400)
            .align(Alignment.TopStart)
            .textAlign(TextAlign.Start)
            .backgroundColor($r('app.color.common_background'))
            .fontFamily('HarmonyHeiTi')
            .padding({
              top: $r('app.float.padding_top_bottom'),
              right: $r('app.float.padding_left_right'),
              left: $r('app.float.padding_left_right'),
              bottom: $r('app.float.padding_top_bottom')
            })
            .focusable(this.editable ? true : false)
            .focusOnTouch(true)
            .defaultFocus(false)
            .onFocus(() => {
              this.opacityValue = 1;
            })
            .onBlur(() => {
              this.opacityValue = OPACITY_VALUE;
            })
            .onChange((value: string) => {
              this.newFileContent = value;
              this.fileContentFlag = true;
            })
        }
        .padding({
          top: Constants.PADDING_TOP,
          left: Constants.PADDING_LEFT_RIGHT,
          right: Constants.PADDING_LEFT_RIGHT
        })
      }
    }
    .backgroundColor($r('app.color.common_background'))
    .height(Constants.FULL_PERCENT)
  }
}