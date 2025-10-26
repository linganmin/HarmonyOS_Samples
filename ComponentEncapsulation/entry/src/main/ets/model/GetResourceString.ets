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
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export function getResourceString(resource: Resource, __this: object): string {
  try {
    return uiContext?.getHostContext()!.resourceManager.getStringSync(resource.id)!;
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'GetResourceString', `getResourceString failed. code=${err.code}, message=${err.message}`);
  }
  return '';
}