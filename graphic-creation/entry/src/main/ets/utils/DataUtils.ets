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
import Logger from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

export class DataUtils {
  public static readonly tag: string = 'DataUtils';
  public static context: common.UIAbilityContext;

  static fromResToNumber(resource: Resource): number {
    let num = 0;
    if (resource === undefined) {
      Logger.error(DataUtils.tag, 'fromResToNumber resource is undefined!');
      return num;
    }
    try {
      num = DataUtils.context.resourceManager.getNumber(resource.id);
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      Logger.info(DataUtils.tag, `fromResToNumber failed, error code: ${code}, message: ${message}.`);
    }
    return num;
  }

  static fromResToString(resource: Resource): string {
    let str = '';
    if (resource === undefined) {
      Logger.error(DataUtils.tag, 'fromResToString resource is undefined!');
      return str;
    }
    try {
      str = DataUtils.context.resourceManager.getStringSync(resource.id);
      Logger.info(DataUtils.tag, `fromResToString str: ${str}.`);
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      Logger.info(DataUtils.tag, `fromResToString failed, error code: ${code}, message: ${message}.`);
    }
    return str;
  }
}