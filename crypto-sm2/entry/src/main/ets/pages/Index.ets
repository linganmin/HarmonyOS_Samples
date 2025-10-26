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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { buffer, util } from '@kit.ArkTS';
import { decryptSM2, encryptSM2 } from '../utils/SM2';
import { SM2CipherText } from '../utils/SM2CipherText';

const TEXT_LABEL_WIDTH = '20%';
const TEXT_FONT_SIZE = 15;
const TEXT_VALUE_WIDTH = '50%';
const TEXT_MARGIN = 2;

const BTN_BORDER_RADIUS = 8;
const BTN_FONT_SIZE = 20;
const BTN_MARGIN = 15;

const DOMAIN = 0x0000;
const TAG = 'Index';
const FORMAT = '%{public}s';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State enMsg: string = '';
  @State deMsg: string = '';
  @State isBase64: Boolean = true;
  @State isc1c3c2: Boolean = false;
  @State msgType: Resource = $r('app.string.text_asn1');
  @State msgFmt: Resource = $r('app.string.text_base64');

  build() {
    Row() {
      Column() {
        Row() {
          Text($r('app.string.text_origin_data'))
            .width(TEXT_LABEL_WIDTH)
            .fontSize(TEXT_FONT_SIZE)
          Text(this.message)
            .width(TEXT_VALUE_WIDTH)
            .margin(TEXT_MARGIN)
            .fontSize(TEXT_FONT_SIZE)
        }
        .height(50)

        Row() {
          Column() {
            Text($r('app.string.text_encode_data'))
              .width(TEXT_LABEL_WIDTH)
              .fontSize(TEXT_FONT_SIZE)
            Text(this.msgType)
              .width(TEXT_LABEL_WIDTH)
              .fontSize(TEXT_FONT_SIZE)
            Text(this.msgFmt)
              .width(TEXT_LABEL_WIDTH)
              .fontSize(TEXT_FONT_SIZE)
          }

          Text(this.enMsg)
            .width(TEXT_VALUE_WIDTH)
            .margin(TEXT_MARGIN)
            .fontSize(TEXT_FONT_SIZE)
        }
        .height(250)

        Row() {
          Text($r('app.string.text_decode_data'))
            .width(TEXT_LABEL_WIDTH)
            .fontSize(TEXT_FONT_SIZE)
          Text(this.deMsg)
            .width(TEXT_VALUE_WIDTH)
            .margin(TEXT_MARGIN)
            .fontSize(TEXT_FONT_SIZE)
        }
        .height(50)

        Button($r('app.string.btn_encode'), { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(BTN_BORDER_RADIUS)
          .fontSize(BTN_FONT_SIZE)
          .margin(BTN_MARGIN)
          .enabled(!this.isc1c3c2)
          .onClick(() => {
            encryptSM2(this.message).then((msg: string) => {
              if (this.isBase64) {
                this.enMsg = msg;
              } else {
                let base64Helper = new util.Base64Helper();
                try {
                  this.enMsg = buffer.from(base64Helper.decodeSync(msg).buffer).toString('hex');
                } catch (err) {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `Buffer from failed. Cause code: ${err.code}, message: ${err.message}`);
                }
              }
              this.deMsg = '';
            });
          })

        Button($r('app.string.btn_decode'), { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(BTN_BORDER_RADIUS)
          .fontSize(BTN_FONT_SIZE)
          .margin(BTN_MARGIN)
          .enabled(this.enMsg != '' && this.deMsg == '')
          .onClick(() => {
            let msg = this.enMsg;
            if (!this.isBase64 && !this.isc1c3c2) {
              let base64Helper = new util.Base64Helper();
              msg = base64Helper.encodeToStringSync(new Uint8Array(buffer.from(this.enMsg, 'hex').buffer));
            }
            decryptSM2(msg, this.isc1c3c2).then((msg: string) => {
              this.deMsg = msg;
            });
          })

        Button($r('app.string.btn_base64_convert'), { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(BTN_BORDER_RADIUS)
          .fontSize(BTN_FONT_SIZE)
          .margin(BTN_MARGIN)
          .enabled(!this.isc1c3c2 && this.enMsg != '')
          .onClick(() => {
            let base64Helper = new util.Base64Helper();
            if (this.isBase64) {
              try {
                this.enMsg = buffer.from(base64Helper.decodeSync(this.enMsg).buffer).toString('hex');
                this.isBase64 = false;
                this.msgFmt = $r('app.string.text_hex')
              } catch (err) {
                hilog.error(DOMAIN, TAG, FORMAT,
                  `Buffer from failed. Cause code: ${err.code}, message: ${err.message}`);
              }
            } else {
              this.enMsg = base64Helper.encodeToStringSync(new Uint8Array(buffer.from(this.enMsg, 'hex').buffer));
              this.isBase64 = true;
              this.msgFmt = $r('app.string.text_base64')
            }
          })
        Button($r('app.string.btn_asn1_convert'), { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(BTN_BORDER_RADIUS)
          .fontSize(BTN_FONT_SIZE)
          .margin(BTN_MARGIN)
          .enabled(!this.isBase64)
          .onClick(() => {
            if (this.isc1c3c2) {
              this.enMsg = new SM2CipherText().i2dSM2CipherText(this.enMsg);
              this.isc1c3c2 = false;
              this.msgType = $r('app.string.text_asn1')
            } else {
              this.enMsg = new SM2CipherText().d2iSM2CipherText(this.enMsg);
              this.isc1c3c2 = true;
              this.msgType = $r('app.string.text_c1c3c2')
            }
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}