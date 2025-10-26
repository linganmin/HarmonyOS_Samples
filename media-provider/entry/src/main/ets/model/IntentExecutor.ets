/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { insightIntent, InsightIntentExecutor } from '@kit.AbilityKit';
import Constants from '../common/constants/Constants';
import Logger from '../common/utils/Logger';
import { ProviderFeature } from '../viewmodel/ProviderManager';

const TAG: string = 'IntentExecutorImpl';

/**
 * The intent framework customizes the IntentParam format.
 */
class Items {
  entityId: string;

  constructor(entityId: string) {
    this.entityId = entityId;
  }
}

/**
 * Intent startup entry. The implementation is for reference only.
 */
export default class IntentExecutor extends InsightIntentExecutor {
  private providerFeature: ProviderFeature | undefined = undefined;
  private isInit: Boolean = false;

  /**
   * Playback control entry for starting a playlist. The app is started in the background to play the playlist.
   */
  async onExecuteInUIAbilityBackgroundMode(intentName: string, intentParam: Record<string, Object>):
    Promise<insightIntent.ExecuteResult> {
    // The playback needs to be started in the background.
    // In addition to initializing resources, you need to apply for a long-time task.
    if (!this.isInit) {
      this.providerFeature = await ProviderFeature.getInstance();
      // Apply for a long-time background playback task.
      this.providerFeature!.startContinuousTask();
    }

    // Process the startup parameter returned by the interface.
    // The intent name of the historical playlist is PlayMusicList.
    let executeResult: insightIntent.ExecuteResult = {
      code: Constants.ERROR_INVALID_INTENT_NAME,
      result: {
        'error': 'invalid intent name',
        'intentName': intentName
      }
    };
    switch (intentName) {
      case Constants.INTENT_NAME_PLAY_MUSIC:
      case Constants.INTENT_NAME_PLAY_MUSIC_LIST:
        Logger.info(TAG, 'intent name:', intentName);
        executeResult = await this.playMusicList(intentParam);
        break;
      default:
        Logger.error(TAG, 'invalid intent name', intentName);
        break;
    }
    return executeResult;
  }

  async playMusicList(intentParam: Record<string, Object>) {
    Logger.info(TAG, ' playMusicList :' + JSON.stringify(intentParam));
    let items: Items[] = intentParam['items'] as Items[];
    Logger.info(TAG, ' playMusicList items[0] :' + items[0].entityId + ' items[entityId] :' + items['entityId']);
    if (items[0].entityId.length === 0) {
      // If the value of entityId is '', the application determines whether to play historical content or recommended content.
      // The current template selects to play the first playlist.
      this.playItemWithEntityId(Constants.ENTITY_ID_FIRST_PLAY_LIST);
    } else {
      // If the value of entityId is not '',
      // the value of avMetadata.avQueueId reported by the app is used, indicating that the playlist is specified.
      this.playItemWithEntityId(items[0].entityId);
    }

    let result: insightIntent.ExecuteResult = {
      code: 0,
      result: {
        message: 'Play music list succeed.'
      }
    };
    return result;
  }

  async playItemWithEntityId(avQueueId: string) {
    // Directly plays a specified playlist.
    this.providerFeature!.handleNewPlayListItem(avQueueId);
  }
}