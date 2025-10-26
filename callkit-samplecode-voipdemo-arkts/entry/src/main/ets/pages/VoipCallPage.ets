import CallDataManager from '../model/CallDataManager';
import { voipCall } from '@kit.CallKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common, abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { AVCastPicker } from '@kit.AVSessionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct VoipCallPage {
  @State username: string = 'Jack';
  @StorageLink('voipCallState') @Watch('callStateChange') voipCallState: voipCall.VoipCallState =
    voipCall.VoipCallState.VOIP_CALL_STATE_IDLE;
  @StorageLink('voipCallMuteState') voipCallMuteState: boolean = false;
  @StorageLink('voipCallSpeakerState') voipCallSpeakerState: boolean = false;
  @StorageLink('voipCallType') voipCallType: voipCall.VoipCallType = voipCall.VoipCallType.VOIP_CALL_VOICE;
  @StorageLink('isVoiceAnswerSupported') isVoiceAnswerSupported: boolean = true;

  aboutToAppear() {
  }

  onPageShow(): void {
    const array: Permissions[] = ['ohos.permission.MICROPHONE'];
    const atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(AppStorage.get<common.UIAbilityContext>('VoipCallAbilityContext'), array).then((data) => {
      hilog.info(0x0000, 'SampleCode', 'requestPermissionsFromUser' + JSON.stringify(data));
      let grantStatus: number[] = data.authResults;
      if (grantStatus[0] === 0) {
        hilog.info(0x0000, 'SampleCode', 'requestPermissionsFromUser grant MICROPHONE permission');
      } else {
        hilog.info(0x0000, 'SampleCode', 'requestPermissionsFromUser reject MICROPHONE permission');
      }
    })
  }

  build() {
    Column() {
      Text(this.username)
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .align(Alignment.Top)
      Text(this.getCallStateLabel(this.voipCallState))
        .fontSize(18)
        .margin({ top: 5 })

      Row() {
        if (this.voipCallState == voipCall.VoipCallState.VOIP_CALL_STATE_RINGING) {
          Image($r('app.media.ic_public_hangup'))
            .width(56)
            .height(56)
            .onClick(() => {
              hilog.info(0x0000, 'SampleCode', 'reject call clicked');
              let result = voipCall.reportCallStateChange(AppStorage.get('voipCallId'), voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
              result.then(() => {
                hilog.info(0x0000, 'SampleCode', 'reject call set call to disconnected success');
                AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
              }).catch((error: BusinessError) => {
                hilog.error(0x0000, 'SampleCode', 'reject call set call to disconnected error code: ' + error.code);
              });
              CallDataManager.getInstance().removeCallById(AppStorage.get('voipCallId') + '');
            })
          if (this.voipCallType == voipCall.VoipCallType.VOIP_CALL_VIDEO) {
            if (this.isVoiceAnswerSupported == undefined || this.isVoiceAnswerSupported) {
              Image($r('app.media.ic_public_answer'))
                .width(56)
                .height(56)
                .onClick(() => {
                  hilog.info(0x0000, 'SampleCode', 'voipCallType is ' + this.voipCallType);
                  hilog.info(0x0000, 'SampleCode', 'answer call clicked');
                  let result = voipCall.reportCallStateChange(AppStorage.get('voipCallId'), voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE, voipCall.VoipCallType.VOIP_CALL_VOICE);
                  result.then(() => {
                    hilog.info(0x0000, 'SampleCode', 'voipCallType is ' + this.voipCallType);
                    hilog.info(0x0000, 'SampleCode', 'answer call set call to active success');
                    AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
                    AppStorage.setOrCreate('voipCallMuteState', false);
                  }).catch((error: BusinessError) => {
                    hilog.error(0x0000, 'SampleCode', 'answer call set call to active error code: ' + error.code);
                  });
                  CallDataManager.getInstance()
                    .updateCallStateById(AppStorage.get('voipCallId') + '', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
                })
                .margin({ left: 40 })
              Image($r('app.media.ic_public_answer_video'))
                .width(56)
                .height(56)
                .onClick(() => {
                  hilog.info(0x0000, 'SampleCode', 'voipCallType is ' + this.voipCallType);
                  hilog.info(0x0000, 'SampleCode', 'answer call clicked');
                  let result = voipCall.reportCallStateChange(AppStorage.get('voipCallId'), voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE, voipCall.VoipCallType.VOIP_CALL_VIDEO);
                  result.then(() => {
                    hilog.info(0x0000, 'SampleCode', 'answer call set call to active success');
                    AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
                    AppStorage.setOrCreate('voipCallMuteState', false);
                  }).catch((error: BusinessError) => {
                    hilog.error(0x0000, 'SampleCode', 'answer call set call to active error code: ' + error.code);
                  });
                  CallDataManager.getInstance()
                    .updateCallStateById(AppStorage.get('voipCallId') + '', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
                })
                .margin({ left: 40 })
            } else {
              Image($r('app.media.ic_public_answer_video'))
                .width(56)
                .height(56)
                .onClick(() => {
                  hilog.info(0x0000, 'SampleCode', 'voipCallType is ' + this.voipCallType);
                  hilog.info(0x0000, 'SampleCode', 'answer call clicked');
                  let result = voipCall.reportCallStateChange(AppStorage.get('voipCallId'), voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE, voipCall.VoipCallType.VOIP_CALL_VIDEO);
                  result.then(() => {
                    hilog.info(0x0000, 'SampleCode', 'answer call set call to active success');
                    AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
                    AppStorage.setOrCreate('voipCallMuteState', false);
                  }).catch((error: BusinessError) => {
                    hilog.error(0x0000, 'SampleCode', 'answer call set call to active error code: ' + error.code);
                  });
                  CallDataManager.getInstance()
                    .updateCallStateById(AppStorage.get('voipCallId') + '', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
                })
                .margin({ left: 100 })
            }
          } else {
            Image($r('app.media.ic_public_answer'))
              .width(56)
              .height(56)
              .onClick(() => {
                hilog.info(0x0000, 'SampleCode', 'voipCallType is ' + this.voipCallType);
                hilog.info(0x0000, 'SampleCode', 'answer call clicked');
                let result = voipCall.reportCallStateChange(AppStorage.get('voipCallId'), voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
                result.then(() => {
                  hilog.info(0x0000, 'SampleCode', 'answer call set call to active success');
                  AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
                  AppStorage.setOrCreate('voipCallMuteState', false);
                }).catch((error: BusinessError) => {
                  hilog.error(0x0000, 'SampleCode', 'answer call set call to active error code: ' + error.code);
                });
                CallDataManager.getInstance()
                  .updateCallStateById(AppStorage.get('voipCallId') + '', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
              })
              .margin({ left: 100 })
          }
        } else if (this.voipCallState !== voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED) {
          Image($r(this.voipCallMuteState ? 'app.media.ic_public_mute_on' : 'app.media.ic_public_mute'))
            .width(56)
            .height(56)
            .onClick(() => {
              hilog.info(0x0000, 'SampleCode', 'mute button clicked');
              let result = voipCall.reportCallAudioEventChange(AppStorage.get('voipCallId'),
                this.voipCallMuteState ? voipCall.CallAudioEvent.AUDIO_EVENT_UNMUTED : voipCall.CallAudioEvent.AUDIO_EVENT_MUTED);
              result.then(() => {
                hilog.info(0x0000, 'SampleCode', 'reportCallAudioEventChange mute event success');
              }).catch((error: BusinessError) => {
                hilog.error(0x0000, 'SampleCode', 'reportCallAudioEventChange mute event error code: ' + error.code);
              });
              AppStorage.setOrCreate('voipCallMuteState', !this.voipCallMuteState);
            })
          Image($r('app.media.ic_public_hangup'))
            .width(56)
            .height(56)
            .onClick(() => {
              hilog.info(0x0000, 'SampleCode', 'hangup call clicked');
              let result = voipCall.reportCallStateChange(AppStorage.get('voipCallId'), voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
              result.then(() => {
                hilog.info(0x0000, 'SampleCode', 'hangup call set call to disconnected success');
                AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
              }).catch((error: BusinessError) => {
                hilog.error(0x0000, 'SampleCode', 'hangup call set call to disconnected error code: ' + error.code);
              });
              CallDataManager.getInstance().removeCallById(AppStorage.get('voipCallId') + '');
            })
            .margin({ left: 50, right: 50 })
          AVCastPicker()
            .size({ height: 56, width: 56 })
            .foregroundColor('sys.color.ohos_id_color_primary')
            .backgroundColor('sys.color.ohos_id_color_primary')
        }
      }
      .margin({ top: 300 })

    }
    .width('100%')
    .height('100%')
    .margin({ top: 100 })
  }

  aboutToDisappear() {
  }

  callStateChange() {
    if (this.voipCallState == voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED) {
      setTimeout(() => {
        if (this.voipCallState == voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED) {
          AppStorage.get<common.UIAbilityContext>('VoipCallAbilityContext')?.terminateSelf();
        }
      }, 1000);
    }
  }

  getCallStateLabel(voipCallState: voipCall.VoipCallState): string {
    if (voipCallState == voipCall.VoipCallState.VOIP_CALL_STATE_RINGING) {
      return '来电';
    } else if (voipCallState == voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE) {
      return '通话中';
    } else if (voipCallState == voipCall.VoipCallState.VOIP_CALL_STATE_DIALING) {
      return '正在拨号';
    } else if (voipCallState == voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED) {
      return '通话结束';
    }
    return '';
  }
}