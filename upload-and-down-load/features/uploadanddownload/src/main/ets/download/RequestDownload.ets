/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

// [Start common1]
import { common } from '@kit.AbilityKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
// [End common1]
import { logger } from '../utils/Logger';
import {
  TOAST_BOTTOM,
  TASK_MAX,
  TASK_PAUSE_MSG,
  TASK_NET_PAUSE_MSG,
  TASK_RESUME_MSG,
  TASK_NET_RESUME_MSG
} from '../utils/Constants';

const TAG: string = 'RequestDownload';
let isNetPause = false;

// [Start request_down_load]
// [Start requestClass]
class RequestDownload {
  // [StartExclude requestClass]
  private context: common.UIAbilityContext | undefined = undefined;
  // [EndExclude requestClass]
  // [Start wait_list]
  private waitList: Array<string[]> = [];
  private downloadTask: request.agent.Task | undefined = undefined;
  // [StartExclude requestClass]
  // [End wait_list]
  // [StartExclude progress_callback]
  progressCallback: Function | undefined = undefined;
  completedCallback: Function | undefined = undefined;
  failedCallback: Function | undefined = undefined;

  constructor() {
    setInterval(() => {
      this.flushBackgroundTask()
    }, 2000);
  }

  async downloadFilesBackground(folder: string, files: Array<string>) {
    logger.info(TAG, 'downloadFiles');
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
    this.context = uiContext?.getHostContext() as common.UIAbilityContext;
    files.forEach((item: string) => {
      this.waitList.push([folder, item]);
    });
  }

