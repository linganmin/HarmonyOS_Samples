/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

// [Start router]
import { insightIntent } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export default class PageNavigateHandler {
  async execute(): Promise<insightIntent.ExecuteResult> {
    try {
      // Execute page redirection.
      let uiContext: UIContext | null | undefined = null;
      uiContext = AppStorage.get('uiContext');
      uiContext?.getRouter().pushUrl({ url: 'pages/SecondPage' })
        .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag',`pushUrl failed, Code:${err.code}, message:${err.message}`);
      })

      return {
        code: 0,
        result: {
          status: 'success',
          message: 'Navigation successful',
          targetPage: 'SecondPage'
        }
      };
    } catch (error) {
      throw new Error(`Page navigation failed: ${(error as BusinessError).message}`);
    }
  }
}
// [End router]