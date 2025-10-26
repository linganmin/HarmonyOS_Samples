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
import libAdd from 'libAdd.so';
import libSub from 'libSub.so';
import { ParamTextInputComponent } from '../main/ets/view/ParamTextInputComponent';
import { promptAction } from '@kit.ArkUI';

@Component
export struct OfficialSecond {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State paramX: string = '';
  @State paramY: string = '';

  @Styles
  customButtonStyle(){
    .height(40)
    .width('100%')
  }

  customToast(str: ResourceStr) {
      promptAction.showToast({ message: str, duration: 2000, bottom: '80vp' })
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          ParamTextInputComponent({
            param: this.paramX,
            paramName: 'parameter X',
            inputAlert: 'Please input parameter X.',
          })
          ParamTextInputComponent({
            param: this.paramY,
            paramName: 'parameter Y',
            inputAlert: 'Please input parameter Y.',
          })
        }
        .width('100%')

        Blank()

        Column({ space: 12 }) {
          Button($r('app.string.default_add'))
            .customButtonStyle()
            .onClick(() => {
              let context = 'parameter X + Y = ';
              let result = libAdd.add(Number(this.paramX), Number(this.paramY));
              this.customToast(context + result.toString());
            })

          Button($r('app.string.default_sub'))
            .customButtonStyle()
            .onClick(() => {
              let context = 'parameter X - Y = ';
              let result = libSub.sub(Number(this.paramX), Number(this.paramY));
              this.customToast(context + result.toString());
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .height('100%')
      .backgroundColor('#F1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
  }
}