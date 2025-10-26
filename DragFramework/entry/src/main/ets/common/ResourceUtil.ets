/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { JSON, util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = '[ResourceUtil]';

export class ResourceUtil {
  /**
   * Get content from the raw file resource "config.json" by key.
   * @param context The base context of an ability or an application.
   * @param key The Json key value.
   * @returns Return the value of the key.
   */
  public static getRawFileStringByKey(context: Context|undefined, key: ConfigMapKey): string {
    try {
      const result: Uint8Array = context!.resourceManager.getRawFileContentSync('config.json');
      const textDecoder: util.TextDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const content: string = textDecoder.decodeToString(result, { stream: false });
      const jsonContent: ConfigMapData = JSON.parse(content) as ConfigMapData;
      if (JSON.has(jsonContent, key)) {
        const linkUrl: string = ResourceUtil.getDataByKey(jsonContent, key);
        return linkUrl;
      }
      return '';
    } catch (error) {
      hilog.error(0x0000, TAG, `%{public}s`, `Failed to getRawFileContent`);
      return '';
    }
  }

  private static getDataByKey(content: ConfigMapData, key: ConfigMapKey): string {
    if (key === ConfigMapKey.HUAWEI_DEVELOPER_URL) {
      return content.huaweiDeveloperUrl;
    } else if (key === ConfigMapKey.HUAWEI_DEVECO_STUDIO_URL) {
      return content.huaweiDevecoStudioUrl;
    }
    hilog.error(0x0000, TAG, `%{public}s`, `Failed to get uri`);
    return '';
  }
}

export class ConfigMapData {
  public huaweiDeveloperUrl: string = '';
  public huaweiDevecoStudioUrl: string = '';
}

export enum ConfigMapKey {
  HUAWEI_DEVELOPER_URL = 'huaweiDeveloperUrl',
  HUAWEI_DEVECO_STUDIO_URL = 'huaweiDevecoStudioUrl'
}