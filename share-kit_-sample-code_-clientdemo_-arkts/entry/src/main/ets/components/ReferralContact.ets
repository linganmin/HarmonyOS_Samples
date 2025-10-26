/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import BuildProfile from 'BuildProfile';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { insightIntent } from '@kit.IntentsKit';
import Logger from '../utils/Logger';

let logger = Logger.getLogger('[ReferralContact]');

/**
 * Share contact information to the sharing recommendation area.
 * The intent framework requires a trust list for testing and cannot run directly.
 */
@Component
export default struct ReferralContact {

  private intentName: string = 'SendMessage'; // Intent name.
  private intent?: insightIntent.InsightIntent = undefined;

  async createIntentData() {
    this.intent = {
      intentName: this.intentName,
      intentVersion: '1.0', // Intent version.
      identifier: util.generateRandomUUID(), // Intent identifier.
      intentActionInfo: { // Intent execution information.
        actionMode: 'EXECUTED', // Action mode.
        executedTimeSlots: { // Actual execution period.
          executedStartTime: new Date().getTime(),
          executedEndTime: new Date().getTime(),
        }
      },
      intentEntityInfo: { // Intent entity information.
        entityId: 'this-is-id', // Entity ID.
        entityName: 'Contact', // Entity name.
        name: 'Nickname', // Contact nickname.
        icon: 'data:image/png;base64,...', // Contact avatar.
        phoneNumbers: [], // Contact phone number.
        extras: {
          shareParams: {
            bundleName: BuildProfile.BUNDLE_NAME, // App package name.
            moduleName: 'entry', // Enter your app module name.
            abilityName: 'SampleContactAbility', // Enter your app ability name.
            action: 'ohos.want.action.sendData', // Indicates that the data is used for sharing. The value cannot be modified.
          }
        }
      }
    };
  }

  async shareIntent() {
    const uiContext: UIContext = this.getUIContext();
    const context: Context = uiContext.getHostContext() as Context;
    insightIntent.shareIntent(context, [this.intent]).then(() => {
      logger.info('shareIntent ok');
    }).catch((err: BusinessError) => {
      logger.error(`shareIntent failed. Code: ${err.code}. message: ${err.message}`);
    });
  }

  async deleteIntent() {
    const uiContext: UIContext = this.getUIContext();
    const context: Context = uiContext.getHostContext() as Context;
    insightIntent.deleteIntent(context, this.intentName).then(() => {
      logger.info('deleteIntent ok');
    }).catch((err: BusinessError) => {
      logger.error(`deleteIntent failed. Code: ${err.code}. message: ${err.message}`);
    });
  }

  build() {
  }
}