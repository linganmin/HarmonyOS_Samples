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
import { BusinessError } from '@kit.BasicServicesKit';
import Constants from '../common/Constants';
import Logger from '../utils/Logger';

@Entry
@Component
struct InputPage {
  @StorageLink('inputText') inputText: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  onPageShow(): void {
    Logger.info(this.inputText);
  }

  build() {
    Row() {
      TextArea({
        text: this.inputText,
        placeholder: $r('app.string.talk_something')
      })
        .fontWeight(Constants.FONT_WEIGHT_MD)
        .fontSize($r('app.integer.comm_font_size30'))
        .textAlign(TextAlign.Center)
        .align(Alignment.Center)
        .width(Constants.EIGHTY_PERCENT)
        .onChange((value: string) => {
          this.inputText = value;
          AppStorage.set('inputText', value);
        })
        .backgroundColor(Color.Transparent)
        .outlineColor($r('app.color.normal_blue_color'))
        .restoreId(2)
        .id('textInput')

      Blank()

      Row() {
        Button($r('app.string.input_submit'), { type: ButtonType.Normal, stateEffect: true })
          .height($r('app.integer.comm_btn_height'))
          .width($r('app.integer.comm_btn_width'))
          .backgroundColor(0x317aff)
          .borderRadius($r('app.integer.normal_component_border_radius'))
          .margin($r('app.integer.normal_component_list_margin'))
          .onClick(() => {
            const RESULT_CODE: number = 1001;
            this.context.terminateSelfWithResult(
              {
                resultCode: RESULT_CODE,
                want: {
                  bundleName: 'com.example.codelab',
                  abilityName: 'EntryAbility',
                  moduleName: 'entry',
                  parameters: {
                    comment: this.inputText
                  }
                }
              },
              (err: BusinessError) => {
                Logger.error(JSON.stringify(err));
              });
          })
      }
      .margin({ left: $r('app.integer.normal_component_list_margin_1') })
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
  }
}