  async flushBackgroundTask() {
    try {
      let tasks = await request.agent.search({
        state: request.agent.State.RUNNING
      });
      if (tasks.length < TASK_MAX && this.waitList.length > 0) {
        let downloadList: Array<string[]> = [];
        if (this.waitList.length <= TASK_MAX - tasks.length) {
          downloadList = this.waitList;
          this.waitList = [];
        } else {
          downloadList = this.waitList.slice(0, TASK_MAX - tasks.length);
          this.waitList = this.waitList.slice(TASK_MAX - tasks.length, this.waitList.length);
        }
        logger.info(TAG, `this.waitList = ${JSON.stringify(this.waitList)}`);
        this.createBackgroundTask(downloadList);
      }
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `flushBackgroundTask failed, error code=${err.code}, message=${err.message}`);
    }
  }

  // [Start create_background_task]
  async createBackgroundTask(downloadList: Array<string[]>) {
    if (this.context === undefined) {
      return;
    }
    for (let i = 0; i < downloadList.length; i++) {
      try {
        let splitUrl = downloadList[i][1].split('//')[1].split('/');
        let downloadConfig: request.agent.Config = {
          action: request.agent.Action.DOWNLOAD,
          url: downloadList[i][1],
          method: 'POST',
          title: 'download',
          mode: request.agent.Mode.BACKGROUND,
          network: request.agent.Network.ANY,
          saveas: `./${downloadList[i][0]}/${splitUrl[splitUrl.length-1]}`,
          overwrite: true,
          gauge: true
        }
        let downTask = await request.agent.create(this.context, downloadConfig);
        // [Start down_task1]
        await downTask.start();
        // [Start down_task1]
      } catch (error) {
        let err = error as BusinessError;
        logger.error(TAG, `task  err code=${err.code}, message=${err.message}`);
        this.waitList.push(downloadList[i]);
      }
    }
  }
  // [End create_background_task]

  async pause() {
    if (this.downloadTask) {
      try {
        let taskInfo = await request.agent.show(this.downloadTask.tid);
        logger.info(TAG, `task pause, taskInfo  = ${JSON.stringify(taskInfo)}`);
        await this.downloadTask.pause();
      } catch (error) {
        let err = error as BusinessError;
        logger.error(TAG, `resume failed, error code=${err.code}, message=${err.message}`);
      }
    }
  }

  async resume() {
    if (this.downloadTask) {
      try {
        let taskInfo = await request.agent.show(this.downloadTask.tid);
        logger.info(TAG, `task resume, taskInfo  = ${JSON.stringify(taskInfo)}`);
        await this.downloadTask.resume();
      } catch (error) {
        let err = error as BusinessError;
        logger.error(TAG, `resume failed, error code=${err.code}, message=${err.message}`);
      }
    }
  }

  async downloadFile(folder: string, url: string, callback: (progress: number, isSuccess: boolean) => void) {
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
    try {
      logger.info(TAG, 'downloadFile');
      // Found an ongoing download task, prompted and returned.
      let tasks = await request.agent.search({
        state: request.agent.State.RUNNING,
        action: request.agent.Action.DOWNLOAD,
        mode: request.agent.Mode.FOREGROUND
      });
      if (tasks.length > 0) {
        uiContext?.getPromptAction().showToast({
          message: $r('app.string.have_download_task_tips'),
          bottom: TOAST_BOTTOM
        });
        return;
      }
    } catch (error) {
      let err = error as BusinessError;
      logger.error(TAG, `downloadFile failed, error code=${err.code}, message=${err.message}`);
    }

    try {
      let context: common.UIAbilityContext = uiContext?.getHostContext() as common.UIAbilityContext;
      let splitUrl = url.split('//')[1].split('/');
      let downloadConfig: request.agent.Config = {
        action: request.agent.Action.DOWNLOAD,
        url: url,
        method: 'GET',
        title: 'download',
        mode: request.agent.Mode.BACKGROUND,
        retry: true,
        network: request.agent.Network.ANY,
        saveas: `./${folder}/${splitUrl[splitUrl.length-1]}`,
        overwrite: true
      }
      logger.info(TAG, `downloadFile, downloadConfig = ${JSON.stringify(downloadConfig)}`);
      this.downloadTask = await request.agent.create(context, downloadConfig);
      this.downloadTask.on('progress', this.progressCallback = (progress: request.agent.Progress) => {
        logger.info(TAG, `progress,  progress = ${progress.processed} ${progress.state}`);
        let processed = Number(progress.processed.toString()).valueOf();
        let size = progress.sizes[0];
        let process: number = Math.floor(processed / size * 100);
        if (process < 100) {
          callback(process, false);
        }
      })
      this.downloadTask.on('completed', this.completedCallback = (progress: request.agent.Progress) => {
        logger.info(TAG, `download complete, file= ${url}, progress = ${progress.processed}`);
        callback(100, true);
        this.deleteTask();
      })
      this.downloadTask.on('pause', this.failedCallback = async (progress: request.agent.Progress) => {
        if (this.downloadTask) {
          let taskInfo = await request.agent.show(this.downloadTask.tid);
          logger.info(TAG,
            `pause,  resean = ${taskInfo.reason}, progress = ${progress.processed}, faults = ${JSON.stringify(taskInfo.faults)}`);
          isNetPause = taskInfo.faults === 0;
          if (isNetPause) {
            callback(TASK_NET_PAUSE_MSG, isNetPause);
          } else {
            callback(TASK_PAUSE_MSG, isNetPause);
          }
        }
      })
      this.downloadTask.on('resume', this.failedCallback = async (progress: request.agent.Progress) => {
        if (this.downloadTask) {
          let taskInfo = await request.agent.show(this.downloadTask.tid);
          logger.info(TAG,
            `resume,  resean = ${taskInfo.reason}, progress = ${progress.processed}, faults = ${JSON.stringify(taskInfo.faults)}`);
          if (isNetPause) {
            isNetPause = false;
            callback(TASK_NET_RESUME_MSG, isNetPause);
          } else {
            callback(TASK_RESUME_MSG, isNetPause);
          }
        }
      })
      this.downloadTask.on('failed', this.failedCallback = async (progress: request.agent.Progress) => {
        if (this.downloadTask) {
          let taskInfo = await request.agent.show(this.downloadTask.tid);
          logger.info(TAG,
            `fail,  resean = ${taskInfo.reason}, progress = ${progress.processed}, faults = ${JSON.stringify(taskInfo.faults)}`);
        }
        callback(100, false);
        this.deleteTask();
      })
      await this.downloadTask.start();
    } catch (err) {
      logger.error(TAG, `task  err, err  = ${JSON.stringify(err)}`);
      callback(100, false);
    }
  }

  async deleteTask() {
    if (this.downloadTask) {
      try {
        this.downloadTask.off('progress');
        this.progressCallback = undefined;
        this.downloadTask.off('completed');
        this.completedCallback = undefined
        this.downloadTask.off('failed');
        this.failedCallback = undefined
        await request.agent.remove(this.downloadTask.tid);
      } catch (err) {
        logger.info(TAG, `deleteTask fail, err= ${JSON.stringify(err)}`);
      }
    }
    this.downloadTask = undefined;
  }

  // [EndExclude progress_callback]
  // [EndExclude requestClass]
}

// [End request_down_load]
// [End requestClass]

export const requestDownload = new RequestDownload();