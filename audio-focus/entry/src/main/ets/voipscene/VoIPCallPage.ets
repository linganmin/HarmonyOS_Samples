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
import Logger from '../commonutils/Logger';

const TAG = 'VoIPCallPage';

@Entry
@Component
struct VoipCallPage {
  @State username: string = 'Jack';
  @StorageLink('voipCallState') voipCallState: voipCall.VoipCallState =
    AppStorage.get('voipCallState') as voipCall.VoipCallState;
  @StorageLink('voipCallMuteState') voipCallMuteState: boolean = false;

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
        if (this.voipCallState === voipCall.VoipCallState.VOIP_CALL_STATE_RINGING) {
          Image($r('app.media.ic_public_hangup'))
            .width(56)
            .height(56)
            .onClick(async () => {
              Logger.info('reject call clicked');
              try {
                await voipCall.reportCallStateChange(AppStorage.get('voipCallId'),
                  voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
              } catch (error) {
                Logger.error(TAG, `reportCallStateChange failed,code is ${error.code},message is ${error.message}}`);
              }
              AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
            })
          Image($r('app.media.ic_public_answer'))
            .width(56)
            .height(56)
            .onClick(async () => {
              Logger.info('answer call clicked');
              try {
                await voipCall.reportCallStateChange(AppStorage.get('voipCallId'),
                  voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
              } catch (error) {
                Logger.error(TAG, `reportCallStateChange failed,code is ${error.code},message is ${error.message}}`);
              }
              AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE);
            })
            .margin({ left: 100 })
        } else if (this.voipCallState === voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE) {
          Image($r(this.voipCallMuteState ? 'app.media.ic_public_mute_on' : 'app.media.ic_public_mute'))
            .width(56)
            .height(56)
            .onClick(async () => {
              Logger.info('mute button clicked');
              this.voipCallMuteState = !this.voipCallMuteState;
              try {
                await voipCall.reportCallAudioEventChange(AppStorage.get('voipCallId'),
                  this.voipCallMuteState ? voipCall.CallAudioEvent.AUDIO_EVENT_MUTED :
                  voipCall.CallAudioEvent.AUDIO_EVENT_UNMUTED);
              } catch (error) {
                Logger.error(TAG, `reportCallAudioEventChange failed,code is ${error.code},message is ${error.message}}`);
              }
            })
          Image($r('app.media.ic_public_hangup'))
            .width(56)
            .height(56)
            .onClick(async () => {
              Logger.info('hangup call clicked');
              try {
                await voipCall.reportCallStateChange(AppStorage.get('voipCallId'),
                  voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
              } catch (error) {
                Logger.error(TAG, `reportCallStateChange failed,code is ${error.code},message is ${error.message}}`);
              }
              AppStorage.setOrCreate('voipCallState', voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED);
            })
            .margin({ left: 100 })
        }
      }
      .margin({ top: 300 })

    }
    .width('100%')
    .height('100%')
    .margin({ top: 100 })
  }

  getCallStateLabel(voipCallState: voipCall.VoipCallState): string {
    if (voipCallState === voipCall.VoipCallState.VOIP_CALL_STATE_RINGING) {
      return '来电';
    } else if (voipCallState === voipCall.VoipCallState.VOIP_CALL_STATE_ACTIVE) {
      return '通话中';
    } else if (voipCallState === voipCall.VoipCallState.VOIP_CALL_STATE_DIALING) {
      return '正在拨号';
    } else if (voipCallState === voipCall.VoipCallState.VOIP_CALL_STATE_DISCONNECTED) {
      return '通话结束';
    }
    return '';
  }
}