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

import { AVCastPicker } from '@kit.AVSessionKit';
import { inputConsumer, KeyCode } from '@kit.InputKit';
import { avSession } from '@kit.AVSessionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SongItem } from '../model/SongData';
import { BreakpointType } from '../common/utils/BreakpointSystem';
import { AudioCastController } from '../controller/AudioCastController';

const TAG = 'TopAreaComponent';

@Component
export struct TopAreaComponent {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
  @StorageProp('selectIndex') selectIndex: number = 0;
  @StorageLink('musicPageStack') musicPageStack: NavPathStack = new NavPathStack();
  @StorageLink('songList') songList: SongItem[] = [];
  @StorageLink('audioCastController')  @Watch('audioCastControllerStateChange') audioCastController?: AudioCastController = undefined;
  @StorageLink('volumeValue') volumeValue: number = 0;

  @State isDark: boolean = true;
  @State color: Color = Color.White;

  async audioCastControllerStateChange() {
    if (this.audioCastController) {
      if (this.audioCastController.state === avSession.PlaybackState.PLAYBACK_STATE_PREPARE) {
        this.startInputConsumer();
      }
    }
  }

  startInputConsumer() {
    let upOptions: inputConsumer.KeyPressedConfig = {
      key: KeyCode.KEYCODE_VOLUME_UP,
      action: 1,
      isRepeat: true,
    }
    let downOptions: inputConsumer.KeyPressedConfig = {
      key: KeyCode.KEYCODE_VOLUME_DOWN,
      action: 1,
      isRepeat: true,
    }
    try {
      inputConsumer.on('keyPressed', upOptions, async () => {
        if (this.audioCastController) {
          let volume = this.volumeValue + 10;
          await this.audioCastController.setAVCastVolume(volume);
        }
      });
      inputConsumer.on('keyPressed', downOptions, async () => {
        if (this.audioCastController) {
          let volume = this.volumeValue - 10;
          if (volume < 0) {
            await this.audioCastController.setAVCastVolume(0);
          }
          await this.audioCastController.setAVCastVolume(volume);
        }
      });
    } catch (error) {
      hilog.error(0x0000, TAG, 'inputConsumer on keyPressed failed.');
    }
  }

  build() {
    Row() {
      Image($r("app.media.ic_arrow_down"))
        .width(24)
        .height(24)
        .onClick(() => {
          this.musicPageStack.pop();
        })
      // [Start AVCastPicker]
      AVCastPicker({
        normalColor: this.color, activeColor: this.color,
      })
      // [End AVCastPicker]
        .width(new BreakpointType({
          sm: $r('app.float.common_iamge'),
          md: $r('app.float.common_iamge'),
          lg: $r('app.float.control_image_lg')
        }).getValue(this.currentBreakpoint))
        .height(new BreakpointType({
          sm: $r('app.float.common_iamge'),
          md: $r('app.float.common_iamge'),
          lg: $r('app.float.control_image_lg')
        }).getValue(this.currentBreakpoint))
    }
    .height($r('app.float.info_margin_top_sm'))
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}