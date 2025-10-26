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

import { hilog } from "@kit.PerformanceAnalysisKit";

const TAG = 'Utils';

export function getResourceString(resource: Resource, context: UIContext): string {
  let result: string = '';
  try {
    result = context.getHostContext()?.resourceManager.getStringSync(resource.id) || '';
  } catch (e) {
    hilog.error(0x0000, TAG, `[getResourceString]getStringSync failed, error:${JSON.stringify(e)}.`);
  }
  return result;
}

type resourceType = 'string' | 'media'

export function genResourceArray(length: number, prefix: string, type: resourceType = 'string'): Resource[] {
  return Array.from({ length }, (_: undefined, index) => {
    return $r(`app.${type}.${prefix}_${index + 1}`);
  });
}