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

import { common } from '@kit.AbilityKit';
import { setDarkColorMode, setLightColorMode, setAutoColorMode } from '../viewmodel/ColorModeChangeFunctions';

@Component
export struct DarkModeSetting {
  @StorageProp('enableDarkMode') enableDarkMode: boolean = false;
  @StorageProp('isFollowSystemSetting') isFollowSystemSetting: boolean = true;
  @StorageProp('currentColorMode') currentColorMode: number = 0;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToDisappear(): void {
    AppStorage.setOrCreate('enableDarkMode', this.enableDarkMode);
    AppStorage.setOrCreate('isFollowSystemSetting', this.isFollowSystemSetting);
  }

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.follow_system_settings_switch_mode'))
          .fontColor($r('app.color.sub_text_color'))
          .fontSize(14)
          .fontWeight(400)
          .lineHeight(20)
          .margin({ bottom: 16, top: 8 })
          .width('100%')
          .textAlign(TextAlign.Start)
        Row() {
          Text($r('app.string.follow_system_settings'))
            .fontColor($r('app.color.font_color'))
            .fontSize(16)
            .fontWeight(500)
            .lineHeight(22)
          Toggle({ type: ToggleType.Switch, isOn: this.isFollowSystemSetting })
            .onChange((isOn: boolean) => {
              if (isOn) {
                this.isFollowSystemSetting = true;
                this.enableDarkMode = false;
                setAutoColorMode(this.context);
              } else {
                this.isFollowSystemSetting = false;
                if (this.enableDarkMode) {
                  setDarkColorMode(this.context);
                } else {
                  setLightColorMode(this.context);
                }
              }
            })
        }
        .width('100%')
        .height(56)
        .backgroundColor($r('app.color.item_box'))
        .margin({ bottom: 12 })
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.SpaceBetween)
        .borderRadius(12)

        Row() {
          Text($r('app.string.dark_mode'))
            .fontColor($r('app.color.font_color'))
            .fontSize(16)
            .fontWeight(500)
            .lineHeight(22)
          Toggle({ type: ToggleType.Switch, isOn: this.enableDarkMode })
            .onChange((isOn: boolean) => {
              this.enableDarkMode = isOn;
              if (isOn) {
                this.isFollowSystemSetting = false;
                setDarkColorMode(this.context);
              } else if (!this.isFollowSystemSetting) {
                setLightColorMode(this.context);
              }
            })
        }
        .width('100%')
        .height(56)
        .backgroundColor($r('app.color.item_box'))
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.SpaceBetween)
        .borderRadius(12)
      }
      .padding({ left: 16, right: 16 })
    }
    .title('Dark Mode')
    .backgroundColor($r('app.color.app_background_color'))
  }
}