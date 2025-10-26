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
import { emitter } from '@kit.BasicServicesKit';
import { AVCastPicker, AVCastPickerState } from '@kit.AVSessionKit';
import Logger from '../common/utils/Logger';
import { Constants } from '../common/constants/Constants';
import AudioCapabilityManager from '../viewmodel/AudioCapabilityManager';

const Tag: string = Constants.CUSTOM_PICKER_TAG;

let innerEventRefreshing: emitter.InnerEvent = {
  eventId: 1,
  priority: emitter.EventPriority.HIGH
};

@Component
export struct CustomPickerComponent {
  @State avCastPickerColor: Color = Color.Blue;
  @State pickerImage: ResourceStr = $r('app.media.ear');
  @State callingEnable: boolean = true;
  @Link audioCapabilityManager: AudioCapabilityManager;

  private changePickerShow(desc: audio.AudioDeviceDescriptors | undefined) {
    if (!desc) {
      return;
    }
    switch (desc[0].deviceType) {
      case 1:
        this.pickerImage = $r('app.media.ear');
        break;
      case 2:
        this.pickerImage = $r('app.media.speaker_wave_3');
        break;
      case 7:
        this.pickerImage = $r('app.media.bluetooth');
        break;
      case 22:
        this.pickerImage = $r('app.media.headphones_fill');
        break;
      default:
        this.pickerImage = $r('app.media.ear');
        break;
    }
  }

  @Builder
  ImageBuilder(): void {
    Image(this.pickerImage)
      .size({
        width: $r('app.float.default_button_image_width'),
        height: $r('app.float.default_button_image_height')
      })
      .fillColor($r('app.color.custom_in_button_color'))
  }

  build() {
    NavDestination() {
      Row() {
        Button() {
          Image($r('app.media.phone_fill'))
            .size({
              width: $r('app.float.default_button_image_width'),
              height: $r('app.float.default_button_image_height')
            })
            .fillColor($r('app.color.custom_in_button_color'))
        }
        .backgroundColor(this.callingEnable ? $r('app.color.custom_calling_color') :
          $r('app.color.default_cancel_color'))
        .size({
          width: $r('app.float.default_button_width'),
          height: $r('app.float.default_button_height')
        })
        .type(ButtonType.Circle)
        .margin({
          bottom: $r('app.float.default_button_margin_bottom'),
          left: $r('app.float.default_button_margin_space')
        })
        .enabled(this.callingEnable)
        .onClick(async () => {
          await this.audioCapabilityManager.startRenderer();
          this.callingEnable = false;
        })

        Button() {
          Image($r('app.media.xmark'))
            .size({
              width: $r('app.float.default_button_image_width'),
              height: $r('app.float.default_button_image_height')
            })
            .fillColor($r('app.color.custom_in_button_color'))
        }
        .backgroundColor(this.callingEnable ? $r('app.color.default_cancel_color') :
          $r('app.color.custom_calling_color'))
        .size({
          width: $r('app.float.default_button_width'),
          height: $r('app.float.default_button_height')
        })
        .type(ButtonType.Circle)
        .margin({ bottom: $r('app.float.default_button_margin_bottom') })
        .enabled(!this.callingEnable)
        .onClick(async () => {
          await this.audioCapabilityManager.stopRenderer();
          this.callingEnable = true;
        })

        Button() {
          AVCastPicker({
            normalColor: this.avCastPickerColor,
            activeColor: this.avCastPickerColor,
            customPicker: () => {
              this.ImageBuilder();
            },
            onStateChange: (state: AVCastPickerState) => {
              Logger.info(Tag, `change avcastpicker: ${state}`);
            }
          })
        }
        .visibility(this.callingEnable ? Visibility.Hidden : Visibility.Visible)
        .backgroundColor(Color.White)
        .size({
          width: $r('app.float.default_button_width'),
          height: $r('app.float.default_button_height')
        })
        .type(ButtonType.Circle)
        .margin({
          bottom: $r('app.float.default_button_margin_bottom'),
          right: $r('app.float.default_button_margin_space')
        })
      }
      .size({
        width: $r('app.string.full_width'),
        height: $r('app.string.full_height')
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom)
    }
    .size({
      width: $r('app.string.full_width'),
      height: $r('app.string.full_height')
    })
    .onWillAppear(async () => {
      await this.audioCapabilityManager.init();
      this.changePickerShow(this.audioCapabilityManager.deviceDesc);
    })
    .onShown(() => {
      emitter.on(innerEventRefreshing, () => {
        this.changePickerShow(this.audioCapabilityManager.deviceDesc);
      });
    })
    .onHidden(async () => {
      emitter.off(innerEventRefreshing.eventId);
      await this.audioCapabilityManager.stopRenderer();
      this.callingEnable = true;
    })
    .onWillDisappear(async () => {
      this.audioCapabilityManager.cancelObserverDevices();
      await this.audioCapabilityManager.destroySession();
    })
    .backgroundColor($r('app.color.custom_window_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}