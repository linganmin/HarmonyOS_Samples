/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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

import { rcp } from '@kit.RemoteCommunicationKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { JSON } from '@kit.ArkTS';
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

// During the test, change the file download address as required.
const kHttpServerAddress = "https://httpbin.org";

@Entry
@Component
struct TransferRange {
  // During the test, change the path for saving the file as required.
  readonly FILE_PATH = this.getUIContext().getHostContext()?.filesDir + '/downloadFile.zip'
  @State viewModel: TransferViewModel = new TransferViewModel(kHttpServerAddress, this.FILE_PATH);
  private netCon = connection.createNetConnection();

  aboutToAppear(): void {
    this.viewModel.initFileSize();
    this.subscribeNetworkChanged();
  }

  aboutToDisappear(): void {
    this.viewModel.stop();
    this.viewModel.deleteFile();
    this.netCon.unregister((error: BusinessError) => {
      console.log(JSON.stringify(error));
    });
  }

  build() {
    Column() {
      Row() {
        Text('TransferRange')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff100f0f')
          .height(30)
          .width(220)
          .margin({ left: 4 })
      }
      .height(32)
      .width(124)
      .margin({ top: 32, left: 12 })

      Divider().color('gray').strokeWidth(1)

      Column() {
        Progress({
          value: this.viewModel.lastTransferPosition,
          total: this.viewModel.fileTotalSize,
          type: ProgressType.Linear
        }).style({
          strokeWidth: 10
        })

        Text(this.viewModel.lastTransferPosition + '/' + this.viewModel.fileTotalSize + ' (byte)')
          .fontColor('#ff100f0f')
          .margin({ top: 10, bottom: 10 })
      }
      .padding(20)
      .margin({ top: 10, bottom: 10 })

      Row({ space: 10 }) {
        Button('Start')
          .height(40)
          .layoutWeight(1)
          .backgroundColor('#0A59F7')
          .fontColor(Color.White)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .borderRadius(20)
          .enabled(this.viewModel.isStopped())
          .onClick(() => {
            this.start();
          })
        Button('Stop')
          .height(40)
          .layoutWeight(1)
          .backgroundColor('#0A59F7')
          .fontColor(Color.White)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .borderRadius(20)
          .enabled(!this.viewModel.isStopped())
          .onClick(() => {
            this.stop();
          })
      }.width('100%')
      .padding(15)
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 10 }) {
        Button('Pause')
          .height(40)
          .layoutWeight(1)
          .backgroundColor('#0A59F7')
          .fontColor(Color.White)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .borderRadius(20)
          .enabled(this.viewModel.isDownloading())
          .onClick(() => {
            this.viewModel.pause();
          })
        Button('Resume')
          .height(40)
          .layoutWeight(1)
          .backgroundColor('#0A59F7')
          .fontColor(Color.White)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .borderRadius(20)
          .enabled(this.viewModel.isPaused())
          .onClick(() => {
            this.resume();
          })
      }.width('100%')
      .padding(15)
      .justifyContent(FlexAlign.SpaceBetween)

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
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .padding(8)
        }
        .width('100%')
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .borderRadius(10)
        .backgroundColor('#F3F3F3')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding(15)
    }
    .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * Interception of network changes.
   */
  private subscribeNetworkChanged() {
    this.netCon.register((error: BusinessError) => {
      console.error(`register, error: ${JSON.stringify(error)}`);
    });
    this.netCon.on('netAvailable', (data: connection.NetHandle) => {
      console.log(`netAvailable, data: ${JSON.stringify(data)}`);
      this.resume();
    });
    this.netCon.on('netUnavailable', () => {
      console.log('netUnavailable');
      this.viewModel.pause();
    });
    this.netCon.on('netLost', (data: connection.NetHandle) => {
      console.log(`netLost, data: ${JSON.stringify(data)}`);
      this.viewModel.pause();
    });
    this.netCon.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      console.log(`netCapabilitiesChange, data: ${JSON.stringify(data)}`);
      if (data && data.netCap.bearerTypes[0] === connection.NetBearType.BEARER_WIFI) {
        this.viewModel.resume();
      }
    });
  }

  private async start() {
    if (await this.isWlan()) {
      this.viewModel.start();
    } else {
      this.viewModel.content = 'The current environment is not WLAN.'
    }
  }

  private async resume() {
    if (await this.isWlan()) {
      this.viewModel.resume();
    } else {
      this.viewModel.content = 'The current environment is not WLAN.'
    }
  }

  private async stop() {
    this.viewModel.stop();
    this.viewModel.deleteFile();
    this.viewModel.initFileSize();
  }

  /**
   * Determine whether the current network is a WLAN network.
   *
   * @returns true:It is a WLAN network;false:Not a WLAN network.
   */
  private async isWlan(): Promise<boolean> {
    try {
      let netHandle = await connection.getDefaultNet();
      if (netHandle) {
        let netCapabilities = await connection.getNetCapabilities(netHandle);
        console.log(`getNetworkType, result: ${JSON.stringify(netCapabilities)}`)
        if (netCapabilities && netCapabilities.bearerTypes.length > 0 &&
          netCapabilities.bearerTypes[0] === connection.NetBearType.BEARER_WIFI) {
          return true;
        }
      }
    } catch (err) {
      console.error(`getNetworkType, error: ${JSON.stringify(err)}`)
    }
    return false;
  }
}


