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

import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { CyclingConstants, CyclingStatus } from '../constants/CyclingConstants';
import { liveViewController } from '../liveview/LiveViewController';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { LiveViewContext } from '../liveview/LiveViewContext';
import { MapUtil } from '../utils/MapUtil';

@Entry
@Component
struct Pay {
  @StorageLink('longitude') longitude: number = CyclingConstants.LONGITUDE;
  @StorageLink('latitude') latitude: number = CyclingConstants.LATITUDE;
  mapOption?: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: this.latitude,
        longitude: this.longitude
      },
      zoom: CyclingConstants.ZOOM
    },
    mapType: mapCommon.MapType.STANDARD
  };
  private callback?: AsyncCallback<map.MapComponentController>;
  private liveViewContext?: LiveViewContext;

  aboutToAppear(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const bundleName = context.abilityInfo.bundleName;
    const abilityName = context.abilityInfo.name;
    this.liveViewContext = {
      want: {
        bundleName,
        abilityName
      },
    }

    this.callback = async (err, mapController) => {
      if (!err) {
        MapUtil.initializeMapWithLocation(mapController)
      }
    };
  }

  onBackPress(): boolean | void {
    return true;
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })
          .width(CyclingConstants.FULL_PERCENT)
          .height(CyclingConstants.FULL_PERCENT)

        Column() {
          Column({ space: CyclingConstants.PAY_COLUMN_SPACE }) {
            Text($r('app.string.pay_text'))
              .fontSize($r('app.float.pay_text_fontSize'))
              .fontWeight(FontWeight.Bold)
              .opacity($r('app.float.pay_text_opacity'))
              .height($r('app.float.pay_text_height'))
            Text($r('app.string.pay_text_time'))
              .fontSize($r('app.float.pay_text_fontSize_second'))
              .height($r('app.float.pay_text_height_second'))
              .opacity($r('app.float.pay_text_opacity_second'))
            Divider()
              .strokeWidth(CyclingConstants.DIVIDER_STROKE_WIDTH)
              .opacity($r('app.float.divider_opacity'))
              .margin({ top: $r('app.float.margin_top') })
            Row() {
              Text($r('app.string.pay_text_third'))
                .fontSize($r('app.float.pay_text_fontSize_third'))
                .fontWeight(FontWeight.Bold)
                .opacity($r('app.float.pay_text_opacity'))
              Text($r('app.string.pay_text_fourth'))
                .fontSize($r('app.float.pay_text_fontSize_second'))
                .opacity($r('app.float.pay_text_opacity_second'))
                .margin({ left: $r('app.float.pay_margin_left') })
              Blank()
              Text($r('app.string.pay_text_fifth'))
                .fontSize($r('app.float.pay_text_fontSize_fourth'))
                .opacity($r('app.float.pay_text_opacity'))
                .fontWeight(FontWeight.Medium)
                .margin({ right: $r('app.float.pay_margin_right') })
            }
            .margin({ top: $r('app.float.margin_top') })
            .width(CyclingConstants.FULL_PERCENT)
          }
          .margin({ left: $r('app.float.pay_margin_left_second'), top: $r('app.float.pay_margin_top') })
          .alignItems(HorizontalAlign.Start)

          Row({ space: CyclingConstants.PAY_ROW_SPACE }) {
            Text($r('app.string.pay_text_sixth'))
              .fontSize($r('app.float.pay_text_fontSize_second'))
              .fontWeight(FontWeight.Regular)
              .opacity($r('app.float.pay_text_opacity_second'))
            Image($r('app.media.unfold'))
              .height($r('app.float.pay_image_height'))
              .width($r('app.float.pay_image_width'))
          }
          .margin({ top: $r('app.float.pay_margin_top_second') })
          .alignSelf(ItemAlign.Center)

          Blank()
          Row() {
            Text($r('app.string.pay_text_seventh'))
              .fontWeight(FontWeight.Medium)
              .fontSize($r('app.float.pay_text_fontSize_sixth'))
              .opacity($r('app.float.pay_text_opacity'))
              .margin({ left: $r('app.float.pay_margin_left_third') })
            Text($r('app.string.pay_text_eighth'))
              .height($r('app.float.pay_text_height_third'))
              .width($r('app.float.pay_text_width_third'))
              .fontSize($r('app.float.pay_fontSize_third'))
              .fontColor(Color.Black)
              .opacity($r('app.float.pay_text_opacity_second'))
              .margin({ left: $r('app.float.pay_margin_left_fifth') })
              .alignSelf(ItemAlign.End)
            Blank()
            Button($r('app.string.pay_text_ninth'))
              .width($r('app.float.pay_button_height'))
              .height($r('app.float.pay_button_width'))
              .backgroundColor($r('app.color.blue'))
              .fontColor(Color.White)
              .onClick(async () => {
                this.getUIContext().getRouter().replaceUrl({
                  url: 'pages/PayCompleted'
                })
                await liveViewController.updateLiveView(CyclingStatus.PAYMENT_COMPLETED, this.liveViewContext!);
              })
              .margin({ right: $r('app.float.pay_margin_right_third') })
          }
          .margin({ bottom: $r('app.float.pay_margin_top_third') })
          .width(CyclingConstants.FULL_PERCENT)
        }
        .borderRadius({
          topLeft: $r('app.float.pay_border_radius'),
          topRight: $r('app.float.pay_border_radius')
        })
        .height($r('app.string.pay_column_height'))
        .width(CyclingConstants.FULL_PERCENT)
        .backgroundColor(Color.White)
      }

    }
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .title($r('app.string.pay_title'))
    .width(CyclingConstants.FULL_PERCENT)
    .height(CyclingConstants.FULL_PERCENT)
  }
}
