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

import { common } from '@kit.AbilityKit';
import { request } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../constants/Constants';
import { ProgressButton } from './ProgressButton';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

const TAG = 'FileDownloadItem';
const BYTE_CONVERSION: number = 1024;
const context = uiContext!.getHostContext()! as common.UIAbilityContext;

function getFileNameFromUrl(url: string): string {
  const segments = url.split('/');
  let tmp = segments.pop() || '';
  if (tmp.indexOf('?') != -1) {
    return tmp.split('?')[0];
  }
  return tmp;
}

@Component
export struct FileDownloadItem {
  @State downloadConfig: request.agent.Config = { action: request.agent.Action.DOWNLOAD, url: '' };
  @State fileName: string = '';
  @State textState: string | Resource = "";
  @Link @Watch('onDownLoadUpdated') isStartAllDownload: boolean;
  private downloadTask: request.agent.Task | undefined = undefined;
  @Link downloadCount: number;
  @Link downloadFailCount: number;
  @State isShow: boolean = false;
  @State downloading: boolean = false;
  @State sFileSize: string | number = "-";
  @State nFileSize: number = 0;
  @State sCurrentDownloadSize: string = "-";
  @State @Watch('updateProgress') nCurrentDownloadSize: number = 0;
  @State progress: number = 0;
  @State isPaused: boolean = false;

  // [Start callback]
  private completedCallback = (progress: request.agent.Progress) => {
    this.textState = $r("app.string.download_completed");
    if (this.sFileSize === -1) {
      this.sFileSize = this.sCurrentDownloadSize
      this.nCurrentDownloadSize = 1;
    }
    this.downloadCount--;
  }
  // [End callback]
  private failedCallback = (progress: request.agent.Progress) => {
    this.textState = $r("app.string.download_fail");
    this.downloadFailCount++;
    if (this.downloadFailCount === this.downloadCount) {
      this.isStartAllDownload = false;
    }
    if (this.downloadTask) {
      request.agent.show(this.downloadTask.tid, (err: Error, taskInfo: request.agent.TaskInfo) => {
        if (err) {
          hilog.error(0x0000, TAG, 'agent show error:', err);
          return;
        }
      });
    }
  }
  private pauseCallback = (progress: request.agent.Progress) => {
    this.isPaused = true;
    this.downloading = false;
    this.textState = $r("app.string.paused");
  }
  private resumeCallback = (progress: request.agent.Progress) => {
    this.isPaused = false;
    this.textState = $r("app.string.downloading");
    this.downloading = true;
  }
  private progressCallback = (progress: request.agent.Progress) => {
    this.textState = $r("app.string.downloading");
    this.downloading = true;
    this.isShow = true;
    if (this.downloadTask) {
      if (this.sFileSize === '-') {
        if (progress.sizes[0] === -1) {
          this.sFileSize = -1;
          this.nCurrentDownloadSize = 0;
          this.nFileSize = 1;
        } else {
          this.nFileSize = progress.sizes[0];
          this.sFileSize = (progress.sizes[0] / BYTE_CONVERSION).toFixed() + 'kb';
          this.nCurrentDownloadSize = progress.processed;
        }
      } else if (this.sFileSize === -1) {
        hilog.info(0x0000, TAG, 'file size unknown');
      } else {
        this.nCurrentDownloadSize = progress.processed;
      }
      this.sCurrentDownloadSize = (progress.processed / BYTE_CONVERSION).toFixed() + 'kb';
    }
  }
  private responseCallback = (response: request.agent.HttpResponse) => {
    hilog.info(0x0000, TAG, 'response:' + response.statusCode);
  };

  updateProgress() {
    setTimeout(() => {
      if (this.textState == $r("app.string.paused")) {
        this.isPaused = true;
        return;
      }
      let tmp = this.nCurrentDownloadSize / this.nFileSize * 100;
      if (tmp <= this.progress) {
        return;
      }
      this.progress = tmp;
    }, 10)
  }

  aboutToAppear(): void {
    this.fileName = getFileNameFromUrl(this.downloadConfig.url);
  }

  onDownLoadUpdated(): void {
    if (this.isStartAllDownload) {
      if (this.textState === $r("app.string.download_fail")) {
        this.downloadTask = undefined;
        this.isShow = false;
        this.textState = "";
      }
      this.startDownload();
    } else {
      if (this.downloadFailCount > 0 && this.downloadFailCount === this.downloadCount) {
        this.downloadFailCount = 0;
      } else {
        this.pauseDownload();
      }
    }
  }

