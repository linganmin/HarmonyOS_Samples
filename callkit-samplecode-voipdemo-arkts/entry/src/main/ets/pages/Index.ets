import CallDataManager from '../model/CallDataManager';
import DefaultCallData from '../model/TypeUtils';
import { voipCall } from '@kit.CallKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { audio } from '@kit.AudioKit';
import { observer } from '@kit.TelephonyKit';
import { avSession } from "@kit.AVSessionKit";
import { common, Want } from '@kit.AbilityKit';
import { bundleManager } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  bundleName: string = '';
  @StorageLink('voipCallState') @Watch('callStateChange') voipCallState: voipCall.VoipCallState =
    voipCall.VoipCallState.VOIP_CALL_STATE_IDLE;
  callIdIndex: number = 1;
  callId: string = '';
  callIdPrefix: string = '';
  audioRenderer: audio.AudioRenderer | undefined;
  session: avSession.AVSession | undefined;

  aboutToAppear() {
    this.bundleName = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)?.name;
    hilog.info(0x0000, 'SampleCode', 'current bundleName: ' + this.bundleName);
    this.callIdPrefix = this.bundleName + '.';
    this.observeEvent();
    this.observeCallState();
  }

  onPageShow(): void {
  }

  build() {
    Column() {
      Button('Incoming call')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          hilog.info(0x0000, 'SampleCode', 'reportIncomingCall with banner');
          this.callId = this.callIdPrefix + (this.callIdIndex++);
          let voipCallAttribute: voipCall.VoipCallAttribute = {
            callId: this.callId,
            voipCallType: voipCall.VoipCallType.VOIP_CALL_VOICE,
            userName: 'Jack',
            userProfile: image.createPixelMapSync(new ArrayBuffer(100), { size: { width: 90, height: 90 } }),
            abilityName: 'VoipCallAbility',
            voipCallState: voipCall.VoipCallState.VOIP_CALL_STATE_RINGING
            // showBannerForIncomingCall: true,
          };
          let result = voipCall.reportIncomingCall(voipCallAttribute);
          result.then((errorReason: voipCall.ErrorReason) => {
            hilog.info(0x0000, 'SampleCode', 'reportIncomingCall errorReason: ' + errorReason);
            if (errorReason == voipCall.ErrorReason.ERROR_NONE) {
              CallDataManager.getInstance()
                .addCall({
                  callId: voipCallAttribute.callId,
                  callState: voipCallAttribute.voipCallState,
                  callType: voipCallAttribute.voipCallType
                });
              if (CallDataManager.getInstance().getCallCount() == 1) {
                AppStorage.setOrCreate('voipCallId', this.callId);
                AppStorage.setOrCreate('voipCallType', voipCall.VoipCallType.VOIP_CALL_VOICE);
                AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_RINGING);
              }

              this.handleIncomingCallTimeout(this.callId);
            }
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportIncomingCall error code: ' + error.code);
          });
        })
      Button('Meeting')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .onClick(() => {
          hilog.info(0x0000, 'SampleCode', 'reportIncomingCall with banner');
          this.callId = this.callIdPrefix + (this.callIdIndex++);
          let voipCallAttribute: voipCall.VoipCallAttribute = {
            callId: this.callId,
            voipCallType: voipCall.VoipCallType.VOIP_CALL_VOICE,
            userName: 'Jack',
            userProfile: image.createPixelMapSync(new ArrayBuffer(100), { size: { width: 90, height: 90 } }),
            abilityName: 'VoipCallAbility',
            voipCallState: voipCall.VoipCallState.VOIP_CALL_STATE_RINGING,
            // showBannerForIncomingCall: true,
            isConferenceCall: true
          };
          let result = voipCall.reportIncomingCall(voipCallAttribute);
          result.then((errorReason: voipCall.ErrorReason) => {
            hilog.info(0x0000, 'SampleCode', 'reportIncomingCall errorReason: ' + errorReason);
            if (errorReason == voipCall.ErrorReason.ERROR_NONE) {
              CallDataManager.getInstance()
                .addCall({
                  callId: voipCallAttribute.callId,
                  callState: voipCallAttribute.voipCallState,
                  callType: voipCallAttribute.voipCallType
                });
              if (CallDataManager.getInstance().getCallCount() == 1) {
                AppStorage.setOrCreate('voipCallId', this.callId);
                AppStorage.setOrCreate('voipCallType', voipCall.VoipCallType.VOIP_CALL_VOICE);
                AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_RINGING);
              }

              this.handleIncomingCallTimeout(this.callId);
            }
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportIncomingCall error code: ' + error.code);
          });
        })
      Button('Incoming call (no banner)')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .onClick(() => {
          hilog.info(0x0000, 'SampleCode', 'reportIncomingCall not with banner');
          this.callId = this.callIdPrefix + (this.callIdIndex++) + '';
          let voipCallAttribute: voipCall.VoipCallAttribute = {
            callId: this.callId,
            voipCallType: voipCall.VoipCallType.VOIP_CALL_VOICE,
            userName: 'Jack',
            userProfile: image.createPixelMapSync(new ArrayBuffer(100), { size: { width: 90, height: 90 } }),
            abilityName: 'VoipCallAbility',
            voipCallState: voipCall.VoipCallState.VOIP_CALL_STATE_RINGING,
            showBannerForIncomingCall: false
          };
          let result = voipCall.reportIncomingCall(voipCallAttribute);
          result.then((errorReason: voipCall.ErrorReason) => {
            hilog.info(0x0000, 'SampleCode', 'reportIncomingCall errorReason: ' + errorReason);
            if (errorReason == voipCall.ErrorReason.ERROR_NONE) {
              CallDataManager.getInstance()
                .addCall({
                  callId: voipCallAttribute.callId,
                  callState: voipCallAttribute.voipCallState,
                  callType: voipCallAttribute.voipCallType
                });
              if (CallDataManager.getInstance().getCallCount() == 1) {
                AppStorage.setOrCreate('voipCallId', this.callId);
                AppStorage.setOrCreate('voipCallType', voipCall.VoipCallType.VOIP_CALL_VOICE);
                AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_RINGING);
              }

              this.handleIncomingCallTimeout(this.callId);
            }
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportIncomingCall error code: ' + error.code);
          });
        })
      Button('Outgoing voice call')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .onClick(() => {
          hilog.info(0x0000, 'SampleCode', 'reportOutgoingCall');
          this.callId = this.callIdPrefix + (this.callIdIndex++) + '';
          let voipCallAttribute: voipCall.VoipCallAttribute = {
            callId: this.callId,
            voipCallType: voipCall.VoipCallType.VOIP_CALL_VOICE,
            userName: 'Jack',
            userProfile: image.createPixelMapSync(new ArrayBuffer(100), { size: { width: 90, height: 90 } }),
            abilityName: 'VoipCallAbility',
            voipCallState: voipCall.VoipCallState.VOIP_CALL_STATE_DIALING
          };
          let result = voipCall.reportOutgoingCall(voipCallAttribute);
          result.then((errorReason: voipCall.ErrorReason) => {
            hilog.info(0x0000, 'SampleCode', 'reportOutgoingCall errorReason: ' + errorReason);
            if (errorReason == voipCall.ErrorReason.ERROR_NONE) {
              CallDataManager.getInstance()
                .addCall({
                  callId: voipCallAttribute.callId,
                  callState: voipCallAttribute.voipCallState,
                  callType: voipCallAttribute.voipCallType
                });
              AppStorage.setOrCreate('voipCallId', this.callId);
              AppStorage.setOrCreate('voipCallType', voipCall.VoipCallType.VOIP_CALL_VOICE);
              AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DIALING);
              AppStorage.setOrCreate('voipCallMuteState', false);
              // Directly show the dialer screen for an outgoing call.
              let want: Want = {
                bundleName: this.bundleName,
                abilityName: 'VoipCallAbility'
              };
              AppStorage.get<common.UIAbilityContext>('AbilityContext')?.startAbility(want);

              this.handleDialingCallTimeout(this.callId);
            }
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportOutgoingCall error code: ' + error.code);
          });
        })
      Button('Outgoing video call')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .onClick(() => {
          hilog.info(0x0000, 'SampleCode', 'reportOutgoingCall video');
          this.callId = this.callIdPrefix + (this.callIdIndex++) + '';
          let voipCallAttribute: voipCall.VoipCallAttribute = {
            callId: this.callId,
            voipCallType: voipCall.VoipCallType.VOIP_CALL_VIDEO,
            userName: 'Jack',
            userProfile: image.createPixelMapSync(new ArrayBuffer(100), { size: { width: 90, height: 90 } }),
            abilityName: 'VoipCallAbility',
            voipCallState: voipCall.VoipCallState.VOIP_CALL_STATE_DIALING
          };
          let result = voipCall.reportOutgoingCall(voipCallAttribute);
          result.then((errorReason: voipCall.ErrorReason) => {
            hilog.info(0x0000, 'SampleCode', 'reportOutgoingCall errorReason: ' + errorReason);
            if (errorReason == voipCall.ErrorReason.ERROR_NONE) {
              CallDataManager.getInstance()
                .addCall({
                  callId: voipCallAttribute.callId,
                  callState: voipCallAttribute.voipCallState,
                  callType: voipCallAttribute.voipCallType
                });
              AppStorage.setOrCreate('voipCallId', this.callId);
              AppStorage.setOrCreate('voipCallType', voipCall.VoipCallType.VOIP_CALL_VIDEO);
              AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DIALING);
              AppStorage.setOrCreate('voipCallMuteState', false);
              // Directly show the dialer screen for an outgoing call.
              let want: Want = {
                bundleName: this.bundleName,
                abilityName: 'VoipCallAbility'
              };
              AppStorage.get<common.UIAbilityContext>('AbilityContext')?.startAbility(want);

              this.handleDialingCallTimeout(this.callId);
            }
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportOutgoingCall error code: ' + error.code);
          });
        })
      Button('Incoming video call')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .onClick(() => {
          hilog.info(0x0000, 'SampleCode', 'reportIncomingCall video with banner');
          this.callId = this.callIdPrefix + (this.callIdIndex++) + '';
          let voipCallAttribute: voipCall.VoipCallAttribute = {
            callId: this.callId,
            voipCallType: voipCall.VoipCallType.VOIP_CALL_VIDEO,
            userName: 'Jack',
            userProfile: image.createPixelMapSync(new ArrayBuffer(100), { size: { width: 90, height: 90 } }),
            abilityName: 'VoipCallAbility',
            voipCallState: voipCall.VoipCallState.VOIP_CALL_STATE_RINGING,
            showBannerForIncomingCall: true
          };
          let result = voipCall.reportIncomingCall(voipCallAttribute);
          result.then((errorReason: voipCall.ErrorReason) => {
            hilog.info(0x0000, 'SampleCode', 'reportIncomingCall video errorReason: ' + errorReason);
            if (errorReason == voipCall.ErrorReason.ERROR_NONE) {
              CallDataManager.getInstance()
                .addCall({
                  callId: voipCallAttribute.callId,
                  callState: voipCallAttribute.voipCallState,
                  callType: voipCallAttribute.voipCallType
                });
              if (CallDataManager.getInstance().getCallCount() == 1) {
                AppStorage.setOrCreate('voipCallId', this.callId);
                AppStorage.setOrCreate('voipCallType', voipCall.VoipCallType.VOIP_CALL_VIDEO);
                AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_RINGING);
              }

              this.handleIncomingCallTimeout(this.callId);
            }
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportIncomingCall video error code: ' + error.code);
          });
        })
      Button('Incoming video call (no voice answer)')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .onClick(() => {
          hilog.info(0x0000, 'SampleCode', 'reportIncomingCall video with banner');
          this.callId = this.callIdPrefix + (this.callIdIndex++) + '';
          let voipCallAttribute: voipCall.VoipCallAttribute = {
            callId: this.callId,
            voipCallType: voipCall.VoipCallType.VOIP_CALL_VIDEO,
            userName: 'Jack',
            userProfile: image.createPixelMapSync(new ArrayBuffer(100), { size: { width: 90, height: 90 } }),
            abilityName: 'VoipCallAbility',
            voipCallState: voipCall.VoipCallState.VOIP_CALL_STATE_RINGING,
            showBannerForIncomingCall: true,
            isVoiceAnswerSupported: false
          };
          let result = voipCall.reportIncomingCall(voipCallAttribute);
          result.then((errorReason: voipCall.ErrorReason) => {
            hilog.info(0x0000, 'SampleCode', 'reportIncomingCall video errorReason: ' + errorReason);
            if (errorReason == voipCall.ErrorReason.ERROR_NONE) {
              CallDataManager.getInstance()
                .addCall({
                  callId: voipCallAttribute.callId,
                  callState: voipCallAttribute.voipCallState,
                  callType: voipCallAttribute.voipCallType,
                  isVoiceAnswerSupported: false
                });
              if (CallDataManager.getInstance().getCallCount() == 1) {
                AppStorage.setOrCreate('voipCallId', this.callId);
                AppStorage.setOrCreate('voipCallType', voipCall.VoipCallType.VOIP_CALL_VIDEO);
                AppStorage.setOrCreate('isVoiceAnswerSupported', false);
                AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_RINGING);
              }

              this.handleIncomingCallTimeout(this.callId);
            }
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportIncomingCall video error code: ' + error);
          });
        })
      Button('Video meeting')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .onClick(() => {
          hilog.info(0x0000, 'SampleCode', 'reportIncomingCall video with banner');
          this.callId = this.callIdPrefix + (this.callIdIndex++) + '';
          let voipCallAttribute: voipCall.VoipCallAttribute = {
            callId: this.callId,
            voipCallType: voipCall.VoipCallType.VOIP_CALL_VIDEO,
            userName: 'Jack',
            userProfile: image.createPixelMapSync(new ArrayBuffer(100), { size: { width: 90, height: 90 } }),
            abilityName: 'VoipCallAbility',
            voipCallState: voipCall.VoipCallState.VOIP_CALL_STATE_RINGING,
            showBannerForIncomingCall: true,
            isConferenceCall: true
          };
          let result = voipCall.reportIncomingCall(voipCallAttribute);
          result.then((errorReason: voipCall.ErrorReason) => {
            hilog.info(0x0000, 'SampleCode', 'reportIncomingCall video errorReason: ' + errorReason);
            if (errorReason == voipCall.ErrorReason.ERROR_NONE) {
              CallDataManager.getInstance()
                .addCall({
                  callId: voipCallAttribute.callId,
                  callState: voipCallAttribute.voipCallState,
                  callType: voipCallAttribute.voipCallType
                });
              if (CallDataManager.getInstance().getCallCount() == 1) {
                AppStorage.setOrCreate('voipCallId', this.callId);
                AppStorage.setOrCreate('voipCallType', voipCall.VoipCallType.VOIP_CALL_VIDEO);
                AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_RINGING);
              }

              this.handleIncomingCallTimeout(this.callId);
            }
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportIncomingCall video error code: ' + error.code);
          });
        })
      Button('Incoming video call (no banner)')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
        .onClick(() => {
          hilog.info(0x0000, 'SampleCode', 'reportIncomingCall video not with banner');
          this.callId = this.callIdPrefix + (this.callIdIndex++) + '';
          let voipCallAttribute: voipCall.VoipCallAttribute = {
            callId: this.callId,
            voipCallType: voipCall.VoipCallType.VOIP_CALL_VIDEO,
            userName: 'Jack',
            userProfile: image.createPixelMapSync(new ArrayBuffer(100), { size: { width: 90, height: 90 } }),
            abilityName: 'VoipCallAbility',
            voipCallState: voipCall.VoipCallState.VOIP_CALL_STATE_RINGING,
            showBannerForIncomingCall: false
          };
          let result = voipCall.reportIncomingCall(voipCallAttribute);
          result.then((errorReason: voipCall.ErrorReason) => {
            hilog.info(0x0000, 'SampleCode', 'reportIncomingCall video errorReason: ' + errorReason);
            if (errorReason == voipCall.ErrorReason.ERROR_NONE) {
              CallDataManager.getInstance()
                .addCall({
                  callId: voipCallAttribute.callId,
                  callState: voipCallAttribute.voipCallState,
                  callType: voipCallAttribute.voipCallType
                });
              if (CallDataManager.getInstance().getCallCount() == 1) {
                AppStorage.setOrCreate('voipCallId', this.callId);
                AppStorage.setOrCreate('voipCallType', voipCall.VoipCallType.VOIP_CALL_VIDEO);
                AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_RINGING);
              }

              this.handleIncomingCallTimeout(this.callId);
            }
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportIncomingCall video error code: ' + error.code);
          });
        })
      Button('Triggering the peer end to answer')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })
        .onClick(() => {
          if (this.voipCallState !== voipCall.VoipCallState.VOIP_CALL_STATE_DIALING) {
            return;
          }
          hilog.info(0x0000, 'SampleCode', 'outgoingCall change to answer');
          AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
          let result = voipCall.reportCallStateChange(AppStorage.get('voipCallId'), voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
          result.then(() => {
            hilog.info(0x0000, 'SampleCode', 'outgoingCall change to active success');
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'outgoingCall change to active error code: ' + error.code);
          });
          CallDataManager.getInstance()
            .updateCallStateById(AppStorage.get('voipCallId') + '', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
        })
    }
    .width('100%')
    .height('100%')
    .margin({ top: 200 })
  }

  aboutToDisappear() {
    voipCall.off('voipCallUiEvent');
  }

  observeEvent() {
    try {
      voipCall.on('voipCallUiEvent', (voipCallUiEventInfo) => {
        hilog.info(0x0000, 'SampleCode', 'voipCallUiEvent: ' + voipCallUiEventInfo);
        if (voipCallUiEventInfo?.voipCallUiEvent == voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_VOICE_ANSWER) {
          hilog.info(0x0000, '20240830', 'ready to report state: %{public}s', 'answered');
          voipCall.reportCallStateChange(voipCallUiEventInfo.callId, voipCall.VoipCallState.VOIP_CALL_STATE_ANSWERED);

          setTimeout(() => {
            hilog.info(0x0000, 'Index', 'answer success, state change to active');
            if (voipCallUiEventInfo.callId === AppStorage.get('voipCallId')) {
              AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
            }
            AppStorage.setOrCreate('voipCallMuteState', false);
            let result = voipCall.reportCallStateChange(voipCallUiEventInfo.callId, voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE,
              voipCall.VoipCallType.VOIP_CALL_VOICE);
            result.then(() => {
              hilog.info(0x0000, 'Index', 'reportCallStateChange to active success');
            }).catch((error: BusinessError) => {
              hilog.error(0x0000, 'Index', 'reportCallStateChange to active error code:', error.code);
            });
            CallDataManager.getInstance()
              .updateCallStateById(voipCallUiEventInfo.callId, voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
          }, 3000);
        } else if (voipCallUiEventInfo?.voipCallUiEvent == voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_VIDEO_ANSWER) {
          voipCall.reportCallStateChange(voipCallUiEventInfo.callId, voipCall.VoipCallState.VOIP_CALL_STATE_ANSWERED);
          setTimeout(() => {
            hilog.info(0x0000, 'SampleCode', 'video answer success, state change to active');
            if (voipCallUiEventInfo.callId === AppStorage.get('voipCallId')) {
              AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
            }
            AppStorage.setOrCreate('voipCallMuteState', false);
            let result = voipCall.reportCallStateChange(voipCallUiEventInfo.callId, voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE,
              voipCall.VoipCallType.VOIP_CALL_VIDEO);
            result.then(() => {
              hilog.info(0x0000, 'SampleCode', 'reportCallStateChange to active success');
            }).catch((error: BusinessError) => {
              hilog.error(0x0000, 'SampleCode', 'reportCallStateChange to active error code: ' + error.code);
            });
            CallDataManager.getInstance()
              .updateCallStateById(voipCallUiEventInfo.callId, voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
          }, 3000);
        } else if (voipCallUiEventInfo?.voipCallUiEvent == voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_REJECT) {
          setTimeout(() => {
            hilog.info(0x0000, 'SampleCode', 'reject success, state change to disconnected');
            if (voipCallUiEventInfo.callId === AppStorage.get('voipCallId')) {
              AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
            }
            let result = voipCall.reportCallStateChange(voipCallUiEventInfo.callId, voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
            result.then(() => {
              hilog.info(0x0000, 'SampleCode', 'reportCallStateChange to disconnected success');
            }).catch((error: BusinessError) => {
              hilog.error(0x0000, 'SampleCode', 'reportCallStateChange to disconnected error code: ' + error.code);
            });
            CallDataManager.getInstance().removeCallById(voipCallUiEventInfo.callId);
          }, 100);
        } else if (voipCallUiEventInfo?.voipCallUiEvent == voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_HANGUP) {
          setTimeout(() => {
            hilog.info(0x0000, 'SampleCode', 'hangup success, state change to disconnected');
            if (voipCallUiEventInfo.callId === AppStorage.get('voipCallId')) {
              AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
            }
            let result = voipCall.reportCallStateChange(voipCallUiEventInfo.callId, voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
            result.then(() => {
              hilog.info(0x0000, 'SampleCode', 'reportCallStateChange to disconnected success');
            }).catch((error: BusinessError) => {
              hilog.error(0x0000, 'SampleCode', 'reportCallStateChange to disconnected error code: ' + error.code);
            });
            CallDataManager.getInstance().removeCallById(voipCallUiEventInfo.callId);
          }, 100);
        } else if (voipCallUiEventInfo?.voipCallUiEvent == voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_MUTED) {
          hilog.info(0x0000, 'SampleCode', 'receive voip call event muted');
          let result = voipCall.reportCallAudioEventChange(voipCallUiEventInfo.callId, voipCall.CallAudioEvent.AUDIO_EVENT_MUTED);
          result.then(() => {
            hilog.info(0x0000, 'SampleCode', 'reportCallAudioEventChange mute event success');
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportCallAudioEventChange mute event error code: ' + error.code);
          });
          AppStorage.setOrCreate('voipCallMuteState', true);
        } else if (voipCallUiEventInfo?.voipCallUiEvent == voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_UNMUTED) {
          hilog.info(0x0000, 'SampleCode', 'receive voip call event unmuted');
          let result = voipCall.reportCallAudioEventChange(voipCallUiEventInfo.callId, voipCall.CallAudioEvent.AUDIO_EVENT_UNMUTED);
          result.then(() => {
            hilog.info(0x0000, 'SampleCode', 'reportCallAudioEventChange unmute event success');
          }).catch((error: BusinessError) => {
            hilog.error(0x0000, 'SampleCode', 'reportCallAudioEventChange unmute event error code: ' + error.code);
          });
          AppStorage.setOrCreate('voipCallMuteState', false);
        } else if (voipCallUiEventInfo?.voipCallUiEvent == voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_SPEAKER_ON) {
          hilog.info(0x0000, 'SampleCode', 'receive voip call event speaker on');
        } else if (voipCallUiEventInfo?.voipCallUiEvent == voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_SPEAKER_OFF) {
          hilog.info(0x0000, 'SampleCode', 'receive voip call event speaker off');
        }
      });
    } catch (err) {
      hilog.error(0x0000, 'SampleCode', 'voipCallUiEvent on error: ' + err);
    }
  }

  observeCallState() {
    observer.on('callStateChange', (data) => {
      hilog.info(0x0000, 'SampleCode', 'callStateChange: ' + JSON.stringify(data));
    })
  }

  callStateChange() {
    if (this.voipCallState == voipCall.VoipCallState.VOIP_CALL_STATE_DIALING ||
      this.voipCallState == voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE) {
      this.startAudioRenderer();
    } else if (this.voipCallState == voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED) {
      this.stopAudioRenderer();
    }
  }

  handleDialingCallTimeout(callId: string) {
    // Automatic timeout after 60s.
    setTimeout((callId: string) => {
      let callData: DefaultCallData | undefined = CallDataManager.getInstance().getCallById(callId);
      hilog.info(0x0000, 'SampleCode', 'handleDialingCallTimeout callId: ' + callId + ', callData: ' + callData);
      if (!callData || callData.callState !== voipCall.VoipCallState.VOIP_CALL_STATE_DIALING) {
        return;
      }
      hilog.info(0x0000, 'SampleCode', 'video dial timeout, state change to disconnected');
      AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
      let result = voipCall.reportCallStateChange(callId, voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
      result.then(() => {
        hilog.info(0x0000, 'SampleCode', 'reportCallStateChange to disconnected success');
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'SampleCode', 'reportCallStateChange to disconnected error: ' + error.code);
      });
      CallDataManager.getInstance().removeCallById(callId);
    }, 60000, callId);
  }

  handleIncomingCallTimeout(callId: string) {
    // Automatic timeout after 60s.
    setTimeout((callId: string) => {
      let callData: DefaultCallData | undefined = CallDataManager.getInstance().getCallById(callId);
      hilog.info(0x0000, 'SampleCode', 'handleIncomingCallTimeout callId: ' + callId + ', callData: ' + callData);
      if (!callData || callData.callState !== voipCall.VoipCallState.VOIP_CALL_STATE_RINGING) {
        return;
      }
      hilog.info(0x0000, 'SampleCode', 'voice incoming timeout, state change to disconnected');
      AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
      let result = voipCall.reportCallStateChange(callId, voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
      result.then(() => {
        hilog.info(0x0000, 'SampleCode', 'reportCallStateChange to disconnected success');
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'SampleCode', 'reportCallStateChange to disconnected error: ' + error.code);
      });
      CallDataManager.getInstance().removeCallById(callId);
    }, 60000, callId);
  }

  startAudioRenderer() {
    if (this.audioRenderer) {
      hilog.info(0x0000, 'SampleCode', `audioRenderer already init, no need to create`);
      return;
    }
    // Create an AVSession of the voice_call type.
    let result = avSession.createAVSession(getContext(this), 'voiptest', 'voice_call');
    result.then(session => {
      // (Optional) Set the call information.
      let callMeta: avSession.CallMetadata = {
        name: "Jack", // Name of the contact.
        phoneNumber: "123XXX890"  // Phone number of the contact.
      }
      this.session = session;
      this.session.setCallMetadata(callMeta);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'SampleCode', `createAVSession error`);
    })
    let audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000, // Sampling rate.
      channels: audio.AudioChannel.CHANNEL_2, // Channel.
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // Sampling format.
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // Encoding format.
    };
    let audioRendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_VOICE_COMMUNICATION,
      rendererFlags: 0
    };
    let audioRendererOptions: audio.AudioRendererOptions = {
      streamInfo: audioStreamInfo,
      rendererInfo: audioRendererInfo
    };
    audio.createAudioRenderer(audioRendererOptions, (err, data) => {
      if (err) {
        hilog.error(0x0000, 'SampleCode', `createAudioRenderer failed, code is ${err.code}, message is ${err.message}`);
        return;
      } else {
        hilog.info(0x0000, 'SampleCode', 'createAudioRenderer succeeded.');
        this.audioRenderer = data;
        this.audioRenderer.on('writeData', (buffer: ArrayBuffer) => {
          // hilog.info(0x0000, 'SampleCode', 'writeData succeeded.');
        });
        this.audioRenderer.start((err: BusinessError) => {
          if (err) {
            hilog.error(0x0000, 'SampleCode', `Renderer start failed, code is ${err.code}, message is ${err.message}`);
          } else {
            hilog.info(0x0000, 'SampleCode', 'Renderer start success.');
          }
        });
      }
    });
    audio.getAudioManager()
      .getRoutingManager()
      .on('preferOutputDeviceChangeForRendererInfo', audioRendererInfo, (desc: audio.AudioDeviceDescriptors) => {
        hilog.info(0x0000, 'SampleCode', `device change To : ${desc[0].deviceType}`);
      });
  }

  stopAudioRenderer() {
    if (!this.audioRenderer) {
      hilog.error(0x0000, 'SampleCode', `audioRenderer not init, no need to release`);
      return;
    }
    this.session?.destroy((err) => {
      if (err) {
        hilog.error(0x0000, 'SampleCode', `Failed to destroy session. Code: ${err.code}, message: ${err.message}`);
      } else {
        hilog.info(0x0000, 'SampleCode', `Destroy : SUCCESS `);
      }
    });
    this.audioRenderer.release((err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, 'SampleCode', `Renderer release failed, code is ${err.code}, message is ${err.message}`);
      } else {
        hilog.info(0x0000, 'SampleCode', 'Renderer released.');
      }
    });
    this.audioRenderer = undefined;
  }
}