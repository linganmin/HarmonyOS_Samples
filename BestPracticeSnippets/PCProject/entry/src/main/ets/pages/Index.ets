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

import { AbilityConstant, bundleManager, common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;
const TAG = 'Index';

@Entry
@Component
struct Index {
  @State floatWindow: window.Window | undefined = undefined;
  // [Start create_float_window_background]
  async createFloatWindowBackground() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      window.getLastWindow(context, (err: BusinessError, topWindow) => {
        const errCode: number = err.code;
        if (errCode) {
          hilog.error(DOMAIN, TAG, '%{public}s',
            `Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
          return;
        }
        topWindow.minimize().catch((err: BusinessError) => {
          hilog.error(DOMAIN, TAG, '%{public}s',
            `Failed to minimize the window. Code: ${err.code}, message: ${err.message}`);
        });
        hilog.info(DOMAIN, TAG, '%{public}s',
          `Succeeded in obtaining the top window. Window id: ${topWindow.getWindowProperties().id}`);
        setTimeout(() => {
          this.createFloatWindow();
        }, 5000);
      });
    } catch (err) {
      hilog.error(DOMAIN, TAG, '%{public}s',
        `Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
    }
  }
  // [End create_float_window_background]
  async createFloatWindow() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let floatWindowName = 'floatWindow';
    let config: window.Configuration = {
      name: floatWindowName,
      windowType: window.WindowType.TYPE_FLOAT,
      ctx: context
    };
    try {
      let floatWindow: window.Window = await window.createWindow(config);
      let storage: LocalStorage = new LocalStorage();
      await floatWindow.moveWindowTo(250, 200);
      await floatWindow.resize(1800, 600);
      await floatWindow.setWindowCornerRadius(50);
      floatWindow.setWindowShadowRadius(50);
      await floatWindow.loadContent('pages/Index', storage);
      floatWindow.showWindow().catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, '%{public}s', `Failed to show the window. Code: ${err.code}, message: ${err.message}`);
      });
      this.floatWindow = floatWindow;
      storage.setOrCreate('name', floatWindowName);
    } catch (err) {
      hilog.error(DOMAIN, TAG, '%{public}s',
        `Failed to create the window. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  build() {
    Column() {
      Button('Start Ability windowMode', { controlSize: ControlSize.SMALL })
        .width(448)
        .margin({
          right: 16,
          bottom: 16,
          left: 16
        })
        .onClick(() => {
          // [Start start_ability_full_screens]
          let want: Want = {
            bundleName: 'com.example.pcproject',
            abilityName: 'SubEntryAbility'
          };
          try {
            (this.getUIContext().getHostContext() as common.UIAbilityContext).startAbility(want, {
              windowMode: AbilityConstant.WindowMode.WINDOW_MODE_FULLSCREEN,
              supportWindowModes: [bundleManager.SupportWindowMode.FULL_SCREEN]
            })
              .then(() => {
                // Carry out normal business operations
                hilog.info(DOMAIN, TAG, '%{public}s', 'startAbility succeed');
              })
              .catch((err: BusinessError) => {
                // Handle business logic errors
                hilog.error(DOMAIN, TAG, '%{public}s',
                  `startAbility failed. Cause code: ${err.code}, message: ${err.message}`);
              });
          } catch (err) {
            // Handle the err of incorrect input parameters
            hilog.error(DOMAIN, TAG, '%{public}s',
              `startAbility failed. Cause code: ${err.code}, message: ${err.message}`);
          }
          // [End start_ability_full_screens]
        })

      Button('Start Ability windowModes', { controlSize: ControlSize.SMALL })
        .width(448)
        .margin({
          right: 16,
          bottom: 16,
          left: 16
        })
        .onClick(() => {
          // [Start start_ability_full_screen]
          let want: Want = {
            bundleName: 'com.example.pcproject',
            abilityName: 'SubEntryAbility'
          };
          try {
            (this.getUIContext().getHostContext() as common.UIAbilityContext).startAbility(want, {
              supportWindowModes: [bundleManager.SupportWindowMode.FULL_SCREEN]
            })
              .then(() => {
                // Carry out normal business operations
                hilog.info(DOMAIN, TAG, '%{public}s', 'startAbility succeed');
              })
              .catch((err: BusinessError) => {
                // Handle business logic errors
                hilog.error(DOMAIN, TAG, '%{public}s',
                  `startAbility failed. Cause code: ${err.code}, message: ${err.message}`);
              });
          } catch (err) {
            // Handle the err of incorrect input parameters
            hilog.error(DOMAIN, TAG, '%{public}s',
              `startAbility failed. Cause code: ${err.code}, message: ${err.message}`);
          }
          // [End start_ability_full_screen]
        })

      Button('Start Ability windowSize', { controlSize: ControlSize.SMALL })
        .width(448)
        .margin({
          right: 16,
          bottom: 16,
          left: 16
        })
        .onClick(() => {
          // [Start start_ability_window]
          let want: Want = {
            bundleName: 'com.example.pcproject',
            abilityName: 'SubEntryAbility'
          };
          try {
            (this.getUIContext().getHostContext() as common.UIAbilityContext).startAbility(want, {
              windowLeft: 700,
              windowTop: 300,
              windowWidth: 1600,
              windowHeight: 1000,
              minWindowWidth: 800,
              minWindowHeight: 600
            })
              .then(() => {
                // Carry out normal business operations
                hilog.info(DOMAIN, TAG, '%{public}s', 'startAbility succeed');
              })
              .catch((err: BusinessError) => {
                // Handle business logic errors
                hilog.error(DOMAIN, TAG, '%{public}s',
                  `startAbility failed. Cause code: ${err.code}, message: ${err.message}`);
              });
          } catch (err) {
            // Handle the err of incorrect input parameters
            hilog.error(DOMAIN, TAG, '%{public}s',
              `startAbility failed. Cause code: ${err.code}, message: ${err.message}`);
          }
          // [End start_ability_window]
        })
      // [Start scan_bar_code]
      Button('Scan Bar Code', { controlSize: ControlSize.SMALL })
        .width(448)
        .margin({
          right: 16,
          bottom: 16,
          left: 16
        })
        .onClick(() => {
          const isLocationAvailable = canIUse('SystemCapability.Multimedia.Scan.ScanBarcode');
          try {
            if (isLocationAvailable) {
              this.getUIContext().getPromptAction().showToast({ message: 'Scan bar code.' });
            } else {
              this.getUIContext().getPromptAction().showToast({ message: 'Scan bar code is not supported' });
            }
          } catch (err) {
            hilog.error(DOMAIN, TAG, '%{public}s',
              `showToast args error. Cause code: ${err.code}, message: ${err.message}`);
          }
        })
      // [End scan_bar_code]
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    // [Start touch_start_moving]
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        try {
          let windowClass: window.Window = window.findWindow('floatWindow');
          if (!windowClass) {
            hilog.error(DOMAIN, TAG, '%{public}s', 'Failed to find window.');
            return;
          }
          windowClass.startMoving().then(() => {
            hilog.info(DOMAIN, TAG, '%{public}s', 'Succeeded in starting moving window.')
          }).catch((err: BusinessError) => {
            hilog.error(DOMAIN, TAG, '%{public}s',
              `Failed to start moving. Cause code: ${err.code}, message: ${err.message}`);
          });
        } catch (err) {
          hilog.error(DOMAIN, TAG, '%{public}s',
            `Failed to start moving window. Cause code: ${err.code}, message: ${err.message}`);
        }
      }
    })
    // [End touch_start_moving]
    .padding({
      right: 16,
      left: 16
    })
  }
}