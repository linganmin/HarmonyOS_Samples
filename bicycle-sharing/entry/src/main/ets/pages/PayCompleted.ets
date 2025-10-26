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
import { CyclingConstants } from '../constants/CyclingConstants';
import { MapUtil } from '../utils/MapUtil';
import { router } from '@kit.ArkUI';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

let backTmp: NavigationMenuItem = {
  value: '',
  icon: 'resources/base/media/backTmp.svg',
  action: () => {
    uiContext?.getRouter().replaceUrl({
      url: 'pages/CyclingPage'
    }, router.RouterMode.Single);
    uiContext?.getRouter().clear();
  }
}

@Entry
@Component
struct PayCompleted {
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

  aboutToAppear(): void {
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
          Image($r('app.media.ic_public_todo_filled'))
            .width($r('app.float.completed_image_height'))
            .height($r('app.float.completed_image_width'))
            .margin({ top: $r('app.float.completed_margin_top') })
          Blank()
          Column() {
            Text($r('app.string.completed_text'))
              .fontSize($r('app.float.completed_fontSize'))
              .fontWeight(FontWeight.Bold)

            Text($r('app.string.completed_text_second'))
              .fontSize($r('app.float.completed_fontSize_second'))
              .margin({ top: $r('app.float.bearing_top') })
          }
          .margin({ bottom: $r('app.float.pay_completed_bottom') })

        }
        .borderRadius({
          topLeft: $r('app.float.pay_border_radius'),
          topRight: $r('app.float.pay_border_radius')
        })
        .alignItems(HorizontalAlign.Center)
        .height($r('app.string.index_map_height'))
        .width(CyclingConstants.FULL_PERCENT)
        .backgroundColor(Color.White)
      }
    }
    .menus([backTmp])
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .title($r('app.string.completed_title'))
    .width(CyclingConstants.FULL_PERCENT)
    .height(CyclingConstants.FULL_PERCENT)
  }
}
