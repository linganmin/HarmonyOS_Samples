/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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
import { Logger } from '../utils/Logger';

const TAG = 'CommonUtil';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export function getChunkRanges(totalSize: number, chunkSize: number): number[][] {
  const chunkCount = Math.ceil(totalSize / chunkSize);
  return Array.from({ length: chunkCount }, (_: undefined, index) => {
    const start = index * chunkSize;
    const end = Math.min(start + chunkSize - 1, totalSize - 1);
    return [start, end];
  });
}

export function getProgressPercent(totalSize: number, transferredSize: number) {
  return Number((transferredSize / totalSize * 100).toFixed(2));
}

export function showSuccessMessage(message: string) {
  try {
    uiContext?.getPromptAction().showToast({
      message: message,
      duration: 2000
    });
  } catch (exception) {
    Logger.error(TAG, `showSuccessMessage failed. Code:${exception.code}, message:${exception.message}`);
  }
}

export function showErrorMessage(errMessage: string) {
  try {
    uiContext?.getPromptAction().showToast({
      message: errMessage,
      backgroundColor: 'rgba(232, 64, 38, 0.15)',
      textColor: '#E84026',
      duration: 3000
    });
  } catch (exception) {
    Logger.error(TAG, `showErrorMessage failed. Code:${exception.code}, message:${exception.message}`);
  }
}