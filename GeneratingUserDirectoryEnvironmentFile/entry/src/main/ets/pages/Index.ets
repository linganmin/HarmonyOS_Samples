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

import Logger from '../common/Logger';
import { Environment } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State text: string = '';
  @State fileName: string = '';
  @State path: string = '';
  controller: TextInputController = new TextInputController();

  aboutToAppear(): void {
    if (!canIUse('SystemCapability.FileManagement.File.Environment.FolderObtain')) {
      Logger.error('this api is not supported on this device');
      return;
    }
  }

  writeUserDownloadDirExample(text: string, fileName: string) {
    try {
      const downloadPath = Environment.getUserDownloadDir();
      this.path = downloadPath;
      console.info(`success to getUserDownloadDir: ${downloadPath}`);
      const file = fs.openSync(`${downloadPath}/${fileName}.txt`, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.writeSync(file.fd, text);
      fs.closeSync(file);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Error code: ${err.code}, message: ${err.message}`);
    }
  }

  writeUserDesktopDirExample(text: string, fileName: string) {
    try {
      const desktopPath = Environment.getUserDesktopDir();
      this.path = desktopPath;
      console.info(`success to getUserDesktopDir: ${desktopPath}`);
      const file = fs.openSync(`${desktopPath}/${fileName}.txt`, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.writeSync(file.fd, text);
      fs.closeSync(file);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Error code: ${err.code}, message: ${err.message}`);
    }
  }

  writeUserDocumentDirExample(text: string, fileName: string) {
    try {
      const documentPath = Environment.getUserDocumentDir();
      this.path = documentPath;
      console.info(`success to getUserDocumentDir: ${documentPath}`);
      const file = fs.openSync(`${documentPath}/${fileName}.txt`, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.writeSync(file.fd, text);
      fs.closeSync(file);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Error code: ${err.code}, message: ${err.message}`);
    }
  }

  build() {
    Column() {
      Text($r('app.string.insert_file'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({
          left: 48,
          top: 14.5
        })
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Image($r('app.media.file'))
        .size({
          width: 198,
          height: 198
        })
        .margin({
          top: 83
        })
      Row() {
        Column() {
          Text($r('app.string.file_name'))
            .width('100%')
            .fontColor(Color.Grey)
            .textAlign(TextAlign.Start)
            .margin({
              bottom: 8,
              left: 400
            })
          TextInput({ text: this.fileName, placeholder: 'input your word...', controller: this.controller })
            .placeholderColor(Color.Grey)
            .placeholderFont({
              size: 14,
              weight: 322
            })
            .caretColor(Color.Blue)
            .height(40)
            .margin(20)
            .fontSize(14)
            .fontColor(Color.Black)
            .onChange((value: string) => {
              this.fileName = value;
            })
            .margin({
              left: 193,
              right: 35
            })
        }.width('50%')

        Column() {
          Text($r('app.string.file_context'))
            .width('100%')
            .fontColor(Color.Grey)
            .textAlign(TextAlign.Start)
            .margin({
              bottom: 8,
              left: 75
            })
          TextInput({ text: this.fileName, placeholder: 'input your word...', controller: this.controller })
            .placeholderColor(Color.Grey)
            .placeholderFont({
              size: 14,
              weight: 200
            })
            .caretColor(Color.Blue)
            .height(40)
            .margin(20)
            .fontSize(14)
            .fontColor(Color.Black)
            .onChange((value: string) => {
              this.text = value;
            })
            .margin({
              left: 193,
              right: 35
            })
        }.width('50%')
      }

      Column() {
        Button($r('app.string.insert_document'), { type: ButtonType.Normal })
          .width(661)
          .height(40)
          .margin({
            bottom: 12
          })
          .backgroundColor(0XEFEFEF)
          .fontColor(0X0A59F7)
          .borderRadius(8)
          .onClick(
            () => {
              this.writeUserDocumentDirExample(this.text, this.fileName);
              try {
                this.getUIContext().getPromptAction().showToast({
                  message: this.getResourceString($r('app.string.message')) + `${this.path}`,
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                Logger.error(`showToast args error code is ${code}, message is ${message}`);
              }
            }
          )

        Button($r('app.string.insert_desktop'), { type: ButtonType.Normal })
          .width(661)
          .height(40)
          .margin({
            bottom: 12
          })
          .backgroundColor(0XEFEFEF)
          .fontColor(0X0A59F7)
          .borderRadius(8)
          .onClick(
            () => {
              this.writeUserDesktopDirExample(this.text, this.fileName);
              try {
                this.getUIContext().getPromptAction().showToast({
                  message: this.getResourceString($r('app.string.message')) + `${this.path}`,
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                Logger.error(`showToast args error code is ${code}, message is ${message}`);
              }
            }
          )

        Button($r('app.string.insert_download'), { type: ButtonType.Normal })
          .width(661)
          .height(40)
          .margin({
            bottom: 12
          })
          .backgroundColor(0XEFEFEF)
          .fontColor(0X0A59F7)
          .borderRadius(8)
          .onClick(
            () => {
              this.writeUserDownloadDirExample(this.text, this.fileName);
              try {
                this.getUIContext().getPromptAction().showToast({
                  message: this.getResourceString($r('app.string.message')) + `${this.path}`,
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message;
                let code = (error as BusinessError).code;
                Logger.error(`showToast args error code is ${code}, message is ${message}`);
              }
            }
          )
      }
      .padding({
        bottom: 24
      })
      .width('100%')
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height('100%')
    .width('100%')
  }

  getResourceString(resource: Resource): string {
    let resourceString = '';
    try {
      resourceString = this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(`getStringSync failed, error code=${err.code}, message=${err.message}`);
    }
    return resourceString;
  }
}