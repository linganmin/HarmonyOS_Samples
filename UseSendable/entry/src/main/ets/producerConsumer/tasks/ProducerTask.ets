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
import { LogLevelEnum, LongTaskCommandEnum } from '../model/CommEnum';
import { LongTaskController } from '../model/LongTaskController';
import { Constants } from '../../constants/Constants';
import { ShareQueue } from '../model/ShareQueue';
import { LogInfo } from '../model/LogInfo';
import Logger from '../../utils/Logger';

@Concurrent
export async function ProducerTask(taskName: string, sq: ShareQueue<LogInfo>): Promise<void> {
  let logInfo: LogInfo;
  logInfo = new LogInfo(taskName, LogLevelEnum.DEBUGGER, 'Log from' + taskName);
  if (!await sq.offer(logInfo)) {
    Logger.info('ProducerLongTask failed');
  }
  Logger.info('ProducerLongTask finish');
}

@Concurrent
export async function ProducerLongTask(taskName: string,
  sq: ShareQueue<LogInfo>, lct: LongTaskController): Promise<void> {
  let logInfo: LogInfo;
  while (true) {
    if (lct.command === LongTaskCommandEnum.STOP) {
      break;
    }
    let start: number;
    start = Date.now();
    while (Date.now() - start < Constants.TIMESTAMP_INTERVAL) {
      // Simulation wait 0.3s.
    }
    logInfo = new LogInfo(taskName, LogLevelEnum.DEBUGGER, 'Log from:' + taskName);
    if (!await sq.offer(logInfo)) {
      Logger.info('ProducerLongTask failed');
    }
    Logger.info('ProducerLongTask finish');
  }
}

@Concurrent
export async function ConsumerTask(taskName: string, sq: ShareQueue<LogInfo>, cc: LongTaskController): Promise<void> {
  while (true) {
    if (cc.command === LongTaskCommandEnum.STOP) {
      break;
    }
    let logInfo = await sq.poll();
    if (logInfo != null) {
      try {
        taskpool.Task.sendData(logInfo);
      } catch (err) {
        Logger.error(`SendData failed. Cause code: ${err.code}, message: ${err.message}`);
      }
    }
  }
  Logger.info(`ConsumerTask finish, taskName: ${taskName}`);
}