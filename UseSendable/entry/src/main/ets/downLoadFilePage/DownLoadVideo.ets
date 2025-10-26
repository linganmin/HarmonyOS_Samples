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

import { taskpool } from '@kit.ArkTS';
import { DownLoadVideoInfo } from './model/DownLoadVideoInfo';
import { DownLoadCommandEnum } from './model/CommEnum';
import { Constants } from '../constants/Constants';
import Logger from '../utils/Logger';

@Concurrent
export function DownLoadVideo(dvi: DownLoadVideoInfo): void {
  let start: number;
  while (dvi.downLoadProgress < Constants.MAX_DOWN_PROGRESS) {
    start = Date.now();
    while (Date.now() - start < Constants.DELAY_TIME) {
      // Simulated wait 1s.
    }
    dvi.increaseDownLoadProgress();
    try {
      taskpool.Task.sendData('UPDATE_DOWNLOAD_PROGRESS');
    } catch (err) {
      Logger.error(`SendData failed. Cause code: ${err.code}, message: ${err.message}`);
    }
    // The thread receives a stop download notification.
    if (dvi.command === DownLoadCommandEnum.STOP_DOWNLOADING) {
      return;
    }
  }
  dvi.videoInfo.long = Constants.VIDEO_INFO_LONG;
}