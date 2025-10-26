/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { audio } from '@kit.AudioKit';
import { AudioCapturerController, AudioRendererController } from '@ohos/mediaservice';
import { ResourceConstants } from '../common/constants/ResourceConstants';
import { AppStore } from '../common/store/AppStore';

@Component
export struct IconContent {
  @StorageLink('isPlaying') isPlaying: boolean = false;
  @StorageLink('isCapturering') isCapturering: boolean = false;
  private iconSrc: number = 0;
  private sceneText: string = '';
  private isInteractive: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(ResourceConstants.IMAGE_RESOURCE[this.iconSrc])
        .width(200)
        .height(200);

      if (this.sceneText) {
        Text(this.sceneText);
      }

      if (this.isInteractive) {
        if (AppStore.getInstance().currentAudioType === 'recording') {
          Row() {
            Image(this.isCapturering ? $r('app.media.record_stop') : $r('app.media.record_start'))
              .width(24)
              .height(24)
              .margin({ right: 16 })
              .onClick(() => {
                let currentAudioType: string | undefined = AppStore.getInstance().currentAudioType;
                if (!currentAudioType) {
                  return;
                }
                this.isCapturering = !this.isCapturering;
                if (this.isCapturering) {
                  AudioCapturerController.getInstance().start();
                } else {
                  AudioCapturerController.getInstance().stop();
                }
              });
            Text(this.isCapturering ? $r('app.string.sound_recording_progress') :
            $r('app.string.sound_recording_stop'));
          };
        } else {
          Row() {
            Image(this.isPlaying ? $r('sys.media.ohos_ic_public_pause') : $r('app.media.public_ic_public_play'))
              .width(24)
              .height(24)
              .margin({ right: 26 })
              .onClick(() => {
                let currentAudioType: string | undefined = AppStore.getInstance().currentAudioType;
                if (!currentAudioType) {
                  return;
                }
                this.isPlaying = !this.isPlaying;
                if (this.isPlaying) {
                  AudioRendererController.getInstance(audio.StreamUsage[currentAudioType]).play();
                } else {
                  AudioRendererController.getInstance(audio.StreamUsage[currentAudioType]).pause();
                }
              });
            Image($r('app.media.svg_8'))
              .width(24)
              .height(24)
              .onClick(() => {
                let currentAudioType: string | undefined = AppStore.getInstance().currentAudioType;
                if (!currentAudioType) {
                  return;
                }
                AudioRendererController.getInstance(audio.StreamUsage[currentAudioType]).reset();
              });
          };
        }
      }
    }
    .width('100%')
    .height(200)
    .margin({
      top: 16,
      bottom: 46
    });
  }
}