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

import { webview } from '@kit.ArkWeb';
import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../common/Constants';

interface ControllerManager {
  registerController(name: string, controller: webview.WebviewController): void;

  getController(name: string): webview.WebviewController | undefined;
}

abstract class AbstractWebDownloadManager {
  abstract start(controllerName: string, path: string, url: string): void;

  abstract pause(): void;

  abstract resume(): void;

  abstract cancel(): void;
}

@Observed
// [Start manage]
export class WebDownloadManager extends AbstractWebDownloadManager
implements ControllerManager {
  // [StartExclude manage]
  downloadSpeed: number = 0;
  downloadProgress: number = 0;
  taskStatus: webview.WebDownloadState = webview.WebDownloadState.IN_PROGRESS;
  private static instance: WebDownloadManager;
  private sourcePath: string = '';
  private failedData: Uint8Array = new Uint8Array();
  private controllers: Map<string, webview.WebviewController> = new Map();
  private currentTask: webview.WebDownloadItem = new webview.WebDownloadItem();
  // [EndExclude manage]
  // Define the download delegate instance.
  private delegate: webview.WebDownloadDelegate = new webview.WebDownloadDelegate();

  // [StartExclude manage]
  private constructor() {
    super()
  }

  public static getInstance() {
    if (!WebDownloadManager.instance) {
      WebDownloadManager.instance = new WebDownloadManager();
    }
    return WebDownloadManager.instance;
  }

  // [EndExclude manage]
  public start(controllerName: string, path: string, url: string): Promise<string> {
    return new Promise((resolve, reject) => {
      const controller = this.getController(controllerName);
      // [StartExclude manage]
      // [Start gate]
      this.delegate.onBeforeDownload((webDownloadItem: webview.WebDownloadItem) => {
        this.currentTask = webDownloadItem;
        this.sourcePath = path + '/' + webDownloadItem.getSuggestedFileName();
        this.currentTask.start(this.sourcePath);
        // Specify the download path before downloading.
        this.taskStatus = webDownloadItem.getState();
      })
      // [End gate]
      // [Start update]
      this.delegate.onDownloadUpdated((webDownloadItem: webview.WebDownloadItem) => {
        this.currentTask = webDownloadItem;
        // maintain download progress.
        this.downloadProgress = webDownloadItem.getPercentComplete();
        this.downloadSpeed = webDownloadItem.getCurrentSpeed();
        this.taskStatus = webDownloadItem.getState();
      })
      // [End update]
      // [Start fail2]
      this.delegate.onDownloadFailed((webDownloadItem: webview.WebDownloadItem) => {
        // Serialize the download data when the download fails to resume the download.
        this.failedData = webDownloadItem.serialize();
        this.taskStatus = webDownloadItem.getState();
        reject(new Error('download failed'));
      })
      // [End fail2]
      // [Start finish1]
      this.delegate.onDownloadFinish((webDownloadItem: webview.WebDownloadItem) => {
        this.taskStatus = webDownloadItem.getState();
        resolve(this.sourcePath);
      })
      // [End finish1]
      try {
        // [EndExclude manage]
        // Associate the download delegate with the webview controller.
        controller?.setDownloadDelegate(this.delegate);
        // [StartExclude manage]
        // [Start url2]
        controller?.startDownload(url);
        // [End url2]
        // [EndExclude manage]
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
          error.code, error.message);
      }
    });
  }

  // [StartExclude manage]
  public pause() {
    const state = this.currentTask.getState();
    if (state === webview.WebDownloadState.IN_PROGRESS) {
      try {
        this.currentTask.pause();
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
          error.code, error.message);
      }
    }
  }

  public unpause() {
    const state = this.currentTask.getState();
    if (state === webview.WebDownloadState.PAUSED) {
      try {
        this.currentTask.resume();
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
          error.code, error.message);
      }
    }
  }
  // [Start resume]
  // Provides an external interface for resuming downloads.
  public resume() {
    const state = this.currentTask.getState();
    if (state === webview.WebDownloadState.CANCELED) {
      webview.WebDownloadManager.setDownloadDelegate(this.delegate);
      try {
        webview.WebDownloadManager.resumeDownload(webview.WebDownloadItem.deserialize(this.failedData));
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
          error.code, error.message);
      }
    }
  }
  // [End resume]

  public cancel(): void {
    try {
      this.currentTask.cancel();
      this.taskStatus = this.currentTask.getState();
      this.deleteFile();
    } catch (e) {
      hilog.error(0x000, Constants.TAG, `failed to cancel：${JSON.stringify(e)}`);
    }
  }

  public clearProgress() {
    this.downloadSpeed = 0;
    this.downloadProgress = 0;
  }

  public deleteFile() {
    try {
      if (fileIo.accessSync(this.sourcePath)) {
        fileIo.unlink(this.sourcePath).catch((error: BusinessError<void>) => {
          hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
            error.code, error.message);
        });
      }
    } catch (error) {
      hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
        error.code, error.message);
    }
  }

  public registerController(name: string, controller: webview.WebviewController): void {
    this.controllers.set(name, controller);
  }

  public getController(name: string): webview.WebviewController | undefined {
    return this.controllers.get(name);
  }
  // [EndExclude manage]
}
// [End manage]