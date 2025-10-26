/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { util } from '@kit.ArkTS';
import { Caption } from '../model/ViewModel';
import { Constant } from '../constants/Constants';

export function uint8ArrayToStr(uint8Array: Uint8Array): string {
  const textDecoder = util.TextDecoder.create("utf-8");
  return textDecoder.decodeToString(uint8Array, { stream: false });
}

function getSecondTime(timeMatch: number[], i: number) {
  return timeMatch[i+1] * Constant.SECOND_TIME + timeMatch[i+2] * Constant.MINUTE_TIME + timeMatch[i+3];
}

export function srtToJson(srt: string): Caption[] {
  const lines = srt.split('\n');
  const result: Caption[] = [];

  for (let i = 0; i < lines.length; i += 4) {
    if (!lines[i].trim()) {
      continue;
    }

    const reg = new RegExp(/(\d{2}):(\d{2}):(\d{2}),(\d{3}) --> (\d{2}):(\d{2}):(\d{2}),(\d{3})/);
    const timeMatch = lines[i+1].match(reg)?.map(time => parseInt(time));

    if (!timeMatch) {
      continue;
    }
    const startTime = getSecondTime(timeMatch, 0);
    const endTime = getSecondTime(timeMatch, 4);

    result.push({
      startTime,
      endTime,
      text: lines[i+2]
    });
  }
  return result;
}