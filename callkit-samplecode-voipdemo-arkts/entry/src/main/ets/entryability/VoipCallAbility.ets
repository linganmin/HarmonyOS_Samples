import CallDataManager from '../model/CallDataManager';
import DefaultCallData from '../model/TypeUtils';
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { voipCall } from '@kit.CallKit';
import { common } from '@kit.AbilityKit';

export default class VoipCallAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'VoipCallAbility', '%{public}s', 'Ability onCreate: ' + want.parameters);
    AppStorage.setOrCreate<common.UIAbilityContext>('VoipCallAbilityContext', this.context);
    if (want.parameters?.VoIPCallId) {
      this.handleWantCallId(want.parameters?.VoIPCallId + '');
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'VoipCallAbility', '%{public}s', 'Ability onNewWant: ' + want.parameters);
    if (want.parameters?.VoIPCallId) {
      this.handleWantCallId(want.parameters?.VoIPCallId + '');
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'VoipCallAbility', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'VoipCallAbility', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/VoipCallPage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'VoipCallAbility', 'Failed to load the content. Cause: %{public}s, err.code: ', err.code ?? '');
        return;
      }
      hilog.info(0x0000, 'VoipCallAbility', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'VoipCallAbility', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'VoipCallAbility', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'VoipCallAbility', '%{public}s', 'Ability onBackground');
  }

  handleWantCallId(callId: string): void {
    hilog.info(0x0000, 'VoipCallAbility', 'handleWantCallId %{public}s', callId);
    let currentCallData: DefaultCallData | undefined = CallDataManager.getInstance()
      .getCallById(AppStorage.get('voipCallId') + '');
    if (currentCallData &&
      currentCallData.callState === voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE &&
      currentCallData.callId !== callId) {
      hilog.info(0x0000, 'VoipCallAbility', '%{public}s exist and not disconnect, no need handle', currentCallData?.callId);
      return;
    }
    let callData: DefaultCallData | undefined = CallDataManager.getInstance().getCallById(callId);
    if (callData) {
      hilog.info(0x0000, 'VoipCallAbility', '%{public}s update to foreground', callId);
      AppStorage.setOrCreate('voipCallId', callData.callId);
      AppStorage.setOrCreate('voipCallState', callData.callState);
      AppStorage.setOrCreate('voipCallType', callData.callType);
      AppStorage.setOrCreate('isVoiceAnswerSupported', callData.isVoiceAnswerSupported);
      hilog.info(0x0000, 'SampleCode', 'set isVoiceAnswerSupported = ' + callData.isVoiceAnswerSupported);
    } else {
      hilog.error(0x0000, 'VoipCallAbility', '%{public}s not exist, no need update', callId);
    }
  }
}
