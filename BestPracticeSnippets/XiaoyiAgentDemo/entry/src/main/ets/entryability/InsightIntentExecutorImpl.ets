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

// [Start executorImpl]
import { insightIntent, InsightIntentExecutor } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import AudioPlayHandler from './intentHandlers/AudioPlayHandler';
import TextGetHandler from './intentHandlers/TextGetHandler';
import PageNavigateHandler from './intentHandlers/PageNavigateHandler';
import { hilog } from '@kit.PerformanceAnalysisKit';

export default class InsightIntentExecutorImpl extends InsightIntentExecutor {
  // Instruction implementation class.
  private audioHandler = new AudioPlayHandler();
  private textHandler = new TextGetHandler();
  private pageHandler = new PageNavigateHandler();

  // Intention execution method for backend execution.
  async onExecuteInUIAbilityBackgroundMode(
    intentName: string,
    params: Record<string, object>
  ): Promise<insightIntent.ExecuteResult> {

    try {
      switch (intentName) {
        // Play audio intention.
        case 'PlayHiddenAudio':
          const stringParam: Record<string, string> = this.convertToRecord(params);
          return this.audioHandler.execute(stringParam);

        // Obtain audio name intent.
        case 'GetAudioName':
          return this.textHandler.execute();

        default:
          return {
            code: -1,
            result: {
              'status': 'failed',
              'message': `not valid intent name, ${intentName}`
            }
          };
      }
    } catch (error) {
      return {
        code: -2,
        result: {
          'status': 'failed',
          'message': `Intent execution failed: ${(error as BusinessError).message}`
        }
      };
    }
  }

  private convertToRecord(origin: Record<string, object>): Record<string, string> {
    const result: Record<string, string> = {};
    Object.keys(origin).forEach(key => {
      result[key] = String(origin[key]);
    });

    return result;
  }

  // Execution method of backend execution intention.
  async onExecuteInUIAbilityForegroundMode(name: string, param: Record<string, Object>, pageLoader: window.WindowStage):
    Promise<insightIntent.ExecuteResult> {
    switch (name) {
      // Open the second page intention.
      case 'OpenSecondPage':
        return this.pageHandler.execute();
      default:
        pageLoader.loadContent('pages/MainPage')
          .catch((error: BusinessError) => {
            hilog.error(0x000, 'testTag', `loadContent failed. code=${error.code}, message=${error.message}`);
          })
        break;
    }
    return Promise.resolve({
      code: -1,
      result: {
        message: 'unknown intent'
      }
    } as insightIntent.ExecuteResult)
  }
}

// [End executorImpl]