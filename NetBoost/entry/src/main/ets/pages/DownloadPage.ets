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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { connection } from '@kit.NetworkKit';
import { common } from '@kit.AbilityKit';
import { getDefaultNetHandle } from '../net/NetConnectionManager';
import { CommonConst } from '../common/CommonConst';
import { DownLoadInfo, FileDownloadManager } from '../viewmodel/download/FileDownManager';
import { SubTitle } from '../views/Titles';
import { showToast } from '../utils/CommonUtils';
import { DownloadItem } from '../views/DownloadView';
import { formatFileSize } from '../utils/FileUtils';
import {
  getMultiPathQuota,
  NetHandleChange,
  releaseMultiPath,
  reportQoe,
  requestMultiPath,
  setOffMultiPathStateChange,
  setOnMultiPathStateChange,
  setUploadSceneDesc
} from '../net/NetBoostManager';

const DOMAIN = 0x0000;
const TAG = 'DownloadPage';

@Builder
export function DownloadPageBuilder() {
  DownloadPage()
}

@Component
struct DownloadPage {
  @State multiPathNetOpened: boolean = false;
  @State downBtnEnable: boolean = true;
  @State downFirstProgress: number = 0;
  @State downFirstProgressColor: Resource = $r('sys.color.comp_background_emphasize');
  @State downSecondProgress: number = 0;
  @State downSecondProgressColor: Resource = $r('sys.color.comp_background_emphasize');
  @State downFirstProgressText: string = '';
  @State downSecondProgressText: string = '';
  @State downFirstFileResult: string | Resource = '';
  @State downSecondFileResult: string | Resource = '';
  private context: Context | undefined;
  private firstDownFileInfo?: DownLoadInfo;
  private secondDownFileInfo?: DownLoadInfo;
  private firstFileDownloader?: FileDownloadManager;
  private secondFileDownloader?: FileDownloadManager;
  private firstFileDownloading: boolean = false;
  private secondFileDownloading: boolean = false;
  private multiNetHandle?: connection.NetHandle;
  private taskArray: string[] = [];
  // [Start nethandle_change]
  private netHandleChange: NetHandleChange = {
    onMultiNetSuccess: async (netHandle: connection.NetHandle): Promise<void> => {
      this.multiNetHandle = netHandle;
      let res = this.taskArray.shift();
      if (res) {
        this.startDownSecondFile(netHandle);
      } else {
        hilog.info(DOMAIN, TAG, `[netHandleChange] Multi-net enable,but no need to download file2`);
      }
    },

    onMultiNetRelease: async (netHandle: connection.NetHandle): Promise<void> => {
      this.multiNetHandle = undefined;
    }
  }
  // [End nethandle_change]

