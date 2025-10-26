/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { promptAction, UIContext } from '@kit.ArkUI';
import Logger from '../util/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'AbilityContextController';
const accountId = 100;
const resultCode = 100;
const connectionNumber = 0;
const permissions = [''];

let want = {
  bundleName: 'ohos.samples.stagemodel',
  abilityName: 'JumpAbility',
  moduleName: 'entry'
};

let serviceWant = {
  deviceId: '',
  bundleName: 'ohos.samples.stagemodel',
  abilityName: 'ServiceExtAbility',
};

export default class AbilityContextController {
  private context: common.UIAbilityContext;
  private UIContext: UIContext;

  constructor(context: common.UIAbilityContext, UIContext: UIContext) {
    this.context = context;
    this.UIContext = UIContext;
  }

  private regOnRelease(caller) {
    try {
      caller.onRelease((msg) => {
        Logger.info(TAG, `caller onRelease is called ${msg}`);
      })
      Logger.info(TAG, 'caller register OnRelease succeed');
    } catch (error) {
      Logger.error(TAG, `caller register OnRelease failed with ${error}`);
    }
  }

  // Enables the Ability, which corresponds to the StartServiceAbility of the FA.
  startAbility() {
    this.context.startAbility(want, (error) => {
      Logger.info(TAG, `error.code: ${JSON.stringify(error.code)}`);
    })
  }

  // Starts the capability and returns the execution result when the capability is complete.
  // This parameter corresponds to startAbilityForResult of the FA.
  startAbilityForResult() {
    this.context.startAbilityForResult(
      {
        deviceId: '', bundleName: 'ohos.samples.stagemodel', abilityName: 'JumpAbility'
      },
      (error, result) => {
        Logger.info(TAG, `startAbilityForResult AsyncCallback is called, error.code: ${JSON.stringify(error)}`);
        Logger.info(TAG,
          `startAbilityForResult AsyncCallback is called, result.resultCode: ${JSON.stringify(result.resultCode)}`);
      }
    );
  }

  // This field is used to stop the capability itself, which corresponds to terminateSelf of the FA.
  terminateSelf() {
    this.context.terminateSelf((error) => {
      Logger.info(TAG, `terminateSelf result: ${JSON.stringify(error)}`);
    })
  }

  // This parameter is used together with startAbilityForResult to stop the capability.
  // The value of this parameter is returned to the interface invoker.
  // The value corresponds to terminateSelfWithResult in the FA.
  terminateSelfWithResult() {
    const abilityResult = {
      want,
      resultCode
    };
    this.context.terminateSelfWithResult(abilityResult, (error) => {
      Logger.info(TAG, `terminateSelfWithResult is called: ${JSON.stringify(error.code)}`)
    }
    );
  }

  // Disconnection, corresponding to disconnectService of the FA model.
  disconnectAbility() {
    this.context.disconnectServiceExtensionAbility(connectionNumber).then((data) => {
      Logger.info(TAG, `disconnectAbility success, data: ${JSON.stringify(data)}`);
      this.UIContext.getPromptAction().showToast({
        message: 'disconnectAbility success'
      });
    }).catch((error) => {
      Logger.error(TAG, `disconnectAbility fail, error: ${JSON.stringify(error)}`);
      this.UIContext.getPromptAction().showToast({
        message: 'disconnectAbility'
      });
    })
  }

  // Start a pop-up window to request user authorization,
  // corresponding to requestPermissionsFromUser in AppContext of the FA model.
  requestPermissionsFromUser() {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(this.context, ['ohos.permission.ABILITY_BACKGROUND_COMMUNICATION'])
        .then((data) => {
          Logger.info(TAG, `data: ${JSON.stringify(data)}`);
          this.UIContext.getPromptAction().showToast({
            message: 'requestPermissionsFromUser success'
          });
        }).catch((err) => {
        Logger.info(TAG, `err: ${JSON.stringify(err)}`);
      });
    } catch (err) {
      Logger.info(TAG, `catch err->${JSON.stringify(err)}`);
    }
  }

  // Specifies the name of the ability displayed in the task,
  setMissionLabel() {
    this.context.setMissionLabel('test', (result) => {
      Logger.info(TAG, `setMissionLabel: ${JSON.stringify(result)}`);
      this.UIContext.getPromptAction().showToast({
        message: 'setMissionLabel success'
      });
    })
  }

  // Check whether the ability is in terminating state.
  isTerminating() {
    let isTerminating = false;
    try {
      isTerminating = this.context.isTerminating();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, 'testTag', `setColorMode failed.code=${err.code},message=${err.message}`);
    }
    try {
      this.UIContext.getPromptAction().showToast({
        message: 'isTerminating success'
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, 'testTag', `showToast failed.code=${err.code},message=${err.message}`);
    }
    Logger.info(TAG, `ability state: ${JSON.stringify(isTerminating)}`);
  }
}

