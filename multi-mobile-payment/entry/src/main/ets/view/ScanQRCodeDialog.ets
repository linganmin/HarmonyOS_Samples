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

import { Constants } from '../common/Constants';
import { XComponentView } from './XComponentView';

@Builder
export function FunctionCard(icon: Resource, text: Resource, clickCallback: Function) {
  Column() {
    Row() {
      Image(icon)
        .width(Constants.FULL_WIDTH)
    }
    .width($r('app.float.quick_function_item_image_size_smaller'))
    .height($r('app.float.quick_function_item_image_size_smaller'))
    .backgroundColor($r('app.color.scan_option_bgc'))
    .borderRadius($r('app.float.br20'))
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: $r('app.float.span3dot5') })

    Text(text)
      .fontFamily($r('app.string.normal_font_family'))
      .fontSize($r('app.float.smaller_font_size'))
      .textAlign(TextAlign.Center)
      .fontWeight(Constants.FONT_WEIGHT_400)
      .fontColor(Color.White)
  }
  .onClick(() => {
    clickCallback()
  })
}

@Builder
export function ScanAbility(name: ResourceStr, index: number, currentIndex: number) {
  Column() {
    Text(name)
      .fontFamily($r('app.string.medium_font_family'))
      .fontSize($r('app.float.smaller_font_size'))
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .fontWeight(Constants.FONT_WEIGHT_500)
      .margin({ bottom: $r('app.float.span4') })
    Row()
      .width($r('app.float.active_dot_size'))
      .height($r('app.float.active_dot_size'))
      .borderRadius($r('app.float.br2'))
      .backgroundColor(currentIndex === index ? $r('app.color.active_dot_color') : Color.Transparent)
  }
  .width($r('app.float.active_dot_size_width'))
}


@CustomDialog
export struct ScanQRCodeDialog {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = Constants.BREAKPOINT_SM;
  @State cameraWidth: number = Constants.INIT_CAMERA_WIDTH_DIALOG;
  @State cameraHeight: number = Constants.INIT_CAMERA_HEIGHT_DIALOG;
  @State currentIndex: number = 0;
  @State scanAbilities: ResourceStr[] = Constants.SCAN_ABILITIES;
  @State marginTop: number = 50;
  @Link isScanDialogOpen: boolean;
  @Consume('pathInfos') pathInfos: NavPathStack;
  private controller?: CustomDialogController;
  private receivePayment: Function = () => {
  };
  private playAnimation = () => this.marginTop = 320;
  private openReceiveMoney = () => {
    this.isScanDialogOpen = false;
    if (this.currentBreakpoint === 'sm') {
      this.pathInfos.pushPath({ name: 'ReceivePaymentPage' });
    } else {
      this.receivePayment();
    }
  };

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        XComponentView({
          cameraWidth: this.cameraWidth,
          cameraHeight: this.cameraHeight,
          playAnimation: this.playAnimation
        })
      }
      .width($r('app.float.half_dialog_width'))
      .height($r('app.float.half_dialog_height'))
      .clip(true)
      .borderRadius($r('app.float.b424'))

      Column() {
        Row() {
          Text($r('app.string.scan_text'))
            .fontFamily('HarmonyHeiTi-Bold')
            .fontSize($r('app.float.biggest_font_size'))
            .fontColor(Color.White)
            .fontWeight(Constants.FONT_WEIGHT_700)
          Row() {
            Image($r('app.media.ic_close'))
              .width(Constants.FULL_WIDTH)
              .height(Constants.FULL_HEIGHT)
              .fillColor(Color.White)
          }
          .width($r('app.float.icon_close_size'))
          .height($r('app.float.icon_close_size'))
          .backgroundColor($r('app.color.border_divider_color'))
          .borderRadius($r('app.float.br20'))
          .onClick(() => {
            this.isScanDialogOpen = false;
          })
        }
        .width(Constants.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: $r('app.float.title_margin_function') })

        Row() {
          Column() {
            FunctionCard($r('app.media.ic_payment_code'), $r('app.string.pay_and_receive'), this.openReceiveMoney)
          }

          Column() {
            FunctionCard($r('app.media.ic_album'), $r('app.string.photo_album'), () => {
            })
          }
        }
        .width(Constants.FULL_WIDTH)
        .padding({
          left: $r('app.float.padding_80'),
          right: $r('app.float.padding_80')
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: $r('app.float.function_margin_scan_ability') })


        Row() {
          Blank()
          ForEach(this.scanAbilities, (item: string, index: number) => {
            ScanAbility(item, index, this.currentIndex)
          }, (item: string) => item)
        }
        .width(Constants.FULL_WIDTH)
        .height($r('app.float.scan_ability_height'))
      }
      .width($r('app.float.half_dialog_width'))
      .height($r('app.float.half_dialog_height'))
      .padding($r('app.float.br16'))
      .backgroundColor($r('app.color.scan_dialog_back_color'))
      .borderRadius($r('app.float.br24'))

      Row() {
        Image($r('app.media.scan_animation'))
          .width(Constants.FULL_WIDTH)
      }
      .width($r('app.float.scan_animation_width'))
      .height($r('app.float.scan_animation_height'))
      .margin({ top: this.marginTop })
      .animation({
        duration: 2500,
        curve: Curve.Linear,
        iterations: -1,
        playMode: PlayMode.Normal
      })
    }
  }
}