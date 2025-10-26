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

import { voipCall } from '@kit.CallServiceKit';
import { image } from '@kit.ImageKit';
import { audio } from '@kit.AudioKit';
import { common, abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { AudioRenderController } from '../commonutils/AudioRenderController';
import { AudioCapturerController } from '../commonutils/AudioCapturerController';
import { AVSessionController } from '../commonutils/AVSessionController';
import { CustomButton } from '../customcomponent/CustomButton'
import Logger from '../commonutils/Logger';

const TAG = 'VoIPScene';

@Builder
export function VoIPScenePageBuilder() {
  VoIPScenePage();
}

@Component
export struct VoIPScenePage {
  @StorageLink('voipCallState') @Watch('callStateChange') voipCallState: voipCall.VoipCallState =
    voipCall.VoipCallState.VOIP_CALL_STATE_IDLE;
  private callId: string = '12345678910';
  private captureFileName: string = 'captureTest.pcm'
  private renderFileName: string = 'voip_audio.pcm';
  private audioRenderController: AudioRenderController = new AudioRenderController();
  private audioCapturerController: AudioCapturerController = new AudioCapturerController();
  private avSessionController: AVSessionController = new AVSessionController();
  private audioSessionManager: audio.AudioSessionManager = audio.getAudioManager().getSessionManager();

  aboutToAppear() {
    this.registerVoIPCallUiEvent();
    this.initAVResource();
  }

  aboutToDisappear() {
    this.releaseAVResource();
    try {
      voipCall.off('voipCallUiEvent');
    } catch (error) {
      Logger.error(TAG, `off voipCallUiEvent fail. error message is ${error.message}`);
    }
  }

  onPageShow() {
    const array: Permissions[] = ['ohos.permission.MICROPHONE'];
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(AppStorage.get<common.UIAbilityContext>('VoIPCallAbilityContext'), array);
    } catch (error) {
      Logger.error(TAG, `requestPermissionsFromUser fail. error message is ${error.message}`);
    }
  }

  // [Start voip_stream_usage]
  async initAVResource() {
    // Create an instance of AudioRenderer and set the audio stream type to STREAM_USAGE_VOICE_COMMUNICATION
    this.audioRenderController.createAndInitAudioRender(this.avSessionController, this.renderFileName,
      audio.StreamUsage.STREAM_USAGE_VOICE_COMMUNICATION);
    // Create an AudioRCapturer instance and set the audio stream type to SOURCE_TYPE_VOICE_COMMUNICATION
    this.audioCapturerController.createAndInitAudioCapturer(this.avSessionController, this.captureFileName,
      audio.SourceType.SOURCE_TYPE_VOICE_COMMUNICATION);
    Logger.info('initAVResource SUCCESS');
  }

  // [End voip_stream_usage]

  async releaseAVResource() {
    if (this.audioRenderController) {
      await this.audioRenderController.releaseAudioRender(this.renderFileName);
    }
    if (this.audioCapturerController) {
      await this.audioCapturerController.releaseAudioCapturer();
    }
    // Deactivate an audio session
    try {
      this.audioSessionManager.deactivateAudioSession().then(() => {
        Logger.info('deactivateAudioSession SUCCESS');
      });
    } catch (error) {
      Logger.error(TAG, `deactivateAudioSession fail. error message is ${error.message}`);
    }

    Logger.info('releaseAVResource SUCCESS');
  }

  registerVoIPCallUiEvent() {
    try {
      voipCall.on('voipCallUiEvent', async (voipCallUiEventInfo) => {
        Logger.info('voipCallUiEvent: ' + voipCallUiEventInfo);
        if (voipCallUiEventInfo.voipCallUiEvent === voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_VOICE_ANSWER) {
          await voipCall.reportCallStateChange(
            voipCallUiEventInfo.callId, voipCall.VoipCallState.VOIP_CALL_STATE_ANSWERED);
          setTimeout(async () => {
            await voipCall.reportCallStateChange(voipCallUiEventInfo.callId,
              voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE, voipCall.VoipCallType.VOIP_CALL_VOICE);
            AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
          }, 2000);
        } else if ((voipCallUiEventInfo.voipCallUiEvent === voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_REJECT) ||
          (voipCallUiEventInfo.voipCallUiEvent === voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_HANGUP)) {
          await voipCall.reportCallStateChange(
            voipCallUiEventInfo.callId, voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
          AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
        } else if (voipCallUiEventInfo.voipCallUiEvent === voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_MUTED) {
          await voipCall.reportCallAudioEventChange(
            voipCallUiEventInfo.callId, voipCall.CallAudioEvent.AUDIO_EVENT_MUTED);
          AppStorage.setOrCreate('voipCallMuteState', true);
        } else if (voipCallUiEventInfo.voipCallUiEvent === voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_UNMUTED) {
          await voipCall.reportCallAudioEventChange(
            voipCallUiEventInfo.callId, voipCall.CallAudioEvent.AUDIO_EVENT_UNMUTED);
          AppStorage.setOrCreate('voipCallMuteState', false);
        } else if (voipCallUiEventInfo.voipCallUiEvent === voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_SPEAKER_ON) {
          await voipCall.reportCallAudioEventChange(
            voipCallUiEventInfo.callId, voipCall.CallAudioEvent.AUDIO_EVENT_SPEAKER_ON);
        } else if (voipCallUiEventInfo.voipCallUiEvent === voipCall.VoipCallUiEvent.VOIP_CALL_EVENT_SPEAKER_OFF) {
          await voipCall.reportCallAudioEventChange(
            voipCallUiEventInfo.callId, voipCall.CallAudioEvent.AUDIO_EVENT_SPEAKER_OFF);
        }
      });
    } catch (error) {
      Logger.error(TAG, `voipCallUiEvent failed,code is ${error.code},message is ${error.message}}`);
    }
  }

  callStateChange() {
    if (this.voipCallState === voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE) {
      // Set the audio concurrency mode
      let strategy: audio.AudioSessionStrategy = {
        concurrencyMode: AppStorage.get('audioConcurrencyMode') as audio.AudioConcurrencyMode
      };
      // Activate the audio session
      try {
        this.audioSessionManager.activateAudioSession(strategy).then(() => {
          Logger.info('activateAudioSession SUCCESS');
        });
      } catch (error) {
        Logger.error(TAG, `activateAudioSession fail. error message is ${error.message}`);
      }
      this.audioRenderController.MediaPlay();
      this.audioCapturerController.MediaPlay();
    } else if (this.voipCallState === voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED) {
      this.audioRenderController.MediaStop();
      this.audioCapturerController.MediaStop();
      // Deactivate an audio session
      try {
        this.audioSessionManager.deactivateAudioSession().then(() => {
          Logger.info('deactivateAudioSession SUCCESS');
        });
      } catch (error) {
        Logger.error(TAG, `deactivateAudioSession fail. error message is ${error.message}`);
      }
      setTimeout(() => {
        AppStorage.get<common.UIAbilityContext>('VoIPCallAbilityContext')?.terminateSelf().then(() => {
          Logger.error(TAG, 'AppStorage get VoIPCallAbilityContext failed');
        });
      }, 1000);
    }
  }

  build() {
    NavDestination() {
      Column() {
        CustomButton({
          buttonName: '激活来电场景',
          buttonOnClick: async () => {
            let voipCallAttribute: voipCall.VoipCallAttribute = {
              callId: this.callId,
              voipCallType: voipCall.VoipCallType.VOIP_CALL_VOICE,
              userName: 'Jack',
              userProfile: image.createPixelMapSync(new ArrayBuffer(100), { size: { width: 90, height: 90 } }),
              abilityName: 'VoIPCallAbility',
              voipCallState: voipCall.VoipCallState.VOIP_CALL_STATE_RINGING
            };
            try {
              await voipCall.reportIncomingCall(voipCallAttribute);
            } catch (error) {
              Logger.error(TAG, `reportIncomingCall failed,code is ${error.code},message is ${error.message}}`);
            }
            AppStorage.setOrCreate('voipCallId', this.callId);
            AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_RINGING);
          }
        });
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
    }
    .title($r('app.string.voip_chart_button'))
  }
}