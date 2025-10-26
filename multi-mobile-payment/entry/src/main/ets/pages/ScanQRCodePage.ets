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

import { FunctionCard, ScanAbility } from '../view/ScanQRCodeDialog';
import { Constants } from '../common/Constants';
import { XComponentView } from '../view/XComponentView';

const aspectToHeightRatio = 4 / 3;

@Component
export struct ScanQRCodePage {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = '';
  @State cameraWidth: number = 1000 * aspectToHeightRatio;
  @State cameraHeight: number = 1000;
  @State currentIndex: number = 0;
  @State scanAbilities: ResourceStr[] = Constants.SCAN_ABILITIES;
  @State marginTop: number = -500;
  @Consume('pathInfos') pathInfos: NavPathStack;
  private openReceiveMoney = () => this.pathInfos.pushPath({ name: 'ReceivePaymentPage' });
  private playAnimation = () => this.marginTop = 450;

  build() {
    Stack() {
      Column() {
        XComponentView({
          cameraWidth: this.cameraWidth,
          cameraHeight: this.cameraHeight,
          playAnimation: this.playAnimation
        })
      }
      .width(Constants.FULL_WIDTH)
      .height(Constants.FULL_HEIGHT)
      .clip(true)

      Column() {
        Row() {
          Image($r('app.media.ic_return'))
            .width($r('app.float.tabs_icon_size'))
            .height($r('app.float.tabs_icon_size'))
            .onClick(() => {
              this.pathInfos.pop();
            })
          Image($r('app.media.ic_four_dot'))
            .width($r('app.float.four_dot_size'))
            .height($r('app.float.four_dot_size'))
        }
        .width(Constants.FULL_WIDTH)
        .height($r('app.float.function_row_height'))
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        Column() {
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
            left: $r('app.float.scan_page_space'),
            right: $r('app.float.scan_page_space'),
          })
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            ForEach(this.scanAbilities, (item: string, index: number) => {
              ScanAbility(item, index, this.currentIndex)
            }, (item: string) => item)
          }
          .width(Constants.FULL_WIDTH)
          .height($r('app.float.scan_ability_height'))
          .justifyContent(FlexAlign.Center)
          .margin({ top: $r('app.float.scan_page_margin_func') })
        }
        .width(Constants.FULL_WIDTH)

      }
      .width(Constants.FULL_WIDTH)
      .height(Constants.FULL_HEIGHT)
      .padding({
        top: $r('app.float.span16'),
        bottom: $r('app.float.span16'),
        left: $r('app.float.span24'),
        right: $r('app.float.span24')
      })
      .backgroundColor($r('app.color.all_opacity'))
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Image($r('app.media.scan_animation'))
          .width(Constants.FULL_WIDTH)
      }
      .width(Constants.FULL_WIDTH)
      .height($r('app.float.scan_animation_height'))
      .margin({ top: this.marginTop })
      .animation({
        duration: 2500,
        curve: Curve.Linear,
        iterations: -1,
        playMode: PlayMode.Normal
      })
    }
    .width(Constants.FULL_WIDTH)
    .height(Constants.FULL_HEIGHT)
  }
}