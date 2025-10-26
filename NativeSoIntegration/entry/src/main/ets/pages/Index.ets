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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { deviceInfo } from '@kit.BasicServicesKit'
import testNapi from 'libentry.so';
import multiplyNapi from 'libmultiply.so';
import { ParamTextInputComponent } from '../view/ParamTextInputComponent';

@Entry
@Component
struct Index {
  @State paramX: string = '';
  @State paramY: string = '';

  @Styles
  customButtonStyle() {
    .height('40vp')
    .width('100%')
  }

  customToast(str: string) {
    hilog.info(0x0000, 'showToast', '%{public}s', `Integrate SO library and calculate: ${str}`);
    try {
      this.getUIContext().getPromptAction().showToast({
        message: str,
        duration: 2000,
        bottom: '80vp',
        backgroundColor: Color.White,
        backgroundBlurStyle: BlurStyle.NONE
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      hilog.info(0x0000, 'showToast', '%{public}s', `showToast args error code is ${code}, message is ${message}`);
    }
  }

  build() {
    Navigation() {
      Column() {
        Column() {
          ParamTextInputComponent({
            param: this.paramX,
            paramName: $r('app.string.parameter_x'),
            inputAlert: $r('app.string.parameter_x_input')
          })
          ParamTextInputComponent({
            param: this.paramY,
            paramName: $r('app.string.parameter_y'),
            inputAlert: $r('app.string.parameter_y_input')
          })
        }
        .margin({
          top: '56vp'
        })

        Blank()

        Column({ space: 12 }) {
          Button($r('app.string.native_so_add'))
            .customButtonStyle()
            .onClick(() => {
              let content =
                this.getUIContext().getHostContext()!.resourceManager.getStringByNameSync('native_so_content');
              // [Start NativeValidateSoAdd]
              // Integrate the SO library on the Native side directly to complete the addition operation
              let result = testNapi.nativeAdd(Number(this.paramX), Number(this.paramY));
              // [End NativeValidateSoAdd]
              if (this.paramX === '' || this.paramY === '') {
                this.customToast(this.getUIContext()
                  .getHostContext()!.resourceManager.getStringByNameSync('input_alert'));
              } else {
                this.customToast(`${content}${result.toString()}`);
              }
            })
          Button($r('app.string.native_so_dlopen_sub'))
            .customButtonStyle()
            .onClick(() => {
              let content = this.getUIContext()
                .getHostContext()!.resourceManager.getStringByNameSync('native_so_dlopen_content');
              // [Start GetThePath]
              let projectPath = this.getUIContext().getHostContext()!.bundleCodeDir; // Get the project path
              let abiPath = deviceInfo.abiList === 'x86_64' ? 'x86_64' : 'arm64';
              let soLibPath = `${projectPath}/libs/${abiPath}/libnativeSub.so`;
              // [End GetThePath]
              // [Start NativeValidateSoSub]
              // Integrate the SO library on the Native side by dlopen to complete the subtraction operation
              let result = testNapi.nativeSub(Number(this.paramX), Number(this.paramY), soLibPath);
              // [End NativeValidateSoSub]
              if (this.paramX === '' || this.paramY === '') {
                this.customToast(this.getUIContext()
                  .getHostContext()!.resourceManager.getStringByNameSync('input_alert'));
              } else {
                this.customToast(`${content}${result.toString()}`);
              }
            })
          Button($r('app.string.arkts_so_multiply'))
            .customButtonStyle()
            .onClick(() => {
              let content =
                this.getUIContext().getHostContext()!.resourceManager.getStringByNameSync('arkts_so_content');
              // [Start ArkTSValidateSo]
              // Integrate the SO library that has been adapted to Native On the ArkTS side to complete the multiplication operation
              let result = multiplyNapi.multiply(Number(this.paramX), Number(this.paramY));
              // [End ArkTSValidateSo]
              if (this.paramX === '' || this.paramY === '') {
                this.customToast(this.getUIContext()
                  .getHostContext()!.resourceManager.getStringByNameSync('input_alert'));
              } else {
                this.customToast(`${content}${result.toString()}`);
              }
            })
        }
        .width('100%')
        .margin({
          bottom: '16vp'
        })
        .padding({
          left: '16vp',
          right: '16vp'
        })
      }
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .title($r('app.string.main_title'))
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}