  private initData() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const filePath = this.context.filesDir;
    this.firstDownFileInfo = new DownLoadInfo(CommonConst.DOWN_URL1, 'aa.mp4', filePath);
    this.secondDownFileInfo = new DownLoadInfo(CommonConst.DOWN_URL2, 'bb.mp4', filePath);
    this.downFirstProgressText = '0 / 0';
    this.downSecondProgressText = '0 / 0';
  }

  aboutToAppear(): void {
    this.initData();
    setOnMultiPathStateChange(this.netHandleChange);
  }

  aboutToDisappear(): void {
    setOffMultiPathStateChange();
    this.closeMultiPathNet();
    this.firstFileDownloader?.clean();
    this.secondFileDownloader?.clean();
  }

  private closeMultiPathNet() {
    setUploadSceneDesc(false);
    releaseMultiPath();
    getMultiPathQuota();
    reportQoe('good');
  }

  // [Start download_first_file]
  /**
   * Downloads the first file using the specified netHandle.
   * @param netHandle The specified netHandle to access the server.
   * */
  private startDownFirstFile(netHandle: connection.NetHandle) {
    this.firstFileDownloader = new FileDownloadManager(this.firstDownFileInfo!, netHandle);
    this.firstFileDownloader.onProgress = (downloaded: number, fileSize: number, progress: number) => {
      this.downFirstProgress = progress;
      this.downFirstProgressText = `${formatFileSize(downloaded)} / ${formatFileSize(fileSize)}`;
    }
    // download success
    this.firstFileDownloader.onSuccess = () => {
      this.firstFileDownloading = false;
      this.downBtnEnable = (!this.firstFileDownloading) && (!this.secondFileDownloading) && this.taskArray.length === 0;
      this.downFirstProgressColor = $r('sys.color.confirm');
      let res = this.taskArray.shift();
      this.downFirstFileResult = '';
      if (res) {
        this.startDownSecondFile(netHandle);
      } else {
        hilog.info(DOMAIN, TAG, `[startDownFirstFile]  File1 downloaded,no need to download File2`);
      }
    }
    // download failed
    this.firstFileDownloader.onError = () => {
      this.firstFileDownloading = false;
      this.downBtnEnable = (!this.firstFileDownloading) && (!this.secondFileDownloading);
      if (this.downFirstProgress === 0) {
        this.downFirstProgress = 0.01;
      }
      this.downFirstProgressColor = $r('sys.color.multi_color_08');
      this.taskArray.shift();
      this.downFirstFileResult = $r('app.string.down_failed');
    }
    // init downloading status
    this.firstFileDownloading = true;
    this.downFirstProgress = 0;
    this.downFirstProgressColor = $r('sys.color.comp_background_emphasize');
    this.downFirstFileResult = '';
    // start download
    this.firstFileDownloader.startDownload();
  }
  // [End download_first_file]

  /**
   * Downloads the second file using the specified netHandle.
   * @param netHandle The specified netHandle to access the server.
   * */
  private startDownSecondFile(netHandle: connection.NetHandle) {
    this.secondFileDownloader = new FileDownloadManager(this.secondDownFileInfo!, netHandle);
    this.secondFileDownloader.onProgress = (downloaded: number, fileSize: number, progress: number) => {
      this.downSecondProgress = progress;
      this.downSecondProgressText = `${formatFileSize(downloaded)} / ${formatFileSize(fileSize)}`;
    }
    // download success
    this.secondFileDownloader.onSuccess = () => {
      this.secondFileDownloading = false;
      this.downBtnEnable = (!this.firstFileDownloading) && (!this.secondFileDownloading) && this.taskArray.length === 0;
      this.downSecondProgressColor = $r('sys.color.confirm');
      if (this.multiNetHandle) {
        this.multiPathNetOpened = false;
      }
    };
    // download failed
    this.secondFileDownloader.onError = () => {
      this.secondFileDownloading = false;
      this.downBtnEnable = (!this.firstFileDownloading) && (!this.secondFileDownloading);
      if (this.downSecondProgress === 0) {
        this.downSecondProgress = 0.01;
      }
      this.downSecondProgressColor = $r('sys.color.multi_color_08');
      if (this.multiNetHandle) {
        this.multiPathNetOpened = false;
      }
      this.downSecondFileResult = $r('app.string.down_failed');
    };
    // init downloading status
    this.secondFileDownloading = true;
    this.downSecondProgress = 0;
    this.downSecondProgressColor = $r('sys.color.comp_background_emphasize');
    this.downSecondFileResult = '';
    // start download
    this.secondFileDownloader.startDownload();
  }

  build() {
    NavDestination() {
      Column() {
        SubTitle($r('app.string.download_list'))
        DownloadItem({
          fileName: $r('app.string.china'),
          downProgressText: this.downFirstProgressText,
          downProgress: this.downFirstProgress,
          downProgressColor: this.downFirstProgressColor,
          downResult: this.downFirstFileResult,
        })
          .margin({
            top: $r('app.float.size_8vp'),
          })

        DownloadItem({
          fileName: $r('app.string.foreign_history'),
          downProgressText: this.downSecondProgressText,
          downProgress: this.downSecondProgress,
          downProgressColor: this.downSecondProgressColor,
          downResult: this.downSecondFileResult,
        })
          .margin({
            top: $r('app.float.size_8vp')
          })

        Blank()
        Row() {
          Text($r('app.string.multi_net_upload'))
            .fontSize($r('app.float.size_14fp'))
            .fontWeight(FontWeight.Normal)
            .textAlign(TextAlign.Start)
            .fontColor($r('sys.color.font_primary'))
            .width('calc(100% - 38vp)')
            .margin({
              left: $r('app.float.size_2vp')
            })

          Toggle({ type: ToggleType.Switch, isOn: $$this.multiPathNetOpened })
            .selectedColor($r('sys.color.brand'))
            .height('app.float.size_20vp')
            .switchPointColor($r('sys.color.comp_background_list_card'))
            .margin({
              right: $r('app.float.size_2vp')
            })
            .onChange(async (value: boolean) => {
              if (value) {
                reportQoe('packetLost');
                setUploadSceneDesc(true);
                if (await requestMultiPath()) {
                  getMultiPathQuota();
                  showToast($r('app.string.multi_net_enabled'));
                } else {
                  this.multiPathNetOpened = false;
                  showToast($r('app.string.multi_net_failed'));
                  setUploadSceneDesc(false);
                }
              } else {
                this.closeMultiPathNet();
              }
            });
        }
        .height('app.float.size_48vp')
        .width('100%')
        .padding({
          left: $r('app.float.size_12vp'),
          right: $r('app.float.size_12vp')
        })
        .onClick(() => {
          this.multiPathNetOpened = !this.multiPathNetOpened;
        })

        Button($r('app.string.download'))
          .fontSize($r('app.float.size_16fp'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Medium)
          .borderRadius($r('app.float.size_20vp'))
          .height($r('app.float.size_40vp'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width('100%')
          .enabled(this.downBtnEnable)
          .margin({
            top: $r('app.float.size_12vp'),
            bottom: $r('app.float.size_16vp')
          })
          .onClick(async () => {
            const mainNetHandle = getDefaultNetHandle();
            if (mainNetHandle) {
              // reset downloading status
              this.downFirstProgress = 0;
              this.downFirstProgressColor = $r('sys.color.comp_background_emphasize');
              this.downSecondProgress = 0;
              this.downSecondProgressColor = $r('sys.color.comp_background_emphasize');
              this.downFirstProgressText = '0 / 0';
              this.downSecondProgressText = '0 / 0';
              this.downFirstFileResult = '';
              this.downSecondFileResult = '';

              this.downBtnEnable = false;
              this.startDownFirstFile(mainNetHandle);
              if (this.multiNetHandle) {
                this.startDownSecondFile(this.multiNetHandle);
              } else {
                hilog.info(DOMAIN, TAG, `[Download] Multi-Network not available`);
                this.taskArray.push('download2');
              }
            } else {
              hilog.error(DOMAIN, TAG, `[Download] Main-Network not available`);
              this.downFirstProgress = 0.01;
              this.downFirstProgressColor = $r('sys.color.multi_color_08');
              this.downSecondProgress = 0.01;
              this.downSecondProgressColor = $r('sys.color.multi_color_08');

              this.downFirstProgressText = '0 / 0';
              this.downSecondProgressText = '0 / 0';

              this.downFirstFileResult = $r('app.string.down_failed');
              this.downSecondFileResult = $r('app.string.down_failed');
            }
          })
      }
      .padding({
        left: $r('app.float.size_16vp'),
        right: $r('app.float.size_16vp'),
      })
      .height('100%')
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(false)
    .title($r('app.string.submit_download'))
    .hideBackButton(false)
    .hideToolBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}