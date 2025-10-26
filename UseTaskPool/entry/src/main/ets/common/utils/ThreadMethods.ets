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

import { process } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import DateTimeUtils from '../utils/DateTimeUtils';

const DATETIME: DateTimeUtils = new DateTimeUtils();
const TAG:string = '[UTILS]';

export enum ThreadType {
  main = '[Main] ',
  taskPool = '[TaskPool] ',
  worker = '[Worker] '
}

export function threadExecuteInfo(threadType: ThreadType, info: string): string {
  let value = threadType + info + '\n';
  value += '-tid: ' + process.tid + '\n';
  value += '-time: ' + DATETIME.getTime() + '\n';
  value += '------------------------\n';
  return value;
}

export function timeConsumingTask(time: number) {
  let start = new Date().getTime();
  while (new Date().getTime() - start < time) {
    continue;
  }
  return;
}

export function getResourceString(uiContext: UIContext, resourceName: string): string {
  let res = 'Unknown Title';
  let readRes: string|undefined = undefined;
  try {
    readRes = uiContext.getHostContext()?.resourceManager.getStringByNameSync(resourceName);
  } catch (error) {
    hilog.error(0x0000, TAG, `getStringByNameSync catch error, code: ${error.code}, message: ${error.message}`);
  }
  if (readRes) {
    res = readRes;
  }
  return res;
}