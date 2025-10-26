/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import type TestRunner from '@ohos.application.testRunner';
import hilog from '@ohos.hilog';

let abilityDelegator = undefined;
let abilityDelegatorArguments = undefined;

async function onAbilityCreateCallback(): Promise<void> {
  hilog.info(0x0000, 'testTag', '%{public}s', 'onAbilityCreateCallback');
}

async function addAbilityMonitorCallback(err): Promise<void> {
  hilog.info(0x0000, 'testTag', 'addAbilityMonitorCallback : %{public}s', JSON.stringify(err) ?? '');
}

export default class OpenHarmonyTestRunner implements TestRunner {
  constructor() {
  }

  onPrepare(): void {
    hilog.info(0x0000, 'fido', '%{public}s', 'fido OnPrepare ');
  }

  async onRun(): Promise<void> {
    hilog.info(0x0000, 'fido', '%{public}s', 'fido onRun run');
    abilityDelegatorArguments = AbilityDelegatorRegistry.getArguments();
    abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator();
    let abilityName = abilityDelegatorArguments.bundleName + '.TestAbility';
    let lMonitor = {
      abilityName: abilityName,
      onAbilityCreate: onAbilityCreateCallback,
    };
    abilityDelegator.addAbilityMonitor(lMonitor, addAbilityMonitorCallback);
    let startCmd = 'aa start -d 0 -a TestAbility' + ' -b ' + abilityDelegatorArguments.bundleName;
    let debug = abilityDelegatorArguments.parameters['-D'];
    if (debug === 'true') {
      startCmd += ' -D';
    }
    hilog.info(0x0000, 'fido', 'cmd : %{public}s', startCmd);
    abilityDelegator.executeShellCommand(startCmd,
      (err, d): void => {
        hilog.info(0x0000, 'fido', 'executeShellCommand : err : %{public}s', JSON.stringify(err) ?? '');
        hilog.info(0x0000, 'fido', 'executeShellCommand : data : %{public}s', d.stdResult ?? '');
        hilog.info(0x0000, 'fido', 'executeShellCommand : data : %{public}s', d.exitCode ?? '');
      });
    hilog.info(0x0000, 'fido', '%{public}s', 'OpenHarmonyTestRunner onRun end');
  }
}