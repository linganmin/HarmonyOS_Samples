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
struct Riding {
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
      }
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
          Text($r('app.string.riding_text'))
            .fontSize($r('app.float.riding_fontSize'))
            .fontWeight(FontWeight.Bold)
            .margin({ top: $r('app.float.riding_margin_top') })
            .alignSelf(ItemAlign.Start)

          Divider()
            .strokeWidth(CyclingConstants.DIVIDER_STROKE_WIDTH)
            .opacity($r('app.float.divider_opacity'))
            .margin({ top: $r('app.float.margin_top') })

          Row({ space: CyclingConstants.RIDDING_ROW_SPACE }) {
            this.TimeCost($r('app.string.riding_text'), CyclingConstants.RIDDING_TEXT_SECOND, false)
            this.TimeCost($r('app.string.ridding_text_third'), CyclingConstants.RIDDING_TEXT_FOURTH, true)
          }
          .margin({ top: $r('app.float.riding_margin_top_second') })

          Blank()
          Button($r('app.string.riding_text_second'))
            .width(CyclingConstants.FULL_PERCENT)
            .height($r('app.float.button_height'))
            .backgroundColor($r('app.color.blue'))
            .fontColor(Color.White)
            .onClick(async () => {
              this.getUIContext().getRouter().replaceUrl({
                url: 'pages/Pay'
              })
              await liveViewController.updateLiveView(CyclingStatus.WAITING_PAYMENT, this.liveViewContext!);
            })
            .margin({ bottom: $r('app.float.riding_margin_top_second') })
        }
        .padding({ left: $r('app.float.terms_margin'), right: $r('app.float.terms_margin') })
        .borderRadius({
          topLeft: $r('app.float.pay_border_radius'),
          topRight: $r('app.float.pay_border_radius')
        })
        .alignItems(HorizontalAlign.Center)
        .height($r('app.string.pay_column_height'))
        .width(CyclingConstants.FULL_PERCENT)
        .backgroundColor(Color.White)
      }
    }
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .title($r('app.string.navigation_title'))
    .width(CyclingConstants.FULL_PERCENT)
    .height(CyclingConstants.FULL_PERCENT)
  }

  @Builder
  TimeCost(aboveDes: string | Resource, downDes: string, isCost: boolean) {
    Column() {
      Text(aboveDes)
        .height($r('app.float.riding_text_height'))
        .fontSize($r('app.float.riding_text_fontSize'))
        .opacity($r('app.float.pay_text_opacity_second'))
      Row() {
        Text(downDes)
          .height($r('app.float.riding_text_height_second'))
          .fontSize($r('app.float.riding_text_fontSize_second'))
          .fontWeight(FontWeight.Bold)
        if (isCost) {
          Text($r('app.string.pay_text_eighth'))
            .height($r('app.float.riding_text_height_third'))
            .width($r('app.float.pay_text_width_third'))
            .fontSize($r('app.float.riding_text_fontSize_third'))
            .fontColor(Color.Black)
            .opacity($r('app.float.pay_text_opacity_second'))
            .margin({ left: $r('app.float.riding_margin_left_third') })
        }
      }
    }

  }
}
