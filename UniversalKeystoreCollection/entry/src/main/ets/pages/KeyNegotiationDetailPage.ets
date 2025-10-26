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

import { Param } from '../viewmodel/RouterParam';
import { huks } from '@kit.UniversalKeystoreKit';
import {
  huksDhAgreeInHuks,
  publicExportKeyFunc,
  publicFinishFunc,
  publicGenKeyFunc,
  publicInitFunc,
  publicUpdateFunc
} from '../common/utils/KeyNegotiationUtils';
import { HuksPropertiesConstants } from '../common/constants/HuksPropertiesConstants';
import { CommonConstants } from '../common/constants/CommonConstants';

@Entry
@Component
struct KeyNegotiationDetailPage {
  mode: number = (this.getUIContext().getRouter().getParams() as Param).id;
  pubKeyA?: huks.HuksReturnResult;
  pubKeyB?: huks.HuksReturnResult;
  exportA?: Uint8Array;
  exportB?: Uint8Array;
  handle?: number;

  build() {
    Column() {
      Row() {
        Button() {
          Image($r('app.media.back'))
            .width($r('app.float.back_height'))
            .height($r('app.float.back_height'))
        }
        .width($r('app.float.back_height'))
        .height($r('app.float.back_height'))
        .type(ButtonType.Circle)
        .backgroundColor($r('app.color.back_button_backgroundColor'))
        .margin({
          left: $r('app.float.title_margin_left'),
          right: $r('app.float.title_margin_right')
        })
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })

        Text($r('app.string.Details'))
          .font({
            size: $r('app.float.title_font_size'),
            weight: CommonConstants.FONT_WEIGHT_700
          })
      }
      .alignItems(VerticalAlign.Center)
      .width(CommonConstants.FULL_PERCENT)

      Column() {
        Button($r('app.string.Generate_key_A'))
          .width($r('app.float.button_width'))
          .height($r('app.float.button_height'))
          .margin({ bottom: $r('app.float.button_margin_bottom') })
          .onClick(async () => {
            if (this.mode === 0) {
              await publicGenKeyFunc(HuksPropertiesConstants.SRC_KEY_ALISA_FIRST, HuksPropertiesConstants.HUKS_OPTIONS);
              await publicExportKeyFunc(HuksPropertiesConstants.SRC_KEY_ALISA_FIRST,
                HuksPropertiesConstants.HUKS_OPTIONS).then((data) => {
                this.exportA = data;
              });
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.Generate_key_A_Success'),
                duration: CommonConstants.TOAST_DURATION
              });
            } else {
              huks.generateKeyItem(HuksPropertiesConstants.ALISA_A, HuksPropertiesConstants.DH_GEN_OPTIONS);
              huks.exportKeyItem(HuksPropertiesConstants.ALISA_A, HuksPropertiesConstants.EMPTY_OPTION).then((data) => {
                this.pubKeyA = data;
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.Generate_key_A_Success'),
                  duration: CommonConstants.TOAST_DURATION
                });
              });
            }
          })
        Button($r('app.string.Generate_key_B'))
          .width($r('app.float.button_width'))
          .height($r('app.float.button_height'))
          .margin({ bottom: $r('app.float.button_margin_bottom') })
          .onClick(async () => {
            if (this.mode === 0) {
              await publicGenKeyFunc(HuksPropertiesConstants.SRC_KEY_ALISA_SECOND,
                HuksPropertiesConstants.HUKS_OPTIONS);
              await publicExportKeyFunc(HuksPropertiesConstants.SRC_KEY_ALISA_SECOND,
                HuksPropertiesConstants.HUKS_OPTIONS)
                .then((data) => {
                  this.exportB = data;
                });
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.Generate_key_B_Success'),
                duration: CommonConstants.TOAST_DURATION
              });
            } else {
              huks.generateKeyItem(HuksPropertiesConstants.ALISA_B, HuksPropertiesConstants.DH_GEN_OPTIONS);
              huks.exportKeyItem(HuksPropertiesConstants.ALISA_B, HuksPropertiesConstants.EMPTY_OPTION).then((data) => {
                this.pubKeyB = data;
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.Generate_key_B_Success'),
                  duration: CommonConstants.TOAST_DURATION
                });
              });
            }
          })
        Button($r('app.string.KeyNegotiation'))
          .width($r('app.float.button_width'))
          .height($r('app.float.button_height'))
          .margin({ bottom: $r('app.float.last_button_margin_bottom') })
          .onClick(async () => {
            if (this.mode === 0) {
              await publicInitFunc(HuksPropertiesConstants.SRC_KEY_ALISA_FIRST, HuksPropertiesConstants.HUKS_OPTIONS)
                .then((data) => {
                  this.handle = data;
                })
              let huksOption = HuksPropertiesConstants.HUKS_OPTIONS;
              huksOption.inData = this.exportB;
              if (this.handle !== undefined) {
                await publicUpdateFunc(this.handle, huksOption);
                await publicFinishFunc(this.handle, HuksPropertiesConstants.finishOptionsFirst);
              }
            } else {
              if (this.pubKeyA !== undefined && this.pubKeyB !== undefined) {
                huksDhAgreeInHuks(this.pubKeyA, this.pubKeyB);
              } else {
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.key_missing'),
                  duration: CommonConstants.TOAST_DURATION
                });
              }
            }
          })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}