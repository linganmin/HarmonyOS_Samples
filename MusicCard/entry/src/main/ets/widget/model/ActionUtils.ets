/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CallMethod, ENTRY_ABILITY, FormCarAction, PlayActionType, RouterType } from './FormCardConstant';

class ActionUtils {
  /**
   * card music play action
   * @param component
   * @param type '0':pause '1'：play '2'：previous '3'：next
   * @param formId
   */
  // [Start play_by_action]
  // [Start dynamic_lyrics_play_pause_control]
  // [Start music_control_card_achieve]
  // src/main/ets/widget/model/ActionUtils.ets
  public playByAction(component: Object, type: PlayActionType, formId: string) {
    postCardAction(component, {
      action: FormCarAction.CALL,
      abilityName: ENTRY_ABILITY,
      params: {
        method: CallMethod.PLAY_BY_ACTION,
        playActionType: type,
        formId: formId,
      },
    });
  }

  // [End music_control_card_achieve]
  // [End dynamic_lyrics_play_pause_control]

  // [End play_by_action]

  // [Start update_control_cardaction]
  // src/main/ets/widget/model/ActionUtils.ets
  public updateControlCardAction(component: Object, formId: string) {
    postCardAction(component, {
      action: FormCarAction.CALL,
      abilityName: ENTRY_ABILITY,
      params: {
        method: CallMethod.REQUEST_UPDATE_CARD,
        formId: formId,
      },
    });
  }

  // [End update_control_cardaction]

  /**
   * card collect action
   * @param component card component
   * @param type '0':uncollected '1':collected
   * @param formId form id
   * @param songId song id
   */
  // [Start collect_action]
  // src/main/ets/widget/model/ActionUtils.ets
  collectAction(component: Object, type: string, formId: string, songId: string) {
    postCardAction(component, {
      action: FormCarAction.CALL,
      abilityName: ENTRY_ABILITY,
      params: {
        method: CallMethod.COLLECT_ACTION,
        collectActionType: type,
        formId: formId,
        songId: songId,
      },
    });
  }

  // [End collect_action]

  // [Start jump_play_page]
  // src/main/ets/widget/model/ActionUtils.ets
  jumpPlayPage(component: Object) {
    postCardAction(component, {
      action: FormCarAction.ROUTER,
      abilityName: ENTRY_ABILITY,
      params: {
        type: RouterType.PLAYER,
      },
    });
  }

  // [End jump_play_page]

  jumpApp(component: Object) {
    postCardAction(component, {
      action: FormCarAction.ROUTER,
      abilityName: ENTRY_ABILITY,
    });
  }
}

export default new ActionUtils();
