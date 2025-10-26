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

import { InsightIntentExecutor, insightIntent } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import CommonConstants from '../common/constants/CommonConstants';
import { Logger } from '../common/utils/Logger';

/**
 * Entry for insight intent execution.
 */
export default class IntentExecutorImpl extends InsightIntentExecutor {
  /**
   * Called when a UIAbility executes the insight intent in the foreground.
   * @param { string } intentName - Indicates the insight intent name.
   * @param { Record<string, Object> } intentParam - Indicates the insight intent parameters.
   * @param { window.WindowStage } pageLoader - Indicates the page loader.
   * @returns { Promise<insightIntent.ExecuteResult> } The result of insight intent execution.
   */
  async onExecuteInUIAbilityForegroundMode(intentName: string, intentParam: Record<string, object>,
    pageLoader: window.WindowStage): Promise<insightIntent.ExecuteResult> {
    const result: insightIntent.ExecuteResult = {
      code: 0
    };
    pageLoader.getMainWindow().then((windowClass: window.Window) => {
      // emit intent execute event and entityId (game id)
      windowClass.getUIContext().getHostContext()?.eventHub.emit(CommonConstants.PLAY_GAME_EVENT, intentParam.entityId);
    }).catch((err: BusinessError) => {
      Logger.error('intent executor', 'Failed to obtain the main window. Cause: ' + JSON.stringify(err));
    })
    return Promise.resolve(result);
  }
}