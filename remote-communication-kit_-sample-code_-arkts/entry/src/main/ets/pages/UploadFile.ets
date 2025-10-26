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

import { FileSelectUtils } from '../utils/FileSelectUtils';
import { rcp } from '@kit.RemoteCommunicationKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

// During the test, fill in the website to which the file will be uploaded as required.
const UPLOAD_URL = 'https://www.example.com';

@Entry
@Component
struct UploadFile {
  @State content: string = '';
  // During the test, enter the path of the file to be uploaded as required.
  @State viewModel: UploadViewModel = new UploadViewModel(UPLOAD_URL);

  aboutToDisappear(): void {
    this.viewModel.close();
  }

  build() {
    Column() {
      Text('UploadFile')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ff100f0f')
        .margin({ top: 32, left: 16 })
        .alignSelf(ItemAlign.Start)

      Divider().color('gray').strokeWidth(1)

      Progress({
        value: this.viewModel.uploadSize,
        total: this.viewModel.fileSize,
        type: ProgressType.Linear
      })
        .style({
          strokeWidth: 10
        })
        .margin({
          left: 15,
          right: 15,
          top: 20,
          bottom: 10
        })

      Text(this.viewModel.uploadSize + '/' + this.viewModel.fileSize + ' (byte)')
        .fontColor('#ff100f0f')
        .margin({ top: 10, bottom: 10 })

      Button('SelectPhoto')
        .width('55%')
        .height(40)
        .backgroundColor('#0A59F7')
        .fontColor(Color.White)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .borderRadius(20)
        .margin(10)
        .onClick(() => {
          this.selectFile();
        })

      Button('UploadFile')
        .width('55%')
        .height(40)
        .backgroundColor('#0A59F7')
        .fontColor(Color.White)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .borderRadius(20)
        .margin(10)
        .onClick(() => {
          this.viewModel.start();
        })

      Column() {
        Text('Result:')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff100f0f')
          .margin({ top: 10, bottom: 10 })

        Scroll() {
          Text(this.viewModel.content)
            .width('100%')
            .fontColor('#ff100f0f')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .padding(8)
        }
        .width('100%')
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .backgroundColor('#F3F3F3')
        .borderRadius(10)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding(15)
    }.width('100%')
    .height('100%')
  }

  /**
   * Select the photo you want to upload.
   */
  private selectFile() {
    FileSelectUtils.selectPhoto().then((res) => {
      if (res && res !== '') {
        this.viewModel.initFile(res)
      }
    })
  }
}

@Observed
export class UploadViewModel {
  private session?: rcp.Session = undefined;
  private file?: fs.File = undefined;
  // Network address for uploading files.
  public uploadUrl: string = '';
  // Local path of the file to be uploaded.
  public filePath: string = '';
  // Size of the file to be uploaded.
  public fileSize: number = 0;
  // Size of the part of the file that has been uploaded.
  public uploadSize: number = 0;
  // Prompt content.
  public content: string = '';

  constructor(uploadUrl: string) {
    this.uploadUrl = uploadUrl;
  }

  /**
   * Obtains the size of the file to be uploaded.
   */
  public initFile(filePath: string) {
    try {
      this.file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      if (this.file) {
        this.fileSize = fs.statSync(this.file.fd).size;
      } else {
        this.fileSize = 0;
        this.content = `initFileSize, error: The file does not exist.`;
        console.error(this.content);
      }
    } catch (err) {
      this.content = `initFileSize, error: ${JSON.stringify(err)}`;
      console.error(this.content);
    }
  }

  /**
   * Start uploading files.
   */
  public start() {
    if (this.fileSize === 0) {
      this.content = `start, error: The file does not exist.`;
      console.error(this.content);
      return;
    }
    this.content = 'Uploading...';
    const eventsHandler: rcp.HttpEventsHandler = {
      // Use the onUploadProgress callback function of HttpEventsHandler to listen to the upload progress.
      onUploadProgress: (_totalSize: number, transferredSize: number) => {
        this.uploadSize = transferredSize;
      }
    };
    const tracingConfig: rcp.TracingConfiguration = {
      httpEventsHandler: eventsHandler
    };
    const requestConfig: rcp.Configuration = {
      tracing: tracingConfig
    };
    // Set Configuration based on service requirements.
    const sessionConfig: rcp.SessionConfiguration = {
      requestConfiguration: requestConfig
    }
    try {
      this.session = rcp.createSession(sessionConfig);
    } catch (err) {
      console.error(`Create session error: ${JSON.stringify(err)}`);
    }
    this.uploadFile();
  }

  /**
   * Upload the file.
   */
  private async uploadFile() {
    if (!this.file) {
      return;
    }
    try {
      const uploadFromFile = new rcp.UploadFromFile(this.file);
      const resp = await this.session?.uploadFromFile(this.uploadUrl, uploadFromFile);
      if (resp) {
        this.content = `uploadFile, result code: ${JSON.stringify(resp.statusCode)}`;
        console.info(this.content);
      }
    } catch (err) {
      this.content = `uploadFile, error: ${JSON.stringify(err)}`;
      console.error(this.content);
    } finally {
      this.close();
    }
  }

  /**
   * Close the session when the upload is complete or when you leave the page.
   */
  public close() {
    if (this.file) {
      fs.close(this.file.fd).catch((err: BusinessError) => {
        console.error(`close error: ${JSON.stringify(err)}`);
      });
      this.file = undefined;
    }
    if (this.session) {
      try {
        this.session.close();
        this.session = undefined;
      } catch (err) {
        this.content = `close, error: ${err}`;
        console.error(this.content);
      }
    }
  }
}
