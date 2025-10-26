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

import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function getStringArray(uiContext: UIContext, resource: Resource): Promise<Array<string>> {
  let menuList: Array<string> = [];
  let context = uiContext.getHostContext() as common.UIAbilityContext;
  try {
    menuList = await context.resourceManager.getStringArrayValue(resource.id);
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'getStringArray', `getStringArrayValue failed, error code=${err.code}, message=${err.message}`);
  }
  return menuList;
}

export function getString(uiContext: UIContext, resource: Resource): string {
  let result: string = '';
  let context = uiContext.getHostContext() as common.UIAbilityContext;
  try {
    result = context.resourceManager.getStringSync(resource.id);
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'getString', `getStringSync failed, error code=${err.code}, message=${err.message}`);
  }
  return result;
}
