/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { cloudCommon } from '@kit.CloudFoundationKit';
import auth from '@hw-agconnect/auth';
import { buffer } from '@kit.ArkTS';
import { GlobalContext } from '../common/GlobalContext';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(DOMAIN, TAG, 'Ability onCreate');
    // Init global context.
    GlobalContext.initContext(this.context);
    // Access Auth SDK.
    try {
      let file = this.context.resourceManager.getRawFileContentSync('agconnect-services.json');
      let json: string = buffer.from(file.buffer).toString();
      auth.init(this.context, json);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to init auth, err: ${err.message}`);
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // When the main window is created, set a main page for this ability.
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', async (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, `Failed to load the content. Cause: ${err.code}, ${err.message}`);
        return;
      }
      // After successfully logging in with a Huawei account, obtain and register the AuthProvider.
      let user = await auth.getCurrentUser();
      if (user === null) {
        await auth.signIn({
          autoCreateUser: true,
          credentialInfo: { 'kind': 'hwid' }
        });
        cloudCommon.init({ authProvider: auth.getAuthProvider() });
      } else {
        cloudCommon.init({ authProvider: auth.getAuthProvider() });
      }
    });
  }

  onWindowStageDestroy(): void {
    // When the main window is destroyed, free up UI-related resources.
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // The ability has been brought to the foreground.
    hilog.info(DOMAIN, TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // The ability has returned to the background.
    hilog.info(DOMAIN, TAG, 'Ability onBackground');
  }
}
