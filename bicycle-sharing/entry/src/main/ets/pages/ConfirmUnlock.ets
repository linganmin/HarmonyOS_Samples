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
import { LiveViewContext } from '../liveview/LiveViewContext';
import { common } from '@kit.AbilityKit';
import { liveViewController } from '../liveview/LiveViewController';
import { router } from '@kit.ArkUI';
import { CyclingConstants } from '../constants/CyclingConstants';
import { MapUtil } from '../utils/MapUtil';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

let backTmp: NavigationMenuItem = {
  value: '',
  icon: 'resources/base/media/backTmp.svg',
  action: () => {
    uiContext?.getRouter().back();
  }
}

@Entry
@Component
struct ConfirmUnlock {
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
  @State isPresent: boolean = false;

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

    this.isPresent = true;
    this.callback = async (err, mapController) => {
      if (!err) {
        MapUtil.initializeMapWithLocation(mapController)
        mapController.on('mapClick', async () => {
          this.isPresent = true;
        })
      }
    };
  }

  aboutToDisappear(): void {
    this.callback = async (err, mapController) => {
      if (!err) {
        mapController.off('mapClick', async () => {
        })
      }
    };
  }

  onBackPress(): boolean | void {
    return true;
  }

  build() {
    Navigation() {
      Column() {
        MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })
          .width(CyclingConstants.FULL_PERCENT)
          .height(CyclingConstants.FULL_PERCENT)
          .bindSheet($$this.isPresent, this.halfModal(), {
            height: CyclingConstants.SHEET_HEIGHT,
            dragBar: true,
            preferType: SheetType.CENTER,
            showClose: true,
            shouldDismiss: ((sheetDismiss: SheetDismiss) => {
              sheetDismiss.dismiss();
            })
          })
      }
    }
    .hideBackButton(true)
    .menus([backTmp])
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .title($r('app.string.navigation_title'))
    .width(CyclingConstants.FULL_PERCENT)
    .height(CyclingConstants.FULL_PERCENT)
  }

  @Builder
  halfModal() {
    Column() {
      Text($r('app.string.service_alerts'))
        .fontSize($r('app.float.service_fontSize'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: $r('app.float.service_top') })

      Text($r('app.string.terms'))
        .opacity($r('app.float.service_opacity'))
        .fontSize($r('app.float.terms_fontSize'))
        .lineHeight($r('app.float.terms_lineHeight'))
        .margin({
          right: $r('app.float.terms_margin'),
          top: $r('app.float.terms_margin')
        })

      Row({ space: CyclingConstants.CONFIRMUNLOCK_ROW_SPACE }) {
        Text($r('app.string.rule'))
          .fontSize($r('app.float.terms_fontSize'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontColor($r('app.color.blue'))

        Image($r('app.media.bearing'))
          .width($r('app.float.bearing_width'))
          .height($r('app.float.bearing_height'))
      }
      .margin({ top: $r('app.float.bearing_top') })

      Button($r('app.string.unlock_button'))
        .width(CyclingConstants.FULL_PERCENT)
        .height($r('app.float.button_height'))
        .backgroundColor($r('app.color.blue'))
        .fontColor(Color.White)
        .onClick(async () => {
          liveViewController.startLiveView(this.liveViewContext!);
          this.getUIContext().getRouter().replaceUrl({
            url: 'pages/Riding'
          })
        })
        .margin({ top: $r('app.float.button_top') })
    }
    .padding({ left: $r('app.float.terms_margin'), right: $r('app.float.terms_margin') })
    .backgroundColor(Color.White)
    .height(CyclingConstants.FULL_PERCENT)
    .width(CyclingConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
  }
}