/**
 * Transmission status.
 */
enum STATE {
  STOPPED,
  DOWNLOADING,
  PAUSED
}

@Observed
export class TransferViewModel {
  private state = STATE.STOPPED;
  private session?: rcp.Session;
  private stepSize = 1000;
  // The network address to download the file.
  private fileUrl: string = '';
  // The local path where the downloaded file is saved.
  private savePath: string = '';
  // The downloaded file.
  private file?: fs.File;
  // The total size of the file.
  public fileTotalSize: number = 0;
  // The size of the part of the file that has been downloaded.
  public lastTransferPosition: number = 0;
  // Prompt content.
  public content: string = 'Stopped.';

  constructor(fileUrl: string, savePath: string) {
    this.fileUrl = fileUrl;
    this.savePath = savePath;
  }

  /**
   * Initialize download file.
   */
  public async initFileSize() {
    try {
      this.fileTotalSize = await this.getUrlFileSize();
      this.getSavedFileSize();
      this.setState(STATE.STOPPED);
    } catch (err) {
      console.error(`initFileSize, error: ${JSON.stringify(err)}`);
    }
  }

  /**
   * Start downloading.
   */
  public async start() {
    if (!this.isStopped()) {
      return;
    }
    try {
      if (this.fileTotalSize === 0) {
        this.content = `start error: getUrlFileSize failed`;
        console.error(this.content);
        return;
      }
      this.file = fs.openSync(this.savePath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
      this.session = rcp.createSession();
    } catch (err) {
      this.content = `start response, error: ${JSON.stringify(err)}`;
      console.error(this.content);
    }
    this.content = '';
    let nextTo = Math.min(this.lastTransferPosition + this.stepSize, this.fileTotalSize);
    this.downloadFileTransfer(this.lastTransferPosition, nextTo);
  }

  /**
   * Pause downloading.
   */
  public pause() {
    if (!this.isDownloading()) {
      return;
    }
    this.setState(STATE.PAUSED);
    this.session?.cancel();
  }

  /**
   * Resume downloading.
   */
  public resume() {
    if (!this.isPaused()) {
      return;
    }
    if (this.fileTotalSize === 0) {
      this.content = 'resume error: Failed to obtain the file to be downloaded.';
      return;
    }
    let nextTo = Math.min(this.lastTransferPosition + this.stepSize, this.fileTotalSize);
    this.downloadFileTransfer(this.lastTransferPosition, nextTo);
  }

  /**
   * Stop downloading.
   */
  public stop() {
    if (this.isStopped()) {
      return;
    }
    this.setState(STATE.STOPPED);
    this.session?.cancel();
    this.session?.close();
    if (this.file) {
      fs.close(this.file).catch((err: BusinessError) => {
        this.content = `stop error: ${JSON.stringify(err)}`;
        console.error(this.content);
      });
    }
  }

  /**
   * Downloading files in resumable download mode.
   *
   * @param from - Transfer start position.
   * @param to - Transfer end position.
   */
  private downloadFileTransfer(from: number, to: number) {
    if (to > this.fileTotalSize) {
      this.setState(STATE.STOPPED);
      return;
    }
    this.setState(STATE.DOWNLOADING);
    const request = new rcp.Request(this.fileUrl, 'GET');
    request.transferRange = { from: from, to: to };
    this.session?.fetch(request).then((rep: rcp.Response) => {
      if (rep.body) {
        try {
          // Save downloaded data.
          fs.writeSync(this.file?.fd, rep.body, { offset: this.lastTransferPosition });
          this.lastTransferPosition += rep.body.byteLength;
          if (this.lastTransferPosition < this.fileTotalSize) {
            let nextTo = Math.min(this.lastTransferPosition + this.stepSize, this.fileTotalSize);
            // Continue downloading the next data segment.
            this.downloadFileTransfer(this.lastTransferPosition, nextTo);
          } else {
            this.content = `downloadFileTransfer, download completed: ${rep.toString()}`;
            console.info(this.content);
            this.stop();
          }
        } catch (error) {
          this.content = `downloadFileTransfer error: ${JSON.stringify(error)}`;
          console.error(this.content);
        }
      } else {
        this.content = `downloadFileTransfer body is empty, download completed: ${rep.toString()}`;
        console.info(this.content);
      }
    }).catch((err: BusinessError) => {
      this.handleError(err);
    });
  }

  /**
   * Gets the total size of the files to be downloaded.
   *
   * @returns Total file size.
   */
  private async getUrlFileSize(): Promise<number> {
    let totalSize = 0;
    try {
      const tempSession = rcp.createSession();
      const request = new rcp.Request(this.fileUrl);
      request.transferRange = { from: 0, to: 1 };
      try {
        let res = await tempSession.fetch(request);
        if (res) {
          console.info(`getUrlFileSize, result: ${JSON.stringify(res.headers)}`);
          // 从返回的响应数据的header的content-range字段中提取出文件的大小
          let contentRange = res.headers['content-range'];
          let sizeStr =
            contentRange ? contentRange.substring(contentRange.indexOf('\/') + 1, contentRange.length) : '0';
          totalSize = Number(sizeStr);
        }
      } catch (err) {
        console.error(`getUrlFileSize, err: ${JSON.stringify(err)}`);
      } finally {
        tempSession.close();
      }
    } catch (err) {
      console.error(`createSession, err: ${JSON.stringify(err)}`);
    }
    return totalSize;
  }

  /**
   * Get the size of the saved part of the file.
   */
  private getSavedFileSize() {
    try {
      if (fs.accessSync(this.savePath)) {
        this.lastTransferPosition = fs.statSync(this.savePath).size;
      } else {
        this.lastTransferPosition = 0;
      }
    } catch (err) {
      this.content = `getSavedFileSize accessSync, err: ${JSON.stringify(err)}`;
      console.error(this.content);
    }
  }

  /**
   * Is it currently paused.
   * @returns true:Paused;false:Not paused.
   */
  public isPaused(): boolean {
    return this.state === STATE.PAUSED;
  }

  /**
   * Is it currently downloading.
   * @returns true:Downloading;false:Not downloading.
   */
  public isDownloading(): boolean {
    return this.state === STATE.DOWNLOADING;
  }

  /**
   * Is it currently stopped.
   * @returns true:Stopped state;false:Not stopped state.
   */
  public isStopped(): boolean {
    return this.state === STATE.STOPPED;
  }

  /**
   * Delete the downloaded file.
   */
  public deleteFile() {
    try {
      if (fs.accessSync(this.savePath)) {
        fs.unlinkSync(this.savePath);
      }
    } catch (err) {
      this.content = `deleteFile accessSync, err: ${JSON.stringify(err)}`;
      console.error(this.content);
    }
  }

  /**
   * Handle error results.
   * @param err - Error message.
   */
  private handleError(err: BusinessError) {
    if (err.code === 1007900992) {
      if (this.isPaused()) {
        this.content = 'Paused.'
      } else {
        this.content = 'Stopped.'
      }
    } else {
      this.content = `downloadFileTransfer, response err: ${JSON.stringify(err)}`;
    }
    console.error(this.content);
  }

  /**
   * Set the current status.
   *
   * @param state - Current status.
   */
  private setState(state: STATE) {
    this.state = state;
    if (this.state === STATE.DOWNLOADING) {
      this.content = 'Downloading...';
    } else if (this.state === STATE.PAUSED) {
      this.content = 'Paused.';
    } else {
      if (this.fileTotalSize === 0) {
        return;
      }
      if (this.lastTransferPosition === this.fileTotalSize) {
        this.content = 'Completed.';
      } else {
        this.content = 'Stopped.';
      }
    }
  }
}