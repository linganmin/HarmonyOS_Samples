/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何获取与设置屏幕亮度
*/

import { promptAction, window } from '@kit.ArkUI';
import { BusinessError, settings } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'brightness';

@Entry
@Component
struct Index {
  @State settingsBrightness: string = '';
  @State windowBrightness: number = 0;
  private context: Context = this.getUIContext().getHostContext() as Context;
  private windowClass: window.Window = AppStorage.get('windowClass') as window.Window;

  build() {
    Column() {
      Column() {
        Text('通过settings模块实现')
        Column() {
          Text('当前屏幕亮度' + this.settingsBrightness + '(范围0-255)')
          // [Start getBrightnessOne]
          Button('获取屏幕亮度')
            .width(328)
            .margin({
              top: 16,
              bottom:16
            })
            .onClick(() => {
              // Get screen brightness through the getValueSync() method.
              this.settingsBrightness = settings.getValueSync(this.context, settings.display.SCREEN_BRIGHTNESS_STATUS, '10');
            })
          // [End getBrightnessOne]
          Button('设置屏幕亮度')
            .width(328)
            .onClick(() => {
              // settings.setValue() is only available for system applications.
              promptAction.showToast({
                message: 'settings.setValue方法仅系统应用使用'
              });
            })
        }
      }
      .margin({
        bottom: 40
      })

      Column() {
        Text('通过window模块实现')
        Column() {
          Text('当前屏幕亮度' + this.windowBrightness + '(范围0-1)')
          // [Start getBrightnessTwo]
          Button('获取屏幕亮度')
            .width(328)
            .margin({
              top: 16,
              bottom:16
            })
            .onClick(() => {
              try {
                // By retrieving window properties using getWindowProperties(), the screen brightness can be obtained.
                let properties = this.windowClass?.getWindowProperties();
                this.windowBrightness = properties?.brightness ?? -1;
              } catch (exception) {
                hilog.error(0x0000, TAG,
                  `Failed to obtain the window properties. Cause code: ${exception.code}, message: ${exception.message}`);
              }
            })
          // [End getBrightnessTwo]
          // [Start setBrightnessTwo]
          Button('设置屏幕亮度')
            .width(328)
            .onClick(() => {
              try {
                this.windowBrightness = Math.random() * (1.0 - 0.0) + 0.0;
                if (this.windowBrightness < 0 || this.windowBrightness > 1) {
                  hilog.error(0x0000, TAG, `WindowBrightness is not within the valid range`);
                  return;
                }
                this.windowClass?.setWindowBrightness(this.windowBrightness, (err: BusinessError) => {
                  const errCode: number = err.code;
                  if (errCode) {
                    hilog.error(0x0000, TAG,
                      `Failed to set the brightness. Cause code: ${err.code}, message: ${err.message}`);
                    return;
                  }
                  hilog.info(0x0000, TAG, 'Succeeded in setting the brightness.');
                });
              } catch (exception) {
                hilog.error(0x0000, TAG,
                  `Failed to set the brightness. Cause code: ${exception.code}, message: ${exception.message}`);
              }
            })
          // [End setBrightnessTwo]
        }
      }
    }
    .height('100%')
    .width('100%')
  }
}