  startDownload(): void {
    if (this.downloadTask === undefined) {
      // [Start create]
      request.agent.create(context, this.downloadConfig).then((task: request.agent.Task) => {
        task.on('completed', this.completedCallback);
        task.on('failed', this.failedCallback);
        task.on('pause', this.pauseCallback);
        task.on('resume', this.resumeCallback);
        task.on('progress', this.progressCallback);
        task.on('response', this.responseCallback);

        // [Start start]
        task.start().then(() => {
          this.downloadTask = task;
        }).catch((err: Error) => {
          hilog.error(0x0000, TAG, 'task start error:', err);
        })
        // [End start]
      }).catch((err: Error) => {
        hilog.error(0x0000, TAG, 'create error:', err);
      });
      // [End create]
    } else {
      this.resumeDownload();
    }
  }

  // [Start download]
  pauseOrResumeDownload(): void {
    if (this.downloadTask) {
      request.agent.show(this.downloadTask.tid, (err: Error, taskInfo: request.agent.TaskInfo) => {
        if (err) {
          hilog.error(0x0000, TAG, 'agent show error:', err);
          return;
        }
        if (taskInfo.progress.state === request.agent.State.PAUSED) {
          this.resumeDownload();
        } else {
          this.pauseDownload();
        }
      });
    }
  }

  pauseDownload(): void {
    if (this.downloadTask) {
      request.agent.show(this.downloadTask.tid, (err: Error, taskInfo: request.agent.TaskInfo) => {
        if (err) {
          hilog.error(0x0000, TAG, 'agent show error:', err);
          return;
        }
        if (this.downloadTask && (taskInfo.progress.state === request.agent.State.WAITING || taskInfo.progress.state
          === request.agent.State.RUNNING || taskInfo.progress.state === request.agent.State.RETRYING)) {
          this.downloadTask.pause().then(() => {
          }).catch((err: Error) => {
            hilog.error(0x0000, TAG, 'task pause error:', err);
          });
        }
      });
    }
  }

  resumeDownload(): void {
    if (this.downloadTask) {
      request.agent.show(this.downloadTask.tid, (err: Error, taskInfo: request.agent.TaskInfo) => {
        if (err) {
          hilog.error(0x0000, TAG, 'agent show error:', err);
          return;
        }
        if (this.downloadTask && taskInfo.progress.state === request.agent.State.PAUSED) {
          this.downloadTask.resume().then(() => {
          }).catch((err: Error) => {
            hilog.error(0x0000, TAG, 'task resume error:', err);
          });
        }
      });
    }
  }
  // [End download]

  build() {
    RelativeContainer() {
      Image($r('app.media.multiple_files_download_file'))
        .height($r("app.integer.multiple_files_download_image_size"))
        .width($r("app.integer.multiple_files_download_image_size"))
        .id('fileImage')
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })

      Text(this.fileName)
        .fontSize($r("app.integer.multiple_files_download_text_font_size"))
        .padding({ left: $r("app.integer.multiple_files_download_padding") })
        .alignRules({
          left: { anchor: 'fileImage', align: HorizontalAlign.End },
          top: { anchor: 'fileImage', align: VerticalAlign.Top },
        })
        .fontWeight(FontWeight.Medium)
        .margin({ top: $r('app.integer.item_name_top_margin') })
        .id('fileName')

      ProgressButton({
        paused: this.isPaused,
        progress: this.progress,
        progressButtonWidth: $r('app.integer.progress_btn_width'),
        content: this.textState,
        enable: true,
        clickCallback: () => {
          this.pauseOrResumeDownload();
        }
      })
        .visibility(this.isShow ? Visibility.Visible : Visibility.Hidden)
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })

      Text(this.sCurrentDownloadSize + "/" + this.sFileSize)
        .fontSize($r('app.integer.multiple_files_download_text_font_size_fourteen'))
        .width($r('app.string.multiple_files_download_text_width'))
        .fontColor($r('app.color.multiple_files_download_text_font_color'))
        .margin({ top: $r("app.integer.multiple_files_download_margin_top") })
        .padding({ left: $r("app.integer.multiple_files_download_padding") })
        .alignRules({
          top: { anchor: 'fileName', align: VerticalAlign.Bottom },
          left: { anchor: 'fileImage', align: HorizontalAlign.End }
        })
        .id('downloadVal')

    }
    .height($r('app.integer.item_height'))
    .margin({ left: Constants.MARGIN_SIXTEEN, right: Constants.MARGIN_SIXTEEN })
    .padding({ left: Constants.PADDING_TWELVE, right: Constants.PADDING_TWELVE })
  }
}