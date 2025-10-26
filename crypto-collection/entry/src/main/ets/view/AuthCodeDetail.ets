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

import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';
import CommonConstants from '../constants/CommonConstants';
import { AuthCodeItem } from '../viewmodel/AuthCodeItem';
import { getResourceString } from '../utils/ResourceString';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function AuthCodeDetailBuilder() {
  AuthCodeDetail();
}

const TAG: string = 'AuthCodeDetail';

@Component
export struct AuthCodeDetail {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State AuthCodeItem: AuthCodeItem = new AuthCodeItem($r('app.string.empty'));
  @State message: string = '';
  @State MessageResult: string = '';

  aboutToAppear(): void {
    this.AuthCodeItem = this.pageInfos.getParamByName('AuthCodeDetail')[0] as AuthCodeItem;
  }

  async genSymKeyByData(symKeyData: Uint8Array) {
    try {
      let symKeyBlob: cryptoFramework.DataBlob = { data: symKeyData };
      let aesGenerator = cryptoFramework.createSymKeyGenerator('HMAC');
      let symKey = await aesGenerator.convertKey(symKeyBlob);
      return symKey;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `genSymKeyByData failed, error code=${err.code}, message=${err.message}`);
      return undefined;
    }
  }

  async doHmac() {
    try {
      // Decode the string in utf-8 to Uint8Array, using a fixed 128-bit key,i.e. 16 bytes.
      let keyData = new Uint8Array(buffer.from('12345678abcdefgh', 'utf-8').buffer);
      let key = await this.genSymKeyByData(keyData);
      if (!key) {
        return;
      }
      let macAlgName = 'SHA256'; // Digest algorithm name.
      let mac = cryptoFramework.createMac(macAlgName);
      await mac.init(key);
      if (this.AuthCodeItem.name === $r('app.string.calculate_seg_code')) {
        let messageData = new Uint8Array(buffer.from(this.message, 'utf-8').buffer);
        // Assume that the segment update is performed in the unit of 20 bytes. in practice,there is no requirement.
        let updateLength = 20;
        for (let i = 0; i < messageData.length; i += updateLength) {
          let updateMessage = messageData.subarray(i, i + updateLength);
          let updateMessageBlob: cryptoFramework.DataBlob = { data: updateMessage };
          await mac.update(updateMessageBlob);
        }
      } else {
        await mac.update({ data: new Uint8Array(buffer.from(this.message, 'utf-8').buffer) });
      }
      let macResult = await mac.doFinal();
      this.MessageResult = `${macResult.data}`;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `doHmac failed, error code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          TextInput({ text: this.message, placeholder: $r('app.string.text_message_code') })
            .margin({ top: $r('app.float.margin_top_sixteen') })
            .backgroundColor(Color.White)
            .onChange((value) => {
              this.message = value;
            })

          Column() {
            Text($r('app.string.message_code_result'))
              .margin({ left: $r('app.float.margin_left_five') })

            TextArea({ text: this.MessageResult })
              .height($r('app.float.textarea_height'))
              .margin({ top: $r('app.float.margin_top_sixteen') })
              .backgroundColor(Color.White)
              .enabled(false)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ top: $r('app.float.margin_top_sixteen') })
        }

        Button() {
          Text(this.AuthCodeItem.name)
            .fontSize($r('app.float.common_font'))
            .fontColor(Color.White)
        }
        .onClick(() => {
          this.doHmac();
        })
        .enabled(this.message ? true : false)
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.button_height'))
        .margin({ top: $r('app.float.margin_top_sixteen') })
      }
      .padding({
        left: $r('app.float.medium_padding'),
        right: $r('app.float.medium_padding'),
        bottom: $r('app.float.medium_padding')
      })
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title(getResourceString(this.AuthCodeItem.name, this.getUIContext()))
    .backgroundColor($r('app.color.background_page'))
  }
}